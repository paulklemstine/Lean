import random
from collections import deque
from typing import Dict, List, Set, Tuple
import matplotlib.pyplot as plt

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
    seen: Set[Atom] = {source}; q: deque[Atom] = deque([source])
    while q:
        x = q.popleft()
        for y in adj.get(x, []):
            if y not in seen:
                seen.add(y); q.append(y)
    return len(seen)

def main() -> None:
    n, trials = 600, 12
    rng = random.Random(1)
    cs = [i / 20 for i in range(1, 61)]
    fracs: List[float] = []
    for c in cs:
        acc = sum(conclusion_size(random_theory(n, c, rng), 0) / n
                  for _ in range(trials))
        fracs.append(acc / trials)
    plt.figure(figsize=(8, 5))
    plt.plot(cs, fracs, lw=2, color='crimson')
    plt.axvline(1.0, ls='--', color='gray', label='c = 1 (threshold)')
    plt.xlabel('rule density c (mean out-degree)')
    plt.ylabel('fraction derivable from source')
    plt.title('Proof Phase Transition in Random Implicational Theories')
    plt.legend(); plt.grid(alpha=0.3); plt.tight_layout()
    plt.savefig('proof_phase_transition.png', dpi=150)
    print('wrote proof_phase_transition.png')

if __name__ == '__main__':
    main()
