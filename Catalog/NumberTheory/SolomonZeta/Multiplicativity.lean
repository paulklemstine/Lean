/-
# Euler factorization of the refined Solomon zeta coefficients

The Solomon zeta function of a lattice factors into local Euler factors.  On the level of the
*refined* (Bushnell–Reiner style) coefficients — which record the isomorphism type `X` of the
quotient rather than just its cardinality — this factorization takes the form of a
multiplicativity statement:

  if the finite modules `X₁` and `X₂` are annihilated by coprime integers `a` and `b`, then
  the Möbius weight of `X₁ × X₂` is the product of the Möbius weights of `X₁` and `X₂`,
  and consequently the refined zeta coefficients multiply.

The proof is structural and proceeds in three steps:

1. `SolomonZeta.mu_orderIso` — the Möbius function of a locally finite poset is invariant under
   order isomorphisms (proved by strong induction on the size of the interval);
2. `SolomonZeta.submodule_prod_split` — under coprimality every submodule of `X₁ × X₂` is a
   product of submodules, giving an order isomorphism of submodule lattices
   `SolomonZeta.coprimeSubmoduleOrderIso`;
3. Mathlib's `IncidenceAlgebra.mu_prod_mu` then evaluates the Möbius function of the product
   poset, and the Hom-counts factor because `Hom(M, Y₁ × Y₂) = Hom(M, Y₁) × Hom(M, Y₂)`.
-/
import Catalog.Shared.SolomonZeta.Core

namespace SolomonZeta

open Finset IncidenceAlgebra

noncomputable instance instDecLESubmodule {R X : Type*} [Ring R] [AddCommGroup X] [Module R X] :
    DecidableLE (Submodule R X) := Classical.decRel _

/-! ### Möbius functions are invariant under order isomorphisms -/

/-- The Möbius function of a locally finite poset is an invariant of the isomorphism type of the
poset: order isomorphic intervals have equal Möbius values. -/
theorem mu_orderIso {𝕜 : Type*} [AddCommGroup 𝕜] [One 𝕜] {α β : Type*}
    [PartialOrder α] [LocallyFiniteOrder α] [DecidableEq α]
    [PartialOrder β] [LocallyFiniteOrder β] [DecidableEq β] (e : α ≃o β) (a b : α) :
    mu 𝕜 (e a) (e b) = mu 𝕜 a b := by
  have himg : ∀ a b : α, (Finset.Ico a b).image e = Finset.Ico (e a) (e b) := by
    intro a b
    ext y
    simp only [Finset.mem_image, Finset.mem_Ico]
    constructor
    · rintro ⟨x, hx, rfl⟩
      exact ⟨e.le_iff_le.2 hx.1, e.lt_iff_lt.2 hx.2⟩
    · rintro ⟨h1, h2⟩
      refine ⟨e.symm y, ⟨?_, ?_⟩, by simp⟩
      · have h1' : e a ≤ e (e.symm y) := by simpa using h1
        exact e.le_iff_le.1 h1'
      · have h2' : e (e.symm y) < e b := by simpa using h2
        exact e.lt_iff_lt.1 h2'
  have key : ∀ n : ℕ, ∀ a b : α, (Finset.Ico a b).card = n → mu 𝕜 (e a) (e b) = mu 𝕜 a b := by
    intro n
    induction n using Nat.strong_induction_on with
    | _ n ih =>
      intro a b hn
      by_cases hab : a = b
      · subst hab; simp
      · rw [mu_apply, mu_apply, if_neg hab, if_neg (fun h => hab (e.injective h))]
        congr 1
        rw [← himg a b, Finset.sum_image (fun x _ y _ h => e.injective h)]
        refine Finset.sum_congr rfl fun x hx => ?_
        rw [Finset.mem_Ico] at hx
        have hsub : Finset.Ico a x ⊆ Finset.Ico a b := by
          intro z hz
          rw [Finset.mem_Ico] at hz ⊢
          exact ⟨hz.1, lt_of_lt_of_le hz.2 (le_of_lt hx.2)⟩
        have hlt : (Finset.Ico a x).card < (Finset.Ico a b).card :=
          Finset.card_lt_card ⟨hsub, fun hcon => by
            have hmem : x ∈ Finset.Ico a x := hcon (Finset.mem_Ico.2 hx)
            simp at hmem⟩
        exact ih _ (hn ▸ hlt) a x rfl
  exact key _ a b rfl

/-! ### Coprime splitting of submodule lattices -/

variable {R M X₁ X₂ : Type*} [Ring R] [AddCommGroup M] [Module R M]
  [AddCommGroup X₁] [Module R X₁] [AddCommGroup X₂] [Module R X₂]

/-- If `X₁` and `X₂` are annihilated by coprime integers, every submodule of `X₁ × X₂` is a
product of submodules. -/
theorem submodule_prod_split (a b : ℕ) (hab : Nat.Coprime a b)
    (h1 : ∀ x : X₁, (a : ℤ) • x = 0) (h2 : ∀ y : X₂, (b : ℤ) • y = 0)
    (Y : Submodule R (X₁ × X₂)) :
    Y = (Y.map (LinearMap.fst R X₁ X₂)).prod (Y.map (LinearMap.snd R X₁ X₂)) := by
  obtain ⟨u, v, huv⟩ : ∃ u v : ℤ, u * a + v * b = 1 := by
    have hco : IsCoprime (a : ℤ) (b : ℤ) := Int.isCoprime_iff_gcd_eq_one.2 (by simpa using hab)
    obtain ⟨u, v, h⟩ := hco
    exact ⟨u, v, h⟩
  apply le_antisymm
  · intro z hz
    exact ⟨⟨z, hz, rfl⟩, ⟨z, hz, rfl⟩⟩
  · rintro ⟨x, y⟩ ⟨⟨z, hz, hx⟩, ⟨w, hw, hy⟩⟩
    simp only [LinearMap.fst_apply, LinearMap.snd_apply] at hx hy
    have hxz : ((x : X₁), (0 : X₂)) ∈ Y := by
      have hmem : (v * b : ℤ) • z ∈ Y := Submodule.smul_of_tower_mem Y _ hz
      have hz2 : (v * b : ℤ) • z = (x, 0) := by
        rw [← hx]
        ext
        · show (v * b : ℤ) • z.1 = z.1
          have hzero : ((u * a) : ℤ) • z.1 = 0 := by rw [mul_smul, h1 z.1, smul_zero]
          have h3 : ((u * a + v * b) : ℤ) • z.1 = z.1 := by rw [huv, one_smul]
          rw [add_smul, hzero, zero_add] at h3
          exact h3
        · show (v * b : ℤ) • z.2 = 0
          rw [mul_smul, h2 z.2, smul_zero]
      rwa [hz2] at hmem
    have hyw : ((0 : X₁), (y : X₂)) ∈ Y := by
      have hmem : (u * a : ℤ) • w ∈ Y := Submodule.smul_of_tower_mem Y _ hw
      have hw2 : (u * a : ℤ) • w = (0, y) := by
        rw [← hy]
        ext
        · show (u * a : ℤ) • w.1 = 0
          rw [mul_smul, h1 w.1, smul_zero]
        · show (u * a : ℤ) • w.2 = w.2
          have hzero : ((v * b) : ℤ) • w.2 = 0 := by rw [mul_smul, h2 w.2, smul_zero]
          have h3 : ((u * a + v * b) : ℤ) • w.2 = w.2 := by rw [huv, one_smul]
          rw [add_smul, hzero, add_zero] at h3
          exact h3
      rwa [hw2] at hmem
    simpa using Y.add_mem hxz hyw

theorem map_fst_prod (Y₁ : Submodule R X₁) (Y₂ : Submodule R X₂) :
    (Y₁.prod Y₂).map (LinearMap.fst R X₁ X₂) = Y₁ := by
  ext x
  simp only [Submodule.mem_map, LinearMap.fst_apply, Submodule.mem_prod]
  exact ⟨by rintro ⟨z, ⟨hz1, -⟩, rfl⟩; exact hz1,
    fun hx => ⟨(x, 0), ⟨hx, Y₂.zero_mem⟩, rfl⟩⟩

theorem map_snd_prod (Y₁ : Submodule R X₁) (Y₂ : Submodule R X₂) :
    (Y₁.prod Y₂).map (LinearMap.snd R X₁ X₂) = Y₂ := by
  ext y
  simp only [Submodule.mem_map, LinearMap.snd_apply, Submodule.mem_prod]
  exact ⟨by rintro ⟨z, ⟨-, hz2⟩, rfl⟩; exact hz2,
    fun hy => ⟨(0, y), ⟨Y₁.zero_mem, hy⟩, rfl⟩⟩

/-- **The submodule lattice of a coprime product splits.** -/
def coprimeSubmoduleOrderIso (a b : ℕ) (hab : Nat.Coprime a b)
    (h1 : ∀ x : X₁, (a : ℤ) • x = 0) (h2 : ∀ y : X₂, (b : ℤ) • y = 0) :
    Submodule R (X₁ × X₂) ≃o Submodule R X₁ × Submodule R X₂ where
  toFun := fun Y => (Y.map (LinearMap.fst R X₁ X₂), Y.map (LinearMap.snd R X₁ X₂))
  invFun := fun p => p.1.prod p.2
  left_inv := fun Y => (submodule_prod_split a b hab h1 h2 Y).symm
  right_inv := fun p => by
    ext1
    · exact map_fst_prod p.1 p.2
    · exact map_snd_prod p.1 p.2
  map_rel_iff' := by
    intro Y Z
    constructor
    · rintro ⟨hle1, hle2⟩
      rw [submodule_prod_split a b hab h1 h2 Y, submodule_prod_split a b hab h1 h2 Z]
      exact Submodule.prod_mono hle1 hle2
    · intro hle
      exact ⟨Submodule.map_mono hle, Submodule.map_mono hle⟩

/-! ### Multiplicativity of the Möbius weight -/

/-- Splitting a submodule of a product also splits the Hom-counts. -/
theorem card_hom_prod_submodule (Y₁ : Submodule R X₁) (Y₂ : Submodule R X₂) :
    Nat.card (M →ₗ[R] (Y₁.prod Y₂)) = Nat.card (M →ₗ[R] Y₁) * Nat.card (M →ₗ[R] Y₂) := by
  have esub : ↥(Y₁.prod Y₂) ≃ₗ[R] (↥Y₁ × ↥Y₂) :=
    { toFun := fun z => (⟨z.1.1, z.2.1⟩, ⟨z.1.2, z.2.2⟩)
      map_add' := fun _ _ => rfl
      map_smul' := fun _ _ => rfl
      invFun := fun p => ⟨(p.1.1, p.2.1), ⟨p.1.2, p.2.2⟩⟩
      left_inv := fun z => by ext <;> rfl
      right_inv := fun p => by ext <;> rfl }
  rw [← Nat.card_prod]
  refine Nat.card_congr (Equiv.trans ?_ (LinearMap.prodEquiv (R := R) (S := ℕ)
      (M := M) (M₂ := ↥Y₁) (M₃ := ↥Y₂)).toEquiv.symm)
  exact ⟨fun f => esub.toLinearMap ∘ₗ f, fun g => esub.symm.toLinearMap ∘ₗ g,
    fun f => LinearMap.ext fun m => by simp, fun g => LinearMap.ext fun m => by simp⟩

theorem mobiusWeight_eq_sum_univ [Finite X₁] :
    mobiusWeight R M X₁
      = ∑ Y : Submodule R X₁, mu ℤ Y ⊤ * (Nat.card (M →ₗ[R] Y) : ℤ) := by
  rw [mobiusWeight]
  congr 1
  ext Y
  simp

/-- **Euler factorization of the Möbius weight.**  If the finite modules `X₁` and `X₂` are
annihilated by coprime integers then their Möbius weights multiply. -/
theorem mobiusWeight_prod_of_coprime [Finite X₁] [Finite X₂] (a b : ℕ) (hab : Nat.Coprime a b)
    (h1 : ∀ x : X₁, (a : ℤ) • x = 0) (h2 : ∀ y : X₂, (b : ℤ) • y = 0) :
    mobiusWeight R M (X₁ × X₂) = mobiusWeight R M X₁ * mobiusWeight R M X₂ := by
  classical
  set e := coprimeSubmoduleOrderIso (R := R) a b hab h1 h2 with he
  have htop : e ⊤ = (⊤, ⊤) := by
    have h1' : (⊤ : Submodule R (X₁ × X₂)).map (LinearMap.fst R X₁ X₂) = ⊤ := by
      rw [Submodule.map_top, LinearMap.range_eq_top]
      exact Prod.fst_surjective
    have h2' : (⊤ : Submodule R (X₁ × X₂)).map (LinearMap.snd R X₁ X₂) = ⊤ := by
      rw [Submodule.map_top, LinearMap.range_eq_top]
      exact Prod.snd_surjective
    exact Prod.ext h1' h2'
  rw [mobiusWeight_eq_sum_univ, mobiusWeight_eq_sum_univ, mobiusWeight_eq_sum_univ]
  rw [← Equiv.sum_comp e.symm.toEquiv
    (fun Y : Submodule R (X₁ × X₂) => mu ℤ Y ⊤ * (Nat.card (M →ₗ[R] Y) : ℤ))]
  rw [Fintype.sum_prod_type]
  rw [Finset.sum_mul_sum]
  refine Finset.sum_congr rfl fun Y₁ _ => Finset.sum_congr rfl fun Y₂ _ => ?_
  have hsymm : e.symm.toEquiv (Y₁, Y₂) = Y₁.prod Y₂ := rfl
  have hmu : mu ℤ (e.symm.toEquiv (Y₁, Y₂)) ⊤ = mu ℤ Y₁ ⊤ * mu ℤ Y₂ ⊤ := by
    show mu ℤ (e.symm (Y₁, Y₂)) ⊤ = mu ℤ Y₁ ⊤ * mu ℤ Y₂ ⊤
    have := mu_orderIso (𝕜 := ℤ) e (e.symm (Y₁, Y₂)) ⊤
    rw [e.apply_symm_apply, htop] at this
    rw [← this, ← IncidenceAlgebra.mu_prod_mu (𝕜 := ℤ)
      (α := Submodule R X₁) (β := Submodule R X₂)]
    rfl
  rw [hmu, hsymm, card_hom_prod_submodule]
  push_cast
  ring

/-- **Multiplicativity of the refined Solomon zeta coefficients.**  For coprime quotient types the
`Aut`-weighted counts of sublattices multiply: this is the Euler factorization of the refined
zeta function at the level of individual coefficients. -/
theorem quotIsoCount_prod_of_coprime [Finite X₁] [Finite X₂] [Module.Finite R M]
    (a b : ℕ) (hab : Nat.Coprime a b)
    (h1 : ∀ x : X₁, (a : ℤ) • x = 0) (h2 : ∀ y : X₂, (b : ℤ) • y = 0) :
    (autCard R (X₁ × X₂) : ℤ) * (quotIsoCount R M (X₁ × X₂) : ℤ)
      = ((autCard R X₁ : ℤ) * (quotIsoCount R M X₁ : ℤ))
        * ((autCard R X₂ : ℤ) * (quotIsoCount R M X₂ : ℤ)) := by
  rw [autCard_mul_quotIsoCount_eq_mobiusWeight, autCard_mul_quotIsoCount_eq_mobiusWeight,
    autCard_mul_quotIsoCount_eq_mobiusWeight, mobiusWeight_prod_of_coprime a b hab h1 h2]

end SolomonZeta