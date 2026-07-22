import math

def maslov_dequantize(z, eps):
    """Smooth approximation to max(z) via Maslov dequantization."""
    m = max(z)
    return eps * (m/eps + math.log(sum(math.exp((zi - m)/eps) for zi in z)))

z = [1.0, 3.0, 2.0, 0.5]
for eps in [10, 1, 0.1, 0.01]:
    approx = maslov_dequantize(z, eps)
    error = approx - max(z)
    bound = eps * math.log(len(z))
    print(f"eps={eps:5.2f}: max={max(z)}, approx={approx:.6f}, error={error:.6f} <= {bound:.6f}")
