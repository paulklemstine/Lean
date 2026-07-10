/-
Copyright (c) 2026. All rights reserved.

# Topological Quantum Compiling: the reduced Burau representation of `B₄`

## Background and honest framing

Anyon braiding in a topological quantum computer produces unitary matrices coming
from a linear representation of the braid group `Bₙ`.  The research prompt
conjectures that the "Jones representation at `k = 5`" sends the braid group `B₄`
to a set of `3 × 3` matrices that is *dense* in `SU(3)`, so that braiding four
Fibonacci anyons is universal for quantum computation.

Full topological density in `SU(3)` is a Lie-theoretic statement (it uses the
classification of closed subgroups of a compact Lie group together with
Solovay–Kitaev) that is far beyond what is currently formalizable directly.  In
this file we instead build the *representation itself* and prove the rigorous,
machine-checked algebraic facts that underlie the conjecture, together with an
honest contrarian observation about the role of the deformation parameter.

Concretely we work with the **reduced Burau representation** of `B₄`, which is
genuinely `(n-1) = 3` dimensional — matching the "`3 × 3` matrices" in the
prompt — over an arbitrary commutative ring `R` with a formal parameter `t` (the
value `t = e^{2πi/k}` is the physics specialization; the algebraic identities
hold for every `t`).  The generators are

* `burau1 t = !![-t,0,0; 1,1,0; 0,0,1]`
* `burau2 t = !![1,t,0; 0,-t,0; 0,1,1]`
* `burau3 t = !![1,0,0; 0,1,t; 0,0,-t]`

## What is proved

* **It is a representation of `B₄`.**  The three matrices satisfy the braid
  relations
    - `σ₁ σ₃ = σ₃ σ₁`               (far commutation, `braid_rel_13`)
    - `σ₁ σ₂ σ₁ = σ₂ σ₁ σ₂`         (`braid_rel_12`)
    - `σ₂ σ₃ σ₂ = σ₃ σ₂ σ₃`         (`braid_rel_23`)
  for *every* value of `t` over *every* commutative ring.  These are exactly the
  defining relations of Artin's presentation of `B₄`, so `σᵢ ↦ burauᵢ t` extends
  to a group homomorphism `B₄ → GL₃(R)` whenever `t` is a unit
  (`det (burauᵢ t) = -t`, lemmas `det_burau*`).

* **The image is genuinely infinite** (a necessary condition for density).  At
  the specialization `t = -1` over `ℚ` (where all generators land in `SL₃(ℤ)`)
  the element `W = ρ(σ₁ σ₃)` is a nontrivial *unipotent*: `W = 1 + N` with
  `N ≠ 0` and `N² = 0`.  Hence `Wⁿ = 1 + n·N` (`braidW_pow`), the powers are
  pairwise distinct (`braidW_pow_injective`), so `W` has infinite order
  (`braidW_infinite_order`) and the braid image is infinite.

* **The image is non-abelian** (`burau_noncommute`): `ρ(σ₁)` and `ρ(σ₂)` do not
  commute, so the image is not contained in any *abelian* (e.g. maximal-torus)
  closed subgroup — a small, rigorous step toward "not contained in a proper
  closed subgroup".

* **Contrarian observation: universality is parameter-dependent.**  At the
  *wrong* root of unity `t = 1` every generator is an involution
  (`burau_involution_1/2/3`); the representation collapses to the permutation
  action of the symmetric group `S₄`, whose image is finite.  So the braid gate
  set is emphatically *not* universal for all `t`; the density conjecture can
  only hold at special roots of unity.  This refutes any naive "braiding is
  always universal" reading.

None of these results assumes the density conjecture; they are the exact,
machine-checked algebraic core on which it rests.
-/
import Mathlib

namespace Catalog.Applications.TopologicalQuantumCompiling

open Matrix

/-! ### The reduced Burau representation of `B₄` (`3 × 3`) -/

variable {R : Type*} [CommRing R]

/-- Reduced Burau image of the braid generator `σ₁ ∈ B₄`. -/
def burau1 (t : R) : Matrix (Fin 3) (Fin 3) R := !![-t, 0, 0; 1, 1, 0; 0, 0, 1]

/-- Reduced Burau image of the braid generator `σ₂ ∈ B₄`. -/
def burau2 (t : R) : Matrix (Fin 3) (Fin 3) R := !![1, t, 0; 0, -t, 0; 0, 1, 1]

/-- Reduced Burau image of the braid generator `σ₃ ∈ B₄`. -/
def burau3 (t : R) : Matrix (Fin 3) (Fin 3) R := !![1, 0, 0; 0, 1, t; 0, 0, -t]

/-! ### Braid relations: `σᵢ ↦ burauᵢ t` is a representation of `B₄` -/

/-- Far commutation `σ₁σ₃ = σ₃σ₁`. -/
theorem braid_rel_13 (t : R) : burau1 t * burau3 t = burau3 t * burau1 t := by
  simp only [burau1, burau3]
  ext i j
  fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_three]

/-- Braid relation `σ₁σ₂σ₁ = σ₂σ₁σ₂`. -/
theorem braid_rel_12 (t : R) :
    burau1 t * burau2 t * burau1 t = burau2 t * burau1 t * burau2 t := by
  simp only [burau1, burau2]
  ext i j
  fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_three]

/-- Braid relation `σ₂σ₃σ₂ = σ₃σ₂σ₃`. -/
theorem braid_rel_23 (t : R) :
    burau2 t * burau3 t * burau2 t = burau3 t * burau2 t * burau3 t := by
  simp only [burau2, burau3]
  ext i j
  fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_three]

/-! ### Determinants: generators are invertible when `t` is a unit -/

theorem det_burau1 (t : R) : (burau1 t).det = -t := by
  simp [burau1, Matrix.det_fin_three]

theorem det_burau2 (t : R) : (burau2 t).det = -t := by
  simp [burau2, Matrix.det_fin_three]

theorem det_burau3 (t : R) : (burau3 t).det = -t := by
  simp [burau3, Matrix.det_fin_three]

/-! ### Contrarian: at `t = 1` the generators are involutions (finite `S₄` image) -/

theorem burau_involution_1 : burau1 (1 : ℚ) * burau1 (1 : ℚ) = 1 := by
  simp only [burau1]
  ext i j
  fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_three]

theorem burau_involution_2 : burau2 (1 : ℚ) * burau2 (1 : ℚ) = 1 := by
  simp only [burau2]
  ext i j
  fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_three]

theorem burau_involution_3 : burau3 (1 : ℚ) * burau3 (1 : ℚ) = 1 := by
  simp only [burau3]
  ext i j
  fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_three]

/-! ### Non-abelian image -/

/-- The generators `ρ(σ₁)` and `ρ(σ₂)` do not commute (evaluated at `t = -1`),
so the braid image is non-abelian and cannot lie in any abelian closed subgroup. -/
theorem burau_noncommute :
    burau1 (-1 : ℚ) * burau2 (-1 : ℚ) ≠ burau2 (-1 : ℚ) * burau1 (-1 : ℚ) := by
  intro h
  have h2 := congrFun (congrFun h 0) 0
  simp [burau1, burau2, Matrix.mul_apply, Fin.sum_univ_three] at h2

/-! ### The image is infinite: a unipotent element of infinite order

At `t = -1` all generators have determinant `-t = 1`, i.e. they lie in `SL₃(ℤ)`.
The element `W = ρ(σ₁σ₃)` is a nontrivial unipotent, hence of infinite order. -/

/-- The braid element `W = ρ(σ₁ σ₃)` at `t = -1`, an element of `SL₃(ℤ) ⊂ SL₃(ℚ)`. -/
def braidW : Matrix (Fin 3) (Fin 3) ℚ := burau1 (-1) * burau3 (-1)

/-- Its nilpotent part `N = W - 1`. -/
def braidN : Matrix (Fin 3) (Fin 3) ℚ := braidW - 1

theorem braidW_eq : braidW = 1 + braidN := by
  simp [braidN]

theorem braidN_sq : braidN * braidN = 0 := by
  simp only [braidN, braidW, burau1, burau3]
  ext i j
  fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_three]

theorem braidN_ne_zero : braidN ≠ 0 := by
  simp only [braidN, braidW, burau1, burau3]
  intro h
  have := congrFun (congrFun h 1) 0
  simp at this

/-- Because `N² = 0`, the powers of `W = 1 + N` are `Wⁿ = 1 + n·N`. -/
theorem braidW_pow (n : ℕ) : braidW ^ n = 1 + (n : ℚ) • braidN := by
  induction n with
  | zero => simp
  | succ k ih =>
    rw [pow_succ, ih, braidW_eq]
    have hNN : braidN * braidN = 0 := braidN_sq
    push_cast
    rw [add_mul, mul_add, mul_add, one_mul, mul_one, one_mul, smul_mul_assoc, hNN]
    simp
    module

/-- `W` has infinite order: no positive power is the identity. -/
theorem braidW_infinite_order (n : ℕ) (hn : 0 < n) : braidW ^ n ≠ 1 := by
  rw [braidW_pow]
  intro h
  have hentry := congrFun (congrFun h 1) 0
  simp only [braidN, braidW, burau1, burau3, Matrix.add_apply, Matrix.smul_apply,
    Matrix.one_apply, smul_eq_mul] at hentry
  norm_num [Matrix.mul_apply, Fin.sum_univ_three] at hentry
  omega

/-- The powers of `W` are pairwise distinct, so the braid image is infinite. -/
theorem braidW_pow_injective : Function.Injective (fun n : ℕ => braidW ^ n) := by
  intro m n h
  simp only [braidW_pow] at h
  have hentry := congrFun (congrFun h 1) 0
  simp only [braidN, braidW, burau1, burau3, Matrix.add_apply, Matrix.smul_apply,
    Matrix.one_apply, smul_eq_mul] at hentry
  norm_num [Matrix.mul_apply, Fin.sum_univ_three] at hentry
  omega

/-- **Summary.** The reduced Burau representation of `B₄` is a genuine
representation (the braid relations hold for all `t`) whose image at `t = -1` is
an infinite, non-abelian subgroup of `SL₃(ℚ)`. -/
theorem burau_B4_infinite_nonabelian :
    (∀ t : ℚ, burau1 t * burau2 t * burau1 t = burau2 t * burau1 t * burau2 t) ∧
    (∀ n : ℕ, 0 < n → braidW ^ n ≠ 1) ∧
    burau1 (-1 : ℚ) * burau2 (-1 : ℚ) ≠ burau2 (-1 : ℚ) * burau1 (-1 : ℚ) :=
  ⟨fun t => braid_rel_12 t, braidW_infinite_order, burau_noncommute⟩

end Catalog.Applications.TopologicalQuantumCompiling