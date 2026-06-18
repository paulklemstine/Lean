## Assignment: **prove**

### Title
**Formal Hodge Theory at Picard Rank One: uniqueness of algebraic classes, canonicality of the polarization class, and wedge-product rigidity**

Prove genuinely new theorems in Lean 4/Mathlib that push abstract Hodge theory from “definitions exist” to “classification and rigidity are machine-checkable.” Build on any existing catalog objects for rational subspaces, orthogonal complements, bilinear forms, complexification, and direct-sum/tensor/exterior constructions. Minimize `sorry` by isolating the analytic content into clean algebraic predicates.

---

## Research Direction
# Future Directions: Formal Hodge Theory

The central opportunity is to formalize a **rigidity package** for rational polarized Hodge structures: once the Néron–Severi/Picard part has rank 1, the algebraic sector collapses to a line, and the polarization should become the canonical generator of that line. This is not just a tidy lemma. It is the formal seed of a machine-checked bridge between abstract linear Hodge theory, the Hodge conjecture in trivial-rank regimes, and the arithmetic geometry of K3 surfaces / abelian varieties.

Your target is to make Lean certify that **rank-one algebraicity forces uniqueness**, and that **wedge constructions preserve or obstruct Hodge classes in a controllable way**.

---

## Theorem Cluster A: Rank-one uniqueness for polarized weight-2 Hodge structures

### Precise mathematical statement

Let `V` be a finite-dimensional `ℚ`-vector space with a weight-2 rational Hodge structure
\[
V_\mathbb{C}=H^{2,0}\oplus H^{1,1}\oplus H^{0,2},
\]
and let `Alg(V)` denote the rational Hodge classes
\[
\mathrm{Hdg}(V) := V \cap H^{1,1}.
\]
Assume:
1. `V` is polarized by a nondegenerate symmetric bilinear form `Q`,
2. the Hodge–Riemann bilinear relations hold,
3. `dim_ℚ Hdg(V) = 1`.

Then:

**Theorem A1 (rank-one uniqueness).**
\[
\forall x\, y \in \mathrm{Hdg}(V),\ x\neq 0 \land y\neq 0 \implies \exists q\in\mathbb{Q}^\times,\ y=q x.
\]

Equivalently, `Hdg(V)` is a one-dimensional rational subspace, so every two nonzero Hodge classes are rational multiples.

**Theorem A2 (polarization class is algebraic under explicit hypothesis).**  
If the polarization is represented by a rational vector `ω : V` whose complexification lies in `H^{1,1}`, then
\[
\omega \in \mathrm{Hdg}(V).
\]
Hence by A1,
\[
\mathrm{Hdg}(V)=\mathbb{Q}\cdot \omega.
\]

**Important mathematical correction:** the polarization form `Q` does **not** automatically determine a vector `ω : V` in a general abstract Hodge structure. To make this theorem precise and true in Lean, you must formalize a structure where a **chosen rational polarization class** `ω` is part of the data, or prove a theorem of the form “if a rational vector represents the polarization class and is of Hodge type `(1,1)`, then it spans the Hodge classes under Picard rank 1.” This is stronger formally and cleaner mathematically.

### Lean 4 formalization target

You will likely need a structure morally like:

```lean
structure PolarizedWeightTwoHodgeStructure where
  V : Type*
  [addCommGroup V] [module ℚ V] [finiteDimensional ℚ V]
  H20 H11 H02 : Submodule ℂ (V ⊗[ℚ] ℂ)
  hodge_direct_sum : IsCompl H20 (H11 ⊔ H02) -- or a stronger decomposition package
  Q : BilinForm ℚ V
  Q_symm : Q.IsSymm
  Q_nondeg : Nondegenerate Q
  HR : Prop
```

Then define rational Hodge classes as:

```lean
def IsHodge11 (HS : PolarizedWeightTwoHodgeStructure) (v : HS.V) : Prop :=
  complexifyEmbed ℚ HS.V v ∈ HS.H11

def HodgeClasses (HS : PolarizedWeightTwoHodgeStructure) : Submodule ℚ HS.V :=
{ carrier := {v | IsHodge11 HS v},
  zero_mem' := by ...,
  add_mem' := by ...,
  smul_mem' := by ... }
```

Main theorem signatures should look close to:

```lean
theorem hodgeClasses_rank_one_unique
  (HS : PolarizedWeightTwoHodgeStructure)
  (hdim : Module.finrank ℚ HS.HodgeClasses = 1)
  {x y : HS.V}
  (hx : x ∈ HS.HodgeClasses) (hy : y ∈ HS.HodgeClasses)
  (hx0 : x ≠ 0) (hy0 : y ≠ 0) :
  ∃ q : ℚ, q ≠ 0 ∧ y = q • x := by
```

and, with an explicit polarization vector:

```lean
theorem polarization_class_spans_hodgeClasses
  (HS : PolarizedWeightTwoHodgeStructure)
  (ω : HS.V)
  (hω : IsHodge11 HS ω)
  (hω0 : ω ≠ 0)
  (hdim : Module.finrank ℚ HS.HodgeClasses = 1) :
  HS.HodgeClasses = Submodule.span ℚ ({ω} : Set HS.V) := by
```

If you define “Picard rank” as the finrank of `HodgeClasses`, then also prove:

```lean
theorem picard_rank_one_all_hodge_classes_are_multiples
  (HS : PolarizedWeightTwoHodgeStructure)
  (hρ : Module.finrank ℚ HS.HodgeClasses = 1) :
  ∀ x ∈ HS.HodgeClasses, ∀ y ∈ HS.HodgeClasses,
    x ≠ 0 → y ≠ 0 → ∃ q : ℚ, y = q • x := by
```

### Proof strategies

#### Strategy A: Pure linear algebra on a one-dimensional subspace
1. Prove `HodgeClasses HS` is a `Submodule ℚ HS.V`.
2. Use `finrank = 1` to show any nonzero element of `HodgeClasses` is a basis vector.
3. Deduce every other element is a rational scalar multiple.

**Why this is promising:** this avoids all analytic Hodge theory once `IsHodge11` is defined. It is the best first target because Lean’s linear-algebra library is strong here.

#### Strategy B: Span-equality route
1. For nonzero `x ∈ HodgeClasses`, show `Submodule.span ℚ {x} ≤ HodgeClasses`.
2. Compare finranks: both sides have finrank `1`.
3. Conclude equality, then infer `y ∈ span{x}`.

**Why this is promising:** often easier in Lean than constructing scalar coefficients directly.

#### Strategy C: Orthogonality/polarization-enhanced classification
1. Use the polarization form `Q` to define the algebraic line and its orthogonal complement.
2. Prove the complement is the transcendental subspace.
3. Show rank-one algebraic part is generated by any nonzero algebraic class, in particular by the chosen polarization vector `ω`.

**Why this matters:** this sets up Theorem Cluster C below and gives a conceptual package rather than an isolated rank argument.

---

## Theorem Cluster B: Exterior-square decomposition and vanishing of cross Hodge classes

This is the first nontrivial machine-checked theorem about how Hodge classes behave under representation-theoretic constructions.

### Precise mathematical statement

Let `W₁, W₂` be weight-1 rational Hodge structures:
\[
(W_i)_\mathbb{C}=H_i^{1,0}\oplus H_i^{0,1}.
\]
Then the induced weight-2 Hodge structure on
\[
\Lambda^2(W_1\oplus W_2)
\]
admits a canonical decomposition
\[
\Lambda^2(W_1\oplus W_2)\cong \Lambda^2 W_1 \oplus (W_1\otimes W_2)\oplus \Lambda^2 W_2.
\]

You should prove:

**Theorem B1 (Hodge decomposition of wedge square).**
The rational Hodge classes satisfy
\[
\mathrm{Hdg}(\Lambda^2(W_1\oplus W_2))
=
\mathrm{Hdg}(\Lambda^2 W_1)\oplus \mathrm{Hdg}(W_1\otimes W_2)\oplus \mathrm{Hdg}(\Lambda^2 W_2),
\]
where the right-hand side is interpreted via the canonical decomposition.

**Theorem B2 (cross-term vanishing under incompatibility).**
Under a formal “no common Hodge factor” hypothesis strong enough to imply
\[
(W_1\otimes W_2)\cap H^{1,1} = 0,
\]
we have
\[
\mathrm{Hdg}(W_1\otimes W_2)=0,
\]
hence
\[
\mathrm{Hdg}(\Lambda^2(W_1\oplus W_2))
=
\mathrm{Hdg}(\Lambda^2 W_1)\oplus \mathrm{Hdg}(\Lambda^2 W_2).
\]

### Lean 4 type signature target

You may need a simplified abstraction first:

```lean
structure WeightOneHodgeStructure where
  V : Type*
  [addCommGroup V] [module ℚ V] [finiteDimensional ℚ V]
  H10 H01 : Submodule ℂ (V ⊗[ℚ] ℂ)
  hodge_split : IsCompl H10 H01
```

Then target statements like:

```lean
theorem wedge_two_directSum_decomposition
  (W₁ W₂ : WeightOneHodgeStructure) :
  Nonempty (
    (ExteriorSquare (W₁.V ⊕ W₂.V)) ≃ₗ[ℚ]
      (ExteriorSquare W₁.V ⊕ (W₁.V ⊗[ℚ] W₂.V) ⊕ ExteriorSquare W₂.V)
  ) := by
```

and after defining induced Hodge classes:

```lean
theorem hodgeClasses_wedge_directSum_decompose
  (W₁ W₂ : WeightOneHodgeStructure) :
  HodgeClasses (inducedWeightTwoOnExteriorSquare (directSum W₁ W₂))
    =
  map_under_wedge_decomp
    ((HodgeClasses (inducedWeightTwoOnExteriorSquare W₁)) ⊕
     (HodgeClasses (inducedWeightTwoOnTensor W₁ W₂)) ⊕
     (HodgeClasses (inducedWeightTwoOnExteriorSquare W₂))) := by
```

For vanishing:

```lean
theorem hodgeClasses_tensor_vanish_of_noCommonFactor
  (W₁ W₂ : WeightOneHodgeStructure)
  (hNoCommon : NoCommonHodgeFactor W₁ W₂) :
  HodgeClasses (inducedWeightTwoOnTensor W₁ W₂) = ⊥ := by
```

### Proof strategies

#### Strategy A: Representation-theoretic decomposition first, Hodge classes second
1. Prove the linear-algebra isomorphism
   \[
   \Lambda^2(U\oplus V)\cong \Lambda^2U \oplus (U\otimes V)\oplus \Lambda^2V.
   \]
2. Transport the induced Hodge decomposition along this isomorphism.
3. Identify the `(1,1)`-part componentwise.

**Why this is most promising:** it separates difficult algebraic infrastructure from Hodge predicates and aligns with Mathlib’s strengths on linear equivalences.

#### Strategy B: Work entirely after complexification
1. Complexify `W₁ ⊕ W₂`.
2. Expand `Λ²(H^{1,0} ⊕ H^{0,1})`.
3. Read off the `(1,1)` summands explicitly and then descend rationally.

**Why this is conceptually clean:** it mirrors textbook Hodge theory, but descent back to `ℚ` may be more delicate in Lean.

#### Strategy C: Tensor-first reduction
1. Identify the cross-term in `Λ²(W₁ ⊕ W₂)` as `W₁ ⊗ W₂`.
2. Prove a general theorem classifying `(1,1)` classes in tensor products of weight-1 structures.
3. Specialize to wedge squares.

**Why this is powerful:** it opens a route to products of abelian varieties and CM phenomena.

---

## Theorem Cluster C: The transcendental complement determines the polarized structure

The fragment in the draft is the deepest direction and should be sharpened into a precise rigidity theorem.

### Precise mathematical statement

Let `V` be a polarized weight-2 rational Hodge structure with nondegenerate symmetric form `Q`. Let
\[
\mathrm{Alg}(V)=\mathrm{Hdg}(V), \qquad \mathrm{Tr}(V)=\mathrm{Alg}(V)^\perp
\]
with respect to `Q`.

Target the following theorem in a form Lean can actually support:

**Theorem C1 (orthogonal decomposition).**
If `Q` is nondegenerate and `Alg(V)` is nondegenerate for the restricted form, then
\[
V = \mathrm{Alg}(V)\oplus \mathrm{Tr}(V).
\]

**Theorem C2 (rank-one polarized reconstruction).**
Suppose `V` and `V'` are polarized weight-2 rational Hodge structures with Picard rank `1`, with chosen nonzero algebraic classes `ω ∈ Alg(V)` and `ω' ∈ Alg(V')`, and suppose there is an isometry of polarized Hodge structures
\[
f:\mathrm{Tr}(V)\xrightarrow{\sim}\mathrm{Tr}(V')
\]
together with equality of algebraic-line norms
\[
Q(\omega,\omega)=Q'(\omega',\omega').
\]
Then there exists an isomorphism of polarized rational Hodge structures
\[
F:V\xrightarrow{\sim}V'
\]
sending `ω` to `ω'` and restricting to `f` on the transcendental part.

This is a formal analog of the idea that in Picard rank one, the entire polarized Hodge structure is determined by the transcendental lattice plus the square of the polarization generator.

### Lean 4 signature target

```lean
def TranscendentalLattice (HS : PolarizedWeightTwoHodgeStructure) : Submodule ℚ HS.V :=
  (HodgeClasses HS).orthogonal HS.Q

theorem alg_plus_transcendental_isCompl
  (HS : PolarizedWeightTwoHodgeStructure)
  (hnondeg : Nondegenerate (HS.Q.restrict (HodgeClasses HS))) :
  IsCompl (HodgeClasses HS) (TranscendentalLattice HS) := by
```

Reconstruction theorem:

```lean
theorem rank_one_reconstruction_from_transcendental
  (HS HS' : PolarizedWeightTwoHodgeStructure)
  (hρ : Module.finrank ℚ (HodgeClasses HS) = 1)
  (hρ' : Module.finrank ℚ (HodgeClasses HS') = 1)
  (ω : HS.V) (ω' : HS'.V)
  (hω : ω ∈ HodgeClasses HS) (hω' : ω' ∈ HodgeClasses HS')
  (hω0 : ω ≠ 0) (hω'0 : ω' ≠ 0)
  (f : TranscendentalLattice HS ≃ₗᵢ[ℚ] TranscendentalLattice HS' )
  (hnorm : HS.Q ω ω = HS'.Q ω' ω') :
  ∃ F : HS.V ≃ₗᵢ[ℚ] HS'.V, F ω = ω' := by
```

You may first prove a weaker linear-isometry statement before adding preservation of Hodge decomposition.

### Proof strategies

#### Strategy A: Orthogonal direct sum gluing
1. Use Picard rank 1 to identify `Alg(V) = ℚ·ω` and `Alg(V') = ℚ·ω'`.
2. Use nondegeneracy to split
   \[
   V \cong \mathbb{Q}\omega \oplus \mathrm{Tr}(V), \quad
   V' \cong \mathbb{Q}\omega' \oplus \mathrm{Tr}(V').
   \]
3. Glue the line isometry sending `ω ↦ ω'` with the given transcendental isometry `f`.

**Why this is most promising:** it is algebraically robust and avoids subtle Torelli-type arguments.

#### Strategy B: Matrix normal form
1. Choose orthogonal bases adapted to algebraic/transcendental decomposition.
2. Express `Q` and `Q'` as block matrices.
3. Build the global isometry blockwise.

**Why useful:** may be easier if Mathlib support for orthogonal complements is stronger than for abstract gluing.

#### Strategy C: Category-theoretic packaging
1. Define a category of polarized rank-one weight-2 Hodge structures.
2. Show the functor sending `HS` to `(Tr(HS), q(ω))` is faithful or essentially injective.
3. Derive C2 as a reconstruction theorem.

**Why revolutionary:** this elevates the result from a one-off theorem to a reusable formal architecture for moduli problems.

---

## Cross-domain connections you should exploit

1. **K3 surfaces / Torelli philosophy**  
   Picard rank 1 is the minimal nontrivial algebraic regime for K3-type Hodge structures. A formal rank-one reconstruction theorem is a linear-algebraic shadow of global Torelli ideas.

2. **Abelian varieties and representation theory**  
   The decomposition
   \[
   \Lambda^2(W_1\oplus W_2)
   \]
   is Schur-functor territory. Formalizing it cleanly opens a path to machine-checked Hodge-theoretic statements for products of elliptic curves and abelian varieties.

3. **Lattice theory and quadratic forms**  
   The transcendental complement theorem is really about orthogonal decomposition of rational quadratic spaces with Hodge constraints. This links formal Hodge theory to Witt theory, discriminants, and arithmetic lattices.

4. **Type theory / certified moduli**  
   Once the decomposition and reconstruction data are formalized, one can envision certified classification of low-rank Hodge structures as actual Lean objects, not just pen-and-paper statements.

5. **Physics-adjacent geometry**  
   Weight-2 polarized Hodge structures govern period domains that appear in mirror symmetry and string compactifications. Rank-one algebraic sectors correspond to “one Kähler modulus” models; your formal theorem would make that slogan mathematically checkable.

---

## Application keywords

**Hodge conjecture, Picard rank one, polarized Hodge structures, Hodge–Riemann bilinear relations, transcendental lattice, orthogonal decomposition, K3 surfaces, Torelli theorem, abelian varieties, wedge square decomposition, tensor Hodge classes, quadratic forms, period domains, mirror symmetry, certified algebraic geometry, Lean 4, Mathlib**

---

## Concrete deliverables

1. Define `IsHodge11`, `HodgeClasses`, and `PicardRank` for a weight-2 rational Hodge structure.
2. Prove `HodgeClasses` is a `Submodule ℚ V`.
3. Prove **Theorem A1** and **A2** in the precise rank-one formulation above.
4. Formalize the linear equivalence
   \[
   \Lambda^2(U\oplus V)\cong \Lambda^2U\oplus(U\otimes V)\oplus\Lambda^2V
   \]
   and use it to prove **Theorem B1**.
5. Introduce a clean predicate `NoCommonHodgeFactor` and prove a vanishing theorem like **B2**.
6. Define the transcendental lattice as an orthogonal complement and prove **C1**.
7. Push as far as possible toward **C2**, even if first in a weakened “linear isometry ignoring Hodge decomposition” form.

---

## Suggested file/theorem organization

- `FormalHodge/Basic.lean`
  - `IsHodge11`
  - `HodgeClasses`
  - `PicardRank`
- `FormalHodge/RankOne.lean`
  - `hodgeClasses_rank_one_unique`
  - `polarization_class_spans_hodgeClasses`
- `FormalHodge/Exterior.lean`
  - `wedge_two_directSum_decomposition`
  - `hodgeClasses_wedge_directSum_decompose`
  - `hodgeClasses_tensor_vanish_of_noCommonFactor`
- `FormalHodge/Transcendental.lean`
  - `TranscendentalLattice`
  - `alg_plus_transcendental_isCompl`
  - `rank_one_reconstruction_from_transcendental`

---

## What would make this a breakthrough

A successful formalization here would not be “yet another definition of Hodge structure.” It would create the first reusable Lean infrastructure for **rigidity, decomposition, and reconstruction** in rational Hodge theory. That opens:

- machine-checked special cases of the Hodge conjecture,
- certified linear-algebraic models of Torelli phenomena,
- formal Schur-functor Hodge computations for abelian varieties,
- eventual interfaces with motives, periods, and lattice-polarized moduli.

This is the point where formalized algebraic geometry stops being archival and starts becoming **experimental theorem architecture**.

---

## Mandatory next step

Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 falsifiable scientific hypotheses** emerging from this work. Each must include:
- a precise conjectural statement,
- the exact Lean definitions/theorems needed to test it,
- what would count as a refutation,
- and why the result would matter.

At least one hypothesis must concern:
1. rank-`>1` algebraic lattices,
2. tensor/exterior Hodge-class generation,
3. a Torelli-style reconstruction principle beyond Picard rank `1`.

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

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

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

Research domain: Speculative
Research mode: prove
