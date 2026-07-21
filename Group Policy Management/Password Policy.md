# 🔐 Password Policy (Domain GPO)

This document outlines the **Password Policy** implemented through Group Policy to enforce strong password requirements in the domain.

---

## ⚙️ Policy Settings

The following settings were configured in **Group Policy Management Editor** under:<br />
📂 `Computer Configuration > Policies > Windows Settings > Security Settings > Account Policies > Password Policy`

| Setting                                         | Value                   |
|-------------------------------------------------|-------------------------|
| **Enforce password history**                    | 24 passwords remembered |
| **Maximum password age**                        | 90 days                 |
| **Minimum password age**                        | 30 day                   |
| **Minimum password length**                     | 13 characters           |
| **Password must meet complexity requirements**  | Enabled                 |
| **Store passwords using reversible encryption** | Disabled                |

These settings ensure users cannot reuse old passwords frequently, must use complex and lengthy passwords, and cannot store passwords insecurely.

<img width="1920" height="1030" alt="password policy" src="https://github.com/user-attachments/assets/59991f2d-acbc-4d3b-918f-fb8b327626d4" />

---

## 📌 Purpose and Justification

### 🛡️ Why These Settings?

- **Password history** prevents reuse of recently used passwords.
- **Expiration** ensures users change their passwords.
- **Complexity requirements** force users to use a mix of characters.
- **Minimum length** increases entropy and password strength.
- **Reversible encryption** is disabled to avoid plaintext storage.
