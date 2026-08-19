# res_w=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
# res_h=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
# h_scale=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .scale' | sed 's/\.//')
# echo "res_h=$res_h  h_scale=$h_scale  margin=$((res_h * 27 / h_scale))"
# w_margin=$((res_h * 27 / h_scale))
wlogout -b 5 -T 400 -B 400
