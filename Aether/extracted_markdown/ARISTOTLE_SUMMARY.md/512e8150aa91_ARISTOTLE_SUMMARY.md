# Summary of changes for run c6a44b9b-bdc2-49c5-9327-5506fc3ad70c
Completed a full research cycle on **Integrated Information via Tensor Networks**, formalizing the algebraic core of IIT for quantum tensor-network states. All work is in `Computation/IIT/` (relative to the Catalog project root), builds cleanly against Mathlib v4.28.0, contains **zero sorries**, and uses only standard axioms (propext, Classical.choice, Quot.sound).

**Central idea**: identify IIT's integrated information Φ of a pure state with the Schmidt rank of its coefficient tensor across a cut, discretized as Φ = rank − 1. This makes IIT's two poles exact linear-algebra facts and bridges to the catalog's existing graph-theoretic IIT (`Shared.CausalIntegration.Core`, where `CausalSystem.phi` is a graph min-cut) — the new `phiMIP` mirrors that same minimum-over-bipartitions architecture with Schmidt rank replacing the cross-cut weight.

**Files (7 theorems, all proved):**
- `Computation/IIT/TensorNetworkSchmidt.lean` (4 theorems): bipartite picture.
  - `phi_productState_eq_zero` — separable states have Φ = 0 (reducibility axiom).
  - `phi_mps_le_bond` — an MPS through a bond of dimension D bounds Φ ≤ D − 1.
  - `phi_mps_bondTwo_le_one` — the concept's explicit bond-2 test case, Φ ≤ 1.
  - `phi_maximallyEntangled_eq` — the maximally entangled d⊗d state attains the extremal Φ = d − 1 (showing the bond bound is tight).
- `Computation/IIT/MultipartiteMIP.lean` (3 theorems): multipartite minimum-information partition.
  - `cutMatrix_rank_le_one_of_product` — a tensor factorizing across a cut has Schmidt rank ≤ 1 there.
  - `phiMIP_eq_zero_of_product_cut` — the minimum-information-partition Φ = 0 whenever any nontrivial cut decouples the state (the tensor analogue of `phi_zero_of_disconnected`).
  - `schmidtRankAt_le_block` — Schmidt rank across a cut is bounded by the complement block dimension d^|Sᶜ| (discrete area-law bound).

Each major theorem carries a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) and a brief `-- !--` proof-sketch comment. 

`Computation/IIT/FUTURE_DIRECTIONS.md` contains the required Synthesis and Results Summary sections plus 5 falsifiable research directions (converse/product characterization, von Neumann mutual-information version, sub-additivity across nested cuts, LOCC-monotonicity as an entanglement-measure test, and tightness of the bond bound), each with a "Why now" justification grounded in the lemmas proved this cycle.

Note on project layout: the active Lean project is the nested `Catalog/` directory (it holds the lakefile/manifest/toolchain); files were placed and verified there.