# Future Directions — Fusion Systems and the Algebraic Core of Turaev–Viro / Verlinde Theory

## Synthesis

This cycle laid the *algebraic bedrock* for the Turaev–Viro state sum and the
Verlinde formula inside `Catalog/Physics/TuraevViroFusion.lean`. We introduced a
single self-contained structure, `FusionSystem`, packaging the data a 3D
topological quantum field theory actually consumes: a finite label set of simple
objects, nonnegative fusion multiplicities `N i j k`, a tensor unit, an
associativity identity (the *pentagon shadow* / 2–3 Pachner identity), and a
strictly positive multiplicative quantum dimension `dim`.

From this minimal data we proved four structural theorems with `sorry = 0`:

- **`fusion_matrix_comm`** — the fusion matrices `Nmat i` pairwise commute. This
  is the "Theorem 1" commutativity result, and it falls out of a *single* use of
  the associativity axiom after reindexing with commutativity of fusion. This is
  the precise sense in which the pentagon equation *is* the 2–3 Pachner-move
  identity in disguise.
- **`fusion_matrix_unit`** — the unit object's fusion matrix is the identity
  matrix, so the `Nmat i` form a commutative monoid with identity.
- **`quantum_dim_eigenvector`** — the quantum-dimension vector is a *simultaneous*
  eigenvector of every fusion matrix, with eigenvalue `dim i`. This is the
  Perron–Frobenius / Verlinde eigenvector statement.
- **`globalDimSq_pos`** — the global dimension squared `D² = Σ dim²` is strictly
  positive, the well-definedness of the Turaev–Viro and Crane–Yetter
  normalization constant.

These connect the catalog's `Physics/CategoricalPhysics` TQFT/cobordism
infrastructure (e.g. `two_infinity_necessity`, `cobordism_hypothesis_structural`)
to a concrete, computable algebraic engine: the abstract cobordism layer now has
a candidate *value-on-the-point* in the form of a `FusionSystem`.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fusion_matrix_comm` | `Nmat i * Nmat j = Nmat j * Nmat i` | proved |
| `fusion_matrix_unit` | `Nmat unit = 1` | proved |
| `quantum_dim_eigenvector` | `(Nmat i).mulVec dim = dim i • dim` | proved |
| `globalDimSq_pos` | `0 < Σ dim²` | proved |

All proofs are axiom-clean (`propext`, `Classical.choice`, `Quot.sound`) and the
file builds in isolation.

## Bold, Falsifiable Directions

### 1. Full Verlinde diagonalization from the commuting family

The commuting, semisimple family `{Nmat i}` should be *simultaneously* unitarily
diagonalizable, yielding a matrix `S` with `N_{ij}^k = Σ_l S_{il} S_{jl} \bar
S_{kl} / S_{0l}`. Concretely: prove that there is an orthonormal eigenbasis
common to all `Nmat i`, and read off `S` from it. **The key insight is** that
`fusion_matrix_comm` already supplies the only hard hypothesis of the spectral
theorem for commuting normal operators — symmetry of `Nmat i` (a separate,
provable consequence of a duality axiom `N i j unit = δ_{j, i*}`) then upgrades
"commuting" to "commuting normal", and Mathlib's
`LinearMap.IsSymmetric`/`isHermitian` spectral machinery finishes it. **Why
now?** The commutativity result is the documented prerequisite, and the only
missing structural axiom (duality/pairing) is one additional field on
`FusionSystem`; the rest is Mathlib's existing finite-dimensional spectral
theorem. *Falsifiable:* a `FusionSystem` whose fusion matrices fail to be
simultaneously diagonalizable would break it — but commutativity + symmetry
forbids this.

### 2. The quantum dimension is the Perron–Frobenius eigenvalue

We proved `dim` is *an* eigenvector with eigenvalue `dim i`; conjecture that it
is *the* dominant (Perron–Frobenius) one: `dim i = ρ(Nmat i)`, the spectral
radius, and `dim i ≥ |λ|` for every eigenvalue `λ` of `Nmat i`. **The key
insight is** that `Nmat i` has nonnegative entries (`N_nonneg`) and a strictly
positive eigenvector (`dim_pos` + `quantum_dim_eigenvector`), which by the
converse Perron–Frobenius theorem pins the associated eigenvalue as the spectral
radius. **Why now?** Both ingredients — nonnegativity and a positive eigenvector
— are already fields/theorems in the file; this is the cleanest possible setting
to formalize a Perron–Frobenius converse in Mathlib, where the general theorem is
still absent. *Falsifiable:* exhibit a nonnegative matrix with a strictly
positive eigenvector whose eigenvalue is not the spectral radius (impossible, by
the conjecture).

### 3. Turaev–Viro 2–3 Pachner invariance as a finite identity

Define a one-tetrahedron partition weight `Z` purely from `N` (a contracted
product of fusion multiplicities standing in for 6j-symbols) and prove the 2–3
move leaves `Z` invariant. **The key insight is** that the 2–3 invariance, once
all colorings are summed, is *exactly* `N_assoc` contracted against `dim`
weights — i.e. the move identity is a corollary of associativity plus
`dim_hom`, with no genuinely topological content. **Why now?** We have isolated
associativity as a single algebraic axiom and proved the dimension is a
character; the combinatorial bookkeeping of a single Pachner move is small and
self-contained, making this a high-feasibility first nontrivial state-sum
invariance. *Falsifiable:* drop `N_assoc` and the constructed `Z` should fail to
be 2–3 invariant.

### 4. Quantum-double instantiation `D(G)` with `D² = |G|²`

Construct, for a finite group `G`, a concrete `FusionSystem` instance whose label
set is the set of (conjugacy-class, irrep) pairs of `G`, whose `dim` is the
product of class size and irrep dimension, and verify `globalDimSq = |G|²`. **The
key insight is** that the abstract axioms `N_comm`, `N_assoc`, `dim_hom` are all
*verifiable identities* about the center `Z(ℂ[G])`, so the whole `FusionSystem`
becomes a theorem rather than a hypothesis, and `globalDimSq_pos` specializes to
the exact value `|G|²`. **Why now?** Mathlib has finite groups, conjugacy
classes, group algebras, and character theory; building `D(G)` as a witness that
the `FusionSystem` axioms are *consistent and nonvacuous* is the natural sanity
check on this cycle's abstraction. *Falsifiable:* compute `globalDimSq` for a
small `G` (e.g. `S_3`, `|G|² = 36`) and check the closed form.

### 5. Crane–Yetter 4D state sum and the `D^{3σ+χ}` formula

Extend the 3D weight of Direction 3 to a 4D Crane–Yetter weight and conjecture
its value on a closed 4-manifold is `D^{3σ+χ}`, depending only on signature `σ`
and Euler characteristic `χ`. **The key insight is** that 4D invariance reduces
to the 4D Pachner moves (1–5, 2–4, 3–3), each of which is a higher associativity
identity generalizing `N_assoc`, while the *value* is forced by counting
simplices through `globalDimSq`. **Why now?** With `globalDimSq_pos` and the
fusion framework already in place, the 4D extension is the minimal additional
combinatorial layer, and the dependence-on-`(σ,χ)`-only claim is sharply
falsifiable by evaluating on `S^4`, `CP^2`, and `S^2 × S^2`.
