import math

def find_separation(param_dim, q, c, kl, n):
    """Find epsilon demonstrating strict separation between
    dimension-based and effective-complexity-based bounds."""
    eff = q + c + kl
    if eff >= param_dim or n <= 0:
        return None
    eps_sq = (eff + param_dim) / (2.0 * n)
    eps = math.sqrt(eps_sq)
    n_eps_sq = n * eps_sq
    print(f'epsilon = {eps:.4f}')
    print(f'Effective rate ({eff:.1f}) <= n*eps^2 ({n_eps_sq:.1f}): {eff <= n_eps_sq}')
    print(f'param_dim ({param_dim}) > n*eps^2 ({n_eps_sq:.1f}): {param_dim > n_eps_sq}')
    return eps

# Example: 1000 parameters, but only 9 effective complexity
find_separation(1000, 5, 3, 1.0, 100)