import Mathlib

/-!
# Hydrogen Atom: The Energy Spectrum

We formalize the spectrum of the (idealized) hydrogen Hamiltonian in Rydberg
units, where the bound-state energies are the Bohr levels `Eₙ = -1/n²` and the
scattering (ionized) states fill the continuous half-line `[0, ∞)`.

The full spectrum is therefore

  `σ(H) = {-1/n² : n ∈ ℕ₊} ∪ [0, ∞)`.

We prove the structural facts that justify this picture:

* `bohrEnergy_neg`, `bohrEnergy_ground`, `bohrEnergy_ge_neg_one`: the bound
  energies are negative, the ground state is `-1`, and `-1` is a lower bound.
* `bohrEnergy_strictMono`: the levels strictly increase toward `0`.
* `bohrEnergy_tendsto_zero` / `zero_mem_closure_discrete`: the discrete spectrum
  accumulates exactly at the ionization threshold `0`.
* `discrete_disjoint_continuous`: bound and scattering spectra are disjoint.
* `rydberg_formula`, `photon_energy_pos`: the emitted photon energies obey the
  Rydberg formula and are positive for transitions to lower levels.

## Lab Notes

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The bound spectrum `{-1/n²}` is a strictly increasing
sequence with infimum `-1` (attained, the ground state) and supremum `0` (not
attained), accumulating only at `0`; together with `[0,∞)` it forms the full
spectrum, and the gaps obey the Rydberg formula.

Experiment (Experimenter): Defined `bohrEnergy : ℕ₊ → ℝ` and `hydrogenSpectrum`,
proved monotonicity via `one_div` antitone on positive squares, accumulation via
`Tendsto (1/n²) atTop (𝓝 0)`, and the Rydberg gap by `field_simp; ring`.

Analysis (Analyst): "True but quantitative" — the spectral picture reduces to
elementary real analysis of `-1/n²`. The deep functional-analytic claim (that
these are the *only* eigenvalues of the Schrödinger operator) is out of reach of
current Mathlib; we formalize the spectral *set* and its order/topological
structure faithfully instead.

Critique (Critic): Guarded against vacuity — every theorem ranges over all
`n : ℕ₊`, ground state and accumulation are both witnessed, and disjointness of
discrete/continuous parts is proven, not assumed.

Synthesis (PI): A self-contained, sorry-free description of the hydrogen energy
set, ready to support selection-rule and degeneracy results in sibling files.
-- !-- Lab Notes -- !--
-/

noncomputable section

open Set Filter Topology

namespace HydrogenSpectrum

/-- Bohr energy levels `Eₙ = -1/n²` (Rydberg units). -/
def bohrEnergy (n : ℕ+) : ℝ := -1 / (n : ℝ) ^ 2

/-- The spectrum of the hydrogen Hamiltonian: the discrete Bohr levels together
with the continuous (scattering) part `[0, ∞)`. -/
def hydrogenSpectrum : Set ℝ := {E | ∃ n : ℕ+, E = bohrEnergy n} ∪ Ici 0

/-
Every bound-state energy is strictly negative.
-/
theorem bohrEnergy_neg (n : ℕ+) : bohrEnergy n < 0 := by
  exact div_neg_of_neg_of_pos ( by norm_num ) ( by positivity )

/-
The ground-state energy is `-1`.
-/
theorem bohrEnergy_ground : bohrEnergy 1 = -1 := by
  unfold bohrEnergy; norm_num

/-
`-1` is a lower bound for all bound-state energies.
-/
theorem bohrEnergy_ge_neg_one (n : ℕ+) : -1 ≤ bohrEnergy n := by
  exact le_trans ( by norm_num ) ( mul_le_mul_of_nonpos_left ( inv_le_one_of_one_le₀ <| mod_cast Nat.one_le_pow _ _ n.pos ) <| by norm_num )

/-
The Bohr levels strictly increase: a larger principal quantum number means a
higher (less negative) energy.
-/
theorem bohrEnergy_strictMono : StrictMono bohrEnergy := by
  exact fun a b h => by rw [ bohrEnergy, bohrEnergy ] ; rw [ div_lt_div_iff₀ ] <;> norm_num ; nlinarith [ show ( a : ℝ ) < b from Nat.cast_lt.mpr h, show ( a : ℝ ) > 0 from Nat.cast_pos.mpr a.pos ] ;

/-
The bound energies approach the ionization threshold `0` as `n → ∞`.
-/
theorem bohrEnergy_tendsto_zero :
    Tendsto (fun n : ℕ => (-1 / ((n : ℝ) + 1) ^ 2)) atTop (𝓝 0) := by
      exact tendsto_const_nhds.div_atTop ( Filter.tendsto_atTop_mono ( fun n => by nlinarith ) tendsto_natCast_atTop_atTop )

/-
The ionization threshold `0` is a limit point of the discrete spectrum.
-/
theorem zero_mem_closure_discrete :
    (0 : ℝ) ∈ closure {E | ∃ n : ℕ+, E = bohrEnergy n} := by
      refine' mem_closure_iff_seq_limit.mpr _;
      refine' ⟨ _, fun n => ⟨ ⟨ n + 1, Nat.succ_pos n ⟩, rfl ⟩, _ ⟩;
      convert bohrEnergy_tendsto_zero ; norm_num [ bohrEnergy ]

/-
The ground state belongs to the spectrum.
-/
theorem ground_mem_spectrum : (-1 : ℝ) ∈ hydrogenSpectrum := by
  exact Or.inl ⟨ 1, by unfold bohrEnergy; norm_num ⟩

/-
The whole continuous part `[0, ∞)` is contained in the spectrum.
-/
theorem continuous_subset_spectrum : Ici (0 : ℝ) ⊆ hydrogenSpectrum := by
  exact fun x hx => Or.inr hx

/-
The discrete (bound) and continuous (scattering) parts of the spectrum are
disjoint: no Bohr level is non-negative.
-/
theorem discrete_disjoint_continuous :
    Disjoint {E | ∃ n : ℕ+, E = bohrEnergy n} (Ici 0) := by
      exact Set.disjoint_left.mpr fun x hx₁ hx₂ => by obtain ⟨ n, rfl ⟩ := hx₁; exact hx₂.out.not_gt ( bohrEnergy_neg n ) ;

/-- Photon energy emitted in the transition `n → m` (electron dropping from level
`n` to level `m`): `Eₙ - Eₘ`. -/
def photonEnergy (n m : ℕ+) : ℝ := bohrEnergy n - bohrEnergy m

/-
The Rydberg formula: the emitted photon energy for `n → m` equals
`1/m² - 1/n²`.
-/
theorem rydberg_formula (n m : ℕ+) :
    photonEnergy n m = 1 / (m : ℝ) ^ 2 - 1 / (n : ℝ) ^ 2 := by
      unfold photonEnergy bohrEnergy; ring;

/-
A transition to a strictly lower level (`m < n`) emits a photon of positive
energy.
-/
theorem photon_energy_pos (n m : ℕ+) (h : m < n) : 0 < photonEnergy n m := by
  exact sub_pos_of_lt ( bohrEnergy_strictMono h )

/-
Each spectral series (fixed lower level `m`) has emitted energies bounded
above by the series limit `1/m²`.
-/
theorem photon_energy_lt_series_limit (n m : ℕ+) :
    photonEnergy n m < 1 / (m : ℝ) ^ 2 := by
  rw [photonEnergy, bohrEnergy, bohrEnergy]
  have hn : (0 : ℝ) < (n : ℝ) := by exact_mod_cast n.pos
  have hpos : 0 < 1 / (n : ℝ) ^ 2 := by positivity
  have key : (-1 : ℝ) / (n : ℝ) ^ 2 - -1 / (m : ℝ) ^ 2
      = 1 / (m : ℝ) ^ 2 - 1 / (n : ℝ) ^ 2 := by ring
  rw [key]; linarith [hpos]

end HydrogenSpectrum