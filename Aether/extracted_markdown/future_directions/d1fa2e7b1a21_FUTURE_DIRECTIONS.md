# Future Directions: Long-Time Metastability for Variational Integrators

## Synthesis

The theorems proved in this cycle establish the *abstract* metastability framework: given a shadow energy certificate with exponentially small defect, energy drift is controlled for exponentially long times. This is the combinatorial/algebraic backbone of the theory. The next frontier is the *analytic* engine: constructing shadow energies from first principles, understanding when and why the exponential guarantee breaks down (resonance), and extending the framework to broader classes of systems and observables. The five directions below form a coherent program: Direction 1 supplies the analytic construction, Direction 2 identifies the obstruction (resonance), Direction 3 extends the observable bridge, Direction 4 connects to sampling algorithms, and Direction 5 aims for the grand unification with KAM theory. Each direction feeds directly into the shadow certificate abstraction established here.

---

## Direction 1: Analytic Shadow Energy Construction via Backward Error Analysis

**Conjecture:** For analytic autonomous Lagrangians with symmetric second-order discrete Lagrangians, the formal modified energy expansion Ē_h = E + h²E₂ + h⁴E₄ + ··· has coefficients satisfying |E_{2k}| ≤ M · (2k)! · R^{−2k} for some analyticity radius R > 0 depending on the system and energy shell. Optimizing the truncation at order m = ⌊R/(eh)⌋ yields a shadow energy with one-step defect ≤ A · exp(−R/(eh)) on compact nonresonant shells.

**Test:** For the Kepler problem and harmonic oscillator with Störmer-Verlet:
1. Compute the modified energy coefficients E₂, E₄, ..., E_{2m} numerically using the BCH formula.
2. Verify the factorial growth |E_{2k}| ~ (2k)! · R^{−2k} by fitting.
3. Compare the optimal truncation defect with the empirically measured per-step energy error.
4. Confirm the predicted exp(−R/(eh)) scaling by varying h.

**Impact:** This would complete the full backward error analysis pipeline: from analytic Hamiltonian through formal expansion to certified shadow energy certificate to exponentially long metastability via our Theorem 2.

**Catalog References:** `Physics/LongTimeMetastability.lean`: `ModifiedEnergyExpansion`, `modified_energy_truncation_drift`, `ShadowEnergyCertificate`

**Proof Strategy:** Formalize the BCH (Baker-Campbell-Hausdorff) formula for the composition of near-identity symplectic maps. Define the formal power series for modified Hamiltonians. Prove coefficient bounds using Cauchy estimates on complexified flows. Use `ModifiedEnergyExpansion` with optimized m to construct a `ShadowEnergyCertificate`.

**Domain Bridges:** Complex analysis (Cauchy estimates) ↔ Geometric integration (shadow Hamiltonians) ↔ Formal power series (asymptotic analysis)

**Lineage:** Builds directly on `modified_energy_truncation_drift` and `ShadowEnergyCertificate`

**Ambition:** 🔴 Grand challenge — requires substantial new infrastructure for formal power series and complex analysis in the formalization

---

## Direction 2: Resonance Breakdown and Polynomial Metastability Windows

**Conjecture:** Near resonant energy shells where the frequency vector ω satisfies |⟨k, ω⟩| < γ/|k|^τ for some integer vector k with |k| ≤ N_res, the analyticity width σ in the shadow energy certificate degrades as σ ~ γ^{1/τ} · dist(ω, resonance)^{1/τ}. Consequently, the exponential plateau degrades to a polynomial metastability window T ~ h^{−(2τ+2)}, and the energy drift can reach O(h^{2/(τ+1)}) within this window.

**Test:**
1. Simulate the Hénon-Heiles system at energies approaching the 1:1 resonance (E → 1/6).
2. Measure the plateau duration T(E) as a function of distance from resonance.
3. Fit T vs. |E - E_res|^{−α} and compare α with the predicted 1/τ.
4. Compare energy drift amplitude with the predicted scaling in h.

**Impact:** Identifies the precise obstruction to exponential metastability and provides quantitative predictions for when symplectic integrators lose their long-time advantage. Critical for understanding simulation fidelity near resonances in celestial mechanics and molecular dynamics.

**Catalog References:** `Physics/LongTimeMetastability.lean`: `energy_drift_plateau_on_exponential_window`, `ShadowEnergyCertificate` (specifically the σ_pos field)

**Proof Strategy:** Define `NonResonantShell` with Diophantine condition. Prove that on such shells, the normal-form transformation has controlled denominators. Show that the resulting σ depends continuously on the Diophantine constants. For the degradation near resonance, use the theory of resonant normal forms.

**Domain Bridges:** Number theory (Diophantine approximation) ↔ Dynamical systems (KAM/Nekhoroshev) ↔ Numerical analysis (symplectic integrators)

**Lineage:** Extends `energy_drift_plateau_on_exponential_window` by parameterizing σ in terms of nonresonance conditions

**Ambition:** 🟡 Solid extension — the Diophantine framework is well-understood informally

---

## Direction 3: Observable Stability for Correlation Functions and Transport Coefficients

**Conjecture:** For any bounded, Lipschitz function F : ℝ^d → ℝ depending on phase-space coordinates through the energy, the two-time correlation function C(t) = ⟨F(x_0) F(x_t)⟩ − ⟨F⟩² computed along a numerical trajectory of a symplectic integrator satisfies |C_num(t) − C_exact(t)| ≤ L² · δ(h) for t within the metastability window, where δ(h) is the energy drift bound.

**Test:**
1. Compute the velocity autocorrelation function for a Lennard-Jones fluid with Störmer-Verlet.
2. Compare with high-accuracy reference values from very small timestep simulations.
3. Verify that the error scales as O(h²) and remains flat within the predicted metastability window.
4. Test with the diffusion coefficient (integral of velocity autocorrelation).

**Impact:** Extends the Lipschitz observable theorem from single-point observables to two-time correlation functions, which are the foundation of linear response theory and transport coefficients in statistical mechanics.

**Catalog References:** `Physics/LongTimeMetastability.lean`: `lipschitz_observable_time_average_control`

**Proof Strategy:** Extend `lipschitz_observable_time_average_control` to product observables F(x_k) · G(x_{k+m}). Use the orbit invariance and energy metastability to control both factors independently. The key new ingredient is bounding the joint error using bilinearity.

**Domain Bridges:** Statistical mechanics (correlation functions, transport) ↔ Geometric integration (symplectic methods) ↔ Functional analysis (Lipschitz spaces)

**Lineage:** Direct generalization of `lipschitz_observable_time_average_control`

**Ambition:** 🟢 Solid extension with clear path

---

## Direction 4: HMC Shadow Acceptance and Bias Control

**Conjecture:** For Hamiltonian Monte Carlo with a symmetric symplectic integrator of step size h and trajectory length L, the expected acceptance probability satisfies |E[α(L)] − E[α(∞)]| ≤ C₁ · L · exp(−σ/h) for L within the metastability window, where α(L) = min(1, exp(−ΔH_L)) is the Metropolis acceptance probability and ΔH_L is the energy error after L steps. Moreover, the bias in expectations of target observables is O(h²) uniformly over exponentially long chains.

**Test:**
1. Run HMC on a 10-dimensional Gaussian with varying L ∈ {10, 100, 1000, 10000}.
2. Track acceptance rate, effective sample size, and bias in mean/variance estimates.
3. Verify acceptance rate stability as L grows (predicted by metastability).
4. Compare bias scaling with O(h²) prediction.

**Impact:** Provides the first certified error bounds for HMC that are valid for long trajectories and long chains simultaneously. Currently, HMC theory bounds the bias for fixed L or the energy error for fixed chain length, but not both together. The metastability framework unifies these.

**Catalog References:** `Physics/LongTimeMetastability.lean`: `energy_drift_exponentially_long`, `lipschitz_observable_time_average_control`, `energy_drift_plateau_on_exponential_window`

**Proof Strategy:** Model HMC as a Markov chain where each transition involves an L-step symplectic trajectory. Use `energy_drift_plateau_on_exponential_window` to bound ΔH_L. Use `lipschitz_observable_time_average_control` (with F = exp(−·) as a Lipschitz observable of energy error) to control the acceptance probability average.

**Domain Bridges:** Bayesian statistics (MCMC) ↔ Geometric integration ↔ Statistical mechanics (detailed balance, ergodicity)

**Lineage:** Combines `energy_drift_plateau_on_exponential_window` with `lipschitz_observable_time_average_control`

**Ambition:** 🟡 Moderate — requires connecting the discrete mechanics framework to the MCMC literature

---

## Direction 5: Discrete KAM Certification — Machine-Checkable Confinement Regions

**Conjecture:** For integrable Hamiltonian systems with d degrees of freedom, there exists a computable procedure that, given:
- A symplectic integrator with step size h
- An energy shell E₀ with frequency vector ω₀
- A Diophantine constant (γ, τ)

produces a machine-checkable certificate that all orbits starting within a computed neighborhood of the shell remain within an O(h²)-neighborhood of the shell for at least exp(c · γ^{1/τ} / h) steps, where c is an explicit computable constant.

**Test:**
1. For the 2D harmonic oscillator with frequencies (1, √2) (strongly nonresonant):
   - Compute the certified confinement region.
   - Verify by numerical integration that no orbit escapes.
   - Compare the certified lifetime with the actual measured lifetime.
2. For the 2D oscillator with frequencies (1, 1.001) (near resonance):
   - Show that the certified region shrinks dramatically.
   - Verify that orbits do exhibit larger drift.

**Impact:** This would be the first instance of *computer-assisted KAM theory for numerical integrators*: a machine-verified proof that specific numerical orbits of specific systems are confined to specific regions for specific times. It would represent a paradigm shift in certified scientific computing.

**Catalog References:** `Physics/LongTimeMetastability.lean`: `ShadowEnergyCertificate`, `ExponentiallyMetastableEnergy`, `energy_drift_plateau_on_exponential_window`. Also `Catalog/Physics/DiscreteNoetherShadow.lean`: `discrete_momentum_conserved`, `discrete_momentum_conserved_range`.

**Proof Strategy:**
1. Formalize `NonResonantShell` with explicit Diophantine data.
2. Construct shadow energy certificates on nonresonant shells using the analytic BEA from Direction 1.
3. Combine with `energy_drift_plateau_on_exponential_window` to get certified confinement.
4. Make the construction computational by implementing interval arithmetic for the certificate constants.

**Domain Bridges:** KAM theory ↔ Computer-assisted proofs ↔ Geometric integration ↔ Interval arithmetic ↔ Celestial mechanics

**Lineage:** Grand synthesis of Directions 1 and 2, building on all theorems in the current cycle

**Ambition:** 🔴 Grand challenge — paradigm-shifting if achieved, combining formal verification with computer-assisted analysis in dynamical systems
