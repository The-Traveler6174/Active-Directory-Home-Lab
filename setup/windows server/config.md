# 🛠️ Windows Server 2025 Setup

In this stage, I installed and configured a **Windows server 2025**. The process includes setting a static IP, installing Active Directory Domain Services, and promoting the server to Domain Controller.

---

## 💻 1. Initial Configuration

- Set a **static IP address**: `192.168.122.10`
- Configured DNS to point to itself (`192.168.122.10`)
<img width="1920" height="1030" alt="set server" src="https://github.com/user-attachments/assets/7da03f3c-3ce9-4569-a7ac-01db59ac2a3f" />

## 📦 2. Installing AD DS Role

- Opened **Server Manager**
- Selected **Add Roles and Features**
- Installed the **Active Directory Domain Services (AD DS)** role
<img width="1920" height="1030" alt="install AD services" src="https://github.com/user-attachments/assets/55409daa-ceca-4a43-bdd3-ba5706dda223" />

## 🏰 3. Promoting to Domain Controller

- Promoted the server to a DC using the post-installation wizard
- Created a **new forest** named `night.corp`
- Accepted the default NetBIOS name: `NIGHT`
- Rebooted the machine after setup completed
<img width="1920" height="1030" alt="promote DC" src="https://github.com/user-attachments/assets/19390714-e7e1-4d46-9872-3792299008c3" />

## 📁 4. Summary

| Configuration Item         | Value                            |
|----------------------------|----------------------------------|
| **Server Name**            | Night-main                       |
| **Static IP**              | 192.168.122.10                   |
| **Domain Name**            | night.corp                       |
| **DNS Server**             | 192.168.122.10 (local)           |
| **AD Role Installed**      | Active Directory Domain Services |
| **Domain Controller Type** | New Forest                       |

---
