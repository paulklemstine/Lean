def collatz_orbit(n: int) -> list[int]:
    orbit = [n]
    while n != 1 and len(orbit) < 10**6:
        n = n // 2 if n % 2 == 0 else 3 * n + 1
        orbit.append(n)
    return orbit