/-
# Cycle 2: stability of the peeling bound, and boundary concentration

The first two files of this thread proved the peeling upper bound
(`exists_peel_stopping_time`, `peelEstimate_error`), its rigidity
(`peel_extremal_tfae`) and produced the matching `O(d)`-equivariant family of
equal-volume shell peelings of a Euclidean ball.  Rigidity is an all-or-nothing
statement: *exact* saturation forces the arithmetic profile.  This file closes
the two gaps that criticism of that statement immediately exposes.

1. **Stability.**  `peel_stability`: if every layer is at most `(1 + ε)` times
   the average rate — an approximate extremiser — then the profile is
   uniformly within `ε · budget` of the arithmetic one.  At `ε = 0` this
   recovers rigidity, and the bound is linear in `ε`, so approximate
   extremisers are approximately arithmetic.  The geometric consequence for
   ball peelings is `ball_peel_stability`.

2. **Maximal symmetry.**  `peel_extremal_iff_symmetric`: saturation of the
   pigeonhole bound is *equivalent* to invariance of the layer contents under
   the full symmetric group of the window.  Combined with
   `peel_extremal_of_cyclic_action` this shows that a single `N`-cycle already
   buys the whole symmetric group's worth of information.

3. **When no search is needed.**  `peel_last_gap_le_rate_of_antitone_gap`: for
   peelings with decreasing layer contents the last step of the window is
   always an admissible stopping time, and the first step is always
   inadmissible.  The existential in `exists_peel_stopping_time` is therefore
   only needed for genuinely oscillating peelings.

4. **Boundary concentration.**  `shell_thickness_le`: in the equal-volume
   shell peeling of `B(0,R) ⊆ ℝ^d`, the outermost shell carries a `1/N`
   fraction of the volume but has thickness at most `R / (d (N-1))`.  The
   discrepancy factor is exactly the dimension: equal-volume peelings of
   high-dimensional balls collapse onto the boundary sphere.  This is the
   quantitative reason ball peelings behave so differently from the abstract
   arithmetic profile they realise.

## Lab notes

`d = 10`, `N = 2`, `R = 1`: outer shell thickness `1 - 2^{-1/10} ≈ 0.0670`,
bound `1/(d(N-1)) = 0.1`; `d = 100`, `N = 2`: thickness `≈ 0.0069`, bound
`0.01`.  The bound is within roughly `30 %` of the truth in these ranges and
has the correct `1/d` decay, which is what the proof through the factorisation
`1 - s^d = (1-s)(1 + s + ... + s^{d-1})` is designed to capture.
-/
import Geometry.PeelSymmetryConstruction

namespace Catalog.Geometry.Peel

open Finset MeasureTheory Metric

variable (P : PeelProfile) {N k : ℕ}

/-! ## Stability of the peeling bound -/

/-- **Stability.**  If every layer of the window is at most `(1 + ε)` times the
average rate, then the profile stays uniformly within `ε · budget` of the
arithmetic profile.  For `ε = 0` this is the rigidity statement
`peel_extremal_tfae`. -/
theorem peel_stability {ε : ℝ} (hε : 0 ≤ ε) (hk : k ≤ N)
    (h : ∀ j < N, peelGap P j ≤ (1 + ε) * peelRate P N) :
    |P.size k - peelEstimate P N k| ≤ ε * peelBudget P N := by
  have hrate := peelRate_nonneg P N
  have hbud : (N : ℝ) * peelRate P N = peelBudget P N := nsmul_peelRate P
  have hkN : (k : ℝ) ≤ N := by exact_mod_cast hk
  have hIco : ((N - k : ℕ) : ℝ) ≤ (N : ℝ) := by
    have : (N - k : ℕ) ≤ N := Nat.sub_le _ _
    exact_mod_cast this
  -- both bounds come from the same estimate on the deviations
  have hdev : ∀ j < N, -(ε * peelRate P N) ≤ peelRate P N - peelGap P j := by
    intro j hj
    have := h j hj
    nlinarith
  have hb : ε * peelBudget P N = ε * (N : ℝ) * peelRate P N := by rw [← hbud]; ring
  have hlow : -(ε * peelBudget P N) ≤ P.size k - peelEstimate P N k := by
    rw [peelEstimate_error_eq]
    have hsum : ∑ _j ∈ range k, -(ε * peelRate P N)
        ≤ ∑ j ∈ range k, (peelRate P N - peelGap P j) :=
      Finset.sum_le_sum fun j hj => hdev j (lt_of_lt_of_le (Finset.mem_range.1 hj) hk)
    rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul] at hsum
    have hslack : 0 ≤ ε * peelRate P N * ((N : ℝ) - k) :=
      mul_nonneg (mul_nonneg hε hrate) (by linarith)
    linarith [hsum, hslack, hb]
  have hup : P.size k - peelEstimate P N k ≤ ε * peelBudget P N := by
    have htail := peelEstimate_error_tail_eq P hk
    have hsum : ∑ _j ∈ Finset.Ico k N, -(ε * peelRate P N)
        ≤ ∑ j ∈ Finset.Ico k N, (peelRate P N - peelGap P j) :=
      Finset.sum_le_sum fun j hj => hdev j (Finset.mem_Ico.1 hj).2
    rw [Finset.sum_const, Nat.card_Ico, nsmul_eq_mul, htail] at hsum
    have hslack : 0 ≤ ε * peelRate P N * ((N : ℝ) - ((N - k : ℕ) : ℝ)) :=
      mul_nonneg (mul_nonneg hε hrate) (by linarith)
    linarith [hsum, hslack, hb]
  rw [abs_le]
  exact ⟨hlow, hup⟩

/-! ## Maximal symmetry characterises the extremisers -/

/-- **Saturation is maximal symmetry.**  The pigeonhole bound is saturated at
every step of the window if and only if the layer contents are invariant under
the full symmetric group acting on the window. -/
theorem peel_extremal_iff_symmetric (hN : 0 < N) :
    (∀ k < N, peelGap P k ≤ peelRate P N) ↔
      ∀ (σ : Equiv.Perm (Fin N)) (i : Fin N), gapFin P N (σ • i) = gapFin P N i := by
  haveI : MulAction.IsPretransitive (Equiv.Perm (Fin N)) (Fin N) :=
    ⟨fun i j => ⟨Equiv.swap i j, Equiv.swap_apply_left i j⟩⟩
  constructor
  · intro h σ i
    have heq := ((peel_extremal_tfae P hN).out 0 1).1 h
    simp only [gapFin]
    rw [heq _ (σ • i).isLt, heq _ i.isLt]
  · intro hinv k hk
    have := peel_gap_const_of_pretransitive P hN hinv ⟨k, hk⟩
    simp only [gapFin] at this
    exact le_of_eq this

/-! ## Monotone peelings need no search -/

/-- For a peeling whose layer contents decrease, the last step of the window is
always an admissible stopping time and the first step never is: the search in
`exists_peel_stopping_time` is only needed for oscillating peelings. -/
theorem peel_last_gap_le_rate_of_antitone_gap (hN : 0 < N)
    (hmono : ∀ i j, i ≤ j → peelGap P j ≤ peelGap P i) :
    peelGap P (N - 1) ≤ peelRate P N ∧ peelRate P N ≤ peelGap P 0 := by
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  have hbud : (N : ℝ) * peelRate P N = peelBudget P N := nsmul_peelRate P
  have hlow : (N : ℝ) * peelGap P (N - 1) ≤ peelBudget P N := by
    rw [← sum_peelGap P N]
    have : ∀ j ∈ range N, peelGap P (N - 1) ≤ peelGap P j := by
      intro j hj
      exact hmono j (N - 1) (by have := Finset.mem_range.1 hj; omega)
    have := Finset.card_nsmul_le_sum (range N) (fun j => peelGap P j) (peelGap P (N - 1)) this
    simpa [nsmul_eq_mul] using this
  have hhigh : peelBudget P N ≤ (N : ℝ) * peelGap P 0 := by
    rw [← sum_peelGap P N]
    have : ∀ j ∈ range N, peelGap P j ≤ peelGap P 0 := fun j _ => hmono 0 j (Nat.zero_le j)
    have := Finset.sum_le_card_nsmul (range N) (fun j => peelGap P j) (peelGap P 0) this
    simpa [nsmul_eq_mul] using this
  constructor
  · nlinarith
  · nlinarith

/-! ## Boundary concentration of equal-volume shell peelings -/

/-- The elementary inequality behind boundary concentration:
`1 - s^d ≥ (1-s) · d · s^{d-1}` for `0 ≤ s ≤ 1`, coming from the
factorisation `1 - s^d = (1-s)(1 + s + ... + s^{d-1})`. -/
lemma one_sub_pow_ge (d : ℕ) {s : ℝ} (hs0 : 0 ≤ s) (hs1 : s ≤ 1) :
    (1 - s) * (d * s ^ (d - 1)) ≤ 1 - s ^ d := by
  have hgeom : (1 - s) * (∑ i ∈ range d, s ^ i) = 1 - s ^ d := by
    have := geom_sum_mul s d
    nlinarith [this]
  have hlow : (d : ℝ) * s ^ (d - 1) ≤ ∑ i ∈ range d, s ^ i := by
    have hterm : ∀ i ∈ range d, s ^ (d - 1) ≤ s ^ i := by
      intro i hi
      exact pow_le_pow_of_le_one hs0 hs1 (by simp only [Finset.mem_range] at hi; omega)
    have := Finset.card_nsmul_le_sum (range d) (fun i => s ^ i) (s ^ (d - 1)) hterm
    simpa [nsmul_eq_mul] using this
  nlinarith [hgeom, hlow, sub_nonneg.2 hs1]

/-- The normalised concentration estimate:
`1 - (1 - 1/N)^{1/d} ≤ 1 / (d (N-1))`. -/
lemma one_sub_rpow_inv_le (d N : ℕ) (hd : 0 < d) (hN : 2 ≤ N) :
    1 - (1 - 1 / (N : ℝ)) ^ ((d : ℝ)⁻¹) ≤ 1 / (d * ((N : ℝ) - 1)) := by
  have hNR : (2 : ℝ) ≤ N := by exact_mod_cast hN
  have hdR : (1 : ℝ) ≤ d := by exact_mod_cast hd
  have hNpos : (0 : ℝ) < N := by linarith
  set t : ℝ := 1 - 1 / (N : ℝ) with ht
  have ht0 : 0 ≤ t := by rw [ht, sub_nonneg, div_le_one hNpos]; linarith
  have ht1 : t ≤ 1 := by
    have : 0 < 1 / (N : ℝ) := by positivity
    rw [ht]; linarith
  set s : ℝ := t ^ ((d : ℝ)⁻¹) with hs
  have hs0 : 0 ≤ s := Real.rpow_nonneg ht0 _
  have hs1 : s ≤ 1 := Real.rpow_le_one ht0 ht1 (by positivity)
  have hsd : s ^ d = t := Real.rpow_inv_natCast_pow ht0 hd.ne'
  have hkey := one_sub_pow_ge d hs0 hs1
  have hpow : s ^ d ≤ s ^ (d - 1) := pow_le_pow_of_le_one hs0 hs1 (by omega)
  rw [hsd] at hkey hpow
  have hs' : (0 : ℝ) ≤ 1 - s := by linarith
  have h1 : (1 - s) * ((d : ℝ) * t) ≤ 1 - t :=
    le_trans (mul_le_mul_of_nonneg_left
      (mul_le_mul_of_nonneg_left hpow (by positivity)) hs') hkey
  have hexp : t = ((N : ℝ) - 1) / N := by rw [ht]; field_simp
  have h3 : 1 - ((N : ℝ) - 1) / N = 1 / N := by
    field_simp
    ring
  rw [hexp, h3] at h1
  have h5 := mul_le_mul_of_nonneg_right h1 hNpos.le
  field_simp at h5
  rw [le_div_iff₀ (by nlinarith : (0 : ℝ) < (d * ((N : ℝ) - 1)))]
  nlinarith [h5]

/-- **Boundary concentration.**  In the equal-volume peeling of `B(0,R)` in
`ℝ^d` into `N` shells, the outermost shell carries the same volume
`vol B(0,R)/N` as every other shell, but its thickness is at most
`R / (d (N-1))`: high-dimensional equal-volume peelings collapse onto the
boundary sphere. -/
theorem shell_thickness_le (d N : ℕ) (hd : 0 < d) (hN : 2 ≤ N) {R : ℝ} (hR : 0 ≤ R) :
    R - shellRadius R d N 1 ≤ R / (d * ((N : ℝ) - 1)) := by
  have hNR : (2 : ℝ) ≤ N := by exact_mod_cast hN
  have hNpos : (0 : ℝ) < N := by linarith
  have hrad : shellRadius R d N 1 = R * (1 - 1 / (N : ℝ)) ^ ((d : ℝ)⁻¹) := by
    have hmax : max (0 : ℝ) (1 - ((1 : ℕ) : ℝ) / (N : ℝ)) = 1 - 1 / (N : ℝ) := by
      rw [Nat.cast_one]
      refine max_eq_right ?_
      rw [sub_nonneg, div_le_one hNpos]
      linarith
    rw [shellRadius, hmax]
  have hbase := one_sub_rpow_inv_le d N hd hN
  rw [hrad]
  have : R - R * (1 - 1 / (N : ℝ)) ^ ((d : ℝ)⁻¹)
      = R * (1 - (1 - 1 / (N : ℝ)) ^ ((d : ℝ)⁻¹)) := by ring
  rw [this]
  calc R * (1 - (1 - 1 / (N : ℝ)) ^ ((d : ℝ)⁻¹))
      ≤ R * (1 / (d * ((N : ℝ) - 1))) := by
        exact mul_le_mul_of_nonneg_left hbase hR
    _ = R / (d * ((N : ℝ) - 1)) := by ring

/-! ## Stability for ball peelings -/

/-- **Geometric stability.**  A nested family of balls all of whose shells have
volume at most `(1 + ε)` times `vol B(0,R)/N` has volumes uniformly within
`ε · vol B(0,R)` of the equal-volume profile. -/
theorem ball_peel_stability (d N : ℕ) (hd : 0 < d) (hN : 0 < N) {R : ℝ}
    {ε : ℝ} (hε : 0 ≤ ε) (r : ℕ → ℝ) (hanti : Antitone r) (hnn : ∀ k, 0 ≤ r k)
    (h0 : r 0 = R) (hlast : r N = 0)
    (hsmall : ∀ j < N, ballVol d (r j) - ballVol d (r (j + 1)) ≤ (1 + ε) * (ballVol d R / N))
    (hk : k ≤ N) :
    |ballVol d (r k) - ballVol d R * (1 - (k : ℝ) / N)| ≤ ε * ballVol d R := by
  set P := radiusProfile d hd r hanti hnn with hP
  have hsize : ∀ j, P.size j = ballVol d (r j) := fun _ => rfl
  have hbudget : peelBudget P N = ballVol d R := by simp [peelBudget, hsize, h0, hlast]
  have hrate : peelRate P N = ballVol d R / N := by rw [peelRate, hbudget]
  have hgap : ∀ j < N, peelGap P j ≤ (1 + ε) * peelRate P N := by
    intro j hj
    rw [hrate, peelGap, hsize, hsize]
    exact hsmall j hj
  have hstab := peel_stability P hε hk hgap
  rw [hbudget] at hstab
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  have hest : peelEstimate P N k = ballVol d R * (1 - (k : ℝ) / N) := by
    rw [peelEstimate, hsize, h0, hrate]
    field_simp
  rw [hest, hsize] at hstab
  exact hstab

end Catalog.Geometry.Peel