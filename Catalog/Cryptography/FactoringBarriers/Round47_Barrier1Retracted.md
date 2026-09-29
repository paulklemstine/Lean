# Round 47 part 11 — RETRACTION of barrier 1: you *can* choose the field

**2026-09-29. `Round47_ThreeBlockers.md` claimed a third, decisive barrier — that at scale
you cannot choose the number field. That claim is WRONG, and the error is the one this
campaign makes most often: concluding a barrier from a failed search.**

---

## What I claimed

`Q ≡ −(m³ + Pm) (mod N)` is "essentially uniform on `[0,N)`", so `P(|Q| ≤ 200) ≈ 400/N`,
so a small `Q` is a `400/N` event, and — since the escapes are "know a factor" or
"Coppersmith at its exact boundary" — the setup step is at least as hard as factoring `N`.

## Why it is wrong

**1. `Q` is not uniform, and my own data already said so.** I ran the search and found
**26, 15, 15** hits at 24, 32 and 39 bits, against a model predicting **25.9, 0.13, 0.001**.
At 39 bits that is **~14,000× the predicted rate.** A model contradicted by four orders of
magnitude, which I read past.

The reason is simple and I should have seen it: **`m ≈ N^{1/3}` implies `m³ ≈ N`.** So
`m³ mod N` is not uniform — it is a small residual, and

> `Q ≈ −(m³ − N) − P·m`,  with `P·m` of size `P·N^{1/3}`,

which is `N^{1/3}` times smaller than `N`. `Q` is **naturally small** in exactly the regime
NFS works in. The density of `|Q| ≤ 200` is of order `200/(3N^{2/3})`, not `400/N`, and the
measurement bears that out.

**2. NFS does not find this `m` by searching it.** I treated "I searched and found nothing"
as "it is hard to find". But choosing the polynomial is the *standard first step of every
NFS computation*, and it is done by **lattice reduction** (Howgrave-Graham): one constructs
`m` from a short vector rather than testing values one at a time. My search was
`2^18` trials; the lattice method is not `2^18` trials.

**3. The Coppersmith remark was a category error.** The provable bound is `N^{1/d} − ε`; the
`−ε` is a statement about what can be *proved*, not a wall the algorithm *hits*. Reading a
theorem's slack as an obstruction is precisely the error that produced the
`arXiv:2601.11131` claim in the handover.

## Corrected barrier list

| | barrier | status |
|---|---|---|
| ~~1~~ | ~~Choose the field~~ | **RETRACTED** — `Q` is naturally small for `m ≈ N^{1/3}`, the lattice method finds such `m` by design, and a naive search failing says nothing about the method |
| 2 | **Certify the point set.** `N² | disc(E)`, so the 2-descent returns `p, q`. | **HOLDS** — proven by the audit's matched-twin control |
| 3 | **Find enough relations.** Supply `≈ 0.03·H` against demand `L_N[1/3]`. | **HOLDS** — measured |

## What this does to the "closed" verdict

`Round47_ThreeBlockers.md` ended by arguing the direction is *closed* on the strength of
three barriers. **One of the three was mine and was wrong**, so that argument does not stand.
The honest position is narrower: **two** barriers remain, both real, and the third — the one
that would have made this a clean negative — is retracted.

This is the third time in one session that I had to withdraw a headline I had already
reported, and the second time the withdrawal came from checking my own arithmetic rather
than from an agent. The pattern is consistent enough to be worth stating as a rule for
anyone continuing this: **a search that fails is not a barrier until the method that would
succeed has been tried.**
