## Mode: discover

## Title
Topology of Proof Search as a Statistical Law: quartile-locality predicts theorem timeout via dependency-graph phase transitions

## Core Breakthrough Goal

Take the existing proof-theoretic locality framework and turn it into a **genuinely structural theory of theorem difficulty**. The target is not another descriptive metric, but a theorem-backed computational program showing that **dependency-graph topology predicts automated proving failure rates** in a way that is stable across domains and explainable via phase-transition phenomena.

The bold claim to investigate and partially formalize is:

> The geometry/topology of theorem dependency neighborhoods contains predictive information about proof difficulty that cannot be reduced to proof length, syntactic size, or theorem statement complexity.

If established, this opens a new field: **proof complexity through topological statistics**, bridging formal mathematics, network science, and statistical mechanics of search.

---

## Exact Research Targets

You must build on:

- `Catalog/Pythagorean/ProofTheoreticTopology/LocalityCorrelation.lean`
  - `proofTheoreticLocality`
  - `critical_threshold_exists_finite`
- `Catalog/Pythagorean/ProofTheoreticTopology/Theorems.lean`
  - `graphCycleRank_pos_of_connected_many_edges`

Do not merely rerun an experiment. Formalize new mathematics around the phase transition and the quartile effect.

---

## New definitions to introduce

You are required to define at least one genuinely new concept not already present in the catalog. Recommended definitions:

1. **Locality quartile classifier**
   - For a finite family of theorem instances indexed by `α`, with score `L : α → ℚ` or `ℝ`, define the lower and upper empirical quartile subsets.
   - This creates a topological-statistical partition of theorem space.

2. **Timeout enrichment over a theorem family**
   - A structure recording:
     - a finite index set of theorem tasks,
     - locality score,
     - timeout indicator,
     - optional syntactic covariates.
   - This is the right object for stating structural predictor theorems.

3. **Normalized critical threshold**
   - If the catalog already gives existence of a critical threshold `ε*`, define
     \[
     \theta(S) := \frac{\varepsilon^*}{\operatorname{diam}(S)}
     \]
     for finite metric theorem spaces with positive diameter.
   - This is the mathematically meaningful dimensionless order parameter for universality.

Suggested Lean 4 skeletons:

```lean
structure TimeoutDataset (α : Type _) [Fintype α] where
  locality : α → ℚ
  timeout : α → Bool

def upperQuartile (D : TimeoutDataset α) : Finset α := ...
def lowerQuartile (D : TimeoutDataset α) : Finset α := ...

def timeoutRate (D : TimeoutDataset α) (s : Finset α) : ℚ := ...

def normalizedCriticalThreshold
  {α : Type _} [Fintype α]
  (d : α → α → ℚ) (εstar diam : ℚ) : ℚ := εstar / diam
```

If quartiles over `ℚ` become awkward, use sorted finite lists or rank-based definitions. The key is that the definitions are mathematically nontrivial and reusable.

---

## Theorem 1: Structural monotonicity theorem for quartile separation

Before any statistical statement, prove a rigorous theorem saying that if timeout probability is monotone in locality, then the upper quartile has at least the timeout rate of the lower quartile. This converts an empirical hypothesis into a theorem schema.

### Precise mathematical statement

Let `α` be finite, let `L : α → ℚ` be a locality score, let `p : α → ℚ` be a timeout propensity with values in `[0,1]`, and suppose `p` is monotone with respect to `L`:
\[
L(x) \le L(y) \implies p(x) \le p(y).
\]
Then the average propensity on the upper quartile is at least the average propensity on the lower quartile.

This is not yet the “2×” claim, but it gives the formal backbone for why locality can be a structural predictor.

### Suggested Lean 4 target

```lean
theorem avg_timeoutProp_upperQuartile_ge_lowerQuartile
  {α : Type _} [Fintype α] [DecidableEq α]
  (L : α → ℚ) (p : α → ℚ)
  (hprob : ∀ a, 0 ≤ p a ∧ p a ≤ 1)
  (hmono : ∀ {a b}, L a ≤ L b → p a ≤ p b) :
  avgOn (upperQuartileFromScore L) p ≥ avgOn (lowerQuartileFromScore L) p := ...
```

If `avgOn` does not exist, define it over `Finset`:
```lean
def avgOn (s : Finset α) (f : α → ℚ) : ℚ := ...
```

### Why this matters
This theorem transforms the experimental quartile phenomenon into a consequence of a latent monotonicity law. It is the bridge between descriptive statistics and structural proof complexity.

### Proof strategy options

**Strategy A: order-statistics + rearrangement inequality**
1. Sort the finite index set by locality.
2. Express lower and upper quartiles as initial/final segments.
3. Use monotonicity of `p` and a finite averaging comparison lemma.

Most promising: this gives a reusable theorem schema and is closest to the mathematical heart.

**Strategy B: injection/comparison by rank**
1. Pair each low-quartile element with a high-quartile element of greater or equal rank.
2. Use `hmono` pointwise.
3. Sum over the pairing and divide by cardinalities.

This may be easier in Lean if explicit sorted lists are cumbersome.

**Strategy C: contradiction via average gap**
1. Assume upper average `<` lower average.
2. Derive existence of a violating pair by finite averaging.
3. Contradict monotonicity.

Elegant, but usually harder to mechanize cleanly.

---

## Theorem 2: Scale invariance of the critical threshold location

Use `critical_threshold_exists_finite` to prove that the *location* of the critical threshold is equivariant under uniform metric rescaling. This is the first step toward universality.

### Precise mathematical statement

Let `(S,d)` be a finite metric space of theorems and let `φ_d(ε)` be the cyclomatic density profile induced by thresholding the graph at distance `ε`. If `c > 0` and `d'(x,y) = c * d(x,y)`, then any critical threshold `ε*` for `d` corresponds to `c ε*` for `d'`. Hence the normalized threshold `ε*/diam(S)` is invariant under scaling.

### Suggested Lean 4 target

```lean
theorem normalizedCriticalThreshold_scale_invariant
  {α : Type _} [Fintype α]
  (d : α → α → ℚ) (εstar diam c : ℚ)
  (hc : 0 < c) (hdiam : 0 < diam) :
  normalizedCriticalThreshold (fun x y => c * d x y) (c * εstar) (c * diam)
    = normalizedCriticalThreshold d εstar diam := by
  field_simp [normalizedCriticalThreshold]
```

This theorem by itself is elementary, but it is not trivial in significance: it identifies the correct dimensionless observable for cross-domain comparison.

### Stronger follow-up theorem

If you can connect the threshold graph construction formally:

```lean
theorem critical_threshold_scales
  {α : Type _} [Fintype α] ...
  (hc : 0 < c) :
  IsCriticalThreshold d εstar →
  IsCriticalThreshold (fun x y => c * d x y) (c * εstar) := ...
```

You will need to define `IsCriticalThreshold` in a way compatible with the catalog theorem. This would be a real contribution.

### Proof strategy options

**Strategy A: threshold graph equivalence**
1. Show `d(x,y) ≤ ε ↔ c*d(x,y) ≤ c*ε` for `c>0`.
2. Deduce the threshold graph is unchanged up to relabeling of the parameter.
3. Transfer criticality.

Most promising because it exposes the combinatorial invariant behind the theorem.

**Strategy B: direct profile identity**
1. Prove `φ_{d'}(c ε) = φ_d(ε)`.
2. Conclude maxima/phase-transition points scale linearly.
3. Normalize by diameter.

**Strategy C: use catalog existence theorem abstractly**
1. Extract an existence witness for `ε*`.
2. Push it through scaling.
3. Repackage as normalized invariance.

This depends more heavily on the exact catalog API.

---

## Theorem 3: A graph-theoretic lower bound connecting locality phase transition to cycle complexity

Exploit `graphCycleRank_pos_of_connected_many_edges` to prove that once a threshold graph crosses a combinatorial edge-density barrier, the proof-dependency neighborhood necessarily acquires nontrivial cycle rank. This is the topological mechanism behind the phase transition.

### Precise mathematical statement

For a finite theorem family with threshold graph `G_ε`, if `G_ε` is connected and has strictly more edges than vertices minus one, then its cycle rank is positive. Therefore any critical threshold at which edge surplus first appears marks the onset of non-tree-like dependency complexity.

This is likely already close to the catalog theorem, but your task is to **lift it into the proof-topology setting** by defining the threshold graph generated from theorem distances/locality and proving the corollary there.

### Suggested Lean 4 target

```lean
theorem thresholdGraph_cycleRank_pos_of_connected_edge_surplus
  {α : Type _} [Fintype α] [DecidableEq α]
  (d : α → α → ℚ) (ε : ℚ)
  (hconn : Graph.Connected (thresholdGraph d ε))
  (hedge : Fintype.card (Sym2 α) <  -- replace with actual edge-count formulation
           edgeCount (thresholdGraph d ε) + Fintype.card α) :
  0 < cycleRank (thresholdGraph d ε) := ...
```

Or, more realistically, state it as a corollary of the catalog theorem with your threshold graph as input.

### Why this matters
This theorem gives a mechanistic explanation: high-locality regions are difficult not merely because they are “far” but because they enter a **cycle-rich regime**, where search spaces gain redundant and interacting dependency loops. This is the exact kind of structural explanation the field lacks.

### Proof strategy options

**Strategy A: instantiate the catalog theorem**
1. Define `thresholdGraph d ε`.
2. Prove finiteness/connectedness/edge surplus hypotheses.
3. invoke `graphCycleRank_pos_of_connected_many_edges`.

Most promising and aligned with the lineage.

**Strategy B: direct cyclomatic-number calculation**
1. Use the formula `β₁ = |E| - |V| + c`.
2. Under connectedness, `c = 1`.
3. Conclude positivity from `|E| > |V| - 1`.

This may require more graph infrastructure than the catalog theorem already provides.

---

## Theorem 4: Cross-domain theorem — universality candidate via dimensionless threshold band

You must include at least one theorem connecting to a different domain. The strongest bridge here is:

**proof complexity ↔ statistical physics**

Define the normalized threshold as an order parameter and prove a finite-space universality principle under metric scaling and graph-isomorphic threshold filtrations.

### Precise statement

If two finite theorem spaces have threshold graph filtrations that are isomorphic after reparameterization by normalized distance, then their normalized critical threshold sets agree.

This is a true cross-domain concept: it is mathematically analogous to universality classes in phase transitions.

### Suggested Lean 4 target

```lean
theorem normalizedCriticalThreshold_eq_of_filtration_isomorphism
  {α β : Type _} [Fintype α] [Fintype β]
  (dα : α → α → ℚ) (dβ : β → β → ℚ)
  (hiso : ∀ t, thresholdGraphNormalized dα t ≃g thresholdGraphNormalized dβ t) :
  criticalSetNormalized dα = criticalSetNormalized dβ := ...
```

If this is too ambitious, prove the one-direction implication for a chosen notion of criticality.

### Why this is revolutionary
This is no longer “metrics on theorem corpora.” It is the beginning of a **universality theory of proof search**, with the same conceptual role that renormalization ideas play in physics.

---

## Strong prediction to test

You should still test the empirical hypothesis:

> The high-locality quartile has timeout rate at least twice the low-locality quartile, with Fisher exact test p-value < 0.01.

But elevate it mathematically by framing it as a falsifiable scientific law candidate:

### Falsifiable conjecture
For any Mathlib domain `D` with at least 100 theorem tasks and a nondegenerate theorem-distance metric,
\[
\frac{\operatorname{TimeoutRate}(Q_{\mathrm{high}})}{\operatorname{TimeoutRate}(Q_{\mathrm{low}})} \ge 2
\]
and the associated Fisher exact test on the 2×2 quartile/timeout table satisfies `p < 0.01`.

### Clear computational disproof test
A single domain with:
- at least 100 tasks,
- valid extracted locality scores,
- quartile ratio `< 2`, or
- Fisher p-value `≥ 0.01`

is a disproof.

This is exactly the kind of falsifiable prediction the cycle needs.

---

## Universality conjecture to formalize and test

### Conjecture
For every Mathlib domain with at least 100 theorems, the normalized cyclomatic density profile is unimodal, and every critical threshold `ε*` satisfies
\[
\theta = \frac{\varepsilon^*}{\operatorname{diam}(S)} \in [0.2, 0.6].
\]

### Computational test protocol
Use at least 5 domains:
- `GroupTheory`
- `RingTheory`
- `Topology`
- `MeasureTheory`
- `Analysis`

For each:
1. compute all distinct metric distances,
2. build threshold graphs at each distance,
3. compute cyclomatic density profile `φ(ε)`,
4. test unimodality,
5. compute `ε*/diam(S)`.

A single domain violating unimodality or the interval bound refutes the conjecture.

---

## Lean-oriented formalization targets

You asked for precise theorem statements with type signatures. Here is a concrete list of plausible targets. Adapt exact namespaces to the catalog API, but keep the mathematical content.

```lean
structure TimeoutDataset (α : Type _) [Fintype α] [DecidableEq α] where
  locality : α → ℚ
  timeout : α → Bool

def avgOn {α : Type _} [DecidableEq α] (s : Finset α) (f : α → ℚ) : ℚ := ...

def lowerQuartileFromScore {α : Type _} [Fintype α] [DecidableEq α]
  (L : α → ℚ) : Finset α := ...

def upperQuartileFromScore {α : Type _} [Fintype α] [DecidableEq α]
  (L : α → ℚ) : Finset α := ...

theorem avg_timeoutProp_upperQuartile_ge_lowerQuartile
  {α : Type _} [Fintype α] [DecidableEq α]
  (L : α → ℚ) (p : α → ℚ)
  (hprob : ∀ a, 0 ≤ p a ∧ p a ≤ 1)
  (hmono : ∀ {a b}, L a ≤ L b → p a ≤ p b) :
  avgOn (upperQuartileFromScore L) p ≥ avgOn (lowerQuartileFromScore L) p := ...

def normalizedCriticalThreshold
  {α : Type _} [Fintype α]
  (d : α → α → ℚ) (εstar diam : ℚ) : ℚ := εstar / diam

theorem normalizedCriticalThreshold_scale_invariant
  {α : Type _} [Fintype α]
  (d : α → α → ℚ) (εstar diam c : ℚ)
  (hc : 0 < c) (hdiam : 0 < diam) :
  normalizedCriticalThreshold (fun x y => c * d x y) (c * εstar) (c * diam)
    = normalizedCriticalThreshold d εstar diam := by
  field_simp [normalizedCriticalThreshold]

def thresholdGraph {α : Type _} [Fintype α] [DecidableEq α]
  (d : α → α → ℚ) (ε : ℚ) : SimpleGraph α := ...

theorem thresholdGraph_cycleRank_pos_of_connected_edge_surplus
  {α : Type _} [Fintype α] [DecidableEq α]
  (d : α → α → ℚ) (ε : ℚ)
  (hconn : (thresholdGraph d ε).Connected)
  (hsurplus : Fintype.card α - 1 < edgeCount (thresholdGraph d ε)) :
  0 < cycleRank (thresholdGraph d ε) := ...

theorem thresholdGraph_scale_equiv
  {α : Type _} [Fintype α] [DecidableEq α]
  (d : α → α → ℚ) (ε c : ℚ)
  (hc : 0 < c) :
  thresholdGraph (fun x y => c * d x y) (c * ε) = thresholdGraph d ε := ...
```

At least three of your proved theorems must use genuinely nontrivial tactics: induction over sorted lists or finite sets, `rcases` on quartile decomposition, `by_contra` in average-comparison arguments, `field_simp` for scale invariance, and multi-step `calc` chains.

Do not pad with easy lemmas.

---

## Proof architecture

### Path A: finite order statistics + graph filtration
This is the most promising route.

1. Define quartiles by rank in a sorted list of locality scores.
2. Prove average comparison for monotone functions over lower/upper quartiles.
3. Define threshold graphs from the theorem metric.
4. Lift `graphCycleRank_pos_of_connected_many_edges` to threshold graphs.
5. Prove scaling invariance and normalized threshold invariance.

Why this is strongest:
- It gives reusable infrastructure.
- It creates theorem statements independent of any one dataset.
- It turns the empirical story into a mathematical framework.

### Path B: filtration-first approach
1. Start from `critical_threshold_exists_finite`.
2. Define normalized threshold and prove scale invariance immediately.
3. Then connect quartile locality to graph-density/cycle-rank regimes.

Why this may work:
- It leverages catalog theorems early.
- It keeps the narrative centered on phase transitions.

Risk:
- It may leave the quartile predictor under-theorized.

### Path C: statistical abstraction
1. Formalize 2×2 contingency tables and Fisher-style monotonic effects abstractly.
2. Prove structural inequalities under monotone hazard assumptions.
3. Connect these to locality scores and threshold topology.

Why it is interesting:
- It imports exact-test thinking into formal mathematics.

Risk:
- Full Fisher exact formalization may be too implementation-heavy for this cycle unless done carefully.

---

## Cross-domain connections you must emphasize

1. **Proof complexity ↔ Network science**
   - Locality creates a graph filtration.
   - Timeout behavior corresponds to navigability or congestion in dependency networks.

2. **Proof complexity ↔ Statistical physics**
   - Critical threshold acts as an order parameter.
   - Cycle-rank onset resembles emergence of frustrated loops / phase transitions.
   - Normalized threshold suggests universality classes.

3. **Formal theorem corpora ↔ Topological data analysis**
   - Threshold graphs and cyclomatic density are 1-dimensional persistent-topological summaries.
   - You are effectively building a TDA of theorem space.

4. **Automated reasoning ↔ Hypothesis testing**
   - Fisher exact test is not window dressing: it operationalizes whether the structural law is real or noise.

These are not decorative. Use them to frame the mathematics.

---

## Application keywords

proof complexity, theorem dependency graphs, threshold graph filtration, cyclomatic density, cycle rank, locality metrics, empirical quartiles, Fisher exact test, universality, phase transition, order parameter, topological data analysis, network science, automated theorem proving, search hardness, structural predictors, finite metric spaces, graph filtrations, statistical mechanics of proof search

---

## Deliverables — all mandatory

You must produce ALL of the following:

1. **Lean development**
   - At least 3 substantial new theorems with deep proof tactics.
   - At least 1 new mathematical definition/structure not in the catalog.
   - Minimal `sorry`; do not hide the difficult core behind placeholders.

2. **A verified algorithm or computational method**
   - Implement a method to:
     - extract or ingest theorem dependency/locality data,
     - compute quartiles,
     - compute timeout-rate ratios,
     - compute threshold-graph profiles and normalized critical thresholds.
   - The algorithm must be specified clearly enough to be reproduced.

3. **`demo.py`**
   - Interactive or command-line demonstration that:
     - loads a sample dataset,
     - computes quartile partitions,
     - reports timeout-rate ratio,
     - computes a threshold profile,
     - visualizes or prints the estimated critical threshold and normalized threshold.

4. **`FUTURE_DIRECTIONS.md`**
   Include 3–5 falsifiable scientific hypotheses, each with:
   - exact statement,
   - test protocol,
   - criterion for refutation.
   
   At least one should concern:
   - universality of normalized thresholds,
   - cycle-rank onset as predictor of timeout,
   - robustness under alternative theorem-distance metrics.

5. **`RESEARCH_PAPER.md`**
   A standalone scientific paper that explains:
   - the mathematical definitions,
   - theorems proved,
   - computational experiments,
   - why the structural predictor matters,
   - what new field this opens.
   
   It must be readable without code access.

6. **`ARTICLE.md`**
   Scientific American style.
   Explain the discovery and why it matters to mathematics and AI-assisted reasoning.
   Do **not** focus on formal verification machinery; focus on the ideas, topology, and scientific significance.

---

## Final challenge

Do not settle for “we measured a correlation.” That is not enough.

The true target is to show that **proof difficulty has a topological phase structure**, and that locality is not merely a feature but an order parameter for the emergence of cycle-rich dependency regimes that defeat bounded search.

If you can formalize even a modest fragment of that vision — especially the quartile monotonicity theorem, threshold scaling law, and cycle-rank onset theorem — you will have created a new language for theorem difficulty itself.

### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  Show the math working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses, including 1-2 grand_challenge paradigm-shifting conjectures
and 2-3 solid extensions building directly on Catalog theorems.
MUST begin with a ## Synthesis section tying all directions together.
Each direction must use the structured format with explicit fields:
**Conjecture**, **Test**, **Impact**, **Catalog References**,
**Proof Strategy**, **Domain Bridges**, **Lineage**, **Ambition**.
Reference specific Catalog theorems by file path. Every hypothesis
must be daring enough to matter and specific enough to fail.


────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Pythagorean
Research mode: prove
