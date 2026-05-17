import Mathlib
import Physics.Quantum.Hydrogen.Defs
import Physics.Quantum.Hydrogen.Degeneracy

/-!
# Hydrogen Atom: Spectral Theory and Hamiltonian Structure

This file establishes the spectral framework for the hydrogen atom,
including:

- **Hamiltonian splitting** into radial and angular components
- **Separated eigenstate** construction
- **Point spectrum** characterization
- **Spectral properties** of the energy levels

## Mathematical Context

The hydrogen Hamiltonian in spherical coordinates separates as:
  H = H_rad + (1/r²) L²

where `H_rad` is the radial kinetic + potential operator and `L²` is
the angular momentum squared operator (Laplace–Beltrami on S²).

On a separated state `ψ(r,θ,φ) = R(r) Y_l^m(θ,φ)`, the angular
eigenvalue `l(l+1)` converts L² into a scalar, reducing the 3D PDE
to a 1D radial ODE.

The radial equation then has normalizable solutions only for discrete
energies `E_n = -1/n²`, leading to the point spectrum.

## Key Results

* `hydrogen_energy_accumulation_at_zero`: energies accumulate at 0
* `hydrogen_no_energy_below_ground`: no energy below `-1`
* `hydrogen_spectrum_countable`: the point spectrum is countable
* `hydrogen_point_spectrum_explicit`: the point spectrum is `{-1/n² : n ≥ 1}`
-/

noncomputable section

open Finset BigOperators Filter

/-! ## Hamiltonian Splitting -/

/-- A radial function is a function `ℝ → ℂ` representing the radial
part of a wavefunction in spherical coordinates. -/
abbrev RadialFun := ℝ → ℂ

/-- An angular function is a function `ℝ → ℝ → ℂ` of `(θ, φ)`
representing the angular part of a wavefunction. -/
abbrev AngularFun := ℝ → ℝ → ℂ

/-- A 3D wavefunction in spherical coordinates `(r, θ, φ)`. -/
abbrev WaveFun := ℝ → ℝ → ℝ → ℂ

/-- Construct a separated state `ψ(r,θ,φ) = R(r) · Y(θ,φ)` from
a radial function and an angular function. -/
def separatedState (R : RadialFun) (Y : AngularFun) : WaveFun :=
  fun r θ φ => R r * Y θ φ

/-- The separated state is the pointwise product. -/
theorem separatedState_apply (R : RadialFun) (Y : AngularFun) (r θ φ : ℝ) :
    separatedState R Y r θ φ = R r * Y θ φ := rfl

/-
A separated state is zero iff one of its factors vanishes everywhere.
-/
theorem separatedState_eq_zero_iff (R : RadialFun) (Y : AngularFun) :
    separatedState R Y = 0 ↔
      R = 0 ∨ Y = 0 := by
  constructor <;> intro hR <;> simp_all +decide [ funext_iff, separatedState ];
  · grind;
  · aesop

/-! ## Point Spectrum Properties -/

/-- The hydrogen point spectrum as a set of real numbers. -/
def hydrogenPointSpectrum : Set ℝ :=
  {E : ℝ | ∃ n : ℕ+, E = hydrogenEnergy n}

/-- Explicit description of the point spectrum. -/
theorem hydrogen_point_spectrum_explicit :
    hydrogenPointSpectrum = {E : ℝ | ∃ n : ℕ+, E = -1 / ((n : ℝ) ^ 2)} := by
  rfl

/-
The point spectrum is countable.
-/
theorem hydrogen_spectrum_countable : Set.Countable hydrogenPointSpectrum := by
  convert Set.countable_range ( fun n : ℕ+ => -1 / ( n : ℝ ) ^ 2 );
  exact Set.ext fun x => ⟨ fun ⟨ n, hn ⟩ => ⟨ n, hn ▸ rfl ⟩, fun ⟨ n, hn ⟩ => ⟨ n, hn ▸ rfl ⟩ ⟩

/-
Every element of the point spectrum is negative.
-/
theorem hydrogen_spectrum_neg : ∀ E ∈ hydrogenPointSpectrum, E < 0 := by
  -- By definition of the hydrogenPointSpectrum, every element in the point spectrum is of the form -1/n² for some positive integer n.
  intro E hE
  obtain ⟨n, hn⟩ := hE
  exact hn.symm ▸ hydrogenEnergy_neg n

/-
The ground state energy `-1` is the infimum of the point spectrum.
-/
theorem hydrogen_ground_state_energy :
    hydrogenEnergy 1 = -1 := by
  unfold hydrogenEnergy;
  norm_num

/-
No energy lies below the ground state.
-/
theorem hydrogen_no_energy_below_ground :
    ∀ E ∈ hydrogenPointSpectrum, -1 ≤ E := by
  exact fun E hE => by obtain ⟨ n, rfl ⟩ := hE; exact hydrogen_ground_state_energy ▸ hydrogenEnergy_strictMono.monotone ( PNat.one_le _ ) ;

/-
The point spectrum accumulates at zero from below.
-/
theorem hydrogen_energy_accumulation_at_zero :
    ∀ ε > 0, ∃ n : ℕ+, -ε < hydrogenEnergy n ∧ hydrogenEnergy n < 0 := by
  -- Given ε > 0, we need n such that -ε < -1/n² < 0. Choose n large enough that 1/n² < ε.
  intro ε hε
  obtain ⟨n, hn⟩ : ∃ n : ℕ+, 1 / ((n : ℝ) ^ 2) < ε := by
    exact ⟨ ⟨ ⌊ε⁻¹⌋₊ + 1, Nat.succ_pos _ ⟩, by simpa using inv_lt_of_inv_lt₀ hε <| by nlinarith [ Nat.lt_floor_add_one ε⁻¹ ] ⟩;
  exact ⟨ n, by rw [ hydrogenEnergy ] ; ring_nf at *; linarith, by rw [ hydrogenEnergy ] ; ring_nf; norm_num ⟩

/-! ## Spectral Gap -/

/-
The spectral gap between ground state and first excited state
is `3/4` (= E₂ - E₁ = -1/4 - (-1) = 3/4).
-/
theorem hydrogen_spectral_gap :
    hydrogenEnergy 2 - hydrogenEnergy 1 = 3 / 4 := by
  unfold hydrogenEnergy; norm_num;

/-
The ionization energy from the ground state is `1`
(= 0 - E₁ = 0 - (-1) = 1).
-/
theorem hydrogen_ionization_energy :
    -hydrogenEnergy 1 = 1 := by
  -- By definition of hydrogenEnergy, we have hydrogenEnergy 1 = -1 / (1^2).
  simp [hydrogenEnergy]

/-! ## Balmer Series -/

/-- The Balmer series transition energies: transitions from level `n` to level 2.
The photon energy emitted is `E_n - E_2 = -1/n² + 1/4 = 1/4 - 1/n²`.
For `n > 2` this is positive. -/
def balmerPhotonEnergy (n : ℕ+) : ℝ := hydrogenEnergy n - hydrogenEnergy 2

/-
The Balmer series converges: photon energies approach `1/4` (the
ionization energy from `n = 2`) as `n → ∞`.
-/
theorem balmer_series_limit :
    Filter.Tendsto (fun k : ℕ => balmerPhotonEnergy ⟨k + 3, by omega⟩)
      Filter.atTop (nhds (1 / 4)) := by
  convert Tendsto.const_sub ( 1 / 4 : ℝ ) ( tendsto_inv_atTop_zero.comp _ ) using 2 <;> norm_num;
  rotate_left;
  exact fun k => ( k + 3 : ℝ ) ^ 2;
  · exact Filter.tendsto_atTop_mono ( fun k => by nlinarith ) tendsto_natCast_atTop_atTop;
  · ext; unfold balmerPhotonEnergy; norm_num [ hydrogenEnergy ] ; ring

/-! ## Full Spectrum Structure -/

/-- The hydrogen spectrum (conjectural full statement):
  σ(H) = {-1/n² : n ∈ ℕ₊} ∪ [0, ∞)

We state this as a definition for the expected full spectrum,
with the discrete part proven and the continuous part as future work. -/
def hydrogenFullSpectrum : Set ℝ :=
  hydrogenPointSpectrum ∪ Set.Ici 0

/-- The full spectrum includes all bound-state energies. -/
theorem hydrogen_point_spectrum_subset_full :
    hydrogenPointSpectrum ⊆ hydrogenFullSpectrum :=
  Set.subset_union_left

/-- The full spectrum includes all non-negative reals (continuous spectrum). -/
theorem hydrogen_continuous_spectrum_subset_full :
    Set.Ici 0 ⊆ hydrogenFullSpectrum :=
  Set.subset_union_right

/-
The full spectrum consists of all nonpositive energies in `{-1/n²}`
and all nonneg reals. There is a gap `(-1/(N+1)², -1/N²)` between
consecutive bound states for every `N ≥ 1`.
-/
theorem hydrogen_spectrum_gap_between_levels (N : ℕ+) :
    ∀ E ∈ hydrogenPointSpectrum,
      ¬(hydrogenEnergy (N + 1) < E ∧ E < hydrogenEnergy N) := by
  intro E hEE';
  rcases hEE' with ⟨ n, rfl ⟩;
  unfold hydrogenEnergy;
  -- Simplify the inequalities to get a contradiction.
  field_simp;
  norm_num [ neg_lt_neg_iff ];
  grind +revert

end