/-
# HINT-VALUE-SCALING (paper 124): hints compound *or* diminish — not both

FACT round-35 #5 (paper 124, verdict *HINTS-COMPOUND-WITH-DIMINISHING-RETURNS*) reports the
hint-value curve

| `k` hints | hint value (bits) | marginal gain `Δ(k-1)` |
|-----------|-------------------|------------------------|
| 0         | 0                 | —                      |
| 1         | +0.52             | +0.52                  |
| 2         | +2.43             | +1.91                  |
| 3         | +3.19             | +0.76                  |

and concludes that hint values *compound* (superadditivity: `V 1 + V 1 < V 2`,
`V 1 + V 2 < V 3`) while marginal gains are *positive but decreasing*.

This file turns the verdict into mathematics and finds that its two halves are incompatible
as a scaling **law**, while each half alone is consistent with the data.

## Abstract scaling calculus (any curve `V : ℕ → ℝ`)

* `HintValueScaling.marginal`, `Compounding` (superadditivity), `DiminishingFrom a`
  (marginal gains non-increasing from `k = a` on).
* `diminishing_linear_cap` — a diminishing curve lies under its tangent line.
* `compounding_succ_mul` — a compounding curve lies above its secant multiples.
* `compounding_horizon` — **THE COMPOUNDING HORIZON.**  If `V` compounds and its marginal gains
  diminish from `a` on, then *every* marginal gain past `a` is at least the best average rate
  `V b / b` ever achieved:  `V b ≤ b · Δ k` for all `b` and all `k ≥ a`.  Diminishing returns
  can only diminish *towards* a slope that the compounding already locked in (a Fekete-type
  argument).
* `compounding_diminishing_linear` — if `V 0 = 0` and the marginal gains diminish from the
  very first hint, a compounding curve is **exactly linear**, `V k = k · V 1`; in particular
  `no_strict_diminishing_of_compounding`: compounding and *strictly* diminishing returns
  cannot coexist at all.
* `compounding_affine_ceiling` — a compounding curve under an affine ceiling `c k + b`
  is under the linear ceiling `c k`: offsets cannot be compounded away;
  `compounding_bounded_nonpos` — a bounded compounding curve is nonpositive.

## The paper-124 data (`MatchesPaper124 V`)

* `paper124_marginals`, `paper124_accelerates_then_decelerates` — the marginal gains are
  `0.52, 1.91, 0.76`: they **rise** before they fall.  The reported curve is S-shaped, not
  concave (`paper124_not_concave`).
* `paper124_window_compounds` — on its window the curve is strictly superadditive.
* `paper124_verdict_refuted` — **HINTS-COMPOUND-WITH-DIMINISHING-RETURNS is refuted as a law:**
  no extension of the data to all `k` is both compounding and diminishing from `k = 2` on.
  `paper124_sharp_k4` pins the failure at the very next hint: compounding demands
  `V 4 ≥ 4.86` while diminishing returns demand `V 4 ≤ 3.95`.
* `paper124_asymptotic_slope` — if a compounding extension diminishes from some point on,
  every later marginal gain is `≥ 1.215` bits per hint.
* `paper124_compounding_breaks_unit_ceiling` — a compounding extension can never sit under a
  one-bit-per-hint affine ceiling.
* `paper124_bounded_not_compounding` — no extension under a uniform ceiling (such as the
  label entropy) compounds.
* `paper124_diminishing_extension`, `paper124_compounding_extension` — each half of the verdict
  separately *is* consistent with the data: the data cannot decide between them.

## Bridge to the factor-residue catalog (`Bridges.HintValueJointCompounding`)

* `catalogCurve` — the hint curve of a factor-residue battery: `0`, the conditional sum-dial
  hint `sumHint`, and the joint hint value `hintValue` (`k ≥ 2`).
* `catalogCurve_monotone`, `catalogCurve_diminishing`, `catalogCurve_second_marginal_le_logb`,
  `catalogCurve_le_label_entropy`.
* `catalogCurve_compounding_iff_zero` — **a factor-residue hint curve compounds iff it is
  identically zero**: in the catalog model diminishing returns are forced and compounding is
  not available.
* `third_hint_saturation` — any third hint computed from the factor residues has **zero**
  marginal value: the `k = 3` gain of `+0.76` bits cannot come from the residue ring itself.
* `paper124_single_field_impossible` — the `k = 1 → 2` jump of `+1.91` bits is impossible over
  a single odd prime field (one-orientation-bit law), and `second_marginal_le_num_fields`
  shows it fits under the two-field ceiling.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): (H1) the paper-124 curve is concave (diminishing from k = 0);
  (H2) compounding + diminishing returns extend jointly to all k;  (H3) the k = 3 gain is a
  residue-ring effect;  (H4) the k = 1 → 2 jump fits a single prime field;  (H5) a compounding
  curve with diminishing marginals is linear;  (H6) the marginal gains converge to a slope at
  least the best average rate.
Experiment (Stage 2): exact rational arithmetic on the reported values (see
  `ComputationalEvidence.md`): marginals 0.52, 1.91, 0.76; superadditivity margins
  2.43 - 1.04 = 1.39 and 3.19 - 2.95 = 0.24; at k = 4 the compounding lower bound
  2·2.43 = 4.86 exceeds the diminishing upper bound 3.19 + 0.76 = 3.95 by 0.91.
Analysis (Stage 3): (H1) false (Δ1 > Δ0).  (H2) false — `paper124_verdict_refuted`.
  (H3) false in the catalog model — `third_hint_saturation`.  (H4) false —
  `paper124_single_field_impossible`.  (H5), (H6) true — `compounding_diminishing_linear`,
  `compounding_horizon`.
Cycle 2 (re-hypothesize from the analysis): (H7) a compounding extension can be
  information-bounded — false, `paper124_bounded_not_compounding`; (H8) a nonzero
  factor-residue hint curve can compound — false, `catalogCurve_compounding_iff_zero`.
  Each half of the verdict alone survives (`paper124_diminishing_extension`,
  `paper124_compounding_extension`); only the information-theoretic ceiling breaks the tie,
  and it breaks it in favour of diminishing returns.
Critique (Stage 4): all statements about the data are about *every* curve through the four
  reported points, so no extrapolation choice is hidden.  The catalog bridge assumes that the
  `k = 1` value is a conditional single-dial hint; under that reading the single-field
  statement holds, and it is stated with that interpretation explicit.
-/
import Mathlib
import Bridges.HintValueMultiFieldCeiling

namespace HintValueScaling

/-! ## 1. The abstract scaling calculus -/

section Calculus

variable (V : ℕ → ℝ)

/-- The **marginal gain** of the `(k+1)`-st hint. -/
def marginal (k : ℕ) : ℝ := V (k + 1) - V k

/-- **Compounding** hint values: the curve is superadditive. -/
def Compounding : Prop := ∀ m n : ℕ, V m + V n ≤ V (m + n)

/-- **Diminishing returns from `a` on**: marginal gains are non-increasing for `k ≥ a`. -/
def DiminishingFrom (a : ℕ) : Prop := ∀ k, a ≤ k → marginal V (k + 1) ≤ marginal V k

variable {V}

/-- Marginal gains past `k` are bounded by the marginal gain at `k`. -/
theorem marginal_le_of_diminishing {a k : ℕ} (hV : DiminishingFrom V a) (hk : a ≤ k) :
    ∀ j, marginal V (k + j) ≤ marginal V k := by
  intro j
  induction j with
  | zero => simp
  | succ j ih =>
    have := hV (k + j) (by omega)
    rw [← add_assoc]; linarith

/-- **Tangent cap.**  A diminishing curve lies under its tangent line at any `k ≥ a`. -/
theorem diminishing_linear_cap {a k : ℕ} (hV : DiminishingFrom V a) (hk : a ≤ k) :
    ∀ j : ℕ, V (k + j) ≤ V k + j * marginal V k := by
  intro j
  induction j with
  | zero => simp
  | succ j ih =>
    have h1 := marginal_le_of_diminishing hV hk j
    have h2 : V (k + (j + 1)) = V (k + j) + marginal V (k + j) := by
      simp only [marginal, ← add_assoc]; ring
    rw [h2]; push_cast; nlinarith

/-- A compounding curve has `V 0 ≤ 0`. -/
theorem compounding_zero_nonpos (hC : Compounding V) : V 0 ≤ 0 := by
  have := hC 0 0; simp at this; linarith

/-- **Secant floor.**  A compounding curve dominates the multiples of any of its values. -/
theorem compounding_succ_mul (hC : Compounding V) (b : ℕ) :
    ∀ m : ℕ, ((m : ℝ) + 1) * V b ≤ V ((m + 1) * b) := by
  intro m
  induction m with
  | zero => simp
  | succ m ih =>
    have h := hC ((m + 1) * b) b
    have he : (m + 1) * b + b = (m + 1 + 1) * b := by ring
    rw [he] at h
    push_cast; nlinarith

/-- **THE COMPOUNDING HORIZON.**  If `V` compounds and its marginal gains diminish from `a`
on, every marginal gain past `a` is at least any average rate `V b / b` of the curve. -/
theorem compounding_horizon {a k : ℕ} (hC : Compounding V) (hV : DiminishingFrom V a)
    (hk : a ≤ k) (b : ℕ) : V b ≤ b * marginal V k := by
  rcases Nat.eq_zero_or_pos b with rfl | hb
  · simpa using compounding_zero_nonpos hC
  by_contra hcon
  push_neg at hcon
  set c : ℝ := V b - b * marginal V k with hc
  have hcpos : 0 < c := by linarith
  obtain ⟨N, hN⟩ := exists_nat_gt ((V k - k * marginal V k) / c)
  -- take `M = k + N` copies of `b`
  set M : ℕ := k + N with hM
  have hMb : k ≤ (M + 1) * b := by
    have : (M + 1) * 1 ≤ (M + 1) * b := Nat.mul_le_mul_left _ hb
    omega
  have hlow := compounding_succ_mul hC b M
  have hup := diminishing_linear_cap hV hk ((M + 1) * b - k)
  rw [Nat.add_sub_cancel' hMb] at hup
  have hcast : (((M + 1) * b - k : ℕ) : ℝ) = ((M : ℝ) + 1) * b - k := by
    rw [Nat.cast_sub hMb]; push_cast; ring
  rw [hcast] at hup
  have hkey : ((M : ℝ) + 1) * c ≤ V k - k * marginal V k := by
    rw [hc]; nlinarith
  have hNc : (V k - k * marginal V k) < N * c := by
    rwa [div_lt_iff₀ hcpos] at hN
  have hMN : (N : ℝ) ≤ (M : ℝ) + 1 := by
    rw [hM]; push_cast; linarith [(Nat.cast_nonneg k : (0 : ℝ) ≤ k)]
  nlinarith

/-- **Compounding + diminishing from the first hint = linear.** -/
theorem compounding_diminishing_linear (hC : Compounding V) (hV : DiminishingFrom V 0)
    (h0 : V 0 = 0) (k : ℕ) : V k = k * V 1 := by
  have hup := diminishing_linear_cap hV (le_refl 0) k
  simp only [zero_add, marginal, h0, sub_zero] at hup
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · simp [h0]
  · obtain ⟨m, rfl⟩ : ∃ m, k = m + 1 := ⟨k - 1, by omega⟩
    have hlow := compounding_succ_mul hC 1 m
    simp only [mul_one] at hlow
    push_cast at hup ⊢
    linarith

/-- Under compounding with diminishing returns from the start, all marginal gains equal
`V 1`. -/
theorem compounding_diminishing_marginal_const (hC : Compounding V)
    (hV : DiminishingFrom V 0) (h0 : V 0 = 0) (k : ℕ) : marginal V k = V 1 := by
  rw [marginal, compounding_diminishing_linear hC hV h0 (k + 1),
    compounding_diminishing_linear hC hV h0 k]
  push_cast; ring

/-- **Compounding and strictly diminishing returns are incompatible.** -/
theorem no_strict_diminishing_of_compounding (hC : Compounding V)
    (hV : DiminishingFrom V 0) (h0 : V 0 = 0) (k : ℕ) :
    ¬ marginal V (k + 1) < marginal V k := by
  rw [compounding_diminishing_marginal_const hC hV h0,
    compounding_diminishing_marginal_const hC hV h0]
  exact lt_irrefl _

/-- **Affine ceilings collapse to linear ones under compounding.** -/
theorem compounding_affine_ceiling {c b : ℝ} (hC : Compounding V)
    (hceil : ∀ k : ℕ, V k ≤ c * k + b) (a : ℕ) : V a ≤ c * a := by
  by_contra hcon
  push_neg at hcon
  set e : ℝ := V a - c * a with he
  have hepos : 0 < e := by linarith
  obtain ⟨N, hN⟩ := exists_nat_gt (b / e)
  have hlow := compounding_succ_mul hC a N
  have hup := hceil ((N + 1) * a)
  push_cast at hup
  have hkey : ((N : ℝ) + 1) * e ≤ b := by rw [he]; nlinarith
  have : b < N * e := by rwa [div_lt_iff₀ hepos] at hN
  nlinarith

/-- **Bounded curves cannot compound upwards.**  A compounding curve with any uniform ceiling
is nonpositive everywhere. -/
theorem compounding_bounded_nonpos {B : ℝ} (hC : Compounding V) (hB : ∀ k, V k ≤ B) (a : ℕ) :
    V a ≤ 0 := by
  have := compounding_affine_ceiling (c := 0) (b := B) hC (by simpa using hB) a
  simpa using this

end Calculus

/-! ## 2. The paper-124 data -/

section Paper124

/-- A curve **matches paper 124** if it passes through the four reported points. -/
def MatchesPaper124 (V : ℕ → ℝ) : Prop :=
  V 0 = 0 ∧ V 1 = 0.52 ∧ V 2 = 2.43 ∧ V 3 = 3.19

variable {V : ℕ → ℝ}

/-- The three reported marginal gains. -/
theorem paper124_marginals (hV : MatchesPaper124 V) :
    marginal V 0 = 0.52 ∧ marginal V 1 = 1.91 ∧ marginal V 2 = 0.76 := by
  obtain ⟨h0, h1, h2, h3⟩ := hV
  refine ⟨?_, ?_, ?_⟩ <;> simp only [marginal] <;> norm_num [h0, h1, h2, h3]

/-- **S-shape.**  All marginal gains are positive; they rise from `k = 0` to `k = 1` and fall
from `k = 1` to `k = 2`. -/
theorem paper124_accelerates_then_decelerates (hV : MatchesPaper124 V) :
    (0 < marginal V 0 ∧ 0 < marginal V 1 ∧ 0 < marginal V 2) ∧
      marginal V 0 < marginal V 1 ∧ marginal V 2 < marginal V 1 := by
  obtain ⟨h0, h1, h2⟩ := paper124_marginals hV
  rw [h0, h1, h2]; norm_num

/-- The reported curve is **not concave**: marginal gains do not diminish from `k = 0`. -/
theorem paper124_not_concave (hV : MatchesPaper124 V) : ¬ DiminishingFrom V 0 := by
  intro hD
  have := hD 0 le_rfl
  obtain ⟨h0, h1, -⟩ := paper124_marginals hV
  rw [h0, h1] at this; norm_num at this

/-- On its window the curve compounds strictly. -/
theorem paper124_window_compounds (hV : MatchesPaper124 V) :
    V 1 + V 1 < V 2 ∧ V 1 + V 2 < V 3 := by
  obtain ⟨-, h1, h2, h3⟩ := hV
  rw [h1, h2, h3]; norm_num

/-- **Asymptotic slope.**  A compounding extension of the data whose marginal gains diminish
from some `a` on has every later marginal gain at least `1.215` bits per hint. -/
theorem paper124_asymptotic_slope {a : ℕ} (hV : MatchesPaper124 V) (hC : Compounding V)
    (hD : DiminishingFrom V a) {k : ℕ} (hk : a ≤ k) : 1.215 ≤ marginal V k := by
  have h := compounding_horizon hC hD hk 2
  obtain ⟨-, -, h2, -⟩ := hV
  rw [h2] at h; push_cast at h; linarith

/-- **HINTS-COMPOUND-WITH-DIMINISHING-RETURNS is refuted as a scaling law.**  No curve through
the paper-124 points both compounds and has diminishing marginal gains from `k = 2` on. -/
theorem paper124_verdict_refuted (hV : MatchesPaper124 V) :
    ¬ (Compounding V ∧ DiminishingFrom V 2) := by
  rintro ⟨hC, hD⟩
  have h := paper124_asymptotic_slope hV hC hD (le_refl 2)
  obtain ⟨-, -, h2⟩ := paper124_marginals hV
  rw [h2] at h; norm_num at h

/-- **The failure is at the very next hint.**  Compounding at `(2,2)` and diminishing returns
at `k = 3` are already incompatible: `4.86 ≤ V 4 ≤ 3.95`. -/
theorem paper124_sharp_k4 (hV : MatchesPaper124 V) (hC : V 2 + V 2 ≤ V 4)
    (hD : marginal V 3 ≤ marginal V 2) : False := by
  obtain ⟨-, -, h2, h3⟩ := hV
  simp only [marginal] at hD
  norm_num [h2, h3] at hC hD
  linarith

/-- A compounding extension can never sit under a one-bit-per-hint affine ceiling. -/
theorem paper124_compounding_breaks_unit_ceiling (hV : MatchesPaper124 V)
    (hC : Compounding V) (b : ℝ) : ¬ ∀ k : ℕ, V k ≤ k + b := by
  intro hceil
  have h := compounding_affine_ceiling (c := 1) (b := b) hC (by simpa using hceil) 2
  obtain ⟨-, -, h2, -⟩ := hV
  rw [h2] at h; norm_num at h

/-- **Information-bounded extensions cannot compound.**  Any extension of the data under a
uniform ceiling (e.g. the label entropy) fails to compound. -/
theorem paper124_bounded_not_compounding {B : ℝ} (hV : MatchesPaper124 V) (hB : ∀ k, V k ≤ B) :
    ¬ Compounding V := by
  intro hC
  have h := compounding_bounded_nonpos hC hB 1
  obtain ⟨-, h1, -⟩ := hV
  rw [h1] at h; norm_num at h

/-- The **diminishing extension**: the data continued along the last tangent line. -/
noncomputable def diminishingExt : ℕ → ℝ
  | 0 => 0
  | 1 => 0.52
  | k + 2 => 2.43 + 0.76 * k

/-- The **compounding extension**: the data continued by `k ↦ k²`. -/
noncomputable def compoundingExt : ℕ → ℝ
  | 0 => 0
  | 1 => 0.52
  | 2 => 2.43
  | 3 => 3.19
  | k + 4 => ((k : ℝ) + 4) ^ 2

/-- Diminishing returns alone are consistent with the data. -/
theorem paper124_diminishing_extension :
    MatchesPaper124 diminishingExt ∧ DiminishingFrom diminishingExt 1 := by
  refine ⟨⟨rfl, rfl, by simp [diminishingExt], by norm_num [diminishingExt]⟩, ?_⟩
  intro k hk
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
  rcases j with _ | j
  · simp only [marginal, diminishingExt]; norm_num
  · simp only [marginal, diminishingExt]; push_cast; ring_nf; norm_num

/-- Every value of the compounding extension is at most `k²`. -/
theorem compoundingExt_le_sq (k : ℕ) : compoundingExt k ≤ (k : ℝ) ^ 2 := by
  match k with
  | 0 => simp [compoundingExt]
  | 1 => norm_num [compoundingExt]
  | 2 => norm_num [compoundingExt]
  | 3 => norm_num [compoundingExt]
  | k + 4 => simp [compoundingExt]

/-- Compounding alone is consistent with the data. -/
theorem paper124_compounding_extension :
    MatchesPaper124 compoundingExt ∧ Compounding compoundingExt := by
  refine ⟨⟨rfl, rfl, rfl, rfl⟩, ?_⟩
  intro m n
  by_cases hmn : 4 ≤ m + n
  · obtain ⟨j, hj⟩ : ∃ j, m + n = j + 4 := ⟨m + n - 4, by omega⟩
    rw [hj]
    have hm := compoundingExt_le_sq m
    have hn := compoundingExt_le_sq n
    have hcast : ((j : ℝ) + 4) = (m : ℝ) + n := by
      have : ((j + 4 : ℕ) : ℝ) = ((m + n : ℕ) : ℝ) := by rw [hj]
      push_cast at this; linarith
    rw [show compoundingExt (j + 4) = ((j : ℝ) + 4) ^ 2 from rfl, hcast]
    nlinarith [(Nat.cast_nonneg m : (0 : ℝ) ≤ m), (Nat.cast_nonneg n : (0 : ℝ) ≤ n)]
  · have hm3 : m ≤ 3 := by omega
    have hn3 : n ≤ 3 - m := by omega
    interval_cases m <;> interval_cases n <;> norm_num [compoundingExt]

end Paper124

/-! ## 3. Bridge: the hint curve of a factor-residue battery -/

section Catalog

open TraceBattery BatterySynergy SumDiffSplit HintValueJoint HintValueMultiField

variable {Ω : Type*} [Fintype Ω] {Λ : Type*} {R : Type*} [CommRing R]
  [Invertible (2 : R)]

/-- The **hint curve of a factor-residue battery**: no hint, the conditional sum-dial hint,
and from `k = 2` on the joint hint value (the joint residue view already determines the
factor residues, so further residue hints are free). -/
noncomputable def catalogCurve (L : Ω → Λ) (P Q : Ω → R) : ℕ → ℝ
  | 0 => 0
  | 1 => sumHint L P Q
  | _ + 2 => hintValue L P Q

/-- **Third-hint saturation.**  Any further hint `h` computed from the factor residues
`(p, q)` adds nothing on top of the joint residue view. -/
theorem third_hint_saturation [Nonempty Ω] {β : Type*} (L : Ω → Λ) (P Q : Ω → R) (h : R × R → β) :
    MIb L (fun x => (residueView P Q x, h (P x, Q x))) = MIb L (residueView P Q) := by
  refine MIb_eq_of_same_fibers L _ _ (fun x y => ⟨fun hxy => congrArg Prod.fst hxy, ?_⟩)
  intro hxy
  have hpq := (residueView_same_fibres P Q x y).1 hxy
  have hpq' : (P x, Q x) = (P y, Q y) := hpq
  simp only [hxy, hpq']

/-- The catalog hint curve is monotone: every marginal gain is nonnegative. -/
theorem catalogCurve_marginal_nonneg (L : Ω → Λ) (P Q : Ω → R) (k : ℕ) :
    0 ≤ marginal (catalogCurve L P Q) k := by
  match k with
  | 0 => simpa [marginal, catalogCurve] using sumHint_nonneg L P Q
  | 1 => simpa [marginal, catalogCurve] using sumHint_le_hintValue L P Q
  | k + 2 => simp [marginal, catalogCurve]

/-- The catalog hint curve is monotone. -/
theorem catalogCurve_monotone (L : Ω → Λ) (P Q : Ω → R) : Monotone (catalogCurve L P Q) :=
  monotone_nat_of_le_succ fun k => by
    have := catalogCurve_marginal_nonneg L P Q k
    simp only [marginal] at this; linarith

/-- **The catalog curve always has diminishing returns from the first hint on** — because it
saturates at `k = 2`. -/
theorem catalogCurve_diminishing (L : Ω → Λ) (P Q : Ω → R) :
    DiminishingFrom (catalogCurve L P Q) 1 := by
  intro k hk
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
  rcases j with _ | j
  · have := catalogCurve_marginal_nonneg L P Q 1
    simpa [marginal, catalogCurve] using this
  · simp [marginal, catalogCurve]

/-- Every value of the catalog hint curve is bounded by the label entropy. -/
theorem catalogCurve_le_label_entropy (L : Ω → Λ) (P Q : Ω → R) (k : ℕ) :
    catalogCurve L P Q k ≤ Hb L := by
  have hH : hintValue L P Q ≤ Hb L := by
    have h1 := MIb_le_label_entropy L (residueView P Q)
    have h2 := MIb_nonneg L (productView P Q)
    simp only [hintValue]; linarith
  have h0 : (0 : ℝ) ≤ Hb L := le_trans (MIb_nonneg L (residueView P Q))
    (MIb_le_label_entropy L _)
  match k with
  | 0 => simpa [catalogCurve] using h0
  | 1 => exact le_trans (sumHint_le_hintValue L P Q) hH
  | k + 2 => exact hH

/-- **A factor-residue hint curve compounds only if it vanishes.**  If the catalog hint curve
is superadditive, every hint value is zero. -/
theorem catalogCurve_compounding_iff_zero (L : Ω → Λ) (P Q : Ω → R) :
    Compounding (catalogCurve L P Q) ↔ ∀ k, catalogCurve L P Q k = 0 := by
  constructor
  · intro hC k
    have hle := compounding_bounded_nonpos hC (catalogCurve_le_label_entropy L P Q) k
    have hge : catalogCurve L P Q 0 ≤ catalogCurve L P Q k :=
      catalogCurve_monotone L P Q (Nat.zero_le k)
    have h0 : catalogCurve L P Q 0 = 0 := rfl
    linarith
  · intro hz m n
    rw [hz, hz, hz]; norm_num

/-- **The second-hint ceiling.**  Over a coefficient ring with a sign selector into `F`, the
`k = 1 → 2` marginal gain is at most `log₂ |F|` bits. -/
theorem catalogCurve_second_marginal_le_logb [Nonempty Ω] {F : Type*} [Fintype F] (L : Ω → Λ)
    (P Q : Ω → R) (S : SignSelector R F) :
    marginal (catalogCurve L P Q) 1 ≤ Real.logb 2 (Fintype.card F) := by
  have := hintValue_le_sumHint_add_logb L P Q S
  simp only [marginal, catalogCurve]; linarith

end Catalog

section Fields

open TraceBattery BatterySynergy SumDiffSplit HintValueJoint HintValueMultiField

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω] {Λ : Type*}

/-- **One field cannot carry the paper-124 jump.**  Over a single odd prime field, no battery
has conditional sum-dial hint `0.52` and joint hint value `2.43`: the jump `1.91` exceeds the
one-orientation-bit ceiling. -/
theorem paper124_single_field_impossible {p : ℕ} [Fact p.Prime] (hp : p % 2 = 1)
    (L : Ω → Λ) (P Q : Ω → ZMod p) : ¬ (sumHint L P Q = 0.52 ∧ hintValue L P Q = 2.43) := by
  letI := invertibleTwoOfOdd hp
  rintro ⟨h1, h2⟩
  have := hintValue_le_sumHint_add_one L P Q zsel (zsel_sound hp)
  rw [h1, h2] at this; norm_num at this

/-- The same obstruction with the gap dial as the first hint. -/
theorem paper124_single_field_impossible_gap {p : ℕ} [Fact p.Prime] (hp : p % 2 = 1)
    (L : Ω → Λ) (P Q : Ω → ZMod p) : ¬ (gapHint L P Q = 0.52 ∧ hintValue L P Q = 2.43) := by
  letI := invertibleTwoOfOdd hp
  rintro ⟨h1, h2⟩
  have := hintValue_le_gapHint_add_one L P Q zsel (zsel_sound hp)
  rw [h1, h2] at this; norm_num at this

/-- **One bit per field for the second marginal gain.**  Over a product of `k` odd prime
fields the `k = 1 → 2` marginal gain of the catalog curve is at most `k` bits; the paper-124
jump of `1.91` bits fits for `k ≥ 2`. -/
theorem second_marginal_le_num_fields {k : ℕ} (p : Fin k → ℕ) [∀ i, Fact (p i).Prime]
    (hp : ∀ i, p i % 2 = 1) (L : Ω → Λ) (P Q : Ω → ∀ i, ZMod (p i)) :
    hintValue L P Q - sumHint L P Q ≤ (k : ℝ) := by
  letI : ∀ i, Invertible (2 : ZMod (p i)) := fun i => invertibleTwoOfOdd (hp i)
  have h := hintValue_le_sumHint_add_logb L P Q (SignSelector.pi fun i => zmodSelector (hp i))
  have hcard : (Fintype.card (Fin k → Bool) : ℝ) = 2 ^ k := by simp
  rw [hcard] at h
  have hl : Real.log 2 ≠ 0 := ne_of_gt log_two_pos
  have hlog : Real.logb 2 ((2 : ℝ) ^ k) = k := by
    simp only [Real.logb, Real.log_pow]
    field_simp
  rw [hlog] at h
  linarith

end Fields

end HintValueScaling