## Assignment: Direction 4: Low-Degree Testing over Finite Grids

**Mode:** prove

Prove a genuinely new theorem that turns the classical Schwartz–Zippel phenomenon into a formal **uniqueness-and-testability principle for functions on finite grids**. Do not settle for a vague “property testing” slogan. The target is a mathematically sharp theorem that says: if a function on a finite product set agrees with a bounded-total-degree polynomial on too large a subset, then that polynomial is uniquely determined; equivalently, two distinct low-degree polynomials cannot both explain too much of the same data. This is the formal nucleus from which local testability, self-correction, Reed–Muller decoding, and PCP-style low-degree tests all emerge.

The right first breakthrough is not yet the full randomized tester with probabilities and query complexity; it is the **combinatorial soundness theorem on finite grids** that makes such testers possible in Lean.

---

## Vision

You should formalize the principle that on a finite grid `S^n ⊆ K^n`, a function cannot correlate too strongly with two different low-degree multivariate polynomials once the degree is below the grid size. This is the exact finite-grid analogue of “codewords of Reed–Muller codes have large distance,” and it is the structural theorem behind low-degree testing.

This opens a new bridge between:

- **algebraic geometry over finite sets**,
- **coding theory** (Reed–Muller distance and decoding),
- **property testing / PCP theory**,
- **self-correction algorithms**,
- and eventually **formal complexity theory in Lean**.

The breakthrough is to turn Schwartz–Zippel from a one-shot root-counting lemma into a reusable **formal soundness engine** for local testing.

---

## Precise theorem target

Let `K` be a field, `S : Finset K` a finite set, and let `grid S n := (Fin n → K)` restricted to points with all coordinates in `S`. For a polynomial `p : MvPolynomial (Fin n) K`, define its evaluation on the grid by `x ↦ MvPolynomial.eval x p`.

The theorem you should aim for is:

### Theorem A: finite-grid uniqueness from large agreement
If `p` and `q` are multivariate polynomials of total degree at most `d`, and `d < S.card`, then if they agree on more than
`d * S.card^(n-1)` points of `S^n`, they are equal on all of `S^n`; in particular their grid-evaluation functions are identical.

This is the multivariate finite-grid version of the standard zero bound, and can be viewed as a Schwartz–Zippel contrapositive specialized to exact cardinality.

A Lean-oriented statement could look like:

```lean
theorem mvpoly_eq_on_grid_of_agree_many
    {K : Type*} [Field K]
    {n d : ℕ} (S : Finset K)
    (hS : d < S.card)
    {p q : MvPolynomial (Fin n) K}
    (hp : p.totalDegree ≤ d)
    (hq : q.totalDegree ≤ d)
    (hag :
      d * S.card ^ (n - 1) <
        (((Finset.univ : Finset (Fin n → K)).filter
          (fun x =>
            (∀ i, x i ∈ S) ∧
            MvPolynomial.eval x p = MvPolynomial.eval x q)).card)) :
    ∀ x : Fin n → K, (∀ i, x i ∈ S) → MvPolynomial.eval x p = MvPolynomial.eval x q
```

This statement may need adjustment depending on what Mathlib already provides for:
- `totalDegree`,
- finite counting over function spaces,
- filtering `Finset.univ`,
- and cardinality of the grid.

If the exact cardinality/filter formulation is cumbersome, define the grid as a dedicated finite type:
```lean
def Grid (S : Finset K) (n : ℕ) := {x : Fin n → K // ∀ i, x i ∈ S}
```
and prove the theorem over `Fintype.card (Grid S n)` and subsets of `Grid S n`.

---

## Stronger corollary target

### Theorem B: uniqueness of a low-degree explanation for a noisy function
For a function `f : (Fin n → K) → K` restricted to the grid `S^n`, if two degree-`≤ d` polynomials `p` and `q` each agree with `f` on more than `d * S.card^(n-1)` grid points, then `p` and `q` agree on all of `S^n`.

A clean Lean sketch:

```lean
theorem low_degree_explanation_unique
    {K : Type*} [Field K]
    {n d : ℕ} (S : Finset K)
    (hS : d < S.card)
    (f : (Fin n → K) → K)
    {p q : MvPolynomial (Fin n) K}
    (hp : p.totalDegree ≤ d)
    (hq : q.totalDegree ≤ d)
    (hp_agree :
      d * S.card ^ (n - 1) <
        (((Finset.univ : Finset (Fin n → K)).filter
          (fun x =>
            (∀ i, x i ∈ S) ∧
            MvPolynomial.eval x p = f x)).card))
    (hq_agree :
      d * S.card ^ (n - 1) <
        (((Finset.univ : Finset (Fin n → K)).filter
          (fun x =>
            (∀ i, x i ∈ S) ∧
            MvPolynomial.eval x q = f x)).card)) :
    ∀ x : Fin n → K, (∀ i, x i ∈ S) → MvPolynomial.eval x p = MvPolynomial.eval x q
```

This is the exact theorem that converts agreement with data into uniqueness of decoding. It is already a coding-theoretic statement: there is at most one codeword in a Hamming ball of that radius.

---

## Ambitious extension theorem

If the foundational theorem lands cleanly, push toward the true low-degree testing statement:

### Theorem C: distance lower bound for distinct low-degree polynomials
Distinct polynomials of total degree `≤ d < |S|` disagree on at least
`|S|^n - d|S|^(n-1)` grid points.

Equivalent Lean-style target:

```lean
theorem low_degree_code_distance
    {K : Type*} [Field K]
    {n d : ℕ} (S : Finset K)
    (hS : d < S.card)
    {p q : MvPolynomial (Fin n) K}
    (hp : p.totalDegree ≤ d)
    (hq : q.totalDegree ≤ d)
    (hpq : ¬ ∀ x : Fin n → K, (∀ i, x i ∈ S) → MvPolynomial.eval x p = MvPolynomial.eval x q) :
    |S.card ^ n - d * S.card ^ (n - 1)| ≤
      (((Finset.univ : Finset (Fin n → K)).filter
        (fun x =>
          (∀ i, x i ∈ S) ∧
          MvPolynomial.eval x p ≠ MvPolynomial.eval x q)).card)
```

You may wish to restate this without `|...|` once the arithmetic side is normalized.

This theorem is the Reed–Muller minimum-distance statement over arbitrary finite subsets of a field, in a form directly useful for local testability.

---

## Why this is a breakthrough

A formal proof of this theorem is not “just another Schwartz–Zippel corollary.” It establishes, inside Lean:

1. **A rigorous algebraic coding theory primitive**:
   low-degree polynomial evaluations on grids form an error-correcting code with explicit distance.

2. **A property testing primitive**:
   random agreement tests become sound because excessive agreement forces global equality.

3. **A self-correction primitive**:
   once uniqueness is proved, one can define the intended polynomial by interpolation/majority along lines.

4. **A PCP primitive**:
   the low-degree test is the backbone of algebraic PCPs, sum-check protocols, and hardness of approximation.

5. **A formal complexity-theory bridge**:
   this becomes one of the first reusable Lean lemmas linking multivariate algebra to local testability and coding distance.

This is the kind of theorem that makes later formalizations of Reed–Muller decoding, BLR-style tests, and algebraic PCP machinery actually feasible.

---

## Proof architecture: three viable strategies

### Strategy A: reduce to a zero-count theorem for `p - q`
This is the most direct and likely most promising route.

1. Define `r := p - q`.  
   Then `r.totalDegree ≤ d` by standard degree lemmas.

2. Show that agreement of `p` and `q` on grid points is exactly vanishing of `r` on the grid:
   ```lean
   MvPolynomial.eval x p = MvPolynomial.eval x q
   ↔ MvPolynomial.eval x (p - q) = 0
   ```

3. Prove or invoke a finite-grid root bound:
   a nonzero polynomial of total degree `≤ d < |S|` has at most `d * |S|^(n-1)` zeros on `S^n`.

4. Contrapose:
   if the zero set is larger than that, then `r` must vanish on all of `S^n`, hence `p` and `q` agree on all grid points.

Why this is promising:
- It isolates the entire difficulty into a single root-count theorem.
- Once the root-count theorem is formalized, Theorems A/B/C become nearly automatic corollaries.
- It aligns perfectly with classical Schwartz–Zippel logic.

### Strategy B: induction on the number of variables via polynomial slicing
This is probably the mathematically cleanest proof of the root-count theorem itself.

1. Fix one coordinate, say `x₀`, and rewrite `r` as a univariate polynomial in `x₀` whose coefficients are polynomials in the remaining variables.

2. For each assignment of the other `n-1` variables, obtain a univariate polynomial of degree at most `d`.

3. Count zeros fiberwise:
   - either the slice polynomial is identically zero,
   - or it has at most `d` zeros in `S`.

4. Control the number of “bad fibers” inductively using the nonzero coefficient of highest degree in `x₀`, which is itself a polynomial in `n-1` variables.

Why this is powerful:
- It yields the exact `d * |S|^(n-1)` bound.
- It is constructive and reusable.
- It naturally suggests a future formalization of interpolation and self-correction along lines.

This is the best route if Mathlib lacks the exact multivariate Schwartz–Zippel theorem you need.

### Strategy C: code-theoretic reinterpretation
This is more conceptual and may be ideal for corollaries after the root bound is proved.

1. Define the evaluation map from bounded-degree polynomials to functions on `Grid S n`.

2. Show injectivity under the condition `d < |S|` using the root-count theorem.

3. Derive Hamming distance bounds for the image code from zero-count bounds for differences.

4. Rephrase uniqueness of explanation as uniqueness of nearest codeword beyond half-distance.

Why this matters:
- It reframes the result as a theorem about formal error-correcting codes.
- It sets up later work on list decoding, local correction, and tester soundness.
- It creates a direct bridge to complexity theory.

Use this after Strategy A or B has established the algebraic heart.

---

## Most promising route

**Primary recommendation: Strategy B to prove the root-count theorem, then Strategy A to derive uniqueness/testability corollaries.**

Reason:
- If the exact finite-grid Schwartz–Zippel bound is absent from Mathlib, induction-on-variables is the theorem-producing engine.
- It is robust, classical, and gives exact constants.
- Once in place, the rest of the development becomes modular and elegant.

---

## Suggested formal decomposition into Lean lemmas

Build the theorem in layers.

### Layer 1: grid infrastructure
Define a finite type or finset for the grid:
```lean
def Grid (S : Finset K) (n : ℕ) := {x : Fin n → K // ∀ i, x i ∈ S}
```

Then prove:
- `Fintype (Grid S n)`
- `Fintype.card (Grid S n) = S.card ^ n`

This cardinality lemma is foundational.

### Layer 2: zero set of a polynomial on a grid
Define:
```lean
def gridZeros (S : Finset K) (p : MvPolynomial (Fin n) K) : Finset (Grid S n) := ...
```

Then target:
```lean
theorem card_gridZeros_le
    (hp : p.totalDegree ≤ d) (hpnz : p ≠ 0) (hS : d < S.card) :
    (gridZeros S p).card ≤ d * S.card ^ (n - 1)
```

This is the central theorem.

### Layer 3: agreement sets
Define:
```lean
def gridAgree (S : Finset K) (f g : (Fin n → K) → K) : Finset (Grid S n) := ...
```

Prove:
- agreement of evaluations of `p` and `q` equals zero set of `p - q`,
- cardinality of disagreement is grid size minus agreement size.

### Layer 4: uniqueness and distance
Derive:
- `mvpoly_eq_on_grid_of_agree_many`
- `low_degree_explanation_unique`
- `low_degree_code_distance`

This decomposition minimizes sorry by keeping each lemma sharply local.

---

## Building on catalog theorems

The catalog theorems provided are not directly about multivariate polynomials, but several encode a pattern you should exploit: **turning evaluation/cardinality control into structural uniqueness**.

Use them as stylistic and architectural precedents:

1. `cost_from_eval_bound`  
   This suggests a pattern: derive global structure from evaluation inequalities. Here, your analogue is: derive global polynomial equality from bounded disagreement on evaluations.

2. `realizer_card_lower_bound`  
   This is conceptually close to what you need: cardinality lower bounds certify existence/uniqueness phenomena. Your theorem will turn a cardinality threshold on agreement sets into uniqueness of the underlying polynomial.

3. `recoverSupport_card_bound`  
   The support-recovery perspective is useful. Think of the zero set or disagreement set as a combinatorial support object whose size controls identifiability.

4. `ternary_tree_card_bound` and `row_support_card_bound`  
   These are reminders that cardinal arithmetic lemmas matter. You will likely need a small library of monotonicity and positivity facts for powers and products to make the main algebraic proof flow in Lean.

Even if these are not directly imported, they indicate that **cardinality-based inference is a recognized pattern in the codebase**. Your theorem should fit this idiom.

---

## Cross-domain connections you should make explicit in the development

Do not hide the significance. State these connections in comments/docstrings and in the final writeup.

### 1. Coding theory
The evaluation map
`p ↦ (x ↦ eval x p on S^n)`
is a Reed–Muller-type code. Your theorem proves:
- injectivity for bounded degree,
- explicit minimum distance,
- uniqueness of decoding in a radius below half the distance.

### 2. Property testing
A low-degree tester samples points/lines/affine subspaces and checks consistency. Your theorem is the **soundness backbone**: too much agreement with a false polynomial is impossible.

### 3. PCPs and interactive proofs
Low-degree extensions and sum-check protocols rely on the fact that low-degree functions are rigid. This theorem formalizes that rigidity.

### 4. Learning theory
This is algebraic identifiability under sparse random observation. It connects to exact learning of polynomial classes and robust reconstruction from noisy labels.

### 5. Finite geometry
The theorem is about hypersurface incidence with Cartesian products. It can later be generalized to affine subspaces, Kakeya-style phenomena, and rank-based tests.

### 6. Cryptography
Reed–Muller codes, local correction, and low-degree tests underpin algebraic secret sharing, proof systems, and code-based primitives.

These are not rhetorical decorations. They define the follow-on program.

---

## Application keywords

Include these in comments / theorem docs / FUTURE_DIRECTIONS:

- Schwartz–Zippel
- finite-grid root bound
- Reed–Muller code
- minimum distance
- unique decoding
- low-degree testing
- local testability
- self-correction
- PCP
- sum-check
- algebraic coding theory
- formal complexity theory
- multivariate interpolation
- finite geometry
- error correction

---

## Concrete implementation notes for Lean 4 / Mathlib

- Inspect existing lemmas around:
  - `MvPolynomial.eval`
  - `MvPolynomial.totalDegree`
  - subtraction and degree bounds
  - `Polynomial.natDegree` / univariate root-count analogues
  - finite types of functions `Fin n → α`
  - cardinality of dependent/subtypes over `Finset`

- You may need a helper lemma converting a bounded-degree multivariate polynomial into a univariate polynomial by freezing all but one variable.

- If total degree is too awkward for induction, consider first proving a theorem with a stronger hypothesis like per-variable degree bound, if Mathlib support is better. But do not stop there: recover the total-degree corollary if possible.

- If equality of polynomials themselves is hard, equality of their evaluations on the grid is already a major theorem. The code-theoretic content only needs equality as functions on the grid.

- Keep the proof modular enough that a later line-based tester can reuse the slicing machinery.

---

## Deliverables

1. A Lean theorem formalizing the finite-grid low-degree uniqueness principle (`Theorem A` or a close equivalent).
2. At least one corollary formalizing uniqueness of low-degree explanation for a noisy function (`Theorem B`).
3. Preferably the distance theorem (`Theorem C`) if the infrastructure is already in place.
4. Minimal sorry usage, with any remaining sorry isolated to generic cardinality lemmas rather than the algebraic core.

---

## FUTURE_DIRECTIONS.md requirement

You must produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, not incremental variants. They should be specific enough to become the next cycle’s theorem targets. Include items of the following flavor:

1. **Affine-line low-degree test soundness**  
   Formalize the statement that if a function restricts to a degree-`≤ d` polynomial on a large fraction of random lines, then it is close to a global low-degree polynomial.

2. **Reed–Muller unique decoding radius**  
   Show that bounded corruption below half the minimum distance admits a unique codeword on the grid.

3. **Low-degree self-corrector**  
   Define a correction algorithm from noisy oracle access using random lines and prove correctness under an explicit error threshold.

4. **Sum-check protocol algebraic soundness**  
   Formalize the low-degree soundness step underlying sum-check over finite fields.

5. **List decoding / Sudan-style extension**  
   Push beyond unique decoding: prove a finite bound on the number of degree-`≤ d` polynomials with large agreement with a function.

These next steps would move the project from algebraic rigidity to fully formalized PCP/coding-theory machinery.

---

## Call to arms

Do not treat this as a minor formalization exercise. The target is to carve out a new formal interface between multivariate algebra and theoretical computer science. A proved finite-grid uniqueness theorem for low-degree polynomials is the seed crystal for formal Reed–Muller theory, local testing, and algebraic proof systems in Lean. Build the root-count engine carefully, derive the uniqueness corollaries cleanly, and make the result reusable enough that future work can climb directly from Schwartz–Zippel to PCP soundness.

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
