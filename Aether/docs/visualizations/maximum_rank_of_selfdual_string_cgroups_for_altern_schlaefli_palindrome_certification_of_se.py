from typing import List, Tuple

Perm = Tuple[int, ...]

def compose(p: Perm, q: Perm) -> Perm:
    return tuple(p[q[i]] for i in range(len(p)))

def order_of(p: Perm) -> int:
    n = len(p); e = tuple(range(n)); power = p; k = 1
    while power != e:
        power = compose(power, p); k += 1
    return k

def schlafli_palindrome_certificate(
    gens: List[Perm],
) -> Tuple[bool, List[int]]:
    r = len(gens)
    P = [[order_of(compose(gens[i], gens[j])) for j in range(r)]
         for i in range(r)]
    schlafli = [P[k][k + 1] for k in range(r - 1)]
    is_pal = all(schlafli[k] == schlafli[r - 2 - k]
                 for k in range(r - 1))
    return is_pal, schlafli
