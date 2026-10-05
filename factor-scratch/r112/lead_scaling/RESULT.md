# Lead: does the α ≥ 0.15 GIFP wall move with n? And a correction to r111c

**Status: SUPPORTED (α-wall is n-independent) + CORRECTION (t and s have opposite
optima; r111c's "use t=ceil" advice is incomplete).**

## The n-scaling question

All r110/r111 results sit at n=200 where the lattice is only 15×15. If the
α ≥ 0.15 wall were a small-dimension artefact it should move at larger n.
Tested at n=200 and n=400 with m scaled as n/50, γ=0.50, **forcing
t = ⌈(1−√α)m⌉ and s = ⌈√α·m⌉** to remove the r111c rounding artefact:

| n | α | m | t=round | t=ceil | reading |
|---|---|---|---------|---------|---------|
| 200 | 0.10 | 4 | 3/3 | 0/3 | see correction below |
| 200 | 0.15 | 4 | 0/3 | 0/3 | wall persists |
| 400 | 0.10 | 8 | 0/3 | **3/3** | m=8 failure was purely rounding |
| 400 | 0.15 | 8 | 0/3 | 0/2 | **wall persists** |

**α ≥ 0.15 does not recover at n=400.** The wall is not a finite-size artefact
in this regime. This is now confirmed at two independent moduli sizes.

Also: at n=400/α=0.10/m=8 the attack goes 0/3 → 3/3 purely by replacing
`round` with `ceil` on t, reproducing the r111c finding at a second n.

## CORRECTION to r111c: t and s have OPPOSITE optima

r111c concluded "compute `t = ⌈(1−√α)·m⌉`". That advice is **half right** and
actively wrong if applied to `s` as well.

At n=200, α=0.10, m=4: `ideal_t = 2.7351` so `t_round = t_ceil = 3` — the two
agree. But `ideal_s = 1.2649` so `s_round = 1` while `s_ceil = 2`. My "ceil"
mode raised **both**, which is why that row shows 3/3 → 0/3. Holding t=3 fixed
and varying s alone:

| s | verified |
|---|----------|
| 1 | **4/4** |
| 2 | 0/4 |
| 3 | 0/4 |

So at this point t=3 requires **s=1**; s=2 destroys it. `t` wants to be
rounded *up* (no undershoot) while `s` wants to be rounded *down* here. They are
not symmetric — they enter the shift-polynomial weighting differently
(`N1^max(t−i,0)` vs `N2^−min(i+j,s)`).

**Revised statement of the r111c finding:** the correct rule is not "t = ceil"
but "choose (t, s) so neither truncates in a way that breaks the size balance" —
and the two must be tuned *jointly*, since raising s can undo a good t. The
r111c commit message says "compute t = ⌈(1−√α)·m⌉ directly rather than tuning m
by trial and error"; that remains valid for t, but the fix is incomplete without
attention to s, and my earlier "t=ceil rescues nothing at α=0.15" conclusion
was tested with s also raised — so it stands as stated for α=0.15 (where s makes
no difference because the attack fails anyway), but the general recipe needs
correcting.

## Honest limits

- n=400 with 2–3 seeds per point is thin. The direction is clear and consistent
  with r111c, but these are not high-confidence counts.
- The α ≥ 0.15 wall is confirmed n-independent **here**; this does not explain
  it. The `gifp_wall` subagent owns the explanation.
- I did not sweep s systematically; the "s wants to round down" claim is
  established at one (n, α, m) point only.