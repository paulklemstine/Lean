# Future Research Directions

## Synthesis

This research cycle established a rigorous combinatorial framework for k-mer avoidance in sequences over finite alphabets, proving the sharp Ramsey threshold α^k + k for k-mer repeats and formalizing subword complexity bounds. The key insight is that the pigeonhole principle, when applied to the k-mer extraction map, yields a clean Fintype-based proof that transfers seamlessly between arbitrary finite alphabets and specific biological alphabets like DNA.

The most promising cross-domain connection is between **subword complexity** (from symbolic dynamics) and **description complexity** (from the existing EML catalog, particularly `EML/DescriptiveApprox/Theorems.lean`). Both measure the "richness" of a mathematical object: subword complexity counts distinct local patterns in sequences, while description complexity measures the shortest program to generate an object. The conjectured Composition Bias Gap directly bridges these: biased sequences have lower subword complexity *and* lower description complexity, and quantifying this relationship could unify combinatorial and information-theoretic views of sequence structure.

The Ramsey threshold framework also connects to lattice theory (via `EML/LatticeTreeCorrespondence.lean`): the set of k-repeat-free sequences forms an antichain in the subsequence partial order, and its maximum cardinality is constrained by the Ramsey threshold. This structural observation could lead to new results about the Sperner-type properties of sequence lattices.

---

### Direction 1: Subsequence Ramsey Numbers for Non-Contiguous Patterns

**Conjecture**: Define the *subsequence Ramsey number* SR(k, m, α) as the minimum n such that for every sequence s ∈ α^n, every subsequence of s of length k (obtained by choosing k positions i₁ < i₂ < ... < iₖ and reading s(i₁), s(i₂), ..., s(iₖ)) contains a repeated contiguous m-mer. Then SR(k, m, α) = k whenever k ≥ α^m + m, and SR(k, m, α) = ∞ (does not exist) whenever k < α^m + m.

**Test**: For the DNA alphabet (α = 4) and m = 4: verify computationally that when k = 260 (≥ 4⁴ + 4), every subsequence of length 260 from any sequence has a repeated 4-mer (this is immediate from the contiguous result). For k = 259, construct a sequence where some subsequence of length 259 has no repeated 4-mer (this requires exhibiting a 259-length repeat-free sequence and embedding it as a subsequence).

**Impact**: If the conjecture is true, it shows that the subsequence Ramsey problem completely reduces to the contiguous case — a surprisingly clean reduction. If false, it would reveal non-trivial Ramsey-theoretic phenomena in the subsequence setting.

**Catalog References**: `EML/DNARamsey/Theorems.lean` (Ramsey threshold), `Catalog/Combinatorics/ErdosFaberLovasz/Theorems.lean` (hypergraph coloring)

**Proof Strategy**: For k ≥ α^m + m, any subsequence of length k is itself a sequence of length k, and the contiguous Ramsey theorem applies. For k < α^m + m, embed a de Bruijn sequence (which is repeat-free) as a subsequence using an increasing map of indices.

**Domain Bridges**: Combinatorics (Ramsey theory) ↔ Information Theory (subsequence entropy) ↔ Genomics (non-contiguous motif analysis)

**Lineage**: Builds on this cycle's `pigeonhole_kmer_repeat` and `repeat_free_length_bound`.

**Ambition**: extension

---

### Direction 2: Morse-Hedlund Theorem Formalization

**Conjecture**: An infinite sequence s : ℕ → α is eventually periodic if and only if there exists k₀ such that C_s(k₀) ≤ k₀, where C_s(k) is the subword complexity (number of distinct k-mers of length k). Moreover, if s is not eventually periodic, then C_s(k) ≥ k + 1 for all k ≥ 1.

**Test**: Formally prove the Morse-Hedlund theorem in Lean 4. For the "if" direction: if C_s(k₀) ≤ k₀, show there exist positions i < j such that s restricted to [i, ∞) equals s restricted to [j, ∞), implying periodicity with period j - i. For the "only if" direction: show that periodic sequences have bounded complexity.

**Impact**: This would be the first formalization of a fundamental result in symbolic dynamics. It connects local diversity (k-mer counts) to global structure (periodicity), bridging combinatorics and dynamical systems. It would also provide the theoretical foundation for periodicity detection algorithms in bioinformatics.

**Catalog References**: `EML/DNARamsey/Theorems.lean` (subword complexity definitions), `EML/ExtendedTheory.lean` (logarithmic bounds)

**Proof Strategy**: 
1. Define eventually periodic sequences over `ℕ → α`.
2. Prove that C_s(k) ≤ period_length for eventually periodic s.
3. For the converse: use the "extension" argument — if C_s(k) = C_s(k+1) for some k, then every k-mer extends uniquely to a (k+1)-mer, which forces periodicity.
4. Key lemma: if C_s(k+1) = C_s(k) and s is bi-extendable, then s is periodic with period ≤ k.

**Domain Bridges**: Symbolic Dynamics (Morse-Hedlund) ↔ Combinatorics (subword complexity) ↔ EML (description complexity)

**Lineage**: Builds on `subword_complexity_le_pow` and `subword_complexity_of_repeat_free` from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Composition Bias Gap — Quantitative Pigeonhole with Frequency Constraints

**Conjecture**: Let s ∈ α^n where α has c symbols, and suppose some symbol a ∈ α appears in at least ⌈n · p⌉ positions for p > 1/c. Then s is k-repeat-free only if n ≤ ⌈(c - 1 + (1-p)/(p))^k⌉ + k - 1. In particular, for DNA (c = 4) with 40% bias (p = 0.4): the maximum repeat-free length for 4-mers drops from 259 to approximately 150.

**Test**: 
1. Generate 100,000 random DNA sequences with controlled bias levels (p = 0.25, 0.30, 0.35, 0.40, 0.45, 0.50).
2. For each bias level, find the maximum length at which a 4-repeat-free sequence exists.
3. Compare empirical thresholds to the predicted bound ⌈(c - 1 + (1-p)/p)^k⌉ + k - 1.
4. Attempt to prove a simplified version: if one symbol appears in > n/2 positions, the repeat-free bound drops to (c-1)^k + k - 1.

**Impact**: Proves that compositional bias is a quantifiable force reducing sequence diversity. This would explain the observed 5x compression factor between random and real genomes, providing a mathematical foundation for GC-content-based genome classification.

**Catalog References**: `EML/DNARamsey/Theorems.lean` (effective alphabet size), `EML/EMLv18Core.lean` (`neg_log_ge_one_sub`)

**Proof Strategy**: Use a refined pigeonhole argument: if symbol a appears in ≥ pn positions, then among the n - k + 1 k-mers, at least (pn - k + 1) contain a at some fixed position (by averaging). This constrains the number of distinct k-mers to at most c^k · (1 - p + p/c)^k via a product bound.

**Domain Bridges**: Combinatorics (pigeonhole refinements) ↔ Information Theory (entropy bounds) ↔ Genomics (GC content analysis)

**Lineage**: Builds on `compositionBiasGapConjecture` stated in this cycle.

**Ambition**: grand_challenge

---

### Direction 4: K-mer Avoidance in de Bruijn Graphs

**Conjecture**: The de Bruijn graph B(α, k) (where vertices are (k-1)-mers and edges are k-mers) has the property that every Eulerian path corresponds to a maximum-length k-repeat-free sequence. Moreover, the number of such paths equals the number of Eulerian circuits in B(α, k), which is given by the BEST theorem: |α|^(|α|^(k-1) - (k-1)) · ∏_{v} (d(v) - 1)!.

**Test**: Formally define de Bruijn graphs in Lean 4 as `SimpleGraph` over `Fin (α^(k-1))`. Prove that Eulerian paths in B(α, k) biject with maximum-length k-repeat-free sequences. Verify the count formula for small cases (α = 2, k = 2,3).

**Impact**: Connects our sequence-theoretic framework to graph theory, opening the door to using graph-theoretic tools (flow algorithms, spectral methods) for sequence analysis. The BEST theorem count would give an exact formula for the number of optimal repeat-free sequences.

**Catalog References**: `EML/DNARamsey/Theorems.lean` (k-mer definitions), `Geometry/ErdosSzekeres/Defs.lean` (combinatorial structures)

**Proof Strategy**: 
1. Define B(α, k) as a directed multigraph.
2. Show each edge corresponds to a k-mer, and each path of length m corresponds to a sequence of length m + k - 1.
3. Prove Eulerian paths exist (all vertices have equal in-degree and out-degree = α).
4. Show Eulerian paths biject with maximum-length repeat-free sequences.

**Domain Bridges**: Graph Theory (Eulerian paths) ↔ Combinatorics (de Bruijn sequences) ↔ Genomics (assembly graphs)

**Lineage**: Builds on `repeat_free_length_bound` and `ramsey_threshold_forces` from this cycle.

**Ambition**: extension

---

### Direction 5: Subword Complexity and Description Complexity Bridge

**Conjecture**: For any finite sequence s of length n over alphabet α, the description complexity K(s) (shortest program generating s) satisfies: K(s) ≥ Σ_{k=1}^{⌊log_α(n)⌋} log₂(C_s(k)) - O(log n). That is, the subword complexity profile provides a lower bound on Kolmogorov complexity.

**Test**: Compute both subword complexity profiles and approximate description complexity (via compression ratio with standard algorithms like gzip, bzip2) for:
1. Random sequences
2. Periodic sequences  
3. De Bruijn sequences
4. Real genomic sequences (E. coli, human chromosome 1 fragments)

Verify that Σ log₂(C_s(k)) correlates with compression ratio across these sequence classes.

**Impact**: This would establish a formal bridge between the combinatorial theory of k-mers (developed in this cycle) and the information-theoretic framework of EML (Empirical Meta-Learning). The subword complexity profile would become a computable proxy for description complexity, enabling efficient estimation of Kolmogorov complexity from local pattern analysis.

**Catalog References**: `EML/DNARamsey/Theorems.lean` (subword complexity), `EML/DescriptiveApprox/Theorems.lean` (description complexity), `EML/EMLv18Core.lean` (information-theoretic bounds)

**Proof Strategy**: 
1. Show that a sequence with low subword complexity can be described by listing its k-mer set (smaller set = shorter description).
2. Use the chain rule for Kolmogorov complexity: K(s) ≤ K(k-mer set) + K(positions | k-mer set) + O(log n).
3. Bound K(k-mer set) ≈ C_s(k) · log₂(c) and K(positions) ≈ n · H(k-mer distribution).
4. Take the sum over k to get the profile bound.

**Domain Bridges**: Information Theory (Kolmogorov complexity) ↔ Combinatorics (subword complexity) ↔ EML (description complexity) ↔ Genomics (compression)

**Lineage**: Bridges this cycle's results with the EML catalog's `eml_min_depth_le_desc_complexity_over_eps`.

**Ambition**: grand_challenge
