## Assignment: Direction 4: Tropical Persistent Homology for Network Data Analysis

**Mode:** prove

You are not being asked for an incremental variant of existing persistent homology. You are being asked to found a genuinely new bridge: a tropicalized, graph-theoretic persistent invariant with rigorous stability theorems and an executable comparison pipeline against classical barcodes.

The core ambition is to turn the vague slogan “cycle-rank behaves like a tropical barcode” into a precise theorem package in Lean 4, with new definitions, nontrivial proofs, and a verified computational method.

---

## Central Vision

Classical persistent homology extracts intervals from chain complexes over fields. Your target is a different but potentially faster and more combinatorial invariant:

- start with a filtration of finite graphs extracted from a point cloud,
- define a **tropical barcode profile** from graph-theoretic/tropical data,
- prove monotonicity and stability theorems,
- connect the invariant to spectral graph theory and tropical geometry,
- and test whether this tropical surrogate tracks or bounds classical persistence in practice.

This would open a new program in **tropical topological data analysis**, where persistence is computed through min-plus or graph-Laplacian combinatorics rather than linear algebra over fields.

Application keywords: **topological data analysis, tropical geometry, spectral graph theory, graph Laplacians, persistent homology, Vietoris–Rips filtration, stability theory, chip-firing, combinatorial Hodge theory, hardware-friendly algorithms**.

---

## New Definitions You Should Introduce

You must define at least one genuinely new structure absent from the catalog. I recommend defining all three below.

### 1. Tropical nullity of a graph
For a finite graph `G`, define the tropical nullity as the first Betti number / cycle rank:
\[
\operatorname{tropNullity}(G) := |E(G)| - |V(G)| + c(G),
\]
where \(c(G)\) is the number of connected components.

This is mathematically justified by the tropical Jacobian / chip-firing intuition: cycle rank is the correct combinatorial shadow of tropical kernel dimension for the graph Laplacian.

Possible Lean-facing definition:
```lean
def tropNullity (G : SimpleGraph V) [Fintype V] [DecidableEq V] : ℕ := 
  G.edgeFinset.card - Fintype.card V + Nat.card (Quotient (SimpleGraph.Reachable.setoid G))
```
If component-count infrastructure is awkward, restrict first to connected graphs:
```lean
def tropNullityConnected (G : SimpleGraph V) [Fintype V] [DecidableEq V] : ℕ :=
  G.edgeFinset.card + 1 - Fintype.card V
```
for use under `[Fact G.Connected]` or a theorem hypothesis `hconn : G.Connected`.

### 2. Tropical barcode profile of a filtration
For a monotone sequence of graphs \(G_0 \subseteq G_1 \subseteq \cdots \subseteq G_n\), define:
\[
\operatorname{tropBarcode}(i) := \operatorname{tropNullity}(G_i).
\]
This is a persistence-style rank invariant, not yet interval-decomposed, but already meaningful and stable.

Lean sketch:
```lean
structure GraphFiltration (V : Type _) [Fintype V] [DecidableEq V] where
  obj : ℕ → SimpleGraph V
  mono : Monotone obj
```

```lean
def tropBarcode {V : Type _} [Fintype V] [DecidableEq V]
    (F : GraphFiltration V) (i : ℕ) : ℕ :=
  tropNullity (F.obj i)
```

### 3. Tropical barcode variation distance
For two filtrations \(F,H\), define the sup distance between barcode profiles on a finite index range:
\[
d_{\mathrm{tb}}(F,H;N) := \sup_{0 \le i \le N} \left| \operatorname{tropBarcode}_F(i)-\operatorname{tropBarcode}_H(i)\right|.
\]

Lean sketch:
```lean
def tropBarcodeDist {V : Type _} [Fintype V] [DecidableEq V]
    (F H : GraphFiltration V) (N : ℕ) : ℕ :=
  Finset.sup (Finset.range (N+1)) (fun i => Nat.dist (tropBarcode F i) (tropBarcode H i))
```

This gives you a concrete object for theorem statements and the computational demo.

---

## Precise Theorem Targets

You need at least 3 serious theorems. The following package is ambitious but realistic.

### Theorem 1: Edge-addition jump formula
For connected finite graphs, adding a missing edge changes tropical nullity by exactly one iff it creates a cycle.

Mathematical statement:
\[
\forall G,e,\quad
\text{if } G \text{ is connected and } e \notin E(G),
\text{ then }
\operatorname{tropNullity}(G+e)=\operatorname{tropNullity}(G)+1.
\]
More generally, without connectivity assumptions:
\[
\operatorname{tropNullity}(G+e)-\operatorname{tropNullity}(G)
=
\begin{cases}
0,& \text{if } e \text{ joins distinct connected components},\\
1,& \text{if } e \text{ lies inside one connected component}.
\end{cases}
\]

This is the combinatorial engine behind persistence jumps.

Lean 4 target signature, connected version:
```lean
theorem tropNullity_addEdge_of_connected
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (hconn : G.Connected)
    {u v : V} (hne : u ≠ v) (hnot : ¬ G.Adj u v) :
    tropNullityConnected (G.sup (SimpleGraph.fromEdgeSet {{(u,v)}})) =
      tropNullityConnected G + 1
```
You may need to replace `sup/fromEdgeSet` by the actual Mathlib edge-addition constructor available for `SimpleGraph`.

Why this matters: it identifies tropical persistence births with explicit graph events. It is the tropical analogue of a one-dimensional persistence birth under edge insertion.

---

### Theorem 2: Monotonicity and Lipschitz bound along filtrations
If \(G_i \subseteq G_{i+1}\), then tropical nullity is monotone, and the one-step jump is bounded by the number of newly added edges:
\[
\operatorname{tropBarcode}(i) \le \operatorname{tropBarcode}(i+1),
\]
\[
\operatorname{tropBarcode}(i+1)-\operatorname{tropBarcode}(i)
\le |E(G_{i+1})\setminus E(G_i)|.
\]

Lean target:
```lean
theorem tropBarcode_monotone
    {V : Type _} [Fintype V] [DecidableEq V]
    (F : GraphFiltration V) :
    Monotone (tropBarcode F)
```

```lean
theorem tropBarcode_step_le_newEdges
    {V : Type _} [Fintype V] [DecidableEq V]
    (F : GraphFiltration V) (i : ℕ) :
    tropBarcode F (i+1) - tropBarcode F i
      ≤ ((F.obj (i+1)).edgeFinset \ (F.obj i).edgeFinset).card
```

Why this matters: this is your tropical persistence regularity theorem. It says the barcode profile is a controlled observable of filtration growth.

---

### Theorem 3: Stability under edge perturbations
For two graphs on the same vertex set,
\[
|\operatorname{tropNullity}(G)-\operatorname{tropNullity}(H)|
\le |E(G)\,\triangle\,E(H)|.
\]
Hence for filtrations,
\[
d_{\mathrm{tb}}(F,H;N)
\le \sup_{0\le i\le N}|E(F_i)\triangle E(H_i)|.
\]

Lean target:
```lean
theorem tropNullity_stable_under_edgeSymmDiff
    {V : Type _} [Fintype V] [DecidableEq V]
    (G H : SimpleGraph V) :
    Nat.dist (tropNullity G) (tropNullity H)
      ≤ ((G.edgeFinset \ H.edgeFinset).card + (H.edgeFinset \ G.edgeFinset).card)
```

```lean
theorem tropBarcodeDist_le_edgePerturbation
    {V : Type _} [Fintype V] [DecidableEq V]
    (F H : GraphFiltration V) (N : ℕ) :
    tropBarcodeDist F H N ≤
      Finset.sup (Finset.range (N+1))
        (fun i =>
          ((F.obj i).edgeFinset \ (H.obj i).edgeFinset).card +
          ((H.obj i).edgeFinset \ (F.obj i).edgeFinset).card)
```

Why this matters: this is a genuine stability theorem in the spirit of TDA, but for a tropical/combinatorial persistence surrogate. It is likely the most important formal theorem in the project.

---

## Spectral Bridge: sharpen the conjectural Fiedler-constant story

The original conjecture says the stability constant equals the minimum Fiedler eigenvalue across the filtration. As stated, that is likely too optimistic and may be false without stronger hypotheses. Do not oversell it as a theorem unless you can prove it. Instead, formalize a **weaker theorem plus a falsifiable conjecture**.

### Safer theorem: spectral lower bound on cycle creation threshold
For connected graphs, adding an edge inside a component increases tropical nullity by one, while the Fiedler eigenvalue \(\lambda_2\) controls how hard it is to disconnect the graph and how robust component structure is under perturbation. This suggests a one-sided relation, not equality.

A plausible theorem statement in paper form:
\[
\text{If } G \text{ is connected and } \lambda_2(G)\ge \alpha >0,
\text{ then any perturbation changing fewer than } m(\alpha)
\text{ edges preserves connectivity, hence}
\]
\[
|\operatorname{tropNullity}(G)-\operatorname{tropNullity}(H)|
\le |E(G)\triangle E(H)|
\]
with the connectivity regime controlled by \(\alpha\).

This cross-links tropical persistence to spectral graph theory, even if the exact “stability constant = minimum Fiedler eigenvalue” remains conjectural.

If full spectral formalization is too heavy in Lean, make this a mathematically precise conjecture in the paper and computational code, and prove the edge-symmetric-difference theorem formally.

---

## Cross-Domain Theorem Requirement

You must include at least one theorem that explicitly connects this domain to another. The strongest available bridge is to **chip-firing / tropical Jacobians**.

Using `Catalog/Pythagorean/TropicalBridge/ChipFiringCorrespondence.lean`, especially `genus_nonneg_of_connected`, prove a theorem of the following flavor:

### Theorem 4: Tropical nullity equals graph genus for connected graphs
For connected finite graphs,
\[
\operatorname{tropNullity}(G)=g(G)=|E(G)|-|V(G)|+1.
\]

Lean target:
```lean
theorem tropNullity_eq_genus_of_connected
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (hconn : G.Connected) :
    tropNullityConnected G = G.edgeFinset.card + 1 - Fintype.card V
```

If the catalog already defines graph genus in the chip-firing file, strengthen to:
```lean
theorem tropNullity_eq_genus_catalog_of_connected
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (hconn : G.Connected) :
    tropNullityConnected G = genus G
```

Why this is revolutionary: it ties TDA to tropical Brill–Noether/chip-firing ideas. The “barcode” is not merely graph-theoretic noise; it is measuring the growth of tropical Jacobian complexity across scales.

Cross-domain connections to emphasize:
- **TDA ↔ tropical geometry** via tropical kernels and graph genus
- **TDA ↔ spectral graph theory** via Fiedler-based stability heuristics
- **TDA ↔ combinatorial algebraic geometry** via chip-firing/Jacobians
- **TDA ↔ hardware/algorithms** via min-plus and edge-count operations

---

## Falsifiable Conjecture With Computational Test

State this cleanly and test it in `demo.py`.

### Conjecture (Spectral tropical stability bound)
Let \(F\) be a Vietoris–Rips graph filtration from a finite point cloud, and let
\[
\lambda_* := \min_i \lambda_2(F_i)
\]
over connected stages. Then for sufficiently small metric perturbations of the point cloud by size \(\varepsilon\),
\[
d_{\mathrm{tb}}(F,\widetilde F;N) \le C \varepsilon / \lambda_*
\]
for a universal or dimension-dependent constant \(C\).

**Testable prediction:** point clouds with larger minimum Fiedler eigenvalue should empirically exhibit smaller tropical barcode variation under the same perturbation scale.

**Falsification criterion:** find two point clouds \(X,Y\) with
\[
\lambda_*(X) > \lambda_*(Y)
\]
but observed normalized tropical barcode instability for \(X\) is strictly larger than for \(Y\) under matched perturbations, beyond sampling error.

This is better than the original equality conjecture because it is structurally plausible and experimentally meaningful.

---

## Proof Strategy Architecture

You must not rely on trivial automation. Use induction, case splits, contradiction, and explicit combinatorial reasoning.

### Strategy A: Edge-by-edge induction on filtration growth
Most promising for the formal development.

1. **Base combinatorial identity:** prove tropical nullity equals edge count minus vertex count plus component count.
2. **Single-edge update lemma:** when one edge is added, analyze whether it merges components or creates a cycle. Use `rcases` on reachability/component cases.
3. **Induct over added edges:** derive monotonicity and Lipschitz bounds for entire filtration steps and then for full perturbation distance.

Why this is most promising: it matches Mathlib’s combinatorial graph infrastructure and avoids heavy spectral formalization bottlenecks.

### Strategy B: Spanning forest / Euler characteristic route
Elegant and mathematically deep.

1. Define a spanning forest count or use existing connected-component machinery.
2. Show
   \[
   \operatorname{tropNullity}(G)=|E|-|V|+c(G)
   \]
   by decomposing the graph into a forest plus excess edges.
3. Each excess edge contributes one independent cycle, giving the jump and stability theorems.

Why this is good: it aligns with classical graph homology and gives clean `calc`-style proofs. It also naturally bridges to Euler characteristic and homology.

### Strategy C: Chip-firing/tropical Jacobian interpretation
Most visionary, possibly hardest formally.

1. Import catalog results connecting graph genus and chip-firing.
2. Interpret tropical nullity as the rank of cycle freedom / genus.
3. Transfer genus monotonicity and update laws to barcode statements.

Why this matters: it gives conceptual depth and the cross-domain theorem. Use this even if Strategy A handles the core combinatorics.

Recommendation: **Use Strategy A for the formal theorem backbone, Strategy C for the conceptual bridge, and Strategy B to clean up proofs where component formulas are cumbersome.**

---

## Concrete Lean 4 Formalization Targets

You should create a file along the lines of:

`Blueprints/TropicalPersistentHomology/TropicalBarcode.lean`

with these target declarations or close analogues:

```lean
import Mathlib
-- plus precise catalog imports

open scoped BigOperators

structure GraphFiltration (V : Type _) [Fintype V] [DecidableEq V] where
  obj : ℕ → SimpleGraph V
  mono : Monotone obj

def tropNullity {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) : ℕ :=
  G.edgeFinset.card - Fintype.card V +
    Nat.card (Quotient (SimpleGraph.Reachable.setoid G))

def tropBarcode {V : Type _} [Fintype V] [DecidableEq V]
    (F : GraphFiltration V) (i : ℕ) : ℕ :=
  tropNullity (F.obj i)

def tropBarcodeDist {V : Type _} [Fintype V] [DecidableEq V]
    (F H : GraphFiltration V) (N : ℕ) : ℕ :=
  Finset.sup (Finset.range (N+1))
    (fun i => Nat.dist (tropBarcode F i) (tropBarcode H i))

theorem tropNullity_nonneg
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) :
    0 ≤ tropNullity G := by
  -- nontrivial proof via genus/component formula

theorem tropBarcode_monotone
    {V : Type _} [Fintype V] [DecidableEq V]
    (F : GraphFiltration V) :
    Monotone (tropBarcode F) := by
  -- induction / edge-addition decomposition

theorem tropNullity_stable_under_edgeSymmDiff
    {V : Type _} [Fintype V] [DecidableEq V]
    (G H : SimpleGraph V) :
    Nat.dist (tropNullity G) (tropNullity H)
      ≤ ((G.edgeFinset \ H.edgeFinset).card + (H.edgeFinset \ G.edgeFinset).card) := by
  -- by induction on symmetric difference

theorem tropBarcodeDist_le_edgePerturbation
    {V : Type _} [Fintype V] [DecidableEq V]
    (F H : GraphFiltration V) (N : ℕ) :
    tropBarcodeDist F H N ≤
      Finset.sup (Finset.range (N+1))
        (fun i =>
          ((F.obj i).edgeFinset \ (H.obj i).edgeFinset).card +
          ((H.obj i).edgeFinset \ (F.obj i).edgeFinset).card) := by
  -- multi-step calc from pointwise bound

theorem tropNullity_eq_genus_of_connected
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (hconn : G.Connected) :
    tropNullity G = G.edgeFinset.card + 1 - Fintype.card V := by
  -- use connected component count = 1
```

If exact component-count APIs differ, adapt the signature, but preserve the theorem content.

---

## Catalog Building Blocks

You explicitly cited:

- `Catalog/Pythagorean/TropicalBridge/ChipFiringCorrespondence.lean`
  - `genus_nonneg_of_connected`

Use this as a certified bridge between graph genus and tropical/chip-firing structure. The likely pattern is:

1. identify your `tropNullity` with graph genus in the connected case;
2. inherit nonnegativity and structural meaning;
3. use the catalog theorem to avoid reproving low-level genus facts.

Also inspect whether `Catalog/Pythagorean/AdelicPersistentHomology.lean` actually contains reusable filtration infrastructure. If it does, reuse its monotone-sequence abstractions rather than reinventing them. If not, your `GraphFiltration` structure becomes the novel formal object.

Do not merely cite catalog files. Explicitly state in comments and the paper how each imported theorem is used.

---

## Algorithmic Deliverable

You must provide a **verified computational method**, not just theorem statements.

### Algorithm: Tropical barcode computation from a point cloud
Input:
- finite point cloud \(X = \{x_1,\dots,x_n\}\subset \mathbb{R}^d\),
- thresholds \(r_0 < \cdots < r_N\).

Procedure:
1. build the Vietoris–Rips graph \(G_i\) at each threshold \(r_i\),
2. compute
   \[
   \operatorname{tropBarcode}(i)=|E(G_i)|-|V|+c(G_i),
   \]
3. output the integer profile \((\operatorname{tropBarcode}(0),\dots,\operatorname{tropBarcode}(N))\).

Formally verify:
- monotonicity in \(i\),
- one-step jump bound,
- perturbation stability under edge changes.

This is compelling because it reduces persistence-like computation to graph connectivity and edge counting, which is dramatically simpler than matrix reduction.

---

## demo.py Requirements

Your `demo.py` must:

1. generate random point clouds in dimensions \(2,3,5\),
2. build Vietoris–Rips graph filtrations,
3. compute tropical barcode profiles,
4. compute classical \(H_1\) persistence barcodes using a standard Python package if available,
5. perturb point clouds and compare stability,
6. estimate empirical relationship between instability and minimum Fiedler eigenvalue,
7. search for falsifying examples to the spectral conjecture.

At minimum, include:
- a scatter plot of perturbation size vs tropical barcode distance,
- a comparison plot of tropical vs classical barcode instability,
- a table of \(\lambda_*\), tropical instability, classical bottleneck distance.

---

## Required Nontrivial Proof Techniques

Your file must contain at least 3 substantial theorems whose proofs genuinely use techniques like:

- induction on the number of added edges,
- `rcases` on whether vertices lie in the same connected component,
- `by_contra` to show edge addition cannot reduce tropical nullity,
- multi-step `calc` chains for distance inequalities,
- if needed, `field_simp` in any spectral/comparison lemmas involving rational bounds.

Do not let the development collapse into pure arithmetic simplification. The mathematics must be structural.

---

## Scientific Significance

If you succeed, you will have introduced a new object: a **tropical persistent graph invariant** with certified stability and a practical algorithm. This could open:

- a lightweight alternative to classical persistence for network-valued data,
- a tropicalized theory of persistence based on genus growth and chip-firing,
- new spectral-combinatorial stability estimates,
- and potentially hardware-accelerated TDA pipelines using min-plus style primitives.

The breakthrough is not “another barcode.” It is the recognition that **graph genus evolution across metric scales is itself a persistent observable with tropical meaning**.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions and at least 3 nontrivial theorem proofs, minimizing sorry.
2. **A verified algorithm or computational method** implementing tropical barcode computation from graph filtrations.
3. **`demo.py`** demonstrating the result interactively on random point clouds and perturbation experiments.
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper. A reader with no access to the code must understand:
   - the new invariant,
   - the main theorems,
   - why it matters,
   - how it compares to classical persistence,
   - and what to investigate next.
5. **`ARTICLE.md`** in Scientific American style, accessible and engaging, focused on the mathematics and scientific significance. Do **not** focus on formal verification machinery.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions. Each direction must include:
   - a sentence beginning **“The key insight is...”**
   - a sentence beginning **“Why now?”**
   At least one direction must bridge to a different domain, such as statistical mechanics, tropical optimization, or geometric deep learning.

---

## Final Charge

Do not merely formalize the conjecture as stated. Refine it into a theorem/conjecture architecture:

- prove the exact combinatorial stability theorems,
- build the chip-firing/tropical bridge rigorously,
- isolate the Fiedler-eigenvalue claim as a falsifiable higher-order conjecture,
- and produce experiments strong enough to sharpen or kill it.

That is how this becomes a field-opening result rather than a decorative formalization.

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
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

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
    "visualizations": [ { "name": "...", "code": "# matplotlib or plotly script, self-contained", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
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
