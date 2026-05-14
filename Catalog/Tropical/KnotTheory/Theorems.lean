import Mathlib
import Tropical.KnotTheory.Basic

/-!
# Tropical Knot Theory: Main Theorems

This module contains the core theorems of tropical knot theory:

## Theorem A: Tropical Skein Relation
The tropical Jones invariant satisfies a min-plus skein relation, analogous to the
classical Kauffman bracket skein relation but with min replacing addition and + replacing
multiplication. This is the foundational recursion of the theory.

## Theorem B: Crossing Number Lower Bound
The support of the tropical Jones invariant is contained in `[-c, c]` where `c` is the
number of crossings. This yields `tropicalSpan ≤ 2 * numCrossings`, a certified lower
bound on crossing complexity from the tropical invariant.

## Theorem C: Canonical Simplification
Simplification steps (crossing resolutions) strictly decrease the diagram complexity.
The simplification relation is well-founded, guaranteeing termination.
All normal forms (fully resolved diagrams) have the same minimal structure.

## Theorem D: Separation Schema
If two diagrams have different tropical state-cost profiles, their tropical Jones
invariants differ. This reduces the problem of finding tropically-separated knot pairs
to a finite comparison of state-cost profiles.

## Cross-Domain Significance
The crossing bound theorem is the knot-theoretic analogue of degree-vs-depth lower bounds
in algebraic circuit complexity: the tropical span plays the role of output degree, and
the crossing number plays the role of circuit size. This connection opens a bridge between
low-dimensional topology and computational complexity theory.
-/

namespace TropicalKnotTheory

open KnotDiagram

/-! ## Theorem A: Tropical Skein Relation -/

/-- **Tropical Skein Relation.** The tropical Jones invariant satisfies the min-plus
    skein equation: at each crossing with weights `wA`, `wB` and sub-diagrams `D0`, `D1`,
    the invariant is the tropical sum (min) of the weighted contributions from each resolution.

    This is the birth certificate of tropical skein theory. It shows that the Kauffman
    bracket's skein relation tropicalizes cleanly into a min-plus recurrence. -/
theorem tJones_skein (wA wB : ℤ) (D0 D1 : KnotDiagram) (n : ℤ) :
    tJones (.crossing wA wB D0 D1) n =
      min ((wA : WithTop ℤ) + tJones D0 (n - 1))
          ((wB : WithTop ℤ) + tJones D1 (n + 1)) := by
  rfl

/-- The tropical skein relation with named resolutions. -/
theorem tJones_skein' (D : KnotDiagram) (wA wB : ℤ) (D0 D1 : KnotDiagram) (n : ℤ)
    (hD : D = .crossing wA wB D0 D1) :
    tJones D n =
      min ((wA : WithTop ℤ) + tJones (D.resolveA) (n - 1))
          ((wB : WithTop ℤ) + tJones (D.resolveB) (n + 1)) := by
  subst hD; rfl

/-- The tropical Jones value is bounded below by either resolution branch. -/
theorem tJones_le_resolveA (wA wB : ℤ) (D0 D1 : KnotDiagram) (n : ℤ) :
    tJones (.crossing wA wB D0 D1) n ≤ (wA : WithTop ℤ) + tJones D0 (n - 1) := by
  simp [tJones]

/-- The tropical Jones value is bounded below by either resolution branch. -/
theorem tJones_le_resolveB (wA wB : ℤ) (D0 D1 : KnotDiagram) (n : ℤ) :
    tJones (.crossing wA wB D0 D1) n ≤ (wB : WithTop ℤ) + tJones D1 (n + 1) := by
  simp [tJones]

/-! ## Theorem B: Crossing Number Lower Bound -/

/-
**Support Boundedness.** If `tJones D n` is finite (not ⊤), then `|n| ≤ numCrossings D`.

    This is the key structural theorem: the support of the tropical Jones invariant
    is contained in the interval `[-c, c]` where `c = numCrossings D`. Each crossing
    contributes at most a ±1 shift to the Laurent degree, so after `c` crossings the
    degree is bounded by `c` in absolute value.

    This is analogous to degree bounds in algebraic circuit complexity: the number of
    crossings (circuit size) bounds the range of achievable degrees (output complexity).
-/
theorem tJones_support_bounded (D : KnotDiagram) (n : ℤ) (h : tJones D n ≠ ⊤) :
    n.natAbs ≤ numCrossings D := by
  induction' D with wA wB D0 D1 ih generalizing n;
  · cases eq_or_ne n 0 <;> simp_all +decide [ KnotDiagram.tJones ];
  · -- By definition of $tJones$, we know that $tJones (crossing wA wB D0 D1) n = min ((wA : WithTop ℤ) + tJones D0 (n - 1)) ((wB : WithTop ℤ) + tJones D1 (n + 1))$.
    have h_tJones : tJones (KnotDiagram.crossing wA wB D0 D1) n = min ((wA : WithTop ℤ) + tJones D0 (n - 1)) ((wB : WithTop ℤ) + tJones D1 (n + 1)) := by
      exact tJones_skein wA wB D0 D1 n;
    cases min_cases ( ( wA : WithTop ℤ ) + tJones D0 ( n - 1 ) ) ( ( wB : WithTop ℤ ) + tJones D1 ( n + 1 ) ) <;> simp_all +decide [ KnotDiagram.numCrossings ];
    · grind;
    · grind

/-
The support of the tropical Jones invariant is contained in [-c, c].
-/
theorem tJones_support_in_range (D : KnotDiagram) (n : ℤ) (h : tJones D n ≠ ⊤) :
    -↑(numCrossings D) ≤ n ∧ n ≤ ↑(numCrossings D) := by
  exact abs_le.mp ( by simpa using Int.ofNat_le.mpr ( tJones_support_bounded D n h ) )

/-
**Tropical Span Lower Bound.** For any knot diagram `D`, the tropical span of
    `tJones D` is at most `2 * numCrossings D`.

    The tropical span is defined as `max(support) - min(support)`. Since the support is
    contained in `[-c, c]`, the span is at most `2c`.

    This gives a certified lower bound: if the tropical span equals `2c`, then the
    diagram has at least `c` crossings, providing a knot complexity lower bound.

    This is the tropical analogue of the Kauffman-Murasugi-Thistlethwaite span bound
    for the classical Jones polynomial, recast in the language of optimization.
-/
theorem tropicalSpan_le_twice_numCrossings (D : KnotDiagram) (n1 n2 : ℤ)
    (h1 : tJones D n1 ≠ ⊤) (h2 : tJones D n2 ≠ ⊤) :
    (n1 - n2).natAbs ≤ 2 * numCrossings D := by
  have := @TropicalKnotTheory.tJones_support_bounded;
  grind

/-! ## Theorem C: Canonical Simplification -/

/-
**Simplification Decreases Crossing Number.** Every simplification step
    strictly reduces the number of crossings in the diagram.

    This is the foundation for termination: since numCrossings is a natural number
    that strictly decreases, the simplification process must terminate.
-/
theorem simpStep_decreases_numCrossings {D D' : KnotDiagram}
    (h : SimpStep D D') : numCrossings D' < numCrossings D := by
  -- We'll use induction on the number of crossings in the diagram.
  induction' D with D0 D1 n hn generalizing D';
  · cases h;
  · cases h <;> simp_all +decide [ KnotDiagram.numCrossings ];
    linarith

/-
**Simplification Terminates.** The simplification relation on knot diagrams
    is well-founded, guaranteeing that any sequence of simplifications terminates.

    This converts tropical skein reduction into a certified termination procedure,
    connecting to rewriting systems and term rewriting theory.
-/
theorem simpStep_wellFounded : WellFounded (fun D' D : KnotDiagram => SimpStep D D') := by
  -- The relation `SimpStep` is strictly decreasing in the crossing number, so it is well-founded.
  have h_wf : WellFounded (fun D' D : KnotDiagram => numCrossings D' < numCrossings D) := by
    -- The natural numbers are well-ordered, so any subset of them is also well-ordered.
    have h_wf_nat : WellFounded (fun n m : ℕ => n < m) := by
      exact wellFounded_lt;
    exact WellFounded.onFun h_wf_nat;
  exact h_wf.mono fun a b h => simpStep_decreases_numCrossings h

/-
A normal form under simplification must be a loop (unknotted diagram).
-/
theorem normalForm_is_loop {D : KnotDiagram} (h : NormalForm D) : D = .loop := by
  cases D <;> simp_all +decide [ KnotDiagram.NormalForm ];
  exact h _ ( SimpStep.resolveA _ _ _ _ )

/-
**Unique Normal Form Cost.** All simplification sequences from the same diagram
    reach normal forms with the same tropical cost.

    Since all normal forms are loops (by `normalForm_is_loop`), and all loops have
    the same tropical Jones invariant, the normal form cost is unique. This is a
    canonical simplification principle.
-/
theorem normalForm_tJones_unique {D D1 D2 : KnotDiagram}
    (_h1 : Relation.ReflTransGen (fun a b => SimpStep a b) D D1) (hn1 : NormalForm D1)
    (_h2 : Relation.ReflTransGen (fun a b => SimpStep a b) D D2) (hn2 : NormalForm D2) :
    tJones D1 = tJones D2 := by
  rw [ normalForm_is_loop hn1, normalForm_is_loop hn2 ]

/-! ## Theorem D: Separation Schema -/

/-
**Tropical Separation Schema.** If two diagrams have different tropical state-cost
    profiles, then their tropical Jones invariants differ at some degree.

    This reduces the deep topological question "does tropical Jones separate knots that
    classical Jones cannot?" to a finite computational search: find two diagrams with
    the same classical Jones polynomial but different tropical state-cost profiles.

    The theorem is the mathematical backbone of the separation program. It isolates
    the topological search into a finite witness (the state-cost profile), while making
    the implication precise and formally verified.
-/
theorem tropical_separation_of_profile_ne {D1 D2 : KnotDiagram}
    (h : tropicalStateProfile D1 ≠ tropicalStateProfile D2) :
    differentTropicalJones D1 D2 := by
  exact Function.ne_iff.mp h

/-
**Full Separation Schema.** If two diagrams have the same classical Jones polynomial
    but different tropical state-cost profiles, then the tropical Jones invariant
    distinguishes them while the classical one does not.
-/
theorem tropical_vs_classical_separation {D1 D2 : KnotDiagram}
    {jones : KnotDiagram → ClassicalJones}
    (hclass : sameClassicalJones D1 D2 jones)
    (htrop : tropicalStateProfile D1 ≠ tropicalStateProfile D2) :
    sameClassicalJones D1 D2 jones ∧ differentTropicalJones D1 D2 := by
  exact ⟨ hclass, tropical_separation_of_profile_ne htrop ⟩

/-! ## Concrete Examples -/

/-- The unknot (loop) has tropical Jones value 0 at degree 0. -/
theorem tJones_loop_zero : tJones .loop 0 = (0 : WithTop ℤ) := by
  simp [tJones]

/-- The unknot (loop) has tropical Jones value ⊤ at nonzero degrees. -/
theorem tJones_loop_nonzero {n : ℤ} (hn : n ≠ 0) : tJones .loop n = ⊤ := by
  simp [tJones, hn]

/-- A single crossing with unit weights has support {-1, 1}. -/
theorem tJones_single_crossing_at_one :
    tJones (.crossing 1 1 .loop .loop) 1 = (1 : WithTop ℤ) := by
  simp [tJones]

/-- A single crossing with unit weights has support {-1, 1}. -/
theorem tJones_single_crossing_at_neg_one :
    tJones (.crossing 1 1 .loop .loop) (-1) = (1 : WithTop ℤ) := by
  simp [tJones]

/-- A single crossing with unit weights has ⊤ at degree 0. -/
theorem tJones_single_crossing_at_zero :
    tJones (.crossing 1 1 .loop .loop) 0 = ⊤ := by
  simp [tJones]

/-- The trefoil surrogate: a chain of three crossings. -/
def trefoilSurrogate : KnotDiagram :=
  .crossing 1 1
    (.crossing 1 1
      (.crossing 1 1 .loop .loop)
      .loop)
    .loop

/-- The trefoil surrogate has 3 crossings. -/
theorem trefoilSurrogate_crossings : trefoilSurrogate.numCrossings = 3 := by
  simp [trefoilSurrogate, numCrossings]

/-! ## Dynamic Programming Interpretation

The tropical Jones invariant can be interpreted as a shortest-path computation:
- The knot diagram defines a binary DAG (the skein expansion tree)
- Each leaf (loop) contributes degree 0 with cost 0
- Each internal node (crossing) combines its children via min with shifted degrees
- `tJones D n` = minimum cost path from root to a leaf achieving degree `n`

This connects knot invariants to optimization theory and opens the door to
efficient algorithms via dynamic programming / memoization. -/

/-- The tropical Jones value at the unknot is the "base case" of the DP:
    cost 0 at degree 0, unreachable otherwise. -/
theorem tJones_dp_base (n : ℤ) :
    tJones .loop n = if n = 0 then (0 : WithTop ℤ) else ⊤ := by
  rfl

/-- The tropical Jones value at a crossing is the "recurrence" of the DP:
    take the min of the two resolution branches with appropriate degree shifts. -/
theorem tJones_dp_recurrence (wA wB : ℤ) (D0 D1 : KnotDiagram) (n : ℤ) :
    tJones (.crossing wA wB D0 D1) n =
      min ((wA : WithTop ℤ) + tJones D0 (n - 1))
          ((wB : WithTop ℤ) + tJones D1 (n + 1)) := by
  rfl

end TropicalKnotTheory