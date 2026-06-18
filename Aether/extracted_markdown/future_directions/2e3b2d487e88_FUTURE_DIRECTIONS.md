# Future Directions: Arithmetic Persistence Theory

## Synthesis

This cycle established the foundational layer of arithmetic persistence theory through three categories of results: (1) the persistent rank function as a complete invariant for sorted slope profiles, with antitonicity and separation guarantees; (2) the tropical defect as a bridge between persistence data and the functional equation symmetry of zeta functions; and (3) the jump count theorem connecting persistence curve structure to formal group heights.

The most promising cross-domain connection is the bridge between **topological data analysis** and **p-adic Hodge theory**. The persistent rank function lives naturally in both worlds — it is simultaneously a persistence curve (in the TDA sense) and a Newton polygon invariant (in the arithmetic geometry sense). The separation theorem shows these are not merely analogous: the persistence viewpoint *exactly captures* the arithmetic information. This opens the door to importing the full machinery of persistent homology — stability theorems, bottleneck distances, persistence landscapes — into arithmetic geometry, where no such computational toolkit existed before.

The tropical defect provides the second key bridge, connecting to **tropical geometry**. The defect measures deviation from Newton polygon self-duality, which in the tropical world corresponds to the failure of a piecewise-linear function to satisfy a reflection symmetry. This connects our results to the broader program of tropical mirror symmetry and tropical Hodge theory.

The direction with highest breakthrough potential is **Direction 1 (Height Refinement)**: upgrading the binary supersingular/ordinary classifier to a complete height detector. If the conjecture holds, it would provide the first persistence-based algorithm for computing formal group heights — a problem currently requiring deep algebraic machinery (Dieudonné modules, deformation theory). The conjecture is explicitly falsifiable by computation, making it an ideal target for the next research cycle.

---

### Direction 1: Height Refinement — Complete Height Detection via Persistence Jump Structure

**Conjecture**: For a K3 surface $X$ over $\mathbb{F}_q$ with formal Brauer group of finite height $h \in \{1, \ldots, 10\}$, let $\sigma$ be its sorted crystalline Frobenius slope profile (22 rational numbers in $[0, 2]$). Then:

(a) The persistent rank function $r_\sigma$ has exactly $2h + 1$ distinct values (including 0 and 22).

(b) The number of distinct slope values in the lower half-profile (slopes $\leq 1$) equals $h + 1$.

(c) The jump magnitude pattern (multiset of drop sizes at each jump) uniquely determines $h$.

Equivalently: $\mathrm{distinctCount}(\sigma) = 2h + 1$ and $\mathrm{jumpCount}(\sigma) = 2h$.

**Test**: Compute Frobenius slopes of the diagonal quartic K3 surface $X: x_0^4 + x_1^4 + x_2^4 + x_3^4 = 0$ over $\mathbb{F}_p$ for primes $p \equiv 1 \pmod{4}$ with $p < 500$. Use Kedlaya's $p$-adic algorithm to get slopes to sufficient precision. For each prime, compute the height $h$ independently via the Artin-Mazur formal group, then verify:
- $\mathrm{distinctCount}(\sigma) \stackrel{?}{=} 2h + 1$
- $\mathrm{jumpCount}(\sigma) \stackrel{?}{=} 2h$
- $\mathrm{distinctCount}(\sigma|_{\leq 1}) \stackrel{?}{=} h + 1$

The conjecture fails if *any* prime produces a mismatch.

**Impact**: If true, this upgrades the binary classifier (supersingular vs. finite height) to a complete height detector, recovering $h \in \{1, \ldots, 10, \infty\}$ from a simple counting operation on the persistent rank curve. This would be:
- The first persistence-based algorithm for formal group heights.
- A new computational tool for studying the stratification of the K3 moduli space by height.
- A potential ingredient in algorithms for computing endomorphism rings of abelian surfaces (relevant to isogeny-based cryptography).

If false, the failure pattern reveals which heights share persistence signatures, pointing to a coarser but still useful classification.

**Catalog References**: `Algebra/ArithmeticPersistenceTheory.lean` — `persistentRank_separation`, `jumpCount_succ_eq_distinctCount`, `height_bounded_by_dim`. `Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean` — `exists_unique_barcode_from_rank_data`.

**Proof Strategy**: 
1. Establish that for a K3 surface of height $h$, the Newton polygon has slopes $\{0, 1/h, 2/h, \ldots, (h-1)/h, 1, (h+1)/h, \ldots, 2\}$ with specific multiplicities (from the classification of Newton polygons of K3 surfaces by Illusie and others).
2. Count distinct values in this canonical form to verify $2h + 1$.
3. For the uniqueness claim (c), show the multiplicity pattern varies with $h$ by explicit computation for $h = 1, \ldots, 10$.
4. Key lemma needed: the Newton polygon of a K3 surface of height $h$ is uniquely determined by $h$ (this follows from the Dieudonné-Manin classification applied to the formal Brauer group).

**Domain Bridges**: NumberTheory <-> TDA, AlgebraicGeometry <-> TropicalGeometry

**Lineage**: Builds on `persistentRank_separation` and `jumpCount_succ_eq_distinctCount` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Persistence Stability for Slope Perturbation — Bottleneck Distance Bounds

**Conjecture**: Let $\sigma, \tau$ be two slope profiles of length $n$ with Bottleneck distance $d_B(\sigma, \tau) = \max_i |\sigma(i) - \tau(i)|$ (after sorting). Then the persistent rank functions satisfy the stability bound:

$$|r_\sigma(t) - r_\tau(t)| \leq n \cdot \mathbf{1}_{[t - d_B, t + d_B]}(\text{some slope of } \sigma)$$

More precisely, for any threshold $t$:

$$|r_\sigma(t) - r_\tau(t)| \leq \#\{i \mid |\sigma(i) - t| \leq d_B(\sigma, \tau)\}$$

This is the arithmetic analogue of the algebraic stability theorem for persistence diagrams.

**Test**: 
1. Generate 1000 random slope profiles of length 22.
2. For each, create perturbations at distances $\epsilon = 0.01, 0.05, 0.1, 0.5$.
3. Compute persistent rank differences at 100 threshold values.
4. Verify the bound holds for all cases.

**Impact**: If true, this provides quantitative control over how sensitive the height classification is to computational errors in Frobenius slope computation. This is critical for practical applications: Kedlaya's algorithm computes slopes to finite $p$-adic precision, and stability bounds would certify that approximate slopes yield correct height classifications.

**Catalog References**: `Algebra/ArithmeticPersistenceTheory.lean` — `persistentRank_antitone`, `persistentRank_add_const`. `EML/PrimewisePersistence.lean` — `PersistenceBarcode`, `PersistenceBarcode.bettiAt`.

**Proof Strategy**:
1. For each index $i$, either both $\sigma(i) \geq t$ and $\tau(i) \geq t$ (contributes 0 to the difference) or their membership in the filter differs. The latter requires $|\sigma(i) - t| \leq d_B$ or $|\tau(i) - t| \leq d_B$.
2. Bound the number of indices where filter membership differs.
3. Key lemma: if $|\sigma(i) - \tau(i)| \leq \epsilon$ and $\sigma(i) \geq t$, then $\tau(i) \geq t - \epsilon$. Use `persistentRank_antitone`.

**Domain Bridges**: TDA <-> NumberTheory, ComputationalAlgebra <-> ApproximationTheory

**Lineage**: Builds on `persistentRank_antitone` and `persistentRank_add_const` from this cycle.

**Ambition**: extension

---

### Direction 3: Abelian Variety Classification — Dimension-Indexed Persistence Modules

**Conjecture**: For an abelian variety $A$ of dimension $g$ over $\mathbb{F}_q$, define the *multi-threshold persistent rank* as the function $R_A : \mathbb{Q}^g \to \mathbb{N}^g$ where the $j$-th component counts slopes in the $j$-th isogeny factor above the $j$-th threshold. Then:

(a) $R_A$ determines the Newton polygon stratum of $A$.

(b) Two abelian varieties with the same $R_A$ have isogenous formal groups.

(c) The joint jump structure of $R_A$ encodes the full Newton polygon (including multiplicities of slopes from different isogeny factors).

**Test**: For $g = 2$ (abelian surfaces), there are finitely many Newton polygon types. For each type, construct an explicit abelian surface over a small finite field (using CM constructions), compute its multi-threshold persistent rank, and verify that different types yield different $R_A$ values.

Specifically: the 5 Newton polygon types for $g = 2$ are:
1. Ordinary: slopes $\{0, 0, 1, 1\}$
2. Almost ordinary: slopes $\{0, 1/2, 1/2, 1\}$
3. Supersingular (type 1): slopes $\{1/2, 1/2, 1/2, 1/2\}$
4. Height 2: slopes $\{0, 1/2, 1/2, 1\}$ with different multiplicities
5. Supersingular (type 2): slopes $\{1/4, 3/4, 1/4, 3/4\}$

Compute the persistent rank for each and verify separation.

**Impact**: Extends arithmetic persistence theory from surfaces (where Newton polygons have well-understood combinatorics) to the full world of abelian varieties. For cryptographic applications, the Newton polygon type of an abelian surface over $\mathbb{F}_p$ determines which isogeny-based protocols are secure.

**Catalog References**: `Algebra/ArithmeticPersistenceTheory.lean` — `SlopeProfile`, `ArithPersistenceSignature`. `Tropical/Arithmetic/TropicalBSDAbelianVariety.lean`.

**Proof Strategy**:
1. Define `MultiSlopeProfile (g n : ℕ)` as a product of `g` slope profiles.
2. Extend `persistentRank` to the multi-threshold setting.
3. Prove multi-threshold separation by reducing to the single-component case (our existing Separation Theorem).
4. Key difficulty: handling the interaction between components (non-trivial for non-simple abelian varieties).

**Domain Bridges**: AlgebraicGeometry <-> TDA, NumberTheory <-> Cryptography

**Lineage**: Builds on `persistentRank_separation` and `ArithPersistenceSignature` from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Prime Variation and Arithmetic Phase Transitions

**Conjecture**: For a fixed K3 surface $X$ over $\mathbb{Q}$, let $\sigma_p$ denote its Frobenius slope profile at prime $p$ (for primes of good reduction). Define the *persistence entropy* at prime $p$:

$$H_p(X) = -\sum_{v \in \mathrm{slopes}_p} \frac{m_v}{n} \log \frac{m_v}{n}$$

where $m_v$ is the multiplicity of slope $v$ and $n$ is the total number of slopes. Then:

(a) $H_p(X) \to \log n$ as $p \to \infty$ along primes of ordinary reduction (the slope distribution becomes uniform, consistent with Sato-Tate for the eigenvalue distribution).

(b) There exist *phase transition primes* where $H_p(X)$ drops sharply, corresponding to supersingular reduction.

(c) The density of supersingular primes (where $H_p(X)$ is minimal) is related to the Picard number of $X$ via the Artin-Tate conjecture.

**Test**: For the Fermat quartic K3 surface $x_0^4 + x_1^4 + x_2^4 + x_3^4 = 0$:
1. Compute $\sigma_p$ for primes $p < 200$ of good reduction.
2. Compute $H_p$ for each.
3. Plot $H_p$ vs. $p$ and identify phase transitions.
4. Compare supersingular primes (where $H_p$ is minimal) with known results for this surface.

**Impact**: If confirmed, this connects arithmetic persistence theory to the Sato-Tate conjecture and provides a new computational tool for studying the distribution of Newton polygons across primes. The phase transitions would give a TDA-flavored perspective on the supersingular locus.

**Catalog References**: `Algebra/ArithmeticPersistenceTheory.lean` — `countDistinct`, `ArithPersistenceSignature`. `EML/PrimewisePersistence.lean` — `PrimewiseInvariant`, `separatingPrimeSet`. `Algebra/CausalCertification.lean` — `spectral_width_increases_with_primes`.

**Proof Strategy**:
1. For (a): use the Sato-Tate conjecture (now a theorem for K3 surfaces, by work of Barnet-Lamb, Geraghty, Harris, Taylor) to show that Frobenius eigenvalue angles equidistribute, which forces slope multiplicities to spread out.
2. For (b): use the density theorem of Elkies (generalized by Charles) showing infinitely many supersingular primes for K3 surfaces with Picard number $\geq 2$.
3. For (c): relate the asymptotic density of supersingular primes to the Artin-Tate formula for the Brauer group.

**Domain Bridges**: NumberTheory <-> StatisticalMechanics, ArithmeticGeometry <-> TDA

**Lineage**: Builds on `persistentRank_antitone` and the arithmetic persistence signature from this cycle. Connects to `spectral_width_increases_with_primes` from the Catalog.

**Ambition**: grand_challenge

---

### Direction 5: Certified Height Oracle — Verified Algorithm with Cryptographic Guarantees

**Conjecture**: There exists a polynomial-time algorithm that, given:
- A K3 surface $X$ defined by equations over $\mathbb{F}_p$,
- An approximation $\tilde{\sigma}$ of the Frobenius slope profile to precision $p^{-N}$,

outputs the formal Brauer group height $h(X)$ together with a machine-checkable certificate (a Lean proof term) that the output is correct, provided $N > C \cdot h^2$ for an explicit constant $C$.

**Test**: Implement the algorithm for diagonal quartic K3 surfaces over $\mathbb{F}_p$ for $p < 100$. For each surface:
1. Compute slopes via Kedlaya's algorithm to precision $p^{-20}$.
2. Run the persistent rank computation and extract the height.
3. Verify the height against known results (from Goto-Livné-Yui tables).
4. Generate a Lean proof term certifying the classification.

**Impact**: This would provide the first *certified* computational tool for formal group height classification, with applications to:
- Isogeny-based cryptography: certifying that an abelian variety has the correct endomorphism ring structure.
- Verified number theory: producing machine-checked certificates for Newton polygon computations.
- Automated arithmetic geometry: a height oracle that other verified proofs can call.

**Catalog References**: `Algebra/ArithmeticPersistenceTheory.lean` — all theorems. `Computation/InfoEfficientAlgorithms.lean` — `InfoEfficientAlgorithm`. `Algebra/CausalCertification.lean`.

**Proof Strategy**:
1. Use the stability bound (Direction 2) to determine the required precision $N$.
2. Show that for precision $N > C \cdot h^2$, the approximate slopes are close enough to the true slopes that the persistent rank function is preserved (by stability).
3. The certificate is a Lean proof term that: (a) the input slopes are within the certified precision, (b) the persistent rank curve has the claimed jump structure, (c) by the Jump Count Theorem, this determines the height.
4. Key lemma: certified inequality checking for rationals in Lean (using `norm_num` extensions).

**Domain Bridges**: Computation <-> NumberTheory, Cryptography <-> FormalVerification

**Lineage**: Builds on all theorems from this cycle plus Direction 2 (stability).

**Ambition**: extension
