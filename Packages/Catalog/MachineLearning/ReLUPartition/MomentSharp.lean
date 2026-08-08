import Mathlib
import MachineLearning.ReLUPartition.SignVectors
import MachineLearning.ReLUPartition.ParityCode

/-!
# Exact sharpness of the Schläfli bound: the moment-curve ReLU layer

This file completes the exact maximum-region formula for a single ReLU layer by
exhibiting, for **every** width `n` and **every** input dimension `d`, a layer
attaining the Schläfli bound `∑_{k ≤ d} C(n,k)` proved in
`MachineLearning.ReLUPartition.SignVectors`.

The construction places the neurons on the moment curve: neuron `i` has weight
vector `(i^0, i^1, …, i^{d-1})` and bias `i^d`, so that its pre-activation at
input `x` is

  `P_x(i)`,  where  `P_x = X^d + ∑_{j<d} x_j X^j`

is the **generic monic polynomial of degree `d`**.  Hence the realizable
activation patterns are exactly the sets

  `{i | P(i) > 0}`,  `P` monic of degree `d`,

and the problem becomes a question about sign patterns of real polynomials:

* a monic degree-`d` polynomial has at most `d` real roots, and every change of
  the sign string `(sign P(0), …, sign P(n-1), +)` costs one root — so the
  change set of a realizable pattern has at most `d` elements;
* conversely any pattern whose change set `C` has `|C| ≤ d` is realized by
  `∏_{j ∈ C} (X - (j + 1/2)) · (X + 1)^{d - |C|}`, whose extra roots are parked
  to the left of all sample points and therefore invisible.

Combining with the change-set bijection of
`MachineLearning.ReLUPartition.ParityCode` gives exactly `schlafli n d` regions,
and hence the exact maximum-region formula `maximum_regionCount`.
-/

open Finset Polynomial

namespace ReLUPartition

variable {n d : ℕ}

/-! ### Monic polynomials as coefficient vectors -/

/-- The monic degree-`d` polynomial with lower coefficients `x`. -/
noncomputable def coeffPoly (d : ℕ) (x : Fin d → ℝ) : ℝ[X] :=
  X ^ d + ∑ j, C (x j) * X ^ (j : ℕ)

lemma degree_lower_lt (d : ℕ) (x : Fin d → ℝ) :
    (∑ j, C (x j) * X ^ (j : ℕ)).degree < (d : WithBot ℕ) := by
  refine lt_of_le_of_lt (Polynomial.degree_sum_le _ _) ?_
  rw [Finset.sup_lt_iff (by exact_mod_cast WithBot.bot_lt_coe d)]
  intro j _
  refine lt_of_le_of_lt (Polynomial.degree_C_mul_X_pow_le _ _) ?_
  exact_mod_cast j.isLt

lemma coeffPoly_monic (d : ℕ) (x : Fin d → ℝ) : (coeffPoly d x).Monic :=
  Polynomial.monic_X_pow_add (degree_lower_lt d x)

lemma coeffPoly_natDegree (d : ℕ) (x : Fin d → ℝ) : (coeffPoly d x).natDegree = d := by
  unfold coeffPoly
  refine Polynomial.natDegree_eq_of_degree_eq_some ?_
  rw [Polynomial.degree_add_eq_left_of_degree_lt (by simpa using degree_lower_lt d x)]
  simp

lemma eval_coeffPoly (d : ℕ) (x : Fin d → ℝ) (t : ℝ) :
    (coeffPoly d x).eval t = t ^ d + ∑ j, x j * t ^ (j : ℕ) := by
  simp [coeffPoly, Polynomial.eval_finset_sum]

/-- Every monic polynomial of degree `d` is `coeffPoly d x` for some `x`. -/
lemma exists_coeffPoly (P : ℝ[X]) (hm : P.Monic) (hd : P.natDegree = d) :
    ∃ x : Fin d → ℝ, coeffPoly d x = P := by
  classical
  refine ⟨fun j => P.coeff (j : ℕ), ?_⟩
  ext k
  rw [coeffPoly, Polynomial.coeff_add, Polynomial.coeff_X_pow, Polynomial.finset_sum_coeff]
  have hsum : (∑ j : Fin d, (C (P.coeff (j : ℕ)) * X ^ (j : ℕ)).coeff k)
      = if h : k < d then P.coeff k else 0 := by
    by_cases hk : k < d
    · rw [dif_pos hk, Finset.sum_eq_single (⟨k, hk⟩ : Fin d)]
      · simp
      · intro j _ hj
        have : k ≠ (j : ℕ) := by
          intro hcon
          exact hj (Fin.eq_of_val_eq hcon.symm)
        simp [this]
      · intro hcon
        exact absurd (Finset.mem_univ _) hcon
    · rw [dif_neg hk]
      refine Finset.sum_eq_zero fun j _ => ?_
      have : k ≠ (j : ℕ) := by
        intro hcon
        exact hk (hcon ▸ j.isLt)
      simp [this]
  rw [hsum]
  rcases lt_trichotomy k d with h | h | h
  · rw [if_neg (by omega), dif_pos h, zero_add]
  · have hc : P.coeff d = 1 := by rw [← hd]; exact hm.coeff_natDegree
    rw [if_pos h, dif_neg (by omega), add_zero, h, hc]
  · rw [if_neg (by omega), dif_neg (by omega), add_zero]
    exact (Polynomial.coeff_eq_zero_of_natDegree_lt (by omega)).symm

/-- The gap between a monic polynomial and its leading term has smaller degree. -/
lemma degree_sub_X_pow_lt (P : ℝ[X]) (hm : P.Monic) (hdeg : P.natDegree = d) :
    (P - X ^ d).degree < (d : WithBot ℕ) := by
  have hdP : P.degree = (d : WithBot ℕ) := by
    rw [Polynomial.degree_eq_natDegree hm.ne_zero, hdeg]
  have hsub : (P - X ^ d).degree < P.degree :=
    Polynomial.degree_sub_lt (by simp [hdP]) hm.ne_zero (by simp [hm.leadingCoeff])
  rwa [hdP] at hsub

/-! ### The moment-curve layer -/

/-- The moment-curve ReLU layer: neuron `i` has weights `(i^j)_{j<d}` and
bias `i^d`, so its pre-activation is the generic monic degree-`d` polynomial
evaluated at `i`. -/
def momentFamily (n d : ℕ) : AffineFamily n d :=
  { weight := fun i j => (i : ℝ) ^ (j : ℕ)
    bias := fun i => (i : ℝ) ^ d }

lemma eval_momentFamily (n d : ℕ) (i : Fin n) (x : Fin d → ℝ) :
    (momentFamily n d).eval i x = (coeffPoly d x).eval (i : ℝ) := by
  rw [eval_coeffPoly]
  simp only [AffineFamily.eval, momentFamily]
  rw [add_comm]
  congr 1
  exact Finset.sum_congr rfl fun j _ => by ring

/-- The pattern realized by an input is the positivity pattern of the
corresponding monic polynomial on the sample points `0, 1, …, n-1`. -/
lemma pattern_momentFamily (n d : ℕ) (x : Fin d → ℝ) :
    (momentFamily n d).pattern x
      = univ.filter (fun i : Fin n => 0 < (coeffPoly d x).eval (i : ℝ)) := by
  classical
  ext i
  rw [AffineFamily.mem_pattern, eval_momentFamily]
  simp

/-! ### Forward direction: a realizable pattern has a small change set -/

/-- A monic polynomial can be lowered by a tiny constant without changing its
positivity pattern on the sample points, and so as to avoid vanishing there. -/
lemma exists_perturb (P : ℝ[X]) (hm : P.Monic) (hdeg : P.natDegree = d) (hd : 1 ≤ d) (n : ℕ) :
    ∃ Q : ℝ[X], Q.Monic ∧ Q.natDegree = d ∧ (∀ i : Fin n, Q.eval (i : ℝ) ≠ 0) ∧
      (∀ i : Fin n, (0 < Q.eval (i : ℝ) ↔ 0 < P.eval (i : ℝ))) := by
  classical
  -- pick `ε` smaller than every positive value of `P` on the sample points
  obtain ⟨ε, hε0, hεlt⟩ : ∃ ε : ℝ, 0 < ε ∧ ∀ i : Fin n, 0 < P.eval (i : ℝ) → ε < P.eval (i : ℝ) := by
    set T : Finset (Fin n) := univ.filter (fun i : Fin n => 0 < P.eval (i : ℝ)) with hT
    rcases T.eq_empty_or_nonempty with h | h
    · refine ⟨1, one_pos, fun i hi => ?_⟩
      have : i ∈ T := by simp [hT, hi]
      rw [h] at this
      exact absurd this (by simp)
    · refine ⟨(T.inf' h (fun i => P.eval (i : ℝ))) / 2, ?_, ?_⟩
      · have hpos : 0 < T.inf' h (fun i => P.eval (i : ℝ)) := by
          rw [Finset.lt_inf'_iff]
          intro i hi
          simpa [hT] using (Finset.mem_filter.mp hi).2
        linarith
      · intro i hi
        have hmem : i ∈ T := by simp [hT, hi]
        have hle : T.inf' h (fun i => P.eval (i : ℝ)) ≤ P.eval (i : ℝ) :=
          Finset.inf'_le _ hmem
        have hpos : 0 < T.inf' h (fun i => P.eval (i : ℝ)) := by
          rw [Finset.lt_inf'_iff]
          intro i' hi'
          simpa [hT] using (Finset.mem_filter.mp hi').2
        linarith
  have hlow : (P - X ^ d).degree < (d : WithBot ℕ) := degree_sub_X_pow_lt P hm hdeg
  have hlowC : (P - X ^ d - C ε).degree < (d : WithBot ℕ) := by
    refine lt_of_le_of_lt (Polynomial.degree_sub_le _ _) (max_lt hlow ?_)
    refine lt_of_le_of_lt (Polynomial.degree_C_le) ?_
    exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hd
  have hrw : P - C ε = X ^ d + (P - X ^ d - C ε) := by ring
  refine ⟨P - C ε, ?_, ?_, ?_, ?_⟩
  · rw [hrw]
    exact Polynomial.monic_X_pow_add hlowC
  · rw [hrw]
    refine Polynomial.natDegree_eq_of_degree_eq_some ?_
    rw [Polynomial.degree_add_eq_left_of_degree_lt (by simpa using hlowC)]
    simp
  · intro i hzero
    simp only [Polynomial.eval_sub, Polynomial.eval_C, sub_eq_zero] at hzero
    have hpos : 0 < P.eval (i : ℝ) := by rw [hzero]; exact hε0
    have hlt := hεlt i hpos
    rw [hzero] at hlt
    exact absurd hlt (lt_irrefl _)
  · intro i
    simp only [Polynomial.eval_sub, Polynomial.eval_C, sub_pos]
    constructor
    · intro h; linarith
    · intro h; exact hεlt i h

/-- **Root accounting.**  If a monic degree-`d` polynomial does not vanish at any
sample point, its positivity pattern has at most `d` sign changes, because each
change costs a distinct real root. -/
lemma changeSet_card_le_of_no_zero (Q : ℝ[X]) (hm : Q.Monic) (hdeg : Q.natDegree = d)
    (hd : 1 ≤ d) (hnz : ∀ i : Fin n, Q.eval (i : ℝ) ≠ 0) :
    (changeSet (univ.filter (fun i : Fin n => 0 < Q.eval (i : ℝ)))).card ≤ d := by
  classical
  set S : Finset (Fin n) := univ.filter (fun i : Fin n => 0 < Q.eval (i : ℝ)) with hS
  have hcont : ContinuousOn (fun t : ℝ => Q.eval t) (Set.univ) := (Q.continuous).continuousOn
  have hind : ∀ i : Fin n, (ind S (i : ℕ) = true ↔ 0 < Q.eval (i : ℝ)) := by
    intro i; simp [hS]
  -- for every change position we produce a root strictly to its right,
  -- and strictly to the left of the next sample point when there is one
  have hroot : ∀ j : Fin n, ∃ r : ℝ, j ∈ changeSet S →
      (Q.eval r = 0 ∧ (j : ℝ) < r ∧ ((j : ℕ) + 1 < n → r < (j : ℝ) + 1)) := by
    intro j
    by_cases hj : j ∈ changeSet S
    · have hne : ind S (j : ℕ) ≠ ind S ((j : ℕ) + 1) := mem_changeSet.mp hj
      by_cases hlast : (j : ℕ) + 1 < n
      · -- interior change: intermediate value theorem on `[j, j+1]`
        set i' : Fin n := ⟨(j : ℕ) + 1, hlast⟩ with hi'
        have hind' : ind S ((j : ℕ) + 1) = decide (0 < Q.eval ((i' : Fin n) : ℝ)) := by
          have : ind S ((j : ℕ) + 1) = decide (i' ∈ S) := by simp [ind, hlast, hi']
          rw [this]; simp [hS]
        have hval : ((i' : Fin n) : ℝ) = (j : ℝ) + 1 := by
          simp [hi']
        have hle : (j : ℝ) ≤ (j : ℝ) + 1 := by linarith
        rcases lt_or_ge 0 (Q.eval (j : ℝ)) with hpos | hnonpos
        · -- positive then negative
          have hneg : Q.eval ((j : ℝ) + 1) < 0 := by
            have hnp : ¬ (0 < Q.eval ((j : ℝ) + 1)) := by
              intro hcon
              have h1 : ind S (j : ℕ) = true := (hind j).mpr hpos
              have h2 : ind S ((j : ℕ) + 1) = true := by
                rw [hind']; simp [hval, hcon]
              exact hne (h1.trans h2.symm)
            rcases lt_trichotomy (Q.eval ((j : ℝ) + 1)) 0 with h | h | h
            · exact h
            · exact absurd (by rw [hval]; exact h) (hnz i')
            · exact absurd h hnp
          obtain ⟨r, hrmem, hr0⟩ := intermediate_value_Ioo' hle (Q.continuous.continuousOn)
            (Set.mem_Ioo.mpr ⟨hneg, hpos⟩)
          exact ⟨r, fun _ => ⟨hr0, hrmem.1, fun _ => hrmem.2⟩⟩
        · -- negative then positive
          have hnegj : Q.eval (j : ℝ) < 0 := lt_of_le_of_ne hnonpos (hnz j)
          have hposj : 0 < Q.eval ((j : ℝ) + 1) := by
            by_contra hcon
            have h1 : ind S (j : ℕ) = false := by
              have : ¬ (0 < Q.eval (j : ℝ)) := by linarith
              rcases Bool.eq_false_or_eq_true (ind S (j : ℕ)) with h | h
              · exact absurd ((hind j).mp h) this
              · exact h
            have h2 : ind S ((j : ℕ) + 1) = false := by
              rw [hind']
              simp only [hval, decide_eq_false_iff_not]
              exact hcon
            exact hne (h1.trans h2.symm)
          obtain ⟨r, hrmem, hr0⟩ := intermediate_value_Ioo hle (Q.continuous.continuousOn)
            (Set.mem_Ioo.mpr ⟨hnegj, hposj⟩)
          exact ⟨r, fun _ => ⟨hr0, hrmem.1, fun _ => hrmem.2⟩⟩
      · -- final change: use that `Q` tends to `+∞`
        have hlastb : ind S ((j : ℕ) + 1) = true := ind_of_ge S (by omega)
        have hjfalse : ind S (j : ℕ) = false := by
          rcases Bool.eq_false_or_eq_true (ind S (j : ℕ)) with h | h
          · exact absurd (h.trans hlastb.symm) hne
          · exact h
        have hnegj : Q.eval (j : ℝ) < 0 := by
          have hnp : ¬ (0 < Q.eval (j : ℝ)) := by
            intro hcon
            exact absurd ((hind j).mpr hcon) (by simp [hjfalse])
          rcases lt_trichotomy (Q.eval (j : ℝ)) 0 with h | h | h
          · exact h
          · exact absurd h (hnz j)
          · exact absurd h hnp
        have hdegpos : 0 < Q.degree := by
          rw [Polynomial.degree_eq_natDegree hm.ne_zero, hdeg]
          exact_mod_cast hd
        have htend := Q.tendsto_atTop_of_leadingCoeff_nonneg hdegpos (by rw [hm.leadingCoeff]; norm_num)
        have h1 : ∀ᶠ y in Filter.atTop, 0 < Polynomial.eval y Q := htend.eventually_gt_atTop 0
        have h2 : ∀ᶠ y in Filter.atTop, (j : ℝ) < y := Filter.eventually_gt_atTop _
        obtain ⟨b, hb1, hb2⟩ := (h1.and h2).exists
        obtain ⟨r, hrmem, hr0⟩ := intermediate_value_Ioo (le_of_lt hb2) (Q.continuous.continuousOn)
          (Set.mem_Ioo.mpr ⟨hnegj, hb1⟩)
        exact ⟨r, fun _ => ⟨hr0, hrmem.1, fun hcon => absurd hcon (by omega)⟩⟩
    · exact ⟨0, fun hcon => absurd hcon hj⟩
  choose r hr using hroot
  have hQ0 : Q ≠ 0 := hm.ne_zero
  have hmaps : ∀ j ∈ changeSet S, r j ∈ Q.roots.toFinset := by
    intro j hj
    rw [Multiset.mem_toFinset, Polynomial.mem_roots hQ0]
    exact (hr j hj).1
  have hinj : Set.InjOn r (changeSet S) := by
    intro a ha b hb hab
    by_contra hne
    have hlt : ∀ p q : Fin n, p ∈ changeSet S → q ∈ changeSet S → p < q → r p < r q := by
      intro p q hp hq hpq
      have hpn : (p : ℕ) + 1 < n := by
        have := q.isLt
        have : (p : ℕ) < (q : ℕ) := hpq
        omega
      have h1 := (hr p hp).2.2 hpn
      have h2 := (hr q hq).2.1
      have hstep : (p : ℝ) + 1 ≤ (q : ℝ) := by
        have : (p : ℕ) + 1 ≤ (q : ℕ) := hpq
        exact_mod_cast this
      linarith
    rcases lt_trichotomy a b with h | h | h
    · exact absurd hab (ne_of_lt (hlt a b ha hb h))
    · exact hne h
    · exact absurd hab.symm (ne_of_lt (hlt b a hb ha h))
  calc (changeSet S).card ≤ Q.roots.toFinset.card := Finset.card_le_card_of_injOn r hmaps hinj
    _ ≤ Multiset.card Q.roots := Multiset.toFinset_card_le _
    _ ≤ Q.natDegree := Q.card_roots'
    _ = d := hdeg

/-- Every pattern realized by the moment layer has a change set of size `≤ d`. -/
theorem changeSet_card_le_of_mem_regions {S : Finset (Fin n)}
    (hS : S ∈ (momentFamily n d).regions) : (changeSet S).card ≤ d := by
  classical
  obtain ⟨x, rfl⟩ := AffineFamily.mem_regions.mp hS
  rw [pattern_momentFamily]
  rcases Nat.eq_zero_or_pos d with hd | hd
  · subst hd
    have hval : ∀ i : Fin n, (coeffPoly 0 x).eval (i : ℝ) = 1 := by
      intro i; simp [eval_coeffPoly]
    have huniv : (univ.filter (fun i : Fin n => 0 < (coeffPoly 0 x).eval (i : ℝ)))
        = (univ : Finset (Fin n)) := by
      refine Finset.eq_univ_of_forall fun i => ?_
      simp [hval i]
    rw [huniv]
    have hchange : changeSet (univ : Finset (Fin n)) = ∅ := by
      rw [Finset.eq_empty_iff_forall_notMem]
      intro j hj
      have := mem_changeSet.mp hj
      have h1 : ind (univ : Finset (Fin n)) (j : ℕ) = true := by simp [ind, j.isLt]
      have h2 : ind (univ : Finset (Fin n)) ((j : ℕ) + 1) = true := by
        by_cases h : (j : ℕ) + 1 < n
        · simp [ind, h]
        · exact ind_of_ge _ (by omega)
      exact this (h1.trans h2.symm)
    simp [hchange]
  · obtain ⟨Q, hQm, hQd, hQnz, hQpat⟩ :=
      exists_perturb (coeffPoly d x) (coeffPoly_monic d x) (coeffPoly_natDegree d x) hd n
    have hfilter : (univ.filter (fun i : Fin n => 0 < (coeffPoly d x).eval (i : ℝ)))
        = univ.filter (fun i : Fin n => 0 < Q.eval (i : ℝ)) := by
      ext i; simp [hQpat i]
    rw [hfilter]
    exact changeSet_card_le_of_no_zero Q hQm hQd hd hQnz

/-! ### Backward direction: every small change set is realized -/

/-- The sign of the "root product" at a sample point is the parity of the number
of roots to its right. -/
lemma prod_pos_iff_even (T : Finset (Fin n)) (i : Fin n) :
    0 < ∏ j ∈ T, ((i : ℝ) - ((j : ℝ) + 1 / 2)) ↔
      Even (T.filter (fun j : Fin n => (i : ℕ) ≤ (j : ℕ))).card := by
  classical
  set A : Finset (Fin n) := T.filter (fun j : Fin n => (i : ℕ) ≤ (j : ℕ)) with hA
  set B : Finset (Fin n) := T.filter (fun j : Fin n => ¬ ((i : ℕ) ≤ (j : ℕ))) with hB
  have hsplit : (∏ j ∈ A, ((i : ℝ) - ((j : ℝ) + 1 / 2))) * (∏ j ∈ B, ((i : ℝ) - ((j : ℝ) + 1 / 2)))
      = ∏ j ∈ T, ((i : ℝ) - ((j : ℝ) + 1 / 2)) := Finset.prod_filter_mul_prod_filter_not _ _ _
  have hBpos : 0 < ∏ j ∈ B, ((i : ℝ) - ((j : ℝ) + 1 / 2)) := by
    refine Finset.prod_pos fun j hj => ?_
    have hjlt : (j : ℕ) < (i : ℕ) := by
      have := (Finset.mem_filter.mp hj).2
      omega
    have : ((j : ℕ) : ℝ) + 1 ≤ ((i : ℕ) : ℝ) := by exact_mod_cast hjlt
    linarith
  have hAneg : ∏ j ∈ A, ((i : ℝ) - ((j : ℝ) + 1 / 2))
      = (-1) ^ A.card * ∏ j ∈ A, (((j : ℝ) + 1 / 2) - (i : ℝ)) := by
    rw [← Finset.prod_neg]
    exact Finset.prod_congr rfl fun j _ => by ring
  have hApos : 0 < ∏ j ∈ A, (((j : ℝ) + 1 / 2) - (i : ℝ)) := by
    refine Finset.prod_pos fun j hj => ?_
    have hij : (i : ℕ) ≤ (j : ℕ) := (Finset.mem_filter.mp hj).2
    have : ((i : ℕ) : ℝ) ≤ ((j : ℕ) : ℝ) := by exact_mod_cast hij
    linarith
  rw [← hsplit, hAneg]
  rcases Nat.even_or_odd A.card with hev | hodd
  · rw [hev.neg_one_pow]
    simp only [one_mul, hev, iff_true]
    positivity
  · rw [hodd.neg_one_pow]
    have hlt : (-1 : ℝ) * ∏ j ∈ A, (((j : ℝ) + 1 / 2) - (i : ℝ)) < 0 := by nlinarith
    constructor
    · intro hcon
      nlinarith
    · intro hcon
      exact absurd hcon (Nat.not_even_iff_odd.mpr hodd)

/-- **Realizability.**  Any pattern whose change set has at most `d` elements is
realized by the moment layer. -/
theorem mem_regions_of_changeSet_card_le {S : Finset (Fin n)} (h : (changeSet S).card ≤ d) :
    S ∈ (momentFamily n d).regions := by
  classical
  set T : Finset (Fin n) := changeSet S with hT
  set k : ℕ := T.card with hk
  set P : ℝ[X] := (∏ j ∈ T, (X - C ((j : ℝ) + 1 / 2))) * (X + C 1) ^ (d - k) with hP
  have hmonicProd : (∏ j ∈ T, (X - C ((j : ℝ) + 1 / 2))).Monic :=
    Polynomial.monic_prod_of_monic _ _ fun j _ => Polynomial.monic_X_sub_C _
  have hmonicPow : ((X + C 1 : ℝ[X]) ^ (d - k)).Monic :=
    (Polynomial.monic_X_add_C (1 : ℝ)).pow _
  have hmonic : P.Monic := hmonicProd.mul hmonicPow
  have hdegProd : (∏ j ∈ T, (X - C ((j : ℝ) + 1 / 2))).natDegree = k := by
    rw [Polynomial.natDegree_prod _ _ (fun j _ => Polynomial.X_sub_C_ne_zero _)]
    simp only [Polynomial.natDegree_X_sub_C]
    simp [hk]
  have hdegPow : ((X + C 1 : ℝ[X]) ^ (d - k)).natDegree = d - k := by
    rw [Polynomial.natDegree_pow, Polynomial.natDegree_X_add_C, mul_one]
  have hdeg : P.natDegree = d := by
    rw [hP, hmonicProd.natDegree_mul hmonicPow, hdegProd, hdegPow]
    omega
  obtain ⟨x, hx⟩ := exists_coeffPoly P hmonic hdeg
  refine AffineFamily.mem_regions.mpr ⟨x, ?_⟩
  rw [pattern_momentFamily, hx]
  ext i
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  have hevalP : P.eval (i : ℝ)
      = (∏ j ∈ T, ((i : ℝ) - ((j : ℝ) + 1 / 2))) * ((i : ℝ) + 1) ^ (d - k) := by
    rw [hP]
    simp [Polynomial.eval_prod]
  have hpowpos : 0 < ((i : ℝ) + 1) ^ (d - k) := by positivity
  rw [hevalP]
  constructor
  · intro hpos
    have hprodpos : 0 < ∏ j ∈ T, ((i : ℝ) - ((j : ℝ) + 1 / 2)) := by
      by_contra hcon
      push_neg at hcon
      nlinarith
    have heven := (prod_pos_iff_even T i).mp hprodpos
    have := (ind_eq_even_tailCount S (n - (i : ℕ)) (i : ℕ) rfl (le_of_lt i.isLt)).mpr heven
    simpa using this
  · intro hmem
    have hind : ind S (i : ℕ) = true := by simpa using hmem
    have heven := (ind_eq_even_tailCount S (n - (i : ℕ)) (i : ℕ) rfl (le_of_lt i.isLt)).mp hind
    have hprodpos : 0 < ∏ j ∈ T, ((i : ℝ) - ((j : ℝ) + 1 / 2)) :=
      (prod_pos_iff_even T i).mpr heven
    positivity

/-! ### The exact maximum region count -/

/-- The moment layer realizes exactly the patterns with a small change set. -/
theorem regions_momentFamily (n d : ℕ) :
    (momentFamily n d).regions = univ.filter (fun S : Finset (Fin n) => (changeSet S).card ≤ d) := by
  classical
  ext S
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  exact ⟨fun h => changeSet_card_le_of_mem_regions h, fun h => mem_regions_of_changeSet_card_le h⟩

/-- **Sharpness of the Schläfli bound in every dimension.**  The moment-curve
ReLU layer of width `n` on `ℝ^d` realizes exactly `∑_{k ≤ d} C(n,k)` regions. -/
theorem regionCount_momentFamily (n d : ℕ) :
    (momentFamily n d).regionCount = schlafli n d := by
  rw [AffineFamily.regionCount, regions_momentFamily, card_filter_changeSet_card_le]

/-- **Exact maximum region count for one ReLU layer.**  The maximum number of
linear regions of a width-`n` ReLU layer on `ℝ^d` is exactly
`schlafli n d = ∑_{k ≤ d} C(n,k)`. -/
theorem maximum_regionCount (n d : ℕ) :
    IsGreatest {m : ℕ | ∃ F : AffineFamily n d, F.regionCount = m} (schlafli n d) :=
  ⟨⟨momentFamily n d, regionCount_momentFamily n d⟩, by
    rintro m ⟨F, rfl⟩
    exact F.regionCount_le_schlafli⟩

end ReLUPartition

section AxiomCheck
#print axioms ReLUPartition.maximum_regionCount
end AxiomCheck