
修改项目中所有文件的mtime属性，解决因往返修改系统时间导致rebar编译所有文件问题。

注意：需要modify.erl文件中修改如下常量宏。
```
-define(Default_RootDir, "../").%%根目录
-define(Default_Suffix, [".erl", ".hrl"]).%%文件后缀
-define(Default_ErlCInfo, "../.rebar/erlcinfo").%%rebar记录文件路径
```

操作流程：
1、在erlShell中执行`modify:start().`
```
        1> modify:start().
          [modify] [30] | start.
          [modify] [32] | total num:{512}
          [modify] [37] | success, usrTime:{467}ms
          ok
```
2、清理所有 .beam 文件（执行 `rebar clean`）
3、开始编译（执行 `rebar compile`）
