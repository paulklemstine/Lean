# Future Directions: Quantitative Confluence Theory

## Synthesis

The de Bruijn Church-Rosser development establishes a new bridge between rewriting theory and metric geometry: confluence of β-reduction, when combined with normalization, induces a canonical hub-and-spoke metric structure on the equivalence classes of λ-terms. This synthesis opens five specific research directions, ranging from immediate extensions (typed λ-calculi, explicit substitutions) to paradigm-shifting conjectures (negative curvature in reduction graphs, universal cost-optimality of complete developments). Each direction builds directly on the verified infrastructure in `Catalog/Pythagorean/ChurchRosserDeBruijn.lean` and `Catalog/Pythagorean/NormalizationBisimDistance.lean`, and each produces testable predictions.

---

## Direction 1: Complete Development Cost-Optimality

**Conjecture**: Complete development (Takahashi's ⋆-translation) achieves normalization within a constant factor of the optimal reduction strategy for any normalizing λ-term.

**Test**: For families of λ-terms (Church numerals applied to combinators, Böhm trees, combinator encodings of sorting algorithms), compute:
- `CD_passes(t)`: number of complete development iterations to reach normal form
- `OPT_steps(t)`: minimum β-reduction steps to reach normal form (via BFS on small terms)
- Test whether `CD_passes(t) ≤ C * OPT_steps(t)` for a universal constant C.

**Impact**: If true, this would establish complete development as a *certified near-optimal normalizer*—a bridge from confluence theory to algorithmics. If false, characterizing the gap would reveal structural properties of "hard" terms.

**Catalog References**: `Catalog/Pythagorean/ChurchRosserDeBruijn.lean` (completeDev, ParBeta.to_completeDev)

**Proof Strategy**: Formalize the notion of "reduction complexity" for normalizing terms. Prove that each CD pass contracts at least one redex that any strategy must also contract (a "necessary redex" argument). Use residual theory to bound the overhead.

**Domain Bridges**: Rewriting theory ↔ Computational complexity

**Lineage**: Extends Takahashi (1995), connects to Lévy's (1980) theory of optimal reduction.

**Ambition**: ★★★☆☆ (Solid extension, likely true for leftmost-needed strategies)

---

## Direction 2: Metric Hub Phenomenon in Orthogonal Rewriting Systems

**Conjecture**: The metric hub inequality `d(t,u) ≤ cost(t,nf) + cost(u,nf)` holds for any orthogonal (left-linear, non-overlapping) term rewriting system with unique normal forms.

**Test**:
1. Formalize a second rewriting system (e.g., string rewriting with non-overlapping rules, or combinatory reduction systems).
2. Instantiate the abstract `ConfluentCostSystem` framework.
3. Verify the hub inequality computationally on generated term pairs.
4. If the inequality holds, prove it using the abstract `hub_theorem`.

**Impact**: Would establish the metric hub as a *universal* consequence of confluence, not specific to λ-calculus. Opens quantitative rewriting theory as a general field.

**Catalog References**: `ConfluentCostSystem` structure, `hub_theorem`, `nf_unique`

**Proof Strategy**: Prove that orthogonal TRS satisfy the confluence hypothesis of `ConfluentCostSystem` (this is a known theorem due to Rosen, 1973). The rest follows from the abstract framework.

**Domain Bridges**: Rewriting theory ↔ Metric geometry ↔ Universal algebra

**Lineage**: Builds on Rosen (1973), Huet (1980), our abstract framework.

**Ambition**: ★★★★☆ (Grand challenge: requires formalizing orthogonal TRS confluence)

---

## Direction 3: Negative Curvature in Reduction Graphs

**Conjecture**: The reduction graph of normalizing λ-terms exhibits a coarse negative-curvature phenomenon: for any "triangle" t—u—v of β-equivalent normalizing terms, the sides of the triangle (measured by eqPathDist) are "thin" relative to the distances through the normal-form hub.

**Test**: For parameterized families of λ-terms:
1. Compute the reduction graph up to depth D.
2. For all triples (t, u, v) in the graph, compute:
   - Side lengths d(t,u), d(u,v), d(t,v)
   - Hub distances d(t,nf), d(u,nf), d(v,nf)
3. Test the δ-hyperbolicity condition: for the Gromov product (t|v)_u = ½(d(t,u) + d(u,v) - d(t,v)), check if (t|v)_u ≥ min((t|w)_u, (w|v)_u) - δ for a small universal δ.

**Impact**: Would connect λ-calculus reduction to geometric group theory and CAT(-1) spaces. Could yield new proof techniques via geometric methods.

**Catalog References**: `eqPathDist` pseudometric in `NormalizationBisimDistance.lean`, hub inequality

**Proof Strategy**: First establish computationally, then attempt to prove using the hub structure: the normal form acts as a "center" that every geodesic must pass near, which is characteristic of negative curvature.

**Domain Bridges**: λ-calculus ↔ Geometric group theory ↔ Metric geometry

**Lineage**: Novel connection; inspired by Gromov hyperbolicity and the tree-like structure of reduction graphs.

**Ambition**: ★★★★★ (Paradigm-shifting: would create a new field of "geometric rewriting theory")

---

## Direction 4: De Bruijn Substitution Scaling Advantage

**Conjecture**: Proofs using de Bruijn indices have strictly lower dependency complexity (number of auxiliary lemmas, total proof length, compile time) than equivalent proofs using named variables with α-equivalence, for the substitution-heavy portions of the Church-Rosser proof.

**Test**:
1. Measure in the current codebase:
   - Number of sorry-free lemmas needed for Church-Rosser via de Bruijn: count in `ChurchRosserDeBruijn.lean`
   - Number of sorries remaining in the named-variable version: count in `ChurchRosserBisimulation.lean`
   - Total proof term size (bytes)
   - Compile time
2. Attempt to formalize the same results using locally nameless representation.
3. Compare all metrics across the three representations.

**Impact**: Provides empirical evidence for or against the "de Bruijn advantage" in formal verification. Guides future formalization efforts.

**Catalog References**: `ChurchRosserDeBruijn.lean` (de Bruijn), `ChurchRosserBisimulation.lean` (named)

**Proof Strategy**: Purely empirical; the "proof" is the comparison data.

**Domain Bridges**: Proof engineering ↔ Software metrics ↔ Lambda calculus

**Lineage**: Extends the Autosubst comparison (Schäfer et al., 2015) to a specific non-trivial case study.

**Ambition**: ★★☆☆☆ (Solid, immediately actionable)

---

## Direction 5: Certified Normalization with Predictable Asymptotics

**Conjecture**: Iterated complete development on Church numeral expressions `church(n) f x` terminates in O(n) passes, and the normalization cost (single-step count) is Θ(n) for linear combinators f.

**Test**:
1. Compute normalization costs for `church(n) I`, `church(n) K`, `church(n) (church(2))` for n = 1..100.
2. Fit cost(n) to polynomial models.
3. Compare CD passes to single-step counts.
4. For `church(n) (church(m))`, test whether cost is O(m^n) (expected from the structure of Church numeral exponentiation).

**Impact**: Would provide the first certified normalizer with provable asymptotic guarantees, bridging confluence theory and algorithm analysis.

**Catalog References**: `completeDev`, `ParBeta.to_completeDev`, `parBeta_diamond`

**Proof Strategy**: Formalize a measure on terms that decreases by a bounded factor per CD pass. Use the diamond property to bound the number of passes.

**Domain Bridges**: λ-calculus ↔ Algorithm analysis ↔ Complexity theory

**Lineage**: Extends our verified completeDev; connects to Accattoli's work on cost models for λ-calculus.

**Ambition**: ★★★☆☆ (Solid, with concrete benchmarks available)
