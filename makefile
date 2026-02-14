ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

THEOS_PACKAGE_SCHEME = rootless
INSTALL_TARGET_PROCESSES = *

TWEAK_NAME = NetflixCookieInj
DilSihirbazi_FILES = Tweak.x
DilSihirbazi_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
