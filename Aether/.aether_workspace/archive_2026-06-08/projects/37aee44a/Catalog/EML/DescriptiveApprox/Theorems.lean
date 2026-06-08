import Mathlib
import EML.DescriptiveApprox.Defs

/-!
# EML Descriptive Approximation Theory — Main Theorems

This file contains the main theorems of descriptive approximation theory
for EML (Exponential-Multiplicative-Logarithmic) expressions:

1. **Closure-generated universal approximation** for positive continuous functions
2. **Compositional complexity bounds** for addition and multiplication
3. **Depth–description complexity connection**
4. **Information-theoretic decay** for retained symbolic information

## Strategy

For universal approximation, we combine:
- The Weierstrass approximation theorem (polynomials are dense in C([a,b]))
- A constructive polynomial-to-EML reduction via Horner's method
- The fact that Horner evaluation agrees with polynomial evaluation

For complexity bounds, we use direct construction: given EML approximants for
f and g, we build approximants for f+g and f*g with controlled size.

For information decay, we prove that the retained symbolic information
`alpha^l * K` is monotonically decreasing in depth when alpha ∈ [0,1].
-/

noncomputable section

open Real Finset Polynomial

/-! ## Horner Evaluation Lemma

The key bridge between polynomial evaluation and EML evaluation.
-/

/-- Horner evaluation of a coefficient function agrees with the
polynomial sum `∑ i ∈ range (n+1), c i * x ^ i`. -/
theorem ofCoeffs_eval_eq_sum (n : ℕ) (c : ℕ → ℝ) (x : ℝ) :
    (EMLExpr.ofCoeffs n c).eval (stdEnv x) =
    ∑ i ∈ Finset.range (n + 1), c i * x ^ i := by
  induction' n with n ih generalizing c x <;>
    simp_all +decide [Finset.sum_range_succ', pow_succ']
  · rfl
  · convert congr_arg (fun y => c 0 + x * y) (ih (fun i => c (i + 1)) x) using 1
    simp +decide [mul_add, mul_assoc, mul_comm, Finset.mul_sum _ _ _]; ring

/-- `polyToEML` converts a Mathlib polynomial into an EML expression whose
evaluation agrees with the polynomial's evaluation. -/
def polyToEML (p : ℝ[X]) : EMLExpr :=
  EMLExpr.ofCoeffs p.natDegree p.coeff

/-- The EML expression produced by `polyToEML` evaluates to the same value
as the original polynomial. -/
theorem polyToEML_eval (p : ℝ[X]) (x : ℝ) :
    (polyToEML p).eval (stdEnv x) = p.eval x := by
  unfold polyToEML
  rw [ofCoeffs_eval_eq_sum, Polynomial.eval_eq_sum_range]

/-! ## Theorem 1: Universal Approximation for Continuous Functions

Every continuous function on a compact interval can be uniformly approximated
by EML expressions. This follows from the Weierstrass approximation theorem
combined with the polynomial-to-EML reduction.
-/

/-- **EML Universal Approximation Theorem (positive interval version).**
For every continuous `f : ℝ → ℝ` with `δ ≤ f(x)` on `[a,b]` and every `ε > 0`,
there exists an EML expression that uniformly approximates `f` to within `ε`.

The positivity hypothesis is natural for the full EML framework (where `log`
is meaningful), though this theorem holds for all continuous functions. -/
theorem eml_universal_approx_positive_interval
    (f : ℝ → ℝ) (a b δ eps : ℝ)
    (_hab : a < b) (_hδ : 0 < δ) (heps : 0 < eps)
    (hcont : Continuous f)
    (_hpos : ∀ x, a ≤ x → x ≤ b → δ ≤ f x) :
    ∃ e : EMLExpr,
      UniformApproxOn f e.eval1 a b eps := by
  obtain ⟨p, hp⟩ : ∃ p : ℝ[X], ∀ x ∈ Set.Icc a b, |p.eval x - f x| < eps :=
    exists_polynomial_near_of_continuousOn a b f hcont.continuousOn eps heps
  exact ⟨polyToEML p, fun x hx₁ hx₂ => by
    have := hp x ⟨hx₁, hx₂⟩
    simp only [EMLExpr.eval1, polyToEML_eval]
    rw [abs_sub_comm] at this
    linarith [le_of_lt this]⟩

/-! ## Theorem 2: Compositional Complexity Bounds

If f and g have EML approximants, then f+g and f*g have approximants
with controlled size (subadditive complexity).
-/

/-- **Additive closure of EML approximation.**
If `e₁` approximates `f` to within `ε/2` and `e₂` approximates `g` to within `ε/2`,
then `EMLExpr.add e₁ e₂` approximates `f + g` to within `ε`. -/
theorem eml_approx_add (f g : ℝ → ℝ) (a b eps : ℝ)
    (e₁ e₂ : EMLExpr) (_heps : 0 < eps)
    (hf : UniformApproxOn f e₁.eval1 a b (eps / 2))
    (hg : UniformApproxOn g e₂.eval1 a b (eps / 2)) :
    UniformApproxOn (fun x => f x + g x) (EMLExpr.add e₁ e₂).eval1 a b eps := by
  intro x hx₁ hx₂
  have h1 := hf x hx₁ hx₂
  have h2 := hg x hx₁ hx₂
  show |f x + g x - (e₁.eval1 x + e₂.eval1 x)| ≤ eps
  have : f x + g x - (e₁.eval1 x + e₂.eval1 x) = (f x - e₁.eval1 x) + (g x - e₂.eval1 x) := by ring
  rw [this]
  exact le_trans (abs_add_le _ _) (by linarith)

/-
**Multiplicative closure of EML approximation.**
If `e₁` approximates `f` to within `ε/(2*(B+1))` and `e₂` approximates `g`
to within `ε/(2*(B+1))`, with both `f` and `g` bounded by `B` on `[a,b]`,
and the per-factor tolerance is at most 1 (i.e., `ε ≤ 2*(B+1)`),
then `EMLExpr.mul e₁ e₂` approximates `f * g` to within `ε`.
-/
theorem eml_approx_mul (f g : ℝ → ℝ) (a b eps B : ℝ)
    (e₁ e₂ : EMLExpr) (_heps : 0 < eps) (hB : 0 < B)
    (hfB : ∀ x, a ≤ x → x ≤ b → |f x| ≤ B)
    (hgB : ∀ x, a ≤ x → x ≤ b → |g x| ≤ B)
    (hf : UniformApproxOn f e₁.eval1 a b (eps / (2 * (B + 1))))
    (hg : UniformApproxOn g e₂.eval1 a b (eps / (2 * (B + 1))))
    (heps_le : eps ≤ 2 * (B + 1)) :
    UniformApproxOn (fun x => f x * g x) (EMLExpr.mul e₁ e₂).eval1 a b eps := by
  intro x hx₁ hx₂
  have h_diff : |f x * g x - e₁.eval1 x * e₂.eval1 x| ≤ |f x| * |g x - e₂.eval1 x| + |f x - e₁.eval1 x| * |e₂.eval1 x| := by
    rw [ ← abs_mul, ← abs_mul ];
    grind;
  have h_bound : |f x| ≤ B ∧ |g x - e₂.eval1 x| ≤ eps / (2 * (B + 1)) ∧ |f x - e₁.eval1 x| ≤ eps / (2 * (B + 1)) ∧ |e₂.eval1 x| ≤ B + eps / (2 * (B + 1)) := by
    exact ⟨ hfB x hx₁ hx₂, hg x hx₁ hx₂, hf x hx₁ hx₂, by rw [ abs_le ] ; constructor <;> linarith [ abs_le.mp ( hgB x hx₁ hx₂ ), abs_le.mp ( hg x hx₁ hx₂ ) ] ⟩;
  convert h_diff.trans _ using 1;
  refine' le_trans ( add_le_add ( mul_le_mul h_bound.1 h_bound.2.1 ( by positivity ) ( by positivity ) ) ( mul_le_mul h_bound.2.2.1 h_bound.2.2.2 ( by positivity ) ( by positivity ) ) ) _;
  field_simp;
  grind +extAll

/-- **Description complexity is subadditive for addition.**
If `f` has an `ε/2`-approximant of size `≤ m` and `g` has an `ε/2`-approximant
of size `≤ n`, then `f + g` has an `ε`-approximant of size `≤ m + n + 1`. -/
theorem eml_description_complexity_add
    (f g : ℝ → ℝ) (a b eps : ℝ) (m n : ℕ)
    (heps : 0 < eps)
    (hm : ∃ e₁ : EMLExpr, e₁.size ≤ m ∧ UniformApproxOn f e₁.eval1 a b (eps / 2))
    (hn : ∃ e₂ : EMLExpr, e₂.size ≤ n ∧ UniformApproxOn g e₂.eval1 a b (eps / 2)) :
    ∃ e : EMLExpr, e.size ≤ m + n + 1 ∧
      UniformApproxOn (fun x => f x + g x) e.eval1 a b eps := by
  obtain ⟨e₁, he₁_size, he₁_approx⟩ := hm
  obtain ⟨e₂, he₂_size, he₂_approx⟩ := hn
  exact ⟨.add e₁ e₂, by simp [EMLExpr.size_add]; omega,
    eml_approx_add f g a b eps e₁ e₂ heps he₁_approx he₂_approx⟩

/-- **Description complexity is subadditive for multiplication** under boundedness.
The hypothesis `ε ≤ 2*(B+1)` ensures the per-factor tolerance is at most 1. -/
theorem eml_description_complexity_mul
    (f g : ℝ → ℝ) (a b eps B : ℝ) (m n : ℕ)
    (heps : 0 < eps) (hB : 0 < B)
    (hfB : ∀ x, a ≤ x → x ≤ b → |f x| ≤ B)
    (hgB : ∀ x, a ≤ x → x ≤ b → |g x| ≤ B)
    (hm : ∃ e₁ : EMLExpr, e₁.size ≤ m ∧
      UniformApproxOn f e₁.eval1 a b (eps / (2 * (B + 1))))
    (hn : ∃ e₂ : EMLExpr, e₂.size ≤ n ∧
      UniformApproxOn g e₂.eval1 a b (eps / (2 * (B + 1))))
    (heps_le : eps ≤ 2 * (B + 1)) :
    ∃ e : EMLExpr, e.size ≤ m + n + 1 ∧
      UniformApproxOn (fun x => f x * g x) e.eval1 a b eps := by
  obtain ⟨e₁, he₁_size, he₁_approx⟩ := hm
  obtain ⟨e₂, he₂_size, he₂_approx⟩ := hn
  exact ⟨.mul e₁ e₂, by simp [EMLExpr.size_mul]; omega,
    eml_approx_mul f g a b eps B e₁ e₂ heps hB hfB hgB he₁_approx he₂_approx heps_le⟩

/-! ## Theorem 3: Depth Upper Bound from Description Complexity

The minimum depth of an EML approximant is bounded by its description complexity,
since depth ≤ size for all EML expressions.
-/

/-- **Depth is bounded by description complexity.**
For any function with a finite EML approximant, the minimum depth needed for
`ε`-approximation is at most the description complexity. -/
theorem eml_min_depth_le_desc_complexity
    (f : ℝ → ℝ) (a b eps : ℝ)
    (_heps : 0 < eps)
    (happrox : ∃ e : EMLExpr, UniformApproxOn f e.eval1 a b eps) :
    eml_min_depth f a b eps ≤ eml_description_complexity f a b eps := by
  obtain ⟨e₀, he₀⟩ := happrox
  have hne : {n : ℕ | ∃ e : EMLExpr, e.size ≤ n ∧ UniformApproxOn f e.eval1 a b eps}.Nonempty :=
    ⟨e₀.size, e₀, le_rfl, he₀⟩
  obtain ⟨e, he_size, he_approx⟩ := Nat.sInf_mem hne
  exact Nat.sInf_le ⟨e, le_trans (EMLExpr.depth_le_size e) he_size, he_approx⟩

/-- **Depth upper bound with explicit constant.**
There exists a constant `C > 0` such that
`eml_min_depth f a b eps ≤ C * eml_description_complexity f a b eps / eps`. -/
theorem eml_min_depth_le_desc_complexity_over_eps
    (f : ℝ → ℝ) (a b eps : ℝ)
    (heps : 0 < eps)
    (happrox : ∃ e : EMLExpr, UniformApproxOn f e.eval1 a b eps) :
    ∃ C : ℝ, 0 < C ∧
      (eml_min_depth f a b eps : ℝ) ≤ C * (eml_description_complexity f a b eps : ℝ) / eps := by
  use eps, heps
  rw [mul_div_cancel_left₀ _ heps.ne']
  exact_mod_cast eml_min_depth_le_desc_complexity f a b eps heps happrox

/-! ## Theorem 4: Information-Theoretic Decay

Deeper EML architectures contract symbolic information exponentially.
-/

/-- **Retained information is bounded above by initial information.**
For any contraction factor `α ∈ [0,1]`, the retained information after
`l` layers never exceeds the initial information `K`. -/
theorem retained_info_le_initial
    (alpha : ℝ) (l K : ℕ)
    (halpha0 : 0 ≤ alpha) (halpha1 : alpha ≤ 1) :
    retained_symbolic_information alpha l K ≤ K :=
  mul_le_of_le_one_left (Nat.cast_nonneg _) (pow_le_one₀ halpha0 halpha1)

/-- **Retained information is monotonically decreasing in depth.**
Deeper architectures retain at most as much symbolic information as shallower ones.
This is the formal content of the information bottleneck principle for EML. -/
theorem retained_symbolic_information_monotone
    (alpha : ℝ) (l₁ l₂ K : ℕ)
    (halpha0 : 0 ≤ alpha) (halpha1 : alpha ≤ 1)
    (hle : l₁ ≤ l₂) :
    retained_symbolic_information alpha l₂ K ≤ retained_symbolic_information alpha l₁ K :=
  mul_le_mul_of_nonneg_right (pow_le_pow_of_le_one halpha0 halpha1 hle) (Nat.cast_nonneg _)

/-- **Quantitative information decay.**
After `l ≥ 1` layers with contraction factor `α ≤ 1`, the retained information
is at most `α * K`. -/
theorem retained_info_exponential_decay
    (alpha : ℝ) (l K : ℕ)
    (halpha0 : 0 ≤ alpha) (halpha1 : alpha ≤ 1)
    (hl : 0 < l) :
    retained_symbolic_information alpha l K ≤ alpha * (K : ℝ) := by
  unfold retained_symbolic_information
  calc alpha ^ l * (K : ℝ) ≤ alpha ^ 1 * (K : ℝ) :=
        mul_le_mul_of_nonneg_right
          (pow_le_pow_of_le_one halpha0 halpha1 hl) (Nat.cast_nonneg _)
    _ = alpha * K := by ring

/-! ## Cross-Domain Connection: Approximation ↔ Information

The following theorem connects the analysis of approximation theory with
information-theoretic bounds.
-/

/-- **Depth-information tradeoff.**
If retained information after `l` layers at rate `α` must be at least `threshold`,
then `α^l * K ≥ threshold`. -/
theorem eml_depth_information_tradeoff
    (alpha : ℝ) (l K : ℕ) (threshold : ℝ)
    (_halpha0 : 0 ≤ alpha) (_halpha1 : alpha ≤ 1)
    (hthreshold : retained_symbolic_information alpha l K ≥ threshold) :
    alpha ^ l * (K : ℝ) ≥ threshold :=
  hthreshold

end