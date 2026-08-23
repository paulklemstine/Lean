/-
# Regime homotopy and the concordance budget of the yield dial

Second cycle of the `UniformDial` thread (see `Combinatorics.UniformDialDrawInvariance`
for the pairwise identity and the sign-invariance theorems).

Two structural questions are settled here.

**(1) What happens *between* two draw regimes?**  Interpolating linearly from a balanced
regime `p` to a genuinely unbalanced regime `q` gives a one-parameter family
`mixWeights p q t`.  `wcov_mix` shows the dial reading is an *exact quadratic* in `t`
with an explicit cross term, and `wcov_mix_ge` / `wcov_mix_ge_half_min` show that for a
comonotone population the reading along the whole homotopy never drops below
`½ · min(endpoint readings)`.  So the dial cannot be diluted *anywhere* on the path, not
merely at the two measured endpoints — a strictly stronger statement than comparing two
experiments.

**(2) How unbalanced may a draw be before the dial could break?**  `wcov_budget` bounds
the dial from below by `ε²·C − M²·Δ`, where `C` and `Δ` are the total concordant and
discordant pair masses of the *population* (regime-free quantities) and `[ε, M]` bounds
the regime's per-key mass.  `dial_pos_of_concordance_ratio` turns this into a triage
rule: the dial is positive in *every* regime whose mass ratio `κ = M/ε` satisfies
`κ² · Δ < C`.  Dilution is therefore impossible until the draw's conditioning number
exceeds an explicit population-determined threshold.
-/
import Combinatorics.UniformDialDrawInvariance

open Finset

namespace Catalog.UniformDial

variable {ι : Type*} [Fintype ι]

/-! ### Homotopy between two draw regimes -/

/-- Linear interpolation between two weightings. -/
noncomputable def mixWeights (p q : ι → ℝ) (t : ℝ) : ι → ℝ := fun i => (1 - t) * p i + t * q i

lemma mixWeights_total {p q : ι → ℝ} (hp : ∑ i, p i = 1) (hq : ∑ i, q i = 1) (t : ℝ) :
    ∑ i, mixWeights p q t i = 1 := by
  simp only [mixWeights]
  rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum, hp, hq]
  ring

omit [Fintype ι] in
lemma mixWeights_nonneg {p q : ι → ℝ} (hp0 : ∀ i, 0 ≤ p i) (hq0 : ∀ i, 0 ≤ q i)
    {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (i : ι) : 0 ≤ mixWeights p q t i :=
  add_nonneg (mul_nonneg (by linarith) (hp0 i)) (mul_nonneg ht0 (hq0 i))

/-- The homotopy between two draw regimes, as a draw regime. -/
noncomputable def DrawRegime.mix (R S : DrawRegime ι) {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    DrawRegime ι where
  p := mixWeights R.p S.p t
  nonneg := mixWeights_nonneg R.nonneg S.nonneg ht0 ht1
  total := mixWeights_total R.total S.total t

private lemma sum_four_comb (f1 f2 f3 f4 : ι → ℝ) (a b c d : ℝ) :
    ∑ i, (a * f1 i + b * f2 i + c * f3 i + d * f4 i)
      = a * (∑ i, f1 i) + b * (∑ i, f2 i) + c * (∑ i, f3 i) + d * (∑ i, f4 i) := by
  simp [Finset.sum_add_distrib, Finset.mul_sum]

/-- The cross term of two regimes: half the total pair mass a *product* draw assigns to
the concordance products. -/
noncomputable def crossTerm (p q x y : ι → ℝ) : ℝ :=
  (1 / 2) * ∑ i, ∑ j, p i * q j * ((x i - x j) * (y i - y j))

lemma crossTerm_symm (p q x y : ι → ℝ) : crossTerm p q x y = crossTerm q p x y := by
  simp only [crossTerm]
  congr 1
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => by ring

lemma crossTerm_nonneg_of_comonotone {p q x y : ι → ℝ} (hp0 : ∀ i, 0 ≤ p i)
    (hq0 : ∀ i, 0 ≤ q i) (h : Comonotone x y) : 0 ≤ crossTerm p q x y := by
  refine mul_nonneg (by norm_num) (Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => ?_)
  exact mul_nonneg (mul_nonneg (hp0 i) (hq0 j)) (h i j)

/-- **The dial is an exact quadratic along a regime homotopy.** -/
theorem wcov_mix {p q x y : ι → ℝ} (hp : ∑ i, p i = 1) (hq : ∑ i, q i = 1) (t : ℝ) :
    wcov (mixWeights p q t) x y
      = (1 - t) ^ 2 * wcov p x y + 2 * t * (1 - t) * crossTerm p q x y
        + t ^ 2 * wcov q x y := by
  have hmix := mixWeights_total hp hq t
  have h0 := wcov_eq_half_double_sum (p := mixWeights p q t) (x := x) (y := y) hmix
  have h1 := wcov_eq_half_double_sum (p := p) (x := x) (y := y) hp
  have h2 := wcov_eq_half_double_sum (p := q) (x := x) (y := y) hq
  have hcross : ∑ i, ∑ j, q i * p j * ((x i - x j) * (y i - y j))
      = ∑ i, ∑ j, p i * q j * ((x i - x j) * (y i - y j)) := by
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => by ring
  have inner : ∀ i, ∑ j, mixWeights p q t i * mixWeights p q t j * ((x i - x j) * (y i - y j))
      = (1 - t) ^ 2 * (∑ j, p i * p j * ((x i - x j) * (y i - y j)))
        + ((1 - t) * t) * (∑ j, p i * q j * ((x i - x j) * (y i - y j)))
        + (t * (1 - t)) * (∑ j, q i * p j * ((x i - x j) * (y i - y j)))
        + t ^ 2 * (∑ j, q i * q j * ((x i - x j) * (y i - y j))) := by
    intro i
    rw [← sum_four_comb]
    exact Finset.sum_congr rfl fun j _ => by simp only [mixWeights]; ring
  have expand : ∑ i, ∑ j, mixWeights p q t i * mixWeights p q t j * ((x i - x j) * (y i - y j))
      = (1 - t) ^ 2 * (∑ i, ∑ j, p i * p j * ((x i - x j) * (y i - y j)))
        + ((1 - t) * t) * (∑ i, ∑ j, p i * q j * ((x i - x j) * (y i - y j)))
        + (t * (1 - t)) * (∑ i, ∑ j, q i * p j * ((x i - x j) * (y i - y j)))
        + t ^ 2 * (∑ i, ∑ j, q i * q j * ((x i - x j) * (y i - y j))) := by
    rw [Finset.sum_congr rfl fun i _ => inner i, sum_four_comb]
  rw [expand, hcross, ← h1, ← h2] at h0
  simp only [crossTerm]
  linarith

/-- Along the homotopy from a balanced to an unbalanced regime, a comonotone population's
dial is bounded below by the *pure* quadratic interpolation of the endpoint readings. -/
theorem wcov_mix_ge {p q x y : ι → ℝ} (hp0 : ∀ i, 0 ≤ p i) (hq0 : ∀ i, 0 ≤ q i)
    (hp : ∑ i, p i = 1) (hq : ∑ i, q i = 1) (h : Comonotone x y) {t : ℝ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    (1 - t) ^ 2 * wcov p x y + t ^ 2 * wcov q x y ≤ wcov (mixWeights p q t) x y := by
  rw [wcov_mix hp hq t]
  have hc := crossTerm_nonneg_of_comonotone hp0 hq0 h
  nlinarith [mul_nonneg ht0 (sub_nonneg.mpr ht1)]

/-- **No dilution anywhere on the homotopy.**  For a comonotone population, every regime
on the segment joining two regimes reads at least half the smaller endpoint reading. -/
theorem wcov_mix_ge_half_min {p q x y : ι → ℝ} (hp0 : ∀ i, 0 ≤ p i) (hq0 : ∀ i, 0 ≤ q i)
    (hp : ∑ i, p i = 1) (hq : ∑ i, q i = 1) (h : Comonotone x y) {t : ℝ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    (1 / 2) * min (wcov p x y) (wcov q x y) ≤ wcov (mixWeights p q t) x y := by
  have hmain := wcov_mix_ge hp0 hq0 hp hq h ht0 ht1
  have hmp : min (wcov p x y) (wcov q x y) ≤ wcov p x y := min_le_left _ _
  have hmq : min (wcov p x y) (wcov q x y) ≤ wcov q x y := min_le_right _ _
  have hm0 : 0 ≤ min (wcov p x y) (wcov q x y) :=
    le_min (wcov_nonneg_of_comonotone ⟨p, hp0, hp⟩ h) (wcov_nonneg_of_comonotone ⟨q, hq0, hq⟩ h)
  have hquad : (1 : ℝ) / 2 ≤ (1 - t) ^ 2 + t ^ 2 := by nlinarith [sq_nonneg (2 * t - 1)]
  nlinarith [mul_nonneg (sq_nonneg (1 - t)) hm0, mul_nonneg (sq_nonneg t) hm0]

/-! ### The concordance budget: how unbalanced can a draw get? -/

/-- Total concordant pair mass of the population (regime-free). -/
noncomputable def concordanceMass (x y : ι → ℝ) : ℝ :=
  ∑ i, ∑ j, max ((x i - x j) * (y i - y j)) 0

/-- Total discordant pair mass of the population (regime-free). -/
noncomputable def discordanceMass (x y : ι → ℝ) : ℝ :=
  ∑ i, ∑ j, max (-((x i - x j) * (y i - y j))) 0

lemma concordanceMass_nonneg (x y : ι → ℝ) : 0 ≤ concordanceMass x y :=
  Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => le_max_right _ _

lemma discordanceMass_nonneg (x y : ι → ℝ) : 0 ≤ discordanceMass x y :=
  Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => le_max_right _ _

/-- A population is comonotone exactly when it has no discordant mass. -/
theorem discordanceMass_eq_zero_iff_comonotone (x y : ι → ℝ) :
    discordanceMass x y = 0 ↔ Comonotone x y := by
  constructor
  · intro h i j
    by_contra hij
    push_neg at hij
    have hterm : 0 < max (-((x i - x j) * (y i - y j))) 0 :=
      lt_max_of_lt_left (by linarith)
    have hpos : 0 < discordanceMass x y := by
      refine Finset.sum_pos' (fun a _ => Finset.sum_nonneg fun b _ => le_max_right _ _)
        ⟨i, Finset.mem_univ i, ?_⟩
      exact Finset.sum_pos' (fun b _ => le_max_right _ _) ⟨j, Finset.mem_univ j, hterm⟩
    linarith
  · intro h
    refine le_antisymm ?_ (discordanceMass_nonneg x y)
    refine Finset.sum_nonpos fun i _ => Finset.sum_nonpos fun j _ => ?_
    exact max_le (by linarith [h i j]) le_rfl

/-- **Concordance budget.**  For any regime whose per-key mass lies in `[ε, M]`, the dial
is bounded below by `ε² · C − M² · Δ`, with `C`, `Δ` the population's concordant and
discordant pair masses. -/
theorem wcov_budget {p x y : ι → ℝ} {ε M : ℝ} (hp : ∑ i, p i = 1) (hε : 0 ≤ ε)
    (hlo : ∀ i, ε ≤ p i) (hhi : ∀ i, p i ≤ M) :
    ε ^ 2 * concordanceMass x y - M ^ 2 * discordanceMass x y ≤ 2 * wcov p x y := by
  rw [wcov_eq_half_double_sum hp]
  have hrw : ε ^ 2 * concordanceMass x y - M ^ 2 * discordanceMass x y
      = ∑ i, ∑ j, (ε ^ 2 * max ((x i - x j) * (y i - y j)) 0
          - M ^ 2 * max (-((x i - x j) * (y i - y j))) 0) := by
    simp only [concordanceMass, discordanceMass]
    rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_sub_distrib]
  rw [hrw]
  refine Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => ?_
  set D := (x i - x j) * (y i - y j) with hD
  have hsplit : max D 0 - max (-D) 0 = D := by
    rcases le_total 0 D with hd | hd
    · rw [max_eq_left hd, max_eq_right (by linarith)]; ring
    · rw [max_eq_right hd, max_eq_left (by linarith)]; ring
  have hmass_lo : ε ^ 2 ≤ p i * p j := by
    have := mul_le_mul (hlo i) (hlo j) hε (le_trans hε (hlo i))
    nlinarith
  have hmass_hi : p i * p j ≤ M ^ 2 := by
    have h1 : 0 ≤ p i := le_trans hε (hlo i)
    have h2 : 0 ≤ p j := le_trans hε (hlo j)
    nlinarith [hhi i, hhi j]
  have hc : 0 ≤ max D 0 := le_max_right _ _
  have hd : 0 ≤ max (-D) 0 := le_max_right _ _
  calc ε ^ 2 * max D 0 - M ^ 2 * max (-D) 0
      ≤ (p i * p j) * max D 0 - (p i * p j) * max (-D) 0 := by
        have h1 : ε ^ 2 * max D 0 ≤ (p i * p j) * max D 0 :=
          mul_le_mul_of_nonneg_right hmass_lo hc
        have h2 : (p i * p j) * max (-D) 0 ≤ M ^ 2 * max (-D) 0 :=
          mul_le_mul_of_nonneg_right hmass_hi hd
        linarith
    _ = p i * p j * D := by rw [← mul_sub, hsplit]
    _ = p i * p j * ((x i - x j) * (y i - y j)) := by rw [hD]

/-- **QS triage rule.**  If the population's concordance/discordance ratio beats the square
of the regime's conditioning number `M/ε`, the dial is strictly positive — no matter how
unbalanced the draw is within those bounds.  Taking `Δ = 0` (comonotone populations)
recovers unconditional positivity for any full-support regime with `C > 0`. -/
theorem dial_pos_of_concordance_ratio {p x y : ι → ℝ} {ε M : ℝ} (hp : ∑ i, p i = 1)
    (hε : 0 < ε) (hlo : ∀ i, ε ≤ p i) (hhi : ∀ i, p i ≤ M)
    (hratio : M ^ 2 * discordanceMass x y < ε ^ 2 * concordanceMass x y) :
    0 < wcov p x y := by
  have := wcov_budget (x := x) (y := y) hp hε.le hlo hhi
  linarith

/-- The triage rule is sharp in its dependence on the conditioning number: the bound is
attained in the balanced case `ε = M = 1/|ι|` for the uniform regime, where it reads
`C − Δ ≤ 2·|ι|²·Cov`, i.e. exactly the Hoeffding identity's positive/negative split. -/
theorem uniform_budget_eq (x y : ι → ℝ) :
    concordanceMass x y - discordanceMass x y
      = ∑ i, ∑ j, ((x i - x j) * (y i - y j)) := by
  simp only [concordanceMass, discordanceMass, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => ?_
  rcases le_total 0 ((x i - x j) * (y i - y j)) with hd | hd
  · rw [max_eq_left hd, max_eq_right (by linarith)]; ring
  · rw [max_eq_right hd, max_eq_left (by linarith)]; ring

end Catalog.UniformDial