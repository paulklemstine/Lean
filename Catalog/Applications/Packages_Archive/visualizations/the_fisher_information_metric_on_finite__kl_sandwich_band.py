"""Visualization: the KL sandwich along a line of distributions.

Interpolates q_t = (1-t) q0 + t q1 between two distributions while holding p
fixed, and plots the Pinsker lower bound, KL divergence, and chi^2 upper bound,
illustrating (1/2)||p-q||_1^2 <= KL(p||q) <= chi^2(p||q).
Requires matplotlib. Saves 'kl_sandwich.png'.
"""
import math
from typing import List, Sequence
import matplotlib.pyplot as plt


def kl(p: Sequence[float], q: Sequence[float]) -> float:
    return sum(pi * math.log(pi / qi) for pi, qi in zip(p, q))


def chi2(p: Sequence[float], q: Sequence[float]) -> float:
    return sum((pi - qi) ** 2 / qi for pi, qi in zip(p, q))


def pinsker(p: Sequence[float], q: Sequence[float]) -> float:
    return 0.5 * sum(abs(pi - qi) for pi, qi in zip(p, q)) ** 2


def main() -> None:
    p = [0.5, 0.3, 0.2]
    q0 = [0.5, 0.3, 0.2]
    q1 = [0.2, 0.3, 0.5]
    ts: List[float] = [0.001 + 0.0015 * k for k in range(660)]
    lo, mid, hi = [], [], []
    for t in ts:
        q = [(1 - t) * q0[i] + t * q1[i] for i in range(3)]
        lo.append(pinsker(p, q)); mid.append(kl(p, q)); hi.append(chi2(p, q))
    plt.figure(figsize=(8, 5))
    plt.plot(ts, lo, label="(1/2)||p-q||_1^2  (Pinsker)", color="green")
    plt.plot(ts, mid, label="KL(p||q)", color="black", linewidth=2)
    plt.plot(ts, hi, label="chi^2(p||q) = Fisher form", color="red")
    plt.fill_between(ts, lo, hi, alpha=0.1, color="gray")
    plt.xlabel("interpolation parameter t"); plt.ylabel("divergence")
    plt.title("The KL sandwich"); plt.legend(); plt.grid(True, alpha=0.3)
    plt.tight_layout(); plt.savefig("kl_sandwich.png", dpi=150)
    print("saved kl_sandwich.png")


if __name__ == "__main__":
    main()
