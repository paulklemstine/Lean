# Computational Evidence — Cosmic Census of L-Functions

## 1. The claim being tested

The census philosophy asserts that a Selberg-class L-function is determined by a
finite package of arithmetic invariants over countable rings:

    (degree ∈ ℕ, conductor ∈ ℕ, root number ∈ ℚ², gamma shifts ∈ List ℚ²,
     finite local Euler data ∈ List (ℕ × List ℤ)).

If that is so, the universe of L-functions injects into a **countable** type, so it
is at most countable. Adding one infinite family (Dirichlet L-functions, one per
conductor) makes it exactly **countably infinite**, hence in bijection with `ℕ`.

## 2. Small-case calculation — the census by conductor

Ordering the degree-1 representatives by conductor `q = 1, 2, 3, …` gives the start
of the census:

| # | conductor | degree | family              |
|---|-----------|--------|---------------------|
| 1 | 1         | 1      | ζ (trivial char)    |
| 2 | 2         | 1      | Dirichlet mod 2     |
| 3 | 3         | 1      | Dirichlet mod 3     |
| … | …         | 1      | …                   |
|100| 100       | 1      | Dirichlet mod 100   |

This is exactly `SelbergDatum.census` in `Census.lean`; the Lean file proves:

* `census_length : census.length = 100`
* `census_conductors : census.map conductor = [1, 2, …, 100]` (`List.range' 1 100`)
* `census_nodup : census.Nodup`
* `census_valid : ∀ d ∈ census, IsValid d`

## 3. Cardinality bookkeeping (why "countable")

* `ℕ`, `ℤ`, `ℚ` are countable; finite products and `List` of countable types are
  countable. Hence the invariant-tuple type is countable.
* `toTuple` is injective (proved in Lean), so `SelbergDatum` is countable.
* `levels : ℕ → SelbergDatum` and `dirichletLike : ℕ → SelbergDatum` are injective,
  so `SelbergDatum` is infinite.
* Countable + Infinite ⇒ `SelbergDatum ≃ ℕ` (`exists_equiv_nat`).

## 4. Counterexample hunt

Could the universe be *uncountable*? Only if some invariant ranged over an
uncountable set (e.g. root numbers as arbitrary reals, or Euler data at *all*
infinitely many primes chosen freely). The finite-invariant model deliberately
excludes that: root numbers/shifts live in `ℚ` and only *finitely many* local
factors are recorded. Within the model no uncountable family exists — consistent
with the conjecture. The genuinely hard content (that the analytic Selberg class
actually embeds into such finite data) is a rigidity statement discussed in
`FUTURE_DIRECTIONS.md` and is *not* asserted here.

## 5. OEIS

The census ordered by conductor with a single degree-1 representative per level is
just `a(n) = n` (conductor tower), OEIS A000027 (the natural numbers) — the very
sequence witnessing the bijection with `ℕ`.
