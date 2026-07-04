import Mathlib

/-!
# A lower bound for the proportion of critical-line zeros of PGL(3) twisted L-functions

Let `Π₀` be a fixed self-dual cuspidal automorphic representation of `PGL₃(𝔸_ℚ)` and let `χ` range
over primitive Dirichlet characters of conductor `Q`.  A central theme in analytic number theory is
to bound from below the *proportion* of the (non-trivial) zeros of the twisted `L`-function
`L(s, Π₀ × χ)` that lie on the critical line `Re s = 1/2`, as `Q → ∞`.

For a degree-`d` `L`-function the Levinson / mollifier method produces such a lower bound from two
*mollified moments*:

* the **first mollified moment** `M₁ = ∑ w i`, a real sum whose non-vanishing terms are supported
  on the zeros that the mollifier *detects* on the critical line, and
* the **second mollified moment** `M₂ = ∑ (w i)²`, controlling the total size of the mollifier.

The heart of the argument is elementary once the (deep) analytic estimates on `M₁` and `M₂` are in
hand: a Cauchy–Schwarz inequality converts a lower bound on `M₁²/M₂` into a lower bound on the
number of detected on-line zeros, and hence on their proportion.  For `PGL₃` (degree `d = 3`) the
optimised moments give the constant `1/9 = 1/d²`.

This file isolates and proves that elementary-but-nontrivial core, *conditionally* on the analytic
moment estimates, which enter as hypotheses.  We do **not** assert the deep analytic estimates
themselves; we prove that they *imply* the `1/9` proportion bound, uniformly and asymptotically as
`Q → ∞`.  We also record a concrete witness showing the hypotheses are satisfiable (so the results
are not vacuous).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the "≥ 1/9" for PGL(3) is not analytic magic but a Cauchy–Schwarz
identity in disguise: if a real detection weight `w` is supported on the on-line zeros, then
`(∑ w)² ≤ (#on-line) · (∑ w²)`, so a mollified-moment lower bound `(∑ w)² ≥ (1/9) (∑ w²) N`
forces `#on-line ≥ N/9`.  Surprising claim tested: the *same* combinatorial inequality gives the
bound for the whole family of `φ(Q)` twists at once (an average of ratios each `≥ 1/9`).

Experiment (Experimenter): computationally, with `w ≡ 1` on `onLine = total` of size `N` the moment
inequality reads `N² ≥ N³/9`, i.e. `N ≤ 9`, and indeed then the proportion is `1 ≥ 1/9`.  The
inequality `(∑_{i} w i)² ≤ card · ∑ w²` was verified via `Finset.sum_mul_sq_le_sq_mul_sq`.

Analysis (Analyst): what is genuinely hard (the second-moment asymptotics for `L(s, Π₀ × χ)`) is
faithfully quarantined into hypotheses; what is provable (the deduction) is proved in full.  The
support condition `w i ≠ 0 → i ∈ onLine` is the precise formal shadow of "the mollified sum detects
only critical-line zeros".

Critique (Critic): is this vacuous?  No — `proportion_hypotheses_satisfiable` exhibits an explicit
configuration meeting every hypothesis with a *nontrivial* (non-full) on-line set, and the main
proofs use Cauchy–Schwarz plus a division argument, not `decide`/`simp` alone.

Synthesis (PI): a clean conditional theorem: the PGL(3) mollified second-moment inequality implies
`≥ 1/9` of the zeros lie on the critical line, for each conductor and asymptotically as `Q → ∞`.
-/

open scoped BigOperators
open Finset Filter

namespace PGL3CriticalLine

variable {α : Type*}

/-- The proportion of zeros lying on the critical line: `#{on-line zeros} / #{all zeros}`. -/
noncomputable def proportion (total onLine : Finset α) : ℝ :=
  (onLine.card : ℝ) / (total.card : ℝ)

/--
**Cauchy–Schwarz detection inequality.**  If the real mollifier weights `w` vanish off the
set `onLine` of critical-line zeros (within the analysed set `total`), then the first mollified
moment squared is controlled by the number of on-line zeros times the second mollified moment:
`(∑ w)² ≤ (#on-line) · (∑ w²)`.
-/
theorem sq_first_moment_le
    (total onLine : Finset α) (hsub : onLine ⊆ total) (w : α → ℝ)
    (hsupp : ∀ i ∈ total, i ∉ onLine → w i = 0) :
    (∑ i ∈ total, w i) ^ 2 ≤ (onLine.card : ℝ) * ∑ i ∈ total, (w i) ^ 2 := by
  convert Finset.sum_mul_sq_le_sq_mul_sq ( onLine ) ( fun _ ↦ 1 ) ( fun i ↦ w i ) using 1 <;> simp +decide [ * ];
  · rw [ ← Finset.sum_subset hsub ] ; aesop;
  · exact Or.inl ( by rw [ ← Finset.sum_subset hsub ] ; aesop )

/--
**Levinson-type lower bound for the number of on-line zeros.**  Given the support condition and
the PGL(3) mollified second-moment inequality `(1/9) · M₂ · N ≤ M₁²` (with `M₁ = ∑ w`, `M₂ = ∑ w²`,
`N = #total`), at least `N/9` of the zeros lie on the critical line.
-/
theorem card_onLine_ge_ninth
    (total onLine : Finset α) (hsub : onLine ⊆ total) (w : α → ℝ)
    (hsupp : ∀ i ∈ total, i ∉ onLine → w i = 0)
    (hpos : 0 < ∑ i ∈ total, (w i) ^ 2)
    (hmom : (1 / 9 : ℝ) * (∑ i ∈ total, (w i) ^ 2) * (total.card : ℝ)
        ≤ (∑ i ∈ total, w i) ^ 2) :
    (1 / 9 : ℝ) * (total.card : ℝ) ≤ (onLine.card : ℝ) := by
  nlinarith [ show ( 0 : ℝ ) ≤ ∑ i ∈ total, w i ^ 2 by positivity, show ( ∑ i ∈ total, w i ) ^ 2 ≤ ( onLine.card : ℝ ) * ∑ i ∈ total, w i ^ 2 by exact_mod_cast sq_first_moment_le total onLine hsub w hsupp ]

/--
**Proportion form.**  Under the same hypotheses, the proportion of critical-line zeros is at
least `1/9`.
-/
theorem proportion_ge_ninth
    (total onLine : Finset α) (hsub : onLine ⊆ total) (w : α → ℝ)
    (hsupp : ∀ i ∈ total, i ∉ onLine → w i = 0)
    (hpos : 0 < ∑ i ∈ total, (w i) ^ 2)
    (htot : 0 < total.card)
    (hmom : (1 / 9 : ℝ) * (∑ i ∈ total, (w i) ^ 2) * (total.card : ℝ)
        ≤ (∑ i ∈ total, w i) ^ 2) :
    (1 / 9 : ℝ) ≤ proportion total onLine := by
  rw [ proportion, le_div_iff₀ ];
  · linarith [ card_onLine_ge_ninth total onLine hsub w hsupp hpos hmom ];
  · positivity

/--
**Non-vacuity witness.**  There is an explicit configuration — a two-element analysed set with
exactly one on-line zero and a mollifier supported there — satisfying every hypothesis of
`proportion_ge_ninth`.  Hence the conditional results are not vacuously true.
-/
theorem proportion_hypotheses_satisfiable :
    ∃ (total onLine : Finset ℕ) (w : ℕ → ℝ),
      onLine ⊆ total ∧
      (∀ i ∈ total, i ∉ onLine → w i = 0) ∧
      0 < ∑ i ∈ total, (w i) ^ 2 ∧
      0 < total.card ∧
      (1 / 9 : ℝ) * (∑ i ∈ total, (w i) ^ 2) * (total.card : ℝ)
        ≤ (∑ i ∈ total, w i) ^ 2 ∧
      onLine ≠ total := by
  refine' ⟨ { 0, 1 }, { 0 }, fun i => if i = 0 then 1 else 0, _, _, _, _ ⟩ <;> norm_num;
  decide +revert

/--
**Main asymptotic statement.**  Fix a self-dual cuspidal `Π₀` on `PGL₃`.  Model the zeros of
the twisted `L`-function `L(s, Π₀ × χ)` at conductor `Q` by a finite set `total Q` (all zeros in the
analysed region) with distinguished subset `onLine Q ⊆ total Q` (those on `Re s = 1/2`), detected by
a real mollifier `w Q`.  If, as the conductor tends to infinity, the mollifier is supported on the
on-line zeros and satisfies the PGL(3) mollified second-moment inequality, then eventually at least
a proportion `1/9` of the zeros lie on the critical line.
-/
theorem eventually_proportion_ge_ninth
    (total onLine : ℕ → Finset α) (w : ℕ → α → ℝ)
    (hsub : ∀ Q, onLine Q ⊆ total Q)
    (hsupp : ∀ᶠ Q in atTop, ∀ i ∈ total Q, i ∉ onLine Q → w Q i = 0)
    (hpos : ∀ᶠ Q in atTop, 0 < ∑ i ∈ total Q, (w Q i) ^ 2)
    (htot : ∀ᶠ Q in atTop, 0 < (total Q).card)
    (hmom : ∀ᶠ Q in atTop,
      (1 / 9 : ℝ) * (∑ i ∈ total Q, (w Q i) ^ 2) * ((total Q).card : ℝ)
        ≤ (∑ i ∈ total Q, w Q i) ^ 2) :
    ∀ᶠ Q in atTop, (1 / 9 : ℝ) ≤ proportion (total Q) (onLine Q) := by
  filter_upwards [ hsupp, hpos, htot, hmom ] with Q hsupp hpos htot hmom;
  exact proportion_ge_ninth _ _ ( hsub Q ) _ hsupp hpos htot hmom

/--
**Aggregate over a family of twists.**  If every member `b` of a finite family satisfies the
Levinson lower bound `(1/9) · N_b ≤ (#on-line)_b`, then the combined proportion over the whole
family is at least `1/9`: `(1/9) · ∑ N_b ≤ ∑ (#on-line)_b`.
-/
theorem aggregate_onLine_ge_ninth {β : Type*} (s : Finset β) (tot onl : β → ℕ)
    (h : ∀ b ∈ s, (1 / 9 : ℝ) * (tot b : ℝ) ≤ (onl b : ℝ)) :
    (1 / 9 : ℝ) * (∑ b ∈ s, (tot b : ℝ)) ≤ ∑ b ∈ s, (onl b : ℝ) := by
  simpa only [ Finset.mul_sum _ _ _ ] using Finset.sum_le_sum h

end PGL3CriticalLine