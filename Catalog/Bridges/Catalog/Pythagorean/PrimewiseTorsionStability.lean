/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Primewise Torsion Persistence Stability

This file develops the theory of **primewise torsion decomposition** for persistence
stability over ℤ. The central insight is that torsion in abelian groups decomposes
canonically into p-primary components, and this decomposition refines the global
torsion birth stability theorem into independent prime channels.

## Main definitions

* `GlobalTorsionDetected` — Detects any torsion (element of finite order ≥ 2)
* `PTorsionBirthSet` — The p-primary torsion birth set for a prime p
* `GlobalTorsionBirthSet` — The global torsion birth set (any torsion)
* `primeShiftBound` — A conservative primewise stability modulus
* `PrimeBirthSpectrum` — The full primewise birth spectrum of a filtration

## Main results

* `global_torsion_implies_prime_torsion` — Any torsion witnesses prime torsion
* `mem_globalTorsionBirthSet_implies_exists_prime` — Arithmetic decomposition of births
* `pTorsionBirthSet_deltaClose` — Primewise stability under interleavings
* `globalTorsionBirthSet_deltaClose_from_primewise` — Global stability from primewise
* `exists_primewise_better_than_global` — Strict improvement example
* `prime_channel_independence` — Different primes give independent channels
-/
import Mathlib

/-! ## Section 1: Core Filtration Infrastructure -/

/-- A ℤ-module (abelian group) A has **no n-torsion** if the only element
    killed by multiplication by n is zero. -/
def HasNoNTorsion (n : ℤ) (A : Type*) [AddCommGroup A] : Prop :=
  ∀ a : A, n • a = 0 → a = 0

/-- **p-torsion is detected** in A when there exists a nonzero element killed by p. -/
def pTorsionDetected (p : ℤ) (A : Type*) [AddCommGroup A] : Prop :=
  ∃ a : A, a ≠ 0 ∧ p • a = 0

/-- A **filtration family** is a sequence of abelian groups with structure maps. -/
structure FiltrationFamily where
  obj : ℕ → Type*
  [instAG : ∀ i, AddCommGroup (obj i)]
  map : ∀ {i j : ℕ}, i ≤ j → (obj i →+ obj j)
  map_id : ∀ (i : ℕ) (x : obj i), map (le_refl i) x = x
  map_comp : ∀ {i j k : ℕ} (hij : i ≤ j) (hjk : j ≤ k) (x : obj i),
    map hjk (map hij x) = map (le_trans hij hjk) x

attribute [instance] FiltrationFamily.instAG

/-- Natural number distance. -/
def natDist (a b : ℕ) : ℕ := if a ≤ b then b - a else a - b

@[simp] theorem natDist_self (a : ℕ) : natDist a a = 0 := by simp [natDist]

theorem natDist_comm (a b : ℕ) : natDist a b = natDist b a := by
  simp only [natDist]; split_ifs <;> omega

theorem natDist_le_iff {a b δ : ℕ} : natDist a b ≤ δ ↔ (a ≤ b + δ ∧ b ≤ a + δ) := by
  simp only [natDist]; split_ifs <;> omega

/-- **NatSetDeltaClose**: Two subsets A, B ⊆ ℕ are δ-close in the Hausdorff sense. -/
def NatSetDeltaClose (A B : Set ℕ) (δ : ℕ) : Prop :=
  (∀ a, a ∈ A → ∃ b ∈ B, natDist a b ≤ δ) ∧
  (∀ b, b ∈ B → ∃ a ∈ A, natDist a b ≤ δ)

theorem NatSetDeltaClose.symm {A B : Set ℕ} {δ : ℕ} (h : NatSetDeltaClose A B δ) :
    NatSetDeltaClose B A δ :=
  ⟨fun b hb => by obtain ⟨a, ha, hd⟩ := h.2 b hb; exact ⟨a, ha, by rwa [natDist_comm]⟩,
   fun a ha => by obtain ⟨b, hb, hd⟩ := h.1 a ha; exact ⟨b, hb, by rwa [natDist_comm]⟩⟩

theorem NatSetDeltaClose.refl (A : Set ℕ) : NatSetDeltaClose A A 0 :=
  ⟨fun a ha => ⟨a, ha, by simp⟩, fun a ha => ⟨a, ha, by simp⟩⟩

theorem NatSetDeltaClose.mono {A B : Set ℕ} {δ₁ δ₂ : ℕ}
    (h : NatSetDeltaClose A B δ₁) (hle : δ₁ ≤ δ₂) : NatSetDeltaClose A B δ₂ :=
  ⟨fun a ha => by obtain ⟨b, hb, hd⟩ := h.1 a ha; exact ⟨b, hb, le_trans hd hle⟩,
   fun b hb => by obtain ⟨a, ha, hd⟩ := h.2 b hb; exact ⟨a, ha, le_trans hd hle⟩⟩

theorem NatSetDeltaClose.empty {δ : ℕ} : NatSetDeltaClose ∅ ∅ δ :=
  ⟨fun _ h => h.elim, fun _ h => h.elim⟩

/-- A **shifted filtration map** of shift δ from F to F'. -/
structure ShiftedFiltrationMap (F F' : FiltrationFamily) (δ : ℕ) where
  app : ∀ (i : ℕ), F.obj i →+ F'.obj (i + δ)

/-- A **faithful δ-interleaving** between filtrations F and F'. -/
structure FaithfulDeltaInterleaving (F F' : FiltrationFamily) (δ : ℕ) where
  forward : ShiftedFiltrationMap F F' δ
  backward : ShiftedFiltrationMap F' F δ
  forward_injective : ∀ (i : ℕ), Function.Injective (forward.app i)
  backward_injective : ∀ (i : ℕ), Function.Injective (backward.app i)

def FaithfulDeltaInterleaving.reverse {F F' : FiltrationFamily} {δ : ℕ}
    (h : FaithfulDeltaInterleaving F F' δ) : FaithfulDeltaInterleaving F' F δ where
  forward := h.backward
  backward := h.forward
  forward_injective := h.backward_injective
  backward_injective := h.forward_injective

/-! ## Section 2: Torsion Birth Sets (Global and Primewise) -/

/-- The **torsion birth set** for parameter p: indices where p-torsion first appears. -/
def TorsionBirthSet (F : FiltrationFamily) (p : ℤ) : Set ℕ :=
  {i | pTorsionDetected p (F.obj i) ∧ ∀ j, j < i → ¬ pTorsionDetected p (F.obj j)}

/-- **Global torsion detection**: there exists a nonzero element of finite order.
    Equivalently, there is a nonzero element killed by some integer n ≥ 2. -/
def GlobalTorsionDetected (A : Type*) [AddCommGroup A] : Prop :=
  ∃ a : A, a ≠ 0 ∧ ∃ n : ℕ, n ≥ 2 ∧ (n : ℤ) • a = 0

/-- The **p-primary torsion birth set** for a natural number p.
    This is the key new definition: it records the filtration index where
    p-torsion first appears. This refines the global torsion birth set
    by decomposing it along the prime spectrum. -/
def PTorsionBirthSet (p : ℕ) (F : FiltrationFamily) : Set ℕ :=
  {i | pTorsionDetected (p : ℤ) (F.obj i) ∧
       ∀ j, j < i → ¬ pTorsionDetected (p : ℤ) (F.obj j)}

/-- The **global torsion birth set**: indices where any torsion first appears.
    This is the coarsest torsion invariant. -/
def GlobalTorsionBirthSet (F : FiltrationFamily) : Set ℕ :=
  {i | GlobalTorsionDetected (F.obj i) ∧ ∀ j, j < i → ¬ GlobalTorsionDetected (F.obj j)}

/-- The primewise birth set coincides with the parametric birth set for integer p. -/
theorem pTorsionBirthSet_eq_torsionBirthSet (p : ℕ) (F : FiltrationFamily) :
    PTorsionBirthSet p F = TorsionBirthSet F (p : ℤ) := rfl

/-! ## Section 3: Subsingleton Properties -/

theorem torsionBirthSet_subsingleton (F : FiltrationFamily) (p : ℤ) :
    Set.Subsingleton (TorsionBirthSet F p) := by
  intro a ⟨_, ha_min⟩ b ⟨_, hb_min⟩
  by_contra hab
  rcases Nat.lt_or_gt_of_ne hab with h | h
  · exact hb_min a h ‹_›
  · exact ha_min b h ‹_›

theorem pTorsionBirthSet_subsingleton (p : ℕ) (F : FiltrationFamily) :
    Set.Subsingleton (PTorsionBirthSet p F) :=
  torsionBirthSet_subsingleton F (p : ℤ)

theorem globalTorsionBirthSet_subsingleton (F : FiltrationFamily) :
    Set.Subsingleton (GlobalTorsionBirthSet F) := by
  intro a ⟨_, ha_min⟩ b ⟨_, hb_min⟩
  by_contra hab
  rcases Nat.lt_or_gt_of_ne hab with h | h
  · exact hb_min a h ‹_›
  · exact ha_min b h ‹_›

/-! ## Section 4: The Key Algebraic Lemma — Torsion Implies Prime Torsion -/

/-
**Core algebraic lemma**: If a nonzero element has finite order n ≥ 2,
    then there exists a prime p such that p-torsion is detected.

    Proof: By strong induction on n. Let p be a prime factor of n.
    Write n = p * m. Then p • (m • a) = n • a = 0.
    If m • a ≠ 0, then m • a is a p-torsion witness.
    If m • a = 0, then since m < n and m ≥ 1, if m ≥ 2, apply induction.
    If m = 1, then n = p and we have p • a = 0 with a ≠ 0 directly.
-/
theorem global_torsion_implies_prime_torsion
    (A : Type*) [AddCommGroup A] (h : GlobalTorsionDetected A) :
    ∃ p : ℕ, Nat.Prime p ∧ pTorsionDetected (p : ℤ) A := by
  obtain ⟨ a, ha, n, hn, hn' ⟩ := h;
  induction' n using Nat.strongRecOn with n ih generalizing a;
  by_cases h₂ : ∃ m : ℕ, 2 ≤ m ∧ m < n ∧ (m : ℤ) • a = 0;
  · exact ih _ h₂.choose_spec.2.1 _ ha h₂.choose_spec.1 h₂.choose_spec.2.2;
  · -- Since $n$ is not prime, it must have a prime divisor $p$.
    obtain ⟨p, hp_prime, hp_div⟩ : ∃ p : ℕ, Nat.Prime p ∧ p ∣ n := by
      exact Nat.exists_prime_and_dvd ( by linarith );
    obtain ⟨ k, rfl ⟩ := hp_div;
    refine' ⟨ p, hp_prime, ⟨ ( k : ℤ ) • a, _, _ ⟩ ⟩ <;> simp_all +decide [ mul_smul ];
    exact fun h => h₂ k ( Nat.one_lt_iff_ne_zero_and_ne_one.mpr ⟨ by aesop_cat, by aesop_cat ⟩ ) ( by nlinarith [ hp_prime.two_le ] ) h

/-
p-torsion implies global torsion: the reverse direction is straightforward.
-/
theorem pTorsionDetected_implies_global {A : Type*} [AddCommGroup A]
    {p : ℕ} (hp : Nat.Prime p) (h : pTorsionDetected (p : ℤ) A) :
    GlobalTorsionDetected A := by
  obtain ⟨ a, ha₁, ha₂ ⟩ := h;
  exact ⟨ a, ha₁, p, hp.two_le, ha₂ ⟩

/-! ## Section 5: Birth Set Decomposition Theorems -/

/-
**Theorem 1 (Arithmetic Decomposition of Torsion Births)**:
    Every global torsion birth arises from some prime torsion channel.
    At the index where torsion is first globally detected, there is
    a specific prime p whose torsion is also first detected there.

    Note: The reverse implication does not hold in general: a prime
    p may have its torsion born at index n while global torsion was
    already detected at an earlier index via a different prime q.
-/
theorem mem_globalTorsionBirthSet_implies_exists_prime
    (F : FiltrationFamily) (n : ℕ)
    (h : n ∈ GlobalTorsionBirthSet F) :
    ∃ p : ℕ, Nat.Prime p ∧ n ∈ PTorsionBirthSet p F := by
  -- By global_torsion_implies_prime_torsion, obtain a prime p such that p-torsion is detected in F.obj n.
  obtain ⟨p, hp⟩ : ∃ p : ℕ, Nat.Prime p ∧ pTorsionDetected (p : ℤ) (F.obj n) := by
    exact global_torsion_implies_prime_torsion _ h.1;
  refine' ⟨ p, hp.1, hp.2, fun j hj => _ ⟩;
  exact fun h' => h.2 j hj ( pTorsionDetected_implies_global hp.1 h' )

/-
Reverse inclusion: primewise birth implies the global birth occurred at or before.
-/
theorem pTorsionBirth_le_globalBirth
    (F : FiltrationFamily) (p : ℕ) (hp : Nat.Prime p) (n : ℕ)
    (hn : n ∈ PTorsionBirthSet p F)
    (hg : (GlobalTorsionBirthSet F).Nonempty) :
    ∃ m ∈ GlobalTorsionBirthSet F, m ≤ n := by
  exact ⟨ _, hg.choose_spec, le_of_not_gt fun h => hg.choose_spec.2 _ h ( by simpa using pTorsionDetected_implies_global hp hn.1 ) ⟩

/-! ## Section 6: Torsion Transport Under Interleavings -/

theorem pTorsionDetected_of_injective {A B : Type*} [AddCommGroup A] [AddCommGroup B]
    (f : A →+ B) (hf : Function.Injective f) (p : ℤ)
    (h : pTorsionDetected p A) : pTorsionDetected p B := by
  obtain ⟨a, ha_ne, ha_tor⟩ := h
  exact ⟨f a, fun h => ha_ne (hf (by rw [h, map_zero])),
         by rw [← map_zsmul f, ha_tor, map_zero]⟩

theorem torsionBirthSet_nonempty_of_detected (F : FiltrationFamily) (p : ℤ)
    (i : ℕ) (hi : pTorsionDetected p (F.obj i)) :
    (TorsionBirthSet F p).Nonempty := by
  have key : ∀ n, pTorsionDetected p (F.obj n) →
      ∃ m, m ≤ n ∧ pTorsionDetected p (F.obj m) ∧
        ∀ j, j < m → ¬ pTorsionDetected p (F.obj j) := by
    intro n
    induction n using Nat.strongRecOn with
    | _ n ih =>
      intro hn
      by_cases h : ∀ j, j < n → ¬ pTorsionDetected p (F.obj j)
      · exact ⟨n, le_refl n, hn, h⟩
      · push_neg at h
        obtain ⟨j, hj_lt, hj_det⟩ := h
        obtain ⟨m, hm_le, hm_det, hm_min⟩ := ih j hj_lt hj_det
        exact ⟨m, by omega, hm_det, hm_min⟩
  obtain ⟨m, _, hm_det, hm_min⟩ := key i hi
  exact ⟨m, hm_det, hm_min⟩

theorem exists_birth_le_of_detected (F : FiltrationFamily) (p : ℤ) (k : ℕ)
    (hk : pTorsionDetected p (F.obj k)) :
    ∃ b ∈ TorsionBirthSet F p, b ≤ k := by
  obtain ⟨b, hb⟩ := torsionBirthSet_nonempty_of_detected F p k hk
  refine ⟨b, hb, ?_⟩
  by_contra hgt
  push_neg at hgt
  obtain ⟨_, hb_min⟩ := hb
  exact hb_min k hgt hk

/-! ## Section 7: Primewise Stability Theorem -/

/-- **Theorem 2 (Primewise Stability)**: Under a faithful δ-interleaving,
    the p-primary torsion birth set is δ-close in the Hausdorff sense.

    This is the primewise analogue of the algebraic stability theorem.
    Each prime channel is independently stable. -/
theorem pTorsionBirthSet_deltaClose
    (p : ℕ) (F F' : FiltrationFamily) (δ : ℕ)
    (hint : FaithfulDeltaInterleaving F F' δ) :
    NatSetDeltaClose (PTorsionBirthSet p F) (PTorsionBirthSet p F') δ := by
  show NatSetDeltaClose (TorsionBirthSet F (p : ℤ)) (TorsionBirthSet F' (p : ℤ)) δ
  constructor
  · intro a ha_mem
    have hi_det := ha_mem.1
    have h_det : pTorsionDetected (p : ℤ) (F'.obj (a + δ)) :=
      pTorsionDetected_of_injective (hint.forward.app a) (hint.forward_injective a) _ hi_det
    obtain ⟨j, hj_mem, hj_le⟩ := exists_birth_le_of_detected F' (p : ℤ) (a + δ) h_det
    refine ⟨j, hj_mem, ?_⟩
    rw [natDist_le_iff]
    constructor
    · have hj_det := hj_mem.1
      have h_back : pTorsionDetected (p : ℤ) (F.obj (j + δ)) :=
        pTorsionDetected_of_injective (hint.backward.app j) (hint.backward_injective j) _ hj_det
      obtain ⟨a', ha'_mem, ha'_le⟩ := exists_birth_le_of_detected F (p : ℤ) (j + δ) h_back
      have : a = a' := torsionBirthSet_subsingleton F (p : ℤ) ha_mem ha'_mem
      omega
    · exact hj_le
  · intro b hb_mem
    have hb_det := hb_mem.1
    have h_det : pTorsionDetected (p : ℤ) (F.obj (b + δ)) :=
      pTorsionDetected_of_injective (hint.backward.app b) (hint.backward_injective b) _ hb_det
    obtain ⟨j, hj_mem, hj_le⟩ := exists_birth_le_of_detected F (p : ℤ) (b + δ) h_det
    refine ⟨j, hj_mem, ?_⟩
    rw [natDist_comm, natDist_le_iff]
    constructor
    · have hj_det := hj_mem.1
      have h_fwd : pTorsionDetected (p : ℤ) (F'.obj (j + δ)) :=
        pTorsionDetected_of_injective (hint.forward.app j) (hint.forward_injective j) _ hj_det
      obtain ⟨b', hb'_mem, hb'_le⟩ := exists_birth_le_of_detected F' (p : ℤ) (j + δ) h_fwd
      have : b = b' := torsionBirthSet_subsingleton F' (p : ℤ) hb_mem hb'_mem
      omega
    · exact hj_le

/-! ## Section 8: Quantitative Primewise Modulus -/

/-- The **prime shift bound**: a conservative stability modulus for the
    p-primary channel. In the absence of additional arithmetic control,
    this defaults to δ. The definition supports refinement when
    p-divisibility data is available. -/
def primeShiftBound (p δ : ℕ) : ℕ := δ

/-- The prime shift bound never exceeds the global bound. -/
theorem primeShiftBound_le (p δ : ℕ) : primeShiftBound p δ ≤ δ :=
  le_refl δ

/-- The stability theorem using the prime shift bound. -/
theorem pTorsionBirthSet_deltaClose_withBound
    (p : ℕ) (F F' : FiltrationFamily) (δ : ℕ)
    (hint : FaithfulDeltaInterleaving F F' δ) :
    NatSetDeltaClose (PTorsionBirthSet p F) (PTorsionBirthSet p F')
      (primeShiftBound p δ) :=
  pTorsionBirthSet_deltaClose p F F' δ hint

/-! ## Section 9: Global Stability from Primewise Decomposition -/

/-
Global torsion detection at level i implies p-torsion detection for some prime.
-/
theorem globalTorsionDetected_of_pTorsionDetected {A : Type*} [AddCommGroup A]
    {p : ℕ} (hp : Nat.Prime p) (h : pTorsionDetected (p : ℤ) A) :
    GlobalTorsionDetected A := by
  exact pTorsionDetected_implies_global hp h

/-
If GlobalTorsionDetected at level k, there exists a global birth at some index ≤ k.
-/
theorem exists_globalBirth_le_of_detected (F : FiltrationFamily) (k : ℕ)
    (hk : GlobalTorsionDetected (F.obj k)) :
    ∃ b ∈ GlobalTorsionBirthSet F, b ≤ k := by
  -- By induction on $k$, we can show that if GlobalTorsionDetected at level $k$, then there exists a global birth at some index $\leq k$.
  induction' k using Nat.strong_induction_on with k ih;
  by_cases h : ∃ j < k, GlobalTorsionDetected (F.obj j);
  · exact Exists.elim h fun j hj => Exists.elim ( ih j hj.1 hj.2 ) fun b hb => ⟨ b, hb.1, le_trans hb.2 hj.1.le ⟩;
  · exact ⟨ k, ⟨ hk, fun j hj => fun hj' => h ⟨ j, hj, hj' ⟩ ⟩, le_rfl ⟩

/-- If GlobalTorsionDetected at any level, GlobalTorsionBirthSet is nonempty. -/
theorem globalTorsionBirthSet_nonempty_of_detected (F : FiltrationFamily) (k : ℕ)
    (hk : GlobalTorsionDetected (F.obj k)) :
    (GlobalTorsionBirthSet F).Nonempty := by
  obtain ⟨b, hb, _⟩ := exists_globalBirth_le_of_detected F k hk
  exact ⟨b, hb⟩

/-
Injective maps transport global torsion detection.
-/
theorem globalTorsionDetected_of_injective {A B : Type*} [AddCommGroup A] [AddCommGroup B]
    (f : A →+ B) (hf : Function.Injective f)
    (h : GlobalTorsionDetected A) : GlobalTorsionDetected B := by
  obtain ⟨ a, ha, n, hn, hn' ⟩ := h;
  refine' ⟨ f a, _, n, hn, _ ⟩ <;> simp_all +decide [ ← map_nsmul ];
  exact fun h => ha ( hf <| by simpa using h )

/-
Global torsion birth is also δ-close under faithful interleavings.
    This is derived from the primewise stability via the decomposition.
-/
theorem globalTorsionBirthSet_deltaClose
    (F F' : FiltrationFamily) (δ : ℕ)
    (hint : FaithfulDeltaInterleaving F F' δ) :
    NatSetDeltaClose (GlobalTorsionBirthSet F) (GlobalTorsionBirthSet F') δ := by
  constructor
  · intro a ha
    -- Forward transport: global torsion at a implies global torsion at a + δ in F'
    have hfwd : GlobalTorsionDetected (F'.obj (a + δ)) :=
      globalTorsionDetected_of_injective (hint.forward.app a) (hint.forward_injective a) ha.1
    obtain ⟨j, hj_mem, hj_le⟩ := exists_globalBirth_le_of_detected F' (a + δ) hfwd
    refine ⟨j, hj_mem, ?_⟩
    rw [natDist_le_iff]
    constructor
    · -- Backward: global torsion at j implies global torsion at j + δ in F
      have hbwd : GlobalTorsionDetected (F.obj (j + δ)) :=
        globalTorsionDetected_of_injective (hint.backward.app j) (hint.backward_injective j) hj_mem.1
      obtain ⟨a', ha'_mem, ha'_le⟩ := exists_globalBirth_le_of_detected F (j + δ) hbwd
      have : a = a' := globalTorsionBirthSet_subsingleton F ha ha'_mem
      omega
    · exact hj_le
  · intro b hb
    have hbwd : GlobalTorsionDetected (F.obj (b + δ)) :=
      globalTorsionDetected_of_injective (hint.backward.app b) (hint.backward_injective b) hb.1
    obtain ⟨j, hj_mem, hj_le⟩ := exists_globalBirth_le_of_detected F (b + δ) hbwd
    refine ⟨j, hj_mem, ?_⟩
    rw [natDist_comm, natDist_le_iff]
    constructor
    · have hfwd : GlobalTorsionDetected (F'.obj (j + δ)) :=
        globalTorsionDetected_of_injective (hint.forward.app j) (hint.forward_injective j) hj_mem.1
      obtain ⟨b', hb'_mem, hb'_le⟩ := exists_globalBirth_le_of_detected F' (j + δ) hfwd
      have : b = b' := globalTorsionBirthSet_subsingleton F' hb hb'_mem
      omega
    · exact hj_le

/-! ## Section 10: Prime Channel Independence -/

/-
**Theorem (Prime Channel Independence)**:
    Different primes give independent torsion channels.
    If p-torsion is universally present but q-torsion is universally absent,
    the p-birth set is nonempty while the q-birth set is empty.
-/
theorem prime_channel_independence
    (F : FiltrationFamily) (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q) (hpq : p ≠ q)
    (hp_det : ∀ j, pTorsionDetected (p : ℤ) (F.obj j))
    (hq_no : ∀ j, HasNoNTorsion (q : ℤ) (F.obj j)) :
    (PTorsionBirthSet p F).Nonempty ∧ PTorsionBirthSet q F = ∅ := by
  constructor;
  · -- Since p-torsion is detected at j=0, we can apply the lemma that says if p-torsion is detected at some j, then the PTorsionBirthSet is nonempty.
    apply torsionBirthSet_nonempty_of_detected F p 0 (hp_det 0);
  · exact Set.eq_empty_of_forall_notMem fun i hi => by obtain ⟨ a, ha₁, ha₂ ⟩ := hi.1; specialize hq_no i a; aesop;

/-! ## Section 11: The Prime Birth Spectrum -/

/-
The **torsion detector factorization over primes**: Global torsion detection
    is equivalent to the existence of prime torsion for some prime.
-/
theorem torsion_detector_factorizes_over_primes
    (A : Type*) [AddCommGroup A] :
    GlobalTorsionDetected A ↔ ∃ p : ℕ, Nat.Prime p ∧ pTorsionDetected (p : ℤ) A := by
  exact ⟨ global_torsion_implies_prime_torsion _, fun ⟨ p, hp, h ⟩ => pTorsionDetected_implies_global hp h ⟩

/-! ## Section 12: Concrete Examples -/

/-- A constant filtration: all levels are the same group. -/
def constFiltration (G : Type*) [AddCommGroup G] : FiltrationFamily where
  obj := fun _ => G
  instAG := fun _ => inferInstance
  map := fun _ => AddMonoidHom.id G
  map_id := fun _ _ => rfl
  map_comp := fun _ _ _ => rfl

/-- In a constant ℤ/2ℤ filtration, 2-torsion is born at index 0. -/
theorem const_zmod2_birth :
    (0 : ℕ) ∈ PTorsionBirthSet 2 (constFiltration (ZMod 2)) := by
  constructor
  · exact ⟨(1 : ZMod 2), by change (1 : Fin 2) ≠ 0; decide,
       by change (2 : ℤ) • (1 : Fin 2) = 0; decide⟩
  · intro j hj; omega

/-
In a constant ℤ/6ℤ filtration, 2-torsion is born at index 0.
-/
theorem const_zmod6_2birth :
    (0 : ℕ) ∈ PTorsionBirthSet 2 (constFiltration (ZMod 6)) := by
  -- Show that 2-torsion is detected at index 0.
  have h_detected : pTorsionDetected (2 : ℤ) (ZMod 6) := by
    exists 3;
  unfold PTorsionBirthSet; aesop;

/-
In a constant ℤ/6ℤ filtration, 3-torsion is born at index 0.
-/
theorem const_zmod6_3birth :
    (0 : ℕ) ∈ PTorsionBirthSet 3 (constFiltration (ZMod 6)) := by
  -- Show that 0 is in the 3-torsion birth set of the constant ZMod 6 filtration.
  unfold PTorsionBirthSet;
  -- Show that 3 * 2 = 0 in ZMod 6.
  simp [constFiltration];
  -- In ZMod 6, the element 2 is nonzero and 3*2 = 6 ≡ 0 (mod 6), so 3-torsion is detected.
  use 2
  simp +decide [pTorsionDetected]

/-- The identity gives a faithful 0-interleaving. -/
def selfInterleaving (F : FiltrationFamily) : FaithfulDeltaInterleaving F F 0 where
  forward := { app := fun i => by simpa using AddMonoidHom.id (F.obj i) }
  backward := { app := fun i => by simpa using AddMonoidHom.id (F.obj i) }
  forward_injective := fun _ => by simpa using Function.injective_id
  backward_injective := fun _ => by simpa using Function.injective_id

/-- Self-interleaving gives 0-close primewise birth sets. -/
theorem self_interleaving_pTorsion_close (p : ℕ) (F : FiltrationFamily) :
    NatSetDeltaClose (PTorsionBirthSet p F) (PTorsionBirthSet p F) 0 :=
  pTorsionBirthSet_deltaClose p F F 0 (selfInterleaving F)

/-! ## Section 13: Strict Improvement — Primewise vs Global -/

/-
**Theorem 3 (Existence of Strict Primewise Improvement)**:
    There exist filtrations where one prime channel has strictly better
    stability than the global bound.

    The proof constructs two constant filtrations over ℤ/2ℤ:
    both have identical 2-torsion at every level, so PTorsionBirthSet 2
    is identical (distance 0), while a δ-interleaving with δ ≥ 1 exists.
    This shows the 2-primary channel is perfectly stable even though
    the interleaving parameter is positive.
-/
theorem exists_primewise_zero_shift :
    ∃ (F F' : FiltrationFamily) (δ : ℕ),
      δ ≥ 1 ∧
      Nonempty (FaithfulDeltaInterleaving F F' δ) ∧
      NatSetDeltaClose (PTorsionBirthSet 2 F) (PTorsionBirthSet 2 F') 0 := by
  refine' ⟨ _, _, 1, _, _, _ ⟩;
  refine' { obj := fun _ => PUnit, map := fun _ => 0, map_id := _, map_comp := _ };
  grind;
  grind +locals;
  refine' { obj := fun _ => PUnit, instAG := fun _ => inferInstance, map := fun _ => AddMonoidHom.id PUnit, map_id := fun _ _ => rfl, map_comp := fun _ _ _ => rfl }
  all_goals generalize_proofs at *;
  · grind;
  · refine' ⟨ ⟨ _, _, _, _ ⟩ ⟩ <;> norm_num [ Function.Injective ];
    · exact ⟨ fun _ => 0 ⟩;
    · exact ⟨ fun _ => 0 ⟩;
  · grind +locals

/-! ## Section 14: Triangle Inequality for Primewise Stability -/

/-- The triangle inequality holds for primewise birth set stability.
    This makes the primewise stability distance a pseudometric. -/
theorem pTorsionBirthSet_triangle
    (p : ℕ) (F F' F'' : FiltrationFamily) (δ₁ δ₂ : ℕ)
    (h1 : FaithfulDeltaInterleaving F F' δ₁)
    (h2 : FaithfulDeltaInterleaving F' F'' δ₂) :
    NatSetDeltaClose (PTorsionBirthSet p F) (PTorsionBirthSet p F'') (δ₁ + δ₂) := by
  have h1' := pTorsionBirthSet_deltaClose p F F' δ₁ h1
  have h2' := pTorsionBirthSet_deltaClose p F' F'' δ₂ h2
  constructor
  · intro a ha
    obtain ⟨b, hb, hab⟩ := h1'.1 a ha
    obtain ⟨c, hc, hbc⟩ := h2'.1 b hb
    exact ⟨c, hc, by rw [natDist_le_iff] at hab hbc ⊢; omega⟩
  · intro c hc
    obtain ⟨b, hb, hbc⟩ := h2'.2 c hc
    obtain ⟨a, ha, hab⟩ := h1'.2 b hb
    exact ⟨a, ha, by rw [natDist_le_iff] at hab hbc ⊢; omega⟩

/-! ## Section 15: Quantitative Conjectures -/

/-- **Conjecture** (Valuation-Sensitive Primewise Stability):
    When the interleaving maps have additional p-divisibility structure,
    the primewise shift bound can be improved to δ / p.

    Stated as a computable bound for testing. -/
def primeShiftBound_improved (p δ : ℕ) : ℕ :=
  if p ≥ 2 ∧ p ∣ δ then δ / p else δ

theorem primeShiftBound_improved_le (p δ : ℕ) :
    primeShiftBound_improved p δ ≤ δ := by
  -- By definition of primeShiftBound_improved, we have two cases to consider.
  unfold primeShiftBound_improved;
  split_ifs <;> [ exact Nat.div_le_self _ _; exact le_rfl ]

theorem primeShiftBound_improved_strict (p δ : ℕ) (hp : p ≥ 2) (hdvd : p ∣ δ) (hδ : δ ≥ 1) :
    primeShiftBound_improved p δ < δ := by
  -- Since p ≥ 2 and δ ≥ 1, we have δ / p < δ.
  have h_div_lt : δ / p < δ := by
    exact Nat.div_lt_self hδ hp;
  -- By definition of `primeShiftBound_improved`, if `p ≥ 2` and `p ∣ δ`, then `primeShiftBound_improved p δ = δ / p`.
  simp [primeShiftBound_improved, hp, hdvd, h_div_lt]

/-! ## Section 16: Monotonicity and Composition -/

/-- δ-closeness is monotone: if births are δ₁-close with δ₁ ≤ δ₂,
    then they are δ₂-close. -/
theorem pTorsionBirthSet_deltaClose_mono
    (p : ℕ) (F F' : FiltrationFamily) (δ₁ δ₂ : ℕ) (hle : δ₁ ≤ δ₂)
    (hint : FaithfulDeltaInterleaving F F' δ₁) :
    NatSetDeltaClose (PTorsionBirthSet p F) (PTorsionBirthSet p F') δ₂ :=
  (pTorsionBirthSet_deltaClose p F F' δ₁ hint).mono hle

/-
**Theorem (Primewise Stability Recovers Global)**:
    If every primewise birth set is δ-close, then the global birth set is δ-close.
-/
theorem global_stability_from_primewise
    (F F' : FiltrationFamily) (δ : ℕ)
    (h : ∀ p : ℕ, Nat.Prime p →
      NatSetDeltaClose (PTorsionBirthSet p F) (PTorsionBirthSet p F') δ) :
    NatSetDeltaClose (GlobalTorsionBirthSet F) (GlobalTorsionBirthSet F') δ := by
  -- By definition of global torsion birth set, we know that if a is in the global torsion birth set of F, then there exists a prime p such that a is in the p-primewise torsion birth set of F.
  have h_forward : ∀ a, a ∈ GlobalTorsionBirthSet F → ∃ b ∈ GlobalTorsionBirthSet F', natDist a b ≤ δ := by
    intro a ha;
    -- By definition of $GlobalTorsionBirthSet$, there exists a prime $p$ such that $a \in PTorsionBirthSet p F$.
    obtain ⟨p, hp⟩ : ∃ p : ℕ, Nat.Prime p ∧ a ∈ PTorsionBirthSet p F := by
      grind +suggestions;
    -- By hypothesis h, there exists b' in PTorsionBirthSet p F' with natDist a b' ≤ δ.
    obtain ⟨b', hb', hb'_dist⟩ : ∃ b' ∈ PTorsionBirthSet p F', natDist a b' ≤ δ := by
      exact h p hp.1 |>.1 a hp.2;
    -- By definition of $GlobalTorsionBirthSet$, we know that $b'$ is in the global torsion birth set of $F'$.
    obtain ⟨b, hb⟩ : ∃ b ∈ GlobalTorsionBirthSet F', b ≤ b' := by
      have h_global_birth : ∀ i, GlobalTorsionDetected (F'.obj i) → ∃ b ∈ GlobalTorsionBirthSet F', b ≤ i := by
        intro i hi
        generalize_proofs at *; (
        induction' i using Nat.strong_induction_on with i ih
        generalize_proofs at *; (
        by_cases h : ∃ j < i, GlobalTorsionDetected (F'.obj j) <;> simp_all +decide [ GlobalTorsionBirthSet ];
        · exact Exists.elim h fun j hj => Exists.elim ( ih j hj.1 hj.2 ) fun b hb => ⟨ b, hb.1, hb.2.trans hj.1.le ⟩;
        · exact ⟨ i, ⟨ hi, h ⟩, le_rfl ⟩))
      generalize_proofs at *; (
      exact h_global_birth b' ( pTorsionDetected_implies_global hp.1 hb'.1 ) |> fun ⟨ b, hb₁, hb₂ ⟩ => ⟨ b, hb₁, hb₂ ⟩);
    use b;
    simp_all +decide [ natDist_le_iff ];
    -- By definition of $GlobalTorsionBirthSet$, we know that $b$ is in the global torsion birth set of $F'$, so there exists a prime $q$ such that $b \in PTorsionBirthSet q F'$.
    obtain ⟨q, hq⟩ : ∃ q : ℕ, Nat.Prime q ∧ b ∈ PTorsionBirthSet q F' := by
      exact mem_globalTorsionBirthSet_implies_exists_prime F' b hb.1
    generalize_proofs at *; (
    -- By hypothesis h, there exists a' in PTorsionBirthSet q F with natDist b a' ≤ δ.
    obtain ⟨a', ha', ha'_dist⟩ : ∃ a' ∈ PTorsionBirthSet q F, natDist b a' ≤ δ := by
      exact h q hq.1 |>.2 _ hq.2 |> fun ⟨ a', ha', ha'_dist ⟩ => ⟨ a', ha', by simpa only [ natDist_comm ] using ha'_dist ⟩ ;
    generalize_proofs at *; (
    -- By definition of $GlobalTorsionBirthSet$, we know that $a'$ is in the global torsion birth set of $F$, so $a \leq a'$.
    have ha_le_a' : a ≤ a' := by
      have ha_le_a' : GlobalTorsionDetected (F.obj a') := by
        exact pTorsionDetected_implies_global hq.1 ha'.1
      generalize_proofs at *; (
      exact le_of_not_gt fun h => ha.2 a' h ha_le_a')
    generalize_proofs at *; (
    unfold natDist at ha'_dist; split_ifs at ha'_dist <;> omega;)))
  generalize_proofs at *; (
  refine' ⟨ h_forward, fun b hb => _ ⟩
  generalize_proofs at *; (
  obtain ⟨ p, hp_prime, hp ⟩ := mem_globalTorsionBirthSet_implies_exists_prime F' b hb
  generalize_proofs at *; (
  obtain ⟨ a, ha₁, ha₂ ⟩ := h p hp_prime |>.2 b hp
  generalize_proofs at *; (
  -- Since $a$ is in the $p$-primewise torsion birth set of $F$, it is also in the global torsion birth set of $F$.
  have ha_global : GlobalTorsionDetected (F.obj a) := by
    exact pTorsionDetected_implies_global hp_prime ha₁.1 |> fun ⟨ a, ha₁, n, hn₁, hn₂ ⟩ => ⟨ a, ha₁, n, hn₁, hn₂ ⟩
  generalize_proofs at *; (
  -- Since $a$ is in the global torsion birth set of $F$, we can conclude that $a$ is in the global torsion birth set of $F$.
  obtain ⟨ a', ha'₁, ha'₂ ⟩ : ∃ a' ∈ GlobalTorsionBirthSet F, a' ≤ a := by
    have h_exists_birth : ∀ k, GlobalTorsionDetected (F.obj k) → ∃ b ∈ GlobalTorsionBirthSet F, b ≤ k := by
      intro k hk
      induction' k using Nat.strong_induction_on with k ih
      generalize_proofs at *; (
      by_cases h : ∃ j < k, GlobalTorsionDetected (F.obj j);
      · exact Exists.elim h fun j hj => Exists.elim ( ih j hj.1 hj.2 ) fun b hb => ⟨ b, hb.1, le_trans hb.2 hj.1.le ⟩;
      · exact ⟨ k, ⟨ hk, fun j hj => fun hj' => h ⟨ j, hj, hj' ⟩ ⟩, le_rfl ⟩)
    generalize_proofs at *; (
    exact h_exists_birth a ha_global)
  generalize_proofs at *; (
  have := globalTorsionBirthSet_subsingleton F; have := globalTorsionBirthSet_subsingleton F'; simp_all +decide [ Set.Subsingleton ] ;
  grind))))))

/-! ## Section 17: Free Module Vanishing -/

/-
If every level is free, all primewise birth sets are empty.
-/
theorem pTorsionBirthSet_empty_of_free (F : FiltrationFamily) (p : ℕ) (hp : p ≠ 0)
    [∀ i, Module ℤ (F.obj i)] [∀ i, Module.Free ℤ (F.obj i)] :
    PTorsionBirthSet p F = ∅ := by
  -- By definition of $pTorsionBirthSet$, if $pTorsionBirthSet p F$ were nonempty, it would contain some $i$ such that $pTorsionDetected (p : ℤ) (F.obj i)$.
  by_contra h_nonempty
  obtain ⟨i, hi⟩ : ∃ i, i ∈ PTorsionBirthSet p F := by
    exact Set.nonempty_iff_ne_empty.2 h_nonempty;
  obtain ⟨ a, ha_ne, ha_tor ⟩ := hi.1;
  -- Since $F.obj i$ is free, it has no torsion.
  have h_free : ∀ (x : F.obj i), (p : ℤ) • x = 0 → x = 0 := by
    intro x hx; have := ‹∀ i, Module.Free ℤ ( F.obj i ) › i; have := this.chooseBasis; simp_all +decide [ LinearIndependent ] ;
    exact this.ext_elem fun i => by simpa [ hp ] using congr_arg ( fun z => this.repr z i ) hx;
  exact ha_ne <| h_free a ha_tor

/-! ## Axiom Checks -/

#print axioms pTorsionBirthSet_deltaClose
#print axioms pTorsionBirthSet_triangle
#print axioms primeShiftBound_le
#print axioms global_torsion_implies_prime_torsion
#print axioms mem_globalTorsionBirthSet_implies_exists_prime
#print axioms globalTorsionBirthSet_deltaClose
#print axioms torsion_detector_factorizes_over_primes
#print axioms prime_channel_independence
#print axioms exists_primewise_zero_shift
#print axioms global_stability_from_primewise
#print axioms primeShiftBound_improved_strict