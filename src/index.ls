module.exports =
  pkg:
    name: "@makeform/upload"
    extend: name: '@makeform/common'
    i18n:
      en:
        "未命名的檔案": "unnamed file"
        "上傳": "upload"
        "上傳中": "uploading"
        "尚未上傳任何檔案": "no file uploaded yet"
        "檔案大小": "File Size"
        "編輯時戳": "Last Modified"
        "上傳時戳": "Upload Time"
        "檔案規格不符": "Specifications of the file(s) to upload do not matched"
      "zh-TW":
        "未命名的檔案": "未命名的檔案"
        "上傳": "上傳"
        "上傳中": "上傳中"
        "尚未上傳任何檔案": "尚未上傳任何檔案"
        "檔案大小": "檔案大小"
        "編輯時戳": "編輯時戳"
        "上傳時戳": "上傳時戳"
        "檔案規格不符": "欲上傳的檔案不符規格"
    dependencies: [
      {url: "https://cdn.jsdelivr.net/npm/moment@2.29.1/moment.min.js", async: false}
      {url: "https://cdn.jsdelivr.net/npm/moment-timezone@0.5.34/builds/moment-timezone-with-data.min.js"}
    ]

  ext: -> @_ext <<< it
  init: (opt) ->
    @_ext = {}
    opt.pubsub.fire \subinit, mod: mod(opt, @_ext)
mod = ({root, ctx, data, parent, pubsub, t, i18n}, ext) ->
  {ldview, moment} = ctx
  lc = {uploading: false}
  init: ->
    _uploading = (v, p) ->
      lc <<< {uploading: v, percent: p}
      view.render <[file-uploading no-file]>
    @on \change, ~>
      lc.file = it
      @mod.child.view.render <[file-info no-file]>
      if @mod.child.view => @mod.child.view.render!
      if ext.view => 
        ext.view.setCtx lc
        ext.view.render!
    progress = -> _uploading true, it.percent
    @mod.child.view = view = new ldview do
      root: root
      action:
        change: input: ({node}) ~>
          if !@mod.child._upload => return
          p = Promise.all(
            Array.from(node.files).map (f) ~>
             if !ext.is-supported => {supported: true} 
             else ext.is-supported f
          )
            .then (list) ->
              if !list.filter(-> !it.supported).length => return
              return Promise.reject new Error! <<< {name: \lderror, id: 1020, message: list.0.message or ''}
            .then ~>
              # check each file against terms other than count
              files = [node.files[i] for i from 0 til node.files.length]
                .map (f) ~> f = {size: f.size, filename: f.name, blob: f}
              (if ext.detail => ext.detail files else Promise.resolve(files))
                .then (files) ~>
                  ps = files.map (f) ~>
                    ps = (@_meta.term or []).map (t) ->
                      # TODO we need to add sth like `precheck` flag in op
                      # in hint block which op should be check in advance
                      if /count/.exec(t.op.id) => return Promise.resolve true
                      t.validate(f)
                    # filter and check if this file fails in any term
                    Promise.all ps .then -> it.filter(->!it).length > 0
                  # filter and return the count of files that fails in any term
                  Promise.all ps .then -> it.filter(->it).length
            .then (failed-file-count) ~>
              if failed-file-count => return Promise.reject new Error! <<< {name: \lderror, id: 1020}
              btn = view.get \button
              btn.classList.toggle \running, true
              files = if !@mod.info.config.multiple => [(node.files or []).0].filter(->it)
              else (node.files or [])
              _ = (idx) ~>
                file = files[idx]
                if !file => return Promise.resolve!
                _uploading true, 0
                @mod.child._upload {file, progress}
                  .then (f) ->
                    f = [{} <<< f <<< {blob: file, uploadtime: new Date!getTime!}]
                    (if ext.detail => ext.detail(f) else Promise.resolve f)
                  .then (f) ->
                    f = f.0
                    delete f.blob
                    if !lc.file => lc.file = []
                    else if !Array.isArray(lc.file) => lc.file = [lc.file]
                    lc.file.push f
                    _(idx + 1)
              _(0)
                .finally ->
                  node.value = null
                  btn.classList.toggle \running, false
                  _uploading false, 1
                .then ~>
                  if !@mod.info.config.multiple => lc.file = lc.file[* - 1]
                  @value lc.file
                .then ~> view.render <[file-info no-file]>
                .catch ~>
                  @fire \upload-failed, it
                  return Promise.reject it
            .catch (e) ->
              node.value = null
              if lderror.id(e) != 1020 => throw e
              alert if e.message => that else t("檔案規格不符")
              console.log e

      handler:
        "file-uploading": ({node}) ->
          node.classList.toggle \d-none, !lc.uploading
          node.innerText = "#{t '上傳中'} / #{Math.floor((lc.percent or 0) * 10000)/100}%"

        "no-file": ({node}) ->
          no-file = !(if Array.isArray(lc.file) => lc.file.filter(->it).length else !!lc.file)
          node.classList.toggle \d-none, (!no-file or lc.uploading)

        "file-info":
          list: ->
            ret = if Array.isArray(lc.file) => lc.file else if lc.file => [lc.file] else []
            ret.filter -> it

          view:
            action: click:
              showtime: ({node, ctx}) ~>
                show = !node.classList.contains(\manual)
                node.classList.toggle \manual, show
                node.classList.toggle \tip-on, show
              delete: ({ctx}) ~>
                if !!@mod.info.meta.readonly => return
                Promise.resolve!
                  .then ~>
                    if !Array.isArray(lc.file) => return @value(lc.file = null)
                    if !~(idx = lc.file.indexOf(ctx)) => return
                    lc.file.splice idx, 1
                    @value lc.file
                  .then ~> view.render <[file-info no-file]>
            text:
              filemodifiedtime: ({node, ctx}) ->
                moment(ctx.modifiedtime).tz("Asia/Taipei").format("YYYY-MM-DD HH:mm:ss")
              uploadtime: ({node, ctx}) ->
                moment(ctx.uploadtime).tz("Asia/Taipei").format("YYYY-MM-DD HH:mm:ss")
              "filemodifiedtime-tz": ({node, ctx}) ->
                moment(ctx.modifiedtime).tz("Asia/Taipei").format("Z")
              "uploadtime-tz": ({node, ctx}) ->
                moment(ctx.uploadtime).tz("Asia/Taipei").format("Z")

            handler:
              delete: ({node}) ~>
                node.classList.toggle \d-none, !!@mod.info.meta.readonly
              size: ({node, ctx}) ->
                size = ctx.size or 0
                size = if size < 1024 => "#{size}bytes"
                else if size < 1048576 => "#{(size/1024).toFixed(2)}KB"
                else if size < (1024 * 1024 * 1024) => "#{(size/1048576).toFixed(2)}MB"
                else "#{(size/(1024 * 1024 * 1024)).toFixed(2)}GB"
                node.innerText = size
              "has-uploadtime": ({node, ctx}) -> node.classList.toggle \d-none, !ctx.uploadtime

              filename: ({node, ctx}) ->
                if !ctx => node.innerText = t("尚未上傳任何檔案")
                name = ctx.filename or t("未命名的檔案")
                if name.length > 40 => name = name.substring(0,40) + "..."
                node.innerText = name
              detail: ({node, ctx}) ->
                if ctx => node.setAttribute \href, ctx.url
                else node.removeAttribute \href
                node.classList.toggle \text-danger, !ctx

        input: ({node}) ~>
          if !@mod.child._upload or !!@mod.info.meta.readonly => node.setAttribute \disabled, true
          else node.removeAttribute \disabled
          if @mod.info.config.multiple => node.setAttribute \multiple, \multiple
          else node.removeAttribute \multiple
          op = (@mod.info.meta.term or []).filter(-> it.opset == \file and it.op == \extension).0
          if op =>
            accept = (op.config.str or '').split(',').filter(->it.length).map(-> ".#{it}").join(',')
            node.setAttribute \accept, accept
          else node.removeAttribute \accept

        button: ({node}) ~>
          ret = !@mod.child._upload or !!@mod.info.meta.readonly
          node.classList.toggle \disabled, ret

  render: ->
    if @mod.child.view => @mod.child.view.render!
    if ext.view => ext.view.render!
  adapt: (opt) ->
    @mod.child._upload = opt.upload
    @render!
  is-empty: (v) ->
    if typeof(v) == \undefined => return true
    if Array.isArray(v) => return v.length == 0
    return !v

