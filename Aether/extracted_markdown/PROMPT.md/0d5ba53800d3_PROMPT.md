
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

**Title**: The companion file `ScalingLaws.lean` proves, from first principles, that a
**Domain**: Applications
**Mathematical framing**: # Future Directions — Scaling Laws from Statistical Mechanics

The companion file `ScalingLaws.lean` proves, from first principles, that a
Gaussian-Process kernel with power-law spectrum `λ_i = i^(-α)` (spectral exponent
`α > 1`) produces a generalisation loss `L(N) = Σ_{i>N} λ_i` that obeys a sharp
two-sided power law,

```
        (N+1)^(1-α)/(α-1)  ≤  L(N)  ≤  N^(1-α)/(α-1),
```

so the loss decays with the resolved-mode count `N` as exactly `N^(-(α-1))`. We
proved the spectrum is summable iff `α > 1`, that the loss vanishes in the
infinite-data limit, that it is monotone in `N`, and (the strengthening) that
`L(N) ∼ N^(1-α)/(α-1)` asymptotically. The following directions extend this
verified core toward the full empirical scaling-law phenomenology.

## 1. The compute-optimal frontier (a verified Chinchilla-type law)

Real training spends a finite compute budget `C` split between model size `M`
(number of resolved modes) and dataset size `D` (number of training samples). A
realistic loss model is `L(M, D) = A·M^(-(α-1)) + B·D^(-(β-1)) + L_∞`, the sum of
an approximation-error tail (our `tailLoss`) and an estimation-error tail with its
own exponent `β`, plus an irreducible floor `L_∞`. Minimising `L` subject to a
compute constraint `M·D = C` is a one-dimensional convex optimisation whose
solution is itself a power law `M*(C) ∝ C^a`, `D*(C) ∝ C^b` with `a + b = 1`.
**The key insight is** that the optimal allocation exponents `a, b` are rational
functions of the two spectral exponents `α, β` alone, so the compute-optimal
frontier is fully determined by the kernel spectrum and can be derived by the same
sum–integral comparison machinery already verified here. **Why now?** We already
have the exact tail bounds and their asymptotics in Lean; the remaining step is a
finite-dimensional convexity/Lagrange argument, for which Mathlib's
`InnerLE`/`StrictConvexOn` and `IsMinOn` API is mature, making a fully formal
derivation of a Chinchilla-style law immediately within reach.

## 2. Effective-exponent corrections at finite resolution

Empirically measured exponents drift with scale: the local log-log slope
`s(N) = -d log L / d log N` is not exactly `α-1` but approaches it. Our two-sided
bound already brackets `s(N)` between `(1-α)·log((N+1)/N)/log(1)`-type corrections.
**The key insight is** that the *gap* between the upper and lower bounds is itself a
controlled power series in `1/N` — precisely `(1 + 1/N)^(1-α) → 1` — so the
finite-size correction to the exponent is `O(1/N)` with an explicit constant
`(α-1)/2`. Formalising `s(N) = (α-1) + c/N + o(1/N)` would turn the qualitative
"exponents drift" folklore into a theorem. **Why now?** The asymptotic ratio
theorem `tailLoss_asymptotic` is already proved; extracting the *rate* of
convergence only requires a second-order Taylor estimate of `x ↦ x^(1-α)` at
`x = 1`, which `Real.hasDerivAt_rpow_const` supplies directly.

## 3. Beyond pure power laws: regularly varying spectra

Power-law spectra are an idealisation; real kernels have `λ_i = i^(-α)·ℓ(i)` with a
slowly varying factor `ℓ` (e.g. logarithmic corrections from feature learning).
**The key insight is** that the entire sum–integral comparison argument depends
only on `λ` being antitone and integrable, not on it being an exact power, so the
loss scaling is governed by the *regular-variation index* of the spectrum via
Karamata's theorem: `L(N) ∼ N·λ_N/(α-1)` whenever `λ` is regularly varying of
index `-α`. Formalising this would subsume the pure power law as a special case and
predict logarithmic scaling-law corrections. **Why now?** Mathlib has a growing
asymptotics/`Filter`-based `IsBigO` framework; the antitone comparison lemmas we
used (`AntitoneOn.sum_le_integral`) are already general enough to plug a regularly
varying `λ` in unchanged, so the generalisation is mostly a statement-level rewrite
plus a Karamata tail lemma.

## 4. Ridge regularisation and the resolution–noise tradeoff

Kernel *ridge* regression with ridge `δ > 0` does not sharply resolve the top `N`
modes; instead it down-weights mode `i` by `λ_i/(λ_i + δ)`, giving a soft loss
`L(δ) = Σ_i δ²λ_i/(λ_i+δ)²`. **The key insight is** that with the power-law
spectrum this soft cutoff is equivalent, up to constants, to a *hard* cutoff at the
effective resolution `N_eff(δ) = δ^(-1/α)`, so the verified hard-cutoff bound
transfers directly and yields `L(δ) ∝ δ^((α-1)/α)`. This connects the regularised
loss to the implicit early-stopping / learning-rate schedules used in practice.
**Why now?** The summand `δ²λ_i/(λ_i+δ)²` is again antitone in `i` for the
power-law spectrum, so the same `AntitoneOn` sum–integral toolkit applies verbatim;
only the closed-form integral changes (a Beta-function evaluation that Mathlib's
`integral_rpow`/`Real.Gamma` API can support).

## 5. Two-sided sharpness and matching constants

Our upper and lower constants differ only by the `(N+1)` vs `N` base; the true
asymptotic constant is `1/(α-1)` and we proved the ratio tends to `1`. **The key
insight is** that a full Euler–Maclaurin expansion with the Bernoulli correction
term would give the *next* coefficient, `L(N) = N^(1-α)/(α-1) + (1/2)N^(-α) + …`,
matching the exact second-order behaviour and closing the gap between our two
bounds quantitatively. **Why now?** Mathlib already contains an Euler–Maclaurin /
`sum_Ico` summation-by-parts development; pairing it with the explicit derivatives
of `x^(-α)` (all available via `Real.rpow`) makes a verified second-order scaling
law a natural, self-contained next milestone built entirely on the lemmas proved
in this cycle.

**Concept description**: # Future Directions — Scaling Laws from Statistical Mechanics

The companion file `ScalingLaws.lean` proves, from first principles, that a
Gaussian-Process kernel with power-law spectrum `λ_i = i^(-α)` (spectral exponent
`α > 1`) produces a generalisation loss `L(N) = Σ_{i>N} λ_i` that obeys a sharp
two-sided power law,

```
        (N+1)^(1-α)/(α-1)  ≤  L(N)  ≤  N^(1-α)/(α-1),
```

so the loss decays with the resolved-mode count `N` as exactly `N^(-(α-1))`. We
proved the spectrum is summable iff `α > 1`, that the loss vanishes in the
infinite-data limit, that it is monotone in `N`, and (the strengthening) that
`L(N) ∼ N^(1-α)/(α-1)` asymptotically. The following directions extend this
verified core toward the full empirical scaling-law phenomenology.

## 1. The compute-optimal frontier (a verified Chinchilla-type law)

Real training spends a finite compute budget `C` split between model size `M`
(number of resolved modes) and dataset size `D` (number of training samples). A
realistic loss model is `L(M, D) = A·M^(-(α-1)) + B·D^(-(β-1)) + L_∞`, the sum of
an approximation-error tail (our `tailLoss`) and an estimation-error tail with its
own exponent `β`, plus an irreducible floor `L_∞`. Minimising `L` subject to a
compute constraint `M·D = C` is a one-dimensional convex optimisation whose
solution is itself a power law `M*(C) ∝ C^a`, `D*(C) ∝ C^b` with `a + b = 1`.
**The key insight is** that the optimal allocation exponents `a, b` are rational
functions of the two spectral exponents `α, β` alone, so the compute-optimal
frontier is fully determined by the kernel spectrum and can be derived by the same
sum–integral comparison machinery already verified here. **Why now?** We already
have the exact tail bounds and their asymptotics in Lean; the remaining step is a
finite-dimensional convexity/Lagrange argument, for which Mathlib's
`InnerLE`/`StrictConvexOn` and `IsMinOn` API is mature, making a fully formal
derivation of a Chinchilla-style law immediately within reach.

## 2. Effective-exponent corrections at finite resolution

Empirically measured exponents drift with scale: the local log-log slope
`s(N) = -d log L / d log N` is not exactly `α-1` but approaches it. Our two-sided
bound already brackets `s(N)` between `(1-α)·log((N+1)/N)/log(1)`-type corrections.
**The key insight is** that the *gap* between the upper and lower bounds is itself a
controlled power series in `1/N` — precisely `(1 + 1/N)^(1-α) → 1` — so the
finite-size correction to the exponent is `O(1/N)` with an explicit constant
`(α-1)/2`. Formalising `s(N) = (α-1) + c/N + o(1/N)` would turn the qualitative
"exponents drift" folklore into a theorem. **Why now?** The asymptotic ratio
theorem `tailLoss_asymptotic` is already proved; extracting the *rate* of
convergence only requires a second-order Taylor estimate of `x ↦ x^(1-α)` at
`x = 1`, which `Real.hasDerivAt_rpow_const` supplies directly.

## 3. Beyond pure power laws: regularly varying spectra

Power-law spectra are an idealisation; real kernels have `λ_i = i^(-α)·ℓ(i)` with a
slowly varying factor `ℓ` (e.g. logarithmic corrections from feature learning).
**The key insight is** that the entire sum–integral comparison argument depends
only on `λ` being antitone and integrable, not on it being an exact power, so the
loss scaling is governed by the *regular-variation index* of the spectrum via
Karamata's theorem: `L(N) ∼ N·λ_N/(α-1)` whenever `λ` is regularly varying of
index `-α`. Formalising this would subsume the pure power law as a special case and
predict logarithmic scaling-law corrections. **Why now?** Mathlib has a growing
asymptotics/`Filter`-based `IsBigO` framework; the antitone comparison lemmas we
used (`AntitoneOn.sum_le_integral`) are already general enough to plug a regularly
varying `λ` in unchanged, so the generalisation is mostly a statement-level rewrite
plus a Karamata tail lemma.

## 4. Ridge regularisation and the resolution–noise tradeoff

Kernel *ridge* regression with ridge `δ > 0` does not sharply resolve the top `N`
modes; instead it down-weights mode `i` by `λ_i/(λ_i + δ)`, giving a soft loss
`L(δ) = Σ_i δ²λ_i/(λ_i+δ)²`. **The key insight is** that with the power-law
spectrum this soft cutoff is equivalent, up to constants, to a *hard* cutoff at the
effective resolution `N_eff(δ) = δ^(-1/α)`, so the verified hard-cutoff bound
transfers directly and yields `L(δ) ∝ δ^((α-1)/α)`. This connects the regularised
loss to the implicit early-stopping / learning-rate schedules used in practice.
**Why now?** The summand `δ²λ_i/(λ_i+δ)²` is again antitone in `i` for the
power-law spectrum, so the same `AntitoneOn` sum–integral toolkit applies verbatim;
only the closed-form integral changes (a Beta-function evaluation that Mathlib's
`integral_rpow`/`Real.Gamma` API can support).

## 5. Two-sided sharpness and matching constants

Our upper and lower constants differ only by the `(N+1)` vs `N` base; the true
asymptotic constant is `1/(α-1)` and we proved the ratio tends to `1`. **The key
insight is** that a full Euler–Maclaurin expansion with the Bernoulli correction
term would give the *next* coefficient, `L(N) = N^(1-α)/(α-1) + (1/2)N^(-α) + …`,
matching the exact second-order behaviour and closing the gap between our two
bounds quantitatively. **Why now?** Mathlib already contains an Euler–Maclaurin /
`sum_Ico` summation-by-parts development; pairing it with the explicit derivatives
of `x^(-α)` (all available via `Real.rpow`) makes a verified second-order scaling
law a natural, self-contained next milestone built entirely on the lemmas proved
in this cycle.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v14 Depth Requirements -- Synthetic Catalog Integration Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Synthetic Catalog Integration**. Focus on building a coherent body of work on top of our existing catalog.

### RESEARCH CORE METHODOLOGY:
1. **Lineage Synthesis**: Analyze the existing catalog context deeply. Do not reinvent definitions; import and build directly on top of the validated catalog results.
2. **Connect the Dots**: Search for "orphan" results or gaps in the catalog and construct bridges to connect them. Show how new theorems advance the overall mathematical architecture of the repository.
3. **Foundational Extension**: Take successful packages from the catalog and extend their results to broader algebraic settings, sharper bounds, or new domain applications.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
