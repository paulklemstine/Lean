import Mathlib

/-!
# The carry chain: a state-free local answer function cannot do it, a stateful cell can

## Context (NET-24)

The empirical finding under formalisation is the *carry-chain length wall*: a
fixed-depth, state-free, position-parameterized answer function masters `n`-digit
addition and then computes `n+1`-digit addition at chance, while the **same**
per-column features fed to a **stateful** (recurrent) answer cell generalise to
every length.  This file isolates the mathematical content of that dichotomy in
the base-`b` carry chain itself, which is a purely number-theoretic object.

Three theorems form the spine.

* `CarryChain.value_digits_add` — **the stateful cell is exactly correct at every
  length.**  The one-step carry automaton (one bit of state, one length-independent
  transition) reproduces base-`b` addition for all `n` simultaneously.

* `CarryChain.no_local_state_free_readout` — **no state-free answer function with a
  bounded receptive field is correct.**  For *every* window radius `k`, and every
  position-parameterized readout that only looks at columns `i-k, …, i`, correctness
  already fails at column `k+1`.  This is the wall: the failure length is
  `k+2`, i.e. exactly one column past what the window can reach.

* `CarryChain.cell_length_general` — **one-step correctness of a stateful cell implies
  correctness at every length.**  Any abstract cell (arbitrary state type) whose state
  merely *simulates* the carry bit for single columns is automatically correct on
  inputs of unbounded length.  Contrast with the state-free case, where agreement on
  short inputs constrains nothing beyond the window.

Two corollaries sharpen the wall: `CarryChain.no_subsingleton_cell` (a cell with no state
is a radius-`0` readout, hence wrong) and `CarryChain.no_commutative_pooling_readout` (an
order-blind pooling of position-blind column features cannot produce the carry bit, since
swapping a generate column with a kill column leaves the pooled value fixed and flips the
carry).

The converse of the cure is `CarryChain.cell_must_encode_carry`: any cell that is correct
at all lengths must separate histories by their carry, so the recurrent state necessarily
stores exactly the carry bit (a Myhill–Nerode argument).

Two further theorems supply the mechanism: the carry chain is the composition of
column signals in the *non-commutative* kill/propagate/generate monoid
(`CarryChain.Signal`), and carrying is `Ω(n)`-sensitive: the carry out of column `n`
depends on column `0` for every `n` (`CarryChain.carry_sensitive_to_lowest_column`).
-/

namespace CarryChain

/-! ## The carry chain -/

/-- The carry **into** column `i`, for digit streams `x`, `y` in base `b`.
This is the one-bit stateful cell: `init = false`, and a single length-independent
transition. -/
def carry (b : ℕ) (x y : ℕ → ℕ) : ℕ → Bool
  | 0 => false
  | i + 1 => decide (b ≤ x i + y i + (if carry b x y i then 1 else 0))

@[simp] theorem carry_zero (b : ℕ) (x y : ℕ → ℕ) : carry b x y 0 = false := rfl

theorem carry_succ (b : ℕ) (x y : ℕ → ℕ) (i : ℕ) :
    carry b x y (i + 1) = decide (b ≤ x i + y i + (if carry b x y i then 1 else 0)) := rfl

/-- The output digit produced at column `i`. -/
def digit (b : ℕ) (x y : ℕ → ℕ) (i : ℕ) : ℕ :=
  (x i + y i + (if carry b x y i then 1 else 0)) % b

/-- The integer with digit stream `x` truncated to `n` columns. -/
def value (b : ℕ) (x : ℕ → ℕ) : ℕ → ℕ
  | 0 => 0
  | n + 1 => value b x n + x n * b ^ n

/-! ### The column identity

`digit + b * carry-out = x + y + carry-in`.  This is the single length-independent
equation the recurrent cell has to satisfy; everything else is induction. -/

theorem column_identity (b : ℕ) (x y : ℕ → ℕ) (i : ℕ)
    (hx : x i < b) (hy : y i < b) :
    digit b x y i + b * (if carry b x y (i + 1) then 1 else 0)
      = x i + y i + (if carry b x y i then 1 else 0) := by
  have hc1 : (if carry b x y i then 1 else 0) ≤ 1 := by split <;> omega
  rw [carry_succ]
  simp only [decide_eq_true_eq]
  by_cases h : b ≤ x i + y i + (if carry b x y i then 1 else 0)
  · rw [if_pos h]
    have hmod : (x i + y i + (if carry b x y i then 1 else 0)) % b
        = x i + y i + (if carry b x y i then 1 else 0) - b := by
      rw [Nat.mod_eq_sub_mod h]
      exact Nat.mod_eq_of_lt (by omega)
    unfold digit
    omega
  · rw [if_neg h]
    have hmod : (x i + y i + (if carry b x y i then 1 else 0)) % b
        = x i + y i + (if carry b x y i then 1 else 0) :=
      Nat.mod_eq_of_lt (by omega)
    unfold digit
    omega

/-- **The stateful carry cell is correct at every length.**  Unrolling the one-bit
cell for `n` columns computes the `n`-column sum exactly, with the final state as the
overflow bit.  One transition, all lengths. -/
theorem value_digits_add (b : ℕ) (x y : ℕ → ℕ)
    (hx : ∀ i, x i < b) (hy : ∀ i, y i < b) (n : ℕ) :
    value b (digit b x y) n + b ^ n * (if carry b x y n then 1 else 0)
      = value b x n + value b y n := by
  induction n with
  | zero => simp [value]
  | succ n ih =>
      have hcol := column_identity b x y n (hx n) (hy n)
      simp only [value]
      have hpow : b ^ (n + 1) = b ^ n * b := by ring
      have key :
          digit b x y n * b ^ n + b ^ (n + 1) * (if carry b x y (n + 1) then 1 else 0)
            = x n * b ^ n + y n * b ^ n + b ^ n * (if carry b x y n then 1 else 0) := by
        rw [hpow]
        calc digit b x y n * b ^ n + b ^ n * b * (if carry b x y (n + 1) then 1 else 0)
            = b ^ n * (digit b x y n + b * (if carry b x y (n + 1) then 1 else 0)) := by ring
          _ = b ^ n * (x n + y n + (if carry b x y n then 1 else 0)) := by rw [hcol]
          _ = x n * b ^ n + y n * b ^ n + b ^ n * (if carry b x y n then 1 else 0) := by ring
      omega

/-! ## Mechanism: the kill / propagate / generate monoid

The carry chain is a *sequential composition* of per-column signals.  The composition
law is associative but **not** commutative, which is the structural reason a
state-free order-blind aggregation cannot replace the recurrence. -/

/-- The carry signal of a single column: kill (carry-out `false` whatever comes in),
propagate (carry-out = carry-in), generate (carry-out `true`). -/
inductive Signal : Type
  | kill : Signal
  | prop : Signal
  | gen : Signal
  deriving DecidableEq, Repr

namespace Signal

/-- Action of a signal on the incoming carry bit. -/
def act : Signal → Bool → Bool
  | kill, _ => false
  | prop, c => c
  | gen, _ => true

/-- `comp s t` is "apply `t`, then `s`". -/
def comp : Signal → Signal → Signal
  | kill, _ => kill
  | gen, _ => gen
  | prop, t => t

theorem comp_act (s t : Signal) (c : Bool) : (comp s t).act c = s.act (t.act c) := by
  cases s <;> cases t <;> cases c <;> rfl

theorem comp_assoc (s t u : Signal) : comp (comp s t) u = comp s (comp t u) := by
  cases s <;> cases t <;> cases u <;> rfl

@[simp] theorem prop_comp (s : Signal) : comp prop s = s := rfl

@[simp] theorem comp_prop (s : Signal) : comp s prop = s := by cases s <;> rfl

/-- **The carry monoid is non-commutative.**  Killing after generating is not the same
as generating after killing; this is precisely the order-sensitivity that forces an
ordered (stateful) accumulation. -/
theorem comp_not_comm : comp kill gen ≠ comp gen kill := by decide

end Signal

/-- The signal of column `i`. -/
def colSignal (b : ℕ) (x y : ℕ → ℕ) (i : ℕ) : Signal :=
  if b ≤ x i + y i then Signal.gen
  else if b ≤ x i + y i + 1 then Signal.prop
  else Signal.kill

/-- The composed signal of columns `0, …, n-1` (leftmost = most significant). -/
def chainSignal (b : ℕ) (x y : ℕ → ℕ) : ℕ → Signal
  | 0 => Signal.prop
  | n + 1 => Signal.comp (colSignal b x y n) (chainSignal b x y n)

/-- The carry chain **is** the composite of the per-column signals acting on `false`:
the carry bit is a monoid fold, not a pointwise function of the columns. -/
theorem carry_eq_chainSignal (b : ℕ) (x y : ℕ → ℕ) (n : ℕ) :
    carry b x y n = (chainSignal b x y n).act false := by
  induction n with
  | zero => rfl
  | succ n ih =>
      rw [carry_succ, chainSignal, Signal.comp_act, ← ih]
      unfold colSignal
      by_cases h1 : b ≤ x n + y n
      · simp [h1, Signal.act]
        omega
      · by_cases h2 : b ≤ x n + y n + 1
        · simp only [h1, h2, if_false, if_true, Signal.act]
          cases hcn : carry b x y n <;> simp <;> omega
        · simp only [h1, h2, if_false, Signal.act]
          cases hcn : carry b x y n <;> simp <;> omega

/-! ## The wall: no bounded-window, state-free answer function

We now exhibit, for every base `b ≥ 2`, a pair of inputs that differ **only** in the
lowest column and whose output digits differ in **every** higher column. -/

section Witness

variable (b : ℕ)

/-- The "all `b-1`" stream with a `1` in the lowest column. -/
def xHi : ℕ → ℕ := fun j => if j = 0 then 1 else b - 1

/-- The same stream with a `0` in the lowest column. -/
def xLo : ℕ → ℕ := fun j => if j = 0 then 0 else b - 1

/-- The companion stream: `b-1` in the lowest column, `0` above. -/
def yWit : ℕ → ℕ := fun j => if j = 0 then b - 1 else 0

theorem xHi_lt (hb : 2 ≤ b) (j : ℕ) : xHi b j < b := by
  unfold xHi; split <;> omega

theorem xLo_lt (hb : 2 ≤ b) (j : ℕ) : xLo b j < b := by
  unfold xLo; split <;> omega

theorem yWit_lt (hb : 2 ≤ b) (j : ℕ) : yWit b j < b := by
  unfold yWit; split <;> omega

/-- With the `1` present, the carry is generated at column `0` and propagates forever. -/
theorem carry_xHi (hb : 2 ≤ b) (i : ℕ) : carry b (xHi b) (yWit b) (i + 1) = true := by
  induction i with
  | zero =>
      rw [carry_succ]
      simp [xHi, yWit]
      omega
  | succ i ih =>
      rw [carry_succ, ih]
      simp [xHi, yWit]
      omega

/-- Without the `1`, no carry is ever produced. -/
theorem carry_xLo (hb : 2 ≤ b) (i : ℕ) : carry b (xLo b) (yWit b) i = false := by
  induction i with
  | zero => rfl
  | succ i ih =>
      rw [carry_succ, ih]
      cases i with
      | zero => simp [xLo, yWit]; omega
      | succ j => simp [xLo, yWit]; omega

/-- The two inputs, which differ only in column `0`, produce different digits in
**every** column `i ≥ 1`: `0` versus `b-1`. -/
theorem digit_witness_differs (hb : 2 ≤ b) (i : ℕ) :
    digit b (xHi b) (yWit b) (i + 1) ≠ digit b (xLo b) (yWit b) (i + 1) := by
  have h1 : digit b (xHi b) (yWit b) (i + 1) = 0 := by
    unfold digit
    rw [carry_xHi b hb i]
    simp [xHi, yWit]
    have : b - 1 + 1 = b := by omega
    rw [this, Nat.mod_self]
  have h2 : digit b (xLo b) (yWit b) (i + 1) = b - 1 := by
    unfold digit
    rw [carry_xLo b hb (i + 1)]
    have hxv : xLo b (i + 1) = b - 1 := by unfold xLo; rw [if_neg (Nat.succ_ne_zero i)]
    have hyv : yWit b (i + 1) = 0 := by unfold yWit; rw [if_neg (Nat.succ_ne_zero i)]
    rw [hxv, hyv]
    show (b - 1 + 0 + 0) % b = b - 1
    simp only [Nat.add_zero]
    exact Nat.mod_eq_of_lt (by omega)
  rw [h1, h2]
  omega

/-- **`Ω(n)` sensitivity of the carry chain.**  For every `n ≥ 1` the carry out of
column `n` depends on column `0`: the two witness streams agree at all columns `j ≥ 1`
yet have opposite carries at every height. -/
theorem carry_sensitive_to_lowest_column (hb : 2 ≤ b) (n : ℕ) :
    (∀ j, 1 ≤ j → xHi b j = xLo b j) ∧
      carry b (xHi b) (yWit b) (n + 1) ≠ carry b (xLo b) (yWit b) (n + 1) := by
  refine ⟨fun j hj => ?_, ?_⟩
  · unfold xHi xLo
    rw [if_neg (by omega), if_neg (by omega)]
  · rw [carry_xHi b hb n, carry_xLo b hb (n + 1)]
    simp

end Witness

/-- A *state-free, position-parameterized answer function with receptive field `k`*:
the digit emitted at column `i` may depend arbitrarily on the position index `i`, but
only on the input columns `i-k, …, i`. -/
def IsLocalReadout (k : ℕ) (g : ℕ → (ℕ → ℕ) → (ℕ → ℕ) → ℕ) : Prop :=
  ∀ (i : ℕ) (x y x' y' : ℕ → ℕ),
    (∀ j, i - k ≤ j → j ≤ i → x j = x' j) →
    (∀ j, i - k ≤ j → j ≤ i → y j = y' j) →
    g i x y = g i x' y'

/-- **The wall.**  No state-free readout with a bounded receptive field computes the
addition digits, no matter how it is parameterized by position.  Moreover the proof
localises the failure: correctness already breaks at column `k+1`, i.e. on inputs of
length `k+2`, one column past the reach of the window. -/
theorem no_local_state_free_readout {b : ℕ} (hb : 2 ≤ b) (k : ℕ)
    (g : ℕ → (ℕ → ℕ) → (ℕ → ℕ) → ℕ) (hloc : IsLocalReadout k g)
    (hcorrect : ∀ (i : ℕ) (x y : ℕ → ℕ), (∀ j, x j < b) → (∀ j, y j < b) →
      g i x y = digit b x y i) : False := by
  have hagree : ∀ j, (k + 1) - k ≤ j → j ≤ k + 1 → xHi b j = xLo b j := by
    intro j hj _
    have : 1 ≤ j := by omega
    unfold xHi xLo
    rw [if_neg (by omega), if_neg (by omega)]
  have hsame : g (k + 1) (xHi b) (yWit b) = g (k + 1) (xLo b) (yWit b) :=
    hloc (k + 1) (xHi b) (yWit b) (xLo b) (yWit b) hagree (fun _ _ _ => rfl)
  rw [hcorrect (k + 1) (xHi b) (yWit b) (xHi_lt b hb) (yWit_lt b hb),
      hcorrect (k + 1) (xLo b) (yWit b) (xLo_lt b hb) (yWit_lt b hb)] at hsame
  exact digit_witness_differs b hb k hsame

/-! ## The cure: an abstract stateful answer cell

An arbitrary cell — any state type, any transition, any readout — that merely
*simulates the carry bit for a single column* is automatically correct at **every**
length.  This is the formal counterpart of "the readout's state is the only
difference, and it flips beyond-max failure to beyond-max success". -/

/-- An abstract length-general answer cell over per-column features. -/
structure Cell (S : Type) where
  init : S
  step : S → ℕ → ℕ → S
  out : S → ℕ → ℕ → ℕ

/-- Unrolling the cell over the first `i` columns. -/
def Cell.run {S : Type} (C : Cell S) (x y : ℕ → ℕ) : ℕ → S
  | 0 => C.init
  | i + 1 => C.step (C.run x y i) (x i) (y i)

/-- One-step simulation of the carry bit propagates to every length. -/
theorem Cell.run_rep {S : Type} {b : ℕ} (C : Cell S) (rep : S → Bool)
    (h0 : rep C.init = false)
    (hstep : ∀ (s : S) (u v : ℕ), u < b → v < b →
      rep (C.step s u v) = decide (b ≤ u + v + (if rep s then 1 else 0)))
    (x y : ℕ → ℕ) (hx : ∀ j, x j < b) (hy : ∀ j, y j < b) (i : ℕ) :
    rep (C.run x y i) = carry b x y i := by
  induction i with
  | zero => simpa [Cell.run] using h0
  | succ i ih =>
      rw [Cell.run, hstep _ _ _ (hx i) (hy i), ih, carry_succ]

/-- **The stateful cell length-generalises.**  Local (single-column) correctness of the
transition and of the readout forces correctness of every emitted digit at every
column — including columns far beyond any training length.  Compare
`no_local_state_free_readout`, where local correctness is *unattainable*. -/
theorem cell_length_general {S : Type} {b : ℕ} (C : Cell S) (rep : S → Bool)
    (h0 : rep C.init = false)
    (hstep : ∀ (s : S) (u v : ℕ), u < b → v < b →
      rep (C.step s u v) = decide (b ≤ u + v + (if rep s then 1 else 0)))
    (hout : ∀ (s : S) (u v : ℕ), u < b → v < b →
      C.out s u v = (u + v + (if rep s then 1 else 0)) % b)
    (x y : ℕ → ℕ) (hx : ∀ j, x j < b) (hy : ∀ j, y j < b) (i : ℕ) :
    C.out (C.run x y i) (x i) (y i) = digit b x y i := by
  rw [hout _ _ _ (hx i) (hy i), C.run_rep rep h0 hstep x y hx hy i]
  rfl

/-- The one-bit carry cell itself, as a `Cell`. -/
def carryCell (b : ℕ) : Cell Bool where
  init := false
  step := fun c u v => decide (b ≤ u + v + (if c then 1 else 0))
  out := fun c u v => (u + v + (if c then 1 else 0)) % b

/-- Its unrolled state is the carry chain, at every length. -/
theorem carryCell_run (b : ℕ) (x y : ℕ → ℕ) (i : ℕ) :
    (carryCell b).run x y i = carry b x y i := by
  induction i with
  | zero => rfl
  | succ i ih => rw [Cell.run, ih, carry_succ]; rfl

/-- Consequently the concrete cell emits exactly the addition digits at every length,
and the full-sum identity `value_digits_add` applies to its output. -/
theorem carryCell_correct (b : ℕ) (x y : ℕ → ℕ) (i : ℕ) :
    (carryCell b).out ((carryCell b).run x y i) (x i) (y i) = digit b x y i := by
  rw [carryCell_run]
  rfl

/-- **A state-free cell is exactly a radius-0 readout, and so it fails.**  If the cell's
state type carries no information (`Subsingleton`), its output at column `i` is a
function of the column alone, and correctness is impossible.  State is not a
convenience here: it is necessary. -/
theorem no_subsingleton_cell {S : Type} [Subsingleton S] {b : ℕ} (hb : 2 ≤ b) (C : Cell S)
    (hcorrect : ∀ (x y : ℕ → ℕ) (i : ℕ), (∀ j, x j < b) → (∀ j, y j < b) →
      C.out (C.run x y i) (x i) (y i) = digit b x y i) : False := by
  refine no_local_state_free_readout hb 0 (fun i x y => C.out (C.run x y i) (x i) (y i))
    ?_ ?_
  · intro i x y x' y' hx hy
    have hs : C.run x y i = C.run x' y' i := Subsingleton.elim _ _
    simp only [hs, hx i (by omega) (by omega), hy i (by omega) (by omega)]
  · intro i x y hx hy
    exact hcorrect x y i hx hy

/-- Two columns, `generate` then `kill`: the `x` stream. -/
def gkX (b : ℕ) : ℕ → ℕ := fun j => if j = 0 then b - 1 else 0
/-- Two columns, `generate` then `kill`: the `y` stream. -/
def gkY : ℕ → ℕ := fun j => if j = 0 then 1 else 0
/-- The same two columns in the opposite order, `kill` then `generate`: the `x` stream. -/
def kgX (b : ℕ) : ℕ → ℕ := fun j => if j = 0 then 0 else b - 1
/-- The same two columns in the opposite order, `kill` then `generate`: the `y` stream. -/
def kgY : ℕ → ℕ := fun j => if j = 0 then 0 else 1

@[simp] theorem gkX_zero (b : ℕ) : gkX b 0 = b - 1 := rfl
@[simp] theorem gkX_one (b : ℕ) : gkX b 1 = 0 := rfl
@[simp] theorem gkY_zero : gkY 0 = 1 := rfl
@[simp] theorem gkY_one : gkY 1 = 0 := rfl
@[simp] theorem kgX_zero (b : ℕ) : kgX b 0 = 0 := rfl
@[simp] theorem kgX_one (b : ℕ) : kgX b 1 = b - 1 := rfl
@[simp] theorem kgY_zero : kgY 0 = 0 := rfl
@[simp] theorem kgY_one : kgY 1 = 1 := rfl

/-- **Order-blind pooling cannot carry.**  Suppose the carry bit were computed by
pooling position-blind per-column features in a *commutative* monoid (the order-free
aggregation a single attention/sum readout performs) and thresholding.  Then swapping a
"generate" column with a "kill" column would not change the pooled value, yet it flips
the carry.  This is `Signal.comp_not_comm` promoted to an impossibility statement. -/
theorem no_commutative_pooling_readout {b : ℕ} (hb : 2 ≤ b) {M : Type} [CommMonoid M]
    (feat : ℕ → ℕ → M) (dec : M → Bool)
    (h : ∀ (x y : ℕ → ℕ) (n : ℕ), (∀ j, x j < b) → (∀ j, y j < b) →
      carry b x y n = dec (∏ j ∈ Finset.range n, feat (x j) (y j))) : False := by
  have hbb : b - 1 + 1 = b := by omega
  have hgkXlt : ∀ j, gkX b j < b := by intro j; unfold gkX; split <;> omega
  have hgkYlt : ∀ j, gkY j < b := by intro j; unfold gkY; split <;> omega
  have hkgXlt : ∀ j, kgX b j < b := by intro j; unfold kgX; split <;> omega
  have hkgYlt : ∀ j, kgY j < b := by intro j; unfold kgY; split <;> omega
  have hA : carry b (gkX b) gkY 2 = false := by
    rw [carry_succ, carry_succ]
    simp [hbb]
    omega
  have hB : carry b (kgX b) kgY 2 = true := by
    rw [carry_succ, carry_succ]
    simp [hbb]
  have hprod : (∏ j ∈ Finset.range 2, feat (gkX b j) (gkY j))
      = ∏ j ∈ Finset.range 2, feat (kgX b j) (kgY j) := by
    simp [Finset.prod_range_succ, mul_comm]
  rw [h (gkX b) gkY 2 hgkXlt hgkYlt, hprod, ← h (kgX b) kgY 2 hkgXlt hkgYlt, hB] at hA
  exact Bool.noConfusion hA

/-! ## Necessity: a length-general cell *must* carry the carry bit

The converse of `cell_length_general`.  Correctness alone forces the state to separate
histories with different carry: this is the Myhill–Nerode argument for the carry
automaton, and it says the recurrent state is not merely sufficient but necessary, and
that what it must store is exactly one bit of arithmetic information. -/

/-- The carry into column `i` only depends on the columns strictly below `i`. -/
theorem carry_congr (b : ℕ) (x y x' y' : ℕ → ℕ) :
    ∀ i, (∀ j < i, x j = x' j) → (∀ j < i, y j = y' j) →
      carry b x y i = carry b x' y' i := by
  intro i
  induction i with
  | zero => intro _ _; rfl
  | succ i ih =>
      intro hx hy
      rw [carry_succ, carry_succ, ih (fun j hj => hx j (by omega)) (fun j hj => hy j (by omega)),
        hx i (by omega), hy i (by omega)]

/-- The unrolled state after `i` columns only depends on the columns strictly below `i`. -/
theorem Cell.run_congr {S : Type} (C : Cell S) (x y x' y' : ℕ → ℕ) :
    ∀ i, (∀ j < i, x j = x' j) → (∀ j < i, y j = y' j) →
      C.run x y i = C.run x' y' i := by
  intro i
  induction i with
  | zero => intro _ _; rfl
  | succ i ih =>
      intro hx hy
      rw [Cell.run, Cell.run, ih (fun j hj => hx j (by omega)) (fun j hj => hy j (by omega)),
        hx i (by omega), hy i (by omega)]

/-- **Any correct cell must encode the carry bit.**  If two histories (possibly of
different lengths) drive a correct cell into the *same* state, they must have the same
carry.  Equivalently: the carry bit is a function of the cell's state, so a correct
length-general answer path necessarily stores one bit of running arithmetic state.
The proof probes the state with the zero column, on which the emitted digit *is* the
carry. -/
theorem cell_must_encode_carry {S : Type} {b : ℕ} (hb : 2 ≤ b) (C : Cell S)
    (hcorrect : ∀ (x y : ℕ → ℕ) (i : ℕ), (∀ j, x j < b) → (∀ j, y j < b) →
      C.out (C.run x y i) (x i) (y i) = digit b x y i)
    (x y x' y' : ℕ → ℕ) (hx : ∀ j, x j < b) (hy : ∀ j, y j < b)
    (hx' : ∀ j, x' j < b) (hy' : ∀ j, y' j < b) (i i' : ℕ)
    (hstate : C.run x y i = C.run x' y' i') :
    carry b x y i = carry b x' y' i' := by
  -- probe both states with a zero column at the current position
  set z : ℕ → ℕ := fun j => if j = i then 0 else x j with hz
  set w : ℕ → ℕ := fun j => if j = i then 0 else y j with hw
  set z' : ℕ → ℕ := fun j => if j = i' then 0 else x' j with hz'
  set w' : ℕ → ℕ := fun j => if j = i' then 0 else y' j with hw'
  have hzlt : ∀ j, z j < b := by
    intro j; rw [hz]; dsimp only; split <;> first | omega | exact hx j
  have hwlt : ∀ j, w j < b := by
    intro j; rw [hw]; dsimp only; split <;> first | omega | exact hy j
  have hz'lt : ∀ j, z' j < b := by
    intro j; rw [hz']; dsimp only; split <;> first | omega | exact hx' j
  have hw'lt : ∀ j, w' j < b := by
    intro j; rw [hw']; dsimp only; split <;> first | omega | exact hy' j
  have hzi : z i = 0 := by rw [hz]; simp
  have hwi : w i = 0 := by rw [hw]; simp
  have hz'i : z' i' = 0 := by rw [hz']; simp
  have hw'i : w' i' = 0 := by rw [hw']; simp
  have hrun : C.run z w i = C.run x y i :=
    C.run_congr z w x y i (fun j hj => by rw [hz]; simp [Nat.ne_of_lt hj])
      (fun j hj => by rw [hw]; simp [Nat.ne_of_lt hj])
  have hrun' : C.run z' w' i' = C.run x' y' i' :=
    C.run_congr z' w' x' y' i' (fun j hj => by rw [hz']; simp [Nat.ne_of_lt hj])
      (fun j hj => by rw [hw']; simp [Nat.ne_of_lt hj])
  have hcar : carry b z w i = carry b x y i :=
    carry_congr b z w x y i (fun j hj => by rw [hz]; simp [Nat.ne_of_lt hj])
      (fun j hj => by rw [hw]; simp [Nat.ne_of_lt hj])
  have hcar' : carry b z' w' i' = carry b x' y' i' :=
    carry_congr b z' w' x' y' i' (fun j hj => by rw [hz']; simp [Nat.ne_of_lt hj])
      (fun j hj => by rw [hw']; simp [Nat.ne_of_lt hj])
  -- on a zero column the emitted digit is literally the carry bit
  have hdig : digit b z w i = (if carry b x y i then 1 else 0) := by
    unfold digit
    rw [hzi, hwi, hcar]
    have : (0 + 0 + (if carry b x y i then 1 else 0)) = (if carry b x y i then 1 else 0) := by
      omega
    rw [this]
    exact Nat.mod_eq_of_lt (by split <;> omega)
  have hdig' : digit b z' w' i' = (if carry b x' y' i' then 1 else 0) := by
    unfold digit
    rw [hz'i, hw'i, hcar']
    have : (0 + 0 + (if carry b x' y' i' then 1 else 0)) = (if carry b x' y' i' then 1 else 0) := by
      omega
    rw [this]
    exact Nat.mod_eq_of_lt (by split <;> omega)
  have e1 := hcorrect z w i hzlt hwlt
  have e2 := hcorrect z' w' i' hz'lt hw'lt
  rw [hrun, hzi, hwi, hdig] at e1
  rw [hrun', hz'i, hw'i, hdig'] at e2
  rw [hstate, e2] at e1
  by_cases h : carry b x y i <;> by_cases h' : carry b x' y' i' <;>
    simp [h, h'] at e1 ⊢

/-! ## The dichotomy, in one statement -/

/-- **NET-24 in one line.**  For every base `b ≥ 2` and every receptive-field radius
`k`: (i) no state-free position-parameterized readout of radius `k` is correct, while
(ii) a one-bit stateful cell with a single length-independent transition is correct at
every column, and its unrolled digits sum correctly at every length. -/
theorem stateful_beats_state_free {b : ℕ} (hb : 2 ≤ b) (k : ℕ) :
    (∀ g : ℕ → (ℕ → ℕ) → (ℕ → ℕ) → ℕ, IsLocalReadout k g →
        ¬ (∀ (i : ℕ) (x y : ℕ → ℕ), (∀ j, x j < b) → (∀ j, y j < b) →
            g i x y = digit b x y i)) ∧
      (∀ (x y : ℕ → ℕ) (i : ℕ),
        (carryCell b).out ((carryCell b).run x y i) (x i) (y i) = digit b x y i) ∧
      (∀ (x y : ℕ → ℕ), (∀ i, x i < b) → (∀ i, y i < b) → ∀ n,
        value b (digit b x y) n + b ^ n * (if carry b x y n then 1 else 0)
          = value b x n + value b y n) := by
  refine ⟨fun g hloc hcorrect => no_local_state_free_readout hb k g hloc hcorrect,
    fun x y i => carryCell_correct b x y i, fun x y hx hy n => value_digits_add b x y hx hy n⟩

end CarryChain