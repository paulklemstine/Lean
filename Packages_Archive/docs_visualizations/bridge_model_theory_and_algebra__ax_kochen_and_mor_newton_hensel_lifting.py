def hensel_lift(f, f_deriv, a0, p, max_precision):
    """Newton-Hensel lifting algorithm for p-adic root finding.
    
    Given f(x) with f(a0) ≡ 0 (mod p) and f'(a0) a unit mod p,
    lifts the root to precision p^max_precision.
    
    Args:
        f: polynomial function Z -> Z
        f_deriv: derivative of f
        a0: initial approximate root (root mod p)
        p: prime
        max_precision: number of lifting steps
    
    Returns:
        List of (k, a_k mod p^k, f(a_k) mod p^k)
    """
    a = a0
    results = []
    for k in range(1, max_precision + 1):
        pk = p ** k
        fa = f(a)
        results.append((k, a % pk, fa % pk))
        if k < max_precision:
            pk1 = p ** (k + 1)
            inv_fd = pow(f_deriv(a), -1, pk1)
            a = (a - fa * inv_fd) % pk1
    return results

# Example: sqrt(2) in 7-adic integers
results = hensel_lift(lambda x: x*x - 2, lambda x: 2*x, 3, 7, 8)
for k, ak, fk in results:
    print(f"  k={k}: a_k = {ak}, f(a_k) mod 7^k = {fk}")
