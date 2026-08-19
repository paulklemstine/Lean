import Algebra.ScanSchemeDecoding.Triangle
import Algebra.ScanSchemeDecoding.Core
import Algebra.ScanSchemeDecoding.Optimum
import Algebra.ScanSchemeDecoding.Rigidity
import Algebra.ScanSchemeDecoding.Epsilon
import Algebra.ScanSchemeDecoding.Spectrum

/-!
# Scan schemes: honest uniqueness decoding and the exact `ε`-pigeonhole optimum

Umbrella import for the `ScanSchemeDecoding` development:

* `Algebra.ScanSchemeDecoding.Triangle` — triangular cost, integral tangent-line
  inequality, the exact optimum `triangleOpt N m` and the balanced profile attaining it.
* `Algebra.ScanSchemeDecoding.Core` — scan schemes, the intra-bucket index, honest
  uniqueness decoding (`ScanScheme.honest_scanCode`, `ScanScheme.decode_eq_some_iff`) and
  exact cost accounting (`ScanScheme.decodeCost_eq`).
* `Algebra.ScanSchemeDecoding.Optimum` — the optimum for schemes (`scan_optimum`), the
  residue scheme attaining it, and the pigeonhole failure analysis.
* `Algebra.ScanSchemeDecoding.Rigidity` — optimal schemes are exactly the balanced ones;
  perfect hashing; invariance of the cost under the symmetry group.
* `Algebra.ScanSchemeDecoding.Epsilon` — the `ε`-compression barrier `1/(2ε)`.
* `Algebra.ScanSchemeDecoding.Spectrum` — the exact maximum `triangle N` and the full
  cost spectrum.
-/