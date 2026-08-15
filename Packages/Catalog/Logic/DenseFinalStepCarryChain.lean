/-
# NET-25 / Catalog·Logic — Carry-chain automata: the transition is length-general

Formal counterpart of the *transition half* of the NET-25 law
**DENSE-FINAL-STEP-IS-THE-CURE**.

The empirical round (round-net-25, mechanism dissection of the NET-24
stateful-carry-cell cure) measured that in every arm — including the arms whose
full-sequence accuracy at `n = 8` collapsed to `0.002–0.08` — the *final-carry*
probe stayed at `0.86–0.99`.  In other words the recurrent **carry transition**
never lost length-generality; only the **digit readout** at the boundary step
did.

This file makes the transition half a theorem, in the exact sense that is needed
for the mechanism argument:

* `Logic.CarryChain.carry` / `digitOut` — the LSB-first base-`b` addition
  automaton with a one-bit state (`carry_le_one`);
* `Logic.CarryChain.val_digitOut_add_carry` — the *exact* length-general
  invariant: for **every** unroll depth `n`,
  `val d n + c n * b ^ n = val a n + val b n`;
* `Logic.CarryChain.modelStep_eq_*` — a *local-to-global* transfer theorem: any
  learned step function that is pointwise correct on the finitely many reachable
  triples `(x, y, c)` with `x, y < base`, `c ≤ 1` — i.e. exactly the triples a
  training set of depth `≥ 2` already exercises — is automatically correct at
  **every** depth;
* `Logic.CarryChain.exists_lengthGeneral_step` and
  `Logic.CarryChain.no_expressivity_wall` — consequently the observed length
  wall is *not* an expressivity obstruction of the recurrent cell: a correct
  finite step table exists and generalises to all lengths.

The complementary *boundary* half (why a 20-dimensional EOS input and a
384-dimensional one, with byte-identical cell weights, nevertheless train to
different solutions) is in `Logic.DenseFinalStepBoundaryConditioning`.
-/

import Mathlib

namespace Logic.CarryChain

open Finset

/-! ## The carry automaton -/

/-- Carry state of LSB-first base-`base` addition of the digit streams `a`, `b`,
after `i` steps.  The state before the first step is `0`. -/
def carry (base : ℕ) (a b : ℕ → ℕ) : ℕ → ℕ
  | 0 => 0
  | i + 1 => (a i + b i + carry base a b i) / base

/-- Digit emitted at step `i`. -/
def digitOut (base : ℕ) (a b : ℕ → ℕ) (i : ℕ) : ℕ :=
  (a i + b i + carry base a b i) % base

/-- Value of the first `n` LSB-first base-`base` digits of the stream `f`. -/
def val (base : ℕ) (f : ℕ → ℕ) (n : ℕ) : ℕ :=
  ∑ i ∈ range n, f i * base ^ i

@[simp] theorem val_zero (base : ℕ) (f : ℕ → ℕ) : val base f 0 = 0 := by
  simp [val]

theorem val_succ (base : ℕ) (f : ℕ → ℕ) (n : ℕ) :
    val base f (n + 1) = val base f n + f n * base ^ n := by
  simp [val, Finset.sum_range_succ]

/-- The carry state is a single bit, as soon as the inputs are genuine digits. -/
theorem carry_le_one {base : ℕ} (hb : 0 < base) {a b : ℕ → ℕ}
    (ha : ∀ i, a i < base) (hbd : ∀ i, b i < base) (n : ℕ) :
    carry base a b n ≤ 1 := by
  induction n with
  | zero => simp [carry]
  | succ n ih =>
      have h : a n + b n + carry base a b n ≤ 2 * base - 1 := by
        have := ha n
        have := hbd n
        omega
      have h1 : (a n + b n + carry base a b n) / base ≤ (2 * base - 1) / base :=
        Nat.div_le_div_right h
      have h2 : (2 * base - 1) / base < 2 := Nat.div_lt_of_lt_mul (by omega)
      simp only [carry]
      omega

/-! ## The exact, depth-uniform invariant -/

/-- **Length-generality of the carry transition.**  For *every* depth `n`, the
digits emitted by the automaton together with the surviving carry represent the
sum exactly.  No hypothesis on `n` — the same finite-state rule is correct at
all unroll depths. -/
theorem val_digitOut_add_carry (base : ℕ) (a b : ℕ → ℕ) (n : ℕ) :
    val base (digitOut base a b) n + carry base a b n * base ^ n
      = val base a n + val base b n := by
  induction n with
  | zero => simp [carry]
  | succ n ih =>
      have hdiv : digitOut base a b n + base * carry base a b (n + 1)
          = a n + b n + carry base a b n := by
        simp only [digitOut, carry]
        exact Nat.mod_add_div _ _
      have hpow : base ^ (n + 1) = base ^ n * base := by ring
      rw [val_succ, val_succ, val_succ, hpow]
      calc
        val base (digitOut base a b) n + digitOut base a b n * base ^ n
              + carry base a b (n + 1) * (base ^ n * base)
            = val base (digitOut base a b) n
              + (digitOut base a b n + base * carry base a b (n + 1)) * base ^ n := by ring
        _ = val base (digitOut base a b) n
              + (a n + b n + carry base a b n) * base ^ n := by rw [hdiv]
        _ = (val base (digitOut base a b) n + carry base a b n * base ^ n)
              + (a n * base ^ n + b n * base ^ n) := by ring
        _ = val base a n + val base b n + (a n * base ^ n + b n * base ^ n) := by
              rw [ih]
        _ = val base a n + a n * base ^ n + (val base b n + b n * base ^ n) := by ring

/-- Packaged form: the emitted digit stream, extended by the terminal carry as a
leading digit, is the base-`base` representation of the sum of the two truncated
inputs — at every depth. -/
theorem sum_eq_output (base : ℕ) (a b : ℕ → ℕ) (n : ℕ) :
    val base a n + val base b n
      = val base (digitOut base a b) n + carry base a b n * base ^ n :=
  (val_digitOut_add_carry base a b n).symm

/-! ## Local-to-global transfer for a *learned* step function -/

/-- Carry state produced by an arbitrary step function `T : x → y → c → (digit, carry)`. -/
def modelCarry (T : ℕ → ℕ → ℕ → ℕ × ℕ) (a b : ℕ → ℕ) : ℕ → ℕ
  | 0 => 0
  | i + 1 => (T (a i) (b i) (modelCarry T a b i)).2

/-- Digit emitted by an arbitrary step function. -/
def modelDigit (T : ℕ → ℕ → ℕ → ℕ × ℕ) (a b : ℕ → ℕ) (i : ℕ) : ℕ :=
  (T (a i) (b i) (modelCarry T a b i)).1

/-- The finitely many *reachable* input triples of the carry cell. -/
def Reachable (base : ℕ) (x y c : ℕ) : Prop := x < base ∧ y < base ∧ c ≤ 1

/-- A step function is *locally correct* if it matches the true transition on
every reachable triple.  For base 10 there are only `10 * 10 * 2 = 200` such
triples, all of which are exercised by depth-`≥ 2` training data. -/
def LocallyCorrect (base : ℕ) (T : ℕ → ℕ → ℕ → ℕ × ℕ) : Prop :=
  ∀ x y c, Reachable base x y c → T x y c = ((x + y + c) % base, (x + y + c) / base)

/-- **Local-to-global transfer, state part.**  Pointwise correctness on the
finite reachable set forces the learned recurrence to track the true carry at
*every* depth. -/
theorem modelCarry_eq_carry {base : ℕ} (hb : 0 < base) {T : ℕ → ℕ → ℕ → ℕ × ℕ}
    (hT : LocallyCorrect base T) {a b : ℕ → ℕ}
    (ha : ∀ i, a i < base) (hbd : ∀ i, b i < base) (n : ℕ) :
    modelCarry T a b n = carry base a b n := by
  induction n with
  | zero => simp [modelCarry, carry]
  | succ n ih =>
      have hc : carry base a b n ≤ 1 := carry_le_one hb ha hbd n
      have hstep := hT (a n) (b n) (modelCarry T a b n)
        ⟨ha n, hbd n, by rw [ih]; exact hc⟩
      rw [ih] at hstep
      simp [modelCarry, carry, ih, hstep]

/-- **Local-to-global transfer, output part.** -/
theorem modelDigit_eq_digitOut {base : ℕ} (hb : 0 < base) {T : ℕ → ℕ → ℕ → ℕ × ℕ}
    (hT : LocallyCorrect base T) {a b : ℕ → ℕ}
    (ha : ∀ i, a i < base) (hbd : ∀ i, b i < base) (n : ℕ) :
    modelDigit T a b n = digitOut base a b n := by
  have hc : carry base a b n ≤ 1 := carry_le_one hb ha hbd n
  have hst : modelCarry T a b n = carry base a b n :=
    modelCarry_eq_carry hb hT ha hbd n
  have hstep := hT (a n) (b n) (modelCarry T a b n) ⟨ha n, hbd n, by rw [hst]; exact hc⟩
  rw [hst] at hstep
  simp [modelDigit, digitOut, hst, hstep]

/-- **No expressivity wall.**  A locally correct step function computes the
correct sum at every depth `n`, however large — the depth wall observed
empirically cannot be blamed on the representational power of the recurrent
cell. -/
theorem no_expressivity_wall {base : ℕ} (hb : 0 < base) {T : ℕ → ℕ → ℕ → ℕ × ℕ}
    (hT : LocallyCorrect base T) {a b : ℕ → ℕ}
    (ha : ∀ i, a i < base) (hbd : ∀ i, b i < base) (n : ℕ) :
    val base (modelDigit T a b) n + modelCarry T a b n * base ^ n
      = val base a n + val base b n := by
  have hdig : ∀ i, modelDigit T a b i = digitOut base a b i :=
    fun i => modelDigit_eq_digitOut hb hT ha hbd i
  have hval : val base (modelDigit T a b) n = val base (digitOut base a b) n := by
    unfold val
    exact Finset.sum_congr rfl (fun i _ => by rw [hdig i])
  rw [hval, modelCarry_eq_carry hb hT ha hbd n]
  exact val_digitOut_add_carry base a b n

/-- A locally correct step function exists (and is unique on the reachable set),
so the hypothesis of `no_expressivity_wall` is not vacuous. -/
theorem exists_lengthGeneral_step (base : ℕ) :
    ∃ T : ℕ → ℕ → ℕ → ℕ × ℕ, LocallyCorrect base T :=
  ⟨fun x y c => ((x + y + c) % base, (x + y + c) / base), fun _ _ _ _ => rfl⟩

/-- Sharpness of the local hypothesis: a step function that errs on a *single*
reachable triple already produces a wrong digit at the corresponding depth.
Here the error is placed at step `0`, where the state is `0` by construction. -/
theorem local_error_propagates {base : ℕ} (T : ℕ → ℕ → ℕ → ℕ × ℕ)
    (x y : ℕ) (hbad : (T x y 0).1 ≠ (x + y) % base) :
    modelDigit T (fun _ => x) (fun _ => y) 0 ≠ digitOut base (fun _ => x) (fun _ => y) 0 := by
  simpa [modelDigit, modelCarry, digitOut, carry] using hbad

/-! ## Lab notes (round-net-25, measured)

Teacher-forced evaluation, plain `n = 5` LSB-first base-10 `a + b = c`,
`bs = 256`, 12000 AdamW steps, 2048 fresh draws per evaluation length.

| arm              | params  | n=8 full        | final-carry probe |
|------------------|---------|-----------------|-------------------|
| cap384-raw s0/s1 | 471,582 | 0.0078 / 0.0063 | 0.86–0.99         |
| proj384  s0/s1   | 335,242 | 1.0000 / 1.0000 | 0.86–0.99         |
| pos28    s0/s1   | 129,830 | 0.0049 / 0.0049 | 0.86–0.99         |
| pad384   s0..s3  | 335,242 | 1.0000 × 4      | 0.86–0.99         |
| pad384-zeroEOS   | 334,878 | 0.7441 / 0.0259 | 0.86–0.99         |
| raw20-192 s0..s6 | 125,214 | 0.0806 … 0.0020 | 0.86–0.99         |

The theorems above say the *transition* column of this table has an exact
depth-uniform solution and that local correctness suffices for it; the
`n = 8 full` column therefore isolates a readout/boundary effect, which is what
`Logic.DenseFinalStepBoundaryConditioning` analyses.
-/

end Logic.CarryChain