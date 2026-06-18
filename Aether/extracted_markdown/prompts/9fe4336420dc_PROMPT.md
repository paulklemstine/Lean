## Mode: prove

### Title
**Freivalds via Schwartz–Zippel over finite fields: a certified matrix-product verification theorem in Lean**

### Vision
Prove the exact finite-field counting theorem that turns polynomial identity testing into a formally verified randomized linear-algebra algorithm. This is not just “another matrix lemma”: it is the certified bridge from algebraic geometry over finite fields to probabilistic verification and complexity theory. Once formalized, it opens a route to a Lean-native theory of randomized certificates, PIT-based verification, and algebraic complexity lower-bounds-by-formalization.

The key point is conceptual: **Freivalds is a codimension-one phenomenon**. If `AB ≠ C`, then the disagreement matrix defines a nonzero linear map, and the false-accept set is a hyperplane kernel with cardinality at most `q^(n-1)`. This is the finite-field geometric core of the algorithm.

---

## Precise target theorem

### Mathematical statement
Let `q` be prime, let `𝔽_q = ZMod q`, and let `A B C : Matrix (Fin n) (Fin n) (𝔽_q)`. If `A * B ≠ C`, then the set of vectors `r : 𝔽_q^n` for which Freivalds’ check falsely accepts,
\[
(A B)\,r = C r,
\]
has size at most `q^(n-1)`.

Equivalently, for uniformly random `r`, the false-accept probability is at most `1/q`.

This is the exact finite-field soundness theorem for one-shot Freivalds.

### Lean 4 type signature
```lean
theorem freivalds_product_verification
    {q n : ℕ} [Fact q.Prime]
    (A B C : Matrix (Fin n) (Fin n) (ZMod q))
    (hneq : A * B ≠ C) :
    Fintype.card {r : Fin n → ZMod q // (A * B).mulVec r = C.mulVec r}
      ≤ q ^ (n - 1)
```

### Stronger theorem worth proving first
The above theorem should likely be derived from a more structural kernel bound:

```lean
theorem card_solutions_mulVec_eq_zero_le
    {q n : ℕ} [Fact q.Prime]
    (D : Matrix (Fin n) (Fin n) (ZMod q))
    (hD : D ≠ 0) :
    Fintype.card {r : Fin n → ZMod q // D.mulVec r = 0}
      ≤ q ^ (n - 1)
```

Then instantiate with `D = A * B - C`.

### Probability corollary
If your local library has finite uniform probability machinery, also prove the explicit Freivalds soundness corollary:

```lean
theorem freivalds_false_accept_prob_le
    {q n : ℕ} [Fact q.Prime]
    (A B C : Matrix (Fin n) (Fin n) (ZMod q))
    (hneq : A * B ≠ C) :
    ((Fintype.card {r : Fin n → ZMod q // (A * B).mulVec r = C.mulVec r} : ℚ)
      / (Fintype.card (Fin n → ZMod q) : ℚ))
      ≤ (1 : ℚ) / q
```

This corollary is where the theorem becomes algorithmics.

---

## Why this is a breakthrough
Freivalds is a foundational randomized algorithm, but formal libraries often stop at algebraic lemmas or toy PIT statements. You should **certify the full conceptual pipeline**:

- nonzero matrix disagreement  
- linear polynomial identity testing  
- codimension-one solution counting  
- randomized soundness of matrix product verification.

That pipeline is the seed of a formal theory of:
- randomized verification,
- algebraic proof systems,
- interactive proofs,
- derandomization via hitting sets,
- and finite-field complexity.

This is how Lean starts speaking complexity theory in a mathematically serious dialect.

---

## Core proof architecture

### Strategy A: Direct reduction to a nonzero linear form bound
This is the most promising strategy if `freivalds_from_schwartz_zippel` or an equivalent kernel-count theorem is already in the catalog.

1. **Define the disagreement matrix**
   ```lean
   let D := A * B - C
   ```
   Show `D ≠ 0` from `A * B ≠ C`.

2. **Identify false accepts with the kernel**
   Prove
   ```lean
   (A * B).mulVec r = C.mulVec r ↔ D.mulVec r = 0
   ```
   using `Matrix.sub_mulVec`, or by extensionality plus simp on `D`.

3. **Apply the kernel-count / Schwartz–Zippel theorem**
   Use the existing theorem for nonzero linear maps over `ZMod q` to deduce
   ```lean
   Fintype.card {r // D.mulVec r = 0} ≤ q^(n-1)
   ```
   and transport along the equivalence.

**Why this is best:** it is structurally clean, aligns exactly with the intended mathematics, and minimizes fragile rank arguments.

---

### Strategy B: Hyperplane-fiber argument from a nonzero row
If the Schwartz–Zippel theorem is awkwardly stated, prove the result directly by elementary finite-field linear algebra.

1. Since `D ≠ 0`, choose indices `i j` with `D i j ≠ 0`. Then the `i`-th coordinate of `D.mulVec r` is
   \[
   \sum_k D_{ik} r_k.
   \]
   This is a nonzero linear form in `r`.

2. Show that if `D.mulVec r = 0`, then in particular the `i`-th coordinate vanishes, so every false-accept vector lies in the zero set of that nonzero linear form.

3. Count the zero set of a nonzero linear form:
   solve uniquely for `r j` in terms of the other `n-1` coordinates, yielding exactly `q^(n-1)` solutions.

**Why this matters:** this avoids rank/nullity machinery and exposes the geometric essence of Freivalds as “a single nontrivial linear constraint cuts the ambient space by one dimension.”

---

### Strategy C: Rank-nullity / cardinality of finite-dimensional subspaces
This is elegant if Mathlib’s finite-dimensional API over `ZMod q` is already convenient.

1. Interpret `D.mulVec` as a linear map
   ```lean
   (Fin n → ZMod q) →ₗ[ZMod q] (Fin n → ZMod q)
   ```
   and use `D ≠ 0` to show the linear map is nonzero.

2. A nonzero linear map has kernel of dimension at most `n - 1`.

3. Use the finite-field formula
   \[
   |\ker D| = q^{\dim \ker D}
   \]
   to conclude the cardinality bound.

**Why this is less promising:** dimension/cardinality lemmas can be heavier in Lean than the direct combinatorial route, but if they are already in place this gives the most conceptual theorem schema for future generalization.

---

## Recommended execution plan

### Step 1: Prove the structural kernel theorem
Target:
```lean
theorem card_solutions_mulVec_eq_zero_le
    {q n : ℕ} [Fact q.Prime]
    (D : Matrix (Fin n) (Fin n) (ZMod q))
    (hD : D ≠ 0) :
    Fintype.card {r : Fin n → ZMod q // D.mulVec r = 0}
      ≤ q ^ (n - 1)
```

This theorem is the reusable engine. It should live in a file like `Freivalds.lean` or a more general `LinearPIT.lean`.

### Step 2: Derive Freivalds immediately
Use:
```lean
have hD : A * B - C ≠ 0 := by
  intro h
  apply hneq
  exact sub_eq_zero.mp h
```
or the appropriate rearrangement.

Then produce an equivalence:
```lean
{r // (A * B).mulVec r = C.mulVec r} ≃ {r // (A * B - C).mulVec r = 0}
```
and transfer cardinality.

### Step 3: Extract the probabilistic statement
Because
```lean
Fintype.card (Fin n → ZMod q) = q ^ n
```
the counting bound implies false-accept probability at most
\[
q^{n-1}/q^n = 1/q.
\]
This is the actual algorithmic soundness guarantee.

---

## Lean-specific build notes

Useful ingredients likely available in Mathlib:

- `Matrix.mulVec`
- matrix subtraction lemmas, perhaps `[AddCommGroup]`-based simp lemmas
- `sub_eq_zero`
- extensionality on vectors/functions `Fin n → ZMod q`
- `Fintype.card_fun`
- cardinality of `ZMod q`
- finite field structure on `ZMod q` from `[Fact q.Prime]`

Potential intermediate lemmas to isolate:

```lean
lemma mulVec_sub
    {R : Type*} [Ring R] {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n R) (r : n → R) :
    (A - B).mulVec r = A.mulVec r - B.mulVec r
```

```lean
lemma mulVec_eq_iff_sub_mulVec_eq_zero
    {q n : ℕ} [Fact q.Prime]
    (A C : Matrix (Fin n) (Fin n) (ZMod q)) (r : Fin n → ZMod q) :
    A.mulVec r = C.mulVec r ↔ (A - C).mulVec r = 0
```

If these already exist, use them aggressively to keep the final theorem tiny.

---

## Cross-domain connections
This theorem is a gateway result. Make those connections explicit in comments/docstrings and in the surrounding file structure.

### 1. Polynomial Identity Testing
Freivalds is a degree-1 PIT instance. Your theorem says:
- a nonzero linear polynomial over `𝔽_q^n` has at most `q^(n-1)` zeros.
This is the affine finite-field shadow of Schwartz–Zippel. Formalizing it creates a path toward:
- multilinear PIT,
- determinant identities,
- circuit verification.

### 2. Randomized complexity theory
This is a Lean formalization of a canonical **coRP-style verifier** for matrix product equality. It opens:
- one-sided error verification,
- amplification by repetition,
- certified randomized algorithms in complexity classes.

### 3. Coding theory and linear sketches
The disagreement test is a random linear sketch. The theorem is exactly a soundness guarantee for a sketch-based certificate:
- if `AB ≠ C`, a random projection detects the error with high probability.
This connects directly to:
- fingerprinting,
- streaming verification,
- linear hash families.

### 4. Finite geometry
The false-accept set is a hyperplane or smaller affine subspace in `𝔽_q^n`. That geometric interpretation suggests future theorems on:
- subspace evasive sets,
- hitting sets,
- deterministic derandomization.

### 5. Proof systems and interactive verification
Freivalds is the baby case of algebraic verification. Formalizing it rigorously is a natural prelude to:
- sum-check,
- low-degree testing,
- PCP-flavored finite-field soundness lemmas.

---

## How to leverage catalog theorems
The listed catalog theorems are not directly about matrices, but they signal a live ecosystem around soundness/error bounds and oracle complexity. Use them rhetorically and architecturally:

- `soundness_error_bound` and `bounded_adversary_bounded_error` suggest a pattern: derive a sharp counting theorem, then package it as an error/soundness theorem.
- `query_bound_card` hints at a bridge from algebraic verification to oracle complexity: Freivalds is a one-query linear sketch verifier.
- If there is any local framework around “soundness,” consider exporting your probability corollary into that style.

Even if these theorems are not imported directly, your theorem should be written so that future integration with those frameworks is straightforward.

---

## Stronger generalization if time permits
Do not stop at square matrices if the APIs cooperate. The real theorem is rectangular:

```lean
theorem freivalds_product_verification_rect
    {q m n k : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin k) (ZMod q))
    (C : Matrix (Fin m) (Fin k) (ZMod q))
    (hneq : A * B ≠ C) :
    Fintype.card {r : Fin k → ZMod q // (A * B).mulVec r = C.mulVec r}
      ≤ q ^ (k - 1)
```

This is mathematically cleaner: the randomness lives in the column dimension `k`, and the false-accept set is a codimension-one subset of `𝔽_q^k`.

If `Freivalds.lean` already partially supports square matrices, **rectangular is the field-opening version**. It makes the theorem match the actual algorithmic generality.

---

## What would make this genuinely paradigm-opening
If you can, package the theorem into a reusable abstraction:

> Any nonzero linear map over a finite field has zero fiber of size at most `|𝔽|^(dim-1)`.

That statement is bigger than Freivalds. It becomes a universal finite-field soundness primitive, reusable across randomized algebraic verification.

An even more ambitious abstraction:
- define a class of verifiers arising from linear sketches,
- prove one-sided soundness from nontriviality of the induced linear functional,
- instantiate with Freivalds.

That would move the library from theorem proving to **verification architecture**.

---

## Deliverables
1. The theorem `freivalds_product_verification`.
2. Preferably the reusable precursor `card_solutions_mulVec_eq_zero_le`.
3. If feasible, the rectangular generalization.
4. A probability/soundness corollary stated in algorithmic language.
5. Minimize sorry; isolate any unavoidable gap into tiny local lemmas.

---

## Application keywords
Freivalds algorithm, polynomial identity testing, Schwartz–Zippel, finite fields, randomized verification, coRP, algebraic complexity, linear sketches, matrix product certification, coding theory, finite geometry, derandomization, soundness bounds, formalized probability, certified algorithms.

---

## FUTURE_DIRECTIONS.md requirement
Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, not incremental variants. Suggested caliber:

1. **Amplified Freivalds with exact exponential decay**  
   Formalize `t` independent repetitions and prove false-accept probability `≤ q^(-t)`.

2. **General linear-sketch verification theorem**  
   Abstract Freivalds to arbitrary nonzero linear maps over finite fields and derive a generic one-sided soundness framework.

3. **Deterministic derandomization via explicit hitting sets**  
   Replace uniform random `r` by explicit small hitting sets for linear forms and certify deterministic matrix product verification under structured assumptions.

4. **From Freivalds to low-degree testing**  
   Formalize the degree-`d` Schwartz–Zippel theorem over finite fields and derive certified PIT for broader arithmetic circuits.

5. **Interactive-proof bridge**  
   Build the first Lean formalization step from Freivalds-style algebraic checking toward sum-check or GKR-style protocols.

This is the right theorem because it is small enough to land now and deep enough to seed an entire formal complexity theory stack.

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

Research domain: Logic
Research mode: prove
