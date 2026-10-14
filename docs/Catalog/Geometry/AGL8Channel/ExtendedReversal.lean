import Geometry.AGL8Channel.DetectorLaw
import MachineLearning.QuinticTypeChannel.PairLaw

/-!
# The extended reversal: the largest cap of the catalog, the smallest channel

This file places `AGL(1,8)` in the catalog's machine-checked law table
(`Cryptography.NonabelianTypeChannel.Fields`: `S₃, S₄, A₄, D₄, V₄, C₄`) and against the
catalog's semiprime pair law (`MachineLearning.QuinticTypeChannel.PairLaw`: `D₅`).

* `agl8_largest_cap_smallest_channel` — every catalog group has a strictly smaller
  abelianization cap (`≤ 2` bits, against `log₂ 7 > 2.8`) *and* a strictly larger prime
  channel than `AGL(1,8)`.
* `agl8_smallest_cap_fraction` — the fraction of the cap realised by `AGL(1,8)` (`< 21.1 %`)
  is strictly below that of every catalog group (the smallest of which is `V₄`, `> 40 %`).
* `agl8_semiprime_below_D5` — at the semiprime level, the catalog's `D₅` pair channel
  (`|G^ab| = 2`, one bit) beats `AGL(1,8)` (`|G^ab| = 7`, `0.114` bits) by a factor `> 8`.
* `not_monotone_in_abelianization` — packaged: neither the prime nor the semiprime channel
  is monotone in the order of the abelianization.
-/

namespace AGL8

open Real TypeChannel

/-- **Largest cap, smallest channel.**  Against each of the six groups of the catalog's law
table, `AGL(1,8)` has the strictly larger cap and the strictly smaller channel. -/
theorem agl8_largest_cap_smallest_channel :
    (2 : ℝ) < entropy aglSet aglCoset ∧
    mutualInfo aglSet aglCoset aglType < mutualInfo S3 signIdx splitType ∧
    mutualInfo aglSet aglCoset aglType < mutualInfo S4 signIdx splitType ∧
    mutualInfo aglSet aglCoset aglType < mutualInfo A4 pairIdx splitType ∧
    mutualInfo aglSet aglCoset aglType < mutualInfo D4 d4Idx splitType ∧
    mutualInfo aglSet aglCoset aglType < mutualInfo V4 rootIdx splitType ∧
    mutualInfo aglSet aglCoset aglType < mutualInfo C4 rootIdx splitType := by
  rw [agl8_cap, S3_channel, S4_channel, D4_channel, V4_channel, C4_channel]
  have hA := agl8_below_A4
  have hb := agl8_prime_bracket
  have := l3_gt; have := l3_lt; have := l7_gt
  refine ⟨by linarith, by linarith, by linarith, hA, by linarith, by linarith, by linarith⟩

/-- **Smallest realised fraction.**  `AGL(1,8)` realises less than `21.1 %` of its cap; every
catalog group realises more than `40 %` of its own (`V₄`: `(2 - (3/4) log₂ 3)/2 > 0.4`;
`A₄`: `(log₂ 3 - 2/3)/log₂ 3 > 0.57`; `D₄, C₄, S₃, S₄`: more still). -/
theorem agl8_smallest_cap_fraction :
    mutualInfo aglSet aglCoset aglType / entropy aglSet aglCoset < 0.211 ∧
    (0.4 : ℝ) < mutualInfo V4 rootIdx splitType / 2 ∧
    (0.57 : ℝ) < mutualInfo A4 pairIdx splitType / entropy A4 pairIdx ∧
    (0.8 : ℝ) < mutualInfo D4 d4Idx splitType / entropy D4 d4Idx ∧
    (0.7 : ℝ) < mutualInfo C4 rootIdx splitType / 2 ∧
    mutualInfo S4 signIdx splitType / 1 = 1 := by
  have hf := agl8_prime_fraction
  rw [V4_channel, A4_channel, A4_entropy_coset, D4_channel, D4_entropy_coset, C4_channel,
    S4_channel]
  have := l3_gt; have := l3_lt
  have h3 : (0 : ℝ) < logb 2 3 := by linarith
  refine ⟨by linarith, by linarith, ?_, by linarith, by norm_num, by norm_num⟩
  rw [lt_div_iff₀ h3]; linarith

/-- **The semiprime reversal against `D₅`.**  The catalog's pair law gives the dihedral
quintic `D₅` (abelianization `C₂`, cap one bit) a full one-bit semiprime channel;
`AGL(1,8)` (abelianization `C₇`, cap `log₂ 7`) transmits less than an eighth of that. -/
theorem agl8_semiprime_below_D5 :
    8 * mutualInfo (aglSet ×ˢ aglSet) semiCoset semiType <
      (PairLaw.pairTable DihedralD5.typeObs PairLaw.D5.cosetHom).mutualInfo := by
  rw [PairLaw.D5.pair_mutualInfo]
  have := agl8_semiprime_bracket
  linarith

/-- **Not monotone in the abelianization.**  There are groups `X` (namely `A₄` at the prime
level and `D₅` at the semiprime level) whose abelianization is strictly smaller than
`AGL(1,8)`'s `C₇` while their channel is strictly larger. -/
theorem not_monotone_in_abelianization :
    (A4.image pairIdx).card < (aglSet.image aglCoset).card ∧
      mutualInfo aglSet aglCoset aglType < mutualInfo A4 pairIdx splitType ∧
    Fintype.card (Multiplicative (ZMod 2)) < (aglSet.image aglCoset).card ∧
      mutualInfo (aglSet ×ˢ aglSet) semiCoset semiType <
        (PairLaw.pairTable DihedralD5.typeObs PairLaw.D5.cosetHom).mutualInfo := by
  have himg : (A4.image pairIdx).card = 3 := by decide
  have h8 := agl8_semiprime_below_D5
  have hpos := agl8_chain.1
  refine ⟨?_, agl8_below_A4, ?_, by linarith⟩
  · rw [himg, aglCoset_image_card]; norm_num
  · rw [PairLaw.D5.card_C2, aglCoset_image_card]; norm_num

end AGL8