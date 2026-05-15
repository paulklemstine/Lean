def recover_exponent_scalar_diag(observed_d: float, lam: float) -> int:
    """Recover secret exponent from observed diagonal entry.
    
    Given d = (G^a)_{ii} = a * lam for scalar diagonal G,
    recovers a = d / lam.
    
    Complexity: O(1)
    """
    if lam == 0:
        raise ValueError("Cannot recover exponent when lambda = 0")
    a_real = observed_d / lam
    a_int = int(round(a_real))
    if abs(a_real - a_int) < 1e-9 and a_int >= 0:
        return a_int
    return None

# Example
lam = 3.5
secret = 42
observed = secret * lam  # = 147.0
recovered = recover_exponent_scalar_diag(observed, lam)
print(f"Secret: {secret}, Recovered: {recovered}, Match: {secret == recovered}")
