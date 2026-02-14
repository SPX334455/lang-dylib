TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = Netflix

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = GhostNetflix
GO_EASY_ON_ME = 1
export THEOS_PACKAGE_SCHEME = rootless
GhostNetflix_FILES = Tweak.xm
GhostNetflix_CFLAGS = -fobjc-arc
GhostNetflix_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
