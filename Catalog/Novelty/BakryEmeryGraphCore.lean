import Mathlib

/-!
# Bakry–Émery Γ-calculus on locally finite graphs

This file sets up the discrete Γ-calculus for the *unnormalised* graph Laplacian

  `Δ f (x) = ∑_{y ∼ x} (f y - f x)`

on a locally finite simple graph, together with the carré du champ operators

  `Γ(f,g)(x) = ½ ∑_{y ∼ x} (f y - f x)(g y - g x)`,
  `Γ₂(f,g)   = ½ (Δ Γ(f,g) - Γ(f, Δg) - Γ(Δf, g))`,

and the dimension-free curvature-dimension condition `CD(0,∞)`:

  `CD0 G  ↔  ∀ f x, 0 ≤ Γ₂(f,f)(x)`.

This is the setting of the paper *Nonnegative Bakry–Émery curvature on bounded-degree
graphs implies volume doubling and Poincaré inequalities*.  The present file develops
the basic calculus: the product-rule characterisation of `Γ`, positivity and
degeneracy of `Γ`, linearity, integration by parts on finite graphs, and the
resulting energy identity.

Downstream files use this calculus to derive *point-mass consequences* of
`Γ₂ ≥ 0` (`Novelty.BakryEmeryPointMass`), an abstract doubling ⇒ polynomial growth
mechanism (`Novelty.BakryEmeryDoubling`) and a fully verified model case
(`Novelty.BakryEmeryLattice`).
-/

namespace BakryEmery

open Finset

variable {V : Type*} [DecidableEq V] (G : SimpleGraph V) [DecidableRel G.Adj]
  [G.LocallyFinite]

/-- The unnormalised graph Laplacian `Δ f (x) = ∑_{y ∼ x} (f y - f x)`. -/
noncomputable def Delta (f : V → ℝ) (x : V) : ℝ :=
  ∑ y ∈ G.neighborFinset x, (f y - f x)

/-- The carré du champ operator `Γ(f,g)(x) = ½ ∑_{y ∼ x} (f y - f x)(g y - g x)`. -/
noncomputable def Gamma (f g : V → ℝ) (x : V) : ℝ :=
  (1 / 2) * ∑ y ∈ G.neighborFinset x, (f y - f x) * (g y - g x)

/-- The iterated carré du champ `Γ₂(f,g) = ½(Δ Γ(f,g) - Γ(f, Δ g) - Γ(Δ f, g))`. -/
noncomputable def Gamma2 (f g : V → ℝ) (x : V) : ℝ :=
  (1 / 2) * (Delta G (Gamma G f g) x - Gamma G f (Delta G g) x - Gamma G (Delta G f) g x)

/-- The dimension-free Bakry–Émery curvature-dimension condition `CD(0,∞)` for the
unnormalised Laplacian. -/
def CD0 : Prop := ∀ (f : V → ℝ) (x : V), 0 ≤ Gamma2 G f f x

variable {G}

/-! ### Elementary identities -/

@[simp] lemma Delta_const (c : ℝ) (x : V) : Delta G (fun _ => c) x = 0 := by
  simp [Delta]

lemma Delta_eq_sum_sub (f : V → ℝ) (x : V) :
    Delta G f x = (∑ y ∈ G.neighborFinset x, f y) - (G.degree x) * f x := by
  simp [Delta, Finset.sum_sub_distrib, SimpleGraph.card_neighborFinset_eq_degree]
  ring

lemma Gamma_comm (f g : V → ℝ) (x : V) : Gamma G f g x = Gamma G g f x := by
  simp only [Gamma]
  congr 1
  exact Finset.sum_congr rfl fun y _ => by ring

/-- `Γ(f,f) ≥ 0`: the carré du champ is a nonnegative quadratic form pointwise. -/
lemma Gamma_self_nonneg (f : V → ℝ) (x : V) : 0 ≤ Gamma G f f x := by
  have : (0:ℝ) ≤ ∑ y ∈ G.neighborFinset x, (f y - f x) * (f y - f x) :=
    Finset.sum_nonneg fun y _ => mul_self_nonneg _
  simpa [Gamma] using by linarith

/-- `Γ(f,f)(x) = 0` exactly when `f` is constant on the closed neighbourhood of `x`. -/
lemma Gamma_self_eq_zero_iff (f : V → ℝ) (x : V) :
    Gamma G f f x = 0 ↔ ∀ y ∈ G.neighborFinset x, f y = f x := by
  constructor
  · intro h y hy
    have hsum : ∑ z ∈ G.neighborFinset x, (f z - f x) * (f z - f x) = 0 := by
      simp only [Gamma] at h; linarith
    have := (Finset.sum_eq_zero_iff_of_nonneg
      (fun z _ => mul_self_nonneg (f z - f x))).1 hsum y hy
    have : f y - f x = 0 := by
      rcases mul_self_eq_zero.1 this with h'
      exact h'
    linarith
  · intro h
    simp only [Gamma]
    rw [Finset.sum_eq_zero (fun y hy => by rw [h y hy]; ring)]
    ring

/-- The product rule: `Γ` is the defect of `Δ` from being a derivation. -/
lemma Gamma_eq_product_rule (f g : V → ℝ) (x : V) :
    Gamma G f g x
      = (1 / 2) * (Delta G (fun v => f v * g v) x - f x * Delta G g x - g x * Delta G f x) := by
  simp only [Gamma, Delta, Finset.mul_sum, ← Finset.sum_sub_distrib]
  congr 1
  funext y
  ring

/-- `Γ₂(f,f) = ½ Δ Γ(f,f) - Γ(f, Δf)`. -/
lemma Gamma2_self (f : V → ℝ) (x : V) :
    Gamma2 G f f x = (1 / 2) * Delta G (Gamma G f f) x - Gamma G f (Delta G f) x := by
  simp only [Gamma2]
  rw [Gamma_comm G (Delta G f) f]
  ring

@[simp] lemma Gamma_const_right (f : V → ℝ) (c : ℝ) (x : V) :
    Gamma G f (fun _ => c) x = 0 := by
  simp [Gamma]

@[simp] lemma Gamma2_const (c : ℝ) (x : V) : Gamma2 G (fun _ => c) (fun _ => c) x = 0 := by
  simp only [Gamma2, Delta_const, Gamma_const_right]
  rw [Gamma_comm G _ (fun _ => c)]
  have h : Gamma G (fun _ : V => c) (fun _ : V => c) = fun _ => 0 := by
    funext y; simp
  simp [h, Delta]

/-! ### Linearity -/

lemma Delta_add (f g : V → ℝ) (x : V) :
    Delta G (fun v => f v + g v) x = Delta G f x + Delta G g x := by
  simp only [Delta, ← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun y _ => by ring

lemma Delta_smul (c : ℝ) (f : V → ℝ) (x : V) :
    Delta G (fun v => c * f v) x = c * Delta G f x := by
  simp only [Delta, Finset.mul_sum]
  exact Finset.sum_congr rfl fun y _ => by ring

lemma Gamma_smul_left (c : ℝ) (f g : V → ℝ) (x : V) :
    Gamma G (fun v => c * f v) g x = c * Gamma G f g x := by
  simp only [Gamma, Finset.mul_sum]
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun y _ => by ring

/-- `Γ₂` scales quadratically, hence `CD(0,∞)` is a scale-invariant condition. -/
lemma Gamma2_smul (c : ℝ) (f : V → ℝ) (x : V) :
    Gamma2 G (fun v => c * f v) (fun v => c * f v) x = c ^ 2 * Gamma2 G f f x := by
  have hΓ : Gamma G (fun v => c * f v) (fun v => c * f v) = fun v => c ^ 2 * Gamma G f f v := by
    funext v
    rw [Gamma_smul_left, Gamma_comm, Gamma_smul_left, Gamma_comm]
    ring
  have hΔ : Delta G (fun v => c * f v) = fun v => c * Delta G f v := by
    funext v; exact Delta_smul c f v
  simp only [Gamma2, hΓ, hΔ]
  rw [Delta_smul (c ^ 2) (Gamma G f f) x,
    Gamma_smul_left c f (fun v => c * Delta G f v) x,
    Gamma_comm G (fun v => c * Delta G f v) f,
    Gamma_smul_left c (Delta G f) f x,
    Gamma_smul_left c (Delta G f) (fun v => c * f v) x,
    Gamma_comm G (Delta G f) (fun v => c * f v),
    Gamma_smul_left c f (Delta G f) x,
    Gamma_comm G f (Delta G f)]
  ring

/-! ### Integration by parts on finite graphs -/

variable [Fintype V]

/-- Symmetry of the adjacency relation lets one swap the order of summation over
oriented edges. -/
lemma sum_neighbor_swap (F : V → V → ℝ) :
    ∑ x : V, ∑ y ∈ G.neighborFinset x, F x y
      = ∑ y : V, ∑ x ∈ G.neighborFinset y, F x y := by
  apply Finset.sum_comm'
  intro x y
  simp only [Finset.mem_univ, true_and, SimpleGraph.mem_neighborFinset, and_true]
  exact ⟨fun h => h.symm, fun h => h.symm⟩

/-- Integration by parts: `∑_x f(x) Δ g(x) = - ∑_x Γ(f,g)(x)`. -/
theorem sum_mul_Delta (f g : V → ℝ) :
    ∑ x : V, f x * Delta G g x = -∑ x : V, Gamma G f g x := by
  have key : ∑ x : V, ∑ y ∈ G.neighborFinset x, f x * (g y - g x)
      = ∑ x : V, ∑ y ∈ G.neighborFinset x, f y * (g x - g y) := by
    rw [sum_neighbor_swap (fun x y => f x * (g y - g x))]
  have expand : ∑ x : V, Gamma G f g x
      = (1/2) * ∑ x : V, ∑ y ∈ G.neighborFinset x, (f y - f x) * (g y - g x) := by
    simp only [Gamma, Finset.mul_sum]
  have lhs : ∑ x : V, f x * Delta G g x
      = ∑ x : V, ∑ y ∈ G.neighborFinset x, f x * (g y - g x) := by
    simp only [Delta, Finset.mul_sum]
  have split : ∑ x : V, ∑ y ∈ G.neighborFinset x, (f y - f x) * (g y - g x)
      = (∑ x : V, ∑ y ∈ G.neighborFinset x, f y * (g y - g x))
        - ∑ x : V, ∑ y ∈ G.neighborFinset x, f x * (g y - g x) := by
    rw [← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun x _ => ?_
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun y _ => by ring
  have swap2 : ∑ x : V, ∑ y ∈ G.neighborFinset x, f y * (g y - g x)
      = -∑ x : V, ∑ y ∈ G.neighborFinset x, f x * (g y - g x) := by
    rw [sum_neighbor_swap (fun x y => f y * (g y - g x))]
    rw [← Finset.sum_neg_distrib]
    refine Finset.sum_congr rfl fun y _ => ?_
    rw [← Finset.sum_neg_distrib]
    exact Finset.sum_congr rfl fun x _ => by ring
  rw [expand, split, swap2, lhs]
  ring

/-- The Laplacian has zero total mass. -/
theorem sum_Delta_eq_zero (f : V → ℝ) : ∑ x : V, Delta G f x = 0 := by
  have := sum_mul_Delta (G := G) (fun _ => (1:ℝ)) f
  simpa using this

/-- Energy identity: `-∑ f Δf = ∑ Γ(f,f) ≥ 0`, i.e. `Δ` is nonpositive. -/
theorem sum_mul_Delta_self_nonpos (f : V → ℝ) : ∑ x : V, f x * Delta G f x ≤ 0 := by
  rw [sum_mul_Delta]
  have : 0 ≤ ∑ x : V, Gamma G f f x :=
    Finset.sum_nonneg fun x _ => Gamma_self_nonneg f x
  linarith

/-- Total `Γ₂` mass equals the squared `L²`-norm of `Δ f`, the discrete Bochner identity
in integrated form. -/
theorem sum_Gamma2_self (f : V → ℝ) :
    ∑ x : V, Gamma2 G f f x = ∑ x : V, (Delta G f x) ^ 2 := by
  have h1 : ∑ x : V, Delta G (Gamma G f f) x = 0 := sum_Delta_eq_zero _
  have h2 : ∑ x : V, Gamma G f (Delta G f) x = -∑ x : V, Delta G f x * Delta G f x := by
    have := sum_mul_Delta (G := G) (Delta G f) f
    rw [this]
    simp only [neg_neg]
    exact (Finset.sum_congr rfl fun x _ => by rw [Gamma_comm]).symm ▸ rfl
  have hsum : ∑ x : V, Gamma2 G f f x
      = ∑ x : V, ((1/2) * Delta G (Gamma G f f) x - Gamma G f (Delta G f) x) := by
    exact Finset.sum_congr rfl fun x _ => Gamma2_self f x
  rw [hsum, Finset.sum_sub_distrib, ← Finset.mul_sum, h1, h2]
  simp [sq]

end BakryEmery