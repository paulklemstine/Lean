## Assignment: Invariant Subspace Problem: Compactness, Commutants, and the Edge of Counterexample

Mode: **prove + formalize + discover**

This is not a request for a routine functional-analysis port. This is a chance to carve out a formally verified corridor through one of the deepest fault lines in operator theory: why compactness forces invariant structure, why commutation with compactness propagates that structure, and where the Enflo–Read universe begins to resist it.

Your target is to formalize a **nontrivial special-case invariant subspace theory** in Lean 4 that is mathematically meaningful even if the full Banach-space frontier remains out of reach. The decisive move is to work in a setting where Mathlib’s Hilbert-space and bounded-operator infrastructure can support real theorems, then build a new bridge from spectral/compact methods to algebraic dynamics of operator commutants.

---

## Core Breakthrough Goal

Formalize a certified package of theorems showing that:

1. **Nonzero compact operators on infinite-dimensional complex Hilbert spaces admit nontrivial closed invariant subspaces.**
2. **Operators commuting with a nonzero compact operator inherit a nontrivial invariant subspace from an eigenspace or finite-dimensional spectral slice of that compact operator.**
3. **A new formal structure capturing “compactly generated invariant geometry” organizes these results and suggests a machine-checkable boundary between positive compact cases and Enflo–Read-type obstruction patterns.**

This would be a breakthrough because it turns one of the iconic qualitative principles of operator theory into a modular formal object: not merely “compact operators have invariant subspaces,” but “compactness manufactures finite-dimensional dynamical skeletons inside infinite-dimensional operator systems.” That is the formal seed of a future verified theory of invariant subspaces, hyperinvariant subspaces, and counterexample architectures.

---

## Precise Theorem Targets

You must prove **at least 3 substantial theorems** with real proof structure. Avoid trivial finite-dimensional or decidable detours. The point is to extract the operator-theoretic mechanism.

### Theorem A: Eigenvector-for-compact ⇒ invariant subspace
A formalizable Aronszajn–Smith style special case:

> **Mathematical statement.**  
> Let `H` be an infinite-dimensional complex Hilbert space. Let `T : H →L[ℂ] H` be a nonzero compact operator. Assume `μ : ℂ` is a nonzero eigenvalue of `T`. Then the eigenspace
> \[
> E_\mu(T)=\{x\in H : T x = \mu x\}
> \]
> is a nontrivial proper closed `T`-invariant subspace.

A plausible Lean 4 signature target:
```lean
theorem eigenspace_is_nontrivial_proper_closedInvariant
  {H : Type*}
  [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
  [InfiniteDimensional ℂ H]
  (T : H →L[ℂ] H)
  (hTcomp : IsCompactOperator T)
  (hT0 : T ≠ 0)
  {μ : ℂ}
  (hμ : μ ≠ 0)
  (hμeig : ∃ x : H, x ≠ 0 ∧ T x = μ • x) :
  ∃ K : Submodule ℂ H,
    K ≠ ⊥ ∧ K ≠ ⊤ ∧
    IsClosed (K : Set H) ∧
    ∀ x ∈ K, T x ∈ K
```

A stronger and cleaner formulation, if Mathlib infrastructure permits:
```lean
theorem eigenspace_nontrivial_proper_invariant
  {H : Type*}
  [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
  [InfiniteDimensional ℂ H]
  (T : H →L[ℂ] H)
  (hTcomp : IsCompactOperator T)
  {μ : ℂ}
  (hμ : μ ≠ 0)
  (hE : (T.eigenspace μ) ≠ ⊥) :
  (T.eigenspace μ) ≠ ⊤ ∧
  ∀ x ∈ T.eigenspace μ, T x ∈ T.eigenspace μ
```

Why it matters: this isolates the exact finite-dimensional nucleus produced by compactness. Even if the full spectral theorem for compact operators is not yet in Mathlib, this theorem is the right formal landing point for any available eigenvalue existence lemma.

---

### Theorem B: Commutant of a compact operator has an invariant subspace
A rigorous special-case Lomonosov theorem:

> **Mathematical statement.**  
> Let `H` be an infinite-dimensional complex Hilbert space. Let `K : H →L[ℂ] H` be a nonzero compact operator and `T : H →L[ℂ] H` satisfy `T.comp K = K.comp T`. If `K` has a nonzero eigenvalue `μ`, then `T` admits a nontrivial closed invariant subspace.

Mechanism: if `T` commutes with `K`, then `T` preserves each eigenspace of `K`.

Lean 4 target:
```lean
theorem commuting_operator_has_invariant_subspace_of_compact_eigenvalue
  {H : Type*}
  [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
  [InfiniteDimensional ℂ H]
  (T K : H →L[ℂ] H)
  (hKcomp : IsCompactOperator K)
  (hK0 : K ≠ 0)
  (hcomm : T.comp K = K.comp T)
  {μ : ℂ}
  (hμ : μ ≠ 0)
  (hμeig : ∃ x : H, x ≠ 0 ∧ K x = μ • x) :
  ∃ M : Submodule ℂ H,
    M ≠ ⊥ ∧ M ≠ ⊤ ∧
    IsClosed (M : Set H) ∧
    (∀ x ∈ M, T x ∈ M)
```

Key intermediate theorem you should prove explicitly:
```lean
theorem eigenspace_map_of_commuting
  {H : Type*}
  [NormedAddCommGroup H] [InnerProductSpace ℂ H]
  (T K : H →L[ℂ] H) {μ : ℂ}
  (hcomm : T.comp K = K.comp T) :
  ∀ x ∈ K.eigenspace μ, T x ∈ K.eigenspace μ
```

Why it matters: this is the formal heart of the “compactness in the commutant forces invariant geometry” principle. It is the finite-dimensional spectral shadow of Lomonosov, and it opens a path toward hyperinvariant subspaces.

---

### Theorem C: Finite-dimensionality of nonzero eigenspaces of compact operators
This is the crucial bridge theorem.

> **Mathematical statement.**  
> For a compact operator `T` on a Hilbert space, every eigenspace corresponding to a nonzero eigenvalue is finite-dimensional.

Lean target:
```lean
theorem finiteDimensional_eigenspace_of_isCompactOperator
  {H : Type*}
  [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
  (T : H →L[ℂ] H)
  (hTcomp : IsCompactOperator T)
  {μ : ℂ}
  (hμ : μ ≠ 0) :
  FiniteDimensional ℂ (T.eigenspace μ)
```

If full generality is too heavy, prove a structurally equivalent theorem for a newly defined finite-rank approximation notion (see “Novel definitions” below), then derive the invariant-subspace theorem in that setting.

Why it matters: finite-dimensionality is what makes the invariant subspace nontrivial and proper in an infinite-dimensional ambient space. It is the exact mechanism by which compactness constrains dynamics.

---

## Novel Definitions You Must Introduce

You are required to define at least one genuinely new concept not already in the catalog. Suggested definitions:

### 1. CompactlyGeneratedInvariant
A structure encoding a subspace obtained from a compact operator’s nonzero spectral data and preserved by a commuting family.

```lean
structure CompactlyGeneratedInvariant
    (H : Type*) [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H] where
  carrier : Submodule ℂ H
  nontrivial : carrier ≠ ⊥
  proper : carrier ≠ ⊤
  closed' : IsClosed (carrier : Set H)
  invariant_under : Set (H →L[ℂ] H)
  stable' : ∀ T ∈ invariant_under, ∀ x ∈ carrier, T x ∈ carrier
```

Then instantiate it from a compact operator eigenspace and its commutant.

### 2. CommutesWithCompact
A predicate for operators lying in the commutant of some nonzero compact operator.

```lean
def CommutesWithCompact
  {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
  (T : H →L[ℂ] H) : Prop :=
  ∃ K : H →L[ℂ] H, K ≠ 0 ∧ IsCompactOperator K ∧ T.comp K = K.comp T
```

Then prove that such operators have invariant subspaces under additional spectral hypotheses on `K`.

### 3. EnfloReadPattern
A formal obstruction-pattern record, not a full counterexample, but a certified abstraction of “no visible compact spectral skeleton.”

```lean
structure EnfloReadPattern
    (H : Type*) [NormedAddCommGroup H] [NormedSpace ℂ H] where
  T : H →L[ℂ] H
  no_nonzero_compact_commutant :
    ∀ K : H →L[ℂ] H, IsCompactOperator K → T.comp K = K.comp T → K = 0
```

This is mathematically valuable: it formalizes one necessary anti-Lomonosov feature of any genuine counterexample architecture.

---

## Proof Strategy Architecture

You must include 2–3 proof routes and pursue the strongest one available in Mathlib.

### Strategy A: Eigenspace transport through commutation
Most promising.

1. Prove that if `K x = μ x` and `T K = K T`, then
   \[
   K(Tx)=T(Kx)=T(\mu x)=\mu T x,
   \]
   so `T x` remains in the eigenspace.
2. Show the eigenspace is closed and nontrivial from existence of an eigenvector.
3. Use finite-dimensionality of the nonzero eigenspace of a compact operator to prove it is proper in an infinite-dimensional Hilbert space.

Why promising: it reduces operator theory to algebraic identities plus one deep compactness lemma. Lean likes this decomposition.

---

### Strategy B: Finite-rank approximation package
If direct compact-spectral theorems are incomplete in Mathlib.

1. Define a predicate expressing that `T` is the norm-limit of finite-rank operators.
2. Prove that for nonzero eigenvalue `μ`, approximate finite-rank images force precompactness of the unit sphere in the eigenspace.
3. Deduce the eigenspace must be finite-dimensional, else the unit sphere would fail total boundedness.

Why promising: this mirrors the standard compact-operator proof and may be more formalization-friendly than importing advanced spectral theory.

Key proof tactics likely needed: `by_contra`, `rcases`, extraction of orthonormal or separated sequences, compactness contradiction, multistep `calc`.

---

### Strategy C: Orthogonality and Riesz-style Hilbert geometry
A Hilbert-specific route.

1. Assume the eigenspace for nonzero `μ` is infinite-dimensional.
2. Produce an infinite orthonormal sequence inside it.
3. Since `T` acts as scalar multiplication by `μ` on that sequence, the image sequence has no convergent subsequence when `μ ≠ 0`.
4. Contradict compactness.

Why promising: conceptually clean and specific to Hilbert spaces. This is likely the most elegant proof of Theorem C if Mathlib supports enough orthonormal-sequence infrastructure.

---

## Deep Proof Tactic Expectations

Your file must contain at least 3 serious proofs using combinations of:
- `rcases`
- `by_contra`
- `have`
- `calc`
- induction where natural
- contradiction from compactness/precompactness
- submodule and eigenspace reasoning
- `field_simp` if scalar identities appear in rearranging eigen-relations

For example, proving propriety of the eigenspace should not be a one-line automation artifact. It should explicitly use infinite-dimensional ambient space versus finite-dimensional eigenspace.

---

## Cross-Domain Connections You Must Build In

This project must not remain sealed inside operator theory. Include at least one theorem or formal discussion linking invariant subspaces to another domain.

### Connection 1: Dynamical systems / Koopman operators
Interpret invariant subspaces as observable sectors preserved by linear dynamics. A compact commuting operator acts like a “coarse-graining” or “resolution filter,” and the preserved eigenspace becomes a finite observable mode.

Possible theorem framing:
- If `T` commutes with a compact self-adjoint `K`, then each nonzero eigenspace of `K` is a finite-dimensional `T`-invariant mode sector.

This is a formal prototype for spectral model reduction in dynamical systems.

### Connection 2: Quantum mechanics
Compact self-adjoint operators model bounded approximations to Hamiltonian resolvents or density operators. The invariant eigenspace theorem becomes a certified “energy shell preservation” statement for commuting observables.

Suggested keyword theorem statement:
- commuting observables preserve compact spectral sectors.

### Connection 3: Complexity / information flow
Use the catalog’s broad unification theorems conceptually: compactness creates low-complexity channels in infinite-dimensional dynamics. The invariant subspace is a formally certified compression layer.

If meaningful, cite how a finite-dimensional invariant sector is a mathematically exact analogue of a latent representation.

Application keywords:
**operator theory, compact operators, invariant subspace, Hilbert space, spectral theory, Koopman dynamics, quantum observables, model reduction, commutant rigidity, formal verification**

---

## How to Build on Existing Verified Theorems

The listed catalog results are heterogeneous, but you should still leverage the strongest abstract infrastructure patterns they suggest.

1. **`FINAL/Algebra/EMLCongruenceHilbert.lean::idempotent_hilbert_basis_theorem`**  
   Use this as a signal that Hilbert-basis/finiteness machinery has already been formalized in the ecosystem. If it provides a basis extraction or finite-generation principle, adapt that style to finite-dimensional eigenspaces or invariant submodule generation.

2. **`FINAL/Algebra/GenesisOracle.lean::master_theorem`** and  
   **`FINAL/Algebra/Other/UnifyingTheory.lean::grand_unification_theorem`**  
   These likely encode high-level abstraction patterns. Do not cite them cosmetically. Use them as templates for packaging a broad operator-theoretic structure into a reusable record/namespace, e.g. `CompactlyGeneratedInvariant`.

3. **`nonzero_linear_form_zero_set_bound`**  
   This theorem is not directly operator-theoretic, but it demonstrates the pattern “nonzero functional data forces geometric restriction.” Emulate that proof architecture: nonzero eigenvalue data forces a geometric codimension/finiteness constraint on the eigenspace.

If the catalog files expose reusable lemmas about finite generation, boundedness, or closedness, explicitly import and cite them in comments.

---

## Concrete Theorem Bundle to Aim For

At minimum, prove a coherent set such as:

```lean
theorem eigenspace_map_of_commuting ...
theorem finiteDimensional_eigenspace_of_isCompactOperator ...
theorem eigenspace_is_nontrivial_proper_closedInvariant ...
theorem commuting_operator_has_invariant_subspace_of_compact_eigenvalue ...
theorem commutesWithCompact_has_invariant_subspace_of_nonzero_eigenvalue ...
```

Optional but highly desirable strengthening:

```lean
theorem commutant_preserves_compact_spectral_sector
  {H : Type*} ...
  (K : H →L[ℂ] H) (hKcomp : IsCompactOperator K)
  (S : Set (H →L[ℂ] H))
  (hcomm : ∀ T ∈ S, T.comp K = K.comp T)
  {μ : ℂ} (hμ : μ ≠ 0) :
  ∀ T ∈ S, ∀ x ∈ K.eigenspace μ, T x ∈ K.eigenspace μ
```

This turns one theorem into a reusable invariant-sector engine.

---

## Enflo–Read Counterexample Structure: What to Formalize

Do **not** claim a full Enflo or Read counterexample unless you can support it. Instead formalize a necessary obstruction schema.

Target theorem:

> If an operator `T` commutes with a nonzero compact operator having a nonzero eigenvalue, then `T` has a nontrivial invariant subspace. Therefore any operator with no nontrivial invariant subspace cannot lie in such a compact commutant class.

Lean target:
```lean
theorem noInvariantSubspace_implies_no_compact_eigenvalue_commutant
  {H : Type*}
  [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
  [InfiniteDimensional ℂ H]
  (T : H →L[ℂ] H)
  (hno :
    ¬ ∃ M : Submodule ℂ H,
      M ≠ ⊥ ∧ M ≠ ⊤ ∧ IsClosed (M : Set H) ∧ ∀ x ∈ M, T x ∈ M) :
  ∀ K : H →L[ℂ] H, IsCompactOperator K → T.comp K = K.comp T →
    ∀ μ : ℂ, μ ≠ 0 → ¬ ∃ x : H, x ≠ 0 ∧ K x = μ • x
```

This is a mathematically sharp “counterexample boundary theorem.”

---

## Testable Conjectures You Must State

Include at least one falsifiable conjecture with a clear computational disproof criterion.

### Conjecture 1: Finite-rank commutant approximation principle
> For every bounded operator `T` on separable Hilbert space that commutes with a nonzero compact operator, there exists a nontrivial finite-dimensional subspace invariant under every polynomial in `T` and the compact operator.

**Test:** numerically sample large truncations of operator pairs `(T_n, K_n)` with `[T_n, K_n] ≈ 0`, compute nonzero eigenspaces of `K_n`, and check whether they are approximately preserved by `T_n`. A counterexample is a family where commutator norm tends to zero but invariant-sector defect stays bounded away from zero.

### Conjecture 2: Enflo–Read obstruction via compact commutant triviality
> Any Banach-space operator with no nontrivial invariant subspace has trivial compact commutant.

**Test:** search known quasinilpotent/shift-like constructions and explicitly compute finite-rank or compact operators in truncated commutants. A disproof would exhibit a nonzero compact operator commuting with the candidate.

### Conjecture 3: Hyperinvariant strengthening in the Hilbert compact case
> If `K` is nonzero compact on a complex Hilbert space, then some nonzero eigenspace of `K` is hyperinvariant for the entire commutant of `K`.

**Test:** in matrix truncations, compute the full commutant of `K_n` and verify preservation of each nonzero eigenspace. A disproof would require a commuting matrix that mixes vectors out of a nonzero eigenspace.

---

## Required Deliverables

You must produce **all** of the following:

1. **Lean file(s)** containing the new definitions and at least 3 deep theorems with minimized sorry usage.
2. **FUTURE_DIRECTIONS.md** with **3–5 falsifiable scientific hypotheses**, each with:
   - exact conjecture statement,
   - what data/computation would test it,
   - what outcome would refute it.
3. **RESEARCH_PAPER.md** as a **standalone scientific paper**:
   - problem statement,
   - theorem statements,
   - proof ideas,
   - significance,
   - limitations,
   - next-step conjectures.
4. **ARTICLE.md** in Scientific American style:
   - explain why compactness creates hidden order in infinite-dimensional systems,
   - connect to quantum mechanics/dynamical systems,
   - explain the Enflo–Read frontier.
5. **A verified algorithm or computational method**:
   - e.g. a procedure that, given finite-dimensional truncations of commuting operators, computes candidate invariant sectors from compact spectral slices.
6. **demo.py**:
   - construct sample matrices approximating compact operators,
   - compute eigenspaces,
   - verify commutant preservation numerically,
   - visualize invariant subspace emergence.

---

## Implementation Guidance in Lean

Prioritize the following formal objects:
- `Submodule ℂ H`
- closedness of eigenspaces / kernels
- continuous linear maps / bounded linear operators
- commuting operators via composition equality
- finite-dimensionality transfer arguments
- infinite-dimensional ambient contradiction

Useful intermediate lemmas to prove if absent:
```lean
theorem eigenspace_eq_ker_sub
theorem eigenspace_isClosed
theorem commuting_preserves_eigenspace
theorem finiteDimensional_proper_of_infiniteDimensional_ambient
theorem invariant_of_preserves_submodule
```

If `IsCompactOperator` is not exactly the existing name in Mathlib, adapt to the library’s compact-map notion, but preserve the mathematical content.

---

## Standard of Ambition

Do not settle for “if there is already an eigenvector, then its span is invariant.” That is mathematically true but too weak unless embedded into the compact-operator mechanism. The point is to prove that compactness forces finite-dimensional spectral sectors and that commutation transports them. The resulting theory should feel like a verified micro-version of Lomonosov’s insight, not a classroom exercise.

The best outcome is a Lean development that future work can extend toward:
- hyperinvariant subspaces,
- Riesz operators,
- polynomially compact operators,
- commutant rigidity,
- formal boundaries around Enflo–Read-type counterexamples.

This is where formal operator theory stops being archival and starts becoming exploratory science.

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

Research domain: Algebra
Research mode: prove
