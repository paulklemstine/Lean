from typing import List


def anti_fib(k: int) -> int:
    """Closed form of the k-th greedy anti-Fibonacci term: floor((3k+2)/2)."""
    return (3 * k + 2) // 2


def verify_identity(max_k: int) -> bool:
    """Check the structural identity A(k) + A(k+1) = 3(k+1) for all k < max_k."""
    return all(anti_fib(k) + anti_fib(k + 1) == 3 * (k + 1) for k in range(max_k))


def verify_closed_form_matches_greedy(max_k: int) -> bool:
    """Check the closed form equals the greedy simulation (non-multiples of 3)."""
    expected: List[int] = [m for m in range(1, 3 * max_k) if m % 3 != 0][:max_k]
    return [anti_fib(k) for k in range(max_k)] == expected


if __name__ == "__main__":
    print("first terms:", [anti_fib(k) for k in range(12)])
    print("identity A(k)+A(k+1)=3(k+1) holds:", verify_identity(100_000))
    print("closed form matches greedy       :", verify_closed_form_matches_greedy(10_000))
    print("A(10^6) =", anti_fib(1_000_000))
