from typing import List

def euler_zigzag_numbers(max_n: int) -> List[int]:
    """Compute E_0,...,E_max_n by the Entringer triangle."""
    if max_n < 0:
        raise ValueError("max_n must be nonnegative")
    row, answer = [1], [1]
    for n in range(1, max_n + 1):
        next_row = [0] * (n + 1)
        for k in range(1, n + 1):
            next_row[k] = next_row[k - 1] + row[n - k]
        row = next_row
        answer.append(row[n])
    return answer
