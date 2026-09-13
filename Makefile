TARGET := iphone:clang:16.5:16.0

ARCHS := arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := SystemCorner

SystemCorner_FILES := Tweak.xm
SystemCorner_CFLAGS := -fobjc-arc

SystemCorner_FRAMEWORKS := UIKit

SystemCorner_PRIVATE_FRAMEWORKS := Preferences

SystemCorner_EXTRA_FRAMEWORKS :=

SystemCorner_PACKAGE_SCHEME := roothide

BUNDLE_NAME := SystemCornerPrefs

SystemCornerPrefs_INSTALL_PATH := /Library/PreferenceBundles

SystemCornerPrefs_FILES := Resources/RootListController.m

SystemCornerPrefs_FRAMEWORKS := UIKit

SystemCornerPrefs_PRIVATE_FRAMEWORKS := Preferences

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/bundle.mk
