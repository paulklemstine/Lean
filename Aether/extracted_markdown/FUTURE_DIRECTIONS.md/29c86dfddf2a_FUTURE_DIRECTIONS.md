# Future Directions — Spectral Universality of Transformer Weight Dynamics

The Lean development in `Basic.lean` formalizes the rigorous backbone of the
spectral-universality conjecture: the empirical spectral measure of a
weight-update covariance matrix is encoded by its **spectral moments**
`specMoment M k = tr(Mᵏ)`, and these moments are provably invariant under the
two transformations that capture "architecture microdetail" — change of basis
(`specMoment_conj_invariant`, `specMoment_units_conj`, packaged as the
universality class `conj_sameSpectralMoments`) and covariance orientation
(`specMoment_orientation`, the rectangular `AB`/`BA` trace identity). The
normalization scaling law (`specMoment_smul`) and mean-spectrum linearity
(`specMoment_one_add`) complete the invariance algebra.

This proven invariance group is the foundation on which any *limiting universal
law* must be defined. The following directions extend that foundation toward the
full conjecture, each stated as a falsifiable mathematical claim that the next
cycle can attack in Lean.

## Direction 1 — Moment determinacy of the empirical spectral measure

**Conjecture.** For self-adjoint `M : Matrix (Fin n) (Fin n) ℝ`, the normalized
moment sequence `k ↦ tr(Mᵏ)/n` uniquely determines the empirical spectral
measure `μ_M = (1/n) Σ δ_{λᵢ}`; consequently `SameSpectralMoments M N` (for
matched dimension) is equivalent to `μ_M = μ_N`. The key insight is that an
empirical spectral measure is *finitely supported*, so the classical Hamburger
moment problem becomes a finite, fully determined Vandermonde inversion — the
measure is recovered exactly from finitely many moments, no analytic tail
conditions needed. **Why now?** We have already proven moment-level invariance
(`SameSpectralMoments`), but the catalog states universality at the level of
*measures*; bridging the two requires exactly this finite moment-determinacy
lemma, and Mathlib now has enough `Polynomial`/`Matrix.charpoly` and
finitely-supported `MeasureTheory` API to carry the Vandermonde argument.

## Direction 2 — Free-additive-convolution law for block-independent layers

**Conjecture.** If two layer weight-update blocks are asymptotically free (in the
free-probability sense) then the limiting spectral law of their sum is the
*free additive convolution* `μ₁ ⊞ μ₂`, characterized by additivity of the
R-transform; in particular the normalized moments of the sum are the
free-cumulant convolution of the summands, generalizing our additive first
moment `specMoment_one_add` to all orders. The key insight is that
`specMoment_one_add` is the order-1 shadow of a much deeper combinatorial law:
non-crossing-partition moment-cumulant relations turn additivity of means into
additivity of *free cumulants* at every order. **Why now?** Our file isolates the
first-moment additivity as a standalone theorem, exposing exactly the gap that
free cumulants fill; formalizing non-crossing partitions and the R-transform is a
self-contained combinatorics-of-`Finset` project that does not depend on any
training dynamics and would be a genuinely novel Mathlib contribution.

## Direction 3 — Marchenko–Pastur as the orientation-invariant Wishart law

**Conjecture.** For a random rectangular factor `G : Matrix (Fin p) (Fin n) ℝ`
with i.i.d. zero-mean unit-variance entries and aspect ratio `p/n → c`, the
empirical spectral measure of the sample covariance `(1/n) G Gᵀ` converges to the
Marchenko–Pastur law `MP(c)`, and — crucially — `specMoment_orientation`
guarantees the *same* nonzero-spectrum law arises from `(1/n) Gᵀ G`, so the
limit is intrinsic to `G` rather than to the chosen covariance orientation. The
key insight is that our exact, finite-`k` identity `tr((AB)ᵏ⁺¹) = tr((BA)ᵏ⁺¹)`
is precisely the algebraic statement that pins the two oriented spectra together
*before* any limit is taken, so the limiting MP moments inherit orientation
independence for free. **Why now?** `specMoment_orientation` is proven and
dimension-agnostic; combined with Mathlib's growing probability and combinatorics
of lattice-path / Catalan-number moment formulas, the MP moment recursion
`m_{k} = Σ c·(non-crossing pairings)` is now formalizable, and it is the simplest
concrete instance of the conjectured universal family.

## Direction 4 — Optimizer class as a deformation of the spectral generator

**Conjecture.** Distinct gradient-based optimizers (plain SGD vs. preconditioned
/ adaptive methods) act on the weight-update covariance as a fixed *symmetric
positive-definite conjugation* `M ↦ Sᵀ M S`, and therefore — by a
positive-definite refinement of `specMoment_conj_invariant` — preserve spectral
moments **iff** the preconditioner is orthogonal, while a non-orthogonal `S`
deforms the moments in a controlled, `S`-dependent way that is *constant across
architectures*. The key insight is that "optimizer class determines the law"
becomes the precise statement that the moment-deformation map factors through the
conjugating matrix `S` alone and is independent of `M`'s architectural origin,
which is exactly the structure our conjugation theorems already expose.
**Why now?** We have the clean similarity-invariance theorem in hand; upgrading
it to track *how* moments change under non-invertible-preserving conjugation is a
short step that turns a qualitative ML claim ("optimizer sets the universality
class") into a quantitative, refutable Lean statement.

## Direction 5 — Entropy rate as the single scalar pinning the limit

**Conjecture.** Within a fixed optimizer class, the limiting spectral law is a
one-parameter family indexed solely by the data **entropy rate** `h`, with the
normalized second spectral moment `tr(M²)/n` an affine function of `h`; matching
`h` across architectures forces all higher normalized moments to agree in the
limit, while a mismatch in `h` produces a predicted, monotone shift in the second
moment. The key insight is that `specMoment_smul` already shows the second moment
scales as `c²` under global rescaling, so once the *normalization* is fixed by
`h` the second moment is the unique remaining free parameter — every other moment
is then determined by the universality class. **Why now?** With the scaling law
(`specMoment_smul`) and basis invariance proven, the only undetermined degree of
freedom left in the moment hierarchy is an overall scale; tying that scale to a
formal information-theoretic `entropy rate` (for which the catalog already hosts
entropy machinery, e.g. `Shared/MutualInformation.lean`,
`Shared/EntropyAlgebra.lean`) is a concrete cross-domain bridge that would close
the loop from data statistics to spectral geometry.
