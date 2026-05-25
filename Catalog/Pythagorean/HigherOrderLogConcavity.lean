/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Higher-Order Log-Concavity and Partition Functions

This file introduces a **hierarchy of discrete log-concavity** indexed by depth,
connecting recursive Lorentzian polynomial structure to quantitative combinatorial
and statistical-mechanical properties of coefficient sequences.

## Mathematical Overview

Ordinary log-concavity asks that `a(n)² ≥ a(n-1) · a(n+1)` for a sequence.
We define **k-fold log-concavity** recursively: a positive sequence is
`(k+1)`-fold log-concave if it is log-concave and its ratio sequence
`r(n) = a(n+1)/a(n)` is `k`-fold log-concave. This creates a filtration:

  `1-fold ⊃ 2-fold ⊃ 3-fold ⊃ ⋯`

where each level imposes strictly stronger constraints.

## Main Results

* `KFoldLogConcave.ratio` — Higher-order log-concavity descends to ratio sequences
* `KFoldLogConcave.logConcave` — k-fold log-concave sequences are log-concave
* `KFoldLogConcave.iterRatio_logConcave` — All iterated ratios are log-concave
* `KFoldLogConcave.iterRatio_positive` — All iterated ratios are positive
* `ratioSeq_mul` — Ratio of a product is the product of ratios
* `KFoldLogConcave.mul` — Product of k-fold log-concave sequences is k-fold log-concave
* `geometric_kFoldLogConcave` — Geometric sequences are k-fold log-concave for all k
* `kFoldLogConcave_mono` — Higher depth implies lower depth

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Anari–Liu–Oveis Gharan–Vinzant, "Log-Concave Polynomials", 2019
-/

noncomputable section

/-! ## Core Definitions -/

/-- A sequence `a : ℕ → ℝ` is **positive** if every term is strictly positive. -/
def PositiveSeq (a : ℕ → ℝ) : Prop :=
  ∀ n, 0 < a n

/-- A sequence `a : ℕ → ℝ` is **log-concave** (in the infinite-support sense) if
    for every `n`, we have `a(n+1)² ≥ a(n) · a(n+2)`. -/
def LogConcaveN (a : ℕ → ℝ) : Prop :=
  ∀ n, a (n + 1) ^ 2 ≥ a n * a (n + 2)

/-- The **ratio sequence** of `a`: `RatioSeq a n = a(n+1) / a(n)`. -/
def RatioSeq (a : ℕ → ℝ) : ℕ → ℝ :=
  fun n => a (n + 1) / a n

/-- **k-fold log-concavity**: a recursive definition capturing depth of concavity.
    - 0-fold: the sequence is positive
    - (k+1)-fold: the sequence is positive, log-concave, and its ratio sequence
      is k-fold log-concave -/
def KFoldLogConcave : ℕ → (ℕ → ℝ) → Prop
  | 0, a => PositiveSeq a
  | k + 1, a => PositiveSeq a ∧ LogConcaveN a ∧ KFoldLogConcave k (RatioSeq a)

/-- The **iterated ratio** operator: apply `RatioSeq` m times. -/
def IterRatio : ℕ → (ℕ → ℝ) → (ℕ → ℝ)
  | 0, a => a
  | m + 1, a => RatioSeq (IterRatio m a)

/-! ## Basic Lemmas about Ratio Sequences -/

/-- The ratio sequence of a positive sequence is positive. -/
theorem ratioSeq_positive {a : ℕ → ℝ} (ha : PositiveSeq a) :
    PositiveSeq (RatioSeq a) := by
  intro n
  exact div_pos (ha (n + 1)) (ha n)

/-- Key algebraic identity: the ratio sequence of a pointwise product is the
    pointwise product of the ratio sequences.
    `(a·b)(n+1) / (a·b)(n) = (a(n+1)/a(n)) · (b(n+1)/b(n))` -/
theorem ratioSeq_mul {a b : ℕ → ℝ} (_ha : PositiveSeq a) (_hb : PositiveSeq b) :
    RatioSeq (fun n => a n * b n) = fun n => RatioSeq a n * RatioSeq b n := by
  ext n
  simp only [RatioSeq]
  rw [mul_div_mul_comm]

/-! ## Structural Theorems on the Hierarchy -/

/-- **Theorem 1: Higher-order log-concavity descends recursively.**
    If `a` is `(k+1)`-fold log-concave, then its ratio sequence is
    `k`-fold log-concave. -/
theorem KFoldLogConcave.ratio
    {k : ℕ} {a : ℕ → ℝ}
    (hk : KFoldLogConcave (k + 1) a) :
    KFoldLogConcave k (RatioSeq a) :=
  hk.2.2

/-- Extracting positivity from k-fold log-concavity. -/
theorem KFoldLogConcave.positive
    {k : ℕ} {a : ℕ → ℝ}
    (hk : KFoldLogConcave k a) :
    PositiveSeq a := by
  cases k with
  | zero => exact hk
  | succ k => exact hk.1

/-- `(k+1)`-fold log-concavity implies log-concavity at the top level. -/
theorem KFoldLogConcave.logConcave
    {k : ℕ} {a : ℕ → ℝ}
    (hk : KFoldLogConcave (k + 1) a) :
    LogConcaveN a :=
  hk.2.1

/-- All iterated ratio sequences of a k-fold log-concave sequence are positive. -/
theorem KFoldLogConcave.iterRatio_positive
    {k : ℕ} {a : ℕ → ℝ}
    (hk : KFoldLogConcave k a) :
    ∀ m, m ≤ k → PositiveSeq (IterRatio m a) := by
  intro m hm
  induction m with
  | zero => exact hk.positive
  | succ m ih =>
    simp only [IterRatio]
    exact ratioSeq_positive (ih (by omega))

/-
Extracting KFoldLogConcave at a deeper level of the iteration.
    If `a` is `k`-fold log-concave and `m ≤ k`, then `IterRatio m a` is
    `(k - m)`-fold log-concave.
-/
theorem KFoldLogConcave.iterRatio_kfold
    {k : ℕ} {a : ℕ → ℝ}
    (hk : KFoldLogConcave k a) :
    ∀ m, m ≤ k → KFoldLogConcave (k - m) (IterRatio m a) := by
  intro m hm;
  induction' m with m ih generalizing a;
  · exact hk;
  · convert KFoldLogConcave.ratio _ using 1;
    grind +qlia

/-
**Theorem 2: Higher-order log-concavity implies log-concavity at every lower level.**
    If `a` is `k`-fold log-concave and `m + 1 ≤ k`, then `IterRatio m a` is log-concave.
    This shows higher-order log-concavity is a full tower of compatible
    concavity constraints.
-/
theorem KFoldLogConcave.iterRatio_logConcave
    {k m : ℕ} {a : ℕ → ℝ}
    (hk : KFoldLogConcave k a)
    (hm : m + 1 ≤ k) :
    LogConcaveN (IterRatio m a) := by
  -- Using the KFoldLogConcave.iterRatio_kfold lemma, we know that `IterRatio m a` is `(k - m)`-fold log-concave.
  have h_iter_pure : KFoldLogConcave (k - m) (IterRatio m a) := by
    exact KFoldLogConcave.iterRatio_kfold hk m ( Nat.le_of_succ_le hm );
  rcases n : k - m with ( _ | _ | k ) <;> simp_all +decide [ KFoldLogConcave ];
  omega

/-
Higher depth implies lower depth: `k`-fold log-concave implies `j`-fold
    log-concave for any `j ≤ k`.
-/
theorem kFoldLogConcave_mono
    {j k : ℕ} {a : ℕ → ℝ}
    (hk : KFoldLogConcave k a)
    (hjk : j ≤ k) :
    KFoldLogConcave j a := by
  induction' k with k ih generalizing a j;
  · grind;
  · rcases hjk <;> simp_all +decide [ KFoldLogConcave ];
    rcases j with ( _ | j ) <;> simp_all +decide [ KFoldLogConcave ];
    exact ih hk.2.2 ( by linarith )

/-! ## Product Stability -/

/-
**Log-concavity of products**: if `a` and `b` are positive log-concave
    sequences, then their pointwise product is log-concave.
-/
theorem logConcaveN_mul {a b : ℕ → ℝ}
    (ha_pos : PositiveSeq a) (hb_pos : PositiveSeq b)
    (ha_lc : LogConcaveN a) (hb_lc : LogConcaveN b) :
    LogConcaveN (fun n => a n * b n) := by
  intro n
  nlinarith [ha_lc n, hb_lc n, mul_pos (ha_pos n) (ha_pos (n + 1)),
    mul_pos (ha_pos n) (ha_pos (n + 2)), mul_pos (hb_pos n) (hb_pos (n + 1)),
    mul_pos (hb_pos n) (hb_pos (n + 2))]

/-
**Theorem 4: Product stability for higher-order log-concavity.**
    If `a` and `b` are positive `k`-fold log-concave sequences, then their
    pointwise product is `k`-fold log-concave.

    The proof proceeds by induction on `k`, using:
    - the base case: positivity of the product
    - `ratioSeq_mul`: the ratio of a product equals the product of ratios
    - the inductive step: apply the hypothesis to the ratio sequences
-/
theorem KFoldLogConcave.mul
    {k : ℕ} {a b : ℕ → ℝ}
    (ha : KFoldLogConcave k a)
    (hb : KFoldLogConcave k b) :
    KFoldLogConcave k (fun n => a n * b n) := by
  induction' k with k ih generalizing a b;
  · exact fun n => mul_pos ( ha n ) ( hb n );
  · exact ⟨ fun n => mul_pos ( ha.1 n ) ( hb.1 n ), logConcaveN_mul ha.1 hb.1 ha.2.1 hb.2.1, by simpa only [ ratioSeq_mul ha.1 hb.1 ] using ih ha.2.2 hb.2.2 ⟩

/-! ## Model Families -/

/-- A **geometric sequence** `a(n) = c · r^n` with `c > 0` and `r > 0`. -/
def GeometricSeq (c r : ℝ) : ℕ → ℝ := fun n => c * r ^ n

/-
The ratio sequence of a geometric sequence is constant.
-/
theorem ratioSeq_geometric {c r : ℝ} (hc : 0 < c) (hr : 0 < r) :
    RatioSeq (GeometricSeq c r) = fun _ => r := by
  exact funext fun x => by unfold RatioSeq GeometricSeq; rw [ div_eq_iff ( by positivity ) ] ; ring;

/-
Geometric sequences are positive when both parameters are positive.
-/
theorem geometricSeq_positive {c r : ℝ} (hc : 0 < c) (hr : 0 < r) :
    PositiveSeq (GeometricSeq c r) := by
  -- Since $c > 0$ and $r > 0$, for any $n$, $c * r^n > 0$.
  intro n
  apply mul_pos hc (pow_pos hr n)

/-
**Geometric sequences are k-fold log-concave for all k.**
    Because the ratio sequence of `c·r^n` is the constant `r`, and constant
    positive sequences are trivially k-fold log-concave at every depth.
-/
theorem geometric_kFoldLogConcave {k : ℕ} {c r : ℝ} (hc : 0 < c) (hr : 0 < r) :
    KFoldLogConcave k (GeometricSeq c r) := by
  induction' k with k ih generalizing c r;
  · exact fun n => mul_pos hc ( pow_pos hr _ );
  · refine' ⟨ _, _, _ ⟩;
    · exact geometricSeq_positive hc hr;
    · exact fun n => by unfold GeometricSeq; ring_nf; norm_num;
    · rw [ ratioSeq_geometric hc hr ];
      convert ih hr zero_lt_one using 1 ; ext ; norm_num [ GeometricSeq ]

/-! ## Bridge to Lorentzian Structure -/

/-- A **recursive Lorentzian sequence** bundles a coefficient sequence with
    its depth certificate. -/
structure RecursiveLorentzianSequence where
  /-- The coefficient sequence -/
  coeff : ℕ → ℝ
  /-- The depth of the Lorentzian certificate -/
  depth : ℕ
  /-- All coefficients are positive -/
  pos : PositiveSeq coeff
  /-- The sequence is k-fold log-concave at the certified depth -/
  kfold : KFoldLogConcave depth coeff

/-- **Independent subsystems preserve higher-order concavity.**
    Partition function factorization theorem. -/
theorem partitionFunctionCoeff_kFoldLogConcave_of_factorization
    {k : ℕ} {a b : ℕ → ℝ}
    (ha : KFoldLogConcave k a)
    (hb : KFoldLogConcave k b) :
    KFoldLogConcave k (fun n => a n * b n) :=
  KFoldLogConcave.mul ha hb

/-- **Product of RecursiveLorentzianSequences at the same depth.** -/
def RecursiveLorentzianSequence.product
    (s₁ s₂ : RecursiveLorentzianSequence)
    (hd : s₁.depth = s₂.depth) :
    RecursiveLorentzianSequence where
  coeff := fun n => s₁.coeff n * s₂.coeff n
  depth := s₁.depth
  pos := fun n => mul_pos (s₁.pos n) (s₂.pos n)
  kfold := KFoldLogConcave.mul s₁.kfold (hd ▸ s₂.kfold)

end