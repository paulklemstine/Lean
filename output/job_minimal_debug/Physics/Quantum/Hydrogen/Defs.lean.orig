import Mathlib

/-!
# Hydrogen Atom: Core Definitions

Foundational definitions for the spectral theory of the hydrogen atom,
including quantum numbers, energy levels, eigenpair predicates, and
transition structures.

## Mathematical Context

The hydrogen atom Hamiltonian in atomic units is H = -Δ - 2/r.
Its bound-state spectrum is {-1/n² : n ∈ ℕ₊}. For each principal
quantum number n, the angular momentum quantum number l ranges
over 0, 1, …, n-1, and the magnetic quantum number m over -l, …, l.
-/

noncomputable section

open Finset BigOperators

/-! ## Quantum Number Validity -/

/-- A valid set of hydrogen quantum numbers (n, l, m) satisfies
n ≥ 1, 0 ≤ l < n, and |m| ≤ l. -/
structure HydrogenQuantumNumbers where
  n : ℕ+
  l : ℕ
  m : ℤ
  hl : l < n
  hm : Int.natAbs m ≤ l

/-! ## Energy Levels -/

/-- The hydrogen bound-state energy for principal quantum number n,
in units where E_n = -1/n². -/
def hydrogenEnergy (n : ℕ+) : ℝ := -1 / ((n : ℝ) ^ 2)

/-- The hydrogen energy is always negative for bound states. -/
theorem hydrogenEnergy_neg (n : ℕ+) : hydrogenEnergy n < 0 := by
  unfold hydrogenEnergy
  apply div_neg_of_neg_of_pos
  · norm_num
  · positivity

/-
Distinct principal quantum numbers give distinct energies.
-/
theorem hydrogenEnergy_injective : Function.Injective hydrogenEnergy := by
  intro n m hnm;
  unfold hydrogenEnergy at hnm;
  rw [ div_eq_div_iff ] at hnm <;> aesop

/-
Energy levels increase (become less negative) with n.
-/
theorem hydrogenEnergy_strictMono : StrictMono hydrogenEnergy := by
  intro n m hnm
  -- By the definition of strict monotonicity, we need to show that if $n < m$, then $E(n) < E(m)$.
  have h_def : (-1 / ((n : ℝ) ^ 2)) < (-1 / ((m : ℝ) ^ 2)) := by
    rw [ div_lt_div_iff₀ ] <;> first | positivity | nlinarith [ show ( n : ℝ ) < m from Nat.cast_lt.mpr hnm ] ;
  exact h_def

/-! ## Eigenpair Predicate -/

/-- A general eigenpair predicate: v is an eigenvector of T with eigenvalue μ. -/
def IsEigenpair {V : Type*} [AddCommMonoid V] [Module ℝ V]
    (T : V → V) (μ : ℝ) (v : V) : Prop :=
  v ≠ 0 ∧ T v = μ • v

/-! ## Transition Structure -/

/-- A hydrogen spectral transition between two energy levels.
Encodes the Rydberg formula: ΔE = E_upper - E_lower = 1/n_lower² - 1/n_upper². -/
structure HydrogenTransition where
  /-- The lower energy level (higher |E|, lower n) -/
  n_lower : ℕ+
  /-- The upper energy level (lower |E|, higher n) -/
  n_upper : ℕ+
  /-- The upper level is strictly above the lower level -/
  h_order : n_lower < n_upper

/-- The photon energy emitted in a hydrogen transition (Rydberg formula).
  ΔE = 1/n_lower² - 1/n_upper² -/
def HydrogenTransition.photonEnergy (t : HydrogenTransition) : ℝ :=
  1 / ((t.n_lower : ℝ) ^ 2) - 1 / ((t.n_upper : ℝ) ^ 2)

/-! ## Spectral Series -/

/-- A spectral series is a family of transitions all ending at the same lower level. -/
structure SpectralSeries where
  /-- The common lower level -/
  n_final : ℕ+
  /-- The upper level index (offset from n_final + 1) -/
  transition : ℕ → HydrogenTransition
  /-- Each transition ends at n_final -/
  h_lower : ∀ k, (transition k).n_lower = n_final

/-- The Lyman series: transitions to n=1. -/
def lymanSeries : ℕ → HydrogenTransition :=
  fun k => ⟨1, ⟨k + 2, by omega⟩, by exact_mod_cast (by omega : (1 : ℕ) < k + 2)⟩

/-- The Balmer series: transitions to n=2. -/
def balmerSeries : ℕ → HydrogenTransition :=
  fun k => ⟨2, ⟨k + 3, by omega⟩, by exact_mod_cast (by omega : (2 : ℕ) < k + 3)⟩

/-- The Paschen series: transitions to n=3. -/
def paschenSeries : ℕ → HydrogenTransition :=
  fun k => ⟨3, ⟨k + 4, by omega⟩, by exact_mod_cast (by omega : (3 : ℕ) < k + 4)⟩

end