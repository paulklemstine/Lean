#!/usr/bin/env python3
"""
Demo 3: Graph 3-Coloring Zero-Knowledge Proof — The Universal ZKP

This is the most important ZKP construction because:
  Theorem (GMW 1986): Every problem in NP can be proven in zero-knowledge
  by reducing it to graph 3-coloring.

Protocol:
  1. Prover has a valid 3-coloring of graph G.
  2. Each round:
     a. Prover randomly permutes the 3 colors (relabeling).
     b. Prover commits to each vertex's (permuted) color using a hiding commitment.
     c. Verifier picks a random edge (u, v).
     d. Prover opens commitments for u and v.
     e. Verifier checks: the two colors are different AND each is a valid color.

  After enough rounds, Verifier is convinced the coloring is valid,
  but learns NOTHING about which vertices have which colors.
"""

import random
import hashlib
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
import networkx as nx
from matplotlib.gridspec import GridSpec


# --- Commitment Scheme ---

def commit(value, randomness=None):
    """Hash-based commitment: binding and hiding."""
    if randomness is None:
        randomness = random.getrandbits(256)
    data = f"{value}:{randomness}".encode()
    return hashlib.sha256(data).hexdigest(), randomness


def verify_commitment(value, randomness, commitment):
    """Verify a commitment opening."""
    data = f"{value}:{randomness}".encode()
    return hashlib.sha256(data).hexdigest() == commitment


# --- Graph 3-Coloring ZKP ---

def create_demo_graph():
    """Create a demo graph with a known 3-coloring."""
    # Petersen graph — a classic graph theory example
    G = nx.petersen_graph()
    # Find a valid 3-coloring
    coloring = nx.coloring.greedy_color(G, strategy="largest_first")
    # Ensure it's a 3-coloring (Petersen graph is 3-chromatic)
    return G, coloring


def zkp_round(G, true_coloring):
    """Execute one round of the graph 3-coloring ZKP."""

    # Step 1: Prover randomly permutes the colors
    color_perm = list(range(3))
    random.shuffle(color_perm)
    permuted_coloring = {v: color_perm[true_coloring[v]] for v in G.nodes()}

    # Step 2: Prover commits to each vertex's permuted color
    commitments = {}
    openings = {}
    for v in G.nodes():
        c, r = commit(permuted_coloring[v])
        commitments[v] = c
        openings[v] = (permuted_coloring[v], r)

    # Step 3: Verifier picks a random edge
    edges = list(G.edges())
    edge = random.choice(edges)
    u, v = edge

    # Step 4: Prover opens commitments for u and v
    color_u, rand_u = openings[u]
    color_v, rand_v = openings[v]

    # Step 5: Verifier checks
    commit_u_ok = verify_commitment(color_u, rand_u, commitments[u])
    commit_v_ok = verify_commitment(color_v, rand_v, commitments[v])
    colors_different = (color_u != color_v)
    colors_valid = (color_u in [0, 1, 2]) and (color_v in [0, 1, 2])

    success = commit_u_ok and commit_v_ok and colors_different and colors_valid

    return {
        "edge": (u, v),
        "color_u": color_u,
        "color_v": color_v,
        "success": success,
        "permuted_coloring": permuted_coloring,
        "commitments_opened": {u: color_u, v: color_v},
    }


def run_full_zkp(G, coloring, n_rounds=50):
    """Run the full ZKP protocol for n rounds."""
    results = []
    for i in range(n_rounds):
        result = zkp_round(G, coloring)
        results.append(result)
        if not result["success"]:
            return results, False
    return results, True


# --- Visualization ---

def draw_graph_round(ax, G, coloring, round_result, round_num, show_colors=False):
    """Draw a graph with the ZKP round result."""
    pos = nx.spring_layout(G, seed=42)

    color_map_palette = {0: "#FF6B6B", 1: "#4ECDC4", 2: "#45B7D1"}

    # Draw edges
    edge_colors = []
    edge_widths = []
    for e in G.edges():
        if set(e) == set(round_result["edge"]):
            edge_colors.append("gold")
            edge_widths.append(4)
        else:
            edge_colors.append("lightgray")
            edge_widths.append(1)

    nx.draw_edges = nx.draw_networkx_edges(G, pos, ax=ax,
                                            edge_color=edge_colors,
                                            width=edge_widths)

    # Draw nodes
    u, v = round_result["edge"]
    for node in G.nodes():
        x, y = pos[node]
        if show_colors:
            color = color_map_palette[round_result["permuted_coloring"][node]]
        elif node == u or node == v:
            color = color_map_palette[round_result["commitments_opened"][node]]
        else:
            color = "lightgray"  # Hidden (committed)

        circle = plt.Circle((x, y), 0.08, color=color, ec="black", linewidth=1.5, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, str(node), fontsize=8, ha="center", va="center",
                fontweight="bold", zorder=6)

    # Highlight the challenged edge
    ax.set_title(f"Round {round_num}: Edge ({u},{v})\n"
                 f"Colors: {round_result['color_u']}≠{round_result['color_v']} "
                 f"{'✅' if round_result['success'] else '❌'}",
                 fontsize=10, fontweight="bold")

    ax.set_xlim(-1.3, 1.3)
    ax.set_ylim(-1.3, 1.3)
    ax.set_aspect("equal")
    ax.axis("off")


def run_visualization():
    """Create the full visualization."""
    G, coloring = create_demo_graph()

    print(f"Graph: {G.number_of_nodes()} nodes, {G.number_of_edges()} edges")
    print(f"Chromatic number: 3 (Petersen graph)")
    print(f"Coloring: {coloring}")

    # Run protocol
    results, all_passed = run_full_zkp(G, coloring, n_rounds=50)

    # === Figure 1: Protocol rounds ===
    fig = plt.figure(figsize=(20, 16))
    fig.suptitle("Graph 3-Coloring Zero-Knowledge Proof\n"
                 "(Universal: ANY NP problem reduces to this)",
                 fontsize=16, fontweight="bold", y=0.99)

    gs = GridSpec(3, 4, figure=fig, hspace=0.5, wspace=0.3)

    # Show 8 rounds
    for i in range(min(8, len(results))):
        row, col = divmod(i, 4)
        ax = fig.add_subplot(gs[row, col])
        draw_graph_round(ax, G, coloring, results[i], i + 1)

    # Panel: What the verifier learns
    ax_info = fig.add_subplot(gs[2, 0:2])
    ax_info.axis("off")
    info_text = (
        "WHAT THE VERIFIER LEARNS\n"
        "━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
        "Each round, the Verifier sees:\n"
        "  • Two colors of ONE edge (out of 15 edges)\n"
        "  • A DIFFERENT random permutation each round\n\n"
        "The Verifier NEVER sees:\n"
        "  • The full coloring\n"
        "  • Any consistent partial coloring\n"
        "  • Which original color maps to which\n\n"
        "After 50 rounds:\n"
        f"  • Confidence: {1 - (1 - 1/G.number_of_edges())**50:.10f}\n"
        f"  • Faker detection: {(1 - 1/G.number_of_edges())**50:.2e}\n\n"
        "KEY INSIGHT: Random permutation each round\n"
        "means no two rounds' colors are correlated!"
    )
    ax_info.text(0.05, 0.95, info_text, fontsize=10, fontfamily="monospace",
                 verticalalignment="top", transform=ax_info.transAxes,
                 bbox=dict(boxstyle="round,pad=0.5", facecolor="lightyellow",
                           edgecolor="orange", linewidth=2))

    # Panel: Why this is universal
    ax_univ = fig.add_subplot(gs[2, 2:4])
    ax_univ.axis("off")
    univ_text = (
        "WHY THIS IS UNIVERSAL (GMW Theorem)\n"
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
        "Graph 3-coloring is NP-complete.\n"
        "Any NP problem can be reduced to it.\n\n"
        "Examples:\n"
        "  • 'I know the factors of N'\n"
        "    → Encode as 3-coloring, ZK-prove it\n\n"
        "  • 'I know a proof of Theorem X'\n"
        "    → Encode proof verification as circuit\n"
        "    → Convert circuit to graph\n"
        "    → 3-color the graph, ZK-prove it\n\n"
        "  • 'My committed value satisfies property P'\n"
        "    → Encode P-check as 3-coloring\n\n"
        "This is why ZKPs are UNIVERSAL:\n"
        "anything efficiently verifiable can be\n"
        "proven without revealing the witness."
    )
    ax_univ.text(0.05, 0.95, univ_text, fontsize=10, fontfamily="monospace",
                 verticalalignment="top", transform=ax_univ.transAxes,
                 bbox=dict(boxstyle="round,pad=0.5", facecolor="honeydew",
                           edgecolor="green", linewidth=2))

    plt.savefig("/workspace/request-project/ZeroKnowledge/demos/graph_coloring_zkp.png",
                dpi=150, bbox_inches="tight")
    plt.close()
    print("✅ Demo 3 saved: graph_coloring_zkp.png")

    # === Figure 2: Security analysis ===
    fig2, axes = plt.subplots(1, 2, figsize=(14, 6))
    fig2.suptitle("Security Analysis of Graph Coloring ZKP", fontsize=14, fontweight="bold")

    # Number of edges vs rounds needed
    ax = axes[0]
    edge_counts = [3, 10, 15, 30, 50, 100]
    security_levels = [40, 80, 128, 256]
    colors = ["blue", "green", "orange", "red"]

    for sec, color in zip(security_levels, colors):
        rounds_needed = [int(np.ceil(sec * np.log(2) / np.log(m / (m - 1))))
                         for m in edge_counts]
        ax.plot(edge_counts, rounds_needed, "o-", color=color, linewidth=2,
                label=f"{sec}-bit security")

    ax.set_xlabel("Number of Edges in Graph", fontsize=12)
    ax.set_ylabel("Rounds Required", fontsize=12)
    ax.set_title("Rounds Needed for Security Level", fontsize=13, fontweight="bold")
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Information leaked per round
    ax = axes[1]
    rounds = np.arange(1, 101)
    # Information about the coloring leaked: 0 bits per round (zero-knowledge!)
    # But confidence grows
    m = G.number_of_edges()
    confidence = 1 - ((m - 1) / m) ** rounds
    info_leaked = np.zeros_like(rounds, dtype=float)

    ax.plot(rounds, confidence * 100, "g-", linewidth=2, label="Verifier confidence (%)")
    ax.fill_between(rounds, info_leaked, alpha=0.3, color="blue")
    ax.plot(rounds, info_leaked, "b-", linewidth=2, label="Information leaked (bits)")
    ax.set_xlabel("Number of Rounds", fontsize=12)
    ax.set_ylabel("Percentage / Bits", fontsize=12)
    ax.set_title("Confidence vs Information Leakage", fontsize=13, fontweight="bold")
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-5, 105)
    ax.annotate("ZERO information\nleaked, ever!", xy=(50, 0), fontsize=12,
                fontweight="bold", color="blue", ha="center",
                bbox=dict(boxstyle="round", facecolor="lightyellow"))

    plt.tight_layout()
    fig2.savefig("/workspace/request-project/ZeroKnowledge/demos/graph_coloring_security.png",
                 dpi=150, bbox_inches="tight")
    plt.close()
    print("✅ Demo 3b saved: graph_coloring_security.png")


if __name__ == "__main__":
    run_visualization()
