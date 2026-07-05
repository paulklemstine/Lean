/-
# Sign Alternation in q-Hypergeometric Series via Oscillatory Asymptotics
# near a Root of Unity

For a q-hypergeometric series whose coefficients `a n` have an asymptotic
expansion dominated, near the root of unity `ω = -1`, by an oscillatory term
proportional to `ω^{-n} = (-1)^n` with a slowly varying positive amplitude
`A n`, the signs of the coefficients **alternate** off a density-zero set of
indices `n`.

This file develops the structural mechanism behind this phenomenon (studied for
concrete mock/quantum modular objects such as the function `v₁(q)` of
Folsom–Males–Rolen–Storzer, and in Andrews' work on Ramanujan's lost notebook):

* `densityZero`                  — natural (asymptotic) density zero of `S ⊆ ℕ`.
* `densityZero_of_finite`        — every finite set has density zero.
* `altExceptionSet`              — the set of indices where sign-alternation fails.
* `oscillatory_root_of_unity_alternation` — **main theorem**: if the `(-1)^n`
  oscillation eventually dominates the error, the exceptional set is finite,
  hence of density zero.

The connection to the `q`-Pochhammer / Nahm-sum machinery of the catalog is made
explicit through `qPoch_one_signs`, which reuses `NahmRank4.qPoch`.
-/
import Mathlib
import Applications.NahmSums.QPochhammer

open Filter Topology

namespace QSignAlt

/-! ## Natural density -/

open Classical in
/-- A set `S ⊆ ℕ` has **natural (asymptotic) density zero** if the proportion of
its elements among `{0, …, N-1}` tends to `0` as `N → ∞`. -/
noncomputable def densityZero (S : Set ℕ) : Prop :=
  Tendsto (fun N : ℕ => (((Finset.range N).filter (fun n => n ∈ S)).card : ℝ) / (N : ℝ))
    atTop (𝓝 0)

/-
!-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): "If an integer/real coefficient sequence has an
asymptotic dominated near ω = -1 by (-1)^n · A n with A n > 0 slowly varying,
then consecutive coefficients have opposite signs once the error is beaten by
the amplitude — so the sign pattern is (eventually) +,-,+,-,…"
EXPERIMENT (Experimenter): For a n = (-1)^n A n + e n with A n > 0, |e n| < A n:
n even ⇒ a n = A n + e n ≥ A n - |e n| > 0; n odd ⇒ a n ≤ -A n + |e n| < 0.
Hence sign(a n) = sign((-1)^n), giving a n · a(n+1) < 0.
ANALYSIS (Analyst): The exceptional set is contained in the finite window
{n < N₀} where dominance has not yet kicked in, so it is finite; a finite set
has density zero because its counting function is bounded by a constant.
CRITIQUE (Critic): The theorem is vacuous only if no N₀ exists; the hypothesis
supplies one. The result genuinely needs a parity case split and the triangle
inequality, not `simp`. Sharpness (infinite but density-zero exceptions) is
established separately in `DensityZeroSharpness.lean`.
!-- end Lab Notes -- !--

Every finite set of naturals has density zero.
-/
theorem densityZero_of_finite {S : Set ℕ} (hS : S.Finite) : densityZero S := by
  refine' squeeze_zero_norm' _ _;
  exact fun n => ( hS.toFinset.card : ℝ ) / n;
  · simp +zetaDelta at *;
    exact ⟨ 0, fun n hn => by gcongr ; exact fun x hx => hS.mem_toFinset.mpr <| by aesop ⟩;
  · exact tendsto_const_nhds.div_atTop tendsto_natCast_atTop_atTop

/-! ## Sign alternation -/

/-- The set of indices where **sign alternation fails**: `a n` and `a (n+1)` do
*not* have strictly opposite signs. -/
def altExceptionSet (a : ℕ → ℝ) : Set ℕ := {n | ¬ (a n * a (n + 1) < 0)}

/-
**Sign of a dominant oscillatory coefficient.** If `a n = (-1)^n · A n + e n`
with the (necessarily positive) amplitude `A n` beating the error `|e n| < A n`
(the hypothesis `|e n| < A n` already forces `A n > 0`), then the sign of `a n`
is exactly the sign of `(-1)^n`.
-/
theorem dominant_sign (a A e : ℕ → ℝ) (n : ℕ)
    (h : a n = (-1) ^ n * A n + e n) (he : |e n| < A n) :
    (Even n → 0 < a n) ∧ (Odd n → a n < 0) := by
  cases' Nat.even_or_odd n with h h <;> simp_all +decide [ abs_lt ];
  linarith

/-
**Main theorem.** If the coefficients `a n` of a `q`-hypergeometric series
admit, from some index `N₀` on, an oscillatory asymptotic
`a n = (-1)^n · A n + e n` (the `ω = -1` contribution) with positive amplitude
`A n > 0` dominating the error `|e n| < A n`, then the set of indices where the
signs fail to alternate is finite, and therefore of natural density zero.
-/
theorem oscillatory_root_of_unity_alternation
    (a A e : ℕ → ℝ) (N₀ : ℕ)
    (hdecomp : ∀ n, a n = (-1) ^ n * A n + e n)
    (hdom : ∀ n, N₀ ≤ n → 0 < A n ∧ |e n| < A n) :
    (altExceptionSet a).Finite ∧ densityZero (altExceptionSet a) := by
  -- Prove that the set of indices where the sign fails to alternate is finite.
  have h_finite : (altExceptionSet a).Finite := by
    refine Set.finite_iff_bddAbove.mpr ⟨ N₀, fun n hn => le_of_not_gt fun h => hn ?_ ⟩;
    cases' Nat.even_or_odd n with h h <;> simp_all +decide;
    · exact mul_neg_of_pos_of_neg ( by linarith [ abs_lt.mp ( hdom n ( by linarith ) |>.2 ) ] ) ( by linarith [ abs_lt.mp ( hdom ( n + 1 ) ( by linarith ) |>.2 ) ] );
    · exact mul_neg_of_neg_of_pos ( by linarith [ abs_lt.mp ( hdom n ( by linarith ) |>.2 ) ] ) ( by linarith [ abs_lt.mp ( hdom ( n + 1 ) ( by linarith ) |>.2 ) ] );
  exact ⟨ h_finite, densityZero_of_finite h_finite ⟩

/-! ## Bridge to the catalog `q`-Pochhammer machinery -/

/-
!-- Lab Notes -- !--
SYNTHESIS: The finite q-Pochhammer (q;q)_1 = 1 - X already exhibits the
period-two sign pattern in miniature: its constant term is +1 (established
in the catalog as `NahmRank4.qPoch_coeff_zero`) and its degree-1 term is -1,
so the two coefficients strictly alternate — the ω = -1 seed of the general
oscillatory phenomenon.
!-- end Lab Notes -- !--
-/
open Polynomial in
/-- The two coefficients of the catalog `q`-Pochhammer `(q;q)_1 = 1 - X`
strictly alternate in sign: `c₀ · c₁ < 0`, with `c₀ = +1` (reusing
`NahmRank4.qPoch_coeff_zero`). -/
theorem qPoch_one_signs :
    ((NahmRank4.qPoch 1).coeff 0 : ℤ) * (NahmRank4.qPoch 1).coeff 1 < 0 := by
  norm_num [ NahmRank4.qPoch, Finset.prod_range_succ ];
  norm_num [ Polynomial.coeff_one ]

end QSignAlt