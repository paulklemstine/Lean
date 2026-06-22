from itertools import combinations_with_replacement
from typing import List

def digits(n: int) -> List[int]:
    out: List[int] = []
    while n > 0:
        out.append(n % 10)
        n //= 10
    return out

def all_narcissistic(max_len: int) -> List[int]:
    """Enumerate every narcissistic number with at most `max_len` digits by
    iterating over digit MULTISETS rather than integers. For each length d, a
    candidate is a multiset (combination with repetition) of d digits; its
    power-sum T is accepted iff T has exactly d digits and the same digit
    multiset. Complexity per length d is C(d+9, 9), far below 10^d."""
    results: List[int] = []
    for d in range(1, max_len + 1):
        for combo in combinations_with_replacement(range(10), d):
            total = sum(a ** d for a in combo)
            if len(digits(total)) == d and sorted(digits(total)) == sorted(combo):
                results.append(total)
    return sorted(set(results))
