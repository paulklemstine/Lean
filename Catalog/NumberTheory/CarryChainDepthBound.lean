import Mathlib
import Catalog.NumberTheory.CarryChainStatefulCell

/-!
# Fixed depth cannot buy length: a depth lower bound for the carry chain,
# and the carry as a 2-cocycle

This is the second cycle of the NET-24 formalisation
(`Catalog/NumberTheory/CarryChainStatefulCell.lean`).  There the wall was stated for a
*bounded receptive field*.  Here we derive that hypothesis from a structural model of a
**fixed-depth layered local computation** and turn it into a quantitative depth bound,
and then give the algebraic reason the carry is a genuinely sequential object.

## Results

* `CarryChain.LocalCircuit.eval_local` — a depth-`d`, radius-`r` layered local circuit
  has receptive field `d * r`: its value at column `i` depends only on input columns
  `i - d*r, …, i`.  (Induction on depth; the arithmetic is `Nat.sub_sub`.)

* `CarryChain.no_fixed_depth_local_circuit` — consequently **no fixed-depth local
  circuit computes the addition digits at all lengths**, for any base `b ≥ 2`.

* `CarryChain.depth_lower_bound` — quantitatively: a radius-`r` circuit that is correct
  on all columns `< n` must have `n ≤ depth * r + 1`, i.e. `depth ≥ (n-1)/r`.  Depth must
  grow *linearly* in the number of digits; a fixed-depth model necessarily walls at
  `depth * r + 1` columns.  A stateful cell of depth `1` has no such bound
  (`CarryChain.cell_length_general`).

* `CarryChain.carryOf_cocycle` — the carry `c(u,v) = ⌊(u+v)/b⌋` is a **2-cocycle**:
  `c(u,v) + c(u+v mod b, w) = c(v,w) + c(u, v+w mod b)`, both sides being `⌊(u+v+w)/b⌋`.
  This is the classical cocycle of the extension `0 → ℤ/b → ℤ/b² → ℤ/b → 0`; it is the
  algebraic content of "the carry is associative but order-sensitive data", and it
  matches `CarryChain.Signal.comp_assoc` together with `CarryChain.Signal.comp_not_comm`.
-/

namespace CarryChain

/-! ## Fixed-depth layered local circuits -/

/-- A layered circuit over per-column features with **mixing radius `r`**: every layer
computes the value at column `i` from the previous layer's values at columns
`i - r, …, i`.  `depth` layers are applied.  This is the abstraction of a fixed-depth,
state-free stack of local mixing layers with an arbitrary position-parameterized
readout (each layer may depend arbitrarily on the layer index and the position `i`). -/
structure LocalCircuit (V : Type) (r : ℕ) where
  /-- Number of mixing layers. -/
  depth : ℕ
  /-- Column embedding: position, `x`-digit, `y`-digit ↦ layer-`0` value. -/
  embed : ℕ → ℕ → ℕ → V
  /-- Layer map: layer index, position, previous layer ↦ value. -/
  layer : ℕ → ℕ → (ℕ → V) → V
  /-- Each layer only reads a window of radius `r`. -/
  hlayer : ∀ (l i : ℕ) (v v' : ℕ → V),
    (∀ j, i - r ≤ j → j ≤ i → v j = v' j) → layer l i v = layer l i v'
  /-- Final decoding of a value into an output digit. -/
  readout : V → ℕ

variable {V : Type} {r : ℕ}

/-- The value computed at layer `l`, column `i`. -/
def LocalCircuit.eval (C : LocalCircuit V r) (x y : ℕ → ℕ) : ℕ → ℕ → V
  | 0, i => C.embed i (x i) (y i)
  | l + 1, i => C.layer l i (fun j => C.eval x y l j)

/-- **Receptive field growth.**  After `l` layers of radius `r`, the value at column `i`
depends only on the input columns `i - l*r, …, i`. -/
theorem LocalCircuit.eval_local (C : LocalCircuit V r) (x y x' y' : ℕ → ℕ) :
    ∀ (l i : ℕ),
      (∀ j, i - l * r ≤ j → j ≤ i → x j = x' j) →
      (∀ j, i - l * r ≤ j → j ≤ i → y j = y' j) →
      C.eval x y l i = C.eval x' y' l i := by
  intro l
  induction l with
  | zero =>
      intro i hx hy
      have hx0 : x i = x' i := hx i (by omega) le_rfl
      have hy0 : y i = y' i := hy i (by omega) le_rfl
      simp [LocalCircuit.eval, hx0, hy0]
  | succ l ih =>
      intro i hx hy
      simp only [LocalCircuit.eval]
      refine C.hlayer l i _ _ ?_
      intro j hj hji
      refine ih j ?_ ?_
      · intro m hm hmj
        refine hx m ?_ (le_trans hmj hji)
        have hsub : i - (l + 1) * r = i - r - l * r := by
          rw [Nat.sub_sub]; ring_nf
        omega
      · intro m hm hmj
        refine hy m ?_ (le_trans hmj hji)
        have hsub : i - (l + 1) * r = i - r - l * r := by
          rw [Nat.sub_sub]; ring_nf
        omega

/-- The answer function realised by a circuit: run all `depth` layers, then decode. -/
def LocalCircuit.answer (C : LocalCircuit V r) (i : ℕ) (x y : ℕ → ℕ) : ℕ :=
  C.readout (C.eval x y C.depth i)

/-- A fixed-depth local circuit is a state-free readout of radius `depth * r`. -/
theorem LocalCircuit.answer_isLocal (C : LocalCircuit V r) :
    IsLocalReadout (C.depth * r) C.answer := by
  intro i x y x' y' hx hy
  exact congrArg C.readout (C.eval_local x y x' y' C.depth i hx hy)

/-- **No fixed-depth local circuit adds.**  For every base `b ≥ 2`, every mixing radius
and every depth, a layered local circuit fails to produce the addition digits.  The
failure is not asymptotic: it already occurs at column `depth * r + 1`. -/
theorem no_fixed_depth_local_circuit {b : ℕ} (hb : 2 ≤ b) (C : LocalCircuit V r)
    (hcorrect : ∀ (i : ℕ) (x y : ℕ → ℕ), (∀ j, x j < b) → (∀ j, y j < b) →
      C.answer i x y = digit b x y i) : False :=
  no_local_state_free_readout hb (C.depth * r) C.answer C.answer_isLocal hcorrect

/-- **Depth must grow linearly in the number of digits.**  If a radius-`r` circuit
produces the correct digit at every column `i < n` (for all base-`b` inputs), then
`n ≤ depth * r + 1`.  Equivalently `depth ≥ (n - 1) / r`: there is no fixed-depth,
state-free solution to `n`-digit addition for all `n`. -/
theorem depth_lower_bound {b : ℕ} (hb : 2 ≤ b) (C : LocalCircuit V r) (n : ℕ)
    (hcorrect : ∀ i < n, ∀ (x y : ℕ → ℕ), (∀ j, x j < b) → (∀ j, y j < b) →
      C.answer i x y = digit b x y i) :
    n ≤ C.depth * r + 1 := by
  by_contra hlt
  push_neg at hlt
  set k := C.depth * r with hk
  have hagree : ∀ j, (k + 1) - k ≤ j → j ≤ k + 1 → xHi b j = xLo b j := by
    intro j hj _
    unfold xHi xLo
    rw [if_neg (by omega), if_neg (by omega)]
  have hsame : C.answer (k + 1) (xHi b) (yWit b) = C.answer (k + 1) (xLo b) (yWit b) :=
    C.answer_isLocal (k + 1) (xHi b) (yWit b) (xLo b) (yWit b) hagree (fun _ _ _ => rfl)
  rw [hcorrect (k + 1) (by omega) (xHi b) (yWit b) (xHi_lt b hb) (yWit_lt b hb),
      hcorrect (k + 1) (by omega) (xLo b) (yWit b) (xLo_lt b hb) (yWit_lt b hb)] at hsame
  exact digit_witness_differs b hb k hsame

/-- The stateful cell realises the answer at **every** column with a single layer of
recurrence, so no analogue of `depth_lower_bound` constrains it: the bound above is a
property of state-freeness, not of the task. -/
theorem carryCell_no_depth_bound (b : ℕ) (n : ℕ) :
    ∀ (x y : ℕ → ℕ), ∀ i < n,
      (carryCell b).out ((carryCell b).run x y i) (x i) (y i) = digit b x y i :=
  fun x y i _ => carryCell_correct b x y i

/-! ## The carry as a 2-cocycle

Group-cohomological reading of the same object: the single-column carry
`c(u,v) = ⌊(u+v)/b⌋` is the 2-cocycle representing the extension
`0 → ℤ/b → ℤ/b² → ℤ/b → 0`.  Its cocycle identity is exactly the statement that carrying
three columns is well defined regardless of which pair is combined first — associativity
— while `Signal.comp_not_comm` says the *chain* is nevertheless order-sensitive. -/

/-- The single-column carry, as a number rather than a bit. -/
def carryOf (b u v : ℕ) : ℕ := (u + v) / b

theorem carryOf_le_one {b u v : ℕ} (hu : u < b) (hv : v < b) : carryOf b u v ≤ 1 := by
  unfold carryOf
  have hb : 0 < b := by omega
  have : u + v < b * 2 := by omega
  exact Nat.lt_succ_iff.mp (Nat.div_lt_of_lt_mul (by omega))

theorem carryOf_eq_one_iff {b u v : ℕ} (hu : u < b) (hv : v < b) :
    carryOf b u v = 1 ↔ b ≤ u + v := by
  unfold carryOf
  constructor
  · intro h
    by_contra hc
    rw [Nat.div_eq_of_lt (by omega)] at h
    exact absurd h (by omega)
  · intro h
    exact Nat.div_eq_of_lt_le (by omega) (by omega)

/-- The carry bit of the chain is the single-column carry of the augmented column. -/
theorem carry_succ_eq_carryOf (b : ℕ) (x y : ℕ → ℕ) (i : ℕ)
    (hx : x i < b) (hy : y i < b) :
    (if carry b x y (i + 1) then 1 else 0)
      = carryOf b (x i + (if carry b x y i then 1 else 0)) (y i) := by
  have hc1 : (if carry b x y i then 1 else 0) ≤ 1 := by split <;> omega
  have hb : 0 < b := by omega
  rw [carry_succ]
  by_cases h : b ≤ x i + y i + (if carry b x y i then 1 else 0)
  · rw [decide_eq_true h, if_pos rfl]
    unfold carryOf
    exact (Nat.div_eq_of_lt_le (by omega) (by omega)).symm
  · rw [decide_eq_false h]
    simp only [Bool.false_eq_true, if_false]
    unfold carryOf
    rw [Nat.div_eq_of_lt (by omega)]

/-- Key computation: two successive single-column carries add up to the carry of the
three-fold sum. -/
theorem carryOf_add_carryOf (b u v w : ℕ) (hb : 0 < b) :
    carryOf b u v + carryOf b ((u + v) % b) w = (u + v + w) / b := by
  unfold carryOf
  have hsplit : u + v + w = ((u + v) % b + w) + b * ((u + v) / b) := by
    have := Nat.div_add_mod (u + v) b
    omega
  rw [hsplit, Nat.add_mul_div_left _ _ hb]
  omega

/-- **The carry is a 2-cocycle.**  `c(u,v) + c(u+v mod b, w) = c(v,w) + c(u, v+w mod b)`.
Both sides compute `⌊(u+v+w)/b⌋`: carrying is associative.  This is the cocycle
condition for the extension `0 → ℤ/b → ℤ/b² → ℤ/b → 0` whose class is nontrivial
exactly when carrying can occur. -/
theorem carryOf_cocycle (b u v w : ℕ) (hb : 0 < b) :
    carryOf b u v + carryOf b ((u + v) % b) w
      = carryOf b v w + carryOf b u ((v + w) % b) := by
  rw [carryOf_add_carryOf b u v w hb]
  have h2 : carryOf b v w + carryOf b u ((v + w) % b)
      = carryOf b v w + carryOf b ((v + w) % b) u := by
    unfold carryOf
    rw [Nat.add_comm u ((v + w) % b)]
  rw [h2, carryOf_add_carryOf b v w u hb]
  congr 1
  omega

/-- Normalisation: no carry out of a column containing a zero digit. -/
@[simp] theorem carryOf_zero_left (b v : ℕ) (hv : v < b) : carryOf b 0 v = 0 := by
  unfold carryOf
  exact Nat.div_eq_of_lt (by omega)

/-- The cocycle is symmetric — the *single column* is order-free.  Order-sensitivity of
the carry chain (`Signal.comp_not_comm`) is therefore a property of the composition of
columns, not of any one column: it is genuinely sequential information. -/
theorem carryOf_comm (b u v : ℕ) : carryOf b u v = carryOf b v u := by
  unfold carryOf
  rw [Nat.add_comm]

end CarryChain