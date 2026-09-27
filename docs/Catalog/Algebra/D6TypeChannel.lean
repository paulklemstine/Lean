/-
# DEGREE-6-NONABELIAN: the `D₆` type channel of `x⁶ - 2` (paper 122)

Umbrella module.  Verdict: **THE-FRAMEWORK-HOLDS-FOR-D₆**, now with exact values.

* `Algebra.D6TypeChannel.Group` — `D₆` acting on the six roots, the fixed-point law
  of `D_n` for even `n`, the `D₆` type distribution `{0 : 8, 2 : 3, 6 : 1}/12`,
  the rotation character (`p mod 3`) and the abelianisation map (`p mod 24`);
* `Algebra.D6TypeChannel.RootCount` — for primes: `T(p) ∈ {0, 6}` if
  `p ≡ 1 (mod 3)`, `T(p) = 2·[p ≡ ±1 (mod 8)]` if `p ≡ 2 (mod 3)`, and the full
  conductor-`24` picture;
* `Algebra.D6TypeChannel.Refinement` — refinement monotonicity of the counting
  conditional entropy and the abelian ceiling for arbitrary finite groups;
* `Algebra.D6TypeChannel.Channel` — `H(T) = (3/4) log₂ 3`,
  `I(p mod 3 ; T) = log₂3/4 + (5/12) log₂5 - 1`, `I(D₆^ab ; T) = log₂3/2 + 1/6`,
  the abelian ceiling and the non-abelian residue `log₂3/4 - 1/6`;
* `Algebra.D6TypeChannel.Pair` — the semiprime pair channel
  `(3/8) log₂3 + (35/72) log₂5 + (17/72) log₂17 - 23/9 ≈ 0.1326`;
* `Algebra.D6TypeChannel.Prediction` — information versus Bayes error: `p mod 3`
  carries `0.36` bits but gives no predictive gain; every abelian dial errs on
  `≥ 1/12`, attained by `p mod 24`.
-/
import Algebra.D6TypeChannel.Group
import Algebra.D6TypeChannel.RootCount
import Algebra.D6TypeChannel.Refinement
import Algebra.D6TypeChannel.Channel
import Algebra.D6TypeChannel.Pair
import Algebra.D6TypeChannel.Prediction