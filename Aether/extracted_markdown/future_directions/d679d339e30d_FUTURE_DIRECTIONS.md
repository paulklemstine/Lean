# FUTURE_DIRECTIONS — Poincaré Conjecture Revisited: 4D Smooth

## Synthesis

This cycle isolated the *algebraic skeleton* of the smooth 4-manifold story. The
deepest tools of the field — Donaldson's instanton invariants, Rokhlin's theorem,
Freedman's classification, and Seiberg–Witten theory — are not yet in Mathlib and
are far out of reach for a single cycle. But they all pivot on one finite, fully
formalizable object: the **intersection form** `Q_M`, a symmetric unimodular
integral bilinear form on `H²(M;ℤ)`. We formalized the invariant that, more than
rank, signature, or determinant, controls smoothability: the **even/odd type**
(type II vs type I). We proved that the type is a ℤ-congruence invariant
(`congr_preserves_evenForm`), that "even diagonal + symmetric" forces type II
(`isEvenForm_of_symm_diag`), and — the headline — that the **E₈ form is not
integrally congruent to the standard diagonal form** `I₈` despite matching it in
rank (8), signature (8), and determinant (1) (`E8_not_congruent_identity`). This
is exactly the lattice-level content of Donaldson's no-E₈ obstruction: a smooth
closed simply-connected definite 4-manifold must have the diagonal (odd) form, so
no smooth manifold realizes the even E₈ — while Freedman's *topological*
E₈-manifold shows the homeomorphism class is nonempty. The same machinery, at
rank 2, separates `S²×S²` (hyperbolic form `H`, even) from `ℂP²#ℂP²` (form `I₂`,
odd).

The structural insight that emerged is sharper than the textbook statement: the
non-congruence needs **only evenness**, and holds for *arbitrary* integer change
matrices `P` (no invertibility, no determinant, no positive-definiteness). Every
attempt to obstruct via rank/signature/determinant is provably doomed for E₈,
because over ℝ the two forms are congruent. The parity argument is the unique
surviving invariant — and it is precisely the invariant that smooth topology
"sees" and real/rational linear algebra does not.

What we could *not* yet close is the quantitative law behind these examples: the
algebraic Rokhlin / van der Blij theorem that an even unimodular form has
signature ≡ 0 (mod 8), realized minimally by E₈. We stated its positive-definite
specialization (`posdef_even_unimodular_rank_div_eight`: rank divisible by 8) as a
conjecture, because the honest proof needs ℤ-diagonalization or theta-series /
modular-form machinery not yet built here. The gap between the algebraic mod-8 law
and the *smooth* mod-16 Rokhlin theorem for spin 4-manifolds is itself a numerical
shadow of the exotic phenomena that keep the smooth 4D Poincaré conjecture open.

## Results Summary

- `isEvenForm_of_symm_diag`: **proved** — a symmetric integer Gram matrix with even diagonal defines an even (type II) quadratic form; the workhorse type-II characterization.
- `congr_preserves_evenForm`: **proved** — evenness/type-II is invariant under integral congruence `A ↦ Pᵀ A P` (change of ℤ-basis of `H²`), for arbitrary `P`.
- `identity_not_evenForm` / `identity8_not_evenForm`: **proved** — the standard diagonal forms `I₂`, `I₈` are odd (type I).
- `hyperbolic_evenForm` / `E8_evenForm`: **proved** — the hyperbolic form `H` and the E₈ Cartan form are even (type II).
- `hyperbolic_not_congruent_identity`: **proved** — `H` (form of `S²×S²`) is not ℤ-congruent to `I₂` (form of `ℂP²#ℂP²`); a smooth distinction by type at rank 2.
- `E8_not_congruent_identity`: **proved** — the E₈ form is not ℤ-congruent to `I₈` despite equal rank/signature/determinant; the lattice core of Donaldson's no-E₈ obstruction.
- `posdef_even_unimodular_rank_div_eight`: **conjecture** — a positive-definite even unimodular form has rank divisible by 8 (algebraic Rokhlin / van der Blij; deferred, `sorry`).

## Research Directions

### Direction 1: Prove the positive-definite mod-8 rank law (van der Blij)
**Hypothesis**: Every positive-definite even unimodular symmetric integer form has
rank `n` divisible by 8 (`posdef_even_unimodular_rank_div_eight`).
**Test**: Formalize the theta series `θ_A(τ) = ∑_v exp(πi τ vᵀAv)` as a modular
form of weight `n/2` for `SL₂(ℤ)` (even unimodular ⇒ level 1), and invoke that the
weight of a nonzero level-1 modular form is an even integer ≥ 0, forcing `4 ∣ n/2`,
i.e. `8 ∣ n`. A more elementary route: prove every positive-definite unimodular
form is ℤ-equivalent to `I_n ⊕ (even part)` and run a direct mod-8 Gauss-sum
argument on the discriminant form.
**Why now**: We already have the type predicate `IsEvenForm`, its congruence
invariance, and `IsPosDef`. The statement is fully formalized and true; only the
proof engine is missing.
**If true**: Gives a Mathlib-level Rokhlin-type theorem and immediately re-derives
`E8_not_congruent_identity` as the `n = 8` boundary case from a general law.
**If false**: Would expose a missing hypothesis (e.g. our `IsPosDef`/unimodularity
encoding is too weak), teaching us the precise integrality assumptions Rokhlin needs.

### Direction 2: The signed (indefinite) mod-8 signature law
**Hypothesis**: For any even unimodular symmetric integer form, the signature
`σ = b⁺ − b⁻` satisfies `8 ∣ σ`.
**Test**: First formalize `signature` honestly via Sylvester's law of inertia
(diagonalize over ℝ/ℚ and count signs), prove it is a congruence invariant, then
reduce to Direction 1 using the indefinite classification `Q ≅ p·H ⊕ q·(±E₈)`.
**Why now**: `congr_preserves_evenForm` is the template — signature should be the
*second* congruence invariant we formalize, and `hyperbolic_evenForm` already gives
the signature-0 building block `H`.
**If true**: Unifies `H` (σ=0) and `E₈` (σ=8) under one law and sets up the smooth
mod-16 gap.
**If false**: The counterexample would have to be a non-diagonalizable even form
with σ ≢ 0 (mod 8), which cannot exist — so a "disproof" attempt is a sharp
stress-test of our signature definition.

### Direction 3: Unimodularity and determinant of E₈
**Hypothesis**: `E8.det = 1` (the E₈ form is unimodular).
**Test**: Compute the 8×8 integer determinant — not by `decide` (the permutation
expansion is intractable) but by an explicit `LDLᵀ`/row-reduction certificate or by
`Matrix.det_fin` after a congruence to block-triangular form. Combine with
`E8_evenForm` to upgrade `E8_not_congruent_identity` to the full statement "E₈ is an
even unimodular positive-definite form not congruent to `I₈`".
**Why now**: We deliberately avoided the determinant because parity alone obstructs
congruence; but unimodularity is exactly the hypothesis Directions 1–2 need, so
producing a reusable 8×8 `det = 1` certificate unblocks them.
**If true**: Certifies E₈ as a genuine even unimodular lattice in Lean.
**If false**: Our chosen Cartan-style Gram matrix is mislabeled — we would have
formalized a different lattice and must correct the definition.

### Direction 4: Positive-definiteness of E₈ and the rank-8 minimality
**Hypothesis**: `IsPosDef E8`, and E₈ is the unique (up to congruence)
positive-definite even unimodular form of rank 8.
**Test**: For positive-definiteness, exhibit `E8 = LᵀL` for an explicit lower-
triangular rational `L` (Cholesky) and conclude `vᵀE₈v = |Lv|² > 0` for `v ≠ 0`.
Uniqueness needs a minimal-vector / root-system argument and is a longer arc.
**Why now**: `IsPosDef` is now a defined predicate; a Cholesky certificate is a
finite, checkable object, and positivity is the last hypothesis separating our
results from the literature's "E₈ lattice".
**If true**: Completes the E₈ characterization and feeds Direction 1's boundary case.
**If false**: Indicates a sign/convention error in the Gram matrix.

### Direction 5: A formal Donaldson "diagonalization" interface
**Hypothesis**: Define a Prop-level predicate `Smoothable Q` abstracting "Q is the
intersection form of some smooth closed simply-connected 4-manifold", axiomatize
Donaldson's theorem as a *hypothesis on this predicate* (`Smoothable Q → Q definite
→ Q ≅ I_n`), and derive `¬ Smoothable E8` as a clean corollary of
`E8_not_congruent_identity`.
**Why now**: We have the congruence-invariant machinery; packaging Donaldson as an
interface lets the next team state and use 4-manifold consequences without building
gauge theory, and cleanly separates the proven algebra from the deep input.
**If true**: Produces the first Lean statement of "no smooth 4-manifold has E₈
intersection form" as a theorem modulo a named topological hypothesis.
**If false (interface unusable)**: Reveals which extra data (spin structure,
Kirby–Siebenmann invariant) the predicate must carry, guiding a faithful
formalization of Freedman/Donaldson.
