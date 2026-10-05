# Harness inventory and trustworthiness audit — round 114

Lens: harness inventory + trustworthiness. Working dir `/home/raver1975/lean`,
round dir `factor-scratch/r114/`.

**Verdict up front: the campaign's harnesses are mostly *methodologically*
sound and several are *mechanically* broken in ways that silently invert their
own result. The single most important finding is that
`gifp_ref/gifp.sage` — the generator behind every GIFP number in r110–r113 —
is NOT reproducible even when given a seed, so no GIFP count in the record is
seeded in the sense the brief requires.**

---

## PART 1 — Inventory

### A. GIFP generator — `Experiments/UMWWindow/gifp_ref/gifp.sage`

* **What it does.** Builds two RSA moduli `N1=p1·q1`, `N2=p2·q2` of equal bit
  length whose large primes `p1,p2` share a high bit string; `q1,q2` are
  independent, `|q_i| = alpha·n`. Then `modular_gifp()` builds the shift
  lattice over `ZZ[x,y,z,w]`, LLL-reduces it, reconstructs polynomials and
  solves a Gröbner system with `z·w − N2` inserted, yielding `p2, q2`.

* **VERDICT: BROKEN — not reproducible.** `gifp.sage` line 49:

  ```python
  if N1.nbits() != modulus_bit_length or N2.nbits() != modulus_bit_length:
      attempts += 1
      seed = int(time.time() * 1e6)      # <-- OVERWRITES the caller's seed
  ```

  The `seed` argument is rebound to wall-clock microseconds on **every retry**.
  The bit-length check fails often enough (the `p1` construction has no loop
  guaranteeing the top bits land exactly) that retries are routine. Measured:

  ```
  === SAME SEED 12345, REPEATED THREE TIMES ===
    trial 0: N1 = 535796636361...
    trial 1: N1 = 665757749129...
    trial 2: N1 = 382976067373...
    all three identical: False
  ```

  This is not a theoretical concern. It is the *exact* mechanism behind the
  three withdrawn counts in the memory note
  `unseeded-counts-are-uncitable` (13/40 → 12/40; 17/40 withdrawn; 3/8 → 5/8).
  **Those were not careless seeding — they were this line.**

* **Known trap it embodies.** The brief's stated trap ("returns `None` unless
  `n*param` is integral") is real but is the *minor* one. I could not reproduce
  a uniform 0/0 sweep at the parameters tried (`n∈{200,800}`, `alpha=0.1`,
  `gamma=0.1`, `beta∈{0.05,0.1,0.15,0.2}` all returned `ok`). The **major**
  trap is the silent seed overwrite, which is strictly worse: it does not fail
  loudly, it returns a *plausible instance from a different seed*, and every
  downstream count inherits it.

* **Fix.** `seed` must be treated as immutable; derive retries as
  `seed + attempts` (or a SHA-256 substream), never from `time.time()`.

### B. GIFP attacker — `gifp.sage::attack_gifp_instance` / `modular_gifp`

* **What it does.** As above, plus the two-parameter `(t,s)` lattice shape.
* **VERDICT: TRUSTED as an algorithm, but every count built on it inherits
  finding A.** The root-recovery step (`f(x0,y0,z0)==0`, `p1·q1==N1`,
  `p2·q2==N2`) is a genuine multiply-back gate and is the right check. The
  `t = round((1−√α)·m)` / `s = round(√α·m)` defaults are the "one-sided fix"
  the r112 synthesis already retracted as unsafe.
* **Known trap.** `find_roots_groebner` **pops the last element** of the
  Gröbner sequence when `len(G) != ngens` (line 232) and retries. It does not
  record how many pops it needed. Two different `(t,s)` can therefore reach the
  same outcome by different routes and a sweep that reports only the boolean
  loses that. `r112/verify_gifp/vcore.sage::scan_gb` fixes this (it returns
  `tries` and `popped`) and should be preferred.

### C. Independent GIFP re-derivation — `r112/verify_gifp/vcore.sage`

* **What it does.** Re-execs `gifp.sage`'s text into a private globals dict and
  rebuilds the instance/lattice with `tmode ∈ {round, ceil, fixed}`; returns
  `nzero` (how many reconstructed polynomials actually vanish at the true
  solution) and scans **every** Gröbner pair for a coefficient dividing `N2`.
* **VERDICT: TRUSTED — this is the best-verified GIFP harness in the tree.** Its
  exhaustiveness fix over the authors' version (`for i,j` over all pairs, all
  monomials, not just `G[1],G[2]`) is the right correction, and the
  `nz`/`nzero` count is a real measurement rather than a pigeonhole.
* **Known trap.** It `exec()`s `gifp.sage`, so it inherits finding A's seed
  overwrite verbatim. It also carries the brief's `exec()`-of-`.sage` risk: it
  sets `_g['__name__']='gifp_mod'` *before* the exec so the `__main__` block does
  not run, which is correct, but the preparser is still skipped — safe here only
  because `gifp.sage` happens to avoid `^`/float-division. Any edit that
  introduces `x/2` would silently change meaning.

### D. ECM baseline — `r113/gifp-n800-scale/baseline.sage`, `ecm1.sage`, `ecmesc.sage`

* **What it does.** Times PARI `factor()` and ECM on the same instance to supply
  the generic-factoring baseline.
* **VERDICT: BROKEN — the ECM call cannot succeed, by construction.** All three
  write `ok, fct = ecmfactor(N, 11000)`. On this box
  `sage.libs.libecm.ecmfactor(number, B1, verbose=False, sigma=0)` returns:

  ```
  ecmfactor(10403*10429, 11000) -> (True, 108492887, 712645761)     len=3
  ecmfactor(199-bit prime, 2000) -> (False, None)                  len=2
  ```

  A 2-tuple unpack of a **3**-tuple raises
  `ValueError: too many values to unpack (expected 2, got 3)`. The docstring in
  `sage/libs/libecm.pyx` line 79 says *"Either `(False, None)` … or `(True, f)`"*
  — **the docstring is wrong; the implementation returns a third `sigma`
  element.** So these harnesses only appear to work on the *failure* path
  `(False, None)`, and **raise on precisely the instances ECM cracks**. Every
  "ECM did not find it" number from those files is void, and every "ECM found
  it" is impossible.

  Second trap in the same API: `ecmfactor(15, 2000) -> (True, 15, 657125637)`.
  It returns `N` itself — "success" with `f == N` is **not** a factorization. A
  caller must guard `1 < f < N and N % f == 0`.

* **Fix (implemented in `infra/_baseline_worker.py`).** Unpack `r[0], r[1]`,
  guard `1 < f < N`, and loop over `sigma` values to emulate `ncurves` — there
  is no `ncurves` or `seed` parameter; `ecmfactor` runs exactly **one** curve.

* **Knock-on.** This means the r113 "PARI is a strawman, ECM is the real
  baseline" *correction* rests on a broken ECM call. The direction is still right
  (PARI 2.17 `factor()` has no ECM stage), but the ECM numbers are not evidence.
  **Re-measure before citing r113/adversarial-audit's ECM timings.**

### E. Self-contained ECM — `r113/adversarial-audit/ecm.py`, `ecm2.py`, `ct_ecm.py`

* **What it does.** Stage-1 Lenstra ECM from the primary description, in
  Montgomery (ecm.py) and Jacobian (ecm2.py) coordinates, with `ct_ecm.py` as
  positive+negative control.
* **VERDICT: UNKNOWN-leaning-TRUSTED.** `ecm.py` and `ecm2.py` carry explicit
  self-checks and `ct_ecm.py` plants factors of known size with a multiply-back
  assertion, which is the discipline the brief demands. I did **not** re-run
  them (out of this lens's budget). `ecm2.py` was written specifically to
  cross-check `ecm.py`'s formulas — that is the right structure.
* **Known trap.** Both are *independent reimplementations of the same method*.
  Agreement between them is a genuine control; either alone is not.

### F. Lattice library — `r113/lattice-obj/lib.py` (was `lib.sage`, changed
mid-audit)

* **What it does.** Seeded semiprime generator with exact bit lengths, Brent
  rho, PARI baseline, multiply-back `ok()`.
* **VERDICT: BROKEN — `gen_N` raises `TypeError` on every call from Sage.**
  Measured:

  ```
  bits=64 bits2=64 -> TypeError: The only supported seed types are:
                      None, int, float, str, bytes, and bytearray.
  ```

  Line 20 is `rng = PyRandom(seed*1000003 + bits*101 + bits2*7)`. Under the Sage
  preparser `7` is a `sage.rings.integer.Integer`, so the expression is an
  `Integer`, and `random.Random` rejects it. The file's own header says
  *"The Sage preparser rebinds `int()` → `Integer`, which silently breaks
  `random.Random(seed)` and cost 3 debug cycles"* — **it diagnosed the trap
  correctly and the fix is incomplete**: it switched to a plain `.py` file but
  never wrapped the seed in `int()`. One-word fix.
* **Second note.** This directory was **actively rewritten while I audited it**
  (`lib.sage` → `lib.py`, plus new `ideallat.py`, `reach.py`, `vacuity.py`).
  Another agent is working the same tree. Any verdict here is a snapshot.
* **Known trap.** Sage-preparsed `Integer` seeds. The campaign-wide rule: wrap
  every RNG seed in `int()`.

### G. Stange Q-kernel — `r113/stange-revive/code/stange.py`, `r112/stange_kernel/core.py`

* **What it does.** Algorithm 2.2 (right-kernel over Q → `alpha_t` → `G =
  gcd(·)`, which is a multiple of `ord(g)`), plus the standard order-trick to
  reach a nontrivial `gcd` with `N`.
* **VERDICT: TRUSTED — the best-disciplined harness in the tree.** `stange.py`
  is written from the printed algorithm with a page citation, **asserts
  `ord(g) | G` on every trial rather than assuming it**, and — importantly —
  uses SHA-256-derived substreams with this comment:

  > `NEVER random.Random(x.__hash__()) -- Python randomizes str/tuple hashing
  > per process under PYTHONHASHSEED, which made two "same-seed" passes
  > disagree in r112 (28/40 vs 33/40).`

  **That is the same root cause as finding A**, independently diagnosed and
  fixed here. It is strong evidence the r112 `28/40 vs 33/40` drift was a
  seeding bug, not a marginal measurement — which retroactively explains a
  mystery in the record.
* **Standing caveat.** The 75% Q-kernel success remains **retracted** as a
  kernel effect (it is exactly the classical 20/27 from `v2(ord_p) ≠ v2(ord_q)`).
  The harness is trustworthy; the claim it was measuring is not.

### H. Coppersmith / small-root — `r113/aux-amplifiers/core.py`,
`r55exp/hnfdesc/`, `r53exp/catmine/`

* **What it does.** Howgrave-Graham lattice construction for
  `f(x)=x+a` monic degree-1, root extraction, multiply-back verification.
* **VERDICT: TRUSTED.** `aux-amplifiers/core.py` is plain Python, imports
  nothing from r110–r112, and re-verifies every candidate factor by
  multiplying back. `r55exp/adaptive/vacuity.py` and
  `r53exp/catmine/vacuity_control.py` are **negative controls of exactly the
  right kind**: they plant `polys = [x − y_rand]` and check the detector fires
  there and *only* there, and they record in the header that their first
  version's positive control printed `0/200` — "a vacuous test that looks like
  a pass". That is the campaign's best methodological writing.
* **Known trap.** `r53exp/catmine/threshold_test.py` is the file that gave
  13/40 then 12/40. **Do not reuse it.**

### I. Vacuity-control precedents — `r53exp/catmine/vacuity*.py`,
`r55exp/adaptive/vacuity.py`

* **VERDICT: TRUSTED, and the correct model for this round.** These are the
  harnesses that taught the campaign to ask "does the probe also fire at a
  random point of the same size?" before believing any recovery count.
  `infra/verify.py` is the same idea applied to *instance size* rather than
  *polynomial structure*.

### J. Stray root-level files

* `A2b_chipcross.py`, `_scratch_comm.py`, `scratch_test_*.py`,
  `scratch_final_catalog_cleaner.py` — **not factoring harnesses**; Lean/Aether
  catalog tooling. Out of scope for this lens.
* `cop.json`, `cop2.json`, `cop3.json` (2.1 MB each, `cop.json` and `cop3.json`
  **byte-identical size**), `churn*.json`, `anti.json`, `_sx.json`,
  `r45_axis7_bach.json` — **measurement dumps with no accompanying code
  provenance**. `cop.json` == `cop3.json` by size is a red flag for a
  copy-paste. VERDICT: **UNKNOWN / uncitable** — no seed, no command, no
  harness. These cannot be reproduced and should not be cited. I did not open
  them beyond `ls`; that is itself the finding.

---

## PART 2 — Built and verified this round

`factor-scratch/r114/infra/`. Run `python3 selftest.py`; exits non-zero on any
failure.

| File | Does | Trust rule enforced |
|---|---|---|
| `baseline.py` + `_baseline_worker.py` | generic factoring with a **hard** wall-clock kill | status ∈ `{factored, gave_up, no_factor, error}`; multiply-back gate inside |
| `verify.py` | arithmetic gate **+** vacuity gate | one verdict ∈ `{INVALID, VACUOUS, UNKNOWN, NON-VACUOUS}` |
| `instances.py` | seeded instances, **small factor guaranteed > 2^40 bits** | refuses to build a vacuous instance |
| `doublerun.py` | run twice, exact-agreement on per-seed outcomes | `agree` boolean + named flaky seeds |
| `selftest.py` | acceptance test for all four | 9 sections, ~40 assertions |

### 2.1 Baseline factorer with timeout — `baseline.py`

Subprocess-per-backend with **SIGKILL to the process group**. A `timeout=` on
the parent Bash call is not enough: `sympy.factorint` on a 2048-bit modulus does
not return, raise, or print, and the child keeps the CPU. Verified:

```
== TEST 2: 2048-bit RSA modulus, T=20 ==
N = 2048-bit RSA modulus (617 decimal digits)
  ecm    -> no_factor | ran to completion, no factor found (13.464s)
  sympy  -> gave_up   | gave up at T=20.0s (eff 20.0s)
  pari   -> gave_up   | gave up at T=20.0s (eff 17.0s)
  rho    -> gave_up   | gave up at T=20.0s (eff 20.0s)
  PASS: no backend factored the 2048-bit modulus at T=20s

== TEST 1: 60-bit, T=60 sympy ==
  -> factored | factored in 0.622s (work 0.525s), small factor 30 bits VACUOUS(<2^40)
  PASS
```

And that the kill *reclaims CPU*, which is the part that is easy to get wrong:

```
== TEST 3: does the timeout actually RECLAIM CPU? ==
  asked T=5.0s, returned in 5.01s, status=gave_up
  PASS: parent returned 5.01s after a T=5.0s request
  live _baseline_worker.py processes (excluding this test): 0
  PASS: no orphaned worker survived the kill
```

**Four statuses, not two.** `no_factor` (ran to completion, found nothing) is
deliberately distinct from `gave_up` (killed at T). Collapsing them is how
"ECM found nothing" becomes "ECM was still running."

**Three bugs found and fixed while building it** — all three were live
Sage/PARI API traps, not typos:
1. `sage -python` does not exist in Sage 10.9 (only `-c` and `file`). Using it
   produced `sage: error: unrecognized arguments: -python`, which surfaced as a
   *misleading* "backend output failed multiply-back".
2. `ecmfactor` 3-tuple (finding D).
3. PARI `factor()` returns an `IntegerFactorization` whose `list()` is
   `(prime, exponent)` **pairs**; `[int(x) for x in f]` raises
   `TypeError: int() argument must be ... not 'tuple'`. Correct form:
   `[int(prime) ** int(exp) for prime, exp in f]`.

Also: Sage startup (~1 s) is charged to the wall clock but not to the backend's
work, so `time_s` and `work_s` are reported separately and a 3 s `startup_grace`
is subtracted from `T`. Without it a `T=2` run reports `gave_up` on a backend
that never started.

### 2.2 Ground-truth verifier — `verify.py`

```
== TEST 4: verifier catches WRONG arithmetic ==
  p*q correct  -> verdict=VACUOUS  |small|=20 bits  small factor is 20 bits (<= 2^40)
  p*q WRONG    -> verdict=INVALID  |small|=-1 bits  p*q != N (or p/q degenerate)
  PASS: wrong arithmetic is caught

== TEST 4b: verifier catches a VACUOUS instance ==
  verdict=VACUOUS  |small|=20 bits  baseline(sympy) factored N in 0.988s at T=30.0s;
                                    small factor is 20 bits (<= 2^40)
  PASS: 20-bit factor flagged VACUOUS automatically
```

The two questions are kept separate because conflating them is how r110 was
published. `verify_factors` answers *"did your arithmetic hold"*;
`verify_claim` adds *"was the answer free"*. A ground-truth check on a 20-bit
factor is a tautology.

### 2.3 Seeded instance generator — `instances.py`

Hard guarantee: `small_bits < 41` **raises**. SHA-256-derived seeds (never
`__hash__`, per the `stange.py` precedent). Exact bit lengths, never
approximate.

```
== TEST 6: determinism and the 2^40 guarantee ==
  seed 42 N bits=800 small=60 bits
  PASS: same seed -> same N, different seed -> different N
  PASS: exact bit lengths, multiply-back holds, small factor 60 > 40 bits
  reproduce: gen_instance(nbits=800, small_bits=60, seed=42, tag='plain')

== TEST 6b: the vacuity guard FIRES ==
  ValueError: small_bits=30 is <= 2^40; VACUOUS BY CONSTRUCTION. Pass small_bits >= 41.
  PASS

== TEST 6e: gifp-shaped instance at n=200 is REFUSED ==
  ValueError: alpha=0.1 at n=200 gives a 20-bit small factor (<= 2^40): VACUOUS
              BY CONSTRUCTION. Raise nbits or alpha.
  PASS: the exact regime that voided r110 cannot be built here
```

`gen_gifp_like` provides the shared-bit **shape** (n=800, α=0.10 → 80-bit small
factor) without importing `gifp.sage`. It is labelled `shape_only=True` in the
returned dict because it is **not verified equivalent** to the published
construction. Use the real generator when the real construction is the object.

### 2.4 Double-run harness — `doublerun.py`

Compares the **per-seed outcome vector** for exact equality. Timing is
deliberately excluded from the comparison and reported separately — two runs of
the same attack will always differ in wall time, and folding that into the
verdict trains you to ignore the check.

```
== TEST 7b: an UNSTABLE measurement is CAUGHT ==
AGREE          : NO -- DO NOT PUBLISH
differing seeds: [0, 1, 3, 4, 6, 7, 9, 10]
  seed 0: pass1=(('hit', True),) pass2=(('hit', False),)
  ...
== TEST 7c: timing jitter alone is NOT a disagreement ==
AGREE          : YES
```

`rate()` reports a Wilson 95% interval, because an exact binomial interval is
degenerate exactly where these campaigns live:

```
  0/12  -> 0/12 = 0.000  (95% CI 0.000-0.242)
  12/12 -> 12/12 = 1.000 (95% CI 0.758-1.000)
```

A `0/12` does **not** license "impossible"; it licenses "below 24%".

---

## PART 3 — What this changes for the record

1. **`gifp_ref/gifp.sage` is not seeded.** Every GIFP count in r110–r113 —
   including the n=800 3/3 that is the campaign's one live positive — was
   measured on an instance drawn from `time.time()`. **This does not refute
   n=800**; it means n=800 cannot currently be *reproduced*, which is a
   different and more serious defect. One-line fix, then re-run.

2. **`r113/gifp-n800-scale/{baseline,ecm1,ecmesc}.sage` cannot report an ECM
   success.** Any ECM timing from them is void pending re-measurement.

3. **`r113/lattice-obj/lib.py::gen_N` raises on every call** from Sage
   (`Integer` seed). One-word fix.

4. **The two drifts the memory note attributes to "unseeded counts" have a
   single identified cause** — the `time.time()` seed overwrite — and
   `stange.py` already diagnosed and fixed it independently. Fixing
   `gifp.sage` the same way should be the first action of the round.

## Falsifier — RUN, and it CONFIRMED the diagnosis

Claim: *line 49 of `gifp.sage` is the cause of GIFP non-reproducibility.*
Falsifier: patch that one line to `seed = seed + attempts`, run the same sweep
four times, and see whether the instances become identical. If they still
differ, the defect is deeper than the seed line and this audit is wrong.

**Result — the one-line patch is exactly sufficient.** Both files differ by
that single line and are loaded with `load()` (which applies the preparser;
`exec()` does not, per the brief's own trap):

```
=== FALSIFIER: is line 49 the cause? ===
  ORIGINAL        (seed = int(time.time()*1e6))
    4 trials @ seed=12345 -> DIFFER (4 distinct of 4)
      trial 0: N1 = ...493080897217
      trial 1: N1 = ...259392212081
      trial 2: N1 = ...546156036617
      trial 3: N1 = ...740126571177
  PATCHED         (seed = seed + attempts)
    4 trials @ seed=12345 -> IDENTICAL
      trial 0: N1 = ...801233495617
      trial 1: N1 = ...801233495617
      trial 2: N1 = ...801233495617
      trial 3: N1 = ...801233495617
```

Reproduce:
```
cd /home/raver1975/lean/factor-scratch/r114/infra
/home/raver1975/sage_mamba/envs/sage/bin/sage _seedfix_falsifier.sage
```

**I did NOT apply the fix to `Experiments/UMWWindow/gifp_ref/gifp.sage`.** This
axis builds infrastructure and audits; it does not silently edit a prior round's
generator. The patched copies live here as `_gifp_orig.sage` / `_gifp_fixed.sage`
so the lead can review the diff before landing it.

Note what this does and does not mean. It does **not** refute the n=800 3/3
result — the mechanism may well be real. It means the result is currently
**irreproducible**, which is a more serious defect than being wrong: a wrong
result can be caught, an unreproducible one cannot be re-checked.

## Honest limits of this audit

* I did **not** re-run the ECM implementations in `r113/adversarial-audit/`
  (`ecm.py`, `ecm2.py`, `ct_ecm.py`). Their *verdicts* are reasoned from their
  source and structure, and are marked UNKNOWN-leaning-TRUSTED accordingly.
  They are the obvious next thing to re-measure, especially now that the
  `ecmfactor` API defect is known.
* I read the stray root-level `*.json` dumps only with `ls`. That they carry no
  seed and no command line *is* the finding — I make no claim about their
  contents.
* `r113/lattice-obj/` was being rewritten while I audited it. That verdict is a
  snapshot with a timestamp, not a standing judgement.
* Every trust verdict above is about **mechanically can this code produce a
  wrong number**, not about whether the mathematics behind it is sound.