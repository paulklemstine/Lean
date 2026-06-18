# Future Directions — Berggren–Lorentz Certificates for Lattice Reduction

This cycle (see `LatticeReduction.lean`) lifted the single-generator facts of
`Core.lean` to whole-word / whole-monoid statements and produced a verified
**descent (lattice-reduction) certificate** for the Berggren tree:

- Every word matrix lies in `O(2,1;ℤ)` (`wordMatrix_preserves_lorentz`).
- Determinant of a word is `(-1)^(#B-letters)` (`wordMatrix_det`), hence a unit, so
  every word matrix is a `ℤ`-lattice automorphism of `ℤ³` (`wordMatrix_det_isUnit`).
- Word matrices act as isometries of the Lorentz form, so they preserve the light
  cone / Pythagorean triples (`wordMatrix_preserves_lightCone`).
- The inverse generator `redB` strictly decreases the hypotenuse of a positive
  Pythagorean triple while staying on the light cone (`redB_descent`), giving a
  well-founded `ℕ`-measure (`redB_strict_anti`).

Below are concrete, falsifiable conjectures for follow-up cycles.

## C1. Completeness of the parent map (Barning–Hall descent)
**Conjecture.** For every primitive Pythagorean triple `(a,b,c)` with `c > 5` and
positive legs, *exactly one* of the inverse generators `invA, invB, invC` sends it to
another primitive Pythagorean triple with positive legs and strictly smaller
hypotenuse; iterating reaches the seed `(3,4,5)`.
**Test.** Formalize a `parent : ℤ×ℤ×ℤ → ℤ×ℤ×ℤ` choosing the inverse by the sign of
`a - b` and primality conditions, prove `parent` lands in positive primitive triples
with smaller `c`, then use `redB_strict_anti`-style well-foundedness to prove every
primitive triple is `wordMatrix w *ᵥ (3,4,5)` for a unique word `w`. This upgrades the
per-branch descent of this cycle to surjectivity + uniqueness (freeness of the tree).

## C2. Free-monoid word problem and unique factorization
**Conjecture.** The Berggren monoid is free on `{A,B,C}`: `wordMatrix w = wordMatrix w'`
iff `w = w'`. Equivalently, the orbit map `w ↦ wordMatrix w *ᵥ (3,4,5)` is injective.
**Test.** Combine C1 (unique parent ⇒ unique reduction path) with the
non-commutativity facts of `Core.lean`. A verified injective orbit map turns the
"hardness of word reversal" claims into an actual `Function.Injective` statement,
giving a rigorous collision-freeness certificate.

## C3. Quantitative growth / depth = Θ(log c)
**Conjecture.** For a primitive triple at tree depth `n`, the hypotenuse satisfies
`3^n ≤ c ≤ (3 + 2√2)^n` (up to the seed constant), so `depth(c) = Θ(log c)`.
**Test.** This cycle proved `5c < hypB` (Core) and `redB` divides the hypotenuse by a
factor `> 1`; iterate to get a two-sided geometric bound. The upper rate `3 + 2√2` is
the spectral radius (largest eigenvalue) of `matB`; prove it via the characteristic
polynomial `λ³ - 5λ² - 5λ + 1` factoring through `λ² - 6λ + 1`.

## C4. Lorentz-form isometry ⇔ membership characterization
**Conjecture.** A matrix `M ∈ GL₃(ℤ)` preserves `lorentzForm` under `mulVec` **iff**
`Mᵀ Q M = Q`. The current file proves the (⇐) direction abstractly
(`mulVec_preserves_lorentzForm`); the (⇒) direction would give a clean intrinsic
characterization of `O(2,1;ℤ)` membership purely in terms of the action on vectors.
**Test.** Prove `(∀ v, lorentzForm (M *ᵥ v) = lorentzForm v) → Mᵀ Q M = Q` by testing
on the standard basis and the pairwise sums `eᵢ + eⱼ` (polarization), reusing
`lorentzBilinear` from `Core.lean`.

## C5. Spectral / Lyapunov gap as a security parameter
**Conjecture.** The three generators have distinct dominant eigenvalues
(`B` strictly larger than `A, C`), and the minimal singular value of any length-`n`
word is bounded below by `ρ⁻ⁿ` for an explicit `ρ`, giving a certified Lipschitz /
conditioning bound for the orbit map (relevant to the ML/robustness bridge in `Core`).
**Test.** Compute eigenvalues from the characteristic polynomials (already accessible
via `det (λ·I − M)`), prove the trace/eigenvalue separation `(3,5,3)` from
`berggren_trace_signature`, and bound word norms via submultiplicativity of the
operator norm.
