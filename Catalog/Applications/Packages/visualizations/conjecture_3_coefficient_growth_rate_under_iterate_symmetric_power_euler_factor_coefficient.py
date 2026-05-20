def symm_euler_coefficients(alpha: complex, beta: complex, n: int) -> list:
    """Compute coefficients of prod_{j=0}^n (1 - alpha^{n-j} beta^j T)."""
    roots = [alpha ** (n - j) * beta ** j for j in range(n + 1)]
    coeffs = [complex(1)]
    for r in roots:
        new_coeffs = [complex(0)] * (len(coeffs) + 1)
        for i, c in enumerate(coeffs):
            new_coeffs[i] += c
            new_coeffs[i + 1] -= c * r
        coeffs = new_coeffs
    return coeffs

from math import comb

def coefficient_bound(n: int, k: int, M: float) -> float:
    """Sharp bound: C(n+1,k) * M^{E(n,k)}."""
    E = k * n - k * (k - 1) // 2
    return comb(n + 1, k) * M ** E

# Verify bounds
alpha, beta = 2.0, 0.5
M = max(abs(alpha), abs(beta))
for n in range(1, 6):
    coeffs = symm_euler_coefficients(alpha, beta, n)
    for k in range(n + 2):
        actual = abs(coeffs[k])
        bound = coefficient_bound(n, k, M)
        status = "OK" if actual <= bound + 1e-10 else "FAIL"
        print(f"n={n}, k={k}: |c|={actual:.4f}, bound={bound:.4f} [{status}]")