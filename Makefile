ARCHS = arm64e

include $(THEOS)/makefile/common.mk

TWEAK_NAME = MyFirstTweak

MyFirstTweak_FILES = Tweak.x
MyFirstTweak_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
