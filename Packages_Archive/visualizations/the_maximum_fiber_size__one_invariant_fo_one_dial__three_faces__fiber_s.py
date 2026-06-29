"""Visualize the fourfold dial: maxFiberSize vs. erased information vs.
Landauer gap, for a family of finite functions. Saves fiber_cost.png."""
import math
from collections import defaultdict
from typing import Callable, Hashable, Sequence

import matplotlib.pyplot as plt

K_BOLTZMANN = 1.380649e-23
T = 300.0


def max_fiber_size(domain: Sequence[Hashable],
                   f: Callable[[Hashable], Hashable]) -> int:
    fib = defaultdict(int)
    for a in domain:
        fib[f(a)] += 1
    return max(fib.values(), default=0)


def info_erased(domain: Sequence[Hashable],
                f: Callable[[Hashable], Hashable]) -> float:
    n = len(domain)
    img = len({f(a) for a in domain})
    return math.log2(n) - math.log2(img) if n and img else 0.0


def main() -> None:
    n = 16
    domain = list(range(n))
    # Family: x -> x // m  for m = 1,2,4,8,16  (collapse ratio grows).
    ms = [1, 2, 4, 8, 16]
    ks, bits, gaps = [], [], []
    for m in ms:
        f = (lambda mm: (lambda x: x // mm))(m)
        ks.append(max_fiber_size(domain, f))
        bits.append(info_erased(domain, f))
        gaps.append(K_BOLTZMANN * T * math.log(2.0) * info_erased(domain, f))

    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    axes[0].bar([str(m) for m in ms], ks, color="#3b6ea5")
    axes[0].set_title("maxFiberSize (ancilla states)")
    axes[0].set_xlabel("collapse ratio m")
    axes[1].bar([str(m) for m in ms], bits, color="#a53b6e")
    axes[1].set_title("information erased (bits)")
    axes[1].set_xlabel("collapse ratio m")
    axes[2].bar([str(m) for m in ms], gaps, color="#6ea53b")
    axes[2].set_title("Landauer gap (J) at 300 K")
    axes[2].set_xlabel("collapse ratio m")
    fig.suptitle("One dial, three faces: fiber size governs ancilla, "
                 "information, and energy", fontsize=13)
    fig.tight_layout()
    fig.savefig("fiber_cost.png", dpi=140)
    print("wrote fiber_cost.png")


if __name__ == "__main__":
    main()
