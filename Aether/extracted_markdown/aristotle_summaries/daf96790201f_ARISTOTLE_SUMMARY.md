# Summary of changes for run 946125da-7e24-405d-b46e-141bed9b5f2c
This research cycle extended the existing Merkle hashing collision-resistance theory (`Cryptography/MerkleTreeHash.lean`, built on `Cryptography/MerkleDamgard.lean`) by closing two of the open directions from the previous cycle's notes: authentication-path soundness and constructive domain separation. Two new Lean files were added, both building with `sorry = 0` on all results and depending only on standard axioms.

New files:
- `Catalog/Cryptography/MerkleAuthPath.lean` — formalizes Merkle membership proofs (authentication paths). An authentication path is a list of (side-bit, sibling-hash) entries, and verification (`verifyAt`) folds the compression over it. Proved theorems:
  - `verifyAt_joint_injective` — path verification is jointly injective in the opened value and sibling list once the position (side-bit sequence) is fixed; the authentication-path analogue of the catalog's `foldl_joint_injective`.
  - `authPath_soundness` — with injective leaf map and compression, a proof cannot be opened to two different leaves at the same position.
  - `authPath_collision_reduction` — the security reduction: a forged opening yields an explicit leaf-map or compression collision.
  - `verifyAt_allLeft_eq_merkleDamgard` — bridge theorem identifying all-left path verification with the Merkle–Damgård fold, the path-level counterpart of the catalog's comb bridge.
  - plus the supporting `authStep_sib_inj`.

- `Catalog/Cryptography/MerkleDomainSeparation.lean` — shows the `hsep` domain-separation hypothesis of the catalog's `treeHash_inj_domainSeparated` is not an extra assumption but a free encoding. A parity tag (leaves even, nodes odd) is proved to realize it. Proved theorems:
  - `taggedNode_injective`, `taggedLeaf_injective`, `taggedLeaf_ne_taggedNode` (parity separation),
  - `taggedTreeHash_inj_crossShape` — full cross-shape injectivity with no separation hypothesis,
  - `taggedTreeHash_no_cross_shape_collision` — concretely defeats the catalog's `tree_cross_shape_collision_exists` counterexample.

Each file contains Lab Notebook comment blocks (Hypothesis / Result / Insight / Failure analysis) and `!--`-style proof sketches per the requested protocol. `FUTURE_DIRECTIONS.md` was written at the project root with the required `## Synthesis`, `## Results Summary`, and five falsifiable `## Research Directions` (each with Hypothesis / Test / Why now / If true / If false).

Note: the project's `lakefile.toml` was missing the `srcDir = "Catalog"` setting, without which no module in the project resolves or builds (the libraries glob on `Cryptography.+` etc. while the sources live under `Catalog/`). I added that one line so the project — including the existing and new files — compiles.

All ten new theorems were verified via the build and `#print axioms` (only `propext`, `Classical.choice`, `Quot.sound`), with no remaining `sorry`.