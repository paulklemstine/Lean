/-
# Cycle 3: universality of the matching family

The shell peeling of a Euclidean ball saturates the peeling bound, and the
`O(d)`-action on its layers exhibits the symmetry responsible for that
saturation.  A natural criticism is that this could be an artefact of the
ball: the ball is the most symmetric body there is, so of course it produces a
symmetric peeling.

This file removes that objection: the construction is *universal*.  For **any**
star-shaped body `K ⊆ ℝ^d` of finite measure the dilates
`c_k • K`, `c_k = (1 - k/N)^{1/d}`, peel `K` into `N` pieces of equal measure
`vol K / N` (`bodyPeel_gap`, `bodyLayer_volume`), and every layer is invariant
under the *entire* linear symmetry group of `K` (`bodyLayer_equivariant`).
Conversely, a dilation peeling all of whose layers have measure at most
`vol K / N` must be this one (`body_peel_rigidity`).  The ball family of the
previous file is the special case `K = B(0,1)`, where the symmetry group is
`O(d)`.

The upshot for the original question — a matching family of actions for the
peeling upper bound — is that the extremisers are parameterised by *all* pairs
`(K, G)` with `G` a group of linear symmetries of `K`: the dimension `d` fixes
the radial profile `(1 - k/N)^{1/d}`, and the body `K` is otherwise free.

## Lab notes

Cross-check in `d = 2` with `K` the unit square `[-1,1]^2` (`vol K = 4`) and
`N = 4`: dilation factors `1, √(3)/2, √(2)/2, 1/2, 0`, layer areas
`4·(1/4) = 1` each — identical factors to the disc case, as the theory
predicts: the factors depend only on `d` and `N`, never on `K`.
-/
import Geometry.PeelStabilityConcentration

namespace Catalog.Geometry.Peel

open Finset MeasureTheory Metric Pointwise

/-! ## Volumes of dilates -/

/-- The Lebesgue measure of a body of `ℝ^d`, as a real number. -/
noncomputable def bodyVol (d : ℕ) (K : Set (EuclideanSpace ℝ (Fin d))) : ℝ :=
  (volume K).toReal

lemma bodyVol_nonneg (d : ℕ) (K : Set (EuclideanSpace ℝ (Fin d))) : 0 ≤ bodyVol d K :=
  ENNReal.toReal_nonneg

lemma volume_smul_ne_top {d : ℕ} {K : Set (EuclideanSpace ℝ (Fin d))} (hK : volume K ≠ ⊤)
    {c : ℝ} (hc : 0 ≤ c) : volume (c • K) ≠ ⊤ := by
  rw [MeasureTheory.Measure.addHaar_smul_of_nonneg volume hc K]
  exact ENNReal.mul_ne_top ENNReal.ofReal_ne_top hK

/-- Scaling law: `vol (c • K) = c^d · vol K`. -/
lemma bodyVol_smul {d : ℕ} {K : Set (EuclideanSpace ℝ (Fin d))} {c : ℝ} (hc : 0 ≤ c) :
    bodyVol d (c • K) = c ^ d * bodyVol d K := by
  unfold bodyVol
  rw [MeasureTheory.Measure.addHaar_smul_of_nonneg volume hc K, finrank_euclideanSpace_fin,
    ENNReal.toReal_mul, ENNReal.toReal_ofReal (by positivity)]

/-! ## Star-shaped bodies and nested dilates -/

/-- `K` is star-shaped about the origin. -/
def StarShaped {d : ℕ} (K : Set (EuclideanSpace ℝ (Fin d))) : Prop :=
  ∀ x ∈ K, ∀ t : ℝ, 0 ≤ t → t ≤ 1 → t • x ∈ K

/-- Dilates of a star-shaped body are nested. -/
lemma smul_subset_smul_of_starShaped {d : ℕ} {K : Set (EuclideanSpace ℝ (Fin d))}
    (hK : StarShaped K) {a b : ℝ} (ha : 0 ≤ a) (hab : a ≤ b) : a • K ⊆ b • K := by
  rcases eq_or_lt_of_le (ha.trans hab) with hb | hb
  · have hb0 : b = 0 := hb.symm
    have ha0 : a = 0 := le_antisymm (hb0 ▸ hab) ha
    rw [ha0, hb0]
  · rintro x ⟨y, hy, rfl⟩
    refine ⟨(a / b) • y, hK y hy (a / b) (by positivity) ?_, ?_⟩
    · rw [div_le_one hb]; exact hab
    · show b • ((a / b) • y) = a • y
      rw [smul_smul, mul_div_cancel₀ _ hb.ne']

/-! ## The universal equal-volume dilation peeling -/

/-- The dilation factor of the `k`-th layer: `(1 - k/N)^{1/d}`, depending only
on the dimension and the number of layers. -/
noncomputable def dilationFactor (d N k : ℕ) : ℝ :=
  (max 0 (1 - (k : ℝ) / (N : ℝ))) ^ ((d : ℝ)⁻¹)

lemma dilationFactor_nonneg (d N k : ℕ) : 0 ≤ dilationFactor d N k :=
  Real.rpow_nonneg (le_max_left _ _) _

lemma dilationFactor_anti (d N : ℕ) : Antitone (dilationFactor d N) := by
  intro a b hab
  have hcast : (a : ℝ) ≤ b := by exact_mod_cast hab
  have hmono : max 0 (1 - (b : ℝ) / N) ≤ max 0 (1 - (a : ℝ) / N) := by
    refine max_le_max (le_refl 0) ?_
    rcases Nat.eq_zero_or_pos N with h | h
    · subst h; simp
    · have hNR : (0 : ℝ) < N := by exact_mod_cast h
      have : (a : ℝ) / N ≤ b / N := by gcongr
      linarith
  exact Real.rpow_le_rpow (le_max_left _ _) hmono (by positivity)

lemma dilationFactor_pow {d N k : ℕ} (hd : 0 < d) :
    (dilationFactor d N k) ^ d = max 0 (1 - (k : ℝ) / (N : ℝ)) :=
  Real.rpow_inv_natCast_pow (le_max_left _ _) hd.ne'

@[simp] lemma dilationFactor_zero (d N : ℕ) : dilationFactor d N 0 = 1 := by
  simp [dilationFactor]

lemma dilationFactor_last {d N : ℕ} (hd : 0 < d) (hN : 0 < N) : dilationFactor d N N = 0 := by
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  have hd' : ((d : ℝ)⁻¹) ≠ 0 := by
    have : (0 : ℝ) < d := by exact_mod_cast hd
    positivity
  simp [dilationFactor, div_self hNR.ne', Real.zero_rpow hd']

/-- The peeling profile of the dilation family of a body `K`. -/
noncomputable def bodyPeel (d : ℕ) (K : Set (EuclideanSpace ℝ (Fin d))) (N : ℕ) : PeelProfile :=
  equipartitionProfile (bodyVol d K) (bodyVol_nonneg d K) N

/-- **The geometric identity, universal form.**  The abstract profile of the
dilation peeling is the sequence of measures of the dilates `c_k • K`. -/
theorem bodyPeel_size (d N k : ℕ) (hd : 0 < d) (K : Set (EuclideanSpace ℝ (Fin d))) :
    (bodyPeel d K N).size k = bodyVol d ((dilationFactor d N k) • K) := by
  rw [bodyVol_smul (dilationFactor_nonneg d N k), dilationFactor_pow hd]
  show bodyVol d K * max 0 (1 - (k : ℝ) / (N : ℝ))
      = max 0 (1 - (k : ℝ) / (N : ℝ)) * bodyVol d K
  ring

lemma bodyPeel_rate (d N : ℕ) (hN : 0 < N) (K : Set (EuclideanSpace ℝ (Fin d))) :
    peelRate (bodyPeel d K N) N = bodyVol d K / N :=
  equipartitionProfile_rate (bodyVol_nonneg d K) hN

/-- **Equal measures for an arbitrary body.**  Every one of the `N` dilation
layers of `K` has measure `vol K / N`. -/
theorem bodyPeel_gap (d N k : ℕ) (hN : 0 < N) (hk : k < N)
    (K : Set (EuclideanSpace ℝ (Fin d))) :
    peelGap (bodyPeel d K N) k = bodyVol d K / N :=
  equipartitionProfile_gap (bodyVol_nonneg d K) hN hk

/-- The `k`-th layer of the dilation peeling of `K`. -/
noncomputable def bodyLayer (d : ℕ) (K : Set (EuclideanSpace ℝ (Fin d))) (N k : ℕ) :
    Set (EuclideanSpace ℝ (Fin d)) :=
  (dilationFactor d N k) • K \ (dilationFactor d N (k + 1)) • K

/-- **Universal equivariance.**  Every layer of the dilation peeling is
invariant under every linear isometry preserving `K`; for `K` a ball this is
the full orthogonal group. -/
theorem bodyLayer_equivariant (d N k : ℕ) (K : Set (EuclideanSpace ℝ (Fin d)))
    (e : EuclideanSpace ℝ (Fin d) ≃ₗᵢ[ℝ] EuclideanSpace ℝ (Fin d)) (he : e '' K = K) :
    e '' bodyLayer d K N k = bodyLayer d K N k := by
  have himg : ∀ c : ℝ, e '' (c • K) = c • K := by
    intro c
    have hcomm : e '' (c • K) = c • (e '' K) := by
      ext y
      simp only [Set.mem_image, Set.mem_smul_set]
      constructor
      · rintro ⟨x, ⟨z, hz, rfl⟩, rfl⟩
        exact ⟨e z, ⟨z, hz, rfl⟩, by simp⟩
      · rintro ⟨x, ⟨z, hz, rfl⟩, rfl⟩
        exact ⟨c • z, ⟨z, hz, rfl⟩, by simp⟩
    rw [hcomm, he]
  rw [bodyLayer, Set.image_diff e.injective, himg, himg]

/-- **The layer really has measure `vol K / N`.**  For a measurable
star-shaped body of finite measure, the set-theoretic layer
`c_k • K \ c_{k+1} • K` has measure exactly `vol K / N`. -/
theorem bodyLayer_volume (d N k : ℕ) (hd : 0 < d) (hN : 0 < N) (hk : k < N)
    {K : Set (EuclideanSpace ℝ (Fin d))} (hmeas : MeasurableSet K) (hfin : volume K ≠ ⊤)
    (hstar : StarShaped K) :
    (volume (bodyLayer d K N k)).toReal = bodyVol d K / N := by
  have hsub : (dilationFactor d N (k + 1)) • K ⊆ (dilationFactor d N k) • K :=
    smul_subset_smul_of_starShaped hstar (dilationFactor_nonneg d N (k + 1))
      (dilationFactor_anti d N (Nat.le_succ k))
  have hnull : NullMeasurableSet ((dilationFactor d N (k + 1)) • K) volume := by
    rcases eq_or_ne (dilationFactor d N (k + 1)) 0 with hc | hc
    · rcases K.eq_empty_or_nonempty with hKe | hne
      · rw [hKe]; simp
      · rw [hc, Set.zero_smul_set hne]
        exact (measurableSet_singleton 0).nullMeasurableSet
    · exact (hmeas.const_smul₀ _).nullMeasurableSet
  have hfin' : volume ((dilationFactor d N (k + 1)) • K) ≠ ⊤ :=
    volume_smul_ne_top hfin (dilationFactor_nonneg d N (k + 1))
  have hdiff : volume (bodyLayer d K N k)
      = volume ((dilationFactor d N k) • K) - volume ((dilationFactor d N (k + 1)) • K) :=
    measure_diff hsub hnull hfin'
  rw [hdiff, ENNReal.toReal_sub_of_le (measure_mono hsub)
    (volume_smul_ne_top hfin (dilationFactor_nonneg d N k))]
  have h1 : bodyVol d ((dilationFactor d N k) • K) = (bodyPeel d K N).size k :=
    (bodyPeel_size d N k hd K).symm
  have h2 : bodyVol d ((dilationFactor d N (k + 1)) • K) = (bodyPeel d K N).size (k + 1) :=
    (bodyPeel_size d N (k + 1) hd K).symm
  show bodyVol d ((dilationFactor d N k) • K)
      - bodyVol d ((dilationFactor d N (k + 1)) • K) = bodyVol d K / N
  rw [h1, h2]
  exact bodyPeel_gap d N k hN hk K

/-! ## Rigidity for arbitrary bodies -/

/-- The peeling profile attached to a dilation family of a star-shaped body. -/
noncomputable def dilationProfile (d : ℕ) (K : Set (EuclideanSpace ℝ (Fin d)))
    (c : ℕ → ℝ) (hanti : Antitone c) (hnn : ∀ k, 0 ≤ c k) : PeelProfile where
  size k := bodyVol d ((c k) • K)
  anti := by
    intro a b hab
    show bodyVol d ((c b) • K) ≤ bodyVol d ((c a) • K)
    rw [bodyVol_smul (hnn a), bodyVol_smul (hnn b)]
    have : c b ^ d ≤ c a ^ d := pow_le_pow_left₀ (hnn b) (hanti hab) d
    nlinarith [bodyVol_nonneg d K]
  nonneg := fun _ => bodyVol_nonneg d _

/-- **Universal rigidity.**  For a body of positive finite measure, a dilation
peeling all of whose layers have measure at most `vol K / N` is forced to be
the equal-measure one: the dilation factors must be `(1 - k/N)^{1/d}`.  This
contains `ball_peel_rigidity` as the case `K = B(0,1)`. -/
theorem body_peel_rigidity (d N : ℕ) (hd : 0 < d) (hN : 0 < N)
    {K : Set (EuclideanSpace ℝ (Fin d))} (hpos : 0 < bodyVol d K)
    (c : ℕ → ℝ) (hanti : Antitone c) (hnn : ∀ k, 0 ≤ c k) (h0 : c 0 = 1) (hlast : c N = 0)
    (hsmall : ∀ k < N, bodyVol d ((c k) • K) - bodyVol d ((c (k + 1)) • K) ≤ bodyVol d K / N) :
    ∀ k ≤ N, c k = dilationFactor d N k := by
  set P := dilationProfile d K c hanti hnn with hP
  have hsize : ∀ k, P.size k = bodyVol d ((c k) • K) := fun _ => rfl
  have hzero : bodyVol d ((c 0) • K) = bodyVol d K := by
    rw [h0]; simp [bodyVol]
  have hlast' : bodyVol d ((c N) • K) = 0 := by
    rw [hlast, bodyVol_smul (le_refl 0)]
    simp [hd.ne']
  have hbudget : peelBudget P N = bodyVol d K := by
    simp only [peelBudget, hsize, hzero, hlast', sub_zero]
  have hrate : peelRate P N = bodyVol d K / N := by rw [peelRate, hbudget]
  have h1 : ∀ k < N, peelGap P k ≤ peelRate P N := by
    intro k hk
    rw [hrate, peelGap, hsize, hsize]
    exact hsmall k hk
  have h3 := ((peel_extremal_tfae P hN).out 0 2).1 h1
  intro k hk
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  have hkN : (k : ℝ) ≤ N := by exact_mod_cast hk
  have hnneg : (0 : ℝ) ≤ 1 - (k : ℝ) / N := by
    rw [sub_nonneg, div_le_one hNR]; exact hkN
  -- the volume identity forces the `d`-th powers of the factors to agree
  have hvol : c k ^ d * bodyVol d K = (dilationFactor d N k) ^ d * bodyVol d K := by
    have hleft : bodyVol d ((c k) • K) = c k ^ d * bodyVol d K := bodyVol_smul (hnn k)
    have hstep := h3 k hk
    rw [hsize, hleft, hsize, hzero, hrate] at hstep
    rw [hstep, dilationFactor_pow hd, max_eq_right hnneg]
    field_simp
  have hpow : c k ^ d = (dilationFactor d N k) ^ d :=
    mul_right_cancel₀ hpos.ne' hvol
  rcases lt_trichotomy (c k) (dilationFactor d N k) with hlt | heq | hgt
  · have := pow_lt_pow_left₀ hlt (hnn k) hd.ne'; linarith
  · exact heq
  · have := pow_lt_pow_left₀ hgt (dilationFactor_nonneg d N k) hd.ne'; linarith

/-- **The matching family, final form.**  For every dimension `d ≥ 1`, every
star-shaped measurable body `K` of finite measure and every `N ≥ 1`, the
dilation peeling of `K` has all `N` layers of equal measure `vol K / N`, is
invariant under the entire linear symmetry group of `K`, and its profile is
exactly the arithmetic one — so it saturates `exists_peel_stopping_time` at
every single step. -/
theorem bodyPeel_matching_family (d N : ℕ) (hd : 0 < d) (hN : 0 < N)
    {K : Set (EuclideanSpace ℝ (Fin d))} (hmeas : MeasurableSet K) (hfin : volume K ≠ ⊤)
    (hstar : StarShaped K) :
    (∀ k < N, (volume (bodyLayer d K N k)).toReal = peelRate (bodyPeel d K N) N) ∧
      (∀ (e : EuclideanSpace ℝ (Fin d) ≃ₗᵢ[ℝ] EuclideanSpace ℝ (Fin d)), e '' K = K →
        ∀ k, e '' bodyLayer d K N k = bodyLayer d K N k) ∧
      (∀ k ≤ N, (bodyPeel d K N).size k
        = (bodyPeel d K N).size 0 - k * peelRate (bodyPeel d K N) N) := by
  refine ⟨fun k hk => ?_, fun e he k => bodyLayer_equivariant d N k K e he, ?_⟩
  · rw [bodyLayer_volume d N k hd hN hk hmeas hfin hstar, bodyPeel_rate d N hN K]
  · exact ((peel_extremal_tfae (bodyPeel d K N) hN).out 1 2).1
      (equipartitionProfile_extremal (bodyVol_nonneg d K) hN)

end Catalog.Geometry.Peel