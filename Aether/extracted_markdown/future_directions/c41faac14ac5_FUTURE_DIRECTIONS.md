# Future Directions: Topological Order, Genus Degeneracy, and Modular Data

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
