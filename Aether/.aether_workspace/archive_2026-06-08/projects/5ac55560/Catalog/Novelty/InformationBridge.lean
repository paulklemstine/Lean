import Mathlib
import Novelty.GameOfLife.Defs
import Novelty.GameOfLife.Structure
import Novelty.GameOfLife.Circuits

/-!
# Information-Theoretic Bridge: GoL as a Tropical Computation Engine

## Overview

This file bridges the Game of Life formalization with tropical algebra and
information theory. We establish connections between GoL, tropical thresholds,
and computational universality.

## Main Results

* `GoL.step_tropical_form` — GoL step expressed via tropical thresholds
* `GoL.birth_near_alive` — born cells are near alive cells
* `GoL.isolated_cell_dies` — isolated cells die
* `GoL.overcrowded_cell_dies` — overcrowded cells die
* `GoL.threshold_universality_bridge` — bridge to tropical computation
* `GoL.step_preserves_empty` — empty config is a still life
* `GoL.step_all_alive` — all-alive config maps to all-dead
* `GoL.step_count_local` — quantitative locality
-/

open Finset Function

namespace GoL

/-! ## GoL Step as Boolean Expression -/

/-- The GoL step at a dead cell reduces to the birth rule. -/

theorem survival_is_threshold (n : ℕ) :
    (n == 2 || n == 3 : Bool) = (decide (TropGate.threshold n 2 3 = 1)) := by
  rcases n with ( _ | _ | _ | _ | _ | _ | _ | n ) <;> simp +arith +decide [ TropGate.threshold ]

/-
The GoL birth condition is a tropical threshold test.
-/

theorem birth_is_threshold (n : ℕ) :
    (n == 3 : Bool) = (decide (TropGate.threshold n 3 3 = 1)) := by
  rcases n with ( _ | _ | _ | _ | n ) <;> simp +arith +decide;
  simp +arith +decide [ TropGate.threshold ]

/-! ## Fixed Points -/

/-- The empty configuration (all dead) is a still life. -/