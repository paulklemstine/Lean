/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Global Stability as Max Envelope

This file establishes the **max-envelope principle** for torsion persistence stability:
the global Hausdorff stability bound is controlled by the supremum of primewise
stability bounds over active prime channels.

## Central Result

For finite-type filtrations with finitely many active primes, the global torsion
birth set stability distance satisfies:

  globalBirthDistance(F,G) ≤ maxPrimeEnvelope(F,G)

where `maxPrimeEnvelope` is the supremum of primewise optimal shifts over active primes.
This converts a many-body arithmetic stability problem into a minimax principle over
finitely many local observables.

## Main Definitions

* `IsMaxEnvelope` — A predicate expressing that a global functional equals the pointwise
  maximum of a finite family of local functionals (the max-envelope property)
* `IsBoundedByMaxEnvelope` — The one-sided bound: global ≤ max of local
* `PrimewiseComplete` — The strongest form: global = max of local

## Main Results

* `natDist_inf'_le_sup'_natDist` — General min-max Lipschitz lemma
* `hausdorff_singleton_dist` — Hausdorff distance between singletons = natDist
* `NatSetDeltaClose_subsingleton_nonempty` — Subsingleton Hausdorff distance characterization
* `globalBirth_le_primeBirth` — Global birth precedes any prime birth
* `global_shift_eq_prime_shift_of_single_determining_prime` — Equality for single prime
* `finite_prime_envelope_suffices` — Finite active prime set upper bound
* `bounded_by_envelope_of_uniform_bound` — Structural properties of max-envelopes

## Cross-Domain Connections

* **Metric geometry**: The global shift is an L∞-aggregation of primewise shifts
* **Minimax theory**: "Global optimum = worst local channel" is a deterministic minimax identity
* **Tropical geometry**: The max-envelope operation is max-plus in flavor
* **Coding theory**: Each prime is a channel; distortion is governed by the worst channel
-/
import Mathlib

open Finset

/-! ## Infrastructure (from PrimewiseTorsionStability) -/

/-- Natural number distance. -/
def natDist' (a b : ℕ) : ℕ := if a ≤ b then b - a else a - b

@[simp] theorem natDist'_self (a : ℕ) : natDist' a a = 0 := by simp [natDist']

theorem natDist'_comm (a b : ℕ) : natDist' a b = natDist' b a := by
  simp only [natDist']; split_ifs <;> omega

theorem natDist'_le_iff {a b δ : ℕ} : natDist' a b ≤ δ ↔ (a ≤ b + δ ∧ b ≤ a + δ) := by
  simp only [natDist']; split_ifs <;> omega

/-- **NatSetDeltaClose'**: Two subsets A, B ⊆ ℕ are δ-close in the Hausdorff sense. -/
def NatSetDeltaClose' (A B : Set ℕ) (δ : ℕ) : Prop :=
  (∀ a, a ∈ A → ∃ b ∈ B, natDist' a b ≤ δ) ∧
  (∀ b, b ∈ B → ∃ a ∈ A, natDist' a b ≤ δ)

theorem NatSetDeltaClose'.mono {A B : Set ℕ} {δ₁ δ₂ : ℕ}
    (h : NatSetDeltaClose' A B δ₁) (hle : δ₁ ≤ δ₂) : NatSetDeltaClose' A B δ₂ :=
  ⟨fun a ha => by obtain ⟨b, hb, hd⟩ := h.1 a ha; exact ⟨b, hb, le_trans hd hle⟩,
   fun b hb => by obtain ⟨a, ha, hd⟩ := h.2 b hb; exact ⟨a, ha, le_trans hd hle⟩⟩

theorem NatSetDeltaClose'.empty : NatSetDeltaClose' ∅ ∅ δ :=
  ⟨fun _ h => h.elim, fun _ h => h.elim⟩

/-- **p-torsion is detected** in A when there exists a nonzero element killed by p. -/
def pTorsionDetected' (p : ℤ) (A : Type*) [AddCommGroup A] : Prop :=
  ∃ a : A, a ≠ 0 ∧ p • a = 0

/-- **Global torsion detection**: there exists a nonzero element of finite order. -/
def GlobalTorsionDetected' (A : Type*) [AddCommGroup A] : Prop :=
  ∃ a : A, a ≠ 0 ∧ ∃ n : ℕ, n ≥ 2 ∧ (n : ℤ) • a = 0

/-- The **p-primary torsion birth set** for a natural number p. -/
def PTorsionBirthSet' (p : ℕ) (F : ℕ → Type*) [∀ i, AddCommGroup (F i)] : Set ℕ :=
  {i | pTorsionDetected' (p : ℤ) (F i) ∧
       ∀ j, j < i → ¬ pTorsionDetected' (p : ℤ) (F j)}

/-- The **global torsion birth set**. -/
def GlobalTorsionBirthSet' (F : ℕ → Type*) [∀ i, AddCommGroup (F i)] : Set ℕ :=
  {i | GlobalTorsionDetected' (F i) ∧ ∀ j, j < i → ¬ GlobalTorsionDetected' (F j)}

theorem pTorsionBirthSet'_subsingleton (p : ℕ) (F : ℕ → Type*) [∀ i, AddCommGroup (F i)] :
    Set.Subsingleton (PTorsionBirthSet' p F) := by
  intro a ⟨_, ha_min⟩ b ⟨_, hb_min⟩
  by_contra hab
  rcases Nat.lt_or_gt_of_ne hab with h | h
  · exact hb_min a h ‹_›
  · exact ha_min b h ‹_›

theorem globalTorsionBirthSet'_subsingleton (F : ℕ → Type*) [∀ i, AddCommGroup (F i)] :
    Set.Subsingleton (GlobalTorsionBirthSet' F) := by
  intro a ⟨_, ha_min⟩ b ⟨_, hb_min⟩
  by_contra hab
  rcases Nat.lt_or_gt_of_ne hab with h | h
  · exact hb_min a h ‹_›
  · exact ha_min b h ‹_›

/-! ## Part 1: The Max-Envelope Framework -/

/-- A global stability functional is a **max-envelope** of local functionals if it equals
the pointwise supremum of a finite family of local functionals. This is the key
abstraction: it says the global metric geometry is an L∞-aggregation of local metrics.

In the language of optimization, the global stability functional is the support
function of the active channel profile. In metric geometry, it is a max-envelope.
In information flow, no hidden cross-channel interference survives in the optimum. -/
def IsMaxEnvelope {α : Type*} {ι : Type*}
    (global : α → α → ℕ) (local_ : ι → α → α → ℕ) (S : Finset ι) : Prop :=
  ∀ F G, global F G = S.sup (fun i => local_ i F G)

/-- The one-sided bound: a global functional is **bounded by** the max-envelope
of a family of local functionals. -/
def IsBoundedByMaxEnvelope {α : Type*} {ι : Type*}
    (global : α → α → ℕ) (local_ : ι → α → α → ℕ) (S : Finset ι) : Prop :=
  ∀ F G, global F G ≤ S.sup (fun i => local_ i F G)

/-- **Primewise completeness**: the global stability distance equals the max-envelope
of primewise stability distances. -/
def PrimewiseComplete {α : Type*}
    (globalShift : α → α → ℕ) (primeShift : ℕ → α → α → ℕ)
    (S : Finset ℕ) (F G : α) : Prop :=
  globalShift F G = S.sup (fun p => primeShift p F G)

/-- A max-envelope implies the bounded-by-max-envelope property. -/
theorem IsMaxEnvelope.toBounded {α : Type*} {ι : Type*}
    {global : α → α → ℕ} {local_ : ι → α → α → ℕ} {S : Finset ι}
    (h : IsMaxEnvelope global local_ S) : IsBoundedByMaxEnvelope global local_ S :=
  fun F G => le_of_eq (h F G)

/-! ## Part 2: Finite Min-Max Lipschitz Lemma

The analytic core: the distance between minima of two functions over a finite set
is bounded by the maximum of their coordinatewise distances.

**Theorem**: |min(aᵢ) − min(bᵢ)| ≤ max |aᵢ − bᵢ|
-/

/-
**Min-Max Lipschitz Lemma**: The distance between minima is bounded by the
maximum of coordinatewise distances. The minimum function is 1-Lipschitz with
respect to the L∞ norm on finite sequences.

Proof: Let `j` achieve `inf' hs b`. Then `inf' a ≤ a j` and
`a j - b j ≤ natDist' (a j) (b j) ≤ sup'(...)`. Since `b j = inf' b`,
we get `inf' a - inf' b ≤ sup'(...)`. By symmetry, `inf' b - inf' a ≤ sup'(...)`.
-/
theorem natDist'_inf'_le_sup'_natDist' {ι : Type*} {s : Finset ι} (hs : s.Nonempty)
    (a b : ι → ℕ) :
    natDist' (s.inf' hs a) (s.inf' hs b) ≤
      s.sup' hs (fun i => natDist' (a i) (b i)) := by
  -- Let `j` achieve `inf' hs b` (use `Finset.exists_mem_eq_inf'`).
  obtain ⟨j, hj⟩ : ∃ j ∈ s, s.inf' hs b = b j := by
    exact?;
  -- By definition of infimum, we know that for any $j \in s$, $s.inf' hs a \leq a j$.
  have h_inf_le : s.inf' hs a ≤ a j := by
    exact Finset.inf'_le _ hj.1;
  -- By definition of supremum, we know that for any $j \in s$, $natDist' (a j) (b j) \leq s.sup' hs (fun i => natDist' (a i) (b i))$.
  have h_dist_le : natDist' (a j) (b j) ≤ s.sup' hs (fun i => natDist' (a i) (b i)) := by
    exact Finset.le_sup' ( fun i => natDist' ( a i ) ( b i ) ) hj.1;
  obtain ⟨i, hi⟩ : ∃ i ∈ s, s.inf' hs a = a i := by
    exact?;
  have h_inf_le' : s.inf' hs b ≤ b i := by
    exact Finset.inf'_le _ hi.1;
  have h_dist_le' : natDist' (a i) (b i) ≤ s.sup' hs (fun i => natDist' (a i) (b i)) := by
    exact Finset.le_sup' ( fun i => natDist' ( a i ) ( b i ) ) hi.1;
  unfold natDist' at *;
  lia

/-! ## Part 3: Singleton Set Distance -/

/-
The Hausdorff distance between two singletons equals the natural distance.
-/
theorem hausdorff_singleton_dist (a b : ℕ) {δ : ℕ} :
    NatSetDeltaClose' {a} {b} δ ↔ natDist' a b ≤ δ := by
  constructor <;> intro h <;> simp_all +decide [ NatSetDeltaClose' ]

/-
Two nonempty subsingleton sets that are δ-close: extract elements and bound.
-/
theorem NatSetDeltaClose'_subsingleton_nonempty
    {A B : Set ℕ} {δ : ℕ}
    (hA : Set.Subsingleton A) (hB : Set.Subsingleton B)
    (hAne : A.Nonempty) (hBne : B.Nonempty)
    (h : NatSetDeltaClose' A B δ) :
    ∃ a b, A = {a} ∧ B = {b} ∧ natDist' a b ≤ δ := by
  obtain ⟨ a, ha ⟩ := hAne; obtain ⟨ b, hb ⟩ := hBne; use a, b; simp_all +decide [ Set.eq_singleton_iff_unique_mem ] ;
  exact ⟨ fun x hx => hA hx ha, fun x hx => hB hx hb, h.1 a ha |> fun ⟨ y, hy, hy' ⟩ => by simpa [ hB hy hb ] using hy' ⟩

/-
NatSetDeltaClose' with the empty set on the left forces the right to be empty.
-/
theorem NatSetDeltaClose'_empty_left {B : Set ℕ} {δ : ℕ}
    (h : NatSetDeltaClose' ∅ B δ) : B = ∅ := by
  -- By definition of NatSetDeltaClose', if the empty set is δ-close to B, then for any b in B, there must be an element in the empty set that is δ-close to b. But the empty set has no elements, so this can't happen. Therefore, B must be empty.
  ext b
  simp [NatSetDeltaClose'] at h;
  tauto

/-! ## Part 4: Global Birth Decomposition

The global torsion birth is always determined by some prime.
-/

theorem pTorsionDetected'_implies_global {A : Type*} [AddCommGroup A]
    {p : ℕ} (hp : Nat.Prime p) (h : pTorsionDetected' (p : ℤ) A) :
    GlobalTorsionDetected' A := by
  obtain ⟨a, ha₁, ha₂⟩ := h
  exact ⟨a, ha₁, p, hp.two_le, ha₂⟩

/-
The global birth index is at most any prime birth index (when both exist).
-/
theorem globalBirth_le_primeBirth'
    (F : ℕ → Type*) [∀ i, AddCommGroup (F i)]
    (p : ℕ) (hp : Nat.Prime p)
    (n_g : ℕ) (hn_g : n_g ∈ GlobalTorsionBirthSet' F)
    (n_p : ℕ) (hn_p : n_p ∈ PTorsionBirthSet' p F) :
    n_g ≤ n_p := by
  exact le_of_not_gt fun h => hn_g.2 _ h <| pTorsionDetected'_implies_global hp ( hn_p.1 )

/-
When p-torsion and global torsion are born at the same index, any global birth
must also be a p-torsion birth.
-/
theorem birth_sets_agree_at_determining_prime'
    (F : ℕ → Type*) [∀ i, AddCommGroup (F i)]
    (p : ℕ) (_hp : Nat.Prime p)
    (n : ℕ) (hn_p : n ∈ PTorsionBirthSet' p F) (hn_g : n ∈ GlobalTorsionBirthSet' F) :
    ∀ m, m ∈ GlobalTorsionBirthSet' F → m ∈ PTorsionBirthSet' p F := by
  intro m hm
  have h_eq : m = n := by
    exact globalTorsionBirthSet'_subsingleton F hm hn_g;
  exact h_eq ▸ hn_p

/-! ## Part 5: Single-Prime Equality -/

/-
**Single-Prime Equality**: When the same prime `p` determines both global
births, the Hausdorff distances coincide.
-/
theorem global_shift_eq_prime_shift_of_single_determining_prime'
    (F G : ℕ → Type*) [∀ i, AddCommGroup (F i)] [∀ i, AddCommGroup (G i)]
    (p : ℕ) (_hp : Nat.Prime p)
    (n : ℕ) (hn_pF : n ∈ PTorsionBirthSet' p F) (hn_gF : n ∈ GlobalTorsionBirthSet' F)
    (m : ℕ) (hm_pG : m ∈ PTorsionBirthSet' p G) (hm_gG : m ∈ GlobalTorsionBirthSet' G)
    (δ : ℕ) :
    NatSetDeltaClose' (GlobalTorsionBirthSet' F) (GlobalTorsionBirthSet' G) δ ↔
    NatSetDeltaClose' (PTorsionBirthSet' p F) (PTorsionBirthSet' p G) δ := by
  have h_singleton : GlobalTorsionBirthSet' F = {n} ∧ GlobalTorsionBirthSet' G = {m} ∧ PTorsionBirthSet' p F = {n} ∧ PTorsionBirthSet' p G = {m} := by
    exact ⟨ globalTorsionBirthSet'_subsingleton F |>.eq_singleton_of_mem hn_gF, globalTorsionBirthSet'_subsingleton G |>.eq_singleton_of_mem hm_gG, pTorsionBirthSet'_subsingleton p F |>.eq_singleton_of_mem hn_pF, pTorsionBirthSet'_subsingleton p G |>.eq_singleton_of_mem hm_pG ⟩;
  simp +decide only [h_singleton]

/-! ## Part 5b: Well-Ordering Helpers -/

/-
If p-torsion is detected at index k, there exists a p-birth index ≤ k.
-/
theorem exists_pBirth_le_of_detected'
    (F : ℕ → Type*) [∀ i, AddCommGroup (F i)]
    (p : ℕ) (k : ℕ) (hk : pTorsionDetected' (p : ℤ) (F k)) :
    ∃ b ∈ PTorsionBirthSet' p F, b ≤ k := by
  -- Apply induction on $k$ to obtain the existence of $b \leq k$ such that $b \in PTorsionBirthSet' p F$.
  induction' k using Nat.strong_induction_on with k ih;
  by_cases h : ∃ j < k, pTorsionDetected' ( p : ℤ ) ( F j );
  · exact Exists.elim h fun j hj => Exists.elim ( ih j hj.1 hj.2 ) fun b hb => ⟨ b, hb.1, hb.2.trans hj.1.le ⟩;
  · exact ⟨ k, ⟨ hk, fun j hj => fun hj' => h ⟨ j, hj, hj' ⟩ ⟩, le_rfl ⟩

/-
If global torsion is detected at index k, there exists a global birth index ≤ k.
-/
theorem exists_globalBirth_le_of_detected'
    (F : ℕ → Type*) [∀ i, AddCommGroup (F i)]
    (k : ℕ) (hk : GlobalTorsionDetected' (F k)) :
    ∃ b ∈ GlobalTorsionBirthSet' F, b ≤ k := by
  -- We proceed by strong induction on $k$.
  induction' k using Nat.strong_induction_on with k ih;
  by_cases h : ∃ j < k, GlobalTorsionDetected' (F j);
  · exact Exists.elim h fun j hj => Exists.elim ( ih j hj.1 hj.2 ) fun b hb => ⟨ b, hb.1, hb.2.trans hj.1.le ⟩;
  · exact ⟨ k, ⟨ hk, fun j hj => fun hj' => h ⟨ j, hj, hj' ⟩ ⟩, le_rfl ⟩

/-
Global torsion implies prime torsion for some prime.
-/
theorem global_torsion_implies_prime_torsion'
    (A : Type*) [AddCommGroup A] (h : GlobalTorsionDetected' A) :
    ∃ p : ℕ, Nat.Prime p ∧ pTorsionDetected' (p : ℤ) A := by
  obtain ⟨ a, ha_ne, n, hn_ge2, hn ⟩ := h;
  induction' n using Nat.strongRecOn with n ih generalizing a;
  by_cases hn_prime : Nat.Prime n;
  · exact ⟨ n, hn_prime, a, ha_ne, hn ⟩;
  · -- If n is not prime, then it has a prime factor p such that p < n.
    obtain ⟨p, hp_prime, hp_div⟩ : ∃ p, Nat.Prime p ∧ p ∣ n ∧ p < n := by
      exact ⟨ Nat.minFac n, Nat.minFac_prime ( by linarith ), Nat.minFac_dvd n, Nat.lt_of_le_of_ne ( Nat.le_of_dvd ( by linarith ) ( Nat.minFac_dvd n ) ) fun h => hn_prime <| h ▸ Nat.minFac_prime ( by linarith ) ⟩;
    obtain ⟨ q, rfl ⟩ := hp_div.1;
    by_cases hq : q • a = 0;
    · rcases q with ( _ | _ | q ) <;> simp_all +decide;
      exact ih ( q + 1 + 1 ) ( by nlinarith only [ hp_prime.two_le ] ) a ha_ne ( by linarith ) hq;
    · simp_all +decide [ mul_smul ];
      exact ih p ( by nlinarith ) ( q • a ) hq ( by nlinarith [ hp_prime.two_le ] ) hn

/-! ## Part 6: Finite Prime Envelope -/

/-
Helper: natDist' is monotone when one endpoint moves closer.
-/
theorem natDist'_le_of_between {a b d : ℕ} (hbd : b ≤ d) (hd : natDist' a d ≤ δ) :
    b ≤ a + δ := by
  grind +locals

/-
If p has a nonempty birth set in F, and all primes outside S have empty birth sets,
then p ∈ S.
-/
theorem prime_in_S_of_birth_nonempty
    (F : ℕ → Type*) [∀ i, AddCommGroup (F i)]
    (S : Finset ℕ) (p : ℕ) (hp : Nat.Prime p)
    (hcov : ∀ q : ℕ, Nat.Prime q → q ∉ S → PTorsionBirthSet' q F = ∅)
    (hne : (PTorsionBirthSet' p F).Nonempty) : p ∈ S := by
  exact Classical.not_not.1 fun h => hne.ne_empty ( hcov p hp h )

/-
Helper: For the forward direction of the envelope theorem.
Given a ∈ GlobalTorsionBirthSet' F, extract the matching global birth in G
with distance bounded by S.sup δ.
-/
theorem finite_envelope_forward_half
    (F G : ℕ → Type*) [∀ i, AddCommGroup (F i)] [∀ i, AddCommGroup (G i)]
    (S : Finset ℕ) (δ : ℕ → ℕ)
    (_hall_prime : ∀ p ∈ S, Nat.Prime p)
    (hcov_F : ∀ p : ℕ, Nat.Prime p → p ∉ S → PTorsionBirthSet' p F = ∅)
    (hcov_G : ∀ p : ℕ, Nat.Prime p → p ∉ S → PTorsionBirthSet' p G = ∅)
    (hS : ∀ p ∈ S, NatSetDeltaClose' (PTorsionBirthSet' p F) (PTorsionBirthSet' p G) (δ p))
    (a : ℕ) (ha : a ∈ GlobalTorsionBirthSet' F) :
    ∃ b ∈ GlobalTorsionBirthSet' G, natDist' a b ≤ S.sup δ := by
  -- Get p prime with pTorsionDetected' at a: use global_torsion_implies_prime_torsion' _ ha.1.
  obtain ⟨p, hp_prime, hp_detected⟩ : ∃ p, Nat.Prime p ∧ pTorsionDetected' (p : ℤ) (F a) := global_torsion_implies_prime_torsion' (F a) ha.1;
  -- By exists_pBirth_le_of_detected', obtain c ∈ PTorsionBirthSet' p F, c ≤ a.
  obtain ⟨c, hc⟩ : ∃ c ∈ PTorsionBirthSet' p F, c ≤ a := exists_pBirth_le_of_detected' F p a hp_detected;
  -- By globalBirth_le_primeBirth', we have a ≤ c. Combining with c ≤ a, we get c = a.
  have hc_eq_a : c = a := by
    exact le_antisymm hc.2 ( globalBirth_le_primeBirth' F p hp_prime a ha c hc.1 );
  obtain ⟨d, hd⟩ : ∃ d ∈ PTorsionBirthSet' p G, natDist' a d ≤ δ p := by
    grind +locals;
  obtain ⟨b, hb⟩ : ∃ b ∈ GlobalTorsionBirthSet' G, b ≤ d := exists_globalBirth_le_of_detected' G d (pTorsionDetected'_implies_global hp_prime hd.left.left);
  have hb_le : b ≤ a + δ p := by
    have hb_le : b ≤ d ∧ natDist' a d ≤ δ p := by
      tauto;
    exact le_trans hb_le.1 ( natDist'_le_of_between ( by linarith ) hb_le.2 );
  obtain ⟨q, hq_prime, hq_detected⟩ : ∃ q : ℕ, Nat.Prime q ∧ pTorsionDetected' (q : ℤ) (G b) := by
    exact global_torsion_implies_prime_torsion' _ hb.1.1;
  obtain ⟨e, he⟩ : ∃ e ∈ PTorsionBirthSet' q G, e ≤ b := exists_pBirth_le_of_detected' G q b hq_detected;
  have he_eq_b : e = b := by
    exact le_antisymm he.2 ( globalBirth_le_primeBirth' G q hq_prime b hb.1 e he.1 );
  obtain ⟨f, hf⟩ : ∃ f ∈ PTorsionBirthSet' q F, natDist' f b ≤ δ q := by
    have := hS q ( prime_in_S_of_birth_nonempty G S q hq_prime hcov_G ⟨ e, he.1 ⟩ );
    simpa only [ he_eq_b ] using this.2 b ( by simpa only [ he_eq_b ] using he.1 );
  obtain ⟨a', ha'⟩ : ∃ a' ∈ GlobalTorsionBirthSet' F, a' ≤ f := exists_globalBirth_le_of_detected' F f (pTorsionDetected'_implies_global hq_prime hf.left.left);
  have ha'_eq_a : a' = a := by
    exact globalTorsionBirthSet'_subsingleton F ha'.1 ha;
  have ha_le : a ≤ b + δ q := by
    grind +suggestions;
  use b;
  simp_all +decide [ natDist'_le_iff ];
  exact ⟨ le_trans ha_le ( Nat.add_le_add_left ( Finset.le_sup ( f := δ ) ( show q ∈ S from prime_in_S_of_birth_nonempty G S q hq_prime hcov_G ⟨ b, he ⟩ ) ) _ ), le_trans hb_le ( Nat.add_le_add_left ( Finset.le_sup ( f := δ ) ( show p ∈ S from prime_in_S_of_birth_nonempty F S p hp_prime hcov_F ⟨ a, hc ⟩ ) ) _ ) ⟩

/-- **Finite Upper Envelope**: When only primes in a finite set S contribute,
the global shift is bounded by the sup of primewise shifts. -/
theorem finite_prime_envelope_suffices'
    (F G : ℕ → Type*) [∀ i, AddCommGroup (F i)] [∀ i, AddCommGroup (G i)]
    (S : Finset ℕ) (δ : ℕ → ℕ)
    (hall_prime : ∀ p ∈ S, Nat.Prime p)
    (hcov_F : ∀ p : ℕ, Nat.Prime p → p ∉ S →
      PTorsionBirthSet' p F = ∅)
    (hcov_G : ∀ p : ℕ, Nat.Prime p → p ∉ S →
      PTorsionBirthSet' p G = ∅)
    (hS : ∀ p ∈ S,
      NatSetDeltaClose' (PTorsionBirthSet' p F) (PTorsionBirthSet' p G) (δ p)) :
    NatSetDeltaClose' (GlobalTorsionBirthSet' F) (GlobalTorsionBirthSet' G) (S.sup δ) :=
  ⟨fun a ha => finite_envelope_forward_half F G S δ hall_prime hcov_F hcov_G hS a ha,
   fun b hb => by
    -- Symmetric: swap F and G, use backward direction of hS
    have hS' : ∀ p ∈ S, NatSetDeltaClose' (PTorsionBirthSet' p G) (PTorsionBirthSet' p F) (δ p) :=
      fun p hp => ⟨fun a ha => by
        obtain ⟨b, hb, hd⟩ := (hS p hp).2 a ha
        exact ⟨b, hb, by rwa [natDist'_comm]⟩,
       fun b hb => by
        obtain ⟨a, ha, hd⟩ := (hS p hp).1 b hb
        exact ⟨a, ha, by rwa [natDist'_comm]⟩⟩
    obtain ⟨a, ha, hd⟩ := finite_envelope_forward_half G F S δ hall_prime hcov_G hcov_F hS' b hb
    exact ⟨a, ha, by rwa [natDist'_comm]⟩⟩

/-! ## Part 7: Structural Properties of Max-Envelopes -/

/-
If a global functional is bounded by a max-envelope, then it is bounded by
any uniform upper bound on the local functionals.
-/
theorem bounded_by_envelope_of_uniform_bound {α : Type*} {ι : Type*}
    {global : α → α → ℕ} {local_ : ι → α → α → ℕ} {S : Finset ι}
    (h : IsBoundedByMaxEnvelope global local_ S)
    (D : ℕ) (hD : ∀ i ∈ S, ∀ F G, local_ i F G ≤ D) :
    ∀ F G, global F G ≤ D := by
  intro F G
  have h_le_sup : global F G ≤ S.sup (fun i => local_ i F G) := by
    exact h F G;
  exact h_le_sup.trans ( Finset.sup_le fun i hi => hD i hi F G )

/-
A max-envelope over a singleton set equals the single local functional.
-/
theorem isMaxEnvelope_singleton {α : Type*} {ι : Type*} [DecidableEq ι]
    {global : α → α → ℕ} {local_ : ι → α → α → ℕ} {i : ι}
    (h : ∀ F G, global F G = local_ i F G) :
    IsMaxEnvelope global local_ {i} := by
  exact fun F G => by simp +decide [ h ] ;

/-
A `IsBoundedByMaxEnvelope` property is monotone: enlarging S preserves it.
-/
theorem isBoundedByMaxEnvelope_mono {α : Type*} {ι : Type*}
    {global : α → α → ℕ} {local_ : ι → α → α → ℕ} {S T : Finset ι}
    (h : IsBoundedByMaxEnvelope global local_ S) (hST : S ⊆ T) :
    IsBoundedByMaxEnvelope global local_ T := by
  exact fun F G ↦ le_trans ( h F G ) ( Finset.sup_mono hST )

/-! ## Part 8: Cross-Domain — Hausdorff Distance and Max-Plus Geometry

The max-envelope principle connects to tropical/max-plus geometry: the operation
of taking the maximum over finitely many local shift functions is the fundamental
operation of max-plus algebra. This section develops the metric-geometric
consequences.
-/

/-- **Hausdorff monotonicity**: If A ⊆ A' and B ⊆ B', and A', B' are δ-close,
then any element of A has a δ-close partner in B'. -/
theorem NatSetDeltaClose'_subset_left {A A' B : Set ℕ} {δ : ℕ}
    (h : NatSetDeltaClose' A' B δ) (hA : A ⊆ A') :
    ∀ a ∈ A, ∃ b ∈ B, natDist' a b ≤ δ :=
  fun a ha => h.1 a (hA ha)

/-- **NatSetDeltaClose' for subsets**: If A is a subset of A' and both are
δ-close to their respective partners, the distance is controlled. -/
theorem NatSetDeltaClose'_refl (A : Set ℕ) : NatSetDeltaClose' A A 0 :=
  ⟨fun a ha => ⟨a, ha, by simp [natDist']⟩, fun a ha => ⟨a, ha, by simp [natDist']⟩⟩

/-! ## Axiom Checks -/

#print axioms natDist'_inf'_le_sup'_natDist'
#print axioms hausdorff_singleton_dist
#print axioms NatSetDeltaClose'_subsingleton_nonempty
#print axioms NatSetDeltaClose'_empty_left
#print axioms globalBirth_le_primeBirth'
#print axioms birth_sets_agree_at_determining_prime'
#print axioms global_shift_eq_prime_shift_of_single_determining_prime'
#print axioms finite_prime_envelope_suffices'
#print axioms bounded_by_envelope_of_uniform_bound
#print axioms isMaxEnvelope_singleton
#print axioms isBoundedByMaxEnvelope_mono