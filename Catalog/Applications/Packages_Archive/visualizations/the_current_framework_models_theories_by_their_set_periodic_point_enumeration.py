def periodic_points(step, states, n):
    """Enumerate n-periodic points of a finite dynamical system."""
    result = set()
    for x in states:
        y = x
        for _ in range(n):
            y = step[y]
        if y == x:
            result.add(x)
    return result

# Example
step = {0: 1, 1: 2, 2: 0, 3: 4, 4: 3, 5: 5}
for n in range(7):
    pts = periodic_points(step, range(6), n)
    print(f'Per_{n} = {sorted(pts)}')