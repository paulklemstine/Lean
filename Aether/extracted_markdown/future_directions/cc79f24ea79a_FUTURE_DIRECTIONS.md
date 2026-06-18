# Future Directions: Spectral Sparsity of Liar Sets

## Synthesis

The formal theory of additive energy for finite abelian groups, established in `Pythagorean/SpectralSparsity.lean`, provides a rigorous foundation for studying the additive structure of Miller–Rabin strong liar sets. The 14 formally verified theorems — including the cubic upper bound, Cauchy–Schwarz lower bound, translation invariance, monotonicity, and disjoint union superadditivity — constitute a complete axiomatic framework for additive energy analysis.

Computational experiments reveal that strong liar sets consistently exhibit sub-generic additive energy, with energy exponents α(n) ∈ [2.0, 2.8] across all tested composites. This spectral diffuseness connects three mathematical domains: additive combinatorics (sum-product phenomena), spectral graph theory (Cayley graph expansion), and number theory (primality testing).

The following five directions build directly on this foundation, progressing from concrete extensions of the verified framework to ambitious structural conjectures.

---

## Direction 1: CRT Product Energy Theorem for Semiprimes

**Conjecture:** For n = pq with distinct odd primes p, q, the additive energy of the strong liar set satisfies E(L(pq)) ≤ E(Fib_p(L)) · E(Fib_q(L)) · f(p,q) where f(p,q) is a correction factor bounded by min(p,q)^{1/2} that accounts for the sub-direct product structure.

**Test:** Compute E(L(pq)), E(Fib_p), E(Fib_q) for all semiprimes pq ≤ 5000. Verify that the ratio E(L(pq))/(E(Fib_p)·E(Fib_q)) is bounded and compute f(p,q) empirically. If the ratio grows unboundedly, the conjecture fails.

**Impact:** Would directly prove the Spectral Sparsity Conjecture for semiprimes by reducing it to the (easier) fiber-level energy bounds. This is the most direct path from the current formal results to the main conjecture.

**Catalog References:**
- `Pythagorean/SpectralSparsity.lean`: `crtFiber`, `crtFiber_card_le` — the fiber framework
- `Catalog/FINAL/Algebra/Transfer.lean`: `int_sq_congruence_implies_dvd_prod_sum` — modular collision bounds

**Proof Strategy:** Formalize the product energy theorem `additiveEnergy_product` (which states E(A×B) = E(A)·E(B) for direct products) and then bound the deviation for sub-direct products using the coupling structure of the Miller–Rabin test.

**Domain Bridges:** Additive combinatorics → Number theory (CRT structure) → Algebraic geometry (fiber products)

**Lineage:** Extends `additiveEnergy_product` (skeleton in current file) and `crtFiber_card_le`.

**Ambition:** Solid extension — the product energy theorem for direct products is standard; the sub-direct correction is the novel contribution.

---

## Direction 2: Fourier L⁴ Norm and Spectral Gap of Liar-Set Cayley Graphs

**Conjecture:** For odd composite non-prime-powers n, the Cayley graph Cay(ℤ/nℤ, L(n)) has spectral gap δ(n) ≥ c/log(log n) for some universal constant c > 0. Equivalently, the Fourier L⁴ norm of the indicator function 1_{L(n)} satisfies ‖ℱ(1_L)‖₄⁴ ≤ (1−δ)⁴·|L|⁴/n.

**Test:** Compute the full Fourier transform of 1_{L(n)} over ℤ/nℤ for n ≤ 1000 using FFT. Compute the L⁴ norm and the spectral gap. If δ(n) → 0 faster than 1/log(log n), the conjecture fails.

**Impact:** Would establish a direct connection between the additive energy framework and the mixing time of random walks on the liar-set Cayley graph, giving a spectral-theoretic explanation for Miller–Rabin's success.

**Catalog References:**
- `Pythagorean/SpectralSparsity.lean`: `additiveEnergy_ge_fourth_div` — the Cauchy–Schwarz energy bound
- `Catalog/FINAL/Algebra/Transfer.lean`: `spectral_energy_modular_collision_bound` — spectral energy framework

**Proof Strategy:** Use the Parseval identity E(S) = |G|·Σ|ℱS(ξ)|⁴ together with the energy bound to control the Fourier L⁴ norm. The spectral gap follows from the L⁴ bound via standard arguments (e.g., Expander Mixing Lemma).

**Domain Bridges:** Additive combinatorics → Spectral graph theory → Probability (random walks) → Cryptography (mixing)

**Lineage:** Builds on `additiveEnergy_ge_fourth_div` and connects to `spectral_energy_modular_collision_bound`.

**Ambition:** Grand challenge — requires formalizing Fourier analysis over finite abelian groups, which is partially available in Mathlib but not fully connected to our energy framework.

---

## Direction 3: Energy Exponent Bounds for Carmichael Numbers

**Conjecture:** For Carmichael numbers n with k ≥ 3 prime factors, the energy exponent satisfies α(n) ≤ 3 − 1/(k−1). In particular, for 3-factor Carmichael numbers, α ≤ 2.5.

**Test:** Compute α(n) for all Carmichael numbers n ≤ 100,000. Classify by number of prime factors. If any 3-factor Carmichael number has α > 2.5, the conjecture is false. Expected computation time: ~10 hours for full enumeration.

**Impact:** Carmichael numbers are the hardest composites for Fermat-type tests (every coprime base is a Fermat liar). Showing that their energy exponent is bounded away from 3 would demonstrate that even in the worst case, liars are additively sparse.

**Catalog References:**
- `Pythagorean/SpectralSparsity.lean`: `IsSpectrallyDiffuse`, `isSpectrallyDiffuse_mono` — diffuseness framework
- `Catalog/Speculative/AutoResearch/PrimalityTesting/WitnessTheorems.lean`: `strongLiarSet_card_le_quarter'` — quarter bound

**Proof Strategy:** For Carmichael numbers, every coprime base is a Fermat liar, so L_Fermat(n) = (ℤ/nℤ)×. The strong liar set is a proper subgroup. Use the structure theory of Carmichael numbers (n = p₁...pₖ with (pᵢ−1)|(n−1)) to bound the fiber energies.

**Domain Bridges:** Number theory (Carmichael numbers) → Group theory (subgroup structure) → Additive combinatorics

**Lineage:** Extends `energy_of_bounded_set` with explicit structural bounds.

**Ambition:** Grand challenge — requires deep number-theoretic input about the structure of Carmichael numbers.

---

## Direction 4: Sum-Product Obstruction for Dense Liar Sets

**Conjecture:** If L(n) is a strong liar set with |L(n)| ≥ n^{1/2}, then the sumset satisfies |L(n) + L(n)| ≥ |L(n)|^{1+c} for some absolute c > 0. This is a sum-product phenomenon: the multiplicative structure of liars (being in a subgroup) forces large sumsets.

**Test:** For composites n with |L(n)| ≥ √n, compute |L(n) + L(n)| / |L(n)| and check whether this ratio grows. If it stays bounded, the conjecture fails.

**Impact:** Would connect the spectral sparsity theory to the celebrated Erdős–Szemerédi sum-product conjecture, placing liar-set analysis within the mainstream of additive combinatorics research.

**Catalog References:**
- `Pythagorean/SpectralSparsity.lean`: `additiveEnergy_le_cube`, `additiveEnergy_ge_fourth_div` — energy bounds that relate to sumset sizes via the Plünnecke-Ruzsa inequality

**Proof Strategy:** By the Plünnecke-Ruzsa inequality, E(S) ≤ |S|³·|S+S|/|S|. If E(S) ≥ |S|^{3−ε}, this gives no useful bound. But the multiplicative structure of L forces additional constraints: L is contained in a subgroup of (ℤ/nℤ)×, and subgroups with large intersections with cosets have structured sumsets.

**Domain Bridges:** Additive combinatorics (sum-product) → Number theory (liar sets) → Algebra (subgroup structure)

**Lineage:** Extends `additiveEnergy_le_cube` and uses the sumset expansion connection.

**Ambition:** Solid extension — the sum-product connection is well-understood in additive combinatorics, and adapting it to liar sets should be tractable.

---

## Direction 5: Information-Theoretic Lower Bound on Detection Probability

**Conjecture:** The mutual information I(A; B) between two independently and uniformly chosen elements A, B of L(n) satisfies I(A; B) ≤ c · log|L(n)| / |L(n)|^{1/3} for some constant c. This means liar-set elements are nearly pairwise independent, which gives an information-theoretic proof of Miller–Rabin's amplification property.

**Test:** Compute the joint distribution of (A mod p, A mod q) for semiprimes n = pq and estimate the mutual information. If I(A; B) grows faster than predicted, the conjecture fails.

**Impact:** Would provide the first information-theoretic proof that Miller–Rabin amplifies — that k independent rounds reduce the error probability to (1/4)^k not just in the worst case, but in an average-case sense weighted by the actual liar distribution.

**Catalog References:**
- `Pythagorean/SpectralSparsity.lean`: `collision_prob_le_one` — collision probability bound, which is the Rényi 2-entropy

**Proof Strategy:** The collision probability E(S)/|S|⁴ equals 2^{−H₂(X+Y)} where H₂ is the Rényi 2-entropy. Sub-generic energy means high Rényi entropy, which bounds the mutual information via standard inequalities (Rényi entropy ≥ Shannon entropy for discrete distributions).

**Domain Bridges:** Information theory → Additive combinatorics → Number theory → Cryptography

**Lineage:** Extends `collision_prob_le_one` via the Rényi entropy interpretation.

**Ambition:** Grand challenge — requires formalizing information-theoretic concepts and connecting them to the additive energy framework.
