from typing import List

def literal_sequence(length: int) -> List[int]:
    """Generate the least-positive singleton-sum-avoidance trajectory."""
    if length < 0:
        raise ValueError("length must be nonnegative")
    if length == 0:
        return []
    values = [1] if length == 1 else [1, 1]
    while len(values) < length:
        forbidden = values[-2] + values[-1]
        candidate = 1
        while candidate == forbidden:
            candidate += 1
        values.append(candidate)
    return values

if __name__ == "__main__":
    values = literal_sequence(20)
    print(values)
    assert values == [1] * 20
