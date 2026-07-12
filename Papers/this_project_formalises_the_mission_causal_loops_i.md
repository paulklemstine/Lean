# Computational Evidence — Monoidal Strictification of `PTree α`

This cycle upgrades the equivalence `PTree α ≌ Discrete (List α)` to a *monoidal*
equivalence with the strict skeleton `Discrete (FreeMonoid α)`. The statement is
structural (category theory), so the "evidence" that matters is the finite combinatorics
of bracketings, which the construction collapses.

## 1. Bracketings collapse to a single word

`flatten : PTree α → FreeMonoid α` forgets bracketing. The number of distinct
bracketings (binary trees) on `n` labelled leaves in fixed left-to-right order is the
Catalan number `C_{n-1}`; all of them flatten to the *same* leaf-word. Monoidal
strictification says: the whole poset of `C_{n-1}` bracketings, together with the
associator isos between them, is monoidally equivalent to the single object `[a₁,…,aₙ]`.

| n leaves | # bracketings (binary trees) | flatten image |
|----------|------------------------------|---------------|
| 1        | 1                            | `[a₁]`        |
| 2        | 1                            | `[a₁,a₂]`     |
| 3        | 2                            | `[a₁,a₂,a₃]`  |
| 4        | 5                            | `[a₁,…,a₄]`   |
| 5        | 14                           | `[a₁,…,a₅]`   |
| 6        | 42                           | `[a₁,…,a₆]`   |

The counts `1,1,2,5,14,42,…` are the **Catalan numbers**, OEIS
[A000108](https://oeis.org/A000108). Their appearance is exactly the point: coherence
(Mac Lane) says all `C_{n-1}` bracketings are *canonically and uniquely* isomorphic, and
strictification realizes that as a single strict object.

## 2. Flattening is a strict monoid morphism (checked by `rfl`)

The key facts underlying the strong-monoidal structure are definitional:

- `flatten (s ⊗ t) = flatten s * flatten t`  (`flatten_tensor`, proved by `rfl`)
- `flatten (𝟙_ (PTree α)) = 1`               (`flatten_unit`, proved by `rfl`)

Because these hold *on the nose*, the tensorator `μ` and unit comparison `ε` of the
monoidal functor are literally identity isomorphisms (`flattenCore`), so `flattenFunctor`
is not merely lax but *strong* monoidal, and in fact strict on structure.

## 3. Normal form round-trip (checked by `rfl`/`simp`)

`ofList` builds the right-nested normal form and satisfies
`flatten (ofList l) = FreeMonoid.ofList l` (`flatten_ofList`). Hence
`flatten ∘ ofList = id` on words, giving the counit of the equivalence; the unit uses
`normalize`-style isos. Every naturality/coherence square is discharged for free because
both `PTree α` and `Discrete (FreeMonoid α)` are thin.

## Why no further numerical search is needed

The claim is a universally-quantified categorical identity whose obligations are all
equalities of morphisms in thin categories (hom-sets are subsingletons). There is no
free parameter to search over and no possible counterexample once thinness is
established; the Lean kernel checks the finitely-many coherence fields directly.
