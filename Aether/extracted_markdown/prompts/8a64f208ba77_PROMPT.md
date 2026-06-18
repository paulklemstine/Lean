## Assignment: Security analysis — tropical factor recovery as a complete hard problem

**Mode:** prove

You should not merely show an ad hoc “security intuition.” You should isolate a precise **reduction theorem**: any instance of tropical matrix factorization can be embedded into the problem of recovering a hidden pair `(A,B)` from a product matrix `M`, so that an oracle for recovering `(A,B)` yields an oracle for general tropical factorization. This is the right notion of hardness, and it upgrades vague cryptographic language into a mathematically certified completeness statement for a tropical inverse problem.

The key breakthrough target is to formalize a **many-one reduction** from tropical factorization to factor recovery. If you can make this clean in Lean with concrete finite matrices over `ℝ`, you create a reusable security primitive: every future tropical cryptosystem based on hidden decompositions can cite this theorem as its hardness backbone.

---

## Precise theorem target

Work over min-plus tropical matrix multiplication on finite matrices `Matrix (Fin n) (Fin m) ℝ`. You will likely need to define the tropical product explicitly if the existing catalog does not already package it in the needed form.

### Core definitions to introduce

Define a tropical product, for compatible sizes:
```lean
def tropMul {n k m : ℕ} (A : Matrix (Fin n) (Fin k) ℝ) (B : Matrix (Fin k) (Fin m) ℝ) :
    Matrix (Fin n) (Fin m) ℝ :=
  fun i j => Finset.inf' Finset.univ (by simp) (fun t => A i t + B t j)
```
or, if easier for proof engineering, use `sInf` over the finite image set:
```lean
def tropMul {n k m : ℕ} (A : Matrix (Fin n) (Fin k) ℝ) (B : Matrix (Fin k) (Fin m) ℝ) :
    Matrix (Fin n) (Fin m) ℝ :=
  fun i j => sInf (Set.range fun t : Fin k => A i t + B t j)
```
with finite-set lemmas to connect them.

Define the factorization predicate:
```lean
def IsTropicalFactorization {n m k : ℕ}
    (M : Matrix (Fin n) (Fin m) ℝ)
    (A : Matrix (Fin n) (Fin k) ℝ)
    (B : Matrix (Fin k) (Fin m) ℝ) : Prop :=
  tropMul A B = M
```

Define the recovery problem as existence of a witness pair:
```lean
def Recoverable {n m k : ℕ} (M : Matrix (Fin n) (Fin m) ℝ) : Prop :=
  ∃ A : Matrix (Fin n) (Fin k) ℝ, ∃ B : Matrix (Fin k) (Fin m) ℝ,
    tropMul A B = M
```

### Main theorem statement

The mathematically meaningful theorem is that **recovering `(A,B)` from `M` is exactly tropical factorization**, not merely “at least as hard.” In decision/existence form, they are definitionally equivalent; in witness form, recovery is the search version of factorization.

A clean Lean target:

```lean
theorem recover_pair_iff_factorization
    {n m k : ℕ} [NeZero n] [NeZero m] [NeZero k]
    (M : Matrix (Fin n) (Fin m) ℝ) :
    Recoverable (k := k) M ↔
      ∃ A : Matrix (Fin n) (Fin k) ℝ, ∃ B : Matrix (Fin k) (Fin m) ℝ,
        IsTropicalFactorization M A B := by
```

This theorem is foundational but still close to definitional. The real non-trivial theorem should express a **uniform reduction**.

### Breakthrough theorem: explicit reduction/completeness

Prove that every factorization instance is identical to a recovery instance under the identity embedding, and package this as a reduction preserving witnesses.

```lean
def TFInstance (n m k : ℕ) := Matrix (Fin n) (Fin m) ℝ

def tropicalFactorizationReducesToRecovery
    {n m k : ℕ} [NeZero n] [NeZero m] [NeZero k] :
    ∃ f : TFInstance n m k → Matrix (Fin n) (Fin m) ℝ,
      (∀ M, Recoverable (k := k) (f M) ↔
        ∃ A : Matrix (Fin n) (Fin k) ℝ, ∃ B : Matrix (Fin k) (Fin m) ℝ,
          tropMul A B = M) := by
```

The reduction map `f` should simply be `id`, but the theorem matters because it identifies the cryptographic inverse problem with the canonical algebraic search problem.

Then push further to a nontrivial **uniqueness-obstruction theorem**: if recovery were easy and canonical, tropical factorizations would be rigid in a way they are not. Show gauge symmetries explicitly.

### Symmetry theorem: non-uniqueness of recovered keys

For any vector `c : Fin k → ℝ`, define row/column shifts
```lean
def shiftA {n k : ℕ} (A : Matrix (Fin n) (Fin k) ℝ) (c : Fin k → ℝ) :
    Matrix (Fin n) (Fin k) ℝ :=
  fun i t => A i t + c t

def shiftB {k m : ℕ} (B : Matrix (Fin k) (Fin m) ℝ) (c : Fin k → ℝ) :
    Matrix (Fin k) (Fin m) ℝ :=
  fun t j => B t j - c t
```

Then prove:
```lean
theorem tropMul_shift_invariant
    {n m k : ℕ} [NeZero n] [NeZero m] [NeZero k]
    (A : Matrix (Fin n) (Fin k) ℝ)
    (B : Matrix (Fin k) (Fin m) ℝ)
    (c : Fin k → ℝ) :
    tropMul (shiftA A c) (shiftB B c) = tropMul A B := by
```

This is genuinely important: it shows the recovery problem is not just factorization, but factorization **modulo tropical gauge symmetry**. That is cryptographically and mathematically deep. It means the right hardness object is an equivalence class of decompositions, not a unique secret key.

### Security consequence theorem

Use the catalog theorem `tropical_security_from_norm_bound` as a bridge: if some norm-based obstruction is already verified, combine it with the reduction above to derive that any successful recovery procedure would solve the corresponding bounded tropical factorization class.

A target shape:
```lean
theorem bounded_recovery_hardness
    {n m k : ℕ} [NeZero n] [NeZero m] [NeZero k]
    (M : Matrix (Fin n) (Fin m) ℝ)
    (hsec : -- hypotheses matching tropical_security_from_norm_bound
    ) :
    Recoverable (k := k) M → 
      ∃ A : Matrix (Fin n) (Fin k) ℝ, ∃ B : Matrix (Fin k) (Fin m) ℝ,
        tropMul A B = M := by
```
This may look tautological, so do not stop there. Refine it with explicit norm bounds on recovered witnesses if the catalog theorem gives such control. The nontrivial content is **bounded witness extraction** from security assumptions.

---

## Lean 4 type signature suggestions

These are good formalization targets. Adapt as needed to existing definitions in the repository.

```lean
def tropMul {n k m : ℕ} :
    Matrix (Fin n) (Fin k) ℝ →
    Matrix (Fin k) (Fin m) ℝ →
    Matrix (Fin n) (Fin m) ℝ
```

```lean
def IsTropicalFactorization {n m k : ℕ}
    (M : Matrix (Fin n) (Fin m) ℝ)
    (A : Matrix (Fin n) (Fin k) ℝ)
    (B : Matrix (Fin k) (Fin m) ℝ) : Prop
```

```lean
def Recoverable {n m k : ℕ}
    (M : Matrix (Fin n) (Fin m) ℝ) : Prop
```

```lean
theorem recover_pair_iff_factorization
    {n m k : ℕ} [NeZero n] [NeZero m] [NeZero k]
    (M : Matrix (Fin n) (Fin m) ℝ) :
    Recoverable (k := k) M ↔
      ∃ A : Matrix (Fin n) (Fin k) ℝ, ∃ B : Matrix (Fin k) (Fin m) ℝ,
        tropMul A B = M
```

```lean
theorem tropMul_shift_invariant
    {n m k : ℕ} [NeZero n] [NeZero m] [NeZero k]
    (A : Matrix (Fin n) (Fin k) ℝ)
    (B : Matrix (Fin k) (Fin m) ℝ)
    (c : Fin k → ℝ) :
    tropMul (fun i t => A i t + c t) (fun t j => B t j - c t) = tropMul A B
```

```lean
theorem tropical_factorization_reduction
    {n m k : ℕ} [NeZero n] [NeZero m] [NeZero k] :
    ∃ f : Matrix (Fin n) (Fin m) ℝ → Matrix (Fin n) (Fin m) ℝ,
      ∀ M,
        (∃ A : Matrix (Fin n) (Fin k) ℝ, ∃ B : Matrix (Fin k) (Fin m) ℝ,
            tropMul A B = M) ↔
        Recoverable (k := k) (f M)
```

If possible, go beyond existence and define an abstract oracle:
```lean
def RecoveryOracle (n m k : ℕ) :=
  ∀ M : Matrix (Fin n) (Fin m) ℝ,
    Option (Matrix (Fin n) (Fin k) ℝ × Matrix (Fin k) (Fin m) ℝ)
```
and prove correctness implies a factorization solver:
```lean
theorem oracle_recovery_yields_factorization_solver ...
```
This packages the hardness statement in the search-problem language used by cryptography and complexity.

---

## Proof strategy architecture

### Strategy A: direct definitional reduction + symmetry analysis
This is the most promising route for a first decisive theorem.

1. **Define tropical multiplication and factorization cleanly.**
   Keep the algebra concrete over `ℝ` and `Fin`-indexed matrices. Avoid abstract semiring generality until the theorem is stable.

2. **Prove recovery/factorization equivalence by unfolding definitions.**
   This gives the exact reduction theorem with essentially no mathematical ambiguity.

3. **Add the gauge-invariance theorem `tropMul_shift_invariant`.**
   This is where the result becomes nontrivial: recovering a secret pair is equivalent to factorization modulo a continuous family of equivalent witnesses. This converts a basic equivalence into a structural theorem about hidden-key non-identifiability.

Why this is best: it is Lean-feasible, mathematically honest, and produces a reusable theorem stack immediately.

### Strategy B: bounded hardness via norm control
This is the best route if the catalog theorem `tropical_security_from_norm_bound` is strong enough.

1. **Extract the exact hypotheses and conclusion of `tropical_security_from_norm_bound`.**
   Determine whether it controls witness norms, separation margins, or impossibility of short decompositions.

2. **Combine with `tropical_norm_from_decomposition`.**
   Use decomposition-induced norm estimates to show any recovery algorithm for bounded secrets would solve bounded tropical factorization.

3. **State and prove a restricted hardness theorem for norm-bounded instances.**
   This is more cryptographically meaningful than raw existence, because security claims usually live in constrained key spaces.

Why this matters: it transforms algebraic equivalence into a true security theorem over structured instance families.

### Strategy C: spectral/eigenvalue obstruction route
This is more speculative but could produce the most surprising mathematics.

1. Use `tropical_eigenpair_from_diagonal` to derive necessary spectral constraints on any factorization `M = A ⊗ B`.
2. Show that a recovery algorithm would implicitly solve a constrained inverse eigenproblem in tropical linear algebra.
3. Reinterpret hidden-factor recovery as reconstructing a latent tropical geometry from spectral shadows.

Why this is exciting: it connects cryptographic hardness to tropical spectral theory, potentially opening a new “spectral cryptanalysis in min-plus algebra” program.

---

## How to build on the catalog theorems

Do not mention the catalog results ceremonially; use them structurally.

### 1. `tropical_security_from_norm_bound`
**Use:** convert generic hardness language into a theorem on **bounded factor spaces**.  
If it says that certain norm bounds imply security or resistance, instantiate it on matrices obtained from a factorization witness and show that any successful recovery contradicts the theorem unless it already solves bounded tropical factorization.

### 2. `tropical_norm_from_decomposition`
**Use:** derive quantitative inequalities on `‖M‖` from `M = tropMul A B`.  
This is crucial if you want to prove that reduction preserves size/energy parameters, which is what makes a reduction cryptographically meaningful rather than merely existential.

### 3. `tropical_eigenpair_from_diagonal`
**Use:** produce necessary conditions for decomposability from diagonal data, then show a recovery oracle reveals hidden eigenstructure.  
This could lead to a theorem saying recovery is at least as hard as reconstructing tropical eigenpairs of latent factors.

### 4. `tropical_mirror_theorem`
This theorem is trivial in isolation, but conceptually it encodes **idempotent collapse** (`max a a = a`).  
**Use:** when proving tropical gauge or symmetry lemmas, idempotence can simplify repeated minimization/maximization terms. It may help in finite infimum normalization arguments.

### 5. `birthday_bound_tropical_hash`
**Use:** connect factor-recovery ambiguity with collision phenomena.  
If many factor pairs map to the same `M` under gauge symmetry or deeper combinatorial symmetries, this resembles a tropical collision space. This is a bridge from algebraic non-uniqueness to cryptographic collision bounds.

---

## Cross-domain connections you should explicitly exploit

### 1. Cryptography / search-vs-decision complexity
Your theorem should say: the secret-recovery problem is not an ad hoc inversion task; it is the canonical **search version** of tropical factorization. This mirrors hardness foundations in lattice cryptography, coding theory, and multivariate cryptography.

### 2. Inverse problems / identifiability
The gauge-invariance theorem makes tropical recovery analogous to blind source separation and matrix sensing with latent symmetries. The right object is a quotient space of decompositions. This is an inverse-problem perspective, not just algebra.

### 3. Tropical geometry
A factorization `M = A ⊗ B` can be read as expressing `M` through latent tropical hyperplanes / generators. Recovery becomes reconstruction of hidden tropical convex structure. This could connect to tropical rank, Barvinok rank, and tropical polytopes.

### 4. Spectral theory
If you can tie recovery to `tropical_eigenpair_from_diagonal`, you create a new bridge: hidden factor cryptography as a tropical inverse spectral problem.

### 5. Information theory
Non-uniqueness classes of decompositions suggest entropy of hidden representations. A future theorem could define a tropical mutual information between `M` and equivalence classes of factors. Even mentioning this direction correctly could seed a new field.

---

## What would count as a real breakthrough

A weak result is: “there exists `(A,B)` iff `M` factors.”  
A strong result is one of the following:

1. **Recovery completeness theorem:** a formal reduction from tropical factorization to pair recovery, preserving witness size/bounds.
2. **Gauge-rigidity theorem:** all recovered pairs are determined only up to an explicit tropical symmetry group.
3. **Bounded-security theorem:** under norm constraints from the catalog, recovery of hidden factors is as hard as bounded tropical factorization.
4. **Spectral bridge theorem:** any recovery oracle yields a solver for a nontrivial tropical inverse spectral problem.

If you can prove (1) + (2), you already have a publishable conceptual core. If you add (3) or (4), you open a research area.

---

## Implementation guidance in Lean

- Prefer `Fin n` matrices and explicit functions over excessive abstraction.
- Prove helper lemmas for finite infima of translated sets:
  - `inf (x + c_t + (y - c_t)) = inf (x + y)`
  - image equality of `fun t => A i t + c t + (B t j - c t)` and `fun t => A i t + B t j`
- If `Finset.inf'` becomes painful, use `sInf` on finite ranges and prove range equality directly.
- For extensionality:
  ```lean
  ext i j
  ```
  then reduce to pointwise equality of infima.
- If subtraction over `ℝ` simplifies gauge invariance, stay over `ℝ`; do not generalize prematurely to arbitrary ordered additive commutative groups unless the proof is already complete.

---

## Concrete theorem package to aim for

At minimum, produce a Lean file proving:

1. `recover_pair_iff_factorization`
2. `tropMul_shift_invariant`
3. `tropical_factorization_reduction`

At best, also prove one of:

4. `bounded_recovery_hardness`
5. `oracle_recovery_yields_factorization_solver`
6. a theorem relating recovered factorizations to tropical eigenpairs or norm bounds

---

## Application keywords

tropical cryptography, min-plus algebra, matrix factorization hardness, search-to-factorization reduction, hidden decomposition security, gauge symmetry, non-identifiability, inverse problems, tropical convexity, tropical rank, inverse spectral theory, collision structure, complexity-theoretic hardness, algebraic cryptanalysis, latent tropical geometry

---

## Deliverables

Required:
- Lean 4 code formalizing the definitions and proving the main theorems
- `FUTURE_DIRECTIONS.md`

Optional but strongly encouraged:
- `ARTICLE.md` explaining why recovery is factorization-complete
- `RESEARCH_PAPER.md` with theorem statements, proof sketches, and cryptographic framing
- `diagram.svg` showing the reduction and symmetry classes

---

## Required FUTURE_DIRECTIONS.md

You must produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete next theorems**, each including:
1. a precise theorem statement,
2. a likely Lean type signature,
3. 2–3 proof strategy bullets,
4. one cross-domain connection.

Strong candidate next steps:
- classify all gauge-equivalent factorizations of a fixed matrix;
- prove hardness for bounded tropical rank recovery;
- connect factor recovery to tropical collision entropy using `birthday_bound_tropical_hash`;
- derive spectral obstructions to recovery from `tropical_eigenpair_from_diagonal`;
- formulate a tropical information measure of hidden decomposition ambiguity.

Do not be incremental. Build the hardness theory that future tropical cryptography will stand on.

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
