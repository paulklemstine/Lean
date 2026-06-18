# Future Directions

## Synthesis

The categorical Helly principle established in this work — that local fiber bounds at the Helly radius |P|+1 force global bounds under probe separation — opens a rich research program at the interface of combinatorial Helly theory, categorical finite generation, and algorithmic property testing. The four theorems (monotonicity, the Helly bound, obstruction dichotomy, and upward closure) form a coherent framework, but each suggests deeper questions. The directions below are ordered by ambition: the first two are grand challenges that would reshape the field, while the remaining three are concrete extensions building directly on the established catalog.

All directions share a common thread: the tension between the *sharpness* of the Helly number |P|+1 and the *structure* of obstructions to global generation. Resolving this tension — through either tighter bounds or richer obstruction theory — is the central open problem.

---

## Direction 1: Sharp Helly Bound Conjecture

**Conjecture:** For every finite type Ob, separating probe family P, and presheaf F, the Helly number for representable finite generation is exactly |P| + 1. That is, there exist presheaves where local bounds at radius |P| fail to imply global bounds, but bounds at radius |P| + 1 always suffice.

**Test:** Exhaustive search over all presheaves on types with |Ob| ≤ 6 and probe families with |P| ≤ 3. For each (Ob, P, F), check whether LocallyRepFinGen(F, |P|, n) ∧ ¬LocallyRepFinGen(F, |P|+1, n) for some n. If no such example exists, the Helly number may be reducible; if examples abound, sharpness is supported.

**Impact:** A proof of sharpness would be a precise categorical analogue of the classical Helly theorem (where d+1 is sharp in ℝ^d). A counterexample would identify a structural reason why categories are "simpler" than convex geometry.

**Catalog References:**
- `Pythagorean/ProbeComplexity/HellyLocality.lean` — `repFinGen_of_local_on_probe_closed`
- `Catalog/Pythagorean/ProbeComplexity/Theorems.lean` — `probeComplexity_le_card`

**Proof Strategy:** For sharpness, construct a presheaf where one fiber is maximally large (equal to probe capacity n^|P|) but evenly distributed across |P| probes, so that any |P|-element window misses one probe and cannot detect the large fiber. For non-sharpness, use the structure of the separation condition to show redundancy.

**Domain Bridges:** Classical Helly theory (convex geometry), Radon partition theory, matroid theory (exchange axioms).

**Lineage:** Directly extends the main Helly theorem (Theorem B) of this work.

**Ambition:** Grand challenge — would settle the central quantitative question of the theory.

---

## Direction 2: Nerve Realizability and Topological Helly Theory

**Conjecture:** Minimal bad subsets of a presheaf F correspond to non-trivial cycles in the nerve of the probe-adapted cover. Specifically, the nerve complex N(P, F) — whose simplices are subsets S with totalFiberCard(F, S) ≤ n — has the same homotopy type as a wedge of spheres, and each missing top-dimensional simplex corresponds to a minimal bad subset.

**Test:** For presheaves on |Ob| ≤ 6 with |P| ≤ 3, compute the nerve complex, its homology groups, and the minimal bad subsets. Check whether the number of minimal bad subsets equals the rank of the top homology group.

**Impact:** Would establish a deep connection between categorical Helly theory and algebraic topology, potentially yielding topological lower bounds on the number of obstructions.

**Catalog References:**
- `Pythagorean/ProbeComplexity/HellyLocality.lean` — `exists_minimal_bad_or_globally_bounded`, `badSubcategories_upward_closed`

**Proof Strategy:** Model the good subsets as an abstract simplicial complex (downward closed by Corollary 3.9). Apply the nerve theorem to relate this complex to the topology of probe neighborhoods. Use persistent homology to track how the complex changes with the threshold n.

**Domain Bridges:** Algebraic topology (nerve theorem, Čech homology), persistent homology, topological combinatorics.

**Lineage:** Extends Theorem D (upward closure) and the obstruction dichotomy (Theorem C).

**Ambition:** Grand challenge — would create a new bridge between category theory and computational topology.

---

## Direction 3: Quantitative Obstruction Bounds

**Conjecture:** Every minimal bad subset S for a presheaf F separated by P satisfies |S| ≤ |P| + 1. That is, the Helly number also bounds the size of minimal obstructions.

**Test:** Enumerate minimal bad subsets for all presheaves on |Ob| ≤ 6, |P| ≤ 3, and all thresholds. Record max(|S|) across all minimal bad subsets and compare with |P| + 1.

**Impact:** Would show that obstructions to global generation are always small and localized, enabling efficient search for counterexamples.

**Catalog References:**
- `Pythagorean/ProbeComplexity/HellyLocality.lean` — `IsMinimalBadSubset`, `IsMinimalBadSubset.removal_good`

**Proof Strategy:** By contradiction. If |S| > |P| + 1, then S contains a subset T of size |P| + 1 that includes P. By the local bound, totalFiberCard(F, T) ≤ n, but S is bad, so some element of S \ T must contribute enough fiber cardinality to push the total over n. But then {element} ∪ (S ∩ P) might be a smaller bad subset, contradicting minimality.

**Domain Bridges:** Ramsey theory, extremal set theory, matroids.

**Lineage:** Directly extends Theorem C (obstruction dichotomy).

**Ambition:** Solid extension — a concrete conjecture with a clear proof strategy.

---

## Direction 4: Non-Discrete Categories and Morphism-Level Helly Theory

**Conjecture:** The Helly principle extends to presheaves on non-discrete finite categories, with the Helly number depending on probe complexity (the minimum separating probe family size from `Catalog/Pythagorean/ProbeComplexity/Theorems.lean`).

**Test:** Define full subcategory restriction for the morphism-level probe family (from `ProbeComplexity.Defs`). Formalize "local representable finite generation" for functors Cᵒᵖ ⥤ Type and test on small non-discrete categories (e.g., the walking arrow, the commutative triangle).

**Impact:** Would generalize the theory from type families to genuine categorical presheaves, opening applications to algebraic geometry and homological algebra.

**Catalog References:**
- `Catalog/Pythagorean/ProbeComplexity/Defs.lean` — `ProbeFamily`, `ProbeFamily.IsSeparating`
- `Catalog/Pythagorean/ProbeComplexity/Theorems.lean` — `probeComplexity_le_card`, `profileMap_injective`

**Proof Strategy:** Reduce to the discrete case by showing that the key step — fiber-capacity inequality — depends only on injectivity of the profile map, which is available in the non-discrete setting via `profileMap_injective`. The remaining steps (summing over objects) are analogous.

**Domain Bridges:** Category theory (representable functors), algebraic geometry (quasi-coherent sheaves), homological algebra (finitely generated modules).

**Lineage:** Extends all four theorems from type families to categorical presheaves.

**Ambition:** Solid extension — natural generalization with a clear path.

---

## Direction 5: Algorithmic Complexity of Helly Testing

**Conjecture:** For fixed probe size |P| = k, the problem "is F globally representably finitely generated with bound n?" is decidable in time O(|Ob|^{k+1} · max|F(Y)|) via the ExhaustiveLocalCheck algorithm, and this is optimal up to polynomial factors.

**Test:** Benchmark the ExhaustiveLocalCheck algorithm on random presheaves with |Ob| up to 20 and |P| up to 4. Compare runtime with the trivial O(|Ob| · max|F(Y)|) global computation. Construct worst-case instances to test lower bound tightness.

**Impact:** Would establish the computational complexity of finite generation testing, with implications for database verification, constraint satisfaction, and network monitoring.

**Catalog References:**
- `Pythagorean/ProbeComplexity/HellyLocality.lean` — `locallyRepFinGen_of_all_subsets_good`, `all_subsets_good_of_locallyRepFinGen`

**Proof Strategy:** The upper bound follows from the algorithm. For the lower bound, construct presheaves where the only bad subset has size exactly k + 1, forcing the algorithm to enumerate all C(|Ob|, k+1) subsets.

**Domain Bridges:** Computational complexity (property testing), parameterized complexity (fixed-parameter tractability), database theory (view maintenance).

**Lineage:** Extends the algorithmic specifications (Algorithms 1–3 in the paper).

**Ambition:** Solid extension — connects the mathematical theory to computational practice.
