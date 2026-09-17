/-
# The transitive quintic row, in closed form

For each of the five transitive subgroups of `S₅` — `C₅`, `D₅`, `F₂₀`, `A₅`, `S₅` — the
Chebotarev readout of a degree-5 field with that Galois group is a finite joint table
on

* the **factorization type** `T` of an unramified prime (equivalently, the cycle type of
  the Frobenius class), and
* the **abelianization coset** `C` of the Frobenius class, i.e. its image in `G^ab`,
  which class field theory realizes as a function of `p mod m*`.

The tables below are the exact conjugacy-class statistics of those five groups (each
class has probability `|class| / |G|`).  We compute all Shannon quantities in closed
form.  Writing `L = logb 2 5` and `M = logb 2 3`:

| group | `H(T)`                        | `H(C)` | `I(T;C)` | gap `H(T) - I` |
|-------|-------------------------------|--------|----------|----------------|
| `C₅`  | `L - 8/5`                     | `L`    | `L - 8/5`| `0`            |
| `D₅`  | `1/5 + L/2`                   | `1`    | `1`      | `L/2 - 4/5`    |
| `F₂₀` | `11/10 + L/4`                 | `2`    | `3/2`    | `L/4 - 2/5`    |
| `A₅`  | `2/15 + 7M/20 + 5L/12`        | `0`    | `0`      | `H(T)`         |
| `S₅`  | `7/5 + 5L/24 + 17M/40`        | `1`    | `1`      | `2/5 + 5L/24 + 17M/40` |

Numerically `H(T)` is `0.7219, 1.3610, 1.6805, 1.6555, 2.5574` and `I` is
`0.7219, 1, 1.5, 0, 1`, matching the measured Chebotarev histograms; the closed forms
prove the measured values are *exact*, not approximate.  In every row the gap equals
the coset-conditioned type entropy `H(T|C)` (`TypeChannel.Joint.gap_eq`).
-/
import MachineLearning.QuinticTypeChannel.Core

open Finset Real

namespace TypeChannel
namespace QuinticRow

/-! ## Logarithm toolkit -/

private lemma log2_pos : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)

private lemma log2_ne : Real.log 2 ≠ 0 := ne_of_gt log2_pos

/-- Logarithm of a `{2,3,5}`-smooth positive rational. -/
private lemma log_smooth (x y z : ℤ) :
    Real.log ((2:ℝ) ^ x * 3 ^ y * 5 ^ z)
      = x * Real.log 2 + y * Real.log 3 + z * Real.log 5 := by
  rw [Real.log_mul (by positivity) (by positivity), Real.log_mul (by positivity) (by positivity),
    Real.log_zpow, Real.log_zpow, Real.log_zpow]

/-- `negMulLog` of a `{2,3,5}`-smooth probability, in terms of `log 2, log 3, log 5`. -/
private lemma nml_smooth {p : ℝ} (x y z : ℤ) (h : p = (2:ℝ) ^ x * 3 ^ y * 5 ^ z) :
    negMulLog p = -(p * (x * Real.log 2 + y * Real.log 3 + z * Real.log 5)) := by
  rw [Real.negMulLog, ← log_smooth x y z, ← h]; ring

/-- `logb 2 5 > 2.3214` (from `5^28 > 2^65`). -/
theorem logb_two_five_lb : (2.3214:ℝ) < Real.logb 2 5 := by
  rw [Real.logb, lt_div_iff₀ log2_pos]
  have h : Real.log ((2:ℝ) ^ (65:ℕ)) < Real.log ((5:ℝ) ^ (28:ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  push_cast at h
  nlinarith [log2_pos]

/-- `logb 2 5 < 2.3221` (from `5^59 < 2^137`). -/
theorem logb_two_five_ub : Real.logb 2 5 < 2.3221 := by
  rw [Real.logb, div_lt_iff₀ log2_pos]
  have h : Real.log ((5:ℝ) ^ (59:ℕ)) < Real.log ((2:ℝ) ^ (137:ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  push_cast at h
  nlinarith [log2_pos]

/-- `logb 2 3 > 1.5833` (from `3^12 > 2^19`). -/
theorem logb_two_three_lb : (1.5833:ℝ) < Real.logb 2 3 := by
  rw [Real.logb, lt_div_iff₀ log2_pos]
  have h : Real.log ((2:ℝ) ^ (19:ℕ)) < Real.log ((3:ℝ) ^ (12:ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  push_cast at h
  nlinarith [log2_pos]

/-- `logb 2 3 < 1.5854` (from `3^41 < 2^65`). -/
theorem logb_two_three_ub : Real.logb 2 3 < 1.5854 := by
  rw [Real.logb, div_lt_iff₀ log2_pos]
  have h : Real.log ((3:ℝ) ^ (41:ℕ)) < Real.log ((2:ℝ) ^ (65:ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  push_cast at h
  nlinarith [log2_pos]

/-! ## `C₅`: the cyclic quintic field, e.g. the real subfield of `ℚ(ζ₁₁)`

Types: `[1⁵]` (the identity, rate `1/5`) and `[5]` (rate `4/5`).  The abelianization is
all of `C₅`, so the coset observable is the Frobenius element itself: five cosets of
rate `1/5` each. -/

noncomputable def C5 : Joint (Fin 2) (Fin 5) where
  p := ![![1/5, 0, 0, 0, 0], ![0, 1/5, 1/5, 1/5, 1/5]]
  nonneg := by intro t c; fin_cases t <;> fin_cases c <;> norm_num
  total := by norm_num [Fin.sum_univ_succ]

lemma C5_typeMarg_zero : C5.typeMarg 0 = 1/5 := by
  simp [Joint.typeMarg, C5, Fin.sum_univ_succ]
lemma C5_typeMarg_one : C5.typeMarg 1 = 4/5 := by
  simp [Joint.typeMarg, C5, Fin.sum_univ_succ]; norm_num
lemma C5_cosetMarg (c : Fin 5) : C5.cosetMarg c = 1/5 := by
  fin_cases c <;> simp [Joint.cosetMarg, C5, Fin.sum_univ_succ]

theorem C5_Htype : C5.Htype = Real.logb 2 5 - 8/5 := by
  rw [Joint.Htype, Fin.sum_univ_two, C5_typeMarg_zero, C5_typeMarg_one,
    nml_smooth 0 0 (-1) (by norm_num), nml_smooth 2 0 (-1) (by norm_num), Real.logb]
  field_simp
  ring

theorem C5_Hcoset : C5.Hcoset = Real.logb 2 5 := by
  rw [Joint.Hcoset]
  have : ∀ c : Fin 5, negMulLog (C5.cosetMarg c) = -((1/5 : ℝ) * (-(1:ℤ) * Real.log 5)) := by
    intro c
    rw [C5_cosetMarg c, nml_smooth 0 0 (-1) (by norm_num)]
    push_cast; ring
  rw [Finset.sum_congr rfl (fun c _ => this c)]
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  rw [Real.logb]
  push_cast
  field_simp

/-- In the cyclic case the coset *is* the Frobenius element, so it determines the type. -/
theorem C5_codetermines : ∀ t t' c, 0 < C5.p t c → 0 < C5.p t' c → t = t' := by
  intro t t' c h h'
  fin_cases t <;> fin_cases t' <;> fin_cases c <;> simp_all [C5]

/-- `I(T;C) = H(T) = log₂5 - 8/5 ≈ 0.7219` for a cyclic quintic field. -/
theorem C5_mutualInfo : C5.mutualInfo = Real.logb 2 5 - 8/5 := by
  rw [C5.mutualInfo_eq_Htype_of_codetermines C5_codetermines, C5_Htype]

theorem C5_gap : C5.Htype - C5.mutualInfo = 0 := by
  rw [C5_Htype, C5_mutualInfo]; ring

/-! ## `D₅`: e.g. the splitting field of `x⁵ + 20x + 32`

Types: `[1⁵]` (rate `1/10`), `[5]` (rate `4/10`), `[1,2,2]` (rate `5/10`).  The
abelianization is `C₂` (the commutator subgroup is the rotation `C₅`), so rotations and
reflections form the two cosets — and the type determines which. -/

noncomputable def D5 : Joint (Fin 3) (Fin 2) where
  p := ![![1/10, 0], ![2/5, 0], ![0, 1/2]]
  nonneg := by intro t c; fin_cases t <;> fin_cases c <;> norm_num
  total := by norm_num [Fin.sum_univ_succ]

lemma D5_typeMarg_zero : D5.typeMarg 0 = 1/10 := by
  simp [Joint.typeMarg, D5, Fin.sum_univ_succ]
lemma D5_typeMarg_one : D5.typeMarg 1 = 2/5 := by
  simp [Joint.typeMarg, D5, Fin.sum_univ_succ]
lemma D5_typeMarg_two : D5.typeMarg 2 = 1/2 := by
  simp [Joint.typeMarg, D5, Fin.sum_univ_succ]
lemma D5_cosetMarg (c : Fin 2) : D5.cosetMarg c = 1/2 := by
  fin_cases c <;> norm_num [Joint.cosetMarg, D5, Fin.sum_univ_succ]

/-- `H(T) = 1/5 + (log₂5)/2 ≈ 1.3610` bits. -/
theorem D5_Htype : D5.Htype = 1/5 + Real.logb 2 5 / 2 := by
  rw [Joint.Htype, Fin.sum_univ_three, D5_typeMarg_zero, D5_typeMarg_one, D5_typeMarg_two,
    nml_smooth (-1) 0 (-1) (by norm_num), nml_smooth 1 0 (-1) (by norm_num),
    nml_smooth (-1) 0 0 (by norm_num), Real.logb]
  field_simp
  ring

theorem D5_Hcoset : D5.Hcoset = 1 := by
  rw [Joint.Hcoset, Fin.sum_univ_two, D5_cosetMarg 0, D5_cosetMarg 1,
    nml_smooth (-1) 0 0 (by norm_num)]
  push_cast
  field_simp
  ring

/-- The `D₅` type determines the abelianization coset: rotations are `[1⁵]` or `[5]`,
reflections are exactly the type `[1,2,2]`. -/
theorem D5_determines : ∀ t c c', 0 < D5.p t c → 0 < D5.p t c' → c = c' := by
  intro t c c' h h'
  fin_cases t <;> fin_cases c <;> fin_cases c' <;> simp_all [D5]

/-- **The `D₅` cell of the law**: `I(T;C) = 1` bit, exactly. -/
theorem D5_mutualInfo : D5.mutualInfo = 1 := by
  rw [D5.mutualInfo_eq_Hcoset_of_determines D5_determines, D5_Hcoset]

/-- The `D₅` gap is exactly `(log₂5)/2 - 4/5 ≈ 0.3610`. -/
theorem D5_gap : D5.Htype - D5.mutualInfo = Real.logb 2 5 / 2 - 4/5 := by
  rw [D5_Htype, D5_mutualInfo]; ring

/-- The measured value `H(T) = 1.3610` bits is pinned between explicit rationals. -/
theorem D5_Htype_bracket : (1.3607:ℝ) < D5.Htype ∧ D5.Htype < 1.36105 := by
  rw [D5_Htype]
  constructor <;> [linarith [logb_two_five_lb]; linarith [logb_two_five_ub]]

/-! ## `F₂₀`: e.g. the splitting field of `x⁵ - 2`

Types: `[1⁵]` (`1/20`), `[5]` (`4/20`), `[4]` (`10/20`), `[1,2,2]` (`5/20`).  The
abelianization is `C₄`; the type `[4]` splits evenly between the two generators of `C₄`,
so here the type does *not* determine the coset and the mutual information falls
strictly below `H(C) = 2`. -/

noncomputable def F20 : Joint (Fin 4) (Fin 4) where
  p := ![![1/20, 0, 0, 0], ![1/5, 0, 0, 0], ![0, 1/4, 0, 1/4], ![0, 0, 1/4, 0]]
  nonneg := by intro t c; fin_cases t <;> fin_cases c <;> norm_num
  total := by norm_num [Fin.sum_univ_succ]

lemma F20_typeMarg_zero : F20.typeMarg 0 = 1/20 := by
  simp [Joint.typeMarg, F20, Fin.sum_univ_succ]
lemma F20_typeMarg_one : F20.typeMarg 1 = 1/5 := by
  simp [Joint.typeMarg, F20, Fin.sum_univ_succ]
lemma F20_typeMarg_two : F20.typeMarg 2 = 1/2 := by
  simp [Joint.typeMarg, F20, Fin.sum_univ_succ]; norm_num
lemma F20_typeMarg_three : F20.typeMarg 3 = 1/4 := by
  simp [Joint.typeMarg, F20, Fin.sum_univ_succ]
lemma F20_cosetMarg (c : Fin 4) : F20.cosetMarg c = 1/4 := by
  fin_cases c <;> norm_num [Joint.cosetMarg, F20, Fin.sum_univ_succ]

/-- `H(T) = 11/10 + (log₂5)/4 ≈ 1.6805` bits. -/
theorem F20_Htype : F20.Htype = 11/10 + Real.logb 2 5 / 4 := by
  rw [Joint.Htype, Fin.sum_univ_four, F20_typeMarg_zero, F20_typeMarg_one, F20_typeMarg_two,
    F20_typeMarg_three, nml_smooth (-2) 0 (-1) (by norm_num), nml_smooth 0 0 (-1) (by norm_num),
    nml_smooth (-1) 0 0 (by norm_num), nml_smooth (-2) 0 0 (by norm_num), Real.logb]
  field_simp
  ring

theorem F20_Hcoset : F20.Hcoset = 2 := by
  rw [Joint.Hcoset, Fin.sum_univ_four, F20_cosetMarg 0, F20_cosetMarg 1, F20_cosetMarg 2,
    F20_cosetMarg 3, nml_smooth (-2) 0 0 (by norm_num)]
  field_simp
  ring

/-- `H(T,C) = 8/5 + (log₂5)/4`. -/
theorem F20_Hjoint : F20.Hjoint = 8/5 + Real.logb 2 5 / 4 := by
  have hsum : ∑ t : Fin 4, ∑ c : Fin 4, negMulLog (F20.p t c)
      = negMulLog (1/20) + negMulLog (1/5) + negMulLog (1/4) + negMulLog (1/4)
        + negMulLog (1/4) := by
    simp [F20, Fin.sum_univ_succ, Real.negMulLog]
    ring
  rw [Joint.Hjoint, hsum, nml_smooth (-2) 0 (-1) (by norm_num),
    nml_smooth 0 0 (-1) (by norm_num), nml_smooth (-2) 0 0 (by norm_num), Real.logb]
  field_simp
  ring

/-- **The `F₂₀` cell**: `I(T;C) = 3/2` exactly — one half bit short of `H(C) = 2`,
because the `[4]` type is ambiguous between the two generators of `C₄`. -/
theorem F20_mutualInfo : F20.mutualInfo = 3/2 := by
  rw [Joint.mutualInfo, F20_Htype, F20_Hcoset, F20_Hjoint]; ring

theorem F20_gap : F20.Htype - F20.mutualInfo = Real.logb 2 5 / 4 - 2/5 := by
  rw [F20_Htype, F20_mutualInfo]; ring

theorem F20_Htype_bracket : (1.6803:ℝ) < F20.Htype ∧ F20.Htype < 1.68053 := by
  rw [F20_Htype]
  constructor <;> [linarith [logb_two_five_lb]; linarith [logb_two_five_ub]]

/-! ## `A₅`: e.g. the splitting field of `x⁵ + 20x + 16`

Types: `[1⁵]` (`1/60`), `[1,2,2]` (`15/60`), `[1,1,3]` (`20/60`), `[5]` (`24/60`).  `A₅`
is perfect, so `G^ab` is trivial: a single coset, zero coset entropy, zero information. -/

noncomputable def A5 : Joint (Fin 4) (Fin 1) where
  p := ![![1/60], ![1/4], ![1/3], ![2/5]]
  nonneg := by intro t c; fin_cases t <;> fin_cases c <;> norm_num
  total := by norm_num [Fin.sum_univ_succ]

lemma A5_typeMarg_zero : A5.typeMarg 0 = 1/60 := by
  simp [Joint.typeMarg, A5]
lemma A5_typeMarg_one : A5.typeMarg 1 = 1/4 := by
  simp [Joint.typeMarg, A5]
lemma A5_typeMarg_two : A5.typeMarg 2 = 1/3 := by
  simp [Joint.typeMarg, A5]
lemma A5_typeMarg_three : A5.typeMarg 3 = 2/5 := by
  simp [Joint.typeMarg, A5]

/-- `H(T) = 2/15 + 7·log₂3/20 + 5·log₂5/12 ≈ 1.6555` bits. -/
theorem A5_Htype : A5.Htype = 2/15 + 7 * Real.logb 2 3 / 20 + 5 * Real.logb 2 5 / 12 := by
  rw [Joint.Htype, Fin.sum_univ_four, A5_typeMarg_zero, A5_typeMarg_one, A5_typeMarg_two,
    A5_typeMarg_three, nml_smooth (-2) (-1) (-1) (by norm_num),
    nml_smooth (-2) 0 0 (by norm_num), nml_smooth 0 (-1) 0 (by norm_num),
    nml_smooth 1 0 (-1) (by norm_num), Real.logb, Real.logb]
  field_simp
  ring

/-- A perfect group has a single abelianization coset, hence zero coset entropy. -/
theorem A5_Hcoset : A5.Hcoset = 0 := by
  have h : A5.cosetMarg 0 = 1 := by norm_num [Joint.cosetMarg, A5, Fin.sum_univ_succ]
  rw [Joint.Hcoset, Fin.sum_univ_one, h]
  simp [Real.negMulLog]

theorem A5_determines : ∀ t c c', 0 < A5.p t c → 0 < A5.p t c' → c = c' := by
  intro t c c' _ _
  fin_cases c
  fin_cases c'
  rfl

/-- **The `A₅` cell**: the type channel carries no abelianization information at all. -/
theorem A5_mutualInfo : A5.mutualInfo = 0 := by
  rw [A5.mutualInfo_eq_Hcoset_of_determines A5_determines, A5_Hcoset]

/-- For `A₅` the whole type entropy is gap: every bit of type is coset-invisible. -/
theorem A5_gap : A5.Htype - A5.mutualInfo = A5.Htype := by
  rw [A5_mutualInfo]; ring

theorem A5_Htype_bracket : (1.6547:ℝ) < A5.Htype ∧ A5.Htype < 1.6558 := by
  rw [A5_Htype]
  constructor
  · linarith [logb_two_five_lb, logb_two_three_lb]
  · linarith [logb_two_five_ub, logb_two_three_ub]

/-! ## `S₅`: e.g. the splitting field of `x⁵ - x - 1`

Seven classes: `[1⁵]` (`1/120`), `[1,1,1,2]` (`10/120`), `[1,2,2]` (`15/120`),
`[1,1,3]` (`20/120`), `[2,3]` (`20/120`), `[1,4]` (`30/120`), `[5]` (`24/120`).  The
abelianization is `C₂` via the sign, and the cycle type determines the sign. -/

noncomputable def S5 : Joint (Fin 7) (Fin 2) where
  p := ![![1/120, 0], ![0, 1/12], ![1/8, 0], ![1/6, 0], ![0, 1/6], ![0, 1/4], ![1/5, 0]]
  nonneg := by intro t c; fin_cases t <;> fin_cases c <;> norm_num
  total := by norm_num [Fin.sum_univ_succ]

lemma S5_typeMarg_zero : S5.typeMarg 0 = 1/120 := by
  simp [Joint.typeMarg, S5, Fin.sum_univ_succ]
lemma S5_typeMarg_one : S5.typeMarg 1 = 1/12 := by
  simp [Joint.typeMarg, S5, Fin.sum_univ_succ]
lemma S5_typeMarg_two : S5.typeMarg 2 = 1/8 := by
  simp [Joint.typeMarg, S5, Fin.sum_univ_succ]
lemma S5_typeMarg_three : S5.typeMarg 3 = 1/6 := by
  simp [Joint.typeMarg, S5, Fin.sum_univ_succ]
lemma S5_typeMarg_four : S5.typeMarg 4 = 1/6 := by
  simp [Joint.typeMarg, S5, Fin.sum_univ_succ]
lemma S5_typeMarg_five : S5.typeMarg 5 = 1/4 := by
  simp [Joint.typeMarg, S5, Fin.sum_univ_succ]
lemma S5_typeMarg_six : S5.typeMarg 6 = 1/5 := by
  simp [Joint.typeMarg, S5, Fin.sum_univ_succ]
lemma S5_cosetMarg (c : Fin 2) : S5.cosetMarg c = 1/2 := by
  fin_cases c <;> norm_num [Joint.cosetMarg, S5, Fin.sum_univ_succ]

/-- `H(T) = 7/5 + 5·log₂5/24 + 17·log₂3/40 ≈ 2.5574` bits. -/
theorem S5_Htype : S5.Htype = 7/5 + 5 * Real.logb 2 5 / 24 + 17 * Real.logb 2 3 / 40 := by
  rw [Joint.Htype, Fin.sum_univ_seven, S5_typeMarg_zero, S5_typeMarg_one, S5_typeMarg_two,
    S5_typeMarg_three, S5_typeMarg_four, S5_typeMarg_five, S5_typeMarg_six,
    nml_smooth (-3) (-1) (-1) (by norm_num), nml_smooth (-2) (-1) 0 (by norm_num),
    nml_smooth (-3) 0 0 (by norm_num), nml_smooth (-1) (-1) 0 (by norm_num),
    nml_smooth (-2) 0 0 (by norm_num), nml_smooth 0 0 (-1) (by norm_num),
    Real.logb, Real.logb]
  field_simp
  ring

theorem S5_Hcoset : S5.Hcoset = 1 := by
  rw [Joint.Hcoset, Fin.sum_univ_two, S5_cosetMarg 0, S5_cosetMarg 1,
    nml_smooth (-1) 0 0 (by norm_num)]
  push_cast
  field_simp
  ring

/-- The cycle type determines the sign, hence the `S₅` abelianization coset. -/
theorem S5_determines : ∀ t c c', 0 < S5.p t c → 0 < S5.p t c' → c = c' := by
  intro t c c' h h'
  fin_cases t <;> fin_cases c <;> fin_cases c' <;> simp_all [S5]

/-- **The `S₅` cell**: `I(T;C) = 1` bit, exactly. -/
theorem S5_mutualInfo : S5.mutualInfo = 1 := by
  rw [S5.mutualInfo_eq_Hcoset_of_determines S5_determines, S5_Hcoset]

theorem S5_gap :
    S5.Htype - S5.mutualInfo = 2/5 + 5 * Real.logb 2 5 / 24 + 17 * Real.logb 2 3 / 40 := by
  rw [S5_Htype, S5_mutualInfo]; ring

theorem S5_Htype_bracket : (2.5565:ℝ) < S5.Htype ∧ S5.Htype < 2.5576 := by
  rw [S5_Htype]
  constructor
  · linarith [logb_two_five_lb, logb_two_three_lb]
  · linarith [logb_two_five_ub, logb_two_three_ub]

/-! ## The completed row -/

/-- **THE QUINTIC ROW.**  The five transitive subgroups of `S₅`, with the exact mutual
information between factorization type and abelianization coset in each case.  The four
rational values `1`, `3/2`, `0`, `1` and the single irrational value `log₂5 - 8/5` are
exactly the measured Chebotarev values `1.0000, 1.5000, 0, 1.0000, 0.7219`. -/
theorem quintic_row :
    C5.mutualInfo = Real.logb 2 5 - 8/5 ∧
    D5.mutualInfo = 1 ∧
    F20.mutualInfo = 3/2 ∧
    A5.mutualInfo = 0 ∧
    S5.mutualInfo = 1 :=
  ⟨C5_mutualInfo, D5_mutualInfo, F20_mutualInfo, A5_mutualInfo, S5_mutualInfo⟩

/-- In every row of the quintic table the gap between the type entropy and the measured
information is exactly the coset-conditioned type entropy `H(T|C)`. -/
theorem quintic_gaps_are_conditional_entropies :
    C5.Htype - C5.mutualInfo = C5.condTypeGivenCoset ∧
    D5.Htype - D5.mutualInfo = D5.condTypeGivenCoset ∧
    F20.Htype - F20.mutualInfo = F20.condTypeGivenCoset ∧
    A5.Htype - A5.mutualInfo = A5.condTypeGivenCoset ∧
    S5.Htype - S5.mutualInfo = S5.condTypeGivenCoset :=
  ⟨C5.gap_eq, D5.gap_eq, F20.gap_eq, A5.gap_eq, S5.gap_eq⟩

/-- Every cell of the row obeys the general bounds `0 ≤ I ≤ min (H(T), H(C))`. -/
theorem quintic_row_information_bounds :
    (0 ≤ C5.mutualInfo ∧ C5.mutualInfo ≤ C5.Hcoset) ∧
    (0 ≤ D5.mutualInfo ∧ D5.mutualInfo ≤ D5.Hcoset) ∧
    (0 ≤ F20.mutualInfo ∧ F20.mutualInfo ≤ F20.Hcoset) ∧
    (0 ≤ A5.mutualInfo ∧ A5.mutualInfo ≤ A5.Hcoset) ∧
    (0 ≤ S5.mutualInfo ∧ S5.mutualInfo ≤ S5.Hcoset) :=
  ⟨⟨C5.mutualInfo_nonneg, C5.mutualInfo_le_Hcoset⟩,
   ⟨D5.mutualInfo_nonneg, D5.mutualInfo_le_Hcoset⟩,
   ⟨F20.mutualInfo_nonneg, F20.mutualInfo_le_Hcoset⟩,
   ⟨A5.mutualInfo_nonneg, A5.mutualInfo_le_Hcoset⟩,
   ⟨S5.mutualInfo_nonneg, S5.mutualInfo_le_Hcoset⟩⟩

end QuinticRow
end TypeChannel