## Assignment: Birch–Swinnerton-Dyer via Tropical L-Function Specialization

Mode: **prove**

You are not being asked for a cosmetic analogy to BSD. You are being asked to carve out a rigorous tropical shadow of BSD that is actually formalizable in Lean 4, anchored in concrete min-plus invariants, and strong enough to become a new research program rather than a slogan.

The key move is this: do **not** attempt to formalize the classical analytic \(L\)-function of an elliptic curve over \(\mathbb{Q}\) inside Lean from scratch. Instead, define a **tropicalized Dirichlet/min-plus L-series model** with enough structure to support a genuine “order of vanishing = rank” theorem in a finitely computable setting, and then prove comparison/inequality principles showing it behaves like a tropical BSD avatar. The breakthrough is to make “special value data” and “rank data” coexist in one idempotent invariant.

Your target should be a package of theorems, not a single isolated lemma.

---

## Core Vision

Construct a tropical BSD machine in which:

1. a finitely supported or eventually stabilized min-plus \(L\)-series has a well-defined tropical order of vanishing at \(s=1\),
2. a tropical Mordell–Weil rank is defined from a finite generating configuration or valuation profile,
3. a tropical residue packages regulator-like and Tamagawa-like corrections into one idempotent quantity,
4. and the rank equals the tropical order of vanishing in a nontrivial formal class.

This is not classical BSD. It is a new theorem-schema: a **tropical specialization principle for arithmetic invariants**.

If done well, this opens a field:
- tropical arithmetic statistics,
- idempotent special value theory,
- min-plus regulators,
- formal bridges between arithmetic geometry, optimization, and information theory.

Application keywords: **tropical BSD, min-plus L-series, idempotent residue, tropical rank, regulator compression, Tamagawa aggregation, valuation geometry, arithmetic optimization, tropical special values, formal arithmetic geometry**

---

## Existing Verified Theorems to Build On

Use these as actual structural anchors, not name-drops:

1. `tropical_residue_min`
   - file: `Algebra/TropicalBSD/TropicalBSDPrototype.lean`
   - likely gives the seed identity for residue extraction in a min-plus setting.
   - Use it to normalize the definition of tropical residue at \(s=1\), and to prove simplification lemmas for your new `tropicalOrderAtOne` / `tropicalResidueAtOne`.

2. `tropical_BSD_inequality`
   - file: `Algebra/TropicalBSD/TropicalBSDSpecialization.lean`
   - this is your bridge theorem.
   - Strengthen it: first package hypotheses so it becomes reusable; then seek equality under a finite-generation / independence hypothesis.

3. `tropical_idempotent_dense (x : ℝ) : min x x = x`
   - file: `Algebra/RosettaStone/Bridge10_Research.lean`
   - trivial-looking, but foundational for rewriting and normalization in min-plus algebra.
   - Use it aggressively to canonicalize tropical sums/products and keep simp-normal forms manageable.

The symmetric group theorems may be useful if you encode regulator-like invariants through permutation minimization or determinant-like combinatorics over finite generating sets.

---

## Precise Theorem Targets

You should define a minimal but robust tropical arithmetic interface and then prove at least one flagship equality theorem and one structural decomposition theorem.

### 1. Tropical order of vanishing equals tropical rank

Define a finitely supported tropical \(L\)-datum on `ℕ` or a finite prime-index set. One practical model:

- coefficients `a : ℕ → ℝ`
- tropical L-series at parameter `s : ℝ` represented by
  \[
  \mathcal{L}_{\mathrm{trop}}(a,s) := \inf_{n \in S} \big(a_n + s \cdot w_n\big)
  \]
  for finite support `S` and weights `w_n`.
- the tropical order at `s = 1` is the cardinality of the active face / multiplicity of minimizers at `s=1`, minus 1, or another equivalent combinatorial notion that you can formalize cleanly.

Define a tropical rank from a finite family of generators with valuation vectors:
- `gens : Fin m → Fin k → ℝ`
- tropical rank = maximal cardinality of a tropically independent subfamily, or a simpler Lean-friendly surrogate:
  cardinality of a basis extracted from pairwise non-collinear valuation profiles.

A precise Lean-friendly flagship theorem could be:

```lean
theorem tropical_order_eq_rank
    {m k : ℕ}
    (gens : Fin m → Fin k → ℝ)
    (a : ℕ → ℝ)
    (support : Finset ℕ)
    (hfin : ∀ n ∉ support, a n = 0)
    (hcompat : TropicalBSDCompatible gens a support)
    (hindep : TropicalIndependentFamily gens)
    (hnondeg : TropicalNondegenerateAtOne a support) :
    tropicalOrderAtOne a support = tropicalRank gens
```

If this exact interface is too ambitious, prove the finite-dimensional special case first:

```lean
theorem tropical_order_eq_rank_finset
    {ι : Type} [Fintype ι] [DecidableEq ι]
    (v : ι → ℝ)
    (hnd : TropicalNondegenerateFamily v) :
    tropicalOrderOfMinPlusSeriesAtOne v = tropicalRankOfFamily v
```

The theorem must not be vacuous: ensure hypotheses imply a nontrivial active minimizer structure.

### 2. Tropical residue decomposition theorem

Define a tropical residue invariant combining regulator and Tamagawa corrections:

\[
\operatorname{TropRes}(E) = \operatorname{TropReg}(E) \oplus \operatorname{TropTam}(E)
\]
with min-plus addition realized as `min` or additive aggregation depending on your convention.

Lean target:

```lean
theorem tropical_residue_decomposes
    {m n : ℕ}
    (R : Fin m → Fin m → ℝ)
    (c : Fin n → ℝ)
    (hR : TropicalRegulatorMatrix R)
    (hc : TropicalTamagawaData c) :
    tropicalResidue (tropicalLSeriesFromData R c)
      = min (tropicalRegulator R) (tropicalTamagawaProduct c)
```

A stronger additive-log version may be easier to reason about:

```lean
theorem tropical_residue_decomposes_add
    {m n : ℕ}
    (R : Matrix (Fin m) (Fin m) ℝ)
    (c : Fin n → ℝ)
    (hR : TropicalRegulatorMatrix R)
    (hc : TropicalTamagawaData c) :
    tropicalResidueAdditive (tropicalLSeriesFromData R c)
      = tropicalRegulatorAdditive R + tropicalTamagawaAdditive c
```

This is especially promising because additive formulations over `ℝ` are often much easier in Lean than direct min-plus multiplicative syntax.

### 3. Equality upgrade from existing inequality

Strengthen the catalog theorem:

```lean
theorem tropical_BSD_equality
    {m k : ℕ}
    (gens : Fin m → Fin k → ℝ)
    (a : ℕ → ℝ)
    (support : Finset ℕ)
    (hcompat : TropicalBSDCompatible gens a support)
    (hsharp : TropicalSharpAtOne gens a support) :
    tropicalRank gens = tropicalOrderAtOne a support
```

This should explicitly build on `tropical_BSD_inequality`; the proof strategy should reduce equality to proving both inequalities, with one direction imported from the catalog and the other obtained from a witness extraction theorem.

---

## Suggested Lean 4 Definitions

Keep the first generation of definitions finite and computable.

### Tropical active set and order
```lean
def activeSetAt (f : ℕ → ℝ) (s : ℝ) (support : Finset ℕ) : Finset ℕ :=
  support.filter (fun n => f n + s = (support.inf' (by simpa) (fun m => f m + s)))

def tropicalOrderAtOne (f : ℕ → ℝ) (support : Finset ℕ) : ℕ :=
  (activeSetAt f 1 support).card - 1
```

You may need a better parameterization, e.g. `f n + w n * s`.

### Tropical rank
```lean
def tropicalRankFamily
    {ι κ : Type} [Fintype ι] [DecidableEq ι] [Fintype κ]
    (v : ι → κ → ℝ) : ℕ := ...
```

If full tropical linear independence is too heavy, define a surrogate rank via:
- cardinality of deduplicated valuation profiles,
- affine dimension of the convex hull in a finite-dimensional real space,
- or maximal size of a family with unique minimizers under coordinate projections.

The point is not to mimic all of tropical linear algebra at once; the point is to prove a strong theorem for a mathematically meaningful finite model.

### Tropical residue / regulator / Tamagawa
Use additive encoding if possible:
```lean
def tropicalRegulatorAdditive {n : ℕ} (R : Matrix (Fin n) (Fin n) ℝ) : ℝ := ...
def tropicalTamagawaAdditive {n : ℕ} (c : Fin n → ℝ) : ℝ := ∑ i, c i
def tropicalResidueAdditive (F : TropicalLData) : ℝ := ...
```

Then later expose a min-plus view as a corollary.

---

## Proof Strategy Architecture

You must pursue at least 2–3 proof paths in parallel and document which one wins.

### Strategy A: Finite active-face combinatorics
Most promising for a first theorem.

1. Define the tropical order at \(s=1\) as the number of simultaneous minimizers of a finite family of affine functions.
2. Define tropical rank via the cardinality of a basis-like valuation subfamily.
3. Prove that under a nondegeneracy/sharpness hypothesis, minimizers correspond exactly to basis witnesses.
4. Conclude equality by cardinality comparison.

Why this is promising:
- finite `Finset` combinatorics,
- good compatibility with existing `inf'`, `card`, `filter`, and matrix APIs,
- likely enough to upgrade `tropical_BSD_inequality` to equality.

### Strategy B: Matrix/valuation geometry route
Best for the regulator theorem.

1. Encode generator valuations as a matrix over `ℝ`.
2. Define tropical regulator through a minimum over permutation weights, analogous to tropical determinant/permanent.
3. Show that the residue of the tropical \(L\)-datum decomposes into matrix part + local correction part.
4. Use finite permutation expansions; this is where `symmetric_group_order` may help in counting/extremal arguments.

Why this is promising:
- matrix and finite permutation machinery already exists in Mathlib,
- determinant-like tropical objects are structurally rich,
- this creates a real arithmetic-geometric interpretation of “regulator.”

### Strategy C: Convex-geometric / Legendre-transform viewpoint
Most visionary; may produce the deepest follow-on work.

1. Regard the tropical \(L\)-series as a lower envelope of affine functions.
2. Interpret order of vanishing as face dimension / multiplicity at the slope \(s=1\).
3. Interpret tropical rank as dimension of a valuation polytope or Newton subdivision stratum.
4. Prove equality via duality between active faces and independent generators.

Why this matters:
- this connects arithmetic geometry to tropical convexity and optimization,
- it opens pathways to tropical height theory and idempotent information geometry.

This may be harder to finish fully in Lean immediately, but even partial formalization could be revolutionary.

---

## Cross-Domain Connections You Must Exploit

Do not leave this as “number theory in tropical notation.” Connect it outward.

### 1. Optimization / operations research
A min-plus \(L\)-series is a shortest-path / dynamic-programming style object.
- Tropical residue becomes a compressed cost invariant.
- Order of vanishing becomes degeneracy of optimal solutions.
- Rank becomes dimension of the optimal face.

This gives algorithmic interpretations and possible certified computation.

### 2. Information theory
The multiplicity of minimizers at \(s=1\) behaves like a tropical entropy/degeneracy count.
- A unique minimizer corresponds to zero tropical uncertainty.
- Multiple minimizers encode arithmetic ambiguity/degeneracy.
- The residue decomposition resembles an information split into global and local contributions.

This suggests future tropical mutual information and data-processing style inequalities for arithmetic invariants.

### 3. Statistical mechanics
The tropical limit is the zero-temperature limit of a partition function.
- Order of vanishing corresponds to ground-state degeneracy.
- Tropical residue is a free-energy defect.
- Regulator/Tamagawa decomposition resembles global-vs-local energy splitting.

This is not decorative. It suggests proving a tropical BSD equality as a zero-temperature special value theorem.

### 4. Polyhedral geometry
Your tropical \(L\)-series is a polyhedral support function.
- Vanishing order = active cell multiplicity.
- Rank = dimension/basis size in a polyhedral complex.
- Residue = weight attached to a codimension-one face.

This opens tropical motivic and Newton-polytope interpretations.

---

## Concrete Intermediate Lemmas to Target

You should prove a chain of reusable lemmas, not jump straight to the flagship theorem.

### Active minimizer lemmas
```lean
theorem mem_activeSetAt_iff
theorem activeSetAt_nonempty
theorem tropicalOrderAtOne_eq_card_activeSet_sub_one
theorem tropicalOrderAtOne_eq_zero_iff_unique_minimizer
```

### Rank comparison lemmas
```lean
theorem tropicalRank_le_card_generators
theorem tropicalRank_mono
theorem tropicalRank_eq_card_of_independent
```

### Residue decomposition lemmas
```lean
theorem tropicalResidueAdditive_of_split
theorem tropicalTamagawaAdditive_nonneg
theorem tropicalRegulatorAdditive_invariant_under_permutation
```

### Equality upgrade lemmas
```lean
theorem tropical_rank_le_order
theorem tropical_order_le_rank
theorem tropical_order_eq_rank_of_sharp
```

The equality theorem should be the summit, not the first step.

---

## Recommended File/Module Architecture

Create or extend files along these lines:

- `Algebra/TropicalBSD/TropicalLSeries.lean`
  - basic definitions of tropical L-data, active sets, order at one

- `Algebra/TropicalBSD/TropicalRank.lean`
  - tropical rank definitions for finite families

- `Algebra/TropicalBSD/TropicalResidue.lean`
  - regulator/Tamagawa/residue packaging

- `Algebra/TropicalBSD/TropicalBSDEquality.lean`
  - inequality-to-equality upgrade theorem

If the existing files already contain nearby definitions, extend them rather than fragmenting the namespace.

---

## Lean 4 Type Signature Candidates

These are not mandatory verbatim, but your final theorem statements should be at least this precise.

```lean
def tropicalOrderAtOne (a w : ℕ → ℝ) (support : Finset ℕ) : ℕ := ...

def tropicalRank
    {ι κ : Type} [Fintype ι] [DecidableEq ι] [Fintype κ]
    (gens : ι → κ → ℝ) : ℕ := ...

def tropicalResidueAdditive {n : ℕ} (R : Matrix (Fin n) (Fin n) ℝ) (c : Fin n → ℝ) : ℝ := ...

theorem tropical_order_eq_rank
    {ι κ : Type} [Fintype ι] [DecidableEq ι] [Fintype κ]
    (gens : ι → κ → ℝ)
    (a w : ℕ → ℝ)
    (support : Finset ℕ)
    (hcompat : TropicalBSDCompatible gens a w support)
    (hsharp : TropicalSharpAtOne gens a w support) :
    tropicalOrderAtOne a w support = tropicalRank gens

theorem tropical_residue_decomposes_add
    {n : ℕ}
    (R : Matrix (Fin n) (Fin n) ℝ)
    (c : Fin n → ℝ)
    (hR : TropicalRegulatorMatrix R)
    (hc : TropicalTamagawaData c) :
    tropicalResidueAdditive R c
      = tropicalRegulatorAdditive R + tropicalTamagawaAdditive c

theorem tropical_BSD_equality
    {ι κ : Type} [Fintype ι] [DecidableEq ι] [Fintype κ]
    (gens : ι → κ → ℝ)
    (a w : ℕ → ℝ)
    (support : Finset ℕ)
    (hineq : tropicalRank gens ≤ tropicalOrderAtOne a w support)
    (hrev : tropicalOrderAtOne a w support ≤ tropicalRank gens) :
    tropicalRank gens = tropicalOrderAtOne a w support
```

---

## What Would Count as a Breakthrough Here

A result counts as genuinely new and worthwhile if you achieve at least one of:

1. A formal theorem showing **exact equality** between a tropical rank and a tropical order of vanishing for a nontrivial finite class.
2. A formal theorem showing the **tropical residue splits canonically** into regulator-like and Tamagawa-like pieces.
3. A robust abstraction theorem showing **tropical BSD inequality upgrades to equality under sharpness/nondegeneracy hypotheses**.
4. A convex-geometric reformulation proving that the tropical order at one equals the dimension/cardinality of an active face/basis object.

Any of these would define a new formal arithmetic-tropical interface.

---

## Anti-Goals

Do not:
- merely restate BSD in prose with tropical vocabulary,
- define a tropical \(L\)-series so weak that the main theorem becomes tautological,
- bury the mathematics under arbitrary structures with no examples,
- spend the cycle on analytic number theory formalization that cannot close.

Instead:
- make the model finite,
- make the theorem exact,
- make the definitions reusable,
- make the bridge deep.

---

## Deliverables

Required:
- Lean 4 code with minimized `sorry`
- at least one flagship theorem proved
- `FUTURE_DIRECTIONS.md`

Optional but encouraged:
- `ARTICLE.md`
- `RESEARCH_PAPER.md`
- `diagram.svg` showing active faces / residue decomposition
- computational toy examples validating the definitions

---

## Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps at breakthrough level, not incremental variants. Include items of the following sort:

1. Extend tropical BSD equality from finite-support models to piecewise-linear Newton polygon families.
2. Formalize tropical regulators via tropical determinant/permanent and compare competing definitions.
3. Develop tropical Tate–Shafarevich shadows as obstruction terms in idempotent cohomology.
4. Prove a tropical special value formula for higher-dimensional abelian varieties or Jacobians of metric graphs.
5. Connect tropical residue degeneracy to zero-temperature free energy and information-theoretic entropy.

Each item should include:
- exact target theorem/construction,
- why it matters,
- what existing theorem from this cycle it builds on.

---

## Final Directive

Be bold and surgical. Build the first rigorous tropical BSD equality theorem that can actually live in Lean. Use the existing inequality and residue lemmas as launchpads. If full classical fidelity is impossible, create the correct finite tropical arithmetic world in which the analogue is exact, structural, and exportable to optimization, polyhedral geometry, and information theory. That is the real breakthrough.

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

Research domain: Algebra
Research mode: prove
