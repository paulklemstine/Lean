def moebius_orbit(g: float, n: int) -> list:
    orbit = [0.0]
    for _ in range(n):
        orbit.append((g + orbit[-1]) / (1 + g * orbit[-1]))
    return orbit