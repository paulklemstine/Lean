import Geometry.AGL8Channel.ExtendedReversal

/-!
# The semiprime channel of a detector: two exact data points for a pair-detector law

For a detector readout on a group with cyclic abelianization `C_n` (see `DetectorLaw`), the
semiprime channel `I(coset(xy) ; {Tx, Ty})` should depend on `n` only:

  `δ₂(n) = log₂ n - (2(n-1)/n²) log₂ (n-1) - ((n-1)/n)² · H_n`,

where `H_n` is the entropy of the product of two independent uniform non-trivial elements of
`C_n` (`1` with probability `1/(n-1)`, each other value with probability `(n-2)/(n-1)²`):

  `H_n = (1/(n-1)) log₂ (n-1) + ((n-2)/(n-1)) log₂ ((n-1)²/(n-2))`.

The general statement is left as a conjecture (`FUTURE_DIRECTIONS.md`).  Here we verify it
exactly at the two detector groups of the catalog:

* `A4_semiprime_channel` — the catalog's `A₄ = AGL(1,4)` (`n = 3`), computed over all
  `12² = 144` pairs: `I₂ = log₂ 3 - 10/9`.
* `pairDetector_three`, `pairDetector_seven` — `δ₂(3)` and `δ₂(7)` match the exact values for
  `A₄` and for `AGL(1,8)` (`SemiprimeChannel.agl8_semiprime_channel`).
* `semiprime_antitone_A4_AGL8` — at the semiprime level too, the larger abelianization
  (`C₇` against `C₃`) gives the smaller channel, by a factor of more than four.
-/

namespace AGL8

open Finset Real TypeChannel

/-- The conjectured pair-detector value `δ₂(n)`. -/
noncomputable def pairDetectorInfo (n : ℝ) : ℝ :=
  logb 2 n - 2 * (n - 1) / n ^ 2 * logb 2 (n - 1) - ((n - 1) / n) ^ 2 *
    (1 / (n - 1) * logb 2 (n - 1) + (n - 2) / (n - 1) * logb 2 ((n - 1) ^ 2 / (n - 2)))

/-! ## 1. The `A₄` semiprime channel -/

/-- The residue readout of a semiprime with `A₄` Frobenius pair: the `C₃` coset of `xy`. -/
def a4SemiCoset (z : Equiv.Perm (Fin 4) × Equiv.Perm (Fin 4)) : ℕ := pairIdx (z.1 * z.2)

/-- The unordered pair of `A₄` splitting types. -/
def a4SemiType (z : Equiv.Perm (Fin 4) × Equiv.Perm (Fin 4)) : Sym2 (ℕ × ℕ) :=
  s(splitType z.1, splitType z.2)

lemma A4sq_card : (A4 ×ˢ A4).card = 144 := by
  rw [card_product, show A4.card = 12 by decide]

lemma a4_coset_entropy : entropy (A4 ×ˢ A4) a4SemiCoset = logb 2 3 := by
  rw [entropy_eq_sumList (A := [0, 1, 2]) (L := [48, 48, 48]) (by decide)
    (by decide +kernel) (by decide +kernel), A4sq_card]
  simp only [List.map_cons, List.map_nil, List.sum_cons, List.sum_nil]
  rw [negTerm 48 144 (by norm_num) (by norm_num), lb_decomp 48 4 1 0 0 (by norm_num),
    lb_decomp 144 4 2 0 0 (by norm_num)]
  push_cast
  ring

lemma a4_type_entropy : entropy (A4 ×ˢ A4) a4SemiType =
    1 / 144 * (4 + 2 * logb 2 3) + 6 / 144 * (3 + logb 2 3) + 9 / 144 * 4
    + 16 / 144 * (2 * logb 2 3) + 48 / 144 * logb 2 3 + 64 / 144 * (2 * logb 2 3 - 2) := by
  rw [entropy_eq_sumList (A := [s((4, 0), (4, 0)), s((4, 0), (0, 4)), s((0, 4), (0, 4)),
      s((4, 0), (1, 0)), s((0, 4), (1, 0)), s((1, 0), (1, 0))])
    (L := [1, 6, 9, 16, 48, 64]) (by decide) (by decide +kernel) (by decide +kernel), A4sq_card]
  simp only [List.map_cons, List.map_nil, List.sum_cons, List.sum_nil]
  rw [negTerm 1 144 (by norm_num) (by norm_num), negTerm 6 144 (by norm_num) (by norm_num),
    negTerm 9 144 (by norm_num) (by norm_num), negTerm 16 144 (by norm_num) (by norm_num),
    negTerm 48 144 (by norm_num) (by norm_num), negTerm 64 144 (by norm_num) (by norm_num),
    lb_decomp 144 4 2 0 0 (by norm_num), lb_decomp 1 0 0 0 0 (by norm_num),
    lb_decomp 6 1 1 0 0 (by norm_num), lb_decomp 9 0 2 0 0 (by norm_num),
    lb_decomp 16 4 0 0 0 (by norm_num), lb_decomp 48 4 1 0 0 (by norm_num),
    lb_decomp 64 6 0 0 0 (by norm_num)]
  push_cast
  ring

lemma a4_joint_entropy : entropy (A4 ×ˢ A4) (pairObs a4SemiCoset a4SemiType) =
    1 / 144 * (4 + 2 * logb 2 3) + 6 / 144 * (3 + logb 2 3) + 9 / 144 * 4
    + 16 / 144 * (1 + 2 * logb 2 3) + 48 / 144 * (1 + logb 2 3)
    + 32 / 144 * (-1 + 2 * logb 2 3) + 32 / 144 * (2 * logb 2 3) := by
  rw [entropy_eq_sumList (A := [(0, s((4, 0), (4, 0))), (0, s((4, 0), (0, 4))),
      (0, s((0, 4), (0, 4))), (1, s((4, 0), (1, 0))), (2, s((4, 0), (1, 0))),
      (1, s((0, 4), (1, 0))), (2, s((0, 4), (1, 0))), (0, s((1, 0), (1, 0))),
      (1, s((1, 0), (1, 0))), (2, s((1, 0), (1, 0)))])
    (L := [1, 6, 9, 8, 8, 24, 24, 32, 16, 16]) (by decide) (by decide +kernel)
    (by decide +kernel), A4sq_card]
  simp only [List.map_cons, List.map_nil, List.sum_cons, List.sum_nil]
  rw [negTerm 1 144 (by norm_num) (by norm_num), negTerm 6 144 (by norm_num) (by norm_num),
    negTerm 9 144 (by norm_num) (by norm_num), negTerm 8 144 (by norm_num) (by norm_num),
    negTerm 24 144 (by norm_num) (by norm_num), negTerm 32 144 (by norm_num) (by norm_num),
    negTerm 16 144 (by norm_num) (by norm_num),
    lb_decomp 144 4 2 0 0 (by norm_num), lb_decomp 1 0 0 0 0 (by norm_num),
    lb_decomp 6 1 1 0 0 (by norm_num), lb_decomp 9 0 2 0 0 (by norm_num),
    lb_decomp 8 3 0 0 0 (by norm_num), lb_decomp 24 3 1 0 0 (by norm_num),
    lb_decomp 32 5 0 0 0 (by norm_num), lb_decomp 16 4 0 0 0 (by norm_num)]
  push_cast
  ring

/-- **The `A₄` semiprime channel.**  Over all 144 ordered pairs of Frobenius elements of the
catalog's `A₄` (Galois group of `x⁴ + 8x + 12`), the unordered pair of splitting types
carries `I(coset(xy) ; {Tx, Ty}) = log₂ 3 - 10/9 = 0.4739…` bits. -/
theorem A4_semiprime_channel :
    mutualInfo (A4 ×ˢ A4) a4SemiCoset a4SemiType = logb 2 3 - 10 / 9 := by
  rw [mutualInfo, a4_coset_entropy, a4_type_entropy, a4_joint_entropy]
  ring

/-! ## 2. The pair-detector formula at `n = 3` and `n = 7` -/

/-- `δ₂(3)` is the exact `A₄` semiprime channel. -/
theorem pairDetector_three :
    pairDetectorInfo 3 = mutualInfo (A4 ×ˢ A4) a4SemiCoset a4SemiType := by
  rw [A4_semiprime_channel, pairDetectorInfo]
  have h4 : logb 2 ((3 - 1 : ℝ) ^ 2 / (3 - 2)) = 2 := by
    rw [show ((3 - 1 : ℝ) ^ 2 / (3 - 2)) = 2 ^ (2 : ℕ) by norm_num, logb_pow,
      logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]
    norm_num
  have h2 : logb 2 ((3 : ℝ) - 1) = 1 := by
    rw [show ((3 : ℝ) - 1) = 2 by norm_num, logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]
  rw [h4, h2]
  norm_num
  ring

/-- `δ₂(7)` is the exact `AGL(1,8)` semiprime channel. -/
theorem pairDetector_seven :
    pairDetectorInfo 7 = mutualInfo (aglSet ×ˢ aglSet) semiCoset semiType := by
  rw [agl8_semiprime_channel, pairDetectorInfo]
  have h36 : logb 2 ((7 - 1 : ℝ) ^ 2 / (7 - 2)) = 2 * logb 2 6 - logb 2 5 := by
    rw [show ((7 - 1 : ℝ) ^ 2 / (7 - 2)) = 6 ^ (2 : ℕ) / 5 by norm_num,
      logb_div (by norm_num) (by norm_num), logb_pow]
    push_cast; ring
  have h6 : logb 2 ((7 : ℝ) - 1) = logb 2 6 := by norm_num
  rw [h36, h6]
  ring

/-- **Semiprime anti-monotonicity on the detector ladder.**  `A₄ = AGL(1,4)` (`C₃`) leaks more
than four times as much at the semiprime level as `AGL(1,8)` (`C₇`). -/
theorem semiprime_antitone_A4_AGL8 :
    4 * mutualInfo (aglSet ×ˢ aglSet) semiCoset semiType <
      mutualInfo (A4 ×ˢ A4) a4SemiCoset a4SemiType := by
  rw [A4_semiprime_channel]
  have := agl8_semiprime_bracket
  have := l3_gt
  linarith

/-- The semiprime channel of `A₄` is strictly below its prime channel (`log₂ 3 - 2/3`):
pairing loses exactly `4/9` of a bit. -/
theorem A4_pairing_loss :
    mutualInfo A4 pairIdx splitType - mutualInfo (A4 ×ˢ A4) a4SemiCoset a4SemiType = 4 / 9 := by
  rw [A4_channel, A4_semiprime_channel]
  ring

end AGL8