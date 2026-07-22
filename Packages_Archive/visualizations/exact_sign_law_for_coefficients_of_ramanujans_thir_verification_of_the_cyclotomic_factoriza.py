from typing import List

PREC: int = 301

def mono(k: int) -> List[int]:
    v = [0] * PREC
    if k < PREC:
        v[k] = 1
    return v

def padd(a: List[int], b: List[int]) -> List[int]:
    return [a[i] + b[i] for i in range(PREC)]

def neg(a: List[int]) -> List[int]:
    return [-c for c in a]

def pmul(a: List[int], b: List[int]) -> List[int]:
    c = [0] * PREC
    for i in range(PREC):
        s = 0
        for j in range(i + 1):
            s += a[j] * b[i - j]
        c[i] = s
    return c

def check_cyclotomic(kmax: int = 8) -> bool:
    ok = True
    for k in range(kmax + 1):
        if 3 * k >= PREC:
            break
        lhs = pmul(padd(padd(mono(0), mono(k)), mono(2 * k)),
                   padd(mono(0), neg(mono(k))))
        rhs = padd(mono(0), neg(mono(3 * k)))
        ok = ok and (lhs == rhs)
    return ok

if __name__ == '__main__':
    print('cyclotomic identity holds:', check_cyclotomic())
