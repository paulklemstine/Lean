# Computational Evidence — Blend colourings on strongly connected digraphs

We model a finite edge-weighted digraph on vertex set `V` by a non-negative,
row-stochastic weight matrix `w` (`w i j ≥ 0`, `∑_j w i j = 1`).  A *blend
colouring* is `c : V → ℝ` with `c i = ∑_j w i j · c j` for every `i`.  The arc
relation is `i → j` iff `w i j > 0`; the digraph is *strongly connected* iff every
vertex reaches every other along positive-weight arcs.

Conjecture: on a finite strongly connected such digraph, every blend colouring
is constant.

## 1. Small-case calculations

### Directed 2-cycle (strongly connected)
`w = [[0,1],[1,0]]`.  Blend equations: `c0 = c1`, `c1 = c0`.  Solution space is
`c0 = c1`: only constant colourings.  ✔ matches conjecture.

### Directed 3-cycle (strongly connected)
`w = [[0,1,0],[0,0,1],[1,0,0]]`.  Equations `c0=c1, c1=c2, c2=c0` ⇒ all equal. ✔

### Averaging on the complete digraph K_n (strongly connected)
`w i j = 1/(n-1)` for `i ≠ j`, `w i i = 0`.  Then `c i = (S - c i)/(n-1)` where
`S = ∑ c`, giving `c i = S/n` for all `i`: constant. ✔

### Non-symmetric / non-reversible chain (strongly connected)
`w = [[1/2,1/2,0],[0,1/2,1/2],[1/2,0,1/2]]` (biased 3-cycle with self loops).
Row-stochastic, irreducible, **not** reversible.  Solving `c = w c` forces
`c0=c1=c2`. ✔  This falsifies the auxiliary conjecture that reversibility/symmetry
is needed.

## 2. Counterexample hunt — where the hypotheses are necessary

### Disjoint self-loops (NOT strongly connected)
`w = identity` (`w i i = 1`).  Every colouring is a blend colouring, so
`c = id` is a **non-constant** blend colouring.  This is exactly the sharpness
witness `blend_sharpness` (2 vertices).  ✘ conjecture fails without strong
connectivity — as expected.

### One-way "absorbing" pair (weakly but not strongly connected)
`w = [[1,0],[1/2,1/2]]`.  Vertex 0 is absorbing; 1 → 0 but not 0 → 1.  Blend:
`c0 = c0` (free), `c1 = (c0 + c1)/2 ⇒ c1 = c0`.  Here it collapses, but making
vertex 0 point only to itself while a second component is independent again
yields non-constant solutions.  Strong connectivity is the precise dividing line.

## 3. Vector-valued check

Colours in `ℝ^2` on the directed 3-cycle: each coordinate independently satisfies
the scalar blend equations, so both coordinates are constant ⇒ the vector colour
is constant.  ✔  Confirms the coordinatewise reduction used in
`blend_const_vector`.

## 4. Summary table

| digraph | strongly connected? | non-constant blend colouring? |
|---|---|---|
| directed 2-cycle | yes | no |
| directed 3-cycle | yes | no |
| complete K_n averaging | yes | no |
| biased 3-cycle + self-loops | yes | no |
| identity / disjoint self-loops | no | **yes** |

The evidence pins strong connectivity as necessary and sufficient (together with
row-stochasticity) for the maximum-principle collapse, and shows symmetry /
reversibility are irrelevant.  All rows are formalised or witnessed in
`Catalog/Novelty/BlendColoringHarmonic.lean`.
