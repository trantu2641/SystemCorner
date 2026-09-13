ARCHS = arm64e
TARGET = iphone:clang:16.5:16.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SystemCorner
SystemCorner1px_FILES = Tweak.xm
SystemCorner1px_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = SystemCorner1pxPrefs
SystemCorner1pxPrefs_FILES = SystemCorner1pxPrefs/RootListController.m
SystemCorner1pxPrefs_INSTALL_PATH = /Library/PreferenceBundles
SystemCorner1pxPrefs_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/bundle.mk
