# Future Directions — Neural Observation Pseudometrics ↔ Proof Spectra

These conjectures extend the bridge developed in
`Catalog/Bridges/NeuralPseudometricProofSpectrumFunctor.lean` and its functoriality /
primality / quotient-geometry sequel
`Catalog/Bridges/NeuralProofSpectrumFunctoriality.lean`. Each is stated to be precise and
falsifiable, with a suggested Lean formalization target.

## C1. Primality is *equivalent* to read-out null-detection (not just sufficient)

The sequel proves `ObserveDetectsNull N` + `NoZeroDivisors K` ⟹ `behaviorPrimeCongruence`
(closing Failure analysis F2). **Conjecture:** for systems whose reachable behavior values
generate `K` multiplicatively, `behaviorCongruence N` is prime *iff* the read-out detects
nullity along reachable states, i.e. `ObserveDetectsNull` is essentially necessary, not
merely sufficient.
- *Target:* `behaviorCongruence_isPrime_iff_observeDetectsNull` under a reachability /
  generation hypothesis.
- *Falsifier:* an integral-domain system that is prime yet has a non-null state with null
  read-out.

## C2. The quotient carries a genuine metric, and the functor lands in `MetricSpace`

`obsDist` is `{0,1}`-valued, symmetric, triangular, and `obsDist_well_defined` shows it is
constant on Myhill–Nerode classes. **Conjecture:** `obsDist` descends to a bona fide
`MetricSpace` instance on the behavioral quotient `R / behaviorCongruence N`, and
`AlgNeuralHom`-morphisms induce `1`-Lipschitz (indeed nonexpansive) maps of these metric
quotients — upgrading the `Prop`-level functor of the sequel to a functor into the category
of metric spaces.
- *Target:* `instance : MetricSpace (Quotient (behaviorSetoid N))` plus
  `LipschitzWith 1 (quotientMap f)`.

## C3. Graded ultrametric refinement of `obsDist`

Failure analysis F1 of the parent file rejected the depth-graded ultrametric
`2^{-(first separating depth)}` because the separating depth can be undefined. Using the
*antitone* filtration `neural_equiv_upto_antitone` from the sequel, define
`gradDist N x y = 2^{-(sInf {k | ¬ neural_equiv_upto N k x y})}` with the empty-set
convention giving `0`. **Conjecture:** `gradDist` is a genuine **ultrametric** (strong
triangle inequality) whose kernel is again `behaviorCongruence N`, refining `obsDist` while
agreeing with it on the kernel.
- *Target:* `gradDist_isUltrametric` and `gradDist_kernel_eq_congruence`.
- *Falsifier:* a 3-state system violating the strong triangle inequality for `gradDist`.

## C4. Functorial Galois/Zariski transport

The sequel exhibits `N ↦ behaviorPrimeCongruence N` as a point of `ProofSpectrum R`.
**Conjecture:** an `AlgNeuralHom f : N ⟶ M` whose `toFun` is a *semiring homomorphism*
induces a continuous map `Spec(toFun) : ProofSpectrum S → ProofSpectrum R` for which the
behavioral prime congruence is natural: `Spec(toFun)(behaviorPrimeCongruence M) =
behaviorPrimeCongruence N`, and `zariskiClosed` pulls back along it. This would make the
bridge a morphism of *spectral spaces*, not just of points.
- *Target:* `behaviorPrime_natural` + `zariskiClosed_pullback`.

## C5. Tensor/product systems and primality of products

For two algebraic neural systems `N, M` over a common alphabet, define the product system
on `R × S` (componentwise dynamics, paired read-out into `K × K`). **Conjecture:**
`behaviorCongruence (N × M)` equals the product congruence, its zero-class is the product
of the zero-classes, and it is **never** prime when both factors are nontrivial — exposing
that primality of behavioral congruences is incompatible with nontrivial behavioral
products (the proof-spectrum analogue of `Spec(A × B)` being disconnected).
- *Target:* `behaviorCongruence_prod` and `behaviorCongruence_prod_not_prime`.
