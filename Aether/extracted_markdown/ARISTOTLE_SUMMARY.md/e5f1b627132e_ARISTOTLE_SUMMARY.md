# Summary of changes for run 3790ec6e-24c1-49da-b934-496cb84a297c
## Completed: Probe Complexity of Finite Categories

### Formally Verified Mathematics (Lean 4)

Created two Lean files with **zero sorries** and all proofs machine-verified:

**`Pythagorean/ProbeComplexity/Defs.lean`** — Core definitions:
- `ProbeFamily` — a `Finset` of objects used to probe morphisms
- `ProbeFamily.IsSeparating` — the separation property
- `ProbeFamily.SeparatesPair` — pairwise separation
- `morphismProfile` — the profile map encoding how a morphism acts on probes
- `profileMap_injective` — injectivity of the profile map for separating families

**`Pythagorean/ProbeComplexity/Theorems.lean`** — Five main theorems:

1. **`probeComplexity_le_card`** (Extremal upper bound): Every finite category has probe complexity ≤ number of objects. Uses the total probe family and the Yoneda-style identity trick.

2. **`card_hom_le_profile_capacity`** (Information-theoretic lower bound): For a separating probe family P, `|Hom(X,Y)| ≤ ∏_{Z∈P} |Hom(Z,Y)|^|Hom(Z,X)|`. This is the key bridge to information theory — it shows probe complexity is bounded below by an entropy budget.

3. **`probeComplexity_pos_iff`** (Complete zero-complexity characterization): Probe complexity is positive iff distinct parallel morphisms exist. Combined with `probeComplexity_eq_zero_of_subsingleton_hom`, this gives a full characterization: thin categories (including discrete and poset categories) have complexity 0.

4. **`ProbeFamily.IsSeparating.supset`** and **`of_erase`** (Monotonicity and deletion): Structural properties enabling incremental optimization of probe families.

5. **`single_probe_capacity_bound`** (Singleton probe bound): Specialization of the capacity bound to a single probe object, giving `|Hom(X,Y)| ≤ |Hom(Z,Y)|^|Hom(Z,X)|`.

**Important note on the discrete category theorem:** The original task suggested that discrete categories have *maximal* probe complexity. This is mathematically false — in `Discrete α`, every hom-set has at most one element, so the empty family is vacuously separating and `probeComplexity = 0`. The formalization correctly identifies this and replaces it with the thin-category characterization theorem.

### Python Code

- **`demo.py`** — Demonstrates probe complexity computations across discrete categories, parallel arrows, cyclic monoids, and disjoint unions, with information-theoretic bound verification.
- **`algorithms.py`** — Implements `ExhaustiveProbeSearch` (exact, exponential time), `GreedyProbeSearch` (O(log P) approximation), `ProfileCapacityChecker`, and `DistinguishingSetAnalysis`.
- **`applications.py`** — Three real-world applications: state machine distinguishability, sensor network design, and protocol verification.

### Documentation

- **`ARTICLE.md`** — Popular science article: "How Many Questions Does It Take to Know a Mathematical Universe?" Explains probe complexity through network monitoring, sensor placement, and the information-theoretic viewpoint.
- **`RESEARCH_PAPER.md`** — Full research paper with abstract, five theorem statements with proof sketches, algorithm pseudocode with complexity analysis, computational experiments, and references.
- **`FUTURE_DIRECTIONS.md`** — Five research directions including subadditivity under products, probabilistic probe complexity (grand challenge), connected component characterization, tightness of bounds, and categorical dimension.
- **`PACKAGE.json`** — JSON data package bundling all deliverables for web templating.