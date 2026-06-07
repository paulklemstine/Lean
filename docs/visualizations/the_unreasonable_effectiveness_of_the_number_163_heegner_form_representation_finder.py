def form_representations(n: int, c: int = 41, bound: int = 100):
    reps = []
    for y in range(-bound, bound + 1):
        for x in range(-bound, bound + 1):
            if x*x + x*y + c*y*y == n:
                reps.append((x, y))
    return reps