from typing import Tuple, Dict

Belnap = str  # 'N','F','T','B'
TO_PROD: Dict[Belnap, Tuple[bool, bool]] = {
    'N': (False, False), 'F': (False, True),
    'T': (True, False),  'B': (True, True),
}
OF_PROD = {v: k for k, v in TO_PROD.items()}

def neg(a: Belnap) -> Belnap:
    f, g = TO_PROD[a]
    return OF_PROD[(g, f)]

def designated(a: Belnap) -> bool:
    return a in ('T', 'B')

def classify(a: Belnap) -> str:
    if designated(a) and designated(neg(a)):
        return 'GLUT'
    if not designated(a) and not designated(neg(a)):
        return 'GAP'
    return 'PLAIN'

if __name__ == '__main__':
    for a in ('N', 'F', 'T', 'B'):
        print(a, classify(a))
