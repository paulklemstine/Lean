# Summary of changes for run 1299d49a-41ef-4965-9eab-6b4d6ccc0f8e
Created a self-contained, fully verified Lean 4 development plus a research roadmap for the concept "Computational Complexity as Physical Law".

**New file: `Geometry/ComplexityPhysics.lean`** (compiles cleanly, 0 `sorry`, depends only on the standard axioms `propext`/`Classical.choice`/`Quot.sound`). It is organized in five parts, each with brief `-- !-- ... --!--` proof-sketch comments:

- **Part I — Extended Church–Turing closure.** Defines `PolyBounded` (polynomial resource budgets) and proves it is an algebra: `polyBounded_const`, `polyBounded_id`, `polyBounded_add`, `polyBounded_mul`, and the headline `polyBounded_comp` (closure under composition — the formal content of the Extended Church–Turing thesis). `ExtendedChurchTuring` packages the thesis for a resource class.
- **Part II — Reversibility vs. irreversibility.** `reversible_iff_injective` (on a finite state space, bijective ⇔ injective) and `irreversible_decreases_phase_space` (a non-injective endomap strictly shrinks the accessible microstates), plus `reset_not_injective`.
- **Part III — Entropy.** `bitEntropy` (log₂ of state count) with `erasure_lowers_entropy` and `bitEntropy_mono`.
- **Part IV — Maxwell's demon obeys the Second Law.** A `DemonCycle` structure carries Landauer's principle as its one physical postulate; `second_law_holds` proves total entropy never decreases, and `strict_sort_forces_dissipation` shows strict gas sorting forces strictly positive environmental dissipation.
- **Part V — No free demon.** `no_free_demon` proves a demon that sorts strictly while paying zero memory/erasure cost is impossible — the rigorous kernel of the speculative claim that an efficient, dissipation-free Maxwell demon would violate the Second Law.

It also includes a concrete satisfiable `honestDemon` (certifying non-vacuity), worked `example`s, a proved generalization `second_law_multicycle` (aggregate entropy of any finite family of cycles is non-negative), and a boundary witness `idleDemon` showing the strictness hypothesis of `no_free_demon` is essential.

**New file: `FUTURE_DIRECTIONS.md`** — a narrative listing five concrete, falsifiable conjectures that extend the work (deriving Landauer quantitatively, polynomial-hierarchy collapse as a composition fixed point, reversible/Bennett computing, a sharp entropy-deficit bound, and an entropic-search capstone), each with a "The key insight is…" sentence and a "Why now?" justification grounded in the lemmas already proven.

All theorems were verified via a full module build (`Geometry.ComplexityPhysics`) and an axiom check.