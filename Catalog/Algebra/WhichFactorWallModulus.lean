/-
# The which-factor wall, cycle III: the exact two-sided modulus, and a replication tolerance

Cycle I refuted the linear inversion conjecture and gave the guarded linear
bound; cycle II gave the unconditional square-root inversion law.  Both bound
the *imbalance* by the *wall gap*.  This file closes the loop with the opposite
direction — how much can the wall move when the split moves? — and combines the
two into a single two-sided modulus of continuity for the wall as a function of
the split.

* `binEntropy_add_le` — subadditivity `binEntropy (q + d) ≤ binEntropy q + binEntropy d`
  on `[0,1]`, proved by antitonicity of the shifted difference
  `x ↦ binEntropy (x + d) - binEntropy x` (the discrete mean value comparison).
* `binEntropy_sub_le_binEntropy_abs_sub` — the **sharp Fannes-type continuity
  bound** on the balanced side: `|binEntropy p - binEntropy q| ≤ binEntropy |p - q|`.
  It is attained (`binEntropy_modulus_attained`), so no smaller modulus works.
* `wall_modulus_two_sided` — the complete law on `[0, 1/2]`:
  `2 |p - q|² ≤ |wall p - wall q| ≤ binEntropy |p - q|`.
  Both sides are sharp.  In particular the wall map is a bi-Hölder
  homeomorphism of `[0, 1/2]` onto `[0, log 2]`, with exponent `2` on one side
  and modulus `t log(1/t)` on the other.
* `binary_wall_replication_robust` — the replication statement the battery
  actually needs: two populations whose splits differ by at most `δ` report
  walls differing by at most `binEntropy δ`.
* `wall_replication_tolerance` — a numeric consequence for the reported wall
  `0.4677` bits: for splits of at most `1/9`, a replication whose wall agrees to
  `0.01` bits pins the split to within `1/300 ≈ 0.33` percentage points.
-/
import Algebra.WhichFactorWallSqrtLaw

namespace WhichFactorWall

open Real Set

/-! ## 1.  Subadditivity of the binary entropy -/

private lemma hasDerivAt_binEntropy_shift {d x : ℝ} (h0 : x + d ≠ 0) (h1 : x + d ≠ 1)
    (hx0 : x ≠ 0) (hx1 : x ≠ 1) :
    HasDerivAt (fun z : ℝ => binEntropy (z + d) - binEntropy z)
      ((log (1 - (x + d)) - log (x + d)) - (log (1 - x) - log x)) x := by
  have hc : HasDerivAt (fun z : ℝ => z + d) 1 x := (hasDerivAt_id x).add_const d
  have h2 : HasDerivAt (fun z : ℝ => binEntropy (z + d)) (log (1 - (x + d)) - log (x + d)) x := by
    simpa using (Real.hasDerivAt_binEntropy h0 h1).comp x hc
  exact h2.sub (Real.hasDerivAt_binEntropy hx0 hx1)

/-- **Subadditivity of the binary entropy.**  The information carried by a split of
size `q + d` is at most that of a split of size `q` plus that of a split of size
`d`.  Proof: `x ↦ binEntropy (x + d) - binEntropy x` is antitone, because
`binEntropy'` is decreasing; evaluate at `x = q` against `x = 0`. -/
theorem binEntropy_add_le {q d : ℝ} (hq : 0 ≤ q) (hd : 0 ≤ d) (hqd : q + d ≤ 1) :
    binEntropy (q + d) ≤ binEntropy q + binEntropy d := by
  rcases eq_or_lt_of_le hd with hd0 | hd0
  · simp [← hd0]
  rcases eq_or_lt_of_le hq with hq0 | hq0
  · simp [← hq0]
  have hanti : AntitoneOn (fun z : ℝ => binEntropy (z + d) - binEntropy z) (Icc 0 q) := by
    apply antitoneOn_of_deriv_nonpos (convex_Icc 0 q)
    · exact ((Real.binEntropy_continuous.comp (continuous_id.add continuous_const)).sub
        Real.binEntropy_continuous).continuousOn
    · rw [interior_Icc]
      intro x hx
      simp only [mem_Ioo] at hx
      exact (hasDerivAt_binEntropy_shift (by intro h; linarith) (by intro h; linarith)
        (by intro h; rw [h] at hx; linarith [hx.1])
        (by intro h; rw [h] at hx; linarith [hx.2])).differentiableAt.differentiableWithinAt
    · rw [interior_Icc]
      intro x hx
      simp only [mem_Ioo] at hx
      rw [(hasDerivAt_binEntropy_shift (by intro h; linarith) (by intro h; linarith)
        (by intro h; rw [h] at hx; linarith [hx.1])
        (by intro h; rw [h] at hx; linarith [hx.2])).deriv]
      have hl1 : log (1 - (x + d)) ≤ log (1 - x) :=
        Real.log_le_log (by linarith [hx.2]) (by linarith)
      have hl2 : log x ≤ log (x + d) := Real.log_le_log hx.1 (by linarith)
      linarith
  have h := hanti (left_mem_Icc.2 hq) (right_mem_Icc.2 hq) hq
  simp only [zero_add, Real.binEntropy_zero] at h
  linarith

/-! ## 2.  The sharp modulus of continuity of the wall -/

/-- **Sharp Fannes-type continuity bound.**  On the balanced side the wall gap is at
most the binary entropy of the imbalance gap.  Since `binEntropy t ~ t log (1/t)`,
this is a strictly sub-Lipschitz modulus: the wall is *more* sensitive than
Lipschitz near a pure split. -/
theorem binEntropy_sub_le_binEntropy_abs_sub {p q : ℝ} (hp : p ∈ Icc (0 : ℝ) 2⁻¹)
    (hq : q ∈ Icc (0 : ℝ) 2⁻¹) : |binEntropy p - binEntropy q| ≤ binEntropy |p - q| := by
  have key : ∀ a b : ℝ, a ∈ Icc (0 : ℝ) 2⁻¹ → b ∈ Icc (0 : ℝ) 2⁻¹ → a ≤ b →
      |binEntropy a - binEntropy b| ≤ binEntropy |a - b| := by
    intro a b ha hb hab
    have hsub := binEntropy_add_le (q := a) (d := b - a) ha.1 (by linarith) (by linarith [hb.2])
    rw [show a + (b - a) = b by ring] at hsub
    have hmono : binEntropy a ≤ binEntropy b :=
      Real.binEntropy_strictMonoOn.monotoneOn ha hb hab
    rw [abs_of_nonpos (by linarith), abs_of_nonpos (by linarith : a - b ≤ 0),
      show -(a - b) = b - a by ring]
    linarith
  rcases le_total p q with h | h
  · exact key p q hp hq h
  · rw [abs_sub_comm, abs_sub_comm p q]; exact key q p hq hp h

/-- The modulus of `binEntropy_sub_le_binEntropy_abs_sub` is attained at `q = 0`, so it
cannot be replaced by any smaller function of `|p - q|`. -/
theorem binEntropy_modulus_attained {p : ℝ} (hp : p ∈ Icc (0 : ℝ) 2⁻¹) :
    |binEntropy p - binEntropy 0| = binEntropy |p - 0| := by
  rw [Real.binEntropy_zero, sub_zero, sub_zero, abs_of_nonneg hp.1,
    abs_of_nonneg (Real.binEntropy_nonneg hp.1 (by linarith [hp.2]))]

/-- **The complete two-sided wall law on the balanced side.**
`2 |p - q|² ≤ |wall p - wall q| ≤ binEntropy |p - q|`.
The left inequality inverts the wall (cycle II, sharp by `sqrt_law_sharp`); the
right inequality makes the wall a stable report (sharp by
`binEntropy_modulus_attained`). -/
theorem wall_modulus_two_sided {p q : ℝ} (hp : p ∈ Icc (0 : ℝ) 2⁻¹) (hq : q ∈ Icc (0 : ℝ) 2⁻¹) :
    2 * (p - q) ^ 2 ≤ |binEntropy p - binEntropy q| ∧
      |binEntropy p - binEntropy q| ≤ binEntropy |p - q| :=
  ⟨two_mul_sq_le_abs_binEntropy_sub hp hq, binEntropy_sub_le_binEntropy_abs_sub hp hq⟩

/-! ## 3.  Replication statements for the battery -/

/-- **Replication robustness of the wall.**  Two binary statistics on two different
finite populations whose class imbalances differ by at most `δ ≤ 1/2` report
walls differing by at most `binEntropy δ`.  Together with
`binary_wall_sqrt_stability` this says the wall and the split determine each
other, quantitatively, in both directions. -/
theorem binary_wall_replication_robust {Ω₁ Ω₂ : Type*} [Fintype Ω₁] [Nonempty Ω₁] [Fintype Ω₂]
    [Nonempty Ω₂] {α₁ α₂ : Type*} [DecidableEq α₁] [DecidableEq α₂]
    (f : Ω₁ → α₁) (g : Ω₂ → α₂) {a b : α₁} {c e : α₂} {δ : ℝ}
    (hab : a ≠ b) (hce : c ≠ e) (hf : img f = {a, b}) (hg : img g = {c, e})
    (hpf : (cnt f a : ℝ) / (Fintype.card Ω₁ : ℝ) ∈ Icc (0 : ℝ) 2⁻¹)
    (hpg : (cnt g c : ℝ) / (Fintype.card Ω₂ : ℝ) ∈ Icc (0 : ℝ) 2⁻¹)
    (hδ : |(cnt f a : ℝ) / (Fintype.card Ω₁ : ℝ) - (cnt g c : ℝ) / (Fintype.card Ω₂ : ℝ)| ≤ δ)
    (hδ2 : δ ≤ 2⁻¹) :
    |H f - H g| ≤ binEntropy δ := by
  have h1 := H_two_values f hab hf
  have h2 := H_two_values g hce hg
  rw [h1, h2]
  refine le_trans (binEntropy_sub_le_binEntropy_abs_sub hpf hpg) ?_
  exact Real.binEntropy_strictMonoOn.monotoneOn ⟨abs_nonneg _, le_trans hδ hδ2⟩
    ⟨le_trans (abs_nonneg _) hδ, hδ2⟩ hδ

/-- **A concrete replication tolerance for the reported wall.**  The round-30 wall
`0.4677` bits corresponds to a split below `1/9` (`wall_imbalance_bracket`).  In
that regime a replication whose wall agrees to `0.01` bits pins the split to
within `1/300`, i.e. a third of a percentage point.  The constant is exactly
`log 8 = 3 log 2` nats per unit of imbalance. -/
theorem wall_replication_tolerance {p q : ℝ} (hp : p ∈ Icc (0 : ℝ) (1/9))
    (hq : q ∈ Icc (0 : ℝ) (1/9)) (h : |binEntropy p - binEntropy q| ≤ 0.01 * log 2) :
    |p - q| ≤ 1 / 300 := by
  have hmem : ∀ r : ℝ, r ∈ Icc (0 : ℝ) (1/9) → r ∈ Icc (0 : ℝ) (2⁻¹ - 7/18) := by
    intro r hr
    exact ⟨hr.1, by norm_num at hr ⊢; linarith [hr.2]⟩
  have hkey := imbalance_dist_le (η := 7/18) (p := p) (q := q) (by norm_num) (by norm_num)
    (hmem p hp) (hmem q hq)
  have hc : log ((2 : ℝ)⁻¹ + 7/18) - log (2⁻¹ - 7/18) = 3 * log 2 := by
    rw [show (2 : ℝ)⁻¹ + 7/18 = 8/9 by norm_num, show (2 : ℝ)⁻¹ - 7/18 = 1/9 by norm_num,
      Real.log_div (by norm_num) (by norm_num), Real.log_div (by norm_num) (by norm_num),
      show (8 : ℝ) = 2 ^ 3 by norm_num, Real.log_pow, Real.log_one]
    ring
  rw [hc] at hkey
  have hlog2 : 0 < log 2 := Real.log_pos (by norm_num)
  nlinarith [hkey, h, hlog2, abs_nonneg (p - q)]

end WhichFactorWall