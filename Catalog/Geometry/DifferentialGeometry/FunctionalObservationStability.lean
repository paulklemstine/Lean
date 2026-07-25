import Mathlib

/-!
# Robust functional observation: a bridge to statistical reconstruction

A functional observation `F : X → B` may send two states close together while an
experience observable `E : X → Y` keeps them far apart.  Any Lipschitz decoder
`R : B → Y` must then pay reconstruction error.  The theorem below identifies this
obstruction quantitatively and interprets the average error on the two states as the
risk under their uniform two-point probability distribution.

Unlike the exact fibre obstruction, the result is stable: an observation discrepancy
of at most `ε` can explain at most `K ε` of the experiential contrast when the decoder
is `K`-Lipschitz.  Everything else is forced into reconstruction risk.
-/

namespace FunctionalObservationStability

/-- Mean absolute reconstruction loss for the uniform probability distribution on two
states.  This is the expected metric loss of a decoder on that two-point experiment. -/
noncomputable def pairRisk {X B Y : Type*} [PseudoMetricSpace Y]
    (F : X → B) (E : X → Y) (R : B → Y) (x z : X) : ℝ :=
  (dist (E x) (R (F x)) + dist (E z) (R (F z))) / 2

/-- **Robust fibre–risk bridge.**  If two states have functional distance at most
`ε` but experiential contrast at least `δ`, every `K`-Lipschitz reconstruction has
uniform two-point expected loss at least `(δ - K ε) / 2`.

This connects the geometry of fibres and approximate fibres with a lower bound in
statistical decision theory.  No compactness assumption is required, so the result
also applies to compact metric state spaces as a special case. -/
theorem pairRisk_lower_bound
    {X B Y : Type*} [PseudoMetricSpace B] [PseudoMetricSpace Y]
    (F : X → B) (E : X → Y) (R : B → Y) {x z : X} {K : NNReal} {ε δ : ℝ}
    (hR : LipschitzWith K R)
    (hF : dist (F x) (F z) ≤ ε)
    (hE : δ ≤ dist (E x) (E z)) :
    (δ - (K : ℝ) * ε) / 2 ≤ pairRisk F E R x z := by
  have hdecoder : dist (R (F x)) (R (F z)) ≤ (K : ℝ) * ε :=
    hR.dist_le_mul_of_le hF
  have hchain : dist (E x) (E z) ≤
      dist (E x) (R (F x)) + dist (R (F x)) (R (F z)) +
        dist (R (F z)) (E z) :=
    dist_triangle4 _ _ _ _
  rw [dist_comm (R (F z)) (E z)] at hchain
  unfold pairRisk
  linarith

/-- Exact functional identity is the zero-noise endpoint: half of the experiential
contrast must appear as expected reconstruction loss, independently of the decoder's
Lipschitz constant. -/
theorem exact_fibre_pairRisk_lower_bound
    {X B Y : Type*} [PseudoMetricSpace B] [PseudoMetricSpace Y]
    (F : X → B) (E : X → Y) (R : B → Y) {x z : X} {δ : ℝ}
    (hF : F x = F z)
    (hE : δ ≤ dist (E x) (E z)) :
    δ / 2 ≤ pairRisk F E R x z := by
  have hchain := dist_triangle (E x) (R (F x)) (E z)
  rw [hF, dist_comm (R (F z)) (E z)] at hchain
  unfold pairRisk
  rw [hF]
  linarith

/-- A pointwise form: at least one member of an exact functional fibre incurs at
least half the hidden experiential contrast. -/
theorem exact_fibre_max_error_lower_bound
    {X B Y : Type*} [PseudoMetricSpace B] [PseudoMetricSpace Y]
    (F : X → B) (E : X → Y) (R : B → Y) {x z : X} {δ : ℝ}
    (hF : F x = F z)
    (hE : δ ≤ dist (E x) (E z)) :
    δ / 2 ≤ max (dist (E x) (R (F x))) (dist (E z) (R (F z))) := by
  have hchain := dist_triangle (E x) (R (F x)) (E z)
  rw [hF] at hchain
  have hmax1 : dist (E x) (R (F z)) ≤
      max (dist (E x) (R (F z))) (dist (E z) (R (F z))) := le_max_left _ _
  have hmax2 : dist (E z) (R (F z)) ≤
      max (dist (E x) (R (F z))) (dist (E z) (R (F z))) := le_max_right _ _
  rw [dist_comm (R (F z)) (E z)] at hchain
  rw [hF]
  linarith

end FunctionalObservationStability