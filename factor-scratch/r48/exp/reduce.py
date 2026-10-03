"""Lattice reduction backends.

Primary: fpylll (exact integer LLL, the production implementation).
Cross-check: the hand-rolled lll.py.  `reduce_exact` runs fpylll and then,
when small enough, re-reduces with the hand-rolled reducer and confirms both
agree on the shortest-vector norm to within a fraction of a bit.  A
disagreement means the instrument is untrustworthy, so the caller is told.
"""
import math
from lll import lll as _hand_lll, verify as _hand_verify, _det_int, row_log2norm

try:
    from fpylll import IntegerMatrix, LLL as _FpLLL
    HAVE_FPYLLL = True
except Exception:            # pragma: no cover
    HAVE_FPYLLL = False


def reduce_fpylll(rows, delta=0.99):
    n = len(rows)
    d = len(rows[0])
    M = IntegerMatrix(n, d)
    for i in range(n):
        ri = rows[i]
        for j in range(d):
            M[i, j] = int(ri[j])
    _FpLLL.reduction(M, delta=delta)
    return [[int(M[i, j]) for j in range(d)] for i in range(n)]


def reduce_hand(rows, delta=0.99, max_steps=200000):
    return _hand_lll(rows, delta=delta, max_steps=max_steps)


def det(rows):
    return _det_int(rows)


def verify(rows_in, rows_out, delta=0.99):
    return _hand_verify(rows_in, rows_out, delta=delta)


def reduce_exact(rows, delta=0.99, cross_check=True):
    """Returns (reduced_rows, diagnostics).  Fails loudly on cross-check
    disagreement rather than returning a possibly-corrupt basis."""
    if not HAVE_FPYLLL:
        raise RuntimeError("fpylll unavailable")
    R = reduce_fpylll(rows, delta=delta)
    din, dout = det(rows), det(R)
    # A rank-deficient lattice has determinant 0 in both; only a *nonzero*
    # determinant that changed is a real corruption.
    det_ok = (din == 0 and dout == 0) or (abs(din) == abs(dout))
    diag = {
        "backend": "fpylll",
        "delta": delta,
        "dim": len(rows),
        "log2norms": [round(row_log2norm(r), 3) for r in R[:5]],
        "det_ok": det_ok,
        "singular": din == 0,
    }
    if not det_ok:
        raise RuntimeError("fpylll changed the determinant: %s -> %s" % (din, dout))
    if cross_check and len(rows) <= 26:
        try:
            H = reduce_hand(rows, delta=delta)
            hn = row_log2norm(H[0])
            fn = diag["log2norms"][0]
            # fpylll at delta=0.99 should be at least as good as the hand-rolled
            # reducer; allow a small slack for the hand-rolled float GS.
            diag["hand_log2norm"] = round(hn, 3)
            diag["cross_ok"] = (fn <= hn + 0.75)
            if not diag["cross_ok"]:
                raise RuntimeError(
                    "backends disagree: fpylll %.3f vs hand %.3f" % (fn, hn))
        except RuntimeError:
            raise
        except Exception as e:
            diag["cross_check"] = "skipped: %s" % type(e).__name__
    return R, diag
