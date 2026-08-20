# Computational evidence

Setting.  For a finitely supported `a : ℕ → ℤ` put `b m = ∑_{k ∣ m} a k` and

```
F_a(q) = ∏_{m ≥ 1} (1 - q^m)^{-b m}  =  ∑_{n ≥ 0} C(n) q^n .
```

If `∑ k · a k = 24` then `η_a = ∏_k η(kτ)^{a k} = q · ∏_m (1-q^m)^{b m}`, so
`q/η_a = F_a` and, in the Hauptmodul indexing `1/η_a = q^{-1} + c(0) + c(1) q + c(2) q² + ⋯`,

```
c(0) = C(1),   c(1) = C(2),   c(2) = C(3).
```

The conjectured (and now proved) closed forms are

```
C(1) = a₁
C(2) = a₁(a₁+3)/2 + a₂                                  (headCoeff)
C(3) = a₁(a₁+1)(a₁+2)/6 + a₁(a₁+a₂) + a₁ + a₃           (secondCoeff)
```

## 1. Direct expansion of the infinite product (truncated at degree 6)

A brute-force power-series evaluator (convolution on coefficient lists, with
`(1-q^m)^{-b}` expanded as a `b`-fold product of `1 + q^m + q^{2m} + ⋯`) gives:

| exponent vector `a` (nonzero entries) | weight `∑ k a k` | `C(0..6)` |
|---|---|---|
| `a₁ = 24`   (`Δ = η^24`)      | 24 | `1, 24, 324, 3200, 25650, 176256, 1073720` |
| `a₂ = 12`   (`η(2τ)^12`)      | 24 | `1, 0, 12, 0, 90, 0, 520` |
| `a₁ = 2, a₂ = 11`             | 24 | `1, 2, 16, 32, 152, 300, 1088` |
| `a₁ = -1, a₂ = 2, a₃ = 7`     | 24 | `1, -1, 1, 5, -4, 3, 26` |

Checks against the closed forms:

* `a₁ = 24`: `headCoeff = 24·27/2 = 324` ✓ and `secondCoeff = 24·25·26/6 + 24·24 + 24 = 2600 + 576 + 24 = 3200` ✓.
  The row is the classical expansion `1/Δ = q⁻¹ + 24 + 324 q + 3200 q² + 25650 q³ + ⋯`
  (coefficients of `1/Δ`, OEIS **A006922**: 1, 24, 324, 3200, 25650, 176256, …).
* `a₂ = 12`: `headCoeff = 0 + 12 = 12` ✓, `secondCoeff = 0 + 0 + 0 + 0 = 0` ✓ (odd coefficients vanish, as they must for a series in `q²`).
* `a₁ = 2, a₂ = 11`: `headCoeff = 2·5/2 + 11 = 16` ✓, `secondCoeff = 2·3·4/6 + 2·13 + 2 + 0 = 4 + 26 + 2 = 32` ✓.
* `a₁ = -1, a₂ = 2, a₃ = 7` (a genuinely mixed-sign quotient): `headCoeff = (-1)(2)/2 + 2 = 1` ✓,
  `secondCoeff = (-1)(0)(1)/6 + (-1)(1) + (-1) + 7 = 5` ✓.

In all four cases `C(1) = a₁` as well.

## 2. Counterexample hunt

* Sign changes: the mixed-sign example above (`a₁ = -1`) confirms the formulas are
  not an artefact of positivity; the `zpow` step of the jet calculus is proved for all
  `n : ℤ` by two-sided integer induction, not only for `n ≥ 0`.
* Truncation: computing `F_a` truncated at `m ≤ N` for `N = 2,3,…,7` leaves the
  coefficients of `q⁰,q¹,q²` unchanged from `N = 2` on and `q³` unchanged from `N = 3`
  on, matching `coeff_two_etaQuotientProd_stable` / `coeff_three_etaQuotientProd_stable`.
* Divisor regrouping: the two products `∏_k (∏_n (1-q^{kn}))^{a k}` and
  `∏_m (1-q^m)^{b m}` were compared term by term for the vectors above and agree in
  every computed degree (proved here in degrees ≤ 2, `eta_regrouping_jet`).

## 3. Head coefficient statistics

`headCoeff` restricted to *pure* exponent vectors (`a₂ = 0`), i.e. `n ↦ n(n+3)/2`:

```
n      : -6  -5  -4  -3  -2  -1   0   1   2   3   4   5   6
n(n+3)/2:  9   5   2   0  -1  -1   0   2   5   9  14  20  27
```

Two features visible in the table and proved in `EtaQuotientHeadStructure.lean`:
the values are bounded below by `-1` (`pure_headCoeff_ge_neg_one`), and the table is
symmetric under `n ↦ -3-n` (`pure_headCoeff_eq_iff`).  The attained set
`{…, -1, 0, 2, 5, 9, 14, 20, 27, …}` is exactly `{c : 8c+9 is a square}`
(`pure_headCoeff_iff_sq`); e.g. `c = 1` is missing because `17` is not a square.
Allowing `a₂ ≠ 0` fills every integer (`headCoeff_surjective`).

---

## 4. The all-degrees recursion (second research cycle)

The logarithmic-derivative identity `X·F' = F·logD F` gives

```
c(0) = 1,      n·c(n) = Σ_{i<n} c(i)·σ_b(n−i),      σ_b(j) = Σ_{m|j, m≤N} m·b(m).
```

For `1/Δ` (`a = 24·δ₁`, so `b m = 24` for all `m ≥ 1`, `σ_b(j) = 24·σ(j)`) an
independent `#eval` implementation of this recursion produces

```
n :   0   1    2     3      4       5        6         7          8
c :   1  24  324  3200  25650  176256  1073720  5930496  30178575

n :        9          10           11             12
c : 143184000  639249300  2705114880  10914317934
```

which is **OEIS A006922** (`1/Δ` coefficients, "number of ways of writing n as a sum
of 24 triangular-like parts"), matching the first terms `1, 24, 324, 3200, 25650,
176256` already produced in §1 by direct power-series multiplication.  Two independent
computational routes therefore agree, and the Lean theorems
`coeff_two_via_recursion` / `coeff_two_delta_via_recursion` agree with both.

### 4.1 Positivity

Every value above is `≥ 1`.  This is proved in general in
`EtaQuotientPositivity.lean` (`one_le_coeff_of_bCoeff_pos`, `coeff_delta_pos`), by
strong induction on the recursion: all `σ_b(j) ≥ b(1) ≥ 1`, so `n·c(n)` is a sum of
`n` terms each `≥ 1`.

### 4.2 Congruence hunt: `c(n) mod 24`

```
n              : 0  1   2  3   4  5  6  7   8  9  10 11 12
gcd(n,24)      : -  1   2  3   4  1  6  1   8  3   2  1 12
c(n) mod 24    : 1  0  12  8  18  0  8  0  15  0  12  0  6
```

Every `n ≥ 1` with `gcd(n,24) = 1` (namely `n = 1,5,7,11`) has `24 ∣ c(n)`, and the
converse fails only in the harmless direction (`n = 9` also happens to give `0`).
The values `12, 8, 18, 15, 6` at `n = 2,3,4,8,12` show the coprimality hypothesis is
necessary.  Both facts are formalised: `coeff_delta_dvd_of_coprime` and
`coeff_two_delta_not_dvd_24`.

## 5. Independence audit of the two derivations of `c(1)`

A transitive dependency scan of the compiled environment was run over the constants
used by each proof.  Result:

```
EtaHead.coeff_two_via_recursion    -> jet-related dependencies: []   (none)
EtaHead.coeff_two_etaQuotientProd  -> jet-related dependencies: 18
   (Jet, Jet.one, Jet.mul, Jet.inv, Jet.zpow, jet_oneSubXPow_one/two/ge_three,
    jet_etaQuotientProd, …)
```

So the two proofs of `c(1) = a₁(a₁+3)/2 + a₂` share **no** proof machinery beyond the
definitions `etaQuotientProd`, `bCoeff`, `headCoeff` and elementary facts about
`1 - X^m`.  They constitute a genuine double check of the head-coefficient formula.
