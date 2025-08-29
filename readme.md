# Claude-Flow AlmaLinux 9 Installation Script

![Claude-Flow](https://img.shields.io/badge/Claude--Flow-v2.0.0--alpha-blue)
![AlmaLinux](https://img.shields.io/badge/AlmaLinux-9-green)
![Node.js](https://img.shields.io/badge/Node.js-20+-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)

**Automated installation script for Claude-Flow on Hetzner Cloud AlmaLinux 9 servers**

## 🚀 Quick Start

```bash
# Create script
sudo nano install.sh

# Make executable
sudo chmod +x install.sh 

# Install
sudo ./install.sh
```

## 🏗️ Infrastructure Setup

### Recommended Hetzner Cloud Setup

For optimal performance, set up **2 servers** in the same private network:

#### Server 1: WireGuard VPN Server
- **RAM**: 2-4GB
- **Purpose**: Secure VPN access
- **Network**: 10.0.0.0/16 subnet

#### Server 2: Claude-Flow Server
- **RAM**: 8GB (minimum)
- **Purpose**: AI orchestration
- **Network**: 10.0.0.0/16 subnet

### Network Requirements
- Both servers must be in the **same subnet** (10.0.0.0/16)
- Private network communication required
- Firewall automatically configured by script

## 📋 Prerequisites

### Required
- **Hetzner Cloud Account**
- **AlmaLinux 9** server with 8GB RAM
- **Claude Pro Account** ($200/month recommended)
- **Root access** to the server

### Token Limits
- **Token reset**: Every 5 hours (7:00, 12:00, 17:00, 22:00)
- **Session capacity**: 2-5 issues per session
- **Usage time**: ~2 hours intensive usage with $200 account

## ✨ Features

### 🔧 System Configuration
- ✅ **Automatic AlmaLinux 9 updates**
- ✅ **Node.js 20+ installation**
- ✅ **Development tools setup**
- ✅ **SELinux configuration for development**
- ✅ **Firewall rules for Hetzner Cloud subnet**

### 👤 User Management
- ✅ **Dedicated flowuser creation**
- ✅ **Proper NPM global directory setup**
- ✅ **PATH configuration in .bashrc**
- ✅ **Sudo permissions configuration**

### 🤖 AI Tools Installation
- ✅ **Claude Code global installation**
- ✅ **Claude-Flow Alpha installation**
- ✅ **87 MCP tools integration**
- ✅ **Hive-mind architecture setup**
- ✅ **Neural-enhanced coordination**

### 🛠️ Helper Scripts
- ✅ **Swarm startup scripts**
- ✅ **Development workflow templates**
- ✅ **Django SSH connection setup**
- ✅ **Convenient aliases (cf, cf-swarm, etc.)**

### 🔒 Security Features
- ✅ **User isolation for flowuser**
- ✅ **SSH key generation for Django**
- ✅ **Firewall configuration**
- ✅ **Private network optimization**

## 📊 Installation Process

### Step-by-Step Breakdown

1. **System Preparation** - Updates and dependencies
2. **Node.js Installation** - Latest LTS version
3. **User Creation** - Dedicated flowuser with sudo
4. **NPM Configuration** - Global directory and permissions
5. **AI Tools Installation** - Claude Code and Claude-Flow
6. **Environment Setup** - Scripts, aliases, and configuration
7. **Django Integration** - SSH templates and connection scripts
8. **Security Configuration** - Firewall and network rules

### Installation Time
- **Total duration**: 5-10 minutes
- **Download size**: ~500MB
- **Disk usage**: ~2GB after installation

## 🎯 Usage Instructions

### After Installation

1. **Switch to flowuser**
   ```bash
   su - flowuser
   ```

2. **Connect Claude Account**
   ```bash
   claude login
   ```
   *Note: For headless servers, this will provide a URL to authenticate on your local machine*

3. **Test Installation**
   ```bash
   cf-version              # Check Claude-Flow version
   cf-test                 # Test memory system (no login required)
   ```

4. **First Swarm**
   ```bash
   cf-swarm 'Create hello world Python script' --claude
   ```

### Development Workflows

#### Simple Task (5 Agents)
```bash
npx claude-flow@alpha swarm 'Your task here' --claude
```

#### Complex Development (16 Agents)
```bash
npx claude-flow@alpha swarm 'Build REST API with FastAPI' --agents 16 --claude
```

#### Enterprise Project (32 Agents)
```bash
npx claude-flow@alpha swarm 'Complex enterprise system' --agents 32 --topology hierarchical --claude
```

### Helper Commands

#### Quick Access Aliases
- `cf` - Short for npx claude-flow@alpha
- `cf-swarm` - Start swarm
- `cf-hive` - Hive-mind mode
- `cf-status` - System status
- `cf-memory` - Memory management

#### Workflow Scripts
- `~/claude-flow/start-swarm.sh` - Swarm examples
- `~/claude-flow/workflow.sh` - Development workflow guide

## 🔧 Swarm Topologies

| Agents | Topology | Best For |
|--------|----------|----------|
| 5 | centralized | Simple tasks |
| 7 | mesh | Team communication |
| 16 | hierarchical | Complex issues |
| 32 | hierarchical | Enterprise projects |

## 🌐 Django Integration

The script prepares SSH connectivity for Django development servers:

### Setup Django Connection
```bash
~/claude-flow/django/connect.sh
```

This will:
1. Generate SSH keys
2. Create SSH configuration
3. Provide public key for Django server
4. Enable secure development workflow

## ⚠️ Important Warnings

### Token Management
- **Never run unattended** - Can consume daily token limit in 2 hours
- **Monitor usage** - Check token consumption regularly
- **Plan sessions** - Best used during productive development hours

### Security Considerations
- **Review git pushes** - May contain API credentials
- **Private network only** - Designed for Hetzner Cloud private networks
- **Firewall configured** - Only allows access from 10.0.0.0/16 subnet

### Performance Notes
- **Compile errors are normal** - Feed errors back to swarm for fixes
- **Memory usage** - 8GB RAM minimum for stable operation
- **Network dependency** - Requires stable internet for API calls

## 🐛 Troubleshooting

### "claude: command not found"
```bash
npm install -g @anthropic-ai/claude-code --force
source ~/.bashrc
```

### Token limit reached
- Wait 5 hours from first usage
- Use smaller swarms (5 instead of 32 agents)
- Monitor usage with cf-status

### Compile errors in projects
```bash
npx claude-flow@alpha swarm 'Fix compile error: [ERROR MESSAGE]' --claude
```

## 📈 Performance Metrics

### Industry-Leading Results
- ✅ **84.8% SWE-Bench** solve rate
- ✅ **32.3% token reduction** through efficient coordination
- ✅ **2.8-4.4x speed improvement** via parallel processing
- ✅ **87 MCP tools** comprehensive AI toolkit

## 📚 Documentation

### Official Resources
- [Claude-Flow GitHub](https://github.com/ruvnet/claude-flow)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Anthropic API Documentation](https://docs.anthropic.com)

### Community
- GitHub Issues for bug reports
- Discussions for feature requests
- Examples directory for code samples

## 📄 License

MIT License - see LICENSE for details.

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Test on AlmaLinux 9
4. Submit pull request

## 🆘 Support

For installation issues:
1. Check troubleshooting section
2. Review log output during installation
3. Create GitHub issue with full error log
4. Include system information (OS, RAM, Node.js version)

---

**Ready to revolutionize your AI development workflow? 🚀**

```bash
curl -O https://raw.githubusercontent.com/your-repo/install.sh
chmod +x install.sh
sudo ./install.sh
```