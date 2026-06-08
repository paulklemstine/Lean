/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Kruskal–Katona Theory for Multi-Index Families

This file develops a compression-based extremal theory for families of
multi-indices (exponent vectors) of fixed total degree on the integer simplex.

## Main Definitions

* `MI.degreeSlice` — The finset of all `α : Fin n → ℕ` with `∑ α = d`.
* `MI.shadow` — The one-step (lower) shadow of a multi-index family.
* `MI.compress` — The `(i,j)`-compression operator.
* `MI.IsCompressed` — Predicate: a family is compressed w.r.t. all pairs.
* `MI.immediateLowerDivisors` — Degree-(d-1) divisors of a multi-index.

## Main Results

* `MI.shadow_degree` — Shadow elements have degree `d - 1`.
* `MI.card_compress_eq` — Compression preserves cardinality.
* `MI.compress_degree` — Compression preserves degree.
* `MI.shadow_eq_biUnion_divisors` — Shadow = union of lower divisors.
* `MI.card_shadow_perm_eq` — Shadow size is permutation-invariant.
* `MI.exists_compressed` — Iterated compression yields a compressed extremizer.
-/

open Finset BigOperators Function

noncomputable section

namespace MI

variable {n : ℕ}

/-! ## Basic definitions -/

/-- Total degree of a multi-index. -/
abbrev deg (α : Fin n → ℕ) : ℕ := ∑ k, α k

/-- The degree slice: all multi-indices of total degree `d`. -/
def degreeSlice (n d : ℕ) : Finset (Fin n → ℕ) :=
  (Fintype.piFinset (fun _ : Fin n => Finset.range (d + 1))).filter (fun α => deg α = d)

theorem mem_degreeSlice {n d : ℕ} {α : Fin n → ℕ} :
    α ∈ degreeSlice n d ↔ deg α = d := by
  simp only [degreeSlice, mem_filter, Fintype.mem_piFinset, mem_range]
  constructor
  · exact fun ⟨_, h⟩ => h
  · intro h
    exact ⟨fun i => by
      have := single_le_sum (f := α) (fun _ _ => Nat.zero_le _) (mem_univ i)
      simp only [deg] at h; omega, h⟩

/-! ## One-Step Shadow -/

/-- The one-step shadow: all multi-indices obtainable by decrementing one coordinate. -/
def shadow (F : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) :=
  F.biUnion fun α =>
    (univ.filter (fun i => 0 < α i)).image fun i => update α i (α i - 1)

theorem mem_shadow {β : Fin n → ℕ} {F : Finset (Fin n → ℕ)} :
    β ∈ shadow F ↔ ∃ α ∈ F, ∃ i : Fin n, 0 < α i ∧ β = update α i (α i - 1) := by
  simp only [shadow, mem_biUnion, mem_image, mem_filter, mem_univ, true_and]
  constructor
  · rintro ⟨α, hα, i, hi, rfl⟩; exact ⟨α, hα, i, hi, rfl⟩
  · rintro ⟨α, hα, i, hi, rfl⟩; exact ⟨α, hα, i, hi, rfl⟩

/-- Immediate lower divisors of `α`: monomials of degree one less that divide `x^α`. -/
def immediateLowerDivisors (α : Fin n → ℕ) : Finset (Fin n → ℕ) :=
  (univ.filter (fun i => 0 < α i)).image fun i => update α i (α i - 1)

/-- **Cross-domain (Commutative Algebra):** Shadow = union of lower divisors. -/
theorem shadow_eq_biUnion_divisors (F : Finset (Fin n → ℕ)) :
    shadow F = F.biUnion immediateLowerDivisors := by
  ext β
  simp only [shadow, immediateLowerDivisors, mem_biUnion, mem_image, mem_filter, mem_univ,
    true_and]

/-
Shadow elements have degree `d - 1`.
-/
theorem shadow_degree {d : ℕ} {F : Finset (Fin n → ℕ)}
    (hF : ∀ α ∈ F, deg α = d) {β : Fin n → ℕ} (hβ : β ∈ shadow F) :
    deg β = d - 1 := by
  -- Use `mem_shadow` to get α ∈ F, i with α i > 0, β = update α i (α i - 1).
  obtain ⟨α, hαF, i, hαi_pos, rfl⟩ := (mem_shadow.mp hβ);
  convert congr_arg ( fun x : ℕ => x - 1 ) ( hF α hαF ) using 1;
  simp +decide [ deg, Finset.sum_update_of_mem ];
  exact eq_tsub_of_add_eq ( by rw [ ← Finset.sum_sdiff ( Finset.subset_univ { i } ) ] ; simpa [ Finset.sum_singleton, hαi_pos ] using by omega )

/-! ## Permutation Invariance -/

/-- Permute coordinates. -/
def perm (σ : Equiv.Perm (Fin n)) (α : Fin n → ℕ) : Fin n → ℕ := α ∘ σ.symm

theorem perm_injective (σ : Equiv.Perm (Fin n)) : Injective (perm σ) := by
  intro a b h
  simp only [perm] at h
  funext i
  have := congr_fun h (σ i)
  simp at this
  exact this

/-
Permutation commutes with shadow.
-/
theorem shadow_perm (σ : Equiv.Perm (Fin n)) (F : Finset (Fin n → ℕ)) :
    shadow (F.image (perm σ)) = (shadow F).image (perm σ) := by
  ext β;
  simp +decide [ shadow, perm ];
  constructor;
  · rintro ⟨ a, ha, i, hi, rfl ⟩;
    refine' ⟨ a, σ.symm i, ⟨ ha, hi ⟩, _ ⟩ ; ext j ; by_cases hj : j = i <;> simp +decide [ hj, update_apply ];
  · rintro ⟨ a, b, ⟨ ha, hb ⟩, rfl ⟩;
    refine' ⟨ a, ha, σ b, _, _ ⟩ <;> simp +decide [ update, Function.comp ];
    · assumption;
    · grind

/-- **Shadow cardinality is permutation-invariant** (discrete isoperimetric symmetry). -/
theorem card_shadow_perm_eq (σ : Equiv.Perm (Fin n)) (F : Finset (Fin n → ℕ)) :
    (shadow (F.image (perm σ))).card = (shadow F).card := by
  rw [shadow_perm]; exact card_image_of_injective _ (perm_injective σ)

/-! ## (i,j)-Compression -/

/-- Shift one unit from coordinate `j` to coordinate `i`. -/
def shift (i j : Fin n) (α : Fin n → ℕ) : Fin n → ℕ :=
  if i = j then α
  else if α j = 0 then α
  else fun k => if k = i then α i + 1 else if k = j then α j - 1 else α k

@[simp] theorem shift_self (i : Fin n) (α : Fin n → ℕ) : shift i i α = α := by simp [shift]

/-
`shift` preserves total degree.
-/
theorem deg_shift (i j : Fin n) (α : Fin n → ℕ) : deg (shift i j α) = deg α := by
  by_cases hij : i = j <;> simp +decide [ *, shift ] ; simp +decide [ *, deg, Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', Finset.sum_add_distrib ];
  by_cases h : α j = 0 <;> simp_all +decide [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq' ] ; ring;
  rw [ ← Finset.sum_erase_add _ _ ( Finset.mem_univ i ), ← Finset.sum_erase_add _ _ ( Finset.mem_erase_of_ne_of_mem ( Ne.symm hij ) ( Finset.mem_univ j ) ) ] ; simp +decide [ *, add_comm, add_left_comm, add_assoc ] ; ring;
  grind

/-
`shift` is injective on elements with positive `j`-th coordinate.
-/
theorem shift_injective_pos {i j : Fin n} (hij : i ≠ j)
    {α β : Fin n → ℕ} (ha : 0 < α j) (hb : 0 < β j)
    (h : shift i j α = shift i j β) : α = β := by
  ext k; by_cases hi : k = i <;> by_cases hj : k = j <;> simp_all +decide [ shift ] ;
  · replace h := congr_fun h i ; aesop;
  · have := congr_fun h j; simp_all +decide [ ne_of_gt ] ; omega;
  · replace h := congr_fun h k; aesop;

/-- The compression map: replace `α` by `shift i j α` when the shift is not in `F`. -/
def compressMap (i j : Fin n) (F : Finset (Fin n → ℕ)) (α : Fin n → ℕ) : Fin n → ℕ :=
  if shift i j α ∈ F then α else shift i j α

/-- The `(i,j)`-compression of `F`. -/
def compress (i j : Fin n) (F : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) :=
  F.image (compressMap i j F)

/-
The compression map is injective on `F`.
-/
theorem compressMap_injOn (i j : Fin n) (F : Finset (Fin n → ℕ)) :
    Set.InjOn (compressMap i j F) ↑F := by
  intro x y hx hyβ;
  unfold compressMap;
  split_ifs <;> simp_all +decide [ shift ];
  · grind;
  · grind;
  · intro h; split_ifs at h <;> simp_all +decide [ funext_iff, Finset.ext_iff ] ;
    grind +locals

/-- **Theorem 1: Compression preserves cardinality.** -/
theorem card_compress_eq (i j : Fin n) (F : Finset (Fin n → ℕ)) :
    (compress i j F).card = F.card :=
  Finset.card_image_of_injOn (compressMap_injOn i j F)

/-
**Compression preserves degree.**
-/
theorem compress_degree {d : ℕ} (i j : Fin n) (F : Finset (Fin n → ℕ))
    (hF : ∀ α ∈ F, deg α = d) :
    ∀ α ∈ compress i j F, deg α = d := by
  intro α hα;
  obtain ⟨ β, hβ, rfl ⟩ := Finset.mem_image.mp hα;
  unfold compressMap;
  split_ifs <;> [ exact hF β hβ; exact hF _ ‹_› |> fun h => by rw [ ← h ] ; exact deg_shift i j β ]

/-- A family is `(i,j)`-compressed. -/
def isCompressedIJ (i j : Fin n) (F : Finset (Fin n → ℕ)) : Prop :=
  ∀ α ∈ F, shift i j α ∈ F

/-- A family is fully down-compressed: closed under shifting weight from
    higher coordinates to lower ones. -/
def IsCompressed (F : Finset (Fin n → ℕ)) : Prop :=
  ∀ i j : Fin n, i < j → isCompressedIJ i j F

/-! ## Compression Energy -/

/-- Energy functional: sum of index-weighted coordinates across the family.
    Compression from `j` to `i` with `i < j` strictly decreases this. -/
def energy (F : Finset (Fin n → ℕ)) : ℕ :=
  F.sum fun α => ∑ k : Fin n, (k : ℕ) * α k

/-
Nontrivial compression strictly decreases energy.
-/
theorem energy_compress_lt {i j : Fin n} (hij : i < j) (F : Finset (Fin n → ℕ))
    (hne : compress i j F ≠ F) : energy (compress i j F) < energy F := by
  -- By definition of $compressMap$, we know that for any $\alpha \in F$, $compressMap i j F \alpha \in compress i j F$ and $\sum_{k} k * (compressMap i j F \alpha) k \leq \sum_{k} k * \alpha k$.
  have h_compressMap_le : ∀ α ∈ F, ∑ k, k.val * (compressMap i j F α) k ≤ ∑ k, k.val * α k := by
    intro α hα
    simp [compressMap, shift];
    split_ifs <;> simp_all +decide [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq' ];
    rw [ ← Finset.sum_erase_add _ _ ( Finset.mem_univ i ), ← Finset.sum_erase_add _ _ ( Finset.mem_erase_of_ne_of_mem ( ne_of_gt hij ) ( Finset.mem_univ j ) ) ] ; simp +decide [ *, Finset.sum_add_distrib, mul_add, add_assoc ] ; ring_nf ;
    split_ifs <;> simp_all +decide [ Finset.card_singleton ] ; nlinarith [ Nat.sub_add_cancel ( Nat.one_le_iff_ne_zero.mpr ‹_› ), show ( i : ℕ ) < j from hij ] ;
  -- Since $compress i j F \neq F$, there exists some $\alpha \in F$ such that $compressMap i j F \alpha \neq \alpha$.
  obtain ⟨α, hαF, hα_ne⟩ : ∃ α ∈ F, compressMap i j F α ≠ α := by
    grind +locals;
  -- Since $compressMap i j F \alpha \neq \alpha$, we have $\sum_{k} k * (compressMap i j F \alpha) k < \sum_{k} k * \alpha k$.
  have h_compressMap_lt : ∑ k, k.val * (compressMap i j F α) k < ∑ k, k.val * α k := by
    have h_compressMap_lt : compressMap i j F α = shift i j α := by
      unfold compressMap at *; aesop;
    unfold shift at *;
    split_ifs at h_compressMap_lt <;> simp_all +decide [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq' ];
    rw [ ← Finset.sum_erase_add _ _ ( Finset.mem_univ i ), ← Finset.sum_erase_add _ _ ( Finset.mem_erase_of_ne_of_mem ( ne_of_gt hij ) ( Finset.mem_univ j ) ) ] ; simp +decide [ *, Finset.sum_add_distrib, mul_add, add_assoc, add_left_comm, add_comm ];
    split_ifs <;> simp_all +decide [ Finset.card_singleton ];
    nlinarith [ Nat.sub_add_cancel ( Nat.one_le_iff_ne_zero.mpr ‹_› ), show ( i : ℕ ) < j from hij ];
  have h_sum_lt : ∑ α ∈ F, ∑ k, k.val * (compressMap i j F α) k < ∑ α ∈ F, ∑ k, k.val * α k := by
    exact Finset.sum_lt_sum ( fun x hx => h_compressMap_le x hx ) ⟨ α, hαF, h_compressMap_lt ⟩;
  convert h_sum_lt using 1;
  convert Finset.sum_image ?_ using 1;
  exact?

/-! ## Shadow Monotonicity Under Compression -/

/-! ## Iterated Compression -/

/-
**Theorem 3: Iterated compression yields a compressed family.**
    Any family can be compressed to a down-compressed family with the same
    cardinality and degree, via well-founded descent on the energy functional.
-/
theorem exists_compressed {d : ℕ} (F : Finset (Fin n → ℕ))
    (hF : ∀ α ∈ F, deg α = d) :
    ∃ G : Finset (Fin n → ℕ),
      IsCompressed G ∧
      G.card = F.card ∧
      (∀ α ∈ G, deg α = d) := by
  -- By Lemma 2, we can compress F to a family G with the same cardinality and degree.
  have h_compress : ∀ F : Finset (Fin n → ℕ), (∀ α ∈ F, deg α = d) → (∃ G : Finset (Fin n → ℕ), IsCompressed G ∧ #G = #F ∧ (∀ α ∈ G, deg α = d)) := by
    intro F hF;
    by_contra h_contra;
    -- By the well-foundedness of the energy functional, there exists a family G with the same cardinality and degree as F, but with minimal energy.
    obtain ⟨G, hG⟩ : ∃ G : Finset (Fin n → ℕ), #G = #F ∧ (∀ α ∈ G, deg α = d) ∧ ∀ H : Finset (Fin n → ℕ), #H = #F → (∀ α ∈ H, deg α = d) → energy G ≤ energy H := by
      have h_well_founded : ∃ G ∈ {H : Finset (Fin n → ℕ) | #H = #F ∧ (∀ α ∈ H, deg α = d)}, ∀ H ∈ {H : Finset (Fin n → ℕ) | #H = #F ∧ (∀ α ∈ H, deg α = d)}, energy G ≤ energy H := by
        apply_rules [ Set.exists_min_image ];
        · refine Set.finite_iff_bddAbove.mpr ?_;
          exact ⟨ Finset.Iic ( fun _ => d ), fun H hH => Finset.le_iff_subset.mpr fun α hα => Finset.mem_Iic.mpr fun i => hH.2 α hα ▸ Finset.single_le_sum ( fun a _ => Nat.zero_le ( α a ) ) ( Finset.mem_univ i ) ⟩;
        · exact ⟨ F, ⟨ rfl, hF ⟩ ⟩;
      exact ⟨ h_well_founded.choose, h_well_founded.choose_spec.1.1, h_well_founded.choose_spec.1.2, fun H hH₁ hH₂ => h_well_founded.choose_spec.2 H ⟨ hH₁, hH₂ ⟩ ⟩;
    -- If G is not compressed, then there exist i < j such that ¬ isCompressedIJ i j G.
    by_cases h_not_compressed : ¬ IsCompressed G;
    · obtain ⟨i, j, hij, h_not_compressed⟩ : ∃ i j : Fin n, i < j ∧ ¬ isCompressedIJ i j G := by
        unfold IsCompressed at h_not_compressed; aesop;
      -- By Lemma 2, compressing G with respect to i and j yields a family with the same cardinality and degree, but strictly lower energy.
      have h_compress : energy (compress i j G) < energy G := by
        apply energy_compress_lt hij G;
        grind +locals;
      exact not_le_of_gt h_compress ( hG.2.2 _ ( by rw [ card_compress_eq, hG.1 ] ) ( by exact compress_degree i j G hG.2.1 ) );
    · exact h_contra ⟨ G, Classical.not_not.mp h_not_compressed, hG.1, hG.2.1 ⟩;
  exact h_compress F hF

/-! ## Shadow Size Bounds -/

/-- Lower divisors bounded by support size. -/
theorem card_divisors_le (α : Fin n → ℕ) :
    (immediateLowerDivisors α).card ≤ (univ.filter (fun i => 0 < α i)).card :=
  card_image_le

/-
Shadow size bounded by family size times n.
-/
theorem card_shadow_le_mul (F : Finset (Fin n → ℕ)) :
    (shadow F).card ≤ F.card * n := by
  convert Finset.card_biUnion_le.trans _ using 1;
  exact le_trans ( Finset.sum_le_sum fun _ _ => Finset.card_image_le ) ( by simpa using Finset.sum_le_sum fun i ( hi : i ∈ F ) => show # ( Finset.filter ( fun k => 0 < i k ) Finset.univ ) ≤ n from le_trans ( Finset.card_le_univ _ ) ( by norm_num ) )

end MI

end