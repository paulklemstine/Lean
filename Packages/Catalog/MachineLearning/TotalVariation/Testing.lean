/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Operational consequences of the sharp total-variation normalization

`MachineLearning.TotalVariation.EventSup` proved the factor-`1/2` characterization

`d_TV(p, q) = max_{A} (p(A) − q(A))`.

Here we cash it in.  Three classical pillars of statistical learning theory are
derived, each of them *tight* precisely because the normalization is the sharp
one:

1. **Le Cam's two-point bound.**  For the uniform-prior binary testing problem
   `p` vs `q`, the Bayes error of the best test is exactly `(1 − d_TV)/2`
   (`isLeast_bayesError`).  With the crude `ℓ¹` normalization one would only get
   the vacuous `(1 − ‖p − q‖₁)/2`, which is negative as soon as `‖p − q‖₁ > 1`.
2. **Data processing.**  Post-processing by an arbitrary stochastic channel — in
   particular by any deterministic feature map / statistic — cannot increase
   total variation (`tvDist_channel_le`, `tvDist_map_le`).
3. **Tensorization and sample complexity.**  `d_TV(p^{⊗n}, q^{⊗n}) ≤ n·d_TV(p, q)`
   (`tvDist_powLaw_le`), so a learner needs `n ≳ 1/d_TV` i.i.d. samples before it
   can tell the two sources apart at all (`bayesError_powLaw_ge`).

## Main results

* `bayesError_eq_half_one_add_eventGap`, `isLeast_bayesError`,
  `bayesError_ge_half_one_sub_tvDist` — Le Cam;
* `tvDist_channel_le`, `tvDist_map_le` — the data-processing inequality;
* `tvDist_prodLaw_le` — two-factor tensorization (hybrid argument);
* `tvDist_powLaw_le` — the `n`-sample bound by induction;
* `bayesError_powLaw_ge` — the resulting sample-complexity lower bound.

## Application keywords

Le Cam method, hypothesis testing, data processing inequality, tensorization,
sample complexity, indistinguishability, hybrid argument
-/

import MachineLearning.TotalVariation.EventSup

open Finset

namespace UniversalRedundancy

variable {X Y : Type*} [Fintype X] [Fintype Y]

/-! ## Le Cam's two-point bound -/

open Classical in
/-- Average error probability of the Boolean test `f` in the uniform-prior
binary testing problem "`p` versus `q`", where the output `true` means
"the sample came from `q`". -/
noncomputable def bayesError (p q : X → ℝ) (f : X → Bool) : ℝ :=
  ((∑ x ∈ univ.filter fun x => f x = true, p x)
    + ∑ x ∈ univ.filter fun x => f x = false, q x) / 2

open Classical in
/-- The error of a test is an affine function of the distinguishing gap of its
acceptance region. -/
lemma bayesError_eq_half_one_add_eventGap {p q : X → ℝ} (hq : ∑ x, q x = 1)
    (f : X → Bool) :
    bayesError p q f = (1 + eventGap p q (univ.filter fun x => f x = true)) / 2 := by
  classical
  have hsplit :
      (∑ x ∈ univ.filter fun x => f x = true, q x)
        + ∑ x ∈ univ.filter fun x => ¬ (f x = true), q x = 1 := by
    rw [Finset.sum_filter_add_sum_filter_not univ (fun x => f x = true) q, hq]
  have hfalse : (univ.filter fun x => f x = false) = univ.filter fun x => ¬ (f x = true) := by
    apply Finset.filter_congr
    intro x _
    cases f x <;> simp
  rw [bayesError, hfalse, eventGap, eventProb, eventProb]
  linarith

/-- **Le Cam's two-point lemma.**  The optimal average error probability in the
binary testing problem is exactly `(1 − d_TV(p, q))/2`: the likelihood-ratio test
attains it and nothing beats it. -/
theorem isLeast_bayesError {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1) :
    IsLeast (Set.range (bayesError p q)) ((1 - tvDist p q) / 2) := by
  classical
  constructor
  · refine ⟨fun x => decide (p x ≤ q x), ?_⟩
    rw [bayesError_eq_half_one_add_eventGap hq]
    have hA : (univ.filter fun x => (decide (p x ≤ q x)) = true) = sepEvent q p := by
      rw [sepEvent]
      apply Finset.filter_congr
      intro x _
      simp
    rw [hA, ← eventGap_neg, eventGap_sepEvent hq hp, tvDist_comm q p]
    ring
  · rintro r ⟨f, rfl⟩
    rw [bayesError_eq_half_one_add_eventGap hq]
    have hbd := abs_eventGap_le_tvDist hp hq (univ.filter fun x => f x = true)
    have := neg_le_of_abs_le hbd
    linarith

/-- Indistinguishability: if two sources are `ε`-close in total variation then
*every* test confuses them with probability at least `(1 − ε)/2`. -/
theorem bayesError_ge_half_one_sub_tvDist {p q : X → ℝ} (hp : ∑ x, p x = 1)
    (hq : ∑ x, q x = 1) (f : X → Bool) :
    (1 - tvDist p q) / 2 ≤ bayesError p q f :=
  (isLeast_bayesError hp hq).2 ⟨f, rfl⟩

/-! ## The data-processing inequality -/

/-- Push-forward of the law `p` through the stochastic channel `K`. -/
def channelPush (p : X → ℝ) (K : X → Y → ℝ) : Y → ℝ := fun y => ∑ x, p x * K x y

lemma sum_channelPush {p : X → ℝ} (hp : ∑ x, p x = 1) {K : X → Y → ℝ}
    (hK : ∀ x, ∑ y, K x y = 1) : ∑ y, channelPush p K y = 1 := by
  simp only [channelPush]
  rw [Finset.sum_comm]
  rw [Finset.sum_congr rfl fun x _ => by rw [← Finset.mul_sum, hK x, mul_one]]
  exact hp

/-- **Data-processing inequality.**  No stochastic post-processing can increase
the total variation distance: information about the source can only be lost. -/
theorem tvDist_channel_le (p q : X → ℝ) {K : X → Y → ℝ} (hK0 : ∀ x y, 0 ≤ K x y)
    (hK : ∀ x, ∑ y, K x y = 1) :
    tvDist (channelPush p K) (channelPush q K) ≤ tvDist p q := by
  have key : ∑ y, |channelPush p K y - channelPush q K y| ≤ ∑ x, |p x - q x| := by
    calc ∑ y, |channelPush p K y - channelPush q K y|
        = ∑ y, |∑ x, (p x - q x) * K x y| := by
          refine Finset.sum_congr rfl fun y _ => ?_
          congr 1
          rw [channelPush, channelPush, ← Finset.sum_sub_distrib]
          exact Finset.sum_congr rfl fun x _ => by ring
      _ ≤ ∑ y, ∑ x, |p x - q x| * K x y := by
          refine Finset.sum_le_sum fun y _ => ?_
          refine le_trans (Finset.abs_sum_le_sum_abs _ _) (Finset.sum_le_sum fun x _ => ?_)
          rw [abs_mul, abs_of_nonneg (hK0 x y)]
      _ = ∑ x, |p x - q x| := by
          rw [Finset.sum_comm]
          refine Finset.sum_congr rfl fun x _ => ?_
          rw [← Finset.mul_sum, hK x, mul_one]
  unfold tvDist
  linarith

/-- Deterministic special case: the law of any statistic `T x` of the sample is
at most as informative as the sample itself. -/
theorem tvDist_map_le [DecidableEq Y] (p q : X → ℝ) (T : X → Y) :
    tvDist (fun y => ∑ x ∈ univ.filter fun x => T x = y, p x)
      (fun y => ∑ x ∈ univ.filter fun x => T x = y, q x) ≤ tvDist p q := by
  classical
  set K : X → Y → ℝ := fun x y => if T x = y then 1 else 0 with hKdef
  have hK0 : ∀ x y, 0 ≤ K x y := by
    intro x y; by_cases h : T x = y <;> simp [hKdef, h]
  have hK : ∀ x, ∑ y, K x y = 1 := by
    intro x
    simp [hKdef]
  have hpush : ∀ r : X → ℝ, channelPush r K
      = fun y => ∑ x ∈ univ.filter fun x => T x = y, r x := by
    intro r
    funext y
    rw [channelPush, Finset.sum_filter]
    exact Finset.sum_congr rfl fun x _ => by by_cases h : T x = y <;> simp [hKdef, h]
  have := tvDist_channel_le p q hK0 hK
  rwa [hpush p, hpush q] at this

/-! ## Tensorization -/

/-- Product law on `X × Y`. -/
def prodLaw (p : X → ℝ) (r : Y → ℝ) : X × Y → ℝ := fun z => p z.1 * r z.2

lemma sum_prodLaw {p : X → ℝ} {r : Y → ℝ} (hp : ∑ x, p x = 1) (hr : ∑ y, r y = 1) :
    ∑ z, prodLaw p r z = 1 := by
  rw [Fintype.sum_prod_type]
  rw [Finset.sum_congr rfl fun x _ => by
    simpa [prodLaw] using (by rw [← Finset.mul_sum, hr, mul_one] :
      ∑ y, p x * r y = p x)]
  exact hp

/-- **Tensorization (hybrid argument).**  Total variation is subadditive over
independent components. -/
theorem tvDist_prodLaw_le {p₁ q₁ : X → ℝ} {p₂ q₂ : Y → ℝ}
    (hq₁0 : ∀ x, 0 ≤ q₁ x) (hq₁ : ∑ x, q₁ x = 1)
    (hp₂0 : ∀ y, 0 ≤ p₂ y) (hp₂ : ∑ y, p₂ y = 1) :
    tvDist (prodLaw p₁ p₂) (prodLaw q₁ q₂) ≤ tvDist p₁ q₁ + tvDist p₂ q₂ := by
  have key : ∑ z, |prodLaw p₁ p₂ z - prodLaw q₁ q₂ z|
      ≤ (∑ x, |p₁ x - q₁ x|) + ∑ y, |p₂ y - q₂ y| := by
    calc ∑ z, |prodLaw p₁ p₂ z - prodLaw q₁ q₂ z|
        = ∑ x, ∑ y, |p₁ x * p₂ y - q₁ x * q₂ y| := by
          rw [Fintype.sum_prod_type]; rfl
      _ ≤ ∑ x, ∑ y, (|p₁ x - q₁ x| * p₂ y + q₁ x * |p₂ y - q₂ y|) := by
          refine Finset.sum_le_sum fun x _ => Finset.sum_le_sum fun y _ => ?_
          have hsplit : p₁ x * p₂ y - q₁ x * q₂ y
              = (p₁ x - q₁ x) * p₂ y + q₁ x * (p₂ y - q₂ y) := by ring
          rw [hsplit]
          refine le_trans (abs_add_le _ _) ?_
          rw [abs_mul, abs_mul, abs_of_nonneg (hp₂0 y), abs_of_nonneg (hq₁0 x)]
      _ = (∑ x, |p₁ x - q₁ x|) + ∑ y, |p₂ y - q₂ y| := by
          have h1 : ∀ x : X, ∑ y, (|p₁ x - q₁ x| * p₂ y + q₁ x * |p₂ y - q₂ y|)
              = |p₁ x - q₁ x| + q₁ x * ∑ y, |p₂ y - q₂ y| := by
            intro x
            rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum, hp₂, mul_one]
          rw [Finset.sum_congr rfl fun x _ => h1 x, Finset.sum_add_distrib,
            ← Finset.sum_mul, hq₁, one_mul]
  unfold tvDist
  linarith

/-! ## `n` i.i.d. samples -/

/-- The `n`-fold product law: the law of `n` i.i.d. samples from `p`. -/
def powLaw (p : X → ℝ) (n : ℕ) : (Fin n → X) → ℝ := fun v => ∏ i, p (v i)

omit [Fintype X] in
lemma powLaw_nonneg {p : X → ℝ} (hp0 : ∀ x, 0 ≤ p x) (n : ℕ) (v : Fin n → X) :
    0 ≤ powLaw p n v :=
  Finset.prod_nonneg fun i _ => hp0 (v i)

omit [Fintype X] in
/-- Decomposing `n + 1` samples into "first sample" and "the rest". -/
lemma powLaw_succ (p : X → ℝ) (n : ℕ) (z : X × (Fin n → X)) :
    powLaw p (n + 1) (Fin.consEquiv (fun _ => X) z) = prodLaw p (powLaw p n) z := by
  obtain ⟨a, v⟩ := z
  simp [powLaw, prodLaw, Fin.consEquiv, Fin.prod_univ_succ]

lemma sum_powLaw {p : X → ℝ} (hp : ∑ x, p x = 1) : ∀ n, ∑ v, powLaw p n v = 1 := by
  intro n
  induction n with
  | zero => simp [powLaw]
  | succ n ih =>
      have hEq : ∑ v, powLaw p (n + 1) v
          = ∑ z : X × (Fin n → X), prodLaw p (powLaw p n) z := by
        rw [← Equiv.sum_comp (Fin.consEquiv (fun _ => X)) (powLaw p (n + 1))]
        exact Finset.sum_congr rfl fun z _ => powLaw_succ p n z
      rw [hEq]
      exact sum_prodLaw hp ih

/-- Total variation is invariant under relabelling the sample space. -/
lemma tvDist_equiv_comp {Z : Type*} [Fintype Z] (e : Z ≃ X) (p q : X → ℝ) :
    tvDist (fun z => p (e z)) (fun z => q (e z)) = tvDist p q := by
  unfold tvDist
  rw [Equiv.sum_comp e fun x => |p x - q x|]

/-- **`n`-sample bound.**  Repeated independent sampling amplifies the
distinguishing advantage at most linearly: `d_TV(p^{⊗n}, q^{⊗n}) ≤ n·d_TV(p, q)`.
This is the total-variation form of the hybrid argument. -/
theorem tvDist_powLaw_le {p q : X → ℝ} (hp0 : ∀ x, 0 ≤ p x) (hp : ∑ x, p x = 1)
    (hq0 : ∀ x, 0 ≤ q x) (hq : ∑ x, q x = 1) :
    ∀ n : ℕ, tvDist (powLaw p n) (powLaw q n) ≤ n * tvDist p q := by
  intro n
  induction n with
  | zero => simp [powLaw, tvDist]
  | succ n ih =>
      have hEq : ∀ r : X → ℝ, (fun z : X × (Fin n → X) =>
          powLaw r (n + 1) (Fin.consEquiv (fun _ => X) z)) = prodLaw r (powLaw r n) := by
        intro r; funext z; exact powLaw_succ r n z
      have hstep : tvDist (powLaw p (n + 1)) (powLaw q (n + 1))
          = tvDist (prodLaw p (powLaw p n)) (prodLaw q (powLaw q n)) := by
        rw [← tvDist_equiv_comp (Fin.consEquiv (fun _ => X)) (powLaw p (n + 1))
          (powLaw q (n + 1)), hEq p, hEq q]
      have hbound := tvDist_prodLaw_le (p₁ := p) (q₁ := q)
        (p₂ := powLaw p n) (q₂ := powLaw q n) hq0 hq (powLaw_nonneg hp0 n) (sum_powLaw hp n)
      rw [hstep]
      have : tvDist p q + tvDist (powLaw p n) (powLaw q n) ≤ tvDist p q + n * tvDist p q := by
        linarith
      have hcast : ((n : ℝ) + 1) * tvDist p q = tvDist p q + n * tvDist p q := by ring
      push_cast
      linarith

/-- **Sample-complexity lower bound (Le Cam's method).**  After `n` i.i.d.
samples the Bayes error of *any* test is still at least `(1 − n·d_TV(p, q))/2`;
so distinguishing the two sources with constant confidence needs
`n = Ω(1 / d_TV(p, q))` samples. -/
theorem bayesError_powLaw_ge {p q : X → ℝ} (hp0 : ∀ x, 0 ≤ p x) (hp : ∑ x, p x = 1)
    (hq0 : ∀ x, 0 ≤ q x) (hq : ∑ x, q x = 1) (n : ℕ) (f : (Fin n → X) → Bool) :
    (1 - n * tvDist p q) / 2 ≤ bayesError (powLaw p n) (powLaw q n) f := by
  have h1 := bayesError_ge_half_one_sub_tvDist (sum_powLaw hp n) (sum_powLaw hq n) f
  have h2 := tvDist_powLaw_le hp0 hp hq0 hq n
  linarith

end UniversalRedundancy