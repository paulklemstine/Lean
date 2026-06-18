Mode: prove

# Breakthrough Objective

Prove a genuine structural theorem about dynamics under semiconjugacy: **periodic complexity can only collapse, and the collapse is arithmetically controlled by divisibility of minimal periods**. This is not a routine lemma; it is the atomic statement behind factor dynamics, symbolic coding, quotient systems, finite-state abstractions, and renormalization of discrete evolution. If formalized cleanly in Lean 4 at the level of `Function.Semiconj` and `Function.minimalPeriod`, it opens a reusable interface for transporting orbit structure across domains.

The target theorem is:

```lean
theorem semiconj_minimalPeriod_dvd
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g)
    {x : α} :
    Function.minimalPeriod g (h x) ∣ Function.minimalPeriod f x
```

This exact statement is too optimistic without a periodicity hypothesis on `x`: if `x` is not periodic, then `minimalPeriod f x = 0` in the usual Mathlib convention, and the image point need not behave as desired unless one carefully uses the zero case. The mathematically sharp theorem should therefore be one of the following two forms.

## Primary theorem candidate

```lean
theorem semiconj_minimalPeriod_dvd
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g)
    {x : α} (hx : Function.PeriodicPt f x) :
    Function.minimalPeriod g (h x) ∣ Function.minimalPeriod f x
```

If `Function.PeriodicPt` is not the Mathlib name in this namespace, use the available periodic-point hypothesis and derive the corresponding witness. A more explicit and often easier-to-use variant is:

```lean
theorem semiconj_minimalPeriod_dvd_of_isPeriodicPt
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g)
    {x : α} {n : ℕ} (hx : Function.IsPeriodicPt f n x) :
    Function.minimalPeriod g (h x) ∣ Function.minimalPeriod f x
```

Depending on the exact Mathlib API, you may need positivity of `n` or an auxiliary lemma converting `IsPeriodicPt f n x` into periodicity of `x`.

## Even stronger theorem worth aiming for

The true conceptual statement is that semiconjugacy transports periodicity and bounds minimal period by any period witness:

```lean
theorem semiconj_minimalPeriod_dvd_of_isPeriodicPt'
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g)
    {x : α} {n : ℕ} (hx : Function.IsPeriodicPt f n x) :
    Function.minimalPeriod g (h x) ∣ n
```

From this, your desired theorem follows immediately once you know that
`Function.IsPeriodicPt f (Function.minimalPeriod f x) x`.

This stronger version is the one that changes the game: it says **every period upstairs induces a period downstairs**, so the downstairs minimal period divides every upstairs period, hence in particular the minimal one.

# Why this is a breakthrough

This theorem is the arithmetic core of factor dynamics:

- quotient systems collapse orbit lengths by divisibility,
- symbolic codings cannot create new primitive periods,
- finite abstractions of deterministic systems preserve periodic signatures only by compression,
- dynamical invariants become transportable through certified simulation maps.

Formalizing this in Lean gives a universal lemma that can be reused in:
- discrete dynamical systems,
- automata and transition systems,
- graph endomorphisms,
- cellular automata factors,
- Markov partition codings,
- neural/state-space compression viewed as semiconjugacy,
- renormalization-style coarse graining.

This is exactly the kind of theorem that looks elementary in hindsight but becomes a foundational bridge once certified.

# Lean 4 formal target

Start by locating the exact Mathlib names around:
- `Function.Semiconj`
- `Function.IsPeriodicPt`
- `Function.PeriodicPt`
- `Function.minimalPeriod`
- lemmas characterizing minimal period divisibility

A likely final theorem family is:

```lean
theorem semiconj_isPeriodicPt
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g)
    {x : α} {n : ℕ} (hx : Function.IsPeriodicPt f n x) :
    Function.IsPeriodicPt g n (h x)
```

```lean
theorem semiconj_minimalPeriod_dvd_of_isPeriodicPt
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g)
    {x : α} {n : ℕ} (hx : Function.IsPeriodicPt f n x) :
    Function.minimalPeriod g (h x) ∣ n
```

```lean
theorem semiconj_minimalPeriod_dvd
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g)
    {x : α} (hx : Function.PeriodicPt f x) :
    Function.minimalPeriod g (h x) ∣ Function.minimalPeriod f x
```

If Mathlib already contains part of this, do not settle for rediscovery: package the strongest clean API theorem and prove the downstream corollaries.

# Proof architecture: three viable strategies

## Strategy A: iterate transport + minimal-period universal property
Most promising.

1. Prove by induction on `n` or by using iterate lemmas that semiconjugacy respects iterates:
   ```lean
   hsemi.iterate_right
   ```
   or derive:
   ```lean
   h (f^[n] x) = g^[n] (h x)
   ```
2. From `hx : Function.IsPeriodicPt f n x`, rewrite `f^[n] x = x`, apply `h`, and conclude:
   ```lean
   g^[n] (h x) = h x
   ```
   hence `Function.IsPeriodicPt g n (h x)`.
3. Invoke the defining theorem for `Function.minimalPeriod` saying that if `h x` is periodic with period `n`, then `minimalPeriod g (h x) ∣ n`.

Why this is best: it isolates the entire proof into two canonical mechanisms already likely present in Mathlib—iterate transport and minimal-period divisibility. It is robust, short, and maximally reusable.

## Strategy B: prove the stronger “period set inclusion” theorem
Conceptually richer.

1. Define or reason about the set
   ```lean
   {n : ℕ | Function.IsPeriodicPt f n x}
   ```
   and similarly for `g (h x)`.
2. Show:
   ```lean
   {n | IsPeriodicPt f n x} ⊆ {n | IsPeriodicPt g n (h x)}
   ```
   via semiconjugacy of iterates.
3. Deduce that the infimum/least positive period downstairs divides the least positive period upstairs.

Why this matters: it reframes the theorem as a monotonicity statement for period spectra under factors. This opens a path toward future work on orbit monoids, zeta functions, and entropy-like invariants.

## Strategy C: contradiction via minimality
Useful if divisibility lemmas are awkward in the API.

1. Show `m := minimalPeriod f x` is a period of `x`.
2. Transport that period to `h x`, so `m` is a period downstairs.
3. Use the minimality characterization of `minimalPeriod g (h x)` to conclude it divides `m`.

This is more manual but often easier if the library has a theorem of the form “minimal period is the least positive period” rather than a ready-made divisibility lemma.

# Key Mathlib building blocks to search for

You should aggressively grep/import around `dynamics` and `order of elements`-style APIs. Likely useful lemmas include names morally similar to:

- `Function.Semiconj.iterate_right`
- `Function.Semiconj.iterate_left`
- `Function.IsPeriodicPt.comp`
- `Function.minimalPeriod_dvd`
- `Function.isPeriodicPt_minimalPeriod`
- `Function.minimalPeriod_eq_zero_iff`
- `Function.minimalPeriod_pos`
- `Function.periodicPt_iff_exists_isPeriodicPt`

Even if the exact names differ, the proof should be built around these concepts.

# Nontrivial refinements worth proving in the same file

If the primary theorem falls quickly, push immediately to one or more of these.

## 1. Conjugacy preserves minimal period exactly
Under bijective semiconjugacy / conjugacy, divisibility upgrades to equality:

```lean
theorem conjugate_minimalPeriod_eq
    {α β : Type*} {f : α → α} {g : β → β} {e : α ≃ β}
    (hconj : Function.Semiconj e f g)
    {x : α} (hx : Function.PeriodicPt f x) :
    Function.minimalPeriod g (e x) = Function.minimalPeriod f x
```

This becomes the formal statement that minimal period is a conjugacy invariant.

## 2. Injective semiconjugacy preserves minimal period exactly
If `h` is injective, no period collapse can occur:

```lean
theorem semiconj_minimalPeriod_eq_of_injective
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g) (hinj : Function.Injective h)
    {x : α} (hx : Function.PeriodicPt f x) :
    Function.minimalPeriod g (h x) = Function.minimalPeriod f x
```

This is stronger than divisibility and has real conceptual bite.

## 3. Eventual periodicity descends under semiconjugacy
A major extension:

```lean
theorem semiconj_isEventualPeriodicPt
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g)
    {x : α} :
    Function.IsEventualPeriodicPt f x →
    Function.IsEventualPeriodicPt g (h x)
```

This opens the door to finite-state reductions and symbolic dynamics.

# Cross-domain connections you should explicitly exploit

## Dynamical systems ↔ automata theory
A deterministic automaton transition map is an endofunction. A homomorphic image of automata is exactly semiconjugacy. Your theorem says cycle lengths in quotient automata divide cycle lengths upstairs. This is a certified theorem about state compression.

## Dynamical systems ↔ symbolic dynamics
Factor maps between subshifts are semiconjugacies. Periodic orbit lengths in the factor divide those in the extension. Formalizing the abstract theorem now prepares a future attack on zeta functions and entropy bounds in symbolic systems.

## Dynamical systems ↔ program verification / model reduction
Abstract interpretation and transition-system simulation often produce a map commuting with dynamics. Then periodic bugs/cycles in the abstraction correspond to compressed cycles in the concrete system. This is a theorem about correctness of cyclic behavior under abstraction.

## Dynamical systems ↔ physics / renormalization
Coarse-graining maps in discrete renormalization behave like semiconjugacies. Period collapse by divisibility is the arithmetic shadow of universality under scale change. This is the bridge to the catalog’s “closure duality”, “transport”, and “renormalization” themes, even if those specific listed theorems are not directly reusable in Lean proof terms.

# How to connect to the catalog theorems meaningfully

The listed catalog theorems are cross-domain exemplars rather than obvious local dependencies. Use them as architectural inspiration:

- `TheoryHom.transport_theorem_comp` suggests a transport principle under compositional structure. Your theorem is a transport theorem for periodic arithmetic under semiconjugacy.
- `boundary_capacity_ext_same_type` and `compression_theorem` indicate quotient/compression invariants. Your result is the dynamical arithmetic invariant underlying compression.
- `clifford_type_bound` and `partition_function_bound` show the project values certified structural bounds. Here the bound is exact divisibility of minimal periods.

Do not force irrelevant imports. Instead, state in comments or accompanying notes that this theorem is the **dynamical transport/compression law** parallel to those certified bridge theorems.

# Concrete implementation advice in Lean

1. First prove iterate transport:
   ```lean
   have hiter := hsemi.iterate_right (n := n)
   ```
   or derive the analogous formula manually.
2. Turn `hx` into an equality of iterates.
3. Obtain:
   ```lean
   have hx' : Function.IsPeriodicPt g n (h x) := ...
   ```
4. Search for a theorem of the form:
   ```lean
   Function.minimalPeriod_dvd
   ```
   and apply it to `hx'`.
5. If `minimalPeriod` theorems require periodicity rather than `IsPeriodicPt`, package `hx'` accordingly.
6. If zero-period edge cases appear, prove a small helper lemma isolating them rather than polluting the main proof.

# What would make this field-opening

Do not stop at the one divisibility theorem. Build a **period transport API** for `Function.Semiconj`, `Function.Commute`, and conjugacy. A polished mini-library here would let future researchers formalize:
- orbit decomposition under factors,
- cycle structure of finite maps,
- periodic point counting,
- Artin–Mazur zeta functions for finite/shift-like systems,
- entropy monotonicity under factor maps.

This is how a tiny theorem becomes infrastructure.

# Deliverables

1. Lean file with:
   - `semiconj_isPeriodicPt`
   - `semiconj_minimalPeriod_dvd_of_isPeriodicPt`
   - `semiconj_minimalPeriod_dvd`
   - if possible, `semiconj_minimalPeriod_eq_of_injective` and/or conjugacy equality
2. Minimize `sorry`; if blocked by API uncertainty, isolate the smallest helper lemmas.
3. Produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next theorems.

# Required FUTURE_DIRECTIONS.md contents

Include specific theorem statements, proof ideas, and cross-domain significance for at least these directions:

1. **Conjugacy invariance of full period spectrum**  
   Prove equality of sets `{n | IsPeriodicPt f n x}` under conjugacy.

2. **Eventual periodicity descent and ascent**  
   Under semiconjugacy and injectivity/surjectivity hypotheses, characterize when eventual periodicity is preserved both ways.

3. **Cycle counting on finite types**  
   For `Fintype α`, prove that semiconjugacy induces divisibility constraints on cycle-count statistics and orbit partitions.

4. **Commuting maps and lcm/gcd structure of periods**  
   If `f` and `g` commute, formalize arithmetic relations between minimal periods of `x`, `g x`, and joint actions.

5. **Symbolic dynamics bridge**  
   Define factor maps for shift systems and prove periodic orbit divisibility as a corollary of the abstract semiconjugacy theorem.

# Application keywords

semiconjugacy, minimal period, periodic points, factor dynamics, symbolic dynamics, automata quotient, state-space compression, abstract interpretation, renormalization, orbit arithmetic, conjugacy invariants, finite dynamical systems, cycle decomposition, certified transport theorem

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
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

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
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: prove
