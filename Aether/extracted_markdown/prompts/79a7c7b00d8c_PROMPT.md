## Assignment: Construct an encoding family with prescribed tropical factor rank

**Mode:** prove

Build a genuinely new theorem family, not an incremental lemma: construct an explicit encoding
\[
\mathrm{encode} : \mathbb{N} \to \bigsqcup_n \mathrm{Mat}_{n\times n}(\mathbb{T})
\]
whose tropical factor rank is *exactly* the encoded integer. The goal is not merely an upper bound construction, but a sharp realization theorem with a formal lower-bound argument robust enough to become reusable infrastructure.

The breakthrough target is to show that tropical factor rank can serve as an **exact discrete information carrier**. This would turn factor rank from a hard-to-compute invariant into a formally certified encoding mechanism, opening a bridge from tropical linear algebra to complexity theory, coding, and cryptographic hardness certificates.

---

## Precise theorem target

Work over tropical matrices with entries in `WithTop ℤ`, using min-plus conventions already natural in Mathlib-style tropical developments.

The central statement should be an explicit realization theorem of the following form:

```lean
def tropMat (n : ℕ) := Matrix (Fin n) (Fin n) (WithTop ℤ)

def encode : ℕ → Σ n : ℕ, tropMat n
```

with theorem:

```lean
theorem tropFactorRank_encode_exact :
  ∀ s : ℕ, tropFactorRank ((encode s).2) = s
```

A more implementation-friendly strengthened version is preferable:

```lean
def encodeDiag (s : ℕ) : tropMat s := fun i j =>
  if h : i = j then (0 : WithTop ℤ) else ⊤

theorem tropFactorRank_encodeDiag :
  ∀ s : ℕ, tropFactorRank (encodeDiag s) = s
```

and then package it into a sigma-type encoding:

```lean
def encode (s : ℕ) : Σ n : ℕ, tropMat n := ⟨s, encodeDiag s⟩

theorem tropFactorRank_encode_exact :
  ∀ s : ℕ, tropFactorRank ((encode s).2) = s
```

If the exact diagonal theorem is too optimistic given the current library notion of `tropFactorRank`, then prove the block-diagonal variant:

```lean
def rankOneBlock : tropMat 1 := fun _ _ => (0 : WithTop ℤ)

def encodeBlock (s : ℕ) : tropMat s := encodeDiag s

theorem tropFactorRank_encodeBlock_exact :
  ∀ s : ℕ, tropFactorRank (encodeBlock s) = s
```

The conceptual theorem is:

> For every natural number `s`, there exists a finite tropical matrix `A` such that `tropFactorRank A = s`.

But do not stop there. The *real* result is the explicit family with exact formula.

---

## Why this is a breakthrough

Shitov-style hardness tells us tropical factor rank is globally difficult to compute. That is exactly why an explicit, certified realization family matters: it isolates a regime where the invariant is not only computable, but **designed**. This changes the role of factor rank from a passive invariant to an active encoding primitive.

This opens at least four directions immediately:

1. **Complexity-theoretic calibration:** exact witnesses for all ranks become benchmark instances for tropical rank algorithms and lower-bound frameworks.
2. **Tropical coding theory:** messages encoded by factor-rank level sets suggest rank-based error models and decoding invariants.
3. **Cryptographic hardness interfaces:** one can distinguish “easy structured rank instances” from “generic hard instances,” a useful formal contrast for post-quantum tropical constructions.
4. **Algebraic geometry/combinatorics:** exact factor-rank strata become concrete test objects for tropical secant varieties and Barvinok/Schein rank phenomena.

---

## Lean 4 formalization target

You should aim to introduce the following definitions and theorem suite, adapted to the existing library conventions for tropical matrices:

```lean
def tropMat (n : ℕ) := Matrix (Fin n) (Fin n) (WithTop ℤ)

def tropicalIdentityLike (n : ℕ) : tropMat n := fun i j =>
  if i = j then (0 : WithTop ℤ) else ⊤

def encodeDiag (s : ℕ) : tropMat s := tropicalIdentityLike s

theorem tropFactorRank_le_dim
  (n : ℕ) (A : tropMat n) :
  tropFactorRank A ≤ n

theorem tropFactorRank_identity
  (n : ℕ) :
  tropFactorRank (tropicalIdentityLike n) = n

theorem tropFactorRank_diagonal
  (n : ℕ) (d : Fin n → WithTop ℤ)
  (hsep : ∀ i j, i ≠ j → ...)
  :
  tropFactorRank (Matrix.diagonal d) = Nat.card {i // d i ≠ ⊤}
```

If the exact diagonal statement above is too strong in current infrastructure, narrow it to the identity-like tropical diagonal:

```lean
theorem tropFactorRank_identity_like
  (n : ℕ) :
  tropFactorRank (fun i j : Fin n => if i = j then (0 : WithTop ℤ) else ⊤) = n
```

and then derive the encoding theorem.

---

## Most promising proof architecture

### Strategy A: Exact diagonal rigidity via support separation
This is the most promising route.

**Step 1: Upper bound.**  
Show `tropFactorRank (encodeDiag s) ≤ s` by exhibiting an explicit decomposition into `s` tropical rank-1 matrices, one per diagonal position. Each rank-1 term should place `0` at one diagonal entry and `⊤` elsewhere, so the tropical sum recovers the diagonal identity-like matrix.

**Step 2: Lower bound by incompatibility of off-diagonal infinities.**  
Prove that any tropical rank-1 matrix contributing to a matrix with all off-diagonal entries equal to `⊤` can support at most one finite diagonal position. Intuition: a rank-1 matrix with finite values at two diagonal positions necessarily induces a finite off-diagonal entry by separability of the form `u i + v j`. Therefore, covering `s` finite diagonal entries requires at least `s` rank-1 summands.

**Step 3: Conclude exactness.**  
Combine the explicit `≤ s` decomposition with the rigidity lemma `s ≤ tropFactorRank (encodeDiag s)`.

This route is powerful because it turns the lower bound into a clean combinatorial obstruction. It should also generalize later to weighted diagonals, sparse support patterns, and tropical communication complexity.

---

### Strategy B: Block-diagonal additivity framework
This is slightly more ambitious but potentially more reusable.

**Step 1: Prove subadditivity under tropical block sum.**  
Define a block-diagonal matrix constructor and show
```lean
tropFactorRank (blockDiag A B) ≤ tropFactorRank A + tropFactorRank B
```
by concatenating decompositions.

**Step 2: Prove lower bound for separated blocks.**  
Show that if off-block entries are `⊤`, then any rank-1 summand can effectively interact with at most one block unless it creates forbidden finite cross-block entries. This gives
```lean
tropFactorRank (blockDiag A B) ≥ tropFactorRank A + tropFactorRank B
```
for suitably separated blocks.

**Step 3: Iterate rank-1 one-by-one blocks.**  
Take `encode s` to be the block diagonal of `s` copies of a `1×1` finite matrix. Then additivity yields exact rank `s`.

This strategy is more structural than Strategy A. If it works, it creates a full theorem schema for exact factor-rank additivity on separated tropical supports. That would be a deeper contribution than the encoding theorem alone.

---

### Strategy C: Boolean support reduction
This is a cross-domain route through combinatorics.

**Step 1: Pass from tropical matrix to its finiteness pattern.**  
For the identity-like matrix, the support is exactly the equality relation on `Fin s`.

**Step 2: Prove a support-cover lower bound.**  
A tropical rank-1 matrix has support of rectangular form
\[
S = U \times V
\]
on finite entries. If such a rectangle contains two diagonal points `(i,i)` and `(j,j)` with `i ≠ j`, then it also contains off-diagonal points `(i,j)` and `(j,i)`, impossible for the identity support.

**Step 3: Deduce rectangle covering number = `s`.**  
Thus the diagonal support requires at least `s` rectangles, giving a lower bound on factor rank. The upper bound comes from `s` singleton rectangles.

This route connects tropical factor rank to communication complexity and Boolean rectangle covers. It is conceptually beautiful and could seed a whole new formal interface between tropical algebra and complexity theory.

---

## Recommended path

Start with **Strategy A**, because it is the most direct and likely to formalize cleanly in Lean with minimal library overhead. Then, if time permits, abstract the argument into **Strategy B** as a reusable block-additivity theorem. Strategy C should inform the combinatorial shape of the lower-bound lemma even if you do not fully formalize the communication-complexity language yet.

---

## Key lemmas to formalize

You already identified the right backbone, but they need sharper formulations.

### 1. Upper bound by explicit decomposition
```lean
theorem tropFactorRank_le_dim
  (n : ℕ) (A : tropMat n) :
  tropFactorRank A ≤ n
```
For the encoding theorem, it is even better to prove a specialized constructive upper bound:
```lean
theorem tropFactorRank_encodeDiag_le
  (s : ℕ) :
  tropFactorRank (encodeDiag s) ≤ s
```

### 2. Rank-1 rigidity on diagonal support
This is the decisive new lemma.
```lean
theorem tropRankOne_diagonal_support_singleton
  (s : ℕ) (u v : Fin s → WithTop ℤ)
  (hdiag : ∀ i, u i + v i ≠ ⊤ → True)
  (hoff : ∀ i j, i ≠ j → u i + v j = ⊤) :
  #{i | u i + v i ≠ ⊤} ≤ 1
```
You may need to adapt this to the exact rank-1 representation used by `tropFactorRank`. The mathematical content is:

> A tropical rank-1 matrix whose off-diagonal entries are all `⊤` can have at most one finite diagonal entry.

This is the lower-bound engine.

### 3. Exact factor rank of the tropical identity-like matrix
```lean
theorem tropFactorRank_identity
  (s : ℕ) :
  tropFactorRank (encodeDiag s) = s
```

### 4. Optional stronger diagonal theorem
If feasible, prove a weighted version:
```lean
def weightedDiag {n : ℕ} (d : Fin n → WithTop ℤ) : tropMat n :=
  fun i j => if i = j then d i else ⊤

theorem tropFactorRank_weightedDiag
  (n : ℕ) (d : Fin n → WithTop ℤ) :
  tropFactorRank (weightedDiag d) = Nat.card {i // d i ≠ ⊤}
```
This would be substantially more powerful: it identifies factor rank exactly with the number of finite diagonal entries.

---

## How to build on existing verified theorems

Use the catalog results not because they are directly about factor rank, but because they establish a pattern: the repository already supports **tropical quantitative invariants with exact or sharp bounds**.

- `tropical_rank_le_dim` from `Tropical/Core/HashInversion.lean` is the most relevant structural analogue. Even if it concerns tropical rank rather than factor rank, mirror its proof architecture, indexing style, and matrix conventions. Reuse its dimension-control patterns and finite-index manipulations.
- `tropical_depth_lower_bound` and `tropical_key_space_lower_bound` signal a broader direction: tropical objects can certify lower bounds relevant to complexity and cryptography. Your theorem should be framed as the linear-algebraic analogue of these certified lower bounds.
- `tropical_product_to_sum` and `tropical_gcd_lcm_identity` show that the codebase is already comfortable with tropicalization as a bridge principle. Position the encoding theorem as a new bridge from tropical algebra to discrete information encoding.

So the message is: **import the style and proof engineering of existing tropical bounds, but create a genuinely new invariant-realization theorem.**

---

## Cross-domain connections to emphasize in the development

1. **Communication complexity:**  
   Exact factor-rank lower bounds via rectangle-cover arguments on finiteness support.
2. **Algebraic geometry:**  
   Tropical factor rank relates to tropical secant decompositions and piecewise-linear models of secant varieties.
3. **Combinatorics:**  
   Diagonal support matrices are extremal objects for biclique/rectangle covers.
4. **Cryptography:**  
   Explicit matrices of certified rank give hard/easy instance families, useful for tropical hardness calibration.
5. **Complexity theory:**  
   This gives a formally verified infinite family of instances with exact invariant values, a rarity for NP-hard-style quantities.
6. **Neural and circuit models:**  
   Tropical rank/factor-rank controls expressive complexity in min-plus linear networks; your encoding theorem becomes a width certificate.

---

## Application keywords

`tropical linear algebra`, `factor rank`, `Barvinok rank`, `min-plus algebra`, `communication complexity`, `rectangle covering`, `tropical secant varieties`, `complexity lower bounds`, `cryptographic hardness calibration`, `formalized mathematics`, `Lean 4`, `Mathlib`

---

## Concrete deliverables

1. Define an explicit encoding family `encodeDiag` or `encode`.
2. Prove the exact theorem
   ```lean
   theorem tropFactorRank_encode_exact :
     ∀ s : ℕ, tropFactorRank ((encode s).2) = s
   ```
   or the equivalent diagonal version.
3. Minimize `sorry` by isolating only the genuinely novel combinatorial lower-bound lemma if necessary.
4. If possible, strengthen to weighted diagonals or block-diagonal additivity.
5. Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - exact factor rank of arbitrary sparse diagonal-plus-noise families,
   - block-diagonal additivity theorems,
   - support-based lower bounds via communication complexity,
   - tropical factor-rank coding schemes,
   - comparison theorems between tropical rank and tropical factor rank.

---

## Final charge

Do not treat this as “just another construction.” Treat it as the first formally verified theorem that **programs tropical factor rank exactly**. If you can make the lower bound clean, reusable, and support-theoretic, you are not only solving this problem — you are creating the foundation for a new formal theory of tropical complexity invariants.

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

Research domain: Tropical
Research mode: prove
