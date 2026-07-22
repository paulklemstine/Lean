from typing import List

def truncated_profile(depth: int, cutoff: int) -> List[int]:
    if depth < 0 or cutoff < 0:
        raise ValueError("nonnegative inputs required")
    values = [1]
    for _ in range(depth):
        values.append(cutoff * values[-1] + 1)
    return values

if __name__ == "__main__":
    print(truncated_profile(6, 10))
