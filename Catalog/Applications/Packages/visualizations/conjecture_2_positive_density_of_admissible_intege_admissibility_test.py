def is_admissible(k: int) -> bool:
    """Check if k is admissible for sum-of-three-cubes (k mod 9 not in {4, 5})."""
    return k % 9 not in (4, 5)

# Example
for k in range(20):
    print(f"{k}: admissible={is_admissible(k)}, k%9={k%9}")