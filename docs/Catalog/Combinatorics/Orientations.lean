/-
# Divisors coming from acyclic orientations

A linear order on the vertices (encoded as an injective ranking `t : V → ℕ`) gives an acyclic
orientation of `G`: orient every edge towards its endpoint of larger rank.  The associated
divisor is `ν_t (v) = indeg(v) - 1`.

Main results:
* `TropicalRR.degD_nu` : `deg ν_t = g - 1`;
* `TropicalRR.nu_add_nu_revRank` : `ν_t + ν_{rev t} = K`;
* `TropicalRR.nu_not_winnable` : `ν_t` is never winnable (this is the "one" half of the
  Baker–Norine dichotomy);
* `TropicalRR.exists_nu_dominating` : a divisor satisfying the `q`-reduced firing condition
  and with value `≤ -1` at `q` is dominated by some `ν_t` (the "other" half).
-/
import Combinatorics.TropicalRiemannRoch.Reduced

namespace TropicalRR

open Finset

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The neighbours of `v` of strictly smaller rank; the in-neighbours of the acyclic
orientation determined by `t`. -/
def below (t : V → ℕ) (v : V) : Finset V :=
  (G.neighborFinset v).filter (fun w => t w < t v)

/-- The divisor `ν_t (v) = indeg(v) - 1` attached to the acyclic orientation given by `t`. -/
def nu (t : V → ℕ) : Divisor V := fun v => ((below G t v).card : ℤ) - 1

/-- The reversed ranking. -/
def revRank (t : V → ℕ) : V → ℕ := fun v => (Finset.univ.sup t) - t v

omit [DecidableEq V] in
lemma le_sup_rank (t : V → ℕ) (v : V) : t v ≤ Finset.univ.sup t :=
  Finset.le_sup (f := t) (Finset.mem_univ v)

omit [DecidableEq V] in
lemma revRank_lt_iff {t : V → ℕ} (u v : V) : revRank t u < revRank t v ↔ t v < t u := by
  unfold revRank
  have h1 := le_sup_rank t u
  have h2 := le_sup_rank t v
  omega

omit [DecidableEq V] in
lemma revRank_injective {t : V → ℕ} (ht : Function.Injective t) :
    Function.Injective (revRank t) := by
  intro u v h
  unfold revRank at h
  have h1 := le_sup_rank t u
  have h2 := le_sup_rank t v
  exact ht (by omega)

/-! ### The degree of `ν_t` -/

omit [DecidableEq V] in
lemma card_below_eq_sum (t : V → ℕ) (v : V) :
    ((below G t v).card : ℤ) = ∑ w ∈ G.neighborFinset v, (if t w < t v then 1 else 0) := by
  rw [below, ← Finset.sum_boole]

omit [DecidableEq V] in
/-- The total in-degree of an acyclic orientation is the number of edges. -/
lemma sum_card_below (t : V → ℕ) (ht : Function.Injective t) :
    ∑ v, ((below G t v).card : ℤ) = (G.edgeFinset.card : ℤ) := by
  set A : ℤ := ∑ v, ∑ w ∈ G.neighborFinset v, (if t w < t v then (1:ℤ) else 0) with hA
  set B : ℤ := ∑ v, ∑ w ∈ G.neighborFinset v, (if t v < t w then (1:ℤ) else 0) with hB
  have hAB : A = B := by
    rw [hA, hB]
    exact sum_adj_comm G (fun v w => if t w < t v then (1:ℤ) else 0)
  have hsum : A + B = 2 * (G.edgeFinset.card : ℤ) := by
    have h1 : A + B = ∑ v, ∑ w ∈ G.neighborFinset v, (1 : ℤ) := by
      rw [hA, hB, ← Finset.sum_add_distrib]
      refine Finset.sum_congr rfl fun v _ => ?_
      rw [← Finset.sum_add_distrib]
      refine Finset.sum_congr rfl fun w hw => ?_
      have hne : w ≠ v := ((SimpleGraph.mem_neighborFinset G v w).1 hw).ne'
      have : t w ≠ t v := fun h => hne (ht h)
      rcases lt_trichotomy (t w) (t v) with h | h | h
      · simp [h, not_lt.2 h.le]
      · exact absurd h this
      · simp [h, not_lt.2 h.le]
    rw [h1]
    have h2 : ∑ v, ∑ _w ∈ G.neighborFinset v, (1 : ℤ) = ∑ v : V, (G.degree v : ℤ) := by
      refine Finset.sum_congr rfl fun v _ => ?_
      rw [Finset.sum_const, nsmul_eq_mul, SimpleGraph.card_neighborFinset_eq_degree, mul_one]
    rw [h2]
    have h3 : ∑ v, G.degree v = 2 * G.edgeFinset.card :=
      SimpleGraph.sum_degrees_eq_twice_card_edges G
    have h4 : ((∑ v, G.degree v : ℕ) : ℤ) = 2 * (G.edgeFinset.card : ℤ) := by exact_mod_cast h3
    rw [Nat.cast_sum] at h4
    exact h4
  have : A = (G.edgeFinset.card : ℤ) := by omega
  rw [← this, hA]
  exact Finset.sum_congr rfl fun v _ => card_below_eq_sum G t v

omit [DecidableEq V] in
/-- `deg ν_t = g - 1`. -/
theorem degD_nu (t : V → ℕ) (ht : Function.Injective t) :
    degD (nu G t) = genus G - 1 := by
  simp only [degD, nu, genus, Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ,
    nsmul_eq_mul, mul_one, sum_card_below G t ht]
  ring

/-! ### Reversal and the canonical divisor -/

lemma card_below_add_card_below_rev (t : V → ℕ) (ht : Function.Injective t) (v : V) :
    (below G t v).card + (below G (revRank t) v).card = G.degree v := by
  have hdisj : Disjoint (below G t v) (below G (revRank t) v) := by
    rw [Finset.disjoint_left]
    intro w hw hw'
    rw [below, Finset.mem_filter] at hw hw'
    rw [revRank_lt_iff] at hw'
    omega
  have hunion : (below G t v) ∪ (below G (revRank t) v) = G.neighborFinset v := by
    apply Finset.Subset.antisymm
    · intro w hw
      rcases Finset.mem_union.1 hw with h | h <;>
        exact Finset.mem_of_mem_filter (s := G.neighborFinset v) w h
    · intro w hw
      have hne : w ≠ v := ((SimpleGraph.mem_neighborFinset G v w).1 hw).ne'
      have htne : t w ≠ t v := fun h => hne (ht h)
      rcases lt_or_gt_of_ne htne with h | h
      · exact Finset.mem_union_left _ (Finset.mem_filter.2 ⟨hw, h⟩)
      · refine Finset.mem_union_right _ (Finset.mem_filter.2 ⟨hw, ?_⟩)
        rw [revRank_lt_iff]; exact h
  rw [← SimpleGraph.card_neighborFinset_eq_degree, ← hunion, Finset.card_union_of_disjoint hdisj]

/-- Reversing the orientation replaces `ν` by `K - ν`. -/
theorem nu_add_nu_revRank (t : V → ℕ) (ht : Function.Injective t) :
    nu G t + nu G (revRank t) = canonical G := by
  funext v
  have := card_below_add_card_below_rev G t ht v
  have hz : ((below G t v).card : ℤ) + ((below G (revRank t) v).card : ℤ)
      = (G.degree v : ℤ) := by exact_mod_cast this
  simp only [nu, canonical, Pi.add_apply]
  omega

lemma canonical_sub_nu (t : V → ℕ) (ht : Function.Injective t) :
    canonical G - nu G t = nu G (revRank t) := by
  rw [← nu_add_nu_revRank G t ht]; abel

/-! ### `ν_t` is never winnable -/

/-- **Acyclic orientation divisors have rank `-1`.**  For every injective ranking `t`, the
divisor `ν_t` is not linearly equivalent to any effective divisor. -/
theorem nu_not_winnable [Nonempty V] (t : V → ℕ) : ¬ Winnable G (nu G t) := by
  rintro ⟨E, ⟨f, rfl⟩, hE⟩
  -- take the vertex of smallest rank inside the set where `f` is maximal
  obtain ⟨v₀, hv₀⟩ := maxSet_nonempty f
  obtain ⟨v, hvA, hvmin⟩ :=
    Finset.exists_min_image (maxSet f) t ⟨v₀, hv₀⟩
  -- every in-neighbour of `v` lies outside the maximum set
  have hsub : below G t v ⊆ (G.neighborFinset v) \ (maxSet f) := by
    intro w hw
    rw [below, Finset.mem_filter] at hw
    refine Finset.mem_sdiff.2 ⟨hw.1, fun hwA => ?_⟩
    have := hvmin w hwA
    omega
  have hcard : (below G t v).card ≤ outdeg G (maxSet f) v := Finset.card_le_card hsub
  have hlap : (outdeg G (maxSet f) v : ℤ) ≤ lap G f v := outdeg_le_lap_maxSet G hvA
  have hcz : ((below G t v).card : ℤ) ≤ (outdeg G (maxSet f) v : ℤ) := by exact_mod_cast hcard
  have := hE v
  simp only [Pi.sub_apply, nu] at this
  omega

/-! ### The greedy construction: every `q`-reduced divisor is dominated by some `ν_t` -/

private lemma greedy_aux (D : Divisor V) (S : Finset V)
    (h : ∀ T : Finset V, T ⊆ S → T.Nonempty → ∃ v ∈ T, D v < (outdeg G T v : ℤ)) :
    ∃ t : V → ℕ, Set.InjOn t (S : Set V) ∧ (∀ v ∈ S, 1 ≤ t v) ∧ (∀ w, w ∉ S → t w = 0) ∧
      (∀ v ∈ S, D v < (((G.neighborFinset v).filter (fun w => t w < t v)).card : ℤ)) := by
  induction S using Finset.strongInduction with
  | _ S ih =>
    rcases S.eq_empty_or_nonempty with rfl | hSne
    · exact ⟨fun _ => 0, by simp, by simp, by simp, by simp⟩
    obtain ⟨v₀, hv₀S, hv₀⟩ := h S (Finset.Subset.refl S) hSne
    obtain ⟨t', hinj', hpos', hzero', hlt'⟩ :=
      ih (S.erase v₀) (Finset.erase_ssubset hv₀S)
        (fun T hT hTne => h T (hT.trans (Finset.erase_subset _ _)) hTne)
    classical
    set T : V → ℕ := fun w => if w = v₀ then 1 else if w ∈ S.erase v₀ then t' w + 1 else 0
      with hTdef
    have hTv0 : T v₀ = 1 := by simp [hTdef]
    have hTin : ∀ w ∈ S.erase v₀, T w = t' w + 1 := by
      intro w hw
      have hwv : w ≠ v₀ := (Finset.mem_erase.1 hw).1
      simp [hTdef, hwv, Finset.mem_of_mem_erase hw]
    have hTout : ∀ w, w ∉ S → T w = 0 := by
      intro w hw
      have hwv : w ≠ v₀ := fun hh => hw (hh ▸ hv₀S)
      have hw' : w ∉ S.erase v₀ := fun hh => hw (Finset.mem_of_mem_erase hh)
      simp [hTdef, hwv, hw]
    have hTge : ∀ w ∈ S, 1 ≤ T w := by
      intro w hw
      by_cases hwv : w = v₀
      · rw [hwv, hTv0]
      · rw [hTin w (Finset.mem_erase.2 ⟨hwv, hw⟩)]; omega
    have hTge2 : ∀ w ∈ S.erase v₀, 2 ≤ T w := by
      intro w hw
      rw [hTin w hw]
      have := hpos' w hw
      omega
    refine ⟨T, ?_, hTge, hTout, ?_⟩
    · intro a ha b hb hab
      simp only [Finset.mem_coe] at ha hb
      by_cases hav : a = v₀ <;> by_cases hbv : b = v₀
      · rw [hav, hbv]
      · exact absurd hab (by
          rw [hav, hTv0]
          have := hTge2 b (Finset.mem_erase.2 ⟨hbv, hb⟩)
          omega)
      · exact absurd hab (by
          rw [hbv, hTv0]
          have := hTge2 a (Finset.mem_erase.2 ⟨hav, ha⟩)
          omega)
      · have haS := Finset.mem_erase.2 ⟨hav, ha⟩
        have hbS := Finset.mem_erase.2 ⟨hbv, hb⟩
        rw [hTin a haS, hTin b hbS] at hab
        exact hinj' (Finset.mem_coe.2 haS) (Finset.mem_coe.2 hbS) (by omega)
    · intro v hv
      by_cases hvv : v = v₀
      · subst hvv
        have heq : (G.neighborFinset v).filter (fun w => T w < T v)
            = (G.neighborFinset v) \ S := by
          ext w
          simp only [Finset.mem_filter, Finset.mem_sdiff]
          constructor
          · rintro ⟨hw, hlt⟩
            refine ⟨hw, fun hwS => ?_⟩
            have h1 := hTge w hwS
            rw [hTv0] at hlt
            omega
          · rintro ⟨hw, hwS⟩
            exact ⟨hw, by rw [hTout w hwS, hTv0]; omega⟩
        rw [heq]
        exact hv₀
      · have hvS : v ∈ S.erase v₀ := Finset.mem_erase.2 ⟨hvv, hv⟩
        refine lt_of_lt_of_le (hlt' v hvS) ?_
        have hmono : (G.neighborFinset v).filter (fun w => t' w < t' v) ⊆
            (G.neighborFinset v).filter (fun w => T w < T v) := by
          intro w hw
          rw [Finset.mem_filter] at hw ⊢
          refine ⟨hw.1, ?_⟩
          rw [hTin v hvS]
          by_cases hwv : w = v₀
          · rw [hwv, hTv0]
            have := hpos' v hvS
            omega
          · by_cases hwS : w ∈ S.erase v₀
            · rw [hTin w hwS]; have := hw.2; omega
            · by_cases hwS' : w ∈ S
              · exact absurd (Finset.mem_erase.2 ⟨hwv, hwS'⟩) hwS
              · rw [hTout w hwS']; have := hpos' v hvS; omega
        exact_mod_cast Finset.card_le_card hmono

/-- **Greedy domination.**  If `D` admits no legal set-firing away from `q` and has value at
most `-1` at `q`, then `D ≤ ν_t` for some injective ranking `t`. -/
theorem exists_nu_dominating {q : V} {D : Divisor V}
    (hfire : ∀ T : Finset V, T.Nonempty → q ∉ T → ∃ v ∈ T, D v < (outdeg G T v : ℤ))
    (hq : D q ≤ -1) :
    ∃ t : V → ℕ, Function.Injective t ∧ ∀ v, D v ≤ nu G t v := by
  obtain ⟨t, hinj, hpos, hzero, hlt⟩ :=
    greedy_aux G D (Finset.univ.erase q)
      (fun T hT hTne => hfire T hTne (fun hmem => (Finset.mem_erase.1 (hT hmem)).1 rfl))
  have htq : t q = 0 := hzero q (by simp)
  refine ⟨t, ?_, ?_⟩
  · intro a b hab
    by_cases ha : a = q <;> by_cases hb : b = q
    · rw [ha, hb]
    · exfalso
      have hbS : b ∈ Finset.univ.erase q := Finset.mem_erase.2 ⟨hb, Finset.mem_univ b⟩
      have := hpos b hbS
      rw [ha, htq] at hab
      omega
    · exfalso
      have haS : a ∈ Finset.univ.erase q := Finset.mem_erase.2 ⟨ha, Finset.mem_univ a⟩
      have := hpos a haS
      rw [hb, htq] at hab
      omega
    · exact hinj (by simp [ha]) (by simp [hb]) hab
  · intro v
    by_cases hv : v = q
    · subst hv
      have : below G t v = ∅ := by
        rw [below]
        refine Finset.filter_eq_empty_iff.2 fun w _ => ?_
        rw [htq]
        omega
      simp only [nu, this, Finset.card_empty, Nat.cast_zero]
      omega
    · have hvS : v ∈ Finset.univ.erase q := Finset.mem_erase.2 ⟨hv, Finset.mem_univ v⟩
      have := hlt v hvS
      simp only [nu, below]
      omega

end TropicalRR