# Summary of changes for run 8d4f3165-f9ef-4408-813a-e44734c079bb
Completed a cold-start research cycle on **Dream Logic: Non-Monotone Reasoning Where Contradictions Coexist** in the Tropical domain. All work is standard, fully-verified Lean 4 with **0 sorries** and only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`); each module builds cleanly.

New files under `Tropical/DreamLogic/`:

1. **Core.lean** — A Belnap–Ginsberg bilattice built on pairs of tropical reals `DreamVal = ℝ × ℝ` (evidence-for, evidence-against). The knowledge-merge `kjoin` is literally the coordinatewise max-plus (tropical) operation. Proved: `kjoin` is an idempotent/commutative/associative semilattice with the knowledge order as its lub; De Morgan negation `tneg` is involutive, commutes with `kjoin`, and swaps `tand`/`tor`; and `tand`/`tor` form a distributive lattice (commutativity, associativity, idempotence, absorption, distributivity).

2. **Paraconsistency.lean** — A small propositional language (`DForm`) with tropical evidence semantics (`eval`) and a designation-based consequence relation `⊨d`. Proved the base logic is a respectable Tarskian (reflexive, ∨-introduction, ∧-elimination, **monotone**) consequence relation, that contradictions coexist (`coexist`), and the headline **`explosion_fails`**: a contradiction `{A, ¬A}` does not entail an arbitrary `B` (ex contradictione quodlibet fails). `neg_undesignated_of_uncontradicted` localizes the failure of classical logic to exactly the contradictory ("glutty") region.

3. **NonMonotone.lean** — Evidence states merged by the tropical `kmerge` (pointwise `kjoin`), with defeasible support (preponderance of evidence). Proved `kmerge` is the tropical idempotent semilattice, information only grows under merge, and the headline **`nonmonotone_support`**: the *same* tropical max-operation that makes knowledge grow monotonically produces non-monotone retraction of defeasible conclusions. The exact monotone fragment is pinned down by `support_preserved_of_no_new_against` and `support_merge_of_both`.

Lab Notes are embedded as `-- !-- Lab Notes -- !--` comment blocks in each file, recording hypotheses (H1–H5), experiments, insights (e.g. "monotone algebra, non-monotone logic"), and explicit failure analyses — including a corrected false lemma (a "non-positive against-coordinate is safe" claim that fails on negative tropical coordinates, replaced by the correct coordinatewise condition).

`FUTURE_DIRECTIONS.md` outlines five bold, testable conjectures: (C1) a tropical conflation Galois connection / Klein four-group on the bilattice, (C2) a bounded least-fixed-point semantics for stratified defeasible closure, (C3) a sharp quantitative stability-margin characterization of retraction, (C4) collapse to classical logic on the consistent cone, and (C5) a size-independent 1-Lipschitz belief-drift bound.

No prose articles, Python, HTML, or package files were produced, per the constraints.