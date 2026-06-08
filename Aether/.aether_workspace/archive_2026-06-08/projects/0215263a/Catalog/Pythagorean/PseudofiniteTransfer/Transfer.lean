/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Pseudofinite Transfer: Core Theorems

This file proves the restricted Łoś transfer theorem and its applications to
definable growth and coset-control transfer.

## Main results

* `los_restrictedFormula`: Restricted Łoś theorem by structural induction.
* `mem_ultraSet_iff_eventually`: Transfer of definable membership.
* `eventual_doubling_transfer`: Transfer of bounded doubling.
* `eventual_control_transfer`: Transfer of coset control.
* `pseudofinite_growth_control_transfer`: Growth-or-control dichotomy transfer.
* `los_small_doubling_as_formula`: Cross-domain bridge (logic ↔ combinatorics).

## References

* Łoś, J. (1955). Quelques remarques, théorèmes et problèmes.
* Hrushovski, E. (2012). Stable group theory and approximate subgroups.
-/

import Mathlib
import Pythagorean.PseudofiniteTransfer.Defs

open Filter Set Pointwise

namespace PseudofiniteTransfer

variable {ι : Type*}

/-! ## Boolean Closure Lemmas for Ultrafilter Membership -/

/-- Conjunction: two sets are both U-large iff their intersection is. -/
theorem ultra_and_iff (U : Ultrafilter ι) (S T : Set ι) :
    (S ∈ U.1 ∧ T ∈ U.1) ↔ (S ∩ T) ∈ U.1 := by
  constructor
  · exact fun ⟨hS, hT⟩ => U.1.inter_mem hS hT
  · exact fun h => ⟨U.1.mem_of_superset h inter_subset_left,
                     U.1.mem_of_superset h inter_subset_right⟩

/-- Disjunction: a union is U-large iff at least one part is. -/
theorem ultra_or_iff (U : Ultrafilter ι) (S T : Set ι) :
    (S ∈ U.1 ∨ T ∈ U.1) ↔ (S ∪ T) ∈ U.1 :=
  Ultrafilter.union_mem_iff.symm

/-- Negation: the complement is U-large iff the set is not. -/
theorem ultra_not_iff (U : Ultrafilter ι) (S : Set ι) :
    (¬S ∈ U.1) ↔ Sᶜ ∈ U.1 :=
  Ultrafilter.compl_mem_iff_notMem.symm

/-- Monotonicity: superset of a U-large set is U-large. -/
theorem ultra_mono (U : Ultrafilter ι) {S T : Set ι} (h : S ⊆ T)
    (hS : S ∈ U.1) : T ∈ U.1 :=
  U.1.mem_of_superset hS h

/-! ## Theorem 1: Restricted Łoś Transfer Theorem -/

/-
**Restricted Łoś theorem.** For any restricted formula φ,
satisfaction in the ultraproduct equals eventual satisfaction.
Proved by structural induction using ultrafilter Boolean closure.

The proof uses:
- structural induction on the formula
- `by_contra` for the implication case
- ultrafilter properties (closure under ∩, ∪, complement)
-/
theorem los_restrictedFormula (U : Ultrafilter ι) {α : ι → Type*}
    (φ : RestrictedFormula ι α) (f : ∀ i, α i) :
    φ.HoldsUltra U (UltraProduct.mk U f) ↔
      φ.satSet f ∈ U.1 := by
        induction' φ with φ ψ hφ hψ generalizing f;
        · convert UltraPred_mk U φ f;
        · convert ultra_and_iff U ( ψ.satSet f ) ( hφ.satSet f ) using 1;
          exact ⟨ fun h => ⟨ hψ f |>.1 h.1, ‹∀ f, hφ.HoldsUltra U ( UltraProduct.mk U f ) ↔ hφ.satSet f ∈ U› f |>.1 h.2 ⟩, fun h => ⟨ hψ f |>.2 h.1, ‹∀ f, hφ.HoldsUltra U ( UltraProduct.mk U f ) ↔ hφ.satSet f ∈ U› f |>.2 h.2 ⟩ ⟩;
        · rename_i φ ψ hφ hψ;
          convert ultra_or_iff U ( φ.satSet f ) ( ψ.satSet f ) using 1;
          exact Iff.trans ( by rfl ) ( Iff.trans ( or_congr ( hφ f ) ( hψ f ) ) ( by rfl ) );
        · rename_i φ hφ;
          convert ultra_not_iff U ( φ.satSet f ) using 1;
          exact not_congr ( hφ f );
        · rename_i φ ψ hφ hψ;
          by_cases h : φ.satSet f ∈ U.1 <;> simp_all +decide [ RestrictedFormula.satSet ];
          · -- By definition of holds Ultra, we have that (φ.imp ψ).HoldsUltra U (UltraProduct.mk U f) is equivalent to (φ.HoldsUltra U (UltraProduct.mk U f) → ψ.HoldsUltra U (UltraProduct.mk U f)).
            simp [RestrictedFormula.HoldsUltra];
            simp +decide [ hφ f, hψ f,RestrictedFormula.satSet, RestrictedFormula.Sat ];
            rw [ show { i | φ.Sat f i → ψ.Sat f i } = { i | φ.Sat f i }ᶜ ∪ { i | ψ.Sat f i } by ext; by_cases hi : φ.Sat f ‹_› <;> simp +decide [ hi ] ] ; simp +decide [ h, Ultrafilter.union_mem_iff ] ;
          · simp_all +decide [ RestrictedFormula.HoldsUltra, RestrictedFormula.satSet ];
            exact Filter.mem_of_superset ( U.compl_mem_iff_notMem.mpr h ) fun i hi => by simp_all +decide [ RestrictedFormula.Sat ] ;

/-! ## Theorem 2: Transfer of Definable Membership -/

/-- Membership in the ultraproduct-lifted set of a uniform definable
family is equivalent to eventual membership. -/
theorem mem_ultraSet_iff_eventually (U : Ultrafilter ι) {α : ι → Type*}
    (A : UniformDefinableFamily ι α) (f : ∀ i, α i) :
    UltraPred U A.toPredFamily (UltraProduct.mk U f) ↔
      ({i | f i ∈ A.eval i} : Set ι) ∈ U.1 := by
  simp [UltraPred_mk, UniformDefinableFamily.toPredFamily]

/-- Eventual equality of evaluation sets implies same ultraproduct predicate. -/
theorem ultra_eval_congr_eventually (U : Ultrafilter ι) {α : ι → Type*}
    (A B : UniformDefinableFamily ι α)
    (heq : ({i | A.eval i = B.eval i} : Set ι) ∈ U.1)
    (f : ∀ i, α i) :
    UltraPred U A.toPredFamily (UltraProduct.mk U f) ↔
      UltraPred U B.toPredFamily (UltraProduct.mk U f) := by
  simp only [UltraPred_mk, UniformDefinableFamily.toPredFamily]
  constructor
  · intro hA
    apply U.1.mem_of_superset (U.1.inter_mem hA heq)
    intro i ⟨hi, he⟩
    simp only [Set.mem_setOf_eq] at he hi ⊢
    rw [← he]; exact hi
  · intro hB
    apply U.1.mem_of_superset (U.1.inter_mem hB heq)
    intro i ⟨hi, he⟩
    simp only [Set.mem_setOf_eq] at he hi ⊢
    rw [he]; exact hi

/-! ## Theorem 3: Transfer of Bounded Doubling -/

/-- **Eventual bounded doubling implies pseudofinite bounded doubling.** -/
theorem eventual_doubling_transfer
    {ι : Type*} {U : Ultrafilter ι}
    {G : ι → Type*} [∀ i, Group (G i)] [∀ i, Fintype (G i)] [∀ i, DecidableEq (G i)]
    (A : ∀ i, Finset (G i)) (K : ℕ)
    (hsmall : ({i | ((A i * A i).card : ℕ) ≤ K * (A i).card} : Set ι) ∈ U.1) :
    UltraDoublingBound U A K :=
  hsmall

/-- Weakening of the doubling bound: K-bounded ⟹ K'-bounded for K' ≥ K. -/
theorem ultra_doubling_mono
    {ι : Type*} {U : Ultrafilter ι}
    {G : ι → Type*} [∀ i, Group (G i)] [∀ i, Fintype (G i)] [∀ i, DecidableEq (G i)]
    (A : ∀ i, Finset (G i)) {K K' : ℕ} (hKK' : K ≤ K')
    (hK : UltraDoublingBound U A K) :
    UltraDoublingBound U A K' := by
  apply U.1.mem_of_superset hK
  intro i hi
  calc (A i * A i).card ≤ K * (A i).card := hi
    _ ≤ K' * (A i).card := Nat.mul_le_mul_right _ hKK'

/-- Bounded doubling and another property hold simultaneously on a U-large set. -/
theorem ultra_doubling_and_property
    {ι : Type*} {U : Ultrafilter ι}
    {G : ι → Type*} [∀ i, Group (G i)] [∀ i, Fintype (G i)] [∀ i, DecidableEq (G i)]
    (A : ∀ i, Finset (G i)) (K : ℕ) (P : ι → Prop)
    (hK : UltraDoublingBound U A K)
    (hP : ({i | P i} : Set ι) ∈ U.1) :
    ({i | (A i * A i).card ≤ K * (A i).card ∧ P i} : Set ι) ∈ U.1 :=
  U.1.inter_mem hK hP

/-! ## Theorem 4: Transfer of Coset Control -/

/-- **Eventual coset control transfers to the ultraproduct.** -/
theorem eventual_control_transfer
    {ι : Type*} {U : Ultrafilter ι}
    {G : ι → Type*} [∀ i, Group (G i)] [∀ i, Fintype (G i)] [∀ i, DecidableEq (G i)]
    (A H : ∀ i, Finset (G i)) (C : ℕ)
    (hcontrol : ({i | CosetControlledBy (A i) (H i) C} : Set ι) ∈ U.1) :
    UltraCosetControl U A H C :=
  hcontrol

/-- Weakening of coset control: C-controlled ⟹ C'-controlled for C' ≥ C. -/
theorem ultra_control_mono
    {ι : Type*} {U : Ultrafilter ι}
    {G : ι → Type*} [∀ i, Group (G i)] [∀ i, Fintype (G i)] [∀ i, DecidableEq (G i)]
    (A H : ∀ i, Finset (G i)) {C C' : ℕ} (hCC' : C ≤ C')
    (hC : UltraCosetControl U A H C) :
    UltraCosetControl U A H C' := by
  apply U.1.mem_of_superset hC
  intro i ⟨S, hS_card, hS_cover⟩
  exact ⟨S, le_trans hS_card hCC', hS_cover⟩

/-! ## Theorem 5: Growth-or-Control Dichotomy Transfer -/

/-- **Growth-or-control dichotomy transfers to the pseudofinite setting.**
If each finite instance satisfies: "bounded doubling ⟹ coset control",
and the family has bounded doubling in the ultrafilter sense, then
the pseudofinite limit has coset control. -/
theorem pseudofinite_growth_control_transfer
    {ι : Type*} {U : Ultrafilter ι}
    {G : ι → Type*} [∀ i, Group (G i)] [∀ i, Fintype (G i)] [∀ i, DecidableEq (G i)]
    (A H : ∀ i, Finset (G i)) (K C : ℕ)
    (hdich : ∀ i, (A i * A i).card ≤ K * (A i).card →
      CosetControlledBy (A i) (H i) C)
    (hbound : UltraDoublingBound U A K) :
    UltraCosetControl U A H C := by
  apply U.1.mem_of_superset hbound
  intro i hi
  exact hdich i hi

/-! ## Cross-Domain Bridge: Logic ↔ Additive Combinatorics -/

/-
**Restricted Łoś preserves small-doubling formulas.**
Encoding the small-doubling condition as a restricted formula and
applying Łoś gives the pseudofinite doubling bound.
-/
theorem los_small_doubling_as_formula
    {ι : Type*} {U : Ultrafilter ι}
    {G : ι → Type*} [∀ i, Group (G i)] [∀ i, Fintype (G i)] [∀ i, DecidableEq (G i)]
    (A : ∀ i, Finset (G i)) (K : ℕ) :
    let doublePred : ∀ i, Set (G i) :=
      fun i => if (A i * A i).card ≤ K * (A i).card then Set.univ else ∅
    let φ : RestrictedFormula ι (fun i => G i) := .pred doublePred
    ∀ (f : ∀ i, G i),
      φ.HoldsUltra U (UltraProduct.mk U f) ↔
        ({i | (A i * A i).card ≤ K * (A i).card} : Set ι) ∈ U.1 := by
          convert PseudofiniteTransfer.los_restrictedFormula U _ _ using 1;
          rotate_left;
          exact fun _ => ℕ;
          exact RestrictedFormula.pred fun i => if ( A i * A i ).card ≤ K * ( A i ).card then Set.univ else ∅;
          exact fun _ => 0;
          simp +decide [ RestrictedFormula.HoldsUltra, RestrictedFormula.satSet ];
          simp +decide [ RestrictedFormula.Sat ]

/-! ## Conjecture -/

/-- The uniform complexity bound conjecture. -/
def uniformComplexityBoundConjecture : Prop :=
  ∀ (ι : Type*) (U : Ultrafilter ι)
    (G : ι → Type*) [∀ i, Group (G i)] [∀ i, Fintype (G i)] [∀ i, DecidableEq (G i)]
    (A : ∀ i, Finset (G i)) (K : ℕ),
    UltraDoublingBound U A K →
    ∃ (C : ℕ) (H : ∀ i, Finset (G i)),
      UltraCosetControl U A H C

end PseudofiniteTransfer