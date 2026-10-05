# HP M1136 macOS 兼容工具

**让 HP LaserJet M1136 MFP 在较新的 macOS 上通过 USB 打印和扫描。**

[English](README.md) · 简体中文

[下载 DMG](https://github.com/HuangChenning/hp-m1136-macos/releases/tag/v0.1.0) · [发布说明（英文）](RELEASE_NOTES.md) · [反馈问题](https://github.com/HuangChenning/hp-m1136-macos/issues)

## 项目概述

这是一个社区兼容安装工具，复用 Apple 分发的原版 HP 打印和扫描组件，并非 HP 官方版本。已发布的 DMG 仍使用 Intel 组件；仓库另有[实验性原生 ARM 打印方案](native/README.md)，已在这台 Mac 上通过一次 CUPS 队列实机打印。原生扫描尚未实现。

> **实验性版本：** DMG 尚未签名和公证。独立组件已在测试机器上正常使用；统一安装入口尚未在干净的 Mac 上完成端到端验证。

## 实机验证效果

打印机所有者已在 **一台 Apple Silicon Mac、macOS 26.6.1** 上通过 USB 验证：

| 功能 | 实际结果 |
| --- | --- |
| 打印 | 测试页正常出纸，中英文内容正常 |
| 进纸 | 纸盒内已有纸张时，自动进纸正常 |
| 扫描 | 系统“图像捕捉”成功扫描并保存文件 |

其他 Mac 和 macOS 版本尚未验证。打印任务离开队列，不等于纸张已经正确打印。

## 工作原理

安装工具从 Apple 官方下载原版 HP 5.1.1 驱动包（约 **558 MiB**），验证固定的 SHA-256，再在本机提取 M1136 所需组件。下载前会检查是否恰好连接一台 M1136，下载后再次确认其 USB 地址，然后安装：

- 独立的 **HP M1136 (Compatibility)** 打印队列，默认 **A4、自动进纸**，不改变已有默认打印机。
- M1130/M1210 ICA 扫描组件，由系统 **“图像捕捉”** 调用。

发布的 DMG 包含我们编写的脚本、文档与测试页。仓库另含注明来源和 GPL 许可的实验性原生编码器源码。**不包含 HP 二进制文件**。已发布的 Intel 组件在 **Apple Silicon 上需要 Rosetta**。

## 安装与首次使用

### 安装前准备

通过 USB 连接一台已开机的 M1136；Apple Silicon 用户先安装 Rosetta，并准备管理员密码。下载 Apple 驱动包需要联网。工具不会覆盖已有组件。

### 从 DMG 安装

1. 下载并打开 [发布版 DMG](https://github.com/HuangChenning/hp-m1136-macos/releases/tag/v0.1.0)。
2. 双击 `Install.command`。它会打开终端，并非图形安装向导。
3. 等待下载与校验完成，按提示输入管理员密码。
4. 安装后拔插 USB；如果扫描仪未出现，重启 Mac。

如果 macOS 阻止打开下载文件，或安装时出现错误，请记录完整提示并 [反馈问题](https://github.com/HuangChenning/hp-m1136-macos/issues)。浏览器下载后的 Gatekeeper 行为尚未验证；脚本不修改系统安全设置。

### 打印测试页

在应用的打印窗口选择 **HP M1136 (Compatibility)**，或进入仓库、已挂载 DMG 的目录后运行：

```sh
lp -d HP_M1136_Compat -o PageSize=A4 -o InputSlot=Auto test-page.pdf
lpstat -p HP_M1136_Compat
```

检查实际纸张，确认中英文清晰可读。日常打印继续选择同一队列。

### 扫描文档

打开 **“图像捕捉”**，选择 M1136，将文档正面朝下放在扫描玻璃上。先进行预览，再尝试 **150 dpi、灰度扫描**并保存 PDF。打开文件，检查内容是否完整。

## 常见问题

| 现象 | 处理方法 |
| --- | --- |
| 纸盒有纸，却提示 `Manual Feed` | 早期版本用户可在仓库或 DMG 目录运行 `sudo bash ./install.sh fix-feed`。取消受影响任务后重新提交；任务会保留提交时的纸源设置。 |
| “图像捕捉”没有扫描仪 | 拔插 USB，退出并重开“图像捕捉”；仍未出现时重启 Mac。 |
| 检测到已有组件 | 先使用本工具卸载。不覆盖其他驱动。 |
| 安全提示或扫描错误 | 提交完整提示、Mac 架构、macOS 版本和安装方式。 |

## 卸载

双击 DMG 中的 `Uninstall.command`。也可在仓库目录运行：

```sh
sudo bash ./install-scanner.sh uninstall
sudo bash ./install.sh uninstall
```

只删除带有本工具所有权标记的组件及打印队列。打印和扫描组件也可以分别卸载。

## 从源码构建

```sh
git clone https://github.com/HuangChenning/hp-m1136-macos.git
cd hp-m1136-macos
bash build-dmg.sh
```

构建后在 `dist/` 生成 DMG 和 SHA-256 文件。构建 DMG 不会安装驱动。

<details>
<summary>高级用法：手动安装原版组件</summary>

从 [Apple 官方页面](https://support.apple.com/en-us/106385) 下载 HP 5.1.1。以下解包和挂载目标目录必须不存在；请按实际情况调整下载路径：

```sh
hdiutil attach ~/Downloads/HewlettPackardPrinterDrivers.dmg -readonly -nobrowse -mountpoint /tmp/hp-driver-volume
pkgutil --expand-full /tmp/hp-driver-volume/HewlettPackardPrinterDrivers.pkg /tmp/hp-expanded
lpinfo -v
```

将 `USB_URI` 替换为 `lpinfo -v` 输出中 M1136 的完整 `usb://` 地址，再在仓库目录运行：

```sh
sudo bash ./install.sh install '/tmp/hp-expanded/HewlettPackardPrinterDrivers.pkg/Payload' 'USB_URI'
sudo bash ./install-scanner.sh install '/tmp/hp-expanded/HewlettPackardPrinterDrivers.pkg/Payload'
```

打印组件安装至 `/Library/Printers/hp-m1136-compat`，扫描组件安装至 `/Library/Image Capture/Devices/HP M1130_M1210 Scanner.app`。不安装其他型号驱动或旧版 HP 工具。

</details>

## 兼容限制与第三方条款

Apple 不支持在较新的 macOS 上使用这个旧包，测试系统也报告其旧签名无效。下载校验值一致不能代替签名验证。本工具不移除隔离属性、不重新签名 HP 组件，也不运行原版安装器。

HP 组件仍受其适用条款约束，来源与限制见 [THIRD_PARTY.md（英文）](THIRD_PARTY.md)。未来 macOS 更新可能影响旧组件或 CUPS 驱动的兼容性。
