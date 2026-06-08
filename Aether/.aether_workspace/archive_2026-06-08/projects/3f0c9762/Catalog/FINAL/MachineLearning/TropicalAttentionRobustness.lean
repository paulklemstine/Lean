import Mathlib

/-!
# Tropical Certified Robustness for Attention-Style Max-Affine Gating Networks

This file formalizes robustness theorems for tropicalized neural networks with
**input-dependent routing** (attention / gating mechanisms). We prove that tropical
geometry controls certified L∞ robustness even when the routing itself depends on
the input, extending the tropical robustness program from fixed-DAG architectures
to gated max-affine networks.

## Overview

The key challenge is that attention/gating networks have **input-dependent routing**:
the set of contributing computational paths changes as the input is perturbed. Our
main contribution is showing that a global pathwise Lipschitz certificate still holds
under this dynamic routing, yielding certified classification robustness.

## Main Results

### Lipschitz Bounds
* `affine_lipschitz_inf` — A single affine function `w · x + b` is `‖w‖₁`-Lipschitz in L∞.
* `sup'_lipschitz_inf` — A finite maximum of K-Lipschitz functions is K-Lipschitz.
* `maxAffine_lipschitz_inf` — Max-affine representations inherit branch Lipschitz constants.
* `hardMaxRoute_lipschitz_inf` — Hard max routing preserves Lipschitz bounds.
* `gatedCombine_lipschitz_inf` — Simplex-gated convex combinations preserve Lipschitz bounds,
  with an additive penalty from gate variation.

### Certification
* `logitGap_lipschitz_inf` — Pairwise logit gaps have `2K` perturbation bound.
* `tropical_attention_certified_radius` — The predicted class cannot change within
  an L∞ ball of radius `m / (2 * K_trop)`.
* `tropical_attention_prediction_constant_on_ball` — Packaged prediction invariance.

### Compositional Architecture
* `TropGateNet` — Inductive syntax for gated tropical networks.
* `TropGateNet.eval` — Evaluator for the network syntax.
* `TropGateNet.certLip` — Recursively computed Lipschitz certificate.
* `eval_lipschitz_of_cert` — The certificate is sound: eval is certLip-Lipschitz.

## References

This formalizes the natural extension of the tropical robustness program to
input-dependent routing, bridging tropical max-plus representations, certified
L∞ robustness via margins, and modern gating/attention mechanisms.
-/

noncomputable section

open Finset BigOperators

/-! ## Core Definitions -/

/-- Affine function: `w · x + b`. This is the basic building block of tropical
    (max-plus) neural network representations. -/
def affineFun {n : ℕ} (w : Fin n → ℝ) (b : ℝ) (x : Fin n → ℝ) : ℝ :=
  (∑ i, w i * x i) + b

/-- L∞ distance between two vectors, defined as `max_i |x_i - y_i|`.
    Requires the index type to be nonempty. -/
def distInf {n : ℕ} [Nonempty (Fin n)] (x y : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => |x i - y i|)

/-- Max-affine representation: `f(x) = max_j (W_j · x + b_j)`.
    This is the tropical analogue of a piecewise-linear function. -/
def IsMaxAffineRep {n k : ℕ} [Nonempty (Fin k)] (f : (Fin n → ℝ) → ℝ)
    (W : Fin k → Fin n → ℝ) (b : Fin k → ℝ) : Prop :=
  ∀ x, f x = Finset.univ.sup' Finset.univ_nonempty (fun j => affineFun (W j) (b j) x)

/-- Coefficient bound: all weights bounded by `K` in absolute value. -/
def AffineInfNormBound {n : ℕ} (w : Fin n → ℝ) (K : ℝ) : Prop :=
  ∀ i, |w i| ≤ K

/-- Simplex membership for gating weights: nonneg and sum to 1. -/
def InSimplex {k : ℕ} (g : Fin k → ℝ) : Prop :=
  (∀ j, 0 ≤ g j) ∧ (∑ j, g j) = 1

/-- Gated convex combination with input-dependent gating:
    `F(x) = ∑_j g(x)_j · φ_j(x)`.
    This models attention-style weighted aggregation where the weights
    themselves depend on the input. -/
def GatedCombine {n k : ℕ}
    (g : (Fin n → ℝ) → Fin k → ℝ)
    (φ : Fin k → (Fin n → ℝ) → ℝ) :
    (Fin n → ℝ) → ℝ :=
  fun x => ∑ j, g x j * φ j x

/-- Hard max routing: `F(x) = max_j φ_j(x)`.
    This models argmax-style routing / hard attention. -/
def HardMaxRoute {n k : ℕ} [Nonempty (Fin k)]
    (φ : Fin k → (Fin n → ℝ) → ℝ) :
    (Fin n → ℝ) → ℝ :=
  fun x => Finset.univ.sup' Finset.univ_nonempty (fun j => φ j x)

/-- Logit gap between two classes. -/
def logitGap {n C : ℕ} (f : Fin C → (Fin n → ℝ) → ℝ)
    (c d : Fin C) (x : Fin n → ℝ) : ℝ :=
  f c x - f d x

/-! ## Step 1: L∞ Distance Properties -/

/-- Each coordinate difference is bounded by `distInf`. -/
lemma abs_sub_le_distInf {n : ℕ} [Nonempty (Fin n)]
    (x y : Fin n → ℝ) (i : Fin n) :
    |x i - y i| ≤ distInf x y := by
  exact Finset.le_sup' (fun i => |x i - y i|) (Finset.mem_univ i)

/-- `distInf` is nonneg. -/
lemma distInf_nonneg {n : ℕ} [Nonempty (Fin n)]
    (x y : Fin n → ℝ) : 0 ≤ distInf x y := by
  have := abs_sub_le_distInf x y (Classical.arbitrary (Fin n))
  linarith [abs_nonneg (x (Classical.arbitrary (Fin n)) - y (Classical.arbitrary (Fin n)))]

/-
`distInf x x = 0`.
-/
lemma distInf_self {n : ℕ} [Nonempty (Fin n)] (x : Fin n → ℝ) :
    distInf x x = 0 := by
  simp [distInf]

/-! ## Step 2: Affine Function Lipschitz Bound

The key estimate: for `a(x) = w · x + b`, we have
`|a(x) - a(y)| = |∑ᵢ wᵢ(xᵢ - yᵢ)| ≤ (∑ᵢ |wᵢ|) · ‖x - y‖_∞`.

This is the L₁-weight-norm vs L∞-input-perturbation duality. -/

/-
The difference of an affine function equals the dot product of weights with
    the coordinate differences.
-/
lemma affineFun_sub {n : ℕ} (w : Fin n → ℝ) (b : ℝ) (x y : Fin n → ℝ) :
    affineFun w b x - affineFun w b y = ∑ i, w i * (x i - y i) := by
  unfold affineFun; simp +decide [ mul_sub, Finset.sum_sub_distrib ] ;

/-
An affine function `w · x + b` is `‖w‖₁`-Lipschitz in L∞.
    This is the foundational duality: L₁ weight norm controls L∞ perturbation.
-/
theorem affine_lipschitz_inf {n : ℕ} [Nonempty (Fin n)]
    (w : Fin n → ℝ) (b : ℝ) :
    ∀ x y, |affineFun w b x - affineFun w b y| ≤ (∑ i, |w i|) * distInf x y := by
  intros x y; rw [ mul_comm ];
  rw [ Finset.mul_sum, affineFun_sub ];
  exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun i _ => by rw [ abs_mul, mul_comm ] ; exact mul_le_mul_of_nonneg_right ( abs_sub_le_distInf x y i ) ( abs_nonneg _ ) )

/-
Corollary: under per-coordinate bound `|wᵢ| ≤ K`, affine is `n·K`-Lipschitz.
-/
theorem affine_lipschitz_inf_coord_bound {n : ℕ} [Nonempty (Fin n)]
    (w : Fin n → ℝ) (b K : ℝ)
    (hK : AffineInfNormBound w K) :
    ∀ x y, |affineFun w b x - affineFun w b y| ≤ (Fintype.card (Fin n) : ℝ) * K * distInf x y := by
  intro x y;
  refine' le_trans ( affine_lipschitz_inf w b x y ) _;
  exact mul_le_mul_of_nonneg_right ( by simpa using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => hK i ) ( distInf_nonneg x y )

/-! ## Step 3: Finite Maximum Lipschitz Bound

The elementary inequality: if each branch `φ_j` is `K`-Lipschitz, then
`max_j φ_j` is also `K`-Lipschitz. The proof chooses the maximizing index
at one point and uses monotonicity at the other. -/

/-
A finite maximum (sup') of K-Lipschitz functions is K-Lipschitz.
    This is the tropical closure property for hard max operations.
-/
theorem sup'_lipschitz_inf {n k : ℕ} [Nonempty (Fin n)] [Nonempty (Fin k)]
    {φ : Fin k → (Fin n → ℝ) → ℝ} {K : ℝ}
    (_hK_nonneg : 0 ≤ K)
    (hφ_lip : ∀ j x y, |φ j x - φ j y| ≤ K * distInf x y) :
    ∀ x y,
      |Finset.univ.sup' Finset.univ_nonempty (fun j => φ j x) -
       Finset.univ.sup' Finset.univ_nonempty (fun j => φ j y)| ≤ K * distInf x y := by
  intro x y;
  rw [ abs_sub_le_iff ];
  constructor <;> rw [ sub_le_iff_le_add ];
  · simp +zetaDelta at *;
    exact fun j => by linarith [ abs_le.mp ( hφ_lip j x y ), Finset.le_sup' ( fun j => φ j y ) ( Finset.mem_univ j ) ] ;
  · simp +zetaDelta at *;
    exact fun j => by linarith [ abs_le.mp ( hφ_lip j x y ), Finset.le_sup' ( fun j => φ j x ) ( Finset.mem_univ j ) ] ;

/-
Max-affine functions are tropically Lipschitz.
    If `f(x) = max_j (W_j · x + b_j)` and each branch has L₁ weight norm `≤ K`,
    then `f` is `K`-Lipschitz in L∞.
-/
theorem maxAffine_lipschitz_inf {n k : ℕ} [Nonempty (Fin n)] [Nonempty (Fin k)]
    {f : (Fin n → ℝ) → ℝ}
    {W : Fin k → Fin n → ℝ} {b : Fin k → ℝ} {K : ℝ}
    (hrep : IsMaxAffineRep f W b)
    (hK_nonneg : 0 ≤ K)
    (hK : ∀ j, (∑ i, |W j i|) ≤ K) :
    ∀ x y, |f x - f y| ≤ K * distInf x y := by
  intros x y; rw [ hrep x, hrep y ] ; exact (by
  apply sup'_lipschitz_inf hK_nonneg;
  exact fun j x y => le_trans ( affine_lipschitz_inf _ _ _ _ ) ( mul_le_mul_of_nonneg_right ( hK j ) ( distInf_nonneg _ _ ) ))

/-! ## Step 4: Hard Max Routing Lipschitz -/

/-
Hard max routing preserves Lipschitz bounds.
    If each branch `φ_j` is `K`-Lipschitz in L∞, then `max_j φ_j(x)` is too.
    This gives closure of certified robustness under argmax-style routing.
-/
theorem hardMaxRoute_lipschitz_inf {n k : ℕ} [Nonempty (Fin n)] [Nonempty (Fin k)]
    {φ : Fin k → (Fin n → ℝ) → ℝ} {K : ℝ}
    (hK_nonneg : 0 ≤ K)
    (hφ_lip : ∀ j x y, |φ j x - φ j y| ≤ K * distInf x y) :
    ∀ x y, |HardMaxRoute φ x - HardMaxRoute φ y| ≤ K * distInf x y := by
  apply sup'_lipschitz_inf hK_nonneg hφ_lip

/-! ## Step 5: Gated Combination Lipschitz Bound

This is the core novelty: input-dependent routing (attention/gating) still
preserves a global Lipschitz certificate.

The decomposition is:
  `g(x)·φ(x) - g(y)·φ(y) = g(x)·(φ(x)-φ(y)) + (g(x)-g(y))·φ(y)`

The first term is controlled by branch Lipschitz constants (using simplex positivity
and `∑ g = 1`). The second term is controlled by gate smoothness and branch magnitude.
This is the attention analogue of the residual/DAG decomposition. -/

/-
Simplex-gated convex combinations preserve Lipschitz bounds.

The bound `Kφ + k · Kg · B` has two terms:
* `Kφ`: the branch Lipschitz contribution (controlled by simplex averaging),
* `k · Kg · B`: the routing perturbation penalty (gate variation × branch magnitude).

This is the precise point where input-dependent routing enters the analysis.
-/
theorem gatedCombine_lipschitz_inf {n k : ℕ} [Nonempty (Fin n)] [Nonempty (Fin k)]
    {g : (Fin n → ℝ) → Fin k → ℝ}
    {φ : Fin k → (Fin n → ℝ) → ℝ}
    {Kg Kφ B : ℝ}
    (hKg_nonneg : 0 ≤ Kg)
    (hKφ_nonneg : 0 ≤ Kφ)
    (_hB_nonneg : 0 ≤ B)
    (hg_lip : ∀ j x y, |g x j - g y j| ≤ Kg * distInf x y)
    (hg_simplex : ∀ x, InSimplex (g x))
    (hφ_lip : ∀ j x y, |φ j x - φ j y| ≤ Kφ * distInf x y)
    (hφ_bound : ∀ j x, |φ j x| ≤ B) :
    ∀ x y, |GatedCombine g φ x - GatedCombine g φ y|
      ≤ (Kφ + (Fintype.card (Fin k) : ℝ) * Kg * B) * distInf x y := by
  -- Apply the triangle inequality to the sum.
  have h_triangle : ∀ x y, |∑ j, g x j * φ j x - ∑ j, g y j * φ j y| ≤ ∑ j, |g x j * (φ j x - φ j y)| + ∑ j, |(g x j - g y j) * φ j y| := by
    intro x y; rw [ ← Finset.sum_sub_distrib ] ; rw [ ← Finset.sum_add_distrib ] ; exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun i _ => by cases abs_cases ( g x i * ( φ i x - φ i y ) ) <;> cases abs_cases ( ( g x i - g y i ) * φ i y ) <;> cases abs_cases ( g x i * φ i x - g y i * φ i y ) <;> linarith ) ;
  -- Apply the bounds on the individual terms.
  have h_bounds : ∀ x y, ∑ j, |g x j * (φ j x - φ j y)| ≤ Kφ * distInf x y ∧ ∑ j, |(g x j - g y j) * φ j y| ≤ (Fintype.card (Fin k)) * Kg * B * distInf x y := by
    intros x y; constructor <;> simp_all +decide [ abs_mul, mul_comm, mul_left_comm ] ;
    · refine' le_trans ( Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( hφ_lip i x y ) ( abs_nonneg _ ) ) _;
      rw [ ← Finset.sum_mul _ _ _ ];
      exact mul_le_of_le_one_left ( mul_nonneg hKφ_nonneg ( distInf_nonneg x y ) ) ( by rw [ Finset.sum_congr rfl fun _ _ => abs_of_nonneg ( hg_simplex x |>.1 _ ) ] ; exact hg_simplex x |>.2.le );
    · refine' le_trans ( Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( hg_lip i x y ) ( abs_nonneg _ ) ) _;
      exact le_trans ( Finset.sum_le_sum fun _ _ => mul_le_mul_of_nonneg_right ( hφ_bound _ _ ) ( mul_nonneg hKg_nonneg ( distInf_nonneg x y ) ) ) ( by norm_num; linarith );
  exact fun x y => le_trans ( h_triangle x y ) ( by linarith [ h_bounds x y ] )

/-! ## Step 6: Logit Gap Perturbation Bound -/

/-
Pairwise logit gaps have `2·K_trop` perturbation bound.
    This is architecture-agnostic once the closure theorems have supplied `hK`.
-/
theorem logitGap_lipschitz_inf {n C : ℕ} [Nonempty (Fin n)]
    {f : Fin C → (Fin n → ℝ) → ℝ} {K_trop : ℝ}
    (hf_lip : ∀ c x y, |f c x - f c y| ≤ K_trop * distInf x y) :
    ∀ c d x y,
      |(f c x - f d x) - (f c y - f d y)| ≤ 2 * K_trop * distInf x y := by
  exact fun c d x y => abs_sub_le_iff.mpr ⟨ by linarith [ abs_le.mp ( hf_lip c x y ), abs_le.mp ( hf_lip d x y ) ], by linarith [ abs_le.mp ( hf_lip c x y ), abs_le.mp ( hf_lip d x y ) ] ⟩

/-! ## Step 7: Certification Theorems -/

/-
**Weak certification**: with `distInf x z ≤ m / (2·K_trop)`,
    the predicted class `c` remains at least as good as any other class.
-/
theorem tropical_attention_certified_radius_le {n C : ℕ} [Nonempty (Fin n)]
    {f : Fin C → (Fin n → ℝ) → ℝ}
    {K_trop m : ℝ} {c : Fin C} {x z : Fin n → ℝ}
    (hK : ∀ c x y, |f c x - f c y| ≤ K_trop * distInf x y)
    (hmarg : ∀ d, d ≠ c → m ≤ f c x - f d x)
    (hKpos : 0 < K_trop)
    (hz : distInf x z ≤ m / (2 * K_trop)) :
    ∀ d, d ≠ c → f d z ≤ f c z := by
  intro d hd;
  nlinarith [ abs_le.mp ( hK c x z ), abs_le.mp ( hK d x z ), hmarg d hd, mul_div_cancel₀ m ( by linarith : ( 2 * K_trop ) ≠ 0 ) ]

/-
**Strong certification**: with strict inequality on the radius,
    the predicted class `c` is strictly better than any competitor.
    This is the exact certified robustness statement.
-/
theorem tropical_attention_certified_radius {n C : ℕ} [Nonempty (Fin n)]
    {f : Fin C → (Fin n → ℝ) → ℝ}
    {K_trop m : ℝ} {c : Fin C} {x z : Fin n → ℝ}
    (hK : ∀ c x y, |f c x - f c y| ≤ K_trop * distInf x y)
    (hmarg : ∀ d, d ≠ c → m ≤ f c x - f d x)
    (hKpos : 0 < K_trop)
    (hz : distInf x z < m / (2 * K_trop)) :
    ∀ d, d ≠ c → f d z < f c z := by
  intro d hd_ne;
  rw [ lt_div_iff₀ ] at hz <;> nlinarith [ hmarg d hd_ne, abs_le.mp ( hK c x z ), abs_le.mp ( hK d x z ) ]

/-
**Prediction invariance on L∞ ball**: the predicted class `c` cannot change
    anywhere in the L∞ ball of radius `m / (2·K_trop)` centered at `x`.

    This is the main certified robustness theorem for tropical attention networks.
    It combines:
    1. Tropical Lipschitz bounds from max-affine / gated architectures,
    2. Logit gap perturbation analysis,
    3. Margin-based certification.

    The result is architecture-agnostic: any composition of max-affine, hard-max-route,
    and simplex-gated blocks that produces a global Lipschitz constant `K_trop` yields
    this certified radius.
-/
theorem tropical_attention_prediction_constant_on_ball
    {n C : ℕ} [Nonempty (Fin n)]
    {f : Fin C → (Fin n → ℝ) → ℝ}
    {K_trop m : ℝ} {c : Fin C} {x : Fin n → ℝ}
    (hK : ∀ c x y, |f c x - f c y| ≤ K_trop * distInf x y)
    (hargmax : ∀ d, d ≠ c → m ≤ f c x - f d x)
    (_hm_nonneg : 0 ≤ m)
    (hKpos : 0 < K_trop) :
    ∀ z, distInf x z < m / (2 * K_trop) →
      ∀ d, d ≠ c → f d z < f c z := by
  intro z hz d hd; have := hK c x z; have := hK d x z; simp_all +decide [ abs_le ] ;
  rw [ lt_div_iff₀ ( by positivity ) ] at hz; nlinarith [ hK c x z, hK d x z, hargmax d hd ] ;

/-! ## Step 8: Compositional Network Syntax

We define an inductive type representing gated tropical networks and prove
that a recursively computed Lipschitz certificate is sound. -/

/-- Inductive syntax for gated tropical networks.
    * `affine w b` — a single affine function `w · x + b`
    * `hardMax k branches` — hard max over `k+1` sub-networks
    * `gatedMix k g Kg B branches` — simplex-gated convex combination with
      gate Lipschitz constant `Kg` and branch output bound `B` -/
inductive TropGateNet (n : ℕ) : Type
  | affine : (Fin n → ℝ) → ℝ → TropGateNet n
  | hardMax : (k : ℕ) → (Fin (k + 1) → TropGateNet n) → TropGateNet n
  | gatedMix : (k : ℕ) →
      (g : (Fin n → ℝ) → Fin (k + 1) → ℝ) →
      (Kg : ℝ) → (B : ℝ) →
      (Fin (k + 1) → TropGateNet n) → TropGateNet n

/-- Evaluate a gated tropical network at an input vector. -/
def TropGateNet.eval {n : ℕ} : TropGateNet n → (Fin n → ℝ) → ℝ
  | .affine w b => fun x => affineFun w b x
  | .hardMax _ branches => fun x =>
      Finset.univ.sup' Finset.univ_nonempty (fun j => (branches j).eval x)
  | .gatedMix _ g _ _ branches => fun x =>
      ∑ j, g x j * (branches j).eval x

/-- Recursively computed Lipschitz certificate for a gated tropical network.
    * For affine: the L₁ weight norm `∑ᵢ |wᵢ|`.
    * For hard max: the max branch certificate.
    * For gated mix: sum of max branch certificate and gate penalty `(k+1) · Kg · B`. -/
def TropGateNet.certLip {n : ℕ} : TropGateNet n → ℝ
  | .affine w _ => ∑ i, |w i|
  | .hardMax _ branches =>
      Finset.univ.sup' Finset.univ_nonempty (fun j => (branches j).certLip)
  | .gatedMix k _ Kg B branches =>
      Finset.univ.sup' Finset.univ_nonempty (fun j => (branches j).certLip) +
        ((k + 1 : ℕ) : ℝ) * Kg * B

/-- Recursive well-formedness predicate for gated tropical networks.
    For `gatedMix` nodes, gates must be simplex-valued, Lipschitz, and
    branch outputs must be bounded. The predicate is satisfied recursively
    for all sub-networks. -/
def TropGateNet.WellFormed {n : ℕ} [Nonempty (Fin n)] : TropGateNet n → Prop
  | .affine _ _ => True
  | .hardMax _ branches => ∀ j, (branches j).WellFormed
  | .gatedMix _ g Kg B branches =>
      (∀ x, InSimplex (g x)) ∧
      (∀ j x y, |g x j - g y j| ≤ Kg * distInf x y) ∧
      (0 ≤ Kg) ∧ (0 ≤ B) ∧
      (∀ j x, |(branches j).eval x| ≤ B) ∧
      (∀ j, (branches j).WellFormed)

/-
`certLip` is nonneg for well-formed networks.
-/
lemma TropGateNet.certLip_nonneg {n : ℕ} [Nonempty (Fin n)] :
    ∀ (N : TropGateNet n), N.WellFormed → 0 ≤ N.certLip := by
  -- By structural induction on N.
  intro N hN
  induction' N with w b hN affine hN hardMax branches hN gatedMix branches hN;
  · exact Finset.sum_nonneg fun _ _ => abs_nonneg _;
  · exact Finset.le_sup' ( fun j => ( affine j ).certLip ) ( Finset.mem_univ 0 ) |> le_trans ( by solve_by_elim );
  · cases hN;
    exact add_nonneg ( Finset.le_sup' ( fun j => ( branches j ).certLip ) ( Finset.mem_univ 0 ) |> le_trans ( hN 0 ( by tauto ) ) ) ( mul_nonneg ( mul_nonneg ( Nat.cast_nonneg _ ) ( by tauto ) ) ( by tauto ) )

/-
The recursively computed certificate is sound:
    `|eval N x - eval N y| ≤ certLip N · distInf x y`.

    This turns the mathematical theorem into a reusable certified robustness engine
    for attention-style tropical networks. Given a well-formed gated tropical network,
    the `certLip` function computes a valid Lipschitz constant in `distInf`.
-/
theorem eval_lipschitz_of_cert {n : ℕ} [Nonempty (Fin n)] :
    ∀ (N : TropGateNet n), N.WellFormed →
      ∀ x y, |N.eval x - N.eval y| ≤ N.certLip * distInf x y := by
  intro N hN x y; induction N generalizing x y; all_goals generalize_proofs at *;
  · exact affine_lipschitz_inf _ _ x y;
  · apply sup'_lipschitz_inf;
    · exact Finset.le_sup' ( fun j => ( ‹Fin ( _ + 1 ) → TropGateNet n› j ).certLip ) ( Finset.mem_univ 0 ) |> le_trans ( TropGateNet.certLip_nonneg _ ( hN 0 ) );
    · rename_i k a ih;
      intro j x y; specialize ih j ( hN j ) x y; exact le_trans ih ( mul_le_mul_of_nonneg_right ( Finset.le_sup' ( fun j => ( a j |> TropGateNet.certLip ) ) ( Finset.mem_univ j ) ) ( distInf_nonneg x y ) ) ;
  · obtain ⟨ hg₁, hg₂, hg₃, hg₄, hg₅, hg₆ ⟩ := hN; simp_all +decide [ TropGateNet.eval, TropGateNet.certLip ] ;
    rename_i k g Kg B branches ih;
    -- Apply the gatedCombine_lipschitz_inf theorem with the given hypotheses.
    have := gatedCombine_lipschitz_inf (by
    exact hg₃ : 0 ≤ Kg) (by
    exact Finset.le_sup' ( fun j => ( branches j |> TropGateNet.certLip ) ) ( Finset.mem_univ 0 ) |> le_trans ( TropGateNet.certLip_nonneg _ ( hg₆ 0 ) ) : 0 ≤ Finset.univ.sup' Finset.univ_nonempty (fun j => (branches j).certLip)) (by
    exact hg₄ : 0 ≤ B) (by
    exact hg₂ : ∀ j x y, |g x j - g y j| ≤ Kg * distInf x y) (by
    assumption : ∀ x, InSimplex (g x)) (by
    exact fun j x y => le_trans ( ih j x y ) ( mul_le_mul_of_nonneg_right ( Finset.le_sup' ( fun j => ( branches j ).certLip ) ( Finset.mem_univ j ) ) ( distInf_nonneg x y ) ) : ∀ j x y, |(branches j).eval x - (branches j).eval y| ≤ Finset.univ.sup' Finset.univ_nonempty (fun j => (branches j).certLip) * distInf x y) (by
    exact hg₅ : ∀ j x, |(branches j).eval x| ≤ B) x y; simp_all +decide [ TropGateNet.eval, TropGateNet.certLip ] ;
    exact this

/-
Compositional classifier certification corollary:
    if each class logit is computed by a well-formed `TropGateNet`, then
    the classifier is robust within the certified radius.
-/
theorem tropGateNet_classifier_certified
    {n C : ℕ} [Nonempty (Fin n)]
    {nets : Fin C → TropGateNet n}
    {K_trop m : ℝ} {c : Fin C} {x : Fin n → ℝ}
    (hwf : ∀ c, (nets c).WellFormed)
    (hK : ∀ c, (nets c).certLip ≤ K_trop)
    (hargmax : ∀ d, d ≠ c → m ≤ (nets c).eval x - (nets d).eval x)
    (hKpos : 0 < K_trop) :
    ∀ z, distInf x z < m / (2 * K_trop) →
      ∀ d, d ≠ c → (nets d).eval z < (nets c).eval z := by
  intros z hz d hd
  apply tropical_attention_certified_radius (fun c x y => by
    exact le_trans ( eval_lipschitz_of_cert _ ( hwf c ) x y ) ( mul_le_mul_of_nonneg_right ( hK c ) ( distInf_nonneg x y ) )) (fun d hd => by
    exact hargmax d hd) hKpos hz d hd

end