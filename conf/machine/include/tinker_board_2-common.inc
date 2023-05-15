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

	chown -R root:root ${IMAGE_ROOTFS}/etc/sudoers
	chmod -R 440 ${IMAGE_ROOTFS}/etc/sudoers
	chown -R root:root ${IMAGE_ROOTFS}/etc/init.d/triggerhappy
	chmod -R 755 ${IMAGE_ROOTFS}/etc/init.d/triggerhappy
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
	fi
}
