"""Algorithm: Los-Vaught completeness check for finite toy theories.

Given an enumerable set of models of a theory T all of cardinality kappa,
decide completeness operationally: if all models are pairwise isomorphic, then
they agree on every (isomorphism-invariant) sentence, hence T is complete.
"""
from __future__ import annotations
from itertools import permutations, product
from dataclasses import dataclass
from typing import Callable, List, Tuple

@dataclass(frozen=True)
class Involution:
    n: int
    f: Tuple[int, ...]
    def is_valid(self) -> bool:
        return (len(self.f) == self.n
                and all(self.f[self.f[x]] == x for x in range(self.n))
                and all(self.f[x] != x for x in range(self.n)))

def are_isomorphic(a: Involution, b: Involution) -> bool:
    if a.n != b.n:
        return False
    return any(all(s[a.f[x]] == b.f[s[x]] for x in range(a.n))
               for s in permutations(range(a.n)))

def is_complete_by_los_vaught(models: List[Involution],
                              sentences: List[Callable[[Involution], bool]]) -> bool:
    categorical = all(are_isomorphic(models[i], models[j])
                      for i in range(len(models)) for j in range(i + 1, len(models)))
    agree = all(len({phi(m) for m in models}) == 1 for phi in sentences)
    return categorical and agree

if __name__ == "__main__":
    models = [Involution(2, f) for f in product(range(2), repeat=2)
              if Involution(2, f).is_valid()]
    print("complete?", is_complete_by_los_vaught(models, [lambda m: m.n % 2 == 0]))
