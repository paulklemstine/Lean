# Future Directions: Primewise Persistent Homology

## Synthesis

This cycle established the mathematical foundations for primewise persistence barcodes — a novel invariant system that assigns persistence data to each prime number and uses the collective behavior across primes to distinguish geometric objects that classical spectral methods cannot separate. The key discovery is that the structural properties of persistence barcodes (additivity, stability, nontriviality) extend naturally to the prime-indexed setting, creating a robust framework for the separation conjecture.

The most promising cross-domain connection is between **tropical persistence** (from the Catalog's `Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean`) and the primewise framework. The `exists_unique_barcode_from_rank_data` theorem guarantees that rank data uniquely determines barcodes; combining this with prime-indexed rank data from mod-p reductions would give a canonical primewise signature. This connection also links to the prime gap results in `MachineLearning/PrimeGapFramework.lean`, which provide density-theoretic tools needed for the positive-density conjecture. The highest breakthrough potential lies in Direction 1 (Chebotarev-Persistence Bridge), which would connect the separating prime density to Galois-theoretic data and potentially resolve the conjecture via established number-theoretic machinery.

The cycle's results relate to the broader Catalog through the EML lens: persistence barcodes are a form of multi-scale closure operator (connecting to `EML/ClosureOperator.lean`), and the primewise construction is a categorification that mirrors the ensemble complexity framework (`EML/AdvancedTheory.lean`). The Sunada triple formalization connects to the algebraic structures in `Algebra/` through finite group theory.

---

### Direction 1: Chebotarev-Persistence Bridge

**Conjecture**: For a Sunada pair (M, N) arising from an arithmetic lattice in a semisimple group G over a number field F, the separating prime set S(M, N) is a union of Frobenius conjugacy classes in Gal(K/F) for some finite extension K/F, and therefore has natural density equal to |S_Frob|/|Gal(K/F)| by Chebotarev.

**Test**: For the S₈ Sunada pair, identify the number field F and extension K/F such that the mod-p barcode behavior depends only on the Frobenius class of p in Gal(K/F). Compute the predicted density and compare against the empirical separating density from the first 1000 primes.

**Impact**: If true, this would reduce the positive-density separation conjecture to a computation in algebraic number theory, providing a complete proof strategy. It would also reveal that primewise persistence is not just a topological invariant but an arithmetic one, encoding Galois-theoretic information. If false, it would show that persistence barcodes capture genuinely new information beyond Frobenius behavior.

**Catalog References**: `Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean` (barcode uniqueness), `MachineLearning/CRT.lean` (prime avoidance via CRT), `EML/PrimewisePersistence.lean` (separating prime set formalization)

**Proof Strategy**:
1. Formalize the notion of a Frobenius-determined prime invariant: I(p) depends only on Frob_p in Gal(K/F).
2. Show that the mod-p simplicial complex construction is Frobenius-determined for good primes.
3. Apply Chebotarev: the set of primes with any given Frobenius class has density |C|/|G|.
4. Conclude that the separating set, being a union of classes, has rational density.

Key lemmas needed:
- Frobenius determination of mod-p congruence orbits
- Functoriality of the Vietoris-Rips construction under Frobenius action
- Chebotarev density theorem (not in Mathlib; would need formalization or axiomatization)

**Domain Bridges**: NumberTheory <-> Topology, AlgebraicGeometry <-> TDA

**Lineage**: Builds on the primewise persistence framework from this cycle (EML/PrimewisePersistence.lean), the tropical persistence realization duality (Bridges), and prime distribution results (MachineLearning/PrimeGapFramework.lean).

**Ambition**: grand_challenge

---

### Direction 2: Multiparameter Prime Persistence

**Conjecture**: For tuples of primes (p₁, ..., p_k), the k-parameter persistence module obtained by intersecting mod-p_i filtrations has strictly more discriminating power than any single prime's barcode. Specifically, there exist isospectral pairs where no single-prime barcode separates them but the 2-parameter module at (p₁, p₂) does.

**Test**: Construct a Sunada pair where τ_p(M) = τ_p(N) for all primes p (single-prime total persistence agrees) but the 2-parameter persistence module at (2, 3) differs. This requires computing bigraded Betti numbers.

**Impact**: This would show that prime interactions carry geometric information beyond what individual primes reveal, analogous to how 2-parameter persistent homology captures information invisible to 1-parameter slices. It would motivate a full multiparameter primewise theory.

**Catalog References**: `EML/AdvancedTheory.lean` (ensemble complexity, multi-scale analysis), `Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean` (barcode realization)

**Proof Strategy**:
1. Define 2-parameter filtrations indexed by (ℕ, ℕ) via simultaneous mod-p₁ and mod-p₂ reduction.
2. Formalize the bigraded Betti numbers β_{s,t}.
3. Construct an explicit example where β_{s,t}(M) ≠ β_{s,t}(N) but all 1-parameter slices agree.
4. Use the Chinese Remainder Theorem structure (connecting to `MachineLearning/CRT.lean`) to show that the 2-parameter data encodes CRT orbits.

**Domain Bridges**: NumberTheory <-> AlgebraicTopology, Computation <-> Geometry

**Lineage**: Extends the single-prime framework of this cycle to multiparameter settings.

**Ambition**: extension

---

### Direction 3: Primewise Persistence for Graph Isomorphism

**Conjecture**: For strongly regular graphs that are cospectral (same adjacency spectrum) but nonisomorphic, the primewise persistence barcode computed from mod-p adjacency data separates them for at least one prime p ≤ max(n, 100), where n is the number of vertices.

**Test**: Take the Shrikhande graph (16 vertices) and the 4×4 rook's graph — these are cospectral strongly regular graphs. Compute mod-p persistence for p = 2, 3, 5, 7, 11, 13. If at least one separates them, the conjecture is supported; if none do, it suggests the bound needs revision.

**Impact**: If true, this gives a polynomial-time heuristic for a hard case of graph isomorphism (cospectral SRGs). The bound p ≤ max(n, 100) would make the method computationally feasible.

**Catalog References**: `EML/PrimewisePersistence.lean` (barcode definitions and structural theorems), `Computation/InfoEfficientAlgorithms.lean` (algorithmic efficiency bounds)

**Proof Strategy**:
1. Define mod-p adjacency complexes: vertices are graph vertices, k-simplices are cliques where all edge weights ≡ 0 mod p.
2. Show that the mod-p Betti numbers refine the adjacency spectrum.
3. For SRGs, relate the mod-p barcode to the p-rank of the adjacency matrix.
4. Use known p-rank differences for nonisomorphic cospectral SRGs to conclude separation.

**Domain Bridges**: Computation <-> Topology, GraphTheory <-> NumberTheory

**Lineage**: Applies the primewise framework to the concrete setting of finite graphs, testing the theory in a computationally accessible domain.

**Ambition**: extension

---

### Direction 4: Quantum Primewise Persistence via Modular Representations

**Conjecture**: For each prime p, the mod-p representation ring of the fundamental group π₁(M) determines a "quantum barcode" via the decomposition of the regular representation into indecomposables. For Sunada pairs over non-semisimple mod-p group algebras, the quantum barcode differs from the classical barcode and provides additional separating information.

**Test**: For the S₈ Sunada pair at p = 2, the group algebra F₂[H₁] is not semisimple. Compute the indecomposable decomposition of the regular representations of H₁ and H₂ over F₂. If the decomposition multiplicities differ, the quantum barcode separates at p = 2 (where the classical barcode fails).

**Impact**: This would create a bridge between modular representation theory and persistent homology, showing that non-semisimple phenomena (which are invisible to character theory and hence to Sunada's spectral argument) are detectable by persistence. It would open a new chapter in the interaction between representation theory and TDA.

**Catalog References**: `EML/ModularForms.lean` (modular structures), `Algebra/Basic.lean` (algebraic foundations), `EML/PrimewisePersistence.lean` (barcode framework)

**Proof Strategy**:
1. Define the quantum barcode: intervals correspond to indecomposable modules, with birth/death from the radical filtration.
2. Show that for semisimple group algebras, the quantum barcode reduces to the classical one.
3. At primes dividing |G|, the non-semisimple structure creates additional intervals.
4. For Sunada triples, almost-conjugacy preserves character-theoretic data but not indecomposable structure.

**Domain Bridges**: Algebra <-> Topology, Physics <-> NumberTheory

**Lineage**: Combines the primewise framework with the modular forms infrastructure in the Catalog, extending to representation-theoretic territory.

**Ambition**: grand_challenge

---

### Direction 5: Persistence Entropy and Arithmetic Complexity

**Conjecture**: Define the persistence entropy of a barcode B as H(B) = -Σ_i (ℓ_i/L) log(ℓ_i/L) where ℓ_i = d_i - b_i and L = τ(B). For a Sunada pair (M, N), the sequence of primewise persistence entropies {H(B_p(M)) - H(B_p(N))}_p converges to a nonzero limit related to the log of the index [G : N_G(H₁)] / [G : N_G(H₂)], where N_G denotes the normalizer.

**Test**: For the S₈ pair, compute H(B_p) for p = 2, 3, ..., 97 for both M and N. Plot the running average of |H(B_p(M)) - H(B_p(N))| and check for convergence. The predicted limit involves normalizer indices that can be computed from the group theory.

**Impact**: If true, this would give a numerical invariant (a real number) derived from the asymptotic behavior of primewise entropies that distinguishes isospectral pairs. It would connect information-theoretic quantities to group-theoretic structure, bridging the ensemble complexity framework in EML with arithmetic geometry.

**Catalog References**: `EML/AdvancedTheory.lean` (ensemble complexity as a form of entropy), `EML/PrimewisePersistence.lean` (barcode total persistence = denominator L), `MachineLearning/PrimeGapFramework.lean` (prime distribution)

**Proof Strategy**:
1. Formalize persistence entropy as a function of barcode data.
2. Show entropy is continuous with respect to small perturbations of the barcode.
3. Relate the mod-p barcode structure to the p-adic valuation of the discriminant.
4. Use the prime number theorem to convert the sum over primes to an integral.
5. Evaluate the integral using normalizer index data.

**Domain Bridges**: InformationTheory <-> NumberTheory, EML <-> ArithmeticGeometry

**Lineage**: Extends the total persistence invariant from this cycle to an entropy-based invariant, connecting to the ensemble complexity framework.

**Ambition**: extension
