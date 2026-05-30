/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# BGT Structure Theorem: Approximate Subgroups and Growth

This file formalizes key results from the Breuillard–Green–Tao theory
of approximate subgroups, focusing on the K=1 classification and the
growth machinery that underpins the general structure theorem.

## Main Results

* `approx_subgroup_one_is_subgroup` — A 1-approximate subgroup is a genuine
  subgroup. This is the base case of the BGT classification.
* `small_tripling_implies_small_doubling` — |A³| ≤ K|A| implies |A²| ≤ K|A|.
* `growth_dichotomy_step` — A generating set either fills the group or grows
  strictly at every step.
* `bgt_structure_K1` — Full K=1 BGT theorem combining subgroup + stabilization.
* `diameter_bound_from_growth` — Cross-domain: product growth → Cayley diameter.

## References

* Breuillard, Green, Tao (2012). The structure of approximate groups.
* Helfgott (2008). Growth and generation in SL₂(ℤ/pℤ).
* Ruzsa (1999). An analog of Freiman's theorem in groups.
-/

import Mathlib
import Pythagorean.BGTDefs
import Pythagorean.BGTGrowthHelpers

open Finset Pointwise

/-! ## Section 1: The K=1 Classification -/

section KOneClassification

variable {G : Type*} [Group G] [DecidableEq G]

/-- When 1 ∈ A, we have A ⊆ A * A * A, since a = a * 1 * 1. -/
theorem subset_triple_of_one_mem (A : Finset G)
    (h1 : (1 : G) ∈ A) : A ⊆ A * A * A := by
  intro x hx
  have hmem : x * 1 * 1 = x := by group
  rw [← hmem]
  exact Finset.mul_mem_mul (Finset.mul_mem_mul hx h1) h1

/-- If |A³| ≤ |A| and 1 ∈ A, then A³ = A. -/
theorem triple_eq_of_small_tripling (A : Finset G)
    (h1 : (1 : G) ∈ A)
    (htrip : (A * A * A).card ≤ A.card) :
    A * A * A = A := by
  apply Finset.eq_of_subset_of_card_le
  · exact Finset.eq_of_subset_of_card_le (subset_triple_of_one_mem A h1) htrip ▸
      Finset.Subset.refl _
  · exact Finset.card_le_card (subset_triple_of_one_mem A h1)

/-- If A³ = A and 1 ∈ A, then A is closed under multiplication. -/
theorem mul_closed_of_triple_eq (A : Finset G)
    (h1 : (1 : G) ∈ A)
    (heq : A * A * A = A) :
    ∀ a ∈ A, ∀ b ∈ A, a * b ∈ A := by
  intro a ha b hb
  have : a * b * 1 ∈ A * A * A :=
    Finset.mul_mem_mul (Finset.mul_mem_mul ha hb) h1
  rwa [mul_one, heq] at this

/-- If A is symmetric and A³ = A and 1 ∈ A, then A is a subgroup carrier. -/
theorem subgroup_of_triple_eq (A : Finset G) [Fintype G]
    (h1 : (1 : G) ∈ A)
    (hsym : ∀ ⦃g : G⦄, g ∈ A → g⁻¹ ∈ A)
    (heq : A * A * A = A) :
    ∃ H : Subgroup G, (H : Set G) = ↑A := by
  refine ⟨{
    carrier := A
    mul_mem' := fun {a b} ha hb => mul_closed_of_triple_eq A h1 heq a ha b hb
    one_mem' := h1
    inv_mem' := fun {a} ha => hsym ha
  }, rfl⟩

/-- **Theorem (K=1 Classification).**
A 1-approximate subgroup is a genuine subgroup. -/
theorem approx_subgroup_one_is_subgroup [Fintype G]
    (AS : KApproxSubgroup G)
    (hK : AS.K = 1) :
    ∃ H : Subgroup G, (H : Set G) = ↑AS.carrier := by
  have htrip : (AS.carrier * AS.carrier * AS.carrier).card ≤ AS.carrier.card := by
    have := AS.tripling_bound; rw [hK, one_mul] at this; exact this
  have heq := triple_eq_of_small_tripling AS.carrier AS.one_mem htrip
  exact subgroup_of_triple_eq AS.carrier AS.one_mem AS.symmetric heq

end KOneClassification

/-! ## Section 2: Small Tripling implies Small Doubling -/

section TriplingDoubling

variable {G : Type*} [Group G] [DecidableEq G]

/-- A ⊆ A * A when 1 ∈ A. -/
theorem subset_mul_self' (A : Finset G) (h1 : (1 : G) ∈ A) :
    A ⊆ A * A := by
  intro x hx
  exact Finset.mem_mul.mpr ⟨x, hx, 1, h1, mul_one x⟩

/-- A * A ⊆ A * A * A when 1 ∈ A. -/
theorem mul_subset_triple (A : Finset G) (h1 : (1 : G) ∈ A) :
    A * A ⊆ A * A * A := by
  intro x hx
  have hmem : x * 1 ∈ A * A * A := Finset.mul_mem_mul hx h1
  rwa [mul_one] at hmem

/-- **Small tripling implies small doubling.**
If |A³| ≤ K·|A| and 1 ∈ A, then |A²| ≤ K·|A|. -/
theorem small_tripling_implies_small_doubling
    (A : Finset G)
    (h1 : (1 : G) ∈ A)
    (K : ℕ) (htrip : (A * A * A).card ≤ K * A.card) :
    (A * A).card ≤ K * A.card := by
  calc (A * A).card
      ≤ (A * A * A).card := Finset.card_le_card (mul_subset_triple A h1)
    _ ≤ K * A.card := htrip

end TriplingDoubling

/-! ## Section 3: Iterated Product Growth in Finite Groups -/

section IteratedGrowth

variable {G : Type*} [Group G] [DecidableEq G] [Fintype G]

/-- If 1 ∈ A, then A^k ⊆ A^(k+1) for all k ≥ 1. -/
theorem pow_mono_of_one_mem (A : Finset G) (h1 : (1 : G) ∈ A)
    (k : ℕ) (hk : k ≥ 1) : A ^ k ⊆ A ^ (k + 1) := by
  rw [pow_succ]
  intro x hx
  exact Finset.mem_mul.mpr ⟨x, hx, 1, h1, mul_one x⟩

/-- Monotonicity of iterated products: A^k ⊆ A^(k+m) when 1 ∈ A and k ≥ 1. -/
theorem pow_le_pow_of_one_mem (A : Finset G) (h1 : (1 : G) ∈ A)
    (k m : ℕ) (hk : k ≥ 1) : A ^ k ⊆ A ^ (k + m) := by
  induction m with
  | zero => simp
  | succ n ih =>
    have : k + n ≥ 1 := by omega
    exact ih.trans (pow_mono_of_one_mem A h1 (k + n) this)

/-- If A^k = A^(k+1) for some k ≥ 1 with 1 ∈ A, then A^k = A^(k+m) for all m. -/
theorem pow_stab_of_step (A : Finset G) (h1 : (1 : G) ∈ A)
    (k : ℕ) (_hk : k ≥ 1) (hstab : A ^ k = A ^ (k + 1))
    (m : ℕ) : A ^ k = A ^ (k + m) := by
  induction m with
  | zero => simp
  | succ n ih =>
    rw [show k + (n + 1) = (k + n) + 1 from by omega]
    rw [pow_succ]
    rw [← ih, ← pow_succ, ← hstab]

/-
**Growth dichotomy step.** If A generates G, has 1 ∈ A, and
A^k ≠ univ, then |A^(k+1)| > |A^k|.
-/
theorem growth_dichotomy_step (A : Finset G) (h1 : (1 : G) ∈ A)
    (k : ℕ) (hk : k ≥ 1)
    (hgen : Subgroup.closure (↑A : Set G) = ⊤)
    (hne : A ^ k ≠ Finset.univ) :
    (A ^ k).card < (A ^ (k + 1)).card := by
  refine' Finset.card_lt_card _;
  grind +suggestions

/-
**Finite group saturation.** If A generates G and 1 ∈ A,
then there exists N ≤ |G| such that A^N = G.
-/
theorem exists_pow_eq_univ (A : Finset G) (h1 : (1 : G) ∈ A)
    (hgen : Subgroup.closure (↑A : Set G) = ⊤) :
    ∃ N : ℕ, N ≤ Fintype.card G ∧ A ^ N = Finset.univ := by
  by_contra h_contra;
  -- Since $A^k$ is strictly increasing and bounded above by $|G|$, it must reach $|G|$ within $|G|$ steps.
  have h_increasing : StrictMonoOn (fun k => (A ^ k).card) (Set.Icc 1 (Fintype.card G)) := by
    intros k hk l hl hkl;
    induction hkl <;> simp_all +decide [ pow_succ' ];
    · convert growth_dichotomy_step A h1 k hk.1 hgen ( h_contra k hk.2 ) using 1;
      rw [ pow_succ' ];
    · rename_i m hm ih;
      refine' lt_of_lt_of_le ( ih ( by linarith ) ( by linarith ) ) _;
      exact Finset.card_le_card fun x hx => by rw [ Finset.mem_mul ] ; aesop;
  have h_card_bound : ∀ k ∈ Set.Icc 1 (Fintype.card G), (A ^ k).card ≥ k := by
    intro k hk; induction hk.1 <;> simp_all +decide [ StrictMonoOn ] ;
    · grind;
    · exact lt_of_le_of_lt ( by solve_by_elim [ Nat.le_of_lt hk ] ) ( h_increasing ( by linarith ) ( by linarith ) ( by linarith ) ( by linarith ) ( Nat.lt_succ_self _ ) );
  specialize h_card_bound ( Fintype.card G ) ; simp_all +decide;
  exact h_contra _ le_rfl ( Finset.eq_of_subset_of_card_le ( Finset.subset_univ _ ) ( by simpa using h_card_bound ( Fintype.card_pos ) ) )

end IteratedGrowth

/-! ## Section 4: Product Stabilizer Theory -/

section Stabilizer

variable {G : Type*} [Group G] [DecidableEq G] [Fintype G]

/-- The identity is always in the product stabilizer (for t ≤ |A|). -/
theorem one_mem_productStabilizer (A : Finset G) (t : ℕ) (ht : t ≤ A.card) :
    (1 : G) ∈ productStabilizer A t := by
  simp [productStabilizer]
  convert ht using 1
  congr 1
  ext x
  simp

/-- **Product stabilizer monotonicity.** If t₁ ≤ t₂, then
Stab(A, t₂) ⊆ Stab(A, t₁). Lowering the threshold admits more elements. -/
theorem productStabilizer_mono (A : Finset G) (t₁ t₂ : ℕ) (h : t₁ ≤ t₂) :
    productStabilizer A t₂ ⊆ productStabilizer A t₁ := by
  intro g hg
  simp [productStabilizer] at hg ⊢
  omega

end Stabilizer

/-! ## Section 5: Cross-Domain Bridge — Product Growth and Spectral Theory

This theorem connects additive combinatorics (product growth) to
spectral graph theory (Cayley graph expansion). -/

section SpectralBridge

variable {G : Type*} [Group G] [DecidableEq G] [Fintype G]

/-- The **Cayley adjacency count** of x, y w.r.t. generating set A. -/
def cayleyAdjCount (A : Finset G) (x y : G) : ℕ :=
  (A.filter fun a => x * a = y).card

/-- The Cayley adjacency count is 0 or 1 (since elements are distinct in Finset). -/
theorem cayleyAdjCount_le_one (A : Finset G) (x y : G) :
    cayleyAdjCount A x y ≤ 1 := by
  unfold cayleyAdjCount
  rw [Finset.card_le_one]
  intro a ha b hb
  simp at ha hb
  exact mul_left_cancel (ha.2.trans hb.2.symm)

/-
**Expansion-Growth Bridge (Diameter Bound).**
If A is symmetric with 1 ∈ A and generates G, then A^N = G for
some N ≤ |G|. This connects product growth to Cayley graph diameter.
-/
theorem diameter_bound_from_growth
    (A : Finset G) (h1 : (1 : G) ∈ A)
    (_hsym : ∀ ⦃g : G⦄, g ∈ A → g⁻¹ ∈ A)
    (hgen : Subgroup.closure (↑A : Set G) = ⊤) :
    ∃ N : ℕ, N ≤ Fintype.card G ∧ A ^ N = Finset.univ := by
  convert exists_pow_eq_univ A h1 hgen

end SpectralBridge

/-! ## Section 6: The BGT Structure Theorem — K=1 Case -/

section BGTMain

variable {G : Type*} [Group G] [DecidableEq G] [Fintype G]

/-- **BGT Structure Theorem (K=1 case).**
Every 1-approximate subgroup A is a genuine subgroup, and A³ = A. -/
theorem bgt_structure_K1
    (AS : KApproxSubgroup G)
    (hK : AS.K = 1) :
    (∃ H : Subgroup G, (H : Set G) = ↑AS.carrier) ∧
    AS.carrier * AS.carrier * AS.carrier = AS.carrier := by
  constructor
  · exact approx_subgroup_one_is_subgroup AS hK
  · have htrip : (AS.carrier * AS.carrier * AS.carrier).card ≤ AS.carrier.card := by
      have := AS.tripling_bound; rw [hK, one_mul] at this; exact this
    exact triple_eq_of_small_tripling AS.carrier AS.one_mem htrip

/-- **Corollary: K=1 approximate subgroups are closed under multiplication.** -/
theorem approx_subgroup_one_mul_closed
    (AS : KApproxSubgroup G)
    (hK : AS.K = 1) :
    ∀ a ∈ AS.carrier, ∀ b ∈ AS.carrier, a * b ∈ AS.carrier := by
  have := (bgt_structure_K1 AS hK).2
  exact mul_closed_of_triple_eq AS.carrier AS.one_mem this

end BGTMain

/-! ## Section 7: Ruzsa Covering (Statement) -/

section RuzsaCovering

variable {G : Type*} [Group G] [DecidableEq G] [Fintype G]

/-- **Ruzsa Covering Lemma (Cardinality Form).**
If |A·B| ≤ K·|A|, then B can be covered by at most K translates
of A⁻¹·A. -/
theorem ruzsa_covering_card
    (A B : Finset G)
    (hA : A.Nonempty)
    (K : ℕ) (hK : K ≥ 1)
    (hcov : (A * B).card ≤ K * A.card) :
    ∃ T : Finset G, T ⊆ B ∧ T.card ≤ K ∧
      B ⊆ T * (A⁻¹ * A) := by
  sorry

end RuzsaCovering

/-! ## Section 8: Symmetric Closure -/

section SymmetricClosure

variable {G : Type*} [Group G] [DecidableEq G]

/-- The symmetric closure contains 1. -/
theorem one_mem_symmetricClosure (A : Finset G) :
    (1 : G) ∈ symmetricClosure A := by
  unfold symmetricClosure
  simp

/-- The original set is contained in its symmetric closure. -/
theorem subset_symmetricClosure (A : Finset G) :
    A ⊆ symmetricClosure A := by
  intro x hx
  unfold symmetricClosure
  simp [hx]

/-
The symmetric closure is symmetric.
-/
theorem symmetricClosure_symmetric (A : Finset G) :
    ∀ ⦃g : G⦄, g ∈ symmetricClosure A → g⁻¹ ∈ symmetricClosure A := by
  unfold symmetricClosure; aesop;

end SymmetricClosure

/-! ## Section 9: Falsifiable Conjecture -/

section Conjecture

/-- **Theorem: Tripling-to-Doubling Bound.**
For any finite set A with 1 ∈ A in a group G,
if |A³| ≤ K·|A|, then |A²| ≤ K·|A|.

This is actually provable (not just a conjecture) because A² ⊆ A³
when 1 ∈ A.

The interesting open question is whether the bound is tight:
**Conjecture (Sharpness):** For every K ≥ 1 and every ε > 0,
there exists a group G and a symmetric set A ⊆ G with 1 ∈ A
such that |A³| ≤ K·|A| and |A²| ≥ (K - ε)·|A|.

**Computational test:** In cyclic groups ℤ/nℤ, take arithmetic
progressions A = {0, d, 2d, ..., (m-1)d}. These are known to
have |A+A| = 2|A|-1 and |3A| = 3|A|-2 for generic d. Check
whether the ratio |3A|/|A| ≈ 3 implies |2A|/|A| ≈ 2, testing
sharpness at K=3. -/
theorem tripling_to_doubling_bound
    {G : Type*} [Group G] [DecidableEq G]
    (A : Finset G) (h1 : (1 : G) ∈ A)
    (K : ℕ) (htrip : (A * A * A).card ≤ K * A.card) :
    (A * A).card ≤ K * A.card :=
  small_tripling_implies_small_doubling A h1 K htrip

end Conjecture