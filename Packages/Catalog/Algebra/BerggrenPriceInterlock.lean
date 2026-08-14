import Algebra.BerggrenPriceInterlock.Core
import Algebra.BerggrenPriceInterlock.Trees
import Algebra.BerggrenPriceInterlock.NNode
import Algebra.BerggrenPriceInterlock.Interlock
import Algebra.BerggrenPriceInterlock.Orthogonality
import Algebra.BerggrenPriceInterlock.RatioLaw
import Algebra.BerggrenPriceInterlock.Classification

/-!
# The Berggren–Price interlock

Umbrella module for the six-part development of the two trees of primitive Pythagorean
triples in Euclid parameters `(m,n)`:

* `Core` — abstract ternary descent: five hypotheses giving a unique root-to-node word.
* `Trees` — the Berggren (`det ±1`) and Price (`det ±2`) generators, their descent rules
  and the two tree theorems.
* `NNode` — the `N`-node identity: every odd coprime factorisation `N = pq` is the node
  `((p+q)/2,(q-p)/2)` of both trees, with odd leg exactly `N`.
* `Interlock` — determinant obstruction, leg-swap asymmetry, depth duality, and the
  level-width versus Fermat-scan comparison.
* `Orthogonality` — exactly two shared edges, Berggren depth against Fermat cost, and the
  mod-4 obstruction to the hypotenuse embedding.
* `RatioLaw` — `m ≤ (2d+3)n` and the trade-off `m ≤ 2·s·(2d+3)²`.
* `Classification` — the two structural constraints on any generator of such a tree.
-/