/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Cellular Automata as Algebraic Geometry: Definitions

Elementary cellular automata (ECAs) are the 256 rules that update a 1D binary array
based on 3-cell neighborhoods. We formalize ECAs as polynomial maps over GF(2) = ZMod 2,
study their fixed-point varieties, and define algebraic invariants that classify rule
complexity.

## Main Definitions

* `ECA.localRule` — The local update function for an ECA rule number
* `ECA.step` — Global update on cyclic binary arrays
* `ECA.IsFixedPoint` — Fixed point predicate
* `ECA.fixedPointSet` — The set of all fixed points
* `ECA.IsLinearRule` — Whether an ECA rule acts linearly over GF(2)
* `ECA.GF2Polynomial3` — Polynomial representation of local rules over GF(2)
-/

open Finset

namespace ECA

/-! ### Local Rule Function -/

/-- The local update function for ECA rule `r ∈ {0, ..., 255}`.
    Maps a 3-cell neighborhood `(left, center, right)` to the new center value.
    The rule number `r` encodes the truth table: bit `4l + 2c + r` of `r`
    gives the output for neighborhood `(l, c, r)`. -/
def localRule (r : ℕ) (left center right : Bool) : Bool :=
  r.testBit ((if left then 4 else 0) + (if center then 2 else 0) + (if right then 1 else 0))

/-- Neighborhood index: maps three booleans to the bit position in the rule number. -/
def neighborhoodIdx (left center right : Bool) : ℕ :=
  (if left then 4 else 0) + (if center then 2 else 0) + (if right then 1 else 0)

theorem neighborhoodIdx_lt_eight (l c r : Bool) : neighborhoodIdx l c r < 8 := by
  unfold neighborhoodIdx
  cases l <;> cases c <;> cases r <;> simp

/-- The local rule can be expressed using the neighborhood index. -/
theorem localRule_eq (r : ℕ) (l c ri : Bool) :
    localRule r l c ri = r.testBit (neighborhoodIdx l c ri) := rfl

/-! ### Global ECA Update -/

/-- Global ECA update function on a cyclic array of `n ≥ 1` cells.
    Each cell is updated simultaneously based on its left and right neighbors
    with cyclic (periodic) boundary conditions. -/
def step (r : ℕ) {n : ℕ} (hn : 0 < n) (s : Fin n → Bool) : Fin n → Bool := fun i =>
  localRule r
    (s ⟨(i.val + n - 1) % n, Nat.mod_lt _ hn⟩)
    (s i)
    (s ⟨(i.val + 1) % n, Nat.mod_lt _ hn⟩)

/-- A state `s` is a fixed point of rule `r` if applying one step leaves it unchanged. -/
def IsFixedPoint (r : ℕ) {n : ℕ} (hn : 0 < n) (s : Fin n → Bool) : Prop :=
  step r hn s = s

/-- The set of all fixed points of rule `r` on `n` cells. -/
def fixedPointSet (r : ℕ) {n : ℕ} (hn : 0 < n) : Set (Fin n → Bool) :=
  {s | IsFixedPoint r hn s}

/-! ### Iterated Dynamics -/

/-- Iterated application of the ECA rule. -/
def iterate (r : ℕ) {n : ℕ} (hn : 0 < n) : ℕ → (Fin n → Bool) → (Fin n → Bool)
  | 0 => id
  | k + 1 => step r hn ∘ iterate r hn k

theorem iterate_zero (r : ℕ) {n : ℕ} (hn : 0 < n) (s : Fin n → Bool) :
    iterate r hn 0 s = s := rfl

theorem iterate_succ (r : ℕ) {n : ℕ} (hn : 0 < n) (k : ℕ) (s : Fin n → Bool) :
    iterate r hn (k + 1) s = step r hn (iterate r hn k s) := rfl

/-- A fixed point is invariant under iteration. -/
theorem fixed_point_iterate {r : ℕ} {n : ℕ} {hn : 0 < n} {s : Fin n → Bool}
    (hfp : IsFixedPoint r hn s) (k : ℕ) :
    iterate r hn k s = s := by
  induction k with
  | zero => rfl
  | succ k ih =>
    simp only [iterate_succ, ih]
    exact hfp

/-! ### Algebraic View over GF(2) -/

/-- Convert a Bool to an element of ZMod 2. -/
def boolToGF2 (b : Bool) : ZMod 2 := if b then 1 else 0

/-- Convert an element of ZMod 2 to Bool. -/
def gf2ToBool (x : ZMod 2) : Bool := x ≠ 0

/-- A state over GF(2) = ZMod 2. This is the algebraic view of a binary state. -/
abbrev GF2State (n : ℕ) := Fin n → ZMod 2

/-- Convert a Bool state to a GF(2) state. -/
def toGF2 {n : ℕ} (s : Fin n → Bool) : GF2State n := boolToGF2 ∘ s

/-- Convert a GF(2) state to a Bool state. -/
def fromGF2 {n : ℕ} (s : GF2State n) : Fin n → Bool := gf2ToBool ∘ s

/-- Round-trip: Bool → GF(2) → Bool is the identity. -/
theorem fromGF2_toGF2 {n : ℕ} (s : Fin n → Bool) : fromGF2 (toGF2 s) = s := by
  ext i
  simp only [fromGF2, toGF2, Function.comp, boolToGF2, gf2ToBool]
  split <;> simp_all

/-! ### Linear Rules -/

/-- An ECA rule is *linear* (over GF(2)) if its local update function
    satisfies `f(l₁ ⊕ l₂, c₁ ⊕ c₂, r₁ ⊕ r₂) = f(l₁,c₁,r₁) ⊕ f(l₂,c₂,r₂)`
    and `f(0,0,0) = 0`. Equivalently, the rule is a GF(2)-linear function
    of its three inputs. -/
def IsLinearRule (r : ℕ) : Prop :=
  localRule r false false false = false ∧
  ∀ l₁ c₁ r₁ l₂ c₂ r₂ : Bool,
    localRule r (xor l₁ l₂) (xor c₁ c₂) (xor r₁ r₂) =
    xor (localRule r l₁ c₁ r₁) (localRule r l₂ c₂ r₂)

/-! ### Complexity Classification -/

/-- Wolfram's complexity classification for ECAs. -/
inductive WolframClass where
  | class1 : WolframClass  -- converges to a uniform state
  | class2 : WolframClass  -- converges to periodic structures
  | class3 : WolframClass  -- chaotic/random behavior
  | class4 : WolframClass  -- complex, localized structures
  deriving DecidableEq, Repr

/-- The all-zero state. -/
def zeroState (n : ℕ) : Fin n → Bool := fun _ => false

/-- The all-one state. -/
def oneState (n : ℕ) : Fin n → Bool := fun _ => true

/-! ### Fixed Point Variety Dimension -/

/-- The fixed-point variety dimension: the log₂ of the number of fixed points.
    This measures the "algebraic complexity" of the rule's fixed-point structure. -/
noncomputable def fixedPointDimension (r : ℕ) (n : ℕ) (hn : 0 < n) : ℕ :=
  Nat.log 2 (Fintype.card {s : Fin n → Bool // IsFixedPoint r hn s})

/-! ### Polynomial Representation -/

/-- Every ECA local rule can be expressed as a degree ≤ 3 polynomial over GF(2).
    The general form is:
      f(l, c, r) = a₀ + a₁l + a₂c + a₃r + a₄lc + a₅lr + a₆cr + a₇lcr
    where aᵢ ∈ GF(2). This structure captures the algebraic normal form (ANF). -/
structure GF2Polynomial3 where
  const : ZMod 2
  coeff_l : ZMod 2
  coeff_c : ZMod 2
  coeff_r : ZMod 2
  coeff_lc : ZMod 2
  coeff_lr : ZMod 2
  coeff_cr : ZMod 2
  coeff_lcr : ZMod 2
  deriving DecidableEq, Repr

/-- Evaluate a GF(2) polynomial at given inputs. -/
def GF2Polynomial3.eval (p : GF2Polynomial3) (l c r : ZMod 2) : ZMod 2 :=
  p.const + p.coeff_l * l + p.coeff_c * c + p.coeff_r * r +
  p.coeff_lc * l * c + p.coeff_lr * l * r + p.coeff_cr * c * r +
  p.coeff_lcr * l * c * r

/-- The degree of a GF(2) polynomial (highest monomial present). -/
def GF2Polynomial3.degree (p : GF2Polynomial3) : ℕ :=
  if p.coeff_lcr ≠ 0 then 3
  else if p.coeff_lc ≠ 0 ∨ p.coeff_lr ≠ 0 ∨ p.coeff_cr ≠ 0 then 2
  else if p.coeff_l ≠ 0 ∨ p.coeff_c ≠ 0 ∨ p.coeff_r ≠ 0 then 1
  else 0

/-- A GF(2) polynomial is linear iff it has no constant term and no higher-order terms. -/
def GF2Polynomial3.isLinear (p : GF2Polynomial3) : Prop :=
  p.const = 0 ∧ p.coeff_lc = 0 ∧ p.coeff_lr = 0 ∧ p.coeff_cr = 0 ∧ p.coeff_lcr = 0

/-! ### Novel Structure: Transfer Matrix -/

/-- The *transfer matrix* of an ECA rule captures the consistency constraints
    for fixed points. For a cyclic array, a state is a fixed point iff the
    transfer matrix raised to the n-th power has a fixed eigenvector.
    We define it as a 4×4 matrix over GF(2), where rows/columns are indexed
    by consecutive cell pairs (sᵢ, sᵢ₊₁). -/
noncomputable def transferMatrix (r : ℕ) : Matrix (Fin 4) (Fin 4) (ZMod 2) := fun row col =>
  let si := if row.val / 2 = 1 then true else false
  let sj := if row.val % 2 = 1 then true else false
  let sk := if col.val % 2 = 1 then true else false
  -- Transition (si, sj) → (sj, sk) is valid if localRule r si sj sk = sj
  -- But we need col.val / 2 = row.val % 2 (overlap condition)
  if col.val / 2 = row.val % 2 then
    if localRule r si sj sk = sj then 1 else 0
  else 0

end ECA