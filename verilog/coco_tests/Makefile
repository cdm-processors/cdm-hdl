#_____________CONFIG_____________
TOPLEVEL_LANG = verilog
SIM = icarus

TEST_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
VERILOG_SRC := $(abspath $(TEST_DIR)/..)
RTL_DIR := $(VERILOG_SRC)/rtl
MODULES_DIR := $(RTL_DIR)/modules

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
all_tests: alu_tests decoder_tests gen_ucode_tests imm_decoder_tests
	@echo "-----------------ALL_TESTS_COMPLETED-----------------"

alu_tests:
	@echo "-----------------ALU_TESTS---------------------"
	$(MAKE) -C $(TEST_DIR) \
		SIM_BUILD=$(TEST_DIR)sim_build/alu \
		COCOTB_TEST_MODULES=$(TESTS_DIR).alu_tests \
		TOPLEVEL=alu \
		VERILOG_SOURCES=$(MODULES_DIR)/alu.sv

decoder_tests:
	@echo "-----------------DECODER_TESTS-----------------"
	$(MAKE) -C $(TEST_DIR) \
		SIM_BUILD=$(TEST_DIR)sim_build/decoder \
		COCOTB_TEST_MODULES=$(TESTS_DIR).decoder_tests \
		TOPLEVEL=decoder \
		VERILOG_SOURCES="$(MODULES_DIR)/decoder.sv $(MODULES_DIR)/branch.sv"

gen_ucode_tests:
	@echo "-----------------GEN_UCODE_TESTS-----------------"
	$(MAKE) -C $(TEST_DIR) \
		SIM_BUILD=$(TEST_DIR)sim_build/gen_ucode \
		COCOTB_TEST_MODULES=$(TESTS_DIR).gen_ucode_tests \
		TOPLEVEL=gen_ucode \
		VERILOG_SOURCES=$(MODULES_DIR)/gen_ucode.sv

imm_decoder_tests:
	@echo "-----------------IMM_DECODER_TESTS-----------------"
	$(MAKE) -C $(TEST_DIR) \
		SIM_BUILD=$(TEST_DIR)sim_build/imm_decoder \
		COCOTB_TEST_MODULES=$(TESTS_DIR).imm_decoder_tests \
		TOPLEVEL=imm_decoder \
		VERILOG_SOURCES=$(MODULES_DIR)/imm_decoder.sv

.PHONY: all_tests alu_tests decoder_tests gen_ucode_tests imm_decoder_tests
