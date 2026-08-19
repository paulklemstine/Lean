# Computational evidence for the pole-order obstruction (cycles 3–7)

All formal claims in `Catalog/Cryptography/PoleOrder*.lean` are proved in Lean 4 with
0 `sorry`s; the table below is *exploratory* evidence gathered before formalization, to
choose the right statements and to catch false conjectures early.  Statements that were
subsequently proved in Lean are marked **[proved]**; the numerical tables themselves were
computed with truncated Laurent arithmetic and are *not* a substitute for the proofs, with
one exception noted below which is itself a Lean theorem.

## 1. Small-case Laurent products of normalized series

Factors are the moonshine-normalized shapes `T = q⁻¹ + a₁q + a₂q² + a₃q³`, with genuine
McKay–Thompson data

```
T_1A = J = q⁻¹ + 196884 q + 21493760 q² + 864299970 q³ + ⋯
T_2A     = q⁻¹ +   4372 q +    96256 q² +   1240002 q³ + ⋯
T_3A     = q⁻¹ +    783 q +     8672 q² +     65367 q³ + ⋯
T_4A     = q⁻¹ +    276 q +     2048 q² +     11202 q³ + ⋯
```

Truncated products of the first `m` of them (exact in the displayed degrees):

| m | order | coeff at −m | coeff at 1−m | coeff at 2−m | Σ a₁ | coeff at 3−m | Σ a₂ |
|---|-------|-------------|--------------|--------------|------|--------------|------|
| 1 | −1 | 1 | 0 | 196884 | 196884 | 21493760 | 21493760 |
| 2 | −2 | 1 | 0 | 201256 | 201256 | 21590016 | 21590016 |
| 3 | −3 | 1 | 0 | 202039 | 202039 | 21598688 | 21598688 |
| 4 | −4 | 1 | 0 | 202315 | 202315 | 21600736 | 21600736 |

One degree further, where the factors first interact:

| m | coeff at 4−m | Σ a₃ + e₂(a₁) |
|---|--------------|----------------|
| 2 | 1726316820 | 1726316820 |
| 3 | 1883965635 | 1883965635 |
| 4 | 1939739601 | 1939739601 |

Observations, each of which became a theorem:

* order is exactly `−m` and the leading coefficient is `1` (cycle 1) **[proved]**;
* the coefficient at `1 − m` is `Σᵢ aᵢ(0) = 0` under the moonshine normalization
  (cycle 1) **[proved]**;
* the coefficient at `2 − m` equals `Σᵢ a₁(i)` when all constant terms vanish
  (cycle 2) **[proved]**;
* the coefficient at `3 − m` equals `Σᵢ a₂(i)` — with *no* elementary-symmetric
  correction, because the vanishing linear coefficients of `q·Tᵢ` block every cross
  term.  This is the new cycle-6 identity
  `PoleOrderThirdOrder.coeff_prod_normalized_third` **[proved]**, and the `m = 3` entry
  `21598688 = 21493760 + 96256 + 8672` is verified inside Lean as
  `PoleOrderThirdOrder.coeff_zero_prod_J_T2A_T3A`, together with
  `202039 = 196884 + 4372 + 783` at degree `−1`.

* the coefficient at `4 − m` equals `Σᵢ aᵢ(3) + e₂(a(1))`, the second elementary symmetric
  function of the *linear* coefficients reappearing because `q·Tᵢ = 1 + aᵢ(1)q² + ⋯` first
  interact in degree `4`.  This is the cycle-8 identity
  `PoleOrderFourthOrder.coeff_prod_normalized_fourth` **[proved]**, with the `m = 3` entry
  `1883965635` verified in Lean as `PoleOrderFourthOrder.coeff_one_prod_J_T2A_T3A`.

A first, buggy version of the exploration truncated intermediate products too aggressively
and reported `5155` instead of `202039` at `m = 3`; the discrepancy with the (already
proved) cycle-2 identity is what exposed the bug.  This is a good illustration of the
policy of trusting the Lean proof over the script.

## 2. Counterexample hunt

* *Could the pole cancel for special coefficient choices?*  No: the leading coefficient of
  the product is a product of `1`s, so no choice of the `aᵢ(n)` can lower the pole order.
  Formalized as `orderTop_prod_normalized` (cycle 1) and re-derived group-theoretically in
  cycle 3.
* *Could a power `u^n` of a pole-carrying unit become a power series?*  Tested numerically
  for small `n` on the `m = 2, 3` products: order scales as `n · (−m)`, never `0`.
  Formalized as `PoleOrderValuation.pow_mem_range_psUnitHom_iff` (torsion-freeness).
* *Could multiplying by a non-monomial unit power series remove the pole?*  Tested with
  random unit power series truncations: order unchanged.  Formalized as
  `PoleOrderSplitting.poleLeak_mul_psUnitHom` and, in the converse direction, as
  `poleLeak_mul_eq_iff`, which shows the stabilizer of the leak is *exactly* `ℂ⟦X⟧ˣ`.
* *Could adding something hide the pole?*  Only by adding something with an equally large
  pole: additive masking by anything of order `> −m` leaves the order at `−m`
  (`PoleOrderRobustness.poleOrder_add_stable`).

## 3. OEIS

The coefficient sequences appearing here are the classical moonshine ones
(`196884, 21493760, 864299970, …` for `J`), which are standard and were used only as input
data.  The derived diagonal sequences `Σᵢ a₁(i)` and `Σᵢ a₂(i)` over the first `m`
McKay–Thompson classes depend on an arbitrary ordering of the classes and were not
searched for in OEIS; no claim of novelty is made about them.

## 4. Scope

The evidence above is deliberately small: the theorems are structural (valuation theory,
group splittings, convolution identities) and hold for arbitrary coefficient data, so the
numerical checks serve only to fix the correct shape of the identities.
