ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0

THEOS_PACKAGE_SCHEME = rootless
INSTALL_TARGET_PROCESSES = Netflix

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NetflixCookieInj

NetflixCookieInj_FILES = Tweak.x
NetflixCookieInj_CFLAGS = -fobjc-arc
NetflixCookieInj_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
