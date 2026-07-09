import matplotlib.pyplot as plt
from itertools import permutations
from collections import Counter

def fixed_point_spectrum(n: int) -> Counter:
    c = Counter()
    for p in permutations(range(n)):
        c[sum(1 for i in range(n) if p[i] == i)] += 1
    return c

if __name__ == "__main__":
    n = 6
    spec = fixed_point_spectrum(n)
    ks = sorted(spec)
    plt.figure(figsize=(7, 5))
    plt.bar(ks, [spec[k] for k in ks], color="steelblue")
    plt.xlabel("number of fixed points (= agreements)")
    plt.ylabel("count of permutations in Sym(n)")
    plt.title(f"Fixed-point spectrum of Sym({n})")
    plt.tight_layout()
    plt.savefig("fixed_point_spectrum.png", dpi=150)
    print("Saved fixed_point_spectrum.png")
