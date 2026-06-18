
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

**Title**: The new file `Computation/SpectralChain/L2Operator.lean` lifts the spectral-chai
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Spectral Chain Framework — L²(π) Operator Layer

## What was established (this cycle)

The new file `Computation/SpectralChain/L2Operator.lean` lifts the spectral-chain
framework from combinatorial energy/variance algebra into genuine **self-adjoint
operator theory** on the finite weighted Hilbert space `L²(π)`. Building on the
foundations of `Computation/SpectralChain/Core.lean` (`ReversibleChain`, `weight`,
`mean`, `Var`, `DirichletForm`, `SpectralGapCert`, and the cross-domain bridge
`cheeger_easy_inequality`), it introduces the Markov operator action
`(P f)(i) = ∑_j P_ij f_j` and the weighted inner product
`⟨f, g⟩_π = ∑_i π_i f_i g_i`, then proves the four structural identities that connect
them. Every main theorem compiles with `sorry = 0` and uses only the standard axioms.

The proven results are:

- **`mean_applyP`** — the kernel action preserves the stationary mean: `mean(Pf) = mean(f)`.
  This is precisely the statement that `P` is a Markov (stochastic) operator on observables.
- **`innerPi_self_adjoint`** — reversibility is *exactly* the self-adjointness of `P`
  in `L²(π)`: `⟨Pf, g⟩_π = ⟨f, Pg⟩_π`. Detailed balance becomes a symmetry of an operator.
- **`DirichletForm_eq_innerPi_sub`** — the Dirichlet form is the quadratic form of
  `I − P`: `E(f) = ⟨f, f⟩_π − ⟨Pf, f⟩_π = ⟨(I − P)f, f⟩_π`. The geometric energy is now
  an operator-theoretic object.
- **`Var_eq_innerPi_sub_mean_sq`** — variance is the squared `L²(π)` norm minus the
  squared mean: `Var(f) = ⟨f, f⟩_π − mean(f)²`, i.e. the norm on the mean-zero subspace.
- **`applyP_inner_contraction`** — the cornerstone bridge: a Poincaré gap `γ` forces a
  *one-step contraction* on mean-zero observables, `⟨Pf, f⟩_π ≤ (1 − γ) ⟨f, f⟩_π`. This
  turns the abstract `SpectralGapCert` into a quantitative convergence statement.

The strengthening `Var_applyP_contraction_conjecture`
(`Var(Pf) ≤ (1 − γ)² · Var(f)`) is recorded as a `sorry`ed target, consuming exactly
`applyP_inner_contraction` and `innerPi_self_adjoint`.

---

## Direction 1: Full geometric ergodicity `Var(Pᵗ f) ≤ (1 − γ)^{2t} · Var(f)`

The one-step contraction `applyP_inner_contraction` is the algebraic heart of geometric
convergence, but the clean iterated bound requires upgrading the inner-product
contraction to an *operator-norm* contraction on the mean-zero subspace.
**The key insight is** that for a self-adjoint operator the inner-product bound
`⟨Pf, f⟩ ≤ (1 − γ)⟨f, f⟩` is not by itself enough — one also needs the *lower* spectral
bound `⟨Pf, f⟩ ≥ −(1 − γ)⟨f, f⟩` (laziness, or the absolute spectral gap), after which
`‖P|_{mean-zero}‖ ≤ 1 − γ` follows from the spectral theorem and iterates trivially to
`‖Pᵗ f − mean(f)‖_π ≤ (1 − γ)ᵗ ‖f − mean(f)‖_π`, which squares to the variance bound.
**Why now?** `innerPi_self_adjoint` already certifies self-adjointness, and
`Var_eq_innerPi_sub_mean_sq` already identifies the variance with the mean-zero norm;
the only missing ingredient is the finite-dimensional spectral theorem for self-adjoint
operators, which is fully available in current Mathlib once `applyP` is packaged as a
`LinearMap` on the Euclidean space `EuclideanSpace ℝ V` reweighted by `π`.

## Direction 2: The reversible kernel as a genuine `LinearMap` and its spectrum

This cycle treats `applyP` as a plain function `(V → ℝ) → (V → ℝ)`. Promoting it to a
`LinearMap ℝ (V → ℝ) (V → ℝ)` (or to a self-adjoint operator on `PiLp 2`) would expose
the entire eigenvalue calculus. **The key insight is** that, once `innerPi` is registered
as an `InnerProductSpace` structure (the weighting `π_i > 0` makes `innerPi` a genuine
positive-definite inner product by `π_pos`), `innerPi_self_adjoint` is literally the
hypothesis `IsSelfAdjoint` of Mathlib's spectral API, so the chain's spectral gap becomes
`1 − λ₂` where `λ₂` is the second-largest eigenvalue of the operator. **Why now?** All the
positivity facts needed for the inner-product axioms are already proven (`π_pos`,
`π_sum`), and `innerPi_self_adjoint` discharges the single nontrivial hypothesis of the
finite spectral theorem; this turns `SpectralGapCert` from a hand-supplied certificate
into a *theorem* about the actual spectrum.

## Direction 3: Variational (Courant–Fischer) characterisation of the optimal gap

Rather than asserting a gap via a certificate, the optimal Poincaré constant is the
Rayleigh quotient minimum `γ* = inf_{f ⊥ 1} E(f)/Var(f)`. **The key insight is** that the
identities `DirichletForm_eq_innerPi_sub` and `Var_eq_innerPi_sub_mean_sq` rewrite this
ratio purely in inner-product terms, `E(f)/Var(f) = ⟨(I−P)f,f⟩_π / ⟨f,f⟩_π` on the
mean-zero subspace, which is exactly the Rayleigh quotient of `I − P`; its infimum is the
smallest nonzero eigenvalue by Courant–Fischer. **Why now?** The two rewriting lemmas are
already proven and mutually compatible, so the Rayleigh quotient is expressible *today*;
the remaining step is to invoke `inner_le_iff` / the min–max theorem on the finite
self-adjoint operator of Direction 2, yielding an *existence* proof of an optimal
`SpectralGapCert` rather than requiring the user to supply one.

## Direction 4: Tensorisation — the gap of a product chain

A central structural fact is that the spectral gap of a product of reversible chains is
the *minimum* of the factor gaps: `γ(C₁ ⊗ C₂) = min(γ(C₁), γ(C₂))`. **The key insight is**
that the product chain's Dirichlet form splits additively along the two coordinates,
`E_{C₁⊗C₂}(f) = E₁⊗id(f) + id⊗E₂(f)`, and the product inner product factorises, so the
contraction `applyP_inner_contraction` applied coordinatewise immediately yields the lower
bound `min(γ₁, γ₂)` for the product gap. **Why now?** The operator layer makes the tensor
structure expressible: `applyP` on `V₁ × V₂` is the Kronecker action `P₁ ⊗ P₂`, and the
additive splitting of `DirichletForm_eq_innerPi_sub` over a product index is a pure
`Finset.sum_product` rearrangement — no new analysis, only the bookkeeping that the
inner-product formulation finally makes tractable.

## Direction 5: A log-Sobolev layer comparable to the spectral gap

Above the spectral gap sits the log-Sobolev constant `α`, governing hypercontractivity and
the sharper mixing bound `t_mix(ε) ≤ (1/2α)·log log(1/ε)`. **The key insight is** that the
entropy functional `Ent(g) = ∑_i π_i g_i log g_i − (∑ π_i g_i) log(∑ π_i g_i)` plays the
role that `Var` plays for the spectral gap, and that the *same* Dirichlet form
`DirichletForm_eq_innerPi_sub` appears on the right-hand side of the log-Sobolev inequality
`Ent(f²) ≤ (2/α)·E(f)`; linearising the entropy around its mean recovers the variance,
giving the universal ordering `α ≤ γ`. **Why now?** `DirichletForm`, `mean`, and the
inner-product machinery are all in place, and the entropy functional needs only `Real.log`
and `Finset.sum`, both already imported; a `LogSobolevCert` structure mirroring
`SpectralGapCert` would slot directly into the existing comparison apparatus and let the
two mixing regimes be compared as theorems.

**Concept description**: # Future Directions: Spectral Chain Framework — L²(π) Operator Layer

## What was established (this cycle)

The new file `Computation/SpectralChain/L2Operator.lean` lifts the spectral-chain
framework from combinatorial energy/variance algebra into genuine **self-adjoint
operator theory** on the finite weighted Hilbert space `L²(π)`. Building on the
foundations of `Computation/SpectralChain/Core.lean` (`ReversibleChain`, `weight`,
`mean`, `Var`, `DirichletForm`, `SpectralGapCert`, and the cross-domain bridge
`cheeger_easy_inequality`), it introduces the Markov operator action
`(P f)(i) = ∑_j P_ij f_j` and the weighted inner product
`⟨f, g⟩_π = ∑_i π_i f_i g_i`, then proves the four structural identities that connect
them. Every main theorem compiles with `sorry = 0` and uses only the standard axioms.

The proven results are:

- **`mean_applyP`** — the kernel action preserves the stationary mean: `mean(Pf) = mean(f)`.
  This is precisely the statement that `P` is a Markov (stochastic) operator on observables.
- **`innerPi_self_adjoint`** — reversibility is *exactly* the self-adjointness of `P`
  in `L²(π)`: `⟨Pf, g⟩_π = ⟨f, Pg⟩_π`. Detailed balance becomes a symmetry of an operator.
- **`DirichletForm_eq_innerPi_sub`** — the Dirichlet form is the quadratic form of
  `I − P`: `E(f) = ⟨f, f⟩_π − ⟨Pf, f⟩_π = ⟨(I − P)f, f⟩_π`. The geometric energy is now
  an operator-theoretic object.
- **`Var_eq_innerPi_sub_mean_sq`** — variance is the squared `L²(π)` norm minus the
  squared mean: `Var(f) = ⟨f, f⟩_π − mean(f)²`, i.e. the norm on the mean-zero subspace.
- **`applyP_inner_contraction`** — the cornerstone bridge: a Poincaré gap `γ` forces a
  *one-step contraction* on mean-zero observables, `⟨Pf, f⟩_π ≤ (1 − γ) ⟨f, f⟩_π`. This
  turns the abstract `SpectralGapCert` into a quantitative convergence statement.

The strengthening `Var_applyP_contraction_conjecture`
(`Var(Pf) ≤ (1 − γ)² · Var(f)`) is recorded as a `sorry`ed target, consuming exactly
`applyP_inner_contraction` and `innerPi_self_adjoint`.

---

## Direction 1: Full geometric ergodicity `Var(Pᵗ f) ≤ (1 − γ)^{2t} · Var(f)`

The one-step contraction `applyP_inner_contraction` is the algebraic heart of geometric
convergence, but the clean iterated bound requires upgrading the inner-product
contraction to an *operator-norm* contraction on the mean-zero subspace.
**The key insight is** that for a self-adjoint operator the inner-product bound
`⟨Pf, f⟩ ≤ (1 − γ)⟨f, f⟩` is not by itself enough — one also needs the *lower* spectral
bound `⟨Pf, f⟩ ≥ −(1 − γ)⟨f, f⟩` (laziness, or the absolute spectral gap), after which
`‖P|_{mean-zero}‖ ≤ 1 − γ` follows from the spectral theorem and iterates trivially to
`‖Pᵗ f − mean(f)‖_π ≤ (1 − γ)ᵗ ‖f − mean(f)‖_π`, which squares to the variance bound.
**Why now?** `innerPi_self_adjoint` already certifies self-adjointness, and
`Var_eq_innerPi_sub_mean_sq` already identifies the variance with the mean-zero norm;
the only missing ingredient is the finite-dimensional spectral theorem for self-adjoint
operators, which is fully available in current Mathlib once `applyP` is packaged as a
`LinearMap` on the Euclidean space `EuclideanSpace ℝ V` reweighted by `π`.

## Direction 2: The reversible kernel as a genuine `LinearMap` and its spectrum

This cycle treats `applyP` as a plain function `(V → ℝ) → (V → ℝ)`. Promoting it to a
`LinearMap ℝ (V → ℝ) (V → ℝ)` (or to a self-adjoint operator on `PiLp 2`) would expose
the entire eigenvalue calculus. **The key insight is** that, once `innerPi` is registered
as an `InnerProductSpace` structure (the weighting `π_i > 0` makes `innerPi` a genuine
positive-definite inner product by `π_pos`), `innerPi_self_adjoint` is literally the
hypothesis `IsSelfAdjoint` of Mathlib's spectral API, so the chain's spectral gap becomes
`1 − λ₂` where `λ₂` is the second-largest eigenvalue of the operator. **Why now?** All the
positivity facts needed for the inner-product axioms are already proven (`π_pos`,
`π_sum`), and `innerPi_self_adjoint` discharges the single nontrivial hypothesis of the
finite spectral theorem; this turns `SpectralGapCert` from a hand-supplied certificate
into a *theorem* about the actual spectrum.

## Direction 3: Variational (Courant–Fischer) characterisation of the optimal gap

Rather than asserting a gap via a certificate, the optimal Poincaré constant is the
Rayleigh quotient minimum `γ* = inf_{f ⊥ 1} E(f)/Var(f)`. **The key insight is** that the
identities `DirichletForm_eq_innerPi_sub` and `Var_eq_innerPi_sub_mean_sq` rewrite this
ratio purely in inner-product terms, `E(f)/Var(f) = ⟨(I−P)f,f⟩_π / ⟨f,f⟩_π` on the
mean-zero subspace, which is exactly the Rayleigh quotient of `I − P`; its infimum is the
smallest nonzero eigenvalue by Courant–Fischer. **Why now?** The two rewriting lemmas are
already proven and mutually compatible, so the Rayleigh quotient is expressible *today*;
the remaining step is to invoke `inner_le_iff` / the min–max theorem on the finite
self-adjoint operator of Direction 2, yielding an *existence* proof of an optimal
`SpectralGapCert` rather than requiring the user to supply one.

## Direction 4: Tensorisation — the gap of a product chain

A central structural fact is that the spectral gap of a product of reversible chains is
the *minimum* of the factor gaps: `γ(C₁ ⊗ C₂) = min(γ(C₁), γ(C₂))`. **The key insight is**
that the product chain's Dirichlet form splits additively along the two coordinates,
`E_{C₁⊗C₂}(f) = E₁⊗id(f) + id⊗E₂(f)`, and the product inner product factorises, so the
contraction `applyP_inner_contraction` applied coordinatewise immediately yields the lower
bound `min(γ₁, γ₂)` for the product gap. **Why now?** The operator layer makes the tensor
structure expressible: `applyP` on `V₁ × V₂` is the Kronecker action `P₁ ⊗ P₂`, and the
additive splitting of `DirichletForm_eq_innerPi_sub` over a product index is a pure
`Finset.sum_product` rearrangement — no new analysis, only the bookkeeping that the
inner-product formulation finally makes tractable.

## Direction 5: A log-Sobolev layer comparable to the spectral gap

Above the spectral gap sits the log-Sobolev constant `α`, governing hypercontractivity and
the sharper mixing bound `t_mix(ε) ≤ (1/2α)·log log(1/ε)`. **The key insight is** that the
entropy functional `Ent(g) = ∑_i π_i g_i log g_i − (∑ π_i g_i) log(∑ π_i g_i)` plays the
role that `Var` plays for the spectral gap, and that the *same* Dirichlet form
`DirichletForm_eq_innerPi_sub` appears on the right-hand side of the log-Sobolev inequality
`Ent(f²) ≤ (2/α)·E(f)`; linearising the entropy around its mean recovers the variance,
giving the universal ordering `α ≤ γ`. **Why now?** `DirichletForm`, `mean`, and the
inner-product machinery are all in place, and the entropy functional needs only `Real.log`
and `Finset.sum`, both already imported; a `LogSobolevCert` structure mirroring
`SpectralGapCert` would slot directly into the existing comparison apparatus and let the
two mixing regimes be compared as theorems.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Research Team Protocol

You are leading a research team. Your team has different roles:
- The **Hypothesizer** generates bold, falsifiable conjectures
- The **Experimenter** proves or disproves them in Lean 4
- The **Analyst** examines what survived, what failed, and WHY
- The **Critic** searches for weaknesses, constructs counterexamples,
  and identifies where proofs might break down. A well-constructed
  counterexample is as valuable as a proof.
- The **Synthesist** upgrades the knowledge base and writes the
  FUTURE_DIRECTIONS.md that seeds the next cycle

You run this loop: **Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate**.
Each cycle is not a one-shot task. It is one iteration of an infinite
research process. Your notes (FUTURE_DIRECTIONS.md, Lab Notebooks,
proof sketches) determine whether the next team builds on your work
or starts over.

**Take good notes.** A cycle without useful notes is a wasted cycle.

### STEP 1: THEOREM DECLARATIONS (required -- before any code)

List every theorem you intend to prove or investigate. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `hypothesis` | `conjecture` | `proved` | `proved_with_lemma_sorry` | `disproved`
- **Why it matters**: One sentence on what this result would mean if true,
  and what it would teach us if false

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective -- proved -- constructive inverse -- confirms decidability of Nat x Nat
2. `cantorPairing_injective`: Cantor pairing is injective -- proved -- diagonal argument -- confirms invertibility
3. `cantorPairing_bijection`: Cantor pairing is a bijection -- proved_with_lemma_sorry -- follows from 1+2 -- completing the characterization

Use `hypothesis` for statements you are not yet sure you can prove but
want to investigate. Use `conjecture` for statements you believe are true
but cannot prove in this cycle. Use `disproved` for statements where you
found a counterexample. Use `proved` for statements with complete Lean
proofs. Use `proved_with_lemma_sorry` when the main proof is complete but
one or more supporting lemmas use `sorry`.

### STEP 2: EXPERIMENT (prove or disprove in Lean 4)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its
status to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it is deferred

**Disproofs count.** If a hypothesis is false, prove its negation or
construct an explicit counterexample. A well-constructed counterexample
is as valuable as a proof. Change the status to `disproved` and state
the counterexample clearly.

### STEP 3: CRITIQUE (find the weaknesses)

For your best theorem, the Critic must:
- Identify the strongest assumption that could be weakened
- Construct a boundary case: where does the result break down?
- If possible, state a `conjecture` for the generalized version and
  explain what would need to change in the proof

This is NOT optional. A theorem without a critique is incomplete.

### STEP 4: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` -- unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures, generalizations, and boundary cases.

### STEP 5: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### STEP 6: TAKE GOOD NOTES (first-class deliverables)

Your notes determine what the next research team investigates. They are NOT
an afterthought. They are your most important output after the proofs themselves.

**6a. Lab Notebook** (in each .lean file, as `-- !-- Lab Notebook -- !--` blocks):

For each major theorem, include a Lab Notebook comment block:
```lean
-- !-- Lab Notebook: cantorPairing_bijection -- !--
-- !-- Hypothesis: Cantor pairing is bijective because both surjective and injective -- !--
-- !-- Result: Proved via composition of surjective and injective proofs -- !--
-- !-- Insight: The constructive inverse of surjectivity is key; diagonal argument handles injectivity -- !--
-- !-- Failure analysis: Initial attempt to prove bijection directly failed; decomposition into surjective+injective was necessary -- !--
-- !-- End Lab Notebook -- !--
```

**6b. FUTURE_DIRECTIONS.md** (MANDATORY — your output WILL BE REJECTED if missing):

You MUST produce a FUTURE_DIRECTIONS.md file with this EXACT structure.
Copy the section headers below verbatim. Do NOT use freeform prose.

## Synthesis

[2-3 paragraphs: what did this cycle discover? What failed and why? What
structural insight emerged? Tie the directions together into a narrative.]

## Results Summary

[For EACH theorem: name, status (proved/conjecture/disproved), one-sentence
significance. Format as a bullet list:]

- `theoremName`: status — one-sentence significance

## Research Directions

### Direction 1: [Concise title]
**Hypothesis**: A precise, falsifiable mathematical statement.
**Test**: What experiment (proof/disproof/computation) would confirm or refute it.
**Why now**: What from THIS cycle makes this tractable.
**If true**: What new territory this opens.
**If false**: What the failure teaches us.

[Repeat for 3-5 directions]

IMPORTANT: The ## Synthesis and ## Results Summary sections are NOT optional.
If your FUTURE_DIRECTIONS.md is missing either section, it will be treated as
incomplete and the next research team will have no context to build on your work.

### STEP 7: Generalization loop

For your BEST theorem, attempt one level of generalization:
- State a stronger version (can use sorry if proving would take too long)
- Identify the boundary: where does the result break down?
- If the generalization is itself interesting, mark it as a `conjecture`
  in your theorem declarations and explain it in FUTURE_DIRECTIONS.md

### Output format

Your output must include:
1. `.lean` files with proofs and Lab Notebook blocks (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with Synthesis, Results Summary, and 3-5 research
   directions (structured as in Step 6b)

Both are required. A cycle with proofs but no Lab Notebook or
FUTURE_DIRECTIONS.md is a cycle where the next team starts from scratch.
Take good notes.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
