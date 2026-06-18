## Assignment: Invariant Subspace Problem

Mode: **formalize + prove + counterexample-aware**

This direction is only revolutionary if you separate what is currently accessible in Lean from the full unresolved invariant subspace problem. Do **not** spend cycles pretending to settle the general statement for all bounded operators on separable Hilbert spaces. Instead, carve out a formally airtight frontier:

1. **Formalize and prove the invariant subspace theorem for compact operators on infinite-dimensional complex Hilbert spaces.**
2. **Formalize and prove the invariant subspace theorem for normal operators via the spectral theorem / orthogonal complement arguments.**
3. **Identify the exact obstruction to a full formal attack on arbitrary bounded operators, and if needed produce a counterexample to over-optimistic intermediate conjectures.**

The real breakthrough is not “solve the invariant subspace problem” by wishful phrasing. The breakthrough is to build a Lean-certified operator-theoretic platform where compactness, normality, eigenspaces, spectral data, and closed invariant subspaces are all interoperable. That infrastructure opens future formal work in spectral theory, quantum mechanics, ergodic theory, control, and operator algebras.

### Core Theorem Targets

Work over `𝕜 = ℂ`. Let `H` be a separable infinite-dimensional Hilbert space.

#### Target Theorem A: compact operator invariant subspace theorem
Precise mathematical statement:

> Let `H` be a nontrivial infinite-dimensional complex Hilbert space and let
> `T : H →L[ℂ] H` be a compact bounded linear operator.  
> If `T ≠ 0`, then there exists a closed subspace `M ⊆ H` such that
> `M ≠ ⊥`, `M ≠ ⊤`, and `T(M) ⊆ M`.

A Lean-shaped target signature:

```lean
theorem exists_nontrivial_closed_invariantSubspace_of_isCompact
    {H : Type*}
    [NormedAddCommGroup H]
    [InnerProductSpace ℂ H]
    [CompleteSpace H]
    [InfiniteDimensional ℂ H]
    (T : H →L[ℂ] H)
    (hTcomp : CompactOperator T)
    (hTnonzero : T ≠ 0) :
    ∃ M : Submodule ℂ H,
      IsClosed (M : Set H) ∧
      M ≠ ⊥ ∧ M ≠ ⊤ ∧
      ∀ x ∈ M, T x ∈ M
```

More ambitious and cleaner if Mathlib supports eigenspaces adequately:

```lean
theorem exists_nontrivial_eigenspace_of_isCompact
    {H : Type*}
    [NormedAddCommGroup H]
    [InnerProductSpace ℂ H]
    [CompleteSpace H]
    [InfiniteDimensional ℂ H]
    (T : H →L[ℂ] H)
    (hTcomp : CompactOperator T)
    (hTnonzero : T ≠ 0) :
    ∃ μ : ℂ, μ ≠ 0 ∧
      let M := LinearMap.eigenspace (T : H →ₗ[ℂ] H) μ
      IsClosed (M : Set H) ∧ M ≠ ⊥ ∧ M ≠ ⊤
```

This theorem is the gateway: a nonzero compact operator on an infinite-dimensional complex Banach/Hilbert space has a nonzero eigenvalue, and its eigenspace is closed and proper.

#### Target Theorem B: normal operator invariant subspace theorem
Precise mathematical statement:

> Let `T : H →L[ℂ] H` be a bounded normal operator on a complex Hilbert space `H`.
> Then there exists a nontrivial closed invariant subspace of `H`, provided `dim H > 1`.

A Lean-shaped target signature:

```lean
theorem exists_nontrivial_closed_invariantSubspace_of_normal
    {H : Type*}
    [NormedAddCommGroup H]
    [InnerProductSpace ℂ H]
    [CompleteSpace H]
    [Fact (1 < Module.finrank ℂ H ∨ InfiniteDimensional ℂ H)]
    (T : H →L[ℂ] H)
    (hTnormal : IsNormal T) :
    ∃ M : Submodule ℂ H,
      IsClosed (M : Set H) ∧
      M ≠ ⊥ ∧ M ≠ ⊤ ∧
      ∀ x ∈ M, T x ∈ M
```

If the full spectral theorem interface is not yet available in Mathlib, target the important special case:

```lean
theorem exists_nontrivial_closed_invariantSubspace_of_selfAdjoint
    {H : Type*}
    [NormedAddCommGroup H]
    [InnerProductSpace ℂ H]
    [CompleteSpace H]
    [InfiniteDimensional ℂ H]
    (T : H →L[ℂ] H)
    (hTsa : IsSelfAdjoint T) :
    ∃ M : Submodule ℂ H,
      IsClosed (M : Set H) ∧
      M ≠ ⊥ ∧ M ≠ ⊤ ∧
      ∀ x ∈ M, T x ∈ M
```

#### Target Theorem C: finite-dimensional reduction as a certified base case
You should also prove the finite-dimensional theorem cleanly:

> Every linear operator on a finite-dimensional complex vector space of dimension at least `2` has a nontrivial invariant subspace.

Lean target:

```lean
theorem exists_nontrivial_invariantSubspace_of_finiteDimensional
    {V : Type*}
    [AddCommGroup V]
    [Module ℂ V]
    [FiniteDimensional ℂ V]
    (hdim : 2 ≤ Module.finrank ℂ V)
    (T : V →ₗ[ℂ] V) :
    ∃ M : Submodule ℂ V,
      M ≠ ⊥ ∧ M ≠ ⊤ ∧
      ∀ x ∈ M, T x ∈ M
```

This should proceed via existence of an eigenvalue over `ℂ`, then eigenspace.

### Why this is a breakthrough

A Lean development of invariant subspace theorems for compact and normal operators is not a routine formalization. It is a foundation for a **certified spectral theory stack**. Once eigenspaces, orthogonal complements, compact spectral data, and invariant-subspace constructions are machine-checked, Aristotle can move directly into:

- quantum observables and measurement subspaces,
- Koopman/operator-theoretic dynamics,
- stability decomposition in infinite-dimensional control,
- C\*-algebra representations,
- certified PDE spectral approximation,
- formal functional analysis for machine learning kernels and Gaussian processes.

The true field-opening move is to make invariant-subspace arguments reusable as infrastructure rather than one-off proofs.

### Mathematical Framing

The global invariant subspace problem for Hilbert spaces is subtle and historically deep; in some settings it is solved, in others variants are open or were resolved negatively in Banach contexts. Therefore:

- **Do not overclaim.**
- **Do formalize the strongest classical positive results currently within reach.**
- **Do expose the exact dependency graph:** compactness → nonzero eigenvalue → eigenspace closed/proper → invariant subspace.
- **Do separate Hilbert-space positivity from Banach-space pathology.**

This is also a chance to build a formal taxonomy:

- invariant subspace,
- hyperinvariant subspace,
- reducing subspace,
- eigenspace-generated invariant subspace,
- spectral projection subspace.

That taxonomy itself is valuable and reusable.

### 2–3 Proof Strategy Architectures

#### Strategy A: compact operator via Riesz–Schauder spectral theory
Most promising if Mathlib already has enough compact-operator and spectral primitives.

Steps:
1. Prove or import the theorem: a nonzero compact operator on an infinite-dimensional complex Banach/Hilbert space has a nonzero eigenvalue.
2. Show the eigenspace `ker(T - μ I)` is a closed subspace and is invariant under `T`.
3. Prove it is nontrivial because `μ` is an eigenvalue, and proper because `μ ≠ 0` and `T ≠ μ I` on an infinite-dimensional space when `T` is compact but `I` is not compact.

Why promising:
- This is the cleanest mathematically.
- It isolates all heavy analysis in one spectral theorem.
- It yields a stronger statement: existence of a nonzero eigenvalue, not merely an invariant subspace.

Potential obstacle:
- Mathlib may not yet package Riesz–Schauder in exactly this form. If absent, you may need to formalize a specialized compact-operator eigenvalue theorem.

#### Strategy B: normal operator via orthogonal complement of eigenspaces / spectral decomposition
Promising if there is enough adjoint and orthogonality API.

Steps:
1. In finite-dimensional or pure point-spectrum cases, extract an eigenvector and take its span.
2. For self-adjoint/normal operators, prove that orthogonal complements of invariant subspaces are invariant under the adjoint, and reducing under normality when appropriate.
3. Use spectral decomposition or spectral projections to produce a proper closed reducing subspace.

Why promising:
- Leverages Hilbert-specific geometry.
- Builds bridges to quantum mechanics: reducing subspaces correspond to measurable spectral sectors.
- Gives stronger structure than mere invariance.

Potential obstacle:
- Full spectral theorem formalization may be heavy. If so, prove special cases first: self-adjoint compact, then normal compact, then finite-dimensional normal.

#### Strategy C: finite-dimensional bootstrap and approximation interface
Use this if infinite-dimensional APIs are immature.

Steps:
1. Prove the finite-dimensional theorem over `ℂ` via existence of eigenvalues.
2. Formalize finite-rank operators as compact operators with obvious invariant subspaces.
3. Build approximation lemmas suggesting compact operators are norm-limits of finite-rank operators, then isolate what extra ingredient is needed to pass invariant subspaces to the limit.

Why useful:
- Even if the final compact theorem stalls, this creates serious reusable infrastructure.
- It clarifies exactly where compactness interacts with spectral existence.
- It may lead to a certified “approximation-to-spectrum” package.

Most promising overall: **Strategy A for compact operators, Strategy B for normal/self-adjoint operators, Strategy C as infrastructure fallback.**

### Definitions to Introduce Cleanly

If absent from Mathlib, define:

```lean
def IsInvariantSubspace
    {H : Type*} [Semiring 𝕜] [AddCommMonoid H] [Module 𝕜 H]
    (T : H →ₗ[𝕜] H) (M : Submodule 𝕜 H) : Prop :=
  ∀ x ∈ M, T x ∈ M
```

For continuous operators:

```lean
def IsInvariantClosedSubspace
    {H : Type*}
    [NormedAddCommGroup H] [NormedSpace 𝕜 H]
    (T : H →L[𝕜] H) (M : Submodule 𝕜 H) : Prop :=
  IsClosed (M : Set H) ∧ ∀ x ∈ M, T x ∈ M
```

Also define:

- `IsReducingSubspace T M := M invariant under T and Mᗮ invariant under T`
- `NontrivialClosedSubspace M := IsClosed (M : Set H) ∧ M ≠ ⊥ ∧ M ≠ ⊤`

These abstractions will pay off immediately.

### Concrete Lemma Chain to Build

You should aim to prove, in order:

1. `LinearMap.eigenspace_isInvariant`
2. `LinearMap.eigenspace_isClosed` for continuous linear maps on complete spaces
3. `span_singleton_isInvariant_of_eigenvector`
4. `orthogonalComplement_invariant_of_adjoint_invariant`
5. `orthogonalComplement_reducing_of_normal`
6. finite-dimensional complex operator has an eigenvalue
7. finite-dimensional complex operator has nontrivial invariant subspace
8. nonzero compact operator has nonzero eigenvalue
9. compact operator has nontrivial closed invariant subspace
10. self-adjoint / normal operator has nontrivial closed invariant subspace

This is the right architecture: small reusable lemmas leading to landmark theorems.

### Cross-Domain Connections

Do not leave this in pure operator theory. Make the bridge explicit.

#### Quantum mechanics
Normal and self-adjoint operators model observables and unitary evolutions. Invariant/reducing subspaces correspond to superselection sectors, stable measurement subspaces, and decomposition of state space into dynamically meaningful components.

#### Dynamical systems / Koopman theory
Invariant subspaces of operators encode coherent structures and mode decompositions. A Lean-certified invariant-subspace library becomes a formal basis for spectral analysis of dynamical systems.

#### Control theory
Closed invariant subspaces are the language of controllability/observability decompositions. Formalized Hilbert-space invariant subspace theory points toward certified infinite-dimensional systems theory.

#### Numerical analysis
Compact self-adjoint operators govern PDE eigenproblems. Formal proofs about eigenspaces and spectral projections support certified finite-element spectral approximation.

#### Machine learning / kernel methods
Compact operators appear as covariance and integral operators in RKHS theory. Invariant subspaces correspond to principal modes, kernel PCA, and stable feature decomposition.

### How to Build on Catalog Theorems

The current catalog theorems are not directly in operator theory, but use them philosophically and structurally, not superficially.

- `finite_core_of_totally_bounded` is the most relevant conceptual bridge: compact operators send bounded sets to relatively compact/totally bounded images. Use this as inspiration for finite-approximation arguments around compactness.
- `feasibleChannelSet_bounded` suggests a style for proving boundedness of structured sets; adapt that discipline when defining spectral candidate sets or invariant families.
- `exists_bounded_cycle_mean_le` is a graph/dynamical systems bridge: invariant subspaces can be viewed as stable recurrent modes of linear dynamics. This should motivate a future operator/dynamics bridge theorem.
- The other trivial theorems are not mathematically substantive here; do not force them unnaturally. The correct move is to note the catalog is sparse in functional analysis and to establish a new core.

### Counterexample Discipline

You should explicitly refute at least one tempting but false intermediate conjecture, if it arises. Examples:

- “Every bounded operator on a complex Hilbert space has an eigenvalue.” False.
- “Every invariant subspace arises as an eigenspace.” False.
- “Compactness is unnecessary in the non-normal proof architecture.” Likely too optimistic for current formalization.

Formalizing one simple counterexample would be valuable, e.g. the unilateral shift on `ℓ²(ℕ)` has no eigenvalues in the usual sense for some spectral regions, yet has invariant subspaces. This clarifies that eigenvalue-based proofs do not capture the full phenomenon.

A possible target:

```lean
theorem unilateralShift_has_no_eigenvalue_outside_closedUnitBall : ...
```

or even a finite-dimensional analogue refuting an overstrong eigenspace claim if `ℓ²` infrastructure is not ready.

### Application Keywords

`operator theory`, `Hilbert space`, `compact operator`, `normal operator`, `self-adjoint operator`, `spectral theorem`, `eigenspace`, `closed invariant subspace`, `reducing subspace`, `quantum mechanics`, `Koopman operator`, `control theory`, `kernel methods`, `PDE spectral approximation`, `formal functional analysis`

### Deliverable Priorities

1. **Lean file proving finite-dimensional invariant subspace theorem over `ℂ`.**
2. **Lean file defining invariant/reducing closed subspaces and proving eigenspace invariance/closedness.**
3. **Lean file proving compact operator ⇒ nontrivial closed invariant subspace.**
4. **Lean file proving self-adjoint/normal operator ⇒ nontrivial closed invariant subspace, at least in a strong special case if full generality is blocked.**
5. **A short note documenting any missing Mathlib dependencies and exact blockers.**

### Required FUTURE_DIRECTIONS.md

Produce `FUTURE_DIRECTIONS.md` with **3–5 testable scientific hypotheses**, each a precise falsifiable conjecture with a clear test. They must not be vague. Suggested examples:

1. **Hypothesis: hyperinvariant compact theorem formalization**
   - Conjecture: every non-scalar compact operator on an infinite-dimensional complex Hilbert space admits a nontrivial closed hyperinvariant subspace.
   - Test: formalize commutant-invariance definitions and prove the theorem for compact normal operators first; attempt extension to all compact operators.

2. **Hypothesis: spectral projection API suffices for normal invariant subspaces**
   - Conjecture: current Mathlib spectral APIs can support a proof that every bounded normal operator on a complex Hilbert space with nontrivial spectrum admits a nontrivial reducing subspace.
   - Test: implement Borel/spectral projection construction for at least one nontrivial clopen spectral partition.

3. **Hypothesis: unilateral shift counterexample infrastructure**
   - Conjecture: Mathlib can formalize the unilateral shift on `ℓ²(ℕ)` and prove it has no eigenvalues of modulus greater than `1`, while exhibiting explicit invariant subspaces.
   - Test: define the shift, compute candidate eigenvector recurrence, and certify the contradiction in `ℓ²`.

4. **Hypothesis: compact-operator spectral approximation bridge**
   - Conjecture: finite-rank approximation lemmas plus norm convergence are sufficient to certify approximate spectral subspaces for compact self-adjoint operators.
   - Test: prove convergence of Ritz/Galerkin-type invariant subspaces in a restricted setting.

5. **Hypothesis: operator-theoretic control decomposition**
   - Conjecture: the formal invariant-subspace framework can be repurposed to prove a Hilbert-space version of a controllability/observability decomposition for bounded linear systems.
   - Test: define reachable/observable closed subspaces and prove invariance properties under system operators.

### Final Directive

Be bold but exact. The general invariant subspace problem is not the theorem to fake; it is the horizon that should organize the work. The actual mission is to formalize the strongest classical positive territory with reusable infrastructure, prove landmark theorems for compact and normal operators, and leave behind a certified operator-theoretic platform that makes the next cycle dramatically stronger.

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
