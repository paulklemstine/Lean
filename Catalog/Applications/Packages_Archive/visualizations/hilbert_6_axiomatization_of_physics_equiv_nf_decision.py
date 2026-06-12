from typing import Callable, Any
# Relies on `normalize` (see the normalize algorithm) and an evaluator `eval_expr`.

def equiv_nf(e: Any, f: Any) -> bool:
    """Sound semantic-equality test for reversible-process expressions.

    Returns True iff the two expressions share an identical normal form.
    By the verified soundness theorem, equal normal forms imply equal
    evaluation in EVERY chronometric semiring; hence True is a certificate
    of indistinguishability across all models of the axioms.
    """
    return normalize(e) == normalize(f)

def eval_of_equiv(e: Any, f: Any,
                  eval_expr: Callable[[Any], Any]) -> bool:
    """If equiv_nf says equal, the concrete model agrees (sanity check)."""
    if equiv_nf(e, f):
        return eval_expr(e) == eval_expr(f)
    return True  # no claim when normal forms differ
