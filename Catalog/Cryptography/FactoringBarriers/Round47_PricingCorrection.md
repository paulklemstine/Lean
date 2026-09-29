# Round 47 part 8 — correction: the pricing was an exponent printed as a value

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


**2026-09-29. This corrects `Round47_HonestVerdict.md`, which was committed ~30 minutes ago
with two figures that are wrong. Found by me, on checking my own arithmetic.**

---

## 1. The error

`Round47_HonestVerdict.md` says an NFS needs "`~L_n[1/3] ≈ 2.5e35` relations" and that the
method is "31× worse than GNFS". **Both are wrong.** The helper returned

```python
def L13(N):
    k = (64/9)**(1/3); lnN = log(N)
    return k * lnN**(1/3) * log(lnN)**(2/3)   # <-- this is the EXPONENT
```

— the exponent of the `L`, not the `L`. Everything downstream inherited it.

**The formula itself is right, and it is validated against the record's own number:**
`L_N[1/3, 1]` at `N = 10^20` computes to **6464**, and `Round46_Handover.md` records
`B = L_n(1/3) = 6463.8` at `n ≈ 10^20`. That is an independent check from a source I did not
write, so the *definition* is sound and only my *use* of it was broken.

## 2. The correct figures

| `N` | `L[1/3,1]` (demand) | `L[1/3,1.923]` (GNFS) |
|---|---|---|
| `10^4` | 35.4 | 954 |
| `10^8` | 219 | 3.2·10⁴ |
| **`10^20`** | **6464** | **2.1·10⁷** |
| `10^40` | 2.3·10⁵ | 2.1·10¹⁰ |
| `10^100` | 1.7·10⁸ | 6.8·10¹⁵ |
| `10^1000` | (overflows float) | — |

**So `Round47_HonestVerdict.md`'s conclusion that the method is "worse than GNFS by a
constant" is retracted. The naive pricing at `N = 10^20` points the *other* way:**

- demand ≈ `L[1/3,1]` = 6464 relations (more precisely, more than the factor base has primes,
  `π(6464) ≈ 810`);
- measured supply slope ≈ **0.03 generators per unit of rational height**;
- so `H ≈ 6464/0.03 ≈ 2.2·10^5`;
- **via a group law** (cost `~H`): `≈ 2.2·10^5`, which is **~100× below** GNFS's `2.1·10^7`;
- **via brute force over `(u,v)`** (cost `~H²`): `≈ 4.7·10^10`, which is `~2200× above` GNFS.

A `100×` constant improvement in the `L`-shape would move `L[1/3, 1.923]` past
`L[1/3, 1]` — i.e. below the "trivial" balance point of the same exponent. **That is the
first time anything in this campaign has looked like it could touch the GNFS constant.**

## 3. Three things that could kill it, none of them tested

1. **The slope's dependence on `N` is measured NOWHERE.** The `0.03` comes from three moduli
   at `ln N ≈ 7–8`. The required height `H` grows with `N` while the curve's coefficients
   grow like `N`, so the number of points of height `≤ H` on a curve with `N`-sized
   coefficients is a genuinely different regime. **This is the single measurement that
   decides the question and it is not made.** It needs moduli at `ln N = 20, 40, 100`, which
   are out of brute-force reach — which is precisely why the group law is needed, and the
   group law is what is circular.
2. **Circularity.** `N² | disc(E)` always (`Round47_Circularity.md`). A basis needs a
   2-descent at the bad primes `p`, `q`.
3. **Smoothness.** `Norm(g) = v^6·B(t)`, and the whole burden is on `B(t) =
   c² − 20ct³ − 8t⁶`. Not one of the ~2·10^3 measured generators was tested for smoothness.

## 4. What survives from the previous document

Unchanged: the 73% factorisation-free measurement, the median-2-relations figure at `H = 60`,
`N² | disc(E)`, the six retractions, and the verdict that **this is not a factoring method
today**. Only the *pricing* and the *direction of the naive comparison* are corrected.

**Three consecutive background measurements timed out** — the rank-computation scaling ladder,
the rank-0 certificate search, and the `ellrank`-versus-hard-discriminant timing test. All
three were measuring the cost of the group law, and all three died. That is itself the
clearest available signal that the group law is the bottleneck, and it is the piece that is
circular.

## 5. Net position, stated honestly

> The algebra is verified, the character is explicit, the obstruction is measured at 73%,
> and a naive `N = 10^20` costing suggests a ~100× constant-factor win — **against a method
> that is circular, whose cost has never been measured beyond `ln N = 8`, and whose
> smoothness requirement has never been tested on a single example.**

That is a lead, not a method. It is the most promising thing round 47 produced, and it is
also the furthest from proven.
