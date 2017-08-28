include device/softwinner/dolphin-common/dolphin-common.mk
include vendor/fvd/fvd.mk

#verimatrix
BOARD_USE_VERIMATRIX := 1
ifeq ($(BOARD_USE_VERIMATRIX), 1)
PRODUCT_PACKAGES += \
    libvmclient \
    libvmlogger \
    vmclientSw \
    readvendor
endif

DEVICE_PACKAGE_OVERLAYS := \
    device/softwinner/dolphin-cantv-h2/overlay \
    $(DEVICE_PACKAGE_OVERLAYS)

# for recovery
PRODUCT_COPY_FILES += \
	device/softwinner/dolphin-cantv-h2/recovery.fstab:recovery.fstab

PRODUCT_COPY_FILES += \
    device/softwinner/dolphin-cantv-h2/kernel:kernel \
    device/softwinner/dolphin-cantv-h2/fstab.sun8i:root/fstab.sun8i \
    device/softwinner/dolphin-cantv-h2/init.rc:root/init.rc \
    device/softwinner/dolphin-cantv-h2/verity/rsa_key/verity_key:root/verity_key \
    device/softwinner/dolphin-cantv-h2/init.recovery.sun8i.rc:root/init.recovery.sun8i.rc \
    device/softwinner/dolphin-cantv-h2/ueventd.sun8i.rc:root/ueventd.sun8i.rc \
    device/softwinner/dolphin-cantv-h2/modules/modules/fivm.ko:root/fivm.ko\
    device/softwinner/dolphin-cantv-h2/modules/modules/nand.ko:root/nand.ko

PRODUCT_COPY_FILES += \
    device/softwinner/dolphin-cantv-h2/configs/tablet_core_hardware.xml:system/etc/permissions/tablet_core_hardware.xml

PRODUCT_COPY_FILES += \
    device/softwinner/dolphin-cantv-h2/configs/camera.cfg:system/etc/camera.cfg \
    device/softwinner/dolphin-cantv-h2/configs/cameralist.cfg:system/etc/cameralist.cfg \
    device/softwinner/dolphin-cantv-h2/configs/sunxi-keyboard.kl:system/usr/keylayout/sunxi-keyboard.kl \
    device/softwinner/dolphin-cantv-h2/configs/media_profiles.xml:system/etc/media_profiles.xml \
    device/softwinner/dolphin-cantv-h2/configs/customer_ir_4cb3.kl:system/usr/keylayout/customer_ir_4cb3.kl \
    device/softwinner/dolphin-cantv-h2/configs/customer_ir_8865.kl:system/usr/keylayout/customer_ir_8865.kl \
    device/softwinner/dolphin-cantv-h2/configs/customer_ir_ff40.kl:system/usr/keylayout/customer_ir_ff40.kl \
    device/softwinner/dolphin-cantv-h2/configs/customer_ir_fe01.kl:system/usr/keylayout/customer_ir_fe01.kl \
    device/softwinner/dolphin-cantv-h2/configs/customer_ir_7f80.kl:system/usr/keylayout/customer_ir_7f80.kl \
	device/softwinner/dolphin-cantv-h2/configs/customer_ir_df00.kl:system/usr/keylayout/customer_ir_df00.kl

src_files := $(shell cd device/softwinner/dolphin-cantv-h2/configs ; ls *.kl)
PRODUCT_COPY_FILES += $(foreach file, $(src_files), device/softwinner/dolphin-cantv-h2/configs/$(file):system/usr/keylayout/$(file))

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml

PRODUCT_COPY_FILES += \
    device/softwinner/dolphin-cantv-h2/initlogo.rle:root/initlogo.rle \
    device/softwinner/dolphin-cantv-h2/needfix.rle:root/needfix.rle \
    device/softwinner/dolphin-cantv-h2/media/bootanimation.zip:system/media/bootanimation.zip \
    device/softwinner/dolphin-cantv-h2/media/boot.mp4:system/media/boot.mp4 \
	device/softwinner/dolphin-cantv-h2/external_product.txt:system/etc/external_product.txt

# wifi & bt config file
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml 
	# H2 don`t have bluetooth
    #frameworks/native/data/etc/android.hardware.bluetooth.xml:system/etc/permissions/android.hardware.bluetooth.xml \
    #frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/etc/permissions/android.hardware.bluetooth_le.xml

# build Bluetooth.apk
#PRODUCT_PACKAGES += \
	Bluetooth

#PRODUCT_PACKAGES += \
    USBBT
PRODUCT_PACKAGES += \
    libusb


PRODUCT_COPY_FILES += \
	device/softwinner/dolphin-cantv-h2/H3-DYOS-lib/libcodec_audio.so:system/lib/libcodec_audio.so \
	device/softwinner/dolphin-cantv-h2/H3-DYOS-lib/libmixer.so:system/lib/libmixer.so \
	device/softwinner/dolphin-cantv-h2/H3-DYOS-lib/libpreprocessing.so:system/lib/libpreprocessing.so \
	device/softwinner/dolphin-cantv-h2/H3-DYOS-lib/libresampler.so:system/lib/libresampler.so \
	device/softwinner/dolphin-cantv-h2/H3-DYOS-lib/libril_audio.so:system/lib/libril_audio.so \
	device/softwinner/dolphin-cantv-h2/H3-DYOS-lib/hw/audio.primary.dolphin.so:system/lib/hw/audio.primary.dolphin.so

# ########## DISPLAY CONFIGS BEGIN #############

PRODUCT_PROPERTY_OVERRIDES += \
	persist.sys.disp_density=160 \
	ro.hwc.sysrsl=5 \
	persist.sys.disp_policy=2 \
	persist.sys.hdmi_hpd=1 \
	persist.sys.hdmi_rvthpd=0 \
	persist.sys.cvbs_hpd=0 \
	persist.sys.cvbs_rvthpd=0 \
	persist.sys.hdmi_4k_ban=0

#DISPLAY_INIT_POLICY is used in init_disp.c to choose display policy.
DISPLAY_INIT_POLICY := 2
HDMI_CHANNEL := 0
HDMI_DEFAULT_MODE := 4
CVBS_CHANNEL := 1
CVBS_DEFAULT_MODE := 11
#SHOW_INITLOGO := true

# ########## DISPLAY CONFIGS END ##############


# dalvik vm parameters set in the init/property_service.c
PRODUCT_PROPERTY_OVERRIDES += \
    ro.zygote.disable_gl_preload=true

# drm
PRODUCT_PROPERTY_OVERRIDES += \
    drm.service.enabled=false

# usb
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.usb.config=mtp,adb \
    ro.udisk.lable=dolphin \
    ro.adb.secure=0

# ui
PRODUCT_PROPERTY_OVERRIDES += \
    ro.property.tabletUI=false \
    ro.property.fontScale=1.0 \
    ro.sf.hwrotation=0 \
    debug.hwui.render_dirty_regions=false \
    ro.property.max_video_height=2160

#for evb hdmi density setting
PRODUCT_PROPERTY_OVERRIDES += \
    persist.evb_flag=1

PRODUCT_PROPERTY_OVERRIDES += \
	ro.hwui.texture_cache_size=170 \
	ro.hwui.layer_cache_size=135 \
	ro.hwui.path_cache_size=34 \
	ro.hwui.shap_cache_size=9 \
	ro.hwui.drop_shadow_cache_size=17 \
	ro.hwui.r_buffer_cache_size=17

#version and ota update
PRODUCT_PROPERTY_OVERRIDES += \
    ro.product.rom.type=YB \
    ro.product.rom.name=BoxRom

PRODUCT_PROPERTY_OVERRIDES += \
        ro.carrier=wifi-only

PRODUCT_PROPERTY_OVERRIDES += \
    media.boost.pref=modec100:160

# default language setting
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.timezone=Asia/Shanghai \
    persist.sys.country=CN \
    persist.sys.language=zh

#PRODUCT_PACKAGES += \
	usb_detect

$(call inherit-product-if-exists, device/softwinner/dolphin-cantv-h2/modules/modules.mk)
$(call inherit-product, cantv/build/cantv.mk)

# Overrides
PRODUCT_CHARACTERISTICS := homlet
PRODUCT_BRAND := Allwinner
PRODUCT_NAME := dolphin_cantv_h2
PRODUCT_DEVICE := dolphin-cantv-h2
PRODUCT_MODEL := H2
PRODUCT_MANUFACTURER := 讯玛

#pack parameter
PACK_BOARD := dolphin-p2

