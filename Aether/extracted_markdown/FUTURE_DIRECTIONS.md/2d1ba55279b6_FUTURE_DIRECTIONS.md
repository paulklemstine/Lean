# Future Directions: Compression Spectrum Structure

## Synthesis

The compression spectrum theory established here — upward closure, interval characterization, essential probes, and hitting-set duality — provides the foundation for a deeper investigation into the combinatorial structure of probe-separated models. The key insight is that the spectrum itself is "trivial" (an interval), but the *internal structure* of separating families (minimality, exchange, defect) encodes rich invariants. The five directions below attack this internal structure from complementary angles: matroid-theoretic (Directions 1–2), computational (Direction 3), topological (Direction 4), and information-theoretic (Direction 5). Together, they aim to determine whether probe separation admits a canonical optimization theory (like matroid intersection) or reveals fundamentally new combinatorial phenomena.

---

## Direction 1: Exchange Property Characterization

**Conjecture:** There exists a finite model `(F, r)` on ≤ 6 objects such that the basis exchange property fails for minimum-cardinality separating families: there exist minimum-cardinality separating families `P, Q` and `p ∈ P \ Q` such that no `q ∈ Q \ P` makes `(P \ {p}) ∪ {q}` separating.

**Test:** Enumerate all models on 4–6 objects with fiber sizes 2–3. For each model, compute all minimum-cardinality separating families and check pairwise exchange. A single counterexample suffices. If no counterexample is found on ≤ 6 objects, this strongly suggests the exchange property holds universally and motivates a proof attempt.

**Impact:** If exchange *fails*, the separating-family system is provably not a matroid, and new algorithmic techniques are needed. If exchange *holds*, a full matroid structure theorem becomes plausible, immediately importing decades of matroid optimization theory.

**Catalog References:**
- `Pythagorean/ProbeComplexity/CompressionSpectrumStructure.lean`: `minimal_separating_family_all_essential`, `minCard_sep_is_inclusion_minimal`
- `Pythagorean/ProbeComplexity/ToposCompressionDefs.lean`: `ProbeSeparates.mono`

**Proof Strategy:** If exchange holds universally, prove by showing that the signature maps form a linear-algebraic structure (e.g., over GF(2)) where exchange follows from linear independence. If it fails, the counterexample construction should exploit non-linear interactions between restriction maps.

**Domain Bridges:** Matroid theory, combinatorial optimization, greedy algorithms.

**Lineage:** Builds directly on Theorems 4.2 and 4.4 (essential probes, min-card ⟹ inclusion-minimal).

**Ambition:** 🔴 Grand Challenge — resolves whether a canonical greedy theory of probe separation exists.

---

## Direction 2: Compression Defect as a Complexity Invariant

**Conjecture:** For every `d ≥ 0`, there exists a model `(F, r)` with compression defect `δ(F, r) = d`. Moreover, the compression defect is a Morita invariant: `δ(F₁, r₁) = δ(F₂, r₂)` whenever the models are compression-equivalent.

**Test:** (a) Construct explicit families of models parameterized by `d` with `δ = d`. (b) For each constructed model, compute all compression-equivalent models and verify `δ` is preserved.

**Impact:** If the defect is a Morita invariant, it becomes a new structural invariant of categorical presheaf models — the first "higher-order" compression invariant beyond the compression number itself. If it's not Morita-invariant, the theory needs refinement, and the failure mode reveals what additional structure equivalences must preserve.

**Catalog References:**
- `Pythagorean/ProbeComplexity/CompressionSpectrumStructure.lean`: `compressionDefect`, `compressionDefect_zero_iff_uniform`
- `Catalog/Bridges/Catalog/Pythagorean/ProbeComplexity/ToposCompressionInvariant.lean`: `compressionNumber_eq_of_equiv'`

**Proof Strategy:** For Morita invariance, show that compression equivalences biject minimal separating families while preserving cardinality, hence preserve both max and min over minimal families.

**Domain Bridges:** Category theory (Morita equivalence), algebraic topology (invariants), complexity theory.

**Lineage:** Extends the Morita invariance of `κ` (Theorem C in ToposCompressionInvariant) to the defect.

**Ambition:** 🟡 Solid Extension — natural next step from existing invariance theorems.

---

## Direction 3: Algorithmic Complexity of the Compression Number

**Conjecture:** Computing `κ(F, r)` is NP-hard in general (via reduction from minimum hitting set), but admits a polynomial-time algorithm when the number of "obstruction pairs" (pairs of distinct sections in any fiber) is bounded by a polynomial in `|Ob|`.

**Test:** (a) Construct an explicit polynomial-time reduction from Minimum Hitting Set to computing `κ`. (b) Implement the specialized algorithm for bounded-obstruction models and benchmark on random models with controlled parameters.

**Impact:** This would precisely delineate tractable from intractable instances of the compression problem, connecting the abstract theory to computational feasibility.

**Catalog References:**
- `Pythagorean/ProbeComplexity/CompressionSpectrumStructure.lean`: `probeSeparates_iff_hits_distinguishing`

**Proof Strategy:** The hitting-set characterization (Theorem 5.1) directly translates to a hitting-set instance. For the polynomial case, use the bounded number of hyperedges to enumerate efficiently.

**Domain Bridges:** Computational complexity, approximation algorithms, parameterized complexity.

**Lineage:** Builds directly on the hitting-set duality theorem.

**Ambition:** 🟡 Solid Extension — connects formal theory to algorithmic practice.

---

## Direction 4: Topological Compression Spectra

**Conjecture:** For presheaves on a finite poset category (not just discrete categories), the compression spectrum may have *gaps* — it need not be an interval. Specifically, there exists a finite poset `C` and a presheaf `F` on `C` such that `CompSpec(F, r)` is not an interval.

**Test:** Enumerate presheaves on small poset categories (chains of length 3, diamond posets, etc.) and compute compression spectra. A single gap would refute the interval conjecture in the poset setting.

**Impact:** If gaps exist in the poset setting, it would show that the interval structure is a special feature of discrete categories, not a general categorical phenomenon. This would motivate a classification of categories by their "spectral topology."

**Catalog References:**
- `Pythagorean/ProbeComplexity/CompressionSpectrumStructure.lean`: `compressionSpectrum_upward_closed` (which uses `Finset.exists_superset_card_eq` — a key step that relies on the discrete structure)

**Proof Strategy:** The upward closure proof relies on extending P by adding arbitrary elements. In a poset category, "probes" must respect the partial order, potentially breaking this argument.

**Domain Bridges:** Order theory, presheaf categories, simplicial complexes, persistent homology.

**Lineage:** Extends the current discrete-category theory to structured categories.

**Ambition:** 🔴 Grand Challenge — would open a new dimension of compression theory.

---

## Direction 5: Information-Theoretic Bounds on Compression Number

**Conjecture:** For any model `(F, r)` with finite fibers:
```
κ(F, r) ≥ ⌈log₂(max_Y |F(Y)|) / log₂(max_Z |F(Z)|)⌉
```
That is, the compression number satisfies an information-theoretic lower bound: you need enough probes to encode all sections in the largest fiber via their signatures at probe objects.

**Test:** Verify this bound computationally on all models with ≤ 5 objects and fibers of size ≤ 4. Any violation refutes the conjecture.

**Impact:** This would provide a computable lower bound on κ that doesn't require enumerating separating families — a "Shannon bound" for compression. Combined with the upper bound `κ ≤ |Ob|`, it would sandwich the compression number.

**Catalog References:**
- `Catalog/Pythagorean/ProbeComplexity/Theorems.lean`: `card_hom_le_profile_capacity` (information-theoretic capacity bound)
- `Pythagorean/ProbeComplexity/CompressionSpectrumStructure.lean`: `compressionNumber_le_card`

**Proof Strategy:** Use the profile capacity bound: if P separates, then |F(Y)| ≤ ∏_{Z ∈ P} |F(Z)|. Taking logs gives |P| ≥ log(|F(Y)|) / max_Z log(|F(Z)|).

**Domain Bridges:** Information theory (Shannon bounds), coding theory (code rate), data compression.

**Lineage:** Builds on the existing profile capacity bound in Theorems.lean.

**Ambition:** 🟡 Solid Extension — natural information-theoretic complement to the combinatorial theory.

---

*Each direction above is designed to be independently pursuable. Directions 1 and 4 are grand challenges that could reshape the theory; Directions 2, 3, and 5 are solid extensions that deepen the existing framework. All are computationally testable and formally falsifiable.*
