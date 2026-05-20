def coord_model_count(n: int, k: int) -> int:
    """Exact model count for coordinate theory with k fixed coordinates."""
    if k > n:
        return 0
    return 2 ** (n - k)

# Example
for n in [8, 16, 32]:
    for k in range(0, n+1, n//4):
        print(f"n={n}, k={k}: {coord_model_count(n,k)} models, entropy={n-k} bits")