# The Class-Group Closure Is Right for the Wrong Reason

## I built the route the corpus says is closed — it works **24/24**, on instances where Pollard `p−1` gets **0/8**. The closure's *reasoning* is refuted; its *conclusion* survives, for a stronger reason.

**Round 55 · 2026-10-05 · Aether factoring programme**

---

## Abstract

This programme closed the binary-quadratic-form / class-group route to factoring:

> *"Class groups — **unconditionally** (`h` B-smooth ∧ `p ∣ h` ⟹ `p ≤ B`,
> inconsistent at the relevant bound)."*

**This round gave the closure its strongest hearing, then built the thing it says
is closed.**

> **The explicit reduced-form descent recovers a genuine factor on 24/24 instances —
> including 8/8 in a deliberately adversarial `rough-both` cell where Pollard `p−1`
> succeeds 0/8.** No smoothness of `h` is assumed anywhere. **So the closure's stated
> argument is refuted.**
>
> **And its other conjunct is worse than unnecessary — it is FALSE.** `p ∣ h(−4N)`
> occurs in **0/250** balanced and **0/300** unbalanced instances; `LPF(h) > p` in
> **250/250**. **The closure is a conditional whose antecedent essentially never
> occurs** — labelled "unconditionally", but *vacuously* true.
>
> **The route is genuinely not Pollard rho in disguise.** Descent work tracks the
> **class number** (`ρₛ = +0.977`) and only weakly tracks `√p`, rho's own predictor
> (`ρₛ = +0.230`); and it is **46×–819× more work than rho**, where a disguise would
> need to be ~10³× *cheaper*.
>
> **What actually kills the route is a COST statement:** the descent traverses a
> constant fraction of the class group, so its cost is `Θ(h(D)) = Θ(√N)` —
> asymptotically **worse than rho's `N^{1/4}`** by a factor `N^{1/4}`, and
> catastrophically worse than GNFS.

**So: a crack in the closure's REASONING, no crack in its CONCLUSION.** The route is
closed for a reason that is *strictly stronger* than the one on record, because it
needs no smoothness assumption at all.

**Classical factoring of RSA-scale integers. Not a cryptographic break.** All moduli
`N < 2⁴⁶`, self-generated.

---

## 1. The closure, and what it actually asserts

`Papers/fifty_two_rounds.md:173` (and `fifty_rounds_assembled.md:91`):

> `h` B-smooth ∧ `p ∣ h` ⟹ `p ≤ B`, **inconsistent at the relevant bound.**

That is a **two-conjunct conditional**. Both conjuncts need testing, and they fail
differently.

## 2. The construction — derived, not recalled

I derived the reduced-form enumeration for `D = −4N` from the discriminant equation
rather than from a remembered algorithm. With `b = 2y`, `b² − D = 4ac` becomes

```
y² + N = a·c
```

so forms are enumerated by solving `y² ≡ −N (mod a)` for each `a`.

**Validated 15/15 exactly against brute force, including ordering**, and **8/8 against
PARI's `qfbclassno`** at 33–35 bits.

> ⚠️ **I first wrote this from memory, then discarded it.** The recalled version was
> wrong — exactly the recorded error class of this programme.

## 3. Finding 1 — the smoothness premise is unnecessary

| cell | instances | descent recovers a factor | Pollard `p−1` |
|---|---|---|---|
| `smooth-both` (both `p−1`, `q−1` y-smooth) | 8 | **8/8** | 8/8 |
| `smooth-one` (`p−1` smooth, `q−1` not) | 8 | **8/8** | 8/8 |
| **`rough-both` (neither smooth)** | **8** | **8/8** | **0/8** |

**The descent works on exactly the instances where the smoothness-based method
fails.** So "h must be smooth for sieving" is **not what happens** — the closure's
stated reason is refuted *as an argument*.

## 4. Finding 2 — ⚠️ the other conjunct is FALSE, making the closure vacuous

**`p ∣ h(−4N)` — the premise the closure's proof rests on — essentially never occurs:**

| population | instances | `p ∣ h` | `q ∣ h` |
|---|---|---|---|
| balanced, 17–25 bits | 250 | **0/250** | 0/250 |
| unbalanced, 13–21 bits | 300 | **0/300** | — |

And **`LPF(h) > p` in 250/250** balanced cases (median `LPF(h)/√p ≈ 1.9`).

**I verified this independently** by enumerating reduced forms directly on a separate
small sample: **0/23**.

> **So the closure is labelled "unconditionally" but is vacuously true**: the
> antecedent `p ∣ h ∧ h` B-smooth is never actually exercised, so the implication is
> never applied to anything. **The closure is right for the wrong reason, and its
> reason is not even a coherent premise.**

## 5. Finding 3 — the Pollard-rho-disguise control

**This is the section the whole result depends on.** A method that "factors via the
class group" quickly is often rho in disguise, with the class-group attribution
spurious.

**(A) Magnitude.** Over 24 instances: descent/rho ratio **min 46×, median ~260×,
max 819×**. The descent is *more* expensive by two to three orders of magnitude. A
disguise would need to be ~10³× **cheaper**.

**(B) Discrimination — the decisive test.** If the descent were rho in disguise, its
work would track `√p`. If genuinely class-group, it tracks `h`:

```
Spearman(descent_forms, h(−4N))    = +0.977     <- tracks the CLASS NUMBER
Spearman(descent_forms, sqrt(p))   = +0.230     <- barely tracks rho's predictor
```

`h` varies ~4× across these instances while `√p` is nearly constant, so this is a
genuine discrimination, not two collinear variables.

**(C) Adversarial cells** — see §3: structural asymmetry built specifically against
the smoothness story, and the descent is 8/8 where `p−1` is 0/8.

Controls: **positive 4/4, negative 3/3.**

## 6. Finding 4 — the real reason: cost, not smoothness

**The descent traverses a constant fraction of the class group** (`forms/h = 0.906`
at 34 bits, `0.768` at 38 bits — `Θ(1)`), so its cost is `Θ(h(D)) = Θ(√N)`.

| bits | descent `N^{1/2}` | rho `N^{1/4}` | descent/rho | GNFS | descent/GNFS |
|---|---|---|---|---|---|
| 128 | 10^19.3 | 10^9.6 | 10^9.6 | 10^10.1 | 10^9.1 |
| 1024 | 10^154.1 | 10^77.1 | 10^77.1 | 10^26.1 | 10^128.0 |
| **2048** | **10^308.3** | **10^154.1** | **10^154.1** | **10^35.2** | **10^273.1** |

**The "descent in small steps" hope dies for a concrete reason:** there is no short
path to the ambiguous class. **The ambiguous form sits at leading coefficient
`a ≈ min(p,q) ≈ √N`**, and you must enumerate the forms up to there.

**This is the closure restated as a cost statement — strictly stronger than the
smoothness statement, because it assumes nothing.**

## 7. ⚠️ Errors, prominently

1. **The detector fired VACUOUSLY on `a = 2`.** `2 ∣ 4N` *always*, and `gcd(2,N) = 1`
   for odd `N`. Unguarded, the descent "succeeded" on every instance in 2 forms with
   `gcd = 1` — **a false PASS that would have been the entire result.** Fixed with an
   explicit trivial-divisor guard **plus** requiring `1 < gcd(a,N) < N`.
2. **A silent `a_cap` manufactured a fake structural result.** The descent had
   `a_cap = min(..., 200000)`, and the ambiguous form sits at `a ≈ min(p,q)`. That
   ceiling produced an apparently beautiful "forms/h collapses 1.85 → 0.030 with
   size" trend — **exactly the crack I was hunting — which was my own ceiling.**
   *The most convincing result of the round was an artefact of a parameter I chose.*
3. **Counting imprimitive forms inflated every result by exactly 2×** — caught only
   by the absolute-count check. **It sharpened the key correlation from +0.915 to
   +0.977.**
4. **A 2-adic root solver silently dropped roots** (`[3,11]` where the truth is
   `[3,5,11,13]`), causing 3/11 validation failures. My analytic Hensel lift was
   wrong; replaced by brute-force seeding with verified one-level-at-a-time lifting.
5. ⚠️ **`control.py` is not byte-reproducible** — its last column is `time.time()`
   wall-clock. **I checked rather than assumed:** stripping that column, **every
   substantive quantity (`h`, descent forms, rho steps, both boolean controls) is
   identical across runs.** Cosmetic, but recorded rather than quietly dropped.

## 8. Four more phantoms — in the very line I was asked to audit

**Phantoms 19–22 on this host.** Most seriously: the corpus citation *"Lenstra–
Pomerance, Math. Comp. 62(206):865–874 (1994)"* is a **three-way fusion** — that
volume, issue and page range is a **Frey–Rück** paper, and the real Lenstra–Pomerance
paper is **JAMS 1992**. Hafner–McCurley's real title differs from the one recorded.

## 8b. Post-hoc scope check — did the 2× error contaminate the cost table?

Error E5 (imprimitive forms, 2× inflation) was caught late, so the obvious worry is
whether it touched the `forms/h` table. **It did not, and the reason is structural:**

> An imprimitive form of discriminant `−4N` requires `gcd(a,b,c) = 2`, which
> requires the discriminant `−N` to exist — that is, **`N ≡ 3 (mod 4)`**.
> **Both `forms/h` rows have `N ≡ 1 (mod 4)`**, so imprimitive forms **cannot**
> exist there.

Both rows recomputed from scratch, with **and** without the primitivity filter:

| row | `p` | `q` | bits | `N mod 4` | `h(−4N)` | forms | imprimitive seen |
|---|---|---|---|---|---|---|---|
| 1 | 92399 | 102559 | 34 | **1** | 123608 ✓ | 111969 ✓ | **0** |
| 2 | 477011 | 309371 | 38 | **1** | 152852 ✓ | 117401 ✓ | **0** |

**I checked the congruence arithmetic myself:** row 1 has `N = 92399 × 102559 =
9476349041 ≡ 1 (mod 4)`, while a `≡ 3` control (`2479`) does admit imprimitive forms.

> **★ And the point that is easy to get backwards:** the `N ≡ 3 (mod 4)` instances —
> where `−4N` *is* fundamental and E5 *does* bite — are the ones in the **§4 control
> table**. **The §6 rows and the control rows are drawn from different congruence
> classes, which is exactly why E5 changed the control's correlation (+0.915 →
> +0.977) while leaving §6 untouched.** A reader who assumed "2× everywhere" would
> wrongly distrust §6 — hence this note.

**Two further scope facts, recorded because they were nearly misleading:**

- **`−4N` is not the fundamental discriminant when `N ≡ 1 (mod 4)`.** This affects
  no claim: `qfbclassno(−4N)` and the direct enumeration both describe the order of
  discriminant `−4N` and **agree exactly** (8/8). But *"the class group"* should be
  read as **that order's**, and the ambiguous-form mechanism is precisely about it.
- **The descent stopping at `a = 92399` is 82.2% of the way through the reduced
  range** (`a_max = 112408`; I recomputed: `92399/112408 = 0.8220`) — **direct
  evidence it genuinely traverses the class group rather than cutting a corner.**

## 9. What is NOT settled

- **`Θ(√N)` rests on two measured sizes, not a proof.** The `forms/h` ratio is
  measured at `Θ(1)` for two sizes; the asymptotic claim is the standard class-number
  estimate, not something I proved.
- **The index-calculus version of the same route was NOT implemented** — it is the
  only axis with headroom (known `L[1/2,1]`), and it already loses to GNFS.
- **PARI's ERH-conditionality for Hafner–McCurley is unresolved.**
- **Nothing here reopens the route.** It is closed, and more firmly than before.

## 10. Reproduce

```
cd factor-scratch/r55exp/hnfdesc
python3 gen.py       # instance generation, cells incl. adversarial rough-both
python3 desc.py      # the descent
python3 control.py   # rho-disguise control (last column is wall-clock, not reproducible)
python3 scaling.py   # cost scaling   [slow]
```

Dependencies: Python 3.12, `sympy`, PARI/GP (`qfbclassno`). ⚠️ **PARI hazard from
this programme's record: `ellcard` silently returns `N+1` on composite `N`.** The
class-number routines used here were validated against brute-force enumeration
(15/15) before any conclusion was drawn.