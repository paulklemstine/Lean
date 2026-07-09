"""Scatter plot of depth n_ell colored by residue class mod 8."""
import matplotlib.pyplot as plt


def v2(n: int) -> int:
    c = 0
    while n % 2 == 0:
        n //= 2
        c += 1
    return c


def is_prime(x: int) -> bool:
    if x < 2:
        return False
    d = 2
    while d * d <= x:
        if x % d == 0:
            return False
        d += 1
    return True


primes = [p for p in range(3, 600, 2) if is_prime(p)]
depths = [v2((p * p - 1) // 8) for p in primes]
res = [p % 8 for p in primes]
colors = {1: "#d1495b", 3: "#edae49", 5: "#66a182", 7: "#2e4057"}
plt.figure(figsize=(11, 5))
for r in (1, 3, 5, 7):
    xs = [p for p, rr in zip(primes, res) if rr == r]
    ys = [d for d, rr in zip(depths, res) if rr == r]
    plt.scatter(xs, ys, s=18, label=f"ell = {r} (mod 8)", color=colors[r])
plt.xlabel("prime ell")
plt.ylabel("depth n_ell")
plt.title("Depth stratified by residue mod 8")
plt.legend()
plt.tight_layout()
plt.savefig("depth_residue.png", dpi=150)
print("wrote depth_residue.png")
