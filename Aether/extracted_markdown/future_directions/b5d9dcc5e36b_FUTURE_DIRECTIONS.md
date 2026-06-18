# Future Directions: Tropical Plancherel Reconstruction Theory

This document outlines five concrete, breakthrough-level research opportunities opened by our formalization of tropical Plancherel reconstruction via idempotent Hecke semirings.

---

## 1. Tropical Plancherel Measure Surrogate

**Goal:** Define and formalize a combinatorial or capacity-theoretic replacement for the classical Plancherel measure on the tropical spectrum `SphTrop(H)`.

**Motivation:** In classical harmonic analysis, the Plancherel measure on the unitary dual gives a canonical weight to each irreducible representation, enabling the Parseval identity ‖f‖² = ∫ |f̂(χ)|² dμ(χ). In the tropical setting, there is no natural Hilbert space norm, but there is a natural lattice-theoretic analogue: the "tropical capacity" or "idempotent Radon measure" that assigns weights to extremal characters.

**Concrete Targets:**
- Define a tropical capacity function `μ : SphTrop(H) → WithTop ℤ` satisfying natural compatibility conditions with the transform.
- Prove a Parseval-type inequality: for any `h : H`, the transform `𝓕(h)` satisfies a lower-envelope bound controlled by `μ`.
- Instantiate for finitely generated free idempotent semirings, where the measure corresponds to the uniform distribution on extremal characters.

**Technical Path:** Use the finite extremal spectrum structure as a discrete support for the measure. The key challenge is identifying the correct normalization condition — likely related to the number of monomials in the tropical polynomial normal form.

---

## 2. Tropical Satake for Explicit Groups

**Goal:** Instantiate the abstract tropical Plancherel framework for concrete semirings modeling spherical Hecke objects of GL₂ and GL₃.

**Motivation:** The classical Satake isomorphism identifies the spherical Hecke algebra H(G(F)//G(O)) with the representation ring Rep(Ĝ) for a reductive group G over a p-adic field. Our formalization provides the abstract spectral reconstruction framework; instantiating it for explicit groups would validate the theory and connect it to established tropical Satake work.

**Concrete Targets:**
- Define the tropical spherical Hecke semiring for GL₂ as a quotient of the free idempotent semiring on Hecke operators T_p.
- Construct the complete finite extremal spectrum from dominant coweights and prove it satisfies `SpectrumComplete`.
- Verify that the generator spectrum coincides with the Weyl-invariant tropical coweight cone.
- Prove that the fingerprint algorithm recovers the classical tropical Satake injectivity theorem as a special case.

**Technical Path:** Build on the existing `TropicalSatake.lean` infrastructure in the catalog, which already establishes Satake injectivity for GL₂ and GL₃ in the max-plus convention. The key step is constructing `TropicalCharacter` instances from the existing Satake parameter maps.

---

## 3. Trace Formula Shadow

**Goal:** Formalize a tropical trace distribution attached to convolution by an element `h : H` and prove it is recoverable from extremal spectral data.

**Motivation:** The classical Selberg trace formula relates spectral data (eigenvalues of Hecke operators) to geometric data (orbital integrals). A tropical shadow would relate the transform fingerprint to a "tropical orbital integral" — the piecewise-linear analogue of summing over conjugacy classes.

**Concrete Targets:**
- Define a tropical trace functional `Tr : H → WithTop ℤ` as the min over all characters of the transform value: `Tr(h) = inf_{χ ∈ SphTrop(H)} χ(h)`.
- Prove that under a complete finite spectrum, the trace is computable as a finite minimum of fingerprint values.
- Show that the trace satisfies convolution compatibility: `Tr(h₁ * h₂) ≤ Tr(h₁) + Tr(h₂)`.
- For GL₂, identify the tropical trace with a known piecewise-linear function on the dominant coweight cone.

**Technical Path:** The trace functional is the global minimum of the lower envelope from Theorem 3. The convolution bound follows from the multiplicativity of characters. The key challenge is the geometric interpretation in terms of tropical orbital integrals.

---

## 4. Automata/Complexity Interface

**Goal:** Show that transform fingerprints coincide with minimal observer semantics for weighted automata over idempotent semirings, yielding complexity bounds for equality checking.

**Motivation:** Finite-state weighted automata over tropical semirings are a classical model in formal language theory. The Myhill–Nerode theorem says that a regular language is characterized by a finite congruence — and our radical congruence is exactly the tropical analogue. This connection would give complexity bounds for the fingerprint equality algorithm.

**Concrete Targets:**
- Define tropical weighted automata as coalgebras over the idempotent Hecke semiring.
- Prove that the radical congruence on `H` coincides with the Myhill–Nerode equivalence for the corresponding automaton.
- Show that the number of extremal characters in a complete spectrum equals the state-minimal automaton size.
- Derive that equality checking via fingerprints runs in time O(|E| · poly(|gens|)) where |E| is the spectrum size.

**Technical Path:** The connection to automata is via the observation that a tropical character is a "one-dimensional tropical representation" — analogous to a scalar-valued automaton weight. The Myhill–Nerode equivalence arises from the kernel of the transform map.

---

## 5. Tropical Tannakian Reconstruction Upgrade

**Goal:** Connect spherical characters of the Hecke semiring to fiber-functor-like invariants in tropical Tannaka reconstruction, aiming at a duality theorem between idempotent representation categories and tropical spectral semirings.

**Motivation:** Classical Tannaka duality reconstructs a group from its category of representations with the forgetful (fiber) functor. In the tropical setting, a "representation" of the Hecke semiring is a tropical semimodule action, and the "fiber functor" evaluates the action on a fixed element. Our character separation theorem says that the collection of all such functors separates elements — which is the first step toward a full Tannakian reconstruction.

**Concrete Targets:**
- Define tropical semimodule representations of `H` and the associated character maps.
- Show that one-dimensional representations correspond to tropical characters in `SphTrop(H)`.
- Formulate and prove a tropical Tannaka duality for finitely generated commutative idempotent semirings: the canonical map from `H` to the endomorphism semiring of the forgetful functor is injective (under semisimplicity).
- Connect this to the fingerprint algorithm: the fiber functor evaluation at each point gives a column of the fingerprint matrix.

**Technical Path:** This is the most ambitious direction and requires building categorical infrastructure for idempotent semimodules. The key insight is that the evaluation map `h ↦ (χ ↦ χ(h))` is precisely the canonical map in Tannaka reconstruction, and our faithfulness theorem proves it is injective.

---

## Cross-Cutting Themes

All five directions share a common architectural feature: they extend the **finite spectral fingerprint** from an equality-checking tool to a richer invariant theory. The fingerprint is simultaneously:
- A **Plancherel coefficient vector** (Direction 1)
- A **Satake parameter tuple** (Direction 2)
- A **trace formula input** (Direction 3)
- An **automaton state vector** (Direction 4)
- A **fiber functor evaluation** (Direction 5)

This convergence suggests that the tropical Plancherel reconstruction framework is not merely an analogy but a genuine structural bridge between representation theory, combinatorics, automata theory, and tropical geometry.
