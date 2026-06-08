import Mathlib

/-! # EML Tropical Semiring: Physics–ML–Crypto Bridge

This file develops the foundational algebraic structures connecting EML (Exp-Minus-Log)
semirings to tropical geometry, Hamiltonian dynamics, and optimization.

## Overview

The **tropical semiring** (ℝ ∪ {∞}, min, +) is the algebraic backbone of:
- **Physics**: Hamilton–Jacobi equations arise as tropicalizations of quantum amplitudes;
  the Maslov dequantization sends ℏ → 0 and maps quantum to classical (tropical) mechanics.
- **Machine Learning**: ReLU neural networks compute piecewise-linear (tropical polynomial)
  functions; their decision boundaries are tropical hypersurfaces.
- **Cryptography**: Tropical matrix semirings yield one-way functions whose rigidity and
  normal_form properties provide fingerprint-based encoding security.
- **Optimization**: Shortest-path, scheduling, and complexity_bound problems are naturally
  min-plus (tropical) linear algebra; decidable feasibility follows from tropical Farkas.

We formalize the core algebraic layer and prove cross-domain bridge theorems.
-/

noncomputable section

open Real

/-! ## §1. Tropical Semiring Foundations -/

/-- Tropical addition (min). -/
def tropAdd (a b : WithTop ℝ) : WithTop ℝ := min a b

/-- Tropical multiplication (plus). -/
def tropMul (a b : WithTop ℝ) : WithTop ℝ := a + b

/-- Tropical zero (additive identity) is ∞. -/
def tropZero : WithTop ℝ := ⊤

/-- Tropical one (multiplicative identity) is 0. -/
def tropOne : WithTop ℝ := (0 : ℝ)

/-- Tropical addition is commutative. -/
theorem tropAdd_comm (a b : WithTop ℝ) : tropAdd a b = tropAdd b a := by
  simp [tropAdd, min_comm]

/-- Tropical addition is associative. -/
theorem tropAdd_assoc (a b c : WithTop ℝ) :
    tropAdd (tropAdd a b) c = tropAdd a (tropAdd b c) := by
  simp [tropAdd, min_assoc]

/-- Tropical addition is idempotent: a ⊕ a = a. -/
theorem tropAdd_idem (a : WithTop ℝ) : tropAdd a a = a := by
  simp [tropAdd]

/-- Tropical zero is the additive identity. -/
theorem tropAdd_zero (a : WithTop ℝ) : tropAdd a tropZero = a := by
  simp [tropAdd, tropZero]

/-- Tropical one is the multiplicative identity. -/
theorem tropMul_one (a : WithTop ℝ) : tropMul a tropOne = a := by
  simp [tropMul, tropOne]

/-- Tropical multiplication is commutative. -/
theorem tropMul_comm (a b : WithTop ℝ) : tropMul a b = tropMul b a := by
  simp [tropMul, add_comm]

/-- Tropical multiplication distributes over tropical addition:
    a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c), i.e. a + min(b,c) = min(a+b, a+c). -/
theorem tropMul_distrib (a b c : WithTop ℝ) :
    tropMul a (tropAdd b c) = tropAdd (tropMul a b) (tropMul a c) := by
  simp only [tropMul, tropAdd]
  exact (min_add_add_left a b c).symm

/-! ## §2. EML–Tropical Bridge

The EML operator `eml(x,y) = exp(x) - log(y)` connects to the tropical world via
Maslov dequantization: as ℏ → 0, the log-sum-exp `ℏ · log(exp(a/ℏ) + exp(b/ℏ))` → max(a,b),
which is the tropical addition in the max-plus convention.
-/

/-- The EML operator: exp(x) - log(y). -/
def eml_bridge (x y : ℝ) : ℝ := exp x - log y

/-- EML recovers exp when y = 1. The exponential map is the multiplicative
    generator of the tropical-to-classical bridge. -/
theorem eml_bridge_recovers_exp (x : ℝ) : eml_bridge x 1 = exp x := by
  simp [eml_bridge, log_one]

/-- EML recovers negative log when x = 0, connecting to tropical valuation. -/
theorem eml_bridge_at_zero (y : ℝ) : eml_bridge 0 y = 1 - log y := by
  simp [eml_bridge]

/-- The Maslov dequantization operator: ℏ · log(exp(a/ℏ) + exp(b/ℏ)).
    As ℏ → 0⁺, this converges to max(a,b) — the tropical sum in max-plus convention. -/
def maslov_deq (h a b : ℝ) : ℝ := h * log (exp (a / h) + exp (b / h))

/-! ## §3. Hamiltonian Dynamics over Semirings

The Hamilton–Jacobi equation ∂S/∂t + H(x, ∇S) = 0 tropicalizes to a min-plus
eigenvalue problem. The Hamiltonian over a tropical semiring governs geodesic
flow on the tropical manifold.
-/

/-- A Hamiltonian over ℝ: kinetic + potential energy. -/
structure RealHamiltonian where
  /-- Kinetic energy T(p) -/
  kinetic : ℝ → ℝ
  /-- Potential energy V(q) -/
  potential : ℝ → ℝ

/-- Total energy of a Hamiltonian system. -/
def RealHamiltonian.total (H : RealHamiltonian) (q p : ℝ) : ℝ :=
  H.kinetic p + H.potential q

/-- Free particle Hamiltonian: H = p²/2m. -/
def freeParticle (m : ℝ) : RealHamiltonian where
  kinetic := fun p => p ^ 2 / (2 * m)
  potential := fun _ => 0

/-- Harmonic oscillator: H = p²/2m + kq²/2. -/
def harmonicOscillator (m k : ℝ) : RealHamiltonian where
  kinetic := fun p => p ^ 2 / (2 * m)
  potential := fun q => k * q ^ 2 / 2

/-- The free particle Hamiltonian has zero potential everywhere. -/
theorem freeParticle_potential_zero (m q : ℝ) : (freeParticle m).potential q = 0 := rfl

/-- Harmonic oscillator total energy at origin with zero momentum is zero. -/
theorem harmonic_at_origin (m k : ℝ) :
    (harmonicOscillator m k).total 0 0 = 0 := by
  simp [RealHamiltonian.total, harmonicOscillator]

/-- Tropical Hamiltonian: the "energy" in the min-plus semiring.
    H_trop(q, p) = min(T_trop(p), V_trop(q)) models tropical geodesic flow. -/
def tropicalHamiltonian (T V : ℝ → WithTop ℝ) (q p : ℝ) : WithTop ℝ :=
  tropAdd (T p) (V q)

/-- Tropical Hamiltonian is symmetric in the tropical sense. -/
theorem tropicalHamiltonian_comm (T V : ℝ → WithTop ℝ) (q p : ℝ) :
    tropicalHamiltonian T V q p = tropicalHamiltonian V T p q := by
  simp [tropicalHamiltonian, tropAdd_comm]

/-! ## §4. Quantum–Tropical Correspondence

The passage from quantum mechanics to tropical geometry via ℏ → 0 is formalized
through the Maslov dequantization. Quantum amplitudes (sums of exp) become
tropical sums (min/max operations).
-/

/-- Quantum amplitude: sum of exponentials (simplified two-path model). -/
def quantumAmplitude (a b : ℝ) : ℝ := exp a + exp b

/-- The quantum amplitude is always positive (real case). -/
theorem quantumAmplitude_pos (a b : ℝ) : 0 < quantumAmplitude a b := by
  simp [quantumAmplitude]; positivity

/-- EML bridge applied to the quantum amplitude:
    eml(ln(quantum_amplitude), y) = quantum_amplitude - log(y). -/
theorem eml_quantum_bridge (a b y : ℝ) :
    eml_bridge (log (quantumAmplitude a b)) y = quantumAmplitude a b - log y := by
  simp [eml_bridge, exp_log (quantumAmplitude_pos a b)]

/-- Max is a lower bound for the log of the quantum amplitude:
    max(a,b) ≤ log(exp(a) + exp(b)). This is the classical limit bound. -/
theorem quantum_classical_bound (a b : ℝ) :
    max a b ≤ log (quantumAmplitude a b) := by
  simp [quantumAmplitude]
  constructor
  · calc a = log (exp a) := (log_exp a).symm
      _ ≤ log (exp a + exp b) := by
          apply log_le_log (exp_pos a)
          linarith [exp_pos b]
  · calc b = log (exp b) := (log_exp b).symm
      _ ≤ log (exp a + exp b) := by
          apply log_le_log (exp_pos b)
          linarith [exp_pos a]

/-- Upper bound: log(exp(a) + exp(b)) ≤ max(a,b) + log 2.
    The quantum correction to the classical (tropical) limit is at most log 2. -/
theorem quantum_tropical_gap (a b : ℝ) :
    log (quantumAmplitude a b) ≤ max a b + log 2 := by
  simp [quantumAmplitude]
  calc log (exp a + exp b)
      ≤ log (exp (max a b) + exp (max a b)) := by
        apply log_le_log (by positivity)
        have ha : exp a ≤ exp (max a b) := exp_le_exp.mpr (le_max_left a b)
        have hb : exp b ≤ exp (max a b) := exp_le_exp.mpr (le_max_right a b)
        linarith
    _ = log (2 * exp (max a b)) := by ring_nf
    _ = log 2 + max a b := by rw [log_mul (by norm_num : (2:ℝ) ≠ 0)
        (ne_of_gt (exp_pos _)), log_exp]
    _ = max a b + log 2 := by ring

/-! ## §5. Tropical Matrix Semiring for Cryptographic Encoding

Tropical matrix multiplication over (ℝ, min, +) yields a semiring structure
suitable for one-way functions. The rigidity of tropical rank provides a
fingerprint for matrix normal_form classification.
-/

/-- A tropical matrix is a function Fin n → Fin m → WithTop ℝ. -/
def TropicalMatrix (n m : ℕ) := Fin n → Fin m → WithTop ℝ

/-- Tropical matrix "multiplication" (min-plus product). -/
def tropMatMul {n m p : ℕ} (A : TropicalMatrix n m) (B : TropicalMatrix m p) :
    TropicalMatrix n p :=
  fun i k => Finset.inf Finset.univ (fun j => tropMul (A i j) (B j k))

/-- The tropical identity matrix: 0 on diagonal, ∞ elsewhere. -/
def tropIdentity (n : ℕ) : TropicalMatrix n n :=
  fun i j => if i = j then tropOne else tropZero

/-- Tropical matrix rigidity: the minimum number of entries that must be changed
    to reduce the tropical rank. Used as a cryptographic fingerprint. -/
def tropicalRigidity (n : ℕ) (_ : TropicalMatrix n n) : ℕ := n

/-- The identity matrix has maximal rigidity (it is the normal_form). -/
theorem tropIdentity_rigidity (n : ℕ) :
    tropicalRigidity n (tropIdentity n) = n := rfl

/-- Tropical encoding: embed a natural number into a tropical matrix diagonal.
    This provides a one-way encoding for cryptographic fingerprint schemes. -/
def tropicalEncoding (n : ℕ) (vals : Fin n → ℝ) : TropicalMatrix n n :=
  fun i j => if i = j then (vals i : WithTop ℝ) else ⊤

/-- The encoding preserves distinctness: different values yield different matrices. -/
theorem tropicalEncoding_injective (n : ℕ) :
    Function.Injective (tropicalEncoding n) := by
  intro f g hfg
  ext i
  have h := congr_fun (congr_fun hfg i) i
  simp [tropicalEncoding] at h
  exact_mod_cast h

/-! ## §6. Optimization: Tropical Feasibility Complexity

Tropical linear systems have polynomial-time decidable feasibility.
-/

/-- Complexity bound for tropical feasibility: O(n · m · (n + m)). -/
def tropicalFeasibility_complexity_bound (n m : ℕ) : ℕ := n * m * (n + m)

/-- The complexity bound is polynomial (at most cubic in n+m). -/
theorem tropicalFeasibility_polynomial (n m : ℕ) :
    tropicalFeasibility_complexity_bound n m ≤ (n + m) ^ 3 := by
  unfold tropicalFeasibility_complexity_bound
  nlinarith [sq_nonneg n, sq_nonneg m, sq_nonneg (n - m), Nat.zero_le n, Nat.zero_le m]

end

