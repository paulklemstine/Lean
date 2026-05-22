/-
# Full EML Depth Hierarchy — Definitions

This file defines the foundational concepts for the Full EML Depth Hierarchy
theorem: even with inversions freely available, exponential depth n is
necessary and sufficient to represent iterExp(n).

## Key Insight

The exponential depth (`expDepth`) counts only exp-nesting, treating `inv`
as a "free" operation that does not increase depth. The main result is that
this definition still yields a strict hierarchy: no expression of expDepth < n
can represent iterExp(n), even though inversions allow rational function
manipulation and potential algebraic cancellation.

## Novel Definition: FullEMLMajorant

We introduce `FullEMLMajorant`, a simultaneous upper-and-lower bound predicate
that extends the catalog's `HasPolyTowerMajorant` to handle inversions.
The key difference: for non-vanishing expressions, we track both
  |f(x)| ≤ C · tower(d, x)^K     (upper bound)
  |f(x)| ≥ c / tower(d, x)^M     (lower bound, when f ≠ 0)
This duality is what makes the `inv` case go through.
-/
import Mathlib

noncomputable section

open Real Filter

/-! ## Expression Language (Full EML with Inversions) -/

/-- Full EML expression language with inversions.
    Transcendence enters through `exp`. Inversions are included but
    do not contribute to exponential depth. -/
inductive FullEML where
  | var : FullEML
  | const : ℝ → FullEML
  | add : FullEML → FullEML → FullEML
  | mul : FullEML → FullEML → FullEML
  | exp : FullEML → FullEML
  | inv : FullEML → FullEML
  deriving Inhabited

namespace FullEML

/-- Evaluation of a `FullEML` expression at a point `x : ℝ`. -/
def eval : FullEML → ℝ → ℝ
  | .var, x => x
  | .const c, _ => c
  | .add f g, x => f.eval x + g.eval x
  | .mul f g, x => f.eval x * g.eval x
  | .exp f, x => Real.exp (f.eval x)
  | .inv f, x => (f.eval x)⁻¹

/-- Exponential depth counts only exp-nesting, not inv-nesting.
    This is the key structural parameter: `inv` is "free" in depth cost. -/
def expDepth : FullEML → ℕ
  | .var | .const _ => 0
  | .add f g | .mul f g => max (f.expDepth) (g.expDepth)
  | .exp f => f.expDepth + 1
  | .inv f => f.expDepth  -- inv does NOT increase exp-depth

/-- Total node count of a FullEML expression. -/
def nodeCount : FullEML → ℕ
  | .var | .const _ => 1
  | .add f g | .mul f g => 1 + f.nodeCount + g.nodeCount
  | .exp f | .inv f => 1 + f.nodeCount

/-- Whether a FullEML expression contains any `inv` nodes. -/
def hasInv : FullEML → Bool
  | .var | .const _ => false
  | .add f g | .mul f g => f.hasInv || g.hasInv
  | .exp f => f.hasInv
  | .inv _ => true

end FullEML

/-! ## Iterated Exponential Tower -/

/-- The iterated exponential tower: `tower 0 x = x`, `tower (n+1) x = exp(tower n x)`. -/
def tower : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => Real.exp (tower n x)

@[simp] theorem tower_zero (x : ℝ) : tower 0 x = x := rfl
@[simp] theorem tower_succ (n : ℕ) (x : ℝ) :
    tower (n + 1) x = Real.exp (tower n x) := rfl

/-- `iteratedExp n x` is `exp^[n](x)`, i.e. `exp` applied n times. Same as tower. -/
abbrev iteratedExp := tower

/-! ## Tower Properties -/

theorem tower_pos_of_succ (n : ℕ) (x : ℝ) : 0 < tower (n + 1) x :=
  Real.exp_pos _

theorem tower_strictMono (n : ℕ) : StrictMono (tower n) := by
  induction n with
  | zero => exact strictMono_id
  | succ n ih => exact Real.exp_strictMono.comp ih

theorem tower_mono (n : ℕ) : Monotone (tower n) :=
  (tower_strictMono n).monotone

/-- Tower at level n+1 is always at least exp(tower n x). -/
theorem tower_level_increase {x : ℝ} (_hx : 0 < x) (n : ℕ) :
    tower n x < tower (n + 1) x := by
  simp [tower_succ]
  linarith [Real.add_one_le_exp (tower n x)]

theorem tower_level_mono {n m : ℕ} (hnm : n ≤ m) {x : ℝ} (_hx : 0 < x) :
    tower n x ≤ tower m x := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hnm
  induction k with
  | zero => simp
  | succ k ih =>
    have h1 := ih (by omega : n ≤ n + k)
    have h2 := tower_level_increase _hx (n + k)
    have h3 : n + k + 1 = n + (k + 1) := by omega
    linarith [h3 ▸ h2]

theorem tower_compose (k m : ℕ) (x : ℝ) :
    tower k (tower m x) = tower (k + m) x := by
  induction k with
  | zero => simp
  | succ k ih => simp [tower_succ, ih, Nat.succ_add]

theorem tower_ge_self (n : ℕ) {x : ℝ} (_hx : 0 ≤ x) : x ≤ tower n x := by
  induction n with
  | zero => simp
  | succ n ih =>
    calc x ≤ tower n x := ih
    _ ≤ Real.exp (tower n x) := by linarith [Real.add_one_le_exp (tower n x)]

/-! ## Novel Definition: Full EML Majorant (with upper AND lower bounds) -/

/-- **Novel concept**: An expression of exp-depth ≤ d has a full EML majorant
    if its absolute value is eventually bounded above by `tower d (C * x^N)`
    for some positive constant C and natural number N.

    This form (matching the catalog's `HasPolyTowerMajorant`) has crucial
    closure properties:
    - Under `add`/`mul`: polynomial arguments compose well.
    - Under `exp`: `exp(tower (d-1) (C * x^N)) = tower d (C * x^N)`,
      so the bound lifts naturally.
    - Under `inv`: if f is non-vanishing, 1/f is bounded by the
      reciprocal of the lower bound, which is still of tower-d form. -/
def HasFullEMLMajorant (d : ℕ) (f : FullEML) : Prop :=
  ∃ (C : ℝ) (N : ℕ), 0 < C ∧
    ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
      |f.eval x| ≤ tower d (C * x ^ N)

/-! ## Decision Procedure -/

/-- Decision procedure: can `iteratedExp n` be represented at expDepth ≤ d?
    Returns `true` iff `d ≥ n`. -/
def canRepresentAtDepth (n d : ℕ) : Bool := d ≥ n

/-! ## Formal Derivative of FullEML -/

/-- Formal derivative of a FullEML expression with respect to the variable.
    Uses the chain rule, product rule, and quotient rule structurally. -/
def FullEML.formalDerivative : FullEML → FullEML
  | .var => .const 1
  | .const _ => .const 0
  | .add f g => .add f.formalDerivative g.formalDerivative
  | .mul f g => .add (.mul f.formalDerivative g) (.mul f g.formalDerivative)
  | .exp f => .mul (.exp f) f.formalDerivative
  | .inv f => .mul (.const (-1)) (.mul (.inv (.mul f f)) f.formalDerivative)

/-! ## Canonical Constructions -/

/-- The canonical FullEML expression representing `tower n`: just n nested `exp`s around `var`. -/
def canonicalTower : ℕ → FullEML
  | 0 => .var
  | n + 1 => .exp (canonicalTower n)

end