# Future Directions — Percolation Thresholds

## Synthesis

This cycle separated the *probabilistic input* of percolation theory from its
*algebraic conclusion*. We formalized the percolation order parameter `θ(p)`
abstractly (monotone, non-negative) and proved the defining dichotomy of the
critical probability `p_c = sSup {p | θ(p) = 0}`: `θ` vanishes strictly below `p_c`
and is strictly positive strictly above it (`theta_eq_zero_of_lt_pc`,
`theta_pos_of_gt_pc`). On top of this we isolated the two mechanisms that pin down
exactly solvable thresholds:

* **Self-duality.** The duality involution `p ↦ 1 - p` has the unique fixed point
  `1/2` (`dual_fixedPoint_iff`). Hence any threshold satisfying the self-duality
  relation `p_c = 1 - p_c` equals `1/2` (`selfDual_pc_eq_half`,
  `square_bond_pc_eq_half`, `triangular_site_pc_eq_half`).
* **Crossing symmetry.** A crossing function obeying `C(p) + C(1-p) = 1` satisfies
  `C(1/2) = 1/2` (`crossing_at_half`), and if it is strictly monotone then `1/2` is
  the *unique* self-dual crossing point (`crossing_half_unique`) — the rigorous
  combinatorial shadow of Cardy's conformally invariant crossing formula.

These extend the finite-graph foundations in `Algebra.Percolation`
(`siteConnected_increasing`, `hasHorizontalCrossing_increasing`) from the level of
increasing events to the phase transition itself, and `Physics.PercolationCrossing`
bookends the transition with deterministic endpoints: no crossing when all sites are
closed, a guaranteed crossing when all are open.

## Results Summary

| Theorem | Statement |
|---|---|
| `theta_eq_zero_of_lt_pc` | subcritical phase below `p_c` |
| `theta_pos_of_gt_pc` | supercritical phase above `p_c` |
| `selfDual_pc_eq_half` | self-dual threshold `= 1/2` |
| `crossing_at_half` / `crossing_half_unique` | self-dual crossing `= 1/2`, uniquely |
| `allClosed_no_crossing` / `allOpen_crossing` | deterministic endpoints `θ(0)=0`, `θ(1)=1` |

## Research Directions

### 1. Verify self-duality from first principles for the square bond lattice
Right now `square_bond_pc_eq_half` *assumes* the relation `p_c = 1 - p_c`. The grand
challenge is to discharge that hypothesis by formalizing planar bond duality on the
finite torus: the open primal crossings and closed dual crossings are complementary,
so the crossing probabilities satisfy `P_p(horizontal open) + P_{1-p}(vertical open) = 1`,
and a Russo–Seymour–Welsh box-crossing estimate upgrades this to equality of thresholds.
**The key insight is** that self-duality is not an analytic accident but a combinatorial
identity between a graph and its planar dual that already lives inside the finite-grid
`gridGraph` we use. **Why now?** Mathlib now has `SimpleGraph.Walk`, planar-style
adjacency, and the increasing-event machinery proved here, so the only missing piece is
the dual-graph construction — a self-contained combinatorial target.

### 2. A monotone coupling theorem to *derive* `OrderParameter.mono`
We axiomatize monotonicity of `θ`. The bold conjecture is to prove it: for any finite
increasing event `A`, the function `p ↦ P_p(A)` (sum over configurations of
`p^{open}(1-p)^{closed}`) is monotone non-decreasing, via Harris' coupling.
**The key insight is** that monotonicity is a polynomial-positivity statement —
the derivative `d/dp P_p(A)` is a non-negative sum of "pivotal" terms (Russo's formula) —
so it reduces to a finite combinatorial inequality, not measure theory. **Why now?**
The increasing-event predicates (`siteConnected_increasing`) are already formalized;
turning them into a probability via a `Finset.sum` over `SiteConfig` is the natural next file.

### 3. Square *site* percolation: prove rigorous non-trivial bounds, not a closed form
The square site threshold (`≈ 0.5927`) is *not* self-dual, so our `1/2` machinery is
silent — consistent with the absence of any known closed form. The falsifiable target is
to prove explicit two-sided bounds `0 < p_c^{site} < 1`, e.g. `p_c ≥ 1/(Δ-1)` via a
branching/Peierls argument on the grid's degree `Δ = 4`. **The key insight is** that the
*absence* of self-duality is itself a theorem: the square site lattice is not isomorphic to
its matching lattice, which is exactly why the elementary value is unavailable. **Why now?**
Our `allOpen_crossing`/`allClosed_no_crossing` endpoints already establish non-degeneracy;
a counting bound on self-avoiding paths in `gridGraph` is the next provable rung.

### 4. Triangular-lattice site percolation and the star–triangle relation
`triangular_site_pc_eq_half` currently borrows the self-matching hypothesis. The deep
conjecture is to formalize the triangular lattice, prove it is self-matching, and connect
the star–triangle (Yang–Baxter) transformation to the invariance of `p_c`.
**The key insight is** that the triangular site threshold equals `1/2` because every face
is a triangle whose three sites cannot be split into two separating monochromatic arcs —
a purely local majority statement. **Why now?** The finite-grid scaffolding generalizes
directly to a triangular adjacency, and the local nature of the argument makes it tractable
without the full RSW theory.

### 5. From crossing symmetry to a Cardy-type scaling limit invariant
We proved `C(1/2) = 1/2` and uniqueness under strict monotonicity. The speculative grand
challenge is to formalize a discrete conformal invariant — Smirnov's pre-holomorphic
fermionic observable on the triangular lattice — and prove it is *discretely harmonic*,
the first rigorous step toward Cardy's formula. **The key insight is** that conformal
invariance enters as a *symmetry of the crossing function* (`C(p)+C(1-p)=1` plus aspect-ratio
covariance), so the scaling limit is forced before any continuum analysis. **Why now?**
With the self-dual crossing value already pinned to `1/2`, the discrete observable is the
unique natural object whose boundary values are fixed by exactly these symmetries.
