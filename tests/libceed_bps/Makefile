# Copyright (c) 2017, Lawrence Livermore National Security, LLC. Produced at
# the Lawrence Livermore National Laboratory. LLNL-CODE-734707. All Rights
# reserved. See files LICENSE and NOTICE for details.
#
# This file is part of CEED, a collection of benchmarks, miniapps, software
# libraries and APIs for efficient high-order finite element and spectral
# element discretizations for exascale applications. For more information and
# source code availability see http://github.com/ceed.
#
# The CEED research is supported by the Exascale Computing Project
# (17-SC-20-SC), a collaborative effort of two U.S. Department of Energy
# organizations (Office of Science and the National Nuclear Security
# Administration) responsible for the planning and preparation of a capable
# exascale ecosystem, including software, applications, hardware, advanced
# system engineering and early testbed platforms, in support of the nation's
# exascale computing imperative.

#
# This makefile is based on libCEED's examples/petsc/Makefile
#

PETSc.pc := $(PETSC_DIR)/$(PETSC_ARCH)/lib/pkgconfig/PETSc.pc
PETSc.pc := $(or $(wildcard $(PETSc.pc)),$(PETSC_DIR)/lib/pkgconfig/PETSc.pc)
CEED_DIR ?= ../..
ceed.pc := $(CEED_DIR)/lib/pkgconfig/ceed.pc

CC = $(call pkgconf, --variable=ccompiler $(PETSc.pc) $(ceed.pc))
CFLAGS = -std=c99 $(call pkgconf, --variable=cflags_extra $(PETSc.pc)) $(call pkgconf, --cflags-only-other $(PETSc.pc)) $(OPT)
CPPFLAGS = $(call pkgconf, --cflags-only-I $(PETSc.pc) $(ceed.pc))
## If using PETSc built as a shared library:
LDFLAGS = $(call pkgconf, --libs-only-L --libs-only-other $(PETSc.pc) $(ceed.pc))
LDFLAGS += $(patsubst -L%, $(call pkgconf, --variable=ldflag_rpath $(PETSc.pc))%, $(call pkgconf, --libs-only-L $(PETSc.pc) $(ceed.pc)))
LDLIBS = $(call pkgconf, --libs-only-l $(PETSc.pc) $(ceed.pc)) -lm
## If using PETSc built as a static library:
LDFLAGS = $(call pkgconf, --libs-only-L --libs-only-other $(ceed.pc))
LDFLAGS += $(patsubst -L%, $(call pkgconf, --variable=ldflag_rpath $(PETSc.pc))%, $(call pkgconf, --libs-only-L $(ceed.pc)))
LDLIBS = $(call pkgconf, --libs-only-l $(ceed.pc)) $(call pkgconf, --libs --static $(PETSc.pc)) -lm

bp.c := $(sort $(wildcard bp*.c))
bp := $(addprefix $(BLD),$(bp.c:%.c=%))

all: $(bp)
$(bp): | $(PETSc.pc) $(ceed.pc)

# Rules for building the examples
$(BLD)%: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $(abspath $<) -o $@ \
	  $(LDLIBS)

print: $(PETSc.pc) $(ceed.pc)
	$(info CC      : $(CC))
	$(info CFLAGS  : $(CFLAGS))
	$(info CPPFLAGS: $(CPPFLAGS))
	$(info LDFLAGS : $(LDFLAGS))
	$(info LDLIBS  : $(LDLIBS))
	@true

clean:
	$(RM) $(bp)

$(PETSc.pc):
	$(if $(wildcard $@),,$(error \
	  PETSc config not found. Please set PETSC_DIR and PETSC_ARCH))

.PHONY: all print clean

pkgconf = $(shell pkg-config $1 | sed -e 's/^"//g' -e 's/"$$//g')
