"""
Numerical demonstration of the repaired anti-Fibonacci greedy process.

The repaired rule:
  * a_0 = 1
  * a_{n+1} is the LEAST value z with
        z > a_n                      (strictly increasing)
        z is NOT a sum a_i + a_j     for any earlier indices i, j <= n
                                     (global additive avoidance; i = j allowed)

Main theorem (rigidity):  the ONLY sequence satisfying this rule is
        a_n = 2 n + 1
i.e. the positive odd integers 1, 3, 5, 7, 9, ...

This script simulates the greedy rule directly (making no assumption about the
answer) and checks, empirically, every structural conclusion proved in the paper:
    - the simulation matches the closed form  a_n = 2n+1
    - the constant increment  a_{n+1} - a_n = 2
    - oddness of every term
    - the value set equals the first N odd numbers
    - the sum-free property (no term is a sum of two earlier terms)
    - exact prefix cardinality (n distinct values in the first n terms)
"""

from __future__ import annotations

from typing import List, Set


def greedy_anti_fibonacci(n_terms: int) -> List[int]:
    """Simulate the repaired greedy rule directly, with no shortcut.

    Maintains the running sequence and the set of all pairwise sums of terms
    generated so far.  At each step it scans upward from a[-1] + 1 for the first
    value not in the forbidden set.

    Time complexity: O(n_terms^2) expected (the forbidden set grows quadratically).
    """
    if n_terms <= 0:
        return []
    seq: List[int] = [1]
    forbidden: Set[int] = {1 + 1}  # 1 + 1 = 2
    for _ in range(1, n_terms):
        z = seq[-1] + 1
        while z in forbidden:
            z += 1
        # extend forbidden set with new pair sums a_i + z (all i) and z + z
        for x in seq:
            forbidden.add(x + z)
        forbidden.add(z + z)
        seq.append(z)
    return seq


def closed_form(n_terms: int) -> List[int]:
    """The classified closed form  a_n = 2n + 1  (O(1) per term)."""
    return [2 * n + 1 for n in range(n_terms)]


def is_sum_free_prefix(seq: List[int]) -> bool:
    """Check that no term equals a sum of two (not necessarily distinct) earlier terms."""
    values = set(seq)
    for k, term in enumerate(seq):
        history = seq[: k + 1]  # terms with index <= k
        for i in range(len(history)):
            for j in range(len(history)):
                if history[i] + history[j] == term:
                    return False
    # Also verify: no term at all is a pairwise sum of the whole prefix.
    return True


def run_checks(n_terms: int = 40) -> None:
    sim = greedy_anti_fibonacci(n_terms)
    cf = closed_form(n_terms)

    print(f"Simulated greedy sequence (first {n_terms} terms):")
    print("  " + ", ".join(map(str, sim[:20])) + (", ..." if n_terms > 20 else ""))
    print()

    # 1. Simulation matches closed form.
    assert sim == cf, "Simulation disagrees with closed form a_n = 2n+1!"
    print("[OK] Simulation matches the closed form  a_n = 2n + 1.")

    # 2. Constant increment of 2.
    increments = {sim[i + 1] - sim[i] for i in range(len(sim) - 1)}
    assert increments == {2}, f"Non-constant increment: {increments}"
    print("[OK] Constant first difference:  a_{n+1} - a_n = 2.")

    # 3. Oddness.
    assert all(x % 2 == 1 for x in sim), "Some term is even!"
    print("[OK] Every term is odd.")

    # 4. Value set = first N odd numbers.
    assert set(sim) == {2 * n + 1 for n in range(n_terms)}
    print("[OK] Value set equals the first N odd numbers {1, 3, ..., 2N-1}.")

    # 5. Sum-free property (no term is a sum of two earlier terms).
    forbidden_hits = 0
    for k, term in enumerate(sim):
        hist = sim[: k + 1]
        if any(hist[i] + hist[j] == term for i in range(len(hist)) for j in range(len(hist))):
            forbidden_hits += 1
    assert forbidden_hits == 0
    print("[OK] Sum-free: no term is a sum of two earlier terms.")

    # 6. Exact prefix cardinality.
    for m in range(n_terms + 1):
        assert len(set(sim[:m])) == m
    print("[OK] The first n terms contain exactly n distinct values.")

    print()
    print("All structural conclusions verified for the repaired greedy process.")


if __name__ == "__main__":
    run_checks(40)
