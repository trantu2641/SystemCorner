# SystemCorner1px

Tweak Theos riêng cho iOS 16.

## Chức năng

- Chỉ chỉnh các layer UI hệ thống đã có `cornerRadius`.
- Đặt `cornerRadius` thành `1.0`.
- Không crop màn hình.
- Không dịch UI.
- Không sửa status bar/home bar.
- Không thay frame, bounds, transform hoặc position.
- Không áp dụng cho ứng dụng thông thường.

## Build

```sh
export THEOS=/home/runner/theos
make clean
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=roothide
```

Target mặc định:

```text
iphone:clang:16.5:16.0
```
