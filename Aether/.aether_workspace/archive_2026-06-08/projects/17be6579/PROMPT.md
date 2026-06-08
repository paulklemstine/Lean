Soli Deo Gloria

## Assignment: Direction 1: M-Convexity Closure Under Differentiation

**Mode:** `prove`

Prove a genuinely new theorem at the interface of **Lorentzian polynomials, matroid contraction, and discrete convex analysis**. This is not an incremental exercise: it is a formal certification that the derivative hierarchy of a polynomial preserves the hidden exchange geometry of its exponent support. If established, this gives a machine-checked bridge from algebraic operations on generating polynomials to structural operations on matroidal/M-convex sets, and opens a route toward a formal theory of Lorentzian renormalization, Hodge-type inequalities, and combinatorial optimization by differentiation.

Build on the catalog’s definitions of support, exchange/M-convexity, and `MvPolynomial.pderiv`. Minimize sorry. Do not settle for finite-case enumeration as proof. The target is a conceptual theorem with a proof architecture that scales.

---

## Core Conjectural Program

The driving conjecture is:

> If `p` is a homogeneous multivariate polynomial with nonnegative coefficients whose support satisfies the exchange axiom, then for every variable `x_i`, the support of the partial derivative `∂p/∂x_i` also satisfies the exchange axiom.

This is the algebraic avatar of the principle:

- **differentiation = contraction**,  
- **M-convex support = valuated matroid shadow**,  
- therefore  
- **the derivative tower should remain in the world of discrete convexity**.

The theorem is important because it says the combinatorial skeleton of a Lorentzian-type object is stable under the most fundamental local operation in analysis.

---

## Precise Theorem Targets

You should aim to formalize not just one theorem, but a coherent package. At minimum, prove 3 substantial theorems.

### 1. Main closure theorem
```lean
theorem SupportSatisfiesExchange.pderiv
    {n : ℕ} {p : MvPolynomial (Fin n) ℝ} {i : Fin n} :
    SupportSatisfiesExchange p →
    SupportSatisfiesExchange (MvPolynomial.pderiv i p)
```

This is the flagship theorem. If the current definition of `SupportSatisfiesExchange` implicitly depends on homogeneity or nonnegativity, make those hypotheses explicit and prove the strongest correct version.

A more precise version may be mathematically necessary:

```lean
theorem SupportSatisfiesExchange.pderiv_of_homogeneous_of_nonneg
    {n : ℕ} {p : MvPolynomial (Fin n) ℝ} {d : ℕ} {i : Fin n} :
    p.IsHomogeneous d →
    (∀ m, 0 ≤ p.coeff m) →
    SupportSatisfiesExchange p →
    SupportSatisfiesExchange (MvPolynomial.pderiv i p)
```

If the theorem is actually true without one or more of these hypotheses, strengthen the result accordingly.

---

### 2. Iterated derivative closure theorem
The true breakthrough is not one derivative, but the whole derivative hierarchy.

```lean
theorem SupportSatisfiesExchange.iteratedPDeriv
    {n : ℕ} {p : MvPolynomial (Fin n) ℝ} :
    SupportSatisfiesExchange p →
    ∀ ks : Fin n → ℕ,
      SupportSatisfiesExchange
        ((Finset.univ).fold
          (fun q i => (Nat.iterate (MvPolynomial.pderiv i) (ks i)) q)
          p)
```

If this exact fold formulation is awkward, define a clean operator for mixed partials first. The conceptual statement is:

> Every mixed partial derivative of an M-convex-supported polynomial again has M-convex support.

This is the formal counterpart of repeated matroid contraction.

---

### 3. Support-level contraction theorem
Introduce a new support-side notion making the derivative/contraction correspondence explicit.

Define a new concept, for example:
```lean
def SupportContraction
    {n : ℕ} (S : Finset (Fin n →₀ ℕ)) (i : Fin n) : Finset (Fin n →₀ ℕ) := ...
```

Intended meaning: exponent vectors in `S` with positive `i`-coordinate, shifted by subtracting one copy of `i`.

Then prove:
```lean
theorem support_pderiv_eq_supportContraction
    {n : ℕ} {p : MvPolynomial (Fin n) ℝ} {i : Fin n} :
    support (MvPolynomial.pderiv i p) =
      SupportContraction (support p) i
```

This may require coefficient-side hypotheses to avoid zero cancellation; if so, use:
```lean
(∀ m, 0 ≤ p.coeff m)
```
or even
```lean
∀ m ∈ support p, 0 < p.coeff m
```
depending on the exact support API. This theorem is not cosmetic: it is the structural dictionary entry that turns algebra into combinatorics.

---

### 4. Cross-domain theorem: differentiation as matroid contraction shadow
Include at least one theorem explicitly connecting to a different domain. A strong candidate is combinatorial optimization / submodularity.

Define a degree-slice rank/support function or a discrete Legendre-type quantity attached to the support, then prove a contraction monotonicity theorem. For example:

```lean
theorem exchangeRank_pderiv_le
    {n : ℕ} {p : MvPolynomial (Fin n) ℝ} {i : Fin n} :
    SupportSatisfiesExchange p →
    ExchangeRank (MvPolynomial.pderiv i p) ≤ ExchangeRank p
```

or, if `ExchangeRank` is too ambitious, define a simpler invariant such as the set of achievable marginals and prove it behaves functorially under derivative/contraction.

This is your required cross-domain bridge:
- **algebraic combinatorics** ↔ **discrete optimization**
- optionally also ↔ **statistical physics** via partition functions and cavity deletion.

---

## New Definitions You Should Introduce

At least one genuinely new concept must appear. Recommended candidates:

### A. Support contraction
```lean
def SupportContraction
    {n : ℕ} (S : Finset (Fin n →₀ ℕ)) (i : Fin n) : Finset (Fin n →₀ ℕ)
```
This is the support-level image of partial differentiation.

### B. Derivative-stable exchange family
```lean
def DerivativeStableExchange
    {n : ℕ} (p : MvPolynomial (Fin n) ℝ) : Prop :=
  SupportSatisfiesExchange p ∧
  ∀ i, SupportSatisfiesExchange (MvPolynomial.pderiv i p)
```
Then prove the main theorem as:
```lean
theorem SupportSatisfiesExchange.to_derivativeStableExchange ...
```

### C. Exchange depth / contraction depth
```lean
def ExchangeDepth
    {n : ℕ} (p : MvPolynomial (Fin n) ℝ) : ℕ := ...
```
Interpretation: maximum order of mixed differentiation preserving nonzero support / exchange structure. This could become an invariant relevant to optimization and Hodge-theoretic stratification.

---

## Why This Would Be a Breakthrough

This result would formalize a principle mathematicians use informally but rarely isolate cleanly:

- Lorentzianity is stable under differentiation.
- M-convexity is the support-theoretic shadow of Lorentzianity.
- Therefore support exchange should survive differentiation.

Making this precise does three things:

1. **It creates a certified interface between continuous and discrete convexity.**  
   One can move from analytic operations on generating polynomials to combinatorial operations on supports.

2. **It opens a derivative calculus for matroidal support geometry.**  
   Once derivatives preserve exchange, one can study Hessians, directional derivatives, polarization, and flow operators while remaining inside the exchange world.

3. **It suggests algorithmic consequences.**  
   Recognition, optimization, and sampling procedures on exchange supports can be transported through derivative towers, potentially yielding new algorithms for basis-generating polynomials, partition functions, and negative dependence structures.

This is the kind of result that can seed a formal theory of **combinatorial differentiation**.

---

## Proof Strategy Architecture

You must not present only one route. Develop at least 2–3 approaches and identify the most promising.

### Strategy A: Direct support transport via exponent subtraction
Most promising for Lean.

1. Unfold the definition of `MvPolynomial.pderiv` on coefficients:
   the coefficient at monomial `m` in `pderiv i p` is proportional to the coefficient of `m + single i 1` in `p`.
2. Prove that the support of `pderiv i p` is exactly the image of the positive-`i` slice of `support p` under subtraction of `single i 1`.
3. Show the exchange axiom is preserved under this contraction map:
   if `a,b` satisfy exchange in `support p`, then `a - e_i, b - e_i` satisfy the corresponding exchange in the contracted support, after careful case analysis on whether the exchanged coordinates involve `i`.

Why promising: it uses concrete APIs for coefficients, finite support, and finitely supported functions (`Finsupp`), and avoids importing the full external Lorentzian theory.

Deep proof tactics likely needed:
- `rcases` on support membership witnesses,
- multi-step `calc` for coefficient identities,
- `by_contra` in support equivalence directions,
- induction for iterated derivative closure.

---

### Strategy B: Reinterpret differentiation as matroid contraction
Most conceptually elegant.

1. Formalize a support-side contraction operation and prove it coincides with polynomial differentiation at the support level.
2. Prove directly that M-convex sets are closed under contraction.
3. Transfer closure from support contraction to `pderiv`.

Why it matters: this exposes the theorem as a discrete convexity theorem independent of coefficients. It also creates reusable infrastructure for deletion/contraction style theorems in matroid theory.

Most delicate point: you may need a robust support-level formulation of exchange for finite subsets of `Fin n →₀ ℕ`, and a precise subtraction lemma for exponent vectors with positive coordinate.

---

### Strategy C: Lorentzian shadow route
Most visionary, potentially hardest to formalize now.

1. Use known mathematics: homogeneous polynomials with M-convex support and suitable coefficient inequalities belong to the Lorentzian world.
2. Invoke closure of Lorentzian polynomials under partial differentiation.
3. Prove that supports of Lorentzian polynomials satisfy exchange, and transfer back.

Why powerful: this would connect your theorem to the Brändén–Huh framework and position the development for Hodge-theoretic consequences.  
Why risky: likely heavier missing infrastructure in Lean.

Recommendation: **Use Strategy A as the main formal proof**, but structure the paper and future directions around Strategies B and C.

---

## Technical Lemmas Likely Needed

Expect to prove supporting lemmas of the following form.

### Coefficient transport under differentiation
```lean
theorem coeff_pderiv_eq
    {n : ℕ} {p : MvPolynomial (Fin n) ℝ} {i : Fin n} {m : Fin n →₀ ℕ} :
    (MvPolynomial.pderiv i p).coeff m =
      (m i + 1) * p.coeff (m + Finsupp.single i 1)
```
or whatever exact catalog theorem already exists. If it exists, use it explicitly as the engine.

### Positive-support characterization
```lean
theorem mem_support_pderiv_iff
    {n : ℕ} {p : MvPolynomial (Fin n) ℝ} {i : Fin n} {m : Fin n →₀ ℕ}
    (hnonneg : ∀ s, 0 ≤ p.coeff s) :
    m ∈ support (MvPolynomial.pderiv i p) ↔
      m + Finsupp.single i 1 ∈ support p
```
This is where nonnegativity prevents cancellation pathologies.

### Contraction preserves exchange
```lean
theorem supportContraction_preserves_exchange
    {n : ℕ} {S : Finset (Fin n →₀ ℕ)} {i : Fin n} :
    SetSatisfiesExchange S →
    SetSatisfiesExchange (SupportContraction S i)
```
Adapt theorem name to the actual support-level predicate in the catalog.

### Iterated contraction closure
```lean
theorem supportContraction_iterate_preserves_exchange
    {n : ℕ} {S : Finset (Fin n →₀ ℕ)} :
    SetSatisfiesExchange S →
    ∀ ks : Fin n → ℕ,
      SetSatisfiesExchange (SupportMultiContraction S ks)
```

---

## Cross-Domain Connections You Must Highlight

Do not leave this as an isolated combinatorics result. Explicitly connect it to at least one other domain in theorem statements, definitions, examples, or discussion.

### 1. Discrete optimization / submodularity
M-convex sets are central in Murota’s discrete convex analysis. Differentiation preserving exchange means polynomial operations induce optimization-stable contractions. This suggests derivative-based algorithms for feasible-set reduction and local search.

### 2. Statistical physics
For basis-generating and partition-function-type polynomials, `pderiv i` corresponds to conditioning or deleting one unit of occupation. Exchange preservation suggests that negative dependence structures may survive local conditioning in combinatorially rigid models.

### 3. Hodge theory / Lorentzian geometry
Derivative stability is a shadow of Hodge-Riemann type positivity. Formalizing the support shadow is a first step toward certified Alexandrov–Fenchel style inequalities in combinatorial settings.

### 4. Tropical geometry
Supports are Newton polytopes in disguise. Derivative contraction acts on lattice points and should correspond to facewise/tropical truncation phenomena. Mention this in the paper even if not fully formalized.

---

## Computational Component and Falsifiable Conjecture

You must include a **verified algorithm or computational method**, not just theorem statements.

### Algorithmic deliverable
Implement a support-level recognition-and-test pipeline:
1. enumerate homogeneous finite supports in degree `≤ 6` on `≤ 5` variables,
2. test the exchange axiom,
3. compute support contraction / derivative support,
4. test exchange again,
5. report any counterexample.

This should be reflected in Lean where feasible, with a Python demonstration in `demo.py`.

### Required falsifiable conjecture
State and test at least one stronger conjecture. For example:

> **Conjecture (Mixed derivative universality).**  
> For every homogeneous polynomial `p` with nonnegative coefficients and M-convex support, every nonzero mixed partial derivative of `p` has M-convex support.

A computational disproof is immediate if any enumerated support fails after repeated contractions.

An even bolder conjecture:

> **Conjecture (Exchange-depth equals minimum coordinate width).**  
> The maximal order of nonzero mixed derivatives preserving nonempty support equals a support-theoretic width invariant computable from the Newton polytope.

This is highly testable and could be false in an interesting way.

---

## Lean 4 Formalization Targets

You should produce precise Lean-facing statements, even if some need adaptation to actual API names.

### Main theorem
```lean
theorem SupportSatisfiesExchange.pderiv
    {n : ℕ} {p : MvPolynomial (Fin n) ℝ} {i : Fin n} :
    SupportSatisfiesExchange p →
    SupportSatisfiesExchange (MvPolynomial.pderiv i p)
```

### Support contraction definition
```lean
def SupportContraction
    {n : ℕ} (S : Finset (Fin n →₀ ℕ)) (i : Fin n) :
    Finset (Fin n →₀ ℕ) :=
  S.filter (fun m => 0 < m i) |>.image
    ⟨fun m => m - Finsupp.single i 1, by
      intro a b h
      -- prove injectivity on the filtered domain
      sorry⟩
```
If subtraction on `Finsupp` is awkward, define the contracted exponent explicitly coordinatewise.

### Support equality theorem
```lean
theorem support_pderiv_eq_supportContraction
    {n : ℕ} {p : MvPolynomial (Fin n) ℝ} {i : Fin n}
    (hpos : ∀ m ∈ p.support, 0 < p.coeff m) :
    (MvPolynomial.pderiv i p).support = SupportContraction p.support i
```

### Iterated derivative closure
```lean
theorem SupportSatisfiesExchange.mixedPDeriv
    {n : ℕ} {p : MvPolynomial (Fin n) ℝ} :
    SupportSatisfiesExchange p →
    ∀ ks : Fin n → ℕ, SupportSatisfiesExchange (mixedPDeriv ks p)
```
You may define:
```lean
def mixedPDeriv {n : ℕ} (ks : Fin n → ℕ) (p : MvPolynomial (Fin n) ℝ) :
    MvPolynomial (Fin n) ℝ := ...
```

### Cross-domain invariant theorem
```lean
theorem contraction_monotone_on_exchangeWidth
    {n : ℕ} {p : MvPolynomial (Fin n) ℝ} {i : Fin n} :
    SupportSatisfiesExchange p →
    exchangeWidth (MvPolynomial.pderiv i p) ≤ exchangeWidth p
```
If `exchangeWidth` is newly defined, make it mathematically meaningful and computationally testable.

---

## Expected Proof Tactics

Your file must contain at least 3 theorems whose proofs genuinely use deep tactics such as:

- `induction` for mixed derivative closure or support contraction iteration,
- `rcases` for unpacking exchange witnesses and support membership,
- `by_contra` when proving support equivalence or nonvanishing,
- `field_simp` if coefficient identities involve normalization factors,
- multi-step `calc` blocks for coefficient transport and support equalities.

Do not satisfy the assignment with toy lemmas. The hard part is transporting exchange witnesses through derivative-induced support contraction.

---

## Recommended File Structure

1. **Definitions**
   - `SupportContraction`
   - `mixedPDeriv`
   - one new invariant such as `ExchangeDepth` or `exchangeWidth`

2. **Coefficient and support lemmas**
   - coefficient formula for `pderiv`
   - membership in derivative support iff shifted membership in original support
   - contraction/support equality

3. **Main structural theorems**
   - contraction preserves exchange
   - `SupportSatisfiesExchange.pderiv`
   - iterated/mixed derivative closure

4. **Cross-domain theorem**
   - optimization/statistical-physics/tropical invariant under contraction

5. **Computational testing**
   - exhaustive checker up to degree 6, 5 variables
   - counterexample search
   - summary theorem or data export

---

## Deliverables You Must Produce

You must produce **all** of the following.

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 research directions. Each direction must include the exact phrases:

- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- Hodge theory,
- tropical geometry,
- statistical physics,
- combinatorial optimization.

Write as original scientific prose, not a template.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper. A reader with no access to the code must understand:
- the theorem proved,
- why it matters,
- how it connects to Lorentzian/discrete convex theories,
- what the computational evidence shows,
- what to investigate next.

### 3. `ARTICLE.md`
Write in **Scientific American** style:
- broad audience,
- idea-centered,
- significance-centered,
- vivid explanation of differentiation preserving hidden combinatorial structure.

**Taboo:** do **not** focus on formal verification machinery. Write about the mathematics and why it changes the landscape.

### 4. Verified algorithm or computational method
Not just a theorem. Implement a certified or partially certified method for:
- recognizing exchange supports,
- computing derivative/contraction supports,
- testing closure under repeated differentiation.

### 5. `demo.py`
An interactive demonstration that:
- constructs sample homogeneous polynomials,
- computes derivative supports,
- checks exchange,
- visualizes or prints the contraction hierarchy,
- searches for counterexamples in bounded degree/variable range.

---

## Application Keywords

Use and foreground these in the paper and article:

**Lorentzian polynomials, M-convexity, discrete convex analysis, matroid contraction, Newton support, partial differentiation, Hodge theory, negative dependence, partition functions, tropical geometry, combinatorial optimization, support transport, mixed partials, valuated matroids, exchange axiom**

---

## Catalog Usage

Build explicitly on the catalog entries around Lorentzian polynomials and support exchange. Cite the exact file/theorem names you use inside the code comments and paper. If the injected context contains a vetted theorem about support recognition or coefficient formulas for `pderiv`, make it the backbone of the development rather than reproving it.

In particular, leverage catalog results of the form:
- coefficient formulas for `MvPolynomial.pderiv`,
- support characterizations,
- existing `SupportSatisfiesExchange` lemmas,
- homogeneity lemmas,
- finite support APIs for `MvPolynomial`.

If a stronger theorem in the exact conjectured form is false, pivot immediately to `counterexample` mode and isolate the sharp corrected theorem. A single explicit counterexample with a proof of failure is scientifically valuable and should be treated as a discovery, not a defeat.

The ambition is clear: **show that differentiation preserves exchange geometry, and thereby make derivative calculus a first-class operation in discrete convex combinatorics.**

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
