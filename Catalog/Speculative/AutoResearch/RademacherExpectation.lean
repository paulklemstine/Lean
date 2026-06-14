/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Expected Empirical Rademacher Complexity over the Boolean Hypercube

This file develops a *measure-theory-free* account of the **expected** empirical
Rademacher complexity of a finite hypothesis class.  A Rademacher sign vector is an
element of the Boolean hypercube `Fin n → Bool`, and the expectation is realised as
an honest arithmetic mean over `Finset.univ` (cardinality `2 ^ n`).  The conceptual
spine is a *duality*: a sign vector is a character of `(ℤ/2)ⁿ`, and averaging over
signs is a pairing against the uniform measure on the dual group.  The decisive
structural fact is the **sign-flip involution** `b ↦ ¬b`, which negates every
correlation and hence forces the raw correlation to average to zero.

## Main results

* `rademacher_correlation_bounded` — `|corr σ h| ≤ B` whenever each `|hᵢ| ≤ B`.
* `sum_rademacherCorrelation_eq_zero` — the duality identity: the correlation of any
  fixed hypothesis, summed over all `2 ^ n` sign patterns, is exactly `0`.
* `expectedRademacher_singleton_eq_zero` — a singleton class has zero complexity.
* `expectedRademacher_nonneg` — a class containing `0` has nonnegative complexity.
* `expectedRademacher_mono` — complexity is monotone in the hypothesis class.
* `expectedRademacher_le_bound` — the basic upper bound `Rₙ(H) ≤ B`.
* `expectedRademacher_smul_nonneg` — positive homogeneity `Rₙ(c • H) = c · Rₙ(H)`.

-- !-- Lab Notebook -- !--
Hypothesis: the *expected* (not fixed-sign) empirical Rademacher complexity over the
  Boolean hypercube admits a fully finite, measure-free theory whose every estimate
  flows from a single sign-flip involution plus the pointwise coordinate bound.
Result: all seven theorems above are proven with `sorry = 0`, depending only on
  `propext`, `Classical.choice`, `Quot.sound`.
Insight: the involution `σ ↦ ¬∘σ` is an `Equiv` on `Fin n → Bool`; pairing it with
  `Equiv.sum_comp` turns "the mean correlation vanishes" into the one-line algebraic
  fact `S = -S`.  Every other result is `Finset.sup'` monotonicity transporting the
  scalar bound `|corr| ≤ B` through the average.
Failure analysis: dividing the correlation by `n` makes the `n = 0` corner of the
  pointwise bound vacuous, so `rademacher_correlation_bounded` carries the honest
  hypothesis `0 < n`; the involution identity and all `sup'` estimates need no such
  caveat and are stated in full generality.
-/
import Mathlib

open Finset BigOperators

namespace RademacherExpectation

open scoped Classical

noncomputable section

/-- The real sign attached to a Boolean: `true ↦ 1`, `false ↦ -1`. -/
noncomputable def sgn (b : Bool) : ℝ := if b then 1 else -1

@[simp] lemma sgn_true : sgn true = 1 := rfl
@[simp] lemma sgn_false : sgn false = -1 := rfl

/-- The sign-flip involution negates the sign. -/
lemma sgn_not (b : Bool) : sgn (!b) = - sgn b := by cases b <;> simp [sgn]

/-- `|sgn b| = 1`. -/
@[simp] lemma abs_sgn (b : Bool) : |sgn b| = 1 := by cases b <;> simp [sgn]

/-- The Rademacher correlation of a sign vector `σ` with a hypothesis `h`,
defined as the empirical average `(1/n) ∑ᵢ σᵢ · hᵢ`. -/
noncomputable def rademacherCorrelation (n : ℕ) (σ : Fin n → Bool) (h : Fin n → ℝ) : ℝ :=
  (∑ i, sgn (σ i) * h i) / n

/-- The expected empirical Rademacher complexity of a finite class `H`:
the mean over all `2 ^ n` sign patterns of the best correlation achievable in `H`. -/
noncomputable def expectedRademacher (n : ℕ) (H : Finset (Fin n → ℝ)) (hne : H.Nonempty) : ℝ :=
  (∑ σ : Fin n → Bool, H.sup' hne (fun h => rademacherCorrelation n σ h)) / (2 ^ n)

/-- The sign-flip involution on the Boolean hypercube as an `Equiv`. -/
noncomputable def flipEquiv (n : ℕ) : (Fin n → Bool) ≃ (Fin n → Bool) :=
  Equiv.piCongrRight (fun _ =>
    Function.Involutive.toPerm Bool.not (by intro b; cases b <;> rfl))

@[simp] lemma flipEquiv_apply (n : ℕ) (σ : Fin n → Bool) (i : Fin n) :
    flipEquiv n σ i = !(σ i) := rfl

/-
!-- Each fixed hypothesis is correlated with a sign vector by at most the
coordinatewise bound `B`, since `|sgn| = 1` and the average of `n` terms each
`≤ B` is `≤ B`. -- !--

The Rademacher correlation is bounded by the coordinatewise sup-bound.
-/
theorem rademacher_correlation_bounded (n : ℕ) (hn : 0 < n) (σ : Fin n → Bool)
    (h : Fin n → ℝ) (B : ℝ) (hB : ∀ i, |h i| ≤ B) :
    |rademacherCorrelation n σ h| ≤ B := by
  rw [ rademacherCorrelation, abs_div, abs_of_pos ( by positivity : 0 < ( n : ℝ ) ) ];
  rw [ div_le_iff₀' ( Nat.cast_pos.mpr hn ) ];
  exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( le_trans ( Finset.sum_le_sum fun _ _ => show |sgn ( σ _ ) * h _| ≤ B by rw [ abs_mul, abs_sgn ] ; norm_num; exact hB _ ) ( by norm_num ) )

/-
!-- The map `σ ↦ ¬∘σ` is an involution that negates every correlation, so by
`Equiv.sum_comp` the sum equals its own negation, forcing it to vanish. -- !--

**Duality identity.** Summed over all sign patterns the correlation vanishes.
-/
theorem sum_rademacherCorrelation_eq_zero (n : ℕ) (h : Fin n → ℝ) :
    ∑ σ : Fin n → Bool, rademacherCorrelation n σ h = 0 := by
  by_contra h_nonzero;
  -- Apply the involution `flipEquiv` to each term in the sum.
  have h_flip : ∑ σ : Fin n → Bool, rademacherCorrelation n (flipEquiv n σ) h = ∑ σ : Fin n → Bool, -rademacherCorrelation n σ h := by
    simp +decide [ rademacherCorrelation, Finset.sum_neg_distrib, sgn_not ];
    simp +decide only [neg_div, sum_neg_distrib];
  exact h_nonzero ( by rw [ Equiv.sum_comp ( flipEquiv n ) fun σ => rademacherCorrelation n σ h ] at h_flip; norm_num at *; linarith )

/-
!-- For a singleton the `sup'` is the correlation itself, whose mean over signs
is zero by the duality identity. -- !--

A singleton hypothesis class has exactly zero expected complexity.
-/
theorem expectedRademacher_singleton_eq_zero (n : ℕ) (h : Fin n → ℝ) :
    expectedRademacher n {h} (singleton_nonempty h) = 0 := by
  -- Apply the duality identity to the singleton set {h}.
  have h_singleton : ∑ σ : Fin n → Bool, rademacherCorrelation n σ h = 0 :=
    sum_rademacherCorrelation_eq_zero n h
  unfold expectedRademacher; aesop

/-
!-- Each `sup'` dominates the correlation with the zero hypothesis, which is
exactly `0`; averaging preserves the sign. -- !--

A class containing the zero hypothesis has nonnegative expected complexity.
-/
theorem expectedRademacher_nonneg (n : ℕ) (H : Finset (Fin n → ℝ)) (hne : H.Nonempty)
    (h0 : (0 : Fin n → ℝ) ∈ H) :
    0 ≤ expectedRademacher n H hne := by
  refine' div_nonneg ( Finset.sum_nonneg _ ) ( by positivity );
  exact fun σ _ => le_trans ( by unfold rademacherCorrelation; aesop ) ( Finset.le_sup' ( fun h => rademacherCorrelation n σ h ) h0 )

/-
!-- A larger class can only raise each pointwise `sup'`, hence the average. -- !--

Expected complexity is monotone in the hypothesis class.
-/
theorem expectedRademacher_mono (n : ℕ) (H₁ H₂ : Finset (Fin n → ℝ))
    (hne₁ : H₁.Nonempty) (hne₂ : H₂.Nonempty) (hsub : H₁ ⊆ H₂) :
    expectedRademacher n H₁ hne₁ ≤ expectedRademacher n H₂ hne₂ := by
  refine' div_le_div_of_nonneg_right _ ( by positivity );
  gcongr

/-
!-- Every correlation is `≤ B`, so every `sup'` is `≤ B`, and the mean of values
`≤ B` is `≤ B`. -- !--

The basic Massart-type upper bound `Rₙ(H) ≤ B`.
-/
theorem expectedRademacher_le_bound (n : ℕ) (hn : 0 < n) (H : Finset (Fin n → ℝ))
    (hne : H.Nonempty) (B : ℝ) (hB : ∀ h ∈ H, ∀ i, |h i| ≤ B) :
    expectedRademacher n H hne ≤ B := by
  refine' div_le_of_le_mul₀ _ _ _ <;> try positivity;
  · exact le_trans ( abs_nonneg _ ) ( hB _ hne.choose_spec ⟨ 0, hn ⟩ );
  · refine' le_trans ( Finset.sum_le_sum fun σ _ => Finset.sup'_le _ _ _ ) _;
    use fun σ => B;
    · exact fun h hh => le_of_abs_le ( rademacher_correlation_bounded n hn σ h B ( hB h hh ) );
    · norm_num [ mul_comm ]

/-
!-- Scaling a hypothesis by `c ≥ 0` scales its correlation by `c`; since `c ≥ 0`
it commutes with `sup'` (`mul₀_sup'`) and with the average. -- !--

**Positive homogeneity.** For `c ≥ 0`, `Rₙ(c • H) = c · Rₙ(H)`.
-/
theorem expectedRademacher_smul_nonneg (n : ℕ) (H : Finset (Fin n → ℝ)) (hne : H.Nonempty)
    (c : ℝ) (hc : 0 ≤ c) :
    expectedRademacher n (H.image (fun h => c • h)) (hne.image _)
      = c * expectedRademacher n H hne := by
  unfold expectedRademacher;
  rw [ Finset.sum_congr rfl fun _ _ => ?_ ];
  rw [ ← mul_div_assoc, Finset.mul_sum ];
  refine' le_antisymm _ _ <;> simp +decide [ Finset.sup'_le_iff, Finset.le_sup'_iff ];
  · intro h hh; exact le_trans ( by
      unfold rademacherCorrelation; simp +decide [ mul_assoc, mul_comm ] ;
      rw [ ← Finset.mul_sum _ _ _, mul_div_assoc ] ) ( mul_le_mul_of_nonneg_left ( Finset.le_sup' _ hh ) hc );
  · obtain ⟨ b, hb ⟩ := Finset.exists_mem_eq_sup' hne fun h => rademacherCorrelation n ‹_› h;
    use b; simp_all +decide [ rademacherCorrelation ] ; ring_nf;
    simp +decide [ mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ]

end

end RademacherExpectation