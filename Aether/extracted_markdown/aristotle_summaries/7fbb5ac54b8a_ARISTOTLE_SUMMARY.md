# Summary of changes for run 15c142a0-85f9-40cd-a139-a18ea8403216
## Completed: Cryptographic Hash Functions — Merkle-Damgård Collision Resistance

Created `Cryptography/MerkleDamgard.lean` containing a complete Lean 4 formalization of the Merkle-Damgård construction and its collision resistance properties. All theorems are fully proved (zero sorries) and compile cleanly against Mathlib v4.28.0.

### Core Definitions
- **`CompressFunc S B`** — compression function type `S × B → S`
- **`merkleDamgard f iv`** — the iterated hash via `List.foldl`
- **`HasCollision`** / **`CollisionFree`** — information-theoretic collision notions
- **`mdStates`** — the list of all intermediate states during MD computation

### Main Theorems (all with full PEGB)

1. **`md_collision_implies_compress_collision`** — *The central theorem*: if two equal-length messages collide under Merkle-Damgård, then the compression function has a collision. Proved by reverse induction on message lists (snoc decomposition), walking backward from the final block to extract a compression collision.

2. **`md_injective_of_compress_injective`** — Corollary: injective compression ⟹ injective MD on same-length messages. Proved as the contrapositive of theorem 1.

3. **`md_strengthening_collision_resistance`** — Merkle-Damgård strengthening: with an injective padding scheme producing same-length padded messages, collision resistance lifts from compression to the full padded hash.

4. **`md_different_length_collision_possible`** — Boundary theorem: the equal-length hypothesis is essential — a concrete counterexample with `Fin 2` types shows different-length messages can collide even with well-behaved compression.

### Structural Lemmas
- `md_cons`, `md_append_block`, `md_append` — decomposition/composition laws
- `mdStates_length`, `mdStates_getLast` — properties of intermediate state traces
- `md_length_extension`, `md_length_extension_general` — the length extension property (basis of length-extension attacks on MD-based hashes)
- `constant_compress_all_collide` — boundary: constant compression trivially collides

### Examples
- XOR compression as a concrete non-injective compression function with explicit collision witnesses
- MD with XOR producing hash collisions across different-length messages

### Future Directions (5 conjectures listed in file)
Sponge construction, HMAC security, indifferentiability from random oracles, Joux multicollision bounds, and birthday bound lower bounds.