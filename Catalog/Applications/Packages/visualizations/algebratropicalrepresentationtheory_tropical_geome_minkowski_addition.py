def minkowski_add(w1, level1, w2, level2):
    """Minkowski addition of two tropical MV polytopes."""
    return [a + b for a, b in zip(w1, w2)], level1 + level2

# Example
w, lev = minkowski_add([0, 1, 0], 1, [0, 0, 1], 1)
print(f"Weight: {w}, Level: {lev}")  # [0, 1, 1], 2
