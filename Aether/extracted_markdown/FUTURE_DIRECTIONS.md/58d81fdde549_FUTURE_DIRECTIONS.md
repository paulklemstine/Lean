# Future Directions

Follow-up conjectures arising from the *Deepening* cycle on the functorial comparison
between neural observation pseudometrics and proof-spectrum congruences.

Relevant files:
- `Catalog/Bridges/NeuralPseudometricProofSpectrumFunctor.lean` (base bridge)
- `Catalog/Bridges/NeuralPseudometricProofSpectrumFunctorDeep.lean` (this cycle)

This cycle resolved two open conjectures from the base file's lab notes:
- **F1** — the depth-graded distance `gradedDist x y = 2^(-sepDepth x y)` is a genuine
  **pseudo-ultrametric** (strong triangle inequality), refining the discrete pseudometric
  `obsDist` while recording the separating depth (`gradedDist_strong_triangle`,
  `gradedDist_le_obsDist`).
- **F2** — under a **faithful observation point** and an integral-domain output, the
  behavior congruence is **prime**, i.e. a genuine point of `ProofSpectrum R`
  (`behaviorPrimeCongruence`, `behaviorPrime_vanishes_iff`).

It also sharpened functoriality to a *metric* statement: morphisms of algebraic neural
systems are **non-expansive** for the graded ultrametric (`gradedDist_map_le`).

## Conjecture C1 (completeness / Cauchy structure of the graded ultrametric)

The quotient of `(R, gradedDist N)` by the behavioral kernel is a metric space; conjecture
that it is **complete** whenever the alphabet `α` is finite and the output `K` is discrete,
and that its completion is canonically the profinite limit of the depth-`k` partition
quotients `R / agreeUpto N k`. Concretely: the inverse system `(R / agreeUpto N k)_k` with
the refinement maps has a limit isometric to the completion of the Myhill–Nerode quotient.
*Testable*: build the inverse system, exhibit the isometry, prove completeness for finite
`α`.

## Conjecture C2 (exact class of faithful-point systems)

Characterize the algebraic neural systems admitting a `FaithfulPoint w₀`. Conjecture: a
finite-state system over an integral domain admits a faithful point **iff** the family of
observation functionals `{a ↦ algBehavior N a w}_w` is *cyclically generated* — i.e. some
single word's functional has the same zero set as the whole behavioral nullspace.
Equivalently, the behavior congruence is prime iff its zero-class is the kernel of a single
point-evaluation semiring map `R → K`. *Testable*: prove the "single evaluation ⇒ prime"
direction in general and the converse over a field with finite `R`.

## Conjecture C3 (functoriality is a contraction-category equivalence)

The assignment `N ↦ (R, gradedDist N)` and `f ↦ f.toFun` is a functor into the category of
pseudo-ultrametric spaces with non-expansive maps (this cycle proved each morphism is
non-expansive). Conjecture that it factors through an **equivalence** onto its image when
restricted to *minimal* (Myhill–Nerode-reduced) systems: a non-expansive map between two
minimal behavioral ultrametrics that preserves observations is induced by a unique
`AlgNeuralHom`. *Testable*: state minimality, prove the unique-lift property.

## Conjecture C4 (spectrum-valued continuity / Zariski–metric comparison)

Pulling back the Zariski topology on `ProofSpectrum R` along the point map
`behaviorPrimeCongruence_mem_spectrum` should be coarser than (continuous w.r.t.) the
graded-ultrametric topology on the faithful-point locus. Conjecture: for systems with a
faithful point, the map `x ↦` (the prime congruence's vanishing locus) is
**ultrametrically continuous**, so behaviorally-close states have Zariski-close vanishing
data. *Testable*: formalize the pullback topology and prove continuity using
`gradedDist_le_obsDist` and `behaviorPrime_vanishes_iff`.

## Conjecture C5 (graded radical = depth-stabilization)

Define a depth-graded radical of the behavior congruence by intersecting the prime
refinements detectable at depth `≤ k`. Conjecture this graded radical **stabilizes** at the
finite depth `k = neural_state_complexity` (the partition-refinement bound from the
Myhill–Nerode file), giving an effective `O(|α|^k)` computation of the radical theory of
`behaviorCongruence N`, and that the stabilization depth equals the diameter of the graded
ultrametric on the reachable quotient. *Testable*: define the graded radical, prove
monotone stabilization and the bound via `finite_depth_refinement_stabilizes_sufficient`.
