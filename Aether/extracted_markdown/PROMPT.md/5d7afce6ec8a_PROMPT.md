## Assignment: 2. Repeated-Trial Soundness Amplification

**Mode**: prove

Prove a genuinely new theorem formalizing **exponential soundness amplification for independent Freivalds trials over a finite field**, and do it in a way that becomes a reusable blueprint for formalized probabilistic verification, derandomization, and interactive-proof amplification in Lean 4.

This is not just a stronger bound on a toy algorithm. If done correctly, it creates a **foundational formal pattern**:

- single-trial algebraic soundness
- product-space factorization of accepting transcripts
- exact cardinality of independent trial spaces
- exponential decay of adversarial acceptance probability

That pattern is the finite-field skeleton underlying PCP amplification, property testing repetition, fingerprinting protocols, and randomized certification. Formalizing it cleanly would open a bridge between **linear algebra**, **finite probability**, **complexity theory**, and **formal cryptographic verification**.

---

## Precise Theorem Target

The theorem should state that if `K ≠ A * B`, then the probability that `t` independent Freivalds checks all accept is at most `1 / q^t`.

A robust Lean 4 target is:

```lean
theorem freivalds_amplified_soundness
    {q m n p t : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) :
    ((Fintype.card {rs : Fin t → (Fin p → ZMod q) //
        ∀ i, K.mulVec (rs i) = (A * B).mulVec (rs i)} : ℚ) /
      (Fintype.card (Fin t → Fin p → ZMod q) : ℚ))
      ≤ (1 : ℚ) / q ^ t
```

But I strongly recommend proving it through a sharper intermediate theorem that exposes the true mechanism:

```lean
theorem freivalds_amplified_accepting_card
    {q m n p t : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q)) :
    Fintype.card {rs : Fin t → (Fin p → ZMod q) //
      ∀ i, K.mulVec (rs i) = (A * B).mulVec (rs i)}
    =
    (Fintype.card {r : Fin p → ZMod q //
      K.mulVec r = (A * B).mulVec r}) ^ t
```

together with the single-trial bound

```lean
theorem freivalds_single_trial_soundness_card
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) :
    Fintype.card {r : Fin p → ZMod q //
      K.mulVec r = (A * B).mulVec r}
    ≤ q ^ (p - 1)
```

and the search-space cardinality identity

```lean
theorem freivalds_trial_space_card
    {q p t : ℕ} :
    Fintype.card (Fin t → Fin p → ZMod q) = q ^ (t * p)
```

From these, the probability theorem should fall with routine arithmetic:
\[
\frac{q^{t(p-1)}}{q^{tp}} = q^{-t} = \frac{1}{q^t}.
\]

If the exact exponent arithmetic with `p - 1` becomes annoying in Lean, an alternative but mathematically equivalent route is to prove

```lean
theorem freivalds_single_trial_fraction_bound
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) :
    ((Fintype.card {r : Fin p → ZMod q //
        K.mulVec r = (A * B).mulVec r} : ℚ) /
      (Fintype.card (Fin p → ZMod q) : ℚ))
      ≤ (1 : ℚ) / q
```

and then amplify multiplicatively across `t`.

This latter route may be cleaner formally.

---

## Why This Is a Breakthrough

Freivalds is the canonical example of a randomized linear-algebra verifier. But the real theorem is not “Freivalds works.” The real theorem is:

> **independent algebraic tests amplify multiplicatively because their accepting transcript set is a product of kernels of nonzero linear maps over finite fields.**

Formalizing that statement in Lean turns a one-off algorithm proof into a **general reusable amplification engine**.

This would immediately suggest future formalizations of:

- Schwartz–Zippel repetition
- polynomial identity testing amplification
- randomized fingerprinting for streaming algorithms
- low-degree test repetition
- soundness amplification in interactive proofs
- coding-theoretic detection bounds

In other words, this theorem can become a **library-level abstraction for probabilistic algebraic verification**.

---

## Core Mathematical Insight

Let
\[
D := K - A B.
\]
Then `hne : K ≠ A * B` means `D ≠ 0`. For a vector `r : (Fin p → ZMod q)`, acceptance is
\[
K r = (AB) r \iff D r = 0.
\]
So the accepting set is exactly the kernel of the linear map
\[
r \mapsto D r.
\]

Because `D ≠ 0`, at least one row is nonzero, hence at least one coordinate of `D r` is a nontrivial linear form in `r`. The solution set to one nontrivial linear equation over `𝔽_q` has size exactly `q^{p-1}`; the kernel of the whole map is therefore at most that large. This is the single-trial soundness bound.

For `t` independent trials, the accepting transcript set is
\[
\{(r_1,\dots,r_t) : D r_i = 0 \text{ for all } i\}
= (\ker D)^t,
\]
so its cardinality is the `t`th power of the single-trial accepting set cardinality. Divide by the full trial space size \((q^p)^t\), and the probability decays as \(q^{-t}\).

This is the exact algebraic mechanism to expose in Lean.

---

## Recommended Proof Architecture

### Strategy A: Product-cardinality amplification from single-trial bound
This is the most promising route.

**Step 1.** Prove a single-trial bound via a nonzero row.
- Define `D := K - A * B`.
- Show `D ≠ 0`.
- Extract indices `i j` with `D i j ≠ 0`.
- Consider the linear equation given by row `i`:
  \[
  \sum_j D_{ij} r_j = 0.
  \]
- Show the set of `r` satisfying this equation has cardinality exactly `q^(p-1)` or at least bounds the full accepting set.
- Conclude
  ```lean
  Fintype.card {r // K.mulVec r = (A * B).mulVec r} ≤ q ^ (p - 1)
  ```
  or directly the probability bound `≤ 1 / q`.

**Step 2.** Identify the `t`-trial accepting set with a function space into the single-trial accepting subtype.
Construct an equivalence
```lean
{rs : Fin t → (Fin p → ZMod q) // ∀ i, accept (rs i)}
  ≃ (Fin t → {r : Fin p → ZMod q // accept r})
```
where `accept r := K.mulVec r = (A * B).mulVec r`.

Then use `Fintype.card_fun`:
```lean
Fintype.card (Fin t → α) = (Fintype.card α) ^ t
```

**Step 3.** Divide by the full search-space cardinality and simplify.
Use
```lean
Fintype.card (Fin t → Fin p → ZMod q) = (q ^ p) ^ t
```
or equivalent `q^(t*p)` form. Then apply monotonicity of powers and field arithmetic over `ℚ`.

**Why Strategy A is best**:
- It modularizes the argument into algebra + combinatorics.
- It avoids heavier linear algebra dimensions if not needed.
- It creates reusable lemmas about product acceptance spaces.

---

### Strategy B: Linear-map/kernel dimension route
This is conceptually elegant and may yield stronger reusable abstractions if Mathlib support is sufficient.

**Step 1.** Package `mulVec` by `D` as a linear map
```lean
(Fin p → ZMod q) →ₗ[ZMod q] (Fin m → ZMod q)
```
and identify the accepting set with its kernel.

**Step 2.** Use rank-nullity or dimension bounds.
Since `D ≠ 0`, the linear map is nonzero, so its kernel has dimension at most `p - 1`. Therefore
\[
|\ker D| \le q^{p-1}.
\]

**Step 3.** Use the fact that the `t`-fold independent test is the kernel of the product map or simply the `t`-fold power of the kernel cardinality.

**Why this is exciting**:
- It upgrades Freivalds into a theorem about finite-dimensional vector spaces.
- It points directly toward generalization: any nonzero linear test has soundness at most `1/q`, and repeated tests amplify exponentially.
- It could become the abstraction for many later results.

**Risk**:
- Depending on current Mathlib APIs for finite-dimensional spaces over `ZMod q`, dimension/cardinality transport may be more cumbersome than the elementary row argument.

---

### Strategy C: Fiber-counting via solving for one pivot coordinate
This is the most elementary and may be the easiest to finish if dimension lemmas are missing.

**Step 1.** Extract a nonzero coefficient `D i j ≠ 0`.

**Step 2.** Define a map from assignments to all coordinates except `j` into the unique value of coordinate `j` making the `i`th row equation hold. Since `ZMod q` is a field when `q` is prime, `D i j` is invertible.

**Step 3.** Show every solution is uniquely determined by the remaining `p-1` coordinates, so the row-equation solution set has cardinality exactly `q^(p-1)`, and the full accepting set is a subset.

**Why this is valuable**:
- It avoids rank-nullity machinery.
- It makes the finite-field algebra completely explicit.
- It is ideal for a first formal breakthrough if the library support for matrix kernels is sparse.

---

## Lean 4 Type-Signature Suggestions

To reduce friction, consider introducing these helper definitions:

```lean
def FreivaldsAccept
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (r : Fin p → ZMod q) : Prop :=
  K.mulVec r = (A * B).mulVec r
```

```lean
def FreivaldsAcceptT
    {q m n p t : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (rs : Fin t → Fin p → ZMod q) : Prop :=
  ∀ i, FreivaldsAccept A B K (rs i)
```

Then prove:

```lean
theorem freivalds_accept_equiv_kernel
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (r : Fin p → ZMod q) :
    FreivaldsAccept A B K r ↔ (K - A * B).mulVec r = 0
```

and

```lean
theorem freivalds_accepting_tuples_equiv
    {q m n p t : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q)) :
    {rs : Fin t → (Fin p → ZMod q) // ∀ i, FreivaldsAccept A B K (rs i)}
      ≃
    (Fin t → {r : Fin p → ZMod q // FreivaldsAccept A B K r})
```

This equivalence is likely to be the key combinatorial hinge.

---

## How to Build on Catalog Theorems

The injected catalog is heterogeneous, but there is still a conceptual opportunity: use the existing cardinality-growth lemmas as **proof-pattern precedents** for product spaces and exponential growth/decay.

1. `search_space_has_exp`
   - Use it as a model for proving that function spaces over finite domains have exponential cardinality.
   - Even if not directly reusable, imitate its handling of `Fintype.card` and exponentiation normalization.

2. `factoring_space_grows_with_product`
   - This theorem likely encodes a “product structure implies multiplicative/exponential size” principle.
   - Recast the repeated Freivalds acceptance space as a product object and follow the same cardinality decomposition philosophy.

3. `cocycle_space_cardinality_bound`
   - This is especially suggestive: a constrained algebraic space with a global cardinality bound.
   - The accepting set here is exactly such a constrained algebraic object, namely a kernel / solution space to linear equations.
   - Study how that theorem formalizes “equational constraints reduce cardinality.”

4. `info_decays_with_depth`
   - Conceptual analogy only, but important for the writeup: repeated independent verification causes exponential decay, just as repeated transformations can force information contraction.
   - Use this cross-domain analogy in the final documentation and theorem commentary.

Even if these theorems are not imported directly, your formal development should consciously mirror their style: **product decomposition, exponent laws, constrained-space bounds, decay under repetition**.

---

## Cross-Domain Connections You Should Explicitly Surface

This project becomes much more important if you frame it as a prototype for the following bridges:

### 1. Complexity Theory / Interactive Proofs
Repeated Freivalds trials are the finite-algebra analogue of **parallel repetition** and **soundness amplification**. A successful formalization here suggests later formal proofs of:
- repetition for one-sided randomized verifiers
- amplification of polynomial identity tests
- algebraic PCP soundness reduction

### 2. Coding Theory
Acceptance means a random probe misses an error pattern. Repetition reduces false acceptance exponentially, exactly like repeated parity checks or syndrome tests reducing undetected error probability.

### 3. Cryptography
This is structurally close to:
- linear fingerprinting
- batch verification
- random linear checks in SNARK/STARK preprocessing
- probabilistic proof-of-correctness certificates

A polished theorem here could seed future formalizations of soundness in cryptographic protocols.

### 4. Information Theory
Each independent trial extracts one unit of algebraic evidence against a false claim; the residual acceptance probability decays exponentially. This is a finite-field version of information contraction under repeated independent observations.

### 5. Quantum / Statistical Analogies
The acceptance event is a repeated projection into a kernel. Independent repetition shrinks the surviving state space multiplicatively, reminiscent of:
- repeated projective filtering
- partition function suppression under constraints
- entropy loss under independent consistency checks

These analogies are not decorative. They suggest a future generalized theorem: **independent constraint application causes exponential collapse of admissible state volume**.

---

## Technical Lemmas Likely Needed

Expect to prove some of the following helper results:

```lean
theorem matrix_ne_iff_exists_entry_ne
    {m p : ℕ} {M N : Matrix (Fin m) (Fin p) (ZMod q)} :
    M ≠ N ↔ ∃ i j, M i j ≠ N i j
```

```lean
theorem nonzero_matrix_has_nonzero_row
    {m p : ℕ} {D : Matrix (Fin m) (Fin p) (ZMod q)} :
    D ≠ 0 → ∃ i, ∃ j, D i j ≠ 0
```

```lean
theorem row_equation_solution_card_le
    {q p : ℕ} [Fact q.Prime]
    (a : Fin p → ZMod q)
    (hane : ∃ j, a j ≠ 0) :
    Fintype.card {r : Fin p → ZMod q // ∑ j, a j * r j = 0} ≤ q ^ (p - 1)
```

```lean
theorem accepting_set_sub_row_solution_set
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (i : Fin m) :
    {r : Fin p → ZMod q // K.mulVec r = (A * B).mulVec r}
      ↪
    {r : Fin p → ZMod q // ((K - A * B).mulVec r) i = 0}
```

Also useful:
- cardinality of `Fin p → ZMod q` is `q^p`
- cardinality of `Fin t → α` is `(card α)^t`
- `ZMod q` is a field under `[Fact q.Prime]`
- exponent simplification lemmas over `ℚ`, `ℕ`

---

## What Would Make This Truly Elegant

The strongest version would abstract away from matrices entirely:

```lean
theorem repeated_linear_test_soundness
    {q p m t : ℕ} [Fact q.Prime]
    (L : (Fin p → ZMod q) →ₗ[ZMod q] (Fin m → ZMod q))
    (hL : L ≠ 0) :
    ((Fintype.card {rs : Fin t → (Fin p → ZMod q) //
        ∀ i, L (rs i) = 0} : ℚ) /
      (Fintype.card (Fin t → Fin p → ZMod q) : ℚ))
      ≤ (1 : ℚ) / q ^ t
```

Then derive Freivalds as the corollary with `L := mulVecLin (K - A * B)`.

If feasible, this is the field-opening version. It would establish a general theorem schema for algebraic randomized verifiers.

---

## Deliverable Expectations

1. Prove the main theorem with minimal sorry.
2. If the final exact theorem above is too rigid, prove the strongest equivalent formulation you can fully formalize:
   - exact accepting-cardinality factorization
   - single-trial probability bound
   - then amplified probability bound
3. Factor the proof into reusable lemmas, not one monolithic argument.
4. Add theorem comments explaining the probabilistic meaning of the cardinality ratio.

---

## Application Keywords

Freivalds algorithm, soundness amplification, randomized verification, finite fields, kernel cardinality, linear algebra over `ZMod`, product-space counting, probabilistic proof systems, interactive proofs, polynomial identity testing, fingerprinting, coding theory, cryptographic verification, formal complexity theory, derandomization interfaces.

---

## FUTURE_DIRECTIONS.md Requirement

You must also produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps at breakthrough level. Include specific theorem statements or formalization targets, not vague themes. At least three of the following should appear:

1. **General linear-test amplification**
   - Formalize the abstract theorem for arbitrary nonzero linear maps over finite fields, with Freivalds as a corollary.

2. **Schwartz–Zippel amplification**
   - Prove that repeated random evaluation of a nonzero multivariate polynomial over `ZMod q` yields failure probability at most `(d/q)^t`.

3. **Streaming fingerprint soundness**
   - Formalize the amplification of random linear fingerprints for equality / matrix product / polynomial identity in streaming models.

4. **One-sided verifier library**
   - Create a reusable Lean framework for one-sided randomized algorithms with independent repetition and exact soundness composition theorems.

5. **Interactive-proof bridge**
   - Formalize a finite-cardinality analogue of parallel repetition for simple algebraic verifiers, using the Freivalds theorem as the base case.

Be bold: the right outcome is not merely “Freivalds with repetition,” but a reusable formal language for **exponential suppression of false algebraic witnesses**.

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

Research domain: EML
Research mode: prove
