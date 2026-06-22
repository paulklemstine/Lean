"""Visualize the extremal-support profile under convolution vs. addition.

Generates a figure with two panels:
  (left)  stems of f, g and their Cauchy convolution f*g, with ord/deg marked,
          illustrating ord(f*g)=ord f+ord g and deg(f*g)=deg f+deg g (EXACT);
  (right) stems of f, g and their sum f+g where leading/trailing terms cancel,
          illustrating the strict inequalities for addition.

Requires matplotlib. Saves 'tropical_profile.png'.
"""
from fractions import Fraction
from typing import Dict
import matplotlib.pyplot as plt

Seq = Dict[int, Fraction]


def cconv(f: Seq, g: Seq) -> Seq:
    out: Seq = {}
    for i, a in f.items():
        for j, b in g.items():
            out[i + j] = out.get(i + j, Fraction(0)) + a * b
    return {n: c for n, c in out.items() if c != 0}


def add(f: Seq, g: Seq) -> Seq:
    out: Seq = dict(f)
    for n, c in g.items():
        out[n] = out.get(n, Fraction(0)) + c
    return {n: c for n, c in out.items() if c != 0}


def stem(ax, seq: Seq, color: str, label: str, offset: float) -> None:
    if not seq:
        return
    xs = sorted(seq)
    ys = [float(seq[n]) for n in xs]
    ax.stem([x + offset for x in xs], ys, linefmt=color, markerfmt=color + "o",
            basefmt=" ", label=label)


def main() -> None:
    f: Seq = {2: Fraction(3), 5: Fraction(7), 9: Fraction(-2)}
    g: Seq = {1: Fraction(4), 4: Fraction(-1), 6: Fraction(5)}
    h = cconv(f, g)

    # Cancellation example for addition.
    p: Seq = {9: Fraction(1)}
    q: Seq = {3: Fraction(1), 9: Fraction(-1)}
    s = add(p, q)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    stem(ax1, f, "C0", "f", -0.12)
    stem(ax1, g, "C1", "g", 0.0)
    stem(ax1, h, "C3", "f * g", 0.12)
    ax1.set_title("Convolution: ord and deg ADD EXACTLY\n"
                  "ord(f*g)=2+1=3, deg(f*g)=9+6=15")
    ax1.legend()
    ax1.set_xlabel("index n")
    ax1.set_ylabel("coefficient")

    stem(ax2, p, "C0", "p = x^9", -0.1)
    stem(ax2, q, "C1", "q = x^3 - x^9", 0.0)
    stem(ax2, s, "C3", "p + q = x^3", 0.1)
    ax2.set_title("Addition: cancellation => STRICT inequality\n"
                  "deg(p+q)=3 < max(deg p, deg q)=9")
    ax2.legend()
    ax2.set_xlabel("index n")

    fig.suptitle("Tropical extremal-support profile: exact under *, inequality under +")
    fig.tight_layout()
    fig.savefig("tropical_profile.png", dpi=150)
    print("Saved tropical_profile.png")


if __name__ == "__main__":
    main()
