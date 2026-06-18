# Future Directions: Quantitative DPI for Lattice Cryptography

## Synthesis

The fiber structure theorem and quantitative DPI established here form a bridge between three mathematical domains: number theory (Beatty sequences, modular arithmetic), information theory (data processing inequality, total variation distance), and cryptography (Module-LWE security, compression analysis). Each direction below extends one of these bridges, either by tightening the contraction bounds, generalizing the fiber structure to richer algebraic settings, or connecting the compression geometry to other areas of mathematics. Together, these directions chart a path from the single-coordinate, single-map analysis presented here toward a complete quantitative security theory for lattice-based cryptography.

---

### Direction 1: Sharp CBD Contraction via Moment Methods

**Conjecture:** For the centered binomial distribution CBD(η) on Z/qZ used in CRYSTALS-Kyber, the contraction ratio satisfies:

    Δ(compress_* CBD(η), compress_* U) ≤ (d/q) · C(η) · Δ(CBD(η), U)

where C(η) = O(√η) rather than the current bound C(η) = q · max(CBD(η)) = O(q/√η).

**Test:** Compute the exact contraction ratio for CBD(η) with η ∈ {1, 2, 3, 4, 5} and q = 3329, d ∈ {16, 32, 1024, 2048}. Verify that the empirical contraction is sublinear in η. If C(η) grows faster than √η for any parameter set, the conjecture is falsified.

**Impact:** A polynomial improvement in the contraction bound (from O(q/√η) to O(√η)) would directly translate to tighter security reductions for Kyber, potentially allowing smaller parameters for the same security level — reducing ciphertext size by 10-20%.

**Catalog References:** `Pythagorean/KyberCompress.lean` (fiber structure), `demo.py` (contraction computation)

**Proof Strategy:** Exploit the unimodal, symmetric structure of CBD(η). The key idea is that the contraction factor should depend on the *variance* of the distribution (which is η for CBD(η)), not the *maximum* (which is the binomial coefficient C(2η, η)/2^{2η}). Use the moment method: bound the fiber-wise TV contribution using the second moment of the distribution restricted to each fiber, then apply Cauchy-Schwarz.

**Domain Bridges:** Probability theory (moment methods) ↔ Combinatorics (binomial distribution) ↔ Cryptography (Kyber noise)

**Lineage:** Direct extension of the smooth contraction bound (Theorem 4.1)

**Ambition:** ★★★☆☆ (Solid extension — requires new analysis but known techniques)

---

### Direction 2: Optimal Compression Maps via Majorization Theory

**Conjecture:** Among all deterministic maps f: Z/qZ → Z/dZ, the floor-based compression compress(x) = ⌊d·x/q⌋ minimizes the worst-case contraction ratio

    sup_{χ: L-smooth} Δ(f_* χ, f_* U) / Δ(χ, U)

up to a factor of (1 + O(1/q)), and this optimality is achieved precisely when the fiber size distribution is {⌊q/d⌋, ⌈q/d⌉} (the most balanced possible).

**Test:** For q = 31 (small prime) and d = 8, enumerate all 31^8 possible maps f: Z/31Z → Z/8Z... this is infeasible. Instead, restrict to "balanced" maps where each fiber has size 3 or 4, and compare the worst-case contraction ratio across 1000 random balanced maps vs. the floor-based map. If any balanced map achieves a strictly better worst-case ratio, the optimality conjecture is falsified.

**Impact:** Would establish that Kyber's compression is not only convenient but information-theoretically optimal, ruling out attacks that exploit sub-optimality of the compression scheme.

**Catalog References:** `Pythagorean/KyberCompress.lean` (fiber balance property)

**Proof Strategy:** Use majorization theory. The fiber size vector of compress_{q,d} majorizes (in the Schur sense) the fiber size vector of any balanced map. By Schur-convexity of the worst-case contraction functional, the optimal map is the most balanced one. The floor-based compression is the unique (up to permutation) balanced map with the Beatty-sequence interspersion property.

**Domain Bridges:** Majorization theory ↔ Optimization ↔ Cryptographic design

**Lineage:** Extends the fiber balance property (Theorem 3.2)

**Ambition:** ★★★★☆ (Grand challenge — connects optimization theory to cryptographic design)

---

### Direction 3: Polynomial Ring Fiber Structure

**Conjecture:** For the polynomial ring R_q = Z_q[x]/(x^n + 1) used in Kyber (n = 256), the component-wise compression map compress^n: R_q → R_d creates fibers whose sizes satisfy:

    |fiber(y₁, ..., y_n)| = ∏ᵢ |fiber_coord(yᵢ)|

and the k-dimensional contraction bound (d/q)^{nk} holds for Module-LWE with k modules of n coefficients each.

**Test:** For small parameters (q = 17, n = 4, d = 4, k = 2), enumerate all fibers of the component-wise compression and verify the product structure. Compute the actual contraction ratio for Module-LWE noise and compare with (d/q)^{nk}.

**Impact:** Would extend the fiber structure theorem from the single-coordinate case to the full polynomial ring, enabling a complete quantitative security analysis of Kyber as deployed.

**Catalog References:** `Pythagorean/KyberCompress.lean` (single-coordinate fiber structure)

**Proof Strategy:** The product structure follows immediately from the independence of component-wise compression. The challenge is handling the NTT domain: Kyber applies compression in the coefficient domain, but noise is generated in the NTT domain. The NTT is an isomorphism of rings, so the fiber structure should transfer — but the transfer of the smoothness property through the NTT requires Parseval's identity for the discrete Fourier transform over Z_q.

**Domain Bridges:** Algebraic number theory (polynomial rings) ↔ Signal processing (NTT/DFT) ↔ Lattice cryptography

**Lineage:** Extends single-coordinate analysis to full Kyber parameters

**Ambition:** ★★★☆☆ (Solid extension — the product structure is straightforward, NTT transfer is the hard part)

---

### Direction 4: Rényi Divergence Contraction for Tight Multi-dimensional Bounds

**Conjecture:** For the Rényi divergence of order α > 1, the compression map contracts by a factor of (d/q)^{k(α-1)/α}:

    D_α(compress_*^k χ || compress_*^k U) ≤ (d/q)^{k(α-1)/α} · D_α(χ || U)

This yields, via the Rényi-to-TV inequality TV ≤ √(D₂/2), a bound of:

    Δ(compress_*^k χ, compress_*^k U) ≤ √((d/q)^{k/2} · D₂(χ||U) / 2)

which is stronger than the L-smooth bound for distributions with bounded Rényi divergence.

**Test:** For q = 3329, d = 1024, k = 3, compute D₂(compress_* D_σ || compress_* U) for σ ∈ {1, ..., 30} and compare with (d/q)^{k/2} · D₂(D_σ || U). If the ratio exceeds 1 for any σ, the Rényi contraction conjecture is falsified.

**Impact:** Would provide an alternative, potentially tighter, approach to quantitative security bounds that leverages the extensive Rényi divergence machinery developed for lattice cryptography.

**Catalog References:** `Pythagorean/KyberCompress.lean` (DPI framework)

**Proof Strategy:** Prove the Rényi DPI by fiber decomposition: within each fiber of size s, the Rényi contribution is bounded by s^{1-α} · (Σ_{x∈fiber} χ(x)^α). Sum over fibers using Hölder's inequality with the fiber size bound.

**Domain Bridges:** Information theory (Rényi divergence) ↔ Cryptography (leftover hash lemma) ↔ Number theory (fiber structure)

**Lineage:** Parallel to the TV-based DPI, using Rényi instead

**Ambition:** ★★★★★ (Grand challenge — would unify TV and Rényi approaches to lattice security)

---

### Direction 5: Three-Distance Theorem and Kyber Fiber Geometry

**Conjecture:** The fiber sizes of compress_{q,d} take at most 3 distinct values, and when gcd(q, d) = 1, they take exactly 2 values (⌊q/d⌋ and ⌈q/d⌉). This is a consequence of the *three-distance theorem* (Steinhaus conjecture, proved by Sós 1958): the points {k·α mod 1 : k = 0, ..., n-1} partition the unit circle into arcs of at most 3 distinct lengths.

**Test:** For q ∈ {100 random primes between 1000 and 10000} and d ∈ {powers of 2 up to q}, verify that the fiber sizes take exactly 2 distinct values when gcd(q, d) = 1. Then test with non-coprime q, d (e.g., q = 1000, d = 100) to check whether 3 distinct fiber sizes appear.

**Impact:** Would connect the Kyber fiber structure to the deep three-distance theorem in Diophantine approximation, opening the door to using continued fraction theory and ergodic theory for cryptographic analysis.

**Catalog References:** `Pythagorean/KyberCompress.lean` (fiber balance: exactly 2 sizes when d ≤ q)

**Proof Strategy:** View the compression map as placing d equally-spaced points on a circle of circumference q. The fiber sizes are the gap lengths, which by the three-distance theorem take at most 3 values. When gcd(q,d) = 1, the points are in "generic position" (the rotation angle q/d is irrational modulo 1 when q is not a multiple of d), and the three-distance theorem guarantees exactly 2 or 3 gap lengths. The coprimality condition forces exactly 2.

**Domain Bridges:** Diophantine approximation (three-distance theorem) ↔ Ergodic theory (irrational rotations) ↔ Cryptography (Kyber fibers)

**Lineage:** Deepens the Beatty sequence connection established in the fiber structure theorem

**Ambition:** ★★★★☆ (Grand challenge — connects to deep number theory with concrete cryptographic implications)
