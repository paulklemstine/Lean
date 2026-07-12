/-
# A two-sided exponential bound for the diagonal Ramsey number

This file combines the two halves of diagonal Ramsey theory living in this
catalog into a single quantitative sandwich, on the shared `Arrows` framework:

* the **probabilistic lower bound** `not_arrows_of_pow`
  (`Catalog/Novelty/RamseyProbabilisticLowerBound.lean`), and
* the classical **Erdős–Szekeres exponential upper bound** `arrows_diagonal_pow`
  (`R(k+1,k+1) ≤ 4^k`, from `Applications/RamseyDiagonalBound.lean`).

Specialising to the even diagonal `k = 2m` gives, for every `m ≥ 4`,
`2 ^ (m-1) < R(2m, 2m) ≤ 4 ^ (2m-1)`, i.e. an explicit *infinite family* on
which the diagonal Ramsey number is sandwiched between two exponentials of `m`.

## Main results

* `RamseyTheory.ramsey_lower_even` — `¬ Arrows (2^(m-1)) (2m) (2m)` for `m ≥ 4`
  (lower bound `R(2m,2m) > 2^(m-1)`).
* `RamseyTheory.arrows_upper_even` — `Arrows (4^(2m-1)) (2m) (2m)`
  (upper bound `R(2m,2m) ≤ 4^(2m-1)`).
* `RamseyTheory.ramsey_even_sandwich` — both bounds together.

## Lab Notes — see `-- !-- Lab Notes -- !--` blocks below.
-/

import Mathlib
import Applications.RamseyDiagonalBound
import Novelty.RamseyProbabilisticLowerBound

open scoped Classical
open SimpleGraph Finset

namespace RamseyTheory

/- -- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): the probabilistic lower bound and the Erdős–Szekeres
upper bound, although proved by completely different machinery (counting vs.
recursion), should *cohabit* on the `Arrows` framework and pinch the diagonal
Ramsey number between `2^{Ω(k)}` and `4^k`.  Conjecture: even with the crude
`C(n,k) ≤ n^k` slack, the lower bound already reaches `2^{k/2-1}`, giving a clean
infinite family with no analytic estimate of `k!` required.

EXPERIMENT (Experimenter): we instantiate `k = 2m`, `n = 2^{m-1}`.  The crude
exponent check reduces to `(m-1)·2m + 1 < C(2m,2) = m(2m-1)`, i.e. `1 < m`; the
side condition `k ≤ n` reduces to `2m ≤ 2^{m-1}`, valid from `m = 4` on.  The
upper bound is the colour-diagonal of `arrows_diagonal_pow` at `k := 2m-1`.
-/

/-! ## Arithmetic inputs -/

/-
For `m ≥ 4`, the vertex count `2^{m-1}` exceeds the clique size `2m`
(the `k ≤ n` side condition of the probabilistic bound).
-/
lemma two_mul_le_two_pow {m : ℕ} (hm : 4 ≤ m) : 2 * m ≤ 2 ^ (m - 1) := by
  rcases m with ( _ | _ | _ | _ | m ) <;> simp_all +arith +decide [ pow_succ' ];
  induction' m with m ih <;> norm_num [ Nat.pow_succ' ] at * ; linarith [ Nat.one_le_pow m 2 zero_lt_two ]

/-
The crude probabilistic exponent inequality for the even diagonal:
`2 · (2^{m-1})^{2m} < 2^{C(2m,2)}` whenever `m ≥ 2`.
-/
lemma prob_exponent_lt {m : ℕ} (hm : 2 ≤ m) :
    2 * (2 ^ (m - 1)) ^ (2 * m) < 2 ^ ((2 * m).choose 2) := by
  rw [ ← pow_mul, mul_comm ];
  rcases m with ( _ | _ | m ) <;> simp +arith +decide [ Nat.choose_two_right ] at *;
  rw [ ← pow_succ' ] ; exact pow_lt_pow_right₀ ( by decide ) ( Nat.le_div_iff_mul_le zero_lt_two |>.2 <| by nlinarith ) ;

/-! ## The even-diagonal lower and upper bounds -/

/-- **Lower bound (probabilistic).** For `m ≥ 4`, `R(2m, 2m) > 2^{m-1}`:
some 2-colouring of `K_{2^{m-1}}` has no monochromatic `K_{2m}`. -/
theorem ramsey_lower_even {m : ℕ} (hm : 4 ≤ m) :
    ¬ Arrows (2 ^ (m - 1)) (2 * m) (2 * m) :=
  not_arrows_of_pow (two_mul_le_two_pow hm) (prob_exponent_lt (le_trans (by norm_num) hm))

/-
**Upper bound (Erdős–Szekeres).** For `m ≥ 1`, `R(2m, 2m) ≤ 4^{2m-1}`:
every 2-colouring of `K_{4^{2m-1}}` has a monochromatic `K_{2m}`.  This is the
colour-diagonal of `arrows_diagonal_pow` at `k := 2m - 1`.
-/
theorem arrows_upper_even {m : ℕ} (hm : 1 ≤ m) :
    Arrows (4 ^ (2 * m - 1)) (2 * m) (2 * m) := by
  have := @arrows_diagonal_pow ( 2 * m - 1 );
  rwa [ Nat.sub_add_cancel ( by linarith ) ] at this

/-- **Two-sided exponential sandwich** for the even diagonal Ramsey number:
for every `m ≥ 4`, `2^{m-1} < R(2m, 2m) ≤ 4^{2m-1}`. -/
theorem ramsey_even_sandwich {m : ℕ} (hm : 4 ≤ m) :
    ¬ Arrows (2 ^ (m - 1)) (2 * m) (2 * m) ∧ Arrows (4 ^ (2 * m - 1)) (2 * m) (2 * m) :=
  ⟨ramsey_lower_even hm, arrows_upper_even (le_trans (by norm_num) hm)⟩

/- -- !-- Lab Notes -- !--
ANALYSIS (Analyst): the sandwich makes the *gap* visible.  Lower `2^{m-1} =
2^{(k/2)-1}` and upper `4^{2m-1} = 2^{2(k-1)}` differ by roughly a factor of `4`
in the exponent — exactly the still-open constant in `R(k,k)^{1/k} ∈ [√2, 4]`.
The probabilistic side is loss-free in *form* (an honest union bound); the slack
to the true `√2` base is entirely in the crude `C(n,k) ≤ n^k` step, not in the
method.

CRITIQUE (Critic): is `ramsey_even_sandwich` vacuous or trivial?  No: the lower
half negates `Arrows` by exhibiting a colouring (via `not_arrows_of_pow`), and
the upper half is the genuine recursion bound `arrows_diagonal_pow`; the two
thresholds satisfy `2^{m-1} < 4^{2m-1}` for all `m ≥ 4`, so the interval is
non-degenerate.  Boundary check (Extra Adversarial Mandate): at `m = 3` the side
condition `2m ≤ 2^{m-1}` fails (`6 ≤ 4` is false), so we cannot assert the lower
bound there — the hypothesis `m ≥ 4` is the precise boundary of this argument,
not a convenience.

SYNTHESIS (PI): both directions of the diagonal Ramsey estimate now live in one
file on one framework, parameterised over an explicit infinite family, ready to
be tightened by replacing the `n^k` bound with `n^k / k!`.
-/

end RamseyTheory