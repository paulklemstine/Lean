# Future Directions — Arithmetic Concentration of Nodal Counts

## Synthesis

This cycle isolated the *deterministic skeleton* hiding underneath the probabilistic
"variance-deficit" conjecture for nodal edge counts of Hecke eigenfunctions on
Ramanujan graphs. Rather than assert an unproved asymptotic limit law, we formalized
the rigorous, finite, local-to-global core in `Core.lean`:

- **Spectral bridge** (`quadForm_eq_eigen`): the adjacency quadratic form
  `fᵀAf` of an eigenfunction equals `lam · ‖f‖²`. The signed edge sum
  `∑_{u~v} f(u)f(v)` *is* the eigenvalue (up to the norm). This is the exact local-to-global
  channel through which edge-local sign data becomes a global spectral invariant.
- **Sign obstructions** (`exists_nodal_of_neg_eigen`, `nodalCount_pos_of_neg_eigen`,
  `exists_concordant_of_pos_eigen`): the *sign* of the eigenvalue is a cohomology-flavored
  obstruction — a negative eigenvalue forces at least one nodal edge, a positive one forces
  a concordant edge. Local sign agreement cannot glue globally against the spectrum.
- **Random-wave mean** (`nodal_density_half`): under the vertex sign-flip ensemble,
  exactly half of the `2^|V|` configurations make a fixed (nonzero) edge nodal. This is the
  rigorous benchmark against which any "deficit" must be measured, proved by an explicit
  sign-flip involution.
- **Hecke-symmetry rigidity** (`nodal_aut_invariant`): a graph automorphism fixing the
  eigenfunction permutes the nodal edges. This is the discrete fingerprint of automorphic
  symmetry acting on nodal geometry — the deterministic seed of the conjectured variance
  deficit.

## Results Summary

Four theorems (plus two corollaries), all sorry-free, axioms limited to
`propext`, `Classical.choice`, `Quot.sound`. The development is degree-agnostic and works
for any finite graph with real vertex functions; the Ramanujan/arithmetic hypotheses enter
only through the automorphism rigidity statement.

## Bold, Falsifiable Directions

### 1. Exact second moment of the sign-flip ensemble nodal count
Prove a closed formula for the *variance* of `nodalCount` over the full
`twist`-ensemble: `Var = (1/4)|E_*| + (covariance over adjacent edge pairs)`, where
`E_*` is the set of edges with both endpoints nonzero, and the covariance term is a sum
over paths of length two. **The key insight is** that distinct edges sharing no vertex give
*independent* sign indicators (so contribute zero covariance), so the entire variance is
carried by the "cherries" (paths `u–w–v`), reducing a global second moment to a purely local
degree-sequence statistic. **Why now?** `nodal_density_half` already supplies the first
moment via an involution; the same `Function.update` two-vertex-flip argument extends
mechanically to pairs of edges, so the variance is within immediate reach and is the precise
quantity the parent conjecture claims is "deficient."

### 2. Eigenvalue-quantitative nodal lower bound
Strengthen the qualitative obstruction `exists_nodal_of_neg_eigen` to a quantitative count:
on a `d`-regular graph, `nodalCount(f) ≥ (some explicit increasing function of) (lam + d)`
when normalized. **The key insight is** that the *full* signed edge sum `lam·‖f‖²`, not just
its sign, is available from `quadForm_eq_eigen`, and bounding `∑ over nodal edges |f(u)f(v)|`
below by a Cauchy–Schwarz/AM–GM estimate against `‖f‖²` converts the scalar spectral gap
directly into an edge count. **Why now?** The spectral bridge is already proved; only a
clean inequality between the quadratic form and the nodal contribution remains, and Mathlib's
`inner_mul_le_norm_mul_norm` machinery is directly applicable.

### 3. Orbit-counting variance deficit under a fixed-point-free automorphism
Prove that if `σ` is a fixed-point-free automorphism with `f ∘ σ = f` and no fixed edges,
then `nodalCount(f)` is *even*, and more generally divisible by the order of `σ` acting on
edges. **The key insight is** that `nodal_aut_invariant` makes the nodal-edge set a union of
free `⟨σ⟩`-orbits, so its cardinality inherits the orbit-size divisibility — a hard
*parity/divisibility constraint* that mechanically shrinks the support of the count's
distribution, i.e. a literal, provable "variance deficit." **Why now?** The invariance lemma
is in hand; turning it into a quotient-by-group-action cardinality statement is a direct
application of Mathlib's `MulAction` orbit-partition API (`Finset.card` of orbits).

### 4. Cheeger-type localization: nodal edges concentrate on the boundary of sign domains
Define the sign domains `{v : f v > 0}` and `{v : f v < 0}` and prove that every nodal edge
crosses between them, hence `nodalCount = ` (edge boundary of the positive domain), so
`nodalCount ≥ h(G)·min(|V₊|,|V₋|)` where `h(G)` is the edge-expansion (Cheeger) constant.
**The key insight is** that the nodal set is *exactly* the cut induced by the sign partition,
turning a spectral/analytic question into graph expansion — and Ramanujan graphs have
near-optimal expansion, which is precisely the arithmetic input that should pin the count.
**Why now?** This is the cleanest cross-domain bridge to the expander material
(`Algebra.ClassicalGroupExpanders`, `Algebra.ExpanderWalk.Amplification`) already in the
catalog, and reframes the conjecture in expansion language where strong tools exist.

### 5. Sheaf-cohomological reformulation of the sign obstruction
Model the sign datum as a `ℤ/2`-valued presheaf on the graph (a section assigns a sign to
each nonzero vertex) and prove that the nodal edge count equals the number of edges where the
gluing of local sections fails, i.e. a `Č^1` cocycle weight; show the spectral obstruction
forces this class to be nonzero when `lam < 0`. **The key insight is** that nodal edges are
literally the first Čech obstruction to globally orienting the eigenfunction's sign, so
"negative eigenvalue ⇒ nonzero `H^1`" is a genuine local-to-global cohomology statement
generalizing `exists_nodal_of_neg_eigen`. **Why now?** The obstruction theorem is already
proved at the element level; lifting it to `ZMod 2` graph cohomology connects this work to
the catalog's sheaf/persistence machinery (`Applications.BoltzmannBridge`,
`Applications.PoincareData`) and matches the engine's local-to-global mandate.
