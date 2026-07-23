from typing import Callable, List, Optional, Tuple

Belnap = str
VALUES: List[Belnap] = ['N', 'F', 'T', 'B']

def neg(a: Belnap) -> Belnap:
    return {'N': 'N', 'F': 'T', 'T': 'F', 'B': 'B'}[a]

def designated(a: Belnap) -> bool:
    return a in ('T', 'B')

def explosion_witness() -> Optional[Tuple[Belnap, Belnap]]:
    for a in VALUES:
        if designated(a) and designated(neg(a)):
            for q in VALUES:
                if not designated(q):
                    return (a, q)
    return None

if __name__ == '__main__':
    w = explosion_witness()
    print('paraconsistent' if w else 'explosive', 'witness=', w)
