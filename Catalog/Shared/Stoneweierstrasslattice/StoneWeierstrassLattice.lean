import Mathlib

/-!
# Lattice closure from linear and absolute-value closure

The elementary identity
`max a b = ((a + b) + |a - b|) / 2` shows that a real linear family of
functions closed under absolute value is a lattice.  This is the algebraic
lattice step used in proofs of the real Stone–Weierstrass theorem.
-/

open Set

namespace StoneWeierstrassLattice

variable {X : Type*}

/-- Closure conditions sufficient for a family of real-valued functions to be a lattice. -/
def IsLinearLattice (A : Set (X → ℝ)) : Prop :=
  (∀ f ∈ A, ∀ g ∈ A, (fun x => f x + g x) ∈ A) ∧
  (∀ f ∈ A, ∀ g ∈ A, (fun x => f x - g x) ∈ A) ∧
  (∀ f ∈ A, (fun x => |f x|) ∈ A) ∧
  (∀ f ∈ A, (fun x => (2 : ℝ)⁻¹ * f x) ∈ A)

/-- Pointwise maximum expressed using addition, subtraction, absolute value, and halving. -/
lemma max_eq_lattice_formula (f g : X → ℝ) :
    (fun x => max (f x) (g x)) =
      fun x => (2 : ℝ)⁻¹ * ((f x + g x) + |f x - g x|) := by
  funext x
  by_cases h : f x ≤ g x
  · rw [max_eq_right h, abs_of_nonpos (sub_nonpos.mpr h)]
    ring
  · have h' : g x ≤ f x := le_of_not_ge h
    rw [max_eq_left h', abs_of_nonneg (sub_nonneg.mpr h')]
    ring

/-- Pointwise minimum expressed using addition, subtraction, absolute value, and halving. -/
lemma min_eq_lattice_formula (f g : X → ℝ) :
    (fun x => min (f x) (g x)) =
      fun x => (2 : ℝ)⁻¹ * ((f x + g x) - |f x - g x|) := by
  funext x
  by_cases h : f x ≤ g x
  · rw [min_eq_left h, abs_of_nonpos (sub_nonpos.mpr h)]
    ring
  · have h' : g x ≤ f x := le_of_not_ge h
    rw [min_eq_right h', abs_of_nonneg (sub_nonneg.mpr h')]
    ring

/-- A real linear family closed under absolute value is closed under pointwise maximum. -/
theorem max_mem_of_isLinearLattice {A : Set (X → ℝ)} (hA : IsLinearLattice A)
    {f g : X → ℝ} (hf : f ∈ A) (hg : g ∈ A) : (fun x => max (f x) (g x)) ∈ A := by
  rcases hA with ⟨hadd, hsub, habs, hhalf⟩
  rw [max_eq_lattice_formula]
  exact hhalf _ (hadd _ (hadd f hf g hg) _ (habs _ (hsub f hf g hg)))

/-- A real linear family closed under absolute value is closed under pointwise minimum. -/
theorem min_mem_of_isLinearLattice {A : Set (X → ℝ)} (hA : IsLinearLattice A)
    {f g : X → ℝ} (hf : f ∈ A) (hg : g ∈ A) : (fun x => min (f x) (g x)) ∈ A := by
  rcases hA with ⟨hadd, hsub, habs, hhalf⟩
  rw [min_eq_lattice_formula]
  exact hhalf _ (hsub _ (hadd f hf g hg) _ (habs _ (hsub f hf g hg)))

end StoneWeierstrassLattice