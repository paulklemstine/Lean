def optimal_cell_count(generators, D):
    """Count generators exceeding distortion threshold D.
    Time: O(|α|), Space: O(1)."""
    return sum(1 for v in generators.values() if v > D)

# Example
generators = {0: 1, 1: 2, 2: 3, 3: 1}
for D in [0, 1, 2, 3]:
    print(f"R({D}) = {optimal_cell_count(generators, D)}")
