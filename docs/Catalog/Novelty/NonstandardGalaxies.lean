/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The order type of the nonstandard model: galaxies

Two hypernaturals lie in the same *galaxy* when they differ by a standard
amount.  Galaxies measure how badly the Archimedean property fails: the
ultrapower is the standard galaxy `ℕ` followed by the nonstandard galaxies.

This file establishes the structure of that galaxy order, without ever building
the quotient type: we work with the equivalence relation `SameGalaxy` and the
strict relation `Far` ("separated by more than any standard amount") and prove

* `sameGalaxy_equivalence` — `SameGalaxy` is an equivalence relation, and it is
  a congruence for addition (`sameGalaxy_add`);
* `far_iff_not_sameGalaxy` — for `H < K`, being in different galaxies is
  exactly `Far H K`, so `Far` is the induced strict order;
* `far_congr` — `Far` is well defined on galaxies, hence descends to the
  quotient;
* `far_irrefl`, `far_trans` — it is a strict order;
* `far_dense` — **the galaxy order is dense**;
* `far_no_max`, `exists_far_below_of_isUnlimited` — it has no greatest element,
  and no least *nonstandard* element;
* `far_standard_iff_isUnlimited` — the standard galaxy is the least galaxy.

Together: the galaxies of the ultrapower form a linear order with least element
(the standard galaxy `ℕ`), and above it a dense order without endpoints.  This
is exactly the classical order type `ℕ + (dense unbounded)`; the failure of the
Archimedean axiom is therefore not a single defect but a densely ordered
continuum of scales.
-/

import Novelty.NonstandardInternalSets
import Mathlib.Tactic

open Filter

namespace NonstandardArithmetic

/-! ## Definitions -/

/-- Two hypernaturals are in the same galaxy when they differ by a standard
amount. -/
def SameGalaxy (H K : HyperNat) : Prop :=
  ∃ n : ℕ, K ≤ H + standard n ∧ H ≤ K + standard n

/-- `Far H K` says that `K` exceeds `H` by more than any standard amount, i.e.
`K` lies in a strictly higher galaxy. -/
def Far (H K : HyperNat) : Prop := ∀ n : ℕ, H + standard n < K

@[simp] theorem standard_zero : standard 0 = 0 := rfl

theorem standard_add (m n : ℕ) : standard m + standard n = standard (m + n) := by
  simp [standard]

/-! ## Pointwise descriptions -/

/-- Adding a hypernatural never decreases: the ultrapower of `ℕ` is
canonically ordered. -/
theorem hyper_le_add_right (A B : HyperNat) : A ≤ A + B := by
  refine Filter.Germ.inductionOn A (fun f => Filter.Germ.inductionOn B (fun g => ?_))
  rw [← Filter.Germ.coe_add, Filter.Germ.coe_le]
  exact Filter.Eventually.of_forall (fun i => by simp)

theorem far_coe {f g : ℕ → ℕ} :
    Far (f : HyperNat) (g : HyperNat) ↔
      ∀ n : ℕ, ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), f i + n < g i := by
  constructor
  · intro h n
    have h' := h n
    rw [standard_eq_coe, ← Filter.Germ.coe_add, Filter.Germ.coe_lt] at h'
    simpa using h'
  · intro h n
    rw [standard_eq_coe, ← Filter.Germ.coe_add, Filter.Germ.coe_lt]
    simpa using h n

theorem sameGalaxy_coe {f g : ℕ → ℕ} :
    SameGalaxy (f : HyperNat) (g : HyperNat) ↔
      ∃ n : ℕ, (∀ᶠ i in (hyperfilter ℕ : Filter ℕ), g i ≤ f i + n) ∧
        (∀ᶠ i in (hyperfilter ℕ : Filter ℕ), f i ≤ g i + n) := by
  constructor
  · rintro ⟨n, h1, h2⟩
    refine ⟨n, ?_, ?_⟩
    · rw [standard_eq_coe, ← Filter.Germ.coe_add, Filter.Germ.coe_le] at h1
      simpa using h1
    · rw [standard_eq_coe, ← Filter.Germ.coe_add, Filter.Germ.coe_le] at h2
      simpa using h2
  · rintro ⟨n, h1, h2⟩
    refine ⟨n, ?_, ?_⟩
    · rw [standard_eq_coe, ← Filter.Germ.coe_add, Filter.Germ.coe_le]
      simpa using h1
    · rw [standard_eq_coe, ← Filter.Germ.coe_add, Filter.Germ.coe_le]
      simpa using h2

/-! ## `SameGalaxy` is an equivalence relation and a congruence -/

theorem sameGalaxy_refl (H : HyperNat) : SameGalaxy H H :=
  ⟨0, by simp, by simp⟩

theorem sameGalaxy_symm {H K : HyperNat} (h : SameGalaxy H K) : SameGalaxy K H := by
  obtain ⟨n, h1, h2⟩ := h
  exact ⟨n, h2, h1⟩

theorem sameGalaxy_trans {H K M : HyperNat} (h1 : SameGalaxy H K) (h2 : SameGalaxy K M) :
    SameGalaxy H M := by
  refine Filter.Germ.inductionOn H (fun f => Filter.Germ.inductionOn K (fun g =>
    Filter.Germ.inductionOn M (fun k h1 h2 => ?_))) h1 h2
  rw [sameGalaxy_coe] at h1 h2 ⊢
  obtain ⟨a, ha1, ha2⟩ := h1
  obtain ⟨b, hb1, hb2⟩ := h2
  refine ⟨a + b, ?_, ?_⟩
  · filter_upwards [ha1, hb1] with i hi1 hi2 using by omega
  · filter_upwards [ha2, hb2] with i hi1 hi2 using by omega

theorem sameGalaxy_equivalence : Equivalence SameGalaxy :=
  ⟨sameGalaxy_refl, sameGalaxy_symm, sameGalaxy_trans⟩

/-- Being in the same galaxy is compatible with addition. -/
theorem sameGalaxy_add {H H' K K' : HyperNat} (h : SameGalaxy H H') (h' : SameGalaxy K K') :
    SameGalaxy (H + K) (H' + K') := by
  refine Filter.Germ.inductionOn H (fun f => Filter.Germ.inductionOn H' (fun f' =>
    Filter.Germ.inductionOn K (fun g => Filter.Germ.inductionOn K' (fun g' h h' => ?_)))) h h'
  rw [sameGalaxy_coe] at h h'
  obtain ⟨a, ha1, ha2⟩ := h
  obtain ⟨b, hb1, hb2⟩ := h'
  rw [← Filter.Germ.coe_add, ← Filter.Germ.coe_add, sameGalaxy_coe]
  refine ⟨a + b, ?_, ?_⟩
  · filter_upwards [ha1, hb1] with i hi1 hi2
    simp only [Pi.add_apply]
    omega
  · filter_upwards [ha2, hb2] with i hi1 hi2
    simp only [Pi.add_apply]
    omega

/-! ## `Far` is the induced strict order on galaxies -/

/-- Below the diagonal, "different galaxies" is exactly `Far`. -/
theorem far_iff_not_sameGalaxy {H K : HyperNat} (hlt : H < K) :
    Far H K ↔ ¬ SameGalaxy H K := by
  constructor
  · rintro hfar ⟨n, h1, _⟩
    exact absurd h1 (not_le.mpr (hfar n))
  · intro hns n
    by_contra hc
    rw [not_lt] at hc
    exact hns ⟨n, hc, le_trans hlt.le (hyper_le_add_right K (standard n))⟩

theorem far_lt {H K : HyperNat} (h : Far H K) : H < K := by
  have := h 0
  simpa using this

theorem far_irrefl (H : HyperNat) : ¬ Far H H := fun h => lt_irrefl H (far_lt h)

theorem far_trans {H K M : HyperNat} (h1 : Far H K) (h2 : Far K M) : Far H M := by
  intro n
  exact lt_trans (h1 n) (far_lt h2)

/-- `Far` only depends on the galaxies of its arguments, so it descends to a
strict order on the quotient by `SameGalaxy`. -/
theorem far_congr {H H' K K' : HyperNat} (hH : SameGalaxy H H') (hK : SameGalaxy K K')
    (h : Far H K) : Far H' K' := by
  refine Filter.Germ.inductionOn H (fun f => Filter.Germ.inductionOn H' (fun f' =>
    Filter.Germ.inductionOn K (fun g => Filter.Germ.inductionOn K' (fun g' hH hK h => ?_))))
    hH hK h
  rw [sameGalaxy_coe] at hH hK
  rw [far_coe] at h ⊢
  obtain ⟨a, ha1, ha2⟩ := hH
  obtain ⟨b, hb1, hb2⟩ := hK
  intro n
  filter_upwards [h (n + a + b), ha1, ha2, hb1, hb2] with i hi h1 h2 h3 h4
  omega

/-! ## The standard galaxy is least -/

theorem far_standard_iff_isUnlimited {H : HyperNat} :
    Far (standard 0) H ↔ IsUnlimited H := by
  constructor
  · intro h n
    have := h n
    rwa [standard_zero, zero_add] at this
  · intro h n
    rw [standard_zero, zero_add]
    exact h n

/-- Every unlimited element is far above every standard one. -/
theorem far_standard_of_isUnlimited {H : HyperNat} (h : IsUnlimited H) (m : ℕ) :
    Far (standard m) H := by
  intro n
  rw [standard_add]
  exact h (m + n)

/-! ## Density and unboundedness of the galaxy order -/

/-- **The galaxy order is dense**: between two different galaxies there is a
third one.  The witness is the pointwise midpoint. -/
theorem far_dense {H K : HyperNat} (h : Far H K) :
    ∃ M : HyperNat, Far H M ∧ Far M K := by
  refine Filter.Germ.inductionOn H (fun f => Filter.Germ.inductionOn K (fun g h => ?_)) h
  rw [far_coe] at h
  refine ⟨((fun i => f i + (g i - f i) / 2 : ℕ → ℕ) : HyperNat), ?_, ?_⟩
  · rw [far_coe]
    intro n
    filter_upwards [h (2 * n + 2)] with i hi
    omega
  · rw [far_coe]
    intro n
    filter_upwards [h (2 * n + 2)] with i hi
    omega

/-- The galaxy order has no greatest element: `H + ω` is always in a strictly
higher galaxy. -/
theorem far_no_max (H : HyperNat) : Far H (H + omega) := by
  refine Filter.Germ.inductionOn H (fun f => ?_)
  show Far (f : HyperNat) ((f : HyperNat) + ((fun i : ℕ => i : ℕ → ℕ) : HyperNat))
  rw [← Filter.Germ.coe_add, far_coe]
  intro n
  filter_upwards [eventually_ge_hyperfilter (n + 1)] with i hi
  simp only [Pi.add_apply]
  omega

/-- Above the standard galaxy there is no least galaxy: halving an unlimited
element lands in a strictly smaller nonstandard galaxy. -/
theorem exists_far_below_of_isUnlimited {H : HyperNat} (h : IsUnlimited H) :
    ∃ K : HyperNat, IsUnlimited K ∧ Far K H := by
  refine Filter.Germ.inductionOn H (fun f h => ?_) h
  rw [isUnlimited_coe] at h
  refine ⟨((fun i => f i / 2 : ℕ → ℕ) : HyperNat), ?_, ?_⟩
  · rw [isUnlimited_coe]
    intro n
    filter_upwards [h (2 * n + 2)] with i hi
    omega
  · rw [far_coe]
    intro n
    filter_upwards [h (2 * n + 2)] with i hi
    omega

/-- Consequently, the nonstandard part of the model contains an infinite
strictly decreasing chain of galaxies: the Archimedean property fails at
densely many different scales. -/
theorem exists_decreasing_galaxy_chain :
    ∃ c : ℕ → HyperNat, (∀ n, IsUnlimited (c n)) ∧ ∀ n, Far (c (n + 1)) (c n) := by
  classical
  have step : ∀ H : HyperNat, IsUnlimited H →
      ∃ K : HyperNat, IsUnlimited K ∧ Far K H := fun _ h => exists_far_below_of_isUnlimited h
  choose next hnext1 hnext2 using step
  refine ⟨fun n => Nat.rec (motive := fun _ => {H : HyperNat // IsUnlimited H})
    ⟨omega, isUnlimited_omega⟩ (fun _ p => ⟨next p.1 p.2, hnext1 p.1 p.2⟩) n |>.1, ?_, ?_⟩
  · intro n
    exact (Nat.rec (motive := fun _ => {H : HyperNat // IsUnlimited H})
      ⟨omega, isUnlimited_omega⟩ (fun _ p => ⟨next p.1 p.2, hnext1 p.1 p.2⟩) n).2
  · intro n
    exact hnext2 _ _

end NonstandardArithmetic