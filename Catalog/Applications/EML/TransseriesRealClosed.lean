import Applications.EML.TransseriesHensel

/-!
# Real closedness: what is proved, and the exact remaining gap

Mathlib's `IsRealClosed R` asks for three things: `R` is semireal, every element or its
negative is a square, and every odd-degree polynomial has a root.

For the EML transseries field `EMLTS.TS` the first two are theorems of this development
(`EMLTS.isSquare_iff_nonneg` in `TransseriesRoots.lean`, restated here as
`EMLTS.isSquare_or_isSquare_neg`), so real closedness of `TS` is *equivalent* to the
odd-degree root property, and even to the odd-degree root property for monic polynomials:

* `EMLTS.isRealClosed_iff_exists_root_odd`
* `EMLTS.isRealClosed_iff_exists_root_odd_monic`

This isolates the single remaining statement.  Two inputs of the classical
Newton-polygon proof of that statement are available here as theorems:

* the value group is divisible (`EMLTS.exists_rank_nsmul`);
* the residue field `ℝ` is real closed — proved here as `Real.instIsRealClosed`
  (Mathlib lists this as a TODO), via the intermediate value theorem.

Odd-degree polynomials of degree `1` are handled by `EMLTS.exists_root_of_natDegree_one`,
degree `3` with nonnegative Cardano discriminant by `EMLTS.exists_root_cubic`, and the
casus irreducibilis (which no radical formula can reach) by
`EMLTS.exists_root_cubic_casus_irreducibilis`.
-/

noncomputable section

open Polynomial Filter

/-! ## The residue field `ℝ` is real closed -/

namespace RealRealClosed

/-- An odd-degree real polynomial takes a positive value. -/
theorem exists_eval_pos {P : ℝ[X]} (hodd : Odd P.natDegree) (hlc : 0 < P.leadingCoeff) :
    ∃ b : ℝ, 0 < P.eval b := by
  have hdeg : 0 < P.degree := by
    have hne : P ≠ 0 := fun h => by simp [h, Nat.odd_iff] at hodd
    have h1 : 1 ≤ P.natDegree := by
      rcases Nat.eq_zero_or_pos P.natDegree with h | h
      · rw [h] at hodd; simp [Nat.odd_iff] at hodd
      · exact h
    exact natDegree_pos_iff_degree_pos.mp h1
  have htend := P.tendsto_atTop_of_leadingCoeff_nonneg hdeg hlc.le
  obtain ⟨b, hb⟩ := (htend.eventually_gt_atTop 0).exists
  exact ⟨b, hb⟩

/-- An odd-degree real polynomial with positive leading coefficient takes a negative
value: substituting `-X` reverses the sign of the leading coefficient. -/
theorem exists_eval_neg {P : ℝ[X]} (hodd : Odd P.natDegree) (hlc : 0 < P.leadingCoeff) :
    ∃ a : ℝ, P.eval a < 0 := by
  set Q : ℝ[X] := P.comp (-X) with hQ
  have hXne : (-X : ℝ[X]).natDegree ≠ 0 := by
    simp
  have hQdeg : Q.natDegree = P.natDegree := by
    rw [hQ, natDegree_comp]
    simp
  have hQlc : Q.leadingCoeff = -P.leadingCoeff := by
    rw [hQ, leadingCoeff_comp hXne]
    have hlcX : (-X : ℝ[X]).leadingCoeff = -1 := by
      simp
    rw [hlcX, hodd.neg_one_pow, mul_neg_one]
  have hdeg : 0 < Q.degree := by
    have h1 : 1 ≤ Q.natDegree := by
      rw [hQdeg]
      rcases Nat.eq_zero_or_pos P.natDegree with h | h
      · rw [h] at hodd; simp [Nat.odd_iff] at hodd
      · exact h
    exact natDegree_pos_iff_degree_pos.mp h1
  have htend := Q.tendsto_atBot_of_leadingCoeff_nonpos hdeg (by rw [hQlc]; linarith)
  obtain ⟨a, ha⟩ := (htend.eventually_lt_atBot 0).exists
  refine ⟨-a, ?_⟩
  have : Q.eval a = P.eval (-a) := by rw [hQ, eval_comp]; simp
  rwa [this] at ha

/-- **Every odd-degree real polynomial has a real root** (intermediate value theorem). -/
theorem exists_isRoot_of_odd_natDegree {P : ℝ[X]} (hodd : Odd P.natDegree) :
    ∃ x : ℝ, P.IsRoot x := by
  have main : ∀ Q : ℝ[X], Odd Q.natDegree → 0 < Q.leadingCoeff → ∃ x : ℝ, Q.IsRoot x := by
    intro Q hoddQ hlc
    obtain ⟨b, hb⟩ := exists_eval_pos hoddQ hlc
    obtain ⟨a, ha⟩ := exists_eval_neg hoddQ hlc
    have hcont : Continuous fun x : ℝ => Q.eval x := Q.continuous
    rcases le_total a b with hab | hab
    · have hsub := intermediate_value_Icc hab (hcont.continuousOn (s := Set.Icc a b))
      obtain ⟨x, -, hx⟩ := hsub (Set.mem_Icc.mpr ⟨ha.le, hb.le⟩)
      exact ⟨x, hx⟩
    · have hsub := intermediate_value_Icc' hab (hcont.continuousOn (s := Set.Icc b a))
      obtain ⟨x, -, hx⟩ := hsub (Set.mem_Icc.mpr ⟨ha.le, hb.le⟩)
      exact ⟨x, hx⟩
  have hne : P ≠ 0 := fun h => by simp [h, Nat.odd_iff] at hodd
  rcases lt_trichotomy P.leadingCoeff 0 with hlc | hlc | hlc
  · obtain ⟨x, hx⟩ := main (-P) (by simpa using hodd) (by simp; linarith)
    refine ⟨x, ?_⟩
    have : -P.eval x = 0 := by simpa [IsRoot] using hx
    simpa [IsRoot] using neg_eq_zero.mp this
  · exact absurd hlc (leadingCoeff_ne_zero.mpr hne)
  · exact main P hodd hlc

end RealRealClosed

/-- **The real numbers form a real closed field.**  (Mathlib records this as a TODO;
the proof combines the existence of square roots of nonnegative reals with the
intermediate value theorem for odd-degree polynomials.) -/
instance Real.instIsRealClosed : IsRealClosed ℝ :=
  IsRealClosed.of_linearOrderedField
    (fun {x} hx => ⟨Real.sqrt x, (Real.mul_self_sqrt hx).symm⟩)
    (fun hf => RealRealClosed.exists_isRoot_of_odd_natDegree hf)

namespace EMLTS

/-! ## The real closedness of the transseries field, reduced to one statement -/

/-- **Real closedness of the transseries field is equivalent to the odd-degree root
property.**  The other two clauses of the definition are theorems of this development. -/
theorem isRealClosed_iff_exists_root_odd :
    IsRealClosed TS ↔ ∀ f : Polynomial TS, Odd f.natDegree → ∃ z : TS, f.IsRoot z := by
  constructor
  · intro _ f hf
    exact IsRealClosed.exists_isRoot_of_odd_natDegree hf
  · intro H
    exact IsRealClosed.of_linearOrderedField (fun {x} hx => isSquare_iff_nonneg.mpr hx)
      (fun {f} hf => H f hf)

/-- The odd-degree root property may be tested on monic polynomials only. -/
theorem isRealClosed_iff_exists_root_odd_monic :
    IsRealClosed TS ↔ ∀ f : Polynomial TS, f.Monic → Odd f.natDegree → ∃ z : TS, f.IsRoot z := by
  rw [isRealClosed_iff_exists_root_odd]
  constructor
  · intro H f _ hf
    exact H f hf
  · intro H f hf
    have hne : f ≠ 0 := fun h => by simp [h, Nat.odd_iff] at hf
    have hmonic : (f * Polynomial.C f.leadingCoeff⁻¹).Monic :=
      Polynomial.monic_mul_leadingCoeff_inv hne
    have hdeg : (f * Polynomial.C f.leadingCoeff⁻¹).natDegree = f.natDegree :=
      Polynomial.natDegree_mul_leadingCoeff_inv f hne
    obtain ⟨z, hz⟩ := H _ hmonic (by rwa [hdeg])
    refine ⟨z, ?_⟩
    have hlc : f.leadingCoeff⁻¹ ≠ 0 := inv_ne_zero (Polynomial.leadingCoeff_ne_zero.mpr hne)
    have := hz
    rw [Polynomial.IsRoot, Polynomial.eval_mul, Polynomial.eval_C, mul_eq_zero] at this
    rcases this with h | h
    · exact h
    · exact absurd h hlc

/-! ## The low-degree cases -/

/-- Degree one: an odd-degree case that is unconditionally solvable. -/
theorem exists_root_of_natDegree_one {f : Polynomial TS} (hf : f.natDegree = 1) :
    ∃ z : TS, f.IsRoot z := by
  have hne : f ≠ 0 := fun h => by simp [h] at hf
  have hlc : f.coeff 1 ≠ 0 := by
    have : f.leadingCoeff ≠ 0 := Polynomial.leadingCoeff_ne_zero.mpr hne
    rwa [Polynomial.leadingCoeff, hf] at this
  refine ⟨-f.coeff 0 / f.coeff 1, ?_⟩
  have heval := Polynomial.eval_eq_sum_range (p := f) (x := -f.coeff 0 / f.coeff 1)
  rw [Polynomial.IsRoot, heval, hf]
  rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_zero]
  field_simp
  ring

end EMLTS