# Computational evidence for the trace-set filter experiments

All numbers below were produced by brute-force `#eval` computations in Lean 4
(no external tooling).  The definitions used are

```lean
def tset (N m : ℕ) : List ℕ :=
  ((List.range m).filter (fun t => (List.range m).any (fun x =>
     Nat.gcd x m = 1 && (x * x + N) % m == (t * x) % m))).eraseDups
def tcard (N m : ℕ) : ℕ := (tset N m).length
def chi  (N m : ℕ) : Int := if (N ^ ((m-1)/2)) % m == 1 then 1 else -1
```

i.e. `tset N m` enumerates `T_m(N) = { x + N·x⁻¹ mod m : gcd(x,m) = 1 }` by
scanning every residue, and `chi` is the Euler-criterion Legendre symbol.

## 1. Small-case calculation: `N = 3233 = 61 · 53`

| `m`  | 3 | 5 | 7 | 11 | 13 | 17 | 19 | 23 |
|------|---|---|---|----|----|----|----|----|
| `|T_m|` | 1 | 2 | 3 | 5 | 7 | 8 | 9 | 12 |
| `(m+χ(N))/2` | 1 | 2 | 3 | 5 | 7 | 8 | 9 | 12 |

The true trace `61 + 53 = 114` lies in `T_m(3233)` for **every** modulus in that
list (`[true, true, true, true, true, true, true, true]`).

Two of these entries are re-verified by the Lean *kernel* (`by decide`) in
`Catalog/Applications/TraceSetFilter.lean`:
`card_traceSet_3233_mod_13 : |T_13| = 7`, `card_traceSet_3233_mod_17 : |T_17| = 8`,
`true_trace_3233_mod_13 : 114 ∈ T_13`.

## 2. Exactness census (zero false negatives)

For all `1369` semiprimes `p·q` with `p, q` prime in `[100, 300)` and all
moduli `m ∈ {3,5,…,71}` (19 primes) the check

```
(p*q) % m ≠ 0  →  (p+q) % m ∈ tset (p*q) m
```

evaluates to `true`.  The same check over the larger sample `p, q ∈ [100, 400)`
(2809 semiprimes) also returns `true`.  This is the numerical face of
`TraceSetFilter.add_mem_traceSet`: **the filter never rejects the truth**.

## 3. The exact `2·|T| = m + χ(N)` law

For all `1369` semiprimes above and all 19 moduli,

```
N % m ≠ 0  →  2 * tcard N m = m + chi N m
```

evaluates to `true`.  This is the numerical face of
`TraceSetFilter.two_mul_card_traceSet_legendre`, and it explains why the
measured pruning factor is *slightly* off the idealised `2^{-ω}`.

## 4. Mean pruning density: `2^{-ω}` with `1/m` corrections

Averaging the density `∏_{m} |T_m|/m` over the 2809 semiprimes with
`p, q ∈ [100, 400)`:

| moduli | measured mean density | idealised `2^{-ω}` |
|--------|----------------------|---------------------|
| `{3,5,7}` (ω=3) | **0.125352** | 0.125 |
| `{3,5,7,11,13,17}` (ω=6) | **0.015732** | 0.015625 |

matching the reported experimental values `0.1233` (ω=3) and `0.0151` (ω=6) to
within sampling noise, and confirming that the filter prunes by *exactly*
`2^{-ω}` up to `O(1/m)` Legendre corrections — never better.

## 5. Window census and translation invariance

With `N = 3233` and moduli `{3,5,7}` (`M = 105`, `|T| = 1,2,3`):

| window | survivors | predicted `∏|T_i|` |
|--------|-----------|--------------------|
| `[0,105)` | 6 | 6 |
| `[500,605)` | 6 | 6 |
| `[1234,1339)` | 6 | 6 |

and with moduli `{3,5,7,11,13}` (`M = 15015`): `210` survivors in `[0, 15015)`,
matching `1·2·3·5·7 = 210`.  Two of these counts are kernel-verified
(`Census.census_window_zero`, `Census.census_window_shifted` in
`Catalog/Applications/TraceSetNoAmplification.lean`).

Finally, a hint window of width `8001` (the experimental `2E+1`) with the six
moduli `{3,5,7,11,13,17}` retains `54` candidates, versus the prediction
`8001 · (density 0.006582) ≈ 52.7`: the window is *narrower* than the primorial
`255255`, so the filter still leaves dozens of spurious candidates — no
isolation, exactly as `isolation_requires_primorial` demands.

## 6. Counterexample hunt

The universal claims tested were: (a) exactness, (b) `2|T| = m + χ(N)`, (c) the
CRT product law for window counts.  No counterexample was found in any of the
samples above; all three are now theorems with complete Lean proofs.  The one
claim that *is* refuted by the data is the amplification hypothesis itself: in
every census the survivor set in a full-period window has `∏|T_i| ≥ 2^ω > 1`
elements, so the true trace is never singled out.

## 7. OEIS

The sequence `|T_p(N)|` for fixed `N` is `(p + χ_p(N))/2`, i.e. a Legendre-symbol
shift of `(p ± 1)/2`; the underlying `(p-1)/2, (p+1)/2` sequences are the
standard quadratic-residue counts (A005097 and friends).  No new sequence
arises, which is itself part of the negative verdict: the filter carries only
the quadratic-character information already implied by the discriminant test.
