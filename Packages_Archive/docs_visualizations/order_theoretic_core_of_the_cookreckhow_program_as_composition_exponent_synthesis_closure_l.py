from typing import Callable

def composition_exponent(a: int, b: int) -> int:
    """Exponent a*(b+1) certifying f . g, per the closure lemma."""
    return a * (b + 1)

def verify_composition_closure(f: Callable[[int], int], g: Callable[[int], int],
                               a: int, b: int, n_max: int) -> bool:
    k = composition_exponent(a, b)
    return all(f(g(n)) + 1 <= (n + 2) ** k for n in range(n_max + 1))