Mode: prove

Priority target: Direction 2 (amplification) — turn a one-shot tropical exact bound into a compositional amplification law. This is the right first breakthrough because it converts an isolated estimate into a reusable calculus. If you succeed, every future bridge involving tropical perturbation, closure growth, bounded automata explosion, or logical reconstruction gains a certified “tensorization” principle.

# Breakthrough Objective

Prove a sharp amplification theorem showing that exact tropical perturbation bounds add under independent/product composition of finite systems.

The conceptual leap is this: `tropical_perturbation_exact_bound` currently behaves like a local energy estimate on one finite support. You should promote it into a global extensivity law, analogous to:
- tensorization in information theory,
- direct-sum theorems in complexity,
- product formulas in statistical mechanics,
- and error exponents in coding theory.

This is not an incremental strengthening. It opens a new field of formalized tropical complexity amplification.

## Precise theorem statement

Work with finite supports `S : Finset α` and `T : Finset β`, both nonempty. Define the product support `S.product T : Finset (α × β)`. Use the exact bound supplied by the catalog theorem `tropical_perturbation_exact_bound` as the scalar complexity/perturbation quantity attached to a finite support.

The target theorem should express that the exact tropical perturbation bound of a product support is the sum of the exact bounds of the factors, or at minimum is bounded below by their sum and above by the same explicit expression so that equality follows.

A concrete Lean-facing target is:

```lean
theorem tropical_perturbation_product_exact
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β)
    (hS : S.Nonempty) (hT : T.Nonempty) :
    tropicalPerturbationBound (S.product T)
      = tropicalPerturbationBound S + tropicalPerturbationBound T
```

If the existing theorem `tropical_perturbation_exact_bound` identifies the bound with a closed form `F : Finset γ → ℝ` or `→ ℕ`, then prove the theorem in that concrete form instead:

```lean
theorem tropical_perturbation_exact_bound_product
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β)
    (hS : S.Nonempty) (hT : T.Nonempty) :
    tropicalPerturbationExactExpr (S.product T)
      = tropicalPerturbationExactExpr S + tropicalPerturbationExactExpr T
```

If exact equality is too optimistic because the current exact bound is phrased via cardinal data, then prove the strongest true theorem available, e.g. a cardinal-log formula:

```lean
theorem tropical_perturbation_exact_bound_product_card
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β)
    (hS : S.Nonempty) (hT : T.Nonempty) :
    tropicalPerturbationExactExpr (S.product T)
      = tropicalPerturbationExactExpr S + tropicalPerturbationExactExpr T
```

where the proof reduces to
`card (S.product T) = card S * card T`
and a logarithmic or valuation-like identity already implicit in the exact-bound theorem.

If exact equality fails, still secure a nontrivial amplification theorem:

```lean
theorem tropical_perturbation_product_lower_bound
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β)
    (hS : S.Nonempty) (hT : T.Nonempty) :
    tropicalPerturbationBound S + tropicalPerturbationBound T
      ≤ tropicalPerturbationBound (S.product T)
```

paired with a matching upper bound.

## Why this is a breakthrough

This theorem would establish the first formal tensorization law for a tropical exact bound in the catalog. That matters because once a complexity-like quantity is additive under products, it becomes a scalable invariant rather than a one-off estimate. This enables:
- asymptotic amplification,
- direct-product lower bounds,
- compositional certification for large systems,
- and a bridge between tropical geometry and complexity theory.

In particular, it would connect:
- tropical perturbation theory,
- automata growth (`boundedWordCount_linear_times_exponential`),
- closure dynamics (`closure_iteration_linear_bound`),
- and finite logical reconstruction (`formula_has_term`).

The long-term vision is a formal “tropical thermodynamics” where product composition corresponds to extensivity of free energy / entropy / robustness.

# Build explicitly on catalog theorems

## Primary building block
Use:

```lean
tropical_perturbation_exact_bound
```

from
`Bridges/AlgebraEML/TropicalChoquetClosureDuality.lean`

You need to inspect exactly what closed form it proves. The central move is to rewrite both sides of the desired product theorem using this exact formula, then prove the resulting finite combinatorial identity.

## Secondary bridge theorems
Use these as downstream amplifiers or sanity checks:

1. `closure_iteration_linear_bound`
   from `Bridges/ClosureMorita/ClosureMoritaMain.lean`

   Idea: if tropical perturbation behaves additively under products while closure iteration is linear, then there may be a compositional principle saying closure complexity of product systems is at most additive or bilinear. Even if not proved now, use it to motivate definitions.

2. `boundedWordCount_linear_times_exponential`
   from `Bridges/BerggrenResidualAutomata.lean`

   This suggests a complexity-growth interface: additive tropical exponents often become multiplicative counting laws after exponentiation. If your exact bound has a logarithmic flavor, the product theorem becomes an automata-style growth theorem.

3. `formula_has_term`
   from `Bridges/AlgebraTropicalLogic/TropicalGodelKripkeReconstruction.lean`

   This offers a logic interpretation: product amplification may correspond to conjunction/product semantics for formula complexity witnesses.

# Proof strategy architecture

## Strategy A: exact-formula reduction via cardinal/product algebra
Most promising.

1. Unfold the exact expression given by `tropical_perturbation_exact_bound`.
2. Prove the finite-support identity for `S.product T`, likely using:
   - `Finset.card_product`,
   - arithmetic identities,
   - logarithm/additivity if the expression is log-cardinality-like,
   - max-plus/min-plus distributive identities if the expression is tropical rank-like.
3. Rewrite the target by applying the exact bound theorem to `S`, `T`, and `S.product T`, then simplify.

Why this is strongest:
- It minimizes new tropical reasoning.
- It exploits a certified exact theorem already in the catalog.
- It should produce equality, not just inequalities.

## Strategy B: variational/tropical duality proof
Use if the exact bound is defined as an extremum over weights or valuations.

1. Show that a feasible perturbation on `S` and one on `T` combine into a feasible perturbation on `S.product T`.
2. Prove lower bound by constructing the product witness.
3. Prove upper bound by projecting any witness on `S.product T` to marginals on `S` and `T`, then use optimality.

Why it matters:
- This reveals the real geometry behind the theorem.
- It is more reusable for later generalizations to matrices, kernels, and linear maps.

## Strategy C: semiring/monoidal abstraction
Most ambitious; do only if the concrete theorem lands cleanly.

1. Define a class of finite tropical complexity functionals `Φ` satisfying monoidal additivity on products.
2. Show the exact perturbation bound is an instance.
3. Derive corollaries for iterated products `S^n`.

This could yield:

```lean
theorem tropical_perturbation_power_exact
    {α : Type*} [DecidableEq α]
    (S : Finset α) (hS : S.Nonempty) :
    ∀ n : ℕ, tropicalPerturbationBound (powFinsetProduct S n)
      = n * tropicalPerturbationBound S
```

This is the real amplification theorem, analogous to block coding exponents.

# Concrete intermediate lemmas to target

These are likely formalization-critical and reusable:

```lean
theorem finset_card_product'
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β) :
    (S.product T).card = S.card * T.card
```

```lean
theorem nonempty_product
    {α β : Type*} (S : Finset α) (T : Finset β) :
    S.Nonempty → T.Nonempty → (S.product T).Nonempty
```

If the exact formula involves logs or natural logs:

```lean
theorem log_card_product
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β)
    (hS : S.Nonempty) (hT : T.Nonempty) :
    Real.log ((S.product T).card : ℝ)
      = Real.log (S.card : ℝ) + Real.log (T.card : ℝ)
```

with positivity discharged from nonemptiness.

If it involves maxima over separable product costs, prove a tropical separability lemma:

```lean
theorem finset_sup_product_separable
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β) (f : α → ℝ) (g : β → ℝ) :
    (S.product T).sup (fun p => f p.1 + g p.2)
      = S.sup f + T.sup g
```

or the corresponding `inf` version if the semiring is min-plus.

# Cross-domain connections you should explicitly exploit

## 1. Information theory
Additivity under products is the formal signature of extensive quantities:
- entropy of independent systems,
- KL divergence tensorization,
- error exponents.

If your theorem is proved, it becomes plausible to define a tropical entropy on finite supports and prove a data-processing-like inequality later.

## 2. Complexity theory
Direct-product theorems say solving many independent instances costs proportionally more. Your product-additivity theorem is the tropical analog of a direct-sum principle.

Connect it to `boundedWordCount_linear_times_exponential`: after exponentiation, additive tropical complexity often becomes multiplicative count growth.

## 3. Statistical mechanics / thermodynamics
Tropicalization often turns partition functions into max-energy principles. Additivity on products corresponds to extensivity of free energy for independent subsystems.

This is a scientifically powerful narrative and may guide future definitions.

## 4. Logic and semantics
Via `formula_has_term`, product amplification may correspond to combining independent semantic constraints. This hints at a tropical proof complexity invariant.

# Strong corollaries worth attempting immediately after the main theorem

## Corollary 1: n-fold amplification
For iterated products of one support:

```lean
theorem tropical_perturbation_exact_bound_pow
    {α : Type*} [DecidableEq α]
    (S : Finset α) (hS : S.Nonempty) :
    ∀ n : ℕ, tropicalPerturbationBound (iteratedProduct S n)
      = n * tropicalPerturbationBound S
```

This is the true amplification law.

## Corollary 2: exponential multiplicativity after exponentiation
If the exact bound is logarithmic:

```lean
theorem tropical_perturbation_exp_multiplicative
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β)
    (hS : S.Nonempty) (hT : T.Nonempty) :
    Real.exp (tropicalPerturbationBound (S.product T))
      = Real.exp (tropicalPerturbationBound S) *
        Real.exp (tropicalPerturbationBound T)
```

This makes the automata/counting connection explicit.

## Corollary 3: closure-growth compatibility
Seek a theorem of the form:

```lean
theorem closure_tropical_amplification_compat
    ... :
    closureComplexity (productSystem A B)
      ≤ C * (tropicalPerturbationBound SA + tropicalPerturbationBound SB)
```

Even a weak version would bridge two catalog islands.

# Lean 4 formalization guidance

Use concrete finite types first:
- `Finset α`, `Finset β`
- codomain `ℕ` or `ℝ`
- avoid abstract semiring generality until the theorem is stable.

Recommended workflow:
1. Inspect the exact statement of `tropical_perturbation_exact_bound`.
2. Define a local abbreviation for the closed-form quantity it computes.
3. Prove product/cardinality/log lemmas independently.
4. Rewrite the target theorem entirely into arithmetic.
5. Only then package corollaries.

If the current theorem is awkwardly specialized, introduce a clean wrapper definition:
```lean
def tropicalPerturbationBound {α : Type*} [DecidableEq α] (S : Finset α) : ℝ := ...
```
and prove equivalence to the catalog theorem before attacking amplification.

# If amplification equality fails

Do not stall. Pivot to a structurally valuable inequality theorem:
- subadditivity,
- superadditivity,
- or asymptotic Fekete-style existence of a rate.

A fallback theorem with real depth is:

```lean
theorem exists_tropical_amplification_rate
    {α : Type*} [DecidableEq α]
    (S : Finset α) (hS : S.Nonempty) :
    ∃ L : ℝ, Tendsto
      (fun n : ℕ => tropicalPerturbationBound (iteratedProduct S (n+1)) / (n+1 : ℝ))
      atTop (𝓝 L)
```

This would open asymptotic tropical complexity theory.

# Application keywords

tropical geometry, tensorization, direct-product theorem, formal complexity theory, information theory, entropy, statistical mechanics, free energy, automata growth, closure systems, compositional verification, semantic complexity, Lean 4, Mathlib

# Deliverables

1. Lean theorem(s) proving the amplification/product result.
2. Any supporting definitions/lemmas needed for a reusable API.
3. At least one corollary connecting the theorem to another catalog domain.
4. Minimize sorry aggressively.
5. Produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps at breakthrough level.

# Required FUTURE_DIRECTIONS.md content

Your `FUTURE_DIRECTIONS.md` must include specific next targets such as:
1. n-fold tropical amplification and asymptotic rate theorems,
2. tropical data-processing inequality / entropy formalization,
3. closure-theoretic tensorization using `closure_iteration_linear_bound`,
4. automata counting duality via `boundedWordCount_linear_times_exponential`,
5. logical product semantics via `formula_has_term`.

Do not write a generic note. Write a research agenda that could found a new subfield.

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
