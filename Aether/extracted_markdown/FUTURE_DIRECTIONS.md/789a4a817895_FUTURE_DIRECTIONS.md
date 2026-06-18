# Future Directions: Directed Cycle Pressure Theory

## Synthesis

The directed cycle pressure framework established here opens a new axis of investigation in proof-theoretic topology: **causal recurrence as a structural observable**. The five directions below form a coherent research program that extends from immediate formalizable extensions (Directions 1–2) through empirical validation (Direction 3) to paradigm-shifting conjectures about the information-theoretic content of proof structure (Directions 4–5). Each direction builds on the comparison theorem and strict separation result, using them as foundational calibration points for increasingly ambitious claims about what directed structure reveals about mathematical knowledge.

---

## Direction 1: Fully Local SCC Pressure and Stabilization

**Conjecture:** For a digraph G on n vertices, define `localDirPressure(G, v, r)` as the number of vertices in `outBall(G, v, r)` that belong to nontrivial SCCs of the *induced subgraph* `G[outBall(G, v, r)]`. Then:

(a) `localDirPressure(G, v, r) ≤ dirPressure(G, v, r)` for all v, r.

(b) For every G and v, `localDirPressure(G, v, r)` stabilizes (becomes constant) for `r ≥ n`.

(c) There exist families where `localDirPressure` and `dirPressure` differ for small r but agree for large r.

**Test:** Implement `localDirPressure` using Tarjan on the induced subgraph. Compute on random digraphs with n = 50–200 vertices and compare with the global definition. Measure stabilization radius.

**Impact:** This establishes the fully local variant as a refinement of the global definition, and the stabilization result connects to the finite-diameter property of directed reachability.

**Catalog References:** `Pythagorean/ProofTheoreticTopology/DirectedCyclePressure.lean` (outBall, dirPressure definitions); `Catalog/Pythagorean/ProofTheoreticTopology/Theorems.lean` (monotonicity framework).

**Proof Strategy:** For (a), show that every SCC of `G[B]` is contained in an SCC of G, so local recurrence implies global recurrence. For (b), note that `outBall(G, v, n)` contains all reachable vertices, so the local and global definitions agree. For (c), construct explicit examples with "long-range" mutual reachability.

**Domain Bridges:** Graph theory → dynamical systems (local vs. global recurrence classes).

**Lineage:** Direct extension of `dirPressure_mono_radius` and `outBall_mono`.

**Ambition:** Incremental but foundational — establishes the fully local theory needed for all subsequent directions.

---

## Direction 2: SCC Profile Dominance and Refinement Ordering

**Conjecture:** Define the **SCC profile** as the multiset of nontrivial SCC sizes within the out-ball. The directed pressure equals the sum of the SCC profile. Conjecture: the SCC profile induces a partial order on digraphs that is strictly finer than the pressure ordering.

Formally: there exist digraphs G₁, G₂ with `dirPressure(G₁, v, r) = dirPressure(G₂, v, r)` but distinct SCC profiles at (v, r).

**Test:** Enumerate small digraphs (≤ 8 vertices) and compute SCC profiles. Find pairs with equal pressure but distinct profiles. Verify the profile partial order is a proper refinement.

**Impact:** Establishes the SCC profile as a strictly finer invariant than scalar pressure, opening a path to multiset-valued graph invariants in proof topology.

**Catalog References:** `Pythagorean/ProofTheoreticTopology/DirectedCyclePressure.lean` (localSCCProfile definition).

**Proof Strategy:** Explicit construction: G₁ has one SCC of size 4, G₂ has two SCCs of size 2. Both have dirPressure = 4 but profiles {4} vs {2, 2}.

**Domain Bridges:** Graph theory → combinatorics (partition/multiset theory), algebraic topology (higher Betti numbers as multiset refinements).

**Lineage:** Builds on `localSCCProfile` definition in the current formalization.

**Ambition:** Moderate — establishes the next level of invariant refinement.

---

## Direction 3: Predictive Superiority of Directed Features (Grand Challenge)

**Conjecture (Directed Predictive Superiority):** For theorem dependency graphs extracted from Mathlib (or a comparable formal library), the feature vector

```
v ↦ (dirPressure(v, 1), dirPressure(v, 2), causalAsymmetry(v, 2))
```

predicts theorem "difficulty" proxies (proof length, number of dependencies, rebuild latency) strictly better than the corresponding undirected pressure features.

**Test:**
1. Extract the theorem dependency DAG from Mathlib (using `lake env printPaths` and import analysis).
2. Compute directed and undirected pressure features for all theorems.
3. Train random forest / gradient boosting classifiers to predict proof length quartiles.
4. Compare cross-validated accuracy: directed features alone, undirected features alone, and combined.
5. Statistical significance via paired t-test or Wilcoxon signed-rank test.

**Disproof criterion:** If directed features do not achieve statistically significant improvement (p < 0.05) over undirected features on any difficulty proxy, the conjecture fails.

**Impact:** If confirmed, this would be the first empirical demonstration that directed graph structure carries predictive information about mathematical complexity that is invisible to undirected analysis. This would transform proof mining from a symmetrized proxy to a genuinely causal science.

**Catalog References:** `Pythagorean/ProofTheoreticTopology/DirectedCyclePressure.lean` (all main theorems); `Catalog/Pythagorean/ProofTheoreticTopology/Defs.lean` (semantic feature space framework).

**Proof Strategy:** Empirical — requires data pipeline, feature extraction, and statistical analysis. The theoretical foundation is the strict separation theorem, which guarantees the features are non-redundant.

**Domain Bridges:** Graph theory → machine learning (feature engineering), proof theory → data science (theorem recommendation), causal inference → library management.

**Lineage:** Builds on `strict_separation_diamond` and `causalAsymmetry` definitions.

**Ambition:** Grand challenge — paradigm-shifting if confirmed.

---

## Direction 4: Directed Pressure and Proof-Theoretic Ordinals (Grand Challenge)

**Conjecture:** For well-founded proof systems, define the **pressure ordinal** of a vertex v as

```
pressureOrd(v) = sup { r : dirPressure(G, v, r) > dirPressure(G, v, r-1) }
```

(the radius at which pressure stops growing). Conjecture: in well-founded dependency graphs, pressureOrd(v) correlates with the proof-theoretic ordinal of the formal system needed to prove v.

**Test:** Compute pressureOrd for theorems in a hierarchy of formal systems (PRA, PA, ATR₀, Π¹₁-CA₀) and test for monotone correlation with known proof-theoretic ordinals.

**Disproof criterion:** If pressureOrd shows no monotone relationship with proof-theoretic strength across systems, the conjecture fails.

**Impact:** This would connect local graph invariants to proof-theoretic calibration, providing a new combinatorial lens on logical strength.

**Catalog References:** `Pythagorean/ProofTheoreticTopology/DirectedCyclePressure.lean` (dirPressure_mono_radius); `Catalog/Pythagorean/ProofTheoreticTopology/Theorems.lean` (filtration framework).

**Proof Strategy:** First establish that pressureOrd is well-defined (finite for finite graphs). Then correlate with ordinal assignments from reverse mathematics. The key obstacle is that proof-theoretic ordinals are properties of *systems*, not individual theorems.

**Domain Bridges:** Graph theory → proof theory → mathematical logic → reverse mathematics.

**Lineage:** Extends `dirPressure_mono_radius` and the DAG vanishing theorem.

**Ambition:** Grand challenge — would bridge two previously unconnected mathematical domains.

---

## Direction 5: Causal Asymmetry as a Structural Health Metric

**Conjecture:** In software dependency graphs, high causal asymmetry (CA > median + 2σ) at a module v predicts that v is a maintenance hotspot — a location where bugs, build failures, or performance issues concentrate.

**Test:**
1. Extract dependency graphs from 10+ open-source projects (Linux kernel modules, Python package DAGs, Rust crate dependencies).
2. Compute causal asymmetry for each module.
3. Correlate with maintenance metrics: bug density, commit frequency, build failure rate.
4. Test whether CA > threshold predicts hotspots with AUC > 0.65.

**Disproof criterion:** If AUC ≤ 0.55 across all projects and metrics, the conjecture fails.

**Impact:** This would give software engineers a new, theoretically grounded metric for identifying structurally problematic code — one that distinguishes genuine circular dependencies from mere high connectivity.

**Catalog References:** `Pythagorean/ProofTheoreticTopology/DirectedCyclePressure.lean` (causalAsymmetry definition, dirPressure_le_undirPressure_forgetDir theorem).

**Proof Strategy:** Empirical — requires data pipeline and statistical analysis. The theoretical grounding is that high CA means the module's apparent complexity is mostly due to symmetrization artifacts, suggesting structural confusion that may correlate with maintenance difficulty.

**Domain Bridges:** Graph theory → software engineering → empirical software research → project management.

**Lineage:** Direct application of `causalAsymmetry` and the comparison theorem.

**Ambition:** High applied impact — connects abstract invariant to engineering practice.
