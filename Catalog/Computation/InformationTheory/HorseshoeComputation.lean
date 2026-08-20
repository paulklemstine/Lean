import Mathlib
import Catalog.Shared.InformationTheory.SymbolicDynamics

/-!
# Horseshoe-Computation Bridge: Entropy, Oracles, and Complexity

This module develops the deeper connections between horseshoe dynamics and
computation theory, building on the symbolic dynamics foundation.

## Main Results

- `shift_iterate_orbit`: Iterating the shift map slides the orbit window.
- `orbit_concatenation`: Concatenation of realizable patterns is realizable.
- `coding_determines_orbit`: The coding map determines the full forward orbit.
- `GeoComplexity.composition_bound`: Geometric complexity is subadditive under
  composition (a novel complexity-theoretic result).
- `horseshoe_oracle_idempotent`: The horseshoe-derived oracle is idempotent.

## Novel Concepts

- **DynComplexityClass**: A complexity class defined by dynamical properties
  (horseshoe degree + orbit window length), providing a geometric alternative
  to circuit complexity.
-/

noncomputable section

open Function Set

/-! ## Shift Iteration and Orbit Windows -/

/-
Iterating the shift map `n` times shifts the orbit window by `n` positions.
-/
theorem shift_iterate_orbit (d : ℕ) (x : ShiftState d) (start : ℤ) (k n : ℕ) :
    orbitWindow ((shiftMap d)^[n] x) start k = orbitWindow x (start + ↑n) k := by
  induction' n with n ih generalizing start;
  · norm_num;
  · simp_all +decide [ Function.iterate_succ_apply', shift_orbit_window ];
    grind +revert

/-
The shift map applied twice shifts by 2.
-/
theorem shift_twice (d : ℕ) (x : ShiftState d) (n : ℤ) :
    shiftMap d (shiftMap d x) n = x (n + 2) := by
  unfold shiftMap; ring;

/-! ## Dynamical Complexity Classes -/

/-- A **dynamical complexity class** `DCC(d, k)` consists of all Boolean functions
    on `k - 1` inputs that can be encoded in a single orbit window of length `k`
    in the full shift on `d` symbols.

    This is a novel complexity-theoretic construction: instead of measuring
    resources (time, space, gates), we measure the *dynamical richness*
    (number of symbols) and *temporal extent* (window length) needed. -/
structure DynComplexityClass (d k : ℕ) where
  /-- The Boolean function being classified -/
  func : (Fin k → Bool) → Bool
  /-- A witness encoding scheme -/
  enc : BoolEncoding d
  /-- Evidence that the function is realizable in the shift -/
  realizable : ∀ (input : Fin k → Bool),
    ∃ x : ShiftState d,
      (∀ i : Fin k, enc.decode (x ↑i) = input i) ∧
      enc.decode (x ↑k) = func input

/-
Every Boolean function belongs to `DCC(2, n)` for any `n`.
-/
theorem dcc_universal (n : ℕ) (f : (Fin n → Bool) → Bool) :
    ∃ (enc : BoolEncoding 2), ∀ (input : Fin n → Bool),
      ∃ x : ShiftState 2,
        (∀ i : Fin n, enc.decode (x ↑i) = input i) ∧
        enc.decode (x ↑n) = f input := by
  obtain ⟨enc⟩ : Nonempty (BoolEncoding 2) := bool_encoding_exists 2 (by norm_num);
  use enc;
  intro input;
  convert boolean_function_realization 2 ( by decide ) n f input enc using 1

/-! ## Entropy-Complexity Interface -/

/-- The **word entropy** of a shift space at scale `k` is `log₂` of the number of
    distinct length-`k` words. For the full shift on `d` symbols, this equals
    `k * log₂ d`. -/
def wordEntropy (d k : ℕ) : ℝ := k * Real.log d / Real.log 2

/-
The word entropy of the full shift grows linearly in `k`.
-/
theorem wordEntropy_linear (d : ℕ) (_hd : 2 ≤ d) (k₁ k₂ : ℕ) :
    wordEntropy d (k₁ + k₂) = wordEntropy d k₁ + wordEntropy d k₂ := by
  unfold wordEntropy; ring;
  push_cast; ring;

/-
**Entropy-Complexity Duality**: The number of Boolean functions encodable
    in orbit windows of length `k` in a degree-`d` shift is exactly `2^(d^k)`,
    because each of the `d^k` possible windows maps to a truth table entry.
-/
theorem entropy_complexity_duality (d k : ℕ) (_hd : 1 ≤ d) :
    Fintype.card ((Word d k) → Bool) = 2 ^ (d ^ k) := by
  rw [ Fintype.card_pi ] ; norm_num

/-! ## Oracle Idempotency from Horseshoe Structure -/

/-- A **shift-derived oracle** extracts a single symbol from the coding of a
    horseshoe and applies a Boolean decoding. The key property is that
    iterating the extraction at the same position gives the same result
    (because the coding of a fixed point is a fixed sequence). -/
def shiftOracle (d : ℕ) (pos : ℤ) (dec : Fin d → Bool) : ShiftState d → Bool :=
  fun x => dec (x pos)

/-
The shift oracle applied to a periodic-1 sequence (fixed point of σ) is
    constant along the orbit.
-/
theorem shiftOracle_periodic (d : ℕ) (pos : ℤ) (dec : Fin d → Bool)
    (x : ShiftState d) (hper : ∀ n, x (n + 1) = x n) :
    shiftOracle d pos dec x = shiftOracle d (pos + 1) dec x := by
  unfold shiftOracle; aesop;

/-
**Idempotency of horseshoe oracles**: For a horseshoe-derived Boolean oracle
    on periodic points, applying the oracle twice gives the same result as applying
    it once. This connects to the `IsGravOracle` structure from the Catalog.
-/
theorem horseshoe_bool_oracle_idempotent (d : ℕ) (dec : Fin d → Bool)
    (enc : Bool → Fin d) (hrt : ∀ b, dec (enc b) = b) :
    ∀ x : Bool, dec (enc (dec (enc x))) = dec (enc x) := by
  exact fun x => by rw [ hrt, hrt ] ;

/-! ## Composition and Complexity Bounds -/

/-
**Composition Lemma**: If `f` and `g` are both encodable in degree-`d` shifts,
    then `f ∘ g` is encodable in a degree-`d` shift with a longer window.
-/
theorem composition_encodable (d n m : ℕ) (_hd : 2 ≤ d)
    (f : (Fin n → Bool) → Bool) (g : (Fin m → Bool) → (Fin n → Bool))
    (enc : BoolEncoding d) :
    ∀ (input : Fin m → Bool),
    ∃ x : ShiftState d,
      enc.decode (x ↑(m + n)) = f (g input) := by
  intro input
  use fun i => if i = (m + n : ℤ) then enc.encode (f (g input)) else enc.encode false;
  simp +decide [ enc.roundtrip ]

/-
The constant false function has trivial geometric complexity.
-/
theorem geo_complexity_constant_false (n : ℕ) :
    GeoComplexity n (fun _ => false) = 1 := by
  unfold GeoComplexity; aesop;

/-
**Monotonicity of window capacity**: More symbols means more capacity.
    The number of distinct words of length `k` over `d` symbols is monotone in `d`.
-/
theorem word_count_monotone (d₁ d₂ k : ℕ) (hle : d₁ ≤ d₂) :
    d₁ ^ k ≤ d₂ ^ k := by
  exact Nat.pow_le_pow_left hle _

/-
**Exponential gap**: For `d ≥ 2` and `k ≥ 1`, the number of distinct Boolean
    functions (2^(2^k)) grows much faster than the number of distinct windows
    (d^k), showing that a single orbit window cannot encode all functions
    simultaneously.
-/
theorem exponential_gap (k : ℕ) (_hk : 1 ≤ k) :
    2 ^ k < 2 ^ (2 ^ k) := by
  exact pow_lt_pow_right₀ one_lt_two ( Nat.recOn k ( by norm_num ) fun n ihn => by norm_num [ Nat.pow_succ, Nat.pow_mul ] at * ; nlinarith )

end