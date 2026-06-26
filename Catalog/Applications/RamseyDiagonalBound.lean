/-
# The diagonal Ramsey upper bound `R(k+1, k+1) ≤ 4^k`

Building on `Applications.Ramsey` (the arrow relation and the Erdős–Szekeres
binomial bound `arrows_recursion : C(s+t,s) → (s+1,t+1)`) and the colour-swap
symmetry `arrows_symm` from `Applications.RamseyFourFour`, this file derives the
classical *exponential* diagonal bound and the symmetry of Ramsey numbers.

* `central_choose_le_four_pow` : `C(2k, k) ≤ 4^k` — the central binomial estimate
  driving every textbook proof of `R(k,k) ≤ 4^k`.
* `arrows_diagonal_pow`        : `Arrows (4^k) (k+1) (k+1)`, i.e. `R(k+1,k+1) ≤ 4^k`.
* `arrows_iff_symm`            : `Arrows n s t ↔ Arrows n t s` (Ramsey numbers are
  symmetric in their two colours).

## Lab Notes — see `-- !-- Lab Notes -- !--` blocks below.
-/

import Mathlib
import Applications.RamseyFourFour

open scoped Classical
open SimpleGraph Finset

namespace RamseyTheory

/- -- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): the Erdős–Szekeres recursion is not merely a tool for
the small exact values; specialised to the diagonal it already yields the
exponential bound `R(k+1,k+1) ≤ C(2k,k) ≤ 4^k`, the classical first non-trivial
upper bound on diagonal Ramsey numbers.

EXPERIMENT (Experimenter): the only analytic input is the central binomial
estimate `C(2k,k) ≤ 4^k`, obtained by bounding a single term of the row-sum
`∑_i C(2k,i) = 2^{2k} = 4^k`.  Combined with `arrows_recursion` (giving
`C(k+k,k) → (k+1,k+1)`) and monotonicity `Arrows.mono`, the bound follows.
-/

/-! ## The central binomial estimate -/

/--
**Central binomial estimate `C(2k, k) ≤ 4^k`.** The central coefficient is a
single term of the full binomial row-sum `∑_{i=0}^{2k} C(2k,i) = 2^{2k} = 4^k`,
hence bounded by it.
-/
theorem central_choose_le_four_pow (k : ℕ) : (2 * k).choose k ≤ 4 ^ k := by
  have h : (2 * k).choose k ≤ ∑ i ∈ Finset.range (2 * k + 1), (2 * k).choose i := by
    apply Finset.single_le_sum (f := fun i => (2 * k).choose i) (by intros; positivity)
    simp; omega
  calc (2 * k).choose k
      ≤ ∑ i ∈ Finset.range (2 * k + 1), (2 * k).choose i := h
    _ = 2 ^ (2 * k) := by rw [Nat.sum_range_choose]
    _ = 4 ^ k := by rw [pow_mul]; norm_num

/-! ## The exponential diagonal bound -/

/--
**Exponential diagonal bound `R(k+1, k+1) ≤ 4^k`.** Every red/blue colouring of a
complete graph on `4^k` vertices contains a monochromatic `K_{k+1}`.

Proof: `arrows_recursion k k` gives `Arrows (C(k+k, k)) (k+1) (k+1)`; since
`C(k+k, k) = C(2k, k) ≤ 4^k`, monotonicity `Arrows.mono` raises the vertex
threshold to `4^k`.
-/
theorem arrows_diagonal_pow (k : ℕ) : Arrows (4 ^ k) (k + 1) (k + 1) := by
  have hle : (k + k).choose k ≤ 4 ^ k := by
    have := central_choose_le_four_pow k
    rwa [two_mul] at this
  intro V _ G W hW
  exact arrows_recursion k k G W (le_trans hle hW)

/-! ## Symmetry of Ramsey numbers -/

/--
**Symmetry.** `n → (s, t)` holds iff `n → (t, s)`: swapping the two colours leaves
the arrow relation invariant.  Hence Ramsey numbers satisfy `R(s,t) = R(t,s)`.
-/
theorem arrows_iff_symm {n s t : ℕ} : Arrows n s t ↔ Arrows n t s :=
  ⟨arrows_symm, arrows_symm⟩

/- -- !-- Lab Notes -- !--
ANALYSIS (Analyst): the diagonal bound exposes the *separation* between general
asymptotics and exact small values.  For `k = 2` the bound gives `R(3,3) ≤ 16`,
far from the true value `6`; for `k = 3` it gives `R(4,4) ≤ 64`, far from `18`.
The exact values proved elsewhere in this catalog therefore genuinely beat the
generic exponential estimate — the recursion is sharp only after colour symmetry
collapses the two off-diagonal feeds (as in `arrows_four_four`).

CRITIQUE (Critic): `central_choose_le_four_pow` is not `simp`/`decide`-only — it
uses the binomial row-sum identity and `Finset.single_le_sum`.  `arrows_diagonal_pow`
combines it with the recursion and monotonicity, and `arrows_iff_symm` packages a
genuine bidirectional colour symmetry.  None is vacuous: all have satisfiable,
non-trivial content for every `k`, `n`, `s`, `t`.

SYNTHESIS (PI): the catalog now contains both the *generic* diagonal bound
`R(k+1,k+1) ≤ 4^k` and the *exact* small values `R(3,3)=6`, `R(3,4)=9`,
`R(4,4)=18`, all on the single `Arrows` framework, with colour symmetry as the
unifying structural lemma.
-/

end RamseyTheory