ARCHS = arm64e
TARGET = iphone:clang:16.5:16.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SystemCorner
SystemCorner_FILES = Tweak.xm
SystemCorner_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = SystemCorner1pxPrefs
SystemCornerPrefs_FILES = SystemCorner1pxPrefs/RootListController.m
SystemCornerPrefs_INSTALL_PATH = /Library/PreferenceBundles
SystemCornerPrefs_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/bundle.mk
