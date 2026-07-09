"""Bar chart comparing the number of open sets: each observer vs consensus vs
possibility on a finite ordered sample, illustrating the sandwich."""
import matplotlib.pyplot as plt
from fractions import Fraction
from itertools import combinations


def _generate(ground, subbasis):
    basis = {frozenset(), ground}
    for s in subbasis:
        basis.add(frozenset(s) & ground)
    changed = True
    while changed:
        changed = False
        for u in list(basis):
            for v in list(basis):
                w = u & v
                if w not in basis:
                    basis.add(w); changed = True
    opens = {frozenset(), ground}
    for r in range(1, len(basis) + 1):
        for c in combinations(basis, r):
            opens.add(frozenset().union(*c))
    return frozenset(opens)


def plot_open_set_counts(n: int = 5) -> None:
    sample = [Fraction(k) for k in range(n)]
    g = frozenset(range(n))
    R = _generate(g, [frozenset(j for j in range(n) if sample[j] >= sample[i])
                      for i in range(n)])
    L = _generate(g, [frozenset(j for j in range(n) if sample[j] <= sample[i])
                      for i in range(n)])
    con = frozenset(set(L) & set(R))
    pos = _generate(g, set(L) | set(R))
    labels = ["consensus", "left obs.", "right obs.", "possibility"]
    counts = [len(con), len(L), len(R), len(pos)]
    colors = ["seagreen", "royalblue", "crimson", "black"]
    fig, ax = plt.subplots(figsize=(7, 4))
    ax.bar(labels, counts, color=colors, alpha=0.8)
    for i, c in enumerate(counts):
        ax.text(i, c + 0.5, str(c), ha="center")
    ax.axhline(2 ** n, color="gray", ls="--", lw=0.8, label=f"$2^{n}$ (discrete)")
    ax.set_ylabel("number of open sets")
    ax.set_title(f"Sandwich of open-set counts on {n} sampled points")
    ax.legend()
    plt.tight_layout()
    plt.savefig("open_set_counts.png", dpi=150)
    print("wrote open_set_counts.png")


if __name__ == "__main__":
    plot_open_set_counts()
