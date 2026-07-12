# Computational Evidence — RB-shaped finite posets

The Jung–Tix criterion states: a finite poset is RB-shaped iff it has a least
element **and** its undirected Hasse graph is a tree. Below we check the two
conjuncts are genuinely independent and that our reformulation
(`least element + #edges = n − 1`) is correct on small cases.

## Small posets (vertices `n`, Hasse edges `e`)

| Poset | Hasse edges | least element? | connected? | tree? | RB-shape? |
|-------|-------------|----------------|------------|-------|-----------|
| 1 point | 0 | yes | yes | yes (`e=0=n−1`) | **yes** |
| 2-chain `0<1` | 1 | yes | yes | yes (`e=1=n−1`) | **yes** |
| 2-antichain | 0 | no | no | no | no |
| "V": `b<a`, `b<c` | 2 | yes (`b`) | yes | yes (`e=2=n−1`) | **yes** |
| "Λ": `a<c`, `b<c` | 2 | **no** (a,b both minimal) | yes | yes (`e=2=n−1`) | **no** |
| diamond `⊥<a,b<⊤` | 4 | yes | yes | **no** (cycle, `e=4≠3`) | no |
| 3-chain `0<1<2` | 2 | yes | yes | yes (`e=2=n−1`) | **yes** |

## Independence of the two conditions

* **Λ** shows *tree Hasse graph* does **not** imply *least element*: `a` and `b`
  are both minimal, so no least element exists, yet the Hasse graph `a–c–b` is a
  path (a tree). Hence RB-shape genuinely needs both conjuncts.
* **2-antichain** shows *least element* is required for connectivity: no least
  element, Hasse graph has no edges and is disconnected.
* **diamond** shows *least element does not imply tree*: `⊥` is least and the
  graph is connected, but the four covering edges form a 4-cycle, so `e = 4`
  while `n − 1 = 3`; the Euler count fails and it is not a tree.

## Consistency with the formal reformulation

`rbShape_iff_hasLeast_and_edgeCount` asserts RB-shape ⇔ (least element ∧
`#edges + 1 = n`). Every row above is consistent: among posets with a least
element, RB-shape holds exactly when `e = n − 1` (1-point, 2-chain, V, 3-chain),
and fails for the diamond where `e = 4 > n − 1 = 3`. The diamond's failure and
the V/chain successes confirm that, *given* a least element, connectivity is
automatic and only the edge count distinguishes trees — exactly what the theorem
proves.

## Note on scope

These are hand computations on Hasse diagrams; they validate the combinatorial
criterion formalized in `RBDomainPosets.lean`. They do not touch the
probabilistic-powerdomain / RB-domain side of the Jung–Tix theorem, which is not
formalized here.
