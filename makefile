TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = GoApeShip

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = GoApeShipFix
GO_EASY_ON_ME = 1
export THEOS_PACKAGE_SCHEME = rootless

GoApeShipFix_FILES = Tweak.xm
GoApeShipFix_CFLAGS = -fobjc-arc
GoApeShipFix_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
