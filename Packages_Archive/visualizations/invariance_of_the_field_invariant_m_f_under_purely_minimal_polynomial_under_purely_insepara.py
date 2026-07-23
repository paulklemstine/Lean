from typing import Dict, Tuple

Poly = Dict[int, Dict[int, int]]  # X-exponent -> (base-var exponent -> coeff in F_p)


def _normalize(f: Poly, p: int) -> Poly:
    out: Poly = {}
    for xe, c in f.items():
        cc = {be: v % p for be, v in c.items() if v % p != 0}
        if cc:
            out[xe] = cc
    return out


def _is_pth_power(f: Poly, p: int) -> bool:
    return all(xe % p == 0 and all(be % p == 0 for be in c) for xe, c in f.items())


def _pth_root(f: Poly, p: int) -> Poly:
    return _normalize({xe // p: {be // p: v for be, v in c.items()}
                       for xe, c in f.items()}, p)


def minpoly_over_N(f: Poly, p: int, k: int) -> Tuple[Poly, int]:
    """Minimal polynomial of theta over N = K(t^{1/p^k}), with K = F_p(t).

    Base change t |-> u^{p^k} sends f to f~ = (minpoly_N theta)^{p^j}; we recover
    minpoly_N theta by maximal p-th root extraction. Returns (minpoly_N theta, j).
    """
    ftilde = _normalize({xe: {be * p ** k: v for be, v in c.items()}
                         for xe, c in f.items()}, p)
    j = 0
    while _is_pth_power(ftilde, p):
        ftilde = _pth_root(ftilde, p)
        j += 1
    return ftilde, j
