# The Order-Finding Constant

## What Stange's multiplicative-relations method actually is, once the constant is derived instead of measured

**Round 49 · 2026-10-03**

---

## Abstract

A factoring construction based on multiplicative relations modulo `n` (Stange, arXiv:2211.06821)
was measured to succeed on 181/240 instances. The obvious reading — that the ℚ-kernel
construction is what succeeds — is **wrong**, and correcting it changes what the method is.

We derive its success probability:

> **`P = 20/27 = 0.740740…`, exactly**, as `P(v₂(ord_p g) ≠ v₂(ord_q g))` averaged over the
> joint law of `s = v₂(p−1)` for two random odd primes — verified to **−1.7 × 10⁻¹⁸** in exact
> rational arithmetic.

`20/27` is the **classical order-finding constant**. Any method ending in *"take a multiple of
`ord(g)`, strip it, gcd"* scores it. **The ℚ-kernel supplies the multiple; the constant belongs
to the step after it.** The construction contributes no probability advantage at all.

We then remove the barrier that made the method look uncompetitive. Its cost requirement
`b_needed ≈ 5.9 × 10⁵` was carried through two research rounds without derivation. It is
`L_n(1/2, β=1) = exp(√(log n · log log n))` — **Stange's own runtime argmin**, not a
correctness condition. Measured: **`b_min = 3` at every modulus tested.** The construction has
**no correctness floor on `b` whatsoever**; what fails at small `b` is cost.

The net position: **empirically viable, unproven, and the barrier is in the guarantee rather
than in the method.**

---

## 1. The derivation, and the two errors that preceded it

Success of the order-finding step is the event that the two local orders differ in their
2-part:

```
P(success) = P( v₂(ord_p g) ≠ v₂(ord_q g) )
```

For a uniform `g ∈ (Z/p)*`, with `s = v₂(p−1)`, the 2-adic valuation of the order has
`P(v₂ = k) = 2^{−(k+1)}` for `k < s` and `P(v₂ = 0) = 2^{−s}`. Averaging `P(v₂(ord) ≠ v₂(ord))`
over the joint law of `(s_p, s_q)` gives **`20/27`**, monotone from below, with no renormalisation.

**Two derivations of mine were wrong first, and both are recorded here because the second is
instructive:**

1. **Wrong law.** I used `P(s = j) = 2^{−(j+1)}`, which has **total mass 0.5, not 1.0** — it was
   never a probability law. With it the sum is **`5/27`**, and `20/27 = 4 × 5/27`.
2. **An undeclared renormalisation.** The code divided through by the truncated mass, which
   cancelled the factor-2 exactly and made the output land on the prettier constant. **The
   self-test that caught error 1 earned enough trust that error 2 survived unexamined.**

The correct law, `P(s = j) = 2^{−j}`, was measured over **216,815 primes** below `3 × 10⁶`:
0.5006 / 0.2500 / 0.1250.

> **A renormalisation is an assertion that your quantity does not sum to its natural value. If
> you need one, the quantity is usually wrong — find out which, and write it down.**

## 2. The constant is an average over moduli, and that matters

`20/27` is **not** the rate at a fixed modulus. It is an average. The per-modulus rate is the
`p_split`-adjusted value, and `p_split` varies enormously with the modulus's own 2-adic structure.

Measured across three moduli: **`p_split` = 0.750, 0.977, 0.994.** Against a flat `20/27`, two
of them would have shown spurious excesses of **+0.22 and +0.24** that are *entirely*
`v₂(q−1) = 1, 6, 8`.

> **Any rate measured against the flat constant, without the per-modulus `p_split`, is
> measuring the modulus rather than the method.**

This same control caught an apparent **−0.458 "deficit"** that was a `seq`-sampler artefact
(`random` gives 0.733 against `p_split` 0.741).

## 3. There is no correctness floor on `b`

`b_needed` came from a *runtime* estimate. Algorithm 2.2 requires only that `b + c` factor-base
smooth residues can be **found** — nothing about `b` is required for correctness.

| n | `b_max` | `b_needed` | **`b_min`** | ratio |
|---|---|---|---|---|
| 2²⁷ | 12 | 49.7 | **3** | 0.060 |
| 2²⁹ | 13 | 60.0 | **3** | 0.050 |
| 2³³ | 15 | 87.3 | **3** | 0.034 |

**`b_min = 3` at every completed modulus.** The method factors with a 4–5-bit factor base at
every size tested. `b_needed` **overstates the smallest usable `b` by 17–30×**, and the
discrepancy is a property of the *estimate*, not of the construction.

What fails at small `b` is **cost** — `7.3 × 10⁵` trials per relation at `b = 3`.

## 4. Why the cost wall is real, and what closes it

`b_max` is set by `n ≥ 8 · b^{b/2}` — and that bound is **Fontein–Wocjan** (arXiv:1211.6246)
Thm 1.1, **not Stange's**, though Stange points at it. It bounds relation *entries* (Stange p.4:
entries `< n`), so it bounds `b` from **above** — it *is* `b_max`.

Since `b_needed` is subexponential and `b_max ≈ 2 log n / log log n` is polylogarithmic,

```
log(ratio) = β√(L log L) − log L + … → ∞
```

**the ratio diverges, for any β > 0.** Lowering `β` buys a constant factor while the gap grows
without bound. And `β = 1` was **hardcoded**: Stange p.5 states she *"will not devote time to
optimizing the constant β"*; balancing her own two costs gives `β → 1/√2`, three orders better.
`c` does not help — it enters as an additive `log(1 + c/b)`, measured at `→ 1.0000`. There is no
`m`: Algorithm 2.2's parameters are only `B` and `c`.

**The one lever that closes it is offered by the paper itself** (p.2, ref [7] = **Gordon 1993**,
the NFS's own exponent): relation-finding becomes `L_n[1/3]`, and `b_needed` falls from
`5.9 × 10⁵` to **8.4**, inside `b_max` for every modulus up to **551 bits**. But that is **not a
factoring advance** — it is the known `L[1/3]` algorithm re-derived, wearing Stange's
linear-algebra and gcd phases. It establishes where the difficulty lives, not a way past it.

## 5. What the difficulty actually is

An independent measurement decomposes the phase (`n ≈ 2⁴⁰, b = 52`):

| phase | share |
|---|---|
| relation-finding | **95%** |
| kernel | 5% |

**The phase that 48 research rounds attacked is ~5% of the cost.** Relation-finding is NFS, and
NFS is what the state of the art already is.

## 6. Honest limits

- The `b_min = 3` result is at four completed moduli spanning `2²⁷–2³³`, **not** at RSA sizes.
  Cost, not correctness, is what fails at small `b` — and cost at `b = 3` is `7.3 × 10⁵` trials
  per relation.
- The `20/27` derivation is exact **in rational arithmetic**; the Monte Carlo check is
  consistent. It is not an asymptotic statement about a family of algorithms — it is the
  classical order-finding constant, which is the point.
- **No claim is made that any of this is new to the literature.** The derivation explains an
  observed rate; it is not a contribution to order-finding theory.

## Reference

- N. Stange, *Factoring using multiplicative relations modulo n*, arXiv:2211.06821. The
  runtime argmin and the `β` remark are on **p. 5**; the regime and `c = b+1` on **p. 4**; the
  NFS alternative on **p. 2**, ref [7] = D. M. Gordon, *Discrete logarithms in GF(p) using the
  number field sieve*, SIAM J. Discrete Math. 6(1):124–138, 1993.
- E. Fieker, M. Fieker — Fontein–Wocjan, arXiv:1211.6246, Thm 1.1, for the actual origin of
  the `n ≥ 8 · b^{b/2}` regime.

**Verification protocol.** WebSearch was not used for any citation. Every page reference was
read from a **rendered page image** of the source PDF — `pdftotext` rendered Stange's
`8b^{b/2}` as the garbage token `8bb/2` and Shoup's `2√2` as `2 2`, which is how those
radicals were reconstructed at all.