# для cocotb+iverilog
# cocotb-тест
TOPLEVEL_LANG = verilog
SIM = icarus

EXTRA_ARGS += -I../../lib

TOP ?= alu
# TEST ?= test_alu

TOPLEVEL = $(TOP)
# MODULE   = $(TEST)

# VERILOG_SOURCES = \
#   ../../src/rtl/$(TOP).sv \
#   ../../src/rtl/register_file.sv \
#   ../../src/rtl/pc.sv


include $(shell cocotb-config --makefiles)/Makefile.sim