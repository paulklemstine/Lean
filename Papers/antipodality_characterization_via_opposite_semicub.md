# Computational Evidence — Opposite-Semicube Helly Property & Antipodality

We model a partial cube concretely as a set `S ⊆ {0,1}^n` of hypercube
vertices, with Hamming distance. For a coordinate `i` and bit `b`, the
*semicube* is `S_i^b = {x ∈ S : x_i = b}`; the pair `(S_i^0, S_i^1)` are
*opposite semicubes*. The *antipode* of a vertex is the full bit-complement.
A set is *antipodal* iff it is closed under the antipode map.

## 1. Small cases

- `n = 2`, `S = Q_2 = {00,01,10,11}` (a 4-cycle). Antipodal: yes (complement
  of each vertex is present). Opposite semicubes in coordinate 0:
  `S_0^0 = {00,01}`, `S_0^1 = {10,11}` — each a single edge, isomorphic. ✓
- `n = 2`, path `P_3 = {00,01,11}`. Not antipodal: complement of `00` is `11` ✓
  but complement of `01` is `10 ∉ S`. Opposite semicubes in coord 0:
  `{00,01}` (2 vertices) vs `{11}` (1 vertex) — NOT isomorphic. Consistent
  with "antipodal ⇒ opposite semicubes isomorphic".
- `n = 3`, `Q_3` (the 3-cube). Antipodal; every opposite-semicube pair is a
  square `Q_2`, all isomorphic. ✓

## 2. Antipode realizes the cube diameter

For any `x`, `hdist x (antipode x) = n` (all `n` bits flip), and this is the
unique vertex at distance `n` from `x`. Hence in an antipodal set every vertex
has a *unique* farthest-possible partner, the hallmark of antipodality.

## 3. Helly number of semicubes

Semicubes are the "halfspaces" `{x_i = b}` of the cube. A finite family of such
constraints is globally satisfiable iff it is pairwise satisfiable: two
constraints conflict only when they fix the *same* coordinate to *different*
bits, a purely pairwise obstruction. So the semicubes of the hypercube have
**Helly number 2**. Checked exhaustively for `n ≤ 3` over all constraint
families: no pairwise-consistent family failed to have a common vertex.

## 4. Counterexample hunt (converse direction)

Equal-size or even isomorphic opposite semicubes do NOT force antipodality
without the Helly hypothesis on `S` itself; this is why the full biconditional
is stated over Helly partial cubes. Recorded as a future direction rather than
a proved theorem here.
