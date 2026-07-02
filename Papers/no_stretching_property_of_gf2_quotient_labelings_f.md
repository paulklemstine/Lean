# Computational Evidence — Quotient Labelings and the No-Stretch Property

All claims below are reflected by fully proved statements in
`CycleParityQuotientNoStretch.lean`; this note records the small-case reasoning that
guided the formalization.

## 1. Small-case calculation: the triangle `K₃`

Partition the three edges of `K₃` into three singleton classes, so `t = 3`. The only
cycle is the triangle itself; its class-parity vector is `(1,1,1)`, so the cycle-class
parity space is `C = ⟨(1,1,1)⟩` with `rank(A) = 1`. The quotient dimension is
`t − rank(A) = 3 − 1 = 2`.

Choosing coset representatives, the class generators in `(Z/2Z)²` become

| class | generator |
|-------|-----------|
| 0     | (1,0)     |
| 1     | (0,1)     |
| 2     | (1,1)     |

and the quotient labeling of the vertices is

| vertex | label |
|--------|-------|
| 0      | (0,0) |
| 1      | (1,0) |
| 2      | (1,1) |

Every edge realizes its class generator as a label difference:
`lab 0 − lab 1 = (1,0) = gen 0`, `lab 1 − lab 2 = (0,1) = gen 1`,
`lab 0 − lab 2 = (1,1) = gen 2`. (Verified: `tri_edge_gen`.)

## 2. Counterexample hunt: coordinate hypercube vs. Cayley graph

For the pair `(0, 2)`:

* Graph distance in `K₃`: `d_G(0,2) = 1` (they are adjacent). (Verified: `tri_graph_dist`.)
* Cayley distance on the class generators: `lab 0` and `lab 2` differ by `gen 2`, hence are
  adjacent, so `d_Cayley = 1 ≤ 1`. No stretch. (Verified: `tri_cayley_adj`,
  `tri_cayley_no_stretch`.)
* Coordinate-hypercube (Hamming) distance: `hammingDist((0,0),(1,1)) = 2 > 1`. A stretch.
  (Verified: `tri_hamming_stretches`.)

**Conclusion of the hunt.** The universal no-stretch claim is *true* for the Cayley target
and *false* for the coordinate-hypercube target. The triangle is the minimal witness: any
graph whose class-parity cycle space is trivial (forests, and more generally partial cubes
under the Djokovic–Winkler partition) shows no such stretch, so a counterexample must
contain a cycle with nonzero class parity, and `K₃` is the smallest such graph.

## 3. Dimension check across sizes

For the `n`-cycle `C_n` with singleton edge classes (`t = n`), the single independent cycle
gives `rank(A) = 1` when `n` is odd (parity vector `(1,…,1) ≠ 0`) and the quotient has
dimension `n − 1`; the same rank–nullity identity `dim(quotient) = t − rank(A)` is proved
in general as `quotient_finrank`, so no per-`n` computation is needed beyond confirming the
rank of the parity space.

## 4. Why no OEIS entry is invoked

The objects here are structural (graphs, GF(2) subspaces, Cayley graphs) rather than a
single integer sequence, so no OEIS lookup was decisive. The relevant catalog anchors are
the Djokovic–Winkler relation, partial cubes, isometric embeddings, Cayley graphs of
abelian groups, and GF(2) linear algebra, all of which enter the proofs directly.
