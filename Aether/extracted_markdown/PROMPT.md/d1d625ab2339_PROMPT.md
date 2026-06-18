## Assignment: Direction 4: Tropical BSD for Higher-Dimensional Abelian Varieties

Mode: `prove`

Prove a genuinely new theorem that upgrades the tropical BSD paradigm from the 1-dimensional case to polarized tropical abelian varieties of arbitrary dimension. This should not be a cosmetic generalization. The goal is to isolate the exact higher-dimensional tropical invariants that play the roles of rank, regulator, local Tamagawa factors, and leading theta coefficient, and then prove their equality in a formally usable Lean 4 statement.

You should aim to make this the foundational theorem for a future tropical arithmetic of polarized real tori, analogous to how classical BSD organizes the arithmetic of abelian varieties over global fields.

---

## Vision

The breakthrough is this: in dimension 1, “regulator = squared period” is too small to reveal the true structure. In higher dimension, the regulator becomes a determinant of a tropical Gram matrix attached to a period lattice and polarization, while local correction factors become a finite product indexed by a set of tropical places/valuations. If formalized correctly, this creates the first viable tropical analogue of the higher-dimensional BSD leading-term formula.

This opens a new field: **tropical arithmetic geometry of polarized tori**, where theta data, lattice covolumes, local defects, and valuation-theoretic correction factors interact in a way that mirrors arithmetic geometry but is accessible to explicit computation and formal proof.

Application keywords: `tropical arithmetic geometry`, `tropical abelian varieties`, `theta functions`, `Gram determinant`, `regulator`, `Tamagawa factors`, `valuation theory`, `mirror symmetry`, `nonarchimedean geometry`, `formalized BSD`, `period lattices`, `Riemann forms`.

---

## Precise Mathematical Target

Let \(g \ge 1\). A tropical abelian variety is modeled as a real torus
\[
A = \mathbb{R}^g / \Lambda
\]
with an integral structure and a positive definite symmetric form \(\Omega\) representing a principal or more general polarization. The tropical theta function attached to \(\Omega\) determines an order of vanishing at the origin, and the period lattice together with the polarization defines a tropical regulator via a Gram determinant.

You should formalize a theorem of the following shape:

1. Define a tropical rank invariant `tropicalRank Ω`, interpreted as the dimension of the period lattice or, more canonically, the rank of the free abelian lattice underlying the polarized torus.
2. Define a tropical theta order `tropicalThetaOrd Ω`, measuring the multiplicity of vanishing of the tropical theta function at the origin.
3. Define a tropical regulator `tropicalRegulator Ω` as the determinant of the Gram matrix induced by the Riemann form/polarization on a basis of the period lattice.
4. Define a finite set of local tropical places/valuations and a local factor `tropicalTamagawa Ω v : ℕ`.
5. Define a leading theta coefficient `tropicalLeadingCoeff Ω : ℝ`.
6. Prove that the order of vanishing equals the tropical rank, and that the leading coefficient factors as regulator times the finite product of local tropical Tamagawa numbers, up to whatever normalization your compatibility structure `AbelianBSDCompatible Ω` packages.

The theorem should be split into at least two formally robust statements:

```lean
theorem tropical_theta_order_eq_rank
    (g : ℕ) (Ω : Matrix (Fin g) (Fin g) ℝ)
    (hΩ : PositiveDefinite Ω) (hcompat : AbelianBSDCompatible Ω) :
    tropicalThetaOrd Ω = tropicalRank Ω
```

and

```lean
theorem tropical_BSD_abelian_variety
    (g : ℕ) (Ω : Matrix (Fin g) (Fin g) ℝ)
    (hΩ : PositiveDefinite Ω) (hcompat : AbelianBSDCompatible Ω) :
    tropicalLeadingCoeff Ω
      = tropicalRegulator Ω *
          ∏ v in tropicalBadPlaces Ω, (tropicalTamagawa Ω v : ℝ)
```

If your formal development requires a normalization constant depending on conventions for theta functions or lattice covolume, make that explicit rather than hiding it:

```lean
theorem tropical_BSD_abelian_variety_normalized
    (g : ℕ) (Ω : Matrix (Fin g) (Fin g) ℝ)
    (hΩ : PositiveDefinite Ω) (hcompat : AbelianBSDCompatible Ω) :
    tropicalLeadingCoeff Ω
      = tropicalBSDNormalization Ω *
        tropicalRegulator Ω *
        ∏ v in tropicalBadPlaces Ω, (tropicalTamagawa Ω v : ℝ)
```

with a follow-up theorem proving `tropicalBSDNormalization Ω = 1` under a principal polarization or a canonical normalization hypothesis.

A more Lean-realistic structure may be to work first with symmetric matrices:

```lean
theorem tropical_BSD_abelian_variety
    (g : ℕ)
    (Ω : Matrix (Fin g) (Fin g) ℝ)
    (hsym : Ω.IsSymm)
    (hΩ : PositiveDefinite Ω)
    (hcompat : AbelianBSDCompatible Ω) :
    tropicalThetaOrd Ω = tropicalRank Ω ∧
    tropicalLeadingCoeff Ω
      = tropicalRegulator Ω *
        ∏ v in tropicalBadPlaces Ω, (tropicalTamagawa Ω v : ℝ)
```

This bundled theorem is acceptable if the infrastructure is still being built, but the split version is mathematically cleaner and better for reuse.

---

## Lean 4 Formalization Targets

You will likely need to introduce precise structures. A promising scaffold is:

```lean
structure TropicalAbelianData (g : ℕ) where
  Ω : Matrix (Fin g) (Fin g) ℝ
  symm : Ω.IsSymm
  posdef : PositiveDefinite Ω
  latticeBasis : Basis (Fin g) ℤ (Fin g → ℝ)
  badPlaces : Finset ℕ
  tamagawa : ℕ → ℕ
  thetaOrd : ℕ
  rank : ℕ
  regulator : ℝ
  leadingCoeff : ℝ
```

or a lighter compatibility class:

```lean
structure AbelianBSDCompatible {g : ℕ} (Ω : Matrix (Fin g) (Fin g) ℝ) : Prop where
  symm : Ω.IsSymm
  theta_rank_axiom : tropicalThetaOrd Ω = tropicalRank Ω
  regulator_def :
    tropicalRegulator Ω = Matrix.det (tropicalGramMatrix Ω)
  badPlaces_finite : (tropicalBadPlaces Ω).Finite
  leading_coeff_factorization :
    tropicalLeadingCoeff Ω
      = tropicalRegulator Ω *
        ∏ v in tropicalBadPlaces Ω, (tropicalTamagawa Ω v : ℝ)
```

But beware: if `AbelianBSDCompatible` already contains the conclusion, the theorem becomes vacuous. The correct move is to let `AbelianBSDCompatible Ω` package the definitional and finiteness hypotheses, not the target identity itself.

A better version is:

```lean
structure AbelianBSDCompatible {g : ℕ} (Ω : Matrix (Fin g) (Fin g) ℝ) : Prop where
  symm : Ω.IsSymm
  theta_well_defined : WellDefinedThetaData Ω
  regulator_well_defined : WellDefinedRegulator Ω
  badPlaces_finite : (tropicalBadPlaces Ω).Finite
  local_factor_compatibility : LocalFactorCompatibility Ω
```

Then prove the actual formula from these hypotheses.

---

## What Would Make This Revolutionary

If successful, this gives the first formal theorem asserting that a tropical leading-term invariant of a higher-dimensional polarized torus factors into a global determinant and local correction factors. That is exactly the structural shape that makes BSD powerful. Even if the tropical setting is simplified, the conceptual gain is enormous:

- it creates a formally certified arithmetic dictionary for tropical abelian varieties;
- it provides a computable surrogate for higher-dimensional BSD phenomena;
- it opens a route from tropical geometry to nonarchimedean and mirror-symmetric arithmetic;
- it gives a machine-checked testbed for conjectural leading-term formulas.

This could seed follow-on programs in tropical Néron models, tropical heights, tropical Jacobians of higher-genus curves, and tropical analogues of Beilinson/Bloch–Kato regulators.

---

## Build Explicitly on Catalog Theorems

You must not merely cite the existing verified theorems; you must exploit them structurally.

1. `period_zero_form`  
   File: `Tropical/Langlands/PeriodsMotives.lean`

   Use this as the degenerate base case for period computations. The higher-dimensional regulator should reduce to a trivial determinant or vanish in the zero-period case. This theorem can serve as the normalization anchor when checking your definitions at rank zero or in a collapsed lattice direction.

2. `tropical_rank_bound`  
   File: `Tropical/Core/TropicalDeepResearch.lean`

   Use this to control the possible rank of the tropical period lattice and ensure that `tropicalRank Ω ≤ g` or a comparable finite-dimensional bound. This is crucial when relating theta order to rank and when proving determinant constructions are dimensionally meaningful.

3. `finite_function_matrix_representation`  
   File: `Tropical/QuantumLLMCompilation.lean`

   This is unexpectedly relevant: it gives a way to move finite combinatorial data into matrix form. Use it to encode local valuation data or finite tropical place contributions as matrices/vectors, enabling the finite product of Tamagawa factors to be represented in a matrix-compatible manner. This is the bridge from finite local data to linear algebraic regulator statements.

4. `tropical_mirror_theorem`  
   File: `Tropical/AlgebraicMirror.lean`

   Superficially trivial, but conceptually useful: it captures tropical idempotence (`max a a = a`). Use this as a local simplification lemma in the tropical theta calculus, especially when proving multiplicity/order statements where repeated dominant terms collapse. It is a seed lemma for proving that the order of a tropical theta function is controlled by the dimension of the active lattice directions.

5. `reconstruct_from_rank2Levi_profiles_and_edge_moments`  
   File: `Tropical/GL3_ReconstructionFromRank2LeviProfiles.lean)

   This is the most visionary bridge theorem in the catalog. Use its reconstruction paradigm as inspiration for recovering global period data from lower-rank local slices. In higher-dimensional tropical BSD, one plausible strategy is to reconstruct the global Gram matrix or regulator from rank-2 tropical sections or pairwise period interactions. This would be a deep and non-obvious structural reuse.

---

## Proof Strategy A: Linear-Algebraic Regulator Route

This is likely the most promising path.

### Step 1: Define the tropical Gram matrix
Construct `tropicalGramMatrix Ω : Matrix (Fin r) (Fin r) ℝ` from a basis of the tropical period lattice and the positive definite form induced by `Ω`. Prove symmetry and positive semidefiniteness, then positive definiteness on the rank subspace.

### Step 2: Identify the regulator with a determinant
Define
```lean
tropicalRegulator Ω := Matrix.det (tropicalGramMatrix Ω)
```
and prove nonnegativity/positivity under rank hypotheses. Use `tropical_rank_bound` to control the dimensions and show the determinant is formed on a finite basis.

### Step 3: Relate theta order to rank
Show that the order of vanishing of the tropical theta function at the origin counts the number of independent active lattice directions, hence equals the lattice rank. This is where tropical idempotence simplifications, via lemmas in the spirit of `tropical_mirror_theorem`, should enter.

### Step 4: Factor the leading coefficient
Express the leading coefficient as the determinant contribution from the global Gram form times the product over finitely many local defects. The finite product should be justified using the finiteness of bad places and, if needed, encoded through finite matrix representation ideas from `finite_function_matrix_representation`.

Why this is promising: it matches the actual shape of the desired formula and keeps everything in finite-dimensional real linear algebra, where Lean is strongest.

---

## Proof Strategy B: Slice-by-Slice Reconstruction from Rank-2 Tropical Sections

This is riskier but potentially more beautiful.

### Step 1: Decompose the \(g\)-dimensional polarized torus into rank-2 or rank-1 tropical slices
For each pair of lattice directions, define a rank-2 sub-abelian tropical section with induced polarization.

### Step 2: Prove local BSD identities on slices
Either inherit the 1-dimensional theorem on suitable degenerations or prove a rank-2 tropical leading-term formula directly.

### Step 3: Reconstruct the global regulator and leading coefficient
Use a reconstruction theorem in the spirit of `reconstruct_from_rank2Levi_profiles_and_edge_moments` to recover the full Gram determinant and global local-factor product from the family of lower-rank sections.

Why this is exciting: it suggests a “Levi decomposition” philosophy for tropical arithmetic invariants. If it works, it would be far more than a proof of one theorem; it would give a structural toolkit for higher-dimensional tropical arithmetic.

Why it is less immediately promising: the formal infrastructure for slicing and reconstructing determinants may be substantial.

---

## Proof Strategy C: Nonarchimedean / Mirror-Symmetric Interpretation

This is the most speculative and conceptually richest.

### Step 1: Interpret the tropical theta function as the skeleton of a nonarchimedean theta object
Define the tropical order and leading coefficient as piecewise-linear shadows of classical analytic data.

### Step 2: Translate polarization data into mirror or dual torus data
Use the symmetric positive definite form \(\Omega\) as a tropical Riemann form and identify the regulator with a volume/covolume invariant of the mirror torus.

### Step 3: Show local factors arise from singularities of the tropical polarization
Interpret tropical Tamagawa numbers as combinatorial multiplicities of local degenerations, then prove the leading-term factorization.

Why this matters: it would connect tropical BSD to SYZ mirror symmetry and Berkovich skeletons. Even partial formalization here would be field-opening.

Why it is less Lean-friendly: the geometric infrastructure may exceed current library support, so this strategy is best as a guiding mathematical interpretation while Strategy A carries the formal proof.

---

## Recommended Route

Pursue Strategy A as the formal core, while importing the conceptual architecture of Strategy B. In practice:

- formalize the regulator as a Gram determinant;
- prove theta order equals rank by a combinatorial analysis of active tropical linear forms;
- package local factors as a finite product over bad places;
- optionally add lemmas showing the regulator can be reconstructed from lower-rank slices, preparing the next breakthrough.

This balances feasibility and originality.

---

## Concrete Intermediate Lemmas to Target

You should aim to prove some of the following as reusable lemmas:

```lean
theorem tropical_rank_le_ambient_dimension
    (g : ℕ) (Ω : Matrix (Fin g) (Fin g) ℝ) :
    tropicalRank Ω ≤ g
```

```lean
theorem tropical_gram_matrix_isSymm
    (g : ℕ) (Ω : Matrix (Fin g) (Fin g) ℝ)
    (hcompat : AbelianBSDCompatible Ω) :
    (tropicalGramMatrix Ω).IsSymm
```

```lean
theorem tropical_regulator_nonneg
    (g : ℕ) (Ω : Matrix (Fin g) (Fin g) ℝ)
    (hΩ : PositiveDefinite Ω) (hcompat : AbelianBSDCompatible Ω) :
    0 ≤ tropicalRegulator Ω
```

```lean
theorem tropical_badPlaces_finite
    (g : ℕ) (Ω : Matrix (Fin g) (Fin g) ℝ)
    (hcompat : AbelianBSDCompatible Ω) :
    (tropicalBadPlaces Ω).Finite
```

```lean
theorem tropical_theta_order_eq_rank
    (g : ℕ) (Ω : Matrix (Fin g) (Fin g) ℝ)
    (hΩ : PositiveDefinite Ω) (hcompat : AbelianBSDCompatible Ω) :
    tropicalThetaOrd Ω = tropicalRank Ω
```

```lean
theorem tropical_leadingCoeff_factorizes
    (g : ℕ) (Ω : Matrix (Fin g) (Fin g) ℝ)
    (hΩ : PositiveDefinite Ω) (hcompat : AbelianBSDCompatible Ω) :
    tropicalLeadingCoeff Ω
      = tropicalRegulator Ω *
        ∏ v in tropicalBadPlaces Ω, (tropicalTamagawa Ω v : ℝ)
```

These lemmas collectively form the theorem. If necessary, prove the final theorem first in a normalized subclass such as principal polarizations, then generalize.

---

## Cross-Domain Connections You Should Explicitly Leverage

1. **Arithmetic geometry ↔ tropical linear algebra**  
   Regulator becomes determinant of a Gram matrix; rank becomes dimension of a lattice; Tamagawa factors become finite local multiplicities.

2. **Nonarchimedean geometry ↔ tropical theta functions**  
   The tropical theta order should be understood as the skeleton-level shadow of analytic vanishing order.

3. **Mirror symmetry ↔ polarization duality**  
   The positive definite form \(\Omega\) is not just a matrix; it is a tropical Riemann form, and its determinant/covolume interpretation should be emphasized.

4. **Representation-theoretic reconstruction ↔ local-to-global arithmetic**  
   The `rank2Levi` reconstruction theorem suggests a methodology for rebuilding global invariants from lower-rank slices.

5. **Quantum compilation / finite matrix coding ↔ local factor bookkeeping**  
   Finite local valuation data can be encoded and manipulated as matrices, making the local factor product algebraically manageable in Lean.

These are not decorative analogies. They should guide definitions and theorem decomposition.

---

## Minimal Deliverables

1. A new Lean file, ideally something like:
   `Tropical/Arithmetic/TropicalBSDAbelianVariety.lean`

2. Definitions for:
   - `tropicalRank`
   - `tropicalThetaOrd`
   - `tropicalGramMatrix`
   - `tropicalRegulator`
   - `tropicalBadPlaces`
   - `tropicalTamagawa`
   - `tropicalLeadingCoeff`
   - `AbelianBSDCompatible`

3. At least one fully proved nontrivial theorem:
   - preferably `tropical_theta_order_eq_rank`
   - and ideally the factorization theorem for the leading coefficient.

4. Minimize `sorry`. If the full theorem is too large, prove a principled restricted version:
   - principal polarization,
   - diagonal \(\Omega\),
   - or a theorem assuming a basis in which the Gram matrix is already explicit.

A restricted theorem with a sharp mathematical statement is vastly better than a vague unfinished general theorem.

---

## If Full Generality Is Too Ambitious

Then prove the diagonal-polarization case:

```lean
theorem tropical_BSD_abelian_variety_diagonal
    (g : ℕ)
    (d : Fin g → ℝ)
    (hpos : ∀ i, 0 < d i)
    (hcompat : AbelianBSDCompatible (Matrix.diagonal d)) :
    tropicalThetaOrd (Matrix.diagonal d) = tropicalRank (Matrix.diagonal d) ∧
    tropicalLeadingCoeff (Matrix.diagonal d)
      = tropicalRegulator (Matrix.diagonal d) *
        ∏ v in tropicalBadPlaces (Matrix.diagonal d),
          (tropicalTamagawa (Matrix.diagonal d) v : ℝ)
```

This is still highly nontrivial and can serve as the certified base case for the full polarized theorem.

---

## Final Charge

Do not treat this as “yet another tropical identity.” Treat it as the seed of a new arithmetic language. The real success criterion is not just a theorem statement; it is the creation of a reusable formal architecture for tropical leading-term formulas in higher dimension.

You must also produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete breakthrough-level next steps, such as:
- tropical BSD for tropical Jacobians of genus \(g\) curves;
- tropical Néron local models and exact Tamagawa computations;
- tropical height pairings and tropical Birch–Swinnerton–Dyer regulators;
- nonarchimedean comparison theorems between analytic and tropical leading terms;
- reconstruction of global tropical regulators from rank-2 slices.

Be bold. If this lands, it will define the arithmetic side of tropical abelian geometry.

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
