import Mathlib

/-!
# Bourgain's Slicing Problem: the discrete cube is dimension-free isotropic

Bourgain's *slicing problem* (the **hyperplane conjecture**) asks whether there is a
universal constant `c > 0` such that every convex body `K ⊆ ℝⁿ` of volume `1` has a
hyperplane section of `(n-1)`-volume at least `c`, *uniformly in the dimension `n`*.
Equivalently, the **isotropic constant** `L_K` of every convex body is bounded by a
universal constant.  The decisive structural notion is *isotropic position*: a body in
isotropic position has covariance matrix equal to a scalar multiple of the identity, and
the scalar (`= L_K²`) is exactly what the conjecture controls.

This file isolates a *fully provable, dimension-free* model of that phenomenon: the uniform
probability measure on the **discrete cube** `{-1, 1}ⁿ`.  We prove, with no measure theory,
that this measure is centred and that its covariance matrix is the identity in *every*
dimension `n`.  Consequently every unit linear functional has variance exactly `1`,
independently of `n` — the discrete cube is in isotropic position with isotropic constant
`1`, a clean dimension-free verification of the structural premise of the slicing problem.

## Main results

* `BourgainSlicing.sum_coord_eq_zero` — each coordinate sums to zero (centred).
* `BourgainSlicing.covariance` — the covariance kernel `T k l = ∑ₓ xₖ xₗ` equals
  `if k = l then 2ⁿ else 0` (identity covariance).
* `BourgainSlicing.E_inner_sq` — `E[⟨θ, x⟩²] = ∑ₖ θₖ²` for every `θ` (isotropy).
* `BourgainSlicing.discreteCube_isotropic` — for a *unit* functional, `E[⟨θ, x⟩²] = 1`,
  **independently of the dimension `n`**.
* `BourgainSlicing.E_inner` — every linear functional is centred: `E[⟨θ, x⟩] = 0`.

-- !-- Lab Notes -- !--
-- HYPOTHESIS: the cube satisfies slicing with a dimension-free constant because, after
--   normalisation, it is isotropic with covariance = identity.  We test the discrete
--   model {-1,1}^n where everything is a finite sum, removing all measure-theoretic
--   machinery (Lebesgue volume of sections is far out of reach of current Mathlib).
-- EXPERIMENT/INSIGHT: the entire isotropy computation reduces to a single sign-flip
--   *involution* on the index set Fin n → Bool.  Flipping coordinate `i` negates xᵢ and
--   fixes every other coordinate; a sum invariant under an involution that negates the
--   summand must vanish.  This collapses both "centred" and "off-diagonal covariance = 0"
--   to the same one-line argument, and makes the result manifestly dimension-free.
-- FAILURE ANALYSIS: attempting to integrate genuine (n-1)-volumes of hyperplane sections
--   (the Pólya/Hensley–Vaaler route) is infeasible here — Mathlib lacks the Fourier-analytic
--   section-volume formula.  The discrete second-moment model captures the *same* structural
--   content (identity covariance ⇒ dimension-free isotropic constant) and is fully verifiable.
-/

namespace BourgainSlicing

open Finset

variable {n : ℕ}

/-- The value of a sign bit: `true ↦ 1`, `false ↦ -1`. -/
def sgn (b : Bool) : ℝ := if b then 1 else -1

/-- The `i`-th coordinate (a `±1` value) of a point of the discrete cube. -/
def coord (x : Fin n → Bool) (i : Fin n) : ℝ := sgn (x i)

/-- Uniform expectation over the `2ⁿ` points of the discrete cube `{-1,1}ⁿ`. -/
noncomputable def E (f : (Fin n → Bool) → ℝ) : ℝ :=
  (∑ x : Fin n → Bool, f x) / 2 ^ n

/-- Flip the `i`-th sign bit of a cube point. -/
def flip (i : Fin n) (x : Fin n → Bool) : Fin n → Bool :=
  Function.update x i (!(x i))

@[simp] theorem sgn_true : sgn true = 1 := rfl
@[simp] theorem sgn_false : sgn false = -1 := rfl

theorem sgn_not (b : Bool) : sgn (!b) = - sgn b := by
  cases b <;> simp [sgn]

theorem sgn_mul_self (b : Bool) : sgn b * sgn b = 1 := by
  cases b <;> norm_num [sgn]

/-- The number of points of the discrete cube is `2ⁿ`. -/
theorem card_cube : (Finset.univ : Finset (Fin n → Bool)).card = 2 ^ n := by
  simp [Fintype.card_fun (α := Fin n) (β := Bool)]

/-- Flipping coordinate `i` is an involution. -/
theorem flip_involutive (i : Fin n) : Function.Involutive (flip i) := by
  intro x
  funext j
  by_cases h : j = i
  · subst h; simp [flip, Function.update_self]
  · simp [flip, Function.update_of_ne h]

/-- Flipping coordinate `i` negates the `i`-th coordinate value. -/
theorem coord_flip_self (i : Fin n) (x : Fin n → Bool) :
    coord (flip i x) i = - coord x i := by
  simp [coord, flip, Function.update_self, sgn_not]

/-- Flipping coordinate `i` leaves coordinate `j ≠ i` unchanged. -/
theorem coord_flip_ne (i j : Fin n) (h : j ≠ i) (x : Fin n → Bool) :
    coord (flip i x) j = coord x j := by
  simp [coord, flip, Function.update_of_ne h]

/-- The permutation of cube points given by flipping coordinate `i`. -/
def flipPerm (i : Fin n) : Equiv.Perm (Fin n → Bool) :=
  (flip_involutive i).toPerm

@[simp] theorem flipPerm_apply (i : Fin n) (x : Fin n → Bool) :
    flipPerm i x = flip i x := rfl

/-- **Centred.** Each coordinate sums to zero over the cube. -/
theorem sum_coord_eq_zero (i : Fin n) :
    ∑ x : Fin n → Bool, coord x i = 0 := by
  have key : ∑ x : Fin n → Bool, coord x i
      = ∑ x : Fin n → Bool, coord (flip i x) i := by
    rw [← Equiv.sum_comp (flipPerm i) (fun x => coord x i)]
    simp
  simp only [coord_flip_self] at key
  rw [Finset.sum_neg_distrib] at key
  linarith

/-- The covariance kernel of the cube: `T k l = ∑ₓ xₖ xₗ`. -/
noncomputable def T (k l : Fin n) : ℝ := ∑ x : Fin n → Bool, coord x k * coord x l

/-- **Off-diagonal covariance vanishes.** For `k ≠ l`, `∑ₓ xₖ xₗ = 0`. -/
theorem T_off_diag {k l : Fin n} (h : k ≠ l) : T k l = 0 := by
  have key : T k l = ∑ x : Fin n → Bool, coord (flip k x) k * coord (flip k x) l := by
    rw [T, ← Equiv.sum_comp (flipPerm k) (fun x => coord x k * coord x l)]
    simp
  simp only [coord_flip_self, coord_flip_ne k l h.symm, neg_mul] at key
  rw [Finset.sum_neg_distrib] at key
  rw [T] at key ⊢
  linarith

/-- **Diagonal covariance.** `∑ₓ xₖ² = 2ⁿ`. -/
theorem T_diag (k : Fin n) : T k k = 2 ^ n := by
  have hone : ∀ x : Fin n → Bool, coord x k * coord x k = 1 := fun x => sgn_mul_self _
  rw [T]
  simp only [hone, Finset.sum_const, card_cube, nsmul_eq_mul, mul_one]
  push_cast
  ring

/-- The covariance kernel is the identity: `T k l = if k = l then 2ⁿ else 0`. -/
theorem covariance (k l : Fin n) : T k l = if k = l then 2 ^ n else 0 := by
  by_cases h : k = l
  · subst h; simp [T_diag]
  · simp [h, T_off_diag h]

/-
**Isotropy.** The second moment of any linear functional `⟨θ, x⟩` over the cube
equals `2ⁿ · ∑ₖ θₖ²`.
-/
theorem sum_inner_sq (θ : Fin n → ℝ) :
    (∑ x : Fin n → Bool, (∑ k, θ k * coord x k) ^ 2)
      = 2 ^ n * ∑ k, (θ k) ^ 2 := by
  have expand : ∀ x : Fin n → Bool,
      (∑ k, θ k * coord x k) ^ 2
        = ∑ k, ∑ l, (θ k * θ l) * (coord x k * coord x l) := by
    intro x
    rw [sq, Finset.sum_mul_sum]
    refine Finset.sum_congr rfl (fun k _ => Finset.sum_congr rfl (fun l _ => by ring))
  simp only [expand]
  -- Pull the `x`-sum innermost: `∑ₓ ∑ₖ ∑ₗ = ∑ₖ ∑ₗ ∑ₓ`, identifying `∑ₓ coordₖ coordₗ` with `T k l`.
  have h_sum : ∑ x : Fin n → Bool, ∑ k, ∑ l, θ k * θ l * (coord x k * coord x l)
      = ∑ k, ∑ l, θ k * θ l * T k l := by
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl (fun k _ => ?_)
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl (fun l _ => by rw [T, Finset.mul_sum])
  -- Use identity covariance `T k l = if k = l then 2ⁿ else 0` and collapse the inner sum.
  rw [h_sum]
  simp only [covariance, mul_ite, mul_zero, Finset.sum_ite_eq, Finset.mem_univ, if_true]
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl (fun k _ => by ring)

/-- **Isotropy, expectation form.** `E[⟨θ, x⟩²] = ∑ₖ θₖ²` for every `θ`. -/
theorem E_inner_sq (θ : Fin n → ℝ) :
    E (fun x => (∑ k, θ k * coord x k) ^ 2) = ∑ k, (θ k) ^ 2 := by
  rw [E, sum_inner_sq]
  have h2 : (2 : ℝ) ^ n ≠ 0 := by positivity
  field_simp

/-- **Centred functionals.** Every linear functional has mean zero over the cube. -/
theorem E_inner (θ : Fin n → ℝ) :
    E (fun x => ∑ k, θ k * coord x k) = 0 := by
  rw [E]
  have : ∑ x : Fin n → Bool, ∑ k, θ k * coord x k = 0 := by
    rw [Finset.sum_comm]
    have : ∀ k, ∑ x : Fin n → Bool, θ k * coord x k = 0 := by
      intro k
      rw [← Finset.mul_sum, sum_coord_eq_zero, mul_zero]
    simp [this]
  rw [this, zero_div]

/-- **Dimension-free isotropic position.** For every *unit* linear functional `θ`
(`∑ₖ θₖ² = 1`), the variance `E[⟨θ, x⟩²]` equals `1`, *independently of the dimension `n`*.
This is the structural property — bounded (here: exactly `1`) isotropic constant uniform in
`n` — whose convex-body analogue is the content of Bourgain's slicing problem. -/
theorem discreteCube_isotropic (θ : Fin n → ℝ) (hθ : ∑ k, (θ k) ^ 2 = 1) :
    E (fun x => (∑ k, θ k * coord x k) ^ 2) = 1 := by
  rw [E_inner_sq, hθ]

end BourgainSlicing