"""Visualization: standard vs. infinitesimal coordinates of event probability.

Renders, for a fixed n, the (std, inf) coordinates of randomly sampled events as
a scatter plot. Events containing the reservoir land on the std=1 vertical line;
events without it land on std=0. The infinitesimal axis is the signed visible
count (minus n when the reservoir is present), making the lexicographic geometry
visible at a glance.
"""
import random
from fractions import Fraction
import matplotlib.pyplot as plt

def prob_closed(n, event):
    ev = set(event)
    has_res = None in ev
    visible = sum(1 for x in ev if x is not None)
    std = 1 if has_res else 0
    inf = visible - (n if has_res else 0)
    return std, inf

def main():
    n = 12
    atoms = [None] + list(range(n))
    xs0, ys0, xs1, ys1 = [], [], [], []
    for _ in range(400):
        k = random.randint(0, len(atoms))
        ev = random.sample(atoms, k)
        std, inf = prob_closed(n, ev)
        (xs1 if std == 1 else xs0).append(std)
        (ys1 if std == 1 else ys0).append(inf)
    plt.figure(figsize=(7, 5))
    plt.scatter([x + random.uniform(-0.02, 0.02) for x in xs0], ys0,
                s=12, alpha=0.5, label="reservoir absent (std=0)")
    plt.scatter([x + random.uniform(-0.02, 0.02) for x in xs1], ys1,
                s=12, alpha=0.5, label="reservoir present (std=1)")
    plt.axhline(0, color="gray", lw=0.5)
    plt.xlabel("standard coordinate  a  (in a + b*eps)")
    plt.ylabel("infinitesimal coordinate  b")
    plt.title(f"Event probabilities in LexRat for n={n}")
    plt.legend()
    plt.tight_layout()
    plt.savefig("infinitesimal_probability_scatter.png", dpi=140)
    print("saved infinitesimal_probability_scatter.png")

if __name__ == "__main__":
    main()
