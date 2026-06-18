# FUTURE_DIRECTIONS — Quantum Topological Phase Computation (Braiding Universality)

Cycle focus: the non-abelian algebraic core of anyon-braiding universality, built
on the catalog files `Speculative/AutoResearch/BraidingUniversality.lean`,
`...BraidingUniversalityExt.lean`, and `Applications/FibonacciAnyonBraiding.lean`.
New file: `Speculative/AutoResearch/BraidingUniversalityNonabelian.lean`.

## Synthesis

The parent program reduced single-qubit topological-computation universality to a
number-theoretic dichotomy on the maximal torus: a single phase gate is dense iff
its phase is irrational, with the Fibonacci eigenphase `4/5` as a finite-order
counterexample. That program explicitly leaves the *full* `SU(2)` density claim
(`su2_braiding_dense`) as a `sorry`, because it requires the classification of
closed subgroups of `SU(2)`. The structural gap is clear: a commuting (abelian)
gate set always sits inside a maximal torus and can never be dense, so density
*must* come from non-commutativity — yet the parent files never proved the
braiding gates actually fail to commute. This cycle closes precisely that gap.

We re-declared the reduced Burau representation of `B₃` self-containedly and
proved: (i) both generators are units in `GL₂(ℂ)` for `t ≠ 0` with explicit
two-sided inverses; (ii) the elementary braid `σ₁σ₂` has trace `-t`, determinant
`t²`, and minimal polynomial `X² + tX + t²` (Cayley–Hamilton made explicit),
whose roots `t·ζ₆^{±1}` show one braid already realises a genuine rotation rather
than a mere phase; (iii) the central full twist `(σ₁σ₂)³ = t³·I`, collapsing to
`I` at `t = 1`; and (iv) the headline result, **non-commutativity of the gates**.

The most instructive event was a Critic refutation. The first boundary
conjecture — "the gates commute at the degenerate value `t = 0`" — was *false*:
the Lean kernel returned `⊢ False` on entry `(0,1)` (`0` versus `1`). Comparing
two entries (`(0,0)` forcing `t = 0` and `(0,1)` forcing `-t = 1`) shows the
gates **never** commute, for *every* `t`, with no hypothesis at all. This both
strengthened the main theorem and corrected our mental model: at `t = 0` it is
*invertibility* that fails (`det σ₁ = 0`, leaving `GL₂`), while
non-commutativity persists. Invertibility and non-commutativity are therefore
independent phenomena — a structural insight that reframes how the next cycle
should attack `su2_braiding_dense`.

## Results Summary

- `burau_braid_relation`: proved — the Burau generators satisfy the Yang–Baxter/braid relation for all `t`, certifying a genuine `B₃` representation.
- `burau_det₁`, `burau_det₂`: proved — each generator has determinant `-t`.
- `burau_noncomm`: proved — the Burau gates `σ₁σ₂ ≠ σ₂σ₁` for **every** `t`; the algebraic certificate of non-abelian braiding (strengthened by the Critic from an initial `t ≠ 0` form).
- `burauSigma₁_mul_inv`, `burauSigma₁_inv_mul`, `burauSigma₂_mul_inv`, `burauSigma₂_inv_mul`: proved — explicit two-sided inverses of both generators.
- `burau_isUnit₁`, `burau_isUnit₂`: proved — both generators lie in `GL₂(ℂ)` for `t ≠ 0`.
- `burau_braidWord_trace`: proved — `tr(σ₁σ₂) = -t` (Jones-polynomial trace input).
- `burau_braidWord_det`: proved — `det(σ₁σ₂) = t²`.
- `burau_braidWord_min_poly`: proved — `(σ₁σ₂)² + t(σ₁σ₂) + t²I = 0` (explicit Cayley–Hamilton).
- `burau_fullTwist_scalar`: proved — `(σ₁σ₂)³ = t³·I`, the center of `B₃` maps to scalars.
- `burau_braidWord_cube_at_one`: proved — at `t = 1`, `(σ₁σ₂)³ = I`.
- `burau_commutator_ne_one`: proved — the commutator `σ₁σ₂σ₁⁻¹σ₂⁻¹ ≠ I` for `t ≠ 0`.
- `burau_degenerate_at_zero`: proved — `det(σ₁ 0) = 0`; the representation leaves `GL₂` at `t = 0` (corrected boundary).
- `burau_noncomm_at_zero`: proved — the gates still fail to commute at `t = 0`, refuting the naive boundary guess.
- `burau_comm_at_zero` (earlier draft): disproved — claimed the gates commute at `t = 0`; the kernel produced `⊢ False` at entry `(0,1)`, and `burau_noncomm 0` is the explicit counterexample.
- `BraidingUniversality.su2_braiding_dense` (parent file): still a conjecture (`sorry`) — full `SU(2)` density; out of reach this cycle, but its missing precondition (non-commutativity) is now supplied.

## Research Directions

### Direction 1: From non-commutativity to a free subgroup of GL₂(ℂ)
**Hypothesis**: For generic loop parameters (e.g. `t` transcendental, or `|t| = 1` with `t` not a root of unity), the two Burau matrices `σ₁(t), σ₂(t)` generate a *free* group of rank 2 inside `GL₂(ℂ)`.
**Test**: Build a ping-pong (Tits-style) argument: exhibit two disjoint attracting/repelling regions in `ℂP¹` preserved by powers of `σ₁` and `σ₂`, and prove freeness by reducing any non-trivial reduced word to a non-identity matrix. Disproof would be an explicit non-trivial relation collapsing to `I`.
**Why now**: This cycle proved `burau_noncomm` (no relation at depth 1) and `burau_commutator_ne_one` (no relation at the first commutator); freeness is the natural induction upgrading "no short relations" to "no relations". The key insight is that the minimal polynomial `X² + tX + t²` already pins the eigenvalues `t·ζ₆^{±1}`, giving explicit attracting directions to seed the ping-pong table.
**If true**: A free non-abelian subgroup is the discrete skeleton of density; it makes the leap to `su2_braiding_dense` a question of *closure* rather than *non-triviality*.
**If false**: A concrete relation would expose an exceptional `t`-locus where braiding genuinely degenerates, sharpening exactly which loop values can support universality.

### Direction 2: Unitarity locus of the reduced Burau representation
**Hypothesis**: There is a precise set of `t` (conjecturally the unit circle `|t| = 1`, after the standard symmetrising conjugation) on which a conjugate of `σ₁(t), σ₂(t)` lands in `U(2)`, and on a dense subset of it the image is dense in `SU(2)` up to phase.
**Test**: Construct the explicit Hermitian form `J(t)` preserved by Burau, prove `σ_iᴴ J σ_i = J`, and characterise when `J` is positive definite. Combine with Direction 1's freeness and a Kronecker-type argument for the eigenphase.
**Why now**: We already have `burau_isUnit₁/₂` (image in `GL₂`) and `burau_fullTwist_scalar` (the central phase `t³`). The key insight is that unitarity is a *single* matrix identity `σᴴJσ = J` per generator — exactly the shape this cycle's entrywise machinery dispatches routinely.
**If true**: It supplies the missing analytic half of `su2_braiding_dense`: freeness (Direction 1) plus unitarity plus an irrational eigenphase forces density by the closed-subgroup classification.
**If false**: Non-unitarity for all `t` would mean Burau alone cannot model protected (norm-preserving) computation, validating the Fibonacci `F`/`R`-matrix route over the bare Burau route.

### Direction 3: Order of the closed phase subgroup and the Fibonacci obstruction, refined
**Hypothesis**: The exact additive order of the Fibonacci eigenphase `4/5` on the torus is `5`, and more generally the phase `p/q` (in lowest terms) generates a cyclic group of order exactly `q`; hence the maximal finite braiding-phase order achievable by anyon model `k` is governed by the conductor of its `R`-matrix eigenphases.
**Test**: Prove `addOrderOf ((p/q : ℝ) : AddCircle 1) = q` in Mathlib's `AddCircle` API, then specialise to `4/5`. Cross-check against the parent's `fibonacci_phase_not_dense`.
**Why now**: The parent file proved density fails for `4/5` and the Ext file proved rational phases are torsion; the key insight is that "torsion" can be upgraded to an *exact order* via `AddCircle.addOrderOf_coe`-style lemmas, turning a qualitative obstruction into a quantitative invariant.
**If true**: It yields a clean numerical invariant ("phase conductor") ranking anyon models by how far their phases are from universality.
**If false**: A mismatch between order and denominator would reveal hidden identifications on the torus, i.e. unexpected coincidences among braiding phases.

### Direction 4: Cayley–Hamilton braid calculus for general two-generator braids
**Hypothesis**: Every length-`n` braid word in `σ₁, σ₂` reduces, via the minimal polynomial `X² + tX + t²` of `σ₁σ₂` (and its analogues), to a matrix whose entries are degree-`≤ n` Laurent polynomials in `t` with an explicit recurrence — giving a polynomial-time normal form for Burau images and hence for the associated Jones traces.
**Test**: Formalise the two-term recurrence `Mⁿ⁺² = -t Mⁿ⁺¹ - t² Mⁿ` from `burau_braidWord_min_poly` and prove a closed form for `tr(Mⁿ)` (Chebyshev-like). Validate against small `n` by `decide`-free computation.
**Why now**: `burau_braidWord_min_poly` and `burau_fullTwist_scalar` are exactly the `n = 2, 3` base cases of such a recurrence. The key insight is that Cayley–Hamilton turns matrix powers into a *linear* recurrence, so the whole braid-word semigroup is controlled by two scalar sequences.
**If true**: A verified normal form makes Jones-polynomial computation for `B₃` closures formal and efficient, bridging this cycle's algebra to the `Applications/Jones.lean` knot-invariant track.
**If false**: A breakdown of the recurrence would localise where Burau fails to be faithful, pointing at the kernel of the Burau representation (a famous open problem for higher strand number).

### Direction 5: Independence of invertibility and non-commutativity as a design principle
**Hypothesis**: For a broad class of parametrised `2×2` braid-type representations, the *non-commutativity locus* strictly contains the *invertibility locus*; i.e. there are always parameter values where gates are non-abelian but non-invertible, and this gap is what distinguishes "computational" from "group-theoretic" braiding.
**Test**: Abstract `burau_noncomm` (all `t`) versus `burau_degenerate_at_zero` (`det = 0` at `t = 0`) into a general lemma over a family `A(t), B(t)` of matrices with polynomial entries, and characterise the two loci via resultants/discriminants.
**Why now**: This cycle produced a concrete witness of the separation (`t = 0`: non-commuting yet singular), discovered through a Critic refutation. The key insight is that non-commutativity is a *generic* (codimension-0) property while invertibility fails on a *hypersurface*, so the two can never coincide for non-trivial families.
**If true**: It gives a parameter-counting heuristic for where to search for universal gate sets — prioritise the invertibility hypersurface's complement, not the non-commutativity locus.
**If false**: A family where the two loci coincide would be a rigid, highly symmetric representation worth isolating as an exceptional case.
