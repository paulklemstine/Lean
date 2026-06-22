import random
from collections import deque
from typing import Dict, List, Set, Tuple

Atom = int
Theory = Set[Tuple[Atom, Atom]]

def random_theory(n: int, c: float, rng: random.Random) -> Theory:
    p = min(1.0, c / n)
    return {(a, b) for a in range(n) for b in range(n)
            if a != b and rng.random() < p}

def conclusion_size(theory: Theory, source: Atom) -> int:
    adj: Dict[Atom, List[Atom]] = {}
    for u, v in theory:
        adj.setdefault(u, []).append(v)
    seen: Set[Atom] = {source}
    q: deque[Atom] = deque([source])
    while q:
        x = q.popleft()
        for y in adj.get(x, []):
            if y not in seen:
                seen.add(y); q.append(y)
    return len(seen)

def phase_scan(n: int, densities: List[float], trials: int,
               seed: int = 0) -> List[Tuple[float, float]]:
    rng = random.Random(seed)
    out: List[Tuple[float, float]] = []
    for c in densities:
        acc = sum(conclusion_size(random_theory(n, c, rng), 0) / n
                  for _ in range(trials))
        out.append((c, acc / trials))
    return out
