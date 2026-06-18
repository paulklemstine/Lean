# Future Directions: Phase-Aware Lemma Synthesis

## Synthesis

The formal theory of reasoning phase transitions establishes that proof search undergoes qualitative regime changes as complexity increases, and that lemma synthesis is the correct macroscopic control parameter above a certified threshold. The five verified theorems — upward closure, strict complexity reduction, resource allocation dominance, energy descent, and phase partition — form a coherent foundation for a new field at the interface of proof complexity, learning theory, and verified AI systems.

The directions below extend this foundation along three axes: (1) deepening the mathematical theory toward renormalization and entropy, (2) bridging to machine learning and curriculum design, and (3) empirically validating the predictions on real theorem-proving benchmarks. The grand challenges (Directions 1–2) aim to establish reasoning phase transitions as a first-class concept in mathematical logic, while the solid extensions (Directions 3–5) build directly on the verified catalog theorems to produce immediately testable hypotheses.

---

## Direction 1: Renormalization Flow on Proof Structures

**Ambition:** Grand Challenge — Paradigm-Shifting

**Conjecture:** There exists a coarse-graining operator Φ on proof terms such that (a) Φ preserves logical validity, (b) the complexity measure is non-increasing under Φ, and (c) the fixed points of iterated Φ correspond to maximally compressed proofs. The sequence of complexities under Φ converges, and the convergence rate exhibits *universality*: it depends on the phase (tractable/intractable) but not on the specific theorem family.

**Test:** Define Φ as lemma abstraction (replacing repeated subterms with a single lemma reference). Implement on proof terms from Mathlib. Measure complexity reduction per iteration. Test universality by comparing convergence rates across algebraic, analytic, and combinatorial theorem families. Reject universality if convergence rates differ by more than a factor of 2 across domains within the same phase.

**Impact:** Would establish a renormalization group theory for mathematical reasoning, connecting proof compression to critical phenomena in physics. Opens the path to *scaling laws* for theorem proving.

**Catalog References:**
- `Catalog/MachineLearning/ProofCompression/Defs.lean` — CompressionInstance, HasAsymptoticGap
- `Pythagorean/PhaseAwareLemmaSynthesis.lean` — Phase, LemmaBenefit, effectiveComplexity

**Proof Strategy:** Define Φ as a function on a type of proof terms. Prove complexity non-increase using the `beneficial` field of LemmaBenefit. Study fixed points using Knaster-Tarski or Banach. Universality requires finer analysis — likely needs new Mathlib infrastructure for proof-term metrics.

**Domain Bridges:** Statistical physics (renormalization group), dynamical systems (fixed-point theory), compiler optimization (common subexpression elimination).

**Lineage:** Builds on Theorem 2 (strict complexity reduction) and Theorem 4 (energy descent). Extends the energy framework from a single-step descent to an iterated flow.

---

## Direction 2: Free-Energy Principle for Tactic Selection

**Ambition:** Grand Challenge — Paradigm-Shifting

**Conjecture (Phase-Separated Solver Advantage):** There exists a threshold function T : ℕ → ℕ such that for any theorem family F : ℕ → α with monotone complexity, if T(n) ≤ complexityScore(F(n)) eventually, then a phase-aware prover with certified lemma synthesis solves infinitely many instances of F within budget B(n) that a direct-search prover of the same budget cannot solve. Moreover, the advantage grows at least as fast as the complexity gap: the number of "synthesis-only" solutions in [0, N] is Ω(N).

**Test:** Build theorem families stratified by complexityScore (e.g., powerset expansion at various sizes). Run both direct-search and phase-aware provers with identical token/time budgets. Measure the separation. Reject the conjecture if no statistically significant separation (p < 0.01) appears above the certified threshold for any family of size ≥ 50.

**Impact:** Would provide the first *asymptotic* separation theorem for adaptive vs. fixed-strategy ATP, analogous to circuit complexity separations.

**Catalog References:**
- `Pythagorean/PhaseAwareLemmaSynthesis.lean` — phaseAware_dominates_direct_above_threshold, chooseSearchAction_improves_complexity
- `Catalog/MachineLearning/ProofCompression/Theorems.lean` — exponential-vs-linear gap theorems

**Proof Strategy:** Use the verified dominance theorem (Theorem 3) as the base case. Extend to asymptotic families by constructing explicit instances in the "dominance zone" (reduced ≤ B < base) and counting them. The Ω(N) growth bound may require number-theoretic estimates on the growth rate of 2^n vs n+1.

**Domain Bridges:** Computational complexity (circuit lower bounds), information theory (channel capacity), learning theory (PAC learning sample complexity).

**Lineage:** Direct extension of Theorem 3. Uses Theorem 1 (upward closure) to guarantee the dominance zone is connected.

---

## Direction 3: Phase-Aware Curriculum Learning for Neural Theorem Provers

**Ambition:** Solid Extension

**Conjecture:** A neural theorem prover trained on a phase-stratified curriculum — tractable instances first, then transitional, then intractable — achieves at least 15% higher solve rate on held-out intractable-phase problems compared to random-order training, under equal total training compute.

**Test:** Take a corpus of Mathlib theorems. Compute complexity scores (e.g., AST depth + variable count). Partition into three phases using a threshold estimated from the corpus statistics. Train two instances of a neural prover (e.g., ReProver): one with phase-ordered curriculum, one with random order. Measure solve rate on the intractable-phase test set. Reject if the curriculum advantage is < 5% (accounting for variance across 5 random seeds).

**Impact:** Would validate the phase transition theory in a practical ML setting, demonstrating that formal mathematical structure improves empirical training outcomes.

**Catalog References:**
- `Pythagorean/PhaseAwareLemmaSynthesis.lean` — curriculumBucket_agrees_with_policy, predictedPhase_monotone
- `Catalog/MachineLearning/ProofCompression/Defs.lean` — Phase, complexityScore

**Proof Strategy:** The formal guarantee (curriculumBucket_agrees_with_policy) shows the partition is mathematically consistent. The empirical test validates whether this consistency translates to training efficiency.

**Domain Bridges:** Machine learning (curriculum learning, self-paced learning), education theory (zone of proximal development).

**Lineage:** Builds on Theorem 5 (phase partition) and the curriculum partition algorithm.

---

## Direction 4: Monotone Advantage Growth Under Parameterized Compression

**Ambition:** Solid Extension

**Conjecture:** For the exponential benefit model, the complexity gap baseComplexity(n) − reducedComplexity(n) = 2^n − (n+1) is not only positive for n ≥ 2 (as proved) but strictly monotone for n ≥ 2, and the *ratio* baseComplexity(n)/reducedComplexity(n) is unbounded. More generally, for any LemmaBenefit model where baseComplexity grows faster than reducedComplexity, the advantage is eventually monotone.

**Test:** Formalize and verify in Lean 4 that the gap function n ↦ 2^n − (n+1) is strictly monotone for n ≥ 2, and that the compression ratio 2^n/(n+1) → ∞. Extend to a general theorem: if baseComplexity is eventually super-linear and reducedComplexity is eventually sub-linear, the gap is eventually monotone. Reject if counter-examples exist for specific growth rates (e.g., base = n log n, reduced = n).

**Impact:** Strengthens the core theory from "strict advantage" to "growing advantage," providing quantitative predictions for how much better synthesis becomes as problems scale.

**Catalog References:**
- `Pythagorean/PhaseAwareLemmaSynthesis.lean` — exponentialBenefit_threshold, effectiveComplexity_strictly_decreases_above_threshold
- `Catalog/MachineLearning/ProofCompression/Theorems.lean` — exists_exp_gt_linear

**Proof Strategy:** For the exponential model, show d/dn(2^n − n − 1) = 2^n ln 2 − 1 > 0 for n ≥ 2 (or discrete analogue). For the general case, use eventual domination hypotheses and the monotone convergence properties of the gap.

**Domain Bridges:** Analysis (growth rate comparison), information theory (rate-distortion theory).

**Lineage:** Direct strengthening of Theorem 2. Uses the exponential benefit model as the canonical case.

---

## Direction 5: Cross-Domain Stability of Phase Boundaries

**Ambition:** Solid Extension

**Conjecture:** The upward-closed hard phase (the set {x | phaseFn(x) ≠ tractable}) is structurally stable across Mathlib domains: when complexity is measured uniformly (e.g., as proof-term size), the threshold value T such that predictedPhase(T, n) transitions from tractable to non-tractable lies within a factor of 3 across algebra, analysis, and combinatorics subsets of Mathlib.

**Test:** Extract theorem metadata from Mathlib (proof-term sizes, tactic counts, dependency depths). For each domain (Algebra, Analysis, Topology, Combinatorics), estimate the empirical phase transition threshold — the complexity level at which direct-tactic solve rate drops below 50%. Compare thresholds across domains. Reject stability if the ratio of max-to-min threshold exceeds 5.

**Impact:** If validated, demonstrates that phase transitions in reasoning are a *universal* phenomenon, not an artifact of specific theorem families. This would justify domain-independent phase-aware architectures.

**Catalog References:**
- `Pythagorean/PhaseAwareLemmaSynthesis.lean` — synthesis_region_upward_closed, theoremSpace_partitioned_by_phase
- `Catalog/MachineLearning/ProofCompression/Defs.lean` — HasThreshold

**Proof Strategy:** The upward closure (formally verified) guarantees structural stability within a domain. Cross-domain stability is an empirical question requiring measurement. A formal version might prove that if two complexity measures are Lipschitz-equivalent, their thresholds are within a bounded factor.

**Domain Bridges:** Statistical physics (universality), meta-mathematics (proof-theoretic ordinals across theories).

**Lineage:** Extends Theorem 1 (upward closure) and Theorem 5 (partition) from single-predictor to multi-domain settings.
