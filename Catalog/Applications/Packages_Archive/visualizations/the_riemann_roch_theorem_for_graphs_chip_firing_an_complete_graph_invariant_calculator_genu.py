from typing import Dict

def kn_invariants(n: int) -> Dict[str, int]:
    """Closed-form verified invariants of the complete graph K_n."""
    edges: int = n * (n - 1) // 2
    vertex_degree: int = n - 1
    genus: int = edges - n + 1            # (n-1)(n-2)/2
    canonical_coeff: int = vertex_degree - 2   # n-3
    canonical_degree: int = n * canonical_coeff  # n(n-3)
    assert canonical_degree == 2 * genus - 2
    return {
        'edges': edges,
        'vertex_degree': vertex_degree,
        'genus': genus,
        'canonical_coeff': canonical_coeff,
        'canonical_degree': canonical_degree,
    }
