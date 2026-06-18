
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: This cycle isolated the *mathematical kernel* of why anyon braiding is a
**Domain**: Applications
**Mathematical framing**: # Future Directions — Topological Quantum Computing: Braiding Universality

## Synthesis

This cycle isolated the *mathematical kernel* of why anyon braiding is a
universal model of quantum computation, and split that claim into a provable
algebraic part and a provable number-theoretic part, with the genuinely hard
geometric part cleanly quarantined as a conjecture. On the algebraic side we
formalized the reduced **Burau representation** of the three-strand braid group
`B₃` — the linear skeleton from which the **Jones polynomial** is extracted as a
normalized Markov trace — and proved it satisfies the defining **Yang–Baxter /
braid relation** `σ₁σ₂σ₁ = σ₂σ₁σ₂` for *every* value of the loop parameter `t`,
together with invertibility (`det = -t`). The braid relation is a polynomial
identity in `t`, which is precisely why the Jones invariant is a Laurent
polynomial rather than a single number.

On the analytic/number-theoretic side we proved the sharp universality
dichotomy on the maximal torus: the orbit of a phase gate `exp(2πiθ)` is dense
in the phase circle **iff** `θ` is irrational (`phaseGate_orbit_dense`). The
decisive structural insight — and the most important note for the next team — is
that *universality is a number-theoretic property of the phase, not a topological
one*: the very same lemma (`AddCircle.denseRange_zsmul_coe_iff`) that produces
density for irrational phases produces its **failure** for the Fibonacci anyon
eigenphase `4/5` (`fibonacci_phase_not_dense`). This is the Critic's
counterexample, and it is conceptually load-bearing: a *single* braiding phase
can never be universal, so full universality must come from the
**non-commutativity** of distinct braids. That is exactly the content we could
not yet close — `su2_braiding_dense`, the existence of two `SU(2)` braid gates
generating a dense subgroup — because Mathlib lacks the classification of closed
subgroups of `SU(2)`. The failure is informative: it pinpoints the single
missing piece of infrastructure that would convert the torus kernel into the
full theorem.

The work bridges three catalog domains — knot theory / braid groups (cf.
`Bridges/CyclotomicKnotSpectra.lean`), quantum information (cf.
`Bridges/QuantumDagger.lean`), and number theory (irrationality) — along the
chain *braiding → linear representation → irrationality → universality*.

## Results Summary

- `burau_braid_relation`: **proved** — the reduced Burau matrices satisfy the
  braid relation for all `t`, establishing a genuine `B₃` representation (the
  Jones-polynomial backbone).
- `burau_det₁`: **proved** — `det σ₁ = -t`, so the first generator is invertible
  for `t ≠ 0` (representation lands in `GL₂`).
- `burau_det₂`: **proved** — `det σ₂ = -t`, the companion invertibility fact.
- `phaseGate_orbit_dense`: **proved** — an irrational braiding phase generates a
  dense orbit on the torus (the one-parameter Solovay–Kitaev kernel).
- `fibonacci_phase_not_dense`: **proved (counterexample)** — the rational
  Fibonacci eigenphase `4/5` has a non-dense orbit, showing pure-phase braiding
  cannot be universal.
- `su2_braiding_dense`: **conjecture** — two `SU(2)` braid gates generate a dense
  subgroup; the missing ingredient is the closed-subgroup classification of
  `SU(2)`.

## Research Directions

### Direction 1: Closed subgroups of `SU(2)` and the density theorem
**Hypothesis**: Every closed subgroup of `SU(2)` that is non-abelian and not
contained in a normalizer of a maximal torus equals all of `SU(2)`; consequently
two generic braid unitaries generate a dense subgroup (`su2_braiding_dense`).
**Test**: Formalize the classification of closed subgroups of the compact group
`SU(2)` (finite groups, tori, their normalizers, and `SU(2)`), then exhibit an
explicit pair `U, V` escaping every proper closed subgroup.
**Why now**: This cycle reduced full universality to exactly this one statement
and showed (`fibonacci_phase_not_dense`) that abelian/finite obstructions are the
only thing standing in the way — so the classification is provably sufficient.
**If true**: Closes the central universality theorem and gives a reusable
`SU(2)` density toolkit for the whole catalog.
**If false**: Would reveal an unexpected exotic closed subgroup, reshaping our
picture of compact-group density.

### Direction 2: Jones polynomial as a Markov trace of Burau words
**Hypothesis**: The normalized weighted trace of the Burau matrix of a braid
word `β`, with the Markov-move normalization, is invariant under both Markov
moves and therefore defines a link invariant equal to the Jones polynomial.
**Test**: Define the trace functional on Burau words and prove invariance under
conjugation (Markov I) and stabilization (Markov II) for `B₃`.
**Why now**: `burau_braid_relation` already gives a well-defined `B₃`
representation, so the trace functional is now expressible; only the two Markov
invariances remain.
**If true**: Yields the first formal Jones polynomial in the catalog, directly
linking to `CyclotomicKnotSpectra.lean`'s Alexander-polynomial machinery.
**If false**: Would expose a normalization error and sharpen the precise
trace weights needed.

### Direction 3: The irrationality dichotomy as a universality classifier
**Hypothesis**: A single-qubit phase gate set `{exp(2πiθ₁), …, exp(2πiθk)}` is
torus-dense iff the `ℚ`-vector space spanned by `1, θ₁, …, θk` has dimension `> 1`
(i.e. some `θᵢ` is irrational relative to the others).
**Test**: Generalize `phaseGate_orbit_dense` from `zmultiples` of one element to
finitely generated subgroups of `AddCircle 1` via `dense_addSubgroupClosure_pair_iff`
and Kronecker's theorem.
**Why now**: The two proved torus results are the `k = 1` instances of this
statement, and Mathlib already has the two-generator density lemma we used.
**If true**: Provides a decidable-flavored criterion for which finite gate sets
are universal on the torus.
**If false**: Pinpoints a phase configuration that is dense without satisfying
the dimension criterion, refining Kronecker's theorem in the circle setting.

### Direction 4: Burau at roots of unity and finite-order braiding
**Hypothesis**: When `t = exp(2πi/n)` the Burau image of `B₃` is a *finite*
group, and its order is a computable function of `n` (matching the finite anyon
models such as Ising at `n = 4`).
**Test**: For small `n`, compute the order of the group generated by
`burauSigma₁ t, burauSigma₂ t` and prove finiteness via a finite invariant
lattice; contrast with the irrational-phase dense case.
**Why now**: `fibonacci_phase_not_dense` already exhibits the finite-order
phenomenon on the torus; the Burau picture lets us see it at the full
non-abelian level.
**If true**: Cleanly separates universal (`SU(2)`-dense) from non-universal
(finite, e.g. Ising) anyon models inside one formal framework.
**If false**: Reveals a root-of-unity value at which Burau is unexpectedly
infinite, an interesting representation-theoretic anomaly.

### Direction 5: Quantitative Solovay–Kitaev approximation rate
**Hypothesis**: For irrational `θ` with bounded continued-fraction
coefficients, the phase-gate orbit `{n • θ}` approximates any target phase to
accuracy `ε` using `O(1/ε)` braids (linear, beating the generic `polylog(1/ε)`
geometric Solovay–Kitaev bound on the torus).
**Test**: Combine `phaseGate_orbit_dense` with the three-distance (Steinhaus)
theorem to bound gap sizes of `{n • θ}` and extract an explicit word-length
bound.
**Why now**: Density alone (this cycle) gives existence; the next quantitative
step is exactly the gap-structure of the same orbit, for which Mathlib's
equidistribution tools are available.
**If true**: First formal *quantitative* universality estimate, turning an
existence theorem into an algorithmically meaningful bound.
**If false**: Would identify phases where approximation is provably slower,
mapping the boundary of efficient compilation.

**Concept description**: # Future Directions — Topological Quantum Computing: Braiding Universality

## Synthesis

This cycle isolated the *mathematical kernel* of why anyon braiding is a
universal model of quantum computation, and split that claim into a provable
algebraic part and a provable number-theoretic part, with the genuinely hard
geometric part cleanly quarantined as a conjecture. On the algebraic side we
formalized the reduced **Burau representation** of the three-strand braid group
`B₃` — the linear skeleton from which the **Jones polynomial** is extracted as a
normalized Markov trace — and proved it satisfies the defining **Yang–Baxter /
braid relation** `σ₁σ₂σ₁ = σ₂σ₁σ₂` for *every* value of the loop parameter `t`,
together with invertibility (`det = -t`). The braid relation is a polynomial
identity in `t`, which is precisely why the Jones invariant is a Laurent
polynomial rather than a single number.

On the analytic/number-theoretic side we proved the sharp universality
dichotomy on the maximal torus: the orbit of a phase gate `exp(2πiθ)` is dense
in the phase circle **iff** `θ` is irrational (`phaseGate_orbit_dense`). The
decisive structural insight — and the most important note for the next team — is
that *universality is a number-theoretic property of the phase, not a topological
one*: the very same lemma (`AddCircle.denseRange_zsmul_coe_iff`) that produces
density for irrational phases produces its **failure** for the Fibonacci anyon
eigenphase `4/5` (`fibonacci_phase_not_dense`). This is the Critic's
counterexample, and it is conceptually load-bearing: a *single* braiding phase
can never be universal, so full universality must come from the
**non-commutativity** of distinct braids. That is exactly the content we could
not yet close — `su2_braiding_dense`, the existence of two `SU(2)` braid gates
generating a dense subgroup — because Mathlib lacks the classification of closed
subgroups of `SU(2)`. The failure is informative: it pinpoints the single
missing piece of infrastructure that would convert the torus kernel into the
full theorem.

The work bridges three catalog domains — knot theory / braid groups (cf.
`Bridges/CyclotomicKnotSpectra.lean`), quantum information (cf.
`Bridges/QuantumDagger.lean`), and number theory (irrationality) — along the
chain *braiding → linear representation → irrationality → universality*.

## Results Summary

- `burau_braid_relation`: **proved** — the reduced Burau matrices satisfy the
  braid relation for all `t`, establishing a genuine `B₃` representation (the
  Jones-polynomial backbone).
- `burau_det₁`: **proved** — `det σ₁ = -t`, so the first generator is invertible
  for `t ≠ 0` (representation lands in `GL₂`).
- `burau_det₂`: **proved** — `det σ₂ = -t`, the companion invertibility fact.
- `phaseGate_orbit_dense`: **proved** — an irrational braiding phase generates a
  dense orbit on the torus (the one-parameter Solovay–Kitaev kernel).
- `fibonacci_phase_not_dense`: **proved (counterexample)** — the rational
  Fibonacci eigenphase `4/5` has a non-dense orbit, showing pure-phase braiding
  cannot be universal.
- `su2_braiding_dense`: **conjecture** — two `SU(2)` braid gates generate a dense
  subgroup; the missing ingredient is the closed-subgroup classification of
  `SU(2)`.

## Research Directions

### Direction 1: Closed subgroups of `SU(2)` and the density theorem
**Hypothesis**: Every closed subgroup of `SU(2)` that is non-abelian and not
contained in a normalizer of a maximal torus equals all of `SU(2)`; consequently
two generic braid unitaries generate a dense subgroup (`su2_braiding_dense`).
**Test**: Formalize the classification of closed subgroups of the compact group
`SU(2)` (finite groups, tori, their normalizers, and `SU(2)`), then exhibit an
explicit pair `U, V` escaping every proper closed subgroup.
**Why now**: This cycle reduced full universality to exactly this one statement
and showed (`fibonacci_phase_not_dense`) that abelian/finite obstructions are the
only thing standing in the way — so the classification is provably sufficient.
**If true**: Closes the central universality theorem and gives a reusable
`SU(2)` density toolkit for the whole catalog.
**If false**: Would reveal an unexpected exotic closed subgroup, reshaping our
picture of compact-group density.

### Direction 2: Jones polynomial as a Markov trace of Burau words
**Hypothesis**: The normalized weighted trace of the Burau matrix of a braid
word `β`, with the Markov-move normalization, is invariant under both Markov
moves and therefore defines a link invariant equal to the Jones polynomial.
**Test**: Define the trace functional on Burau words and prove invariance under
conjugation (Markov I) and stabilization (Markov II) for `B₃`.
**Why now**: `burau_braid_relation` already gives a well-defined `B₃`
representation, so the trace functional is now expressible; only the two Markov
invariances remain.
**If true**: Yields the first formal Jones polynomial in the catalog, directly
linking to `CyclotomicKnotSpectra.lean`'s Alexander-polynomial machinery.
**If false**: Would expose a normalization error and sharpen the precise
trace weights needed.

### Direction 3: The irrationality dichotomy as a universality classifier
**Hypothesis**: A single-qubit phase gate set `{exp(2πiθ₁), …, exp(2πiθk)}` is
torus-dense iff the `ℚ`-vector space spanned by `1, θ₁, …, θk` has dimension `> 1`
(i.e. some `θᵢ` is irrational relative to the others).
**Test**: Generalize `phaseGate_orbit_dense` from `zmultiples` of one element to
finitely generated subgroups of `AddCircle 1` via `dense_addSubgroupClosure_pair_iff`
and Kronecker's theorem.
**Why now**: The two proved torus results are the `k = 1` instances of this
statement, and Mathlib already has the two-generator density lemma we used.
**If true**: Provides a decidable-flavored criterion for which finite gate sets
are universal on the torus.
**If false**: Pinpoints a phase configuration that is dense without satisfying
the dimension criterion, refining Kronecker's theorem in the circle setting.

### Direction 4: Burau at roots of unity and finite-order braiding
**Hypothesis**: When `t = exp(2πi/n)` the Burau image of `B₃` is a *finite*
group, and its order is a computable function of `n` (matching the finite anyon
models such as Ising at `n = 4`).
**Test**: For small `n`, compute the order of the group generated by
`burauSigma₁ t, burauSigma₂ t` and prove finiteness via a finite invariant
lattice; contrast with the irrational-phase dense case.
**Why now**: `fibonacci_phase_not_dense` already exhibits the finite-order
phenomenon on the torus; the Burau picture lets us see it at the full
non-abelian level.
**If true**: Cleanly separates universal (`SU(2)`-dense) from non-universal
(finite, e.g. Ising) anyon models inside one formal framework.
**If false**: Reveals a root-of-unity value at which Burau is unexpectedly
infinite, an interesting representation-theoretic anomaly.

### Direction 5: Quantitative Solovay–Kitaev approximation rate
**Hypothesis**: For irrational `θ` with bounded continued-fraction
coefficients, the phase-gate orbit `{n • θ}` approximates any target phase to
accuracy `ε` using `O(1/ε)` braids (linear, beating the generic `polylog(1/ε)`
geometric Solovay–Kitaev bound on the torus).
**Test**: Combine `phaseGate_orbit_dense` with the three-distance (Steinhaus)
theorem to bound gap sizes of `{n • θ}` and extract an explicit word-length
bound.
**Why now**: Density alone (this cycle) gives existence; the next quantitative
step is exactly the gap-structure of the same orbit, for which Mathlib's
equidistribution tools are available.
**If true**: First formal *quantitative* universality estimate, turning an
existence theorem into an algorithmically meaningful bound.
**If false**: Would identify phases where approximation is provably slower,
mapping the boundary of efficient compilation.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v13 Depth Requirements -- First-Principles Grounding Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **First-Principles Grounding**. Focus on elegance, structural simplicity, and building blocks of deep theories.

### RESEARCH CORE METHODOLOGY:
1. **Foundational Clarity**: Build theories starting from clean, minimal, first-principles assumptions. Keep definitions mathematically pure, elegant, and simple.
2. **Lemma Factorization**: Decompose large, complex theorems into a hierarchy of beautiful, standalone, reusable lemmas. Each lemma should be a complete mathematical statement of independent interest.
3. **Explanatory Elegance**: Design proofs that are not only correct but structurally beautiful and easy to understand. Let the proofs explain the mathematical mechanism.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
