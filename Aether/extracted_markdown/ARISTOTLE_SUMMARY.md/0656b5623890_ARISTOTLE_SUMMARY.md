# Summary of changes for run 4e0964da-56bf-4314-8cab-95e1fc56b18d
## What was done

This research cycle extends the existing linear Merkle–Damgård collision-resistance theory in `Catalog/Cryptography/MerkleDamgard.lean` (the `CryptoHash` namespace, whose theorems were already complete/`sorry`-free). I added a new cross-domain (Algebra ⇄ Cryptography) file:

**New file:** `Catalog/Algebra/MerkleDamgardAction.lean` (module `Algebra.MerkleDamgardAction`), which builds on the catalog via `import Cryptography.MerkleDamgard` and reuses its `merkleDamgard`, `merkleDamgard_append`, and `foldl_joint_injective`.

**Core idea:** reinterpret a message `m` as the state transformation `a ↦ merkleDamgard f a m ∈ Function.End α`. Domain extension then becomes an algebraic action law, and the catalog's fixed-IV collision lemmas upgrade to IV-independent algebraic statements.

**Proved theorems (no `sorry`):**
- `mdEnd`, `mdEnd_apply`, `mdEnd_nil` — the message-as-transformation viewpoint and its identity law.
- `mdEnd_append` — concatenation composes transformations in reverse order (algebraic form of `merkleDamgard_append`).
- `mdHom` — packages the whole construction as a monoid homomorphism `FreeMonoid β →* (Function.End α)ᵐᵒᵖ`; domain extension is exactly `map_mul`.
- `mdHom_apply` — evaluating the hom recovers `merkleDamgard`.
- `mdEnd_injOn_length` (main result) — injective compression ⇒ faithful action on equal-length messages, an IV-free strengthening of the catalog's `compress_injective_md_injective`.
- `mdHom_injOn_length` — the homomorphism is injective on fixed-length words.
- `md_collision_closed_under_suffix` — every collision survives a common suffix.
- `mdEnd_injective_of_padding` — Merkle–Damgård strengthening yields total faithfulness (action-language form of `md_strengthen_injective`).
- `converse_faithful_not_imply_injective` — an explicit **counterexample** showing faithfulness is strictly weaker than injectivity of the compression function.
- `treeHash`, `BTree`, `BTree.shape`, and `treeHash_injOn_shape` — a free-magma generalization to binary Merkle *tree* hashing, with collision resistance proved for same-shape trees.

**Remaining `sorry`:** exactly one, in `treeHash_injective_with_domain_separation_conjecture`, which is an intentional open conjecture (domain-separation tree collision resistance) seeding the next cycle, as called for by the protocol's generalization step. No main result uses `sorry`.

The whole module compiles (`Algebra.MerkleDamgardAction`), with the only build warning being the single intended conjecture `sorry`.

**Notes/deliverables:** Each theorem carries a Lab Notebook block (`-- !-- ... -- !--`) recording Hypothesis / Result / Insight / Failure analysis, plus docstring proof sketches. A `FUTURE_DIRECTIONS.md` (at the project root) contains the required Synthesis and Results Summary sections plus five falsifiable research directions (domain separation, reachable-orbit faithfulness characterization, permutation/group action for invertible compression, collision-suffix submonoid invariant, and truncated/wide-pipe MD).