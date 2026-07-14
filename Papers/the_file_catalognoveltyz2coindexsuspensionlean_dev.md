# Computational Evidence: the join of ℤ₂-maps of combinatorial spheres

We study the combinatorial spheres `Sⁿ` (boundary complexes of cross-polytopes, `n+1`
coordinate axes with signs) and their equivariant simplicial maps `Z2Map m n`. A prior
development established the exact criterion

    Z2Map m n is nonempty  ⇔  m ≤ n,   so   coind(Sⁿ) = n,

and the count of such maps

    |Z2Map m n| = 2^(m+1) · (n+1)_{(m+1)}          (falling factorial)

## 1. Small-case counts of ℤ₂-maps

Using `|Z2Map m n| = 2^(m+1) · descFactorial (n+1) (m+1)`:

| m \ n | 0 | 1 | 2 | 3 |
|-------|---|----|-----|------|
| 0     | 2 | 4  | 6   | 8    |
| 1     | 0 | 8  | 24  | 48   |
| 2     | 0 | 0  | 48  | 192  |
| 3     | 0 | 0  | 0   | 384  |

Zeros below the diagonal confirm the Borsuk–Ulam upper bound (`m > n ⇒` no map).

## 2. The join dimension law

Join of spheres: `Sᵃ * Sᶜ ≅ Sᵃ⁺ᶜ⁺¹`, because axis counts add:
`(a+1) + (c+1) = (a+c+1) + 1`. Checking the coindex additivity `coind(Sᵃ * Sᶜ) =
coind(Sᵃ) + coind(Sᶜ) + 1`:

| a | c | a+c+1 | coind LHS | coind a + coind c + 1 |
|---|---|-------|-----------|-----------------------|
| 0 | 0 | 1     | 1         | 0+0+1 = 1  ✓          |
| 1 | 0 | 2     | 2         | 1+0+1 = 2  ✓          |
| 1 | 2 | 4     | 4         | 1+2+1 = 4  ✓          |
| 3 | 3 | 7     | 7         | 3+3+1 = 7  ✓          |

## 3. Supermultiplicativity under join (map counts)

The join embeds pairs `(F, G) ↦ F * G`, so `|Z2Map a b| · |Z2Map c d| ≤
|Z2Map (a+c+1) (b+d+1)|`. Sample checks:

- a,b,c,d = 0,1,0,1:  LHS = 4·4 = 16,   RHS = |Z2Map 1 3| = 2^2·(4·3·2) = 96.  16 ≤ 96 ✓
- a,b,c,d = 1,1,1,1:  LHS = 8·8 = 64,   RHS = |Z2Map 3 3| = 2^4·4! = 384.     64 ≤ 384 ✓
- a,b,c,d = 0,0,0,0:  LHS = 2·2 = 4,    RHS = |Z2Map 1 1| = 2^2·2 = 8.        4 ≤ 8  ✓

The inequality is generally strict: the join image is a proper subset of all ℤ₂-maps.

## 4. Boundary: join is strictly sufficient, not necessary

The join construction requires the *blockwise* conditions `a ≤ b` and `c ≤ d`, whereas a
ℤ₂-map into the joined target exists under only `a + c ≤ b + d`. Witness:
`S¹ ↛ S⁰` (no first-block map, `1 > 0`) yet `S³ → S³` exists (`3 ≤ 3`). So the
blockwise hypotheses are strictly stronger than existence of a map into the joined sphere.

All numeric claims above are confirmed by the formally verified theorems in
`Z2CoindexJoin.lean` (`coind_join_eq`, `join_card_le`, `join_sufficient_not_necessary`).
