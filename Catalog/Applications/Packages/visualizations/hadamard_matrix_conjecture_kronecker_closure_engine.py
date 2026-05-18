import numpy as np

def certified_hadamard_orders(bound):
    """Compute all constructible Hadamard orders up to bound."""
    orders = {1, 2}
    # Sylvester: powers of 2
    k = 0
    while 2**k <= bound:
        orders.add(2**k); k += 1
    # Paley Type I: q+1 for primes q ≡ 3 (mod 4)
    def is_prime(n):
        if n < 2: return False
        for p in range(2, int(n**0.5)+1):
            if n % p == 0: return False
        return True
    for q in range(3, bound, 4):
        if is_prime(q) and q+1 <= bound:
            orders.add(q+1)
    # Paley Type II: 2(q+1) for primes q ≡ 1 (mod 4)
    for q in range(5, bound, 4):
        if is_prime(q) and 2*(q+1) <= bound:
            orders.add(2*(q+1))
    # Kronecker closure
    changed = True
    while changed:
        changed = False
        for a in list(orders):
            for b in list(orders):
                if a*b <= bound and a*b not in orders:
                    orders.add(a*b); changed = True
    return orders

def unresolved_orders(bound):
    """Multiples of 4 NOT covered by our constructions."""
    covered = certified_hadamard_orders(bound)
    return sorted(set(range(4, bound+1, 4)) - covered)

if __name__ == "__main__":
    for bound in [100, 200, 500, 1000]:
        orders = certified_hadamard_orders(bound)
        m4 = len(range(4, bound+1, 4))
        covered = len(orders & set(range(4, bound+1, 4)))
        print(f"Bound {bound:5d}: {covered}/{m4} multiples of 4 covered ({100*covered/m4:.1f}%)")
    print(f"Unresolved up to 200: {unresolved_orders(200)}")
