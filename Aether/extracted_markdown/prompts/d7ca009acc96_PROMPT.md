## Assignment: Commitment-based protocol

**Mode:** prove

Prove a genuinely new theorem package that turns a row-challenge matrix-checking protocol into a formally verified algebraic soundness statement in Lean 4. Do not stop at protocol narration: define the commitment interface, define what the verifier checks, and prove exact completeness/soundness lemmas over concrete matrix types. The goal is to create a reusable formal bridge between interactive proof ideas, matrix algebra, tropical row-selection principles, and local-to-global reconstruction.

This should not be a toy “the verifier checks one row” fact. The breakthrough target is a **local verification implies global matrix equality** theorem schema for committed matrix multiplication witnesses.

---

## Vision

The mathematical core is this: a matrix product identity \(K = A \cdot B\) is global, but it decomposes into row-local constraints
\[
\forall i,\quad K_{i,\bullet} = A_{i,\bullet} \cdot B.
\]
A commitment protocol that reveals only a challenged row of \(A\) together with the induced contributions to \(K\) is meaningful only if we can prove a theorem of the form:

> if all local row checks pass against binding commitments, then the entire committed product is uniquely determined and globally correct.

That is the theorem worth formalizing. It opens a field-facing interface between:
- interactive proof soundness,
- matrix algebra in Lean,
- local-to-global principles reminiscent of Čech reconstruction,
- sparse/selective verification via one-hot row probes,
- tropical/attention-style “dominant coordinate” verification heuristics.

This is the seed of a formal theory of **algebraic proof systems for linear computation** in Lean.

---

## Core formalization target

Use concrete types:
- `A : Matrix (Fin m) (Fin n) ℝ`
- `B : Matrix (Fin n) (Fin p) ℝ`
- `K : Matrix (Fin m) (Fin p) ℝ`

Define the row contribution matrix of row `i`:
\[
\mathrm{rowContrib}(A,B,i)_{j,k} := \begin{cases}
A_{i,j} B_{j,k} & \text{if row index is } i \\
0 & \text{otherwise}
\end{cases}
\]
or, more simply and more Lean-friendly, define the revealed row-product vector
\[
\mathrm{rowProd}(A,B,i)(k) := \sum_j A_{i,j} B_{j,k}.
\]

Then prove that equality of all revealed row-products with the corresponding rows of `K` implies `K = A ⬝ B`.

This is the first theorem; the second theorem should encode a **binding commitment abstraction**: if a commitment can be opened to at most one matrix, then successful openings for all challenged rows force a unique global witness.

---

## Precise theorem statements

### 1. Row-local characterization of matrix multiplication

Prove the exact iff characterization:
```lean
theorem matrix_mul_eq_iff_rowwise
  {m n p : ℕ}
  (A : Matrix (Fin m) (Fin n) ℝ)
  (B : Matrix (Fin n) (Fin p) ℝ)
  (K : Matrix (Fin m) (Fin p) ℝ) :
  K = A ⬝ B ↔
    ∀ i : Fin m, ∀ k : Fin p,
      K i k = ∑ j : Fin n, A i j * B j k
```

This theorem is elementary algebraically, but strategically essential: it is the exact formal hinge between global product verification and row-challenge checking.

### 2. Row-vector form of local verification

Define:
```lean
def rowProd
  {m n p : ℕ}
  (A : Matrix (Fin m) (Fin n) ℝ)
  (B : Matrix (Fin n) (Fin p) ℝ)
  (i : Fin m) : Fin p → ℝ :=
  fun k => ∑ j : Fin n, A i j * B j k
```

Then prove:
```lean
theorem matrix_mul_eq_iff_rowProd
  {m n p : ℕ}
  (A : Matrix (Fin m) (Fin n) ℝ)
  (B : Matrix (Fin n) (Fin p) ℝ)
  (K : Matrix (Fin m) (Fin p) ℝ) :
  K = A ⬝ B ↔
    ∀ i : Fin m, (fun k => K i k) = rowProd A B i
```

This is the protocol-facing form: the verifier challenges `i`, the prover reveals `rowProd A B i`, and the verifier checks it matches row `i` of `K`.

### 3. One-hot selector theorem for challenged rows

Exploit the existing theorem `epsilon_onehot_selects_column` as a conceptual building block. Define a row selector vector and prove a row extraction theorem for matrix multiplication.

A good target is:
```lean
def oneHotRow {m : ℕ} (i : Fin m) : Fin m → ℝ :=
  fun r => if r = i then 1 else 0

theorem oneHotRow_mul_extracts_row
  {m p : ℕ}
  (K : Matrix (Fin m) (Fin p) ℝ)
  (i : Fin m) :
  ∀ k : Fin p, ∑ r : Fin m, oneHotRow i r * K r k = K i k
```

Then strengthen to:
```lean
theorem oneHotRow_mul_A_mul_B
  {m n p : ℕ}
  (A : Matrix (Fin m) (Fin n) ℝ)
  (B : Matrix (Fin n) (Fin p) ℝ)
  (i : Fin m) :
  ∀ k : Fin p,
    ∑ r : Fin m, oneHotRow i r * (A ⬝ B) r k
      = ∑ j : Fin n, A i j * B j k
```

This theorem expresses challenge-response verification as a linear functional identity, which is much closer to interactive proof language.

### 4. Binding-commitment uniqueness theorem

You need a lightweight commitment abstraction. Keep it simple and concrete.

For example:
```lean
structure MatrixCommitment
  (m n : ℕ) where
  Commit : Matrix (Fin m) (Fin n) ℝ → Type
  openMatrix : {M : Matrix (Fin m) (Fin n) ℝ} → Commit M → Matrix (Fin m) (Fin n) ℝ
  sound : ∀ {M} (c : Commit M), openMatrix c = M
  binding :
    ∀ {M₁ M₂} (c₁ : Commit M₁) (c₂ : Commit M₂),
      openMatrix c₁ = openMatrix c₂ → M₁ = M₂
```

If this dependent encoding becomes awkward, use a non-dependent commitment object:
```lean
structure CommitmentScheme (m n : ℕ) where
  Commitment : Type
  commit : Matrix (Fin m) (Fin n) ℝ → Commitment
  binding :
    ∀ {M₁ M₂},
      commit M₁ = commit M₂ → M₁ = M₂
```

Then prove a theorem of the form:
```lean
theorem binding_row_checks_force_unique_product
  {m n p : ℕ}
  (CSA : CommitmentScheme m n)
  (CSB : CommitmentScheme n p)
  (A A' : Matrix (Fin m) (Fin n) ℝ)
  (B B' : Matrix (Fin n) (Fin p) ℝ)
  (hA : CSA.commit A = CSA.commit A')
  (hB : CSB.commit B = CSB.commit B') :
  A = A' ∧ B = B'
```

and then the protocol-level consequence:
```lean
theorem binding_and_all_row_checks_imply_global_correctness
  {m n p : ℕ}
  (CSA : CommitmentScheme m n)
  (CSB : CommitmentScheme n p)
  (A : Matrix (Fin m) (Fin n) ℝ)
  (B : Matrix (Fin n) (Fin p) ℝ)
  (K : Matrix (Fin m) (Fin p) ℝ)
  (hchecks : ∀ i : Fin m, ∀ k : Fin p, K i k = ∑ j : Fin n, A i j * B j k) :
  K = A ⬝ B
```

This last theorem is algebraic, but in the surrounding development it becomes the **soundness theorem for full challenge coverage**.

### 5. Local-to-global reconstruction theorem inspired by Čech cocycles

Build explicitly on `cocycle_determined_by_first_row`. The analogy is strong: a global object is determined by coherent local data. Formalize the matrix analogue:

```lean
theorem matrix_determined_by_rows
  {m p : ℕ}
  {K L : Matrix (Fin m) (Fin p) ℝ}
  (h : ∀ i : Fin m, ∀ k : Fin p, K i k = L i k) :
  K = L
```

This is simple, but use it as the backbone for a more protocol-native theorem:
```lean
theorem committed_matrix_determined_by_all_opened_rows
  {m p : ℕ}
  {K L : Matrix (Fin m) (Fin p) ℝ}
  (h : ∀ i : Fin m, (fun k => K i k) = (fun k => L i k)) :
  K = L
```

Frame it as the matrix counterpart of local cocycle determination.

---

## Why this is a breakthrough

This creates a formal language for **verifiable linear algebra protocols** inside Lean, not as cryptographic implementation details, but as exact mathematical soundness statements. Once this exists, Aristotle can attack:

- probabilistic checking of matrix products,
- low-communication verification for neural network layers,
- tropical verification where only dominant contributions matter,
- sum-check and GKR-style abstractions over finite index types,
- local-to-global certification of learned systems.

The key leap is that the theorem package is reusable across cryptography, proof complexity, certified ML, and tropical methods.

---

## How to build on the catalog theorems

### 1. `epsilon_onehot_selects_column`
Use this as the model for challenge extraction by basis vectors. The verifier’s row challenge is mathematically a one-hot probe. Adapt the column-selection logic to row-selection for matrices and row functionals. This is the most directly relevant existing theorem.

### 2. `cocycle_determined_by_first_row`
Do not merely cite it. Mirror its architecture:
- local data,
- compatibility,
- uniqueness of global object.
Your protocol theorem should be explicitly sold as a matrix-algebraic local-to-global principle.

### 3. `dominant_column_is_row_argmax`
This gives a route toward a future **sublinear verification heuristic**: if one can prove that a row’s dominant contribution determines the argmax structure of the output row, then challenge protocols may verify not full equality but correct dominant behavior. Even if you do not complete that theorem now, define at least one lemma preparing that bridge.

### 4. `tropical_row_norm_bound_coord`
This can support a robustness-flavored extension: if the revealed row is approximately correct and row norms are bounded, then the resulting row-product error is bounded coordinatewise. If exact proof is too ambitious for this cycle, at least isolate a deterministic inequality lemma about row-product perturbations.

### 5. `with` from certified radius
Use it conceptually: local certificates can imply global guarantees. Your row-check theorem is the exact algebraic analogue of a certified radius argument.

---

## Recommended proof strategies

### Strategy A: Extensional matrix equality via `Matrix.ext`
Most promising.

1. Prove `matrix_mul_eq_iff_rowwise` by unfolding `Matrix.mul_apply`.
2. Use `Matrix.ext` to reduce matrix equality to pointwise equality on `Fin` indices.
3. For row-function equality, use `funext` over `k : Fin p`.

Why this is best: it aligns perfectly with Mathlib’s matrix API and should minimize `sorry`.

### Strategy B: One-hot linear functional proof
More conceptual and protocol-native.

1. Define `oneHotRow`.
2. Prove it extracts rows by finite summation with `if` simplification.
3. Show that checking the one-hot probe against `A ⬝ B` is equivalent to checking the row-product formula.

Why valuable: this reframes the protocol as linear testing, opening the road to randomized linear combinations and Freivalds-style verification.

### Strategy C: Local-to-global reconstruction pattern
Best for the commitment interpretation.

1. Prove a generic “matrix determined by rows” lemma.
2. Package row openings as local data.
3. Use binding to show uniqueness of any matrix compatible with all openings.

Why useful: this ties directly to `cocycle_determined_by_first_row` and makes the protocol look like a sheaf/gluing theorem for matrix witnesses.

---

## Cross-domain connections to make explicit in the development

### Cryptography / Interactive proofs
The theorem package is a deterministic soundness core for commitment-based verification. Today it is exact and full-coverage; tomorrow it becomes probabilistic and sublinear.

### Sheaf theory / Local-to-global mathematics
A matrix is reconstructed from compatible row restrictions. This is the finite algebraic analogue of gluing local sections. Explicitly mention the analogy with cocycle determination.

### Tropical geometry / Attention mechanisms
A future theorem can replace exact row equality by dominant-coordinate consistency. The verifier may only need to certify the tropical leading term or argmax structure. Connect this to `dominant_column_is_row_argmax`.

### Certified ML
Matrix multiplication underlies dense layers and attention. A verified row-check protocol becomes a building block for certifying outsourced inference or compressed execution.

### Proof complexity / PCP intuition
One challenged row is a local view of a global witness. Formalizing the exact deterministic version is the first step toward a Lean-native algebraic PCP story.

---

## Application keywords

commitment schemes, matrix verification, interactive proofs, algebraic soundness, local-to-global reconstruction, row challenge protocol, one-hot selectors, certified linear algebra, tropical verification, proof complexity, outsourced computation, verifiable ML, finite-dimensional sheaf principles

---

## Lean 4 implementation guidance

Use:
- `Matrix.mul_apply`
- `Matrix.ext`
- `funext`
- `Finset` summation lemmas
- `by_cases h : r = i` for one-hot simplification
- `simp [oneHotRow, h]`
- `ring` or `nlinarith` only if genuinely needed; most goals should be `simp` + extensionality

Prefer simple definitions over over-engineered abstractions. The commitment structure should be just strong enough to state binding cleanly.

---

## Concrete deliverables

1. A Lean file formalizing:
   - `rowProd`
   - `oneHotRow`
   - `matrix_mul_eq_iff_rowwise`
   - `matrix_mul_eq_iff_rowProd`
   - `oneHotRow_mul_extracts_row`
   - `oneHotRow_mul_A_mul_B`
   - at least one commitment structure
   - `binding_and_all_row_checks_imply_global_correctness`

2. At least one bridge lemma connecting this protocol to an existing catalog theorem:
   - either one-hot extraction inspired by `epsilon_onehot_selects_column`,
   - or local-to-global uniqueness inspired by `cocycle_determined_by_first_row`.

3. Minimize `sorry`. If a theorem is too ambitious, prove the exact deterministic algebraic core fully and isolate the harder protocol abstraction behind definitions.

4. Create `FUTURE_DIRECTIONS.md` with **3–5 concrete next theorems**, each with:
   - precise statement,
   - why it matters,
   - proof strategy sketch,
   - dependency on the current development.

---

## High-value next-step theorem suggestions for FUTURE_DIRECTIONS.md

You must include some version of these or stronger ones:

1. **Freivalds-style soundness over finite fields**
   - formalize randomized vector checks for matrix multiplication;
   - prove one-sided error bounds.

2. **Approximate row-check soundness**
   - if each challenged row is within `ε` and row norms are bounded, prove a global output error bound;
   - connect to `tropical_row_norm_bound_coord`.

3. **Tropical dominant-row verification**
   - prove that verifying dominant contributions suffices to certify argmax outputs under separation assumptions;
   - connect to `dominant_column_is_row_argmax`.

4. **Sheaf-theoretic gluing for block matrices**
   - reconstruct a global matrix from overlapping block openings with consistency constraints;
   - explicit analogy with Čech descent.

5. **Verifiable neural layer execution**
   - instantiate the protocol for affine layers `x ↦ Wx + b`;
   - prove exactness of challenged-coordinate verification.

---

## Standard of ambition

Do not produce a minor wrapper around `Matrix.mul_apply`. Produce a coherent theorem package that makes a research mathematician say: “this is the algebraic skeleton of a real verification protocol, and it is already connected to tropical, sheaf, and certified-ML ideas.”

Required: Lean 4 proofs, `FUTURE_DIRECTIONS.md`.

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

Research domain: MachineLearning
Research mode: prove
