# Computational Evidence — Franke decomposition for level-one spherical forms

## 1. The pole structure of the standard Eisenstein series

For `SL(2, ℤ)` the constant term of the real-analytic Eisenstein series is

    E(s; z) has constant term  y^s + φ(s) · y^{1-s},
    φ(s) = √π · Γ(s - 1/2) · ζ(2s-1) / ( Γ(s) · ζ(2s) ).

Small-case tabulation of the *arithmetic factor* `ζ(2s-1)` near `s = 1` (so `u = 2s-1 → 1`),
using `ζ(u) ≈ 1/(u-1) + γ`:

| s      | u = 2s-1 | (s-1)·ζ(2s-1)  ≈ (u-1)/2 · (1/(u-1)+γ) |
|--------|----------|-----------------------------------------|
| 1.10   | 1.20     | 0.100·(5.577)  ≈ 0.558                   |
| 1.010  | 1.020    | 0.010·(50.58)  ≈ 0.506                   |
| 1.0010 | 1.0020   | 0.0010·(500.6) ≈ 0.5006                  |
| 1.0001 | 1.0002   | 0.0001·(5000.6)≈ 0.50006                 |

The product `(s-1)·ζ(2s-1)` clearly converges to `1/2` as `s → 1`, matching the proved value
of the residue. Meanwhile `ζ(2s-1)` itself diverges (`50.6, 500.6, 5000.6, …`), confirming the
genuine pole. This is the sole pole of `E(s; z)` in `Re(s) ≥ 1/2`: `Γ(s)` and `ζ(2s)` are finite
and nonzero at `s = 1` (`ζ(2) = π²/6 ≠ 0`), and `Γ(s-1/2)` is finite at `s = 1` (`Γ(1/2) = √π`).

## 2. Finiteness of the residual family

Because there is exactly one pole (order 1), the Laurent expansion at `s = 1` contributes exactly
one residual vector (the residue, a constant function on `X`), plus finitely many honest Laurent
coefficients if one truncates. So the "finite linear combination of Laurent coefficients" in the
Franke statement has, in this smallest case, a one-term residual part — a strong finiteness check
consistent with `franke_eisenstein_finiteDimensional`.

## 3. Level one → single (untwisted) series

The Dirichlet/Hecke characters of conductor `1` number `φ(1) = 1`: only the trivial character.
Hence no twisting is available at level one, and a single standard Eisenstein series governs the
whole Eisenstein spectrum. This is the finite computation behind `levelOne_unique_character`.

    #(characters mod 1) = φ(1) = 1.

## 4. Counterexample hunt

- Could `E(s; z)` have a *second* pole in `Re(s) ≥ 1/2`? A pole would require a zero of `ζ(2s)`
  with `Re(2s) ≥ 1`, i.e. `Re(2s) ≥ 1`; `ζ` has no zeros in `Re ≥ 1`, so no extra pole appears.
  No counterexample found — consistent with the one-dimensional residual claim.
- Could the residue vanish (making the Eisenstein term absorbable into cusp forms)? The tabulated
  limit `1/2 ≠ 0` rules this out, matching `eisenstein_arithmetic_factor_blows_up`.

All numerical evidence is consistent with the formalized theorems.
