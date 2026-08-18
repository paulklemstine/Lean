/-
# Closing the silent-corruption loophole: a random checksum layer

Part of the research thread *Compression Beyond the Pigeonhole Bound*
(Phase B, Question 2: can random number generators help?).

`Geometry.AlmostLosslessDecoder` proves that the scanning decoder never returns a
wrong string *provided the transmitted string is typical*.  Adversarial review
exposes the remaining loophole: an **atypical** source string `x ∉ S` can be
silently decoded to some typical `y ≠ x`, because the decoder has no way of
knowing that `x` was atypical.

Here we close that loophole with an independent random checksum
`C : α → Fin K` appended to the codeword (`log₂ K` extra bits).  The key point is
a *conditional independence* (fibrewise counting) argument: for a fixed hash
codebook `H` the candidate returned by the hash decoder is already determined,
so the checksum has only one chance in `K` of confirming it.

* `AlmostLossless.decodeChk_cost` — exact cost `|L| + 1` comparisons.
* `AlmostLossless.decodeChk_never_wrong` — typical strings are still never
  silently corrupted (deterministically).
* `AlmostLossless.silent_corruption_prob_le` — **for every source string, typical
  or not**, the probability of a silent corruption is at most `1 / K`.
-/
import Geometry.AlmostLosslessDecoder

namespace AlmostLossless

open Finset

variable {α : Type*} [DecidableEq α] {M K : ℕ}

/-! ## 1. The checksummed scheme -/

/-- Encoder with checksum: hash plus an independent random checksum. -/
def encChk (H : α → Fin M) (C : α → Fin K) (x : α) : Fin M × Fin K := (H x, C x)

/-- Decoder with checksum: run the scanning decoder, then accept its candidate
only if the checksum matches.  The cost is one comparison more than the plain
decoder. -/
def decodeChk (L : List α) (H : α → Fin M) (C : α → Fin K) (p : Fin M × Fin K) :
    Option α × ℕ :=
  ((decode L H p.1).1.bind (fun y => if C y = p.2 then some y else none),
   (decode L H p.1).2 + 1)

omit [DecidableEq α] in
/-- **Exact decoding complexity with checksum**: `|L| + 1` comparisons. -/
theorem decodeChk_cost (L : List α) (H : α → Fin M) (C : α → Fin K)
    (p : Fin M × Fin K) : (decodeChk L H C p).2 = L.length + 1 := by
  simp [decodeChk, decode_cost]

omit [DecidableEq α] in
/-- The checksummed decoder can only output what the hash decoder proposed. -/
theorem decodeChk_output {L : List α} {H : α → Fin M} {C : α → Fin K}
    {p : Fin M × Fin K} {y : α} (h : (decodeChk L H C p).1 = some y) :
    (decode L H p.1).1 = some y := by
  simp only [decodeChk, Option.bind_eq_some_iff] at h
  obtain ⟨z, hz, hzy⟩ := h
  by_cases hc : C z = p.2
  · rw [if_pos hc] at hzy
    rw [hz, hzy]
  · rw [if_neg hc] at hzy
    exact absurd hzy (by simp)

omit [DecidableEq α] in
/-- Typical strings are still never silently corrupted. -/
theorem decodeChk_never_wrong {L : List α} {H : α → Fin M} {C : α → Fin K} {x y : α}
    (hx : x ∈ L) (h : (decodeChk L H C (encChk H C x)).1 = some y) : y = x :=
  decode_never_wrong hx (decodeChk_output h)

/-! ## 2. The silent-corruption probability, uniformly over all sources -/

variable [Fintype α]

/-- A decoding outcome is a *silent corruption* for `x` when the decoder confidently
outputs a string different from `x`. -/
def IsSilent (o : Option α) (x : α) : Prop := o.isSome ∧ o ≠ some x

instance (o : Option α) (x : α) : Decidable (IsSilent o x) := by
  unfold IsSilent; infer_instance

/-- The set of (hash, checksum) codebook pairs that silently corrupt `x`. -/
def silentSet (L : List α) (x : α) (M K : ℕ) :
    Finset ((α → Fin M) × (α → Fin K)) :=
  univ.filter (fun p => IsSilent (decodeChk L p.1 p.2 (encChk p.1 p.2 x)).1 x)

/-- The checksum slice of the silent set above a fixed hash codebook. -/
def silentSlice (L : List α) (x : α) (H : α → Fin M) (K : ℕ) : Finset (α → Fin K) :=
  univ.filter (fun C => IsSilent (decodeChk L H C (encChk H C x)).1 x)

/-- **Fibrewise bound.**  Once the hash codebook `H` is fixed, the candidate the
hash decoder proposes is determined; a silent corruption then requires the
independent checksum to collide on that single pair, an event of probability
`1/K`. -/
theorem card_silentSlice_mul_le (L : List α) (x : α) (H : α → Fin M) :
    K * (silentSlice L x H K).card ≤ K ^ Fintype.card α := by
  classical
  rcases hd : (decode L H (H x)).1 with _ | y₀
  · -- the hash decoder already refuses: no output at all
    have hempty : silentSlice L x H K = ∅ := by
      apply Finset.eq_empty_of_forall_notMem
      intro C hC
      simp only [silentSlice, mem_filter, mem_univ, true_and, IsSilent] at hC
      obtain ⟨hsome, -⟩ := hC
      obtain ⟨y, hy⟩ := Option.isSome_iff_exists.1 hsome
      have := decodeChk_output hy
      rw [show (encChk H C x).1 = H x from rfl, hd] at this
      exact absurd this (by simp)
    rw [hempty]
    simp
  · by_cases hy₀ : y₀ = x
    · -- the hash decoder proposes the correct string: nothing silent can happen
      have hempty : silentSlice L x H K = ∅ := by
        apply Finset.eq_empty_of_forall_notMem
        intro C hC
        simp only [silentSlice, mem_filter, mem_univ, true_and, IsSilent] at hC
        obtain ⟨hsome, hne⟩ := hC
        obtain ⟨y, hy⟩ := Option.isSome_iff_exists.1 hsome
        have hout := decodeChk_output hy
        rw [show (encChk H C x).1 = H x from rfl, hd] at hout
        have : y = x := by rw [← hy₀]; exact (Option.some_injective _ hout).symm
        rw [hy, this] at hne
        exact hne rfl
      rw [hempty]
      simp
    · -- the hash decoder proposes a wrong candidate `y₀`: the checksum must collide
      have hsub : silentSlice L x H K ⊆ collisionEvent K y₀ x := by
        intro C hC
        simp only [silentSlice, mem_filter, mem_univ, true_and, IsSilent] at hC
        obtain ⟨hsome, -⟩ := hC
        obtain ⟨y, hy⟩ := Option.isSome_iff_exists.1 hsome
        have hout := decodeChk_output hy
        rw [show (encChk H C x).1 = H x from rfl, hd] at hout
        have hyy : y₀ = y := Option.some_injective _ hout
        -- the checksum of the accepted candidate equals the received checksum `C x`
        have hchk : C y = (encChk H C x).2 := by
          simp only [decodeChk, Option.bind_eq_some_iff] at hy
          obtain ⟨z, hz, hzy⟩ := hy
          by_cases hc : C z = (encChk H C x).2
          · rw [if_pos hc] at hzy
            have : z = y := by simpa using hzy
            rw [← this]; exact hc
          · rw [if_neg hc] at hzy
            exact absurd hzy (by simp)
        simp only [collisionEvent, mem_filter, mem_univ, true_and]
        rw [hyy]
        exact hchk
      calc K * (silentSlice L x H K).card
          ≤ K * (collisionEvent K y₀ x).card := Nat.mul_le_mul_left _ (Finset.card_le_card hsub)
        _ = K ^ Fintype.card α := card_collisionEvent_mul hy₀

/-- **No silent corruption, quantitatively.**  For *every* source string `x` —
typical or atypical, i.e. with no assumption whatsoever on `x` — the fraction of
codebook pairs `(H, C)` under which the decoder confidently outputs a wrong
string is at most `1/K`.  Failures are therefore detected except with probability
`2 ^ (-log₂ K)`, at a cost of `log₂ K` extra bits and one extra comparison. -/
theorem silent_corruption_prob_le (L : List α) (x : α) :
    K * (silentSet L x M K).card ≤ M ^ Fintype.card α * K ^ Fintype.card α := by
  classical
  have hsub : silentSet L x M K ⊆
      (univ : Finset (α → Fin M)).biUnion (fun H => {H} ×ˢ silentSlice L x H K) := by
    intro p hp
    simp only [silentSet, mem_filter, mem_univ, true_and] at hp
    refine mem_biUnion.2 ⟨p.1, mem_univ _, ?_⟩
    rw [mem_product]
    refine ⟨by simp, ?_⟩
    simp only [silentSlice, mem_filter, mem_univ, true_and]
    exact hp
  have hcard : (silentSet L x M K).card ≤ ∑ H : α → Fin M, (silentSlice L x H K).card := by
    refine le_trans (Finset.card_le_card hsub) (le_trans Finset.card_biUnion_le ?_)
    refine Finset.sum_le_sum (fun H _ => ?_)
    rw [Finset.card_product, Finset.card_singleton, one_mul]
  calc K * (silentSet L x M K).card
      ≤ K * ∑ H : α → Fin M, (silentSlice L x H K).card := Nat.mul_le_mul_left _ hcard
    _ = ∑ H : α → Fin M, K * (silentSlice L x H K).card := by rw [Finset.mul_sum]
    _ ≤ ∑ _H : α → Fin M, K ^ Fintype.card α :=
        Finset.sum_le_sum (fun H _ => card_silentSlice_mul_le L x H)
    _ = M ^ Fintype.card α * K ^ Fintype.card α := by
        rw [Finset.sum_const, smul_eq_mul, Finset.card_univ, card_codebooks]

/-- Real-valued form: `P[silent corruption] ≤ 1/K`, uniformly in the source
string. -/
theorem silent_corruption_prob_le_real (L : List α) (x : α) (hK : 0 < K) (hM : 0 < M) :
    ((silentSet L x M K).card : ℝ) /
      ((M : ℝ) ^ Fintype.card α * (K : ℝ) ^ Fintype.card α) ≤ 1 / K := by
  have hMpos : (0 : ℝ) < M := by exact_mod_cast hM
  have hKpos : (0 : ℝ) < K := by exact_mod_cast hK
  have hden : (0 : ℝ) < (M : ℝ) ^ Fintype.card α * (K : ℝ) ^ Fintype.card α := by positivity
  have h := silent_corruption_prob_le (M := M) (K := K) L x
  have h' : (K : ℝ) * ((silentSet L x M K).card : ℝ)
      ≤ (M : ℝ) ^ Fintype.card α * (K : ℝ) ^ Fintype.card α := by
    exact_mod_cast h
  rw [div_le_div_iff₀ hden hKpos]
  nlinarith [h']

end AlmostLossless