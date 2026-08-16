import Mathlib

/-!
# EML transseries: the ordered field of exp-log transmonomials

This file sets up the ambient object for the EML transseries programme: the field of
Hahn series whose exponent group is the *EML growth rank group*

  `Rank = ℝ ×ₗ (ℝ ×ₗ (ℝ ×ₗ ℝ))`,

a rank `(d, a, b, c)` recording the transmonomial

  `exp (d · exp x) · exp (a · x) · x ^ b · (log x) ^ c`.

The four coordinates are exactly the four scales named in the classical transseries
hierarchy `exp (exp x) ≫ exp x ≫ x ≫ log x`, and they are compared
lexicographically, the fastest-growing scale first.

Because a Hahn series is small when its exponent is *large*, the transmonomial with
data `(d,a,b,c)` is placed at the rank `(-d,-a,-b,-c)`; this is the definition
`EMLTS.T`.

## Main results

* `EMLTS.T_mul` : the transmonomials form a multiplicative group isomorphic to `(ℝ⁴, +)`.
* `EMLTS.T_lt_T_iff` : the ordering of transmonomials is the lexicographic ordering of
  their data — the *asymptotic scale comparison*.
* `EMLTS.const_lt_T_expx`, `EMLTS.T_x_pow_lt_T_expx`, ... : the growth hierarchy
  `1 ≪ log x ≪ x ≪ exp x ≪ exp (exp x)`, in the strong form that no finite power of
  one level reaches the next.
* `EMLTS.not_archimedean` : the transseries field is non-Archimedean.
* `EMLTS.exists_rank_nsmul` : the rank group is divisible (needed for root extraction).
-/

noncomputable section

open HahnSeries

namespace EMLTS

/-! ## The rank group -/

/-- The EML growth rank group: a rank `(d,a,b,c)` stands for the transmonomial
`exp (d exp x) exp (a x) x ^ b (log x) ^ c`, ordered lexicographically. -/
abbrev Rank := ℝ ×ₗ (ℝ ×ₗ (ℝ ×ₗ ℝ))

/-- Package four real exponents into a growth rank. -/
def rk (d a b c : ℝ) : Rank := toLex (d, toLex (a, toLex (b, c)))

@[simp] theorem rk_add (d a b c d' a' b' c' : ℝ) :
    rk d a b c + rk d' a' b' c' = rk (d + d') (a + a') (b + b') (c + c') := rfl

@[simp] theorem rk_zero : rk 0 0 0 0 = (0 : Rank) := rfl

@[simp] theorem rk_neg (d a b c : ℝ) : -rk d a b c = rk (-d) (-a) (-b) (-c) := rfl

theorem rk_congr {d a b c d' a' b' c' : ℝ} (hd : d = d') (ha : a = a') (hb : b = b')
    (hc : c = c') : rk d a b c = rk d' a' b' c' := by
  subst hd; subst ha; subst hb; subst hc; rfl

@[simp] theorem rk_inj {d a b c d' a' b' c' : ℝ} :
    rk d a b c = rk d' a' b' c' ↔ d = d' ∧ a = a' ∧ b = b' ∧ c = c' := by
  constructor
  · intro h
    have h' := congrArg ofLex h
    simp only [rk, ofLex_toLex, Prod.mk.injEq] at h'
    obtain ⟨hd, h2⟩ := h'
    have h2' := congrArg ofLex h2
    simp only [ofLex_toLex, Prod.mk.injEq] at h2'
    obtain ⟨ha, h3⟩ := h2'
    have h3' := congrArg ofLex h3
    simp only [ofLex_toLex, Prod.mk.injEq] at h3'
    exact ⟨hd, ha, h3'.1, h3'.2⟩
  · rintro ⟨rfl, rfl, rfl, rfl⟩; rfl

/-- Every rank is of the form `rk d a b c`. -/
theorem rank_surj (g : Rank) : ∃ d a b c, g = rk d a b c := ⟨_, _, _, _, rfl⟩

theorem rk_nsmul (n : ℕ) (d a b c : ℝ) :
    n • rk d a b c = rk (n * d) (n * a) (n * b) (n * c) := by
  induction n with
  | zero => simp only [zero_nsmul, Nat.cast_zero, zero_mul, rk_zero]
  | succ k ih =>
      rw [succ_nsmul, ih, rk_add]
      push_cast
      exact rk_congr (by ring) (by ring) (by ring) (by ring)

/-- The rank group is divisible: this is what makes root extraction possible. -/
theorem exists_rank_nsmul (n : ℕ) (hn : n ≠ 0) (g : Rank) : ∃ h : Rank, n • h = g := by
  obtain ⟨d, a, b, c, rfl⟩ := rank_surj g
  refine ⟨rk (d / n) (a / n) (b / n) (c / n), ?_⟩
  have hn' : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn
  rw [rk_nsmul]
  exact rk_congr (by field_simp) (by field_simp) (by field_simp) (by field_simp)

/-- Comparison of ranks is lexicographic. -/
theorem rk_lt_rk_iff {d a b c d' a' b' c' : ℝ} :
    rk d a b c < rk d' a' b' c' ↔
      d < d' ∨ (d = d' ∧ (a < a' ∨ (a = a' ∧ (b < b' ∨ (b = b' ∧ c < c'))))) := by
  simp only [rk, Prod.Lex.toLex_lt_toLex]

/-! ## The transseries field -/

/-- The field of EML transseries: Hahn series over the growth rank group, with the
lexicographic (asymptotic) ordering. -/
abbrev TS := Lex (HahnSeries Rank ℝ)

instance : Field TS := inferInstance
instance : LinearOrder TS := inferInstance
instance : IsStrictOrderedRing TS := inferInstance

/-- The transmonomial `exp (d exp x) exp (a x) x ^ b (log x) ^ c`. -/
def T (d a b c : ℝ) : TS := toLex (single (rk (-d) (-a) (-b) (-c)) 1)

/-- A real constant, viewed as a transseries. -/
def C (r : ℝ) : TS := toLex (single (0 : Rank) r)

@[simp] theorem leadingCoeff_T (d a b c : ℝ) : (ofLex (T d a b c)).leadingCoeff = 1 := by
  simp [T, leadingCoeff_of_single]

@[simp] theorem T_mul (d a b c d' a' b' c' : ℝ) :
    T d a b c * T d' a' b' c' = T (d + d') (a + a') (b + b') (c + c') := by
  simp only [T, ← toLex_mul, single_mul_single, mul_one, rk_add]
  exact congrArg toLex (congrArg (single · (1 : ℝ)) (rk_congr (by ring) (by ring)
    (by ring) (by ring)))

theorem T_congr {d a b c d' a' b' c' : ℝ} (hd : d = d') (ha : a = a') (hb : b = b')
    (hc : c = c') : T d a b c = T d' a' b' c' := by
  subst hd; subst ha; subst hb; subst hc; rfl

@[simp] theorem T_zero : T 0 0 0 0 = 1 := by
  simp only [T, neg_zero, rk_zero]
  rfl

theorem T_pos (d a b c : ℝ) : 0 < T d a b c := by
  rw [← leadingCoeff_pos_iff, leadingCoeff_T]; norm_num

@[simp] theorem T_ne_zero (d a b c : ℝ) : T d a b c ≠ 0 := (T_pos d a b c).ne'

theorem T_inv (d a b c : ℝ) : (T d a b c)⁻¹ = T (-d) (-a) (-b) (-c) := by
  refine inv_eq_of_mul_eq_one_left ?_
  rw [T_mul, T_congr (neg_add_cancel d) (neg_add_cancel a) (neg_add_cancel b) (neg_add_cancel c),
    T_zero]

theorem T_pow (d a b c : ℝ) (n : ℕ) : (T d a b c) ^ n = T (n * d) (n * a) (n * b) (n * c) := by
  induction n with
  | zero => simp only [pow_zero, Nat.cast_zero, zero_mul, T_zero]
  | succ k ih =>
      rw [pow_succ, ih, T_mul]
      push_cast
      exact T_congr (by ring) (by ring) (by ring) (by ring)

/-- A monomial of *smaller* rank dominates: in the asymptotic ordering, small exponent
means large transseries. -/
theorem single_lt_single_of_lt {g g' : Rank} {r r' : ℝ} (hr' : 0 < r') (h : g' < g) :
    (toLex (single g r) : TS) < toLex (single g' r') := by
  refine (HahnSeries.lt_iff _ _).mpr ⟨g', fun j hj => ?_, ?_⟩
  · rw [ofLex_toLex, ofLex_toLex, coeff_single_of_ne (hj.trans h).ne,
      coeff_single_of_ne hj.ne]
  · rw [ofLex_toLex, ofLex_toLex, coeff_single_of_ne h.ne, coeff_single_same]
    exact hr'

/-- Comparison of positive monomials is the reversed comparison of their ranks. -/
theorem single_lt_single_iff {g g' : Rank} {r : ℝ} (hr : 0 < r) :
    (toLex (single g r) : TS) < toLex (single g' r) ↔ g' < g := by
  refine ⟨fun h => ?_, single_lt_single_of_lt hr⟩
  rcases lt_trichotomy g' g with hlt | rfl | hgt
  · exact hlt
  · exact absurd h (lt_irrefl _)
  · exact absurd (single_lt_single_of_lt hr hgt) (asymm h)

theorem T_lt_T_iff_rk {d a b c d' a' b' c' : ℝ} :
    T d a b c < T d' a' b' c' ↔ rk (-d') (-a') (-b') (-c') < rk (-d) (-a) (-b) (-c) :=
  single_lt_single_iff one_pos

/-- The asymptotic comparison of transmonomials is the lexicographic comparison of
their exponent data: the double-exponential rate dominates the exponential rate,
which dominates the power of `x`, which dominates the power of `log x`. -/
theorem T_lt_T_iff {d a b c d' a' b' c' : ℝ} :
    T d a b c < T d' a' b' c' ↔
      d < d' ∨ (d = d' ∧ (a < a' ∨ (a = a' ∧ (b < b' ∨ (b = b' ∧ c < c'))))) := by
  rw [T_lt_T_iff_rk, rk_lt_rk_iff]
  constructor
  · rintro (h | ⟨hd, h | ⟨ha, h | ⟨hb, hc⟩⟩⟩)
    · exact Or.inl (by linarith)
    · exact Or.inr ⟨by linarith, Or.inl (by linarith)⟩
    · exact Or.inr ⟨by linarith, Or.inr ⟨by linarith, Or.inl (by linarith)⟩⟩
    · exact Or.inr ⟨by linarith, Or.inr ⟨by linarith, Or.inr ⟨by linarith, by linarith⟩⟩⟩
  · rintro (h | ⟨hd, h | ⟨ha, h | ⟨hb, hc⟩⟩⟩)
    · exact Or.inl (by linarith)
    · exact Or.inr ⟨by linarith, Or.inl (by linarith)⟩
    · exact Or.inr ⟨by linarith, Or.inr ⟨by linarith, Or.inl (by linarith)⟩⟩
    · exact Or.inr ⟨by linarith, Or.inr ⟨by linarith, Or.inr ⟨by linarith, by linarith⟩⟩⟩

/-! ## Real constants -/

@[simp] theorem C_zero : C 0 = 0 := by simp [C]

@[simp] theorem C_one : C 1 = 1 := rfl

@[simp] theorem C_add (r s : ℝ) : C (r + s) = C r + C s := by
  simp [C, ← toLex_add, single_add]

@[simp] theorem C_mul (r s : ℝ) : C (r * s) = C r * C s := by
  simp [C, ← toLex_mul, single_mul_single]

/-- The natural number `n`, as a transseries, is the constant transseries `n`. -/
theorem natCast_eq_C (n : ℕ) : (n : TS) = C (n : ℝ) := by
  induction n with
  | zero => simp
  | succ k ih => push_cast; rw [ih, ← C_one, ← C_add]

/-! ## The growth hierarchy `1 ≪ log x ≪ x ≪ exp x ≪ exp (exp x)` -/

/-- The transseries variable `x`. -/
def Lx : TS := T 0 0 1 0

/-- The transseries `log x`. -/
def Llog : TS := T 0 0 0 1

/-- The transseries `exp x`. -/
def Lexp : TS := T 0 1 0 0

/-- The transseries `exp (exp x)`. -/
def Lexpexp : TS := T 1 0 0 0

theorem Lx_pos : 0 < Lx := T_pos _ _ _ _
theorem Llog_pos : 0 < Llog := T_pos _ _ _ _
theorem Lexp_pos : 0 < Lexp := T_pos _ _ _ _
theorem Lexpexp_pos : 0 < Lexpexp := T_pos _ _ _ _

/-- Every real constant is smaller than `log x`: `log x` is infinitely large. -/
theorem C_lt_Llog (r : ℝ) : C r < Llog := by
  refine single_lt_single_of_lt one_pos ?_
  rw [show (0 : Rank) = rk 0 0 0 0 from rfl, rk_lt_rk_iff]
  norm_num

/-- No power of `log x` reaches `x`. -/
theorem Llog_pow_lt_Lx (n : ℕ) : Llog ^ n < Lx := by
  rw [Llog, T_pow, Lx, T_lt_T_iff]
  norm_num

/-- No power of `x` reaches `exp x`. -/
theorem Lx_pow_lt_Lexp (n : ℕ) : Lx ^ n < Lexp := by
  rw [Lx, T_pow, Lexp, T_lt_T_iff]
  norm_num

/-- No power of `exp x` reaches `exp (exp x)`. -/
theorem Lexp_pow_lt_Lexpexp (n : ℕ) : Lexp ^ n < Lexpexp := by
  rw [Lexp, T_pow, Lexpexp, T_lt_T_iff]
  norm_num

theorem Llog_lt_Lx : Llog < Lx := by simpa using Llog_pow_lt_Lx 1
theorem Lx_lt_Lexp : Lx < Lexp := by simpa using Lx_pow_lt_Lexp 1
theorem Lexp_lt_Lexpexp : Lexp < Lexpexp := by simpa using Lexp_pow_lt_Lexpexp 1

/-- `1 / x` is a nonzero infinitesimal. -/
theorem inv_Lx_lt_C {r : ℝ} (hr : 0 < r) : Lx⁻¹ < C r := by
  rw [Lx, T_inv]
  refine single_lt_single_of_lt hr ?_
  rw [show (0 : Rank) = rk 0 0 0 0 from rfl, rk_lt_rk_iff]
  norm_num

/-- The transseries field is **not** Archimedean: no multiple of `1` reaches `x`. -/
theorem not_archimedean : ¬ Archimedean TS := by
  intro h
  obtain ⟨n, hn⟩ := h.arch Lx (zero_lt_one' TS)
  rw [nsmul_eq_mul, mul_one, natCast_eq_C] at hn
  exact absurd hn (not_le.mpr (lt_trans (C_lt_Llog _) Llog_lt_Lx))

end EMLTS