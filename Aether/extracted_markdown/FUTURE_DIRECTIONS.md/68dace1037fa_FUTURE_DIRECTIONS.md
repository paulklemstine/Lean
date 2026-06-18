# Future Directions: Topological Order, Anyons, and Modular Data

## Synthesis

This cycle extended the catalog file `Physics.TopologicalOrderGenus` — which proved the
genus-`g` ground-state degeneracy `GSD A g = d^g` and the **unitarity** of the modular
S-matrix `S_{a,b} = (1/√d)·χ_a(b)` for abelian anyon theories `A` (finite abelian group,
quantum dimension `d = |A|`) — into the new file `Physics.AnyonVerlinde`. The new file
closes the *modular-data ↔ fusion* half of the anyon dictionary by proving, entirely from
the `ModularBraiding` data:

* `verlinde_fusion` — the **Verlinde formula** `∑_x S_{a,x} S_{b,x} conj(S_{c,x})/S_{0,x}
  = δ_{a+b,c}`, exhibiting fusion `a × b = a + b` as the group law of `A`;
* `verlinde_GSD` — the **TQFT dimension formula** `∑_a |S_{0,a}|^{2-2g} = GSD A g = d^g`,
  re-deriving the genus power-law purely from the vacuum S-matrix row (valid for all `g`
  via real `rpow`);
* `quantumDim_eq_one` and `total_quantum_dimension` — every abelian anyon is **invertible**
  (`d_a = S_{0,a}/S_{0,0} = 1`), with total quantum dimension `D^2 = ∑_a d_a^2 = |A| = d`;
* `cyclic_verlinde_fusion`, `cyclic_verlinde_GSD` — the *unconditional* specializations to
  the discrete-Fourier model `cyclicBraiding n` on `ZMod n`.

The unifying engine is additive-character orthogonality (`chi_orthogonality`): bilinearity
of the braiding collapses the triple product `χ_a χ_b conj χ_c` to `χ_{a+b} conj χ_c`, and
orthogonality projects onto the diagonal `a+b=c`. The constant vacuum row `S_{0,a} = 1/√d`
is what makes both the fusion division and the genus power-law come out clean.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `verlinde_fusion` | S-matrix diagonalizes fusion; `N_{ab}^c = δ_{a+b,c}` | proven (no sorry) |
| `verlinde_GSD` | `∑_a |S_{0,a}|^{2-2g} = d^g = GSD A g` | proven (no sorry) |
| `quantumDim_eq_one` | abelian anyons are invertible (`d_a = 1`) | proven (no sorry) |
| `total_quantum_dimension` | `D^2 = ∑_a d_a^2 = |A|` | proven (no sorry) |
| `cyclic_verlinde_fusion` / `cyclic_verlinde_GSD` | unconditional `ZMod n` model | proven (no sorry) |

All results depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. The modular T-matrix and the `(ST)^3 = S^2` representation of `SL(2,ℤ)`

The S-matrix is only half of the modular data. The missing half is the **T-matrix**
`T_{a,b} = δ_{a,b} θ_a`, where `θ_a = exp(2πi h_a)` is the topological spin (twist) of
anyon `a`. For the cyclic model `ZMod n` the natural quadratic refinement is
`θ_a = exp(πi a^2 / n)` (a Gauss sum). The grand challenge is to prove that `S` and `T`
together furnish a projective representation of the modular group `SL(2,ℤ)`, i.e.
`(S T)^3 = e^{iφ} S^2` and `S^2 = C` (charge conjugation, `C_{a,b} = δ_{a,-b}`), with the
central phase `φ` fixed by the Gauss-sum reciprocity law.

The key insight is that, exactly as `verlinde_fusion` reduced fusion to character
orthogonality, the `(ST)^3` relation reduces to **quadratic Gauss-sum reciprocity** for
`ZMod n`: the triple product over `SL(2,ℤ)` generators is a classical Gauss sum whose value
is already governed by reciprocity theorems near Mathlib's reach. Why now? Mathlib has
`ZMod.gaussSum` and quadratic-character machinery, and we already possess a fully working
`ModularBraiding` and the `chi_orthogonality` kernel, so the abelian `SL(2,ℤ)` rep is the
shortest path from "S unitary + Verlinde" to a complete modular-tensor-category certificate.

Falsifiable prediction: with `θ_a = exp(πi a^2/n)`, `S^2_{a,b} = δ_{a,-b}` should hold
*exactly* for every `n`, and `(ST)^3 = (1/√n ∑_j e^{πi j^2/n}) · S^2`; both are decidable
finite identities for each fixed small `n` and can be `#eval`-checked before the general proof.

### 2. Non-abelian quantum dimensions: `GSD` as `∑_a d_a^{2-2g}` with `d_a > 1`

This cycle proved every *abelian* anyon has `d_a = 1`, so `GSD A g = d^g` with `d = |A|`.
The bold generalization drops commutativity: replace the group `A` by a fusion ring with
non-integer Perron–Frobenius dimensions `d_a` (e.g. the Fibonacci anyon with `d_τ = φ`, the
golden ratio). The conjecture is the **general Verlinde dimension formula**
`dim V(Σ_g) = ∑_a (D / d_a)^{2g-2}`, `D = √(∑_a d_a^2)`, which for Fibonacci gives the
Lucas-number sequence `dim V(Σ_g) = L_{2g}`-type growth rather than a pure power.

The key insight is that `d_a` is the largest eigenvalue of the fusion matrix `N_a`, so the
whole formula is a statement about **simultaneous diagonalization of commuting non-negative
integer matrices by a unitary `S`** — a Perron–Frobenius + spectral-theorem package, not new
physics. Why now? The abelian proof here is exactly this statement with all `N_a` being
permutation matrices (eigenvalue 1); generalizing means swapping "group orthogonality" for
"Perron–Frobenius eigenvector orthogonality", and Mathlib's `Matrix.IsHermitian.spectral_theorem`
and `Matrix.PerronFrobenius` give the needed eigen-decomposition.

Falsifiable prediction: for the Fibonacci fusion ring, `∑_a d_a^{2-2g}` evaluated with
`d_1 = 1, d_τ = φ` should equal a fixed integer (the dimension of the genus-`g` Hilbert
space) for every `g` — directly checkable, and a single non-integer output would refute the
chosen `d_a`.

### 3. Stability: the genus power-law as a robust topological invariant

`GSD A g = d^g` is a number; topological order asserts it is *robust* — invariant under any
local perturbation of the Hamiltonian below the gap. A bold, testable formalization: define a
finite "local deformation" as a sequence of single-handle surgeries and prove that `GSD`
transforms only through `GSD_handle` and `GSD_connected_sum` (already in the catalog), so that
**no finite composition of local moves changes the value `d^g` for fixed topology**. This makes
"topological invariance" a literal Lean theorem about the functor `g ↦ d^g`.

The key insight is that the multiplicative structure already proven (`GSD (g+h) = GSD g · GSD h`,
`GSD (g+1) = d · GSD g`) *is* a TQFT gluing axiom in disguise: a 2D TQFT is a symmetric monoidal
functor, and these two laws are precisely monoidality plus the handle (pair-of-pants) relation.
Why now? Recasting the existing `GSD` lemmas as a `MonoidalFunctor`-style structure is low-risk
formal plumbing that immediately yields a clean "topological invariance" corollary and connects
to Mathlib's category-theory library.

Falsifiable prediction: any candidate `GSD'` satisfying the same handle and connected-sum laws
with `GSD' 0 = 1` must equal `d^g`; a proposed alternative degeneracy function violating this is
impossible — a uniqueness theorem one can attempt directly.

### 4. The Hilbert space of conformal blocks and an explicit S-action on `(Fin g → A) →₀ ℂ`

The catalog identified `GSD A g` with `Module.finrank ℂ ((Fin g → A) →₀ ℂ)`. The next step is to
realize the modular group action *on that concrete Hilbert space*: build the linear operator
`Ŝ : ((Fin g → A) →₀ ℂ) → _` whose matrix in the flat-configuration basis is the `g`-fold tensor
power of `S`, and prove `Ŝ` is unitary using `smatrix_unitary` `g` times.

The key insight is that the genus-`g` mapping-class-group representation **factors as a tensor
power** of the torus (`g=1`) representation for abelian theories — so unitarity on `Σ_g` is just
`g` independent copies of the already-proven `smatrix_unitary`, assembled with
`TensorProduct`/`Finsupp` functoriality. Why now? We have both the finrank identification and the
unitary `S`; the only missing ingredient is the tensor-power bookkeeping, which Mathlib's
`Finsupp` and `TensorProduct` APIs supply.

Falsifiable prediction: `Ŝ` defined as the `g`-fold Kronecker power of `S` satisfies
`Ŝ Ŝ† = 1` on the `d^g`-dimensional space, and its trace equals `(∑_a S_{a,a})^g` — a closed
form testable per `(A, g)`.

### 5. Cross-domain bridge: anyon S-matrix unitarity ⇒ MacWilliams duality for group codes

The catalog contains `Physics.QuantumMacWilliams` (MacWilliams identities via Krawtchouk
transforms). The discrete-Fourier S-matrix proven unitary here, `S_{a,b} = (1/√n) e^{2πi ab/n}`,
*is* the finite Fourier transform underlying the MacWilliams identity for `ZMod n`-linear codes.
The bridge conjecture: the MacWilliams transform of a `ZMod n` group code's complete weight
enumerator equals the `S`-conjugation of its dual enumerator, with `smatrix_unitary` /
`chi_orthogonality` supplying the inversion `S S† = 1`.

The key insight is that **modular data and coding-theoretic duality share one kernel** —
additive-character orthogonality on a finite abelian group — so anyon unitarity and MacWilliams
inversion are two readings of the same Lean lemma. Why now? Both halves already exist in the
catalog (`chi_orthogonality` here, Krawtchouk/MacWilliams in `QuantumMacWilliams`); the bridge is
a matter of identifying `S` with the weight-enumerator transform and reusing the orthogonality
proof, a high-novelty cross-domain link at low proof cost.

Falsifiable prediction: for a specific `ZMod n` code, applying `S` to its weight enumerator and
back should return the original enumerator (involutivity up to `S^2 = C`), checkable by `#eval`
on small codes; failure would indicate the wrong normalization or character convention.
