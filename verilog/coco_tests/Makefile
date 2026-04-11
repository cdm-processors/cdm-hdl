#_____________CONFIG_____________
TOPLEVEL_LANG = verilog
SIM = icarus

VERILOG_SRC= $(CURDIR)/..
RTL_DIR = $(VERILOG_SRC)/rtl
MODULES_DIR = $(RTL_DIR)/modules

TESTS_DIR = modules

COMPILE_ARGS = -I$(RTL_DIR)

#_____________COCOTB______________
ifeq ($(MAKECMDGOALS),)
ifndef VERILOG_SOURCES
$(error ERROR: use make *_tests instead of make)
endif
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

#_____________TESTS______________
all_tests: alu_tests decoder_tests

alu_tests:
	@echo "-----------------ALU_TESTS---------------------"
	$(MAKE) \
		COCOTB_TEST_MODULES=$(TESTS_DIR).alu_tests \
		TOPLEVEL=alu \
		VERILOG_SOURCES=$(MODULES_DIR)/alu.sv

decoder_tests:
	@echo "-----------------DECODER_TESTS-----------------"
	$(MAKE) \
		COCOTB_TEST_MODULES=$(TESTS_DIR).decoder_tests\
		TOPLEVEL=decoder \
		VERILOG_SOURCES="$(MODULES_DIR)/decoder.sv $(MODULES_DIR)/branch.sv"

.PHONY: all alu_tests decoder_tests