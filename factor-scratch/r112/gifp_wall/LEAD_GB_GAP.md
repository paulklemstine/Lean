# Lead: the α ≈ 0.17–0.18 "Gröbner-closure gap" is NOT a separate failure mode

**Status: REFUTES the third-ceiling claim. There are TWO ceilings, not three.**

## The claim I tested

`gifp_wall/RESULT.md` claims a distinct third failure at α ≈ 0.17–0.18:
"the lattice is healthy (27/28 vanishing) but the Gröbner step fails to close
(0/3 verified). No (t,s) fixes that one."

## What I measure

Independent pipeline, (t,s)=(3,0), m=4, γ kept feasible per α, counting `nz` =
reconstructed polynomials that vanish over ℤ at the true root:

| α | γ | nz | min \|G\| over prefixes | \|G\| reaches 4? |
|---|---|---|---|---|
| 0.10 | 0.660 | **8/9** | 2 | only at k=4 (shortest prefix) |
| 0.15 | 0.680 | **8/9** | 2 | only at k=4 |
| 0.17 | 0.660 | **0/9** | 2 | never |
| 0.18 | 0.650 | **0/9** | 2 | never |
| 0.20 | 0.630 | **0/9** | 2 | at k=4 |

**At α = 0.17–0.18 the lattice is NOT healthy — `nz = 0/9`.** That is the same
value as α=0.20. There is no separate Gröbner-only failure band.

## Where the discrepancy came from

Reading the agent's own tables, the `27/28` figures appear in the
**α = 0.10 / 0.15** rows (its `quick_reach.sage` γ-scan and its
`dbg_why20` α-sweep). Its α=0.20 row states `nz = 0/15` explicitly. So the
"27/28 at α=0.17–0.18" was a misattribution of the healthy α≤0.15 numbers to a
band that its own data shows is already dead. Consistent with its self-corrected
note that "my α=0.18 'rescue' was nz-only — end-to-end it's 0/3."

**Correction to my own r112 synthesis**, which repeated the three-ceiling
framing: there are **two** ceilings, both geometric:
- **α ≈ 0.17+** — the lattice stops producing vanishing polynomials (nz → 0).
  The "Gröbner failure" is downstream of that, not an independent cause.
- **α ≥ 0.19–0.20** — the same nz=0, with the shift/modulus ratio at 1.503.

The honest single statement: **the lattice degrades to zero vanishing
polynomials somewhere in α ∈ (0.15, 0.17]**, and everything above that is
downstream. I have not located the transition more precisely than that.

## A separate, real observation

The `len|G|` trace shows the Gröbner basis reaches length 4 **only at k=4** —
the shortest prefix — and the root-extraction step then still needs a
*univariate* element in the basis, which the trace shows is **never present
(`univariate-in-G=0` everywhere)**. This is the same read-the-answer bug class
documented in r110: the script's `len(G)==ngens` test is necessary but not
sufficient, and the README gcd route is doing the real work. It is not a new
failure mode, just a reminder that `ok` here always means "ok via the gcd
route".

## Limits

- Single seed per α in this probe; the `nz=0` readings at 0.17/0.18/0.20 are
  consistent across the trace but I did not sweep seeds.
- The transition in α ∈ (0.15, 0.17] is bracketed, not located.
- Using m=4; the agent's data at m=6 may differ, and I did not re-check.