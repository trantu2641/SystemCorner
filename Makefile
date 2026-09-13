TARGET := iphone:clang:16.5:16.0
ARCHS := arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := SystemCorner

SystemCorner_FILES := Tweak.xm
SystemCorner_FRAMEWORKS := UIKit
SystemCorner_CFLAGS := -fobjc-arc

BUNDLE_NAME := SystemCorner1pxPrefs

SystemCorner1pxPrefs_FILES := Resources/RootListController.m
SystemCorner1pxPrefs_INSTALL_PATH := /Library/PreferenceBundles
SystemCorner1pxPrefs_FRAMEWORKS := UIKit
SystemCorner1pxPrefs_PRIVATE_FRAMEWORKS := Preferences
SystemCorner1pxPrefs_CFLAGS := -fobjc-arc
SystemCorner1pxPrefs_RESOURCE_DIRS := Resources

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 Preferences"
