def compute_bottleneck_set(capacities):
    """Identify indices achieving minimum capacity. O(n)."""
    if not capacities:
        return set()
    m = min(capacities)
    return {i for i, c in enumerate(capacities) if c == m}

# Example
caps = [8, 5, 12, 5, 9]
print(f"Capacities: {caps}")
print(f"Bottleneck set: {compute_bottleneck_set(caps)}")
print(f"System throughput: {min(caps)}")