from dataclasses import dataclass
from typing import List

@dataclass(frozen=True)
class Proof:
    complexity: int

def long_chain(N: int) -> List[Proof]:
    return [Proof(complexity=N - i) for i in range(N + 1)]

def is_strictly_descending(chain: List[Proof]) -> bool:
    return all(chain[i + 1].complexity < chain[i].complexity
               for i in range(len(chain) - 1))
