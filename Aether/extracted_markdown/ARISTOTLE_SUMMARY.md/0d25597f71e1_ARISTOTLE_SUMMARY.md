# Summary of changes for run f3c102b6-b0ea-4425-b629-772956d15ec3
## Completed: Cryptographic Hash Functions — Collision Resistance via Merkle-Damgård

### Deliverables

**`Cryptography/MerkleDamgard.lean`** — A self-contained formalization of the Merkle-Damgård construction and its collision resistance properties. All theorems compile with zero `sorry` and only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

**`FUTURE_DIRECTIONS.md`** — Five research directions with falsifiable hypotheses.

### Theorems Proved (7 total, 5 substantive)

1. **`foldl_joint_injective`** — If the compression function `f : α × β → α` is injective, then `List.foldl f` is jointly injective in both the initial accumulator and the list (for same-length lists). This is the core algebraic fact underlying Merkle-Damgård security. *Proof: induction on the first list, generalizing the second list and both accumulators.*

2. **`compress_injective_md_injective`** — Injective compression implies the Merkle-Damgård hash is injective on same-length messages. *Proof: direct corollary of `foldl_joint_injective`.*

3. **`md_collision_implies_compress_collision`** *(Main theorem)* — If two distinct equal-length messages produce the same Merkle-Damgård hash, then the compression function has a collision (∃ distinct pairs with the same output). This is THE fundamental security reduction for hash functions like SHA-256. *Proof: contrapositive of `compress_injective_md_injective`.*

4. **`foldl_convergence`** — If two different initial states produce the same output under `foldl` with the same list, there exists a step where different states (same block) yield the same output. This is a constructive collision extraction. *Proof: induction with decidable equality case split.*

5. **`md_strengthen_injective`** — With injective, length-preserving padding, the strengthened Merkle-Damgård construction is injective on all messages (not just same-length). *Proof: reduces to `compress_injective_md_injective` via padding injectivity.*

Plus structural lemmas: `merkleDamgard_append` (domain extension) and `length_extension_property` (documenting the length extension vulnerability).

### Key Insight

The Merkle-Damgård security reduction is purely combinatorial — no probabilistic reasoning required. The entire argument reduces to a clean property of `List.foldl`: joint injectivity in (accumulator, list) propagates from the step function to the iteration.