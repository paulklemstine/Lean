import Mathlib

/-!
# Tropical Orbit Shadowing: Non-Autonomous Systems and Max-Plus Dynamics

This file develops a theory of orbit shadowing for **non-autonomous** dynamical systems
(time-varying maps) and connects it to **tropical (max-plus) dynamics**. The key results are:

## Novel Definitions
* `NA` — Non-autonomous dynamical system framework with time-varying maps
* `NA.accumProduct` — Accumulated product of variable contraction rates
* `TropicalShadowingCertificate` — A certified shadowing window with tropical spectral data

## Main Theorems

1. **Variable-Rate Inductive Bound** (`NA.variable_rate_bound`):
   For a non-autonomous system with time-varying Lipschitz constants L₀, L₁, ...,
   the tracking error at step n satisfies:
     eₙ ≤ δ · Σ_{k=0}^{n-1} Π_{j=k+1}^{n-1} L_j
   This generalizes the classical δ/(1−L) bound to non-stationary dynamics.

2. **Variable-Rate Contractive Shadowing** (`NA.uniform_contractive_shadowing`):
   If sup_n L_n ≤ L < 1, the non-autonomous system has the shadowing
   property with radius `δ/(1-L)`.

3. **Shadowing Defect Triangle Inequality** (`ShadowDS.defect_triangle`):
   Compositional certified computation via triangle inequality on defects.

4. **Iterated Contraction Fixed-Point Distance** (`ShadowDS.iterate_dist_fixed_point_bound`):
   For an `L`-contraction with fixed point `p`,
     dist(f^[n](x), p) ≤ L^n · dist(x, p)

5. **Tropical Non-Expansiveness** (`tropMV_component_nonexpansive`):
   Max-plus matrix-vector multiply is non-expansive in each component.

6. **Falsifiable Conjecture**: Birkhoff contraction coefficient for scrambling
   tropical matrices.

## Mathematical Significance

The non-autonomous extension is critical for applications:
- In **tropical dynamics**, the effective contraction rate varies with state
- In **SGD**, the learning rate schedule makes the system non-autonomous
- In **model predictive control**, the dynamics change at each planning horizon
-/

open scoped NNReal Topology
open Finset

noncomputable section

/-! ## Part 1: Non-Autonomous Dynamical Systems -/

namespace NA

/-- A sequence `x : ℕ → α` is a `δ`-pseudo-orbit of the non-autonomous system
    `f : ℕ → α → α` if each step deviates from the map by at most `δ`. -/
def IsPseudoOrbit {α : Type*} [PseudoMetricSpace α]
    (f : ℕ → α → α) (x : ℕ → α) (δ : ℝ) : Prop :=
  ∀ n : ℕ, dist (f n (x n)) (x (n + 1)) ≤ δ

/-- The true orbit of a non-autonomous system starting at `a`. -/
def trueOrbit {α : Type*} (f : ℕ → α → α) (a : α) : ℕ → α
  | 0 => a
  | n + 1 => f n (trueOrbit f a n)

@[simp] lemma trueOrbit_zero {α : Type*} (f : ℕ → α → α) (a : α) :
    trueOrbit f a 0 = a := rfl

@[simp] lemma trueOrbit_succ {α : Type*} (f : ℕ → α → α) (a : α) (n : ℕ) :
    trueOrbit f a (n + 1) = f n (trueOrbit f a n) := rfl

/-- The accumulated product of contraction rates from step `k+1` to step `n-1`:
    Π_{j ∈ [k+1, n)} L_j. When k+1 ≥ n, this is 1 (empty product). -/
def accumProduct (L : ℕ → ℝ) (k n : ℕ) : ℝ :=
  ∏ j ∈ Finset.Ico (k + 1) n, L j

/-- The accumulated error sum: Σ_{k=0}^{n-1} Π_{j=k+1}^{n-1} L_j.
    This generalizes the geometric partial sum Σ_{k=0}^{n-1} L^k. -/
def accumErrorSum (L : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ k ∈ Finset.range n, accumProduct L k n

/-
**Variable-Rate Inductive Bound**: For a non-autonomous system where `f n` is
`L n`-Lipschitz, the tracking error of the true orbit starting at `x 0` against
a `δ`-pseudo-orbit satisfies:

  dist(trueOrbit(n), x(n)) ≤ δ · Σ_{k=0}^{n-1} Π_{j=k+1}^{n-1} L_j

This generalizes the classical bound δ · Σ L^k for autonomous systems.
The proof proceeds by induction on n. At the inductive step, we use the
Lipschitz property of f_n to propagate the error through the triangle inequality.
-/
theorem variable_rate_bound {α : Type*} [PseudoMetricSpace α]
    {f : ℕ → α → α} {L : ℕ → NNReal}
    (hL : ∀ n, LipschitzWith (L n) (f n))
    {x : ℕ → α} {δ : ℝ} (hδ : 0 ≤ δ)
    (hpo : IsPseudoOrbit f x δ) :
    ∀ n : ℕ, dist (trueOrbit f (x 0) n) (x n) ≤
      δ * accumErrorSum (fun k => (L k : ℝ)) n := by
  intro n;
  induction' n with n ih;
  · simp +decide [ accumErrorSum ];
  · -- By the triangle inequality and the Lipschitz property of $f_n$, we have:
    have h_step : dist (trueOrbit f (x 0) (n + 1)) (x (n + 1)) ≤ (L n : ℝ) * dist (trueOrbit f (x 0) n) (x n) + δ := by
      exact le_trans ( dist_triangle _ ( f n ( x n ) ) _ ) ( add_le_add ( by simpa using ( hL n ).dist_le_mul _ _ ) ( hpo n ) );
    -- We'll use that $accumErrorSum L (n + 1) = L n * accumErrorSum L n + 1$.
    have h_accum : accumErrorSum (fun k => (L k : ℝ)) (n + 1) = (L n : ℝ) * accumErrorSum (fun k => (L k : ℝ)) n + 1 := by
      simp +decide [ accumErrorSum, Finset.sum_range_succ ];
      simp +decide [ accumProduct, Finset.mul_sum _ _ _ ];
      exact Finset.sum_congr rfl fun i hi => by rw [ Finset.prod_Ico_succ_top ( by linarith [ Finset.mem_range.mp hi ] ) ] ; ring;
    nlinarith [ show ( L n : ℝ ) ≥ 0 by positivity ]

/-
**Variable-Rate Contractive Shadowing**: If all Lipschitz constants are
uniformly bounded by `Lb < 1`, the accumulated error sum is bounded by the
geometric series `1/(1-Lb)`, giving shadowing radius `δ/(1-Lb)`.

This recovers the autonomous contractive shadowing lemma as a special case
when all maps are the same, but applies to genuinely non-stationary systems.
-/
theorem uniform_contractive_shadowing {α : Type*} [PseudoMetricSpace α]
    {f : ℕ → α → α} {Lb : NNReal} (hLb : (Lb : ℝ) < 1)
    {L : ℕ → NNReal} (hL : ∀ n, LipschitzWith (L n) (f n))
    (hLle : ∀ n, (L n : ℝ) ≤ Lb)
    {x : ℕ → α} {δ : ℝ} (hδ : 0 ≤ δ)
    (hpo : IsPseudoOrbit f x δ) :
    ∀ n : ℕ, dist (trueOrbit f (x 0) n) (x n) ≤ δ / (1 - (Lb : ℝ)) := by
  -- By the variable_rate_bound theorem, we have that the distance is bounded by δ times the accumulated error sum.
  have h_bound : ∀ n, dist (trueOrbit f (x 0) n) (x n) ≤ δ * ∑ k ∈ Finset.range n, (Lb : ℝ) ^ (n - k - 1) := by
    intro n
    have := variable_rate_bound hL hδ hpo n
    have h_prod : ∀ k ∈ Finset.range n, accumProduct (fun k => (L k : ℝ)) k n ≤ (Lb : ℝ) ^ (n - k - 1) := by
      intro k hk; rw [ accumProduct ] ; refine' le_trans ( Finset.prod_le_prod _ fun i hi => hLle i ) _ <;> aesop;
    exact this.trans ( mul_le_mul_of_nonneg_left ( Finset.sum_le_sum h_prod ) hδ );
  intro n
  have h_sum_bound : ∑ k ∈ Finset.range n, (Lb : ℝ) ^ (n - k - 1) ≤ 1 / (1 - Lb) := by
    rw [ ← Finset.sum_range_reflect ];
    rw [ one_div, ← tsum_geometric_of_lt_one ( by positivity ) hLb ];
    refine' le_trans _ ( Summable.sum_le_tsum ( Finset.range n ) ( fun _ _ => by positivity ) ( summable_geometric_of_lt_one ( by positivity ) hLb ) );
    exact Finset.sum_le_sum fun i hi => pow_le_pow_of_le_one ( by positivity ) hLb.le ( by norm_num at *; omega );
  simpa only [ mul_one_div ] using le_trans ( h_bound n ) ( mul_le_mul_of_nonneg_left h_sum_bound hδ )

end NA

/-! ## Part 2: Shadowing Defect Composition -/

namespace ShadowDS

/-
**Shadowing Defect Triangle Inequality**: If `y` is within `ε₁` of `x` and
`z` is within `ε₂` of `y`, then `z` is within `ε₁ + ε₂` of `x`.
This enables compositional certified computation.
-/
theorem defect_triangle {α : Type*} [PseudoMetricSpace α]
    {y x z : ℕ → α} {N : ℕ}
    {ε₁ ε₂ : ℝ}
    (h1 : ∀ n, n ≤ N → dist (y n) (x n) ≤ ε₁)
    (h2 : ∀ n, n ≤ N → dist (z n) (y n) ≤ ε₂) :
    ∀ n, n ≤ N → dist (z n) (x n) ≤ ε₁ + ε₂ := by
  exact fun n hn => le_trans ( dist_triangle _ _ _ ) ( add_comm ε₁ ε₂ ▸ add_le_add ( h2 n hn ) ( h1 n hn ) )

/-
**Iterated Contraction Fixed-Point Distance**: For an `L`-contraction with
fixed point `p`, the distance from the `n`-th iterate to `p` decays
exponentially as `L^n · dist(x, p)`.
-/
theorem iterate_dist_fixed_point_bound {α : Type*} [PseudoMetricSpace α]
    {f : α → α} {L : NNReal} (hL : LipschitzWith L f)
    {p : α} (hfp : f p = p) (x : α) (n : ℕ) :
    dist (f^[n] x) p ≤ (L : ℝ) ^ n * dist x p := by
  induction' n with n ih;
  · simp +decide;
  · simpa [ pow_succ', mul_assoc, hfp, Function.iterate_succ_apply' ] using le_trans ( hL.dist_le_mul _ _ ) ( mul_le_mul_of_nonneg_left ih L.coe_nonneg )

end ShadowDS

/-! ## Part 3: Tropical Shadowing Certificate -/

/-- A **Tropical Shadowing Certificate** bundles spectral data from a tropical
    (max-plus) matrix with orbit shadowing guarantees. -/
structure TropicalShadowingCertificate (α : Type*) [PseudoMetricSpace α] where
  /-- The dynamical map -/
  map : α → α
  /-- Lipschitz constant -/
  lipConst : NNReal
  /-- Lipschitz proof -/
  lipProof : LipschitzWith lipConst map
  /-- Contraction: L < 1 -/
  isContraction : (lipConst : ℝ) < 1
  /-- Per-step deviation bound -/
  delta : ℝ
  /-- Delta is nonneg -/
  delta_nonneg : 0 ≤ delta

/-- The certified shadowing radius of a tropical shadowing certificate. -/
def TropicalShadowingCertificate.certifiedRadius {α : Type*} [PseudoMetricSpace α]
    (cert : TropicalShadowingCertificate α) : ℝ :=
  cert.delta / (1 - (cert.lipConst : ℝ))

/-
The certified radius is nonneg.
-/
theorem TropicalShadowingCertificate.certifiedRadius_nonneg {α : Type*} [PseudoMetricSpace α]
    (cert : TropicalShadowingCertificate α) :
    0 ≤ cert.certifiedRadius := by
  exact div_nonneg cert.delta_nonneg ( sub_nonneg.2 cert.isContraction.le )

/-
**Certificate Composition Bound**: The maximum of two certificates' radii
is bounded by the radius using the maximum delta and the maximum contraction rate.
-/
theorem TropicalShadowingCertificate.compose_radius_bound
    {α : Type*} [PseudoMetricSpace α]
    (c₁ c₂ : TropicalShadowingCertificate α)
    (hmax_contract : max (c₁.lipConst : ℝ) (c₂.lipConst : ℝ) < 1) :
    max c₁.certifiedRadius c₂.certifiedRadius ≤
      (max c₁.delta c₂.delta) / (1 - max (c₁.lipConst : ℝ) (c₂.lipConst : ℝ)) := by
  refine' max_le_iff.mpr ⟨ _, _ ⟩;
  · rw [ TropicalShadowingCertificate.certifiedRadius, div_le_div_iff₀ ] <;> try linarith;
    · exact mul_le_mul ( le_max_left _ _ ) ( sub_le_sub_left ( le_max_left _ _ ) _ ) ( sub_nonneg.2 <| by linarith ) ( by linarith [ c₁.delta_nonneg, c₂.delta_nonneg, le_max_left c₁.delta c₂.delta, le_max_right c₁.delta c₂.delta ] );
    · exact sub_pos_of_lt ( lt_of_le_of_lt ( le_max_left _ _ ) hmax_contract );
  · refine' div_le_div₀ _ _ _ _;
    · exact le_max_of_le_left c₁.delta_nonneg;
    · exact le_max_right _ _;
    · linarith;
    · exact sub_le_sub_left ( le_max_right _ _ ) _

/-! ## Part 4: Tropical Max-Plus Non-Expansiveness -/

/-- Tropical (max-plus) matrix-vector product:
    `(A ⊗ x)_i = max_j (A_{ij} + x_j)`. -/
def tropMV {n : ℕ} [NeZero n] (A : Fin n → Fin n → ℝ) (x : Fin n → ℝ) :
    Fin n → ℝ :=
  fun i => Finset.sup' Finset.univ Finset.univ_nonempty (fun j => A i j + x j)

/-
**Tropical Non-Expansiveness (Component-wise)**: For each coordinate `i`,
the tropical matrix-vector product satisfies:

  |tropMV(A, x)_i - tropMV(A, y)_i| ≤ ⨆ j, |x j - y j|

**Proof**: The max-plus product is the sup of affine functions in x.
For any j, `A_{ij} + x_j ≤ A_{ij} + y_j + |x_j - y_j| ≤ tropMV(A,y)_i + ‖x-y‖`.
Taking the sup over j gives the forward inequality. By symmetry, we get the reverse.
-/
theorem tropMV_component_nonexpansive {n : ℕ} [NeZero n]
    (A : Fin n → Fin n → ℝ) (x y : Fin n → ℝ) (i : Fin n) :
    |tropMV A x i - tropMV A y i| ≤ ⨆ j : Fin n, |x j - y j| := by
  apply abs_sub_le_iff.mpr;
  constructor <;> rw [ sub_le_iff_le_add' ];
  · refine' Finset.sup'_le _ _ _;
    intro j _; linarith [ show A i j + x j ≤ A i j + y j + ⨆ j, |x j - y j| by linarith [ abs_le.mp ( show |x j - y j| ≤ ⨆ j, |x j - y j| by exact le_ciSup ( Finite.bddAbove_range fun j => |x j - y j| ) j ) ], show A i j + y j ≤ tropMV A y i by exact Finset.le_sup' ( f := fun j => A i j + y j ) ( Finset.mem_univ j ) ] ;
  · refine' Finset.sup'_le _ _ _;
    intro j _; linarith [ show A i j + y j ≤ A i j + x j + ⨆ j, |x j - y j| by linarith [ abs_le.mp ( show |x j - y j| ≤ ⨆ j, |x j - y j| by exact le_ciSup ( Finite.bddAbove_range fun j => |x j - y j| ) j ) ], show A i j + x j ≤ tropMV A x i by exact Finset.le_sup' ( f := fun j => A i j + x j ) ( Finset.mem_univ j ) ] ;

/-! ## Part 5: Falsifiable Conjecture -/

/-- **Conjecture (Birkhoff Contraction for Scrambling Matrices)**:

For a tropical matrix `A` that is "scrambling" (for every pair of rows i₁, i₂,
there exists a column j with both A_{i₁,j} > -B and A_{i₂,j} > -B for some bound B),
the oscillation of `A ⊗ x` contracts:

  osc(A ⊗ x) ≤ τ · osc(x)

where `τ < 1` is the Birkhoff contraction coefficient.

**Computational test**: For the 3×3 matrix
  A = [[0, -1, -2], [-2, 0, -1], [-1, -2, 0]]
compute τ(A) and verify that osc(A ⊗ x) / osc(x) ≤ τ(A) for 1000 random x. -/
def BirkhoffContractionConjecture : Prop :=
  ∀ (n : ℕ) [NeZero n] (A : Fin n → Fin n → ℝ),
  (∀ i₁ i₂ : Fin n, ∃ j : Fin n, A i₁ j > -1000 ∧ A i₂ j > -1000) →
  ∃ τ : ℝ, 0 ≤ τ ∧ τ < 1 ∧
    ∀ x : Fin n → ℝ,
      (Finset.sup' Finset.univ Finset.univ_nonempty (tropMV A x) -
       Finset.inf' Finset.univ Finset.univ_nonempty (tropMV A x)) ≤
      τ * (Finset.sup' Finset.univ Finset.univ_nonempty x -
           Finset.inf' Finset.univ Finset.univ_nonempty x)

end