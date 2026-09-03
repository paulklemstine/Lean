import Mathlib
import Bridges.ORDialCap
import Bridges.ORDialMaximum
import Bridges.ORDialClassification
import Bridges.ORDialCharacter

/-!
# The OR dial under inflation and under multiplier randomisation

Two structural laws for the semiprime OR dial of `Bridges.ORDialMaximum`, corresponding to
the two empirical findings of the round-48 experiment (exp 510):

* **DIAL-HOLDS-UNIFORM** — the dial value is an invariant of the *character quotient* of
  the class group, not of the class group itself.  Formally, for a surjective group
  homomorphism `f : G →* Q` and any profile `s : Q → ℝ`, `orInfo (s ∘ f) = orInfo s`
  (`orInfo_comp_surjective`).  Enlarging the ambient class group (the "bit-length" axis),
  relabelling it by an automorphism (the "regime" axis) or crossing it with an arbitrary
  extra factor leaves the dial exactly where it was; `dial_uniform_cell` packages the
  intersection cell: on `G × Q`, every translate of an index-two kernel pulled back from
  `G` sits precisely at `orCap`, uniformly in `Q` and in the translate.

* **K-WASHOUT** — averaging the profile over a group `H` of multipliers can only destroy
  the channel.  `washout_dichotomy` is an exact criterion: an `H`-invariant profile
  reaches the cap **iff** `H` is contained in an index-two subgroup.  Hence
  `washout_of_odd_index`: if `[G : H]` is odd the cap is unreachable, and
  `orInfo_mix_top`: full randomisation (`H = ⊤`) collapses the dial to exactly `0`,
  while `avg_mix` shows the *count* statistic `avg` is completely unchanged by the
  randomisation.  `count_blind_dial_separates` states this contrast quantitatively: two
  profiles with the same mean whose dial values differ by the full cap `orCap > 0`.

The character form of the washout: `avg_quadChar_eq_zero` — the `±1` character of an
index-two subgroup averages to `0` over the class group, i.e. randomising the multiplier
equidistributes the quadratic character, which is exactly the mechanism the pilot
observed.
-/

open Real Finset

namespace ORDial

/-- The cap is strictly positive: `orCap = (3/2) log 2 - (3/4) log 3 ≥ (3/8) log 2 - 3/64`. -/
lemma orCap_pos : 0 < orCap := by
  have h2 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have h3 : Real.log 3 ≤ 3/2 * Real.log 2 + 1/16 := log_three_le
  rw [orCap_eq]
  nlinarith

/-! ## Part I. Inflation invariance: the dial only sees the character quotient -/

section Inflation

variable {G Q : Type*} [Fintype G] [CommGroup G] [Fintype Q] [CommGroup Q]

/-- Summing a pulled-back function over `G` multiplies the sum over `Q` by the size of the
kernel. -/
lemma sum_comp_surjective (f : G →* Q) (hf : Function.Surjective f) (F : Q → ℝ) :
    ∑ a : G, F (f a) = (Nat.card f.ker : ℝ) * ∑ b : Q, F b := by
  classical
  have h := Fintype.sum_fiberwise (fun a : G => f a) (fun a : G => F (f a))
  rw [← h, Finset.mul_sum]
  refine Finset.sum_congr rfl fun b _ => ?_
  have hcard : Nat.card {a : G // f a = b} = Nat.card f.ker :=
    Nat.card_congr (MonoidHom.fiberEquivKerOfSurjective hf b)
  have h2 : ∑ a : {a : G // f a = b}, F (f a.1) = ∑ _a : {a : G // f a = b}, F b :=
    Finset.sum_congr rfl fun a _ => by rw [a.2]
  rw [h2, Finset.sum_const, nsmul_eq_mul, Finset.card_univ, ← Nat.card_eq_fintype_card, hcard]

/-- Lagrange for a surjection: `|G| = |ker f| · |Q|`. -/
lemma card_eq_card_ker_mul (f : G →* Q) (hf : Function.Surjective f) :
    (Fintype.card G : ℝ) = (Nat.card f.ker : ℝ) * (Fintype.card Q : ℝ) := by
  have hindex : f.ker.index = Nat.card Q := by
    rw [Subgroup.index_ker]
    have hrange : f.range = (⊤ : Subgroup Q) := MonoidHom.range_eq_top.mpr hf
    rw [hrange]
    exact Nat.card_congr (Subgroup.topEquiv.toEquiv)
  have hcard : Nat.card f.ker * f.ker.index = Nat.card G := Subgroup.card_mul_index _
  rw [hindex] at hcard
  have : (Nat.card G : ℝ) = (Nat.card f.ker : ℝ) * (Nat.card Q : ℝ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) hcard.symm
  have hG : (Fintype.card G : ℝ) = (Nat.card G : ℝ) := by rw [Nat.card_eq_fintype_card]
  have hQ : (Fintype.card Q : ℝ) = (Nat.card Q : ℝ) := by rw [Nat.card_eq_fintype_card]
  rw [hG, hQ]
  exact this

/-- **Averages are inflation invariant.** -/
lemma avg_comp_surjective (f : G →* Q) (hf : Function.Surjective f) (F : Q → ℝ) :
    avg (fun a : G => F (f a)) = avg F := by
  have hker : (0 : ℝ) < (Nat.card f.ker : ℝ) := by
    have : 0 < Nat.card f.ker := Nat.card_pos
    exact_mod_cast this
  have hQ : (0 : ℝ) < (Fintype.card Q : ℝ) := card_pos' (G := Q)
  unfold avg
  rw [sum_comp_surjective f hf F, card_eq_card_ker_mul f hf]
  field_simp

/-- The no-fork profile of a pulled-back profile is the pull-back of the no-fork profile. -/
lemma noFork_comp_surjective (f : G →* Q) (hf : Function.Surjective f) (s : Q → ℝ) (c : G) :
    noFork (fun a : G => s (f a)) c = noFork s (f c) := by
  unfold noFork
  have hfun : (fun a : G => s (f a) * s (f (c * a⁻¹)))
      = fun a : G => (fun b : Q => s b * s (f c * b⁻¹)) (f a) := by
    funext a
    simp [map_mul, map_inv]
  rw [hfun]
  exact avg_comp_surjective f hf (fun b : Q => s b * s (f c * b⁻¹))

/-- **DIAL-HOLDS: inflation invariance of the OR dial.**  The mutual information carried
by the OR channel depends only on the profile on the quotient it factors through: pulling
a profile back along any surjection of class groups leaves the dial value unchanged. -/
theorem orInfo_comp_surjective (f : G →* Q) (hf : Function.Surjective f) (s : Q → ℝ) :
    orInfo (fun a : G => s (f a)) = orInfo s := by
  unfold orInfo
  rw [avg_comp_surjective f hf s]
  congr 1
  have hfun : (fun c : G => Real.binEntropy (noFork (fun a : G => s (f a)) c))
      = fun c : G => (fun b : Q => Real.binEntropy (noFork s b)) (f c) := by
    funext c; rw [noFork_comp_surjective f hf]
  rw [hfun]
  exact avg_comp_surjective f hf (fun b : Q => Real.binEntropy (noFork s b))

/-- **Regime invariance**: relabelling the class group by an isomorphism does not move the
dial. -/
theorem orInfo_comp_mulEquiv (e : G ≃* Q) (s : Q → ℝ) :
    orInfo (fun a : G => s (e a)) = orInfo s :=
  orInfo_comp_surjective e.toMonoidHom e.surjective s

/-- **Bit-length invariance**: crossing the class group with an arbitrary extra factor
`Q` (more classes, longer moduli) leaves the dial of a profile that ignores the new factor
unchanged. -/
theorem orInfo_prod_fst (s : G → ℝ) :
    orInfo (fun p : G × Q => s p.1) = orInfo s :=
  orInfo_comp_surjective (MonoidHom.fst G Q) (fun a => ⟨(a, 1), rfl⟩) s

/-- **The intersection cell.**  For an index-two subgroup `K ≤ G`, *every* translate
(regime) of its indicator, inflated to *any* larger class group `G × Q` (bit-length),
sits exactly at the cap: the dial value is the same in all cells of the
regime × bit-length grid. -/
theorem dial_uniform_cell (K : Subgroup G) (hK : K.index = 2) (x : G) :
    orInfo (fun p : G × Q => subgroupProfile K (x⁻¹ * p.1)) = orCap := by
  rw [orInfo_prod_fst (Q := Q) (fun a : G => subgroupProfile K (x⁻¹ * a))]
  exact orInfo_coset_index_two K hK x

end Inflation

/-! ## Part II. Multiplier randomisation and the washout dichotomy -/

section Washout

variable {G : Type*} [Fintype G] [CommGroup G]

/-- A profile is `H`-invariant when multiplying the class by any multiplier from `H`
leaves it unchanged. -/
def InvariantUnder (H : Subgroup G) (s : G → ℝ) : Prop := ∀ h ∈ H, ∀ a : G, s (h * a) = s a

open Classical in
/-- The multiplier-randomised profile: the average of the profile over the multiplier
group `H`.  This is the profile seen by a sampler that multiplies its input by a uniformly
random `k ∈ H` before reading off the class. -/
noncomputable def mix (H : Subgroup G) (s : G → ℝ) : G → ℝ :=
  fun a => (∑ g : G, if g ∈ H then s (g * a) else 0) / (Nat.card H : ℝ)

lemma card_subgroup_pos (H : Subgroup G) : (0 : ℝ) < (Nat.card H : ℝ) := by
  have : 0 < Nat.card H := Nat.card_pos
  exact_mod_cast this

open Classical in
/-- The number of multipliers, as a real sum of indicators. -/
lemma sum_indicator_subgroup (H : Subgroup G) :
    ∑ g : G, (if g ∈ H then (1 : ℝ) else 0) = (Nat.card H : ℝ) := by
  rw [Finset.sum_boole, Nat.card_eq_fintype_card, Fintype.card_subtype]

lemma mix_nonneg {H : Subgroup G} {s : G → ℝ} (hs0 : ∀ a, 0 ≤ s a) (a : G) :
    0 ≤ mix H s a := by
  classical
  have hsum : 0 ≤ ∑ g : G, if g ∈ H then s (g * a) else 0 :=
    Finset.sum_nonneg fun g _ => by by_cases h : g ∈ H <;> simp [h, hs0]
  exact div_nonneg hsum (card_subgroup_pos H).le

lemma mix_le_one {H : Subgroup G} {s : G → ℝ} (hs1 : ∀ a, s a ≤ 1) (a : G) :
    mix H s a ≤ 1 := by
  classical
  have hsum : (∑ g : G, if g ∈ H then s (g * a) else 0) ≤ (Nat.card H : ℝ) := by
    rw [← sum_indicator_subgroup H]
    refine Finset.sum_le_sum fun g _ => ?_
    by_cases h : g ∈ H <;> simp [h, hs1]
  exact (div_le_one (card_subgroup_pos H)).mpr hsum

open Classical in
/-- The randomised profile is invariant under the multiplier group: this is the reason
the channel cannot be recovered afterwards. -/
lemma mix_invariantUnder (H : Subgroup G) (s : G → ℝ) : InvariantUnder H (mix H s) := by
  classical
  intro h hh a
  unfold mix
  congr 1
  refine Fintype.sum_equiv (Equiv.mulRight h) _ _ (fun g => ?_)
  have hmem : g * h ∈ H ↔ g ∈ H := by
    constructor
    · intro hg
      simpa using H.mul_mem hg (H.inv_mem hh)
    · intro hg; exact H.mul_mem hg hh
  by_cases hg : g ∈ H
  · have : g * h ∈ H := hmem.mpr hg
    simp only [Equiv.coe_mulRight, if_pos this, if_pos hg]
    rw [mul_assoc, mul_comm h a]
  · have : ¬ (g * h ∈ H) := fun hc => hg (hmem.mp hc)
    simp [this, hg]

open Classical in
/-- **Randomisation is count-blind**: the mean rate (the "count" statistic) is exactly
preserved by multiplier randomisation. -/
lemma avg_mix (H : Subgroup G) (s : G → ℝ) : avg (mix H s) = avg s := by
  classical
  have hH : (Nat.card H : ℝ) ≠ 0 := ne_of_gt (card_subgroup_pos H)
  have hstep : ∀ g : G, avg (fun a : G => if g ∈ H then s (g * a) else 0)
      = (if g ∈ H then avg s else 0) := by
    intro g
    by_cases hg : g ∈ H
    · simp only [hg, if_pos]
      exact avg_comp_mulLeft s g
    · simp [hg]
  have hsum : avg (mix H s)
      = (∑ g : G, avg (fun a : G => if g ∈ H then s (g * a) else 0)) / (Nat.card H : ℝ) := by
    unfold mix avg
    rw [← Finset.sum_div, ← Finset.sum_div]
    rw [Finset.sum_comm]
    field_simp
  rw [hsum]
  have : ∑ g : G, avg (fun a : G => if g ∈ H then s (g * a) else 0)
      = (Nat.card H : ℝ) * avg s := by
    rw [Finset.sum_congr rfl fun g _ => hstep g]
    have : ∀ g : G, (if g ∈ H then avg s else 0) = (if g ∈ H then (1:ℝ) else 0) * avg s := by
      intro g; by_cases hg : g ∈ H <;> simp [hg]
    rw [Finset.sum_congr rfl fun g _ => this g, ← Finset.sum_mul, sum_indicator_subgroup]
  rw [this]
  field_simp

/-- A profile invariant under `H` that attains the cap forces `H` to lie inside an
index-two subgroup: the surviving channel is a quadratic character that is *trivial on the
multipliers*. -/
theorem le_index_two_of_invariant_max {H : Subgroup G} {s : G → ℝ}
    (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1) (hinv : InvariantUnder H s)
    (hmax : orInfo s = orCap) : ∃ K : Subgroup G, K.index = 2 ∧ H ≤ K := by
  classical
  obtain ⟨K, x, hK, hs⟩ := (max_iff_coset_indicator hs0 hs1).mp hmax
  refine ⟨K, hK, fun h hh => ?_⟩
  have hx : s x = 1 := by
    rw [hs]
    simp [subgroupProfile]
  have hhx : s (h * x) = 1 := by rw [hinv h hh x, hx]
  rw [hs] at hhx
  have harg : x⁻¹ * (h * x) = h := by
    rw [mul_comm h x, ← mul_assoc, inv_mul_cancel, one_mul]
  have hhx' : subgroupProfile K (x⁻¹ * (h * x)) = 1 := hhx
  rw [harg] at hhx'
  by_contra hnk
  rw [subgroupProfile, if_neg hnk] at hhx'
  norm_num at hhx'

/-- **The washout dichotomy.**  A multiplier group `H` leaves some maximal channel intact
iff `H` is contained in an index-two subgroup; otherwise *every* `H`-invariant profile is
strictly below the cap. -/
theorem washout_dichotomy (H : Subgroup G) :
    (∃ s : G → ℝ, (∀ a, 0 ≤ s a) ∧ (∀ a, s a ≤ 1) ∧ InvariantUnder H s ∧ orInfo s = orCap)
      ↔ ∃ K : Subgroup G, K.index = 2 ∧ H ≤ K := by
  constructor
  · rintro ⟨s, hs0, hs1, hinv, hmax⟩
    exact le_index_two_of_invariant_max hs0 hs1 hinv hmax
  · rintro ⟨K, hK, hHK⟩
    refine ⟨subgroupProfile K, subgroupProfile_nonneg K, subgroupProfile_le_one K, ?_,
      orInfo_index_two_eq_orCap K hK⟩
    intro h hh a
    have hhK : h ∈ K := hHK hh
    unfold subgroupProfile
    by_cases ha : a ∈ K
    · rw [if_pos (K.mul_mem hhK ha), if_pos ha]
    · have : h * a ∉ K := fun hc => ha (by simpa using K.mul_mem (K.inv_mem hhK) hc)
      rw [if_neg this, if_neg ha]

/-- **K-WASHOUT (odd index).**  If the multiplier group has odd index, no invariant
profile can reach the cap: the quadratic-character channel is strictly degraded. -/
theorem washout_of_odd_index {H : Subgroup G} {s : G → ℝ} (hodd : Odd H.index)
    (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1) (hinv : InvariantUnder H s) :
    orInfo s < orCap := by
  rcases lt_or_eq_of_le (orInfo_le_orCap hs0 hs1) with h | h
  · exact h
  · exfalso
    obtain ⟨K, hK, hHK⟩ := le_index_two_of_invariant_max hs0 hs1 hinv h
    have hdvd : K.index ∣ H.index := Subgroup.index_dvd_of_le hHK
    rw [hK] at hdvd
    exact (Nat.not_even_iff_odd.mpr hodd) (even_iff_two_dvd.mpr hdvd)

/-- **Randomised profiles are washed out** whenever the multiplier group has odd index. -/
theorem orInfo_mix_lt_orCap {H : Subgroup G} (hodd : Odd H.index) {s : G → ℝ}
    (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1) : orInfo (mix H s) < orCap :=
  washout_of_odd_index hodd (mix_nonneg hs0) (mix_le_one hs1) (mix_invariantUnder H s)

/-- A constant profile carries no information at all. -/
theorem orInfo_const (t : ℝ) : orInfo (fun _ : G => t) = 0 := by
  have hnf : noFork (fun _ : G => t) = fun _ : G => t ^ 2 := by
    funext c
    unfold noFork
    have : (fun _ : G => t * t) = fun _ : G => t ^ 2 := by funext a; ring
    rw [this, avg_const]
  unfold orInfo
  rw [hnf, avg_const, avg_const]
  ring

open Classical in
/-- Randomising over *all* multipliers flattens the profile to its mean. -/
lemma mix_top (s : G → ℝ) : mix (⊤ : Subgroup G) s = fun _ : G => avg s := by
  classical
  funext a
  have hcard : (Nat.card (⊤ : Subgroup G) : ℝ) = (Fintype.card G : ℝ) := by
    have : Nat.card (⊤ : Subgroup G) = Nat.card G := Nat.card_congr Subgroup.topEquiv.toEquiv
    rw [this, Nat.card_eq_fintype_card]
  have hsum : (∑ g : G, if g ∈ (⊤ : Subgroup G) then s (g * a) else 0) = ∑ g : G, s g := by
    have h1 : (∑ g : G, if g ∈ (⊤ : Subgroup G) then s (g * a) else 0)
        = ∑ g : G, s (g * a) := by
      refine Finset.sum_congr rfl fun g _ => ?_
      simp
    rw [h1]
    exact Fintype.sum_equiv (Equiv.mulRight a) _ _ (fun g => rfl)
  unfold mix avg
  rw [hsum, hcard]

/-- **Total washout.**  Full multiplier randomisation destroys the channel exactly: the
dial reads zero. -/
theorem orInfo_mix_top (s : G → ℝ) : orInfo (mix (⊤ : Subgroup G) s) = 0 := by
  rw [mix_top s]
  exact orInfo_const (avg s)

/-- The `±1` quadratic character of an index-two subgroup averages to zero over the class
group: randomising the multiplier equidistributes the character.  This is the mechanism
behind the washout. -/
theorem avg_quadChar_eq_zero (K : Subgroup G) (hK : K.index = 2) :
    avg (quadChar K) = 0 := by
  classical
  have hfun : quadChar K = fun a : G => (-1 : ℝ) + 2 * subgroupProfile K a := by
    funext a
    unfold quadChar subgroupProfile
    by_cases h : a ∈ K
    · simp [h]; norm_num
    · simp [h]
  rw [hfun, avg_affine, avg_subgroupProfile, hK]
  norm_num

/-- The randomised quadratic-character profile is the constant `1/2`: the dial channel is
gone, but the mean rate is untouched. -/
theorem mix_top_subgroupProfile (K : Subgroup G) (hK : K.index = 2) :
    mix (⊤ : Subgroup G) (subgroupProfile K) = fun _ : G => (1 : ℝ)/2 := by
  rw [mix_top, avg_subgroupProfile, hK]
  norm_num

/-- **T beats count.**  The quadratic-character profile and its multiplier-randomised
version have *identical* mean rate, yet their dial values differ by the full cap: the
count statistic is blind exactly where the dial statistic separates maximally. -/
theorem count_blind_dial_separates (K : Subgroup G) (hK : K.index = 2) :
    avg (mix (⊤ : Subgroup G) (subgroupProfile K)) = avg (subgroupProfile K) ∧
      orInfo (subgroupProfile K) - orInfo (mix (⊤ : Subgroup G) (subgroupProfile K)) = orCap ∧
      0 < orCap := by
  refine ⟨avg_mix ⊤ (subgroupProfile K), ?_, orCap_pos⟩
  rw [orInfo_mix_top, orInfo_index_two_eq_orCap K hK]
  ring

end Washout

end ORDial