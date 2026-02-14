TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = Netflix

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = GhostNetflix

GhostNetflix_FILES = Tweak.xm
GhostNetflix_CFLAGS = -fobjc-arc
GhostNetflix_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
