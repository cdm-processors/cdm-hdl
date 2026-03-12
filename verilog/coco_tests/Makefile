TOPLEVEL_LANG = verilog
SIM = icarus

VERILOG_SRC= $(CURDIR)/../
RTL_DIR = ${VERILOG_SRC}/rtl

VERILOG_SOURCES = ${RTL_DIR}/modules/alu.sv

TOPLEVEL = alu
MODULE = modules/alu_tests.py

include $(shell cocotb-config --makefiles)/Makefile.sim