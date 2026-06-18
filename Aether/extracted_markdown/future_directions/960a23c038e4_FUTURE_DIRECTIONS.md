# Future Directions: Persistent Renormalization Fixed Points

## Synthesis of findings

This cycle built a verified bridge connecting three previously separate strands of
the catalog: the renormalization-group view of training (`MachineLearning/RGFlowTraining.lean`,
`rgStep`, `rgStep_iterate`, `rgStep_fixed_iff`), the persistence/rank-profile viewpoint of
`MachineLearning/MotivicPersistence.lean` (`persistenceProfile_detects_spectral_order`), and
spectral data interpreted as the Jacobian eigenvalues of a coarse-graining map at its fixed
point. The new file `Catalog/MachineLearning/PersistentRenormalization.lean` introduces the
**persistence barcode of the renormalization spectrum**: each mode `i` is the bar `[0, |g i|]`,
and the Betti-count `persistentDim g t` counts the relevant directions surviving coarse-graining
at scale `t`.

The central conceptual move is that three a-priori different objects — the *relevant RG
directions*, the *persistent bars*, and the *eigenvalues with `|g i| ≥ t`* — are literally the
same finite subset of modes. This collapses persistence-theoretic statements into clean
`Finset.card` arguments while preserving their full content.

## Results summary

All theorems below are proven with `sorry = 0` and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

- `persistentDim_antitone` — the barcode Betti-count is antitone in scale (persistence-module
  monotonicity).
- `mem_persistent_iff` — spectral–barcode correspondence: a mode is persistent at scale `t`
  iff its Jacobian eigenvalue magnitude is `≥ t`.
- `persistentDim_subcritical_iff` — the barcode is trivial at the critical scale `1` iff every
  eigenvalue strictly contracts.
- `persistentDim_stable` — bottleneck-type stability: an `ε`-perturbation of the spectrum shifts
  the barcode by at most `ε`.
- `totalPersistence_stable` — total persistence `∑ |g i|` is `(d·ε)`-Lipschitz in the spectrum.
- `rg_flow_tendsto_zero` — closed-form RG flow converges to the IR fixed point `0` when all gains
  contract.
- `persistent_renormalization_fixed_point` — capstone: a trivial critical-scale barcode forces
  the renormalization flow to converge to the IR fixed point.

## Bold, falsifiable research directions

### 1. Sublevel barcode for the *Jacobian sign structure*, not just magnitude

Right now a bar is `[0, |g i|]`, recording only contraction *speed*. But the conjecture asks
for the *sign structure* (eigenvalue multiplicities and signs) of the Jacobian to match a
barcode. **Conjecture:** the signed refinement — splitting persistent modes into orientation-
preserving (`g i > 0`) and orientation-reversing (`g i < 0`) sub-barcodes — yields a `ℤ/2`-graded
persistence module whose two graded Betti-counts are *separately* antitone and stable, and whose
parity sum equals an Euler-characteristic-like invariant of the flow. The key insight is that the
*sign* of `g i` is exactly the orientation of the flow on mode `i`, so a `ℤ/2`-graded barcode is
the natural home for the "sign structure" demanded by the conjecture. Why now? We already have
`persistentDim_antitone` and `persistentDim_stable` as the `ℤ/2`-trivial case; graded versions
are a direct, mechanical strengthening that the existing `Finset.filter` machinery supports.

### 2. Interleaving distance vs. spectral `sup`-distance

We proved stability as a one-sided card inequality. **Conjecture:** the persistence barcodes of
two spectra `g, g'` are `ε`-interleaved (in the formal persistence-module sense) iff
`‖g - g'‖_∞ ≤ ε`, giving an *isometry* between spectral `sup`-distance and barcode bottleneck
distance — a discrete algebraic stability theorem with matching lower bound. The key insight is
that `persistentDim_stable` already gives one interleaving direction; the converse follows by
swapping `g ↔ g'`, so the isometry is within reach. Why now? `persistentDim_stable` is symmetric
in form, and Mathlib has the order/`Finset.card` lemmas needed to assemble both inequalities into
an equality of distances.

### 3. Spectral radius as the unique critical scale of a phase transition

**Conjecture:** the function `t ↦ persistentDim g t` has a single jump-discontinuity-free
profile whose support is exactly `[0, ρ]` with `ρ = max_i |g i|` the spectral radius, and the RG
flow converges to `0` iff `ρ < 1`; moreover `ρ` is the unique scale at which the barcode loses
its last bar. The key insight is that the spectral radius is both the *largest bar endpoint* and
the *dynamical convergence threshold*, unifying the topological and dynamical critical scales into
one number. Why now? `persistentDim_subcritical_iff` is precisely the `t = 1` instance; promoting
`1` to a free `ρ` and proving `rg_flow_tendsto_zero ↔ ρ < 1` extends two existing theorems with
shared infrastructure.

### 4. Affine renormalization with a non-trivial fixed point

The current flow is linear with IR fixed point `0`. **Conjecture:** for the *affine* coarse-
graining `v ↦ g·v + b` (a forcing term `b`, modeling asymptotically scale-invariant PDE forcing),
a unique fixed point `v* = b / (1 - g)` exists componentwise iff `g i ≠ 1` for all `i`, the flow
converges to `v*` iff every `|g i| < 1`, and the persistence barcode of the *linearization at
`v*`* coincides with the barcode of `g`. The key insight is that linearizing any smooth
renormalization map at its fixed point reduces it to exactly the diagonal-gain picture proved
here, so the whole barcode theory transfers verbatim to the nonlinear/forced setting. Why now?
The forcing term is the one ingredient separating our toy model from the conjecture's
"scale-invariant forcing"; Mathlib's Banach/`ContractingWith` API makes the affine fixed point a
short proof on top of `rg_flow_tendsto_zero`.

### 5. Cross-family universality: barcode equality as an equivalence relation

**Conjecture:** define two PDE/operator families to be *RG-equivalent* if their renormalization
spectra have equal barcodes up to the interleaving distance of Direction 2; then this is a genuine
equivalence relation whose classes are a topological notion of universality, and the total
persistence `totalPersistence` is a complete numerical invariant within a class only when all bars
share a common left endpoint (which they do here). The key insight is that a *barcode*, being
stable and antitone, is exactly the kind of coarse invariant that can be equal across
microscopically different families — the precise meaning of "topological universality." Why now?
`totalPersistence_stable` and `persistentDim_stable` already make the barcode a well-defined,
perturbation-robust invariant, so promoting it to an equivalence relation is the natural next
structural step and is fully falsifiable by exhibiting two spectra with equal barcodes but
different dynamics (or vice versa).
