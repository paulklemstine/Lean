## Mode: prove

## Assignment: String Theory T-Duality as Tropical Duality: Min-Plus Mirror Symmetry

Aristotle, do not treat this as metaphor. Force the physics slogan into a sharp min-plus theorem scheme that survives formal scrutiny. The breakthrough is not “using tropical language to describe duality,” but proving that the core involutive mechanism of T-duality and the convex-dual mechanism of mirror symmetry are already present as exact algebraic statements in min-plus geometry. If you can make this precise in Lean, you open a formal bridge between tropical geometry, convex analysis, and the algebraic skeleton of string dualities.

The physically grand claims in the prompt are too ambitious if taken literally over full Calabi–Yau geometry. So the right move is to isolate the rigid mathematical heart:
1. radius inversion as an involutive min-plus duality,
2. tropical Legendre transform as mirror involution on a class of potentials,
3. corner loci as the singular transition set where linear phases exchange dominance.

That is already field-opening if done cleanly and abstractly.

## Precise Theorem Targets

### Theorem A: Tropical radius inversion is an involutive duality
Define the tropicalized circle energy for momentum-winding data `(n,w)` at radius `R > 0` by
`E_R(n,w) = min (n + R) (w - R)` on the additive tropical side, or more symmetrically by a two-branch affine potential
`Φ R x = min (x + log R) (-x - log R)`.

Then prove that radius inversion `R ↦ 1/R` corresponds exactly to exchanging the affine branches, hence to a min-plus duality involution.

A Lean-friendly theorem statement:

```lean
def tropPotential (r x : ℝ) : ℝ := min (x + Real.log r) (-x - Real.log r)

theorem tropPotential_radius_inversion
    {r x : ℝ} (hr : 0 < r) :
    tropPotential (1 / r) x = tropPotential r (-x) := by
```

This is the formal nucleus of “T-duality = tropical duality”: inversion of radius is equivalent to reflection of tropical coordinate.

A stronger involutivity theorem:

```lean
def radiusDual (r : ℝ) : ℝ := 1 / r

theorem radiusDual_involutive {r : ℝ} (hr : r ≠ 0) :
    radiusDual (radiusDual r) = r := by
```

And the combined symmetry theorem:

```lean
theorem tropPotential_duality_involutive
    {r x : ℝ} (hr : 0 < r) :
    tropPotential (radiusDual (radiusDual r)) x = tropPotential r x := by
```

### Theorem B: Tropical mirror symmetry as involutivity of tropical Legendre transform
Do not try to formalize full Calabi–Yau mirror symmetry immediately. Formalize the tropical mirror principle on piecewise-affine convex potentials. Define the tropical Legendre transform
`f⋆(p) = inf_x (f(x) - p*x)`,
and prove involutivity for a manageable class of functions, ideally finite minima/maxima of affine functions where the biconjugate is exact.

Lean-friendly finite model:
use a finite set of affine forms `a_i * x + b_i`, define a convex piecewise-linear function by supremum or, in min-plus convention, switch signs appropriately. Since `sInf` over all reals is harder, begin with a finite-grid or finite-family dual transform.

Example target:

```lean
def affineFamily (S : Finset ι) (a : ι → ℝ) (b : ι → ℝ) (x : ℝ) : ℝ :=
  S.sup' (by intro h; cases h) (fun i => a i * x + b i)

def tropLegendreFinite (S : Finset ι) (f : ℝ → ℝ) (p : ι → ℝ) : ι → ℝ :=
  fun i => S.inf' (by intro h; cases h) (fun j => f (p j) - p i * p j)
```

This exact signature may need adjustment, but the theorem target should be:

```lean
theorem tropLegendre_biconjugate_eq_of_piecewiseAffineConvex
    (f : ℝ → ℝ)
    (hf : PiecewiseAffineConvex f) :
    tropLegendre (tropLegendre f) = f := by
```

If a full function equality is too ambitious, prove pointwise equality on a finite support/grid first:

```lean
theorem tropLegendreFinite_biconjugate_eq
    (S : Finset ℝ) (f : ℝ → ℝ)
    (hf : FiniteConvexOn S f) :
    ∀ x ∈ S, tropLegendreFiniteEval S (tropLegendreFiniteEval S f) x = f x := by
```

This is the formal mathematical content of “mirror symmetry = tropical Legendre duality.”

### Theorem C: Conifold transition as tropical corner locus
A conifold transition is, in this formal skeleton, the place where two or more affine phases become simultaneously dominant. In tropical geometry, that is exactly the corner locus / nondifferentiability locus of a min/max of affine forms.

Define a simple tropical potential with three affine branches and prove that the singular set is the set where at least two branches tie.

```lean
def tropPoly3 (a₁ b₁ a₂ b₂ a₃ b₃ x : ℝ) : ℝ :=
  min (a₁ * x + b₁) (min (a₂ * x + b₂) (a₃ * x + b₃))

def IsCorner (f : ℝ → ℝ) (x : ℝ) : Prop :=
  ∃ g₁ g₂ : ℝ → ℝ, g₁ ≠ g₂ ∧
    IsAffine g₁ ∧ IsAffine g₂ ∧
    f x = g₁ x ∧ f x = g₂ x
```

Then prove a branch-collision theorem such as:

```lean
theorem corner_of_affine_tie
    {a₁ b₁ a₂ b₂ x : ℝ}
    (htie : a₁ * x + b₁ = a₂ * x + b₂)
    (hne : (a₁, b₁) ≠ (a₂, b₂)) :
    IsCorner (fun t => min (a₁ * t + b₁) (a₂ * t + b₂)) x := by
```

And, if possible, characterize the corner locus explicitly:

```lean
theorem corner_locus_two_branch
    {a₁ b₁ a₂ b₂ x : ℝ}
    (hne : a₁ ≠ a₂) :
    IsCorner (fun t => min (a₁ * t + b₁) (a₂ * t + b₂)) x
      ↔ x = (b₂ - b₁) / (a₁ - a₂) := by
```

This is the mathematically precise avatar of “conifold transition = tropical corner locus”: the transition occurs where combinatorial phase structure changes.

## Why this is a breakthrough

If you prove these three theorems in a coherent package, you create a formal dictionary:

- **string-theoretic duality** ↔ **min-plus involution**,
- **mirror transform** ↔ **tropical convex duality**,
- **geometric transition singularity** ↔ **corner locus / phase collision**.

This is not just poetic repackaging. It gives a theorem-proving substrate for dualities that are usually discussed analytically or physically. Once formalized, this can seed:
- tropical moduli of dual theories,
- certified symbolic detection of phase transitions,
- algorithmic mirror constructions via convex dualization,
- bridges to optimization, verification, and scattering amplitudes.

## Build explicitly on catalog theorems

The catalog theorem
`Bridges/MinPlusVerificationCore.lean : tropical_plus_distributes_over_min`
is not incidental. Use it to normalize expressions of the form
`c + min a b = min (c + a) (c + b)`,
which is exactly the algebraic engine behind branch shifts, affine reparameterizations, and tropical gauge transformations.

Also use
`Physics/Quantum/TropicalFeynman.lean : tropical_interference_min`
as conceptual infrastructure: branch competition in tropical amplitudes already behaves like selecting dominant action. Your corner-locus theorem should be framed as the singular set where tropical interference changes branch.

Concretely:
- in Theorem A, distribution over `min` lets you rewrite radius shifts and reflections cleanly;
- in Theorem C, the same theorem helps factor common affine offsets when analyzing tie sets;
- if you define translated potentials, the catalog theorem gives immediate simplification lemmas.

## Proof strategy architecture

### Strategy 1: Direct algebraic min-plus proof
Best for Theorem A and the basic corner-locus lemmas.

Steps:
1. Expand definitions of `tropPotential` and `radiusDual`.
2. use `Real.log_inv` under `0 < r` to rewrite `log (1/r) = - log r`;
3. simplify both sides to the same `min` expression, using commutativity and the catalog distributivity lemma where useful.

Why promising:
- extremely Lean-friendly,
- little analytic overhead,
- produces a canonical exact theorem embodying T-duality.

### Strategy 2: Convex-analytic route via piecewise affine functions
Best for Theorem B.

Steps:
1. Define a class of finite piecewise-affine convex functions;
2. define tropical Legendre transform first on finite affine families or finite grids to avoid difficult `sInf` issues;
3. prove biconjugation by explicit branch comparison or by importing Mathlib convex-analysis lemmas if available.

Why promising:
- this captures the genuine mathematical substance of mirror duality,
- once finite-version works, you can generalize systematically,
- it connects immediately to optimization and tropical geometry.

Risk:
- full infinite-dimensional Legendre formalization may be too heavy for one cycle.
Mitigation:
- prove exact finite-support biconjugacy first; that is already nontrivial and publishable as a formal bridge theorem.

### Strategy 3: Singular-locus characterization via affine tie equations
Best for Theorem C.

Steps:
1. define `IsCorner` using equality of at least two active affine branches;
2. show tie implies corner for `min` of two affine functions;
3. solve the tie equation explicitly when slopes differ, obtaining the unique transition point.

Why promising:
- elementary but powerful,
- gives a rigorous singularity dictionary,
- can later be lifted from one variable to polyhedral complexes in `ℝ^n`.

Most promising overall:
Start with A + C to secure a coherent exact package quickly. Then drive B as the conceptual centerpiece. A and C provide the algebraic and singularity backbone; B supplies the mirror-symmetry engine.

## Cross-domain connections you should exploit

### 1. Convex analysis / optimization
The tropical Legendre transform is the min-plus shadow of classical convex duality. This means mirror symmetry can be recast as dual optimization geometry. That opens algorithmic mirror constructions and certified dual witnesses.

### 2. Verification / robustness
Corner loci are exactly phase boundaries. In verification language, they are decision-boundary analogues for tropical models. This suggests conifold-style singular transitions can be detected by certified branch-collision algorithms.

### 3. Quantum / scattering
The theorem `tropical_interference_min` suggests a physics interpretation: tropical amplitudes choose dominant actions. T-duality then becomes an invariance of dominant-action structure under radius inversion. That is a mathematically crisp bridge between tropical Feynman heuristics and compactification dualities.

### 4. Polyhedral geometry
Corner loci are codimension-1 cells in tropical hypersurfaces. A successful one-dimensional theorem should be explicitly positioned as the seed for higher-dimensional tropical Calabi–Yau skeleta.

## Concrete Lean 4 formalization suggestions

You may need to define lightweight structures rather than chase full geometric objects. Good candidates:

```lean
def IsAffine (f : ℝ → ℝ) : Prop :=
  ∃ a b : ℝ, ∀ x, f x = a * x + b

def tropPotential (r x : ℝ) : ℝ := min (x + Real.log r) (-x - Real.log r)

def radiusDual (r : ℝ) : ℝ := 1 / r

def IsCorner (f : ℝ → ℝ) (x : ℝ) : Prop :=
  ∃ a₁ b₁ a₂ b₂ : ℝ,
    (a₁ ≠ a₂ ∨ b₁ ≠ b₂) ∧
    f x = a₁ * x + b₁ ∧
    f x = a₂ * x + b₂
```

You can later refine `IsCorner` to encode local active-branch behavior, but this simple definition is enough for first theorems.

If full `Real.log` causes friction, an even cleaner first formalization is to parameterize by `ρ : ℝ` with `ρ = log r` abstractly:

```lean
def tropPotentialLog (ρ x : ℝ) : ℝ := min (x + ρ) (-x - ρ)

theorem tropPotentialLog_duality (ρ x : ℝ) :
    tropPotentialLog (-ρ) x = tropPotentialLog ρ (-x) := by
```

This theorem is beautiful, exact, and avoids analytic side conditions. Then derive the radius theorem as a corollary using `ρ = log r`.

## Suggested theorem dependency order

1. `radiusDual_involutive`
2. `tropPotentialLog_duality`
3. `tropPotential_radius_inversion`
4. `corner_of_affine_tie`
5. `corner_locus_two_branch`
6. finite tropical Legendre definitions
7. finite biconjugation theorem
8. synthesis theorem relating duality involution + biconjugation + corner locus as a “tropical mirror package”

## Synthesis theorem worth aiming for

If you can package the story, prove a theorem of the form:

```lean
theorem tropical_duality_package
    {r : ℝ} (hr : 0 < r) :
    (∀ x, tropPotential (1 / r) x = tropPotential r (-x)) ∧
    (radiusDual (radiusDual r) = r) := by
```

and separately:

```lean
theorem tropical_mirror_singularity_principle
    (f : ℝ → ℝ) (hf : PiecewiseAffineConvex f) :
    tropLegendre (tropLegendre f) = f ∧
    ∀ x, IsCorner f x ↔ ∃ branches of f tying at x := by
```

Even if the second theorem must be weakened to finite families, the conceptual package is strong.

## Application keywords
tropical geometry, mirror symmetry, T-duality, min-plus algebra, Legendre transform, convex duality, corner locus, conifold transition, polyhedral geometry, formalized physics, tropical scattering, certified singularity detection, optimization duality, Calabi–Yau skeletons

## Deliverables
1. Lean file(s) with precise definitions and theorem statements above.
2. Minimize sorry aggressively; if one theorem is too ambitious, lock in a finite exact version rather than leaving a vague placeholder.
3. Include comments explaining the physics-to-math dictionary.
4. Produce `FUTURE_DIRECTIONS.md` with 3–5 concrete breakthrough next steps, for example:
   - higher-dimensional tropical torus duality on `ℝ^n`,
   - tropical hypersurface models of Calabi–Yau degenerations,
   - sheaf/cohomological formulation of tropical mirror functors,
   - certified algorithms for singular-locus detection in tropical potentials,
   - tropical analogues of wall-crossing and cluster transformations.

Be bold, but formalize the mathematically immortal core first.

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

Research domain: Physics
Research mode: prove
