# Future Directions — Quantum Topological Phase Computation

The new file `Catalog/Physics/FibonacciAnyonBraiding.lean` makes the Fibonacci
anyon model concrete in Lean 4: it defines the explicit `F`-matrix (`fibF`) and
`R`-matrix (`fibR`) of the smallest universal anyon theory and proves the
structural identities that a braid-group representation must satisfy — `F` is a
traceless symmetric involution with `det F = -1`, `R` is unitary with unit-modulus
determinant, the total quantum dimension squared is `2 + φ`, and, decisively, the
two single-qubit generators `B₁ = R`, `B₂ = F·R·F` satisfy the **Artin braid
relation** `B₁B₂B₁ = B₂B₁B₂` (`fib_braid_relation`). This certifies that the
Fibonacci data assemble into a genuine unitary representation of `B₃`. The
following conjectures push from "well-defined representation" towards the catalog's
still-open `su2_braiding_dense` (in `Speculative.AutoResearch.BraidingUniversality`).

## Direction 1 — The generators land in `SU(2)`, not merely `U(2)`

We proved `fibR_unitary` and `fibR_det_abs` (`‖det R‖ = 1`). The next step is to
normalize the generators so that `det = 1`, i.e. exhibit a global phase `λ` with
`(λ • B₁), (λ • B₂) ∈ SU(2)` as a literal `Matrix.specialUnitaryGroup (Fin 2) ℂ`
membership, and show the braid relation is preserved under this rescaling (it is,
since a scalar is central — compare `burau_fullTwist_central` in the catalog).
**The key insight is** that the braid relation is invariant under multiplying each
generator by the *same* scalar, so universality is a statement about the projective
image `PSU(2)`, and the `det = -1` of `F` cancels against the `R`-phases to give
`det B₂ = det B₁`. **Why now?** With `fib_braid_relation` and `fibR_unitary`
already discharged, the only remaining ingredient is a one-line scalar bookkeeping
lemma, making this the cheapest immediate extension that connects to Mathlib's
existing `Matrix.specialUnitaryGroup` API.

## Direction 2 — Infinite order and the eigenvalue spectrum of `B₁B₂`

Conjecture: the product `B₁B₂ = R·F·R·F` has an eigenvalue that is not a root of
unity, hence has infinite order in `SU(2)`. **The key insight is** that the trace
`tr(B₁B₂)` is an algebraic number in `ℚ(φ, e^{iπ/5})` whose value `2cos θ`
determines the rotation angle `θ`; infinite order is equivalent to `θ/π ∉ ℚ`, a
statement provable with the irrationality machinery already present
(`golden_ratio_irrational`, `irrational_phase_injective`). **Why now?** The catalog
already contains `phaseGate_orbit_dense` (density of irrational rotations) and
`rational_phase_finite_order`; computing `tr(B₁B₂)` explicitly from `fibF`/`fibR`
and feeding it into those lemmas is a direct, mechanizable bridge from our concrete
matrices to a dynamical density statement.

## Direction 3 — A formal pentagon/hexagon consistency proof

We used `fibF_involutive` as a stand-in for the pentagon equation. The full
program is to define the Fibonacci fusion category data abstractly (objects `{1, τ}`
with `τ⊗τ = 1 ⊕ τ`) and prove that `fibF` and `fibR` *solve* the pentagon and
hexagon equations, with `tau_mul_succ` (`τ(τ+1)=1`) emerging as a corollary rather
than an input. **The key insight is** that the pentagon equation for a single
self-dual object reduces to exactly the `2×2` matrix identity `F² = 1` plus a sign
constraint, so our involution theorem is already the analytic heart — what remains
is the categorical scaffolding. **Why now?** Mathlib's `CategoryTheory.Monoidal`
and braided-category libraries are mature enough to host the fusion category, and
our verified matrix identities give a concrete model to test the abstract axioms
against, preventing vacuous formalizations.

## Direction 4 — Solovay–Kitaev compilation with certified error bounds

The catalog states `solovay_kitaev_depth_bound` abstractly. Conjecture: for the
concrete Fibonacci generators of this file, every target `U ∈ SU(2)` admits a braid
word `w` of length `O(log^c(1/ε))` with `‖ρ(w) − U‖ < ε`, where `ρ` is the
representation `BraidRep₂.eval` built from `B₁, B₂`. **The key insight is** that
density (Direction 2) plus the *exact* unitarity proved here (`fibR_unitary`) lets
the Solovay–Kitaev recursion run with rigorously tracked Frobenius-norm error,
turning the catalog's `frobeniusNormSq` lemmas into genuine convergence
certificates. **Why now?** All three prerequisites — unitary generators, a length
metric on braid words (`braidWord_compose_length`), and the SK depth recursion —
already exist in the catalog; this direction stitches them into the first
end-to-end *certified* topological-gate compiler.

## Direction 5 — Generalization to `SU(2)_k` for `k ≥ 3`

Conjecture: replacing the golden ratio by the quantum dimension
`d = 2cos(π/(k+2))` yields an `F`-matrix `F_k = !![1/d, √(1−1/d²); √(1−1/d²), −1/d]`
that is *still an involution* for every `k ≥ 1`, and the associated braid
generators are unitary; universality (density) holds exactly when `k ∉ {1,2,4}`.
**The key insight is** that the involution identity generalizes from `τ(τ+1)=1` to
`(1/d)² + (1 − 1/d²) = 1`, which is a trivial algebraic identity, so `F_k² = 1`
holds *unconditionally* — the arithmetic of `k` enters only through the braiding
phases and the density question, not the F-matrix structure. **Why now?** Our
`fibF_involutive` proof is phrased through the single lemma `tau_mul_succ`;
abstracting that one lemma to the `SU(2)_k` quantum dimension immediately produces
a parameterized family of theorems, and the failure cases `k ∈ {1,2,4}` give
sharp, falsifiable boundary tests (the Jones/Ising anyons), connecting directly to
`cyclotomic` and knot-spectrum results already in the `Tropical` catalog.
