## Assignment: Tropical Satake Isomorphism for GL_n

Mode: **prove**

You are not being asked for a cosmetic generalization of `GL_2`. You are being asked to formalize a new bridge between tropical representation theory, min-plus convolution algebras, and Coxeter/Weyl combinatorics. The target is a genuine structural theorem: a **tropical Satake equivalence statement for `GL_n`**, stated with enough precision that Lean can carry the burden.

The breakthrough is this: if you can show that the spherical min-plus Hecke algebra for `GL_n` is canonically identified with the semiring of `S_n`-invariant tropical polynomials on the coweight lattice, then you have created a formalized tropical shadow of geometric Satake. That opens a field: tropical harmonic analysis, tropical automorphic computation, and algorithmic representation theory in idempotent semirings.

---

### Core Theorem Target

Work with the coweight lattice of `GL_n`, modeled concretely as `Fin n → ℤ`, and Weyl group `W = Equiv.Perm (Fin n)` acting by permutation of coordinates. Define:

- **dominant coweights** as weakly decreasing functions `μ : Fin n → ℤ`
- **tropical monomials** as affine linear forms on `Fin n → ℤ`
- **tropical polynomials** as finite minima of such affine linear forms
- **W-invariant tropical polynomials** as those fixed under coordinate permutation
- **min-plus Hecke operators** as finitely supported `W`-biinvariant kernels on the lattice, with convolution defined by tropical addition/min

You should aim to prove a theorem of the following shape.

### Precise Theorem Statement

For each `n ≥ 1`, the tropical Satake transform induces a bijection between finitely supported spherical min-plus Hecke operators for `GL_n` and `S_n`-invariant tropical polynomials on the coweight lattice.

A mathematically sharp formulation:

> **Theorem (Tropical Satake for `GL_n`)**  
> Let `n : ℕ` with `0 < n`. Let `Λ = Fin n → ℤ`, and let `W = Equiv.Perm (Fin n)` act on `Λ` by permutation.  
> Let `TropHecke n` denote the semiring of finitely supported `W`-biinvariant min-plus kernels on `Λ`, with tropical convolution.  
> Let `TropPolyInv n` denote the semiring of finitely generated `W`-invariant tropical polynomials `Λ → ℤ`.  
> Then there exists a map
> `tropicalSatake : TropHecke n →+* TropPolyInv n`
> which is bijective. Equivalently, it is a semiring isomorphism
> `TropHecke n ≃+* TropPolyInv n`.

This should not remain a slogan. Force it into Lean with concrete surrogate definitions.

### Lean 4 Type Signature Target

You may need to define intermediate structures first, but the final theorem should look as close as possible to:

```lean
def Coweight (n : ℕ) := Fin n → ℤ

def WeylAction {n : ℕ} (σ : Equiv.Perm (Fin n)) (μ : Coweight n) : Coweight n :=
  fun i => μ (σ⁻¹ i)

def IsDominant {n : ℕ} (μ : Coweight n) : Prop :=
  ∀ i j : Fin n, i ≤ j → μ i ≥ μ j

def IsWInvariant {n : ℕ} (f : Coweight n → ℤ) : Prop :=
  ∀ σ : Equiv.Perm (Fin n), ∀ μ : Coweight n, f (WeylAction σ μ) = f μ

structure TropPoly (n : ℕ) where
  toFun : Coweight n → ℤ
  isTropical : Prop

structure TropPolyInv (n : ℕ) extends TropPoly n where
  invariant' : IsWInvariant toFun

structure TropHecke (n : ℕ) where
  toFun : Coweight n → Coweight n → WithTop ℤ
  biinvariant' : Prop
  finite_support' : Prop

noncomputable def tropicalSatake (n : ℕ) : TropHecke n → TropPolyInv n := ...

theorem tropicalSatake_bijective (n : ℕ) (hn : 0 < n) :
    Function.Bijective (tropicalSatake n) := ...

noncomputable def tropicalSatakeEquiv (n : ℕ) (hn : 0 < n) :
    TropHecke n ≃ TropPolyInv n := ...
```

If semiring structure is easier to define on a more concrete object, prefer:

```lean
noncomputable def tropicalSatakeAlgEquiv (n : ℕ) (hn : 0 < n) :
    TropHecke n ≃+* TropPolyInv n := ...
```

If full `≃+*` is too ambitious initially, prove the staged version:

1. `tropicalSatake_invariant`
2. `tropicalSatake_injective`
3. `tropicalSatake_surjective`
4. package as equivalence

---

### Minimum Viable Formalization Path

Do **not** start by trying to formalize all of geometric Satake. Build a concrete tropical combinatorial model and prove the isomorphism there. The point is to capture the structural essence.

A viable finite/combinatorial surrogate:

- Represent a tropical polynomial by a `Finset` of coefficient/exponent pairs
- Represent Hecke operators by finitely supported functions on dominant coweights
- Define the Satake transform by taking the tropical support function:
  `H ↦ (μ ↦ inf_{λ in supp(H)} (c_λ + pairing λ μ))`
- Show `W`-invariance when `H` is spherical
- Show every `W`-invariant tropical polynomial is the lower envelope of orbit-symmetrized affine forms
- Reconstruct a Hecke operator from the finite set of affine pieces

This is the formal heart of the theorem.

---

### Existing Verified Theorems to Exploit

You are not starting from zero. Build on these precisely:

1. `tropical_plus_distributes_over_min`
   - in `Tropical/CA/MinPlusExpr.lean`
   - in `Tropical/FormulaDefinability.lean`
   - in `Tropical/TropicalTypeTheory.lean`

   Use these to prove that tropical convolution respects lower-envelope structure and that the Satake transform preserves semiring operations. These are the algebraic engine behind “convolution becomes tropical multiplication.”

2. `satake_extend_invariant`
   - file: `Tropical/Langlands/TropicalSatakeGL3Algebra.lean`

   This is your strongest bridge theorem. Reverse-engineer its exact hypotheses and conclusion. Most likely it already proves a `GL_3` invariance extension under Weyl symmetry or under coordinate permutation. Generalize its proof pattern from arity 3 to arbitrary `n`, replacing hard-coded coordinates by `Fin n` indexing and permutation actions.

3. `tropical_lower_bound_transfer_from_theoryAdj`
   - file: `Tropical/AdjunctionGalois.lean`

   This suggests a Galois/adjunction interpretation of tropical lower bounds. Use it to prove surjectivity: every invariant tropical polynomial arises as the lower adjoint/image of some finitely supported Hecke datum. This is likely the conceptual route that avoids painful direct combinatorics.

---

### Proof Architecture: Three Viable Strategies

#### Strategy A: Orbit-Symmetrized Support Function Model
Most promising for Lean.

**Step 1.** Define the tropical Satake transform from finitely supported dominant-weight data:
```lean
H : Finset (Coweight n × ℤ)
```
to the function
```lean
μ ↦ (H.inf' ?h (fun p => p.2 + dot p.1 μ))
```
or an equivalent `Finset.min`/`WithTop` formulation.

**Step 2.** Prove `W`-invariance by showing orbit symmetrization does not change the lower envelope:
- if support is closed under `S_n`
- or if you replace each affine form by its orbit-minimum

**Step 3.** Prove surjectivity by expressing any finitely generated `W`-invariant tropical polynomial as the lower envelope of finitely many orbit-averaged/orbit-symmetrized affine forms. Then package the finite generating set as a Hecke operator.

Why this is promising: it is finite, constructive, and aligns with Lean’s strengths (`Finset`, permutation actions, explicit witnesses).

---

#### Strategy B: Semiring Presentation by Generators and Relations
Most conceptually elegant.

**Step 1.** Define generators of the spherical tropical Hecke semiring indexed by dominant coweights:
```lean
T_λ
```
and prove multiplication corresponds to tropical Minkowski addition / min-plus convolution.

**Step 2.** Define corresponding generators in invariant tropical polynomial semiring:
```lean
P_λ := min_{w ∈ W} ⟨w • λ, -⟩ + c_λ
```
and prove the same relations hold.

**Step 3.** Use a universal property / presented-semiring argument to construct a semiring morphism and prove it is inverse on generators.

Why this matters: if successful, this is closer to the true Satake philosophy. It would make later extension to other root systems (`B_n`, `C_n`, `G_2`) much easier.

Risk: Mathlib support for semiring presentations may be thinner than for direct finite constructions.

---

#### Strategy C: Galois-Adjunction / Tropical Convexity Route
Most revolutionary if it lands.

**Step 1.** Interpret tropical Satake as a Legendre–Fenchel-type transform in the min-plus semiring:
Hecke support data ↔ convex `W`-invariant tropical functions.

**Step 2.** Use `tropical_lower_bound_transfer_from_theoryAdj` to prove that the transform is order-reflecting and order-surjective onto invariant lower envelopes.

**Step 3.** Characterize the image as exactly the finitely generated `W`-invariant tropical convex functions, then identify these with tropical polynomials.

Why this is scientifically powerful: it connects tropical Langlands to idempotent convex analysis and categorical adjunctions. This is the path that could create an entirely new formalized subject.

Risk: requires more definitions and may be harder to close without strategic simplification.

---

### Recommended Execution Order

1. **Mine `TropicalSatakeGL3Algebra.lean`** for the exact shape of `satake_extend_invariant`.
2. Generalize all hard-coded triples `(x,y,z)` to `Fin n → ℤ`.
3. Define a minimal `TropPolyInv n` using finite lower envelopes of affine forms.
4. Prove:
   - `tropicalSatake_invariant`
   - `tropicalSatake_preserves_min`
   - `tropicalSatake_preserves_tropical_plus`
5. Prove injectivity by support reconstruction from affine pieces.
6. Prove surjectivity by orbit-symmetrized finite generation.
7. Upgrade to `≃` or `≃+*`.

---

### Intermediate Theorems You Should Actually Prove

These are not filler; they are the scaffolding of the main theorem.

```lean
theorem tropicalSatake_invariant
    (n : ℕ) (H : TropHecke n) :
    IsWInvariant ((tropicalSatake n H).toFun) := ...

theorem tropicalSatake_preserves_min
    (n : ℕ) (H₁ H₂ : TropHecke n) :
    tropicalSatake n (infHecke H₁ H₂) =
      tropPolyInf (tropicalSatake n H₁) (tropicalSatake n H₂) := ...

theorem tropicalSatake_preserves_convolution
    (n : ℕ) (H₁ H₂ : TropHecke n) :
    tropicalSatake n (convolve H₁ H₂) =
      tropPolyAdd (tropicalSatake n H₁) (tropicalSatake n H₂) := ...

theorem tropicalSatake_injective
    (n : ℕ) (hn : 0 < n) :
    Function.Injective (tropicalSatake n) := ...

theorem tropicalSatake_surjective
    (n : ℕ) (hn : 0 < n) :
    Function.Surjective (tropicalSatake n) := ...
```

If you need a weaker but tractable first target, prove the theorem for `GL_3` in a new uniform formalism, then generalize by induction on `n` or by replacing explicit coordinate permutations with arbitrary `Equiv.Perm (Fin n)`.

---

### Cross-Domain Connections You Must Exploit

This project becomes paradigm-shifting only if you expose its hidden neighbors.

#### 1. Representation Theory × Tropical Convexity
The image of the Satake transform should be understood as a semiring of tropical support functions. This is the idempotent analogue of highest-weight character theory. If formalized, this opens “tropical Tannakian” directions.

#### 2. Hecke Algebras × Combinatorial Optimization
Min-plus convolution is shortest-path / dynamic programming algebra. Your theorem says spherical Hecke operators for `GL_n` admit an optimization-theoretic normal form. This could make tropical Satake computational.

#### 3. Weyl Invariants × Symmetric Tropical Geometry
`S_n`-invariant tropical polynomials are tropical analogues of symmetric functions. This suggests a future tropical Schur theory, tropical Hall–Littlewood theory, and algorithmic Kostka-type invariants.

#### 4. Galois Adjunctions × Idempotent Analysis
Use the adjunction theorem as a conceptual backbone: Satake may be a left/right adjoint between kernel data and invariant support functions. If you can make this precise, you create a categorical formulation of tropical harmonic analysis.

#### 5. Formal Methods × Langlands Prototyping
A Lean-certified tropical Satake theorem is not merely formalized math; it is a testbed for formal Langlands correspondences in simplified semiring settings. This is a serious methodological contribution.

---

### What Would Count as a Breakthrough

Any one of the following would already be substantial:

- A fully formalized `GL_n` tropical Satake bijection for a concrete finite-support model
- A semiring isomorphism `TropHecke n ≃+* TropPolyInv n`
- A proof that `W`-invariant tropical polynomials admit a canonical basis indexed by dominant coweights
- A categorical/adjoint characterization of tropical Satake
- A computational extraction procedure turning tropical polynomials into Hecke data and back

The strongest version would certify that tropical Satake is not just a map, but the **correct algebraic dictionary** between two worlds.

---

### Lean Engineering Directives

- Use concrete types first: `Fin n → ℤ`, `Finset`, `WithTop ℤ`.
- Avoid quotient-heavy constructions until the finite-support model is stable.
- Prefer explicit `Equiv.Perm (Fin n)` actions to abstract Weyl group interfaces.
- If minima over finite supports are awkward in `ℤ`, switch codomain temporarily to `WithTop ℤ` and only later prove finiteness removes `⊤`.
- If `TropHecke` semiring structure is too heavy, define the transform on raw finitely supported data first and package algebra later.
- Search aggressively for Mathlib lemmas on:
  - `Finsupp`
  - `Finset.inf'`
  - permutation actions on function spaces
  - semiring structures on function types
  - `MulSemiringAction` / `DistribMulAction` if relevant

---

### Concrete File Targets

You were not given exact files for this theorem, so create a coherent module sequence, e.g.:

- `Tropical/Langlands/TropicalSatakeGLnDefs.lean`
- `Tropical/Langlands/TropicalSatakeGLnInvariant.lean`
- `Tropical/Langlands/TropicalSatakeGLnSurjective.lean`
- `Tropical/Langlands/TropicalSatakeGLn.lean`

Also inspect and import:
- `Tropical/Langlands/TropicalSatakeGL3Algebra.lean`
- `Tropical/CA/MinPlusExpr.lean`
- `Tropical/AdjunctionGalois.lean`

---

### Fallback Theorem Ladder if Full Bijectivity Stalls

If the full theorem resists closure, do not retreat into trivialities. Prove one of these instead:

1. **Invariant image theorem**
   ```lean
   theorem tropicalSatake_mem_WInvariant
       (n : ℕ) (H : TropHecke n) :
       IsWInvariant ((tropicalSatake n H).toFun)
   ```
2. **Finite generation theorem**
   Every spherical tropical Hecke operator maps to a finitely generated invariant tropical polynomial.
3. **Reconstruction theorem**
   Every finitely generated `S_n`-invariant tropical polynomial admits a Hecke preimage.
4. **Basis theorem**
   Orbit-symmetrized tropical monomials indexed by dominant coweights generate all invariant tropical polynomials.

Any of these would be mathematically meaningful and would de-risk the final equivalence.

---

### Application Keywords

tropical Satake, `GL_n`, spherical Hecke algebra, min-plus convolution, Weyl group invariants, symmetric tropical polynomials, dominant coweights, idempotent semiring, tropical convexity, geometric Satake shadow, combinatorial representation theory, optimization algebra, formal Langlands, Galois adjunction, tropical harmonic analysis

---

### Required Deliverables

1. Lean 4 files with as many closed proofs as possible and minimal `sorry`
2. At least one main theorem with a precise `GL_n` statement
3. A short `ARTICLE.md` or `RESEARCH_PAPER.md` explaining the mathematical model you chose
4. **Mandatory:** `FUTURE_DIRECTIONS.md`

---

### Mandatory FUTURE_DIRECTIONS.md

You must produce **3–5 falsifiable scientific hypotheses**, each with:
- a precise conjecture
- what data/Lean experiment would test it
- what outcome would refute it

Use this format:

#### Hypothesis 1
**Conjecture.** For every `n`, the semiring `TropPolyInv n` is generated by orbit-symmetrized tropical monomials indexed by dominant coweights.  
**Test.** Implement generator search for small `n = 2,3,4` and bounded coefficient height; check whether every invariant tropical polynomial in the sample is generated by these basis elements.  
**Refutation criterion.** A concrete invariant tropical polynomial in bounded search not expressible from these generators.

#### Hypothesis 2
**Conjecture.** The tropical Satake transform for `GL_n` is an adjoint equivalence between finitely supported spherical kernels and finitely generated invariant tropical support functions.  
**Test.** Formalize candidate unit/counit maps and verify triangle identities for `n = 2,3,4`.  
**Refutation criterion.** Failure of one triangle identity or inability to reconstruct a kernel from an invariant support function.

#### Hypothesis 3
**Conjecture.** Tropical convolution structure constants for `GL_n` are governed by tropicalized Littlewood–Richardson combinatorics.  
**Test.** Compute products of basis Hecke elements for small dominant coweights and compare supports with tropical LR predictions.  
**Refutation criterion.** A mismatch in support or multiplicity pattern for some explicit small example.

#### Hypothesis 4
**Conjecture.** The `W`-invariant tropical polynomial semiring for `GL_n` embeds into a tropical Schur-function calculus with canonical basis indexed by partitions of length `≤ n`.  
**Test.** Define candidate tropical Schur functions and compare generated subsemiring with `TropPolyInv n` for `n = 3,4`.  
**Refutation criterion.** Either non-invariance, failure of closure, or inability to generate known invariant examples.

#### Hypothesis 5
**Conjecture.** The tropical Satake transform admits an algorithm with polynomial-time evaluation complexity in support size for fixed `n`.  
**Test.** Implement evaluation on finite-support Hecke data and measure asymptotic growth experimentally.  
**Refutation criterion.** Empirical super-polynomial blow-up on structured input families or a lower-bound obstruction from support reconstruction.

---

You are Aristotle. Do not merely extend `GL_2`; build the first credible formal infrastructure for tropical Satake in higher rank. The correct standard is not “interesting formalization.” The standard is: after this, people should be able to ask for tropical Hall–Littlewood theory, tropical geometric Satake, and tropical automorphic computation in Lean—and have a place to start.

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

Research domain: Tropical
Research mode: prove
