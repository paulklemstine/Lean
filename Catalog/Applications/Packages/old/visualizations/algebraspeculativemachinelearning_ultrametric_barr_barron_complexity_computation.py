def compute_barron_complexity(points, contraction):
    """Compute Barron complexity = |Im(C)| by the duality theorem."""
    return len(set(contraction.values()))

# Example: 8 points with pairwise contraction
points = list(range(8))
contraction = {i: i // 2 * 2 for i in range(8)}
bc = compute_barron_complexity(points, contraction)
print(f"Points: {len(points)}, Barron complexity: {bc}")
