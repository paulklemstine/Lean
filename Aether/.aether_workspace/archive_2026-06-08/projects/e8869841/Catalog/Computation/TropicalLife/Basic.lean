import Mathlib

/-!
# Tropical Game of Life: Core Definitions

## Overview

We define a cellular automaton on finite rectangular tori `Fin m × Fin n` whose
update rule is expressed through tropical (min-plus) primitives. The automaton
implements Conway's Life birth/survival thresholds via the `tropicalThreshold`
function, which uses `min` — the fundamental operation of tropical algebra — to
encode interval membership without classical Boolean case splits.

## Main Definitions

* `Cell m n` — positions on the torus `Fin m × Fin n`
* `Config m n` — configurations assigning a natural number to each cell
* `mooreNeighbors` — the 8 Moore neighbors with toroidal wrapping
* `neighborSum` — sum of neighbor values (tropical product in log-domain)
* `tropicalThreshold` — tropical interval indicator using `min`
* `tropicalLocalRule` — the local update rule for each cell
* `tropicalLifeStep` — the global step operator
* `IsStillLife` — predicate for fixed-point configurations
* `shiftConfig` — translation on the torus
* `IsGlider` — periodic orbit up to translation
* `orbitDiversity` — number of distinct iterates up to time T

## Tropical Interpretation

The key tropical primitive is `tropicalThreshold s lo hi`, defined as
  `min 1 (s + 1 - lo) * min 1 (hi + 1 - s)`
which equals 1 iff `lo ≤ s ≤ hi` and 0 otherwise (using ℕ truncating subtraction).
This replaces classical Boolean threshold comparisons with min-based arithmetic,
connecting the automaton to tropical semiring computation.
-/

open Function Finset

/-! ## Basic Types -/

/-- A cell on the `m × n` torus. -/
abbrev Cell (m n : ℕ) := Fin m × Fin n

/-- A configuration assigns a natural number to each cell. -/
abbrev Config (m n : ℕ) := Cell m n → ℕ

/-! ## Toroidal Wrapping -/

/-- Wrap a natural number into `Fin n` via modular reduction. -/
def wrapFin (i : ℕ) (n : ℕ) (hn : 0 < n) : Fin n :=
  ⟨i % n, Nat.mod_lt i hn⟩

/-! ## Moore Neighborhood -/

/-- The 8 Moore neighbors of a cell on the torus, with periodic boundary conditions. -/
def mooreNeighbors {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (x : Cell m n) :
    List (Cell m n) :=
  let i := x.1.val
  let j := x.2.val
  [ (wrapFin (i + m - 1) m hm, wrapFin (j + n - 1) n hn),
    (wrapFin (i + m - 1) m hm, wrapFin j n hn),
    (wrapFin (i + m - 1) m hm, wrapFin (j + 1) n hn),
    (wrapFin i m hm,           wrapFin (j + n - 1) n hn),
    (wrapFin i m hm,           wrapFin (j + 1) n hn),
    (wrapFin (i + 1) m hm,     wrapFin (j + n - 1) n hn),
    (wrapFin (i + 1) m hm,     wrapFin j n hn),
    (wrapFin (i + 1) m hm,     wrapFin (j + 1) n hn) ]

/-- The number of Moore neighbors is always 8. -/
theorem mooreNeighbors_length {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (x : Cell m n) :
    (mooreNeighbors hm hn x).length = 8 := by
  simp [mooreNeighbors]

/-! ## Neighborhood Aggregation -/

/-- Sum of configuration values over the Moore neighborhood.
    In tropical log-domain, this corresponds to the tropical product of
    neighbor weights. -/
def neighborSum {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (c : Config m n)
    (x : Cell m n) : ℕ :=
  ((mooreNeighbors hm hn x).map c).sum

/-! ## Tropical Threshold -/

/-- Tropical threshold indicator: returns 1 if `lo ≤ s ≤ hi`, else 0.
    Implemented using `min` (the tropical addition operation) and ℕ arithmetic.

    This function is the bridge between tropical algebra and Boolean logic:
    it converts a tropical score into a binary activation signal using only
    `min`, addition, multiplication, and truncating subtraction — all of which
    have natural interpretations in the tropical semiring. -/
def tropicalThreshold (s lo hi : ℕ) : ℕ :=
  min 1 (s + 1 - lo) * min 1 (hi + 1 - s)

theorem tropicalThreshold_eq_one_iff (s lo hi : ℕ) :
    tropicalThreshold s lo hi = 1 ↔ lo ≤ s ∧ s ≤ hi := by
  unfold tropicalThreshold
  rcases Nat.eq_or_lt_of_le (Nat.zero_le (s + 1 - lo)) with h1 | h1
  · -- s + 1 - lo = 0, so s < lo
    simp [← h1]; omega
  · rcases Nat.eq_or_lt_of_le (Nat.zero_le (hi + 1 - s)) with h2 | h2
    · -- hi + 1 - s = 0, so hi < s
      simp [← h2]; omega
    · -- Both positive
      have hA : min 1 (s + 1 - lo) = 1 := by omega
      have hB : min 1 (hi + 1 - s) = 1 := by omega
      simp [hA, hB]; omega

theorem tropicalThreshold_le_one (s lo hi : ℕ) :
    tropicalThreshold s lo hi ≤ 1 := by
  unfold tropicalThreshold
  have h1 : min 1 (s + 1 - lo) ≤ 1 := Nat.min_le_left _ _
  have h2 : min 1 (hi + 1 - s) ≤ 1 := Nat.min_le_left _ _
  calc min 1 (s + 1 - lo) * min 1 (hi + 1 - s)
      ≤ 1 * 1 := Nat.mul_le_mul h1 h2
    _ = 1 := by ring

theorem tropicalThreshold_eq_zero_iff (s lo hi : ℕ) :
    tropicalThreshold s lo hi = 0 ↔ s < lo ∨ hi < s := by
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    have := (tropicalThreshold_eq_one_iff s lo hi).mpr hc
    omega
  · intro h
    unfold tropicalThreshold
    rcases h with h | h
    · have : s + 1 - lo = 0 := by omega
      simp [this]
    · have : hi + 1 - s = 0 := by omega
      simp [this]

/-! ## Tropical Local Rule -/

/-- The tropical local update rule for a single cell.

    The rule implements Conway's Life birth/survival thresholds using
    tropical primitives:
    - **Survival**: if `c x ≥ 1` (alive), the cell survives iff it has 2 or 3
      alive neighbors, detected by `tropicalThreshold s 2 3`.
    - **Birth**: if `c x = 0` (dead), the cell is born iff it has exactly 3
      alive neighbors, detected by `tropicalThreshold s 3 3`.

    The alive/dead status is extracted via `min 1 (c x)`, another tropical operation.
    The full expression uses only `min`, `+`, `*`, and truncating `-`. -/
def tropicalLocalRule {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (c : Config m n)
    (x : Cell m n) : ℕ :=
  let s := neighborSum hm hn c x
  let alive := min 1 (c x)
  alive * tropicalThreshold s 2 3 + (1 - alive) * tropicalThreshold s 3 3

/-! ## Global Step Operator -/

/-- The tropical Life step operator: applies `tropicalLocalRule` to every cell. -/
def tropicalLifeStep {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (c : Config m n) :
    Config m n :=
  fun x => tropicalLocalRule hm hn c x

/-! ## Still Life Predicate -/

/-- A configuration is a **still life** if it is a fixed point of the step operator. -/
def IsStillLife {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (c : Config m n) : Prop :=
  tropicalLifeStep hm hn c = c

/-! ## Translation on the Torus -/

/-- Shift a configuration by `(dx, dy)` on the torus.
    `shiftConfig hm hn dx dy c` at position `(i, j)` returns `c` evaluated
    at `((i - dx) mod m, (j - dy) mod n)`. -/
def shiftConfig {m n : ℕ} (hm : 0 < m) (hn : 0 < n)
    (dx dy : ℕ) (c : Config m n) : Config m n :=
  fun ⟨i, j⟩ => c (wrapFin (i.val + m - dx % m) m hm,
                     wrapFin (j.val + n - dy % n) n hn)

/-! ## Glider Predicate -/

/-- A configuration is a **glider** if it is not a still life, and some iterate
    equals a nontrivial translation of the original configuration. This captures
    a structured mobile pattern: information transport on the torus. -/
def IsGlider {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (c : Config m n) : Prop :=
  ∃ k : ℕ, 0 < k ∧ ∃ dx dy : ℕ,
    (tropicalLifeStep hm hn)^[k] c = shiftConfig hm hn dx dy c ∧
    ¬ IsStillLife hm hn c

/-! ## Binary Valued -/

/-- A configuration is binary-valued if every cell has value 0 or 1. -/
def binaryValued {m n : ℕ} (c : Config m n) : Prop :=
  ∀ x, c x = 0 ∨ c x = 1

/-! ## Orbit Diversity -/

/-- The number of distinct configurations in the orbit prefix `{step^i(c) : i ≤ T}`. -/
def orbitDiversity {m n : ℕ} [DecidableEq (Config m n)] (hm : 0 < m) (hn : 0 < n)
    (T : ℕ) (c : Config m n) : ℕ :=
  ((Finset.range (T + 1)).image (fun t => (tropicalLifeStep hm hn)^[t] c)).card

/-! ## Tropical Algebraic Properties -/

/-- Min is associative (tropical addition is associative). -/
theorem tropical_min_associative_nat (a b c : ℕ) :
    min (min a b) c = min a (min b c) := by omega

/-- Tropical distributivity: min distributes over plus. -/
theorem tropical_distributivity_nat (a b c : ℕ) :
    min a b + c = min (a + c) (b + c) := by omega

/-- Tropical bound: `min a b ≤ a` (projection property). -/
theorem tropical_min_bound (a b : ℕ) : min a b ≤ a := Nat.min_le_left a b

/-! ## Structural Theorems -/

/-- A still life is equivalently characterized by the local rule fixing each cell.
    This converts the global fixed-point condition into a conjunction of local
    tropical constraints. -/
theorem stillLife_iff_local_fixed {m n : ℕ} (hm : 0 < m) (hn : 0 < n)
    (c : Config m n) :
    IsStillLife hm hn c ↔ ∀ x, tropicalLocalRule hm hn c x = c x := by
  simp only [IsStillLife, tropicalLifeStep, funext_iff]

/-- The tropical local rule preserves binary-valuedness. -/
theorem tropicalLocalRule_binary {m n : ℕ} (hm : 0 < m) (hn : 0 < n)
    (c : Config m n) (hc : binaryValued c) (x : Cell m n) :
    tropicalLocalRule hm hn c x = 0 ∨ tropicalLocalRule hm hn c x = 1 := by
  simp only [tropicalLocalRule]
  have hth23 : tropicalThreshold (neighborSum hm hn c x) 2 3 ≤ 1 :=
    tropicalThreshold_le_one _ _ _
  have hth33 : tropicalThreshold (neighborSum hm hn c x) 3 3 ≤ 1 :=
    tropicalThreshold_le_one _ _ _
  have halive : min 1 (c x) = 0 ∨ min 1 (c x) = 1 := by omega
  rcases halive with h | h <;> simp [h] <;> omega

/-- The step operator preserves binary-valuedness. -/
theorem tropicalLifeStep_binary {m n : ℕ} (hm : 0 < m) (hn : 0 < n)
    (c : Config m n) (hc : binaryValued c) :
    binaryValued (tropicalLifeStep hm hn c) := by
  intro x
  exact tropicalLocalRule_binary hm hn c hc x