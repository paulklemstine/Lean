# Computational Evidence — Möbius arithmetic cycle

All computations below were run inside Lean 4 with `#eval` (exact integer / rational
arithmetic, no floating point). They guided which conjectural claims to prove and
which to refute.

## 1. The value map on the proposed Möbius integers

The conjecture embeds `n ↦ (1/2 + 1/(2n), |n|)` and reads off
`val (x,y) = y (2x − 1)`. Symbolically

```
val (emb n) = |n| · (2(1/2 + 1/(2n)) − 1) = |n| / n = sign n.
```

Table of `val (emb n)`:

| n        | −4 | −3 | −2 | −1 | 0 | 1 | 2 | 3 | 4 |
|----------|----|----|----|----|---|---|---|---|---|
| val(emb n)| −1 | −1 | −1 | −1 | 0 | 1 | 1 | 1 | 1 |

**Conclusion.** The embedding stores only the *sign*; magnitudes are destroyed.
Formalised as `MoebiusBand.val_emb` and `MoebiusBand.val_collapse`.

## 2. Seam behaviour (`1` vs `−1`, and `(1,0)`)

`emb 1 = (1, 1)` and `emb (−1) = (0, 1)`. The seam relation glues `(0,y)` to
`(1,−y)`, hence `(0,1) ∼ (1,−1) ≠ (1,1)`: the two are **not** identified.
By contrast `(1,0) ∼ (0,0)`, so the claimed nonzero zero-divisor factor `(1,0)`
*is* the zero point. Formalised as `emb_one_ne_emb_neg_one`, `one_zero_eq_zero`.

Descent test for the induced operations (exact arithmetic on representatives):

| operation | `(0,1)⊙(0,1)` | `(1,−1)⊙(1,−1)` | related by the seam? |
|-----------|---------------|------------------|----------------------|
| `+`       | `(0,2)`       | `(2,−2)`         | no                   |
| `·`       | `(0,1)`       | `(1,1)`          | no                   |

So no operation on the quotient can lift coordinatewise `+` or `·`
(`no_induced_add`, `no_induced_mul`).

## 3. The twist ring `ZM = ℤ[t]/(t²−1)`, norm `N(a+bt) = a² − b²`

**Units** — search over `|a|,|b| ≤ 4` for `N = ±1`:

```
(a,b) ∈ {(1,0), (−1,0), (0,1), (0,−1)}   i.e.  {±1, ±t}
```

matching `ZM.isUnit_mk_iff`; the unit group is `(ℤ/2)²`.

**Norm 2 is never attained** — search over `|a|,|b| ≤ 20` for `N = ±2`:

```
[]  (empty)
```

matching `ZM.nrm_ne_two`, which is the key to `ZM.irreducible_two`.

**Splitting of small integers** — solutions of `a² − b² = n` with `b ≠ 0`,
`0 ≤ a,b ≤ 29`:

| n | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|----|----|----|
| witness | – | – | (2,1) | – | (3,2) | – | (4,3) | (3,1) | (5,4) | – | (6,5) | (4,2) |

Every odd `n ≥ 3` splits as `((n+1)/2)² − ((n−1)/2)²` (`ZM.odd_prime_splits`),
every `n ≡ 2 (mod 4)` never splits, and `n ≡ 0 (mod 4)` splits. In particular
`3 = (2+t)(2−t)` while `2` stays irreducible: the "6" test case gives **three**
irreducible factors `6 = 2·(2+t)·(2−t)`, not two.

**Idempotents** — search over `|a|,|b| ≤ 5` for `(a+bt)² = a+bt`, i.e.
`a² + b² = a` and `2ab = b`:

```
(a,b) ∈ {(0,0), (1,0)}   i.e.  only 0 and 1
```

matching `ZM.idempotent_eq`; hence `ZM ≇ ℤ × ℤ` (`ZM.not_ringEquiv_prod`),
even though `ZM ⊗ ℚ ≅ ℚ × ℚ`.

## 4. OEIS

The norm form `a² − b²` and the resulting "representable" set
`{n : n ≢ 2 (mod 4)}` is the classical difference-of-two-squares set,
OEIS **A042965** (`0, 1, 3, 4, 5, 7, 8, 9, 11, 12, …`, numbers not `≡ 2 mod 4`).
The unit group order (4) and the sequence of counts of factorisations are too short
to warrant an OEIS identification.

## 5. Counterexample hunt against the conjecture

| claim of the conjecture | test | verdict |
|---|---|---|
| `val` is well defined on the band | symbolic check on the seam | **true** (proved) |
| `Z_M` is a ring with induced operations | descent test §2 | **false** (proved) |
| `1` and `−1` are identified | §2 | **false** (proved) |
| `Z_M` is a one-point compactification of `ℤ` | `emb` injective, unbounded | **false** (proved) |
| `(1,0)·(0,1) = 0` with both factors nonzero | `(1,0) ∼ (0,0)` | **false** (proved) |
| the twist is a prime | unit search §3 | **false**: it is a unit (proved) |
| non-domain with a genuine twist | `(1+t)(1−t) = 0` in `ZM` | **true** (proved) |
