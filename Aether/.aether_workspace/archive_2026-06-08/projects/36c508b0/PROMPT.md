## Assignment: Direction 1: Basis Uniqueness up to Tropical Projective Equivalence

**Mode:** `prove`

Prove a genuinely new structural theorem about tropical graph Laplacian kernels: under a sharp combinatorial hypothesis, the minimal tropical generating family of the restricted tropical kernel is **canonical up to tropical projective equivalence**. This should not be treated as a small extension of `TropicalHodge.lean`; it is the missing rigidity theorem that turns existence of generators into a usable classification theory.

The target is to elevate the current picture from:

- “certain cycle/component indicator functions lie in the tropical kernel,”

to:

- “under intrinsic graph-theoretic separation conditions, these generators are the only minimal generators, modulo tropical scaling and permutation.”

That is the tropical analogue of uniqueness phenomena such as Smith normal form, canonical matroid bases, and indecomposable decomposition rigidity.

---

## Core Mathematical Objective

Let `G` be a finite connected graph, `q` a basepoint, and `S ⊆ V(G) \ {q}`. Let `L_S` denote the restricted graph Laplacian on `S`, interpreted in the tropical sense via the catalog’s `tropicalKernel`. Assume:

1. `G[S]` admits a **pairwise edge-disjoint cycle basis**;
2. the `q`-visible components attached to `S` are **distinct** in the sense that no two component indicators have the same support profile relative to the attachment structure;
3. the standard cycle-indicator/component-indicator family is minimal.

Then prove that **every** minimal tropical generating family of `tropicalKernel L_S` is obtained from the canonical one by:
- adding an arbitrary constant to each generator, and
- permuting the generators.

This is the exact rigidity statement needed to make tropical kernels into computable graph invariants rather than merely existential objects.

---

## Precise Theorem Targets

You should formalize at least three substantial theorems. The following are the intended targets; refine predicates as needed to match the existing catalog API.

### New definitions required

Introduce at least one genuinely new concept, for example:

- `TropProjEq` : tropical projective equivalence of generator families;
- `MinimalTropGeneratingFamily` : a family generating a tropical kernel and minimal under deletion;
- `EdgeDisjointCycleBasis` : a cycle basis with pairwise edge-disjoint supports;
- `DistinctQVisibleComponents` : a support-separation property for the component indicators.

These should be mathematically meaningful, not ad hoc wrappers.

---

## Suggested Lean 4 theorem statements

The exact signatures may need adjustment to the graph types in the catalog, but the formal targets should be this precise in spirit.

```lean
def TropProjEq
  {α : Type*} [AddCommMonoid α] (F₁ F₂ : Finset (V → α)) : Prop :=
  ∃ σ : Equiv.Perm {f // f ∈ F₁},
    ∃ c : {f // f ∈ F₁} → α,
      ∀ x : {f // f ∈ F₁}, ∀ v : V,
        σ x.1 v = x.1 v + c x
```

For tropical values you may want `α = ℤ` or `α = ℝ∞` or whatever the catalog uses.

```lean
def MinimalTropGeneratingFamily
  (K : Set (V → TropVal)) (F : Finset (V → TropVal)) : Prop :=
  TropicallyGenerates K F ∧
  ∀ f ∈ F, ¬ TropicallyGenerates K (F.erase f)
```

```lean
def EdgeDisjointCycleBasis
  (G : SimpleGraph V) (B : Finset (Finset V)) : Prop := ...
```

```lean
def DistinctQVisibleComponents
  (G : SimpleGraph V) (q : V) (S : Finset V) : Prop := ...
```

### Theorem 1: Separation / support rigidity
A generator supported on one canonical region cannot be tropically synthesized from generators supported on disjoint canonical regions unless one of those regions coincides with it.

```lean
theorem canonical_generator_support_rigid
  {G : SimpleGraph V} [Fintype V] [DecidableEq V]
  {q : V} {S : Finset V} {g : V → TropVal} {F : Finset (V → TropVal)} :
  Connected G →
  SupportSeparatedCanonicalFamily G q S F →
  g ∈ F →
  ¬ TropicallyGeneratesSingletonFromOthers g (F.erase g)
```

This is the engine that rules out hidden redundancies.

### Theorem 2: Uniqueness up to tropical projective equivalence
This is the central breakthrough theorem.

```lean
theorem tropical_kernel_generating_family_unique_up_to_proj
  {G : SimpleGraph V} [Fintype V] [DecidableEq V]
  {q : V} {S : Finset V}
  (hq : q ∉ S)
  (hconn : Connected G)
  (hcyc : EdgeDisjointCycleBasisOnInduced G S)
  (hvis : DistinctQVisibleComponents G q S) :
  let K := tropicalKernel (restrictedLaplacian G S)
  let Fcanon := canonicalCycleComponentFamily G q S
  MinimalTropGeneratingFamily K Fcanon →
  ∀ Falt : Finset (V → TropVal),
    MinimalTropGeneratingFamily K Falt →
    TropProjEq Fcanon Falt
```

### Theorem 3: Matroidal corollary
Connect the theorem to matroid theory: the uniqueness class depends only on the cycle matroid plus `q`-visibility data.

```lean
theorem tropical_kernel_uniqueness_depends_only_on_cycle_matroid_data
  {G₁ G₂ : SimpleGraph V} [Fintype V] [DecidableEq V]
  {q : V} {S : Finset V} :
  Connected G₁ →
  Connected G₂ →
  CycleMatroidEquivalentOn G₁ G₂ S →
  SameQVisibilityData G₁ G₂ q S →
  EdgeDisjointCycleBasisOnInduced G₁ S →
  EdgeDisjointCycleBasisOnInduced G₂ S →
  TropProjEq
    (canonicalCycleComponentFamily G₁ q S)
    (canonicalCycleComponentFamily G₂ q S)
```

This is your required cross-domain theorem: tropical linear algebra ↔ matroid theory.

---

## Proof architecture: 3 viable strategies

You must give a serious proof, not an API shuffle. Use multi-step reasoning, contradiction, support analysis, and propagation lemmas from the catalog.

### Strategy A: Support-separation + leaf propagation
**Most promising.**

1. **Canonical support decomposition.**  
   Show that each canonical generator has a support pattern concentrated on either:
   - a cycle block, or
   - a `q`-visible component block.
   
   Use `componentIndicator_mem_tropicalKernel` and the cycle-side lemmas already present in `TropicalHodge.lean`.

2. **Leaf propagation rigidity.**  
   Use the existing leaf propagation principle (`tropicalKernel_leaf_eq` or its local consequences) to prove that values on tree-like appendages are forced by values on the adjacent cycle/component core. This should show that any tropical kernel element is determined on large regions by a small support seed.

3. **Contradiction via minimality.**  
   Assume an alternative minimal generating family contains a generator not projectively equivalent to a canonical one. By comparing support minima and forced propagation along pendant trees, derive that either:
   - two supposedly distinct generators must share the same support profile, violating `DistinctQVisibleComponents`, or
   - one generator is tropically generated by the others, violating minimality.

Why this is strongest: it exploits exactly the graph-theoretic structure already certified in the catalog and turns local propagation into global rigidity.

---

### Strategy B: Extremal rays of the tropical kernel semimodule
This is conceptually deeper and may produce stronger future generalizations.

1. Define an intrinsic notion of **tropical extremal generator** for the kernel semimodule.
2. Prove that the canonical cycle/component indicators are extremal under edge-disjointness and visibility separation.
3. Show every minimal generating family consists exactly of the extremal rays; then uniqueness follows from extremal-ray classification.

Why this matters: if successful, this reframes the theorem as a tropical convexity theorem and opens a bridge to idempotent convex geometry and optimization.

Risk: Mathlib support for tropical convexity abstractions may be thinner than for graph combinatorics, so this may require more infrastructure.

---

### Strategy C: Matroidal reconstruction
Use the cycle matroid as the hidden rigidity object.

1. Prove that edge-disjoint cycle bases induce uniquely identifiable support circuits in the tropical kernel.
2. Show component generators are the cocircuit-like complementary data seen from the basepoint `q`.
3. Reconstruct any minimal generating family from the circuit/cocircuit incidence pattern; projective ambiguity is the only remaining freedom.

Why this is exciting: it would reveal that tropical kernel uniqueness is controlled by a combinatorial shadow of oriented matroid structure.

Risk: likely more abstract and technically demanding in Lean.

---

## Catalog building blocks to exploit

You must build explicitly on these vetted results, not merely cite them:

- `Pythagorean/TropicalBridge/Defs.lean`
  - `tropicalKernel`
  - `componentIndicator`
- `Pythagorean/TropicalBridge/TropicalHodge.lean`
  - `componentIndicator_mem_tropicalKernel`
  - `tropicalKernel_leaf_eq`

How to use them:

- `componentIndicator_mem_tropicalKernel` gives certified membership of the component-side canonical generators.
- `tropicalKernel_leaf_eq` is the rigidity lever: along leaf or tree attachments, tropical kernel values cannot vary arbitrarily. This should be converted into a propagation lemma for entire `q`-visible components.
- `tropicalKernel` and `componentIndicator` provide the semantic anchor for your new minimality and projective-equivalence notions.

You should derive one or two intermediate lemmas of the following form:

```lean
theorem tropical_kernel_equal_on_hanging_tree
  ...
```

and

```lean
theorem cycle_indicator_not_generated_by_component_indicators
  ...
```

These are likely the real workhorses.

---

## Required theorem flow

A strong file should have a structure like this:

1. **Definitions**
   - `TropProjEq`
   - `MinimalTropGeneratingFamily`
   - `SupportSeparatedCanonicalFamily`
   - `EdgeDisjointCycleBasis...`
   - `DistinctQVisibleComponents...`

2. **Rigidity lemmas**
   - support monotonicity / support separation
   - leaf/tree propagation
   - non-generation of one canonical block from disjoint others

3. **Main uniqueness theorem**
   - every minimal generating family matches the canonical family up to tropical scaling/permutation

4. **Cross-domain theorem**
   - matroidal invariance or a theorem connecting uniqueness to a combinatorial invariant

5. **Conjecture + computational test**
   - formal statement of a falsifiable conjecture beyond the theorem

---

## Cross-domain connections you must emphasize

### 1. Tropical linear algebra ↔ matroid theory
The edge-disjoint cycle basis condition is not merely graph-theoretic convenience; it is a circuit-separation hypothesis in the cycle matroid. The uniqueness theorem should be framed as a **matroidal rigidity theorem for tropical kernel generators**.

### 2. Algebraic combinatorics ↔ canonical forms
This result is a tropical analogue of uniqueness phenomena like Smith normal form, Jordan blocks up to scaling, or indecomposable decompositions. It suggests a theory of **canonical tropical presentations** for graph-derived semimodules.

### 3. Potential bridge to network science / physics
`q`-visible components behave like independently observable modes in a constrained network. Canonical tropical generators may model robust modes of dissipation, synchronization, or chip-firing flow. Include at least one theorem or discussion point tying the combinatorics to physical network modes or discrete potential theory.

A possible theorem of this flavor:

```lean
theorem visible_component_generator_corresponds_to_unique_potential_mode
  ...
```

Even if formalized at a combinatorial level, frame it as a bridge to discrete physics.

---

## Falsifiable conjecture with computational prediction

State and test something stronger than the main theorem. For example:

> **Conjecture.** For every connected graph `G`, basepoint `q`, and subset `S ⊆ V \ {q}`, the number of tropical projective equivalence classes of minimal generating families of `tropicalKernel (restrictedLaplacian G S)` equals the number of overlap classes of cycle supports in any cycle basis of `G[S]`.

This is falsifiable by exhaustive search on small graphs.

A more precise Lean-friendly skeleton:

```lean
conjecture overlap_class_counts_proj_generator_classes
  {G : SimpleGraph V} [Fintype V] [DecidableEq V]
  {q : V} {S : Finset V} :
  Connected G →
  q ∉ S →
  NumProjGeneratorClasses (tropicalKernel (restrictedLaplacian G S))
    = NumCycleOverlapClasses G S
```

**Computational test:** enumerate all connected graphs on `n ≤ 7`, all `q`, all valid `S`; compute canonical families, all minimal generating families, quotient by `TropProjEq`, and compare against cycle-overlap statistics. Record the smallest counterexample if false.

---

## Why this would be a breakthrough

Existence theorems are not enough for a usable theory. Without uniqueness, tropical kernel generators are coordinate choices; with uniqueness, they become **invariants**.

This project would create:

- a canonical representation theory for tropical graph kernels,
- a bridge from tropical Hodge-style graph structures to matroid rigidity,
- an algorithmic route for comparing graph families via canonical tropical signatures,
- a foundation for classification, clustering, and isomorphism heuristics based on tropical kernel data.

In short: this turns tropical kernel theory from descriptive combinatorics into a canonical algebraic language.

---

## Verified algorithmic deliverable

You must produce a verified computational method, not just theorem statements.

### Required algorithm
Implement an algorithm that:

1. constructs the canonical cycle-component family for `(G,q,S)`,
2. checks the edge-disjoint cycle basis and visibility hypotheses,
3. computes whether a candidate family is a minimal tropical generating family,
4. tests projective equivalence classes of minimal generating families,
5. returns either:
   - the unique class certificate, or
   - a concrete obstruction/witness to non-uniqueness.

Suggested artifact names:
- `canonicalTropicalKernelFamily`
- `isMinimalTropGeneratingFamily`
- `tropProjEqDecide`
- `uniquenessWitnessOrCounterexample`

This algorithm should drive the conjecture experiments on small graphs.

---

## demo.py requirement

Create `demo.py` that interactively:

- enumerates connected graphs up to 7 vertices,
- lets the user choose `q` and `S`,
- displays the canonical generators,
- computes alternative minimal generating families when feasible,
- reports whether uniqueness up to tropical projective equivalence holds,
- visualizes failure cases by highlighting overlapping cycle supports / ambiguous components.

The demo should make the conjecture feel experimentally alive.

---

## Mandatory deliverables

You must produce **all** of the following:

1. **Lean development** with at least 3 substantial theorems using real proof structure (`induction`, `rcases`, `by_contra`, `field_simp` where relevant, multi-step `calc`, etc.), and not trivial decision procedures.

2. **A new mathematical definition** not already in the catalog, such as `TropProjEq` or `MinimalTropGeneratingFamily`.

3. **A cross-domain theorem** connecting tropical kernel uniqueness to matroid theory, canonical forms, or discrete potential modes.

4. **A falsifiable conjecture** with a clear computational test and explicit search protocol.

5. **A verified algorithm or computational method** as described above.

6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions.  
   Each direction must include the exact phrases:
   - **“The key insight is...”**
   - **“Why now?”**
   
   At least one direction must bridge to a different domain.

7. **`RESEARCH_PAPER.md`** as a standalone scientific paper.  
   A reader with no access to the code must understand:
   - the theorem,
   - why it matters,
   - the proof idea,
   - the experiments,
   - and the next questions.

8. **`ARTICLE.md`** in Scientific American style.  
   It must explain the mathematical discovery and significance to a broad audience.  
   **Do not focus on formal verification or proof assistants.** Focus on the ideas.

9. **`demo.py`** as above.

---

## Application keywords

tropical kernel rigidity, canonical generators, tropical projective equivalence, graph Laplacian, edge-disjoint cycle basis, cycle matroid, tropical convexity, canonical forms, discrete potential theory, chip-firing, network modes, algebraic combinatorics, graph invariants, semimodule extremality, exhaustive graph search

---

## Final charge

Do not merely show that some generating family exists. Prove that, under a clean and meaningful combinatorial hypothesis, the tropical kernel itself **chooses its own basis**. That is the conceptual leap. If you can make this precise in Lean and back it with exhaustive computation, you will have created the first canonical-form theorem for this tropical graph kernel framework.

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
