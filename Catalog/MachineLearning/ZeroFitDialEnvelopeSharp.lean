import Mathlib
import Novelty.ZeroFitDialU64
import MachineLearning.ZeroFitDialResolution
import MachineLearning.ZeroFitDialEnvelope

/-!
# How Lipschitz is the deployment envelope?  Bracketing the shift constant

## Research context (FACT round-58 #1, exp 528, `CELL-CLOSED-DIAL-HOLDS-UNIF-52`)

`MachineLearning.ZeroFitDialEnvelope` proves that the Spearman tie ceiling is `7`-Lipschitz
in the total-variation distance between draw laws — the mathematical content of the
round-58 claim that the dial's *deployment envelope* now covers balanced as well as uniform
draws.  The constant `7` there comes from a crude cube-Lipschitz step which ignores mass
conservation.  This file sharpens it and, more importantly, bounds it from **below**, so the
true envelope constant is now bracketed.

## Main results

* `two_mul_abs_le_l1dist_add_sdiff` — the **displacement lemma**: for two profiles of equal
  length, every coordinate satisfies `2|mⱼ - m'ⱼ| ≤ ‖L-L'‖₁ + |ΣL - ΣL'|`; when the two
  profiles carry the same total mass this says no single block can absorb more than half of
  the `ℓ¹` budget.
* `sqSum_le` — the square-sum bound `Σⱼ(mⱼ+m'ⱼ)² ≤ (n+n')²`.
* `cubeSum_lipschitz_sharp` — combining the two: `|Σmⱼ³ - Σm'ⱼ³| ≤ 2n²‖L-L'‖₁` for
  mass-preserving shifts, a factor `3/2` better than the generic bound and, unlike it, using
  the conservation law.
* `ceiling_tv_stability_sharp` — the improved envelope law: ceilings are `4.1`-Lipschitz in
  total variation (constant `41/10`, valid for `n ≥ 7`), replacing the previous `7`.
* `envelope_constant_ge_two_point_nine` — the matching **lower** witness: two explicit
  52-bit profiles at total variation exactly below `1/100` whose ceilings differ by more
  than `2.96/100`.  Hence the sharp envelope constant lies in `[2.96, 4.1]`.

## The scientific payload

Envelope claims are only as strong as their modulus of continuity.  This file shows the
modulus is a genuine constant of order one — it cannot be improved below `2.96`, and it is
at most `4.1` — so a `1%` change of the draw law can move a tie ceiling by about `3%` and no
more than `4.1%`.  For the recorded bitlen-52 readings (`ρ² ≈ 0.497` against a ceiling of
`6/7 ≈ 0.857`) that is a comfortable margin: the dial's band membership survives any draw-law
shift of total variation up to about `8%`.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64

open Catalog.MachineLearning.ZeroFitDialResolution

open Catalog.MachineLearning.ZeroFitDialEnvelope

namespace Catalog.MachineLearning.ZeroFitDialEnvelopeSharp

/-! ## 1. The displacement lemma -/

/-- Signed mass difference of two profiles. -/
def sdiff (L L' : List ℕ) : ℚ := (L.sum : ℚ) - (L'.sum : ℚ)

lemma abs_sdiff_le_l1dist (L L' : List ℕ) (hlen : L.length = L'.length) :
    |sdiff L L'| ≤ l1dist L L' := by
  induction L generalizing L' with
  | nil =>
      have : L' = [] := List.length_eq_zero_iff.1 hlen.symm
      subst this
      simp [sdiff, l1dist]
  | cons a L ih =>
      cases L' with
      | nil => simp at hlen
      | cons b L' =>
          have hlen' : L.length = L'.length := by simpa using hlen
          have hrest := ih L' hlen'
          have hs : sdiff (a :: L) (b :: L') = ((a : ℚ) - (b : ℚ)) + sdiff L L' := by
            simp only [sdiff, List.sum_cons]
            push_cast
            ring
          rw [hs, l1dist]
          calc |((a : ℚ) - (b : ℚ)) + sdiff L L'| ≤ |(a : ℚ) - (b : ℚ)| + |sdiff L L'| :=
                abs_add_le _ _
            _ ≤ |(a : ℚ) - (b : ℚ)| + l1dist L L' := by linarith

/-- **Displacement lemma.**  No coordinate can move by more than half the `ℓ¹` budget, up to
the mass defect: `2|mⱼ - m'ⱼ| ≤ ‖L-L'‖₁ + |ΣL - ΣL'|`. -/
theorem two_mul_abs_le_l1dist_add_sdiff (L L' : List ℕ) (hlen : L.length = L'.length) :
    ∀ p ∈ L.zip L', 2 * |((p.1 : ℚ)) - ((p.2 : ℚ))| ≤ l1dist L L' + |sdiff L L'| := by
  induction L generalizing L' with
  | nil => intro p hp; simp at hp
  | cons a L ih =>
      cases L' with
      | nil => simp at hlen
      | cons b L' =>
          have hlen' : L.length = L'.length := by simpa using hlen
          have hs : sdiff (a :: L) (b :: L') = ((a : ℚ) - (b : ℚ)) + sdiff L L' := by
            simp only [sdiff, List.sum_cons]
            push_cast
            ring
          have hl : l1dist (a :: L) (b :: L') = |(a : ℚ) - (b : ℚ)| + l1dist L L' := by
            rw [l1dist]
          have hsd := abs_sdiff_le_l1dist L L' hlen'
          intro p hp
          rw [List.zip_cons_cons, List.mem_cons] at hp
          rcases hp with rfl | hp'
          · -- the head coordinate
            have htri : |(a : ℚ) - (b : ℚ)|
                ≤ |((a : ℚ) - (b : ℚ)) + sdiff L L'| + |sdiff L L'| := by
              have habs := abs_sub (((a : ℚ) - (b : ℚ)) + sdiff L L') (sdiff L L')
              simpa using habs
            rw [hl, hs]
            linarith
          · -- a tail coordinate
            have hih := ih L' hlen' p hp'
            have hsplit : |sdiff L L'| ≤ |(a : ℚ) - (b : ℚ)| + |sdiff (a :: L) (b :: L')| := by
              have : sdiff L L' = sdiff (a :: L) (b :: L') - ((a : ℚ) - (b : ℚ)) := by
                rw [hs]; ring
              rw [this]
              calc |sdiff (a :: L) (b :: L') - ((a : ℚ) - (b : ℚ))|
                  ≤ |sdiff (a :: L) (b :: L')| + |(a : ℚ) - (b : ℚ)| := abs_sub _ _
                _ = |(a : ℚ) - (b : ℚ)| + |sdiff (a :: L) (b :: L')| := by ring
            rw [hl]
            linarith

/-- With equal total mass, each coordinate moves by at most half the `ℓ¹` distance. -/
theorem abs_le_half_l1dist (L L' : List ℕ) (hlen : L.length = L'.length)
    (hsum : L.sum = L'.sum) :
    ∀ p ∈ L.zip L', |((p.1 : ℚ)) - ((p.2 : ℚ))| ≤ l1dist L L' / 2 := by
  intro p hp
  have h := two_mul_abs_le_l1dist_add_sdiff L L' hlen p hp
  have hs : sdiff L L' = 0 := by simp [sdiff, hsum]
  rw [hs] at h
  simp only [abs_zero, add_zero] at h
  linarith

/-! ## 2. A conservation-aware Lipschitz bound for the cube sum -/

/-- `Σⱼ (mⱼ + m'ⱼ)²`, the weight appearing in the sharpened cube bound. -/
def sqSum : List ℕ → List ℕ → ℚ
  | [], _ => 0
  | _ :: _, [] => 0
  | a :: L, b :: M => ((a : ℚ) + (b : ℚ)) ^ 2 + sqSum L M

lemma sqSum_nonneg (L L' : List ℕ) : 0 ≤ sqSum L L' := by
  induction L generalizing L' with
  | nil => simp [sqSum]
  | cons a L ih =>
      cases L' with
      | nil => simp [sqSum]
      | cons b L' =>
          have := ih L'
          have h2 : (0 : ℚ) ≤ ((a : ℚ) + (b : ℚ)) ^ 2 := sq_nonneg _
          rw [sqSum]
          linarith

lemma sqSum_le (L L' : List ℕ) : sqSum L L' ≤ ((L.sum : ℚ) + (L'.sum : ℚ)) ^ 2 := by
  induction L generalizing L' with
  | nil => simp [sqSum]; positivity
  | cons a L ih =>
      cases L' with
      | nil =>
          simp only [sqSum]
          positivity
      | cons b L' =>
          have hrest := ih L'
          have hs : (((a :: L).sum : ℕ) : ℚ) = (a : ℚ) + (L.sum : ℚ) := by
            rw [List.sum_cons]; push_cast; ring
          have hs' : (((b :: L').sum : ℕ) : ℚ) = (b : ℚ) + (L'.sum : ℚ) := by
            rw [List.sum_cons]; push_cast; ring
          have ha : (0 : ℚ) ≤ (a : ℚ) := by positivity
          have hb : (0 : ℚ) ≤ (b : ℚ) := by positivity
          have hL : (0 : ℚ) ≤ (L.sum : ℚ) := by positivity
          have hL' : (0 : ℚ) ≤ (L'.sum : ℚ) := by positivity
          rw [sqSum, hs, hs']
          nlinarith

/-- Cube sums are Lipschitz with the weight `sqSum` once all coordinate moves are bounded. -/
theorem cubeSum_diff_le_of_bounded (L L' : List ℕ) (D : ℚ) (hD0 : 0 ≤ D)
    (hlen : L.length = L'.length)
    (hD : ∀ p ∈ L.zip L', |((p.1 : ℚ)) - ((p.2 : ℚ))| ≤ D) :
    |cubeSum L - cubeSum L'| ≤ D * sqSum L L' := by
  induction L generalizing L' with
  | nil =>
      have : L' = [] := List.length_eq_zero_iff.1 hlen.symm
      subst this
      simp [cubeSum, sqSum]
  | cons a L ih =>
      cases L' with
      | nil => simp at hlen
      | cons b L' =>
          have hlen' : L.length = L'.length := by simpa using hlen
          have hhead : |(a : ℚ) - (b : ℚ)| ≤ D := by
            apply hD (a, b)
            rw [List.zip_cons_cons]
            exact List.mem_cons_self ..
          have hrest := ih L' hlen' (fun p hp => hD p (by
            rw [List.zip_cons_cons]
            exact List.mem_cons_of_mem _ hp))
          have hterm : |(a : ℚ) ^ 3 - (b : ℚ) ^ 3| ≤ D * ((a : ℚ) + (b : ℚ)) ^ 2 := by
            have hfac : (a : ℚ) ^ 3 - (b : ℚ) ^ 3
                = ((a : ℚ) - (b : ℚ)) * ((a : ℚ) ^ 2 + (a : ℚ) * (b : ℚ) + (b : ℚ) ^ 2) := by
              ring
            have ha : (0 : ℚ) ≤ (a : ℚ) := by positivity
            have hb : (0 : ℚ) ≤ (b : ℚ) := by positivity
            have hw : |(a : ℚ) ^ 2 + (a : ℚ) * (b : ℚ) + (b : ℚ) ^ 2|
                ≤ ((a : ℚ) + (b : ℚ)) ^ 2 := by
              rw [abs_of_nonneg (by positivity)]
              nlinarith
            calc |(a : ℚ) ^ 3 - (b : ℚ) ^ 3|
                = |(a : ℚ) - (b : ℚ)| * |(a : ℚ) ^ 2 + (a : ℚ) * (b : ℚ) + (b : ℚ) ^ 2| := by
                  rw [hfac, abs_mul]
              _ ≤ D * ((a : ℚ) + (b : ℚ)) ^ 2 := by
                  apply mul_le_mul hhead hw (abs_nonneg _) hD0
          have hcs : cubeSum (a :: L) - cubeSum (b :: L')
              = ((a : ℚ) ^ 3 - (b : ℚ) ^ 3) + (cubeSum L - cubeSum L') := by
            simp only [cubeSum]
            ring
          calc |cubeSum (a :: L) - cubeSum (b :: L')|
              ≤ |(a : ℚ) ^ 3 - (b : ℚ) ^ 3| + |cubeSum L - cubeSum L'| := by
                rw [hcs]; exact abs_add_le _ _
            _ ≤ D * ((a : ℚ) + (b : ℚ)) ^ 2 + D * sqSum L L' := by linarith
            _ = D * sqSum (a :: L) (b :: L') := by rw [sqSum]; ring

/-- **Conservation-aware cube Lipschitz bound.**  For mass-preserving shifts,
`|Σmⱼ³ - Σm'ⱼ³| ≤ 2n²‖L-L'‖₁`. -/
theorem cubeSum_lipschitz_sharp (L L' : List ℕ) (hlen : L.length = L'.length)
    (hsum : L.sum = L'.sum) :
    |cubeSum L - cubeSum L'| ≤ 2 * ((L.sum : ℚ)) ^ 2 * l1dist L L' := by
  have hD0 : 0 ≤ l1dist L L' / 2 := by
    have := l1dist_nonneg L L'
    linarith
  have hmain := cubeSum_diff_le_of_bounded L L' (l1dist L L' / 2) hD0 hlen
    (abs_le_half_l1dist L L' hlen hsum)
  have hsq : sqSum L L' ≤ ((L.sum : ℚ) + (L'.sum : ℚ)) ^ 2 := sqSum_le L L'
  have hcast : ((L'.sum : ℕ) : ℚ) = ((L.sum : ℕ) : ℚ) := by rw [hsum]
  rw [hcast] at hsq
  have h4 : ((L.sum : ℚ) + (L.sum : ℚ)) ^ 2 = 4 * ((L.sum : ℚ)) ^ 2 := by ring
  rw [h4] at hsq
  have hpos : 0 ≤ l1dist L L' / 2 := hD0
  calc |cubeSum L - cubeSum L'| ≤ l1dist L L' / 2 * sqSum L L' := hmain
    _ ≤ l1dist L L' / 2 * (4 * ((L.sum : ℚ)) ^ 2) := by
        exact mul_le_mul_of_nonneg_left hsq hpos
    _ = 2 * ((L.sum : ℚ)) ^ 2 * l1dist L L' := by ring

/-! ## 3. The sharpened envelope law -/

/-- **Sharpened envelope law.**  Tie ceilings are `41/10`-Lipschitz in the total-variation
distance between draw laws, improving the constant `7` of `ceiling_tv_stability`. -/
theorem ceiling_tv_stability_sharp (L L' : List ℕ) (tau : ℚ) (htau : 0 ≤ tau)
    (hlen : L.length = L'.length) (hsum : L.sum = L'.sum) (h : 7 ≤ L.sum)
    (htv : l1dist L L' ≤ 2 * tau * (L.sum : ℚ)) :
    |spearmanSq L - spearmanSq L'| ≤ 41 / 10 * tau := by
  have h2 : 2 ≤ L.sum := by omega
  have hn : (7 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := cube_sub_self_pos (by linarith)
  have h' : 2 ≤ L'.sum := hsum ▸ h2
  have hcubeL : 12 * tieCorr L = cubeSum L - (L.sum : ℚ) := twelve_tieCorr_eq L
  have hcubeL' : 12 * tieCorr L' = cubeSum L' - (L'.sum : ℚ) := twelve_tieCorr_eq L'
  have hcast : ((L'.sum : ℕ) : ℚ) = ((L.sum : ℕ) : ℚ) := by rw [hsum]
  have hdiff : spearmanSq L - spearmanSq L'
      = (cubeSum L' - cubeSum L) / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) := by
    rw [spearmanSq_eq L h2, spearmanSq_eq L' h', hcubeL, hcubeL', hcast]
    field_simp
    ring
  have hlip : |cubeSum L - cubeSum L'| ≤ 2 * ((L.sum : ℚ)) ^ 2 * l1dist L L' :=
    cubeSum_lipschitz_sharp L L' hlen hsum
  have hl1 : 2 * ((L.sum : ℚ)) ^ 2 * l1dist L L' ≤ 4 * tau * ((L.sum : ℚ)) ^ 3 := by
    have hfac : (0 : ℚ) ≤ 2 * ((L.sum : ℚ)) ^ 2 := by positivity
    calc 2 * ((L.sum : ℚ)) ^ 2 * l1dist L L'
        ≤ 2 * ((L.sum : ℚ)) ^ 2 * (2 * tau * (L.sum : ℚ)) :=
          mul_le_mul_of_nonneg_left htv hfac
      _ = 4 * tau * ((L.sum : ℚ)) ^ 3 := by ring
  rw [hdiff, abs_div, abs_of_pos hden, abs_sub_comm, div_le_iff₀ hden]
  have hgoal : 4 * tau * ((L.sum : ℚ)) ^ 3 ≤ 41 / 10 * tau * ((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) := by
    have hkey : (0 : ℚ) ≤ ((L.sum : ℚ)) ^ 3 - 41 * (L.sum : ℚ) := by nlinarith
    nlinarith [mul_nonneg htau hkey]
  linarith

/-! ## 4. The matching lower witness -/

/-- Extremal 52-bit profile: one dominant class and one singleton. -/
def witnessA : List ℕ := [4503599627370495, 1]

/-- The same profile after moving `1%` of the mass out of the dominant class. -/
def witnessB : List ℕ := [4458563631096791, 45035996273705]

lemma witnessA_sum : witnessA.sum = 4503599627370496 := by decide

lemma witnessB_sum : witnessB.sum = 4503599627370496 := by decide

lemma witness_l1 : l1dist witnessA witnessB = 90071992547408 := by
  rw [witnessA, witnessB, l1dist, l1dist, l1dist]
  norm_num

/-- **Envelope constant lower witness.**  Two explicit 52-bit profiles of equal length and
equal mass, at total variation below `1/100`, whose tie ceilings differ by more than
`2.96/100`.  Hence no envelope law can have Lipschitz constant below `2.96`, and combined
with `ceiling_tv_stability_sharp` the sharp constant lies in `[2.96, 4.1]`. -/
theorem envelope_constant_ge_two_point_nine :
    witnessA.length = witnessB.length ∧
    witnessA.sum = witnessB.sum ∧
    l1dist witnessA witnessB ≤ 2 * (1 / 100) * ((witnessA.sum : ℕ) : ℚ) ∧
    (296 / 10000 : ℚ) ≤ |spearmanSq witnessA - spearmanSq witnessB| := by
  refine ⟨by decide, by rw [witnessA_sum, witnessB_sum], ?_, ?_⟩
  · rw [witness_l1, witnessA_sum]
    norm_num
  · have hA2 : 2 ≤ witnessA.sum := by rw [witnessA_sum]; norm_num
    have hB2 : 2 ≤ witnessB.sum := by rw [witnessB_sum]; norm_num
    have hcA : 12 * tieCorr witnessA = cubeSum witnessA - (witnessA.sum : ℚ) :=
      twelve_tieCorr_eq witnessA
    have hcB : 12 * tieCorr witnessB = cubeSum witnessB - (witnessB.sum : ℚ) :=
      twelve_tieCorr_eq witnessB
    have hcubeA : cubeSum witnessA = (4503599627370495 : ℚ) ^ 3 + 1 ^ 3 := by
      rw [witnessA]
      simp only [cubeSum]
      norm_num
    have hcubeB : cubeSum witnessB
        = (4458563631096791 : ℚ) ^ 3 + (45035996273705 : ℚ) ^ 3 := by
      rw [witnessB]
      simp only [cubeSum]
      norm_num
    rw [spearmanSq_eq witnessA hA2, spearmanSq_eq witnessB hB2, hcA, hcB, hcubeA, hcubeB,
      witnessA_sum, witnessB_sum]
    rw [abs_of_nonpos (by norm_num)]
    norm_num

end Catalog.MachineLearning.ZeroFitDialEnvelopeSharp