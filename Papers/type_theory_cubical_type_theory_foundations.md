# Computational Evidence — Cubical Type Theory Foundations

This cycle is largely structural (constructions + computation rules), but several
claims admit small finite checks that we ran before committing to the formal proofs.

## 1. The univalence obstruction at `Bool` (counterexample hunt)

Full univalence would require `(A ≃ B) ≃ (A = B)`. We tested the smallest non-trivial
case `A = B = Bool`.

- `Bool ≃ Bool` has exactly `2! = 2` elements: the identity and negation.
  - `Equiv.refl Bool`:  `true ↦ true`, `false ↦ false`.
  - `notEquiv`:         `true ↦ false`, `false ↦ true`.
  - These differ at `true`, so `Equiv.refl Bool ≠ notEquiv`.
- `Bool = Bool` is a **subsingleton** under Lean's UIP (proof irrelevance for `Prop`):
  it has at most one element.
- `2 > 1`, so no bijection `(Bool ≃ Bool) ≃ (Bool = Bool)` can exist.

This finite cardinality mismatch is the seed of `no_univalence_at_Bool`.

## 2. Circle endpoint identification (small-case)

The circle `S1 = I / (0 ∼ 1)`. Representative checks of the gluing relation `rel`:

| x   | y   | rel x y | reason            |
|-----|-----|---------|-------------------|
| 0   | 0   | true    | reflexivity       |
| 0   | 1   | true    | endpoint gluing   |
| 1   | 0   | true    | endpoint gluing   |
| 0   | ½   | false   | distinct interior |
| ½   | ½   | true    | reflexivity       |

So `⟦0⟧ = ⟦1⟧` (the loop closes) but `⟦0⟧ ≠ ⟦½⟧` as far as `rel` forces; the quotient
is not collapsed to a point. This matches `loop_one` and the non-degeneracy of the
model.

## 3. Suspension poles (small-case)

For `Susp A = (A × I) / ∼`, all of `A × {0}` collapses to `north` and all of
`A × {1}` to `south`. Sample: for `a ≠ b`, `(a,0) ∼ (b,0)` holds (both poles north),
while `(a,½) ∼ (b,½)` fails — interior meridians stay distinct. This is the data the
recursion principle `Susp.rec` dispatches on.

## 4. De Morgan laws on the interval (spot check)

For `a = 0.3, b = 0.7` in `[0,1]`:
- `σ(min a b) = 1 - min(0.3,0.7) = 1 - 0.3 = 0.7`.
- `max(σ a, σ b) = max(0.7, 0.3) = 0.7`. ✓ (`symm_min`)
- `σ(max a b) = 1 - 0.7 = 0.3`; `min(0.7,0.3) = 0.3`. ✓ (`symm_max`)

All checks are consistent with the formally proved theorems; no counterexamples were
found.
