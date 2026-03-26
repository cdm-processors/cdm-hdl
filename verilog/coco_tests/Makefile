#_____________CONFIG_____________
TOPLEVEL_LANG = verilog
SIM = icarus

VERILOG_SRC= $(CURDIR)/../
RTL_DIR = ${VERILOG_SRC}/rtl

#_____________TESTS______________
COCOTB_TEST_MODULES = modules.alu_tests
VERILOG_SOURCES = ${RTL_DIR}/modules/alu.sv
TOPLEVEL = alu
include $(shell cocotb-config --makefiles)/Makefile.sim