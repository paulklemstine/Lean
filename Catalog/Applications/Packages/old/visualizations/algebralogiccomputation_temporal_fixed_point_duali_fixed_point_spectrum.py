def fixed_point_spectrum(step, states):
    visited = set()
    spectrum = []
    for x in sorted(states):
        if x not in visited:
            orbit = [x]; current = x
            while True:
                current = step[current]
                if current == x: break
                orbit.append(current)
            visited.update(orbit)
            spectrum.append(len(orbit))
    return sorted(set(spectrum))

# Example: (0 1)(2 3 4) on {0,...,4}
step = {0:1, 1:0, 2:3, 3:4, 4:2}
print(f"Spectrum: {fixed_point_spectrum(step, range(5))}")  # [2, 3]