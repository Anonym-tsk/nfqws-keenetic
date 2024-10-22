SHELL := /bin/bash
VERSION := $(shell cat VERSION)
ROOT_DIR := /opt

include repository.mk
include packages.mk
include web.mk

.DEFAULT_GOAL := packages

clean:
	rm -rf out/_pages
	rm -rf out/mipsel
	rm -rf out/mips
	rm -rf out/aarch64
	rm -rf out/all
	rm -rf out/openwrt
	rm -rf out/web
