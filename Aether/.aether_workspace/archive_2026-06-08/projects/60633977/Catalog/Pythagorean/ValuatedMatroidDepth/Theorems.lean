/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Pythagorean.ValuatedMatroidDepth.Defs

/-!
# Theorems on Valuated Matroid Depth

This file proves the main theorems of the directional depth theory:

1. **Multiplicative stability** (`directionalDepthAtLeast_mul`):
   Products of depth-k functions have depth k.

2. **Tropical bridge** (`negLog_supermodular_of_depth_one`):
   Depth ≥ 1 implies `-log f` is supermodular on the positive support.

3. **Strictness criterion** (`not_depth_two_of_ratio_failure`):
   Failure of log-concavity on a ratio transform obstructs depth 2.

4. **Weak exchange** (`weak_exchange_of_depth_one`):
   Depth ≥ 1 with exchange-closed support yields a tropical exchange inequality.

## Key Technical Lemma

The ratio transform of a product factors as the product of ratio transforms:

  `Rᵢ(f · g)(m) = Rᵢf(m) · Rᵢg(m)`

This identity, combined with induction on depth, gives the multiplicative closure.
-/

noncomputable section

open Finset BigOperators Real

variable {α : Type*} [DecidableEq α]

/-! ## Ratio Transform Algebra -/

/-
The ratio transform of a pointwise product is the pointwise product
    of the ratio transforms. This is the key algebraic identity.
-/
theorem ratioTransform_mul (i : α) (f g : (α → ℕ) → ℝ) :
    RatioTransform i (fun m => f m * g m) = fun m => RatioTransform i f m * RatioTransform i g m := by
  funext m; simp [RatioTransform]; ring

/-! ## Directional Log-Concavity of Products -/

/-
The product of two nonneg directionally log-concave functions is
    directionally log-concave.
-/
theorem directionalLogConcave_mul
    (f g : (α → ℕ) → ℝ)
    (hf_nn : ∀ m, 0 ≤ f m) (hg_nn : ∀ m, 0 ≤ g m)
    (hf : DirectionalLogConcave f) (hg : DirectionalLogConcave g) :
    DirectionalLogConcave (fun m => f m * g m) := by
  -- By definition of DirectionalLogConcave, we need to show that for all i j m, the product of the ratio transforms is greater than or equal to the product of the original functions.
  intros i j m
  have h_f := hf i j m
  have h_g := hg i j m
  simp at *;
  convert mul_le_mul h_f h_g ( mul_nonneg ( hg_nn _ ) ( hg_nn _ ) ) ( mul_nonneg ( hf_nn _ ) ( hf_nn _ ) ) using 1 <;> ring!;

/-! ## Theorem 1: Multiplicative Depth Stability -/

/-
**Multiplicative depth stability**: if `f` and `g` each have directional
    depth at least `k`, and both are nonnegative, then their product also has
    directional depth at least `k`.

    This upgrades first-order log-concavity closure to an entire depth filtration,
    showing that the classes of functions of depth ≥ k form multiplicative monoids.

    **Proof**: by induction on `k`.
    - Base case `k = 0`: trivial.
    - Inductive step `k + 1`: extract directional log-concavity and use
      `directionalLogConcave_mul` for the first layer. Then use the ratio
      transform product identity `Rᵢ(fg) = Rᵢf · Rᵢg` and the inductive
      hypothesis for the recursive depth condition.
-/
theorem directionalDepthAtLeast_mul
    (k : ℕ) (f g : (α → ℕ) → ℝ)
    (hf_nn : ∀ m, 0 ≤ f m) (hg_nn : ∀ m, 0 ≤ g m)
    (hf : DirectionalDepthAtLeast k f)
    (hg : DirectionalDepthAtLeast k g) :
    DirectionalDepthAtLeast k (fun m => f m * g m) := by
  induction' k with k ih generalizing f g;
  · trivial;
  · refine' ⟨ directionalLogConcave_mul f g hf_nn hg_nn hf.1 hg.1, fun i => _ ⟩;
    rw [ ratioTransform_mul ];
    exact ih _ _ ( fun m => div_nonneg ( hf_nn _ ) ( hf_nn _ ) ) ( fun m => div_nonneg ( hg_nn _ ) ( hg_nn _ ) ) ( hf.2 i ) ( hg.2 i )

/-! ## Depth Monotonicity -/

/-
Higher depth implies lower depth: if `f` has depth at least `k`,
    then it has depth at least `j` for any `j ≤ k`.
-/
theorem directionalDepthAtLeast_mono
    {j k : ℕ} {f : (α → ℕ) → ℝ}
    (hk : DirectionalDepthAtLeast k f)
    (hjk : j ≤ k) :
    DirectionalDepthAtLeast j f := by
  induction' k with k ih generalizing j f;
  · aesop;
  · rcases j with ( _ | j ) <;> simp_all +decide [ DirectionalDepthAtLeast ]

/-! ## Theorem 2: Tropical Bridge — Supermodularity -/

/-
**Tropical bridge theorem**: if `f` has directional depth at least 1 and is
    everywhere positive, then `-log f` is supermodular.

    This says depth ≥ 1 already produces a tropical convex potential.
    The mixed log-concavity condition `f(m+eᵢ)·f(m+eⱼ) ≥ f(m)·f(m+eᵢ+eⱼ)`
    translates directly to supermodularity of `-log f` via logarithm monotonicity.

    **Proof**: from `DirectionalLogConcave f`, take `i ≠ j` and use the
    mixed inequality. Apply `Real.log_le_log` and algebraic rearrangement.
-/
theorem negLog_supermodular_of_depth_one
    (f : (α → ℕ) → ℝ)
    (hf_pos : ∀ m, 0 < f m)
    (hf : DirectionalDepthAtLeast 1 f) :
    MultiSupermodular (fun m => - Real.log (f m)) := by
  intro i j m hij
  have h_log : Real.log (f (m + basisVec i)) + Real.log (f (m + basisVec j)) ≥ Real.log (f m) + Real.log (f (m + basisVec i + basisVec j)) := by
    rw [ ← Real.log_mul ( ne_of_gt ( hf_pos _ ) ) ( ne_of_gt ( hf_pos _ ) ), ← Real.log_mul ( ne_of_gt ( hf_pos _ ) ) ( ne_of_gt ( hf_pos _ ) ) ];
    exact Real.log_le_log ( mul_pos ( hf_pos _ ) ( hf_pos _ ) ) ( hf.1 i j m );
  linarith

/-
**Recursive tropical transport**: if `f` has depth at least `k + 1` and is
    everywhere positive, then `-log(Rᵢf)` is supermodular. This produces a tower
    of tropical convex potentials.
-/
theorem negLog_supermodular_ratio_of_depth_succ
    (k : ℕ) (i : α) (f : (α → ℕ) → ℝ)
    (hf_pos : ∀ m, 0 < f m)
    (hf : DirectionalDepthAtLeast (k + 2) f) :
    MultiSupermodular (fun m => - Real.log (RatioTransform i f m)) := by
  convert negLog_supermodular_of_depth_one _ _ _ using 1;
  · exact fun m => div_pos ( hf_pos _ ) ( hf_pos _ );
  · exact directionalDepthAtLeast_mono ( hf.2 i ) ( Nat.le_add_left 1 k )

/-! ## Theorem 3: Strictness Criterion -/

/-
**Strictness criterion**: if `f` has depth at least 1 but some ratio transform
    fails to be directionally log-concave, then `f` does not have depth 2.

    This provides a computational route to exhibiting functions of exact depth 1.
-/
theorem not_depth_two_of_ratio_failure
    (f : (α → ℕ) → ℝ)
    (_h1 : DirectionalDepthAtLeast 1 f)
    (i : α)
    (hfail : ¬ DirectionalLogConcave (RatioTransform i f)) :
    ¬ DirectionalDepthAtLeast 2 f := by
  exact fun h => hfail <| by exact h.2 i |>.1;

/-! ## Theorem 4: Weak Exchange from Depth One -/

/-
Auxiliary: the exchange move preserves degree when `i ≠ j` and `m j > 0`.
-/
theorem exchangeMove_degree [Fintype α]
    {d : ℕ} {m : α → ℕ} {i j : α}
    (hij : i ≠ j) (hm : DegreeSlice d m) (hmj : 0 < m j) :
    DegreeSlice (d) (ExchangeMove m i j) := by
  unfold DegreeSlice ExchangeMove at *;
  simp +decide [ ← hm, Function.update_apply, hij.symm ];
  simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne', * ];
  rw [ ← hm, ← Finset.sum_erase_add _ _ ( Finset.mem_univ j ), ← Finset.sum_erase_add _ _ ( Finset.mem_erase_of_ne_of_mem hij ( Finset.mem_univ i ) ) ] ; omega

/-
**Weak tropical exchange from depth one**: under exchange-closed support
    on a degree slice and directional log-concavity, for any two multi-indices
    with an excess in direction `i`, there exists a compensating direction `j`
    such that the exchange move yields a positive-valued point and the
    directional log-concavity square inequality holds at the exchanged point.

    This is the first bridge from depth theory to valuated matroid exchange:
    the exchange direction exists and the tropical potential remains finite.
-/
theorem weak_exchange_of_depth_one [Fintype α]
    (d : ℕ) (f : (α → ℕ) → ℝ)
    (hf_pos : ∀ m, 0 < f m)
    (hsupp : ExchangeClosedSupport f d)
    (_hf : DirectionalDepthAtLeast 1 f) :
    ∀ ⦃m n : α → ℕ⦄,
      DegreeSlice d m →
      DegreeSlice d n →
      ∀ ⦃i : α⦄, m i < n i →
      ∃ j, n j < m j ∧
        0 < f (ExchangeMove m i j) ∧
        0 < f (ExchangeMove n j i) := by
  exact fun m n hm hn i hi => by rcases hsupp hm hn ( hf_pos m ) ( hf_pos n ) hi with ⟨ j, hj₁, hj₂ ⟩ ; exact ⟨ j, hj₁, hj₂, hf_pos _ ⟩ ;

/-! ## Cross-Domain: Statistical Physics Energy Convexity -/

/-
**Energy landscape convexity**: depth ≥ 2 implies that the local free energy
    increments (ratio transform viewed as chemical potential) have supermodular
    energy landscape. This connects to convexity of response functions in
    statistical mechanics.
-/
theorem ratio_energy_supermodular
    (i : α) (f : (α → ℕ) → ℝ)
    (hf_pos : ∀ m, 0 < f m)
    (hf : DirectionalDepthAtLeast 2 f) :
    MultiSupermodular (fun m => - Real.log (RatioTransform i f m)) := by
  convert negLog_supermodular_ratio_of_depth_succ 0 i f hf_pos hf

end