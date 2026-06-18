# Future Directions — The Combinatorial–Categorical Bridge (Species of Structures)

The file `Bridges/CombinatorialSpecies.lean` formalizes Joyal's combinatorial species
both categorically (`Species := Core FintypeCat ⥤ Type`, with the transport-of-structure
theorem `species_iso_invariant`) and enumeratively (`LSpecies`, with sum, Cauchy product,
and the exponential generating function `egf`). Its centerpiece is the **bridge theorem**
`egf_prod : egf (S ⊠ T) = egf S * egf T`, which—together with `egf_sum` and `egf_one`—
exhibits the EGF as a semiring homomorphism from species to `ℚ⟦X⟧`. The following
conjectures extend this skeleton toward the full Joyal dictionary.

## 1. Composition of species = substitution of generating functions

**Conjecture.** Define the *composition* (substitution) of species `S ∘ T`, where a
`(S ∘ T)`-structure on `[n]` is a partition of `[n]` into blocks, an `S`-structure on the
set of blocks, and a `T`-structure on each block (with `T[∅]` empty). Then for species `T`
with `card T 0 = 0`, `egf (S ∘ T) = (egf S) ∘ (egf T)` where the right side is formal
power-series substitution.

The key insight is that the binomial-convolution argument already proven in `card_prod`
is the *two-block* special case of the general *set-partition* convolution that governs
composition; the EGF homomorphism property should follow by iterating `egf_prod` over the
blocks of a partition and summing over partition types (Faà di Bruno / the exponential
formula). **Why now?** With `egf_prod` and `card_prod` already established and Mathlib's
`Finset` partition / `Nat.sum_range_choose` machinery available, composition is the next
strictly-harder convolution; closing it turns the homomorphism into the full Joyal
correspondence and immediately yields the exponential formula `egf (E ∘ T) = exp (egf T)`
for the set species `E` (already defined here as `setSpecies`).

## 2. The species of permutations has EGF `1/(1-X)`

**Conjecture.** Let `permSpecies` be the species with `permSpecies.obj n = Equiv.Perm (Fin n)`
(structures = linear orders / total bijections, `card = n!`). Then
`egf permSpecies = (1 - PowerSeries.X)⁻¹` in `ℚ⟦X⟧`, equivalently every coefficient equals
`1`.

The key insight is that `card permSpecies n = n!` makes the EGF coefficient `n!/n! = 1`
identically, so this is a *closed-form ordinary* generating function appearing as an EGF—
the cleanest finite witness that the bridge converts factorial growth into a rational
function. **Why now?** Mathlib already proves `Fintype.card_perm : card (Perm α) = (card α)!`,
so the count is free; the only new ingredient is identifying `PowerSeries.mk (fun _ => 1)`
with `(1 - X)⁻¹` via `PowerSeries.invOfUnit` / the geometric-series lemmas, a self-contained
lemma that would seed a small library of named EGFs.

## 3. Functoriality forces counts to be cardinality invariants

**Conjecture.** For the categorical `Species := Core FintypeCat ⥤ Type` landing in *finite*
types, define `speciesCard F n := Fintype.card (F.obj (Fin n))`. Then any natural
isomorphism `F ≅ G` of species induces `speciesCard F = speciesCard G`, and more strongly,
`speciesCard F n` depends only on `n` and not on the chosen `n`-element representative.

The key insight is that `species_iso_invariant` (already proven) upgrades from a pointwise
`Equiv` to an equality of *counts* because `Fintype.card` is an `Equiv`-invariant
(`Fintype.card_congr`); the categorical groupoid action is exactly what makes the
enumerative invariant well defined, closing the conceptual loop between the two halves of
the file. **Why now?** `species_iso_invariant` and `Fintype.card_congr` already exist, so
this is a short bridge lemma whose real value is methodological: it certifies that the
concrete `LSpecies` layer is a faithful shadow of the categorical `Species` layer.

## 4. Associativity and commutativity make species a commutative semiring object

**Conjecture.** Up to natural isomorphism of `LSpecies` (i.e. `∀ n, S.obj n ≃ T.obj n`),
the operations `⊞` and `⊠` satisfy the commutative-semiring axioms: `⊞` is associative,
commutative, with unit the empty species; `⊠` is associative, commutative, with unit
`oneSpecies`; and `⊠` distributes over `⊞`. Consequently `egf` descends to an honest
`RingHom` on the quotient by natural isomorphism.

The key insight is that each axiom is witnessed by a *natural family of bijections* on the
underlying finite structure types (e.g. commutativity of `⊠` swaps the subset `s` with its
complement, an involution on `Finset (Fin n)`), so the proofs are explicit `Equiv`
constructions rather than analytic estimates. **Why now?** The product and sum are already
defined and their counts computed (`card_sum`, `card_prod`); promoting the scalar EGF
homomorphism (`egf_sum`/`egf_prod`/`egf_one`) to a bundled `RingHom` is the natural
structural payoff and would let downstream files reuse `map_pow`, `map_sum`, etc., for free.

## 5. Derivative of a species and `egf (S') = (egf S)'`

**Conjecture.** Define the *derivative* species `S'` by `S'.obj n = S.obj (n + 1)`
(an `S'`-structure on `[n]` is an `S`-structure on `[n]` plus one extra "ghost" label).
Then `egf S' = PowerSeries.derivative (egf S)` (the formal derivative), i.e.
`coeff n (egf S') = (n+1) · coeff (n+1) (egf S) · ... ` matches the `1/n!` normalization
so that `card S' n / n! = card S (n+1) / n!`.

The key insight is that the EGF normalization `1/n!` is *precisely* the one under which the
pointed/derivative construction becomes the analyst's derivative—an identity that the
ordinary generating function does **not** enjoy—pinpointing why exponential (not ordinary)
generating functions are the canonical invariant of species. **Why now?** Mathlib provides
`PowerSeries.derivative` (a `coeff`-shifting linear map), and the derivative species is a
one-line reindexing of `obj`, so the proof reduces to a single `coeff`-level factorial
identity in the same spirit as the termwise step already used inside `egf_prod`.
