"""
Visualization: entropy drop and Landauer dissipation across logic gates.

Generates a two-panel figure:
  (left)  Shannon entropy H(p) vs H(f_*p) for a battery of 2-bit logic maps,
          illustrating the data-processing inequality H(f_*p) <= H(p).
  (right) Landauer dissipated work W = kT(H(p)-H(f_*p)) per gate at T=300K,
          with the injective (reversible) gate sitting exactly at W=0.

Standard library + matplotlib only.
"""

from __future__ import annotations

import math
from collections import defaultdict
from typing import Callable, Dict, Hashable, List

import matplotlib.pyplot as plt

BOLTZMANN_K: float = 1.380_649e-23


def shannon_entropy(p: Dict[Hashable, float]) -> float:
    return -sum(px * math.log(px) for px in p.values() if px > 0.0)


def pushforward(f: Callable[[Hashable], Hashable],
                p: Dict[Hashable, float]) -> Dict[Hashable, float]:
    out: Dict[Hashable, float] = defaultdict(float)
    for x, px in p.items():
        out[f(x)] += px
    return dict(out)


def bitstrings(n: int) -> List[str]:
    return [format(i, f"0{n}b") for i in range(2 ** n)]


def main() -> None:
    T = 300.0
    states = bitstrings(2)
    p = {s: 0.25 for s in states}
    gates: Dict[str, Callable[[Hashable], Hashable]] = {
        "SWAP\n(reversible)": lambda s: s[::-1],
        "XOR": lambda s: str(int(s[0]) ^ int(s[1])),
        "AND": lambda s: str(int(s[0]) & int(s[1])),
        "OR": lambda s: str(int(s[0]) | int(s[1])),
        "ERASE": lambda s: "00",
    }

    names = list(gates)
    h_in = [shannon_entropy(p)] * len(names)
    h_out = [shannon_entropy(pushforward(f, p)) for f in gates.values()]
    work = [BOLTZMANN_K * T * (hi - ho) for hi, ho in zip(h_in, h_out)]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    x = range(len(names))

    ax1.bar([i - 0.2 for i in x], h_in, width=0.4, label="H(p) input", color="#4C72B0")
    ax1.bar([i + 0.2 for i in x], h_out, width=0.4, label="H(f_*p) output", color="#DD8452")
    ax1.set_xticks(list(x))
    ax1.set_xticklabels(names)
    ax1.set_ylabel("Shannon entropy (nats)")
    ax1.set_title("Data-processing inequality:  H(f_*p) <= H(p)")
    ax1.legend()

    colors = ["#55A868" if w < 1e-30 else "#C44E52" for w in work]
    ax2.bar(list(x), work, color=colors)
    ax2.set_xticks(list(x))
    ax2.set_xticklabels(names)
    ax2.set_ylabel("Landauer work W at T=300K (J)")
    ax2.set_title("Dissipation W = kT(H(p) - H(f_*p)) >= 0")
    ax2.axhline(0.0, color="black", linewidth=0.8)

    fig.suptitle("Landauer's principle from the deterministic data-processing inequality")
    fig.tight_layout()
    fig.savefig("landauer_visualization.png", dpi=150)
    print("Saved landauer_visualization.png")


if __name__ == "__main__":
    main()
