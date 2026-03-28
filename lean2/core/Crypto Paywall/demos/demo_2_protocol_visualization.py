#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║  DEMO 2: Protocol Flow Visualization                                       ║
║                                                                            ║
║  Generates visual diagrams of the Pay-to-Decrypt protocol:                 ║
║  • State machine diagram (ASCII + matplotlib)                              ║
║  • Sequence diagram of the happy path                                      ║
║  • Threat model visualization                                              ║
║  • Gas cost analysis chart                                                 ║
║                                                                            ║
║  Outputs PNG files for the research paper.                                 ║
╚══════════════════════════════════════════════════════════════════════════════╝

Requirements: pip install matplotlib numpy
"""

import os
import sys

# ═══════════════════════════════════════════════════════════════════════════════
#  ASCII SEQUENCE DIAGRAM
# ═══════════════════════════════════════════════════════════════════════════════

def print_sequence_diagram():
    """Print an ASCII sequence diagram of the protocol."""
    
    diagram = """
╔══════════════════════════════════════════════════════════════════════════════════╗
║                    PAY-TO-DECRYPT PROTOCOL SEQUENCE DIAGRAM                    ║
╚══════════════════════════════════════════════════════════════════════════════════╝

  SELLER                         SMART CONTRACT                         BUYER
    │                                  │                                  │
    │  ┌─────────────────────────┐     │                                  │
    │  │ 1. Generate random      │     │                                  │
    │  │    key K (32 bytes)     │     │                                  │
    │  │ 2. Encrypt payload:     │     │                                  │
    │  │    C = Enc(K, P)        │     │                                  │
    │  │ 3. Compute commitment:  │     │                                  │
    │  │    H = keccak256(K)     │     │                                  │
    │  │ 4. Upload C to IPFS     │     │                                  │
    │  └─────────────────────────┘     │                                  │
    │                                  │                                  │
    │──── createListing(H, CID, ───▶  │                                  │
    │         price, timeout)          │                                  │
    │                                  │  ┌────────────────────────────┐  │
    │                                  │  │ State: CREATED             │  │
    │                                  │  │ Stores: H, CID, price     │  │
    │                                  │  └────────────────────────────┘  │
    │                                  │                                  │
    │                                  │     emit ListingCreated() ──────▶│
    │                                  │                                  │
    │                                  │  ┌─────────────────────────┐     │
    │                                  │  │ Buyer inspects listing: │     │
    │                                  │  │ • Checks description    │     │
    │                                  │  │ • Downloads C from IPFS │     │
    │                                  │  │ • Verifies H is valid   │     │
    │                                  │  │ • Decides to purchase   │     │
    │                                  │  └─────────────────────────┘     │
    │                                  │                                  │
    │                                  │  ◀──── fundListing(id)  ────────│
    │                                  │         {value: price}           │
    │                                  │                                  │
    │                                  │  ┌────────────────────────────┐  │
    │                                  │  │ State: FUNDED              │  │
    │                                  │  │ ETH locked in escrow       │  │
    │                                  │  │ Timeout clock starts       │  │
    │                                  │  └────────────────────────────┘  │
    │                                  │                                  │
    │     emit ListingFunded()  ◀─────│                                  │
    │                                  │                                  │
    │──── revealKey(id, K) ──────────▶│                                  │
    │                                  │                                  │
    │                                  │  ┌────────────────────────────┐  │
    │                                  │  │ VERIFY:                    │  │
    │                                  │  │ keccak256(K) == H ? ✅     │  │
    │                                  │  │                            │  │
    │                                  │  │ State: REVEALED            │  │
    │                                  │  │ Transfer ETH → Seller      │  │
    │                                  │  └────────────────────────────┘  │
    │                                  │                                  │
    │  ◀──── ETH Payment ─────────────│                                  │
    │                                  │     emit KeyRevealed(K) ───────▶│
    │                                  │                                  │
    │                                  │  ┌─────────────────────────┐     │
    │                                  │  │ Buyer reads K from event │    │
    │                                  │  │ Decrypts: P = Dec(K, C)  │    │
    │                                  │  │ Verifies content hash    │    │
    │                                  │  └─────────────────────────┘     │
    │                                  │                                  │
    ▼                                  ▼                                  ▼
  SELLER has ETH              CONTRACT is settled            BUYER has plaintext P


═══════════════════════════════════════════════════════════════════════════════════
  TIMEOUT PATH (Seller fails to reveal):
═══════════════════════════════════════════════════════════════════════════════════

    │                                  │                                  │
    │   (Seller disappears or         │     After timeout expires:       │
    │    refuses to reveal K)         │                                  │
    │                                  │  ◀──── claimRefund(id) ─────────│
    │                                  │                                  │
    │                                  │  ┌────────────────────────────┐  │
    │                                  │  │ VERIFY:                    │  │
    │                                  │  │ block.timestamp > expiry   │  │
    │                                  │  │                            │  │
    │                                  │  │ State: REFUNDED            │  │
    │                                  │  │ Transfer ETH → Buyer       │  │
    │                                  │  └────────────────────────────┘  │
    │                                  │                                  │
    │                                  │       ETH Refund ──────────────▶│
    ▼                                  ▼                                  ▼
  SELLER gets nothing         CONTRACT is settled           BUYER gets ETH back
"""
    print(diagram)


# ═══════════════════════════════════════════════════════════════════════════════
#  ASCII STATE MACHINE
# ═══════════════════════════════════════════════════════════════════════════════

def print_state_machine():
    """Print ASCII state machine diagram."""
    
    diagram = """
╔══════════════════════════════════════════════════════════════════════════════════╗
║                         LISTING STATE MACHINE                                  ║
╚══════════════════════════════════════════════════════════════════════════════════╝

                        createListing()
                              │
                              ▼
                    ┌───────────────────┐
                    │     CREATED       │◀─── Initial state
                    │                   │     Seller posted listing
                    └───────┬───────┬───┘
                            │       │
              fundListing() │       │ cancelListing()
              + send ETH    │       │ (seller only)
                            │       │
                            ▼       ▼
                    ┌──────────┐  ┌──────────┐
                    │  FUNDED  │  │CANCELLED │ ◀── Terminal
                    │          │  └──────────┘
                    │ ETH held │
                    │ in escrow│
                    └────┬──┬──┘
                         │  │
           revealKey(K)  │  │  claimRefund()
           + hash check  │  │  + timeout check
                         │  │
                         ▼  ▼
               ┌──────────┐  ┌──────────┐
               │ REVEALED │  │ REFUNDED │
               │          │  │          │
               │ ETH→Sell │  │ ETH→Buy  │
               └──────────┘  └──────────┘
                    ▲              ▲
                    │              │
                 Terminal       Terminal


  ┌─────────────────────────────────────────────────────────────────────┐
  │ SECURITY INVARIANTS:                                               │
  │                                                                    │
  │ 1. ETH can only leave escrow via REVEALED or REFUNDED states      │
  │ 2. REVEALED requires keccak256(K) == committed_hash               │
  │ 3. REFUNDED requires block.timestamp > fundedAt + timeout          │
  │ 4. State transitions are irreversible (no loops)                   │
  │ 5. Exactly one of {REVEALED, REFUNDED, CANCELLED} is the          │
  │    terminal state for any listing that gets funded                  │
  └─────────────────────────────────────────────────────────────────────┘
"""
    print(diagram)


# ═══════════════════════════════════════════════════════════════════════════════
#  THREAT MODEL VISUALIZATION
# ═══════════════════════════════════════════════════════════════════════════════

def print_threat_model():
    """Print threat model analysis."""
    
    diagram = """
╔══════════════════════════════════════════════════════════════════════════════════╗
║                           THREAT MODEL ANALYSIS                                ║
╚══════════════════════════════════════════════════════════════════════════════════╝

  ┌──────────────────────────────────────────────────────────────────────────────┐
  │                          ATTACK SURFACE MAP                                 │
  │                                                                             │
  │    ┌─────────┐         ┌──────────┐         ┌─────────┐                    │
  │    │ SELLER  │◀───①───▶│ CONTRACT │◀───②───▶│  BUYER  │                    │
  │    └────┬────┘         └────┬─────┘         └────┬────┘                    │
  │         │                   │                     │                         │
  │         │              ┌────┴─────┐               │                         │
  │         ③              │ MEMPOOL  │               ④                         │
  │         │              └────┬─────┘               │                         │
  │         │                   │                     │                         │
  │    ┌────┴────┐         ┌────┴─────┐         ┌────┴────┐                    │
  │    │  IPFS   │         │MEV BOTS  │         │OFF-CHAIN│                    │
  │    │STORAGE  │         │SEARCHERS │         │ CLIENT  │                    │
  │    └─────────┘         └──────────┘         └─────────┘                    │
  └──────────────────────────────────────────────────────────────────────────────┘

  ATTACK VECTORS:

  ① Seller → Contract Attacks
  ┌─────────────────────────────────────────────────────────────────────┐
  │ ATTACK: Submit wrong key to claim payment                          │
  │ RESULT: ❌ BLOCKED — keccak256(K) must match committed hash H     │
  │                                                                    │
  │ ATTACK: Never reveal key (take payment without delivering)         │
  │ RESULT: ❌ BLOCKED — Payment is in escrow; no reveal = no payment  │
  │                                                                    │
  │ ATTACK: Reveal key for garbage content                             │
  │ RESULT: ⚠️ PARTIAL — Content hash helps, but buyer must trust     │
  │         the description. Consider adding ZK proofs of content      │
  │         properties.                                                │
  └─────────────────────────────────────────────────────────────────────┘

  ② Buyer → Contract Attacks
  ┌─────────────────────────────────────────────────────────────────────┐
  │ ATTACK: Get key without paying                                     │
  │ RESULT: ❌ BLOCKED — Key only revealed after funding               │
  │                                                                    │
  │ ATTACK: Claim refund before timeout                                │
  │ RESULT: ❌ BLOCKED — block.timestamp check enforced                │
  │                                                                    │
  │ ATTACK: Fund with wrong amount                                     │
  │ RESULT: ❌ BLOCKED — Exact price match required                    │
  └─────────────────────────────────────────────────────────────────────┘

  ③ IPFS / Storage Attacks
  ┌─────────────────────────────────────────────────────────────────────┐
  │ ATTACK: Seller removes ciphertext from IPFS after getting paid     │
  │ RESULT: ⚠️ RISK — Buyer should download immediately after funding │
  │         Mitigation: Pin ciphertext; use Filecoin for persistence   │
  │                                                                    │
  │ ATTACK: Modify ciphertext on IPFS                                  │
  │ RESULT: ❌ BLOCKED — IPFS CID is a content hash; any change       │
  │         produces a different CID                                   │
  └─────────────────────────────────────────────────────────────────────┘

  ④ MEV / Front-Running Attacks
  ┌─────────────────────────────────────────────────────────────────────┐
  │ ATTACK: Extract key K from seller's revealKey() transaction        │
  │         in the mempool before it's mined                           │
  │ RESULT: ⚠️ RISK — Key IS visible in pending transactions          │
  │                                                                    │
  │ MITIGATIONS:                                                       │
  │  • Flashbots Protect: Submit via private mempool                   │
  │  • MEV-Share: Seller captures MEV value                            │
  │  • Accept risk: Front-runner gets content but buyer already paid   │
  │    (buyer still gets the key when tx is mined)                     │
  │  • Encrypt key for buyer's public key (adds complexity)            │
  └─────────────────────────────────────────────────────────────────────┘

  ┌──────────────────────────────────────────────────────────────────────────────┐
  │                        SECURITY SCORECARD                                   │
  │                                                                             │
  │  Property                              │ Status │ Notes                     │
  │  ──────────────────────────────────────┼────────┼────────────────────────── │
  │  Seller can't steal payment            │   ✅   │ Escrow + hash-lock        │
  │  Buyer can't get key without paying    │   ✅   │ Key only revealed on-chain│
  │  Seller must reveal correct key        │   ✅   │ Hash verification         │
  │  Buyer protected from timeout          │   ✅   │ Refund mechanism          │
  │  Content quality guaranteed            │   ⚠️   │ Needs ZK proofs           │
  │  Front-running resistant               │   ⚠️   │ Use Flashbots             │
  │  Censorship resistant                  │   ✅   │ Decentralized (Ethereum)  │
  │  Quantum resistant                     │   ❌   │ keccak256 is pre-quantum  │
  └──────────────────────────────────────────────────────────────────────────────┘
"""
    print(diagram)


# ═══════════════════════════════════════════════════════════════════════════════
#  GAS COST ANALYSIS (ASCII Chart)
# ═══════════════════════════════════════════════════════════════════════════════

def print_gas_analysis():
    """Print gas cost analysis as ASCII bar chart."""
    
    operations = [
        ("createListing()", 85000, "Deploy listing data"),
        ("fundListing()",   55000, "Lock ETH in escrow"),
        ("revealKey()",     45000, "Verify hash + transfer"),
        ("claimRefund()",   35000, "Return ETH to buyer"),
        ("cancelListing()", 25000, "Cancel unfunded listing"),
    ]
    
    eth_price_usd = 3000
    gas_price_gwei = 30
    
    print("""
╔══════════════════════════════════════════════════════════════════════════════════╗
║                          GAS COST ANALYSIS                                     ║
║                    (at 30 gwei gas price, ETH = $3,000)                        ║
╚══════════════════════════════════════════════════════════════════════════════════╝
""")
    
    max_gas = max(op[1] for op in operations)
    bar_width = 40
    
    for name, gas, desc in operations:
        cost_eth = gas * gas_price_gwei * 1e-9
        cost_usd = cost_eth * eth_price_usd
        bar_len = int(gas / max_gas * bar_width)
        bar = '█' * bar_len + '░' * (bar_width - bar_len)
        
        print(f"  {name:<20} │{bar}│ {gas:>6} gas  ${cost_usd:.2f}")
    
    total_happy = 85000 + 55000 + 45000
    total_cost = total_happy * gas_price_gwei * 1e-9 * eth_price_usd
    
    print(f"""
  ─────────────────────────────────────────────────────────────────
  Happy path total:     {total_happy:>6} gas  (${total_cost:.2f})
  
  ┌─────────────────────────────────────────────────────────────────┐
  │ COMPARISON: Layer 1 vs Layer 2 costs                            │
  │                                                                 │
  │ Network          │ Happy Path Cost │ Break-even Content Value   │
  │ ─────────────────┼─────────────────┼──────────────────────────  │
  │ Ethereum L1      │     ${total_cost:>7.2f}     │           >${total_cost*3:.0f}            │
  │ Arbitrum         │     ${total_cost/20:>7.2f}     │           >${total_cost*3/20:.0f}             │
  │ Optimism         │     ${total_cost/20:>7.2f}     │           >${total_cost*3/20:.0f}             │
  │ Base             │     ${total_cost/50:>7.2f}     │           >${total_cost*3/50:.0f}              │
  │ zkSync Era       │     ${total_cost/30:>7.2f}     │           >${total_cost*3/30:.0f}             │
  └─────────────────────────────────────────────────────────────────┘
""")


# ═══════════════════════════════════════════════════════════════════════════════
#  MATPLOTLIB VISUALIZATIONS (saved as PNG)
# ═══════════════════════════════════════════════════════════════════════════════

def try_generate_matplotlib_charts():
    """Generate publication-quality charts if matplotlib is available."""
    try:
        import matplotlib
        matplotlib.use('Agg')  # Non-interactive backend
        import matplotlib.pyplot as plt
        import matplotlib.patches as mpatches
        import numpy as np
        
        output_dir = os.path.dirname(os.path.abspath(__file__))
        
        # ── Chart 1: State Machine ──────────────────────────────────────
        fig, ax = plt.subplots(1, 1, figsize=(12, 8))
        ax.set_xlim(0, 10)
        ax.set_ylim(0, 10)
        ax.set_aspect('equal')
        ax.axis('off')
        ax.set_title('Pay-to-Decrypt: Contract State Machine', fontsize=16, fontweight='bold', pad=20)
        
        # State positions
        states = {
            'CREATED':   (5, 8.5, '#4CAF50'),
            'FUNDED':    (5, 6, '#2196F3'),
            'REVEALED':  (3, 3.5, '#FF9800'),
            'REFUNDED':  (7, 3.5, '#F44336'),
            'CANCELLED': (8.5, 8.5, '#9E9E9E'),
        }
        
        for name, (x, y, color) in states.items():
            circle = plt.Circle((x, y), 0.8, color=color, alpha=0.3, ec=color, lw=2)
            ax.add_patch(circle)
            ax.text(x, y, name, ha='center', va='center', fontsize=9, fontweight='bold')
        
        # Arrows
        arrows = [
            ((5, 7.7), (5, 6.8), 'fundListing()\n+ ETH'),
            ((5, 5.2), (3.5, 4.2), 'revealKey(K)\nhash ✓'),
            ((5, 5.2), (6.5, 4.2), 'claimRefund()\ntimeout ✓'),
            ((5.8, 8.5), (7.7, 8.5), 'cancel()'),
        ]
        
        for start, end, label in arrows:
            ax.annotate('', xy=end, xytext=start,
                       arrowprops=dict(arrowstyle='->', lw=1.5, color='#333'))
            mid_x = (start[0] + end[0]) / 2
            mid_y = (start[1] + end[1]) / 2
            ax.text(mid_x + 0.3, mid_y, label, fontsize=7, ha='center', va='center',
                   bbox=dict(boxstyle='round,pad=0.3', facecolor='wheat', alpha=0.7))
        
        # Entry arrow
        ax.annotate('', xy=(5, 9.3), xytext=(5, 9.8),
                   arrowprops=dict(arrowstyle='->', lw=2, color='green'))
        ax.text(5, 10.0, 'createListing()', ha='center', fontsize=9, color='green')
        
        plt.tight_layout()
        path1 = os.path.join(output_dir, 'state_machine.png')
        plt.savefig(path1, dpi=150, bbox_inches='tight')
        plt.close()
        print(f"  ✅ Saved: {path1}")
        
        # ── Chart 2: Gas Cost Comparison ────────────────────────────────
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
        
        # Left: Gas per operation
        ops = ['createListing', 'fundListing', 'revealKey', 'claimRefund', 'cancelListing']
        gas_costs = [85000, 55000, 45000, 35000, 25000]
        colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9E9E9E']
        
        bars = ax1.barh(ops, gas_costs, color=colors, alpha=0.8, edgecolor='white', lw=1.5)
        ax1.set_xlabel('Gas Units', fontsize=12)
        ax1.set_title('Gas Cost per Operation', fontsize=14, fontweight='bold')
        ax1.invert_yaxis()
        
        for bar, cost in zip(bars, gas_costs):
            ax1.text(bar.get_width() + 1000, bar.get_y() + bar.get_height()/2,
                    f'{cost:,}', va='center', fontsize=10)
        
        # Right: L1 vs L2 costs
        networks = ['Ethereum\nL1', 'Arbitrum', 'Optimism', 'Base', 'zkSync\nEra']
        multipliers = [1, 1/20, 1/20, 1/50, 1/30]
        base_cost_usd = 185000 * 30 * 1e-9 * 3000
        costs_usd = [base_cost_usd * m for m in multipliers]
        
        bars2 = ax2.bar(networks, costs_usd, color=['#627EEA', '#28A0F0', '#FF0420', '#0052FF', '#8C8DFC'],
                       alpha=0.8, edgecolor='white', lw=1.5)
        ax2.set_ylabel('Cost (USD)', fontsize=12)
        ax2.set_title('Happy Path Cost by Network\n(30 gwei, ETH=$3000)', fontsize=14, fontweight='bold')
        ax2.set_yscale('log')
        
        for bar, cost in zip(bars2, costs_usd):
            ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() * 1.2,
                    f'${cost:.2f}', ha='center', va='bottom', fontsize=10, fontweight='bold')
        
        plt.tight_layout()
        path2 = os.path.join(output_dir, 'gas_analysis.png')
        plt.savefig(path2, dpi=150, bbox_inches='tight')
        plt.close()
        print(f"  ✅ Saved: {path2}")
        
        # ── Chart 3: Security Property Radar ────────────────────────────
        fig, ax = plt.subplots(1, 1, figsize=(8, 8), subplot_kw=dict(polar=True))
        
        categories = ['Payment\nAtomicity', 'Content\nIntegrity', 'Censorship\nResistance',
                      'Front-Run\nResistance', 'Content\nVerification', 'Quantum\nResistance',
                      'Privacy', 'Cost\nEfficiency']
        N = len(categories)
        
        # Protocol scores (0-10)
        scores_v1 = [9, 8, 9, 3, 4, 2, 5, 4]  # Basic HTLC
        scores_v2 = [9, 9, 9, 7, 7, 2, 7, 7]  # With Flashbots + L2 + ZK proofs
        
        angles = np.linspace(0, 2 * np.pi, N, endpoint=False).tolist()
        scores_v1 += scores_v1[:1]
        scores_v2 += scores_v2[:1]
        angles += angles[:1]
        
        ax.plot(angles, scores_v1, 'o-', linewidth=2, label='v1: Basic HTLC', color='#FF6B6B')
        ax.fill(angles, scores_v1, alpha=0.15, color='#FF6B6B')
        ax.plot(angles, scores_v2, 's-', linewidth=2, label='v2: Enhanced', color='#4ECDC4')
        ax.fill(angles, scores_v2, alpha=0.15, color='#4ECDC4')
        
        ax.set_thetagrids(np.degrees(angles[:-1]), categories, fontsize=9)
        ax.set_ylim(0, 10)
        ax.set_yticks([2, 4, 6, 8, 10])
        ax.set_title('Security Properties: Basic vs Enhanced Protocol', fontsize=14,
                     fontweight='bold', pad=30)
        ax.legend(loc='lower right', bbox_to_anchor=(1.2, -0.05), fontsize=11)
        
        plt.tight_layout()
        path3 = os.path.join(output_dir, 'security_radar.png')
        plt.savefig(path3, dpi=150, bbox_inches='tight')
        plt.close()
        print(f"  ✅ Saved: {path3}")
        
        # ── Chart 4: Protocol Timeline ──────────────────────────────────
        fig, ax = plt.subplots(figsize=(14, 5))
        
        events = [
            (0, 'Seller creates\nlisting', '#4CAF50', 'Seller'),
            (1, 'Buyer inspects\nlisting', '#2196F3', 'Buyer'),
            (2, 'Buyer funds\nescrow', '#2196F3', 'Buyer'),
            (3, 'Seller reveals\nkey K', '#4CAF50', 'Seller'),
            (3.3, 'Contract verifies\nhash(K)==H', '#FF9800', 'Contract'),
            (3.6, 'ETH transferred\nto Seller', '#FF9800', 'Contract'),
            (4, 'Buyer reads K\nfrom event', '#2196F3', 'Buyer'),
            (4.5, 'Buyer decrypts\nciphertext', '#2196F3', 'Buyer'),
        ]
        
        y_map = {'Seller': 2, 'Contract': 1, 'Buyer': 0}
        
        # Draw timeline
        ax.axhline(y=2, color='#4CAF50', alpha=0.3, lw=20, solid_capstyle='round')
        ax.axhline(y=1, color='#FF9800', alpha=0.3, lw=20, solid_capstyle='round')
        ax.axhline(y=0, color='#2196F3', alpha=0.3, lw=20, solid_capstyle='round')
        
        for t, label, color, actor in events:
            y = y_map[actor]
            ax.scatter(t, y, s=200, color=color, zorder=5, edgecolors='white', lw=2)
            ax.annotate(label, (t, y), textcoords="offset points",
                       xytext=(0, 25 if y != 1 else -35), ha='center', fontsize=8,
                       bbox=dict(boxstyle='round,pad=0.3', facecolor=color, alpha=0.2))
        
        # Timeout indicator
        ax.annotate('', xy=(5.5, 0.5), xytext=(2, 0.5),
                   arrowprops=dict(arrowstyle='<->', color='red', lw=2))
        ax.text(3.75, 0.7, 'TIMEOUT WINDOW\n(buyer refund eligible after expiry)',
               ha='center', fontsize=8, color='red', style='italic')
        
        ax.set_yticks([0, 1, 2])
        ax.set_yticklabels(['Buyer', 'Contract', 'Seller'], fontsize=12, fontweight='bold')
        ax.set_xlabel('Time →', fontsize=12)
        ax.set_title('Pay-to-Decrypt Protocol Timeline', fontsize=14, fontweight='bold')
        ax.set_xlim(-0.5, 6)
        ax.set_ylim(-0.8, 3)
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.set_xticks([])
        
        plt.tight_layout()
        path4 = os.path.join(output_dir, 'protocol_timeline.png')
        plt.savefig(path4, dpi=150, bbox_inches='tight')
        plt.close()
        print(f"  ✅ Saved: {path4}")
        
        return True
        
    except ImportError:
        print("  ⚠️  matplotlib not available — skipping PNG generation")
        print("     Install with: pip install matplotlib numpy")
        return False


# ═══════════════════════════════════════════════════════════════════════════════
#  MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main():
    print("\n" + "=" * 80)
    print("  PAY-TO-DECRYPT: Protocol Visualization Suite")
    print("=" * 80)
    
    print_sequence_diagram()
    print_state_machine()
    print_threat_model()
    print_gas_analysis()
    
    print("\n" + "=" * 80)
    print("  Generating matplotlib charts...")
    print("=" * 80)
    try_generate_matplotlib_charts()
    
    print("\n✅ All visualizations complete!\n")

if __name__ == '__main__':
    main()
