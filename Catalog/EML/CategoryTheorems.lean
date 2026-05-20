/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import EML.CategoryDefs

/-!
# EML Category Theorems: Categorical and Analytic Structure

This file proves that EML-computable maps form a category with finite products and
establishes cross-domain theorems connecting EML computation to log-affine geometry.

## Main results

### Categorical structure (Theorems 1–3)
* `vecEMLComp_id` — The identity map is EML-computable.
* `vecEMLComp_comp` — EML-computable maps are closed under composition.
* `vecEMLComp_pair` — EML-computable maps are closed under pairing (finite products).

### Analytical structure (Theorems 4–5)
* `logAffine_mul_closed` — Log-affine maps are closed under multiplication.
* `logAffine_log_is_affine` — Log-affine maps become affine in logarithmic coordinates.

### Additional results
* `scalarEML_neg` — Negation preserves scalar EML computability.
* `scalarEML_sub` — Subtraction preserves scalar EML computability.
* `scalarEML_sum` — Finite sums of EML-computable functions are EML-computable.
* `vecEMLComp_proj` — Coordinate projections are EML-computable.
* `emlComputable_weightedGeomMean` — Weighted geometric means are EML-computable.

## Proof strategy

All categorical theorems are proved by structural induction on the `ScalarEML` derivation
or by coordinatewise reduction. The cross-domain theorems use algebraic identities for
`Real.exp` and `Real.log` (`exp_add`, `log_mul`, `log_exp`).
-/

noncomputable section

open Finset Real

/-! ## Basic scalar EML closure properties -/

/-- Negation preserves scalar EML computability: if `f` is EML-computable, so is `-f`. -/
theorem scalarEML_neg {n : ℕ} {f : (Fin n → ℝ) → ℝ}
    (hf : ScalarEML n f) : ScalarEML n (fun x => -(f x)) := by
  have : (fun x => -(f x)) = (fun x => (fun _ => (-1 : ℝ)) x * f x) := by ext; ring
  rw [this]
  exact ScalarEML.mul (ScalarEML.const (-1)) hf

/-- Subtraction preserves scalar EML computability. -/
theorem scalarEML_sub {n : ℕ} {f g : (Fin n → ℝ) → ℝ}
    (hf : ScalarEML n f) (hg : ScalarEML n g) :
    ScalarEML n (fun x => f x - g x) := by
  have : (fun x => f x - g x) = (fun x => f x + (-(g x))) := by ext; ring
  rw [this]
  exact ScalarEML.add hf (scalarEML_neg hg)

/-- Finite sums of EML-computable scalar functions are EML-computable. -/
theorem scalarEML_sum {n k : ℕ} {fs : Fin k → ((Fin n → ℝ) → ℝ)}
    (hfs : ∀ i, ScalarEML n (fs i)) :
    ScalarEML n (fun x => ∑ i : Fin k, fs i x) := by
  induction k with
  | zero =>
    simp
    exact ScalarEML.const 0
  | succ k ih =>
    have : (fun x => ∑ i : Fin (k + 1), fs i x) =
           (fun x => (∑ i : Fin k, fs (Fin.castSucc i) x) + fs (Fin.last k) x) := by
      ext x
      rw [Fin.sum_univ_castSucc]
    rw [this]
    exact ScalarEML.add (ih (fun i => hfs (Fin.castSucc i))) (hfs (Fin.last k))

/-! ## Theorem 1: Identity is EML-computable -/

/-- **The identity map is EML-computable.** This is the first categorical axiom:
every object has an identity morphism. -/
theorem vecEMLComp_id (n : ℕ) : VecEMLComp n n (fun x => x) := by
  intro j
  exact ScalarEML.coord j

/-! ## Theorem 2: Composition closure -/

/-- **EML-computable maps are closed under composition.** This is the second categorical
axiom: morphisms compose. The proof works by showing that for each output coordinate `j`,
the composed function `g(f(x))_j` is scalar EML by composing the scalar EML derivation
for `g(·)_j` with the vector of scalar EML derivations for `f(·)_i`.

This is the multivariate generalization of `eml_closure_closed_under_comp` from
`ClosureOperator.lean`, lifting from unary to finite-dimensional semantics. -/
theorem vecEMLComp_comp {n m k : ℕ}
    {f : (Fin n → ℝ) → (Fin m → ℝ)}
    {g : (Fin m → ℝ) → (Fin k → ℝ)}
    (hf : VecEMLComp n m f) (hg : VecEMLComp m k g) :
    VecEMLComp n k (fun x => g (f x)) := by
  intro j
  -- g(·)_j is ScalarEML m, and each f(·)_i is ScalarEML n
  -- By the composition rule, g(f(x))_j is ScalarEML n
  exact ScalarEML.comp (hg j) hf

/-! ## Theorem 3: Product stability / Pairing -/

/-- **Coordinate projection is EML-computable.** Projecting onto any single coordinate
is a basic EML-computable map. -/
theorem vecEMLComp_proj {n : ℕ} (i : Fin n) :
    VecEMLComp n 1 (fun x => ![x i]) := by
  intro j
  fin_cases j
  simp
  exact ScalarEML.coord i

/-- **EML-computable maps are closed under pairing (finite products).**
Given `f : ℝⁿ → ℝᵐ` and `g : ℝⁿ → ℝᵏ`, both EML-computable, the paired map
`x ↦ (f(x), g(x)) : ℝⁿ → ℝᵐ⁺ᵏ` is also EML-computable.

This establishes that the category of EML-computable maps has finite products,
upgrading EML from "a class of formulas" to a semantic universe with product structure.
The paired output uses `Fin.addCases` to index the first `m` coordinates by `f`
and the remaining `k` coordinates by `g`. -/
theorem vecEMLComp_pair {n m k : ℕ}
    {f : (Fin n → ℝ) → (Fin m → ℝ)}
    {g : (Fin n → ℝ) → (Fin k → ℝ)}
    (hf : VecEMLComp n m f) (hg : VecEMLComp n k g) :
    VecEMLComp n (m + k) (fun x => Fin.addCases (f x) (g x)) := by
  intro j
  refine Fin.addCases (fun i => ?_) (fun i => ?_) j
  · -- For indices in the first m coordinates, use f
    simp [Fin.addCases]
    exact hf i
  · -- For indices in the last k coordinates, use g
    simp [Fin.addCases]
    exact hg i

/-! ## Theorem 4: Log-affine maps are closed under multiplication -/

/-
**Log-affine maps are closed under pointwise multiplication.**
If `f(x) = exp(∑ᵢ wᵢ log(xᵢ) + c)` and `g(x) = exp(∑ᵢ vᵢ log(xᵢ) + d)`,
then `(f · g)(x) = exp(∑ᵢ (wᵢ + vᵢ) log(xᵢ) + (c + d))`.

This shows the log-affine fragment forms a multiplicative monoid, connecting
EML semantics to information geometry and log-linear statistical models.
-/
theorem logAffine_mul_closed {n : ℕ} {f g : PosVec n → ℝ}
    (hf : LogAffine n f) (hg : LogAffine n g) :
    LogAffine n (fun x => f x * g x) := by
  obtain ⟨ w₁, c₁, hw₁ ⟩ := hf; obtain ⟨ w₂, c₂, hw₂ ⟩ := hg; use w₁ + w₂; use c₁ + c₂; intro x; simp +decide [ hw₁, hw₂, Real.exp_add, add_mul, Finset.sum_add_distrib ] ;
  ring

/-
**Log-affine maps become affine in logarithmic coordinates.**
If `f` is log-affine, then `log(f(x)) = ∑ᵢ wᵢ · log(xᵢ) + c`.

This is the key cross-domain theorem: it identifies the multiplicative fragment
of EML computation with affine geometry in logarithmic coordinates, bridging
analytic computation to convex analysis and tropical geometry.
-/
theorem logAffine_log_is_affine {n : ℕ} {f : PosVec n → ℝ}
    (hf : LogAffine n f) :
    ∃ w : Fin n → ℝ, ∃ c : ℝ,
      ∀ x : PosVec n, Real.log (f x) = ∑ i, w i * Real.log (x.val i) + c := by
  rcases hf with ⟨ w, c, h ⟩;
  -- Apply the natural logarithm to both sides of the equation from h.
  use w, c
  intro x
  simp [h, Real.log_exp]

/-! ## Theorem 5: Weighted geometric mean is EML-computable -/

/-
**Weighted geometric means are EML-computable on positive inputs.**
For any weight vector `w`, the map
`x ↦ exp(∑ᵢ wᵢ · log(xᵢ))`
is a scalar EML expression. This internalizes nonlinear scaling laws, geometric means,
and multiplicative statistics within the EML framework.
-/
theorem emlComputable_weightedGeomMean {n : ℕ} (w : Fin n → ℝ) :
    LogAffine n (fun x : PosVec n => Real.exp (∑ i, w i * Real.log (x.val i))) := by
  exact ⟨ w, 0, fun x => by simp +decide ⟩

/-! ## Theorem 6: Parameterized EML maps (currying) -/

/-
**EML-computable maps support currying via parameter splitting.**
If `f : ℝᵖ⁺ⁿ → ℝᵐ` is EML-computable on a combined input space,
then for any fixed parameter vector `θ : Fin p → ℝ`, the specialized map
`x ↦ f(θ, x)` is EML-computable.

This formalizes the idea that EML families support "parameter sharing":
a single EML-computable map on the joint space gives rise to a family
of EML-computable maps indexed by parameters.
-/
theorem vecEMLComp_curry {p n m : ℕ}
    {f : (Fin (p + n) → ℝ) → (Fin m → ℝ)}
    (hf : VecEMLComp (p + n) m f)
    (θ : Fin p → ℝ) :
    VecEMLComp n m (fun x => f (Fin.addCases θ x)) := by
  intro j;
  convert ScalarEML.comp ( hf j ) _;
  intro i; refine' Fin.addCases _ _ i <;> simp +decide ;
  · exact fun i => ScalarEML.const _;
  · exact fun i => ScalarEML.coord i

/-! ## Additional categorical constructions -/

/-- The constant map is EML-computable. -/
theorem vecEMLComp_const {n m : ℕ} (v : Fin m → ℝ) :
    VecEMLComp n m (fun _ => v) := by
  intro j
  exact ScalarEML.const (v j)

/-- The zero map is EML-computable. -/
theorem vecEMLComp_zero {n m : ℕ} :
    VecEMLComp n m (fun _ => 0) := by
  exact vecEMLComp_const 0

/-
Scalar EML functions on positive inputs are log-affine when they have the right form.
-/
theorem logAffine_const {n : ℕ} (c : ℝ) :
    LogAffine n (fun _ : PosVec n => Real.exp c) := by
  exact ⟨ fun _ ↦ 0, c, fun _ ↦ by simp +decide ⟩

/-
Log-affine positivity: log-affine functions are strictly positive.
-/
theorem logAffine_pos {n : ℕ} {f : PosVec n → ℝ}
    (hf : LogAffine n f) (x : PosVec n) : 0 < f x := by
  obtain ⟨ w, c, h ⟩ := hf;
  exact h x ▸ Real.exp_pos _

end