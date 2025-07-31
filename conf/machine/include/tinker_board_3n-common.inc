ASUS_OVERLAY_DIRS:append = " \
	${TOPDIR}/../../yocto/meta-asus/asus-overlay/overlay \
"

BB_BASEHASH_IGNORE_VARS:append = " ASUS_OVERLAY_DIRS"
ROOTFS_POSTPROCESS_COMMAND:append = " do_asus_post_rootfs;"
do_rootfs[depends] += "rsync-native:do_populate_sysroot"
do_asus_post_rootfs() {
	for overlay in ${ASUS_OVERLAY_DIRS};do
		[ -d "${overlay}" ] || continue
		echo "Installing overlay: ${overlay}..."
		rsync -av --chmod=u=rwX,go=rX "${overlay}/" "${IMAGE_ROOTFS}"
	done

	mv ${IMAGE_ROOTFS}/usr/bin/tinker-config-tb3n ${IMAGE_ROOTFS}/usr/bin/tinker-config
	rm ${IMAGE_ROOTFS}/usr/bin/tinker-config-tb3

	chown -R root:root ${IMAGE_ROOTFS}/etc/sudoers
	chmod -R 440 ${IMAGE_ROOTFS}/etc/sudoers
	chown -R root:root ${IMAGE_ROOTFS}/etc/init.d/triggerhappy
	chmod -R 755 ${IMAGE_ROOTFS}/etc/init.d/triggerhappy
	chown -R root:root ${IMAGE_ROOTFS}/etc/profile.d/ethernet_wol.sh
	chmod -R 755 ${IMAGE_ROOTFS}/etc/profile.d/ethernet_wol.sh
	chown -R root:root ${IMAGE_ROOTFS}/usr/lib/pm-utils/sleep.d/99ethernet_restart
	chmod -R 755 ${IMAGE_ROOTFS}/usr/lib/pm-utils/sleep.d/99ethernet_restart
	chown -R root:root ${IMAGE_ROOTFS}/usr/lib/pm-utils/sleep.d/02pulseaudio-resume
	chmod -R 755 ${IMAGE_ROOTFS}/usr/lib/pm-utils/sleep.d/02pulseaudio-resume
	chown -R root:root ${IMAGE_ROOTFS}/etc/udev/rules.d/60-drm.rules
	chmod -R 755 ${IMAGE_ROOTFS}/etc/udev/rules.d/60-drm.rules
	chown -R root:root ${IMAGE_ROOTFS}/usr/bin/drm-hotplug.sh
	chmod -R 755 ${IMAGE_ROOTFS}/usr/bin/drm-hotplug.sh
	chown -R root:root ${IMAGE_ROOTFS}/etc/pulse/jack_hotplug.sh
	chmod -R 755 ${IMAGE_ROOTFS}/etc/pulse/jack_hotplug.sh
	chown -R root:root ${IMAGE_ROOTFS}/etc/pulse/switch_sound_device.sh
	chmod -R 755 ${IMAGE_ROOTFS}/etc/pulse/switch_sound_device.sh
	chown -R root:root ${IMAGE_ROOTFS}/etc/profile.d/switch_sound_device_boot.sh
	chmod -R 755 ${IMAGE_ROOTFS}/etc/profile.d/switch_sound_device_boot.sh
	chown -R root:root ${IMAGE_ROOTFS}/etc/wireplumber/jack_hotplug.sh
	chmod -R 755 ${IMAGE_ROOTFS}/etc/wireplumber/jack_hotplug.sh
	rm -rf ${IMAGE_ROOTFS}/userdata
	ln -s -r ${IMAGE_ROOTFS}/boot ${IMAGE_ROOTFS}/userdata
	rm -rf ${IMAGE_ROOTFS}/tmp
	ln -s -r ${IMAGE_ROOTFS}/var/tmp ${IMAGE_ROOTFS}/tmp
}

ASUS_OVERLAY_DEBUG_DIRS:append = " \
	${TOPDIR}/../../yocto/meta-asus/asus-overlay/overlay-debug \
"

BB_BASEHASH_IGNORE_VARS:append = " ASUS_OVERLAY_DEBUG_DIRS"
ROOTFS_POSTPROCESS_COMMAND:append = " do_asus_post_rootfs_debug;"
do_asus_post_rootfs_debug() {
	image_type=`echo ${IMAGE_VERSION} | awk -F '_' '{print $NF}'`
	if [ "$image_type" != "release" ]; then
		for overlay in ${ASUS_OVERLAY_DEBUG_DIRS};do
			[ -d "${overlay}" ] || continue
			echo "Installing overlay: ${overlay}..."
			rsync -av --chmod=u=rwX,go=rX "${overlay}/" "${IMAGE_ROOTFS}"
		done

		if [ -e ${IMAGE_ROOTFS}/home/root/Test_tool_${RK_PROJECT_NAME} ]; then
        		mv ${IMAGE_ROOTFS}/home/root/Test_tool_${RK_PROJECT_NAME} ${IMAGE_ROOTFS}/home/root/Test_tool 
		fi

		if [ -z $(find "${IMAGE_ROOTFS}/home/root/" -name "Test_tool_*") ]; then
			echo "No other project Test tool"
		else
                        echo "Remove other project Test tool"
			rm -rf ${IMAGE_ROOTFS}/home/root/Test_tool_*
                fi

	fi
}
