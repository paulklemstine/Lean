def find_cycle(f: list[int], start: int) -> tuple[int, int]:
    """Find first collision in orbit of f from start."""
    n = len(f)
    seen = {start: 0}
    x = start
    for step in range(1, n + 2):
        x = f[x]
        if x in seen:
            return seen[x], step
        seen[x] = step
    raise ValueError('No cycle found (impossible for finite types)')

# Example: cycle of length 4
f = [1, 2, 3, 0, 4]
i, j = find_cycle(f, 0)
print(f'f^{i}(0) = f^{j}(0), cycle length = {j-i}')