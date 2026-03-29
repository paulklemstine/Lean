# The Vending Machine That Sells Secrets

### How cryptographers built a digital file shop with no shopkeeper, no server, and no trust required

*By the CryptoVending Research Team*

---

Imagine a vending machine. You walk up, insert your coins, press a button, and a candy bar drops out. Simple. Reliable. No cashier needed.

Now imagine the same thing, but for digital files. You visit a web page, send some cryptocurrency, and an encrypted file unlocks itself — just for you. There's no company running the store. No server to hack. No employee to bribe. The "shopkeeper" is a few hundred lines of code running on Ethereum, the global blockchain computer, and the file lives on IPFS, a decentralised network where data is identified not by *where* it lives but by *what* it contains.

We built this. We call it CryptoVending.

---

## The Problem No One Knew They Had

When you buy a song on iTunes or a document on Gumroad, a cascade of trust is required. You trust Apple or Gumroad not to steal your credit card. You trust them to actually deliver the file. You trust their servers to stay online. You trust them not to revoke your access later.

Most of the time, this works fine. But "most of the time" isn't the same as "always." Servers go down. Companies go bankrupt. Governments order takedowns. And behind every digital storefront is a database that some administrator can read, modify, or delete.

What if the laws of mathematics — not the policies of corporations — guaranteed that you got what you paid for?

---

## A Lock, A Key, and A Promise

The core idea is deceptively simple. Here's how it works:

**The Seller** has a file — let's say it's a recipe for the world's best chocolate chip cookies. (Or a research dataset. Or a musical score. Or anything.) The seller runs a program that does three things:

1. **Encrypts the file** with a random 256-bit key. This is AES-256-GCM, the same encryption used by banks and governments. Without the key, the encrypted file is gibberish — even with every computer on Earth working in concert, it would take longer than the age of the universe to crack.

2. **Uploads the encrypted file to IPFS.** The InterPlanetary File System is a peer-to-peer network where files are identified by their cryptographic fingerprint (called a CID, or Content Identifier). If even a single bit of the file changes, the fingerprint changes. This means you can verify the file hasn't been tampered with just by checking its CID.

3. **Deploys a smart contract to Ethereum.** This is the "vending machine." It's a small program that lives on the blockchain and enforces the rules: accept payment, record the buyer's identity, and coordinate the key delivery. Crucially, the contract stores a *commitment* to the encryption key (a hash) — not the key itself.

**The Buyer** visits a web page — also hosted on IPFS, so it's decentralised too — and clicks "Buy." Their MetaMask crypto wallet pops up. They approve the transaction. Behind the scenes, their browser generates a fresh cryptographic keypair and sends the public key along with the payment.

Then something elegant happens. The seller's computer, watching the blockchain for purchase events, sees the buyer's payment and public key. It encrypts the file's decryption key *specifically for that buyer* using a scheme called ECIES (Elliptic Curve Integrated Encryption Scheme), which ensures that only the holder of the matching private key can unlock it. It posts this encrypted package back to the smart contract.

The buyer's browser picks it up, decrypts the file key with its private key (which never left the browser), downloads the encrypted file from IPFS, and unlocks it.

The cookie recipe appears on screen.

---

## Why It Matters

Let's count the things that *didn't* happen:

- **No server was needed.** The buyer page is on IPFS. The payment logic is on Ethereum. The file is on IPFS. There is no `http://cookies.com` to go offline.

- **No one saw the decryption key.** It was generated on the seller's computer, encrypted for the specific buyer, and decrypted in the buyer's browser. At no point did it appear in cleartext on the blockchain.

- **No one can tamper with the file.** IPFS's content addressing means the CID *is* the file's hash. If someone swaps the file, the CID changes, and the buyer's software rejects it.

- **No intermediary took a cut.** The payment goes directly from buyer to seller via the smart contract. (Ethereum does charge a gas fee — currently a few dollars — but this goes to the network's validators, not a middleman.)

- **No one can revoke access.** Once the buyer has the decrypted file, it's theirs. No DRM server can phone home and disable it.

---

## The Mathematics of Trust

The security of CryptoVending rests on three pillars, each backed by decades of cryptographic research:

**AES-256-GCM** provides what cryptographers call *authenticated encryption*. "Authenticated" means that any attempt to modify the encrypted data — even flipping a single bit — will be detected during decryption. It's not just secret; it's tamper-proof. The "256" refers to the key length: 2^256 possible keys, a number so large that writing it out would fill this paragraph with digits.

**ECIES** (based on elliptic curve cryptography) solves the key-transport problem. How do you send a secret to someone you've never met? The buyer publishes a public key — think of it as a padlock they've opened and left out for anyone to use. The seller locks the decryption key inside and sends it to the buyer. Only the buyer's private key — the one key that opens their particular padlock — can unlock it.

**Keccak-256** (Ethereum's native hash function) provides the key commitment. The seller stores `hash(key)` on the blockchain when deploying the contract. After the buyer receives and decrypts the key, they can compute the hash themselves and verify it matches the on-chain value. If the seller sent a wrong key, the hashes won't match — and the buyer has immutable, on-chain proof of fraud.

---

## The Elephant in the Room

No system is perfect, and CryptoVending has an honest limitation: the seller needs to be online.

When the buyer pays, the seller's computer must be running to detect the purchase and deliver the encrypted key. If the seller's computer is off, the buyer waits. In a future version, this could be solved with *threshold cryptography* — distributing the key across a network of independent nodes that collectively decrypt it when the payment condition is met, with no single node able to cheat.

There's also the cost question. On Ethereum's main network, the gas fees for deploying a contract and processing a purchase total around $14 at current prices. That's fine for selling a $100 dataset, but absurd for a $1 song. The fix is *Layer 2* networks — platforms like Arbitrum and Base that batch transactions and settle on Ethereum, reducing costs by a factor of 10 to 50. On Layer 2, the same process costs under $2.

---

## What Does This Enable?

The implications go beyond cookie recipes.

**Academic publishing.** A researcher could sell access to a dataset or a paper directly, without a publisher as intermediary. The payment is instant, global, and pseudonymous.

**Whistleblowing.** A source could encrypt documents and sell (or give) them to journalists via a smart contract, with no server logs to subpoena. The IPFS CID serves as a tamper-proof receipt.

**Digital art.** Unlike NFTs that merely point to an image URL, CryptoVending actually gates access to the underlying file. You don't buy a receipt — you buy the art itself, encrypted and delivered.

**Software licensing.** A developer could sell a binary or source code archive. The buyer proves payment on-chain; the code unlocks automatically.

**Music and media.** Independent artists could sell tracks directly to fans. No Spotify. No Apple. No 30% cut.

---

## A Philosophical Machine

There's something almost philosophical about a vending machine with no owner.

Traditional commerce requires trust in institutions — banks, courts, corporations. CryptoVending replaces institutional trust with mathematical trust. The AES cipher doesn't care about your jurisdiction. The Ethereum blockchain doesn't take weekends off. The IPFS network doesn't have a CEO who can be pressured by a government.

This isn't anarchy. The smart contract *is* the institution — an institution whose rules are transparent, whose enforcement is automatic, and whose existence doesn't depend on any single person or organisation.

Of course, mathematics can't solve everything. It can't verify that the cookie recipe is actually good. It can't prevent the seller from uploading an empty file (though the buyer can check the file size before purchasing). And it can't replace the human relationships that make real commerce work.

But for the narrow problem of "I have a file, you want it, let's make a deal" — the vending machine is open. No shopkeeper required.

---

*The CryptoVending protocol and reference implementation are open-source. The complete technical paper, source code, and demo are available in the project repository.*

---

### Sidebar: How to Buy a File from the Blockchain

1. **Get MetaMask** — a browser extension that serves as your Ethereum wallet.
2. **Get some ETH** — purchase on a crypto exchange and send to your wallet.
3. **Visit the seller's link** — an IPFS URL like `ipfs.io/ipfs/Qm...`
4. **Click "Connect Wallet & Buy"** — MetaMask pops up to confirm.
5. **Wait ~30 seconds** — the seller's automated system delivers your key.
6. **Download** — the decrypted file saves to your computer.

Total time: under a minute. Total trust required: zero.

---

### Sidebar: The Numbers

| What | How much |
|------|---------|
| Encryption strength | 2^256 possible keys |
| File storage | Unlimited (IPFS) |
| Gas cost (L1) | ~$14 per sale |
| Gas cost (L2) | ~$1.50 per sale |
| Intermediaries | 0 |
| Servers | 0 |
| Trust required | Cryptographic only |
