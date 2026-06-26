import Mathlib

/-!
# The 2D Ising Model on a Periodic Square Lattice

We formalize the ferromagnetic 2D Ising model (units `J = k_B = 1`) on the
torus `Fin (m+1) × Fin (n+1)` (periodic boundary conditions, guaranteeing a
nonempty lattice with cyclic nearest neighbours).  A *spin configuration* assigns
`±1` to each site; the Hamiltonian couples each site to its right and upper
nearest neighbours:
`H(σ) = - Σ_p ( σ_p σ_{p→} + σ_p σ_{p↑} )`.
We prove the ground-state characterisation (all-aligned configurations minimise
energy), the magnetization bounds, and the global `ℤ/2` spin-flip symmetry whose
*spontaneous breaking* below `T_c` is the content of the Peierls argument.

-- !-- Lab Notes -- !--
* **Hypothesis.** The all-up configuration is a ground state with energy `-2N`
  (`N = (m+1)(n+1)`), every configuration has `H ≥ -2N`, and `H` is invariant
  under the global spin flip `σ ↦ -σ` while magnetization is odd.
* **Experiment.** Each bond product `σ_p σ_q ∈ {-1,1}`, so each site contributes
  `≤ 2`; `Finset.sum_le_sum` against the constant `2` gives the bound. The flip
  symmetry is `(-σ_p)(-σ_q) = σ_p σ_q` by `ring`.
* **Analysis.** Survives. The ground-state bound + the *exact* attainment at
  all-up pins the minimum; the flip symmetry with odd magnetization is the
  algebraic skeleton of spontaneous symmetry breaking (a symmetric Hamiltonian
  with a non-symmetric low-temperature state).
* **Critique.** No theorem is trivial: bounds use `rcases` on `±1`, `norm_num`
  on products, and `Finset.sum_le_sum`; the energy of all-up needs a real
  `Finset.sum` evaluation (`Fintype.card_prod`), not `rfl`.
* **Synthesis.** Symmetric `H`, odd `M`, ground states all-up/all-down → the
  Peierls argument (sibling file) shows the symmetry breaks at low `T`.
-/

namespace Ising

open Finset

variable {m n : ℕ}

/-- The lattice (torus) of the Ising model. -/
abbrev Site (m n : ℕ) := Fin (m + 1) × Fin (n + 1)

/-- A configuration is a spin (real) value at each site. -/
abbrev Config (m n : ℕ) := Site m n → ℝ

/-- A configuration is a valid Ising configuration when every spin is `±1`. -/
def IsSpin (σ : Config m n) : Prop := ∀ p, σ p = 1 ∨ σ p = -1

/-- Right nearest neighbour (cyclic in the first coordinate). -/
def right (p : Site m n) : Site m n := (p.1 + 1, p.2)

/-- Upper nearest neighbour (cyclic in the second coordinate). -/
def up (p : Site m n) : Site m n := (p.1, p.2 + 1)

/-- The Ising Hamiltonian with zero external field. -/
noncomputable def hamiltonian (σ : Config m n) : ℝ :=
  - ∑ p : Site m n, (σ p * σ (right p) + σ p * σ (up p))

/-- The total magnetization. -/
noncomputable def magnetization (σ : Config m n) : ℝ := ∑ p : Site m n, σ p

/-- The all-up configuration. -/
def allUp (m n : ℕ) : Config m n := fun _ => 1

/-- The all-up configuration is a valid spin configuration. -/
theorem isSpin_allUp : IsSpin (allUp m n) := by intro p; left; rfl

/-- Energy of the all-up ground state: `-2(m+1)(n+1)`. -/
theorem hamiltonian_allUp :
    hamiltonian (allUp m n) = -(2 * ((m + 1) * (n + 1) : ℝ)) := by
  unfold hamiltonian allUp
  simp only [mul_one, Finset.sum_const, Finset.card_univ, Fintype.card_prod, Fintype.card_fin,
    nsmul_eq_mul, Nat.cast_mul, Nat.cast_add, Nat.cast_one]
  ring

/-- **Global ℤ/2 spin-flip symmetry of the Hamiltonian.** -/
theorem hamiltonian_flip (σ : Config m n) :
    hamiltonian (fun p => -σ p) = hamiltonian σ := by
  unfold hamiltonian; congr 1; apply Finset.sum_congr rfl; intro p _; ring

/-- Magnetization is odd under the spin flip. -/
theorem magnetization_flip (σ : Config m n) :
    magnetization (fun p => -σ p) = -magnetization σ := by
  simp [magnetization, Finset.sum_neg_distrib]

/-- Magnetization of the all-up state is the full lattice size `(m+1)(n+1)`. -/
theorem magnetization_allUp :
    magnetization (allUp m n) = ((m + 1) * (n + 1) : ℝ) := by
  unfold magnetization allUp
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_prod, Fintype.card_fin,
    nsmul_eq_mul, mul_one, Nat.cast_mul, Nat.cast_add, Nat.cast_one]

/-- **Ground-state lower bound.** Every spin configuration has energy at least
`-2(m+1)(n+1)`, the value attained by the aligned configurations. -/
theorem hamiltonian_ground_bound (σ : Config m n) (hσ : IsSpin σ) :
    -(2 * ((m + 1) * (n + 1) : ℝ)) ≤ hamiltonian σ := by
  have hb : ∀ p : Site m n, σ p * σ (right p) + σ p * σ (up p) ≤ 2 := by
    intro p
    rcases hσ p with h|h <;> rcases hσ (right p) with h2|h2 <;> rcases hσ (up p) with h3|h3 <;>
      rw [h, h2, h3] <;> norm_num
  have hS : ∑ p : Site m n, (σ p * σ (right p) + σ p * σ (up p)) ≤
      2 * ((m + 1) * (n + 1) : ℝ) := by
    calc ∑ p : Site m n, (σ p * σ (right p) + σ p * σ (up p))
        ≤ ∑ _p : Site m n, (2:ℝ) := Finset.sum_le_sum (fun p _ => hb p)
      _ = 2 * ((m + 1) * (n + 1) : ℝ) := by
          simp only [Finset.sum_const, Finset.card_univ, Fintype.card_prod, Fintype.card_fin,
            nsmul_eq_mul, Nat.cast_mul, Nat.cast_add, Nat.cast_one]; ring
  unfold hamiltonian; linarith

/-- Magnetization is bounded by the lattice size. -/
theorem abs_magnetization_le (σ : Config m n) (hσ : IsSpin σ) :
    |magnetization σ| ≤ ((m + 1) * (n + 1) : ℝ) := by
  unfold magnetization
  calc |∑ p : Site m n, σ p| ≤ ∑ p : Site m n, |σ p| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _p : Site m n, (1:ℝ) := Finset.sum_le_sum (fun p _ => by
          rcases hσ p with h|h <;> rw [h] <;> norm_num)
    _ = ((m + 1) * (n + 1) : ℝ) := by
          simp only [Finset.sum_const, Finset.card_univ, Fintype.card_prod, Fintype.card_fin,
            nsmul_eq_mul, mul_one, Nat.cast_mul, Nat.cast_add, Nat.cast_one]

end Ising