import Combinatorics.BerggrenCongruentDefs
import Combinatorics.BerggrenCongruentDescent
import Combinatorics.BerggrenCongruentElliptic
import Combinatorics.BerggrenCongruentFermat
import Combinatorics.BerggrenCongruentMain
import Combinatorics.BerggrenCongruentGrowth
import Combinatorics.BerggrenCongruentTwo
import Combinatorics.BerggrenCongruentGenocchi

/-!
# The Berggren tree's area function and the congruent number problem

Entry point for the development.  The pieces are:

| file | content |
|------|---------|
| `BerggrenCongruentDefs` | `IsCongruentNumber`, `euclidArea`, `triArea`, square-class invariance, `6 ∣ area` |
| `BerggrenCongruentDescent` | squarefree cancellation and descent from rational triangles to primitive triples |
| `BerggrenCongruentElliptic` | the correspondence with `y² = x³ − N²x` |
| `BerggrenCongruentFermat` | Fermat's right triangle theorem as a descent inside the tree |
| `BerggrenCongruentMain` | the main equivalences: congruent numbers = squarefree parts of node areas = curve points |
| `BerggrenCongruentGrowth` | branch growth, the Pell spine's silver law, properness, explicit witnesses |
| `BerggrenCongruentTwo` | `2` is not a congruent number |
| `BerggrenCongruentGenocchi` | primes `p ≡ 3 (mod 8)` are not congruent |

The headline statements are `BerggrenCongruent.congruent_iff_tree_node`,
`BerggrenCongruent.tree_node_iff_curve`, `BerggrenCongruent.one_not_congruentNumber`,
`BerggrenCongruent.two_not_congruentNumber` and
`BerggrenCongruent.prime_three_mod_eight_not_congruent`.
-/