Soli Deo Gloria

## Assignment: Direction 2 — Sparse-Support Certificate Compression for Matroid Basis Polynomials

**Mode:** `prove`

You are not being asked for a cosmetic improvement to an existing bound. You are being asked to isolate and formalize the structural reason that Lorentzian-recognition recursion trees collapse for matroid basis generating polynomials. The breakthrough is to replace ambient-monomial worst-case complexity by **support-controlled complexity**, and then show that matroid exchange forces the support to be so rigid that most derivative branches vanish before they are born.

The catalog already contains the two ingredients in embryonic form:

- `Pythagorean/LorentzianRecognition.lean`
  - `multiIndexSet`
  - `numberOfQuadraticLeaves`
- `Speculative/AutoResearch/LorentzianMConvex.lean`
  - `NewtonSupport`
  - `IsMConvexExchangeNat`

Your task is to forge these into a new theory of **certificate compression by exchange geometry**.

---

## Core Mathematical Vision

Let \(M\) be a matroid of rank \(r\) on ground set \([n]\), and let
\[
B_M(x_1,\dots,x_n) := \sum_{B \in \mathcal B(M)} \prod_{i \in B} x_i
\]
be its basis generating polynomial. This is homogeneous of degree \(r\), multiaffine, and its support is exactly the family of basis indicator vectors.

The generic recursive Lorentzian recognition algorithm explores derivative branches indexed by multiindices \(\alpha\) with \(|\alpha| = r-2\), and the naive worst-case leaf count scales like the full ambient count of such \(\alpha\)'s. But for a multiaffine basis polynomial, the derivative
\[
\partial^\alpha B_M
\]
is nonzero **iff** \(\operatorname{supp}(\alpha)\) is contained in some basis of \(M\), equivalently iff it is an independent set of size \(|\alpha|\). Thus nonzero quadratic leaves are not governed by ambient monomials but by the independent-set geometry of the matroid.

The decisive insight is:

> **Quadratic leaves of a basis generating polynomial are in bijection with independent sets of size \(r-2\).**

For uniform matroids this gives an exact closed form. For graphic and transversal matroids it converts symbolic differentiation complexity into combinatorial counting. For general matroids it opens a new route to practical Lorentzian recognition: compress the certificate using support geometry rather than coefficient arithmetic.

This is not a small optimization. It is a new complexity principle for Lorentzian certification, with immediate consequences for combinatorial optimization and partition-function computation.

---

## New Definitions You Should Introduce

You must define at least one genuinely new concept absent from the catalog. I recommend introducing all of the following.

### 1. Nonzero quadratic derivative profile
A support-theoretic notion of which derivative leaves survive.

```lean
def NonzeroQuadraticLeafSet
    (s : Finset (Fin n →₀ ℕ)) (d : ℕ) : Finset (Fin n →₀ ℕ) :=
  ((multiIndexSet n (d - 2)).filter fun α => ∃ β ∈ s, α ≤ β)
```

Interpretation: a degree-\((d-2)\) multiindex `α` survives if it is dominated by some exponent vector `β` in the support.

For multiaffine supports this should reduce to a combinatorial family of subsets.

### 2. Support-compressed leaf count
```lean
def supportCompressedLeafCount
    (s : Finset (Fin n →₀ ℕ)) (d : ℕ) : ℕ :=
  (NonzeroQuadraticLeafSet s d).card
```

This is the mathematically correct complexity measure for recursive Lorentzian recognition.

### 3. Matroid-support profile
If you formalize a finite matroid interface or work relative to a set family of bases, define a support object recording basis indicator vectors and prove it is M-convex using the catalog theorem.

```lean
def basisIndicatorSupport
    (M : Matroid (Fin n)) : Finset (Fin n →₀ ℕ) := ...
```

Even if Mathlib’s matroid API requires adaptation, this is worth doing. It will become the bridge from combinatorics to certified symbolic complexity.

---

## Precise Theorem Targets

You must prove at least 3 substantial theorems. Here are the right targets.

---

### Theorem 1: Exact support criterion for nonzero derivatives of multiaffine homogeneous polynomials

**Mathematical statement.**  
Let \(p(x)=\sum_{\beta \in S} c_\beta x^\beta\) be a homogeneous multiaffine polynomial of degree \(r\), with all \(c_\beta \neq 0\). For any multiindex \(\alpha\) with \(|\alpha|=r-2\),
\[
\partial^\alpha p \neq 0
\quad\Longleftrightarrow\quad
\exists \beta \in S,\ \alpha \le \beta.
\]
In the multiaffine case, this is equivalent to saying that the support of \(\alpha\) is contained in some support monomial.

This theorem is the compression mechanism: derivative survival is a pure support property.

**Lean 4 target signature**  
Adjust names to the actual polynomial API, but aim for something this precise:

```lean
theorem derivative_nonzero_iff_dominated_support
    {n r : ℕ}
    (s : Finset (Fin n →₀ ℕ))
    (c : (Fin n →₀ ℕ) → ℚ)
    (hsupp : ∀ β, β ∈ s ↔ c β ≠ 0)
    (hmulti : ∀ β ∈ s, ∀ i, β i ≤ 1)
    (hdeg : ∀ β ∈ s, β.sum (fun _ m => m) = r)
    {α : Fin n →₀ ℕ}
    (hα : α.sum (fun _ m => m) = r - 2) :
    iteratedFDerivMulti α (polynomialOfSupport c) ≠ 0 ↔
      ∃ β ∈ s, α ≤ β := by
  ...
```

If `iteratedFDerivMulti` is not the right API, formulate using repeated partial derivatives or a bespoke support-level derivative operator. The theorem matters more than the exact packaging.

**Why this is a breakthrough.**  
It recasts analytic recursion as finite geometry. Once formalized, every future Lorentzian-recognition bound can be proved by support combinatorics alone.

---

### Theorem 2: Exact leaf count for basis generating polynomials equals number of independent \((r-2)\)-sets

**Mathematical statement.**  
Let \(M\) be a rank-\(r\) matroid on \([n]\). Then the number of nonzero quadratic derivative leaves of \(B_M\) is exactly
\[
\#\{I \subseteq [n] : |I| = r-2,\ I \text{ independent in } M\}.
\]

Equivalently, every nonzero quadratic leaf corresponds to an independent \((r-2)\)-set, and every such independent set extends to a basis, hence produces a surviving derivative branch.

This is the conceptual center of the project.

**Lean 4 target signature**
A subset-based version may be easiest:

```lean
theorem numberOfQuadraticLeaves_basisGenerating_eq_indep_sets
    {n r : ℕ}
    (M : Matroid (Fin n))
    (hr : M.rk = r) :
    numberOfQuadraticLeaves (basisGeneratingPolynomial M) =
      (((Finset.powersetLen (r - 2) Finset.univ).filter
        (fun I => M.Indep (↑I : Set (Fin n)))).card) := by
  ...
```

If `basisGeneratingPolynomial` is not yet defined, define it. If `M.rk` is awkward, use a rank assumption tailored to the API. If Mathlib matroids are too heavy, formalize first for a family of bases satisfying the basis exchange axiom and then derive the theorem.

**Why this is a breakthrough.**  
It identifies the exact complexity parameter. Instead of a symbolic-algebra black box, Lorentzian recognition for matroid polynomials becomes an independent-set counting problem. This is algorithmically meaningful and mathematically natural.

---

### Theorem 3: Uniform matroid closed form

**Mathematical statement.**  
For the uniform matroid \(U_{r,n}\),
\[
\#\{\text{nonzero quadratic leaves of } B_{U_{r,n}}\}
= \binom{n}{r-2}.
\]

This is the first exact solved case and the sanity-check for the general theory.

**Lean 4 target signature**
```lean
theorem numberOfQuadraticLeaves_uniformMatroid
    {n r : ℕ}
    (h2 : 2 ≤ r)
    (hrn : r ≤ n) :
    numberOfQuadraticLeaves (basisGeneratingPolynomial (uniformMatroid r (Fin n))) =
      Nat.choose n (r - 2) := by
  ...
```

This theorem should not be proved by raw enumeration. Prove it by the general independent-set theorem plus the fact that every subset of size at most \(r\) is independent in the uniform matroid.

**Why this matters.**  
It gives the exact benchmark against which all sparse-support compression claims are measured. It also supplies a computationally testable reference implementation.

---

## Strongly Recommended Fourth Theorem: A genuine upper bound from support geometry

You should push beyond exact identities and prove a support-driven upper bound that uses M-convexity or exchange.

### Theorem 4: Compression by support cardinality
For any homogeneous multiaffine polynomial \(p\) of degree \(r\),
\[
\#\{\alpha : |\alpha|=r-2,\ \partial^\alpha p \neq 0\}
\le \binom{\omega(p)}{r-2},
\]
where \(\omega(p)\) is the size of the union of variables appearing in the support. A sharper form may use the rank of the support hypergraph or the number of active coordinates.

This is not yet matroid-specific, but it gives a support complexity law independent of ambient \(n\).

Possible Lean target:
```lean
theorem supportCompressedLeafCount_le_active_choose
    {n r : ℕ}
    (s : Finset (Fin n →₀ ℕ))
    (hmulti : ∀ β ∈ s, ∀ i, β i ≤ 1)
    (hdeg : ∀ β ∈ s, β.sum (fun _ m => m) = r) :
    supportCompressedLeafCount s r ≤
      Nat.choose (activeVariableCount s) (r - 2) := by
  ...
```

This theorem is algorithmically powerful: if only \(k \ll n\) variables ever appear, certification cost is \(O(\binom{k}{r-2})\), not \(O(\binom{n}{r-2})\).

---

## Proof Strategy Architecture

You must not rely on a single proof idea. Develop 2–3 routes and decide which is strongest.

### Strategy A: Support-first derivative combinatorics
1. Prove a monomial lemma: repeated partial differentiation of \(x^\beta\) by multiindex \(\alpha\) is zero unless \(\alpha \le \beta\).
2. Lift to finite sums, using coefficient non-cancellation in the multiaffine homogeneous setting.
3. Specialize to basis supports, where \(\beta\) are \(0/1\)-vectors of bases.
4. Translate domination \(\alpha \le \beta\) into subset containment, then use matroid extension of independent sets to bases.

**Why promising:** This is the cleanest route to exact leaf-count identities and likely the easiest to formalize robustly in Lean.

### Strategy B: Newton support and M-convex exchange
1. Use `NewtonSupport` and `IsMConvexExchangeNat` to show basis-support indicator vectors form an M-convex set.
2. Prove that if a degree-\((r-2)\) derivative branch survives, then its index lies in the two-step shadow of the M-convex support.
3. Use exchange to characterize this shadow as precisely the independent \((r-2)\)-skeleton.

**Why promising:** This better exposes the catalog lineage and yields the most reusable general theory. It may also support future extension beyond matroids to arbitrary Lorentzian/M-convex supports.

### Strategy C: Recursive leaf-pruning theorem
1. Analyze the recursion in `numberOfQuadraticLeaves`.
2. Prove an invariant: a branch survives iff the accumulated derivative multiindex remains extendable to some support exponent.
3. Show that for matroid basis supports, extendability is equivalent to independence.
4. Deduce exact pruning statistics branch-by-branch.

**Why promising:** This connects directly to the existing implementation and may produce an executable verified algorithm with no translation gap.

**Recommendation:** Use Strategy A for the foundational exact theorem, then Strategy C to connect explicitly to the catalog’s leaf-counting machinery. Strategy B should be pursued if the M-convex API is already mature enough; it is the most visionary route and the one most likely to generate follow-on theorems.

---

## Cross-Domain Connections You Must Explicitly Develop

### 1. Matroid theory ↔ algorithmic complexity
The surviving derivative leaves are exactly a combinatorial shadow of the basis complex. This turns symbolic certification complexity into a structural invariant of the underlying combinatorial object.

### 2. Matroid theory ↔ statistical physics
Basis generating polynomials are partition functions for hard-core type combinatorial ensembles. Sparse-support certificate compression means physically meaningful partition functions may admit efficient Lorentzian or strong log-concavity certification because the thermodynamically relevant states are geometrically sparse.

### 3. M-convex analysis ↔ formal symbolic computation
M-convex exchange is not just a geometric curiosity; it is a pruning principle for derivative search trees. This is a new computational interpretation of discrete convexity.

### 4. Potential bridge to coding theory or network reliability
Graphic and transversal matroids connect directly to network reliability, sparse graph ensembles, and representable matroids over finite fields. Exact leaf counts could become proxies for tractable certification in reliability polynomials and coding partition functions.

---

## Conjecture with a Falsifiable Computational Prediction

You must state and test a conjecture stronger than the exact identities above.

### Conjecture: Exchange-compressed leaf growth
For every rank-\(r\) matroid \(M\) on \(n\) elements,
\[
\#\{\text{nonzero quadratic leaves of } B_M\}
\le C \cdot n^2 r^{\,r-4}
\]
for an absolute constant \(C\), or more invariantly,
\[
\#\{\text{nonzero quadratic leaves}\}
\le \#\{I : |I|=r-2,\ I \text{ independent}\},
\]
with the latter admitting sharper asymptotic bounds in sparse matroid families than the ambient \(\binom{n}{r-2}\) count.

A stronger and cleaner conjecture, better suited to computation, is:

> For every sparse graphic matroid arising from a graph \(G\) with \(m\) edges and cyclomatic complexity \(c\), the quadratic leaf count is controlled polynomially by low-order graph invariants such as the number of forests of size \(r-2\), and is asymptotically far below the ambient worst-case count whenever \(G\) is sparse.

**Testable prediction.**
Implement computations for:
- uniform matroids \(U_{r,n}\),
- graphic matroids of paths, cycles, trees, grids, sparse Erdős–Rényi graphs,
- transversal matroids from sparse bipartite incidence data.

For each family, compute:
1. ambient worst-case leaf bound,
2. actual nonzero quadratic leaf count,
3. ratio `actual / ambient`,
4. independent \((r-2)\)-set count,
5. timings for compressed versus naive enumeration.

A disproof would be a family where the actual count asymptotically matches the ambient worst case even though support geometry appears sparse.

---

## Verified Algorithmic Deliverable

You must produce not just theorems but a verified computational method.

### Algorithm target
Design and verify an algorithm that computes nonzero quadratic leaves from support data without differentiating the full polynomial.

For basis generating polynomials, the algorithm should:
1. enumerate candidate \((r-2)\)-subsets,
2. test whether each is independent / extendable to a basis,
3. count surviving leaves,
4. optionally construct the corresponding quadratic leaf polynomial.

This should be justified by the exact support criterion theorem.

Suggested Lean-facing specification:

```lean
def countNonzeroQuadraticLeavesFromSupport
    (s : Finset (Fin n →₀ ℕ)) (r : ℕ) : ℕ := ...

theorem countNonzeroQuadraticLeavesFromSupport_correct
    ... :
    countNonzeroQuadraticLeavesFromSupport s r =
      supportCompressedLeafCount s r := by
  ...
```

For matroids:
```lean
def countMatroidQuadraticLeaves
    (M : Matroid (Fin n)) : ℕ := ...

theorem countMatroidQuadraticLeaves_correct
    (M : Matroid (Fin n)) :
    countMatroidQuadraticLeaves M =
      numberOfQuadraticLeaves (basisGeneratingPolynomial M) := by
  ...
```

This is the computational heart of the project.

---

## Implementation Notes for Lean 4

- Reuse `multiIndexSet` and `numberOfQuadraticLeaves` wherever possible.
- If polynomial differentiation APIs are cumbersome, define a support-level derivative survival predicate first and prove equivalence to polynomial nonvanishing afterward.
- Use multiaffineness aggressively: exponents are \(0/1\), so domination by \(\alpha\) becomes subset containment.
- Expect to need:
  - induction on derivative order,
  - `rcases` for extracting basis extensions,
  - `by_contra` for non-survival arguments,
  - `field_simp` only if coefficient normalization introduces denominators,
  - multi-step `calc` blocks for cardinality identities and subset equivalences.
- Do not hide the combinatorial content under automation. The point is the structure.

---

## Minimum Theorem Checklist

Your file must contain at least these 3 deep theorems, with real proofs:

1. `derivative_nonzero_iff_dominated_support`
2. `numberOfQuadraticLeaves_basisGenerating_eq_indep_sets`
3. `numberOfQuadraticLeaves_uniformMatroid`

And preferably also one of:

4. `supportCompressedLeafCount_le_active_choose`
5. a graphic-matroid specialization identifying leaves with forests of size \(r-2\)

A particularly exciting cross-domain theorem would be:

```lean
theorem graphicMatroid_quadraticLeaves_eq_forests
    (G : SimpleGraph V) :
    numberOfQuadraticLeaves (basisGeneratingPolynomial (graphicMatroid G)) =
      #{F : Finset (Sym2 V) | IsForestSubgraph G F ∧ F.card = graphicRank G - 2} := by
  ...
```

This would connect Lorentzian-recognition complexity to graph enumeration and statistical mechanics in one stroke.

---

## Application Keywords

Lorentzian polynomials; matroid basis generating polynomial; M-convexity; discrete convex analysis; support compression; derivative sparsity; certificate complexity; combinatorial optimization; partition functions; statistical physics; graphic matroids; transversal matroids; independent set enumeration; forest counting; network reliability; strong log-concavity.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions and theorems above, minimizing sorry and avoiding trivialized proofs.
2. **A verified algorithm or computational method** implementing support-compressed leaf counting, with correctness theorem(s).
3. **`demo.py`** that interactively computes and compares:
   - naive ambient leaf counts,
   - compressed leaf counts,
   - exact counts for uniform / graphic / transversal examples,
   - empirical ratios and timings.
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper explaining:
   - the exact theorem,
   - why support geometry compresses certification,
   - worked examples,
   - conjectures and open problems.
5. **`ARTICLE.md`** in Scientific American style, focusing on the mathematics and its significance, not on verification machinery.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions. Each direction must include:
   - a sentence beginning **“The key insight is...”**
   - a sentence beginning **“Why now?”**
   At least one direction must bridge to a different domain, such as statistical physics, coding theory, or network science.

---

## Final Call to Arms

Do not merely show that some branches vanish. Prove that the recursion tree for matroid basis polynomials is secretly the independent-set complex in disguise. That is the field-opening statement here. Once formalized, it changes the language of Lorentzian certification from brute-force differentiation to support geometry, and it invites a broader program: **discrete convexity as a complexity theory for symbolic inequalities**.

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
