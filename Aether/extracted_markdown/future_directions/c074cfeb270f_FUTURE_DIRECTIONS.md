# Future Directions: Secondary Torsion Obstructions via Smith Normal Form

## Synthesis

The results in this cycle establish a computational bridge between Smith Normal Form — a classical tool of integer linear algebra — and secondary homological invariants of filtered chain complexes. The core insight is that the connecting homomorphism in a long exact sequence, which encodes "secondary torsion" beyond primary homology, admits an explicit formula in terms of SNF diagonal entries: for invariant factor *d* and torsion order *n*, the connecting element is *n*/gcd(*d*,*n*), generating a cyclic torsion group of order gcd(*d*,*n*).

This opens five research directions, ranging from concrete extensions of the current framework to paradigm-shifting conjectures about the computability of spectral sequence differentials. All directions share the unifying theme: **derived homological structure, traditionally defined through abstract existence arguments, may be algorithmically accessible through certified integer linear algebra**.

The directions below are ordered by increasing ambition, from solid extensions building on existing catalog theorems to grand-challenge conjectures.

---

## Direction 1: Multi-Step Filtration and Spectral Sequence Differentials

**Conjecture:** For an *n*-step filtration of a chain complex of free ℤ-modules, the *E₂*-page differentials of the associated spectral sequence can be computed from at most *O*(*n*²) SNF computations, with each differential expressed as an explicit formula involving SNF diagonal entries and basis-change matrices.

**Test:** Construct explicit 3-step and 4-step filtrations (e.g., skeletal filtrations of CW-complexes with nontrivial cell structure). Compute the *E₂* differentials both abstractly (via the spectral sequence definition) and algorithmically (via iterated SNF). Verify agreement on ≥10 examples with total rank ≤ 20.

**Possible failure mode:** The *E₂* differentials may require tracking *compositions* of connecting maps through multiple filtration layers, and the composition may not decompose into independent per-factor formulas. A single example where the SNF-based formula gives the wrong differential would falsify the conjecture.

**Impact:** If true, this would extend the "certified derived persistence" program from two-step to arbitrary filtrations, enabling fully algorithmic computation of spectral sequence pages.

**Catalog References:**
- `Catalog/Algebra/Homology/DerivedFunctors/LongExactSequence.lean` — long exact sequence machinery
- `Catalog/Algebra/Homology/DerivedFunctors/ExtTorBasic.lean` — Tor₁ computation as validation

**Proof Strategy:** Induction on filtration length, reducing each step to a two-step problem via the "octahedral axiom" in homological algebra.

**Domain Bridges:** Spectral sequences ↔ integer linear algebra ↔ computational topology

**Lineage:** Direct extension of `dTorsion_eq_zmultiples` and `algorithmic_obstruction_correct`.

**Ambition:** ★★★★☆ (Extension with significant new content)

---

## Direction 2: Lens-Space Rigidity via Torsion Obstruction Signatures

**Conjecture:** For the standard skeletal filtration of L(*p*, 1), the torsion obstruction signature σ(*p*) = (gcd(*p*, 2), gcd(*p*, 3), gcd(*p*, 4), …, gcd(*p*, *p*+1)) determines *p* uniquely. More precisely, σ(*p*₁) = σ(*p*₂) implies *p*₁ = *p*₂.

**Test:** Compute σ(*p*) for all *p* ∈ [2, 10000] and check for collisions. Currently verified for *p* ∈ [2, 100].

**Possible failure mode:** Two distinct primes *p*₁, *p*₂ with identical gcd profiles against all integers 2 through max(*p*₁, *p*₂) + 1. Since the signature contains gcd(*p*, *p*) = *p* as an entry, collisions can only occur if *p*₁ and *p*₂ differ but have identical gcd behavior against all smaller moduli — which would require them to have the same prime factorization structure. This seems unlikely but is not proved.

**Impact:** Would give a new, elementary classification of lens spaces L(*p*, 1) bypassing Reidemeister torsion and surgery theory. Could generalize to L(*p*, *q*) for *q* ≠ 1.

**Catalog References:**
- `Catalog/Pythagorean/SNFObstruction/Basic.lean` — `dTorsion_card`, `obstruction_determined_by_snf_diagonal`
- `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean` — `prime_selectivity`

**Proof Strategy:** Reduce to number theory: show that the multiset of gcd values determines the prime factorization of *p*.

**Domain Bridges:** Number theory ↔ topology ↔ certified linear algebra

**Lineage:** Built directly on `dTorsion_card` and computational validation.

**Ambition:** ★★★☆☆ (Concrete conjecture with clear test)

---

## Direction 3: Certified Derived Persistence over ℤ

**Conjecture (Grand Challenge):** There exists a polynomial-time algorithm that, given a filtered simplicial complex with *N* simplices and boundary matrices with entries bounded by *B*, computes the full torsion persistence barcode over ℤ (including birth-death pairs for all prime torsion) in *O*(*N*³ · log *B*) operations, with a machine-verified correctness certificate.

**Test:** Implement the algorithm for Rips complexes of point clouds with 20–50 points. Compare torsion barcodes against the field-coefficient barcodes to quantify the "torsion gap" — the amount of topological information lost by working over a field. Benchmark against existing ℤ-coefficient implementations (e.g., PHAT with ℤ coefficients, though these are rare).

**Possible failure mode:** The per-step SNF computation may interact badly with the persistence pairing, creating exponential blowup in entry sizes during reduction. The certified certificate may have superpolynomial size even when the computation is polynomial.

**Impact:** This would be a breakthrough for computational topology: the first certified, efficient, and complete persistence algorithm over ℤ. Current software (Ripser, GUDHI, Dionysus) works over fields and cannot detect torsion.

**Catalog References:**
- `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean` — `pTorPersistence_vanishes_of_free`, `exists_torsion_birth`
- `Catalog/Pythagorean/SNFObstruction/Basic.lean` — full SNF obstruction framework

**Proof Strategy:** Adapt the standard persistence algorithm (matrix reduction) to ℤ coefficients, using SNF at each step instead of column reduction over a field.

**Domain Bridges:** Persistent homology ↔ integer linear algebra ↔ topological data analysis ↔ materials science

**Lineage:** Combines torsion detection framework with SNF obstruction computation.

**Ambition:** ★★★★★ (Grand challenge / paradigm shift)

---

## Direction 4: Saturation-Stability Criterion

**Conjecture:** For a short exact sequence 0 → *A* → *B* → *C* → 0 of finitely generated free ℤ-modules with inclusion *i* : *A* → *B*, if the image *i*(*A*) is a *saturated* sublattice of *B* (i.e., *B*/*i*(*A*) is torsion-free), then the secondary torsion obstruction for any torsion order *n* vanishes.

**Test:**
1. Generate 1000 random pairs (*i* : ℤ^*k* → ℤ^*m*, *n*) with varying saturation indices.
2. Compute saturation index = lcm(invariant factors) / product(invariant factors).
3. Check correlation between saturation index = 1 and vanishing obstruction.

**Possible failure mode:** A saturated inclusion (all invariant factors = 1) trivially has gcd(1, *n*) = 1 for all *n*, so the conjecture is true in this case. The interesting question is whether *partial* saturation (some factors = 1) leads to partial vanishing, or whether there are edge cases where saturation is not captured by the invariant factors alone.

**Impact:** Would provide a fast pre-screening test for nontrivial torsion: check saturation before computing the full obstruction.

**Catalog References:**
- `Catalog/Pythagorean/SNFObstruction/Basic.lean` — `dTorsion_trivial_iff_coprime`

**Proof Strategy:** Direct from `dTorsion_trivial_iff_coprime`: saturated means all factors = 1, and Coprime(1, *n*) always holds.

**Domain Bridges:** Lattice theory ↔ homological algebra ↔ computational number theory

**Lineage:** Immediate consequence of `dTorsion_trivial_iff_coprime`.

**Ambition:** ★★☆☆☆ (Solid extension, essentially proved)

---

## Direction 5: Discrete Gauge Anomaly Detection via Torsion Obstructions

**Conjecture (Grand Challenge):** For a lattice gauge theory on a triangulated manifold with gauge group ℤ/*p*, the secondary torsion obstruction of the associated chain complex detects discrete gauge anomalies: the obstruction vanishes if and only if the gauge configuration extends consistently across the triangulation.

**Test:** Construct explicit triangulations of RP², the Klein bottle, and lens spaces L(*p*, 1). Define a "gauge field" as a 1-cocycle with values in ℤ/*p*. Compute the obstruction and check whether it equals the known anomaly (the second Stiefel-Whitney class for RP², the torsion class for lens spaces).

**Possible failure mode:** The relationship between the chain-level obstruction and the gauge-theoretic anomaly may require a cup product or Steenrod square computation that is not captured by the SNF connecting formula alone.

**Impact:** Would establish a formal bridge between certified algebraic computation and lattice gauge theory, with potential applications in condensed matter physics (topological insulators) and quantum error correction (homological codes).

**Catalog References:**
- `Catalog/Pythagorean/SNFObstruction/Basic.lean` — `dTorsion_invariant_under_auto` (gauge invariance)
- `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean` — `prime_selectivity` (anomaly at specific primes)

**Proof Strategy:** Identify the anomaly with the connecting class δ: H₁(M; ℤ/*p*) → H₀(∂M; ℤ), then use the SNF formula to compute δ explicitly.

**Domain Bridges:** Gauge theory ↔ homological algebra ↔ certified computation ↔ quantum error correction

**Lineage:** Extension of the automorphism invariance theorem to the gauge-theoretic setting.

**Ambition:** ★★★★★ (Grand challenge / paradigm shift)
