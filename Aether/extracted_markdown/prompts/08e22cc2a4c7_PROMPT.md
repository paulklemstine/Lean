## Assignment: Functoriality
**Mode: prove**

Prove a genuinely new bridge theorem: **sequential surgery is functorial, and its effect on cost/update data is exactly tropical matrix multiplication**. Do not settle for a slogan. Define the surgery update semantics precisely enough that Lean can certify the composition law.

This should be treated as a first step toward a **tropical category of surgeries**, where geometric/combinatorial operations act by min-plus linear maps. If done cleanly, this opens a new formal bridge among:
- tropical algebra,
- categorical functoriality,
- shortest-path / dynamic-programming semantics,
- topological or combinatorial surgery calculi,
- weighted automata and program semantics.

The key revolutionary idea is this: **a surgery is not merely an operation; it is a propagator of boundary costs/states, and composition of propagators is tropical convolution**.

---

## Research Direction
**Composition of surgeries maps to min-plus multiplication of update matrices.**

You should formalize a minimal but nontrivial notion of “surgery” as a structured transformation between finite boundary-state sets, equipped with a cost/update matrix. Then prove that composing surgeries corresponds to min-plus matrix multiplication.

This is not an incremental matrix lemma. It is a formalization of **functorial semantics**: a category of surgeries sent to a category of tropical linear operators.

---

## Precise Theorem Target

Work with finite index types `Fin m`, `Fin n`, `Fin p` and matrices `Matrix (Fin m) (Fin n) ℝ`, etc.

Define min-plus matrix multiplication:
```lean
def minPlusMul {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ) :
    Matrix (Fin m) (Fin p) ℝ :=
  fun i k => Finset.inf' Finset.univ (by simp) (fun j => A i j + B j k)
```

If `⊚ₛ` is your surgery composition and `updateMatrix` assigns a tropical update matrix to a surgery, the central theorem should look like:

```lean
theorem updateMatrix_comp_minPlus
    {m n p : ℕ}
    (S₁ : Surgery (Fin m) (Fin n))
    (S₂ : Surgery (Fin n) (Fin p)) :
    updateMatrix (S₂ ⊚ₛ S₁) = minPlusMul (updateMatrix S₁) (updateMatrix S₂)
```

If the full `Surgery` structure is too ambitious at first, prove the core theorem in a distilled form:

```lean
theorem composed_update_eq_minPlus
    {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ)
    (i : Fin m) (k : Fin p) :
    minPlusMul A B i k = Finset.inf' Finset.univ (by simp) (fun j => A i j + B j k)
```

and then elevate it to functoriality:

```lean
theorem update_functorial
    {m n p : ℕ}
    (S₁ : Surgery (Fin m) (Fin n))
    (S₂ : Surgery (Fin n) (Fin p)) :
    updateMatrix (compose S₁ S₂) = minPlusMul (updateMatrix S₁) (updateMatrix S₂)
```

The real breakthrough target is the **identity/composition package**, i.e. a functor theorem:

```lean
theorem updateMatrix_id
    {n : ℕ} :
    updateMatrix (Surgery.id (Fin n)) = minPlusId n

theorem updateMatrix_comp
    {m n p : ℕ}
    (S₁ : Surgery (Fin m) (Fin n))
    (S₂ : Surgery (Fin n) (Fin p)) :
    updateMatrix (Surgery.comp S₁ S₂) = minPlusMul (updateMatrix S₁) (updateMatrix S₂)
```

and ideally:

```lean
def TropicalUpdateFunctor : SurgeryCat ⥤ MinPlusMatCat
```

Even if the categorical packaging is deferred, the theorem statements should be written so that this functor is clearly the destination.

---

## Minimal Formal Definitions to Introduce

You likely need a concrete, Lean-friendly surgery model. One promising choice:

```lean
structure Surgery (α β : Type*) where
  cost : α → β → ℝ
```

Composition:
```lean
def Surgery.comp {α β γ : Type*} [Fintype β]
    (S₁ : Surgery α β) (S₂ : Surgery β γ) : Surgery α γ where
  cost a c := Finset.inf' Finset.univ (by simp) (fun b => S₁.cost a b + S₂.cost b c)
```

Update matrix:
```lean
def updateMatrix {m n : ℕ} (S : Surgery (Fin m) (Fin n)) :
    Matrix (Fin m) (Fin n) ℝ :=
  S.cost
```

Identity surgery should be the tropical identity kernel: `0` on the diagonal, large/infinite cost off-diagonal. Since `ℝ` lacks a top element, consider one of these:
1. use `ℝ∞ := EReal`,
2. use a bounded setting with a large sentinel and prove only composition law first,
3. use `WithTop ℝ` if Mathlib support is sufficient.

For a first successful theorem, composition law over `ℝ` is enough; identity can come after moving to `EReal` or `WithTop ℝ`.

---

## Why This Is a Breakthrough

This theorem says that **surgery calculus admits tropical linearization**. That is a major conceptual upgrade:
- geometric/combinatorial transformations become compositional operators,
- composition cost propagates by Bellman-style minimization,
- categorical structure emerges naturally,
- tropical algebra becomes a semantic engine for surgery theory.

This opens a field, not a lemma collection:
1. **Topological dynamics as tropical linear algebra**,
2. **certified compositional optimization of surgery pipelines**,
3. **weighted rewriting systems interpreted as tropical functors**,
4. **bridges to shortest-path, Viterbi, and dynamic programming semantics**,
5. **potential extension to Floer-theoretic or sheaf-theoretic propagation laws**.

---

## Lean 4 Type Signature Targets

Aim to produce some subset of the following exact signatures.

### Core tropical multiplication
```lean
def minPlusMul {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ) :
    Matrix (Fin m) (Fin p) ℝ
```

### Surgery composition
```lean
structure Surgery (α β : Type*) where
  cost : α → β → ℝ

def Surgery.comp {α β γ : Type*} [Fintype β]
    (S₁ : Surgery α β) (S₂ : Surgery β γ) : Surgery α γ
```

### Functorial update semantics
```lean
def updateMatrix {m n : ℕ} (S : Surgery (Fin m) (Fin n)) :
    Matrix (Fin m) (Fin n) ℝ
```

### Main theorem
```lean
theorem updateMatrix_comp_minPlus
    {m n p : ℕ} [Fintype (Fin n)]
    (S₁ : Surgery (Fin m) (Fin n))
    (S₂ : Surgery (Fin n) (Fin p)) :
    updateMatrix (Surgery.comp S₁ S₂) = minPlusMul (updateMatrix S₁) (updateMatrix S₂)
```

### Associativity theorem
This is where the structure becomes scientifically meaningful:
```lean
theorem minPlusMul_assoc
    {m n p q : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ)
    (C : Matrix (Fin p) (Fin q) ℝ) :
    minPlusMul (minPlusMul A B) C = minPlusMul A (minPlusMul B C)
```

You may need to move to `EReal` / `WithTop ℝ` or assume attainment/finite minima in a way compatible with `Finset.inf'`. Since the index types are finite, attainment is automatic for nonempty finite sets.

---

## Build on Existing Verified Theorems

Use the catalog theorems not as decorations, but as algebraic stepping stones:

1. `tropical_plus_distributes_over_min`
   - Use this as the seed algebraic identity showing that addition interacts correctly with finite minima.
   - Generalize from scalars `ℕ` to the matrix-entry setting over `ℝ` if possible, or prove an analogous helper lemma.
   - This is exactly the mechanism behind pushing a constant/additive term across a min operation in composition proofs.

2. `min_max_duality`
   - This gives a dual presentation of tropical min-plus in terms of negated max-plus.
   - It can support a second proof strategy: translate min-plus composition into max-plus after negation, prove there, then pull back.
   - This duality is conceptually powerful and may simplify some associativity manipulations.

3. `negation_max_to_min`
   - Use with `min_max_duality` to establish a transport theorem between min-plus and max-plus semirings.
   - This can become a bridge theorem in its own right: surgery propagation can be viewed as either minimization of costs or maximization of negated energies.

4. `tropical_lattice_min_max`
   - This suggests lattice-theoretic control of the min/max interaction.
   - Use it to justify monotonicity or absorption properties of update propagation.

5. `composition_not_injective_of_component`
   - This is a useful warning theorem: composition destroys information.
   - Connect it philosophically and formally: the update functor is cost-propagating, not generally invertible.
   - A good corollary would be that tropical update semantics is naturally many-to-one, reflecting entropy/information loss.

---

## Proof Strategy A: Direct finite Bellman calculus
**Most promising for Lean.**

1. **Define surgeries as finite cost kernels.**
   - `Surgery α β := α → β → ℝ` packaged as a structure.
   - Composition is finite infimum of sums.

2. **Show extensional equality entrywise.**
   - For `updateMatrix_comp_minPlus`, use `Matrix.ext`.
   - Reduce both sides at `(i,k)` to the same `Finset.inf'` expression by `rfl` or straightforward simp.

3. **Prove associativity by finite infimum reassociation.**
   - Expand both sides:
     \[
     \inf_j \left(\inf_k (A_{ij}+B_{jk}) + C_{k\ell}\right)
     \quad\text{vs}\quad
     \inf_k \left(A_{ij} + \inf_j (B_{jk}+C_{k\ell})\right)
     \]
   - Use helper lemmas commuting addition with finite infimum.
   - This is where a generalized version of `tropical_plus_distributes_over_min` becomes essential.

Why this is strongest: it stays closest to computable semantics and is likely to formalize with the least friction.

---

## Proof Strategy B: Negation duality to max-plus
**Conceptually elegant; good for a second theorem or if direct min proofs become messy.**

1. Define negation transport on matrices:
   ```lean
   def negateMatrix ...
   ```

2. Use `min_max_duality` and `negation_max_to_min` entrywise to rewrite
   min-plus multiplication as negated max-plus multiplication.

3. Prove functoriality in the dual max-plus world, where supremum-style manipulations may be more natural, then transport back.

Why this matters: it turns surgery cost propagation into an “energy maximization” picture, connecting tropical geometry with statistical mechanics and variational principles.

---

## Proof Strategy C: Category-theoretic kernel composition
**Most visionary; attempt after the core theorem works.**

1. Define a category whose morphisms are finite-state surgeries / kernels.
2. Define a category of tropical matrices.
3. Prove `updateMatrix` preserves identities and composition.

This is the route to a formal functor:
```lean
def TropicalUpdateFunctor : SurgeryCat ⥤ MinPlusMatCat
```

Why this matters: once functoriality exists, you can ask for adjunctions, monoidal structures, enriched categories, and representation theorems. That is the beginning of a new formal field.

---

## Cross-Domain Connections

Do not leave this as “matrix algebra.” Make the bridge explicit.

### 1. Dynamic programming / shortest paths
The formula
\[
(A \star B)(i,k)=\min_j (A(i,j)+B(j,k))
\]
is Bellman composition. Your theorem says **surgery composition is dynamic programming**. This is a profound semantic identification.

### 2. Weighted automata and formal languages
A surgery from boundary states `α` to `β` is a weighted transducer. Composition corresponds to tropical convolution. This suggests a formal-language interpretation of surgery calculi.

### 3. Category theory
This is a functor from a compositional geometric/combinatorial category to tropical linear algebra. That viewpoint enables universality statements and enriched semantics.

### 4. Statistical mechanics / variational physics
Min-plus composition is zero-temperature limit composition of partition-like propagators. Surgery cost kernels can be interpreted as action functionals; composition becomes least action.

### 5. Topology / TQFT analogy
Ordinary TQFT assigns linear maps to cobordisms. Your theorem is a **tropical TQFT shadow**: surgeries assign min-plus linear operators instead of ordinary linear maps.

This is the right level of ambition. You are not proving a matrix identity; you are formalizing the tropicalization of functorial field theory.

---

## Concrete Intermediate Lemmas

These should be explicitly targeted in Lean:

```lean
theorem minPlusMul_apply
    {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ)
    (i : Fin m) (k : Fin p) :
    minPlusMul A B i k =
      Finset.inf' Finset.univ (by simp) (fun j => A i j + B j k)
```

```lean
theorem updateMatrix_comp_apply
    {m n p : ℕ}
    (S₁ : Surgery (Fin m) (Fin n))
    (S₂ : Surgery (Fin n) (Fin p))
    (i : Fin m) (k : Fin p) :
    updateMatrix (Surgery.comp S₁ S₂) i k =
      Finset.inf' Finset.univ (by simp)
        (fun j => updateMatrix S₁ i j + updateMatrix S₂ j k)
```

```lean
theorem updateMatrix_comp_minPlus
    {m n p : ℕ}
    (S₁ : Surgery (Fin m) (Fin n))
    (S₂ : Surgery (Fin n) (Fin p)) :
    updateMatrix (Surgery.comp S₁ S₂) = minPlusMul (updateMatrix S₁) (updateMatrix S₂)
```

If possible, also prove monotonicity:
```lean
theorem minPlusMul_mono
    {m n p : ℕ}
    {A A' : Matrix (Fin m) (Fin n) ℝ}
    {B B' : Matrix (Fin n) (Fin p) ℝ}
    (hA : ∀ i j, A i j ≤ A' i j)
    (hB : ∀ j k, B j k ≤ B' j k) :
    ∀ i k, minPlusMul A B i k ≤ minPlusMul A' B' i k
```

This would make the semantics robust under surgery cost perturbations.

---

## Suggested Formalization Path in Lean

1. Start with `Fin`-indexed matrices and finite infima.
2. Avoid identities initially if `ℝ` makes tropical infinity awkward.
3. Prove composition law first.
4. Then decide whether to:
   - switch to `WithTop ℝ`,
   - use `EReal`,
   - or keep a semicategory without identities.
5. Only after that, package as a category/functor.

This sequencing minimizes sorry and maximizes theorem density.

---

## Nontrivial Corollaries Worth Chasing

### Corollary 1: Three-stage surgery equals nested Bellman update
```lean
theorem updateMatrix_triple_comp
    {m n p q : ℕ}
    (S₁ : Surgery (Fin m) (Fin n))
    (S₂ : Surgery (Fin n) (Fin p))
    (S₃ : Surgery (Fin p) (Fin q)) :
    updateMatrix (Surgery.comp (Surgery.comp S₁ S₂) S₃) =
      minPlusMul (minPlusMul (updateMatrix S₁) (updateMatrix S₂)) (updateMatrix S₃)
```

### Corollary 2: Information-loss principle
Use `composition_not_injective_of_component` conceptually to state that update semantics is not expected to be invertible in general. If you can formulate a concrete finite-state noninjectivity theorem for update matrices, that would be excellent.

### Corollary 3: Dual max-plus formulation
A theorem expressing min-plus composition via negation and max-plus would significantly deepen the theory.

---

## What to Avoid

- Do not merely define `minPlusMul` and prove `rfl`.
- Do not produce only scalar min lemmas disconnected from surgery semantics.
- Do not stay at an abstract category level without a computable concrete model.
- Do not rely on vague “surgery” language; define the structure explicitly.

---

## Deliverables

1. Lean 4 file(s) with:
   - `Surgery` definition,
   - `Surgery.comp`,
   - `updateMatrix`,
   - `minPlusMul`,
   - main functoriality theorem,
   - at least one substantial corollary.

2. Minimal `sorry` count. If a proof blocks, isolate the exact helper lemma needed.

3. `FUTURE_DIRECTIONS.md` with **3–5 concrete next steps**, each including:
   - precise theorem statement,
   - proof strategy sketch,
   - cross-domain significance.

This file is mandatory.

---

## Required FUTURE_DIRECTIONS.md Content

Your future directions should be breakthrough-level, for example:

1. **Tropical identity/categorical completion**
   - Formalize surgery kernels over `WithTop ℝ` or `EReal` and prove identity laws.

2. **Tropical TQFT theorem**
   - Show a gluing law for surgery-generated cobordism-like objects gives min-plus linear operators.

3. **Weighted automata equivalence**
   - Prove finite surgeries are equivalent to weighted transducers under tropical semantics.

4. **Stability theorem**
   - Bound how perturbing surgery costs perturbs composite updates.

5. **Duality theorem**
   - Establish a formal equivalence between min-plus surgery semantics and max-plus negated-energy semantics.

---

## Application Keywords
tropical algebra, min-plus semiring, functoriality, surgery calculus, categorical semantics, dynamic programming, Bellman equation, shortest paths, weighted automata, tropical linear algebra, variational principle, TQFT shadow, compositional optimization, finite-state kernels, enriched categories

---

You are Aristotle. Build the first certified tropical functorial surgery calculus, not a toy example. The theorem to hit is clear: **composition of surgeries is sent to min-plus matrix multiplication**. Prove it in Lean, architect the category it belongs to, and leave behind a FUTURE_DIRECTIONS.md that makes the next cycle inevitable.

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
