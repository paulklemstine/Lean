# Computational evidence

Exploratory computations carried out before and alongside the Lean formalisation in
`Catalog/Algebra/KleberComplementaryProducts.lean` and
`Catalog/Algebra/KleberManyFoldProducts.lean`.

**Status of the numbers below: exploratory, produced by ad-hoc scripts — they are *not*
machine-verified.** The machine-verified statements are exactly the Lean theorems in the two
files above (all sorry-free, axioms `propext`, `Classical.choice`, `Quot.sound` only).

Throughout, for partitions `α, β` the *componentwise splitting* condition is
`α + β = θ` (parts added row by row, both summands partitions), and the *multiset union*
`α ⊎ β` is the multiset of all nonzero parts of `α` and `β` together.

## 1. Does the multiset union separate componentwise splittings?

For each partition `θ` we enumerated the unordered componentwise splittings `{α, β}` of `θ`
and counted how many distinct multiset unions `α ⊎ β` they produce.

| θ | #splittings | #distinct unions |
|---|---|---|
| (2) | 2 | 2 |
| (3,1) | 3 | **2** |
| (4,2) | 5 | 5 |
| (5,1) | 5 | **3** |
| (5,3) | 6 | **5** |
| (6,2) | 8 | **7** |
| (4,2,1) | 6 | **5** |

Over all **96 partitions of `n ≤ 9`**, the unions are pairwise distinct for exactly **48**
of them. So the criterion proved in Lean
(`KleberSplit.linearIndependent_msym_mul`) covers about half of all shapes outright, and the
first failure is `θ = (3,1)`.

The smallest collision with *both* parts of both pairs nonempty is

```
(3,1) + (2,2) = (5,3) = (3,2) + (2,1),      {3,1} ⊎ {2,2} = {3,2,2,1} = {3,2} ⊎ {2,1}
```

which is formalised as `KleberSplit.union_collision_five_three`.

## 2. Are the monomial products actually independent? (rank experiment)

For each `θ` we expanded every product `m_α m_β` (over unordered componentwise splittings of
`θ`) in the monomial basis `{m_μ}` — the coefficient of `m_μ` in `m_α m_β` is the number of
pairs `(u,v)` of rearrangements of `α` and `β` with `u + v = μ` — and computed the rank of
the resulting integer matrix over `ℚ`.

Result: **for all 96 partitions of `n ≤ 9`, rank = number of splittings**, i.e. the products
are linearly independent in every tested case, including all the collision cases where the
formalised criterion does not apply.

| θ | #splittings | rank |
|---|---|---|
| (3,1) | 3 | 3 |
| (5,1) | 5 | 5 |
| (5,3) | 6 | 6 |
| (6,2) | 8 | 8 |
| (5,2,1) | 8 | 8 |

## 3. The Schur case

The same experiment for Schur functions (expanding `s_λ = Σ_μ K_{λμ} m_μ` with Kostka
numbers obtained by enumerating semistandard tableaux, then multiplying in the monomial
basis): for **all partitions `θ` with `|θ| ≤ 7`**, the rank of the matrix of products
`s_α s_β` equals the number of unordered componentwise splittings. This is consistent with
the paper's main theorem.

## 4. The union-class conjecture

Section 1 shows the obstruction is exactly: several splittings can share one union. This
suggests isolating a single union class. For a fixed multiset `U`, enumerate all unordered
*multiset* splittings `A ⊎ B = U` and test independence of `m_A m_B`.

Result: for **all `U` with `|U| ≤ 8`** the products are linearly independent.

| U | #multiset splittings | rank |
|---|---|---|
| (2,2) | 2 | 2 |
| (2,2,2) | 2 | 2 |
| (3,2,1) | 4 | 4 |
| (4,2,1) | 4 | 4 |
| (2,1,1,1,1,1,1) | 7 | 7 |

The smallest nontrivial class, `U = {v,v}` with the two splittings `{∅,(v,v)}` and
`{(v),(v)}`, is proved in Lean: `KleberSplit.linearIndependent_collision_pair`. (Note
`m_{(v)} m_{(v)} = 2 m_{(v,v)} + m_{(2v)}`; the separating monomial `x₀^{2v}` sits in a
strictly higher layer of the quadratic filtration used in the proofs.)

## 5. OEIS

The counting sequence "number of unordered componentwise splittings of a partition" was not
pursued as a named integer sequence: it is a function of the partition, not of `n` alone, so
no single OEIS entry applies. Summing over all partitions of `n` gives
`1, 3, 5, 11, 18, 34, 55, 95, 150` for `n = 1..9` (from the enumeration above); we make no
claim about its presence in OEIS.

## 6. Method (abridged script)

```python
def coeff_m(alpha, beta, mu):          # coefficient of x^mu in m_alpha * m_beta
    L = len(mu)
    if len(alpha) > L or len(beta) > L: return 0
    Bs = set(mperms(list(beta) + [0]*(L-len(beta))))
    return sum(1 for u in mperms(list(alpha) + [0]*(L-len(alpha)))
                 if all(mu[i] >= u[i] for i in range(L))
                 and tuple(mu[i]-u[i] for i in range(L)) in Bs)
# rows = splittings of theta, columns = partitions mu of |theta|, entries = coeff_m
# then exact rank over the rationals
```

`mperms` enumerates the distinct rearrangements of a multiset; exact rational Gaussian
elimination is used for the rank.
