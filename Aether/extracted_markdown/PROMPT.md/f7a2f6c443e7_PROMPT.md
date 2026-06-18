Soli Deo Gloria

# Assignment: Euler–Mascheroni Constant Irrationality via Structural Obstructions, Continued Fractions, and Arithmetic Transforms

## Mode: `prove`

Aristotle, do **not** treat this as a routine attempt to “prove γ irrational.” That direct target is likely beyond current formal reach. Instead, build a **field-opening formal framework** that isolates **necessary irrationality mechanisms** for the Euler–Mascheroni constant
\[
\gamma := \lim_{n\to\infty}\left(\sum_{k=1}^n \frac1k - \log n\right),
\]
and makes irrationality/transcendence attacks mathematically executable in Lean 4.

The breakthrough is to formalize a **certificate architecture for irrationality**: continued-fraction growth, accelerated rational approximants, integral transforms, and arithmetic obstruction lemmas linking γ to special-value phenomena. If successful, this creates the first verified research platform where irrationality strategies for γ can be compared, stress-tested, and algorithmically explored.

You are to prove **new, non-trivial theorems** and define at least one genuinely new concept. The goal is not a cosmetic formalization of folklore; it is to construct a rigorous bridge between:

- asymptotic analysis of harmonic-logarithmic errors,
- Diophantine approximation / continued fractions,
- arithmetic transforms suggestive of special values of zeta/L-functions,
- and computational falsification infrastructure.

## Central Vision

Introduce a new object: an **Euler–Mascheroni irrationality certificate** built from explicit rational approximants and denominator growth bounds.

A promising formal direction is to define, for rational sequences \(A_n/B_n\), a property saying they approximate a real \(x\) too well relative to denominator growth for \(x\) to be rational. Then instantiate this for accelerated approximants to γ derived from harmonic sums, Euler summation, or logarithmic integral identities.

Even if full irrationality remains out of reach, proving theorems that force any rationality proof/disproof to pass through explicit asymptotic barriers would already be a major advance.

---

## Required New Definition

Define a new concept, something in the spirit of:

```lean
structure IrrationalityCertificate (x : ℝ) where
  A : ℕ → ℤ
  B : ℕ → ℤ
  hBpos : ∀ n, 0 < B n
  tendsTo : Tendsto (fun n => ((A n : ℝ) / (B n : ℝ))) atTop (𝓝 x)
  errorBound : ∃ C p : ℝ, 0 < C ∧ 1 < p ∧
    ∀ᶠ n in atTop, |x - (A n : ℝ) / (B n : ℝ)| ≤ C / (B n : ℝ)^p
```

or a more arithmetic version tailored to continued fractions / linear forms in \(1,\gamma,\log m\).

Also define an explicit sequence approximating γ, for example:

```lean
def harmonicLogApprox (n : ℕ) : ℝ :=
  (∑ k in Finset.Icc 1 n, (1 : ℝ) / k) - Real.log n
```

with the convention that you separately handle `n = 0`, or define on positive naturals / `ℕ+`.

You may also define an accelerated sequence such as

```lean
def gammaAccelerant (n : ℕ) : ℝ := ...
```

based on Euler–Maclaurin-style cancellation or a logarithmic integral identity.

Novelty requirement: this certificate framework must not merely rename an existing Mathlib notion.

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems**. Below are the primary targets; prove as many as possible, with at least three completed.

### Theorem 1: Monotone convergence of harmonic-log approximants

Prove that the sequence
\[
a_n = H_n - \log n
\]
is eventually monotone and converges, and package the limit as the Euler–Mascheroni constant candidate.

A Lean-facing statement could be:

```lean
theorem harmonicLogApprox_monotone_eventually :
  ∃ N : ℕ, MonotoneOn harmonicLogApprox (Set.Ici N)
```

More concretely, the sharper theorem is:

```lean
theorem harmonicLogApprox_antitone :
  Antitone fun n : ℕ+ => harmonicLogApprox n
```

and

```lean
theorem harmonicLogApprox_bdd_below :
  ∃ c : ℝ, ∀ n : ℕ+, c ≤ harmonicLogApprox n
```

hence:

```lean
theorem harmonicLogApprox_converges :
  ∃ γ : ℝ, Tendsto harmonicLogApprox atTop (𝓝 γ)
```

This is not trivial: prove it using logarithmic inequalities, monotonicity, and order completeness.

### Theorem 2: Rational-obstruction theorem from superquadratic approximation

This is the key structural theorem. Prove that any real admitting sufficiently strong rational approximation is irrational unless eventually constant in the rational case.

A target theorem:

```lean
theorem irrational_of_superquadratic_approx
    {x : ℝ}
    (h : ∃ (A B : ℕ → ℤ) (C p : ℝ),
      0 < C ∧ 2 < p ∧
      (∀ᶠ n in Filter.atTop, 0 < B n) ∧
      Tendsto (fun n => ((A n : ℝ) / (B n : ℝ))) Filter.atTop (𝓝 x) ∧
      (∀ᶠ n in Filter.atTop,
        |x - (A n : ℝ) / (B n : ℝ)| ≤ C / (B n : ℝ)^p)) :
    Irrational x
```

You may need a slightly weaker or cleaner version with `p = 2 + ε`, or assuming infinitely many distinct rationals \(A_n/B_n\). If the exact statement is technically awkward over `ℝ`, formulate it first for reduced rationals in `ℚ` embedded into `ℝ`.

This theorem is a breakthrough enabler: it turns irrationality into a search for verified approximation certificates.

### Theorem 3: Continued-fraction denominator growth obstruction

Formalize enough continued fractions to prove a theorem of the following flavor:

> If a real number has eventually bounded continued-fraction coefficients, then its convergents cannot approximate it beyond quadratic order with arbitrarily small constant.

A Lean target may look like:

```lean
theorem bounded_cf_no_superquadratic_approx
    (x : ℝ)
    (hx : Irrational x)
    (K : ℕ)
    (hK : ∀ᶠ n in Filter.atTop, continuedFractionCoeff x n ≤ K) :
    ∃ C > 0, ∀ᶠ n in Filter.atTop,
      C / ((q n : ℝ)^2) ≤ |x - (p n : ℝ) / (q n : ℝ)|
```

If full continued-fraction infrastructure is too heavy, prove an equivalent theorem for an abstract recurrence of convergents. The point is to formalize a **Diophantine rigidity principle**.

### Theorem 4: Harmonic-log telescoping inequality with explicit error bounds

Prove explicit two-sided bounds such as
\[
\frac{1}{2(n+1)} \le H_n - \log n - \gamma \le \frac{1}{2n}
\]
or a formally weaker but explicit inequality derived from convexity of log. If γ is introduced as the limit, phrase the theorem as a Cauchy-control estimate:

```lean
theorem harmonicLogApprox_cauchy_rate :
  ∀ n m : ℕ+, n ≤ m →
  |harmonicLogApprox n - harmonicLogApprox m| ≤ (1 : ℝ) / n
```

or, sharper,

```lean
theorem harmonicLogApprox_step_bounds (n : ℕ+) :
  0 ≤ harmonicLogApprox n - harmonicLogApprox (n+1) ∧
  harmonicLogApprox n - harmonicLogApprox (n+1) ≤ 1 / ((n : ℝ)^2)
```

This theorem gives the computational backbone for certified experiments.

### Theorem 5: Cross-domain theorem linking γ-style approximants to Dirichlet/L-series tails

You must include a theorem connecting this domain to another mathematical domain. One strong option is analytic number theory:

Define a logarithmically weighted arithmetic sum, e.g.
\[
S_f(n)=\sum_{k\le n}\frac{f(k)}{k},
\]
for a multiplicative or periodic arithmetic function \(f\), and prove a decomposition theorem showing that when \(f\) has mean zero, the logarithmic divergence cancels.

A Lean target:

```lean
theorem periodic_mean_zero_log_weighted_bounded
    (f : ℕ → ℝ)
    (q : ℕ)
    (hq : 0 < q)
    (hper : ∀ n, f (n + q) = f n)
    (hmean : ∑ i in Finset.range q, f i = 0) :
    ∃ C : ℝ, ∀ n ≥ 1, |∑ k in Finset.Icc 1 n, f k / k| ≤ C
```

This is a genuine cross-domain bridge:
- harmonic analysis / periodic structures,
- analytic number theory,
- and special-value heuristics for \(L(1,\chi)\).

If you can, push further and isolate the analogy:
- \(H_n - \log n\) is the non-periodic “constant term” phenomenon,
- periodic mean-zero sums approximate \(L(1,\chi)\)-type values.

This opens the route from γ to special values of L-functions without pretending they are already the same object.

---

## Lean 4 Type Signature Suggestions

You asked for precise signatures. Here are candidate signatures Aristotle can refine to fit Mathlib APIs.

```lean
def harmonicLogApprox : ℕ+ → ℝ
```

```lean
def eulerMascheroniCandidate : ℝ :=
  sInf (Set.range harmonicLogApprox)
```

or better via existence theorem rather than a definition by `sInf`.

```lean
structure IrrationalityCertificate (x : ℝ) where
  A : ℕ → ℤ
  B : ℕ → ℤ
  hBpos : ∀ᶠ n in Filter.atTop, 0 < B n
  hdistinct : Set.Infinite (Set.range fun n => (A n, B n))
  rate :
    ∃ C p : ℝ, 0 < C ∧ 2 < p ∧
      ∀ᶠ n in Filter.atTop,
        |x - ((A n : ℝ) / (B n : ℝ))| ≤ C / (B n : ℝ)^p
```

```lean
theorem certificate_implies_irrational
    {x : ℝ} :
    IrrationalityCertificate x → Irrational x
```

```lean
theorem harmonicLogApprox_antitone :
  Antitone harmonicLogApprox
```

```lean
theorem harmonicLogApprox_lower_bound :
  ∃ c : ℝ, ∀ n : ℕ+, c ≤ harmonicLogApprox n
```

```lean
theorem harmonicLogApprox_tendsto :
  ∃ γ : ℝ, Filter.Tendsto harmonicLogApprox Filter.atTop (𝓝 γ)
```

```lean
theorem harmonicLogApprox_successive_diff_formula (n : ℕ+) :
  harmonicLogApprox n - harmonicLogApprox (n+1)
    = Real.log (1 + (1 : ℝ) / n) - (1 : ℝ) / (n+1)
```

```lean
theorem periodic_mean_zero_log_weighted_bounded
    (f : ℕ → ℝ) (q : ℕ) (hq : 0 < q)
    (hper : ∀ n, f (n + q) = f n)
    (hmean : ∑ i in Finset.range q, f i = 0) :
    ∃ C : ℝ, ∀ n : ℕ, 1 ≤ n →
      |∑ k in Finset.Icc 1 n, f k / k| ≤ C
```

If continued fractions are available in Mathlib in a usable form, add:

```lean
theorem bounded_partial_quotients_denominator_growth
    (a : ℕ → ℕ) (K : ℕ)
    (hK : ∀ n, a n ≤ K) :
    ∃ C > 0, ∀ n, (q n : ℝ) ≤ C * ((K+1 : ℝ) ^ n)
```

followed by an approximation obstruction theorem.

---

## Proof Strategy Architecture

You must pursue at least 2–3 proof avenues, not just one.

### Strategy A: Order-theoretic / convexity route for γ existence and explicit error bounds
1. Define \(a_n = H_n - \log n\) on positive naturals.
2. Prove the exact step identity
   \[
   a_n-a_{n+1} = \log\!\left(1+\frac1n\right)-\frac1{n+1}.
   \]
3. Use standard log inequalities from convexity/concavity:
   \[
   \frac{x}{1+x} \le \log(1+x) \le x \quad (x>-1),
   \]
   with \(x=1/n\), to show monotonicity and boundedness.
4. Deduce convergence via monotone convergence in `ℝ`.

**Why promising:** this is the cleanest route to a verified γ object with quantitative estimates and uses deep multi-step `calc`, inequalities, and asymptotics rather than brute-force evaluation.

### Strategy B: Diophantine approximation certificate route
1. Prove a general lemma: if \(x=a/b\in\mathbb Q\), then for any distinct rational \(p/q\),
   \[
   \left|x-\frac pq\right|\ge \frac{1}{bq}.
   \]
2. Upgrade this to an eventual contradiction with any approximation rate \(O(q^{-p})\) for \(p>1\), or more safely \(p>2\) if you want a clean irrationality criterion.
3. Package the data as `IrrationalityCertificate x`.
4. Show how a future γ-approximant generator could instantiate this structure.

**Why promising:** this theorem is independent of the final fate of γ and creates reusable machinery for many constants.

### Strategy C: Abel summation / periodic arithmetic bridge to L-values
1. For periodic \(f\) with mean zero, decompose partial sums into residue classes mod \(q\).
2. Use bounded partial sums of \(f\) and summation by parts / discrete Abel transform to prove boundedness of \(\sum_{k\le n} f(k)/k\).
3. Interpret this as a formal shadow of convergence of \(L(1,\chi)\).
4. Compare this with the non-canceling constant-term behavior in \(H_n-\log n\).

**Why promising:** this is the strongest cross-domain theorem. It opens a conceptual bridge from γ to special values of Dirichlet series and gives a language for “why γ behaves like a renormalized special value but resists the algebraicity patterns of classical \(L(1,\chi)\).”

Most promising overall:
- **A + B** are the core.
- **C** is the visionary bridge that makes the project more than a sequence-limit exercise.

---

## Suggested Use of Existing Catalog Theorems

The listed catalog theorems are heterogeneous, but you should still opportunistically build on them where structurally meaningful.

- `qdf_euler_composition` may inspire an arithmetic-composition viewpoint: use it as precedent for encoding nontrivial algebraic/arithmetic identities in Lean and for designing recurrence-based rational approximants.
- `euler_totient_semiprime` can support examples in the cross-domain section when constructing periodic arithmetic functions via residue systems modulo semiprimes.
- `galois_connection_theory_variety` is conceptually relevant if you package irrationality certificates as a theory/obstruction correspondence, though likely not directly used in proof.
- `euler_char'` is not mathematically central here, but it is a reminder to prefer structural transformations over raw computation.

Do **not** force irrelevant catalog dependencies. Build only where mathematically natural.

---

## Cross-Domain Connections You Must Explicitly Develop

At least one theorem and one discussion section must connect this work to another domain.

### 1. Number theory ↔ analytic summation / special values
The periodic mean-zero weighted sum theorem is the primary bridge. Explain that it models the convergence mechanism behind \(L(1,\chi)\), while γ arises as a renormalized residue/constant-term phenomenon near the pole of \(\zeta(s)\).

### 2. Number theory ↔ computational complexity / certification
Your `IrrationalityCertificate` is an algorithmic object: a finite witness schema that can be checked numerically and symbolically. This reframes irrationality research as **proof-certificate design**, not merely existential speculation.

### 3. Number theory ↔ statistical physics / renormalization
Explain in prose that \(H_n-\log n\) behaves like subtraction of a universal divergence, analogous to extracting finite parts in renormalization. This is not just metaphor: the constant survives after removing the divergent bulk term.

If you can support a formal lemma about subtracting logarithmic divergence from a harmonic-type observable, include it.

---

## Conjecture with Testable Prediction

You must state at least one falsifiable conjecture with a concrete computational disproof protocol.

### Conjecture A: Accelerated γ approximants exhibit no eventual bounded partial quotient regime
Let `gammaAccelerant n` be an explicitly defined rational approximant sequence to γ (for example from a binomial/harmonic transform, if you can construct one). Conjecture:

> The continued-fraction partial quotients of these approximants, viewed through the limiting real they target, are unbounded and exhibit infinitely many spikes exceeding \(c \log n\) for every fixed \(c < 1\).

This is falsifiable:
- compute the first \(N\) convergents / approximants,
- extract partial quotients,
- search for long bounded regimes contradicting the growth heuristic.

### Conjecture B: Periodic cancellation distinguishes \(L(1,\chi)\)-type constants from γ
For any nontrivial periodic mean-zero rational-valued \(f\), the sequence
\[
\sum_{k\le n}\frac{f(k)}{k}
\]
admits a limiting value whose rational approximants satisfy only quadratic-type approximation bounds, whereas the γ-sequence resists analogous periodic decomposition.

Computational test:
- generate many periodic mean-zero functions \(f\),
- numerically estimate convergence and approximation exponents,
- compare against harmonic-log approximants.

At least one conjecture must be included in both the Lean comments/documentation and the scientific writeup.

---

## Verified Algorithm / Computational Method

You must deliver a verified computational method, not just a theorem.

### Required algorithm
Implement an algorithm that:
1. computes `harmonicLogApprox n`,
2. computes certified upper/lower bounds on successive differences,
3. empirically searches for rational approximants \(A_n/B_n\) to γ from your chosen family,
4. tests whether observed errors are compatible with an irrationality certificate exponent \(p>2\),
5. optionally analyzes periodic mean-zero weighted sums.

This should be accompanied by theorem(s) proving correctness of at least one bound used by the algorithm.

Possible Lean-level definitions:
- recursive harmonic sum computation,
- certified monotonicity checker,
- denominator-growth estimator,
- periodic weighted sum evaluator with provable truncation control.

---

## Demo Requirements

Create `demo.py` that:
- plots \(H_n-\log n\),
- displays monotone convergence,
- compares raw and accelerated approximants,
- tests the conjectured approximation exponent numerically,
- explores periodic mean-zero examples related to Dirichlet characters,
- prints human-readable interpretations.

Make it interactive if possible:
- slider for \(n\),
- choose periodic function \(f\),
- toggle between approximation families.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean file(s)** with at least 3 substantial theorems using deep tactics such as:
   - induction,
   - `rcases`,
   - `by_contra`,
   - `field_simp`,
   - multi-step `calc`,
   - inequality chains,
   - asymptotic/filter reasoning.

2. **A new definition** not already present in the catalog:
   - preferably `IrrationalityCertificate`,
   - plus at least one explicit approximant family.

3. **A cross-domain theorem**:
   - ideally `periodic_mean_zero_log_weighted_bounded`.

4. **A falsifiable conjecture** with computational test protocol.

5. **A verified algorithm or computational method**.

6. **`demo.py`** demonstrating the result interactively.

7. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions.
   Each direction must include:
   - a sentence beginning exactly with **“The key insight is...”**
   - a sentence beginning exactly with **“Why now?”**
   At least one direction must bridge to a different domain.

8. **`RESEARCH_PAPER.md`** as a standalone scientific paper.
   It must explain:
   - the mathematical problem,
   - the new definitions,
   - the main theorems,
   - why this is a conceptual advance,
   - what future investigations are now unlocked.
   A reader with no access to code must still understand the discovery.

9. **`ARTICLE.md`** in Scientific American style.
   It must be engaging and accessible, focused on the mathematics and significance.
   **Do not focus on formal verification machinery.**

---

## Application Keywords

Euler–Mascheroni constant; irrationality measures; continued fractions; Diophantine approximation; harmonic sums; logarithmic asymptotics; Abel summation; Dirichlet series; \(L(1,\chi)\); renormalized constants; special values; arithmetic transforms; certified approximation; analytic number theory; computational experimentation; symbolic asymptotics; irrationality certificates; denominator growth; periodic mean-zero sequences; cross-domain arithmetic analysis.

---

## Final Charge

Do not submit a shallow “γ exists as a limit” note. Build a **research platform** around γ:
- explicit approximants,
- structural irrationality obstructions,
- arithmetic-summation bridges,
- and computational probes that could genuinely redirect the field.

If you cannot prove γ irrational, prove theorems that make future irrationality proofs *structurally inevitable*—theorems that say exactly what kind of approximation, recurrence, or arithmetic cancellation would be sufficient. That is how one opens a field.

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
