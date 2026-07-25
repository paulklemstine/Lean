/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Directional Depth Theory for Iterated Log-Concavity

This file develops **directional depth**, a new invariant for positive sequences
measuring iterated log-concavity under the ratio transform `R(a)(n) = a(n+1)/a(n)`.

## Main Results

* `hasDepth_hereditary` — Depth filtration is nested
* `depth_filtration_antitone` — Monotonicity of filtration
* `depth_product_min` — Depth of product ≥ min of depths
* `geometric_infinite_depth` — Geometric sequences have arbitrary depth
* `logConcave_exchange` — Log-concavity ⟹ matroid exchange property
* `logConcave_tropical_bridge` — Bridge to tropical concavity
-/

noncomputable section

open Real

/-! ## Core Definitions -/

/-- The **ratio transform**: `R(a)(n) = a(n+1) / a(n)`. The discrete
    multiplicative analog of the logarithmic derivative. -/
def ratioTr (a : ℕ → ℝ) : ℕ → ℝ := fun n => a (n + 1) / a n

/-- **Directional depth** of a positive sequence, defined inductively.
    - `HasDepth a 0` means `a` is positive and log-concave.
    - `HasDepth a (k+1)` means `a` has depth 0 and `R(a)` has depth k. -/
inductive HasDepth : (ℕ → ℝ) → ℕ → Prop where
  | base {a : ℕ → ℝ} (hpos : ∀ n, 0 < a n)
    (hlc : ∀ n, a (n + 1) ^ 2 ≥ a n * a (n + 2)) : HasDepth a 0
  | step {a : ℕ → ℝ} {k : ℕ} (h0 : HasDepth a 0)
    (hR : HasDepth (ratioTr a) k) : HasDepth a (k + 1)

/-! ## Filtration Properties -/

/-- **Depth Hereditary**: depth ≥ k+1 implies depth ≥ k. -/
theorem hasDepth_hereditary {a : ℕ → ℝ} {k : ℕ}
    (h : HasDepth a (k + 1)) : HasDepth a k := by
  induction k generalizing a with
  | zero => match h with | .step h0 _ => exact h0
  | succ k ih => match h with | .step h0 hR => exact .step h0 (ih hR)

/-- **Antitone Filtration**: depth ≥ k and j ≤ k implies depth ≥ j. -/
theorem depth_filtration_antitone {a : ℕ → ℝ} {j k : ℕ} (hjk : j ≤ k)
    (h : HasDepth a k) : HasDepth a j := by
  obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hjk
  induction d with
  | zero => exact h
  | succ d ih => exact ih (Nat.le_add_right j d) (hasDepth_hereditary h)

/-- Extract positivity from any depth level. -/
theorem pos_of_depth {a : ℕ → ℝ} {k : ℕ} (h : HasDepth a k) :
    ∀ n, 0 < a n := by
  match h with
  | .base hpos _ => exact hpos
  | .step h0 _ => exact pos_of_depth h0

/-- Extract log-concavity from any depth level. -/
theorem logConcave_of_depth {a : ℕ → ℝ} {k : ℕ} (h : HasDepth a k) :
    ∀ n, a (n + 1) ^ 2 ≥ a n * a (n + 2) := by
  match h with
  | .base _ hlc => exact hlc
  | .step h0 _ => exact logConcave_of_depth h0

/-! ## Ratio Transform Properties -/

/-- Ratio transform preserves positivity. -/
theorem ratioTr_pos {a : ℕ → ℝ} (hpos : ∀ n, 0 < a n) :
    ∀ n, 0 < ratioTr a n :=
  fun n => div_pos (hpos (n + 1)) (hpos n)

/-- **Ratio Antitonicity**: log-concavity makes ratios antitone. -/
theorem ratioTr_antitone {a : ℕ → ℝ}
    (hpos : ∀ n, 0 < a n)
    (hlc : ∀ n, a (n + 1) ^ 2 ≥ a n * a (n + 2)) :
    ∀ n, ratioTr a n ≥ ratioTr a (n + 1) := by
  intro n
  simp only [ratioTr, ge_iff_le, div_le_div_iff₀ (hpos (n + 1)) (hpos n)]
  nlinarith [hlc n]

/-! ## Geometric Sequences: Infinite Depth -/

/-- Ratio transform of constant c > 0 is 1. -/
theorem ratioTr_const {c : ℝ} (hc : 0 < c) :
    ratioTr (fun _ : ℕ => c) = fun _ => (1 : ℝ) := by
  ext n; simp [ratioTr, ne_of_gt hc]

/-- **Constant sequences have infinite depth**. -/
theorem const_infinite_depth : ∀ (k : ℕ) {c : ℝ} (_ : 0 < c),
    HasDepth (fun _ : ℕ => c) k := by
  intro k; induction k with
  | zero =>
    intro c hc
    exact .base (fun _ => hc) (fun _ => by nlinarith [sq_nonneg c])
  | succ k ih =>
    intro c hc
    exact .step (.base (fun _ => hc) (fun _ => by nlinarith [sq_nonneg c]))
      (by rw [ratioTr_const hc]; exact ih one_pos)

/-- Ratio transform of a geometric sequence `a₀ · r^n` is constant `r`. -/
theorem ratioTr_geometric {a₀ r : ℝ} (ha₀ : 0 < a₀) (hr : 0 < r) :
    ratioTr (fun n => a₀ * r ^ n) = fun _ => r := by
  ext n; simp only [ratioTr]; field_simp; ring

/-- Helper: geometric sequences are log-concave. -/
private theorem geometric_logConcave {a₀ r : ℝ} (n : ℕ) :
    (a₀ * r ^ (n + 1)) ^ 2 ≥ a₀ * r ^ n * (a₀ * r ^ (n + 2)) := by
  have h1 : r ^ (n + 1) = r ^ n * r := by ring
  have h2 : r ^ (n + 2) = r ^ n * r ^ 2 := by ring
  rw [h1, h2]; nlinarith [sq_nonneg (a₀ * (r ^ n * r))]

/-- **Geometric sequences have infinite depth**: since `R(a₀·r^n) = r`
    (constant), and constants have infinite depth. -/
theorem geometric_infinite_depth {a₀ r : ℝ} (ha₀ : 0 < a₀) (hr : 0 < r) :
    ∀ k, HasDepth (fun n => a₀ * r ^ n) k := by
  intro k; induction k with
  | zero =>
    exact .base (fun n => mul_pos ha₀ (pow_pos hr n)) geometric_logConcave
  | succ k _ =>
    exact .step (.base (fun n => mul_pos ha₀ (pow_pos hr n)) geometric_logConcave)
      (by rw [ratioTr_geometric ha₀ hr]; exact const_infinite_depth k hr)

/-! ## Product Depth Theorem -/

/-
Product of log-concave positive sequences is log-concave.
-/
set_option linter.unusedVariables false in
theorem product_logConcave {a b : ℕ → ℝ}
    (ha_pos : ∀ n, 0 < a n) (hb_pos : ∀ n, 0 < b n)
    (ha_lc : ∀ n, a (n+1)^2 ≥ a n * a (n+2))
    (hb_lc : ∀ n, b (n+1)^2 ≥ b n * b (n+2)) :
    ∀ n, (a (n+1) * b (n+1))^2 ≥ (a n * b n) * (a (n+2) * b (n+2)) := by
  intro n;
  nlinarith [ ha_lc n, hb_lc n, mul_pos ( ha_pos n ) ( hb_pos n ), mul_pos ( ha_pos n ) ( hb_pos ( n + 1 ) ), mul_pos ( ha_pos n ) ( hb_pos ( n + 2 ) ), mul_pos ( hb_pos n ) ( hb_pos ( n + 1 ) ), mul_pos ( hb_pos n ) ( hb_pos ( n + 2 ) ), mul_pos ( hb_pos ( n + 1 ) ) ( hb_pos ( n + 2 ) ) ]

/-- Ratio transform distributes over products. -/
theorem ratioTr_mul (a b : ℕ → ℝ) :
    ratioTr (fun n => a n * b n) = fun n => ratioTr a n * ratioTr b n := by
  ext n; simp only [ratioTr]; rw [mul_div_mul_comm]

/-
**Product Depth Theorem**: depth of product ≥ min of depths.
-/
theorem depth_product_min : ∀ (k : ℕ) {a b : ℕ → ℝ},
    HasDepth a k → HasDepth b k → HasDepth (fun n => a n * b n) k := by
  intro k a b ha hb
  induction' k with k ih generalizing a b;
  · exact HasDepth.base ( fun n => mul_pos ( pos_of_depth ha n ) ( pos_of_depth hb n ) ) ( product_logConcave ( pos_of_depth ha ) ( pos_of_depth hb ) ( logConcave_of_depth ha ) ( logConcave_of_depth hb ) );
  · obtain ⟨h0_a, hR_a⟩ := ha
    obtain ⟨h0_b, hR_b⟩ := hb
    have h_prod : HasDepth (fun n => (ratioTr a n) * (ratioTr b n)) k := by
      grind +qlia;
    exact HasDepth.step ( HasDepth.base ( fun n => mul_pos ( pos_of_depth ‹HasDepth a 0› n ) ( pos_of_depth ‹HasDepth b 0› n ) ) ( product_logConcave ( fun n => pos_of_depth ‹HasDepth a 0› n ) ( fun n => pos_of_depth ‹HasDepth b 0› n ) ( logConcave_of_depth ‹HasDepth a 0› ) ( logConcave_of_depth ‹HasDepth b 0› ) ) ) ( by simpa only [ ← ratioTr_mul ] using h_prod )

/-! ## Exchange Property: Bridge to Matroid Theory -/

/-- The **exchange property**: `∀ i ≤ j, a(i)·a(j+1) ≤ a(i+1)·a(j)`. -/
def HasExchangeProp (a : ℕ → ℝ) : Prop :=
  ∀ i j, i ≤ j → a i * a (j + 1) ≤ a (i + 1) * a j

/-
**Exchange Theorem**: Positive log-concave sequences have the exchange
    property. Proof by induction on `j - i`.
-/
theorem logConcave_exchange {a : ℕ → ℝ}
    (hpos : ∀ n, 0 < a n) (hlc : ∀ n, a (n + 1) ^ 2 ≥ a n * a (n + 2)) :
    HasExchangeProp a := by
  intro i j hij
  induction' hij with k hk
  · exact le_of_eq (by ring)
  ·
    nlinarith! [ hpos i, hpos ( i + 1 ), hpos k, hpos ( k + 1 ), hlc i, hlc k, mul_pos ( hpos i ) ( hpos ( k + 1 ) ), mul_pos ( hpos ( i + 1 ) ) ( hpos k ) ]

/-- Every sequence of positive depth has the exchange property. -/
theorem depth_implies_exchange {a : ℕ → ℝ} {k : ℕ} (h : HasDepth a k) :
    HasExchangeProp a :=
  logConcave_exchange (pos_of_depth h) (logConcave_of_depth h)

/-! ## Tropical Bridge -/

/-- Tropical concavity: `2·v(n+1) ≥ v(n) + v(n+2)`. -/
def IsTropConcave (v : ℕ → ℝ) : Prop :=
  ∀ n, 2 * v (n + 1) ≥ v n + v (n + 2)

/-
**Tropical Bridge**: Log-concavity of a positive sequence implies tropical
    concavity of its logarithm.
-/
theorem logConcave_tropical_bridge {a : ℕ → ℝ}
    (hpos : ∀ n, 0 < a n) (hlc : ∀ n, a (n + 1) ^ 2 ≥ a n * a (n + 2)) :
    IsTropConcave (fun n => Real.log (a n)) := by
  intro n;
  simpa [ ← Real.log_mul ( ne_of_gt ( hpos _ ) ) ( ne_of_gt ( hpos _ ) ), two_mul ] using Real.log_le_log ( mul_pos ( hpos _ ) ( hpos _ ) ) ( hlc _ )

/-- Depth implies tropical concavity of log. -/
theorem depth_tropical {a : ℕ → ℝ} {k : ℕ} (h : HasDepth a k) :
    IsTropConcave (fun n => Real.log (a n)) :=
  logConcave_tropical_bridge (pos_of_depth h) (logConcave_of_depth h)

/-! ## Depth Spectrum -/

/-- The depth spectrum at a given scale. -/
def scaleSeq (a : ℕ → ℝ) (s : ℕ) : ℕ → ℝ := fun n => a (s * n)

/-- Scaling preserves positivity. -/
theorem scaleSeq_pos {a : ℕ → ℝ} {s : ℕ}
    (hpos : ∀ n, 0 < a n) : ∀ n, 0 < scaleSeq a s n :=
  fun n => hpos (s * n)

/-! ## DepthFiltration Structure -/

/-- Packages a sequence with its depth certificate. -/
structure DepthFiltration (k : ℕ) where
  seq : ℕ → ℝ
  depth_cert : HasDepth seq k

/-- Natural inclusion of filtration levels. -/
def DepthFiltration.restrict {j k : ℕ} (hjk : j ≤ k) (f : DepthFiltration k) :
    DepthFiltration j :=
  ⟨f.seq, depth_filtration_antitone hjk f.depth_cert⟩

/-! ## Phase Transition Conjecture -/

/-- **Falsifiable Conjecture**: Depth of perturbed geometric sequences grows
    as Θ(log(1/δ)).

    **Test**: For δ = 0.01, sequences `2^n·(1+ε_n)` with |ε_n| < 0.01
    should have depth ≥ 3 with probability > 0.9. -/
def depthPhaseTransitionConjecture : Prop :=
  ∃ c : ℝ, c > 0 ∧ ∀ δ : ℝ, 0 < δ → δ < 1/2 →
    ∀ r : ℝ, 1 < r →
    ∀ ε : ℕ → ℝ, (∀ n, |ε n| < δ) →
    ∀ a : ℕ → ℝ, (∀ n, a n = r ^ n * (1 + ε n)) →
    (∀ n, 0 < a n) →
    ∃ k : ℕ, (k : ℝ) ≥ c * |Real.log δ| ∧ HasDepth a k

end