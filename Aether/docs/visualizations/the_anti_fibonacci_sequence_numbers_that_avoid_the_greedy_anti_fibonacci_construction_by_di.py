from typing import List, Set, Tuple


def greedy_anti_fibonacci(n_terms: int) -> Tuple[List[int], Set[int]]:
    """Directly simulate the greedy anti-Fibonacci rule.

    Start at 1; at each step append the smallest positive integer not yet used
    that is not equal to any consecutive sum A(i)+A(i+1) of earlier terms.
    Returns (terms, avoided_values).
    """
    if n_terms <= 0:
        return [], set()
    terms: List[int] = [1]
    forbidden: Set[int] = set()
    used: Set[int] = {1}
    while len(terms) < n_terms:
        if len(terms) >= 2:
            forbidden.add(terms[-1] + terms[-2])
        candidate = terms[-1] + 1
        while candidate in used or candidate in forbidden:
            candidate += 1
        terms.append(candidate)
        used.add(candidate)
    return terms, forbidden


if __name__ == "__main__":
    terms, forbidden = greedy_anti_fibonacci(15)
    print("terms  :", terms)
    print("avoided:", sorted(forbidden)[:10])
    assert terms == [m for m in range(1, 60) if m % 3 != 0][:15]
    print("confirmed: terms are exactly the positive non-multiples of 3")
