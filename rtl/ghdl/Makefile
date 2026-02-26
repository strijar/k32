GHDL=ghdl
GHDLFLAGS= --std=93 --ieee=synopsys --workdir=work
GHDLRUNFLAGS=--wave=tb_k32.ghw

RAM = test

SRC = \
    ../core/k32_pkg.vhd\
    txt_util.vhd\
    ram_$(RAM).vhd\
    ../core/k32_fetch.vhd\
    ../core/k32_decode.vhd\
    ../core/k32_dstack.vhd\
    ../core/k32_q.vhd\
    ../core/k32_ex.vhd\
    ../core/k32.vhd\
    ../soc/uart.vhd\
    trace.vhd\
    tb_k32.vhd\

all: work/work-obj93.cf

work/work-obj93.cf: $(SRC)
	mkdir -p work
	$(GHDL) -a $(GHDLFLAGS) $(SRC)

run: work/work-obj93.cf
	$(GHDL) -r $(GHDLFLAGS) tb_k32 $(GHDLRUNFLAGS)

clean:
	rm -rf work *.ghw *.log
