Soli Deo Gloria

## Assignment: Direction 1: Logarithmic Bound from O'Nan–Scott Classification

**Mode:** `prove`

You are to attack the conditional bottleneck in the wreath-product universality program and replace it with an **unconditional logarithmic theorem** derived from the subgroup geometry of product-action wreath products. This is not a bookkeeping exercise in subgroup enumeration: it is a structural theorem about how permutation-group complexity collapses into a controlled Dirichlet-type pressure law.

Build directly on:

- `Pythagorean/WreathPhaseTransition.lean`
  - especially the existing `noncoord_pressure_log_bound` framework and `NoncoordPressureLogarithmicConjecture`
- `Pythagorean/WreathPerturbation.lean`
  - especially perturbative comparison lemmas that convert subgroup-class counting plus index growth into pressure bounds

Your goal is to formalize and prove new theorems showing that the non-coordinate contribution for
\[
W_{k,m} := S_k \wr S_m
\]
in product action is logarithmically bounded in \(m\), for fixed \(k \ge 5\), by exploiting O'Nan–Scott / Kovács–Praeger type structure of maximal subgroups.

This would be a breakthrough because it would turn the current phase-transition mechanism from **conditional on subgroup-pressure hypotheses** into a **certified theorem with explicit asymptotics**. That, in turn, would produce the first rigorous generation-threshold estimator with quantified error bars for this family, and would open a new program: treating subgroup statistics of large permutation groups as an analytic-combinatorial “partition function.”

---

## Core theorem target

### Precise theorem statement

For each fixed \(k \ge 5\), there exist explicit constants \(A_k, B_k > 0\) such that for all \(m \ge 1\),
\[
P_{\mathrm{noncoord}}(W_{k,m}) \le A_k \log m + B_k.
\]
Here \(P_{\mathrm{noncoord}}(W_{k,m})\) is the reciprocal-index sum over non-coordinate maximal subgroup classes (or the corresponding pressure notion already defined in `WreathPhaseTransition.lean`).

The intended strengthening is:

1. **Typewise counting bound:** for each non-coordinate O'Nan–Scott type \(T\), the number of conjugacy classes of maximal subgroups of type \(T\) is bounded by \(C_{k,T} m^{d_{k,T}}\).
2. **Typewise index lower bound:** every such maximal subgroup \(M\) satisfies
   \[
   [W_{k,m} : M] \ge c_{k,T} m^{\alpha_{k,T}}
   \quad\text{with}\quad \alpha_{k,T} > 1.
   \]
3. **Summation theorem:** the resulting reciprocal-index contribution is \(O(\log m)\), and preferably \(O(1)\) for some types.

The conceptual point is that **classification + polynomial class count + superlinear index growth** implies logarithmic pressure. This is the exact bridge from finite permutation-group structure to analytic asymptotics.

---

## Lean 4 formal target

You should state the main theorem in a form as close as possible to the existing pressure definitions in the catalog. If the exact existing names differ, adapt consistently, but aim for a theorem of this shape:

```lean
theorem noncoord_pressure_logarithmic_of_ONanScott
    (k : ℕ) (hk : 5 ≤ k) :
    ∃ A B : ℝ, 0 < A ∧ 0 < B ∧
      ∀ m : ℕ, 1 ≤ m →
        noncoordPressure (wreathSymmetric k m) ≤ A * Real.log m + B
```

If the pressure object is `ℚ`, `ENNReal`, or another codomain in the catalog, use the native codomain and derive an `ℝ`-valued corollary if needed.

A stronger explicit-constant theorem is highly desirable:

```lean
theorem noncoord_pressure_logarithmic_explicit
    (k : ℕ) (hk : 5 ≤ k) :
    ∃ A B : ℚ,
      ∀ m : ℕ, 1 ≤ m →
        noncoordPressureQ (wreathSymmetric k m) ≤ A * (ratLog m) + B
```

where `ratLog` may need to be replaced by an upper-bounding arithmetic surrogate already available in the project.

---

## New definitions you should introduce

You must define at least one genuinely new structure or concept not already present in the catalog. Recommended definitions:

### 1. O'Nan–Scott type tag for non-coordinate maximal subgroups
A finite type encoding the product-action non-coordinate families relevant to \(S_k \wr S_m\):

```lean
inductive WreathMaxType
  | almostSimple
  | diagonal
  | productDecomposition
  | twistedWreath
  | topGroupInduced
  deriving DecidableEq, Fintype
```

If some cases collapse or are unnecessary for the exact formal development, refine accordingly. The point is to create a **typewise decomposition interface** for summing pressure contributions.

### 2. Typewise pressure contribution
```lean
def typePressureContribution
    (k m : ℕ) (T : WreathMaxType) : ℝ := ...
```

This should isolate the reciprocal-index sum over conjugacy classes of non-coordinate maximal subgroups of type `T`.

### 3. Polynomial-count / power-index certificate
A reusable analytic-combinatorial abstraction:

```lean
structure PressureCertificate where
  classBoundConst : ℝ
  classBoundDeg : ℕ
  indexBoundConst : ℝ
  indexBoundExp : ℝ
  indexExp_gt_one : 1 < indexBoundExp
  class_count_le : ∀ m ≥ 1, ...
  index_lower_bound : ∀ m ≥ 1, ...
```

This is strategically important: once you package “number of classes grows polynomially” and “indices grow with exponent \(>1\),” you can prove a general summation lemma and reuse it in future group families.

---

## Minimum theorem package

Your Lean development must contain **at least 3 substantial theorems** with real proof architecture, not trivial closure. A recommended package is:

### Theorem 1: General pressure from certificates
A meta-theorem converting class-count and index-growth data into a logarithmic bound.

```lean
theorem pressure_le_log_of_polynomial_class_count_and_power_index
    (C : PressureCertificate) :
    ∃ A B : ℝ, 0 < A ∧ 0 < B ∧
      ∀ m : ℕ, 1 ≤ m →
        certifiedPressure C m ≤ A * Real.log m + B
```

This theorem should use multi-step inequalities, monotonicity, and summation estimates. Even if the result is stronger than \(O(\log m)\), proving the logarithmic statement is enough.

### Theorem 2: Typewise non-coordinate certificate for one substantial family
For at least one genuinely nontrivial O'Nan–Scott family, prove a certificate theorem:

```lean
theorem productDecomposition_has_pressure_certificate
    (k : ℕ) (hk : 5 ≤ k) :
    ∃ C : PressureCertificate,
      certifiesType k WreathMaxType.productDecomposition C
```

This is where the real group theory enters: use projection to the top group, decomposition of the base group intersection, and index factorization.

### Theorem 3: Global logarithmic bound by summing types
```lean
theorem noncoord_pressure_log_bound_of_typewise_certificates
    (k : ℕ) (hk : 5 ≤ k) :
    ∃ A B : ℝ, 0 < A ∧ 0 < B ∧
      ∀ m : ℕ, 1 ≤ m →
        noncoordPressure (wreathSymmetric k m) ≤ A * Real.log m + B
```

This should combine a finite sum over `WreathMaxType`, using `Fintype` and typewise certificate theorems.

### Optional breakthrough theorem 4: Explicit constants for small \(k\)
For \(k = 5,6,7\), prove an explicit bound that is computationally checkable against GAP output:

```lean
theorem noncoord_pressure_log_bound_k5 :
  ∃ A B : ℚ, ∀ m : ℕ, 1 ≤ m →
    noncoordPressureQ (wreathSymmetric 5 m) ≤ A * ratLog m + B
```

---

## Suggested proof architecture

You must not rely on trivial decision procedures. Use real proof tactics: `induction`, `rcases`, `by_contra`, `field_simp`, structured `calc`, and case analysis on subgroup type.

### Strategy A: Certificate-first analytic architecture
**Most promising.**

1. **Abstract the summation mechanism.**
   Prove once and for all that if the number of conjugacy classes in a family is \(O(m^d)\) and each index is \(\Omega(m^\alpha)\) with \(\alpha > d\) or at least enough after dyadic grouping, then the reciprocal sum is \(O(\log m)\) or better.
2. **Package each O'Nan–Scott family into a certificate.**
   For each type \(T\), define a certificate containing:
   - a polynomial upper bound on class count,
   - a power-law lower bound on index.
3. **Sum over finitely many types.**
   Since the type set is finite, the total pressure is bounded by the sum of finitely many logarithmic contributions.

Why this is most promising: it isolates the hard group theory from the soft asymptotic analysis, making the final theorem modular and reusable. It also matches the architecture suggested by `WreathPerturbation.lean`.

### Strategy B: Direct maximal-subgroup pressure decomposition
1. Define the non-coordinate pressure directly as a finite sum over conjugacy classes of maximal subgroups.
2. Partition that sum by O'Nan–Scott type using a classification theorem.
3. For each summand, prove a direct bound using the index factorization
   \[
   [W_{k,m}:M] = [S_k^m : M \cap S_k^m]\,[S_m : \pi(M)].
   \]
4. Bound the number of possibilities for \(M \cap S_k^m\) and \(\pi(M)\) separately by combinatorial counting.

Why it may work: this is closer to the underlying mathematics and may yield sharper constants. Why it is less attractive: it risks entangling classification and asymptotics into one brittle proof.

### Strategy C: Dirichlet-series / Mellin-transform viewpoint
1. Define a subgroup zeta-type generating function
   \[
   \zeta^{\mathrm{noncoord}}_{k,m}(s) = \sum_{[M]} [W_{k,m}:M]^{-s}.
   \]
2. Prove convergence and bounds near \(s=1\) from typewise class-count and index-growth estimates.
3. Recover the pressure bound as the value or derivative at \(s=1\), or as a partial-summation corollary.

Why this is visionary: it reframes subgroup growth as analytic number theory. Even if you only partially formalize this perspective, include at least one theorem or definition pushing in this direction. This is the cross-domain bridge that could open an entirely new field of “subgroup thermodynamics.”

---

## Required group-theoretic ingredients

You should formalize as much of the following skeleton as is feasible in Lean, even if some classification results are encoded axiomatically first and then discharged for the concrete families you need.

1. **Projection/index factorization.**
   For a subgroup \(M \le W_{k,m}\) with projection \(\pi : W_{k,m} \to S_m\),
   \[
   [W_{k,m}:M] = [S_k^m : M \cap S_k^m]\,[S_m : \pi(M)].
   \]
   This is a critical theorem and should be formally proved if not already available.

2. **Non-coordinate implies nontrivial top/base obstruction.**
   Show that if \(M\) is maximal and non-coordinate, then either:
   - \(\pi(M)\) is a proper subgroup of \(S_m\) of controlled type, or
   - \(M \cap S_k^m\) is a proper structured subdirect subgroup imposing a large index penalty.

3. **Polynomial class counting.**
   The number of possible block systems / decomposition patterns / induced top-group structures is polynomially bounded in \(m\). This is where enumerative combinatorics enters.

4. **Superlinear index lower bounds.**
   Use orbit-size, partition-size, or subdirect-product rigidity arguments to prove lower bounds like
   \[
   [W_{k,m}:M] \ge m^\alpha.
   \]

These ingredients should not be treated as folklore. They are the mathematical heart of the project.

---

## Cross-domain connections you must explicitly develop

This project is strongest when framed as a synthesis of several areas. Include at least one theorem or definitional bridge in each of the following directions.

### 1. Enumerative combinatorics
Interpret conjugacy classes of non-coordinate maximal subgroups via combinatorial decomposition data: partitions, block systems, or colored set partitions. Prove at least one theorem translating a subgroup-count problem into a combinatorial counting problem.

Example target:
```lean
theorem num_product_decomposition_patterns_polynomial
    (d : ℕ) :
    ∃ C : ℝ, ∀ m ≥ 1,
      (numberOfDecompositionPatterns d m : ℝ) ≤ C * m^d
```

### 2. Analytic number theory
Treat the reciprocal-index sum as a Dirichlet-type series. Prove at least one theorem showing that a power-law lower bound on indices yields logarithmic or bounded growth of the cumulative pressure.

Application keywords: **Dirichlet series, subgroup zeta functions, Tauberian heuristics, harmonic sums**

### 3. Algorithm design / certified estimation
Extract a computable upper bound for non-coordinate pressure that can be used as a certified estimator in the phase-transition theorem.

Example:
```lean
def certifiedNoncoordUpperBound (k m : ℕ) : ℝ := ...

theorem noncoordPressure_le_certifiedUpperBound
    (k m : ℕ) :
    noncoordPressure (wreathSymmetric k m) ≤ certifiedNoncoordUpperBound k m
```

This is mandatory: produce not just existential asymptotics, but a verified computational method.

### 4. Statistical mechanics / physics language
At least in `RESEARCH_PAPER.md`, explain the pressure as a partition function over rare subgroup defects, where the index plays the role of energy. This is not decorative: it suggests future thermodynamic limit theorems.

Application keywords: **partition function, entropy-energy competition, phase transition, defect spectrum**

---

## Conjecture with computationally falsifiable prediction

You must state at least one explicit conjecture whose failure can be detected by computation.

### Recommended conjecture
For each fixed \(k \ge 5\), there exists a dominant non-coordinate type \(T_k\) and constants \(c_k, d_k > 0\) such that
\[
P_{\mathrm{noncoord}}(W_{k,m})
=
c_k \log m + d_k + o(1),
\]
and asymptotically almost all non-coordinate pressure comes from a single O'Nan–Scott family.

Formalize a Lean-level conjecture stub and provide a computational test in `demo.py` / GAP-backed scripts for \(k=5,6,7\), \(m \le 100\).

A simpler falsifiable prediction if asymptotics are too ambitious:
- for \(k=5,6,7\), the sequence
  \[
  \frac{P_{\mathrm{noncoord}}(W_{k,m})}{\log m}
  \]
  is eventually nonincreasing for \(m \ge m_0(k)\).

This is computationally checkable and mathematically meaningful.

---

## Concrete implementation tasks

### Lean file goals
Create or extend a file proving the global logarithmic theorem. The file should include:

1. A new type encoding non-coordinate maximal subgroup families.
2. A reusable certificate structure for pressure bounds.
3. At least one substantial theorem proving a typewise certificate.
4. A finite-sum theorem aggregating typewise bounds.
5. A final logarithmic bound theorem for `wreathSymmetric k m`.
6. A computable certified upper-bound function.

### Deep proof tactics requirement
At least 3 theorems must use genuinely nontrivial proof structure:
- `induction` on `m`, partition size, or finite type decomposition
- `rcases` on subgroup classification cases
- `by_contra` to force properness / nontriviality of projection or base intersection
- `field_simp` where index inequalities are converted into rational estimates
- multi-step `calc` chains for pressure inequalities

Avoid toy lemmas whose only content is definitional unfolding.

---

## How to use the catalog references

### From `Pythagorean/WreathPhaseTransition.lean`
Use the existing pressure definitions and any theorem that already expresses the universality threshold in terms of non-coordinate pressure. Your mission is to **discharge the remaining hypothesis** by proving the logarithmic estimate unconditionally.

### From `Pythagorean/WreathPerturbation.lean`
Exploit any perturbative lemma that says roughly:
- if an error term is bounded by a slowly growing function,
- then the threshold / universality statement survives with explicit quantitative control.

Your theorem should feed directly into this perturbative pipeline. Do not merely reprove an isolated asymptotic fact; integrate it into the phase-transition narrative.

---

## Why this is revolutionary

If you succeed, the result does more than settle a conjectural bound in one file.

It establishes a new paradigm:

- **Finite permutation-group classification becomes asymptotic analysis.**
- **Subgroup geometry becomes a thermodynamic observable.**
- **Generation thresholds become certifiable numerical invariants, not heuristic phenomena.**

This opens at least four research frontiers:

1. **Subgroup thermodynamics of finite groups:** define and analyze pressure, entropy, and free-energy analogues for subgroup spectra.
2. **Analytic subgroup zeta theory for permutation families:** connect O'Nan–Scott classification to Dirichlet-series asymptotics.
3. **Certified probabilistic generation:** turn structural group theory into rigorous threshold algorithms.
4. **Complexity of symmetry defects:** reinterpret maximal subgroups as rare defects in high-dimensional symmetry systems.

This is exactly the sort of theorem that makes a mathematician say: *I had never thought to use O'Nan–Scott classification as an engine for analytic pressure bounds.*

---

## Application keywords

**Permutation groups, O'Nan–Scott classification, Kovács–Praeger theory, wreath products, maximal subgroups, subgroup growth, subgroup zeta functions, Dirichlet sums, analytic combinatorics, probabilistic generation, phase transitions, certified estimation, statistical mechanics of symmetry, finite group thermodynamics**

---

## Mandatory deliverables

You must produce **all** of the following:

1. **`FUTURE_DIRECTIONS.md`**
   - 3–5 original research directions
   - each direction must include the exact sentences:
     - **“The key insight is...”**
     - **“Why now?”**
   - at least one direction must bridge to a different domain, such as analytic number theory, statistical physics, or algorithmic complexity

2. **`RESEARCH_PAPER.md`**
   - a standalone scientific paper
   - someone reading only this document must understand:
     - the theorem
     - the proof strategy
     - why it matters
     - what comes next
   - write it as a genuine paper, not notes

3. **`ARTICLE.md`**
   - Scientific American style
   - engaging, concept-driven, broad-audience explanation
   - taboo: do **not** focus on formal verification machinery
   - focus on the mathematics, its meaning, and why the result is surprising

4. **A verified algorithm or computational method**
   - not merely theorem statements
   - provide a function computing a certified upper bound on non-coordinate pressure
   - explain complexity and limitations

5. **`demo.py`**
   - interactive demonstration of the theorem
   - should compute / visualize the bound for \(k = 5,6,7\), \(m \le 100\)
   - compare empirical subgroup-pressure data (via GAP or precomputed tables if needed) against the certified logarithmic envelope

---

## Final charge

Do not aim for a decorative formalization of a conjecture. Aim to **collapse a classification theorem into an analytic law**. The real target is a theorem schema that says:

> finite symmetry defects, when organized by type and weighted by reciprocal index, obey a universal low-complexity pressure principle.

Prove that for wreath products first. Then make it impossible for anyone to ignore the idea.

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
