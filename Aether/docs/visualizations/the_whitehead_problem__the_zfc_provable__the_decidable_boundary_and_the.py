"""Visualization: the Whitehead decidable boundary and the cyclic obstruction.

Generates two panels:
  (left)  the lattice extension 0 -> Z --(.n)--> Z --(mod n)--> Z/n -> 0,
          showing the sublattice nZ inside Z and the n residue classes; the
          obstruction is that no Z-linear section Z/n -> Z exists.
  (right) the decidable boundary: free => Whitehead (split), torsion => not.

Requires matplotlib. Saves 'whitehead_boundary.png'.
"""

from __future__ import annotations

import matplotlib.pyplot as plt


def main() -> None:
    n = 4
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # --- Left: the cyclic extension and its residue classes ---
    xs = list(range(-2, 13))
    for x in xs:
        cls = x % n
        is_multiple = (x % n == 0)
        ax1.scatter(x, 0, s=180 if is_multiple else 90,
                    c="crimson" if is_multiple else "steelblue",
                    edgecolors="black", zorder=3)
        ax1.annotate(str(cls), (x, 0.12), ha="center", fontsize=9, color="dimgray")
    ax1.axhline(0, color="black", lw=0.8, zorder=1)
    ax1.set_title(r"$0 \to \mathbb{Z} \xrightarrow{\cdot %d} \mathbb{Z}"
                  r" \xrightarrow{\mathrm{mod}\,%d} \mathbb{Z}/%d \to 0$"
                  % (n, n, n), fontsize=12)
    ax1.text(5, -0.45, "red = image of (.%d) = ker(mod %d);\n"
                       "labels = residue class in Z/%d.\n"
                       "No linear section Z/%d -> Z exists." % (n, n, n, n),
             ha="center", fontsize=9)
    ax1.set_yticks([])
    ax1.set_xlabel(r"$\mathbb{Z}$")
    ax1.set_ylim(-0.8, 0.5)

    # --- Right: decidable boundary bar chart ---
    groups = [r"$\mathbb{Z}$", r"$\mathbb{Z}^2$", r"$\mathbb{Z}/2$",
              r"$\mathbb{Z}/6$", r"$\mathbb{Z}\oplus\mathbb{Z}/3$"]
    whitehead = [1, 1, 0, 0, 0]  # 1 = Whitehead, 0 = not
    colors = ["seagreen" if w else "indianred" for w in whitehead]
    ax2.bar(groups, [1] * len(groups), color=colors, edgecolor="black")
    for i, w in enumerate(whitehead):
        ax2.text(i, 0.5, "Whitehead\n(free)" if w else "NOT Whitehead\n(torsion)",
                 ha="center", va="center", fontsize=9, color="white",
                 fontweight="bold")
    ax2.set_title("Finitely generated: Whitehead  <=>  free", fontsize=12)
    ax2.set_yticks([])
    ax2.set_ylim(0, 1)

    fig.suptitle("The ZFC-provable skeleton of the Whitehead problem", fontsize=14)
    fig.tight_layout()
    fig.savefig("whitehead_boundary.png", dpi=150)
    print("Saved whitehead_boundary.png")


if __name__ == "__main__":
    main()
