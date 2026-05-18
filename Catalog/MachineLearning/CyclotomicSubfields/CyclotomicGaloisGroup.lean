/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/

import Mathlib
import Speculative.CyclotomicSubfields.CyclicGroupSubgroups

/-!
# Cyclotomic Galois group structure and intermediate field extraction

For an odd prime `p`, we prove:
1. The Galois group `Gal(ℚ(ζ_p)/ℚ)` is cyclic of order `p - 1`.
2. For every divisor `d ∣ (p - 1)`, there exists an intermediate field of degree `d` over `ℚ`.

## Main results

* `prime_cyclotomic_galois_group_cyclic` : the Galois group is cyclic
* `prime_cyclotomic_galois_group_card` : the Galois group has order `p.totient`
* `prime_cyclotomic_galois_group_card_eq` : for odd prime, order = `p - 1`
* `exists_intermediateField_prime_cyclotomic_finrank_eq` : intermediate field of any divisor degree
-/

open Polynomial IntermediateField

noncomputable section

variable (p : ℕ) [hp : Fact (Nat.Prime p)]

/-
The Galois group of `ℚ(ζ_p)/ℚ` is cyclic for any prime `p`.
-/
theorem prime_cyclotomic_galois_group_cyclic :
    IsCyclic (CyclotomicField p ℚ ≃ₐ[ℚ] CyclotomicField p ℚ) := by
  -- Use the isomorphism `IsCyclotomicExtension.Rat.galEquivZMod p (CyclotomicField p ℚ) : Gal ≃* (ZMod p)ˣ` to transfer cyclicity from `(ZMod p)ˣ`.
  have h_iso : Gal(CyclotomicField p ℚ/ℚ) ≃* (ZMod p)ˣ := by
    convert IsCyclotomicExtension.Rat.galEquivZMod p ( CyclotomicField p ℚ ) using 1;
  -- Since (ZMod p)ˣ is cyclic, we can conclude that Gal(CyclotomicField p ℚ/ℚ) is cyclic.
  have h_cyclic : IsCyclic (ZMod p)ˣ := by
    infer_instance;
  obtain ⟨ g, hg ⟩ := h_cyclic;
  use h_iso.symm g;
  intro x;
  obtain ⟨ a, ha ⟩ := hg ( h_iso x );
  exact ⟨ a, by simpa [ ← h_iso.injective.eq_iff ] using ha ⟩

/-
The Galois group of `ℚ(ζ_p)/ℚ` has cardinality `p.totient`.
-/
theorem prime_cyclotomic_galois_group_card :
    Fintype.card (CyclotomicField p ℚ ≃ₐ[ℚ] CyclotomicField p ℚ) = p.totient := by
  have h_galois_group : (CyclotomicField p ℚ ≃ₐ[ℚ] CyclotomicField p ℚ) ≃* (ZMod p)ˣ := by
    exact?
  have h_card : Fintype.card (CyclotomicField p ℚ ≃ₐ[ℚ] CyclotomicField p ℚ) = Nat.totient p := by
    exact Fintype.card_congr h_galois_group.toEquiv ▸ ZMod.card_units_eq_totient p
  exact (by
  grind +revert)

/-
For an odd prime `p`, the Galois group of `ℚ(ζ_p)/ℚ` has cardinality `p - 1`.
-/
theorem prime_cyclotomic_galois_group_card_eq (hpodd : p ≠ 2) :
    Fintype.card (CyclotomicField p ℚ ≃ₐ[ℚ] CyclotomicField p ℚ) = p - 1 := by
  convert prime_cyclotomic_galois_group_card p using 1;
  rw [ Nat.totient_prime hp.1 ]

/-
For an odd prime `p` and divisor `d ∣ (p - 1)`, there exists an intermediate field
    `ℚ ⊆ K ⊆ ℚ(ζ_p)` with `[K : ℚ] = d`.
-/
theorem exists_intermediateField_prime_cyclotomic_finrank_eq
    (d : ℕ) (hpodd : p ≠ 2) (hd : d ∣ (p - 1)) :
    ∃ K : IntermediateField ℚ (CyclotomicField p ℚ),
      Module.finrank ℚ K = d := by
  -- Use prime_cyclotomic_galois_subgroup_exists to get a subgroup H of Gal with Nat.card H = (p-1)/d.
  obtain ⟨H, hH⟩ : ∃ H : Subgroup (CyclotomicField p ℚ ≃ₐ[ℚ] CyclotomicField p ℚ), Nat.card H = (p - 1) / d := by
    convert cyclic_group_exists_subgroup_of_card_dvd ( ( p - 1 ) / d ) ?_;
    exact?;
    · convert prime_cyclotomic_galois_group_cyclic p;
    · convert Nat.div_dvd_of_dvd hd using 1;
      convert prime_cyclotomic_galois_group_card_eq p hpodd using 1;
  -- By the tower law: finrank ℚ (CyclotomicField p ℚ) = finrank ℚ (fixedField H) * finrank (fixedField H) (CyclotomicField p ℚ)
  have h_tower : Module.finrank ℚ (CyclotomicField p ℚ) = Module.finrank ℚ (IntermediateField.fixedField H) * Module.finrank (IntermediateField.fixedField H) (CyclotomicField p ℚ) := by
    rw [ Module.finrank_mul_finrank ];
  -- We know that `finrank ℚ (CyclotomicField p ℚ) = p - 1` and `finrank (fixedField H) (CyclotomicField p ℚ) = Nat.card H`.
  have h_finranks : Module.finrank ℚ (CyclotomicField p ℚ) = p - 1 ∧ Module.finrank (IntermediateField.fixedField H) (CyclotomicField p ℚ) = Nat.card H := by
    have h_finranks : Module.finrank ℚ (CyclotomicField p ℚ) = p.totient ∧ Module.finrank (IntermediateField.fixedField H) (CyclotomicField p ℚ) = Nat.card H := by
      constructor;
      · convert IsCyclotomicExtension.finrank _ _;
        · exact ⟨ hp.1.ne_zero ⟩;
        · infer_instance;
        · infer_instance;
        · exact Polynomial.cyclotomic.irreducible_rat hp.1.pos;
      · convert IntermediateField.finrank_fixedField_eq_card H;
    exact ⟨ h_finranks.1.trans ( Nat.totient_prime hp.1 ), h_finranks.2 ⟩;
  -- Substitute the known values into the tower law equation.
  have h_subst : p - 1 = Module.finrank ℚ (IntermediateField.fixedField H) * ((p - 1) / d) := by
    grind;
  exact ⟨ _, by nlinarith [ Nat.div_mul_cancel hd, Nat.sub_pos_of_lt hp.1.one_lt ] ⟩

/-
For an odd prime `p` and divisor `d ∣ (p - 1)`, there exists a subgroup of the Galois group
    of `ℚ(ζ_p)/ℚ` with cardinality `(p - 1) / d`.
-/
theorem prime_cyclotomic_galois_subgroup_exists
    (d : ℕ) (hpodd : p ≠ 2) (hd : d ∣ (p - 1)) :
    ∃ H : Subgroup (CyclotomicField p ℚ ≃ₐ[ℚ] CyclotomicField p ℚ),
      Nat.card H = (p - 1) / d := by
  have h_card : Fintype.card (CyclotomicField p ℚ ≃ₐ[ℚ] CyclotomicField p ℚ) = p - 1 := by
    convert prime_cyclotomic_galois_group_card_eq p hpodd using 1;
  have h_cyclic : IsCyclic (CyclotomicField p ℚ ≃ₐ[ℚ] CyclotomicField p ℚ) := by
    grind +suggestions;
  have h_subgroup : ∀ {n : ℕ}, n ∣ Fintype.card (CyclotomicField p ℚ ≃ₐ[ℚ] CyclotomicField p ℚ) → ∃ H : Subgroup (CyclotomicField p ℚ ≃ₐ[ℚ] CyclotomicField p ℚ), Nat.card H = n := by
    apply cyclic_group_exists_subgroup_of_card_dvd;
  exact h_subgroup ( h_card.symm ▸ Nat.div_dvd_of_dvd hd )

end