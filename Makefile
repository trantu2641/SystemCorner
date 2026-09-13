export THEOS ?= /home/runner/theos

TARGET := iphone:clang:16.5:16.0
ARCHS := arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := SystemCorner

SystemCorner_FILES := Tweak.xm
SystemCorner_FRAMEWORKS := UIKit
SystemCorner_CFLAGS := -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk


BUNDLE_NAME := SystemCornerPrefs

SystemCornerPrefs_FILES := Resources/RootListController.m
SystemCornerPrefs_INSTALL_PATH := /Library/PreferenceBundles
SystemCornerPrefs_FRAMEWORKS := UIKit
SystemCornerPrefs_PRIVATE_FRAMEWORKS := Preferences
SystemCornerPrefs_CFLAGS := -fobjc-arc
SystemCornerPrefs_BUNDLE_RESOURCES := Resources/Root.plist

include $(THEOS_MAKE_PATH)/bundle.mk


after-stage::
	$(ECHO_NOTHING)mkdir -p "$(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences"$(ECHO_END)
	$(ECHO_NOTHING)cp "Resources/SystemCornerPrefs.plist" "$(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SystemCornerPrefs.plist"$(ECHO_END)


after-install::
	install.exec "killall -9 SpringBoard 2>/dev/null || true"
