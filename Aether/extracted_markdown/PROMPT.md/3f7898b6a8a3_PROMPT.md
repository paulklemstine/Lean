Soli Deo Gloria

## Assignment: Direction 5: M-Convex Optimization via Directional Log-Concavity Certificates

**Mode:** `prove`

You are not being asked for an incremental extension of discrete convex analysis. You are being asked to formalize a new optimization paradigm:

> **Directional log-concavity as a weaker-than-M-convex certificate for global optimization on exchange systems.**

The breakthrough target is to show that *graded local curvature information* on an integer objective, together with an exchange axiom on the feasible set, is already enough to force termination and quantitative progress of a natural exchange descent algorithm. If this works, it opens a new layer between arbitrary discrete optimization and full Murota-style M-convexity: a hierarchy of efficiently optimizable objectives certified by directional inequalities rather than full exchange convexity.

Build directly on:

- `Pythagorean/MultivariateLogConcavity.lean`
  - `support_rectangle_closure`
  - `kfold_mono`
  - `CoeffDirectionalLogConcave`

Your task is to create a new Lean file developing a rigorous theory of **exchange descent under directional log-concavity certificates**.

---

## Core mathematical vision

Let \( \alpha \) be a finite coordinate type. For integer lattice points \(x : \alpha \to \mathbb{Z}\), an **exchange move** is a displacement of the form
\[
x \mapsto x + e_i - e_j
\]
when feasibility is preserved. On a feasible family \(S\) satisfying an exchange axiom (matroid bases, integral polymatroids, or an abstract exchange system), define an objective \(f : (\alpha \to \mathbb{Z}) \to \mathbb{R}\) or \( \mathbb{Z}\).

The conjectural principle to turn into theorems is:

> If \(f\) satisfies a suitable directional log-concavity / mixed discrete midpoint inequality along exchange rectangles, then every exchange-local optimum is global, and a greedy exchange descent cannot cycle. Moreover, the amount of “depth” of directional log-concavity controls how many bad directions can persist.

This is not merely a formal restatement of M-convexity. The point is to isolate a *strictly weaker* certificate, built from local rectangle inequalities, that still implies global optimization guarantees on structured feasible sets.

---

## New definitions you should introduce

You must define at least one genuinely new concept not already in the catalog. The following are strong candidates.

### 1. Exchange-feasible family
Define an abstract exchange system on integer vectors.

Suggested Lean-facing shape:
```lean
structure ExchangeFamily (α : Type*) [DecidableEq α] where
  carrier : Set (α → ℤ)
  exchange :
    ∀ {x y : α → ℤ},
      x ∈ carrier → y ∈ carrier →
      ∀ {i : α}, y i < x i →
      ∃ j : α, x j < y j ∧
        (x + Function.update 0 i 1 + Function.update 0 j (-1)) ∈ carrier
```

You will likely want a cleaner additive basis-vector definition instead of `Function.update`; define a standard basis step:
```lean
def basisStep [DecidableEq α] (i : α) : α → ℤ := fun j => if j = i then 1 else 0
```
and then use
```lean
x + basisStep i - basisStep j
```

Refine the exchange axiom so it is usable in proofs.

### 2. Exchange-local minimum
```lean
def IsExchangeLocalMin
  {α : Type*} [Fintype α] [DecidableEq α]
  (S : Set (α → ℤ)) (f : (α → ℤ) → ℝ) (x : α → ℤ) : Prop :=
  x ∈ S ∧
  ∀ i j, x + basisStep i - basisStep j ∈ S → f x ≤ f (x + basisStep i - basisStep j)
```

### 3. Directional exchange certificate
Define a property expressing the relevant 2-coordinate inequality induced by directional log-concavity. Keep it abstract enough to prove theorems from it, then later derive it from catalog DLC results.

Example:
```lean
def ExchangeDLC
  {α : Type*} [Fintype α] [DecidableEq α]
  (S : Set (α → ℤ)) (f : (α → ℤ) → ℝ) : Prop :=
  ∀ x ∈ S, ∀ i j, ∀ m : ℤ,
    x + m • basisStep i - m • basisStep j ∈ S →
    -- suitable midpoint / discrete concavity / monotonic ratio inequality
    True
```

You may instead define this on finite-support coefficient arrays if that interfaces more naturally with `CoeffDirectionalLogConcave`.

### 4. k-step descent depth / certificate depth
A graded notion matching the catalog’s `kfold_mono` hierarchy. This is essential: the theorem should not collapse to a binary “convex / not convex” statement.

---

## Precise theorem targets

You must prove at least **3 substantial theorems**. The first two below are the heart of the project; the third can be either the graded bound or the cross-domain bridge.

### Theorem 1: Local exchange optimality implies global optimality
Formal statement idea:

> On an exchange family \(S\), if \(f\) satisfies the directional rectangle-improvement property induced by mixed DLC, then every exchange-local minimum is a global minimum on \(S\).

Suggested Lean type signature:
```lean
theorem isExchangeLocalMin_isGlobal
  {α : Type*} [Fintype α] [DecidableEq α]
  (E : ExchangeFamily α)
  (f : (α → ℤ) → ℝ)
  (hDLC : ExchangeDLC E.carrier f) :
  ∀ {x : α → ℤ},
    IsExchangeLocalMin E.carrier f x →
    ∀ {y : α → ℤ}, y ∈ E.carrier → f x ≤ f y
```

This theorem is the conceptual breakthrough. It says that *local certificates plus exchange geometry imply global optimization*.

### Theorem 2: Strict descent exchange algorithm terminates without cycling
Define an algorithmic relation:
```lean
def ExchangeDescentStep
  {α : Type*} [Fintype α] [DecidableEq α]
  (S : Set (α → ℤ)) (f : (α → ℤ) → ℝ) (x y : α → ℤ) : Prop :=
  ∃ i j, y = x + basisStep i - basisStep j ∧ y ∈ S ∧ f y < f x
```

Then prove a no-cycle / termination theorem on finite feasible sets.

Suggested Lean type signature:
```lean
theorem exchangeDescent_acyclic
  {α : Type*} [Fintype α] [DecidableEq α]
  (S : Finset (α → ℤ))
  (f : (α → ℤ) → ℝ) :
  Directed.Acyclic (fun x y => x ∈ S ∧ y ∈ S ∧ ExchangeDescentStep (↑S : Set (α → ℤ)) f x y)
```

Or, if acyclicity is awkward, prove:
```lean
theorem exchangeDescent_no_infinite_chain
  {α : Type*} [Fintype α] [DecidableEq α]
  (S : Finset (α → ℤ))
  (f : (α → ℤ) → ℝ) :
  WellFounded (fun x y => x ∈ S ∧ y ∈ S ∧ ExchangeDescentStep (↑S : Set (α → ℤ)) f x y)
```

This theorem gives the verified algorithmic content. It should not be proved trivially; use strict decrease and finiteness in a multi-step argument.

### Theorem 3: Rectangle closure upgrades pairwise descent to pathwise descent
Use `support_rectangle_closure` in a serious way.

Conceptual statement:

> If two feasible points \(x,y\) lie in an exchange family and the support of feasible exchange directions is rectangle-closed, then every coordinate discrepancy can be resolved by a sequence of improving exchanges; hence failure of global optimality would produce a locally improving exchange.

Suggested Lean type signature:
```lean
theorem exists_improving_exchange_of_not_global
  {α : Type*} [Fintype α] [DecidableEq α]
  (E : ExchangeFamily α)
  (f : (α → ℤ) → ℝ)
  (hRect : -- derived from support_rectangle_closure / support data
  )
  (hDLC : ExchangeDLC E.carrier f) :
  ∀ {x y : α → ℤ},
    x ∈ E.carrier → y ∈ E.carrier → f y < f x →
    ∃ i j, x + basisStep i - basisStep j ∈ E.carrier ∧
      f (x + basisStep i - basisStep j) < f x
```

This theorem is the mechanism behind Theorem 1. It is also the place where catalog results should enter nontrivially.

### Optional Theorem 4: Monotonicity in depth
Exploit `kfold_mono`.

> If a function has a \(k+1\)-fold directional certificate, then it has a \(k\)-fold certificate, and therefore any optimization guarantee proved at depth \(k\) automatically extends upward.

Suggested Lean signature:
```lean
theorem ExchangeDLC.of_kfold_mono
  {α : Type*} [Fintype α] [DecidableEq α]
  {k l : ℕ} (hkl : k ≤ l)
  (fdata : -- coefficient data)
  (hl : CoeffDirectionalLogConcave l fdata) :
  CoeffDirectionalLogConcave k fdata
```
combined with a theorem
```lean
theorem depth_monotone_global_optimality
  ...
```

### Optional Theorem 5: Quantitative descent bound on finite diameter exchange families
If the feasible family has bounded \(\ell_1\)-diameter \(D\), prove that every strict descent run has length at most \(D\) or at most a weighted potential bound.

Suggested Lean signature:
```lean
theorem exchangeDescent_length_le_diameter
  {α : Type*} [Fintype α] [DecidableEq α]
  (E : ExchangeFamily α)
  (Sfin : Finite E.carrier)
  (f : (α → ℤ) → ℝ)
  (x0 : α → ℤ) (hx0 : x0 ∈ E.carrier) :
  ∃ N : ℕ, ∀ xs,
    -- xs is a descent trajectory from x0
    xs.length ≤ N
```

Even a weaker bound via cardinality of the feasible set is acceptable, but strive for a potential-function bound.

---

## How to use the catalog theorems

Do not merely cite the catalog. Use it as structural scaffolding.

### `support_rectangle_closure`
Use this as the local-to-global engine. The philosophical interpretation here is:

- pairwise feasible exchange directions generate rectangles in support space;
- mixed DLC inequalities propagate along these rectangles;
- therefore, if a target point improves the objective globally, one of the first exchange edges on a rectangle path must already improve locally.

This is the key theorem that should bridge local directional inequalities to global exchange descent.

### `kfold_mono`
Use this to justify a **graded hierarchy of optimization certificates**. The point is not just monotonicity of a predicate: it lets you state and prove that stronger directional depth assumptions automatically imply the optimization theorem. This is the right abstraction barrier for future work on complexity-vs-depth tradeoffs.

### `CoeffDirectionalLogConcave`
This should be used to instantiate your abstract `ExchangeDLC` property from coefficient data of multivariate generating functions or discrete objective tables. The ideal result is:

- define an objective from coefficient data,
- show coefficient directional log-concavity implies your exchange certificate,
- then invoke the optimization theorem.

This creates a bridge from algebraic/log-concavity data to algorithmic discrete optimization.

---

## Proof strategy architecture

You must give at least 2–3 real proof routes in the code comments / paper, and pursue the most viable one in Lean.

### Strategy A: Exchange path contradiction via first improving edge
1. Assume \(x\) is exchange-local minimum but not global; choose \(y\) with \(f(y) < f(x)\).
2. Use the exchange property to build a sequence of feasible exchanges from \(x\) toward \(y\), reducing coordinate discrepancy.
3. Use `support_rectangle_closure` plus directional log-concavity to show objective values along this path cannot remain nondecreasing all the way to \(y\); hence some first step must improve, contradicting local optimality.

**Why this is promising:** It matches the combinatorial structure of matroid/polymatroid exchange and turns rectangle closure into a concrete descent witness. This should be the main route.

### Strategy B: Potential-function induction on \(\ell_1\)-distance
1. Define a discrepancy potential
   \[
   \Phi(x,y) = \sum_i |x_i-y_i|.
   \]
2. Prove by induction on \(\Phi(x,y)\) that if \(f(y) < f(x)\), then there exists an improving exchange from \(x\).
3. The inductive step uses the exchange axiom to choose \(i,j\), then uses directional certificate inequalities on the corresponding 2D slice to transfer improvement from a closer point back to \(x\).

**Why this is promising:** This yields a strong recursive proof and can also produce quantitative descent bounds. It is likely Lean-friendly because induction on a natural-valued potential is robust.

### Strategy C: Generating-function / coefficient route
1. Encode feasible integer points and objective weights into a multivariate coefficient array or generating polynomial.
2. Use `CoeffDirectionalLogConcave` to derive mixed inequalities on coefficient ratios or objective increments.
3. Translate these inequalities into exchange-descent monotonicity and local-global optimality.

**Why this matters:** This is the conceptual bridge to algebraic combinatorics and Hodge-style log-concavity. It may be harder to complete fully in Lean, but even one theorem in this direction would be field-opening.

---

## Cross-domain connection requirement

You must include at least one theorem connecting this optimization theory to a different domain.

### Recommended bridge: Algebraic combinatorics / Lorentzian-style generating functions
If coefficient arrays of a multivariate polynomial satisfy directional log-concavity, then the induced discrete objective on exponent vectors admits exchange-local-to-global optimization on suitable support sets.

Possible theorem shape:
```lean
theorem coeffDLC_induces_exchange_optimization
  {α : Type*} [Fintype α] [DecidableEq α]
  (a : -- coefficient data)
  (hlog : CoeffDirectionalLogConcave k a)
  (hsupp : -- support of a forms an exchange family / rectangle-closed set) :
  ∀ {x : α → ℤ},
    IsExchangeLocalMin (support a) (objectiveOfCoeff a) x →
    ∀ {y}, y ∈ support a → objectiveOfCoeff a x ≤ objectiveOfCoeff a y
```

This bridges:
- discrete optimization,
- matroid/polymatroid geometry,
- multivariate log-concavity / Hodge-theoretic combinatorics.

Alternative cross-domain bridge: statistical physics. Interpret \(f\) as an energy on occupation vectors and prove that directional log-concavity prevents metastable non-global local minima on exchange-connected state spaces. Even a modest formal theorem here would be conceptually powerful.

---

## Lean 4 implementation targets

You should aim to produce a file with the following components:

1. **Definitions**
   - `basisStep`
   - `ExchangeFamily`
   - `IsExchangeLocalMin`
   - `ExchangeDescentStep`
   - `ExchangeDLC`
   - a natural potential such as `l1Dist`

2. **Core lemmas**
   - algebra of `basisStep`
   - coordinate update identities
   - discrepancy reduction under exchange
   - no-cycle from strict objective descent on finite sets
   - existence of exchange paths in an exchange family

3. **Main theorems**
   - local minimum implies global minimum
   - descent termination / acyclicity
   - depth monotonicity transfer
   - one cross-domain theorem from coefficient DLC to optimization

4. **Verified algorithm**
   - a computable exchange-descent procedure on finite feasible sets
   - proof that if it terminates at `x`, then `x` is exchange-local minimum
   - proof that under your hypotheses, the output is globally optimal

You do **not** need to solve weighted matroid intersection in full generality, but you do need a certified algorithm on a finite exchange family representation.

---

## Computational method requirement

You must provide a verified algorithm or computational method, not just theorem statements.

### Suggested algorithm
For a finite feasible family `S : Finset (α → ℤ)` and objective `f`, define:

- enumerate all feasible exchange neighbors of `x`,
- if any has strictly smaller objective, move to one such neighbor,
- iterate until none exists.

Then verify:

1. every step remains feasible;
2. objective strictly decreases;
3. on finite `S`, the process terminates;
4. under `ExchangeDLC` plus exchange hypotheses, the terminal state is globally optimal.

This is mathematically meaningful and experimentally testable.

---

## Conjecture with testable prediction

You must state at least one falsifiable conjecture in the file and in the paper.

### Main conjecture
> **Conjecture (graded complexity by depth).**
> Let \(S \subseteq \mathbb{Z}^\alpha\) be a finite exchange family of ambient rank \(d\), and let \(f\) admit a \(k\)-fold directional log-concavity certificate on all exchange rectangles. Then the exchange descent algorithm reaches a global optimum in
> \[
> O(|\alpha|^{\,d-k} \cdot \mathrm{diam}(S))
> \]
> improving exchanges.

This is falsifiable: generate exchange families and objectives with certified depth \(k\), run the algorithm, and test whether step counts scale polynomially with exponent approximately \(d-k\).

### Lean-facing placeholder
You may encode a weaker formal conjecture as a `def`/commented statement if full formal proof is out of reach, but it must be explicit and computationally testable.

---

## Demo / experiments

Implement `demo.py` to test the conjecture on finite examples:
- small matroid base families,
- integral polymatroid-like exchange sets,
- synthetic coefficient-defined objectives with varying k-fold depth.

Measure:
- number of exchange steps,
- final objective,
- dependence on `n, d, k`.

Plot or print empirical scaling trends.

---

## Deliverables — all mandatory

You must produce all of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**, each with:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**

At least one direction must bridge to a different domain, such as:
- Lorentzian polynomials / Hodge theory,
- statistical physics and energy landscapes,
- market design / discrete economics,
- information theory on exchange systems.

Write these as real research visions, not templates.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the new definitions,
- the main theorems,
- why directional log-concavity is weaker and more flexible than full M-convexity,
- the algorithm,
- examples,
- conjectural complexity-depth tradeoff,
- future implications.

Someone reading only this document must understand the mathematics and significance without seeing the code.

### 3. `ARTICLE.md`
Write this in **Scientific American style**:
- accessible,
- vivid,
- idea-driven,
- focused on the mathematical discovery and why it matters.

**Taboo:** do not focus on formal verification machinery. The story is about a new way to certify efficient optimization in discrete systems.

### 4. Verified algorithm / computational method
As above: certified exchange descent on finite exchange families, with correctness theorem.

### 5. `demo.py`
An interactive or script-based demonstration of the algorithm and the conjectural scaling law.

---

## Application keywords

Use and emphasize these throughout the work:

- discrete convex analysis
- M-convex optimization
- matroid base polytope
- integral polymatroid
- exchange axiom
- directional log-concavity
- rectangle closure
- local-to-global principle
- certified optimization
- descent algorithm
- Lorentzian polynomial
- algebraic combinatorics
- energy landscape
- metastability barrier removal
- polynomial-time optimization
- complexity-depth tradeoff

---

## Nontriviality requirements

These are mandatory and must be visible in the Lean development:

1. **No trivial theorem padding.**
   Do not rely on `native_decide`, `decide`, `norm_num`, or `rfl` for the main results.

2. **At least 3 genuinely deep proofs.**
   Use induction, `rcases`, `by_contra`, `field_simp`, and multi-step `calc` chains where appropriate.

3. **Novel definitions.**
   At least one of your central definitions must be genuinely new relative to the catalog.

4. **Cross-domain theorem.**
   At least one theorem must explicitly connect exchange optimization to another mathematical domain.

5. **Falsifiable conjecture.**
   State a prediction that computation could refute.

---

## Final charge

Do not merely formalize a known corner of Murota’s theory. Create a new intermediate layer of discrete optimization theory:

> **exchange geometry + directional log-concavity ⇒ certified global optimization**

If successful, this opens a program in which algebraic log-concavity certificates become algorithmic optimization certificates. That is a new bridge between combinatorics, optimization, and algebraic geometry—and exactly the kind of bridge that can found a field.

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
