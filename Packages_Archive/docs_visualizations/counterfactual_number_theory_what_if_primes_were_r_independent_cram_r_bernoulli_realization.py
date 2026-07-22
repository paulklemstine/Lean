import math
import random

def sample_counts(limit: int, trials: int, seed: int = 0) -> list[int]:
    if limit < 0 or trials < 0:
        raise ValueError("limits must be nonnegative")
    rng = random.Random(seed)
    counts: list[int] = []
    for _ in range(trials):
        count = 0
        for n in range(limit):
            probability = min(1.0, 1.0 / math.log(n + 2))
            count += rng.random() < probability
        counts.append(count)
    return counts

if __name__ == "__main__":
    values = sample_counts(10000, 20, 2026)
    print(values)
    print("mean", sum(values) / len(values))
