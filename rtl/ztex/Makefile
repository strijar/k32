ZTEX=~/ztex/ztex

DESIGN		= ztex

TOP		= top

SRC     = \
    ../core/k32_decode.vhd\
    ../core/k32_ex.vhd\
    ../core/k32_decode.vhd\
    ../core/k32_fetch.vhd\
    ../core/k32_dstack.vhd\
    ../core/k32_dstack_ext.vhd\
    ../core/k32_pkg.vhd\
    ../core/k32.vhd\
    ../uart/uart.vhd\
    ram.vhd\
    top.vhd

DEVICE		= xc6slx25-ftg256-3
#DEVICE		= xc6slx75-csg484-3

all:		$(DESIGN).bit

clean:
		rm -f *~

cleanall:	clean
		rm -rf build $(DESIGN).bit

check:		build/$(DESIGN).ngc

build/$(DESIGN).src:
		@[ -d build ] || mkdir build
		@rm -f $@
		for i in $(SRC); do echo vhdl work ../$$i >> $@; done

build/$(DESIGN).xst: build/$(DESIGN).src
		echo "run" > $@
		echo "-top $(TOP)" >> $@
		echo "-p $(DEVICE)" >> $@
		echo "-ifn $(DESIGN).src" >> $@
		echo "-ofn $(DESIGN)" >> $@
		echo "-ofmt NGC" >> $@
		echo "-lso ../$(DESIGN).lso" >>$@
		echo "-ifmt mixed" >> $@
		echo "-ofn counter_3bit" >> $@
		echo "-opt_mode speed" >> $@
		echo "-opt_level 2" >> $@
		echo "-iuc NO" >> $@
		echo "-keep_hierarchy NO" >> $@
		echo "-netlist_hierarchy as_optimized" >> $@
		echo "-rtlview Yes" >> $@
		echo "-glob_opt AllClockNets" >> $@
		echo "-read_cores YES" >> $@
		echo "-write_timing_constraints NO" >> $@
		echo "-cross_clock_analysis NO" >> $@
		echo "-hierarchy_separator /" >> $@
		echo "-bus_delimiter <>" >> $@
		echo "-case maintain" >> $@
		echo "-slice_utilization_ratio 100" >> $@
		echo "-bram_utilization_ratio 100" >> $@
		echo "-fsm_extract YES -fsm_encoding Auto" >> $@
		echo "-safe_implementation No" >> $@
		echo "-fsm_style lut" >> $@
		echo "-ram_extract Yes" >> $@
		echo "-ram_style Auto" >> $@
		echo "-rom_extract Yes" >> $@
		echo "-shreg_extract YES" >> $@
		echo "-rom_style Auto" >> $@
		echo "-auto_bram_packing NO" >> $@
		echo "-resource_sharing YES" >> $@
		echo "-async_to_sync NO" >> $@
		echo "-iobuf YES" >> $@
		echo "-max_fanout 500" >> $@
		echo "-bufg 32" >> $@
		echo "-register_duplication YES" >> $@
		echo "-register_balancing NO" >> $@
		echo "-optimize_primitives NO" >> $@
		echo "-use_clock_enable Auto" >> $@
		echo "-use_sync_set Auto" >> $@
		echo "-use_sync_reset Auto" >> $@
		echo "-iob auto" >> $@
		echo "-equivalent_register_removal YES" >> $@
		echo "-slice_utilization_ratio_maxmargin 5" >> $@

build/$(DESIGN).ngc: build/$(DESIGN).xst $(SRC)
		cd build && xst -intstyle ise -ifn $(DESIGN).xst -ofn $(DESIGN).syr

build/$(DESIGN).ngd: build/$(DESIGN).ngc $(DESIGN).ucf
		cd build && ngdbuild -intstyle ise -dd _ngo -nt timestamp -uc ../$(DESIGN).ucf -p $(DEVICE) $(DESIGN).ngc $(DESIGN).ngd

build/$(DESIGN).ncd: build/$(DESIGN).ngd
		cd build && map -w -intstyle ise -p $(DEVICE) -pr off -c 100 -timing -o $(DESIGN)_map.ncd $(DESIGN).ngd $(DESIGN).pcf

build/$(DESIGN)_r.ncd: build/$(DESIGN).ncd
		cd build && par -w -intstyle ise -ol high $(DESIGN)_map.ncd $(DESIGN).ncd $(DESIGN).pcf

build/$(DESIGN)_r.twr: build/$(DESIGN)_r.ncd
		cd build && trce -intstyle ise -e 3 -xml $(DESIGN) $(DESIGN).ncd -o $(DESIGN).twr $(DESIGN).pcf

$(DESIGN).bit:	build/$(DESIGN)_r.ncd build/$(DESIGN)_r.twr
		cd build && bitgen -w -intstyle ise -f ../$(DESIGN).ut $(DESIGN).ncd
		@cp -f build/$(DESIGN).bit $@

upload:
	$(ZTEX)/java/FWLoader/FWLoader -c -rf -uf $(DESIGN).bit

load:
	xc3sprog -c ftdi -v -p 0 $(DESIGN).bit
