def collatz_orbit(n: int, max_steps: int = 10000) -> list[int]:
    orbit = [n]
    current = n
    for _ in range(max_steps):
        if current == 1:
            break
        current = current // 2 if current % 2 == 0 else 3 * current + 1
        orbit.append(current)
    return orbit