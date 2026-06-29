"""Visualization: rarity of meaning and the map-vs-territory gap.

Produces two panels:
  (left)  per-position match probability b^{-m} vs window-count bound,
          showing the exponential decay of "meaning density".
  (right) base-10 digit counts of the Library b^L and of its minimal
          distributed catalog b^L / L, showing they nearly coincide.
"""
from math import log10
import matplotlib.pyplot as plt

def make_figure(path: str = "library_of_babel.png") -> None:
    b = 25
    ms = list(range(1, 41))
    L = 1000
    per_pos = [-m * log10(b) for m in ms]                  # log10 b^{-m}
    anywhere = [log10(L - m + 1) - m * log10(b) for m in ms]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(ms, per_pos, "o-", label="fixed position: b^-m")
    ax1.plot(ms, anywhere, "s--", label="occurs anywhere: (L-m+1) b^-m")
    ax1.set_xlabel("target length m")
    ax1.set_ylabel("log10 probability")
    ax1.set_title("Rarity of meaning (b = 25)")
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    Ls = [10 ** k for k in range(2, 8)]
    lib_digits = [int(Lk * log10(b)) + 1 for Lk in Ls]
    cat_digits = [int(Lk * log10(b)) + 1 - len(str(Lk)) + 1 for Lk in Ls]
    x = range(len(Ls))
    ax2.bar([i - 0.2 for i in x], lib_digits, width=0.4, label="Library  b^L")
    ax2.bar([i + 0.2 for i in x], cat_digits, width=0.4,
            label="catalog  b^L / L")
    ax2.set_xticks(list(x))
    ax2.set_xticklabels([f"10^{k}" for k in range(2, 8)])
    ax2.set_xlabel("book length L")
    ax2.set_ylabel("decimal digits")
    ax2.set_title("Map vs territory: catalog ~ Library")
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig(path, dpi=150)
    print(f"wrote {path}")

if __name__ == "__main__":
    make_figure()
