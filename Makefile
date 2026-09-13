ARCHS = arm64 arm64e
TARGET = iphone:clang:16.5:16.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SystemCorner

SystemCorner_FILES = Tweak.xm
SystemCorner_FRAMEWORKS = UIKit
SystemCorner_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk


BUNDLE_NAME = SystemCornerPrefs

SystemCornerPrefs_FILES = Resources/RootListController.m
SystemCornerPrefs_RESOURCE_FILES = \
	Resources/Root.plist \
	Resources/Info.plist

SystemCornerPrefs_INSTALL_PATH = /Library/PreferenceBundles
SystemCornerPrefs_FRAMEWORKS = UIKit
SystemCornerPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

after-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences
	cp Resources/SystemCornerPrefs.plist \
		$(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SystemCornerPrefs.plist
