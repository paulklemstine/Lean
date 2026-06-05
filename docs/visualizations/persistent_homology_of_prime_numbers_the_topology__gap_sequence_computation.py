def compute_gap_sequence(points: list[int]) -> list[int]:
    return [points[i+1] - points[i] for i in range(len(points) - 1)]