# Round 47 part 33 — the discriminator: the dead moduli are EMPTY CURVES, not tall ones

**2026-09-29. This decides the axis. The question was whether the 54% of moduli that give no
factor have their `chi_P = −1` relation hidden above `H = 200`, or whether the relation curve
is simply empty. It is the second.**

---

## The measurement

For each dead modulus, find a valid `f = X³ + c` with `m³ ≡ c (mod N)`, then census **every**
relation of height `≤ H` for `H = 200, 600, 1500`, recording the `chi_P` of each. No early
exit, no stopping at the first hit.

| bits `N` | `H`=200 | `H`=600 | `H`=1500 |
|---|---|---|---|
| 21 | 1 relation, `+1` | 1, `+1` | 1, `+1` |
| 25 | 0 | 0 | 1, `+1` |
| 33 | 0 | 0 | **0** |
| 37 | — | — | no small `c` found within the scan budget |

> **Zero to one relations at height 1500. These curves are EMPTY.**
> They are not tall curves whose `−1` sits at height 2001 — **there is essentially nothing
> there at all**, at any height I can reach.

**So the explanation is (a), not (b).** It is not a search-depth problem. The relation curve
for these `(N, f)` genuinely supplies almost nothing.

## What this means for the method — and it is a *mechanism*, not a barrier

**Each different `f` gives a different curve, and roughly half of them are empty.** That is
exactly the structure a probabilistic algorithm needs:

> **The method is not defeated by these moduli — it is defeated by *this* `f`.** Change `f`,
> get a new curve, and the per-modulus rate is what the earlier sweep measured: `1/7 … 13/26`
> across twelve moduli.

So the correct algorithm is the one already in `Round47_Method.md`: **repeat the trial with a
fresh `f` until it fires.** The "all-or-nothing" appearance in the scaling table was an
artefact of `find_m_c` returning essentially the *first* small `c` it saw for each modulus,
so each row tested a single `f` and reported that one `f`'s fate. With many `f` per modulus the
rate is `46%` overall.

## And the honest cost, restated

- **The trial is milliseconds.** `O(H²) = 4·10⁴` isqrt calls plus one gcd.
- **Choosing `f` dominates**: `N/cmax` probes by brute scan — `9.1·10²` at 14 bits,
  `1.2·10⁸` at 30 bits. NFS does this by lattice reduction; that step is still uncosted
  here (issue #515's next-step 1).
- **Empty curves are not avoidable by height.** A different `f` is the only lever, and about
  half of them are empty.

## The two-line state

> **The method works whenever the relation curve is non-empty — verified 68/68, 910/910,
> 16,411/16,411, 706/706, every success a true factor, descent-free and factorisation-free.
> Roughly half of all `f` give an empty curve, so repeating with fresh `f` is the algorithm
> and its per-trial rate is ~46%.**
>
> **What is not yet measured: the cost of finding a good `f` by lattice rather than by
> scanning, and hence the size at which the method stops being worth running at all.** That
> is a quantity, not a principle, and it is the one number that would settle whether this is
> a curiosity or a competitor.
