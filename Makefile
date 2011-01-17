.PHONY:	config all
all:	tests
## Load Previous Configuration ####################################################################

-include config.mk

## Configurable options ###########################################################################

# Directory to store object files, libraries, executables, and dependencies:
BUILD_DIR  ?= build

# Dependencies
MINISAT_INCLUDE?=
MINISAT_LIB    ?=-lminisat
MCBIND_INCLUDE ?=
MCBIND_LIB     ?=-lminisat-c

# GNU Standard Install Prefix
prefix         ?= /usr/local

## Write Configuration  ###########################################################################

config:
	@( echo 'BUILD_DIR?=$(BUILD_DIR)'            ; \
	   echo 'MINISAT_INCLUDE?=$(MINISAT_INCLUDE)'; \
	   echo 'MINISAT_LIB?=$(MINISAT_LIB)'	     ; \
	   echo 'MCBIND_INCLUDE?=$(MCBIN_INCLUDE)'   ; \
	   echo 'MCBIN_LIB?=$(MCBIND_LIB)'	     ; \
	   echo 'prefix?=$(prefix)'                  ) > config.mk

## Configurable options end #######################################################################

GHC?=ghc

# Note: as long as we are using dynamic linking with the external libraries, stdc++ will be pulled
# in automaticall. If linking is static, we will have to specify it explicitly.
GHC_COMPILEFLAGS=
GHC_LINKFLAGS=-package QuickCheck $(MCBIND_LIB) $(MINISAT_LIB) -lz #-lstdc++

ifeq ($(VERB),)
ECHO=@
VERB=@
else
ECHO=#
VERB=
endif

SRCS = $(wildcard *.hs)
OBJS = $(SRCS:.hs=.o)

tests:	$(BUILD_DIR)/release/bin/test-minisatraw

## Build-type Compile-flags:
$(BUILD_DIR)/release/%.o:			GHC_COMPILEFLAGS+=-O2
$(BUILD_DIR)/debug/%.o:				MBINDC_CXXFLAGS +=$(MBINDC_DEB) -g

## Test link rules:
$(BUILD_DIR)/release/bin/test-minisatraw:	$(BUILD_DIR)/release/MiniSatRaw.o
	$(VERB) echo Linking: $@
	$(ECHO) mkdir -p $(dir $@)
	$(ECHO) $(GHC) -o $@ $< $(GHC_LINKFLAGS) #-lstdc++

## Compile rules:
$(BUILD_DIR)/release/%.o:	%.hs
	$(VERB) echo Compiling: $@
	$(ECHO) mkdir -p $(dir $@)
	$(ECHO) $(GHC) $(GHC_COMPILEFLAGS) -c -o $@ $< -hidir $(dir $@)

ghci:	
	ghci Sat.hs $(GHC_COMPILEFLAGS) $(GHC_LINKFLAGS)

ghci2:
	ghci SatImplicit.hs $(GHC_LINKFLAGS)
