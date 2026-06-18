## Assignment: High impact (new theory)

Mode: **prove**

Prove genuinely new, non-trivial theorems that found a **tropical information theory** inside Lean 4, not as metaphor but as a mathematically usable calculus on finite channels and finite distributions. Build on catalog theorems where they give certified tropical inequalities, but do not stay local to those statements. The target is a first rigorous bridge between **tropical algebra, entropy-like functionals, and data-processing phenomena**.

Minimize sorry. If a full strongest theorem resists formalization, first prove the finite/discrete sharp core and then package the definitions so the next cycle can generalize.

### Research Direction
**Tropical mutual information**, with a precise finite-state theorem establishing a tropical analogue of the data processing inequality.

### Mathematical Framing
Classical mutual information is built from sums and logarithms; tropical mathematics replaces addition/multiplication by max-plus or min-plus operations. The breakthrough is to identify a finite combinatorial functional that behaves like information flow under deterministic coarse-graining and channel composition.

The right first step is not to imitate Shannon entropy verbatim, but to define a **support-sensitive tropical information functional** on finite weighted relations, prove monotonicity under composition, and isolate exactly where tropical convexity enters.

You should aim to show that tropical information is not merely an analogy, but a **monotone resource** under tropical channels. That would open a new field: tropical coding theory, tropical statistical decision theory, tropical Markov semantics, and potentially tropical analogues of rate-distortion and representation learning.

---

## Primary theorem target

Work in finite types. Let `X Y Z` be finite index types. Let a tropical channel be a matrix of real weights
`K : X → Y → ℝ`, interpreted in max-plus algebra. For each input `x`, define its tropical support profile on outputs by the argmax set of `K x ·`. For a deterministic post-processing map `g : Y → Z`, define the pushed channel
`K ▷ g : X → Z → ℝ` by
`(K ▷ g) x z = sup { K x y | g y = z }`,
implemented over finite types as a `Finset.sup`.

Define the **tropical distinguishability**
between two inputs `x₁, x₂` through channel `K` as
the output-side separation
`δ_K(x₁,x₂) = sup_y (K x₁ y - K x₂ y) + sup_y (K x₂ y - K x₁ y)`.

Then define the **tropical mutual information functional**
of `K` by taking the maximum pairwise distinguishability:
`TMI(K) = sup_{x₁,x₂} δ_K(x₁,x₂)`.

This is not Shannon MI; it is a tropical information radius. But it is the correct formal starting point because it is:
- finite,
- nontrivial,
- channel-theoretic,
- monotone under deterministic post-processing,
- compatible with tropical spectral and convex inequalities.

### Exact theorem statement
Prove that deterministic post-processing cannot increase tropical mutual information.

#### Lean 4 target signature
```lean
theorem tropical_mutual_information_data_processing
  {X Y Z : Type} [Fintype X] [Fintype Y] [Fintype Z]
  [DecidableEq X] [DecidableEq Y] [DecidableEq Z]
  (K : X → Y → ℝ) (g : Y → Z) :
  tropicalMutualInformation (postprocess K g) ≤ tropicalMutualInformation K
```

You will need to define:
```lean
def postprocess
  {X Y Z : Type} [Fintype Y] [Fintype Z] [DecidableEq Z]
  (K : X → Y → ℝ) (g : Y → Z) : X → Z → ℝ := ...

def tropicalDist
  {X Y : Type} [Fintype Y]
  (K : X → Y → ℝ) (x₁ x₂ : X) : ℝ := ...

def tropicalMutualInformation
  {X Y : Type} [Fintype X] [Fintype Y]
  (K : X → Y → ℝ) : ℝ := ...
```

A robust concrete implementation is to use `Finset.univ.sup` with a default witness where needed, or to work first with `sInf`/`iSup` only if that is cleaner in Mathlib. Since all types are finite, a `Finset` implementation is likely easiest.

---

## Stronger theorem target if the first lands cleanly

Prove a **tensorization/subadditivity theorem** for product channels.

For channels `K₁ : X₁ → Y₁ → ℝ` and `K₂ : X₂ → Y₂ → ℝ`, define the product channel by tropical addition:
`(K₁ ⊗ K₂) (x₁,x₂) (y₁,y₂) = K₁ x₁ y₁ + K₂ x₂ y₂`.

Then aim for:
```lean
theorem tropical_mutual_information_tensor_le
  {X₁ Y₁ X₂ Y₂ : Type}
  [Fintype X₁] [Fintype Y₁] [Fintype X₂] [Fintype Y₂]
  (K₁ : X₁ → Y₁ → ℝ) (K₂ : X₂ → Y₂ → ℝ) :
  tropicalMutualInformation (tensorChannel K₁ K₂)
    ≤ tropicalMutualInformation K₁ + tropicalMutualInformation K₂
```

If possible, sharpen to equality under a carefully chosen definition of `tropicalDist`; but subadditivity alone is already field-opening.

---

## Foundational lemmas you should likely prove first

### 1. Supremum contraction under deterministic aggregation
For any `f : Y → ℝ` and `g : Y → Z`,
```lean
theorem finset_sup_fiber_le_sup
  {Y Z : Type} [Fintype Y] [Fintype Z] [DecidableEq Z]
  (f : Y → ℝ) (g : Y → Z) :
  (Finset.univ.sup fun z : Z => Finset.univ.sup fun y : {y // g y = z} => f y) ≤
  Finset.univ.sup f
```
You may want a cleaner formulation using image fibers or by proving pointwise:
`(postprocess K g) x z ≤ sup_y K x y`.

### 2. Pairwise distinguishability contracts under post-processing
```lean
theorem tropicalDist_postprocess_le
  {X Y Z : Type} [Fintype X] [Fintype Y] [Fintype Z]
  [DecidableEq Y] [DecidableEq Z]
  (K : X → Y → ℝ) (g : Y → Z) (x₁ x₂ : X) :
  tropicalDist (postprocess K g) x₁ x₂ ≤ tropicalDist K x₁ x₂
```

### 3. Globalization from pairwise to channel functional
```lean
theorem tropicalMutualInformation_mono
  {X Y₁ Y₂ : Type} [Fintype X] [Fintype Y₁] [Fintype Y₂]
  (K₁ : X → Y₁ → ℝ) (K₂ : X → Y₂ → ℝ)
  (h : ∀ x₁ x₂, tropicalDist K₂ x₁ x₂ ≤ tropicalDist K₁ x₁ x₂) :
  tropicalMutualInformation K₂ ≤ tropicalMutualInformation K₁
```

These three lemmas form the skeleton. Once established, the main theorem should become a short composition.

---

## Why this is a breakthrough

A proof of tropical data processing would create the first formalized monotone-information principle in tropical mathematics. That is not an incremental variant of existing entropy inequalities; it is the seed of an entire parallel information theory where:
- channels are max-plus kernels,
- coarse-graining is tropical matrix composition,
- information is distinguishability radius,
- representation collapse and feature extraction become tropical contractions.

This opens at least four new directions:
1. **Tropical coding theory**: define code separation and prove converse bounds.
2. **Tropical learning theory**: information loss under layer compression for max-plus neural models.
3. **Tropical Markov processes**: monotone observability and identifiability under coarse observation.
4. **Idempotent statistical mechanics**: zero-temperature limits of relative entropy and free energy.

This is the kind of theorem that makes mathematicians say: “There is an information theory hidden in tropical algebra.”

---

## How to build on the catalog theorems

The listed theorems are simple footholds, but they suggest the algebraic environment:
- `tropical_mirror_theorem` shows idempotent collapse `max a a = a`. Use this philosophy repeatedly: tropical aggregation should not create new distinguishability.
- `tropical_spectral_bound` is especially important conceptually. Once TMI is defined, you should investigate whether tropical channel information is bounded by a spectral radius or tropical operator seminorm. Even if not used in the first proof, architect definitions so this follow-on theorem becomes natural.
- `tropical_young_ineq` suggests a path through tropical convex duality. Distinguishability may admit a dual formulation as a support functional, which would make data processing a corollary of monotonicity under pushforward.
- `birthday_bound_tropical_hash` hints at hashing/collision applications: post-processing merges outputs, so information contraction should imply collision amplification bounds.
- `tropical_fundamental_theorem_of_arithmetic` is less directly relevant, but it indicates that factorization phenomena are already being tropicalized in the library. You should explicitly frame TMI as the information-theoretic analogue of a tropical invariant.

Do not force these theorems into the proof if they are not mathematically needed. Instead, use them to shape the next layer of results.

---

## Proof strategy options

### Strategy A: Direct finite sup/argmax proof
This is the most promising initial route.

1. **Define `postprocess` by finite fiber sup** over `g`.
   For each fixed `x,z`, show `(postprocess K g) x z ≤ sup_y K x y`, and similarly for the difference terms.
2. **Prove contraction of one-sided separation**
   `sup_z ((postprocess K g) x₁ z - (postprocess K g) x₂ z) ≤ sup_y (K x₁ y - K x₂ y)`.
   The key inequality is
   `sup_i a_i - sup_i b_i ≤ sup_i (a_i - b_i)`
   on finite families.
3. Apply this inequality in both directions and sum to get
   `tropicalDist (postprocess K g) x₁ x₂ ≤ tropicalDist K x₁ x₂`,
   then take the supremum over `x₁,x₂`.

Why most promising: it is elementary, finite, and Lean-friendly. No measure theory, no probability simplex, no topology.

### Strategy B: Tropical seminorm/operator proof
Define
`φ_K(x₁,x₂) = sup_y (K x₁ y - K x₂ y)`,
a max-plus analogue of a projective or oscillation seminorm.

1. Show post-processing is a monotone map on output potentials.
2. Show `φ_{K▷g} ≤ φ_K` because deterministic aggregation cannot enlarge oscillation.
3. Observe `tropicalDist K x₁ x₂ = φ_K(x₁,x₂) + φ_K(x₂,x₁)` and conclude.

Why powerful: this reveals the theorem as a contraction in tropical functional analysis, connecting directly to `tropical_spectral_bound`. This is likely the best conceptual packaging even if Strategy A supplies the formal details.

### Strategy C: Convex-dual/tropical Young route
Use `tropical_young_ineq` to interpret the one-sided separation as a support functional against indicator-like test functions.

1. Express tropical distinguishability through a dual bound.
2. Show deterministic pushforward restricts the test-function class.
3. Conclude monotonicity as a duality consequence.

Why valuable: harder to formalize first, but if successful it immediately points toward tropical f-divergences and a richer information geometry.

Recommendation: **Implement Strategy A fully, package the definitions in the seminorm language of Strategy B, and record Strategy C in FUTURE_DIRECTIONS.md.**

---

## Cross-domain connections you must exploit

### 1. Information theory × tropical geometry
Interpret post-processing as collapsing tropical polyhedral cells in output space. Then data processing says polyhedral collapse cannot increase distinguishability radius. This is the geometric heart of the theorem.

### 2. Statistical decision theory × max-plus algebra
A channel encodes utilities/costs rather than probabilities. Tropical mutual information measures how well outputs preserve pairwise decision separation between inputs. This gives an idempotent analogue of Blackwell informativeness.

### 3. Spectral theory × dynamical systems
The one-sided separation functional behaves like an operator seminorm. This suggests future bounds of the form:
`tropicalMutualInformation K ≤ C * tropicalSpectralRadius K`.
If this bridge is made later, tropical information flow becomes a dynamical invariant.

### 4. Machine learning × representation collapse
Deterministic post-processing models feature compression or layer pooling. The theorem becomes a rigorous statement that tropical feature maps cannot increase pairwise information radius. This is directly relevant to certifiable robustness and max-plus neural representations.

### 5. Hashing × collision complexity
Coarse-graining outputs merges fibers, increasing collisions. Tropical data processing should imply lower bounds on distinguishability after hashing, connecting to `birthday_bound_tropical_hash`.

---

## Application keywords
tropical information theory, data processing inequality, max-plus channels, idempotent entropy, tropical distinguishability, coarse-graining, channel contraction, tropical coding theory, tropical learning theory, tropical decision theory, spectral seminorms, finite-state channels, hashing collisions, representation compression

---

## Lean design guidance

Use concrete finite types first:
- `Fin n`
- `Matrix (Fin m) (Fin n) ℝ`
- `Fintype`/`DecidableEq` abstractions after the first core proof works.

A matrix-specialized theorem may be easier to prove first:
```lean
theorem tropical_mutual_information_data_processing_matrix
  {m n k : ℕ}
  (K : Matrix (Fin m) (Fin n) ℝ)
  (g : Fin n → Fin k) :
  tropicalMutualInformation (postprocessMatrix K g) ≤ tropicalMutualInformation K
```
Then generalize.

If `Finset.sup` over `ℝ` becomes awkward because of order-theoretic side conditions, use `sSup` on finite sets converted to `Set.range`, or define with `max'` on nonempty finite types. Since `Fintype` gives nonemptiness only if inhabited, you may need explicit `[Inhabited Y]` or theorem variants for `Finite` plus `Nonempty`. It is acceptable to assume nonempty finite types if that simplifies the first theory.

---

## Deliverables

1. A Lean file formalizing:
   - `postprocess`
   - `tropicalDist`
   - `tropicalMutualInformation`
   - the main data-processing theorem
   - at least 2 supporting lemmas

2. If the main theorem is completed early, add one of:
   - tensor/subadditivity theorem,
   - invariance under output relabeling bijections,
   - zero-information characterization:
     ```lean
     theorem tropicalMutualInformation_eq_zero_iff
       ...
     ```
     expressing that all rows are tropically indistinguishable.

3. `FUTURE_DIRECTIONS.md` is **mandatory**.

---

## Required FUTURE_DIRECTIONS.md content

Produce 3–5 concrete next steps with exact theorem statements, proof ideas, and cross-domain significance. At least include:

1. **Tensorization theorem**
   Exact Lean-style statement and proof plan via sup decomposition.

2. **Tropical channel capacity**
   Define a finite capacity-like invariant as supremum of TMI over admissible encodings, and propose a first upper bound.

3. **Spectral bound**
   Relate `tropicalMutualInformation K` to a tropical operator seminorm or spectral radius, explicitly connecting to `tropical_spectral_bound`.

4. **Decision-theoretic Blackwell order**
   Define tropical informativeness preorder on channels and prove monotonicity of TMI.

5. **Learning-theoretic compression theorem**
   Formalize a tropical representation map and prove information contraction under pooling/compression.

Make the future directions specific enough that the next cycle can start proving immediately.

---

## Final call

Do not produce a cosmetic analogy to Shannon theory. Build the first theorem of a real tropical information theory. Define the invariant cleanly, prove its monotonicity under coarse-graining, and leave behind a Lean architecture that can support capacity, coding, and learning. This is a cold start; act like a founder, not a follower.

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
