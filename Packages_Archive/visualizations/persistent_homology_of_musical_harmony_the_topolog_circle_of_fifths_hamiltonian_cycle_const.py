from math import gcd
from typing import List

def circle_of_fifths(n: int = 12, step: int = 7) -> List[int]:
    """Construct the circle-of-fifths traversal i -> (step*i) mod n."""
    return [(step * i) % n for i in range(n)]

def is_hamiltonian(seq: List[int], n: int = 12) -> bool:
    """Verify a traversal visits every pitch class exactly once."""
    return len(seq) == n and set(seq) == set(range(n))

def hamiltonian_generator_exists(n: int = 12, step: int = 7) -> bool:
    """The step-interval yields a Hamiltonian cycle iff it is coprime to n.
    Complexity: O(n) to build and check the traversal.
    """
    return is_hamiltonian(circle_of_fifths(n, step), n) == (gcd(n, step) == 1)
