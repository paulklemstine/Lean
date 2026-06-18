# Future Directions: Quantum Error Correction Bounds

## 1. Quantum Gilbert-Varshamov Bound (Existence Bound)

The quantum Hamming bound gives an upper limit on code parameters, but the **quantum Gilbert-Varshamov (GV) bound** provides a complementary *existence* result: for any n and d with 2d ≤ n + 2, there exists an [[n, k, d]] stabilizer code with k ≥ n - 2⌈log₂ V_q(n, d-1)⌉. The key insight is that this can be proved via a probabilistic argument over random self-orthogonal subspaces of F₂^{2n} under the symplectic form, connecting our `symplecticInnerProduct` to a counting argument. Why now? We already have the symplectic infrastructure and the Hamming volume function; the GV bound would close the gap between achievability and converse, completing the fundamental coding-theoretic picture.

## 2. Algebraic Structure of the Pauli Group and Weight Enumerator Polynomials

The Shor-Laflamme quantum weight enumerators A(z) and B(z) of a quantum code satisfy a MacWilliams-type identity relating the code and its dual. The key insight is that this identity follows from the character theory of the Pauli group (which is the extraspecial 2-group), connecting representation theory to coding theory in a way that has not been formalized. The quantum MacWilliams identity A'(z) = 2^{-k} · A(z) (under Krawtchouk transform) would yield the linear programming bound as a corollary. Why now? The Pauli group can be constructed as a central extension of (ZMod 2)^{2n} by (ZMod 2), building directly on our F₂ symplectic geometry.

## 3. Topological Quantum Codes and Homological Dimension

Surface codes (toric codes) on a genus-g surface encode k = 2g logical qubits with distance d = O(√n). The key insight is that k = dim H₁(Σ; F₂) = 2g, and the distance equals the systole (shortest non-contractible cycle) of the cellulation — this makes the quantum Singleton bound geometrically transparent as a constraint on the systole vs. total area. Why now? The existing `CechStabilizerCode.lean` already connects chain complexes to CSS codes; extending it with an explicit genus computation and a formal systole bound would give the first formalized proof that surface codes achieve k = 2g.

## 4. Fault-Tolerant Threshold Theorem (Combinatorial Core)

The threshold theorem states that if physical error rate p < p_th (a constant threshold), then logical error rate decreases exponentially with code distance: p_L ≤ (p/p_th)^{⌊d/2⌋}. The key insight is that the combinatorial core of this theorem reduces to a counting argument: the number of malignant fault paths of weight t in a concatenated code is bounded by A^t for a circuit-dependent constant A, and our quantum Hamming volume provides the first factor. Why now? With `quantumHammingVolume_upper_bound` and `no_full_correction` established, the exponential suppression argument becomes a clean induction on concatenation level.

## 5. Quantum Singleton Bound Tightness via MDS Codes

A quantum MDS (maximum distance separable) code is one achieving equality k + 2d = n + 2 in the Singleton bound. The key insight is that quantum MDS codes over F_q exist when q ≥ n + 1 (via classical Reed-Solomon codes lifted through the Hermitian construction), but the existence question over F₂ (the most physical case) is highly constrained — the only known binary quantum MDS codes have d ≤ 3. Formalizing the non-existence of binary quantum MDS codes with d ≥ 4 would be a novel result connecting our parameter framework to deep algebraic geometry. Why now? Our `perfectCode_singleton_tight` already verifies tightness for [[5,1,3]]; extending to a proof that no binary [[n, n-2d+2, d]] code exists for d ≥ 4 would resolve a concrete open question.
