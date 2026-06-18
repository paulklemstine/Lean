Soli Deo Gloria

## Assignment: Lehmer's Mahler Measure Problem

**Mode: prove + discover**

Attack Lehmer’s problem not as an isolated extremal question, but as the seed of a formal theory linking **Mahler measure, logarithmic height, spectral entropy, algebraic dynamics, and tropical/root-geometry barriers**. The goal is not to “solve Lehmer’s conjecture” outright in one cycle, but to create a **verified theorem stack** that makes the conjecture mathematically rigid, computationally testable, and structurally connected to other fields.

You must prove **new, non-trivial theorems** and build on catalog theorems where they genuinely help. Minimize sorry. Avoid any result whose essence is brute-force evaluation.

---

## Core Vision

Lehmer’s polynomial
\[
L(x)=x^{10}+x^9-x^7-x^6-x^5-x^4-x^3+x+1
\]
has Mahler measure approximately \(1.17628\ldots\), and the conjecture says:

> Every non-cyclotomic monic integer polynomial \(f\) has Mahler measure at least \(M(L)\).

This is one of the sharpest “gap” problems in arithmetic complexity: it predicts a universal positive lower bound on arithmetic-dynamical complexity outside the cyclotomic locus. Formalizing this properly opens a field: **verified entropy gaps for algebraic dynamics**, **height lower bounds via root geometry**, and **algorithmic certification of non-cyclotomic complexity**.

Your task is to build a Lean 4 framework in which Lehmer-type lower bounds become statements about:
- roots outside the unit circle,
- positivity of logarithmic Mahler measure,
- cyclotomic obstructions,
- entropy of companion dynamics,
- and computable lower-bound certificates.

This is important because a verified theory here would bridge:
- **number theory**: heights, algebraic integers, cyclotomicity;
- **dynamical systems**: topological entropy of toral/solenoidal endomorphisms;
- **spectral theory**: product of expanding eigenvalues;
- **tropical/root geometry**: max-log envelopes from root moduli;
- **computational mathematics**: certified screening algorithms for low Mahler measure polynomials.

---

## Precise Formal Targets

You must define a robust notion of Mahler measure for integer polynomials, preferably first through roots over `ℂ`, then logarithmically.

A mathematically clean target is:

\[
M(f)=|a_n|\prod_{\alpha : f(\alpha)=0}\max(1,|\alpha|),
\qquad
m(f)=\log M(f)=\log |a_n|+\sum_\alpha \log \max(1,|\alpha|).
\]

For monic integer polynomials, this simplifies to
\[
M(f)=\prod_\alpha \max(1,|\alpha|), \qquad
m(f)=\sum_\alpha \log \max(1,|\alpha|).
\]

You should introduce at least one genuinely new definition, for example:

- `rootEscapeMass` = sum over roots of `Real.log (max 1 ‖α‖)`,
- `isExpansivePolynomial` = all roots satisfy `1 < ‖α‖`,
- `cyclotomicDefect` = a numerical witness that a polynomial has a root off the unit circle,
- `mahlerLowerCertificate` = a finite-data certificate implying `c ≤ logMahler f`.

These are not merely coding conveniences; they are new formal interfaces between arithmetic and dynamics.

---

## Suggested Lean 4 Type Signatures

You do not need to use these exact names, but your theorem statements should be this precise.

### New definitions
```lean
noncomputable def logMahlerMeasure (f : Polynomial ℤ) : ℝ := ...
noncomputable def mahlerMeasure (f : Polynomial ℤ) : ℝ := Real.exp (logMahlerMeasure f)

noncomputable def rootEscapeMass (f : Polynomial ℤ) : ℝ := ...

def IsCyclotomicLike (f : Polynomial ℤ) : Prop := ...

def MahlerLowerCertificate (f : Polynomial ℤ) (c : ℝ) : Prop := ...
```

### Theorem 1: nonnegativity and rigidity
A foundational theorem that is already nontrivial if proved through root-factor reasoning, not by automation.

```lean
theorem logMahlerMeasure_nonneg
    (f : Polynomial ℤ) (hf : f ≠ 0) :
    0 ≤ logMahlerMeasure f
```

A stronger rigidity theorem is even better:

```lean
theorem logMahlerMeasure_eq_zero_iff_all_roots_le_one
    (f : Polynomial ℤ) (hf : f.Monic) (hneq : f ≠ 0) :
    logMahlerMeasure f = 0 ↔
      ∀ z : ℂ, Polynomial.aeval z f = 0 → ‖z‖ ≤ 1
```

If the exact iff is too hard in one cycle, prove one direction plus a converse under a separability/splitting hypothesis.

### Theorem 2: strict positivity from an escaping root
This is the key arithmetic-dynamical bridge.

```lean
theorem positive_logMahler_of_root_outside_unit_circle
    (f : Polynomial ℤ) (hfmonic : f.Monic)
    (z : ℂ)
    (hz : Polynomial.aeval z f = 0)
    (hesc : 1 < ‖z‖) :
    0 < logMahlerMeasure f
```

This theorem should use genuine analysis/algebra: root contributions to the logarithmic sum, positivity of `Real.log`, and multiplicity bookkeeping.

### Theorem 3: entropy connection for companion dynamics
You must include at least one cross-domain theorem. The strongest target is an entropy identity or lower bound for the companion matrix / algebraic dynamical system associated to a monic polynomial.

A realistic theorem form:

```lean
noncomputable def companionSpectralEntropy (f : Polynomial ℤ) : ℝ := ...

theorem logMahler_eq_companion_entropy
    (f : Polynomial ℤ) (hf : f.Monic) (hdeg : 0 < f.natDegree) :
    logMahlerMeasure f = companionSpectralEntropy f
```

If full equality is too ambitious, prove a lower bound:

```lean
theorem logMahler_le_companionSpectralEntropy
    (f : Polynomial ℤ) (hf : f.Monic) :
    logMahlerMeasure f ≤ companionSpectralEntropy f
```

Interpretation: Lehmer’s conjectural gap becomes an **entropy gap theorem** for algebraic dynamics.

### Theorem 4: certified lower bounds from explicit root data
This gives the required algorithmic/computational deliverable.

```lean
theorem certificate_implies_logMahler_lower_bound
    (f : Polynomial ℤ) (c : ℝ)
    (hcert : MahlerLowerCertificate f c) :
    c ≤ logMahlerMeasure f
```

You should define `MahlerLowerCertificate` so it can be checked from approximate roots plus rigorous error margins, interval bounds, or root-counting regions.

### Theorem 5: Lehmer polynomial witness
You should at minimum formalize the specific polynomial and prove meaningful facts about it.

```lean
def lehmerPoly : Polynomial ℤ :=
  X^10 + X^9 - X^7 - X^6 - X^5 - X^4 - X^3 + X + 1

theorem lehmerPoly_monic : lehmerPoly.Monic := ...
theorem lehmerPoly_not_cyclotomic_like : ¬ IsCyclotomicLike lehmerPoly := ...
theorem lehmerPoly_positive_logMahler :
    0 < logMahlerMeasure lehmerPoly := ...
```

If feasible, also produce a verified numerical enclosure:

```lean
theorem lehmerPoly_logMahler_lower_bound :
    (0.16 : ℝ) ≤ logMahlerMeasure lehmerPoly
```

or a stronger rational lower bound close to the true value.

---

## Minimum Theorem Package

Your file must contain at least **3 substantial theorems** proved with deep tactics and multi-step arguments, not mere simplification. A strong package would be:

1. `logMahlerMeasure_nonneg`
2. `positive_logMahler_of_root_outside_unit_circle`
3. `certificate_implies_logMahler_lower_bound`
4. one cross-domain theorem such as `logMahler_eq_companion_entropy`
5. one theorem about `lehmerPoly`

At least one proof should use:
- induction over roots / degree or finite multisets,
- `rcases` on factorization or root existence,
- `by_contra` to force positivity from a nontrivial root,
- `field_simp` if you pass through reciprocal-polynomial identities,
- multi-step `calc` with `Real.log`, `Finset.sum`, and inequalities.

---

## Proof Strategy Architecture

### Strategy A: Root-multiset / Jensen-style decomposition
**Most promising** if Mathlib already gives enough polynomial root machinery over `ℂ`.

1. Define `logMahlerMeasure` via the multiset of roots of `f.map (Int.castRingHom ℂ)` counted with multiplicity.
2. Prove each summand `Real.log (max 1 ‖z‖)` is nonnegative.
3. Show a root with `1 < ‖z‖` contributes strictly positively, so the total sum is positive.
4. For monic polynomials, eliminate leading coefficient terms and derive clean rigidity statements.

Why this is promising: it gives the most canonical mathematics, aligns with classical Mahler measure, and naturally supports positivity and entropy interpretations.

### Strategy B: Reciprocal polynomial + coefficient identities
Especially useful for monic integer polynomials and cyclotomic obstructions.

1. Define a reciprocal/reversed polynomial and prove identities comparing roots inside and outside the unit circle.
2. Use contradiction: if `logMahlerMeasure = 0`, then all root contributions vanish, forcing all roots onto/inside the unit circle.
3. Combine with integer-coefficient structure to derive strong constraints suggestive of cyclotomicity or “cyclotomic-like” behavior.
4. Use `field_simp` and explicit reciprocal identities to manage root inversions.

Why this matters: it creates a bridge toward Kronecker-type statements and gives a formal route from “small Mahler measure” to “special algebraic structure.”

### Strategy C: Dynamical/spectral route via companion matrices
Best for the cross-domain theorem.

1. Associate to a monic polynomial its companion matrix over `ℂ` or `ℝ`.
2. Show eigenvalues are the roots of the polynomial.
3. Define spectral entropy as the sum of logs of expanding eigenvalue moduli.
4. Identify this sum with `logMahlerMeasure`.

Why this is revolutionary: it reframes Lehmer’s problem as a universal lower-bound problem for entropy in algebraic dynamics. This is the bridge theorem that makes the project field-opening.

**Recommended order:** A first, then C, then B. A gives the core invariant. C gives the conceptual breakthrough. B gives arithmetic rigidity and future access to cyclotomic classification.

---

## How to Build on Existing Catalog Theorems

Use catalog theorems only where they genuinely amplify the architecture.

- `cyclotomic_lattice_bound`  
  Use this as a structural bound on cyclotomic complexity or as a model for proving that cyclotomic objects lie in a quantitatively constrained region, contrasting with positive escape mass. Even if not directly about Mahler measure, it can motivate/structure a theorem that cyclotomic-like polynomials have zero escape mass while non-cyclotomic candidates must exceed a positive lower certificate.

- `fundamental_theorem_algebraic_light'`  
  Use as a lightweight existence principle for algebraic structure when constructing root-based arguments or ensuring nontrivial algebraic data exists in low-degree auxiliary situations.

- `TropicalContraction.has_fixed_point_approach`  
  This is a valuable cross-pollination tool: use it to motivate or formalize an iterative scheme for approximating dominant roots / root moduli, yielding computable certificates for lower bounds on Mahler measure. A fixed-point approach to the dominant root is a natural algorithmic bridge to tropical geometry and nonlinear dynamics.

- `commuting_operator_has_invariant_subspace_of_compact_eigenvalue`  
  If you develop the companion-operator entropy viewpoint, this theorem can help justify invariant subspace language and spectral decomposition heuristics in the dynamical formulation.

Do not force these theorems into the proof if they are not mathematically natural. But where possible, use them to create a genuine bridge theorem, not decorative citation.

---

## Cross-Domain Connections You Must Exploit

At least one theorem must connect Mahler measure to a different domain. Strong options:

### 1. Number theory + dynamical systems
Interpret `logMahlerMeasure f` as entropy of the algebraic dynamical system induced by the companion map. This is the best choice.

### 2. Number theory + tropical geometry
Define a tropicalized root modulus profile:
\[
\tau_f(t)=\max_i (\log |a_i| + i t)
\]
and relate breakpoints or slopes heuristically to lower bounds on root escape mass. Even a rigorous inequality connecting coefficient tropicalization to a Mahler lower certificate would be novel.

### 3. Number theory + spectral theory / operator theory
Show that expanding spectral mass of the companion operator lower-bounds Mahler measure. This ties arithmetic complexity to operator growth.

### 4. Number theory + information theory
Frame `logMahlerMeasure` as a complexity/entropy functional on algebraic data; prove monotonicity under certain polynomial transforms if feasible.

---

## Conjecture with Testable Prediction

You must state at least one falsifiable conjecture and provide a computational test that could refute it.

A strong option:

```lean
conjecture lehmer_gap_degree_bounded
    (d : ℕ) :
    ∃ ε > 0, ∀ f : Polynomial ℤ,
      f.Monic →
      f.natDegree ≤ d →
      ¬ IsCyclotomicLike f →
      ε ≤ logMahlerMeasure f
```

Testable prediction:
- Exhaust monic integer polynomials of degree `≤ d` with coefficients in `[-B, B]`.
- Filter out cyclotomic-like cases.
- Compute certified lower bounds on `logMahlerMeasure`.
- Search for violations below Lehmer’s value.

An even sharper computational conjecture:

> Among reciprocal monic integer polynomials of even degree at most `20` and bounded coefficients, `lehmerPoly` uniquely minimizes certified `logMahlerMeasure` among non-cyclotomic cases.

This is falsifiable by search.

---

## Required New Definitions

You must define at least one genuinely new concept. Recommended package:

1. `rootEscapeMass`
   - Sum of positive logarithmic root moduli.
   - This is the arithmetic-dynamical complexity functional.

2. `MahlerLowerCertificate`
   - A finite, checkable witness that forces `c ≤ logMahlerMeasure f`.
   - This is essential for the algorithmic component.

3. `IsCyclotomicLike`
   - A formally tractable proxy for “all roots lie on the unit circle” or “product of cyclotomic factors.”
   - If exact cyclotomicity is hard, define a rigorous intermediate notion and prove theorems about it.

These are scientifically valuable abstractions, not placeholders.

---

## Algorithmic Deliverable

You must provide a **verified algorithm or computational method**, not just theorems.

Recommended target:

### Certified Mahler lower-bound engine
Input: monic `f : Polynomial ℤ`.

Output:
- either a certificate that `logMahlerMeasure f ≥ c`,
- or an “inconclusive” result.

Possible approaches:
1. Numerically approximate roots over `ℂ`,
2. certify a subset with modulus provably `> 1 + δ`,
3. sum rigorous lower bounds on `log ‖z‖`,
4. output a `MahlerLowerCertificate f c`.

This can be implemented using interval arithmetic, rational enclosures, or root-radius inequalities. The theorem `certificate_implies_logMahler_lower_bound` must justify the output.

---

## Demo Requirements

Provide `demo.py` that:
- constructs `lehmerPoly`,
- computes a numerical approximation to its Mahler measure,
- runs your certified lower-bound routine,
- compares several nearby reciprocal polynomials,
- reports whether any tested example beats Lehmer’s value,
- visualizes root moduli or entropy contributions.

This demo should feel like an exploratory research instrument, not a toy script.

---

## Application Keywords

Include and emphasize these in your writeup and code comments:

**Lehmer’s conjecture, Mahler measure, logarithmic height, algebraic dynamics, entropy gap, companion matrix, spectral radius, cyclotomic obstruction, root geometry, Jensen formula, reciprocal polynomial, tropicalization, certified computation, algebraic complexity, dynamical rigidity**

---

## Deliverables (MANDATORY)

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Provide 3–5 original research directions. Each direction must include:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**

At least one direction must bridge to a different domain, such as:
- symbolic dynamics,
- tropical geometry,
- operator algebras,
- information theory,
- arithmetic complexity.

### 2. `RESEARCH_PAPER.md`
A standalone scientific document. A reader with no code access must understand:
- the formal definitions,
- the theorems proved,
- why they matter,
- how they relate to Lehmer’s problem,
- what computational evidence was obtained,
- what new conjectures and programs follow.

Do not write it as notes; write it as a real paper.

### 3. `ARTICLE.md`
Write in **Scientific American style** for a broad audience.
Explain:
- what Mahler measure is,
- why Lehmer’s tiny polynomial is mysterious,
- how entropy and dynamics unexpectedly enter,
- why this hints at a hidden law of arithmetic complexity.

**Taboo:** do **not** focus on formal verification machinery. Focus on the mathematical ideas and significance.

### 4. Verified algorithm / computational method
A genuine implemented method with a correctness theorem, ideally the certificate engine above.

### 5. `demo.py`
An interactive demonstration of the result and the conjectural landscape.

---

## Standard of Ambition

Do not settle for “Mahler measure is nonnegative” unless it is part of a larger architecture culminating in:
- strict positivity from escaping roots,
- an entropy or spectral interpretation,
- and a certified computational method.

The breakthrough target is:

> Build the first verified Lean framework in which Lehmer’s problem becomes a theorem schema about **entropy gaps for algebraic dynamics** and **certified lower bounds from root-escape geometry**.

That is a field-opening platform, not an incremental formalization.

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

Research domain: Algebra
Research mode: prove
