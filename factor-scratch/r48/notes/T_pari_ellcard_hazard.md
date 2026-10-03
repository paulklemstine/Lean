# ⚠️ PARI/GP `ellcard` on a COMPOSITE modulus returns `N+1` — silently, instantly

**Verified by the orchestrator, independently of the agent that reported it. This is an
operational hazard for every experiment in this program, because PARI is the workhorse.**

## The finding

For `E : y² = x³ − x`, PARI's `ellcard(E, N)` with `N` **composite** returns a plausible
integer in ~0.00 s and **raises no error**. The value is wrong.

| N | factorization | `ellcard(E,N)` | truth = #E(F_p)·#E(F_q) | match |
|---|---|---|---|---|
| 21 | 3·7 | 18 | 32 | ✗ |
| 55 | 5·11 | 62 | 96 | ✗ |
| 221 | 13·17 | 82 | 128 | ✗ |
| 10403 | 101·103 | **10404 = N+1** | 10816 | ✗ |
| 1022117 | 1009·1013 | **1022118 = N+1** | 1006720 | ✗ |
| 100160063 | 10007·10009 | **100160064 = N+1** | 100240128 | ✗ |

**0 of 6 match.** On primes the same call is correct (verified: #E(F_3)=4, #E(F_7)=8,
#E(F_101)=104, #E(F_103)=104, all matching the standard CM curve of conductor 32).

The pattern `N+1` is the tell: it is the naive "one point at infinity plus `N` affine points"
count, i.e. PARI is counting a different object than `#E(Z/NZ)`, and that object's value
**contains no information about `p` and `q`**.

## Why this is dangerous here specifically

This program has been bitten nine times by the failure mode the round-47 record names as:

> "a control that reports success over zero instances is worse than no control, because it
> **green**"

`ellcard` on a composite is a **green** control by every superficial test: it returns fast,
it returns an integer, it does not raise, and the integer is the right *order of magnitude*
(`N+1` is within a small factor of the true count, which is also `~N`). Only a comparison
against an independently-derived truth exposes it.

An agent computing "the point count over Z/NZ" would get `N+1`, and any subsequent reasoning
about recovering `p+q` from the count would be built on sand.

## The rule this forces

> **Any library call used as ground truth must be validated on a case whose answer is known
> independently — including in the exact regime where it will be used.**

`ellcard` was validated on primes (where it is correct) and then used on composites (where it
is not). The validation regime and the use regime were different, which is precisely the
recurrence of "a control that only runs at the parameter you derived it at is not a control."

**Concretely, for PARI/GP:**
- `ellcard`, `ellsea`, and point counts over `Z/NZ`: **only meaningful for prime `N`.**
- Any group-order computation feeding an ECM-style argument must be checked against a
  CRT-derived truth `#E(Z/NZ) = Π #E(F_{p_i^{e_i}})` before use.
- `qfbclassno` is a genuine, different case: it is documented for arbitrary discriminants and
  the class-group agent verified it against brute-force enumeration of reduced forms on 10
  discriminants. **That verification is the model to follow.**

## Credit

Reported by the round-48 cross-discipline agent (`notes/H_crossdiscipline.md`), which noted
that trusting the output would have produced a **fake polynomial-time factoring result** — the
kind of result that gets committed and published, as this program has done with 16 fabricated
citations already. Re-verified here with an independent script because the claim is severe
enough to act on.

## Related, same round, same agent

For `E : y² = x³ − x`, computing the **projective** count `#E(Z/NZ)` is **equivalent to
factoring `N` in both directions, with no slack** — already in print (arXiv:1911.11004, p. 3),
which also states that a *single* count is not known to suffice.

The asymmetry that makes this precise: the four **affine** twist counts sum to exactly `4N`
(a tautology, no information), while the four **projective** ones sum to `4N + 4p + 4q + 4` and
so recover `p + q`. The known equivalence lives entirely in the projective half. Any future
attempt must therefore compute a projective count — and must not use `ellcard` to do it.