# 👤 User Rights Assignment

This section documents the **User Rights Assignment** configured through Group Policy Management Editor to define and manage the specific rights assigned to users and groups in the domain.

---

## ⚙️ Policy Settings

The following settings were configured under:<br />
📂 `Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies > User Rights Assignment`

| Setting                                                            | Value                           |
|--------------------------------------------------------------------|---------------------------------|
| **Allow Log on locally**                                           | Administrators, Domain Users    |
| **Allow Log on through Remote Desktop Services**                   | Administrators, Domain Users    |
| **Log on as a service**                                            | Local Service, Network Service  |
| **Log on as a batch job**                                          | Administrators, Backup Admins   |
| **Shut down the system**                                           | Administrators                  |

---

### 🛡️ Why These Settings?

- **Log on locally:**
Lets users sign in directly at the machine itself, rather than from a remote location.

- **Log on as a service:**
Enables specific system accounts to automatically run background services without manual intervention.

- **Log on as a batch job:**
Allows users to schedule and run scripts or automated tasks during off-peak hours.

- **Shut down the system:**
Restricts shutdown access to admins only, preventing accidental power-downs by regular users who might not realize the impact.

- **Log on through Remote Desktop Services:**
allows users to log into a desktop remotly.

<img width="1920" height="1030" alt="user rights" src="https://github.com/user-attachments/assets/599b7217-f078-4ef0-8e64-449fe4c9553b" />
