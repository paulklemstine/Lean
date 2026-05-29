#!/usr/bin/env python3
"""
Visualization: Character Table Sparsity Heatmaps

Visualizes the character tables of S₃, A₄, S₄, and A₅ as heatmaps,
highlighting zero entries (character zeros) that determine the sparsity
structure. The uncertainty principle states that the product of nonzero
rows (class sparsity) and columns (spectral sparsity) must exceed r.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def get_groups():
    """Character tables for small groups."""
    w = np.exp(2j * np.pi / 3)
    phi = (1 + np.sqrt(5)) / 2

    return {
        "S₃": {
            "class_sizes": [1, 3, 2],
            "class_labels": ["{e}", "{(12)}", "{(123)}"],
            "char_table": np.array([[1,1,1],[1,-1,1],[2,0,-1]], dtype=complex),
        },
        "A₄": {
            "class_sizes": [1, 3, 4, 4],
            "class_labels": ["{e}", "{(12)(34)}", "{(123)}", "{(132)}"],
            "char_table": np.array([
                [1, 1, 1, 1], [1, 1, w, w**2],
                [1, 1, w**2, w], [3, -1, 0, 0],
            ], dtype=complex),
        },
        "S₄": {
            "class_sizes": [1, 6, 3, 8, 6],
            "class_labels": ["1", "(12)", "(12)(34)", "(123)", "(1234)"],
            "char_table": np.array([
                [1,1,1,1,1],[1,-1,1,1,-1],[2,0,2,-1,0],
                [3,1,-1,0,-1],[3,-1,-1,0,1],
            ], dtype=complex),
        },
        "A₅": {
            "class_sizes": [1, 15, 20, 12, 12],
            "class_labels": ["1", "(12)(34)", "(123)", "(12345)", "(13245)"],
            "char_table": np.array([
                [1, 1, 1, 1, 1],
                [3, -1, 0, phi, 1-phi],
                [3, -1, 0, 1-phi, phi],
                [4, 0, 1, -1, -1],
                [5, 1, -1, 0, 0],
            ], dtype=complex),
        },
    }


def plot_heatmaps():
    groups = get_groups()
    fig, axes = plt.subplots(2, 2, figsize=(14, 11))
    fig.suptitle("Character Table Sparsity: Zeros Constrain Uncertainty",
                 fontsize=16, fontweight='bold', y=0.98)

    for idx, (name, data) in enumerate(groups.items()):
        ax = axes[idx // 2, idx % 2]
        ct = data["char_table"]
        r = ct.shape[0]
        abs_ct = np.abs(ct)

        # Create colormap: zeros are dark red, nonzeros are blue gradient
        cmap = plt.cm.Blues
        norm = mcolors.Normalize(vmin=0, vmax=np.max(abs_ct) * 1.1)

        im = ax.imshow(abs_ct, cmap=cmap, norm=norm, aspect='equal')

        # Highlight zeros with red
        for i in range(r):
            for j in range(r):
                val = ct[i, j]
                abs_val = abs(val)
                if abs_val < 1e-10:
                    ax.add_patch(plt.Rectangle((j-0.5, i-0.5), 1, 1,
                                               fill=True, facecolor='#ff4444',
                                               alpha=0.7))
                    ax.text(j, i, "0", ha='center', va='center',
                           fontsize=12, fontweight='bold', color='white')
                else:
                    # Show the actual value
                    if abs(val.imag) < 1e-10:
                        text = f"{val.real:.2f}"
                    else:
                        text = f"{val:.1f}"
                    color = 'white' if abs_val > np.max(abs_ct) * 0.5 else 'black'
                    ax.text(j, i, text, ha='center', va='center',
                           fontsize=9, color=color)

        # Compute sparsity info
        class_sparsities = [int(np.sum(np.abs(ct[i]) > 1e-10)) for i in range(r)]
        min_cs = min(class_sparsities)
        all_nonvanishing = all(cs == r for cs in class_sparsities)

        ax.set_xticks(range(r))
        ax.set_xticklabels([f"C{j+1}" for j in range(r)], fontsize=9)
        ax.set_yticks(range(r))
        ax.set_yticklabels([f"χ{i+1}" for i in range(r)], fontsize=9)
        ax.set_xlabel("Conjugacy Classes", fontsize=10)
        ax.set_ylabel("Irreducible Characters", fontsize=10)

        status = "ALL NONVANISHING ✓" if all_nonvanishing else f"min class_sp = {min_cs}"
        ax.set_title(f"{name} (r={r}) — {status}", fontsize=12, fontweight='bold')

        plt.colorbar(im, ax=ax, shrink=0.8, label="|χᵢ(Cⱼ)|")

    plt.tight_layout(rect=[0, 0, 1, 0.95])

    # Add annotation
    fig.text(0.5, 0.01,
             "Red cells = zeros (character zeros). "
             "Uncertainty Principle: σ_cls × σ_spec ≥ r. "
             "Note A₅ has no zeros → all characters are extremal.",
             ha='center', fontsize=10, style='italic',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    plt.savefig("sparsity_heatmap.png", dpi=150, bbox_inches='tight')
    print("Saved: sparsity_heatmap.png")


if __name__ == "__main__":
    plot_heatmaps()
