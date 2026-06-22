from collections import deque
from typing import Dict, List, Optional, Set, Tuple
import matplotlib.pyplot as plt

Atom = int
Theory = Set[Tuple[Atom, Atom]]

def min_proof_len(theory: Theory, a: Atom, b: Atom) -> Optional[int]:
    if a == b:
        return 0
    adj: Dict[Atom, List[Atom]] = {}
    for u, v in theory:
        adj.setdefault(u, []).append(v)
    dist: Dict[Atom, int] = {a: 0}; q: deque[Atom] = deque([a])
    while q:
        x = q.popleft()
        for y in adj.get(x, []):
            if y not in dist:
                dist[y] = dist[x] + 1; q.append(y)
    return dist.get(b)

def main() -> None:
    N = 32
    chain: Theory = {(k, k + 1) for k in range(N)}
    shortcuts: Theory = chain | {(k, k + 8) for k in range(0, N - 8, 8)}
    xs = list(range(N + 1))
    d_chain = [min_proof_len(chain, 0, n) for n in xs]
    d_short = [min_proof_len(shortcuts, 0, n) for n in xs]
    plt.figure(figsize=(8, 5))
    plt.plot(xs, d_chain, 'o-', label='chain: d(0,n) = n (diameter)')
    plt.plot(xs, d_short, 's-', label='with shortcuts (proofs shorten)')
    plt.xlabel('target atom n'); plt.ylabel('minimal proof length')
    plt.title('Diameter Theorem and Monotone Proof Shortening')
    plt.legend(); plt.grid(alpha=0.3); plt.tight_layout()
    plt.savefig('proof_distance.png', dpi=150)
    print('wrote proof_distance.png')

if __name__ == '__main__':
    main()
