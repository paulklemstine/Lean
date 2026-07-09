"""Bar chart of the 2-adic depth n_ell for small primes."""
import matplotlib.pyplot as plt


def v2(n: int) -> int:
    c = 0
    while n % 2 == 0:
        n //= 2
        c += 1
    return c


def n_ell(ell: int) -> int:
    return v2((ell * ell - 1) // 8)


primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 97, 127, 257]
depths = [n_ell(p) for p in primes]
plt.figure(figsize=(10, 5))
plt.bar([str(p) for p in primes], depths, color="#3b6ea5")
plt.xlabel("prime ell")
plt.ylabel("depth n_ell = v2((ell^2-1)/8)")
plt.title("2-adic depth of small primes")
plt.tight_layout()
plt.savefig("depth_bars.png", dpi=150)
print("wrote depth_bars.png")
