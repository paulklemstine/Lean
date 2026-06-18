## Mode: prove

## Assignment: Freivalds as a Corollary of Schwartz–Zippel over Finite Fields

Aristotle, this is not merely a counting lemma about kernels of matrices. This is the formal birth of a bridge between randomized linear algebra and polynomial identity testing inside Lean. The theorem below should be proved in a way that makes the conceptual statement unavoidable:

> **Freivalds’ one-sided error phenomenon is the degree-1 case of Schwartz–Zippel.**

That shift matters. Once formalized, matrix verification, linear-code soundness, low-degree testing, and algebraic complexity begin to live in one certified framework rather than as isolated tricks.

### Target theorem
```lean
theorem freivalds_from_schwartz_zippel
    {q m p : ℕ} [Fact q.Prime]
    (M : Matrix (Fin m) (Fin p) (ZMod q))
    (hM : M ≠ 0) :
    Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0}
      ≤ q ^ (p - 1)
```

### Stronger theorem you should actually aim to prove first
The displayed theorem is the visible tip. The breakthrough is the row-functional version, from which the matrix statement is immediate.

```lean
theorem card_solutions_linear_form_le
    {q p : ℕ} [Fact q.Prime]
    (w : Fin p → ZMod q)
    (hw : w ≠ 0) :
    Fintype.card {r : Fin p → ZMod q // ∑ j, w j * r j = 0}
      ≤ q ^ (p - 1)
```

Then derive:

```lean
theorem freivalds_from_schwartz_zippel
    {q m p : ℕ} [Fact q.Prime]
    (M : Matrix (Fin m) (Fin p) (ZMod q))
    (hM : M ≠ 0) :
    Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0}
      ≤ q ^ (p - 1)
```

by extracting a nonzero row `w = M i`, observing
`{r | M.mulVec r = 0} ⊆ {r | ∑ j, w j * r j = 0}`, and applying the stronger theorem.

---

## Precise mathematical theorem statement

Let `F = ZMod q` with `q` prime, so `F` is a finite field of cardinality `q`. For any nonzero linear polynomial
\[
P(X_1,\dots,X_p)=\sum_{j=1}^p w_j X_j \in F[X_1,\dots,X_p]
\]
with coefficient vector `w ≠ 0`, the Schwartz–Zippel lemma at degree `1` implies
\[
|\{a \in F^p : P(a)=0\}| \le 1 \cdot q^{p-1} = q^{p-1}.
\]
If `M ≠ 0`, some row `w` is nonzero, and every vector in `ker(M)` is a zero of the corresponding nonzero linear polynomial, hence
\[
|\ker(M)| \le q^{p-1}.
\]

This is stronger than the usual “random vector catches an error with probability at least `1 - 1/q`” phrasing: it reclassifies the argument as a finite-field zero-set bound for a degree-1 polynomial.

---

## Lean 4 formalization target

You should structure the development around an explicit polynomial and an evaluation lemma.

### Suggested auxiliary definitions
```lean
def linearRowPoly
    {q p : ℕ} [Fact q.Prime]
    (w : Fin p → ZMod q) :
    MvPolynomial (Fin p) (ZMod q) :=
  ∑ j, MvPolynomial.C (w j) * MvPolynomial.X j
```

```lean
theorem eval₂_linearRowPoly
    {q p : ℕ} [Fact q.Prime]
    (w r : Fin p → ZMod q) :
    MvPolynomial.eval r (linearRowPoly w) = ∑ j, w j * r j
```

```lean
theorem totalDegree_linearRowPoly_le_one
    {q p : ℕ} [Fact q.Prime]
    (w : Fin p → ZMod q) :
    (linearRowPoly w).totalDegree ≤ 1
```

```lean
theorem linearRowPoly_ne_zero
    {q p : ℕ} [Fact q.Prime]
    (w : Fin p → ZMod q)
    (hw : w ≠ 0) :
    linearRowPoly w ≠ 0
```

Then package the Schwartz–Zippel step as:

```lean
theorem card_zeros_linearRowPoly_le
    {q p : ℕ} [Fact q.Prime]
    (w : Fin p → ZMod q)
    (hw : w ≠ 0) :
    Fintype.card {r : Fin p → ZMod q // MvPolynomial.eval r (linearRowPoly w) = 0}
      ≤ q ^ (p - 1)
```

and finally identify this set with the solution set to the linear equation.

---

## 2–3 proof strategy paths

### Strategy A: Direct Schwartz–Zippel instantiation on `MvPolynomial`
This is the conceptually correct route and the one most worth formalizing.

1. **Build the polynomial**  
   Define `linearRowPoly w = ∑ j, C (w j) * X j`. Prove evaluation computes the row-dot-product:
   ```lean
   MvPolynomial.eval r (linearRowPoly w) = ∑ j, w j * r j
   ```
   This is a straightforward induction over the finite sum using `eval₂_at`/`eval_C`/`eval_X`.

2. **Show nontriviality and degree bound**  
   Use `w ≠ 0` to choose `j` with `w j ≠ 0`; then the coefficient of monomial `X j` is nonzero, so the polynomial is nonzero. Prove `totalDegree ≤ 1`; indeed every summand is either `0` or a scalar multiple of one variable.

3. **Apply finite-field Schwartz–Zippel**  
   Invoke the existing or newly formalized finite-field zero-count theorem for nonzero multivariate polynomials:
   \[
   |\{x \in F^p : P(x)=0\}| \le \deg(P)\,|F|^{p-1}.
   \]
   Since `deg(P) ≤ 1`, obtain `≤ q^(p-1)`. Rewrite the zero set via the evaluation lemma.

**Why this is most promising:** it realizes the exact research vision: Freivalds becomes a corollary of polynomial identity testing, not merely a linear algebra fact with a cosmetic polynomial wrapper.

---

### Strategy B: Prove the linear-form count directly, then retrofit the Schwartz–Zippel interpretation
This is a robust fallback if the exact Schwartz–Zippel theorem is not yet in the catalog.

1. **Choose a pivot coordinate**  
   From `w ≠ 0`, choose `j₀` with `w j₀ ≠ 0`.

2. **Solve uniquely for one variable**  
   For each assignment of the other `p-1` coordinates, the equation
   \[
   \sum_j w_j r_j = 0
   \]
   determines `r j₀` uniquely because `w j₀` is invertible in the field `ZMod q`.

3. **Count by explicit equivalence**  
   Construct a bijection between the solution set and functions on `Fin p \ {j₀}`. This gives exactly `q^(p-1)` solutions, hence the desired inequality.

Then add a theorem or remark identifying this direct proof as the degree-1 Schwartz–Zippel instance.

**Why this is valuable:** it provides a no-frills, likely easier formal core and can serve as the base case validating the general Schwartz–Zippel formalization.

---

### Strategy C: Codimension-1 subspace argument plus polynomial certification
This is the linear algebra / algebraic geometry hybrid route.

1. Show the solution set of a nonzero linear form is a proper subspace of `(Fin p → ZMod q)`.
2. Prove any proper codimension-1 subspace of `F^p` has cardinality `q^(p-1)`.
3. Use the polynomial `linearRowPoly w` to certify that the subspace is the vanishing locus of a degree-1 polynomial, explicitly connecting subspace geometry to zero sets.

**Why this is interesting:** it prepares a future generalization from hyperplanes to intersections of low-degree hypersurfaces, i.e. from rank arguments to algebraic complexity bounds.

---

## Recommended proof architecture

You should aim for the following theorem dependency chain:

1. `linearRowPoly`
2. `eval₂_linearRowPoly`
3. `linearRowPoly_ne_zero`
4. `totalDegree_linearRowPoly_le_one`
5. finite-field Schwartz–Zippel zero-count theorem specialized to `ZMod q`
6. `card_solutions_linear_form_le`
7. existence of a nonzero row of a nonzero matrix
8. subset relation from `M.mulVec r = 0` to vanishing of one row functional
9. `freivalds_from_schwartz_zippel`

This architecture is reusable. It sets up later work on:
- bilinear tests,
- low-degree code soundness,
- circuit identity testing,
- rank-vs-degree phenomena.

---

## Key Lean obstacles to solve cleanly

### 1. Extracting a nonzero row from `M ≠ 0`
You will likely need:
```lean
have : ∃ i, M i ≠ 0 := ...
```
using extensionality contraposition:
if every row were zero, then every entry is zero, hence `M = 0`.

### 2. Translating `M.mulVec r = 0` into a scalar equation on one row
For chosen `i`,
```lean
have hrow : ∀ r, M.mulVec r = 0 → ∑ j, M i j * r j = 0 := ...
```
by evaluating the `i`th coordinate of `M.mulVec r`.

### 3. Nonzero polynomial from nonzero coefficient vector
Show some monomial coefficient is nonzero. The monomial to isolate is the finitely-supported exponent corresponding to variable `j₀` with exponent `1`.

### 4. Cardinality of `ZMod q`
You will need the field/cardinality bridge:
```lean
Fintype.card (ZMod q) = q
```
under primality assumptions.

### 5. The exponent `p - 1`
If you go through an exact bijection with `Fin (p-1)`-style indexing, subtraction on naturals can become annoying. The Schwartz–Zippel statement naturally produces `q^(p-1)` without index surgery, which is another reason Strategy A is superior.

---

## Cross-domain connections you should make explicit in the file/docstring

This theorem is a formal bridge among at least four domains:

1. **Randomized algorithms / Freivalds**  
   The classic matrix product verification guarantee becomes a zero-set bound.

2. **Polynomial identity testing (PIT)**  
   Freivalds is not an isolated linear trick; it is a special case of black-box PIT over finite fields.

3. **Coding theory**  
   A nonzero row defines a parity-check equation; the theorem bounds the fraction of words satisfying a nontrivial parity check. This is the one-check shadow of Reed–Muller / low-degree testing.

4. **Algebraic complexity**  
   This is the finite-field degree-vs-error mechanism underlying soundness of algebraic protocols. It conceptually aligns with catalog results such as:
   - `depth_lower_bound_from_degree`
   - `mulGates_lower_bound_from_degree`

Those theorems already encode the philosophical principle that **degree controls complexity**. Your theorem adds the complementary principle that **degree controls vanishing probability**. Together, they point toward a formal complexity/soundness synthesis.

---

## How to leverage existing catalog theorems

The currently listed catalog theorems are not directly about finite-field zero counting, but two of them suggest the right conceptual extension:

- `depth_lower_bound_from_degree`
- `mulGates_lower_bound_from_degree`

Use them in the narrative and in `FUTURE_DIRECTIONS.md`, not as direct proof ingredients. The important connection is:

> If low degree constrains circuit depth and multiplication gates, and low degree also constrains zero density by Schwartz–Zippel, then low degree simultaneously governs **computational complexity** and **probabilistic soundness**.

That is a field-opening axis. It suggests formalizing PIT lower bounds, soundness amplification, and algebraic proof systems in Lean.

---

## Revolutionary significance

If you formalize this correctly, you do more than prove a bound on a matrix kernel. You establish a reusable theorem schema:

> **Algorithmic error bounds can be certified by algebraic geometry over finite fields.**

That opens the door to:
- formalized randomized verification,
- certified PIT reductions,
- finite-field soundness lemmas for interactive proofs,
- algebraic coding arguments,
- complexity-theoretic lower bounds expressed via degree.

This is the kind of theorem that changes what Lean users think is “naturally formalizable”: not just static algebra, but the conceptual infrastructure of randomized algorithms.

---

## Deliverables

1. Prove the stronger row-functional theorem.
2. Derive `freivalds_from_schwartz_zippel`.
3. Minimize sorry aggressively; if a general Schwartz–Zippel theorem is missing, prove the degree-1 specialization cleanly and state the general theorem as a future target.
4. Add a short module-level comment explaining why this is a PIT interpretation of Freivalds.
5. Produce `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**.

---

## Required FUTURE_DIRECTIONS.md items

Include 3–5 of the following, but make them precise and theorem-oriented:

1. **General Schwartz–Zippel over finite fields in Mathlib style**  
   Formalize:
   ```lean
   theorem card_zeros_le_totalDegree_mul
       {F : Type*} [Field F] [Fintype F]
       (P : MvPolynomial σ F) (hP : P ≠ 0) :
       Fintype.card {x : σ → F // MvPolynomial.eval x P = 0}
         ≤ P.totalDegree * (Fintype.card F) ^ (Fintype.card σ - 1)
   ```
   for finite `σ`, with appropriate degree conventions.

2. **Freivalds for matrix product verification via PIT**  
   Formalize the standard randomized algorithm: if `A * B ≠ C`, then for uniform `r`,
   \[
   \Pr[(A*B)r = Cr] \le 1/q.
   \]
   Prove this by reducing to the row-functional theorem.

3. **Affine and higher-degree variants**  
   Generalize from homogeneous linear forms to affine forms and then to degree-`d` hypersurfaces, obtaining explicit finite-field soundness bounds.

4. **Coding-theoretic reinterpretation**  
   Formalize that a nonzero parity-check equation accepts exactly a `1/q` fraction of words over `ZMod q`, and connect this to dual codes and low-degree tests.

5. **Complexity/soundness bridge**  
   Combine zero-density bounds with `depth_lower_bound_from_degree` and `mulGates_lower_bound_from_degree` to formulate a certified statement that low-degree algebraic circuits simultaneously have structural limitations and predictable PIT behavior.

---

## Application keywords
Freivalds algorithm, Schwartz–Zippel lemma, polynomial identity testing, finite fields, multivariate polynomials, zero-counting, randomized verification, algebraic complexity, coding theory, parity-check equations, Reed–Muller perspective, soundness bounds, formalized mathematics, Lean 4, Mathlib

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

Research domain: Algebra
Research mode: prove
