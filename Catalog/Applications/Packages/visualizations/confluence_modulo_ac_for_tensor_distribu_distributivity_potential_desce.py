#!/usr/bin/env python3
"""
Visualization: Distributivity Potential Descent
================================================

Visualizes how the distributivity potential strictly decreases under each of
the 8 rewrite rules, proving termination of the rewrite system.

This script is fully self-contained and does not import any local modules.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    # The 8 rules and their potential changes
    rules = [
        "R1: mulVec(A, v⊕w)",
        "R2: mulVec(A⊞B, v)",
        "R3: mulVec(a⊙A, v)",
        "R4: smulVec(a, v⊕w)",
        "R5: smulMat(a, A⊞B)",
        "R6: dot(v⊕w, u)",
        "R7: dot(u, v⊕w)",
        "R8: dot(a•v, w)",
    ]

    # Compute potential for simple variable cases (dp(var) = 3)
    dp_var = 3

    # Before and after potentials for each rule with atomic subterms
    # dp(add(a,b)) = dp(a) + dp(b) + 1, dp(mul(a,b)) = dp(a)*dp(b), etc.
    before = [
        dp_var * (dp_var + dp_var + 1),        # R1: dp(A) * (dp(v)+dp(w)+1)
        (dp_var + dp_var + 1) * dp_var,        # R2: (dp(A)+dp(B)+1) * dp(v)
        (dp_var * dp_var + 1) * dp_var,        # R3: (dp(a)*dp(A)+1) * dp(v)
        dp_var * (dp_var + dp_var + 1) + 1,    # R4: dp(a)*(dp(v)+dp(w)+1)+1
        dp_var * (dp_var + dp_var + 1) + 1,    # R5: dp(a)*(dp(A)+dp(B)+1)+1
        (dp_var + dp_var + 1) * dp_var,        # R6: (dp(v)+dp(w)+1) * dp(u)
        dp_var * (dp_var + dp_var + 1),        # R7: dp(u) * (dp(v)+dp(w)+1)
        (dp_var * dp_var + 1) * dp_var,        # R8: (dp(a)*dp(v)+1) * dp(w)
    ]

    after = [
        dp_var * dp_var + dp_var * dp_var + 1,     # R1: dp(A)*dp(v) + dp(A)*dp(w) + 1
        dp_var * dp_var + dp_var * dp_var + 1,     # R2: dp(A)*dp(v) + dp(B)*dp(v) + 1
        dp_var * (dp_var * dp_var) + 1,            # R3: dp(a)*dp(A)*dp(v) + 1
        dp_var * dp_var + 1 + dp_var * dp_var + 1 + 1,  # R4
        dp_var * dp_var + 1 + dp_var * dp_var + 1 + 1,  # R5
        dp_var * dp_var + dp_var * dp_var + 1,     # R6
        dp_var * dp_var + dp_var * dp_var + 1,     # R7
        dp_var * dp_var * dp_var,                   # R8: dp(a)*dp(v)*dp(w)
    ]

    decrease = [b - a for b, a in zip(before, after)]

    # Create figure
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left plot: before vs after
    x = np.arange(len(rules))
    width = 0.35
    bars1 = ax1.bar(x - width/2, before, width, label='Before rewrite', color='#e74c3c', alpha=0.8)
    bars2 = ax1.bar(x + width/2, after, width, label='After rewrite', color='#2ecc71', alpha=0.8)

    ax1.set_xlabel('Rewrite Rule', fontsize=12)
    ax1.set_ylabel('Distributivity Potential', fontsize=12)
    ax1.set_title('Strict Descent: dp(before) > dp(after)', fontsize=14, fontweight='bold')
    ax1.set_xticks(x)
    ax1.set_xticklabels([r.split(':')[0] for r in rules], rotation=45, ha='right')
    ax1.legend(fontsize=11)
    ax1.grid(axis='y', alpha=0.3)

    # Right plot: decrease amounts
    colors = ['#3498db' if d > 0 else '#e74c3c' for d in decrease]
    bars3 = ax2.bar(x, decrease, color=colors, alpha=0.8, edgecolor='black', linewidth=0.5)

    ax2.set_xlabel('Rewrite Rule', fontsize=12)
    ax2.set_ylabel('Potential Decrease', fontsize=12)
    ax2.set_title('Decrease per Rule (all strictly positive)', fontsize=14, fontweight='bold')
    ax2.set_xticks(x)
    ax2.set_xticklabels([r.split(':')[0] for r in rules], rotation=45, ha='right')
    ax2.axhline(y=0, color='black', linewidth=0.5)
    ax2.grid(axis='y', alpha=0.3)

    # Add value labels
    for bar, val in zip(bars3, decrease):
        ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.2,
                f'{val}', ha='center', va='bottom', fontweight='bold', fontsize=10)

    plt.tight_layout()
    plt.savefig('viz_potential.png', dpi=150, bbox_inches='tight')
    print("Saved viz_potential.png")


if __name__ == "__main__":
    main()
