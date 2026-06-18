# Summary of changes for run 0409c278-44c9-4265-8ab2-cfef7117e65f
# Galois Theory of Cellular Automata: Completed Research Cycle

## Novel Mathematical Structure: The Dynamical Core

I introduced the **Dynamical Core** — a novel mathematical structure that decomposes any endomorphism of a finite set into a bijective core and a transient basin. For any function f: α → α on a finite type, the iterated images form a decreasing tower that stabilizes. The stable limit (the core) is the largest f-invariant subset on which f acts bijectively.

## Lean 4 Proofs (All sorry-free, machine-verified)

### `Novelty/DynCore.lean` — The Dynamical Core Theory (16 theorems)
Key results, all fully proved:
- **`imageTower_antitone`** — The image tower is decreasing
- **`imageTower_stabilizes`** — For finite types, the tower stabilizes
- **`core_maps_to_core`** — f maps the core into itself
- **`core_surjOn`** — f surjects from core onto core  
- **`core_injOn`** — f is injective on the core (KEY: uses pigeonhole at stabilization)
- **`core_bijOn`** — **The Core Bijectivity Theorem**: f restricted to its core is bijective
- **`core_eq_univ_iff`** — The core is everything iff f is bijective
- **`coreDepth_le_card`** — Core depth is bounded by |α|
- **`coreDepth_eq_zero_of_bijective`** — Bijective functions have depth 0

### `Novelty/CAGalois.lean` — CA Reversibility Group (20+ theorems)
Key results, all fully proved:
- **`RevGroup`** — The reversibility group (shift-equivariant permutations) as a formal Subgroup
- **`revGroup_ne_top`** — The reversibility group is a proper subgroup of the full symmetric group
- **`shift_compl_comm`** — Shift and complement commute
- **`reversible_eca_comm`** — All reversible elementary CAs commute with each other
- **`caShift_period`** — The shift has period n
- **`shift_fixed_iff_const`** — Shift fixed points are exactly constant configurations
- **`isShiftEquiv_rule150`** — Rule 150 (XOR-3 CA) is shift-equivariant
- **`shift_core_univ`** / **`compl_core_univ`** — Reversible CAs have full dynamical core

## PEGB Analysis (4 major theorems covered)
Each major theorem has Proof + Example + Generalization + Boundary analysis in RESEARCH_PAPER.md.

## Falsifiable Conjecture
Rule 150 is reversible on ℤ/nℤ iff 3 ∤ n. Computationally verified for n = 1..20 in the demo.

## Deliverables
- **ARTICLE.md** — Popular science article (~2500 words) on the hidden order inside chaos
- **RESEARCH_PAPER.md** — Full research paper with definitions, proofs, PEGB, algorithms
- **FUTURE_DIRECTIONS.md** — 5 self-contained research directions with conjectures and tests
- **demo.py** — 5 interactive demonstrations (reversible rule identification, core computation, commutativity, Rule 150 spectrum, core depth statistics)
- **algorithms.py** — Type-hinted implementations of all core algorithms
- **viz_image_tower.py**, **viz_rule150_spectrum.py** — Matplotlib visualizations
- **PACKAGE.json** — Full package with 3 interactive HTML widgets (CA Core Explorer, Rule 150 Spectrum, ECA Group Explorer)