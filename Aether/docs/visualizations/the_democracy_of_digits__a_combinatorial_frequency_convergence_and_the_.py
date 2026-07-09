"""
Visualization: convergence of digit frequencies to 1/b for several streams,
and the O(1) discrepancy band of the cyclic stream.  Requires matplotlib.
"""
from typing import Callable
import matplotlib.pyplot as plt

DigitStream = Callable[[int], int]

def count_digit(s: DigitStream, d: int, n: int) -> int:
    return sum(1 for k in range(n) if s(k) == d)

def cyc(b: int) -> DigitStream:
    return lambda k: k % b

def main() -> None:
    b = 10
    ns = list(range(1, 2001))
    s = cyc(b)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # Left: frequency of each digit converging to 1/b.
    for d in range(b):
        freqs = [count_digit(s, d, n) / n for n in ns]
        ax1.plot(ns, freqs, lw=0.8)
    ax1.axhline(1 / b, color="black", ls="--", label="1/b")
    ax1.set_title(f"Digit frequencies of cyc_{b} -> 1/{b}")
    ax1.set_xlabel("window size n")
    ax1.set_ylabel("freq(s, d, n)")
    ax1.legend()

    # Right: discrepancy |count - n/b| stays within [0, 1].
    disc = [max(abs(count_digit(s, d, n) - n / b) for d in range(b)) for n in ns]
    ax2.plot(ns, disc, color="crimson", lw=1.0)
    ax2.axhline(1.0, color="black", ls="--", label="O(1) bound = 1")
    ax2.set_ylim(0, 1.3)
    ax2.set_title(f"Max discrepancy |count - n/b| for cyc_{b}")
    ax2.set_xlabel("window size n")
    ax2.set_ylabel("discrepancy")
    ax2.legend()

    fig.tight_layout()
    fig.savefig("normality_convergence.png", dpi=150)
    print("saved normality_convergence.png")

if __name__ == "__main__":
    main()
