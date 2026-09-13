export THEOS ?= /home/runner/theos

ARCHS = arm64 arm64e
TARGET = iphone:clang:16.5:16.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SystemCorner

SystemCorner_FILES = Tweak.xm
SystemCorner_CFLAGS = -fobjc-arc
SystemCorner_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk


BUNDLE_NAME = SystemCornerPrefs

SystemCornerPrefs_FILES = Resources/RootListController.m
SystemCornerPrefs_INSTALL_PATH = /Library/PreferenceBundles
SystemCornerPrefs_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/bundle.mk
