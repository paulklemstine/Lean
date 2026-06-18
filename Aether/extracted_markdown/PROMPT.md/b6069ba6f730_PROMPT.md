
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

**Title**: This cycle attacked the conjecture that *smooth structure is a usable computatio
**Domain**: Applications
**Mathematical framing**: # Future Directions — Topological Error-Correcting Codes and the Topological/Geometric Split

## Synthesis

This cycle attacked the conjecture that *smooth structure is a usable computational resource*:
that homeomorphic-but-non-diffeomorphic manifolds support error-correcting codes whose logical
content is pinned by topology while their **distance** responds to finer geometric data. Rather
than formalizing exotic 4- and 7-manifolds directly (far beyond current Mathlib), we extracted
the *invariant-theoretic skeleton* of the claim and proved it cleanly on the simplest nontrivial
homological codes — the cycle codes of graphs over `ZMod 2`, the 1-dimensional members of the
CSS/homological code family.

The file `Catalog/Speculative/AutoResearch/TopologicalCodes.lean` establishes, for the `n`-cycle
`C_n`:

* `cycleBoundary_eq_zero_iff` — the cycle space is exactly `{0, 𝟙}`;
* `cycleCode_card` — the **logical dimension is `k = 1 = b₁(C_n)`**, a topological invariant
  (the harmonic-kernel/Betti number computed basis-free in the catalog's `HodgeBettiRank`);
* `cycleDistance_eq` — the **code distance is `d = n`**, the girth, a refinement-sensitive
  (geometric) invariant;
* `distance_not_homological_invariant` — `C₃` and `C₄` have *equal* `k` but *unequal* `d`;
* `distance_scales_with_refinement` — edge-subdivision (`C_n → C_{2n}`) fixes `k` and doubles `d`.

This is the conjecture's dichotomy made precise and machine-checked: **`k` lives in homology;
`d` lives one level finer.** It is also the missing quantum-information layer over the catalog's
discrete-Hodge thread (`HodgeBettiRank`, `HodgeFullDecomposition`), where the harmonic sector had
been computed but never read as a code space.

## Results Summary

| Theorem | Statement | Role |
|---|---|---|
| `cycleBoundary_eq_zero_iff` | cycles `= {0, 𝟙}` | structural core |
| `cycleCode_card` | `#code = 2`, i.e. `k = 1` | topological invariant |
| `allOnes_hammingNorm` | `wt(𝟙) = n` | distance ingredient |
| `cycleDistance_eq` | `d = n` | geometric invariant |
| `distance_not_homological_invariant` | equal `k`, unequal `d` | headline split |
| `distance_scales_with_refinement` | `k` fixed, `d` doubles | refinement law |

All proofs depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Surface (toric-code) homology and the rate–distance frontier in 2D

Lift the 1D cycle code to the 2D toric code: a chain complex `C₂ →∂₂ C₁ →∂₁ C₀` over `ZMod 2`
on an `m × m` torus grid, with `k = dim H₁ = 2` (two independent loops) and `d = m`. Prove the
analogue `distance_not_homological_invariant` by comparing two cellulations of the *same* torus
with the same `H₁` but different shortest noncontractible cycles. **The key insight is** that the
1D proof's "constancy forces `{0, 𝟙}`" generalizes to "homology class is fixed by `∂₁∂₂ = 0`
while the minimal representative weight is a cellulation functional" — distance is a *minimum over
a homology coset*, never a coset invariant. **Why now?** The 1D kernel-characterization technique
and the catalog's entrywise Hodge decomposition already give both halves (`ker ∂₁`, `im ∂₂`);
only the coset-minimization Finset argument is new, and it is decidable on fixed grids.

### 2. Triangulation-refinement invariance of `k`, formalized as a chain homotopy

We proved `k` is *constant* under the specific refinement `C_n → C_{2n}`. Conjecture and prove
the general statement: any edge-subdivision of a finite graph induces a chain isomorphism on
`H₁` over `ZMod 2`, hence preserves `k` exactly, while multiplying every cycle's length (and thus
the distance) by the subdivision factor. **The key insight is** that subdivision is the discrete
shadow of triangulation refinement, and homology's refinement-invariance is precisely the
"topology-only" half of the conjecture — so the split is *forced*, not accidental. **Why now?**
Mathlib's `SimpleGraph` plus the cycle-space kernel description make subdivision a concrete map
on `Fin`-indexed chain spaces; the homotopy is an explicit `ZMod 2`-linear bijection.

### 3. Spectral certification: distance from the Laplacian spectrum, not the Betti number

Define the graph Hodge Laplacian `Δ = ∂₁ᵀ∂₁` on `1`-chains and prove that its kernel dimension
equals `k` (rank–nullity, exactly the catalog `HodgeBettiRank` mechanism) while a *spectral gap*
bound lower-bounds the distance: `d ≥ f(λ_min nonzero eigenvalue)`. Then exhibit two graphs with
identical `k` but different spectral gaps witnessing different `d`. **The key insight is** that
"smooth-structure-sensitive spectral invariants" in the conjecture become honest Laplacian
spectra here, and the harmonic kernel (topology) and spectral gap (geometry) are computed by the
*same operator* — unifying the two invariants in one object. **Why now?** The catalog already has
the discrete Hodge Laplacian and its rank–nullity Betti theorem; adding an eigenvalue/distance
inequality is a self-contained linear-algebra extension over `ℝ` or `ZMod 2`.

### 4. A decidable code-equivalence checker and its incompleteness for distance

Build a computable function `codeEquiv : ChainComplex → ChainComplex → Bool` deciding equality of
logical dimension `k`, and prove it is *correct for `k`* (`decide`-backed) but *provably blind to
`d`*: there exist inputs it accepts whose distances differ (instantiate with `C₃`, `C₄`). **The
key insight is** that algorithmic topological-equivalence testing is sound but strictly weaker
than geometric-equivalence testing — the formal analogue of "homeomorphism is decidable data,
diffeomorphism is not." **Why now?** Everything here is finite and `Decidable`; the catalog's
constructive/algorithmic mandate is directly served, and the falsifier (a single distance gap) is
already proved as `distance_not_homological_invariant`.

### 5. Higher-dimensional obstruction: when does `k` *force* `d`?

Conjecture the converse boundary: characterize the chain complexes for which `d` *is* determined
by `k` (e.g. complexes whose nonzero homology classes all have the same minimal weight), and prove
the cycle codes `C_n` are the *extremal* family saturating distance for `k = 1`. Refute the naive
"distance is always free" reading by proving that for `k = 0` (acyclic complexes) the distance is
vacuously `∞`/undefined — a genuine collapse. **The key insight is** that the split is not
universal: there is a sharp dividing line between complexes where geometry adds information and
where it cannot, and locating it tells you exactly when exotic smooth structure could matter.
**Why now?** The `cycleDistance` `sInf`-over-weight-set definition already exposes the empty-set
(acyclic) edge case, so the collapse direction is immediate, and the extremal characterization is
a clean optimization statement over the proved `{0, 𝟙}` kernel.

**Concept description**: # Future Directions — Topological Error-Correcting Codes and the Topological/Geometric Split

## Synthesis

This cycle attacked the conjecture that *smooth structure is a usable computational resource*:
that homeomorphic-but-non-diffeomorphic manifolds support error-correcting codes whose logical
content is pinned by topology while their **distance** responds to finer geometric data. Rather
than formalizing exotic 4- and 7-manifolds directly (far beyond current Mathlib), we extracted
the *invariant-theoretic skeleton* of the claim and proved it cleanly on the simplest nontrivial
homological codes — the cycle codes of graphs over `ZMod 2`, the 1-dimensional members of the
CSS/homological code family.

The file `Catalog/Speculative/AutoResearch/TopologicalCodes.lean` establishes, for the `n`-cycle
`C_n`:

* `cycleBoundary_eq_zero_iff` — the cycle space is exactly `{0, 𝟙}`;
* `cycleCode_card` — the **logical dimension is `k = 1 = b₁(C_n)`**, a topological invariant
  (the harmonic-kernel/Betti number computed basis-free in the catalog's `HodgeBettiRank`);
* `cycleDistance_eq` — the **code distance is `d = n`**, the girth, a refinement-sensitive
  (geometric) invariant;
* `distance_not_homological_invariant` — `C₃` and `C₄` have *equal* `k` but *unequal* `d`;
* `distance_scales_with_refinement` — edge-subdivision (`C_n → C_{2n}`) fixes `k` and doubles `d`.

This is the conjecture's dichotomy made precise and machine-checked: **`k` lives in homology;
`d` lives one level finer.** It is also the missing quantum-information layer over the catalog's
discrete-Hodge thread (`HodgeBettiRank`, `HodgeFullDecomposition`), where the harmonic sector had
been computed but never read as a code space.

## Results Summary

| Theorem | Statement | Role |
|---|---|---|
| `cycleBoundary_eq_zero_iff` | cycles `= {0, 𝟙}` | structural core |
| `cycleCode_card` | `#code = 2`, i.e. `k = 1` | topological invariant |
| `allOnes_hammingNorm` | `wt(𝟙) = n` | distance ingredient |
| `cycleDistance_eq` | `d = n` | geometric invariant |
| `distance_not_homological_invariant` | equal `k`, unequal `d` | headline split |
| `distance_scales_with_refinement` | `k` fixed, `d` doubles | refinement law |

All proofs depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Surface (toric-code) homology and the rate–distance frontier in 2D

Lift the 1D cycle code to the 2D toric code: a chain complex `C₂ →∂₂ C₁ →∂₁ C₀` over `ZMod 2`
on an `m × m` torus grid, with `k = dim H₁ = 2` (two independent loops) and `d = m`. Prove the
analogue `distance_not_homological_invariant` by comparing two cellulations of the *same* torus
with the same `H₁` but different shortest noncontractible cycles. **The key insight is** that the
1D proof's "constancy forces `{0, 𝟙}`" generalizes to "homology class is fixed by `∂₁∂₂ = 0`
while the minimal representative weight is a cellulation functional" — distance is a *minimum over
a homology coset*, never a coset invariant. **Why now?** The 1D kernel-characterization technique
and the catalog's entrywise Hodge decomposition already give both halves (`ker ∂₁`, `im ∂₂`);
only the coset-minimization Finset argument is new, and it is decidable on fixed grids.

### 2. Triangulation-refinement invariance of `k`, formalized as a chain homotopy

We proved `k` is *constant* under the specific refinement `C_n → C_{2n}`. Conjecture and prove
the general statement: any edge-subdivision of a finite graph induces a chain isomorphism on
`H₁` over `ZMod 2`, hence preserves `k` exactly, while multiplying every cycle's length (and thus
the distance) by the subdivision factor. **The key insight is** that subdivision is the discrete
shadow of triangulation refinement, and homology's refinement-invariance is precisely the
"topology-only" half of the conjecture — so the split is *forced*, not accidental. **Why now?**
Mathlib's `SimpleGraph` plus the cycle-space kernel description make subdivision a concrete map
on `Fin`-indexed chain spaces; the homotopy is an explicit `ZMod 2`-linear bijection.

### 3. Spectral certification: distance from the Laplacian spectrum, not the Betti number

Define the graph Hodge Laplacian `Δ = ∂₁ᵀ∂₁` on `1`-chains and prove that its kernel dimension
equals `k` (rank–nullity, exactly the catalog `HodgeBettiRank` mechanism) while a *spectral gap*
bound lower-bounds the distance: `d ≥ f(λ_min nonzero eigenvalue)`. Then exhibit two graphs with
identical `k` but different spectral gaps witnessing different `d`. **The key insight is** that
"smooth-structure-sensitive spectral invariants" in the conjecture become honest Laplacian
spectra here, and the harmonic kernel (topology) and spectral gap (geometry) are computed by the
*same operator* — unifying the two invariants in one object. **Why now?** The catalog already has
the discrete Hodge Laplacian and its rank–nullity Betti theorem; adding an eigenvalue/distance
inequality is a self-contained linear-algebra extension over `ℝ` or `ZMod 2`.

### 4. A decidable code-equivalence checker and its incompleteness for distance

Build a computable function `codeEquiv : ChainComplex → ChainComplex → Bool` deciding equality of
logical dimension `k`, and prove it is *correct for `k`* (`decide`-backed) but *provably blind to
`d`*: there exist inputs it accepts whose distances differ (instantiate with `C₃`, `C₄`). **The
key insight is** that algorithmic topological-equivalence testing is sound but strictly weaker
than geometric-equivalence testing — the formal analogue of "homeomorphism is decidable data,
diffeomorphism is not." **Why now?** Everything here is finite and `Decidable`; the catalog's
constructive/algorithmic mandate is directly served, and the falsifier (a single distance gap) is
already proved as `distance_not_homological_invariant`.

### 5. Higher-dimensional obstruction: when does `k` *force* `d`?

Conjecture the converse boundary: characterize the chain complexes for which `d` *is* determined
by `k` (e.g. complexes whose nonzero homology classes all have the same minimal weight), and prove
the cycle codes `C_n` are the *extremal* family saturating distance for `k = 1`. Refute the naive
"distance is always free" reading by proving that for `k = 0` (acyclic complexes) the distance is
vacuously `∞`/undefined — a genuine collapse. **The key insight is** that the split is not
universal: there is a sharp dividing line between complexes where geometry adds information and
where it cannot, and locating it tells you exactly when exotic smooth structure could matter.
**Why now?** The `cycleDistance` `sInf`-over-weight-set definition already exposes the empty-set
(acyclic) edge case, so the collapse direction is immediate, and the extremal characterization is
a clean optimization statement over the proved `{0, 𝟙}` kernel.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Conceptual Unifier: Duality & Representation Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Duality & Representation)**. Search for deep dualities, representation theorems, and dual translations (such as Stone duality, Gelfand duality, or Fourier/Pontryagin dualities).

### RESEARCH CORE METHODOLOGY:
1. **Dual Translations**: Look for dual formulations of your mathematical objects. Translate geometric or topological spaces into algebraic representations (e.g. rings of functions), and algebraic structures back into geometric spaces.
2. **Representation Theorems**: Seek to represent abstract algebraic or topological structures as concrete operations on simpler, well-understood spaces (e.g. matrices, sets, or functions).
3. **Spectral Perspectives**: Leverage spectral properties, duality pairings, and transform methods to translate hard problems in the primary space into easier problems in the dual space.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
