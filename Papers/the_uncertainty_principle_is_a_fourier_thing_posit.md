# Computational Evidence

The theorems in `Core.lean` are qualitative statements from complex analysis, so the
relevant "computation" is checking the *shape* of the zero sets of concrete transforms
and confirming the mechanism (isolated zeros → null zero set → infinite-measure support).

## 1. Zeros of the archetypal transforms

The Fourier transform of the box `𝟙_{[-1,1]}(x)` is the sinc function

  `F(ξ) = ∫_{-1}^{1} e^{-iξx} dx = 2·sin(ξ)/ξ`,

which extends to an **entire** function of `ξ`.  Its numerator `sin` has zeros exactly at
`ξ = nπ`:

| n            | -3     | -2     | -1     | 0 | 1     | 2     | 3     |
|--------------|--------|--------|--------|---|-------|-------|-------|
| zero `nπ`    | -9.42  | -6.28  | -3.14  | 0 | 3.14  | 6.28  | 9.42  |

These are **isolated** points — the gap between consecutive zeros is exactly `π ≈ 3.14`.
A set of isolated points in `ℂ` is countable, hence has 2-D Lebesgue measure `0`.  This is
precisely `sin_zeroSet_measure_zero`.  So the box's transform vanishes only on a null set;
it is *not* supported on a finite-measure set.  (Formalized: `sin_support_measure_top`.)

## 2. The Gaussian equality case

`f(x) = e^{-x²}` has Fourier transform `√π · e^{-ξ²/4}`, again a Gaussian.  The complex
extension `z ↦ e^{-z²}` is entire and **never** zero (`exp` is nowhere zero).  Hence its
zero set is empty and its support is *all* of `ℂ` (`gaussian_support_eq_univ`).  Neither
the signal nor its transform has small support — the extremal, minimum-uncertainty case.

## 3. Counterexample hunt

The universal claim under test is:

  *A nonzero entire function cannot vanish on a set of positive measure / have
  finite-measure support.*

Attempted counterexamples, all of which fail (as they must):

* `sin`, `cos`, `exp`, any nonzero polynomial: zero sets are discrete/finite → measure 0. ✔
* `exp(-z²)`: zero set empty. ✔
* A hypothetical entire function equal to `0` on a disk: ruled out by the identity theorem
  (`eqOn_zero_of_vanishes_on_open`) — vanishing on any nonempty open set forces `f ≡ 0`. ✔

No counterexample exists: the phenomenon is a theorem, not a coincidence.  The single
mechanism (principle of isolated zeros) drives every case, which is exactly why the
uncertainty principle is transform-agnostic — it holds for the Fourier transform (`U = ℂ`),
the Laplace transform (`U =` right half-plane), and the Mellin transform (`U =` strip)
via the same lemma `eqOn_zero_of_vanishes_on_open`.

## 4. Numerical sanity of the "gap ⇒ measure 0" heuristic

For `sin`, the number of zeros in `[-R, R]` is `≈ 2R/π`, growing *linearly* in `R`, while a
positive-measure subset of `ℝ` would contain `≈ c·R` worth of *length*.  Discrete linear
growth vs. positive length is the quantitative reason the zero set is null — consistent
with the formal proof going through countability.
