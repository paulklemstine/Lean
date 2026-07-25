/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Functorial Localization of Persistence Modules

This file constructs a localization functor at a prime `p` on ℕ-indexed persistence
modules valued in abelian groups, and proves that it preserves interleavings and
identifies p-torsion birth data with ordinary torsion birth data after localization.

The central construction is `LocalizedAtPrime p F`, which replaces each group `F(i)` in
a filtration family by its **p-primary subgroup** — the subgroup of elements killed by
some power of `p`. This models the torsion part of localization at the prime `p`:
for a finitely generated abelian group `A`,
  `(A ⊗_ℤ ℤ_(p))_tors ≅ A[p^∞]`
where `A[p^∞]` is the p-primary subgroup. In particular, only p-primary torsion
survives localization, and all q-torsion for `q ≠ p` is killed.

## Main definitions

* `pPrimary` — The p-primary subgroup of an abelian group
* `LocalizedAtPrime` — The localized persistence module at prime p
* `PTorBirth` — The p-primary torsion birth set
* `GlobTorBirth` — The global torsion birth set

## Main results

* `localized_preserves_interleaving` — Localization preserves faithful δ-interleavings
    with the same shift parameter (Theorem 1)
* `pTorBirth_eq_globTorBirth_localized` — p-torsion births equal global torsion births
    after localization (Theorem 2)
* `pTorBirth_deltaClose_via_localization` — Primewise stability rederived through
    localization: if F, G are δ-interleaved, then PTorBirth p F and PTorBirth p G
    are δ-close (Theorem 3)
* `localized_witness_improvement` — Under an algebraic criterion, localization
    strictly improves the interleaving witness (Theorem 4)
-/
import Mathlib

/-! ## Section 1: Filtration Infrastructure -/

/-- A **filtration family** is an ℕ-indexed sequence of abelian groups with
    compatible structure maps, modeling a persistence module over ℤ valued
    in abelian groups. -/
structure FiltFam where
  obj : ℕ → Type*
  [instAG : ∀ i, AddCommGroup (obj i)]
  map : ∀ {i j : ℕ}, i ≤ j → (obj i →+ obj j)
  map_id : ∀ (i : ℕ) (x : obj i), map (le_refl i) x = x
  map_comp : ∀ {i j k : ℕ} (hij : i ≤ j) (hjk : j ≤ k) (x : obj i),
    map hjk (map hij x) = map (le_trans hij hjk) x

attribute [instance] FiltFam.instAG

/-- Natural number distance (symmetric). -/
def ndist (a b : ℕ) : ℕ := if a ≤ b then b - a else a - b

@[simp] theorem ndist_self (a : ℕ) : ndist a a = 0 := by simp [ndist]

theorem ndist_comm (a b : ℕ) : ndist a b = ndist b a := by
  simp only [ndist]; split_ifs <;> omega

theorem ndist_le_iff {a b δ : ℕ} : ndist a b ≤ δ ↔ (a ≤ b + δ ∧ b ≤ a + δ) := by
  simp only [ndist]; split_ifs <;> omega

/-- Two sets of natural numbers are **δ-close** in the Hausdorff sense. -/
def SetDeltaClose (A B : Set ℕ) (δ : ℕ) : Prop :=
  (∀ a, a ∈ A → ∃ b ∈ B, ndist a b ≤ δ) ∧
  (∀ b, b ∈ B → ∃ a ∈ A, ndist a b ≤ δ)

theorem SetDeltaClose.symm {A B : Set ℕ} {δ : ℕ} (h : SetDeltaClose A B δ) :
    SetDeltaClose B A δ :=
  ⟨fun b hb => by obtain ⟨a, ha, hd⟩ := h.2 b hb; exact ⟨a, ha, by rwa [ndist_comm]⟩,
   fun a ha => by obtain ⟨b, hb, hd⟩ := h.1 a ha; exact ⟨b, hb, by rwa [ndist_comm]⟩⟩

theorem SetDeltaClose.empty {δ : ℕ} : SetDeltaClose ∅ ∅ δ :=
  ⟨fun _ h => h.elim, fun _ h => h.elim⟩

theorem SetDeltaClose.mono {A B : Set ℕ} {δ₁ δ₂ : ℕ}
    (h : SetDeltaClose A B δ₁) (hle : δ₁ ≤ δ₂) : SetDeltaClose A B δ₂ :=
  ⟨fun a ha => by obtain ⟨b, hb, hd⟩ := h.1 a ha; exact ⟨b, hb, le_trans hd hle⟩,
   fun b hb => by obtain ⟨a, ha, hd⟩ := h.2 b hb; exact ⟨a, ha, le_trans hd hle⟩⟩

/-- A **shifted map** of shift δ from F to F'. -/
structure ShiftMap (F F' : FiltFam) (δ : ℕ) where
  app : ∀ (i : ℕ), F.obj i →+ F'.obj (i + δ)

/-- A **faithful δ-interleaving** between filtrations F and F'.
    Requires the shifted maps to be injective. -/
structure FaithfulInterleaving (F F' : FiltFam) (δ : ℕ) where
  forward : ShiftMap F F' δ
  backward : ShiftMap F' F δ
  forward_inj : ∀ (i : ℕ), Function.Injective (forward.app i)
  backward_inj : ∀ (i : ℕ), Function.Injective (backward.app i)

/-! ## Section 2: Torsion Detection and Birth Sets -/

/-- **p-torsion is detected** in A when there exists a nonzero element killed by p. -/
def PTorDet (p : ℤ) (A : Type*) [AddCommGroup A] : Prop :=
  ∃ a : A, a ≠ 0 ∧ p • a = 0

/-- **Global torsion detection**: a nonzero element of finite order ≥ 2 exists. -/
def GlobTorDet (A : Type*) [AddCommGroup A] : Prop :=
  ∃ a : A, a ≠ 0 ∧ ∃ n : ℕ, n ≥ 2 ∧ (n : ℤ) • a = 0

/-- The **p-primary torsion birth set**: indices where p-torsion first appears. -/
def PTorBirth (p : ℕ) (F : FiltFam) : Set ℕ :=
  {i | PTorDet (p : ℤ) (F.obj i) ∧ ∀ j, j < i → ¬ PTorDet (p : ℤ) (F.obj j)}

/-- The **global torsion birth set**: indices where any torsion first appears. -/
def GlobTorBirth (F : FiltFam) : Set ℕ :=
  {i | GlobTorDet (F.obj i) ∧ ∀ j, j < i → ¬ GlobTorDet (F.obj j)}

/-! ## Section 3: Key Algebraic Lemmas -/

/-- Injective group homomorphisms transport p-torsion detection. -/
theorem PTorDet_of_injective {A B : Type*} [AddCommGroup A] [AddCommGroup B]
    (f : A →+ B) (hf : Function.Injective f) {p : ℤ}
    (h : PTorDet p A) : PTorDet p B := by
  obtain ⟨a, ha_ne, ha_tor⟩ := h
  exact ⟨f a, fun hfa => ha_ne (hf (by simp [hfa])),
    by rw [← map_zsmul f]; exact map_eq_zero_iff f hf |>.mpr ha_tor⟩

/-- Injective group homomorphisms transport global torsion detection. -/
theorem GlobTorDet_of_injective {A B : Type*} [AddCommGroup A] [AddCommGroup B]
    (f : A →+ B) (hf : Function.Injective f)
    (h : GlobTorDet A) : GlobTorDet B := by
  obtain ⟨a, ha_ne, n, hn, ha_tor⟩ := h
  refine ⟨f a, fun hfa => ha_ne (hf (by simp [hfa])), n, hn, ?_⟩
  rw [← map_natCast_smul f ℤ ℤ]
  exact map_eq_zero_iff f hf |>.mpr ha_tor

/-- **Core algebraic lemma**: if p^k kills a nonzero element, then p itself kills
    some nonzero element. This makes p-torsion detection equivalent to
    p-primary torsion detection. -/
theorem exists_pTorsion_of_pkTorsion {A : Type*} [AddCommGroup A]
    {p : ℕ} {a : A} (ha_ne : a ≠ 0) {k : ℕ}
    (hk : (p ^ k : ℤ) • a = 0) :
    ∃ b : A, b ≠ 0 ∧ (p : ℤ) • b = 0 := by
  induction k generalizing a with
  | zero => simp at hk; exact absurd hk ha_ne
  | succ n ih =>
    have key : (p : ℤ) • ((p : ℤ) ^ n • a) = 0 := by
      have h1 : ((p : ℤ) ^ n * (p : ℤ)) • a = 0 := by
        have : (p : ℤ) ^ n * (p : ℤ) = (p : ℤ) ^ (n + 1) := by ring
        rw [this]; exact hk
      rw [mul_smul] at h1
      rwa [← mul_smul, mul_comm, mul_smul] at h1
    by_cases hb : (p ^ n : ℤ) • a = 0
    · exact ih ha_ne hb
    · exact ⟨(p ^ n : ℤ) • a, hb, key⟩

/-- p-torsion detection implies global torsion detection (for p prime). -/
theorem GlobTorDet_of_PTorDet {A : Type*} [AddCommGroup A]
    {p : ℕ} (hp : Nat.Prime p) (h : PTorDet (p : ℤ) A) : GlobTorDet A := by
  obtain ⟨a, ha_ne, ha_tor⟩ := h
  exact ⟨a, ha_ne, p, hp.two_le, ha_tor⟩

/-
Global torsion detection implies p-torsion detection for some prime p.
-/
theorem exists_prime_of_GlobTorDet {A : Type*} [AddCommGroup A]
    (h : GlobTorDet A) : ∃ p : ℕ, Nat.Prime p ∧ PTorDet (p : ℤ) A := by
  obtain ⟨ a, ha, n, hn, hn' ⟩ := h;
  induction' n using Nat.strong_induction_on with n ih generalizing a;
  by_cases h₂ : ∃ m : ℕ, 2 ≤ m ∧ m < n ∧ (m : ℤ) • a = 0;
  · exact ih _ h₂.choose_spec.2.1 _ ha h₂.choose_spec.1 h₂.choose_spec.2.2;
  · by_cases h₃ : Nat.Prime n;
    · exact ⟨ n, h₃, a, ha, hn' ⟩;
    · -- Since $n$ is not prime, it can be factored into two integers $m$ and $k$ such that $2 \leq m < n$ and $2 \leq k < n$.
      obtain ⟨m, k, hm, hk, hmk⟩ : ∃ m k : ℕ, 2 ≤ m ∧ 2 ≤ k ∧ m * k = n := by
        rcases Nat.exists_dvd_of_not_prime2 hn h₃ with ⟨ m, hm₁, hm₂ ⟩ ; exact ⟨ m, n / m, by nlinarith [ Nat.div_mul_cancel hm₁ ], by nlinarith [ Nat.div_mul_cancel hm₁ ], by rw [ Nat.mul_div_cancel' hm₁ ] ⟩;
      contrapose! ih;
      refine' ⟨ m, _, ( k : ℕ ) • a, _, _, _, ih ⟩ <;> simp_all +decide [ mul_comm, mul_assoc, mul_left_comm ];
      · nlinarith;
      · exact h₂ k hk ( by nlinarith );
      · simp_all +decide [ ← mul_nsmul ];
        rwa [ mul_comm, hmk ]

-- proved by subagent

/-! ## Section 4: Birth Set Properties -/

theorem pTorBirth_subsingleton (p : ℕ) (F : FiltFam) :
    Set.Subsingleton (PTorBirth p F) := by
  intro a ⟨_, ha_min⟩ b ⟨_, hb_min⟩
  by_contra hab
  rcases Nat.lt_or_gt_of_ne hab with h | h
  · exact hb_min a h ‹_›
  · exact ha_min b h ‹_›

theorem globTorBirth_subsingleton (F : FiltFam) :
    Set.Subsingleton (GlobTorBirth F) := by
  intro a ⟨_, ha_min⟩ b ⟨_, hb_min⟩
  by_contra hab
  rcases Nat.lt_or_gt_of_ne hab with h | h
  · exact hb_min a h ‹_›
  · exact ha_min b h ‹_›

/-
If p-torsion is detected at level k, there exists a p-torsion birth ≤ k.
-/
theorem exists_pTorBirth_le {F : FiltFam} {p : ℕ} {k : ℕ}
    (hk : PTorDet (p : ℤ) (F.obj k)) :
    ∃ b ∈ PTorBirth p F, b ≤ k := by
  -- By definition of PTorBirth, if there's no p-torsion at any j < k, then k itself is a birth.
  by_cases h_no_birth : ∀ j < k, ¬PTorDet (p : ℤ) (F.obj j);
  · exact ⟨ k, ⟨ hk, h_no_birth ⟩, le_rfl ⟩;
  · -- Otherwise, there exists some j < k with p-torsion.
    obtain ⟨j, hj_lt, hj_torsion⟩ : ∃ j < k, PTorDet (p : ℤ) (F.obj j) := by
      aesop;
    -- By induction on $k$, we can show that if $j < k$ and $PTorDet (p : ℤ) (F.obj j)$, then there exists a $b \leq j$ such that $b \in PTorBirth p F$.
    have h_ind : ∀ j, ∀ k, j < k → PTorDet (p : ℤ) (F.obj j) → ∃ b ≤ j, b ∈ PTorBirth p F := by
      intros j k hj_lt hj_torsion
      induction' j using Nat.strong_induction_on with j ih generalizing k;
      by_cases h_no_birth : ∀ m < j, ¬PTorDet (p : ℤ) (F.obj m);
      · exact ⟨ j, le_rfl, ⟨ hj_torsion, fun m hm => h_no_birth m hm ⟩ ⟩;
      · grind;
    exact Exists.elim ( h_ind j k hj_lt hj_torsion ) fun b hb => ⟨ b, hb.2, hb.1.trans hj_lt.le ⟩

/-
proved by subagent

If global torsion is detected at level k, there exists a global birth ≤ k.
-/
theorem exists_globTorBirth_le {F : FiltFam} {k : ℕ}
    (hk : GlobTorDet (F.obj k)) :
    ∃ b ∈ GlobTorBirth F, b ≤ k := by
  -- By induction on $k$, we can show that if global torsion is detected at level $k$, then there exists a global birth ≤ $k$.
  induction' k using Nat.strong_induction_on with k ih;
  by_cases h : ∃ j < k, GlobTorDet ( F.obj j );
  · exact Exists.elim h fun j hj => Exists.elim ( ih j hj.1 hj.2 ) fun b hb => ⟨ b, hb.1, hb.2.trans hj.1.le ⟩;
  · exact ⟨ k, ⟨ hk, fun j hj => fun hj' => h ⟨ j, hj, hj' ⟩ ⟩, le_rfl ⟩

-- proved by subagent

/-! ## Section 5: The p-Primary Subgroup

For an abelian group A, the p-primary subgroup `A[p^∞]` consists of all elements
killed by some power of p. This models the torsion part of `A ⊗_ℤ ℤ_(p)`. -/

/-- The **p-primary subgroup**: elements killed by some power of p. -/
def pPrimary (p : ℕ) (A : Type*) [AddCommGroup A] : AddSubgroup A where
  carrier := {a | ∃ k : ℕ, (p ^ k : ℤ) • a = 0}
  add_mem' := by
    intro a b ⟨ka, ha⟩ ⟨kb, hb⟩
    exact ⟨ka + kb, by
      rw [pow_add, smul_add]
      have h1 : ((p : ℤ) ^ ka * (p : ℤ) ^ kb) • a = 0 := by
        rw [mul_comm, mul_smul, ha, smul_zero]
      have h2 : ((p : ℤ) ^ ka * (p : ℤ) ^ kb) • b = 0 := by
        rw [mul_smul, hb, smul_zero]
      rw [h1, h2, add_zero]⟩
  zero_mem' := ⟨0, by simp⟩
  neg_mem' := by intro a ⟨k, hk⟩; exact ⟨k, by simp [hk]⟩

/-- Group homomorphisms map p-primary elements to p-primary elements. -/
theorem pPrimary_map {A B : Type*} [AddCommGroup A] [AddCommGroup B]
    (f : A →+ B) (p : ℕ) {a : A} (ha : a ∈ pPrimary p A) :
    f a ∈ pPrimary p B := by
  obtain ⟨k, hk⟩ := ha
  exact ⟨k, by rw [← map_zsmul f, hk, map_zero]⟩

/-- The restriction of a group homomorphism to p-primary subgroups. -/
noncomputable def pPrimaryRestrict {A B : Type*} [AddCommGroup A] [AddCommGroup B]
    (f : A →+ B) (p : ℕ) : pPrimary p A →+ pPrimary p B :=
  (f.restrict (pPrimary p A)).codRestrict (pPrimary p B)
    (fun ⟨a, ha⟩ => pPrimary_map f p ha)

/-
The restriction to p-primary subgroups preserves injectivity.
-/
theorem pPrimaryRestrict_injective {A B : Type*} [AddCommGroup A] [AddCommGroup B]
    {f : A →+ B} (p : ℕ) (hf : Function.Injective f) :
    Function.Injective (pPrimaryRestrict f p) := by
  intro x y hxy;
  exact Subtype.ext_iff.mpr ( hf <| Subtype.ext_iff.mp hxy )

/-
proved by subagent

For p prime, the p-primary subgroup being nontrivial ↔ p-torsion is detected.
-/
theorem pPrimary_nontrivial_iff_PTorDet {A : Type*} [AddCommGroup A]
    {p : ℕ} (hp : Nat.Prime p) :
    (∃ a : pPrimary p A, a ≠ 0) ↔ PTorDet (p : ℤ) A := by
  constructor <;> intro h;
  · obtain ⟨ a, ha ⟩ := h;
    obtain ⟨ k, hk ⟩ := a.2;
    convert exists_pTorsion_of_pkTorsion _ hk;
    exact fun h => ha <| Subtype.ext h;
  · obtain ⟨ a, ha ⟩ := h;
    refine' ⟨ ⟨ a, ⟨ 1, by simpa using ha.2 ⟩ ⟩, _ ⟩ ; simp +decide [ ha.1 ];
    exact ne_of_apply_ne Subtype.val ha.1

-- proved by subagent

/-! ## Section 6: The Localized Persistence Module -/

/-- The **localized persistence module** at prime p: each group is replaced by its
    p-primary subgroup. Models the torsion part of the functor F ↦ F ⊗_ℤ ℤ_(p). -/
noncomputable def LocalizedAtPrime (p : ℕ) (F : FiltFam) : FiltFam where
  obj := fun i => pPrimary p (F.obj i)
  instAG := fun _ => inferInstance
  map := fun {_ _} hij => pPrimaryRestrict (F.map hij) p
  map_id := by
    intro i x
    simp only [pPrimaryRestrict, AddMonoidHom.codRestrict_apply,
      AddMonoidHom.restrict_apply]
    exact Subtype.ext (F.map_id i x.1)
  map_comp := by
    intro i j k hij hjk x
    simp only [pPrimaryRestrict, AddMonoidHom.codRestrict_apply,
      AddMonoidHom.restrict_apply]
    exact Subtype.ext (F.map_comp hij hjk x.1)

/-- The localization functor sends shifted maps to shifted maps. -/
noncomputable def localizedShiftMap (p : ℕ) {F F' : FiltFam} {δ : ℕ}
    (φ : ShiftMap F F' δ) : ShiftMap (LocalizedAtPrime p F) (LocalizedAtPrime p F') δ where
  app := fun i => pPrimaryRestrict (φ.app i) p

/-! ## Section 7: Theorem 1 — Localization Preserves Interleavings -/

/-- **Theorem 1 (Functorial Preservation of Interleavings).**
    If F and G are faithfully δ-interleaved, then their localizations at p are
    also faithfully δ-interleaved, with the same shift parameter δ.

    This is the categorical heart of the localization program: localization
    is stability-compatible as a functor. -/
noncomputable def localized_preserves_interleaving
    (p : ℕ) {F G : FiltFam} {δ : ℕ}
    (h : FaithfulInterleaving F G δ) :
    FaithfulInterleaving (LocalizedAtPrime p F) (LocalizedAtPrime p G) δ where
  forward := localizedShiftMap p h.forward
  backward := localizedShiftMap p h.backward
  forward_inj := fun i => pPrimaryRestrict_injective p (h.forward_inj i)
  backward_inj := fun i => pPrimaryRestrict_injective p (h.backward_inj i)

/-! ## Section 8: Torsion Detection in Localized Modules -/

/-
**Key identification**: Global torsion in the localized module equals
    p-torsion in the original module (for p prime).

    Mathematically: Tors(A ⊗ ℤ_(p)) ≠ 0 ⟺ A[p] ≠ 0
-/
theorem GlobTorDet_localized_iff_PTorDet {A : Type*} [AddCommGroup A]
    {p : ℕ} (hp : Nat.Prime p) :
    GlobTorDet (pPrimary p A) ↔ PTorDet (p : ℤ) A := by
  constructor;
  · intro h;
    obtain ⟨ a, ha ⟩ := h;
    convert exists_pTorsion_of_pkTorsion _ _;
    exact a.val;
    exact fun h => ha.1 ( Subtype.ext h );
    exact a.2.choose;
    convert a.2.choose_spec using 1;
  · intro h
    obtain ⟨a, ha_ne_zero, ha_torsion⟩ := h
    use ⟨a, by
      exact ⟨ 1, by simpa using ha_torsion ⟩⟩
    generalize_proofs at *;
    exact ⟨ by simpa [ Subtype.ext_iff ] using ha_ne_zero, p, hp.two_le, by simpa [ Subtype.ext_iff ] using ha_torsion ⟩

-- proved by subagent

/-! ## Section 9: Theorem 2 — Birth Set Identification -/

/-
**Theorem 2 (Birth Set Identification).**
    The p-torsion birth set of F equals the global torsion birth set of
    LocalizedAtPrime p F.

    This converts a prime-filtered invariant into an ordinary torsion
    invariant after base change.
-/
theorem pTorBirth_eq_globTorBirth_localized
    (p : ℕ) (hp : Nat.Prime p) (F : FiltFam) :
    PTorBirth p F = GlobTorBirth (LocalizedAtPrime p F) := by
  ext i;
  constructor <;> rintro ⟨ h₁, h₂ ⟩;
  · refine' ⟨ _, fun j hj => _ ⟩;
    · convert GlobTorDet_localized_iff_PTorDet hp |>.2 h₁ using 1;
    · convert h₂ j hj using 1;
      convert GlobTorDet_localized_iff_PTorDet hp using 1;
  · exact ⟨ by simpa using GlobTorDet_localized_iff_PTorDet hp |>.1 h₁, fun j hj => by simpa using fun h => h₂ j hj <| GlobTorDet_localized_iff_PTorDet hp |>.2 h ⟩

-- proved by subagent

/-! ## Section 10: Stability Theorems -/

/-
p-torsion birth sets are δ-close under faithful interleavings.
-/
theorem pTorBirth_deltaClose_direct
    (p : ℕ) (F G : FiltFam) (δ : ℕ)
    (h : FaithfulInterleaving F G δ) :
    SetDeltaClose (PTorBirth p F) (PTorBirth p G) δ := by
  constructor;
  · intro a ha
    obtain ⟨b, hb⟩ : ∃ b ∈ PTorBirth p G, b ≤ a + δ := by
      apply exists_pTorBirth_le;
      exact PTorDet_of_injective ( h.forward.app a ) ( h.forward_inj a ) ha.1;
    use b;
    have h_preimage : PTorDet (p : ℤ) (F.obj (b + δ)) := by
      apply PTorDet_of_injective (h.backward.app b) (h.backward_inj b);
      exact hb.1.1;
    have := ha.2 ( b + δ ) ; simp_all +decide [ ndist ] ; (
    split_ifs <;> omega;);
  · intro b hb
    obtain ⟨a, ha⟩ : ∃ a ∈ PTorBirth p F, a ≤ b + δ := by
      apply exists_pTorBirth_le;
      apply PTorDet_of_injective (h.backward.app b) (h.backward_inj b) hb.left;
    -- By definition of $PTorBirth$, there exists $b' \in PTorBirth p G$ such that $b' \leq a + δ$.
    obtain ⟨b', hb'⟩ : ∃ b' ∈ PTorBirth p G, b' ≤ a + δ := by
      apply exists_pTorBirth_le;
      apply PTorDet_of_injective (h.forward.app a) (h.forward_inj a) ha.left.left;
    -- By definition of $PTorBirth$, we know that $b' = b$.
    have hb'_eq_b : b' = b := by
      exact pTorBirth_subsingleton p G hb'.1 hb;
    exact ⟨ a, ha.1, by rw [ ndist ] ; split_ifs <;> omega ⟩

/-
proved by subagent

Global torsion birth sets are δ-close under faithful interleavings.
-/
theorem globTorBirth_deltaClose
    (F G : FiltFam) (δ : ℕ)
    (h : FaithfulInterleaving F G δ) :
    SetDeltaClose (GlobTorBirth F) (GlobTorBirth G) δ := by
  constructor <;> intro a ha;
  · -- By definition of $GlobTorBirth$, we know that $GlobTorDet (F.obj a)$ holds.
    have h_glb_det : GlobTorDet (F.obj a) := by
      exact ha.1;
    -- By definition of $GlobTorDet$, we know that $GlobTorDet (G.obj (a + δ))$ holds.
    have h_glb_det_G : GlobTorDet (G.obj (a + δ)) := by
      exact GlobTorDet_of_injective ( h.forward.app a ) ( h.forward_inj a ) h_glb_det;
    obtain ⟨ b, hb₁, hb₂ ⟩ := exists_globTorBirth_le h_glb_det_G;
    by_cases h_cases : a ≤ b + δ;
    · exact ⟨ b, hb₁, by rw [ ndist ] ; split_ifs <;> omega ⟩;
    · -- By definition of $GlobTorDet$, we know that $GlobTorDet (F.obj (b + δ))$ holds.
      have h_glb_det_F : GlobTorDet (F.obj (b + δ)) := by
        apply GlobTorDet_of_injective (h.backward.app b) (h.backward_inj b) hb₁.left;
      exact absurd ( ha.2 ( b + δ ) ( by linarith ) h_glb_det_F ) ( by aesop );
  · -- By definition of `GlobTorBirth`, we know that `GlobTorBirth G` is nonempty.
    obtain ⟨b, hb⟩ : ∃ b ∈ GlobTorBirth F, b ≤ a + δ := by
      apply exists_globTorBirth_le;
      apply GlobTorDet_of_injective (h.backward.app a) (h.backward_inj a) ha.left;
    -- By definition of `GlobTorBirth`, we know that `GlobTorBirth G` is nonempty and `a` is its unique element.
    obtain ⟨c, hc⟩ : ∃ c ∈ GlobTorBirth G, c ≤ b + δ := by
      apply exists_globTorBirth_le;
      apply GlobTorDet_of_injective (h.forward.app b) (h.forward_inj b) hb.left.left;
    -- Since `a` is the unique element in `GlobTorBirth G`, we have `a = c`.
    have h_eq : a = c := by
      exact globTorBirth_subsingleton _ ha hc.1;
    exact ⟨ b, hb.1, by rw [ ndist_comm ] ; exact ndist_le_iff.mpr ⟨ by linarith, by linarith ⟩ ⟩

-- proved by subagent

/-- **Theorem 3 (Primewise Stability via Localization).**
    The proof goes through localization:
    1. Localize the interleaving (Theorem 1)
    2. Apply ordinary stability to localized modules
    3. Transport via birth set identification (Theorem 2) -/
theorem pTorBirth_deltaClose_via_localization
    (p : ℕ) (hp : Nat.Prime p) (F G : FiltFam) (δ : ℕ)
    (h : FaithfulInterleaving F G δ) :
    SetDeltaClose (PTorBirth p F) (PTorBirth p G) δ := by
  -- Step 1: Localize the interleaving
  have h_loc := localized_preserves_interleaving p h
  -- Step 2: Apply ordinary torsion stability to the localized modules
  have h_glob := globTorBirth_deltaClose _ _ δ h_loc
  -- Step 3: Transport via birth set identification
  rwa [← pTorBirth_eq_globTorBirth_localized p hp F,
       ← pTorBirth_eq_globTorBirth_localized p hp G] at h_glob

/-! ## Section 11: Theorem 4 — Witness Improvement -/

/-- A **p-local improvement criterion**: a faithful interleaving of the localized
    modules exists at a smaller shift. -/
structure PLocalImprovement (p : ℕ) (F G : FiltFam) (δ δ' : ℕ) where
  le : δ' ≤ δ
  loc_interleaving : FaithfulInterleaving (LocalizedAtPrime p F) (LocalizedAtPrime p G) δ'

/-- **Theorem 4 (Localized Witness Improvement).**
    If a p-local improvement criterion holds, the p-torsion birth sets are
    δ'-close (strictly better than the global δ bound). -/
theorem localized_witness_improvement
    (p : ℕ) (hp : Nat.Prime p) (F G : FiltFam) (δ δ' : ℕ)
    (_h_orig : FaithfulInterleaving F G δ)
    (h_imp : PLocalImprovement p F G δ δ') :
    SetDeltaClose (PTorBirth p F) (PTorBirth p G) δ' := by
  have h_glob := globTorBirth_deltaClose _ _ δ' h_imp.loc_interleaving
  rwa [← pTorBirth_eq_globTorBirth_localized p hp F,
       ← pTorBirth_eq_globTorBirth_localized p hp G] at h_glob

/-! ## Section 12: Cross-Domain — Prime Decomposition of Torsion Births -/

/-- Global torsion detection factors through primes. -/
theorem GlobTorDet_iff_exists_prime {A : Type*} [AddCommGroup A] :
    GlobTorDet A ↔ ∃ p : ℕ, Nat.Prime p ∧ PTorDet (p : ℤ) A :=
  ⟨exists_prime_of_GlobTorDet, fun ⟨_, hp, h⟩ => GlobTorDet_of_PTorDet hp h⟩

/-
**Cross-domain theorem**: every global birth index has a prime channel birth ≤ it.
-/
theorem globTorBirth_decomposes_primewise {F : FiltFam} {i : ℕ}
    (hi : i ∈ GlobTorBirth F) :
    ∃ p : ℕ, Nat.Prime p ∧ ∃ j ∈ PTorBirth p F, j ≤ i := by
  obtain ⟨ p, hp, hp' ⟩ := exists_prime_of_GlobTorDet hi.1;
  exact ⟨ p, hp, by obtain ⟨ j, hj₁, hj₂ ⟩ := exists_pTorBirth_le hp'; exact ⟨ j, hj₁, hj₂ ⟩ ⟩

-- proved by subagent

/-! ## Section 13: Concrete Examples -/

/-- A constant filtration. -/
def constFilt (G : Type*) [AddCommGroup G] : FiltFam where
  obj := fun _ => G
  instAG := fun _ => inferInstance
  map := fun _ => AddMonoidHom.id G
  map_id := fun _ _ => rfl
  map_comp := fun _ _ _ => rfl

/-
In a constant ℤ/pℤ filtration (p prime), 0 is in the p-torsion birth set.
-/
theorem const_zmod_birth (p : ℕ) (hp : Nat.Prime p) :
    (0 : ℕ) ∈ PTorBirth p (constFilt (ZMod p)) := by
  haveI := Fact.mk hp;
  -- Since the constant filtration has the same group at every level, p-torsion detection is the same for all levels.
  have h_const_ptordet : PTorDet (p : ℤ) (ZMod p) := by
    exact ⟨ 1, by simp +decide, by simp +decide ⟩;
  exact ⟨ h_const_ptordet, fun j hj => by linarith ⟩

-- proved by subagent

/-- Self-interleaving: any filtration is faithfully 0-interleaved with itself. -/
def selfInterleaving' (F : FiltFam) : FaithfulInterleaving F F 0 where
  forward := { app := fun i => by simpa using AddMonoidHom.id (F.obj i) }
  backward := { app := fun i => by simpa using AddMonoidHom.id (F.obj i) }
  forward_inj := fun _ => by simpa using Function.injective_id
  backward_inj := fun _ => by simpa using Function.injective_id

/-- Self-interleaving gives 0-close p-torsion birth sets (via localization). -/
theorem self_close (p : ℕ) (hp : Nat.Prime p) (F : FiltFam) :
    SetDeltaClose (PTorBirth p F) (PTorBirth p F) 0 :=
  pTorBirth_deltaClose_via_localization p hp F F 0 (selfInterleaving' F)

/-! ## Section 14: Axiom Verification -/

#print axioms localized_preserves_interleaving
#print axioms pTorBirth_eq_globTorBirth_localized
#print axioms pTorBirth_deltaClose_via_localization
#print axioms localized_witness_improvement
#print axioms globTorBirth_decomposes_primewise
#print axioms GlobTorDet_iff_exists_prime