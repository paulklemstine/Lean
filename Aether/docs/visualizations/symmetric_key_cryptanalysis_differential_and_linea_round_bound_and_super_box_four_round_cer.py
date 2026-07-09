from typing import List, Tuple

State = List[List[int]]


def aes_shift_rows(a: State) -> State:
    """AES ShiftRows: row i is cyclically shifted left by i."""
    n = len(a)
    return [[a[i][(j + i) % n] for j in range(n)] for i in range(n)]


def _col_weight(a: State, j: int) -> int:
    return sum(1 for i in range(len(a)) if a[i][j] != 0)


def _col_active(a: State) -> int:
    n = len(a[0])
    return sum(1 for j in range(n) if any(a[i][j] != 0 for i in range(len(a))))


def _wt(a: State) -> int:
    return sum(1 for row in a for x in row if x != 0)


def _round_bound_holds(a_in: State, a_out: State, B: int) -> bool:
    sr = aes_shift_rows(a_in)
    n = len(a_in[0])
    for j in range(n):
        ain = any(sr[i][j] != 0 for i in range(len(sr)))
        aout = any(a_out[i][j] != 0 for i in range(len(a_out)))
        if ain != aout:
            return False
        if ain and not (B <= _col_weight(sr, j) + _col_weight(a_out, j)):
            return False
    return B * _col_active(a_out) <= _wt(a_in) + _wt(a_out)


def four_round_branch_certificate(
    a1: State, a2: State, a3: State, a4: State, B: int
) -> Tuple[bool, int, int]:
    """
    Round-bound / super-box verification.

    Verify, for a four-round trail with branch number B:
      - the round bound for rounds 1 (a1->a2) and 3 (a3->a4),
      - the super-box branch B <= colActive(a2) + colActive(a4),
    and certify the conclusion B*B <= total active S-boxes.

    Returns (certified, B*B, total).
    Complexity: O(r * c) per round.
    """
    rounds_ok = _round_bound_holds(a1, a2, B) and _round_bound_holds(a3, a4, B)
    super_ok = B <= _col_active(a2) + _col_active(a4)
    total = _wt(a1) + _wt(a2) + _wt(a3) + _wt(a4)
    return (rounds_ok and super_ok and B * B <= total), B * B, total
