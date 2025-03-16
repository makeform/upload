# @makeform/upload

Widget for users to upload file(s).


## Configs

 - `multiple`: boolean value, default false. if true, accept multiple files upload.



## Extension

`@makeform/upload` supports module extension with `ext` api: call `parent.ext` with following parameters to extend:

 - `view`: optional. ldview object to be rendered when re-rendered. `lc` object will be used as its context.
 - `render()`: a callback function that is called when re-rendered, with widget context.
 - `is-support(file)`:
   - given `file` object, return a promise resolving with `{supported}` object,
     indicating if that file is supported by true or false of `supported` field.
 - `detail(list)`: given a list of file objects, extend it with additional information.
   - return a promise.


## License

MIT
