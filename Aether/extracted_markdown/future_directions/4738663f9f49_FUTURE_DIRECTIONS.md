# Future Research Directions: Counterpoint Category Theory

## Synthesis

This cycle established that first-species counterpoint, when formalized as objects (consonant intervals) and morphisms (valid voice leadings) over ℤ/12ℤ, fails to form a category due to the non-composability of valid voice leadings under the parallel-perfects rule. However, the restriction to imperfect consonances (thirds and sixths) yields a genuine 4-object, 192-morphism subcategory. The consonance asymmetry theorem — showing that the consonant set is not closed under interval inversion, with the asymmetry localized to the fifth/fourth pair — provides a precise algebraic formulation of a centuries-old music-theoretic observation.

The most promising cross-domain connection is between the **partial composition structure** of counterpoint and the theory of **restriction categories** in pure mathematics. Restriction categories formalize "partial maps" in a categorically clean way, and the counterpoint composition failure has exactly the structure needed: a total identity, but partial composition governed by a decidable predicate. Formalizing this connection would bridge music theory, category theory, and the theory of partial computation simultaneously.

The results connect to existing catalog entries: `Catalog/Algebra/MusicalCounterpoint.lean` (voice leading cost as L¹ seminorm) provides the quantitative refinement of our qualitative transition graph, while `Catalog/Pythagorean/HarmonicMusicTheory.lean` (consonance from Pythagorean triples) offers an alternative derivation of the consonant set from number-theoretic principles.

---

### Direction 1: Counterpoint as a Restriction Category

**Conjecture**: The voice-leading structure of first-species counterpoint, with its partial composition, is isomorphic to a specific restriction category in the sense of Cockett & Lack (2002). Specifically, there exists a restriction category R with 6 objects and a restriction combinator that encodes exactly the parallel-perfects rule: the restriction of a composite morphism f;g is total iff the target interval is imperfect or the composite motion is non-parallel.

**Test**: Define a restriction category structure on the voice-leading data (6 objects, 410 morphisms, partial composition). Verify the restriction category axioms: (R1) f ∘ f̄ = f, (R2) f̄ ∘ ḡ = ḡ ∘ f̄ when domains match, (R3) ḡ ∘ f̄ = (g ∘ f̄)̄, (R4) ḡ ∘ f = f ∘ (g ∘ f)̄. Prove or disprove each axiom in Lean 4.

**Impact**: If true, this provides the first concrete musical example of a restriction category, connecting music theory to the foundations of partial computation. If false, the specific failing axiom would identify what makes counterpoint composition "more partial" than standard partial maps.

**Catalog References**: `Catalog/Algebra/MusicalCounterpoint.lean`, `Novelty/CounterpointCategory/Theorems.lean`

**Proof Strategy**: Define the restriction combinator as projection onto the "valid prefix" of a composite. Use the decidability of all predicates (finite types over ZMod 12) to verify axioms computationally. The key lemma is showing that the restriction of f;g depends only on the target interval class and the parallel/non-parallel status.

**Domain Bridges**: Music theory ↔ Restriction categories ↔ Partial computation theory

**Lineage**: Builds on `composition_not_closed` and `imperfect_composition_closed` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Consonance Asymmetry in n-TET Systems

**Conjecture**: For n-TET systems (equal division of the octave into n parts) with consonance defined by bounded frequency-ratio complexity, the consonance set is closed under inversion if and only if n is odd or the "fifth-equivalent" interval (closest to log₂(3/2) × n) is self-inverse (i.e., 2 × fifth ≡ 0 mod n). Specifically, for n ∈ {5, 7, 12, 19, 24, 31, 53}, compute the consonance sets and their inversion closure properties.

**Test**: For each n, define consonant intervals using the Tenney height bound (sum of numerator and denominator of best rational approximation ≤ threshold), compute the inversion map, and check closure. Identify the pattern relating n, the position of the fifth, and inversion symmetry.

**Impact**: If the conjecture holds, it explains the 12-TET consonance asymmetry as an instance of a general number-theoretic phenomenon. If false, the counterexamples would reveal new constraints on the relationship between tuning systems and consonance.

**Catalog References**: `Catalog/Pythagorean/HarmonicMusicTheory.lean` (consonance from Pythagorean triples), `Novelty/CounterpointCategory/Defs.lean` (consonantSet definition)

**Proof Strategy**: For each n, the consonant set is computable. Use `native_decide` for small n and structural arguments for general n. The key insight is that inversion failure is equivalent to the fifth and fourth having different complexity bounds, which depends on the continued fraction expansion of log₂(3/2).

**Domain Bridges**: Music theory ↔ Number theory (continued fractions) ↔ Combinatorics

**Lineage**: Builds on `consonance_not_inversion_closed` and `inversion_swaps_consonant_dissonant`.

**Ambition**: extension

---

### Direction 3: Voice Leading Cost as an Enriched Category

**Conjecture**: The voice-leading structure, when enriched with the L¹ cost function from `Catalog/Algebra/MusicalCounterpoint.lean`, forms a lawful category enriched over (ℝ≥0, +, 0). Specifically, composition of voice leadings satisfies cost(f;g) ≤ cost(f) + cost(g) (triangle inequality), and identity morphisms have cost 0. The enriched category structure exists even though the ordinary category structure fails, because the enrichment absorbs the parallel-perfects constraint into infinite cost.

**Test**: Define cost(vl) = |bass_step| + |treble_step| for valid voice leadings and cost(vl) = ∞ for invalid ones. Verify that this satisfies the enriched category axioms: (1) composition is monotone, (2) identity has cost 0, (3) triangle inequality holds. Prove in Lean 4 using the existing cost_triangle theorem.

**Impact**: If true, this reconciles the categorical and lattice-theoretic approaches to counterpoint: the ordinary category fails but the enriched category succeeds. This would be a novel application of enriched category theory to music.

**Catalog References**: `Catalog/Algebra/MusicalCounterpoint.lean` (cost_triangle, cost_seminorm_properties), `Novelty/CounterpointCategory/Theorems.lean`

**Proof Strategy**: Use `WithTop ℝ≥0` (extended nonneg reals with ∞) as the enriching monoidal category. Define the hom-object for (s,t) as the minimum cost over valid voice leadings. The triangle inequality follows from cost_triangle. The key new result is showing that minimum cost is subadditive under transition composition.

**Domain Bridges**: Category theory (enriched categories) ↔ Metric geometry ↔ Music theory

**Lineage**: Bridges this cycle's categorical analysis with the lattice theory in `MusicalCounterpoint.lean`.

**Ambition**: grand_challenge

---

### Direction 4: Second-Species Counterpoint and Temporal Categories

**Conjecture**: Second-species counterpoint (two notes against one), which introduces passing tones and neighbor tones, restores categorical composition when voice leadings are modeled as 2-morphisms in a bicategory. The dissonant passing tones serve as "witnesses" for composition, making the parallel-perfects rule locally checkable.

**Test**: Formalize second-species rules: consonant intervals on strong beats, dissonant passing tones allowed on weak beats if approached and left by step. Model each beat-pair as a 2-cell in a bicategory. Check whether horizontal composition of 2-cells preserves validity.

**Impact**: If true, this would show that the failure of ordinary categorical structure in first-species is resolved by moving to higher categories in second-species — a temporal enrichment. This connects to the mathematical theory of double categories and provides a new perspective on why musicians invented second-species counterpoint.

**Catalog References**: `Catalog/Algebra/MusicalCounterpoint.lean` (stepwiseMotion constraint), `Novelty/CounterpointCategory/Defs.lean`

**Proof Strategy**: Define a double category with: objects = pitch classes, horizontal morphisms = melodic intervals, vertical morphisms = time steps, 2-cells = counterpoint transitions. Verify interchange law and composition. The key difficulty is formalizing the "stepwise approach to dissonance" rule as a local condition on 2-cells.

**Domain Bridges**: Music theory ↔ Higher category theory (bicategories) ↔ Temporal logic

**Lineage**: Direct extension of the composition failure result, seeking the minimal categorical framework that accommodates counterpoint.

**Ambition**: extension

---

### Direction 5: Computational Complexity of Counterpoint Satisfiability

**Conjecture**: The problem "given a cantus firmus of length n over a diatonic scale, does there exist a valid first-species counterpoint?" is solvable in O(n) time, but "does there exist a valid counterpoint minimizing total voice-leading cost?" is NP-hard for general constraint sets (non-diatonic scales, additional interval restrictions).

**Test**: For the standard diatonic case, construct a linear-time algorithm using the transition graph (K₆ structure). For the NP-hardness result, reduce from a known NP-hard graph coloring or constraint satisfaction problem by encoding it as a counterpoint problem with a suitable scale and interval restrictions.

**Impact**: Establishes the computational boundary between "easy" and "hard" counterpoint. The O(n) result for diatonic first-species would confirm that the rules, while musically rich, are computationally simple. The NP-hardness for generalized systems would show that extending counterpoint rules creates genuinely hard combinatorial problems.

**Catalog References**: `Computation/InfoEfficientAlgorithms.lean` (algorithmic complexity framework), `Novelty/CounterpointCategory/algorithms.py`

**Proof Strategy**: For O(n): the transition graph is K₆, so any sequence of consonant intervals is achievable (always a valid voice leading exists). Build a dynamic programming algorithm. For NP-hardness: use the framework from constraint satisfaction — encode 3-colorability as a counterpoint problem where "colors" are interval classes and "edges" are parallel-motion constraints.

**Domain Bridges**: Music theory ↔ Computational complexity ↔ Constraint satisfaction

**Lineage**: Extends the transition_complete result and the algorithmic analysis.

**Ambition**: extension
