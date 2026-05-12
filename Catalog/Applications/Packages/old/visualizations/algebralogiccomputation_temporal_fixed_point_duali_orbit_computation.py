def compute_orbit(step, x):
    orbit = [x]
    current = x
    while True:
        current = step[current]
        if current == x:
            break
        orbit.append(current)
    return orbit, len(orbit)

# Example: cyclic permutation on {0,...,4}
step = {i: (i+1) % 5 for i in range(5)}
orbit, period = compute_orbit(step, 0)
print(f"Orbit of 0: {orbit}, Period: {period}")