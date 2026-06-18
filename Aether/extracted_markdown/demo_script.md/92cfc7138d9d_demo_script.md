# CryptoVend v3 Demo Script

## Demo: "Selling a File with No Server, No Intermediary, No Trust — and No Seller Online"

*Duration: ~6 minutes*
*Requirements: Chrome/Firefox with MetaMask, testnet ETH on Arbitrum Sepolia, 3 browser profiles (seller + 2 oracles)*

---

## ACT 1: The Problem (30 seconds)

**Narration:**

> "In v2, CryptoVend let you sell files with no server — just two HTML pages and a smart contract. But there was an elephant in the room: the seller had to keep their browser open to deliver keys."
>
> "v3 kills the elephant. Using threshold cryptography, the seller deploys once and goes offline forever."

---

## ACT 2: The Seller (90 seconds)

**Action:** Open `seller.html` in Chrome.

1. **Connect MetaMask** → Click "Connect MetaMask"
   - **Narration:** "Connect your wallet — same as before."

2. **Select a file** → Drag in a sample file
   - **Narration:** "Choose your file. Any format, any size."

3. **Choose network** → Click "Arb Sepolia"

4. **Set price** → Enter 0.001 ETH

5. **Configure oracles** → Set threshold to 2-of-3
   - Enter 3 oracle addresses (from MetaMask)
   - Enter 3 endpoint URLs
   - **Narration:** "Here's what's new: I configure an oracle network. Three independent nodes, any two can reconstruct the key. I enter their Ethereum addresses and their server endpoints."

6. **Click "Deploy"** → Watch the log
   - Show: New steps appearing:
     - "Encrypting file with AES-256-GCM..."
     - "Splitting key into 3 shares (threshold=2)..."
     - "✓ Shamir split verified: 2-of-3 reconstruction OK"
     - "Encrypting shares for oracle nodes..."
     - "Deploying CryptoVendThreshold contract..."
     - "Registering oracle nodes on-chain..."
     - "Pinning buyer page to IPFS..."
     - "🎉 THRESHOLD VENDING MACHINE IS LIVE!"
   - **Narration:** "Watch: the browser splits the encryption key into three pieces using Shamir's Secret Sharing. Each piece is encrypted for its oracle and pinned to IPFS. The contract is deployed with commitment hashes for verification."

7. **Close the tab**
   - **Narration:** "And now... I close the page. The seller is done. Forever. No watcher. No background process. Nothing."

---

## ACT 3: The Oracles (60 seconds)

**Action:** Open `oracle.html` in two different browser profiles.

1. **Oracle #1:** Connect wallet, enter contract address, load share
   - Show: "✓ Share loaded and verified! x=1, 32 bytes"
   - Click "Start Serving"

2. **Oracle #2:** Same process
   - Show: "✓ Share loaded and verified! x=2, 32 bytes"
   - Click "Start Serving"

   - **Narration:** "Each oracle loads their share from IPFS using their Ethereum key. They're stateless — if they restart, they just reload from IPFS. In production, these would be serverless functions, not browser tabs."

---

## ACT 4: The Buyer (90 seconds)

**Action:** Open the buyer IPFS link in yet another browser profile.

1. **See the buyer page**
   - Show: New "2-of-3 threshold" badge, share visualization grid
   - **Narration:** "The buyer sees the same clean interface, but with a threshold indicator: 2-of-3."

2. **Click "Connect & Buy"**
   - Approve MetaMask transaction

3. **Watch share collection**
   - Show: Share dots lighting up: ■ ■ □
     - "Requesting share from Oracle #1..."
     - "Share #1 verified ✓ (1/2)"
     - "Requesting share from Oracle #2..."
     - "Share #2 verified ✓ (2/2)"
   - **Narration:** "The buyer's page contacts each oracle. Each oracle checks on-chain that the payment is valid, then encrypts their share for this specific buyer. Two shares collected — that's enough."

4. **Watch reconstruction**
   - Show: "Reconstructing AES key via Lagrange interpolation..."
   - Show: "✓ Key reconstructed and verified against on-chain commitment"
   - **Narration:** "The browser reconstructs the key using Lagrange interpolation over GF(256). Then it verifies the result against the on-chain commitment — proving the key is correct."

5. **File decrypts and downloads**
   - **Narration:** "File decrypted. Sale complete. The seller was never involved."

---

## ACT 5: The Significance (30 seconds)

**Narration:**

> "Let's recap what just happened:
> - The seller deployed once and closed their browser
> - Two independent oracle nodes held pieces of the key
> - Neither oracle knew the full key
> - The buyer paid, collected shares, reconstructed the key, and decrypted — all automatically
> - If oracle #3 was offline, it didn't matter — only 2 were needed
> - No server. No watcher. No single point of failure."
>
> "CryptoVend v3: the vending machine that runs itself."

---

## Setup Checklist

- [ ] Install MetaMask in Chrome
- [ ] Create 4+ MetaMask accounts (seller, 3 oracles, buyer)
- [ ] Get testnet ETH on Arbitrum Sepolia for all accounts
- [ ] Open seller.html in one browser profile
- [ ] Prepare oracle.html in two other profiles
- [ ] Have a fourth profile ready for the buyer
- [ ] Prepare a sample file (small CSV or text file)
