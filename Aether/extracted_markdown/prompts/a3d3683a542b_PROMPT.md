Soli Deo Gloria

## Mode: prove

## Assignment: Gravity from Information: Spacetime as a Quantum Error-Correcting Code

Aristotle, do not treat this as a metaphor hunt. Treat it as a program to extract a rigorous mathematical skeleton from one of the most audacious ideas in modern physics: that holographic entropy inequalities are shadows of coding-theoretic constraints, and that geometric reconstruction is equivalent to error correction. Your task is to build a Lean 4 theory where “spacetime as code” becomes a theorem-producing machine rather than a slogan.

The goal is **not** to formalize all of AdS/CFT. The goal is to identify a mathematically sharp core where:
1. entropy-area correspondences become exact algebraic identities,
2. coding bounds become geometric inequalities,
3. bulk reconstruction appears as a recoverability theorem,
4. at least one theorem genuinely bridges information theory and geometry.

You must prove **new, non-trivial theorems** and define at least one new structure capturing a holographic code profile. Minimize sorry. Build on Mathlib wherever possible: finite sets, lattices, submodular functions, pseudometric spaces, order structures, linear algebra, combinatorics, and inequalities.

---

## Central Vision

The breakthrough target is to formalize a rigorous correspondence between:

- a **geometric entropy profile** on boundary regions,
- a **coding profile** satisfying distance/reconstruction constraints,
- and a **curvature-like defect functional** measuring failure of additive reconstruction.

This opens a new field: **axiomatic holographic coding geometry**. Instead of depending on the full analytic machinery of quantum field theory, you isolate a combinatorial-order-theoretic core that can be explored, generalized, falsified, and computed.

If successful, this would make possible:
- theorem-driven holography in discrete geometry,
- certified algorithms for reconstructable regions,
- new entropy inequalities inspired by coding bounds,
- and a route from stabilizer-code logic to emergent geometry.

Application keywords: **holography, quantum error correction, entropy inequalities, submodularity, discrete geometry, geodesic reconstruction, stabilizer codes, bulk-boundary correspondence, information geometry, tensor networks, recoverability, combinatorial curvature**.

---

## Precise Mathematical Program

You should introduce a new structure encoding the holographic/code dictionary at the level of finite boundary regions.

### Novel definition 1: holographic entropy profile

Define a structure on a finite boundary type `α` with:
- an entropy functional `S : Finset α → ℝ`,
- an effective area functional `A : Finset α → ℝ`,
- a reconstruction distance proxy `d : Finset α → ℝ`,
- and axioms expressing normalization, monotonicity/submodularity where appropriate, and a coding-compatible relation between these quantities.

A possible Lean 4 sketch:

```lean
import Mathlib

open Finset

structure HolographicCodeProfile (α : Type*) [DecidableEq α] where
  S : Finset α → ℝ
  area : Finset α → ℝ
  dist : Finset α → ℝ
  S_empty : S ∅ = 0
  area_empty : area ∅ = 0
  dist_nonneg : ∀ X, 0 ≤ dist X
  area_nonneg : ∀ X, 0 ≤ area X
  S_nonneg : ∀ X, 0 ≤ S X
  submod_S : ∀ X Y, S X + S Y ≥ S (X ∩ Y) + S (X ∪ Y)
  rt_relation : ∀ X, S X = area X / 4
  singleton_like : ∀ X, S X ≤ (X.card : ℝ)
```

This is only a starting point. Improve it if the catalog context suggests stronger existing submodular or polymatroid infrastructure.

### Novel definition 2: curvature/syndrome defect

Define a defect functional measuring failure of exact additivity across a decomposition:
```lean
def syndromeDefect (H : HolographicCodeProfile α) (X Y : Finset α) : ℝ :=
  H.S X + H.S Y - H.S (X ∩ Y) - H.S (X ∪ Y)
```

Interpretation:
- `syndromeDefect H X Y = 0` means perfect additive reconstruction across overlap,
- positivity is a strong-subadditivity-type statement,
- nonzero defect is a curvature-like or syndrome-like obstruction.

This is mathematically fertile because it turns “gravity as syndrome” into an inequality/defect theory.

### Novel definition 3: coding-realizable profile

Introduce a finite combinatorial coding abstraction:
```lean
structure CodeLikeProfile (α : Type*) [DecidableEq α] where
  n : ℕ
  k : ℕ
  d : ℕ
  boundarySize : Finset α → ℕ
  entropyQubits : Finset α → ℕ
  singletonBound : n - k ≤ 2 * (d - 1)
  entropy_le_logical : ∀ X, entropyQubits X ≤ k
```

Then define when a holographic profile is compatible with a code-like profile via scaling laws:
```lean
structure CodeGeometryCorrespondence (α : Type*) [DecidableEq α] where
  H : HolographicCodeProfile α
  C : CodeLikeProfile α
  entropy_matches : ∀ X, H.S X = C.entropyQubits X
  area_counts : ∀ X, H.area X = boundarySize X
```

You may want to replace `ℕ` by `ℝ` or `ℚ` in the compatibility layer to avoid coercion friction.

---

## Theorem Targets

You must prove at least **3 deep theorems**. The following are the core targets.

### Theorem 1: RT-submodularity induces nonnegative syndrome defect
This is the foundational “gravity = defect” theorem.

**Statement.**
For every holographic code profile, the syndrome defect is nonnegative.

Lean target:
```lean
theorem syndromeDefect_nonneg
    {α : Type*} [DecidableEq α]
    (H : HolographicCodeProfile α) (X Y : Finset α) :
    0 ≤ syndromeDefect H X Y
```

This theorem is not deep by itself unless you set it inside a stronger framework. The real force comes from coupling it with equality/rigidity results below.

### Theorem 2: Exact RT relation converts submodularity into an area inequality
This is the first real bridge from information theory to geometry.

**Statement.**
If entropy equals quarter-area on all regions, then strong subadditivity is equivalent to the geometric inequality
\[
\mathrm{area}(X) + \mathrm{area}(Y) \ge \mathrm{area}(X \cap Y) + \mathrm{area}(X \cup Y).
\]

Lean target:
```lean
theorem area_submod_of_rt
    {α : Type*} [DecidableEq α]
    (H : HolographicCodeProfile α) (X Y : Finset α) :
    H.area X + H.area Y ≥ H.area (X ∩ Y) + H.area (X ∪ Y)
```

This theorem says: once the RT relation is imposed, a purely quantum-information inequality becomes a geometric one. That is already a meaningful formal bridge.

### Theorem 3: Singleton-type holographic bound
This is the coding-theoretic heart of the project.

Define an effective boundary size `N(X)` and effective distance proxy `D(X)` so that a region-wise holographic Singleton inequality takes the form
\[
N(X) - K(X) \le 2(D(X)-1),
\]
where `K(X)` is induced by entropy or logical content.

You need a mathematically precise finite formulation. For example:

```lean
structure RegionalCodeBound (α : Type*) [DecidableEq α] where
  N : Finset α → ℕ
  K : Finset α → ℕ
  D : Finset α → ℕ
  singleton_regional : ∀ X, N X - K X ≤ 2 * (D X - 1)
```

Then prove a theorem of the form:

```lean
theorem entropy_lower_bound_of_singleton
    {α : Type*} [DecidableEq α]
    (R : RegionalCodeBound α) (X : Finset α) :
    (R.K X : ℤ) ≥ (R.N X : ℤ) - 2 * ((R.D X : ℤ) - 1)
```

and then connect `K(X)` to `S(X)` and `N(X)` to area counts. If done cleanly, this gives a precise algebraic version of “Bekenstein-Hawking entropy is constrained by coding.”

The nontriviality comes from setting up the coercions and proving the inequality in a reusable abstract form, not by arithmetic automation alone.

### Theorem 4: Vanishing syndrome defect yields modularity/flatness
This is the first curvature theorem.

**Statement.**
If `syndromeDefect H X Y = 0`, then entropy is modular on the pair `(X,Y)`:
\[
S(X) + S(Y) = S(X\cap Y) + S(X\cup Y).
\]
Then derive the corresponding area modularity under RT.

Lean target:
```lean
theorem modular_of_zero_syndrome
    {α : Type*} [DecidableEq α]
    (H : HolographicCodeProfile α) (X Y : Finset α)
    (hzero : syndromeDefect H X Y = 0) :
    H.S X + H.S Y = H.S (X ∩ Y) + H.S (X ∪ Y)
```

and

```lean
theorem area_modular_of_zero_syndrome
    {α : Type*} [DecidableEq α]
    (H : HolographicCodeProfile α) (X Y : Finset α)
    (hzero : syndromeDefect H X Y = 0) :
    H.area X + H.area Y = H.area (X ∩ Y) + H.area (X ∪ Y)
```

Interpretation: zero syndrome means flat entropic geometry. This is a precise theorem in the “curvature from information” direction.

### Theorem 5: Reconstruction monotonicity
You need at least one theorem with actual finite-set induction or nontrivial case decomposition.

Define a region `X` to be reconstructable if its complement is too small to erase relative to the distance profile. Then prove monotonicity: if `X ⊆ Y` and `X` is reconstructable, so is `Y`.

Possible Lean shape:
```lean
def Reconstructable
    {α : Type*} [DecidableEq α]
    (D : Finset α → ℕ) (X U : Finset α) : Prop :=
  U ⊆ X ∧ (U \ X).card < D U

theorem reconstructable_monotone
    {α : Type*} [DecidableEq α]
    (D : Finset α → ℕ) (hmono : Monotone D)
    {X Y U : Finset α}
    (hXY : X ⊆ Y)
    (hrec : Reconstructable D X U) :
    Reconstructable D Y U
```

You may refine the definition; the point is to prove a theorem that genuinely models bulk reconstruction as error correction.

---

## One Cross-Domain Theorem Is Mandatory

You must include at least one theorem connecting **information theory and geometry** or **coding theory and order/lattice theory** in a non-cosmetic way.

The best candidate is an equivalence theorem:

```lean
theorem rt_submodularity_iff_area_submodularity
    {α : Type*} [DecidableEq α]
    (H : HolographicCodeProfile α) :
    (∀ X Y, H.S X + H.S Y ≥ H.S (X ∩ Y) + H.S (X ∪ Y)) ↔
    (∀ X Y, H.area X + H.area Y ≥ H.area (X ∩ Y) + H.area (X ∪ Y))
```

This is a genuine bridge:
- left side: entropy inequality / information theory,
- right side: geometric area inequality / discrete geometry.

If you can strengthen this to an order-isomorphism between classes of entropy profiles and area profiles under RT scaling, even better.

---

## Lean 4 Type Signatures to Aim For

Use or adapt the following exact signatures.

```lean
theorem syndromeDefect_nonneg
    {α : Type*} [DecidableEq α]
    (H : HolographicCodeProfile α) (X Y : Finset α) :
    0 ≤ syndromeDefect H X Y
```

```lean
theorem area_submod_of_rt
    {α : Type*} [DecidableEq α]
    (H : HolographicCodeProfile α) (X Y : Finset α) :
    H.area X + H.area Y ≥ H.area (X ∩ Y) + H.area (X ∪ Y)
```

```lean
theorem modular_of_zero_syndrome
    {α : Type*} [DecidableEq α]
    (H : HolographicCodeProfile α) (X Y : Finset α)
    (hzero : syndromeDefect H X Y = 0) :
    H.S X + H.S Y = H.S (X ∩ Y) + H.S (X ∪ Y)
```

```lean
theorem area_modular_of_zero_syndrome
    {α : Type*} [DecidableEq α]
    (H : HolographicCodeProfile α) (X Y : Finset α)
    (hzero : syndromeDefect H X Y = 0) :
    H.area X + H.area Y = H.area (X ∩ Y) + H.area (X ∪ Y)
```

```lean
theorem rt_submodularity_iff_area_submodularity
    {α : Type*} [DecidableEq α]
    (H : HolographicCodeProfile α) :
    (∀ X Y, H.S X + H.S Y ≥ H.S (X ∩ Y) + H.S (X ∪ Y)) ↔
    (∀ X Y, H.area X + H.area Y ≥ H.area (X ∩ Y) + H.area (X ∪ Y))
```

```lean
theorem reconstructable_monotone
    {α : Type*} [DecidableEq α]
    (D : Finset α → ℕ)
    (hmono : ∀ {X Y : Finset α}, X ⊆ Y → D X ≤ D Y)
    {X Y U : Finset α}
    (hXY : X ⊆ Y)
    (hUX : U ⊆ X)
    (hrec : U.card < D U) :
    U ⊆ Y ∧ U.card < D U
```

You should also include at least one theorem with induction on `Finset.card` or structural decomposition of finite sets.

---

## Proof Strategy Architecture

You must pursue at least 2–3 proof routes and choose the strongest.

### Strategy A: Direct finite-set entropy algebra
Most promising for Lean.

1. Encode entropy/area relations as functions on `Finset α`.
2. Define `syndromeDefect` and prove positivity directly from submodularity.
3. Rewrite using `rt_relation` to transfer entropy inequalities to area inequalities.
4. Derive rigidity results from zero defect by linear rearrangement.

Why promising: it uses mature Mathlib support for `Finset`, inequalities, and algebraic rewriting, and gives multiple nontrivial theorems with low analytic overhead.

### Strategy B: Lattice-theoretic / polymatroid route
Potentially deeper and more reusable.

1. Regard `S` as a rank-like function on the distributive lattice of finite subsets.
2. Prove that `S` defines a polymatroid-type object under normalization, monotonicity, and submodularity.
3. Transport the polymatroid structure to `area` via RT scaling.
4. Study modular pairs as “flat” regions and define curvature defect as deviation from modularity.

Why this may be superior scientifically: it places holography inside the theory of submodular rank functions, opening connections to matroids, optimization, and combinatorial geometry. If the catalog already contains submodular machinery, exploit it aggressively.

### Strategy C: Coding-bound abstraction via order inequalities
Best for the Singleton side.

1. Introduce an abstract regional coding bound structure.
2. Prove integer and real-valued lower bounds on logical entropy from Singleton inequalities.
3. Map area counts and entropy values into this framework.
4. Deduce holographic entropy lower bounds and identify when equality forces extremal code geometry.

Why valuable: this creates the first exact formal interface between coding bounds and geometric entropy proxies. It is the right place to formulate falsifiable conjectures.

Recommended path: **A + C**, with selective use of **B** if the catalog context reveals existing polymatroid/submodular lemmas.

---

## Nontrivial Tactic Requirements

At least 3 theorems must use deep proof patterns such as:
- induction on `Finset.card` or decomposition via `Finset.induction_on`,
- `rcases` on subset/intersection/union structure,
- `by_contra` to derive impossibility of a negative defect,
- `field_simp` if you normalize RT constants with rational coefficients like `1/4`,
- multi-step `calc` blocks for inequality transport.

Do **not** cheapen the file with theorem statements whose only proof is `native_decide`, `decide`, `norm_num`, or `rfl`.

---

## Falsifiable Conjecture with Computational Test

You must state at least one explicit conjecture and provide a computational test in Lean/Python that could refute it.

### Conjecture: extremal holographic profiles are modular on geodesic laminar families
For a finite boundary set `α`, suppose `H : HolographicCodeProfile α` saturates a regional Singleton bound on every member of a laminar family `𝓛`. Then for all `X Y ∈ 𝓛`,
\[
\text{syndromeDefect}(H,X,Y)=0.
\]

Interpretation: extremal coding efficiency forces entropic flatness along noncrossing geodesics.

This is falsifiable: enumerate small laminar families and random submodular profiles satisfying the axioms; search for a counterexample.

Possible Lean-facing formulation:
```lean
conjecture singleton_saturation_implies_zero_syndrome_on_laminar
    {α : Type*} [DecidableEq α]
    (H : HolographicCodeProfile α)
    (L : Finset (Finset α)) : Prop
```

In `demo.py`, test small finite examples by generating candidate submodular functions and checking whether saturation implies zero defect.

A second, stronger conjecture if you want more ambition:

### Conjecture: holographic entropy profiles form a scaled polymatroid cone
Every finite holographic profile satisfying RT and submodularity belongs to a cone linearly equivalent to a cone of code-realizable rank functions.

This would be revolutionary if even partial evidence emerges.

---

## Cross-Domain Connections to Develop

Do not leave these as buzzwords; prove at least one theorem embodying one of them.

1. **Quantum information ↔ discrete geometry**  
   RT converts entropy inequalities into area inequalities.

2. **Coding theory ↔ lattice theory**  
   The boundary-region poset carries a rank-like function; modular pairs correspond to flat sectors.

3. **Physics ↔ combinatorial optimization**  
   Reconstructable regions can be characterized by monotone feasible sets, suggesting min-cut/max-flow analogues.

4. **Entropy ↔ curvature**  
   The syndrome defect behaves like a discrete curvature scalar: zero means flat/modular, positive means nontrivial interaction.

5. **Tensor networks ↔ graph theory**  
   If you can define a graph-cut model for area, prove that min-cut submodularity induces RT-submodularity.

That last point could lead to an additional theorem:
```lean
theorem mincut_area_submodular
    -- formulate on finite weighted graphs if feasible
```
Only pursue this if the catalog context contains graph cut lemmas you can leverage.

---

## What Would Count as a Breakthrough Here?

A true success is not “I encoded a definition and proved a toy inequality.” A true success is:

- a new formal object, like `HolographicCodeProfile`,
- a theorem turning entropy axioms into geometry,
- a theorem turning coding bounds into entropy/area constraints,
- a defect/rigidity theorem interpreting syndrome as curvature,
- and a computational exploration showing the conjecture survives nontrivial finite tests.

That would establish a rigorous finite analogue of the slogan:
**geometry is the visible face of information constraints**.

---

## Deliverables (ALL mandatory)

You must produce all of the following:

1. **Lean file(s)** with:
   - at least 3 nontrivial theorems,
   - at least one novel definition,
   - at least one cross-domain theorem,
   - at least one falsifiable conjecture,
   - minimized sorry usage.

2. **A verified algorithm or computational method**  
   Examples:
   - an algorithm computing `syndromeDefect` over all pairs of boundary regions,
   - a checker for RT-induced area submodularity,
   - or a search procedure for counterexamples to the conjecture on small finite boundaries.

3. **demo.py**  
   Must interactively:
   - generate finite region systems,
   - compute entropy/area/defect tables,
   - test the conjecture on random or structured examples,
   - and display whether modularity/flatness emerges under Singleton saturation.

4. **RESEARCH_PAPER.md**  
   A standalone scientific paper explaining:
   - the mathematical setup,
   - exact theorem statements,
   - proof ideas,
   - why this is a genuine bridge between coding and geometry,
   - computational evidence,
   - and what comes next.
   Someone reading only this document must understand the discovery without seeing the code.

5. **ARTICLE.md**  
   Scientific American style. Engaging, idea-driven, accessible.  
   Taboo: do **not** focus on formal verification machinery. Focus on the mathematics and conceptual significance: how geometry might emerge from information constraints.

6. **FUTURE_DIRECTIONS.md**  
   Include 3–5 original research directions.  
   Each direction must contain the exact sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain, such as matroid theory, graph cuts, statistical physics, or quantum complexity.

---

## Final Charge

Do not merely formalize a slogan from physics. Extract a theorem-bearing mathematical nucleus that can survive outside physics entirely. If you succeed, you will have built the first verified framework in which:

- entropy acts like rank,
- area acts like geometry,
- syndrome acts like curvature,
- and recoverability acts like locality.

That is the beginning of a new language for spacetime.

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
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
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
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
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

Research domain: Speculative
Research mode: prove
