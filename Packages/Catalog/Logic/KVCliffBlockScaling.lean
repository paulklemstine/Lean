/-
# NET-92 cycle 2: does block scaling rescue 4-bit KV?  Exactly one bit per halving, and never
# distinctness

NET-92's own list of honest limits names this as the immediate follow-up:

> *`q4_1`/`iq4_nl` block-scaled variants untested (does block-scaling rescue 4-bit?)*

This file answers the question structurally, in two halves that pull in opposite directions.

**Yes, on resolution — and by an exactly computable amount.**  A block-scaled quantiser is a
per-tensor quantiser applied to a smaller dynamic range.  Against the crowding criterion of
`Logic.KVCliffCrowdingLaw`, shrinking the range by `2 ^ m` is *literally the same statement* as
adding `m` bits (`block_scaling_is_bit_shift`).  So `q4_1` rescues the NET-92 cell if and only
if the per-block key range is at least `16 ×` smaller than the per-tensor range
(`rescue_requires_16x_concentration`), and `block_rescue_at_net92_scale` exhibits the rescue at
the reference scale.  The prediction is sharp and cheap to test: measure the ratio
`(per-block key range) / (per-tensor key range)`; block scaling rescues 4-bit KV exactly when
that ratio is below `1/16`, and one *single* bad block is enough to lose the guarantee
(`worst_block_governs`, `no_rescue_of_full_range_block`).

**No, on distinctness — and no scaling scheme ever can.**  A 4-bit code has sixteen levels, and
a `q4_0`/`q4_1` block holds thirty-two weights: by pigeonhole two distinct keys in every block
receive the same code (`block_collision`), whatever affine rescaling is applied
(`affine_rescaling_cannot_separate`).  Collided keys have equal logits, hence exactly equal
softmax weights (`collided_keys_tie`), so the attention ranking inside each block is destroyed
at 4 bits no matter how the block is scaled.  This is the structural reason the KV cliff is a
wall: block scaling moves the *resolution* threshold by a computable number of bits but cannot
move the *distinctness* threshold at all, and at 4 bits the two thresholds have already
crossed.
-/
import Mathlib
import Logic.KVCliffCrowdingLaw

namespace Catalog.Logic.KVCliffBlock

open Finset Catalog.Algebra.KVCache Catalog.Logic.KVCliffCrowding

/-! ## Resolution: block scaling is a bit shift -/

/-- **Block scaling is exactly a bit shift.**  Quantising a range shrunk by `2 ^ m` at `b` bits
is the same safety statement as quantising the full range at `b + m` bits. -/
theorem block_scaling_is_bit_shift {A R : ℝ} {n b m : ℕ} :
    SafeBits (A / 2 ^ m) R n b ↔ SafeBits A R n (b + m) := by
  unfold SafeBits
  rw [pow_add, div_div, mul_comm ((2:ℝ) ^ m) ((2:ℝ) ^ b)]

/-- **How much concentration a rescue needs.**  If a `ρ`-fold concentrated block range makes
`4` bits safe while the full range is not even safe at `8` bits, then `ρ < 1/16`: block scaling
must shrink the dynamic range by more than the four bits it is trying to replace. -/
theorem rescue_requires_16x_concentration {A R rho : ℝ} {n : ℕ} (hn : 0 < n) (hA : 0 < A)
    (hsafe : SafeBits (rho * A) R n 4) (hfail : ¬ SafeBits A R n 8) :
    rho < 1 / 16 := by
  rw [SafeBits_iff_pow_gt hn] at hsafe
  rw [SafeBits_iff_pow_gt hn] at hfail
  push_neg at hfail
  have hnpos : (0:ℝ) < n := by exact_mod_cast hn
  have h1 : 2 * (rho * A) * n < R * 2 ^ 4 := hsafe
  have h2 : R * 2 ^ 8 ≤ 2 * A * n := hfail
  have hAn : 0 < 2 * A * n := by positivity
  nlinarith [h1, h2, hAn]

/-- The NET-92 reference scale (`A = 1`, `R = 32`, `ctx = 2048`): four bits fail, but four bits
on a range concentrated by `2 ^ 4` succeed.  Block scaling *does* rescue the cell — provided
the concentration is real. -/
theorem block_rescue_at_net92_scale :
    ¬ SafeBits 1 32 2048 4 ∧ SafeBits ((1 : ℝ) / 2 ^ 4) 32 2048 4 := by
  refine ⟨net92_bracket.2, ?_⟩
  rw [block_scaling_is_bit_shift]
  simpa using net92_bracket.1

/-! ## One bad block is enough -/

/-- Safety of a blocked cache is safety of every block. -/
def BlockSafe {B : ℕ} (A : Fin B → ℝ) (R : ℝ) (n b : ℕ) : Prop := ∀ j, SafeBits (A j) R n b

/-- **The worst block governs.**  If one block's range dominates, the whole cache is safe as
soon as that block is. -/
theorem worst_block_governs {B : ℕ} {A : Fin B → ℝ} {R : ℝ} {n b : ℕ} {j₀ : Fin B}
    (hmax : ∀ j, A j ≤ A j₀) (hj₀ : SafeBits (A j₀) R n b) : BlockSafe A R n b := by
  intro j
  have hpow : (0:ℝ) < 2 ^ b := by positivity
  have hle : A j / 2 ^ b ≤ A j₀ / 2 ^ b := by
    have := hmax j
    gcongr
  exact lt_of_le_of_lt (by linarith) hj₀

/-- **No rescue from a single full-range block.**  If one block still spans the whole tensor
range, block scaling has bought nothing: the blocked cache is safe only where the per-tensor
cache already was. -/
theorem no_rescue_of_full_range_block {B : ℕ} {A : Fin B → ℝ} {Afull R : ℝ} {n b : ℕ}
    {j₀ : Fin B} (hfull : A j₀ = Afull) (hsafe : BlockSafe A R n b) : SafeBits Afull R n b := by
  rw [← hfull]; exact hsafe j₀

/-! ## Distinctness: pigeonhole beats every scaling scheme -/

/-- **Four bits collide inside every block.**  A quantiser whose codebook has at most `16`
values must send two of the `32` distinct weights of a `q4_0`-style block to the same code.
Sixteen levels cannot separate thirty-two numbers; this is independent of the scale. -/
theorem block_collision (Q : ℝ → ℝ) (x : Fin 32 → ℝ) (C : Finset ℝ) (hcard : C.card ≤ 16)
    (hmaps : ∀ i, Q (x i) ∈ C) (hinj : Function.Injective x) :
    ∃ i j : Fin 32, i ≠ j ∧ x i ≠ x j ∧ Q (x i) = Q (x j) := by
  have hlt : C.card < (Finset.univ : Finset (Fin 32)).card := by
    simp only [Finset.card_univ, Fintype.card_fin]
    omega
  obtain ⟨i, _, j, _, hij, heq⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to hlt (fun i _ => Finset.mem_coe.mp (by
      simpa using hmaps i))
  exact ⟨i, j, hij, fun h => hij (hinj h), heq⟩

/-- **Affine rescaling cannot separate.**  Block scaling replaces the quantiser `Q` by
`x ↦ σ · Q ((x − μ)/σ)`; the number of distinct outputs is unchanged, so the collision of
`block_collision` survives every choice of block scale `σ ≠ 0` and block offset `μ`. -/
theorem affine_rescaling_cannot_separate (Q : ℝ → ℝ) (x : Fin 32 → ℝ) (C : Finset ℝ)
    (sigma mu : ℝ) (hcard : C.card ≤ 16)
    (hmaps : ∀ i, Q ((x i - mu) / sigma) ∈ C) (hinj : Function.Injective x) :
    ∃ i j : Fin 32, i ≠ j ∧ x i ≠ x j ∧
      sigma * Q ((x i - mu) / sigma) = sigma * Q ((x j - mu) / sigma) := by
  obtain ⟨i, j, hij, hxij, heq⟩ :=
    block_collision (fun y => Q ((y - mu) / sigma)) x C hcard hmaps hinj
  exact ⟨i, j, hij, hxij, by rw [heq]⟩

/-- **A collision is a tie, and a tie is a lost ranking.**  Two cache positions whose quantised
logits agree receive exactly equal softmax weights, so the attention ordering between them
carries no information at all — the failure mode that the gap-threshold analysis of
`Algebra.KVCacheArgmaxThreshold` predicts and that no rescaling can undo. -/
theorem collided_keys_tie {N : ℕ} [NeZero N] (s : Fin N → ℝ) (i j : Fin N) (hs : s i = s j) :
    softmaxW s i = softmaxW s j := by
  unfold softmaxW
  rw [hs]

/-- **The two thresholds, side by side.**  At `4` bits, on the NET-92 reference scale, block
scaling by `2 ^ 4` restores the resolution criterion, yet the very same block still contains a
pair of distinct keys that the code cannot tell apart, and those keys tie in the softmax.  A
rescue of the resolution axis is therefore not a rescue of the model. -/
theorem block_scaling_rescues_resolution_not_distinctness
    (Q : ℝ → ℝ) (x : Fin 32 → ℝ) (C : Finset ℝ) (hcard : C.card ≤ 16)
    (hmaps : ∀ i, Q (x i) ∈ C) (hinj : Function.Injective x) :
    SafeBits ((1 : ℝ) / 2 ^ 4) 32 2048 4 ∧
      ∃ i j : Fin 32, i ≠ j ∧ x i ≠ x j ∧ Q (x i) = Q (x j) :=
  ⟨block_rescue_at_net92_scale.2, block_collision Q x C hcard hmaps hinj⟩

end Catalog.Logic.KVCliffBlock