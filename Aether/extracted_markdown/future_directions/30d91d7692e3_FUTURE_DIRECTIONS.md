# FUTURE_DIRECTIONS.md — Cryptographic Hash Functions: Collision Resistance

## Synthesis

This cycle established the foundational formalization of Merkle-Damgård collision resistance in Lean 4. We proved five theorems capturing the core security reduction: that collisions in the iterated hash imply collisions in the compression function. The key structural insight is that the Merkle-Damgård construction's security reduces to a pure algebraic property — joint injectivity of `List.foldl` — which admits a clean inductive proof without any probabilistic reasoning.

Two independent proof techniques emerged. The contrapositive approach (via `foldl_joint_injective`) handles the general case but uses classical logic. The constructive convergence lemma (`foldl_convergence`) extracts explicit collision witnesses but only handles the "same message, different IV" case. The gap between these — constructive collision extraction for the full "different message, same IV" case — is a natural next target.

We also identified the boundary of our results: they apply only to equal-length messages. The `md_strengthen_injective` theorem shows how injective padding extends the result to variable-length messages, but real-world padding schemes (like SHA-256's) require formalizing bitwise operations and length encoding, which is infrastructure work for a future cycle.

## Results Summary

- `foldl_joint_injective`: proved — If compression is injective as α × β → α, then foldl is jointly injective in (accumulator, list) for same-length lists
- `compress_injective_md_injective`: proved — Injective compression implies Merkle-Damgård is injective on same-length messages
- `md_collision_implies_compress_collision`: proved — Any collision in MD on same-length messages implies a collision in the compression function (the main security reduction)
- `foldl_convergence`: proved — Different initial states converging under the same message sequence yield a constructive compression collision
- `md_strengthen_injective`: proved — With injective, length-preserving padding, MD is injective on all messages
- `length_extension_property`: proved (trivial) — Documents the length extension vulnerability as a structural property
- `merkleDamgard_append`: proved — Domain extension / structural decomposition of MD

## Research Directions

### Direction 1: Constructive Full Collision Extraction
**Hypothesis**: For any two distinct same-length messages with the same MD hash, one can constructively (without classical choice) extract the specific index and inputs where the compression function collides.
**Test**: Prove a version of `md_collision_implies_compress_collision` that returns a `Fin n` index and explicit collision witnesses, using only constructive logic (no `Classical.choice`).
**Why now**: The `foldl_convergence` lemma already gives constructive extraction for the convergence sub-case. The missing piece is handling the "different blocks at the same position" case constructively, which should be doable by combining `foldl_convergence` with decidable equality on β.
**If true**: Opens the door to verified collision-finding algorithms and computational security reductions.
**If false**: Reveals that the collision location genuinely requires classical reasoning, which would be an interesting metamathematical fact about cryptographic reductions. The key insight is that the constructive content of the convergence lemma may not extend to the full case analysis needed when both blocks and states differ simultaneously.

### Direction 2: Probabilistic Collision Resistance and the Birthday Bound
**Hypothesis**: For a random compression function f : Fin N × Fin M → Fin N, the probability that k random messages yield a collision in the Merkle-Damgård hash is at most k²/(2N), matching the birthday bound.
**Test**: Formalize a probability space over compression functions (using `MeasureTheory.MeasureSpace` on `Fin N × Fin M → Fin N`) and prove the birthday bound for the iterated construction.
**Why now**: Our deterministic collision reduction is complete; the natural next step is quantitative security. Mathlib's measure theory should provide the infrastructure, though finite probability spaces over function types may need custom development. The key insight is that the deterministic reduction theorem converts the birthday bound on compression functions directly to a birthday bound on the full hash.
**If true**: Gives the first formalized quantitative security bound for iterated hash constructions.
**If false**: Indicates that the birthday bound requires tighter coupling between the compression function distribution and the iteration structure.

### Direction 3: Sponge Construction and Beyond Merkle-Damgård
**Hypothesis**: The sponge construction (used in SHA-3/Keccak) satisfies a collision resistance reduction analogous to our Merkle-Damgård theorem, where collision resistance of the sponge reduces to properties of the underlying permutation.
**Test**: Define the sponge construction as `sponge (π : Fin n → Fin n) (r c : ℕ) (msg : List (Fin (2^r)))` and prove that collisions in the sponge output imply either (a) a collision in π or (b) a capacity collision (two states agreeing on the capacity bits).
**Why now**: Our `foldl_joint_injective` technique generalizes — the sponge is also an iterated construction, but with a twist: the permutation is bijective, so collisions arise from information loss in the rate/capacity split rather than from compression. The key insight is that the sponge security argument is structurally dual to Merkle-Damgård: instead of proving compression injectivity implies hash injectivity, we prove permutation bijectivity plus capacity separation implies hash collision resistance.
**If true**: Unifies the security foundations of both major hash construction paradigms in a single formal framework.
**If false**: The capacity-based argument may require fundamentally different proof techniques that our foldl framework cannot capture.

### Direction 4: HMAC Security from Merkle-Damgård Properties
**Hypothesis**: HMAC (keyed-hash message authentication) constructed from a Merkle-Damgård hash is a secure PRF if the compression function is a PRF, and this reduction can be formalized building on our collision resistance framework.
**Test**: Define HMAC as `hmac f k msg = merkleDamgard f (f iv (k ⊕ opad)) [merkleDamgard f (f iv (k ⊕ ipad)) msg]` and prove that any distinguisher for HMAC yields either a compression-function distinguisher or a collision.
**Why now**: Our `merkleDamgard_append` decomposition theorem is exactly the structural property needed to decompose HMAC into its inner and outer hash applications. The key insight is that HMAC security decomposes into two applications of our collision resistance theorem (for the inner and outer hashes) plus a PRF assumption on the compression function.
**If true**: Provides the first end-to-end formal security proof for the most widely deployed MAC construction.
**If false**: The PRF-to-collision-resistance gap may require formalizing computational indistinguishability, which is a major infrastructure investment.

### Direction 5: Tree Hashing and Parallelizable Collision Resistance
**Hypothesis**: A binary tree hash (where leaves are message blocks and internal nodes apply the compression function) preserves collision resistance with a tighter reduction than Merkle-Damgård: a collision in the tree hash of depth d implies a collision in the compression function with no loss (vs. the sequential chain where the reduction quality depends on message length).
**Test**: Define `treeHash f : BinaryTree β → α` recursively and prove `treeHash_collision_implies_compress_collision` with a reduction that does not depend on tree depth.
**Why now**: Our proof technique for `foldl_joint_injective` — peeling off one layer at a time — adapts directly to tree structures via structural induction on `BinaryTree`. The key insight is that tree hashing's collision resistance reduction is actually simpler than Merkle-Damgård's because each path from root to leaf is independent, eliminating the need for the convergence argument.
**If true**: Establishes tree hashing as formally superior to sequential hashing for collision resistance, with implications for parallel hash function design.
**If false**: The independence assumption between paths may break down, revealing subtle dependencies in tree-structured compression.
