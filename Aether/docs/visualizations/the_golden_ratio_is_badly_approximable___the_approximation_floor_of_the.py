"""Visualize the badly-approximable bound for the golden ratio.

Plots q^2 * |phi - p/q| for the best fraction p = round(q*phi) at each
denominator q, overlaying the proven floor 1/3 and the sharp Hurwitz limit
1/sqrt(5). The Fibonacci-denominator points trace the lower envelope.
"""

import math

import matplotlib.pyplot as plt

PHI = (1 + math.sqrt(5)) / 2


def best_score(q: int) -> float:
    p = round(q * PHI)
    return q * q * abs(PHI - p / q)


def fib_set(limit: int) -> set:
    s, a, b = set(), 1, 1
    while a <= limit:
        s.add(a)
        a, b = b, a + b
    return s


def main() -> None:
    qs = list(range(1, 120))
    scores = [best_score(q) for q in qs]
    fibs = fib_set(120)

    plt.figure(figsize=(10, 6))
    plt.scatter(qs, scores, s=14, color="#888", label=r"$q^2|\varphi-p/q|$")
    fq = [q for q in qs if q in fibs]
    fs = [best_score(q) for q in fq]
    plt.scatter(fq, fs, s=60, color="#d4a017", zorder=5,
                label="Fibonacci denominators")
    plt.axhline(1 / 3, color="crimson", ls="--", label="proven floor $1/3$")
    plt.axhline(1 / math.sqrt(5), color="navy", ls=":",
                label=r"sharp limit $1/\sqrt5$")
    plt.xlabel("denominator $q$")
    plt.ylabel(r"$q^2\,|\varphi - p/q|$")
    plt.title("The golden ratio is badly approximable")
    plt.legend()
    plt.tight_layout()
    plt.savefig("badly_approximable.png", dpi=150)
    print("saved badly_approximable.png")


if __name__ == "__main__":
    main()
