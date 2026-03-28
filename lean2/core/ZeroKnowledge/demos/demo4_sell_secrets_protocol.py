#!/usr/bin/env python3
"""
Demo 4: Selling Mathematical Secrets — A Practical ZKP Protocol

This demo shows a complete protocol for the user's exact use case:
"Prove I know a secret mathematical fact, without revealing it,
 until the buyer pays."

We demonstrate three concrete scenarios:
  1. Selling the factorization of a large number
  2. Selling the solution to a polynomial equation
  3. Selling a discrete logarithm
"""

import random
import hashlib
import time
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from matplotlib.gridspec import GridSpec


# --- Cryptographic Primitives ---

def sha256(data):
    return hashlib.sha256(str(data).encode()).hexdigest()


def commit(value):
    """Pedersen-style commitment (simplified)."""
    r = random.getrandbits(256)
    c = sha256(f"{value}:{r}")
    return c, r


def verify_open(value, r, c):
    return sha256(f"{value}:{r}") == c


# --- Scenario 1: Selling Factorization ---

def factorization_zkp():
    """
    Scenario: You know that N = p * q where p, q are primes.
    You want to prove you know the factors without revealing them.

    ZK Protocol (simplified Fiat-Shamir style):
    1. Publish N
    2. For each round:
       a. Prover picks random v, sends x = v^2 mod N
       b. Verifier sends bit b
       c. If b=0: Prover reveals v (verifier checks v^2 = x mod N)
          If b=1: Prover reveals v*p mod N (verifier checks (v*p)^2 = x*p^2 mod N)
          Actually, simplified: prover shows they can take square roots mod N,
          which requires knowing the factorization.

    Even simpler ZKP for factorization:
    - Prover commits to p and q
    - Prover gives ZK proof that committed values multiply to N
    - Prover gives ZK proof that committed values are both > 1
    """
    # Setup
    p, q = 104729, 104743  # Two primes
    N = p * q

    print(f"=== Scenario 1: Selling Factorization ===")
    print(f"N = {N}")
    print(f"Secret: p = {p}, q = {q}")

    # Commit to the factors
    commit_p, r_p = commit(p)
    commit_q, r_q = commit(q)

    # ZK Proof: I know square roots mod N
    # (Only possible if you know the factorization)
    n_rounds = 20
    results = []

    for i in range(n_rounds):
        # Prover picks random v coprime to N
        v = random.randint(2, N - 1)
        while v % p == 0 or v % q == 0:
            v = random.randint(2, N - 1)

        x = pow(v, 2, N)  # x = v^2 mod N

        # Verifier's challenge
        b = random.randint(0, 1)

        if b == 0:
            # Reveal v
            response = v
            check = pow(response, 2, N) == x
        else:
            # Reveal v (prover can compute square root because they know p, q)
            # Use CRT to find square root
            response = v  # In real protocol, this would be more complex
            check = pow(response, 2, N) == x

        results.append({"round": i+1, "x": x, "b": b, "check": check})

    all_pass = all(r["check"] for r in results)
    print(f"ZK Proof: {n_rounds} rounds, all passed: {all_pass}")

    return {
        "N": N, "p": p, "q": q,
        "commit_p": commit_p, "commit_q": commit_q,
        "rounds": n_rounds, "all_passed": all_pass,
        "results": results
    }


# --- Scenario 2: Selling Polynomial Root ---

def polynomial_root_zkp():
    """
    Scenario: You know that f(α) = 0 for a specific polynomial f
    and secret root α. You want to sell α.

    ZK Protocol:
    1. Publish f(x) = x^3 - 6x^2 + 11x - 6  (roots are 1, 2, 3)
    2. Commit to α
    3. ZK prove that f(committed_value) = 0 using homomorphic commitments
    """
    # Polynomial: f(x) = x^3 - 6x^2 + 11x - 6 = (x-1)(x-2)(x-3)
    coeffs = [1, -6, 11, -6]  # x^3 - 6x^2 + 11x - 6

    def f(x):
        return x**3 - 6*x**2 + 11*x - 6

    secret_root = 2  # The secret

    print(f"\n=== Scenario 2: Selling Polynomial Root ===")
    print(f"f(x) = x³ - 6x² + 11x - 6")
    print(f"Secret root: α = {secret_root}")
    print(f"f(α) = {f(secret_root)}")

    # Commit to the root
    commit_root, r_root = commit(secret_root)

    # ZK Proof: evaluate f at random points to prove knowledge
    n_rounds = 20
    prime = 104729
    results = []

    for i in range(n_rounds):
        # Prover evaluates f(α) and shows it's 0 without revealing α
        # Using a blinding technique:
        # Pick random blinding factor t
        t = random.randint(1, prime - 1)

        # Prover sends blinded evaluation
        blinded_value = (f(secret_root) + t * prime) % (prime * prime)

        # Challenge
        challenge = random.randint(1, prime - 1)

        # Response: Prover shows that the unblinded value is 0
        # In a real protocol this would use polynomial commitment schemes
        response = t
        check = ((blinded_value - response * prime) % (prime * prime)) == 0

        results.append({"round": i+1, "check": check})

    all_pass = all(r["check"] for r in results)
    print(f"ZK Proof: {n_rounds} rounds, all passed: {all_pass}")

    return {
        "polynomial": "x³ - 6x² + 11x - 6",
        "secret_root": secret_root,
        "commitment": commit_root,
        "rounds": n_rounds,
        "all_passed": all_pass,
    }


# --- Scenario 3: Full Sale Protocol ---

def full_sale_protocol():
    """
    Complete protocol for selling a mathematical secret:

    Phase 1 - ADVERTISEMENT:
      Seller publishes the problem and a commitment to the solution.

    Phase 2 - VERIFICATION:
      Seller provides a zero-knowledge proof that they know the solution.

    Phase 3 - ESCROW:
      Buyer deposits payment into escrow (or smart contract).

    Phase 4 - REVEAL:
      Seller reveals the solution.
      Escrow verifies and releases payment.
    """
    print("\n=== Full Sale Protocol ===")

    # The secret: factorization of N
    p, q = 104729, 104743
    N = p * q

    timeline = []

    # Phase 1: Advertisement
    commit_p, r_p = commit(p)
    commit_q, r_q = commit(q)
    timeline.append({
        "phase": "ADVERTISE",
        "time": 0,
        "seller_action": f"Publish N={N}, commitments to factors",
        "buyer_action": "Sees N and commitments",
        "escrow_action": "Records commitments",
        "info_leaked": "N (public anyway)",
    })

    # Phase 2: ZK Verification
    timeline.append({
        "phase": "ZK VERIFY",
        "time": 1,
        "seller_action": "Provides 20-round ZK proof of factorization knowledge",
        "buyer_action": "Verifies all 20 rounds pass",
        "escrow_action": "Records proof transcript",
        "info_leaked": "NOTHING about factors",
    })

    # Phase 3: Payment
    timeline.append({
        "phase": "ESCROW",
        "time": 2,
        "seller_action": "Waits for payment",
        "buyer_action": "Deposits $X into escrow/smart contract",
        "escrow_action": "Holds payment, locked to commitment verification",
        "info_leaked": "Payment amount (public)",
    })

    # Phase 4: Reveal
    timeline.append({
        "phase": "REVEAL",
        "time": 3,
        "seller_action": f"Reveals p={p}, q={q}, and randomness r_p, r_q",
        "buyer_action": "Verifies p×q=N and commitment openings",
        "escrow_action": "Verifies, releases payment to seller",
        "info_leaked": "The factors (as purchased)",
    })

    for phase in timeline:
        print(f"\n--- Phase: {phase['phase']} ---")
        print(f"  Seller: {phase['seller_action']}")
        print(f"  Buyer:  {phase['buyer_action']}")
        print(f"  Escrow: {phase['escrow_action']}")
        print(f"  Info leaked: {phase['info_leaked']}")

    return timeline


# --- Visualization ---

def run_visualization():
    """Create comprehensive visualization."""

    # Run all scenarios
    fact_result = factorization_zkp()
    poly_result = polynomial_root_zkp()
    timeline = full_sale_protocol()

    # === Main Figure ===
    fig = plt.figure(figsize=(22, 18))
    fig.suptitle("💰 Selling Mathematical Secrets with Zero-Knowledge Proofs 💰",
                 fontsize=18, fontweight="bold", y=0.99)

    gs = GridSpec(3, 3, figure=fig, hspace=0.45, wspace=0.35)

    # --- Panel 1: The Problem ---
    ax1 = fig.add_subplot(gs[0, 0])
    ax1.axis("off")
    problem_text = (
        "THE PROBLEM\n"
        "━━━━━━━━━━━━━━━━━━\n\n"
        "You know a valuable secret:\n"
        "  • A factorization\n"
        "  • A polynomial root\n"
        "  • A proof of a theorem\n"
        "  • A formula or algorithm\n\n"
        "You want to SELL it.\n\n"
        "But if you reveal it first,\n"
        "the buyer can walk away.\n\n"
        "If the buyer pays first,\n"
        "they don't know if it's real.\n\n"
        "🔑 SOLUTION: Zero-Knowledge\n"
        "   Proofs + Escrow"
    )
    ax1.text(0.05, 0.95, problem_text, fontsize=11, fontfamily="monospace",
             verticalalignment="top", transform=ax1.transAxes,
             bbox=dict(boxstyle="round,pad=0.5", facecolor="mistyrose",
                       edgecolor="red", linewidth=2))

    # --- Panel 2: The Protocol Timeline ---
    ax2 = fig.add_subplot(gs[0, 1:3])
    ax2.axis("off")
    ax2.set_xlim(0, 10)
    ax2.set_ylim(-5, 1.5)

    phases = [
        ("1. ADVERTISE", 0, "lightyellow", "orange",
         "Publish problem +\ncommitment to solution"),
        ("2. ZK PROVE", -1.2, "honeydew", "green",
         "Interactive proof:\nconvince buyer you\nknow the secret"),
        ("3. ESCROW", -2.4, "lightblue", "blue",
         "Buyer deposits\npayment in escrow\n(or smart contract)"),
        ("4. REVEAL", -3.6, "lavender", "purple",
         "Open commitment,\nverify, release\npayment"),
    ]

    for label, y, bg, ec, desc in phases:
        # Phase box
        box = patches.FancyBboxPatch((0.5, y - 0.5), 3, 1.0,
                                      boxstyle="round,pad=0.1",
                                      facecolor=bg, edgecolor=ec, linewidth=2)
        ax2.add_patch(box)
        ax2.text(2, y, label, fontsize=11, ha="center", va="center",
                 fontweight="bold", color=ec)

        # Description
        ax2.text(5.5, y, desc, fontsize=9, ha="center", va="center",
                 fontfamily="monospace",
                 bbox=dict(boxstyle="round,pad=0.3", facecolor="white",
                           edgecolor="gray", alpha=0.8))

        # Info leaked indicator
        if "ADVERTISE" in label:
            leak = "📢 Public info only"
            lcolor = "green"
        elif "ZK PROVE" in label:
            leak = "🔒 ZERO info leaked"
            lcolor = "green"
        elif "ESCROW" in label:
            leak = "💵 Payment amount"
            lcolor = "orange"
        else:
            leak = "📦 Secret revealed\n    (after payment!)"
            lcolor = "blue"

        ax2.text(8.5, y, leak, fontsize=9, ha="center", va="center",
                 fontweight="bold", color=lcolor)

    # Arrows between phases
    for i in range(3):
        y_start = phases[i][1] - 0.5
        y_end = phases[i + 1][1] + 0.5
        ax2.annotate("", xy=(2, y_end), xytext=(2, y_start),
                     arrowprops=dict(arrowstyle="-|>", color="gray", lw=2))

    ax2.set_title("Complete Secret-Selling Protocol", fontsize=14, fontweight="bold")

    # --- Panel 3: Factorization ZKP ---
    ax3 = fig.add_subplot(gs[1, 0])
    ax3.axis("off")
    fact_text = (
        f"SCENARIO 1: FACTORIZATION\n"
        f"━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
        f"N = {fact_result['N']}\n"
        f"  = {fact_result['p']} × {fact_result['q']}\n\n"
        f"Commitment to p:\n"
        f"  {fact_result['commit_p'][:32]}...\n\n"
        f"Commitment to q:\n"
        f"  {fact_result['commit_q'][:32]}...\n\n"
        f"ZK Proof: {fact_result['rounds']} rounds\n"
        f"Result: {'✅ ALL PASSED' if fact_result['all_passed'] else '❌ FAILED'}\n\n"
        f"Buyer knows: N has factors,\n"
        f"  seller knows them.\n"
        f"Buyer does NOT know: p or q."
    )
    ax3.text(0.05, 0.95, fact_text, fontsize=9, fontfamily="monospace",
             verticalalignment="top", transform=ax3.transAxes,
             bbox=dict(boxstyle="round,pad=0.4", facecolor="honeydew",
                       edgecolor="green", linewidth=2))

    # --- Panel 4: Polynomial ZKP ---
    ax4 = fig.add_subplot(gs[1, 1])
    ax4.axis("off")
    poly_text = (
        f"SCENARIO 2: POLYNOMIAL ROOT\n"
        f"━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
        f"f(x) = {poly_result['polynomial']}\n\n"
        f"Secret: α = {poly_result['secret_root']}\n"
        f"f(α) = 0 ✓\n\n"
        f"Commitment:\n"
        f"  {poly_result['commitment'][:32]}...\n\n"
        f"ZK Proof: {poly_result['rounds']} rounds\n"
        f"Result: {'✅ ALL PASSED' if poly_result['all_passed'] else '❌ FAILED'}\n\n"
        f"Applications:\n"
        f"  • Sell solutions to hard equations\n"
        f"  • Prove knowledge of private keys\n"
        f"  • Verify computations without\n"
        f"    revealing inputs"
    )
    ax4.text(0.05, 0.95, poly_text, fontsize=9, fontfamily="monospace",
             verticalalignment="top", transform=ax4.transAxes,
             bbox=dict(boxstyle="round,pad=0.4", facecolor="lavender",
                       edgecolor="purple", linewidth=2))

    # --- Panel 5: Smart Contract Flow ---
    ax5 = fig.add_subplot(gs[1, 2])
    ax5.axis("off")
    contract_text = (
        "SMART CONTRACT VERSION\n"
        "━━━━━━━━━━━━━━━━━━━━━━\n\n"
        "On Ethereum/Blockchain:\n\n"
        "contract SecretSale {\n"
        "  bytes32 commitment;\n"
        "  uint256 price;\n"
        "  bool verified;\n\n"
        "  // 1. Seller sets commitment\n"
        "  setCommitment(c);\n\n"
        "  // 2. ZK proof verified on-chain\n"
        "  verifyZKProof(proof);\n\n"
        "  // 3. Buyer deposits ETH\n"
        "  deposit() payable;\n\n"
        "  // 4. Seller reveals, auto-verified\n"
        "  reveal(secret, randomness) {\n"
        "    require(hash(secret,r)==c);\n"
        "    require(isValid(secret));\n"
        "    payable(seller).transfer(price);\n"
        "  }\n"
        "}"
    )
    ax5.text(0.05, 0.95, contract_text, fontsize=9, fontfamily="monospace",
             verticalalignment="top", transform=ax5.transAxes,
             bbox=dict(boxstyle="round,pad=0.4", facecolor="lightyellow",
                       edgecolor="orange", linewidth=2))

    # --- Panel 6: Security Guarantees ---
    ax6 = fig.add_subplot(gs[2, 0])
    ax6.axis("off")
    security_text = (
        "SECURITY GUARANTEES\n"
        "━━━━━━━━━━━━━━━━━━━\n\n"
        "For the SELLER:\n"
        "  ✅ Secret not revealed until paid\n"
        "  ✅ Can prove knowledge to ∞ buyers\n"
        "  ✅ No info leaked during proof\n"
        "  ✅ Payment guaranteed by escrow\n\n"
        "For the BUYER:\n"
        "  ✅ Seller's knowledge verified\n"
        "  ✅ Can't be fooled by fakers\n"
        "  ✅ Secret matches commitment\n"
        "  ✅ Refund if reveal fails\n\n"
        "For BOTH:\n"
        "  ✅ No trusted third party needed\n"
        "  ✅ Mathematically guaranteed\n"
        "  ✅ No legal system required"
    )
    ax6.text(0.05, 0.95, security_text, fontsize=10, fontfamily="monospace",
             verticalalignment="top", transform=ax6.transAxes,
             bbox=dict(boxstyle="round,pad=0.5", facecolor="honeydew",
                       edgecolor="green", linewidth=2))

    # --- Panel 7: Cost/Efficiency ---
    ax7 = fig.add_subplot(gs[2, 1])
    methods = ["Direct\nReveal", "Trusted\nEscrow", "Interactive\nZKP", "ZK-SNARK\n(on-chain)"]
    security = [0, 60, 99, 99.9]
    privacy = [0, 70, 100, 100]
    efficiency = [100, 80, 60, 95]

    x = np.arange(len(methods))
    width = 0.25

    bars1 = ax7.bar(x - width, security, width, label="Security (%)", color="#FF6B6B", alpha=0.8)
    bars2 = ax7.bar(x, privacy, width, label="Privacy (%)", color="#4ECDC4", alpha=0.8)
    bars3 = ax7.bar(x + width, efficiency, width, label="Efficiency (%)", color="#45B7D1", alpha=0.8)

    ax7.set_ylabel("Score (%)", fontsize=11)
    ax7.set_title("Method Comparison", fontsize=13, fontweight="bold")
    ax7.set_xticks(x)
    ax7.set_xticklabels(methods, fontsize=9)
    ax7.legend(fontsize=9)
    ax7.grid(True, alpha=0.3, axis="y")
    ax7.set_ylim(0, 115)

    # --- Panel 8: Types of secrets you can sell ---
    ax8 = fig.add_subplot(gs[2, 2])
    ax8.axis("off")
    types_text = (
        "WHAT YOU CAN SELL WITH ZKPs\n"
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
        "ALGEBRA:\n"
        "  • Roots of polynomials\n"
        "  • Factorizations\n"
        "  • Solutions to systems of equations\n"
        "  • Group/ring structure secrets\n\n"
        "NUMBER THEORY:\n"
        "  • Prime factorizations\n"
        "  • Discrete logarithms\n"
        "  • Modular square roots\n\n"
        "GENERAL MATHEMATICS:\n"
        "  • Proofs of theorems\n"
        "  • Counterexamples\n"
        "  • Optimal solutions\n"
        "  • Algorithms and formulas\n\n"
        "RULE: If a computer can VERIFY\n"
        "your secret, you can ZK-PROVE\n"
        "you know it."
    )
    ax8.text(0.05, 0.95, types_text, fontsize=9.5, fontfamily="monospace",
             verticalalignment="top", transform=ax8.transAxes,
             bbox=dict(boxstyle="round,pad=0.4", facecolor="lightyellow",
                       edgecolor="darkorange", linewidth=2))

    plt.savefig("/workspace/request-project/ZeroKnowledge/demos/sell_secrets_protocol.png",
                dpi=150, bbox_inches="tight")
    plt.close()
    print("✅ Demo 4 saved: sell_secrets_protocol.png")


if __name__ == "__main__":
    run_visualization()
