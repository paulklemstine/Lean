import Mathlib
import Combinatorics.KneeInvariance
import Probability.NET64GridArtifact

/-!
# NET-64, cycle 2: how cheap can an honest budget sweep be?

`Probability/NET64GridArtifact.lean` shows that a sweep reports the *ceiling of
the true knee in its grid*, so the only question a sweep designer can control is
how badly that ceiling can distort the knee.  This file answers the design
question exactly, and then asks what the completed `{16, 20, 24}` chain claims.

* `gridKnee_ratioGrid_lt_mul` — **upper bound**: on the geometric grid
  `{1, r, r², …}` (`r ≥ 2`) the reported knee is always `< r · k*`.  A ratio-`r`
  sweep localises the knee to a factor `r`, whatever the model, corpus or gate.
  The doubling case `r = 2` is `gridKnee_dyadic_lt_two_mul`, which bounds the
  measured `24 ↦ 32` inflation.
* `ratioGrid_upto_covers` — that guarantee is already achieved by the *finite*
  geometric grid `{r^0, …, r^s}`, of size `s + 1`, on the whole budget range
  `[1, r^s]`.
* `grid_card_lower_bound` — **matching lower bound**, and the main theorem of
  this file: *any* grid `G` (geometric or not) that localises every knee in
  `[1, N]` to a factor `r` must satisfy `N < (r+1)^{|G|}`.  So
  `|G| ≥ log_{r+1} N` sweep points are necessary: geometric grids are optimal up
  to the base of the logarithm, and a coarse sweep that saves points *must* pay
  in knee inflation.  The proof is a disjoint-interval packing argument: the
  covering intervals `[r^i, r·r^i]` around the test budgets `(r+1)^i` are
  pairwise disjoint, so each consumes a distinct grid point.
* `grid_too_small_has_blind_budget` — the contrapositive, in experimental terms:
  a grid smaller than `log_{r+1} N` provably has a budget it cannot localise.
* `logLaw_prediction_2048`, `logLaw_slope_unique` — the completed chain, read as
  a *pre-registered prediction*: the two cells `512 ↦ 16` and `1024 ↦ 20`
  determine every affine-in-`log₂` law, and the unique such law predicts exactly
  the value `24` later measured at `ctx = 2048`.  The third cell was a test, not
  a fit — and any competing slope is refuted by it (`logLaw_refutes_slope`).
-/

namespace Catalog.Probability.NET64GridDesign

open Finset Combinatorics.KneeInvariance Catalog.Probability.NET64GridArtifact

/-! ## 1. Geometric grids: the achievable localisation factor -/

/-- The geometric grid `{1, r, r², …}` of a ratio-`r` sweep. -/
def ratioGrid (r : ℕ) : Set ℕ := Set.range fun j : ℕ => r ^ j

theorem dyadicGrid_eq_ratioGrid : dyadicGrid = ratioGrid 2 := rfl

variable {A : ℕ → ℚ} {g : ℚ}

/-- **Localisation guarantee of a ratio-`r` sweep.**  The reported knee is always
strictly below `r` times the true knee. -/
theorem gridKnee_ratioGrid_lt_mul {r : ℕ} (hr : 2 ≤ r) (hA : Monotone A)
    (hne : ∃ m, g ≤ A m) (hpos : 0 < knee A g) :
    gridKnee (ratioGrid r) A g < r * knee A g := by
  have hr1 : 1 < r := hr
  set k := knee A g with hk
  have hcov : k ≤ r ^ Nat.clog r k := Nat.le_pow_clog hr1 k
  have hgrid : r ^ Nat.clog r k ∈ ratioGrid r := ⟨Nat.clog r k, rfl⟩
  have hval : g ≤ A (r ^ Nat.clog r k) :=
    le_trans (Combinatorics.KneeInvariance.knee_mem hne) (hA hcov)
  have hle : gridKnee (ratioGrid r) A g ≤ r ^ Nat.clog r k := gridKnee_le hgrid hval
  have hlt : r ^ Nat.clog r k < r * k := by
    have hk1 : 1 ≤ k := hpos
    rcases eq_or_lt_of_le hk1 with h1 | h1
    · rw [← h1, Nat.clog_one_right]
      simpa using hr1
    · have hc : 0 < Nat.clog r k := Nat.clog_pos hr1 h1
      have hstep : r ^ (Nat.clog r k - 1) < k := Nat.pow_pred_clog_lt_self hr1 h1
      have hsplit : r ^ Nat.clog r k = r * r ^ (Nat.clog r k - 1) := by
        rw [← pow_succ']
        congr 1
        omega
      calc r ^ Nat.clog r k = r * r ^ (Nat.clog r k - 1) := hsplit
        _ < r * k := mul_lt_mul_of_pos_left hstep (by omega)
  exact lt_of_le_of_lt hle hlt

/-- The finite truncation `{r^0, …, r^s}` of a geometric grid already localises
every budget in `[1, r^s]` to a factor `r`. -/
theorem ratioGrid_upto_covers {r s : ℕ} (hr : 2 ≤ r) {c : ℕ} (hc : 1 ≤ c) (hcN : c ≤ r ^ s) :
    ∃ j ≤ s, c ≤ r ^ j ∧ r ^ j ≤ r * c := by
  refine ⟨Nat.clog r c, ?_, Nat.le_pow_clog hr c, ?_⟩
  · exact (Nat.clog_mono_right r hcN).trans_eq (Nat.clog_pow r s hr)
  · rcases eq_or_lt_of_le hc with h1 | h1
    · rw [← h1, Nat.clog_one_right]
      simp
      omega
    · have hstep : r ^ (Nat.clog r c - 1) < c := Nat.pow_pred_clog_lt_self hr h1
      have hc0 : 0 < Nat.clog r c := Nat.clog_pos hr h1
      have hsplit : r ^ Nat.clog r c = r * r ^ (Nat.clog r c - 1) := by
        rw [← pow_succ']
        congr 1
        omega
      rw [hsplit]
      exact Nat.mul_le_mul_left r (by omega)

/-! ## 2. The sweep-cost lower bound -/

/-- **Optimality of geometric sweeps.**  If a grid `G` localises every budget in
`[1, N]` to a factor `r` — i.e. every `c ≤ N` has a grid point in `[c, r·c]`,
which by the factorisation theorem is exactly what it means for the sweep to
report every knee up to a factor `r` — then `N < (r+1)^{|G|}`.  Equivalently
`|G| ≥ log_{r+1} N`: no clever placement beats the geometric grid by more than
the base of the logarithm.

The proof packs the disjoint intervals `[(r+1)^i, r·(r+1)^i]`, `i = 0, …, |G|`,
each of which must contain its own grid point. -/
theorem grid_card_lower_bound {G : Finset ℕ} {r N : ℕ} (hr : 1 ≤ r)
    (hcover : ∀ c, 1 ≤ c → c ≤ N → ∃ gp ∈ G, c ≤ gp ∧ gp ≤ r * c) :
    N < (r + 1) ^ G.card := by
  classical
  by_contra hN
  push_neg at hN
  set s := G.card with hs
  set T : ℕ → Finset ℕ :=
    fun i => G.filter (fun gp => (r + 1) ^ i ≤ gp ∧ gp ≤ r * (r + 1) ^ i) with hT
  have hpow_pos : ∀ i : ℕ, 1 ≤ (r + 1) ^ i := fun i => Nat.one_le_pow _ _ (by omega)
  have hne : ∀ i ≤ s, (T i).Nonempty := by
    intro i hi
    have hle : (r + 1) ^ i ≤ N :=
      le_trans (Nat.pow_le_pow_right (by omega) hi) hN
    obtain ⟨gp, hgpG, h1, h2⟩ := hcover ((r + 1) ^ i) (hpow_pos i) hle
    exact ⟨gp, Finset.mem_filter.mpr ⟨hgpG, h1, h2⟩⟩
  have hdisj : ((range (s + 1) : Finset ℕ) : Set ℕ).PairwiseDisjoint T := by
    have key : ∀ i j : ℕ, i < j → Disjoint (T i) (T j) := by
      intro i j hij
      refine Finset.disjoint_left.mpr ?_
      intro gp hgi hgj
      obtain ⟨-, -, hup⟩ := Finset.mem_filter.mp hgi
      obtain ⟨-, hlow, -⟩ := Finset.mem_filter.mp hgj
      have hstep : r * (r + 1) ^ i < (r + 1) ^ (i + 1) := by
        have h1 : (r + 1) ^ (i + 1) = (r + 1) * (r + 1) ^ i := by ring
        have h2 : 1 ≤ (r + 1) ^ i := hpow_pos i
        nlinarith [h1, h2]
      have hmono : (r + 1) ^ (i + 1) ≤ (r + 1) ^ j :=
        Nat.pow_le_pow_right (by omega) (by omega)
      omega
    intro i _ j _ hij
    simp only [Function.onFun]
    rcases lt_or_gt_of_ne hij with h | h
    · exact key i j h
    · exact (key j i h).symm
  have hsub : (range (s + 1)).biUnion T ⊆ G := by
    intro x hx
    obtain ⟨i, -, hxi⟩ := Finset.mem_biUnion.mp hx
    exact (Finset.mem_filter.mp hxi).1
  have hcard : s + 1 ≤ ((range (s + 1)).biUnion T).card := by
    rw [Finset.card_biUnion hdisj]
    calc s + 1 = ∑ _i ∈ range (s + 1), 1 := by simp
      _ ≤ ∑ i ∈ range (s + 1), (T i).card := by
          refine Finset.sum_le_sum ?_
          intro i hi
          exact Finset.card_pos.mpr (hne i (by simpa using Nat.lt_succ_iff.mp (mem_range.mp hi)))
  have hle := Finset.card_le_card hsub
  omega

/-- **A small grid is provably blind.**  Restated for the experimenter: if the
number of sampled budgets is below `log_{r+1} N`, some budget in `[1, N]` has no
grid point within a factor `r` of it — the sweep cannot localise that knee. -/
theorem grid_too_small_has_blind_budget {G : Finset ℕ} {r N : ℕ} (hr : 1 ≤ r)
    (hsmall : (r + 1) ^ G.card ≤ N) :
    ∃ c, 1 ≤ c ∧ c ≤ N ∧ ∀ gp ∈ G, ¬(c ≤ gp ∧ gp ≤ r * c) := by
  by_contra hcon
  push_neg at hcon
  refine absurd (grid_card_lower_bound (G := G) (r := r) (N := N) hr ?_) (by omega)
  intro c hc1 hcN
  obtain ⟨gp, hgp, h1, h2⟩ := hcon c hc1 hcN
  exact ⟨gp, hgp, h1, h2⟩

/-- The NET-64 coarse sweep, sized.  No four-point grid whatsoever — doubling or
not — can localise every budget up to `81` within a factor `2`; four points buy
at most the range `[1, 80]`. -/
theorem net64_coarse_sweep_capacity :
    ¬ ∃ G : Finset ℕ, G.card = 4 ∧
        ∀ c, 1 ≤ c → c ≤ 81 → ∃ gp ∈ G, c ≤ gp ∧ gp ≤ 2 * c := by
  rintro ⟨G, hcard, hcover⟩
  have hlt := grid_card_lower_bound (G := G) (r := 2) (N := 81) (by norm_num) hcover
  rw [hcard] at hlt
  norm_num at hlt

/-! ## 3. The completed chain as a pre-registered prediction -/

/-- **The third cell was a prediction, not a fit.**  Any law affine in `log₂ ctx`
that matches the two earlier cells (`512 ↦ 16`, `1024 ↦ 20`) is forced to predict
`24` at `ctx = 2048` — which is what the NET-64 sweep then measured, on both
corpora. -/
theorem logLaw_prediction_2048 (a b : ℚ) (h512 : a * 9 + b = 16) (h1024 : a * 10 + b = 20) :
    a * 11 + b = 24 := by linarith

/-- The two earlier cells already pin the slope to `4` keys per doubling and the
intercept to `-20`. -/
theorem logLaw_slope_unique (a b : ℚ) (h512 : a * 9 + b = 16) (h1024 : a * 10 + b = 20) :
    a = 4 ∧ b = -20 := by
  constructor <;> linarith

/-- **And the prediction is falsifiable.**  Any competing slope `a ≠ 4` that still
matches `ctx = 512` predicts a value at `ctx = 2048` different from the measured
`24`; the measurement therefore discriminates. -/
theorem logLaw_refutes_slope (a b : ℚ) (h512 : a * 9 + b = 16) (ha : a ≠ 4) :
    a * 11 + b ≠ 24 := by
  intro h
  apply ha
  linarith

end Catalog.Probability.NET64GridDesign