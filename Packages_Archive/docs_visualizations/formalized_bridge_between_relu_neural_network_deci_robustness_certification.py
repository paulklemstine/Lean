import math

def certify_robustness(phi, y_true, eps, L):
    """Certified robustness via Maslov dequantization."""
    d = len(phi[0])
    trop_scores = [max(p) for p in phi]
    gamma = trop_scores[y_true] - max(s for k,s in enumerate(trop_scores) if k != y_true)
    gamma_eff = gamma - 2 * eps * math.log(d)
    return max(0, gamma_eff / (2 * L)) if gamma_eff > 0 else 0.0

# Example: 3-class, 4 pieces/class, L=2
phi = [[3,2.5,1,0.5], [8,7.5,6,5], [4,3.5,2,1.5]]
for eps in [0.01, 0.1, 1.0]:
    r = certify_robustness(phi, 1, eps, 2.0)
    print(f"eps={eps}: certified_radius={r:.4f}")
