#!/bin/bash

#############################################
# Claude-Flow Installation for Hetzner/AlmaLinux 9
# IMPORTANT: Requires Claude Pro Account ($200/month recommended)
#############################################

set -e

# Configuration
FLOW_USER="flowuser"
INSTALL_DIR="/home/$FLOW_USER/claude-flow"
NODE_VERSION="20"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Claude-Flow Installation${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "• Requires Claude Pro Account (recommended: \$200/month)"
echo "• Claude Code uses your Pro subscription token limit"
echo "• Token reset every 5 hours"
echo "• Recommended: Hetzner Cloud server with 8GB RAM"
echo ""
read -p "Continue? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

#############################################
# System Updates
#############################################

echo -e "${BLUE}[1/8] Preparing system...${NC}"
dnf update -y
dnf install -y epel-release
dnf groupinstall -y "Development Tools"
dnf install -y git sqlite python3 wget curl

# Disable SELinux for development environment
setenforce 0 || true
sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

#############################################
# Install Node.js
#############################################

echo -e "${BLUE}[2/8] Installing Node.js ${NODE_VERSION}...${NC}"
curl -fsSL https://rpm.nodesource.com/setup_${NODE_VERSION}.x | bash -
dnf install -y nodejs

#############################################
# Create User
#############################################

echo -e "${BLUE}[3/8] Creating user ${FLOW_USER}...${NC}"
if ! id "$FLOW_USER" &>/dev/null; then
    useradd -m -s /bin/bash $FLOW_USER
    echo "$FLOW_USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$FLOW_USER
fi

#############################################
# Configure NPM Global Directory for User
#############################################

echo -e "${BLUE}[4/8] Configuring NPM permissions for ${FLOW_USER}...${NC}"
sudo -u $FLOW_USER bash << 'NPMSETUP'
# Set NPM Global Directory for user
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'

# Extend PATH
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
export PATH=~/.npm-global/bin:$PATH
NPMSETUP

#############################################
# Install Packages as flowuser
#############################################

echo -e "${BLUE}[5/8] Installing Claude Code & Claude-Flow as ${FLOW_USER}...${NC}"
echo -e "${YELLOW}NOTE: NPM warnings with --force are normal for Claude Code/Flow!${NC}"

sudo -u $FLOW_USER bash << 'USERINSTALL'
# Set PATH for this session
export PATH=~/.npm-global/bin:$PATH

echo "Installing Claude Code (NPM warnings are normal)..."
npm install -g @anthropic-ai/claude-code --force 2>/dev/null || {
    echo "Retrying Claude Code installation..."
    npm install -g @anthropic-ai/claude-code --force
}

echo "Installing Claude-Flow (NPM warnings are normal)..."
npm install -g claude-flow@alpha --force 2>/dev/null || {
    echo "Retrying Claude-Flow installation..."
    npm install -g claude-flow@alpha --force
}

# Verify installations
echo ""
echo "=== INSTALLATION VERIFICATION ==="
if command -v claude &> /dev/null; then
    echo "✅ Claude Code installed successfully"
    claude --version
else
    echo "❌ Claude Code not found in PATH"
fi

if npx claude-flow@alpha --version &> /dev/null; then
    echo "✅ Claude-Flow installed successfully"
    npx claude-flow@alpha --version
else
    echo "❌ Claude-Flow not working"
fi

echo ""
echo "Global packages:"
npm list -g --depth=0 2>/dev/null | head -10
USERINSTALL

#############################################
# Setup User Environment
#############################################

echo -e "${BLUE}[6/8] Configuring user environment...${NC}"
sudo -u $FLOW_USER bash << 'USERSETUP'
# Set PATH for this session
export PATH=~/.npm-global/bin:$PATH

mkdir -p ~/claude-flow
cd ~/claude-flow

echo "Initializing Claude-Flow..."
# Initialize Claude-Flow
npx claude-flow@alpha init --force --hive-mind --neural-enhanced || true

echo "Setting up MCP..."
# MCP Setup
npx claude-flow@alpha mcp setup --auto-permissions --87-tools || true

# Create helper scripts
cat > ~/claude-flow/start-swarm.sh << 'EOF'
#!/bin/bash
echo "Starting Claude-Flow Swarm"
echo "========================="
echo "IMPORTANT: Uses your Claude Pro tokens!"
echo ""
echo "Examples:"
echo "  5 Agents (Standard): npx claude-flow@alpha swarm 'Your task' --claude"
echo "  16 Agents: npx claude-flow@alpha swarm 'Your task' --agents 16 --claude"
echo "  32 Agents: npx claude-flow@alpha swarm 'Your task' --agents 32 --claude"
echo ""
echo "Topology:"
echo "  Centralized (small): --topology centralized"
echo "  Mesh (7 agents max): --topology mesh"
echo "  Hierarchical (16+): --topology hierarchical"
EOF
chmod +x ~/claude-flow/start-swarm.sh

cat > ~/claude-flow/workflow.sh << 'EOF'
#!/bin/bash
echo "Development Workflow:"
echo "===================="
echo "1. Create issue (GitHub or local)"
echo "2. Analysis Swarm:"
echo "   npx claude-flow@alpha swarm 'Analyze issue #1' --mode analysis --claude"
echo "3. Implementation Swarm:"
echo "   npx claude-flow@alpha swarm 'Fix issue #1' --agents 16 --claude"
echo "4. Test Swarm (optional):"
echo "   npx claude-flow@alpha swarm 'Write tests for issue #1' --claude"
EOF
chmod +x ~/claude-flow/workflow.sh

# Add aliases (PATH already in .bashrc)
cat >> ~/.bashrc << 'EOF'

# Claude-Flow Aliases
alias cf='npx claude-flow@alpha'
alias cf-swarm='npx claude-flow@alpha swarm'
alias cf-hive='npx claude-flow@alpha hive-mind'
alias cf-status='npx claude-flow@alpha status'
alias cf-memory='npx claude-flow@alpha memory'

# Debug Aliases
alias cf-version='npx claude-flow@alpha --version'
alias cf-test='npx claude-flow@alpha memory stats'
EOF

# Reload .bashrc for PATH
source ~/.bashrc
USERSETUP

#############################################
# Prepare Django Connection
#############################################

echo -e "${BLUE}[7/8] Creating SSH template for accessing more hetzner servers...${NC}"
sudo -u $FLOW_USER bash << 'DJANGO'
mkdir -p ~/claude-flow/django
cat > ~/claude-flow/django/connect.sh << 'EOF'
#!/bin/bash
echo "Setting up Django SSH Connection"
echo "================================"

# Generate SSH key if not exists
if [ ! -f ~/.ssh/django_key ]; then
    echo "Generating SSH key..."
    ssh-keygen -t ed25519 -f ~/.ssh/django_key -N ""
fi

# Create/extend SSH config
if ! grep -q "Host django-server" ~/.ssh/config 2>/dev/null; then
    echo "Adding SSH config..."
    mkdir -p ~/.ssh
    cat >> ~/.ssh/config << 'CONFIG'

Host django-server
    HostName <DJANGO_IP>
    User <USERNAME>
    Port 22
    IdentityFile ~/.ssh/django_key
    StrictHostKeyChecking no
CONFIG
fi

echo ""
echo "NEXT STEPS:"
echo "1. Replace <DJANGO_IP> and <USERNAME> in ~/.ssh/config"
echo "2. Copy this public key to the Django server:"
echo ""
echo "--- PUBLIC KEY ---"
cat ~/.ssh/django_key.pub
echo ""
echo "--- COMMAND FOR DJANGO SERVER ---"
echo "ssh USER@DJANGO_IP 'mkdir -p ~/.ssh && echo \"$(cat ~/.ssh/django_key.pub)\" >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'"
echo ""
echo "3. Test connection: ssh django-server"
EOF
chmod +x ~/claude-flow/django/connect.sh
DJANGO

#############################################
# Configure Firewall
#############################################

echo -e "${BLUE}[8/8] Configuring firewall...${NC}"
if systemctl is-active --quiet firewalld; then
    # Allow Claude-Flow default port
    firewall-cmd --permanent --add-port=3000/tcp
    # Allow SSH from private network (Hetzner Cloud subnet)
    firewall-cmd --permanent --add-source=10.0.0.0/16
    firewall-cmd --reload
    echo "✅ Firewall configured for Hetzner Cloud subnet 10.0.0.0/16"
fi

#############################################
# Set Final Permissions
#############################################

echo -e "${BLUE}[8/8] Setting final permissions...${NC}"
chown -R $FLOW_USER:$FLOW_USER /home/$FLOW_USER/

#############################################
# Installation Test
#############################################

echo -e "${BLUE}Testing installation...${NC}"
sudo -u $FLOW_USER bash << 'TEST'
export PATH=~/.npm-global/bin:$PATH
echo "Testing Claude Code installation:"
claude --version || echo "❌ Claude not working"
echo ""
echo "Testing Claude-Flow installation:"
npx claude-flow@alpha --version || echo "❌ Claude-Flow not working"
echo ""
echo "Testing Memory System (works without Claude login):"
npx claude-flow@alpha memory stats || echo "❌ Memory system not working"
TEST

#############################################
# Final Instructions
#############################################

echo ""
echo "================================"
echo "Installation completed!"
echo "================================"
echo ""
echo "✅ CORRECTIONS APPLIED:"
echo "• NPM Global Directory configured for flowuser"
echo "• All packages installed as flowuser"
echo "• PATH correctly set in ~/.bashrc"
echo "• Permissions set for ~/.npm-global"
echo "• Firewall configured for Hetzner Cloud"
echo ""
echo "NEXT STEPS:"
echo -e "1. Login as flowuser: ${GREEN}su - $FLOW_USER${NC}"
echo -e "2. Connect Claude account: ${GREEN}claude login${NC}"
echo -e "3. Test installation: ${GREEN}cf-version${NC}"
echo -e "4. Memory test (no login required): ${GREEN}cf-test${NC}"
echo -e "5. First swarm: ${GREEN}cf-swarm 'Create hello world' --claude${NC}"
echo ""
echo "HELPER COMMANDS:"
echo "• Connect to Django: ~/claude-flow/django/connect.sh"
echo "• Workflow help: ~/claude-flow/workflow.sh"
echo "• Load aliases: source ~/.bashrc"
echo ""
echo -e "${RED}IMPORTANT WARNINGS:${NC}"
echo "• Token reset every 5 hours (e.g. 7:00, 12:00, 17:00, 22:00)"
echo "• Per session: 2-5 issues possible (\$200 account = 2h intensive usage)"
echo "• Never run unattended!"
echo "• Always manually review git pushes (may contain credentials!)"
echo ""
echo -e "${GREEN}Ready to rock! 🚀${NC}"