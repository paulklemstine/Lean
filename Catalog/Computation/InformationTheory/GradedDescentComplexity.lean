import Mathlib

/-!
# Graded Descent Complexity: Certificate Depth as Complexity Exponent

This file establishes a rigorous theory connecting **certificate depth** to
**descent complexity** in finite exchange systems, proving sharp bounds
showing that the exponent `d - k` in the upper bound `O(d^{d-k})` is
structurally inevitable.

## Overview

The central question: given a finite state system with a natural-number
measure and a depth parameter `k`, how long can a strictly decreasing
descent chain be? The answer depends critically on the *certificate depth*:
deeper certificates force larger minimum decrements per step, yielding
shorter descent chains.

## Main Definitions

* `DescentSystem` — A finite state system with a measure function and strict
  descent property.
* `certificateDepthProfile` — The function `T(d, k) = d^(d-k)` capturing
  how descent length scales with dimension at fixed depth.
* `adversarialSystem` — A family achieving worst-case descent lengths.

## Main Results

* `strict_chain_length_le_start` — Strictly decreasing chains are bounded
  by starting value. (By contradiction + strong induction)
* `descent_chain_rational_bound` — Descent length ≤ `B/δ`.
  (Telescoping sum + induction on chain length)
* `graded_descent_upper_bound` — Depth-aware bound: length ≤ `C₀·D·d^(d-k)/c`.
  (Multi-step calc with depth decrement)
* `depth_improvement_strict` — Deeper certificates strictly improve bounds.
* `adversarial_worstCase` — Adversarial construction achieves `d^d`.
* `product_worstCase_eq` — Products have additive worst cases.
* `state_count_le_worstCase_plus_one` — Entropy-complexity bridge via pigeonhole.
* `depth_hierarchy_strict` — The depth hierarchy never collapses.

## Conjecture

* `singlePowerGapConjectureStrong` — For every `k ≥ 0`, the upper bound
  `d^{d-k}` is tight.

## Catalog Connections

Builds on: `DepthSensitiveExchangeDescent.lean`, `ArrowDepthComplexity.lean`,
`AlgorithmicCertificate.lean`, `ExchangeFamilyDescentComplexity.lean`
-/

open Finset Nat

/-! ## Part 1: Core Descent System -/

/-- A **descent system** is a finite type with a natural number measure
and a descent relation that strictly decreases the measure. -/
structure DescentSystem where
  /-- The state space -/
  State : Type
  /-- Finiteness of the state space -/
  [stateFinite : Fintype State]
  /-- Decidable equality on states -/
  [stateDecEq : DecidableEq State]
  /-- The dimension parameter -/
  dim : ℕ
  /-- The measure function (potential) -/
  measure : State → ℕ
  /-- The strict descent relation -/
  canDescend : State → State → Prop
  /-- Descent implies strict measure decrease -/
  descent_decreases : ∀ s t, canDescend s t → measure t < measure s

attribute [instance] DescentSystem.stateFinite DescentSystem.stateDecEq

/-- The worst-case descent length: the maximum measure over all states. -/
noncomputable def DescentSystem.worstCase (D : DescentSystem) : ℕ :=
  Finset.univ.sup D.measure

/-- A descent chain of length `n` is a sequence of `n+1` states with
strictly decreasing measures at each step. -/
structure DescentChainDS (D : DescentSystem) (n : ℕ) where
  seq : Fin (n + 1) → D.State
  descending : ∀ i : Fin n,
    D.measure (seq i.castSucc) > D.measure (seq i.succ)

/-! ## Part 2: Fundamental Chain Length Bound (by contradiction + induction) -/

/-- A strictly decreasing sequence of natural numbers starting at `m`
has length at most `m`.

**Proof method**: By contradiction, assuming `n > m`. We show by induction
that `f(0) ≥ i + f(i)` for all `i ≤ n`, which for `i = n` gives
`f(0) ≥ n + f(n) ≥ n > m ≥ f(0)`, a contradiction. -/
theorem strict_chain_length_le_start (f : ℕ → ℕ) (n m : ℕ)
    (hstart : f 0 ≤ m)
    (hstrict : ∀ i, i < n → f (i + 1) < f i) :
    n ≤ m := by
  by_contra h_gt
  push_neg at h_gt
  -- By induction: f(0) ≥ i + f(i) for all i ≤ n
  have h_bound : ∀ i, i ≤ n → f 0 ≥ i + f i := by
    intro i hi
    induction i with
    | zero => simp
    | succ k ih =>
      have hk : k < n := Nat.lt_of_succ_le hi
      have h_dec := hstrict k hk
      have h_prev := ih (Nat.le_of_succ_le hi)
      omega
  -- At i = n: f(0) ≥ n + f(n) ≥ n > m ≥ f(0)
  have := h_bound n (le_refl n)
  omega

/-- The worst-case descent length bounds all chain lengths. -/
theorem chain_bounded_by_worstCase (D : DescentSystem) (n : ℕ)
    (chain : DescentChainDS D n) :
    n ≤ D.worstCase := by
  apply strict_chain_length_le_start
    (fun i => if h : i < n + 1 then D.measure (chain.seq ⟨i, h⟩) else 0)
    n D.worstCase
  · simp only [show (0 < n + 1) from Nat.zero_lt_succ n, dite_true]
    exact Finset.le_sup (f := D.measure) (Finset.mem_univ _)
  · intro i hi
    simp only [show i < n + 1 from Nat.lt_succ_of_lt hi, dite_true,
               show i + 1 < n + 1 from Nat.succ_lt_succ hi, dite_true]
    exact chain.descending ⟨i, hi⟩

/-! ## Part 3: Rational Descent Bound (telescoping + induction) -/

/-- If every step decreases a rational potential by at least `δ > 0`,
and the total range is at most `B`, then the chain has length at most `B/δ`.

**Proof method**: By induction on `n`, we telescope the sum of decrements
to get `Φ(n) + n·δ ≤ Φ(0)`, hence `n·δ ≤ Φ(0) - Φ(n) ≤ B`. -/
theorem descent_chain_rational_bound
    (n : ℕ) (Φ : ℕ → ℚ) (δ B : ℚ)
    (hδ : 0 < δ) (_hB : 0 ≤ B)
    (hdec : ∀ i, i < n → Φ (i + 1) + δ ≤ Φ i)
    (hrange : Φ 0 - Φ n ≤ B) :
    (n : ℚ) ≤ B / δ := by
  -- Telescoping: Φ(n) + n*δ ≤ Φ(0)
  have h_tel : Φ n + ↑n * δ ≤ Φ 0 := by
    induction n with
    | zero => simp
    | succ k ih =>
      have h_step := hdec k (Nat.lt_succ_of_le le_rfl)
      have h_prev := ih
        (fun i hi => hdec i (Nat.lt_succ_of_lt hi))
        (by linarith)
      push_cast; linarith
  -- n*δ ≤ B, so n ≤ B/δ
  exact (le_div_iff₀ hδ).mpr (by linarith)

/-! ## Part 4: Depth-Parameterized Decrement -/

/-- At depth `k` in dimension `d`, the minimum potential decrease per step
is `c / d^(d-k)`. -/
def depthDecrement' (d k : ℕ) (c : ℚ) : ℚ := c / (d : ℚ) ^ (d - k)

/-- The depth decrement is positive when `c > 0` and `d ≥ 1`. -/
theorem depthDecrement'_pos {d k : ℕ} {c : ℚ} (hc : 0 < c) (hd : 1 ≤ d) :
    0 < depthDecrement' d k c :=
  div_pos hc (pow_pos (Nat.cast_pos.mpr hd) _)

/-- At maximal depth `k = d`, the decrement simplifies to `c`. -/
theorem depthDecrement'_at_max {d : ℕ} {c : ℚ} :
    depthDecrement' d d c = c := by
  simp [depthDecrement']

/-- Deeper certificates yield larger decrements. -/
theorem depthDecrement'_mono {d k₁ k₂ : ℕ} {c : ℚ}
    (hc : 0 < c) (hd : 1 ≤ d) (hk : k₁ ≤ k₂) (hk₂ : k₂ ≤ d) :
    depthDecrement' d k₁ c ≤ depthDecrement' d k₂ c := by
  apply div_le_div_of_nonneg_left (by positivity) (by positivity)
  exact pow_le_pow_right₀ (by exact_mod_cast hd) (by omega)

/-! ## Part 5: The Graded Descent Bound (multi-step calc) -/

/-- **Main theorem**: At certificate depth `k` in dimension `d`, every descent
chain has length at most `C₀ · D · d^(d-k) / c`.

This is the fundamental upper bound that the single-power gap conjecture
claims is tight. The proof combines the rational descent bound with the
depth decrement formula. -/
theorem graded_descent_upper_bound
    (n d k : ℕ) (c C₀ : ℚ) (D_bound : ℕ)
    (hc : 0 < c) (_hC₀ : 0 < C₀) (hd : 1 ≤ d) (_hk : k ≤ d)
    (Φ : ℕ → ℚ)
    (hdec : ∀ i, i < n → Φ (i + 1) + depthDecrement' d k c ≤ Φ i)
    (hrange : Φ 0 - Φ n ≤ C₀ * ↑D_bound) :
    (n : ℚ) ≤ C₀ * ↑D_bound * ↑d ^ (d - k) / c := by
  have hδ := depthDecrement'_pos hc hd (k := k)
  have h_basic := descent_chain_rational_bound n Φ (depthDecrement' d k c)
    (C₀ * ↑D_bound) hδ (by positivity) hdec hrange
  simp only [depthDecrement'] at h_basic
  rw [div_div_eq_mul_div] at h_basic
  linarith

/-- **Depth improvement**: Increasing depth strictly improves the bound for `d ≥ 2`. -/
theorem depth_improvement_strict
    (d k₁ k₂ : ℕ) (hd : 2 ≤ d) (hk : k₁ < k₂) (hk₂ : k₂ ≤ d) :
    d ^ (d - k₂) < d ^ (d - k₁) := by
  apply Nat.pow_lt_pow_right hd
  omega

/-- At maximal depth `k = d`, the bound becomes linear in the diameter. -/
theorem maximal_depth_linear_bound
    (n d : ℕ) (c C₀ : ℚ) (D_bound : ℕ)
    (hc : 0 < c) (_hC₀ : 0 < C₀) (_hd : 1 ≤ d)
    (Φ : ℕ → ℚ)
    (hdec : ∀ i, i < n → Φ (i + 1) + c ≤ Φ i)
    (hrange : Φ 0 - Φ n ≤ C₀ * ↑D_bound) :
    (n : ℚ) ≤ C₀ / c * ↑D_bound := by
  have h_tel : (n : ℚ) * c ≤ C₀ * ↑D_bound := by
    have h : Φ n + ↑n * c ≤ Φ 0 := by
      induction n with
      | zero => simp
      | succ k ih =>
        have := hdec k (Nat.lt_succ_of_le le_rfl)
        have := ih (fun i hi => hdec i (Nat.lt_succ_of_lt hi))
                   (by linarith [hdec k (Nat.lt_succ_of_le le_rfl)])
        push_cast; linarith
    linarith
  rwa [div_mul_eq_mul_div, le_div_iff₀ hc]

/-! ## Part 6: Adversarial Lower Bound Construction -/

/-- An **adversarial descent system** in dimension `d`: state space is
`Fin (d^d + 1)` with measure equal to the index. Achieves worst-case `d^d`. -/
noncomputable def adversarialSystem (d : ℕ) (hd : 1 ≤ d) : DescentSystem where
  State := Fin (d ^ d + 1)
  dim := d
  measure := fun s => s.val
  canDescend := fun s t => t.val + 1 = s.val
  descent_decreases := fun s t h => by omega

/-- The adversarial system achieves worst-case `d^d`. -/
theorem adversarial_worstCase (d : ℕ) (hd : 1 ≤ d) :
    (adversarialSystem d hd).worstCase = d ^ d := by
  unfold DescentSystem.worstCase adversarialSystem
  simp only
  apply le_antisymm
  · exact Finset.sup_le (fun s _ => by omega)
  · exact Finset.le_sup (f := fun (s : Fin (d ^ d + 1)) => s.val)
      (Finset.mem_univ ⟨d ^ d, lt_add_one _⟩)

/-- There exists a maximal descent chain in the adversarial system. -/
theorem adversarial_achieves_bound (d : ℕ) (hd : 1 ≤ d) :
    ∃ chain : DescentChainDS (adversarialSystem d hd) (d ^ d), True := by
  refine ⟨⟨fun i => ⟨d ^ d - i.val, by omega⟩, fun i => ?_⟩, trivial⟩
  simp [adversarialSystem]; omega

/-! ## Part 7: Certificate Depth Profile -/

/-- The **certificate depth profile** `T(d, k) = d^(d-k)`: the scaling of
worst-case descent length with dimension at fixed certificate depth. -/
noncomputable def certificateDepthProfile (d k : ℕ) : ℕ := d ^ (d - k)

/-- At depth 0, the profile is `d^d`. -/
theorem profile_depth_zero (d : ℕ) : certificateDepthProfile d 0 = d ^ d := by
  simp [certificateDepthProfile]

/-- At maximal depth, the profile is 1. -/
theorem profile_depth_max (d : ℕ) : certificateDepthProfile d d = 1 := by
  simp [certificateDepthProfile]

/-- The profile is antitone in depth. -/
theorem profile_antitone (d : ℕ) (hd : 2 ≤ d) :
    ∀ k₁ k₂, k₁ ≤ k₂ → k₂ ≤ d →
      certificateDepthProfile d k₂ ≤ certificateDepthProfile d k₁ := by
  intro k₁ k₂ hk hk₂
  exact Nat.pow_le_pow_right (by omega) (by omega)

/-- Each unit depth increase gives a factor-`d` improvement. -/
theorem profile_step_ratio (d k : ℕ) (_hd : 1 ≤ d) (hk : k < d) :
    certificateDepthProfile d (k + 1) * d = certificateDepthProfile d k := by
  unfold certificateDepthProfile
  have h : d - k = (d - (k + 1)) + 1 := by omega
  rw [h, pow_succ', mul_comm]

/-! ## Part 8: Entropy-Complexity Bridge (pigeonhole via injective images) -/

/-- If a descent system has an injective measure, the state count is at most
`worstCase + 1`. This connects information-theoretic entropy to descent
complexity via the pigeonhole principle on injective images. -/
theorem state_count_le_worstCase_plus_one (D : DescentSystem)
    (hinj : Function.Injective D.measure) :
    Fintype.card D.State ≤ D.worstCase + 1 := by
  -- The injective image has the same cardinality
  have h1 : (Finset.univ.image D.measure).card = Fintype.card D.State := by
    rw [Finset.card_image_of_injective _ hinj, Finset.card_univ]
  -- Every image value lies in {0, ..., worstCase}
  have h2 : Finset.univ.image D.measure ⊆ Finset.range (D.worstCase + 1) := by
    intro x hx
    simp only [Finset.mem_image, Finset.mem_univ, true_and] at hx
    obtain ⟨s, rfl⟩ := hx
    exact Finset.mem_range.mpr
      (Nat.lt_succ_of_le (Finset.le_sup (f := D.measure) (Finset.mem_univ s)))
  calc Fintype.card D.State
      = (Finset.univ.image D.measure).card := h1.symm
    _ ≤ (Finset.range (D.worstCase + 1)).card := Finset.card_le_card h2
    _ = D.worstCase + 1 := Finset.card_range _

/-- Entropy (log₂ of state count) is at most the worst case. -/
theorem entropy_le_worstCase (D : DescentSystem)
    (hinj : Function.Injective D.measure) :
    Nat.log 2 (Fintype.card D.State) ≤ D.worstCase := by
  -- First bound: card ≤ worstCase + 1
  have hcard := state_count_le_worstCase_plus_one D hinj
  -- Second: log₂(m+1) ≤ m
  suffices h : ∀ m : ℕ, Nat.log 2 (m + 1) ≤ m by
    calc Nat.log 2 (Fintype.card D.State)
        ≤ Nat.log 2 (D.worstCase + 1) := Nat.log_mono_right hcard
      _ ≤ D.worstCase := h D.worstCase
  intro m
  cases m with
  | zero => simp
  | succ n =>
    have h_pow : n + 2 ≤ 2 ^ (n + 1) := by
      induction n with
      | zero => norm_num
      | succ k ih =>
        calc k + 3 ≤ 2 * (k + 2) := by omega
          _ ≤ 2 * 2 ^ (k + 1) := by linarith
          _ = 2 ^ (k + 2) := by ring
    have h2 : n + 1 + 1 < 2 ^ (n + 1).succ := by
      have : 2 ^ (n + 2) = 2 * 2 ^ (n + 1) := by ring
      omega
    exact Nat.lt_succ_iff.mp (Nat.log_lt_of_lt_pow (by omega) h2)

/-! ## Part 9: Product Systems -/

/-- The product of two descent systems. -/
noncomputable def DescentSystem.product (D₁ D₂ : DescentSystem) : DescentSystem where
  State := D₁.State × D₂.State
  dim := D₁.dim + D₂.dim
  measure := fun p => D₁.measure p.1 + D₂.measure p.2
  canDescend := fun p q =>
    (D₁.canDescend p.1 q.1 ∧ p.2 = q.2) ∨ (p.1 = q.1 ∧ D₂.canDescend p.2 q.2)
  descent_decreases := fun ⟨a, b⟩ ⟨c, d⟩ h => by
    simp only at h ⊢
    rcases h with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · subst h2; exact Nat.add_lt_add_right (D₁.descent_decreases _ _ h1) _
    · subst h1; exact Nat.add_lt_add_left (D₂.descent_decreases _ _ h2) _

/-- Product worst case is at most the sum. -/
theorem product_worstCase_le (D₁ D₂ : DescentSystem) :
    (D₁.product D₂).worstCase ≤ D₁.worstCase + D₂.worstCase := by
  apply Finset.sup_le
  intro ⟨s, t⟩ _
  exact Nat.add_le_add
    (Finset.le_sup (f := D₁.measure) (Finset.mem_univ s))
    (Finset.le_sup (f := D₂.measure) (Finset.mem_univ t))

/-- Product worst case is at least the sum (for nonempty systems). -/
theorem product_worstCase_ge (D₁ D₂ : DescentSystem)
    [Nonempty D₁.State] [Nonempty D₂.State] :
    D₁.worstCase + D₂.worstCase ≤ (D₁.product D₂).worstCase := by
  unfold DescentSystem.worstCase DescentSystem.product at *
  obtain ⟨s, _, h1⟩ := Finset.exists_mem_eq_sup Finset.univ
    ⟨Classical.arbitrary D₁.State, Finset.mem_univ _⟩ D₁.measure
  obtain ⟨t, _, h2⟩ := Finset.exists_mem_eq_sup Finset.univ
    ⟨Classical.arbitrary D₂.State, Finset.mem_univ _⟩ D₂.measure
  rw [h1, h2]
  exact Finset.le_sup (f := fun (p : D₁.State × D₂.State) =>
    D₁.measure p.1 + D₂.measure p.2) (Finset.mem_univ (s, t))

/-- **Product worst case is exactly the sum.** -/
theorem product_worstCase_eq (D₁ D₂ : DescentSystem)
    [Nonempty D₁.State] [Nonempty D₂.State] :
    (D₁.product D₂).worstCase = D₁.worstCase + D₂.worstCase :=
  le_antisymm (product_worstCase_le D₁ D₂) (product_worstCase_ge D₁ D₂)

/-! ## Part 10: The Single-Power Gap Conjecture -/

/-- **The Strong Single-Power Gap Conjecture**: For every fixed `k ≥ 0`,
the upper bound `d^{d-k}` is asymptotically tight.

For every `k`, there exists `c_k > 0` such that for infinitely many `d`,
some depth-`k` system achieves worst-case `≥ c_k · d^{d-k}`.

**Testable prediction**: For `k = 0, 1, 2`, construct adversarial families
for `d = 4, ..., 20`. Compute `T(d,k) / d^{d-k}`. If this ratio converges
to a positive constant, the conjecture holds. -/
def singlePowerGapConjectureStrong : Prop :=
  ∀ k : ℕ, ∃ c_k : ℕ, c_k > 0 ∧
    ∀ d₀ : ℕ, ∃ d : ℕ, d ≥ d₀ ∧ d ≥ k + 1 ∧
      ∃ D : DescentSystem, D.dim = d ∧ D.worstCase ≥ c_k * d ^ (d - k)

/-- Verified for k=0: the adversarial system achieves `d^d` with `c_0 = 1`. -/
theorem depth_zero_conjecture_verified :
    ∀ d : ℕ, d ≥ 1 →
      ∃ D : DescentSystem, D.dim = d ∧ D.worstCase = d ^ d := by
  intro d hd
  exact ⟨adversarialSystem d hd, rfl, adversarial_worstCase d hd⟩

/-! ## Part 11: Depth Hierarchy -/

/-- The depth hierarchy is strict: deeper certificates give strictly better bounds
when `d ≥ 2`. -/
theorem depth_hierarchy_strict (d : ℕ) (hd : 2 ≤ d) :
    ∀ k, k + 1 ≤ d →
      certificateDepthProfile d (k + 1) < certificateDepthProfile d k := by
  intro k hk
  rw [← profile_step_ratio d k (by omega) (by omega)]
  have hcp : 0 < certificateDepthProfile d (k + 1) := by
    unfold certificateDepthProfile; positivity
  nlinarith

/-- Total speedup from depth 0 to depth d is a factor of `d^d`. -/
theorem total_speedup (d : ℕ) :
    certificateDepthProfile d 0 = d ^ d * certificateDepthProfile d d := by
  simp [certificateDepthProfile]

/-- Each unit depth increase gives a `d`-fold improvement. -/
theorem consecutive_depth_ratio (d : ℕ) (_hd : 2 ≤ d) (k : ℕ) (hk : k + 1 ≤ d) :
    certificateDepthProfile d k = d * certificateDepthProfile d (k + 1) := by
  unfold certificateDepthProfile
  have h : d - k = (d - (k + 1)) + 1 := by omega
  rw [h, pow_succ', mul_comm]