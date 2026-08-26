import Mathlib

/-!
# The three-bin log-convexity defect: kernel existence is identified, steepness is not

Companion to `MachineLearning.EdgeSpikeCensoring`.  That file shows that the
*steepness* `b` of a left-edge spike is censored by the data.  Here we show the
complementary half of the round-88 audit: what the data **do** identify, and
why they identify it uniformly in the cap.

Take three equal bins of the unit interval.  An exponential law with rate `b`
truncated to `[0,1]` has bin probabilities `geomBin r j = r ^ j / (1 + r + r²)`
with `r = exp (-b/3)`; they are geometric, so the *log-convexity defect*

`defect x y z = x * z - y ^ 2`

vanishes identically on the whole single-law family (`defect_geom_eq_zero`).
For the two-component profile *flat bulk + spike* the defect equals
`rho (1 - rho) (1 - r)² / (3 (1 + r + r²))`, which is **strictly positive** and,
once `r ≤ 1/2` (i.e. `b ≥ 3 log 2`), bounded below by `rho (1 - rho) / 21`
independently of `b` (`defect_mix_ge`).  Since the defect is `4`-Lipschitz in
the sup-norm on bin vectors, the mixture stays at sup-distance at least
`rho (1 - rho) / 84` from *every* single-law bin vector
(`single_law_separation`).  This is the formal counterpart of
"`dAICc ≈ -100` at every cap: kernel existence never wavers".

At the same time the observable bin vector is exponentially insensitive to the
steepness (`steepness_valley`): two steepnesses above `B` produce bin vectors
within `4 rho exp (-B/3)` of each other.  Identified: the presence of the
kernel.  Unidentified: how steep it is.

The section `GeneralBins` repeats the whole argument for an arbitrary number
`k ≥ 1` of equal bins: `defect_geomK_eq_zero`, the closed form
`defect_mixK_eq`, the cap-uniform bound `rho (1 - rho) / (8 k)`
(`defect_mixK_ge`) and the separation `rho (1 - rho) / (32 k)`
(`single_law_separationK`).  The evidence for a second component therefore
degrades only linearly in the number of bins, never with the steepness.

Finally `twoComp_role_swap` records the second, exact non-identifiability
direction disclosed in the ledger: swapping the two components together with
the mixing weight leaves every observable unchanged, so no criterion computed
from the bin probabilities can have a unique maximiser.
-/

namespace EdgeSpikeDefect

open Real

/-- Bin probability of bin `j` for an exponential law truncated to `[0,1]` and
binned into three equal cells, written in terms of `r = exp (-b/3)`. -/
noncomputable def geomBin (r : ℝ) (j : ℕ) : ℝ := r ^ j / (1 + r + r ^ 2)

/-- Bin probability of the *flat bulk + left-edge spike* profile on three equal
bins: weight `1 - rho` uniform, weight `rho` on the truncated exponential. -/
noncomputable def mixBin (rho r : ℝ) (j : ℕ) : ℝ := (1 - rho) / 3 + rho * geomBin r j

/-- The three-bin log-convexity defect.  It vanishes exactly on geometric
(= single truncated-exponential) bin vectors. -/
def defect (x y z : ℝ) : ℝ := x * z - y ^ 2

section GeomBasic

variable {r : ℝ} {j : ℕ}

lemma geom_den_pos (hr : 0 ≤ r) : 0 < 1 + r + r ^ 2 := by nlinarith [sq_nonneg r]

/-- The geometric bin weights are genuinely the binned truncated exponential. -/
lemma geomBin_exp (b : ℝ) (hb : 0 < b) (j : ℕ) :
    geomBin (exp (-(b / 3))) j =
      (exp (-(b * j / 3)) - exp (-(b * (j + 1) / 3))) / (1 - exp (-b)) := by
  set r := exp (-(b / 3)) with hrdef
  have hrpos : 0 < r := Real.exp_pos _
  have hr1 : r < 1 := Real.exp_lt_one_iff.mpr (by linarith)
  have hpow : ∀ n : ℕ, r ^ n = exp (-(b * n / 3)) := by
    intro n
    rw [hrdef, ← Real.exp_nat_mul]
    ring_nf
  have hcube : r ^ 3 = exp (-b) := by
    rw [hpow 3]; norm_num
  have hsucc : exp (-(b * ((j : ℝ) + 1) / 3)) = r ^ (j + 1) := by
    have := hpow (j + 1)
    push_cast at this
    linarith
  have hden : (1 : ℝ) + r + r ^ 2 ≠ 0 := ne_of_gt (geom_den_pos hrpos.le)
  have hone : (1 : ℝ) - r ≠ 0 := by intro hc; linarith
  have hc3 : (1 : ℝ) - r ^ 3 ≠ 0 := by
    have : r ^ 3 < 1 := pow_lt_one₀ hrpos.le hr1 (by norm_num)
    intro hcon; linarith
  rw [← hpow j, hsucc, ← hcube]
  unfold geomBin
  field_simp
  ring

lemma geomBin_nonneg (hr : 0 ≤ r) : 0 ≤ geomBin r j :=
  div_nonneg (pow_nonneg hr j) (geom_den_pos hr).le

lemma geomBin_le_one (hr0 : 0 ≤ r) (hr1 : r ≤ 1) : geomBin r j ≤ 1 := by
  have hden := geom_den_pos hr0
  unfold geomBin
  rw [div_le_one hden]
  have : r ^ j ≤ 1 := pow_le_one₀ hr0 hr1
  nlinarith [sq_nonneg r]

/-- The three geometric bin weights are a probability vector. -/
lemma geomBin_sum (hr : 0 ≤ r) : geomBin r 0 + geomBin r 1 + geomBin r 2 = 1 := by
  have hden : (1 : ℝ) + r + r ^ 2 ≠ 0 := ne_of_gt (geom_den_pos hr)
  unfold geomBin
  field_simp

lemma mixBin_nonneg (hrho0 : 0 ≤ rho) (hrho1 : rho ≤ 1) (hr : 0 ≤ r) :
    0 ≤ mixBin rho r j := by
  unfold mixBin
  have := geomBin_nonneg (r := r) (j := j) hr
  nlinarith

lemma mixBin_le_one (hrho0 : 0 ≤ rho) (hrho1 : rho ≤ 1) (hr0 : 0 ≤ r) (hr1 : r ≤ 1) :
    mixBin rho r j ≤ 1 := by
  unfold mixBin
  have := geomBin_le_one (r := r) (j := j) hr0 hr1
  nlinarith

lemma mixBin_sum (hr : 0 ≤ r) :
    mixBin rho r 0 + mixBin rho r 1 + mixBin rho r 2 = 1 := by
  unfold mixBin
  have h := geomBin_sum (r := r) hr
  linear_combination rho * h

end GeomBasic

section Defect

variable {r rho : ℝ}

/-- **Every single truncated-exponential law has zero defect**: its binned
weights are geometric, so `p₀ p₂ = p₁²` exactly, for every rate. -/
theorem defect_geom_eq_zero (hr : 0 ≤ r) :
    defect (geomBin r 0) (geomBin r 1) (geomBin r 2) = 0 := by
  have hden : (1 : ℝ) + r + r ^ 2 ≠ 0 := ne_of_gt (geom_den_pos hr)
  unfold defect geomBin
  field_simp
  ring

/-- **Closed form for the defect of the two-component profile.** -/
theorem defect_mix_eq (hr : 0 ≤ r) :
    defect (mixBin rho r 0) (mixBin rho r 1) (mixBin rho r 2) =
      rho * (1 - rho) / 3 * ((1 - r) ^ 2 / (1 + r + r ^ 2)) := by
  have hden : (1 : ℝ) + r + r ^ 2 ≠ 0 := ne_of_gt (geom_den_pos hr)
  unfold defect mixBin geomBin
  field_simp
  ring

/-- The mixture has a **strictly positive** defect: no single law can reproduce
it, whatever the steepness. -/
theorem defect_mix_pos (hrho0 : 0 < rho) (hrho1 : rho < 1) (hr0 : 0 ≤ r) (hr1 : r < 1) :
    0 < defect (mixBin rho r 0) (mixBin rho r 1) (mixBin rho r 2) := by
  rw [defect_mix_eq hr0]
  have hden := geom_den_pos hr0
  have h1 : 0 < (1 - r) ^ 2 := pow_pos (by linarith) 2
  have h2 : 0 < rho * (1 - rho) / 3 := div_pos (mul_pos hrho0 (by linarith)) (by norm_num)
  exact mul_pos h2 (div_pos h1 hden)

/-- **Cap-uniform lower bound.**  For every steepness with `r = exp (-b/3) ≤ 1/2`
(i.e. `b ≥ 3 log 2`) the defect is at least `rho (1 - rho) / 21`: the evidence
for a second component does not degrade as the cap is raised. -/
theorem defect_mix_ge (hrho0 : 0 < rho) (hrho1 : rho < 1) (hr0 : 0 ≤ r)
    (hr1 : r ≤ 1 / 2) :
    rho * (1 - rho) / 21 ≤ defect (mixBin rho r 0) (mixBin rho r 1) (mixBin rho r 2) := by
  rw [defect_mix_eq hr0]
  have hden : 0 < 1 + r + r ^ 2 := geom_den_pos hr0
  have hnum : (1 : ℝ) / 4 ≤ (1 - r) ^ 2 := by nlinarith
  have hden' : 1 + r + r ^ 2 ≤ 7 / 4 := by nlinarith
  have hkey : (1 : ℝ) / 7 ≤ (1 - r) ^ 2 / (1 + r + r ^ 2) := by
    rw [le_div_iff₀ hden]
    nlinarith
  have hpos : 0 < rho * (1 - rho) / 3 :=
    div_pos (mul_pos hrho0 (by linarith)) (by norm_num)
  nlinarith [hkey, hpos]

/-- The defect is `4`-Lipschitz in the sup-norm on `[0,1]`-valued bin vectors. -/
theorem defect_lipschitz {x y z x' y' z' e : ℝ}
    (hx : 0 ≤ x) (hx1 : x ≤ 1) (hy : 0 ≤ y) (hy1 : y ≤ 1) (hz : 0 ≤ z) (hz1 : z ≤ 1)
    (hx' : 0 ≤ x') (hx1' : x' ≤ 1) (hy' : 0 ≤ y') (hy1' : y' ≤ 1)
    (hdx : |x - x'| ≤ e) (hdy : |y - y'| ≤ e) (hdz : |z - z'| ≤ e) :
    |defect x y z - defect x' y' z'| ≤ 4 * e := by
  have hxx := abs_le.mp hdx
  have hyy := abs_le.mp hdy
  have hzz := abs_le.mp hdz
  have he : 0 ≤ e := le_trans (abs_nonneg _) hdx
  unfold defect
  rw [abs_le]
  constructor <;> nlinarith [hxx.1, hxx.2, hyy.1, hyy.2, hzz.1, hzz.2]

/-- **Single-law exclusion, uniformly in the cap.**  For any steepness of the
spike with `r ≤ 1/2` and *any* single-law parameter `r'`, some bin probability
differs by at least `rho (1 - rho) / 84`.  The two-component kernel is therefore
excluded from the one-parameter family by a margin that does not depend on the
(unidentified) steepness. -/
theorem single_law_separation {r' : ℝ} (hrho0 : 0 < rho) (hrho1 : rho < 1)
    (hr0 : 0 ≤ r) (hr1 : r ≤ 1 / 2) (hr0' : 0 ≤ r') (hr1' : r' ≤ 1) :
    rho * (1 - rho) / 84 ≤
      max |mixBin rho r 0 - geomBin r' 0|
        (max |mixBin rho r 1 - geomBin r' 1| |mixBin rho r 2 - geomBin r' 2|) := by
  set e := max |mixBin rho r 0 - geomBin r' 0|
      (max |mixBin rho r 1 - geomBin r' 1| |mixBin rho r 2 - geomBin r' 2|) with hedef
  have h0 : |mixBin rho r 0 - geomBin r' 0| ≤ e := le_max_left _ _
  have h1 : |mixBin rho r 1 - geomBin r' 1| ≤ e :=
    le_trans (le_max_left _ _) (le_max_right _ _)
  have h2 : |mixBin rho r 2 - geomBin r' 2| ≤ e :=
    le_trans (le_max_right _ _) (le_max_right _ _)
  have hlip := defect_lipschitz
    (mixBin_nonneg (j := 0) hrho0.le hrho1.le hr0)
    (mixBin_le_one (j := 0) hrho0.le hrho1.le hr0 (by linarith))
    (mixBin_nonneg (j := 1) hrho0.le hrho1.le hr0)
    (mixBin_le_one (j := 1) hrho0.le hrho1.le hr0 (by linarith))
    (mixBin_nonneg (j := 2) hrho0.le hrho1.le hr0)
    (mixBin_le_one (j := 2) hrho0.le hrho1.le hr0 (by linarith))
    (geomBin_nonneg (j := 0) hr0') (geomBin_le_one (j := 0) hr0' hr1')
    (geomBin_nonneg (j := 1) hr0') (geomBin_le_one (j := 1) hr0' hr1')
    h0 h1 h2
  rw [defect_geom_eq_zero hr0', sub_zero] at hlip
  have hlow := defect_mix_ge hrho0 hrho1 hr0 hr1
  have hpos : 0 < defect (mixBin rho r 0) (mixBin rho r 1) (mixBin rho r 2) :=
    defect_mix_pos hrho0 hrho1 hr0 (by linarith)
  rw [abs_of_pos hpos] at hlip
  linarith

end Defect

section Valley

variable {rho r r' : ℝ}

lemma geomBin_close (hr0 : 0 ≤ r) (hr1 : r ≤ 1) {j : ℕ} (hj : 1 ≤ j) :
    geomBin r j ≤ r := by
  have hden := geom_den_pos hr0
  unfold geomBin
  rw [div_le_iff₀ hden]
  have hpow : r ^ j ≤ r := by
    calc r ^ j ≤ r ^ 1 := pow_le_pow_of_le_one hr0 hr1 hj
      _ = r := pow_one r
  nlinarith [sq_nonneg r, mul_nonneg hr0 hr0]

lemma geomBin_zero_close (hr0 : 0 ≤ r) : |geomBin r 0 - 1| ≤ 2 * r := by
  have hden := geom_den_pos hr0
  have hval : geomBin r 0 - 1 = -((r + r ^ 2) / (1 + r + r ^ 2)) := by
    unfold geomBin
    field_simp
    ring
  rw [hval, abs_neg, abs_of_nonneg (by positivity), div_le_iff₀ hden]
  nlinarith [sq_nonneg r, mul_nonneg hr0 hr0]

/-- **The steepness valley.**  Above any threshold `B ≥ 0`, all steepnesses give
bin vectors within `4 rho exp (-B/3)` of each other: the observable is
exponentially insensitive to the steepness, which is precisely why the fitted
value rides whatever cap is imposed. -/
theorem steepness_valley (hrho0 : 0 ≤ rho) {b b' B : ℝ} (hB : 0 ≤ B)
    (hb : B ≤ b) (hb' : B ≤ b') (j : ℕ) :
    |mixBin rho (exp (-(b / 3))) j - mixBin rho (exp (-(b' / 3))) j| ≤
      4 * rho * exp (-(B / 3)) := by
  set eB := exp (-(B / 3)) with hEdef
  have hEpos : 0 < eB := Real.exp_pos _
  have key : ∀ c : ℝ, B ≤ c →
      |geomBin (exp (-(c / 3))) j - (if j = 0 then (1 : ℝ) else 0)| ≤ 2 * eB := by
    intro c hc
    have hcpos : 0 < exp (-(c / 3)) := Real.exp_pos _
    have hcle : exp (-(c / 3)) ≤ eB := Real.exp_le_exp.mpr (by linarith)
    by_cases hj0 : j = 0
    · rw [if_pos hj0, hj0]
      exact le_trans (geomBin_zero_close hcpos.le) (by linarith)
    · rw [if_neg hj0, sub_zero, abs_of_nonneg (geomBin_nonneg (j := j) hcpos.le)]
      have hle := geomBin_close (r := exp (-(c / 3))) hcpos.le
        (Real.exp_le_one_iff.mpr (by linarith)) (Nat.one_le_iff_ne_zero.mpr hj0)
      linarith
  have k1 := key b hb
  have k2 := key b' hb'
  have htri := abs_sub_le (geomBin (exp (-(b / 3))) j) (if j = 0 then (1 : ℝ) else 0)
    (geomBin (exp (-(b' / 3))) j)
  rw [abs_sub_comm (if j = 0 then (1 : ℝ) else 0) (geomBin (exp (-(b' / 3))) j)] at htri
  have hdiff : |geomBin (exp (-(b / 3))) j - geomBin (exp (-(b' / 3))) j| ≤ 4 * eB := by
    linarith
  have hmix : mixBin rho (exp (-(b / 3))) j - mixBin rho (exp (-(b' / 3))) j =
      rho * (geomBin (exp (-(b / 3))) j - geomBin (exp (-(b' / 3))) j) := by
    unfold mixBin; ring
  rw [hmix, abs_mul, abs_of_nonneg hrho0]
  calc rho * |geomBin (exp (-(b / 3))) j - geomBin (exp (-(b' / 3))) j|
      ≤ rho * (4 * eB) := mul_le_mul_of_nonneg_left hdiff hrho0
    _ = 4 * rho * eB := by ring

end Valley

section RoleSwap

/-- Bin probabilities of a genuine two-component mixture of truncated
exponentials with steepnesses `b₁, b₂` and weight `rho` on the first. -/
noncomputable def twoCompBin (rho b₁ b₂ : ℝ) (j : ℕ) : ℝ :=
  rho * geomBin (exp (-(b₁ / 3))) j + (1 - rho) * geomBin (exp (-(b₂ / 3))) j

/-- **Exact role swap.**  Exchanging the two components together with the mixing
weight changes no observable: this is a second, exact non-identifiability
direction, on top of the censoring of the steepness. -/
theorem twoComp_role_swap (rho b₁ b₂ : ℝ) (j : ℕ) :
    twoCompBin rho b₁ b₂ j = twoCompBin (1 - rho) b₂ b₁ j := by
  unfold twoCompBin
  ring

/-- Consequently, any fitting criterion `F` that reads the model only through
its bin probabilities has a non-unique optimum whenever the two steepnesses
differ and the weight is not `1/2`: the swapped parameter point is a distinct
point with the same criterion value. -/
theorem role_swap_nonunique (F : (ℕ → ℝ) → ℝ) {rho b₁ b₂ : ℝ}
    (hb : b₁ ≠ b₂) :
    ((rho, b₁, b₂) : ℝ × ℝ × ℝ) ≠ (1 - rho, b₂, b₁) ∧
      F (twoCompBin rho b₁ b₂) = F (twoCompBin (1 - rho) b₂ b₁) := by
  refine ⟨?_, ?_⟩
  · intro hc
    exact hb (congrArg (fun x => x.2.1) hc)
  · congr 1
    funext j
    exact twoComp_role_swap rho b₁ b₂ j

end RoleSwap

section GeneralBins

/-!
### From three bins to `k` bins

The three-bin computation is not special.  For any number `k ≥ 1` of equal bins
the single-law weights are still geometric, hence still have vanishing second
log-differences, while the flat-plus-spike mixture has defect
`rho (1 - rho) / k · q_j (1 - r)²`.  The margin degrades only like `1/k`.
-/

/-- Bin `j` of a truncated exponential binned into `k` equal cells, `r = exp (-b/k)`. -/
noncomputable def geomBinK (k : ℕ) (r : ℝ) (j : ℕ) : ℝ := r ^ j * (1 - r) / (1 - r ^ k)

/-- Bin `j` of the flat-bulk plus spike profile on `k` equal cells. -/
noncomputable def mixBinK (k : ℕ) (rho r : ℝ) (j : ℕ) : ℝ :=
  (1 - rho) / k + rho * geomBinK k r j

variable {k j : ℕ} {r rho : ℝ}

lemma geomK_den_pos (hk : 1 ≤ k) (hr0 : 0 ≤ r) (hr1 : r < 1) : 0 < 1 - r ^ k := by
  have : r ^ k < 1 := pow_lt_one₀ hr0 hr1 (by omega)
  linarith

lemma geomBinK_nonneg (hk : 1 ≤ k) (hr0 : 0 ≤ r) (hr1 : r < 1) : 0 ≤ geomBinK k r j := by
  unfold geomBinK
  exact div_nonneg (mul_nonneg (pow_nonneg hr0 j) (by linarith))
    (geomK_den_pos hk hr0 hr1).le

lemma geomBinK_le_one (hk : 1 ≤ k) (hr0 : 0 ≤ r) (hr1 : r < 1) : geomBinK k r j ≤ 1 := by
  have hden := geomK_den_pos hk hr0 hr1
  have hrk : r ^ k ≤ r := by
    calc r ^ k ≤ r ^ 1 := pow_le_pow_of_le_one hr0 hr1.le hk
      _ = r := pow_one r
  have hnum : r ^ j * (1 - r) ≤ 1 - r ^ k := by
    have h1 : r ^ j ≤ 1 := pow_le_one₀ hr0 hr1.le
    nlinarith
  unfold geomBinK
  rw [div_le_one hden]
  exact hnum

/-- The `k` geometric bin weights are a probability vector. -/
lemma geomBinK_sum (hk : 1 ≤ k) (hr0 : 0 ≤ r) (hr1 : r < 1) :
    ∑ j ∈ Finset.range k, geomBinK k r j = 1 := by
  have hden := geomK_den_pos hk hr0 hr1
  have hone : r - 1 ≠ 0 := by intro hc; linarith
  have hgeom : ∑ j ∈ Finset.range k, r ^ j = (r ^ k - 1) / (r - 1) :=
    geom_sum_eq (by intro hc; rw [hc] at hr1; linarith) k
  unfold geomBinK
  rw [← Finset.sum_div, ← Finset.sum_mul, hgeom]
  field_simp
  ring

/-- **Every single law has vanishing second log-difference, for every `k`.** -/
theorem defect_geomK_eq_zero (hk : 1 ≤ k) (hr0 : 0 ≤ r) (hr1 : r < 1) :
    defect (geomBinK k r j) (geomBinK k r (j + 1)) (geomBinK k r (j + 2)) = 0 := by
  have hden : (1 : ℝ) - r ^ k ≠ 0 := ne_of_gt (geomK_den_pos hk hr0 hr1)
  unfold defect geomBinK
  field_simp
  ring

/-- **Closed form of the `k`-bin defect of the two-component profile.** -/
theorem defect_mixK_eq (hk : 1 ≤ k) (hr0 : 0 ≤ r) (hr1 : r < 1) :
    defect (mixBinK k rho r j) (mixBinK k rho r (j + 1)) (mixBinK k rho r (j + 2)) =
      rho * (1 - rho) / k * (geomBinK k r j * (1 - r) ^ 2) := by
  have hden : (1 : ℝ) - r ^ k ≠ 0 := ne_of_gt (geomK_den_pos hk hr0 hr1)
  have hk0 : (k : ℝ) ≠ 0 := by
    have : 0 < k := hk
    positivity
  unfold defect mixBinK geomBinK
  field_simp
  ring

/-- **The margin degrades only like `1/k`.**  For `r ≤ 1/2` the leading `k`-bin
defect of the mixture is at least `rho (1 - rho) / (8 k)`, uniformly in the
steepness. -/
theorem defect_mixK_ge (hk : 1 ≤ k) (hrho0 : 0 < rho) (hrho1 : rho < 1)
    (hr0 : 0 ≤ r) (hr1 : r ≤ 1 / 2) :
    rho * (1 - rho) / (8 * k) ≤
      defect (mixBinK k rho r 0) (mixBinK k rho r 1) (mixBinK k rho r 2) := by
  have hrlt : r < 1 := by linarith
  have hden := geomK_den_pos hk hr0 hrlt
  have hk0 : (0 : ℝ) < k := by exact_mod_cast hk
  rw [defect_mixK_eq hk hr0 hrlt]
  have hq0 : (1 : ℝ) / 2 ≤ geomBinK k r 0 := by
    unfold geomBinK
    rw [le_div_iff₀ hden]
    have hrk : (0 : ℝ) ≤ r ^ k := pow_nonneg hr0 k
    simp only [pow_zero, one_mul]
    nlinarith
  have hsq : (1 : ℝ) / 4 ≤ (1 - r) ^ 2 := by nlinarith
  have hprod : (1 : ℝ) / 8 ≤ geomBinK k r 0 * (1 - r) ^ 2 := by nlinarith
  have hcoef : 0 < rho * (1 - rho) / k := div_pos (mul_pos hrho0 (by linarith)) hk0
  have : rho * (1 - rho) / (8 * k) = rho * (1 - rho) / k * (1 / 8) := by
    field_simp
  rw [this]
  exact mul_le_mul_of_nonneg_left hprod hcoef.le

/-- **`k`-bin single-law exclusion.**  Some bin probability of the mixture
differs from that of *any* single law by at least `rho (1 - rho) / (32 k)`. -/
theorem single_law_separationK {r' : ℝ} (hk : 1 ≤ k) (hrho0 : 0 < rho) (hrho1 : rho < 1)
    (hr0 : 0 ≤ r) (hr1 : r ≤ 1 / 2) (hr0' : 0 ≤ r') (hr1' : r' < 1) :
    rho * (1 - rho) / (32 * k) ≤
      max |mixBinK k rho r 0 - geomBinK k r' 0|
        (max |mixBinK k rho r 1 - geomBinK k r' 1| |mixBinK k rho r 2 - geomBinK k r' 2|) := by
  have hrlt : r < 1 := by linarith
  have hk0 : (0 : ℝ) < k := by exact_mod_cast hk
  set e := max |mixBinK k rho r 0 - geomBinK k r' 0|
      (max |mixBinK k rho r 1 - geomBinK k r' 1| |mixBinK k rho r 2 - geomBinK k r' 2|)
    with hedef
  have h0 : |mixBinK k rho r 0 - geomBinK k r' 0| ≤ e := le_max_left _ _
  have h1 : |mixBinK k rho r 1 - geomBinK k r' 1| ≤ e :=
    le_trans (le_max_left _ _) (le_max_right _ _)
  have h2 : |mixBinK k rho r 2 - geomBinK k r' 2| ≤ e :=
    le_trans (le_max_right _ _) (le_max_right _ _)
  have hmixnn : ∀ i : ℕ, 0 ≤ mixBinK k rho r i := by
    intro i
    unfold mixBinK
    have := geomBinK_nonneg (k := k) (j := i) hk hr0 hrlt
    have : 0 ≤ (1 - rho) / k := div_nonneg (by linarith) hk0.le
    positivity
  have hmixle : ∀ i : ℕ, mixBinK k rho r i ≤ 1 := by
    intro i
    unfold mixBinK
    have hg := geomBinK_le_one (k := k) (j := i) hk hr0 hrlt
    have hka : (1 - rho) / k ≤ 1 - rho := by
      rw [div_le_iff₀ hk0]
      have : (1 : ℝ) ≤ k := by exact_mod_cast hk
      nlinarith
    nlinarith
  have hlip := defect_lipschitz
    (hmixnn 0) (hmixle 0) (hmixnn 1) (hmixle 1) (hmixnn 2) (hmixle 2)
    (geomBinK_nonneg (k := k) (j := 0) hk hr0' hr1')
    (geomBinK_le_one (k := k) (j := 0) hk hr0' hr1')
    (geomBinK_nonneg (k := k) (j := 1) hk hr0' hr1')
    (geomBinK_le_one (k := k) (j := 1) hk hr0' hr1')
    h0 h1 h2
  have hzero : defect (geomBinK k r' 0) (geomBinK k r' 1) (geomBinK k r' 2) = 0 := by
    have := defect_geomK_eq_zero (k := k) (j := 0) hk hr0' hr1'
    simpa using this
  rw [hzero, sub_zero] at hlip
  have hlow := defect_mixK_ge hk hrho0 hrho1 hr0 hr1
  have hpos : 0 < defect (mixBinK k rho r 0) (mixBinK k rho r 1) (mixBinK k rho r 2) := by
    have hc : 0 < rho * (1 - rho) / (8 * k) :=
      div_pos (mul_pos hrho0 (by linarith)) (by linarith)
    linarith
  rw [abs_of_pos hpos] at hlip
  have h8 : rho * (1 - rho) / (8 * k) ≤ 4 * e := le_trans hlow hlip
  have hmul := (div_le_iff₀ (show (0 : ℝ) < 8 * k by linarith)).mp h8
  rw [div_le_iff₀ (show (0 : ℝ) < 32 * k by linarith)]
  linarith

end GeneralBins

end EdgeSpikeDefect