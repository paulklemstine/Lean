/-
Copyright (c) 2025. All rights reserved.

# Local Hamiltonian Energy Algebra and the Promise Gap

This module formalizes the linear-algebraic core underlying the *k-Local Hamiltonian
Problem*, the canonical QMA-complete problem of quantum Hamiltonian complexity
(Kitaev). A quantum Hamiltonian on a finite-dimensional Hilbert space is a Hermitian
operator; a *local* Hamiltonian is a sum of Hermitian terms each acting on few qubits.
The decision problem asks to estimate the ground-state energy (smallest eigenvalue)
within a promise gap `b - a`.

We make the following pieces rigorous and machine-checked:

* `qform` — the Rayleigh quadratic form `⟨x, H x⟩` of an operator;
* `IsHermitian.qform_self_conj` — for Hermitian `H` the energy `⟨x, H x⟩` is real
  (the spectrum is real), the well-definedness underlying the whole problem;
* `EnergyLB` — the predicate "`λ` is an energy lower bound for `H`" (a certified
  bound on the ground energy);
* `energyLB_add` / `energyLB_sum` — energy lower bounds compose **additively** over
  local terms: a sum of `m` terms each bounded below by `λ i` is bounded below by
  `∑ λ i`. This is the soundness direction of the promise-gap analysis for local
  Hamiltonians.
* `isHermitian_sum` — a sum of local Hermitian terms is Hermitian.
* `promise_gap_consistent` — the promise gap is logically consistent: with `a < b`,
  no instance can be simultaneously a YES instance (a witness of energy `≤ a`) and a
  NO instance (ground energy `≥ b`). This is the abstract soundness/completeness
  separation that makes the QMA promise problem well posed.
* `frustration_no_common_ground_state` — a concrete two-term, single-qubit witness of
  *frustration*: the local terms `(I - Z)/2` and `(I - X)/2` have ground energy `0`
  individually, yet share **no** common zero-energy state. Frustration is precisely
  what makes computing the ground energy of a local Hamiltonian hard (super-additive
  ground energy) rather than a trivial term-by-term minimization.

## Cross-domain bridge

The energy-lower-bound algebra (`EnergyLB`) is an ordered-semiring-flavoured
*certificate calculus*: certificates for individual local terms add to a certificate
for the whole Hamiltonian, exactly as interval bounds compose in
`Physics.CertifiedMassGapBounds`. The frustration witness connects this complexity
theory to the variational principles of `Physics.V12_VariationalPrinciples`: the gap
between `∑ λ i` and the true ground energy is the algebraic signature of
computational hardness.
-/

import Mathlib

open Matrix
open scoped Matrix BigOperators

namespace LocalHamiltonian

variable {m : Type*} [Fintype m]

/-! ## The Rayleigh quadratic form (energy functional) -/

/-- The energy functional (Rayleigh quadratic form) `⟨x, H x⟩` of an operator `H`
on state `x`. -/
noncomputable def qform (H : Matrix m m ℂ) (x : m → ℂ) : ℂ := star x ⬝ᵥ H.mulVec x

-- !-- The energy functional is additive in the operator: `⟨x,(H₁+H₂)x⟩ = ⟨x,H₁x⟩+⟨x,H₂x⟩`,
-- immediate from bilinearity of matrix-vector product and the dot product. -- !--
theorem qform_add (H₁ H₂ : Matrix m m ℂ) (x : m → ℂ) :
    qform (H₁ + H₂) x = qform H₁ x + qform H₂ x := by
  unfold qform
  rw [Matrix.add_mulVec, dotProduct_add]

-- !-- The zero operator has zero energy on every state. -- !--
theorem qform_zero (x : m → ℂ) : qform (0 : Matrix m m ℂ) x = 0 := by
  unfold qform
  rw [Matrix.zero_mulVec, dotProduct_zero]

/-- Helper: complex-conjugation distributes over the dot product (the entry star ring
is commutative). -/
theorem star_dotProduct_distrib (v w : m → ℂ) :
    star (v ⬝ᵥ w) = star v ⬝ᵥ star w := by
  simp only [dotProduct, star_sum, star_mul']
  rfl

-- !-- For Hermitian `H`, the energy `⟨x,Hx⟩` is self-conjugate, hence real: this is
-- the statement that observables (Hermitian operators) have real expectation values
-- and real spectrum, the foundation of the Local Hamiltonian Problem. -- !--
theorem IsHermitian.qform_self_conj {H : Matrix m m ℂ} (hH : H.IsHermitian)
    (x : m → ℂ) : star (qform H x) = qform H x := by
  unfold qform
  rw [star_dotProduct_distrib, star_star, star_mulVec, hH.eq, dotProduct_comm,
    dotProduct_mulVec]

-- !-- Consequently the energy of a Hermitian operator has zero imaginary part. -- !--
theorem IsHermitian.qform_im_zero {H : Matrix m m ℂ} (hH : H.IsHermitian)
    (x : m → ℂ) : (qform H x).im = 0 := by
  have h := IsHermitian.qform_self_conj hH x
  have : (starRingEnd ℂ) (qform H x) = qform H x := h
  rw [Complex.conj_eq_iff_im] at this
  exact this

/-! ## Norms and energy lower bounds -/

/-- The squared norm `⟨x, x⟩ = ∑ |xᵢ|²` of a state, as a real number. -/
noncomputable def normSq2 (x : m → ℂ) : ℝ := (star x ⬝ᵥ x).re

-- !-- `∑|xᵢ|² ≥ 0`: the dot product `star x ⬝ᵥ x` equals `∑ |xᵢ|²` whose real part is a
-- sum of squared moduli. -- !--
theorem normSq2_nonneg (x : m → ℂ) : 0 ≤ normSq2 x := by
  unfold normSq2 dotProduct
  rw [Complex.re_sum]
  apply Finset.sum_nonneg
  intro i _
  simp [Complex.mul_re, Pi.star_apply, Complex.conj_re, Complex.conj_im]
  nlinarith [sq_nonneg (x i).re, sq_nonneg (x i).im]

-- !-- A state has zero squared norm iff it is the zero vector. -- !--
theorem normSq2_eq_zero_iff (x : m → ℂ) : normSq2 x = 0 ↔ x = 0 := by
  unfold normSq2;
  simp +decide [ dotProduct ];
  simp +decide [ Finset.sum_eq_zero_iff_of_nonneg, add_nonneg, mul_self_nonneg, funext_iff ];
  exact forall_congr' fun i => by simp +decide [ Complex.ext_iff, add_eq_zero_iff_of_nonneg, mul_self_nonneg ] ;

/-- `λ` is a certified **energy lower bound** for `H`: every state has Rayleigh
energy at least `λ‖x‖²`. For Hermitian `H` this lower-bounds the ground-state
energy (smallest eigenvalue). -/
def EnergyLB (H : Matrix m m ℂ) (lam : ℝ) : Prop :=
  ∀ x : m → ℂ, lam * normSq2 x ≤ (qform H x).re

-- !-- Energy lower bounds compose additively: this is the soundness of summing local
-- terms. Follows from `qform_add` and additivity of `Complex.re`, then `linarith`. -- !--
theorem energyLB_add {H₁ H₂ : Matrix m m ℂ} {a b : ℝ}
    (h₁ : EnergyLB H₁ a) (h₂ : EnergyLB H₂ b) : EnergyLB (H₁ + H₂) (a + b) := by
  intro x
  have e := qform_add H₁ H₂ x
  have h1 := h₁ x
  have h2 := h₂ x
  rw [e, Complex.add_re]
  have : (a + b) * normSq2 x = a * normSq2 x + b * normSq2 x := by ring
  rw [this]
  linarith

-- !-- The zero Hamiltonian has energy lower bound `0`. -- !--
theorem energyLB_zero : EnergyLB (0 : Matrix m m ℂ) 0 := by
  intro x
  rw [qform_zero]
  simp

-- !-- Energy lower bounds for a finite family of local terms sum to an energy lower
-- bound for the total Hamiltonian. Finset induction on `energyLB_add`/`energyLB_zero`. -- !--
theorem energyLB_sum {ι : Type*} (s : Finset ι) (H : ι → Matrix m m ℂ)
    (lam : ι → ℝ) (h : ∀ i ∈ s, EnergyLB (H i) (lam i)) :
    EnergyLB (∑ i ∈ s, H i) (∑ i ∈ s, lam i) := by
  classical
  induction s using Finset.induction with
  | empty => simpa using (energyLB_zero (m := m))
  | insert i s hi ih =>
    rw [Finset.sum_insert hi, Finset.sum_insert hi]
    exact energyLB_add (h i (Finset.mem_insert_self _ _))
      (ih (fun j hj => h j (Finset.mem_insert_of_mem hj)))

/-! ## Hermiticity of the total local Hamiltonian -/

-- !-- A sum of Hermitian local terms is Hermitian: `(∑ Hᵢ)ᴴ = ∑ Hᵢᴴ = ∑ Hᵢ`. -- !--
omit [Fintype m] in
theorem isHermitian_sum {ι : Type*} (s : Finset ι) (H : ι → Matrix m m ℂ)
    (h : ∀ i ∈ s, (H i).IsHermitian) : (∑ i ∈ s, H i).IsHermitian := by
  classical
  induction s using Finset.induction with
  | empty => simp [Matrix.IsHermitian]
  | insert i s hi ih =>
    rw [Finset.sum_insert hi]
    exact (h i (Finset.mem_insert_self _ _)).add
      (ih (fun j hj => h j (Finset.mem_insert_of_mem hj)))

/-! ## The promise gap is well posed -/

/-- A **YES instance** witness: a normalized state of energy at most `a`. -/
def IsYesWitness (H : Matrix m m ℂ) (a : ℝ) (x : m → ℂ) : Prop :=
  normSq2 x = 1 ∧ (qform H x).re ≤ a

-- !-- Soundness of the promise gap: if `a < b`, an operator cannot simultaneously
-- admit a YES witness at threshold `a` and be a NO instance (energy lower bound `b`).
-- Evaluate the lower bound on the unit witness: `b = b·1 ≤ energy ≤ a < b`. -- !--
theorem promise_gap_consistent {H : Matrix m m ℂ} {a b : ℝ} (hab : a < b)
    (x : m → ℂ) (hyes : IsYesWitness H a x) (hno : EnergyLB H b) : False := by
  obtain ⟨hnorm, hle⟩ := hyes
  have hb := hno x
  rw [hnorm, mul_one] at hb
  linarith

/-! ## Frustration: a concrete obstruction to term-by-term ground states -/

/-- Local term `(I - Z)/2 = diag(0,1)` on one qubit; ground energy `0` with ground
state `|0⟩`. -/
def Hz : Matrix (Fin 2) (Fin 2) ℂ := !![0, 0; 0, 1]

/-- Local term `(I - X)/2` on one qubit; ground energy `0` with ground state `|+⟩`. -/
noncomputable def Hx : Matrix (Fin 2) (Fin 2) ℂ := !![1/2, -1/2; -1/2, 1/2]

-- !-- `Hz` is Hermitian (real diagonal). -- !--
theorem Hz_isHermitian : Hz.IsHermitian := by
  unfold Hz Matrix.IsHermitian
  ext i j
  fin_cases i <;> fin_cases j <;> simp [Matrix.conjTranspose, Matrix.of_apply]

-- !-- `Hx` is Hermitian (real symmetric). -- !--
theorem Hx_isHermitian : Hx.IsHermitian := by
  ext i j; fin_cases i <;> fin_cases j <;> norm_num [ Hx ] ;

-- !-- `Hz` has energy `|x₁|²`, forcing `x₁ = 0` at a zero-energy state. -- !--
theorem qform_Hz (x : Fin 2 → ℂ) : qform Hz x = (starRingEnd ℂ) (x 1) * x 1 := by
  -- By definition of qform, we have qform Hz x = star x ⬝ᵥ Hz.mulVec x.
  simp [qform, Hz];
  rfl

-- !-- `Hx` has energy `½|x₀ - x₁|²`, forcing `x₀ = x₁` at a zero-energy state. -- !--
theorem qform_Hx (x : Fin 2 → ℂ) :
    qform Hx x = (1/2 : ℂ) * ((starRingEnd ℂ) (x 0 - x 1) * (x 0 - x 1)) := by
  unfold qform Hx; norm_num ; ring;
  norm_num [ vecHead, vecTail ] ; ring!;

-- !-- **Frustration.** The two local terms `Hz` and `Hx` admit ground energy `0`
-- individually but share no common zero-energy state: any state annihilated by both
-- must satisfy `x₁ = 0` (from `Hz`) and `x₀ = x₁` (from `Hx`), hence `x = 0`. This
-- super-additivity of ground energy is the structural reason the Local Hamiltonian
-- ground energy is hard to compute. -- !--
theorem frustration_no_common_ground_state :
    ¬ ∃ x : Fin 2 → ℂ, x ≠ 0 ∧ qform Hz x = 0 ∧ qform Hx x = 0 := by
  push_neg;
  intro x hx hx' hx''; simp_all +decide [ funext_iff, Fin.forall_fin_two, qform_Hz, qform_Hx ] ;

/-! ## Examples -/

example : EnergyLB (0 : Matrix (Fin 2) (Fin 2) ℂ) 0 := energyLB_zero

example : Hz.IsHermitian := Hz_isHermitian

end LocalHamiltonian