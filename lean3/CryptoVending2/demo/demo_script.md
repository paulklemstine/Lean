# CryptoVend Demo Script

## Demo Solidarity: "Selling a File with No Server, No Intermediary, No Trust"

*Duration: ~5 minutes*
*Requirements: Chrome/Firefox with MetaMask, testnet ETH on Arbitrum Sepolia*

---

## ACT 1: The Problem (30 seconds)

**Narration:**

> "Right now, if you want to sell a digital file — a dataset, an e-book, a song — you need a platform. Gumroad takes 10%. Apple takes 30%. They require your real identity, your bank account, and they can deplatform you at any time."
>
> "What if you could sell a file using nothing but your web browser?"

**Visual:** Show comparison table of platform fees.

---

## ACT 2: The Seller (90 seconds)

**Action:** Open `seller.html` in Chrome.

1. **Connect MetaMask** → Click "Connect MetaMask" button
   - Show: wallet address appears
   - **Narration:** "First, I connect my crypto wallet. This is my identity — a cryptographic address, not my name."

2. **Select a file** → Drag in a sample file (e.g., `sample_dataset.csv`)
   - Show: filename and size appear
   - **Narration:** "I drag in the file I want to sell. Could be anything — a dataset, a research paper, source code."

3. **Choose network** → Click "Arb Sepolia" (testnet)
   - Show: network card highlights
   - **Narration:** "I choose a Layer 2 network. Transaction costs are pennies instead of dollars."

4. **Set price** → Enter 0.001 ETH
   - **Narration:** "I set my price. About $3 at current rates."

5. **Click "Deploy"** → Watch the deployment log
   - Show: Step-by-step log appearing:
     - "Encrypting file with AES-256-GCM..."
     - "Uploading encrypted file to IPFS..."
     - "Deploying contract..."
     - "Generating buyer page..."
     - "Pinning buyer page to IPFS..."
     - "🎉 VENDING MACHINE IS LIVE!"
   - **Narration:** "Watch what happens: the browser encrypts the file, uploads it to IPFS, deploys a smart contract, and generates a buyer page — all automatically. No server. No backend. Just this HTML page."

6. **Show the IPFS link**
   - **Narration:** "This link is the buyer page. It's hosted on IPFS — a decentralized network. I share this link, and anyone in the world can buy my file."

---

## ACT 3: The Buyer (90 seconds)

**Action:** Open the buyer IPFS link in a different browser/profile (simulating a different person).

1. **See the buyer page**
   - Show: File info, price, "Connect & Buy" button
   - **Narration:** "The buyer sees a clean page: file name, price, one button. That's it."

2. **Click "Connect & Buy"**
   - Show: MetaMask pops up, asking to connect
   - **Narration:** "They connect their wallet..."

3. **Approve the transaction**
   - Show: MetaMask shows transaction details (amount, gas estimate)
   - **Narration:** "...and approve the payment. On Arbitrum Sepolia, gas is free. On mainnet, it's about 2 cents."

4. **Watch the purchase flow**
   - Show: Progress steps lighting up:
     - ✓ Connect MetaMask
     - ✓ Generate encryption keypair
     - ✓ Send payment
     - ⏳ Wait for seller...
   - **Narration:** "The browser generates a fresh encryption keypair and sends the payment plus the public key to the contract."

5. **Key delivery** (automatic)
   - Show: On seller's tab, watcher log shows "🛒 NEW PURCHASE" and "✓ Key delivered"
   - Show: On buyer's page, remaining steps complete:
     - ✓ Decrypt AES key
     - ✓ Download & decrypt file
   - **Narration:** "The seller's browser detects the payment, encrypts the key specifically for this buyer, and delivers it on-chain. The buyer decrypts everything locally. Total time: about 25 seconds."

6. **Download the file**
   - Show: "Download Decrypted File" button appears, click it
   - **Narration:** "The buyer downloads the file. It's the original, unencrypted file. The sale is complete."

---

## ACT 4: The Magic (30 seconds)

**Action:** Switch back to seller's tab, show the dashboard.

- Show: Sales counter shows "1", revenue shows "0.001 ETH"
- **Narration:** "The seller's dashboard updates in real-time. One sale, 0.001 ETH revenue. And here's the thing: the vending machine stays live. The next buyer, and the one after that, get the same seamless experience. Infinite automated sales."

---

## ACT 5: The Elephant (30 seconds)

**Narration:**

> "There's one honest limitation: the seller needs to keep this tab open. Their browser detects purchases and delivers keys. If the seller closes their laptop, the buyer waits — but after one hour, they can trigger an automatic refund. No money is lost."
>
> "In the future, threshold cryptography could eliminate this requirement — splitting the key across independent nodes that collectively release it. But today, the simplicity is the point: two HTML files and a smart contract. That's the whole system."

---

## CLOSING

**Narration:**

> "CryptoVend. No server. No intermediary. No trust. Just math."

**Visual:** Show the three files side by side:
- `seller.html` — the seller console
- `buyer page` — generated and pinned to IPFS
- `CryptoVendL2.sol` — the smart contract

---

## Technical Demo: Encryption Verification

For a more technical audience, add this segment:

1. **Show the encrypted file on IPFS** — it's gibberish
2. **Show the AES key commitment on the block explorer** — just a hash
3. **Show the ECIES encrypted key on-chain** — encrypted specifically for the buyer
4. **Show the decrypted file** — matches the original exactly

**Narration:** "The AES key never appears on-chain in the clear. The buyer's ECIES private key never leaves their browser. The IPFS file is content-addressed — any modification changes the address. Every layer has its own cryptographic guarantee."

---

## Setup Checklist

- [ ] Install MetaMask in Chrome
- [ ] Create two MetaMask accounts (seller and buyer)
- [ ] Get testnet ETH on Arbitrum Sepolia (faucet: https://www.alchemy.com/faucets/arbitrum-sepolia)
- [ ] Open seller.html in one browser profile
- [ ] Prepare a sample file (e.g., small CSV or text file)
- [ ] Have a second browser profile ready for buyer
- [ ] Optional: Web3.Storage API token for real IPFS pinning
