# Future Directions: Emergent Spacetime from Quantum Entanglement

The file `Catalog/Physics/Spacetime/EmergentSpacetimeEntanglement.lean` establishes a
self-contained toy model in which a *metric geometry* emerges from an abstract
entanglement functional. The centerpiece is `HolographicEntropy.entDist_triangle`:
the entropic ("variation-of-information") distance
`d(A,B) = 2·S(A∪B) − S A − S B` satisfies the triangle inequality as a direct
consequence of strong subadditivity, together with non-negativity, symmetry and
reflexive vanishing. The qubit section closes the ER=EPR dictionary at the
single-pair level: an Einstein–Rosen bridge (positive entanglement entropy)
exists iff the pair is EPR-entangled. The following conjectures extend this
frontier, each phrased to be testable and falsifiable inside the same Lean
framework.

## 1. The emergent geometry is a genuine `PseudoMetricSpace`

We proved the four pseudometric axioms separately. The natural strengthening is
to package a `HolographicEntropy α` together with a chosen separating quotient
into an actual Mathlib `PseudoMetricSpace` (and, after quotienting by
`d(A,B) = 0`, a `MetricSpace`) instance, so that the whole topological toolbox —
balls, completeness, Hausdorff distance, Gromov–Hausdorff limits — becomes
available to the entanglement structure.
**The key insight is** that `entDist_self`, `entDist_comm`, `entDist_nonneg` and
`entDist_triangle` are *exactly* the four bundled fields of `PseudoMetricSpace`,
so the instance is a packaging theorem, not new mathematics — and once it exists,
"the geometry of spacetime is a metric space reconstructed from entanglement"
becomes a literal Lean type, not a slogan.
**Why now?** With the four axioms already discharged from submodularity, the
remaining work is purely structural plumbing that unlocks downstream geometric
analysis with essentially zero additional analytic risk.

## 2. Ryu–Takayanagi monotonicity: more entanglement ⇒ shorter bridge

Conjecture: for the one-qubit realization, the emergent distance
`log 2 − schmidtEntropy p` is strictly decreasing in the entanglement on `[0,1/2]`
and strictly increasing on `[1/2,1]`, attaining its unique minimum (zero) at the
maximally entangled point `p = 1/2`, matching `schmidtEntropy_max_iff_maximally_entangled`.
**The key insight is** that the Ryu–Takayanagi relation "geodesic length is a
decreasing function of boundary entanglement" is, in this toy model, precisely
the strict concavity / unimodality of `Real.binEntropy`, which Mathlib already
supports via `Real.strictConcaveOn_binEntropy`-style lemmas.
**Why now?** `schmidtEntropy_pos_iff_entangled` already isolates the interior of
`[0,1]` as the entangled regime; upgrading the qualitative iff to a quantitative
monotone profile is the next provable rung and turns the dictionary into a
quantitative RT statement.

## 3. Disconnection ⇔ factorization (the converse wormhole criterion)

Conjecture: for disjoint regions `A,B`, the emergent distance is *maximal*
(equivalently the mutual information vanishes, `H.mutualInfo A B = 0`) **iff** the
entropy factorizes, `S(A∪B) = S A + S B`. This is the geometric statement that
"no bridge ⇔ product state": two boundary regions are at the maximal emergent
separation exactly when they are completely unentangled.
**The key insight is** that `mutualInfo_nonneg` already pins the sign, so the
equality case is governed entirely by the saturation of submodularity at
`S(A∩B) = 0`, an extremal/rigidity analysis rather than a fresh inequality.
**Why now?** Having proved the bridge *exists* when entangled, the scientifically
sharp and falsifiable claim is the converse — that disconnection forces
factorization — which is the missing half of the ER=EPR equivalence.

## 4. Subsystem-pure entanglement symmetry `S A = S Aᶜ`

Augment `HolographicEntropy` with a global-purity field (`S univ = 0`) and
conjecture the von-Neumann symmetry `S A = S Aᶜ` for every region `A`, hence
`mutualInfo A Aᶜ = 2 · S A`: the bridge cross-section between a region and its
complement is exactly twice the entanglement entropy.
**The key insight is** that complementary purity is the single extra axiom that
turns the *one*-sided subadditive cone into the *symmetric* RT entropy of a
globally pure state, and `er_epr_mutual_info` in the catalog is the degenerate
`S A = 0` shadow of this identity.
**Why now?** The current structure deliberately omits purity to stay maximally
general; reintroducing it as an opt-in field is a clean, low-risk extension that
connects the abstract functional directly to the pure-state holographic setting
where ER=EPR was originally formulated.

## 5. Holographic codes: error correction implies submodularity

Bridge to `Physics.Spacetime.QuantumGravityErrorCorrection`: conjecture that the
`PerfectTensor` / `QECCode` data there *induce* a `HolographicEntropy` whose `S`
counts cut bond dimensions, and that the code's correctability bound forces the
submodular axiom — so the metric of Theorem 1 emerges from quantum error
correction itself.
**The key insight is** that a perfect-tensor cut function is a polymatroid rank
function, and polymatroid rank functions are exactly the submodular monotone
normalized functions that `HolographicEntropy` axiomatizes — making the holographic
code a *constructor* of emergent geometry rather than a separate object.
**Why now?** The catalog already contains `PerfectTensor.maxEntropy` and
`perfect_tensor_entropy_pos`; wiring those into a `HolographicEntropy` instance is
a concrete cross-domain synthesis that would let the emergent-metric theorems be
*applied*, not merely stated, validating the whole framework on a worked example.
