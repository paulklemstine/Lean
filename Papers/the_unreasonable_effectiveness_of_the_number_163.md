# Computational Evidence — The Number 163 and the Heegner Numbers

## 1. The Euler prime run and its sharp length

The Euler polynomial `f_p(n) = n² + n + p` at `p = 41` (discriminant `1 − 4·41 = −163`)
produces primes for a record `n = 0, …, 39`:

| n | f_41(n) | prime? |
|---|---------|--------|
| 0 | 41 | ✓ |
| 1 | 43 | ✓ |
| 2 | 47 | ✓ |
| … | … | ✓ |
| 39 | 1601 | ✓ |
| **40** | **1681 = 41²** | **✗** |

The run stops sharply at `n = 40`, and this is not accidental: for **every** `p`,

    f_p(p − 1) = (p−1)² + (p−1) + p = p²,

so the run can never reach `n = p − 1`. The maximal possible run length is `p − 1`,
and `p = 41` attains it. (Formalised as `eulerPoly_pred` / `eulerPoly_pred_not_prime`.)

## 2. Classification of Euler "lucky" primes

Scanning `p = 2, …, 59` for the full-length property
(`f_p(n)` prime for all `0 ≤ n ≤ p − 2`) yields **exactly**:

    {2, 3, 5, 11, 17, 41}

Their discriminants `4p − 1` are:

    2 → 7,  3 → 11,  5 → 19,  11 → 43,  17 → 67,  41 → 163

which are **precisely** the prime Heegner numbers greater than `3`
(`7, 11, 19, 43, 67, 163`). This is the Rabinowitsch correspondence between
class-number-one imaginary quadratic fields and prime-generating polynomials.

## 3. Counterexample hunt / maximality window

We searched every `p` in `42 ≤ p ≤ 1000` for the full-length property and found
**none** — for each such `p` there is an explicit `n < p − 1` with `f_p(n)`
composite. Thus `41` is the largest Euler lucky prime below `1000`, the finite
computational shadow of the Stark–Heegner theorem (`163` is the largest Heegner
number). The unbounded statement requires transcendence / L-function methods and
is not elementary.

## 4. The modular "magic integers"

For the three largest Heegner numbers the singular modulus `j` is a perfect cube,
and `e^{π√d} ≈ (−j) + 744`:

| d | −j | (−j) + 744 = nearest integer | e^{π√d} error |
|---|----|------------------------------|----------------|
| 43 | 960³ = 884736000 | 884736744 | ≈ 2.2·10⁻⁴ |
| 67 | 5280³ = 147197952000 | 147197952744 | ≈ 1.3·10⁻⁶ |
| 163 | 640320³ = 262537412640768000 | 262537412640768744 | ≈ 7.5·10⁻¹³ |

The integer identities `640320³ + 744 = 262537412640768744`, etc., are exact and
are proved directly. The `744` is the constant term of the `q`-expansion of the
`j`-invariant; the cube reflects the `ζ₃` structure of the singular modulus.

## 5. OEIS pointers

* Heegner numbers `1, 2, 3, 7, 11, 19, 43, 67, 163` — OEIS A003173.
* Euler's lucky numbers `1, 2, 3, 5, 11, 17, 41` — OEIS A014556 (with `4p − 1`
  giving the prime Heegner numbers).
