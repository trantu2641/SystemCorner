include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SystemCorner

SystemCorner_FILES = Tweak.xm
SystemCorner_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
