/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression III: Beating the Exponential Decoder

## Bridge: Product measures (probability) ↔ Verified algorithm cost (computation)

The naive random-coding decoder of `AlmostLosslessRandomCoding` scans the whole
codebook.  On a block source `β^b` with a typical set `T^b` the codebook has
`|T|^b` entries, so decoding is *exponential in the block length*.

This file removes that obstacle.  We decode **coordinatewise**: each of the `b`
blocks gets its own unique-match scan over the size-`|T|` codebook, and the
answers are assembled.  The results:

* `powDist_marginal` — exact marginalization for the `b`-fold product source;
* `setMass_powDist_exists_le` — a union bound over blocks for the product source;
* `blockDec_eq_some_iff` — the block decoder is *exactly* the coordinatewise
  decoder, so it never corrupts silently on the product codebook;
* `blockScheme_failure_bound` — failure probability `≤ b · (per-block failure)`;
* `blockScanCost_eq_sum` / `blockScanCost_const` — cost is exactly `b·|T|`
  hash evaluations, versus `|T|^b` for the naive scan
  (`naive_codebook_card`), and `linear_lt_pow` shows the gap is genuine.

## Impact: polynomial_time_random_coding, certified_decoder_cost
-/

import Mathlib
import Bridges.AlmostLosslessRandomCoding

open Finset BigOperators NonArchInfoTheory

namespace AlmostLossless

/-! ## Section 1: The `b`-fold product source -/

section Product

variable {β : Type*} [Fintype β] [DecidableEq β]

/-- The `b`-fold i.i.d. product of a finite source. -/
noncomputable def powDist (μ : FinProbDist β) (b : ℕ) : FinProbDist (Fin b → β) where
  mass x := ∏ i, μ.mass (x i)
  mass_nonneg x := Finset.prod_nonneg fun i _ => μ.mass_nonneg (x i)
  mass_sum_one := by
    have h := Finset.prod_univ_sum (fun _ : Fin b => (Finset.univ : Finset β))
      (fun (_ : Fin b) (a : β) => μ.mass a)
    simp only [Fintype.piFinset_univ, μ.mass_sum_one, Finset.prod_const_one] at h
    exact h.symm

/-- **Exact marginalization.**  The mass of the event "block `j` lands in `B`"
under the product source is exactly the mass of `B` under the one-block
source. -/
theorem powDist_marginal (μ : FinProbDist β) (b : ℕ) (j : Fin b) (B : Finset β) :
    setMass (powDist μ b) (Finset.univ.filter (fun x : Fin b → β => x j ∈ B))
      = setMass μ B := by
  classical
  have key : ∀ x : Fin b → β,
      (if x j ∈ B then ∏ i, μ.mass (x i) else 0)
        = ∏ i, (if i = j then (if x i ∈ B then μ.mass (x i) else 0) else μ.mass (x i)) := by
    intro x
    have hR : ∏ i, (if i = j then (if x i ∈ B then μ.mass (x i) else 0) else μ.mass (x i))
        = (∏ i ∈ Finset.univ.erase j, μ.mass (x i))
            * (if x j ∈ B then μ.mass (x j) else 0) := by
      rw [← Finset.prod_erase_mul _ _ (Finset.mem_univ j), if_pos rfl]
      congr 1
      exact Finset.prod_congr rfl fun i hi => by
        rw [if_neg (Finset.mem_erase.mp hi).1]
    have hL : ∏ i, μ.mass (x i)
        = (∏ i ∈ Finset.univ.erase j, μ.mass (x i)) * μ.mass (x j) :=
      (Finset.prod_erase_mul _ _ (Finset.mem_univ j)).symm
    rw [hR, hL]
    by_cases hx : x j ∈ B
    · rw [if_pos hx, if_pos hx]
    · rw [if_neg hx, if_neg hx, mul_zero]
  unfold setMass powDist
  simp only []
  rw [Finset.sum_filter]
  simp_rw [key]
  have h := Finset.prod_univ_sum (fun _ : Fin b => (Finset.univ : Finset β))
    (fun (i : Fin b) (a : β) => if i = j then (if a ∈ B then μ.mass a else 0) else μ.mass a)
  simp only [Fintype.piFinset_univ] at h
  have hone : ∏ i ∈ Finset.univ.erase j,
      (∑ a : β, if i = j then (if a ∈ B then μ.mass a else 0) else μ.mass a) = 1 := by
    refine Finset.prod_eq_one fun i hi => ?_
    simp only [if_neg (Finset.mem_erase.mp hi).1]
    exact μ.mass_sum_one
  rw [← h, ← Finset.prod_erase_mul _ _ (Finset.mem_univ j), hone, one_mul]
  simp

/-- Union bound over the `b` blocks of a product source. -/
theorem powDist_union_bound (μ : FinProbDist β) (b : ℕ) (Bs : Fin b → Finset β) :
    setMass (powDist μ b) (Finset.univ.filter (fun x : Fin b → β => ∃ j, x j ∈ Bs j))
      ≤ ∑ j, setMass μ (Bs j) := by
  classical
  have hsub : Finset.univ.filter (fun x : Fin b → β => ∃ j, x j ∈ Bs j)
      ⊆ Finset.univ.biUnion
          (fun j => Finset.univ.filter (fun x : Fin b → β => x j ∈ Bs j)) := by
    intro x hx
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx
    obtain ⟨j, hj⟩ := hx
    exact Finset.mem_biUnion.mpr ⟨j, Finset.mem_univ _, by simp [hj]⟩
  refine le_trans (setMass_mono _ hsub) ?_
  refine le_trans (setMass_biUnion_le _ _ _) (le_of_eq ?_)
  exact Finset.sum_congr rfl fun j _ => powDist_marginal μ b j (Bs j)

end Product

/-! ## Section 2: The coordinatewise (block) decoder -/

section Block

variable {β : Type*} [Fintype β] [DecidableEq β] {b m : ℕ}

/-- Encode each block independently. -/
def blockEnc (h : Fin b → β → Fin m) : (Fin b → β) → (Fin b → Fin m) :=
  fun x j => h j (x j)

/-- Decode each block independently; abstain unless *every* block decodes. -/
def blockDec (l : Fin b → List β) (h : Fin b → β → Fin m) (c : Fin b → Fin m) :
    Option (Fin b → β) :=
  if hall : ∀ j, (decodeList (h j) (l j) (c j)).isSome then
    some (fun j => (decodeList (h j) (l j) (c j)).get (hall j))
  else none

/-- The block compression scheme. -/
def blockScheme (l : Fin b → List β) (h : Fin b → β → Fin m) :
    Scheme (Fin b → β) (Fin b → Fin m) where
  enc := blockEnc h
  dec := blockDec l h

omit [Fintype β] [DecidableEq β] in
/-- The block decoder is *exactly* the coordinatewise decoder. -/
theorem blockDec_eq_some_iff {l : Fin b → List β} {h : Fin b → β → Fin m}
    {c : Fin b → Fin m} {x : Fin b → β} :
    blockDec l h c = some x ↔ ∀ j, decodeList (h j) (l j) (c j) = some (x j) := by
  unfold blockDec
  constructor
  · intro hc
    by_cases hall : ∀ j, (decodeList (h j) (l j) (c j)).isSome
    · rw [dif_pos hall] at hc
      have hx := Option.some_inj.mp hc
      intro j
      have hj := congrFun hx j
      rw [← hj]
      exact (Option.some_get (hall j)).symm
    · rw [dif_neg hall] at hc; exact absurd hc (by simp)
  · intro hx
    have hall : ∀ j, (decodeList (h j) (l j) (c j)).isSome := by
      intro j; rw [hx j]; rfl
    rw [dif_pos hall]
    congr 1
    funext j
    exact Option.get_of_mem (hall j) (by rw [Option.mem_def, hx j])

omit [Fintype β] [DecidableEq β] in
/-- Block success is exactly per-block success. -/
theorem blockScheme_succeeds_iff {l : Fin b → List β} {h : Fin b → β → Fin m}
    {x : Fin b → β} :
    (blockScheme l h).Succeeds x ↔ ∀ j, (hashScheme (l j) (h j)).Succeeds (x j) := by
  unfold Scheme.Succeeds blockScheme hashScheme blockEnc
  simpa using (blockDec_eq_some_iff (l := l) (h := h) (c := fun j => h j (x j)) (x := x))

omit [Fintype β] [DecidableEq β] in
/-- **No silent corruption in the block scheme.**  If every block of `x` lies in
its codebook, the block decoder either returns `x` or abstains. -/
theorem blockScheme_neverSilent_on_codebook {l : Fin b → List β} {h : Fin b → β → Fin m}
    {x : Fin b → β} (hx : ∀ j, x j ∈ l j) :
    ¬ (blockScheme l h).SilentError x := by
  rintro ⟨y, hy, hne⟩
  refine hne (funext fun j => ?_)
  have hj := (blockDec_eq_some_iff.mp hy) j
  exact decodeList_never_wrong_on_codebook (hx j) hj

/-! ## Section 3: Failure probability of the block scheme -/

/-- **Failure probability of the block scheme.**  It is at most the sum of the
per-block failure probabilities: the union bound over blocks, with no
exponential blow-up. -/
theorem blockScheme_failure_bound (μ : FinProbDist β) (l : Fin b → List β)
    (h : Fin b → β → Fin m) (e : ℝ)
    (hblock : ∀ j, setMass μ (Finset.univ.filter
        (fun y => ¬ (hashScheme (l j) (h j)).Succeeds y)) ≤ e) :
    setMass (powDist μ b) (Finset.univ.filter
        (fun x : Fin b → β => ¬ (blockScheme l h).Succeeds x)) ≤ b * e := by
  classical
  set Bs : Fin b → Finset β := fun j =>
    Finset.univ.filter (fun y => ¬ (hashScheme (l j) (h j)).Succeeds y) with hBs
  have hset : Finset.univ.filter (fun x : Fin b → β => ¬ (blockScheme l h).Succeeds x)
      = Finset.univ.filter (fun x : Fin b → β => ∃ j, x j ∈ Bs j) := by
    ext x
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, hBs]
    rw [blockScheme_succeeds_iff]
    push_neg
    constructor
    · rintro ⟨j, hj⟩; exact ⟨j, by simp [hj]⟩
    · rintro ⟨j, hj⟩; exact ⟨j, by simpa using hj⟩
  rw [hset]
  refine le_trans (powDist_union_bound μ b Bs) ?_
  calc ∑ j, setMass μ (Bs j) ≤ ∑ _j : Fin b, e := Finset.sum_le_sum fun j _ => hblock j
    _ = b * e := by simp [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

/-! ## Section 4: Exact decoding cost, and the exponential separation -/

/-- Total cost of block decoding: the sum of the per-block scan costs. -/
def blockScanCost (l : Fin b → List β) (h : Fin b → β → Fin m) (c : Fin b → Fin m) : ℕ :=
  ∑ j, (scanCost (h j) (c j) (l j)).2

omit [Fintype β] [DecidableEq β] in
/-- **Exact block decoding cost.** -/
theorem blockScanCost_eq_sum (l : Fin b → List β) (h : Fin b → β → Fin m)
    (c : Fin b → Fin m) : blockScanCost l h c = ∑ j, (l j).length := by
  unfold blockScanCost
  exact Finset.sum_congr rfl fun j _ => scanCost_snd _ _ _

omit [Fintype β] [DecidableEq β] in
/-- With a common codebook of size `n` in every block, decoding costs exactly
`b · n` hash evaluations. -/
theorem blockScanCost_const (lc : List β) (h : Fin b → β → Fin m) (c : Fin b → Fin m) :
    blockScanCost (fun _ => lc) h c = b * lc.length := by
  rw [blockScanCost_eq_sum]
  simp [Finset.sum_const, Finset.card_univ]

omit [Fintype β] in
/-- The *product* codebook — what a one-shot random-coding decoder must scan —
has `∏ j |l j|` entries: exponentially many in the block length. -/
theorem naive_codebook_card (l : Fin b → List β) (hnd : ∀ j, (l j).Nodup) :
    (Fintype.piFinset (fun j => (l j).toFinset)).card = ∏ j, (l j).length := by
  rw [Fintype.card_piFinset]
  exact Finset.prod_congr rfl fun j _ => List.toFinset_card_of_nodup (hnd j)

/-- **Exponential separation.**  For a codebook of size `n ≥ 2` and at least
three blocks, the coordinatewise decoder cost `b·n` is strictly smaller than the
one-shot cost `n^b` — and the ratio grows without bound. -/
theorem linear_lt_pow {n b : ℕ} (hn : 2 ≤ n) (hb : 3 ≤ b) : b * n < n ^ b := by
  induction b, hb using Nat.le_induction with
  | base =>
      have h1 : 3 * n < n ^ 3 := by nlinarith [sq_nonneg n]
      simpa using h1
  | succ b hb ih =>
      have hpow : 2 ≤ n ^ b := by
        calc 2 = 2 ^ 1 := by norm_num
          _ ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) (by omega)
          _ ≤ n ^ b := Nat.pow_le_pow_left hn b
      have hstep : n ^ b + n ≤ n ^ (b + 1) := by
        have : n ^ (b + 1) = n ^ b * n := by ring
        rw [this]
        nlinarith [hpow, hn]
      calc (b + 1) * n = b * n + n := by ring
        _ < n ^ b + n := by omega
        _ ≤ n ^ (b + 1) := hstep

omit [Fintype β] in
/-- **Main separation theorem.**  The block scheme decodes a `b`-block source in
exactly `b·|l|` hash evaluations while the one-shot codebook it replaces has
`|l|^b` entries; for `|l| ≥ 2` and `b ≥ 3` the former is strictly smaller. -/
theorem block_decoding_exponential_speedup (lc : List β) (hnd : lc.Nodup)
    (h : Fin b → β → Fin m) (c : Fin b → Fin m)
    (hn : 2 ≤ lc.length) (hb : 3 ≤ b) :
    blockScanCost (fun _ => lc) h c
        = b * lc.length
      ∧ (Fintype.piFinset (fun _ : Fin b => lc.toFinset)).card = lc.length ^ b
      ∧ b * lc.length < lc.length ^ b := by
  refine ⟨blockScanCost_const lc h c, ?_, linear_lt_pow hn hb⟩
  rw [naive_codebook_card (fun _ => lc) (fun _ => hnd)]
  simp [Finset.prod_const, Finset.card_univ]

end Block

/-! ## Section 5: The full block scheme with a universal hash family -/

section Full

variable {β : Type*} [Fintype β] [DecidableEq β] {K m : ℕ}

/-- **The Monte-Carlo block compressor.**  With a 2-universal family of `K`
hash functions into `m` codewords and a codebook list `l` capturing all but `δ`
of the one-block mass, there is a single key `k` such that the `b`-block scheme

* fails with probability at most `b·(δ + |l|/m)`,
* never corrupts a product-codebook message silently,
* decodes in exactly `b·|l|` hash evaluations — linear in the block length,
  whereas the product codebook it decodes against has `|l|^b` entries.
-/
theorem exists_block_almost_lossless_scheme (μ : FinProbDist β) {H : Fin K → β → Fin m}
    (hU : Universal2 H) (hK : 0 < K) (hm : 0 < m)
    (l : List β) (hnd : l.Nodup) (δ : ℝ) (hδ : setMass μ (l.toFinset)ᶜ ≤ δ) (b : ℕ) :
    ∃ k : Fin K,
      setMass (powDist μ b) (Finset.univ.filter
          (fun x : Fin b → β => ¬ (blockScheme (fun _ => l) (fun _ => H k)).Succeeds x))
          ≤ b * (δ + (l.length : ℝ) / m)
      ∧ (∀ x : Fin b → β, (∀ j, x j ∈ l) →
          ¬ (blockScheme (fun _ => l) (fun _ => H k)).SilentError x)
      ∧ ∀ c : Fin b → Fin m,
          blockScanCost (fun _ : Fin b => l) (fun _ => H k) c = b * l.length := by
  classical
  obtain ⟨k, hfail, _, _⟩ := exists_almost_lossless_scheme μ hU hK hm l hnd δ hδ
  refine ⟨k, ?_, fun x hx => blockScheme_neverSilent_on_codebook hx,
    fun c => blockScanCost_const l _ c⟩
  exact blockScheme_failure_bound μ (fun _ => l) (fun _ => H k)
    (δ + (l.length : ℝ) / m) (fun _ => hfail)

end Full

end AlmostLossless