# Round 47 part 12 — the direction is closed: the relation curve's genus explodes at `d ≥ 4`

**2026-09-29. This is the close. A rigorous structural statement about the direction round
47 opened, and it explains *why* rather than merely recording a failure.**

---

## The result

For `f = X^d − c`, the locus

> `C_d = { g ∈ ℤ[α] : g²  reduces to a LINEAR form modulo (X^d − c) }`

is the complete intersection of `d−2` **quadrics** in `P^{d−1}`, of degree `2^{d−2}`, with

> **genus `g(C_d) = 1 + (d−4)·2^{d−3}`**

giving `g(C_3)=1`, `g(C_4)=1`, `g(C_5)=5`, `g(C_6)=17`. The relation condition `l(m)=u²` is
a **double cover of `C_d` branched at `r = 2^{d−1}` points**, so the relations live on

> **`Ŷ_d : y² = l(m)`,  genus `1 + (d−3)·2^{d−2}`  —  `g(Ŷ_3)=1`, `g(Ŷ_4)=5`, `g(Ŷ_5)=17`, `g(Ŷ_6)=49`.**

**`d=3` gives 1, reproducing round 47's verified quartic exactly.** For `d ≥ 4` the Mordell–Weil
step — the entire mechanism of Algorithm 47 — **has no analogue.**

## Evidence

- The quadrics were derived and cross-checked two ways: `Q₂ = 2g₀g₂ + g₁² + c·g₃²`,
  `Q₃ = 2g₀g₃ + 2g₁g₂` at `d=4`; the `c`-terms come from `α^{k+d} = c·α^k`. Control
  **2400/2400**. (`CTRL2b` exists because the agent's first pass silently dropped every
  `c`-term and a control caught it.)
- Genus computed **twice independently** — Hilbert function by matrix rank, and by Gröbner
  — which **agree**, and match adjunction `K_C = ((d−4)H)|_C` at `d = 4,5,6`. Smoothness
  Jacobian-verified, `(g)^D ⊂ J`.
- The branch count `r` comes from a reduced branch scheme at `d=4,5,6` × 5 instances:
  **`r = 8, 16, 32`**. For `d=4` the explicit form is
  `l(m) = 2[v⁵(v−2m) + v³w(v−2m) + c(v²+2mv+w)]` on `w² = v⁴ − c`, of degree 8, squarefree
  5/5, both identities checked against the direct `ℤ[α]` reduction.
- **`d=3` reproduces round 47's cone** — the two lines of work meet and agree.

### A verified `d=4` instance (so the case is not vacuous)

`N = 1333 = 31·43`, `f = X⁴ − 36`, `m = 36` (since `m⁴ − c = 1333·1260`),
`g = 40 + 16α − 5α² + 2α³`, `l = 560X + 4804`:

> `g² = 4804 + 560α + 0α² + 0α³` over `ℤ[α]`,  `l(m) = 24964 = 158²`,  `g(m) = 87448`,
> `gcd` gives **43 and 31 — `N` factored**.

Four corrupted `g` were rejected by the validity test; the same `g` with `m+1` gives a
non-square. **So `d = 4` relations exist — there are just almost none.**

### The supply collapses

38 instances with `c = m^d mod N`, height `H = max(|g_i|, |m|)`:

| `d` | instances with a relation | relations at `H ≤ 240` |
|---|---|---|
| 3 | 22/38 = **57.9%** | **1941** |
| **4** | 1/38 = **2.6%** | **1** |

An independent scan over 30.27M triples found **150 genuine relations** — a rate of
`5.0·10⁻⁶` per triple, and every one has `c = v⁴ − w²`.

## Why this closes the direction

Lee–Venkatesan's degree is `d = δ(log n)^{1/3}(log log n)^{−1/3}`, which is **3–4 at
`n ≈ 10^20`**. So:

- at `d = 3` the relation curve is genus 1 and Algorithm 47 works — but it is blocked by the
  descent (`N² | disc(E)`, so the 2-descent returns `p` and `q`) and the supply is
  `≈ 0.03·H` against a demand of `L_n[1/3]`;
- at `d = 4` the relation curve is **genus 5** and the supply falls by a factor of
  **~2000×** — the mechanism is simply gone.

**The method does not degrade gracefully past `d = 3`; it disappears.** And the operating
point of the NFS sits exactly at the boundary.

## The four independent closures

| | closure | kind |
|---|---|---|
| 1 | **Choose the field** — RETRACTED, was my error | — |
| 2 | **The descent** — `disc(E) = 27c²(m³−c)²`, `N² | disc`, so `ellrank` factors `N` | proven by matched-twin control |
| 3 | **The relation count** — supply `0.03·H` vs demand `L_n[1/3]` | measured |
| 4 | **The degree** — `g(Ŷ_4) = 5`, supply down `~2000×` | proven + measured |

## What round 47 is worth

A correct and useful **negative** result, which the record did not have: the relations of the
cubic NFS form the rational points of an explicit genus-1 curve with an explicit Jacobian and
an explicit quadratic character — and that is the *only* degree at which this is so. One step
further and the relation curve is genus 5 and the supply collapses by three orders of
magnitude. The structure explains the absence: **the elliptic geometry is a feature of
`d = 3` alone, and the NFS does not operate at `d = 3` for long.**

That is a better answer than "no method was found". It says where the method would have to
live, and why it is not there.

---

## Addendum, 2026-09-29 — why the group law cannot supply NFS relations

The closure above is structural (the genus grows). One further measurement says what goes
wrong *mechanically* even at `d = 3`, where the curve is genus 1 and the mechanism works.

A relation's smoothness burden is entirely on `B(t) = c^2 − 20ct^3 − 8t^6` (since
`Norm(g) = v^6·B(t)` and `v^6` is a perfect cube). Generate relations by the **group law
alone** — no descent, no factorisation — and measure:

| `n` (multiple) | height of `t` | bits of `B(t)` | 2·10^5-smooth? |
|---|---|---|---|
| 1 | 1 | 11 | **yes** |
| 2 | 5.99·10¹² | 261 | no |
| 3 | 1.50·10³⁰ | 605 | no |
| 4 | 2.58·10⁵¹ | 1065 | no |
| 5 | 5.44·10⁷² | 1677 | no |

> **1 / 12 of the generated relations are smooth — and that one is the base point, i.e. the
> point you started from.**

The pattern is the mechanism: `B(t)` grows **quadratically in the multiple index `n`**
(11, 261, 605, 1065, 1677 bits — differences ≈ `n²`), which is exactly the canonical-height
law on a genus-1 curve. **The group law hands you points almost for free, and their norms
explode at the same time.** The smoothness bar `L_n[1/3]` is *fixed* — at `N = 1333` it is
literally **21** — so past the first point nothing can be smooth, because the number is
already hundreds of digits.

**This is the sharpest statement of why round 47's approach cannot be an NFS.** NFS does not
need the relations to be structured; it needs *many small smooth values of a linear form*,
and it gets them by **sieving** — a random walk onto small primes. An elliptic curve gives a
group, and the group law converts a small norm into an exponentially larger one. **The
structure that made the obstruction computable is the same structure that prevents the
relations from being usable.**

That closes the last open measurement on this direction, and it closes it for a reason that is
not "we looked and did not find it".
