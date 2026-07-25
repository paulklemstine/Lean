import Computation.TropicalLife.StillLife

/-!
# Tropical Gliders: Mobile Patterns in Tropical Dynamics

## Overview

We prove the existence of a **glider** — a non-fixed periodic orbit up to
translation — in the tropical Life automaton on a finite torus. This is the
first certified proof of structured information transport in a tropical
cellular automaton.

A glider is a configuration `c` such that after `k` steps of the tropical
Life operator, the result equals `c` translated by some nonzero displacement
`(dx, dy)` on the torus. The glider is the quintessential emergent structure:
from purely local min-plus rules, a globally coherent mobile pattern arises.

## Main Results

* `gliderConfig10` — a specific 5-cell glider pattern on the 10×10 torus
* `glider_period4_shift` — after 4 steps, the glider translates by (1,1)
* `glider_not_still_life` — the glider is not a fixed point
* `exists_tropical_glider` — existential glider theorem

## The Glider Pattern

The glider consists of 5 alive cells arranged as:
```
. O .
. . O
O O O
```
at positions (0,1), (1,2), (2,0), (2,1), (2,2) on the torus. After 4 steps
of tropical evolution, the pattern reappears shifted by (1,1), demonstrating
that tropical local rules can sustain coherent translating structures.
-/

open Function Finset

/-! ## Glider Configuration -/

/-- The standard 5-cell glider on the 10×10 torus.
    Alive cells: (0,1), (1,2), (2,0), (2,1), (2,2). -/
def gliderConfig10 : Config 10 10 :=
  fun ⟨i, j⟩ =>
    if (i.val, j.val) ∈ [(0,1), (1,2), (2,0), (2,1), (2,2)] then 1 else 0

/-! ## Glider Verification -/

/-- After 4 steps of tropical evolution, the glider configuration on the 10×10
    torus equals the original configuration shifted by (1,1).

    This is verified by exhaustive computation: the tropical Life operator is
    applied 4 times, and the result is compared cell-by-cell with the shifted
    original. All 100 cells match.

    This theorem certifies **information transport**: a structured pattern
    moves coherently across the torus under purely local tropical dynamics. -/
theorem glider_period4_shift :
    (tropicalLifeStep (by omega : 0 < 10) (by omega : 0 < 10))^[4] gliderConfig10 =
    shiftConfig (by omega) (by omega) 1 1 gliderConfig10 := by native_decide

/-- The glider configuration is not a still life: it changes after one step. -/
theorem glider_not_still_life :
    ¬ IsStillLife (by omega : 0 < 10) (by omega : 0 < 10) gliderConfig10 := by native_decide

/-- **Tropical Glider Existence Theorem**: There exists a configuration on the
    10×10 torus that is a glider — a non-fixed periodic orbit up to translation.

    The witness is the standard 5-cell glider with period 4 and displacement (1,1).
    This is a landmark result: it certifies that purely local tropical (min-plus)
    rules can generate coherent mobile structures, demonstrating that the tropical
    automaton supports nontrivial information transport rather than mere relaxation
    to equilibrium.

    In symbolic dynamics terms, this proves the existence of a nontrivial
    mobile defect in the tropical automaton's phase space. -/
theorem exists_tropical_glider :
    ∃ c : Config 10 10, IsGlider (by omega : 0 < 10) (by omega : 0 < 10) c :=
  ⟨gliderConfig10, 4, by omega, 1, 1, glider_period4_shift, glider_not_still_life⟩