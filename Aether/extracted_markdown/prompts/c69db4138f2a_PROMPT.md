## Assignment: Phase 1 (Months 1–3): Foundations

Prove new, non-trivial theorems that create a genuine bridge between certified robustness, tropical/residuated algebra, and computable benchmarking. Build on the catalog theorems aggressively. Minimize `sorry` by choosing statements whose core algebraic and order-theoretic skeleton already exists in Mathlib.

This phase should not merely “extend certified radii.” It should establish a formal language in Lean for **robustness as residuation**, so that certified radii become instances of a more general adjoint calculus on `WithBot ℝ`. That is the conceptual leap.

---

## Research Direction

### Primary Target: Certified radii as a residuated/order-theoretic phenomenon
Formalize Direction 2 as the first visible breakthrough:
prove that the certified radius construction is monotone, stable under tropical perturbation bounds, and naturally expressible through `WithBot ℝ` order structure.

### Secondary Target: Begin a residuated lattice framework on `WithBot ℝ`
Direction 3 is not bookkeeping. The goal is to make `WithBot ℝ` into a usable semantic universe for tropical and robustness arguments:
`⊔ = max`, `⊓ = min`, additive shift as tropical multiplication, and truncated subtraction as a candidate residuation mechanism.

### Tertiary Target: Benchmarking as theorem-guided computation
Direction 5 should produce executable benchmark objects whose correctness is certified by theorems, not post hoc numerics. Use concrete finite types and finite sets so Lean proofs and evaluation can coexist.

---

## Mathematical Framing

The decisive move is to unify three ideas:

1. **Certified radius bounds** from Lipschitz/margin inequalities,
2. **Residuated structure** on ordered extended reals, especially `WithBot ℝ`,
3. **Tropical algebraic semantics** where robustness is a separation-from-hypersurface phenomenon.

The breakthrough theorem family should show that a certified radius is not just an analytic estimate, but an **order-theoretic residual**: the largest perturbation budget compatible with a margin inequality. This opens a path from machine learning certification to lattice-theoretic optimization, tropical geometry, and eventually cryptographic hardness via certified separation bounds.

Build explicitly on:
- `certified_residuated_bound` from `Bridges/AlgebraTropicalMachineLearning/TropicalKernelMeanDuality.lean`
- `certified_entropy_extraction_Lipschitz_bound` from `Cryptography/EntropyExtraction/LeftoverHash.lean`
- `tropical_lattice_det_bound` from `Cryptography/TropicalOneWayFoundations.lean`

The intended synthesis is:
- `certified_entropy_extraction_Lipschitz_bound` gives a template for radius-style inequalities from Lipschitz control;
- `certified_residuated_bound` suggests that such inequalities admit a residual/adjoint interpretation;
- `tropical_lattice_det_bound` indicates a geometric-combinatorial certificate mechanism that may later encode robust regions through tropical determinants.

---

## Core Theorem Targets

### Theorem A: Monotonicity of certified radius under margin increase and Lipschitz decrease

Define the canonical scalar certified radius
\[
r(m,K) := \max(0, m/K)
\]
for `m, K : ℝ` with `0 < K`, interpreted as the perturbation radius guaranteed by a margin `m` and Lipschitz constant `K`.

Prove a precise monotonicity theorem:
\[
m_1 \le m_2,\quad 0 < K_2 \le K_1 \implies r(m_1,K_1) \le r(m_2,K_2).
\]

This is mathematically simple, but formally essential: it becomes the order-theoretic monotonicity law from which benchmark correctness and tropical stability can be derived.

### Lean 4 target signature
```lean
theorem certifiedRadius_mono
    {m₁ m₂ K₁ K₂ : ℝ}
    (hm : m₁ ≤ m₂)
    (hKpos : 0 < K₂)
    (hK : K₂ ≤ K₁) :
    max 0 (m₁ / K₁) ≤ max 0 (m₂ / K₂) := by
  ...
```

A stronger variant worth targeting:
```lean
theorem certifiedRadius_antitone_Lipschitz
    {m : ℝ} {K₁ K₂ : ℝ}
    (hKpos : 0 < K₂)
    (hK : K₂ ≤ K₁) :
    max 0 (m / K₁) ≤ max 0 (m / K₂) := by
  ...
```

And the margin monotonicity:
```lean
theorem certifiedRadius_monotone_margin
    {m₁ m₂ K : ℝ}
    (hK : 0 < K)
    (hm : m₁ ≤ m₂) :
    max 0 (m₁ / K) ≤ max 0 (m₂ / K) := by
  ...
```

### Why this matters
This theorem is the minimal algebraic law needed to turn certified radii into a compositional invariant. Once formalized, every later robustness theorem can reduce to monotonicity plus one bound-producing lemma.

---

### Theorem B: Radius as a residual witness on `WithBot ℝ`

Define a candidate residual operation on `WithBot ℝ` induced by subtraction:
\[
a \Rightarrow b := \text{the greatest } r \text{ such that } a + r \le b,
\]
with suitable handling of `⊥`.

A tractable first theorem is not full residuated lattice structure, but the adjunction law for real elements embedded into `WithBot ℝ`.

### Precise statement
For real `a b r`, viewed in `WithBot ℝ`,
\[
a + r \le b \iff r \le b - a.
\]

Then lift this to a `WithBot` statement on coercions. This is the seed from which residuation grows.

### Lean 4 target signature
```lean
theorem withBot_add_le_iff_le_sub
    {a b r : ℝ} :
    ((a : WithBot ℝ) + r ≤ b) ↔ (r ≤ b - a) := by
  ...
```

If coercion/instance issues obstruct this exact form, split into a pure real theorem first:
```lean
theorem real_add_le_iff_le_sub
    {a b r : ℝ} :
    a + r ≤ b ↔ r ≤ b - a := by
  ...
```
then prove a coercion lemma:
```lean
theorem withBot_coe_real_add_le_iff
    {a b r : ℝ} :
    (((a : WithBot ℝ) + r : WithBot ℝ) ≤ b) ↔ a + r ≤ b := by
  ...
```

A more ambitious theorem, if the definitions settle cleanly:
```lean
def wbotResidual (a b : WithBot ℝ) : WithBot ℝ := ...

theorem wbotResidual_adjoint
    (a b r : WithBot ℝ) :
    a + r ≤ b ↔ r ≤ wbotResidual a b := by
  ...
```

### Why this matters
If proved, this reframes certified radius as an adjoint computation rather than a hand-derived inequality. That is the conceptual bridge to tropical optimization, quantale semantics, and abstract interpretation.

---

### Theorem C: Finite benchmark certificate theorem

Construct a finite benchmark theorem on concrete types such as `Fin n → ℝ`, with a score function `f` and Lipschitz constant `K`, proving that a computed candidate radius is sound for all points in a finite perturbation set.

For example, with `S : Finset (Fin n → ℝ)` and center `x`, prove:
\[
(\forall y \in S,\ \|y-x\| \le r \to f(y) \ge 0)
\]
from a margin/Lipschitz hypothesis.

### Lean 4 target signature
```lean
theorem finite_certified_ball_nonneg
    {n : ℕ}
    (S : Finset (Fin n → ℝ))
    (f : (Fin n → ℝ) → ℝ)
    (x : Fin n → ℝ)
    (m K r : ℝ)
    (hK : 0 ≤ K)
    (hm : m ≤ f x)
    (hr : r ≤ max 0 (m / K))
    (hLip : ∀ y ∈ S, |f y - f x| ≤ K * ‖y - x‖) :
    ∀ y ∈ S, ‖y - x‖ ≤ r → 0 ≤ f y := by
  ...
```

You may need to adapt norms and finite-dimensional instances depending on Mathlib convenience; if necessary replace `‖y - x‖` with a coordinatewise `Finset.sup` or `∑ i, |y i - x i|` metric first. Concreteness beats elegance in Phase 1.

### Why this matters
This theorem turns abstract certification into executable benchmarking. It is the formal seed of a verified robustness testbed.

---

## Suggested Definitions

If needed, introduce a compact certified radius definition:
```lean
def certifiedRadius (m K : ℝ) : ℝ := max 0 (m / K)
```

For finite perturbation budgets:
```lean
def l1Dist {n : ℕ} (x y : Fin n → ℝ) : ℝ :=
  ∑ i, |x i - y i|
```

For a first-order residual on reals:
```lean
def residualReal (a b : ℝ) : ℝ := b - a
```

For `WithBot ℝ`, proceed cautiously. First formalize coercion-safe lemmas before attempting full typeclass infrastructure.

---

## Proof Strategy Architecture

### Strategy A: Analytic-order route for certified radii
Most promising for Theorem A and C.

1. Normalize everything to inequalities involving division by positive reals:
   use `div_le_div_of_nonneg_left`, `div_le_div_of_nonneg`, `le_max_left`, `max_le_iff`, and case splits on sign of `m`.
2. Factor monotonicity into two lemmas:
   monotone in margin, antitone in Lipschitz constant.
3. For finite benchmark certification, combine the Lipschitz hypothesis with
   \[
   f(y) \ge f(x) - K\|y-x\|
   \]
   and then substitute `f(x) ≥ m` and `K r ≤ m`.

Why promising: Mathlib already handles these order/division manipulations well, and this yields reusable lemmas for every later theorem.

---

### Strategy B: Residuation-first route on `WithBot ℝ`
Most promising for Theorem B.

1. Prove the adjunction law on plain `ℝ` first:
   `a + r ≤ b ↔ r ≤ b - a`.
2. Lift to `WithBot ℝ` only on coercions, avoiding immediate full generality with `⊥`.
3. Once the coercion lemmas are stable, define a partial residual or a total residual with conservative `⊥` behavior and prove the adjunction on the well-behaved fragment.

Why promising: direct full-residuated-lattice formalization on `WithBot ℝ` may trigger instance and edge-case complexity. A staged approach still creates the conceptual bridge and keeps sorry count low.

---

### Strategy C: Tropical reinterpretation route
Best for producing novelty and cross-domain impact, possibly after A and B are established.

1. Interpret margin certificates as tropical separations:
   robustness means remaining in a chamber where one affine form dominates others.
2. Use max-plus language to rewrite classifier margins as differences of tropical linear forms.
3. Connect the certified radius to distance from a tropical hypersurface or arrangement boundary.

Why promising: this is where the field-opening narrative emerges. It can leverage `tropical_lattice_det_bound` later to derive combinatorial/geometric robustness certificates.

---

## Cross-Domain Connections

### Tropical geometry
A certified radius can be interpreted as distance to a tropical decision boundary. Once formalized, robust classification regions become tropical polyhedral cells. This creates a bridge between neural certification and tropical stratification theory.

### Abstract interpretation / program semantics
Residuation is the algebra of weakest preconditions and resource bounds. A radius certificate as a residual suggests a semantics of “largest safe perturbation” analogous to program transformers.

### Cryptography
The catalog already contains entropy extraction and tropical one-way foundations. A verified certified radius framework could be repurposed as a **separation certificate** in cryptographic hardness landscapes: if outputs remain distinguishable under bounded perturbation, robustness becomes a complexity witness.

### Information theory
`certified_entropy_extraction_Lipschitz_bound` hints that entropy loss and perturbation stability may obey a common Lipschitz-residual calculus. This could eventually lead to certified information contraction theorems in tropical settings.

### Computational complexity
Finite certified benchmark theorems provide proof-producing test instances. This is the beginning of a complexity theory of formally verified robustness certificates.

---

## Application Keywords

certified robustness, tropical geometry, residuated lattice, `WithBot ℝ`, max-plus algebra, formal verification, Lean 4, Lipschitz certification, benchmark correctness, abstract interpretation, entropy extraction, cryptographic hardness, tropical decision boundaries, verified optimization, adjoint calculus

---

## Immediate Lean Priorities

1. Prove `real_add_le_iff_le_sub`.
2. Define `certifiedRadius` and prove its monotonicity lemmas.
3. Build one concrete finite benchmark theorem using `Fin n → ℝ` and a simple metric.
4. Only then attempt a partial `WithBot ℝ` residual interface.
5. If blocked, prove coercion lemmas and monotonicity facts instead of forcing a full algebraic instance too early.

---

## Build on Existing Verified Theorems

Existing theorems you should explicitly cite and attempt to reuse:
1. `bounded_berggren_orbit_in_lattice`
   from `Cryptography/BerggrenPythagoreanLattices.lean`
2. `extension_obstruction_communication_bound`
   from `Cryptography/CohomologicalCrypto/Commitments.lean`
3. `certified_entropy_extraction_Lipschitz_bound`
   from `Cryptography/EntropyExtraction/LeftoverHash.lean`
4. `tropical_lattice_det_bound`
   from `Cryptography/TropicalOneWayFoundations.lean`
5. `certified_residuated_bound`
   from `Bridges/AlgebraTropicalMachineLearning/TropicalKernelMeanDuality.lean`

Use them not decoratively but structurally:
- extract proof patterns from `certified_entropy_extraction_Lipschitz_bound`,
- align theorem naming and statement architecture with `certified_residuated_bound`,
- position `tropical_lattice_det_bound` as the future geometric certificate layer.

---

## Cold-Start Tactical Note

Since this is a cold start, if there are easily accessible `sorry_fill` opportunities for high-value known targets like `CarmichaelComposite` or `Fib_gcd_identity`, close them opportunistically only if they do not derail the main bridge program. The main mission is still to establish a new theorem cluster around certified radii and residuation.

---

## Deliverables

Required:
- Lean 4 code with minimized `sorry`
- `FUTURE_DIRECTIONS.md`

Optional:
- `ARTICLE.md`
- `RESEARCH_PAPER.md`
- `demo.py`
- `diagram.svg`

---

## Mandatory FUTURE_DIRECTIONS.md

Produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, each including:
1. a precise theorem statement,
2. a proposed Lean signature,
3. 2 proof strategies,
4. one cross-domain connection.

These next steps should be breakthrough-level, for example:
- full residuated lattice or quantale structure on tropical extended reals,
- tropical hypersurface distance as a certified robustness invariant,
- entropy-contraction theorems derived from residual robustness bounds,
- cryptographic distinguishability certificates via tropical separation,
- formal equivalence between margin certificates and tropical chamber stability.

---

## Team Directive

Create a research team process:
- one thread for theorem proving,
- one for definition design,
- one for computational experiments,
- one for cross-domain conjecture generation.

Iterate between them continuously. Use experiments to discover statements, then formalize only those with structural depth.

---

## Final Charge

Do not settle for a local lemma farm. The real target is a new formal paradigm:

**robustness certificates as residuated tropical invariants.**

Phase 1 succeeds if, by the end of three months, Lean contains:
- a usable certified radius API,
- the first adjunction/residual theorem on reals or `WithBot ℝ`,
- at least one finite certified benchmark theorem,
- and a clear path toward tropical-geometric and cryptographic applications.

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

Research domain: Cryptography
Research mode: prove
