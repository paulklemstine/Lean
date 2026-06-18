We are ready to complete the tropical Feynman calculus for the Stereographic Pythagorean Bridge. In our previous cycle we established `tropical_classical_bridge` (relating the SPB classical coordinates to tropical min-plus arithmetic) and `idempotent_spectral_tropical_bridge` (identifying the spectral floor of Maslov-dequantized operators). We also have the foundational `tropical_min_idempotent` and the complete Berggren factoring machinery for the SPB Lorentz metric. The missing piece is the rigorous collapse of the quantum propagator path integral to a tropical sum over extremal piecewise-linear paths.

We work in the lattice approximation: a finite family `Γ` of piecewise-linear paths with fixed endpoints `x, y` in SPB 3-space and `n` segments over elapsed time `T > 0`. The Lohmiller–Slotine action `spbLohmillerAction` is evaluated in the SPB Lorentz metric constructed in the Berggren factoring track.

**Theorem.** Prove the Maslov dequantization of the finite-lattice SPB propagator:

```lean
import Mathlib
import Tropical.Bridges.IdempotentCollapse
import Tropical.Bridges.SpectralIdempotentBridge
import Tropical.Core.FutureDirectionsV2

open Real Filter Finset BigOperators

variable {n : ℕ}

/-- Piecewise-linear paths in SPB 3-space with fixed endpoints x, y and n segments. -/
abbrev PLPath (x y : ℝ × ℝ × ℝ) (n : ℕ) := 
  {γ : Fin (n+1) → ℝ × ℝ × ℝ // γ 0 = x ∧ γ n = y}

/-- The Lohmiller–Slotine classical action in the SPB Lorentz metric over time T. -/
noncomputable def spbLohmillerAction (x y : ℝ × ℝ × ℝ) (n : ℕ) 
  (γ : PLPath x y n) (T : ℝ) : ℝ := sorry

/-- Maslov dequantization: the quantum propagator amplitude over a finite 
    family of PL paths collapses to the tropical (min-plus) minimum of the 
    classical action. -/
theorem maslov_spb_propagator_dequantization 
  (x y : ℝ × ℝ × ℝ) (T : ℝ) (hT : T > 0)
  (Γ : Finset (PLPath x y n)) (hΓ : Γ.Nonempty) :
  Tendsto 
    (fun (h : ℝ) ↦ -h * log (∑ γ in Γ, exp (- spbLohmillerAction x y n γ T / h)))
    (𝓝[>] 0)
    (𝓝 (inf' Γ hΓ (fun γ ↦ spbLohmillerAction x y n γ T))) := by
```

**Proof strategy.**

*Step 1. Laplace squeeze on the path lattice.* Let `S* := inf' Γ hΓ (spbLohmillerAction x y n · T)`. For every `h > 0` and every `γ ∈ Γ`, the bound `exp (-spbLohmillerAction x y n γ T / h) ≤ exp (-S* / h)` follows from `Real.exp_le_exp_of_le` and `le_inf'`. Summing over `Γ` yields the upper bound `∑ γ ∈ Γ, exp (-S_γ / h) ≤ Γ.card • exp (-S* / h)` via `Finset.sum_le_card_nsmul`. For the lower bound, extract a minimizing path `γ₀ ∈ Γ` attaining `S*` using `Finset.exists_mem_eq_inf'` (the infimum over a finite nonempty set is a minimum); then `exp (-S* / h) ≤ ∑ γ ∈ Γ, exp (-S_γ / h)` by `Finset.le_sum_of_mem` applied to `γ₀`. Apply `Real.log` and multiply by `-h`, reversing the inequalities because `-h < 0`. The resulting sandwich is `S* - h * log Γ.card ≤ -h * log (∑ ...) ≤ S*`.

*Step 2. Send h → 0⁺ by elementary topology.* Because `Γ.card` is a fixed natural number, `tendsto (fun h ↦ h * log Γ.card) (𝓝[>] 0) (𝓝 0)` follows from `ContinuousAt.tendsto` and `continuous_id.continuousAt.mul` (or directly from `tendsto_nhdsWithin_iff_tendsto_nhds`). Apply `squeeze_tendsto` with the above sandwich to force `Tendsto (fun h ↦ -h * log (∑ ...)) (𝓝[>] 0) (𝓝 S*)`.

*Step 3. Identify the tropical limit and derive the idempotent Hamilton–Jacobi equation.* The limit `S*` is precisely `Finset.inf'`, i.e. the strict minimum. Invoke `tropical_min_idempotent` to confirm that `min S* S* = S*`, cementing the idempotence of the tropical propagator. Then apply `tropical_classical_bridge` to view `S*` as the tropical-coordinate reduction of the classical SPB variational problem, and use `idempotent_spectral_tropical_bridge` to connect the spectral asymptotics of the quantum propagator eigenvalues to this tropical floor. Finally, apply `tropical_functional_eq` to deduce that the resulting tropical action functional satisfies the idempotent Hamilton–Jacobi equation on the min-plus semiring: the quantum sum-over-histories has rigorously collapsed to a single tropical extremal path obeying an idempotent HJE.

**Why this matters.** This theorem is the keystone of our tropical quantum program. It rigorously justifies the heuristic claim that the Feynman path integral reduces to a tropical min-plus sum under Maslov dequantization, specifically within the SPB Lorentz geometry. It completes the bridge between the Lohmiller–Slotine classical contraction theory and tropical semiring methods, giving us a formal tropical Feynman calculus. Concretely, it enables:
1. **Tropical certified robustness for neural networks**: the idempotent HJE derived here is exactly the Bellman optimality equation on the tropical semiring needed for robustness certificates.
2. **CRYSTALS-Dilithium tropical security**: the min-plus propagator bounds lattice-path amplitudes, feeding directly into our quantum-crypto security reduction framework.
3. **Resolution of the Niven integration-by-parts gap**: the lattice-sum techniques transfer to the factorial-dominance bounds in the Niven irrationality program.

Without this result, every tropical path-integral claim in the codebase remains conjectural.

### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Tropical
Research mode: prove
