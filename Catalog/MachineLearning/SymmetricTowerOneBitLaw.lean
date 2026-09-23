/-
# The one-bit law along the whole symmetric tower

Third cycle of the `S₅` / `A₅` thread (`MachineLearning.QuinticTypeChannelS5A5`,
`MachineLearning.QuinticTypeChannelS5A5Cap`).  There the abelianization law was established at
degree five: the splitting type of an `S₅` quintic transmits exactly one bit — the quadratic
character of the discriminant — and nothing more, while the perfect group `A₅` transmits
nothing at all.

Here we show that neither statement is a degree-five accident.  For *every* finite set of
roots the sign is a function of the cycle type, the sign dial is exactly balanced, and the
one-bit law holds verbatim; and from degree five upwards the whole dichotomy for abelian
dials holds, because `Aₙ` is perfect for `n ≥ 5`.

## Results

* `sign_fiber_card_eq` — the two sign classes of `Perm α` are equinumerous with `Aₙ`.
* `symmetric_signEntropy` — `H(sign) = 1` for every `α` with at least two elements.
* `symmetric_one_bit_law` — **the law in every degree**: `I(sign ; cycleType) = 1`.
* `symmetric_hom_trivial_on_even`, `symmetric_hom_factors_sign` — for `5 ≤ #α` every
  homomorphism of `Perm α` into an abelian group is trivial on `Aₙ` and factors through the
  sign, since `Aₙ` is perfect (`commutator_alternatingGroup_eq_top`).
* `symmetric_abelian_dial_dichotomy` — **the sharp law in every degree ≥ 5**: an abelian dial
  of `Sₙ` receives exactly one bit if it is nontrivial and nothing if it is trivial;
  `symmetric_abelian_dial_le_one` is the cap.
* `alternating_tower_seal` — the seal for the perfect groups `Aₙ`, `n ≥ 5`: every abelian
  dial has mutual information exactly `0` with every read-out.
* `quintic_one_bit_law_of_tower` — the degree-five law of the first file, recovered as the
  instance `α = Fin 5`.
-/
import MachineLearning.QuinticTypeChannelS5A5Cap

namespace QuinticS5A5

open Finset Equiv CyclicTypeChannel

/-! ## 1. The balanced sign dial in every degree -/

section Tower

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- The even permutations are exactly the elements of `Aₙ`, counted as a `Finset`. -/
lemma card_even_filter [Nontrivial α] :
    (#{x ∈ (univ : Finset (Perm α)) | Perm.sign x = 1} : ℕ)
      = Fintype.card (alternatingGroup α) := by
  classical
  rw [Fintype.card_subtype]
  congr 1
  exact Finset.filter_congr fun x _ => by
    simp [Perm.mem_alternatingGroup]

/-- Both sign classes have the same size: multiplication by `σ⁻¹` is a bijection from the
class of `σ` onto the even permutations. -/
lemma sign_fiber_card_eq [Nontrivial α] (σ : Perm α) :
    (#{x ∈ (univ : Finset (Perm α)) | Perm.sign x = Perm.sign σ} : ℕ)
      = Fintype.card (alternatingGroup α) := by
  classical
  rw [← card_even_filter (α := α)]
  refine Finset.card_nbij' (fun x => σ⁻¹ * x) (fun x => σ * x) ?_ ?_ ?_ ?_
  · intro x hx
    simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_univ, true_and] at hx ⊢
    rw [map_mul, map_inv, hx]
    simp
  · intro x hx
    simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_univ, true_and] at hx ⊢
    rw [map_mul, hx, mul_one]
  · intro x _
    simp
  · intro x _
    simp

/-- **The sign dial carries exactly one bit, in every degree.** -/
theorem symmetric_signEntropy [Nontrivial α] :
    uEnt (univ : Finset (Perm α)) (fun σ => Perm.sign σ) = 1 := by
  classical
  have hk : 0 < Fintype.card (alternatingGroup α) := Fintype.card_pos
  have hcard : (Fintype.card (Perm α) : ℕ) = 2 * Fintype.card (alternatingGroup α) :=
    (two_mul_card_alternatingGroup (α := α)).symm
  have h := QuinticF20.uEnt_eq_logb_of_uniform_fibers (s := (univ : Finset (Perm α)))
    (g := fun σ => Perm.sign σ) (c := Fintype.card (alternatingGroup α))
    ⟨1, mem_univ _⟩ (fun a _ => sign_fiber_card_eq a)
  rw [h, Finset.card_univ, hcard]
  push_cast
  rw [show (2 : ℝ) * (Fintype.card (alternatingGroup α) : ℝ)
      = 2 * (Fintype.card (alternatingGroup α) : ℝ) from rfl]
  exact logb_double (by exact_mod_cast hk)

/-- The sign of a permutation is a function of its cycle type, in every degree. -/
theorem sign_of_cycleType_eq {σ τ : Perm α} (h : σ.cycleType = τ.cycleType) :
    Perm.sign σ = Perm.sign τ := by
  rw [Perm.sign_of_cycleType, Perm.sign_of_cycleType, h]

/-- **The one-bit law in every degree.**  The cycle type of a permutation transmits exactly
one bit about its sign — the quadratic character of the discriminant of the corresponding
field — no matter how large the type alphabet grows. -/
theorem symmetric_one_bit_law [Nontrivial α] :
    mutInfo (univ : Finset (Perm α)) (fun σ => Perm.sign σ) (fun σ => σ.cycleType) = 1 := by
  rw [mutInfo_eq_uEnt_of_factors (fun x _ y _ h => sign_of_cycleType_eq h),
    symmetric_signEntropy]

end Tower

/-! ## 2. Perfection of `Aₙ` for `n ≥ 5` and the sharp law -/

section HighTower

variable {α : Type*} [Fintype α] [DecidableEq α] {M : Type*} [CommGroup M]

/-- For `5 ≤ #α` the alternating group is perfect, so every homomorphism into an abelian
group is trivial on it. -/
theorem alternating_tower_hom_trivial (hα : 5 ≤ Fintype.card α)
    (ψ : alternatingGroup α →* M) (x : alternatingGroup α) : ψ x = 1 := by
  have hcomm : commutator (alternatingGroup α) = ⊤ := commutator_alternatingGroup_eq_top hα
  have hle : commutator (alternatingGroup α) ≤ ψ.ker := Abelianization.commutator_subset_ker ψ
  have : x ∈ ψ.ker := by
    rw [hcomm] at hle
    exact hle (Subgroup.mem_top x)
  exact this

/-- Every homomorphism of `Sₙ` (`n ≥ 5`) into an abelian group kills the even
permutations. -/
theorem symmetric_hom_trivial_on_even (hα : 5 ≤ Fintype.card α) (φ : Perm α →* M)
    {σ : Perm α} (hσ : Perm.sign σ = 1) : φ σ = 1 :=
  alternating_tower_hom_trivial hα (φ.comp (alternatingGroup α).subtype)
    ⟨σ, Perm.mem_alternatingGroup.2 hσ⟩

/-- Every homomorphism of `Sₙ` (`n ≥ 5`) into an abelian group factors through the sign. -/
theorem symmetric_hom_factors_sign (hα : 5 ≤ Fintype.card α) (φ : Perm α →* M)
    {x y : Perm α} (h : Perm.sign x = Perm.sign y) : φ x = φ y := by
  have hsign : Perm.sign (x * y⁻¹) = 1 := by rw [map_mul, map_inv, h, mul_inv_cancel]
  have h1 := symmetric_hom_trivial_on_even hα φ hsign
  rw [map_mul, map_inv] at h1
  exact mul_inv_eq_one.mp h1

variable [DecidableEq M]

omit [DecidableEq M] in
/-- If a dial of `Sₙ` (`n ≥ 5`) is nontrivial, its fibres are the two cosets of `Aₙ`. -/
theorem symmetric_nontrivial_hom_fiber (hα : 5 ≤ Fintype.card α) (φ : Perm α →* M)
    (hφ : ∃ τ, φ τ ≠ 1) {x y : Perm α} : φ x = φ y ↔ Perm.sign x = Perm.sign y := by
  obtain ⟨τ, hτ⟩ := hφ
  have hτodd : Perm.sign τ = -1 :=
    (Int.units_eq_one_or _).resolve_left fun h => hτ (symmetric_hom_trivial_on_even hα φ h)
  refine ⟨fun h => ?_, fun h => symmetric_hom_factors_sign hα φ h⟩
  by_contra hne
  have hu : Perm.sign (x * y⁻¹) ≠ 1 := by
    rw [map_mul, map_inv]
    exact fun hc => hne (by rwa [mul_inv_eq_one] at hc)
  have hxy : Perm.sign (x * y⁻¹) = -1 := (Int.units_eq_one_or _).resolve_left hu
  have hev : Perm.sign (x * y⁻¹ * τ⁻¹) = 1 := by
    rw [map_mul, hxy, map_inv, hτodd]
    decide
  have h1 : φ (x * y⁻¹ * τ⁻¹) = 1 := symmetric_hom_trivial_on_even hα φ hev
  rw [map_mul, map_mul, map_inv, map_inv, h] at h1
  simp only [mul_inv_cancel, one_mul, inv_eq_one] at h1
  exact hτ h1

/-- **The sharp abelianization law along the tower.**  For `n ≥ 5` every homomorphism of `Sₙ`
into an abelian group receives exactly one bit from the cycle type if it is nontrivial, and
nothing at all if it is trivial. -/
theorem symmetric_abelian_dial_dichotomy (hα : 5 ≤ Fintype.card α) (φ : Perm α →* M) :
    mutInfo (univ : Finset (Perm α)) (fun σ => φ σ) (fun σ => σ.cycleType)
      = if (∃ τ, φ τ ≠ 1) then 1 else 0 := by
  classical
  have hnt : Nontrivial α := Fintype.one_lt_card_iff_nontrivial.1 (by omega)
  have hmut : mutInfo (univ : Finset (Perm α)) (fun σ => φ σ) (fun σ => σ.cycleType)
      = uEnt (univ : Finset (Perm α)) (fun σ => φ σ) :=
    mutInfo_eq_uEnt_of_factors fun _ _ _ _ h =>
      symmetric_hom_factors_sign hα φ (sign_of_cycleType_eq h)
  rw [hmut]
  by_cases hφ : ∃ τ, φ τ ≠ 1
  · rw [if_pos hφ]
    have hk : 0 < Fintype.card (alternatingGroup α) := Fintype.card_pos
    have hfib : ∀ a ∈ (univ : Finset (Perm α)),
        (#{x ∈ (univ : Finset (Perm α)) | φ x = φ a} : ℕ)
          = Fintype.card (alternatingGroup α) := by
      intro a _
      have hset : ({x ∈ (univ : Finset (Perm α)) | φ x = φ a} : Finset (Perm α))
          = {x ∈ (univ : Finset (Perm α)) | Perm.sign x = Perm.sign a} := by
        ext x
        simp only [mem_filter, mem_univ, true_and]
        exact symmetric_nontrivial_hom_fiber hα φ hφ
      rw [hset, sign_fiber_card_eq]
    have h := QuinticF20.uEnt_eq_logb_of_uniform_fibers (s := (univ : Finset (Perm α)))
      (g := fun σ => φ σ) (c := Fintype.card (alternatingGroup α)) ⟨1, mem_univ _⟩ hfib
    have hcard : (Fintype.card (Perm α) : ℕ) = 2 * Fintype.card (alternatingGroup α) :=
      (two_mul_card_alternatingGroup (α := α)).symm
    rw [h, Finset.card_univ, hcard]
    push_cast
    exact logb_double (by exact_mod_cast hk)
  · rw [if_neg hφ]
    push_neg at hφ
    exact uEnt_eq_zero_of_const fun x _ y _ => by rw [hφ x, hφ y]

/-- The cap along the tower: an abelian dial of `Sₙ` never receives more than one bit. -/
theorem symmetric_abelian_dial_le_one (hα : 5 ≤ Fintype.card α) (φ : Perm α →* M) :
    mutInfo (univ : Finset (Perm α)) (fun σ => φ σ) (fun σ => σ.cycleType) ≤ 1 := by
  rw [symmetric_abelian_dial_dichotomy hα]
  split <;> norm_num

/-- **The seal along the tower.**  For `n ≥ 5` the perfect group `Aₙ` transmits nothing to any
abelian dial, for any read-out whatsoever. -/
theorem alternating_tower_seal (hα : 5 ≤ Fintype.card α) {β : Type*} [DecidableEq β]
    (φ : alternatingGroup α →* M) (T : alternatingGroup α → β) :
    mutInfo (univ : Finset (alternatingGroup α)) (fun g => φ g) T = 0 :=
  mutInfo_eq_zero_of_const T fun x _ y _ => by
    rw [alternating_tower_hom_trivial hα φ x, alternating_tower_hom_trivial hα φ y]

end HighTower

/-! ## 3. Consistency with the degree-five endpoint -/

/-- The degree-five one-bit law of `MachineLearning.QuinticTypeChannelS5A5` is the instance
`α = Fin 5` of the tower law. -/
theorem quintic_one_bit_law_of_tower : mutInfo S5box signDial qType = 1 := by
  have h := symmetric_one_bit_law (α := Fin 5)
  rw [S5box]
  exact h

end QuinticS5A5