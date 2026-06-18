# Future Directions

## Synthesis

The theorems established in this work — extraction soundness, cheapest extraction optimality, and quotient normal-form agreement — form the foundation of a **certified optimization theory for equality saturation**. All three theorems share a common architecture: semantic invariance on quotient classes induced by `EqvGen`. This opens five interconnected research directions, ranging from constructive algorithm formalization (Direction 1) to deep conjectures about computational complexity of saturation (Direction 5). Directions 1–3 are solid extensions building directly on catalog theorems; Directions 4–5 are grand-challenge conjectures that, if proved, would reshape our understanding of equational reasoning and optimization.

---

## Direction 1: Constructive Bounded Saturation with Verified Termination

**Conjecture:** For every finite convergent rewrite system `R` over a finite type `α` with `[Fintype α]` and every finite seed set `S ⊆ α`, there exists a computable bound `B(R, S) : ℕ` such that iterating the saturation closure `B(R, S)` times produces an e-graph whose `sameClass` relation is complete for `EqvGen R.rel` restricted to the reachable closure of `S`.

**Test:** Implement bounded saturation in Lean 4 as a `def` operating on `Finset α`. Verify that the resulting e-graph satisfies the `SaturatedEGraphExtractor` interface. Measure `B(R, S)` for randomly generated finite convergent systems with up to 20 symbols and 10 rules. Plot `B` against `|reachable closure|`.

**Impact:** This would close the gap between our abstract theorems (which assume a saturated e-graph exists) and practical implementation (which needs to construct one). It would yield the first *verified equality saturation engine* with proven termination.

**Catalog References:**
- `Pythagorean/EqualitySaturationExtraction.lean`: `SaturatedEGraphExtractor`, `extraction_semantics_preserved`
- `Catalog/Pythagorean/ConvergentRewriteOptimizer.lean`: `CertifiedNormalizer`, `nf_constant_on_eqvGen`

**Proof Strategy:** Induction on the complement of the saturation closure in `Finset α`. Each saturation step either adds a new equivalence or is a no-op. Since `Fintype α` bounds the total number of possible equivalences, saturation must terminate.

**Domain Bridges:** Verified compilation, certified SMT solving, decidability of equational theories.

**Lineage:** Direct extension of `extraction_semantics_preserved` + `Convergent` structure.

**Ambition:** ★★★☆☆ (solid extension, requires careful algorithm formalization)

---

## Direction 2: Compositional E-Graph Extraction for Modular Optimization

**Conjecture:** If `E₁` and `E₂` are saturated e-graph extractors for rewrite systems `R₁` and `R₂` on the same type `α`, and `R₁.rel` and `R₂.rel` are *compatible* (i.e., `EqvGen R₁.rel` ⊆ `EqvGen (R₁.rel ∪ R₂.rel)` and vice versa with `R₂`), then the sequential composition `E₂.extract ∘ E₁.extract` is a sound extractor for the combined system `R₁ ∪ R₂`.

**Test:** Construct two simple rewrite systems (e.g., commutativity + associativity of addition) and verify that composing their extractors preserves semantics on random term algebras. Measure whether composition introduces cost regressions compared to a monolithic saturated e-graph for the combined system.

**Impact:** Modular extraction would enable *compositional compiler optimization*: each optimization pass is a separate e-graph, and their composition is provably sound. This is the missing formal foundation for multi-pass compiler pipelines.

**Catalog References:**
- `Pythagorean/EqualitySaturationExtraction.lean`: `extraction_semantics_preserved`, `extract_respects_eqvGen`
- `Catalog/Pythagorean/ConvergentRewriteOptimizer.lean`: `compose_normalizers_sound`

**Proof Strategy:** Show that `EqvGen (R₁.rel ∪ R₂.rel)` is the join of `EqvGen R₁.rel` and `EqvGen R₂.rel`. Then extraction soundness for the composition follows from soundness of each component.

**Domain Bridges:** Compiler pass composition, modular verification, categorical semantics of rewriting.

**Lineage:** Extends `compose_normalizers_sound` from normalizers to extractors.

**Ambition:** ★★★☆☆ (requires careful handling of equivalence relation compatibility)

---

## Direction 3: Cost-Aware Extraction with Probabilistic Cost Models

**Conjecture:** If the cost model `c : α → ℝ≥0` is replaced by a probabilistic cost `c : α → Distribution ℝ≥0` (e.g., execution time depends on input distribution), then extraction minimizing *expected cost* is still semantically sound, and the cheapest extraction theorem generalizes to expected-cost optimality.

**Test:** Implement a probabilistic cost model in Python where each term's cost is drawn from a distribution depending on its structure. Run equality saturation with expected-cost extraction on arithmetic expression optimization. Compare expected cost of extracted terms versus normal forms over 10,000 random inputs.

**Impact:** This would extend certified optimization from worst-case to average-case, which is the regime that matters for profile-guided optimization and JIT compilation.

**Catalog References:**
- `Pythagorean/EqualitySaturationExtraction.lean`: `cheapest_extraction_sound_and_optimal`, `CostModel`

**Proof Strategy:** Soundness is unchanged (it doesn't depend on cost). Expected-cost optimality requires showing that `argmin_{x ∈ class} E[c(x)]` is well-defined for integrable cost distributions, then applying the same cheapest-in-class argument with expectations.

**Domain Bridges:** Profile-guided optimization, stochastic programming, Bayesian optimization.

**Lineage:** Direct generalization of `cheapest_extraction_sound_and_optimal`.

**Ambition:** ★★☆☆☆ (soundness is trivial; optimality requires measure theory)

---

## Direction 4: Polynomial Saturation Depth for Ground Convergent Systems (Grand Challenge)

**Conjecture:** For every ground convergent rewrite system `R` (no variables, all rules are ground equations) over a finite signature `Σ` with `n` symbols and maximum rule size `k`, the saturation depth required to discover all `EqvGen R.rel` classes among terms of size ≤ `m` is bounded by `poly(n, k, m)`.

**Test:** Generate 1000 random ground convergent systems with `n ∈ {3, ..., 20}`, `k ∈ {2, ..., 8}`. For each, compute the saturation depth needed for terms of size `m ∈ {1, ..., 50}`. Fit `depth ~ n^a · k^b · m^c` and test whether `a, b, c` are bounded.

**Impact:** If true, this would establish that equality saturation is a *polynomial-time* decision procedure for ground equational theories, resolving a long-standing question in automated reasoning. If false, it would identify the structural features that cause exponential saturation.

**Catalog References:**
- `Pythagorean/EqualitySaturationExtraction.lean`: `nf_constant_on_eqvGen_rs`, `Convergent`
- `Catalog/Pythagorean/ConvergentRewriteOptimizer.lean`: `nf_unique_of_confluent`

**Proof Strategy:** For ground convergent systems, every term has a unique normal form of size ≤ max rule RHS size. The equivalence classes are determined by normal forms. Saturation discovers an equivalence `t ∼ u` when it finds a rewrite path `t →* nf(t) = nf(u) ←* u`. The key question is whether these paths can be discovered in polynomial depth.

**Domain Bridges:** Complexity theory, automated theorem proving, word problems in algebra.

**Lineage:** Grand challenge extending `nf_constant_on_eqvGen_rs`.

**Ambition:** ★★★★★ (open problem, falsification would be equally valuable)

---

## Direction 5: Equality Saturation as Free Energy Minimization (Grand Challenge)

**Conjecture:** The dynamics of equality saturation — iterative merging of e-classes followed by cost-guided extraction — can be formalized as a gradient flow on a free energy functional `F = E - TS`, where `E` is the extraction cost, `T` is a "temperature" parameter controlling exploration breadth, and `S` is the logarithm of the e-class size (entropy). At zero temperature, this recovers cheapest extraction; at infinite temperature, it recovers uniform random extraction.

**Test:** Implement simulated-annealing extraction on e-graphs. Define `F(x) = cost(x) - T · log(|class(x)|)` and extract by minimizing `F`. Vary `T` from 0 to ∞ and measure: (a) extraction cost, (b) semantic diversity of extracted terms, (c) convergence rate. Compare with standard cheapest extraction.

**Impact:** This would reveal equality saturation as a *statistical mechanics* process, connecting compiler optimization to thermodynamic optimization. It would suggest new extraction algorithms based on Metropolis sampling, replica exchange, or variational inference over e-classes.

**Catalog References:**
- `Pythagorean/EqualitySaturationExtraction.lean`: `cheapest_extraction_sound_and_optimal`, `extraction_induces_resource_abstraction`

**Proof Strategy:** Define the free energy functional on e-classes. Show that at `T = 0`, the minimizer of `F` coincides with the cheapest representative (recovering our optimality theorem). Show that for `T > 0`, the Gibbs distribution over each e-class is well-defined and assigns higher probability to lower-cost terms.

**Domain Bridges:** Statistical mechanics, information theory, variational inference, simulated annealing.

**Lineage:** Paradigm-shifting reinterpretation of `cheapest_extraction_sound_and_optimal`.

**Ambition:** ★★★★★ (paradigm-shifting, connects optimization theory to statistical physics)
