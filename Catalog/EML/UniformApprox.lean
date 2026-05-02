/-
# Uniform Approximation on Sets and Compositional Error Propagation

This file develops a theory of uniform approximation on subsets of metric spaces,
with particular focus on how approximation errors propagate through compositions
of Lipschitz maps. This provides the foundational perturbation theory needed for
deep network approximation.

## Main definitions

* `UniformApproxOn K f g ε` — `f` and `g` are `ε`-close on `K` in sup-distance.

## Main results

* `UniformApproxOn.comp` — Lipschitz maps amplify uniform approximation error by
  at most their Lipschitz constant.
* `UniformApproxOn.comp₂` — Two-stage telescoping: approximating both the inner
  map and outer map yields error `L * ε₁ + ε₂`.
-/
import Mathlib

noncomputable section

/-! ## Definition and basic properties -/

/-- `UniformApproxOn K f g ε` means `f` and `g` are uniformly `ε`-close on the set `K`. -/
def UniformApproxOn {α β : Type*} [PseudoMetricSpace β]
    (K : Set α) (f g : α → β) (ε : ℝ) : Prop :=
  ∀ x ∈ K, dist (f x) (g x) ≤ ε

namespace UniformApproxOn

variable {α β γ : Type*} [PseudoMetricSpace β] [PseudoMetricSpace γ]

/-- Reflexivity: any function is a 0-approximation of itself. -/
theorem refl (K : Set α) (f : α → β) : UniformApproxOn K f f 0 := by
  intro x _; simp [dist_self]

/-- Symmetry: if `f` approximates `g`, then `g` approximates `f`. -/
theorem symm {K : Set α} {f g : α → β} {ε : ℝ}
    (h : UniformApproxOn K f g ε) : UniformApproxOn K g f ε := by
  intro x hx; rw [dist_comm]; exact h x hx

/-- Monotonicity in the error bound. -/
theorem mono {K : Set α} {f g : α → β} {ε₁ ε₂ : ℝ}
    (h : UniformApproxOn K f g ε₁) (hle : ε₁ ≤ ε₂) :
    UniformApproxOn K f g ε₂ := by
  intro x hx; exact le_trans (h x hx) hle

/-- Monotonicity in the set. -/
theorem mono_set {K₁ K₂ : Set α} {f g : α → β} {ε : ℝ}
    (h : UniformApproxOn K₂ f g ε) (hle : K₁ ⊆ K₂) :
    UniformApproxOn K₁ f g ε := by
  intro x hx; exact h x (hle hx)

/-- Triangle inequality for uniform approximation. -/
theorem triangle {K : Set α} {f g h : α → β} {ε₁ ε₂ : ℝ}
    (hfg : UniformApproxOn K f g ε₁) (hgh : UniformApproxOn K g h ε₂) :
    UniformApproxOn K f h (ε₁ + ε₂) := by
  intro x hx
  calc dist (f x) (h x)
      ≤ dist (f x) (g x) + dist (g x) (h x) := dist_triangle _ _ _
    _ ≤ ε₁ + ε₂ := add_le_add (hfg x hx) (hgh x hx)

/-- On the empty set, anything is uniformly close. -/
theorem empty (f g : α → β) (ε : ℝ) : UniformApproxOn ∅ f g ε := by
  intro x hx; simp at hx

/-- The universal set version: equivalent to pointwise bound everywhere. -/
theorem univ_iff {f g : α → β} {ε : ℝ} :
    UniformApproxOn Set.univ f g ε ↔ ∀ x, dist (f x) (g x) ≤ ε := by
  constructor
  · intro h x; exact h x (Set.mem_univ x)
  · intro h x _; exact h x

/-! ## Composition with Lipschitz maps -/

/-
**Lipschitz composition stability.**
If `Φ` is `L`-Lipschitz and `f ≈ g` within `ε` on `K`,
then `Φ ∘ f ≈ Φ ∘ g` within `L * ε` on `K`.
-/
theorem comp {K : Set α} {f g : α → β} {Φ : β → γ} {ε : ℝ} {L : NNReal}
    (hfg : UniformApproxOn K f g ε)
    (hΦ : LipschitzWith L Φ)
    (_hε : 0 ≤ ε) :
    UniformApproxOn K (fun x => Φ (f x)) (fun x => Φ (g x)) ((L : ℝ) * ε) := by
  -- By definition of Lipschitz continuity, we have that for any $x \in K$, $d(\Phi(f(x)), \Phi(g(x))) \leq L \cdot d(f(x), g(x))$.
  have h_lip : ∀ x ∈ K, dist (Φ (f x)) (Φ (g x)) ≤ L * dist (f x) (g x) := by
    exact fun x hx => hΦ.dist_le_mul _ _;
  exact fun x hx => le_trans ( h_lip x hx ) ( mul_le_mul_of_nonneg_left ( hfg x hx ) L.coe_nonneg )

/-
**Two-stage telescoping estimate.**
Given:
- inner approximation `g ≈ gg` within `ε₁` on `K`,
- outer map `Φ` is `L`-Lipschitz,
- outer approximation `Φ ≈ Ψ` pointwise within `ε₂`,
then `Φ ∘ g ≈ Ψ ∘ gg` within `L * ε₁ + ε₂` on `K`.
-/
theorem comp₂ {K : Set α} {g gg : α → β} {Φ Ψ : β → γ}
    {ε₁ ε₂ : ℝ} {L : NNReal}
    (hg : UniformApproxOn K g gg ε₁)
    (hΦ : LipschitzWith L Φ)
    (hΨ : ∀ y, dist (Φ y) (Ψ y) ≤ ε₂)
    (_hε₁ : 0 ≤ ε₁) :
    UniformApproxOn K (fun x => Φ (g x)) (fun x => Ψ (gg x)) ((L : ℝ) * ε₁ + ε₂) := by
  intro x hx; exact le_trans ( dist_triangle _ _ _ ) ( add_le_add ( hΦ.dist_le_mul _ _ |> le_trans <| mul_le_mul_of_nonneg_left ( hg x hx ) <| NNReal.coe_nonneg _ ) <| hΨ _ ) ;

end UniformApproxOn

end