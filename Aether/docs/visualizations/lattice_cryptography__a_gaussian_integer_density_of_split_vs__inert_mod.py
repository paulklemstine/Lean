import matplotlib.pyplot as plt

def is_prime(n: int) -> bool:
    if n < 2: return False
    i = 2
    while i * i <= n:
        if n % i == 0: return False
        i += 1
    return True

def plot_prime_density(N: int = 2000) -> None:
    xs, split, inert = [], [], []
    s = c = 0
    for n in range(2, N + 1):
        if is_prime(n):
            if n % 4 == 1: s += 1
            elif n % 4 == 3: c += 1
        xs.append(n); split.append(s); inert.append(c)
    plt.figure(figsize=(8, 5))
    plt.plot(xs, split, label="split: p ≡ 1 (mod 4)", color="crimson")
    plt.plot(xs, inert, label="inert: p ≡ 3 (mod 4)", color="navy")
    plt.xlabel("N"); plt.ylabel("count of primes <= N")
    plt.title("Split vs inert moduli (Dirichlet equidistribution)")
    plt.legend(); plt.grid(True, alpha=0.3); plt.tight_layout()
    plt.savefig("prime_density.png", dpi=150)
    print("saved prime_density.png")

if __name__ == "__main__":
    plot_prime_density()
