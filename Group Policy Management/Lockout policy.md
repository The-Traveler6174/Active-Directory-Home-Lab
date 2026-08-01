# 🚫 Account Lockout Policy

This document outlines the **Account Lockout Policy** configured in Group Policy Management Editor to limit repeated invalid login attempts. This policy adds a critical layer of defense against brute-force attacks and dictionary attacks.

---

## ⚙️ Policy Settings

Configured in:<br />
  📂 `Computer Configuration > Policies > Windows Settings > Security Settings > Account Policies > Account Lockout Policy`

| Setting                                     | Value         |
|---------------------------------------------|---------------|
| **Account lockout duration**                | 30 minutes    |
| **Account lockout threshold**               | 5 attempts    |
| **Allow Administrator account lockout**     | Disabled      |
| **Reset account lockout counter after**     | 10 minutes    |

These settings ensure that accounts are temporarily disabled after five failed login attempts.

---

## 🔐 Why These Settings?

- **Lockout threshold:**
Safeguards accounts from brute-force attacks by temporarily locking them out after too many wrong passwords.

- **Lockout duration:**
Buys your security team critical time to identify threats and take action.

- **Reset counter:**
Lets legitimate users regain access after a quiet period, without sacrificing account protection.
<img width="1920" height="1030" alt="lockout policy" src="https://github.com/user-attachments/assets/390e0c0a-e670-4b73-abef-a803d79d20d3" />
