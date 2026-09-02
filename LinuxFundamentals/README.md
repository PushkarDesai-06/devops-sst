## Task 1: Soft Link vs Hard Link

A **link** is another way to access a file.

### Soft Link (Symbolic Link)

A soft link points to the **path/name of another file**.

Create one:

```bash
ln -s original.txt softlink.txt
```

Check it:

```bash
ls -l
```

You may see:

```text
softlink.txt -> original.txt
```

### Hard Link

A hard link is another directory entry pointing to the **same inode/data** as the original file.

Create one:

```bash
ln original.txt hardlink.txt
```

---

### Key Differences

| Feature               | Soft Link   | Hard Link                                    |
| --------------------- | ----------- | -------------------------------------------- |
| Command               | `ln -s`     | `ln`                                         |
| Points to             | File path   | Same inode/data                              |
| Different filesystem? | Yes         | Usually no                                   |
| Can link directories? | Yes         | Generally no                                 |
| Original deleted?     | Link breaks | File data still accessible through hard link |
| Has separate inode?   | Yes         | No                                           |

### Example

```bash
echo "Hello" > original.txt

ln original.txt hard.txt
ln -s original.txt soft.txt

ls -li
```

The original and hard link will have the **same inode number**.

---

### What happens when the original is deleted?

```bash
rm original.txt
```

#### Soft link

```bash
cat soft.txt
```

It fails because the path it points to no longer exists.

#### Hard link

```bash
cat hard.txt
```

It still works because `hard.txt` points directly to the same underlying file data.

---

## Task 2: `adduser` vs `useradd`

### `useradd`

```bash
sudo useradd username
```

`useradd` is a **low-level command**.

By default, depending on the system configuration, it may:

- Create the user
- Not create a home directory unless requested
- Not interactively ask for details
- Require additional options

Example:

```bash
sudo useradd -m john
```

`-m` creates the home directory.

---

### `adduser`

```bash
sudo adduser john
```

On Ubuntu and Debian-based systems, `adduser` is a **higher-level, user-friendly interactive script**.

It typically:

- Creates the user
- Creates the home directory
- Creates a group
- Asks for a password
- Interactively asks for user information

### Which should you prefer?

On **Ubuntu/Debian**, for manually creating a user:

```bash
sudo adduser testuser
```

is generally more convenient.

For **scripts and automation**, `useradd` is often preferred because it is a lower-level command and offers predictable options.

---

# Task 3: `journalctl`

## What is `journalctl`?

`journalctl` is used to view logs collected by **systemd-journald**.

It can display logs from:

- The Linux kernel
- System services
- Applications
- Boot processes
- Other system components

---

## Basic Commands

### View all logs

```bash
journalctl
```

### View recent logs

```bash
journalctl -e
```

`-e` jumps to the end of the logs.

### Follow logs in real time

Similar to:

```bash
tail -f
```

Use:

```bash
journalctl -f
```

---

## View Logs for a Specific Service

For example, SSH:

```bash
journalctl -u ssh
```

Or on some systems:

```bash
journalctl -u sshd
```

For a service such as Nginx:

```bash
journalctl -u nginx
```

Follow logs in real time:

```bash
journalctl -u nginx -f
```

---

## View Logs from the Current Boot

```bash
journalctl -b
```

View logs from the previous boot:

```bash
journalctl -b -1
```

---

## Filter by Time

Logs from today:

```bash
journalctl --since today
```

Last hour:

```bash
journalctl --since "1 hour ago"
```

Specific time range:

```bash
journalctl --since "2026-09-01 10:00:00" --until "2026-09-01 12:00:00"
```
