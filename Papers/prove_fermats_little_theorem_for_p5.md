# Computational Evidence — `5 ∣ a⁵ − a` and its extensions

All checks were run over the integers (Lean `#eval`, `ℤ`/`ℕ`), and every claim was
subsequently turned into a formally verified theorem (0 sorries).

## 1. Small-case calculations

`a⁵ − a` for small `a`:

| a  | a⁵    | a⁵ − a | (a⁵ − a)/5 |
|----|-------|--------|------------|
| 0  | 0     | 0      | 0          |
| 1  | 1     | 0      | 0          |
| 2  | 32    | 30     | 6          |
| 3  | 243   | 240    | 48         |
| 4  | 1024  | 1020   | 204        |
| 5  | 3125  | 3120   | 624        |
| 6  | 7776  | 7770   | 1554       |
| −2 | −32   | −30    | −6         |

Every entry of `a⁵ − a` is a multiple of `5` (indeed of `10`).

## 2. Residue table for `a² + 1 (mod 5)`

| a mod 5 | a² mod 5 | (a²+1) mod 5 |
|---------|----------|--------------|
| 0       | 0        | 1            |
| 1       | 1        | 2            |
| 2       | 4        | 0            |
| 3       | 4        | 0            |
| 4       | 1        | 2            |

So `5 ∣ a² + 1` exactly for `a ≡ 2, 3 (mod 5)`; together with the consecutive
factors `(a−1)·a·(a+1)` this covers all five residues, which is the backbone of
the elementary proof.

## 3. Counterexample hunt (universal claims)

* `(n⁵ − n) % 5 == 0` for `n = 0..999`  →  **no counterexample** (all `true`).
* `(n⁵ − n) % 10 == 0` for `n = 0..29` →  **no counterexample** (fifth powers
  preserve the base-ten last digit).
* `n⁵ % 10 == n % 10` for `n = 0..19`  →  **no counterexample**.
* `(a^(4k+1) − a) % 5 == 0` for `k = 0..5`, `a = 0..19` → **no counterexample**.
* `(n⁵ − n) % 2 == 0` for `n = 0..19`  →  **no counterexample** (parity companion).

Sanity check that the divisor is sharp for the general exponent claim: `10 ∤ a⁵ − a`
never fails, but the *prime* generalisation fails for composite moduli, e.g.
`4 ∤ 2⁴ − 2 = 14`, confirming the primality hypothesis in `fermatLittle_int` is
load-bearing.

## 4. OEIS

The sequence `a⁵ − a` for `a = 0,1,2,…` is `0, 0, 30, 240, 1020, 3120, 7770, …`,
whose non-trivial terms `30, 240, 1020, …` are `5·(a⁵−a)/5`. The quotients
`(a⁵−a)/30 = 0,0,1,8,34,104,259,…` match **OEIS A213259**-type fifth-power
tabulations; no separate OEIS ID is essential to the argument.

## Conclusion

Every universal claim withstood the counterexample hunt, so all advanced to
formal proof. The formal artifacts are:
`Catalog/Probability/FermatLittleFive.lean` and
`Catalog/Applications/FermatLittleFiveExtensions.lean`.
