# Future Directions: Topos-Level Compression Invariant

## Synthesis

The topos compression invariant κ opens a new axis of geometric complexity measurement: the efficiency of observation. The five theorems established here — existence, transport, invariance, dimension comparison, and observation complexity — form a complete foundation for this theory in the finite discrete setting. The natural next steps extend along three axes: (1) enriching the categorical structure (non-discrete sites, infinite topoi), (2) sharpening the invariant with computational and algebraic tools, and (3) bridging to other domains (VC dimension, coding theory, topological data analysis). Each direction below is falsifiable and computationally testable.

---

## Direction 1: Compression Additivity Under Products

**Conjecture:** For finite presheaf models (Ob₁, F₁, r₁) and (Ob₂, F₂, r₂), the product model satisfies:
```
κ(F₁ × F₂) = κ(F₁) + κ(F₂)
```
where the product model has objects Ob₁ × Ob₂ and fibers F₁(Y₁) × F₂(Y₂) with componentwise restriction.

**Test:** Enumerate all presheaf models on ≤ 3 objects with fibers of size ≤ 3. For each pair, compute κ of the product and compare to κ₁ + κ₂. A single strict inequality refutes additivity. Sub-additivity (κ(F₁ × F₂) ≤ κ(F₁) + κ(F₂)) is expected to hold unconditionally and should be proved first.

**Impact:** Additivity would make κ a *valuation* on presheaf models, analogous to dimension of manifolds. This would place compression in the same structural class as Euler characteristic and topological dimension.

**Catalog References:**
- `Pythagorean/ProbeComplexity/Defs.lean` (probe family definition)
- `Pythagorean/ProbeComplexity/ToposCompressionInvariant.lean` (transport theorem)

**Proof Strategy:** For sub-additivity, project an optimal product-family onto components. For super-additivity (if true), construct a product element distinguishable only by combining information from both factors.

**Domain Bridges:** Dimension theory, information theory (capacity of product channels), tensor product structure.

**Lineage:** Extends Theorem C (Morita invariance) to categorical products.

**Ambition:** ★★★★ (High — additivity of complexity measures is rare and would be a significant structural result.)

---

## Direction 2: Sharp Representable Dimension Bound

**Conjecture:** For all finite presheaf models with non-trivial fibers (|F(Y)| ≥ 2 for all Y):
```
κ(F, r) ≤ ⌈|Ob| / max_Y |F(Y)|⌉ + 1
```

In particular, when all fibers have the same size s ≥ 2, we conjecture κ ≤ ⌈|Ob|/s⌉ + 1. The "+1" may be removable for specific classes of restriction maps.

**Test:** Generate all models on ≤ 5 objects with uniform fiber size s ∈ {2, 3, 4} and identity restriction maps. Compute κ for each and check the bound. A violation refutes the conjecture.

**Impact:** This would turn the crude bound κ ≤ |Ob| into a tight parametric bound, making κ efficiently estimable without search.

**Catalog References:**
- `Pythagorean/ProbeComplexity/RepresentableDimension.lean` (repDim definition)
- `Pythagorean/ProbeComplexity/ToposCompressionInvariant.lean` (Theorem D)

**Proof Strategy:** Use probabilistic arguments: a random probe family of size k separates with high probability when k · log(s) ≥ log(|F(Y)|) for all Y. This gives a probabilistic upper bound; derandomize for the deterministic claim.

**Domain Bridges:** Probabilistic method in combinatorics, coding theory (sphere-packing bounds).

**Lineage:** Sharpens Theorem D (κ ≤ repDim).

**Ambition:** ★★★ (Moderate — bounds of this type are common in combinatorics but connecting to categorical structure adds novelty.)

---

## Direction 3: Extension to Non-Discrete Sites (Grand Challenge)

**Conjecture:** The compression number can be defined for presheaves on a (non-discrete) finite category C by using the full Yoneda-style separation: a probe family P separates if for all X, Y and parallel morphisms f, g : X → Y, the restrictions along probes distinguish f from g. The resulting κ(C) is a Morita-invariant of C.

**Test:** Implement the non-discrete version for small categories (≤ 4 objects, ≤ 8 morphisms). Compute κ for pairs of Morita-equivalent categories (e.g., a category and its Karoubi envelope) and check equality.

**Impact:** This would extend the invariant from discrete models to genuine categorical structures, making contact with the original probe complexity theory of the catalog.

**Catalog References:**
- `Pythagorean/ProbeComplexity/Defs.lean` (morphism-level IsSeparating)
- `Pythagorean/ProbeComplexity/Theorems.lean` (probeComplexity definition)
- `Bridges/Catalog/Pythagorean/ProbeComplexity/SheafCompressionFiniteSite.lean` (sheaf compression)

**Proof Strategy:** Define CompressionEquiv for non-discrete categories using functors instead of bijections. Transport of separation follows from the functoriality of composition. The main challenge is ensuring the compatibility condition handles morphism composition correctly.

**Domain Bridges:** Category theory (Morita theory), algebraic geometry (site presentations), topos theory.

**Lineage:** Generalizes Theorems B and C from discrete to non-discrete sites.

**Ambition:** ★★★★★ (Grand challenge — this is the gateway to genuine topos-level invariants.)

---

## Direction 4: Compression and VC Dimension

**Conjecture:** For a presheaf model (Ob, F, r) where F(Y) ⊆ 2^S for some finite set S (i.e., fibers are sets of subsets), the compression number κ is bounded below by the VC dimension of the induced set system:
```
VCdim({F(Y) : Y ∈ Ob}) ≤ κ(F, r)
```

**Test:** Construct set systems with known VC dimension d ∈ {1, 2, 3, 4} and embed them as presheaf models. Compute κ and check the bound. A counterexample would refute the conjecture.

**Impact:** This would formally connect the topos compression invariant to one of the most important quantities in machine learning theory, establishing a bridge between categorical geometry and statistical learning theory.

**Catalog References:**
- `Pythagorean/ProbeComplexity/ToposCompressionInvariant.lean` (Theorem E, observation complexity)

**Proof Strategy:** Show that VC-shattering implies non-separability by small probe families. If a set system shatters a set of size d, then at least d probes are needed to distinguish all shattered subsets.

**Domain Bridges:** Machine learning (VC theory), computational geometry, PAC learning.

**Lineage:** Extends Theorem E (observation complexity bound) to VC-theoretic setting.

**Ambition:** ★★★★ (High — connecting category theory to learning theory is novel and impactful.)

---

## Direction 5: Compression Spectrum Structure

**Conjecture:** The compression spectrum CompSpec(F, r) = {n : ∃ P, |P| = n and P separates} is always an "upward-closed interval": if n ∈ CompSpec and m > n, then m ∈ CompSpec. Equivalently, CompSpec = {κ, κ+1, ..., |Ob|}.

**Test:** Enumerate all models on ≤ 5 objects and compute their spectra. A model with a "gap" (some k > κ not in the spectrum) refutes the conjecture.

**Impact:** If true, the spectrum is determined by the single number κ, vastly simplifying the theory. If false, the gap structure itself becomes an interesting invariant.

**Catalog References:**
- `Pythagorean/ProbeComplexity/ToposCompressionDefs.lean` (compressionSpectrum')
- `Pythagorean/ProbeComplexity/ToposCompressionInvariant.lean` (ProbeSeparates.mono)

**Proof Strategy:** Use the monotonicity theorem (supersets of separating families separate). If P of size k separates, then P ∪ {Z} of size k+1 separates. This gives upward closure immediately. The question is whether the spectrum has no gaps — i.e., whether P of size k separating implies some subfamily of size k-1 also separates (which is generally false, as some probes may be essential).

**Domain Bridges:** Matroid theory (if the spectrum has the augmentation property, the separating families form a matroid), combinatorial optimization.

**Lineage:** Extends the structural analysis of compression from Theorems A and B.

**Ambition:** ★★ (Moderate — the upward closure is easy to prove; the no-gap property is the interesting part and is likely false, which would itself be informative.)
