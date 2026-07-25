/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Group-theoretic classification for S₅

We prove the group-theoretic facts needed for the Galois group computation:
a subgroup of `S₅` whose order is divisible by 30 and not contained
in `A₅` must be all of `S₅`.
-/

open Equiv.Perm

/-! ### Helper lemmas about S₅ -/

/-
Any nontrivial normal subgroup of `S₅` contains `A₅`.
    This follows from the simplicity of `A₅` and the commutator `[S₅, S₅] = A₅`.
-/
theorem Perm_Fin5_alternating_le_of_normal_nontrivial
    (N : Subgroup (Equiv.Perm (Fin 5))) [hN : N.Normal] (hbot : N ≠ ⊥) :
    alternatingGroup (Fin 5) ≤ N := by
  -- By the simplicity of alternatingGroup (Fin 5), N ∩ alternatingGroup is either trivial or the entire alternatingGroup.
  have h_inter : N ⊓ alternatingGroup (Fin 5) = ⊥ ∨ N ⊓ alternatingGroup (Fin 5) = alternatingGroup (Fin 5) := by
    have h_inter_normal : N ⊓ alternatingGroup (Fin 5) = ⊥ ∨ N ⊓ alternatingGroup (Fin 5) = alternatingGroup (Fin 5) := by
      have h_simple : IsSimpleGroup (alternatingGroup (Fin 5)) := by
        infer_instance
      have h_inter_normal : (N ⊓ alternatingGroup (Fin 5)).comap (Subgroup.subtype (alternatingGroup (Fin 5))) = ⊥ ∨ (N ⊓ alternatingGroup (Fin 5)).comap (Subgroup.subtype (alternatingGroup (Fin 5))) = ⊤ := by
        apply h_simple.2;
        infer_instance;
      simp_all +decide [ Subgroup.eq_bot_iff_forall, Subgroup.eq_top_iff' ];
      exact Or.imp ( fun h x hx hx' => h x hx' <| Subgroup.mem_subgroupOf.mpr hx ) ( fun h x hx => h x hx ) h_inter_normal;
    exact h_inter_normal;
  cases' h_inter with h_inter h_inter <;> simp_all +decide [ Subgroup.eq_bot_iff_forall ];
  -- If N ∩ alternatingGroup = ⊥, then N and alternatingGroup intersect trivially. Since N is nontrivial, there's some σ ∈ N with σ ≠ 1. Since N ∩ alternatingGroup = ⊥, σ ∉ alternatingGroup, so sign(σ) = -1.
  obtain ⟨σ, hσN, hσ_ne_one, hσ_sign⟩ : ∃ σ ∈ N, σ ≠ 1 ∧ sign σ = -1 := by
    exact hbot.imp fun x hx => ⟨ hx.1, hx.2, Or.resolve_left ( Int.units_eq_one_or _ ) fun h => hx.2 <| h_inter x hx.1 h ⟩;
  -- Since N is normal, σ⁻¹ ∈ N, and then for any g ∈ S_5, g*σ⁻¹*g⁻¹ ∈ N.
  have h_conj : ∀ g : Equiv.Perm (Fin 5), g * σ⁻¹ * g⁻¹ ∈ N := by
    exact fun g => hN.conj_mem _ ( N.inv_mem hσN ) g;
  -- Since N is normal, σ⁻¹ ∈ N, and then for any g ∈ S_5, g*σ⁻¹*g⁻¹ ∈ N. Therefore, N contains all elements of the form g*σ⁻¹*g⁻¹.
  have h_all_conj : ∀ g : Equiv.Perm (Fin 5), g * σ⁻¹ * g⁻¹ = σ⁻¹ := by
    intro g
    have h_conj_eq : g * σ⁻¹ * g⁻¹ * σ ∈ N := by
      exact N.mul_mem ( h_conj g ) hσN;
    specialize h_inter _ h_conj_eq ; simp_all +decide [ mul_assoc ];
    exact eq_inv_of_mul_eq_one_left h_inter;
  have h_center : σ⁻¹ ∈ Subgroup.center (Equiv.Perm (Fin 5)) := by
    rw [ Subgroup.mem_center_iff ];
    exact fun g => by simpa [ mul_inv_eq_iff_eq_mul ] using h_all_conj g;
  have h_center_trivial : ∀ g : Equiv.Perm (Fin 5), g ∈ Subgroup.center (Equiv.Perm (Fin 5)) → g = 1 := by
    native_decide +revert;
  exact False.elim <| hσ_ne_one <| inv_eq_one.mp <| h_center_trivial _ h_center

/-
`S₅` has no subgroup of index 4.
-/
theorem Perm_Fin5_no_index_four
    (H : Subgroup (Equiv.Perm (Fin 5)))
    (hH : H.index = 4) : False := by
  -- The coset action gives φ : S₅ → Perm(S₅/H) with ker φ ≤ H
  -- ker φ is normal in S₅, with |ker φ| ≤ |H| = 30
  -- By Perm_Fin5_alternating_le_of_normal_nontrivial, if ker φ ≠ ⊥,
  -- then A₅ ≤ ker φ, so |ker φ| ≥ 60 > 30, contradiction.
  -- So ker φ = ⊥, i.e., φ is injective.
  -- But |S₅| = 120 > 24 = |S₄|, contradiction.
  -- The kernel of the coset action is a normal subgroup of $S_5$ contained in $H$.
  set φ : Equiv.Perm (Fin 5) →* Equiv.Perm (Equiv.Perm (Fin 5) ⧸ H) := MulAction.toPermHom (Equiv.Perm (Fin 5)) (Equiv.Perm (Fin 5) ⧸ H) with hφ_def
  have h_ker_le_H : φ.ker ≤ H := by
    intro g hg; have := hg; simp_all +decide [ Equiv.Perm.ext_iff, MulAction.toPermHom ] ;
    specialize hg ( QuotientGroup.mk 1 ) ; simp_all +decide [ QuotientGroup.eq ] ;
  -- By Perm_Fin5_alternating_le_of_normal_nontrivial, if ker(φ) ≠ ⊥ then alternatingGroup (Fin 5) ≤ ker(φ).
  by_cases h_ker_bot : φ.ker = ⊥;
  · -- If ker(φ) = ⊥, then φ is injective.
    have h_inj : Function.Injective φ := by
      grind +suggestions;
    have h_card : Nat.card (Equiv.Perm (Equiv.Perm (Fin 5) ⧸ H)) ≥ Nat.card (Equiv.Perm (Fin 5)) := by
      apply_rules [ Nat.card_le_card_of_injective ];
    simp_all +decide [ Fintype.card_perm ];
    have h_card : Nat.card (Equiv.Perm (Equiv.Perm (Fin 5) ⧸ H)) = Nat.factorial (H.index) := by
      simp +decide [ Subgroup.index ];
      exact Nat.card_perm;
    simp_all +decide [ Nat.factorial ];
  · have h_alternating_le_ker : alternatingGroup (Fin 5) ≤ φ.ker := by
      apply_rules [ Perm_Fin5_alternating_le_of_normal_nontrivial ];
    have h_card_ker : Nat.card φ.ker ∣ Nat.card H := by
      convert Subgroup.card_dvd_of_le h_ker_le_H;
    have h_card_H : Nat.card H = 30 := by
      have := Subgroup.index_mul_card H; simp_all +decide ;
      exact mul_left_cancel₀ ( by decide ) ( this.trans ( by native_decide ) );
    have h_card_alternating : Nat.card (alternatingGroup (Fin 5)) = 60 := by
      simp +decide [ Nat.card_eq_fintype_card ];
    have h_card_ker_ge_alternating : Nat.card φ.ker ≥ Nat.card (alternatingGroup (Fin 5)) := by
      apply_rules [ Nat.card_mono ];
      exact Set.toFinite _;
    linarith [ Nat.le_of_dvd ( by linarith ) h_card_ker ]

/-- Any subgroup of `S₅` of index 2 is `A₅`. -/
theorem Perm_Fin5_index_two_eq_alt
    (H : Subgroup (Equiv.Perm (Fin 5)))
    (hH : H.index = 2) :
    H = alternatingGroup (Fin 5) := by
  exact eq_alternatingGroup_of_index_eq_two hH

/-! ### Main classification theorem -/

/-- A subgroup of `S₅` whose order is divisible by `30` and not contained
    in `A₅` must equal `S₅`. -/
theorem S5_of_30_dvd_not_alt
    (H : Subgroup (Equiv.Perm (Fin 5)))
    (h30 : 30 ∣ Nat.card H)
    (hnotalt : ¬ (H ≤ alternatingGroup (Fin 5))) :
    H = ⊤ := by
  have h_cases : Nat.card H = 30 ∨ Nat.card H = 60 ∨ Nat.card H = 120 := by
    have h_cases : 30 ∣ Nat.card H ∧ Nat.card H ∣ 120 := by
      exact ⟨ h30, by simpa [ Fintype.card_perm ] using Subgroup.card_subgroup_dvd_card H ⟩;
    have := Nat.le_of_dvd ( by decide ) h_cases.2; interval_cases Nat.card H <;> simp +decide at h_cases ⊢;
  obtain h|h|h := h_cases <;> simp_all +decide only;
  · have := Perm_Fin5_no_index_four H ?_;
    · contradiction;
    · have := Subgroup.index_mul_card H; simp_all +decide ;
      exact mul_right_cancel₀ ( by decide ) this;
  · have h_index : H.index = 2 := by
      have := Subgroup.index_mul_card H; simp_all +decide ;
      exact mul_right_cancel₀ ( by decide ) this;
    exact False.elim <| hnotalt <| Perm_Fin5_index_two_eq_alt H h_index ▸ le_rfl;
  · exact Subgroup.eq_top_of_card_eq _ ( by simpa [ Fintype.card_perm ] using h )