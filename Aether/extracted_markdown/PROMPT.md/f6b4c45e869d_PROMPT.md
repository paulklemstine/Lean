
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

**Title**: The file `Physics/TopologicalOrderGenus.lean` establishes, for an *abelian* anyo
**Domain**: Applications
**Mathematical framing**: # Future Directions: Topological Order, Genus Degeneracy, and Modular Data

The file `Physics/TopologicalOrderGenus.lean` establishes, for an *abelian* anyon theory
whose anyon types form a finite abelian group `A` with `d = |A|`:

* the ground-state degeneracy law `GSD A g = d ^ g` on a genus-`g` surface, its
  per-handle recursion, connected-sum multiplicativity, and identification with the complex
  dimension of the free ground-state Hilbert space `(Fin g → A) →₀ ℂ`; and
* the unitarity of the modular S-matrix `S_{a,b} = (1/√d) · S_a(b)` built from a nondegenerate
  braiding bicharacter, via character orthogonality on `A`.

It extends the catalog result `ToricCode.ground_space_dim` (the `ℤ/2` toric code, with its
fixed `[[2L², 2, L]]` parameters) from one concrete lattice model to *all* abelian anyon
theories and *all* genera, and it adds the missing braiding/modular-data half of the story.
The directions below push toward the full anyon–TQFT dictionary.

## Direction 1 — A concrete modular braiding for cyclic anyons `ZMod n`

The `ModularBraiding` structure currently takes the braiding as data; we should *construct* it.
For `A = ZMod n`, define `S_a` to be the additive character `b ↦ exp(2πi · a·b / n)` and prove
it is a nondegenerate bicharacter, producing an explicit term `ModularBraiding (ZMod n)` and
hence an explicit unitary S-matrix `S_{a,b} = (1/√n) exp(2πi ab/n)` — the discrete Fourier
matrix. **The key insight is** that nondegeneracy of the braiding is exactly the statement that
`exp(2πi ab/n) = 1` for all `b` forces `a = 0`, i.e. the primitivity of the `n`-th root of unity,
which Mathlib already supports through `ZMod.isPrimitiveRoot` / `AddChar` on `ZMod n`.
**Why now?** The abstract `smatrix_unitary` theorem is already proved, so a single realizability
lemma immediately upgrades it from "for any modular braiding" to "for the canonical cyclic
anyon model," turning a conditional theorem into an unconditional, fully worked example.

## Direction 2 — The T-matrix and an `SL(2,ℤ)` representation on the torus

Adjoin the topological spin / T-matrix `T_{a,b} = θ_a · δ_{a,b}` with `θ_a = exp(πi q(a))` for a
quadratic refinement `q` of the braiding, and prove the modular relations `(ST)³ = c·S²` and
`S⁴ = 1` on the `GSD A 1 = |A|`-dimensional torus ground-state space. **The key insight is** that
the torus ground states carry a projective representation of the mapping class group
`SL(2,ℤ) = π₀ Diff⁺(T²)`, with `S` and `T` the images of the two Dehn-twist generators, so the
modular relations are *forced* by the topology of the torus rather than postulated.
**Why now?** With `smatrix_unitary` and a diagonal `T` in hand, the relations reduce to finite
Gauss-sum identities over `A`, exactly the regime where Mathlib's `AddChar`/`gaussSum` machinery
is strong; this is the smallest nontrivial mapping-class-group representation to formalize.

## Direction 3 — The Verlinde formula and non-abelian genus degeneracy

Generalize `GSD_eq_pow` to the full Verlinde formula
`GSD(g) = ∑_a (S_{0,a})^{2-2g}`, which for abelian theories collapses to `d^g` (all `S_{0,a} =
1/√d`) but for non-abelian modular categories yields the dimension of the space of genus-`g`
conformal blocks, and prove the Verlinde fusion identity `N_{ab}^c = ∑_x S_{ax}S_{bx}\bar S_{cx}/S_{0x}`.
**The key insight is** that diagonalizing the commutative fusion algebra by the unitary S-matrix
turns the topological recursion (cutting a genus-`g` surface into pairs of pants) into an
eigenvalue computation, so degeneracy is a *trace* `∑_a λ_a^{2g-2}` of the fusion operators.
**Why now?** Our `smatrix_unitary` provides precisely the orthonormal eigenbasis the Verlinde
formula needs; extending the anyon model from a group to a based commutative `ℂ`-algebra with
nonnegative integer structure constants is the natural next data-structure step.

## Direction 4 — Toric code as an instance and the hyperbolic braiding form

Instantiate the abstract theory at `A = (ZMod 2) × (ZMod 2)` (the four anyons `1, e, m, em`) and
prove that this reproduces `ToricCode.ground_space_dim`: `GSD A g = 4^g`, in particular `4` on the
torus, matching the existing `[[2L², 2, L]]` analysis. Then show the toric-code braiding is the
*hyperbolic* bicharacter `((e₁,m₁),(e₂,m₂)) ↦ (-1)^{e₁m₂ + e₂m₁}`, and verify it is nondegenerate,
yielding a `ModularBraiding ((ZMod 2)²)`. **The key insight is** that the mutual `e`–`m` statistics
of the toric code are encoded by a symplectic (hyperbolic) form, whose nondegeneracy is the
algebraic shadow of the geometric linking of `e` and `m` loops on the torus.
**Why now?** It is a direct cross-file bridge: it ties the new abstract degeneracy/braiding
theorems to the already-formalized chain-complex toric code, validating both formalizations
against each other on the canonical example.

## Direction 5 — Degeneracy as a topological invariant: ground states from `H¹(Σ_g; A)`

Replace the chosen basis `Fin g → A` by the gauge-theoretic ground-state space
`H¹(Σ_g; A) ≅ A^{2g}` of flat `A`-connections and prove the discrete-gauge-theory degeneracy
`|A|^{2g}` (Dijkgraaf–Witten), then show our `d^g` law is the *holomorphic/chiral half* obtained
after imposing a Lagrangian (maximal isotropic) polarization of the intersection form on
`H¹`. **The key insight is** that the symplectic intersection pairing on `H¹(Σ_g; A)` makes the
full flat-connection space `A^{2g}` a phase space, and quantization picks out a Lagrangian of
dimension `g`, recovering exactly the `d^g` we proved. **Why now?** Mathlib's group-cohomology and
finite-abelian-group APIs are mature enough to define `H¹(Σ_g; A)` for the surface group
presentation `⟨a_i,b_i | ∏[a_i,b_i]⟩`, so the `|A|^{2g}` count is within reach and would place
our combinatorial `GSD` on a genuinely topological footing.

**Concept description**: # Future Directions: Topological Order, Genus Degeneracy, and Modular Data

The file `Physics/TopologicalOrderGenus.lean` establishes, for an *abelian* anyon theory
whose anyon types form a finite abelian group `A` with `d = |A|`:

* the ground-state degeneracy law `GSD A g = d ^ g` on a genus-`g` surface, its
  per-handle recursion, connected-sum multiplicativity, and identification with the complex
  dimension of the free ground-state Hilbert space `(Fin g → A) →₀ ℂ`; and
* the unitarity of the modular S-matrix `S_{a,b} = (1/√d) · S_a(b)` built from a nondegenerate
  braiding bicharacter, via character orthogonality on `A`.

It extends the catalog result `ToricCode.ground_space_dim` (the `ℤ/2` toric code, with its
fixed `[[2L², 2, L]]` parameters) from one concrete lattice model to *all* abelian anyon
theories and *all* genera, and it adds the missing braiding/modular-data half of the story.
The directions below push toward the full anyon–TQFT dictionary.

## Direction 1 — A concrete modular braiding for cyclic anyons `ZMod n`

The `ModularBraiding` structure currently takes the braiding as data; we should *construct* it.
For `A = ZMod n`, define `S_a` to be the additive character `b ↦ exp(2πi · a·b / n)` and prove
it is a nondegenerate bicharacter, producing an explicit term `ModularBraiding (ZMod n)` and
hence an explicit unitary S-matrix `S_{a,b} = (1/√n) exp(2πi ab/n)` — the discrete Fourier
matrix. **The key insight is** that nondegeneracy of the braiding is exactly the statement that
`exp(2πi ab/n) = 1` for all `b` forces `a = 0`, i.e. the primitivity of the `n`-th root of unity,
which Mathlib already supports through `ZMod.isPrimitiveRoot` / `AddChar` on `ZMod n`.
**Why now?** The abstract `smatrix_unitary` theorem is already proved, so a single realizability
lemma immediately upgrades it from "for any modular braiding" to "for the canonical cyclic
anyon model," turning a conditional theorem into an unconditional, fully worked example.

## Direction 2 — The T-matrix and an `SL(2,ℤ)` representation on the torus

Adjoin the topological spin / T-matrix `T_{a,b} = θ_a · δ_{a,b}` with `θ_a = exp(πi q(a))` for a
quadratic refinement `q` of the braiding, and prove the modular relations `(ST)³ = c·S²` and
`S⁴ = 1` on the `GSD A 1 = |A|`-dimensional torus ground-state space. **The key insight is** that
the torus ground states carry a projective representation of the mapping class group
`SL(2,ℤ) = π₀ Diff⁺(T²)`, with `S` and `T` the images of the two Dehn-twist generators, so the
modular relations are *forced* by the topology of the torus rather than postulated.
**Why now?** With `smatrix_unitary` and a diagonal `T` in hand, the relations reduce to finite
Gauss-sum identities over `A`, exactly the regime where Mathlib's `AddChar`/`gaussSum` machinery
is strong; this is the smallest nontrivial mapping-class-group representation to formalize.

## Direction 3 — The Verlinde formula and non-abelian genus degeneracy

Generalize `GSD_eq_pow` to the full Verlinde formula
`GSD(g) = ∑_a (S_{0,a})^{2-2g}`, which for abelian theories collapses to `d^g` (all `S_{0,a} =
1/√d`) but for non-abelian modular categories yields the dimension of the space of genus-`g`
conformal blocks, and prove the Verlinde fusion identity `N_{ab}^c = ∑_x S_{ax}S_{bx}\bar S_{cx}/S_{0x}`.
**The key insight is** that diagonalizing the commutative fusion algebra by the unitary S-matrix
turns the topological recursion (cutting a genus-`g` surface into pairs of pants) into an
eigenvalue computation, so degeneracy is a *trace* `∑_a λ_a^{2g-2}` of the fusion operators.
**Why now?** Our `smatrix_unitary` provides precisely the orthonormal eigenbasis the Verlinde
formula needs; extending the anyon model from a group to a based commutative `ℂ`-algebra with
nonnegative integer structure constants is the natural next data-structure step.

## Direction 4 — Toric code as an instance and the hyperbolic braiding form

Instantiate the abstract theory at `A = (ZMod 2) × (ZMod 2)` (the four anyons `1, e, m, em`) and
prove that this reproduces `ToricCode.ground_space_dim`: `GSD A g = 4^g`, in particular `4` on the
torus, matching the existing `[[2L², 2, L]]` analysis. Then show the toric-code braiding is the
*hyperbolic* bicharacter `((e₁,m₁),(e₂,m₂)) ↦ (-1)^{e₁m₂ + e₂m₁}`, and verify it is nondegenerate,
yielding a `ModularBraiding ((ZMod 2)²)`. **The key insight is** that the mutual `e`–`m` statistics
of the toric code are encoded by a symplectic (hyperbolic) form, whose nondegeneracy is the
algebraic shadow of the geometric linking of `e` and `m` loops on the torus.
**Why now?** It is a direct cross-file bridge: it ties the new abstract degeneracy/braiding
theorems to the already-formalized chain-complex toric code, validating both formalizations
against each other on the canonical example.

## Direction 5 — Degeneracy as a topological invariant: ground states from `H¹(Σ_g; A)`

Replace the chosen basis `Fin g → A` by the gauge-theoretic ground-state space
`H¹(Σ_g; A) ≅ A^{2g}` of flat `A`-connections and prove the discrete-gauge-theory degeneracy
`|A|^{2g}` (Dijkgraaf–Witten), then show our `d^g` law is the *holomorphic/chiral half* obtained
after imposing a Lagrangian (maximal isotropic) polarization of the intersection form on
`H¹`. **The key insight is** that the symplectic intersection pairing on `H¹(Σ_g; A)` makes the
full flat-connection space `A^{2g}` a phase space, and quantization picks out a Lagrangian of
dimension `g`, recovering exactly the `d^g` we proved. **Why now?** Mathlib's group-cohomology and
finite-abelian-group APIs are mature enough to define `H¹(Σ_g; A)` for the surface group
presentation `⟨a_i,b_i | ∏[a_i,b_i]⟩`, so the `|A|^{2g}` count is within reach and would place
our combinatorial `GSD` on a genuinely topological footing.

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
