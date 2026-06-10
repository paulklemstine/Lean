#!/usr/bin/env python3
"""
Algorithms for Perturbed Fibonacci Sequences

Type-hinted implementations of all core algorithms from the theory.
"""

from typing import Callable, List, Tuple


def fibonacci(n: int) -> int:
    """Standard Fibonacci number F(n) with F(0)=0, F(1)=1.

    Time: O(n), Space: O(1)
    """
    if n <= 0:
        return 0
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b


def fibonacci_shifted(n: int) -> int:
    """Shifted Fibonacci: fib'(n) = F(n+1), starting 1, 1, 2, 3, 5, 8, ...

    This is the natural indexing for perturbed Fibonacci sequences.
    """
    return fibonacci(n + 1)


def perturbed_fibonacci(
    perturbation: Callable[[int], int],
    n: int,
    initial: Tuple[int, int] = (1, 1)
) -> int:
    """Compute the n-th term of the perturbed Fibonacci sequence.

    P(0) = initial[0], P(1) = initial[1]
    P(k+2) = P(k+1) + P(k) + perturbation(k)

    Args:
        perturbation: Function f: ℕ → ℤ giving the perturbation at each step
        n: Index to compute
        initial: Initial values (P(0), P(1))

    Returns:
        P(n)
    """
    if n == 0:
        return initial[0]
    if n == 1:
        return initial[1]
    prev2, prev1 = initial
    for k in range(2, n + 1):
        curr = prev1 + prev2 + perturbation(k - 2)
        prev2, prev1 = prev1, curr
    return prev1


def perturbed_fibonacci_sequence(
    perturbation: Callable[[int], int],
    length: int,
    initial: Tuple[int, int] = (1, 1)
) -> List[int]:
    """Compute the first `length` terms of the perturbed Fibonacci sequence.

    Args:
        perturbation: Function f: ℕ → ℤ
        length: Number of terms to compute
        initial: Initial values (P(0), P(1))

    Returns:
        List [P(0), P(1), ..., P(length-1)]
    """
    if length == 0:
        return []
    if length == 1:
        return [initial[0]]
    result = [initial[0], initial[1]]
    for k in range(2, length):
        result.append(result[-1] + result[-2] + perturbation(k - 2))
    return result


def fibonacci_deviation(
    perturbation: Callable[[int], int],
    n: int
) -> int:
    """Compute the Fibonacci deviation: dev(f, n) = pertFib(f, n) - fib'(n).

    The deviation measures how far the perturbed sequence is from standard Fibonacci.
    Key property: dev is a LINEAR operator on perturbation functions.
    """
    return perturbed_fibonacci(perturbation, n) - fibonacci_shifted(n)


def constant_perturbation_closed_form(c: int, n: int) -> int:
    """Closed form for constant perturbation c.

    P(n) = (1 + c) * fib'(n) - c

    This is the main structural result: constant perturbation just scales
    the Fibonacci sequence and shifts it.
    """
    return (1 + c) * fibonacci_shifted(n) - c


def anti_fibonacci(n: int) -> int:
    """The Anti-Fibonacci sequence: P(n) = 2 * fib'(n) - 1.

    This is the c=1 constant perturbation. Each term exceeds the
    Fibonacci prediction by exactly 1. The sequence is always odd.

    First terms: 1, 1, 3, 5, 9, 15, 25, 41, 67, 109, ...
    """
    return 2 * fibonacci_shifted(n) - 1


def recover_perturbation(
    deviation: Callable[[int], int],
    n: int
) -> int:
    """Recover the perturbation from the deviation sequence.

    f(n) = dev(n+2) - dev(n+1) - dev(n)

    This is the inverse of the deviation map, showing the map is bijective
    (onto sequences with dev(0) = dev(1) = 0).
    """
    return deviation(n + 2) - deviation(n + 1) - deviation(n)


def superposition(
    f: Callable[[int], int],
    g: Callable[[int], int],
    n: int
) -> int:
    """Verify the superposition principle:

    pertFib(f + g, n) = pertFib(f, n) + pertFib(g, n) - fib'(n)

    Returns the left-hand side (which should equal the right-hand side).
    """
    return perturbed_fibonacci(lambda k: f(k) + g(k), n)


def verify_superposition(
    f: Callable[[int], int],
    g: Callable[[int], int],
    max_n: int = 100
) -> bool:
    """Verify the superposition principle up to index max_n.

    Returns True if pertFib(f+g, n) = pertFib(f, n) + pertFib(g, n) - fib'(n)
    holds for all n in [0, max_n].
    """
    pf = perturbed_fibonacci_sequence(f, max_n + 1)
    pg = perturbed_fibonacci_sequence(g, max_n + 1)
    pfg = perturbed_fibonacci_sequence(lambda k: f(k) + g(k), max_n + 1)
    fib = [fibonacci_shifted(n) for n in range(max_n + 1)]

    for n in range(max_n + 1):
        if pfg[n] != pf[n] + pg[n] - fib[n]:
            return False
    return True


def local_fibonacci_check(
    perturbation: Callable[[int], int],
    max_n: int = 100
) -> List[int]:
    """Find all indices where the perturbed sequence locally satisfies
    the Fibonacci recurrence (i.e., where f(n) = 0).

    Returns list of indices n where P(n+2) = P(n+1) + P(n).
    """
    return [n for n in range(max_n) if perturbation(n) == 0]


if __name__ == "__main__":
    # Quick self-test
    print("Running algorithm self-tests...")

    # Test closed form
    for c in range(-5, 6):
        for n in range(20):
            assert perturbed_fibonacci(lambda _, c=c: c, n) == constant_perturbation_closed_form(c, n), \
                f"Closed form failed at c={c}, n={n}"
    print("✓ Constant perturbation closed form verified")

    # Test anti-Fibonacci
    for n in range(20):
        af = anti_fibonacci(n)
        assert af == perturbed_fibonacci(lambda _: 1, n)
        assert af % 2 == 1, f"Anti-Fibonacci not odd at n={n}"
    print("✓ Anti-Fibonacci closed form and oddness verified")

    # Test c=-1 fixed point
    for n in range(50):
        assert perturbed_fibonacci(lambda _: -1, n) == 1
    print("✓ c=-1 fixed point verified")

    # Test superposition
    assert verify_superposition(lambda k: k, lambda k: (-1)**k, 50)
    assert verify_superposition(lambda k: k**2, lambda _: 3, 50)
    print("✓ Superposition principle verified")

    # Test recovery
    test_f = lambda k: 2 * k + 1
    for n in range(30):
        dev_f = lambda m: fibonacci_deviation(test_f, m)
        assert recover_perturbation(dev_f, n) == test_f(n), \
            f"Recovery failed at n={n}"
    print("✓ Perturbation recovery verified")

    print("\nAll algorithm self-tests passed! ✓")
