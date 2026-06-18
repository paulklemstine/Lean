# Future Directions: Renormalization Fixed Points for Proof Search Trees

## Overview

This document presents five falsifiable scientific hypotheses extending the formally verified universality theorem for proof search trees. Each hypothesis is specific enough to fail and ambitious enough to matter.

---

## Hypothesis 1: Fragment Universality Hypothesis

**Conjecture:** For bounded-branching propositional proof search, all complete fair provers with equal renormalized entropy converge to the same local limit law. That is, the contraction hypothesis in our Theorem C (universality_of_shared_contraction) is automatically satisfied whenever two proof-search procedures share the same logical fragment and entropy normalization.

**Test:** Compare CDCL-style, tableau-style, and BFS-style proof search on shared random 3-SAT families. Compute empirical radius-r neighborhood distributions at depths n = 100, 1000, 10000. If the distributions converge and agree across prover types, the hypothesis is supported.

**Refutation:** A stable benchmark family for which two complete provers produce provably distinct limiting radius-r profile vectors despite sharing the same fragment and entropy normalization. This would mean the contraction hypothesis is *not* automatic and additional structural conditions are needed.

**Impact if true:** Proof-search benchmarks should be classified by universality class rather than syntactic problem family. Performance predictions would transfer between provers.

---

## Hypothesis 2: Fragment Separation Hypothesis

**Conjecture:** Propositional and first-order proof search have non-isomorphic local limit objects under any entropy-preserving renormalization. Specifically, the renormalization fixed point μ* for propositional fragments is always distinguishable from the fixed point for first-order fragments by a finite number of radius-r profile moments.

**Test:** Compute certified local invariants (radius-2 and radius-3 neighborhood frequency vectors) for propositional resolution trees and first-order unification trees on matched problem families. Check whether the limit vectors are separated in total variation.

**Refutation:** A benchmark family whose propositional and first-order search trees produce identical limiting profiles. This would suggest that the quantifier structure of first-order logic does not affect local tree geometry.

**Impact if true:** It would establish that different logical fragments define genuinely different universality classes — creating a classification theory for proof-search geometry analogous to universality classes in statistical mechanics.

---

## Hypothesis 3: Criticality Hypothesis

**Conjecture:** There exists a critical entropy threshold h_c > 0 at which the local proof-search geometry undergoes a phase transition from a "narrow-tree" universality class (dominated by path-like structures) to a "heavy-branching" universality class (dominated by full subtrees). Formally, the renormalization fixed point μ*(h) is discontinuous as a function of the entropy parameter h at h = h_c.

**Test:** For a parametric family of proof-search procedures indexed by branching penalty λ (which controls entropy), compute the limiting radius-2 neighborhood distribution μ*(λ) as a function of λ. Monitor for discontinuities or sharp transitions in the distribution.

**Refutation:** If μ*(h) is continuous and differentiable across the entire entropy range, or if no bifurcation is detectable, the criticality hypothesis fails. This would suggest proof-search universality classes vary smoothly rather than exhibiting phase transitions.

**Impact if true:** It would predict that proof search undergoes qualitative behavioral changes at specific complexity thresholds, analogous to satisfiability phase transitions. This could explain why certain proof-search strategies fail catastrophically beyond specific problem sizes.

---

## Hypothesis 4: Heuristic Irrelevance Hypothesis

**Conjecture:** Within a fixed fragment class, heuristic differences (variable ordering, clause selection, backtracking strategy) affect only transient renormalization trajectories, not the limiting fixed point. Formally, if R₁ and R₂ are renormalization operators for two provers sharing the same fragment, then they have the same fixed point even if R₁ ≠ R₂ — that is, the basin of attraction is the entire profile space.

**Test:** Compare time-series of local profile vectors μ_n across 5+ provers on the same problem family. Track convergence trajectories and asymptotic values. If all trajectories converge to the same limit despite different transient behavior, the hypothesis is supported.

**Refutation:** Two provers with the same fragment that converge to provably distinct asymptotic local profiles. This would show that heuristic choices can create genuinely different universality classes within the same fragment.

**Impact if true:** It would mean that all the engineering effort in prover heuristics affects only speed of convergence, not the fundamental geometry of proof search. Lower bounds proved for one prover would automatically apply to all provers in the same fragment.

---

## Hypothesis 5: Dependent-Type Anomaly Hypothesis

**Conjecture:** Dependent type theory yields a fundamentally different renormalization structure from propositional and first-order logic. Specifically, either (a) the local profile space is non-compact (infinitely many distinct limiting profiles exist as the type complexity varies), or (b) the renormalization operator is not eventually contractive in any standard metric, so the contraction-based universality theorem does not apply.

**Test:** Compute bounded-radius local statistics over elaboration/search traces in a dependent type theory kernel (e.g., the core type-checking algorithm). Measure whether the empirical neighborhood distributions stabilize with increasing depth, and whether the contraction ratio is bounded away from 1.

**Refutation:** A finite compact family of stable universal limits for dependent-type proof search. This would show that dependent types do not fundamentally break the renormalization framework — they simply define additional universality classes within the same theory.

**Impact if true:** It would establish that the proof-search universality theory requires fundamentally new tools for dependent type theory. The term-dependency feedback loop between types and terms may create a qualitatively different mathematical structure, potentially connecting to coherence conditions in higher category theory.

---

## Methodological Notes

### Computational Validation Protocol
Each hypothesis should be tested with:
1. **At least 3 distinct proof-search implementations** per fragment
2. **Random problem families with n ≥ 1000** variables
3. **Depth truncations at n = 10, 100, 1000, 10000**
4. **Radius r = 1, 2, 3** neighborhood statistics
5. **Statistical tests**: Kolmogorov-Smirnov or total variation distance with significance level α = 0.01

### Connection to Verified Mathematics
The formally verified theorems (profile_converges_of_summable_steps, contraction_unique_fixedPoint, universality_of_shared_contraction) provide the mathematical backbone for all five hypotheses. The hypotheses differ in *which structural conditions* are assumed versus proved:
- Hypothesis 1: Is contractivity automatic?
- Hypothesis 2: Do different fragments yield different fixed points?
- Hypothesis 3: Is the fixed point continuous in parameters?
- Hypothesis 4: Is the fixed point unique across heuristic variations?
- Hypothesis 5: Does the framework extend to dependent types?

### Priority Ordering
1. **Hypothesis 4** (Heuristic Irrelevance) — most directly testable with existing provers
2. **Hypothesis 1** (Fragment Universality) — the core conjecture
3. **Hypothesis 3** (Criticality) — connects to SAT phase transitions
4. **Hypothesis 2** (Fragment Separation) — requires cross-fragment comparison
5. **Hypothesis 5** (Dependent-Type Anomaly) — requires specialized infrastructure
