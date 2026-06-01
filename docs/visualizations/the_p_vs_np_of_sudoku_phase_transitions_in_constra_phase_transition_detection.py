def detect_phase_transition(n: int, steps: int = 20, samples: int = 50) -> list:
    results = []
    for i in range(steps + 1):
        d = i / steps
        filled = int(d * n * n)
        sat_count = sum(1 for _ in range(samples) if test_random_instance(n, filled))
        results.append((d, sat_count / samples))
    return results