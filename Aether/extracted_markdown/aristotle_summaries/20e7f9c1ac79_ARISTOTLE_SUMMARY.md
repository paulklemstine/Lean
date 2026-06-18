# Summary of changes for run 45a730f9-95f9-47f0-b46f-1322de1eac08
## Cellular Automata at the Ordinals: Transfinite Computation

I produced a new, fully-proved Lean 4 file plus a research roadmap, building directly on the catalog's existing ℕ-indexed transfinite-CA work and Mathlib's ordinal fixed-point machinery.

### Deliverables
- **`Catalog/Bridges/OrdinalCellularAutomata.lean`** — a self-contained development (15 theorems, **zero `sorry` on every result**, no `native_decide`/`exact?`/`decide` shortcuts). It introduces genuine *ordinal-time* CA semantics: a transfinite cellular automaton is a monotone global operator `F : Set α →o Set α`, run as `ordRun F o := lfpApprox F ⊥ o`, taking unions at limit ordinals (the Infinite-Time / ITTM semantics).
- **`FUTURE_DIRECTIONS.md`** — with the required `## Synthesis`, `## Results Summary`, and 5 falsifiable `## Research Directions` (each with a key insight and a "Why now?" justification).

### Main theorems
1. **Clockable Ordinal Theorem** (`ordRun_halts`, `ordRun_eq_lfp`, `ordRun_const_after`, `ordRun_isLeast`): every monotone transfinite CA reaches a genuine fixed point at the bounded ordinal `ord(succ #(Set α))`, stays constant forever after, and the halting configuration is exactly the least CA-closed configuration — the CA analogue of ITTM clockable-ordinal boundedness.
2. **Super-Turing Gap** (`succCA_transfinite_gap`, with `succCA_stage_nat`, `succCA_omega_eq_univ`, `succCA_lfp_eq_univ`): a concrete CA whose clockable ordinal is exactly ω — every finite stage is finite, yet the first limit stage computes the whole space, something no finite iteration can.
3. **Clockable ordinal above ω** (`clockable_above_omega`, with `flagCA_stage_nat`, `flagCA_omega`): an explicit "completion-flag" CA whose ω-stage is *not* a fixed point (its flag cell can only fire after infinitely many cells are active), so its clockable ordinal is ω+1. This was initially posed as an open conjecture and was *resolved within the cycle*.

### Notes & relationship to the catalog
The file cross-references and extends `Catalog/Computation/TransfiniteCA.lean` and `TransfiniteCADepth.lean` (whose ℕ-"levels" each correspond to one ω-step). The structural insight, recorded in the in-file Lab Notebook blocks and the synthesis, is that **monotonicity** is the dividing line: it makes the limit-stage union the correct semantics and lets Mathlib's `lfpApprox` pigeonhole transport to CA, whereas the catalog's non-monotone lim-inf rules fall outside this theory (flagged as Direction 5 for the next cycle). Each major theorem carries a brief `-- !--` proof sketch and a full Lab Notebook block (Hypothesis / Result / Insight / Failure analysis).

All proofs were verified to compile cleanly via the language server with no errors or warnings, and the file contains no axioms beyond the standard `propext`, `Classical.choice`, `Quot.sound`.