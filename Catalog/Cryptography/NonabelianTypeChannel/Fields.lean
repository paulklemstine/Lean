import Cryptography.NonabelianTypeChannel.LogValues

/-!
# The law table: seven splitting-type channels in closed form

This file evaluates, exactly and in closed form, the complete splitting-type channel
of the six Galois groups of the experiment.  Writing `L3 = log₂ 3`, the table is

| field | `G` | `G^ab` | `H(T)` | `I(coset ; T)` | dial `log₂[G:G']` | loss |
|---|---|---|---|---|---|---|
| `x³+x+1`, `x³-x+1` | `S₃` | `C₂` | `2/3 + L3/2` | `1` | `1` | `0` |
| `x⁴-x-1` | `S₄` | `C₂` | `3/2 + 3L3/8` | `1` | `1` | `0` |
| `x⁴+8x+12` | `A₄` | `C₃` | `3L3/4` | `L3 - 2/3` | `L3` | `2/3` |
| `x⁴-2` | `D₄` | `C₂×C₂` | `5/2 - 3L3/8` | `9/4 - 3L3/8` | `2` | `3L3/8 - 1/4` |
| `x⁴-2x²+9` | `V₄` | `V₄` | `2 - 3L3/4` | `2 - 3L3/4` | `2` | `3L3/4` |
| `Φ₅` | `C₄` | `C₄` | `3/2` | `3/2` | `2` | `1/2` |

Numerically `L3 = 1.58496...`, so the `I` column reads
`1, 1, 0.91830, 1.65564, 0.81128, 1.5`, matching the measured prime-level channels
`1.0000, 1.0100, 0.9188, 1.6555, 0.8092, 1.4989` of the experiment.

Two structural phenomena are isolated as theorems:

* `TypeChannel.S4_cap_strict` — `S₄` carries `3/2 + 3L3/8 > 2` bits of splitting
  entropy but leaks exactly one: the cap is a theorem about the abelianization, not
  about the number of types.
* `TypeChannel.reversal_V4_lt_D4` — the *reversal*: the non-abelian `D₄` channel is
  strictly richer than the abelian `V₄` channel.  Abelianness of the group is not
  what makes a channel rich; separation of the cosets by the readout is.
-/

namespace TypeChannel

open Finset Real

set_option maxRecDepth 4000000

/-! ### `S₃`: the Galois group of `x³ + x + 1` -/

theorem S3_entropy_type : entropy S3 splitType = 2/3 + 1/2 * logb 2 3 := by
  have hcard : S3.card = 6 := by decide
  rw [entropy_eq_sumList (A := [(3,0),(1,2),(0,0)]) (L := [1,3,2])
      (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 1 6 (by norm_num) (by norm_num),
      neg_prob_logb_real 3 6 (by norm_num) (by norm_num),
      neg_prob_logb_real 2 6 (by norm_num) (by norm_num)]
  rw [logb2_six, logb2_two]
  norm_num
  ring

/-- In `S₃` the splitting type determines the parity, so the channel is complete. -/
theorem S3_channel : mutualInfo S3 signIdx splitType = 1 := by
  have himg : (S3.image signIdx).card = 2 := by decide
  have hdet : ∀ g ∈ S3, signIdx g = (fun t : ℕ × ℕ => if t = (1,2) then 1 else 0)
      (splitType g) := by decide
  rw [typeChannel_eq_logb_index_of_determines (φ := fun t : ℕ × ℕ => if t = (1,2) then 1 else 0)
    S3_isSubgroup A3_isSubgroup (by decide) S3_coset hdet, himg]
  simp

/-! ### `S₄`: the Galois group of `x⁴ - x - 1` -/

theorem S4_entropy_type : entropy S4 splitType = 3/2 + 3/8 * logb 2 3 := by
  have hcard : S4.card = 24 := by decide
  rw [entropy_eq_sumList (A := [(4,0),(2,2),(0,4),(1,0),(0,0)]) (L := [1,6,3,8,6])
      (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 1 24 (by norm_num) (by norm_num),
      neg_prob_logb_real 6 24 (by norm_num) (by norm_num),
      neg_prob_logb_real 3 24 (by norm_num) (by norm_num),
      neg_prob_logb_real 8 24 (by norm_num) (by norm_num)]
  rw [logb2_six, logb2_eight, logb2_twentyfour]
  norm_num
  ring

/-- `S₄` has five splitting types and more than two bits of type entropy, but its
channel is exactly one bit: the `C₂` cap of its abelianization. -/
theorem S4_channel : mutualInfo S4 signIdx splitType = 1 := by
  have himg : (S4.image signIdx).card = 2 := by decide
  have hdet : ∀ g ∈ S4, signIdx g =
      (fun t : ℕ × ℕ => if t = (2,2) ∨ t = (0,0) then 1 else 0) (splitType g) := by decide
  rw [typeChannel_eq_logb_index_of_determines
    (φ := fun t : ℕ × ℕ => if t = (2,2) ∨ t = (0,0) then 1 else 0)
    S4_isSubgroup A4_isSubgroup (by decide) S4_coset hdet, himg]
  simp

/-- **The cap is about the abelianization, not the type count.**  `S₄` carries more
than two bits of splitting entropy and leaks exactly one. -/
theorem S4_cap_strict : mutualInfo S4 signIdx splitType < entropy S4 splitType := by
  rw [S4_channel, S4_entropy_type]
  have := logb2_three_pos
  linarith

/-! ### `A₄`: the Galois group of `x⁴ + 8x + 12` -/

theorem A4_entropy_type : entropy A4 splitType = 3/4 * logb 2 3 := by
  have hcard : A4.card = 12 := by decide
  rw [entropy_eq_sumList (A := [(4,0),(0,4),(1,0)]) (L := [1,3,8])
      (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 1 12 (by norm_num) (by norm_num),
      neg_prob_logb_real 3 12 (by norm_num) (by norm_num),
      neg_prob_logb_real 8 12 (by norm_num) (by norm_num)]
  rw [logb2_eight, logb2_twelve]
  norm_num
  ring

theorem A4_entropy_coset : entropy A4 pairIdx = logb 2 3 := by
  have himg : (A4.image pairIdx).card = 3 := by decide
  rw [entropy_cosetReadout A4_isSubgroup V4_isSubgroup (by decide) A4_coset, himg]
  norm_num

theorem A4_entropy_joint : entropy A4 (pairObs pairIdx splitType)
    = 2/3 + 3/4 * logb 2 3 := by
  have hcard : A4.card = 12 := by decide
  rw [entropy_eq_sumList (A := [(0,(4,0)),(0,(0,4)),(1,(1,0)),(2,(1,0))]) (L := [1,3,4,4])
      (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 1 12 (by norm_num) (by norm_num),
      neg_prob_logb_real 3 12 (by norm_num) (by norm_num),
      neg_prob_logb_real 4 12 (by norm_num) (by norm_num)]
  rw [logb2_four, logb2_twelve]
  norm_num
  ring

/-- The `A₄` channel: `log₂ 3 - 2/3 = 0.91830...` bits. -/
theorem A4_channel : mutualInfo A4 pairIdx splitType = logb 2 3 - 2/3 := by
  rw [mutualInfo, A4_entropy_coset, A4_entropy_type, A4_entropy_joint]
  ring

/-- The `A₄` loss is exactly `2/3` of a bit: the type `[3,1]` fills both non-trivial
`C₃`-cosets. -/
theorem A4_loss : logb 2 (A4.image pairIdx).card - mutualInfo A4 pairIdx splitType = 2/3 := by
  have himg : (A4.image pairIdx).card = 3 := by decide
  rw [himg, A4_channel]
  norm_num

/-! ### `D₄`: the Galois group of `x⁴ - 2` -/

theorem D4_entropy_type : entropy D4 splitType = 5/2 - 3/8 * logb 2 3 := by
  have hcard : D4.card = 8 := by decide
  rw [entropy_eq_sumList (A := [(4,0),(0,0),(2,2),(0,4)]) (L := [1,2,2,3])
      (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 1 8 (by norm_num) (by norm_num),
      neg_prob_logb_real 2 8 (by norm_num) (by norm_num),
      neg_prob_logb_real 3 8 (by norm_num) (by norm_num)]
  rw [logb2_eight, logb2_two]
  norm_num
  ring

theorem D4_entropy_coset : entropy D4 d4Idx = 2 := by
  have himg : (D4.image d4Idx).card = 4 := by decide
  rw [entropy_cosetReadout D4_isSubgroup Z4c_isSubgroup (by decide) D4_coset, himg]
  simpa using logb2_four

theorem D4_entropy_joint : entropy D4 (pairObs d4Idx splitType) = 9/4 := by
  have hcard : D4.card = 8 := by decide
  rw [entropy_eq_sumList (A := [(0,(4,0)),(0,(0,4)),(1,(2,2)),(2,(0,4)),(3,(0,0))])
      (L := [1,1,2,2,2]) (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 1 8 (by norm_num) (by norm_num),
      neg_prob_logb_real 2 8 (by norm_num) (by norm_num)]
  rw [logb2_eight, logb2_two]
  norm_num

/-- The `D₄` channel: `9/4 - (3/8)·log₂3 = 1.65564...` bits — a non-abelian group whose
channel exceeds one bit, exactly as its two-dimensional abelianization predicts. -/
theorem D4_channel : mutualInfo D4 d4Idx splitType = 9/4 - 3/8 * logb 2 3 := by
  rw [mutualInfo, D4_entropy_coset, D4_entropy_type, D4_entropy_joint]
  ring

theorem D4_loss :
    logb 2 (D4.image d4Idx).card - mutualInfo D4 d4Idx splitType = 3/8 * logb 2 3 - 1/4 := by
  have himg : (D4.image d4Idx).card = 4 := by decide
  rw [himg, D4_channel]
  have : logb 2 ((4:ℕ) : ℝ) = 2 := by simpa using logb2_four
  rw [this]
  ring

/-! ### `V₄`: the Galois group of `x⁴ - 2x² + 9` (abelian control) -/

theorem V4_entropy_type : entropy V4 splitType = 2 - 3/4 * logb 2 3 := by
  have hcard : V4.card = 4 := by decide
  rw [entropy_eq_sumList (A := [(4,0),(0,4)]) (L := [1,3])
      (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 1 4 (by norm_num) (by norm_num),
      neg_prob_logb_real 3 4 (by norm_num) (by norm_num)]
  rw [logb2_four]
  norm_num
  ring

/-- For the regular abelian groups the coset readout is injective, so the type is a
function of it and the channel is the whole type entropy. -/
theorem V4_channel : mutualInfo V4 rootIdx splitType = 2 - 3/4 * logb 2 3 := by
  have hdet : ∀ g ∈ V4, splitType g = (fun i : ℕ => if i = 0 then (4,0) else (0,4))
      (rootIdx g) := by decide
  rw [mutualInfo_comm,
    mutualInfo_eq_left_of_factors (φ := fun i : ℕ => if i = 0 then (4,0) else (0,4)) hdet,
    V4_entropy_type]

/-! ### `C₄`: the Galois group of `Φ₅` (abelian control) -/

theorem C4_entropy_type : entropy C4 splitType = 3/2 := by
  have hcard : C4.card = 4 := by decide
  rw [entropy_eq_sumList (A := [(4,0),(0,0),(0,4)]) (L := [1,2,1])
      (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 1 4 (by norm_num) (by norm_num),
      neg_prob_logb_real 2 4 (by norm_num) (by norm_num)]
  rw [logb2_four, logb2_two]
  norm_num

theorem C4_channel : mutualInfo C4 rootIdx splitType = 3/2 := by
  have hdet : ∀ g ∈ C4, splitType g =
      (fun i : ℕ => if i = 0 then (4,0) else if i = 2 then (0,4) else (0,0)) (rootIdx g) := by
    decide
  rw [mutualInfo_comm,
    mutualInfo_eq_left_of_factors
      (φ := fun i : ℕ => if i = 0 then (4,0) else if i = 2 then (0,4) else (0,0)) hdet,
    C4_entropy_type]

/-! ### The reversal -/

/-- **The reversal.**  The non-abelian `D₄` type channel is strictly richer than the
abelian `V₄` type channel, even though `V₄` is its own abelianization: what decides
the richness of a channel is the separation of the cosets by the readout. -/
theorem reversal_V4_lt_D4 :
    mutualInfo V4 rootIdx splitType < mutualInfo D4 d4Idx splitType := by
  rw [V4_channel, D4_channel]
  have := logb2_three_pos
  linarith

/-- Both `V₄` and `D₄` sit under the same two-bit abelianization cap. -/
theorem V4_D4_under_two_bits :
    mutualInfo V4 rootIdx splitType < 2 ∧ mutualInfo D4 d4Idx splitType < 2 := by
  rw [V4_channel, D4_channel]
  have h1 := logb2_three_pos
  have h2 := logb2_three_gt_one
  constructor <;> linarith

end TypeChannel