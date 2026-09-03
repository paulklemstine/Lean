import Mathlib
import Bridges.ORDialCap
import Bridges.ORDialMaximum
import Bridges.ORDialClassification
import Bridges.ORDialWashoutInvariance
import Bridges.ORDialRealizations

/-!
# The arithmetic of the washout: the dial survives exactly on even index

`Bridges.ORDialWashoutInvariance` reduces the fate of the OR dial under multiplier
randomisation to a group-theoretic condition: an `H`-invariant class-rate profile reaches
the cap `orCap` iff the multiplier group `H` is contained in an index-two subgroup.  This
file turns that condition into a *number*: for a finite abelian class group,

`H` lies in an index-two subgroup  ⟺  `[G : H]` is even.

The nontrivial direction is the existence statement
`exists_index_two_of_even_card`: a finite abelian group of even order has a subgroup of
index two.  This is proved without the structure theorem, by:

1. `exists_index_two_pow_complement`: Sylow theory gives a subgroup `M` whose index is
   `2 · m` with `m` odd (take a `2`-subgroup of order one less power of two than the full
   `2`-part);
2. `exists_index_two_of_two_mul_odd`: in an abelian group of order `2 m` with `m` odd the
   squaring homomorphism has kernel of order exactly `2` — the kernel is a `2`-group by
   exponent, it is nontrivial by Cauchy, and `4 ∤ 2m` — so its *image* has index two;
3. pulling back along `G → G ⧸ M` and then along `G → G ⧸ H` preserves the index.

The pay-off is `washout_iff_even_index`: **multiplier randomisation by `H` leaves a
maximal OR channel alive iff `[G : H]` is even**, and `mix_washout_of_odd_index`, its
contrapositive for the randomised profile itself.  In particular full randomisation
(`H = ⊤`, index `1`) always washes out — the `K`-WASHOUT observation — while the fixed
multiplier `H = ⊥` never does when the class group has even order.
-/

open Real Finset

namespace ORDial

/-! ## Part I. Index-two subgroups of finite abelian groups -/

/-- Sylow step: a finite abelian group of even order has a subgroup whose index is twice
an odd number (a `2`-subgroup one power short of a full Sylow `2`-subgroup). -/
theorem exists_index_two_pow_complement (Q : Type*) [CommGroup Q] [Finite Q]
    (h2 : 2 ∣ Nat.card Q) : ∃ (M : Subgroup Q) (m : ℕ), ¬ (2 ∣ m) ∧ M.index = 2 * m := by
  classical
  haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  have hn0 : Nat.card Q ≠ 0 := Nat.card_pos.ne'
  obtain ⟨k, m, hmodd, hnm⟩ := Nat.exists_eq_pow_mul_and_not_dvd hn0 2 (by norm_num)
  have hk1 : k ≠ 0 := by
    rintro rfl
    rw [pow_zero, one_mul] at hnm
    rw [hnm] at h2
    exact hmodd h2
  obtain ⟨k', rfl⟩ := Nat.exists_eq_succ_of_ne_zero hk1
  rw [pow_succ] at hnm
  have hdvd : (2:ℕ) ^ k' ∣ Nat.card Q := ⟨2 * m, by rw [hnm]; ring⟩
  obtain ⟨M, hM⟩ := Sylow.exists_subgroup_card_pow_prime (G := Q) 2 (n := k') hdvd
  have hcard : Nat.card M * M.index = Nat.card Q := Subgroup.card_mul_index M
  refine ⟨M, m, hmodd, ?_⟩
  rw [hM] at hcard
  have h : 2 ^ k' * M.index = 2 ^ k' * (2 * m) := by rw [hcard, hnm]; ring
  exact Nat.eq_of_mul_eq_mul_left (Nat.pow_pos (by norm_num)) h

/-- Squaring step: in a finite abelian group of order `2 m` with `m` odd, the subgroup of
squares has index exactly two. -/
theorem exists_index_two_of_two_mul_odd (A : Type*) [CommGroup A] [Finite A] (m : ℕ)
    (hmodd : ¬ (2 ∣ m)) (hA : Nat.card A = 2 * m) : ∃ L : Subgroup A, L.index = 2 := by
  classical
  haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  set sq : A →* A := powMonoidHom 2 with hsq
  have hker2 : IsPGroup 2 sq.ker := by
    intro g
    refine ⟨1, ?_⟩
    have hg : sq (g : A) = 1 := g.2
    have hg2 : (g : A) ^ 2 = 1 := hg
    ext
    push_cast
    simpa using hg2
  obtain ⟨j, hj⟩ := hker2.exists_card_eq
  have hdvd : Nat.card sq.ker ∣ Nat.card A := Subgroup.card_subgroup_dvd_card _
  have hne : Nat.card sq.ker ≠ 1 := by
    haveI : Fintype A := Fintype.ofFinite A
    obtain ⟨x, hx⟩ := exists_prime_orderOf_dvd_card (G := A) 2 (by
      rw [Fintype.card_eq_nat_card, hA]; exact ⟨m, rfl⟩)
    have hxk : x ∈ sq.ker := by
      have hx2 : x ^ 2 = 1 := by rw [← hx]; exact pow_orderOf_eq_one x
      exact hx2
    have hx1 : x ≠ 1 := by
      intro h
      rw [h, orderOf_one] at hx
      norm_num at hx
    intro hcard1
    have hsub : Subsingleton sq.ker := (Nat.card_eq_one_iff_unique.mp hcard1).1
    refine hx1 ?_
    have := Subsingleton.elim (⟨x, hxk⟩ : sq.ker) 1
    simpa using congrArg Subtype.val this
  have hcard2 : Nat.card sq.ker = 2 := by
    rw [hj] at hdvd hne ⊢
    rw [hA] at hdvd
    have hj1 : j = 1 := by
      rcases Nat.lt_or_ge j 2 with h | h
      · interval_cases j
        · simp at hne
        · rfl
      · exfalso
        have h4 : (4:ℕ) ∣ 2 ^ j := by
          calc (4:ℕ) = 2 ^ 2 := by norm_num
            _ ∣ 2 ^ j := pow_dvd_pow 2 h
        obtain ⟨c, hc⟩ := dvd_trans h4 hdvd
        exact hmodd ⟨c, by omega⟩
    rw [hj1]
    norm_num
  refine ⟨sq.range, ?_⟩
  have h1 : Nat.card sq.ker * sq.ker.index = Nat.card A := Subgroup.card_mul_index _
  have h2 : Nat.card sq.range * sq.range.index = Nat.card A := Subgroup.card_mul_index _
  rw [Subgroup.index_ker, hcard2] at h1
  rw [← h1] at h2
  have hrpos : 0 < Nat.card sq.range := Nat.card_pos
  exact Nat.eq_of_mul_eq_mul_left hrpos
    (by linarith [h2] : Nat.card sq.range * sq.range.index = Nat.card sq.range * 2)

/-- **A finite abelian group of even order has a subgroup of index two** — equivalently, it
carries a nontrivial quadratic character. -/
theorem exists_index_two_of_even_card (Q : Type*) [CommGroup Q] [Finite Q]
    (h2 : 2 ∣ Nat.card Q) : ∃ L : Subgroup Q, L.index = 2 := by
  obtain ⟨M, m, hmodd, hM⟩ := exists_index_two_pow_complement Q h2
  have hcardA : Nat.card (Q ⧸ M) = 2 * m := by rw [← Subgroup.index_eq_card, hM]
  obtain ⟨L, hL⟩ := exists_index_two_of_two_mul_odd (Q ⧸ M) m hmodd hcardA
  refine ⟨L.comap (QuotientGroup.mk' M), ?_⟩
  rw [Subgroup.index_comap_of_surjective L (QuotientGroup.mk'_surjective M), hL]

/-- **Even index means a quadratic character trivial on `H`.**  If `[G : H]` is even then
`H` sits inside an index-two subgroup. -/
theorem exists_index_two_ge_of_even_index {G : Type*} [CommGroup G] [Finite G]
    {H : Subgroup G} (h : Even H.index) : ∃ K : Subgroup G, K.index = 2 ∧ H ≤ K := by
  have h2 : 2 ∣ Nat.card (G ⧸ H) := by
    rw [← Subgroup.index_eq_card]
    exact even_iff_two_dvd.mp h
  obtain ⟨L, hL⟩ := exists_index_two_of_even_card (G ⧸ H) h2
  refine ⟨L.comap (QuotientGroup.mk' H), ?_, ?_⟩
  · rw [Subgroup.index_comap_of_surjective L (QuotientGroup.mk'_surjective H), hL]
  · intro x hx
    have hx1 : (QuotientGroup.mk' H) x = 1 := by
      simpa [QuotientGroup.mk'_apply] using (QuotientGroup.eq_one_iff x).mpr hx
    simp [Subgroup.mem_comap, hx1]

/-- The converse: a multiplier group inside an index-two subgroup has even index. -/
theorem even_index_of_le_index_two {G : Type*} [Group G] {H K : Subgroup G}
    (hK : K.index = 2) (hHK : H ≤ K) : Even H.index := by
  have hdvd : K.index ∣ H.index := Subgroup.index_dvd_of_le hHK
  rw [hK] at hdvd
  exact even_iff_two_dvd.mpr hdvd

/-! ## Part II. The parity criterion for the OR dial -/

section Dial

variable {G : Type*} [Fintype G] [CommGroup G]

/-- **The parity criterion for multiplier washout.**  A sampler that randomises its input
by multipliers from `H` can still support a maximal OR channel **iff the index `[G : H]`
is even**.  Odd index — in particular the fully randomised case `H = ⊤`, of index `1` —
destroys the channel. -/
theorem washout_iff_even_index (H : Subgroup G) :
    (∃ s : G → ℝ, (∀ a, 0 ≤ s a) ∧ (∀ a, s a ≤ 1) ∧ InvariantUnder H s ∧ orInfo s = orCap)
      ↔ Even H.index := by
  rw [washout_dichotomy H]
  constructor
  · rintro ⟨K, hK, hHK⟩
    exact even_index_of_le_index_two hK hHK
  · intro h
    exact exists_index_two_ge_of_even_index h

/-- **K-WASHOUT, numerical form.**  If `[G : H]` is odd, the multiplier-randomised profile
is strictly below the cap for *every* input profile: averaging over the multipliers
equidistributes the quadratic characters and the dial channel is gone. -/
theorem mix_washout_of_odd_index {H : Subgroup G} (hodd : ¬ Even H.index) {s : G → ℝ}
    (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1) : orInfo (mix H s) < orCap :=
  orInfo_mix_lt_orCap (Nat.not_even_iff_odd.mp hodd) hs0 hs1

/-- **Fixed multipliers keep the dial.**  With the trivial multiplier group (`k = 1`
sampling) the cap is attained as soon as the class group has even order: the contrast with
`mix_washout_of_odd_index` is the fixed-`k` requirement of the ladder. -/
theorem fixed_multiplier_attains_cap (hG : 2 ∣ Fintype.card G) :
    ∃ s : G → ℝ, (∀ a, 0 ≤ s a) ∧ (∀ a, s a ≤ 1) ∧
      InvariantUnder (⊥ : Subgroup G) s ∧ orInfo s = orCap := by
  refine (washout_iff_even_index (⊥ : Subgroup G)).mpr ?_
  rw [Subgroup.index_bot, Nat.card_eq_fintype_card]
  exact even_iff_two_dvd.mpr hG

/-- The two ends of the multiplier scale, side by side: with fixed multipliers the dial
reaches `orCap` on any even-order class group, with fully random multipliers it reads `0`
for every profile. -/
theorem fixed_versus_random (hG : 2 ∣ Fintype.card G) :
    (∃ s : G → ℝ, (∀ a, 0 ≤ s a) ∧ (∀ a, s a ≤ 1) ∧ orInfo s = orCap) ∧
      (∀ s : G → ℝ, orInfo (mix (⊤ : Subgroup G) s) = 0) := by
  refine ⟨?_, fun s => orInfo_mix_top s⟩
  obtain ⟨s, hs0, hs1, -, hmax⟩ := fixed_multiplier_attains_cap hG
  exact ⟨s, hs0, hs1, hmax⟩

end Dial

/-! ## Part III. An arithmetic realization -/

/-- **The dial and its washout on the class group `(ℤ/p)ˣ`.**  For every odd prime `p` the
Legendre-symbol kernel realises the cap with fixed multipliers, while multiplier
randomisation drives every profile to dial value `0`. -/
theorem washout_units_zmod (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    (∃ s : (ZMod p)ˣ → ℝ, (∀ a, 0 ≤ s a) ∧ (∀ a, s a ≤ 1) ∧ orInfo s = orCap) ∧
      (∀ s : (ZMod p)ˣ → ℝ, orInfo (mix (⊤ : Subgroup (ZMod p)ˣ) s) = 0) := by
  obtain ⟨K, hK, -⟩ := exists_index_two_units_zmod p hp
  exact ⟨⟨subgroupProfile K, subgroupProfile_nonneg K, subgroupProfile_le_one K,
    orInfo_index_two_eq_orCap K hK⟩, fun s => orInfo_mix_top s⟩

end ORDial