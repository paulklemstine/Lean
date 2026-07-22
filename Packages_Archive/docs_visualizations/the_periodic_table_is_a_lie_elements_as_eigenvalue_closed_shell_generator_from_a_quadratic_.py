from typing import List, Tuple

def cumulative_fillings(a: int, b: int, c: int, M: int) -> List[int]:
    out: List[int] = []
    running = 0
    for k in range(M + 1):
        running += a * k * k + b * k + c
        out.append(running)
    return out

def recover_law(fillings: List[int]) -> Tuple[float, float, float]:
    d1 = fillings[1] - fillings[0]
    d2 = fillings[2] - fillings[1]
    d3 = fillings[3] - fillings[2]
    a = (d3 - 2 * d2 + d1) / 2.0
    b = (d2 - d1) - 3.0 * a
    c = d1 - a - b
    return a, b, c
