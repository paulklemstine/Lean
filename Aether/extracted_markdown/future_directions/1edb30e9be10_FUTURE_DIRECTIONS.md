# Future Research Directions

## Synthesis

This research cycle established a rigorous combinatorial framework for k-mer avoidance in sequences over finite alphabets. The central achievement is a complete formalization of the Ramsey threshold theorem (α^k + k) via the pigeonhole principle, together with subword complexity bounds, composition bias detection, and structural properties of the k-mer extraction map. These results are formalized in Lean 4 with all proofs verified, zero remaining sorries, and standard axioms only.

The most promising cross-domain connection from this cycle is the **bias-complexity bridge**: the theorem that composition bias (using fewer symbols) causes exponential reduction in subword complexity. This connects cryptographic randomness testing to combinatorial sequence analysis, suggesting that k-mer methods could serve as a unified framework for both bioinformatic pattern discovery and cryptographic bias detection. The bridge to the existing Catalog is through the Cryptography domain (particularly `Cryptography/Commitments.lean` and its `entropy_lower_bound_from_fiber` theorem, which bounds entropy from fiber cardinality — the same pigeonhole structure underlying our k-mer threshold).

The highest breakthrough potential lies in Direction 1 (Subsequence Ramsey Numbers), which would extend the framework from contiguous to non-contiguous patterns, opening connections to Ramsey theory proper. Direction 3 (Entropy-Complexity Bridge) has the most immediate practical impact, as it would provide quantitative security guarantees for bias detection systems.

---

### Direction 1: Subsequence Ramsey Numbers for Non-Contiguous Patterns

**Conjecture**: Define the *subsequence k-mer* of a sequence s at positions i₁ < i₂ < ... < iₖ as the tuple (s(i₁), s(i₂), ..., s(iₖ)). Define SR(n, k, α) as the minimum number of distinct subsequence k-mers in any sequence of length n over alphabet α. Then for n ≥ α^k + k, every sequence contains a repeated contiguous k-mer (our Ramsey threshold), but the subsequence version satisfies SR(n, k, α) = min(C(n, k), α^k) where C(n, k) is the binomial coefficient.

**Test**: Compute SR(n, k, 2) for small values (n ≤ 10, k ≤ 4) by exhaustive enumeration. Verify that the conjectured formula holds. Check edge cases: does SR(n, 1, α) = min(n, α)? Does SR(n, n, α) = 1?

**Impact**: If true, this would extend the pigeonhole framework to non-contiguous patterns, connecting k-mer analysis to classical Ramsey theory and providing new bounds for subsequence pattern detection in cryptographic and biological contexts.

**Catalog References**: `Cryptography/KMerAvoidance.lean` (kmer_repeat_threshold), `Cryptography/Commitments.lean` (entropy_lower_bound_from_fiber)

**Proof Strategy**: The upper bound SR ≤ α^k follows from the pigeonhole principle on k-symbol tuples. The lower bound requires constructing sequences that achieve many distinct subsequence k-mers. For the lower bound, consider sequences that cycle through all α symbols repeatedly — these should generate diverse subsequence patterns. The key lemma needed is a counting argument for the number of distinct subsequences of a given sequence.

**Domain Bridges**: Combinatorics (Ramsey theory) <-> Cryptography (subsequence pattern detection) <-> Bioinformatics (gapped k-mer analysis)

**Lineage**: Builds on kmer_repeat_threshold from this cycle. Extends the contiguous k-mer framework to non-contiguous patterns.

**Ambition**: grand_challenge

---

### Direction 2: De Bruijn Sequence Formalization via Euler Paths

**Conjecture**: For every finite alphabet α with |α| ≥ 1 and every k ≥ 1, there exists a sequence of length |α|^k + k - 1 over α that is k-mer repeat-free (i.e., all k-mers are distinct). Equivalently, the de Bruijn graph of order k over α has an Euler path.

The de Bruijn graph B(k, α) has:
- Vertices: all (k-1)-mers (functions Fin(k-1) → α), totaling |α|^(k-1) vertices
- Edges: all k-mers (functions Fin(k) → α), where the k-mer (a₁, ..., aₖ) is an edge from (a₁, ..., aₖ₋₁) to (a₂, ..., aₖ)
- Each vertex has in-degree |α| and out-degree |α|

Since B(k, α) is connected (for |α| ≥ 1) and balanced (in-degree = out-degree at every vertex), it has an Euler circuit by the BEST theorem. Linearizing this circuit gives the desired sequence.

**Test**: Construct de Bruijn sequences computationally for (α=2, k=1,...,5) and verify they have the correct length and all k-mers distinct.

**Impact**: This would establish the sharpness of our Ramsey threshold α^k + k, proving it is tight. The formalization would also provide the first Lean 4 proof of the Euler path theorem for directed graphs.

**Catalog References**: `Cryptography/KMerAvoidance.lean` (subthreshold_no_pigeonhole_obstruction, kmer_repeat_threshold)

**Proof Strategy**:
1. Define directed graphs and Euler paths in Lean 4
2. Prove the Euler path existence theorem for connected balanced digraphs
3. Define the de Bruijn graph B(k, α) and verify it is connected and balanced
4. Apply the Euler path theorem to obtain the desired sequence
5. Verify that the Euler path linearization produces a k-mer repeat-free sequence

Key lemma: the de Bruijn graph is connected. This can be proved by showing that any vertex (k-1)-mer can be reached from any other by a sequence of edge traversals, corresponding to a sequence of symbol appends and drops.

**Domain Bridges**: Graph theory (Euler paths) <-> Combinatorics (de Bruijn sequences) <-> Cryptography (optimal k-mer coverage)

**Lineage**: Builds on the subthreshold non-obstruction result from this cycle, which shows the pigeonhole argument alone cannot force collisions below the threshold.

**Ambition**: grand_challenge

---

### Direction 3: Entropy-Complexity Bridge for Finite Sequences

**Conjecture**: For a sequence s : Fin(n) → Fin(α) with empirical frequency distribution p = (p₁, ..., pα), the subword complexity satisfies:

    SC(s, k) ≤ min(n - k + 1, ⌈2^(k · H(p))⌉)

where H(p) = -Σ pᵢ log₂ pᵢ is the empirical Shannon entropy of the symbol frequencies. This would establish that low-entropy sequences (those with biased symbol frequencies) have bounded subword complexity, providing a quantitative strengthening of the bias detection theorem.

**Test**: Generate 1000 random sequences of length 100 over Fin(4) with various bias levels (uniform, 70/10/10/10, 90/4/3/3). Compute SC(s, k) for k = 3, 5, 7 and compare against the conjectured bound 2^(k · H(p)). Plot the relationship.

**Impact**: If true, this would provide tight quantitative bounds for cryptographic bias detection. The entropy H(p) is directly computable from the sequence, so the bound would give a practical formula for the expected subword complexity of biased key material.

**Catalog References**: `Cryptography/KMerAvoidance.lean` (biased_seq_reduced_complexity, distinguisher_catches_bias), `EML/AdvancedTheory.lean` (ensembleComplexity)

**Proof Strategy**: The upper bound SC ≤ n - k + 1 is trivial (at most one k-mer per position). The bound SC ≤ 2^(k · H(p)) can be approached by:
1. Bounding the number of distinct k-mers by the number of "typical sequences" of length k
2. Using the asymptotic equipartition property to count typical sequences as ≈ 2^(k · H)
3. The formal proof would likely require Mathlib's real analysis (logarithms, exponentials)

**Domain Bridges**: Information theory (Shannon entropy) <-> Combinatorics (subword complexity) <-> Cryptography (bias detection bounds)

**Lineage**: Direct extension of biased_seq_reduced_complexity and distinguisher_catches_bias from this cycle.

**Ambition**: extension

---

### Direction 4: K-Mer Lattice Structure and Sperner-Type Bounds

**Conjecture**: The set of k-mer repeat-free sequences of length n over alphabet α forms an antichain in the lexicographic partial order on sequences. Furthermore, the maximum cardinality of this antichain is related to the Sperner number of the k-mer lattice.

More precisely, define a partial order on Fin(n) → α by pointwise comparison (when α is linearly ordered). The set of k-mer repeat-free sequences is not necessarily an antichain in this order, but the set of *maximally* repeat-free sequences (those where inserting any symbol at any position would create a k-mer repeat) forms an interesting combinatorial structure.

**Test**: For α = Fin(2) and k = 2, enumerate all maximally repeat-free sequences of each length n from 1 to 7. Count them and check whether their cardinality follows a pattern related to Sperner numbers or Dilworth decompositions.

**Impact**: This would connect k-mer avoidance to lattice theory and extremal combinatorics, potentially revealing new structural constraints on repeat-free sequences beyond the cardinality bound.

**Catalog References**: `Cryptography/KMerAvoidance.lean`, `EML/LatticeTreeCorrespondence.lean` (if it exists in the Catalog)

**Proof Strategy**:
1. Define the pointwise order on sequences
2. Characterize maximally repeat-free sequences
3. Count them for small cases
4. Look for patterns connecting to Sperner/Dilworth theory
5. If a pattern emerges, prove the relationship

**Domain Bridges**: Order theory (Sperner, Dilworth) <-> Combinatorics (k-mer avoidance) <-> Algebra (lattice theory)

**Lineage**: Builds on the structural results (kmer_overlap, constant_seq_complexity) from this cycle.

**Ambition**: extension

---

### Direction 5: Multi-Scale K-Mer Profiles and Sequence Classification

**Conjecture**: Define the **k-mer profile** of a sequence s as the function P(s) : ℕ → ℕ given by P(s)(k) = SC(s, k). Two sequences s, t over the same alphabet have the same k-mer profile P(s) = P(t) for all k if and only if s and t are related by a symbol permutation (i.e., there exists a bijection σ : α → α such that t = σ ∘ s).

**Test**: Generate pairs of binary sequences of length 20. For each pair, compute P(s) and P(t) for k = 1, ..., 10. Check whether P(s) = P(t) implies the existence of a symbol permutation relating them. Find counterexamples if they exist.

**Impact**: If true, this would show that the k-mer profile is a complete invariant up to symbol relabeling — a powerful classification tool. If false, the counterexamples would reveal exactly what additional information beyond the k-mer profile is needed for classification.

**Catalog References**: `Cryptography/KMerAvoidance.lean` (subwordComplexity), `EML/EMLv17Core.lean` (complexity measures)

**Proof Strategy**: The "if" direction is straightforward: symbol permutations preserve k-mer multiplicities and hence subword complexity. The "only if" direction is the interesting claim. Approach via:
1. Show P(s)(1) determines the multiset of symbol frequencies
2. Show P(s)(2) determines the transition frequencies
3. Argue inductively that P(s)(k) for all k determines s up to symbol permutation

**Domain Bridges**: Combinatorics (sequence invariants) <-> Information theory (sufficient statistics) <-> Machine learning (feature extraction)

**Lineage**: Builds on subwordComplexity and the structural results from this cycle.

**Ambition**: extension
