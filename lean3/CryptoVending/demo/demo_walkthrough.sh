#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
#  CryptoVending — End-to-End Demo Walkthrough
# ═══════════════════════════════════════════════════════════════════════
#
#  This script demonstrates the full lifecycle:
#    1. Create a test file
#    2. Encrypt & upload to mock IPFS
#    3. Deploy the contract to a local Hardhat/Ganache node
#    4. Simulate a purchase
#    5. Deliver the decryption key
#    6. Buyer decrypts the file
#
#  Prerequisites:
#    pip install -r requirements.txt
#    # Start a local Ethereum node (one of):
#    npx hardhat node          # Hardhat
#    ganache-cli               # Ganache
#
# ═══════════════════════════════════════════════════════════════════════

set -euo pipefail
cd "$(dirname "$0")/.."

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           CryptoVending — Demo Walkthrough                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo

# ── Step 1: Create test file ──────────────────────────────────────────
echo "📄 Step 1: Creating test file…"
mkdir -p /tmp/cryptovending_demo
cat > /tmp/cryptovending_demo/secret_recipe.txt << 'EOF'
╔══════════════════════════════════════════╗
║   TOP SECRET: Grandma's Cookie Recipe    ║
╠══════════════════════════════════════════╣
║                                          ║
║  2 cups flour                            ║
║  1 cup butter (the real kind)            ║
║  3/4 cup brown sugar                     ║
║  1 tsp vanilla extract                   ║
║  1 cup chocolate chips                   ║
║  1 pinch of love                         ║
║                                          ║
║  Bake at 350°F for 12 minutes.           ║
║  This file cost you 0.01 ETH.            ║
║  Worth every wei.                        ║
║                                          ║
╚══════════════════════════════════════════╝
EOF
echo "   Created: /tmp/cryptovending_demo/secret_recipe.txt"
echo

# ── Step 2: Encrypt & upload ─────────────────────────────────────────
echo "🔐 Step 2: Encrypting and uploading to mock IPFS…"
python vending_machine.py create \
    --file /tmp/cryptovending_demo/secret_recipe.txt \
    --price 0.01 \
    --ipfs mock \
    --network localhost \
    --output /tmp/cryptovending_demo/recipe_vend.json
echo

# ── Step 3: Show artifact ────────────────────────────────────────────
echo "📋 Step 3: Deployment artifact:"
python vending_machine.py info \
    --artifact /tmp/cryptovending_demo/recipe_vend.json
echo

# ── Step 4: Deploy (requires local node) ─────────────────────────────
echo "🚀 Step 4: Deploying contract…"
echo "   (Requires a running local Ethereum node on port 8545)"
echo "   Skipping deployment in demo mode — run manually:"
echo "   python vending_machine.py deploy \\"
echo "       --artifact /tmp/cryptovending_demo/recipe_vend.json \\"
echo "       --network localhost"
echo

# ── Step 5: Summary ──────────────────────────────────────────────────
echo "═══════════════════════════════════════════════════════════════"
echo "✅ Demo complete!"
echo ""
echo "Files created:"
echo "  • Encrypted file uploaded to mock IPFS"
echo "  • Buyer page HTML generated"
echo "  • Deployment artifact saved"
echo ""
echo "To complete the full flow:"
echo "  1. Start a local node:  npx hardhat node"
echo "  2. Deploy:              python vending_machine.py deploy ..."
echo "  3. Watch:               python vending_machine.py watch ..."
echo "  4. Open buyer page in browser with MetaMask"
echo "═══════════════════════════════════════════════════════════════"
