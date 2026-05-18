import numpy as np

def sylvester_construction(k):
    """Construct Sylvester-Hadamard matrix of order 2^k. O(n^2) time."""
    H = np.array([[1]], dtype=int)
    for _ in range(k):
        H = np.block([[H, H], [H, -H]])
    return H

def kronecker_product(A, B):
    """Kronecker product closure: if A,B Hadamard then A⊗B Hadamard."""
    return np.kron(A, B)

def is_hadamard(H):
    """Verify Hadamard property: ±1 entries and H@H^T = nI."""
    n = H.shape[0]
    if not np.all(np.isin(H, [-1, 1])):
        return False
    return np.array_equal(H @ H.T, n * np.eye(n, dtype=int))

def legendre_symbol(a, p):
    """Compute Legendre symbol (a/p) via Euler criterion."""
    if a % p == 0: return 0
    r = pow(a, (p-1)//2, p)
    return r if r == 1 else -1

def paley_type_I(q):
    """Paley Type I: Hadamard matrix of order q+1 for prime q≡3(mod 4)."""
    Q = np.array([[legendre_symbol(i-j, q) for j in range(q)] for i in range(q)])
    n = q + 1
    H = np.zeros((n, n), dtype=int)
    H[0, 0] = 1; H[0, 1:] = 1; H[1:, 0] = -1
    H[1:, 1:] = Q + np.eye(q, dtype=int)
    return H

def certified_orders(bound):
    """All Hadamard orders up to bound via Sylvester+Paley+Kronecker closure."""
    orders = {1, 2}
    k = 0
    while 2**k <= bound:
        orders.add(2**k); k += 1
    for q in range(3, bound, 4):
        if all(q%p for p in range(2, int(q**0.5)+1)) and q+1 <= bound:
            orders.add(q+1)
    changed = True
    while changed:
        changed = False
        for a in list(orders):
            for b in list(orders):
                if a*b <= bound and a*b not in orders:
                    orders.add(a*b); changed = True
    return orders

# Demo
if __name__ == "__main__":
    print("Sylvester matrices:")
    for k in range(5):
        H = sylvester_construction(k)
        print(f"  H_{k} (order {2**k}): Hadamard = {is_hadamard(H)}")
    
    print("
Paley constructions:")
    for q in [3, 7, 11, 19, 23]:
        H = paley_type_I(q)
        print(f"  Paley({q}): order {q+1}, Hadamard = {is_hadamard(H)}")
    
    print(f"
Certified orders up to 100: {sorted(certified_orders(100))}")
    
    multiples_of_4 = set(range(4, 101, 4))
    covered = certified_orders(100) & multiples_of_4
    print(f"Coverage: {len(covered)}/{len(multiples_of_4)} multiples of 4")
    print(f"Unresolved: {sorted(multiples_of_4 - covered)}")
