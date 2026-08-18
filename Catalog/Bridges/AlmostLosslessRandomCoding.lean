/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression II: Random Coding with a Certified Decoder

## Bridge: Universal hashing (algebra) ↔ Shannon random coding (probability)
##         ↔ Verified algorithmics (exact decoder cost)

Shannon's random-coding argument is usually stated with an *unbounded* random
codebook and an existential (non-constructive) decoder.  Here everything is
finite, explicit and cost-instrumented:

* the "random codebook" is a **2-universal hash family** `H : Fin K → α → Fin M`
  (`Universal2`), so the randomness is a single key `k ∈ Fin K`;
* the decoder `decodeList` scans an explicit codebook list `l` and answers
  `some x` **only** when the match is unique;
* the scan is instrumented (`scanCost`) so the decoding cost is *proved*, not
  estimated: exactly `l.length` hash evaluations per query.

Main results:

* `sum_collision_mass_le` — the averaging (first-moment) identity behind random
  coding, in the exact form `M · Σₖ P(collision) ≤ K · |S| · P(A)`;
* `exists_good_key` — derandomized existence of a single good key;
* `decodeList_eq_some_of_unique`, `not_silentError_of_mem` — the decoder never
  corrupts a codebook symbol silently;
* `exists_almost_lossless_scheme` — **the deliverable**: a key `k` such that the
  scheme fails with probability `≤ δ + |S|/M`, corrupts silently with
  probability `≤ |S|/M`, and costs exactly `|S|` steps per decode;
* `converse_flat_source` — the matching converse, giving a rate gap independent
  of the source size.

## Impact: almost_lossless_achievability, certified_decoder_cost
-/

import Mathlib
import Bridges.AlmostLosslessCompression

open Finset BigOperators NonArchInfoTheory

namespace AlmostLossless

/-! ## Section 1: Universal hash families and collisions -/

section Universal

variable {α : Type*} [Fintype α] [DecidableEq α] {K M : ℕ}

/-- A **2-universal** family of hash functions: for any two distinct source
symbols, at most a `1/M` fraction of the keys make them collide.  (Stated
multiplicatively to avoid division.) -/
def Universal2 (H : Fin K → α → Fin M) : Prop :=
  ∀ x y : α, x ≠ y →
    ((Finset.univ.filter (fun k => H k x = H k y)).card : ℝ) * M ≤ K

/-- The set of codebook entries other than `x` that collide with `x`. -/
def collisionSet (H : Fin K → α → Fin M) (k : Fin K) (S : Finset α) (x : α) :
    Finset α :=
  (S.erase x).filter (fun y => H k y = H k x)

/-- `x` collides with the codebook `S` under key `k`. -/
def Collides (H : Fin K → α → Fin M) (k : Fin K) (S : Finset α) (x : α) : Prop :=
  (collisionSet H k S x).Nonempty

instance (H : Fin K → α → Fin M) (k : Fin K) (S : Finset α) :
    DecidablePred (Collides H k S) := fun _ => Finset.decidableNonempty

omit [Fintype α] in
theorem collides_iff {H : Fin K → α → Fin M} {k : Fin K} {S : Finset α} {x : α} :
    Collides H k S x ↔ ∃ y ∈ S, y ≠ x ∧ H k y = H k x := by
  unfold Collides collisionSet
  constructor
  · rintro ⟨y, hy⟩
    rw [Finset.mem_filter, Finset.mem_erase] at hy
    exact ⟨y, hy.1.2, hy.1.1, hy.2⟩
  · rintro ⟨y, hyS, hne, hh⟩
    exact ⟨y, by rw [Finset.mem_filter, Finset.mem_erase]; exact ⟨⟨hne, hyS⟩, hh⟩⟩

/-- The set of keys under which `x` collides with the codebook. -/
def badKeys (H : Fin K → α → Fin M) (S : Finset α) (x : α) : Finset (Fin K) :=
  Finset.univ.filter (fun k => Collides H k S x)

omit [Fintype α] in
/-- **Union bound over the codebook.** For a 2-universal family, at most a
`|S|/M` fraction of keys make `x` collide with the codebook `S`. -/
theorem card_badKeys_mul_le {H : Fin K → α → Fin M} (hU : Universal2 H)
    (S : Finset α) (x : α) :
    ((badKeys H S x).card : ℝ) * M ≤ (K : ℝ) * S.card := by
  classical
  set T : Finset α := S.erase x with hT
  have hsub : badKeys H S x ⊆
      T.biUnion (fun y => Finset.univ.filter (fun k => H k x = H k y)) := by
    intro k hk
    simp only [badKeys, Finset.mem_filter, Finset.mem_univ, true_and] at hk
    obtain ⟨y, hyS, hne, hh⟩ := collides_iff.mp hk
    refine Finset.mem_biUnion.mpr ⟨y, ?_, ?_⟩
    · rw [hT, Finset.mem_erase]; exact ⟨hne, hyS⟩
    · simp [hh.symm]
  have hcard : (badKeys H S x).card ≤
      ∑ y ∈ T, (Finset.univ.filter (fun k => H k x = H k y)).card :=
    le_trans (Finset.card_le_card hsub) (Finset.card_biUnion_le)
  have hstep : ((badKeys H S x).card : ℝ) * M ≤
      ∑ y ∈ T, ((Finset.univ.filter (fun k => H k x = H k y)).card : ℝ) * M := by
    rw [← Finset.sum_mul]
    have : ((badKeys H S x).card : ℝ) ≤
        ∑ y ∈ T, ((Finset.univ.filter (fun k => H k x = H k y)).card : ℝ) := by
      exact_mod_cast hcard
    exact mul_le_mul_of_nonneg_right this (Nat.cast_nonneg M)
  refine hstep.trans ?_
  have hterm : ∀ y ∈ T,
      ((Finset.univ.filter (fun k => H k x = H k y)).card : ℝ) * M ≤ (K : ℝ) := by
    intro y hy
    exact hU x y (Ne.symm (Finset.mem_erase.mp hy).1)
  calc ∑ y ∈ T, ((Finset.univ.filter (fun k => H k x = H k y)).card : ℝ) * M
      ≤ ∑ _y ∈ T, (K : ℝ) := Finset.sum_le_sum hterm
    _ = (T.card : ℝ) * K := by simp [Finset.sum_const, nsmul_eq_mul]
    _ ≤ (S.card : ℝ) * K := by
        have : (T.card : ℝ) ≤ (S.card : ℝ) := by
          exact_mod_cast Finset.card_le_card (Finset.erase_subset _ _)
        exact mul_le_mul_of_nonneg_right this (Nat.cast_nonneg K)
    _ = (K : ℝ) * S.card := by ring

/-! ## Section 2: The first-moment (random coding) bound -/

/-- **Random-coding averaging bound.**  Summed over all keys, the probability
mass of symbols that collide with the codebook `S` is at most `K·|S|/M` times
the mass of the region `A` under consideration.  This is Shannon's first-moment
computation, made exact and division-free. -/
theorem sum_collision_mass_le (μ : FinProbDist α) {H : Fin K → α → Fin M}
    (hU : Universal2 H) (S A : Finset α) :
    (M : ℝ) * ∑ k : Fin K, setMass μ (A.filter (fun x => Collides H k S x))
      ≤ (K : ℝ) * S.card * setMass μ A := by
  classical
  have hinner : ∀ x : α, ∑ k : Fin K, (if Collides H k S x then μ.mass x else 0)
      = ((badKeys H S x).card : ℝ) * μ.mass x := by
    intro x
    rw [← Finset.sum_filter]
    simp [badKeys, Finset.sum_const, nsmul_eq_mul]
  have hswap : ∑ k : Fin K, setMass μ (A.filter (fun x => Collides H k S x))
      = ∑ x ∈ A, ((badKeys H S x).card : ℝ) * μ.mass x := by
    unfold setMass
    simp_rw [Finset.sum_filter]
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl fun x _ => hinner x
  rw [hswap, Finset.mul_sum]
  have hbound : ∀ x ∈ A, (M : ℝ) * (((badKeys H S x).card : ℝ) * μ.mass x)
      ≤ ((K : ℝ) * S.card) * μ.mass x := by
    intro x _
    have h1 := card_badKeys_mul_le hU S x
    have h2 : (0 : ℝ) ≤ μ.mass x := μ.mass_nonneg x
    nlinarith [h1, h2]
  calc ∑ x ∈ A, (M : ℝ) * (((badKeys H S x).card : ℝ) * μ.mass x)
      ≤ ∑ x ∈ A, ((K : ℝ) * S.card) * μ.mass x := Finset.sum_le_sum hbound
    _ = (K : ℝ) * S.card * setMass μ A := by rw [← Finset.mul_sum]; rfl

/-- **Derandomization.**  Some single key is at least as good as the average:
its collision mass is at most `|S|/M` times the mass of `A`. -/
theorem exists_good_key (μ : FinProbDist α) {H : Fin K → α → Fin M}
    (hU : Universal2 H) (hK : 0 < K) (S A : Finset α) :
    ∃ k : Fin K,
      (M : ℝ) * setMass μ (A.filter (fun x => Collides H k S x))
        ≤ (S.card : ℝ) * setMass μ A := by
  classical
  have hne : (Finset.univ : Finset (Fin K)).Nonempty := by
    have : Nonempty (Fin K) := ⟨⟨0, hK⟩⟩
    exact Finset.univ_nonempty
  have hR : ∑ _k : Fin K, ((S.card : ℝ) * setMass μ A)
      = (K : ℝ) * S.card * setMass μ A := by
    rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    ring
  have hsum : ∑ k : Fin K, ((M : ℝ) * setMass μ (A.filter (fun x => Collides H k S x)))
      ≤ ∑ _k : Fin K, ((S.card : ℝ) * setMass μ A) := by
    rw [← Finset.mul_sum, hR]
    exact sum_collision_mass_le μ hU S A
  obtain ⟨k, _, hk⟩ := Finset.exists_le_of_sum_le hne hsum
  exact ⟨k, hk⟩

end Universal

/-! ## Section 3: The cost-instrumented decoder -/

section Decoder

variable {α : Type*} {M : ℕ}

/-- A single left-to-right scan of the codebook list, returning the list of
matches together with the **exact number of hash evaluations performed**. -/
def scanCost (h : α → Fin M) (i : Fin M) : List α → List α × ℕ
  | [] => ([], 0)
  | y :: ys =>
      let p := scanCost h i ys
      (if h y = i then y :: p.1 else p.1, p.2 + 1)

/-- The scan collects exactly the matching entries. -/
theorem scanCost_fst (h : α → Fin M) (i : Fin M) (l : List α) :
    (scanCost h i l).1 = l.filter (fun y => decide (h y = i)) := by
  induction l with
  | nil => rfl
  | cons y ys ih =>
      by_cases hy : h y = i <;> simp [scanCost, hy, ih]

/-- **Exact decoding cost**: one hash evaluation per codebook entry. -/
theorem scanCost_snd (h : α → Fin M) (i : Fin M) (l : List α) :
    (scanCost h i l).2 = l.length := by
  induction l with
  | nil => rfl
  | cons y ys ih => simp [scanCost, ih]

/-- The decoder: answer `some y` **only** when the scan produced a unique match,
otherwise abstain.  Abstention is the mechanism that prevents silent
corruption of codebook symbols. -/
def decodeList (h : α → Fin M) (l : List α) (i : Fin M) : Option α :=
  match (scanCost h i l).1 with
  | [y] => some y
  | _ => none

/-- The decoder answers `some y` exactly when `y` is the unique match. -/
theorem decodeList_eq_some_iff {h : α → Fin M} {l : List α} {i : Fin M} {y : α} :
    decodeList h l i = some y ↔ l.filter (fun z => decide (h z = i)) = [y] := by
  unfold decodeList
  rw [scanCost_fst]
  generalize l.filter (fun z => decide (h z = i)) = fl
  rcases fl with _ | ⟨a, _ | ⟨b, t⟩⟩
  · simp
  · simp [eq_comm]
  · simp

/-- Any decoded symbol is a codebook entry hashing to the received codeword. -/
theorem decodeList_eq_some_imp {h : α → Fin M} {l : List α} {i : Fin M} {y : α}
    (hy : decodeList h l i = some y) : y ∈ l ∧ h y = i := by
  have hf := decodeList_eq_some_iff.mp hy
  have ha : y ∈ l.filter (fun z => decide (h z = i)) := by rw [hf]; simp
  rw [List.mem_filter] at ha
  exact ⟨ha.1, of_decide_eq_true ha.2⟩

/-- If `x` is in the (duplicate-free) codebook and nothing else in the codebook
shares its hash, the scan returns exactly `[x]`. -/
theorem filter_eq_singleton_of_unique {h : α → Fin M} {l : List α} {x : α}
    (hnd : l.Nodup) (hx : x ∈ l) (huniq : ∀ y ∈ l, h y = h x → y = x) :
    l.filter (fun z => decide (h z = h x)) = [x] := by
  induction l with
  | nil => cases hx
  | cons a t ih =>
      rw [List.nodup_cons] at hnd
      rcases List.mem_cons.mp hx with rfl | hxt
      · have hnil : t.filter (fun z => decide (h z = h x)) = [] := by
          rw [List.filter_eq_nil_iff]
          intro y hy hdec
          have := huniq y (List.mem_cons_of_mem _ hy) (of_decide_eq_true hdec)
          exact hnd.1 (this ▸ hy)
        simp [hnil]
      · have hane : h a ≠ h x := by
          intro hcon
          have := huniq a (List.mem_cons_self ..) hcon
          exact hnd.1 (this ▸ hxt)
        rw [List.filter_cons, if_neg (by simpa using hane)]
        exact ih hnd.2 hxt (fun y hy hh => huniq y (List.mem_cons_of_mem _ hy) hh)

/-- **Correct decoding.**  A collision-free codebook symbol is decoded exactly. -/
theorem decodeList_eq_some_of_unique {h : α → Fin M} {l : List α} {x : α}
    (hnd : l.Nodup) (hx : x ∈ l) (huniq : ∀ y ∈ l, h y = h x → y = x) :
    decodeList h l (h x) = some x := by
  unfold decodeList
  rw [scanCost_fst, filter_eq_singleton_of_unique hnd hx huniq]

/-- **No silent corruption on the codebook.**  Whatever the hash function, a
codebook symbol is either decoded correctly or the decoder abstains: a wrong
answer for `x ∈ l` is impossible, because `x` itself would then be a second
match. -/
theorem decodeList_never_wrong_on_codebook {h : α → Fin M} {l : List α} {x y : α}
    (hx : x ∈ l) (hy : decodeList h l (h x) = some y) : y = x := by
  have hf := decodeList_eq_some_iff.mp hy
  have hxmem : x ∈ l.filter (fun z => decide (h z = h x)) := by
    rw [List.mem_filter]; exact ⟨hx, by simp⟩
  rw [hf, List.mem_singleton] at hxmem
  exact hxmem.symm

end Decoder

/-! ## Section 4: The almost-lossless scheme and its guarantees -/

section Scheme

variable {α : Type*} [Fintype α] [DecidableEq α] {K M : ℕ}

/-- The compression scheme built from a hash function and a codebook list:
encode by hashing, decode by a unique-match scan. -/
def hashScheme (l : List α) (h : α → Fin M) : Scheme α (Fin M) where
  enc := h
  dec := decodeList h l

omit [Fintype α] in
/-- Codebook symbols that do not collide are decoded exactly. -/
theorem hashScheme_succeeds {l : List α} {h : α → Fin M} {x : α}
    (hnd : l.Nodup) (hx : x ∈ l)
    (hnc : ¬ ∃ y ∈ l.toFinset, y ≠ x ∧ h y = h x) :
    (hashScheme l h).Succeeds x := by
  refine decodeList_eq_some_of_unique hnd hx ?_
  intro y hy hh
  by_contra hne
  exact hnc ⟨y, List.mem_toFinset.mpr hy, hne, hh⟩

omit [Fintype α] in
/-- A silent error can only happen through a codebook collision. -/
theorem silentError_imp_collides {l : List α} {h : α → Fin M} {x : α}
    (hs : (hashScheme l h).SilentError x) :
    ∃ y ∈ l.toFinset, y ≠ x ∧ h y = h x := by
  obtain ⟨y, hy, hne⟩ := hs
  obtain ⟨hyl, hyh⟩ := decodeList_eq_some_imp hy
  exact ⟨y, List.mem_toFinset.mpr hyl, hne, hyh⟩

omit [Fintype α] [DecidableEq α] in
/-- Silent errors are impossible for codebook symbols — the guarantee that
failures are *never* silent on the typical set. -/
theorem hashScheme_neverSilent_on_codebook {l : List α} {h : α → Fin M} {x : α}
    (hx : x ∈ l) : ¬ (hashScheme l h).SilentError x := by
  rintro ⟨y, hy, hne⟩
  exact hne (decodeList_never_wrong_on_codebook hx hy)

/-- **Main achievability theorem (the deliverable).**

Given a 2-universal family `H` of `K` hash functions into `M` codewords and a
duplicate-free codebook list `l` whose symbol set carries all but `δ` of the
probability mass, there is an explicit key `k` such that the scheme
`hashScheme l (H k)`:

1. fails with probability at most `δ + |l|/M`;
2. corrupts silently with probability at most `|l|/M`, and never at all on the
   codebook;
3. decodes in exactly `|l|` hash evaluations per query — linear, not
   exponential, in the codebook size.
-/
theorem exists_almost_lossless_scheme (μ : FinProbDist α) {H : Fin K → α → Fin M}
    (hU : Universal2 H) (hK : 0 < K) (hM : 0 < M)
    (l : List α) (hnd : l.Nodup) (δ : ℝ) (hδ : setMass μ (l.toFinset)ᶜ ≤ δ) :
    ∃ k : Fin K,
      setMass μ (Finset.univ.filter (fun x => ¬ (hashScheme l (H k)).Succeeds x))
          ≤ δ + (l.length : ℝ) / M
      ∧ setMass μ (Finset.univ.filter (fun x => (hashScheme l (H k)).SilentError x))
          ≤ (l.length : ℝ) / M
      ∧ ∀ i : Fin M, (scanCost (H k) i l).2 = l.length := by
  classical
  obtain ⟨k, hk⟩ := exists_good_key μ hU hK l.toFinset Finset.univ
  have hMR : (0 : ℝ) < M := by exact_mod_cast hM
  have hcard : (l.toFinset.card : ℝ) = (l.length : ℝ) := by
    rw [List.toFinset_card_of_nodup hnd]
  -- the collision mass of the chosen key
  set C : Finset α := Finset.univ.filter (fun x => Collides H k l.toFinset x) with hC
  have hCbound : setMass μ C ≤ (l.length : ℝ) / M := by
    rw [le_div_iff₀ hMR]
    have h2 := hk
    rw [setMass_univ, mul_one, hcard] at h2
    linarith [h2, mul_comm (M : ℝ) (setMass μ C)]
  refine ⟨k, ?_, ?_, fun i => scanCost_snd _ _ _⟩
  · -- failure ⊆ (codebook)ᶜ ∪ collisions
    have hsub : Finset.univ.filter (fun x => ¬ (hashScheme l (H k)).Succeeds x)
        ⊆ (l.toFinset)ᶜ ∪ C := by
      intro x hx
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx
      rw [Finset.mem_union]
      by_cases hxl : x ∈ l.toFinset
      · right
        rw [hC, Finset.mem_filter]
        refine ⟨Finset.mem_univ _, ?_⟩
        rw [collides_iff]
        by_contra hnc
        exact hx (hashScheme_succeeds hnd (List.mem_toFinset.mp hxl) hnc)
      · left; exact Finset.mem_compl.mpr hxl
    calc setMass μ (Finset.univ.filter (fun x => ¬ (hashScheme l (H k)).Succeeds x))
        ≤ setMass μ ((l.toFinset)ᶜ ∪ C) := setMass_mono μ hsub
      _ ≤ setMass μ (l.toFinset)ᶜ + setMass μ C := setMass_union_le μ _ _
      _ ≤ δ + (l.length : ℝ) / M := add_le_add hδ hCbound
  · have hsub : Finset.univ.filter (fun x => (hashScheme l (H k)).SilentError x) ⊆ C := by
      intro x hx
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx
      rw [hC, Finset.mem_filter]
      exact ⟨Finset.mem_univ _, collides_iff.mpr (silentError_imp_collides hx)⟩
    exact le_trans (setMass_mono μ hsub) hCbound

/-- **Success-probability form.**  The scheme of `exists_almost_lossless_scheme`
succeeds with probability at least `1 - δ - |l|/M`; taking `M ≥ |l|/(ε-δ)` gives
success probability `≥ 1 - ε` at rate `log M ≈ log|l| + log(1/(ε-δ))`. -/
theorem exists_scheme_successProb (μ : FinProbDist α) {H : Fin K → α → Fin M}
    (hU : Universal2 H) (hK : 0 < K) (hM : 0 < M)
    (l : List α) (hnd : l.Nodup) (δ : ℝ) (hδ : setMass μ (l.toFinset)ᶜ ≤ δ) :
    ∃ k : Fin K, 1 - (δ + (l.length : ℝ) / M) ≤ successProb μ (hashScheme l (H k)) := by
  classical
  obtain ⟨k, hfail, _, _⟩ := exists_almost_lossless_scheme μ hU hK hM l hnd δ hδ
  refine ⟨k, ?_⟩
  have hcompl : Finset.univ.filter (fun x => ¬ (hashScheme l (H k)).Succeeds x)
      = (successSet (hashScheme l (H k)))ᶜ := by
    ext x
    simp [successSet, Scheme.Succeeds]
  rw [hcompl] at hfail
  have := setMass_add_compl μ (successSet (hashScheme l (H k)))
  unfold successProb
  linarith

end Scheme

/-! ## Section 5: The matching converse for a flat (typical) source -/

section Converse

variable {α : Type*} [Fintype α] [Nonempty α] [DecidableEq α] {Code : Type*} [Fintype Code]

/-- **Converse for a flat source.**  If the source is `c`-flat on a set `S`
(i.e. `p_max · |S| ≤ c`, the defining property of a typical set), then *every*
scheme with success probability `≥ 1-ε` needs at least `(1-ε)|S|/c` codewords.

Combined with `exists_almost_lossless_scheme` (which uses `M ≈ |S|/(ε-δ)`
codewords) this pins the optimal code size to within the factor
`c/((ε-δ)(1-ε))`, which does **not** grow with the source. -/
theorem converse_flat_source (μ : FinProbDist α) (sch : Scheme α Code)
    (S : Finset α) (c ε : ℝ) (hc : 0 < c) (hflat : maxMass μ * S.card ≤ c)
    (h : 1 - ε ≤ successProb μ sch) (hε : ε < 1) :
    (1 - ε) * S.card / c ≤ (Fintype.card Code : ℝ) := by
  have hp := maxMass_pos μ
  have h1 : (0 : ℝ) < 1 - ε := by linarith
  have hmain := card_code_ge_of_success μ sch ε h
  have hstep : (1 - ε) * S.card / c ≤ (1 - ε) / maxMass μ := by
    rw [div_le_div_iff₀ hc hp]
    nlinarith [hflat, h1]
  linarith

end Converse

/-! ## Section 6: The two-sided rate theorem -/

section Sandwich

variable {α : Type*} [Fintype α] [Nonempty α] [DecidableEq α] {K M : ℕ}

/-- **Two-sided (sandwich) rate theorem.**  For a source that is `c`-flat on the
codebook `l` (the typical-set condition `p_max·|l| ≤ c`):

* *achievability* — as soon as `|l|/M ≤ ε - δ`, some key of the universal family
  gives success probability `≥ 1 - ε` using `M` codewords;
* *converse* — **every** scheme, of whatever design, with success probability
  `≥ 1 - ε` needs at least `(1-ε)|l|/c` codewords.

The two bounds differ by the factor `c/((ε-δ)(1-ε))`, which depends only on the
accuracy parameters and the flatness constant — not on the size of the source. -/
theorem almost_lossless_rate_sandwich (μ : FinProbDist α) {H : Fin K → α → Fin M}
    (hU : Universal2 H) (hK : 0 < K) (hM : 0 < M)
    (l : List α) (hnd : l.Nodup) (δ ε c : ℝ) (hc : 0 < c) (hε : ε < 1)
    (hδ : setMass μ (l.toFinset)ᶜ ≤ δ)
    (hflat : maxMass μ * l.length ≤ c)
    (hrate : (l.length : ℝ) / M ≤ ε - δ) :
    (∃ k : Fin K, 1 - ε ≤ successProb μ (hashScheme l (H k)))
    ∧ (∀ (M' : ℕ) (sch : Scheme α (Fin M')),
        1 - ε ≤ successProb μ sch → (1 - ε) * l.length / c ≤ (M' : ℝ)) := by
  constructor
  · obtain ⟨k, hk⟩ := exists_scheme_successProb μ hU hK hM l hnd δ hδ
    exact ⟨k, by linarith⟩
  · intro M' sch hsucc
    have hcard : (l.toFinset.card : ℝ) = (l.length : ℝ) := by
      rw [List.toFinset_card_of_nodup hnd]
    have hflat' : maxMass μ * l.toFinset.card ≤ c := by rw [hcard]; exact hflat
    have := converse_flat_source μ sch l.toFinset c ε hc hflat' hsucc hε
    rwa [hcard, Fintype.card_fin] at this

end Sandwich

end AlmostLossless