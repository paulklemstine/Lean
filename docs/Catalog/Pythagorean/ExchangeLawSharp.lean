/-
# The sharp single-voter exchange law and its converse

This file continues the tropical / social-choice bridge of
`Tropical/SocialChoice/Chambers.lean`, `Tropical/SocialChoice/ChamberComplex.lean`
and `Tropical/SocialChoice/SupportMatroid.lean`.

The catalog already contains the *one-directional* single-voter exchange law:
from a profile `x` in the chamber of `i`, resetting the score of the single
voter `j` to the threshold `x i + δ i - δ j` lands on the wall between the
chambers of `i` and `j` (`exchange_mem_wall`), and going strictly below the
threshold lands in the open cell `{j}` (`single_voter_exchange`).

Here we prove the exchange law is *sharp and reversible*, and we compute the
whole one-parameter family:

* `tropAgg_update`: the master formula
  `F (update x j c) = min (c + δ j) (min_{k ∈ S \ {j}} (x k + δ k))`.
* `tropAgg_update_of_mem_chamber`: on the chamber of `i` this collapses to
  `F (update x j c) = min (c + δ j) (x i + δ i)`, an explicit piecewise-affine
  function of the single exchanged score, with a kink exactly at the threshold.
* `mem_decisiveSet_update_iff_le`, `mem_decisiveSet_update_incumbent_iff`,
  `decisiveSet_update_eq_singleton_iff`, `exchange_wall_iff`: the exchanged
  voter `j` is decisive iff `c ≤ θ`, the incumbent `i` is decisive iff `θ ≤ c`,
  the profile is in the open cell `{j}` iff `c < θ`, and it is on the wall
  `{i, j}` iff `c = θ`, where `θ = x i + δ i - δ j` is the exchange threshold.
  So the catalog's two exchange theorems are exactly the two halves of a
  trichotomy, with no slack.
* `tropAgg_exchangePath`, `tropAgg_exchangePath_kink`: along the exchange
  segment the social score is `x i + δ i - max t 0`: flat before the wall,
  slope `-1` after it.  The wall is precisely the non-differentiability locus.
* `decisiveSet_update_lower_subset`, `decisiveSet_update_raise_superset`:
  comparative statics — lowering one score can only make *that* voter decisive,
  raising it can only remove *that* voter.
* `single_voter_exchange_converse`, `single_voter_exchange_iff`: the converse
  of the exchange law.  A downward single-voter move out of the open chamber
  of `i` into the open chamber of `j` must be a move of voter `j`, and it
  happens exactly when the new score is below the threshold.  Thus adjacency of
  top-dimensional cells is realized by one-voter exchanges *and only* by them.
* `decisiveSet_coalitionExchange`, `decisiveSet_coalitionExchange_wall`,
  `exists_reach_cell`: the coalition generalization.  Simultaneously exchanging
  the voters of a coalition `T` reaches the open cell `T` (and, at the
  threshold, the cell `T ∪ decisiveSet x`), so every cell of the complex is
  reachable from any chamber by `|T|` single-voter exchanges.
* `abs_tropAgg_sub_le`, `abs_tropAgg_update_sub_le`: the aggregator is
  `1`-Lipschitz for the sup-distance; a single exchange moves the social score
  by at most the size of the exchange.

Finally, a Pythagorean instantiation.  With three voters weighted by the sides
`(a, b, c)` of a Pythagorean triple, the hypotenuse voter is never decisive at
the neutral profile, and the exchange threshold that makes it decisive has size
exactly `c - a > 0` — a strictly positive gap, forced by `a² + b² = c²`.
-/
import Mathlib
import Tropical.SocialChoice.ChamberComplex

namespace PythagoreanExchangeLaw

open Finset TropicalChambers TropicalChamberComplex

variable {ι : Type*}

/-! ## The master formula for a single-voter update -/

/-- **Master formula.**  Updating the single score of `j` replaces the tropical
monomial of `j` by `c + δ j` and leaves the rest of the min-plus expression
alone. -/
theorem tropAgg_update [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ)
    (x : ι → ℝ) {j : ι} (hjS : j ∈ S) (hne : (S.erase j).Nonempty) (c : ℝ) :
    tropAgg S hS δ (Function.update x j c)
      = min (c + δ j) ((S.erase j).inf' hne fun k => x k + δ k) := by
  classical
  set y : ι → ℝ := Function.update x j c with hy
  have hyj : y j = c := by simp [hy]
  have hyk : ∀ k, k ≠ j → y k = x k := fun k hk => by
    simp [hy, Function.update_of_ne hk]
  refine le_antisymm (le_min ?_ ?_) ?_
  · have := Finset.inf'_le (fun k => y k + δ k) hjS
    simpa [tropAgg, hyj] using this
  · refine Finset.le_inf' hne _ ?_
    intro k hk
    have hkj : k ≠ j := (Finset.mem_erase.mp hk).1
    have := Finset.inf'_le (fun m => y m + δ m) (Finset.mem_erase.mp hk).2
    simp only [tropAgg]
    rw [← hyk k hkj]
    exact this
  · refine Finset.le_inf' hS _ ?_
    intro k hk
    by_cases hkj : k = j
    · subst hkj
      exact le_trans (min_le_left _ _) (by rw [hyj])
    · refine le_trans (min_le_right _ _) ?_
      rw [hyk k hkj]
      exact Finset.inf'_le (fun m => x m + δ m) (Finset.mem_erase.mpr ⟨hkj, hk⟩)

/-- On the chamber of `i` the master formula collapses to a minimum of two
affine functions of the exchanged score. -/
theorem tropAgg_update_of_mem_chamber [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty)
    (δ : ι → ℝ) {i j : ι} (hiS : i ∈ S) (hjS : j ∈ S) (hij : i ≠ j) {x : ι → ℝ}
    (hx : x ∈ chamber S δ i) (c : ℝ) :
    tropAgg S hS δ (Function.update x j c) = min (c + δ j) (x i + δ i) := by
  classical
  set y : ι → ℝ := Function.update x j c with hy
  have hyj : y j = c := by simp [hy]
  have hyk : ∀ k, k ≠ j → y k = x k := fun k hk => by
    simp [hy, Function.update_of_ne hk]
  refine le_antisymm (le_min ?_ ?_) ?_
  · have := Finset.inf'_le (fun k => y k + δ k) hjS
    simpa [tropAgg, hyj] using this
  · have := Finset.inf'_le (fun k => y k + δ k) hiS
    simp only [tropAgg] at this ⊢
    rwa [hyk i hij] at this
  · refine Finset.le_inf' hS _ ?_
    intro k hk
    by_cases hkj : k = j
    · subst hkj
      exact le_trans (min_le_left _ _) (by rw [hyj])
    · refine le_trans (min_le_right _ _) ?_
      rw [hyk k hkj]
      exact hx k hk

/-! ## The exchange threshold and the sharp trichotomy -/

/-- The **exchange threshold**: the score that voter `j` must be given in order
to tie with the incumbent `i` on the profile `x`. -/
def exchangeThreshold (δ : ι → ℝ) (x : ι → ℝ) (i j : ι) : ℝ := x i + δ i - δ j

/-- The exchanged voter becomes decisive exactly at and below the threshold. -/
theorem mem_decisiveSet_update_iff_le [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty)
    (δ : ι → ℝ) {i j : ι} (hiS : i ∈ S) (hjS : j ∈ S) (hij : i ≠ j) {x : ι → ℝ}
    (hx : x ∈ chamber S δ i) (c : ℝ) :
    j ∈ decisiveSet S hS δ (Function.update x j c) ↔ c ≤ exchangeThreshold δ x i j := by
  classical
  rw [mem_decisiveSet_iff, tropAgg_update_of_mem_chamber hS δ hiS hjS hij hx c]
  have hyj : (Function.update x j c) j = c := by simp
  rw [hyj]
  constructor
  · intro ⟨_, h⟩
    have := min_le_right (c + δ j) (x i + δ i)
    rw [← h] at this
    simp only [exchangeThreshold]
    linarith
  · intro h
    refine ⟨hjS, ?_⟩
    simp only [exchangeThreshold] at h
    rw [min_eq_left (by linarith)]

/-- The incumbent stays decisive exactly at and above the threshold. -/
theorem mem_decisiveSet_update_incumbent_iff [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty)
    (δ : ι → ℝ) {i j : ι} (hiS : i ∈ S) (hjS : j ∈ S) (hij : i ≠ j) {x : ι → ℝ}
    (hx : x ∈ chamber S δ i) (c : ℝ) :
    i ∈ decisiveSet S hS δ (Function.update x j c) ↔ exchangeThreshold δ x i j ≤ c := by
  classical
  rw [mem_decisiveSet_iff, tropAgg_update_of_mem_chamber hS δ hiS hjS hij hx c]
  have hyi : (Function.update x j c) i = x i := by
    simp [Function.update_of_ne hij]
  rw [hyi]
  constructor
  · intro ⟨_, h⟩
    have := min_le_left (c + δ j) (x i + δ i)
    rw [← h] at this
    simp only [exchangeThreshold]
    linarith
  · intro h
    refine ⟨hiS, ?_⟩
    simp only [exchangeThreshold] at h
    rw [min_eq_right (by linarith)]

/-- **Sharp exchange law.**  The updated profile lies in the open cell `{j}`
exactly when the new score is *strictly* below the exchange threshold.  This
sharpens the catalog's `single_voter_exchange` to an equivalence. -/
theorem decisiveSet_update_eq_singleton_iff [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty)
    (δ : ι → ℝ) {i j : ι} (hiS : i ∈ S) (hjS : j ∈ S) (hij : i ≠ j) {x : ι → ℝ}
    (hx : x ∈ chamber S δ i) (c : ℝ) :
    decisiveSet S hS δ (Function.update x j c) = {j} ↔ c < exchangeThreshold δ x i j := by
  classical
  constructor
  · intro h
    by_contra hle
    push_neg at hle
    have hi : i ∈ decisiveSet S hS δ (Function.update x j c) :=
      (mem_decisiveSet_update_incumbent_iff hS δ hiS hjS hij hx c).mpr hle
    rw [h, Finset.mem_singleton] at hi
    exact hij hi
  · intro hlt
    refine decisiveSet_update_eq_singleton hS δ hjS ?_
    intro k hk hkj
    have h1 := hx k hk
    simp only [exchangeThreshold] at hlt
    linarith

/-- **Sharp wall law.**  The updated profile lies on the wall between the
chambers of `i` and `j` exactly at the threshold.  This sharpens the catalog's
`exchange_mem_wall` to an equivalence. -/
theorem exchange_wall_iff [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty)
    (δ : ι → ℝ) {i j : ι} (hiS : i ∈ S) (hjS : j ∈ S) (hij : i ≠ j) {x : ι → ℝ}
    (hx : x ∈ chamber S δ i) (c : ℝ) :
    ({i, j} : Finset ι) ⊆ decisiveSet S hS δ (Function.update x j c)
      ↔ c = exchangeThreshold δ x i j := by
  classical
  constructor
  · intro h
    have hi : i ∈ decisiveSet S hS δ (Function.update x j c) := h (by simp)
    have hj : j ∈ decisiveSet S hS δ (Function.update x j c) := h (by simp)
    have h1 := (mem_decisiveSet_update_incumbent_iff hS δ hiS hjS hij hx c).mp hi
    have h2 := (mem_decisiveSet_update_iff_le hS δ hiS hjS hij hx c).mp hj
    linarith
  · rintro rfl
    intro k hk
    rcases Finset.mem_insert.mp hk with rfl | hk
    · exact (mem_decisiveSet_update_incumbent_iff hS δ hiS hjS hij hx _).mpr le_rfl
    · rw [Finset.mem_singleton] at hk
      subst hk
      exact (mem_decisiveSet_update_iff_le hS δ hiS hjS hij hx _).mpr le_rfl

/-! ## The exchange path and the kink of the social score -/

/-- The exchange path: starting from `x` in the chamber of `i`, lower the single
score of `j` by `t` past the threshold. -/
noncomputable def exchangePath [DecidableEq ι] (δ : ι → ℝ) (x : ι → ℝ) (i j : ι) (t : ℝ) :
    ι → ℝ := Function.update x j (exchangeThreshold δ x i j - t)

/-- **The social score along the exchange path is piecewise affine with a single
kink at the wall**: constant before the wall, of slope `-1` after it. -/
theorem tropAgg_exchangePath [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ)
    {i j : ι} (hiS : i ∈ S) (hjS : j ∈ S) (hij : i ≠ j) {x : ι → ℝ}
    (hx : x ∈ chamber S δ i) (t : ℝ) :
    tropAgg S hS δ (exchangePath δ x i j t) = x i + δ i - max t 0 := by
  rw [exchangePath, tropAgg_update_of_mem_chamber hS δ hiS hjS hij hx]
  simp only [exchangeThreshold]
  rcases le_total t 0 with ht | ht
  · rw [max_eq_right ht, min_eq_right (by linarith)]
    ring
  · rw [max_eq_left ht, min_eq_left (by linarith)]
    ring

/-- The kink is genuine: the social score is flat on the incumbent side of the
wall and strictly decreasing on the challenger side, so the two one-sided slopes
differ by `1`.  In particular the aggregator is not differentiable at the wall. -/
theorem tropAgg_exchangePath_kink [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ)
    {i j : ι} (hiS : i ∈ S) (hjS : j ∈ S) (hij : i ≠ j) {x : ι → ℝ}
    (hx : x ∈ chamber S δ i) {t : ℝ} (ht : 0 < t) :
    tropAgg S hS δ (exchangePath δ x i j (-t)) = tropAgg S hS δ (exchangePath δ x i j 0) ∧
      tropAgg S hS δ (exchangePath δ x i j 0)
        - tropAgg S hS δ (exchangePath δ x i j t) = t := by
  rw [tropAgg_exchangePath hS δ hiS hjS hij hx, tropAgg_exchangePath hS δ hiS hjS hij hx,
    tropAgg_exchangePath hS δ hiS hjS hij hx]
  rw [max_eq_right (by linarith : (-t : ℝ) ≤ 0), max_eq_left (le_refl (0:ℝ)),
    max_eq_left ht.le]
  constructor <;> ring

/-! ## Comparative statics: who can become decisive -/

/-- The aggregator is monotone in the profile. -/
theorem tropAgg_mono {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ) {x y : ι → ℝ}
    (h : ∀ k, x k ≤ y k) : tropAgg S hS δ x ≤ tropAgg S hS δ y := by
  refine Finset.le_inf' hS _ ?_
  intro k hk
  exact le_trans (Finset.inf'_le (fun m => x m + δ m) hk) (by linarith [h k])

/-- **No spurious pivots.**  Lowering the score of a single voter `k` can only
add `k` to the decisive coalition; every other newly decisive voter was already
decisive. -/
theorem decisiveSet_update_lower_subset [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty)
    (δ : ι → ℝ) {x : ι → ℝ} {k : ι} {c : ℝ} (hc : c ≤ x k) :
    decisiveSet S hS δ (Function.update x k c) ⊆ insert k (decisiveSet S hS δ x) := by
  classical
  intro m hm
  by_cases hmk : m = k
  · subst hmk; exact Finset.mem_insert_self _ _
  refine Finset.mem_insert_of_mem ?_
  obtain ⟨hmS, hmval⟩ := mem_decisiveSet_iff.mp hm
  have hle : tropAgg S hS δ (Function.update x k c) ≤ tropAgg S hS δ x := by
    refine tropAgg_mono hS δ ?_
    intro n
    by_cases hnk : n = k
    · subst hnk; simpa using hc
    · simp [Function.update_of_ne hnk]
  have hxm : (Function.update x k c) m = x m := by
    simp [Function.update_of_ne hmk]
  rw [hxm] at hmval
  have hge : tropAgg S hS δ x ≤ x m + δ m := Finset.inf'_le (fun n => x n + δ n) hmS
  exact mem_decisiveSet_iff.mpr ⟨hmS, le_antisymm (by linarith) hge⟩

/-- **Raising a score cannot unseat anybody else.**  Every voter other than `k`
that was decisive stays decisive after `k`'s score is raised. -/
theorem decisiveSet_update_raise_superset [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty)
    (δ : ι → ℝ) {x : ι → ℝ} {k : ι} {c : ℝ} (hc : x k ≤ c) :
    (decisiveSet S hS δ x).erase k ⊆ decisiveSet S hS δ (Function.update x k c) := by
  classical
  intro m hm
  obtain ⟨hmk, hmem⟩ := Finset.mem_erase.mp hm
  obtain ⟨hmS, hmval⟩ := mem_decisiveSet_iff.mp hmem
  have hge : tropAgg S hS δ x ≤ tropAgg S hS δ (Function.update x k c) := by
    refine tropAgg_mono hS δ ?_
    intro n
    by_cases hnk : n = k
    · subst hnk; simpa using hc
    · simp [Function.update_of_ne hnk]
  have hxm : (Function.update x k c) m = x m := by
    simp [Function.update_of_ne hmk]
  have hle : tropAgg S hS δ (Function.update x k c) ≤ (Function.update x k c) m + δ m :=
    Finset.inf'_le (fun n => (Function.update x k c) n + δ n) hmS
  rw [hxm] at hle
  refine mem_decisiveSet_iff.mpr ⟨hmS, ?_⟩
  rw [hxm]
  linarith

/-! ## The converse of the exchange law -/

/-- **Converse of the exchange law.**  If a downward move of the single voter
`k` carries a profile from the open chamber of `i` into the open chamber of
`j ≠ i`, then the voter that moved is `j` itself.  Adjacency of top-dimensional
cells is realized by one-voter exchanges *and only* by the exchange of the
incoming winner. -/
theorem single_voter_exchange_converse [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty)
    (δ : ι → ℝ) {x : ι → ℝ} {i j k : ι} {c : ℝ} (hxi : decisiveSet S hS δ x = {i})
    (hc : c ≤ x k) (hj : decisiveSet S hS δ (Function.update x k c) = {j}) (hij : j ≠ i) :
    k = j := by
  classical
  have hmem : j ∈ decisiveSet S hS δ (Function.update x k c) := by
    rw [hj]; exact Finset.mem_singleton_self j
  have := decisiveSet_update_lower_subset hS δ hc hmem
  rcases Finset.mem_insert.mp this with h | h
  · exact h.symm
  · rw [hxi, Finset.mem_singleton] at h
    exact absurd h hij

/-- **The exchange law, in both directions.**  Let `x` be a profile in the open
chamber of `i` and let `j ≠ i` be a voter of the support.  Lowering the score of
a single voter `k` to `c` reaches the open cell `{j}` if and only if `k = j` and
`c` is strictly below the exchange threshold. -/
theorem single_voter_exchange_iff [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty)
    (δ : ι → ℝ) {x : ι → ℝ} {i j k : ι} {c : ℝ} (hiS : i ∈ S) (hjS : j ∈ S)
    (hxi : decisiveSet S hS δ x = {i}) (hij : i ≠ j) (hc : c ≤ x k) :
    decisiveSet S hS δ (Function.update x k c) = {j}
      ↔ k = j ∧ c < exchangeThreshold δ x i j := by
  classical
  have hx : x ∈ chamber S δ i := by
    have : i ∈ decisiveSet S hS δ x := by rw [hxi]; exact Finset.mem_singleton_self i
    exact (mem_decisiveSet_iff_mem_chamber.mp this).2
  constructor
  · intro h
    have hkj : k = j :=
      single_voter_exchange_converse hS δ hxi hc h (Ne.symm hij)
    subst hkj
    exact ⟨rfl, (decisiveSet_update_eq_singleton_iff hS δ hiS hjS hij hx c).mp h⟩
  · rintro ⟨rfl, hlt⟩
    exact (decisiveSet_update_eq_singleton_iff hS δ hiS hjS hij hx c).mpr hlt

/-! ## Coalition exchanges: reaching every cell -/

open scoped Classical in
/-- Simultaneous exchange of a whole coalition `T`, each member being given the
score that puts it `ε` below the incumbent's tropical monomial. -/
noncomputable def coalitionExchange (δ : ι → ℝ) (x : ι → ℝ) (i : ι) (T : Finset ι) (ε : ℝ) :
    ι → ℝ := fun k => if k ∈ T then x i + δ i - δ k - ε else x k

open scoped Classical in
lemma coalitionExchange_eq_of_notMem {δ : ι → ℝ} {x : ι → ℝ} {i : ι} {T : Finset ι} {ε : ℝ}
    {k : ι} (hk : k ∉ T) : coalitionExchange δ x i T ε k = x k := by
  simp [coalitionExchange, hk]

open scoped Classical in
lemma coalitionExchange_monomial {δ : ι → ℝ} {x : ι → ℝ} {i : ι} {T : Finset ι} {ε : ℝ}
    {k : ι} (hk : k ∈ T) : coalitionExchange δ x i T ε k + δ k = x i + δ i - ε := by
  simp only [coalitionExchange, if_pos hk]
  ring

/-- **Coalition exchange law.**  From any profile in the chamber of `i`, lowering
the scores of the voters of a nonempty coalition `T ⊆ S` to `ε` below the
incumbent's monomial lands exactly in the open cell labelled `T`.  Hence every
cell of the complex is reached from any chamber by `|T|` single-voter
exchanges. -/
theorem decisiveSet_coalitionExchange {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ)
    {i : ι} {x : ι → ℝ} (hx : x ∈ chamber S δ i) {T : Finset ι} (hTS : T ⊆ S)
    (hT : T.Nonempty) {ε : ℝ} (hε : 0 < ε) :
    decisiveSet S hS δ (coalitionExchange δ x i T ε) = T := by
  classical
  set y : ι → ℝ := coalitionExchange δ x i T ε with hy
  obtain ⟨t, htT⟩ := hT
  have hin : ∀ k ∈ T, y k + δ k = x i + δ i - ε := fun k hk =>
    coalitionExchange_monomial hk
  have hout : ∀ k ∈ S, k ∉ T → x i + δ i - ε < y k + δ k := by
    intro k hk hkT
    rw [hy, coalitionExchange_eq_of_notMem hkT]
    have := hx k hk
    linarith
  have hagg : tropAgg S hS δ y = x i + δ i - ε := by
    refine le_antisymm ?_ ?_
    · have := Finset.inf'_le (fun k => y k + δ k) (hTS htT)
      simp only [tropAgg] at this ⊢
      rw [hin t htT] at this
      exact this
    · refine Finset.le_inf' hS _ ?_
      intro k hk
      by_cases hkT : k ∈ T
      · rw [hin k hkT]
      · exact (hout k hk hkT).le
  ext k
  rw [mem_decisiveSet_iff, hagg]
  constructor
  · rintro ⟨hkS, hkv⟩
    by_contra hkT
    exact absurd hkv.symm (ne_of_lt (hout k hkS hkT))
  · intro hk
    exact ⟨hTS hk, hin k hk⟩

/-- At the threshold (`ε = 0`) the coalition exchange lands on the common wall
of the chambers of `T` and of the previously decisive voters: the label is the
union `T ∪ decisiveSet x`. -/
theorem decisiveSet_coalitionExchange_wall [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ)
    {i : ι} (hiS : i ∈ S) {x : ι → ℝ} (hx : x ∈ chamber S δ i) {T : Finset ι}
    (hTS : T ⊆ S) :
    decisiveSet S hS δ (coalitionExchange δ x i T 0) = T ∪ decisiveSet S hS δ x := by
  classical
  set y : ι → ℝ := coalitionExchange δ x i T 0 with hy
  have hin : ∀ k ∈ T, y k + δ k = x i + δ i := by
    intro k hk
    have := coalitionExchange_monomial (δ := δ) (x := x) (i := i) (T := T) (ε := 0) hk
    simpa using this
  have hout : ∀ k, k ∉ T → y k + δ k = x k + δ k := by
    intro k hk
    rw [hy, coalitionExchange_eq_of_notMem hk]
  have haggx : tropAgg S hS δ x = x i + δ i := tropAgg_eq_on_chamber hS δ hiS hx
  have hagg : tropAgg S hS δ y = x i + δ i := by
    refine le_antisymm ?_ ?_
    · by_cases hiT : i ∈ T
      · have := Finset.inf'_le (fun k => y k + δ k) hiS
        simp only [tropAgg] at this ⊢
        rw [hin i hiT] at this
        exact this
      · have := Finset.inf'_le (fun k => y k + δ k) hiS
        simp only [tropAgg] at this ⊢
        rw [hout i hiT] at this
        exact this
    · refine Finset.le_inf' hS _ ?_
      intro k hk
      by_cases hkT : k ∈ T
      · rw [hin k hkT]
      · rw [hout k hkT]
        exact hx k hk
  ext k
  rw [Finset.mem_union, mem_decisiveSet_iff, mem_decisiveSet_iff, hagg, haggx]
  constructor
  · rintro ⟨hkS, hkv⟩
    by_cases hkT : k ∈ T
    · exact Or.inl hkT
    · rw [hout k hkT] at hkv
      exact Or.inr ⟨hkS, hkv⟩
  · rintro (hk | ⟨hkS, hkv⟩)
    · exact ⟨hTS hk, hin k hk⟩
    · by_cases hkT : k ∈ T
      · exact ⟨hkS, hin k hkT⟩
      · exact ⟨hkS, by rw [hout k hkT, hkv]⟩

/-- **Every cell is reachable by exchanges inside its own label.**  From a
profile `x` in the chamber of `i` and for every nonempty `T ⊆ S` there is a
profile with decisive coalition exactly `T` that differs from `x` only in the
coordinates belonging to `T`. -/
theorem exists_reach_cell {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ) {i : ι}
    {x : ι → ℝ} (hx : x ∈ chamber S δ i) {T : Finset ι} (hTS : T ⊆ S) (hT : T.Nonempty) :
    ∃ y : ι → ℝ, decisiveSet S hS δ y = T ∧ ∀ k ∉ T, y k = x k := by
  classical
  exact ⟨coalitionExchange δ x i T 1,
    decisiveSet_coalitionExchange hS δ hx hTS hT one_pos,
    fun _ hk => coalitionExchange_eq_of_notMem hk⟩

/-! ## Lipschitz control of the exchange -/

/-- The aggregator is `1`-Lipschitz for the sup-distance on profiles. -/
theorem abs_tropAgg_sub_le {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ) {x y : ι → ℝ}
    {M : ℝ} (h : ∀ k, |x k - y k| ≤ M) :
    |tropAgg S hS δ x - tropAgg S hS δ y| ≤ M := by
  have key : ∀ u v : ι → ℝ, (∀ k, u k - v k ≤ M) →
      tropAgg S hS δ u ≤ tropAgg S hS δ v + M := by
    intro u v huv
    have hstep : tropAgg S hS δ u - M ≤ tropAgg S hS δ v := by
      simp only [tropAgg]
      refine Finset.le_inf' hS _ ?_
      intro k hk
      have hk1 : S.inf' hS (fun m => u m + δ m) ≤ u k + δ k :=
        Finset.inf'_le (fun m => u m + δ m) hk
      have := huv k
      linarith
    linarith
  have h1 : tropAgg S hS δ x ≤ tropAgg S hS δ y + M :=
    key x y (fun k => (abs_le.mp (h k)).2)
  have h2 : tropAgg S hS δ y ≤ tropAgg S hS δ x + M := by
    refine key y x (fun k => ?_)
    have := (abs_le.mp (h k)).1
    linarith
  rw [abs_le]
  constructor <;> linarith

/-- A single-voter exchange moves the social score by at most the size of the
exchange: one voter can never swing the outcome by more than the change of its
own score. -/
theorem abs_tropAgg_update_sub_le [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ)
    (x : ι → ℝ) (j : ι) (c : ℝ) :
    |tropAgg S hS δ (Function.update x j c) - tropAgg S hS δ x| ≤ |c - x j| := by
  classical
  refine abs_tropAgg_sub_le hS δ ?_
  intro k
  by_cases hkj : k = j
  · subst hkj; simp
  · simp [Function.update_of_ne hkj]

/-! ## A Pythagorean instantiation

Three voters weighted by the sides of a Pythagorean triple.  The relation
`a² + b² = c²` forces the hypotenuse weight to dominate both legs, so the
hypotenuse voter is *never* decisive at the neutral profile: it can be made
decisive only by a strictly positive exchange, of size exactly `c - a`. -/

/-- In a Pythagorean triple with positive sides the hypotenuse strictly exceeds
each leg. -/
theorem leg_lt_hyp {a b c : ℝ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) : a < c := by
  nlinarith [sq_nonneg (a - c), sq_nonneg (a + c)]

/-- The neutral profile lies in the chamber of the smallest weight. -/
theorem zero_mem_chamber {S : Finset ι} (δ : ι → ℝ) {i : ι} (hmin : ∀ j ∈ S, δ i ≤ δ j) :
    (0 : ι → ℝ) ∈ chamber S δ i := by
  intro j hj
  simpa using hmin j hj

/-- **Pythagorean exchange gap.**  Weight three voters by the sides `a ≤ b < c`
of a Pythagorean triple.  At the neutral profile the leg-`a` voter is decisive,
and the exchange threshold that first makes the hypotenuse voter decisive is
`a - c`, i.e. an exchange of the strictly positive size `c - a`.  The gap is
forced by the Pythagorean relation. -/
theorem pythagorean_exchange_gap {a b c : ℝ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hab : a ≤ b) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let δ : Fin 3 → ℝ := ![a, b, c]
    let S : Finset (Fin 3) := Finset.univ
    (0 : Fin 3 → ℝ) ∈ chamber S δ 0 ∧
      exchangeThreshold δ (0 : Fin 3 → ℝ) 0 2 = a - c ∧
      0 < c - a ∧
      ∀ ε > 0, decisiveSet S ⟨0, Finset.mem_univ 0⟩ δ
        (Function.update (0 : Fin 3 → ℝ) 2 (a - c - ε)) = {2} := by
  intro δ S
  have hac : a < c := leg_lt_hyp ha hb hc h
  have hmem : (0 : Fin 3 → ℝ) ∈ chamber S δ 0 := by
    refine zero_mem_chamber δ ?_
    intro j _
    fin_cases j <;> simp [δ] <;> linarith
  refine ⟨hmem, by simp [exchangeThreshold, δ], by linarith, ?_⟩
  intro ε hε
  have hthr : exchangeThreshold δ (0 : Fin 3 → ℝ) 0 2 = a - c := by
    simp [exchangeThreshold, δ]
  refine (decisiveSet_update_eq_singleton_iff (S := S) ⟨0, Finset.mem_univ 0⟩ δ
    (Finset.mem_univ 0) (Finset.mem_univ 2) (by decide) hmem _).mpr ?_
  rw [hthr]
  linarith

/-- The `(3, 4, 5)` instance, spelled out: the hypotenuse voter needs an
exchange of size `2` to take over from the leg-`3` voter, and any strictly
larger exchange puts it in the open cell `{2}`. -/
theorem pythagorean_exchange_345 (ε : ℝ) (hε : 0 < ε) :
    decisiveSet (Finset.univ : Finset (Fin 3)) ⟨0, Finset.mem_univ 0⟩ ![3, 4, 5]
      (Function.update (0 : Fin 3 → ℝ) 2 (-2 - ε)) = {2} := by
  have := pythagorean_exchange_gap (a := 3) (b := 4) (c := 5) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num)
  obtain ⟨-, -, -, hlast⟩ := this
  have := hlast ε hε
  norm_num at this ⊢
  exact this

end PythagoreanExchangeLaw