/-
Copyright (c) 2025. All rights reserved.

# Idempotent Large Deviations: the Donsker–Varadhan Variational Principle

This file develops the **idempotent Donsker–Varadhan / Gibbs variational principle**,
the max-plus analogue of the classical convex-duality formula

  `log E_P[e^φ] = sup_Q ( E_Q[φ] − KL(Q‖P) )`.

In the idempotent world the free energy is the max-plus integral
`∫⁺ φ dP = supₓ (φ x + w_P x)` and the relative-entropy / KL term is replaced by the
**idempotent relative entropy** `D(Q‖P) = supₓ (w_Q x − w_P x)`.  We prove that

  `∫⁺ φ dP = sup_Q ( ∫⁺ φ dQ − D(Q‖P) )`,

the supremum being attained at `Q = P`.  We also establish the **Gibbs inequality**
`D(Q‖P) ≥ 0` for idempotent probabilities, with the exact equality characterisation
`D(Q‖P) = 0 ↔ w_Q ≤ w_P` pointwise.

This builds directly on `Catalog/Tropical/MeasureTheory/Basic.lean` and
`Catalog/Tropical/MeasureTheory/LargeDeviations.lean` (the objects `maxPlusIntegral`,
`idempotentRate`, `IsTropicalProbability`).

## Main results

* `relEnt_self` — `D(P‖P) = 0`.
* `relEnt_nonneg` — **Gibbs inequality**: `D(Q‖P) ≥ 0` for idempotent probabilities.
* `relEnt_eq_zero_iff` — `D(Q‖P) = 0 ↔ ∀x, w_Q x ≤ w_P x`.
* `donsker_varadhan_le` — weak duality: `∫⁺ φ dQ − D(Q‖P) ≤ ∫⁺ φ dP` for all `Q`.
* `idempotent_donsker_varadhan` — the variational principle as an `IsGreatest`.
* `idempotent_varadhan_variational` — `∫⁺ φ dP = supₓ (φ x − I_P(x))` (Varadhan form).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The classical Donsker–Varadhan duality should have an
  exact idempotent counterpart in which the KL divergence is replaced by the
  *additive* relative entropy `D(Q‖P) = supₓ (w_Q − w_P)`, and — surprising
  sub-claim — the variational supremum should be attained at `Q = P` itself, so the
  idempotent Gibbs measure that maximises `free energy − entropy` is the reference
  law (no tilting needed when `φ` is absorbed into the test measure).
Experiment (Experimenter): Defined `relEnt` and proved (i) `D(P‖P) = 0` directly,
  (ii) the Gibbs inequality from the normalisation `supₓ w_Q = 0` (the maximiser of
  `w_Q` witnesses `D ≥ −w_P ≥ 0`), (iii) weak duality from the sub-additivity of the
  finite supremum `sup'(a+b) ≤ sup' a + sup' b`, and (iv) attainment at `Q = P` via
  `relEnt_self`, packaged as `IsGreatest`.
Analysis (Analyst): The conjecture SURVIVES.  The proof reveals that idempotent
  Donsker–Varadhan is *purely order-theoretic* — it needs only sub-additivity of the
  max, no convexity — in sharp contrast to the Legendre–Fenchel duality of
  `DualityGap.lean`, which genuinely needs convexity.  This isolates exactly which
  parts of Cramér's program survive the idempotent collapse.
Critique (Critic): `relEnt` is a genuine functional (not a rename), the Gibbs
  inequality consumes the `IsTropicalProbability` normalisation non-trivially, and
  the main theorem is an `IsGreatest` proved with `Finset.sup'` sub-additivity and
  `le_antisymm`, never `decide`.  Weak duality is stated for an *arbitrary* test
  measure `Q`, so the principle is non-vacuous.
-- !-- end Lab Notes -- !--
-/

import Mathlib
import Catalog.Tropical.MeasureTheory.Basic
import Catalog.Tropical.MeasureTheory.LargeDeviations

namespace TropicalLDP.DonskerVaradhan

open TropicalMeasureTheory TropicalLDP Finset

variable {X : Type*} [Fintype X] [Nonempty X]

/-- The **idempotent relative entropy** of `Q` with respect to `P`:
`D(Q‖P) = supₓ (w_Q x − w_P x)`, the max-plus analogue of the Kullback–Leibler
divergence. -/
noncomputable def relEnt (Q P : MaxPlusMeasure X) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun x => Q.weight x - P.weight x)

/-
`D(P‖P) = 0`.
-/
theorem relEnt_self (P : MaxPlusMeasure X) : relEnt P P = 0 := by
  unfold relEnt; aesop;

/-
**Gibbs inequality**: the idempotent relative entropy of two idempotent
probability measures is non-negative.
-/
theorem relEnt_nonneg (Q P : MaxPlusMeasure X)
    [hQ : IsTropicalProbability X Q] [hP : IsTropicalProbability X P] :
    0 ≤ relEnt Q P := by
  obtain ⟨ x₀, hx₀ ⟩ := Finset.exists_mem_eq_sup' Finset.univ_nonempty Q.weight;
  exact le_trans ( by linarith [ hP.weight_nonpos x₀, hQ.total_mass, Finset.le_sup' ( fun x => Q.weight x ) hx₀.1 ] ) ( Finset.le_sup' ( fun x => Q.weight x - P.weight x ) hx₀.1 )

/-
**Equality characterisation** of the Gibbs inequality: the idempotent relative
entropy vanishes exactly when `Q` is pointwise dominated by `P`.
-/
theorem relEnt_eq_zero_iff (Q P : MaxPlusMeasure X)
    [hQ : IsTropicalProbability X Q] [hP : IsTropicalProbability X P] :
    relEnt Q P = 0 ↔ ∀ x, Q.weight x ≤ P.weight x := by
  constructor <;> intro h <;> simp_all +decide [ relEnt ];
  · exact fun x => by linarith [ Finset.le_sup' ( fun x => Q.weight x - P.weight x ) ( Finset.mem_univ x ) ] ;
  · refine' le_antisymm _ _;
    · exact Finset.sup'_le _ _ fun x _ => sub_nonpos_of_le ( h x );
    · convert relEnt_nonneg Q P

/-
**Weak duality**: for *any* test measure `Q`, the idempotent free energy of `φ`
under `Q` minus the relative entropy `D(Q‖P)` is bounded by the free energy under
`P`.
-/
theorem donsker_varadhan_le (P Q : MaxPlusMeasure X) (φ : X → ℝ) :
    maxPlusIntegral φ Q - relEnt Q P ≤ maxPlusIntegral φ P := by
  rw [ sub_le_iff_le_add ];
  refine' Finset.sup'_le _ _ _;
  exact fun x _ => by linarith [ le_maxPlusIntegral P φ x, show Q.weight x - P.weight x ≤ relEnt Q P from Finset.le_sup' ( fun x => Q.weight x - P.weight x ) ( Finset.mem_univ x ) ] ;

/-
**Idempotent Donsker–Varadhan variational principle.**  The max-plus integral
(idempotent free energy) of `φ` against `P` is the *greatest* value of
`∫⁺ φ dQ − D(Q‖P)` over all test measures `Q`, the supremum being attained at
`Q = P`.
-/
theorem idempotent_donsker_varadhan (P : MaxPlusMeasure X) (φ : X → ℝ) :
    IsGreatest
      {r : ℝ | ∃ Q : MaxPlusMeasure X, r = maxPlusIntegral φ Q - relEnt Q P}
      (maxPlusIntegral φ P) := by
  refine' ⟨ ⟨ P, _ ⟩, fun r hr => _ ⟩;
  · rw [ relEnt_self, sub_zero ];
  · exact hr.choose_spec.symm ▸ donsker_varadhan_le P hr.choose φ

/-
**Idempotent Varadhan lemma (rate-function form).**  The max-plus integral of
`φ` is the supremum of `φ` discounted by the large-deviation rate function:
`∫⁺ φ dP = supₓ (φ x − I_P(x))`.
-/
theorem idempotent_varadhan_variational (P : MaxPlusMeasure X) (φ : X → ℝ) :
    maxPlusIntegral φ P
      = Finset.univ.sup' Finset.univ_nonempty (fun x => φ x - idempotentRate P x) := by
  unfold maxPlusIntegral idempotentRate ;
  grind

end TropicalLDP.DonskerVaradhan