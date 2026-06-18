# Future Directions: Code-Based Cryptography from Goppa Codes

## 1. Goppa Code Minimum Distance Bound: deg(g) + 1

The classical result states that a binary Goppa code with Goppa polynomial g(x) of degree t has minimum distance at least 2t + 1. More generally, over F_q, the minimum distance is at least deg(g) + 1. This is provable from the syndrome formulation: if a codeword c has weight ≤ deg(g), then the error locator polynomial has degree < deg(g), and the key equation σ(x) · S(x) ≡ ω(x) mod g(x) forces σ to be zero, contradicting c ≠ 0.

The key insight is that the syndrome-based argument reduces to a degree comparison in F_q[x]/g(x), which is already formalized via Mathlib's polynomial algebra. Why now? Our `GoppaCode` definition and `isGoppaCodeword` predicate give us the syndrome condition directly; what remains is connecting the polynomial degree argument to the Hamming weight bound.

## 2. Indistinguishability of Goppa Code Generator Matrices

A central security assumption of the McEliece cryptosystem is that the public key (a scrambled generator matrix of a Goppa code) is computationally indistinguishable from a random matrix. Formalizing this requires defining a notion of computational indistinguishability for matrix distributions and showing that any efficient distinguisher has negligible advantage.

The key insight is that this can be modeled as a game-based security definition: the adversary receives either a scrambled Goppa matrix or a uniformly random matrix and must guess which. The reduction to NP-hardness of random linear code decoding (Berlekamp-McEliece-Tilborg) provides the theoretical foundation. Why now? Our linear code infrastructure (submodules, projections, dimension bounds) gives us the algebraic side; what's needed is the complexity-theoretic framing, which can be axiomatized as an oracle assumption.

## 3. Patterson's Decoding Algorithm Correctness

Patterson's algorithm efficiently decodes binary Goppa codes by computing the error locator polynomial from the syndrome. Formalizing its correctness would complete the McEliece decryption pipeline: given a received word y = c + e with wt(e) ≤ t, Patterson's algorithm recovers e (and hence c) in polynomial time.

The key insight is that the algorithm reduces to finding square roots in F_{2^m}[x]/(g(x)) and then factoring the resulting polynomial, both of which are constructive operations in finite fields. Why now? Our `unique_nearest_codeword` theorem guarantees uniqueness of the decoded codeword; formalizing Patterson's algorithm would give us constructive decoding to match the existential uniqueness result.

## 4. MacWilliams Identity for Weight Enumerators

The MacWilliams identity relates the weight enumerator of a linear code to that of its dual code: W_{C⊥}(x,y) = |C|^{-1} · W_C(y-x, y+x) (for binary codes). This is a deep structural result connecting a code to its dual.

The key insight is that the proof uses character sums over finite fields, specifically the fact that ∑_{c ∈ C} χ(c · v) = |C| if v ∈ C⊥ and 0 otherwise. This character-sum machinery connects to Mathlib's existing Fourier analysis on finite abelian groups. Why now? Our weight enumerator definition and the `weightEnumerator_zero_eq_one` result provide the starting point; the dual code C⊥ is naturally defined as the orthogonal complement submodule, which Mathlib already supports.

## 5. Singleton Bound Tightness: MDS Codes

A code meeting the Singleton bound d = n - k + 1 with equality is called Maximum Distance Separable (MDS). Reed-Solomon codes are the canonical examples. Formalizing MDS codes and proving that Reed-Solomon codes are MDS would connect our Singleton bound to the most important family of optimal codes.

The key insight is that a code is MDS if and only if every k columns of any parity-check matrix are linearly independent, which can be shown via the Vandermonde determinant for Reed-Solomon codes. Why now? Our `singleton_bound` and `coordProj_injOn_code` already formalize the projection-based argument; proving tightness requires constructing explicit codes (Reed-Solomon) and showing their evaluation matrices have full rank, which reduces to the nonvanishing of Vandermonde determinants — a result close to what Mathlib already has for polynomial interpolation.
