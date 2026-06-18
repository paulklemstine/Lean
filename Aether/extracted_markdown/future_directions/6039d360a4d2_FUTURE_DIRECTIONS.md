# Future Directions: Certified Novelty Detection for Mathematical Theorems

## Direction 1: Semantic Theorem Embeddings via Dependency Graphs

**Hypothesis:** Embedding theorems based on their logical dependency DAGs (which axioms, lemmas, and definitions they transitively depend on) produces a more semantically meaningful metric than syntactic features, and yields tighter equivalence radii.

**Approach:**
- Extract dependency graphs from formal proof libraries (Mathlib, AFP).
- Define graph distance metrics (e.g., graph edit distance, spectral distance on Laplacians).
- Prove that logically equivalent theorems (modulo definitional unfolding) have dependency graphs within bounded edit distance.
- Formalize a new `novelty_of_far_from_catalog` theorem parameterized by graph embeddings.

**Cross-domain connections:** Graph neural networks for representation learning; persistent homology for topological signatures of dependency DAGs.

**Concrete first step:** Implement dependency extraction for 100 Mathlib theorems and compute pairwise graph distances. Verify that known equivalences cluster tightly.

## Direction 2: Novelty Certificates Modulo Definitional Equality and α-Renaming

**Hypothesis:** The equivalence radius δ can be made very small (even zero for certain features) if we quotient by definitional equality and variable renaming before embedding, yielding sharper novelty certificates.

**Approach:**
- Define a normal form for theorem statements (e.g., de Bruijn indices for variable binding, β-normal η-long form for terms).
- Prove that normalization preserves logical equivalence.
- Show that the normalized embedding has δ = 0 for syntactic features, reducing novelty certification to exact non-matching.
- Formalize the relationship between normalization quality and achievable δ.

**Cross-domain connections:** Lambda calculus normalization; canonical forms in type theory; hashing for equality testing.

**Concrete first step:** Formalize de Bruijn index normalization for a fragment of dependent type theory and prove that it strictly reduces the equivalence radius for the arity feature.

## Direction 3: Coding-Theoretic Bounds for Theorem Catalog Capacity

**Hypothesis:** The maximum number of certifiably distinct theorems at complexity level ≤ B grows as Θ(exp(c·B)) for some constant c depending on the equivalence radius and feature dimension, analogous to sphere-packing bounds in coding theory.

**Approach:**
- Define "complexity budget" as a bound on descriptor coordinates (e.g., symbolCount ≤ B).
- Prove upper bounds on the number of non-overlapping δ-balls in the feasible region of feature space.
- Prove lower bounds by constructing explicit packings (catalog families achieving the bound).
- Connect to Shannon capacity and Gilbert-Varshamov bounds.

**Cross-domain connections:** Information theory (channel capacity); combinatorial geometry (sphere packing); computational complexity (counting distinct objects).

**Concrete first step:** Prove that in d-dimensional Euclidean space with integer coordinates in [0, B]^d and equivalence radius δ, the number of certifiable novelty regions is at most ((B + 2δ) / (2δ))^d. Formalize this in Lean.

## Direction 4: Cryptographic Commitments to Theorem Identity

**Hypothesis:** The embedding framework can be extended to support *commitment schemes*: a researcher can commit to a theorem's descriptor hash before publication, providing a machine-verifiable priority claim that does not reveal the theorem itself.

**Approach:**
- Define a collision-resistant hash on theorem descriptors.
- Prove that commitment (publishing the hash) does not reveal the theorem but binds the committer.
- Show that novelty certification of the revealed theorem, combined with the commitment, constitutes a verifiable priority proof.
- Formalize the binding and hiding properties.

**Cross-domain connections:** Cryptographic commitment schemes; zero-knowledge proofs; blockchain timestamping for intellectual priority.

**Concrete first step:** Define a Merkle-tree commitment over the six TheoremDescriptor fields and prove binding (changing any field changes the root hash).

## Direction 5: Learned Embeddings with Formal Soundness Wrappers

**Hypothesis:** Neural network embeddings (e.g., from transformer models trained on theorem statements) can be wrapped with formal soundness guarantees by empirically estimating δ on a validation set of known equivalences, then proving that the certified novelty theorem holds for that δ.

**Approach:**
- Train a sentence embedding model on pairs of equivalent/non-equivalent theorem statements.
- Estimate δ as the maximum embedding distance among known equivalent pairs (with statistical confidence bounds).
- Prove that the `novelty_of_nearestDist_gt` theorem applies to the learned embedding with the estimated δ.
- Formalize the interface between the learned embedding (trusted but unverified) and the formal certificate (verified).

**Cross-domain connections:** Representation learning; conformal prediction for uncertainty quantification; PAC-Bayes bounds.

**Concrete first step:** Train a small embedding model on 1000 Mathlib theorem pairs, estimate δ, and run the novelty certification pipeline on held-out theorems. Measure the rate of correct novelty/non-novelty predictions.

---

## Team Directive

Each direction should be pursued by a sub-team that:

1. **States precise hypotheses** as formal conjectures (Lean theorem statements with `sorry`).
2. **Runs computational experiments** to validate or refute conjectures before attempting formal proof.
3. **Decomposes proofs** into independently provable lemmas of ≤ 50 lines each.
4. **Cross-pollinates** with other directions: e.g., Direction 3's packing bounds inform Direction 5's choice of embedding dimension; Direction 2's normalization reduces Direction 1's graph distances.
5. **Iterates weekly** with updated knowledge base: which lemmas are proved, which conjectures are refuted, which new conjectures emerge.

The overarching goal is to build a complete, formally verified pipeline from theorem statement to novelty certificate, combining the rigor of the metric-geometric framework with the power of learned representations and the scalability of algorithmic implementations.
