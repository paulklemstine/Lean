"""Visualization: the containment-probability sandwich and Borges completeness.
Generates two panels:
  (left)  lower bound, true (enumerated) probability, and union upper bound vs L
          for a mini-Library (b=4, k=3);
  (right) the disjoint-block lower bound climbing to 1 for Borges' library
          (b=25, k=3) on a log-L axis.
Saves to 'library_of_babel_bounds.png'."""
from __future__ import annotations
from itertools import product
from typing import List, Tuple
import matplotlib.pyplot as plt

Pattern = Tuple[int, ...]

def contains(pattern: Pattern, v: Tuple[int, ...]) -> bool:
    k, L = len(pattern), len(v)
    return any(all(v[i + j] == pattern[j] for j in range(k))
               for i in range(L - k + 1))

def lower(b: int, L: int, k: int) -> float:
    m = L // k
    return 1.0 - ((b ** k - 1) / b ** k) ** m

def upper(b: int, L: int, k: int) -> float:
    return (L - k + 1) / b ** k

def main() -> None:
    b, k = 4, 3
    pattern: Pattern = (1, 2, 3)
    Ls: List[int] = list(range(3, 12))
    true_p, lo, up = [], [], []
    for L in Ls:
        n = b ** L
        matched = sum(1 for v in product(range(b), repeat=L) if contains(pattern, v))
        true_p.append(matched / n)
        lo.append(lower(b, L, k))
        up.append(min(1.0, upper(b, L, k)))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    ax1.plot(Ls, lo, "g--o", label="lower bound")
    ax1.plot(Ls, true_p, "k-s", label="true P(contains)")
    ax1.plot(Ls, up, "r--^", label="union upper bound")
    ax1.set_xlabel("book length L"); ax1.set_ylabel("probability")
    ax1.set_title(f"Containment sandwich (b={b}, k={k})"); ax1.legend(); ax1.grid(True)

    b2, k2 = 25, 3
    Ls2 = [10 ** e for e in range(1, 7)]
    lo2 = [lower(b2, L, k2) for L in Ls2]
    ax2.semilogx(Ls2, lo2, "b-o")
    ax2.axhline(1.0, color="gray", ls=":")
    ax2.set_xlabel("book length L (log scale)"); ax2.set_ylabel("lower bound on P(contains)")
    ax2.set_title(f"Borges completeness (b={b2}, k={k2}): bound -> 1")
    ax2.grid(True, which="both")

    fig.tight_layout()
    fig.savefig("library_of_babel_bounds.png", dpi=130)
    print("saved library_of_babel_bounds.png")

if __name__ == "__main__":
    main()
