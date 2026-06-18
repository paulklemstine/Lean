## Assignment: 5. Streaming/Interactive Verification Protocol

**Mode**: prove

Prove a genuinely new theorem package that turns algebraic matrix-product checking into a formally verified **streaming interactive verification protocol** over `ZMod q`, with exact space accounting at the level of maintained state. The immediate target is not merely the tautological equivalence
`(K - A * B).mulVec r = 0 ↔ K.mulVec r = (A * B).mulVec r`,
but a **soundness architecture**: if `K ≠ A * B`, then the set of challenges `r` accepted by the verifier is a proper codimension-1 kernel, hence acceptance probability is at most `1 / q` once a nonzero discrepancy row is exposed. This is the algebraic heart of Freivalds-style verification, but the breakthrough here is to formalize it in Lean as a **streaming certificate theorem** rather than as a one-shot linear algebra lemma.

The revolutionary point is that this creates a bridge between:
- formal linear algebra over finite fields,
- randomized verification / interactive proofs,
- streaming algorithms with sublinear memory,
- and eventually PCP/SNARK-style algebraic checking in Mathlib-compatible foundations.

This is the seed of a formal complexity-theoretic library in Lean where “algorithm” and “proof of soundness” are literally the same object.

---

## Core theorem targets

You should formalize the verifier state and prove both the algebraic invariant and the probabilistic/small-kernel soundness consequence.

### 1. Streaming verifier state

A more operational definition is needed than the current structure. The verifier should store:
- the random challenge `r : Fin p → ZMod q`,
- the compressed right witness `br : Fin n → ZMod q := B.mulVec r`,
- the running discrepancy `state : Fin m → ZMod q`, intended to equal `A.mulVec br - K.mulVec r`.

A good formal target is:

```lean
structure StreamingVerifier (q m n p : ℕ) [Fact q.Prime] where
  r     : Fin p → ZMod q
  br    : Fin n → ZMod q
  state : Fin m → ZMod q
```

Then define a specification predicate:

```lean
def StreamingVerifier.IsValid
    {q m n p : ℕ} [Fact q.Prime]
    (V : StreamingVerifier q m n p)
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q)) : Prop :=
  V.br = B.mulVec V.r ∧
  V.state = A.mulVec V.br - K.mulVec V.r
```

This exposes the true streaming invariant: the verifier never stores `B` or `K` in full compressed form, only `r`, `br`, and `state`, so memory is `O(p + n + m)` in the static formalization, and in the row-streaming implementation the active memory can be driven toward `O(m + p)` depending on how `br` is produced.

---

## Precise theorem statements with Lean 4 targets

### Theorem A: algebraic invariant / acceptance criterion

This is the cleaned-up algebraic core of your current target.

```lean
theorem streaming_verifier_accept_iff
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (r : Fin p → ZMod q) :
    (K - A * B).mulVec r = 0 ↔ K.mulVec r = (A * B).mulVec r
```

This theorem is exact, useful, and should be proved with matrix-vector linearity lemmas:
- `Matrix.sub_mulVec`
- `Matrix.mul_mulVec`
- additive group cancellation in `Fin m → ZMod q`

If Mathlib names differ, adapt to the available API around `Matrix.mulVec`, `Matrix.mul`, and extensionality on `Fin`.

---

### Theorem B: nonzero discrepancy yields a nontrivial linear functional

The actual soundness engine is not the equivalence above, but the existence of a nonzero row functional when `K ≠ A * B`.

```lean
theorem exists_nonzero_discrepancy_row
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) :
    ∃ i : Fin m, K i ≠ (A * B) i
```

Here `K i` and `(A * B) i` are row functions `Fin p → ZMod q`. This is a simple but indispensable extensionality lemma: matrix inequality implies existence of an index with unequal rows. It is the exact pivot from matrix inequality to a one-row linear test.

---

### Theorem C: kernel bound for a nonzero row over a field

This is the genuinely nontrivial theorem that makes the protocol sound.

Let `v : Fin p → ZMod q` be nonzero. Then the map `r ↦ ∑ j, v j * r j` is not identically zero. Over a prime field, if one coordinate of `v` is nonzero, then for every assignment to the other `p-1` coordinates, there is exactly one choice of the remaining coordinate that makes the dot product vanish. Hence the number of accepting challenges is `q^(p-1)`.

A powerful finite-set version is:

```lean
theorem card_zero_set_dot_eq
    {q p : ℕ} [Fact q.Prime]
    (v : Fin p → ZMod q)
    (hv : v ≠ 0) :
    Fintype.card {r : Fin p → ZMod q // dotProduct v r = 0} = q ^ (p - 1)
```

If this exact cardinality is too heavy for the first pass, prove the softer but already breakthrough-grade bound:

```lean
theorem exists_coordinate_nonzero_of_ne_zero
    {q p : ℕ} [Fact q.Prime]
    (v : Fin p → ZMod q)
    (hv : v ≠ 0) :
    ∃ j : Fin p, v j ≠ 0
```

and then:

```lean
theorem dot_zero_set_card_le
    {q p : ℕ} [Fact q.Prime]
    (v : Fin p → ZMod q)
    (hv : v ≠ 0) :
    Fintype.card {r : Fin p → ZMod q // dotProduct v r = 0} ≤ q ^ (p - 1)
```

This is already enough to formalize one-sided error at most `1/q` under uniform random choice of `r`.

---

### Theorem D: matrix-product streaming soundness bound

This is the flagship theorem.

```lean
theorem streaming_verifier_soundness_bound
    {q m n p : ℕ} [Fact q.Prime] [Fintype (Fin p)]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) :
    Fintype.card {r : Fin p → ZMod q // K.mulVec r = (A * B).mulVec r}
      ≤ q ^ (p - 1)
```

Equivalent probabilistic phrasing, if you build finite uniform probability later:

```lean
theorem streaming_verifier_accept_prob_le
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) :
    ((Fintype.card {r : Fin p → ZMod q // K.mulVec r = (A * B).mulVec r} : ℚ)
      / q ^ p) ≤ (1 : ℚ) / q
```

Even if the rational probability theorem is deferred, the cardinality theorem is already a major formal milestone.

---

## Why this is a breakthrough

This is not “yet another matrix lemma.” It is the first step toward a **formal complexity theory of randomized algebraic verification** in Lean:
- Freivalds’ algorithm becomes a theorem schema.
- Streaming verification becomes a certified protocol, not just an implementation idea.
- The linear-algebraic soundness proof becomes reusable for low-degree testing, polynomial identity testing, sketching, and interactive proof systems.
- Once this scaffold exists, one can formalize:
  - sum-check,
  - fingerprinting for streaming equality and moment estimation,
  - rank verification,
  - delegated linear algebra,
  - and eventually PCP/SNARK-inspired algebraic protocols.

This opens a new field inside formalized mathematics: **certified probabilistic complexity**.

---

## Proof strategy architecture

### Strategy A: Row-separation + kernel counting via explicit pivot coordinate
This is the most promising route.

1. **Algebraic reduction**  
   Use `hne : K ≠ A * B` to obtain a row `i : Fin m` with
   `v := fun j => K i j - (A * B) i j` nonzero.
   Show that if `(K - A * B).mulVec r = 0`, then in particular
   `dotProduct v r = 0`.

2. **Choose a pivot coordinate**  
   From `v ≠ 0`, choose `j₀ : Fin p` with `v j₀ ≠ 0`.
   Since `ZMod q` is a field when `q` is prime, solve uniquely for `r j₀` in terms of the other coordinates. This shows the zero set of `dotProduct v` has cardinality exactly `q^(p-1)`.

3. **Lift row bound to matrix bound**  
   The acceptance set for the whole matrix is contained in the zero set for that single nonzero row functional. Therefore its cardinality is at most `q^(p-1)`.

**Why this is best:** it avoids heavy abstract linear algebra and uses only explicit finite-field algebra plus `Fin` combinatorics. It should be robust in Lean.

---

### Strategy B: Linear map rank-nullity over finite vector spaces
This is more conceptual and may yield stronger reusable infrastructure.

1. Define the discrepancy matrix
   `D := K - A * B`.
2. If `D ≠ 0`, then the linear map `φ : (Fin p → ZMod q) →ₗ[ZMod q] (Fin m → ZMod q)` given by `φ r = D.mulVec r` is nonzero.
3. A nonzero linear map into any vector space has kernel of codimension at least `1`; hence over the finite field `ZMod q`, the kernel has size at most `q^(p-1)`.

**Why it is powerful:** this generalizes immediately to arbitrary finite-dimensional codomains and becomes the basis for many algebraic proof systems.

**Why it is harder:** it requires more infrastructure around finite-dimensional vector spaces, dimensions of function spaces on `Fin`, and cardinality of finite subspaces.

---

### Strategy C: Streaming invariant first, soundness second
This is the protocol-oriented route.

1. Define an update semantics for processing rows/entries of `B` into `br = B.mulVec r`, and then rows of `A` and `K` into `state`.
2. Prove by induction on the stream that the final state equals
   `A.mulVec (B.mulVec r) - K.mulVec r`.
3. Only then invoke Strategy A to prove that if `K ≠ A * B`, acceptance is rare.

**Why it matters:** this turns the algebraic theorem into an actual streaming protocol theorem, not just a matrix identity.  
**Why it is second-stage:** operational semantics may cost time; first secure the algebraic soundness core.

---

## Concrete build plan in Lean

### Phase 1: algebraic identities
Prove the basic equalities around `mulVec`:
- `(K - A * B).mulVec r = K.mulVec r - (A * B).mulVec r`
- `(A * B).mulVec r = A.mulVec (B.mulVec r)`

These should reduce Theorem A to additive cancellation.

### Phase 2: matrix inequality gives nonzero row
Prove extensionality contrapositive:
- if every row agrees, matrices agree.
Then derive `exists_nonzero_discrepancy_row`.

### Phase 3: one nonzero row implies at most `q^(p-1)` accepting challenges
This is the key technical component. You may need helper lemmas:
- a nonzero function `v : Fin p → ZMod q` has a nonzero coordinate,
- nonzero elements in `ZMod q` are units when `q` is prime,
- solving a linear equation in one variable over a field is unique.

### Phase 4: package as streaming verifier theorem
Add the structure and invariant theorem, then derive the soundness bound for accepted challenges.

---

## Cross-domain connections you should explicitly exploit

1. **Interactive proofs / complexity theory**  
   This theorem is a finite-field avatar of one-round public-coin verification. The challenge vector `r` is the verifier’s randomness; the state is a sketch. Formalizing this in Lean opens the path to verified IP=PSPACE toy models and algebraic proof systems.

2. **Coding theory / fingerprinting**  
   The acceptance condition is a linear fingerprint collision event. The same kernel-counting lemma underlies Reed–Solomon fingerprinting, hash-based equality testing, and linear sketch soundness.

3. **Streaming algorithms**  
   The verifier stores only a compressed state, not the whole product. This is the essence of sublinear-space certification. A formal theorem here can seed certified lower/upper-bound experiments in Lean.

4. **Finite geometry**  
   The set `{r | dotProduct v r = 0}` is a hyperplane in `𝔽_q^p`. The soundness bound is a finite projective geometry statement in disguise. If formalized elegantly, it will support future work on incidence bounds and finite-field combinatorics.

5. **Formal cryptography / SNARK precursors**  
   Matrix-product checks are among the simplest algebraic consistency tests. Once the hyperplane soundness lemma exists, it can be repurposed for polynomial identity testing, vector commitments, and succinct proof gadgets.

---

## Suggested theorem dependencies from the catalog

The catalog theorem
- `product_verification_sound`  
  from `Algebra/GravitationalFactoring/CausalCertification.lean`

is the obvious conceptual anchor. Do not merely cite it: inspect whether it already contains a list-based or combinatorial soundness principle for product checking, and **lift it into the matrix-over-`ZMod q` setting** with `Matrix.mulVec` semantics. If it is weaker or differently typed, use it as the prototype for the final theorem statement and naming scheme.

The theorem
- `zmod_prime_idempotent_iff`

signals that there is already some nontrivial `ZMod p` prime-field infrastructure in the codebase. Reuse its prime-field lemmas, especially any existing facts that make nonzero elements invertible or identify field structure cleanly under `[Fact q.Prime]`.

The other listed theorems are likely not directly relevant mathematically, and you should resist forcing connections unless they expose reusable finite-field tactics or proof patterns.

---

## Minimal theorem package to land in this cycle

At minimum, deliver:

1. `streaming_verifier_accept_iff`
2. `exists_nonzero_discrepancy_row`
3. one of:
   - `dot_zero_set_card_le`, or
   - `streaming_verifier_soundness_bound`
4. a `StreamingVerifier` structure with `IsValid` specification
5. a theorem identifying the final state with the discrepancy action:
   ```lean
   theorem StreamingVerifier.state_eq_discrepancy_mulVec
       {q m n p : ℕ} [Fact q.Prime]
       (V : StreamingVerifier q m n p)
       (A : Matrix (Fin m) (Fin n) (ZMod q))
       (B : Matrix (Fin n) (Fin p) (ZMod q))
       (K : Matrix (Fin m) (Fin p) (ZMod q))
       (hV : V.IsValid A B K) :
       V.state = (A * B - K).mulVec V.r ∨ V.state = (K - A * B).mulVec V.r
   ```
   Pick one sign convention and keep it consistent.

That package is already field-opening if done cleanly.

---

## If exact probability is too ambitious

Then prove the deterministic implication:

```lean
theorem streaming_verifier_complete
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (r : Fin p → ZMod q) :
    (A * B).mulVec r = (A * B).mulVec r
```

and combine it with the nonzero-row theorem plus a **non-surjectivity / proper subset** result:

```lean
theorem accepts_on_proper_subset_of_challenges
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) :
    ∃ r_bad : Fin p → ZMod q, K.mulVec r_bad ≠ (A * B).mulVec r_bad
```

This is weaker than the `1/q` bound, but still nontrivial and sets up the full soundness theorem.

---

## Implementation notes

- Expect to use `Matrix.ext`, function extensionality, and `Finset` sums.
- If `dotProduct` interoperability with row functions is awkward, define a local helper:
  ```lean
  def rowDot {q p : ℕ} [Fact q.Prime]
      (v r : Fin p → ZMod q) : ZMod q :=
    ∑ j, v j * r j
  ```
- Be careful about whether rows are exposed as functions or vectors; in Lean, the function model `Fin p → ZMod q` is often the path of least resistance.
- Use explicit `have` blocks for matrix-entry formulas of `mulVec`.
- If cardinality over subtype is painful, first characterize the zero set by an equivalence with functions on `Fin (p-1)` after solving for one coordinate.

---

## Application keywords

Freivalds algorithm; streaming verification; interactive proofs; randomized linear algebra; finite fields; matrix fingerprinting; algebraic complexity; certified probabilistic verification; finite geometry; linear sketches; formal complexity theory; proof-carrying computation; algebraic soundness; Lean 4 Mathlib; sublinear-space verification.

---

## Deliverables

1. Lean file(s) containing the theorem package above with minimized `sorry`.
2. Clear comments marking which theorem is the algebraic invariant and which theorem is the soundness bound.
3. A short note in comments on the exact memory interpretation of the verifier state.
4. **A structured `FUTURE_DIRECTIONS.md` with 3–5 concrete breakthrough next steps**, for example:
   - formalize exact acceptance probability `= 1/q` for nonzero rank-1 discrepancy,
   - generalize from matrix product to polynomial identity testing,
   - build a verified sum-check protocol over `ZMod q`,
   - formalize streaming fingerprinting for equality and frequency moments,
   - connect kernel-size lemmas to finite affine geometry in Mathlib.

Do not settle for the equivalence theorem alone. The real target is the hyperplane-soundness theorem that turns matrix discrepancy into a codimension-1 event. That is the conceptual leap.

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
