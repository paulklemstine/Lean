from math import gcd

def totient(n: int) -> int:
    """Return the number of automorphisms of the cyclic group C_n."""
    if n < 1:
        raise ValueError("n must be positive")
    return sum(gcd(k, n) == 1 for k in range(1, n + 1))

if __name__ == "__main__":
    for n in range(1, 21):
        print(f"|Aut(C_{n})| = {totient(n)}")
