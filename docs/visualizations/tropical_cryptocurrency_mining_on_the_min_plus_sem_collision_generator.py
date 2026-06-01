def generate_collision(m: list[int], h: list[int]) -> list[int]:
    sums = [m[i] + h[i] for i in range(len(m))]
    j = sums.index(min(sums))
    return [m[i] + (0 if i == j else 1) for i in range(len(m))]