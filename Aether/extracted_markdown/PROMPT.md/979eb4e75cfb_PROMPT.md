## Assignment: Homological Phase Transition in Automated Conjecture Spaces

**Mode:** discover / prove / formalize

Aristotle, do not nibble at the edges of this idea. Turn it into a rigorous prototype of a new science: **proof-theoretic topology**. The target is not merely to “analyze conjecture spaces,” but to formalize a mathematically sharp bridge between:

- bounded-complexity theorem generation,
- semantic similarity metrics on formal statements,
- clique/Vietoris–Rips topology of similarity graphs,
- and the onset of proof-theoretic hardness.

The breakthrough is to show that **topological complexity in semantic statement spaces is not epiphenomenal**: it can be made into a certified invariant that predicts when routine proof search breaks down.

Your mission is to prove theorems that are mathematically nontrivial **even before** the full metamathematical conjecture is resolved. Build a formal scaffold in Lean 4 that makes the conjecture scientifically testable and mathematically fertile.

---

## Core Vision

Construct a finite, parameterized family of “conjecture spaces” \( \mathcal S_n \), where elements are bounded-complexity algebraic/combinatorial statements represented by semantic feature vectors or feature sets. From these, define:

1. a **semantic dissimilarity** \(d_n\),
2. a threshold graph \(G_{n,\varepsilon}\) on statements with edges when \(d_n \le \varepsilon\),
3. the clique complex / Vietoris–Rips complex \(VR(\mathcal S_n,\varepsilon)\),
4. a notion of **proof-search hardness profile** \(h_n : \mathcal S_n \to \mathbb N \cup \{\infty\}\),
5. and a topological order parameter detecting the birth of nontrivial \(H_1\) or higher connectivity obstructions.

Then prove theorems showing that, under explicit combinatorial hypotheses, **sharp graph-theoretic connectivity transitions force topological transitions**, and that monotone hardness functionals correlate with these transitions.

This is the right level of ambition because it avoids fake Gödelian overreach while still opening a field: a formal, computable theory of **topological diagnostics for theorem proving**.

---

## New Mathematical Structures to Introduce

You must define at least one genuinely new structure. I recommend introducing all three:

### 1. SemanticFeatureSpace
A finite space of statements with a feature map into finite sets or finite-support vectors.

```lean
structure SemanticFeatureSpace (α β : Type _) [Fintype α] where
  featureSet : α → Finset β
```

### 2. SemanticDistance
A computable dissimilarity based on symmetric difference or weighted feature discrepancy.

```lean
def semanticDist {α β : Type _} [DecidableEq β]
    (S : α → Finset β) (x y : α) : Nat :=
  ((S x) \ (S y)).card + ((S y) \ (S x)).card
```

This is intentionally discrete and Lean-friendly. It gives you a bona fide metric-like object on finite spaces.

### 3. HardnessProfile / TopologicalOrderParameter
A monotone summary statistic over threshold graphs or complexes.

```lean
structure HardnessProfile (α : Type _) where
  hardness : α → WithTop Nat

def firstBettiSurrogate {α : Type _} [Fintype α] (G : SimpleGraph α) : Int :=
  (G.edgeFinset.card : Int) - Fintype.card α + connectedComponentCount G
```

Even if full homology is too heavy for the first pass, the **cyclomatic number**
\[
\beta_1^{\mathrm{graph}} = |E| - |V| + c
\]
is already a profound surrogate: it is the first Betti number of the graph as a 1-dimensional CW complex, and a lower-dimensional shadow of clique-complex topology.

---

## Precise Theorem Targets

You need at least 3 substantial theorems. Here is a coherent package.

---

### Theorem 1: Monotonicity of semantic threshold graphs

If \(\varepsilon \le \varepsilon'\), then every edge at threshold \(\varepsilon\) remains an edge at threshold \(\varepsilon'\). Hence the threshold graph filtration is monotone.

#### Mathematical statement
For any finite semantic feature space with distance \(d\),
\[
\varepsilon \le \varepsilon' \implies E(G_\varepsilon) \subseteq E(G_{\varepsilon'}).
\]

#### Lean 4 target signature
```lean
def semanticGraph {α β : Type _} [Fintype α] [DecidableEq α] [DecidableEq β]
    (S : α → Finset β) (ε : Nat) : SimpleGraph α where
  Adj x y := x ≠ y ∧ semanticDist S x y ≤ ε
  symm := by
    intro x y h
    rcases h with ⟨hxy, hε⟩
    constructor
    · exact Ne.symm hxy
    · -- nontrivial symmetry of semanticDist
      sorry
  loopless := by
    intro x h
    exact h.1 rfl

theorem semanticGraph_mono
    {α β : Type _} [Fintype α] [DecidableEq α] [DecidableEq β]
    (S : α → Finset β) {ε ε' : Nat} (h : ε ≤ ε') :
    ∀ ⦃x y : α⦄, (semanticGraph S ε).Adj x y → (semanticGraph S ε').Adj x y := by
  intro x y hxy
  rcases hxy with ⟨hne, hdist⟩
  exact ⟨hne, le_trans hdist h⟩
```

#### Why this matters
This theorem creates the formal filtration needed for persistent topology. Without it, there is no mathematically legitimate “phase transition” story.

---

### Theorem 2: Connectivity threshold from common-core features

Assume there exists a feature core \(C\) such that every statement differs from \(C\) by at most \(r\) feature edits. Then for threshold \(2r\), the semantic graph is complete, hence connected and topologically collapsed at the graph level.

#### Mathematical statement
Let \(S_x\) be the feature set of statement \(x\). If there exists a finite set \(C\) such that
\[
|S_x \triangle C| \le r \quad \forall x,
\]
then for all \(x,y\),
\[
|S_x \triangle S_y| \le 2r.
\]
Hence \(G_{2r}\) is complete.

This is a clean “high-similarity phase” theorem.

#### Lean 4 target signature
```lean
theorem semanticDist_le_twice_of_common_core
    {α β : Type _} [Fintype α] [DecidableEq β]
    (S : α → Finset β) (C : Finset β) (r : Nat)
    (hC : ∀ x, semanticDist (fun _ => C) x x + ((S x) \ C).card + (C \ (S x)).card ≤ r) :
    ∀ x y, semanticDist S x y ≤ 2 * r := by
  intro x y
  -- prove via symmetric-difference triangle inequality
  sorry
```

A cleaner formulation may first define
```lean
def symmDiffCard (A B : Finset β) : Nat := ((A \ B).card + (B \ A).card)
```
and prove the triangle inequality:
```lean
theorem symmDiffCard_triangle
    (A B C : Finset β) :
    symmDiffCard A C ≤ symmDiffCard A B + symmDiffCard B C := by
  sorry
```
Then instantiate with \(A=Sx, B=C, C=Sy\).

#### Consequence theorem
```lean
theorem semanticGraph_complete_of_common_core
    {α β : Type _} [Fintype α] [Nonempty α] [DecidableEq α] [DecidableEq β]
    (S : α → Finset β) (C : Finset β) (r : Nat)
    (hball : ∀ x, symmDiffCard (S x) C ≤ r) :
    ∀ x y, x ≠ y → (semanticGraph S (2 * r)).Adj x y := by
  intro x y hxy
  constructor
  · exact hxy
  ·
    have hx := hball x
    have hy := hball y
    -- triangle inequality through C
    sorry
```

#### Why this is a breakthrough
This gives an explicit **certified collapse threshold**. It says that when a conjecture family is organized around a common semantic core, the filtration must eventually enter a trivialized phase. This is the rigorous counterpart of “all low-complexity conjectures look alike.”

---

### Theorem 3: Separation theorem yielding disconnected low-threshold phase

Assume the statement family splits into two semantic clusters \(A,B\), each internally tight but externally far:
- internal distances \(\le r\),
- cross distances \(> R\), with \(r < R\).

Then for any threshold \(\varepsilon < R\), there are no cross edges; if both clusters are nonempty, the graph is disconnected. This is the low-complexity fragmented phase.

#### Mathematical statement
If \(X = A \sqcup B\) and
\[
d(x,y) \le r \text{ for } x,y \in A \text{ or } x,y \in B,
\qquad
d(a,b) > R \text{ for } a\in A,\ b\in B,
\]
then for all \(\varepsilon < R\), \(G_\varepsilon\) has at least two connected components.

#### Lean 4 target signature
```lean
theorem disconnected_of_cluster_separation
    {α β : Type _} [Fintype α] [DecidableEq α] [DecidableEq β]
    (S : α → Finset β) (A B : Finset α) (R ε : Nat)
    (hcover : ∀ x : α, x ∈ A ∨ x ∈ B)
    (hdisj : Disjoint A B)
    (hsep : ∀ a b, a ∈ A → b ∈ B → R < semanticDist S a b)
    (hε : ε < R)
    (hA : A.Nonempty) (hB : B.Nonempty) :
    ¬ SimpleGraph.Connected (semanticGraph S ε) := by
  intro hconn
  rcases hA with ⟨a, ha⟩
  rcases hB with ⟨b, hb⟩
  -- use connectedness to force a path, then show first edge crossing A/B violates separation
  sorry
```

#### Why this matters
This theorem gives the **fragmented phase**. Together with Theorem 2, you now have a genuine finite-size phase-transition schema: disconnected at low threshold, complete at high threshold.

---

### Theorem 4: Emergence of nontrivial cycle rank in an intermediate regime

Prove a graph-theoretic Betti theorem: if a finite connected threshold graph has at least \(|V|\) edges, then its cyclomatic number is positive:
\[
|E| - |V| + 1 > 0.
\]
This certifies a nontrivial 1-cycle in the graph realization.

#### Lean 4 target signature
```lean
def graphCycleRank {α : Type _} [Fintype α] [DecidableEq α] (G : SimpleGraph α) : Int :=
  (G.edgeFinset.card : Int) - (Fintype.card α : Int) + connectedComponentCount G

theorem graphCycleRank_pos_of_connected_many_edges
    {α : Type _} [Fintype α] [DecidableEq α]
    (G : SimpleGraph α)
    (hconn : SimpleGraph.Connected G)
    (hedge : Fintype.card α ≤ G.edgeFinset.card) :
    0 < graphCycleRank G := by
  -- reduce connectedComponentCount to 1, then linear arithmetic
  sorry
```

A stronger version: if disconnected at low threshold and complete at high threshold, then under edge-count growth assumptions there exists an intermediate threshold with positive cycle rank. This is a formal finite analogue of a topological phase transition.

#### Why this is the key bridge
This theorem turns “phase transition” from metaphor into certified topology. Even if full persistent homology is deferred, **positive cycle rank is already a rigorous topological order parameter**.

---

## Ambitious Synthesis Theorem

If you can push one theorem beyond the four above, make it this:

### Theorem 5: Intermediate topological regime theorem
Let \((G_\varepsilon)_{\varepsilon \in \mathbb N}\) be the semantic graph filtration of a finite statement family. Assume:

1. \(G_{\varepsilon_0}\) is disconnected,
2. \(G_{\varepsilon_1}\) is complete for some \(\varepsilon_0 < \varepsilon_1\),
3. edge count strictly increases at some stage after connectedness is achieved.

Then there exists \(\varepsilon_*\) such that \(G_{\varepsilon_*}\) is connected and has positive cycle rank.

This is the precise finite prototype of “topological complexity appears between fragmentation and saturation.”

#### Lean shape
```lean
theorem exists_intermediate_cycle_phase
    {α β : Type _} [Fintype α] [DecidableEq α] [DecidableEq β] [Nonempty α]
    (S : α → Finset β) {ε0 ε1 : Nat}
    (hlt : ε0 < ε1)
    (hdisc : ¬ SimpleGraph.Connected (semanticGraph S ε0))
    (hcomplete : ∀ x y, x ≠ y → (semanticGraph S ε1).Adj x y)
    (hedge_growth : ∃ ε, ε0 < ε ∧ ε ≤ ε1 ∧
      SimpleGraph.Connected (semanticGraph S ε) ∧
      Fintype.card α ≤ (semanticGraph S ε).edgeFinset.card) :
    ∃ ε, ε0 < ε ∧ ε ≤ ε1 ∧
      0 < graphCycleRank (semanticGraph S ε) := by
  rcases hedge_growth with ⟨ε, h0, h1, hconn, hcard⟩
  refine ⟨ε, h0, h1, ?_⟩
  exact graphCycleRank_pos_of_connected_many_edges _ hconn hcard
```

This is modest enough to formalize, but conceptually strong enough to launch a field.

---

## Proof Strategy Architecture

You must not rely on trivial automation. Use induction, rcases, by_contra, field_simp where relevant, and multi-step `calc`.

### Strategy A: Finset symmetric-difference geometry
Most promising.

1. Define `symmDiffCard` on `Finset β`.
2. Prove:
   - symmetry,
   - zero iff equality (if useful),
   - triangle inequality.
3. Use this to build threshold graphs and prove low/high-threshold phase theorems.

Why best: finite, computable, Lean-native, and already enough to support a genuine topological filtration.

---

### Strategy B: Graph filtration and cycle-rank persistence
Very promising as the “topology without heavy homology” route.

1. Build `semanticGraph S ε`.
2. Prove monotonicity in ε.
3. Define a graph-theoretic first Betti surrogate via edge/vertex/component counts.
4. Prove positivity criteria in connected regimes with enough edges.

Why best: avoids premature dependence on a full simplicial-homology API while still producing a rigorous topological invariant.

---

### Strategy C: Clique complex / flag complex escalation
Most visionary, but only pursue if Mathlib support is adequate.

1. Define the clique complex of `semanticGraph S ε`.
2. Show graph monotonicity induces simplicial-complex inclusion.
3. Relate graph cycles to nontrivial 1-skeleton topology, and possibly to simplicial \(H_1\).

Why exciting: this upgrades graph topology to actual Vietoris–Rips-style topology and opens the door to certified persistent homology in Lean.

---

## Cross-Domain Connections You Must Exploit

This project is strongest when it does not remain “just graph theory.”

### 1. Topology × Proof Theory
The order parameter is topological; the motivating boundary is proof-theoretic hardness. This is the birth of a new interface:
- semantic geometry of formal statements,
- topological diagnostics for independence-like phenomena,
- adaptive theorem proving based on phase signals.

### 2. Combinatorics × Statistical Physics
Your threshold parameter \(\varepsilon\) plays the role of inverse temperature / interaction radius. The disconnected-to-cyclic-to-complete evolution mirrors:
- percolation,
- emergence of mesoscopic loops,
- eventual saturation.

You should explicitly frame the intermediate cycle regime as a **mesoscopic phase**.

### 3. Automated Reasoning × Topological Data Analysis
Persistent homology is usually empirical. Here, you are asked to prove theorems explaining why persistence-like features should arise in synthetic theorem spaces. This is not TDA applied to data; it is **TDA internalized into formal mathematics**.

### 4. Logic × Network Science
Similarity graphs on statements are epistemic networks. Cluster separation and cycle emergence can be interpreted as:
- doctrinal fragmentation,
- bridge-conjecture formation,
- semantic redundancy and obstruction.

---

## Catalog-Building Blocks to Seek and Reuse

Build aggressively on vetted Mathlib components involving:

- `Finset` set difference, card arithmetic, subset lemmas,
- `SimpleGraph` connectivity, paths, edge finsets,
- finite cardinality lemmas,
- `WithTop Nat` for hardness profiles,
- any existing simplicial-complex / combinatorial-topology APIs if sufficiently mature.

Even if there is no catalog theorem exactly matching your needs, the architecture should explicitly exploit:
- `Finset.card` inequalities,
- path decomposition in `SimpleGraph`,
- connected component counting,
- monotonicity constructions for graph families.

If a catalog theorem gives a graph-edge/cardinality identity or connectedness criterion, use it as the backbone of the cycle-rank theorem.

---

## Conjecture with Testable Prediction

You must state at least one falsifiable conjecture, and it must be computationally testable.

### Conjecture A: Mesoscopic cycle-window conjecture
For natural theorem-generation families \( \mathcal S_n \) with bounded feature alphabets and increasing syntactic complexity, there exists a threshold interval
\[
[\varepsilon_n^-, \varepsilon_n^+]
\]
such that:
1. for \( \varepsilon < \varepsilon_n^- \), the semantic graph is typically disconnected,
2. for \( \varepsilon \in [\varepsilon_n^-, \varepsilon_n^+] \), the graph cycle rank is positive and often maximized,
3. for \( \varepsilon \gg \varepsilon_n^+ \), the clique complex becomes contractible-like / graph-complete.

**Test:** generate finite theorem families, compute feature-set distances, scan thresholds, and measure:
- connected component count,
- cycle rank,
- proof-search failure rate,
- model-checking disagreement rate.

**Refutation criterion:** no reproducible intermediate cycle window across families, or no correlation with hardness statistics.

### Conjecture B: Hardness-correlation conjecture
Let \(h_n(x)\) be bounded proof-search cost (or timeout). Then the threshold maximizing cycle rank is asymptotically near the threshold where variance of hardness across connected components is maximized.

**Test:** compute cycle rank and hardness variance along the filtration.  
**Refutation criterion:** no statistically stable co-localization.

---

## Verified Algorithm / Computational Method Required

You must produce a verified computational pipeline, not just theorem statements.

### Required algorithm
Implement a finite algorithm that:
1. takes a finite family of feature sets,
2. computes pairwise semantic distances,
3. builds threshold graphs,
4. computes:
   - number of connected components,
   - edge count,
   - graph cycle rank,
5. identifies candidate transition thresholds.

A Lean-facing specification could be:

```lean
def transitionProfile {α β : Type _} [Fintype α] [DecidableEq α] [DecidableEq β]
    (S : α → Finset β) (thresholds : List Nat) :
    List (Nat × Nat × Nat × Int)
-- (ε, componentCount, edgeCount, cycleRank)
```

You do not need full persistent homology for the first milestone. A **verified cycle-rank scanner** is enough to make the science real.

---

## demo.py Requirements

Your `demo.py` must:
- generate synthetic theorem-like feature spaces,
- build the threshold filtration,
- plot:
  - connected components vs threshold,
  - edge count vs threshold,
  - cycle rank vs threshold,
  - optional hardness proxy vs threshold,
- highlight the “mesoscopic cycle window.”

Use at least two synthetic families:
1. clustered-core family,
2. separated-then-bridged family.

The demo should visibly illustrate the finite analogue of a phase transition.

---

## RESEARCH_PAPER.md Requirements

This must be standalone and explain:

1. the formal definition of semantic conjecture spaces,
2. the graph filtration and topological order parameter,
3. the proven theorems:
   - monotonicity,
   - disconnected phase from separation,
   - collapsed phase from common core,
   - intermediate cycle regime,
4. the interpretation as a prototype for topological diagnostics of proof hardness,
5. limitations: this is not a proof of undecidability detection,
6. next scientific targets: persistent homology, stronger hardness proxies, model-theoretic semantics.

---

## FUTURE_DIRECTIONS.md Requirements

Include 3–5 falsifiable hypotheses, not vague wishes. Suggested examples:

1. **Cycle-window universality hypothesis:** normalized cycle-rank curves collapse across multiple theorem-generation families after rescaling threshold by median pairwise distance.
2. **Hardness-localization hypothesis:** statements lying on edges participating in many graph cycles have higher proof-search timeout rates than statements in tree-like regions.
3. **Core-collapse hypothesis:** families with low feature entropy exhibit earlier complete-graph collapse thresholds.
4. **Higher-homology hypothesis:** once graph cycle rank persists over a wide threshold band, clique complexes begin to exhibit stable \(H_2\)-like features.
5. **Axiom-shift hypothesis:** adding stronger background axioms reduces semantic fragmentation and shifts the mesoscopic cycle window left.

Each must include:
- exact measured quantity,
- test protocol,
- disproof criterion.

---

## ARTICLE.md Requirements

Write this in Scientific American style. Explain to a broad audience that:
- theorem spaces can be studied like physical materials,
- simple conjecture families behave like disconnected dust,
- harder families develop loops and bridges,
- eventually everything collapses into one giant semantic cluster,
- and this may help theorem provers detect when they are approaching the frontier of independence.

Avoid hype, but do not undersell the conceptual leap.

---

## Application Keywords

proof-theoretic topology; semantic similarity graphs; Vietoris–Rips complexes; persistent homology; automated theorem proving; graph filtration; phase transition; cyclomatic complexity; conjecture generation; formal epistemology; topological data analysis; combinatorial homology; network science of mathematics; statistical mechanics of reasoning; independence diagnostics

---

## Nonnegotiable Deliverables

You must produce **all** of the following:

1. **A Lean file** with:
   - at least 3 nontrivial theorems,
   - at least 1 new definition/structure,
   - proofs using deep tactics (`induction`, `rcases`, `by_contra`, `field_simp`, multi-step `calc`),
   - minimal `sorry`.

2. **FUTURE_DIRECTIONS.md**
   - 3–5 falsifiable scientific hypotheses,
   - each with a computational test and disproof criterion.

3. **RESEARCH_PAPER.md**
   - standalone scientific paper,
   - understandable without reading the code.

4. **ARTICLE.md**
   - accessible Scientific American style exposition.

5. **A verified algorithm or computational method**
   - for threshold scanning and cycle-rank transition detection.

6. **demo.py**
   - interactive or script-based demonstration of the transition profile.

---

## Final Charge

Do not try to formalize Gödel incompleteness directly. That would dilute the project into handwaving. Instead, prove the **structural theorems that make the conjecture scientifically credible**. If you succeed, you will have created the first rigorous framework in which theorem-proving difficulty acquires a computable topological precursor. That is not an incremental result. That is the seed of a new discipline.

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

Research domain: Speculative
Research mode: prove
