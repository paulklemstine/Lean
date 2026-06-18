## Assignment: Lorentz force analogue

**Mode:** prove

Prove a genuinely new theorem package formalizing a **discrete magnetic perturbation principle for tropical shortest-path geometry**. The core claim is that adding an antisymmetric “vector potential” perturbs tropical path length by at most the total flux budget seen along a path, yielding a graph-theoretic analogue of Lorentz-force deflection.

This should not be a vague exploration. Define the charged weight precisely, prove a sharp pathwise estimate, then lift it to a distance estimate. If possible, also isolate a gauge-invariance statement showing that exact potentials do not change cycle flux.

---

## Precise Mathematical Target

Work in a finite directed graph on a finite vertex type `V`, with edge weights `W : V → V → ℝ` and a bounded antisymmetric perturbation `A : V → V → ℝ`. Let `q : ℝ` be the charge parameter. Define

- `chargedWeight W A q u v := W u v + q * A u v`

and let `tropicalDistance W s t` denote the infimum/minimum path weight from `s` to `t` under tropical addition = ordinary addition along paths and tropical minimization over paths.

You should formalize a theorem of the following shape:

### Main theorem: pathwise magnetic perturbation bound
For every path `p` from `s` to `t`, if `A` is uniformly bounded by `maxA` on edges of `p`, then
\[
\bigl| \mathrm{pathWeight}(chargedWeight\, W\, A\, q, p) - \mathrm{pathWeight}(W, p) \bigr|
\le |q| \cdot maxA \cdot \mathrm{pathLength}(p).
\]

### Distance-level theorem: tropical Lorentz-force bound
Assume:
1. every relevant shortest path exists for both `W` and `chargedWeight W A q`,
2. `|A u v| ≤ maxA` on admissible edges,
3. shortest paths have at most `L` edges.

Then for all vertices `s t`,
\[
\bigl| tropicalDistance (chargedWeight\, W\, A\, q)\, s\, t - tropicalDistance W\, s\, t \bigr|
\le |q| \cdot maxA \cdot L.
\]

This is the discrete analogue of the statement that magnetic perturbation changes action/optical length by at most charge times field scale times trajectory length.

---

## Suggested Lean 4 Formalization Targets

You may need to define your own finite-path object if the catalog does not already provide one. Keep it concrete and finite.

A good minimal architecture is:

```lean
def chargedWeight {V : Type*} (W A : V → V → ℝ) (q : ℝ) : V → V → ℝ :=
  fun u v => W u v + q * A u v
```

If paths are represented as lists of vertices, define:

```lean
def pathLength {V : Type*} (p : List V) : ℕ :=
  p.length.saturatingSub 1

def pathWeight {V : Type*} (W : V → V → ℝ) : List V → ℝ
  | [] => 0
  | [_] => 0
  | u :: v :: xs => W u v + pathWeight W (v :: xs)
```

Then target the exact theorem:

```lean
theorem pathWeight_charged_sub_le
  {V : Type*} (W A : V → V → ℝ) (q maxA : ℝ) :
  ∀ p : List V,
    (∀ u v, (u, v) ∈ (p.zip p.tail) → |A u v| ≤ maxA) →
    |pathWeight (chargedWeight W A q) p - pathWeight W p|
      ≤ |q| * maxA * (pathLength p : ℝ)
```

If the zipped-edge encoding is awkward, replace it with an inductive `Path` type carrying edge data explicitly.

For the distance theorem, if you define shortest distance by minimization over a finite set of paths of bounded length, target:

```lean
theorem tropicalDistance_charged_sub_le
  {V : Type*} [Fintype V] [DecidableEq V]
  (W A : V → V → ℝ) (q maxA : ℝ) (L : ℕ) :
  (∀ u v, |A u v| ≤ maxA) →
  (∀ s t, ∃ p : List V, -- p is a path from s to t
      pathLength p ≤ L ∧
      pathWeight W p = tropicalDistance W s t) →
  (∀ s t, ∃ p : List V,
      pathLength p ≤ L ∧
      pathWeight (chargedWeight W A q) p = tropicalDistance (chargedWeight W A q) s t) →
  ∀ s t,
    |tropicalDistance (chargedWeight W A q) s t - tropicalDistance W s t|
      ≤ |q| * maxA * L
```

If a full `tropicalDistance` infrastructure is too expensive, prove the bounded minimization theorem over a finite path family first:

```lean
theorem min_pathWeight_charged_sub_le
  {ι : Type*} [Finite ι]
  (f g : ι → ℝ) (B : ℝ) :
  (∀ i, |f i - g i| ≤ B) →
  |sInf (Set.range f) - sInf (Set.range g)| ≤ B
```

or, more realistically for finite types, via `Finset.inf'` / `Finset.min'`.

That finite-minimum stability lemma is itself a valuable reusable theorem and may be the cleanest route.

---

## Why this would be a breakthrough

This opens a new formal bridge between:

- **tropical geometry / min-plus analysis**,
- **discrete gauge theory**,
- **optimal transport on graphs**,
- **Hamilton–Jacobi / action perturbation bounds**,
- **certified robustness of weighted combinatorial systems**.

The key insight is that a magnetic perturbation in a min-plus metric behaves like a **Lipschitz deformation of action**, and this can be formalized entirely in Lean using finite combinatorics and inequalities. Once proved, this becomes a prototype for:

- tropical electromagnetism,
- graph-based Aharonov–Bohm analogues,
- perturbation theory for shortest paths,
- robustness certificates for routing under antisymmetric noise,
- min-plus control systems with gauge fields.

This is exactly the kind of theorem that makes people say: “Why is nobody treating magnetic perturbations as tropical metric deformations in theorem provers?”

---

## Proof Strategy Architecture

### Strategy A: direct path induction + shortest-path comparison
This is the most promising route.

1. **Pathwise telescoping estimate.**
   Prove by induction on the path list that
   ```lean
   pathWeight (chargedWeight W A q) p - pathWeight W p
   = q * magneticSum A p
   ```
   where `magneticSum A p` is the sum of `A u v` over consecutive edges.

2. **Absolute-value bound.**
   Use triangle inequality and uniform boundedness of `A` to show
   ```lean
   |magneticSum A p| ≤ maxA * pathLength p
   ```
   hence
   ```lean
   |...| ≤ |q| * maxA * pathLength p.
   ```

3. **Lift from paths to distances.**
   Compare the shortest `W`-path evaluated under `chargedWeight`, and vice versa. This gives two one-sided inequalities:
   \[
   d_q(s,t) \le d(s,t) + |q| maxA L,\quad
   d(s,t) \le d_q(s,t) + |q| maxA L.
   \]
   Combine them into the absolute-value bound.

**Why best:** entirely elementary, finite, and robust in Lean. It avoids heavy graph theory if you encode paths concretely.

---

### Strategy B: finite-minimum stability lemma
This is conceptually cleaner and likely reusable.

1. Index all admissible `s`-`t` paths of length `≤ L` by a finite type `ι`.
2. Define
   ```lean
   f i = pathWeight W (P i)
   g i = pathWeight (chargedWeight W A q) (P i)
   ```
   and prove `∀ i, |f i - g i| ≤ B` with `B = |q| * maxA * L`.
3. Prove a general theorem: **finite minima are 1-Lipschitz in sup norm**:
   \[
   |\min_i f(i) - \min_i g(i)| \le \max_i |f(i)-g(i)|.
   \]
   Then instantiate it.

**Why important:** this yields a reusable perturbation theorem for any tropical optimization problem, not just shortest paths.

---

### Strategy C: gauge-theoretic decomposition
This is more ambitious and could produce a second breakthrough theorem.

1. Decompose `A` into an exact part plus a cycle-detecting part:
   \[
   A(u,v) = \phi(v)-\phi(u) + A_{\mathrm{curl}}(u,v).
   \]
2. Show the exact part contributes only endpoint terms along paths:
   \[
   \sum (\phi(v)-\phi(u)) = \phi(t)-\phi(s).
   \]
3. Conclude that distance perturbation is controlled by endpoint gauge shift plus bounded curl contribution. On closed loops, only the curl part survives.

This suggests a formal **discrete Aharonov–Bohm principle** for tropical path geometry.

**Why exciting:** this goes beyond a norm bound and introduces genuine gauge structure.

---

## Concrete Theorem Package to Aim For

Prove as many of the following as possible.

### 1. Exact algebraic identity for charged path weights
```lean
theorem pathWeight_charged_eq
  {V : Type*} (W A : V → V → ℝ) (q : ℝ) :
  ∀ p : List V,
    pathWeight (chargedWeight W A q) p
      = pathWeight W p + q * magneticSum A p
```

### 2. Magnetic sum bounded by path length
```lean
theorem magneticSum_abs_le
  {V : Type*} (A : V → V → ℝ) (maxA : ℝ) :
  ∀ p : List V,
    (∀ u v, (u, v) ∈ (p.zip p.tail) → |A u v| ≤ maxA) →
    |magneticSum A p| ≤ maxA * (pathLength p : ℝ)
```

### 3. Main pathwise Lorentz bound
```lean
theorem pathWeight_charged_sub_le
  {V : Type*} (W A : V → V → ℝ) (q maxA : ℝ) :
  ∀ p : List V,
    (∀ u v, (u, v) ∈ (p.zip p.tail) → |A u v| ≤ maxA) →
    |pathWeight (chargedWeight W A q) p - pathWeight W p|
      ≤ |q| * maxA * (pathLength p : ℝ)
```

### 4. Finite-minimum tropical stability lemma
```lean
theorem finset_min_perturbation_le
  {ι : Type*} [DecidableEq ι] (s : Finset ι) (hs : s.Nonempty)
  (f g : ι → ℝ) (B : ℝ) :
  (∀ i ∈ s, |f i - g i| ≤ B) →
  |s.inf' hs f - s.inf' hs g| ≤ B
```

### 5. Distance-level Lorentz bound
```lean
theorem tropicalDistance_charged_sub_le
  {V : Type*} [Fintype V] [DecidableEq V]
  (W A : V → V → ℝ) (q maxA : ℝ) (L : ℕ) :
  (∀ u v, |A u v| ≤ maxA) →
  -- shortest paths exist among paths of length ≤ L
  ...
  →
  ∀ s t,
    |tropicalDistance (chargedWeight W A q) s t - tropicalDistance W s t|
      ≤ |q| * maxA * L
```

### 6. Gauge invariance for exact potentials
If you define `Aφ u v = φ v - φ u`, prove:
```lean
theorem magneticSum_exact
  {V : Type*} (φ : V → ℝ) :
  ∀ p : List V, -- path from s to t
    magneticSum (fun u v => φ v - φ u) p
      = endpoint p - startpoint p
```
and for closed loops:
```lean
theorem magneticSum_exact_cycle_zero
  {V : Type*} (φ : V → ℝ) :
  ∀ p : List V, isClosed p →
    magneticSum (fun u v => φ v - φ u) p = 0
```

This would elevate the project from an inequality to a nascent discrete gauge theory.

---

## How to Build on Catalog Theorems

The listed catalog theorems are not directly about graph perturbation, but they signal a pattern you should exploit:

- `quantum_correction_bounded` shows a certified perturbative bound already exists in the library ecosystem. Mimic its proof style: isolate the correction term, bound it by absolute values, then package the estimate as a stability theorem.
- `gl3_tropical_satake_bounded_reconstruction` and `finite_support_of_depth_bounded` suggest a **bounded-support / bounded-complexity philosophy**. Your theorem should similarly reduce infinite optimization to finite bounded path families.
- `discrete_exp_mod_bound` and `pollardRho_bounded` indicate that **explicit quantitative bounds** are welcome, even across domains. Lean into this: prove an explicit constant, not just asymptotic `O(q)` behavior.

Even if these theorems are not imported directly, structurally align your development with them: bounded perturbation, finite search, explicit constants.

---

## Cross-Domain Connections to Make Explicit

You must connect this work to at least one of the following domains in the formal development notes and `FUTURE_DIRECTIONS.md`:

1. **Discrete gauge theory**
   - `A : V → V → ℝ` is a vector potential.
   - Antisymmetry `A u v = -A v u` models orientation-sensitive flux.
   - Exact potentials correspond to gauge transformations.

2. **Optimal transport / control**
   - `tropicalDistance` is a discrete action functional.
   - The theorem is a perturbation bound for value functions.

3. **Robust routing / adversarial graph optimization**
   - The result certifies that bounded antisymmetric edge noise cannot deflect shortest-path cost by more than a linear budget.

4. **Hamilton–Jacobi / weak KAM analogy**
   - Tropical shortest paths are discrete action minimizers.
   - Magnetic perturbation corresponds to adding a one-form to the Lagrangian.

5. **Quantum analogy**
   - The pathwise phase/action perturbation is a min-plus shadow of electromagnetic coupling.
   - A future theorem on cycle flux would resemble a tropical Aharonov–Bohm effect.

---

## Application Keywords

Include these in comments, notes, or documentation:

**tropical geometry, shortest paths, min-plus algebra, discrete gauge theory, magnetic perturbation, Lorentz force analogue, Hamilton–Jacobi, robust optimization, graph transport, Aharonov–Bohm, tropical metric stability, certified bounds**

---

## Execution Priorities

1. Define the core objects cleanly:
   - `chargedWeight`
   - `pathWeight`
   - `pathLength`
   - `magneticSum`
   - optionally bounded path families / finite minimization

2. Prove the pathwise bound completely with minimal sorry.

3. Prove at least one reusable finite-minimum perturbation lemma.

4. If full `tropicalDistance` is too expensive, prove the distance theorem for a finite set of admissible paths first. That is already substantial and publishable as a formal lemma schema.

5. If time permits, add gauge-invariance lemmas for exact potentials.

---

## Deliverables

Required:
- Lean 4 code with theorems above or the strongest provable variants
- `FUTURE_DIRECTIONS.md`

Optional but encouraged:
- `ARTICLE.md` explaining the discrete Lorentz analogy
- `RESEARCH_PAPER.md` with theorem statements and proof sketches
- a small demo enumerating finite paths and numerically verifying the bound

---

## FUTURE_DIRECTIONS.md Requirements

You must produce `FUTURE_DIRECTIONS.md` with **3–5 specific breakthrough next steps**, each containing:
1. a precise theorem statement,
2. a proposed Lean formalization target,
3. 2 proof strategy ideas,
4. one cross-domain connection.

Strong candidate next steps include:

- **Tropical Aharonov–Bohm theorem:** path-cost difference around two homotopically distinct routes depends only on enclosed discrete flux.
- **Bellman operator perturbation theorem:** the dynamic programming operator for charged weights is Lipschitz in `q`.
- **Magnetic tropical curvature:** define cycle flux curvature and prove geodesic deviation bounds.
- **Random magnetic perturbations:** expected distance distortion under bounded stochastic antisymmetric potentials.
- **Tropical Yang–Mills toy model:** minimize total squared cycle flux on finite graphs and relate to shortest-path deformation.

Be bold. Don’t just prove a bound; create the formal language in which tropical electromagnetism can exist.

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
