import Mathlib
import Physics.Quantum.Hydrogen.Defs

/-!
# Hydrogen Atom: Spectral Theory

Spectral properties of hydrogen energy levels: Rydberg formula,
spectral series convergence, and connections to number theory.

## Main Results

* `transition_energy_positive`: All emission transitions release positive energy
* `rydberg_formula_symmetric`: Rydberg formula in symmetric form
* `lyman_alpha_energy`: Lyman-α has energy 3/4
* `hydrogen_spectrum_gap_formula`: Gap formula (2n+1)/(n²(n+1)²)
* `hydrogen_energy_sum_telescoping_bound`: Connection to Basel problem
* `hydrogen_degeneracy`: Sum of odd numbers = n²
* `hydrogen_total_states`: Sum of squares formula
-/

noncomputable section

open Finset BigOperators Filter Real

/-! ## Rydberg Formula -/

/-- The Rydberg formula: photon energy equals the difference of reciprocal squares. -/
theorem rydberg_formula (t : HydrogenTransition) :
    t.photonEnergy = 1 / ((t.n_lower : ℝ) ^ 2) - 1 / ((t.n_upper : ℝ) ^ 2) := rfl

/-
All emission transitions release positive energy.
-/
theorem transition_energy_positive (t : HydrogenTransition) :
    0 < t.photonEnergy := by
  exact sub_pos_of_lt ( by gcongr ; exact t.h_order )

/-
The Rydberg formula in symmetric form using field_simp and ring.
-/
theorem rydberg_formula_symmetric (t : HydrogenTransition) :
    t.photonEnergy * ((t.n_lower : ℝ) ^ 2 * (t.n_upper : ℝ) ^ 2) =
      (t.n_upper : ℝ) ^ 2 - (t.n_lower : ℝ) ^ 2 := by
  convert congr_arg ( fun x : ℝ => x * ( t.n_lower ^ 2 * t.n_upper ^ 2 ) ) ( rydberg_formula t ) using 1 ; ring;
  simp +decide [ mul_assoc, mul_comm, mul_left_comm, ne_of_gt ( PNat.pos _ ) ]

/-! ## Spectral Series Energies -/

/-
The Lyman-α transition (n=2 → n=1) has energy 3/4.
-/
theorem lyman_alpha_energy :
    (lymanSeries 0).photonEnergy = 3 / 4 := by
  norm_num [ lymanSeries, HydrogenTransition.photonEnergy ] ;

/-
The Balmer-α transition (n=3 → n=2) has energy 5/36.
-/
theorem balmer_alpha_energy :
    (balmerSeries 0).photonEnergy = 5 / 36 := by
  unfold HydrogenTransition.photonEnergy balmerSeries; norm_num;

/-
The Paschen-α transition (n=4 → n=3) has energy 7/144.
-/
theorem paschen_alpha_energy :
    (paschenSeries 0).photonEnergy = 7 / 144 := by
  -- By definition of `paschenSeries`, the photon energy for the transition from n=4 to n=3 is given by the Rydberg formula.
  unfold paschenSeries
  norm_num [ HydrogenTransition.photonEnergy ]

/-! ## Spectral Gap Between Consecutive Levels -/

/-- The energy gap between consecutive hydrogen levels n and n+1. -/
def hydrogenSpectralGap (n : ℕ+) : ℝ :=
  hydrogenEnergy ⟨n + 1, by omega⟩ - hydrogenEnergy n

/-
The spectral gap formula: ΔE_{n,n+1} · n²(n+1)² = 2n+1.
-/
theorem hydrogen_spectrum_gap_formula (n : ℕ+) :
    hydrogenSpectralGap n * ((n : ℝ) ^ 2 * ((n : ℝ) + 1) ^ 2) = 2 * (n : ℝ) + 1 := by
  unfold hydrogenSpectralGap hydrogenEnergy;
  -- Simplify the expression using algebraic manipulation.
  field_simp
  ring;
  norm_num ; ring

/-! ## Degeneracy and State Counting -/

/-
The degeneracy of level n is n². Sum-of-odd-numbers identity by induction.
-/
theorem hydrogen_degeneracy (n : ℕ) :
    ∑ l ∈ Finset.range n, (2 * l + 1) = n ^ 2 := by
  induction n <;> simpa [ Finset.sum_range_succ ] using by linarith;

/-
Sum of squares formula by induction.
-/
theorem hydrogen_total_states (N : ℕ) :
    6 * ∑ k ∈ Finset.range N, (k + 1) ^ 2 = N * (N + 1) * (2 * N + 1) := by
  exact Nat.recOn N ( by norm_num ) fun k ih => by norm_num [ Finset.sum_range_succ ] at * ; linarith;

/-! ## Point Spectrum Characterization -/

/-- The hydrogen point spectrum. -/
def hydrogenPointSpectrum : Set ℝ :=
  {E : ℝ | ∃ n : ℕ+, E = hydrogenEnergy n}

/-- The point spectrum is exactly {-1/n² : n ∈ ℕ₊}. -/
theorem hydrogen_point_spectrum_explicit :
    hydrogenPointSpectrum = {E : ℝ | ∃ n : ℕ+, E = -1 / ((n : ℝ) ^ 2)} := rfl

/-
The point spectrum is countable.
-/
theorem hydrogen_spectrum_countable : Set.Countable hydrogenPointSpectrum := by
  exact Set.countable_range ( fun n : ℕ+ => -1 / ( n : ℝ ) ^ 2 ) |> Set.Countable.mono fun x hx => by cases hx; aesop;

/-- Every element of the point spectrum is negative. -/
theorem hydrogen_spectrum_neg (E : ℝ) (hE : E ∈ hydrogenPointSpectrum) : E < 0 := by
  obtain ⟨n, rfl⟩ := hE
  exact hydrogenEnergy_neg n

/-- The ground state energy is -1. -/
theorem hydrogen_ground_state_energy : hydrogenEnergy 1 = -1 := by
  unfold hydrogenEnergy; norm_num

/-
No energy lies below the ground state.
-/
theorem hydrogen_no_energy_below_ground (E : ℝ) (hE : E ∈ hydrogenPointSpectrum) :
    -1 ≤ E := by
  obtain ⟨ n, hn ⟩ := hE;
  exact hn.symm ▸ le_trans ( by norm_num [ hydrogen_ground_state_energy ] ) ( hydrogenEnergy_strictMono.monotone <| PNat.one_le _ )

/-- The spectral gap between ground and first excited state is 3/4. -/
theorem hydrogen_spectral_gap_ground :
    hydrogenEnergy 2 - hydrogenEnergy 1 = 3 / 4 := by
  unfold hydrogenEnergy; norm_num

/-- The full hydrogen spectrum: σ(H) = {-1/n² : n ∈ ℕ₊} ∪ [0, ∞). -/
def hydrogenFullSpectrum : Set ℝ :=
  hydrogenPointSpectrum ∪ Set.Ici 0

/-
No energy in the point spectrum lies strictly between consecutive bound states.
-/
theorem hydrogen_spectrum_gap_between_levels (N : ℕ+) (E : ℝ)
    (hE : E ∈ hydrogenPointSpectrum) :
    ¬(hydrogenEnergy (N + 1) < E ∧ E < hydrogenEnergy N) := by
  rcases hE with ⟨ n, rfl ⟩;
  simp +decide [ hydrogenEnergy, div_lt_div_iff₀ ];
  intro h; rw [ div_lt_div_iff₀ ] at h <;> norm_cast at * <;> norm_num at *;
  exact Nat.pow_le_pow_left ( show ( N : ℕ ) ≤ n from by nlinarith ) 2

/-! ## Cross-Domain: Hydrogen Spectrum and Number Theory -/

/-- Partial sum of |E_k| = 1/k² for k = 1 to n. The limit as n → ∞
is ζ(2) = π²/6, connecting atomic physics to number theory. -/
def hydrogenEnergyPartialSum (n : ℕ) : ℝ :=
  ∑ k ∈ Finset.range n, 1 / ((k + 1 : ℝ) ^ 2)

/-
**Cross-domain theorem**: ∑_{k=1}^{n} 1/k² ≤ 2 - 1/n for n ≥ 1.
Connects hydrogen energy levels to the Basel problem.
-/
theorem hydrogen_energy_sum_telescoping_bound (n : ℕ) (hn : 0 < n) :
    hydrogenEnergyPartialSum n ≤ 2 - 1 / (n : ℝ) := by
  induction' hn with n hn ih <;> norm_num [ Finset.sum_range_succ ] at *;
  · exact le_of_eq ( by unfold hydrogenEnergyPartialSum; norm_num );
  · unfold hydrogenEnergyPartialSum at *; norm_num [ Finset.sum_range_succ ] at *;
    nlinarith [ inv_pos.mpr ( by positivity : 0 < ( n : ℝ ) ), inv_pos.mpr ( by positivity : 0 < ( n + 1 : ℝ ) ), mul_inv_cancel₀ ( by positivity : ( n : ℝ ) ≠ 0 ), mul_inv_cancel₀ ( by positivity : ( n + 1 : ℝ ) ≠ 0 ), mul_inv_cancel₀ ( by positivity : ( n + 1 : ℝ ) ^ 2 ≠ 0 ) ]

/-! ## Falsifiable Conjecture -/

/-- The spectral gap ratio between consecutive levels. -/
def spectralGapRatio (n : ℕ+) : ℝ :=
  hydrogenSpectralGap n / hydrogenSpectralGap ⟨n + 1, by omega⟩

/-
**Testable prediction**: For n=1, gap(1)/gap(2) should equal 27/5.
gap(1) = E₂ - E₁ = -1/4 - (-1) = 3/4.
gap(2) = E₃ - E₂ = -1/9 - (-1/4) = 5/36.
Ratio = (3/4)/(5/36) = (3/4)·(36/5) = 108/20 = 27/5.
-/
theorem spectral_gap_ratio_test :
    spectralGapRatio 1 = 27 / 5 := by
  norm_num [ spectralGapRatio, hydrogenSpectralGap, hydrogenEnergy ] ;

end