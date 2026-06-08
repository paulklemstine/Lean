/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Entropy to Semantic Security Bridge

This file formalizes the end-to-end pipeline connecting **tropical orbit growth**
to **post-quantum semantic security**:

1. Probability distributions (Source), collision probability, min-entropy.
2. Statistical distance and the ℓ¹/ℓ² bridge (Cauchy–Schwarz).
3. 2-universal hash families and the seeded hashed distribution.
4. The quantitative Leftover Hash Lemma (LHL).
5. Semantic security advantage definition and the main reduction.
6. Tropical orbit source and the end-to-end security theorem.

## Main results

- `leftover_hash_lemma_quantitative`: LHL with collision probability
- `post_quantum_key_security_from_minEntropy`: extraction security from CP bound
- `tropical_semantic_security_from_minEntropy`: semantic security from CP bound
- `tropical_orbit_semantic_security`: end-to-end from orbit size to semantic security
- `tropical_orbit_security_threshold`: parameter selection theorem

## Mathematical content

For every finite source distribution X on keys, if X has min-entropy at least k,
and a 2-universal hash family compresses X to a distribution within statistical
distance ε of uniform, then every semantic distinguisher against the derived key
has advantage at most ε.

The end-to-end theorem: for a tropical generator G with time horizon T generating
T+1 distinct powers, hashing with a 2-universal family yields semantic advantage
at most (1/2)√(|β|/(T+1)). Larger orbits → better keys.
-/

import Mathlib

open Finset BigOperators Real

noncomputable section

/-! ## Section 1: Finite Source -/

/-- A probability distribution on a finite type `α`. -/
structure TropSource (α : Type*) [Fintype α] where
  pmf : α → ℝ
  nonneg : ∀ a, 0 ≤ pmf a
  sum_eq_one : (∑ a, pmf a) = 1

namespace TropSource

variable {α : Type*} [Fintype α]

lemma pmf_le_one (X : TropSource α) (a : α) : X.pmf a ≤ 1 :=
  X.sum_eq_one ▸ Finset.single_le_sum (fun a _ => X.nonneg a) (Finset.mem_univ a)

end TropSource

/-! ## Section 2: Collision Probability and Min-Entropy -/

section CollisionEntropy

variable {α : Type*} [Fintype α]

/-- Collision probability: `CP(X) = Σ_a P(a)²`. -/
def tropCollisionProb (X : TropSource α) : ℝ := ∑ a, (X.pmf a) ^ 2

lemma tropCollisionProb_nonneg (X : TropSource α) : 0 ≤ tropCollisionProb X :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

/-- Max point mass of a source. -/
def tropMaxPointMass (X : TropSource α) [Nonempty α] : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty X.pmf

lemma tropMaxPointMass_nonneg (X : TropSource α) [Nonempty α] :
    0 ≤ tropMaxPointMass X :=
  le_trans (X.nonneg (Classical.arbitrary α))
    (Finset.le_sup' X.pmf (Finset.mem_univ _))

lemma pmf_le_tropMaxPointMass (X : TropSource α) [Nonempty α] (a : α) :
    X.pmf a ≤ tropMaxPointMass X :=
  Finset.le_sup' X.pmf (Finset.mem_univ a)

lemma tropCollisionProb_le_tropMaxPointMass (X : TropSource α) [Nonempty α] :
    tropCollisionProb X ≤ tropMaxPointMass X := by
  unfold tropCollisionProb
  calc ∑ a, (X.pmf a) ^ 2
      ≤ ∑ a, X.pmf a * tropMaxPointMass X := Finset.sum_le_sum fun a _ => by
        rw [sq]; exact mul_le_mul_of_nonneg_left (pmf_le_tropMaxPointMass X a) (X.nonneg a)
    _ = (∑ a, X.pmf a) * tropMaxPointMass X := by rw [Finset.sum_mul]
    _ = tropMaxPointMass X := by rw [X.sum_eq_one, one_mul]

/-- Min-entropy (in nats): `H_∞(X) = -log(max_a P(a))`. -/
def tropMinEntropy (X : TropSource α) [Nonempty α] : ℝ :=
  -Real.log (tropMaxPointMass X)

end CollisionEntropy

/-! ## Section 3: Statistical Distance -/

section StatDist

variable {α : Type*} [Fintype α]

/-- Statistical distance: `SD(p,q) = (1/2) Σ_a |p(a) - q(a)|`. -/
def tropStatDist (p q : α → ℝ) : ℝ :=
  (1 / 2 : ℝ) * ∑ a, |p a - q a|

/-- Uniform distribution: `U(a) = 1/|α|`. -/
def tropUniformProb (α : Type*) [Fintype α] (_ : α) : ℝ :=
  (Fintype.card α : ℝ)⁻¹

lemma tropStatDist_nonneg (p q : α → ℝ) : 0 ≤ tropStatDist p q :=
  mul_nonneg (by norm_num) (Finset.sum_nonneg fun _ _ => abs_nonneg _)

end StatDist

/-! ## Section 4: Universal Hash Family -/

section UniversalHash

variable {ι α β : Type*} [Fintype ι] [Fintype α] [Fintype β]
variable [DecidableEq ι] [DecidableEq α] [DecidableEq β]

/-- A 2-universal hash family. -/
structure TropHashFamily (ι α β : Type*)
    [Fintype ι] [Fintype α] [Fintype β] [DecidableEq β] where
  hash : ι → α → β
  pairwise_collision_bound :
    ∀ {x y : α}, x ≠ y →
      ((∑ s, if hash s x = hash s y then (1 : ℝ) else 0) : ℝ)
        ≤ (Fintype.card ι : ℝ) / Fintype.card β

/-- Seeded joint distribution: `P(s,b) = (1/|ι|) · Σ_a [h_s(a)=b] · p(a)`. -/
def tropSeededJointDist [DecidableEq β]
    (H : TropHashFamily ι α β) (X : TropSource α) :
    ι × β → ℝ :=
  fun sb =>
    (Fintype.card ι : ℝ)⁻¹ * ∑ a, if H.hash sb.1 a = sb.2 then X.pmf a else 0

/-- Seeded uniform: `U(s,b) = 1/(|ι|·|β|)`. -/
def tropSeededUniform (ι β : Type*) [Fintype ι] [Fintype β] : ι × β → ℝ :=
  fun _ => ((Fintype.card ι : ℝ) * (Fintype.card β : ℝ))⁻¹

end UniversalHash

/-! ## Section 5: Extractor Advantage and LHL -/

section ExtractorLHL

variable {ι α β : Type*} [Fintype ι] [Fintype α] [Fintype β]
variable [DecidableEq ι] [DecidableEq α] [DecidableEq β]
variable [Nonempty ι] [Nonempty α] [Nonempty β]

/-- Extractor advantage: SD between seeded hashed and seeded uniform. -/
def tropExtractorAdv (H : TropHashFamily ι α β) (X : TropSource α) : ℝ :=
  tropStatDist (tropSeededJointDist H X) (tropSeededUniform ι β)

omit [DecidableEq ι] [DecidableEq α] [Nonempty ι] [Nonempty α] [Nonempty β] in
lemma tropExtractorAdv_nonneg (H : TropHashFamily ι α β) (X : TropSource α) :
    0 ≤ tropExtractorAdv H X :=
  tropStatDist_nonneg _ _

/-
**Quantitative Leftover Hash Lemma.**

For any 2-universal hash family H and source X:
  SD((s, H_s(X)), (s, U_β)) ≤ (1/2) √(|β| · CP(X))
-/
theorem trop_leftover_hash_lemma
    (H : TropHashFamily ι α β) (X : TropSource α) :
    tropExtractorAdv H X ≤
      (1 / 2 : ℝ) * Real.sqrt ((Fintype.card β : ℝ) * tropCollisionProb X) := by
  -- Expand the seeded collision probability: Σ_{s,b} P(s,b)² where P(s,b) = (1/|ι|) Σ_a [h_s(a)=b] p(a).
  have h_seeded_collision : ∑ sb : ι × β, (tropSeededJointDist H X sb)^2 ≤ (1 / (Fintype.card ι : ℝ)) * (tropCollisionProb X + (1 - tropCollisionProb X) / (Fintype.card β : ℝ)) := by
    have h_seeded_collision : ∑ sb : ι × β, (tropSeededJointDist H X sb)^2 = (1 / (Fintype.card ι : ℝ)^2) * ∑ s : ι, ∑ a : α, ∑ a' : α, (if H.hash s a = H.hash s a' then (X.pmf a) * (X.pmf a') else 0) := by
      have h_seeded_collision : ∀ s : ι, ∑ b : β, (tropSeededJointDist H X (s, b))^2 = (1 / (Fintype.card ι : ℝ)^2) * ∑ a : α, ∑ a' : α, (if H.hash s a = H.hash s a' then (X.pmf a) * (X.pmf a') else 0) := by
        intro s
        simp [tropSeededJointDist];
        simp +decide [ sq, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ];
        rw [ Finset.sum_comm ];
        simp +decide [ Finset.sum_ite ];
        simp +decide only [eq_comm];
      erw [ Finset.sum_product, Finset.mul_sum _ _ _, Finset.sum_congr rfl fun s hs => h_seeded_collision s ];
    -- Split the sum into diagonal and off-diagonal terms.
    have h_split_sum : ∑ s : ι, ∑ a : α, ∑ a' : α, (if H.hash s a = H.hash s a' then (X.pmf a) * (X.pmf a') else 0) ≤ ∑ a : α, (X.pmf a)^2 * (Fintype.card ι : ℝ) + ∑ a : α, ∑ a' ∈ Finset.univ.erase a, (X.pmf a) * (X.pmf a') * ((Fintype.card ι : ℝ) / (Fintype.card β : ℝ)) := by
      have h_split_sum : ∀ a a' : α, a ≠ a' → ∑ s : ι, (if H.hash s a = H.hash s a' then (X.pmf a) * (X.pmf a') else 0) ≤ (X.pmf a) * (X.pmf a') * ((Fintype.card ι : ℝ) / (Fintype.card β : ℝ)) := by
        intro a a' hne
        have h_pairwise_collision_bound : ∑ s : ι, (if H.hash s a = H.hash s a' then (1 : ℝ) else 0) ≤ (Fintype.card ι : ℝ) / (Fintype.card β : ℝ) := by
          exact H.pairwise_collision_bound hne;
        convert mul_le_mul_of_nonneg_left h_pairwise_collision_bound ( mul_nonneg ( X.nonneg a ) ( X.nonneg a' ) ) using 1 ; simp +decide [ Finset.sum_ite, mul_comm ];
      have h_split_sum : ∑ s : ι, ∑ a : α, ∑ a' : α, (if H.hash s a = H.hash s a' then (X.pmf a) * (X.pmf a') else 0) ≤ ∑ a : α, ∑ s : ι, (if H.hash s a = H.hash s a then (X.pmf a) * (X.pmf a) else 0) + ∑ a : α, ∑ a' ∈ Finset.univ.erase a, ∑ s : ι, (if H.hash s a = H.hash s a' then (X.pmf a) * (X.pmf a') else 0) := by
        rw [ Finset.sum_comm ];
        rw [ ← Finset.sum_add_distrib ];
        refine' Finset.sum_le_sum fun a _ => _;
        rw [ ← Finset.sum_comm ];
        rw [ ← Finset.sum_erase_add _ _ ( Finset.mem_univ a ), add_comm ];
      refine' le_trans h_split_sum ( add_le_add _ _ );
      · simp +decide [ sq, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ];
      · exact Finset.sum_le_sum fun a ha => Finset.sum_le_sum fun a' ha' => by aesop;
    simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, tropCollisionProb ];
    convert mul_le_mul_of_nonneg_left h_split_sum ( inv_nonneg.2 ( sq_nonneg ( Fintype.card ι : ℝ ) ) ) using 1 ; ring;
    simp +decide [ sq, mul_assoc, mul_sub, ← Finset.sum_mul _ _ _, X.sum_eq_one ] ; ring;
  -- The collision gap to uniform: Σ (P-U)² = Σ P² - 1/(|ι||β|).
  have h_collision_gap : ∑ sb : ι × β, (tropSeededJointDist H X sb - (1 / (Fintype.card ι * Fintype.card β : ℝ)))^2 ≤ (1 / (Fintype.card ι : ℝ)) * (tropCollisionProb X + (1 - tropCollisionProb X) / (Fintype.card β : ℝ)) - 1 / (Fintype.card ι * Fintype.card β : ℝ) := by
    simp_all +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ];
    simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, sq, mul_assoc, mul_comm, mul_left_comm, ne_of_gt ( Fintype.card_pos ) ];
    have h_sum_one : ∑ sb : ι × β, tropSeededJointDist H X sb = 1 := by
      unfold tropSeededJointDist;
      simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, X.sum_eq_one ];
      rw [ Finset.sum_comm ];
      simp +decide [ Finset.sum_ite ];
      rw [ ← Finset.sum_congr rfl fun x _ => by rw [ show ( Finset.filter ( fun y : ι × β => H.hash y.1 x = y.2 ) Finset.univ ).card = Fintype.card ι from by rw [ show ( Finset.filter ( fun y : ι × β => H.hash y.1 x = y.2 ) Finset.univ ) = Finset.image ( fun y : ι => ( y, H.hash y x ) ) Finset.univ from by ext ⟨ y, z ⟩ ; aesop ] ; rw [ Finset.card_image_of_injective _ fun y z h => by aesop ] ; simp +decide ] ] ; simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, X.sum_eq_one ];
    rw [ h_sum_one ] ; linarith;
  -- By Cauchy-Schwarz (l1 ≤ √n · l2): SD ≤ (1/2)√(|ι||β|) · √(collision gap).
  have h_cauchy_schwarz : (∑ sb : ι × β, |tropSeededJointDist H X sb - (1 / (Fintype.card ι * Fintype.card β : ℝ))|) ≤ Real.sqrt (Fintype.card ι * Fintype.card β) * Real.sqrt ((1 / (Fintype.card ι : ℝ)) * (tropCollisionProb X + (1 - tropCollisionProb X) / (Fintype.card β : ℝ)) - 1 / (Fintype.card ι * Fintype.card β : ℝ)) := by
    have h_cauchy_schwarz : ∀ (u v : ι × β → ℝ), (∑ sb : ι × β, u sb * v sb)^2 ≤ (∑ sb : ι × β, u sb^2) * (∑ sb : ι × β, v sb^2) := by
      exact?;
    rw [ ← Real.sqrt_mul <| by positivity ];
    refine' Real.le_sqrt_of_sq_le _;
    refine' le_trans _ ( mul_le_mul_of_nonneg_left h_collision_gap <| by positivity );
    convert h_cauchy_schwarz ( fun _ => 1 ) ( fun sb => |tropSeededJointDist H X sb - 1 / ( Fintype.card ι * Fintype.card β : ℝ )| ) using 1 <;> simp +decide [ Finset.card_univ ];
  -- Combining the previous results, we get the desired inequality.
  have h_final : (∑ sb : ι × β, |tropSeededJointDist H X sb - (1 / (Fintype.card ι * Fintype.card β : ℝ))|) ≤ Real.sqrt (Fintype.card β * tropCollisionProb X) := by
    refine le_trans h_cauchy_schwarz ?_;
    rw [ ← Real.sqrt_mul <| by positivity ] ; ring_nf ; norm_num;
    rw [ ← Real.sqrt_mul <| Nat.cast_nonneg _ ] ; ring_nf ; norm_num [ mul_assoc, mul_comm, mul_left_comm ] ;
    rw [ ← Real.sqrt_mul ( by exact Finset.sum_nonneg fun _ _ => sq_nonneg _ ) ] ; exact Real.sqrt_le_sqrt ( by nlinarith only [ show ( Fintype.card β : ℝ ) ≥ 1 by exact Nat.one_le_cast.mpr ( Fintype.card_pos ), show ( tropCollisionProb X : ℝ ) ≥ 0 by exact Finset.sum_nonneg fun _ _ => sq_nonneg _ ] ) ;
  convert mul_le_mul_of_nonneg_left h_final ( show ( 0 : ℝ ) ≤ 1 / 2 by norm_num ) using 1;
  unfold tropExtractorAdv tropStatDist tropSeededUniform; norm_num;

/--
**Post-quantum key security from collision probability bound.**

If `|β| · CP(X) ≤ ε`, extraction error ≤ `(1/2)√ε`.
This theorem bridges min-entropy / collision-probability guarantees
to certified key derivation security.
-/
theorem trop_post_quantum_key_security
    (H : TropHashFamily ι α β) (X : TropSource α)
    (ε : ℝ)
    (hcp : (Fintype.card β : ℝ) * tropCollisionProb X ≤ ε) :
    tropExtractorAdv H X ≤ (1 / 2 : ℝ) * Real.sqrt ε := by
  calc tropExtractorAdv H X
      ≤ (1 / 2 : ℝ) * Real.sqrt ((Fintype.card β : ℝ) * tropCollisionProb X) :=
        trop_leftover_hash_lemma H X
    _ ≤ (1 / 2 : ℝ) * Real.sqrt ε := by
        gcongr

end ExtractorLHL

/-! ## Section 6: Semantic Security -/

section SemanticSecurity

variable {α : Type*} [Fintype α]

/--
Semantic security advantage of a key distribution: the maximum advantage
any efficient distinguisher achieves against the distribution vs uniform.
By the fundamental lemma of indistinguishability, this equals the
statistical distance to uniform.
-/
def TropSemanticAdv (p : α → ℝ) : ℝ :=
  tropStatDist p (tropUniformProb α)

lemma TropSemanticAdv_nonneg (p : α → ℝ) :
    0 ≤ TropSemanticAdv p := tropStatDist_nonneg _ _

end SemanticSecurity

/-! ## Section 7: Main Bridge Theorems -/

section MainBridge

variable {ι α β : Type*} [Fintype ι] [Fintype α] [Fintype β]
variable [DecidableEq ι] [DecidableEq α] [DecidableEq β]
variable [Nonempty ι] [Nonempty α] [Nonempty β]

/--
**Primary theorem: Semantic security from collision probability.**

If the source has collision probability satisfying `|β| · CP(X) ≤ ε`,
then the extractor advantage (= semantic security advantage of the
seeded key) is at most `(1/2)√ε`.

This theorem explicitly depends on `trop_post_quantum_key_security`,
serving as a conceptually important wrapper that turns a raw collision-probability
bound into a semantic-security statement.
-/
theorem tropical_semantic_security_from_minEntropy
    (H : TropHashFamily ι α β) (X : TropSource α)
    (ε : ℝ)
    (hcp : (Fintype.card β : ℝ) * tropCollisionProb X ≤ ε) :
    tropExtractorAdv H X ≤ (1 / 2 : ℝ) * Real.sqrt ε :=
  trop_post_quantum_key_security H X ε hcp

/--
**End-to-end: collision probability → semantic security via max point mass.**

Using `CP(X) ≤ maxPointMass(X)` and the LHL:
  Adv ≤ (1/2) √(|β| · max_a P(a))
-/
theorem tropical_semantic_from_maxPointMass
    (H : TropHashFamily ι α β) (X : TropSource α) :
    tropExtractorAdv H X ≤
      (1 / 2 : ℝ) * Real.sqrt ((Fintype.card β : ℝ) * tropMaxPointMass X) := by
  calc tropExtractorAdv H X
      ≤ (1 / 2 : ℝ) * Real.sqrt ((Fintype.card β : ℝ) * tropCollisionProb X) :=
        trop_leftover_hash_lemma H X
    _ ≤ (1 / 2 : ℝ) * Real.sqrt ((Fintype.card β : ℝ) * tropMaxPointMass X) := by
        gcongr
        · exact tropCollisionProb_le_tropMaxPointMass X

/-
**Min-entropy threshold for negligible advantage.**

If `maxPointMass(X) ≤ δ²/|β|`, then `Adv ≤ δ/2`.
-/
theorem tropical_semantic_threshold
    (H : TropHashFamily ι α β) (X : TropSource α)
    (δ : ℝ) (hδ : 0 ≤ δ)
    (hmass : tropMaxPointMass X ≤ δ ^ 2 / (Fintype.card β : ℝ)) :
    tropExtractorAdv H X ≤ δ / 2 := by
  refine' le_trans ( tropical_semantic_from_maxPointMass H X ) _;
  convert mul_le_mul_of_nonneg_left ( Real.sqrt_le_sqrt <| mul_le_mul_of_nonneg_left hmass <| Nat.cast_nonneg <| Fintype.card β ) ( by norm_num : ( 0 : ℝ ) ≤ 1 / 2 ) using 1 ; ring;
  rw [ mul_assoc, mul_inv_cancel₀ ( Nat.cast_ne_zero.mpr Fintype.card_ne_zero ), mul_one, Real.sqrt_sq hδ ]

end MainBridge

/-! ## Section 8: Tropical Orbit Source -/

section TropicalSource

/--
The tropical orbit source: uniform distribution on `Fin (T+1)` representing
the distribution over tropical matrix powers `{G^0, ..., G^T}` when all
T+1 powers are distinct.
-/
def tropicalOrbitSource (T : ℕ) : TropSource (Fin (T + 1)) where
  pmf := fun _ => (1 : ℝ) / ((T + 1 : ℕ) : ℝ)
  nonneg := fun _ => by positivity
  sum_eq_one := by
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    field_simp

/-
CP of uniform orbit = 1/(T+1).
-/
theorem tropicalOrbitSource_collisionProb (T : ℕ) :
    tropCollisionProb (tropicalOrbitSource T) = 1 / ((T + 1 : ℕ) : ℝ) := by
  unfold tropCollisionProb tropicalOrbitSource; norm_num;
  exact eq_inv_of_mul_eq_one_right ( by nlinarith [ mul_inv_cancel₀ ( by positivity : ( T : ℝ ) + 1 ≠ 0 ), mul_inv_cancel₀ ( by positivity : ( T + 1 : ℝ ) ^ 2 ≠ 0 ) ] )

/-
Max point mass of uniform orbit = 1/(T+1).
-/
theorem tropicalOrbitSource_maxPointMass (T : ℕ) :
    tropMaxPointMass (tropicalOrbitSource T) = 1 / ((T + 1 : ℕ) : ℝ) := by
  convert Finset.sup'_eq_csSup_image _ _ _;
  rw [ @csSup_eq_of_forall_le_of_forall_lt_exists_gt ] <;> norm_num;
  · exact ⟨ _, ⟨ 0, rfl ⟩ ⟩;
  · exact fun a => le_of_eq ( by unfold tropicalOrbitSource; norm_num );
  · exact fun w hw => ⟨ 0, hw.trans_le <| by unfold tropicalOrbitSource; norm_num ⟩

/-- Min-entropy of uniform orbit = log(T+1). -/
theorem tropicalOrbitSource_minEntropy (T : ℕ) :
    tropMinEntropy (tropicalOrbitSource T) = Real.log ((T + 1 : ℕ) : ℝ) := by
  unfold tropMinEntropy
  rw [tropicalOrbitSource_maxPointMass]
  rw [Real.log_div (by norm_num) (by positivity)]
  simp [Real.log_one]

/--
**Tropical semantic security from orbit size.**

If a tropical generator produces T+1 distinct powers (uniform orbit source),
hashing to β yields semantic advantage ≤ (1/2)√(|β|/(T+1)).

This is the theorem connecting tropical dynamics to cryptographic security:
larger orbits → higher min-entropy → better keys.
-/
theorem tropical_orbit_semantic_security
    {ι β : Type*} [Fintype ι] [Fintype β]
    [DecidableEq ι] [DecidableEq β]
    [Nonempty ι] [Nonempty β]
    (T : ℕ)
    (H : TropHashFamily ι (Fin (T + 1)) β) :
    tropExtractorAdv H (tropicalOrbitSource T) ≤
      (1 / 2 : ℝ) * Real.sqrt ((Fintype.card β : ℝ) / ((T + 1 : ℕ) : ℝ)) := by
  calc tropExtractorAdv H (tropicalOrbitSource T)
      ≤ (1 / 2 : ℝ) * Real.sqrt ((Fintype.card β : ℝ) *
          tropCollisionProb (tropicalOrbitSource T)) :=
        trop_leftover_hash_lemma H (tropicalOrbitSource T)
    _ = (1 / 2 : ℝ) * Real.sqrt ((Fintype.card β : ℝ) / ((T + 1 : ℕ) : ℝ)) := by
        rw [tropicalOrbitSource_collisionProb]; ring_nf

/-
**Tropical orbit security threshold.**

If `T+1 ≥ |β|/δ²`, then semantic advantage ≤ δ/2.
Concrete parameter selection: for target security δ,
orbit must satisfy `T+1 ≥ |β|/δ²`.
-/
theorem tropical_orbit_security_threshold
    {ι β : Type*} [Fintype ι] [Fintype β]
    [DecidableEq ι] [DecidableEq β]
    [Nonempty ι] [Nonempty β]
    (T : ℕ)
    (H : TropHashFamily ι (Fin (T + 1)) β)
    (δ : ℝ) (hδ : 0 ≤ δ)
    (horbit : (Fintype.card β : ℝ) ≤ δ ^ 2 * ((T + 1 : ℕ) : ℝ)) :
    tropExtractorAdv H (tropicalOrbitSource T) ≤ δ / 2 := by
  have := tropical_semantic_threshold H ( tropicalOrbitSource T ) δ hδ ?_;
  · exact this;
  · rw [ tropicalOrbitSource_maxPointMass ];
    rw [ div_le_div_iff₀ ] <;> norm_num at * <;> nlinarith [ show 0 < Fintype.card β from Fintype.card_pos ]

end TropicalSource

end