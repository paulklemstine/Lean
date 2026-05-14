def portal_threshold(c: int, k: int = 8) -> float:
    """Compute distance threshold beyond which Nether dominates."""
    return 2 * c * k / (k - 1)

def use_nether(c: int, d: int, k: int = 8) -> bool:
    """Decide whether to use Nether (compressed) travel."""
    return d > portal_threshold(c, k)

# Examples
for c in [10, 50, 100]:
    t = portal_threshold(c)
    print(f'Portal cost {c}: threshold = {t:.1f}')