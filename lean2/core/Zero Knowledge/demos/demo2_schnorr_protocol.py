#!/usr/bin/env python3
"""
Demo 2: Schnorr Zero-Knowledge Proof Protocol — Interactive Visualization

The Schnorr protocol allows a Prover to convince a Verifier that they know
the discrete logarithm x of h = g^x mod p, without revealing x.

Protocol:
  Setup: Public (p, g, h) where h = g^x mod p, secret x.
  1. Prover picks random r, sends commitment t = g^r mod p
  2. Verifier sends random challenge c
  3. Prover sends response s = r + c*x (mod q, where q | p-1)
  4. Verifier checks: g^s ≡ t * h^c (mod p)

This demo shows:
  - The protocol execution step by step
  - Why a faker (who doesn't know x) gets caught
  - The simulator that proves zero-knowledge
"""

import random
import hashlib
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from matplotlib.gridspec import GridSpec


# --- Schnorr Protocol Implementation ---

def generate_schnorr_params(bits=32):
    """Generate safe Schnorr parameters (small for demo purposes)."""
    # For demonstration, use well-known small safe prime
    # In practice, use 2048+ bit primes
    q = 104729  # A prime
    p = 2 * q + 1  # 209459, check if prime
    # Find a generator of the subgroup of order q
    for g_candidate in range(2, p):
        if pow(g_candidate, 2, p) != 1 and pow(g_candidate, q, p) == 1:
            g = g_candidate
            break
    return p, q, g


def schnorr_keygen(p, q, g):
    """Generate a Schnorr key pair."""
    x = random.randint(1, q - 1)  # Secret key
    h = pow(g, x, p)              # Public key
    return x, h


def schnorr_prove_step1(p, q, g):
    """Prover's first step: generate commitment."""
    r = random.randint(1, q - 1)  # Random nonce
    t = pow(g, r, p)              # Commitment
    return r, t


def schnorr_verify_challenge(q):
    """Verifier generates a random challenge."""
    c = random.randint(1, q - 1)
    return c


def schnorr_prove_step2(r, c, x, q):
    """Prover's response."""
    s = (r + c * x) % q
    return s


def schnorr_verify(g, h, t, c, s, p):
    """Verifier checks the proof."""
    lhs = pow(g, s, p)
    rhs = (t * pow(h, c, p)) % p
    return lhs == rhs


def schnorr_simulator(g, h, p, q):
    """
    The Simulator: proves zero-knowledge property.
    Creates a valid-looking transcript WITHOUT knowing the secret x.

    Trick: Choose s and c first, then compute t = g^s * h^(-c) mod p.
    The resulting (t, c, s) is indistinguishable from a real transcript.
    """
    s = random.randint(1, q - 1)
    c = random.randint(1, q - 1)
    h_inv_c = pow(h, q - c, p)  # h^(-c) mod p = h^(q-c) mod p
    t = (pow(g, s, p) * h_inv_c) % p
    return t, c, s


# --- Faker who doesn't know x ---

def faker_prove_step1(p, q, g):
    """Faker also generates a random commitment (same as honest)."""
    r = random.randint(1, q - 1)
    t = pow(g, r, p)
    return r, t


def faker_prove_step2(r, c, q):
    """Faker doesn't know x, so just returns s = r (ignoring c·x)."""
    # The faker can only succeed if c = 0, which almost never happens
    s = r  # Missing the c*x term!
    return s


# --- Visualization ---

def draw_protocol_diagram(ax, title, steps, success, color_scheme):
    """Draw a message-sequence diagram of the protocol."""
    ax.set_xlim(0, 10)
    ax.set_ylim(-len(steps) - 1, 2)
    ax.axis("off")

    # Draw Prover and Verifier columns
    prover_x, verifier_x = 2, 8

    ax.text(prover_x, 1.5, "PROVER", fontsize=12, ha="center", fontweight="bold",
            color=color_scheme["prover"],
            bbox=dict(boxstyle="round,pad=0.3", facecolor=color_scheme["prover_bg"]))
    ax.text(verifier_x, 1.5, "VERIFIER", fontsize=12, ha="center", fontweight="bold",
            color=color_scheme["verifier"],
            bbox=dict(boxstyle="round,pad=0.3", facecolor=color_scheme["verifier_bg"]))

    # Draw vertical lifelines
    ax.plot([prover_x, prover_x], [1.0, -len(steps) - 0.5], "--",
            color=color_scheme["prover"], alpha=0.4, linewidth=1)
    ax.plot([verifier_x, verifier_x], [1.0, -len(steps) - 0.5], "--",
            color=color_scheme["verifier"], alpha=0.4, linewidth=1)

    for i, step in enumerate(steps):
        y = -i
        direction = step["direction"]
        label = step["label"]
        detail = step.get("detail", "")

        if direction == "right":
            ax.annotate("", xy=(verifier_x - 0.5, y), xytext=(prover_x + 0.5, y),
                         arrowprops=dict(arrowstyle="-|>", color=color_scheme["arrow"],
                                          lw=2, mutation_scale=15))
            ax.text(5, y + 0.25, label, fontsize=10, ha="center", fontweight="bold",
                    color=color_scheme["arrow"])
            if detail:
                ax.text(5, y - 0.25, detail, fontsize=7, ha="center",
                        color="gray", style="italic")
        elif direction == "left":
            ax.annotate("", xy=(prover_x + 0.5, y), xytext=(verifier_x - 0.5, y),
                         arrowprops=dict(arrowstyle="-|>", color=color_scheme["challenge"],
                                          lw=2, mutation_scale=15))
            ax.text(5, y + 0.25, label, fontsize=10, ha="center", fontweight="bold",
                    color=color_scheme["challenge"])
            if detail:
                ax.text(5, y - 0.25, detail, fontsize=7, ha="center",
                        color="gray", style="italic")
        elif direction == "check":
            result_str = "✅ ACCEPT" if success else "❌ REJECT"
            result_color = "green" if success else "red"
            ax.text(verifier_x, y, result_str, fontsize=11, ha="center",
                    fontweight="bold", color=result_color,
                    bbox=dict(boxstyle="round,pad=0.2", facecolor="lightyellow",
                              edgecolor=result_color, linewidth=2))
            if detail:
                ax.text(verifier_x, y - 0.4, detail, fontsize=7, ha="center", color="gray")

    ax.set_title(title, fontsize=13, fontweight="bold", pad=10)


def run_visualization():
    """Run the full Schnorr protocol visualization."""
    # Generate parameters
    p, q, g = generate_schnorr_params()
    x, h = schnorr_keygen(p, q, g)

    print(f"Parameters: p={p}, q={q}, g={g}")
    print(f"Secret key: x={x}")
    print(f"Public key:  h=g^x mod p = {h}")

    # === Run honest protocol ===
    r, t = schnorr_prove_step1(p, q, g)
    c = schnorr_verify_challenge(q)
    s = schnorr_prove_step2(r, c, x, q)
    honest_ok = schnorr_verify(g, h, t, c, s, p)
    print(f"\nHonest protocol: t={t}, c={c}, s={s}, verify={honest_ok}")

    # === Run faker protocol ===
    r_f, t_f = faker_prove_step1(p, q, g)
    c_f = schnorr_verify_challenge(q)
    s_f = faker_prove_step2(r_f, c_f, q)
    faker_ok = schnorr_verify(g, h, t_f, c_f, s_f, p)
    print(f"Faker protocol:  t={t_f}, c={c_f}, s={s_f}, verify={faker_ok}")

    # === Run simulator ===
    t_s, c_s, s_s = schnorr_simulator(g, h, p, q)
    sim_ok = schnorr_verify(g, h, t_s, c_s, s_s, p)
    print(f"Simulator:       t={t_s}, c={c_s}, s={s_s}, verify={sim_ok}")

    # === Visualization ===
    fig = plt.figure(figsize=(20, 16))
    fig.suptitle("Schnorr Zero-Knowledge Proof Protocol", fontsize=18, fontweight="bold", y=0.98)

    gs = GridSpec(2, 3, figure=fig, hspace=0.4, wspace=0.3)

    # --- Panel 1: Honest Prover ---
    ax1 = fig.add_subplot(gs[0, 0])
    honest_steps = [
        {"direction": "right", "label": f"t = g^r mod p = {t}",
         "detail": f"(random r={r})"},
        {"direction": "left", "label": f"challenge c = {c}", "detail": "(random)"},
        {"direction": "right", "label": f"s = r + c·x mod q = {s}",
         "detail": f"({r} + {c}·{x} mod {q})"},
        {"direction": "check", "label": "", "detail": f"g^s = {pow(g,s,p)}, t·h^c = {(t*pow(h,c,p))%p}"},
    ]
    draw_protocol_diagram(ax1, "Honest Prover (knows x)", honest_steps, honest_ok,
                          {"prover": "navy", "prover_bg": "lightblue",
                           "verifier": "darkred", "verifier_bg": "mistyrose",
                           "arrow": "navy", "challenge": "darkred"})

    # --- Panel 2: Faker ---
    ax2 = fig.add_subplot(gs[0, 1])
    faker_steps = [
        {"direction": "right", "label": f"t = g^r mod p = {t_f}",
         "detail": f"(random r={r_f})"},
        {"direction": "left", "label": f"challenge c = {c_f}", "detail": "(random)"},
        {"direction": "right", "label": f"s = r = {s_f}",
         "detail": f"(doesn't know x, omits c·x!)"},
        {"direction": "check", "label": "",
         "detail": f"g^s = {pow(g,s_f,p)}, t·h^c = {(t_f*pow(h,c_f,p))%p}"},
    ]
    draw_protocol_diagram(ax2, "Faker (doesn't know x)", faker_steps, faker_ok,
                          {"prover": "darkred", "prover_bg": "lightyellow",
                           "verifier": "darkred", "verifier_bg": "mistyrose",
                           "arrow": "darkred", "challenge": "darkred"})

    # --- Panel 3: Simulator (proves zero-knowledge) ---
    ax3 = fig.add_subplot(gs[0, 2])
    sim_steps = [
        {"direction": "right", "label": f"t = g^s·h^(−c) = {t_s}",
         "detail": "(computed BACKWARDS)"},
        {"direction": "left", "label": f"challenge c = {c_s}",
         "detail": "(chosen by simulator)"},
        {"direction": "right", "label": f"s = {s_s}",
         "detail": "(chosen first, randomly)"},
        {"direction": "check", "label": "",
         "detail": "Always passes! (by construction)"},
    ]
    draw_protocol_diagram(ax3, "Simulator (no secret, fakes transcript)", sim_steps, sim_ok,
                          {"prover": "purple", "prover_bg": "lavender",
                           "verifier": "purple", "verifier_bg": "lavender",
                           "arrow": "purple", "challenge": "purple"})

    # --- Panel 4: Completeness proof ---
    ax4 = fig.add_subplot(gs[1, 0])
    ax4.axis("off")
    proof_text = (
        "COMPLETENESS PROOF\n"
        "━━━━━━━━━━━━━━━━━━\n\n"
        "Claim: If Prover knows x, Verifier\n"
        "always accepts.\n\n"
        "Proof:\n"
        "  Verifier checks: g^s ≡ t · h^c (mod p)\n\n"
        "  LHS = g^s = g^(r + c·x)\n"
        "      = g^r · g^(c·x)\n"
        "      = g^r · (g^x)^c\n"
        "      = t · h^c\n"
        "      = RHS  ✓\n\n"
        "  ∴ Honest prover ALWAYS passes.  □"
    )
    ax4.text(0.05, 0.95, proof_text, fontsize=10, fontfamily="monospace",
             verticalalignment="top", transform=ax4.transAxes,
             bbox=dict(boxstyle="round,pad=0.5", facecolor="honeydew",
                       edgecolor="green", linewidth=2))

    # --- Panel 5: Soundness proof ---
    ax5 = fig.add_subplot(gs[1, 1])
    ax5.axis("off")
    sound_text = (
        "SOUNDNESS (EXTRACTION)\n"
        "━━━━━━━━━━━━━━━━━━━━━━\n\n"
        "Claim: Two accepting transcripts\n"
        "with same t reveal x.\n\n"
        "Given: (t, c₁, s₁) and (t, c₂, s₂)\n"
        "  both accepted, c₁ ≠ c₂.\n\n"
        "Then:\n"
        "  g^s₁ = t · h^c₁\n"
        "  g^s₂ = t · h^c₂\n\n"
        "Dividing:\n"
        "  g^(s₁−s₂) = h^(c₁−c₂)\n"
        "  g^(s₁−s₂) = g^(x·(c₁−c₂))\n\n"
        "  ∴ x = (s₁−s₂)/(c₁−c₂) mod q\n\n"
        "  The secret is EXTRACTED.  □"
    )
    ax5.text(0.05, 0.95, sound_text, fontsize=10, fontfamily="monospace",
             verticalalignment="top", transform=ax5.transAxes,
             bbox=dict(boxstyle="round,pad=0.5", facecolor="lavenderblush",
                       edgecolor="red", linewidth=2))

    # --- Panel 6: Zero-Knowledge proof ---
    ax6 = fig.add_subplot(gs[1, 2])
    ax6.axis("off")
    zk_text = (
        "ZERO-KNOWLEDGE (SIMULATION)\n"
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
        "Claim: Transcripts leak NOTHING\n"
        "about x.\n\n"
        "Proof: A Simulator (knowing only h,\n"
        "NOT x) can produce transcripts\n"
        "indistinguishable from real ones.\n\n"
        "Simulator algorithm:\n"
        "  1. Pick random s, c\n"
        "  2. Set t = g^s · h^(−c) mod p\n"
        "  3. Output (t, c, s)\n\n"
        "Verification:\n"
        "  g^s = g^s · h^(−c) · h^c\n"
        "      = t · h^c  ✓\n\n"
        "Both distributions are uniform\n"
        "over valid transcripts.\n"
        "∴ No information about x leaks.  □"
    )
    ax6.text(0.05, 0.95, zk_text, fontsize=10, fontfamily="monospace",
             verticalalignment="top", transform=ax6.transAxes,
             bbox=dict(boxstyle="round,pad=0.5", facecolor="lavender",
                       edgecolor="purple", linewidth=2))

    plt.savefig("/workspace/request-project/ZeroKnowledge/demos/schnorr_protocol.png",
                dpi=150, bbox_inches="tight")
    plt.close()
    print("✅ Demo 2 saved: schnorr_protocol.png")

    # === Distribution comparison ===
    fig2, axes = plt.subplots(1, 3, figsize=(18, 5))
    fig2.suptitle("Real vs Simulated Transcript Distributions (Proving Zero-Knowledge)",
                  fontsize=14, fontweight="bold")

    n_samples = 5000

    # Generate real transcripts
    real_ts, real_cs, real_ss = [], [], []
    for _ in range(n_samples):
        r, t = schnorr_prove_step1(p, q, g)
        c = schnorr_verify_challenge(q)
        s = schnorr_prove_step2(r, c, x, q)
        real_ts.append(t)
        real_cs.append(c)
        real_ss.append(s)

    # Generate simulated transcripts
    sim_ts, sim_cs, sim_ss = [], [], []
    for _ in range(n_samples):
        t, c, s = schnorr_simulator(g, h, p, q)
        sim_ts.append(t)
        sim_cs.append(c)
        sim_ss.append(s)

    for ax, real_data, sim_data, label in [
        (axes[0], real_ts, sim_ts, "Commitment t"),
        (axes[1], real_cs, sim_cs, "Challenge c"),
        (axes[2], real_ss, sim_ss, "Response s"),
    ]:
        ax.hist(real_data, bins=50, alpha=0.5, label="Real", color="blue", density=True)
        ax.hist(sim_data, bins=50, alpha=0.5, label="Simulated", color="red", density=True)
        ax.set_title(f"Distribution of {label}", fontsize=12, fontweight="bold")
        ax.legend(fontsize=10)
        ax.set_xlabel("Value", fontsize=10)
        ax.set_ylabel("Density", fontsize=10)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig2.savefig("/workspace/request-project/ZeroKnowledge/demos/schnorr_distributions.png",
                 dpi=150, bbox_inches="tight")
    plt.close()
    print("✅ Demo 2b saved: schnorr_distributions.png")


if __name__ == "__main__":
    run_visualization()
