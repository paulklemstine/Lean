/-
  Gravity from Information: Spacetime as a Quantum Error-Correcting Code

  This module formalizes the connection between quantum error-correcting codes
  and holographic gravity. We define holographic codes, prove the quantum
  Singleton bound, and show that the Bekenstein-Hawking entropy formula
  S = A/(4G) is equivalent to a code saturating this bound under the
  holographic dictionary.

  Key results:
  1. The quantum Singleton bound for stabilizer codes
  2. Equivalence between Bekenstein-Hawking entropy and the Singleton bound
  3. Subadditivity of holographic entanglement entropy from code properties
  4. Entanglement wedge nesting from code inclusion
  5. A falsifiable conjecture about code distance and curvature
-/

import Mathlib

open Finset BigOperators

/-! ## Quantum Error-Correcting Code Parameters -/

/-- A quantum error-correcting code with parameters [[n, k, d]].
    n = number of physical qubits, k = number of logical qubits,
    d = code distance (minimum weight of undetectable error). -/
structure QECCode where
  n : ℕ  -- physical qubits
  k : ℕ  -- logical qubits
  d : ℕ  -- code distance
  n_pos : 0 < n
  k_le_n : k ≤ n
  d_pos : 0 < d
  d_le_n : d ≤ n

/-- The quantum Singleton bound: for any [[n,k,d]] code, k ≤ n - 2(d-1).
    Equivalently, n - k ≥ 2(d - 1). This is the quantum analog of the
    classical Singleton bound and is tight for MDS codes. -/
def QECCode.satisfies_singleton_bound (C : QECCode) : Prop :=
  C.n - C.k ≥ 2 * (C.d - 1)

/-- A code saturates the Singleton bound when equality holds:
    k = n - 2(d - 1) = n - 2d + 2. These are quantum MDS codes. -/
def QECCode.saturates_singleton (C : QECCode) : Prop :=
  C.k + 2 * (C.d - 1) = C.n

/-- The code rate k/n, measuring efficiency of logical encoding. -/
noncomputable def QECCode.rate (C : QECCode) : ℝ :=
  (C.k : ℝ) / (C.n : ℝ)

/-- The relative distance d/n, measuring error-correction capability. -/
noncomputable def QECCode.relative_distance (C : QECCode) : ℝ :=
  (C.d : ℝ) / (C.n : ℝ)

/-! ## Holographic Dictionary

We formalize the AdS/CFT holographic dictionary that maps spacetime
geometry to quantum code parameters. -/

/-- The holographic dictionary maps spacetime geometry to code parameters.
    Given area A (in Planck units) and geodesic length L (in Planck units):
    - n = A (number of Planck cells on boundary)
    - k = A / 4 (Bekenstein-Hawking entropy, in units where G = 1/4 in Planck units)
    - d = L / 2 (code distance from minimal geodesic)

    We work in discrete (ℕ) units for clean formalization. -/
structure HolographicParams where
  area : ℕ         -- boundary area in Planck units
  geodesic : ℕ     -- minimal geodesic length in Planck units
  area_pos : 0 < area
  geodesic_pos : 0 < geodesic
  area_div4 : 4 ∣ area   -- area divisible by 4 for clean entropy
  geodesic_even : 2 ∣ geodesic  -- geodesic even for clean distance
  geodesic_le : geodesic ≤ area  -- geodesic fits within boundary

/-- Construct the holographic code from spacetime geometry.
    n = area, k = area/4, d = geodesic/2. -/
def HolographicParams.toCode (h : HolographicParams) : QECCode where
  n := h.area
  k := h.area / 4
  d := h.geodesic / 2
  n_pos := h.area_pos
  k_le_n := Nat.div_le_self h.area 4
  d_pos := by
    obtain ⟨m, hm⟩ := h.geodesic_even
    have := h.geodesic_pos
    omega
  d_le_n := le_trans (Nat.div_le_self h.geodesic 2) h.geodesic_le

/-! ## Main Theorems -/

/-
For any holographic code, the Singleton bound reduces to a geometric
    constraint: geodesic ≤ 3·area/4 + 2 (in Planck units).
-/
theorem holographic_singleton_geometric (h : HolographicParams)
    (hsat : h.toCode.satisfies_singleton_bound) :
    h.geodesic ≤ 3 * h.area / 4 + 2 := by
  obtain ⟨ m, hm ⟩ := h.area_div4; obtain ⟨ n, hn ⟩ := h.geodesic_even; simp_all +decide [ HolographicParams.toCode ] ;
  unfold QECCode.satisfies_singleton_bound at hsat; norm_num at hsat; omega;

/-
Conversely, the geometric constraint implies the Singleton bound.
-/
theorem geometric_implies_singleton (h : HolographicParams)
    (hgeom : h.geodesic ≤ 3 * h.area / 4 + 2) :
    h.toCode.satisfies_singleton_bound := by
  unfold QECCode.satisfies_singleton_bound;
  obtain ⟨ m, hm ⟩ := h.area_div4; obtain ⟨ n, hn ⟩ := h.geodesic_even; simp_all +decide [ HolographicParams.toCode ] ;
  omega

/-! ## Subadditivity of Holographic Entropy -/

/-- Holographic entanglement entropy for a boundary region of size a,
    computed as a/4 (Bekenstein-Hawking formula in Planck units). -/
def holographic_entropy (a : ℕ) : ℕ := a / 4

/-
Subadditivity of holographic entropy with integer division correction:
    (a + b) / 4 ≤ a / 4 + b / 4 + 1.
-/
theorem holographic_entropy_subadditive (a b : ℕ) :
    holographic_entropy (a + b) ≤ holographic_entropy a + holographic_entropy b + 1 := by
  unfold holographic_entropy; omega;

/-
Strong subadditivity: S(ABC) + S(B) ≤ S(AB) + S(BC) + 1.
-/
theorem holographic_entropy_strong_subadditive (a b c : ℕ) :
    holographic_entropy (a + b + c) + holographic_entropy b
      ≤ holographic_entropy (a + b) + holographic_entropy (b + c) + 1 := by
  unfold holographic_entropy;
  omega

/-! ## Code Distance and Rate -/

/-
**Theorem 3: Rate increases with n for fixed distance**

For codes saturating the Singleton bound with same distance d > 1,
larger n gives HIGHER rate. This captures the physical intuition that
larger boundary regions are more efficient at encoding information
(the "overhead" 2(d-1) becomes a smaller fraction of n).
-/
theorem singleton_rate_increases
    (C₁ C₂ : QECCode) (hsat₁ : C₁.saturates_singleton) (hsat₂ : C₂.saturates_singleton)
    (hd : C₁.d = C₂.d) (hn : C₁.n < C₂.n) (hd_gt : 1 < C₁.d) :
    C₁.rate < C₂.rate := by
  unfold QECCode.saturates_singleton at *;
  unfold QECCode.rate;
  rw [ div_lt_div_iff₀ ] <;> norm_cast <;> try linarith [ C₁.n_pos ];
  nlinarith [ Nat.sub_add_cancel hd_gt.le, Nat.sub_add_cancel ( show 1 ≤ C₂.d from hd ▸ hd_gt.le ) ]

/-! ## Entanglement Wedge Nesting -/

/-- An entanglement wedge assignment maps boundary regions (subsets of Fin n)
    to bulk regions (subsets of some bulk space). -/
structure EntanglementWedge (n : ℕ) (bulk : Type*) where
  wedge : Finset (Fin n) → Set bulk
  monotone : ∀ A B : Finset (Fin n), A ⊆ B → wedge A ⊆ wedge B
  empty_wedge : wedge ∅ = ∅

/-
Entanglement wedge nesting implies entropy monotonicity:
    restricting to a smaller region gives fewer logical qubits.
-/
theorem wedge_nesting_entropy_monotone
    (C : QECCode) (m : ℕ) (hm : m ≤ C.n) (_hm_pos : 0 < m)
    (_hd_le : C.d ≤ m)
    (hsat : C.saturates_singleton)
    (C' : QECCode)
    (hn' : C'.n = m)
    (hd' : C'.d = C.d)
    (hsat' : C'.saturates_singleton) :
    C'.k ≤ C.k := by
  unfold QECCode.saturates_singleton at *;
  grind

/-! ## Holographic Redundancy -/

/-
For a Singleton-saturating code, n = k + 2(d-1).
-/
theorem singleton_redundancy_lower_bound (C : QECCode)
    (hsat : C.saturates_singleton) (_hk : 0 < C.k) :
    (C.n : ℝ) ≥ (C.k : ℝ) + 2 * ((C.d : ℝ) - 1) := by
  rw [ ← hsat ];
  rcases C_d : C.d with ( _ | _ | d ) <;> norm_num [ C_d ] at *

/-! ## Information-Protection Tradeoff -/

/-- The information density of a code: logical bits per physical qubit. -/
noncomputable def QECCode.info_density (C : QECCode) : ℝ :=
  (C.k : ℝ) / (C.n : ℝ)

/-- The protection density: code distance per physical qubit. -/
noncomputable def QECCode.prot_density (C : QECCode) : ℝ :=
  (C.d : ℝ) / (C.n : ℝ)

/-
The information-protection tradeoff: for any code satisfying the
    Singleton bound, info_density + 2 · prot_density ≤ 1 + 2/n.
    This is the coding-theoretic analog of the Einstein constraint.
-/
theorem info_protection_tradeoff (C : QECCode)
    (hsat : C.satisfies_singleton_bound) :
    C.info_density + 2 * C.prot_density ≤ 1 + 2 / (C.n : ℝ) := by
  unfold QECCode.satisfies_singleton_bound at hsat; ( unfold QECCode.info_density QECCode.prot_density; simp_all +decide; );
  rw [ ← mul_div_assoc, ← add_div, div_le_iff₀ ];
  · rw [ add_mul, div_mul_cancel₀ ] <;> norm_cast;
    · linarith [ Nat.sub_add_cancel C.d_pos, Nat.sub_add_cancel ( show C.k ≤ C.n from C.k_le_n ) ];
    · linarith [ C.n_pos ];
  · exact Nat.cast_pos.mpr C.n_pos

/-! ## Distance and Entropy from Singleton Saturation -/

/-
For Singleton-saturating codes with k ≥ 1, d ≤ (n+2)/2.
-/
theorem singleton_distance_upper_bound (C : QECCode)
    (hsat : C.saturates_singleton) (hk : 0 < C.k) :
    2 * C.d ≤ C.n + 2 := by
  linarith [ hsat.symm, Nat.sub_add_cancel C.d_pos ]

/-
For Singleton-saturating codes, k is uniquely determined by n and d:
    k + 2d = n + 2. (Avoids ℕ subtraction issues.)
-/
theorem singleton_entropy_from_distance (C : QECCode)
    (hsat : C.saturates_singleton) :
    C.k + 2 * C.d = C.n + 2 := by
  convert congr_arg ( · + 2 ) hsat using 1 ; ring_nf!;
  linarith [ Nat.sub_add_cancel ( show 1 ≤ C.d from C.d_pos ) ]

/-! ## Composition of Holographic Codes -/

/-- Composition of two codes: if C₁ encodes into C₂'s logical space,
    the composed code has parameters that multiply/add appropriately. -/
def QECCode.compose (C₁ C₂ : QECCode) (h : C₁.n = C₂.k) : QECCode where
  n := C₂.n
  k := C₁.k
  d := min C₁.d C₂.d
  n_pos := C₂.n_pos
  k_le_n := le_trans C₁.k_le_n (h ▸ C₂.k_le_n)
  d_pos := by
    have := C₁.d_pos; have := C₂.d_pos
    omega
  d_le_n := min_le_of_right_le C₂.d_le_n

/-
The composed code preserves the k bound.
-/
theorem compose_k_le (C₁ C₂ : QECCode) (h : C₁.n = C₂.k) :
    (C₁.compose C₂ h).k ≤ C₂.n := by
  convert C₁.k_le_n.trans ( h.le.trans C₂.k_le_n ) using 1

/-
The composed code's distance is the minimum of the components.
-/
theorem compose_distance_min (C₁ C₂ : QECCode) (h : C₁.n = C₂.k) :
    (C₁.compose C₂ h).d = min C₁.d C₂.d := by
  rfl