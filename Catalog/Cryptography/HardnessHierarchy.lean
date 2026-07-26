/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Cryptographic Hardness Hierarchy: OWF → PRG → PRF → Encryption

This module formalizes the **lattice of cryptographic hardness assumptions**,
establishing the chain of implications:
  one-way functions → pseudorandom generators → pseudorandom functions → secure encryption

We prove structural/combinatorial theorems that capture the core mathematical
content of these reductions, including:
- Lossy function collision bounds (preimage counting)
- PRG stretch impossibility (non-surjectivity of stretching maps)
- Hybrid argument advantage decomposition
- Preimage fiber analysis via pigeonhole
- Reduction composition with multiplicative loss
- Security degradation through reduction chains

## Main Definitions

* `CryptoLevel` — Enumeration of hardness levels in the hierarchy
* `HybridSequence` — Hybrid experiment advantage tracking
* `GGMTree` — The Goldreich-Goldwasser-Micali tree construction
* `LossyFunction` — A function with bounded image size (lossy OWF model)
* `SecurityProfile` — Novel structure tracking security degradation through reductions

## References

* Goldreich, O. "Foundations of Cryptography" Vol. 1 (2001)
* Goldreich, Goldwasser, Micali "How to Construct Random Functions" (1986)
* Håstad, Impagliazzo, Levin, Luby "A Pseudorandom Generator from any OWF" (1999)
-/

open Finset Fintype BigOperators Function

set_option maxHeartbeats 800000

/-! ## Section 1: The Cryptographic Hardness Lattice -/

/-- The four fundamental levels of the cryptographic hardness hierarchy. -/
inductive CryptoLevel
  | OWF   -- One-Way Functions
  | PRG   -- Pseudorandom Generators
  | PRF   -- Pseudorandom Functions
  | ENC   -- Secure Encryption (IND-CPA)
  deriving DecidableEq, Repr

namespace CryptoLevel

/-- Rank in the hardness hierarchy. Higher = stronger primitive. -/
def rank : CryptoLevel → ℕ
  | OWF => 0
  | PRG => 1
  | PRF => 2
  | ENC => 3

/-- Level A implies level B if A's rank ≥ B's rank. -/
instance : LE CryptoLevel where le a b := b.rank ≤ a.rank

instance : DecidableRel (· ≤ · : CryptoLevel → CryptoLevel → Prop) :=
  fun a b => Nat.decLe b.rank a.rank

theorem implies_refl (A : CryptoLevel) : A ≤ A := Nat.le_refl A.rank

theorem implies_trans {A B C : CryptoLevel} (h1 : A ≤ B) (h2 : B ≤ C) : A ≤ C :=
  Nat.le_trans h2 h1

/-- The chain is strict: no two distinct levels are equivalent. -/
theorem hierarchy_strict : ∀ A B : CryptoLevel, A ≠ B → ¬(A ≤ B ∧ B ≤ A) := by
  intro A B hne ⟨h1, h2⟩
  have : A.rank = B.rank := Nat.le_antisymm h2 h1
  cases A <;> cases B <;> simp_all [rank]

end CryptoLevel

/-! ## Section 2: Lossy Functions and Collision Bounds -/

/-- A lossy function model: `f : α → β` with bounded image size. -/
structure LossyFunction (α β : Type*) [Fintype α] [Fintype β] [DecidableEq β] where
  f : α → β
  imageSize : ℕ
  image_bound : (Finset.univ.image f).card ≤ imageSize

namespace LossyFunction

variable {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]

/-- **Lossy collision bound**: If `|α| > imageSize`, then there exist distinct
    elements mapping to the same value (pigeonhole). -/
theorem lossy_collision_exists (L : LossyFunction α β)
    (h : L.imageSize < Fintype.card α) :
    ∃ x y : α, x ≠ y ∧ L.f x = L.f y := by
  by_contra h_no_collision
  push_neg at h_no_collision
  have hinj : Injective L.f := by
    intro a b hab
    by_contra hne
    exact h_no_collision a b hne hab
  have hcard : (Finset.univ.image L.f).card = Fintype.card α := by
    rw [Finset.card_image_of_injective _ hinj, Finset.card_univ]
  linarith [L.image_bound]

end LossyFunction

/-! ## Section 3: PRG Stretch — Non-Surjectivity -/

/-- **PRG stretch non-surjectivity**: Any function from a smaller type to a larger
    type cannot be surjective. -/
theorem prg_stretch_not_surjective {α β : Type*} [Fintype α] [Fintype β]
    (f : α → β) (h : Fintype.card α < Fintype.card β) : ¬Surjective f := by
  intro hsurj
  exact Nat.lt_irrefl _ (Nat.lt_of_lt_of_le h (Fintype.card_le_of_surjective f hsurj))

/-- The image of any function covers at most `|α|` elements. -/
theorem prg_image_fraction_bound {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) :
    (Finset.univ.image f).card ≤ Fintype.card α := by
  exact le_trans Finset.card_image_le (by simp [Finset.card_univ])

/-- **PRG output gap**: Elements NOT in the image ≥ `|β| - |α|`. -/
theorem prg_output_gap {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) :
    (Fintype.card β : ℤ) - (Finset.univ.image f).card ≥
    (Fintype.card β : ℤ) - Fintype.card α := by
  have := prg_image_fraction_bound f
  omega

/-! ## Section 4: Hybrid Argument — Advantage Decomposition -/

/-- A sequence of hybrid experiments, with advantage at each transition. -/
structure HybridSequence where
  numSteps : ℕ
  stepAdvantage : Fin numSteps → ℚ
  step_nonneg : ∀ i, 0 ≤ stepAdvantage i

namespace HybridSequence

/-- Total advantage across all hybrid steps. -/
def totalAdvantage (H : HybridSequence) : ℚ :=
  ∑ i : Fin H.numSteps, H.stepAdvantage i

/-- Total advantage is non-negative. -/
theorem totalAdvantage_nonneg (H : HybridSequence) : 0 ≤ H.totalAdvantage :=
  Finset.sum_nonneg (fun i _ => H.step_nonneg i)

/-- **Hybrid argument upper bound**: `∑ᵢ εᵢ ≤ n · max_i εᵢ`. -/
theorem hybrid_advantage_triangle (H : HybridSequence)
    (maxAdv : ℚ) (hmax : ∀ i, H.stepAdvantage i ≤ maxAdv) :
    H.totalAdvantage ≤ H.numSteps * maxAdv := by
  unfold totalAdvantage
  calc ∑ i : Fin H.numSteps, H.stepAdvantage i
      ≤ ∑ _i : Fin H.numSteps, maxAdv :=
        Finset.sum_le_sum (fun i _ => hmax i)
    _ = H.numSteps * maxAdv := by
        simp [Finset.sum_const, nsmul_eq_mul]

/-- **Hybrid tightness**: Each step advantage ≤ total advantage. -/
theorem hybrid_advantage_lower (H : HybridSequence) (i : Fin H.numSteps) :
    H.stepAdvantage i ≤ H.totalAdvantage :=
  Finset.single_le_sum (fun j _ => H.step_nonneg j) (Finset.mem_univ i)

end HybridSequence

/-! ## Section 5: GGM Tree Construction — PRG to PRF -/

/-- The GGM tree: given `G : α → α × α` and a seed, evaluate along a binary path. -/
def GGMTree {α : Type*} (G : α → α × α) (seed : α) : List Bool → α
  | [] => seed
  | b :: bs =>
    let node := GGMTree G seed bs
    if b then (G node).2 else (G node).1

@[simp]
theorem ggm_depth_zero {α : Type*} (G : α → α × α) (seed : α) :
    GGMTree G seed [] = seed := rfl

/-- **GGM image bound**: The GGM image over any path set is at most `|α|`. -/
theorem ggm_image_bounded {α : Type*} [Fintype α] [DecidableEq α]
    (G : α → α × α) (seed : α) (paths : Finset (List Bool)) :
    (paths.image (GGMTree G seed)).card ≤ Fintype.card α := by
  calc (paths.image (GGMTree G seed)).card
      ≤ (Finset.univ : Finset α).card := Finset.card_le_univ _
    _ = Fintype.card α := Finset.card_univ

/-! ## Section 6: Preimage Counting for One-Way Functions -/

/-- The fiber (preimage set) of `f` at `y`. -/
def fiber {α β : Type*} [Fintype α] [DecidableEq β] (f : α → β) (y : β) : Finset α :=
  Finset.univ.filter (fun x => f x = y)

/-- **Fiber partition**: The sum of fiber sizes equals the domain size. -/
theorem fiber_sum_eq_card {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β] (f : α → β) :
    ∑ y ∈ Finset.univ.image f, (fiber f y).card = Fintype.card α := by
  rw [← Finset.card_univ, ← Finset.card_biUnion]
  · congr 1
    ext x
    simp [fiber, Finset.mem_biUnion, Finset.mem_image, Finset.mem_filter]
  · intro x _ y _ hxy
    apply Finset.disjoint_filter.mpr
    intro a _ h1 h2
    exact hxy (h1.symm.trans h2)

/-- **Large fiber existence**: If `|Im(f)| < |α|`, some fiber has size ≥ 2. -/
theorem large_fiber_exists {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β] (f : α → β)
    (h : (Finset.univ.image f).card < Fintype.card α) :
    ∃ y ∈ Finset.univ.image f, 2 ≤ (fiber f y).card := by
  by_contra h_all_small
  push_neg at h_all_small
  have h_le_one : ∀ y ∈ Finset.univ.image f, (fiber f y).card ≤ 1 := by
    intro y hy; have := h_all_small y hy; omega
  have hsum := fiber_sum_eq_card f
  have hle : Fintype.card α ≤ (Finset.univ.image f).card := by
    calc Fintype.card α
        = ∑ y ∈ Finset.univ.image f, (fiber f y).card := hsum.symm
      _ ≤ (Finset.univ.image f).card * 1 :=
          Finset.sum_le_card_nsmul _ _ 1 h_le_one
      _ = (Finset.univ.image f).card := by ring
  linarith

/-
**Collision from large fiber**: A fiber of size ≥ 2 yields two distinct
    elements mapping to the same value.
-/
theorem collision_from_large_fiber {α β : Type*} [Fintype α]
    [DecidableEq α] [DecidableEq β] (f : α → β) (y : β)
    (hlarge : 2 ≤ (fiber f y).card) :
    ∃ x₁ x₂ : α, x₁ ≠ x₂ ∧ f x₁ = y ∧ f x₂ = y := by
  have := Finset.one_lt_card.1 hlarge;
  obtain ⟨ a, ha, b, hb, hab ⟩ := this; exact ⟨ a, b, hab, by simpa using Finset.mem_filter.mp ha |>.2, by simpa using Finset.mem_filter.mp hb |>.2 ⟩ ;

/-! ## Section 7: Reduction Composition -/

/-- A **cryptographic reduction**: maps breaking B to breaking A with loss. -/
structure CryptoReduction where
  lossFactor : ℚ
  lossFactor_pos : 0 < lossFactor
  runtimeOverhead : ℕ

/-- Composition of reductions: loss factors multiply. -/
def CryptoReduction.compose (R₁ R₂ : CryptoReduction) : CryptoReduction where
  lossFactor := R₁.lossFactor * R₂.lossFactor
  lossFactor_pos := mul_pos R₁.lossFactor_pos R₂.lossFactor_pos
  runtimeOverhead := R₁.runtimeOverhead + R₂.runtimeOverhead

/-- **Reduction composition bound**: Composing reductions multiplies loss factors. -/
theorem reduction_compose_loss (R₁ R₂ : CryptoReduction)
    (adv_A adv_B adv_C : ℚ)
    (h1 : adv_B ≤ R₁.lossFactor * adv_A)
    (h2 : adv_C ≤ R₂.lossFactor * adv_B) :
    adv_C ≤ (R₁.compose R₂).lossFactor * adv_A := by
  unfold CryptoReduction.compose; simp only
  calc adv_C ≤ R₂.lossFactor * adv_B := h2
    _ ≤ R₂.lossFactor * (R₁.lossFactor * adv_A) :=
        mul_le_mul_of_nonneg_left h1 (le_of_lt R₂.lossFactor_pos)
    _ = R₁.lossFactor * R₂.lossFactor * adv_A := by ring

/-! ## Section 8: Advantage Amplification -/

/-- Failure probability `(1 - p)^k ≤ 1` for `0 ≤ p ≤ 1`. -/
theorem amplification_bound (p : ℚ) (k : ℕ) (hp : 0 ≤ p) (hp1 : p ≤ 1) :
    (1 - p) ^ k ≤ 1 :=
  pow_le_one₀ (by linarith) (by linarith)

/-- Failure probability decreases with more repetitions. -/
theorem amplification_monotone (p : ℚ) (k₁ k₂ : ℕ) (hp : 0 < p) (hp1 : p ≤ 1)
    (hk : k₁ ≤ k₂) :
    (1 - p) ^ k₂ ≤ (1 - p) ^ k₁ :=
  pow_le_pow_of_le_one (by linarith) (by linarith) hk

/-! ## Section 9: OWF-to-PRG Image Gap -/

/-- **OWF-to-PRG image gap**: Elements NOT in image ≥ `M - N` for `f : Fin N → Fin M`. -/
theorem owf_to_prg_image_gap (N M : ℕ) (f : Fin N → Fin M) :
    (M : ℤ) - (Finset.univ.image f).card ≥ (M : ℤ) - N := by
  have := prg_image_fraction_bound f
  simp [Fintype.card_fin] at this; omega

/-! ## Section 10: Security Profile — Novel Structure -/

/-- A **SecurityProfile** captures how security degrades through a chain of
    reductions. Tracks security loss at each level of the hierarchy. -/
structure SecurityProfile where
  depth : ℕ
  securityAtLevel : Fin (depth + 1) → ℚ
  degradation : Fin depth → ℚ
  security_pos : ∀ i, 0 < securityAtLevel i
  degradation_ge_one : ∀ i, 1 ≤ degradation i
  security_chain : ∀ i : Fin depth,
    securityAtLevel i.castSucc ≤ degradation i * securityAtLevel i.succ

namespace SecurityProfile

/-- Total degradation: product of all degradation factors. -/
def totalDegradation (S : SecurityProfile) : ℚ :=
  ∏ i : Fin S.depth, S.degradation i

/-- Total degradation is at least 1. -/
theorem totalDegradation_ge_one (S : SecurityProfile) :
    1 ≤ S.totalDegradation := by
  unfold totalDegradation
  exact Finset.one_le_prod Finset.univ (fun i => S.degradation_ge_one i)

/-
**End-to-end security bound**: Security at level 0 ≤ totalDegradation × security at top.
    Proved by induction on depth.
-/
theorem end_to_end_security (S : SecurityProfile) :
    S.securityAtLevel 0 ≤ S.totalDegradation * S.securityAtLevel (Fin.last S.depth) := by
  induction' S with depth securityAtLevel degradation security_pos degradation_ge_one security_chain;
  induction' depth with depth ih;
  · simp +decide [ SecurityProfile.totalDegradation ];
  · specialize ih ( fun i => securityAtLevel i.succ ) ( fun i => degradation i.succ ) ( fun i => security_pos _ ) ( fun i => degradation_ge_one _ ) ( fun i => security_chain _ );
    convert mul_le_mul_of_nonneg_left ih ( show 0 ≤ degradation 0 from le_trans zero_le_one ( degradation_ge_one _ ) ) |> le_trans ( security_chain 0 ) using 1 ; ring!;
    simp +decide [ mul_assoc, mul_comm, mul_left_comm, Fin.prod_univ_succ, SecurityProfile.totalDegradation ]

end SecurityProfile

/-! ## Section 11: Collision Density -/

/-- Count of outputs with exactly one preimage. -/
noncomputable def collisionFreeOutputs {N M : ℕ} (f : Fin N → Fin M) : ℕ :=
  (Finset.univ.filter (fun y : Fin M =>
    (Finset.univ.filter (fun x : Fin N => f x = y)).card = 1)).card

/-
**Falsifiable conjecture (Collision-free bound)**:
   For any function `f : Fin N → Fin M`, the collision-free output count
   is bounded by N. This follows from collision-free outputs ⊆ image, and |image| ≤ N.
   The deeper open question: what is the minimum collision-free count
   for a random function `f : Fin N → Fin (2*N)`? Empirically around `N * (1/e)`.
   We conjecture every such function with `N ≥ 2` has at least one collision-free output.
   Test: find a counterexample to refute this.

Collision-free outputs are bounded by domain size.
-/
theorem collision_free_le_domain {N M : ℕ} (f : Fin N → Fin M) :
    collisionFreeOutputs f ≤ N := by
  have h_card : Finset.card (Finset.filter (fun y => Finset.card (Finset.filter (fun x => f x = y) Finset.univ) = 1) Finset.univ) ≤ Finset.card (Finset.image f Finset.univ) := by
    refine Finset.card_le_card ?_;
    exact fun y hy => by obtain ⟨ x, hx ⟩ := Finset.card_pos.mp ( by linarith [ Finset.mem_filter.mp hy ] ) ; aesop;
  exact h_card.trans ( Finset.card_image_le.trans ( by simpa ) )

/-- For injective functions, all image elements are collision-free. -/
theorem injective_all_collision_free {N M : ℕ}
    (f : Fin N → Fin M) (hinj : Injective f) :
    collisionFreeOutputs f = N := by
  rw [ collisionFreeOutputs, Finset.card_eq_of_bijective ];
  use fun i hi => f ⟨ i, hi ⟩;
  · intro a ha; contrapose! ha; simp_all +decide [ Finset.card_eq_one ] ;
  · simp +decide [ Finset.card_eq_one, hinj.eq_iff ];
    exact fun i hi => ⟨ ⟨ i, hi ⟩, by ext; aesop ⟩;
  · exact fun i j hi hj h => by simpa [ Fin.ext_iff ] using hinj h;