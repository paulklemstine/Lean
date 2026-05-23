def isolated_vertex_expectation(n: int, p: float) -> float:
    """E[isolated vertex count] = n * (1-p)^(n-1)"""
    if n <= 0: return 0.0
    return n * (1 - p) ** (n - 1)

# Example
print(isolated_vertex_expectation(100, 0.05))