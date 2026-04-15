/-! # CatalogBuild.Physics.Classical.PhysicalPhenomena

Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 13
-/

import Mathlib

noncomputable section

def sphereSurfaceArea (R : ℝ) : ℝ := 4 * Real.pi * R ^ 2

/-- Volume of a sphere of radius R: V = (4/3)πR³. -/

theorem holographic_subvolumetric (R : ℝ) (hR : 1 < R) :
    sphereSurfaceArea R < sphereVolume R * 3 := by
  unfold sphereSurfaceArea sphereVolume;
  nlinarith [ Real.pi_pos, mul_lt_mul_of_pos_left hR Real.pi_pos, pow_pos ( zero_lt_one.trans hR ) 3 ]

/-! ## Part II: Quantum Measurement as Oracle Query -/

/-- A quantum state over a finite-dimensional space is a unit vector
    in the probability simplex (Born rule). We model it as probability amplitudes. -/

structure QuantumState (n : ℕ) where
  amplitudes : Fin n → ℂ
  normalized : ∑ i, Complex.normSq (amplitudes i) = 1

/-- Born rule: probability of measuring outcome i is |αᵢ|². -/

def bornProb {n : ℕ} (ψ : QuantumState n) (i : Fin n) : ℝ :=
  Complex.normSq (ψ.amplitudes i)

/-- Born probabilities sum to 1. -/

theorem born_prob_sum_one {n : ℕ} (ψ : QuantumState n) :
    ∑ i, bornProb ψ i = 1 := by
  simp [bornProb]
  exact ψ.normalized

/-- Born probabilities are nonneg. -/

theorem measurement_is_oracle_query {n : ℕ} (ψ : QuantumState n)
    (i : Fin n) (hi : 0 < bornProb ψ i) :
    0 ≤ -Real.logb 2 (bornProb ψ i) := by
  rw [ neg_nonneg, logb_nonpos_iff ] <;> norm_num [ hi ];
  exact le_trans ( Finset.single_le_sum ( fun a _ => Complex.normSq_nonneg ( ψ.amplitudes a ) ) ( Finset.mem_univ i ) ) ( by norm_num [ ψ.normalized ] )

/-! ## Part III: Black Hole Information -/

/-- Schwarzschild radius: R_s = 2GM/c². -/

def blackHoleEntropy (G M c ℏ : ℝ) : ℝ :=
  let R := schwarzschildRadius G M c
  let A := sphereSurfaceArea R
  let l_P_sq := ℏ * G / c ^ 3
  A / (4 * l_P_sq)

/-
PROBLEM
**Black hole entropy scales as M²**: S_BH(2M) = 4 × S_BH(M).
    A black hole of mass 2M has 4× the entropy of one of mass M.

PROVIDED SOLUTION
Unfold everything. schwarzschildRadius G (2M) c = 2G(2M)/c² = 2 · schwarzschildRadius G M c. sphereSurfaceArea (2R) = 4π(2R)² = 16πR² = 4 · 4πR² = 4 · sphereSurfaceArea R. The rest divides by the same l_P_sq. So blackHoleEntropy doubles R, quadruples area, quadruples entropy. Use ring after unfolding.
-/

theorem bh_entropy_quadratic (G c ℏ : ℝ) (hG : 0 < G) (hc : 0 < c) (hℏ : 0 < ℏ)
    (M : ℝ) (hM : 0 < M) :
    blackHoleEntropy G (2 * M) c ℏ = 4 * blackHoleEntropy G M c ℏ := by
  unfold blackHoleEntropy
  unfold schwarzschildRadius
  unfold sphereSurfaceArea
  field_simp
  ring_nf at *

/-! ## Part IV: The Universe as a Computation -/

/-- The computational capacity of a region: maximum operations per second
    bounded by E / (π ℏ) (Margolus-Levitin theorem). -/

def margolusLevitin (E ℏ : ℝ) : ℝ := E / (Real.pi * ℏ)

/-- The Lloyd bound: total computation performed by a system of energy E
    in time t is at most 2Et / (π ℏ). -/

def lloydBound (E t ℏ : ℝ) : ℝ := 2 * E * t / (Real.pi * ℏ)

/-
PROBLEM
**Lloyd bound is nonneg** for positive energy and time.

PROVIDED SOLUTION
lloydBound = 2Et/(πℏ). Since E ≥ 0, t ≥ 0, π > 0, ℏ > 0, this is nonneg. Use div_nonneg, mul_nonneg, etc., or positivity.
-/

theorem lloyd_nonneg (E t ℏ : ℝ) (hE : 0 ≤ E) (ht : 0 ≤ t) (hℏ : 0 < ℏ) :
    0 ≤ lloydBound E t ℏ := by
  exact div_nonneg ( mul_nonneg ( mul_nonneg zero_le_two hE ) ht ) ( mul_nonneg Real.pi_pos.le hℏ.le )

/-! ## Part V: The Meta-Physical Theorem -/

/-- The three phenomena are unified by a single principle:
    The universe processes I bits of information per unit time,
    at an energy cost of at least I × kT ln 2.

    This connects:
    - Holographic principle (I is bounded by surface area)
    - Landauer's principle (energy cost per bit)
    - Lloyd bound (operations per second bounded by energy)

    The chain: Surface Area → Max Info → Max Computation → Min Energy
-/

def universalComputationBound (surfaceArea k_B T ℏ : ℝ) : ℝ :=
  let maxBits := holographicBound surfaceArea
  let minEnergy := maxBits * k_B * T * Real.log 2
  let maxOpsPerSec := margolusLevitin minEnergy ℏ
  maxOpsPerSec

/-
PROBLEM
The universal bound is nonneg.

PROVIDED SOLUTION
Unfold universalComputationBound. It's margolusLevitin applied to a nonneg energy. margolusLevitin E ℏ = E/(πℏ). The energy argument is holographicBound A * k_B * T * log 2, which is nonneg since A ≥ 0, k_B > 0, T > 0, log 2 > 0. So the whole thing is nonneg. Use positivity or manual mul_nonneg/div_nonneg.
-/

theorem universal_bound_nonneg (A k_B T ℏ : ℝ)
    (hA : 0 ≤ A) (hk : 0 < k_B) (hT : 0 < T) (hℏ : 0 < ℏ) :
    0 ≤ universalComputationBound A k_B T ℏ := by
  apply div_nonneg;
  · exact mul_nonneg ( mul_nonneg ( mul_nonneg ( div_nonneg hA ( by positivity ) ) hk.le ) hT.le ) ( Real.log_nonneg ( by norm_num ) );
  · positivity


end
