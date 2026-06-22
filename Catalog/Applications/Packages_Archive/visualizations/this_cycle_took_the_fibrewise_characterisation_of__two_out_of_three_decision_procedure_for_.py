from typing import Callable, Hashable, Sequence, TypeVar
A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)
C = TypeVar("C", bound=Hashable)

def is_bijective(f: Callable[[A], B], domain: Sequence[A],
                 codomain: Sequence[B]) -> bool:
    img = [f(a) for a in domain]
    return len(set(img)) == len(img) and set(img) == set(codomain)

def two_out_of_three(f: Callable[[A], B], g: Callable[[B], C],
                     A_set: Sequence[A], B_set: Sequence[B],
                     C_set: Sequence[C]) -> dict:
    """Decide each of f, g, g.f and verify the two-out-of-three law:
    any two equivalences force the third."""
    gf: Callable[[A], C] = lambda a: g(f(a))
    bf = is_bijective(f, A_set, B_set)
    bg = is_bijective(g, B_set, C_set)
    bgf = is_bijective(gf, A_set, C_set)
    # The three legs (logical implications) must all hold:
    assert (bf and bg) <= bgf          # leg 1: f,g => g.f
    assert (bg and bgf) <= bf          # leg 2: g,g.f => f
    assert (bf and bgf) <= bg          # leg 3: f,g.f => g
    return {"f": bf, "g": bg, "g_after_f": bgf}
