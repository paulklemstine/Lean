import Mathlib
import Bridges.ORDialCap
import Bridges.ORDialMaximum
import Bridges.ORDialClassification
import Bridges.ORDialCharacter
import Bridges.ORDialWashoutInvariance

/-!
# Character-level washout: one non-residue multiplier zeroes the channel

`Bridges.ORDialWashoutParity` shows that a multiplier group of odd index leaves *no*
maximal channel.  This file explains the mechanism at the level of a single quadratic
character, which is what the `K`-WASHOUT pilot actually observed: averaging over the
multipliers equidistributes the character.

Let `K ≤ G` be an index-two subgroup, `χ = quadChar K` its `±1` character, and `H` a
multiplier group.  If `H` is *not* contained in `K` — i.e. the sampler can multiply by at
least one quadratic non-residue — then

* `sum_quadChar_over_subgroup` : `Σ_{g ∈ H} χ(g) = 0` (the character equidistributes over
  the multipliers);
* `mix_subgroupProfile_of_not_le` : the randomised profile is the constant `1/2`, i.e. the
  entire `χ`-channel is flattened;
* `orInfo_mix_subgroupProfile_of_not_le` : the dial reads exactly `0` — not merely below
  the cap — while `avg_mix` keeps the mean rate at `1/2`.

`quadChar_channel_collapse` packages the trichotomy in one statement: same mean, dial
`orCap` before randomisation and dial `0` after it.
-/

open Real Finset

namespace ORDial

section CharacterWashout

variable {G : Type*} [Fintype G] [CommGroup G]

omit [Fintype G] in
/-- `subgroupProfile K` is the character profile `(1 + χ)/2`. -/
lemma subgroupProfile_eq_quadChar (K : Subgroup G) (a : G) :
    subgroupProfile K a = (1 + quadChar K a) / 2 := by
  classical
  unfold subgroupProfile quadChar
  by_cases h : a ∈ K
  · simp [h]
  · simp [h]

open Classical in
/-- **The character equidistributes over a multiplier group that contains a
non-residue.**  If `H ⊄ K` then the `±1` character of `K` sums to zero over `H`. -/
theorem sum_quadChar_over_subgroup (K H : Subgroup G) (hK : K.index = 2) (hHK : ¬ H ≤ K) :
    ∑ g : G, (if g ∈ H then quadChar K g else 0) = 0 := by
  classical
  obtain ⟨h₁, hh₁H, hh₁K⟩ : ∃ h ∈ H, h ∉ K := by
    by_contra hc
    exact hHK fun x hx => by
      by_contra hxK
      exact hc ⟨x, hx, hxK⟩
  have hchar : quadChar K h₁ = -1 := by
    unfold quadChar
    simp [hh₁K]
  set S : ℝ := ∑ g : G, (if g ∈ H then quadChar K g else 0) with hS
  have hmem : ∀ g : G, (g * h₁ ∈ H ↔ g ∈ H) := by
    intro g
    constructor
    · intro hg; simpa using H.mul_mem hg (H.inv_mem hh₁H)
    · intro hg; exact H.mul_mem hg hh₁H
  have hterm : ∀ g : G, (if g * h₁ ∈ H then quadChar K (g * h₁) else 0)
      = -(if g ∈ H then quadChar K g else 0) := by
    intro g
    by_cases hg : g ∈ H
    · rw [if_pos ((hmem g).mpr hg), if_pos hg]
      have hmul := (quadCharHom K hK).map_mul g h₁
      simp only [quadCharHom_apply] at hmul
      rw [hmul, hchar]
      ring
    · rw [if_neg (fun hc => hg ((hmem g).mp hc)), if_neg hg]
      ring
  have hswap : S = -S :=
    calc S = ∑ g : G, (if g * h₁ ∈ H then quadChar K (g * h₁) else 0) :=
          (Fintype.sum_equiv (Equiv.mulRight h₁) _ _ (fun g => rfl)).symm
      _ = ∑ g : G, -(if g ∈ H then quadChar K g else 0) :=
          Finset.sum_congr rfl fun g _ => hterm g
      _ = -S := by rw [hS, Finset.sum_neg_distrib]
  exact eq_zero_of_neg_eq hswap.symm

open Classical in
/-- **One non-residue multiplier flattens the quadratic-character profile.**  If the
multiplier group is not contained in the character kernel, the randomised profile is the
constant `1/2`. -/
theorem mix_subgroupProfile_of_not_le (K H : Subgroup G) (hK : K.index = 2) (hHK : ¬ H ≤ K) :
    mix H (subgroupProfile K) = fun _ : G => (1 : ℝ)/2 := by
  classical
  funext a
  have hcard : (0:ℝ) < (Nat.card H : ℝ) := card_subgroup_pos H
  have hsum : ∑ g : G, (if g ∈ H then subgroupProfile K (g * a) else 0)
      = (Nat.card H : ℝ) / 2 := by
    have hterm : ∀ g : G, (if g ∈ H then subgroupProfile K (g * a) else 0)
        = (1/2) * (if g ∈ H then (1:ℝ) else 0)
          + (quadChar K a / 2) * (if g ∈ H then quadChar K g else 0) := by
      intro g
      by_cases hg : g ∈ H
      · rw [if_pos hg, if_pos hg, if_pos hg, subgroupProfile_eq_quadChar]
        have hmul := (quadCharHom K hK).map_mul g a
        simp only [quadCharHom_apply] at hmul
        rw [hmul]
        ring
      · rw [if_neg hg, if_neg hg, if_neg hg]
        ring
    rw [Finset.sum_congr rfl fun g _ => hterm g, Finset.sum_add_distrib, ← Finset.mul_sum,
      ← Finset.mul_sum, sum_indicator_subgroup H, sum_quadChar_over_subgroup K H hK hHK]
    ring
  unfold mix
  rw [hsum]
  field_simp

/-- **Total collapse of a single character channel.**  A multiplier group containing a
non-residue drives the dial of the quadratic-character profile to exactly `0`. -/
theorem orInfo_mix_subgroupProfile_of_not_le (K H : Subgroup G) (hK : K.index = 2)
    (hHK : ¬ H ≤ K) : orInfo (mix H (subgroupProfile K)) = 0 := by
  rw [mix_subgroupProfile_of_not_le K H hK hHK]
  exact orInfo_const _

/-- **The channel collapse, in one statement.**  Randomising by a multiplier group that
contains a quadratic non-residue leaves the mean rate at `1/2` (the count statistic sees
nothing at all) while the dial drops from the cap `orCap > 0` straight to `0`. -/
theorem quadChar_channel_collapse (K H : Subgroup G) (hK : K.index = 2) (hHK : ¬ H ≤ K) :
    avg (mix H (subgroupProfile K)) = avg (subgroupProfile K) ∧
      avg (subgroupProfile K) = 1/2 ∧
      orInfo (subgroupProfile K) = orCap ∧
      orInfo (mix H (subgroupProfile K)) = 0 ∧ 0 < orCap := by
  refine ⟨avg_mix H (subgroupProfile K), ?_, orInfo_index_two_eq_orCap K hK,
    orInfo_mix_subgroupProfile_of_not_le K H hK hHK, orCap_pos⟩
  rw [avg_subgroupProfile, hK]
  norm_num

omit [Fintype G] in
/-- **Monotonicity of washout.**  Enlarging the multiplier group can only destroy more:
every `H'`-invariant profile is `H`-invariant when `H ≤ H'`. -/
theorem invariantUnder_mono {H H' : Subgroup G} (hHH' : H ≤ H') {s : G → ℝ}
    (h : InvariantUnder H' s) : InvariantUnder H s :=
  fun g hg a => h g (hHH' hg) a

end CharacterWashout

end ORDial