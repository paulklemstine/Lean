"""Numerical demonstrations for *Chronometric Semirings* and the trace calculus.

This file is fully self-contained (standard library only) and demonstrates the
machine-checked results of the package:

  * A concrete chronometric semiring: n x n Boolean matrices with
        +  = entrywise OR            (idempotent choice, unit = zero matrix)
        *  = Boolean matrix product  (sequencing, unit = identity matrix)
        dagger = transpose           (time reversal: involutive anti-automorphism)
  * The trace-expression syntax (0, 1, atom, +, *, dagger).
  * Normalization into a sum of words of signed atoms.
  * Empirical checks of the verified theorems:
        - reversal is an involutive anti-automorphism: (A B)^T = B^T A^T, (A^T)^T = A
        - normalization soundness:  evalNF(normalize e) == eval(e)
        - canonicalization bound:   |normalize e| <= 2 ** size(e)
        - multiplication-free expressions normalize linearly
        - equal normal forms imply equal evaluation in the model

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, List, Tuple, Union

# --------------------------------------------------------------------------- #
# 1. A concrete chronometric semiring: Boolean matrices under (OR, bool-matmul)
#    with time reversal = transpose.
# --------------------------------------------------------------------------- #

Matrix = Tuple[Tuple[bool, ...], ...]  # immutable n x n Boolean matrix


def mat_zero(n: int) -> Matrix:
    """Additive unit 0: the all-False matrix (the impossible process)."""
    return tuple(tuple(False for _ in range(n)) for _ in range(n))


def mat_one(n: int) -> Matrix:
    """Multiplicative unit 1: the identity matrix (the do-nothing process)."""
    return tuple(tuple(i == j for j in range(n)) for i in range(n))


def mat_add(a: Matrix, b: Matrix) -> Matrix:
    """Choice a + b: entrywise OR. Idempotent: a + a = a."""
    n = len(a)
    return tuple(tuple(a[i][j] or b[i][j] for j in range(n)) for i in range(n))


def mat_mul(a: Matrix, b: Matrix) -> Matrix:
    """Sequencing a * b: Boolean matrix product (relation composition)."""
    n = len(a)
    return tuple(
        tuple(any(a[i][k] and b[k][j] for k in range(n)) for j in range(n))
        for i in range(n)
    )


def mat_rev(a: Matrix) -> Matrix:
    """Time reversal: transpose. Involutive, and (a*b)^T = b^T * a^T."""
    n = len(a)
    return tuple(tuple(a[j][i] for j in range(n)) for i in range(n))


# --------------------------------------------------------------------------- #
# 2. Trace-expression syntax.
# --------------------------------------------------------------------------- #

@dataclass(frozen=True)
class Zero:
    pass


@dataclass(frozen=True)
class One:
    pass


@dataclass(frozen=True)
class Atom:
    name: str


@dataclass(frozen=True)
class Add:
    left: "TraceExpr"
    right: "TraceExpr"


@dataclass(frozen=True)
class Mul:
    left: "TraceExpr"
    right: "TraceExpr"


@dataclass(frozen=True)
class Rev:
    inner: "TraceExpr"


TraceExpr = Union[Zero, One, Atom, Add, Mul, Rev]

# Signed atoms / words / normal forms.
SignedAtom = Tuple[str, str]          # (direction, name), direction in {"fwd","bwd"}
TraceWord = List[SignedAtom]          # product of signed atoms
TraceNormalForm = List[TraceWord]     # sum of words


# --------------------------------------------------------------------------- #
# 3. Semantic evaluation in a chronometric semiring.
# --------------------------------------------------------------------------- #

Valuation = Callable[[str], Matrix]


def eval_signed_atom(sigma: Valuation, s: SignedAtom) -> Matrix:
    direction, name = s
    return sigma(name) if direction == "fwd" else mat_rev(sigma(name))


def eval_word(sigma: Valuation, w: TraceWord, n: int) -> Matrix:
    acc = mat_one(n)
    for s in w:
        acc = mat_mul(acc, eval_signed_atom(sigma, s))
    return acc


def eval_nf(sigma: Valuation, nf: TraceNormalForm, n: int) -> Matrix:
    acc = mat_zero(n)
    for w in nf:
        acc = mat_add(acc, eval_word(sigma, w, n))
    return acc


def eval_expr(sigma: Valuation, e: TraceExpr, n: int) -> Matrix:
    if isinstance(e, Zero):
        return mat_zero(n)
    if isinstance(e, One):
        return mat_one(n)
    if isinstance(e, Atom):
        return sigma(e.name)
    if isinstance(e, Add):
        return mat_add(eval_expr(sigma, e.left, n), eval_expr(sigma, e.right, n))
    if isinstance(e, Mul):
        return mat_mul(eval_expr(sigma, e.left, n), eval_expr(sigma, e.right, n))
    if isinstance(e, Rev):
        return mat_rev(eval_expr(sigma, e.inner, n))
    raise TypeError(f"unknown expression: {e!r}")


# --------------------------------------------------------------------------- #
# 4. Normalization (mirrors the Lean definitions exactly).
# --------------------------------------------------------------------------- #

def flip(s: SignedAtom) -> SignedAtom:
    direction, name = s
    return ("bwd" if direction == "fwd" else "fwd", name)


def rev_word(w: TraceWord) -> TraceWord:
    return [flip(s) for s in reversed(w)]


def rev_nf(nf: TraceNormalForm) -> TraceNormalForm:
    return [rev_word(w) for w in nf]


def mul_nf(nf1: TraceNormalForm, nf2: TraceNormalForm) -> TraceNormalForm:
    return [w1 + w2 for w1 in nf1 for w2 in nf2]


def normalize(e: TraceExpr) -> TraceNormalForm:
    if isinstance(e, Zero):
        return []
    if isinstance(e, One):
        return [[]]
    if isinstance(e, Atom):
        return [[("fwd", e.name)]]
    if isinstance(e, Add):
        return normalize(e.left) + normalize(e.right)
    if isinstance(e, Mul):
        return mul_nf(normalize(e.left), normalize(e.right))
    if isinstance(e, Rev):
        return rev_nf(normalize(e.inner))
    raise TypeError(f"unknown expression: {e!r}")


def size(e: TraceExpr) -> int:
    if isinstance(e, (Zero, One, Atom)):
        return 1
    if isinstance(e, (Add, Mul)):
        return size(e.left) + size(e.right)
    if isinstance(e, Rev):
        return size(e.inner)
    raise TypeError(f"unknown expression: {e!r}")


def is_mul_free(e: TraceExpr) -> bool:
    if isinstance(e, (Zero, One, Atom)):
        return True
    if isinstance(e, Add):
        return is_mul_free(e.left) and is_mul_free(e.right)
    if isinstance(e, Mul):
        return False
    if isinstance(e, Rev):
        return is_mul_free(e.inner)
    raise TypeError(f"unknown expression: {e!r}")


def equiv_nf(e: TraceExpr, f: TraceExpr) -> bool:
    """Sound equality test: compare normal forms as data."""
    return normalize(e) == normalize(f)


# --------------------------------------------------------------------------- #
# 5. Demonstrations.
# --------------------------------------------------------------------------- #

def all_matrices(n: int) -> List[Matrix]:
    cells = list(product([False, True], repeat=n * n))
    return [tuple(tuple(c[i * n + j] for j in range(n)) for i in range(n)) for c in cells]


def demo_anti_automorphism(n: int = 2) -> None:
    print("=" * 70)
    print("Time reversal is an involutive anti-automorphism (transpose model)")
    print("=" * 70)
    mats = all_matrices(n)
    inv_ok = all(mat_rev(mat_rev(a)) == a for a in mats)
    flip_ok = all(mat_rev(mat_mul(a, b)) == mat_mul(mat_rev(b), mat_rev(a))
                  for a in mats for b in mats)
    print(f"  (A^T)^T == A           for all {len(mats)} matrices: {inv_ok}")
    print(f"  (A B)^T == B^T A^T     for all {len(mats)**2} pairs:    {flip_ok}")
    print(f"  add idempotent A+A==A:                              "
          f"{all(mat_add(a, a) == a for a in mats)}")


def make_valuation(n: int) -> Valuation:
    rng_a = ((False, True), (True, False))   # a 2x2 example
    rng_b = ((True, True), (False, True))
    rng_c = ((False, False), (True, True))
    table = {"a": rng_a, "b": rng_b, "c": rng_c}
    return lambda name: table.get(name, mat_one(n))


def demo_soundness(n: int = 2) -> None:
    print("=" * 70)
    print("Normalization soundness:  evalNF(normalize e) == eval(e)")
    print("=" * 70)
    sigma = make_valuation(n)
    a, b, c = Atom("a"), Atom("b"), Atom("c")
    exprs: List[Tuple[str, TraceExpr]] = [
        ("a*b", Mul(a, b)),
        ("(a*b)^T", Rev(Mul(a, b))),
        ("a + b*c", Add(a, Mul(b, c))),
        ("(a + b)^T", Rev(Add(a, b))),
        ("(a*b*c)^T", Rev(Mul(Mul(a, b), c))),
        ("(a+1)*(b+c)", Mul(Add(a, One()), Add(b, c))),
    ]
    for label, e in exprs:
        lhs = eval_nf(sigma, normalize(e), n)
        rhs = eval_expr(sigma, e, n)
        print(f"  {label:14s}  sound: {lhs == rhs}   "
              f"|normalize| = {len(normalize(e))}")


def demo_bounds(n: int = 2) -> None:
    print("=" * 70)
    print("Canonicalization bound  |normalize e| <= 2^size(e)")
    print("(and linear size for multiplication-free expressions)")
    print("=" * 70)
    a, b, c = Atom("a"), Atom("b"), Atom("c")
    exprs: List[Tuple[str, TraceExpr]] = [
        ("a", a),
        ("a+b+c", Add(a, Add(b, c))),
        ("(a+b)^T", Rev(Add(a, b))),
        ("(a+b)*(b+c)", Mul(Add(a, b), Add(b, c))),
        ("((a+b)*(a+b))*(a+b)", Mul(Mul(Add(a, b), Add(a, b)), Add(a, b))),
    ]
    for label, e in exprs:
        ln = len(normalize(e))
        sz = size(e)
        bound = 2 ** sz
        tag = "mul-free" if is_mul_free(e) else "has mul"
        lin = f"  linear ok: {ln <= sz}" if is_mul_free(e) else ""
        print(f"  {label:22s} size={sz}  |nf|={ln:3d}  2^size={bound:4d}  "
              f"bound ok: {ln <= bound}  [{tag}]{lin}")


def demo_decision(n: int = 2) -> None:
    print("=" * 70)
    print("Sound equality test: equal normal forms => equal evaluation")
    print("=" * 70)
    sigma = make_valuation(n)
    a, b, c = Atom("a"), Atom("b"), Atom("c")
    # ((a)^T)^T normalizes back to fwd a == a  (double reversal collapses)
    pairs: List[Tuple[str, TraceExpr, TraceExpr]] = [
        ("(a^T)^T  vs  a", Rev(Rev(a)), a),
        ("a*(b+c)  vs  a*b + a*c", Mul(a, Add(b, c)), Add(Mul(a, b), Mul(a, c))),
        ("(a*b)^T  vs  b^T*a^T", Rev(Mul(a, b)), Mul(Rev(b), Rev(a))),
    ]
    for label, e, f in pairs:
        eq = equiv_nf(e, f)
        same_eval = eval_expr(sigma, e, n) == eval_expr(sigma, f, n)
        print(f"  {label:28s}  equivNF: {eq}   model-equal: {same_eval}")


def main() -> None:
    demo_anti_automorphism()
    print()
    demo_soundness()
    print()
    demo_bounds()
    print()
    demo_decision()


if __name__ == "__main__":
    main()
