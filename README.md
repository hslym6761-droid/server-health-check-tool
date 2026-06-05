# Server Health Check Tool

A Bash script that performs health checks on multiple remote Linux servers through SSH.

## Features

- Check system uptime
- Check disk usage
- Check memory usage
- Check failed SSH login attempts
- Support multiple servers from a file

## Requirements

- Linux
- Bash
- SSH access to target servers

## Usage

```bash
./server_check.sh -f servers.txt -u username
```

## Example

```bash
./server_check.sh -f servers.txt -u akamal
```

## Output

- System uptime
- Disk usage
- Memory usage
- Security information

## Author

Hamdy Selim
