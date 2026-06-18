# Future Directions

## Synthesis

The formal verification of unramified Hecke eigenpacket structure — coprime multiplicativity, prime-power recursion, the Euler factor identity, and verified coefficient propagation — establishes a certified algebraic foundation at the interface of automorphic forms, harmonic analysis on restricted products, and computational number theory. The five directions below extend this foundation along two axes: (1) deepening the adelic-to-classical bridge by connecting our algebraic packets to analytic objects built on the restricted-product Haar measure infrastructure, and (2) broadening the theory to weighted, ramified, and higher-rank settings that open the door to L-function formalization and eventually the Langlands correspondence.

All directions build directly on the catalog's restricted product infrastructure (`Pythagorean/HaarRestrictedProduct/Defs.lean`, `Pythagorean/HaarRestrictedProduct/Theorems.lean`) and the Hecke packet theorems (`Pythagorean/HeckePacket/`).

---

## Direction 1: Weighted Hecke Packets and the General Divisor Convolution

**Conjecture.** For a weight-k Hecke packet with recursion a(p^{r+2}) = a(p)·a(p^{r+1}) - p^{k-1}·a(p^r), the general Hecke relation takes the form:
$$a(m) \cdot a(n) = \sum_{d \mid \gcd(m,n)} d^{k-1} \cdot a\left(\frac{mn}{d^2}\right)$$
for all positive integers m, n.

**Test.** Implement the weight-k packet in Lean with `(p : R) ^ (k-1)` replacing `(p : R)` in the recursion. Verify the general Hecke relation computationally for the Ramanujan tau function (k=12) for all m, n ≤ 100. Formally prove the prime-power case by adapting the existing induction, then derive the general case via coprime multiplicativity and prime factorization.

**Impact.** Completes the algebraic theory of Hecke eigenforms at all classical weights. The divisor convolution formula is the finite-level shadow of the full Hecke algebra multiplication law, giving the arithmetic API for Euler products and Rankin-Selberg convolutions.

**Catalog References.** `Pythagorean/HeckePacket/PrimePowerHecke.lean` (adapt induction), `Pythagorean/HeckePacket/Defs.lean` (generalize structure).

**Proof Strategy.** Define `WeightedHeckePacket R k` with the modified recursion. Adapt `coeff_hecke_prime_powers_le` by replacing `p^i` with `p^{i(k-1)}` throughout. For the general relation, use `Nat.factorization` to decompose m and n into prime powers, apply the prime-power Hecke relation at each prime, and assemble via `Finsupp.prod`.

**Domain Bridges.** Number theory ↔ representation theory (Satake isomorphism with weight parameter), number theory ↔ signal processing (weighted transfer functions with different pole configurations).

**Lineage.** Direct extension of Theorems 3.2 and 3.3 from the current formalization.

**Ambition.** Solid extension — generalizes existing proofs to a parameterized family.

---

## Direction 2: Adelic Realization via Restricted Product Convolution

**Conjecture.** The spherical double-coset convolution operators on the restricted product GL₂(𝔸_ℚ), defined using cylinder functions and the level-compatible Haar measure from the catalog, yield eigenvalues that satisfy the UnramifiedHeckePacket axioms. Specifically: if f is a bi-K-invariant eigenfunction of the Hecke convolution operators T_p for all primes p, then the eigenvalue sequence a(p) = λ_f(T_p) defines an `UnramifiedHeckePacket`.

**Test.** Formalize the characteristic function of the double coset GL₂(ℤ_p)·diag(p,1)·GL₂(ℤ_p) as a cylinder function in the restricted product framework. Compute the convolution T_p * T_q for coprime p, q and verify it equals T_{pq}. Compute T_p * T_p and verify the quadratic relation T_p² = T_{p²} + p.

**Impact.** This would be the first machine-verified bridge from adelic harmonic analysis to classical Hecke algebra structure — the central theorem connecting the restricted-product measure theory to arithmetic. It transforms the catalog's Haar measure infrastructure from passive definitions to an active engine for automorphic theory.

**Catalog References.** `Pythagorean/HaarRestrictedProduct/Defs.lean` (basicCylinder, IsLevelCompatible), `Pythagorean/HaarRestrictedProduct/Theorems.lean` (Haar positivity, translation invariance).

**Proof Strategy.** Define `SphericalHeckeOperator p` as the indicator function of the double coset viewed as a basic cylinder. Show convolution factors through the cylinder measure via `IsLevelCompatible`. Use the Cartan decomposition GL₂(ℚ_p) = ⊔ GL₂(ℤ_p)·diag(p^a, p^b)·GL₂(ℤ_p) to compute products.

**Domain Bridges.** Harmonic analysis ↔ number theory (convolution algebra ↔ Hecke algebra), measure theory ↔ representation theory (Haar measure ↔ spherical functions).

**Lineage.** Builds on both the restricted product infrastructure and the Hecke packet algebraic theory.

**Ambition.** Grand challenge — requires substantial new measure-theoretic and group-theoretic formalization.

---

## Direction 3: Formal Euler Products and Analytic Continuation

**Conjecture.** The formal Euler product ∏_p E_p(p^{-s})^{-1}, where E_p(T) = 1 - a(p)T + pT², converges absolutely for Re(s) > 3/2 (in the weight-1 normalization) and defines an analytic function. Under the Ramanujan bound |a(p)| ≤ 2√p, the product converges for Re(s) > 1 and has analytic continuation to Re(s) > 1/2.

**Test.** For the Ramanujan tau packet (weight-1 normalization), numerically evaluate the partial Euler product ∏_{p ≤ B} E_p(p^{-s})^{-1} for increasing B and verify convergence at s = 2, 3, 5. Compare with the Dirichlet series ∑_{n ≤ N} a(n)/n^s for increasing N. Any divergence or mismatch falsifies either the convergence claim or the computational implementation.

**Impact.** Establishes the first formal connection between Hecke eigenpackets and L-functions. This opens the door to formalizing functional equations, special values, and eventually the connection to Galois representations.

**Catalog References.** `Pythagorean/HeckePacket/EulerFactor.lean` (local_euler_factor_identity).

**Proof Strategy.** Use the formal power series ring isomorphism to define the infinite Euler product as a limit. Bound the partial products using |a(p)| ≤ 2√p and the comparison test. For absolute convergence, bound |E_p(p^{-s})^{-1} - 1| ≤ C/p^{Re(s)} and sum over primes using the prime number theorem.

**Domain Bridges.** Number theory ↔ complex analysis (analytic continuation), number theory ↔ probability theory (Euler products as independence of prime factors).

**Lineage.** Direct application of the Euler factor identity (Theorem 3.3).

**Ambition.** Solid extension — convergence analysis uses standard techniques.

---

## Direction 4: Strong Multiplicity One for Unramified Packets

**Conjecture.** If two UnramifiedHeckePackets over ℤ agree on a(p) for all primes p, then they agree on a(n) for all n. More strongly: if they agree on a(p) for all primes p ≤ B, they agree on a(n) for all n whose prime factors are all ≤ B.

**Test.** Formalize the statement and attempt a proof using the factorization theorem (coeff_squarefree_prod) and the prime-power computation correctness (computePrimePower_correct). Computationally verify by constructing two packets with the same prime values and checking agreement on all n ≤ 10000.

**Impact.** This is the finite-level analogue of strong multiplicity one for GL₂. A formal proof would establish that Hecke eigenpackets are completely determined by their local data — the arithmetic analogue of the holographic principle.

**Catalog References.** `Pythagorean/HeckePacket/Compute.lean` (computePrimePower_correct, coeff_squarefree_prod).

**Proof Strategy.** Every positive integer n has a unique factorization n = ∏ p_i^{e_i}. By coprime multiplicativity, a(n) = ∏ a(p_i^{e_i}). Each a(p_i^{e_i}) is determined by a(p_i) via computePrimePower_correct. Hence a(n) is determined by the collection {a(p) : p prime dividing n}.

**Domain Bridges.** Number theory ↔ information theory (determination from local data is a coding theorem), algebra ↔ logic (uniqueness is a categoricity result).

**Lineage.** Immediate consequence of existing theorems; the proof is essentially already done.

**Ambition.** Solid extension — should be straightforward to formalize.

---

## Direction 5: Higher-Rank Hecke Algebras and GL_n Satake Isomorphism

**Conjecture.** The Satake isomorphism for GL_n produces an n-parameter family of Hecke eigenpackets satisfying an n-term recursion at each prime, generalizing the two-term recursion for GL₂. The local Euler factor becomes a degree-n polynomial, and the Hecke multiplication law involves sums over partitions rather than simple divisor sums.

**Test.** For GL₃, define a `GL3HeckePacket` with two generators T_{p,1} and T_{p,2} at each prime and the corresponding recursion relations. Verify computationally that the local generating series is annihilated by the degree-3 Euler polynomial (1 - a₁(p)T + a₂(p)pT² - p³T³).

**Impact.** This would be a paradigm-shifting extension: moving from GL₂ to GL_n opens the entire automorphic spectrum. The GL₃ case is directly connected to symmetric-square L-functions and the Gelbart-Jacquet lift, providing concrete access to the Langlands functoriality conjectures.

**Catalog References.** `Pythagorean/HeckePacket/Defs.lean` (generalize structure), `Pythagorean/HeckePacket/EulerFactor.lean` (generalize to degree-n polynomial).

**Proof Strategy.** Define GL_n Hecke packets with n-1 independent generators at each prime. The Satake isomorphism identifies the spherical Hecke algebra with the ring of symmetric polynomials in n variables, giving the recursion structure. Prove the Euler factor identity by induction on the degree of the Euler polynomial.

**Domain Bridges.** Number theory ↔ combinatorics (partition theory), number theory ↔ representation theory (symmetric group actions), algebra ↔ mathematical physics (quantum group structures).

**Lineage.** Ambitious generalization of the entire current framework.

**Ambition.** Grand challenge — requires new mathematical infrastructure beyond the current GL₂ setting.
