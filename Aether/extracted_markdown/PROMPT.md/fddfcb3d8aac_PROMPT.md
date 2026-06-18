## Assignment: Homological Algebra: Derived Functors

Mode: **prove/formalize**

This direction is worth pursuing only if we refuse to make it a routine library extension. The real target is to turn Lean into a machine that can express and verify the architecture of derived functors in enough generality that algebraic topology, representation theory, algebraic geometry, and even categorical semantics can all plug into the same formal engine. Ext, Tor, long exact sequences, and the universal coefficient theorem are not isolated milestones: together they form the first serious gateway from “chain complexes exist in Lean” to “derived mathematics is operational in Lean.”

Your mission is to build that gateway.

### Breakthrough Objective

Formalize the first robust Lean 4 pipeline for **derived functors over concrete rings and modules**, culminating in machine-checked versions of:

1. **Ext as the cohomology of Hom out of a projective resolution**
2. **Tor as the homology of tensoring a projective resolution**
3. **The long exact sequence in cohomology induced by a short exact sequence of cochain complexes**
4. **Concrete projective/injective resolutions for explicit modules**
5. **A universal coefficient theorem for homology over `ℤ`**, at least in a concrete finitely generated setting, and ideally in a natural short exact sequence form

This is a breakthrough because once these are in place, Aristotle can formalize spectral sequences, derived categories, sheaf cohomology prototypes, and homological invariants in topology and number theory. Without this infrastructure, all of those remain aspirational.

---

## Precise Theorem Targets

You should aim for the strongest theorem statements that Mathlib’s current category-theoretic and homological infrastructure will support, but do not hide behind abstraction if concrete algebra is the only path to completion. If necessary, prove concrete `Module ℤ` versions first and then isolate the abstract interface.

### Target 1: Long exact sequence in cohomology

Let `R` be a ring and let
`0 ⟶ A ⟶ B ⟶ C ⟶ 0`
be a short exact sequence of cochain complexes of `R`-modules. Prove that there exists a connecting morphism
`δ_n : H^n(C) ⟶ H^(n+1)(A)`
making the induced sequence exact at every stage:
`… ⟶ H^n(A) ⟶ H^n(B) ⟶ H^n(C) ⟶ H^(n+1)(A) ⟶ …`

A Lean-facing theorem shape could be:

```lean
theorem cohomology_long_exact_of_short_exact
  {R : Type u} [Ring R]
  {A B C : CochainComplex (ModuleCat R) ℤ}
  (f : A ⟶ B) (g : B ⟶ C)
  (hfg : f ≫ g = 0)
  (hexact : ∀ n : ℤ, Function.Exact (f.f n) (g.f n))
  (hmono : ∀ n : ℤ, Mono (f.f n))
  (hepi  : ∀ n : ℤ, Epi (g.f n)) :
  ∃ (δ : ∀ n : ℤ, (CohomologyFunctor (ModuleCat R) n).obj C ⟶
                   (CohomologyFunctor (ModuleCat R) (n+1)).obj A),
    ∀ n : ℤ, Function.Exact
      (((CohomologyFunctor (ModuleCat R) n).map f))
      (((CohomologyFunctor (ModuleCat R) n).map g)) ∧
      Function.Exact
      (((CohomologyFunctor (ModuleCat R) n).map g))
      (δ n)
```

If this exact type is too ambitious for current APIs, prove a degreewise concrete version for complexes of abelian groups or `ModuleCat ℤ`.

### Target 2: Ext via projective resolutions

For an `R`-module `M`, define a projective resolution `P• ⟶ M`. For any `N`, define:
`Ext^n_R(M,N) := H^n(Hom(P•, N))`
and prove independence of the chosen projective resolution at least up to nonempty isomorphism in low degrees or for concrete modules.

A realistic Lean target:

```lean
def Ext0
  {R : Type u} [Ring R] (M N : ModuleCat R) : Type _ := ...

theorem Ext0_iso_Hom
  {R : Type u} [Ring R] (M N : ModuleCat R) :
  Nonempty (Ext0 M N ≅ (M ⟶ N)) := ...
```

Then push to:

```lean
def Ext
  {R : Type u} [Ring R] (n : ℕ) (M N : ModuleCat R) : Type _ := ...

theorem Ext_one_classifies_extensions
  {R : Type u} [Ring R] (M N : ModuleCat R) :
  Nonempty (Ext 1 M N ≃ extension_classes M N) := ...
```

If classification of extensions is too large for one cycle, at least prove:

```lean
theorem Ext_vanishes_for_projective_left
  {R : Type u} [Ring R] (P N : ModuleCat R) [Projective P] (n : ℕ) :
  0 < n → Subsingleton (Ext n P N) := ...
```

### Target 3: Tor via tensoring a projective resolution

For a projective resolution `P• ⟶ M`, define:
`Tor_n^R(M,N) := H_n(P• ⊗ N)`

Lean target:

```lean
def Tor
  {R : Type u} [CommRing R] (n : ℕ) (M N : ModuleCat R) : Type _ := ...

theorem Tor_zero_iso_tensor
  {R : Type u} [CommRing R] (M N : ModuleCat R) :
  Nonempty (Tor 0 M N ≅ ModuleCat.of R (M ⊗[R] N)) := ...
```

And a nontrivial concrete theorem over `ℤ`:

```lean
theorem Tor_Zmod_Zmod
  (m n : ℕ) :
  Nonempty (Tor 1 (ModuleCat.of ℤ (ZMod m)) (ModuleCat.of ℤ (ZMod n))
    ≅ ModuleCat.of ℤ (ZMod (Nat.gcd m n))) := ...
```

This theorem is mathematically sharp, concrete, and opens computational algebra.

### Target 4: Concrete projective resolutions

Construct explicit free/projective resolutions for modules like `ℤ/nℤ` over `ℤ`.

Key theorem:

```lean
theorem exists_free_resolution_ZMod
  (n : ℕ) :
  ∃ (P : ChainComplex (ModuleCat ℤ) ℕ),
    ProjectiveResolution (ModuleCat.of ℤ (ZMod n)) P := ...
```

Even a 2-term resolution is enough for major downstream computation:
`ℤ --(·n)--> ℤ --> ℤ/nℤ --> 0`

### Target 5: Universal coefficient theorem for homology

For a chain complex `C` of free abelian groups and an abelian group `A`, prove a natural short exact sequence:
`0 → H_n(C) ⊗ A → H_n(C;A) → Tor(H_{n-1}(C), A) → 0`

Lean target shape:

```lean
theorem universal_coefficient_homology_Z
  (C : ChainComplex (ModuleCat ℤ) ℕ)
  (A : ModuleCat ℤ)
  (hfree : ∀ n, Module.Free ℤ (C.X n)) :
  ∀ n : ℕ,
  ∃ (i : ModuleCat.of ℤ ((homology C n) ⊗[ℤ] A) ⟶ homology (tensorChainComplex C A) n)
    (p : homology (tensorChainComplex C A) n ⟶ Tor 1 (homology C (n-1)) A),
    Function.Exact i p := ...
```

If the split exact sequence is too difficult, prove the exactness statement first. If even that is too large, prove the theorem for finite free complexes or for the explicit 2-term complex resolving `ℤ/nℤ`.

---

## Lean 4 Formalization Targets

You should define only what Mathlib does not already expose cleanly. Before inventing structures, inspect existing APIs for:

- `CategoryTheory`
- `Algebra.Homology.HomologicalComplex`
- `Algebra.Homology.ShortComplex`
- `CategoryTheory.Abelian`
- `ModuleCat`
- `FunctorCategory`
- tensor/Hom adjunction APIs
- projective/injective objects
- cohomology and homology functors

A plausible set of Lean definitions to introduce:

```lean
def projectiveResolution
  {R : Type u} [Ring R] (M : ModuleCat R) := ...

def Ext
  {R : Type u} [Ring R] (n : ℕ) (M N : ModuleCat R) := ...

def Tor
  {R : Type u} [CommRing R] (n : ℕ) (M N : ModuleCat R) := ...

def extension_classes
  {R : Type u} [Ring R] (M N : ModuleCat R) := ...
```

If full universe-polymorphic category-theoretic definitions become brittle, create a concrete layer over `ModuleCat ℤ` first. A concrete successful theorem beats a perfectly abstract sorry-filled scaffold.

---

## Proof Strategy Architecture

### Strategy A: Concrete-first over `ℤ`, then abstract upward
This is the most promising route.

1. **Build explicit finite resolutions**
   - Start with the 2-term free resolution of `ℤ/nℤ`.
   - Compute `Hom` and tensor complexes directly.
   - Derive explicit `Ext^1` and `Tor_1` calculations.

2. **Prove exactness by element-chasing in concrete modules**
   - Use kernels, images, quotient presentations, and explicit representatives.
   - Formalize connecting maps concretely before abstracting them.

3. **Generalize only after the computational core works**
   - Once `Tor_1(ℤ/m, ℤ/n) ≅ ℤ/gcd(m,n)` and `Ext^1_ℤ(ℤ/n,A) ≅ A/nA` are formalized, extract reusable abstractions.

Why this is strongest: Lean handles concrete algebraic data more reliably than high-level derived constructions from scratch, and these concrete computations force the right API design.

### Strategy B: Abelian-category route via existing homology infrastructure
This is more elegant, but riskier.

1. **Use short exact sequences of complexes and existing cohomology functors**
   - Search for already formalized snake-lemma-like or exactness transport lemmas.
   - Build the connecting morphism through kernels/cokernels in an abelian category.

2. **Define Ext as right derived functors of `Hom(M,-)`**
   - If Mathlib’s derived functor APIs are insufficient, emulate them through resolutions and comparison maps.

3. **Prove universal coefficient as a consequence of exactness of tensor on free resolutions**
   - This route could eventually scale to arbitrary PIDs and sheaf-theoretic contexts.

Why it matters: if successful, this opens a genuinely reusable derived-functor framework, not just a collection of examples.

### Strategy C: Hybrid computational-categorical bridge
This may be the ideal architecture.

1. **Abstract the pattern of “apply additive functor to a resolution, then take homology”**
   - Create a generic mechanism for `Hom` and tensor separately.

2. **Instantiate for explicit complexes**
   - Verify on the free resolution of `ℤ/nℤ`.

3. **Use the concrete examples as regression tests**
   - Every abstraction should be validated by recovering `Tor_1^ℤ(ℤ/m,ℤ/n)` and `Ext^1_ℤ(ℤ/n,A)`.

This strategy is likely best if you can sustain both theorem proving and library design simultaneously.

---

## Nontrivial Intermediate Theorems Worth Proving

These are not filler; they are structural stepping stones.

### Ext over `ℤ`
```lean
theorem Ext1_ZMod
  (n : ℕ) (A : ModuleCat ℤ) :
  Nonempty (Ext 1 (ModuleCat.of ℤ (ZMod n)) A ≅ ModuleCat.of ℤ (A / n • ⊤)) := ...
```

Or in a more standard additive form:
`Ext^1_ℤ(ℤ/nℤ, A) ≅ A / nA`

### Tor over `ℤ`
```lean
theorem Tor1_ZMod
  (n : ℕ) (A : ModuleCat ℤ) :
  Nonempty (Tor 1 (ModuleCat.of ℤ (ZMod n)) A ≅
    ModuleCat.of ℤ {a : A // (n : ℤ) • a = 0}) := ...
```

This identifies `Tor_1^ℤ(ℤ/nℤ,A)` with the `n`-torsion subgroup.

### Vanishing theorems
```lean
theorem Ext_vanishes_above_zero_for_projective
  {R : Type u} [Ring R] (P N : ModuleCat R) [Projective P] :
  ∀ n : ℕ, 0 < n → Subsingleton (Ext n P N) := ...
```

```lean
theorem Tor_vanishes_above_zero_for_flat
  {R : Type u} [CommRing R] (M N : ModuleCat R) [Module.Flat R M] :
  ∀ n : ℕ, 0 < n → Subsingleton (Tor n M N) := ...
```

These are conceptually powerful because they make Lean capable of expressing homological dimension phenomena.

---

## Cross-Domain Connections You Should Explicitly Exploit

Do not leave this as pure algebra. Tie it to other domains so the formalization becomes a platform, not a silo.

### 1. Algebraic Topology
The universal coefficient theorem is the bridge from chain-level topology to coefficient systems. Once formalized, Aristotle can compute homology with coefficients for simplicial complexes, CW approximations, or cellular chain complexes.

**Concrete impact:** certified computation of `H_n(X; A)` from integral homology.

### 2. Representation Theory
`Ext^1` classifies module extensions and therefore deformations of representations. Formalized Ext immediately becomes a language for block theory, quiver representations, and deformation-theoretic semantics.

**Concrete impact:** Lean-verified extension classes of finite-dimensional representations.

### 3. Arithmetic / Computational Algebra
The theorem
`Tor_1^ℤ(ℤ/m, ℤ/n) ≅ ℤ/gcd(m,n)`
connects derived functors to algorithmic number theory through gcd structure, Smith normal form, and finitely generated abelian groups.

**Concrete impact:** machine-checked algebraic invariants driven by effective arithmetic.

### 4. Type Theory / Semantics
Derived functors measure failure of exactness. In semantics, this is a rigorous algebraic model of obstruction, dependency, and higher-order correction terms. A formalized exactness calculus in Lean can influence verified compilers and compositional semantics.

### 5. Topological Data Analysis / Applied Topology
UCT allows coefficient changes in persistent or combinatorial homology. Once chain complexes are concrete, one can certify coefficient-sensitive invariants.

---

## How to Use Existing Catalog Theorems

The listed catalog theorems are not directly homological, but they should still influence your style of attack.

- `norm_exact_sequence` strongly suggests there is already some exact-sequence reasoning in the repository. Mine its proof patterns, naming conventions, and any local lemmas about exactness transport.
- `idempotent_hilbert_basis_theorem` may contain useful infrastructure for module-like algebraic constructions and proof organization around nontrivial algebraic objects.
- The other catalog theorems are cross-domain reminders: this cycle should produce a bridge theorem, not just internal algebra. In particular, use the arithmetic flavor of `insufficient_qubits_theorem` as motivation to prioritize explicit `ℤ`-module computations over purely abstract category theory.

---

## Suggested File-Level Deliverables

Create a coherent cluster, for example:

- `Algebra/Homology/DerivedFunctors/ProjectiveResolutionConcrete.lean`
- `Algebra/Homology/DerivedFunctors/ExtBasic.lean`
- `Algebra/Homology/DerivedFunctors/TorBasic.lean`
- `Algebra/Homology/DerivedFunctors/LongExactSequence.lean`
- `Algebra/Homology/DerivedFunctors/UniversalCoefficient.lean`

Do not spread definitions chaotically. Build a ladder:
concrete resolutions → Ext/Tor definitions → exact sequence machinery → UCT.

---

## Minimal Victory Conditions

If full generality is out of reach this cycle, the following package still counts as a serious success:

1. Define a concrete free resolution of `ZMod n` over `ℤ`
2. Define `Tor` and/or `Ext` via that resolution
3. Prove at least one explicit computational theorem:
   - `Tor_1^ℤ(ℤ/m,ℤ/n) ≅ ℤ/gcd(m,n)`, or
   - `Ext^1_ℤ(ℤ/nℤ,A) ≅ A/nA`
4. Prove a concrete long exact sequence in cohomology for complexes of abelian groups
5. State and partially formalize a UCT exact sequence, with at least one fully proved special case

That would already be field-opening for Lean homological algebra.

---

## Application Keywords

derived functors, Ext, Tor, universal coefficient theorem, long exact sequence, projective resolution, injective resolution, cohomology, homology, abelian categories, module theory, algebraic topology, representation theory, computational algebra, finitely generated abelian groups, Smith normal form, exactness, certified mathematics

---

## Required Research Discipline

- Minimize `sorry` aggressively.
- Prefer one fully proved deep theorem over five abstract placeholders.
- Use concrete types where possible: `ModuleCat ℤ`, `ZMod n`, finite free modules, explicit chain complexes.
- If a categorical proof stalls, switch immediately to an elementwise proof in the concrete category of abelian groups/modules over `ℤ`.
- Record every obstruction as a theorem-shaping insight, not as a dead end.

---

## Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md`, and it must contain **3–5 concrete next-step theorems**, each with:

1. a precise theorem statement,
2. a proposed Lean type signature,
3. 2 proof strategy sketches,
4. one cross-domain connection.

The next-step theorems should be breakthrough-level, such as:

- Ext/Tor over PIDs via Smith normal form
- classification of extensions by `Ext^1`
- Künneth-type formulas for finite free chain complexes
- derived functor computations for group cohomology prototypes
- UCT for cochain complexes and cohomology

This file is not optional bookkeeping. It is the mechanism by which this work becomes a research program rather than a one-off formalization.

---

You are Aristotle. Do not merely encode standard textbook algebra. Build the verified entrance ramp to derived mathematics.

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
