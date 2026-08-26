/-
# A polynomial-method criterion for `∑ i S i • v i = 𝔽_p²`

This file complements `Computation.KneserManyLines`.  There we showed that the
"Kneser input for many lines" conjecture

  `∑ i (p - #(S i)) ≤ (k-2)(p-1)  →  Reach v S = 𝔽_p²`

is **false** for `k ≥ 4`.  Here we explain *why* the bound `(k-2)(p-1)` is the
right-looking one, by deriving the conjecture from Alon's Combinatorial
Nullstellensatz under one extra, checkable hypothesis: the nonvanishing of a
single coefficient of the polynomial `L₁^{p-1} L₂^{p-1}`, where

  `L₁ = ∑ i (v i).1 X i`,  `L₂ = ∑ i (v i).2 X i`

are the two coordinate linear forms of the direction family.

* `reach_eq_univ_of_coeff_ne_zero` : if some monomial `∏ X i ^ (e i)` with
  `e i < #(S i)` and `∑ i e i = 2(p-1)` has a nonzero coefficient in
  `L₁^{p-1} L₂^{p-1}`, then `Reach v S = 𝔽_p²`.
* `exists_exponents_of_defSum_le` : the *degree budget* needed above exists
  exactly under the conjectured hypothesis `∑ i (p - #(S i)) ≤ (k-2)(p-1)`.
* `reach_eq_univ_of_defSum_le_of_coeff` : the two combined.  Consequently, the
  only possible failure of the conjecture is the vanishing of *every* admissible
  coefficient — which is exactly what happens in `counterexample_p3_k4`.
-/
import Mathlib
import Computation.KneserManyLines

namespace KneserLines

open Finset MvPolynomial

variable {p k : ℕ}

/-- The linear form `∑ i, w i * X i`. -/
noncomputable def linForm (w : Fin k → ZMod p) : MvPolynomial (Fin k) (ZMod p) :=
  ∑ i, C (w i) * X i

lemma eval_linForm (w x : Fin k → ZMod p) : eval x (linForm w) = ∑ i, w i * x i := by
  simp [linForm]

lemma totalDegree_linForm_le [Fact (Nat.Prime p)] (w : Fin k → ZMod p) :
    (linForm w).totalDegree ≤ 1 := by
  refine (totalDegree_finset_sum _ _).trans ?_
  refine Finset.sup_le (fun i _ => ?_)
  refine (totalDegree_mul _ _).trans ?_
  simp [totalDegree_X]

/-- Replacing a linear form `f` by `f - c` changes its `n`-th power only in degrees
`< n`. -/
lemma totalDegree_pow_sub_pow_le (f : MvPolynomial (Fin k) (ZMod p)) (hf : f.totalDegree ≤ 1)
    (c : ZMod p) (n : ℕ) : (((f - C c) ^ n) - f ^ n).totalDegree ≤ n - 1 := by
  have h1 : (f - C c).totalDegree ≤ 1 := (totalDegree_sub _ _).trans (by simp [hf])
  induction n with
  | zero => simp
  | succ n ih =>
      rcases Nat.eq_zero_or_pos n with rfl | hn
      · have hz : ((f - C c) ^ 1) - f ^ 1 = - C c := by ring
        rw [hz]
        simp [totalDegree_C]
      · have hrw : ((f - C c) ^ (n+1)) - f ^ (n+1)
            = (f - C c) * (((f - C c) ^ n) - f ^ n) + (- C c) * f ^ n := by ring
        have hE : (f ^ n).totalDegree ≤ n := by
          refine (totalDegree_pow _ _).trans ?_
          calc n * f.totalDegree ≤ n * 1 := Nat.mul_le_mul_left _ hf
          _ = n := by ring
        rw [hrw]
        refine (totalDegree_add _ _).trans (max_le ?_ ?_)
        · refine (totalDegree_mul _ _).trans ?_
          have := ih
          omega
        · refine (totalDegree_mul _ _).trans ?_
          have hD : (-C c : MvPolynomial (Fin k) (ZMod p)).totalDegree = 0 := by
            simp [totalDegree_C]
          omega

/-- **Polynomial-method criterion.**  If the monomial `∏ i X i ^ (e i)`, with
`e i < #(S i)` and total degree `2(p-1)`, has nonzero coefficient in the product
`L₁^{p-1} L₂^{p-1}` of the two coordinate linear forms of the directions, then
every point of `𝔽_p²` is reachable. -/
theorem reach_eq_univ_of_coeff_ne_zero (hp : p.Prime) (v : Fin k → Plane p)
    (S : Fin k → Finset (ZMod p)) (e : Fin k →₀ ℕ)
    (hlt : ∀ i, e i < #(S i)) (hdeg : Finsupp.degree e = 2 * (p - 1))
    (hcoeff : coeff e ((linForm fun i => (v i).1) ^ (p-1) * (linForm fun i => (v i).2) ^ (p-1))
      ≠ 0) :
    Reach v S = Set.univ := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hp2 : 2 ≤ p := hp.two_le
  ext t
  simp only [Set.mem_univ, iff_true]
  set L1 : MvPolynomial (Fin k) (ZMod p) := linForm (fun i => (v i).1) with hL1
  set L2 : MvPolynomial (Fin k) (ZMod p) := linForm (fun i => (v i).2) with hL2
  have hd1 : L1.totalDegree ≤ 1 := totalDegree_linForm_le _
  have hd2 : L2.totalDegree ≤ 1 := totalDegree_linForm_le _
  set A : MvPolynomial (Fin k) (ZMod p) := (L1 - C t.1) ^ (p-1) with hA
  set B : MvPolynomial (Fin k) (ZMod p) := (L2 - C t.2) ^ (p-1) with hB
  have hdA : A.totalDegree ≤ p - 1 := by
    rw [hA]
    refine (totalDegree_pow _ _).trans ?_
    have h : (L1 - C t.1).totalDegree ≤ 1 := (totalDegree_sub _ _).trans (by simp [hd1])
    calc (p-1) * (L1 - C t.1).totalDegree ≤ (p-1) * 1 := Nat.mul_le_mul_left _ h
    _ = p - 1 := by ring
  have hdB : B.totalDegree ≤ p - 1 := by
    rw [hB]
    refine (totalDegree_pow _ _).trans ?_
    have h : (L2 - C t.2).totalDegree ≤ 1 := (totalDegree_sub _ _).trans (by simp [hd2])
    calc (p-1) * (L2 - C t.2).totalDegree ≤ (p-1) * 1 := Nat.mul_le_mul_left _ h
    _ = p - 1 := by ring
  have hdL1 : (L1 ^ (p-1)).totalDegree ≤ p - 1 := by
    refine (totalDegree_pow _ _).trans ?_
    calc (p-1) * L1.totalDegree ≤ (p-1) * 1 := Nat.mul_le_mul_left _ hd1
    _ = p - 1 := by ring
  have hdL2 : (L2 ^ (p-1)).totalDegree ≤ p - 1 := by
    refine (totalDegree_pow _ _).trans ?_
    calc (p-1) * L2.totalDegree ≤ (p-1) * 1 := Nat.mul_le_mul_left _ hd2
    _ = p - 1 := by ring
  set F : MvPolynomial (Fin k) (ZMod p) := (1 - A) * (1 - B) with hF
  have hcoeffF : coeff e F = coeff e (L1 ^ (p-1) * L2 ^ (p-1)) := by
    have hexp : F = 1 - A - B + A * B := by rw [hF]; ring
    have hsmall : ∀ (g : MvPolynomial (Fin k) (ZMod p)), g.totalDegree < 2 * (p-1) →
        coeff e g = 0 := by
      intro g hg
      refine coeff_eq_zero_of_totalDegree_lt ?_
      rw [← Finsupp.degree_apply, hdeg]
      exact hg
    have h1 : coeff e (1 : MvPolynomial (Fin k) (ZMod p)) = 0 := by
      refine hsmall _ ?_
      have h : (1 : MvPolynomial (Fin k) (ZMod p)).totalDegree = 0 := totalDegree_one
      omega
    have h2 : coeff e A = 0 := hsmall _ (by omega)
    have h3 : coeff e B = 0 := hsmall _ (by omega)
    have hdiff : coeff e (A * B - L1 ^ (p-1) * L2 ^ (p-1)) = 0 := by
      refine hsmall _ ?_
      have hrw : A * B - L1 ^ (p-1) * L2 ^ (p-1)
          = (A - L1 ^ (p-1)) * B + L1 ^ (p-1) * (B - L2 ^ (p-1)) := by ring
      have hA' : (A - L1 ^ (p-1)).totalDegree ≤ (p-1) - 1 := by
        rw [hA, hL1]
        exact totalDegree_pow_sub_pow_le _ (by rw [← hL1]; exact hd1) _ _
      have hB' : (B - L2 ^ (p-1)).totalDegree ≤ (p-1) - 1 := by
        rw [hB, hL2]
        exact totalDegree_pow_sub_pow_le _ (by rw [← hL2]; exact hd2) _ _
      rw [hrw]
      refine lt_of_le_of_lt (totalDegree_add _ _) ?_
      have hm1 := totalDegree_mul (A - L1 ^ (p-1)) B
      have hm2 := totalDegree_mul (L1 ^ (p-1)) (B - L2 ^ (p-1))
      have hmax : max ((A - L1 ^ (p-1)) * B).totalDegree
          ((L1 ^ (p-1)) * (B - L2 ^ (p-1))).totalDegree ≤ 2 * (p-1) - 1 := by
        apply max_le <;> omega
      omega
    have hz : coeff e (A * B) = coeff e (L1 ^ (p-1) * L2 ^ (p-1)) := by
      rw [coeff_sub] at hdiff
      exact sub_eq_zero.1 hdiff
    rw [hexp, coeff_add, coeff_sub, coeff_sub, h1, h2, h3, hz]
    ring
  have hcoeffFne : coeff e F ≠ 0 := by rw [hcoeffF]; exact hcoeff
  have hdegF : F.totalDegree = Finsupp.degree e := by
    refine le_antisymm ?_ ?_
    · rw [hdeg, hF]
      have hm := totalDegree_mul (1 - A) (1 - B)
      have h1A : (1 - A : MvPolynomial (Fin k) (ZMod p)).totalDegree ≤ p - 1 :=
        (totalDegree_sub _ _).trans (by simp [totalDegree_one, hdA])
      have h1B : (1 - B : MvPolynomial (Fin k) (ZMod p)).totalDegree ≤ p - 1 :=
        (totalDegree_sub _ _).trans (by simp [totalDegree_one, hdB])
      omega
    · rw [Finsupp.degree_apply]
      exact le_totalDegree (mem_support_iff.2 hcoeffFne)
  obtain ⟨x, hx, hne⟩ :=
    combinatorial_nullstellensatz_exists_eval_nonzero F e hcoeffFne hdegF S hlt
  refine ⟨x, hx, ?_⟩
  rw [hF] at hne
  simp only [map_mul, map_sub, map_one, map_pow, hA, hB, eval_C] at hne
  have hne1 : (1 : ZMod p) - (eval x L1 - t.1) ^ (p-1) ≠ 0 := by
    intro h; rw [h, zero_mul] at hne; exact hne rfl
  have hne2 : (1 : ZMod p) - (eval x L2 - t.2) ^ (p-1) ≠ 0 := by
    intro h; rw [h, mul_zero] at hne; exact hne rfl
  have key : ∀ y : ZMod p, (1 : ZMod p) - y ^ (p-1) ≠ 0 → y = 0 := by
    intro y hy
    by_contra hy0
    exact hy (by rw [ZMod.pow_card_sub_one_eq_one hy0, sub_self])
  have e1 : eval x L1 = t.1 := sub_eq_zero.1 (key _ hne1)
  have e2 : eval x L2 = t.2 := sub_eq_zero.1 (key _ hne2)
  rw [hL1, eval_linForm] at e1
  rw [hL2, eval_linForm] at e2
  refine Prod.ext ?_ ?_
  · rw [Prod.fst_sum]
    simpa [mul_comm] using e1
  · rw [Prod.snd_sum]
    simpa [mul_comm] using e2

/-! ### The degree budget is exactly the conjectured hypothesis -/

/-- Capped selection: if the caps `c` sum to at least `N` over `I`, some choice
`e ≤ c` supported in `I` sums to exactly `N`. -/
lemma exists_le_cap_sum_eq {ι : Type*} [DecidableEq ι] (I : Finset ι) (c : ι → ℕ) (N : ℕ)
    (h : N ≤ ∑ i ∈ I, c i) :
    ∃ e : ι → ℕ, (∀ i, e i ≤ c i) ∧ (∀ i ∉ I, e i = 0) ∧ ∑ i ∈ I, e i = N := by
  classical
  induction I using Finset.induction_on generalizing N with
  | empty =>
      refine ⟨fun _ => 0, fun i => Nat.zero_le _, fun i _ => rfl, ?_⟩
      simp only [Finset.sum_empty] at h ⊢
      omega
  | insert a I ha ih =>
      rw [Finset.sum_insert ha] at h
      obtain ⟨e, hle, hzero, hsum⟩ := ih (N := N - min (c a) N) (by omega)
      refine ⟨Function.update e a (min (c a) N), ?_, ?_, ?_⟩
      · intro i
        by_cases hi : i = a
        · subst hi; simp
        · rw [Function.update_of_ne hi]; exact hle i
      · intro i hi
        have hia : i ≠ a := by rintro rfl; exact hi (Finset.mem_insert_self _ _)
        rw [Function.update_of_ne hia]
        exact hzero i (fun hmem => hi (Finset.mem_insert_of_mem hmem))
      · rw [Finset.sum_insert ha, Function.update_self]
        have hcongr : ∑ i ∈ I, Function.update e a (min (c a) N) i = ∑ i ∈ I, e i :=
          Finset.sum_congr rfl (fun i hi => by
            rw [Function.update_of_ne (by rintro rfl; exact ha hi)])
        rw [hcongr, hsum]
        omega

/-- The degree budget required by `reach_eq_univ_of_coeff_ne_zero` is available
precisely under the conjectured deficiency bound `∑ i (p - #(S i)) ≤ (k-2)(p-1)`. -/
lemma exists_exponents_of_defSum_le (hp : p.Prime) (hk : 2 ≤ k)
    (S : Fin k → Finset (ZMod p)) (hne : ∀ i, (S i).Nonempty)
    (hd : defSum S ≤ (k - 2) * (p - 1)) :
    ∃ e : Fin k →₀ ℕ, (∀ i, e i < #(S i)) ∧ Finsupp.degree e = 2 * (p - 1) := by
  classical
  haveI : Fact p.Prime := ⟨hp⟩
  have hp2 : 2 ≤ p := hp.two_le
  have hcardS : ∀ i, #(S i) ≤ p := by
    intro i; simpa [ZMod.card] using (S i).card_le_univ
  have hpos : ∀ i, 1 ≤ #(S i) := fun i => (hne i).card_pos
  -- the caps `#(S i) - 1` sum to at least `2(p-1)`
  have hbudget : 2 * (p - 1) ≤ ∑ i, (#(S i) - 1) := by
    have hsplit : (∑ i, (#(S i) - 1)) + (∑ i, (p - #(S i))) = k * (p - 1) := by
      rw [← Finset.sum_add_distrib]
      have hterm : ∀ i : Fin k, (#(S i) - 1) + (p - #(S i)) = p - 1 := by
        intro i
        have := hcardS i
        have := hpos i
        omega
      rw [Finset.sum_congr rfl (fun i _ => hterm i), Finset.sum_const, Finset.card_univ,
        Fintype.card_fin, smul_eq_mul]
    obtain ⟨m, rfl⟩ : ∃ m, k = m + 2 := ⟨k - 2, by omega⟩
    obtain ⟨q, rfl⟩ : ∃ q, p = q + 1 := ⟨p - 1, by omega⟩
    simp only [Nat.add_sub_cancel] at hd hsplit ⊢
    have hexp : (m + 2) * q = m * q + 2 * q := by ring
    rw [hexp] at hsplit
    rw [defSum] at hd
    omega
  obtain ⟨f, hfle, -, hfsum⟩ :=
    exists_le_cap_sum_eq (Finset.univ : Finset (Fin k)) (fun i => #(S i) - 1) (2 * (p - 1))
      hbudget
  have hcoe : ∀ i, (Finsupp.equivFunOnFinite.symm f : Fin k →₀ ℕ) i = f i := fun _ => rfl
  refine ⟨Finsupp.equivFunOnFinite.symm f, ?_, ?_⟩
  · intro i
    have h1 := hfle i
    have h2 := hpos i
    rw [hcoe i]
    omega
  · have hsub : ∑ i ∈ (Finsupp.equivFunOnFinite.symm f : Fin k →₀ ℕ).support,
        (Finsupp.equivFunOnFinite.symm f : Fin k →₀ ℕ) i
        = ∑ i, (Finsupp.equivFunOnFinite.symm f : Fin k →₀ ℕ) i :=
      Finset.sum_subset (Finset.subset_univ _) (by intro i _ hi; simpa using hi)
    rw [Finsupp.degree_apply, hsub]
    simp only [hcoe]
    exact hfsum

/-- **Structure of the conjecture.**  Under the conjectured deficiency bound an
admissible exponent vector always exists, and any admissible vector with nonzero
coefficient in `L₁^{p-1} L₂^{p-1}` proves the conclusion.  Hence the conjecture can
only fail through the simultaneous vanishing of all admissible coefficients — which
is exactly what happens in `counterexample_p3_k4` and `counterexample_p5_k6`. -/
theorem exists_admissible_exponent_forcing_reach (hp : p.Prime) (hk : 2 ≤ k)
    (v : Fin k → Plane p) (S : Fin k → Finset (ZMod p)) (hne : ∀ i, (S i).Nonempty)
    (hd : defSum S ≤ (k - 2) * (p - 1)) :
    ∃ e : Fin k →₀ ℕ, (∀ i, e i < #(S i)) ∧ Finsupp.degree e = 2 * (p - 1) ∧
      (coeff e ((linForm fun i => (v i).1) ^ (p-1) * (linForm fun i => (v i).2) ^ (p-1)) ≠ 0 →
        Reach v S = Set.univ) := by
  obtain ⟨e, hlt, hdeg⟩ := exists_exponents_of_defSum_le hp hk S hne hd
  exact ⟨e, hlt, hdeg, fun hc => reach_eq_univ_of_coeff_ne_zero hp v S e hlt hdeg hc⟩

end KneserLines