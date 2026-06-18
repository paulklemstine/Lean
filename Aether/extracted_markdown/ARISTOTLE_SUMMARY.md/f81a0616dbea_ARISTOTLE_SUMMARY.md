# Summary of changes for run 150b9c94-13d1-4b23-9ba7-6858ab87764e
Added a new, fully proved Lean 4 file `Catalog/Computation/NaturalProofsBarrier.lean` formalizing the *quantitative core* of the Razborov–Rudich natural proofs barrier, plus the required `FUTURE_DIRECTIONS.md`.

**What the new file does.** It upgrades the existing qualitative skeleton `natural_proof_distinguisher` (in `Catalog/Computation/BarrierFramework.lean`), which only produced a single high-complexity witness function, into a quantitative theory of *distinguishing advantage*. Working over the finite type `BoolFn n = (Fin n → Bool) → Bool` and measuring largeness/advantage in `ℚ`, it defines `density` (fraction of all Boolean functions satisfying a property), `empiricalFreq` (fraction over a class `C`), `advantage`, and `UsefulAgainst`.

**Theorems (all proved, 0 sorries on every result):**
1. `density_nonneg`, `density_le_one` — density is a genuine fraction in [0,1].
2. `useful_empiricalFreq_zero` — a property useful against `C` fires nowhere on `C`.
3. `natural_property_advantage_eq` — for a useful property, distinguishing advantage equals its density.
4. `natural_proofs_distinguish` (main) — a large (`δ ≤ density`) + useful property distinguishes with advantage ≥ `δ`.
5. `razborov_rudich_barrier` (main) — under PRG security (no test beats `δ`), no large + useful property exists; contrapositively, a large + useful constructive property breaks every PRG (the `natural ⟹ ¬PRG` conclusion).
6. `useful_against_all_not_large` (boundary) — usefulness against *all* functions forces density 0, exhibiting the largeness/usefulness tension.
7. `natural_proofs_distinguish_approx` (strengthening) — with only approximate usefulness (frequency ≤ `ρ`), advantage is still ≥ `density − ρ`.

The work synthesizes catalog material across domains: it builds on the natural-proofs/relativization/algebrization skeletons in `Catalog/Computation/BarrierFramework.lean` and the circuit/formula and Shannon-counting machinery in `Catalog/Computation/CircuitBarriers.lean` and `Catalog/Logic/CircuitComplexityBarriers.lean`.

**Verification.** The file compiles cleanly (only `sorry`-free warnings absent), contains no `sorry`, and the main theorems depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

**FUTURE_DIRECTIONS.md** gives 5 falsifiable extensions, each with a "key insight" and "why now" justification: (1) derive largeness automatically from Shannon counting, (2) instantiate `C` as a real PRF-generator image (complexity↔crypto bridge), (3) formalize constructivity via `BoolCircuit` size, (4) a Schwartz–Zippel-based quantitative algebrization barrier, and (5) tightness of the advantage bound via concrete small-`n` witnesses.

Note: the project's `lakefile.toml` library globs (`Computation.+`, etc.) target a non-existent root rather than the `Catalog/` directory, so the new file (like the existing catalog files) is verified by compiling it directly with `lake env lean` rather than via a default `lake build` target.