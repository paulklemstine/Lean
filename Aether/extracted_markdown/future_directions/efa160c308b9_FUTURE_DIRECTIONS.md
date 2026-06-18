# Future Directions: Probe Complexity as Representable Dimension

## Synthesis

The results established in this cycle prove that **probe measurement complexity exactly determines representable dimension** for finite discrete categories. The key identity — `repDim(F) = measurementInvariant(P)` under probe separation — collapses three seemingly distinct invariants into one. This opens five concrete research directions: extending the equality to richer categories (thin categories, categories with parallel morphisms), establishing information-theoretic lower bounds via shattering, connecting to graph metric dimension, developing monotonicity results for nested probe families, and exploring the gap phenomenon in non-discrete settings. Each direction below is stated as a falsifiable conjecture with explicit computational tests, building directly on the formally verified theorems in `Pythagorean/ProbeComplexity/RepresentableDimension.lean` and `Pythagorean/ProbeComplexity/Theorems.lean`.

---

## Direction 1: Thin-Category Equality Hypothesis

**Conjecture:** For every finite thin category `C` (a finite poset viewed as a category) and probe family `P` with a functorial restriction map, if `P` separates the presheaf `F` in the sense that probe signatures are injective at every object, then

$$\operatorname{repDim}(F) = \mathrm{measurementInvariant}(P).$$

**Test:** Enumerate all posets on at most 5 elements. For each poset, define presheaves with fibers of size ≤ 4 and restriction maps given by order-preserving projections. Compute both invariants and check equality. A single counterexample refutes the conjecture.

**Impact:** If true, this would extend the Grand Challenge equality from discrete categories to the full class of skeletal thin categories, covering all finite partial orders, lattices, and directed graphs without parallel edges.

**Catalog References:**
- `Pythagorean/ProbeComplexity/RepresentableDimension.lean` — `grand_challenge_discrete`
- `Pythagorean/ProbeComplexity/Theorems.lean` — `probeComplexity_le_card`

**Proof Strategy:** Generalize the proof of `grand_challenge_discrete` by showing that functoriality of restriction maps preserves the injectivity argument. The key new ingredient is that in a thin category, composition is unique, so restriction along a path is well-defined. Use induction on the length of the longest chain in the poset.

**Domain Bridges:** Order theory, lattice theory, finite topology (Alexandrov spaces)

**Lineage:** Direct extension of `grand_challenge_discrete`

**Ambition:** 🟡 Moderate — requires handling non-trivial restriction maps but the structure is still relatively simple.

---

## Direction 2: Strict Gap Hypothesis for Non-Thin Categories

**Conjecture:** There exists a finite non-thin category `C` (with at least two parallel morphisms between some pair of objects) and a probe family `P` such that

$$\sup_F \operatorname{repDim}(F) < \mathrm{measurementInvariant}(P),$$

where the supremum ranges over all finite-valued `P`-separated presheaves.

**Test:** Construct the "parallel pair" category with two objects and two parallel morphisms. Define probe families and systematically enumerate presheaves with fibers of size ≤ 5. Compare the supremal representable dimension against the measurement invariant. A strict inequality confirms the conjecture.

**Impact:** This would establish that the Grand Challenge equality is **specific to thin categories** and identify the precise structural obstruction. It would delineate the boundary of the dimension theory.

**Catalog References:**
- `Pythagorean/ProbeComplexity/RepresentableDimension.lean` — `measurementInvariant_le_objectwiseTotalCard`
- `Pythagorean/ProbeComplexity/Defs.lean` — `ProbeFamily.IsSeparating`

**Proof Strategy:** In a category with parallel morphisms f, g: X → Y, the presheaf Hom(—, Y) has functorial restrictions that force constraints between fibers. These constraints reduce the effective representable dimension below the raw measurement count. Construct an explicit witness category and compute both invariants.

**Domain Bridges:** Homological algebra (parallel pairs appear in equalizer diagrams), database theory (functional dependencies)

**Lineage:** Complement to Direction 1

**Ambition:** 🟢 Achievable — explicit small-case computation should resolve this.

---

## Direction 3: Categorical Shattering and VC Dimension

**Conjecture:** Define the **categorical shattering number** `shatter(P)` as the maximum number of objects `Y` such that every subset of `F(Y)` can be separated by some probe sub-family. Then for all finite categories and probe families:

$$\mathrm{shatter}(P) \leq \sup_F \operatorname{repDim}(F) \leq \mathrm{measurementInvariant}(P).$$

**Test:** For discrete categories with ≤ 4 objects and presheaves with fibers of size ≤ 4, compute the shattering number, supremal representable dimension, and measurement invariant. Verify the chain of inequalities. A violation at any point refutes the conjecture.

**Impact:** This would establish the first **categorical analogue of VC dimension**, connecting learning theory to presheaf geometry. The shattering number would become a new complexity measure for finite categories, bridging combinatorial learning theory and categorical algebra.

**Catalog References:**
- `Pythagorean/ProbeComplexity/RepresentableDimension.lean` — `representableDimension_le_measurementInvariant`
- `Pythagorean/ProbeComplexity/Theorems.lean` — `card_hom_le_profile_capacity`

**Proof Strategy:** The upper bound is already proved (`representableDimension_le_measurementInvariant`). For the lower bound, construct a presheaf whose elements at shattered objects form a free module over the probe sub-families, forcing the representable dimension to be at least the shattering number.

**Domain Bridges:** Statistical learning theory (VC dimension, Rademacher complexity), combinatorics (set systems, Sauer-Shelah lemma)

**Lineage:** Extends the information-theoretic bounds in `card_hom_le_profile_capacity`

**Ambition:** 🔴 Grand Challenge — would open an entirely new field connecting categorical algebra and learning theory.

---

## Direction 4: Compression Stability Under Probe Enlargement

**Conjecture:** For nested probe families `P ⊆ P'` with compatible restriction maps, the measurement invariant is monotone:

$$\mathrm{measurementInvariant}(P) \leq \mathrm{measurementInvariant}(P')$$

and equality holds if and only if `P` already separates everything that `P'` separates.

**Test:** For discrete categories with ≤ 4 objects, enumerate all pairs `P ⊆ P'` and compute both measurement invariants. Verify monotonicity. Check the equality characterization. A single violation of monotonicity refutes the first part; a failure of the characterization refutes the second.

**Impact:** Establishes that adding probes never decreases measurement resolution (monotonicity) and characterizes when additional probes are redundant. This is the categorical analogue of the data processing inequality from information theory.

**Catalog References:**
- `Pythagorean/ProbeComplexity/RepresentableDimension.lean` — `measurementInvariant_eq_objectwiseTotalCard`
- `Pythagorean/ProbeComplexity/Theorems.lean` — `ProbeFamily.IsSeparating.supset`

**Proof Strategy:** For monotonicity, show that the probe signature map for `P'` refines that for `P`, so the image can only grow. For the characterization, use the equality theorem: if `P` already separates, adding probes doesn't change the image cardinalities.

**Domain Bridges:** Information theory (data processing inequality), signal processing (sampling theory), experimental design (sequential testing)

**Lineage:** Builds on `ProbeFamily.IsSeparating.supset` and `measurementInvariant_eq_objectwiseTotalCard`

**Ambition:** 🟢 Achievable — the monotonicity should follow directly from image-subset arguments.

---

## Direction 5: Presheaf Reconstruction from Measurement Data

**Conjecture:** For finite discrete categories with full probe families (P = all objects), the measurement signature type `MeasurementSignatureType P r Y` at each object carries a canonical presheaf structure, and this "measurement presheaf" is the universal presheaf separated by `P` — every other separated presheaf factors through it.

**Test:** For categories with ≤ 3 objects and fibers of size ≤ 4, construct the measurement presheaf explicitly and verify the universal property. Check that every separated presheaf admits a unique factoring natural transformation.

**Impact:** This would establish that probe signatures define not just an invariant but a **universal measurement presheaf** — the maximal object that probes can detect. This is analogous to the spectrum of a commutative ring or the Stone space of a Boolean algebra: a canonical geometric object extracted from algebraic/measurement data.

**Catalog References:**
- `Pythagorean/ProbeComplexity/RepresentableDimension.lean` — `MeasurementSignatureType`, `card_measurementSignatureType_eq`
- `Pythagorean/ProbeComplexity/Defs.lean` — `morphismProfile`

**Proof Strategy:** Define the measurement presheaf as `Y ↦ MeasurementSignatureType P r Y` with restriction maps induced by composition of probe signatures. Show that any separated presheaf `F` admits a natural transformation `F → MeasPresh` that is injective objectwise (by separation) and that this transformation is essentially unique.

**Domain Bridges:** Algebraic geometry (spectrum construction), topology (Stone duality), signal processing (compressed sensing — measurement matrices define reconstruction spaces)

**Lineage:** Direct continuation of `MeasurementSignatureType` and `card_measurementSignatureType_eq`

**Ambition:** 🔴 Grand Challenge — would establish probe signatures as a new foundation for presheaf reconstruction theory.
