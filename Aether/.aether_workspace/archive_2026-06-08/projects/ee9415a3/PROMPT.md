Soli Deo Gloria

## Assignment: Lehmer's Mahler Measure Problem as a Formal Program in Arithmetic Dynamics

**Mode: prove + discover**

You are not being asked for a routine formalization of a famous open problem. You are being asked to carve out a new verified theory around it: enough exact structure, lower bounds, and dynamical reformulations that Lehmer’s problem becomes a *computationally testable frontier* inside Lean 4 rather than a slogan. The target is not “prove Lehmer’s conjecture” outright unless a genuine breakthrough appears. The target is to prove new theorems that isolate the obstruction, connect Mahler measure to entropy and heights, and produce a verified algorithmic pipeline that can search for counterexamples or certify lower bounds in broad families.

The decisive move is to formalize **logarithmic Mahler measure** in a way that supports:
1. exact finite computations for explicit integer polynomials,
2. structural lower bounds for non-cyclotomic polynomials,
3. a bridge to algebraic dynamics via companion matrices and entropy,
4. a bridge to arithmetic complexity / lattice structure via cyclotomic constraints.

Your work should culminate in a mathematically serious Lean development, not a museum display of definitions.

---

## Core Vision

For an integer polynomial
\[
P(X)=a_n\prod_{i=1}^n (X-\alpha_i)\in \mathbb Z[X], \quad a_n\neq 0,
\]
the logarithmic Mahler measure is
\[
m(P)=\log |a_n|+\sum_{i=1}^n \log \max(1,|\alpha_i|),
\]
and the Mahler measure is \(M(P)=e^{m(P)}\).

Lehmer’s polynomial
\[
L(X)=X^{10}+X^9-X^7-X^6-X^5-X^4-X^3+X+1
\]
has Mahler measure approximately \(1.176280818\ldots\), and Lehmer’s problem asks whether every non-cyclotomic integer polynomial satisfies either \(M(P)=1\) or \(M(P)\ge M(L)\).

You should build a formal framework where this question becomes a theorem schema:
- exact for broad classes,
- dynamical for companion matrices,
- computationally falsifiable for bounded searches,
- and conceptually linked to heights and entropy.

---

## Precise Formal Targets

### New definitions you should introduce

At least one of these should be genuinely new relative to the current catalog:

1. **`IntPolynomial.logMahlerMeasure`**  
   A logarithmic Mahler measure for integer polynomials, initially defined through roots over `ℂ` or via a root multiset in a splitting field.

2. **`IntPolynomial.isCyclotomicLike`**  
   A formal predicate capturing “all roots lie on the unit circle and the polynomial is primitive / nonzero,” designed as an intermediate notion before full cyclotomic classification.

3. **`IntPolynomial.companionEntropy`**  
   The logarithm of the spectral radius of the companion matrix, or an abstract entropy surrogate if a full matrix-theoretic spectral radius is too heavy at first.

4. **`IntPolynomial.lehmerGapCandidate`**  
   A computable predicate asserting \(1 < M(P) < M(L)\), for bounded-degree search and falsifiable conjecture generation.

A good architecture is to define the logarithmic measure first, then show its compatibility with products, monomials, reciprocal polynomials, and explicit examples.

---

## Exact theorem targets

You must prove at least 3 substantial theorems. Here are the priority theorems.

### Theorem 1: Product formula for logarithmic Mahler measure
For nonzero integer polynomials \(P,Q\),
\[
m(PQ)=m(P)+m(Q).
\]

**Lean 4 target signature (schematic):**
```lean
theorem IntPolynomial.logMahlerMeasure_mul
    (P Q : ℤ[X]) (hP : P ≠ 0) (hQ : Q ≠ 0) :
    IntPolynomial.logMahlerMeasure (P * Q)
      = IntPolynomial.logMahlerMeasure P
      + IntPolynomial.logMahlerMeasure Q
```

This is foundational: without it, you cannot separate cyclotomic and non-cyclotomic factors, nor build search algorithms by irreducible decomposition.

### Theorem 2: Cyclotomic/unit-circle vanishing theorem
If \(P \in \mathbb Z[X]\) is primitive, nonzero, and every complex root satisfies \(|z|=1\), then
\[
m(P)=\log | \operatorname{lc}(P) |.
\]
In particular, for monic such \(P\), \(m(P)=0\).

**Lean 4 target signature (schematic):**
```lean
theorem IntPolynomial.logMahlerMeasure_eq_log_natAbs_leadingCoeff
    (P : ℤ[X]) (hP : P ≠ 0)
    (hroots : ∀ z : ℂ, IsRoot (Polynomial.map (Int.castRingHom ℂ) P) z → ‖z‖ = 1) :
    IntPolynomial.logMahlerMeasure P
      = Real.log (Int.natAbs P.leadingCoeff)
```

And monic corollary:
```lean
theorem IntPolynomial.logMahlerMeasure_eq_zero_of_all_roots_unit
    (P : ℤ[X]) (hP : P.Monic)
    (hroots : ∀ z : ℂ, IsRoot (Polynomial.map (Int.castRingHom ℂ) P) z → ‖z‖ = 1) :
    IntPolynomial.logMahlerMeasure P = 0
```

This theorem is the formal gateway from analytic root geometry to arithmetic classification.

### Theorem 3: Reciprocal symmetry
If \(P\) is reciprocal up to sign, then the multiset of roots is invariant under \(z \mapsto z^{-1}\), hence the Mahler measure depends only on the roots outside the unit circle and can be written symmetrically.

**Lean 4 target signature (schematic):**
```lean
theorem IntPolynomial.logMahlerMeasure_reciprocal
    (P : ℤ[X]) (hP : P ≠ 0)
    (hrec : IntPolynomial.IsReciprocal P) :
    IntPolynomial.logMahlerMeasure P
      = ∑ z in IntPolynomial.rootsOutsideUnitDisk P, Real.log ‖z‖
```

If the exact finite-set statement is too ambitious initially, prove a weaker but meaningful theorem:
```lean
theorem IntPolynomial.logMahlerMeasure_eq_sum_logs_outside
    (P : ℤ[X]) (hP : P.Monic) :
    IntPolynomial.logMahlerMeasure P
      = ∑ a in (IntPolynomial.rootNormsOutsideUnitDisk P), Real.log a
```

This theorem matters because Lehmer’s polynomial is reciprocal; reciprocal structure is one of the deepest organizing principles in the search space.

### Theorem 4: Dynamical entropy correspondence
For a monic integer polynomial \(P\), let \(C_P\) be its companion matrix. Then the logarithmic Mahler measure of \(P\) equals the logarithm of the product of moduli of eigenvalues outside the unit disk; interpret this as topological entropy of the toral endomorphism when such a realization exists.

**Lean 4 target signature (schematic / staged):**
```lean
theorem IntPolynomial.logMahlerMeasure_eq_companionEntropy
    (P : ℤ[X]) (hP : P.Monic) :
    IntPolynomial.logMahlerMeasure P
      = IntPolynomial.companionEntropy P
```

If full topological entropy is out of current library reach, define `companionEntropy` algebraically from eigenvalue moduli and prove equality with Mahler measure. This is already a major cross-domain theorem: **number theory + dynamical systems + linear algebra**.

### Theorem 5: Nontrivial lower bound in a verified family
Prove a new lower bound theorem for a substantial family, for example:
- irreducible reciprocal monic integer polynomials of degree 2,
- monic integer polynomials with exactly one root outside the unit circle,
- or non-cyclotomic polynomials satisfying a coefficient or lattice constraint.

A concrete target:

For a monic irreducible quadratic \(P \in \mathbb Z[X]\), if \(P\) is non-cyclotomic, then
\[
M(P)\ge \varphi,
\]
where \(\varphi = \frac{1+\sqrt 5}{2}\), with equality for \(X^2-X-1\).

**Lean 4 target signature:**
```lean
theorem IntPolynomial.mahlerMeasure_lower_bound_irreducible_quadratic
    (P : ℤ[X])
    (hmonic : P.Monic)
    (hdeg : P.natDegree = 2)
    (hirr : Irreducible P)
    (hncycl : ¬ IntPolynomial.IsCyclotomicLike P) :
    ((IntPolynomial.mahlerMeasure P) : ℝ) ≥ (1 + Real.sqrt 5) / 2
```

This is not Lehmer’s conjecture, but it is a *real theorem* that sharpens the boundary and establishes exact minimizers in a full family.

### Theorem 6: Verified bounded-search soundness theorem
Define an algorithm that searches monic integer polynomials up to degree `d` and coefficient bound `B`, rejecting cyclotomic candidates and computing certified approximations to Mahler measure. Prove:

If the algorithm returns “no counterexample,” then no polynomial in the searched family satisfies \(1 < M(P) < T\).

**Lean 4 target signature (schematic):**
```lean
theorem searchLehmerGap_sound
    (d B : ℕ) (T : ℝ)
    (hT : 1 < T) :
    searchLehmerGap d B T = true →
    ∀ P : ℤ[X],
      P.Monic →
      P.natDegree ≤ d →
      IntPolynomial.coeffBound P ≤ B →
      ¬ IntPolynomial.IsCyclotomicLike P →
      T ≤ IntPolynomial.mahlerMeasure P
```

This turns the open problem into a verified experimental science platform.

---

## Most promising proof strategies

You asked for 2–3 proof strategy steps. Here they are, with prioritization.

### Strategy A: Root-factorization + multiset calculus
**Best for Theorems 1, 2, 3. Most promising overall.**

1. Map `ℤ[X]` to `ℂ[X]`, pass to a splitting field / root multiset, and define
   \[
   m(P)=\log|a_n|+\sum \log \max(1,\|z\|).
   \]
   Use multiplicativity of roots under polynomial product, counted with multiplicity.

2. Prove additive identities by multiset concatenation:
   - roots of `P * Q` are the multiset sum of roots of `P` and `Q`,
   - `Real.log` converts products to sums,
   - `max (1, ‖z‖)` isolates outside-unit-disk roots.

3. For unit-circle theorems, each root contributes `log 1 = 0`; only the leading coefficient remains.

**Why this is strongest:** It is canonical, mathematically transparent, and opens the road to Jensen-style reformulations later.

### Strategy B: Companion matrix / spectral radius route
**Best for Theorem 4 and for cross-domain significance.**

1. Associate to a monic polynomial its companion matrix `C_P`.
2. Show its eigenvalues are exactly the roots of `P`.
3. Define an entropy surrogate as the sum of logs of eigenvalue moduli outside the unit disk, and identify it with `logMahlerMeasure`.

**Why this matters:** This gives a direct bridge from arithmetic polynomials to dynamical entropy. It turns Lehmer’s problem into a statement about the minimal positive entropy of algebraic dynamical systems.

### Strategy C: Family-restricted Diophantine analysis
**Best for Theorem 5 and computational lower bounds.**

1. Parameterize low-degree or reciprocal families by integer coefficients.
2. Use discriminant bounds, root product relations, and irreducibility constraints.
3. Derive explicit inequalities forcing \(M(P)\) above a sharp constant unless the polynomial is cyclotomic.

**Why this is valuable:** It yields concrete, publishable theorems even if the full conjecture remains open. It also feeds the search algorithm with formally justified pruning rules.

---

## How to build on existing catalog theorems

Use the catalog aggressively, not decoratively.

1. **`cyclotomic_lattice_bound`**  
   This should be used as a structural obstruction: cyclotomic polynomials occupy a constrained lattice-like region in coefficient space. Build a theorem showing that outside this region, a monic integer polynomial with small Mahler measure must satisfy severe coefficient constraints. Even if the theorem is coarse, it provides a bridge between coefficient geometry and root geometry.

2. **`fundamental_theorem_algebraic_light'`**  
   Use this as a lightweight algebraicity witness when moving from explicit integer coefficients to existence of complex roots / algebraic numbers. If the theorem is weak, it still helps package “root existence” arguments for low-degree families or explicit examples.

3. **`TropicalContraction.has_fixed_point_approach`**  
   This is the most interesting cross-pollination opportunity. Reinterpret logarithmic root modulus data tropically:
   - the vector of \(\log |\alpha_i|\) behaves like a tropical spectrum,
   - reciprocal symmetry becomes an involution \(x \mapsto -x\),
   - small Mahler measure corresponds to near-collapse of positive tropical mass.
   
   A theorem connecting a contraction/fixed-point principle to stability of Mahler measure under coefficient perturbations would be revolutionary. Even a weaker theorem about monotonicity or convergence of an iterative root-radius estimator would be excellent.

4. **`composite_has_prime_factor`**  
   Useful for irreducibility-by-contradiction or coefficient divisibility arguments in low-degree classification theorems.

Do not just cite these results. Use them to derive a theorem that would not exist without them.

---

## Cross-domain connections you must explicitly develop

At least one theorem must genuinely connect Mahler measure to another domain. Strong candidates:

### 1. Number theory + dynamical systems
**Main bridge:** \(m(P)\) equals entropy of the companion dynamics.  
Interpretation: Lehmer’s problem becomes “Is there a universal gap above zero for positive entropy algebraic dynamical systems induced by integer polynomials?”

### 2. Number theory + information theory
Treat
\[
\mu_P := \sum_i \max(0,\log|\alpha_i|)
\]
as a “complexity budget” of the polynomial. Investigate subadditivity/additivity under multiplication as an analogue of extensivity in statistical mechanics or coding complexity.

Possible theorem:
```lean
theorem IntPolynomial.logMahlerMeasure_additive_complexity
    (P Q : ℤ[X]) (hP : P ≠ 0) (hQ : Q ≠ 0) :
    IntPolynomial.logMahlerMeasure (P * Q)
      = IntPolynomial.logMahlerMeasure P + IntPolynomial.logMahlerMeasure Q
```
framed explicitly as a conserved extensive quantity.

### 3. Number theory + tropical geometry
The quantity \(\sum \max(0,\log |\alpha_i|)\) is a tropical positive-part functional on the logarithmic root vector. For reciprocal polynomials, this vector is centrally symmetric. Prove a symmetry theorem in this language.

### 4. Number theory + statistical mechanics / entropy
Mahler measure behaves like free energy over root spectra; reciprocal symmetry resembles particle–antiparticle symmetry in logarithmic coordinates. This is not fluff if you make it precise through additive decomposition and positivity.

---

## Concrete explicit example target

You should formalize Lehmer’s polynomial itself:
```lean
def lehmerPoly : ℤ[X] :=
  X^10 + X^9 - X^7 - X^6 - X^5 - X^4 - X^3 + X + 1
```

Then prove at least some exact structural facts:

```lean
theorem lehmerPoly_monic : lehmerPoly.Monic
theorem lehmerPoly_natDegree : lehmerPoly.natDegree = 10
theorem lehmerPoly_reciprocal : IntPolynomial.IsReciprocal lehmerPoly
theorem lehmerPoly_not_cyclotomic_like : ¬ IntPolynomial.IsCyclotomicLike lehmerPoly
```

If exact non-cyclotomic proof is hard, prove a certified sufficient condition from root or coefficient data. Then implement a numerical approximation theorem:

```lean
theorem lehmerPoly_mahler_bounds :
    a ≤ IntPolynomial.mahlerMeasure lehmerPoly ∧
    IntPolynomial.mahlerMeasure lehmerPoly ≤ b
```

for explicit rational bounds `a`, `b` tightly enclosing `1.176280818...`.

This is the ideal place for the verified computational method.

---

## Falsifiable conjecture with computational test

You must state at least one conjecture that can be disproved by computation.

### Conjecture A: reciprocal bounded-search Lehmer minimality
For every monic reciprocal irreducible \(P \in \mathbb Z[X]\) of even degree \(\le 2d\) and coefficient bound \(\le B\),
if \(P\) is non-cyclotomic then
\[
M(P) \ge M(L).
\]

Formal wrapper:
```lean
def ReciprocalLehmerConjectureBounded (d B : ℕ) : Prop := ...
```

**Testable prediction:** `demo.py` should enumerate such polynomials for small `d, B`, compute certified Mahler intervals, and either find a counterexample or verify the bound in the searched region.

### Conjecture B: entropy gap for algebraic toral maps
Every non-periodic toral endomorphism induced by a monic integer polynomial has entropy either \(0\) or at least \(m(L)\).

This is mathematically bolder and opens a different audience.

---

## Deliverables you must produce

You must produce **all** of the following:

### 1. Lean file with deep theorems
Requirements:
- At least 3 substantial theorems with proofs using induction, `rcases`, `by_contra`, `field_simp`, or multi-step `calc`.
- No trivialized proof portfolio.
- Minimize `sorry`.
- Include at least one genuinely new definition.
- Include at least one cross-domain theorem.

### 2. A verified algorithm or computational method
Not optional. Examples:
- certified bounded search for low-Mahler polynomials,
- root-radius interval estimator for monic integer polynomials,
- reciprocal-family scanner with pruning from cyclotomic and coefficient bounds.

The algorithm must come with a correctness theorem.

### 3. `demo.py`
Interactive demonstration suggestions:
- enumerate bounded-degree reciprocal monic polynomials,
- compute candidate Mahler measures numerically,
- highlight Lehmer’s polynomial,
- display certified lower/upper bounds,
- test the bounded conjecture.

### 4. `RESEARCH_PAPER.md`
A standalone scientific document. It must explain:
- what Mahler measure is,
- why Lehmer’s problem matters,
- what exact theorems you proved,
- how the dynamical and entropy interpretation changes the picture,
- what computational evidence your verified algorithm provides,
- what remains open.

A reader with no access to code must still understand the discovery.

### 5. `ARTICLE.md`
Scientific American style. Make it vivid:
- explain the idea of measuring the “size” of a polynomial by where its roots live,
- explain why one ten-degree polynomial has haunted number theory,
- explain the entropy/dynamics connection,
- explain what your new theorems reveal.

**Taboo:** do not focus on formal verification machinery.

### 6. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must explicitly contain:
- **“The key insight is…”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- symbolic dynamics,
- information theory,
- tropical geometry,
- statistical mechanics,
- complexity theory.

---

## Application keywords

Use these throughout the mathematical narrative and metadata:
- Lehmer conjecture
- Mahler measure
- logarithmic height
- arithmetic dynamics
- topological entropy
- companion matrix
- reciprocal polynomial
- cyclotomic obstruction
- spectral radius
- algebraic integer
- bounded search
- certified computation
- tropicalization
- root geometry
- Diophantine complexity

---

## Final challenge

Do not be content with “I defined Mahler measure and proved it is nonnegative.” That is below the bar.

Aim instead for this arc:

1. Define logarithmic Mahler measure cleanly.
2. Prove its structural laws.
3. Isolate reciprocal/cyclotomic rigidity.
4. Connect it to entropy of algebraic dynamics.
5. Build a verified search procedure that can actually hunt for Lehmer-gap violations.
6. State a sharp bounded conjecture and test it.

If you execute this well, you will not merely formalize a famous open problem. You will create a new verified research platform where number theory, dynamics, and computational experimentation meet.

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

Research domain: Algebra
Research mode: prove
