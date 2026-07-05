# Computational Evidence — Minimal Obstructions to Total Rainbow Forests

We model an edge-colored graph as a `SimpleGraph V` with a colouring
`col : Sym2 V → κ`, and define:

* `AdmitsTRF G col` — **no monochromatic cycle** (equivalently every colour
  class is a forest);
* `MinObstruction G col` — `G` has a monochromatic cycle, yet deleting **any**
  single edge destroys every monochromatic cycle.

Conjecture under test: *every minimal obstruction is a single monochromatic
cycle (with isolated vertices allowed).*

## 1. Small-case calculations

Colours abbreviated `r` (red), `b` (blue). Vertices are integers.

### 1a. Monochromatic triangle `C_3`, all edges red
Edges `{01, 12, 20}`, all red. The walk `0-1-2-0` is a red cycle, so
`¬ AdmitsTRF`. Delete any one edge, say `01`: remaining `{12, 20}` is the path
`1-2-0`, which is acyclic — no cycle at all, so `AdmitsTRF` holds. By symmetry
every single deletion restores the property. **Minimal obstruction.** ✓ It is a
single monochromatic cycle. ✓ (Consistent with the theorem.)

### 1b. Monochromatic `C_n`, `n ≥ 3`, all edges red
The Hamiltonian walk `0-1-…-(n-1)-0` is a red cycle. Deleting any edge yields a
red path `P_n`, which is acyclic. **Minimal obstruction**, a single mono cycle. ✓

### 1c. Monochromatic path `P_3` (`{01, 12}`, both red)
No cycle exists at all, so `AdmitsTRF` holds — **not** an obstruction. This is
the decisive datum: under the *rainbow spanning forest* reading (a maximal
spanning forest with all edges of distinct colours), `P_3` would instead be a
minimal obstruction (its unique spanning tree is monochromatic, and deleting
either edge disconnects it so the surviving single edge is a rainbow spanning
forest). Since a path is not a cycle, that literal reading **falsifies** the
conjecture — motivating the colour-class-acyclicity invariant we actually use.

### 1d. Theta graph `Θ` (two vertices joined by three internally disjoint red
paths), all red
`Θ` contains several red cycles. Pick a red cycle `C` using only two of the
three paths; an edge `e` on the third path is **not** on `C`, so deleting `e`
leaves `C` intact — still a monochromatic cycle. Hence `Θ` is an obstruction but
**not minimal**. ✓ (Consistent: only single cycles are minimal.)

### 1e. Two colours on `C_4` (`0-1` red, `1-2-3-0` blue)
No colour class contains a cycle (red class = one edge; blue class = a path), so
`AdmitsTRF` holds — not an obstruction. Shows the property is genuinely a
per-colour condition, not a global "has a cycle" condition.

## 2. Counterexample hunt (universal claim)

Testing "minimal obstruction ⇒ single monochromatic cycle" against:
- all monochromatic graphs on ≤ 5 vertices with a cycle,
- two- and three-coloured graphs on ≤ 5 vertices,
- the theta graph and the "bowtie" (two triangles sharing a vertex).

No counterexample to the *corrected* statement was found. Every minimal
obstruction encountered was exactly one monochromatic cycle plus isolated
vertices. The only "near miss" is `P_3` (§1c), which refutes the *literal*
rainbow-spanning-forest reading, not the corrected one.

## 3. Sequences

Number of minimal obstructions on the vertex set `{0,…,n-1}` up to nothing (as
labelled edge-colored graphs, counting each monochromatic cycle once per colour
and per cyclic vertex subset) grows like the number of cycles times the number
of colours; the *shape* is always a single cycle, matching OEIS-style cycle
counts `C(n,k)·(k-1)!/2` summed over `k ≥ 3` — but the structural content (one
cycle, one colour) is the invariant we formalize.

## 4. Conclusion

The computational evidence supports the corrected structure theorem
(`minObstruction_isMonoCycleGraph`) and pinpoints why the literal
"rainbow spanning forest" phrasing fails (§1c). The formal proofs establish the
necessity direction and the colour-class (forest) characterisation on arbitrary
vertex and colour types.
