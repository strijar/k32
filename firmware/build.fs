include compile/utils.fs
include compile/cross.fs
include compile/basewords.fs
include compile/k32words.fs
include compile/save.fs

target

dict[
    $0800 org
    module[ NUC
        include lib/nuc.fs
        include lib/math.fs
        include lib/format.fs
    ]module

    $20 org
    module[ MAIN
        include main_life.fs
    ]module
]dict

0 org
code VECTORS
    main        ubranch
    .irq.       ubranch
    dict,
end-code

meta

:noname
    32 0
    2dup
    s" k32_vec.mem" save_mem
    s" k32_vec.bin" save_bin

    2dup
    s" k32_main.mem" save_mem
    s" k32_main.bin" save_bin

    2dup
    s" k32_nuc.mem" save_mem
    s" k32_nuc.bin" save_bin
; execute
