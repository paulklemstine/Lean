# Computational Evidence: A Cosmic Census of L-Functions

This note collects the small-case evidence behind the countability census of
Selberg-type L-functions formalized in `SelbergClassCensus.lean`.

## 1. Small-case enumeration by conductor

Each "natural" L-function is recorded by a finite arithmetic signature
(degree, conductor, gamma-factor shifts, and Euler data at finitely many primes).
The principal degree-one signatures, ordered by conductor, begin:

| index | conductor |
|-------|-----------|
| 1     | 1  (Riemann zeta) |
| 2     | 2  |
| 3     | 3  |
| ...   | ... |
| 100   | 100 |

Computed in the formal file:

```
#eval (List.range 20).map (fun n => (principalSignature (n + 1)).conductor)
-- [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]

#eval ((List.range 100).map (fun n => (principalSignature (n + 1)).conductor)).length
-- 100
```

This exhibits an explicit strictly-increasing (by conductor) enumeration of
distinct census members — a concrete "first 100 elements" list — confirming the
census is at least countably infinite.

## 2. Counting Dirichlet characters per level (finiteness of fibers)

The Dirichlet L-functions of level `N` correspond to characters modulo `N`.
The number of Dirichlet characters modulo `N` equals `φ(N)` (Euler's totient),
which is finite for every `N ≥ 1`:

| N  | # characters = φ(N) |
|----|---------------------|
| 1  | 1 |
| 2  | 1 |
| 3  | 2 |
| 4  | 2 |
| 5  | 4 |
| 6  | 2 |
| 7  | 6 |
| 8  | 4 |
| 12 | 4 |

Finitely many per level, summed over countably many levels, gives a countable
family — matching `dirichletFamily_countable`.

## 3. Counterexample hunt: where countability fails (boundary)

The informal slogan "an L-function is determined by finitely many Euler factors"
is *too strong*. If we instead allow an **independent binary choice at every
prime** (e.g. a free ramified/unramified flag), the family is the full Cantor
space `Primes → Bool`, of cardinality `2^{ℵ₀}` — uncountable. This is not a bug
in the census but its precise boundary: countability requires the *stored*
determining data to be finite. Formalized as `naive_all_primes_uncountable`.

Similarly, the reals carry uncountably many j-invariants, yet only countably many
elliptic curves are defined over `ℚ` (five rational Weierstrass coefficients).
The continuum of complex j-invariants therefore does **not** inject into the
census: `no_injective_real_signature`.

## 4. OEIS connections

- **A000010** (Euler totient φ): counts Dirichlet characters per level; the fiber
  sizes of the Dirichlet family.
- **A002088** (partial sums of φ): running count of primitive-plus-imprimitive
  Dirichlet L-functions up to conductor `N`.
- **A000027** (natural numbers): the conductor enumeration of the principal
  census members is literally `1, 2, 3, ...`.

## 5. Summary

Every finite census fiber is finite; the base (conductors, levels, coefficient
tuples) is countable; the total is countably infinite. Relaxing finiteness of the
determining data crosses immediately into the uncountable. The evidence is fully
consistent with the two-sided census proved in the accompanying module.
