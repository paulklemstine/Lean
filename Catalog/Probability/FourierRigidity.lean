/-
# Rigidity: the converse of Poisson summation on a finite abelian group

`Catalog.Shared.FourierSubgroupDuality` proves the *"if"* direction of finite Poisson summation:
for a subgroup `H ≤ G` and every `f : G → ℂ`,
`|G| * ∑_{x ∈ H} f x = |H| * ∑_{ψ ∈ H^⊥} f̂ ψ`.

This file proves the **converse**, i.e. that the pair (subgroup, annihilator) is the *only*
pair of finite sets for which such an identity can hold. Concretely, if `S ⊆ G` is a nonempty
finite set and `T` is a finite set of characters such that

`|G| * ∑_{x ∈ S} f x = |S| * ∑_{ψ ∈ T} f̂ ψ`  for **all** `f : G → ℂ`,

then `S` is automatically a subgroup of `G` and `T` is exactly its annihilator.

Main results:

* `FourierFA.eq_one_of_sum_eq_card` : an equality case of the triangle inequality — unit-modulus
  complex numbers whose sum equals the cardinality are all equal to `1`.
* `FourierFA.preAnnih` : the annihilator *in `G`* of a set of characters, as an `AddSubgroup`.
* `FourierFA.poisson_converse` : the rigidity statement described above.
* `FourierFA.poisson_iff_subgroup_annihilator` : the resulting biconditional characterisation of
  the pairs `(S, T)` supporting a Poisson summation formula.
* `FourierFA.poisson_card_mul` : any Poisson pair satisfies `|S| * |T| = |G|`.
-/

import Mathlib
import Shared.FourierFiniteAbelian
import Shared.FourierSubgroupDuality

open Finset ComplexConjugate

namespace FourierFA

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-! ## An equality case of the triangle inequality -/

/-- If finitely many complex numbers of modulus `1` sum to the cardinality of the index set,
then every one of them equals `1`. This is the equality case of the triangle inequality in the
form used throughout this file. -/
theorem eq_one_of_sum_eq_card {ι : Type*} {s : Finset ι} {z : ι → ℂ}
    (hz : ∀ i ∈ s, ‖z i‖ = 1) (hsum : ∑ i ∈ s, z i = (s.card : ℂ)) :
    ∀ i ∈ s, z i = 1 := by
  have hre : ∑ i ∈ s, (z i).re = ∑ _i ∈ s, (1 : ℝ) := by
    have : (∑ i ∈ s, z i).re = ((s.card : ℂ)).re := by rw [hsum]
    simpa [Complex.re_sum] using this
  have hle : ∀ i ∈ s, (z i).re ≤ 1 := by
    intro i hi
    calc (z i).re ≤ ‖z i‖ := Complex.re_le_norm _
      _ = 1 := hz i hi
  have hall := (Finset.sum_eq_sum_iff_of_le hle).1 hre
  intro i hi
  have hre1 : (z i).re = 1 := hall i hi
  have hnorm : ‖z i‖ = 1 := hz i hi
  have hsq : (z i).re ^ 2 + (z i).im ^ 2 = 1 := by
    have h3 : Complex.normSq (z i) = 1 := by
      rw [Complex.normSq_eq_norm_sq, hnorm]; norm_num
    simpa [Complex.normSq_apply, pow_two] using h3
  have him : (z i).im = 0 := by nlinarith [sq_nonneg (z i).im]
  apply Complex.ext <;> simp [hre1, him]

/-! ## The annihilator of a set of characters -/

/-- The annihilator **in `G`** of a finite set `T` of characters: the subgroup of elements on
which every character of `T` is trivial. (Dually to `FourierFA.annih`, which is the annihilator
of a subgroup of `G` inside the dual group.) -/
def preAnnih (T : Finset (AddChar G ℂ)) : AddSubgroup G where
  carrier := {y : G | ∀ ψ ∈ T, ψ y = 1}
  zero_mem' := by intro ψ _; simp
  add_mem' := by
    intro a b ha hb ψ hψ
    rw [ψ.map_add_eq_mul, ha ψ hψ, hb ψ hψ, one_mul]
  neg_mem' := by
    intro a ha ψ hψ
    rw [AddChar.map_neg_eq_inv, ha ψ hψ, inv_one]

omit [Fintype G] [DecidableEq G] in
@[simp] lemma mem_preAnnih {T : Finset (AddChar G ℂ)} {y : G} :
    y ∈ preAnnih T ↔ ∀ ψ ∈ T, ψ y = 1 := Iff.rfl

/-! ## The converse of Poisson summation -/

/-- The Poisson summation identity for a pair `(S, T)` consisting of a finite subset of `G`
and a finite set of characters. -/
def IsPoissonPair (S : Finset G) (T : Finset (AddChar G ℂ)) : Prop :=
  ∀ f : G → ℂ, (Fintype.card G : ℂ) * ∑ x ∈ S, f x = (S.card : ℂ) * ∑ ψ ∈ T, dft f ψ

/-- Testing a Poisson pair against Dirac deltas: the character sum `∑_{ψ ∈ T} ψ y` is
proportional to the indicator of `S`. -/
theorem poisson_delta_test {S : Finset G} {T : Finset (AddChar G ℂ)} (h : IsPoissonPair S T)
    (y : G) :
    (Fintype.card G : ℂ) * (if y ∈ S then 1 else 0) = (S.card : ℂ) * ∑ ψ ∈ T, ψ y := by
  have hd := h (delta y)
  have hL : ∑ x ∈ S, delta y x = (if y ∈ S then 1 else 0) := by
    simp [delta, Finset.sum_ite_eq' S y (fun _ => (1 : ℂ))]
  have hR : ∑ ψ ∈ T, dft (delta y) ψ = ∑ ψ ∈ T, conj (ψ y) :=
    Finset.sum_congr rfl fun ψ _ => dft_delta y ψ
  rw [hL, hR] at hd
  have := congrArg (starRingEnd ℂ) hd
  simpa [map_sum, Complex.conj_ofReal, apply_ite (starRingEnd ℂ)] using this

/-- A Poisson pair contains `0` and satisfies `|S| * |T| = |G|`. -/
theorem poisson_card_mul {S : Finset G} {T : Finset (AddChar G ℂ)} (h : IsPoissonPair S T)
    (hS : S.Nonempty) : (0 : G) ∈ S ∧ S.card * T.card = Fintype.card G := by
  have hN : (Fintype.card G : ℂ) ≠ 0 := by exact_mod_cast (Fintype.card_ne_zero (α := G))
  have hScard : 0 < S.card := Finset.card_pos.2 hS
  have h0 := poisson_delta_test h 0
  have hF0 : ∑ ψ ∈ T, ψ (0 : G) = (T.card : ℂ) := by simp
  rw [hF0] at h0
  by_cases hmem : (0 : G) ∈ S
  · refine ⟨hmem, ?_⟩
    rw [if_pos hmem, mul_one] at h0
    exact_mod_cast h0.symm
  · exfalso
    rw [if_neg hmem, mul_zero] at h0
    have hT : (T.card : ℂ) = 0 := by
      rcases mul_eq_zero.1 h0.symm with h1 | h2
      · exact absurd (by exact_mod_cast h1 : S.card = 0) (by omega)
      · exact h2
    have hTempty : T = ∅ := by
      have : T.card = 0 := by exact_mod_cast hT
      exact Finset.card_eq_zero.1 this
    obtain ⟨y, hy⟩ := hS
    have h2 := poisson_delta_test h y
    rw [if_pos hy, mul_one, hTempty] at h2
    simp only [Finset.sum_empty, mul_zero] at h2
    exact hN h2

/-- **Converse of Poisson summation.** If the Poisson identity holds for a nonempty finite set
`S ⊆ G` and a finite set `T` of characters and *all* test functions, then `S` is a subgroup of
`G` and `T` is precisely its annihilator. -/
theorem poisson_converse {S : Finset G} {T : Finset (AddChar G ℂ)} (h : IsPoissonPair S T)
    (hS : S.Nonempty) :
    ∃ H : AddSubgroup G, (∀ x, x ∈ S ↔ x ∈ H) ∧ (∀ ψ, ψ ∈ T ↔ ∀ x ∈ H, ψ x = 1) := by
  classical
  obtain ⟨h0S, hcards⟩ := poisson_card_mul h hS
  have hScard : 0 < S.card := Finset.card_pos.2 hS
  have hTcard : 0 < T.card := by
    rcases Nat.eq_zero_or_pos T.card with h' | h'
    · exfalso
      rw [h', Nat.mul_zero] at hcards
      exact (Fintype.card_ne_zero (α := G)) hcards.symm
    · exact h'
  have hNC : (Fintype.card G : ℂ) = (S.card : ℂ) * (T.card : ℂ) := by exact_mod_cast hcards.symm
  have hSC : (S.card : ℂ) ≠ 0 := by
    have : S.card ≠ 0 := by omega
    exact_mod_cast this
  -- the key pointwise identity: `∑_{ψ ∈ T} ψ y = |T| * 1_S (y)`
  have hkey : ∀ y : G, (S.card : ℂ) * ∑ ψ ∈ T, ψ y
      = (S.card : ℂ) * (T.card : ℂ) * (if y ∈ S then 1 else 0) := by
    intro y
    rw [← poisson_delta_test h y, hNC]
  refine ⟨preAnnih T, ?_, ?_⟩
  · intro x
    constructor
    · -- if `x ∈ S`, the character sum is `|T|`, forcing every character of `T` to be `1` at `x`
      intro hx
      have hsum : ∑ ψ ∈ T, ψ x = (T.card : ℂ) := by
        have h1 := hkey x
        rw [if_pos hx, mul_one] at h1
        exact mul_left_cancel₀ hSC h1
      exact mem_preAnnih.2 (eq_one_of_sum_eq_card (fun ψ _ => AddChar.norm_apply ψ x) hsum)
    · -- conversely, if all characters of `T` are trivial at `x` the sum is `|T| ≠ 0`
      intro hx
      by_contra hxS
      have hsum : ∑ ψ ∈ T, ψ x = (T.card : ℂ) := by
        rw [Finset.sum_congr rfl fun ψ hψ => mem_preAnnih.1 hx ψ hψ]
        simp
      have := hkey x
      rw [if_neg hxS, mul_zero, hsum] at this
      have hT0 : (T.card : ℂ) = 0 := by
        rcases mul_eq_zero.1 this with h1 | h1
        · exact absurd h1 hSC
        · exact h1
      have : T.card = 0 := by exact_mod_cast hT0
      omega
  · -- `T` is the annihilator of `S`, by a counting argument
    intro ψ
    letI : DecidablePred (· ∈ preAnnih T) := fun _ => Classical.dec _
    have hSsub : subFinset (preAnnih T) = S := by
      ext x
      rw [mem_subFinset]
      constructor
      · intro hx
        by_contra hxS
        have hsum : ∑ χ ∈ T, χ x = (T.card : ℂ) := by
          rw [Finset.sum_congr rfl fun χ hχ => mem_preAnnih.1 hx χ hχ]
          simp
        have := hkey x
        rw [if_neg hxS, mul_zero, hsum] at this
        have hT0 : (T.card : ℂ) = 0 := by
          rcases mul_eq_zero.1 this with h1 | h1
          · exact absurd h1 hSC
          · exact h1
        have : T.card = 0 := by exact_mod_cast hT0
        omega
      · intro hx
        have hsum : ∑ χ ∈ T, χ x = (T.card : ℂ) := by
          have h1 := hkey x
          rw [if_pos hx, mul_one] at h1
          exact mul_left_cancel₀ hSC h1
        exact mem_preAnnih.2 (eq_one_of_sum_eq_card (fun χ _ => AddChar.norm_apply χ x) hsum)
    have hcard := card_subgroup_mul_card_annihilator (H := preAnnih T)
    rw [hSsub] at hcard
    have hTeq : (annih (preAnnih T)).card = T.card := by
      have : S.card * (annih (preAnnih T)).card = S.card * T.card := by
        rw [hcard, hcards]
      exact Nat.eq_of_mul_eq_mul_left hScard this
    have hsubset : T ⊆ annih (preAnnih T) := by
      intro χ hχ
      exact mem_annih.2 fun x hx => mem_preAnnih.1 hx χ hχ
    have hTfull : T = annih (preAnnih T) :=
      Finset.eq_of_subset_of_card_le hsubset (le_of_eq hTeq)
    constructor
    · intro hψ x hx
      exact mem_preAnnih.1 hx ψ hψ
    · intro hψ
      have hmem : ψ ∈ annih (preAnnih T) := mem_annih.2 hψ
      rw [← hTfull] at hmem
      exact hmem

/-- **Poisson summation holds exactly for subgroup/annihilator pairs.** -/
theorem poisson_iff_subgroup_annihilator (S : Finset G) (T : Finset (AddChar G ℂ))
    (hS : S.Nonempty) :
    IsPoissonPair S T ↔
      ∃ H : AddSubgroup G, (∀ x, x ∈ S ↔ x ∈ H) ∧ (∀ ψ, ψ ∈ T ↔ ∀ x ∈ H, ψ x = 1) := by
  classical
  refine ⟨fun h => poisson_converse h hS, ?_⟩
  rintro ⟨H, hSH, hTH⟩
  letI : DecidablePred (· ∈ H) := fun _ => Classical.dec _
  have hSf : S = subFinset H := by
    ext x; rw [mem_subFinset]; exact hSH x
  have hTf : T = annih H := by
    ext ψ; rw [mem_annih]; exact hTH ψ
  intro f
  rw [hSf, hTf]
  exact poisson_summation f

end FourierFA