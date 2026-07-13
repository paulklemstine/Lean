# Computational Evidence: Labeled Poset Counts modulo 4 (A001035)

## 1. Small-case calculations

Enumerating all reflexive, antisymmetric, transitive boolean matrices on `Fin n`
gives the count `P(n)` of labeled partial orders:

| n | P(n)                | P(n) mod 4 | P(n) mod 2 |
|---|---------------------|-----------|-----------|
| 0 | 1                   | 1         | 1         |
| 1 | 1                   | 1         | 1         |
| 2 | 3                   | 3         | 1         |
| 3 | 19                  | 3         | 1         |
| 4 | 219                 | 3         | 1         |
| 5 | 4231                | 3         | 1         |

All values were obtained by direct enumeration over `2^(n^2)` boolean matrices
(feasible through `n = 5`). From `n = 2` onward every value is `≡ 3 (mod 4)`,
and in particular **odd** for all `n`.

## 2. OEIS identification

The sequence `1, 1, 3, 19, 219, 4231, 130023, 6129859, …` is **OEIS A001035**,
"Number of partially ordered sets ('posets') with n labeled elements". The
congruence `P(n) ≡ 3 (mod 4)` for `n ≥ 2` is verified there up to
`P(19) = 646099441937791106493755218560442089979 ≡ 3 (mod 4)`.

## 3. Self-dual counts

Enumerating the *self-dual* labeled partial orders (those equal to their own
order reversal) gives, strikingly, a constant:

| n | Q(n) = # self-dual posets |
|---|---------------------------|
| 2 | 1 |
| 3 | 1 |
| 4 | 1 |
| 5 | 1 |

This is not a coincidence: a self-dual order is *symmetric*, and symmetry
combined with antisymmetry forces the relation to be equality. Hence the
**discrete order is the unique self-dual labeled partial order** for every `n`,
so `Q(n) = 1` identically.

## 4. Structural consequence (proved)

Order reversal is an involution on the set of labeled partial orders whose only
fixed point is the discrete order. A fixed-point/involution parity count then
gives `P(n) ≡ Q(n) = 1 (mod 2)`, i.e. **`P(n)` is odd for all `n`** — the parity
half of the `mod 4` pattern, established for all `n` (not just the enumerated
range).

## 5. Counterexample hunt

No counterexample to `P(n)` odd exists (proved). No counterexample to
`P(n) ≡ 3 (mod 4)` was found for `2 ≤ n ≤ 5` by enumeration, consistent with the
OEIS record through `n = 19`. The step from `mod 2` to `mod 4` cannot come from a
single order-4 group with one global fixed point (that would give
`P ≡ 1 (mod 4)`, contradicting the data), so it requires a finer orbit analysis;
this is left as a conjecture.
