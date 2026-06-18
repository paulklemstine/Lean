## Assignment: Direction 3: Generation Certificates for Matrix Groups

Prove a genuinely new theorem schema for finite linear groups by transporting the catalog’s certificate philosophy from permutation groups to matrix groups. The goal is not merely to count special elements in `GL n (𝔽_q)`, but to create a **formal generation-certificate infrastructure for classical groups** that can support rigorous lower bounds on random generation probabilities, certified algorithms, and computational experiments.

This direction is timely because the symmetric-group framework in `Algebra/SymmGroupGeneration.lean` already isolates the abstract mechanism:
- identify a certificate predicate `C : G → Prop`,
- prove that any `g` with `C g` is “sufficient” for generation when paired with a second element satisfying a complementary property,
- invoke `generation_lower_bound_of_sufficient_condition`.

Your task is to build the **first nontrivial matrix-group instantiation** of this paradigm.

---

## Core Vision

A Singer cycle in `GL_n(𝔽_q)` is the linear-algebraic analogue of a full cycle in `S_n`: it is an element whose action identifies `𝔽_q^n` with the field extension `𝔽_{q^n}` and acts by multiplication by a primitive element. This imports finite field arithmetic into group generation. The breakthrough is to show that **irreducibility certificates in linear algebra can feed directly into probabilistic generation lower bounds**.

If successful, this opens a field:
- certified random generation for classical groups,
- finite-geometry-driven generation heuristics,
- algorithmic recognition of “field-extension type” elements,
- bridges to coding theory, expander constructions, and black-box group algorithms.

---

## Precise Formalization Target

Build a new file, for example:

`Algebra/MatrixGroupGeneration.lean`

that introduces a certificate notion for matrix groups over finite fields and proves lower bounds by instantiating the abstract theorem from:

- `Algebra/SymmGroupGeneration.lean`
  - `generation_lower_bound_of_sufficient_condition`
  - `SymmGenerationCertificate`

You should define a matrix-group analogue, e.g.
- `LinearGenerationCertificate`
- `IsSingerCycle`
- `IrreducibleActionCertificate`

The formalization should be ambitious but modular: start with the strongest theorem you can prove cleanly in Lean, and isolate conjectural strengthening as explicit conjectures.

---

## Precise Theorem Statements

### Theorem 1: Irreducible characteristic polynomial implies no nontrivial invariant submodule

This is the structural theorem that makes Singer cycles useful as certificates.

Let `K` be a field, `V` a finite-dimensional `K`-vector space, and `φ : V →ₗ[K] V`. If the characteristic polynomial of `φ` is irreducible over `K`, then every `φ`-stable subspace is either `⊥` or `⊤`.

A Lean-oriented type signature could be:

```lean
theorem invariantSubspace_eq_bot_or_top_of_charpoly_irreducible
    {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    [FiniteDimensional K V]
    (φ : Module.End K V)
    (hirr : Irreducible φ.charpoly) :
    ∀ W : Submodule K V,
      W ≤ LinearMap.range φ.toLinearMap →  -- replace by φ-stability predicate as appropriate
      (∃ hW : ∀ w ∈ W, φ w ∈ W, W = ⊥ ∨ W = ⊤) := by
  sorry
```

More realistically, you should define a stability predicate first:

```lean
def IsInvariantSubmodule {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    (φ : Module.End K V) (W : Submodule K V) : Prop :=
  ∀ w, w ∈ W → φ w ∈ W
```

and then prove:

```lean
theorem eq_bot_or_top_of_charpoly_irreducible
    {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    [FiniteDimensional K V]
    (φ : Module.End K V)
    (hirr : Irreducible φ.charpoly) :
    ∀ W : Submodule K V,
      IsInvariantSubmodule φ W → W = ⊥ ∨ W = ⊤ := by
  sorry
```

This theorem is mathematically central: it says the action is irreducible, turning an algebraic polynomial condition into a group-theoretic certificate.

---

### Theorem 2: Singer-cycle certificate implies irreducible action in `GL_n(𝔽_q)`

Define a Singer-style certificate for invertible matrices over a finite field. Since primitive-element formalization may be heavy, begin with the irreducible characteristic polynomial criterion, then strengthen if possible to order `q^n - 1`.

Suggested definition:

```lean
structure LinearGenerationCertificate
    (K : Type*) [Field K]
    (V : Type*) [AddCommGroup V] [Module K V] where
  elem : Module.End K V
  invertible : Function.Bijective elem
  charpoly_irreducible : Irreducible elem.charpoly
```

Or, if working directly in matrices:

```lean
def IsSingerCycleMatrix
    {K : Type*} [Field K] {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n K) : Prop :=
  IsUnit A.det ∧ Irreducible (LinearMap.charpoly (Matrix.toLin' A))
```

Then prove:

```lean
theorem singerCertificate_acts_irreducibly
    {K : Type*} [Field K] {V : Type*}
    [AddCommGroup V] [Module K V] [FiniteDimensional K V]
    (φ : Module.End K V)
    (hcert : Irreducible φ.charpoly) :
    ∀ W : Submodule K V,
      IsInvariantSubmodule φ W → W = ⊥ ∨ W = ⊤ := by
  sorry
```

If you can reach finite fields and cardinality assumptions:

```lean
theorem singerCycle_has_no_nontrivial_invariant_subspace
    {q : ℕ} [Fact q.Prime] {V : Type*}
    [AddCommGroup V] [Module (ZMod q) V]
    [FiniteDimensional (ZMod q) V]
    (φ : Module.End (ZMod q) V)
    (hchar : Irreducible φ.charpoly) :
    ∀ W : Submodule (ZMod q) V,
      IsInvariantSubmodule φ W → W = ⊥ ∨ W = ⊤ := by
  sorry
```

This is the first bridge theorem from the certificate world to finite geometry.

---

### Theorem 3: Abstract generation lower bound for linear certificates

You should instantiate the abstract lower-bound theorem from the symmetric-group file with your new certificate. Even if the full “Singer + determinant primitive root implies generation of all `GL_n(𝔽_q)`” is too strong to prove in one cycle, you should prove a theorem of the following shape:

```lean
theorem generation_lower_bound_of_linear_certificate
    {G : Type*} [Fintype G] [Group G]
    (Cert : G → Prop)
    (h_sufficient :
      ∀ g, Cert g → SufficientForGeneration g) :
    generationProbability G ≥
      (Fintype.card {g : G // Cert g} : ℚ) / Fintype.card G := by
  sorry
```

But the ideal result is a direct reuse of the catalog theorem:

```lean
theorem gl_generation_lower_bound_from_singer_certificate
    {G : Type*} [Fintype G] [Group G]
    (Cert : G → Prop)
    (hcert : ∀ g, Cert g → sufficient_condition_for_generation g) :
    generationProbability G ≥ certificateDensity Cert := by
  simpa using generation_lower_bound_of_sufficient_condition Cert hcert
```

Then specialize to a matrix group model of `GL_n(𝔽_q)`.

If a full formal `GL_n(𝔽_q)` group model is cumbersome, prove the theorem at the level of any finite subgroup `G ≤* GL(V)` equipped with a Singer-certificate predicate.

---

### Theorem 4: Cross-domain theorem — irreducible action yields finite-geometry transitivity surrogate

You are required to include a cross-domain connection. Here the most natural bridge is finite geometry.

A Singer cycle acts transitively on the 1-dimensional subspaces of `𝔽_q^n`; a weaker but still meaningful Lean theorem is:

```lean
theorem irreducible_endomorphism_has_no_fixed_proper_projective_subspace
    {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    [FiniteDimensional K V]
    (φ : Module.End K V)
    (hirr : Irreducible φ.charpoly) :
    ¬ ∃ W : Submodule K V,
        W ≠ ⊥ ∧ W ≠ ⊤ ∧ IsInvariantSubmodule φ W := by
  sorry
```

This is a finite-geometry statement phrased in algebraic language: there is no proper projective subspace preserved by the action. It connects linear group generation to incidence geometry.

A stronger cross-domain theorem, if feasible, is a coding-theoretic one:
- use the orbit of a nonzero vector under a Singer cycle to construct a spanning set;
- prove that the orbit spans the whole space.

Suggested signature:

```lean
theorem span_orbit_eq_top_of_irreducible
    {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    [FiniteDimensional K V]
    (φ : Module.End K V)
    (hirr : Irreducible φ.charpoly)
    {v : V} (hv : v ≠ 0) :
    Submodule.span K (Set.range fun m : ℕ => (φ ^ m) v) = ⊤ := by
  sorry
```

This is excellent because it links:
- group generation,
- cyclic modules,
- coding/spreading sequences,
- dynamical systems on finite vector spaces.

---

## New Definitions You Must Introduce

At least one genuinely new concept is mandatory. Introduce 2–3 if possible.

### 1. Invariant-submodule predicate
```lean
def IsInvariantSubmodule
    {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    (φ : Module.End K V) (W : Submodule K V) : Prop :=
  ∀ w, w ∈ W → φ w ∈ W
```

### 2. Linear generation certificate
```lean
structure LinearGenerationCertificate
    {K V : Type*} [Field K] [AddCommGroup V] [Module K V] where
  φ : Module.End K V
  invertible : Function.Bijective φ
  charpoly_irreducible : Irreducible φ.charpoly
```

### 3. Certificate density for matrix groups
```lean
def certificateDensity
    {G : Type*} [Fintype G] [DecidableEq G]
    (C : G → Prop) : ℚ :=
  (Fintype.card {g : G // C g} : ℚ) / Fintype.card G
```

If the catalog already defines a density notion, reuse it; otherwise define a matrix-group-specific wrapper.

---

## Lean 4 Type Signature Targets

These are the exact kinds of theorem headers I want to see in the file.

```lean
def IsInvariantSubmodule
    {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    (φ : Module.End K V) (W : Submodule K V) : Prop := ...

structure LinearGenerationCertificate
    {K V : Type*} [Field K] [AddCommGroup V] [Module K V] where
  φ : Module.End K V
  invertible : Function.Bijective φ
  charpoly_irreducible : Irreducible φ.charpoly

theorem eq_bot_or_top_of_charpoly_irreducible
    {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    [FiniteDimensional K V]
    (φ : Module.End K V)
    (hirr : Irreducible φ.charpoly) :
    ∀ W : Submodule K V,
      IsInvariantSubmodule φ W → W = ⊥ ∨ W = ⊤ := by
  sorry

theorem span_orbit_eq_top_of_irreducible
    {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    [FiniteDimensional K V]
    (φ : Module.End K V)
    (hirr : Irreducible φ.charpoly)
    {v : V} (hv : v ≠ 0) :
    Submodule.span K (Set.range fun m : ℕ => (φ ^ m) v) = ⊤ := by
  sorry

theorem generation_lower_bound_of_linear_certificate
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (C : G → Prop)
    (hC : ∀ g, C g → SufficientForGeneration g) :
    generationProbability G ≥ certificateDensity C := by
  sorry
```

If the catalog has different names for `generationProbability` or `SufficientForGeneration`, adapt to the actual API, but preserve the mathematical statement.

---

## Proof Strategy: 3 Viable Routes

### Strategy A: Module-theoretic irreducibility via minimal polynomial
**Most promising.**

1. Show that if `W` is a nontrivial invariant submodule of `V`, then the restriction of `φ` to `W` yields a nontrivial polynomial factor of the characteristic polynomial, or at least a proper divisor of the minimal polynomial.
2. Use irreducibility of `φ.charpoly` to force the minimal polynomial to be irreducible of full degree.
3. Conclude that no proper nonzero invariant submodule exists.

Why this is promising:
- Mathlib has strong infrastructure around `LinearMap`, `charpoly`, `minpoly`, and finite-dimensional modules.
- The proof is conceptual and not tied to finite-field enumeration.
- It gives a theorem valid over any field, not just `𝔽_q`.

Likely tactics:
- `rcases` on cases `W = ⊥` or `W ≠ ⊥`,
- `by_contra` for existence of proper invariant subspace,
- `calc` chains between divisibility relations of minimal/characteristic polynomials,
- induction on dimension if needed.

---

### Strategy B: Cyclic-vector/orbit-span argument
**Best for the orbit-spanning cross-domain theorem.**

1. For nonzero `v`, define `W := span K { φ^m v | m ∈ ℕ }`.
2. Prove `W` is invariant under `φ`.
3. Apply Theorem 1 to conclude `W = ⊤` since `v ∈ W` and `v ≠ 0`, so `W ≠ ⊥`.

Why this is promising:
- It naturally yields the finite-geometry/coding-theory bridge theorem.
- The proof uses induction on powers and explicit submodule manipulations.
- It is constructive: it gives an algorithm for generating a spanning set from one orbit.

This theorem should definitely involve multi-step `calc` reasoning and submodule membership proofs.

---

### Strategy C: Group-theoretic instantiation of the abstract certificate theorem
**Most efficient once A/B are in place.**

1. Define a certificate predicate on the chosen finite group model of invertible linear maps.
2. Prove that every certified element satisfies the sufficient condition required by the abstract theorem from `Algebra/SymmGroupGeneration.lean`.
3. Apply `generation_lower_bound_of_sufficient_condition` directly.

Why this is promising:
- It leverages the catalog exactly as intended.
- The proof is not computational; it is a transfer principle from structural algebra to probabilistic generation.
- It sets up future work for `SL_n`, `PGL_n`, symplectic groups, and unitary groups.

---

## What Would Count as a Breakthrough Here

The real breakthrough is not “Singer cycles exist.” That is classical. The breakthrough is:

> A formally reusable **certificate architecture for linear groups** where algebraic irreducibility of an operator implies measurable lower bounds on random generation.

This would be the first step toward:
- certified random-generation bounds for `GL_n(𝔽_q)`, `SL_n(𝔽_q)`, `Sp_{2n}(𝔽_q)`,
- black-box recognition algorithms using characteristic-polynomial certificates,
- finite-geometry-driven probabilistic group theory.

The concept generalizes beyond matrix groups:
- monodromy groups in arithmetic geometry,
- transfer operators in dynamical systems,
- linear recurrences in coding and cryptography.

---

## Cross-Domain Connections You Must Explicitly Develop

### Finite Geometry
Singer cycles correspond to cyclic collineation groups of projective spaces `PG(n-1,q)`. Your irreducibility theorem should be interpreted geometrically as the absence of preserved proper projective subspaces.

### Coding Theory
The orbit of a nonzero vector under a Singer cycle gives a cyclic spanning family. This is closely related to linear feedback shift registers, cyclic codes, and MDS-style constructions. Formalize at least the spanning theorem.

### Cryptography
Singer cycles are multiplication-by-primitive-element actions on `𝔽_{q^n}`. This connects to discrete logarithm structure, pseudorandom orbit generation, and companion-matrix representations.

### Probabilistic Group Theory
The generation certificate transforms structural linear algebra into lower bounds on random generation probability.

---

## Concrete Computational Program

You must include a verified computational method, not just theorem statements.

### Verified algorithm
Implement an algorithm that, for small `n, q`, tests whether a matrix qualifies as a provisional Singer certificate:
1. compute determinant and reject singular matrices,
2. compute characteristic polynomial,
3. test irreducibility over `𝔽_q`,
4. optionally test whether order divides/equals `q^n - 1` when feasible.

Even if order computation is expensive, the irreducible-charpoly criterion is already substantial.

Possible artifact:
- `def isSingerCertificateCandidate : Matrix n n (ZMod q) → Bool`
- prove soundness:
```lean
theorem isSingerCertificateCandidate_sound
    (A : Matrix n n (ZMod q))
    (h : isSingerCertificateCandidate A = true) :
    IsSingerCycleMatrix A := by
  sorry
```

### demo.py
Your `demo.py` should:
- enumerate matrices in `GL_2(𝔽_3)`, `GL_2(𝔽_5)`, `GL_3(𝔽_2)`,
- estimate certificate density,
- compare with generation experiments using GAP or direct enumeration where feasible,
- print candidate lower bounds and empirical generation fractions.

---

## Falsifiable Conjecture with Computational Test

State at least one explicit conjecture.

### Conjecture A: Linear certificate density lower bound
For fixed `q` and increasing `n`,
\[
\frac{\#\{\text{Singer certificates in } GL_n(\mathbb{F}_q)\}}{|GL_n(\mathbb{F}_q)|}
\ge \frac{c_q}{n}
\]
for some constant `c_q > 0`.

Computational disproof test:
- enumerate or sample random elements in `GL_n(𝔽_q)` for small `n`,
- test irreducible characteristic polynomial,
- fit `n * density_n`; if it trends to zero, the conjecture fails.

### Conjecture B: Certificate sufficiency for high-probability generation
For random `g,h ∈ GL_n(𝔽_q)`, if `g` is a Singer certificate and `det h` is primitive in `𝔽_q^×`, then
\[
\Pr[\langle g,h\rangle = GL_n(\mathbb{F}_q)] \ge 1 - O(q^{-1}).
\]

Computational test:
- for small groups, enumerate pairs `(g,h)` with `g` certified and `det h` primitive,
- compute subgroup generated,
- compare failure rate as `q` grows.

This conjecture is strong and absolutely falsifiable.

---

## Required Theorem Count and Depth

Your Lean development must contain at least 3 substantial theorems with genuine proof structure. Suitable candidates are:

1. `eq_bot_or_top_of_charpoly_irreducible`
2. `span_orbit_eq_top_of_irreducible`
3. `generation_lower_bound_of_linear_certificate`
4. `irreducible_endomorphism_has_no_fixed_proper_projective_subspace`

At least three of these should use nontrivial tactics such as:
- `induction`
- `rcases`
- `by_contra`
- `field_simp` where relevant
- multi-step `calc`

No toy lemmas padded into the count.

---

## Catalog Build Instructions

You must explicitly build on:

- `Algebra/SymmGroupGeneration.lean`
  - `generation_lower_bound_of_sufficient_condition`
  - `SymmGenerationCertificate`

Your mission is to **abstract the certificate mechanism away from permutations and into linear actions**. If useful, mirror the API shape of `SymmGenerationCertificate` so future files can instantiate a common interface.

A particularly strong outcome would be to define a typeclass or structure for certificate systems:
```lean
structure GenerationCertificateSystem (G : Type*) [Group G] where
  Cert : G → Prop
  sufficient : ∀ g, Cert g → SufficientForGeneration g
```
and then instantiate it both for symmetric groups and linear groups.

That would be a major architectural contribution.

---

## Deliverables (MANDATORY)

You must produce ALL of the following:

1. `FUTURE_DIRECTIONS.md`
   - 3–5 original research directions.
   - Each direction must include the exact sentences:
     - **“The key insight is...”**
     - **“Why now?”**
   - At least one direction must bridge to a different domain, such as coding theory, finite geometry, or cryptography.

2. `RESEARCH_PAPER.md`
   - A standalone scientific paper.
   - A reader with no access to code must understand:
     - the new definitions,
     - the main theorems,
     - why they matter,
     - the computational evidence,
     - the conjectures and next steps.

3. `ARTICLE.md`
   - Written in Scientific American style.
   - Explain the ideas and significance to a broad audience.
   - Do **not** focus on formal verification machinery.
   - Focus on Singer cycles, hidden field structure inside matrices, and why this matters for understanding random generation.

4. A verified algorithm or computational method
   - not just theorem statements,
   - but an actual tested procedure for recognizing certificate candidates and estimating density.

5. `demo.py`
   - interactive or command-line demonstration,
   - computes small-case densities,
   - compares with generation experiments,
   - displays test results for the stated conjecture.

---

## Application Keywords

finite group theory, random generation, matrix groups, Singer cycles, finite fields, irreducible characteristic polynomial, invariant subspaces, projective geometry, coding theory, cryptography, cyclic modules, black-box groups, probabilistic algebra, certified algorithms, computational group theory

---

## Final Charge

Do not settle for a weak restatement of known facts. The target is a new **certificate language for linear groups** that makes random generation lower bounds a consequence of structural linear algebra. If you succeed, this will not be “an extension of the symmetric-group file.” It will be the prototype for a whole new layer of certified probabilistic group theory across classical groups.

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
    "visualizations": [ { "name": "...", "code": "# matplotlib or plotly script, self-contained", "description": "What this visualizes" } ],
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
