# 💻 Windows 11 Client Setup

This section details how I configured and joined a Windows 11 workstation—**R-Night-comp**—to my domain `night.corp`.

---

## 🌐 1. Network & Hostname Setup

After installation, I did the following:

- Set static IP addresses and DNS:
  - R-Night-comp: `192.168.122.11`
- Set Preferred DNS to point to the Domain Controller: `192.168.122.10`
- Restarted machine to apply changes
<img width="1920" height="1030" alt="set comp" src="https://github.com/user-attachments/assets/284365c1-f753-48c2-aee4-15c099d6cec6" />

---

## 🏢 2. Joining the Domain

On the client:

1. Opened **📂 `Settings > System > About > and click the Domain or Workgroup link under the "Related links" section.`**
2. Hit **change** in the Computer Name tab in System Properties, entered `night.corp`
3. Supplied credentials for a domain admin account
4. Restarted the machine when prompted
<img width="1920" height="1030" alt="join domain" src="https://github.com/user-attachments/assets/a215bb2d-9443-4060-9373-be5e7ce26d03" />

---

## 🧪 4. Verification

After reboot, I:

- Logged in using domain credentials
- Verified domain membership in **System Properties**
<img width="1920" height="1030" alt="verify" src="https://github.com/user-attachments/assets/d696b648-db0d-446e-8cf5-92d90ec65960" />

---

## 📦 7. Summary

| Client Name         | IP Address     | DNS Server     | Domain Joined    |
|---------------------|----------------|----------------|------------------|
| **R-Night-comp**    | 192.168.122.11 | 192.168.122.10 | night.corp       |
