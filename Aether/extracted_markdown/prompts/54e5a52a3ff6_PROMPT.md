Soli Deo Gloria

## Assignment: Direction 3 — Tropical Faithfulness of Differentiation

**Mode:** `prove`

You are to establish a genuinely new tropical–algebraic dictionary: **differentiation is tropically faithful exactly when valuative non-cancellation prevents coefficient collapse**. This is not an incremental lemma about supports; it is a structural theorem linking symbolic differentiation, convex geometry, and tropicalization.

Build directly on:

- `Bridges/Catalog/Speculative/AutoResearch/NonCancellationCertificate.lean`
- any existing tropical / Newton polytope / finitely supported function infrastructure in Mathlib and the Catalog
- finite-support polynomial APIs (`MvPolynomial`, support lemmas, derivatives if available; otherwise define the required mixed-partial support operators carefully)

Your goal is to turn the conjectural slogan

> “the certificate is exactly the obstruction to tropical faithfulness of second differentiation”

into a package of formal theorems, algorithms, experiments, and a scientific narrative.

---

## Central Vision

Let `p` be a multivariate polynomial over a valued field `K` of characteristic zero. The mixed partial derivative `∂ᵢ∂ⱼ p` is formed by shifting exponents by `eᵢ + eⱼ` and rescaling coefficients. On the level of **supports/Newton polytopes**, this should behave like a **combinatorial shadow operator**: remove one unit in the `i` and `j` directions whenever possible. But this naive shadow can fail because distinct precursor monomials may collapse to the same exponent and cancel at the coefficient level.

The **non-cancellation certificate** should be the exact condition ensuring that the tropical/combinatorial shadow matches the algebraic derivative. If proved, this gives a formal criterion for when tropical differentiation is faithful, opening a new route to tropical intersection theory, discriminants, and certified symbolic–tropical computation.

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems**. At least one should use contradiction or contrapositive reasoning, and at least one should use multi-step `calc` / support manipulation / convex-geometric inclusion arguments.

You may need to introduce a new finite-dimensional support-shadow structure if the catalog lacks the exact notion.

### New definitions to introduce

At minimum define one or more of the following, ensuring novelty relative to the catalog:

1. `mixedShadow` on exponent sets:
   - sends a support set `S ⊆ ℕ^σ` to the set of exponents `a` such that `a + eᵢ + eⱼ ∈ S`
   - or equivalently the image of admissible exponents under subtraction by `eᵢ + eⱼ`

2. `NewtonShadow` on Newton polytopes:
   - the convex-geometric shadow induced by subtracting `eᵢ + eⱼ` from exponents with sufficient coordinate mass

3. `TropFaithfulDiff`:
   - a predicate asserting that the support / Newton polytope / tropicalization of `∂ᵢ∂ⱼ p` agrees with the combinatorial shadow predicted from `p`

4. `SecondOrderNonCancellationCertificate`:
   - a specialization or refinement of the existing certificate adapted to mixed partials and valuative uniqueness of minimizers/contributors

You should design these definitions so that theorems can be stated cleanly both combinatorially and algebraically.

---

## Theorem 1: Support-level faithfulness under certificate

### Mathematical statement
For a polynomial `p`, if the second-order non-cancellation certificate holds for indices `i, j`, then the support of `∂ᵢ∂ⱼ p` is exactly the mixed shadow of the support of `p`.

This is the first real theorem: it isolates the precise support-level mechanism behind tropical faithfulness.

### Suggested Lean 4 type signature
Use a finite index type for variables, e.g. `σ : Type* [DecidableEq σ] [Fintype σ]`. A representative theorem could be:

```lean
theorem support_mixedPartial_eq_mixedShadow
    {K σ : Type*} [Field K] [CharZero K] [DecidableEq σ] [Fintype σ]
    (p : MvPolynomial σ K) (i j : σ)
    (hcert : SecondOrderNonCancellationCertificate p i j) :
    mixedPartialSupport p i j = mixedShadow (Finsupp.single i 1 + Finsupp.single j 1) p.support
```

If `p.support` is not the right type directly, define the theorem over a coerced finite set / set of exponent vectors.

A more realistic variant if derivative APIs are awkward:

```lean
theorem support_mixedPartial_eq_mixedShadow
    {K σ : Type*} [Field K] [CharZero K] [DecidableEq σ] [Fintype σ]
    (p : MvPolynomial σ K) (i j : σ)
    (hcert : SecondOrderNonCancellationCertificate p i j) :
    (mixedPartial i j p).support = Finset.filter
      (fun a => a + Finsupp.single i 1 + Finsupp.single j 1 ∈ p.support)
      (p.support.image fun b => b - (Finsupp.single i 1 + Finsupp.single j 1))
```

### Why this is a breakthrough
This theorem identifies a **necessary algebraic certificate for a purely combinatorial tropical rule to become exact**. It is a concrete bridge from symbolic algebra to tropical combinatorics.

---

## Theorem 2: Newton polytope equality as Minkowski shadow

### Mathematical statement
Assume the certificate from Theorem 1. Then the Newton polytope of `∂ᵢ∂ⱼ p` equals the convex hull of the mixed shadow of the support of `p`. Under the standard admissibility hypothesis (“all relevant exponents have coordinates at least the differentiation order”), this equals the Newton shadow / truncated Minkowski difference by the segment or point-shift corresponding to `eᵢ + eⱼ`.

This theorem is the geometric heart of the project.

### Suggested Lean 4 type signature
Because full polytope infrastructure may vary, state it in the strongest available formal language. If you build Newton polytopes as convex hulls in `σ → ℝ`, aim for:

```lean
theorem newtonPolytope_mixedPartial_eq_shadow
    {K σ : Type*} [Field K] [CharZero K] [DecidableEq σ] [Fintype σ]
    [LinearOrderedField R]
    (v : K →₀ ℤ∞)  -- or whatever valuation interface is available / appropriate
    (p : MvPolynomial σ K) (i j : σ)
    (hcert : SecondOrderNonCancellationCertificate p i j) :
    newtonPolytope (mixedPartial i j p) =
      newtonShadow i j (newtonPolytope p)
```

If `newtonShadow` is too ambitious to define abstractly, prove instead:

```lean
theorem newtonPolytope_mixedPartial_eq_convexHull_mixedShadow
    {K σ : Type*} [Field K] [CharZero K] [DecidableEq σ] [Fintype σ]
    (p : MvPolynomial σ K) (i j : σ)
    (hcert : SecondOrderNonCancellationCertificate p i j) :
    newtonPolytope (mixedPartial i j p) =
      convexHull ℝ (mixedShadowSet i j (supportSet p))
```

Then add a separate theorem identifying this convex hull with a Minkowski-type difference under admissibility hypotheses.

### Why this is a breakthrough
This upgrades a support computation into a **convex-geometric equivalence theorem**. It gives a rigorous mechanism for passing from algebraic differentiation to Newton polytope dynamics, exactly the sort of statement tropical geometers use implicitly but rarely isolate formally.

---

## Theorem 3: Failure of certificate implies strict shadow over-approximation

### Mathematical statement
If the certificate fails, then the mixed shadow is in general only an over-approximation: there exists an exponent predicted by the shadow that is absent from the support of `∂ᵢ∂ⱼ p`, and consequently the Newton polytope of the derivative is contained in, and for explicit examples strictly contained in, the predicted shadow polytope.

This theorem should include a formal counterexample family, not just an existential handwave.

### Suggested Lean 4 type signature
A clean version:

```lean
theorem mixedShadow_overapproximates_support_mixedPartial
    {K σ : Type*} [Field K] [CharZero K] [DecidableEq σ] [Fintype σ]
    (p : MvPolynomial σ K) (i j : σ) :
    (mixedPartial i j p).support ⊆ mixedPartialSupportOverapprox p i j
```

and then a nontrivial strictness theorem for an explicit family:

```lean
theorem exists_strict_inclusion_without_certificate
    {K : Type*} [Field K] [CharZero K] :
    ∃ p : MvPolynomial (Fin 2) K, ∃ i j : Fin 2,
      ¬ SecondOrderNonCancellationCertificate p i j ∧
      (mixedPartial i j p).support ⊂ mixedPartialSupportOverapprox p i j
```

If proving strict polytope containment is more robust than strict support containment in your infrastructure, do that.

### Why this is a breakthrough
A field-opening result is not just a positive theorem; it identifies the exact obstruction. This theorem transforms the certificate from a sufficient condition into a mathematically meaningful **boundary marker** between faithful and non-faithful tropicalization.

---

## Theorem 4 (Cross-domain theorem): Tropical differentiation meets convex optimization / Legendre duality

You must include at least one theorem that bridges to another domain. The most promising bridge here is:

- **convex analysis / optimization**
- alternatively **algebraic statistics**
- alternatively **combinatorial physics** via energy landscapes

### Mathematical statement
Show that the mixed shadow operation on Newton polytopes corresponds to a translation/truncation operation on the support function, and therefore to a piecewise-linear update on the tropical polynomial viewed as a convex potential.

Concretely: for admissible directions `w`, the support function of the Newton polytope of `∂ᵢ∂ⱼ p` equals the support function of `Newt(p)` shifted by `⟨w, eᵢ + eⱼ⟩`, restricted to faces surviving the certificate.

### Suggested Lean 4 type signature
Abstractly:

```lean
theorem supportFunction_newtonShadow
    {σ : Type*} [DecidableEq σ] [Fintype σ]
    (P : ConvexBody σ) (i j : σ) (w : σ → ℝ) :
    supportFunction (newtonShadow i j P) w =
      supportFunction P w - (w i + w j)
```

This may need hypotheses ensuring the shadow is nonempty / admissible. If full support-function formalization is too large, prove a finite polytope version for convex hulls of finite sets.

### Why this matters
This connects tropical differentiation to **convex duality**, meaning your work is not merely about polynomials but about **energy landscapes, optimization geometry, and piecewise-linear Hamiltonians**. That is exactly the kind of cross-pollination that creates new fields.

---

## Main Conjecture to state and computationally test

You must explicitly state a falsifiable conjecture and implement a test.

### Conjecture: Tropical faithfulness criterion
For polynomials over a nontrivially valued field `K` of characteristic zero, the following are equivalent for fixed `i, j`:

1. `SecondOrderNonCancellationCertificate p i j`
2. `supp(∂ᵢ∂ⱼ p) = mixedShadow(supp p)`
3. `Newt(∂ᵢ∂ⱼ p) = newtonShadow(Newt p)`
4. the tropicalization of `∂ᵢ∂ⱼ p` equals the tropical differential shadow of `Trop(p)` on all cells where the certificate predicts unique leading contributors

A Lean-friendly predicate version:

```lean
def TropFaithfulDiff
    {K σ : Type*} [Field K] [CharZero K] [DecidableEq σ] [Fintype σ]
    (p : MvPolynomial σ K) (i j : σ) : Prop := ...
```

and conjecture:

```lean
conjecture tropical_faithfulness_iff_certificate
    {K σ : Type*} [Field K] [CharZero K] [DecidableEq σ] [Fintype σ]
    (p : MvPolynomial σ K) (i j : σ) :
    TropFaithfulDiff p i j ↔ SecondOrderNonCancellationCertificate p i j
```

### Testable prediction
In random polynomial families with bounded support in 2D/3D:

- when the certificate holds, equality rates between actual derivative Newton polytope and predicted shadow should be 100%
- when the certificate fails, strict inclusion should occur with positive frequency, increasing with support collision density

This is computationally falsifiable.

---

## Proof Architecture: 3 viable strategies

You must pursue at least two in the file/comments/paper, and explain why one is primary.

### Strategy A: Support-first algebraic proof
**Best primary route.**

1. Define the mixed shadow on exponent vectors and prove a general lemma:
   coefficients of `∂ᵢ∂ⱼ p` at exponent `a` are sums of coefficients of `p` at `a + eᵢ + eⱼ` times explicit scalar factors.
2. Show inclusion
   `support(∂ᵢ∂ⱼ p) ⊆ mixedShadow(support p)`
   unconditionally.
3. Use the certificate to show every shadow exponent has a nonzero coefficient contribution with no cancellation, yielding reverse inclusion.
4. Pass to convex hulls to deduce Newton polytope equality.

Why promising: this route matches Mathlib’s strength on finitely supported algebraic objects and minimizes geometric overhead until the final step.

### Strategy B: Vertex / face method on Newton polytopes
1. Characterize vertices or exposed faces of `Newt(∂ᵢ∂ⱼ p)` via maximizers of linear functionals.
2. Compare exposed faces before and after differentiation by tracking exponent shifts.
3. Use the certificate to prove no exposed face disappears unexpectedly.
4. Deduce polytope equality from face equality.

Why powerful: this is conceptually closest to tropical geometry and may generalize to higher-order differential operators and discriminants.

Risk: polytope/face infrastructure may be heavier in Lean.

### Strategy C: Valuative/tropical route
1. Define the tropical differential shadow on tropical polynomials as a min-plus transform on exponent-weight pairs.
2. Show algebraic differentiation followed by tropicalization always gives a lower envelope bounded by the shadow transform.
3. Use the certificate to prove equality of minimizers / leading terms.
4. Recover support and Newton polytope results as corollaries.

Why exciting: this most directly realizes the slogan “tropicalization commutes with differentiation under certificate.”

Risk: depends on valuation formalization and tropical APIs that may be incomplete.

**Recommendation:** Make Strategy A the formal backbone, Strategy B the geometric upgrade, and Strategy C the conceptual framing in `RESEARCH_PAPER.md`.

---

## Specific technical lemmas you should aim to prove

These are not optional fluff; they are the scaffolding for the major theorems.

1. **Derivative support inclusion**
```lean
theorem support_mixedPartial_subset_shadow ...
```

2. **Coefficient formula for mixed partial**
```lean
theorem coeff_mixedPartial
    (p : MvPolynomial σ K) (i j : σ) (a : σ →₀ ℕ) :
    coeff a (mixedPartial i j p) =
      mixedPartialCoeffFormula p i j a
```

3. **No-cancellation gives nonvanishing**
```lean
theorem certificate_implies_coeff_ne_zero ...
```

4. **Convex hull monotonicity transfer**
```lean
theorem newtonPolytope_mono_from_support_subset ...
```

5. **Convex hull equality from support equality**
```lean
theorem newtonPolytope_eq_of_support_eq ...
```

6. **Strict inclusion example**
Construct an explicit 2-variable polynomial with two precursor monomials whose mixed derivative contributions cancel.

A model family to formalize:
- choose coefficients so two distinct terms contribute to the same mixed-partial monomial with opposite signs
- verify predicted shadow contains that exponent but derivative support omits it

This should require real algebraic reasoning, not brute force.

---

## Lean 4 implementation guidance

Work in a new file such as:

```text
Bridges/Catalog/Speculative/AutoResearch/TropicalFaithfulDifferentiation.lean
```

If mixed partial derivatives for `MvPolynomial` are missing or awkward, define:

```lean
def mixedPartial (i j : σ) (p : MvPolynomial σ K) : MvPolynomial σ K := ...
```

and prove basic API lemmas yourself.

Likewise define:

```lean
def mixedShadowExponent (i j : σ) : (σ →₀ ℕ) → Option (σ →₀ ℕ)
def mixedShadowSet (i j : σ) (S : Set (σ →₀ ℕ)) : Set (σ →₀ ℕ)
def mixedPartialSupportOverapprox ...
def TropFaithfulDiff ...
```

Prefer finite support statements first (`Finset`), then lift to `Set` and convex hulls.

Use genuine proof methods:
- induction on finite support where natural
- `rcases` on support membership witnesses
- `by_contra` for reverse-inclusion arguments
- `field_simp` if scalar coefficient factors require normalization in characteristic zero
- multi-step `calc` for support-function or convex-hull equalities

Avoid proofs whose essence is computation by normalization.

---

## Cross-domain connections to emphasize

You must explicitly develop at least one of these in the theorem statements, paper, and article:

1. **Convex optimization**
   - Newton polytope shadows correspond to support-function shifts
   - tropical differentiation becomes an operation on piecewise-linear energy landscapes

2. **Algebraic statistics**
   - supports/Newton polytopes encode model complexity; differentiation corresponds to marginal sensitivity
   - certificate predicts when tropical sensitivity analysis is exact

3. **Mathematical physics**
   - tropical polynomials as zero-temperature free energies
   - differentiation shadow as a combinatorial response operator
   - certificate marks absence of destructive interference in asymptotic regimes

4. **Computational complexity**
   - exactness of combinatorial differentiation gives certified shortcuts for derivative support computation
   - could reduce symbolic blowup in sparse polynomial algorithms

---

## Application keywords

Include these keywords in the paper and article where appropriate:

- tropical geometry
- Newton polytope
- mixed partial derivative
- non-cancellation certificate
- faithful tropicalization
- convex hull
- Minkowski shadow
- support function
- sparse polynomial computation
- tropical intersection theory
- discriminants
- algebraic statistics
- convex optimization
- asymptotic energy landscape

---

## Deliverables (ALL mandatory)

You must produce all of the following:

### 1. `FUTURE_DIRECTIONS.md`
Provide **3–5 original research directions** unlocked by this work. Each direction must include the exact sentences:

- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a genuinely different domain, such as optimization, physics, or statistics.

Possible directions to consider:
- higher-order tropical-faithful differential operators
- tropical Hessians and curvature-like invariants
- faithful tropicalization of resultants/discriminants under certificate conditions
- tropical sensitivity theory for sparse statistical models
- complexity-theoretic derivative shadow algorithms

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper that explains:
- the main definitions
- the exact theorems proved
- why the certificate is the right obstruction
- computational experiments
- significance for tropical geometry and adjacent fields
- open problems

Someone reading only this paper must understand the discovery without any code.

### 3. `ARTICLE.md`
Write this in **Scientific American style**:
- engaging
- idea-driven
- accessible to broad scientific readers

**Taboo:** do **not** focus on formal verification machinery. Focus on the mathematics, the new dictionary between differentiation and tropical geometry, and why it matters.

### 4. Verified algorithm / computational method
Implement a verified method for:
- computing mixed derivative support over-approximation via shadow
- computing actual mixed derivative support
- comparing Newton polytopes in 2D and 3D
- detecting certificate satisfaction or failure on finite examples

If full convex hull verification in Lean is too large, verify the combinatorial support-shadow layer in Lean and make the convex hull computation trustworthy/tested in Python, clearly documenting the trusted boundary.

### 5. `demo.py`
Provide an interactive demonstration that:
- samples sparse polynomials in 2D/3D
- computes support, mixed derivative support, and predicted shadow
- computes Newton polytopes / convex hulls
- highlights equality vs strict inclusion
- exhibits explicit failure examples when cancellation occurs

The demo should make the theorem feel experimentally alive.

---

## Experimental program

Your computational experiments must include:

1. **Random sparse 2D and 3D polynomial families**
   - bounded degree
   - random supports
   - random coefficients from small integer sets

2. **Certificate-positive regime**
   - examples where equality always holds

3. **Certificate-negative regime**
   - examples with support collisions and cancellation
   - measure frequency of strict inclusion

4. **Visualization**
   - plot support sets and Newton polytopes before/after differentiation
   - overlay predicted shadow vs actual derivative polytope

5. **Explicit showcase examples**
   - at least one “perfect faithfulness” example
   - at least one “catastrophic cancellation” example

---

## Standard of ambition

Do not stop at “support inclusion.” The point is to prove a theorem that a tropical geometer would actually cite:

> **Under a second-order non-cancellation certificate, mixed differentiation is tropically faithful at the level of support and Newton polytope; without the certificate, the combinatorial shadow is only an over-approximation and can be strictly larger.**

That is a real statement. It creates a new interface between symbolic differentiation and tropical geometry.

Make the file mathematically serious, the proofs layered, the examples sharp, and the exposition worthy of a new research program.

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
