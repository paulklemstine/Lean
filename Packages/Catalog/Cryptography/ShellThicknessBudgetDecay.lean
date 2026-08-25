/-
# Cycle 4d: how fast the thick block disappears as `N` grows

`thickCount_le` bounds the number of shells thicker than `δ` by `1 + R/(dδ)`, uniformly in `N`,
and `thickCount_max_ge` shows that order is attained — but only for one value of `N`.  The
present file makes the `N`-dependence explicit through a single polynomial inequality:

`peeling_thick_decay` : if `m = thickCount R d N δ ≥ 2` then `(m - 1)^{d-1} · N ≤ (R/(dδ))^d`.

For `d = 1` this is `N ≤ R/δ`; for `d ≥ 2` it gives `m ≤ 1 + ((R/(dδ))^d / N)^{1/(d-1)}`, so the
thick block shrinks like a power of `N` and vanishes at `N = (R/δ)^d`, matching
`all_thin_iff_card`.  Together with `thickCount_le` and `thickCount_max_ge` the profile of the
thick-shell count in `N` is now determined up to constants.

`peeling_thick_lower` is the matching statement in the other direction: every shell at inner
index `j` with `j^{d-1} N < (R/(dδ))^d` *is* thick.  Together (`thickCount_pinned`) the two
determine the thick-shell count to within one, for every `N`.

The analytic input is Bernoulli's inequality in the form `d u^{d-1}(1-u) ≤ 1 - u^d`, i.e. the
catalog's `one_sub_pow_ge`, which upgrades the crude bound `a^{1/d} - b^{1/d} ≤ (a-b) a^{1/d}/(db)`
used previously to the sharp derivative bound
`a^{1/d} - b^{1/d} ≤ (a-b) b^{1/d}/(db)` (`rpow_inv_sub_le_deriv`).

## Lab notes (`R = 1`, `δ = 0.01`, `d = 2`, so `(R/(dδ))^d = 2500`)

`N = 50, m = 50`: `(m-1)·N = 2450`.  `N = 100, m = 25`: `2400`.  `N = 200, m = 13`: `2400`.
`N = 400, m = 6`: `2000`.  `N = 1000, m = 3`: `2000`.  All below `2500`, and within `2%` of it
near the peak: the inequality is essentially an equality in the interesting range.
-/
import Mathlib
import Cryptography.ShellThicknessBudgetStructure

namespace Catalog.Cryptography.ShellBudget

open Finset Catalog.Geometry.Peel Catalog.Shared.ShellSharp

/-- **Sharp derivative bound for `x ↦ x^{1/d}`.**  `a^{1/d} - b^{1/d} ≤ (a-b)/(d b) · b^{1/d}`,
the discrete form of `(x^{1/d})' = x^{1/d}/(d x)`.  Equivalent to Bernoulli's inequality. -/
lemma rpow_inv_sub_le_deriv {d : ℕ} (hd : 0 < d) {a b : ℝ} (hb : 0 < b) (hab : b ≤ a) :
    a ^ ((d : ℝ)⁻¹) - b ^ ((d : ℝ)⁻¹) ≤ (a - b) / (d * b) * b ^ ((d : ℝ)⁻¹) := by
  have ha : 0 < a := lt_of_lt_of_le hb hab
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  set p : ℝ := (d : ℝ)⁻¹ with hp
  have hp0 : 0 ≤ p := by rw [hp]; positivity
  set y : ℝ := b / a with hy
  have hy0 : 0 < y := div_pos hb ha
  have hy1 : y ≤ 1 := (div_le_one ha).2 hab
  set u : ℝ := y ^ p with hu
  have hu0 : 0 < u := Real.rpow_pos_of_pos hy0 p
  have hu1 : u ≤ 1 := Real.rpow_le_one hy0.le hy1 hp0
  have hud : u ^ d = y := Real.rpow_inv_natCast_pow hy0.le hd.ne'
  have hap : 0 < a ^ p := Real.rpow_pos_of_pos ha p
  have hbay : b = a * y := by rw [hy]; field_simp
  have hbp : b ^ p = a ^ p * u := by
    rw [hbay, Real.mul_rpow ha.le hy0.le, hu]
  -- Bernoulli
  have key := one_sub_pow_ge d hu0.le hu1
  have hsucc : u ^ d = u ^ (d - 1) * u := by
    rw [← pow_succ]
    congr 1
    omega
  have hbnd : (1 - u) * ((d : ℝ) * u ^ (d - 1)) ≤ 1 - u ^ (d - 1) * u := by
    rw [← hsucc]; exact key
  have hud1 : (0 : ℝ) < u ^ (d - 1) := by positivity
  -- rewrite both sides of the goal in terms of `u`
  have hbu : b = a * u ^ d := by rw [hud, ← hbay]
  have hab' : a - b = a * (1 - u ^ d) := by rw [hbu]; ring
  have hgoal : (a - b) / ((d : ℝ) * b) * b ^ p = a ^ p * ((1 - u ^ d) * u / ((d : ℝ) * u ^ d)) := by
    rw [hab', hbp, hbu]
    field_simp
  rw [hgoal, hbp]
  have hstep : 1 - u ≤ (1 - u ^ d) * u / ((d : ℝ) * u ^ d) := by
    rw [le_div_iff₀ (by positivity)]
    calc (1 - u) * ((d : ℝ) * u ^ d) = (1 - u) * ((d : ℝ) * u ^ (d - 1)) * u := by
          rw [hsucc]; ring
      _ ≤ (1 - u ^ (d - 1) * u) * u := by
          exact mul_le_mul_of_nonneg_right hbnd hu0.le
      _ = (1 - u ^ d) * u := by rw [hsucc]
  have := mul_le_mul_of_nonneg_left hstep hap.le
  linarith [this]

/-- **Sharp derivative bound at the left endpoint.**  `(a-b)/(d a) · a^{1/d} ≤ a^{1/d} - b^{1/d}`,
the concavity companion of `rpow_inv_sub_le_deriv`. -/
lemma rpow_inv_sub_ge_deriv {d : ℕ} (hd : 0 < d) {a b : ℝ} (ha : 0 < a) (hb0 : 0 ≤ b)
    (hba : b ≤ a) :
    (a - b) / (d * a) * a ^ ((d : ℝ)⁻¹) ≤ a ^ ((d : ℝ)⁻¹) - b ^ ((d : ℝ)⁻¹) := by
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  set p : ℝ := (d : ℝ)⁻¹ with hp
  set y : ℝ := b / a with hy
  have hy0 : 0 ≤ y := by rw [hy]; positivity
  have hy1 : y ≤ 1 := (div_le_one ha).2 hba
  have hap : 0 < a ^ p := Real.rpow_pos_of_pos ha p
  have hbay : b = a * y := by rw [hy]; field_simp
  have hbp : b ^ p = a ^ p * y ^ p := by
    rw [hbay, Real.mul_rpow ha.le hy0]
  have key := one_sub_rpow_inv_ge hy0 hy1 hd
  have hmul : a ^ p * ((1 - y) / d) ≤ a ^ p * (1 - y ^ p) :=
    mul_le_mul_of_nonneg_left key hap.le
  have hleft : (a - b) / ((d : ℝ) * a) * a ^ p = a ^ p * ((1 - y) / d) := by
    rw [hbay, hy]
    field_simp
  rw [hleft, hbp]
  nlinarith [hmul]

/-- **Every shell at inner index `j` with `j^{d-1} N < (R/(dδ))^d` is thick.**  The matching
lower bound to `peeling_thick_decay`: together they determine the thick-shell count up to an
additive constant, for every `N`. -/
theorem peeling_thick_lower {R δ : ℝ} (hR : 0 < R) (hδ : 0 < δ) {d N j : ℕ} (hd : 0 < d)
    (hj1 : 1 ≤ j) (hjN : j ≤ N) (hjbound : ((j : ℝ)) ^ (d - 1) * N < (R / (d * δ)) ^ d) :
    j ≤ thickCount R d N δ := by
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  have hN : 0 < N := lt_of_lt_of_le hj1 hjN
  have hNpos : (0 : ℝ) < N := by exact_mod_cast hN
  have hjpos : (0 : ℝ) < j := by exact_mod_cast hj1
  set k : ℕ := N - j with hk_def
  have hkN : k < N := by omega
  have hkcast : (N : ℝ) - k = (j : ℝ) := by
    rw [hk_def, Nat.cast_sub hjN]; ring
  set p : ℝ := (d : ℝ)⁻¹ with hp
  set a : ℝ := ((N : ℝ) - k) / N with ha_def
  set b : ℝ := ((N : ℝ) - k - 1) / N with hb_def
  have ha : 0 < a := by rw [ha_def, hkcast]; positivity
  have hb0 : 0 ≤ b := by
    rw [hb_def, hkcast]
    apply div_nonneg _ hNpos.le
    have : (1 : ℝ) ≤ j := by exact_mod_cast hj1
    linarith
  have hdiff : a - b = 1 / N := by rw [ha_def, hb_def]; field_simp; ring
  have hba : b ≤ a := by rw [← sub_nonneg, hdiff]; positivity
  have hthick_eq : shellThickness R d N k = R * (a ^ p - b ^ p) := by
    rw [shellThickness_eq' hkN, ha_def, hb_def, hp]
  have hderiv := rpow_inv_sub_ge_deriv hd ha hb0 hba
  have haval : a = (j : ℝ) / N := by rw [ha_def, hkcast]
  have hap : 0 < a ^ p := Real.rpow_pos_of_pos ha p
  have hapd : (a ^ p) ^ d = a := Real.rpow_inv_natCast_pow ha.le hd.ne'
  -- the shell at inner index `j` is thick
  have hlow : R / ((d : ℝ) * j) * a ^ p ≤ shellThickness R d N k := by
    have hscal : (a - b) / ((d : ℝ) * a) = 1 / ((d : ℝ) * (j : ℝ)) := by
      rw [hdiff, haval]
      field_simp
    rw [hscal] at hderiv
    have := mul_le_mul_of_nonneg_left hderiv hR.le
    rw [hthick_eq]
    calc R / ((d : ℝ) * j) * a ^ p = R * (1 / ((d : ℝ) * (j : ℝ)) * a ^ p) := by ring
      _ ≤ R * (a ^ p - b ^ p) := this
  have hjd : (j : ℝ) ^ d = (j : ℝ) ^ (d - 1) * (j : ℝ) := by
    rw [← pow_succ]; congr 1; omega
  have hstrict : δ < R / ((d : ℝ) * j) * a ^ p := by
    have hpos : 0 < R / ((d : ℝ) * j) * a ^ p := by positivity
    refine lt_of_pow_lt_pow_left₀ d hpos.le ?_
    have hrhs : (R / ((d : ℝ) * j) * a ^ p) ^ d
        = R ^ d / ((d : ℝ) ^ d * (j : ℝ) ^ (d - 1) * N) := by
      rw [mul_pow, hapd, haval, div_pow, mul_pow, hjd]
      field_simp
    rw [hrhs, lt_div_iff₀ (by positivity)]
    have hb2 : ((j : ℝ)) ^ (d - 1) * N * ((d : ℝ) ^ d * δ ^ d) < R ^ d := by
      rw [div_pow, mul_pow, lt_div_iff₀ (by positivity)] at hjbound
      exact hjbound
    rw [show δ ^ d * ((d : ℝ) ^ d * (j : ℝ) ^ (d - 1) * N)
        = ((j : ℝ)) ^ (d - 1) * N * ((d : ℝ) ^ d * δ ^ d) from by ring]
    exact hb2
  have hthick : δ < shellThickness R d N k := lt_of_lt_of_le hstrict hlow
  obtain ⟨k₀, hk₀N, hiff, hcard⟩ := exists_thick_threshold hR.le hd (δ := δ) (N := N)
  have hk₀le : k₀ ≤ k := (hiff k hkN).1 hthick
  omega

/-- **Decay of the thick block in `N`.**  If at least two shells violate the budget then
`(m-1)^{d-1} N ≤ (R/(dδ))^d`, where `m` is their number.  For `d = 1` this reads `N ≤ R/δ`; for
`d ≥ 2` the thick block shrinks like `N^{-1/(d-1)}` and is empty once `N ≥ (R/δ)^d`. -/
theorem peeling_thick_decay {R δ : ℝ} (hR : 0 < R) (hδ : 0 < δ) {d N : ℕ} (hd : 0 < d)
    (hm : 2 ≤ thickCount R d N δ) :
    (((thickCount R d N δ - 1 : ℕ) : ℝ)) ^ (d - 1) * N ≤ (R / (d * δ)) ^ d := by
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  obtain ⟨k₀, hk₀N, hiff, hcard⟩ := exists_thick_threshold hR.le hd (δ := δ) (N := N)
  set m : ℕ := thickCount R d N δ with hm_def
  have hmN : m = N - k₀ := hcard
  have hk₀ : k₀ + 2 ≤ N := by omega
  have hN : 0 < N := by omega
  have hNpos : (0 : ℝ) < N := by exact_mod_cast hN
  have hk₀lt : k₀ < N := by omega
  have hthick : δ < shellThickness R d N k₀ := (hiff k₀ hk₀lt).2 le_rfl
  -- the outermost thick shell sits at inner index `m`
  have hk₀cast : ((N : ℝ) - k₀) = (m : ℝ) := by
    have : (m : ℝ) = (N : ℝ) - k₀ := by
      rw [hmN, Nat.cast_sub hk₀N]
    linarith
  have hm2 : (2 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  set p : ℝ := (d : ℝ)⁻¹ with hp
  set a : ℝ := ((N : ℝ) - k₀) / N with ha_def
  set b : ℝ := ((N : ℝ) - k₀ - 1) / N with hb_def
  have hb : 0 < b := by
    rw [hb_def]
    apply div_pos _ hNpos
    rw [hk₀cast]; linarith
  have hdiff : a - b = 1 / N := by rw [ha_def, hb_def]; field_simp; ring
  have hab : b ≤ a := by rw [← sub_nonneg, hdiff]; positivity
  have hthick_eq : shellThickness R d N k₀ = R * (a ^ p - b ^ p) := by
    rw [shellThickness_eq' hk₀lt, ha_def, hb_def, hp]
  have hderiv := rpow_inv_sub_le_deriv hd hb hab
  have hbval : b = ((m : ℝ) - 1) / N := by rw [hb_def, hk₀cast]
  have hm1 : (0 : ℝ) < (m : ℝ) - 1 := by linarith
  -- `δ < R/(d(m-1)) · b^{1/d}`
  have hkey : δ < R / ((d : ℝ) * ((m : ℝ) - 1)) * b ^ p := by
    have hscal : (a - b) / ((d : ℝ) * b) = 1 / ((d : ℝ) * ((m : ℝ) - 1)) := by
      rw [hdiff, hbval]
      field_simp
    have h1 : a ^ p - b ^ p ≤ 1 / ((d : ℝ) * ((m : ℝ) - 1)) * b ^ p := by
      rw [← hscal]; exact hderiv
    have h2 : R * (a ^ p - b ^ p) ≤ R * (1 / ((d : ℝ) * ((m : ℝ) - 1)) * b ^ p) :=
      mul_le_mul_of_nonneg_left h1 hR.le
    rw [hthick_eq] at hthick
    have h3 : R * (1 / ((d : ℝ) * ((m : ℝ) - 1)) * b ^ p)
        = R / ((d : ℝ) * ((m : ℝ) - 1)) * b ^ p := by ring
    linarith [hthick, h2, h3.symm.le, h3.le]
  -- raise to the `d`-th power
  have hbp0 : 0 < b ^ p := Real.rpow_pos_of_pos hb p
  have hbpd : (b ^ p) ^ d = b := Real.rpow_inv_natCast_pow hb.le hd.ne'
  have hpow : δ ^ d ≤ (R / ((d : ℝ) * ((m : ℝ) - 1))) ^ d * b := by
    have h4 : δ ^ d ≤ (R / ((d : ℝ) * ((m : ℝ) - 1)) * b ^ p) ^ d :=
      pow_le_pow_left₀ hδ.le hkey.le d
    rw [mul_pow, hbpd] at h4
    exact h4
  have hmcast : (((m - 1 : ℕ) : ℝ)) = (m : ℝ) - 1 := by
    have h1m : 1 ≤ m := by omega
    rw [Nat.cast_sub h1m, Nat.cast_one]
  set X : ℝ := ((m : ℝ) - 1) ^ (d - 1) with hX
  have hX0 : 0 < X := by rw [hX]; positivity
  have hmd : ((m : ℝ) - 1) ^ d = X * ((m : ℝ) - 1) := by
    rw [hX, ← pow_succ]
    congr 1
    omega
  have hsimp : (R / ((d : ℝ) * ((m : ℝ) - 1))) ^ d * (((m : ℝ) - 1) / N)
      = R ^ d / ((d : ℝ) ^ d * X * N) := by
    rw [div_pow, mul_pow, hmd]
    field_simp
  rw [hbval, hsimp] at hpow
  have hkey2 : δ ^ d * ((d : ℝ) ^ d * X * N) ≤ R ^ d := by
    rw [le_div_iff₀ (by positivity)] at hpow
    exact hpow
  rw [hmcast, ← hX, div_pow, mul_pow, le_div_iff₀ (by positivity),
    show X * (N : ℝ) * ((d : ℝ) ^ d * δ ^ d) = δ ^ d * ((d : ℝ) ^ d * X * N) from by ring]
  exact hkey2

/-- **The thick-shell count is pinned to within one.**  If `j^{d-1} N < (R/(dδ))^d <
(j+1)^{d-1} N` then the number of shells exceeding the budget is `j` or `j+1`.  For `d ≥ 2` this
determines the count for every `N` from the single quantity `(R/(dδ))^d / N`. -/
theorem thickCount_pinned {R δ : ℝ} (hR : 0 < R) (hδ : 0 < δ) {d N j : ℕ} (hd : 0 < d)
    (hj1 : 1 ≤ j) (hjN : j + 1 ≤ N)
    (hlow : ((j : ℝ)) ^ (d - 1) * N < (R / (d * δ)) ^ d)
    (hhigh : (R / (d * δ)) ^ d < ((j : ℝ) + 1) ^ (d - 1) * N) :
    j ≤ thickCount R d N δ ∧ thickCount R d N δ ≤ j + 1 := by
  have hNpos : (0 : ℝ) < N := by
    have : 0 < N := by omega
    exact_mod_cast this
  refine ⟨peeling_thick_lower hR hδ hd hj1 (by omega) hlow, ?_⟩
  by_contra hcon
  push_neg at hcon
  have hm2 : 2 ≤ thickCount R d N δ := by omega
  have hdec := peeling_thick_decay hR hδ hd hm2
  have hstep : ((j : ℝ) + 1) ≤ ((thickCount R d N δ - 1 : ℕ) : ℝ) := by
    have h1 : j + 1 ≤ thickCount R d N δ - 1 := by omega
    have h2 : ((j + 1 : ℕ) : ℝ) ≤ ((thickCount R d N δ - 1 : ℕ) : ℝ) := by exact_mod_cast h1
    push_cast at h2
    linarith
  have hpow : ((j : ℝ) + 1) ^ (d - 1) ≤ ((thickCount R d N δ - 1 : ℕ) : ℝ) ^ (d - 1) :=
    pow_le_pow_left₀ (by positivity) hstep _
  nlinarith [hdec, hhigh, hpow, hNpos]

end Catalog.Cryptography.ShellBudget