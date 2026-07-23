from typing import Sequence

def recover_k(v_in: Sequence[int], v_out: Sequence[int],
              lam: int, i: int = 0) -> int:
    if lam == 0:
        raise ValueError('eigenvalue lambda must be nonzero')
    diff = v_out[i] - v_in[i]   # = k * lam (iterate_eigenline_attack)
    assert diff % lam == 0
    return diff // lam          # tdlp_recover_eigenline when lam == 1
