import Mathlib

/-!
# Monotone Min-Max Circuits

This module develops a formally verified theory of **monotone min-max circuits** — a
computational model where gates compute `min` (AND) and `max` (OR) over linearly ordered types.
These circuits generalize monotone Boolean circuits to numerical domains and serve as the
algebraic skeleton of tropical computation, dynamic programming, and lattice-valued
decision architectures.

## Main Definitions

- `MonotoneCircuit α n` — Inductive type of circuits with `n` input variables over type `α`,
  built from variables, constants, min-gates (AND), and max-gates (OR).
- `MonotoneCircuit.eval` — Semantics: evaluates a circuit given an assignment `Fin n → α`.
- `MonotoneCircuit.size` — Number of nodes in the circuit tree.
- `MonotoneCircuit.depth` — Depth (longest root-to-leaf path) of the circuit tree.

## Main Results

### Monotonicity
- `MonotoneCircuit.eval_mono` — Every circuit computes a coordinatewise monotone function.
- `MonotoneCircuit.eval_monotone` — The `Monotone` version of the above.

### Gate Bounds
- `MonotoneCircuit.eval_and_le_left` / `eval_and_le_right` — AND gates are bounded by inputs.
- `MonotoneCircuit.le_eval_or_left` / `le_eval_or_right` — OR gates bound inputs.

### Distributive Laws
- `MonotoneCircuit.eval_and_or_distrib` — `min(a, max(b,c)) = max(min(a,b), min(a,c))`
- `MonotoneCircuit.eval_or_and_distrib` — `max(a, min(b,c)) = min(max(a,b), max(a,c))`

### 1-Lipschitz Stability
- `MonotoneCircuit.eval_le_of_coordwise_le_add` — Circuit evaluation is 1-Lipschitz in
  the sup norm over `ℝ`: if all inputs differ by at most `ε`, so does the output.

## References

These circuits formalize the computational model studied in monotone circuit complexity
theory and tropical mathematics. The monotonicity theorem identifies them as certified
models of positive computation, while the Lipschitz theorem establishes robust stability.
-/

noncomputable section

open Finset

/-! ## Circuit Definition -/

/-- A monotone min-max circuit with `n` input variables over type `α`.
  - `var i` reads the `i`-th input
  - `const c` is a constant gate
  - `and c₁ c₂` computes `min` of two subcircuits (conjunction / tropical AND)
  - `or c₁ c₂` computes `max` of two subcircuits (disjunction / tropical OR) -/
inductive MonotoneCircuit (α : Type*) (n : ℕ) where
  | var   : Fin n → MonotoneCircuit α n
  | const : α → MonotoneCircuit α n
  | and   : MonotoneCircuit α n → MonotoneCircuit α n → MonotoneCircuit α n
  | or    : MonotoneCircuit α n → MonotoneCircuit α n → MonotoneCircuit α n
  deriving Repr

namespace MonotoneCircuit

/-! ## Semantics -/

/-- Evaluate a monotone circuit on an input assignment.
  Variables map to their assigned values, constants to themselves,
  AND gates compute `min`, OR gates compute `max`. -/
def eval {α : Type*} [LinearOrder α] {n : ℕ} :
    MonotoneCircuit α n → (Fin n → α) → α
  | var i, x => x i
  | const c, _ => c
  | and c₁ c₂, x => min (eval c₁ x) (eval c₂ x)
  | or c₁ c₂, x => max (eval c₁ x) (eval c₂ x)

/-! ## Structural Metrics -/

/-- The number of nodes in the circuit tree. -/
def size {α : Type*} {n : ℕ} : MonotoneCircuit α n → ℕ
  | var _ => 1
  | const _ => 1
  | and c₁ c₂ => 1 + size c₁ + size c₂
  | or c₁ c₂ => 1 + size c₁ + size c₂

/-- The depth (height) of the circuit tree. -/
def depth {α : Type*} {n : ℕ} : MonotoneCircuit α n → ℕ
  | var _ => 0
  | const _ => 0
  | and c₁ c₂ => 1 + max (depth c₁) (depth c₂)
  | or c₁ c₂ => 1 + max (depth c₁) (depth c₂)

/-! ## Gate Order Bounds -/

/-
An AND gate (min) is bounded above by its left input.
-/
theorem eval_and_le_left {α : Type*} [LinearOrder α] {n : ℕ}
    (c₁ c₂ : MonotoneCircuit α n) (x : Fin n → α) :
    eval (and c₁ c₂) x ≤ eval c₁ x := by
  exact min_le_left _ _

/-
An AND gate (min) is bounded above by its right input.
-/
theorem eval_and_le_right {α : Type*} [LinearOrder α] {n : ℕ}
    (c₁ c₂ : MonotoneCircuit α n) (x : Fin n → α) :
    eval (and c₁ c₂) x ≤ eval c₂ x := by
  grind +locals

/-
An OR gate (max) is bounded below by its left input.
-/
theorem le_eval_or_left {α : Type*} [LinearOrder α] {n : ℕ}
    (c₁ c₂ : MonotoneCircuit α n) (x : Fin n → α) :
    eval c₁ x ≤ eval (or c₁ c₂) x := by
  exact le_max_left _ _

/-
An OR gate (max) is bounded below by its right input.
-/
theorem le_eval_or_right {α : Type*} [LinearOrder α] {n : ℕ}
    (c₁ c₂ : MonotoneCircuit α n) (x : Fin n → α) :
    eval c₂ x ≤ eval (or c₁ c₂) x := by
  exact le_max_right _ _

/-! ## Monotonicity Theorems -/

/-
**Semantic Monotonicity (pointwise form).**
Every monotone circuit computes a coordinatewise monotone function:
if every input coordinate increases, the output does not decrease.

This is proved by structural induction on the circuit:
- Variables and constants are trivially monotone.
- `min` and `max` preserve monotonicity by `min_le_min` and `max_le_max`.
-/
theorem eval_mono {α : Type*} [LinearOrder α] {n : ℕ}
    (c : MonotoneCircuit α n)
    {x y : Fin n → α}
    (hxy : ∀ i, x i ≤ y i) :
    eval c x ≤ eval c y := by
  induction' c with i c₁ c₂ ih₁ ih₂ generalizing x y;
  · exact hxy i;
  · rfl;
  · exact min_le_min ( ih₂ hxy ) ( by solve_by_elim );
  · exact max_le_max ( by solve_by_elim ) ( by solve_by_elim )

/-
**Semantic Monotonicity (Monotone form).**
The evaluation function of any monotone circuit is `Monotone` on the
pointwise-ordered function space `Fin n → α`.
-/
theorem eval_monotone {α : Type*} [LinearOrder α] {n : ℕ}
    (c : MonotoneCircuit α n) :
    Monotone fun x : Fin n → α => eval c x := by
  exact fun x y hxy => eval_mono _ fun i => hxy i

/-! ## Distributive Law Soundness -/

/-
**Left distributivity of AND over OR.**
`min(a, max(b, c)) = max(min(a, b), min(a, c))` — this is the
standard distributive law in any linear order (which forms a
distributive lattice).
-/
theorem eval_and_or_distrib {α : Type*} [LinearOrder α] {n : ℕ}
    (a b c : MonotoneCircuit α n) (x : Fin n → α) :
    eval (and a (or b c)) x = eval (or (and a b) (and a c)) x := by
  exact min_max_distrib_left _ _ _

/-
**Left distributivity of OR over AND.**
`max(a, min(b, c)) = min(max(a, b), max(a, c))` — the dual
distributive law in a linear order.
-/
theorem eval_or_and_distrib {α : Type*} [LinearOrder α] {n : ℕ}
    (a b c : MonotoneCircuit α n) (x : Fin n → α) :
    eval (or a (and b c)) x = eval (and (or a b) (or a c)) x := by
  grind +locals

/-! ## 1-Lipschitz Stability -/

/-
Auxiliary: `|max(a,b) - max(c,d)| ≤ max(|a-c|, |b-d|)` for reals.
-/
theorem abs_max_sub_max_le (a b c d : ℝ) :
    |max a b - max c d| ≤ max (|a - c|) (|b - d|) := by
  grind

/-
**1-Lipschitz stability in the sup norm.**
If every input coordinate changes by at most `ε`, the circuit output
changes by at most `ε`. This says monotone circuits are nonexpansive
(1-Lipschitz) maps from `(Fin n → ℝ, ‖·‖_∞)` to `(ℝ, |·|)`.

Proved by structural induction:
- For variables: immediate from coordinate bound.
- For constants: the difference is zero.
- For AND (min): use `abs_min_sub_min_le` and transitivity.
- For OR (max): use `abs_max_sub_max_le` and transitivity.
-/
theorem eval_le_of_coordwise_le_add {n : ℕ} (c : MonotoneCircuit ℝ n)
    {x y : Fin n → ℝ} {ε : ℝ}
    (hε : 0 ≤ ε)
    (hxy : ∀ i, |x i - y i| ≤ ε) :
    |eval c x - eval c y| ≤ ε := by
  induction' c with c₁ c₂ ih₁ ih₂ <;> norm_num at *;
  · exact hxy _;
  · exact le_trans ( by norm_num [ MonotoneCircuit.eval ] ) hε;
  · -- Apply the induction hypothesis to the subcircuits.
    have h_ind : |min (ih₁.eval x) (ih₂.eval x) - min (ih₁.eval y) (ih₂.eval y)| ≤ max (|ih₁.eval x - ih₁.eval y|) (|ih₂.eval x - ih₂.eval y|) := by
      cases min_cases ( ih₁.eval x ) ( ih₂.eval x ) <;> cases min_cases ( ih₁.eval y ) ( ih₂.eval y ) <;> cases max_cases |ih₁.eval x - ih₁.eval y| |ih₂.eval x - ih₂.eval y| <;> cases abs_cases ( min ( ih₁.eval x ) ( ih₂.eval x ) - min ( ih₁.eval y ) ( ih₂.eval y ) ) <;> cases abs_cases ( ih₁.eval x - ih₁.eval y ) <;> cases abs_cases ( ih₂.eval x - ih₂.eval y ) <;> linarith;
    exact h_ind.trans ( max_le ‹_› ‹_› );
  · rename_i c₁ c₂ hc₁ hc₂;
    convert abs_max_sub_max_le _ _ _ _ |> le_trans <| max_le hc₁ hc₂ using 1

end MonotoneCircuit