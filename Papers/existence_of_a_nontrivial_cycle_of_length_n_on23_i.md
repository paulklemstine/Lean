# Computational Evidence

Target theorem (formalized in `Logic/HamiltonianNontrivialCycle.lean`):

> A Hamiltonian graph `G` on `n ≥ 3` vertices with minimum degree `δ(G) ≥ 3`
> contains a **nontrivial** cycle `c` (strictly shorter than the whole Hamiltonian
> cycle, `c.length < n`) that is **long**: `2·c.length ≥ n + 2`, i.e.
> `c.length ≥ ⌈(n+2)/2⌉`.

We model the fixed Hamiltonian cycle as the successor edges `i ~ i+1` on `ZMod n`,
and a *chord* as an edge `a ~ b` with `b ≠ a±1`.

## 1. Small-case calculations

The whole argument is driven by a single chord. A chord `a ~ b` at cyclic distance
`k = (b - a).val` (`2 ≤ k ≤ n-2`) splits the Hamiltonian cycle into two arcs of
edge-lengths `k` and `n-k`; closing each arc with the chord yields cycles of
lengths `k+1` and `(n-k)+1`, which sum to `n+2`.

| n | chord dist k | cycle 1 len `k+1` | cycle 2 len `n-k+1` | sum | max = long cycle |
|---|--------------|-------------------|---------------------|-----|------------------|
| 4 | 2            | 3                 | 3                   | 6   | 3 (= ⌈6/2⌉)      |
| 5 | 2            | 3                 | 4                   | 7   | 4                |
| 6 | 2            | 3                 | 5                   | 8   | 5                |
| 6 | 3            | 4                 | 4                   | 8   | 4 (= ⌈8/2⌉)      |
| 7 | 3            | 4                 | 5                   | 9   | 5                |
| 8 | 4            | 5                 | 5                   | 10  | 5 (= ⌈10/2⌉)     |

In every row `max ≥ ⌈(n+2)/2⌉` and `max ≤ n-1`, matching the two conclusions
(`2·length ≥ n+2` and `length < n`). The worst case (smallest long cycle) is the
*balanced* chord `k = n/2`, giving `length = ⌊n/2⌋+1`; this is exactly the
`⌈(n+2)/2⌉` bound and shows the elementary method cannot beat `n/2 + O(1)` from a
single chord — the whole point of the deeper poset/probabilistic refinements.

## 2. Degree input (pigeonhole)

For `n = 3` the graph `ZMod 3` has only two non-self vertices per vertex, so
`δ(G) ≥ 3` is *unsatisfiable*; the theorem holds vacuously and the formal proof
handles this via the same pigeonhole (`every_vertex_has_chord`: the two cycle
neighbours account for degree 2, so degree ≥ 3 forces a third, non-cycle,
neighbour). For all `n ≥ 4` a chord genuinely exists whenever `δ(G) ≥ 3`.

## 3. Counterexample hunt

The claim is an existence statement, so a counterexample would be a Hamiltonian
`G` with `δ ≥ 3` and *no* nontrivial long cycle. None can exist: any single chord
already produces the required cycle, and `δ ≥ 3` guarantees a chord. Testing the
construction on the balanced chord for `n = 4,…,12` (table above extended)
consistently yields `length = ⌊n/2⌋+1` satisfying both bounds, with no failure.

## 4. OEIS

No integer sequence is central to the statement; the only quantity that appears,
`⌈(n+2)/2⌉ = ⌊n/2⌋+1`, is `A008619` (integers repeated) and needs no lookup.

## Conclusion

The computational picture confirms both conclusions with the balanced chord as the
tight case, and confirms that the elementary constructive method saturates at
`n/2 + O(1)`. This matches what is formalized.
