import Mathlib

/-!
# NFS closure, the structural boundary: the column set is governed by `d`, not by `N`

The round-43/44 boundary (#448): unlike the quadratic sieve, whose factor base is pinned by
`N` through the quadratic residue condition, the number field sieve's algebraic columns are
governed by the auxiliary polynomial `f` of degree `d` (equivalently the field `ℚ(α)`).  This
file machine-checks the three facts behind that statement, and shows where the decoupling
stops: every quantity it controls enters the cost only through the degree balance, whose
optimum is fixed by AM–GM — there is no extra per-instance surplus to exploit.

* `base_m_selection` : base-`m` polynomial selection.  For `m ≥ 2` and `m^d ≤ N < m^(d+1)`
  the digit polynomial `f` has `f(m) = N`, degree exactly `d`, and every coefficient `< m`,
  where `m ≤ N^{1/d}` (i.e. `m^d ≤ N`).  The polynomial and hence the column set is a
  function of `(N, d)` through `m` only — the size of everything is governed by `d`.
* `homogeneous_norm_bound` : `|F(a,b)| ≤ (d+1) · M · U^d` for the homogenised norm
  form `F(a,b) = Σ cᵢ aⁱ b^{d-i}` with `|cᵢ| ≤ M`, `|a|,|b| ≤ U`.  The factor `d+1` is a
  constant factor for each fixed `d` (cf. `NFSClosureConstantFactor`: `L`-invisible).
* `degree_balance` : the degree trade-off `d·u + x/d ≥ 2 √(u x)` with equality exactly at
  `d = √(x/u)`.  This is the variational principle that yields the `L[1/3]` exponent once
  `u = log U` is itself balanced — and it shows that any instance-dependent choice of `d`
  can only reach, never beat, the balanced value.
-/

namespace Physics.NFSClosure

open Polynomial

/-! ## Base-`m` polynomial selection -/

/-- The polynomial with coefficient list `l` (constant term first). -/
noncomputable def ofDigitsPoly : List ℕ → ℕ[X]
  | [] => 0
  | a :: l => C a + X * ofDigitsPoly l

theorem eval_ofDigitsPoly (m : ℕ) (l : List ℕ) :
    (ofDigitsPoly l).eval m = Nat.ofDigits m l := by
  induction l with
  | nil => simp [ofDigitsPoly]
  | cons a l ih => simp [ofDigitsPoly, ih, Nat.ofDigits_cons]

theorem coeff_ofDigitsPoly (l : List ℕ) (i : ℕ) :
    (ofDigitsPoly l).coeff i = l.getD i 0 := by
  induction l generalizing i with
  | nil => simp [ofDigitsPoly]
  | cons a l ih =>
    cases i with
    | zero => simp [ofDigitsPoly]
    | succ i => simp [ofDigitsPoly, coeff_X_mul, ih]

/-- **Base-`m` polynomial selection.**  If `2 ≤ m` and `m ^ d ≤ N < m ^ (d+1)`, the base-`m`
digit polynomial `f` of `N` satisfies `f(m) = N`, has every coefficient `< m`, has nonzero
coefficient in degree `d` and vanishing coefficients above it (so `natDegree f = d`). -/
theorem base_m_selection {m N d : ℕ} (hm : 2 ≤ m) (hlo : m ^ d ≤ N) (hhi : N < m ^ (d + 1)) :
    let f := ofDigitsPoly (Nat.digits m N)
    f.eval m = N ∧ (∀ i, f.coeff i < m) ∧ f.coeff d ≠ 0 ∧ (∀ i, d < i → f.coeff i = 0) ∧
      f.natDegree = d := by
  intro f
  have hN : N ≠ 0 := by
    have : 0 < m ^ d := pow_pos (by omega) d
    omega
  have hlog : Nat.log m N = d := Nat.log_eq_of_pow_le_of_lt_pow hlo hhi
  have hlen : (Nat.digits m N).length = d + 1 := by
    rw [Nat.digits_len m N (by omega) hN, hlog]
  have hcoeff : ∀ i, f.coeff i = (Nat.digits m N).getD i 0 := coeff_ofDigitsPoly _
  have hlt : ∀ i, f.coeff i < m := by
    intro i
    rw [hcoeff, List.getD_eq_getElem?_getD]
    rcases h : (Nat.digits m N)[i]? with _ | x
    · simp; omega
    · simp only [Option.getD_some]
      exact Nat.digits_lt_base (by omega) (List.mem_of_getElem? h)
  have htop : ∀ i, d < i → f.coeff i = 0 := by
    intro i hi
    rw [hcoeff, List.getD_eq_default]
    omega
  have hd : f.coeff d ≠ 0 := by
    rw [hcoeff, List.getD_eq_getElem _ _ (by omega)]
    have hlast := Nat.getLast_digit_ne_zero m hN
    rw [List.getLast_eq_getElem] at hlast
    simpa [hlen] using hlast
  refine ⟨?_, hlt, hd, htop, ?_⟩
  · simp only [f, eval_ofDigitsPoly, Nat.ofDigits_digits]
  · apply le_antisymm
    · rw [Polynomial.natDegree_le_iff_coeff_eq_zero]
      intro i hi
      exact htop i (by exact_mod_cast hi)
    · exact Polynomial.le_natDegree_of_ne_zero hd

/-- The coefficient scale `m` satisfies `m ^ d ≤ N`: all coefficient sizes are governed by
`N ^ {1/d}`, i.e. by the degree. -/
theorem base_m_coeff_scale {m N d : ℕ} (hm : 2 ≤ m) (hlo : m ^ d ≤ N) (hhi : N < m ^ (d + 1)) :
    ∀ i, (ofDigitsPoly (Nat.digits m N)).coeff i < m ∧ m ^ d ≤ N :=
  fun i => ⟨(base_m_selection hm hlo hhi).2.1 i, hlo⟩

/-! ## The homogeneous norm bound -/

/-- **Homogeneous norm bound.**  For `F(a,b) = Σ_{i ≤ d} cᵢ aⁱ b^{d-i}` with `|cᵢ| ≤ M` and
`|a|, |b| ≤ U`, we have `|F(a,b)| ≤ (d+1) · M · U^d`. -/
theorem homogeneous_norm_bound (d : ℕ) (c : ℕ → ℤ) (M U a b : ℤ)
    (hc : ∀ i, |c i| ≤ M) (ha : |a| ≤ U) (hb : |b| ≤ U) :
    |∑ i ∈ Finset.range (d + 1), c i * a ^ i * b ^ (d - i)| ≤ (d + 1) * M * U ^ d := by
  have hU : 0 ≤ U := le_trans (abs_nonneg a) ha
  have hterm : ∀ i ∈ Finset.range (d + 1), |c i * a ^ i * b ^ (d - i)| ≤ M * U ^ d := by
    intro i hi
    have hid : i ≤ d := Nat.lt_succ_iff.mp (Finset.mem_range.mp hi)
    rw [abs_mul, abs_mul, abs_pow, abs_pow]
    have h1 : |a| ^ i ≤ U ^ i := pow_le_pow_left₀ (abs_nonneg a) ha i
    have h2 : |b| ^ (d - i) ≤ U ^ (d - i) := pow_le_pow_left₀ (abs_nonneg b) hb _
    have hsplit : U ^ d = U ^ i * U ^ (d - i) := by
      rw [← pow_add, Nat.add_sub_cancel' hid]
    rw [hsplit]
    have hM : 0 ≤ M := le_trans (abs_nonneg _) (hc 0)
    calc |c i| * |a| ^ i * |b| ^ (d - i)
        ≤ M * U ^ i * U ^ (d - i) := by
          gcongr
          exact hc i
      _ = M * (U ^ i * U ^ (d - i)) := by ring
  calc |∑ i ∈ Finset.range (d + 1), c i * a ^ i * b ^ (d - i)|
      ≤ ∑ i ∈ Finset.range (d + 1), |c i * a ^ i * b ^ (d - i)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i ∈ Finset.range (d + 1), M * U ^ d := Finset.sum_le_sum hterm
    _ = (d + 1) * M * U ^ d := by
          rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]
          push_cast
          ring

/-! ## The degree balance -/

/-- **Degree balance (AM–GM).**  For `u, x > 0` and every positive real degree `d`,
`d·u + x/d ≥ 2 √(u x)`. -/
theorem degree_balance {u x d : ℝ} (hu : 0 < u) (hx : 0 < x) (hd : 0 < d) :
    2 * Real.sqrt (u * x) ≤ d * u + x / d := by
  have hsu := Real.sq_sqrt hu.le
  have hsx := Real.sq_sqrt hx.le
  rw [Real.sqrt_mul hu.le, ← sub_nonneg]
  have key : d * u + x / d - 2 * (Real.sqrt u * Real.sqrt x)
      = (d * Real.sqrt u - Real.sqrt x) ^ 2 / d := by
    field_simp
    linear_combination (-d ^ 2) * hsu - hsx
  rw [key]
  positivity

/-- The balance is attained exactly at `d = √(x/u)`. -/
theorem degree_balance_attained {u x : ℝ} (hu : 0 < u) (hx : 0 < x) :
    Real.sqrt (x / u) * u + x / Real.sqrt (x / u) = 2 * Real.sqrt (u * x) := by
  have hsu := Real.sq_sqrt hu.le
  have hsx := Real.sq_sqrt hx.le
  have hu' : 0 < Real.sqrt u := Real.sqrt_pos.mpr hu
  have hx' : 0 < Real.sqrt x := Real.sqrt_pos.mpr hx
  rw [Real.sqrt_div hx.le, Real.sqrt_mul hu.le]
  field_simp
  rw [hsu, hsx]
  ring

/-- Equality in the degree balance forces `d = √(x/u)`: the optimal degree is unique, so no
instance-dependent degree choice can undercut the balanced cost `2 √(u x)`. -/
theorem degree_balance_eq_iff {u x d : ℝ} (hu : 0 < u) (hx : 0 < x) (hd : 0 < d) :
    d * u + x / d = 2 * Real.sqrt (u * x) ↔ d = Real.sqrt (x / u) := by
  constructor
  · intro h
    have hsu := Real.sq_sqrt hu.le
    have hsx := Real.sq_sqrt hx.le
    have hu' : 0 < Real.sqrt u := Real.sqrt_pos.mpr hu
    have key : (d * Real.sqrt u - Real.sqrt x) ^ 2 = 0 := by
      have h2 : d * (d * u + x / d) = d * (2 * (Real.sqrt u * Real.sqrt x)) := by
        rw [h, Real.sqrt_mul hu.le]
      field_simp at h2
      nlinarith [h2]
    have h3 : d * Real.sqrt u = Real.sqrt x := by
      have := pow_eq_zero_iff (n := 2) (by norm_num) |>.mp key
      linarith
    rw [Real.sqrt_div hx.le, ← h3]
    field_simp
  · rintro rfl
    exact degree_balance_attained hu hx

end Physics.NFSClosure