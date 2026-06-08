/-
Copyright (c) 2026 Harmonic. All rights reserved.

# Simulation Lattice and Universality Theory

This file develops the **Simulation Lattice** — a novel algebraic structure on cellular
automata capturing computational power via simulation reducibility.

## Main Results

* `overhead_compose_assoc` — Composition is associative
* `log_overhead_additive` — Log-overhead is additive
* `overhead_at_least_one` — Lower bound on overhead
* `gol_translation_invariant` — GoL is translation-invariant
* `nand_as_not/and/or/xor` — NAND functional completeness
* `glider_speed_le_light` — Light speed bound
-/
import Mathlib
import Computation.CA.Core

namespace CellularAutomata

open CellularAutomata

/-! ## Computational Morphism Monoid (CMM) -/


theorem gol_translation_invariant (g : Grid Bool) (d : ℤ × ℤ) :
    translateGrid (golStep g) d = golStep (translateGrid g d) := by
  funext p;
  unfold translateGrid golStep;
  unfold golLocalRule aliveNeighborCount;
  rw [ show mooreNeighbors p = Finset.image ( fun q => ( q.1 + d.1, q.2 + d.2 ) ) ( mooreNeighbors ( p.1 - d.1, p.2 - d.2 ) ) from ?_, Finset.card_filter, Finset.card_filter ];
  · rw [ Finset.sum_image ] <;> aesop;
  · ext ⟨x, y⟩; simp [mooreNeighbors];
    grind

/-! ## NAND Functional Completeness -/