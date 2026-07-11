# Computational Evidence — finiteness of bounded representations

## 1. Small-case calculations (rank one, cyclic sources)

For a cyclic source `C_m = Multiplicative (ZMod m)` and a finite field `F_q`,
a character `C_m → F_q^×` is determined by the image of the generator, which
must be an element of `F_q^×` of order dividing `m`. The number of such
characters is `gcd(m, q-1)`:

| source `C_m` | field `F_q` | `q-1` | `#{characters}` = `gcd(m, q-1)` |
|--------------|-------------|-------|--------------------------------|
| `C_2`        | `F_5`       | 4     | 2                              |
| `C_3`        | `F_5`       | 4     | 1                              |
| `C_4`        | `F_5`       | 4     | 4                              |
| `C_6`        | `F_7`       | 6     | 6                              |
| `C_5`        | `F_7`       | 6     | 1                              |

Every entry is finite, matching `characters_finite_of_finite_field`.

## 2. Boundary check (infinite target)

For `C_∞ = Multiplicative ℤ` and target `M`, characters correspond bijectively
to elements of `M` (image of the generator). Sampling:

| target `M`            | `#{homs}`          |
|-----------------------|--------------------|
| `F_5^×` (order 4)     | 4  (finite)        |
| `Multiplicative ℤ`    | ∞  (infinite)      |
| `ℂ^×`                 | ∞  (infinite)      |

The infinite rows are exactly the situations excluded by the bounded-image
hypothesis, and are witnessed formally by `unbounded_reps_infinite`.

## 3. Counterexample hunt

We tested whether finite generation of the source *alone* suffices for
finiteness. It does not: `Multiplicative ℤ` is finitely generated, yet it has a
continuum of homomorphisms into `ℂ^×` and infinitely many into
`Multiplicative ℤ` itself. This confirms that the finite-image hypothesis is
load-bearing rather than cosmetic — the divisor `D` cannot be dropped.

## 4. Structural table (why the engine works)

| ingredient                     | supplies                          |
|--------------------------------|-----------------------------------|
| discreteness of `F`            | each representation has finite image |
| bounded ramification (`D`)     | finitely many *possible* finite images |
| finite generation of `π₁`      | each map is finite data           |
| semisimplicity + conjugacy     | quotient of a finite type is finite |

Each row is realized by a named lemma in the accompanying development, and the
product of the four is the finiteness conjecture.
