# Third-party components

This community project is not affiliated with HP or Apple. It supplies installation scripts and PPD adaptations, not a newly implemented print or scan protocol.

HP binaries, the original HP PPD, and Apple's original installer are not redistributed in this repository or release DMG. Installation downloads the original package from Apple's HTTPS server, checks a pinned SHA-256, and extracts the required components locally. The checksum checks that bytes match the inspected download; it does not replace code-signature validation or establish redistribution rights.

Source: https://support.apple.com/en-us/106385

The original package and components remain subject to their applicable license terms. The current macOS reports the old package signature as invalid. This tool does not change Gatekeeper, remove quarantine attributes, or re-sign HP components. Security prompts may require further diagnosis on another Mac.

The original components are unsupported on modern macOS. Intel components require Rosetta on Apple Silicon. Future macOS updates may remove compatibility with these components or legacy CUPS drivers.
