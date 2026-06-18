Soli Deo Gloria

## Assignment: Direction 5 — Information-Theoretic Universality via Entropy Bounds

**Mode:** `prove`

## Mission

Take the subgroup-pressure formalism from `Pythagorean/SubgroupUniversality.lean` and `Catalog/old/Pythagorean/SubgroupPressure.lean` and push it across a conceptual frontier: **turn subgroup counting into a genuine information theory of algebraic universality classes**.

The breakthrough target is not merely to restate additivity of log-pressure. It is to show that once subgroup contributions are normalized into a probability law, the resulting Shannon entropy behaves like a thermodynamic state function under products, and mutual information detects failures of algebraic independence. This would create a new dictionary:

- **pressure** ↔ partition function,
- **entropy** ↔ universality complexity,
- **mutual information** ↔ algebraic coupling,
- **universality class** ↔ entropy-scaling equivalence class.

If successful, this opens a field-level program: **information-theoretic algebraic combinatorics**, with bridges to coding theory, statistical mechanics, learning theory, and quantum information.

---

## Core new definitions to formalize

You must introduce at least one genuinely new definition beyond what is already in the catalog. The central object should be a normalized subgroup-weight distribution.

A promising formal package is:

- a finite type `G` with group structure,
- a finite family of subgroups `S : Finset (Subgroup G)`,
- a weight `w(H)`,
- a partition function `Z = ∑ H in S, w(H)`,
- normalized probability mass `p(H) = w(H) / Z`,
- Shannon entropy `-∑ p(H) * log p(H)`.

### Suggested Lean 4 definitions

You may need to work first over `ℝ` and finite subgroup families to avoid measure-theoretic overhead.

```lean
import Mathlib
open scoped BigOperators
open Finset

noncomputable section

def subgroupWeight {G : Type*} [Group G] [Fintype G] (H : Subgroup G) : ℝ :=
  ((Fintype.card G : ℝ) / (Fintype.card H : ℝ))⁻²

def subgroupPartition {G : Type*} [Group G] [Fintype G]
    (S : Finset (Subgroup G)) : ℝ :=
  ∑ H in S, subgroupWeight H

def subgroupProb {G : Type*} [Group G] [Fintype G]
    (S : Finset (Subgroup G)) (H : Subgroup G) : ℝ :=
  subgroupWeight H / subgroupPartition S

def subgroupEntropy {G : Type*} [Group G] [Fintype G]
    (S : Finset (Subgroup G)) : ℝ :=
  - ∑ H in S, subgroupProb S H * Real.log (subgroupProb S H)

def subgroupSelfInfo {G : Type*} [Group G] [Fintype G]
    (S : Finset (Subgroup G)) (H : Subgroup G) : ℝ :=
  - Real.log (subgroupProb S H)
```

If direct use of all subgroups is too difficult computationally, define entropy for an **admissible finite family** of subgroups and prove theorems there first. That is mathematically honest and likely the right abstraction.

A second novel definition should capture product independence at the level of subgroup families:

```lean
def IsProductClosedFamily
    {G K : Type*} [Group G] [Fintype G] [Group K] [Fintype K]
    (SG : Finset (Subgroup G)) (SK : Finset (Subgroup K))
    (SGK : Finset (Subgroup (G × K))) : Prop := ...
```

Or, more realistically, define the embedded product family explicitly and prove entropy additivity for that family.

---

## Precise theorem targets

You need at least 3 serious theorems. Here is the exact research spine.

### Theorem 1: normalization and positivity

This is foundational and should not be trivialized. Prove that the normalized subgroup weights define a probability distribution on any nonempty finite family.

```lean
theorem subgroupProb_nonneg
    {G : Type*} [Group G] [Fintype G]
    (S : Finset (Subgroup G)) (hS : S.Nonempty) (H : Subgroup G) :
    0 ≤ subgroupProb S H := by
  ...

theorem subgroupProb_sum_eq_one
    {G : Type*} [Group G] [Fintype G]
    (S : Finset (Subgroup G)) (hS : S.Nonempty) :
    ∑ H in S, subgroupProb S H = 1 := by
  ...
```

**Why it matters:** this is the moment the subgroup-pressure framework becomes a genuine probabilistic theory rather than a suggestive analogy.

---

### Theorem 2: exact entropy additivity for product families

This is the decisive theorem. Do not settle for vague asymptotics if exact finite additivity is accessible for product families.

Let `SG : Finset (Subgroup G)` and `SK : Finset (Subgroup K)`. Define the product family
`SG.product SK` pushed forward to subgroups of `G × K` via `H × K`.

You want an exact theorem of the form:

```lean
theorem subgroupEntropy_prod_eq_add
    {G K : Type*}
    [Group G] [Fintype G] [Group K] [Fintype K]
    (SG : Finset (Subgroup G)) (SK : Finset (Subgroup K))
    (hSG : SG.Nonempty) (hSK : SK.Nonempty) :
    subgroupEntropy (productSubgroupFamily SG SK)
      = subgroupEntropy SG + subgroupEntropy SK := by
  ...
```

You will need a precise definition of `productSubgroupFamily`.

The proof should build on the catalog’s product factorization theorem for pressure / partition function:
- if the catalog already proves a theorem morally of the form
  `Z(G × K) = Z(G) * Z(K)`,
  then **reuse it explicitly**;
- if not available in the exact finite-family form you need, prove the finite-family analogue.

**Mathematical content:** if
`p_{H×L} = p_H p_L`,
then Shannon entropy satisfies
`H(p ⊗ q) = H(p) + H(q)`.
This is a real theorem, not bookkeeping.

---

### Theorem 3: mutual information vanishes for exact product families

Define mutual information of the product-family law relative to its marginals and prove it is zero.

Suggested definition:

```lean
def subgroupMutualInformation
    {G K : Type*}
    [Group G] [Fintype G] [Group K] [Fintype K]
    (SG : Finset (Subgroup G)) (SK : Finset (Subgroup K)) : ℝ := ...
```

Then prove:

```lean
theorem subgroupMutualInformation_prod_eq_zero
    {G K : Type*}
    [Group G] [Fintype G] [Group K] [Fintype K]
    (SG : Finset (Subgroup G)) (SK : Finset (Subgroup K))
    (hSG : SG.Nonempty) (hSK : SK.Nonempty) :
    subgroupMutualInformation SG SK = 0 := by
  ...
```

Equivalent formulations are acceptable:
- via KL divergence of joint from product marginals,
- via `I(X;Y) = H(X) + H(Y) - H(X,Y)` plus Theorem 2.

**Why it is a breakthrough:** this is the first algebraically natural family in your program where independence is not metaphorical but formally exact.

---

## Strong extension theorem: entropy bound from support size

To move beyond formal translation, prove a nontrivial entropy inequality connecting algebraic subgroup complexity to combinatorial support size.

```lean
theorem subgroupEntropy_le_log_card
    {G : Type*} [Group G] [Fintype G]
    (S : Finset (Subgroup G)) (hS : S.Nonempty) :
    subgroupEntropy S ≤ Real.log (S.card : ℝ) := by
  ...
```

This is a classical information-theoretic inequality, but in your setting it becomes a **universal upper bound on algebraic complexity of subgroup families**. It gives a rigorous notion of universality class compression: two families with entropy close to `log |S|` are maximally spread, while low entropy indicates concentration on a few dominant subgroup scales.

If the full theorem is technically heavy, prove a specialized version first:
- for uniform weights,
- or under a boundedness hypothesis ensuring positivity,
- then state the general conjecture sharply.

---

## Cross-domain theorem requirement

You must include at least one theorem that bridges to another mathematical domain. The best bridge here is statistical mechanics or coding theory.

### Option A: statistical mechanics bridge
Define the surprisal as an “energy”
`E(H) = -log p(H)`,
and prove expectation equals entropy:

```lean
theorem subgroupEntropy_eq_expected_selfInfo
    {G : Type*} [Group G] [Fintype G]
    (S : Finset (Subgroup G)) (hS : S.Nonempty) :
    subgroupEntropy S
      = ∑ H in S, subgroupProb S H * subgroupSelfInfo S H := by
  ...
```

This is the Gibbs identity in a subgroup ensemble. It creates a direct bridge to thermodynamics.

### Option B: coding-theoretic bridge
Interpret `subgroupSelfInfo` as ideal code length and prove a lower bound for any prefix-free code model if you formalize one abstractly. Even a weaker theorem relating entropy to average self-information is acceptable.

### Option C: learning-theoretic bridge
Define entropy deficit
`log |S| - H(S)` as a concentration statistic and prove it is zero exactly for uniform subgroup distributions. This mirrors representation collapse / information bottleneck ideas.

---

## Precise asymptotic conjecture to state and test

Your original asymptotic claim should be sharpened. Exact product families likely give exact additivity, so the asymptotic error term should be reserved for **approximately independent families**, such as wreath products or semidirect products.

State a falsifiable conjecture such as:

```text
Conjecture (approximate entropy additivity for wreath products).
Let W_{n,m} = S_n ≀ S_m with the subgroup-weight distribution induced by index^-2 weights
on a canonical finite family of imprimitive subgroups. Then there exists an absolute C > 0 such that

| subgroupEntropy(W_{n,m}) - subgroupEntropy(S_n^m) - subgroupEntropy(S_m) |
≤ C * (log (n+m)) / min(n,m)

for all n,m ≥ 2.
```

Or more abstractly:

```text
Conjecture.
For any family of finite groups G_n ⋊ K_n with coupling complexity ε_n measured by deviation of
partition functions from multiplicativity, the subgroup mutual information satisfies

I_n ≤ C ε_n,

and hence entropy additivity fails only at the same scale as pressure non-multiplicativity.
```

This is falsifiable: compute the entropies and mutual information numerically for small `n, m`; if the bound fails systematically, the conjecture is wrong.

---

## Lean 4 type signatures to target

Use these or very close variants.

```lean
theorem subgroupProb_sum_eq_one
    {G : Type*} [Group G] [Fintype G]
    (S : Finset (Subgroup G)) (hS : S.Nonempty) :
    ∑ H in S, subgroupProb S H = 1 := by
  ...

theorem subgroupEntropy_prod_eq_add
    {G K : Type*}
    [Group G] [Fintype G] [Group K] [Fintype K]
    (SG : Finset (Subgroup G)) (SK : Finset (Subgroup K))
    (hSG : SG.Nonempty) (hSK : SK.Nonempty) :
    subgroupEntropy (productSubgroupFamily SG SK)
      = subgroupEntropy SG + subgroupEntropy SK := by
  ...

theorem subgroupMutualInformation_prod_eq_zero
    {G K : Type*}
    [Group G] [Fintype G] [Group K] [Fintype K]
    (SG : Finset (Subgroup G)) (SK : Finset (Subgroup K))
    (hSG : SG.Nonempty) (hSK : SK.Nonempty) :
    subgroupMutualInformation SG SK = 0 := by
  ...

theorem subgroupEntropy_eq_expected_selfInfo
    {G : Type*} [Group G] [Fintype G]
    (S : Finset (Subgroup G)) (hS : S.Nonempty) :
    subgroupEntropy S
      = ∑ H in S, subgroupProb S H * subgroupSelfInfo S H := by
  ...

theorem subgroupEntropy_le_log_card
    {G : Type*} [Group G] [Fintype G]
    (S : Finset (Subgroup G)) (hS : S.Nonempty) :
    subgroupEntropy S ≤ Real.log (S.card : ℝ) := by
  ...
```

If `subgroupEntropy_le_log_card` is too ambitious in one cycle, prove instead:

```lean
theorem subgroupEntropy_eq_log_card_of_uniform
    {G : Type*} [Group G] [Fintype G]
    (S : Finset (Subgroup G)) (hS : S.Nonempty)
    (hunif : ∀ H ∈ S, subgroupProb S H = (S.card : ℝ)⁻¹) :
    subgroupEntropy S = Real.log (S.card : ℝ) := by
  ...
```

This is still meaningful and nontrivial.

---

## Proof architecture: 3 viable strategies

### Strategy A — direct product-factorization and finite-sum calculus
**Most promising.**

1. Prove the partition function factorizes on product subgroup families:
   `subgroupPartition (productSubgroupFamily SG SK) = subgroupPartition SG * subgroupPartition SK`.
2. Deduce pointwise probability factorization:
   `p(H × L) = p(H) * p(L)`.
3. Expand entropy:
   `-∑ p(H)p(L) log(p(H)p(L))`,
   use `Real.log_mul` under positivity hypotheses,
   split the double sum into two terms,
   and simplify using `∑ p = 1`.

Why this is best: it aligns exactly with the catalog’s pressure product theorem and keeps the formalization finite and explicit. It also naturally yields mutual information zero as a corollary.

---

### Strategy B — entropy via KL divergence / convexity
**More conceptual, potentially stronger.**

1. Define the joint law on product subgroups and marginal laws.
2. Define KL divergence
   `D(P || Q) = ∑ p log(p/q)`.
3. Show for exact product families that the joint equals the product of marginals, hence divergence is zero.
4. Recover
   `I(X;Y) = D(P_{XY} || P_X ⊗ P_Y)` and
   `H(X,Y) = H(X) + H(Y) - I(X;Y)`.

Why it matters: this framework is the right one if you want approximate product results later. It turns error terms in pressure multiplicativity into information-theoretic stability bounds.

---

### Strategy C — thermodynamic formalism
**Best for cross-domain significance.**

1. Treat `subgroupWeight H` as a Boltzmann weight and `log subgroupPartition` as free energy.
2. Show entropy is the expectation of self-information.
3. Use product free-energy additivity from the catalog to infer entropy additivity through the Gibbs decomposition.

Why it is powerful: it situates subgroup universality inside statistical mechanics and points toward phase transitions, large deviations, and renormalization analogies.

---

## Catalog build instructions

You must explicitly inspect and reuse the following:

- `Pythagorean/SubgroupUniversality.lean`
- `Catalog/old/Pythagorean/SubgroupPressure.lean`

In particular, identify the exact theorem corresponding to pressure or partition multiplicativity under products. If there is a theorem analogous to `log_pressure_prod_eq_add`, use it as the backbone of Theorem 2 rather than reproving from scratch. The brief lineage should be:

- existing result: pressure / log-pressure additivity,
- new result: normalized subgroup law,
- breakthrough: entropy and mutual information structure.

Do not merely mention these files. Build your theorem statements so that the imported result genuinely shortens the proof.

---

## Formalization cautions

- Be careful with positivity hypotheses for `Real.log`.
- You may need lemmas showing subgroup weights are strictly positive:
  indices are positive finite-cardinality ratios, hence their inverse square is positive.
- For product families, ensure the map from `(H,L)` to a subgroup of `G × K` is injective on your chosen family representation, or define the family as an image with a no-dup proof.
- Avoid brittle theorem statements over all subgroups if enumeration is too expensive; finite admissible families are mathematically cleaner and algorithmically realistic.
- Do not hide difficulty behind `classical` and huge simp blocks alone; at least 3 theorems must use genuine multi-step reasoning.

---

## Computational / algorithmic deliverable

You must produce a **verified computational method**, not just theorem statements.

### Required algorithm
Implement a procedure that, given a finite group with a finite subgroup family:
1. computes subgroup weights,
2. normalizes them,
3. computes entropy,
4. for product families, computes joint entropy and verifies additivity numerically.

This can be formalized abstractly in Lean and demonstrated concretely in Python.

### `demo.py` should:
- compute entropy for explicit families such as:
  - cyclic groups `Z/nZ`,
  - small symmetric groups if computationally feasible,
  - direct products like `C₂ × C₃`, `C₂ × C₂`, `S₃ × C₂`,
- compare `H(G × K)` with `H(G) + H(K)`,
- estimate mutual information for exact products and approximately coupled families,
- test the conjecture on wreath-product-inspired surrogate families if full subgroup enumeration is hard.

The demo must be interactive enough to let a reader vary parameters.

---

## Application keywords

Use these explicitly in your writeup and paper metadata:

**Application keywords:** Shannon entropy, mutual information, subgroup growth, universality classes, statistical mechanics, free energy, coding theory, information bottleneck, quantum information, entanglement entropy, algebraic combinatorics, finite groups, product measures, KL divergence, thermodynamic formalism, symmetry complexity.

---

## Revolutionary significance

If you succeed, you will have done more than extend subgroup pressure. You will have created a **quantitative invariant of algebraic universality** that behaves exactly like entropy under composition. That reframes finite-group subgroup structure as an information-bearing object and suggests entirely new research programs:

- classify families of groups by entropy scaling rather than raw subgroup counts,
- detect hidden algebraic couplings via mutual information,
- compare algebraic and physical universality classes,
- transport techniques from coding theory and learning theory into finite-group asymptotics,
- define “entanglement” of semidirect and wreath product structures.

This is the kind of result that makes a mathematician say: *I did not expect subgroup combinatorics to admit an information-theoretic first law.*

---

## Mandatory deliverables

You must produce **all** of the following:

1. **A Lean file** with at least 3 nontrivial theorems proved using deep tactics such as induction, `rcases`, `by_contra`, `field_simp`, or substantial `calc` chains.
2. **At least one new definition** not already present in the catalog.
3. **At least one cross-domain theorem** linking subgroup entropy to information theory / statistical mechanics / coding theory.
4. **A falsifiable conjecture** with a concrete computational disproof test.
5. **A verified algorithm or computational method** for entropy computation and product verification.
6. **`demo.py`** demonstrating the result interactively.
7. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions; each direction must include the exact sentences:
   - “The key insight is ...”
   - “Why now?”
   At least one direction must bridge to a different domain.
8. **`RESEARCH_PAPER.md`** as a standalone scientific paper: motivation, definitions, theorem statements, proof ideas, significance, experiments, and next questions. A reader with no access to code must fully understand the discovery.
9. **`ARTICLE.md`** in Scientific American style for a broad audience. Do **not** focus on formal verification machinery; focus on the mathematics and why the ideas matter.

Minimize `sorry`. If a theorem is too hard in full generality, prove the strongest honest finite-family version you can, and state the sharper theorem as a conjecture with a test plan. The goal is not cosmetic completion. The goal is to found an information theory of subgroup universality.

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
DELIVERABLE 4 — Python Code: Demos, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  Show the math working.
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses, including 1-2 grand_challenge paradigm-shifting conjectures
and 2-3 solid extensions building directly on Catalog theorems.
MUST begin with a ## Synthesis section tying all directions together.
Each direction must use the structured format with explicit fields:
**Conjecture**, **Test**, **Impact**, **Catalog References**,
**Proof Strategy**, **Domain Bridges**, **Lineage**, **Ambition**.
Reference specific Catalog theorems by file path. Every hypothesis
must be daring enough to matter and specific enough to fail.


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
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Pythagorean
Research mode: prove
