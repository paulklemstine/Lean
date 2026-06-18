
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by the Plan)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.

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

**Title**: The file `Computation/SpectralChain/Core.lean` builds, from first principles, a
**Domain**: Applications
**Mathematical framing**: # Future Directions: Spectral Chain Framework

## What was established (this cycle)

The file `Computation/SpectralChain/Core.lean` builds, from first principles, a
formally verified bridge across four mathematical domains for **finite reversible
Markov chains**. Every main theorem compiles with `sorry = 0` and depends only on
the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

The cornerstone object is `ReversibleChain`: a stationary distribution `π`, a
stochastic kernel `P`, and detailed balance `π_i P_ij = π_j P_ji`. On top of it we
define the edge weight `weight i j = π_i P_ij`, the stationary `mean`, the `Var`iance,
the `DirichletForm` (energy), the cut flow `flowOut`, the set measure `piSet`, and a
`SpectralGapCert` (a Poincaré certificate `γ · Var(f) ≤ E(f)`).

The proven results form a genuine geometry → spectral → probability chain:

- **`weight_symm`** — detailed balance is exactly symmetry of the edge weight.
- **`Var_eq_double_sum`** — the variance double-sum identity
  `Var(f) = ½ ∑_{i,j} π_i π_j (f_i − f_j)²`.
- **`flowOut_symm`** — the flow out of a cut equals the flow into it.
- **`DirichletForm_indicator` / `Var_indicator`** — for a set indicator the energy is
  the cut flow `flowOut(S)` and the variance collapses to `π(S)(1 − π(S))`.
- **`cheeger_easy_inequality`** — the *easy* direction of the discrete Cheeger
  inequality: any Poincaré gap obeys `γ ≤ 2 · flowOut(S)/π(S)`. This is the key
  cross-domain bridge (geometry controls spectrum).
- **`mixingBound_antitone` / `mixing_diverges_at_zero_gap`** — the spectral-gap mixing
  bound `(1/γ)·log(n/ε)` is antitone in `γ`, and diverges to `+∞` as `γ → 0⁺`: the
  structural phase-transition statement.

A concrete `twoState` chain (`π = (½,½)`, `P ≡ ½`) instantiates the framework with
real numbers, and `cheeger_hard_direction_conjecture` records the shape of the open
hard half of Cheeger's inequality as a `sorry`ed target.

---

## Direction 1: The hard direction of Cheeger's inequality

The framework proves `γ ≤ 2h` (where `h` is the conductance); the missing companion
is `h²/2 ≤ γ`, already stubbed as `cheeger_hard_direction_conjecture`. **The key
insight is** that the proof is not a certificate manipulation at all but a
*construction*: from the eigenfunction realizing the gap one extracts an ordered
level-set sweep, and a discrete co-area identity rewrites `DirichletForm(f)` as an
integral of the cut flows `flowOut({f ≥ t})` over the threshold `t`. Bounding each
level-set conductance below by `h` and applying Cauchy–Schwarz yields the quadratic
loss `h²/2`. **Why now?** The pieces it consumes — `flowOut`, `piSet`,
`DirichletForm`, `Var`, and the `SpectralGapCert` interface — are all in place and
already proven mutually compatible by `DirichletForm_indicator` and `Var_indicator`;
the only genuinely new lemma needed is the finite co-area formula
`DirichletForm(f) = ∑_t flowOut({f ≥ t}) · Δt`, which is a finite telescoping sum.

## Direction 2: Geometric (variance) contraction from the gap

The Poincaré certificate should imply quantitative convergence:
`Var(Pᵗ f) ≤ (1 − γ)^{2t} · Var(f)`, where `P` acts on observables by
`(Pf)(i) = ∑_j P_ij f(j)`. **The key insight is** that reversibility makes `P`
self-adjoint in the weighted inner product `⟨f,g⟩_π = ∑_i π_i f_i g_i`, so the
Dirichlet form is `⟨(I−P)f, f⟩_π` and the Poincaré inequality is precisely the
statement that `I − P` is bounded below by `γ` on the mean-zero subspace; one
contraction step then iterates. **Why now?** `Var`, `mean`, and `DirichletForm` are
defined exactly so that `DirichletForm(f) = ⟨(I−P)f,f⟩_π`; formalizing the weighted
inner-product space `L²(π)` over the finite `V` (a `Finset`-indexed inner product,
fully within current Mathlib) turns the spectral gap into an operator-norm bound and
unlocks the whole self-adjoint finite-dimensional toolkit.

## Direction 3: A log-Sobolev layer above the spectral gap

Mixing under a log-Sobolev constant `α` improves the bound to
`t_mix(ε) ≤ (1/2α)·log log(1/ε)`, a doubly-logarithmic speed-up over the spectral
`(1/γ)·log(n/ε)`. **The key insight is** that `α` and `γ` are *ordered*
(`α ≤ γ ≤ 2α` for product chains), so a `LogSobolevCert` structure — mirroring
`SpectralGapCert` but certifying `Ent(f²·π) ≤ (2/α)·DirichletForm(f)` via the
entropy functional `Ent(g) = ∑_i π_i g_i log g_i − (∑ π_i g_i) log(∑ π_i g_i)` — slots
directly into the existing `mixingBound` comparison machinery. **Why now?**
`mixingBound` and `mixingBound_antitone` already provide the apparatus for comparing
two mixing formulas; the analogue of `mixing_diverges_at_zero_gap` for `α` would
quantify the gap between the two regimes, and the entropy functional needs only
`Real.log` and `Finset.sum`, both already imported.

## Direction 4: Explicit gaps for small constraint-satisfaction chains

The framework currently has one numeric instance (`twoState`). The natural next test
is the swap Markov chain on small grid puzzles — 3×3 Latin squares, 4×4 Shidoku —
whose solution counts (≤ 288 for Shidoku) are tiny. **The key insight is** that for
`n ≤ 4` the transition kernel is an explicit *rational* matrix, so detailed balance,
`piSet`, and `flowOut` are decidable rational computations, and a verified Poincaré
constant can be exhibited as a `SpectralGapCert` whose `poincare` field is discharged
by finite case analysis rather than analysis. **Why now?** `ReversibleChain` and
`SpectralGapCert` are records with purely arithmetic obligations; `twoState` already
demonstrates that the obligations are dischargeable by `norm_num`, so scaling to a
genuine CSP chain is a matter of bookkeeping, and it would yield the framework's
first *non-trivial* numerical conductance / gap pair to plug into
`cheeger_easy_inequality`.

## Direction 5: Tropical lower bounds on the spectral gap

The classical gap is expensive (Cheeger optimizes over exponentially many cuts),
whereas the tropical (min-plus) eigenvalue of a structured non-negative matrix — the
minimum cycle mean — is computable in polynomial time. **The key insight is** that
for CSP transition graphs the min-plus spectral radius lower-bounds the mixing speed
through the same cut structure that `flowOut` already measures, giving combinatorial
gap certificates that bypass the worst-case quadratic loss in Cheeger. **Why now?**
The repository already contains tropical-algebra infrastructure
(`Catalog/Tropical/`, `Catalog/Computation/Spectral.lean` with `minDiag`/`tropPow`
cycle-cost bounds); bridging `ReversibleChain.weight` to a tropical matrix and
relating `minDiag` of its powers to `flowOut` would connect two independent parts of
the codebase and produce a cheap, verified lower bound feeding into a future
`SpectralGapCert`.

**Concept description**: # Future Directions: Spectral Chain Framework

## What was established (this cycle)

The file `Computation/SpectralChain/Core.lean` builds, from first principles, a
formally verified bridge across four mathematical domains for **finite reversible
Markov chains**. Every main theorem compiles with `sorry = 0` and depends only on
the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

The cornerstone object is `ReversibleChain`: a stationary distribution `π`, a
stochastic kernel `P`, and detailed balance `π_i P_ij = π_j P_ji`. On top of it we
define the edge weight `weight i j = π_i P_ij`, the stationary `mean`, the `Var`iance,
the `DirichletForm` (energy), the cut flow `flowOut`, the set measure `piSet`, and a
`SpectralGapCert` (a Poincaré certificate `γ · Var(f) ≤ E(f)`).

The proven results form a genuine geometry → spectral → probability chain:

- **`weight_symm`** — detailed balance is exactly symmetry of the edge weight.
- **`Var_eq_double_sum`** — the variance double-sum identity
  `Var(f) = ½ ∑_{i,j} π_i π_j (f_i − f_j)²`.
- **`flowOut_symm`** — the flow out of a cut equals the flow into it.
- **`DirichletForm_indicator` / `Var_indicator`** — for a set indicator the energy is
  the cut flow `flowOut(S)` and the variance collapses to `π(S)(1 − π(S))`.
- **`cheeger_easy_inequality`** — the *easy* direction of the discrete Cheeger
  inequality: any Poincaré gap obeys `γ ≤ 2 · flowOut(S)/π(S)`. This is the key
  cross-domain bridge (geometry controls spectrum).
- **`mixingBound_antitone` / `mixing_diverges_at_zero_gap`** — the spectral-gap mixing
  bound `(1/γ)·log(n/ε)` is antitone in `γ`, and diverges to `+∞` as `γ → 0⁺`: the
  structural phase-transition statement.

A concrete `twoState` chain (`π = (½,½)`, `P ≡ ½`) instantiates the framework with
real numbers, and `cheeger_hard_direction_conjecture` records the shape of the open
hard half of Cheeger's inequality as a `sorry`ed target.

---

## Direction 1: The hard direction of Cheeger's inequality

The framework proves `γ ≤ 2h` (where `h` is the conductance); the missing companion
is `h²/2 ≤ γ`, already stubbed as `cheeger_hard_direction_conjecture`. **The key
insight is** that the proof is not a certificate manipulation at all but a
*construction*: from the eigenfunction realizing the gap one extracts an ordered
level-set sweep, and a discrete co-area identity rewrites `DirichletForm(f)` as an
integral of the cut flows `flowOut({f ≥ t})` over the threshold `t`. Bounding each
level-set conductance below by `h` and applying Cauchy–Schwarz yields the quadratic
loss `h²/2`. **Why now?** The pieces it consumes — `flowOut`, `piSet`,
`DirichletForm`, `Var`, and the `SpectralGapCert` interface — are all in place and
already proven mutually compatible by `DirichletForm_indicator` and `Var_indicator`;
the only genuinely new lemma needed is the finite co-area formula
`DirichletForm(f) = ∑_t flowOut({f ≥ t}) · Δt`, which is a finite telescoping sum.

## Direction 2: Geometric (variance) contraction from the gap

The Poincaré certificate should imply quantitative convergence:
`Var(Pᵗ f) ≤ (1 − γ)^{2t} · Var(f)`, where `P` acts on observables by
`(Pf)(i) = ∑_j P_ij f(j)`. **The key insight is** that reversibility makes `P`
self-adjoint in the weighted inner product `⟨f,g⟩_π = ∑_i π_i f_i g_i`, so the
Dirichlet form is `⟨(I−P)f, f⟩_π` and the Poincaré inequality is precisely the
statement that `I − P` is bounded below by `γ` on the mean-zero subspace; one
contraction step then iterates. **Why now?** `Var`, `mean`, and `DirichletForm` are
defined exactly so that `DirichletForm(f) = ⟨(I−P)f,f⟩_π`; formalizing the weighted
inner-product space `L²(π)` over the finite `V` (a `Finset`-indexed inner product,
fully within current Mathlib) turns the spectral gap into an operator-norm bound and
unlocks the whole self-adjoint finite-dimensional toolkit.

## Direction 3: A log-Sobolev layer above the spectral gap

Mixing under a log-Sobolev constant `α` improves the bound to
`t_mix(ε) ≤ (1/2α)·log log(1/ε)`, a doubly-logarithmic speed-up over the spectral
`(1/γ)·log(n/ε)`. **The key insight is** that `α` and `γ` are *ordered*
(`α ≤ γ ≤ 2α` for product chains), so a `LogSobolevCert` structure — mirroring
`SpectralGapCert` but certifying `Ent(f²·π) ≤ (2/α)·DirichletForm(f)` via the
entropy functional `Ent(g) = ∑_i π_i g_i log g_i − (∑ π_i g_i) log(∑ π_i g_i)` — slots
directly into the existing `mixingBound` comparison machinery. **Why now?**
`mixingBound` and `mixingBound_antitone` already provide the apparatus for comparing
two mixing formulas; the analogue of `mixing_diverges_at_zero_gap` for `α` would
quantify the gap between the two regimes, and the entropy functional needs only
`Real.log` and `Finset.sum`, both already imported.

## Direction 4: Explicit gaps for small constraint-satisfaction chains

The framework currently has one numeric instance (`twoState`). The natural next test
is the swap Markov chain on small grid puzzles — 3×3 Latin squares, 4×4 Shidoku —
whose solution counts (≤ 288 for Shidoku) are tiny. **The key insight is** that for
`n ≤ 4` the transition kernel is an explicit *rational* matrix, so detailed balance,
`piSet`, and `flowOut` are decidable rational computations, and a verified Poincaré
constant can be exhibited as a `SpectralGapCert` whose `poincare` field is discharged
by finite case analysis rather than analysis. **Why now?** `ReversibleChain` and
`SpectralGapCert` are records with purely arithmetic obligations; `twoState` already
demonstrates that the obligations are dischargeable by `norm_num`, so scaling to a
genuine CSP chain is a matter of bookkeeping, and it would yield the framework's
first *non-trivial* numerical conductance / gap pair to plug into
`cheeger_easy_inequality`.

## Direction 5: Tropical lower bounds on the spectral gap

The classical gap is expensive (Cheeger optimizes over exponentially many cuts),
whereas the tropical (min-plus) eigenvalue of a structured non-negative matrix — the
minimum cycle mean — is computable in polynomial time. **The key insight is** that
for CSP transition graphs the min-plus spectral radius lower-bounds the mixing speed
through the same cut structure that `flowOut` already measures, giving combinatorial
gap certificates that bypass the worst-case quadratic loss in Cheeger. **Why now?**
The repository already contains tropical-algebra infrastructure
(`Catalog/Tropical/`, `Catalog/Computation/Spectral.lean` with `minDiag`/`tropPow`
cycle-cost bounds); bridging `ReversibleChain.weight` to a tropical matrix and
relating `minDiag` of its powers to `flowOut` would connect two independent parts of
the codebase and produce a cheap, verified lower bound feeding into a future
`SpectralGapCert`.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
