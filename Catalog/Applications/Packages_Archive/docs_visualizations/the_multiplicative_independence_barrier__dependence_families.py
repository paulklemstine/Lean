"""Visualization: dependence families (equivalence classes) of bases 2..64."""
import matplotlib.pyplot as plt
from math import isqrt


def prime_factorization(n):
    f, d = {}, 2
    while d <= isqrt(n):
        while n % d == 0:
            f[d] = f.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        f[n] = f.get(n, 0) + 1
    return f


def signature(n):
    """Primitive multiplicative signature: prime set + gcd-reduced exponent vector."""
    f = prime_factorization(n)
    from math import gcd
    g = 0
    for e in f.values():
        g = gcd(g, e)
    return tuple(sorted((p, e // g) for p, e in f.items()))


def main() -> None:
    bases = list(range(2, 65))
    classes = {}
    for n in bases:
        classes.setdefault(signature(n), []).append(n)
    fig, ax = plt.subplots(figsize=(10, 6))
    for i, (_, members) in enumerate(sorted(classes.items(), key=lambda kv: kv[1][0])):
        ax.scatter(members, [i] * len(members), s=40)
        ax.annotate(",".join(map(str, members)), (members[0], i),
                    xytext=(5, 4), textcoords="offset points", fontsize=7)
    ax.set_xlabel("base")
    ax.set_ylabel("dependence family index")
    ax.set_title("Dependence families of bases 2..64 (each row = one equivalence class)")
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("dependence_families.png", dpi=130)
    print("wrote dependence_families.png; %d families" % len(classes))


if __name__ == "__main__":
    main()
