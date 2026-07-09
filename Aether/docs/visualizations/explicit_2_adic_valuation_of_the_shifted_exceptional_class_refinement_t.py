"""Draw the binary refinement tree of the exceptional class m = 26 mod 28."""
from __future__ import annotations
import matplotlib.pyplot as plt


def perrin_mod(m: int, modulus: int) -> int:
    if m < 3:
        return [3, 0, 2][m] % modulus
    a, b, c = 3 % modulus, 0, 2 % modulus
    for _ in range(3, m + 1):
        a, b, c = b, c, (b + a) % modulus
    return c


def main() -> None:
    # Follow the "persisting" survivor thread starting from residue 26.
    fig, ax = plt.subplots(figsize=(9, 5))
    level_period = [28, 56, 112, 224]
    residues = [26]
    for lp in level_period[1:]:
        prev = residues[-1]
        # the two children mod 2*prev_period; pick the one with higher valuation
        cand = [prev, prev + lp // 2]
        best = max(cand, key=lambda r: _val(r, lp))
        residues.append(best)
    ys = list(range(len(residues)))
    for y, (lp, r) in enumerate(zip(level_period, residues)):
        ax.text(0.5, -y, f"m ≡ {r} (mod {lp})", ha="center",
                bbox=dict(boxstyle="round", fc="wheat"))
        if y:
            ax.plot([0.5, 0.5], [-y + 1, -y], "k-")
    ax.set_ylim(-len(residues), 1); ax.axis("off")
    ax.set_title("Survivor thread of the exceptional class (period doubling)")
    plt.tight_layout(); plt.savefig("perrin_refinement_tree.png", dpi=150)


def _val(r: int, period: int) -> int:
    k = 0
    while True:
        mod = 1 << (k + 1)
        if (perrin_mod(r % (7 * (1 << k)), mod) - 1) % mod != 0:
            return k
        k += 1
        if k > 40:
            return k


if __name__ == "__main__":
    main()
