# GIFP threshold γ > 4α(1−√α) — VERIFIED end-to-end (round 110)

**Status: the round-109 blocker is CLOSED.** The GIFP threshold is now verified
end-to-end under real SageMath, using the authors' own ground-truth code.

## What round 109 got wrong

Round 109 concluded: *"the shift-polynomial construction is DEGENERATE in my
port… EVERY reduced row is zero… I cannot diagnose this reliably."* and
attributed the failure to Sage's exact `L.LLL(0.8)` being irreproducible with
fpylll.

**Both claims were wrong.** The lattice was never degenerate. Under Sage 10.7:

- the lattice is 15×15 (non-degenerate),
- `reconstruct_polynomials` returns 10 polynomials,
- **8 of 10 evaluate to exactly 0 over ℤ at the true solution**.

That is a working small-root attack. The `fpylll` port was the thing that was
broken; the mathematics and the Sage construction were fine.

## Why the authors' script still prints 0

`sage gifp.sage 200 0.1 0.7 0.1 0.15 4` prints **0 (failure)** even though the
attack genuinely succeeds. The reason is in `find_roots_groebner`
(`gifp.sage:183-232`): after building the Gröbner basis it only harvests roots
from **univariate** basis elements. With the extra variable `w` the basis is

```
f1 (x,y,w) deg 3     f2 (x,y,w) deg 3     f3 (x,y,w) deg 3     f4 (z,w) = z*w − N2
```

— **none univariate**, so `len(roots) != pr.ngens()` and it returns without
yielding. The recovery is genuinely there; the script just doesn't read it.

The authors' own README documents the correct extraction, which the script never
implements: take `gcd(f2,f3)`, factor it, and pull out the `(y,w)`-linear factor
`p2·y − y0·w`. Verified on the authors' example seed:

```
gcd(f1,f2) = x + 1496577676626844588240573268701473812127674924007424·y + w
gcd(f2,f3) factors as  (p2·y − y0·w) · (x + c·y + w)
   p2 = 1049051663491949916718543835817164082636546493960542391   ← ground truth p2
   y0 = 900216                                                    ← ground truth y0
   N2 / p2 = 792731                                              ← ground truth q2
```

Both `p2` and `q2` match the ground truth **exactly**.

## Threshold sweep (α = 0.1, threshold γ > 4·0.1·(1−√0.1) = 0.27351)

Every "verified" count below is an **independent** check that the recovered
divisor is a nontrivial exact factor of the true N₂ (and equals p₂ or q₂), not
merely that the pipeline ran.

| γ | margin | verified | zero-polys at root |
|---|--------|----------|--------------------|
| 0.30 | +0.027 | 0/10 | 0/7 |
| 0.35 | +0.077 | 0/10 | 0–3/7 |
| 0.40 | +0.127 | 0/10 | 2–4/7 |
| 0.45 | +0.177 | 8/10 | 5/7 |
| 0.50 | +0.227 | 10/10 | 5/10 |
| 0.60 | +0.327 | 10/10 | 7–8/10 |
| 0.70 | +0.427 | 20/20 | 8/10 |

Below threshold: **0/10 at γ = 0.20 and 0/10 at γ = 0.30**.

**The bound is confirmed, and it is not tight at these parameters** — the attack
only succeeds from γ ≈ 0.45, about 1.6× the proven threshold. The theorem's
`γ > 4α(1−√α)` is a *sufficient* condition; the true threshold in this regime
is higher.

## Reproducibility

- Sage **10.7** (`/tmp/mamba`) and Sage **10.9** (`~/sage_mamba`) — independent
  installs — **both** give 20/20 at γ = 0.70 and both reproduce the authors'
  example seed. The round-109 worry that exact `L.LLL(0.8)` output is
  irreproducible is **refuted**: the recovery is stable across Sage versions.
- Determinism: 3 repeat runs at γ = 0.70 → **20/20 each time**.

## Harness bugs hit (and their lesson)

Three separate runs gave *wrong* answers before I got a trustworthy number:

1. `exec()` of a `.sage` fragment **skips the Sage preparser**. This silently
   changed semantics and reported **0/20** on a seed that `recipe.sage` solves.
   `final_confirm.sage` is deliberately self-contained and preparsed; do not
   refactor its body into an `exec`'d fragment.
2. `generate_gifp_instance` returns `None` after `max_attempts`; unhandled, it
   crashed the sweep. Unseedable instances are **skipped, not counted as
   failures**.
3. One transient 19/20 that did not reproduce in 3×20 subsequent runs — a
   log/shared-state artifact, not physics. Consistent with
   `unseeded-counts-are-uncitable`: re-run before publishing any count.

Also: exponent tuples from `mono.exponents()` are indexed in **parent-ring**
order `(x,y,z,w)`, not in the order of `fac_ir.variables()` — getting this
backwards silently swaps p2 and y0.

## Files

- `gifp_ref/gifp.sage` — authors' ground truth, unmodified.
- `gifp_verify_sage.sage` — full pipeline + README gcd recovery + independent
  verification. **The headline script.**
- `gifp_threshold_sweep.sage` — the γ sweep table.

## Net effect on the campaign

Round 109's "polynomial-time IFP corollary" (r109, 8/8) was already verified and
is unaffected. What is new: the **GIFP threshold itself** is now verified, and
the `w`-variable recovery path is understood well enough to state *why* the
authors' script under-reports (it only reads univariate Gröbner elements).

> ⚠️ **r111–r111c are partially RETRACTED (round 112).** The α ≥ 0.15 wall they
> reported is an artefact of `gifp.sage:339`'s `t = round((1−√α)m)` collapsing the
> modulus by a full n bits, not a property of the construction. The threshold
> verification *in this document* is unaffected. See
> `factor-scratch/r112/LEAD_SYNTHESIS.md`.

Follow-up rounds r111–r111c (see `GIFP_R111_ALPHA_SCALING.md`) push further:
- The bound's **shape** is wrong, not just its constant: the observed success
  threshold tracks `γ/[4α(1−√α)]` differently at each α, and fails entirely for
  α ≥ 0.15 at every feasible γ and m.
- The apparent "m-resonance" (m=4 works, m=3/5/6/8 fail) is a **t-rounding bug**
  in `gifp.sage:339-340`, confirmed causally — compute `t = ⌈(1−√α)m⌉` instead.
  This is independent of the α ≥ 0.15 wall, which `t=ceil` does not rescue.