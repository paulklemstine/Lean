/-
# NET-92 cycle: the crowding law — where the KV cliff sits as a function of context

NET-92 measured, on Qwen2.5-7B-Instruct Q4_K_M at context `2048`, that an 8-bit KV cache is
quality free (`+0.10 %` worst case over the `q8_0` arms) while a raw per-tensor `q4_0` cache
annihilates the model (`PPL 7.1093 → 2714.6042`, `+38 084 %`).  The honest limits of that
round include one that this file addresses head on:

> *cliff position vs context length untested.*

The existing catalog files fix the context and study the bit axis:
`Algebra.KVCacheRoleSplit` (upper bounds per role), `Algebra.KVCacheArgmaxThreshold`
(the gap-threshold mechanism, `softmaxW_lt_iff`, `softmaxW_rank_inversion`,
`critical_band_subsingleton`), `Novelty.KeyBitwidthSafety` (`res`, margin criteria).
Here we fix the bit axis and move the **context**.

The mechanism is a pigeonhole on the *logit window*.  A transformer's attention logits at a
given head live in a bounded window of width `R` (bounded queries, bounded keys).  With `n`
cached positions inside that window, the tightest consecutive pair is separated by at most
`R / n` (`exists_small_consecutive_gap`): **crowding is forced, not accidental**.  Since the
gap-threshold mechanism of `Algebra.KVCacheArgmaxThreshold` inverts a pair as soon as the
quantisation noise `A / 2 ^ b` beats half that gap, the safe bit width obeys

* `SafeBits_iff_pow_gt` — `b` is safe at context `n` iff `2 ^ b > 2 A n / R`;
* `SafeBits_ctx_double` — safety at `(n, b)` and at `(2 n, b + 1)` are *the same statement*:
  **one extra KV bit buys exactly one context doubling**;
* `minSafeBits_double` — the least safe width increases by exactly one per doubling;
* `crowding_inverts_softmax` — above the crowding threshold an admissible quantisation
  error actually reverses a softmax ranking.

The prediction is quantitative and falsifiable: the NET-92 cliff, bracketed in `(4, 8]` at
`ctx = 2048`, must move **up by one bit per context doubling** — at `ctx = 8192` the same
model should already be damaged at bit widths that were free at `2048`.
-/
import Mathlib
import Algebra.KVCacheArgmaxThreshold
import Novelty.KeyBitwidthSafety

namespace Catalog.Logic.KVCliffCrowding

open Finset Catalog.Algebra.KVCache

/-! ## The crowding pigeonhole -/

/-- **Crowding is forced.**  If `n + 1` positions `s 0, …, s n` are enumerated in a window of
total width `R`, then some *consecutive* pair is separated by at most `R / n`.  Nothing is
assumed about the distribution of the logits: this is a telescoping pigeonhole. -/
theorem exists_small_consecutive_gap (s : ℕ → ℝ) (n : ℕ) (hn : 0 < n) (R : ℝ)
    (hspread : s n - s 0 ≤ R) : ∃ k < n, s (k + 1) - s k ≤ R / n := by
  by_contra hcon
  push_neg at hcon
  have hne : (Finset.range n).Nonempty := by
    simpa [Finset.nonempty_range_iff] using hn.ne'
  have hlt : ∑ _k ∈ Finset.range n, (R / n) < ∑ k ∈ Finset.range n, (s (k + 1) - s k) :=
    Finset.sum_lt_sum_of_nonempty hne (fun k hk => hcon k (Finset.mem_range.mp hk))
  rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul, Finset.sum_range_sub] at hlt
  have hcast : (n : ℝ) * (R / n) = R := by
    field_simp
  linarith [hcast ▸ hlt]

/-- The crowding bound in the form used downstream: the minimal consecutive gap of a
monotone enumeration of `n + 1` positions inside a window of width `R` is `≤ R / n`, and the
witnessing pair is genuinely ordered. -/
theorem exists_crowded_pair (s : ℕ → ℝ) (n : ℕ) (hn : 0 < n) (R : ℝ)
    (hmono : ∀ k, s k ≤ s (k + 1)) (hspread : s n - s 0 ≤ R) :
    ∃ k < n, s k ≤ s (k + 1) ∧ s (k + 1) - s k ≤ R / n := by
  obtain ⟨k, hk, hgap⟩ := exists_small_consecutive_gap s n hn R hspread
  exact ⟨k, hk, hmono k, hgap⟩

/-! ## The safe-bit predicate and its context scaling -/

/-- `SafeBits A R n b` : at context length `n`, with attention logits confined to a window of
width `R` and a `b`-bit key grid contributing at most `A / 2 ^ b` of logit error, the noise
stays strictly below half of the *forced* crowding gap `R / n`.

`A` is the logit-side amplification of one key entry (`‖q‖₁` times the key range in the
language of `Novelty.KeyBitwidthSafety.bits_suffice_for_margin`). -/
def SafeBits (A R : ℝ) (n b : ℕ) : Prop := 2 * (A / 2 ^ b) < R / n

/-- Safety is monotone in the bit width. -/
theorem SafeBits_mono {A R : ℝ} {n b b' : ℕ} (hA : 0 ≤ A) (hbb : b ≤ b')
    (h : SafeBits A R n b) : SafeBits A R n b' := by
  have hmono : (2 : ℝ) ^ b ≤ 2 ^ b' := pow_le_pow_right₀ (by norm_num) hbb
  have : A / 2 ^ b' ≤ A / 2 ^ b :=
    div_le_div_of_nonneg_left hA (by positivity) hmono
  exact lt_of_le_of_lt (by linarith) h

/-- Safety is a purely arithmetic condition on `2 ^ b`. -/
theorem SafeBits_iff_pow_gt {A R : ℝ} {n b : ℕ} (hn : 0 < n) :
    SafeBits A R n b ↔ 2 * A * n < R * 2 ^ b := by
  have hpow : (0 : ℝ) < 2 ^ b := by positivity
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
  unfold SafeBits
  rw [show 2 * (A / 2 ^ b) = (2 * A) / 2 ^ b by ring, div_lt_div_iff₀ hpow hnpos,
    show (2 * A) * (n : ℝ) = 2 * A * n by ring]

/-- **One bit per context doubling.**  Safety at `(n, b)` and safety at `(2 n, b + 1)` are the
*same* condition — not merely comparable, literally equivalent.  This is the exact scaling law
for the position of the KV cliff along the context axis. -/
theorem SafeBits_ctx_double {A R : ℝ} {n b : ℕ} :
    SafeBits A R (2 * n) (b + 1) ↔ SafeBits A R n b := by
  have hpow : (0 : ℝ) < 2 ^ b := by positivity
  unfold SafeBits
  rw [pow_succ]
  have h1 : 2 * (A / (2 ^ b * 2)) = (2 * (A / 2 ^ b)) / 2 := by ring
  have h2 : R / ((2 * n : ℕ) : ℝ) = (R / n) / 2 := by
    push_cast
    rw [mul_comm (2:ℝ) (n:ℝ)]
    rw [div_mul_eq_div_div]
  rw [h1, h2, div_lt_div_iff_of_pos_right (by norm_num : (0:ℝ) < 2)]

/-- Iterated form: `m` context doublings cost exactly `m` bits. -/
theorem SafeBits_ctx_pow {A R : ℝ} {n b : ℕ} (m : ℕ) :
    SafeBits A R (2 ^ m * n) (b + m) ↔ SafeBits A R n b := by
  induction m with
  | zero => simp
  | succ m ih =>
      have hrw : 2 ^ (m + 1) * n = 2 * (2 ^ m * n) := by ring
      rw [hrw, show b + (m + 1) = (b + m) + 1 by ring, SafeBits_ctx_double, ih]

/-- Some bit width is always safe: the requirement is logarithmic in the crowding factor. -/
theorem SafeBits_exists {A R : ℝ} {n : ℕ} (hR : 0 < R) (hn : 0 < n) :
    ∃ b, SafeBits A R n b := by
  set x : ℝ := 2 * A * n / R with hx
  refine ⟨⌈x⌉₊, ?_⟩
  have hxle : x ≤ (⌈x⌉₊ : ℝ) := Nat.le_ceil x
  have hlt : ((⌈x⌉₊ : ℕ) : ℝ) < 2 ^ (⌈x⌉₊ : ℕ) := by
    exact_mod_cast Nat.lt_two_pow_self
  have hxlt : x < 2 ^ (⌈x⌉₊ : ℕ) := lt_of_le_of_lt hxle hlt
  rw [SafeBits_iff_pow_gt hn]
  have hkey : 2 * A * n < 2 ^ (⌈x⌉₊ : ℕ) * R := (div_lt_iff₀ hR).mp hxlt
  linarith

/-- The least safe bit width at context `n`. -/
noncomputable def minSafeBits (A R : ℝ) (n : ℕ) : ℕ := sInf {b | SafeBits A R n b}

/-- **The cliff moves by exactly one bit per context doubling.**  Provided the doubled context
is not already safe at zero bits (i.e. the regime is nontrivial), the least safe KV width at
context `2 n` is one more than at context `n`. -/
theorem minSafeBits_double {A R : ℝ} {n : ℕ} (hR : 0 < R) (hn : 0 < n)
    (h0 : ¬ SafeBits A R (2 * n) 0) :
    minSafeBits A R (2 * n) = minSafeBits A R n + 1 := by
  have hne : {b | SafeBits A R n b}.Nonempty := SafeBits_exists hR hn
  have hmem : SafeBits A R n (minSafeBits A R n) := Nat.sInf_mem hne
  have hupper : SafeBits A R (2 * n) (minSafeBits A R n + 1) :=
    SafeBits_ctx_double.mpr hmem
  refine le_antisymm (Nat.sInf_le hupper) ?_
  have hne2 : {b | SafeBits A R (2 * n) b}.Nonempty := ⟨_, hupper⟩
  have hmem2 : SafeBits A R (2 * n) (minSafeBits A R (2 * n)) := Nat.sInf_mem hne2
  rcases Nat.eq_zero_or_pos (minSafeBits A R (2 * n)) with hz | hpos
  · rw [hz] at hmem2; exact absurd hmem2 h0
  · obtain ⟨c, hc⟩ : ∃ c, minSafeBits A R (2 * n) = c + 1 :=
      ⟨minSafeBits A R (2 * n) - 1, by omega⟩
    have hcs : SafeBits A R n c := SafeBits_ctx_double.mp (hc ▸ hmem2)
    have hle : minSafeBits A R n ≤ c := Nat.sInf_le hcs
    omega

/-! ## From crowding to an actual softmax inversion -/

/-- **The crowding law bites.**  Take `n + 1` cached positions whose logits are monotone and
confined to a window of width `R`, and a quantiser whose logit error can reach `ε` with
`2 ε > R / n`.  Then there are two adjacent positions, correctly ordered before quantisation,
whose softmax weights are *strictly reversed* after it: the model attends to the wrong token.

Combined with `SafeBits_ctx_double`, this says the damage threshold is not a property of the
bit width alone — it is a property of `bits − log₂(context)`. -/
theorem crowding_inverts_softmax {n : ℕ} (hn : 0 < n) (s : Fin (n + 1) → ℝ) (R ε : ℝ)
    (hmono : Monotone s) (hspread : s (Fin.last n) - s 0 ≤ R) (hε : R / n < 2 * ε) :
    ∃ (i j : Fin (n + 1)) (d : Fin (n + 1) → ℝ),
      s i ≤ s j ∧ (∀ k, |d k| ≤ ε) ∧
        softmaxW (fun k => s k + d k) j < softmaxW (fun k => s k + d k) i := by
  classical
  -- enumerate the logits along `ℕ`, clamped at `n`
  set t : ℕ → ℝ := fun m => s ⟨min m n, by omega⟩ with ht
  have hmono' : ∀ k, t k ≤ t (k + 1) := by
    intro k
    refine hmono ?_
    simp only [Fin.mk_le_mk]
    omega
  have hspread' : t n - t 0 ≤ R := by
    have h1 : t n = s (Fin.last n) := by
      simp [ht, Fin.last]
    have h2 : t 0 = s 0 := by
      simp [ht]
    rw [h1, h2]; exact hspread
  obtain ⟨k, hk, hgap⟩ := exists_small_consecutive_gap t n hn R hspread'
  have hklt : k < n + 1 := by omega
  have hk1lt : k + 1 < n + 1 := by omega
  refine ⟨⟨k, hklt⟩, ⟨k + 1, hk1lt⟩, fun m => if (m : ℕ) ≤ k then ε else -ε,
    ?_, ?_, ?_⟩
  · have := hmono' k
    have e1 : t k = s ⟨k, hklt⟩ := by
      simp only [ht]
      congr 1
      simp only [Fin.mk.injEq]
      omega
    have e2 : t (k + 1) = s ⟨k + 1, hk1lt⟩ := by
      simp only [ht]
      congr 1
      simp only [Fin.mk.injEq]
      omega
    rw [← e1, ← e2]; exact hmono' k
  · intro m
    have hεnn : 0 ≤ ε := by
      have hgap0 : 0 ≤ t (k + 1) - t k := by linarith [hmono' k]
      linarith [hgap, hε]
    show |(if (m : ℕ) ≤ k then ε else -ε)| ≤ ε
    by_cases h1 : (m : ℕ) ≤ k
    · rw [if_pos h1, abs_of_nonneg hεnn]
    · rw [if_neg h1, abs_neg, abs_of_nonneg hεnn]
  · refine (softmaxW_lt_iff (fun k => s k + _) _ _).2 ?_
    have e1 : t k = s ⟨k, hklt⟩ := by
      simp only [ht]; congr 1; simp only [Fin.mk.injEq]; omega
    have e2 : t (k + 1) = s ⟨k + 1, hk1lt⟩ := by
      simp only [ht]; congr 1; simp only [Fin.mk.injEq]; omega
    have hnoise : s ⟨k + 1, hk1lt⟩ - s ⟨k, hklt⟩ < 2 * ε := by
      rw [← e1, ← e2]
      calc t (k + 1) - t k ≤ R / n := hgap
        _ < 2 * ε := hε
    show s ⟨k + 1, hk1lt⟩ + (if (k + 1 : ℕ) ≤ k then ε else -ε)
        < s ⟨k, hklt⟩ + (if (k : ℕ) ≤ k then ε else -ε)
    rw [if_neg (by omega : ¬ (k + 1 ≤ k)), if_pos (le_refl k)]
    linarith

/-! ## The NET-92 instance -/

/-- **NET-92 prediction, in numbers.**  At the NET-92 reference scale (logit amplification
`A = 1`, logit window `R = 32`) the crowding criterion is satisfied at `8` bits for
`ctx = 2048` and fails at `4` bits for the same context: the cliff is bracketed in `(4, 8]`,
exactly as measured. -/
theorem net92_bracket : SafeBits 1 32 2048 8 ∧ ¬ SafeBits 1 32 2048 4 := by
  constructor
  · rw [SafeBits_iff_pow_gt (by norm_num)]
    norm_num
  · rw [SafeBits_iff_pow_gt (by norm_num)]
    norm_num

/-- **The falsifiable consequence.**  The same reference scale that brackets the cliff in
`(4, 8]` at `ctx = 2048` predicts that `8` bits are *no longer* safe at `ctx = 32768`: four
context doublings consume four bits of KV precision, so the safe 8-bit operating point of
NET-92 is a statement about the context, not about the model. -/
theorem net92_eight_bits_fail_at_long_context : ¬ SafeBits 1 32 32768 8 := by
  rw [SafeBits_iff_pow_gt (by norm_num)]
  norm_num

end Catalog.Logic.KVCliffCrowding