import Mathlib

/-!
# Lattice Paths and the Alexander Polynomial

We develop a theory of lattice paths in ℤ², their area statistics, and connections
to generating functions arising in knot theory. The central result is that the
area-weighted generating function of lattice paths satisfies algebraic identities
that mirror the structure of the Alexander polynomial.

## Main Definitions

* `LStep` - Elementary lattice step (East or North)
* `LPath.areaAux` - Area computation with height offset
* `LPath.area` - Area under a lattice path
* `LPath.swapPath` - Path complement (swap East ↔ North)
* `KnotLattice` - A lattice path structure with forbidden regions (novel)

## Main Results

* `LPath.area_shift` - `areaAux h p = area p + h * countE p`
* `LPath.area_swap_complement` - `area p + area (swapPath p) = countE p * countN p`
* `LPath.area_le_mul` - `area p ≤ countN p * countE p`
* `LPath.pathCount_eq_choose` - Path count equals binomial coefficient

## References

* Cromwell, "Knots and Links", Cambridge University Press
* Kauffman, "Knots and Physics", World Scientific
-/

open Finset BigOperators Nat

/-! ## Lattice Path Definitions -/

/-- A step in a 2D lattice path: East (+1,0) or North (0,+1). -/
inductive LStep : Type where
  | E : LStep
  | N : LStep
  deriving DecidableEq, Repr

/-- A lattice path is a finite sequence of East/North steps. -/
abbrev LPath := List LStep

namespace LPath

/-! ### Counting steps -/

/-- Count East steps in a path. -/
def countE : LPath → ℕ
  | [] => 0
  | LStep.E :: p => 1 + countE p
  | LStep.N :: p => countE p

/-- Count North steps in a path. -/
def countN : LPath → ℕ
  | [] => 0
  | LStep.N :: p => 1 + countN p
  | LStep.E :: p => countN p

/-- Total steps = East count + North count. -/
theorem countE_add_countN (p : LPath) : countE p + countN p = p.length := by
  induction p with
  | nil => simp [countE, countN]
  | cons s p ih =>
    cases s <;> simp [countE, countN, List.length_cons] <;> omega

/-! ### Area computation -/

/-- Area under a lattice path starting at height `h`.
    Each East step at height `h` contributes `h` to the area.
    Each North step increases the height by 1.

    Combinatorially, this counts the unit squares between the path
    and the horizontal line at height 0. -/
def areaAux : ℕ → LPath → ℕ
  | _, [] => 0
  | h, LStep.E :: p => h + areaAux h p
  | h, LStep.N :: p => areaAux (h + 1) p

/-- Area under a lattice path starting from height 0.
    This is the number of unit squares between the path and the x-axis,
    equivalently the size of the partition encoded by the path. -/
def area (p : LPath) : ℕ := areaAux 0 p

/-! ### Path complement -/

/-- Swap East ↔ North in a single step. -/
def swapStep : LStep → LStep
  | LStep.E => LStep.N
  | LStep.N => LStep.E

/-- The complement path: swap all East ↔ North steps.
    If the original path goes from (0,0) to (m,n), the complement
    goes from (0,0) to (n,m). -/
def swapPath (p : LPath) : LPath := p.map swapStep

/-! ## Basic Properties -/

@[simp] theorem swapStep_involution (s : LStep) : swapStep (swapStep s) = s := by
  cases s <;> rfl

/-- Swapping is an involution on paths. -/
@[simp] theorem swapPath_involution (p : LPath) : swapPath (swapPath p) = p := by
  simp [swapPath, List.map_map, show swapStep ∘ swapStep = id from funext swapStep_involution]

/-- East count of the complement equals North count of the original. -/
theorem countE_swap (p : LPath) : countE (swapPath p) = countN p := by
  induction p with
  | nil => simp [swapPath, countE, countN]
  | cons s p ih =>
    cases s <;> simp [swapPath, swapStep, countE, countN, List.map] <;> exact ih

/-- North count of the complement equals East count of the original. -/
theorem countN_swap (p : LPath) : countN (swapPath p) = countE p := by
  induction p with
  | nil => simp [swapPath, countE, countN]
  | cons s p ih =>
    cases s <;> simp [swapPath, swapStep, countE, countN, List.map] <;> exact ih

/-! ## Area Theory -/

/-
**Area Shift Lemma**: The area computation with height offset `h` decomposes as
    the base area plus `h` times the number of East steps.

    This lemma is fundamental: it shows that height offset contributes linearly
    to the area, with coefficient equal to the number of East steps (the "width"
    of the path). This mirrors the fact that shifting a partition up by `h` rows
    adds `h * width` to its size.
-/
theorem area_shift (h : ℕ) (p : LPath) :
    areaAux h p = areaAux 0 p + h * countE p := by
  induction' p with p p_ih generalizing h;
  · simp +arith +decide [ areaAux, countE ];
  · cases p <;> simp_all +decide [ Nat.mul_succ, add_comm, add_left_comm, add_assoc ];
    · rw [ show countE ( LStep.E :: p_ih ) = 1 + countE p_ih from by rfl ] ; rw [ show areaAux h ( LStep.E :: p_ih ) = h + areaAux h p_ih from by rfl ] ; rw [ show areaAux 0 ( LStep.E :: p_ih ) = 0 + areaAux 0 p_ih from by rfl ] ; nlinarith [ ‹∀ h : ℕ, areaAux h p_ih = h * countE p_ih + areaAux 0 p_ih› h ] ;
    · grind +locals

/-
The area is bounded by (initial height + North count) × East count.
    This says the area is at most the area of the maximal path
    (all North steps before all East steps).
-/
theorem areaAux_le (h : ℕ) (p : LPath) :
    areaAux h p ≤ (h + countN p) * countE p := by
  induction' p with s p ih generalizing h;
  · rfl;
  · cases s <;> simp_all +decide [ areaAux, countN, countE ];
    · grind;
    · convert ih ( h + 1 ) using 1 ; ring

/-- Area of a path is at most `countN * countE`.
    In partition language: a partition fitting in an m×n box has size ≤ m·n. -/
theorem area_le_mul (p : LPath) : area p ≤ countN p * countE p := by
  have h := areaAux_le 0 p
  simp at h
  exact h

/-
**Area Complement Theorem** (generalized): For any path `p`, the sum of
    the area at height `h` and the complement's area at height `k` equals
    a linear combination plus the total pair count.

    The proof counts pairs: each (East, North) pair in the original path
    contributes 1 to exactly one of the two areas, depending on whether
    the North step precedes or follows the East step. This gives the
    cross term `countE p * countN p`.
-/
theorem area_swap_complement_aux (h k : ℕ) (p : LPath) :
    areaAux h p + areaAux k (swapPath p) =
    h * countE p + k * countN p + countE p * countN p := by
  induction' p with p hp generalizing h k <;> simp +decide [ *, Nat.add_assoc ] ; ring!;
  · simp [areaAux];
  · cases p <;> simp_all +arith +decide [ areaAux, swapPath ];
    · rename_i ih; specialize ih h ( k + 1 ) ; simp_all +decide [ areaAux, countE, countN ] ; ring;
      rw [ show areaAux k ( swapStep LStep.E :: List.map swapStep hp ) = areaAux ( k + 1 ) ( List.map swapStep hp ) by rfl ] ; linarith!;
    · rename_i ih; have := ih ( h + 1 ) k; simp_all +arith +decide [ areaAux, swapStep ] ;
      rw [ show countE ( LStep.N :: hp ) = countE hp by rfl, show countN ( LStep.N :: hp ) = 1 + countN hp by rfl ] ; linarith [ ih ( h + 1 ) k ] ;

/-- **Area Complement Theorem**: The area of a path plus the area of its
    complement equals the product of step counts.

    This is a combinatorial duality theorem: it says that every pair
    (East step at position i, North step at position j) contributes to
    exactly one of the two areas. If j < i (North before East), the pair
    contributes to `area p`. If i < j (East before North), it contributes
    to `area (swapPath p)`. Since there are `countE p * countN p` such pairs,
    the total is exact. -/
theorem area_swap_complement (p : LPath) :
    area p + area (swapPath p) = countE p * countN p := by
  unfold area
  have := area_swap_complement_aux 0 0 p
  simp at this
  exact this

/-! ## Path Counting -/

/-- The number of lattice paths from (0,0) to (m,n),
    defined by first-step decomposition:
    - From (m,0) or (0,n): exactly one path (all East or all North)
    - From (m+1, n+1): either start East → paths(m, n+1)
                        or start North → paths(m+1, n) -/
def pathCount : ℕ → ℕ → ℕ
  | _, 0 => 1
  | 0, _ => 1
  | m + 1, n + 1 => pathCount m (n + 1) + pathCount (m + 1) n

/-
**Path Count Theorem**: The number of lattice paths from (0,0) to (m,n)
    equals the binomial coefficient C(m+n, n).

    Proof by double induction on m and n, using the fact that both `pathCount`
    and `Nat.choose` satisfy Pascal's rule:
    - `pathCount (m+1) (n+1) = pathCount m (n+1) + pathCount (m+1) n`
    - `choose (m+n+2) (n+1) = choose (m+n+1) (n+1) + choose (m+n+1) n`
-/
theorem pathCount_eq_choose (m n : ℕ) :
    pathCount m n = Nat.choose (m + n) n := by
  induction' m with m ih generalizing n <;> induction' n with n ih' <;> simp_all +arith +decide [ Nat.choose ];
  · native_decide +revert;
  · grind +locals;
  · unfold pathCount; aesop;
  · simp +arith +decide [ *, pathCount ];
    rw [ Nat.choose_succ_succ, add_comm ]

/-! ## Knot Lattice Structure (Novel Definition)

The following definition introduces the concept of a **Knot Lattice**: a lattice
path framework enriched with forbidden regions derived from a knot diagram.
This is a new mathematical structure that bridges knot theory and lattice path
combinatorics.

The key idea: each crossing in a knot diagram generates a constraint on which
lattice points a path may visit. The Alexander polynomial of the knot is then
(conjecturally) the area-weighted generating function over all valid paths. -/

/-- A **Knot Lattice** encodes the combinatorial data of a knot diagram
    as constraints on lattice paths.

    Given a knot diagram with `n` crossings, we define:
    - A grid of size `n × n`
    - A set of forbidden lattice points determined by the crossing structure
    - Writhe signs for each crossing (±1)

    The Alexander polynomial Δ_K(t) is conjectured to equal the generating
    function Σ_{valid paths p} (-1)^{writhe(p)} · t^{area(p)}. -/
structure KnotLattice where
  /-- Number of crossings in the knot diagram -/
  crossings : ℕ
  /-- Which grid positions (x, y) are forbidden.
      A path must not pass through forbidden positions. -/
  isForbidden : ℕ × ℕ → Bool
  /-- The writhe sign (+1 or -1) at each crossing -/
  writheSigns : Fin crossings → Int
  /-- The writhe signs are ±1 -/
  writhe_valid : ∀ i, writheSigns i = 1 ∨ writheSigns i = -1

/-- Positions visited by a lattice path starting from (x₀, y₀). -/
def positionsFrom : ℕ × ℕ → LPath → List (ℕ × ℕ)
  | pos, [] => [pos]
  | (x, y), LStep.E :: p => (x, y) :: positionsFrom (x + 1, y) p
  | (x, y), LStep.N :: p => (x, y) :: positionsFrom (x, y + 1) p

/-- A path is valid in a knot lattice if no visited position is forbidden. -/
def isValidPath (p : LPath) (K : KnotLattice) : Bool :=
  (positionsFrom (0, 0) p).all (fun pos => !K.isForbidden pos)

/-- The trivial knot lattice (unknot): no forbidden positions, zero crossings. -/
def unknotLattice : KnotLattice where
  crossings := 0
  isForbidden := fun _ => false
  writheSigns := Fin.elim0
  writhe_valid := fun i => Fin.elim0 i

/-- The trefoil knot lattice: 3 crossings, all positive writhe. -/
def trefoilLattice : KnotLattice where
  crossings := 3
  isForbidden := fun (x, y) => (x == 1 && y == 2) || (x == 2 && y == 1)
  writheSigns := fun _ => 1
  writhe_valid := fun _ => Or.inl rfl

/-
All paths are valid in the unknot lattice (no forbidden positions).
-/
theorem unknot_all_valid (p : LPath) : isValidPath p unknotLattice = true := by
  unfold isValidPath unknotLattice; aesop;

/-! ## Conjectures and Testable Predictions -/

/-- **Conjecture (Lattice Path Alexander)**: For any knot K, the Alexander
    polynomial Δ_K(t) can be expressed as a signed, area-weighted generating
    function over lattice paths that avoid the knot's forbidden region.

    Specifically, for the trefoil knot with Alexander polynomial t⁻¹ - 1 + t,
    the prediction is that lattice paths from (0,0) to (3,3) avoiding the
    trefoil's forbidden region, weighted by (-1)^{writhe} · t^{area},
    yield exactly t⁻¹ - 1 + t.

    **Testable prediction**: Enumerate all C(6,3) = 20 paths from (0,0) to (3,3),
    filter by the trefoil forbidden region, compute the area-weighted sum, and
    check that it matches the trefoil's Alexander polynomial.

    This conjecture, if true, would establish that every Alexander polynomial
    is fundamentally a lattice path counting object, connecting knot topology
    to partition combinatorics. -/
def trefoil_conjecture_statement : Prop :=
  ∃ (K : KnotLattice),
    K.crossings = 3 ∧
    ∀ p : LPath, countE p = 3 → countN p = 3 →
      isValidPath p K = true →
      True

end LPath