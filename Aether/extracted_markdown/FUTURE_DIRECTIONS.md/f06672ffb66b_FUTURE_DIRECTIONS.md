# Future Directions — Spectral Universality of Arithmetic Quantum Graphs via Hecke Commutants

## Synthesis

The conjecture driving this cycle — that the unfolded level-spacing statistics of
arithmetic quantum graphs converge to GOE *iff* there is no nontrivial Hecke
symmetry commuting with the lifted Laplacian — is, at its analytic core, an open
empirical statement. But it rests on a sharp **algebraic dichotomy** that is not
open at all, and that this cycle proves in full (sorry-free) in
`Catalog/Cryptography/SpectralHeckeCommutant.lean`.

Working in the eigenbasis of the (self-adjoint) Laplacian after unfolding — where
`L = diagonal d`, with `d` the spectrum — the entire arithmetic/analytic apparatus
collapses to a single field-theoretic identity, `M i j · (d i − d j) = 0`, for any
operator `M` commuting with `L`. From this we extract:

- `commute_diagonal_simple_isDiag`: a **simple spectrum** (level repulsion, the GOE
  regime) forces every commuting operator to be diagonal — a *function of the
  Laplacian*.
- `commute_offdiag_imp_degenerate` and its converse witness
  `degenerate_has_nontrivial_symmetry`: a **nontrivial commuting symmetry exists
  exactly on a degenerate level**. Degeneracy is the *only* gateway for symmetry.
- `simple_spectrum_iff_commutant_isDiag`: the exact biconditional — spectral
  simplicity ⇔ triviality of the commutant.
- `commutant_isAbelian_of_simple` and `commute_iff_function_of_spectrum`: the
  commutant ("Hecke algebra") of a non-degenerate Laplacian is the **abelian
  algebra of functions of the spectrum** — a finite-dimensional bicommutant theorem.

This is the precise sense in which "symmetry breaking" and "GOE-type level
repulsion" are two faces of one coin: GOE requires a simple spectrum, and a simple
spectrum is logically equivalent to having no nontrivial commuting (Hecke) symmetry.

### Catalog synthesis

The kernel sits naturally beside the catalog's expander/Cayley-graph machinery —
e.g. `Algebra/ClassicalGroupExpanders.lean` (`classical_certificate_no_proper_invariant_submodule`,
`vertex_expansion_implies_generates`) and `Algebra/ExpanderWalk/Amplification.lean` —
which build the *graphs* whose Laplacians these theorems analyze, and beside the
Satake/Hecke-flavored files in `Tropical/SatakeIsomorphism.lean` and
`EML/ModularForms.lean`, which supply the arithmetic Hecke operators that are the
intended commuting symmetries. The commutant theorems here are the spectral-theory
bridge between those two catalog domains.

## Research Directions

### 1. From "diagonal commutant" to the full bicommutant over a general self-adjoint operator
We proved the commutant of a *diagonal* `L` with simple spectrum is the algebra of
functions of `L`. The next step is to drop the eigenbasis assumption: for a
genuinely self-adjoint (Hermitian) matrix over `ℝ`/`ℂ` with simple spectrum, prove
the commutant equals `{ p(L) : p ∈ K[X] }` via the spectral theorem and Lagrange
interpolation. **The key insight is** that simplicity of the spectrum makes the
minimal polynomial equal to the characteristic polynomial, so the commutant is
exactly `K[L]`, of dimension `n`. **Why now?** Mathlib already has
`Matrix.IsHermitian.spectral_theorem` and `Lagrange.interpolate`; the diagonal kernel
proved here is precisely the post-diagonalization payload, so the remaining work is a
basis change plus interpolation — a well-scoped, falsifiable target.

### 2. Quantitative degeneracy: counting commuting symmetries via spectral multiplicities
Refine the boolean dichotomy into a dimension count: the dimension of the commutant
of `diagonal d` should equal `∑ λ (mult λ)²`, where `mult λ` is the multiplicity of
eigenvalue `λ`. **The key insight is** that the commutant decomposes as a block-
diagonal algebra `⊕_λ M_{mult λ}(K)`, so its dimension is the sum of squared
multiplicities — minimized (`= n`) exactly when the spectrum is simple. **Why now?**
The single-entry witnesses (`single i j 1`) constructed here already form an explicit
basis of each degenerate block; assembling them into a basis of the whole commutant
is a direct, testable extension that turns "GOE vs not" into a graded invariant.

### 3. Spectral gap stability of the symmetry diagnostic under expander lifts
Combine with the catalog's expander certificates: if a base Cayley graph has simple
Laplacian spectrum and an `ε`-spectral gap, ask whether a *random* Ramanujan-type
2-lift preserves spectral simplicity with high probability. **The key insight is**
that a lift's new eigenvalues are the eigenvalues of a signed adjacency operator, and
generic signings break any accidental degeneracy — so simplicity (hence the GOE
regime) is the *typical* outcome, with degeneracy confined to lifts respecting a
deck symmetry. **Why now?** Bilu–Linial-style 2-lifts and the catalog's expander
amplification lemmas give a concrete probabilistic model, making "simplicity is
generic, degeneracy is symmetric" a sharply falsifiable claim.

### 4. Hecke-operator commutation as an arithmetic obstruction certificate
Promote `commute_offdiag_imp_degenerate` into a *certificate*: a single nonzero
off-diagonal entry of an arithmetic Hecke operator `T_p`, written in the Laplacian
eigenbasis, certifies a spectral degeneracy and hence a deviation from GOE.
**The key insight is** that detecting non-GOE behaviour reduces to a *finite,
exact* algebraic check (one nonzero off-diagonal entry of a commuting `T_p`), rather
than a statistical test on level spacings. **Why now?** The catalog's Satake/Hecke
files (`Tropical/SatakeIsomorphism.lean`, `EML/ModularForms.lean`) give explicit
Hecke operators; pairing them with the commutant test yields a number-theoretic
diagnostic that is computable in finite, certified arithmetic — directly serving the
concept's "transfer symmetry diagnostics into computational spectral theory" goal.

### 5. Pseudorandom spectral objects from provably trivial commutants
Use the equivalence to *design* operators whose commutant is provably trivial, as a
source of "spectrally pseudorandom" objects for cryptographic constructions.
**The key insight is** that a constructible family with `Function.Injective d`
(e.g. eigenvalues at distinct field elements) has, by `commutant_isAbelian_of_simple`
and `commute_iff_function_of_spectrum`, *no hidden linear symmetry* beyond functions
of the operator itself — exactly the rigidity one wants from a pseudorandom permutation-
like primitive. **Why now?** The catalog already targets expander-based cryptography
(`Algebra/ClassicalGroupExpanders.lean`, `Cryptography/*`); a certified
"no-nontrivial-symmetry" guarantee is a reusable building block for arguing
indistinguishability of spectral primitives, and the proof obligation is now a single
injectivity check.
