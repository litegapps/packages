# package-restore running in /system/addon.d/

#system dir
if [ -f /system/system/build.prop ]; then
dirsystem=/system/system
elif [ -f /system_root/system/build.prop ]; then
diesystem=/system_root/system
elif [ -f /system_root/build.prop ]; then
dirsystem=/system_root
else
dirsystem=/system
fi

set_prop() {
  property="$1"
  value="$2"
  file_location="$3"
  if grep -q "${property}" "${file_location}"; then
    sed -i "s/\(${property}\)=.*/\1=${value}/g" "${file_location}"
  else
    echo "${property}=${value}" >>"${file_location}"
  fi
}


set_prop "setupwizard.feature.baseline_setupwizard_enabled" "true" "$dirsystem/product/build.prop"
set_prop "ro.setupwizard.enterprise_mode" "1" "$dirsystem/product/build.prop"
set_prop "ro.setupwizard.rotation_locked" "true" "$dirsystem/product/build.prop"
set_prop "setupwizard.enable_assist_gesture_training" "true" "$dirsystem/product/build.prop"
set_prop "setupwizard.theme" "glif_v3_light" "$dirsystem/product/build.prop"
set_prop "setupwizard.feature.skip_button_use_mobile_data.carrier1839" "true" "$dirsystem/product/build.prop"
set_prop "setupwizard.feature.show_pai_screen_in_main_flow.carrier1839" "false" "$dirsystem/product/build.prop"
set_prop "setupwizard.feature.show_pixel_tos" "false" "$dirsystem/product/build.prop"
set_prop "ro.setupwizard.network_required" "false" "$dirsystem/product/build.prop"
