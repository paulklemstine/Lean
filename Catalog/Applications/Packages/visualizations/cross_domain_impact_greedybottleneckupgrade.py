def greedy_upgrade(capacities, target):
    """Iteratively upgrade bottleneck set until target throughput reached."""
    current = capacities[:]
    rounds = 0
    while min(current) < target:
        m = min(current)
        current = [c + (1 if c == m else 0) for c in current]
        rounds += 1
    return current, rounds

# Example
caps = [3, 7, 5, 3, 9, 5]
final, rounds = greedy_upgrade(caps, 8)
print(f"Initial: {caps}, throughput = {min(caps)}")
print(f"Final:   {final}, throughput = {min(final)}")
print(f"Rounds:  {rounds}")