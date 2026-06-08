/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Gravity from Information: Spacetime as a Quantum Error-Correcting Code

This module formalizes the correspondence between quantum error-correcting codes
and holographic spacetime geometry. The central thesis is that the
Bekenstein-Hawking entropy formula S = A/(4G) is precisely the quantum
Singleton bound for an [[n,k,d]] stabilizer code, where:
  - n = number of Planck-area cells on a boundary spatial slice
  - k = number of logical qubits (= Bekenstein-Hawking entropy)
  - d = code distance (= minimal bulk geodesic length in Planck units)

## Main Definitions

* `StabilizerCodeParams` — Parameters [[n,k,d]] of a quantum stabilizer code
* `HolographicCode` — Code whose parameters derive from spacetime geometry
* `HolographicEntropy` — Entropy functional satisfying Ryu-Takayanagi properties
* `EntanglementWedge` — Region assignment satisfying nesting and complementarity

## Main Results

* `rt_implies_strengthened_singleton` — RT formula strengthens Singleton bound
* `singleton_constrains_geodesic` — Singleton bound constrains geodesic length
* `ssa_implies_subadditivity` — SSA implies subadditivity for holographic entropy
* `wedge_inter_subset` — Entanglement wedge monotonicity under intersection
* `wedge_univ_eq_univ` — Full boundary wedge covers entire bulk
* `ryu_takayanagi_determines_entropy` — RT formula determines entropy from area
* `saturated_determines_distance` — Singleton saturation + RT fixes code distance
* `monogamy_from_holography` — Monogamy of entanglement from holographic SSA
* `ads3_saturates_singleton` — AdS₃ code saturates the Singleton bound

## References

* Almheiri, Dong, Harlow — "Bulk Locality and Quantum Error Correction in AdS/CFT"
* Pastawski, Yoshida, Harlow, Preskill — "Holographic quantum error-correcting codes"
* Harlow — "The Ryu-Takayanagi formula from quantum error correction"
-/
import Mathlib

open Finset BigOperators

noncomputable section

/-! ## Core Code Parameters -/

/-- Parameters of a quantum stabilizer code [[n, k, d]].
    n = number of physical qubits (boundary degrees of freedom)
    k = number of logical qubits (bulk degrees of freedom)
    d = code distance (minimum weight of undetectable error) -/
structure StabilizerCodeParams where
  n : ℕ  -- physical qubits
  k : ℕ  -- logical qubits
  d : ℕ  -- code distance
  k_le_n : k ≤ n
  d_pos : 0 < d
  d_le_n : d ≤ n

/-- The quantum Singleton bound: the fundamental constraint on quantum codes.
    For an [[n,k,d]] stabilizer code, we must have k ≤ n - 2(d - 1),
    equivalently k + 2d ≤ n + 2. -/
def satisfiesSingletonBound (c : StabilizerCodeParams) : Prop :=
  c.k + 2 * c.d ≤ c.n + 2

/-- A code saturates the Singleton bound when k = n - 2d + 2.
    These are the "perfect" quantum codes, analogous to MDS codes classically. -/
def saturatesSingletonBound (c : StabilizerCodeParams) : Prop :=
  c.k + 2 * c.d = c.n + 2

/-! ## Holographic Code -/

/-- A holographic code is a stabilizer code whose parameters are determined by
    spacetime geometry. The Ryu-Takayanagi condition states 4k = n. -/
structure HolographicCode where
  params : StabilizerCodeParams
  boundaryArea : ℕ  -- in Planck units
  bulkGeodesicLength : ℕ  -- in Planck units (twice the code distance)
  area_eq_n : boundaryArea = params.n
  geodesic_eq_2d : bulkGeodesicLength = 2 * params.d
  /-- The Ryu-Takayanagi / Bekenstein-Hawking condition:
      entropy = area / 4, encoded as 4 * k = n. -/
  rt_formula : 4 * params.k = params.n

/-! ## Singleton Bound Theory -/

/-
**Main Theorem**: The Ryu-Takayanagi formula implies a strengthened Singleton bound.
    If entropy = n/4 and the Singleton bound holds, then 8*d ≤ 3*n + 8.
    Proof: from 4k = n we get k = n/4. Substituting into k + 2d ≤ n + 2 gives
    n/4 + 2d ≤ n + 2, hence 8d ≤ 3n + 8.
-/
theorem rt_implies_strengthened_singleton (c : StabilizerCodeParams)
    (hrt : 4 * c.k = c.n) (hsb : satisfiesSingletonBound c) :
    8 * c.d ≤ 3 * c.n + 8 := by
  unfold satisfiesSingletonBound at hsb; linarith;

/-
Every holographic code satisfying the Singleton bound gives a constraint on
    the geodesic length relative to the boundary area.
-/
theorem singleton_constrains_geodesic (hc : HolographicCode)
    (hsb : satisfiesSingletonBound hc.params) :
    4 * hc.bulkGeodesicLength ≤ 3 * hc.boundaryArea + 8 := by
  -- Open up the definitions of HolographicCode to get at the underlying stabilizer code parameters.
  -- Then we can apply the.rt_implies_strengthened_singleton lemma to obtain the desired inequality in terms of $params.n$ and $params.d$.
  rcases hc with ⟨⟨n, k, d, co_k_le_n, co_d_pos, co_d_le_n⟩, boundaryArea, bulkGeodesicLength, area_eq_n, geodesic_eq_2d, rt_formula⟩
  have := rt_implies_strengthened_singleton ⟨n, k, d, co_k_le_n, co_d_pos, co_d_le_n⟩ rt_formula hsb
  simp_all;
  linarith

/-! ## Holographic Entropy Functional -/

/-- A holographic entropy functional on subsets of a finite boundary type.
    Models the von Neumann entropy of boundary subregions.
    This is a novel abstraction: a "holographic entropy system" axiomatizing
    the properties shared by all holographic theories (non-negativity,
    complementarity, and purity of the global state). -/
structure HolographicEntropy (β : Type*) [Fintype β] [DecidableEq β] where
  /-- Entropy of a boundary region -/
  S : Finset β → ℝ
  /-- Entropy is non-negative -/
  S_nonneg : ∀ A, 0 ≤ S A
  /-- Empty region has zero entropy -/
  S_empty : S ∅ = 0
  /-- The full boundary has zero entropy (pure state) -/
  S_full : S Finset.univ = 0
  /-- Complementarity: S(A) = S(Aᶜ) for a pure global state -/
  S_complement : ∀ A, S A = S Aᶜ

variable {β : Type*} [Fintype β] [DecidableEq β]

/-- Strong subadditivity: S(ABC) + S(B) ≤ S(AB) + S(BC).
    This is the fundamental inequality of quantum information theory. -/
def strongSubadditivity (H : HolographicEntropy β) : Prop :=
  ∀ A B C : Finset β, A ∩ B = ∅ → B ∩ C = ∅ → A ∩ C = ∅ →
    H.S (A ∪ B ∪ C) + H.S B ≤ H.S (A ∪ B) + H.S (B ∪ C)

/-- Subadditivity: S(AB) ≤ S(A) + S(B) for disjoint regions. -/
def subadditivity (H : HolographicEntropy β) : Prop :=
  ∀ A B : Finset β, A ∩ B = ∅ → H.S (A ∪ B) ≤ H.S A + H.S B

/-
**Theorem**: Strong subadditivity implies subadditivity.
    Proof: specialize SSA with C = ∅. Then A ∪ B ∪ ∅ = A ∪ B, B ∪ ∅ = B,
    and S(∅) = 0, giving S(A∪B) + 0 ≤ S(A) + S(B).
-/
theorem ssa_implies_subadditivity
    (H : HolographicEntropy β) (hssa : strongSubadditivity H) :
    subadditivity H := by
  intro A B h;
  convert hssa A ∅ B _ _ _ using 1 <;> simp +decide [ h ];
  exact H.S_empty

/-! ## Entanglement Wedge and Region Monotonicity -/

/-- An entanglement wedge assignment maps each boundary region to a "bulk region"
    (modeled as a set of bulk points). The key axioms are:
    1. Nesting: A ⊆ B implies wedge(A) ⊆ wedge(B)
    2. Complementarity: wedge(A) ∪ wedge(Aᶜ) = bulk -/
structure EntanglementWedge (β : Type*) (bulk : Type*) [Fintype β] [DecidableEq β] where
  /-- The entanglement wedge of a boundary region -/
  wedge : Finset β → Set bulk
  /-- Nesting / monotonicity: larger boundary → larger bulk wedge -/
  nesting : ∀ A B : Finset β, A ⊆ B → wedge A ⊆ wedge B
  /-- Complementarity: the wedge of the complement covers the rest of the bulk -/
  complementary : ∀ A : Finset β, wedge A ∪ wedge Aᶜ = Set.univ

variable {bulk : Type*}

/-
**Theorem**: The entanglement wedge of A ∩ B is contained in both wedge(A) and wedge(B).
    Proof: A ∩ B ⊆ A and A ∩ B ⊆ B, so by nesting, wedge(A∩B) ⊆ wedge(A) and
    wedge(A∩B) ⊆ wedge(B).
-/
theorem wedge_inter_subset
    (W : EntanglementWedge β bulk) (A B : Finset β) :
    W.wedge (A ∩ B) ⊆ W.wedge A ∩ W.wedge B := by
  exact Set.subset_inter ( W.nesting _ _ ( Finset.inter_subset_left ) ) ( W.nesting _ _ ( Finset.inter_subset_right ) )

/-
**Theorem**: The wedge of the full boundary is the entire bulk.
    Proof: By complementarity, wedge(univ) ∪ wedge(univᶜ) = univ.
    Since univᶜ = ∅, wedge(∅) ⊆ wedge(univ) by nesting (∅ ⊆ univ).
    Hence wedge(univ) ∪ wedge(univ) = wedge(univ) ⊇ univ.
-/
theorem wedge_univ_eq_univ
    (W : EntanglementWedge β bulk) :
    W.wedge Finset.univ = Set.univ := by
  have := W.complementary ∅; simp_all +decide [ Set.ext_iff ] ;
  intro x; specialize this x; cases this <;> have := W.nesting ∅ univ <;> aesop;

/-! ## Error Correction from Code Distance -/

/-- The error correction capacity: a code of distance d can correct
    any erasure pattern of size at most ⌊(d-1)/2⌋. -/
def erasureCorrectionCapacity (c : StabilizerCodeParams) : ℕ :=
  (c.d - 1) / 2

/-
**Theorem**: For a saturated holographic code (4k = n, k + 2d = n + 2),
    the erasure correction capacity is (3k)/4.
    Proof: d = (3k + 2)/2, so (d-1)/2 = ((3k+2)/2 - 1)/2 = (3k)/4.
-/
theorem erasure_capacity_of_saturated_holographic (c : StabilizerCodeParams)
    (hrt : 4 * c.k = c.n) (hsat : saturatesSingletonBound c) :
    erasureCorrectionCapacity c = 3 * c.k / 4 := by
  grind +locals

/-! ## Ryu-Takayanagi as Singleton Saturation -/

/-
**Key Theorem**: The RT formula determines entropy from area.
-/
theorem ryu_takayanagi_determines_entropy (c : StabilizerCodeParams)
    (hrt : 4 * c.k = c.n) :
    c.k = c.n / 4 := by
  rw [ ← hrt, Nat.mul_div_cancel_left _ ( by decide ) ]

/-
**Key Theorem**: When the code also saturates Singleton, the distance
    is uniquely determined: 2*d = 3*k + 2.
-/
theorem saturated_determines_distance (c : StabilizerCodeParams)
    (hrt : 4 * c.k = c.n) (hsat : saturatesSingletonBound c) :
    2 * c.d = 3 * c.k + 2 := by
  linarith [ hsat.symm ]

/-! ## Monogamy of Entanglement from Code Structure -/

/-
**Theorem**: For a holographic entropy satisfying SSA and complementarity,
    the mutual information I(A:C) is bounded by 2 * S(A).
    Proof: SSA gives S(ABC) + S(B) ≤ S(AB) + S(BC).
    Since ABC = univ (by hfull), S(ABC) = 0.
    By complementarity, S(BC) = S((BC)ᶜ) = S(A).
    So S(B) ≤ S(AB) + S(A) - 0 = S(AB) + S(A).
    We need S(A) + S(C) - S(AC) ≤ 2*S(A).
    By complementarity S(C) = S(AB) and S(AC) = S(B).
    So the claim becomes S(A) + S(AB) - S(B) ≤ 2*S(A),
    i.e. S(AB) - S(B) ≤ S(A), i.e. S(AB) ≤ S(A) + S(B).
    This follows from subadditivity (which follows from SSA).
-/
theorem monogamy_from_holography
    (H : HolographicEntropy β) (hssa : strongSubadditivity H)
    (A B C : Finset β) (hdisj_ab : A ∩ B = ∅) (hdisj_bc : B ∩ C = ∅)
    (hdisj_ac : A ∩ C = ∅)
    (hfull : A ∪ B ∪ C = Finset.univ) :
    H.S A + H.S C - H.S (A ∪ C) ≤ 2 * H.S A := by
  -- By complementarity, $S(C) = S(A \cup B)$.
  have hC : H.S C = H.S (A ∪ B) := by
    simp_all +decide [ Finset.ext_iff ];
    convert H.S_complement C using 2 ; ext x ; specialize hfull x ; aesop;
  -- By complementarity, $S(A \cup C) = S(B)$.
  have hAC : H.S (A ∪ C) = H.S B := by
    convert H.S_complement _ using 2;
    simp_all +decide [ Finset.ext_iff ];
    grind;
  linarith [ ssa_implies_subadditivity H hssa A B hdisj_ab, H.S_nonneg A, H.S_nonneg B ]

/-! ## Bekenstein-Hawking Bound as Information Capacity -/

/-
**Theorem**: Logical qubits = n/4 under the RT formula.
-/
theorem bekenstein_hawking_capacity (c : StabilizerCodeParams)
    (hrt : 4 * c.k = c.n) :
    c.k = c.n / 4 := by
  rw [ ← hrt, Nat.mul_div_cancel_left _ ( by decide ) ]

/-! ## AdS₃ Specific Verification -/

/-- In AdS₃/CFT₂, the boundary is a circle with n sites (divisible by 8). -/
structure AdS3Code where
  n : ℕ
  n_pos : 0 < n
  n_div8 : 8 ∣ n

/-- Construct stabilizer code parameters for the AdS₃ code. -/
def AdS3Code.toParams (c : AdS3Code) : StabilizerCodeParams where
  n := c.n
  k := c.n / 4
  d := (3 * c.n + 8) / 8
  k_le_n := Nat.div_le_self c.n 4
  d_pos := by
    obtain ⟨m, hm⟩ := c.n_div8
    omega
  d_le_n := by
    obtain ⟨m, hm⟩ := c.n_div8
    have h1 := c.n_pos
    rw [hm] at h1 ⊢
    omega

/-
**Theorem**: The AdS₃ code satisfies the RT formula 4k = n.
-/
theorem ads3_rt_formula (c : AdS3Code) :
    4 * (c.toParams).k = (c.toParams).n := by
  convert Nat.mul_div_cancel' ( show 4 ∣ c.n from dvd_trans ( by decide ) c.n_div8 ) using 1

/-
**Theorem**: The AdS₃ code saturates the Singleton bound.
-/
theorem ads3_saturates_singleton (c : AdS3Code) :
    saturatesSingletonBound c.toParams := by
  unfold saturatesSingletonBound;
  obtain ⟨m, hm⟩ := c.n_div8
  simp [hm, AdS3Code.toParams];
  omega

/-
**Falsifiable Conjecture**: For a saturated holographic code, the redundancy
    ratio r = (n - k) / n = 3/4 (in the limit of large n). Formalized:
    4 * (n - k) = 3 * n when 4k = n. This is equivalent to the holographic
    bound: 75% of boundary degrees of freedom are "parity checks" protecting
    the 25% that encode bulk information.

    Test: for n = 8, k = 2, n - k = 6, and 4 * 6 = 24 = 3 * 8. ✓
    For n = 100, k = 25, n - k = 75, and 4 * 75 = 300 = 3 * 100. ✓
-/
theorem holographic_redundancy_ratio (c : StabilizerCodeParams)
    (hrt : 4 * c.k = c.n) :
    4 * (c.n - c.k) = 3 * c.n := by
  omega

end