"""Visualization: Pisano period pi(m), entry point z(m) and ratio pi/z.

Produces two panels: (1) pi(m) and z(m) versus m for m up to a bound, showing
their erratic growth and the inclusion z(m) <= pi(m); (2) a histogram of the
ratio pi(m)/z(m), which always lands in {1, 2, 4}. Requires matplotlib.
"""
from __future__ import annotations
from collections import Counter
import matplotlib.pyplot as plt

def pisano_period(m: int) -> int:
    if m == 1:
        return 1
    a, b = 0, 1
    for k in range(1, 6 * m + 1):
        a, b = b % m, (a + b) % m
        if a == 0 and b == 1:
            return k
    raise RuntimeError

def entry_point(m: int) -> int:
    if m == 1:
        return 1
    a, b = 0, 1
    for k in range(1, 6 * m + 1):
        a, b = b % m, (a + b) % m
        if a == 0:
            return k
    raise RuntimeError

def main(limit: int = 200) -> None:
    ms = list(range(1, limit + 1))
    pis = [pisano_period(m) for m in ms]
    zs = [entry_point(m) for m in ms]
    ratios = [p // z for p, z in zip(pis, zs)]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))
    ax1.plot(ms, pis, ".", ms=4, label="pi(m)  (Pisano period)")
    ax1.plot(ms, zs, ".", ms=4, label="z(m)  (entry point)")
    ax1.set_xlabel("m"); ax1.set_ylabel("value")
    ax1.set_title("Pisano period and entry point"); ax1.legend()

    cnt = Counter(ratios)
    keys = sorted(cnt)
    ax2.bar([str(k) for k in keys], [cnt[k] for k in keys], color="#3b6")
    ax2.set_xlabel("pi(m) / z(m)"); ax2.set_ylabel("count")
    ax2.set_title("The ratio pi/z always lies in {1, 2, 4}")
    fig.tight_layout()
    fig.savefig("pisano_stats.png", dpi=140)
    print("wrote pisano_stats.png; ratios seen:", dict(cnt))

if __name__ == "__main__":
    main()
