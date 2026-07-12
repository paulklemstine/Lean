# Computational Evidence

Concise numerical evidence for the harmonic-balance theory developed in
`OppositeSemicubeHellyDeepening.lean`. All observations below are also captured as
fully proved statements in that file; the numbers here are the small-case sanity
checks that motivated them.

## 1. The full hypercube is balanced

For coordinate set of size `m` the full cube has `2^m` vertices, and each
coordinate's two semicubes each have `2^(m-1)` vertices.

| m | vertices | semicube (true) | semicube (false) | balanced? |
|---|----------|-----------------|------------------|-----------|
| 1 | 2        | 1               | 1                | yes       |
| 2 | 4        | 2               | 2                | yes       |
| 3 | 8        | 4               | 4                | yes       |

This is the concrete witness behind `harmonicEven_univ` and shows the property is
non-vacuous.

## 2. Parity obstruction

A single vertex `{v}` on a nonempty coordinate set has, at any coordinate, one
semicube of size `1` and the opposite of size `0` — maximally unbalanced. More
generally a balanced cube splits as `|V| = 2·|semicube|`, so `|V|` is even.

| set             | card | even? | harmonic-even? |
|-----------------|------|-------|----------------|
| `{v}`           | 1    | no    | no             |
| full cube (m=1) | 2    | yes   | yes            |
| full cube (m=2) | 4    | yes   | yes            |

This matches `harmonicEven_even_card` and `not_harmonicEven_singleton`.

## 3. Product cardinalities

For a family product on the disjoint union of coordinate sets, the `⟨k,i⟩`-semicube
has size `|Semicube (V_k) i c| · ∏_{j≠k} |V_j|`. Example with two Boolean factors
`P` on 1 coordinate (`|P|=2`, semicubes `1,1`) and `R` on 1 coordinate (`|R|=2`):
the product has `4` vertices, and each cut yields semicubes of size
`1·2 = 2` on both sides — balanced, consistent with both factors being balanced.

Cancelling the positive factor `∏_{j≠k}|V_j|` recovers balance of the single factor
`V_k`; this is the cancellation step behind `harmonicEven_piCube` and
`oppositeSemicubeHelly_piCube`.

## 4. Counterexample hunt

Testing "product balanced ⇒ factors balanced" requires nonempty factors: if some
`V_j` is empty then the product is empty (vacuously balanced) while another factor
may be unbalanced. This is exactly why the nonemptiness hypothesis is present and
load-bearing in the family-product theorems. No counterexample survives once every
factor is required nonempty.
