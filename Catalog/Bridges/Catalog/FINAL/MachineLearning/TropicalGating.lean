import Mathlib

/-!
# Tropical Certified Robustness for Attention-Style Gating Networks

This file formalizes attention-style tropical gating blocks — finitely many affine experts
combined via a finite-valued selector — and proves robustness certificates extending the
tropical ReLU theory to dynamically routed piecewise-affine networks.

The central result is that if a piecewise-affine network with global L∞ Lipschitz constant K
has pairwise logit-gap margin m > 0 at a point x, then every perturbation δ with
‖δ‖∞ < m / (2K) preserves the argmax class.

## Main Definitions

* `AffineMapVec d o` — Affine map ℝ^d → ℝ^o represented as a matrix-bias pair.
* `evalAffine` — Evaluation of an affine map.
* `GatedBlock` — A gated block with finite experts and finite-valued routing.
* `combinedAffine` — The single affine map obtained by fixing the route.
* `IsConvexSelector` — Predicate for convex selector coefficients.

## Main Results

* `eval_combinedAffine` — On a fixed route, a gated block equals a single affine map.
* `gatedBlock_eq_affine_on_route_fiber` — Cellwise affine theorem.
* `evalAffine_coord_bound` — Coordinate-wise Lipschitz bound for affine maps.
* `gap_lipschitz` — The logit gap function is 2K-Lipschitz.
* `robust_of_pairwise_margin_lipschitz` — Main robustness theorem.
* `gatedBlock_coord_lipschitz` — Same-cell Lipschitz bound for gated blocks.
* `same_route_local_robustness` — Stronger local certificate using route stability.
* `compose_coord_lipschitz` — Lipschitz constants compose multiplicatively.
* `two_layer_lipschitz` — Compositional norm-level Lipschitz bound.
-/

open scoped BigOperators
open Finset Matrix

noncomputable section

/-! ## Core Definitions -/

/-- An affine map from ℝ^d to ℝ^o, represented as a matrix-bias pair. -/
def AffineMapVec (d o : ℕ) := Matrix (Fin o) (Fin d) ℝ × (Fin o → ℝ)

/-- Evaluate an affine map at a point: `(A, b)(x) = Ax + b`. -/
def evalAffine {d o : ℕ} (E : AffineMapVec d o) (x : Fin d → ℝ) : Fin o → ℝ :=
  fun i => ∑ j, E.1 i j * x j + E.2 i

/-- Selector coefficients for combining experts. -/
def SelectorVec (ι : Type) [Fintype ι] := ι → ℝ

/-- Output of a selector-weighted combination of experts at a point. -/
def selectorOutput {d o : ℕ} {ι σ : Type} [Fintype ι]
    (experts : ι → AffineMapVec d o) (sel : σ → SelectorVec ι) (s : σ) (x : Fin d → ℝ) :
    Fin o → ℝ :=
  fun k => ∑ i, (sel s i) * evalAffine (experts i) x k

/-- A gated block: finite experts with finite-valued routing.
    The route function maps each input to a selector index, determining which
    convex combination of experts is applied. -/
structure GatedBlock (d o : ℕ) (ι σ : Type) [Fintype ι] [Fintype σ] where
  experts : ι → AffineMapVec d o
  selector : σ → SelectorVec ι
  route : (Fin d → ℝ) → σ

/-- Evaluate a gated block at a point. -/
def GatedBlock.eval {d o : ℕ} {ι σ : Type} [Fintype ι] [Fintype σ]
    (B : GatedBlock d o ι σ) (x : Fin d → ℝ) : Fin o → ℝ :=
  selectorOutput B.experts B.selector (B.route x) x

/-- The combined affine map for a given selector value `s`.
    When the route is fixed to `s`, the gated block reduces to this single affine map.
    The matrix is `∑ᵢ sel(s,i) · Aᵢ` and the bias is `∑ᵢ sel(s,i) · bᵢ`. -/
def combinedAffine {d o : ℕ} {ι σ : Type} [Fintype ι]
    (experts : ι → AffineMapVec d o) (sel : σ → SelectorVec ι) (s : σ) :
    AffineMapVec d o :=
  (fun k j => ∑ i, sel s i * (experts i).1 k j,
   fun k => ∑ i, sel s i * (experts i).2 k)

/-- Predicate for convex selector coefficients: nonnegative and summing to 1. -/
def IsConvexSelector {ι σ : Type} [Fintype ι] (sel : σ → SelectorVec ι) : Prop :=
  ∀ s, (∀ i, 0 ≤ sel s i) ∧ (∑ i, sel s i = 1)

/-- Coordinate-wise Lipschitz bound: each output coordinate of `f` changes by
    at most `K · ‖x - y‖` under L∞ perturbation. -/
def CoordLipschitz {d o : ℕ} (f : (Fin d → ℝ) → Fin o → ℝ) (K : ℝ) : Prop :=
  ∀ x y : Fin d → ℝ, ∀ i : Fin o, |f x i - f y i| ≤ K * ‖x - y‖

/-! ## Section 1: Cellwise Affine Structure -/

/-- **Structural lemma**: evaluating the combined affine map equals the selector output.
    This is the key reduction showing that on a fixed route fiber, a gated block
    is a single affine map. -/
theorem eval_combinedAffine {d o : ℕ} {ι σ : Type} [Fintype ι]
    (experts : ι → AffineMapVec d o) (sel : σ → SelectorVec ι) (s : σ) (x : Fin d → ℝ) :
    evalAffine (combinedAffine experts sel s) x = selectorOutput experts sel s x := by
  unfold evalAffine selectorOutput combinedAffine
  unfold evalAffine
  ext
  simp [Finset.sum_add_distrib, mul_add, mul_comm, mul_left_comm, Finset.mul_sum]
  exact Finset.sum_comm

/-- **Cellwise affine theorem**: on the route fiber `{x | B.route x = s}`,
    the gated block equals the combined affine map for selector `s`. -/
theorem gatedBlock_eq_affine_on_route_fiber
    {d o : ℕ} {ι σ : Type} [Fintype ι] [Fintype σ]
    (B : GatedBlock d o ι σ) (s : σ) :
    ∀ x, B.route x = s → B.eval x = evalAffine (combinedAffine B.experts B.selector s) x := by
  intro x hx
  show selectorOutput B.experts B.selector (B.route x) x =
    evalAffine (combinedAffine B.experts B.selector s) x
  rw [hx, ← eval_combinedAffine]

/-! ## Section 2: Lipschitz Bounds for Affine Maps -/

/-- Helper: the difference of affine evaluations eliminates the bias term. -/
theorem evalAffine_diff {d o : ℕ} (E : AffineMapVec d o) (x y : Fin d → ℝ) (i : Fin o) :
    evalAffine E x i - evalAffine E y i = ∑ j, E.1 i j * (x j - y j) := by
  unfold evalAffine; simp [mul_sub]

/-- **Coordinate-wise Lipschitz bound** for a single affine map.
    The bound uses the row-sum of absolute values of the matrix. -/
theorem evalAffine_coord_bound {d o : ℕ} (E : AffineMapVec d o) (x y : Fin d → ℝ) (i : Fin o) :
    |evalAffine E x i - evalAffine E y i| ≤ (∑ j, |E.1 i j|) * ‖x - y‖ := by
  rw [evalAffine_diff, Finset.sum_mul]
  exact le_trans (Finset.abs_sum_le_sum_abs _ _)
    (Finset.sum_le_sum fun _ _ => by
      rw [abs_mul]
      exact mul_le_mul_of_nonneg_left
        (by simpa using norm_le_pi_norm (x - y) _) (abs_nonneg _))

/-- Affine maps satisfy `CoordLipschitz` with any bound on the row-sums. -/
theorem evalAffine_coordLipschitz {d o : ℕ} (E : AffineMapVec d o) (K : ℝ)
    (hK : ∀ i : Fin o, (∑ j, |E.1 i j|) ≤ K) :
    CoordLipschitz (evalAffine E) K := by
  intro x y i
  exact le_trans (evalAffine_coord_bound E x y i)
    (mul_le_mul_of_nonneg_right (hK i) (norm_nonneg _))

/-! ## Section 3: Convex Combination Norm Bounds -/

/-- Each row-sum of the combined matrix is bounded by a convex combination of
    expert row-sums, via the triangle inequality. -/
theorem combinedAffine_rowsum_le {d o : ℕ} {ι σ : Type} [Fintype ι]
    (experts : ι → AffineMapVec d o) (sel : σ → SelectorVec ι)
    (hsel : IsConvexSelector sel) (s : σ) (k : Fin o) :
    ∑ j, |(combinedAffine experts sel s).1 k j| ≤
      ∑ i : ι, sel s i * (∑ j, |(experts i).1 k j|) := by
  have h_triangle : ∑ j, |(combinedAffine experts sel s).1 k j| ≤
      ∑ j, ∑ i, |sel s i * (experts i).1 k j| :=
    Finset.sum_le_sum fun j _ => Finset.abs_sum_le_sum_abs _ _
  exact h_triangle.trans_eq (Finset.sum_comm.trans (Finset.sum_congr rfl fun _ _ => by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun _ _ => by rw [abs_mul, abs_of_nonneg ((hsel s).1 _)]))

/-- A convex combination of values each ≤ M is itself ≤ M. -/
theorem convex_combination_le {ι : Type} [Fintype ι]
    (w : ι → ℝ) (vals : ι → ℝ) (M : ℝ)
    (hw_nn : ∀ i, 0 ≤ w i) (hw_sum : ∑ i, w i = 1)
    (hvals : ∀ i, vals i ≤ M) :
    ∑ i, w i * vals i ≤ M := by
  exact le_trans (Finset.sum_le_sum fun i _ =>
    mul_le_mul_of_nonneg_left (hvals i) (hw_nn i))
    (by simp [← Finset.sum_mul, hw_sum])

/-! ## Section 4: Gated Block Lipschitz on Same Route -/

/-- **Same-cell Lipschitz bound** for gated blocks with convex selectors.
    When two inputs share the same route, the gated block output difference
    is bounded by `K · ‖x - y‖`, where `K` bounds all expert row-sums. -/
theorem gatedBlock_coord_lipschitz
    {d o : ℕ} {ι σ : Type} [Fintype ι] [Fintype σ]
    (B : GatedBlock d o ι σ) (hsel : IsConvexSelector B.selector)
    (K : ℝ)
    (hK : ∀ i : ι, ∀ k : Fin o, (∑ j, |(B.experts i).1 k j|) ≤ K) :
    ∀ x y, B.route x = B.route y →
      ∀ k : Fin o, |B.eval x k - B.eval y k| ≤ K * ‖x - y‖ := by
  intro x y hxy k
  have hx : B.eval x k = evalAffine (combinedAffine B.experts B.selector (B.route x)) x k :=
    congr_fun (gatedBlock_eq_affine_on_route_fiber B (B.route x) x rfl) k
  have hy : B.eval y k = evalAffine (combinedAffine B.experts B.selector (B.route y)) y k :=
    congr_fun (gatedBlock_eq_affine_on_route_fiber B (B.route y) y rfl) k
  rw [hx, hy, hxy]
  exact le_trans (evalAffine_coord_bound _ x y k)
    (mul_le_mul_of_nonneg_right
      (le_trans (combinedAffine_rowsum_le _ _ hsel _ _)
        (convex_combination_le _ _ _ (fun i => (hsel _).1 i) (hsel _).2 (fun i => hK i k)))
      (norm_nonneg _))

/-! ## Section 5: Gap Lipschitz and Robustness -/

/-- **Gap Lipschitz**: the pairwise logit gap `f(·,c) - f(·,j)` is 2K-Lipschitz
    when each coordinate of `f` is K-Lipschitz. -/
theorem gap_lipschitz
    {d C : ℕ} (f : (Fin d → ℝ) → Fin C → ℝ) (K : ℝ)
    (hK : CoordLipschitz f K) (c j : Fin C) :
    ∀ x y, |(f x c - f x j) - (f y c - f y j)| ≤ 2 * K * ‖x - y‖ := by
  intro x y
  have h_triangle : |(f x c - f y c) - (f x j - f y j)| ≤
      |f x c - f y c| + |f x j - f y j| :=
    abs_sub _ _
  calc |(f x c - f x j) - (f y c - f y j)|
      = |(f x c - f y c) - (f x j - f y j)| := by ring_nf
    _ ≤ |f x c - f y c| + |f x j - f y j| := h_triangle
    _ ≤ K * ‖x - y‖ + K * ‖x - y‖ := add_le_add (hK x y c) (hK x y j)
    _ = 2 * K * ‖x - y‖ := by ring

/-- **Main robustness theorem**: if a K-Lipschitz network has pairwise logit-gap
    margin m > 0 at x for class c, then every perturbation δ with ‖δ‖ < m/(2K)
    preserves the argmax class. -/
theorem robust_of_pairwise_margin_lipschitz
    {d C : ℕ} (f : (Fin d → ℝ) → Fin C → ℝ)
    (K : ℝ) (hKpos : 0 < K)
    (hK : CoordLipschitz f K)
    (x : Fin d → ℝ) (c : Fin C) (m : ℝ)
    (_hm : 0 < m)
    (hmargin : ∀ j, j ≠ c → m ≤ f x c - f x j)
    (δ : Fin d → ℝ) (hδ : ‖δ‖ < m / (2 * K)) :
    ∀ j, j ≠ c → f (x + δ) j < f (x + δ) c := by
  intro j hj_ne
  have hgap := gap_lipschitz f K hK c j (x + δ) x
  rw [lt_div_iff₀] at hδ <;> norm_num at * <;>
    nlinarith [abs_le.mp hgap, hmargin j hj_ne]

/-! ## Section 6: Same-Route Local Robustness -/

/-- **Stronger local certificate**: under the assumption that the perturbation
    does not change the route pattern, we get a tighter robustness guarantee
    using the expert norm bound directly. This is the precise local theorem
    showing that the tropical cell decomposition carries the robustness certificate. -/
theorem same_route_local_robustness
    {d C : ℕ} {ι σ : Type} [Fintype ι] [Fintype σ]
    (B : GatedBlock d C ι σ) (hsel : IsConvexSelector B.selector)
    (K : ℝ) (hKpos : 0 < K)
    (hK : ∀ i : ι, ∀ k : Fin C, (∑ j, |(B.experts i).1 k j|) ≤ K)
    (x δ : Fin d → ℝ) (c : Fin C) (m : ℝ)
    (hr : B.route (x + δ) = B.route x)
    (_hm : 0 < m)
    (hmargin : ∀ j, j ≠ c → m ≤ B.eval x c - B.eval x j)
    (hδ : ‖δ‖ < m / (2 * K)) :
    ∀ j, j ≠ c → B.eval (x + δ) j < B.eval (x + δ) c := by
  have h_lip : ∀ k : Fin C, |B.eval (x + δ) k - B.eval x k| ≤ K * ‖δ‖ := by
    intro k
    have := gatedBlock_coord_lipschitz B hsel K hK (x + δ) x hr k
    simpa [show (x + δ) - x = δ from by abel] using this
  intro j hj
  nlinarith [abs_le.mp (h_lip j), abs_le.mp (h_lip c), hmargin j hj,
    mul_div_cancel₀ m (by linarith : (2 * K) ≠ 0)]

/-! ## Section 7: Network Composition -/

/-- Coordinate-wise Lipschitz bounds lift to the norm level. -/
theorem coordLipschitz_to_norm {d o : ℕ} (f : (Fin d → ℝ) → Fin o → ℝ) (K : ℝ) (hK0 : 0 ≤ K)
    (hK : CoordLipschitz f K) :
    ∀ x y : Fin d → ℝ, ‖f x - f y‖ ≤ K * ‖x - y‖ := by
  intro x y
  rw [pi_norm_le_iff_of_nonneg (by positivity)]
  intro i
  simpa [Real.norm_eq_abs] using hK x y i

/-- **Composition of Lipschitz bounds**: if `f` is `Kf`-Lipschitz and `g` is `Kg`-Lipschitz
    (both coordinate-wise, with nonneg constants), then `g ∘ f` is `(Kg * Kf)`-Lipschitz. -/
theorem compose_coord_lipschitz {d m o : ℕ}
    (f : (Fin d → ℝ) → Fin m → ℝ) (g : (Fin m → ℝ) → Fin o → ℝ)
    (Kf Kg : ℝ) (hKf : 0 ≤ Kf) (hKg : 0 ≤ Kg)
    (hf : CoordLipschitz f Kf) (hg : CoordLipschitz g Kg) :
    CoordLipschitz (g ∘ f) (Kg * Kf) := by
  intro x y i
  calc |g (f x) i - g (f y) i|
      ≤ Kg * ‖f x - f y‖ := hg (f x) (f y) i
    _ ≤ Kg * (Kf * ‖x - y‖) :=
        mul_le_mul_of_nonneg_left (coordLipschitz_to_norm f Kf hKf hf x y) hKg
    _ = Kg * Kf * ‖x - y‖ := by ring

/-- **Compositional norm-level Lipschitz bound**: the two-layer norm bound. -/
theorem two_layer_lipschitz {d m o : ℕ}
    (f : (Fin d → ℝ) → Fin m → ℝ) (g : (Fin m → ℝ) → Fin o → ℝ)
    (Kf Kg : ℝ) (hKf : 0 ≤ Kf) (hKg : 0 ≤ Kg)
    (hf : CoordLipschitz f Kf) (hg : CoordLipschitz g Kg) :
    ∀ x y : Fin d → ℝ, ‖(g ∘ f) x - (g ∘ f) y‖ ≤ (Kg * Kf) * ‖x - y‖ :=
  coordLipschitz_to_norm (g ∘ f) (Kg * Kf) (mul_nonneg hKg hKf)
    (compose_coord_lipschitz f g Kf Kg hKf hKg hf hg)

end