from typing import List, Tuple

Strategy = Tuple[float, float]
Profile = Tuple[Strategy, Strategy]

def expected_payoffs(A: List[List[float]], B: List[List[float]],
                     p: Strategy, q: Strategy) -> Tuple[float, float]:
    u1 = sum(A[i][j] * p[i] * q[j] for i in range(2) for j in range(2))
    u2 = sum(B[i][j] * p[i] * q[j] for i in range(2) for j in range(2))
    return u1, u2

def improvement_step(A: List[List[float]], B: List[List[float]], profile: Profile) -> Profile:
    p, q = profile
    u1, u2 = expected_payoffs(A, B, p, q)
    g1 = [max(0.0, sum(A[i][j] * q[j] for j in range(2)) - u1) for i in range(2)]
    g2 = [max(0.0, sum(B[i][j] * p[i] for i in range(2)) - u2) for j in range(2)]
    new_p = tuple((p[i] + g1[i]) / (1 + sum(g1)) for i in range(2))
    new_q = tuple((q[j] + g2[j]) / (1 + sum(g2)) for j in range(2))
    return (new_p, new_q)  # type: ignore[return-value]

def max_regret(A: List[List[float]], B: List[List[float]], profile: Profile) -> float:
    p, q = profile
    u1, u2 = expected_payoffs(A, B, p, q)
    r1 = max(sum(A[i][j] * q[j] for j in range(2)) - u1 for i in range(2))
    r2 = max(sum(B[i][j] * p[i] for i in range(2)) - u2 for j in range(2))
    return max(r1, r2)

def find_nash(A: List[List[float]], B: List[List[float]], grid: int = 200) -> Profile:
    best, best_r = ((1.0, 0.0), (1.0, 0.0)), float("inf")
    for a in range(grid + 1):
        p = (a / grid, 1 - a / grid)
        for b in range(grid + 1):
            q = (b / grid, 1 - b / grid)
            r = max_regret(A, B, (p, q))
            if r < best_r:
                best_r, best = r, (p, q)
    return best
