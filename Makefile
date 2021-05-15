SHELL := /bin/bash
CYC_DIR = "../cyclone-bootstrap"

#	source ~/Documents/emsdk/emsdk_env.sh
all:
	emcc src/terminal.c -O2 -fPIC -Wall -Wno-shift-negative-value -Wno-unused-command-line-argument -I$(CYC_DIR)/include -c -o terminal.o
	emcc terminal.o \
	  $(CYC_DIR)/scheme/base.o \
	  $(CYC_DIR)/scheme/write.o \
	  $(CYC_DIR)/scheme/cyclone/common.o \
	  $(CYC_DIR)/scheme/file.o \
	  $(CYC_DIR)/scheme/char.o \
	  $(CYC_DIR)/srfi/18.o \
	  $(CYC_DIR)/srfi/69.o \
	  $(CYC_DIR)/scheme/cyclone/hashset.o \
	  $(CYC_DIR)/scheme/cyclone/primitives.o \
	  $(CYC_DIR)/scheme/process-context.o \
	  $(CYC_DIR)/scheme/read.o \
	  $(CYC_DIR)/scheme/cyclone/util.o \
	  $(CYC_DIR)/scheme/cyclone/libraries.o \
	  $(CYC_DIR)/scheme/eval.o \
	  $(CYC_DIR)/scheme/repl.o \
	 -O2 -pthread -lcyclone -lm -lcyclonebn -ldl -L$(CYC_DIR)  -o terminal.html \
	 -s USE_PTHREADS=1 -s WASM=1 -s INITIAL_MEMORY=33554432 -s PROXY_TO_PTHREAD --source-map-base https://cyclone-scheme.netlify.app/ \
	 -s ASSERTIONS=2 -s SAFE_HEAP=1 -s STACK_OVERFLOW_CHECK=1 \
	 -s "EXTRA_EXPORTED_RUNTIME_METHODS=['ccall', 'cwrap']"
	cp terminal.wasm _site
	cp terminal.js _site
	cp terminal.worker.js _site

.PHONY: clean dist

# Deploy locally
dist:
	cp _site/* /var/www/html/terminal/

clean: 
	git clean -fdx
