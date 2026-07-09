"""Plot |s-s| = k^2 - k + 1 for Sidon sets against the trivial upper bound."""
from __future__ import annotations
from typing import List, Set
import matplotlib.pyplot as plt


def greedy_sidon(k: int) -> List[int]:
    s: List[int] = []
    diffs: Set[int] = set()
    x = 0
    while len(s) < k:
        x += 1
        new: Set[int] = set()
        ok = True
        for y in s:
            d = x - y
            if d in diffs or -d in diffs or d in new or -d in new:
                ok = False
                break
            new |= {d, -d}
        if ok:
            s.append(x)
            diffs |= new
    return s


def diff_card(s: List[int]) -> int:
    e = list(set(s))
    return len({a - b for a in e for b in e})


def main() -> None:
    ks = list(range(1, 13))
    actual = [diff_card(greedy_sidon(k)) for k in ks]
    theory = [k * k - k + 1 for k in ks]
    plt.figure(figsize=(8, 5))
    plt.plot(ks, theory, "o-", label="k^2 - k + 1 (theorem)")
    plt.plot(ks, actual, "x--", label="measured |s - s|")
    plt.title("Sidon sets attain the maximal difference-set size")
    plt.xlabel("k = |s|")
    plt.ylabel("|s - s|")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("difference_growth.png", dpi=150)
    print("wrote difference_growth.png")


if __name__ == "__main__":
    main()
