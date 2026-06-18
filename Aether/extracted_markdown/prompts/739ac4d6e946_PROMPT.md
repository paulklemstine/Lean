Soli Deo Gloria

## Assignment: Direction 2: M-Convex Support Compression Beyond Matroids

**Mode:** `prove`

Aristotle, aim for a theorem package that upgrades support compression from the matroid basis world to the genuinely broader universe of discrete convex analysis. The target is not an incremental variant: it is a structural theorem asserting that **M-convexity alone controls quadratic leaf complexity**. If successful, this opens a new bridge between Lorentzian/combinatorial Hodge theory, discrete convex analysis, tropical geometry, and fast certification algorithms.

The conceptual leap is this: matroid basis supports are only one visible corner of the exchange universe. If the same compression law survives for arbitrary M-convex Newton supports, then the true mechanism behind support sparsification is not linear representability or basis exchange, but **integral exchange geometry of degree slices**. That would reframe support compression as a theorem of Murota-style discrete convexity.

---

## Core Breakthrough Target

### Main theorem to prove

Let `s : Finset (σ →₀ ℕ)` be a finite family of exponent vectors of fixed total degree `d`, with active coordinate set of cardinality `ω`. Assume:

1. every `m ∈ s` has total degree `d`,
2. `s` satisfies the natural-number M-convex symmetric exchange property,
3. `LeafSet₂(s)` denotes the set of all exponent vectors `u` of degree `d-2` such that `u ≤ m` coordinatewise for some `m ∈ s`.

Then the number of nonzero quadratic leaves is bounded by
\[
|LeafSet₂(s)| \le \binom{\omega}{d-2}.
\]

This should be formalized in a Lean-friendly form using the catalog notions around `NewtonSupport`, `IsMConvexExchangeNat`, and the compression machinery from `supportCompressedLeafCount_le_active_choose`.

### Proposed Lean 4 theorem signature

You may need to adapt names to the exact catalog interfaces, but the target should be as close as possible to:

```lean
theorem mconvex_leafCount_le_active_choose
    {σ : Type*} [DecidableEq σ]
    (s : Finset (σ →₀ ℕ)) (d : ℕ)
    (hsdeg : ∀ m ∈ s, m.sum (fun _ n => n) = d)
    (hmconv : IsMConvexExchangeNat s)
    :
    (quadraticLeafSet s d).card ≤ Nat.choose (activeCoords s).card (d - 2)
```

If `quadraticLeafSet` is not yet in the catalog, define it precisely and prove its finiteness/cardinality lemmas.

A more structural theorem may be even better:

```lean
theorem mconvex_shadow_card_le_active_choose
    {σ : Type*} [DecidableEq σ]
    (s : Finset (σ →₀ ℕ)) (k d : ℕ)
    (hk : k ≤ d)
    (hsdeg : ∀ m ∈ s, m.sum (fun _ n => n) = d)
    (hmconv : IsMConvexExchangeNat s)
    :
    (degreeShadow s k).card ≤ Nat.choose (activeCoords s).card k
```

and then derive the quadratic leaf bound by taking `k = d - 2`.

This stronger theorem would be a real breakthrough: it says the entire lower shadow of an M-convex degree slice behaves combinatorially like a compressed simplicial skeleton.

---

## New definitions you should introduce

You are required to add at least one genuinely new concept. The following are mathematically natural and likely absent from the catalog.

### 1. Degree shadow of a support
For a finite support `s` of degree `d`, define the `k`-shadow:
```lean
def degreeShadow (s : Finset (σ →₀ ℕ)) (k : ℕ) : Finset (σ →₀ ℕ) :=
  s.biUnion (fun m => dominatedSubfinsuppsOfDegree m k)
```
where `u ∈ dominatedSubfinsuppsOfDegree m k` means `u ≤ m` coordinatewise and total degree `k`.

This is the correct abstraction behind “leaf sets.”

### 2. Active width
If not already present under another name, define:
```lean
def activeCoords (s : Finset (σ →₀ ℕ)) : Finset σ := ...
```
and set `ω := (activeCoords s).card`.

### 3. Hereditary shadow exchange
Define a property expressing that the shadow inherits a weakened exchange law:
```lean
def ShadowHereditaryExchange (s : Finset (σ →₀ ℕ)) (k : ℕ) : Prop := ...
```
Even if you cannot prove full M-convexity of the shadow, proving a hereditary exchange lemma would itself be new and useful.

This new concept is valuable because it isolates the exact mechanism needed for compression and may survive beyond homogeneous settings.

---

## Theorems you should deliver

You must prove at least 3 nontrivial theorems with real proof structure. Here is the theorem stack I recommend.

### Theorem 1: Shadow support lies in active-coordinate simplex
This is the geometric containment theorem underlying the count bound.

```lean
theorem mem_degreeShadow_support
    {σ : Type*} [DecidableEq σ]
    {s : Finset (σ →₀ ℕ)} {k d : ℕ}
    (hsdeg : ∀ m ∈ s, m.sum (fun _ n => n) = d)
    {u : σ →₀ ℕ}
    (hu : u ∈ degreeShadow s k) :
    u.support ⊆ activeCoords s ∧ u.sum (fun _ n => n) = k
```

**Meaning:** every leaf/shadow element is a degree-`k` occupancy pattern using only active coordinates. This theorem is not enough by itself for the sharp binomial bound, but it is the first geometric skeleton.

### Theorem 2: Exchange descent / shadow heredity
This is the genuinely new combinatorial theorem.

```lean
theorem mconvex_shadow_hereditary
    {σ : Type*} [DecidableEq σ]
    (s : Finset (σ →₀ ℕ)) (k d : ℕ)
    (hk : k ≤ d)
    (hsdeg : ∀ m ∈ s, m.sum (fun _ n => n) = d)
    (hmconv : IsMConvexExchangeNat s)
    :
    ShadowHereditaryExchange s k
```

**Meaning:** the M-convex exchange axiom on degree-`d` support induces a recursive exchange structure on degree-`k` dominated slices. This is where the real science is. Even a carefully weakened version is significant.

### Theorem 3: M-convex shadow cardinality bound
The central compression theorem.

```lean
theorem mconvex_shadow_card_le_active_choose
    {σ : Type*} [DecidableEq σ]
    (s : Finset (σ →₀ ℕ)) (k d : ℕ)
    (hk : k ≤ d)
    (hsdeg : ∀ m ∈ s, m.sum (fun _ n => n) = d)
    (hmconv : IsMConvexExchangeNat s)
    :
    (degreeShadow s k).card ≤ Nat.choose (activeCoords s).card k
```

### Theorem 4: Quadratic leaf compression as a corollary
Specialize to `k = d - 2`.

```lean
theorem mconvex_quadratic_leafCount_le
    {σ : Type*} [DecidableEq σ]
    (s : Finset (σ →₀ ℕ)) (d : ℕ)
    (hsdeg : ∀ m ∈ s, m.sum (fun _ n => n) = d)
    (hmconv : IsMConvexExchangeNat s)
    :
    (quadraticLeafSet s d).card ≤ Nat.choose (activeCoords s).card (d - 2)
```

### Cross-domain theorem: tropical bridge
You must include at least one theorem connecting to another domain. The cleanest bridge is tropical geometry.

Define a tropical support functional:
```lean
def tropicalWeight (w : σ → ℤ) (m : σ →₀ ℕ) : ℤ := ...
```
and prove a theorem of the form:

```lean
theorem mconvex_initial_support_nonempty_mconvex
    {σ : Type*} [DecidableEq σ]
    (s : Finset (σ →₀ ℕ))
    (hmconv : IsMConvexExchangeNat s)
    (w : σ → ℤ)
    :
    ∃ t ⊆ s, t.Nonempty ∧ IsMConvexExchangeNat t ∧
      t = initialSupport w s
```

Even a weaker theorem saying the set of weight-minimizers inherits exchange is important. This is a bridge to tropical geometry because initial supports are tropical faces / regular subdivisions. It says M-convexity is stable under tropical degeneration.

If this exact theorem is too ambitious, prove a shadow/tropical compatibility lemma:
```lean
theorem degreeShadow_initialSupport_commutes_under_exchange ...
```

This would connect discrete convex analysis with tropical initial forms.

---

## Precise conjecture with computationally falsifiable prediction

### Conjecture: tightness and recursive certification
For every M-convex support `s` of homogeneous degree `d`, there exists a recursively defined partition of `quadraticLeafSet s d` into exchange intervals whose total description length is `O(ω log d)`, and hence leaf membership can be certified in sublinear time in `|s|`.

A weaker but testable form:
```text
For randomly generated M-convex supports of degree d and active width ω,
the size of the minimal exchange-generated certificate for quadratic leaves
is O(ω polylog d) on average.
```

### Computational disproof test
Generate finite M-convex supports that are not matroid basis supports:
- generalized permutohedron lattice point slices,
- polymatroid base families,
- valuated-matroid minimizer sets after forgetting valuation,
- Schur polynomial Newton supports for non-hook partitions.

For each sample:
1. compute `quadraticLeafSet`,
2. compute the binomial bound `choose ω (d-2)`,
3. search for equality cases,
4. build recursive exchange certificates and measure certificate size.

A single explicit family with super-binomial leaf growth or certificate complexity `≫ ω polylog d` would refute the conjecture.

---

## Proof strategy architecture

You asked for 2–3 proof strategy steps. Here are three serious routes.

### Strategy A: Shadow injection into squarefree occupancy patterns
**Most promising for the cardinality theorem.**

1. **Canonical compression map:** For each `u ∈ degreeShadow s k`, construct a canonical representative subset of active coordinates of size `k` by recursively “spreading mass” along M-convex exchanges until reaching a squarefree dominated vector.
2. **Well-definedness via exchange:** Use the symmetric exchange property to show the resulting squarefree representative is independent of choices or at least gives an injective map into `Finset` subsets of `activeCoords s` of cardinality `k`.
3. **Count by choose:** Conclude cardinality is bounded by the number of `k`-subsets of active coordinates.

Why this is promising: it directly mirrors the matroid compression mechanism while using M-convexity to replace basis exchange. It also naturally produces an algorithm.

### Strategy B: Induction on degree using exchange descent
**Most promising for the hereditary shadow theorem.**

1. **Degree-lowering step:** Show that if `u ≤ m ∈ s` with degree `k < d`, then there exists a coordinate split reducing a support element from degree `d` to degree `d-1` while preserving an exchange-compatible witness above `u`.
2. **Inductive shadow decomposition:** Decompose the `k`-shadow into a union of shadows of degree-`d-1` slices indexed by active coordinates or exchange pivots.
3. **Apply combinatorial recursion:** Prove the resulting cardinalities satisfy Pascal-type recursion, yielding `choose ω k`.

Why this is promising: it fits Lean well. Induction on `d`, `Finset` decompositions, and `calc` chains are formalization-friendly. It also naturally avoids black-box polyhedral machinery.

### Strategy C: Polyhedral/discrete convex route through generalized permutohedra
**Most visionary, but probably hardest to formalize fully.**

1. Interpret `s` as the integer point set of a base polytope slice or as an M-convex family in Murota’s sense.
2. Show the `k`-shadow corresponds to integer points in a lower Minkowski shadow/projection.
3. Use discrete Brunn–Minkowski / polymatroid inequalities / simplex containment to deduce the binomial bound.

Why this matters: this would identify support compression as a theorem of generalized permutohedra. But it is likely too heavy for a first Lean implementation unless the catalog already has substantial polyhedral infrastructure.

**Recommendation:** pursue Strategy B for the main formal theorem, and extract Strategy A as the verified algorithmic corollary.

---

## How to build on catalog theorems

### From `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean`
Use:
- `IsMConvexExchangeNat`
- `NewtonSupport`

Do not merely cite them. Use `IsMConvexExchangeNat` as the engine for constructing exchange witnesses in the shadow. If `NewtonSupport` is available for actual polynomials, prove your combinatorial theorem first for abstract supports, then lift it:

```lean
theorem polynomial_newtonSupport_quadratic_leafCount_le
    ...
    (hmconv : IsMConvexExchangeNat (NewtonSupport p))
    :
    ...
```

This lift is important: it turns an abstract support theorem into a theorem about homogeneous polynomials with nonnegative coefficients.

### From `Catalog/Pythagorean/SupportCertificateCompression.lean`
Use:
- `supportCompressedLeafCount_le_active_choose`

Do not reprove the matroid-style compression from scratch. Instead:
1. isolate the hypotheses actually used there,
2. show M-convex exchange implies the needed compression hypotheses,
3. invoke the catalog theorem as the final counting step.

The dream statement is a transfer lemma:

```lean
theorem mconvex_implies_supportCompressionHyp
    ...
    (hmconv : IsMConvexExchangeNat s)
    :
    SupportCompressionHyp s
```

and then:

```lean
exact supportCompressedLeafCount_le_active_choose ... (mconvex_implies_supportCompressionHyp ... hmconv)
```

If this works, it is elegant and minimizes duplication.

---

## Cross-domain connections to emphasize

### 1. Tropical geometry
Initial forms/minimizer supports under weight vectors should preserve M-convex exchange. This suggests a tropical face of an M-convex Newton polytope remains exchange-controlled. That is a new structural link between tropical degenerations and support compression.

### 2. Lorentzian polynomials / combinatorial Hodge theory
Many Lorentzian examples have M-convex support. A support compression theorem at this level suggests that leaf complexity bounds may be a support-level shadow of Hodge-theoretic negativity. This is philosophically important: it hints that some “Hodge complexity” is already visible in discrete convex support geometry.

### 3. Optimization / algorithms
M-convex sets are the feasible sets of discrete convex optimization. If quadratic leaves admit recursive exchange certificates, then Hessian-signature style certification for structured polynomials may become fast enough for symbolic or combinatorial optimization pipelines.

### 4. Representation theory / Schur polynomials
Schur polynomial Newton supports are prototypical M-convex families beyond matroids. A theorem here would imply nontrivial complexity control for symmetric-function supports, opening a bridge to algebraic combinatorics.

---

## Application keywords

Use these explicitly in your paper and code comments:

**discrete convex analysis, M-convexity, symmetric exchange, Newton polytope, generalized permutohedron, polymatroid, valuated matroid, tropical initial form, Lorentzian polynomial, combinatorial Hodge theory, support compression, shadow bound, certificate complexity, sublinear certification, Schur polynomial, multivariate Tutte polynomial**

---

## Verified algorithm / computational method

You must produce a verified algorithm, not just a theorem.

### Target algorithm
Implement a certified procedure that, given a finite homogeneous support `s` with proof of `IsMConvexExchangeNat s`, computes:
1. `activeCoords s`,
2. `degreeShadow s (d-2)`,
3. a certificate that its cardinality is bounded by `Nat.choose ω (d-2)`.

Stronger version: construct a recursive exchange decomposition tree witnessing the bound.

Possible Lean interface:
```lean
def buildShadowCertificate
    {σ : Type*} [DecidableEq σ]
    (s : Finset (σ →₀ ℕ)) (d : ℕ)
    (hsdeg : ∀ m ∈ s, m.sum (fun _ n => n) = d)
    (hmconv : IsMConvexExchangeNat s)
    : ShadowCertificate s (d - 2)
```

Then prove:
```lean
theorem shadowCertificate_sound ... :
  (buildShadowCertificate s d hsdeg hmconv).valid
```

and:
```lean
theorem shadowCertificate_size_bound ... :
  (buildShadowCertificate s d hsdeg hmconv).leafCount ≤ Nat.choose (activeCoords s).card (d - 2)
```

This is the algorithmic heart of the project.

---

## Demo requirements

Produce `demo.py` that:
1. constructs explicit M-convex supports not coming from matroid bases,
2. computes quadratic leaf sets,
3. compares observed counts to `binom(ω, d-2)`,
4. searches for tight examples,
5. visualizes exchange graphs / shadow decomposition.

Suggested examples:
- Schur support for partitions `(2,1)`, `(3,1)`, `(2,2)`,
- polymatroid base sets from submodular rank functions,
- generalized permutohedron slices,
- valuated matroid minimizer supports.

The demo should let a user toggle families and parameters and see the bound hold or fail.

---

## Formal proof style requirements

You must satisfy the depth constraints explicitly:
- at least 3 theorems with proofs using induction, `rcases`, `by_contra`, `field_simp` where relevant, or multi-step `calc`,
- no trivial theorem-padding,
- minimize `sorry`,
- include at least one theorem whose proof genuinely uses exchange witnesses extracted by `rcases`,
- include at least one contradiction-style proof showing impossibility of support outside active coordinates or violation of degree constraints.

A good proof profile:
- **induction on degree** for shadow recursion,
- **`rcases`** on exchange witnesses from `IsMConvexExchangeNat`,
- **`by_contra`** for uniqueness/support containment contradictions,
- **`calc`** for cardinality inequalities and degree bookkeeping.

---

## Deliverables (ALL mandatory)

1. **Lean file(s)** proving the theorem stack above, with the new definitions and verified algorithm.
2. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions. Each direction must include the exact sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain.
3. **`RESEARCH_PAPER.md`** as a standalone scientific paper explaining the theorem, proof architecture, examples, significance, and next questions. A reader with no code access must understand the discovery.
4. **`ARTICLE.md`** in Scientific American style, engaging and accessible, focused on the mathematics and why it matters. Do **not** focus on formal verification.
5. **A verified algorithm/computational method**, as above.
6. **`demo.py`** demonstrating the result interactively.

---

## Final scientific objective

Do not settle for “M-convex implies a weak analogue of the matroid bound.” The ambitious target is to show:

> **Support compression is a theorem of exchange geometry, not of matroids.**

If you can prove even the degree-shadow bound and one tropical stability theorem, you will have created a new structural lens on Lorentzian support theory and a plausible algorithmic entry point for fast certification across combinatorics, optimization, and algebraic geometry.

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
