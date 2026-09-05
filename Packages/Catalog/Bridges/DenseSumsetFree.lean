/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Dense sets without large sumsets

Index file: imports the whole development.

* `Bridges.DenseSumsetFree.Basic` — definitions, Cauchy–Davenport, baseline bound
* `Bridges.DenseSumsetFree.Extraction` — greedy distinct-sums extraction
* `Bridges.DenseSumsetFree.Counting` — the first-moment counting argument
* `Bridges.DenseSumsetFree.TwoSummands` — the `(log n)³` theorem for two summands
  (reconstructed as the `t = 2` case of the general theorem; the original `Main`
  module is absent from the repository)
* `Bridges.DenseSumsetFree.Sharpness` — obstructions and a numerical instance
* `Bridges.DenseSumsetFree.MultiFold` — the `t`-fold corollary
* `Bridges.DenseSumsetFree.Triple` — the native three-fold `(log n)^{5/2}` theorem
* `Bridges.DenseSumsetFree.General` — the native `t`-summand theorem, threshold
  `(log n)^{(2t-1)/(t-1)}`
* `Bridges.DenseSumsetFree.Scales` — scale predicate and the open `log n` target
-/
import Bridges.DenseSumsetFree.Basic
import Bridges.DenseSumsetFree.Extraction
import Bridges.DenseSumsetFree.Counting
import Bridges.DenseSumsetFree.TwoSummands
import Bridges.DenseSumsetFree.Sharpness
import Bridges.DenseSumsetFree.MultiFold
import Bridges.DenseSumsetFree.Triple
import Bridges.DenseSumsetFree.General
import Bridges.DenseSumsetFree.Scales