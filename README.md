# HP M1136 macOS Compatibility Installer

复用 Apple 官方 HP 5.1.1 驱动包中的 M1130/M1136 组件，绕开旧安装器的系统版本限制。不是重新实现的原生 ARM 驱动；Intel 64 位组件在 Apple Silicon 上需要 Rosetta。打印与扫描已在一台 Apple Silicon Mac、macOS 26.6.1 上实机验证成功。其他机器和系统版本尚未验证。

## DMG 安装（测试版）

从 [GitHub Releases](https://github.com/HuangChenning/hp-m1136-macos/releases) 下载 DMG，打开后双击 `Install.command`。终端会从 Apple 官方下载约 558 MiB 驱动包并验证固定校验值，再自动识别 USB 打印机、请求管理员密码、安装打印和扫描组件。Apple Silicon 需要先安装 Rosetta。

双击 `Uninstall.command` 卸载。已安装组件时，工具会拒绝覆盖；请先卸载本工具拥有的组件。DMG 未签名、未公证，浏览器下载后的 Gatekeeper 行为尚未验证。合并安装流程仍需在干净的 Mac 上验证；详细限制见 `THIRD_PARTY.md`。

## 本地构建

执行 `bash build-dmg.sh`，在 `dist/` 生成 DMG 和 SHA-256 文件。发布包只含本项目脚本、说明与测试页，不包含 HP 二进制组件。

## 手动安装：准备

从 [Apple 官方页面](https://support.apple.com/en-us/106385) 下载 HP 5.1.1 驱动镜像。该包不受官方支持用于新 macOS，且当前系统报告旧包签名无效。本工具不更改系统安全设置，不运行原安装器，不重新分发 HP 二进制文件。

只读挂载镜像并解包（目标目录必须不存在）：

```sh
hdiutil attach ~/Downloads/HewlettPackardPrinterDrivers.dmg -readonly -nobrowse -mountpoint /tmp/hp-driver-volume
pkgutil --expand-full /tmp/hp-driver-volume/HewlettPackardPrinterDrivers.pkg /tmp/hp-expanded
```

解包后的 payload 通常是 `/tmp/hp-expanded/HewlettPackardPrinterDrivers.pkg/Payload`。

## 安装与验证

连接并打开打印机，用 `lpinfo -v` 获取包含 M1136 的完整 `usb://` 地址，然后执行：

```sh
sudo bash ./install.sh install '/tmp/hp-expanded/HewlettPackardPrinterDrivers.pkg/Payload' 'usb://地址'
lp -d HP_M1136_Compat your-document.pdf
lpstat -p HP_M1136_Compat
```

在应用的打印窗口中选择 **HP M1136 (Compatibility)**。默认 A4，默认打印机不变。请确认实际出纸、中文内容和多页顺序；任务离开队列不等于打印结果已验证。

默认使用自动进纸。旧版工具继承了 HP PPD 的手动进纸默认值，会触发 `Manual Feed` 提示。已安装旧版本时，可执行 `sudo bash ./install.sh fix-feed` 更新队列；原有任务须取消并重新提交，因为任务保留提交时的纸源设置。

仓库中的 `test-page.pdf` 可用于一页中英文打印检查。已验证：脚本语法、调整后的 PPD、系统文本转 PDF 和光栅流程；HP 过滤器从标准输入生成了非空打印数据。随后经实机验证，测试页正常出纸，中英文正常。

只复制 HP 光栅过滤器 bundle 和调整路径后的 PPD 到 `/Library/Printers/hp-m1136-compat`。不安装旧 HP 工具或其他型号的驱动。

## 卸载

```sh
sudo bash ./install.sh uninstall
```

仅删除本工具的打印队列和有所有权标记的独立目录。安装失败后也可执行此命令清理。

## 扫描适配

独立安装同一 Apple 官方包内的 `HP M1130_M1210 Scanner.app`，不安装其他型号扫描驱动，不更改打印配置。其设备匹配表包含 M1136（USB VID `03f0`、PID `042a`），组件已在这台 Mac 上通过“图像捕捉”完成扫描和保存文件。

```sh
sudo bash ./install-scanner.sh install '/tmp/hp-expanded/HewlettPackardPrinterDrivers.pkg/Payload'
open -a 'Image Capture'
```

安装后拔插 USB，退出并重开“图像捕捉”。将文档正面朝下放到扫描玻璃上，选择 M1136，先尝试预览，再以 150 dpi、灰度扫描并保存 PDF。验证文件能打开且内容完整。若不显示设备，重启 Mac 后重试；如出现安全提示或扫描错误，记录原文以便继续诊断。脚本不修改 Gatekeeper 或重新签名旧组件。

扫描组件独立卸载：

```sh
sudo bash ./install-scanner.sh uninstall
```
