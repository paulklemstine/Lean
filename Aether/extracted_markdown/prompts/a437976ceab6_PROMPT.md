## Assignment: Key Equation Beyond Folklore — Formal Reed–Solomon Decoding as Linear Algebra and Vanishing Geometry

**Mode:** prove

Prove a genuinely nontrivial decoding theorem formalizing the Reed–Solomon key equation in Lean 4, not merely as a coding-theory anecdote but as a bridge between polynomial interpolation, finite-dimensional linear algebra, and vanishing-set geometry.

The core breakthrough is to formalize the passage

\[
r(a_i)E(a_i)=p(a_i)E(a_i)\quad\forall i
\]

into a **global polynomial identity under degree bounds**, and then derive **uniqueness of decoding** from a linear kernel argument. This turns error correction into a theorem about low-degree polynomials agreeing on sufficiently many points. That is the mathematically decisive step.

---

## Precise Research Target

Let \(F\) be a field, let \(a : \mathrm{Fin}\ n \to F\) be pairwise distinct evaluation points, let \(p : F[X]\) be the transmitted polynomial with \(\deg p < k\), let \(r : \mathrm{Fin}\ n \to F\) be the received word, and let \(S \subseteq \mathrm{Fin}\ n\) be the error set with \(|S| \le t\). Define the error-locator polynomial

\[
E(X)=\prod_{i\in S}(X-C(a_i)).
\]

Assume
\[
r(i)=p(a_i)\quad \text{for all } i\notin S.
\]

Then setting \(Q := p \cdot E\), one has
\[
Q(a_i)=C(r(i))\cdot E(a_i)\quad\text{for all }i.
\]

This is the pointwise key equation. The real theorem is the converse uniqueness statement:

> If \(E \neq 0\), \(\deg E \le t\), \(\deg Q < k+t\), and
> \[
> Q(a_i)=C(r(i))\cdot E(a_i)\quad\forall i,
> \]
> with \(n > (k+t-1)+t\), then \(E \mid Q\), and writing \(Q = p' E\), one has \(\deg p' < k\) and \(p'(a_i)=r(i)\) on all non-error positions. Under the usual unique-decoding bound \(2t+k \le n\), this \(p'\) is unique.

This is the formal heart of Welch–Berlekamp decoding.

---

## Lean 4 Formalization Targets

Use concrete finite types and Mathlib polynomials. Work over a general field `F`, not just `ℝ`; finite fields can be an application layer.

### Theorem 1: Pointwise key equation from an error set
```lean
theorem key_equation_pointwise
  {F : Type*} [Field F]
  {n k t : ℕ}
  (a : Fin n → F)
  (ha : Function.Injective a)
  (p : F[X])
  (r : Fin n → F)
  (S : Finset (Fin n))
  (hdegp : p.natDegree < k)
  (hS : S.card ≤ t)
  (hr :
    ∀ i : Fin n, i ∉ S → r i = Polynomial.eval (a i) p) :
  let E : F[X] := ∏ i in S, (Polynomial.X - Polynomial.C (a i))
  let Q : F[X] := p * E
  ∀ i : Fin n, Polynomial.eval (a i) Q = r i * Polynomial.eval (a i) E
```

### Theorem 2: Vanishing-on-many-points forces divisibility / equality
A crucial supporting theorem:
```lean
theorem polynomial_eq_zero_of_natDegree_lt_and_eval_eq_zero_on_finset
  {F : Type*} [Field F]
  (f : F[X]) (s : Finset F)
  (hs : s.card > f.natDegree)
  (hvan : ∀ x ∈ s, Polynomial.eval x f = 0) :
  f = 0
```
If this exact statement is awkward because of `natDegree` conventions at zero, use a version with `degree` or an explicit `f ≠ 0` hypothesis plus contradiction.

### Theorem 3: Uniqueness of the key-equation solution under decoding bounds
```lean
theorem key_equation_unique
  {F : Type*} [Field F]
  {n k t : ℕ}
  (a : Fin n → F)
  (ha : Function.Injective a)
  (r : Fin n → F)
  (Q1 Q2 E1 E2 : F[X])
  (hE1 : E1 ≠ 0) (hE2 : E2 ≠ 0)
  (hdegQ1 : Q1.natDegree < k + t)
  (hdegQ2 : Q2.natDegree < k + t)
  (hdegE1 : E1.natDegree ≤ t)
  (hdegE2 : E2.natDegree ≤ t)
  (hbound : k + 2 * t ≤ n)
  (hsol1 : ∀ i : Fin n, Polynomial.eval (a i) Q1 = r i * Polynomial.eval (a i) E1)
  (hsol2 : ∀ i : Fin n, Polynomial.eval (a i) Q2 = r i * Polynomial.eval (a i) E2) :
  Q1 * E2 = Q2 * E1
```

This theorem is the algebraic uniqueness engine. From it, derive a corollary that if `E ∣ Q` and `Monic E`, then the decoded message polynomial is unique.

### Theorem 4: Existence of a nonzero solution by dimension count
A bold but valuable theorem:
```lean
theorem exists_nonzero_key_equation_solution
  {F : Type*} [Field F] [Infinite F]
  {n k t : ℕ}
  (a : Fin n → F)
  (ha : Function.Injective a)
  (r : Fin n → F)
  (hbound : n > k + 2 * t) :
  ∃ Q E : F[X],
    E ≠ 0 ∧
    Q.natDegree < k + t ∧
    E.natDegree ≤ t ∧
    (∀ i : Fin n, Polynomial.eval (a i) Q = r i * Polynomial.eval (a i) E)
```

If the full dimension-count proof is too heavy for one cycle, first prove a matrix-form reformulation: the coefficient vector of `(Q,E)` lies in the kernel of an explicit `n × (k+2*t+1)` matrix.

---

## Why This Is a Breakthrough

This is not “yet another coding theorem.” Formalizing the key equation at this level opens a **machine-verified algebraic decoding stack**:

- interpolation and low-degree rigidity,
- linear-algebraic decoding certificates,
- vanishing ideals of finite point sets,
- eventually Berlekamp–Welch, Sudan, Guruswami–Sudan, and list decoding.

The field-opening move is to recast decoding as a theorem schema:

> **Low-degree algebraic relations are determined by enough evaluation constraints.**

That schema is reusable in symbolic computation, compressed sensing over finite fields, algebraic cryptanalysis, and proof-carrying error correction.

---

## Mathematical Framing

At corrupted positions, the received word may disagree with `p`; at uncorrupted positions it agrees. The error-locator polynomial `E` vanishes exactly where corruption occurs, so multiplying by `E` annihilates the discrepancy pointwise:

\[
(r(a_i)-p(a_i))E(a_i)=0.
\]

Thus the nonlinear unknown “error locations” becomes linearized into the unknown coefficients of `Q = pE` and `E`. This is the conceptual miracle.

Your formalization should make this miracle explicit:
1. pointwise annihilation,
2. degree bookkeeping,
3. many-point vanishing implies zero polynomial,
4. uniqueness from low-degree rigidity.

---

## 2–3 Proof Strategy Paths

### Strategy A: Direct polynomial rigidity via many roots
**Most promising.**

1. Prove the pointwise identity:
   \[
   Q(a_i)-r(i)E(a_i)=0
   \]
   by splitting on whether `i ∈ S`.
2. For uniqueness, define
   \[
   D := Q_1E_2 - Q_2E_1.
   \]
   Show `D(a_i)=0` for all evaluation points.
3. Bound
   \[
   \deg D < k+2t,
   \]
   then use `k + 2t ≤ n` and injectivity of `a` to conclude `D=0`.

Why promising: Mathlib already supports polynomial evaluation, products over finsets, degree estimates, and root-count arguments. This route minimizes new infrastructure.

### Strategy B: Explicit matrix kernel / linear system formalization
1. Encode coefficients of `Q` and `E` as a vector of length `k + 2*t + 1`.
2. Define the matrix whose `i`-th row enforces
   \[
   Q(a_i)-r(i)E(a_i)=0.
   \]
3. Prove any genuine transmitted pair `(pE,E)` gives a kernel vector; if columns exceed rows, derive a nonzero kernel element.
4. Then use Strategy A’s uniqueness theorem to show the kernel solution recovers the codeword uniquely.

Why powerful: this exposes the key equation as **certified linear algebra**, linking coding theory to rank-nullity and computational extraction. It also aligns with eventual executable decoders.

### Strategy C: Vanishing ideal / finite-set algebra
1. Package the evaluation points as a finite subset `A : Finset F`.
2. Show any polynomial vanishing on all `a i` is divisible by
   \[
   \prod_i (X-C(a_i)).
   \]
3. Apply this to the discrepancy polynomial
   \[
   Q-rE
   \]
   in a suitably interpolated sense, or to `D = Q₁E₂ - Q₂E₁`.
4. Conclude equality from degree bounds.

Why interesting: this creates a bridge to algebraic geometry and ideal-theoretic reasoning. It is more ambitious, but it opens the door to multivariate decoding and list decoding.

---

## Building on Catalog Theorems

The supplied catalog theorems are not coding-theory results, but they suggest a methodological bridge: **global validity from checking a controlled family of points / linear bounds / closure under constraints**.

- `implication_valid_iff_all_prime_points`  
  Use its philosophical pattern: a global statement is certified by checking enough distinguished points. Here, the analogous principle is: a low-degree polynomial identity is certified by enough evaluation points. If possible, echo this style in naming and theorem decomposition.

- `closure_iteration_linear_bound` and `coboundary_check_linear`  
  These support the framing that the key equation is a **linear constraint system**. Even if not directly imported, mirror their architecture: define a linear operator and prove correctness/uniqueness via kernel properties.

- `boundedWordCount_linear_times_exponential`  
  Use this as inspiration for complexity commentary: decoding search spaces collapse from combinatorial error patterns to a linear-algebraic kernel problem.

- `error_vanishing`  
  Thematically relevant: corruption is handled by constructing an annihilator. Your error-locator polynomial is exactly an algebraic annihilator. Explicitly make this bridge.

Do not force fake dependencies; instead, build a new bridge theorem in the same spirit: **error annihilation + linear constraint = recoverability**.

---

## Cross-Domain Connections

1. **Algebraic geometry:**  
   The error-locator polynomial is a vanishing function on a finite subscheme. This is the one-variable shadow of vanishing ideals and evaluation codes on varieties.

2. **Signal processing / compressed sensing:**  
   The key equation converts sparse corruption locations into an annihilating filter, analogous to Prony’s method and sparse spectral recovery.

3. **Cryptography:**  
   Syndrome decoding, code-based cryptography, and algebraic attacks all rely on low-degree relations constrained by point evaluations. A formal key-equation library would be foundational.

4. **Quantum error correction:**  
   The annihilator viewpoint resonates with stabilizer checks: hidden error structure is revealed through linear constraints. This is a conceptual bridge worth stating explicitly.

5. **Computational complexity:**  
   The theorem demonstrates how exponential search over error subsets is replaced by polynomial-time linear algebra. Formalizing that transition is mathematically and algorithmically significant.

---

## Concrete Definitions to Introduce

You may need these Lean definitions:

```lean
def errorLocator
  {F : Type*} [Field F] {n : ℕ}
  (a : Fin n → F) (S : Finset (Fin n)) : F[X] :=
  ∏ i in S, (Polynomial.X - Polynomial.C (a i))
```

```lean
def keyEquationHolds
  {F : Type*} [Field F] {n : ℕ}
  (a : Fin n → F) (r : Fin n → F) (Q E : F[X]) : Prop :=
  ∀ i : Fin n, Polynomial.eval (a i) Q = r i * Polynomial.eval (a i) E
```

Optionally define a structure:
```lean
structure KeyEquationSolution
  {F : Type*} [Field F] {n : ℕ}
  (a : Fin n → F) (r : Fin n → F) where
  Q : F[X]
  E : F[X]
  hE : E ≠ 0
  hrel : keyEquationHolds a r Q E
```

This will make later uniqueness and normalization statements cleaner.

---

## Suggested Proof Lemmas

Prove these in order:

1. `eval_errorLocator_eq_zero_iff`
2. `eval_errorLocator_ne_zero_of_not_mem`
3. `key_equation_pointwise`
4. `natDegree_errorLocator_le_card`
5. `sub_eq_zero_of_eval_eq_zero_many`
6. `key_equation_unique`
7. `decoded_polynomial_unique`

A very useful lemma:
```lean
theorem eval_prod_X_sub_C
  {F : Type*} [Field F]
  (s : Finset F) (x : F) :
  Polynomial.eval x (∏ a in s, (Polynomial.X - Polynomial.C a))
    = ∏ a in s, (x - a)
```
Mathlib may already provide enough simp lemmas to avoid proving this from scratch.

---

## Lean Tactics / Library Guidance

- Look for:
  - `Polynomial.eval_mul`
  - `Polynomial.eval_sub`
  - `Polynomial.natDegree_mul_le`
  - root-count lemmas such as `Polynomial.card_roots`
  - finset product simp lemmas
  - `Finset.mem_image`, injectivity lemmas for converting `Fin n` distinctness into distinct field elements

- Degree arguments often go more smoothly with `Polynomial.degree` in `WithBot ℕ`; if `natDegree` is awkward at zero, isolate the nonzero case first.

- For uniqueness, proving `Q1 * E2 - Q2 * E1 = 0` is often easier than proving equality directly.

- Normalize `E` to be monic if needed for quotient uniqueness.

---

## Ambitious Extension If Time Permits

Formalize the Berlekamp–Welch decoder correctness theorem:

```lean
theorem berlekamp_welch_correct
  {F : Type*} [Field F]
  {n k t : ℕ}
  (a : Fin n → F)
  (ha : Function.Injective a)
  (p : F[X])
  (hdegp : p.natDegree < k)
  (r : Fin n → F)
  (herr : ∃ S : Finset (Fin n), S.card ≤ t ∧
    ∀ i : Fin n, i ∉ S → r i = Polynomial.eval (a i) p)
  (hbound : k + 2 * t ≤ n) :
  ∃! p' : F[X], p'.natDegree < k ∧
    ∃ E Q : F[X],
      E ≠ 0 ∧
      Q = p' * E ∧
      E.natDegree ≤ t ∧
      keyEquationHolds a r Q E
```

This would be a true formal coding-theory milestone.

---

## Application Keywords

Reed–Solomon codes, Berlekamp–Welch decoding, key equation, error-locator polynomial, polynomial identity testing, finite fields, vanishing ideals, linear algebraic decoding, sparse corruption, annihilating filters, algebraic cryptanalysis, quantum error correction, proof-carrying decoders, certified algorithms.

---

## Deliverables

1. Lean 4 file(s) proving at least Theorem 1 and one of Theorem 2 or 3.
2. Definitions for `errorLocator` and `keyEquationHolds`.
3. Minimal `sorry` usage; if blocked, isolate the obstruction in a helper lemma.
4. `FUTURE_DIRECTIONS.md` with **3–5 concrete next steps**, each including:
   - exact theorem statement,
   - likely proof strategy,
   - cross-domain significance.

---

## FUTURE_DIRECTIONS.md Requirement

This is mandatory. Include specific next-cycle targets such as:

1. matrix-kernel existence of key-equation solutions over finite fields;
2. monic normalization and executable decoder extraction;
3. list-decoding generalization via multiplicity constraints;
4. multivariate vanishing-ideal decoding on affine varieties;
5. bridge to annihilating-filter methods in sparse signal recovery.

Make it concrete enough that the next cycle can immediately begin proving.

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
