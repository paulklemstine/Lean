/-
# The quantum double produces braided structures

The Drinfeld (quantum) double `D(H)` of a Hopf algebra is quasitriangular, and its module
category is braided.  This file formalises two complementary, completely explicit instances of
that principle, and the two structural mechanisms behind them.

## Contents

* **Racks give braidings.**  `QuantumDouble.IsSelfDistrib` records self-distributivity of a
  binary operation.  `QuantumDouble.rack_yang_baxter` proves that the associated map
  `c(x,y) = (x ▷ y, x)` satisfies the set-theoretic Yang–Baxter (braid) equation on `X³`.
  Self-distributivity is *exactly* the braid relation — no other hypothesis is used.

* **The double of a group.**  For any group `G`, conjugation `x ▷ y = x y x⁻¹` is
  self-distributive (`conj_selfDistrib`); this is the canonical Yetter–Drinfeld object of the
  quantum double `D(k[G])`.  We package the braiding as permutations
  (`QuantumDouble.conjBraid₁`, `conjBraid₂`), prove the braid relation
  (`conj_braid_relation`) and obtain a genuine action of the 3-strand braid group
  `QuantumDouble.doubleBraidRep : B₃ →* Equiv.Perm (G × G × G)`.  This is the statement that the
  quantum double of a finite group is a braided category, in its most concrete form.

* **Abelian anyons and modularity.**  For a finite abelian group `A` a bicharacter `χ` gives the
  diagonal braiding `c(x ⊗ y) = χ(x,y) (y ⊗ x)` of the abelian-anyon (quantum double) category.
  We prove the Yang–Baxter equation for it (`anyon_yang_baxter`), the fusion/hexagon
  compatibility (`anyon_hexagon_left`, `anyon_hexagon_right`), and — the substantive statement —
  **modularity**: nondegeneracy of `χ` implies the `S`-matrix `S_{xy} = χ(x,y)` is invertible,
  `S ⬝ S' = |A| • 1` (`smatrix_orthogonality`, `smatrix_mul_eq`).  This is the exact analogue,
  for `D(A)`, of the nondegeneracy of the braiding of `U_q(sl₂)` at a root of unity.
-/

import Mathlib
import Physics.QuantumSL2Braiding

namespace QuantumDouble

open QuantumBraiding

/-! ## 1. Self-distributive operations and the set-theoretic Yang–Baxter equation -/

section Rack

variable {X : Type*}

/-- Self-distributivity `x ▷ (y ▷ z) = (x ▷ y) ▷ (x ▷ z)`, the rack axiom. -/
def IsSelfDistrib (act : X → X → X) : Prop :=
  ∀ x y z, act x (act y z) = act (act x y) (act x z)

/-- The braiding on the first two factors of `X³`. -/
def rackBraid₁ (act : X → X → X) : X × X × X → X × X × X :=
  fun p => (act p.1 p.2.1, p.1, p.2.2)

/-- The braiding on the last two factors of `X³`. -/
def rackBraid₂ (act : X → X → X) : X × X × X → X × X × X :=
  fun p => (p.1, act p.2.1 p.2.2, p.2.1)

/-- **Self-distributivity is the Yang–Baxter equation.** -/
theorem rack_yang_baxter {act : X → X → X} (h : IsSelfDistrib act) :
    rackBraid₁ act ∘ rackBraid₂ act ∘ rackBraid₁ act
      = rackBraid₂ act ∘ rackBraid₁ act ∘ rackBraid₂ act := by
  funext p
  obtain ⟨x, y, z⟩ := p
  simp only [Function.comp_apply, rackBraid₁, rackBraid₂]
  rw [h x y z]

/-- Conversely, if the associated map satisfies the Yang–Baxter equation then the operation is
self-distributive: the two notions are equivalent. -/
theorem selfDistrib_of_yang_baxter {act : X → X → X}
    (h : rackBraid₁ act ∘ rackBraid₂ act ∘ rackBraid₁ act
      = rackBraid₂ act ∘ rackBraid₁ act ∘ rackBraid₂ act) : IsSelfDistrib act := by
  intro x y z
  have H := congrFun h (x, y, z)
  simp only [Function.comp_apply, rackBraid₁, rackBraid₂, Prod.mk.injEq] at H
  exact H.1.symm

end Rack

/-! ## 2. The quantum double of a group: conjugation braiding and the `B₃` action -/

section GroupDouble

variable {G : Type*} [Group G]

/-- Conjugation, the canonical Yetter–Drinfeld operation of the quantum double `D(k[G])`. -/
def conjAct (x y : G) : G := x * y * x⁻¹

theorem conj_selfDistrib : IsSelfDistrib (conjAct (G := G)) := by
  intro x y z
  simp only [conjAct]
  group

/-- The quantum double braiding on the first two tensor factors, as a permutation. -/
def conjBraid₁ : Equiv.Perm (G × G × G) where
  toFun p := (p.1 * p.2.1 * p.1⁻¹, p.1, p.2.2)
  invFun p := (p.2.1, p.2.1⁻¹ * p.1 * p.2.1, p.2.2)
  left_inv := by rintro ⟨x, y, z⟩; simp only [Prod.mk.injEq]; and_intros <;> first | rfl | group
  right_inv := by rintro ⟨x, y, z⟩; simp only [Prod.mk.injEq]; and_intros <;> first | rfl | group

/-- The quantum double braiding on the last two tensor factors, as a permutation. -/
def conjBraid₂ : Equiv.Perm (G × G × G) where
  toFun p := (p.1, p.2.1 * p.2.2 * p.2.1⁻¹, p.2.1)
  invFun p := (p.1, p.2.2, p.2.2⁻¹ * p.2.1 * p.2.2)
  left_inv := by rintro ⟨x, y, z⟩; simp only [Prod.mk.injEq]; and_intros <;> first | rfl | group
  right_inv := by rintro ⟨x, y, z⟩; simp only [Prod.mk.injEq]; and_intros <;> first | rfl | group

/-- **The braid relation for the quantum double braiding of a group.** -/
theorem conj_braid_relation :
    (conjBraid₁ : Equiv.Perm (G × G × G)) * conjBraid₂ * conjBraid₁
      = conjBraid₂ * conjBraid₁ * conjBraid₂ := by
  apply Equiv.ext
  rintro ⟨x, y, z⟩
  simp only [Equiv.Perm.mul_apply, conjBraid₁, conjBraid₂, Equiv.coe_fn_mk, Prod.mk.injEq]
  and_intros <;> first | rfl | group

/-- **The quantum double of a group is braided**: an action of the 3-strand braid group on the
triple tensor product of the canonical Yetter–Drinfeld object. -/
def doubleBraidRep : B3 →* Equiv.Perm (G × G × G) :=
  braidHom conjBraid₁ conjBraid₂ conj_braid_relation

theorem doubleBraidRep_apply_of (x y z : G) :
    doubleBraidRep (PresentedGroup.of 0) (x, y, z) = (x * y * x⁻¹, x, z) := by
  simp [doubleBraidRep, conjBraid₁]

end GroupDouble

/-! ## 3. Abelian anyons: the double of a finite abelian group is modular -/

section Anyons

variable {A : Type*} [AddCommGroup A]

/-- A bicharacter on `A`: the braiding datum of the abelian-anyon (quantum double) category. -/
structure IsBicharacter (χ : A → A → ℂ) : Prop where
  /-- Additivity in the first slot (left hexagon). -/
  left : ∀ x y z, χ (x + y) z = χ x z * χ y z
  /-- Additivity in the second slot (right hexagon). -/
  right : ∀ x y z, χ x (y + z) = χ x y * χ x z
  /-- Normalisation. -/
  zero_right : ∀ x, χ x 0 = 1

variable {χ : A → A → ℂ}

theorem IsBicharacter.zero_left (h : IsBicharacter χ) (y : A) : χ 0 y = 1 := by
  have h0 := h.left 0 0 y
  simp only [add_zero] at h0
  rcases mul_eq_zero.mp (by linear_combination -h0 : χ 0 y * (χ 0 y - 1) = 0) with h1 | h1
  · have hx := h.right 0 y (-y)
    rw [add_neg_cancel, h.zero_right, h1, zero_mul] at hx
    exact absurd hx one_ne_zero
  · linear_combination h1

/-- The diagonal braiding on the first two factors, written on coefficient functions. -/
noncomputable def anyonBraid₁ (χ : A → A → ℂ) (f : A × A × A → ℂ) : A × A × A → ℂ :=
  fun p => χ p.2.1 p.1 * f (p.2.1, p.1, p.2.2)

/-- The diagonal braiding on the last two factors. -/
noncomputable def anyonBraid₂ (χ : A → A → ℂ) (f : A × A × A → ℂ) : A × A × A → ℂ :=
  fun p => χ p.2.2 p.2.1 * f (p.1, p.2.2, p.2.1)

omit [AddCommGroup A] in
/-- **Yang–Baxter equation for the abelian-anyon braiding.** -/
theorem anyon_yang_baxter (χ : A → A → ℂ) (f : A × A × A → ℂ) :
    anyonBraid₁ χ (anyonBraid₂ χ (anyonBraid₁ χ f))
      = anyonBraid₂ χ (anyonBraid₁ χ (anyonBraid₂ χ f)) := by
  funext p
  obtain ⟨x, y, z⟩ := p
  simp only [anyonBraid₁, anyonBraid₂]
  ring

/-- Left hexagon: braiding a fused pair is the composite of the two braidings. -/
theorem anyon_hexagon_left (h : IsBicharacter χ) (x y z : A) :
    χ (x + y) z = χ x z * χ y z := h.left x y z

/-- Right hexagon. -/
theorem anyon_hexagon_right (h : IsBicharacter χ) (x y z : A) :
    χ x (y + z) = χ x y * χ x z := h.right x y z

/-- The character `y ↦ χ x y`. -/
noncomputable def charOf (h : IsBicharacter χ) (x : A) : AddChar A ℂ where
  toFun := χ x
  map_zero_eq_one' := h.zero_right x
  map_add_eq_mul' := h.right x

variable [Fintype A] [DecidableEq A]

/-- **Modularity / `S`-matrix orthogonality.**  If the bicharacter is nondegenerate — i.e. every
nonzero anyon braids nontrivially with some anyon — then the rows of the `S`-matrix are
orthogonal. -/
theorem smatrix_orthogonality (h : IsBicharacter χ)
    (hnd : ∀ x : A, x ≠ 0 → ∃ y, χ x y ≠ 1) (x x' : A) :
    ∑ y, χ x y * χ (-x') y = if x = x' then (Fintype.card A : ℂ) else 0 := by
  classical
  have hsum : ∑ y, χ x y * χ (-x') y = ∑ y, charOf h (x - x') y := by
    refine Finset.sum_congr rfl fun y _ => ?_
    rw [sub_eq_add_neg]
    exact (h.left x (-x') y).symm
  rw [hsum, AddChar.sum_eq_ite]
  by_cases hxx : x = x'
  · subst hxx
    have hz : charOf h (0 : A) = 0 := by ext y; simpa using h.zero_left y
    simp [sub_self, hz]
  · have hne : charOf h (x - x') ≠ 0 := by
      intro hc
      obtain ⟨y, hy⟩ := hnd (x - x') (sub_ne_zero.mpr hxx)
      apply hy
      have := congrFun (congrArg (fun ψ : AddChar A ℂ => (ψ : A → ℂ)) hc) y
      simpa [charOf] using this
    simp [hne, hxx]

/-- The `S`-matrix of the abelian quantum double is invertible: `S ⬝ S' = |A| • 1`.  A braided
category with invertible `S`-matrix is *modular*. -/
theorem smatrix_mul_eq (h : IsBicharacter χ) (hnd : ∀ x : A, x ≠ 0 → ∃ y, χ x y ≠ 1) :
    (Matrix.of fun x y : A => χ x y) * (Matrix.of fun y x' : A => χ (-x') y)
      = (Fintype.card A : ℂ) • (1 : Matrix A A ℂ) := by
  ext x x'
  rw [Matrix.mul_apply]
  simp only [Matrix.of_apply, Matrix.smul_apply, Matrix.one_apply, smul_eq_mul]
  rw [smatrix_orthogonality h hnd x x']
  by_cases hxx : x = x' <;> simp [hxx]

end Anyons

end QuantumDouble