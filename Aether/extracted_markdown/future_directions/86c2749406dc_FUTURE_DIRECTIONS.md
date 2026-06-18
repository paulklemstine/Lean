# Future Directions: Torsion Barcode Stability

## Synthesis

The torsion birth set stability theorem establishes the first rigorous stability result for torsion invariants in persistent homology over ℤ. This opens a systematic research program along five axes: (1) extending birth stability to birth-death intervals, (2) upgrading from set-level Hausdorff bounds to multiset-level bottleneck bounds, (3) relaxing the injectivity condition on interleavings, (4) exploiting prime decomposition for finer stability constants, and (5) connecting torsion stability to applied domains via computable certificates. Each direction builds directly on the formalized infrastructure — the `TorsionBirthSet`, `NatSetDeltaClose`, `FaithfulDeltaInterleaving`, and the main `torsion_birthSet_deltaClose` theorem — and targets concrete, falsifiable predictions.

---

## Direction 1: Birth-Death Interval Stability (Grand Challenge)

**Conjecture**: For finite filtrations over ℤ, define a torsion death index as the filtration level where p-torsion disappears after being present. The resulting birth-death pair (b, d) is stable: under δ-interleaving, births shift by ≤ δ and deaths shift by ≤ δ.

**Test**: Construct filtrations of RP² and lens spaces L(p,q) with known torsion birth-death pairs. Verify computationally that δ-perturbations shift both endpoints by ≤ δ across 50+ examples with p ∈ {2, 3, 5} and δ ∈ {1, 2, 3, 4}.

**Impact**: This would establish a full "torsion barcode" theory with stability, analogous to classical barcodes but natively supporting torsion over ℤ. It would be the first complete stable persistence theory outside the field-coefficient regime.

**Catalog References**: `Pythagorean/TorsionBarcodeStability.lean` — `TorsionBirthSet`, `torsion_birthSet_deltaClose`, `torsionBirthSet_subsingleton`

**Proof Strategy**: Define `TorsionDeathSet(F, p)` as indices where p-torsion is last detected. Use backward transport (as in the birth stability proof) to bound death displacement. The subsingleton property may not hold for deaths; if not, a matching argument using well-ordering on both births and deaths is needed.

**Domain Bridges**: Topological data analysis, materials science (defect lifetime tracking), dynamical systems (persistence of invariant torsion under parameter variation)

**Lineage**: Direct extension of `torsion_birthSet_deltaClose` from this work.

**Ambition**: Grand challenge — requires significant new machinery beyond current formalization.

---

## Direction 2: Multiset Bottleneck Stability

**Conjecture**: For filtrations with bounded torsion rank (each H_n has torsion part of rank ≤ R), define a torsion birth multiset recording invariant factors from the Smith Normal Form. Under δ-interleaving, the bottleneck distance between torsion birth multisets is ≤ δ.

**Test**: Compute torsion birth multisets for:
- Filtrations of wedge sums of RP²'s (producing multiple ℤ/2ℤ summands)
- Random 2-complex filtrations with 20-50 simplices
- Compare multiset bottleneck distances under perturbations of δ = 1, 2, 3

**Impact**: Would provide a complete, computationally tractable stability theorem for torsion persistence comparable in power to the classical bottleneck stability theorem.

**Catalog References**: `torsion_birthSet_deltaClose`, `NatSetDeltaClose`, `torsionBirthSet_subsingleton`

**Proof Strategy**: Generalize from subsingleton birth sets to finite multisets. The matching between multisets requires a Hall's theorem argument or a flow-based matching on the bipartite graph of births. Injectivity of interleaving maps should induce a monotone matching.

**Domain Bridges**: Combinatorial optimization (matching theory), computational algebra (Smith Normal Form complexity)

**Lineage**: Builds on `torsion_birthSet_triangle` (the triangle inequality structure is needed for the matching metric).

**Ambition**: Solid extension — achievable with moderate additional formalization.

---

## Direction 3: Relaxing Injectivity to Controlled Kernels

**Conjecture**: Replace the injectivity condition in `FaithfulDeltaInterleaving` with a "controlled kernel" condition: the kernel of each shifted map φᵢ contains no element of order exactly p. Under this weaker condition, torsion birth sets are still δ-close.

**Test**: Construct explicit non-injective interleavings where:
- (a) the kernel is p-torsion-free → verify stability holds
- (b) the kernel contains p-torsion elements → find counterexample to stability

Run on 20+ examples with varying kernel structures.

**Impact**: Would significantly broaden the applicability of the stability theorem, since geometric interleavings in practice are often non-injective (e.g., projection maps in dimensionality reduction).

**Catalog References**: `FaithfulDeltaInterleaving`, `pTorsionDetected_of_injective`, `torsion_support_forward_faithful`

**Proof Strategy**: Weaken `forward_injective` to `∀ a, a ≠ 0 ∧ p • a = 0 → φᵢ(a) ≠ 0` (injectivity on p-torsion elements only). The transport proof uses only this restricted injectivity, so the modification is surgical.

**Domain Bridges**: Geometric group theory (quotient maps), dimensionality reduction (projection stability)

**Lineage**: Direct weakening of `FaithfulDeltaInterleaving` hypothesis.

**Ambition**: Solid extension — the proof modification is clear; the challenge is identifying the right condition.

---

## Direction 4: Primewise Decomposition and Improved Constants (Grand Challenge)

**Conjecture**: When torsion birth sets are computed separately for each prime p, the stability constant can be improved. Specifically, for p-primary torsion birth sets:

```
NatSetDeltaClose(TorsionBirthSet_p(F), TorsionBirthSet_p(F'), δ/ord_p(δ))
```

where ord_p(δ) accounts for the p-adic structure of the interleaving parameter.

**Test**: Compute p-primary torsion births for p = 2, 3, 5, 7 on:
- Filtrations with ℤ/30ℤ ≅ ℤ/2ℤ × ℤ/3ℤ × ℤ/5ℤ torsion
- Mixed filtrations where different primes appear at different levels
- Search for examples where the primewise bound is strictly better than the global bound δ

**Impact**: Would establish that torsion persistence has *more* structure than classical persistence: the prime decomposition provides a natural multi-channel invariant with independent stability in each channel.

**Catalog References**: `TorsionBirthSet`, `prime_selectivity_filtration`, `torsion_birthSet_deltaClose`

**Proof Strategy**: Use the Chinese Remainder Theorem to decompose torsion detection primewise. Each prime detector is functorial independently, and the interleaving may have different effective shifts for different primes.

**Domain Bridges**: Number theory (p-adic analysis), algebraic topology (localization at primes), signal processing (multi-channel filtering)

**Lineage**: Extends `prime_selectivity_filtration` from detection to stability.

**Ambition**: Grand challenge — the p-adic improvement conjecture is speculative and may be false.

---

## Direction 5: Sharp Mesh Stability and Barycentric Subdivision

**Conjecture**: For any finite simplicial filtration F and its barycentric subdivision Sd(F):
```
NatSetDeltaClose(TorsionBirthSet(F, p), TorsionBirthSet(Sd(F), p), 1)
```
for all homological degrees n and primes p.

**Test**:
- Compute torsion birth sets for explicit triangulations of RP², Klein bottle, and Moore spaces M(ℤ/nℤ, 1)
- Compare with their barycentric subdivisions
- Run on 30+ examples including random 2-complexes
- Search for displacement > 1 (counterexample to sharpness)

**Impact**: Would provide a concrete, computable geometric instance of the stability theorem, connecting abstract algebraic stability to combinatorial topology.

**Catalog References**: `refinement_torsion_stability`, `torsion_birthSet_deltaClose`

**Proof Strategy**: Show that barycentric subdivision produces a faithful 1-interleaving. The forward map sends each simplex to its barycentric subdivision (injective on chains). The backward map uses the canonical simplicial approximation (which is injective on homology for sufficiently fine subdivisions).

**Domain Bridges**: Computational geometry (mesh refinement), numerical analysis (discretization error), geometric topology (simplicial approximation)

**Lineage**: Directly uses `refinement_torsion_stability` as the abstract framework.

**Ambition**: Solid extension — the main work is constructing the explicit interleaving, which is classical geometry.
