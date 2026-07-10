# Computational Evidence: Alexander Polynomials in the OAM Spectrum

All numbers below are reproduced inside the Lean file
`Catalog/MachineLearning/KnottedLightAlexander.lean` as machine-checked theorems;
this note only records the exploratory arithmetic that motivated them.

## 1. Alexander polynomials of small knots

| Knot            | Δ_K(t)                    | deg | Δ(1) | Δ(−1) (= determinant) |
|-----------------|---------------------------|-----|------|------------------------|
| unknot 0₁       | 1                         | 0   | 1    | 1                      |
| trefoil 3₁      | t² − t + 1                | 2   | 1    | 3                      |
| figure-eight 4₁ | t² − 3t + 1               | 2   | −1   | 5                      |
| cinquefoil 5₁   | t⁴ − t³ + t² − t + 1      | 4   | 1    | 5                      |

The determinants 3, 5, 5 are all odd — a general feature of `Δ(−1)` for knots.

## 2. Roots and the OAM (root-of-unity) test

The claim under study: the "OAM spectrum" is `{l : Δ_K(exp(2πi·l/N)) = 0}`.

* **Trefoil.**  `t² − t + 1` is the 6th cyclotomic polynomial `Φ₆`.
  Its roots are the primitive 6th roots of unity `exp(±iπ/3) = exp(2πi·{1,5}/6)`.
  Check via the factorization `t³ + 1 = (t+1)(t²−t+1)`: at `z = exp(2πi/6)` we have
  `z³ = exp(πi) = −1` and `z ≠ −1`, so `z² − z + 1 = 0`.
  Hence the trefoil beam is quantized at `l = 1, 5 (mod 6)` and *not* at `l = 0`
  (there `Δ(1) = 1 ≠ 0`).

* **Cinquefoil.**  `t⁴ − t³ + t² − t + 1` is `Φ₁₀`.
  Its roots are the primitive 10th roots of unity.  Via
  `t⁵ + 1 = (t+1)(t⁴−t³+t²−t+1)`: at `z = exp(2πi/10)`, `z⁵ = −1`, `z ≠ −1`,
  so `Δ(z) = 0`.  Quantized at `l = 1 (mod 10)`.

* **Unknot.**  `Δ = 1` never vanishes ⇒ empty spectrum (no quantized OAM).

* **Figure-eight.**  `t² − 3t + 1` has roots `(3 ± √5)/2`.  Numerically
  `(3+√5)/2 ≈ 2.618` and `(3−√5)/2 ≈ 0.382`; their product is `1`.
  Crucially these equal `φ²` and `ψ²` where `φ = (1+√5)/2` is the golden ratio
  and `ψ = (1−√5)/2` its conjugate (both satisfy `x² = x + 1`):
  `x² − 3x + 1 = (x²)... ` reduces, at `x = φ²`, to `φ² − φ − 1 = 0` = `gold_sq`.
  Since `|φ²| ≈ 2.618 ≠ 1`, the figure-eight roots lie **off** the unit circle,
  so the figure-eight beam has **no** root-of-unity OAM quantization.

## 3. Counterexample hunt / caveat

The physics description states "N is the crossing number," but the trefoil (crossing
number 3) yields the *sixth* roots of unity, not the third — consistent with `N = 6`,
i.e. twice the number of Alexander roots on the circle, or with using the cyclotomic
index rather than the crossing number.  We therefore state the OAM membership results
with an explicit modular period `N` (6 for the trefoil, 10 for the cinquefoil) rather
than committing to "N = crossing number," which does not hold literally.

The genuinely robust mathematical content — proved in Lean — is:

* trefoil `Δ = Φ₆`, cinquefoil `Δ = Φ₁₀`: roots are roots of unity (on the circle);
* figure-eight roots are golden-ratio squares (off the circle);
* determinants 3, 5, 5 (all odd);
* reciprocity `t^deg Δ(1/t) = Δ(t)` for the trefoil and cinquefoil.

No counterexample to these was found; the figure-eight "off the circle" fact is itself
the natural boundary of the naive conjecture.

## 4. OEIS

The sixth/tenth roots-of-unity and cyclotomic connection are standard; no new integer
sequence arises. Knot determinants 3, 5, 5 are individual invariants, not a sequence.
