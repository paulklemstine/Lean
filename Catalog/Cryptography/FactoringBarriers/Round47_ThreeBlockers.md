# Round 47 part 10 — the method is blocked three independent ways, and the third is new

> ## ⚠️ BARRIER 3 BELOW IS RETRACTED — see `Round47_Barrier1Retracted.md`
>
> I claimed you cannot choose the field at scale. **That is wrong**, and the error is the
> campaign's most common one: concluding a barrier from a failed *search*. My own data
> already contradicted it — 26, 15, 15 hits at 24/32/39 bits against a model predicting
> 25.9, 0.13, **0.001** (14,000x the predicted rate at 39 bits). The reason is that
> `m ≈ N^(1/3)` implies `m³ ≈ N`, so `Q ≈ -(m³-N) - P·m` is of size `N^(1/3)`, not uniform on
> `[0,N)`. And NFS finds this `m` by **lattice reduction**, by design, not by searching it.
>
> So the "closed" verdict below loses one of its three supports. **Barriers 1 and 2 (the
> descent, and the relation count) both hold; barrier 3 does not.**


**2026-09-29. Completing the picture. Barriers 1 and 2 are known; barrier 3 — that you
cannot even *set up the polynomial* at scale without factoring `N` — is new, and it is the
one nobody had noticed.**

---

## Barrier 3 (new): you cannot choose the field

To run the method you need `f = X³ + PX + Q` with **small** `P, Q` and an `m` near `N^{1/3}`
satisfying `f(m) ≡ 0 (mod N)`. Fix `m` and `P` and `Q` is *forced*:

> `Q ≡ −(m³ + Pm)  (mod N)`,  and it is essentially uniform on `[0, N)`.

So the chance of landing in `|Q| ≤ 200` is about `400/N` per try. Measured:

| `N` | `ln N` | `(m,P,Q)` with `|Q| ≤ 200` found |
|---|---|---|
| 20 bits | 13.1 | yes, `m=254, P=2, Q=129` |
| 40 bits | 27.6 | **none** |
| 80 bits | 55.3 | **none** |
| 160 bits | 110.5 | **none** |
| 320 bits | 221.4 | **none** |

**And the two obvious ways out are the two classic factoring routes.** Solving
`m³ + Pm + Q ≡ 0 (mod N)` for a small `m`:

- **via a factor** — know `p`, and Hensel/`m ≡ root (mod p)`; or
- **via Coppersmith** — and here is the sting: for degree `d` the guaranteed root bound is
  `N^{1/d}`, so for `d = 3` it is **`N^{1/3}`** — **exactly the size of `m` we need.** Coppersmith
  is exactly at its boundary, which is why it does not work.

So **the setup step is itself at least as hard as factoring `N`.** The whole round-47
procedure is blocked before it starts, at every size where it would matter.

This is a *different* barrier from the two the audit found, and it is the reason none of the
12 instances was ever a real test: they were all chosen with `m` and `c` in a range small
enough to find, which is only possible at small `N`.

## What is NOT a barrier (a useful negative)

> **`ellinit` is not the problem.** Measured `0.000 s` at every size tested, up to
> `a4 = 1280 bits` and `disc = 3847 bits`.

So the audit's D1 is precisely a statement about **`ellrank`** (the 2-descent), not about
PARI's curve arithmetic generally. A descent-free route that iterates the **group law alone**
from a single point is not blocked at the arithmetic level. That is worth knowing, and it is
the reason the negative is worth stating carefully rather than as "PARI chokes".

## The three barriers together

| | barrier | status |
|---|---|---|
| 1 | **Choose the field.** `Q ≡ −(m³+Pm) mod N` is uniform, so small `Q` is a `400/N` event; the alternatives are a factor or Coppersmith at its exact boundary. | **blocks at scale** |
| 2 | **Certify the point set.** A basis needs a 2-descent at the bad primes `p, q`, and `disc(E) = 27c²(m³−c)²` is divisible by `N²`, so the descent returns `p, q`. | **blocks always** |
| 3 | **Find enough relations.** Supply is `≈ 0.03·H` generators at rational height `H`; an NFS needs `≈ L_N[1/3]`. | **blocks** |

Barrier 2 is proven by the audit's matched-twin control. Barrier 1 is measured above.
Barrier 3 is measured and was the original honest verdict.

## What this round actually produced

1. **A correct characterisation** of the Lee–Venkatesan obstruction as a group-theoretic
   question on an explicit cubic `Y² = V² + UW`, valid for the **full** cubic randomisation
   (verified 1155/1155, 535/535, 22/22, 6/6).
2. **A verified algebraic reduction** from a relation with opposed branches to a factor of
   `N` — twelve instances confirmed in `Z[α]` exactly, no leakage.
3. **A clean measurement** that such a relation exists for **60.5%** of `(m,c)` — the
   obstruction is absent most of the time, with zero `ellrank` errors and depth saturation
   at 2.
4. **Three independent structural barriers** to turning that into a method, one of them new.
5. **A retraction of my own headline**, twice over, with the evidence.

**And no method.** Not because the mathematics is wrong — it is verified to the digit at
every step I know how to check — but because the reduction runs into the same wall three
separate times, and the wall is the integer `N` itself.

That is, on the evidence of 47 rounds, a reasonably strong argument that this direction is
closed rather than merely unfinished: the obstruction to a non-circular attack is *choosing
the number field*, which is where number field sieve theory already spends its hardest
assumption, and I have now found that the elliptic structure of the relations does not
relieve it by even one bit.
