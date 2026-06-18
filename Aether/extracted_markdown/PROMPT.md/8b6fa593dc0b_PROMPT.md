## Assignment: prove

### Title
Freivalds as the Degree-1 Shadow of Schwartz–Zippel over Finite Fields

Prove a genuinely structural theorem: the randomized verification of matrix multiplication is not an isolated algorithmic trick, but the first nontrivial case of polynomial identity testing over finite fields. The target is to formalize Schwartz–Zippel in a way that immediately yields Freivalds’ error bound as a corollary, thereby opening a reusable Lean bridge between algebraic complexity, randomized algorithms, and formal verification.

This is not merely “formalize a standard lemma.” The breakthrough is to turn a folklore implication into a certified Mathlib-level pipeline:

- multivariate polynomial zero counting over `ZMod q`,
- linear-algebraic discrepancy encoded as a degree-1 polynomial map,
- randomized matrix product verification as PIT,
- future extraction toward algebraic circuit lower bounds and certified randomized computation.

### Exact theorem targets

You should aim for a theorem stack, not a single isolated result.

#### 1. Core Schwartz–Zippel over a finite field
A more robust Lean target than the raw statement given is to separate the finite-field cardinality from the prime modulus and to state the theorem over any finite integral domain / field first if convenient, then specialize to `ZMod q`.

A likely primary target:

```lean
theorem schwartz_zippel_finset_bound
    {K : Type*} [Field K] [Fintype K]
    {n : ℕ}
    (f : MvPolynomial (Fin n) K)
    (hf : f ≠ 0) :
    Fintype.card {x : Fin n → K // MvPolynomial.eval x f = 0}
      ≤ f.totalDegree * (Fintype.card K) ^ (n - 1)
```

Then specialize:

```lean
theorem schwartz_zippel_zmod
    {q : ℕ} [Fact q.Prime] {n : ℕ}
    (f : MvPolynomial (Fin n) (ZMod q))
    (hf : f ≠ 0) :
    Fintype.card {x : Fin n → ZMod q // MvPolynomial.eval x f = 0}
      ≤ f.totalDegree * q ^ (n - 1)
```

If `n = 0` causes edge-case friction because of `n - 1`, split into:
- `n = 0` trivial case,
- `n + 1` induction theorem with exponent `n`.

That may be cleaner:

```lean
theorem schwartz_zippel_succ
    {K : Type*} [Field K] [Fintype K]
    {n : ℕ}
    (f : MvPolynomial (Fin (n+1)) K)
    (hf : f ≠ 0) :
    Fintype.card {x : Fin (n+1) → K // MvPolynomial.eval x f = 0}
      ≤ f.totalDegree * (Fintype.card K) ^ n
```

This successor formulation is probably the best formal statement.

#### 2. Degree-1 specialization
Extract the linear case explicitly. This is the theorem that turns Schwartz–Zippel into an algorithmic principle.

```lean
theorem linear_schwartz_zippel
    {K : Type*} [Field K] [Fintype K]
    {n : ℕ}
    (f : MvPolynomial (Fin n) K)
    (hf : f ≠ 0)
    (hdeg : f.totalDegree ≤ 1) :
    Fintype.card {x : Fin n → K // MvPolynomial.eval x f = 0}
      ≤ (Fintype.card K) ^ (n - 1)
```

Or in probabilistic form:

```lean
theorem linear_zero_probability_le
    {K : Type*} [Field K] [Fintype K]
    {n : ℕ}
    (f : MvPolynomial (Fin n) K)
    (hf : f ≠ 0)
    (hdeg : f.totalDegree ≤ 1) :
    (Fintype.card {x : Fin n → K // MvPolynomial.eval x f = 0} : ℚ)
      / (Fintype.card (Fin n → K) : ℚ)
      ≤ 1 / Fintype.card K
```

The counting statement is enough; the probability statement is the conceptual crown.

#### 3. Freivalds as corollary
For matrices over `ZMod q`, define the discrepancy matrix
`D = A * B - C`. If `D ≠ 0`, then `D.mulVec r = 0` occurs with probability at most `1/q`.

A precise theorem target:

```lean
theorem freivalds_zmod_bound
    {q n : ℕ} [Fact q.Prime]
    (A B C : Matrix (Fin n) (Fin n) (ZMod q))
    (hneq : A ⬝ B ≠ C) :
    Fintype.card {r : Fin n → ZMod q // (A ⬝ B).mulVec r = C.mulVec r}
      ≤ q ^ (n - 1)
```

Equivalent discrepancy form:

```lean
theorem freivalds_zmod_bound'
    {q n : ℕ} [Fact q.Prime]
    (D : Matrix (Fin n) (Fin n) (ZMod q))
    (hD : D ≠ 0) :
    Fintype.card {r : Fin n → ZMod q // D.mulVec r = 0}
      ≤ q ^ (n - 1)
```

This discrepancy form is cleaner and should be proved first. Then derive Freivalds by setting `D = A ⬝ B - C`.

You should also isolate the nonzero linear form lemma that powers the matrix statement:

```lean
theorem nonzero_linear_form_zero_set_bound
    {K : Type*} [Field K] [Fintype K]
    {n : ℕ}
    (v : Fin n → K)
    (hv : v ≠ 0) :
    Fintype.card {x : Fin n → K // ∑ i, v i * x i = 0}
      ≤ (Fintype.card K) ^ (n - 1)
```

Then prove matrix Freivalds by extracting one nonzero row of `D`.

### Why this is a breakthrough

If formalized correctly, this creates a new certified corridor in Lean:

**polynomial method → randomized verification → circuit complexity**.

That corridor is mathematically deep and strategically powerful. Schwartz–Zippel is the gateway theorem behind polynomial identity testing, derandomization, algebraic circuit lower bounds, coding theory, interactive proofs, and verification of numerical/algebraic computation. Formalizing it in a reusable way means future work can mechanize:
- PIT for algebraic circuits,
- soundness bounds for randomized protocols,
- coding-theoretic distance arguments,
- finite-field incidence geometry,
- derandomization hypotheses formalized against complexity classes.

Freivalds then becomes the first concrete algorithmic manifestation of this theory in Lean. The philosophical payoff is large: one certifies that a randomized algorithm’s soundness is really an algebraic geometry statement about hypersurfaces over finite fields.

### Build explicitly on catalog theorems

Use the verified theorem:

- `univariate_root_bound`
  from `Algebra/CircuitComplexity/NullstellensatzPIT.lean`

This should be the engine for the base case and for the “freeze all but one variable” step in the induction. Do not merely cite it; make it the exact one-variable fiber bound after partial evaluation. The induction should reduce each fiber to a univariate polynomial in the distinguished variable, then apply `univariate_root_bound` to each nonzero fiber polynomial.

You should also keep in mind:
- `bounded_circuit_degree_bound`
- `mulGates_lower_bound_from_degree`

These are not needed for the main proof, but they indicate the larger destination: once Schwartz–Zippel is in place, one can connect semantic nonzeroness probabilities of algebraic circuits to syntactic degree/complexity constraints. That is exactly the kind of cross-domain bridge this project should enable.

### Proof architecture: three viable strategies

#### Strategy A: Classical induction on number of variables via polynomial fibers
This is the most canonical and likely the best Lean path.

1. Choose the last variable `X_n`.
2. Rewrite `f` as a univariate polynomial in `X_n` whose coefficients are multivariate polynomials in the remaining variables.
3. For each assignment `a : Fin n → K` to the first `n` variables, obtain a univariate specialization `g_a`.
4. Split assignments `a` into:
   - those where `g_a = 0`,
   - those where `g_a ≠ 0`.
5. For `g_a ≠ 0`, apply `univariate_root_bound`.
6. For `g_a = 0`, show these `a` lie in the zero set of the leading coefficient (or some nonzero coefficient) of `f`, whose total degree is strictly smaller; then invoke the induction hypothesis.

Why this is promising:
- It follows the textbook proof exactly.
- It uses `univariate_root_bound` in the intended way.
- It scales to future PIT theorems.

Main technical burden:
- expressing partial evaluation and coefficient extraction in `MvPolynomial`,
- relating the degree of specialized fibers and coefficient polynomials to `f.totalDegree`.

#### Strategy B: Hyperplane-counting first, then deduce degree-1 and bootstrap to full Schwartz–Zippel
This is strategically elegant if the full induction becomes too painful initially.

1. Prove `nonzero_linear_form_zero_set_bound`.
2. Derive `freivalds_zmod_bound'` immediately.
3. Then attack full Schwartz–Zippel separately, possibly using a more bespoke induction framework developed from the linear case.

Why this is promising:
- It gets a substantial theorem quickly.
- It gives an immediate algorithmic deliverable even if the full multivariate machinery is delicate.
- It isolates the key conceptual statement behind Freivalds.

Limitation:
- It does not by itself prove general Schwartz–Zippel, so it is less revolutionary unless completed.

#### Strategy C: Finite-function counting via decomposition into graphs of roots
This is a combinatorial recasting of Strategy A.

1. View the zero set of `f` as a union over assignments to the first `n` variables of root sets of a univariate fiber.
2. Sum the cardinalities of fibers using `Fintype.card` over sigma/subtype decompositions.
3. Bound the number of “bad” base assignments producing identically zero fibers by induction on a coefficient polynomial.

Why this is promising:
- It may align better with Lean’s finite-type cardinal arithmetic than direct probabilistic language.
- It makes the final cardinality theorem natural and avoids measure/probability formalization overhead.

Most promising overall:
**Strategy A**, implemented in the counting style of **Strategy C**.

### Key technical sublemmas to isolate early

You should not attempt the whole theorem monolithically. First carve out these reusable lemmas.

1. **Partial evaluation preserves polynomial structure**
   A function specializing all but one variable to obtain a univariate polynomial:
   ```lean
   def fiberPoly
       {K : Type*} [CommSemiring K] {n : ℕ}
       (f : MvPolynomial (Fin (n+1)) K)
       (a : Fin n → K) :
       Polynomial K := ...
   ```

2. **Fiber evaluation identity**
   ```lean
   theorem eval_fiberPoly
       {K : Type*} [CommSemiring K] {n : ℕ}
       (f : MvPolynomial (Fin (n+1)) K)
       (a : Fin n → K) (t : K) :
       Polynomial.eval t (fiberPoly f a)
         = MvPolynomial.eval (extendFin a t) f
   ```

3. **Degree bound on fibers**
   ```lean
   theorem natDegree_fiberPoly_le_totalDegree
       {K : Type*} [Field K] {n : ℕ}
       (f : MvPolynomial (Fin (n+1)) K)
       (a : Fin n → K) :
       (fiberPoly f a).natDegree ≤ f.totalDegree
   ```

4. **Nontrivial coefficient polynomial exists**
   If `f ≠ 0`, choose a coefficient in the distinguished variable that is a nonzero polynomial in the remaining variables.

5. **Coefficient degree drops**
   The selected coefficient polynomial has total degree at most `f.totalDegree - k`, hence strictly smaller when `k > 0`.

6. **Nonzero matrix gives nonzero row**
   ```lean
   theorem exists_nonzero_row_of_ne_zero
       {K : Type*} [Semiring K] [Nontrivial K] {n : ℕ}
       {D : Matrix (Fin n) (Fin n) K}
       (hD : D ≠ 0) :
       ∃ i, D i ≠ 0
   ```

7. **A nonzero row defines a nonzero linear form**
   ```lean
   theorem row_mulVec_eq_dotProduct
       {K : Type*} [Semiring K] {n : ℕ}
       (D : Matrix (Fin n) (Fin n) K) (i : Fin n) (r : Fin n → K) :
       (D.mulVec r) i = ∑ j, D i j * r j
   ```

These lemmas are not administrative details; they are the reusable interface that future formalizations of PIT, Reed–Solomon bounds, and low-degree testing will rely on.

### Cross-domain connections you should exploit explicitly

#### 1. Algebraic complexity
Schwartz–Zippel is the semantic heart of polynomial identity testing. Once formalized, it can combine with:
- `bounded_circuit_degree_bound`
- `mulGates_lower_bound_from_degree`

to produce future theorems of the form:
“a bounded-depth algebraic circuit computing a nonzero polynomial cannot vanish on too large a fraction of inputs.”

That is the first step toward certified lower-bound heuristics in algebraic complexity.

#### 2. Randomized algorithms and proof verification
Freivalds is one of the canonical examples in randomized verification. Formalizing it as a corollary of Schwartz–Zippel reframes randomized algorithm correctness as an algebraic counting theorem. This suggests future formalizations of:
- fingerprinting,
- polynomial hashing,
- streaming verification,
- interactive proof soundness over finite fields.

#### 3. Coding theory
The same counting principle underlies the distance of Reed–Muller codes: a nonzero low-degree polynomial cannot vanish on too many points. Your theorem is therefore the seed for formalized coding-theoretic distance bounds.

#### 4. Finite geometry
Zero sets of low-degree polynomials over finite fields are hypersurfaces with bounded point counts. Even the elementary Schwartz–Zippel bound is a first finite-geometric incidence theorem in Lean.

#### 5. Derandomization and complexity theory
The formal slogan is:
**“Freivalds is PIT for linear circuits.”**
This is the first rung on the ladder from randomized algorithms to derandomization. A future formal development could connect hitting sets, identity testing, and complexity separations.

### Suggested Lean design choices

- Prefer a theorem over arbitrary finite fields first, then specialize to `ZMod q`.
- Avoid probability theory initially; prove cardinality bounds, then derive probability bounds by finite counting.
- If `MvPolynomial.totalDegree` is awkward, consider proving an intermediate theorem using `f.degrees.card` or a variable-wise degree bound, then derive the total-degree version.
- Consider implementing the induction on `Fin (n+1)` rather than arbitrary finite index types to keep variable bookkeeping manageable.
- Keep the discrepancy form of Freivalds (`D.mulVec r = 0`) separate from the matrix product statement; this will be far easier to reuse.

### Concrete theorem dependency graph

A highly plausible order:

1. `nonzero_linear_form_zero_set_bound`
2. `freivalds_zmod_bound'`
3. `freivalds_zmod_bound`
4. fiber construction lemmas for `MvPolynomial`
5. `schwartz_zippel_succ`
6. `schwartz_zippel_zmod`
7. `linear_schwartz_zippel` as a clean corollary of the general theorem

This order ensures an early theorem of independent significance while building toward the flagship result.

### What would make this field-opening

Do not stop at “the theorem compiles.” Package the result so that it becomes the base layer for a future formal theory of PIT. In particular, if possible, place the result in a file path such as:

- `Algebra/CircuitComplexity/SchwartzZippel.lean`
- or `Algebra/CircuitComplexity/Freivalds.lean`

with imports and lemmas chosen for downstream use in algebraic circuits.

The true prize is not just Schwartz–Zippel; it is a reusable formal algebraic-complexity toolkit that lets Lean speak about randomized algebraic verification with theorem-level precision.

### Application keywords
Schwartz–Zippel, Freivalds algorithm, polynomial identity testing, algebraic complexity, finite fields, randomized verification, derandomization, Reed–Muller codes, low-degree testing, matrix multiplication verification, formalized complexity theory, hypersurface point counting

### Deliverables
1. Formalized Lean theorem(s) for Schwartz–Zippel and Freivalds over `ZMod q`.
2. Supporting lemmas for partial evaluation and degree control.
3. Minimal `sorry` footprint, with any remaining gaps isolated into sharply stated helper lemmas.
4. A structured `FUTURE_DIRECTIONS.md` containing 3–5 concrete next steps at breakthrough scale, for example:
   - Reed–Muller minimum distance from Schwartz–Zippel,
   - PIT soundness for algebraic circuits using `bounded_circuit_degree_bound`,
   - polynomial fingerprinting theorems for string equality / streaming,
   - low-degree testing over finite grids,
   - finite-field Nullstellensatz consequences for randomized certification.

Be bold: formalize the theorem in the form that future derandomization results will actually want to use.

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
