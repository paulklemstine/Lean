## Assignment: Geometric (long-term)

Mode: **prove**

Prove a genuinely new theorem in tropical geometry that is both formalizable in Lean 4 and conceptually expansive enough to seed a full tropical-varieties infrastructure. Do **not** settle for a definitional exercise. The target should create a reusable bridge between tropical hypersurfaces, polyhedral combinatorics, and optimization.

### Research Direction
**Tropical varieties via corner loci of tropical polynomials, with a first nontrivial structural theorem in finite dimension.**

The immediate goal is to formalize a robust notion of tropical polynomial on `Fin n → ℕ` exponents with real coefficients, define its evaluation as a max-plus function on `Fin n → ℝ`, define the tropical hypersurface as the locus where the maximum is attained at least twice, and prove a foundational theorem identifying this hypersurface as a union of pairwise linear equality cells. This is the first serious step from isolated tropical identities toward actual tropical geometry.

### Why this would be a breakthrough
Right now the catalog contains isolated tropical lemmas (`max_self`, inequalities, spectral bounds, arithmetic analogies), but not the infrastructure that lets tropical mathematics behave like geometry. The decisive move is to formalize the **corner locus paradigm**:

- tropical polynomial = max of finitely many affine forms,
- tropical hypersurface = nondifferentiability / non-unique argmax locus,
- geometry emerges as a finite polyhedral complex.

Even a first theorem at this level opens an entirely new lane in Lean:
- tropical hypersurfaces,
- tropical convexity,
- tropical Newton polytopes,
- tropical optimization and certified piecewise-linearity,
- bridges to combinatorial geometry, neural network decision boundaries, and max-plus spectral theory.

This is not an incremental variant. It is the point where “tropical calculations” become “tropical spaces.”

---

## Precise theorem target

### Core mathematical statement
Let `σ` be a finite set of tropical monomials in `n` variables, where each monomial is determined by a coefficient `c : ℝ` and exponent vector `α : Fin n → ℕ`. Define
\[
T_\sigma(x) = \max_{m \in \sigma} \left(c_m + \sum_i (\alpha_m(i) : \mathbb R)\, x_i\right).
\]
Define the tropical hypersurface
\[
\mathrm{TropHyp}(\sigma) = \{x \mid \exists m_1 \neq m_2 \in \sigma,\ 
L_{m_1}(x) = L_{m_2}(x) = T_\sigma(x)\}.
\]
Then:
\[
\mathrm{TropHyp}(\sigma)
=
\bigcup_{m_1 \neq m_2 \in \sigma}
\left\{x \mid
L_{m_1}(x)=L_{m_2}(x)\ \land\
\forall m\in\sigma,\ L_m(x)\le L_{m_1}(x)\right\}.
\]
This theorem says the tropical hypersurface is exactly the union of the codimension-1 competition cells where two affine forms tie and dominate all others.

This is the correct first structural theorem because it is:
- nontrivial,
- exact,
- reusable,
- purely finite-dimensional,
- compatible with concrete Lean data structures.

---

## Suggested Lean 4 formalization target

Use concrete finitely supported data first. A good design is to avoid abstract semiring-generalization initially.

### Candidate definitions
```lean
structure TropMonomial (n : ℕ) where
  coeff : ℝ
  exp   : Fin n → ℕ

def TropMonomial.eval {n : ℕ} (m : TropMonomial n) (x : Fin n → ℝ) : ℝ :=
  m.coeff + ∑ i, (m.exp i : ℝ) * x i

def TropPoly (n : ℕ) := Finset (TropMonomial n)

def TropPoly.eval {n : ℕ} (p : TropPoly n) (x : Fin n → ℝ) : ℝ :=
  p.sup' (by
    -- proof polynomial is nonempty in the theorem hypotheses, or use Option/WithBot design
  ) (fun m => m.eval x)

def IsTropRoot {n : ℕ} (p : TropPoly n) (x : Fin n → ℝ) : Prop :=
  ∃ m₁ ∈ p, ∃ m₂ ∈ p, m₁ ≠ m₂ ∧
    m₁.eval x = TropPoly.eval p x ∧
    m₂.eval x = TropPoly.eval p x
```

A cleaner route is to parameterize by a **nonempty finite family**:
```lean
structure NonemptyTropPoly (n : ℕ) where
  terms : Finset (TropMonomial n)
  nonempty : terms.Nonempty
```

Then the principal theorem can be stated as:

```lean
theorem isTropRoot_iff_exists_pairwise_dominating_tie
  {n : ℕ} (p : NonemptyTropPoly n) (x : Fin n → ℝ) :
  IsTropRoot p.terms x ↔
    ∃ m₁ ∈ p.terms, ∃ m₂ ∈ p.terms, m₁ ≠ m₂ ∧
      m₁.eval x = m₂.eval x ∧
      (∀ m ∈ p.terms, m.eval x ≤ m₁.eval x)
```

A second theorem, more geometric and stronger as a destination theorem:

```lean
def PairCell {n : ℕ} (p : NonemptyTropPoly n)
    (m₁ m₂ : TropMonomial n) : Set (Fin n → ℝ) :=
  {x | m₁ ∈ p.terms ∧ m₂ ∈ p.terms ∧ m₁ ≠ m₂ ∧
       m₁.eval x = m₂.eval x ∧
       ∀ m ∈ p.terms, m.eval x ≤ m₁.eval x}

def TropHypersurface {n : ℕ} (p : NonemptyTropPoly n) : Set (Fin n → ℝ) :=
  {x | IsTropRoot p.terms x}

theorem tropHypersurface_eq_iUnion_pairCells
  {n : ℕ} (p : NonemptyTropPoly n) :
  TropHypersurface p =
    ⋃ m₁ ∈ p.terms, ⋃ m₂ ∈ p.terms, PairCell p m₁ m₂
```

If set-level `iUnion` over `Finset` becomes cumbersome, use the existential characterization theorem first; it is already substantial and likely the right Lean milestone.

---

## Stronger theorem if momentum appears
Once the existential characterization is done, aim for the first true “variety-like” theorem:

### Tropical hypersurface is closed
Because each `m.eval` is continuous and the root condition can be expressed by finite unions/intersections of equality and inequality sets of continuous functions, prove:

```lean
theorem isClosed_tropHypersurface
  {n : ℕ} (p : NonemptyTropPoly n) :
  IsClosed (TropHypersurface p)
```

This is a real geometric theorem, not a tautology. It opens topological tropical geometry in Lean.

---

## Proof strategies

### Strategy A: Finset-max characterization via `Finset.mem` and `sup'`
Most direct and probably the best first route.

1. Define evaluation using `Finset.sup'` on the finite set of monomial values.
2. Prove a lemma:
   ```lean
   theorem eval_le_tropEval {n} (p : NonemptyTropPoly n) (m) (hm : m ∈ p.terms) (x) :
     m.eval x ≤ p.terms.sup' p.nonempty (fun t => t.eval x)
   ```
3. Show:
   - if two distinct monomials both attain the supremum, then the pairwise dominating tie condition holds;
   - conversely, if two monomials tie and dominate all terms, then each equals the `sup'`, hence `x` is a tropical root.

**Why this is promising:** it stays entirely within finite combinatorics and order theory. No topology, no convexity, no advanced geometry. It is exactly the kind of theorem Lean likes once definitions are chosen carefully.

---

### Strategy B: Argmax-set formulation
Define the set of maximizing monomials:
```lean
def Maximizers {n : ℕ} (p : NonemptyTropPoly n) (x : Fin n → ℝ) : Finset (TropMonomial n) :=
  p.terms.filter (fun m => m.eval x = TropPoly.eval p.terms x)
```
Then prove:
\[
x \in \mathrm{TropHyp}(p) \iff 2 \le (Maximizers\ p\ x).card.
\]

From there derive the pairwise-cell decomposition by extracting two distinct members of a filtered finset.

**Why this is promising:** conceptually elegant and extensible. It sets up future work on combinatorial types of cells, balancing, and tropical fans. Slightly more infrastructure is needed around filtered finsets and cardinality.

---

### Strategy C: Polyhedral inequality encoding
Rewrite the root condition as a finite union over pairs `(m₁,m₂)` of sets defined by:
- one equality `m₁.eval x = m₂.eval x`,
- finitely many inequalities `m.eval x ≤ m₁.eval x`.

Then prove the characterization by elementary logic alone.

**Why this matters:** this is the right setup for the follow-up theorem that the hypersurface is closed, and eventually polyhedral. It also aligns with optimization language: tropical roots are decision-boundary cells of a max-affine model.

**Most promising overall:** Strategy A first, then package the result in the language of Strategy C. This gives a fast proof and a geometry-ready API.

---

## How to build on catalog theorems

The existing catalog theorems are primitive, but they can still serve as symbolic anchors for a coherent tropical program:

1. `tropical_mirror_theorem` (`max a a = a`)  
   This is the atomic idempotency principle of max-plus algebra. Use it philosophically and notationally: tropical polynomial evaluation is built from repeated max-combinations of affine forms. Your theorem upgrades idempotent algebra from a scalar identity to a geometric decomposition theorem.

2. `tropical_spectral_bound`  
   This suggests existing max-plus linear algebra infrastructure. Connect your tropical hypersurface to max-plus eigenvalue geometry: the pairwise tie loci are the same kind of combinatorial regions that control changes in dominant cycle weights and piecewise-linear spectral behavior.

3. `tropical_young_ineq`  
   This hints at convex duality. Since tropical polynomials are max of affine forms, they are convex piecewise-linear functions. The tropical hypersurface is exactly the nondifferentiability set of such a convex function. This creates a bridge to Fenchel-Legendre theory and subgradient geometry.

4. `tropical_fundamental_theorem_of_arithmetic`  
   Even if far afield, it supports a broader narrative: tropical arithmetic already exists in the catalog; your theorem supplies its geometric avatar. This is the transition from algebraic slogans to actual spaces.

Do not force these into the proof if unnecessary. Use them to shape naming, API, and the writeup so the theorem sits inside a larger tropical ecosystem.

---

## Cross-domain connections to emphasize

### 1. Convex analysis
A tropical polynomial is a finite max of affine functions, hence a convex piecewise-linear map. Its tropical hypersurface is the nondifferentiability locus. This directly links tropical geometry to:
- subdifferentials,
- normal fans,
- Legendre-Fenchel duality.

This is likely the richest conceptual bridge.

### 2. Optimization and machine learning
Max-affine functions are standard in:
- piecewise-linear regression,
- ReLU/maxout architectures,
- robust optimization.

The tropical hypersurface is the **decision boundary where active affine pieces switch**. Formalizing this theorem opens a route to certified geometry of neural-network boundaries in max-plus language.

### 3. Polyhedral combinatorics
The pairwise-cell decomposition is a finite arrangement theorem. It is the first step toward:
- Newton polytopes,
- regular subdivisions,
- tropical fans,
- balancing conditions.

### 4. Max-plus spectral theory
Tropical eigenspaces and cycle-dominance regions are governed by equalities between affine/max-plus weights. The same cell-complex language should eventually unify tropical hypersurfaces with spectral phase transitions.

---

## Concrete theorem package to aim for

A strong deliverable would be a file proving several lemmas in sequence:

1. `eval_monomial_le_eval_poly`
2. `isTropRoot_iff_exists_distinct_maximizers`
3. `isTropRoot_iff_exists_pairwise_dominating_tie`
4. `tropHypersurface_eq_union_pairCells`
5. `isClosed_tropHypersurface` (stretch goal, but highly desirable)

This is already a publishable-formalization-grade seed.

---

## Lean design advice
- Use `Fin n → ℝ` for ambient space and `Fin n → ℕ` for exponent vectors.
- Keep polynomial support finite via `Finset`.
- Require nonemptiness explicitly to avoid awkward `sup` over empty sets.
- Prefer theorem statements in terms of `∃ m ∈ p.terms` rather than set unions initially.
- If equality on `TropMonomial` becomes awkward for `Finset`, derive or instantiate `DecidableEq`.
- Avoid over-generalizing to arbitrary ordered idempotent semirings in the first pass. First prove the theorem over `ℝ`.

---

## If direct proof stalls
If `sup'` becomes painful, switch to a list-based representation:
- define polynomial as `List (TropMonomial n)` with nonempty proof,
- define evaluation recursively by `foldl max`,
- prove the theorem by induction on the list.

This is less elegant but often easier for a first formal breakthrough. Once the theorem is established, refactor to `Finset`.

---

## Deliverables
1. Lean file implementing the above definitions and at least one main theorem.
2. Minimize sorry aggressively.
3. Add module-level comments explaining the geometric meaning.
4. Produce `FUTURE_DIRECTIONS.md` with **3–5 concrete next theorems**, each including:
   - exact theorem statement,
   - Lean-facing formalization plan,
   - proof strategy,
   - cross-domain significance.

---

## Required FUTURE_DIRECTIONS targets
Your `FUTURE_DIRECTIONS.md` must include specific next steps such as:

1. **Closedness theorem**  
   `IsClosed (TropHypersurface p)` for finite tropical polynomials.

2. **Convex-complement theorem**  
   Each connected component of the complement of a tropical hypersurface is a region of unique maximizer; formalize as an open cell where one affine form strictly dominates all others.

3. **Newton polytope bridge**  
   Define the lifted Newton polytope and conjecture/prove that tropical cells correspond to normal cones of upper faces in low dimension.

4. **Tropical line in dimension 2**  
   Give an explicit formal classification for a 3-term tropical polynomial in two variables; prove its hypersurface is the standard tripod under suitable coefficient normalization.

5. **Optimization bridge theorem**  
   Prove that the tropical hypersurface of a max-affine function equals its nondifferentiability set.

These are not optional ornaments. They are the roadmap to field creation.

---

## Application keywords
tropical geometry, tropical hypersurface, corner locus, max-plus algebra, convex piecewise-linear analysis, polyhedral complex, Newton polytope, argmax geometry, max-affine optimization, neural decision boundaries, tropical spectral theory, formalized mathematics, Lean 4, Mathlib

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
