
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

**Title**: Catalog's arithmetic mirror-symmetry skeleton
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Calabi–Yau Fourfold Hodge Combinatorics and Arithmetic Mirror Symmetry

## Synthesis

This cycle extended the catalog's arithmetic mirror-symmetry skeleton
(`Geometry.MirrorSymmetry.ArithmeticMirror`, with its `eulerChar` / `mirror`
reflection machinery and the threefold relation `χ(mirror Y) = −χ(X)`) from
complex dimension `3` to dimension `4`, the case actively studied in F-theory
compactifications. The new file
`Geometry.MirrorSymmetry.CalabiYauFourfold` packages the four independent Hodge
numbers `h^{1,1}, h^{2,1}, h^{3,1}, h^{2,2}` of a smooth Calabi–Yau fourfold into
a structure `CY4`, builds the full `ℕ → ℕ → ℤ` Hodge diamond from the D4
symmetries (Hodge symmetry, Serre duality, Calabi–Yau vanishing), and proves the
combinatorial backbone of fourfold mirror symmetry directly over the catalog's
`eulerChar`.

## Results Summary

All six results are proven with `sorry = 0` and only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`):

1. `CY4.eulerChar_eq` — the bare combinatorial Euler characteristic of the
   fourfold diamond is `χ = 4 + 2 h¹¹ + 2 h³¹ + h²² − 4 h²¹` (no Chern input).
2. `CY4.mirror_diamond_eq` — the catalog reflection `ArithmeticMirror.mirror 4`
   realizes, on the support `p,q ≤ 4`, the F-theory mirror map `h^{1,1} ↔ h^{3,1}`
   with `h^{2,1}, h^{2,2}` fixed.
3. `CY4.swap_involutive` — that mirror exchange is an involution (`ℤ/2`-action).
4. `CY4.eulerChar_swap_invariant` and `CY4.eulerChar_mirror_invariant` — for the
   *even* dimension `4`, `χ(mirror X) = χ(X)`, the `(-1)^4 = 1` shadow of the
   catalog `ArithmeticMirror.eulerChar_mirror`, in sharp contrast to the
   threefold sign flip `ArithmeticMirror.eulerChar_mirror_threefold`.
5. `CY4.eulerChar_KLRY` — under the Klemm–Lian–Roan–Yau Chern relation
   `h²² = 2(22 + 2h¹¹ + 2h³¹ − h²¹)`, the Euler characteristic collapses to the
   celebrated F-theory formula `χ = 6(8 + h¹¹ + h³¹ − h²¹)`.

The unification observed is that *parity of the complex dimension* is the single
parameter governing the mirror behaviour of the Euler characteristic: odd
dimensions flip the sign, even dimensions fix it, and both are the `u = v = 1`
specializations of the catalog `eulerChar_mirror` / `HodgeEPolynomial`
functional equations.

## Bold, Falsifiable Research Directions

### 1. Closed-form `χ` for every Calabi–Yau `n`-fold diamond

The fourfold computation `CY4.eulerChar_eq` was a finite `Finset.sum_range_succ`
expansion of a `match`-defined diamond. Conjecture: for *every* `n` there is a
single uniform linear form, computed from the Hodge–symmetric / Serre-dual
orbit structure of the index square `{0,…,n}²`, giving
`χ(X_n) = Σ_{orbits O} (-1)^{p+q} |O| · h_O`, and this form is mirror-symmetric
(invariant under `p ↦ n−p`) iff `n` is even.

The key insight is that the D4 symmetry group acting on the index square `{0,…,n}²`
partitions the Hodge numbers into orbits whose alternating-sign-weighted sizes are
*computable as a function of `n` alone*, so `χ` is a fixed `ℤ`-linear functional of
the independent Hodge numbers, and the catalog sign `(-1)^n` reading off
`eulerChar_mirror` controls its mirror parity.

Why now? `CY4.eulerChar_eq` and `ArithmeticMirror.projHodge_eulerChar` show the
method works in concrete dimensions; the only missing ingredient is a generic
`Finset`-orbit bookkeeping lemma, which is well within Lean's reach. This would be
the first *dimension-uniform* formal Hodge–Euler theorem in the catalog.

### 2. The middle Hodge number `h^{n/2,n/2}` as the unique mirror-fixed degree of freedom

For even `n`, mirror symmetry `h^{p,q} ↦ h^{n−p,q}` fixes precisely the central
column `p = n/2`. Conjecture: among the independent Hodge numbers of a CY
`n`-fold (even `n`), the mirror involution has exactly one nontrivially-fixed
"genuinely middle" number `h^{n/2,n/2}` (here `h^{2,2}`), and `χ` depends on it
with coefficient `+1` while all paired numbers enter with even coefficients.

The key insight is that `CY4.eulerChar_eq` already exhibits this: `h^{2,2}` has
coefficient `1` (odd) whereas `h^{1,1}, h^{3,1}, h^{2,1}` all have even
coefficients `2, 2, −4`; this parity asymmetry is forced by `h^{2,2}` being the
unique mirror-fixed point of the reflection, an essentially homotopy-theoretic
statement about the fixed locus of a `ℤ/2`-action (`CY4.swap_involutive`).

Why now? The involution and its fixed structure are already formalized
(`CY4.swap`, `CY4.swap_involutive`); promoting "fixed point of the `ℤ/2`-action"
to a general statement about the central column is a clean combinatorial lemma
that connects mirror symmetry to equivariant fixed-point counting.

### 3. Integrality / congruence constraints on `χ` of CY fourfolds

The KLRY relation makes `χ = 6(8 + h¹¹ + h³¹ − h²¹)`, so `6 ∣ χ` and
`χ ≡ 48 (mod 6·gcd)`. Conjecture: every CY fourfold satisfying the Chern
constraint has `χ` divisible by `6`, and more refined congruences
(`χ ≡ 0 mod 24` under additional spin/flux quantization) hold; these are exactly
the F-theory tadpole-cancellation divisibility conditions.

The key insight is that `CY4.eulerChar_KLRY` already exposes the factor `6`
literally as a ring identity, so divisibility becomes `Dvd` facts about the
explicit linear form rather than geometry; the deeper `24 ∣ χ` should follow by
combining the Chern substitution with a parity constraint on `h^{2,1}`.

Why now? The exact integer identity is in hand; the next step is purely
arithmetic (`omega` / `Int.dvd` reasoning on the closed form), and it ports the
F-theory flux-quantization folklore into a fully checked statement.

### 4. Mirror-pair Euler relation across dimensions as one parity theorem

Direction unifying the threefold (`eulerChar_mirror_threefold`, `χ ↦ −χ`) and
fourfold (`eulerChar_mirror_invariant`, `χ ↦ χ`) results. Conjecture: for a
mirror pair `(X, X̌)` of CY `n`-folds, `χ(X̌) = (-1)^n χ(X)`, and consequently
`χ(X) + (-1)^{n+1} χ(X̌) = 0` is the universal "mirror Euler law", whose `n=3`
instance recovers `χ(X) = −χ(X̌)` (mirror swaps `h^{1,1} ↔ h^{2,1}`).

The key insight is that this is literally `ArithmeticMirror.eulerChar_mirror`
read with the dimension parity as the only variable, so a single theorem
parameterized by `n` subsumes every dimension-specific corollary currently stated
separately in the catalog.

Why now? Both endpoint cases are already formal (`n=3` in `ArithmeticMirror`,
`n=4` here); abstracting them into one `(-1)^n`-indexed law is a short
generalization that removes duplication and makes the parity dichotomy a theorem
rather than a pattern.

### 5. Batyrev mirror construction: `h^{1,1} ↔ h^{n−1,1}` from polar-dual polytopes

The combinatorial `CY4.swap` (`h^{1,1} ↔ h^{3,1}`) is the numerical shadow of
Batyrev's polar duality `Δ ↔ Δ°` on reflexive polytopes. Conjecture: for a toric
CY hypersurface in dimension `n`, `h^{1,1}(X)` equals a lattice-point count of `Δ`
and `h^{n−1,1}(X)` the dual count of `Δ°`, so `Batyrev mirror` *induces* exactly
`CY4.swap` (and its `n`-fold analogue) at the level of Hodge data.

The key insight is that `CY4.mirror_diamond_eq` shows the abstract reflection
already produces the right swap, so all that remains is to *define* the two
lattice-point functionals and prove they are exchanged by polar duality — an
Ehrhart-style identity, not a deformation argument.

Why now? Lean's `Finset`/polytope tooling supports lattice-point counting, and
the target identity (`#interior(Δ) ↔ #interior(Δ°)` paired with facet counts) is a
finite, falsifiable statement testable on the quintic and its Batyrev mirror
before attempting the general reflexive case.

**Concept description**: # Future Directions: Calabi–Yau Fourfold Hodge Combinatorics and Arithmetic Mirror Symmetry

## Synthesis

This cycle extended the catalog's arithmetic mirror-symmetry skeleton
(`Geometry.MirrorSymmetry.ArithmeticMirror`, with its `eulerChar` / `mirror`
reflection machinery and the threefold relation `χ(mirror Y) = −χ(X)`) from
complex dimension `3` to dimension `4`, the case actively studied in F-theory
compactifications. The new file
`Geometry.MirrorSymmetry.CalabiYauFourfold` packages the four independent Hodge
numbers `h^{1,1}, h^{2,1}, h^{3,1}, h^{2,2}` of a smooth Calabi–Yau fourfold into
a structure `CY4`, builds the full `ℕ → ℕ → ℤ` Hodge diamond from the D4
symmetries (Hodge symmetry, Serre duality, Calabi–Yau vanishing), and proves the
combinatorial backbone of fourfold mirror symmetry directly over the catalog's
`eulerChar`.

## Results Summary

All six results are proven with `sorry = 0` and only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`):

1. `CY4.eulerChar_eq` — the bare combinatorial Euler characteristic of the
   fourfold diamond is `χ = 4 + 2 h¹¹ + 2 h³¹ + h²² − 4 h²¹` (no Chern input).
2. `CY4.mirror_diamond_eq` — the catalog reflection `ArithmeticMirror.mirror 4`
   realizes, on the support `p,q ≤ 4`, the F-theory mirror map `h^{1,1} ↔ h^{3,1}`
   with `h^{2,1}, h^{2,2}` fixed.
3. `CY4.swap_involutive` — that mirror exchange is an involution (`ℤ/2`-action).
4. `CY4.eulerChar_swap_invariant` and `CY4.eulerChar_mirror_invariant` — for the
   *even* dimension `4`, `χ(mirror X) = χ(X)`, the `(-1)^4 = 1` shadow of the
   catalog `ArithmeticMirror.eulerChar_mirror`, in sharp contrast to the
   threefold sign flip `ArithmeticMirror.eulerChar_mirror_threefold`.
5. `CY4.eulerChar_KLRY` — under the Klemm–Lian–Roan–Yau Chern relation
   `h²² = 2(22 + 2h¹¹ + 2h³¹ − h²¹)`, the Euler characteristic collapses to the
   celebrated F-theory formula `χ = 6(8 + h¹¹ + h³¹ − h²¹)`.

The unification observed is that *parity of the complex dimension* is the single
parameter governing the mirror behaviour of the Euler characteristic: odd
dimensions flip the sign, even dimensions fix it, and both are the `u = v = 1`
specializations of the catalog `eulerChar_mirror` / `HodgeEPolynomial`
functional equations.

## Bold, Falsifiable Research Directions

### 1. Closed-form `χ` for every Calabi–Yau `n`-fold diamond

The fourfold computation `CY4.eulerChar_eq` was a finite `Finset.sum_range_succ`
expansion of a `match`-defined diamond. Conjecture: for *every* `n` there is a
single uniform linear form, computed from the Hodge–symmetric / Serre-dual
orbit structure of the index square `{0,…,n}²`, giving
`χ(X_n) = Σ_{orbits O} (-1)^{p+q} |O| · h_O`, and this form is mirror-symmetric
(invariant under `p ↦ n−p`) iff `n` is even.

The key insight is that the D4 symmetry group acting on the index square `{0,…,n}²`
partitions the Hodge numbers into orbits whose alternating-sign-weighted sizes are
*computable as a function of `n` alone*, so `χ` is a fixed `ℤ`-linear functional of
the independent Hodge numbers, and the catalog sign `(-1)^n` reading off
`eulerChar_mirror` controls its mirror parity.

Why now? `CY4.eulerChar_eq` and `ArithmeticMirror.projHodge_eulerChar` show the
method works in concrete dimensions; the only missing ingredient is a generic
`Finset`-orbit bookkeeping lemma, which is well within Lean's reach. This would be
the first *dimension-uniform* formal Hodge–Euler theorem in the catalog.

### 2. The middle Hodge number `h^{n/2,n/2}` as the unique mirror-fixed degree of freedom

For even `n`, mirror symmetry `h^{p,q} ↦ h^{n−p,q}` fixes precisely the central
column `p = n/2`. Conjecture: among the independent Hodge numbers of a CY
`n`-fold (even `n`), the mirror involution has exactly one nontrivially-fixed
"genuinely middle" number `h^{n/2,n/2}` (here `h^{2,2}`), and `χ` depends on it
with coefficient `+1` while all paired numbers enter with even coefficients.

The key insight is that `CY4.eulerChar_eq` already exhibits this: `h^{2,2}` has
coefficient `1` (odd) whereas `h^{1,1}, h^{3,1}, h^{2,1}` all have even
coefficients `2, 2, −4`; this parity asymmetry is forced by `h^{2,2}` being the
unique mirror-fixed point of the reflection, an essentially homotopy-theoretic
statement about the fixed locus of a `ℤ/2`-action (`CY4.swap_involutive`).

Why now? The involution and its fixed structure are already formalized
(`CY4.swap`, `CY4.swap_involutive`); promoting "fixed point of the `ℤ/2`-action"
to a general statement about the central column is a clean combinatorial lemma
that connects mirror symmetry to equivariant fixed-point counting.

### 3. Integrality / congruence constraints on `χ` of CY fourfolds

The KLRY relation makes `χ = 6(8 + h¹¹ + h³¹ − h²¹)`, so `6 ∣ χ` and
`χ ≡ 48 (mod 6·gcd)`. Conjecture: every CY fourfold satisfying the Chern
constraint has `χ` divisible by `6`, and more refined congruences
(`χ ≡ 0 mod 24` under additional spin/flux quantization) hold; these are exactly
the F-theory tadpole-cancellation divisibility conditions.

The key insight is that `CY4.eulerChar_KLRY` already exposes the factor `6`
literally as a ring identity, so divisibility becomes `Dvd` facts about the
explicit linear form rather than geometry; the deeper `24 ∣ χ` should follow by
combining the Chern substitution with a parity constraint on `h^{2,1}`.

Why now? The exact integer identity is in hand; the next step is purely
arithmetic (`omega` / `Int.dvd` reasoning on the closed form), and it ports the
F-theory flux-quantization folklore into a fully checked statement.

### 4. Mirror-pair Euler relation across dimensions as one parity theorem

Direction unifying the threefold (`eulerChar_mirror_threefold`, `χ ↦ −χ`) and
fourfold (`eulerChar_mirror_invariant`, `χ ↦ χ`) results. Conjecture: for a
mirror pair `(X, X̌)` of CY `n`-folds, `χ(X̌) = (-1)^n χ(X)`, and consequently
`χ(X) + (-1)^{n+1} χ(X̌) = 0` is the universal "mirror Euler law", whose `n=3`
instance recovers `χ(X) = −χ(X̌)` (mirror swaps `h^{1,1} ↔ h^{2,1}`).

The key insight is that this is literally `ArithmeticMirror.eulerChar_mirror`
read with the dimension parity as the only variable, so a single theorem
parameterized by `n` subsumes every dimension-specific corollary currently stated
separately in the catalog.

Why now? Both endpoint cases are already formal (`n=3` in `ArithmeticMirror`,
`n=4` here); abstracting them into one `(-1)^n`-indexed law is a short
generalization that removes duplication and makes the parity dichotomy a theorem
rather than a pattern.

### 5. Batyrev mirror construction: `h^{1,1} ↔ h^{n−1,1}` from polar-dual polytopes

The combinatorial `CY4.swap` (`h^{1,1} ↔ h^{3,1}`) is the numerical shadow of
Batyrev's polar duality `Δ ↔ Δ°` on reflexive polytopes. Conjecture: for a toric
CY hypersurface in dimension `n`, `h^{1,1}(X)` equals a lattice-point count of `Δ`
and `h^{n−1,1}(X)` the dual count of `Δ°`, so `Batyrev mirror` *induces* exactly
`CY4.swap` (and its `n`-fold analogue) at the level of Hodge data.

The key insight is that `CY4.mirror_diamond_eq` shows the abstract reflection
already produces the right swap, so all that remains is to *define* the two
lattice-point functionals and prove they are exchanged by polar duality — an
Ehrhart-style identity, not a deformation argument.

Why now? Lean's `Finset`/polytope tooling supports lattice-point counting, and
the target identity (`#interior(Δ) ↔ #interior(Δ°)` paired with facet counts) is a
finite, falsifiable statement testable on the quintic and its Batyrev mirror
before attempting the general reflexive case.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
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
