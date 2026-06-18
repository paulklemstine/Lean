            # Phase A Research Mission v16a: Self-contained Mathlib foundation for the discrete Hodg

            ## Concept
            **Domain**: Novelty
            **Research mode**: team
            **Title**: Self-contained Mathlib foundation for the discrete Hodg
            **Description**: # FUTURE DIRECTIONS — Discrete Hodge ↔ Probability

This cycle established a self-contained Mathlib foundation for the discrete Hodge
program on finite weighted graphs and bridged it to the probability of reversible
random walks (file `Catalog/Bridges/DiscreteHodgeRandomWalk.lean`).

Proved this cycle:
- Dirichlet energy identity `xᵀ L x = ½ Σᵢⱼ wᵢⱼ (xᵢ − xⱼ)²`.
- Positive semidefiniteness of the combinatorial Laplacian `L = D − A`.
- Symmetry of `L`, zero row-sums, and harmonicity of constants.
- Detailed balance / reversibility of `P = D⁻¹A` w.r.t. the degree measure
  (stated *unconditionally* using totality of real division).
- The factorization `L f = D(f − Pf)` and the bridge theorem:
  at a positive-degree vertex, `(L f) i = 0 ⟺ (P f) i = f i`
  (discrete harmonic forms = walk-invariant functions).

The following conjectures are bold, precise, and testable in subsequent cycles.

## C1 — Kernel of `L` = locally constant functions (connectivity ⇒ 0th Hodge number)
For a finite weighted graph whose positive-weight relation is connected,
`L.mulVec f = 0 ↔ f` is constant. More generally, `dim ker L` equals the number
of connected components of the support graph. This is the discrete `H⁰` and the
0th Betti number; it is the natural next theorem after `laplacian_mulVec_const`
and `quadForm_nonneg` (the energy `½ Σ wᵢⱼ(fᵢ−fⱼ)²` vanishes iff `f` is constant
on each component).

## C2 — Spectral gap ⇒ exponential mixing of the reversible walk
Let `0 = λ₀ ≤ λ₁ ≤ … ` be the eigenvalues of the *normalized* Laplacian
`𝓛 = I − D^{-1/2} A D^{-1/2}`. Conjecture: for a connected graph with
`λ₁ > 0`, the reversible walk `P` satisfies a Poincaré inequality
`Var_π(f) ≤ (1/λ₁) · 𝓔(f, f)` (Dirichlet form), hence `Lᵖ` mixing
`‖Pᵗf − π(f)‖ ≤ (1 − λ₁)ᵗ ‖f‖`. This connects the Hodge spectrum directly to
the probabilistic convergence rate; the Dirichlet identity proved here is the
exact `𝓔(f,f)` appearing in the inequality.

## C3 — Discrete Hodge decomposition `ℝ^V = ker L ⊕ im L`
Because `L` is symmetric PSD, `ℝ^V` orthogonally decomposes as
`ker L ⊕ range L`, with `ker L` the harmonic part and `range L` the "exact +
co-exact" part. Conjecture (and formalize): every function uniquely splits as
`f = h + Lg` with `h` harmonic, and `h` is the orthogonal projection minimizing
Dirichlet energy among representatives of `f mod range L`. This is the finite-
dimensional Hodge theorem; it needs only `Matrix.IsSymm` + PSD already proved.

## C4 — Reversibility characterizes self-adjointness of `P` in the `π`-inner product
Conjecture: a stochastic kernel `P` on `Fin n` is reversible w.r.t. a positive
measure `π` (`πᵢ Pᵢⱼ = πⱼ Pⱼᵢ`) **iff** `P` is self-adjoint for the weighted
inner product `⟨f,g⟩_π = Σ πᵢ fᵢ gᵢ`, **iff** `P` arises from some symmetric
weight kernel `w` via `wᵢⱼ = πᵢ Pᵢⱼ`. This upgrades `reversible` from a property
of graph-derived walks to a full equivalence, identifying "reversible Markov
chain" with "weighted graph" canonically.

## C5 — Effective resistance is a metric, and a graph-Green's-function identity
Define effective resistance `R(i,j)` via the energy-minimizing `g` with
`L g = eᵢ − eⱼ` (well-defined on connected graphs by C3). Conjecture:
`R` is a metric on vertices (the "resistance metric"), `R(i,j) = (eᵢ−eⱼ)ᵀ L⁺ (eᵢ−eⱼ)`
with `L⁺` the Moore–Penrose pseudoinverse, and it equals the expected commute
time of the reversible walk up to the factor `2·(total weight)`. This is the
deepest probability↔Hodge bridge: the Green's function `L⁺` simultaneously
governs harmonic extension (Hodge) and commute/hitting times (probability).

            **Mathematical framing**: # FUTURE DIRECTIONS — Discrete Hodge ↔ Probability

This cycle established a self-contained Mathlib foundation for the discrete Hodge
program on finite weighted graphs and bridged it to the probability of reversible
random walks (file `Catalog/Bridges/DiscreteHodgeRandomWalk.lean`).

Proved this cycle:
- Dirichlet energy identity `xᵀ L x = ½ Σᵢⱼ wᵢⱼ (xᵢ − xⱼ)²`.
- Positive semidefiniteness of the combinatorial Laplacian `L = D − A`.
- Symmetry of `L`, zero row-sums, and harmonicity of constants.
- Detailed balance / reversibility of `P = D⁻¹A` w.r.t. the degree measure
  (stated *unconditionally* using totality of real division).
- The factorization `L f = D(f − Pf)` and the bridge theorem:
  at a positive-degree vertex, `(L f) i = 0 ⟺ (P f) i = f i`
  (discrete harmonic forms = walk-invariant functions).

The following conjectures are bold, precise, and testable in subsequent cycles.

## C1 — Kernel of `L` = locally constant functions (connectivity ⇒ 0th Hodge number)
For a finite weighted graph whose positive-weight relation is connected,
`L.mulVec f = 0 ↔ f` is constant. More generally, `dim ker L` equals the number
of connected components of the support graph. This is the discrete `H⁰` and the
0th Betti number; it is the natural next theorem after `laplacian_mulVec_const`
and `quadForm_nonneg` (the energy `½ Σ wᵢⱼ(fᵢ−fⱼ)²` vanishes iff `f` is constant
on each component).

## C2 — Spectral gap ⇒ exponential mixing of the reversible walk
Let `0 = λ₀ ≤ λ₁ ≤ … ` be the eigenvalues of the *normalized* Laplacian
`𝓛 = I − D^{-1/2} A D^{-1/2}`. Conjecture: for a connected graph with
`λ₁ > 0`, the reversible walk `P` satisfies a Poincaré inequality
`Var_π(f) ≤ (1/λ₁) · 𝓔(f, f)` (Dirichlet form), hence `Lᵖ` mixing
`‖Pᵗf − π(f)‖ ≤ (1 − λ₁)ᵗ ‖f‖`. This connects the Hodge spectrum directly to
the probabilistic convergence rate; the Dirichlet identity proved here is the
exact `𝓔(f,f)` appearing in the inequality.

## C3 — Discrete Hodge decomposition `ℝ^V = ker L ⊕ im L`
Because `L` is symmetric PSD, `ℝ^V` orthogonally decomposes as
`ker L ⊕ range L`, with `ker L` the harmonic part and `range L` the "exact +
co-exact" part. Conjecture (and formalize): every function uniquely splits as
`f = h + Lg` with `h` harmonic, and `h` is the orthogonal projection minimizing
Dirichlet energy among representatives of `f mod range L`. This is the finite-
dimensional Hodge theorem; it needs only `Matrix.IsSymm` + PSD already proved.

## C4 — Reversibility characterizes self-adjointness of `P` in the `π`-inner product
Conjecture: a stochastic kernel `P` on `Fin n` is reversible w.r.t. a positive
measure `π` (`πᵢ Pᵢⱼ = πⱼ Pⱼᵢ`) **iff** `P` is self-adjoint for the weighted
inner product `⟨f,g⟩_π = Σ πᵢ fᵢ gᵢ`, **iff** `P` arises from some symmetric
weight kernel `w` via `wᵢⱼ = πᵢ Pᵢⱼ`. This upgrades `reversible` from a property
of graph-derived walks to a full equivalence, identifying "reversible Markov
chain" with "weighted graph" canonically.

## C5 — Effective resistance is a metric, and a graph-Green's-function identity
Define effective resistance `R(i,j)` via the energy-minimizing `g` with
`L g = eᵢ − eⱼ` (well-defined on connected graphs by C3). Conjecture:
`R` is a metric on vertices (the "resistance metric"), `R(i,j) = (eᵢ−eⱼ)ᵀ L⁺ (eᵢ−eⱼ)`
with `L⁺` the Moore–Penrose pseudoinverse, and it equals the expected commute
time of the reversible walk up to the factor `2·(total weight)`. This is the
deepest probability↔Hodge bridge: the Green's function `L⁺` simultaneously
governs harmonic extension (Hodge) and commute/hitting times (probability).





### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


            ## v16 Research Core Methodology — Scientific Team Loop

You are the Principal Investigator leading a research team with four
roles: **Hypothesizer**, **Experimenter**, **Analyst**, and **Critic**.
Run the following loop and record notes at each stage.

### Stage 1 — Hypothesize (team: Hypothesizer)
Brainstorm 5–7 falsifiable conjectures about the topic. At least two
must be surprising or counter-intuitive. Rank them by expected
scientific impact, not by ease of proof.

### Stage 2 — Experiment (team: Experimenter)
For each conjecture, attempt to prove it in Lean 4 or disprove it with
a concrete counterexample. Prioritize the most surprising conjectures
first. If a proof is beyond reach, prove the strongest lemma you can
and mark the remaining step with exactly one `sorry` that is clearly
documented.

### Stage 3 — Analyze (team: Analyst)
Summarize what survived, what failed, and **why** failures failed.
Distinguish "true but hard", "false", and "needs a different
definition". These insights are as valuable as the proofs.

### Stage 4 — Critique / Adversarial Review (team: Critic)
Before finalizing, challenge every theorem:
- Is any theorem trivial (True, definitional equality, `native_decide`)?
- Does every main theorem have 0 sorries?
- Do the results genuinely extend the attached catalog files?
- Are there hidden assumptions or corner cases that break the claim?
If you find a weakness, fix it or replace the theorem with a guarded
version and explain the boundary.

### Stage 5 — Synthesize (team: Principal Investigator)
Combine the verified results into clean, compiling Lean 4 files.
Write a `FUTURE_DIRECTIONS.md` that lists 3–5 **bold, testable**
conjectures derived from Stage 3 and Stage 4. Each conjecture must
include a "The key insight is..." sentence and a "Why now?"
justification.

### Extra Adversarial Mandate (v16a)
Every claimed theorem must survive at least one explicit attempted
counterexample in Lean. Report the counterexample search in a Lab
Notes block. If no counterexample exists, briefly explain why the
claim is robust. If a counterexample exists, turn the original claim
into a precise characterization of the boundary case.


            ### Anti-Trivial Guardrails (non-negotiable)
The following are NOT acceptable as main results:
- Theorems of the form `theorem name {X : Type*} [Inhabited X] : True := by trivial`.
- Definition-only theorems or definitional equalities proved by `rfl`.
- Results whose entire proof is `simp`, `norm_num`, `decide`, or `native_decide`.
- Wrapper types that rename existing definitions.
- Re-proving existing catalog theorems with minor notation changes.

Every main theorem must use at least one insight-bearing tactic or
technique such as `induction`, `by_contra`, `field_simp`, `ring_nf`,
`omega`, `linarith`, `rcases`, or a custom helper lemma.


            ### Deliverables & Acceptance Criteria
1. **Lean 4 files** (2–4 files in the appropriate `Catalog/<domain>/` subtree).
   - Main theorems must be fully proved (0 sorries).
   - Each file must contain `-- !-- Lab Notes -- !--` blocks documenting
     the team loop: Hypothesis, Experiment, Analysis, Critique, Synthesis.
2. **FUTURE_DIRECTIONS.md** with 3–5 bold, falsifiable conjectures derived
   from the cycle's findings. Each must have a "The key insight is..."
   sentence and a "Why now?" justification.

### Strictly Forbidden in Phase A
- `ARTICLE.md`, `RESEARCH_PAPER.md`, `demo.py`, HTML widgets, `PACKAGE.json`.
- Prose for human readers other than Lab Notes and FUTURE_DIRECTIONS.md.


            ## Self-Critique Checklist (perform before final output)
            Review your candidate output and answer each item. If the answer is
            unsatisfactory, revise the output before returning it.

            - [ ] No theorem is trivial (True, Inhabited-only, native_decide-only, etc.).
            - [ ] Every main theorem has 0 sorries.
            - [ ] At least one theorem imports or uses results from the attached catalog.
            - [ ] Lab Notes blocks contain real hypotheses, results, insights, and failure analysis.
            - [ ] FUTURE_DIRECTIONS.md conjectures are derived from this cycle's findings.
            - [ ] Every future direction includes a "The key insight is..." sentence and a "Why now?" justification.

            ## Output Format Reminder
            Return `.lean` files and `FUTURE_DIRECTIONS.md` only. Focus all compute
            on the mathematics.
