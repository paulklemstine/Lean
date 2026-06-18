## Assignment: Direction 5: Neural Proof Guidance via Cycle Pressure Features

**Mode:** `prove` + `discover`

You are not being asked for a mere empirical ML pipeline. You are being asked to extract a mathematically rigid theory of **cycle pressure as a proof-theoretic complexity invariant**, and then to prove theorems strong enough that an eventual neural system is forced to respect them. The engineering experiment is downstream. The breakthrough is to make “topological hardness of theorem space” into a formal predictive theory.

Build on the proof-theoretic topology catalog, especially everything in:

- `Speculative/ProofTheoreticTopology/`
- `Catalog/Pythagorean/ProofTheoreticTopology/CoreCollapseEntropy.lean`

and use those results not as decoration, but as lemmas in a new structural theory connecting:

- local graph topology of dependency neighborhoods,
- entropy / collapse invariants,
- proof-search branching complexity,
- and feature design for graph-guided theorem proving.

Your goal is to formalize a theorem-level analogue of statistical mechanics: **local cyclic congestion in theorem graphs creates irreducible search pressure**, and any guidance architecture that ignores it is information-theoretically incomplete on cycle-dense regions.

---

## Core Vision

The conjecture about “10% better proof success” is not itself the theorem. It is the experimentally testable shadow of a deeper mathematical claim:

> In proof dependency graphs, local cycle structure is not noise. It is a compressed sufficient statistic for a genuine obstruction to greedy proof search.

If you can prove this in a mathematically sharp form, you open a new field:
**proof-topological learning theory**.

This would create a rigorous bridge between:

- automated theorem proving,
- topological graph invariants,
- complexity of search,
- entropy methods,
- and representation learning.

It would also generate a new class of architecture priors for theorem-proving AI, not by black-box tuning, but by theorem-driven feature design.

---

## Precise Formal Target

Define a new mathematical structure formalizing local cycle pressure on finite proof graphs.

You should work with finite simple graphs or finite directed dependency graphs, depending on what the catalog already supports best. If directed graph infrastructure is weak, first prove the theory for undirected local dependency skeletons, then explain in the paper how to lift to directed proof graphs.

### New definitions to introduce

At minimum, define one genuinely new concept, for example:

1. **Local cycle pressure** of radius `r` at vertex `v`:
   a weighted excess of edges over tree capacity in the radius-`r` neighborhood.

2. **Cycle-pressure profile**:
   the function `r ↦ lcp(G, v, r)`.

3. **Pressure-monotone graph region**:
   a graph where cycle pressure is nondecreasing under neighborhood expansion.

4. **Proof-guidance sufficiency gap**:
   a formal discrepancy between two scoring rules, one using only degree/local size and one using cycle-aware features.

A concrete Lean-friendly definition is:

- Let `ball G v r` be the finite set of vertices within graph distance at most `r`.
- Let `inducedEdges G S` count edges in the induced subgraph on `S`.
- Define
  \[
  \operatorname{lcp}(G,v,r) := \#E(G[S]) - (\#S - 1),
  \quad S = \mathrm{ball}(G,v,r),
  \]
  i.e. the cyclomatic excess of the local neighborhood over a tree.

This is mathematically natural: it is exactly the local first Betti-number surrogate for connected neighborhoods.

If connectivity issues make this awkward, use
\[
\operatorname{lcp}(G,v,r) := \#E(G[S]) - \#S + c(S),
\]
where `c(S)` is the number of connected components of the induced subgraph. That is the true cycle rank.

---

## Exact Theorem Statements to Formalize

You must prove at least 3 nontrivial theorems. Here is the recommended theorem package.

### Theorem 1: Tree-characterization by vanishing local cycle pressure
This should be the foundational structural theorem.

**Mathematical statement.**
For a finite connected graph `G`, the following are equivalent:

1. `G` is acyclic.
2. For every vertex `v` and every radius `r`, `lcp(G,v,r) = 0`.
3. For every vertex `v`, the global-radius local cycle pressure vanishes.

This is not trivial: it identifies local cycle pressure as a complete obstruction to tree-likeness.

**Lean 4 target signature sketch**
```lean
theorem isAcyclic_iff_localCyclePressure_eq_zero
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) :
  G.IsAcyclic ↔
    ∀ v : V, ∀ r : ℕ, localCyclePressure G v r = 0
```

If `SimpleGraph.IsAcyclic` is unavailable in the exact form, replace with an equivalent graph-theoretic predicate already present in Mathlib or formalize a finite-graph acyclicity notion.

A weaker but still powerful version is:

```lean
theorem localCyclePressure_eq_zero_of_tree
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V)
  (hG : G.IsAcyclic) :
  ∀ v : V, ∀ r : ℕ, localCyclePressure G v r = 0
```

and conversely:

```lean
theorem isAcyclic_of_localCyclePressure_eq_zero
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V)
  (h : ∀ v : V, ∀ r : ℕ, localCyclePressure G v r = 0) :
  G.IsAcyclic
```

### Theorem 2: Monotonicity under induced neighborhood growth
This theorem makes cycle pressure a usable feature, not just a diagnostic.

**Mathematical statement.**
If radius-`r` and radius-`r+1` neighborhoods around `v` are connected, then local cycle pressure is monotone:
\[
\operatorname{lcp}(G,v,r) \le \operatorname{lcp}(G,v,r+1).
\]

More generally, prove a sharp increment formula:
\[
\operatorname{lcp}(G,v,r+1)-\operatorname{lcp}(G,v,r)
=
\Delta E - \Delta V + \Delta c,
\]
where the deltas are computed from the newly added shell.

This is the theorem that makes local cycle pressure interpretable as a cumulative obstruction.

**Lean 4 target signature sketch**
```lean
theorem localCyclePressure_mono
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (v : V) :
  Monotone (localCyclePressure G v)
```

If full monotonicity is false without hypotheses, state the correct conditional version:

```lean
theorem localCyclePressure_mono_of_connected_balls
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (v : V)
  (hconn : ∀ r, ballConnected G v r) :
  Monotone (localCyclePressure G v)
```

or the increment identity:

```lean
theorem localCyclePressure_succ
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (v : V) (r : ℕ) :
  localCyclePressure G v (r+1) - localCyclePressure G v r
    = shellEdgeGain G v r - shellVertexGain G v r + shellComponentCorrection G v r
```

This is likely the most mathematically fertile theorem in the project.

### Theorem 3: Entropy / collapse lower bound from cycle pressure
This is the field-opening theorem. It connects your new invariant to the catalog’s entropy-collapse framework.

**Mathematical statement.**
There exists a theorem of the following shape:

> If a finite proof graph region has local cycle pressure at least `k`, then its collapse entropy / branching complexity / obstruction index is bounded below by a monotone function of `k`.

You must instantiate this using whichever entropy-like quantity is already certified in `CoreCollapseEntropy.lean`.

A schematic statement:

```lean
theorem collapseEntropy_lower_bound_of_localCyclePressure
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (v : V) (r : ℕ) :
  localCyclePressure G v r ≤ collapseEntropy G (ballSubgraph G v r)
```

If the existing entropy quantity has codomain `ℝ` or `ℚ`, cast appropriately and prove a real-valued lower bound. If the catalog gives only a collapse-count or entropy proxy, adapt the theorem to that exact object.

This theorem says cycle pressure is not an ad hoc feature: it is a lower bound for a previously formalized hardness invariant.

### Theorem 4: Feature separation theorem for guidance statistics
This is the cross-domain theorem tying graph topology to learning-theoretic expressivity.

**Mathematical statement.**
Construct two finite graphs `G₁, G₂` and vertices `v₁, v₂` such that:

- the local neighborhoods have the same size and degree profile up to radius `r`,
- but different local cycle pressure,
- and hence different entropy/collapse lower bounds.

This proves that degree-only local statistics cannot recover the hardness signal captured by cycle pressure.

**Lean 4 target signature sketch**
```lean
theorem exists_same_degreeProfile_diff_cyclePressure :
  ∃ (V1 V2 : Type) (_ : Fintype V1) (_ : Fintype V2)
    (_ : DecidableEq V1) (_ : DecidableEq V2)
    (G1 : SimpleGraph V1) (G2 : SimpleGraph V2)
    (v1 : V1) (v2 : V2) (r : ℕ),
      sameDegreeProfileUpTo G1 v1 G2 v2 r ∧
      localCyclePressure G1 v1 r ≠ localCyclePressure G2 v2 r
```

This theorem is the mathematical reason cycle-aware neural features should help: they distinguish states that degree-only encodings provably conflate.

Even a radius-1 or radius-2 explicit construction would be excellent.

---

## Most Promising Proof Strategies

You must include multi-step proofs, not one-line reductions. At least 3 theorems should require induction, `rcases`, `by_contra`, `field_simp`, or substantial `calc` chains.

### Strategy A: Cyclomatic-number localization
**Best overall path.**

1. Define local cycle pressure as induced-edge count minus vertex count plus component count.
2. Prove finite-subgraph identities relating this quantity to the standard cycle rank / cyclomatic number.
3. Use known facts:
   - trees satisfy `|E| = |V| - 1`,
   - connected acyclic finite graphs are characterized by this equality,
   - induced subgraphs of acyclic graphs are acyclic.
4. Deduce Theorem 1 and monotonicity/increment formulas for Theorem 2.

**Why this is promising:**  
It is robust, combinatorial, and should mesh well with finite graph lemmas already in Mathlib. It also naturally interfaces with entropy lower bounds because cyclomatic excess is an additive obstruction measure.

### Strategy B: Neighborhood filtration and shell decomposition
Use the filtration
\[
B_0(v) \subseteq B_1(v) \subseteq \cdots \subseteq B_r(v).
\]
Then:

1. Define shell vertices and shell edges.
2. Express local cycle pressure recursively.
3. Prove the increment formula by counting how many “extra” shell edges fail to preserve treeness.
4. Use induction on `r` for monotonicity and for any lower bound theorem.

**Why this is promising:**  
This gives the most interpretable theorem statements for ML applications. It turns cycle pressure into a recursively computable feature and makes the verified algorithm straightforward.

### Strategy C: Entropy transfer via catalog hardness invariants
Use the existing entropy-collapse theory as a black-box hardness certificate.

1. Identify the exact theorem in `CoreCollapseEntropy.lean` that lower-bounds collapse difficulty by graph redundancy, core size, or cycle count.
2. Prove that local cycle pressure injects into that certified quantity by an induced-subgraph comparison.
3. Lift local graph topology to proof-search hardness.

**Why this is promising:**  
This is the decisive cross-catalog bridge. It turns your new invariant into something already semantically meaningful in the proof-topology library.

**Recommended order:** A → B → C.  
First make the invariant real. Then make it computable. Then make it scientifically consequential.

---

## Cross-Domain Connections You Must Exploit

Do not leave this as “graphs for ML.” Push the mathematics across domains.

### 1. Algebraic topology
Local cycle pressure is a graph-theoretic shadow of a local first Betti number. Make this explicit in the paper and, if feasible, prove a theorem identifying `lcp` with the cycle rank of the induced neighborhood graph.

**Keywords:** first Betti number, homology surrogate, local topological complexity.

### 2. Statistical mechanics / entropy
Interpret high-cycle regions as high-frustration states in a constraint system: many locally consistent continuations, few globally collapsing ones. This is exactly why entropy and search branching interact.

**Keywords:** entropy landscape, frustration, metastability, free-energy barrier.

### 3. Learning theory / representation sufficiency
The feature separation theorem should be framed as a **representation-theoretic impossibility result**: degree-only local summaries are insufficient statistics for proof-search hardness.

**Keywords:** sufficient statistics, feature identifiability, expressivity separation, inductive bias.

### 4. Automated reasoning / proof complexity
Cycle pressure should be linked to the existence of multiple dependency loops, nontrivial lemma reuse, and delayed collapse of search branches.

**Keywords:** branching complexity, proof-state geometry, tactic ambiguity, search obstruction.

---

## Verified Algorithmic Deliverable

You must produce a verified computational method, not just theorem statements.

### Required algorithm
Implement a certified function computing local cycle pressure on finite graphs / finite theorem neighborhoods.

A Lean target sketch:

```lean
def localCyclePressureCompute
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (v : V) (r : ℕ) : ℕ := ...
```

and prove correctness:

```lean
theorem localCyclePressureCompute_correct
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (v : V) (r : ℕ) :
  localCyclePressureCompute G v r = localCyclePressure G v r
```

If subtraction forces an integer codomain, use `ℤ` instead of `ℕ`.

Then define a ranking score for theorem nodes:

```lean
def cycleAwareScore
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (v : V) : ℤ :=
  α * localCyclePressure G v r + β * degree G v + γ * localEntropyProxy G v r
```

You do not need a neural net in Lean. You do need a mathematically certified feature extractor and at least one theorem justifying why it contains information absent from simpler scores.

---

## Demo Requirements

Produce `demo.py` that:

1. Constructs small explicit graphs representing:
   - a tree-like theorem region,
   - a single-cycle region,
   - a dense cyclic region.
2. Computes local cycle pressure by radius.
3. Visualizes the pressure profile.
4. Demonstrates a pair of neighborhoods with equal degree statistics but different cycle pressure.
5. If possible, simulates a toy proof-search heuristic showing how a cycle-aware score changes expansion order.

This demo should make the theorem visually obvious.

---

## Falsifiable Scientific Hypotheses for `FUTURE_DIRECTIONS.md`

You must include 3–5 testable hypotheses. At least these should appear, sharpened into falsifiable form.

1. **Cycle-pressure benefit hypothesis.**  
   On theorem graphs stratified by top decile of local cycle pressure, any tactic-prediction model augmented with `(lcp, cycle rank, shell growth)` achieves at least 10% relative improvement in proof success over a degree-only baseline.

   **Test:** Controlled train/test split on theorem neighborhoods.  
   **Refutation:** No significant gain at `p ≤ 0.05`.

2. **No-harm tree regime hypothesis.**  
   On bottom decile cycle-pressure theorems, cycle-aware augmentation changes success by at most 2% in either direction.

   **Test:** Stratified evaluation on low-pressure instances.  
   **Refutation:** Significant degradation beyond 2%.

3. **Entropy mediation hypothesis.**  
   The predictive advantage of cycle-aware features is statistically mediated by certified collapse-entropy proxies from the catalog.

   **Test:** Ablation and mediation analysis.  
   **Refutation:** Entropy proxy contributes no explanatory power.

4. **Feature separation robustness hypothesis.**  
   There exist theorem-neighborhood pairs in Mathlib with matching local degree statistics up to radius 2 but differing proof difficulty, explained by differing cycle pressure.

   **Test:** Search over extracted theorem graphs.  
   **Refutation:** No such pairs found in a sufficiently large corpus.

5. **Radius saturation hypothesis.**  
   Most predictive gain from cycle pressure saturates by radius 3.

   **Test:** Compare feature sets using radii 1,2,3,4.  
   **Refutation:** Performance continues increasing substantially beyond radius 3.

---

## Required Deliverables

You must produce **all** of the following:

### 1. Lean development
A file with:
- at least one novel definition,
- at least 3 substantial theorems,
- nontrivial proofs using induction / `rcases` / `by_contra` / `calc` / counting arguments,
- minimal `sorry`.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the new invariant,
- the main theorems,
- why cycle pressure matters for proof search,
- the bridge to entropy-collapse theory,
- the feature separation principle,
- and concrete next experiments.

This paper must be understandable without reading code.

### 3. `ARTICLE.md`
Write this in Scientific American style:
- vivid,
- concept-driven,
- broad-audience accessible,
- focused on the mathematics and AI significance.

**Taboo:** do not make the article about formal verification infrastructure. Make it about the discovery: topology hidden inside mathematical reasoning.

### 4. `FUTURE_DIRECTIONS.md`
Include 3–5 falsifiable hypotheses with:
- exact predicted effect,
- clear test protocol,
- explicit refutation criterion.

### 5. Verified algorithm / computational method
A certified local-cycle-pressure computation pipeline, plus at least one mathematically justified ranking score.

### 6. `demo.py`
Interactive or script-based demonstration of the pressure profile and feature separation phenomenon.

---

## Application Keywords

Use these throughout the paper and article where appropriate:

- proof-topological learning theory
- local cycle pressure
- theorem-space geometry
- proof-search hardness
- collapse entropy
- graph neural guidance
- sufficient statistics for reasoning
- topological inductive bias
- cycle-aware tactic prediction
- dependency graph complexity
- local Betti surrogate
- search frustration
- theorem neighborhood filtration
- expressivity separation
- AI for mathematics

---

## Standard of Success

Success is **not** “we added a graph feature.”  
Success is:

1. You define a mathematically inevitable invariant.
2. You prove it detects a real obstruction invisible to simpler summaries.
3. You connect it to certified hardness/entropy theory already in the catalog.
4. You extract a verified feature computation that can drive real proof guidance.
5. You formulate experiments whose failure would genuinely falsify the theory.

That would transform an engineering hunch into a new mathematical science of proof guidance.

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
