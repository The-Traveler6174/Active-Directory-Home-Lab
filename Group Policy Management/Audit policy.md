# 🔍 Audit Policy

This document explains the Audit Policy that’s applied to the domain through Group Policy Management Editor. Audit policies help you track key security events in Active Directory such as sign-in activity, use of privileged accounts, and changes to important objects so you can improve security and respond faster when incidents happen.

---

## ⚙️ Policy Settings

Path to settings:<br />  
📂 `Computer Configuration > Policies > Windows Settings > Security Settings > Advanced Audit Policy Configuration > Audit Policies`

| Category               | Setting                          | Audit Type        |
|------------------------|----------------------------------|-------------------|
| **Account Logon**      | Credential Validation            | Success/Failure   |
| **Account Management** | User Account Management          | Success/Failure   |
| **Detailed Tracking**  | Process Creation                 | Success           |
| **Logon/Logoff**       | Logon Events                     | Success/Failure   |
| **Object Access**      | File System Access               | Success/Failure   |
| **Policy Change**      | Audit Policy Changes             | Success/Failure   |
| **Privilege Use**      | Sensitive Privilege Use          | Success/Failure   |
| **System**             | Security System Extension        | Success/Failure   |

---

## 🛡️ Purpose and Justification

Audit policies provide visibility into actions that may indicate unauthorized behavior. These logs are essential for:

- **Compliance:**
with standards like ISO 27001, NIST 800-53, and CIS Controls.

- **Forensics:**
in the event of an incident or breach.

- **Alerting:**
through SIEM tools or manual log reviews.

<img width="1920" height="1030" alt="audit policy" src="https://github.com/user-attachments/assets/212d9a77-a4a1-43d7-9ec0-6dbd3ec65c23" />
