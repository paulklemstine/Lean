
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

**Title**: These directions extend `Catalog/MachineLearning/RademacherSpectral.lean`, which
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Rademacher Complexity of Neural Networks

These directions extend `Catalog/MachineLearning/RademacherSpectral.lean`, which
formalizes the *empirical* Rademacher complexity as an honest uniform average over
the `2^n` sign patterns `s : Fin n → Bool` (`signAvg`), proves the discrete
second-moment identity `expected_sq_norm_rademacher_sum`
(`E_σ ‖∑ᵢ σᵢ xᵢ‖² = ∑ᵢ ‖xᵢ‖²`), the linear/kernel base case
`linear_rademacher_bound` (`empRademacher ≤ C·B/√n`), and the spectral depth bound
`netComp_lipschitz_pow` (an `L`-layer network of `C`-Lipschitz layers is
`C^L`-Lipschitz). Together these isolate exactly the two ingredients — a base-case
rate and a Lipschitz contraction — whose product yields neural-network bounds.
They also connect to the catalog's algebraic abstraction in
`Catalog/MachineLearning/Foundations.lean` (`spectralComplexityBound`,
`spectral_complexity_le_card_spectrum`) and the Lipschitz machinery in
`Catalog/MachineLearning/ResNetLipschitz.lean`.

## 1. The Talagrand contraction lemma for `signAvg`

The missing link between `netComp_lipschitz_pow` and a genuine network bound is the
contraction (comparison) principle: if `φ` is `ρ`-Lipschitz with `φ 0 = 0`, then
`signAvg n (fun s => sup_f (1/n) ∑ᵢ σᵢ φ(f xᵢ)) ≤ ρ · signAvg n (fun s => sup_f (1/n) ∑ᵢ σᵢ f xᵢ)`.
Chaining this `L` times over `netComp` and feeding in `linear_rademacher_bound`
gives `empRademacher(network) ≤ C^L · B / √n`.

The key insight is that contraction need not invoke any measure theory in this
discrete model: the sign average is a finite sum, so the classical proof reduces to
a *one-coordinate* comparison (peel coordinate `i`, bound the two sign branches
using Lipschitzness, recombine) that is amenable to `Finset` induction — exactly the
same flip-a-coordinate technology already used to prove `signAvg_sgn_mul`.

Why now? We already have the two endpoints in Lean (`linear_rademacher_bound` and
`netComp_lipschitz_pow`); the contraction lemma is the only intermediate object
needed, and its discrete proof reuses an involution argument we have shown compiles.

## 2. The depth-improved `O(C·√L/√n)` bound (Golowich–Rakhlin–Shamir)

`netComp_lipschitz_pow` gives the *exponential-in-depth* constant `C^L`. The sharper
modern result replaces `C^L` by something scaling like `√L` (after Frobenius/spectral
normalization), giving the target rate `O(C·√L/√n)`.

The key insight is that the `√L` arises from a *Jensen-on-the-MGF* step
(`log E exp` is concave in depth) rather than from iterating the crude product bound;
formalizing it amounts to proving a one-dimensional convexity inequality on top of
the already-formalized second-moment identity `expected_sq_norm_rademacher_sum`.

Why now? The hard analytic core (the `√(∑‖xᵢ‖²)` second moment and the
`(E Y)² ≤ E Y²` power-mean step `signAvg_le_sqrt_signAvg_sq`) is already in the file;
the refinement is a convexity argument layered on these, not a new foundation.

## 3. Massart's finite-class lemma in the `signAvg` model

For a finite class of `m` hypotheses bounded by `B`, conjecture
`empRademacher n m hm f ≤ B · √(2 · Real.log m) / √n`. This is the discrete Massart
lemma and is the bridge from the linear base case to *covering-number* bounds for
infinite classes.

The key insight is that the maximal-inequality proof becomes purely combinatorial
here: the sub-Gaussian MGF `signAvg n (fun s => exp(λ ∑ᵢ σᵢ f j i)) ≤ exp(λ²B²n/2)`
factorizes over coordinates because the `2^n` average factors as a product over the
`n` independent Boolean coordinates — a `Finset.prod`/`Fintype.piFinset` identity.

Why now? `signAvg` is literally a normalized `Finset` sum over a `Pi` type, so the
coordinatewise factorization is a structural `simp`-level fact rather than a
probabilistic theorem; the per-coordinate Hoeffding bound is a finite `cosh ≤ exp`
inequality.

## 4. From Rademacher to a PAC-Bayes / uniform-generalization guarantee

Conjecture a symmetrization inequality stating that the worst-case gap between the
empirical mean and the population mean over the class is controlled by
`2 · empRademacher`, and combine it with `linear_rademacher_bound` to get an explicit
`O(C·B/√n)` generalization certificate for spectrally normalized linear predictors,
and (via Direction 1) for `netComp` networks.

The key insight is that in the finite/discrete sample model the "ghost sample"
symmetrization is a *reindexing* of one finite sum by another, so the inequality is a
`Finset.sum` manipulation rather than a statement about independent copies of a
random variable.

Why now? `netComp_nonexpansive_of_le_one` already certifies that spectrally
normalized networks are `1`-Lipschitz at every depth, so the generalization
certificate would immediately specialize to a depth-*independent* guarantee, which is
the practically important regime.

## 5. Tightness: a matching lower bound via Khintchine

Conjecture that `linear_rademacher_bound` is tight up to an absolute constant:
for the single hypothesis `w` with `‖w‖ = C` and an orthonormal sample with
`‖xᵢ‖ = B`, `empRademacher ≥ c · C·B/√n` for an absolute `c > 0`.

The key insight is that the lower bound is the *reverse* Khintchine inequality
`E|∑ᵢ σᵢ aᵢ| ≥ (1/√2)·√(∑ aᵢ²)`, and in the orthonormal case the second moment we
already computed (`expected_sq_norm_rademacher_sum`) pins down `√(∑‖xᵢ‖²) = B√n`
exactly, so only the constant-factor lower Khintchine bound remains.

Why now? The exact second moment is already a theorem in this file, so a tightness
result needs only the lower Khintchine constant — turning our upper bound into a
*characterization* of the linear Rademacher rate, the strongest possible statement.

**Concept description**: # Future Directions — Rademacher Complexity of Neural Networks

These directions extend `Catalog/MachineLearning/RademacherSpectral.lean`, which
formalizes the *empirical* Rademacher complexity as an honest uniform average over
the `2^n` sign patterns `s : Fin n → Bool` (`signAvg`), proves the discrete
second-moment identity `expected_sq_norm_rademacher_sum`
(`E_σ ‖∑ᵢ σᵢ xᵢ‖² = ∑ᵢ ‖xᵢ‖²`), the linear/kernel base case
`linear_rademacher_bound` (`empRademacher ≤ C·B/√n`), and the spectral depth bound
`netComp_lipschitz_pow` (an `L`-layer network of `C`-Lipschitz layers is
`C^L`-Lipschitz). Together these isolate exactly the two ingredients — a base-case
rate and a Lipschitz contraction — whose product yields neural-network bounds.
They also connect to the catalog's algebraic abstraction in
`Catalog/MachineLearning/Foundations.lean` (`spectralComplexityBound`,
`spectral_complexity_le_card_spectrum`) and the Lipschitz machinery in
`Catalog/MachineLearning/ResNetLipschitz.lean`.

## 1. The Talagrand contraction lemma for `signAvg`

The missing link between `netComp_lipschitz_pow` and a genuine network bound is the
contraction (comparison) principle: if `φ` is `ρ`-Lipschitz with `φ 0 = 0`, then
`signAvg n (fun s => sup_f (1/n) ∑ᵢ σᵢ φ(f xᵢ)) ≤ ρ · signAvg n (fun s => sup_f (1/n) ∑ᵢ σᵢ f xᵢ)`.
Chaining this `L` times over `netComp` and feeding in `linear_rademacher_bound`
gives `empRademacher(network) ≤ C^L · B / √n`.

The key insight is that contraction need not invoke any measure theory in this
discrete model: the sign average is a finite sum, so the classical proof reduces to
a *one-coordinate* comparison (peel coordinate `i`, bound the two sign branches
using Lipschitzness, recombine) that is amenable to `Finset` induction — exactly the
same flip-a-coordinate technology already used to prove `signAvg_sgn_mul`.

Why now? We already have the two endpoints in Lean (`linear_rademacher_bound` and
`netComp_lipschitz_pow`); the contraction lemma is the only intermediate object
needed, and its discrete proof reuses an involution argument we have shown compiles.

## 2. The depth-improved `O(C·√L/√n)` bound (Golowich–Rakhlin–Shamir)

`netComp_lipschitz_pow` gives the *exponential-in-depth* constant `C^L`. The sharper
modern result replaces `C^L` by something scaling like `√L` (after Frobenius/spectral
normalization), giving the target rate `O(C·√L/√n)`.

The key insight is that the `√L` arises from a *Jensen-on-the-MGF* step
(`log E exp` is concave in depth) rather than from iterating the crude product bound;
formalizing it amounts to proving a one-dimensional convexity inequality on top of
the already-formalized second-moment identity `expected_sq_norm_rademacher_sum`.

Why now? The hard analytic core (the `√(∑‖xᵢ‖²)` second moment and the
`(E Y)² ≤ E Y²` power-mean step `signAvg_le_sqrt_signAvg_sq`) is already in the file;
the refinement is a convexity argument layered on these, not a new foundation.

## 3. Massart's finite-class lemma in the `signAvg` model

For a finite class of `m` hypotheses bounded by `B`, conjecture
`empRademacher n m hm f ≤ B · √(2 · Real.log m) / √n`. This is the discrete Massart
lemma and is the bridge from the linear base case to *covering-number* bounds for
infinite classes.

The key insight is that the maximal-inequality proof becomes purely combinatorial
here: the sub-Gaussian MGF `signAvg n (fun s => exp(λ ∑ᵢ σᵢ f j i)) ≤ exp(λ²B²n/2)`
factorizes over coordinates because the `2^n` average factors as a product over the
`n` independent Boolean coordinates — a `Finset.prod`/`Fintype.piFinset` identity.

Why now? `signAvg` is literally a normalized `Finset` sum over a `Pi` type, so the
coordinatewise factorization is a structural `simp`-level fact rather than a
probabilistic theorem; the per-coordinate Hoeffding bound is a finite `cosh ≤ exp`
inequality.

## 4. From Rademacher to a PAC-Bayes / uniform-generalization guarantee

Conjecture a symmetrization inequality stating that the worst-case gap between the
empirical mean and the population mean over the class is controlled by
`2 · empRademacher`, and combine it with `linear_rademacher_bound` to get an explicit
`O(C·B/√n)` generalization certificate for spectrally normalized linear predictors,
and (via Direction 1) for `netComp` networks.

The key insight is that in the finite/discrete sample model the "ghost sample"
symmetrization is a *reindexing* of one finite sum by another, so the inequality is a
`Finset.sum` manipulation rather than a statement about independent copies of a
random variable.

Why now? `netComp_nonexpansive_of_le_one` already certifies that spectrally
normalized networks are `1`-Lipschitz at every depth, so the generalization
certificate would immediately specialize to a depth-*independent* guarantee, which is
the practically important regime.

## 5. Tightness: a matching lower bound via Khintchine

Conjecture that `linear_rademacher_bound` is tight up to an absolute constant:
for the single hypothesis `w` with `‖w‖ = C` and an orthonormal sample with
`‖xᵢ‖ = B`, `empRademacher ≥ c · C·B/√n` for an absolute `c > 0`.

The key insight is that the lower bound is the *reverse* Khintchine inequality
`E|∑ᵢ σᵢ aᵢ| ≥ (1/√2)·√(∑ aᵢ²)`, and in the orthonormal case the second moment we
already computed (`expected_sq_norm_rademacher_sum`) pins down `√(∑‖xᵢ‖²) = B√n`
exactly, so only the constant-factor lower Khintchine bound remains.

Why now? The exact second moment is already a theorem in this file, so a tightness
result needs only the lower Khintchine constant — turning our upper bound into a
*characterization* of the linear Rademacher rate, the strongest possible statement.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
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
