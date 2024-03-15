include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = $(TWEAK_NAME)Prefs

$(BUNDLE_NAME)_FRAMEWORKS = SwiftUI
$(BUNDLE_NAME)_FILES = $(shell find Sources/$(BUNDLE_NAME) -name '*.swift') $(shell find Sources/$(BUNDLE_NAME)C -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
$(BUNDLE_NAME)_SWIFTFLAGS = -ISources/$(BUNDLE_NAME)C/include
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
