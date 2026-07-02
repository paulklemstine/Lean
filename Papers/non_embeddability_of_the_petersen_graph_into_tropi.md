# Computational Evidence

Support for the claim: *the Petersen graph does not isometrically embed into the
tropical (odd-valuation) Cayley graph of any abelian group*.

## 1. The source graph (Petersen = Kneser `K(5,2)`)

Direct enumeration over the two-element subsets of a five-element set:

| Quantity              | Computed value |
|-----------------------|----------------|
| vertices              | 10             |
| edges                 | 15             |
| regularity            | 3              |
| girth                 | 5 (odd)        |
| explicit odd walk     | pentagon, length 5 |

The pentagon `{0,1}–{2,3}–{4,0}–{1,2}–{3,4}–{0,1}` is a closed walk of length 5;
each consecutive pair is disjoint, so each step is an edge. Length 5 is odd, so
the graph is not bipartite. (Enumeration of vertices/edges checked by evaluation:
10 vertices, 15 edges.)

## 2. The tropical valuation certificate

For a valuation `v : A → ℤ` (a homomorphism into the value group of the min-plus
semiring) the connection set is `{a : v(a) odd}`.

* Symmetry: `v(-a) = -v(a)`, and `-v(a)` is odd iff `v(a)` is odd. ✔
* Looplessness: `v(0) = 0` is even, so `0` is not a generator. ✔
* Parity two-coloring: `x ↦ v(x) mod 2` sends every generator to `1`, hence
  differs across every edge. ✔

Small check on `ℤ^3` with the coordinate-sum valuation: the basis vector
`e₀ = (1,0,0)` has valuation `1` (computed), which is odd, so it is a genuine
generator and the host has edges — the theorem is not vacuous.

## 3. Counterexample hunt (odd cycles vs bipartite hosts)

Sampled small odd-valuation Cayley graphs:

* `A = ℤ`, `v = id`: generators = all odd integers; two-coloring by parity of the
  coordinate. Contains no odd closed walk (each step flips parity). Consistent
  with the theorem — no odd-girth graph can sit isometrically inside.
* `A = ℤ^k`, `v = coordinate sum`: the classical bipartite integer lattice;
  checkerboard two-coloring by coordinate-sum parity. Again bipartite.

No counterexample to bipartiteness of odd-valuation hosts was found, matching the
proved statement `tropicalCayley_colorable_two`.

## 4. Boundary observation (motivating FUTURE_DIRECTIONS)

If the valuation is *even* on all generators (e.g. `v = 2·(coordinate sum)`),
the parity certificate collapses (`v(x) mod 2 ≡ 0`), and the host can itself
carry odd closed walks. This is the exact regime where an isometric Petersen copy
is not excluded by the present argument — recorded as Conjecture 1.

## Scope note

The computations above are finite sanity checks (vertex/edge counts, a single
valuation value, small-group two-colorings). The universal non-embeddability
claim is established by proof, not by enumeration; the tables merely confirm the
inputs (odd girth, valid parity certificate, non-vacuous host) on small cases.
