"""Plot the 2-adic valuation nu_2(t_2(2^k - 1)) = k against k."""
from typing import List
import matplotlib.pyplot as plt


def tmsign(n: int) -> int:
    return -1 if bin(n).count("1") & 1 else 1


def tconv2(bound: int) -> List[int]:
    s = [tmsign(j) for j in range(bound + 1)]
    return [sum(s[k] * s[n - k] for k in range(n + 1)) for n in range(bound + 1)]


def nu2(v: int) -> int:
    c = 0
    while v % 2 == 0:
        v //= 2
        c += 1
    return c


def main() -> None:
    kmax = 10
    t2 = tconv2((1 << kmax) - 1)
    ks = list(range(1, kmax + 1))
    vals = [nu2(t2[(1 << k) - 1]) for k in ks]
    plt.figure(figsize=(6, 4))
    plt.plot(ks, vals, "o-", label=r"$\nu_2(t_2(2^k-1))$")
    plt.plot(ks, ks, "--", label=r"$y = k$")
    plt.xlabel("k")
    plt.ylabel("2-adic valuation")
    plt.title(r"Sharp Mersenne law: $t_2(2^k-1) = (-2)^k$")
    plt.legend()
    plt.tight_layout()
    plt.savefig("mersenne_valuation.png", dpi=150)
    print("saved mersenne_valuation.png")


if __name__ == "__main__":
    main()
