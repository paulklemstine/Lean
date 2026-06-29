from typing import Callable, Set

Belnap = str

def glut_locus(v: Callable[[int], Belnap], n: int) -> Set[int]:
    return {k for k in range(n) if v(k) == 'B'}

def dream_open(s: Set[int], is_full_space: bool) -> bool:
    return True if is_full_space else (len(s) < float('inf'))

if __name__ == '__main__':
    v = lambda k: 'B' if k % 2 == 0 else 'T'
    loc = glut_locus(v, 12)
    print('glut locus:', sorted(loc))
    print('evens; not dream-open in finite-or-univ space (infinite, != N)')
