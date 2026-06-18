# Future Directions: Code-Based Cryptography Formalization

## 1. Goppa Code Construction from Algebraic Geometry

The current formalization treats linear codes abstractly as submodules of F^n. A natural next step is to construct binary Goppa codes explicitly from a Goppa polynomial g(x) ∈ GF(2^m)[x] and a support set L ⊆ GF(2^m), then prove that the resulting code has minimum distance ≥ 2·deg(g) + 1 (the "square root" improvement over general alternant codes).

The key insight is that the parity check matrix of a Goppa code has a Vandermonde-like structure that forces every codeword to satisfy syndrome equations modulo g(x), and the binary case doubles the designed distance because the square root of the syndrome polynomial exists over GF(2^m).

Why now? Mathlib's finite field infrastructure (GaloisField, polynomial rings over finite fields, Frobenius endomorphism) is now mature enough to formalize the algebraic construction. The Hamming weight/distance framework established here provides the metric foundation.

## 2. Patterson's Decoding Algorithm Correctness

The McEliece cryptosystem's private key operation depends on efficient decoding of Goppa codes. Patterson's algorithm (1975) decodes binary Goppa codes up to t errors in O(n²) operations by computing the error locator polynomial via a square root and extended GCD computation in GF(2^m)[x]/g(x).

The key insight is that Patterson reduces decoding to finding a polynomial σ(x) of degree ≤ t such that σ²(x) ≡ x (mod g(x)) and σ(x) divides the syndrome, which can be solved by the extended Euclidean algorithm with early termination.

Why now? The unique decoding guarantee (Theorem 3) ensures that Patterson's algorithm, if it terminates successfully, produces the unique closest codeword. Formalizing the algorithm would close the loop on McEliece correctness from abstract specification to concrete implementation.

## 3. ISD Complexity Lower Bounds and Security Reduction

Information-Set Decoding (ISD) is the best known generic attack against code-based cryptosystems. Formalizing the combinatorial lower bound — that any algorithm solving the syndrome decoding problem must examine at least C(n,t)/C(k,0) ≈ C(n,t) information sets in expectation — would provide the first machine-verified security argument for McEliece parameters.

The key insight is that the number of information sets (k-subsets of [n] that form a basis for the code) is approximately C(n,k), and only a C(n-t, k)/C(n,k) fraction of them avoid all t error positions, giving a birthday-type lower bound.

Why now? The parameter verification theorems (mceliece6960119_params, mceliece8192128_params) establish the arithmetic foundation. Connecting these to a formal complexity argument would produce the first end-to-end verified post-quantum security claim.

## 4. Distinguisher Reduction: Goppa vs. Random

A central open problem in code-based cryptography is whether Goppa code generator matrices are computationally indistinguishable from random matrices. Formalizing even partial results — such as the Faugère–Otmani–Perret–Tillich distinguisher for high-rate Goppa codes, or the proof that square-free Goppa codes resist algebraic distinguishers up to certain parameters — would advance both the formalization and the cryptographic understanding.

The key insight is that the distinguishing advantage is bounded by the number of low-weight codewords in the dual code, which for properly chosen Goppa codes is exponentially small.

Why now? The permutation invariance theorem (Theorem 4) shows that code equivalence under permutation preserves all metric properties, which is a prerequisite for any distinguisher reduction. The linear code framework supports defining the dual code as the orthogonal complement.

## 5. Quantum Security of McEliece via Grover Bounds

While McEliece is considered post-quantum secure, the formal argument requires showing that Grover's algorithm provides at most a quadratic speedup over classical ISD. This means a [n, k, d] binary Goppa code with classical work factor W has quantum work factor ≥ W^{1/2}, so 256-bit quantum security requires parameters achieving classical work factor ≥ 2^{512}.

The key insight is that Grover's algorithm applies to the ISD search as an unstructured search over information sets, and the lack of exploitable algebraic structure in the search space prevents better-than-quadratic quantum speedups (assuming no quantum algebraic attacks exist).

Why now? The parameter verification infrastructure can be extended to verify that the mceliece8192128 parameter set achieves ≥ 2^{512} classical work factor (and thus ≥ 2^{256} quantum). This would produce the first formally verified post-quantum security parameter claim.
