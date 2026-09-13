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
SystemCornerPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk


after-all::
	@mkdir -p $(THEOS_PACKAGE_DIR)/Library/PreferenceLoader/Preferences
	@cp Resources/SystemCornerPrefs.plist \
		$(THEOS_PACKAGE_DIR)/Library/PreferenceLoader/Preferences/SystemCornerPrefs.plist
