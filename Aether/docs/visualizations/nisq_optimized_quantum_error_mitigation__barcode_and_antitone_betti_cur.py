"""Visualize the persistence Betti curve and the margin-to-noise safe zone.

Generates a figure with two panels:
  (left)  a barcode with the threshold tau and the +/- eps noise band;
  (right) the antitone Betti curve beta_tau(B).
Saves to `betti_recovery.png`.
"""
from dataclasses import dataclass
from typing import List, Sequence
import random
import matplotlib.pyplot as plt


@dataclass(frozen=True)
class Bar:
    birth: float
    death: float


def persistence(b: Bar) -> float:
    return b.death - b.birth


def betti_count(tau: float, bars: Sequence[Bar]) -> int:
    return sum(1 for b in bars if tau < persistence(b))


def main() -> None:
    rng = random.Random(1)
    tau, eps = 2.5, 0.3
    bars: List[Bar] = sorted(
        [Bar(0.0, rng.random() * 5.0) for _ in range(20)],
        key=persistence)

    fig, (ax0, ax1) = plt.subplots(1, 2, figsize=(12, 5))

    for i, b in enumerate(bars):
        p = persistence(b)
        color = "crimson" if tau < p else "steelblue"
        ax0.plot([b.birth, b.death], [i, i], color=color, lw=3)
        ax0.plot([b.death - eps, b.death + eps], [i, i],
                 color="gray", lw=1, alpha=0.6)
    ax0.axvline(tau, color="black", ls="--", label=f"threshold tau={tau}")
    ax0.set_title("Barcode (red = persistence > tau)")
    ax0.set_xlabel("filtration scale"); ax0.set_ylabel("bar index")
    ax0.legend()

    ts = [i * 0.1 for i in range(60)]
    curve = [betti_count(t, bars) for t in ts]
    ax1.step(ts, curve, where="post", color="darkgreen")
    ax1.axvline(tau, color="black", ls="--")
    ax1.set_title("Antitone Betti curve  beta_tau(B)")
    ax1.set_xlabel("threshold tau"); ax1.set_ylabel("Betti count")

    fig.tight_layout()
    fig.savefig("betti_recovery.png", dpi=140)
    print("saved betti_recovery.png")


if __name__ == "__main__":
    main()
