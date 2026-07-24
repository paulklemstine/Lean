# Computational Evidence: strictness vs. associativity for codiscrete one-object bicategories

## Claim under test

For a unital magma `M` (a set with a two-sided unit `1` and a not-necessarily-associative
product `*`), the one-object bicategory whose 1-cells are the elements of `M`, with codiscrete
hom-categories and composition given by `*`, admits a strict structure **iff** `*` is associative.

The nontrivial content is the negative side: when `*` fails associativity, no strict structure
exists on the fixed composition, even though every coherence diagram commutes.

## Small-case calculations (twisted multiplication `a ⋆ b = a + 2b` away from the unit)

Unit is `0`; `a ⋆ 0 = a`, `0 ⋆ a = a`; otherwise `a ⋆ b = a + 2b`.

| triple (a,b,c) | (a⋆b)⋆c | a⋆(b⋆c) | equal? |
|----------------|---------|---------|--------|
| (1,1,1)        | (1+2)⋆1 = 3+2 = 5 | 1⋆(1+2) = 1+6 = 7 | no |
| (2,1,1)        | (2+2)⋆1 = 4+2 = 6 | 2⋆(1+2) = 2+6 = 8 | no |
| (1,0,1)        | 1⋆1 = 3           | 1⋆1 = 3           | yes (unit slot) |
| (1,1,0)        | (1+2) = 3 = 3     | 1⋆1 = 3           | yes (unit slot) |

The defect `a⋆(b⋆c) − (a⋆b)⋆c = 2b` is nonzero whenever the middle factor is a nonzero
non-unit, so associativity fails on a large family of triples, not just one. The associativity
defect is therefore robust, confirming the negative side is non-vacuous.

## Enumeration over small finite unital magmas

For a carrier of size `n` with a fixed unit, the associativity condition is a finite check over
all `n^3` triples. Sampling the qualitative landscape:

- `n = 1`: only the trivial magma, associative, so the bicategory is strict.
- `n = 2` with unit `e` and second element `x`: the single free choice is `x*x ∈ {e, x}`. Both
  choices are associative (they are the two-element monoids `ℤ/2` and the idempotent monoid), so
  every 2-element unital magma yields a strict bicategory.
- `n = 3`: nonassociative unital magmas first appear here; each nonassociative table is a fresh
  witness that the codiscrete bicategory is non-strict while remaining fully coherent.

The pattern matches the theorem: strictness is coextensive with associativity, and the boundary
is exactly where nonassociative unital tables begin to exist.

## Sequence note

The count of unital magmas / monoids on `n` labelled elements is a classical enumeration problem
(monoids by order are catalogued in OEIS, e.g. A058129 for monoids up to isomorphism). The
present work does not need the exact counts; it only uses the qualitative fact that
nonassociative unital tables exist from `n = 3` onward, and that the twisted infinite example
supplies an explicit robust nonassociative witness.

## Conclusion

The computational landscape is consistent with the proved dichotomy: associativity ⇔ strictness.
No counterexample to the iff was found; the twisted magma supplies a persistent (not knife-edge)
violation of associativity, so the negative direction is genuinely inhabited.
