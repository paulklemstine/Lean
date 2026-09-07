"""
Standard-Part Projection-Valued Measures — numerical / symbolic demonstrations.

This script is fully self-contained (standard library only) and exercises every
main result of the theory of standard-part projection-valued measures:

  1. Exact symbolic arithmetic in a non-Archimedean field: finite Laurent series
     in a formal infinite element omega with rational coefficients.  Positive
     powers of omega are infinite, negative powers are infinitesimal, and the
     standard part of a finite element is its constant coefficient.
  2. The Descent Theorem: for hyperreal matrices with no infinite entry, the
     entrywise standard parts form a projection-valued measure (PVM) if and only
     if distinct channels are orthogonal up to infinitesimals and the total is
     infinitesimally close to the identity.
  3. Redundancy of idempotency: approximate orthogonality plus approximate
     completeness already force each channel to be approximately idempotent.
  4. Sharpness of the finiteness hypothesis, in BOTH directions, with the
     explicit 2x2 and 1x1 witnesses built from omega.
  5. Dimension quantization: observed traces are natural numbers equal to the
     ranks of the observed projections, and they sum to the dimension.
  6. Rigidity: every approximate PVM is entrywise infinitesimally close to an
     exact hyperreal PVM, namely the lift of its own observation.
  7. Spectral collapse: infinitesimally separated eigenvalues merge into a
     single observed spectral line.
  8. Observed Born measure and entropy monotonicity under coarse-graining,
     including the strict case and the sharp equality boundary.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from fractions import Fraction
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Number = Fraction | int


# ---------------------------------------------------------------------------
# 1.  A computable non-Archimedean field: finite Laurent series in omega
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Hyper:
    """A hyperreal number represented as a finite Laurent series in omega.

    ``coeffs`` maps an integer exponent k to the rational coefficient of
    omega**k.  Positive k contributes an infinite part, k = 0 the appreciable
    part, negative k an infinitesimal part.  Zero coefficients are dropped, so
    the representation is canonical and equality is structural.
    """

    coeffs: Tuple[Tuple[int, Fraction], ...]

    # -- construction -------------------------------------------------------

    @staticmethod
    def of(d: Dict[int, Number]) -> "Hyper":
        cleaned = {k: Fraction(v) for k, v in d.items() if Fraction(v) != 0}
        return Hyper(tuple(sorted(cleaned.items())))

    @staticmethod
    def real(c: Number) -> "Hyper":
        """The image of a real (here: rational) number in the hyperreals."""
        return Hyper.of({0: c})

    @staticmethod
    def omega(power: int = 1) -> "Hyper":
        """omega**power: infinite for power > 0, infinitesimal for power < 0."""
        return Hyper.of({power: 1})

    # -- ring structure -----------------------------------------------------

    def as_dict(self) -> Dict[int, Fraction]:
        return dict(self.coeffs)

    def __add__(self, other: "Hyper") -> "Hyper":
        out = self.as_dict()
        for k, v in other.coeffs:
            out[k] = out.get(k, Fraction(0)) + v
        return Hyper.of(out)

    def __neg__(self) -> "Hyper":
        return Hyper.of({k: -v for k, v in self.coeffs})

    def __sub__(self, other: "Hyper") -> "Hyper":
        return self + (-other)

    def __mul__(self, other: "Hyper") -> "Hyper":
        out: Dict[int, Fraction] = {}
        for k1, v1 in self.coeffs:
            for k2, v2 in other.coeffs:
                out[k1 + k2] = out.get(k1 + k2, Fraction(0)) + v1 * v2
        return Hyper.of(out)

    # -- non-Archimedean predicates ----------------------------------------

    def is_infinite(self) -> bool:
        """True iff some strictly positive power of omega occurs."""
        return any(k > 0 for k, _ in self.coeffs)

    def is_finite(self) -> bool:
        return not self.is_infinite()

    def is_infinitesimal(self) -> bool:
        """True iff every occurring power of omega is strictly negative."""
        return all(k < 0 for k, _ in self.coeffs)

    def st(self) -> Fraction:
        """Standard part: the constant coefficient (0 on infinite elements)."""
        if self.is_infinite():
            return Fraction(0)
        return dict(self.coeffs).get(0, Fraction(0))

    # -- display ------------------------------------------------------------

    def __repr__(self) -> str:
        if not self.coeffs:
            return "0"
        pieces: List[str] = []
        for k, v in sorted(self.coeffs, reverse=True):
            mag = "" if abs(v) == 1 and k != 0 else str(abs(v))
            sign = "-" if v < 0 else ""
            if k == 0:
                pieces.append(f"{v}")
            elif k == 1:
                pieces.append(f"{sign}{mag}w")
            elif k == -1:
                pieces.append(f"{sign}{mag or '1'}/w")
            elif k > 0:
                pieces.append(f"{sign}{mag}w^{k}")
            else:
                pieces.append(f"{sign}{mag or '1'}/w^{-k}")
        return " + ".join(pieces).replace("+ -", "- ")


ZERO = Hyper.real(0)
ONE = Hyper.real(1)
W = Hyper.omega(1)        # an infinite element
EPS = Hyper.omega(-1)     # its reciprocal: an infinitesimal

HMatrix = List[List[Hyper]]
RMatrix = List[List[Fraction]]


# ---------------------------------------------------------------------------
# 2.  Matrix algebra over the hyperreals and over the rationals
# ---------------------------------------------------------------------------


def hyper_matrix(rows: Sequence[Sequence[Hyper]]) -> HMatrix:
    return [list(r) for r in rows]


def h_identity(n: int) -> HMatrix:
    return [[ONE if i == j else ZERO for j in range(n)] for i in range(n)]


def h_zero(n: int) -> HMatrix:
    return [[ZERO for _ in range(n)] for _ in range(n)]


def h_add(a: HMatrix, b: HMatrix) -> HMatrix:
    return [[x + y for x, y in zip(ra, rb)] for ra, rb in zip(a, b)]


def h_sub(a: HMatrix, b: HMatrix) -> HMatrix:
    return [[x - y for x, y in zip(ra, rb)] for ra, rb in zip(a, b)]


def h_mul(a: HMatrix, b: HMatrix) -> HMatrix:
    n, m, p = len(a), len(b), len(b[0])
    out = [[ZERO for _ in range(p)] for _ in range(n)]
    for i in range(n):
        for j in range(p):
            acc = ZERO
            for k in range(m):
                acc = acc + a[i][k] * b[k][j]
            out[i][j] = acc
    return out


def h_smul(c: Hyper, a: HMatrix) -> HMatrix:
    return [[c * x for x in row] for row in a]


def h_sum(mats: Iterable[HMatrix], n: int) -> HMatrix:
    total = h_zero(n)
    for m in mats:
        total = h_add(total, m)
    return total


def h_trace(a: HMatrix) -> Hyper:
    acc = ZERO
    for i in range(len(a)):
        acc = acc + a[i][i]
    return acc


def has_finite_entries(a: HMatrix) -> bool:
    return all(x.is_finite() for row in a for x in row)


def is_infinitesimal_matrix(a: HMatrix) -> bool:
    return all(x.is_infinitesimal() for row in a for x in row)


def approx_eq(a: HMatrix, b: HMatrix) -> bool:
    """A ~ B: the entrywise difference is infinitesimal."""
    return is_infinitesimal_matrix(h_sub(a, b))


def st_matrix(a: HMatrix) -> RMatrix:
    """The observation map: entrywise standard part."""
    return [[x.st() for x in row] for row in a]


def lift(a: RMatrix) -> HMatrix:
    """The canonical lift of a real matrix into the hyperreals."""
    return [[Hyper.real(x) for x in row] for row in a]


def r_identity(n: int) -> RMatrix:
    return [[Fraction(1) if i == j else Fraction(0) for j in range(n)] for i in range(n)]


def r_mul(a: RMatrix, b: RMatrix) -> RMatrix:
    n, m, p = len(a), len(b), len(b[0])
    return [[sum((a[i][k] * b[k][j] for k in range(m)), Fraction(0)) for j in range(p)]
            for i in range(n)]


def r_add(a: RMatrix, b: RMatrix) -> RMatrix:
    return [[x + y for x, y in zip(ra, rb)] for ra, rb in zip(a, b)]


def r_zero(n: int) -> RMatrix:
    return [[Fraction(0) for _ in range(n)] for _ in range(n)]


def r_trace(a: RMatrix) -> Fraction:
    return sum((a[i][i] for i in range(len(a))), Fraction(0))


def r_rank(a: RMatrix) -> int:
    """Exact rank by Gaussian elimination over the rationals."""
    m = [row[:] for row in a]
    rows, cols = len(m), len(m[0])
    rank, pivot_row = 0, 0
    for c in range(cols):
        piv = None
        for r in range(pivot_row, rows):
            if m[r][c] != 0:
                piv = r
                break
        if piv is None:
            continue
        m[pivot_row], m[piv] = m[piv], m[pivot_row]
        inv = Fraction(1) / m[pivot_row][c]
        m[pivot_row] = [x * inv for x in m[pivot_row]]
        for r in range(rows):
            if r != pivot_row and m[r][c] != 0:
                f = m[r][c]
                m[r] = [x - f * y for x, y in zip(m[r], m[pivot_row])]
        pivot_row += 1
        rank += 1
    return rank


def r_transpose(a: RMatrix) -> RMatrix:
    return [list(col) for col in zip(*a)]


# ---------------------------------------------------------------------------
# 3.  The Descent Theorem, as an executable test
# ---------------------------------------------------------------------------


def is_real_pvm(q: Sequence[RMatrix]) -> Tuple[bool, Dict[str, bool]]:
    """Check the three defining identities of a real projection-valued measure."""
    n = len(q[0])
    idem = all(r_mul(qa, qa) == qa for qa in q)
    orth = all(r_mul(q[a], q[b]) == r_zero(n)
               for a in range(len(q)) for b in range(len(q)) if a != b)
    total = r_zero(n)
    for qa in q:
        total = r_add(total, qa)
    complete = total == r_identity(n)
    return (idem and orth and complete,
            {"idempotent": idem, "orthogonal": orth, "complete": complete})


def descent_test(p: Sequence[HMatrix]) -> Dict[str, object]:
    """The certified descent test of the theory.

    Returns the three hypotheses (F), (O), (C), whether the observation is a
    PVM, the observed ranks, and the quantization certificate sum(rank) = n.
    """
    n = len(p[0])
    finite = all(has_finite_entries(pa) for pa in p)
    orth = all(is_infinitesimal_matrix(h_mul(p[a], p[b]))
               for a in range(len(p)) for b in range(len(p)) if a != b)
    complete = approx_eq(h_sum(p, n), h_identity(n))
    observed = [st_matrix(pa) for pa in p]
    is_pvm, parts = is_real_pvm(observed)
    ranks = [r_rank(q) for q in observed]
    return {
        "finite_entries_F": finite,
        "approx_orthogonal_O": orth,
        "approx_complete_C": complete,
        "observation_is_pvm": is_pvm,
        "observation_parts": parts,
        "observed": observed,
        "ranks": ranks,
        "rank_sum": sum(ranks),
        "dimension": n,
        # The Descent Theorem: under (F), (O) and (C) hold iff the observation is a PVM.
        "descent_theorem_confirmed": (not finite) or (is_pvm == (orth and complete)),
    }


def fmt_real_matrix(a: RMatrix) -> str:
    return "[" + "; ".join(" ".join(str(x) for x in row) for row in a) + "]"


def fmt_hyper_matrix(a: HMatrix) -> str:
    return "[" + "; ".join(" , ".join(repr(x) for x in row) for row in a) + "]"


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# ---------------------------------------------------------------------------
# Demonstration 1: the epsilon-channel — approximate but not exact
# ---------------------------------------------------------------------------


def demo_eps_channel() -> None:
    banner("1.  The epsilon-channel: an approximate PVM that is NOT an exact one")

    p0 = hyper_matrix([[ONE, EPS], [ZERO, ZERO]])
    p1 = hyper_matrix([[ZERO, ZERO], [ZERO, ONE]])
    p = [p0, p1]

    print("P_1 =", fmt_hyper_matrix(p0))
    print("P_2 =", fmt_hyper_matrix(p1))
    print()
    print("P_1 P_2      =", fmt_hyper_matrix(h_mul(p0, p1)),
          "  (infinitesimal, but NOT zero)")
    print("P_2 P_1      =", fmt_hyper_matrix(h_mul(p1, p0)))
    print("P_1 + P_2    =", fmt_hyper_matrix(h_add(p0, p1)),
          "  (~ I, but NOT equal to I)")

    res = descent_test(p)
    print()
    print("hypothesis (F) finite entries          :", res["finite_entries_F"])
    print("hypothesis (O) approx. orthogonality   :", res["approx_orthogonal_O"])
    print("hypothesis (C) approx. completeness    :", res["approx_complete_C"])
    print("observation is a projection-valued measure:", res["observation_is_pvm"])
    print("   -> observed channels:",
          " and ".join(fmt_real_matrix(q) for q in res["observed"]))

    # Redundancy of idempotency (Theorem: (F)+(O)+(C) => P_a P_a ~ P_a).
    print()
    for a, pa in enumerate(p, start=1):
        print(f"P_{a}^2 ~ P_{a} (idempotency was never assumed):",
              approx_eq(h_mul(pa, pa), pa))

    # Dimension quantization.
    print()
    for a, pa in enumerate(p, start=1):
        print(f"st(tr P_{a}) = {h_trace(pa).st()}  =  rank st(P_{a}) = {res['ranks'][a - 1]}")
    print(f"sum of observed ranks = {res['rank_sum']} = dim = {res['dimension']}")

    # Rigidity: the exact model is the lift of the observation.
    r = [lift(q) for q in res["observed"]]
    n = len(p0)
    exact_idem = all(h_mul(ra, ra) == ra for ra in r)
    exact_orth = h_mul(r[0], r[1]) == h_zero(n) and h_mul(r[1], r[0]) == h_zero(n)
    exact_total = h_sum(r, n) == h_identity(n)
    print()
    print("RIGIDITY.  Exact model R_a = lift(st(P_a)):")
    print("   R exactly idempotent :", exact_idem)
    print("   R exactly orthogonal :", exact_orth)
    print("   R exactly complete   :", exact_total)
    print("   P_a ~ R_a for all a  :", all(approx_eq(pa, ra) for pa, ra in zip(p, r)))
    print("   entrywise difference P_1 - R_1 =",
          fmt_hyper_matrix(h_sub(p[0], r[0])), " (infinitesimal)")


# ---------------------------------------------------------------------------
# Demonstration 2: sharpness — infinite entries break descent in BOTH directions
# ---------------------------------------------------------------------------


def demo_sharpness_if_direction() -> None:
    banner("2.  Sharpness I: an EXACT hyperreal PVM whose observation is NOT a PVM")

    # P = [[2, w], [-2/w, -1]] is an exact idempotent because w * (-2/w) = -2.
    p0 = hyper_matrix([[Hyper.real(2), W],
                       [Hyper.real(-2) * EPS, Hyper.real(-1)]])
    p1 = h_sub(h_identity(2), p0)
    p = [p0, p1]

    print("P_1 =", fmt_hyper_matrix(p0), "   (contains the infinite entry w)")
    print("P_2 = I - P_1 =", fmt_hyper_matrix(p1))
    print()
    print("P_1^2 = P_1 exactly       :", h_mul(p0, p0) == p0)
    print("P_1 P_2 = 0 exactly       :", h_mul(p0, p1) == h_zero(2))
    print("P_2 P_1 = 0 exactly       :", h_mul(p1, p0) == h_zero(2))
    print("P_1 + P_2 = I exactly     :", h_add(p0, p1) == h_identity(2))
    print("  -> this is an EXACT hyperreal projection-valued measure.")

    res = descent_test(p)
    print()
    print("hypothesis (F) finite entries :", res["finite_entries_F"], " <-- FAILS")
    print("st(P_1) =", fmt_real_matrix(res["observed"][0]))
    q = res["observed"][0]
    print("st(P_1)^2 =", fmt_real_matrix(r_mul(q, q)), " != st(P_1)")
    print("observation is a PVM :", res["observation_is_pvm"], " <-- descent FAILS")
    print()
    print("Mechanism: w * (-2/w) = -2 is an appreciable quantity manufactured from")
    print("an infinite entry and an infinitesimal one.  Entrywise observation sends")
    print("both factors to 0 and loses the contribution.")


def demo_sharpness_only_if_direction() -> None:
    banner("3.  Sharpness II: a PVM observation whose channels are NOT approx. orthogonal")

    p0 = hyper_matrix([[ONE]])
    p1 = hyper_matrix([[W]])
    p = [p0, p1]

    print("P_1 = [1],  P_2 = [w]   (1x1 matrices)")
    print("st(P_1) = [1],  st(P_2) = [0]   -> an honest PVM on R^1")
    res = descent_test(p)
    print("observation is a PVM               :", res["observation_is_pvm"])
    print("P_1 P_2 = [w] is infinitesimal     :", is_infinitesimal_matrix(h_mul(p0, p1)),
          " <-- (O) FAILS badly: w is infinite")
    print("hypothesis (F) finite entries      :", res["finite_entries_F"], " <-- FAILS")
    print()
    print("So without finiteness the 'only if' direction of the Descent Theorem is false.")


# ---------------------------------------------------------------------------
# Demonstration 3: a three-channel example with quantization
# ---------------------------------------------------------------------------


def demo_three_channel_quantization() -> None:
    banner("4.  A 4-dimensional, 3-channel approximate PVM: dimension quantization")

    n, half = 4, Fraction(1, 2)
    e2 = EPS * EPS  # 1/w^2, an infinitesimal of higher order

    # Channel 1: rank-2 projection onto span(e1, e2), perturbed infinitesimally.
    p1 = h_zero(n)
    p1[0][0] = ONE
    p1[1][1] = ONE + EPS      # an infinitesimally detuned diagonal entry
    p1[0][2] = EPS
    p1[3][1] = e2

    # Channel 2: rank-1 projection onto span(e3), perturbed.
    p2 = h_zero(n)
    p2[2][2] = ONE
    p2[2][0] = Hyper.real(3) * EPS

    # Channel 3: whatever is needed to make the total exactly I minus a tiny slack.
    p3 = h_sub(h_identity(n), h_add(p1, p2))
    p3[3][3] = p3[3][3] + e2   # extra infinitesimal detuning of the total

    p = [p1, p2, p3]
    res = descent_test(p)

    print("hypothesis (F) finite entries        :", res["finite_entries_F"])
    print("hypothesis (O) approx. orthogonality :", res["approx_orthogonal_O"])
    print("hypothesis (C) approx. completeness  :", res["approx_complete_C"])
    print("observation is a PVM                 :", res["observation_is_pvm"])
    print("Descent Theorem confirmed on this input:", res["descent_theorem_confirmed"])
    print()
    for a in range(3):
        tr_h = h_trace(p[a])
        print(f"channel {a + 1}: hyperreal trace = {tr_h!r:>14}   "
              f"st(trace) = {tr_h.st()}   rank st(P) = {res['ranks'][a]}")
    print(f"\nQUANTIZATION: {' + '.join(str(r) for r in res['ranks'])} "
          f"= {res['rank_sum']} = dim R^{res['dimension']}")
    print("The hyperreal traces live in a continuum; the observed ones are integers.")


# ---------------------------------------------------------------------------
# Demonstration 4: spectral collapse
# ---------------------------------------------------------------------------


def demo_spectral_collapse() -> None:
    banner("5.  Spectral collapse: infinitesimally separated eigenvalues merge")

    # Three rank-1 channels in R^3 with eigenvalues 5, 5 + eps, and -2.
    n = 3
    chans: List[HMatrix] = []
    for i in range(n):
        m = h_zero(n)
        m[i][i] = ONE
        chans.append(m)
    lams = [Hyper.real(5), Hyper.real(5) + EPS, Hyper.real(-2)]

    a = h_zero(n)
    for lam, ch in zip(lams, chans):
        a = h_add(a, h_smul(lam, ch))

    print("eigenvalues:", ", ".join(repr(l) for l in lams))
    print("A = sum_a lambda_a P_a =", fmt_hyper_matrix(a))
    print("st(A) =", fmt_real_matrix(st_matrix(a)))
    print()
    print("observed eigenvalues:", [str(l.st()) for l in lams])
    print("channels 1 and 2 have the SAME observed eigenvalue 5, so they fuse.")

    # Coarse-grain along f: {1,2,3} -> {A, B} merging the two 5-eigenvalue channels.
    f: Callable[[int], str] = lambda i: "A" if i in (0, 1) else "B"
    coarse: Dict[str, RMatrix] = {}
    for i in range(n):
        k = f(i)
        coarse[k] = r_add(coarse.get(k, r_zero(n)), st_matrix(chans[i]))
    mu = {"A": Fraction(5), "B": Fraction(-2)}

    rebuilt = r_zero(n)
    for k, q in coarse.items():
        rebuilt = r_add(rebuilt, [[mu[k] * x for x in row] for row in q])

    print()
    for k in sorted(coarse):
        print(f"coarse channel {k}: eigenvalue {mu[k]}, projection "
              f"{fmt_real_matrix(coarse[k])}, rank {r_rank(coarse[k])}")
    print("sum_k mu_k Q_k =", fmt_real_matrix(rebuilt))
    print("equals st(A):", rebuilt == st_matrix(a))
    print()
    print("The fine 3-channel hyperreal decomposition is observed as a 2-line real one.")


# ---------------------------------------------------------------------------
# Demonstration 5: Born measure and entropy under coarse-graining
# ---------------------------------------------------------------------------


def born_weight(q: RMatrix, v: Sequence[Fraction]) -> Fraction:
    """p_a = v^T Q_a v."""
    n = len(v)
    qv = [sum((q[i][j] * v[j] for j in range(n)), Fraction(0)) for i in range(n)]
    return sum((v[i] * qv[i] for i in range(n)), Fraction(0))


def eta(t: Fraction) -> float:
    """-t log t, with eta(0) = 0."""
    x = float(t)
    return 0.0 if x <= 0.0 else -x * math.log(x)


def observed_entropy(q: Sequence[RMatrix], v: Sequence[Fraction]) -> float:
    return sum(eta(born_weight(qa, v)) for qa in q)


def coarse_grain(q: Sequence[RMatrix], f: Sequence[int]) -> List[RMatrix]:
    """Merge channels: (f_* Q)_k = sum over {a : f(a) = k} of Q_a."""
    n = len(q[0])
    out: Dict[int, RMatrix] = {}
    for a, qa in enumerate(q):
        out[f[a]] = r_add(out.get(f[a], r_zero(n)), qa)
    return [out[k] for k in sorted(out)]


def demo_entropy() -> None:
    banner("6.  Observed Born measure and entropy monotonicity under coarse-graining")

    # A 4-dimensional PVM with four rank-1 orthogonal channels (diagonal, hence
    # symmetric, so the Born weights are genuine probabilities).
    n = 4
    q: List[RMatrix] = []
    for i in range(n):
        m = r_zero(n)
        m[i][i] = Fraction(1)
        q.append(m)

    ok, parts = is_real_pvm(q)
    print("the fine family is a PVM:", ok, parts)
    print("all channels symmetric  :", all(r_transpose(qa) == qa for qa in q))

    # The exactly normalized state v = (1/2, 1/2, 1/2, 1/2), giving the uniform
    # Born distribution (1/4, 1/4, 1/4, 1/4).
    v = [Fraction(1, 2)] * 4
    print("\nstate v =", [str(x) for x in v],
          " with |v|^2 =", sum((x * x for x in v), Fraction(0)))
    p = [born_weight(qa, v) for qa in q]
    print("Born weights:", [str(x) for x in p], " sum =", sum(p, Fraction(0)))

    h_fine = observed_entropy(q, v)
    print(f"\nfine entropy   H = {h_fine:.6f}   (= log 4 = {math.log(4):.6f})")

    # (a) merge two channels of positive weight  -> strict decrease
    f_merge = [0, 0, 1, 2]
    qc = coarse_grain(q, f_merge)
    h_c = observed_entropy(qc, v)
    print(f"\n(a) merging channels 1,2 (both weight 1/4 > 0):")
    print(f"    coarse entropy H' = {h_c:.6f}   strict decrease: {h_c < h_fine}")
    print(f"    predicted:  H' = {-0.5 * math.log(0.5) - 2 * 0.25 * math.log(0.25):.6f}")

    # (b) merge a positive-weight channel with a zero-weight channel -> equality
    v2 = [Fraction(1), Fraction(0), Fraction(0), Fraction(0)]
    p2 = [born_weight(qa, v2) for qa in q]
    print(f"\n(b) state v = {[str(x) for x in v2]}, Born weights {[str(x) for x in p2]}")
    h_fine2 = observed_entropy(q, v2)
    h_c2 = observed_entropy(coarse_grain(q, f_merge), v2)
    print(f"    fine H = {h_fine2:.6f},  coarse H' = {h_c2:.6f},  equality: {h_c2 == h_fine2}")
    print("    (equality boundary: no two channels of NONZERO weight were merged)")

    # (c) total merge into one channel -> entropy 0
    f_total = [0, 0, 0, 0]
    h_c3 = observed_entropy(coarse_grain(q, f_total), v)
    print(f"\n(c) merging everything into one channel: H' = {h_c3:.6f} "
          f"(<= {h_fine:.6f}: {h_c3 <= h_fine})")

    # Sharp criterion check across all merging schemes of a 4-element set.
    print("\nSharp equality criterion, checked over all 4^4 merging schemes:")
    bad = 0
    for code in range(4 ** 4):
        f = [(code >> (2 * i)) & 3 for i in range(4)]
        hc = observed_entropy(coarse_grain(q, f), v)
        pw = [born_weight(qa, v) for qa in q]
        no_merge_of_positives = all(
            not (f[a] == f[b] and a != b and pw[a] != 0 and pw[b] != 0)
            for a in range(4) for b in range(4))
        equal = abs(hc - h_fine) < 1e-12
        if equal != no_merge_of_positives:
            bad += 1
    print(f"   schemes violating the criterion: {bad}   (0 means the criterion is exact)")


# ---------------------------------------------------------------------------
# Demonstration 6: the functional calculus survives observation
# ---------------------------------------------------------------------------


def demo_functional_calculus() -> None:
    banner("7.  Polynomial functional calculus: st(p(A)) = p(st(A))")

    a = hyper_matrix([[Hyper.real(2) + EPS, Hyper.real(1)],
                      [Hyper.real(-1) * EPS, Hyper.real(3)]])
    print("A =", fmt_hyper_matrix(a), "   (finite entries)")

    # p(X) = X^3 - 2X + 5
    def p_hyper(m: HMatrix) -> HMatrix:
        m2 = h_mul(m, m)
        m3 = h_mul(m2, m)
        out = h_sub(m3, h_smul(Hyper.real(2), m))
        return h_add(out, h_smul(Hyper.real(5), h_identity(len(m))))

    def p_real(m: RMatrix) -> RMatrix:
        m2 = r_mul(m, m)
        m3 = r_mul(m2, m)
        out = [[m3[i][j] - 2 * m[i][j] for j in range(len(m))] for i in range(len(m))]
        return r_add(out, [[5 * x for x in row] for row in r_identity(len(m))])

    lhs = st_matrix(p_hyper(a))
    rhs = p_real(st_matrix(a))
    print("p(X) = X^3 - 2X + 5")
    print("st(p(A)) =", fmt_real_matrix(lhs))
    print("p(st A)  =", fmt_real_matrix(rhs))
    print("equal    :", lhs == rhs)

    # Approximate annihilators become exact: B^2 - B is infinitesimal.
    b = hyper_matrix([[ONE, EPS], [ZERO, EPS * EPS]])
    b2mb = h_sub(h_mul(b, b), b)
    print("\nB =", fmt_hyper_matrix(b))
    print("B^2 - B =", fmt_hyper_matrix(b2mb), " infinitesimal:",
          is_infinitesimal_matrix(b2mb))
    sb = st_matrix(b)
    print("st(B) =", fmt_real_matrix(sb), " and st(B)^2 - st(B) = 0 exactly:",
          r_mul(sb, sb) == sb)


# ---------------------------------------------------------------------------


def main() -> None:
    print(__doc__)
    demo_eps_channel()
    demo_sharpness_if_direction()
    demo_sharpness_only_if_direction()
    demo_three_channel_quantization()
    demo_spectral_collapse()
    demo_entropy()
    demo_functional_calculus()
    banner("All demonstrations completed.")


if __name__ == "__main__":
    main()
