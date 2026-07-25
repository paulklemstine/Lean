/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Dependent Ultraproducts: Construction and Transfer Theorems

This file establishes the **dependent ultraproduct** construction and proves
fundamental transfer theorems connecting finite combinatorics to infinite algebra.

## Main Results

* `ultrafilter_pigeonhole` — pigeonhole principle for ultrafilters
* `ultrafilter_transfer_and/or` — boolean closure of transferred properties
* `ultrafilter_finite_image_resolution` — finite value determination (induction)
* `ultrafilter_determines_fin_value` — unique value selection (by_contra)
* `char_zero_transfer_finitary` — characteristic zero transfer (by_contra)
* `no_varying_prime_char_finite_range` — impossibility result
* `ultrafilter_conjunction_transfer` — iterated conjunction (structural induction)
* `ultrafilter_bounded_forall_transfer` — bounded quantifier transfer (induction on ℕ)
* `ultraproduct_add/mul/neg_welldef` — ring operation compatibility
* `ultraproduct_zero_product_transfer` — integral domain transfer
-/

import Mathlib

set_option maxHeartbeats 400000

open Set Filter

universe u v

/-! ## §1. Ultrafilter Combinatorics -/

section UltrafilterCombinatorics

variable {I : Type u} (U : Ultrafilter I)

/-- **Ultrafilter Pigeonhole Principle**: If the full index set is covered by
    finitely many sets indexed by `Fin n`, at least one is ultrafilter-large. -/
theorem ultrafilter_pigeonhole {n : ℕ} (covers : Fin n → Set I)
    (hcov : (⋃ k, covers k) ∈ U) :
    ∃ k, covers k ∈ U := by
  have : (⋃ k ∈ (Set.univ : Set (Fin n)), covers k) ∈ U := by rwa [Set.biUnion_univ]
  rw [Ultrafilter.finite_biUnion_mem_iff Set.finite_univ] at this
  obtain ⟨k, _, hk⟩ := this
  exact ⟨k, hk⟩

/-- The complement characterization for ultrafilters. -/
theorem ultrafilter_compl_iff (s : Set I) : sᶜ ∈ U ↔ s ∉ U := by
  constructor
  · intro hc hs
    have h1 : s ∩ sᶜ ∈ U := U.inter_mem hs hc
    have h2 : s ∩ sᶜ = ∅ := Set.inter_compl_self s
    rw [h2] at h1; exact Ultrafilter.empty_notMem h1
  · intro hs
    rcases U.mem_or_compl_mem s with h | h
    · exact absurd h hs
    · exact h

/-- **Boolean transfer: conjunction**. -/
theorem ultrafilter_transfer_and {P Q : I → Prop}
    (hP : {i | P i} ∈ U) (hQ : {i | Q i} ∈ U) :
    {i | P i ∧ Q i} ∈ U :=
  U.sets_of_superset (U.inter_mem hP hQ) (fun _ ⟨hp, hq⟩ => ⟨hp, hq⟩)

/-- **Boolean transfer: disjunction** — the ultrafilter prime ideal property. -/
theorem ultrafilter_transfer_or {P Q : I → Prop}
    (hPQ : {i | P i ∨ Q i} ∈ U) :
    {i | P i} ∈ U ∨ {i | Q i} ∈ U := by
  have h : {i | P i ∨ Q i} ⊆ {i | P i} ∪ {i | Q i} := by
    intro i hi; cases hi with
    | inl h => left; exact h
    | inr h => right; exact h
  exact Ultrafilter.union_mem_iff.mp (U.sets_of_superset hPQ h)

end UltrafilterCombinatorics

/-! ## §2. The Ultraproduct Setoid -/

section UltraproductConstruction

variable {I : Type u} (U : Ultrafilter I) (K : I → Type v)

/-- Two elements of `∀ i, K i` are **ultrafilter-equivalent**
    if they agree on a set in the ultrafilter. -/
def UltraEq [∀ i, DecidableEq (K i)] (f g : ∀ i, K i) : Prop :=
  {i : I | f i = g i} ∈ U

/-- `UltraEq` is an equivalence relation. -/
theorem ultraEq_equivalence [∀ i, DecidableEq (K i)] :
    Equivalence (UltraEq U K) where
  refl f := by
    show {i | f i = f i} ∈ U
    convert U.univ_sets using 1; ext; simp
  symm := fun {f g} (h : {i | f i = g i} ∈ U) =>
    U.sets_of_superset h (fun i (hi : f i = g i) => hi.symm)
  trans := fun {f g h} (hfg : {i | f i = g i} ∈ U) (hgh : {i | g i = h i} ∈ U) =>
    U.sets_of_superset (U.inter_mem hfg hgh) (fun i ⟨h1, h2⟩ => h1.trans h2)

/-- The setoid on `∀ i, K i` induced by ultrafilter equivalence. -/
def UltraproductSetoid [∀ i, DecidableEq (K i)] : Setoid (∀ i, K i) :=
  ⟨UltraEq U K, ultraEq_equivalence U K⟩

/-- The **dependent ultraproduct**: the quotient type. -/
def Ultraproduct [∀ i, DecidableEq (K i)] : Type _ :=
  Quotient (UltraproductSetoid U K)

/-- The canonical projection. -/
def Ultraproduct.mk' [∀ i, DecidableEq (K i)] (f : ∀ i, K i) : Ultraproduct U K :=
  Quotient.mk (UltraproductSetoid U K) f

end UltraproductConstruction

/-! ## §3. Finite Image Resolution -/

section FiniteImageResolution

variable {I : Type u} (U : Ultrafilter I)

/-
**Finite image resolution** (by induction on Finset): if `f` takes values in a
    finite set S on a U-large set, then some specific value in S is U-selected.
-/
theorem ultrafilter_finite_image_resolution {α : Type*} [DecidableEq α]
    (f : I → α) (S : Finset α)
    (hS : {i | f i ∈ (S : Set α)} ∈ U) :
    ∃ a ∈ S, {i | f i = a} ∈ U := by
  induction' S using Finset.induction with a S haS ih;
  · aesop;
  · by_cases h : { i | f i = a } ∈ U <;> simp_all +decide [ Set.setOf_or ]

/-
**Unique value determination**: for `f : I → Fin n`, exactly one value
    has its preimage in U. Uses `by_contra` for uniqueness.
-/
theorem ultrafilter_determines_fin_value (n : ℕ) (hn : 0 < n) (f : I → Fin n) :
    ∃! k : Fin n, {i | f i = k} ∈ U := by
  -- By the finite image resolution theorem �,� there exists a unique $k$ such that ${i | f i = k} \in U$.
  obtain ⟨k, hk⟩ : ∃ k : Fin n, {i | f i = k} ∈ U := by
    have := ultrafilter_pigeonhole U ( fun k => { i | f i = k } ) ?_;
    · exact this;
    · exact Filter.univ_mem' fun i => Set.mem_iUnion.2 ⟨ f i, rfl ⟩;
  refine' ⟨ k, hk, fun x hx => _ ⟩;
  exact Classical.not_not.1 fun h => by have := U.inter_mem hk hx; exact U.empty_notMem <| by convert this; ext; aesop;

end FiniteImageResolution

/-! ## §4. Characteristic Transfer -/

section CharacteristicTransfer

variable {I : Type u} (U : Ultrafilter I)

/-- A family of characteristics is **cofinitely varying** relative to U. -/
def CofinitelyVaryingChar (char_of : I → ℕ) : Prop :=
  ∀ p : ℕ, Nat.Prime p → {i | char_of i = p} ∉ U

/-- **Characteristic Zero Transfer** (finitary): if `char_of` takes values
    in `{0} ∪ primes` and no prime is U-selected, then 0 is U-selected.
    Uses `by_contra` and the ultrafilter finite union resolution. -/
theorem char_zero_transfer_finitary
    (char_of : I → ℕ) (primes : Finset ℕ)
    (h_range : ∀ i, char_of i = 0 ∨ char_of i ∈ primes)
    (h_not_p : ∀ p ∈ primes, {i | char_of i = p} ∉ U) :
    {i | char_of i = 0} ∈ U := by
  by_contra h0
  have hcov : (Set.univ : Set I) ⊆
      {i | char_of i = 0} ∪ ⋃ p ∈ (primes : Set ℕ), {i | char_of i = p} := by
    intro i _
    rcases h_range i with h | h
    · left; exact h
    · right; exact Set.mem_biUnion (Finset.mem_coe.mpr h) rfl
  have huniv : {i | char_of i = 0} ∪ ⋃ p ∈ (primes : Set ℕ), {i | char_of i = p} ∈ U :=
    U.sets_of_superset U.univ_sets hcov
  rw [Ultrafilter.union_mem_iff] at huniv
  cases huniv with
  | inl h => exact h0 h
  | inr h =>
    rw [Ultrafilter.finite_biUnion_mem_iff (Finset.finite_toSet primes)] at h
    obtain ⟨p, hp, hpi⟩ := h
    exact h_not_p p (Finset.mem_coe.mp hp) hpi

/-- **Impossibility of varying primes with finite range**: contradicts the
    ultrafilter property if all indices have prime char from a finite set
    but no specific prime is U-selected. -/
theorem no_varying_prime_char_finite_range
    (char_of : I → ℕ) (primes : Finset ℕ)
    (h_all_prime : ∀ i, char_of i ∈ primes)
    (h_not_p : ∀ p ∈ primes, {i | char_of i = p} ∉ U) :
    False := by
  have hcov : (Set.univ : Set I) ⊆ ⋃ p ∈ (primes : Set ℕ), {i | char_of i = p} := by
    intro i _; exact Set.mem_biUnion (Finset.mem_coe.mpr (h_all_prime i)) rfl
  have h : (⋃ p ∈ (primes : Set ℕ), {i | char_of i = p}) ∈ U :=
    U.sets_of_superset U.univ_sets hcov
  rw [Ultrafilter.finite_biUnion_mem_iff (Finset.finite_toSet primes)] at h
  obtain ⟨p, hp, hpi⟩ := h
  exact h_not_p p (Finset.mem_coe.mp hp) hpi

/-- **Zero-product transfer for ℕ**: if `n * m = 0` on a U-large set,
    then `n = 0` or `m = 0` on a U-large set. -/
theorem ultrafilter_mul_eq_zero_transfer
    (f g : I → ℕ) (h : {i | f i * g i = 0} ∈ U) :
    {i | f i = 0} ∈ U ∨ {i | g i = 0} ∈ U := by
  apply ultrafilter_transfer_or U
  exact U.sets_of_superset h (fun i hi => by
    simp at hi; exact hi)

end CharacteristicTransfer

/-! ## §5. Ultraproduct Ring Operations -/

section UltraproductAlgebra

variable {I : Type u} (U : Ultrafilter I) (K : I → Type v)
variable [∀ i, DecidableEq (K i)] [∀ i, CommRing (K i)]

/-- Pointwise addition is well-defined on ultraproduct equivalence classes. -/
theorem ultraproduct_add_welldef (f₁ f₂ g₁ g₂ : ∀ i, K i)
    (h1 : UltraEq U K f₁ g₁) (h2 : UltraEq U K f₂ g₂) :
    UltraEq U K (fun i => f₁ i + f₂ i) (fun i => g₁ i + g₂ i) :=
  U.sets_of_superset (U.inter_mem h1 h2) (fun i ⟨e1, e2⟩ => by
    show f₁ i + f₂ i = g₁ i + g₂ i; rw [e1, e2])

/-- Pointwise multiplication is well-defined on ultraproduct equivalence classes. -/
theorem ultraproduct_mul_welldef (f₁ f₂ g₁ g₂ : ∀ i, K i)
    (h1 : UltraEq U K f₁ g₁) (h2 : UltraEq U K f₂ g₂) :
    UltraEq U K (fun i => f₁ i * f₂ i) (fun i => g₁ i * g₂ i) :=
  U.sets_of_superset (U.inter_mem h1 h2) (fun i ⟨e1, e2⟩ => by
    show f₁ i * f₂ i = g₁ i * g₂ i; rw [e1, e2])

/-- Pointwise negation is well-defined on ultraproduct equivalence classes. -/
theorem ultraproduct_neg_welldef (f g : ∀ i, K i) (h : UltraEq U K f g) :
    UltraEq U K (fun i => -f i) (fun i => -g i) :=
  U.sets_of_superset h (fun i (hi : f i = g i) => by show -f i = -g i; rw [hi])

/-- **Zero-product transfer for integral domains**: if `f * g ≈ 0` in the
    ultraproduct and all components are integral domains, then `f ≈ 0` or `g ≈ 0`. -/
theorem ultraproduct_zero_product_transfer [∀ i, IsDomain (K i)]
    (f g : ∀ i, K i)
    (h : UltraEq U K (fun i => f i * g i) (fun _ => 0)) :
    UltraEq U K f (fun _ => 0) ∨ UltraEq U K g (fun _ => 0) := by
  apply ultrafilter_transfer_or U
  exact U.sets_of_superset h (fun i (hi : f i * g i = 0) => by
    rcases mul_eq_zero.mp hi with h | h
    · left; exact h
    · right; exact h)

end UltraproductAlgebra

/-! ## §6. Iterated Transfer (Inductive Proofs) -/

section IteratedTransfer

variable {I : Type u} (U : Ultrafilter I)

/-- **Iterated conjunction transfer** (structural induction on List):
    if each property in a list holds on a U-large set, then all hold
    simultaneously on a U-large set. -/
theorem ultrafilter_conjunction_transfer :
    ∀ (props : List (I → Prop)),
    (∀ P, P ∈ props → {i | P i} ∈ U) →
    {i | ∀ P, P ∈ props → P i} ∈ U := by
  intro props
  induction props with
  | nil =>
    intro _; convert U.univ_sets using 1; ext i; simp
  | cons P ps ih =>
    intro hall
    have hP : {i | P i} ∈ U := hall P List.mem_cons_self
    have hps : ∀ Q, Q ∈ ps → {i | Q i} ∈ U :=
      fun Q hQ => hall Q (List.mem_cons_of_mem P hQ)
    have hrest := ih hps
    apply U.sets_of_superset (U.inter_mem hP hrest)
    intro i ⟨hp, hps_i⟩ Q hQ
    rcases List.mem_cons.mp hQ with rfl | hmem
    · exact hp
    · exact hps_i Q hmem

/-- **Bounded universal transfer** (induction on ℕ):
    if `∀ k < n, P(i, k)` holds for each k on a U-large set,
    then all bounds hold simultaneously on a U-large set. -/
theorem ultrafilter_bounded_forall_transfer (n : ℕ)
    (P : I → ℕ → Prop)
    (h : ∀ k, k < n → {i | P i k} ∈ U) :
    {i | ∀ k, k < n → P i k} ∈ U := by
  induction n with
  | zero => convert U.univ_sets using 1; ext i; simp
  | succ n ih =>
    have hn_sets : ∀ k, k < n → {i | P i k} ∈ U :=
      fun k hk => h k (Nat.lt_succ_of_lt hk)
    have hrest := ih hn_sets
    have hlast : {i | P i n} ∈ U := h n (Nat.lt_succ_iff.mpr le_rfl)
    apply U.sets_of_superset (U.inter_mem hrest hlast)
    intro i ⟨hprev, hcur⟩ k hk
    rcases Nat.lt_succ_iff_lt_or_eq.mp hk with hlt | heq
    · exact hprev k hlt
    · rwa [heq]

end IteratedTransfer

/-! ## §7. GCD Transfer -/

section DivisibilityTransfer

variable {I : Type u} (U : Ultrafilter I)

/-- **GCD transfer**: common divisibility on U-large sets combines. -/
theorem ultrafilter_gcd_transfer (d f g : I → ℕ)
    (hf : {i | d i ∣ f i} ∈ U) (hg : {i | d i ∣ g i} ∈ U) :
    {i | d i ∣ f i ∧ d i ∣ g i} ∈ U :=
  ultrafilter_transfer_and U hf hg

end DivisibilityTransfer

/-! ## §8. Compactness Bridge -/

section CompactnessBridge

/-- **Ultrafilter finite compactness**: if each axiom in a list is satisfied
    on a U-large set of witnesses, all are simultaneously satisfied. -/
theorem ultrafilter_finite_compactness {I : Type u} (U : Ultrafilter I)
    {α : Type v} (axiom_list : List (α → Prop))
    (witnesses : I → α)
    (h_each : ∀ φ, φ ∈ axiom_list → {i | φ (witnesses i)} ∈ U) :
    {i | ∀ φ, φ ∈ axiom_list → φ (witnesses i)} ∈ U := by
  have key := ultrafilter_conjunction_transfer U
    (axiom_list.map (· ∘ witnesses))
    (by intro P hP
        simp [List.mem_map] at hP
        obtain ⟨φ, hφ, rfl⟩ := hP
        exact h_each φ hφ)
  exact U.sets_of_superset key (by
    intro i hi φ hφ
    exact hi (φ ∘ witnesses) (List.mem_map_of_mem hφ))

end CompactnessBridge

/-! ## §9. Conjecture -/

section Conjecture

/-- **Conjecture (Falsifiable — Ultrafilter Ramsey Selection)**:

    For any ultrafilter U on ℕ and any 2-coloring, the U-selected color
    class contains arbitrarily long arithmetic progressions.

    **Test**: For `c(n) = n mod 2`, the selected class is all evens or
    all odds, both containing infinite APs. For `c(n) = ⌊n√2⌋ mod 2`,
    verify computationally for APs up to length 100. -/
def UltrafilterRamseyAP (U : Ultrafilter ℕ) : Prop :=
  ∀ (c : ℕ → Fin 2),
    ∃ color : Fin 2,
      {n | c n = color} ∈ U ∧
      ∀ L : ℕ, ∃ a d : ℕ, 0 < d ∧ ∀ j, j < L → c (a + j * d) = color

end Conjecture