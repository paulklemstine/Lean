/-
# Kneser input for many lines: the `(k-2)(p-1)` threshold

Let `v 1, …, v k` be pairwise independent directions in `𝔽_p²` and let
`S 1, …, S k ⊆ 𝔽_p` be sets containing `0`.  Write

  `Reach v S = { ∑ i, s i • v i : s i ∈ S i }`.

The conjecture under investigation ("Kneser input for many lines") asserts

  `∑ i (p - #(S i)) ≤ (k-2)(p-1)  →  Reach v S = 𝔽_p²`.

This file settles the conjecture:

* `three_lines_of_defSum_lt` : the case `k = 3` holds in the sharp form
  `∑ i (p - #(S i)) < p` (which is `(k-2)(p-1) + 1` for `k = 3`).
* `reach_eq_univ_of_defSum_lt_p` : consequently, for every `k ≥ 3`, the weaker
  hypothesis `∑ i (p - #(S i)) ≤ p - 1` already forces `Reach v S = 𝔽_p²`.
* `reach_eq_univ_of_exists_full` : the conjectured bound `(k-2)(p-1)` *is*
  correct as soon as one of the sets is all of `𝔽_p` (iterated Cauchy–Davenport
  in the quotient line).
* `counterexample_p3_k4` and `counterexample_p5_k6` : the conjecture is **false**
  for `k ≥ 4`.  At `p = 3, k = 4` and at `p = 5, k = 6` there are configurations
  with `∑ i (p - #(S i)) = (k-2)(p-1)` whose reach misses a point.  In
  particular the intended exclusion of the `p = 5` profile `(8,2,2,2,2,2)`
  cannot be obtained from the conjecture as stated.
* `reach_eq_univ_of_triple` : the strongest positive criterion available for
  arbitrary `k` — if *some* three distinct indices have deficiency sum `< p`
  then the reach is everything.  It is proved optimal in
  `Computation/KneserManyLinesSharpness.lean`, which also upgrades the two
  sample counterexamples to a uniform family covering every prime `p ≥ 3` and
  every `k` with `4 ≤ k ≤ p + 1`.
-/
import Mathlib

namespace KneserLines

open Finset Pointwise

variable {p : ℕ}

/-- The affine plane `𝔽_p²`. -/
abbrev Plane (p : ℕ) := ZMod p × ZMod p

/-- The set of vectors reachable as `∑ i, s i • v i` with `s i ∈ S i`. -/
def Reach {k : ℕ} (v : Fin k → Plane p) (S : Fin k → Finset (ZMod p)) : Set (Plane p) :=
  {t | ∃ s : Fin k → ZMod p, (∀ i, s i ∈ S i) ∧ ∑ i, s i • v i = t}

/-- Determinant of two plane vectors. -/
def det (a b : Plane p) : ZMod p := a.1 * b.2 - a.2 * b.1

/-- Pairwise independence of a family of directions. -/
def PairwiseIndep {k : ℕ} (v : Fin k → Plane p) : Prop :=
  ∀ i j, i ≠ j → det (v i) (v j) ≠ 0

/-- The total deficiency `∑ i (p - #(S i))`. -/
def defSum {k : ℕ} (S : Fin k → Finset (ZMod p)) : ℕ := ∑ i, (p - #(S i))

lemma det_swap (a b : Plane p) : det a b = -det b a := by
  simp [det]; ring

lemma det_add (a b z : Plane p) : det (a + b) z = det a z + det b z := by
  simp [det]; ring

lemma det_smul (c : ZMod p) (a z : Plane p) : det (c • a) z = c * det a z := by
  simp [det]; ring

lemma det_sum {ι : Type*} (I : Finset ι) (g : ι → Plane p) (z : Plane p) :
    det (∑ i ∈ I, g i) z = ∑ i ∈ I, det (g i) z := by
  classical
  induction I using Finset.induction_on with
  | empty => simp [det]
  | insert a I ha ih => rw [Finset.sum_insert ha, det_add, ih, Finset.sum_insert ha]

/-- A vector with vanishing determinant against a nonzero `z` is a multiple of `z`. -/
lemma exists_smul_of_det_eq_zero [Fact p.Prime] (u z : Plane p) (hz : z ≠ 0)
    (h : det u z = 0) : ∃ a : ZMod p, u = a • z := by
  have hz' : z.1 ≠ 0 ∨ z.2 ≠ 0 := by
    by_contra hcon
    push_neg at hcon
    exact hz (Prod.ext hcon.1 hcon.2)
  rw [det, sub_eq_zero] at h
  rcases hz' with hz1 | hz2
  · refine ⟨u.1 / z.1, Prod.ext ?_ ?_⟩
    · simp [div_mul_cancel₀ _ hz1]
    · show u.2 = u.1 / z.1 * z.2
      field_simp
      linear_combination -h
  · refine ⟨u.2 / z.2, Prod.ext ?_ ?_⟩
    · show u.1 = u.2 / z.2 * z.1
      field_simp
      linear_combination h
    · simp [div_mul_cancel₀ _ hz2]

/-! ### The case of three lines -/

/-- **Three pairwise independent lines.**  If the total deficiency of three sets
`S 0, S 1, S 2 ⊆ 𝔽_p` is less than `p`, then every vector of `𝔽_p²` is of the form
`s 0 • v 0 + s 1 • v 1 + s 2 • v 2` with `s i ∈ S i`.  (Sharp: taking
`S 0 = S 1 = 𝔽_p`, `S 2 = {0}` gives deficiency `p - 1 < p` and total reach, while
deficiency `p` is achieved by non-spanning configurations.) -/
theorem three_lines_of_defSum_lt (hp : p.Prime) (v : Fin 3 → Plane p)
    (hv : PairwiseIndep v) (S : Fin 3 → Finset (ZMod p)) (hd : defSum S < p) :
    Reach v S = Set.univ := by
  haveI : Fact p.Prime := ⟨hp⟩
  classical
  ext t
  simp only [Set.mem_univ, iff_true, Reach, Set.mem_setOf_eq]
  have hD0 : det (v 0) (v 1) ≠ 0 := hv 0 1 (by decide)
  set D := det (v 0) (v 1) with hD
  set α : ZMod p := (t.1 * (v 1).2 - t.2 * (v 1).1) / D with hα
  set β : ZMod p := ((v 0).1 * t.2 - (v 0).2 * t.1) / D with hβ
  set γ : ZMod p := ((v 2).1 * (v 1).2 - (v 2).2 * (v 1).1) / D with hγdef
  set δ : ZMod p := ((v 0).1 * (v 2).2 - (v 0).2 * (v 2).1) / D with hδdef
  have hbasis : α • v 0 + β • v 1 = t := by
    have h1 : α * (v 0).1 + β * (v 1).1 = t.1 := by
      rw [hα, hβ, div_mul_eq_mul_div, div_mul_eq_mul_div, ← add_div, div_eq_iff hD0, hD, det]; ring
    have h2 : α * (v 0).2 + β * (v 1).2 = t.2 := by
      rw [hα, hβ, div_mul_eq_mul_div, div_mul_eq_mul_div, ← add_div, div_eq_iff hD0, hD, det]; ring
    refine Prod.ext ?_ ?_ <;> simpa using ‹_›
  have hv2 : γ • v 0 + δ • v 1 = v 2 := by
    have h1 : γ * (v 0).1 + δ * (v 1).1 = (v 2).1 := by
      rw [hγdef, hδdef, div_mul_eq_mul_div, div_mul_eq_mul_div, ← add_div, div_eq_iff hD0, hD, det]
      ring
    have h2 : γ * (v 0).2 + δ * (v 1).2 = (v 2).2 := by
      rw [hγdef, hδdef, div_mul_eq_mul_div, div_mul_eq_mul_div, ← add_div, div_eq_iff hD0, hD, det]
      ring
    refine Prod.ext ?_ ?_ <;> simpa using ‹_›
  have hγ : γ ≠ 0 := by
    simp only [hγdef, ne_eq, div_eq_zero_iff, not_or]
    exact ⟨hv 2 1 (by decide), hD0⟩
  have hδ : δ ≠ 0 := by
    simp only [hδdef, ne_eq, div_eq_zero_iff, not_or]
    exact ⟨hv 0 2 (by decide), hD0⟩
  by_contra hcon
  push_neg at hcon
  have key : ∀ c : ZMod p, c ∉ S 2 ∨ α - γ * c ∉ S 0 ∨ β - δ * c ∉ S 1 := by
    intro c
    by_contra hc
    push_neg at hc
    obtain ⟨h2, h0, h1⟩ := hc
    refine hcon ![α - γ * c, β - δ * c, c] ?_ ?_
    · intro i; fin_cases i <;> simpa
    · rw [Fin.sum_univ_three]
      simp only [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two,
        Matrix.tail_cons]
      rw [← hbasis, ← hv2]
      module
  have hcover : (univ : Finset (ZMod p)) ⊆
      (((S 0)ᶜ.image (fun u => (α - u) / γ)) ∪ ((S 1)ᶜ.image (fun u => (β - u) / δ))) ∪ (S 2)ᶜ := by
    intro c _
    rcases key c with h | h | h
    · exact mem_union_right _ (by simpa using h)
    · refine mem_union_left _ (mem_union_left _ ?_)
      refine mem_image.2 ⟨α - γ * c, by simpa using h, ?_⟩
      field_simp
      ring
    · refine mem_union_left _ (mem_union_right _ ?_)
      refine mem_image.2 ⟨β - δ * c, by simpa using h, ?_⟩
      field_simp
      ring
  have hcard : p ≤ (p - #(S 0)) + (p - #(S 1)) + (p - #(S 2)) := by
    have h1 : #((S 0)ᶜ.image (fun u => (α - u) / γ)) ≤ p - #(S 0) := by
      refine (card_image_le).trans ?_
      simp [card_compl, ZMod.card]
    have h2 : #((S 1)ᶜ.image (fun u => (β - u) / δ)) ≤ p - #(S 1) := by
      refine (card_image_le).trans ?_
      simp [card_compl, ZMod.card]
    have h3 : #((S 2)ᶜ) = p - #(S 2) := by simp [card_compl, ZMod.card]
    have hle := card_le_card hcover
    rw [card_univ, ZMod.card] at hle
    refine hle.trans ?_
    refine (card_union_le _ _).trans ?_
    exact add_le_add ((card_union_le _ _).trans (add_le_add h1 h2)) h3.le
  rw [defSum, Fin.sum_univ_three] at hd
  omega

/-! ### Consequences for many lines -/

theorem reach_eq_univ_of_triple {k : ℕ} (hp : p.Prime) (v : Fin k → Plane p)
    (hv : PairwiseIndep v) (S : Fin k → Finset (ZMod p)) (h0 : ∀ i, (0 : ZMod p) ∈ S i)
    (i j l : Fin k) (hij : i ≠ j) (hil : i ≠ l) (hjl : j ≠ l)
    (hd : (p - #(S i)) + (p - #(S j)) + (p - #(S l)) < p) :
    Reach v S = Set.univ := by
  classical
  have hindep : PairwiseIndep ![v i, v j, v l] := by
    intro a b hab
    fin_cases a <;> fin_cases b <;> simp_all [det] <;>
      first
        | exact hv i j hij | exact hv j i (Ne.symm hij)
        | exact hv i l hil | exact hv l i (Ne.symm hil)
        | exact hv j l hjl | exact hv l j (Ne.symm hjl)
  have hdef : defSum ![S i, S j, S l] < p := by
    simpa [defSum, Fin.sum_univ_three] using hd
  have h3 := three_lines_of_defSum_lt hp _ hindep _ hdef
  ext t
  simp only [Set.mem_univ, iff_true]
  have ht : t ∈ Reach ![v i, v j, v l] ![S i, S j, S l] := by rw [h3]; trivial
  obtain ⟨s, hs, hsum⟩ := ht
  refine ⟨fun m => if m = i then s 0 else if m = j then s 1 else if m = l then s 2 else 0, ?_, ?_⟩
  · intro m
    by_cases hm : m = i
    · subst hm; simpa using hs 0
    · by_cases hm2 : m = j
      · subst hm2; simp only [if_neg hm]; simpa using hs 1
      · by_cases hm3 : m = l
        · subst hm3; simp only [if_neg hm, if_neg hm2]; simpa using hs 2
        · simp [hm, hm2, hm3, h0 m]
  · rw [← Finset.sum_subset (Finset.subset_univ ({i, j, l} : Finset (Fin k)))]
    · rw [Finset.sum_insert (by simp [hij, hil]), Finset.sum_insert (by simp [hjl]),
        Finset.sum_singleton]
      simp only [if_neg (Ne.symm hij), if_neg (Ne.symm hil), if_neg (Ne.symm hjl)]
      rw [Fin.sum_univ_three] at hsum
      rw [← add_assoc]
      simpa [Matrix.cons_val] using hsum
    · intro m _ hm
      simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hm
      simp [hm.1, hm.2.1, hm.2.2]

/-- For any number `k ≥ 3` of pairwise independent directions, total deficiency
`< p` already forces the reach to be everything. -/
theorem reach_eq_univ_of_defSum_lt_p {k : ℕ} (hp : p.Prime) (hk : 3 ≤ k)
    (v : Fin k → Plane p) (hv : PairwiseIndep v) (S : Fin k → Finset (ZMod p))
    (h0 : ∀ i, (0 : ZMod p) ∈ S i) (hd : defSum S < p) :
    Reach v S = Set.univ := by
  classical
  set i : Fin k := ⟨0, by omega⟩
  set j : Fin k := ⟨1, by omega⟩
  set l : Fin k := ⟨2, by omega⟩
  have hij : i ≠ j := by simp [i, j, Fin.ext_iff]
  have hil : i ≠ l := by simp [i, l, Fin.ext_iff]
  have hjl : j ≠ l := by simp [j, l, Fin.ext_iff]
  refine reach_eq_univ_of_triple hp v hv S h0 i j l hij hil hjl ?_
  have hsub : ({i, j, l} : Finset (Fin k)) ⊆ Finset.univ := Finset.subset_univ _
  have hle := Finset.sum_le_sum_of_subset (f := fun m => p - #(S m)) hsub
  rw [Finset.sum_insert (by simp [hij, hil]), Finset.sum_insert (by simp [hjl]),
    Finset.sum_singleton] at hle
  have h2 : (p - #(S i)) + (p - #(S j)) + (p - #(S l)) ≤ defSum S := by
    simpa [defSum, add_assoc] using hle
  omega

/-! ### Iterated Cauchy–Davenport and the "one full set" case -/

/-- Iterated Cauchy–Davenport, in representation form: there is a set `A` of
scalars of size at least `min p (∑ #(T i) + 1 - #I)` all of whose elements are
represented as `∑ i ∈ I, c i * s i` with `s i ∈ T i`. -/
lemma exists_big_repr_set (hp : p.Prime) {ι : Type*} [DecidableEq ι] (I : Finset ι)
    (c : ι → ZMod p) (T : ι → Finset (ZMod p)) (hne : ∀ i ∈ I, (T i).Nonempty)
    (hc : ∀ i ∈ I, c i ≠ 0) :
    ∃ A : Finset (ZMod p),
      (∀ x ∈ A, ∃ s : ι → ZMod p, (∀ i ∈ I, s i ∈ T i) ∧ ∑ i ∈ I, c i * s i = x) ∧
      min p ((∑ i ∈ I, #(T i)) + 1 - #I) ≤ #A := by
  haveI : Fact p.Prime := ⟨hp⟩
  classical
  induction I using Finset.induction_on with
  | empty =>
      refine ⟨{0}, ?_, ?_⟩
      · intro x hx
        simp only [Finset.mem_singleton] at hx
        exact ⟨fun _ => 0, by simp, by simp [hx]⟩
      · simp
  | insert a I ha ih =>
      obtain ⟨A, hA, hcardA⟩ := ih (fun i hi => hne i (Finset.mem_insert_of_mem hi))
        (fun i hi => hc i (Finset.mem_insert_of_mem hi))
      have hTa : (T a).Nonempty := hne a (Finset.mem_insert_self a I)
      have hca : c a ≠ 0 := hc a (Finset.mem_insert_self a I)
      have hsumI : #I ≤ ∑ i ∈ I, #(T i) := by
        calc #I = ∑ _i ∈ I, 1 := by simp
        _ ≤ ∑ i ∈ I, #(T i) :=
            Finset.sum_le_sum (fun i hi => (hne i (Finset.mem_insert_of_mem hi)).card_pos)
      have hp2 : 2 ≤ p := hp.two_le
      have hAne : A.Nonempty := by
        rw [← Finset.card_pos]
        omega
      set B : Finset (ZMod p) := (T a).image (fun y => c a * y) with hB
      have hcardB : #B = #(T a) := by
        rw [hB]
        exact Finset.card_image_of_injective _ (mul_right_injective₀ hca)
      have hBne : B.Nonempty := by rw [hB]; exact hTa.image _
      have hcd := ZMod.cauchy_davenport hp hBne hAne
      refine ⟨B + A, ?_, ?_⟩
      · intro x hx
        rw [Finset.mem_add] at hx
        obtain ⟨b, hb, y, hy, hxy⟩ := hx
        rw [hB, Finset.mem_image] at hb
        obtain ⟨z, hz, rfl⟩ := hb
        obtain ⟨s, hs, hsum⟩ := hA y hy
        refine ⟨Function.update s a z, ?_, ?_⟩
        · intro i hi
          rcases Finset.mem_insert.1 hi with h | h
          · subst h; simpa using hz
          · rw [Function.update_of_ne (by rintro rfl; exact ha h)]
            exact hs i h
        · rw [Finset.sum_insert ha, Function.update_self]
          have hcongr : ∑ i ∈ I, c i * Function.update s a z i = ∑ i ∈ I, c i * s i := by
            refine Finset.sum_congr rfl (fun i hi => ?_)
            rw [Function.update_of_ne (by rintro rfl; exact ha hi)]
          rw [hcongr, hsum, hxy]
      · rw [Finset.card_insert_of_notMem ha, Finset.sum_insert ha]
        have h1 : 1 ≤ #(T a) := hTa.card_pos
        omega

/-- **The conjectured bound holds when one of the sets is everything.**  If
`S i₀ = 𝔽_p` for some `i₀`, then `∑ i (p - #(S i)) ≤ (k-2)(p-1)` implies that the
reach is all of `𝔽_p²`. -/
theorem reach_eq_univ_of_exists_full {k : ℕ} (hp : p.Prime) (hk : 2 ≤ k)
    (v : Fin k → Plane p) (hv : PairwiseIndep v) (S : Fin k → Finset (ZMod p))
    (h0 : ∀ i, (0 : ZMod p) ∈ S i) (i₀ : Fin k) (hfull : ∀ x : ZMod p, x ∈ S i₀)
    (hd : defSum S ≤ (k - 2) * (p - 1)) :
    Reach v S = Set.univ := by
  haveI : Fact p.Prime := ⟨hp⟩
  classical
  have hp2 : 2 ≤ p := hp.two_le
  set I : Finset (Fin k) := Finset.univ.erase i₀ with hI
  have hcard_I : #I = k - 1 := by
    rw [hI, Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ, Fintype.card_fin]
  have hne : ∀ i ∈ I, (S i).Nonempty := fun i _ => ⟨0, h0 i⟩
  have hcne : ∀ i ∈ I, det (v i) (v i₀) ≠ 0 := fun i hi => hv i i₀ (Finset.ne_of_mem_erase hi)
  have hcardS : ∀ i, #(S i) ≤ p := by
    intro i; simpa [ZMod.card] using (S i).card_le_univ
  have hSi₀ : #(S i₀) = p := by
    have hu : S i₀ = Finset.univ := Finset.eq_univ_iff_forall.2 hfull
    rw [hu, Finset.card_univ, ZMod.card]
  have hn : p + (k - 1) ≤ (∑ i ∈ I, #(S i)) + 1 := by
    have hsplit : (∑ i ∈ I, #(S i)) + (∑ i ∈ I, (p - #(S i))) = (k - 1) * p := by
      rw [← Finset.sum_add_distrib]
      rw [Finset.sum_congr rfl (fun i _ => Nat.add_sub_cancel' (hcardS i))]
      rw [Finset.sum_const, hcard_I, smul_eq_mul]
    have hdI : (∑ i ∈ I, (p - #(S i))) = defSum S := by
      rw [defSum, hI, ← Finset.sum_erase_add _ _ (Finset.mem_univ i₀), hSi₀]
      simp
    obtain ⟨m, rfl⟩ : ∃ m, k = m + 2 := ⟨k - 2, by omega⟩
    obtain ⟨q, rfl⟩ : ∃ q, p = q + 1 := ⟨p - 1, by omega⟩
    simp only [Nat.add_sub_cancel] at hd hsplit ⊢
    have hexp : (m + 2 - 1) * (q + 1) = m * q + m + q + 1 := by
      have h' : m + 2 - 1 = m + 1 := by omega
      rw [h']; ring
    rw [hexp, hdI] at hsplit
    omega
  obtain ⟨A, hA, hcardA⟩ := exists_big_repr_set hp I (fun i => det (v i) (v i₀)) S hne hcne
  have hAuniv : A = Finset.univ := by
    have hge : p ≤ #A := le_trans (le_min le_rfl (by omega)) hcardA
    have hle : #A ≤ p := by simpa [ZMod.card] using A.card_le_univ
    exact Finset.eq_univ_of_card A (by rw [ZMod.card]; omega)
  ext t
  simp only [Set.mem_univ, iff_true]
  obtain ⟨s, hs, hsum⟩ := hA (det t (v i₀)) (hAuniv ▸ Finset.mem_univ _)
  set w : Plane p := ∑ i ∈ I, s i • v i with hw
  have hdetw : det (t - w) (v i₀) = 0 := by
    have h1 : det w (v i₀) = ∑ i ∈ I, det (v i) (v i₀) * s i := by
      rw [hw, det_sum]
      exact Finset.sum_congr rfl (fun i _ => by rw [det_smul]; ring)
    have h2 : det (t - w) (v i₀) = det t (v i₀) - det w (v i₀) := by
      simp [det, Prod.fst_sub, Prod.snd_sub]; ring
    rw [h2, h1, hsum, sub_self]
  have hvz : v i₀ ≠ 0 := by
    obtain ⟨j, hj⟩ : ∃ j : Fin k, j ≠ i₀ := by
      haveI : Nontrivial (Fin k) := Fin.nontrivial_iff_two_le.2 hk
      exact exists_ne i₀
    intro hzero
    exact hv j i₀ hj (by simp [det, hzero])
  obtain ⟨a, ha⟩ := exists_smul_of_det_eq_zero (t - w) (v i₀) hvz hdetw
  refine ⟨fun i => if i = i₀ then a else s i, ?_, ?_⟩
  · intro i
    by_cases hi : i = i₀
    · subst hi; simp [hfull]
    · simp only [if_neg hi]
      exact hs i (Finset.mem_erase.2 ⟨hi, Finset.mem_univ i⟩)
  · have hrest : ∑ i ∈ I, (if i = i₀ then a else s i) • v i = w := by
      rw [hw]
      refine Finset.sum_congr rfl (fun i hi => ?_)
      rw [if_neg (Finset.ne_of_mem_erase hi)]
    calc ∑ i, (if i = i₀ then a else s i) • v i
        = (∑ i ∈ I, (if i = i₀ then a else s i) • v i)
            + (if i₀ = i₀ then a else s i₀) • v i₀ := by
          rw [hI]; exact (Finset.sum_erase_add _ _ (Finset.mem_univ i₀)).symm
      _ = w + a • v i₀ := by rw [hrest, if_pos rfl]
      _ = t := by rw [← ha]; abel

/-! ### Refutation of the general conjecture -/

/-- The `p = 3`, `k = 4` counterexample: four pairwise independent directions and
four two-element sets, of total deficiency `4 = (k-2)(p-1)`, whose reach misses
`(2,0)`. -/
theorem counterexample_p3_k4 :
    ∃ (v : Fin 4 → Plane 3) (S : Fin 4 → Finset (ZMod 3)),
      PairwiseIndep v ∧ (∀ i, (0 : ZMod 3) ∈ S i) ∧
      defSum S = (4 - 2) * (3 - 1) ∧ Reach v S ≠ Set.univ := by
  refine ⟨![(1,0),(0,1),(1,1),(2,1)], ![{0,1},{0,1},{0,1},{0,1}], ?_, ?_, ?_, ?_⟩
  · unfold PairwiseIndep det; decide
  · decide
  · decide
  · intro h
    have hmem : ((2 : ZMod 3), (0 : ZMod 3)) ∈
        Reach ![((1:ZMod 3),(0:ZMod 3)),(0,1),(1,1),(2,1)] ![{0,1},{0,1},{0,1},{0,1}] := by
      rw [h]; trivial
    revert hmem
    simp only [Reach, Set.mem_setOf_eq]
    decide

/-- The `p = 5`, `k = 6` counterexample, the case relevant to the profile
`(8,2,2,2,2,2)`: six pairwise independent directions in `𝔽_5²` with total
deficiency `16 = (k-2)(p-1)` whose reach is not everything. -/
theorem counterexample_p5_k6 :
    ∃ (v : Fin 6 → Plane 5) (S : Fin 6 → Finset (ZMod 5)),
      PairwiseIndep v ∧ (∀ i, (0 : ZMod 5) ∈ S i) ∧
      defSum S = (6 - 2) * (5 - 1) ∧ Reach v S ≠ Set.univ := by
  refine ⟨![(1,0),(0,1),(1,1),(2,1),(3,1),(4,1)],
    ![{0,1,2,3},{0,1,2,3},{0,1},{0},{0},{0,1}], ?_, ?_, ?_, ?_⟩
  · unfold PairwiseIndep det; decide
  · decide
  · decide
  · intro h
    have hmem : ((4 : ZMod 5), (0 : ZMod 5)) ∈
        Reach ![((1:ZMod 5),(0:ZMod 5)),(0,1),(1,1),(2,1),(3,1),(4,1)]
          ![{0,1,2,3},{0,1,2,3},{0,1},{0},{0},{0,1}] := by
      rw [h]; trivial
    obtain ⟨s, hs, hsum⟩ := hmem
    have h0 := hs 0
    have h1 := hs 1
    have h2 := hs 2
    have h3 := hs 3
    have h4 := hs 4
    have h5 := hs 5
    simp [Matrix.cons_val] at h0 h1 h2 h3 h4 h5
    rw [Fin.sum_univ_six] at hsum
    simp [Matrix.cons_val, Prod.ext_iff, h3, h4] at hsum
    exact absurd hsum (by revert h0 h1 h2 h5; exact (by decide : ∀ a b c e : ZMod 5,
      (a = 0 ∨ a = 1 ∨ a = 2 ∨ a = 3) → (b = 0 ∨ b = 1 ∨ b = 2 ∨ b = 3) →
      (c = 0 ∨ c = 1) → (e = 0 ∨ e = 1) →
      ¬ (a + c + e * 4 = 4 ∧ b + c + e = 0)) (s 0) (s 1) (s 2) (s 5))

end KneserLines