from math import gcd
from typing import List
import matplotlib.pyplot as plt

def is_prime(n: int) -> bool:
    return n > 1 and all(n % d for d in range(2, int(n**0.5) + 1))

def liar_fraction(n: int) -> float:
    bases = [b for b in range(2, n) if gcd(n, b) == 1]
    if not bases:
        return 0.0
    liars = sum(1 for b in bases if pow(b, n - 1, n) == 1)
    return liars / len(bases)

if __name__ == "__main__":
    carmichael = [561, 1105, 1729, 2465, 2821]
    ordinary = [15, 21, 35, 91, 561 - 2]
    nums: List[int] = carmichael + ordinary
    fracs = [liar_fraction(n) for n in nums]
    colors = ["crimson"] * len(carmichael) + ["steelblue"] * len(ordinary)
    plt.figure(figsize=(10, 5))
    plt.bar([str(n) for n in nums], fracs, color=colors)
    plt.ylabel("Fraction of coprime bases that are Fermat liars")
    plt.title("Carmichael numbers (red) fool 100% of coprime Fermat witnesses")
    plt.axhline(1.0, ls="--", color="gray")
    plt.tight_layout()
    plt.savefig("fermat_liars.png", dpi=150)
    print("saved fermat_liars.png")
