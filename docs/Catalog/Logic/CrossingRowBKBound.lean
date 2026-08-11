/-
# A BK upper bound and a cylinder lower bound for grid crossing probabilities

The previous files of this cycle proved the van den Berg–Kesten inequality on a
finite site set (`Catalog/Logic/BKInequalityBernoulli.lean`).  This file puts it
to work on the object of the thread, the horizontal crossing probability
`θ_n(p)` of the `n × n` grid, and sandwiches it between two explicit
polynomials:

`p ^ n ≤ θ_n(p) ≤ (1 - (1 - p) ^ n) ^ n`.

The lower bound is a cylinder bound: a fully open column already crosses.

The upper bound is the interesting half.  A crossing configuration must contain
an open site in *every* row (a grid walk changes its row index by one at a time,
so it cannot jump over a row: `gridWalk_row_invariant`), and these `n` witnesses
live in pairwise disjoint site sets.  Hence the crossing event is contained in
the *disjoint* occurrence of the `n` row events, and the BK inequality — in the
finite-family form `bernProb_bkList_le` proved here — turns the containment into
a product bound.  Harris would give the inequality in the wrong direction, so
this is a genuine application of BK.

## Main results

* `bernProb_allClosedEvent`: `P_p(all sites of S closed) = (1-p) ^ |S|`, the
  closed cylinder formula, via the site-splitting lemma
  `bernProb_inter_closedSite_of_indep`.
* `bernProb_someOpenEvent`: `P_p(some site of S open) = 1 - (1-p) ^ |S|`.
* `bkList`, `bernProb_bkList_le`: disjoint occurrence of a finite list of events
  and the corresponding BK product bound.
* `mem_bkList_of_pairwise_disjoint`: a witness criterion for membership in
  `bkList`.
* `gridWalk_row_invariant`, `crossing_row_open`: a crossing has an open site in
  every row.
* `crossing_bernProb_le_row_prod`: `θ_n(p) ≤ (1 - (1-p) ^ n) ^ n`.
* `crossing_bernProb_ge_pow`: `p ^ n ≤ θ_n(p)`.
* `crossing_bernProb_sandwich`, `crossing_bernProb_half_sandwich`,
  `crossing_bernProb_lt_one`: the combined statements, and the fact that the
  crossing probability is `< 1` for every `p < 1`.
* `crossing_sq_one_lt_two`: a refutation.  The naive doubling bound
  `θ_{2n}(p) ≤ θ_n(p)²` fails already at `n = 1`, because a crossing of the
  `2n × 2n` grid decomposes into crossings of two `2n × n` half rectangles and
  not of two `n × n` grids.
-/

import Logic.BKInequalityBernoulli
import Logic.GridCrossingSmallCases
import Logic.BondSiteLineGraphDomination

open Finset

namespace BernoulliThresholdCoupling

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## Closed cylinders -/

/-- The event that every site of `S` is closed. -/
def allClosedEvent (S : Finset ι) : Set (ι → Bool) := {η | ∀ v ∈ S, η v = false}

/-- The event that some site of `S` is open. -/
def someOpenEvent (S : Finset ι) : Set (ι → Bool) := {η | ∃ v ∈ S, η v = true}

omit [Fintype ι] [DecidableEq ι] in
theorem someOpenEvent_isIncreasing (S : Finset ι) : IsIncreasing (someOpenEvent S) := by
  rintro ω ξ hdom ⟨v, hv, hvo⟩
  exact ⟨v, hv, hdom v hvo⟩

omit [Fintype ι] [DecidableEq ι] in
theorem someOpenEvent_compl (S : Finset ι) :
    (someOpenEvent S)ᶜ = allClosedEvent S := by
  ext η
  simp only [someOpenEvent, allClosedEvent, Set.mem_compl_iff, Set.mem_setOf_eq]
  constructor
  · intro h v hv
    by_contra hc
    exact h ⟨v, hv, by simpa using hc⟩
  · rintro h ⟨v, hv, hvo⟩
    rw [h v hv] at hvo
    exact Bool.noConfusion hvo

omit [Fintype ι] [DecidableEq ι] in
theorem allClosedEvent_empty : allClosedEvent (∅ : Finset ι) = Set.univ := by
  ext η; simp [allClosedEvent]

omit [Fintype ι] in
theorem allClosedEvent_insert {S : Finset ι} {w : ι} :
    allClosedEvent (insert w S) = allClosedEvent S ∩ {η : ι → Bool | η w = false} := by
  ext η
  simp only [allClosedEvent, Set.mem_setOf_eq, Set.mem_inter_iff, Finset.mem_insert]
  constructor
  · intro h
    exact ⟨fun v hv => h v (Or.inr hv), h w (Or.inl rfl)⟩
  · rintro ⟨h1, h2⟩ v (rfl | hv)
    · exact h2
    · exact h1 v hv

/-- **Splitting at a site the event does not see.**  If membership in `A` is
unaffected by the value at `v`, then conditioning on `v` being closed multiplies
the probability by `1 - p`. -/
theorem bernProb_inter_closedSite_of_indep {A : Set (ι → Bool)} {v : ι}
    (hind : ∀ (η : ι → Bool) (b : Bool), Function.update η v b ∈ A ↔ η ∈ A) (p : ℝ) :
    bernProb p (A ∩ {η : ι → Bool | η v = false}) = (1 - p) * bernProb p A := by
  classical
  rw [bernProb_eq_sum_mul_indicator, bernProb_eq_sum_mul_indicator, sum_split v, sum_split v,
    Finset.mul_sum]
  refine Finset.sum_congr rfl fun η hη => ?_
  simp only [mem_filter, mem_univ, true_and] at hη
  have hwη : weight p η = p * offWeight p v η := by
    rw [weight_eq_mul_offWeight p v η, hη]; simp
  have hwη₀ : weight p (Function.update η v false) = (1 - p) * offWeight p v η := by
    rw [weight_eq_mul_offWeight p v (Function.update η v false), offWeight_update]
    simp
  have hAη₀ : (Function.update η v false ∈ A) ↔ η ∈ A := hind η false
  have hnot : η ∉ A ∩ {η : ι → Bool | η v = false} := by
    rintro ⟨-, h2⟩
    simp only [Set.mem_setOf_eq] at h2
    rw [hη] at h2
    exact Bool.noConfusion h2
  rw [hwη, hwη₀, Set.indicator_of_notMem hnot]
  by_cases hA : η ∈ A
  · rw [Set.indicator_of_mem hA, Set.indicator_of_mem (hAη₀.mpr hA),
      Set.indicator_of_mem (show Function.update η v false ∈ A ∩ {η : ι → Bool | η v = false} from
        ⟨hAη₀.mpr hA, by simp⟩)]
    ring
  · rw [Set.indicator_of_notMem hA, Set.indicator_of_notMem (fun hc => hA (hAη₀.mp hc)),
      Set.indicator_of_notMem (fun hc => hA (hAη₀.mp hc.1))]
    ring

omit [Fintype ι] in
/-- A site outside `S` does not affect the closed cylinder of `S`. -/
theorem allClosedEvent_update_of_notMem {S : Finset ι} {w : ι} (hw : w ∉ S)
    (η : ι → Bool) (b : Bool) :
    Function.update η w b ∈ allClosedEvent S ↔ η ∈ allClosedEvent S := by
  constructor
  · intro h v hv
    have hvw : v ≠ w := fun hc => hw (hc ▸ hv)
    have := h v hv
    rwa [Function.update_of_ne hvw] at this
  · intro h v hv
    have hvw : v ≠ w := fun hc => hw (hc ▸ hv)
    rw [Function.update_of_ne hvw]
    exact h v hv

/-- **Closed cylinder probability.**  The probability that all sites of `S` are
closed is `(1 - p) ^ |S|`. -/
theorem bernProb_allClosedEvent (p : ℝ) (S : Finset ι) :
    bernProb p (allClosedEvent S) = (1 - p) ^ S.card := by
  classical
  induction S using Finset.induction_on with
  | empty => simp [allClosedEvent_empty, bernProb_univ]
  | insert w S hw ih =>
    rw [allClosedEvent_insert,
      bernProb_inter_closedSite_of_indep (allClosedEvent_update_of_notMem hw) p, ih,
      Finset.card_insert_of_notMem hw, pow_succ, mul_comm]

/-- **Probability that some site of `S` is open.** -/
theorem bernProb_someOpenEvent (p : ℝ) (S : Finset ι) :
    bernProb p (someOpenEvent S) = 1 - (1 - p) ^ S.card := by
  have h := bernProb_add_bernProb_compl p (someOpenEvent S)
  rw [someOpenEvent_compl, bernProb_allClosedEvent] at h
  linarith

/-! ## Disjoint occurrence of a finite list of events -/

/-- Disjoint occurrence of all the events of a list. -/
def bkList : List (Set (ι → Bool)) → Set (ι → Bool)
  | [] => Set.univ
  | A :: L => disjointOccur A (bkList L)

omit [Fintype ι] in
theorem bkList_isIncreasing : ∀ {L : List (Set (ι → Bool))},
    (∀ A ∈ L, IsIncreasing A) → IsIncreasing (bkList L)
  | [], _ => isIncreasing_univ
  | A :: _, h =>
    disjointOccur_isIncreasing (h A (List.mem_cons_self ..))
      (bkList_isIncreasing fun B hB => h B (List.mem_cons_of_mem _ hB))

/-- **BK for a finite list of increasing events.** -/
theorem bernProb_bkList_le {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    ∀ {L : List (Set (ι → Bool))}, (∀ A ∈ L, IsIncreasing A) →
      bernProb p (bkList L) ≤ (L.map (bernProb p)).prod
  | [], _ => by simp [bkList, bernProb_univ]
  | A :: L, h => by
    have hA : IsIncreasing A := h A (List.mem_cons_self ..)
    have hL : ∀ B ∈ L, IsIncreasing B := fun B hB => h B (List.mem_cons_of_mem _ hB)
    have hstep := bernProb_bk hp0 hp1 hA (bkList_isIncreasing hL)
    have hih := bernProb_bkList_le hp0 hp1 hL
    have hA0 : 0 ≤ bernProb p A := bernProb_nonneg hp0 hp1 A
    calc bernProb p (bkList (A :: L))
        ≤ bernProb p A * bernProb p (bkList L) := hstep
      _ ≤ bernProb p A * (L.map (bernProb p)).prod := mul_le_mul_of_nonneg_left hih hA0
      _ = ((A :: L).map (bernProb p)).prod := by simp

omit [Fintype ι] in
theorem maskOn_maskOn_of_subset {S T : Finset ι} (hST : S ⊆ T) (ω : ι → Bool) :
    maskOn S (maskOn T ω) = maskOn S ω := by
  funext v
  by_cases hv : v ∈ S
  · simp [maskOn, hv, hST hv]
  · simp [maskOn, hv]

omit [Fintype ι] in
/-- **A witness criterion for disjoint occurrence.**  If each event of a list is
already realized by the restriction of `ω` to its own site set, and these site
sets are pairwise disjoint, then `ω` realizes the events disjointly. -/
theorem mem_bkList_of_pairwise_disjoint {ω : ι → Bool} :
    ∀ (L : List (Finset ι × Set (ι → Bool))), (L.map Prod.fst).Pairwise Disjoint →
      (∀ q ∈ L, maskOn q.1 ω ∈ q.2) → ω ∈ bkList (L.map Prod.snd)
  | [], _, _ => Set.mem_univ _
  | q :: L, hpw, hmem => by
    classical
    have hpwL : (L.map Prod.fst).Pairwise Disjoint := by
      simpa using (List.pairwise_cons.mp (by simpa using hpw)).2
    have hdisj : ∀ r ∈ L, Disjoint q.1 r.1 := by
      intro r hr
      exact (List.pairwise_cons.mp (by simpa using hpw)).1 r.1 (List.mem_map_of_mem hr)
    set T : Finset ι := (L.map Prod.fst).foldr (· ∪ ·) ∅ with hT
    have hsubT : ∀ r ∈ L, r.1 ⊆ T := by
      intro r hr
      have : ∀ (M : List (Finset ι)) (s : Finset ι), s ∈ M →
          s ⊆ M.foldr (· ∪ ·) ∅ := by
        intro M
        induction M with
        | nil => intro s hs; exact absurd hs (List.not_mem_nil)
        | cons a M ih =>
          intro s hs
          rcases List.mem_cons.mp hs with rfl | hs'
          · exact fun x hx => Finset.mem_union_left _ hx
          · exact fun x hx => Finset.mem_union_right _ (ih s hs' hx)
      exact this _ r.1 (List.mem_map_of_mem hr)
    have hqT : Disjoint q.1 T := by
      have : ∀ (M : List (Finset ι)), (∀ s ∈ M, Disjoint q.1 s) →
          Disjoint q.1 (M.foldr (· ∪ ·) ∅) := by
        intro M
        induction M with
        | nil => intro _; simp
        | cons a M ih =>
          intro h
          refine Finset.disjoint_union_right.mpr
            ⟨h a (List.mem_cons_self ..), ih fun s hs => h s (List.mem_cons_of_mem _ hs)⟩
      refine this _ ?_
      intro s hs
      obtain ⟨r, hr, rfl⟩ := List.mem_map.mp hs
      exact hdisj r hr
    refine ⟨q.1, T, hqT, hmem q (List.mem_cons_self ..), ?_⟩
    refine mem_bkList_of_pairwise_disjoint L hpwL ?_
    intro r hr
    rw [maskOn_maskOn_of_subset (hsubT r hr)]
    exact hmem r (List.mem_cons_of_mem _ hr)

/-! ## Every row of a crossing contains an open site -/

omit [Fintype ι] [DecidableEq ι] in
/-- A grid walk that avoids row `r` stays on one side of it: a walk changes its
row index by at most one at each step. -/
theorem gridWalk_row_invariant {n r : ℕ} {a b : Fin n × Fin n}
    (w : (gridGraph n).Walk a b) (hsup : ∀ x ∈ w.support, x.1.val ≠ r) :
    (a.1.val < r ↔ b.1.val < r) := by
  induction w with
  | nil => exact Iff.rfl
  | @cons x y z hadj q ih =>
    have hx : x.1.val ≠ r := hsup x (by simp)
    have hy : y.1.val ≠ r := hsup y (by simp)
    have hstepiff : (x.1.val < r ↔ y.1.val < r) := by
      rcases hadj with ⟨h1, -⟩ | ⟨-, h2⟩
      · rw [h1]
      · rcases h2 with h | h <;> constructor <;> intro hlt <;> omega
    refine hstepiff.trans (ih fun u hu => hsup u ?_)
    rw [SimpleGraph.Walk.support_cons]
    exact List.mem_cons_of_mem _ hu

/-- **A crossing configuration has an open site in every row.** -/
theorem crossing_row_open {n : ℕ} (hn : 0 < n) {η : Fin n × Fin n → Bool}
    (hη : η ∈ crossingEvent n hn) (r : Fin n) :
    ∃ j : Fin n, η (r, j) = true := by
  obtain ⟨a, b, w, hw⟩ := hη
  by_contra hc
  push_neg at hc
  have hsup : ∀ x ∈ w.support, x.1.val ≠ r.val := by
    intro x hx hxr
    have hxo := hw x hx
    have : x = (r, x.2) := Prod.ext (Fin.ext hxr) rfl
    rw [this] at hxo
    exact absurd hxo (by simpa using hc x.2)
  have hstart := hsup _ w.start_mem_support
  have hend := hsup _ w.end_mem_support
  have hinv := gridWalk_row_invariant w hsup
  simp only at hstart hend hinv
  have hr : r.val < n := r.isLt
  omega

/-! ## The row sets of the grid -/

/-- The set of sites of the `n × n` grid in row `r`. -/
def gridRow (n : ℕ) (r : Fin n) : Finset (Fin n × Fin n) :=
  ({r} : Finset (Fin n)) ×ˢ (univ : Finset (Fin n))

/-- The set of sites of the `n × n` grid in column `c`. -/
def gridCol (n : ℕ) (c : Fin n) : Finset (Fin n × Fin n) :=
  (univ : Finset (Fin n)) ×ˢ ({c} : Finset (Fin n))

theorem mem_gridRow {n : ℕ} {r : Fin n} {x : Fin n × Fin n} : x ∈ gridRow n r ↔ x.1 = r := by
  simp only [gridRow, Finset.mem_product, Finset.mem_singleton, Finset.mem_univ, and_true]

theorem mem_gridCol {n : ℕ} {c : Fin n} {x : Fin n × Fin n} : x ∈ gridCol n c ↔ x.2 = c := by
  simp only [gridCol, Finset.mem_product, Finset.mem_singleton, Finset.mem_univ, true_and]

theorem card_gridRow (n : ℕ) (r : Fin n) : (gridRow n r).card = n := by
  simp [gridRow]

theorem card_gridCol (n : ℕ) (c : Fin n) : (gridCol n c).card = n := by
  simp [gridCol]

theorem gridRow_disjoint {n : ℕ} {r s : Fin n} (hrs : r ≠ s) :
    Disjoint (gridRow n r) (gridRow n s) := by
  refine Finset.disjoint_left.mpr fun x hx hx' => hrs ?_
  rw [mem_gridRow] at hx hx'
  rw [← hx, hx']

/-! ## The BK upper bound for grid crossings -/

/-- The list of the `n` row events of the grid, tagged with their site sets. -/
def gridRowList (n : ℕ) : List (Finset (Fin n × Fin n) × Set (Fin n × Fin n → Bool)) :=
  (List.finRange n).map (fun r => (gridRow n r, someOpenEvent (gridRow n r)))

/-- A crossing realizes all the row events disjointly. -/
theorem crossing_subset_bkList (n : ℕ) (hn : 0 < n) :
    crossingEvent n hn ⊆ bkList ((gridRowList n).map Prod.snd) := by
  intro η hη
  refine mem_bkList_of_pairwise_disjoint (gridRowList n) ?_ ?_
  · rw [gridRowList, List.map_map]
    refine List.Pairwise.map _ ?_ (List.nodup_finRange n)
    intro r s hrs
    exact gridRow_disjoint hrs
  · intro q hq
    obtain ⟨r, -, rfl⟩ := List.mem_map.mp hq
    obtain ⟨j, hj⟩ := crossing_row_open hn hη r
    refine ⟨(r, j), mem_gridRow.mpr rfl, ?_⟩
    simp only [maskOn, if_pos (mem_gridRow.mpr (rfl : ((r, j) : Fin n × Fin n).1 = r))]
    exact hj

/-- **The BK upper bound for grid crossings.**  The horizontal crossing
probability of the `n × n` grid is at most `(1 - (1-p)^n)^n`: a crossing needs an
open site in each of the `n` rows, and those `n` increasing events occur on
disjoint site sets, so the van den Berg–Kesten inequality applies. -/
theorem crossing_bernProb_le_row_prod (n : ℕ) (hn : 0 < n) {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    bernProb p (crossingEvent n hn) ≤ (1 - (1 - p) ^ n) ^ n := by
  have hrow : ∀ A ∈ (gridRowList n).map Prod.snd,
      IsIncreasing A ∧ bernProb p A = 1 - (1 - p) ^ n := by
    intro A hA
    obtain ⟨q, hq, rfl⟩ := List.mem_map.mp hA
    obtain ⟨r, -, rfl⟩ := List.mem_map.mp hq
    refine ⟨someOpenEvent_isIncreasing _, ?_⟩
    rw [bernProb_someOpenEvent, card_gridRow]
  have hsub := bernProb_mono_subset hp0 hp1 (crossing_subset_bkList n hn)
  have hbk := bernProb_bkList_le (ι := Fin n × Fin n) hp0 hp1
    (L := (gridRowList n).map Prod.snd) (fun A hA => (hrow A hA).1)
  refine hsub.trans (hbk.trans (le_of_eq ?_))
  have hrep : ((gridRowList n).map Prod.snd).map (bernProb p)
      = List.replicate n (1 - (1 - p) ^ n) := by
    rw [List.eq_replicate_iff]
    refine ⟨by simp [gridRowList], ?_⟩
    intro b hb
    obtain ⟨A, hA, rfl⟩ := List.mem_map.mp hb
    exact (hrow A hA).2
  rw [hrep, List.prod_replicate]

/-! ## The cylinder lower bound -/

/-- A fully open column crosses the grid. -/
theorem allOpenEvent_gridCol_subset_crossing (n : ℕ) (hn : 0 < n) (c : Fin n) :
    allOpenEvent (gridCol n c) ⊆ crossingEvent n hn := by
  intro η hη
  obtain ⟨w, hw⟩ := gridGraph_column_walk n hn c (n - 1) (by omega)
  exact ⟨c, c, w, fun x hx => hη x (mem_gridCol.mpr (hw x hx))⟩

/-- **The cylinder lower bound.**  `p ^ n ≤ θ_n(p)`. -/
theorem crossing_bernProb_ge_pow (n : ℕ) (hn : 0 < n) {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    p ^ n ≤ bernProb p (crossingEvent n hn) := by
  have h := bernProb_mono_subset hp0 hp1
    (allOpenEvent_gridCol_subset_crossing n hn ⟨0, hn⟩)
  rwa [bernProb_allOpenEvent, card_gridCol] at h

/-! ## The sandwich -/

/-- **The crossing probability sandwich.** -/
theorem crossing_bernProb_sandwich (n : ℕ) (hn : 0 < n) {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    p ^ n ≤ bernProb p (crossingEvent n hn) ∧
      bernProb p (crossingEvent n hn) ≤ (1 - (1 - p) ^ n) ^ n :=
  ⟨crossing_bernProb_ge_pow n hn hp0 hp1, crossing_bernProb_le_row_prod n hn hp0 hp1⟩

/-- At the self-dual density the sandwich reads `2⁻ⁿ ≤ θ_n(1/2) ≤ (1 - 2⁻ⁿ)ⁿ`. -/
theorem crossing_bernProb_half_sandwich (n : ℕ) (hn : 0 < n) :
    (1 / 2 : ℝ) ^ n ≤ bernProb (1 / 2 : ℝ) (crossingEvent n hn) ∧
      bernProb (1 / 2 : ℝ) (crossingEvent n hn) ≤ (1 - (1 / 2 : ℝ) ^ n) ^ n := by
  have h := crossing_bernProb_sandwich n hn (p := (1 / 2 : ℝ)) (by norm_num) (by norm_num)
  norm_num at h ⊢
  exact h

/-- **The crossing probability is bounded away from one.**  For `p < 1` the BK
bound gives `θ_n(p) < 1`; no coupling or duality argument is needed. -/
theorem crossing_bernProb_lt_one (n : ℕ) (hn : 0 < n) {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p < 1) :
    bernProb p (crossingEvent n hn) < 1 := by
  have hbase : (0 : ℝ) < (1 - p) ^ n := pow_pos (by linarith) n
  have hb1 : (1 : ℝ) - (1 - p) ^ n < 1 := by linarith
  have hb0 : (0 : ℝ) ≤ 1 - (1 - p) ^ n := by
    have : (1 - p) ^ n ≤ 1 := pow_le_one₀ (by linarith) (by linarith)
    linarith
  have hlt : (1 - (1 - p) ^ n) ^ n < 1 := pow_lt_one₀ hb0 hb1 (by omega)
  exact lt_of_le_of_lt (crossing_bernProb_le_row_prod n hn hp0 hp1.le) hlt

/-! ## Consistency with the exactly computed cases -/

/-- For `n = 1` the BK upper bound is attained: `θ_1(p) = p = (1 - (1-p)^1)^1`. -/
theorem crossing_row_bound_sharp_one (p : ℝ) :
    bernProb p (crossingEvent 1 one_pos) = (1 - (1 - p) ^ 1) ^ 1 := by
  rw [crossing_bernProb_one]; ring

/-- For `n = 2` the BK upper bound is strict at every `p ∈ (0,1)`:
`θ_2(p) = 2p² - p⁴ < (2p - p²)² `. -/
theorem crossing_row_bound_strict_two {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) :
    bernProb p (crossingEvent 2 two_pos) < (1 - (1 - p) ^ 2) ^ 2 := by
  rw [crossing_bernProb_two]
  nlinarith [mul_pos (mul_pos hp0 hp0) (mul_pos (sub_pos.mpr hp1) (sub_pos.mpr hp1))]

/-! ## A refuted doubling conjecture -/

/-- **The naive doubling bound `θ_{2n}(p) ≤ θ_n(p)²` is false.**  At `n = 1` the
exact polynomials give `θ_1(p)² = p² < 2p² - p⁴ = θ_2(p)` for every
`p ∈ (0,1)`.  The reason is structural: a top-to-bottom crossing of the `2n × 2n`
grid does split into two crossings on disjoint site sets, but of the two
`2n × n` *half rectangles*, which are easier to cross than the `n × n` grid.  Any
BK-driven decay statement must therefore be phrased with rectangle crossings. -/
theorem crossing_sq_one_lt_two {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) :
    bernProb p (crossingEvent 1 one_pos) ^ 2 < bernProb p (crossingEvent 2 two_pos) := by
  rw [crossing_bernProb_one, crossing_bernProb_two]
  nlinarith [mul_pos hp0 hp0, mul_pos (sub_pos.mpr hp1) (by linarith : (0:ℝ) < 1 + p)]

/-- The same refutation at the self-dual density: `θ_1(1/2)² = 1/4 < 7/16 = θ_2(1/2)`. -/
theorem crossing_sq_one_half_lt_two_half :
    bernProb (1 / 2 : ℝ) (crossingEvent 1 one_pos) ^ 2 <
      bernProb (1 / 2 : ℝ) (crossingEvent 2 two_pos) := by
  rw [crossing_bernProb_one_half, crossing_bernProb_two_half]
  norm_num

end BernoulliThresholdCoupling