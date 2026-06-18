Mode: prove

Title: A reflected AC-normalized decision procedure for tropical polynomial identities, with certified bounds transport

You should attack the highest-leverage bridge theorem in this landscape: turn the existing verified normalizer into a genuine reflective engine for tropical algebra, then connect it to certified optimization bounds. The target is not “another simplifier.” It is a formally verified mechanism showing that tropical identities can be decided by computation inside Lean, and that this computation interoperates with optimization-style lower-bound certificates already present in the catalog.

## Core breakthrough target

Define a syntax of tropical expressions over variables in `Fin n`, with tropical addition = `max` and tropical multiplication = `+`, and prove that AC-normalization computes canonical representatives modulo associativity, commutativity, and the tropical distributive laws already witnessed by catalog results such as `tropical_and_distributes`.

The decisive theorem should be a semantic completeness statement for the normal form on a nontrivial fragment: tropical polynomials built from variables, constants, `max`, and `+`.

### Precise theorem statement

A strong target is:

> For every fixed finite variable set `Fin n`, if two tropical polynomial expressions have equal AC-normal forms, then they denote the same function `((Fin n → ℝ) → ℝ)`. Conversely, if they denote the same function for all valuations, then their normalized supports coincide.

The second direction is the field-opening part: it upgrades normalization from a sound procedure to a semantic classifier for tropical polynomials. This is the seed of a true decision procedure.

A Lean-oriented formulation:

```lean
inductive TropExpr (n : Nat) where
  | var   : Fin n → TropExpr n
  | const : ℝ → TropExpr n
  | tmax  : TropExpr n → TropExpr n → TropExpr n
  | tplus : TropExpr n → TropExpr n → TropExpr n

def TropExpr.eval {n : Nat} : TropExpr n → (Fin n → ℝ) → ℝ
-- interpret `tmax` as `max`, `tplus` as `+`

/-- canonical finite support representation of a tropical polynomial:
    a finite set/list of affine forms `(c, w)` interpreted as `c + ∑ i, w i * x i`,
    with normalization quotienting by permutation and duplicate maxima. -/
def TropNF (n : Nat) := ...

def normalize {n : Nat} : TropExpr n → TropNF n := ...

def TropNF.eval {n : Nat} : TropNF n → (Fin n → ℝ) → ℝ := ...

theorem normalize_sound {n : Nat} (e : TropExpr n) :
  TropNF.eval (normalize e) = TropExpr.eval e

theorem normalize_complete_functional
    {n : Nat} (e₁ e₂ : TropExpr n) :
    normalize e₁ = normalize e₂ →
    TropExpr.eval e₁ = TropExpr.eval e₂

theorem normalize_complete_extensional
    {n : Nat} (e₁ e₂ : TropExpr n) :
    (∀ x : Fin n → ℝ, TropExpr.eval e₁ x = TropExpr.eval e₂ x) →
    normalize e₁ = normalize e₂
```

If full extensional completeness over arbitrary real constants is too ambitious at first pass, prove it on the coefficient-restricted fragment with natural coefficients and finite tropical monomial support:

```lean
theorem normalize_complete_natCoeff
    {n : Nat} (e₁ e₂ : TropExpr n) :
    TropExpr.IsPolynomialNatCoeff e₁ →
    TropExpr.IsPolynomialNatCoeff e₂ →
    (∀ x : Fin n → ℝ, TropExpr.eval e₁ x = TropExpr.eval e₂ x) →
    normalize e₁ = normalize e₂
```

This is already a major result: a certified decision procedure for equality of tropical polynomials via canonical form.

## Why this is a breakthrough

This opens a verified tropical symbolic algebra layer in Lean. Not just simplification, but a computational semantics theorem: extensional equality of piecewise-linear convex tropical polynomials is reduced to equality of canonical combinatorial data. Once formalized, this becomes infrastructure for:
- verified tropical optimization preprocessing,
- certified neural network reasoning in max-plus form,
- formal tropical geometry via Newton polytopes and support functions,
- proof-producing tactics for semiring-like but nonclassical algebra.

The conceptual leap is that normalization is no longer syntax management; it becomes a theorem that tropical algebraic semantics is finitely capturable by support data. That is the kind of result that changes what can be automated.

## Suggested Lean 4 formalization targets

Use concrete finite combinatorics:
- variables indexed by `Fin n`
- monomials as `Fin n →₀ Nat` or `Fin n → Nat` with finite support automatic from finiteness
- supports as `Finset`
- coefficients in `ℝ`
- evaluation as max over finitely many affine forms

A robust normal form is:
```lean
-- coefficient c and exponent vector w
abbrev TropMonomial (n : Nat) := ℝ × (Fin n → Nat)

-- finite family of monomials, interpreted as max of affine forms
abbrev TropPolyNF (n : Nat) := Finset (TropMonomial n)
```

with semantics
```lean
def evalMonomial {n : Nat} (m : TropMonomial n) (x : Fin n → ℝ) : ℝ :=
  m.1 + ∑ i, (m.2 i : ℝ) * x i

def evalNF {n : Nat} (s : TropPolyNF n) (x : Fin n → ℝ) : ℝ :=
  s.sup fun m => evalMonomial m x
```

Then show:
- `tmax` corresponds to `Finset.union`
- `tplus` corresponds to tropical convolution / Minkowski sum of exponent vectors:
  coefficients add, exponents add pointwise

This is the hidden geometric content: normal forms are finite subsets of `ℝ × ℕ^n`, and multiplication is Minkowski addition.

## Proof strategies

### Strategy A: Support-function / Newton-polytope route
Most promising.

1. Represent each normalized tropical polynomial as a finite set of affine forms, hence as a support function of a finite subset of `ℝ × ℕ^n`.
2. Prove soundness by induction on syntax: `max` becomes union, `+` becomes pairwise sum of affine forms.
3. For completeness, use separation of distinct affine families: if two normalized supports differ, choose a valuation `x` forcing one affine form to dominate strictly. This yields extensional inequality.

Why this is strongest: it reveals the convex-geometric meaning of normalization. Equality of tropical polynomials becomes equality of support functions of finite Newton data. This is not just a proof trick; it is the bridge to tropical geometry.

### Strategy B: Direct finite-max normal form with domination pruning
More implementation-friendly.

1. Normalize expressions to a list/finset of monomials.
2. Define a pruning relation removing monomials everywhere dominated by others.
3. Prove every expression evaluates to the max of its pruned monomial set.
4. Show uniqueness of the pruned set by constructing witness valuations that isolate nondominated monomials.

This may be easier in Lean because domination is combinatorial. It also sets up an efficient tactic.

### Strategy C: Reflection-first approach
Best for immediate tooling, weaker mathematically unless paired with A or B.

1. Define a boolean procedure `beqNorm : TropExpr n → TropExpr n → Bool`.
2. Prove `beqNorm = true →` semantic equality.
3. Reify concrete `ℝ`-valued tropical goals and discharge them by vm-computation/native_decide.

This yields immediate practical impact. But without completeness it remains a one-sided certifier. Use this as the engineering layer after A or B.

## Immediate theorem cascade to pursue

### 1. Normalization respects semantics
```lean
theorem eval_normalize {n : Nat} (e : TropExpr n) (x : Fin n → ℝ) :
  TropNF.eval (normalize e) x = TropExpr.eval e x
```

### 2. Tropical convolution theorem
```lean
theorem eval_mulNF
    {n : Nat} (S T : TropPolyNF n) (x : Fin n → ℝ) :
    evalNF (mulNF S T) x = evalNF S x + evalNF T x
```

This is the algebraic heart.

### 3. Union/max theorem
```lean
theorem eval_addNF
    {n : Nat} (S T : TropPolyNF n) (x : Fin n → ℝ) :
    evalNF (addNF S T) x = max (evalNF S x) (evalNF T x)
```

### 4. Extensional completeness by witness valuation
```lean
theorem nf_extensional_complete
    {n : Nat} {S T : TropPolyNF n} :
    (∀ x : Fin n → ℝ, evalNF S x = evalNF T x) → S = T
```

This is the conceptual summit.

## Build explicitly on catalog theorems

Use the catalog not decoratively but structurally:

- `tropical_and_distributes` should guide the semantic proof that tropical multiplication distributes over tropical addition. Even if its exact statement is phrased in another application layer, mine its proof pattern for rewriting `a + max b c = max (a+b) (a+c)` or analogous identities.
- `bool_and_as_tropical_max` is a clue for reflection: tropical `max` already serves as a logical connective surrogate. This suggests a reified tactic architecture where Boolean goal structure is transported into tropical normal forms.
- `tropical_and_bound` indicates a route to bounds preservation: after normalization, lower bounds should be transported componentwise through max-plus structure.
- `tropical_certified_robustness` is the bridge to optimization and ML: once expressions are normalized to finite affine maxima, certified robustness becomes a question about margins between finitely many affine forms.
- `tropical_yoneda_preservation` hints at a categorical abstraction layer: normalization as a functor preserving tropical semantics. Do not start there, but once the concrete theorem is done, package normalization as a semantics-preserving reflector.

## Cross-domain connections you should make explicit in the development

1. Tropical geometry:
   Normal forms are Newton supports; evaluation is a support function. This is the formal seed of Newton polytope reasoning in Lean.

2. Convex analysis:
   Tropical polynomials over `ℝ` are convex piecewise-linear functions. Completeness of normalization is a uniqueness theorem for finite support-function presentations after pruning dominated terms.

3. Automated reasoning / proof by reflection:
   The normalizer becomes a certified decision procedure. This is a genuine theorem-proving tool, not merely algebraic formalization.

4. Neural networks:
   Max-plus neural layers are tropical polynomials. A canonical form yields exact symbolic compression and robustness certificate extraction.

5. Program optimization:
   Bounds preservation after normalization means preprocessing transformations can be certified semantics-preserving and certificate-preserving.

## Secondary theorem: bounds preservation under normalization

Once `eval_normalize` is proved, show a certificate transport theorem:

```lean
theorem lower_bound_preserved_by_normalize
    {n : Nat} (e : TropExpr n) (L : ℝ) :
    (∀ x : Fin n → ℝ, L ≤ TropExpr.eval e x) →
    ∀ x : Fin n → ℝ, L ≤ TropNF.eval (normalize e) x
```

This is easy from soundness, but do not undersell it. It links symbolic normalization to certified optimization pipelines.

A stronger and more interesting variant:
```lean
theorem affine_lower_bound_of_nf
    {n : Nat} (S : TropPolyNF n) (m : TropMonomial n) :
    m ∈ S →
    ∀ x, evalMonomial m x ≤ evalNF S x
```

This says every retained monomial is itself a certified lower bound. Combined with nondominance pruning, this gives a finite family of exact lower certificates.

## Reflection tactic target

If the core theorem lands, implement:

```lean
syntax (name := tropical_nf) "tropical_nf" : tactic
```

with a correctness theorem of the form:
```lean
theorem tropical_nf_correct
    {n : Nat} (e₁ e₂ : TropExpr n) :
    normalize e₁ = normalize e₂ →
    ∀ x : Fin n → ℝ, TropExpr.eval e₁ x = TropExpr.eval e₂ x
```

Then hook the tactic to reified goals involving `max`, `+`, variables, and constants.

This is immediately useful and demonstrates the theorem’s practical force.

## Concrete implementation advice

- Use `Finset.sup` for finite maxima over `ℝ`; handle emptiness carefully, likely by ensuring nonempty supports or using a bottom-extended type initially if needed.
- If `Finset.sup` over `ℝ` is awkward, start with nonempty lists plus proofs, or normalize into a head-plus-tail structure.
- Exponents in `Nat` avoid coefficient pathology and are enough for a first major theorem.
- Constants can be encoded as monomials with zero exponent vector.
- Equality of functions `Fin n → ℝ → ℝ` should likely be proved by `funext`.

## If completeness stalls

Produce an intermediate but still meaningful theorem:

```lean
theorem normalize_complete_linearFragment
    {n : Nat} (e₁ e₂ : TropExpr n) :
    TropExpr.IsAffineMax e₁ →
    TropExpr.IsAffineMax e₂ →
    (∀ x, TropExpr.eval e₁ x = TropExpr.eval e₂ x) →
    normalize e₁ = normalize e₂
```

Even this would be a breakthrough-quality formal result if done cleanly, because it captures the exact class of convex PWL functions representable as finite maxima of affine forms.

## Application keywords

tropical algebra, max-plus semiring, proof by reflection, decision procedure, canonical forms, Newton polytope, support function, convex piecewise-linear analysis, certified optimization, formal verification, Lean 4, Mathlib, tropical neural networks, robustness certificates, symbolic computation

## Deliverables

1. A Lean file defining `TropExpr`, `TropNF`, evaluation, and normalization.
2. Proofs of soundness and at least one nontrivial completeness theorem.
3. If possible, a reflective tactic for goal discharge on concrete tropical identities.
4. A structured `FUTURE_DIRECTIONS.md` with 3–5 concrete breakthrough next steps, for example:
   - extension from `ℕ` exponents to integer Laurent tropical expressions,
   - Newton polytope equivalence and Legendre–Fenchel duality formalization,
   - tropical Gröbner-style reduction for ideal membership,
   - exact symbolic certification of max-plus neural network robustness,
   - tropical quantifier elimination on finite affine-max fragments.

Be bold: the right theorem here is not “normalization works.” It is “tropical semantics admits a canonical, computable, extensional classifier inside Lean.” That would transform this codebase from a collection of lemmas into a platform.

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
