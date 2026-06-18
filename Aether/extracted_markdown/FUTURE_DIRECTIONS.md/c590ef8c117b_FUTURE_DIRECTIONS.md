# Future Directions: The Boltzmann Bridge — Higher-Dimensional Persistence

The file `HigherPersistence.lean` lifts the catalog's 0-dimensional persistence
machinery (abstract simplicial complexes and the Vietoris–Rips construction from
`Catalog/Applications/PoincareData/SimplicialComplex.lean`) to a general
*filtration calculus*: any monotone weight on simplices generates a nested family
of complexes, the Vietoris–Rips filtration is recovered as the sublevel filtration
of the diameter weight (`vr_mem_iff_diam_le`), and the Euler characteristic of the
full simplex is pinned to `1` (`euler_char_full_simplex`). The following directions
push this backbone toward genuine higher-dimensional persistent homology and its
thermodynamic interpretation.

## 1. The f-vector / h-vector and the Euler–Poincaré bridge

The proven fact that the full simplex has Euler characteristic `1` is the simplest
instance of a far richer combinatorial invariant: the *f-vector* `(f₀, f₁, …)`
counting faces by dimension, and its alternating sum the Euler characteristic. A
natural next theorem is that the Euler characteristic is a *filtration invariant in
disguise* — for a sublevel filtration, the f-vector is a monotone step function of
the scale parameter, and its alternating sum jumps exactly at the weight values of
the simplices.

**The key insight is** that the alternating-sign cancellation proven in
`euler_char_full_simplex` (via `Int.alternating_sum_range_choose`) is not special
to the full simplex: it is the shadow of the boundary map `∂² = 0`, so the same
binomial identity computes the Euler characteristic of *any* shellable complex once
its f-vector is known. **Why now?** We already have the monotone weight framework
(`Filtration`, `sublevelComplex`) and a working alternating-binomial lemma in
Mathlib; combining them only requires defining the dimension-graded face count,
which is a `Finset.filter` over `sublevelFaces`.

## 2. Stability of the diameter filtration under metric perturbation

Persistent homology's headline theorem is *stability*: a small perturbation of the
input data produces a small change in the barcode. Our `diamWeight` is the exact
quantity whose sublevel sets define the bars. The conjecture: if two pseudometrics
`d, d'` satisfy `|d x y − d' x y| ≤ δ` for all vertices, then
`|diamWeight_d σ − diamWeight_{d'} σ| ≤ δ` for every simplex `σ`, hence the two VR
filtrations are interleaved at scale `δ`.

**The key insight is** that `diamWeight` is a `Finset.sup'`, and `sup'` is
1-Lipschitz in its argument function — so the global stability bound reduces to a
pointwise distance bound, exactly mirroring `sphere_detection_stable` in the
catalog's `SimplicialComplex.lean`. **Why now?** The catalog already proves
perturbation stability for sphere-membership; our `vr_mem_iff_diam_le` makes
`diamWeight` the canonical birth-time function, so the stability statement is now a
clean lemma about `Finset.sup'` rather than an ad hoc geometric estimate.

## 3. Boltzmann-weighted filtrations and the free-energy bridge

The "Boltzmann Bridge" name points at the thermodynamic reading: replace the
diameter weight by a *Boltzmann weight* `w_β(σ) = −β⁻¹ log Z(σ)` where `Z` is a
partition function over the simplex's configurations. The conjecture is that
`w_β` is again a monotone weight (a `Filtration`), so the entire sublevel calculus
applies, and that as the inverse temperature `β → ∞` the Boltzmann filtration
converges to the min-plus (tropical) diameter filtration.

**The key insight is** that monotonicity of `w_β` follows from the partition
function being *supermultiplicative under inclusion*, the same min-plus/`log Z`
correspondence already formalized in the catalog's tropical thermodynamics
(`Catalog/Physics/Bridge.lean`, `uniform_shannon_eq_tropical`). **Why now?** With
`Filtration` abstracting away the specific weight, we can instantiate it with the
log-partition function and immediately inherit `sublevelComplex` and
`sublevel_mono`, turning a thermodynamic limit into a statement about converging
filtration values.

## 4. Functoriality of sublevel complexes as a persistence module

A filtration is more than a nested family of sets — it is a *functor* from the
poset `(ℝ, ≤)` to simplicial complexes, and after applying homology, to vector
spaces (a persistence module). The next structural theorem: the assignment
`t ↦ sublevelComplex F t` is functorial, i.e. the inclusions
`sublevelFaces F t₁ ⊆ sublevelFaces F t₂` (already proven as `sublevel_mono`)
compose correctly and respect identities, packaging the filtration as a genuine
`(ℝ, ≤)`-indexed diagram.

**The key insight is** that `sublevel_mono` already supplies the morphisms; what
remains is purely formal — recording that subset-inclusions form a thin category,
so functoriality is automatic and the persistence module is the post-composition
with the (yet to be formalized) homology functor. **Why now?** Mathlib's
`CategoryTheory` library has the poset-as-category and functor infrastructure, and
our `sublevel_mono` is exactly the data of the morphism map; the bridge to
persistence modules is therefore one definitional step away.

## 5. A combinatorial nerve lemma for the diameter filtration

The Vietoris–Rips complex approximates the *Čech* complex (the nerve of the ball
cover), and the Nerve Lemma says the Čech complex is homotopy-equivalent to the
union of balls. A tractable combinatorial shadow: at any scale `ε`, every face of
the VR complex whose vertices share a common `ε/2`-ball is a Čech face, giving the
classical interleaving `Čech(ε) ⊆ VR(2ε)`. Formalizing the inclusion of these two
filtrations is a concrete, finite statement.

**The key insight is** that the interleaving is governed entirely by the triangle
inequality applied to `diamWeight`: a common ball of radius `ε/2` forces all
pairwise distances below `ε`, which is precisely `vr_mem_iff_diam_le`. **Why now?**
With both complexes expressible as sublevel sets of explicit `Finset.sup'`-style
weights, the interleaving inclusion becomes a `Finset.sup'_le` argument of exactly
the kind already used to prove `diamFiltration.weight_mono`, so no new analytic
machinery is needed — only the metric bookkeeping that our framework now makes
routine.
