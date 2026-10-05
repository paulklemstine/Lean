# FINDING (ledger axis, r114): `pari(N).factor(1)` returns N ITSELF — a silent no-op

## The claim
PARI's `factor(x, D)` second argument is a **DOMAIN / primality bound `D`**, NOT a
boolean flag. Passing `1` asks for "primes < 1", i.e. NO trial division at all.

## Verbatim from this host's PARI (`?factor`, via `gp -q`)

> ```
> ?factor
> factor(x,{D}): factorization of x over domain D. If x and D are both integers,
> return partial factorization, using primes < D.
> ```

Contrast with `factorint`, whose doc DOES use flags:

> ```
> factorint(x,{flag=0}): factor the integer x. flag is optional, whose binary
> digits mean 1: avoid MPQS, 2: avoid first-stage ECM (may fall back on it
> later), 4: avoid Pollard-Brent Rho and Shanks SQUFOF, 8: skip final ECM (huge
> composites will be declared prime).
> ```

## Measurement (this host, `cypari2` under `~/sage_mamba`)

N = 79-bit semiprime (both factors prime, p*q == N asserted):

| call | time | result |
|---|---|---|
| `pari(N).factor()` | 0.0014 s | `[274877906951, 1; 1099511627791, 1]` — CORRECT 2-factor split |
| `pari(N).factor(1)` | **0.0001 s** | `Mat([302231454915477043675241, 1])` — **N ITSELF, 1 row** |
| `pari.factorint(N)` | 0.0016 s | correct 2-factor split |
| `pari.factor(N,1)` | 0.0000 s | **N itself** |

Reproduced at 79, 119, 159 and 239-bit semiprimes and for `flag` in {0,1,2,3}:
**every** call with an explicit integer second argument returned the trivial
single-row `[N, 1]`. A 239-bit semiprime "factored" in 0.0001 s, which is
physically impossible — that alone is the tell.

## Why it is dangerous (the campaign's #1 trap, one layer down)

The campaign's standing rule is "report the generic baseline beside every count."
A baseline built on `factor(N,1)` reports **COMPLETE=True** with **rows=1**,
i.e. it *appears* to solve the instance while having done nothing. Anything
comparing attack time against that baseline compares against 0.0001 s.

**r113 is currently in flight and has this bug in FOUR scripts**, each with a
comment asserting the opposite of the truth:

- `r113/gifp-n800-scale/pari_ecm.sage:1` — `# HONEST BASELINE. In PARI, factor(n) uses
  trial division + rho; factor(n,1)` … asserted to be the ECM arm.
- `r113/gifp-n800-scale/ecmbase.sage:3` — `# PARI factor(n,1) additionally runs ECM
  (Montgomery multiple-…)`
- `r113/gifp-n800-scale/pari_ecm2.sage:16,24`, `pari_ecm3.sage:4` — same call.

`r113/gifp-n800-scale/ecm2.py:3-5` states the conclusion explicitly:
> `r112's headline positive is "at n=800 the GIFP lattice recovered p2 3/3 while
> PARI factor(N2) ran >4 min without success". PARI 2.17's factor() has NO ECM
> stage (measured in RESULT.md), so that baseline is a strawman.`

Two problems with that, in order of severity:
1. The replacement baseline it builds (`factor(1)`) **does not run ECM**, because
   there is no ECM flag on `factor` at all — it is a primality bound. The
   "stronger baseline" is a 0.0001 s no-op.
2. Its premise (PARI `factor()` has no ECM) is itself **unverified**, and r112's own
   committed log contradicts the "without success" claim (see the other finding).

`r112/verify_gifp/hardN2.sage.py:20` correctly used bare `pari(N2).factor()`, so
**r112's own baseline was not affected by this bug.** The bug is confined to
in-flight r113 code.

## Correct calls
- strongest generic baseline PARI offers: `pari(N).factorint()` (doc: includes first-stage ECM)
- bare `pari(N).factor()`: what r112 used; its n=800 log shows a real 310.72 s split
- NEVER pass an integer as the 2nd arg of `factor` expecting a behaviour flag.

## Guard to add
Any baseline call must assert the returned factor set is a **strict** refinement,
i.e. more than one row OR the single row is < N. `rows==1 and row0==N` means the
call did nothing. Asserting "the returned factors multiply back to N" is NOT
sufficient — it holds for the trivial answer, which is precisely why this went
unseen.
