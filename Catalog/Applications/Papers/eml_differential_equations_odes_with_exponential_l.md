# Computational Evidence — EML Differential Equations cycle

This cycle adds order-reduction and Riccati-gauge infrastructure for second-order
EML ODEs. The new results are *algebraic identities in an arbitrary differential
field*, so the relevant evidence is symbolic verification of the identities on the
canonical analytic realization (functions of a real variable, derivation = `d/dx`,
exp/log the genuine transcendentals). Each identity below was checked by hand on a
concrete worked example; all are then proved in full generality in the Lean files.

## 1. Normal-form reduction `y = z·u` removes the `y′` term

Test ODE: `y″ − 2x·y′ + (something)·y = 0`, gauge `z` with `2z′ + p·z = 0`,
`p = −2x` ⇒ `z′ = x·z` ⇒ `z = exp(x²/2)`.

Substitution identity (`reduction_identity`):
`(z·u)″ + p·(z·u)′ + q·(z·u) = z·u″ + (z″ + p·z′ + q·z)·u`.

Check with `z = exp(x²/2)`, `p = −2x`:
- `z′ = x z`, `z″ = (1 + x²) z`.
- `z″ + p z′ = (1+x²)z − 2x·(x z) = (1 − x²) z`.
  So the coefficient of `u` is `(1 − x² + q) z`, independent of `u′` — the `u′`
  term has cancelled, as the identity asserts. ✓

Explicit coefficient (`normalForm_coeff_explicit`, division-free `×4` form):
`4(z″ + p z′ + q z) = z(4q − p² − 2p′)`.
With `p = −2x`: `p² = 4x²`, `p′ = −2`, so `4q − p² − 2p′ = 4q − 4x² + 4`.
RHS `= z(4q − 4x² + 4) = 4z(q − x² + 1)`, matching `4·(1 − x² + q)z`. ✓
(Classical normal-form coefficient `r = q − p²/4 − p′/2 = q − x² + 1`.)

## 2. d'Alembert reduction of order

Test: `y″ = y` (`a = 1`), known solution `y₁ = exp x`.
Second solution `y₂ = y₁·w` with `y₁²·w′` constant: `y₁² = exp(2x)`, pick
`y₁²·w′ = −2` (constant) ⇒ `w′ = −2 exp(−2x)` ⇒ `w = exp(−2x)` ⇒
`y₂ = exp x · exp(−2x) = exp(−x)`.
Indeed `y₂″ = exp(−x) = y₂`. ✓ (`reduction_of_order`).

Wronskian (`reduction_wronskian`): `W(y₁, y₂) = y₁²·w′ = −2`, a nonzero constant,
so `y₁, y₂` are independent over the constants (`reduction_linIndep`). ✓
(Boundary: if instead `y₁²·w′ = 0` then `w` is constant and `y₂ = c·y₁` is
dependent — `W = 0`.)

## 3. Riccati gauge (completing the square)

Full Riccati of `y″ + p y′ + q y = 0` via `v = y′/y`:
`v′ + v² + p v + q = 0` (`riccati_full_of_second_order`).

Gauge `ṽ = v + g`, `2g = p`: `(v+g)′ + (v+g)² = g′ + g² − q`
(`riccati_gauge`). Worked check `p = −2x` (`g = −x`), `q` arbitrary:
- `g′ = −1`, `g² = x²`, so RHS `= −1 + x² − q`.
- Equivalently the normal-form coefficient is `r = −(g′ + g² − q) = q − x² + 1`,
  matching §1. The two gauges (linear-side `y = z·u` and Riccati-side `ṽ = v + p/2`)
  land on the *same* `r`. ✓

## 4. Sanity counterexample hunt

- Normal-form criterion requires `z ≠ 0`: with `z = 0` the substitution `y = z·u`
  is identically `0`, so the iff is vacuous/false — hypothesis is load-bearing.
- `galois_action_is_mul_constant` requires both solutions nonzero: with `y₂ = 0`
  the "constant" `c = y₂/y₁ = 0` is not in `Gₘ`, so `y₂ ≠ 0` is necessary.
- `reduction_linIndep` requires `y₁²·w′ ≠ 0`: dropping it allows `w` constant, giving
  a dependent pair. No counterexample to any stated theorem was found.

## Notes

No integer/OEIS sequence arises (the content is symbolic differential algebra rather
than enumerative). The decisive evidence is that every identity, verified above on
canonical exp/log examples, is proved in Lean over an *arbitrary* differential field
with only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).
