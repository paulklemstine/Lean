
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

**Title**: The grand conjecture — that spectral form factors of modular quantum graphs carr
**Domain**: Applications
**Mathematical framing**: # Future Directions — Arithmetic Holography via Prime Geodesic Echoes on Modular Quantum Graphs

## Synthesis

The grand conjecture — that spectral form factors of modular quantum graphs carry echoes
of the Riemann zeta zeros beyond random-matrix universality — is, as stated, far beyond
present formalization. Our strategy was to isolate its *unconditional provable kernel* and
prove that kernel completely in Lean 4, so that the next cycle can build upward from solid
ground rather than sideways into folklore.

Three rigid facts emerged, and together they pin down *where* arithmetic must enter:

1. **The spectral form factor is nothing but a pair sum of eigenvalue gaps.**
   `sff_echo_decomposition` proves `SFF(μ, t) = ∑_{j,k} cos(t (μⱼ − μₖ))`. Every
   oscillatory ("echo") component is an eigenvalue *difference*. There is no hidden
   spectral information — the SFF is a transparent functional of the gap multiset.

2. **Spectral moments count closed geodesics.** `trace_pow_eq_sum_eigenvalues` /
   `closedWalks_eq_sum_eigenvalues` give `∑ᵢ μᵢ^k = trace(A^k) = #{closed length-k walks}`.
   This is the elementary trace formula: short closed geodesics ↔ low spectral moments.

3. **Modular graphs have arithmetic spectra.** `cayley_eigenvector` proves that on any
   finite abelian group every additive character `ψ` is an eigenvector of the Cayley
   adjacency operator, with eigenvalue the finite Fourier/Gauss sum `∑ₛ c(s) ψ(s)`.

Composing (1) and (3): the SFF frequencies of a modular (Cayley) graph are *differences of
character sums*. The arithmetic content of the conjecture is therefore localized exactly at
the bridge between (3) and (1).

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `sff_nonneg` | `0 ≤ SFF(μ,t)` | ✅ proved |
| `sff_zero` | `SFF(μ,0) = n²` | ✅ proved |
| `sff_echo_decomposition` | `SFF(μ,t) = ∑_{j,k} cos(t(μⱼ−μₖ))` | ✅ proved |
| `trace_pow_eq_sum_eigenvalues` | `trace(A^k) = ∑ᵢ μᵢ^k` (Hermitian) | ✅ proved |
| `closedWalks_eq_sum_eigenvalues` | closed-walk count = `k`-th power sum | ✅ proved |
| `cayley_eigenvector` / `cayley_hasEigenvalue` | characters diagonalize Cayley graphs | ✅ proved |

All depend only on `propext`, `Classical.choice`, `Quot.sound`. Zero `sorry`.

## Research Directions

### 1. Gauss-sum modulus law for prime-level modular graphs
For `G = ZMod p` with `p` prime and connection weights `c` supported on the quadratic
residues, the character eigenvalues `∑ₛ c(s) ψₐ(s)` become quadratic Gauss sums, whose
modulus is exactly `√p` for `a ≠ 0`. **The key insight is** that this is the finite,
unconditional avatar of "square-root cancellation" — the same phenomenon the zeta
conjecture invokes asymptotically — and it is fully provable from `cayley_eigenvector`
plus Mathlib's `gaussSum` API. *Why now?* We already have the eigenvector bridge formalized
and Mathlib carries `ZMod`, `quadraticChar`, and `gaussSum_sq`; the only missing step is
specializing `cayleyEigenvalue` to the residue indicator, which is a direct computation.

### 2. Ramp–plateau dichotomy for the averaged spectral form factor
Conjecture: for any spectrum with distinct eigenvalues, the long-time average
`lim_{T→∞} (1/T)∫₀ᵀ SFF(μ,t) dt = n` (the "plateau"), separating cleanly from the `t=0`
value `n²`. **The key insight is** that `sff_echo_decomposition` already reduces this to the
statement that each off-diagonal `cos(t(μⱼ−μₖ))` time-averages to zero while the `n`
diagonal terms survive — a pure equidistribution fact, not a physical assumption.
*Why now?* The decomposition theorem hands us the exact integrand termwise; Mathlib's
`Real.cos` integrability and average lemmas close the off-diagonal terms, making this a
finite, falsifiable target rather than a heuristic.

### 3. Character orthogonality ⇒ full diagonalization and a Plancherel SFF
The single eigenvector theorem should be upgraded to a full spectral decomposition: the `n`
characters of a finite abelian group form an orthogonal eigenbasis of every Cayley operator,
giving `SFF` a closed form purely in terms of `{cayleyEigenvalue c ψ}`. **The key insight
is** that Cayley operators over abelian groups are *simultaneously* diagonalized by the
character basis independent of `c`, so the whole family is a commutative von-Neumann-style
algebra and the SFF becomes a Plancherel sum over the dual group. *Why now?* Mathlib's
`AddChar` orthogonality relations (`AddChar.sum_eq_zero_of_ne` style) are already available,
so promoting `cayley_eigenvector` to a basis statement is incremental, not foundational.

### 4. Stability of echo frequencies under congruence-level refinement
Conjecture: as one passes from `ZMod N` to `ZMod (N·M)` with a compatible connection set,
a distinguished subset of eigenvalue gaps is *preserved* (scale-stable echoes), realized via
the projection `ZMod (N·M) → ZMod N` and pullback of characters. **The key insight is** that
character pullback along a quotient map embeds the level-`N` spectrum inside the level-`NM`
spectrum, giving a literal, finite-dimensional mechanism for "scale-stable oscillatory
components" without invoking universality. *Why now?* `ZMod.castHom` and the induced
`AddChar` comap are in Mathlib, so the inclusion of spectra is a concrete lemma we can state
and attack immediately, turning the vague "persistence across levels" into a theorem.

### 5. Null-model separation: random-circulant SFF concentration
To make the conjecture falsifiable we need the *null* side: for connection weights `c`
drawn i.i.d. with mean zero, the expected SFF equals the diagonal `n` plus a vanishing
off-diagonal contribution, i.e. random modular graphs show *no* persistent echoes. **The
key insight is** that `sff_echo_decomposition` turns this into a statement about
`E[cos(t(μⱼ−μₖ))]` for random character sums, which factorizes through independence and is
amenable to second-moment bounds. *Why now?* With the deterministic decomposition proved,
the probabilistic null model is a clean add-on using Mathlib's `ProbabilityTheory` variance
machinery, giving the contrast (signal vs. null) that the original test demands.

**Concept description**: # Future Directions — Arithmetic Holography via Prime Geodesic Echoes on Modular Quantum Graphs

## Synthesis

The grand conjecture — that spectral form factors of modular quantum graphs carry echoes
of the Riemann zeta zeros beyond random-matrix universality — is, as stated, far beyond
present formalization. Our strategy was to isolate its *unconditional provable kernel* and
prove that kernel completely in Lean 4, so that the next cycle can build upward from solid
ground rather than sideways into folklore.

Three rigid facts emerged, and together they pin down *where* arithmetic must enter:

1. **The spectral form factor is nothing but a pair sum of eigenvalue gaps.**
   `sff_echo_decomposition` proves `SFF(μ, t) = ∑_{j,k} cos(t (μⱼ − μₖ))`. Every
   oscillatory ("echo") component is an eigenvalue *difference*. There is no hidden
   spectral information — the SFF is a transparent functional of the gap multiset.

2. **Spectral moments count closed geodesics.** `trace_pow_eq_sum_eigenvalues` /
   `closedWalks_eq_sum_eigenvalues` give `∑ᵢ μᵢ^k = trace(A^k) = #{closed length-k walks}`.
   This is the elementary trace formula: short closed geodesics ↔ low spectral moments.

3. **Modular graphs have arithmetic spectra.** `cayley_eigenvector` proves that on any
   finite abelian group every additive character `ψ` is an eigenvector of the Cayley
   adjacency operator, with eigenvalue the finite Fourier/Gauss sum `∑ₛ c(s) ψ(s)`.

Composing (1) and (3): the SFF frequencies of a modular (Cayley) graph are *differences of
character sums*. The arithmetic content of the conjecture is therefore localized exactly at
the bridge between (3) and (1).

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `sff_nonneg` | `0 ≤ SFF(μ,t)` | ✅ proved |
| `sff_zero` | `SFF(μ,0) = n²` | ✅ proved |
| `sff_echo_decomposition` | `SFF(μ,t) = ∑_{j,k} cos(t(μⱼ−μₖ))` | ✅ proved |
| `trace_pow_eq_sum_eigenvalues` | `trace(A^k) = ∑ᵢ μᵢ^k` (Hermitian) | ✅ proved |
| `closedWalks_eq_sum_eigenvalues` | closed-walk count = `k`-th power sum | ✅ proved |
| `cayley_eigenvector` / `cayley_hasEigenvalue` | characters diagonalize Cayley graphs | ✅ proved |

All depend only on `propext`, `Classical.choice`, `Quot.sound`. Zero `sorry`.

## Research Directions

### 1. Gauss-sum modulus law for prime-level modular graphs
For `G = ZMod p` with `p` prime and connection weights `c` supported on the quadratic
residues, the character eigenvalues `∑ₛ c(s) ψₐ(s)` become quadratic Gauss sums, whose
modulus is exactly `√p` for `a ≠ 0`. **The key insight is** that this is the finite,
unconditional avatar of "square-root cancellation" — the same phenomenon the zeta
conjecture invokes asymptotically — and it is fully provable from `cayley_eigenvector`
plus Mathlib's `gaussSum` API. *Why now?* We already have the eigenvector bridge formalized
and Mathlib carries `ZMod`, `quadraticChar`, and `gaussSum_sq`; the only missing step is
specializing `cayleyEigenvalue` to the residue indicator, which is a direct computation.

### 2. Ramp–plateau dichotomy for the averaged spectral form factor
Conjecture: for any spectrum with distinct eigenvalues, the long-time average
`lim_{T→∞} (1/T)∫₀ᵀ SFF(μ,t) dt = n` (the "plateau"), separating cleanly from the `t=0`
value `n²`. **The key insight is** that `sff_echo_decomposition` already reduces this to the
statement that each off-diagonal `cos(t(μⱼ−μₖ))` time-averages to zero while the `n`
diagonal terms survive — a pure equidistribution fact, not a physical assumption.
*Why now?* The decomposition theorem hands us the exact integrand termwise; Mathlib's
`Real.cos` integrability and average lemmas close the off-diagonal terms, making this a
finite, falsifiable target rather than a heuristic.

### 3. Character orthogonality ⇒ full diagonalization and a Plancherel SFF
The single eigenvector theorem should be upgraded to a full spectral decomposition: the `n`
characters of a finite abelian group form an orthogonal eigenbasis of every Cayley operator,
giving `SFF` a closed form purely in terms of `{cayleyEigenvalue c ψ}`. **The key insight
is** that Cayley operators over abelian groups are *simultaneously* diagonalized by the
character basis independent of `c`, so the whole family is a commutative von-Neumann-style
algebra and the SFF becomes a Plancherel sum over the dual group. *Why now?* Mathlib's
`AddChar` orthogonality relations (`AddChar.sum_eq_zero_of_ne` style) are already available,
so promoting `cayley_eigenvector` to a basis statement is incremental, not foundational.

### 4. Stability of echo frequencies under congruence-level refinement
Conjecture: as one passes from `ZMod N` to `ZMod (N·M)` with a compatible connection set,
a distinguished subset of eigenvalue gaps is *preserved* (scale-stable echoes), realized via
the projection `ZMod (N·M) → ZMod N` and pullback of characters. **The key insight is** that
character pullback along a quotient map embeds the level-`N` spectrum inside the level-`NM`
spectrum, giving a literal, finite-dimensional mechanism for "scale-stable oscillatory
components" without invoking universality. *Why now?* `ZMod.castHom` and the induced
`AddChar` comap are in Mathlib, so the inclusion of spectra is a concrete lemma we can state
and attack immediately, turning the vague "persistence across levels" into a theorem.

### 5. Null-model separation: random-circulant SFF concentration
To make the conjecture falsifiable we need the *null* side: for connection weights `c`
drawn i.i.d. with mean zero, the expected SFF equals the diagonal `n` plus a vanishing
off-diagonal contribution, i.e. random modular graphs show *no* persistent echoes. **The
key insight is** that `sff_echo_decomposition` turns this into a statement about
`E[cos(t(μⱼ−μₖ))]` for random character sums, which factorizes through independence and is
amenable to second-moment bounds. *Why now?* With the deterministic decomposition proved,
the probabilistic null model is a clean add-on using Mathlib's `ProbabilityTheory` variance
machinery, giving the contrast (signal vs. null) that the original test demands.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v14 Depth Requirements -- Conceptual Unifier: Local-to-Global Sheaves Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Local-to-Global Sheaves)**. Explore sheaf theory, local-to-global translations, and cohomological obstructions.

### RESEARCH CORE METHODOLOGY:
1. **Local-to-Global Translation**: Construct sheaves or presheaves to describe local properties that glue together to form global structures. Check if local solutions can be extended globally.
2. **Obstruction Theory & Cohomology**: Use cohomology groups or obstruction classes to mathematically measure the failure or boundaries of local-to-global extensions.
3. **Stalk-Level Reduction**: Reduce complex global proofs to stalk-level computations or local neighborhood verifications, using algebraic localization or geometric limits.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
