## Assignment: Semantic Compression via Tropical Information Geometry

Mode: **prove**

You are not being asked for a metaphor. You are being asked to carve out a new mathematical interface between **information geometry**, **tropical/idempotent analysis**, and **semantic coding theory** in a form Lean can certify. The breakthrough target is to replace probabilistic “compression preserves likelihood” with a geometric theorem of the form:

> semantic compression is an **idempotent nearest-point projection** onto a tropical semantic model class, and the induced projection error is controlled by a tropical Fisher-type metric.

This would not be a variant of rate-distortion. It would be a new formal bridge: **semantic coding as tropical metric projection**.

Build from the catalog, especially:
- `optimal_adjoint_rate_distortion`
- `tropical_relu_idempotent`
- `finite_quotient_implies_finite_tropicalVC_and_compression`
- `tropical_sum_to_min`
- `tropical_plus_distributes_over_min`

The key is to formulate everything on finite spaces first, with concrete types such as `Fin n → ℝ`, `Finset`, and `Matrix`, so the theorems are strong but Lean-realistic.

---

## Core Definitions to Introduce

Work on a finite alphabet `α := Fin n` with `Fintype α`.

Interpret a source as a score function `s : α → ℝ`. Its tropical semantics are not the full score vector, but its **equivalence class modulo additive constants** and/or its **projection onto a semantic code family**.

### 1. Tropical semantic distortion
Define, for score functions `s c : α → ℝ`,
- the additive gauge-invariant distortion
\[
D_{\mathrm{sem}}(s,c) := \inf_{k \in \mathbb R}\ \max_{x : \alpha} |s(x) - c(x) - k|.
\]
This is the natural projective sup-distance on tropical affine space.

In Lean, first define the computable finite version via `sInf` over `Set.range`, or if that is awkward, define a more Lean-friendly surrogate:
\[
D^\sharp_{\mathrm{sem}}(s,c) := \max_{x} (s x - c x) - \min_{x} (s x - c x),
\]
which vanishes exactly when `s - c` is constant. This is often easier to prove with, and it is equivalent up to a factor of `2` to the inf-over-shifts version.

### 2. Tropical semantic code family
Let `C : Set (α → ℝ)` be a family closed under tropical convex combinations or at least under pointwise `min` and additive shifts. For first breakthrough theorems, use the finitely generated tropical hull:
\[
\operatorname{tconv}(G) := \{x \mapsto \min_{g \in G} (g(x)+w_g)\},
\]
for finite `G : Finset (α → ℝ)` and weights `w_g : ℝ`.

If full tropical convexity is too heavy in Lean, define a simpler **semantic prototype family**
\[
C_G := \{x \mapsto \min_{g \in G} (g(x)+t)\mid t \in \mathbb R\}
\]
or even the closure under pairwise `min` plus shifts.

### 3. Tropical Fisher seminorm
On a finite score vector `v : α → ℝ`, define
\[
\|v\|_{\mathrm{TF}} := \max_x v(x) - \min_x v(x).
\]
This is the tropical analogue of an information seminorm: it kills additive constants and measures semantic sensitivity.

For a pair `s,c`, define
\[
d_{\mathrm{TF}}(s,c) := \|(s-c)\|_{\mathrm{TF}}.
\]
This is immediately concrete and Lean-friendly.

This is the correct first theorem-scale object: not a full Riemannian tensor yet, but a certified idempotent information geometry on score space.

---

## Breakthrough Theorem Targets

### Theorem 1: Tropical semantic distortion equals projective oscillation
This is the foundational theorem. It says semantic distortion is exactly tropical Fisher oscillation.

#### Mathematical statement
For every finite alphabet `α` and score functions `s c : α → ℝ`,
\[
\inf_{k \in \mathbb R} \max_{x : \alpha} |(s x - c x) - k|
= \frac12\Big(\max_x (s x - c x) - \min_x (s x - c x)\Big).
\]

This is the exact tropical analogue of “best semantic recentering = half the oscillation.” It turns semantic compression into projective metric approximation.

#### Lean 4 target signature
```lean
theorem semanticDist_eq_half_range
  {n : ℕ} [NeZero n]
  (s c : Fin n → ℝ) :
  sInf {r : ℝ | ∃ k : ℝ, r = Finset.univ.sup (fun i => |(s i - c i) - k|)} =
    ((Finset.univ.sup (fun i => (s i - c i)) - Finset.univ.inf' Finset.univ Finset.univ_nonempty
      (fun i => (s i - c i))) / 2)
```

If this exact `sInf` formulation is too cumbersome, first prove the cleaner surrogate:

```lean
def tropicalFisherRange {n : ℕ} (v : Fin n → ℝ) : ℝ :=
  Finset.univ.sup v - Finset.univ.inf' Finset.univ Finset.univ_nonempty v

def semanticDistSharp {n : ℕ} (s c : Fin n → ℝ) : ℝ :=
  tropicalFisherRange (fun i => s i - c i)

theorem semanticDistSharp_eq_zero_iff
  {n : ℕ} [NeZero n] (s c : Fin n → ℝ) :
  semanticDistSharp s c = 0 ↔ ∃ k : ℝ, ∀ i, s i = c i + k
```

This surrogate theorem is already nontrivial and field-opening because it identifies **semantic equivalence** with **tropical projective collapse**.

#### Why this is a breakthrough
It gives a rigorous mathematical meaning to “preserving meaning rather than exact code length”: two messages are semantically identical iff they differ by a tropical gauge. This is the primitive theorem needed before any rate-distortion analogue can be reinterpreted semantically.

---

### Theorem 2: Idempotent tropical projection is optimal among semantic codes
Define the projection onto a finite semantic prototype family by pointwise tropical infimum:
\[
(\Pi_G s)(x) := \min_{g \in G} (g(x) + w_g^\ast),
\]
where the chosen weights minimize semantic distortion, or in the first formal version simply:
\[
(\Pi_G s)(x) := \min_{g \in G} \max(s(x),g(x))
\]
if you want an explicitly idempotent closure operator built from `max/min`.

But the cleanest first formalizable theorem is: for a finite family closed under pointwise `min`, the pointwise infimum is idempotent and is the greatest lower semantic approximation.

#### Mathematical statement
Let `C` be a finite set of score functions closed under pointwise `min`. Define
\[
(\Pi_C s)(x) := \min\{ c(x) \mid c \in C,\ c(x)\ge s(x)\ \forall x\}
\]
when the feasible set is nonempty. Then:
1. `Π_C s ∈ C`,
2. `Π_C (Π_C s) = Π_C s`,
3. if `c ∈ C` and `c ≥ s` pointwise, then `Π_C s ≤ c` pointwise.

This is a semantic compression theorem: the projection is the **best semantic code above the source** in idempotent order.

#### Lean 4 target signature
A simpler and more realistic finite-family version:
```lean
def pointwiseMinFamily {n : ℕ} (G : Finset (Fin n → ℝ)) : Fin n → ℝ :=
  fun i => G.inf' (by simpa using G.nonempty) (fun g => g i)

theorem pointwiseMinFamily_idempotent
  {n : ℕ} (G : Finset (Fin n → ℝ)) (hG : G.Nonempty) :
  pointwiseMinFamily ({pointwiseMinFamily G} : Finset (Fin n → ℝ)) = pointwiseMinFamily G
```

Then the real theorem:
```lean
theorem tropical_projection_idempotent_optimal
  {n : ℕ} (G : Finset (Fin n → ℝ)) (hG : G.Nonempty) :
  let π := pointwiseMinFamily G
  (pointwiseMinFamily ({π} : Finset (Fin n → ℝ)) = π) ∧
  (∀ g ∈ G, ∀ i, π i ≤ g i)
```

A more ambitious theorem if you define a closure family:
```lean
theorem tropical_projection_semantic_optimal
  {n : ℕ} [NeZero n]
  (C : Set (Fin n → ℝ))
  (hmin : ∀ a ∈ C, ∀ b ∈ C, fun i => min (a i) (b i) ∈ C)
  (s : Fin n → ℝ) :
  ∃ p ∈ C, (∀ i, p i ≤ s i) ∧
    (∀ q ∈ C, (∀ i, q i ≤ s i) → ∀ i, q i ≤ p i)
```

This is order-theoretic tropical projection. It is a new semantic coding primitive.

#### Why this is a breakthrough
This turns “compression” into **idempotent approximation by semantic prototypes**, not symbol elimination. It opens a formal language for prototype-based semantic coding, tropical autoencoders, and abstraction as projection in an idempotent geometry.

---

### Theorem 3: Tropical Fisher range bounds semantic distortion under projection
This is the headline theorem connecting geometry to coding.

#### Mathematical statement
For finite `α`, any score `s`, and any semantic code `c`,
\[
D_{\mathrm{sem}}^\sharp(s,c) \le d_{\mathrm{TF}}(s,c),
\]
trivially by definition in the surrogate form, but the nontrivial theorem is:

If `p = Π_C s` is the tropical projection onto a semantic code family `C`, then for all `c ∈ C`,
\[
d_{\mathrm{TF}}(s,p) \le d_{\mathrm{TF}}(s,c).
\]

That is: the tropical projection is **nearest-point optimal** for semantic distortion measured by tropical Fisher range.

#### Lean 4 target signature
```lean
def tropicalFisherDist {n : ℕ} (s c : Fin n → ℝ) : ℝ :=
  let d : Fin n → ℝ := fun i => s i - c i
  Finset.univ.sup d - Finset.univ.inf' Finset.univ Finset.univ_nonempty d

theorem tropical_projection_minimizes_fisherDist
  {n : ℕ} [NeZero n]
  (G : Finset (Fin n → ℝ)) (hG : G.Nonempty)
  (p : Fin n → ℝ)
  (hp : p ∈ G) :
  -- replace by your chosen projection predicate
  IsGreatest {x : ℝ | ∃ c ∈ G, x = - tropicalFisherDist p c} (- tropicalFisherDist p p)
```

This signature may be too abstract. A better formal target is to define `argmin` over a finite `Finset` and prove:
```lean
theorem exists_best_semantic_code
  {n : ℕ} [NeZero n]
  (G : Finset (Fin n → ℝ)) (hG : G.Nonempty)
  (s : Fin n → ℝ) :
  ∃ c ∈ G, ∀ d ∈ G, tropicalFisherDist s c ≤ tropicalFisherDist s d
```

Then separately prove idempotence if the minimizer is selected canonically by a tie-break.

#### Why this is a breakthrough
This is the first certifiable theorem saying: **semantic compression is nearest-point approximation in tropical information geometry**. That is a new field seed.

---

## Lean-Realistic Proof Strategies

### Strategy A: Finite oscillation geometry via max/min identities
Most promising for Theorem 1.

1. For `v : Fin n → ℝ`, let `M = max_i v i` and `m = min_i v i`.
2. Show for every `k`, `max_i |v i - k| ≥ (M - m)/2`.
3. Take `k = (M + m)/2` to attain equality.
4. Deduce the inf-over-shifts formula.

Why this is promising:
- Pure finite-dimensional real analysis.
- Uses only `Finset.sup`, `Finset.inf'`, linear order lemmas, and absolute value algebra.
- No measure theory, no manifolds, no topology.

This should be your first assault.

---

### Strategy B: Idempotent order-theoretic projection
Most promising for Theorem 2.

1. Define semantic code families as lower sets or min-closed families in `(α → ℝ, ≤)`.
2. Show pointwise `min` computes finite meets.
3. Prove the projection is a closure/interior operator depending on orientation:
   - monotone,
   - idempotent,
   - order-optimal.
4. Then derive semantic optimality under the tropical Fisher distortion when restricted to the family.

Why this is promising:
- Strong algebraic structure.
- Connects directly to `tropical_relu_idempotent`.
- Gives a reusable theorem schema for tropical autoencoders and semantic abstractions.

---

### Strategy C: Finite argmin existence + rate-distortion bridge
Most promising for connecting to catalog theorem `optimal_adjoint_rate_distortion`.

1. On finite prototype family `G`, prove existence of a minimizer of `tropicalFisherDist s ·`.
2. Interpret this as a semantic codebook theorem.
3. Compare with `optimal_adjoint_rate_distortion`: classical coding minimizes expected distortion; tropical semantic coding minimizes projective oscillation.
4. Prove a comparison lemma: if two code families induce the same finite quotient of semantic classes, then finite semantic complexity implies compressibility, invoking
   `finite_quotient_implies_finite_tropicalVC_and_compression`.

Why this matters:
- This is the bridge from geometric coding to statistical learning/compression theory.
- It upgrades the result from “interesting geometry” to “new compression principle.”

---

## Cross-Domain Connections You Should Exploit

### 1. Information Geometry × Tropical Geometry
Classical Fisher geometry measures local sensitivity of log-likelihood coordinates. Your tropical Fisher range measures **projective sensitivity of score profiles** under additive gauge. This is the idempotent shadow of information geometry.

### 2. Rate-Distortion × Semantic Coding
Use `optimal_adjoint_rate_distortion` as conceptual scaffolding: classical distortion counts reconstruction fidelity; your tropical distortion counts **semantic equivalence class fidelity**. The theorem should suggest a tropical adjoint rate-distortion principle.

### 3. Neural Architectures × Idempotent Projection
Use `tropical_relu_idempotent` as the microscopic prototype: idempotence is the algebraic fingerprint of semantic collapse. Compression layers in semantic architectures should be formalized as tropical projection operators.

### 4. VC/Compression × Finite Semantic Quotients
Use `finite_quotient_implies_finite_tropicalVC_and_compression` to argue that if semantic classes form a finite tropical quotient, then semantic compression is not just geometric but statistically learnable.

### 5. Ultrametrics / p-adics × Semantic Stability
The theorem `tropical_sum_to_min` points toward a non-Archimedean interpretation: semantic codes should be stable under dominance hierarchies just as p-adic addition tropicalizes to minima. This suggests robustness theorems for semantic compression under hierarchical perturbations.

---

## Suggested Definition/Proof Order

1. Define `tropicalFisherRange`.
2. Prove:
```lean
theorem tropicalFisherRange_nonneg ...
theorem tropicalFisherRange_eq_zero_iff_constant ...
theorem tropicalFisherRange_shift_invariant ...
```

3. Define `semanticDistSharp`.
4. Prove:
```lean
theorem semanticDistSharp_eq_tropicalFisherRange ...
theorem semanticDistSharp_eq_zero_iff ...
```

5. For a finite codebook `G`, prove existence of a best semantic code:
```lean
theorem exists_best_semantic_code ...
```

6. Define a canonical projection if possible.
7. Prove idempotence and optimality:
```lean
theorem projection_idempotent ...
theorem projection_optimal ...
```

8. Only after that, attempt the exact half-range theorem with `sInf`.

---

## Strong Intermediate Lemmas

These are likely to be the real engines.

```lean
theorem range_eq_zero_iff_exists_const
  {n : ℕ} [NeZero n] (v : Fin n → ℝ) :
  tropicalFisherRange v = 0 ↔ ∃ k : ℝ, ∀ i, v i = k
```

```lean
theorem range_sub_eq_zero_iff_projectively_equal
  {n : ℕ} [NeZero n] (s c : Fin n → ℝ) :
  tropicalFisherRange (fun i => s i - c i) = 0 ↔
    ∃ k : ℝ, ∀ i, s i = c i + k
```

```lean
theorem range_shift_invariant
  {n : ℕ} [NeZero n] (v : Fin n → ℝ) (k : ℝ) :
  tropicalFisherRange (fun i => v i + k) = tropicalFisherRange v
```

```lean
theorem abs_max_lower_bound_half_range
  {n : ℕ} [NeZero n] (v : Fin n → ℝ) (k : ℝ) :
  (Finset.univ.sup (fun i => |v i - k|)) ≥ tropicalFisherRange v / 2
```

```lean
theorem abs_max_midpoint_eq_half_range
  {n : ℕ} [NeZero n] (v : Fin n → ℝ) :
  let M := Finset.univ.sup v
  let m := Finset.univ.inf' Finset.univ Finset.univ_nonempty v
  Finset.univ.sup (fun i => |v i - (M + m)/2|) = (M - m)/2
```

These would be genuinely useful Mathlib-adjacent lemmas even outside this project.

---

## How to Use the Catalog Theorems

- `tropical_relu_idempotent`  
  Use as the simplest witness that idempotent nonlinearities naturally define projection-like semantic collapses. Generalize from scalar `max x 0` to finite-dimensional pointwise tropical operators.

- `tropical_plus_distributes_over_min`  
  Use to simplify tropical affine combinations and establish closure of code families under shifts/min.

- `tropical_sum_to_min`  
  Use as conceptual support for non-Archimedean semantic aggregation: when one meaning dominates, composition tropicalizes to a min-selection rule.

- `finite_quotient_implies_finite_tropicalVC_and_compression`  
  After proving finite semantic quotient theorems, connect them to learnability/compressibility of semantic classes.

- `optimal_adjoint_rate_distortion`  
  Use as the classical benchmark and formulate a comparison lemma or explanatory theorem showing tropical semantic coding is an idempotent analogue of rate-distortion optimization.

---

## Concrete Ambitious Theorem Extension

If the core theorems land, aim for this bolder finite theorem:

### Tropical semantic codebook theorem
Let `G` be a finite semantic prototype family on `Fin n`. Then every source `s` admits a code `c ∈ G` minimizing tropical semantic distortion, and the induced coding map factors through the quotient of score space by additive constants.

#### Lean shape
```lean
theorem semantic_code_factors_through_projective_quotient
  {n : ℕ} [NeZero n]
  (G : Finset (Fin n → ℝ)) (hG : G.Nonempty) :
  ∃ encode : (Fin n → ℝ) → (Fin n → ℝ),
    (∀ s, encode s ∈ G) ∧
    (∀ s, ∀ c ∈ G, tropicalFisherDist s (encode s) ≤ tropicalFisherDist s c) ∧
    (∀ s t, (∃ k : ℝ, ∀ i, s i = t i + k) → encode s = encode t)
```

This is the first precise theorem that says **semantic coding depends only on meaning-class, not raw score normalization**.

That is a true conceptual breakthrough.

---

## Application Keywords

tropical information geometry; semantic compression; idempotent projection; projective metric; Fisher information analogue; rate-distortion duality; tropical autoencoders; semantic codebooks; non-Archimedean learning; VC-compression bridge; min-plus approximation; gauge-invariant representation learning

---

## Deliverables

1. Formalize the core definitions in Lean 4 on finite spaces.
2. Prove at least one nontrivial exact theorem:
   - preferably `semanticDistSharp_eq_zero_iff`, or
   - the finite best-code existence theorem, or
   - the exact half-range theorem if feasible.
3. Prove at least one idempotence/projection theorem.
4. Minimize sorry aggressively.
5. Explicitly connect one theorem to one catalog theorem in comments/docstrings.
6. Produce `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - tropical semantic rate-distortion function on finite alphabets,
   - tropical mutual information and data processing inequality,
   - semantic compression for matrix-valued attention scores,
   - non-Archimedean robustness of semantic codes,
   - categorical semantics of idempotent encoders.

## Team Directive
Create a team to conduct research:
- **The Geometer**: define the tropical Fisher/projective metric cleanly.
- **The Lean Architect**: choose finite-space definitions that avoid topological overhead.
- **The Compression Theorist**: connect nearest-point projection to codebook optimality.
- **The Bridge Builder**: extract implications for VC/compression and adjoint rate-distortion.

Do not drift into vague philosophy. Force the semantics into exact finite-dimensional theorems and let the geometry speak.

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

Research domain: MachineLearning
Research mode: prove
