# Future Directions: Adelic Persistent Homology

## Synthesis

The adelic torsion persistence framework established here — decomposing the torsion barcode of filtered finite abelian groups by prime, packaging this into an adelic datum with finite support, and proving exact reconstruction — opens a genuinely new interface between arithmetic, algebra, and topological data analysis. The theorems proved (functoriality of p-primary persistence, adelic reconstruction, bounded support criterion, CRT persistence splitting) form the foundation of **arithmetic persistent homology**: the study of topological evolution through the lens of local-global number-theoretic decomposition.

The directions below range from incremental extensions (strengthening existing theorems to richer settings) to paradigm-shifting conjectures (persistence zeta functions, adelic sheaves on Spec ℤ). Each is formulated as a testable hypothesis with a concrete falsification protocol, ensuring scientific rigor. Together, they chart a path from the current results toward a mature theory connecting TDA, arithmetic geometry, and representation theory.

---

## Direction 1: Persistence Zeta Function Multiplicativity

**Conjecture:** For filtered finite abelian groups F₁ and F₂ with coprime torsion exponents, the persistence zeta function Z(s) = ∏_p (1 + len(barcode_p) · p^{-s}) satisfies

Z(F₁ × F₂, s) = Z(F₁, s) · Z(F₂, s).

**Test:** Compute Z(s) on all products of filtrations with ≤ 5 levels over groups of order ≤ 120. Compare Z(product) with Z₁ · Z₂ for s ∈ {1, 2, 3}. Computational experiments (see `applications.py`) show multiplicativity holds when the two filtrations have coprime support, but can fail when supports overlap due to barcode length interaction.

**Impact:** If multiplicative, Z(s) would be a genuine arithmetic invariant of persistence modules with Euler-product structure, directly analogous to Dedekind zeta functions. This would establish the first formal connection between persistence theory and analytic number theory.

**Catalog References:** `Pythagorean/AdelicPersistentHomology.lean` — `persistence_zeta` definition (Python), `bounded_torsion_implies_bounded_primeSupport`.

**Proof Strategy:** Prove multiplicativity for filtrations with coprime support using the CRT persistence theorem (`persistence_CRT_decomposition`). The coprime-support case should follow from independence of prime barcodes. For the general case, investigate correction terms from barcode interaction at shared primes.

**Domain Bridges:** Analytic number theory ↔ topological data analysis. The Euler product for ζ(s) is the classical prototype; persistence zeta is its TDA analogue.

**Lineage:** Extends `persistence_CRT_decomposition` and `adelic_reconstruction_correct_set`.

**Ambition:** Grand challenge — if true in generality, opens an entire field.

---

## Direction 2: Adelic Sheaf on Spec ℤ

**Conjecture:** The adelic torsion datum of a persistence module defines a constructible sheaf on Spec ℤ whose stalks at the generic point and at each closed point (p) record, respectively, the free part and the p-primary persistence barcode.

**Test:** Formalize the sheaf condition: for any open set U ⊆ Spec ℤ (complement of finitely many primes), the sections over U are determined by the local data at primes in U. Verify this for filtrations of groups of order ≤ 60. A failure would manifest as non-uniqueness of global sections given local data.

**Impact:** This would embed persistence theory into the framework of arithmetic geometry, making persistent homology computable via sheaf-cohomological methods. It provides a rigorous foundation for the analogy between "persistence over local fields" and classical algebraic geometry.

**Catalog References:** `Pythagorean/AdelicPersistentHomology.lean` — `AdelicTorsionDatum`, `adelic_extensionality`, `reconstructTorsionSupport`.

**Proof Strategy:** Define the presheaf by assigning to each open U the set of adelic data restricted to primes outside U. Use `adelic_extensionality` (which shows that local supports determine global reconstruction uniquely) to establish the sheaf gluing condition. The key lemma is that `reconstructTorsionSupport` factors through the sheaf structure.

**Domain Bridges:** Arithmetic geometry ↔ persistent homology ↔ sheaf theory.

**Lineage:** Direct extension of `adelic_extensionality` and `same_local_same_global`.

**Ambition:** Grand challenge — paradigm shift connecting TDA to algebraic geometry.

---

## Direction 3: Prime-Multiplicity Barcodes

**Conjecture:** For a filtered finite abelian group F, the adelic torsion datum determines not only which primes are active at each level (the support), but also the **multiplicities** of each prime in the group structure (i.e., the exact p-primary ranks and invariant factors), giving a complete "arithmetic barcode" up to isomorphism.

**Test:** For filtrations of groups Z/p^a × Z/p^b (e.g., Z/4 × Z/4 vs Z/2 × Z/8, both of order 16), check whether the adelic support data distinguishes them. If both give the same support {2} at all levels but different invariant factors, the conjecture is false at the support level and requires enrichment.

**Impact:** A positive result would mean the adelic framework captures the full isomorphism type of torsion persistence, not just its support. A negative result (likely) would identify exactly what additional data is needed, guiding the definition of enriched adelic objects.

**Catalog References:** `Pythagorean/AdelicPersistentHomology.lean` — `pPrimaryNontrivial`, `torsionPrimeSupportSet`.

**Proof Strategy:** The support-level conjecture is almost certainly false for non-cyclic groups (Z/4 and Z/2² have the same 2-primary support but different structures). Enrich `AdelicTorsionDatum` to record p-adic valuations or invariant factor sequences at each prime and level. Prove the enriched version using the structure theorem for finitely generated abelian groups.

**Domain Bridges:** Algebra (structure theorem for f.g. abelian groups) ↔ persistence theory ↔ p-adic analysis.

**Lineage:** Builds on `pPrimaryComponent` and `catalog_connection`.

**Ambition:** Solid extension — enriches the existing framework with strictly more information.

---

## Direction 4: CRT Persistence for Non-Abelian Groups

**Conjecture:** For a filtered group G (not necessarily abelian) whose abelianization has coprime torsion decomposition, the H₁-persistence module (with integer coefficients) splits by CRT in a way compatible with the abelianization map.

**Test:** Construct explicit filtrations of non-abelian groups (e.g., dihedral groups D_n, symmetric groups S_n) and compute whether the CRT splitting of H₁ = G^{ab} lifts to a persistence-compatible decomposition. Concretely, test on D₆ (abelianization Z/2 × Z/2) and S₃ (abelianization Z/2).

**Impact:** Extends adelic persistence from abelian groups to the non-abelian setting via abelianization, connecting to the results in `ArithmeticPhaseClassification.lean`. This would bring the entire theory of arithmetic phase visibility under the adelic umbrella.

**Catalog References:** `Catalog/Pythagorean/ArithmeticPhaseClassification.lean` — `primePhaseVisible_iff_hasPTorsion_abelianization`, `arithmeticPhaseProfile_eq_of_abelianization_equiv`.

**Proof Strategy:** Use `primePhaseVisible_iff_hasPTorsion_abelianization` to reduce the non-abelian case to the abelian case. Apply `persistence_CRT_decomposition` to the abelianization, then lift via naturality of the abelianization map. The key technical challenge is showing that the CRT decomposition commutes with the abelianization functor.

**Domain Bridges:** Group theory ↔ homological algebra ↔ persistence theory.

**Lineage:** Combines `CRT_persistence_functorial` with `primePhaseVisible_iff_hasPTorsion_abelianization`.

**Ambition:** Solid extension — the abelianization machinery is already in the catalog.

---

## Direction 5: Computational Complexity of Adelic Reconstruction

**Conjecture:** The adelic torsion datum of a filtration of length n with groups of maximum order M can be computed in time O(n · √M), and the reconstruction map runs in time O(n · log M). The bottleneck is prime factorization of group orders.

**Test:** Benchmark the algorithms in `algorithms.py` on filtrations with n up to 1000 and M up to 10^6. Measure wall-clock time and compare with the theoretical bounds. Test whether the persistence zeta function can be evaluated in O(log M) time for pre-computed barcodes.

**Impact:** Establishes that adelic persistent homology is computationally practical for real-world TDA applications, not just a theoretical framework. Sub-linear reconstruction time (in M) would make it competitive with existing persistence algorithms.

**Catalog References:** `Pythagorean/AdelicPersistentHomology.lean` — `torsionPrimeSupportSet_finite`, `finite_filtration_has_bounded_primeSupport`.

**Proof Strategy:** The finiteness proof (`torsionPrimeSupportSet_finite`) shows that prime support is bounded by prime factors of the group order, giving O(log M) primes. Reconstruction is then O(n · log M). For computation, leverage number-theoretic sieves for efficient prime factorization.

**Domain Bridges:** Computational complexity ↔ number theory ↔ TDA algorithms.

**Lineage:** Builds on `torsionPrimeSupportSet_finite` and `bounded_torsion_implies_bounded_primeSupport`.

**Ambition:** Solid extension — important for practical adoption.
