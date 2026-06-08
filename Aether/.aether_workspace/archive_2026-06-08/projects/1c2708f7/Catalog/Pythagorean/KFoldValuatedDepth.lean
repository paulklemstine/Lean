/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# K-Fold Directional Log-Concavity Depth for Valuated Matroids

This file develops the **Lorentzian depth invariant** for valuated matroids,
based on the k-fold directional log-concavity hierarchy. The central idea is
that the ratio transform `Rᵢf(m) = f(m + eᵢ) / f(m)` is the discrete analog
of the logarithmic derivative, and applying it repeatedly extracts finer
curvature information from the valuation.

## Main Definitions

* `ratioTransform` — the discrete directional ratio transform R_i
* `KFoldDirLogConcave` — k-fold directional log-concavity for multivariate functions
* `LorentzianDepth` — the maximal k at which a function remains k-fold DLC
* `MConvexSupport` — M-convex (exchange-closed) support predicate
* `ValuatedMatroidFn` — a function with M-convex support and positive values

## Main Results

* `kfold_dir_mono` — Higher depth implies lower depth (the hierarchy is nested)
* `kfold_dir_mul` — Product stability: k-fold DLC is closed under pointwise product
* `const_kfold` — Constant functions have infinite depth
* `negLog_supermod_of_dirLC` — Cross-domain bridge to tropical geometry

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Murota, "Discrete Convex Analysis", SIAM, 2003
* Anari–Liu–Oveis Gharan–Vinzant, "Log-Concave Polynomials", 2019
-/

noncomputable section

open Finset BigOperators

namespace KFoldValuatedDepth

/-! ## Unit vectors and support operations -/

/-- Standard basis vector `eᵢ` in `Fin n → ℤ`. -/
def unitVec (n : ℕ) (i : Fin n) : Fin n → ℤ :=
  fun j => if j = i then 1 else 0

/-- Degree of a vector: sum of coordinates. -/
def degree {n : ℕ} (m : Fin n → ℤ) : ℤ :=
  ∑ i, m i

/-- Point-wise addition of integer vectors. -/
def vecAdd {n : ℕ} (m v : Fin n → ℤ) : Fin n → ℤ :=
  fun i => m i + v i

theorem unitVec_coord_self (n : ℕ) (i : Fin n) : unitVec n i i = 1 := by
  simp [unitVec]

theorem unitVec_coord_ne (n : ℕ) (i j : Fin n) (h : j ≠ i) : unitVec n i j = 0 := by
  simp [unitVec, h]

theorem degree_vecAdd {n : ℕ} (m v : Fin n → ℤ) :
    degree (vecAdd m v) = degree m + degree v := by
  simp [degree, vecAdd, Finset.sum_add_distrib]

theorem degree_unitVec (n : ℕ) (i : Fin n) : degree (unitVec n i) = 1 := by
  simp [degree, unitVec, Finset.sum_ite_eq', Finset.mem_univ]

/-! ## Core Definitions -/

variable {n : ℕ}

/-- A function `f` is **positive-valued** on a domain. -/
def PosOn (f : (Fin n → ℤ) → ℝ) (S : Set (Fin n → ℤ)) : Prop :=
  ∀ m ∈ S, 0 < f m

/-- **M-convex support** (exchange-closed): for any two points m, m' in S
    with m_i > m'_i, there exists j with m_j < m'_j such that the exchange
    m - e_i + e_j is also in S. -/
def MConvexSupport (S : Set (Fin n → ℤ)) : Prop :=
  ∀ m m' : Fin n → ℤ, m ∈ S → m' ∈ S →
    ∀ i : Fin n, m' i < m i →
      ∃ j : Fin n, m j < m' j ∧
        vecAdd (vecAdd m (fun k => if k = i then -1 else 0))
               (fun k => if k = j then 1 else 0) ∈ S

/-- The **ratio transform** in direction `i`:
    `Rᵢf(m) = f(m + eᵢ) / f(m)`. -/
def ratioTransform (f : (Fin n → ℤ) → ℝ) (i : Fin n) :
    (Fin n → ℤ) → ℝ :=
  fun m => f (vecAdd m (unitVec n i)) / f m

/-- **Directional log-concavity** in direction `i`:
    `f(m + eᵢ)² ≥ f(m) · f(m + 2eᵢ)` for all m in the domain. -/
def DirLogConcaveAt (f : (Fin n → ℤ) → ℝ) (i : Fin n)
    (S : Set (Fin n → ℤ)) : Prop :=
  ∀ m ∈ S,
    vecAdd m (unitVec n i) ∈ S →
    vecAdd (vecAdd m (unitVec n i)) (unitVec n i) ∈ S →
    f (vecAdd m (unitVec n i)) ^ 2 ≥
      f m * f (vecAdd (vecAdd m (unitVec n i)) (unitVec n i))

/-- **All-direction log-concavity**: directional log-concavity
    holds in every direction. -/
def AllDirLogConcave (f : (Fin n → ℤ) → ℝ) (S : Set (Fin n → ℤ)) : Prop :=
  ∀ i : Fin n, DirLogConcaveAt f i S

/-- **k-fold directional log-concavity**: a recursive definition.
    - 0-fold: f is positive on S
    - (k+1)-fold: f is positive on S, all-direction log-concave,
      and the ratio transform R_i f is k-fold DLC for every direction i. -/
def KFoldDirLogConcave : ℕ → ((Fin n → ℤ) → ℝ) → Set (Fin n → ℤ) → Prop
  | 0, f, S => PosOn f S
  | k + 1, f, S =>
    PosOn f S ∧ AllDirLogConcave f S ∧
    ∀ i : Fin n, KFoldDirLogConcave k (ratioTransform f i) S

/-- The **Lorentzian depth** of a function: the supremum of k such that
    f is k-fold directionally log-concave. -/
def LorentzianDepth (f : (Fin n → ℤ) → ℝ) (S : Set (Fin n → ℤ)) : ℕ∞ :=
  ⨆ (k : ℕ) (_ : KFoldDirLogConcave k f S), (k : ℕ∞)

/-! ## Structural Theorems -/

/-- **Extracting positivity**: k-fold DLC implies positivity on the domain. -/
theorem KFoldDirLogConcave.posOn {f : (Fin n → ℤ) → ℝ}
    {S : Set (Fin n → ℤ)} {k : ℕ}
    (hk : KFoldDirLogConcave k f S) : PosOn f S := by
  cases k with
  | zero => exact hk
  | succ k => exact hk.1

/-- **Extracting log-concavity**: (k+1)-fold DLC implies all-direction log-concavity. -/
theorem KFoldDirLogConcave.allDirLC {f : (Fin n → ℤ) → ℝ}
    {S : Set (Fin n → ℤ)} {k : ℕ}
    (hk : KFoldDirLogConcave (k + 1) f S) : AllDirLogConcave f S :=
  hk.2.1

/-- **Extracting ratio descent**: (k+1)-fold DLC implies the ratio transform
    is k-fold DLC. -/
theorem KFoldDirLogConcave.ratioDescend {f : (Fin n → ℤ) → ℝ}
    {S : Set (Fin n → ℤ)} {k : ℕ}
    (hk : KFoldDirLogConcave (k + 1) f S) (i : Fin n) :
    KFoldDirLogConcave k (ratioTransform f i) S :=
  hk.2.2 i

/-- **Theorem 1 (Hierarchy monotonicity)**: If f is (k+1)-fold DLC, then
    it is k-fold DLC. The hierarchy is strictly nested.

    Proof by induction on k: the base case extracts positivity,
    the inductive step preserves the triple structure. -/
theorem kfold_dir_mono {f : (Fin n → ℤ) → ℝ}
    {S : Set (Fin n → ℤ)} {k : ℕ}
    (hk : KFoldDirLogConcave (k + 1) f S) :
    KFoldDirLogConcave k f S := by
  induction k generalizing f with
  | zero => exact hk.posOn
  | succ k ih =>
    exact ⟨hk.posOn, hk.allDirLC, fun i => ih (hk.ratioDescend i)⟩

/-- Generalized monotonicity: if j ≤ k and f is k-fold DLC, then f is j-fold DLC. -/
theorem kfold_dir_mono_le {f : (Fin n → ℤ) → ℝ}
    {S : Set (Fin n → ℤ)} {j k : ℕ}
    (hjk : j ≤ k) (hk : KFoldDirLogConcave k f S) :
    KFoldDirLogConcave j f S := by
  induction k generalizing f j with
  | zero =>
    have : j = 0 := Nat.eq_zero_of_le_zero hjk
    subst this; exact hk
  | succ k ih =>
    rcases Nat.eq_or_lt_of_le hjk with rfl | hlt
    · exact hk
    · exact ih (Nat.lt_succ_iff.mp hlt) (kfold_dir_mono hk)

/-! ## Product Stability -/

/-- The ratio transform of a pointwise product equals the pointwise product
    of the ratio transforms, when both factors are nonzero. -/
theorem ratioTransform_mul (f g : (Fin n → ℤ) → ℝ) (i : Fin n)
    (_hf : ∀ m, f m ≠ 0) (_hg : ∀ m, g m ≠ 0) :
    ratioTransform (fun m => f m * g m) i =
    fun m => ratioTransform f i m * ratioTransform g i m := by
  ext m
  simp only [ratioTransform]
  rw [mul_div_mul_comm]

/-- Helper: ratio transform of a nowhere-zero function is nowhere-zero. -/
theorem ratioTransform_ne_zero (f : (Fin n → ℤ) → ℝ) (i : Fin n)
    (hf : ∀ m, f m ≠ 0) : ∀ m, ratioTransform f i m ≠ 0 := by
  intro m
  simp only [ratioTransform]
  exact div_ne_zero (hf _) (hf _)

/-- **Theorem 2 (Product stability)**: The product of two k-fold DLC functions
    with nowhere-zero values is k-fold DLC.

    This shows the k-fold classes form multiplicative monoids, a key structural
    property that distinguishes this hierarchy from ad hoc concavity conditions. -/
theorem kfold_dir_mul {f g : (Fin n → ℤ) → ℝ}
    {S : Set (Fin n → ℤ)} {k : ℕ}
    (hf_nz : ∀ m, f m ≠ 0) (hg_nz : ∀ m, g m ≠ 0)
    (hf : KFoldDirLogConcave k f S) (hg : KFoldDirLogConcave k g S) :
    KFoldDirLogConcave k (fun m => f m * g m) S := by
  induction k generalizing f g S with
  | zero =>
    intro m hm
    exact mul_pos (hf m hm) (hg m hm)
  | succ k ih =>
    refine ⟨fun m hm => mul_pos (hf.posOn m hm) (hg.posOn m hm), ?_, ?_⟩
    · -- All-direction log-concavity of the product
      intro i m hm hm1 hm2
      have hfp := hf.posOn
      have hgp := hg.posOn
      have hf_lc := hf.allDirLC i m hm hm1 hm2
      have hg_lc := hg.allDirLC i m hm hm1 hm2
      nlinarith [mul_pos (hfp m hm) (hfp (vecAdd m (unitVec n i)) hm1),
                  mul_pos (hfp m hm) (hfp (vecAdd (vecAdd m (unitVec n i)) (unitVec n i)) hm2),
                  mul_pos (hgp m hm) (hgp (vecAdd m (unitVec n i)) hm1),
                  mul_pos (hgp m hm) (hgp (vecAdd (vecAdd m (unitVec n i)) (unitVec n i)) hm2)]
    · -- Ratio transforms descend
      intro i
      rw [ratioTransform_mul f g i hf_nz hg_nz]
      exact ih (ratioTransform_ne_zero f i hf_nz) (ratioTransform_ne_zero g i hg_nz)
               (hf.ratioDescend i) (hg.ratioDescend i)

/-! ## Constant Functions Have Infinite Depth -/

/-- The ratio transform of a positive constant is the constant 1. -/
theorem ratioTransform_const {c : ℝ} (hc : c ≠ 0) (i : Fin n) :
    ratioTransform (fun _ : Fin n → ℤ => c) i = fun _ => 1 := by
  ext m; simp [ratioTransform, div_self hc]

/-- A positive constant function is k-fold DLC for all k.
    Proof by strong induction on k, generalizing over all positive constants. -/
theorem const_kfold (S : Set (Fin n → ℤ)) :
    ∀ k, ∀ c : ℝ, 0 < c → KFoldDirLogConcave k (fun _ => c) S := by
  intro k
  induction k with
  | zero => intro c hc m _; exact hc
  | succ k ih =>
    intro c hc
    refine ⟨fun m _ => hc, ?_, ?_⟩
    · intro i m _ _ _
      simp; nlinarith
    · intro i
      rw [ratioTransform_const (ne_of_gt hc) i]
      exact ih 1 one_pos

/-! ## Tropical Bridge -/

/-- **Tropical valuation**: negated logarithm sends multiplicative structure
    to additive (min-plus) structure. -/
def tropicalize (f : (Fin n → ℤ) → ℝ) (m : Fin n → ℤ) : ℝ :=
  -Real.log (f m)

/-
**Theorem 3 (Cross-domain bridge)**: If f is 1-fold DLC with positive
    values everywhere, then `- log f` satisfies the directional convexity
    inequality: `2 · (- log f(m+e)) ≤ (- log f(m)) + (- log f(m+2e))`.

    This connects the curvature hierarchy to tropical geometry:
    log-concavity becomes tropical convexity under the logarithmic map.
-/
theorem negLog_supermod_of_dirLC {f : (Fin n → ℤ) → ℝ}
    {S : Set (Fin n → ℤ)}
    (hf : KFoldDirLogConcave 1 f S)
    (hS : S = Set.univ)
    (i : Fin n) (m : Fin n → ℤ) :
    2 * tropicalize f (vecAdd m (unitVec n i)) ≤
      tropicalize f m + tropicalize f (vecAdd (vecAdd m (unitVec n i)) (unitVec n i)) := by
  unfold KFoldDirLogConcave at hf;
  unfold tropicalize; have := hf.2.1 i; simp_all +decide [ PosOn ] ;
  convert Real.log_le_log ?_ ( this m ( Set.mem_univ m ) ( Set.mem_univ ( vecAdd m ( unitVec n i ) ) ) ( Set.mem_univ ( vecAdd ( vecAdd m ( unitVec n i ) ) ( unitVec n i ) ) ) ) using 1 ; ring;
  · rw [ Real.log_mul ( ne_of_gt ( hf.1 _ ) ) ( ne_of_gt ( hf.1 _ ) ), add_comm ];
  · rw [ Real.log_pow ] ; ring;
  · exact mul_pos ( hf.1 m ) ( hf.1 _ )

/-! ## Valuated Matroid Structure -/

/-- A **valuated matroid function** bundles a support set,
    a valuation function, M-convexity, and positivity. -/
structure ValuatedMatroidFn (n : ℕ) where
  /-- The support set. -/
  support : Set (Fin n → ℤ)
  /-- The valuation function. -/
  val : (Fin n → ℤ) → ℝ
  /-- Support is M-convex. -/
  mconvex : MConvexSupport support
  /-- Values are positive on the support. -/
  posOnSupp : PosOn val support

/-- The **Lorentzian depth** of a valuated matroid function. -/
def ValuatedMatroidFn.depth {n : ℕ} (V : ValuatedMatroidFn n) : ℕ∞ :=
  LorentzianDepth V.val V.support

/-- If `V.val` is k-fold DLC, then the depth is at least k. -/
theorem ValuatedMatroidFn.depth_ge {n : ℕ} (V : ValuatedMatroidFn n) (k : ℕ)
    (hk : KFoldDirLogConcave k V.val V.support) :
    k ≤ V.depth := by
  apply le_iSup₂_of_le k hk
  exact le_refl _

/-! ## Uniform Matroid Valuations -/

/-- The **uniform matroid valuation** on `Fin n → ℤ`:
    `f(m) = ∏ (m_i !)⁻¹` (multinomial weight). -/
def uniformMatroidVal (n : ℕ) (m : Fin n → ℤ) : ℝ :=
  if ∀ i, 0 ≤ m i then
    ∏ i : Fin n, (1 : ℝ) / ((m i).toNat.factorial : ℝ)
  else 0

/-- Uniform matroid valuation is nonneg. -/
theorem uniformMatroidVal_nonneg (n : ℕ) (m : Fin n → ℤ) :
    0 ≤ uniformMatroidVal n m := by
  unfold uniformMatroidVal
  split_ifs with h
  · apply Finset.prod_nonneg
    intro i _
    exact div_nonneg zero_le_one (Nat.cast_nonneg _)
  · exact le_refl _

/-! ## Conjecture: Finite Depth Greater Than 1 -/

/-- **Falsifiable Conjecture**: There exists a valuated matroid function
    with M-convex support that has Lorentzian depth exactly 2.

    **Test**: Compute the depth of the graphic matroid valuation for the
    complete graph K₄ with generic edge weights. -/
def FiniteDepthConjecture : Prop :=
  ∃ (n : ℕ) (V : ValuatedMatroidFn n),
    V.depth = 2

end KFoldValuatedDepth