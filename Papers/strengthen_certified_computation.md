# Computational evidence

All numbers below were produced with `#eval` inside this Lean project (compiled,
*untrusted* execution).  They were used only to size fuel budgets and to choose
which certificates to attempt; every claim that ends up as a theorem is proved
by kernel reduction (`decide` / `decide +kernel`) plus a soundness lemma, never
by `#eval` and never by `native_decide`.

## 1. Small cases: the accelerated Collatz map

`T n = n/2` for even `n`, `(3n+1)/2` for odd `n`.  Number of `T`-steps needed to
reach `1`, for `n = 1..20` (this is the window the supplied evidence checks):

| n | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 |
|---|---|---|---|---|---|---|---|---|---|----|----|----|----|----|----|----|----|----|----|----|
| steps | 0 | 1 | 5 | 2 | 4 | 6 | 11 | 3 | 13 | 5 | 10 | 7 | 7 | 12 | 12 | 4 | 9 | 14 | 14 | 6 |

This is the halving-step count of the `3x+1` problem (the sequence commonly
indexed as OEIS **A006666**; the identification was made from memory, as no
OEIS lookup was possible in this environment, and nothing in the formal
development depends on it).

## 2. Sizing the certificates

Over `n ∈ [2, 131072]`:

| quantity                                        | mean   | max |
|-------------------------------------------------|--------|-----|
| `T`-steps to reach `1`                           | 73.74  | 223 |
| `T`-steps to fall **below the starting point**   | 3.48   | 135 |
| inputs with `n ≡ 3 (mod 4)`                      | 32768 = exactly `1/4` of the window |

Two design decisions follow, and both became theorems:

* the **drop-below** test costs ~21× less per input than running the orbit to
  `1` (3.48 vs 73.74 steps on average) — formalised as `dropsBelow`, proved
  sound (`dropsBelow_sound`) and relatively complete (`dropsBelowAux_complete`);
* only the residue class `3 mod 4` needs testing — formalised as `sieve_mod4`,
  and identified in `ScaleSieve` as the scale-2 member of a family of sieves.

Fuel `400` safely exceeds the observed maximum `135`; had it not, the kernel
`decide` would simply have failed, so no trust is placed in this measurement.

## 3. Kernel timings (what actually limits certification)

| certificate                                 | window       | kernel time | outcome |
|----------------------------------------------|--------------|-------------|---------|
| `collatzChecker` (orbit to 1), linear scan    | `[1,1000]`   | ≈ 28 s      | proved (`evidence_1000`) |
| `sievedChecker` (mod 4), linear scan          | `[1,4000]`   | ≈ 45 s      | proved (`sieved_evidence_4000`) |
| `sievedDrop`, linear scan                     | `[1,20000]`  | —           | **stack overflow** |
| `sievedDrop`, balanced (`checkPow2`, `d=17`)  | `[1,131072]` | ≈ 130 s     | proved (`fast_evidence`) |

The overflow row is the interesting datum: past ≈ 2·10⁴ inputs the limiting
resource is not time but the *shape* of the evaluation, since `checkFrom`
recurses linearly.  `checkPow2` evaluates the identical Boolean value at stack
depth `d = log₂(window)`, which is why `[1,131072]` goes through.
`checkPow2_eq_checkFrom` proves the two agree, so the speed-up costs nothing in
trust.

## 4. Counterexample hunt

* `#eval` on the sieved drop-below checker finds **no** failure for
  `n ≤ 10^6`; consistent with the literature, no Collatz counterexample was
  found.  This is not asserted as a theorem: only the kernel-checked window
  `[1,131072]` is.
* The counterexample hunt that *did* succeed is the logical one: for every
  bound `B` the predicate `truncate (collatzChecker fuel) B` reproduces the
  entire certificate on `[1,B]` and is false at `B+1`
  (`collatz_evidence_is_not_a_proof`).  Finite evidence has an explicit,
  constructible impostor at every scale.
* For the numerical-semigroup example the hunt is exhaustive and decisive: the
  non-representable inputs of `⟨3,5⟩` are exactly `{1,2,4,7}` (`mcnugget_gaps`),
  so the certified base window `[8,10]` is sharp.
