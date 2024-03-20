# Change Logs

## v1.0.14

 - fix bug: old file isn't replaced whtn a new file is uploaded. newly uploaded file in single file mode should overwrite the original file.


## v1.0.13

 - fix bug: exception when canceling file selection after blocked upload by rule, because we didn't clear input node value after 1020 error.


## v1.0.12

 - integrate code for uploading multiple / non-multiple files
 - support `ext.detail` for child blocks that are able to anaylze different file format
 - throw exception for all error except 1020 in uploading process


## v1.0.11

 - use `mf-note` to replace styling in note-related tag.


## v1.0.10

 - fix bug: missing 1.0.9 dist 


## v1.0.9

 - tweak `no file` hint style to separate from error


## v1.0.8

 - precheck files against terms to prevent incompatible file from uploading


## v1.0.7

 - bug fix: `上傳時間` should be `編輯時戳`


## v1.0.6

 - tweak layout for inline mode


## v1.0.5

 - fix bug: title class `d-flex` was incorrectly added twice, one of which should be `flex-wrap`.


## v1.0.4

 - rename `文件` to `檔案` for better semantic when this block is extended.
 - tweak file list UI
 - support preview plugin for child blocks to customize.


## v1.0.3

 - make file info wrappable
 - upgrade dev dependencies


## v1.0.2

 - make title bar wrappable


## v1.0.1

 - use `g-2`, `g-3` instead of `_g-2`, `_g-3` since they are buggy
 - audit fix for fixing vulnerabilities in dependencies


## v1.0.0

 - init release

