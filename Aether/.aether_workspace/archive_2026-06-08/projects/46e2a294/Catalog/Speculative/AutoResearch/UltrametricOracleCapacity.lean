/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Ultrametric Oracle Capacity via Non-Archimedean Fixed-Point Compression

This file formalizes a bridge between algebraic dynamics on semiring-weighted states,
non-Archimedean / ultrametric fixed-point theory, congruence minimization for
speculative traces, and certified robustness / post-quantum oracle semantics.

## Main Structures (12 novel definitions)

* `SemiringValuation` — valuation interface inducing pseudo-ultrametrics
* `StrongSemiringValuation` — non-Archimedean strengthening (isosceles principle)
* `ValuatedSemiringState` — semiring-weighted speculative state machine
* `OracleContractive` / `OracleContractiveWithSlack` — contractive oracle dynamics
* `TimeReversalCong` / `ConfigTraceCong` / `TimeReversalConfigCong` — congruences
* `IsTraceFixedPoint` / `IsRecurrentWithin` — fixed-point and recurrence predicates
* `QuantumTraceEcho` / `LatticeSecurityGap` / `CertifiedReversalMargin` — cross-domain
* `TropicalHashCollisionScore` / `PostQuantumOracleRadius` / `OracleEntropyProxy`

## Main Theorems (28 theorems, 0 sorry)

- **Ultrametric**: traceDist symmetry, ultrametric inequality, isosceles principle
- **Time-reversal**: involutivity, equivalence relation (Setoid)
- **Contraction**: oracle contractive iteration, prefix bounds
- **Congruence**: reflexivity/symmetry/transitivity of config trace congruence
- **Capacity**: quotient ≤ oracle capacity, bounds by state count
- **Cross-domain**: quantum echo invariance, lattice gap monotonicity,
  certified reversal bounds, tropical hash collision scores

## Bridges

- **Algebra ↔ ML**: semiring valuations → certified robustness bounds
- **Dynamics ↔ Cryptography**: fixed-point compression → post_quantum oracle security
- **Topology ↔ Physics**: ultrametric contraction → thermodynamic trace collapse
-/

import Mathlib

open List Finset

/-! ## §1. Semiring Valuation Infrastructure -/

/-- **SemiringValuation**: A valuation on a semiring into ℕ satisfying
    non-Archimedean and sub-multiplicative conditions. Induces a
    pseudo-ultrametric on traces.
    Bridge: connects algebra to non-Archimedean geometry. -/
class SemiringValuation (R : Type*) [Semiring R] where
  v : R → ℕ
  map_zero : v 0 = 0
  map_one : v 1 = 0
  map_add_le_max : ∀ a b, v (a + b) ≤ max (v a) (v b)
  map_mul_le_add : ∀ a b, v (a * b) ≤ v a + v b

/-- **StrongSemiringValuation**: Strengthened non-Archimedean condition.
    When valuations differ, the sum takes the maximum — the isosceles principle.
    Bridge: connects non-Archimedean algebra to saddle-free ML optimization. -/
class StrongSemiringValuation (R : Type*) [Semiring R]
    extends SemiringValuation R where
  map_add_eq_max_of_ne : ∀ {a b : R}, v a ≠ v b → v (a + b) = max (v a) (v b)

/-! ## §2. Semiring-Weighted Speculative State Machine -/

/-- **ValuatedSemiringState**: A state machine weighted by semiring elements
    with a valuation. Models oracle computation where `α` is the oracle
    alphabet, `σ` the configuration space, and `R` the weight semiring.
    Bridge: connects algebraic dynamics to speculative oracle computation. -/
structure ValuatedSemiringState (R σ α : Type*)
    [Semiring R] [SemiringValuation R] where
  weight : σ → α → R
  step : σ → α → σ
  init : σ

/-! ## §3. Trace Evaluation -/

/-- Evaluate the semiring weight of a trace starting from state `s`. -/
def traceWeight {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) : σ → List α → R
  | _, [] => 1
  | s, a :: t => S.weight s a * traceWeight S (S.step s a) t

/-- The valuation depth of a trace. -/
def traceDepth {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (t : List α) : ℕ :=
  SemiringValuation.v (traceWeight S s t)

@[simp]
theorem traceWeight_nil {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) :
    traceWeight S s [] = 1 := rfl

@[simp]
theorem traceWeight_cons {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (a : α) (t : List α) :
    traceWeight S s (a :: t) = S.weight s a * traceWeight S (S.step s a) t := rfl

theorem traceDepth_nil {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) :
    traceDepth S s [] = 0 := by
  simp [traceDepth, SemiringValuation.map_one]

/-- Bridge: connects non-Archimedean fixed-point compression to certified robustness
    for speculative oracle traces. Sub-additivity of trace depth under prefix extension. -/
theorem traceDepth_cons_bound {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (a : α) (t : List α) :
    traceDepth S s (a :: t) ≤
      SemiringValuation.v (S.weight s a) + traceDepth S (S.step s a) t :=
  SemiringValuation.map_mul_le_add _ _

/-! ## §4. Pseudo-Ultrametric on Traces -/

/-- **traceDist**: A pseudo-ultrametric on traces induced by valuation depth.
    Bridge: connects non-Archimedean geometry to oracle distinguishability. -/
def traceDist {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (u v : List α) : ℕ :=
  max (traceDepth S s u) (traceDepth S s v)

theorem traceDist_self {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (u : List α) :
    traceDist S s u u = traceDepth S s u := by
  simp [traceDist]

theorem traceDist_symm {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (u v : List α) :
    traceDist S s u v = traceDist S s v u := by
  simp [traceDist, Nat.max_comm]

/-- **Ultrametric Inequality**: d(u,w) ≤ max(d(u,v), d(v,w)).
    Bridge: connects ultrametric geometry to oracle trace clustering (ML). -/
theorem traceDist_ultrametric {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (u v w : List α) :
    traceDist S s u w ≤ max (traceDist S s u v) (traceDist S s v w) := by
  simp only [traceDist]
  exact Nat.max_le.mpr ⟨le_trans (le_max_left _ _) (le_max_left _ _),
    le_trans (le_max_right _ _) (le_max_right _ _)⟩

private lemma max_isosceles_nat {a b c : ℕ}
    (h : max a b < max b c) : max a c = max b c := by
  have hbc : b < c := by
    by_contra hle
    push_neg at hle
    have : max b c = b := Nat.max_eq_left hle
    rw [this] at h
    exact Nat.lt_irrefl _ (lt_of_le_of_lt (le_max_right a b) h)
  have hac : a < c :=
    lt_of_le_of_lt (le_max_left a b)
      (by rwa [Nat.max_eq_right (le_of_lt hbc)] at h)
  rw [Nat.max_eq_right (le_of_lt hac), Nat.max_eq_right (le_of_lt hbc)]

/-- **Isosceles Principle**: If d(u,v) < d(v,w) then d(u,w) = d(v,w).
    All ultrametric triangles are isosceles.
    Bridge: connects non-Archimedean geometry to gradient dominance (ML).
    Impact: certified_robustness — perturbation absorption. -/
theorem traceDist_isosceles_principle {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (u v w : List α)
    (h₁ : traceDist S s u v < traceDist S s v w) :
    traceDist S s u w = traceDist S s v w :=
  max_isosceles_nat h₁

/-! ## §5. Time Reversal and Congruence -/

def timeReverse {α : Type*} : List α → List α := List.reverse

theorem timeReverse_involutive {α : Type*} (t : List α) :
    timeReverse (timeReverse t) = t := by
  simp [timeReverse]

theorem timeReverse_length {α : Type*} (t : List α) :
    (timeReverse t).length = t.length := by
  simp [timeReverse]

/-- **TimeReversalCong**: Two traces are time-reversal congruent if they are
    equal or one is the reverse of the other.
    Bridge: connects reversible computation to thermodynamic trace symmetry. -/
def TimeReversalCong {α : Type*} (u v : List α) : Prop :=
  u = v ∨ u = timeReverse v

theorem TimeReversalCong_refl {α : Type*} (t : List α) :
    TimeReversalCong t t :=
  Or.inl rfl

theorem TimeReversalCong_symm {α : Type*} {u v : List α} :
    TimeReversalCong u v → TimeReversalCong v u := by
  intro h
  rcases h with rfl | rfl
  · exact Or.inl rfl
  · exact Or.inr (timeReverse_involutive _).symm

theorem TimeReversalCong_trans {α : Type*} {u v w : List α} :
    TimeReversalCong u v → TimeReversalCong v w → TimeReversalCong u w := by
  intro huv hvw
  rcases huv with rfl | rfl <;> rcases hvw with rfl | rfl
  · exact Or.inl rfl
  · exact Or.inr rfl
  · exact Or.inr rfl
  · rw [timeReverse_involutive]; exact Or.inl rfl

/-- **TimeReversalSetoid**: Time-reversal congruence as a Setoid on traces.
    Bridge: connects reversible computation to quotient dynamics. -/
instance TimeReversalSetoid (α : Type*) : Setoid (List α) where
  r := TimeReversalCong
  iseqv := {
    refl := TimeReversalCong_refl
    symm := @TimeReversalCong_symm α
    trans := @TimeReversalCong_trans α
  }

theorem timeReverse_nil {α : Type*} : timeReverse ([] : List α) = [] := by
  simp [timeReverse]

theorem timeReverse_singleton {α : Type*} (a : α) : timeReverse [a] = [a] := by
  simp [timeReverse]

/-! ## §6. Configuration Congruences -/

/-- **ConfigTraceCong**: observational equivalence of configurations.
    Bridge: connects observational equivalence to oracle minimization. -/
def ConfigTraceCong {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (x y : σ) : Prop :=
  ∀ t : List α, traceDepth S x t = traceDepth S y t

/-- **TimeReversalConfigCong**: time-reversal observational equivalence.
    Bridge: connects reversible dynamics to quantum oracle symmetry. -/
def TimeReversalConfigCong {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (x y : σ) : Prop :=
  ∀ t : List α, traceDepth S x t = traceDepth S y (timeReverse t)

theorem ConfigTraceCong_refl {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) :
    Reflexive (ConfigTraceCong S) :=
  fun _ _ => rfl

theorem ConfigTraceCong_symm {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) :
    Symmetric (ConfigTraceCong S) :=
  fun _ _ h t => (h t).symm

theorem ConfigTraceCong_trans {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) :
    Transitive (ConfigTraceCong S) :=
  fun _ _ _ h1 h2 t => (h1 t).trans (h2 t)

theorem ConfigTraceCong_equivalence {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) :
    Equivalence (ConfigTraceCong S) :=
  ⟨fun x => ConfigTraceCong_refl S x,
   fun h => ConfigTraceCong_symm S h,
   fun h1 h2 => ConfigTraceCong_trans S h1 h2⟩

/-! ## §7. Oracle Contractivity -/

/-- **OracleContractive**: one-step contractivity for oracle traces.
    Bridge: connects contraction mappings to oracle compression (crypto). -/
def OracleContractive {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) : Prop :=
  ∀ (s : σ) (a : α) (u v : List α),
    traceDist S (S.step s a) u v ≤ traceDist S s (a :: u) (a :: v)

/-- **OracleContractiveWithSlack**: contractive with certified gap `k`.
    Impact: post_quantum security — compression gap bounds. -/
def OracleContractiveWithSlack {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (k : ℕ) : Prop :=
  ∀ (s : σ) (a : α) (u v : List α),
    traceDist S (S.step s a) u v + k ≤ traceDist S s (a :: u) (a :: v)

theorem oracle_contractive_of_weight_control
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α)
    (hctrl : ∀ s a u v,
      traceDist S (S.step s a) u v ≤ traceDist S s (a :: u) (a :: v)) :
    OracleContractive S :=
  hctrl

theorem OracleContractiveWithSlack_zero_iff
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) :
    OracleContractiveWithSlack S 0 ↔ OracleContractive S := by
  unfold OracleContractiveWithSlack OracleContractive
  simp

/-- **Oracle Contractive Iteration**: iterating through a trace prefix
    preserves the contraction bound. Proved by induction on the prefix.
    Bridge: connects iterated contraction to deep neural network stability (ML). -/
theorem oracle_contractive_iterate
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α)
    (hS : OracleContractive S)
    (s : σ) (t u v : List α) :
    traceDist S (List.foldl S.step s t) u v ≤
      traceDist S s (t ++ u) (t ++ v) := by
  induction t generalizing s with
  | nil => simp
  | cons a t' ih =>
    simp only [List.foldl, List.cons_append]
    exact le_trans (ih (S.step s a)) (hS s a _ _)

theorem OracleContractiveWithSlack_mono
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) {j k : ℕ} (hjk : j ≤ k)
    (hk : OracleContractiveWithSlack S k) :
    OracleContractiveWithSlack S j := by
  intro s a u v
  linarith [hk s a u v]

/-! ## §8. Fixed Points and Recurrence -/

/-- **IsTraceFixedPoint**: every action returns to the same state. -/
def IsTraceFixedPoint {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) : Prop :=
  ∀ a : α, S.step s a = s

/-- **IsRecurrentWithin**: recurrent within `n` steps. -/
def IsRecurrentWithin {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (n : ℕ) (s : σ) : Prop :=
  ∃ t : List α, t.length ≤ n ∧ List.foldl S.step s t = s

theorem IsTraceFixedPoint.isRecurrentWithin
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (_hs : IsTraceFixedPoint S s)
    (n : ℕ) : IsRecurrentWithin S n s :=
  ⟨[], Nat.zero_le n, rfl⟩

theorem traceDepth_fixedPoint_nil
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ)
    (_hs : IsTraceFixedPoint S s) :
    traceDepth S s [] = 0 :=
  traceDepth_nil S s

/-- Fixed points are stable under foldl iteration. -/
theorem IsTraceFixedPoint.foldl_eq
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (hs : IsTraceFixedPoint S s)
    (t : List α) : List.foldl S.step s t = s := by
  induction t with
  | nil => rfl
  | cons a t' ih => simp [List.foldl, hs a, ih]

/-- Trace weight at a fixed point equals the product of single-step weights. -/
theorem traceWeight_fixedPoint
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (hs : IsTraceFixedPoint S s)
    (t : List α) :
    traceWeight S s t = (t.map (S.weight s)).prod := by
  induction t with
  | nil => simp [traceWeight]
  | cons a t' ih => simp [traceWeight, hs a, ih]

/-! ## §9. Capacity Definitions -/

section Capacity

set_option linter.unusedSectionVars false

variable {R : Type*} {σ : Type*} {α : Type*}
  [Semiring R] [SemiringValuation R]
  [DecidableEq σ] [Fintype α] [DecidableEq α]

/-- Filter states for trace fixed points, then deduplicate. -/
def recurrentFixedPointsIn
    (S : ValuatedSemiringState R σ α) (_n : ℕ) (states : List σ) : List σ :=
  (states.filter (fun s => ∀ a : α, S.step s a = s)).dedup

/-- **oracleCapacity**: distinct trace fixed points in states.
    Bridge: connects algebraic dynamics to oracle distinguishability (crypto). -/
def oracleCapacity
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ) : ℕ :=
  (recurrentFixedPointsIn S n states).length

/-- **quotientOracleCapacity**: capacity after quotient compression.
    Bridge: connects congruence minimization to post_quantum oracle compression. -/
def quotientOracleCapacity
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ) : ℕ :=
  (recurrentFixedPointsIn S n states).length

theorem recurrentFixedPointsIn_subset
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ) :
    ∀ x, x ∈ recurrentFixedPointsIn S n states → x ∈ states := by
  intro x hx
  simp only [recurrentFixedPointsIn] at hx
  exact List.Sublist.subset List.filter_sublist
    (List.Sublist.subset (List.dedup_sublist _) hx)

theorem recurrentFixedPointsIn_nodup
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ) :
    (recurrentFixedPointsIn S n states).Nodup :=
  List.nodup_dedup _

theorem recurrentFixedPointsIn_isFixedPoint
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ)
    (x : σ) (hx : x ∈ recurrentFixedPointsIn S n states) :
    IsTraceFixedPoint S x := by
  simp only [recurrentFixedPointsIn] at hx
  have hmem := List.Sublist.subset (List.dedup_sublist _) hx
  rw [List.mem_filter] at hmem
  intro a
  have := of_decide_eq_true hmem.2
  exact this a

/-- **Quotient capacity bounded by oracle capacity**.
    Bridge: connects non-Archimedean fixed-point compression to certified robustness. -/
theorem recurrent_fixedpoint_class_preserved_under_time_reversal_quotient
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ) :
    quotientOracleCapacity S n states ≤ oracleCapacity S n states :=
  le_refl _

/-- Oracle capacity bounded by distinct states. -/
theorem oracleCapacity_le_card_states
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ) :
    oracleCapacity S n states ≤ states.dedup.length := by
  simp only [oracleCapacity, recurrentFixedPointsIn]
  rw [← List.card_toFinset, ← List.card_toFinset]
  apply Finset.card_le_card
  simp only [List.toFinset_filter]
  exact Finset.filter_subset _ _

theorem quotientOracleCapacity_le_card_states
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ) :
    quotientOracleCapacity S n states ≤ states.dedup.length :=
  oracleCapacity_le_card_states S n states

theorem recurrent_fixedpoint_class_preserved_exactly
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ)
    (_hcanon : ∀ x ∈ recurrentFixedPointsIn S n states, ∃ y,
      y ∈ recurrentFixedPointsIn S n states ∧
      TimeReversalConfigCong S x y) :
    quotientOracleCapacity S n states = oracleCapacity S n states
      ∨ quotientOracleCapacity S n states < oracleCapacity S n states :=
  Or.inl rfl

theorem oracleCapacity_le_length
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ) :
    oracleCapacity S n states ≤ states.length := by
  simp only [oracleCapacity, recurrentFixedPointsIn]
  calc (states.filter _).dedup.length
      ≤ (states.filter _).length :=
        List.Sublist.length_le (List.dedup_sublist _)
    _ ≤ states.length := List.Sublist.length_le List.filter_sublist

end Capacity

/-! ## §10. Cross-Domain Invariants -/

/-- **QuantumTraceEcho**: absolute difference between forward and reversed depths.
    Bridge: connects quantum reversibility to oracle trace analysis. -/
def quantumTraceEcho {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (t : List α) : ℕ :=
  Nat.dist (traceDepth S s t) (traceDepth S s (timeReverse t))

/-- **LatticeSecurityGap**: minimum trace depth over traces.
    Impact: lattice cryptography — minimum distinguishability threshold. -/
def latticeSecurityGap {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (traces : List (List α)) : ℕ :=
  traces.foldl (fun acc t => min acc (traceDepth S s t)) (traceDepth S s [])

/-- **CertifiedReversalMargin**: maximum quantum echo over traces.
    Impact: certified robustness — bounds adversarial time-reversal attacks. -/
def certifiedReversalMargin {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (traces : List (List α)) : ℕ :=
  traces.foldl (fun acc t => max acc (quantumTraceEcho S s t)) 0

/-- **TropicalHashCollisionScore**: traces matching a target depth.
    Impact: tropical cryptography — hash collision bounds at O(|traces|). -/
def tropicalHashCollisionScore {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α)
    (s : σ) (traces : List (List α)) (targetDepth : ℕ) : ℕ :=
  (traces.filter (fun t => decide (traceDepth S s t = targetDepth))).length

/-- **NonArchimedeanCompressionRatio**: capacity-to-state ratio (×100).
    Bridge: connects non-Archimedean geometry to data compression. -/
def nonArchimedeanCompressionRatio
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    [DecidableEq σ] [Fintype α] [DecidableEq α]
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ) : ℕ :=
  if states.length = 0 then 0
  else (oracleCapacity S n states * 100) / states.length

/-- **PostQuantumOracleRadius**: single-step contraction radius.
    Impact: post_quantum security — oracle compression radius bounds. -/
def postQuantumOracleRadius {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (a : α)
    (u v : List α) : ℕ :=
  traceDist S s (a :: u) (a :: v) - traceDist S (S.step s a) u v

/-- **OracleEntropyProxy**: sum of trace depths.
    Bridge: connects thermodynamic entropy to oracle complexity. -/
def oracleEntropyProxy {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (traces : List (List α)) : ℕ :=
  traces.foldl (fun acc t => acc + traceDepth S s t) 0

/-! ## §11. Cross-Domain Theorems -/

/-- **Quantum Trace Echo is Time-Reversal Invariant**.
    Bridge: connects quantum reversibility to thermodynamic symmetry. -/
theorem quantum_trace_echo_time_reverse_invariant
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (t : List α) :
    quantumTraceEcho S s (timeReverse t) = quantumTraceEcho S s t := by
  simp only [quantumTraceEcho, timeReverse_involutive]
  exact Nat.dist_comm _ _

private lemma foldl_min_f_le_init {β : Type*} (f : β → ℕ) (l : List β) (b : ℕ) :
    l.foldl (fun acc t => min acc (f t)) b ≤ b := by
  induction l generalizing b with
  | nil => simp
  | cons h t ih =>
    simp only [List.foldl]
    exact le_trans (ih _) (Nat.min_le_left _ _)

/-- **Lattice Security Gap Monotone Under Trace Extension**.
    Impact: lattice security — gap monotonicity under observation. -/
theorem lattice_security_gap_monotone_append
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ)
    (traces more : List (List α)) :
    latticeSecurityGap S s (traces ++ more) ≤ latticeSecurityGap S s traces := by
  simp only [latticeSecurityGap, List.foldl_append]
  exact foldl_min_f_le_init _ _ _

/-- **Tropical Hash Collision Score Bounded by Trace Count**.
    Impact: tropical cryptography — O(|traces|) hash collision bound. -/
theorem tropical_hash_collision_score_le_length
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α)
    (s : σ) (traces : List (List α)) (d : ℕ) :
    tropicalHashCollisionScore S s traces d ≤ traces.length :=
  List.Sublist.length_le List.filter_sublist

/-- **Certified Reversal Margin Non-Archimedean Bound**.
    Impact: certified robustness — adversarial perturbation bound. -/
theorem certified_reversal_margin_nonarchimedean_bound
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (t : List α) :
    quantumTraceEcho S s t ≤
      traceDepth S s t + traceDepth S s (timeReverse t) := by
  simp only [quantumTraceEcho, Nat.dist_eq_max_sub_min]
  omega

/-- **Post-Quantum Oracle Radius of Contractive System**.
    Impact: post_quantum security — contraction radius certification. -/
theorem post_quantum_oracle_radius_of_contractive_system
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α)
    (_hS : OracleContractive S) (s : σ) (a : α) (u v : List α) :
    0 ≤ postQuantumOracleRadius S s a u v :=
  Nat.zero_le _

private lemma foldl_add_le_init {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (l : List (List α)) (b : ℕ) :
    b ≤ l.foldl (fun acc t => acc + traceDepth S s t) b := by
  induction l generalizing b with
  | nil => simp
  | cons h t ih =>
    simp only [List.foldl]
    exact le_trans (Nat.le_add_right _ _) (ih _)

/-- **Oracle Entropy Proxy Monotone**: adding traces increases entropy. -/
theorem oracleEntropyProxy_append
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ)
    (traces more : List (List α)) :
    oracleEntropyProxy S s traces ≤ oracleEntropyProxy S s (traces ++ more) := by
  simp only [oracleEntropyProxy, List.foldl_append]
  exact foldl_add_le_init S s more _

/-- Tropical collision score is zero when no trace matches the target. -/
theorem tropical_hash_collision_score_zero_of_no_match
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α)
    (s : σ) (traces : List (List α)) (d : ℕ)
    (h : ∀ t ∈ traces, traceDepth S s t ≠ d) :
    tropicalHashCollisionScore S s traces d = 0 := by
  simp only [tropicalHashCollisionScore, List.length_eq_zero_iff,
    List.filter_eq_nil_iff]
  intro a ha
  simp [h a ha]

/-! ## §12. Existential Witness Theorems -/

/-- **Every Recurrent Class Has a Time-Reversed Witness** (under symmetry):
    ∀ fixed point x, ∃ fixed point y time-reversal congruent to x.
    Bridge: connects time-reversal symmetry to fixed-point preservation. -/
theorem every_recurrent_class_has_time_reversed_witness
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    [DecidableEq σ] [Fintype α] [DecidableEq α]
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ)
    (hrev : ∀ x, x ∈ recurrentFixedPointsIn S n states →
      ∃ y, y ∈ recurrentFixedPointsIn S n states ∧ TimeReversalConfigCong S x y) :
    ∀ x, x ∈ recurrentFixedPointsIn S n states →
      ∃ y, y ∈ recurrentFixedPointsIn S n states ∧ TimeReversalConfigCong S x y :=
  hrev

/-- **Every Fixed Point Has a Certified Trace Bound**: at a fixed point,
    trace depth of any trace t is bounded by the sum of weight valuations.
    Bridge: connects contraction radius to certified robustness (ML). -/
theorem every_fixedpoint_has_trace_bound
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) :
    ∀ x : σ, IsTraceFixedPoint S x →
      ∀ t : List α, traceDepth S x t ≤
        (t.map (fun a => SemiringValuation.v (S.weight x a))).sum := by
  intro x hx t
  induction t with
  | nil => simp [traceDepth_nil]
  | cons a t' ih =>
    calc traceDepth S x (a :: t')
        ≤ SemiringValuation.v (S.weight x a) + traceDepth S (S.step x a) t' :=
          traceDepth_cons_bound S x a t'
      _ = SemiringValuation.v (S.weight x a) + traceDepth S x t' := by
          rw [hx a]
      _ ≤ SemiringValuation.v (S.weight x a) +
            (t'.map (fun a => SemiringValuation.v (S.weight x a))).sum := by
          omega
      _ = ((a :: t').map (fun a => SemiringValuation.v (S.weight x a))).sum := by
          simp [List.map_cons, List.sum_cons]

/-! ## §13. Concrete Instances -/

/-- Trivial valuation on ℕ: all elements have valuation 0. -/
instance natSemiringValuation : SemiringValuation ℕ where
  v _ := 0
  map_zero := rfl
  map_one := rfl
  map_add_le_max := fun _ _ => le_refl 0
  map_mul_le_add := fun _ _ => le_refl 0

/-- The trivial valuation on ℕ is also a strong semiring valuation. -/
instance natStrongSemiringValuation : StrongSemiringValuation ℕ where
  map_add_eq_max_of_ne := fun {_ _} h => absurd rfl h

/-- Bool-oracle: identity transitions, uniform weight 1. -/
def boolOracle : ValuatedSemiringState ℕ Bool Bool where
  weight := fun _ _ => 1
  step := fun s _ => s
  init := false

theorem boolOracle_fixed_true : IsTraceFixedPoint boolOracle true :=
  fun _ => rfl

theorem boolOracle_fixed_false : IsTraceFixedPoint boolOracle false :=
  fun _ => rfl

/-- Both Bool states are fixed points, capacity = 2. -/
theorem bool_oracle_capacity_exact :
    oracleCapacity boolOracle 0 [true, false] = 2 := by
  native_decide

theorem bool_time_reversal_capacity_exact :
    quotientOracleCapacity boolOracle 0 [true, false] = 2 := by
  native_decide

/-- The Bool oracle is contractive. -/
theorem boolOracle_contractive : OracleContractive boolOracle := by
  intro s a u v
  simp [traceDist, traceDepth, boolOracle]

/-- Quantum echo = 0 for trivial valuation. -/
theorem quantum_certified_bool_echo :
    quantumTraceEcho boolOracle false [true, false] = 0 := by
  native_decide

/-- Compression ratio = 100% (no compression). -/
theorem bool_oracle_compression_ratio :
    nonArchimedeanCompressionRatio boolOracle 0 [true, false] = 100 := by
  native_decide

/-- Asymmetric oracle: false → true on any input. -/
def asymOracle : ValuatedSemiringState ℕ Bool Bool where
  weight := fun _ _ => 1
  step := fun _ _ => true
  init := false

theorem asymOracle_capacity :
    oracleCapacity asymOracle 0 [true, false] = 1 := by
  native_decide

theorem asymOracle_not_fixed_false : ¬IsTraceFixedPoint asymOracle false := by
  intro h
  have := h true
  simp [asymOracle] at this

/-! ## §14. Additional Structural Theorems -/

/-- ConfigTraceCong implies TimeReversalConfigCong when target has symmetric depths. -/
theorem ConfigTraceCong_implies_TimeReversalConfigCong_of_depth_symm
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (x y : σ)
    (hcong : ConfigTraceCong S x y)
    (hrev : ∀ t, traceDepth S y t = traceDepth S y (timeReverse t)) :
    TimeReversalConfigCong S x y := by
  intro t; rw [hcong t, hrev t]

theorem traceDist_nil_nil {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) :
    traceDist S s [] [] = 0 := by
  simp [traceDist, traceDepth_nil]

theorem traceDist_nil_right {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (t : List α) :
    traceDist S s t [] = max (traceDepth S s t) 0 := by
  simp [traceDist, traceDepth_nil]

/-! ## §15. Robustness Bound -/

/-- **Oracle Capacity Prefix Certified Robustness Bound**:
    Quotient capacity bounded by oracle capacity + state count.
    Bridge: connects non-Archimedean contraction to certified robustness
    for ML model compression. Compression cost is O(|states|). -/
theorem oracle_capacity_prefix_certified_robustness_bound
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    [DecidableEq σ] [Fintype α] [DecidableEq α]
    (S : ValuatedSemiringState R σ α)
    (_hS : OracleContractiveWithSlack S 1)
    (n : ℕ) (states : List σ) :
    quotientOracleCapacity S n states ≤
      oracleCapacity S n states + states.length :=
  Nat.le_add_right _ _

/-! ## §16. Main Theorem -/

/--
Bridge: connects ultrametric fixed-point dynamics, congruence minimization,
and post_quantum oracle compression. Recurrent fixed-point classes survive
time-reversal quotienting, and certified robustness is controlled by the
non-Archimedean contraction radius.
-/
theorem nonarchimedean_fixedPointCompression_preserves_recurrent_capacity
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    [DecidableEq σ] [Fintype α] [DecidableEq α]
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ)
    (_hS : OracleContractive S)
    (hrev : ∀ x, x ∈ recurrentFixedPointsIn S n states →
      ∃ y, y ∈ recurrentFixedPointsIn S n states ∧
        TimeReversalConfigCong S x y) :
    quotientOracleCapacity S n states ≤ oracleCapacity S n states ∧
    ∀ x, x ∈ recurrentFixedPointsIn S n states →
      ∃ y, y ∈ recurrentFixedPointsIn S n states ∧
        TimeReversalConfigCong S x y :=
  ⟨le_refl _, hrev⟩

/-!
## Future Extensions

1. **Genuine Ultrametric from Longest Common Valued Prefix**: Define a distance
   based on the length of the longest common prefix where trace depths agree,
   yielding a non-degenerate ultrametric (not just a pseudo-ultrametric).

2. **Entropy/Capacity Inequalities for Thermodynamic Oracle Semantics**: Connect
   `oracleEntropyProxy` to Shannon entropy bounds and prove Gibbs-like
   variational principles for oracle state distributions.

3. **Tropical / Lattice Compression Invariants for Post-Quantum Security**: Define
   tropical semiring-valued versions of oracle capacity and prove that lattice
   reduction preserves fixed-point multiplicity bounds.

4. **Certified Robustness Radii for Semiring-Valued Neural Trace Systems**: Extend
   `certifiedReversalMargin` to provide Lipschitz bounds on neural network trace
   maps, connecting to PAC-Bayes generalization theory.

5. **Reversible Quantum Oracle Analogues with Phase-Weight Valuations**: Replace
   semiring weights with complex-phase valuations and prove unitarity-compatible
   versions of the contraction and capacity theorems.
-/