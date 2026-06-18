Soli Deo Gloria

## Assignment: Direction 2: Valuated Matroid Theory via k-Fold Log-Concavity

**Mode: prove / discover**

You are to build a new theory, not merely verify folklore. The goal is to turn the heuristic “iterated ratio transforms measure discrete curvature depth” into a precise invariant of valuated matroids and to connect it to tropical convexity, discrete convex analysis, and Hodge/Lorentzian phenomena.

Work in Lean 4 with Mathlib, and explicitly build on catalog lemmas such as:

- `mixedLogConcave_mul`
- `directionalLogConcave_mul`
- `negLog_supermodular_of_mixed`

Use them as structural engines, not as endpoints. The ambition is to define and prove the first mathematically meaningful **depth filtration** on valuated matroids arising from repeated directional log-concavity.

---

## Core Vision

A valuated matroid is usually detected through tropical Plücker-style exchange inequalities, M-convexity, or submodularity of the negative valuation. These are “first-order” shadows. Your task is to define a **higher-order curvature hierarchy**: repeated ratio transforms should expose whether a valuation behaves like a discrete object of class \(C^k\), with infinite depth corresponding to a hidden Lorentzian rigidity.

The breakthrough would be a theorem showing that this depth is:

1. **intrinsic**,
2. **stable under natural operations**,
3. **visible tropically via supermodularity/submodularity**, and
4. **strictly finer than ordinary exchange/M-convexity data**.

If successful, this opens a new field: **higher discrete curvature theory for valuated matroids**.

---

## Precise Mathematical Program

Let \( \alpha \) be a finite index type, and let functions \( f : (\alpha \to \mathbb{N}) \to \mathbb{R}_{\ge 0} \) be supported on a fixed degree slice
\[
\sum_i m(i) = d.
\]
For indices \(i\), define the ratio transform heuristically by
\[
R_i f(m) = \frac{f(m + e_i)}{f(m)}
\]
when both terms are meaningful and \(f(m) \neq 0\). Since division on zeros is delicate, you should introduce a robust formalization that is actually Lean-friendly.

### Mandatory new definition
Define a new concept not already in the catalog, such as one of the following:

1. `DirectionalDepthAtLeast k f`
2. `ValuatedMatroidDepthAtLeast k f`
3. `RatioStableOnSlice d f`
4. `ExchangeClosedSupport f d`

A recommended route is:

- define a safe ratio-transform predicate on the support,
- define iterated directional log-concavity by recursion,
- define the maximal depth (or “infinite depth” as a proposition over all `k`).

For example, a Lean-facing scaffold could look like:

```lean
def degreeSlice (d : ℕ) (m : α → ℕ) : Prop :=
  (∑ i, m i) = d

def exchangeClosedSupport (f : (α → ℕ) → ℝ) (d : ℕ) : Prop := 
  ∀ ⦃m n : α → ℕ⦄, degreeSlice d m → degreeSlice d n →
    0 < f m → 0 < f n →
    ∀ ⦃i : α⦄, m i < n i →
      ∃ j, n j < m j ∧ 0 < f (Function.update m i (m i + 1) |> Function.update j (m j - 1))

def ratioTransform (i : α) (f : (α → ℕ) → ℝ) : ((α → ℕ) → ℝ) :=
  fun m => f (m + Pi.single i 1) / f m

def directionalDepthAtLeast : ℕ → ((α → ℕ) → ℝ) → Prop
| 0, f => True
| k+1, f => directionalLogConcave f ∧ ∀ i, directionalDepthAtLeast k (ratioTransform i f)
```

You may need to replace the naïve `m + Pi.single i 1` by a dedicated additive update operation with lemmas about degree changes, positivity, and support compatibility. That is good mathematics, not boilerplate.

---

## Main theorem targets

You must prove at least **3 substantial theorems**, each using genuine proof structure: induction, `rcases`, `by_contra`, `field_simp`, nontrivial `calc`, case analysis on support, or recursive arguments. No trivial theorem proving by enumeration.

### Theorem 1: Multiplicative depth stability
This should be your foundational theorem.

#### Mathematical statement
If \(f\) and \(g\) each have directional depth at least \(k\), then so does their product. In particular, the classes of functions of depth \(\ge k\) form multiplicative monoids.

#### Lean 4 target signature
```lean
theorem directionalDepthAtLeast_mul
    [Fintype α] [DecidableEq α]
    (k : ℕ) (f g : (α → ℕ) → ℝ)
    (hf : directionalDepthAtLeast k f)
    (hg : directionalDepthAtLeast k g) :
    directionalDepthAtLeast k (fun m => f m * g m)
```

#### Why this matters
This upgrades `mixedLogConcave_mul` and `directionalLogConcave_mul` from first-order closure to an **entire depth filtration**. It is the algebraic backbone of the theory: without it, the hierarchy is just a curiosity; with it, it becomes a robust invariant under tropical/product constructions.

#### Proof strategy options
**Strategy A: induction on `k`**
1. Base case `k = 0` is immediate from the definition.
2. For `k+1`, extract first-order directional log-concavity of `f` and `g`.
3. Use `directionalLogConcave_mul` for the first layer, then prove the iterated claim by showing the ratio transform of a product factors:
   \[
   R_i(fg) = R_i(f)\,R_i(g),
   \]
   and invoke the induction hypothesis.

**Strategy B: recursive monoid structure**
1. Define the typeclass-like predicate “depth at least `k`” as a recursive multiplicative closure.
2. Prove a general lemma that any operator preserving products lifts multiplicativity one level up.
3. Instantiate with `ratioTransform`.

**Most promising:** Strategy A. It directly exploits catalog theorems and makes the recursive geometry transparent.

---

### Theorem 2: Depth implies tropical higher convexity
This is the crucial bridge theorem.

#### Mathematical statement
If \(f\) has depth at least \(1\) (or more strongly, mixed log-concavity on a degree slice), then \(-\log f\) is supermodular/submodular on the support in the tropical sense. You should then prove a strengthened statement: if \(f\) has depth at least \(k+1\), then every first ratio transform \(R_i f\) also tropicalizes to a supermodular potential of one lower depth.

This is the seed of a recursive tropical Hodge theory.

#### Lean 4 target signature
A realistic pair of theorems:

```lean
theorem negLog_supermodular_of_depth_one
    [Fintype α] [DecidableEq α]
    (f : (α → ℕ) → ℝ)
    (hf_pos : ∀ m, 0 < f m)
    (hf : directionalDepthAtLeast 1 f) :
    Supermodular (fun m => - Real.log (f m))
```

and the recursive transport theorem:

```lean
theorem negLog_supermodular_ratio_of_depth_succ
    [Fintype α] [DecidableEq α]
    (k : ℕ) (i : α) (f : (α → ℕ) → ℝ)
    (hf_pos : ∀ m, 0 < f m)
    (hf : directionalDepthAtLeast (k+1) f) :
    Supermodular (fun m => - Real.log (ratioTransform i f m))
```

If `Supermodular` is not already in the exact desired form, define an appropriate predicate on functions over lattice points and prove equivalence to the available catalog notion where possible.

#### Why this matters
This theorem says the hierarchy is not merely algebraic but **tropical-geometric**. The iterated ratio transform becomes a machine producing a tower of tropical convex potentials. This is the conceptual leap: higher log-concavity becomes higher tropical convexity.

#### Proof strategy options
**Strategy A: reduction to catalog bridge**
1. Use `directionalDepthAtLeast (k+1) f` to extract directional/mixed log-concavity of `ratioTransform i f`.
2. Apply `negLog_supermodular_of_mixed` to the ratio transform.
3. Transfer positivity assumptions through division using `field_simp` and positivity lemmas.

**Strategy B: direct logarithmic inequality**
1. Rewrite the supermodular inequality after applying `-log`.
2. Convert sums of logs into logs of products.
3. Use directional log-concavity inequalities of `f` and its ratios directly.

**Most promising:** Strategy A, because it leverages catalog theorems and avoids fragile analytic manipulations except where positivity is needed.

---

### Theorem 3: Exchange-closed support + depth one gives M-convex shadow
This is your first bridge to valuated matroid theory proper.

#### Mathematical statement
For a function on a fixed degree slice with exchange-closed support, depth at least 1 forces a discrete exchange inequality on the tropical valuation \(v = -\log f\). Formalize a theorem showing that from directional log-concavity plus support exchange-closure, one obtains a weak M-convexity/exchange axiom for `v`.

Even if the full valuated matroid equivalence is too large for one cycle, prove a rigorous one-sided theorem.

#### Lean 4 target signature
Something like:

```lean
theorem weak_exchange_of_depth_one
    [Fintype α] [DecidableEq α]
    (d : ℕ) (f : (α → ℕ) → ℝ)
    (hf_pos : ∀ m, 0 < f m)
    (hsupp : exchangeClosedSupport f d)
    (hf : directionalDepthAtLeast 1 f) :
    ∀ ⦃m n : α → ℕ⦄,
      degreeSlice d m →
      degreeSlice d n →
      ∀ ⦃i : α⦄, m i < n i →
      ∃ j, n j < m j ∧
        (- Real.log (f m) - Real.log (f n))
          ≤
        (- Real.log (f (exchangeMove m i j)) - Real.log (f (exchangeMove n j i)))
```

You will need to define `exchangeMove` carefully.

#### Why this matters
This is the theorem that makes the hierarchy relevant to valuated matroids rather than merely to combinatorial analysis. It says first-order depth already produces an exchange law in the tropicalized valuation. That is the first rigorous evidence that your depth filtration refines Murota’s M-convexity.

#### Proof strategy options
**Strategy A: local-to-global exchange via supermodularity**
1. Convert depth one into supermodularity of `-log f`.
2. Use degree-slice conservation to identify admissible exchange coordinates.
3. Derive the exchange inequality by applying supermodularity to a pair of neighboring lattice points and summing via a `calc` chain.

**Strategy B: ratio-monotonicity**
1. Show directional log-concavity implies monotonicity of directional ratios along exchange directions.
2. Compare `R_i f` and `R_j f` between `m` and `n`.
3. Rearrange via logarithms to obtain the exchange inequality.

**Most promising:** Strategy B is conceptually deeper and closer to valuated matroid language; Strategy A is more likely to formalize quickly. If possible, prove A first and isolate B as a stronger lemma.

---

## Stretch theorem: strictness of the hierarchy

A field-opening result would be to exhibit a function with depth at least 1 but not depth at least 2, or at least to prove a conditional criterion producing such examples.

#### Lean 4 target signature
```lean
theorem exists_depth_one_not_depth_two
    : ∃ (α : Type) (_ : Fintype α) (_ : DecidableEq α)
        (f : (α → ℕ) → ℝ),
        directionalDepthAtLeast 1 f ∧
        ¬ directionalDepthAtLeast 2 f
```

If this full existential theorem is too ambitious, prove a parameterized criterion:

```lean
theorem not_depth_two_of_ratio_failure
    [Fintype α] [DecidableEq α]
    (f : (α → ℕ) → ℝ)
    (h1 : directionalDepthAtLeast 1 f)
    (i : α)
    (hfail : ¬ directionalLogConcave (ratioTransform i f)) :
    ¬ directionalDepthAtLeast 2 f
```

This is still substantial and gives a computational route to strictness.

---

## Cross-domain connections you must explicitly develop

At least one theorem and one discussion section must connect this project to a different domain.

### 1. Tropical geometry
The tropicalization \(v = -\log f\) should be treated as a discrete potential. Depth becomes a hierarchy of tropical convexity classes. This is not cosmetic: it suggests a new notion of **higher tropical curvature**.

### 2. Hodge/Lorentzian geometry
Interpret depth as a discrete analog of repeated directional positivity. The slogan is:
- depth \(1\) corresponds to first-order Lorentzian behavior,
- depth \(k\) corresponds to persistence of Lorentzianity under \(k\) logarithmic directional derivatives.

You do not need to formalize full Lorentzian polynomial theory, but you should state clearly how your invariant is intended as a valuated-matroid shadow of Hodge-Riemann positivity.

### 3. Statistical physics / information geometry
The function \(-\log f\) is an energy landscape. Ratio transforms are discrete chemical potentials / local free-energy increments. Depth then measures the persistence of convexity under repeated renormalized local response. This is a genuine cross-domain bridge, not an analogy for style points.

A possible formal theorem here is a monotonicity/convexity statement for “local free energy increments” derived from the ratio transform.

#### Example Lean-facing theorem
```lean
theorem ratio_energy_supermodular
    [Fintype α] [DecidableEq α]
    (i : α) (f : (α → ℕ) → ℝ)
    (hf_pos : ∀ m, 0 < f m)
    (hf : directionalDepthAtLeast 2 f) :
    Supermodular (fun m => - Real.log (ratioTransform i f m))
```

This can be presented both as tropical convexity and as discrete response convexity in statistical mechanics.

---

## Conjecture with testable prediction

You must state and computationally probe at least one falsifiable conjecture.

### Primary conjecture
**Conjecture (Depth Dichotomy for Natural Valuated Matroids).**
For every naturally arising valuated matroid \(v\) from one of the classes below, either:
1. the associated positive weight function \(f = \exp(-v)\) has infinite directional depth, or
2. it has depth exactly \(1\).

There are no natural examples of depth exactly \(2,3,\dots\) below the algebro-geometric boundary.

Classes to test:
- uniform matroid valuations,
- weighted graphical matroid valuations,
- valuated matroids from tropical Plücker vectors / Grassmannians.

This is falsifiable: a single explicit example with depth exactly \(2\) disproves it.

### Computational prediction
For graphical matroids with generic edge weights on small graphs:
- trees and cycles should have infinite depth,
- the first finite-depth examples, if they exist, should appear on graphs with overlapping circuits such as theta graphs or \(K_4\)-type structures.

### Lean-friendly conjecture wrapper
You may encode a finite version for experimentation:
```lean
def hasExactDepth (k : ℕ) (f : (α → ℕ) → ℝ) : Prop :=
  directionalDepthAtLeast k f ∧ ¬ directionalDepthAtLeast (k+1) f
```

and state:
```lean
conjecture first_nontrivial_graphical_example_occurs_on_overlap_circuit_graph :
  ∃ f, hasExactDepth 2 f
```

Then use `demo.py` to search finite weighted examples.

---

## Proof architecture and implementation guidance

### Step 1: Build the combinatorial infrastructure
You will likely need:
- a degree-slice predicate,
- additive single-coordinate updates,
- an exchange move operation,
- lemmas about preservation of total degree under exchange,
- positivity transport lemmas for ratio transforms.

This is essential, not overhead.

### Step 2: Define recursive depth carefully
The definition should make induction on `k` natural. Avoid definitions that bake in impossible side conditions globally. Prefer:
- a recursive predicate,
- separate positivity hypotheses in theorems,
- local support assumptions where needed.

### Step 3: Lift catalog first-order theorems recursively
The crucial idea is:
- first-order log-concavity lives in the catalog,
- your novelty is to **iterate** it and prove closure under iteration.

### Step 4: Tropicalize
Push every meaningful first-order and higher-order theorem through `-Real.log`, using positivity hypotheses. This is where the theory becomes geometrically interpretable.

### Step 5: Extract exchange consequences
Even a weak exchange theorem is enough to justify the phrase “graded refinement of M-convexity.”

---

## Application keywords

Use these explicitly in the paper and article:

- valuated matroids
- M-convexity
- discrete convex analysis
- tropical geometry
- Lorentzian polynomials
- Hodge theory
- higher-order log-concavity
- supermodularity
- exchange axiom
- tropical Grassmannian
- graphical matroids
- energy landscapes
- information geometry
- statistical mechanics
- combinatorial curvature
- discrete Hessian
- renormalized ratio transform

---

## Minimum theorem checklist

Your Lean development must include at least these kinds of results:

1. **A recursive closure theorem**
   - e.g. `directionalDepthAtLeast_mul`.

2. **A tropical bridge theorem**
   - e.g. `negLog_supermodular_of_depth_one` or its recursive ratio version.

3. **A valuated-matroid exchange theorem**
   - e.g. `weak_exchange_of_depth_one`.

4. **A strictness or obstruction theorem**
   - e.g. `not_depth_two_of_ratio_failure`.

At least 3 of these must be fully proved with nontrivial tactics and argument structure.

---

## Deliverables (ALL mandatory)

You must produce all of the following:

### 1. Lean file(s)
Containing:
- the new definitions,
- at least 3 deep theorems,
- minimized `sorry`,
- explicit use of nontrivial proof tactics (`induction`, `rcases`, `by_contra`, `field_simp`, `calc`, etc.),
- at least one cross-domain theorem.

### 2. `FUTURE_DIRECTIONS.md`
Provide **3–5 original research directions**. Each direction must include:
- a sentence beginning exactly with **“The key insight is...”**
- a sentence beginning exactly with **“Why now?”**
At least one direction must bridge to a different domain, such as statistical physics, algebraic geometry, or information theory.

### 3. `RESEARCH_PAPER.md`
A standalone scientific document that explains:
- the problem,
- the new definitions,
- the main theorems,
- why the depth filtration is a breakthrough,
- how it refines M-convexity,
- what computational evidence says,
- what should be done next.

A reader with no access to the code must still understand the discovery.

### 4. `ARTICLE.md`
Write this in **Scientific American style**:
- engaging,
- broad-audience accessible,
- focused on the mathematics and significance,
- **do not focus on formal verification machinery**,
- explain why repeated ratio transforms reveal hidden geometric layers in combinatorial optimization and tropical geometry.

### 5. Verified algorithm / computational method
You must implement a mathematically meaningful algorithm, not just theorem statements. Recommended:

- an algorithm that computes or lower-bounds directional depth on finite degree slices,
- or a checker for failure of depth at level `k`,
- or a search procedure for exact-depth examples among small graphical/uniform valuations.

The algorithm should be tied to your definitions and justified by proved lemmas.

### 6. `demo.py`
An interactive demo that:
- constructs sample functions/valuations,
- computes empirical depth profiles,
- tests the conjecture on small examples,
- visualizes or prints where depth fails,
- includes uniform, graphical, and at least one Grassmannian-inspired toy family if feasible.

---

## Final standard

Do not settle for “another closure lemma.” The target is a new invariant:
\[
\text{depth}(f) \in \mathbb{N} \cup \{\infty\},
\]
interpretable simultaneously as:
- an iterated log-concavity order,
- a tropical convexity persistence length,
- and a proto-Lorentzian complexity measure for valuated matroids.

If you can prove that this depth is multiplicative, tropicalizable, and exchange-detecting, you will have created a new language for valuated matroid theory.

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

Research domain: Pythagorean
Research mode: prove
