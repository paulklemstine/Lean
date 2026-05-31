import Mathlib

/-!
# Circuit Depth Lower Bounds from Layer Profiles

This file develops a theory of Boolean circuit depth lower bounds using
**layer profiles** — a novel combinatorial invariant that tracks the distribution
of gates across circuit layers.

## Main Definitions

* `BoolCircuit` — Boolean circuits with AND, OR, NOT, and INPUT gates
* `layerCount` — counts gates at each depth level (layer profile)
* `ExchangeDescentSpec` — specification of an exchange descent computation
* `conjectured_depth_lower_bound` — the conjectured circuit depth lower bound

## Main Results

* `layerCount_zero_of_ge_depth` — layer counts vanish beyond circuit depth
* `size_ge_depth_succ` — work ≥ span for Boolean circuits
* `negDepth_le_depth` — negation depth ≤ total depth
* `negDepth_zero_monotone` — zero-negation circuits are monotone
* `sensitivity_depth_zero` — depth-0 circuits have sensitivity ≤ 1
* `leafCount_le_two_pow_depth` — leaf count ≤ 2^depth
* `conjectured_bound_monotone_gap` — conjecture respects certificate ordering
-/

set_option maxHeartbeats 1600000

namespace CircuitDepth

/-! ## Section 1: Boolean Circuit Model -/

/-- A Boolean circuit with `n` input variables. -/
inductive BoolCircuit (n : ℕ) : Type where
  | input : Fin n → BoolCircuit n
  | constTrue : BoolCircuit n
  | constFalse : BoolCircuit n
  | and : BoolCircuit n → BoolCircuit n → BoolCircuit n
  | or : BoolCircuit n → BoolCircuit n → BoolCircuit n
  | not : BoolCircuit n → BoolCircuit n
  deriving Inhabited

variable {n : ℕ}

/-- Evaluate a Boolean circuit on an input assignment. -/
def BoolCircuit.eval (C : BoolCircuit n) (v : Fin n → Bool) : Bool :=
  match C with
  | .input i => v i
  | .constTrue => true
  | .constFalse => false
  | .and C₁ C₂ => C₁.eval v && C₂.eval v
  | .or C₁ C₂ => C₁.eval v || C₂.eval v
  | .not C₁ => !(C₁.eval v)

/-- The depth of a Boolean circuit (longest root-to-leaf path). -/
def BoolCircuit.depth : BoolCircuit n → ℕ
  | .input _ => 0
  | .constTrue => 0
  | .constFalse => 0
  | .and C₁ C₂ => 1 + max C₁.depth C₂.depth
  | .or C₁ C₂ => 1 + max C₁.depth C₂.depth
  | .not C₁ => 1 + C₁.depth

/-- The size of a Boolean circuit (total gate count). -/
def BoolCircuit.size : BoolCircuit n → ℕ
  | .input _ => 1
  | .constTrue => 1
  | .constFalse => 1
  | .and C₁ C₂ => 1 + C₁.size + C₂.size
  | .or C₁ C₂ => 1 + C₁.size + C₂.size
  | .not C₁ => 1 + C₁.size

/-- The number of internal (non-leaf) gates. -/
def BoolCircuit.internalSize : BoolCircuit n → ℕ
  | .input _ => 0
  | .constTrue => 0
  | .constFalse => 0
  | .and C₁ C₂ => 1 + C₁.internalSize + C₂.internalSize
  | .or C₁ C₂ => 1 + C₁.internalSize + C₂.internalSize
  | .not C₁ => 1 + C₁.internalSize

/-- Size is always positive. -/
theorem BoolCircuit.size_pos (C : BoolCircuit n) : 0 < C.size := by
  cases C <;> simp [BoolCircuit.size] <;> omega

/-- Internal size ≤ total size. -/
theorem BoolCircuit.internalSize_le_size (C : BoolCircuit n) :
    C.internalSize ≤ C.size := by
  induction C with
  | input _ => simp [internalSize, size]
  | constTrue => simp [internalSize, size]
  | constFalse => simp [internalSize, size]
  | and _ _ ih₁ ih₂ => simp only [internalSize, size]; omega
  | or _ _ ih₁ ih₂ => simp only [internalSize, size]; omega
  | not _ ih => simp only [internalSize, size]; omega

/-! ## Section 2: Layer Profile -/

/-- Count the number of internal gates at depth exactly `d` in the circuit. -/
def BoolCircuit.layerCount : BoolCircuit n → ℕ → ℕ
  | .input _, _ => 0
  | .constTrue, _ => 0
  | .constFalse, _ => 0
  | .and _ _, 0 => 1
  | .and C₁ C₂, d + 1 => C₁.layerCount d + C₂.layerCount d
  | .or _ _, 0 => 1
  | .or C₁ C₂, d + 1 => C₁.layerCount d + C₂.layerCount d
  | .not _, 0 => 1
  | .not C₁, d + 1 => C₁.layerCount d

/-! ## Section 3: Fundamental Theorems -/

/-- **Layer counts vanish beyond circuit depth.** -/
theorem BoolCircuit.layerCount_zero_of_ge_depth (C : BoolCircuit n) (d : ℕ)
    (hd : C.depth ≤ d) : C.layerCount d = 0 := by
  induction C generalizing d with
  | input _ => simp [layerCount]
  | constTrue => simp [layerCount]
  | constFalse => simp [layerCount]
  | and C₁ C₂ ih₁ ih₂ =>
    simp only [depth] at hd
    match d with
    | 0 => omega
    | d + 1 =>
      simp only [layerCount]
      have h1 := ih₁ d (by omega)
      have h2 := ih₂ d (by omega)
      omega
  | or C₁ C₂ ih₁ ih₂ =>
    simp only [depth] at hd
    match d with
    | 0 => omega
    | d + 1 =>
      simp only [layerCount]
      have h1 := ih₁ d (by omega)
      have h2 := ih₂ d (by omega)
      omega
  | not C₁ ih =>
    simp only [depth] at hd
    match d with
    | 0 => omega
    | d + 1 => simp only [layerCount]; exact ih d (by omega)

/-- A circuit with at least one internal gate has positive depth. -/
theorem BoolCircuit.depth_pos_of_has_gate (C : BoolCircuit n)
    (h : 0 < C.internalSize) : 0 < C.depth := by
  cases C with
  | input _ => simp [internalSize] at h
  | constTrue => simp [internalSize] at h
  | constFalse => simp [internalSize] at h
  | and _ _ => simp [depth]
  | or _ _ => simp [depth]
  | not _ => simp [depth]

/-! ## Section 4: Size-Depth Tradeoffs -/

/-- **Work ≥ Span**: Size ≥ depth + 1. -/
theorem BoolCircuit.size_ge_depth_succ (C : BoolCircuit n) :
    C.depth + 1 ≤ C.size := by
  induction C with
  | input _ => simp [depth, size]
  | constTrue => simp [depth, size]
  | constFalse => simp [depth, size]
  | and _ _ ih₁ ih₂ => simp only [depth, size]; omega
  | or _ _ ih₁ ih₂ => simp only [depth, size]; omega
  | not _ ih => simp only [depth, size]; omega

/-! ## Section 5: Exchange Descent Specification -/

/-- An **exchange descent specification** describes a computational problem
    where we must find an improving exchange in a combinatorial optimization.

    This is a novel formalization connecting optimization theory to circuit
    complexity through the lens of information flow. -/
structure ExchangeDescentSpec where
  dim : ℕ
  certDepth : ℕ
  cert_lt_dim : certDepth < dim
  dim_ge_two : 2 ≤ dim

/-- The **complexity gap** between dimension and certificate depth. -/
def ExchangeDescentSpec.gap (spec : ExchangeDescentSpec) : ℕ :=
  spec.dim - spec.certDepth - 1

/-- The gap is at most dim - 1. -/
theorem ExchangeDescentSpec.gap_le (spec : ExchangeDescentSpec) :
    spec.gap ≤ spec.dim - 1 := by
  unfold gap; omega

/-- The gap is zero when certificate depth = dim - 1. -/
theorem ExchangeDescentSpec.gap_zero (spec : ExchangeDescentSpec)
    (h : spec.certDepth = spec.dim - 1) : spec.gap = 0 := by
  unfold gap; omega

/-- The gap is maximized when certificate depth is zero. -/
theorem ExchangeDescentSpec.gap_max (spec : ExchangeDescentSpec)
    (h : spec.certDepth = 0) : spec.gap = spec.dim - 1 := by
  unfold gap; omega

/-! ## Section 6: Sensitivity -/

/-- The **sensitivity** of a Boolean circuit at input `v`. -/
def BoolCircuit.sensitivity (C : BoolCircuit n) (v : Fin n → Bool) : ℕ :=
  (Finset.univ.filter fun i : Fin n =>
    C.eval v ≠ C.eval (Function.update v i (!v i))).card

/-- Sensitivity is at most n. -/
theorem BoolCircuit.sensitivity_le (C : BoolCircuit n) (v : Fin n → Bool) :
    C.sensitivity v ≤ n := by
  unfold sensitivity
  calc (Finset.filter _ Finset.univ).card
      ≤ Finset.univ.card := Finset.card_filter_le _ _
    _ = n := Finset.card_fin n

/-
**Depth-0 sensitivity bound**: depth-0 circuits have sensitivity ≤ 1.
-/
theorem BoolCircuit.sensitivity_depth_zero (C : BoolCircuit n) (v : Fin n → Bool)
    (hd : C.depth = 0) : C.sensitivity v ≤ 1 := by
  induction' C with _ _ _ _ _ _ _ _ _ ih1 ih2;
  all_goals norm_num [ BoolCircuit.eval, BoolCircuit.depth ] at *;
  · refine' Finset.card_le_one.mpr _;
    simp +decide [ BoolCircuit.eval ];
    grind;
  · exact Nat.le_of_lt_succ ( by rw [ show ( constTrue : BoolCircuit n ).sensitivity v = 0 by exact Finset.card_eq_zero.mpr <| by aesop ] ; norm_num );
  · exact Nat.le_of_lt_succ ( by rw [ show ( constFalse : BoolCircuit n ).sensitivity v = 0 by exact Finset.card_eq_zero.mpr <| Finset.filter_eq_empty_iff.mpr fun _ _ => by aesop ] ; norm_num )

/-! ## Section 7: Negation Depth -/

/-- The **negation depth** counts only NOT gates on the longest path. -/
def BoolCircuit.negDepth : BoolCircuit n → ℕ
  | .input _ => 0
  | .constTrue => 0
  | .constFalse => 0
  | .and C₁ C₂ => max C₁.negDepth C₂.negDepth
  | .or C₁ C₂ => max C₁.negDepth C₂.negDepth
  | .not C₁ => 1 + C₁.negDepth

/-- **Negation depth ≤ total depth.** -/
theorem BoolCircuit.negDepth_le_depth (C : BoolCircuit n) :
    C.negDepth ≤ C.depth := by
  induction C with
  | input _ => simp [negDepth, depth]
  | constTrue => simp [negDepth, depth]
  | constFalse => simp [negDepth, depth]
  | and _ _ ih₁ ih₂ => simp only [negDepth, depth]; omega
  | or _ _ ih₁ ih₂ => simp only [negDepth, depth]; omega
  | not _ ih => simp only [negDepth, depth]; omega

/-
**Monotone circuit theorem**: Zero negation depth ⟹ monotone function.
-/
theorem BoolCircuit.negDepth_zero_monotone (C : BoolCircuit n)
    (hnd : C.negDepth = 0) :
    ∀ v w : Fin n → Bool, (∀ i, v i = true → w i = true) →
      C.eval v = true → C.eval w = true := by
  -- We'll use induction on the structure of the circuit to prove the monotonicity.
  induction' C with C₁ C₂ ih₁ ih₂;
  all_goals norm_num [ BoolCircuit.eval, BoolCircuit.negDepth ] at *;
  · aesop;
  · grind;
  · grind

/-! ## Section 8: Conjectured Depth Lower Bound -/

/-- The **conjectured depth lower bound** for exchange descent:
    `(d - k - 1) * ⌊log₂ d⌋`.

    **Falsification test**: For d = 4, k = 0, predicts depth ≥ 6.
    Encode d=4 exchange descent as SAT and find shallowest circuit. -/
def conjectured_depth_lower_bound (d k : ℕ) : ℕ :=
  (d - k - 1) * (Nat.log 2 d)

/-- The conjectured bound is zero when k ≥ d - 1. -/
theorem conjectured_bound_zero_at_trivial (d k : ℕ) (hk : d ≤ k + 1) :
    conjectured_depth_lower_bound d k = 0 := by
  unfold conjectured_depth_lower_bound
  have : d - k - 1 = 0 := by omega
  simp [this]

/-- **Monotonicity**: Lower certificate depth ⟹ higher bound. -/
theorem conjectured_bound_monotone_gap (d k₁ k₂ : ℕ)
    (hle : k₁ ≤ k₂) :
    conjectured_depth_lower_bound d k₂ ≤
    conjectured_depth_lower_bound d k₁ := by
  unfold conjectured_depth_lower_bound
  apply Nat.mul_le_mul_right
  omega

/-- The conjectured bound grows at least linearly in the gap for d ≥ 2. -/
theorem conjectured_bound_ge_gap (d k : ℕ) (hd : 2 ≤ d) :
    d - k - 1 ≤ conjectured_depth_lower_bound d k := by
  unfold conjectured_depth_lower_bound
  have hlog : 1 ≤ Nat.log 2 d := Nat.log_pos (by omega) (by omega)
  calc d - k - 1 = (d - k - 1) * 1 := (Nat.mul_one _).symm
    _ ≤ (d - k - 1) * Nat.log 2 d := Nat.mul_le_mul_left _ hlog

/-! ## Section 9: Leaf Count and Depth -/

/-- The **number of leaves** in a circuit. -/
def BoolCircuit.leafCount : BoolCircuit n → ℕ
  | .input _ => 1
  | .constTrue => 1
  | .constFalse => 1
  | .and C₁ C₂ => C₁.leafCount + C₂.leafCount
  | .or C₁ C₂ => C₁.leafCount + C₂.leafCount
  | .not C₁ => C₁.leafCount

/-- **Leaf count ≤ 2^depth**: fundamental information-theoretic bound. -/
theorem BoolCircuit.leafCount_le_two_pow_depth (C : BoolCircuit n) :
    C.leafCount ≤ 2 ^ C.depth := by
  induction C with
  | input _ => simp [leafCount, depth]
  | constTrue => simp [leafCount, depth]
  | constFalse => simp [leafCount, depth]
  | and C₁ C₂ ih₁ ih₂ =>
    simp only [leafCount, depth]
    calc C₁.leafCount + C₂.leafCount
        ≤ 2 ^ C₁.depth + 2 ^ C₂.depth := Nat.add_le_add ih₁ ih₂
      _ ≤ 2 ^ max C₁.depth C₂.depth + 2 ^ max C₁.depth C₂.depth := by
          apply Nat.add_le_add
          · exact Nat.pow_le_pow_right (by omega) (le_max_left _ _)
          · exact Nat.pow_le_pow_right (by omega) (le_max_right _ _)
      _ = 2 ^ (1 + max C₁.depth C₂.depth) := by ring
  | or C₁ C₂ ih₁ ih₂ =>
    simp only [leafCount, depth]
    calc C₁.leafCount + C₂.leafCount
        ≤ 2 ^ C₁.depth + 2 ^ C₂.depth := Nat.add_le_add ih₁ ih₂
      _ ≤ 2 ^ max C₁.depth C₂.depth + 2 ^ max C₁.depth C₂.depth := by
          apply Nat.add_le_add
          · exact Nat.pow_le_pow_right (by omega) (le_max_left _ _)
          · exact Nat.pow_le_pow_right (by omega) (le_max_right _ _)
      _ = 2 ^ (1 + max C₁.depth C₂.depth) := by ring
  | not C₁ ih =>
    simp only [leafCount, depth]
    calc C₁.leafCount ≤ 2 ^ C₁.depth := ih
      _ ≤ 2 ^ (1 + C₁.depth) := by
          apply Nat.pow_le_pow_right (by omega); omega

/-
**Depth lower bound from leaf count**.
-/
theorem BoolCircuit.depth_ge_log_leafCount (C : BoolCircuit n) :
    Nat.log 2 C.leafCount ≤ C.depth := by
  have h := C.leafCount_le_two_pow_depth
  exact Nat.le_trans (Nat.log_mono_right h) (by norm_num [Nat.log_pow])

/-! ## Section 10: Layer Profile Conservation -/

/-
**Layer profile conservation**: sum of layer counts = internal gate count.
-/
theorem BoolCircuit.layerCount_sum_eq_internalSize (C : BoolCircuit n) :
    (Finset.range C.depth).sum C.layerCount = C.internalSize := by
  induction' C using BoolCircuit.recOn with n ih;
  all_goals norm_num [ BoolCircuit.depth, BoolCircuit.internalSize ];
  · rw [ add_comm, Finset.sum_range_succ' ];
    -- By definition of `layerCount`, we can split the sum into two parts: one for `ih` and one for `a✝`.
    have h_split : ∑ k ∈ Finset.range (max ih.depth ‹BoolCircuit n›.depth), (ih.and ‹BoolCircuit n›).layerCount (k + 1) = ∑ k ∈ Finset.range (max ih.depth ‹BoolCircuit n›.depth), (ih.layerCount k + ‹BoolCircuit n›.layerCount k) := by
      rfl;
    simp_all +decide [ Finset.sum_add_distrib ];
    rw [ ← Finset.sum_subset ( Finset.range_mono ( Nat.le_max_left _ _ ) ), ← Finset.sum_subset ( Finset.range_mono ( Nat.le_max_right _ _ ) ) ] <;> simp_all +decide [ add_comm, add_left_comm, add_assoc ];
    · rw [ show ( ih.and _ ).layerCount 0 = 1 from rfl ] ; ring;
    · exact fun x hx₁ hx₂ => BoolCircuit.layerCount_zero_of_ge_depth _ _ hx₂;
    · exact fun x hx₁ hx₂ => BoolCircuit.layerCount_zero_of_ge_depth _ _ hx₂;
  · rename_i C₁ C₂ h₁ h₂;
    -- By definition of `layerCount`, we can split the sum into two parts: the sum for `C₁` and the sum for `C₂`.
    have h_split : (Finset.range (1 + max C₁.depth C₂.depth)).sum (C₁.or C₂).layerCount = 1 + (Finset.range (max C₁.depth C₂.depth)).sum (fun d => C₁.layerCount d + C₂.layerCount d) := by
      rw [ add_comm, Finset.sum_range_succ' ];
      simp +arith +decide [ BoolCircuit.layerCount ];
    cases max_cases C₁.depth C₂.depth <;> simp_all +decide [ add_assoc, Finset.sum_add_distrib ];
    · rw [ ← h₂, ← Finset.sum_range_add_sum_Ico _ ‹_› ];
      simp +zetaDelta at *;
      exact fun i hi₁ hi₂ => BoolCircuit.layerCount_zero_of_ge_depth _ _ hi₁;
    · rw [ ← h₁, Finset.sum_subset ( Finset.range_mono ( by linarith : C₁.depth ≤ C₂.depth ) ) fun x hx₁ hx₂ => by rw [ BoolCircuit.layerCount_zero_of_ge_depth ] ; aesop ];
  · simp_all +decide [ add_comm 1, Finset.sum_range_succ' ];
    simp_all +decide [ add_comm, BoolCircuit.layerCount ]

end CircuitDepth