# FUTURE DIRECTIONS — Discrete Hodge ↔ Probability (cycle v16a)

This cycle delivered a self-contained Mathlib foundation for the discrete Hodge
program on finite weighted graphs and proved two of the program's headline
conjectures:

* `Catalog/Bridges/DiscreteHodgeRandomWalk.lean` — the foundation: Dirichlet
  energy identity `xᵀLx = ½ Σᵢⱼ wᵢⱼ(xᵢ−xⱼ)²`, positive semidefiniteness and
  symmetry of `L = D − A`, harmonicity of constants, unconditional detailed
  balance for `P = D⁻¹A`, the factorization `L f = D(f − Pf)`, and the bridge
  `(L f)ᵢ = 0 ⟺ (P f)ᵢ = fᵢ` at positive-degree vertices.
* `Catalog/Bridges/DiscreteHodgeKernel.lean` — **C1 solved**: on a connected
  graph, `ker L` is exactly the constants (discrete `H⁰`).
* `Catalog/Bridges/DiscreteHodgeReversibility.lean` — **C4 solved**: reversibility
  ⟺ `π`-self-adjointness ⟺ symmetry of the weight kernel `wᵢⱼ = πᵢ Pᵢⱼ`.

The adversarial review of each theorem (recorded in the in-file Lab Notes) located
the exact boundary cases — disconnection for C1, zero-degree vertices for the
bridge, and indicator-vector necessity for C4 — and those boundaries are precisely
what the conjectures below promote to theorems.

---

## D1 — `dim ker L` equals the number of connected components

For a finite weighted graph, `Module.finrank ℝ (LinearMap.ker (Matrix.mulVecLin (lap w)))`
equals the number of connected components of the positive-weight support graph,
with the component indicator functions as an explicit basis.

**The key insight is** that `lap_mulVec_eq_zero_iff_const` already pins the kernel
on *one* connected component to a 1-dimensional space; the global kernel is the
direct sum over components, so the dimension is a pure counting statement once the
component partition (via `Relation.ReflTransGen`) is in hand.

**Why now?** The connectedness counterexample surfaced by the C1 critic (two
isolated vertices give a 2-dimensional kernel) is exactly the `n`-component case,
so the proof is a localization of the already-formalized connected result rather
than new analysis.

---

## D2 — Spectral gap ⇒ Poincaré inequality for the reversible walk

For a connected graph, let `λ₁ > 0` be the smallest nonzero eigenvalue of `L`
relative to the degree inner product. Then `Var_π(f) ≤ (1/λ₁) · 𝓔(f,f)` where
`𝓔(f,f) = ½ Σᵢⱼ wᵢⱼ(fᵢ−fⱼ)²` is the Dirichlet form proved here, hence the walk
contracts variance by a factor `(1 − λ₁)` per step.

**The key insight is** that `lap_quadForm` identifies `𝓔(f,f)` *on the nose* with
`fᵀLf`, and `lap_posSemidef` plus C1 give the spectral decomposition `0 = λ₀ < λ₁`
with the constants as the bottom eigenspace; the Poincaré constant is then the
Courant–Fischer minimum over the orthogonal complement of constants.

**Why now?** Both ingredients — the exact energy identity and the
"kernel = constants" gap-opening fact — are formalized this cycle, so the
inequality reduces to a Rayleigh-quotient argument with no missing analytic input.

---

## D3 — Finite-dimensional discrete Hodge decomposition `ℝ^V = ker L ⊕ range L`

Because `L` is symmetric and PSD, `ℝ^V` decomposes orthogonally as
`ker L ⊕ range L`; every `f` splits uniquely as `f = h + L g` with `h` harmonic,
and `h` minimizes Dirichlet energy among all representatives of `f mod range L`.

**The key insight is** that symmetry (`lap_isSymm`) makes `range L = (ker L)ᗮ`
in the standard inner product, so the abstract `Submodule.orthogonal` machinery in
Mathlib yields the decomposition directly from the two facts already proved; the
energy-minimality of `h` is then `Pythagoras` applied to `f = h + Lg`.

**Why now?** The conjecture explicitly "needs only `Matrix.IsSymm` + PSD", and both
are theorems in the foundation file, so this is a packaging of existing results into
the orthogonal-projection API rather than new mathematics.

---

## D4 — Effective resistance is the squared distance of the resistance metric

Define `R(i,j)` as the Dirichlet energy of the minimal-energy `g` solving
`L g = eᵢ − eⱼ` on a connected graph. Then `R` is a metric on vertices and equals
`(eᵢ−eⱼ)ᵀ L⁺ (eᵢ−eⱼ)` for the Moore–Penrose pseudoinverse `L⁺`, and `2·(total
weight)·R(i,j)` is the expected commute time of the reversible walk.

**The key insight is** that the Hodge decomposition (D3) makes `eᵢ − eⱼ ∈ range L`
(it is orthogonal to constants), so the defining equation `L g = eᵢ − eⱼ` is
solvable and `L⁺` is well-defined; the triangle inequality for `R` is then exactly
PSD of `L⁺` applied to differences of unit vectors.

**Why now?** The solvability obstruction is removed precisely by C1/D3 (`eᵢ − eⱼ`
sums to zero, hence lies in `range L = (ker L)ᗮ`), so the resistance metric becomes
definable as soon as the decomposition is in place — the deepest probability↔Hodge
bridge becomes reachable from this cycle's results.

---

## D5 — Reversible chains and weighted graphs are the same category

C4 gives a pointwise bijection `reversible (π, P) ↔ symmetric weight kernel w`.
Conjecture: this lifts to an *equivalence of categories* between reversible Markov
kernels with measure-preserving maps and finite weighted graphs with
weight-preserving maps, under which the walk Laplacian `I − P` corresponds to the
normalized graph Laplacian `D^{-1/2} L D^{-1/2}`.

**The key insight is** that `reversible_tfae` already identifies the *objects*
canonically (`wᵢⱼ = πᵢ Pᵢⱼ`); promoting it to a functor only requires checking that
detailed balance is preserved under the natural notion of morphism, which is again
a symmetry computation of the kind automated in C4.

**Why now?** The object-level equivalence is a proven `TFAE` this cycle, so the
categorical statement is the natural next abstraction and has no analytic
prerequisites — only the bookkeeping of morphisms.
