from fractions import Fraction
from typing import Dict, List, Sequence
Matrix = List[List[Fraction]]

def gaussian_rank(rows: Matrix) -> int:
    if not rows or not rows[0]:
        return 0
    m = [r[:] for r in rows]
    n_rows, n_cols, rank, pc = len(m), len(m[0]), 0, 0
    for r in range(n_rows):
        if pc >= n_cols:
            break
        piv = None
        while pc < n_cols:
            for i in range(r, n_rows):
                if m[i][pc] != 0:
                    piv = i
                    break
            if piv is not None:
                break
            pc += 1
        if piv is None:
            break
        m[r], m[piv] = m[piv], m[r]
        inv = m[r][pc]
        m[r] = [x / inv for x in m[r]]
        for i in range(n_rows):
            if i != r and m[i][pc] != 0:
                f = m[i][pc]
                m[i] = [a - f * b for a, b in zip(m[i], m[r])]
        rank += 1
        pc += 1
    return rank

def certify_bound(d2: Matrix, d1: Matrix, n_cells: int,
                  widths: Sequence[int]) -> Dict[str, object]:
    """Certify beta <= #cells <= 2^{sum w} for a decision-surface complex."""
    dim_c1 = len(d1[0]) if (d1 and d1[0]) else (len(d2) if d2 else 0)
    beta = (dim_c1 - gaussian_rank(d1)) - gaussian_rank(d2)
    ap_count = 2 ** sum(widths)
    step1 = beta <= n_cells
    step2 = n_cells <= ap_count
    return {
        "beta": beta,
        "n_cells": n_cells,
        "activation_patterns": ap_count,
        "beta_le_cells": step1,
        "cells_le_patterns": step2,
        "certified": step1 and step2,
    }
