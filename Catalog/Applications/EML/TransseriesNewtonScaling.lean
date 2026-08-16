import Applications.EML.TransseriesRealClosed

/-!
# Newton scaling: normalising a monic transseries polynomial

`Applications/EML/TransseriesRealClosed.lean` reduced real closedness of the transseries
field `EMLTS.TS` to the single clause

  *every monic odd-degree `P ∈ TS[X]` has a root*.

This file performs the first step of the classical Newton-polygon analysis of that
clause — the *scaling* step — entirely inside `TS`, using only that `TS` is an ordered
field in which every positive element has an `n`-th root
(`EMLTS.exists_pow_eq_of_pos`).

For `λ > 0` put

  `newtonScale λ P = λ^{-n} · P(λ · X)`,   `n = deg P`,

which is again monic of degree `n`, whose coefficients are `λ^{i-n} · P.coeff i`, and
whose roots are exactly the roots of `P` divided by `λ`.  The main theorem
`EMLTS.exists_newtonScale_normalized` says that `λ` can always be chosen so that the
scaled polynomial is **normalised**:

* every coefficient satisfies `|coeff| ≤ 1` (all coefficients are in the valuation ring),
* and, unless `P = X ^ n`, some *non-leading* coefficient is exactly `±1` (so the scaled
  polynomial is not congruent to `X ^ n` modulo the infinitesimals — its residue
  polynomial is a monic real polynomial of degree `n` different from `X ^ n`).

The choice of `λ` is the Newton one: `λ = max_i |a_i| ^ (1/(n-i))`, the maximum being
taken over the indices `i < n` with `a_i ≠ 0`; the roots `|a_i| ^ (1/(n-i))` exist in `TS`
because the rank group is divisible and the residue field is real closed.

The payoff is the sharpened reduction

* `EMLTS.isRealClosed_iff_exists_root_normalized`,

which says that real closedness of `TS` need only be tested on *normalised* monic
odd-degree polynomials.  This is strictly stronger than
`EMLTS.isRealClosed_iff_exists_root_odd_monic`, and it is exactly the hypothesis under
which a Newton-polygon/Hensel argument operates.
-/

noncomputable section

namespace EMLTS

/-! ## Roots of absolute values -/

/-- A positive `k`-th root of `|a|`, chosen with the axiom of choice; the value is `1`
in the degenerate cases `a = 0` or `k = 0`. -/
def absRoot (a : TS) (k : ℕ) : TS :=
  if h : 0 < |a| ∧ k ≠ 0 then (exists_pow_eq_of_pos h.1 h.2).choose else 1

theorem absRoot_pos (a : TS) (k : ℕ) : 0 < absRoot a k := by
  rw [absRoot]
  split
  · next h => exact (exists_pow_eq_of_pos h.1 h.2).choose_spec.1
  · exact one_pos

theorem absRoot_pow {a : TS} {k : ℕ} (ha : a ≠ 0) (hk : k ≠ 0) :
    absRoot a k ^ k = |a| := by
  have h : 0 < |a| ∧ k ≠ 0 := ⟨abs_pos.mpr ha, hk⟩
  rw [absRoot, dif_pos h]
  exact (exists_pow_eq_of_pos h.1 h.2).choose_spec.2

/-! ## The scaling operator -/

/-- **Newton scaling.**  `newtonScale λ P = λ^{-deg P} · P (λ X)`. -/
def newtonScale (lam : TS) (P : Polynomial TS) : Polynomial TS :=
  Polynomial.C (lam⁻¹ ^ P.natDegree) * P.comp (Polynomial.C lam * Polynomial.X)

theorem coeff_newtonScale (lam : TS) (P : Polynomial TS) (i : ℕ) :
    (newtonScale lam P).coeff i = lam⁻¹ ^ P.natDegree * (P.coeff i * lam ^ i) := by
  rw [newtonScale, Polynomial.coeff_C_mul, Polynomial.comp_C_mul_X_coeff]

theorem natDegree_newtonScale {lam : TS} (hlam : lam ≠ 0) (P : Polynomial TS) :
    (newtonScale lam P).natDegree = P.natDegree := by
  rw [newtonScale, Polynomial.natDegree_C_mul (pow_ne_zero _ (inv_ne_zero hlam)),
    Polynomial.natDegree_comp, Polynomial.natDegree_C_mul_X _ hlam, mul_one]

theorem monic_newtonScale {lam : TS} (hlam : lam ≠ 0) {P : Polynomial TS} (hP : P.Monic) :
    (newtonScale lam P).Monic := by
  have h := coeff_newtonScale lam P P.natDegree
  rw [hP.coeff_natDegree] at h
  show (newtonScale lam P).coeff (newtonScale lam P).natDegree = 1
  rw [natDegree_newtonScale hlam, h, one_mul, inv_pow,
    inv_mul_cancel₀ (pow_ne_zero _ hlam)]

/-- Scaling transports roots: `z` is a root of the scaled polynomial iff `λ z` is a root
of the original one. -/
theorem eval_newtonScale (lam : TS) (P : Polynomial TS) (z : TS) :
    (newtonScale lam P).eval z = lam⁻¹ ^ P.natDegree * P.eval (lam * z) := by
  rw [newtonScale, Polynomial.eval_mul, Polynomial.eval_C, Polynomial.eval_comp]
  simp

theorem isRoot_of_isRoot_newtonScale {lam : TS} (hlam : lam ≠ 0) (P : Polynomial TS) {z : TS}
    (hz : (newtonScale lam P).IsRoot z) : P.IsRoot (lam * z) := by
  have h := eval_newtonScale lam P z
  rw [Polynomial.IsRoot] at hz
  rw [hz] at h
  have hc : (lam⁻¹ ^ P.natDegree) ≠ 0 := pow_ne_zero _ (inv_ne_zero hlam)
  rcases mul_eq_zero.mp h.symm with h0 | h0
  · exact absurd h0 hc
  · exact h0

/-! ## The scaling estimate -/

/-- The elementary estimate behind the scaling step. -/
private theorem abs_scaled_coeff_le_one {lam a : TS} (hlam : 0 < lam) {i n : ℕ} (hi : i ≤ n)
    (h : |a| ≤ lam ^ (n - i)) : |lam⁻¹ ^ n * (a * lam ^ i)| ≤ 1 := by
  have hpow : (0 : TS) < lam ^ n := pow_pos hlam n
  have hkey : |a| * lam ^ i ≤ lam ^ n := by
    calc |a| * lam ^ i ≤ lam ^ (n - i) * lam ^ i := by
          exact mul_le_mul_of_nonneg_right h (pow_pos hlam i).le
      _ = lam ^ n := by rw [← pow_add, Nat.sub_add_cancel hi]
  rw [abs_mul, abs_mul, abs_pow, abs_pow, abs_inv, abs_of_pos hlam, inv_pow,
    inv_mul_le_iff₀ hpow, mul_one]
  exact hkey

/-- The same computation in the boundary case, giving an exact value `1`. -/
private theorem abs_scaled_coeff_eq_one {lam a : TS} (hlam : 0 < lam) {i n : ℕ} (hi : i ≤ n)
    (h : |a| = lam ^ (n - i)) : |lam⁻¹ ^ n * (a * lam ^ i)| = 1 := by
  have hpow : (0 : TS) < lam ^ n := pow_pos hlam n
  have hkey : |a| * lam ^ i = lam ^ n := by
    rw [h, ← pow_add, Nat.sub_add_cancel hi]
  rw [abs_mul, abs_mul, abs_pow, abs_pow, abs_inv, abs_of_pos hlam, hkey, inv_pow,
    inv_mul_cancel₀ hpow.ne']

/-- **Newton scaling normalises a monic polynomial.**  For every monic `P` of positive
degree there is a positive scaling factor `λ` such that all coefficients of the scaled
polynomial lie in the valuation ring (`|coeff| ≤ 1`), and — unless `P = X ^ n` — some
non-leading coefficient of the scaled polynomial is exactly `±1`. -/
theorem exists_newtonScale_normalized {P : Polynomial TS} (hP : P.Monic) :
    ∃ lam : TS, 0 < lam ∧
      (∀ i, |(newtonScale lam P).coeff i| ≤ 1) ∧
      ((∃ i < P.natDegree, P.coeff i ≠ 0) →
        ∃ i < P.natDegree, |(newtonScale lam P).coeff i| = 1) := by
  classical
  set n := P.natDegree with hndef
  set S : Finset ℕ := (Finset.range n).filter fun i => P.coeff i ≠ 0 with hSdef
  by_cases hS : S.Nonempty
  · set lam : TS := S.sup' hS fun i => absRoot (P.coeff i) (n - i) with hlamdef
    obtain ⟨i₀, hi₀S, hi₀⟩ := Finset.exists_mem_eq_sup' hS fun i => absRoot (P.coeff i) (n - i)
    have hlampos : 0 < lam := by rw [hlamdef, hi₀]; exact absRoot_pos _ _
    have hle : ∀ i ∈ S, |P.coeff i| ≤ lam ^ (n - i) := by
      intro i hi
      have hcoeff : P.coeff i ≠ 0 := by
        have := (Finset.mem_filter.mp hi).2
        exact this
      have hlt : i < n := Finset.mem_range.mp (Finset.mem_filter.mp hi).1
      have hk : n - i ≠ 0 := by omega
      have hmu : absRoot (P.coeff i) (n - i) ^ (n - i) = |P.coeff i| := absRoot_pow hcoeff hk
      have hmule : absRoot (P.coeff i) (n - i) ≤ lam :=
        Finset.le_sup' (fun j => absRoot (P.coeff j) (n - j)) hi
      calc |P.coeff i| = absRoot (P.coeff i) (n - i) ^ (n - i) := hmu.symm
        _ ≤ lam ^ (n - i) := by
            exact pow_le_pow_left₀ (absRoot_pos _ _).le hmule _
    refine ⟨lam, hlampos, ?_, ?_⟩
    · intro i
      rw [coeff_newtonScale, ← hndef]
      rcases lt_trichotomy i n with hi | hi | hi
      · by_cases hc : P.coeff i = 0
        · rw [hc]; simp
        · refine abs_scaled_coeff_le_one hlampos hi.le (hle i ?_)
          exact Finset.mem_filter.mpr ⟨Finset.mem_range.mpr hi, hc⟩
      · subst hi
        rw [hP.coeff_natDegree, one_mul, inv_pow,
          inv_mul_cancel₀ (pow_ne_zero _ hlampos.ne'), abs_one]
      · rw [Polynomial.coeff_eq_zero_of_natDegree_lt hi]
        simp
    · intro _
      have hcoeff : P.coeff i₀ ≠ 0 := (Finset.mem_filter.mp hi₀S).2
      have hlt : i₀ < n := Finset.mem_range.mp (Finset.mem_filter.mp hi₀S).1
      have hk : n - i₀ ≠ 0 := by omega
      have hmu : lam ^ (n - i₀) = |P.coeff i₀| := by
        rw [hlamdef, hi₀]; exact absRoot_pow hcoeff hk
      refine ⟨i₀, hlt, ?_⟩
      rw [coeff_newtonScale, ← hndef]
      exact abs_scaled_coeff_eq_one hlampos hlt.le hmu.symm
  · refine ⟨1, one_pos, ?_, ?_⟩
    · intro i
      rw [coeff_newtonScale]
      simp only [inv_one, one_pow, one_mul, mul_one]
      rcases lt_trichotomy i n with hi | hi | hi
      · have hc : P.coeff i = 0 := by
          by_contra hne
          exact hS ⟨i, Finset.mem_filter.mpr ⟨Finset.mem_range.mpr hi, hne⟩⟩
        rw [hc]; simp
      · subst hi; rw [hP.coeff_natDegree, abs_one]
      · rw [Polynomial.coeff_eq_zero_of_natDegree_lt hi]; simp
    · rintro ⟨i, hi, hne⟩
      exact absurd ⟨i, Finset.mem_filter.mpr ⟨Finset.mem_range.mpr hi, hne⟩⟩ hS

/-! ## A Cauchy bound: the scaling factor measures the size of the roots -/

/-- **Cauchy's root bound in the transseries field.**  Every root of a monic polynomial
all of whose coefficients lie in the valuation ring is bounded by `2`.  The proof is the
geometric-series estimate, valid verbatim in any ordered field. -/
theorem abs_lt_two_of_isRoot_of_coeff_abs_le_one {P : Polynomial TS} (hP : P.Monic)
    (hbdd : ∀ i, |P.coeff i| ≤ 1) {z : TS} (hz : P.IsRoot z) :
    |z| < 2 := by
  by_contra hcon
  push_neg at hcon
  set n := P.natDegree with hndef
  have hz1 : (1 : TS) ≤ |z| := le_trans (by norm_num) hcon
  have hz1' : (1 : TS) < |z| := lt_of_lt_of_le (by norm_num) hcon
  -- expand the evaluation
  have heval : ∑ i ∈ Finset.range n, P.coeff i * z ^ i + z ^ n = 0 := by
    have h := Polynomial.eval_eq_sum_range (p := P) (x := z)
    rw [hz] at h
    rw [← hndef] at h
    rw [Finset.sum_range_succ, hP.coeff_natDegree, one_mul] at h
    exact h.symm
  have hpow : z ^ n = -∑ i ∈ Finset.range n, P.coeff i * z ^ i := by linarith [heval]
  -- the geometric estimate
  have hgeom : ∑ i ∈ Finset.range n, |z| ^ i ≤ |z| ^ n - 1 := by
    have hne : |z| ≠ 1 := ne_of_gt hz1'
    rw [geom_sum_eq hne]
    have hden : (1 : TS) ≤ |z| - 1 := by linarith
    have hnum : (0 : TS) ≤ |z| ^ n - 1 := by
      have : (1 : TS) ^ n ≤ |z| ^ n := pow_le_pow_left₀ zero_le_one hz1 n
      simpa using this
    calc (|z| ^ n - 1) / (|z| - 1) ≤ (|z| ^ n - 1) / 1 := by
          gcongr
      _ = |z| ^ n - 1 := by rw [div_one]
  have hsum : |∑ i ∈ Finset.range n, P.coeff i * z ^ i| ≤ ∑ i ∈ Finset.range n, |z| ^ i := by
    refine le_trans (Finset.abs_sum_le_sum_abs _ _) ?_
    refine Finset.sum_le_sum fun i _ => ?_
    rw [abs_mul, abs_pow]
    have := hbdd i
    nlinarith [abs_nonneg (P.coeff i), pow_pos (lt_of_lt_of_le zero_lt_one hz1) i]
  have hzn : |z| ^ n = |∑ i ∈ Finset.range n, P.coeff i * z ^ i| := by
    rw [← abs_pow, hpow, abs_neg]
  linarith [hzn ▸ le_trans hsum hgeom]

/-- The Newton scaling factor bounds the roots of the original polynomial: every root of a
monic `P` of positive degree is at most `2 λ` in absolute value, for the `λ` produced by
`EMLTS.exists_newtonScale_normalized`. -/
theorem exists_scaling_bounding_roots {P : Polynomial TS} (hP : P.Monic) :
    ∃ lam : TS, 0 < lam ∧ ∀ w : TS, P.IsRoot w → |w| < 2 * lam := by
  obtain ⟨lam, hlampos, hbdd, -⟩ := exists_newtonScale_normalized hP
  refine ⟨lam, hlampos, fun w hw => ?_⟩
  have hroot : (newtonScale lam P).IsRoot (lam⁻¹ * w) := by
    rw [Polynomial.IsRoot, eval_newtonScale]
    rw [show lam * (lam⁻¹ * w) = w by field_simp, hw, mul_zero]
  have hb := abs_lt_two_of_isRoot_of_coeff_abs_le_one (monic_newtonScale hlampos.ne' hP)
    hbdd hroot
  have habs : |lam⁻¹ * w| = |w| / lam := by
    rw [abs_mul, abs_inv, abs_of_pos hlampos, div_eq_inv_mul]
  rw [habs, div_lt_iff₀ hlampos] at hb
  linarith [hb]

/-! ## The sharpened reduction of real closedness -/

/-- **Real closedness of the transseries field, tested on normalised polynomials only.**
`TS` is real closed if and only if every *normalised* monic odd-degree polynomial has a
root, where normalised means that all coefficients lie in the valuation ring and some
non-leading coefficient is a unit of absolute value `1`.  Together with
`EMLTS.isRealClosed_iff_exists_root_odd_monic` this is the exact input of a
Newton-polygon argument: the residue polynomial of a normalised polynomial is a monic
real polynomial of the same degree, different from `X ^ n`. -/
theorem isRealClosed_iff_exists_root_normalized :
    IsRealClosed TS ↔ ∀ P : Polynomial TS, P.Monic → Odd P.natDegree →
      (∀ i, |P.coeff i| ≤ 1) → (∃ i < P.natDegree, |P.coeff i| = 1) →
      ∃ z : TS, P.IsRoot z := by
  rw [isRealClosed_iff_exists_root_odd_monic]
  constructor
  · intro H P hP hodd _ _
    exact H P hP hodd
  · intro H P hP hodd
    have hn : P.natDegree ≠ 0 := by
      rintro h
      rw [h] at hodd
      simp [Nat.odd_iff] at hodd
    obtain ⟨lam, hlampos, hbdd, hunit⟩ := exists_newtonScale_normalized hP
    by_cases hzero : ∃ i < P.natDegree, P.coeff i ≠ 0
    · obtain ⟨i, hi, hval⟩ := hunit hzero
      have hdeg : (newtonScale lam P).natDegree = P.natDegree :=
        natDegree_newtonScale hlampos.ne' P
      obtain ⟨z, hz⟩ := H (newtonScale lam P) (monic_newtonScale hlampos.ne' hP)
        (by rw [hdeg]; exact hodd) hbdd ⟨i, by rw [hdeg]; exact hi, hval⟩
      exact ⟨lam * z, isRoot_of_isRoot_newtonScale hlampos.ne' P hz⟩
    · push_neg at hzero
      refine ⟨0, ?_⟩
      have h0 : P.coeff 0 = 0 := hzero 0 (Nat.pos_of_ne_zero hn)
      rw [Polynomial.IsRoot, ← Polynomial.coeff_zero_eq_eval_zero, h0]

end EMLTS