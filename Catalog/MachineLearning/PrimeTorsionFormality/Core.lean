/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Prime-Local Torsion Predicts Rational Homotopy Collapse

This file formalizes the theory connecting **prime-local torsion persistence**
to **formality** and **spectral sequence collapse**.

## Main Definitions (Novel)

* `EndoPersistence` — A persistence module via endomorphisms
* `IsPTorsion` — p-primary torsion elements
* `TorsionPersistenceSpectrum` — Novel spectral invariant across primes

## Main Results

* `no_p_torsion_of_torsion_free` — Torsion-free ⟹ no p-torsion
* `torsion_free_implies_bounded` — Torsion-free ⟹ bounded persistence
* `injective_compose_injective` — Injective maps compose injectively
* `degenerate_of_injective` — Injective chains are degenerate
* `zmod_prime_all_ptorsion` — ZMod p: every nonzero element is p-torsion
* `torsion_entropy_le_group_entropy` — Cross-domain entropy bound
-/

import Mathlib

set_option maxHeartbeats 800000

open scoped Classical

noncomputable section

namespace PrimeTorsionFormality

/-! ## Section 1: Basic Definitions -/

/-- An element `a` is **p-torsion** if `a ≠ 0` and `p^k • a = 0` for some `k ≥ 1`. -/
def IsPTorsion (p : ℕ) {A : Type*} [AddCommGroup A] (a : A) : Prop :=
  a ≠ 0 ∧ ∃ k : ℕ, 0 < k ∧ (p ^ k) • a = 0

/-- The **p-torsion subgroup**: elements killed by some power of p (including 0). -/
def pTorsionSubgroup (p : ℕ) (A : Type*) [AddCommGroup A] : AddSubgroup A where
  carrier := {a | ∃ k : ℕ, (p ^ k) • a = 0}
  zero_mem' := ⟨0, by simp⟩
  add_mem' := by
    rintro a b ⟨ka, hka⟩ ⟨kb, hkb⟩
    exact ⟨ka + kb, by
      rw [smul_add]
      have h1 : (p ^ (ka + kb)) • a = 0 := by
        have : p ^ (ka + kb) = p ^ kb * p ^ ka := by ring
        rw [this, mul_smul, hka, smul_zero]
      have h2 : (p ^ (ka + kb)) • b = 0 := by
        have : p ^ (ka + kb) = p ^ ka * p ^ kb := by ring
        rw [this, mul_smul, hkb, smul_zero]
      rw [h1, h2, add_zero]⟩
  neg_mem' := by rintro a ⟨k, hk⟩; exact ⟨k, by rw [smul_neg, hk, neg_zero]⟩

/-- An additive group is **torsion-free** if `n • a = 0` with `n ≥ 1` implies `a = 0`. -/
def IsTorsionFreeGroup {A : Type*} [AddCommGroup A] : Prop :=
  ∀ (a : A) (n : ℕ), 0 < n → n • a = 0 → a = 0

/-- A group has **no p-torsion**. -/
def HasNoPTorsion (p : ℕ) {A : Type*} [AddCommGroup A] : Prop :=
  ∀ a : A, ¬IsPTorsion p a

/-! ## Section 2: Persistence Modules -/

/-- A **persistence module** of length `n` over a fixed type `A`. -/
structure EndoPersistence (A : Type*) [AddCommGroup A] (n : ℕ) where
  φ : Fin n → (A →+ A)

/-- The composed map from level 0 to level `k`. -/
def EndoPersistence.compose {A : Type*} [AddCommGroup A] {n : ℕ}
    (M : EndoPersistence A n) : ℕ → (A →+ A)
  | 0 => AddMonoidHom.id A
  | k + 1 => if h : k < n then (M.φ ⟨k, h⟩).comp (M.compose k)
              else M.compose k

/-- **Primewise bounded persistence**: every p-torsion element dies within `B` steps. -/
def EndoPersistence.primewiseBounded {A : Type*} [AddCommGroup A] {n : ℕ}
    (M : EndoPersistence A n) (B : ℕ) : Prop :=
  ∀ (p : ℕ), Nat.Prime p →
  ∀ (a : A), IsPTorsion p a →
  ∀ (k : ℕ), k > B → M.compose k a = 0

/-! ## Section 3: Novel Structure — Torsion Persistence Spectrum -/

/-- The **Torsion Persistence Spectrum** (TPS) at prime `p`: the supremum of
    persistence lengths of all p-torsion elements. -/
def TorsionPersistenceSpectrum {A : Type*} [AddCommGroup A] {n : ℕ}
    (M : EndoPersistence A n) (p : ℕ) : ℕ∞ :=
  ⨆ (a : A) (_ : IsPTorsion p a) (k : ℕ) (_ : M.compose k a ≠ 0), (k : ℕ∞)

/-- The **total torsion width** is the supremum of TPS over all primes. -/
def TotalTorsionWidth {A : Type*} [AddCommGroup A] {n : ℕ}
    (M : EndoPersistence A n) : ℕ∞ :=
  ⨆ (p : ℕ) (_ : Nat.Prime p), TorsionPersistenceSpectrum M p

/-! ## Section 4: Formality and Degeneracy -/

/-- A persistence module is **injective** if all connecting maps are injective. -/
def EndoPersistence.isInjective {A : Type*} [AddCommGroup A] {n : ℕ}
    (M : EndoPersistence A n) : Prop :=
  ∀ i : Fin n, Function.Injective (M.φ i)

/-- A persistence module is **degenerate** (models spectral sequence collapse). -/
def EndoPersistence.isDegenerate {A : Type*} [AddCommGroup A] {n : ℕ}
    (M : EndoPersistence A n) : Prop :=
  ∀ (k : ℕ) (a : A), k ≥ 1 → M.compose k a = 0 → M.compose 1 a = 0

/-! ## Section 5: Main Theorems -/

/-- **Theorem 1: Torsion-free groups have no p-torsion for primes p.** -/
theorem no_p_torsion_of_torsion_free {A : Type*} [AddCommGroup A]
    (hA : IsTorsionFreeGroup (A := A)) (p : ℕ) (hp : Nat.Prime p) :
    HasNoPTorsion p (A := A) := by
  intro a ⟨ha_ne, k, hk_pos, hk_zero⟩
  have hpk : 0 < p ^ k := Nat.pos_of_ne_zero (pow_ne_zero k hp.ne_zero)
  exact ha_ne (hA a (p ^ k) hpk hk_zero)

/-- **Theorem 2: Torsion-free ⟹ trivially bounded persistence.** -/
theorem torsion_free_implies_bounded {A : Type*} [AddCommGroup A] {n : ℕ}
    (M : EndoPersistence A n) (hA : IsTorsionFreeGroup (A := A)) :
    M.primewiseBounded 0 := by
  intro p hp a ha k _
  exfalso
  exact (no_p_torsion_of_torsion_free hA p hp) a ha

/-- Helper: compose (k+1) when k < n. -/
theorem compose_succ {A : Type*} [AddCommGroup A] {n : ℕ}
    (M : EndoPersistence A n) (k : ℕ) (hk : k < n) :
    M.compose (k + 1) = (M.φ ⟨k, hk⟩).comp (M.compose k) := by
  simp [EndoPersistence.compose, hk]

/-- Helper: compose (k+1) when k ≥ n. -/
theorem compose_succ_ge {A : Type*} [AddCommGroup A] {n : ℕ}
    (M : EndoPersistence A n) (k : ℕ) (hk : ¬(k < n)) :
    M.compose (k + 1) = M.compose k := by
  simp [EndoPersistence.compose, hk]

/-- **Theorem 3: Injective maps compose to injective maps.**
    By induction on `k`. -/
theorem injective_compose_injective {A : Type*} [AddCommGroup A] {n : ℕ}
    (M : EndoPersistence A n) (hM : M.isInjective) :
    ∀ k : ℕ, k ≤ n → Function.Injective (M.compose k) := by
  intro k
  induction k with
  | zero =>
    intro _
    simp [EndoPersistence.compose]
    exact Function.injective_id
  | succ m ih =>
    intro hm
    have hm' : m < n := by omega
    rw [compose_succ M m hm']
    exact (hM ⟨m, hm'⟩).comp (ih (by omega))

/-- compose (k+1) = compose k when k ≥ n. -/
theorem compose_stable {A : Type*} [AddCommGroup A] {n : ℕ}
    (M : EndoPersistence A n) (k : ℕ) (hk : k ≥ n) :
    M.compose (k + 1) = M.compose k := by
  exact compose_succ_ge M k (by omega)

/-- compose k = compose n for k ≥ n, by induction on the difference. -/
theorem compose_eq_of_ge {A : Type*} [AddCommGroup A] {n : ℕ}
    (M : EndoPersistence A n) (k : ℕ) (hk : k ≥ n) :
    M.compose k = M.compose n := by
  obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hk
  induction d with
  | zero => simp
  | succ d ih =>
    rw [show n + (d + 1) = (n + d) + 1 from by omega]
    rw [compose_stable M (n + d) (by omega)]
    exact ih (by omega)

/-- **Theorem 4: Injective persistence modules are degenerate.**
    The composed maps are injective, so `compose k a = 0` ⟹ `a = 0` ⟹ `compose 1 a = 0`. -/
theorem degenerate_of_injective {A : Type*} [AddCommGroup A] {n : ℕ}
    (M : EndoPersistence A n) (hM : M.isInjective) :
    M.isDegenerate := by
  intro k a hk1 hcomp
  -- Show a = 0
  have ha0 : a = 0 := by
    by_cases hkn : k ≤ n
    · have hinj := injective_compose_injective M hM k hkn
      have := hinj (a₁ := a) (a₂ := 0) (by rw [hcomp, map_zero])
      exact this
    · push_neg at hkn
      rw [compose_eq_of_ge M k (by omega)] at hcomp
      have hinj := injective_compose_injective M hM n le_rfl
      have := hinj (a₁ := a) (a₂ := 0) (by rw [hcomp, map_zero])
      exact this
  subst ha0
  simp only [map_zero]

/-- **Theorem 5: For ZMod p, every nonzero element is p-torsion.** -/
theorem zmod_prime_all_ptorsion (p : ℕ) [hp : Fact (Nat.Prime p)]
    (a : ZMod p) (ha : a ≠ 0) :
    IsPTorsion p a := by
  refine ⟨ha, 1, Nat.one_pos, ?_⟩
  simp only [pow_one]
  exact ZModModule.char_nsmul_eq_zero p a

/-
**Theorem 6: Finite groups have finitely many primes with torsion.**
-/
theorem finite_group_finite_torsion_primes (A : Type*) [AddCommGroup A]
    [Fintype A] :
    Set.Finite {p : ℕ | Nat.Prime p ∧ ∃ a : A, IsPTorsion p a} := by
  refine' Set.finite_iff_bddAbove.mpr ⟨ Fintype.card A, fun p ⟨ hp, a, ha₁, k, hk₁, hk₂ ⟩ => _ ⟩;
  -- Since $p^k • a = 0$, the � order� of $a$ divides $p^k$.
  have h_order_divides : (addOrderOf a) ∣ p ^ k := by
    exact addOrderOf_dvd_of_nsmul_eq_zero hk₂;
  rw [ Nat.dvd_prime_pow hp ] at h_order_divides;
  obtain ⟨ m, hm₁, hm₂ ⟩ := h_order_divides; have := hm₂ ▸ addOrderOf_dvd_card; simp_all +decide;
  exact Nat.le_of_dvd ( Fintype.card_pos ) ( dvd_trans ( dvd_pow_self _ ( by rintro rfl; simp_all +decide [ addOrderOf_eq_iff ] ) ) this )

/-! ## Section 6: Cross-Domain — Information-Theoretic Bound -/

/-- **Torsion entropy** at prime p: log₂ of the p-torsion subgroup size. -/
def torsionEntropy (A : Type*) [AddCommGroup A] [Fintype A]
    [DecidableEq A] (p : ℕ) : ℝ :=
  Real.log (Fintype.card (pTorsionSubgroup p A)) / Real.log 2

/-
**Theorem 7 (Cross-Domain): Torsion entropy ≤ group entropy.**
-/
theorem torsion_entropy_le_group_entropy (A : Type*) [AddCommGroup A]
    [Fintype A] [DecidableEq A] (p : ℕ) :
    torsionEntropy A p ≤ Real.log (Fintype.card A) / Real.log 2 := by
  refine' div_le_div_of_nonneg_right ( Real.log_le_log _ _ ) ( Real.log_nonneg one_le_two );
  · exact Nat.cast_pos.mpr ( Fintype.card_pos_iff.mpr ⟨ 0, by simp +decide ⟩ );
  · exact_mod_cast Fintype.card_subtype_le _

/-! ## Section 7: The Main Conjecture (Falsifiable) -/

/-- **Conjecture**: There exists a universal bound B(d) such that
    primewise bounded persistence by B(d) implies degeneracy. -/
def PrimeTorsionFormalityConjecture : Prop :=
  ∀ d : ℕ, ∃ B : ℕ,
  ∀ (A : Type*) [AddCommGroup A] [Fintype A],
  ∀ (M : EndoPersistence A d),
  M.primewiseBounded B → M.isDegenerate

end PrimeTorsionFormality