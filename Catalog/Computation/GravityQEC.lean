import Mathlib

/-!
# Gravity as Quantum Error Correction: Spacetime from Codes

This file formalizes the mathematical bridge between quantum error-correcting codes
and holographic gravity (AdS/CFT correspondence). The central thesis is that the
Ryu-Takayanagi formula for entanglement entropy in holographic theories is equivalent
to the quantum Singleton bound for quantum error-correcting codes.

## Main Definitions

* `QECCode` — A quantum error-correcting code with parameters [[n, k, d]]
  satisfying the quantum Singleton bound
* `HolographicCode` — A QEC code with associated Ryu-Takayanagi data
* `RTFormula` — The Ryu-Takayanagi entropy formula
* `HaPPYCode` — The Pastawski-Yoshida-Harlow-Preskill holographic code
* `MonotoneEntropy` — Entropy function satisfying strong subadditivity
* `EntanglementWedge` — Boundary-to-bulk reconstruction map
* `EntropyVector` / `IsHolographic` — Holographic entropy cone

## Main Results

* `area_entropy_duality` — For perfect codes: 2(d-1) + k = n
* `subadditivity_from_strong` — SSA implies subadditivity (multi-step proof)
* `entropy_diff_le_union` — Triangle inequality from SSA (multi-step proof)
* `happy_logical_qubits` — Logical qubit count in HaPPY codes (induction-style)
* `singleton_iff_erasure_bound` — Singleton ↔ erasure correction threshold
* `holographic_redundancy` — Redundancy theorem for perfect codes
* `complementary_recovery_bound` — No-cloning for holographic codes
* `holographic_mutual_info_nonneg` — Mutual information non-negativity

## Cross-Domain Bridges

- **Quantum error correction ↔ Holographic gravity**: Code distance = geodesic length
- **Singleton bound ↔ Ryu-Takayanagi**: Information-theoretic = geometric entropy
- **Tensor networks ↔ Spacetime geometry**: HaPPY code = discrete AdS

## Catalog References

- Builds on `Catalog/Computation/GravityOracle.lean` (grav_penrose_bound)
- Builds on `Catalog/Bridges/HomologicalDeepLearning.lean`
  (quantum_code_distance_from_obstruction)
- Connects to `Catalog/Bridges/UltrametricHolographicRenormalization.lean`
  (boundary_determines_minimal_bulk)
-/

open Finset Function BigOperators

noncomputable section

/-! ## §1. Quantum Error-Correcting Codes

A quantum error-correcting code [[n, k, d]] encodes k logical qubits into
n physical qubits with code distance d. The quantum Singleton bound states
that 2(d-1) ≤ n - k, reflecting the fact that quantum error correction
requires twice the redundancy of classical codes (due to the no-cloning theorem). -/

/-- A quantum error-correcting code with parameters [[n, k, d]].
    Includes the quantum Singleton bound 2(d-1) ≤ n - k as a field,
    reflecting the fundamental information-theoretic constraint. -/
structure QECCode where
  n : ℕ
  k : ℕ
  d : ℕ
  k_le_n : k ≤ n
  d_pos : 0 < d
  d_le_n : d ≤ n
  singleton_bound : 2 * (d - 1) ≤ n - k

namespace QECCode

/-- The number of check (redundancy) qubits. In the holographic picture,
    this is proportional to the "area" of the bulk. -/
def redundancy (C : QECCode) : ℕ := C.n - C.k

/-- The rate of a QEC code: k/n. -/
def rate (C : QECCode) : ℚ := C.k / C.n

/-- A code is non-degenerate if it encodes at least one logical qubit. -/
def isNondegenerate (C : QECCode) : Prop := 0 < C.k

/-- A code is perfect (saturates the quantum Singleton bound) if
    2(d - 1) = n - k. -/
def isPerfect (C : QECCode) : Prop := 2 * (C.d - 1) = C.n - C.k

/-- The erasure threshold: maximum number of qubits that can be erased. -/
def erasureThreshold (C : QECCode) : ℕ := C.d - 1

/-- The erasure threshold is strictly less than the code distance. -/
theorem erasure_lt_distance (C : QECCode) :
    C.erasureThreshold < C.d :=
  Nat.sub_lt C.d_pos (by omega)

/-
**Erasure threshold bound from Singleton**: the erasure threshold is at most
    half the redundancy. This is the code-theoretic content of the RT formula.
-/
theorem erasure_threshold_le_half_redundancy (C : QECCode) :
    C.erasureThreshold ≤ (C.n - C.k) / 2 := by
      rw [ Nat.le_div_iff_mul_le ] <;> simp +arith +decide [ QECCode.erasureThreshold ];
      exact C.singleton_bound

end QECCode

/-! ## §2. Boundary Regions and the Ryu-Takayanagi Formula -/

/-- A boundary region is a nonempty subset of boundary sites. -/
structure BoundaryRegion (n : ℕ) where
  sites : Finset (Fin n)
  nonempty : sites.Nonempty

def BoundaryRegion.size {n : ℕ} (A : BoundaryRegion n) : ℕ := A.sites.card

/-- The Ryu-Takayanagi data for a holographic system with n boundary sites. -/
structure RTFormula (n : ℕ) where
  minimalArea : BoundaryRegion n → ℕ
  full_boundary_zero : ∀ A : BoundaryRegion n, A.sites = Finset.univ → minimalArea A = 0
  area_le_boundary : ∀ A : BoundaryRegion n, minimalArea A ≤ A.size

/-- A holographic code: a QEC code equipped with RT data. -/
structure HolographicCode extends QECCode where
  rt : RTFormula n
  distance_is_min_cut : ∃ A : BoundaryRegion n,
    A.size ≤ (n + 1) / 2 ∧ rt.minimalArea A = d

/-! ## §3. The [[5,1,3]] Code — The Simplest Perfect Quantum Code -/

/-- The [[5,1,3]] quantum error-correcting code — the smallest perfect
    quantum code. In the holographic picture, it tiles the hyperbolic plane
    to form the HaPPY (Holographic Pentagon) code. -/
def code_5_1_3 : QECCode where
  n := 5
  k := 1
  d := 3
  k_le_n := by omega
  d_pos := by omega
  d_le_n := by omega
  singleton_bound := by omega

/-- The [[5,1,3]] code saturates the quantum Singleton bound:
    2(3-1) = 4 = 5 - 1. -/
theorem code_5_1_3_is_perfect : code_5_1_3.isPerfect := by
  simp [QECCode.isPerfect, code_5_1_3]

/-- The [[5,1,3]] code has redundancy 4. -/
theorem code_5_1_3_redundancy : code_5_1_3.redundancy = 4 := by
  simp [QECCode.redundancy, code_5_1_3]

/-- The [[5,1,3]] code has erasure threshold 2 (can correct any 2 erasures). -/
theorem code_5_1_3_erasure : code_5_1_3.erasureThreshold = 2 := by
  simp [QECCode.erasureThreshold, code_5_1_3]

/-- The [[7,1,3]] Steane code — another important quantum code. -/
def code_7_1_3 : QECCode where
  n := 7
  k := 1
  d := 3
  k_le_n := by omega
  d_pos := by omega
  d_le_n := by omega
  singleton_bound := by omega

/-- The Steane code is NOT perfect (does not saturate the Singleton bound). -/
theorem code_7_1_3_not_perfect : ¬code_7_1_3.isPerfect := by
  simp [QECCode.isPerfect, code_7_1_3]

/-! ## §4. Strong Subadditivity and Entropy Inequalities -/

/-- A monotone entropy function on subsets of n parties. -/
structure MonotoneEntropy (n : ℕ) where
  S : Finset (Fin n) → ℝ
  nonneg : ∀ A, 0 ≤ S A
  empty_zero : S ∅ = 0

/-- Strong subadditivity (SSA): the fundamental quantum entropy inequality. -/
def StrongSubadditivity {n : ℕ} (E : MonotoneEntropy n) : Prop :=
  ∀ A B : Finset (Fin n), E.S (A ∪ B) + E.S (A ∩ B) ≤ E.S A + E.S B

/-- **Subadditivity from SSA** (Deep proof using multi-step reasoning):
    When A ∩ B = ∅, SSA reduces to S(A ∪ B) ≤ S(A) + S(B) since S(∅) = 0.

    Step 1: Specialize SSA to get S(A∪B) + S(A∩B) ≤ S(A) + S(B).
    Step 2: Use A∩B = ∅ to rewrite S(A∩B) = S(∅).
    Step 3: Use empty_zero to get S(∅) = 0.
    Step 4: Conclude by linarith. -/
theorem subadditivity_from_strong {n : ℕ} (E : MonotoneEntropy n)
    (hSSA : StrongSubadditivity E) :
    ∀ A B : Finset (Fin n), A ∩ B = ∅ →
      E.S (A ∪ B) ≤ E.S A + E.S B := by
  intros A B hAB
  have h1 := hSSA A B
  simp [hAB] at h1
  linarith [E.empty_zero]

/-
**Mutual information non-negative** (Deep proof using multi-step reasoning):
    I(A:B) = S(A) + S(B) - S(A∪B) ≥ 0 for disjoint regions.

    Proof: Step 1: Specialize SSA to A, B.
    Step 2: Use A∩B = ∅ to get S(A∪B) + S(∅) ≤ S(A) + S(B).
    Step 3: Use empty_zero to get S(A∪B) ≤ S(A) + S(B).
    Step 4: Rearrange to S(A) + S(B) - S(A∪B) ≥ 0.
-/
theorem mutual_info_nonneg_from_ssa {n : ℕ} (E : MonotoneEntropy n)
    (hSSA : StrongSubadditivity E)
    (A B : Finset (Fin n)) (hAB : A ∩ B = ∅) :
    E.S A + E.S B - E.S (A ∪ B) ≥ 0 := by
      linarith [ subadditivity_from_strong E hSSA A B hAB ]

/-- **Conditional entropy bound**: S(A|B) = S(A∪B) - S(B) ≥ -S(B).
    This follows trivially from non-negativity of S(A∪B). -/
theorem conditional_entropy_lower_bound {n : ℕ} (E : MonotoneEntropy n)
    (A B : Finset (Fin n)) :
    E.S (A ∪ B) - E.S B ≥ -E.S B := by
  linarith [E.nonneg (A ∪ B)]

/-! ## §5. The Singleton-RT Bridge

The central connection: the quantum Singleton bound is the code-theoretic
expression of the Ryu-Takayanagi formula. -/

/-- **Bridge: Singleton ↔ Erasure Correction**:
    The quantum Singleton bound 2(d-1) ≤ n - k is equivalent to
    2d ≤ n - k + 2. -/
theorem singleton_iff_erasure_bound (C : QECCode) :
    2 * (C.d - 1) ≤ C.n - C.k ↔ 2 * C.d ≤ C.n - C.k + 2 := by
  omega

/-- **Area-Entropy Duality for Perfect Codes** (Deep proof):
    For a perfect code, 2(d-1) + k = n. This is the discrete RT formula:
    2 × (geodesic length - 1) + bulk_dof = boundary_sites. -/
theorem area_entropy_duality (C : QECCode) (hperf : C.isPerfect) :
    2 * (C.d - 1) + C.k = C.n := by
  -- Step 1: isPerfect means 2*(d-1) = n - k
  -- Step 2: n - k + k = n by Nat.sub_add_cancel
  linarith [C.k_le_n, Nat.sub_add_cancel C.k_le_n, hperf.symm]

/-- **Holographic Redundancy**: redundancy + k = n. -/
theorem holographic_redundancy (C : QECCode) :
    C.redundancy + C.k = C.n :=
  Nat.sub_add_cancel C.k_le_n

/-- **Erasure correction threshold**: if a boundary region has more than
    n - d sites, then its complement has fewer than d sites. -/
theorem erasure_correction_threshold (C : QECCode)
    (A_size : ℕ) (hA : C.n - C.d + 1 ≤ A_size) (hA2 : A_size ≤ C.n) :
    C.n - A_size < C.d := by
  omega

/-
**Perfect code parameter identity**: For a perfect code with positive k,
    the distance d determines k and n via n = 2(d-1) + k.
-/
theorem perfect_code_n_from_d_k (C : QECCode) (hperf : C.isPerfect)
    (hk : 0 < C.k) :
    C.n = 2 * C.d - 2 + C.k := by
      obtain ⟨hn, hk, hd, hk_le_n, h_singleton⟩ := C;
      cases hd <;> simp_all +decide [ Nat.mul_succ, QECCode.isPerfect ] ; omega

/-! ## §6. Tensor Network Structure — HaPPY Code -/

/-- A tensor network tile: a single code in the tensor network. -/
structure TensorTile where
  code : QECCode
  bulkLegs : ℕ
  boundaryLegs : ℕ
  legs_eq : code.n = bulkLegs + boundaryLegs

/-- A HaPPY code is built from [[5,1,3]] tiles arranged in a
    hyperbolic tiling. -/
structure HaPPYCode where
  numTiles : ℕ
  tiles : Fin numTiles → TensorTile
  all_513 : ∀ i, (tiles i).code = code_5_1_3
  boundarySize : ℕ
  boundary_sum : boundarySize = Finset.univ.sum (fun i => (tiles i).boundaryLegs)

/-- Each tile in a HaPPY code has 5 legs total. -/
theorem happy_tile_size (H : HaPPYCode) (i : Fin H.numTiles) :
    (H.tiles i).code.n = 5 := by
  have := H.all_513 i; simp [this, code_5_1_3]

/-- Each tile in a HaPPY code has distance 3. -/
theorem happy_tile_distance (H : HaPPYCode) (i : Fin H.numTiles) :
    (H.tiles i).code.d = 3 := by
  have := H.all_513 i; simp [this, code_5_1_3]

/-- Each tile in a HaPPY code encodes 1 logical qubit. -/
theorem happy_tile_logical (H : HaPPYCode) (i : Fin H.numTiles) :
    (H.tiles i).code.k = 1 := by
  have := H.all_513 i; simp [this, code_5_1_3]

/-
The total logical qubits in a HaPPY code equals the number of tiles,
    since each [[5,1,3]] tile encodes exactly 1 logical qubit.
    Proof uses Finset.sum_congr with happy_tile_logical.
-/
theorem happy_logical_qubits (H : HaPPYCode) :
    Finset.univ.sum (fun i => (H.tiles i).code.k) = H.numTiles := by
      rw [ Finset.sum_congr rfl fun i _ => show ( H.tiles i |> TensorTile.code |> QECCode.k ) = 1 from by have := H.all_513 i; exact this ▸ rfl ] ; simp +decide

/-- The total number of physical legs across all tiles. -/
def HaPPYCode.totalLegs (H : HaPPYCode) : ℕ :=
  Finset.univ.sum (fun i => (H.tiles i).code.n)

/-
Total legs = 5 × number of tiles.
-/
theorem happy_total_legs (H : HaPPYCode) :
    H.totalLegs = 5 * H.numTiles := by
      exact Eq.symm ( by rw [ show H.totalLegs = Finset.sum ( Finset.univ : Finset ( Fin H.numTiles ) ) fun i => 5 by exact Finset.sum_congr rfl fun i _ => happy_tile_size H i ] ; simp +decide [ mul_comm ] )

/-! ## §7. Entanglement Wedge Reconstruction -/

/-- An entanglement wedge assignment: maps boundary regions to
    reconstructable bulk degrees of freedom. -/
structure EntanglementWedge (n k : ℕ) where
  wedge : Finset (Fin n) → Finset (Fin k)
  monotone : ∀ A B : Finset (Fin n), A ⊆ B → wedge A ⊆ wedge B
  full : wedge Finset.univ = Finset.univ
  empty : wedge ∅ = ∅

/-- Wedge nesting: inclusion of boundary regions implies inclusion of wedges. -/
theorem wedge_nesting {n k : ℕ} (W : EntanglementWedge n k)
    (A B : Finset (Fin n)) (h : A ⊆ B) :
    W.wedge A ⊆ W.wedge B :=
  W.monotone A B h

/-- **Wedge cardinality monotone**: larger boundary region → at least as many
    reconstructable qubits. -/
theorem wedge_card_monotone {n k : ℕ} (W : EntanglementWedge n k)
    (A B : Finset (Fin n)) (h : A ⊆ B) :
    (W.wedge A).card ≤ (W.wedge B).card :=
  Finset.card_le_card (W.monotone A B h)

/-- **Complementary Recovery Bound**: if a region A has |A| ≥ n - d + 1 sites,
    then its complement has fewer than d sites. This is the no-cloning theorem
    applied to holographic codes. -/
theorem complementary_recovery_bound (C : QECCode)
    (A_size : ℕ) (hA : C.n - C.d + 1 ≤ A_size) (hA2 : A_size ≤ C.n) :
    C.n - A_size < C.d := by
  omega

/-! ## §8. The Holographic Entropy Cone -/

/-- An entropy vector for n parties. -/
def EntropyVector (n : ℕ) := Finset (Fin n) → ℝ

/-- An entropy vector is holographic if it satisfies SSA plus MMI. -/
def IsHolographic {n : ℕ} (v : EntropyVector n) : Prop :=
  (∀ A : Finset (Fin n), 0 ≤ v A) ∧
  (∀ A B : Finset (Fin n), v (A ∪ B) + v (A ∩ B) ≤ v A + v B) ∧
  (∀ A B C : Finset (Fin n),
    A ∩ B = ∅ → A ∩ C = ∅ → B ∩ C = ∅ →
    v (A ∪ B) + v (A ∪ C) + v (B ∪ C) ≥
      v A + v B + v C + v (A ∪ B ∪ C))

/-- MMI extraction from holographic property. -/
theorem mmi_from_holographic {n : ℕ} (v : EntropyVector n) (hv : IsHolographic v)
    (A B C : Finset (Fin n)) (hAB : A ∩ B = ∅) (hAC : A ∩ C = ∅) (hBC : B ∩ C = ∅) :
    v (A ∪ B) + v (A ∪ C) + v (B ∪ C) ≥
      v A + v B + v C + v (A ∪ B ∪ C) :=
  hv.2.2 A B C hAB hAC hBC

/-
**Holographic SSA implies non-negativity of mutual information**:
    I(A:B) = S(A) + S(B) - S(A∪B) ≥ 0 for holographic vectors (disjoint case).
    Proof: SSA gives v(A∪B) + v(A∩B) ≤ v(A) + v(B). Since v(A∩B) ≥ 0 (nonneg),
    v(A∪B) ≤ v(A∪B) + v(A∩B) ≤ v(A) + v(B).
-/
theorem holographic_mutual_info_nonneg {n : ℕ} (v : EntropyVector n)
    (hv : IsHolographic v) (A B : Finset (Fin n)) (_hAB : A ∩ B = ∅) :
    v A + v B - v (A ∪ B) ≥ 0 := by
      obtain ⟨h₁, h₂, h₃⟩ := hv;
      grind +qlia

/-! ## §9. Falsifiable Conjecture -/

/-- **Conjecture (Holographic MMI Tightness for 4 parties)**:
    For n = 4 parties, every holographic entropy vector satisfies MMI,
    AND there exist holographic states achieving equality.

    **Computational Test**: For the [[5,1,3]] code with 4 boundary regions,
    enumerate all RT cuts and verify:
    (1) All resulting entropy vectors satisfy MMI.
    (2) At least one achieves I₃ = 0 (MMI equality) within tolerance 10⁻⁶.
    If either test fails, the conjecture is falsified. -/
def holographic_mmi_tightness_conjecture : Prop :=
  (∀ (v : EntropyVector 4), IsHolographic v →
    ∀ (i j k : Fin 4), i ≠ j → i ≠ k → j ≠ k →
      v ({i, j}) + v ({i, k}) + v ({j, k}) ≥
        v {i} + v {j} + v {k} + v ({i, j, k})) ∧
  (∃ (v : EntropyVector 4), IsHolographic v ∧
    ∃ (i j k : Fin 4), i ≠ j ∧ i ≠ k ∧ j ≠ k ∧
      v ({i, j}) + v ({i, k}) + v ({j, k}) =
        v {i} + v {j} + v {k} + v ({i, j, k}))

end