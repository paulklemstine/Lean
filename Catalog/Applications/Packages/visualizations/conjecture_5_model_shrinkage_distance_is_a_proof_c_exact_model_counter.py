import itertools
from typing import Callable, Set, Tuple

class ExactModelCounter:
    """Brute-force exact model counter for propositional constraints."""
    def __init__(self, n_vars: int):
        self.n_vars = n_vars
        self._all = list(itertools.product([False, True], repeat=n_vars))
    
    def count(self, predicate: Callable[[Tuple[bool,...]], bool]) -> int:
        return sum(1 for a in self._all if predicate(a))
    
    def model_set(self, predicate: Callable) -> Set[Tuple[bool,...]]:
        return {a for a in self._all if predicate(a)}

# Example
counter = ExactModelCounter(5)
print(f"All assignments: {counter.count(lambda a: True)}")
print(f"x0=True: {counter.count(lambda a: a[0])}")
print(f"x0 AND x1: {counter.count(lambda a: a[0] and a[1])}")
