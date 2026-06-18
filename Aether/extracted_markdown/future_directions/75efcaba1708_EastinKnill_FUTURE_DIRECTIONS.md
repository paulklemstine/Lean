# Future Directions: The Eastin–Knill No-Go Theorem

The file `Computation/EastinKnill.lean` isolates the *algebraic kernel* of the
Eastin–Knill theorem in a fully rigorous, `sorry`-free, finite-dimensional matrix
setting over `ℂ`. A code is a Hermitian projector `P`; an operator is *detectable*
with scalar `c` when `P A P = c • P` (the compressed Knill–Laflamme condition).
The headline results are that detectable operators form a scalar-valued
linear/sum-closed family, that a transversal generator (a finite sum of detectable
single-site terms) compresses to a scalar `(∑ cᵢ)•P`, and that such generators are
**central** in the logical operator algebra — the precise obstruction to logical
universality (`eastin_knill_transversal_central`). The boundary theorem
`logical_noncentral_without_detection` shows the detection hypothesis is essential.

Below are five testable, falsifiable directions that extend this kernel toward the
full theorem and beyond.

## 1. From centrality to a genuine group-theoretic discreteness statement

The current `detectable_logical_central` proves the logical generator commutes with
*everything*; the next step is to show the connected component of the transversal
**gate group** acts trivially on the code, i.e. is contained in the global-phase
subgroup. Formalize a one-parameter family `t ↦ exp(t • (-I • A))` of unitaries and
prove that `P · exp(tA) · P = exp(t c) • P` whenever `A` is detectable, by
differentiating the matrix exponential and invoking `detectable_logical_central` at
the Lie-algebra level. **The key insight is** that commutation of the *generator*
with the whole logical algebra upgrades, via the Baker–Campbell–Hausdorff series, to
the *gate* acting as a pure phase — turning an infinitesimal statement into a global
one. **Why now?** Mathlib now has `NormedSpace.exp` with `exp_add` for commuting
elements and matrix-exponential derivative lemmas, so the analytic upgrade that was
previously out of reach is finally tractable on top of the algebraic core proved here.

## 2. Tensor-product realization of "single-site" detectability

We axiomatized single-site terms abstractly as detectable operators. The deeper claim
is geometric: an operator of the form `1 ⊗ … ⊗ Aᵢ ⊗ … ⊗ 1` acting on one tensor
factor of `(ℂ^d)^{⊗ n}` is *automatically* detectable for any distance-≥2 code.
Build `QECCode` instances from `TensorProduct`/`Matrix.kroneckerMap` and prove that
single-factor operators satisfy `P A P = c • P` directly from the Knill–Laflamme
distance condition. **The key insight is** that distance ≥ 2 is exactly the statement
that the code "cannot see" any single tensor factor, which is what forces the scalar
compression — so detectability is not an extra hypothesis but a *consequence* of code
distance. **Why now?** With the abstract centrality argument already discharged, the
only remaining gap to a textbook-faithful statement is this kronecker-product lemma,
which is pure linear algebra and ideally suited to the matrix API used here.

## 3. Quantitative / approximate Eastin–Knill

Real codes only *approximately* satisfy `P A P = c • P`. Define
`ApproxDetectable Q A c ε := ‖P A P − c • P‖ ≤ ε` and prove a stability theorem:
the logical commutator `‖[P A P, P B P]‖` is bounded by `2 ε ‖B‖` (a Lipschitz
version of `detectable_logical_central`), so near-detectable transversal generators
are *near*-central. **The key insight is** that the exact algebraic identity used in
`detectable_logical_central` degrades *linearly* in the detection error, which
quantifies exactly how much logical non-commutativity (hence computational power) a
code can buy per unit of detection violation — the modern "approximate QEC" refinement
of Eastin–Knill. **Why now?** Mathlib's matrix operator-norm and `‖·‖` sub-multiplicativity
lemmas make these inequalities provable, and the exact `ε = 0` case is already in hand
to anchor the bound.

## 4. Covariance and the Wigner–Araki–Yanase connection

Eastin–Knill is the discrete shadow of the Wigner–Araki–Yanase theorem: a conserved
*additive* charge `Q = ∑ Qᵢ` (a transversal Hamiltonian) cannot be measured/implemented
covariantly with perfect accuracy on a code. Formalize the charge as a
`TransversalGenerator`, prove `P Q P = (∑ cᵢ) • P` via `eastin_knill_transversal_scalar`,
and derive that the code carries *no* nontrivial logical charge — a clean no-go for
covariant codes. **The key insight is** that additivity of the conserved quantity is
*precisely* the `detectable_sum` closure we already proved, so charge conservation and
transversality are the same algebraic phenomenon viewed from two physical angles.
**Why now?** The summation lemma is done; only the (short) identification of the
physical charge with a transversal generator remains, making this a high-yield, low-cost
cross-domain bridge between quantum computation and quantum measurement theory.

## 5. Escaping the no-go: locating the largest non-central transversal subalgebra

The boundary theorem shows that *without* detection the logical algebra can be the full
(non-commutative) matrix algebra. Interpolate: for a code of distance exactly `d`,
characterize the maximal set of operators that remain detectable, and conjecture that
the transversal logical gates form precisely the normalizer of the stabilizer modulo
phases — a *finite* group whose order is computable from the code parameters.
**The key insight is** that the gap between "central/abelian" (perfect code) and "full
matrix algebra" (no code) is governed by a single integer, the code distance, so the
size of the achievable transversal gate set should be an explicit function of `(n, k, d)`.
**Why now?** With both extreme cases (`eastin_knill_transversal_central` and
`logical_noncentral_without_detection`) formalized, the project has the two endpoints
needed to state and test the interpolating conjecture computationally on small
stabilizer codes before attempting a general proof.
