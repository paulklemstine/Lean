/-
# The master scheme: blocked random hashing + random checksum

Part of the research thread *Compression Beyond the Pigeonhole Bound*
(Phase B, Question 2: can random number generators help?).

This file assembles the previous three ingredients into one scheme and proves a
*general* checksum theorem that does not care how the inner decoder works.

* `AlmostLossless.general_checksum_bound` — **universal error-detection
  theorem**: for *any* inner decoder `propose : Ω → α → Option α` whatsoever
  (deterministic, randomised, blocked, list-decoding, …), appending an
  independent random checksum `C : α → Fin K` makes the probability of a silent
  corruption at most `1/K`, uniformly over all source strings.  The proof is a
  fibrewise (conditional-independence) count: once the inner randomness `ω` is
  fixed, the proposed candidate is determined, so the checksum has a single
  chance in `K` of confirming a wrong candidate.

* The composite scheme `AlmostLossless.blockChkDecode` then satisfies, for a
  typical set `T^b` of size `|T|^b`:
  - exact decoding cost `b·|T| + 1` (`blockChkDecode_cost`),
  - deterministic soundness (`blockChkDecode_never_wrong`),
  - success probability `≥ 1 - ε` for `M ≥ b(|T|-1)/ε`
    (`blockChkDecode_success_prob_ge`),
  - silent-corruption probability `≤ 1/K` for *every* source string, typical or
    not (`blockChk_silent_prob_le`).
-/
import Geometry.AlmostLosslessBlock
import Geometry.AlmostLosslessChecksum

namespace AlmostLossless

open Finset

/-! ## 1. A universal error-detection theorem -/

section General

variable {α : Type*} [Fintype α] [DecidableEq α]
variable {Ω : Type*} [Fintype Ω] [DecidableEq Ω] {K : ℕ}

/-- Output of an arbitrary inner decoder followed by a checksum test. -/
def chkOutput (o : Option α) (C : α → Fin K) (x : α) : Option α :=
  o.bind (fun y => if C y = C x then some y else none)

/-- The pairs (inner randomness, checksum) that silently corrupt `x`. -/
def silentPairs (propose : Ω → α → Option α) (x : α) (K : ℕ) : Finset (Ω × (α → Fin K)) :=
  univ.filter (fun p => IsSilent (chkOutput (propose p.1 x) p.2 x) x)

/-- The checksum slice above a fixed inner randomness. -/
def silentPairSlice (propose : Ω → α → Option α) (x : α) (w : Ω) (K : ℕ) :
    Finset (α → Fin K) :=
  univ.filter (fun C => IsSilent (chkOutput (propose w x) C x) x)

omit [Fintype Ω] [DecidableEq Ω] in
/-- Fibrewise bound: given the inner randomness, a silent corruption forces the
checksum to collide on one prescribed pair. -/
theorem card_silentPairSlice_mul_le (propose : Ω → α → Option α) (x : α) (w : Ω) :
    K * (silentPairSlice propose x w K).card ≤ K ^ Fintype.card α := by
  classical
  rcases hd : propose w x with _ | y₀
  · have hempty : silentPairSlice propose x w K = ∅ := by
      apply Finset.eq_empty_of_forall_notMem
      intro C hC
      simp only [silentPairSlice, mem_filter, mem_univ, true_and, IsSilent, chkOutput,
        hd] at hC
      exact absurd hC.1 (by simp)
    rw [hempty]; simp
  · by_cases hy₀ : y₀ = x
    · have hempty : silentPairSlice propose x w K = ∅ := by
        apply Finset.eq_empty_of_forall_notMem
        intro C hC
        simp only [silentPairSlice, mem_filter, mem_univ, true_and, IsSilent, chkOutput,
          hd, Option.bind_some, hy₀] at hC
        simp at hC
      rw [hempty]; simp
    · have hsub : silentPairSlice propose x w K ⊆ collisionEvent K y₀ x := by
        intro C hC
        simp only [silentPairSlice, mem_filter, mem_univ, true_and, IsSilent, chkOutput,
          hd, Option.bind_some] at hC
        by_cases hc : C y₀ = C x
        · simp only [collisionEvent, mem_filter, mem_univ, true_and]
          exact hc
        · rw [if_neg hc] at hC
          exact absurd hC.1 (by simp)
      calc K * (silentPairSlice propose x w K).card
          ≤ K * (collisionEvent K y₀ x).card :=
            Nat.mul_le_mul_left _ (Finset.card_le_card hsub)
        _ = K ^ Fintype.card α := card_collisionEvent_mul hy₀

/-- **Universal error-detection theorem.**  Whatever the inner (possibly
randomised) decoder is, an independent random checksum of size `K` reduces the
probability of a silent corruption to at most `1/K`, for *every* source string,
typical or atypical.  No assumption on `propose` is used. -/
theorem general_checksum_bound (propose : Ω → α → Option α) (x : α) :
    K * (silentPairs propose x K).card ≤ Fintype.card Ω * K ^ Fintype.card α := by
  classical
  have hsub : silentPairs propose x K ⊆
      (univ : Finset Ω).biUnion (fun w => {w} ×ˢ silentPairSlice propose x w K) := by
    intro p hp
    simp only [silentPairs, mem_filter, mem_univ, true_and] at hp
    refine mem_biUnion.2 ⟨p.1, mem_univ _, ?_⟩
    rw [mem_product]
    exact ⟨by simp, by simpa [silentPairSlice] using hp⟩
  have hcard : (silentPairs propose x K).card
      ≤ ∑ w : Ω, (silentPairSlice propose x w K).card := by
    refine le_trans (Finset.card_le_card hsub) (le_trans Finset.card_biUnion_le ?_)
    refine Finset.sum_le_sum (fun w _ => ?_)
    rw [Finset.card_product, Finset.card_singleton, one_mul]
  calc K * (silentPairs propose x K).card
      ≤ K * ∑ w : Ω, (silentPairSlice propose x w K).card := Nat.mul_le_mul_left _ hcard
    _ = ∑ w : Ω, K * (silentPairSlice propose x w K).card := by rw [Finset.mul_sum]
    _ ≤ ∑ _w : Ω, K ^ Fintype.card α :=
        Finset.sum_le_sum (fun w _ => card_silentPairSlice_mul_le propose x w)
    _ = Fintype.card Ω * K ^ Fintype.card α := by
        rw [Finset.sum_const, smul_eq_mul, Finset.card_univ]

/-- Real-valued form of the universal error-detection theorem. -/
theorem general_checksum_prob_le (propose : Ω → α → Option α) (x : α)
    (hK : 0 < K) (hΩ : 0 < Fintype.card Ω) :
    ((silentPairs propose x K).card : ℝ) /
      ((Fintype.card Ω : ℝ) * (K : ℝ) ^ Fintype.card α) ≤ 1 / K := by
  have hKpos : (0 : ℝ) < K := by exact_mod_cast hK
  have hΩpos : (0 : ℝ) < Fintype.card Ω := by exact_mod_cast hΩ
  have hden : (0 : ℝ) < (Fintype.card Ω : ℝ) * (K : ℝ) ^ Fintype.card α := by positivity
  have h := general_checksum_bound (K := K) propose x
  have h' : (K : ℝ) * ((silentPairs propose x K).card : ℝ)
      ≤ (Fintype.card Ω : ℝ) * (K : ℝ) ^ Fintype.card α := by exact_mod_cast h
  rw [div_le_div_iff₀ hden hKpos]
  nlinarith [h']

end General

/-! ## 2. The composite scheme: blocks + checksum -/

variable {β : Type*} [Fintype β] [DecidableEq β] {b M K : ℕ}

/-- Composite encoder: one codeword per block, plus a global checksum. -/
def blockChkEncode (H : Fin b × β → Fin M) (C : (Fin b → β) → Fin K) (x : Fin b → β) :
    (Fin b → Fin M) × Fin K :=
  (blockEncode H x, C x)

/-- Composite decoder: blockwise scanning decode, then the global checksum test. -/
def blockChkDecode (LT : List β) (H : Fin b × β → Fin M) (C : (Fin b → β) → Fin K)
    (p : (Fin b → Fin M) × Fin K) : Option (Fin b → β) × ℕ :=
  ((blockDecode LT H p.1).1.bind (fun z => if C z = p.2 then some z else none),
   (blockDecode LT H p.1).2 + 1)

omit [Fintype β] [DecidableEq β] in
/-- **Exact complexity of the composite scheme**: `b |T| + 1` comparisons. -/
theorem blockChkDecode_cost (LT : List β) (H : Fin b × β → Fin M)
    (C : (Fin b → β) → Fin K) (p : (Fin b → Fin M) × Fin K) :
    (blockChkDecode LT H C p).2 = b * LT.length + 1 := by
  simp [blockChkDecode, blockDecode_cost]

omit [Fintype β] [DecidableEq β] in
/-- The composite decoder only ever outputs what the blocked decoder proposed. -/
theorem blockChkDecode_output {LT : List β} {H : Fin b × β → Fin M}
    {C : (Fin b → β) → Fin K} {p : (Fin b → Fin M) × Fin K} {z : Fin b → β}
    (h : (blockChkDecode LT H C p).1 = some z) : (blockDecode LT H p.1).1 = some z := by
  simp only [blockChkDecode, Option.bind_eq_some_iff] at h
  obtain ⟨w, hw, hwz⟩ := h
  by_cases hc : C w = p.2
  · rw [if_pos hc] at hwz
    rw [hw, hwz]
  · rw [if_neg hc] at hwz
    exact absurd hwz (by simp)

omit [Fintype β] [DecidableEq β] in
/-- **No silent corruption for typical strings**, deterministically. -/
theorem blockChkDecode_never_wrong {LT : List β} {H : Fin b × β → Fin M}
    {C : (Fin b → β) → Fin K} {x z : Fin b → β} (hx : ∀ i, x i ∈ LT)
    (h : (blockChkDecode LT H C (blockChkEncode H C x)).1 = some z) : z = x :=
  blockDecode_never_wrong hx (blockChkDecode_output h)

/-- Off the blocked failure event the composite decoder still succeeds: the
checksum of the transmitted string always matches. -/
theorem blockChkDecode_success {T : Finset β} {LT : List β} {x : Fin b → β}
    {H : Fin b × β → Fin M} {C : (Fin b → β) → Fin K} (hnd : LT.Nodup)
    (hmem : ∀ y, y ∈ LT ↔ y ∈ T) (hx : ∀ i, x i ∈ T) (hH : H ∉ blockFail T x M) :
    blockChkDecode LT H C (blockChkEncode H C x) = (some x, b * LT.length + 1) := by
  have hb := blockDecode_success hnd hmem hx hH
  refine Prod.ext ?_ (blockChkDecode_cost LT H C _)
  simp [blockChkDecode, blockChkEncode, hb]

/-- The set of composite codebooks (hash, checksum) that recover `x`. -/
def blockChkGood (LT : List β) (x : Fin b → β) (M K : ℕ) :
    Finset ((Fin b × β → Fin M) × ((Fin b → β) → Fin K)) :=
  univ.filter (fun p => (blockChkDecode LT p.1 p.2 (blockChkEncode p.1 p.2 x)).1 = some x)

/-- Adding the checksum does not cost any success probability: the good set of the
composite scheme contains a full product slab over the good hash codebooks. -/
theorem card_blockChkGood_ge (LT : List β) (x : Fin b → β) :
    (blockGood LT x M).card * K ^ Fintype.card (Fin b → β)
      ≤ (blockChkGood LT x M K).card := by
  classical
  have hsub2 : (blockGood LT x M) ×ˢ (univ : Finset ((Fin b → β) → Fin K))
      ⊆ blockChkGood LT x M K := by
    intro p hp
    rw [mem_product] at hp
    have hH : (blockDecode LT p.1 (blockEncode p.1 x)).1 = some x := by
      simpa [blockGood] using hp.1
    simp [blockChkGood, blockChkDecode, blockChkEncode, hH]
  have hcard2 := Finset.card_le_card hsub2
  rwa [Finset.card_product, Finset.card_univ, card_codebooks] at hcard2

omit [Fintype β] [DecidableEq β] in
/-- The composite decoder is exactly "inner blocked decoder, then checksum test",
so the universal error-detection theorem applies to it verbatim. -/
theorem blockChkDecode_eq_chkOutput (LT : List β) (H : Fin b × β → Fin M)
    (C : (Fin b → β) → Fin K) (x : Fin b → β) :
    (blockChkDecode LT H C (blockChkEncode H C x)).1
      = chkOutput (blockDecode LT H (blockEncode H x)).1 C x := rfl

/-- **Almost-lossless guarantee for the composite scheme**: with
`M ≥ b(|T|-1)/ε`, a random codebook pair recovers a fixed typical string with
probability at least `1 - ε`, at a decoding cost of exactly `b|T| + 1`. -/
theorem blockChkDecode_success_prob_ge {T : Finset β} {LT : List β} {x : Fin b → β}
    (hnd : LT.Nodup) (hmem : ∀ y, y ∈ LT ↔ y ∈ T) (hx : ∀ i, x i ∈ T)
    (hM : 0 < M) (hK : 0 < K) {ε : ℝ} (hε : 0 < ε)
    (hMe : (b : ℝ) * ((T.card : ℝ) - 1) / ε ≤ M) (hT : 0 < T.card) :
    1 - ε ≤ ((blockChkGood LT x M K).card : ℝ) /
      ((M : ℝ) ^ (b * Fintype.card β) * (K : ℝ) ^ Fintype.card (Fin b → β)) := by
  have hMpos : (0 : ℝ) < M := by exact_mod_cast hM
  have hKpos : (0 : ℝ) < K := by exact_mod_cast hK
  have hpow : (0 : ℝ) < (M : ℝ) ^ (b * Fintype.card β) := by positivity
  have hpowK : (0 : ℝ) < (K : ℝ) ^ Fintype.card (Fin b → β) := by positivity
  have hbase := blockDecode_success_prob_ge (M := M) hnd hmem hx hM hε hMe hT
  have hprod : ((blockGood LT x M).card : ℝ) * (K : ℝ) ^ Fintype.card (Fin b → β)
      ≤ ((blockChkGood LT x M K).card : ℝ) := by
    have h := card_blockChkGood_ge (M := M) (K := K) LT x
    exact_mod_cast h
  rw [le_div_iff₀ (by positivity)]
  rw [le_div_iff₀ hpow] at hbase
  nlinarith [hbase, hprod, hpowK, hpow]

/-- **No silent corruption for the composite scheme**, uniformly over *all* source
strings: an instance of the universal error-detection theorem with the blocked
decoder as inner decoder. -/
theorem blockChk_silent_prob_le (LT : List β) (x : Fin b → β) :
    K * (silentPairs
        (fun (H : Fin b × β → Fin M) (z : Fin b → β) =>
          (blockDecode LT H (blockEncode H z)).1) x K).card
      ≤ Fintype.card (Fin b × β → Fin M) * K ^ Fintype.card (Fin b → β) :=
  general_checksum_bound _ x

end AlmostLossless