# Future Directions: Formal Yang–Mills Mass Gap Program

## Direction 1: Uniform Lattice Gap Hypothesis

**Conjecture.** For every compact simple Lie group G and every Wilson-action lattice gauge theory on a sequence of hypercubic lattices Λ_n ⊂ ℝ⁴ with spacing a_n → 0, there exists a universal constant c(G) > 0 such that the spectral gap gap(H_n) of the transfer-matrix Hamiltonian H_n satisfies gap(H_n) ≥ c(G) for all n, after appropriate renormalization of the coupling constant.

**Test.** Formalize the Wilson action for G = SU(2) on a 2×2×2×2 lattice (Fin 2 for each dimension) and compute the transfer matrix numerically. Extract the spectral gap. Repeat for 3×3×3×3 and 4×4×4×4. If the gaps (after coupling renormalization) decrease without apparent lower bound, the conjecture is refuted for that renormalization scheme.

**Why it matters.** Our theorem `uniform_lattice_gap_persists_under_refinement` and `lattice_gap_infimum_positive` provide the formal infrastructure to certify this statement once the gap sequence is computed. A verified uniform bound would constitute a major milestone toward the Clay Yang–Mills problem: it would reduce the full conjecture to a continuum limit existence argument.

---

## Direction 2: Gauge-Minimizer Rigidity Hypothesis

**Conjecture.** Let H be a gauge-invariant Hamiltonian on a finite lattice gauge configuration space with compact gauge group G. If the vacuum configuration v₀ (global minimizer of the energy functional) is unique up to gauge equivalence, and the Hessian of the energy at v₀ restricted to the gauge-orthogonal complement has smallest eigenvalue λ₁ > 0, then the full quantum Hamiltonian has a spectral gap of at least λ₁/2.

**Test.** Formalize the discrete Hessian for a diagonal Hamiltonian (using `diagonal_hamiltonian`) with a non-degenerate vacuum. Compute the Hessian eigenvalues using `#eval` on a concrete Fin n → ℝ energy function. Verify whether the quantum spectral gap (from `diagonal_hamiltonian_mass_gap`) matches or exceeds λ₁/2 in all tested cases with n ≤ 20.

**Why it matters.** Our theorem `gauge_energy_minimizer_yields_mass_gap` provides the skeleton: a vacuum with positive excitation bound gives a gap. This conjecture would sharpen the bound to connect classical (Hessian) and quantum (spectral) gap sizes, bridging variational calculus and spectral theory within the same formal framework.

---

## Direction 3: Transfer-Matrix Correlation Decay Hypothesis

**Conjecture.** For a finite lattice gauge model with transfer matrix T and certified spectral gap Δ > 0 (i.e., the ratio of second-largest to largest eigenvalue of T is at most 1 − Δ), the connected two-point correlation function ⟨O(x) O(y)⟩_c decays as |⟨O(x) O(y)⟩_c| ≤ C · e^{−Δ · d(x,y)} for all gauge-invariant observables O with ‖O‖ ≤ 1 and lattice distance d(x,y).

**Test.** Define a toy transfer matrix as a `Matrix (Fin N) (Fin N) ℝ` with known eigenvalues. Define a two-point function as ⟨e_x, T^d e_y⟩ where e_x, e_y are basis vectors. Verify computationally (via `#eval` on ℚ-valued matrices with N = 4, 8) that the correlation decays exponentially with rate matching the spectral gap. If any counterexample is found, the conjecture needs refinement.

**Why it matters.** Exponential correlation decay is physically equivalent to confinement in gauge theories: it means force-carrying gauge bosons are massive. Formalizing this connection in the finite setting would create a machine-checked bridge from spectral gaps (our `has_mass_gap`) to physically measurable confinement criteria.

---

## Direction 4: Expansion-to-Confinement Bridge Hypothesis

**Conjecture.** For a finite lattice gauge theory whose configuration-space graph has spectral expansion parameter λ ≥ 1 − 1/√k (as in our catalog's `spectral_gap_lower_bound`), every Wilson loop observable W(C) for a contractible loop C of area A satisfies |⟨W(C)⟩| ≤ e^{−σ · A} where σ ≥ c · λ for a universal constant c > 0.

**Test.** Define Wilson loop observables on a 2D lattice gauge theory with gauge group ℤ/2ℤ (simplest non-trivial case). Compute ⟨W(C)⟩ for rectangular loops of increasing area using exact enumeration (Fintype). Fit the decay rate σ and compare with the spectral expansion parameter λ of the configuration space. A positive correlation between λ and σ supports the conjecture.

**Why it matters.** This would create the first formal bridge between spectral graph theory (expansion bounds) and lattice gauge theory (area-law confinement). The `spectral_gap_lower_bound` theorem already provides expansion estimates; this conjecture would give those estimates direct physical meaning as confinement criteria.

---

## Direction 5: Optimization-to-QFT Vacuum Hypothesis

**Conjecture.** For any finite lattice gauge theory with plaquette energy functional E and compact gauge group G, the global minimizer of E (whose existence is guaranteed by our `lattice_gauge_vacuum_exists`) is gauge-equivalent to a configuration satisfying the discrete Yang–Mills equations δE/δA_e = 0 for all edges e, and this minimizer can be found by a convergent iterative algorithm (e.g., discrete gradient flow) in at most |V|⁴ · |G|² steps where |V| is the number of vertices.

**Test.** Implement the plaquette energy for G = ℤ/3ℤ on a 3×3 lattice in Python. Run gradient descent (or exhaustive search for this small case) and verify convergence. Check that the minimizer satisfies discrete Euler–Lagrange equations. Compare with the formal minimizer existence from `lattice_gauge_vacuum_exists`.

**Why it matters.** This conjecture connects the formal existence theorem (proof that a vacuum exists) with constructive algorithms (how to find it). If true, it means that the formal infrastructure we built is not merely existential but computationally actionable—opening the door to certified numerical gauge theory where computation and proof work in tandem.
