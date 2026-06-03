def collatz_orbit(n: int, max_steps: int = 100000) -> list[int]:
    orbit = [n]
    while n != 1 and len(orbit) < max_steps:
        n = n // 2 if n % 2 == 0 else 3 * n + 1
        orbit.append(n)
    return orbit