# Round 47 part 5 — the reduction extends to the FULL cubic randomisation

> ## ⚠️ PREDATES THE CONTROL REPORT — read `Round47_Audit.md`
>
> Two claims below were **voided by the adversarial audit** and are retained only for the
> record of what was believed at the time:
>
> 1. **"12/12 factors recovered"** is **VOID as a factoring result.** Step 2 of Algorithm 47
>    calls `ellrank`, and PARI's 2-descent needs the cubic discriminant's prime
>    factorisation — which for these curves **is** the factorisation of `N`, because
>    `disc = -27c^2(m^3-c)^2` and `N | (m^3-c)`. Proven by a matched-twin control: identical
>    coefficient sizes, smooth vs hard discriminant, `ellrank` 0.02 s vs timeout >300 s.
> 2. **"Decidable failures, `chi_P` decided by a basis"** is **FALSE.** `chi_P` is **not** a
>    homomorphism on `E(Q)` — the Jacobian transports the *curve* law, not multiplication of
>    relations (39/1243 violations; 3 of 15 instances are not homomorphisms). The identity
>    `chi(l1 l2) = chi(l1)chi(l2)` **does** hold (69/69); the two are not the same statement.
> 3. **The 62%/60.5% figure** is a real measurement with zero `ellrank` errors, but it is a
>    rate *in `f`*, not a completeness certificate, and the instrument used to get it is the
>    one shown to be circular.
>
> **What survives**: the algebra (1155/1155, 22/22, 6/6), the twelve relations as genuine
> NFS relations verified in `Z[alpha]` with no leakage, the Jacobian and its independent
> cross-check, the genus-1 structure at `d=3`, and the genus-5 collapse at `d=4`
> (`Round47_DegreeBarrier.md`), which is the round's actual result.


**2026-09-29. `Round47_MordellWeil.md` used the specialisation `f = X³ − c`. Lee–Venkatesan
randomise the full cubic `f = X³ + PX + Q`. A reduction that only works at `P = 0` is a
specialisation artefact. It is not: the whole thing survives, and `P = 0` is recovered
exactly.**

---

## 1. The cone generalises, and stays rational

With `α³ = −Pα − Q` and `α⁴ = −Pα² − Qα`, expanding `g²` for `g = (g₀,g₁,g₂)` gives

| coefficient | expression |
|---|---|
| `α⁰` | `g₀² − 2Q g₁g₂` |
| `α¹` | `2g₀g₁ − 2P g₁g₂ − Q g₂²` |
| `α²` | `2g₀g₂ + g₁² − P g₂²` |

so `l(α) = g²` is **linear** exactly when

> **(CONE)**  `g₁² + 2g₀g₂ − P g₂² = 0`.

At `P = 0` this is round 47's cone. **For `P ≠ 0` it is a plane *conic*, and it always has
the rational point `(P/2 : 0 : 1)`** — so it stays rational. In the chart `g₂ = 1` it is
`g₁ = s`, `g₀ = (P − s²)/2`; setting `s = −2t` and clearing denominators:

> **`g = ( P v² − 4u² ,  −4uv ,  2v² )`**,  `t = u/v`.

At `P = 0` this is `2·(−2u², −2uv, v²)`, i.e. round 47's `g` up to the scalar `2v²` that
`g²` absorbs.

## 2. The quartic, and the term round 47 never saw

`l(m) = l_slope·m + l_const` with

```
l_slope = 8t³ + 2Pt − Q          l_const = P²/4 − 2Pt² + 4t⁴ + 4Qt
```

gives

> **`l(m) = 4v⁴ · A_P(t)`,   `A_P(t) = 4t⁴ + 8mt³ − 2Pt² + (2mP + 4Q)t + (P²/4 − mQ)`.**

**The `−2Pt²` term is real and it vanishes at `P = 0`**, which is precisely why round 47's
specialisation never showed it. I initially "simplified" it away, and the self-test caught
that: `1155` cases, `86` mismatches. **Do not drop it.**

Since `4v⁴` is a square, `l(m)` is a perfect square **iff `A_P(t)` is a rational square** —
and `A_P` is **still a quartic**. So the relations are still the rational points of a
**genus-1** curve and the whole reduction survives.

## 3. The Jacobian, and the exact `P = 0` reduction

With `x = y + 2t² + 2mt` the `t⁴` and `t³` terms cancel exactly and leave a quadratic in `t`,

```
(2x − 2m² − P) t² + 2(mx + mP/2 + Q) t + (m²Q/2 + P²/8 − x²/2) = 0
```

whose discriminant gives, with `U = 2x − 2m² − P`, `V = mx + mP/2 + Q`,
`W = x²/2 − P²/8 + mQ/2`, the cubic

> **`Y² = V² + U W`.**

This is a **cubic in `x` for every `P`**, so genus 1 is preserved without exception. Two
worked instances, written out:

- `m=20, P=2, Q=−2`:  `Y² = x³ − x² + 679x + 16765`
- `m=14, P=11, Q=−207`: `Y² = x³ − (11/2)x² − (26273/4)x + 4855539/8`

**At `P = 0, Q = −c` it is exactly round 47's curve.** Verified symbolically on six
instances (`m,c` = (20,2), (14,207), (19,256), (28,108), (13,368), (22,263)):

> `Y² = x³ − 3mc·x + c² + m³c` — identical in all three coefficients, every time.

## 4. Verification (`Round47_general_cubic.py`), with the bugs it caught

All arithmetic in exact `Fraction`s — **not** floats. `P*P/4` in Python is float division
and it silently contaminated an entire test run until it was caught.

| check | result |
|---|---|
| `gpar` satisfies `(CONE)` identically, `P ≠ 0` included | 0 violations |
| `l(m) == 4v⁴ A_P(u/v)` | **1155 / 1155** |
| `l(m)` a square ⟺ `A_P(t)` a square | **535 / 535** |
| rational quartic points land on `Y² = V² + UW` | **22 / 22** |
| at `P=0, Q=−c`, the cubic equals round 47's | **6 / 6** |

**Three of my own errors were caught by these tests, not by reading them:** the spurious
`−2Pt²` removal (86 mismatches), the `2v²` scaling (comparing `v⁴A` against `4v⁴A`), and
float division in `P*P/4`. This is the third time in round 47 that a test I wrote caught me
rather than the record — the campaign's rule 1, and the reason it is a rule.

## 5. What this changes

**Algorithm 47 is no longer confined to `f = X³ − c`.** It applies to
`f = X³ + PX + Q` with `f(m) ≡ 0 (mod N)`, which is the family Lee–Venkatesan actually
randomise (their seed is a general coefficient vector, not a single constant). Concretely:

1. pick `P, Q, m` with `m³ + Pm + Q ≡ 0 (mod N)`;
2. parametrise the conic `(CONE)` — rationally, since `(P/2 : 0 : 1)` is on it;
3. the relations are the rational points of the genus-1 quartic `y² = A_P(t)`;
4. its Jacobian is the cubic `Y² = V² + UW` of §3, of height `O(log N)`;
5. compute a Mordell–Weil basis and read `chi_P` off it, as before.

**The one-parameter restriction was the most obvious objection to the method, and it is
gone.** What remains exactly as it was: the equidistribution step (`Round47_ChebotarevAnd
Retraction.md` §1–2), the rank-0 instances, and the fact that the rank computation's cost
is the binding constraint at scale.

**Not established here:** that the general curve's rank is generically positive (measured
only for `P = 0` so far: ranks 1–5, zero in 10%); that `chi_P` attains `−1` at the same
rate for `P ≠ 0`; and any runtime statement at RSA scale.
