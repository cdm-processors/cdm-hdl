#_____________CONFIG_____________
TOPLEVEL_LANG = verilog
SIM = icarus

VERILOG_SRC= $(CURDIR)/..
RTL_DIR = $(VERILOG_SRC)/rtl

COMPILE_ARGS = -I$(RTL_DIR)

#_____________TESTS______________

# COCOTB_TEST_MODULES = modules.alu_tests
# VERILOG_SOURCES = ${RTL_DIR}/modules/alu.sv
# TOPLEVEL = alu


ifeq ($(MAKECMDGOALS),)
ifndef VERILOG_SOURCES
$(error ERROR: use make *_tests instead of make)
endif
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

all_tests: alu_tests decoder_tests

alu_tests:
	@echo "-----------------ALU_TESTS------------------"
	$(MAKE) \
		COCOTB_TEST_MODULES=modules.alu_tests \
		TOPLEVEL=alu \
		VERILOG_SOURCES=$(RTL_DIR)/modules/alu.sv

decoder_tests:
	@echo "-----------------DECODER_TESTS------------------"
	$(MAKE) \
		COCOTB_TEST_MODULES=modules.alu_tests \
		TOPLEVEL=alu \
		VERILOG_SOURCES=$(RTL_DIR)/modules/alu.sv
# 	$(MAKE) \
# 		COCOTB_TEST_MODULES=modules.decoder_tests \
# 		TOPLEVEL=decoder \
# 		VERILOG_SOURCES=$(RTL_DIR)/modules/decoder.sv

.PHONY: all alu_tests decoder_tests