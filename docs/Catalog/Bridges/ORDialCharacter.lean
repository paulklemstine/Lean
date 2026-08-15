import Mathlib
import Bridges.ORDialCap
import Bridges.ORDialMaximum
import Bridges.ORDialClassification

/-!
# The OR-dial maximisers in quadratic-character form

`Bridges.ORDialClassification` proves that the maximisers of the semiprime OR dial are
exactly the indicators of cosets of index-two subgroups.  Index-two subgroups of a group
`G` are the same thing as nontrivial homomorphisms `G → {±1} ⊆ ℝ`, so the classification
can be restated in the language in which the phenomenon was discovered: the extremal
profiles are exactly the *quadratic-character kernel profiles* `(1 ± χ)/2`.

Main results:

* `quadCharHom`: the `±1`-valued character attached to an index-two subgroup.
* `charKernel_index_eq_two`: a nontrivial `±1`-valued character has an index-two kernel.
* `max_iff_quadratic_character`: **a class-rate profile attains the cap `orCap = g(2)` iff
  it is of the form `(1 + ε χ)/2` for a nontrivial quadratic character `χ` and a sign
  `ε = ±1`** — the character event and its complement, and nothing else.
-/

open Real Finset

namespace ORDial

variable {G : Type*} [Fintype G] [CommGroup G]

/-! ## Quadratic characters and index-two subgroups -/

open Classical in
/-- The `±1`-valued character cut out by a subgroup. -/
noncomputable def quadChar (K : Subgroup G) : G → ℝ := fun a => if a ∈ K then 1 else -1

omit [Fintype G] in
lemma quadChar_eq_one_iff {K : Subgroup G} {a : G} : quadChar K a = 1 ↔ a ∈ K := by
  classical
  unfold quadChar
  by_cases h : a ∈ K <;> simp [h]
  norm_num

omit [Fintype G] in
@[simp] lemma quadChar_one (K : Subgroup G) : quadChar K 1 = 1 := by
  classical
  unfold quadChar
  simp

omit [Fintype G] in
lemma quadChar_values (K : Subgroup G) (a : G) : quadChar K a = 1 ∨ quadChar K a = -1 := by
  classical
  unfold quadChar
  by_cases h : a ∈ K <;> simp [h]

omit [Fintype G] in
/-- For an index-two subgroup the `±1`-valued indicator is a group homomorphism: this is
the quadratic character of the mission statement. -/
noncomputable def quadCharHom (K : Subgroup G) (h : K.index = 2) : G →* ℝ where
  toFun := quadChar K
  map_one' := by classical simp [quadChar]
  map_mul' := by
    classical
    intro p q
    unfold quadChar
    by_cases hp : p ∈ K <;> by_cases hq : q ∈ K
    · simp [hp, hq, K.mul_mem hp hq]
    · have hpq : p * q ∉ K := (xor_determined_by_product K h p q).mp (Or.inl ⟨hp, hq⟩)
      simp [hp, hq, hpq]
    · have hpq : p * q ∉ K := (xor_determined_by_product K h p q).mp (Or.inr ⟨hq, hp⟩)
      simp [hp, hq, hpq]
    · have hpq : p * q ∈ K := by
        by_contra hc
        rcases (xor_determined_by_product K h p q).mpr hc with ⟨h1, _⟩ | ⟨h1, _⟩
        · exact hp h1
        · exact hq h1
      simp [hp, hq, hpq]

omit [Fintype G] in
@[simp] lemma quadCharHom_apply (K : Subgroup G) (h : K.index = 2) (a : G) :
    quadCharHom K h a = quadChar K a := rfl

omit [Fintype G] in
/-- An index-two subgroup has an element outside it, so its character is nontrivial. -/
lemma exists_quadChar_eq_neg_one (K : Subgroup G) (h : K.index = 2) :
    ∃ a : G, quadChar K a = -1 := by
  classical
  obtain ⟨a, ha⟩ := Subgroup.index_eq_two_iff.mp h
  have h1 := ha 1
  have hane : a ∉ K := by
    rw [one_mul] at h1
    rcases h1 with ⟨_, h2⟩ | ⟨_, h2⟩
    · exact absurd K.one_mem h2
    · exact h2
  exact ⟨a, by unfold quadChar; simp [hane]⟩

omit [Fintype G] in
/-- The kernel `{χ = 1}` of a `±1`-valued character, as a subgroup. -/
def charKernel (chi : G →* ℝ) : Subgroup G where
  carrier := {a : G | chi a = 1}
  mul_mem' := by
    intro a b ha hb
    simp only [Set.mem_setOf_eq] at ha hb ⊢
    rw [map_mul, ha, hb, one_mul]
  one_mem' := by simp [Set.mem_setOf_eq]
  inv_mem' := by
    intro a ha
    simp only [Set.mem_setOf_eq] at ha ⊢
    have hmul := chi.map_mul a a⁻¹
    rw [mul_inv_cancel, chi.map_one, ha, one_mul] at hmul
    exact hmul.symm

omit [Fintype G] in
lemma mem_charKernel_iff {chi : G →* ℝ} {a : G} : a ∈ charKernel chi ↔ chi a = 1 := Iff.rfl

omit [Fintype G] in
/-- A nontrivial `±1`-valued character has kernel of index two. -/
lemma charKernel_index_eq_two (chi : G →* ℝ) (hval : ∀ a, chi a = 1 ∨ chi a = -1)
    (hnt : ∃ a, chi a = -1) : (charKernel chi).index = 2 := by
  obtain ⟨x, hx⟩ := hnt
  refine Subgroup.index_eq_two_iff.mpr ⟨x, fun b => ?_⟩
  rcases hval b with hb | hb
  · right
    refine ⟨mem_charKernel_iff.mpr hb, ?_⟩
    intro hmem
    have hbx := mem_charKernel_iff.mp hmem
    rw [map_mul, hb, hx, one_mul] at hbx
    norm_num at hbx
  · left
    refine ⟨mem_charKernel_iff.mpr ?_, ?_⟩
    · rw [map_mul, hb, hx]; norm_num
    · intro hmem
      have hb1 := mem_charKernel_iff.mp hmem
      rw [hb] at hb1
      norm_num at hb1

/-! ## The character form of the classification -/

variable {s : G → ℝ}

omit [Fintype G] in
/-- A kernel-coset indicator written through its quadratic character. -/
lemma subgroupProfile_eq_char (K : Subgroup G) (h : K.index = 2) (x a : G) :
    subgroupProfile K (x⁻¹ * a) = (1 + quadChar K x * quadChar K a) / 2 := by
  classical
  have hhom := quadCharHom K h
  have hmul : quadChar K (x⁻¹ * a) = quadChar K x⁻¹ * quadChar K a := by
    simpa using (quadCharHom K h).map_mul x⁻¹ a
  have hinv : quadChar K x⁻¹ = quadChar K x := by
    have h1 : quadChar K x * quadChar K x⁻¹ = 1 := by
      have hmm := (quadCharHom K h).map_mul x x⁻¹
      simpa using hmm.symm
    rcases quadChar_values K x with hx | hx <;> rw [hx] at h1 ⊢ <;> linarith
  have hprof : ∀ b : G, subgroupProfile K b = (1 + quadChar K b) / 2 := by
    intro b
    unfold subgroupProfile quadChar
    by_cases hb : b ∈ K <;> simp [hb]
  rw [hprof, hmul, hinv]

/-- **The maximisers of the semiprime OR dial are exactly the quadratic-character
profiles.**  A class-rate profile `s` attains the global cap `orCap = g(2)` if and only if
`s = (1 + ε χ)/2` for some nontrivial `±1`-valued character `χ` of the class group and
some sign `ε = ±1` (the character event and its complement). -/
theorem max_iff_quadratic_character (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1) :
    orInfo s = orCap
      ↔ ∃ (chi : G →* ℝ) (eps : ℝ), (∀ a, chi a = 1 ∨ chi a = -1) ∧ (∃ a, chi a = -1)
          ∧ (eps = 1 ∨ eps = -1) ∧ ∀ a, s a = (1 + eps * chi a) / 2 := by
  constructor
  · intro heq
    obtain ⟨K, x, hK, hs⟩ := (max_iff_coset_indicator hs0 hs1).mp heq
    refine ⟨quadCharHom K hK, quadChar K x, fun a => quadChar_values K a,
      exists_quadChar_eq_neg_one K hK, quadChar_values K x, fun a => ?_⟩
    rw [hs]
    simpa using subgroupProfile_eq_char K hK x a
  · rintro ⟨chi, eps, hval, hnt, heps, hs⟩
    have hK : (charKernel chi).index = 2 := charKernel_index_eq_two chi hval hnt
    obtain ⟨y, hy⟩ := hnt
    -- choose a coset representative realising the sign `eps`
    obtain ⟨x, hx⟩ : ∃ x : G, chi x = eps := by
      rcases heps with h | h
      · exact ⟨1, by rw [chi.map_one, h]⟩
      · exact ⟨y, by rw [hy, h]⟩
    have hchar : ∀ a : G, quadChar (charKernel chi) a = chi a := by
      intro a
      classical
      unfold quadChar
      rcases hval a with h | h
      · rw [if_pos (mem_charKernel_iff.mpr h), h]
      · have hnm : a ∉ charKernel chi := by
          intro hmem
          rw [mem_charKernel_iff.mp hmem] at h
          norm_num at h
        rw [if_neg hnm, h]
    refine (max_iff_coset_indicator hs0 hs1).mpr ⟨charKernel chi, x, hK, ?_⟩
    funext a
    rw [hs a, subgroupProfile_eq_char (charKernel chi) hK x a, hchar, hchar, hx]

end ORDial