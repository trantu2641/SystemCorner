TARGET := iphone:clang:16.5:16.0
ARCHS := arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := SystemCorner

SystemCorner_FILES := Tweak.xm
SystemCorner_CFLAGS := -fobjc-arc

SystemCorner_FRAMEWORKS := UIKit
SystemCorner_PRIVATE_FRAMEWORKS := Preferences

SystemCorner_INSTALL_TARGET_PROCESSES := SpringBoard

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += SystemCornerPrefs

include $(THEOS_MAKE_PATH)/aggregate.mk
