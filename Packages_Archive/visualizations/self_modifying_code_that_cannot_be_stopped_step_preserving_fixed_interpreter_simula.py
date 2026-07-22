from __future__ import annotations
from dataclasses import dataclass
from typing import Optional

@dataclass(frozen=True)
class Config:
    a: int
    b: int
    value: int

def step(c: Config, limit: int) -> Optional[Config]:
    if c.value >= limit:
        return None
    return Config(c.b, c.a + c.b, c.value + c.a)

def compare(limit: int = 50, budget: int = 20) -> bool:
    mutable = Config(1, 1, 0)
    encoded = (1, 1, 0)
    for _ in range(budget):
        successor = step(mutable, limit)
        a, b, value = encoded
        fixed = None if value >= limit else (b, a + b, value + a)
        if (None if successor is None else (successor.a, successor.b, successor.value)) != fixed:
            return False
        if successor is None:
            return True
        mutable, encoded = successor, fixed
    return True

if __name__ == "__main__":
    print("Exact traces:", compare())
