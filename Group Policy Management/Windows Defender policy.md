# 🛡️ Windows Defender Policies

This section describes the **Windows Defender Policies** implemented via Group Policy Management Editor to secure client machines and enforce antivirus protections.

---

## ⚙️ Policy Settings

Configured under:<br />
📂 `Computer Configuration > Policies > Administrative Templates > Windows Components > Microsoft Defender Antivirus`

| Setting                                                 | Value                |
|---------------------------------------------------------|----------------------|
| **Turn off Microsoft Defender Antivirus**               | Disabled             |
| **Turn off real-time protection**                       | Disabled             |
| **Join Microsoft MAPS**                                 | Enabled              |
| **Scan Removable Drives**                               | Enabled              |
| **Send file samples when further analysis is required** | Enabled              |

These settings ensure that Windows Defender is active, real-time protection is enabled, and cloud-based protections are being used.

---

## 🛡️ Why These Settings?

- **Microsoft Defender Antivirus Protection:**
Keeps your system safe from malware, viruses, and other threats by actively monitoring your device.

- **Real-Time Protection:**
Automatically scans files and processes as they run on your computer, catching threats before they can cause damage.

- **Microsoft MAPS (Cloud-Based Security):**
Uses Microsoft's cloud intelligence to detect and block new and emerging threats more effectively.

- **Send Suspicious Files for Analysis:**
Lets Windows Defender automatically send suspicious files for deeper investigation, helping improve security for everyone.

- **Scan Removable Drives Automatically:**
Checks USB drives, external hard drives, and other removable storage for malware as soon as they're connected—stopping infected files from spreading through shared devices.

<img width="1920" height="1030" alt="MS defend policy" src="https://github.com/user-attachments/assets/0a0060f5-ae2b-4547-8b61-bf4a04eaca02" />
