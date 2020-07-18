### Create a New User

```bash
sudo sh newuser.sh [username] [password]
```

### Automatically Reset Owner in a Directory

```bash
find . -maxdepth 1 -type d | sudo bash ~/set.sh
```
