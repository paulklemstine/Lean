# Future Directions: Primewise Persistence and Beyond

## Synthesis

The max-envelope stability theorem for derived persistence invariants opens a new axis of investigation in topological data analysis: the *arithmetic axis*. Classical TDA treats filtrations as continuous families of spaces and studies their topology over a field. Our work shows that working over ℤ introduces independent prime channels, each carrying its own persistence signal, with the global signal reconstructed by a sup-envelope law. The strictness phenomenon — the fact that this reconstruction loses information — identifies the precise boundary of the local-global principle in this setting.

The five directions below form a coherent research program. Directions 1-2 deepen the mathematical theory by extending the max-envelope law to richer invariants and connecting it to spectral sequences. Direction 3 bridges to applied TDA with concrete algorithms. Direction 4 connects to algebraic K-theory and opens a new interface between persistence and arithmetic geometry. Direction 5 is a grand challenge: proving a full algebraic stability theorem for integer persistence with primewise decomposition.

All directions build directly on the formal infrastructure developed here and reference specific catalog theorems.

---

## Direction 1: Max-Envelope Law for Persistence Landscapes

**Conjecture:** The max-envelope stability bound extends from Betti curves to persistence landscapes. For prime-indexed persistence landscape families {Λ_p}, the global landscape Λ = sup_p Λ_p satisfies:

```
‖Λ_M - Λ_N‖_∞ ≤ sup_p ‖Λ_{M,p} - Λ_{N,p}‖_∞
```

**The key insight is** that persistence landscapes are defined as suprema of tent functions over persistence intervals, and this supremum operation commutes with the primewise supremum, enabling the same Lipschitz argument used for Betti curves.

**Why now?** The `natDist_sup'_le_sup'_natDist` lemma provides the exact analytic core needed. Landscapes are pointwise suprema, and our framework handles arbitrary sup-envelope invariants via `PrimewiseDerivedInvariant`.

**Test:** Implement primewise landscape computation in Python, generate 1000 random interval-decomposable modules with 3-5 primes, and check whether the landscape L∞ distance satisfies the bound. Measure the gap distribution.

**Impact:** Would establish the max-envelope law as a universal principle for all functional persistence summaries, not just Betti curves.

**Catalog References:** `betti_envelope_pointwise`, `derived_invariant_pointwise_stability`, `natDist_sup'_le_sup'_natDist` in `Pythagorean/DerivedPersistence/PrimewiseCompleteness.lean`.

**Proof Strategy:** Define a `PrimewiseLandscapeProfile` structure where each prime contributes a landscape function. Show the global landscape is the sup-envelope. Apply `derived_invariant_pointwise_stability`.

**Domain Bridges:** Applied TDA (landscapes are the most popular functional summary), statistical inference (landscape means and confidence bands).

**Lineage:** Direct extension of `betti_envelope_pointwise`.

**Ambition:** Solid extension — high confidence of success within one research cycle.

---

## Direction 2: Spectral Sequence Primewise Splitting

**Conjecture:** If a filtered chain complex over ℤ has pagewise p-primary splitting compatible with differentials, then the persistence summary at the abutment satisfies the max-envelope stability bound.

Formally: let (E_r, d_r) be a spectral sequence converging to H*(X). If each page E_r decomposes as ⊕_p E_r^(p) with d_r respecting the decomposition, then:

```
d_∞(H*(X), H*(Y)) ≤ sup_p d_∞(H_p*(X), H_p*(Y))
```

**The key insight is** that spectral sequences are iterated derived functors, and the p-primary decomposition (being a direct sum decomposition of abelian groups) commutes with taking homology. If the differentials respect the decomposition, so does every page, and hence the abutment.

**Why now?** The catalog's `DerivedPersistence/Basic.lean` already formalizes secondary torsion obstructions in short exact sequences. Spectral sequences are the natural generalization: a SES is a spectral sequence that degenerates at E_2.

**Test:** Construct explicit spectral sequences for small filtered complexes (e.g., CW-complexes with 2-3 cells per dimension) and verify the bound computationally.

**Impact:** Would connect persistence theory to the most powerful computational tool in homological algebra, enabling new methods for computing persistent homology of filtered spaces.

**Catalog References:** `surj_maps_torsion_surj`, `split_implies_no_secondary_obstruction` and `torsion_seq_exact_at_middle` in `Catalog/Pythagorean/DerivedPersistence/Basic.lean`.

**Proof Strategy:** Formalize a toy spectral sequence (E_2 page only). Prove the p-primary splitting commutes with d_2. Deduce the max-envelope bound at E_∞. Generalize by induction on page number.

**Domain Bridges:** Homological algebra (spectral sequences), algebraic topology (Serre spectral sequence), algebraic geometry (Leray spectral sequence).

**Lineage:** Extends `derived_invariant_pointwise_stability` from single-level invariants to multi-level spectral filtrations.

**Ambition:** Grand challenge — requires substantial new infrastructure but would be a breakthrough.

---

## Direction 3: Computational Prime-Resolved TDA

**Conjecture:** For point cloud data with integer-valued distance matrices, prime-resolved persistence reveals structural features invisible to real-coefficient persistence.

**The key insight is** that integer distances naturally carry arithmetic information (divisibility, p-adic structure) that is erased by working over ℝ. The primewise decomposition recovers this information as independent channels, each potentially carrying distinct topological signal.

**Why now?** The algorithms in `algorithms.py` provide a working implementation. The formal correctness theorems (`global_dist_le_primewiseDerivedUpperBound`) certify the output. What's needed is application to real datasets.

**Test:** Apply prime-resolved persistence to:
1. Molecular weight datasets (divisibility by 2, 3, 5 captures molecular families)
2. Lattice data (where integer distances are exact)
3. Sensor network coverage (where integer thresholds define connectivity)

Measure whether primewise channels capture features that the global persistence diagram misses.

**Impact:** Would establish arithmetic TDA as a practical tool, not just a theoretical framework.

**Catalog References:** `primewiseDerivedUpperBound`, `finite_prime_derived_envelope_suffices` in `PrimewiseCompleteness.lean`.

**Proof Strategy:** No formal proof needed; this is an empirical direction. The formal infrastructure provides certified bounds for any implementation.

**Domain Bridges:** Materials science, computational chemistry, sensor networks, network science.

**Lineage:** Applies `global_dist_le_primewiseDerivedUpperBound` to real computation.

**Ambition:** Solid extension — directly implementable with existing tools.

---

## Direction 4: K-Theoretic Torsion Profiles

**Conjecture:** The primewise torsion profile of a persistence module defines an element of a K-theoretic group, and the max-envelope distance descends to a metric on K₀.

Specifically: define K₀^tors(R) as the Grothendieck group of finitely generated torsion R-modules modulo exact sequences. The primewise Betti profile is an invariant of the K₀-class, and the max-envelope distance is well-defined on K₀-classes.

**The key insight is** that the max-envelope law depends only on the sup-envelope structure, not on the specific module representatives. If two modules have the same primewise Betti profile (same K₀ class), they have the same global Betti curve. This means the distance descends to the quotient.

**Why now?** The `PrimewiseDerivedInvariant` structure abstracts exactly the properties needed: a local-to-global sup-envelope with vanishing outside a finite support. This is precisely a finitely-supported function on primes — an element of ⊕_p ℕ, which is the free part of K₀(ℤ).

**Test:** Compute K₀ classes for small persistence modules (e.g., cyclic groups ℤ/nℤ with n ≤ 100). Verify that the max-envelope distance is well-defined on classes. Check whether the K₀ metric refines the bottleneck distance.

**Impact:** Would create a new bridge between persistence theory and algebraic K-theory, potentially enabling K-theoretic methods for stability analysis.

**Catalog References:** `PrimewiseDerivedInvariant`, `PrimewiseBettiProfile.toDerivedInvariant` in `PrimewiseCompleteness.lean`.

**Proof Strategy:** Define K₀^tors formally. Show the primewise Betti profile is an invariant of the K₀ class (using the SES torsion rank bound). Define the max-envelope metric on K₀ and verify it satisfies the triangle inequality.

**Domain Bridges:** Algebraic K-theory, arithmetic geometry (zeta functions, local-global principles), representation theory.

**Lineage:** Extends `surj_maps_torsion_surj` from individual homomorphisms to K-theoretic equivalence classes.

**Ambition:** Grand challenge — requires new K-theoretic infrastructure but would be paradigm-shifting.

---

## Direction 5: Full Algebraic Stability for Integer Persistence

**Conjecture:** For finitely generated persistence modules over ℤ with interval-decomposable p-primary parts, the bottleneck distance on persistence diagrams satisfies:

```
d_B(dgm(M), dgm(N)) ≤ sup_p d_B(dgm_p(M), dgm_p(N))
```

where dgm_p denotes the p-primary persistence diagram.

**The key insight is** that a matching on the global diagram should decompose into primewise matchings by restricting to p-primary intervals. Conversely, optimal primewise matchings should reassemble into a global matching whose cost is the supremum of primewise costs. This is the matching-theoretic analogue of the max-envelope principle.

**Why now?** The Betti curve version (`betti_envelope_pointwise`) is proven. The strictness result (`exists_strict_betti_gap`) shows the bound is not always tight, identifying the exact obstruction. The matching decomposition strategy (Strategy A in the assignment) is now concretely informed by the functional-analytic results.

**Test:** Implement persistence diagram computation for small integer persistence modules. Compute bottleneck distances globally and primewise. Check the bound on 10,000 random instances. If counterexamples exist, characterize the obstruction.

**Impact:** Would establish the definitive algebraic stability theorem for integer persistence, completing the program initiated by the birth-set envelope theorems.

**Catalog References:** `finite_prime_envelope_suffices'` in `Catalog/Pythagorean/MaxEnvelopeStability.lean`, `betti_envelope_pointwise` and `exists_strict_betti_gap` in `PrimewiseCompleteness.lean`.

**Proof Strategy:** (Strategy A) Define global torsion persistence diagrams as finite multisets of (birth, death, prime) triples. Define admissible matchings. Prove that global matchings restrict to primewise matchings. Prove that primewise matchings reassemble. Deduce the bottleneck bound via a calc chain.

**Domain Bridges:** Algebraic topology (persistence diagrams), metric geometry (bottleneck and Wasserstein distances), optimization (matching theory).

**Lineage:** Direct generalization of `finite_prime_envelope_suffices'` from birth sets to full diagrams.

**Ambition:** Grand challenge — this is the flagship theorem of the entire research program.
