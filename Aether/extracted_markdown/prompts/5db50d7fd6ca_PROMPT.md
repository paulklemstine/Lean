## Assignment: Formal Hodge Theory Beyond Rank One — Algebraic/Transcendental Decomposition as a Formal Engine

Prove genuinely new theorems that turn the current rank-one formalization into a reusable classification machine for polarized rational Hodge structures. Build directly on the catalog’s existing weight-one/weight-two Hodge infrastructure, orthogonality lemmas, sesquilinear/bilinear form API, finite-dimensional linear algebra, and any previously certified reconstruction statements. Minimize `sorry` by targeting statements whose proof skeleton can be assembled from Mathlib’s `Submodule`, `LinearMap`, `BilinForm`, `FiniteDimensional`, and orthogonal-complement libraries.

The central opportunity is not “more examples.” It is to formalize the algebraic mechanism underlying Torelli-type reconstruction: **Hodge classes as a nondegenerate algebraic core, transcendental complement as a canonical orthogonal shadow, and tensor Hodge classes as morphism spaces.** If completed cleanly, this opens a formal bridge from Hodge theory to lattice theory, representation theory, and eventually motives.

Application keywords: `Torelli`, `K3 lattice`, `orthogonal decomposition`, `transcendental lattice`, `tensor-Hom adjunction`, `motivic linear algebra`, `period domains`, `lattice embeddings`, `categorical Hodge theory`, `formal algebraic geometry`

---

# Target Theorem 1: Orthogonal decomposition for higher Picard rank

The rank-`k` statement should be sharpened so that it is mathematically correct and formally robust. The real breakthrough is not merely the existence of a submodule equal to `HodgeClasses`; it is the **canonical orthogonal splitting under a nondegeneracy hypothesis on the restricted polarization**.

## Precise theorem statement

Let `V` be a finite-dimensional `ℚ`-vector space equipped with polarized weight-2 Hodge data `HS`, and let `A := HodgeClasses HS.toWeightTwoHodgeData`. Assume the restriction of the polarization `Q` to `A` is nondegenerate. Then:

1. `A ⊓ Aᗮ = ⊥`,
2. `A ⊔ Aᗮ = ⊤`,
3. every `v : V` decomposes uniquely as `v = a + t` with `a ∈ A`, `t ∈ Aᗮ`.

This is the linear-algebraic heart of the algebraic/transcendental decomposition.

### Suggested Lean 4 signature
```lean
theorem hodgeClasses_orthogonal_direct_sum
  {V : Type*} [AddCommGroup V] [Module ℚ V] [FiniteDimensional ℚ V]
  (HS : PolarizedWeightTwoHodgeData V)
  let A : Submodule ℚ V := HodgeClasses HS.toWeightTwoHodgeData
  (hA_nd :
    BilinForm.Nondegenerate
      ((HS.Q).restrict (A := A) (B := A))) :
  IsCompl A (A.orthogonal (HS.Q)) := by
  sorry
```

If your API uses a different orthogonal-complement definition or restricted-form notation, adapt the signature, but keep the theorem mathematically exact: **nondegeneracy of `Q|A` implies `A` is an orthogonal direct summand**.

### Stronger corollary
```lean
theorem exists_unique_hodge_transcendental_decomposition
  {V : Type*} [AddCommGroup V] [Module ℚ V] [FiniteDimensional ℚ V]
  (HS : PolarizedWeightTwoHodgeData V)
  let A : Submodule ℚ V := HodgeClasses HS.toWeightTwoHodgeData
  (hA_nd :
    BilinForm.Nondegenerate
      ((HS.Q).restrict (A := A) (B := A))) :
  ∀ v : V, ∃! p : A × (A.orthogonal HS.Q), v = p.1.1 + p.2.1 := by
  sorry
```

## Why this is a breakthrough

This is the first point where formal Hodge theory stops being bookkeeping and becomes **structural decomposition theory**. Once this theorem exists, every later Torelli-style statement can factor through a certified algebraic/transcendental split. It also creates the formal substrate for:
- transcendental lattice invariants,
- comparison of Hodge isometries via restriction to summands,
- lattice embedding problems into the K3 lattice,
- period-map rigidity statements.

This is the reusable theorem, not a one-off lemma.

## Proof strategy options

### Strategy A: Pure orthogonal-complement linear algebra
1. Prove `A ⊓ Aᗮ = ⊥` from nondegeneracy of the restricted form: if `x ∈ A ∩ Aᗮ`, then `Q x y = 0` for all `y ∈ A`, hence `x = 0`.
2. Use finite-dimensional dimension formulas to show `finrank A + finrank Aᗮ = finrank V`.
3. Conclude `IsCompl A Aᗮ`.

**Why promising:** closest to Mathlib’s existing APIs; avoids basis-level constructions.

### Strategy B: Construct projection by solving orthogonality equations
1. For each `v`, define a functional on `A` by `a ↦ Q(v,a)`.
2. Use nondegeneracy of `Q|A` to identify `A ≃ A*` and solve for unique `a ∈ A` with `Q(v-a, b)=0` for all `b ∈ A`.
3. Set `t = v-a`; prove `t ∈ Aᗮ` and uniqueness.

**Why promising:** gives the decomposition theorem directly and may produce a computational projection map useful later.

### Strategy C: Matrix/basis reduction
1. Choose a basis adapted to `A`.
2. Represent `Q` by a block matrix.
3. Use invertibility of the `A × A` block to eliminate mixed terms and derive a direct-sum decomposition.

**Why less promising initially:** formally heavier in Lean; useful only if the orthogonal API is missing.

**Recommendation:** Start with Strategy A. If the library’s dimension lemmas are awkward, pivot to Strategy B, which often yields cleaner witness construction.

## Cross-domain connections

- **Lattice theory:** this is the rational precursor to primitive lattice embeddings and discriminant-form control.
- **Differential geometry:** the algebraic/transcendental split is the linear skeleton of period-domain coordinates.
- **Representation theory:** orthogonal direct summands are exactly what one needs to compare invariant subspaces under Mumford–Tate actions.
- **Physics:** the decomposition mirrors charge-lattice splitting into algebraic and transcendental sectors in K3 compactifications.

---

# Target Theorem 2: Tensor Hodge classes are exactly Hodge morphisms

The conjecture should be promoted from a heuristic slogan to a formal tensor-Hom equivalence. This is much bigger than a technical lemma: it is the beginning of a **formal Tannakian interface** for Hodge structures.

## Precise theorem statement

For weight-1 rational Hodge structures `W₁`, `W₂`, the `(0,0)`-classes in the induced weight-2 Hodge structure on `W₁ᵛ ⊗ W₂` are naturally isomorphic to morphisms of Hodge structures `W₁ → W₂`. Equivalently,
\[
\operatorname{Hdg}(W_1^\vee \otimes W_2) \cong \operatorname{Hom}_{HS}(W_1,W_2).
\]

If your existing formalization places Hodge classes in `W₁ ⊗ W₂`, then you likely need a dualization correction. The mathematically canonical statement uses `W₁ᵛ ⊗ W₂`.

### Suggested Lean 4 definitions
```lean
def HodgeStructureHom
  (W₁ W₂ : WeightOneHodgeData) :
  Submodule ℚ (W₁.V →ₗ[ℚ] W₂.V) := by
  sorry
```

Interpret this as linear maps preserving the Hodge decomposition after complexification.

### Suggested main theorem
```lean
theorem hodgeClasses_dualTensor_equiv_hodgeHom
  (W₁ W₂ : WeightOneHodgeData) :
  HodgeClasses (inducedWeightZeroOnDualTensor W₁ W₂) ≃ₗ[ℚ]
    HodgeStructureHom W₁ W₂ := by
  sorry
```

If your convention shifts weights so that `W₁ᵛ ⊗ W₂` is realized as weight `2`, then state the codomain accordingly, but the conceptual content must be: **tensor Hodge classes = Hodge morphisms**.

## Why this is a breakthrough

This theorem is the portal from isolated Hodge calculations to **categorical Hodge theory**. Once formalized, it enables:
- certified endomorphism algebras of Hodge structures,
- formal CM/real multiplication detection,
- a path toward Mumford–Tate groups via tensor invariants,
- eventually, a machine-readable Tannakian formalization of pure Hodge structures.

This is not an incremental generalization. It changes the language of the subject inside Lean.

## Proof strategy options

### Strategy A: Decompose by Hodge types after complexification
1. Expand `W₁,ℂ = H^{1,0}_1 ⊕ H^{0,1}_1` and similarly for `W₂`.
2. Compute the Hodge decomposition of `W₁ᵛ ⊗ W₂`; identify the `(0,0)` summand as
   \[
   \operatorname{Hom}(H^{1,0}_1,H^{1,0}_2)\oplus \operatorname{Hom}(H^{0,1}_1,H^{0,1}_2).
   \]
3. Show these are exactly the complexified maps preserving Hodge type, then descend to `ℚ`.

**Why promising:** conceptually clean and directly aligned with Hodge theory.

### Strategy B: Tensor-Hom adjunction first, Hodge condition second
1. Use linear algebra to identify `W₁ᵛ ⊗ W₂ ≃ Hom(W₁,W₂)`.
2. Transport the induced Hodge structure across this equivalence.
3. Prove that `(0,0)` vectors are exactly Hodge-preserving maps.

**Why promising:** more modular; if you already have tensor/dual infrastructure in Lean, this may be the shortest route.

### Strategy C: Characterize by universal property
1. Define `HodgeStructureHom` as maps preserving filtrations or bigrading.
2. Show the representing object for this functor is the `(0,0)`-part of `W₁ᵛ ⊗ W₂`.
3. Deduce equivalence by extensionality.

**Why ambitious:** best long-term architecture for categorical reuse, but requires more API investment.

**Recommendation:** Strategy B is likely optimal for formalization speed; Strategy A should be used to prove the key type-computation lemma if the transport argument needs explicit bigrading control.

## Cross-domain connections

- **Category theory:** this is the tensor-Hom adjunction internalized in a Hodge category.
- **Arithmetic geometry:** endomorphism Hodge classes detect CM and extra symmetries of abelian varieties.
- **Motivic theory:** Hodge classes as tensor invariants is exactly the language needed for motivic Galois heuristics.
- **Quantum information:** invariant tensors corresponding to structure-preserving channels is a striking analogy worth documenting.

---

# Target Theorem 3: Endomorphism algebra of a simple weight-one Hodge structure

Once Theorem 2 is in place, do not stop. Push immediately to a nontrivial corollary that exposes arithmetic structure.

## Precise theorem statement

For a simple weight-1 rational Hodge structure `W`, the Hodge endomorphisms form a division algebra over `ℚ`:
\[
\operatorname{End}_{HS}(W)
\]
has no nontrivial zero divisors in the finite-dimensional semisimple sense; equivalently every nonzero Hodge endomorphism is injective, hence bijective by finite dimensionality.

### Suggested Lean 4 signature
```lean
theorem nonzero_hodge_endomorphism_bijective
  (W : WeightOneHodgeData)
  (h_simple : IsSimpleHodgeStructure W)
  (f : HodgeStructureHom W W)
  (hf : f ≠ 0) :
  Function.Bijective (f : W.V → W.V) := by
  sorry
```

A more algebraic formulation via `LinearEquiv` is even better if your `HodgeStructureHom` is packaged as a subspace of endomorphisms.

## Why this is a breakthrough

This turns the formalization from static decomposition theory into **symmetry detection**. It begins the road to formal Albert classification phenomena and CM detection. Even in a modest form, it says Lean can certify that extra Hodge classes imply extra endomorphisms, and simplicity forces those endomorphisms to be invertible.

## Proof strategy options

### Strategy A: Kernel/image as Hodge substructures
1. Show `ker f` and `range f` are Hodge substructures.
2. Use simplicity to deduce `ker f = ⊥` and `range f = ⊤`.
3. Conclude injective and surjective.

### Strategy B: Use Theorem 2 to reinterpret endomorphisms as Hodge classes
1. Transport `f` to a tensor Hodge class in `Wᵛ ⊗ W`.
2. Show nontriviality excludes vanishing on a nontrivial Hodge summand.
3. Use simplicity to force invertibility.

### Strategy C: Schur-style categorical argument
1. Formalize the category of weight-1 Hodge structures.
2. Invoke a Schur lemma analogue once simplicity is available.

**Recommendation:** Strategy A is the right first proof; Strategy C is the long-term architecture.

## Cross-domain connections

- **Representation theory:** this is Schur’s lemma in Hodge clothing.
- **Abelian varieties:** simple Hodge structures correspond to simple isogeny factors.
- **Noncommutative algebra:** opens the door to division-algebra-valued Hodge symmetries.

---

# Build on catalog theorems explicitly

You should search the catalog for any theorem already proving one or more of the following and use them as immediate inputs rather than reproving from scratch:

- rank-one reconstruction/classification for polarized weight-2 Hodge structures,
- existing `HodgeClasses` closure under submodule operations,
- orthogonality/nondegeneracy lemmas for restricted bilinear forms,
- finite-dimensional direct-sum criteria (`Submodule.IsCompl`, dimension formulas),
- dual/tensor complexification equivalences,
- any theorem identifying kernels/ranges of Hodge morphisms as Hodge substructures.

In the proof scripts, make the dependency graph explicit:
1. identify the exact catalog theorem names,
2. state how each theorem eliminates a proof obligation,
3. isolate any missing bridge lemmas into small standalone results.

If the catalog already contains a rank-one decomposition theorem, the correct move is to generalize the **mechanism** (nondegenerate restriction implies orthogonal splitting), not to iterate rank by rank.

---

# Implementation architecture in Lean

Organize the work as follows:

1. **Restricted-form API**
   - prove helper lemmas about `BilinForm.restrict`,
   - characterize `A ⊓ Aᗮ = ⊥` from restricted nondegeneracy.

2. **Orthogonal decomposition layer**
   - dimension lemma for `A` and `Aᗮ`,
   - direct-sum theorem,
   - unique decomposition corollary.

3. **Tensor-Hom layer**
   - dual/tensor induced Hodge structure definitions,
   - equivalence with linear maps,
   - Hodge-condition transport lemma,
   - main equivalence theorem.

4. **Symmetry layer**
   - kernels/ranges of Hodge morphisms are Hodge substructures,
   - simple-object corollaries,
   - invertibility of nonzero endomorphisms.

This layering will make future period-domain and Mumford–Tate formalization dramatically easier.

---

# Failure modes to watch for

- The original rank-`k` conjecture is false without nondegeneracy of `Q|Hdg(V)`. Do not formalize a false theorem. If needed, first formalize a counterexample schema with an isotropic Hodge-class vector.
- The tensor-Hodge-class statement likely requires `W₁ᵛ ⊗ W₂`, not `W₁ ⊗ W₂`, unless conventions have already absorbed the dual.
- Be careful whether your notion of Hodge classes means `(p,p)` in weight `2p` or specifically `(0,0)` after Tate normalization. State conventions explicitly in code comments.

---

# Deliverables

1. Formalized theorem `hodgeClasses_orthogonal_direct_sum` or equivalent.
2. Formalized theorem `hodgeClasses_dualTensor_equiv_hodgeHom` or equivalent.
3. At least one nontrivial corollary on Hodge endomorphisms of simple weight-one structures.
4. Minimal, reusable bridge lemmas replacing broad `sorry`s with targeted API extensions.
5. A structured `FUTURE_DIRECTIONS.md` containing **3–5 falsifiable scientific hypotheses**, each with:
   - a precise conjecture,
   - what theorem/formalization would test it,
   - what would count as refutation,
   - why it matters.

---

# Required FUTURE_DIRECTIONS hypotheses

Your `FUTURE_DIRECTIONS.md` must include testable hypotheses at the next frontier, such as:

1. **Primitive embedding hypothesis**
   - Conjecture that a nondegenerate Hodge lattice of appropriate signature admits formal primitive embedding into the K3 lattice under explicit discriminant constraints.
   - Refutation: construct a discriminant-form obstruction formally.

2. **Semisimplicity hypothesis for polarizable rational Hodge structures**
   - Conjecture every Hodge substructure admits a Hodge-theoretic complement.
   - Refutation: identify the exact missing polarization/nondegeneracy condition if formalization fails.

3. **Mumford–Tate via tensor invariants**
   - Conjecture the stabilizer of all tensor Hodge classes defines a formal algebraic group recovering endomorphism symmetries in low-rank cases.
   - Refutation: failure of finite-generation or definability in the current formal framework.

4. **Kuga–Satake precursor**
   - Conjecture that the even Clifford algebra of a polarized weight-2 Hodge structure carries a canonically induced weight-1 Hodge structure under suitable signature assumptions.
   - Refutation: failure to define the Hodge decomposition compatibly with multiplication.

5. **Derived Torelli linear skeleton**
   - Conjecture that an isometry preserving the Hodge-class lattice and transcendental lattice separately reconstructs the full polarized Hodge structure.
   - Refutation: produce a mismatch in gluing data despite summandwise isometries.

These are not optional. They are how this project becomes a research program rather than a sequence of lemmas.

---

# Final call

Do not merely extend rank-one Hodge theory. Formalize the algebraic engine that makes Torelli, tensor invariants, and symmetry detection possible. The right result here is a theorem that future formalizations can cite as infrastructure. If you succeed, Lean will no longer just “know examples” of Hodge theory — it will know how Hodge theory organizes structure.

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
