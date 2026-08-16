import Physics.WrongTheories.MetaTheorem

/-!
# The wrongness hierarchy: knowingly wrong theories converge to the truth

`Physics.WrongTheories.MetaTheorem` shows that an approximately correct theory
beats any imperfect competitor in a window of couplings.  This file analyses the
*internal* structure of wrongness: the tower of finite-order truncations

`truncate T 0 ε , truncate T 1 ε , truncate T 2 ε , …`

each of which is a theory that is *knowingly wrong* (it discards infinitely many
corrections), and shows that this tower is strictly ordered by empirical
adequacy in the small-coupling regime.

Main results:

* `WrongTheory.tail_succ` — the exact recursion `tail N = term N + tail (N+1)`;
* `WrongTheory.abs_tail_le_two` and `WrongTheory.abs_tail_ge` — matching upper
  and lower geometric estimates for the truncation error;
* `WrongTheory.truncation_err_eq` — the error of the `N`-th truncation with
  respect to the exact prediction is exactly the `N`-th tail;
* `WrongTheory.higher_order_eventually_better` — **the wrongness hierarchy
  theorem**: whenever the `M`-th correction is nonzero, every higher truncation
  `N > M` strictly outpredicts the `M`-th one throughout a punctured window of
  couplings.  Thus the wrongness of an approximately correct theory forms a
  convergent series whose partial sums approach the truth *monotonically in
  order*, not merely in the limit;
* `WrongTheory.truncation_tower_strictly_better` — the induced strict chain
  along an arbitrary finite stretch of the tower.
-/

namespace WrongTheory

variable {Φ : Type*}

/-- The `N`-th tail of the wrongness series: the part of the truth that the
`N`-th order truncation throws away. -/
noncomputable def tail (T : Perturbative Φ) (ε : ℝ) (p : Φ) (N : ℕ) : ℝ :=
  wrongness T ε p - ∑ n ∈ Finset.range N, wrongTerm T ε p n

/-- The error of the `N`-th order truncation, measured against the exact
prediction `predict T ε`, is exactly the `N`-th tail. -/
theorem truncation_err_eq (T : Perturbative Φ) (ε : ℝ) (p : Φ) (N : ℕ) :
    predErr (truncate T N ε) (predict T ε) p = |tail T ε p N| := by
  have h : truncate T N ε p - predict T ε p = -tail T ε p N := by
    simp [truncate, predict, tail]
  rw [predErr, h, abs_neg]

/-- Exact recursion for the tails. -/
theorem tail_succ (T : Perturbative Φ) (ε : ℝ) (p : Φ) (N : ℕ) :
    tail T ε p N = wrongTerm T ε p N + tail T ε p (N + 1) := by
  simp [tail, Finset.sum_range_succ]
  ring

/-- Upper estimate for the truncation error in the half-disc `ratio * |ε| ≤ 1/2`. -/
theorem abs_tail_le_two (T : Perturbative Φ) (ε : ℝ) (p : Φ) (N : ℕ)
    (h : T.ratio * |ε| ≤ 1 / 2) :
    |tail T ε p N| ≤ 2 * T.bound * T.ratio ^ N * |ε| ^ (N + 1) := by
  rw [tail]
  have hlt : T.ratio * |ε| < 1 := by linarith
  have hmain := abs_tail_le T ε p N hlt
  have hnn : 0 ≤ T.bound * |ε| ^ (N + 1) * T.ratio ^ N :=
    mul_nonneg (mul_nonneg T.bound_nonneg (by positivity)) (pow_nonneg T.ratio_nonneg N)
  have hden : (1 : ℝ) / 2 ≤ 1 - T.ratio * |ε| := by linarith
  have hstep : (T.bound * |ε| ^ (N + 1) * T.ratio ^ N) / (1 - T.ratio * |ε|)
      ≤ (T.bound * |ε| ^ (N + 1) * T.ratio ^ N) / (1 / 2) :=
    div_le_div_of_nonneg_left hnn (by norm_num) hden
  have heq : (T.bound * |ε| ^ (N + 1) * T.ratio ^ N) / (1 / 2)
      = 2 * T.bound * T.ratio ^ N * |ε| ^ (N + 1) := by ring
  linarith [hmain.trans hstep, heq]

/-- Lower estimate: the truncation error is at least the size of the first
discarded term minus the (much smaller) rest. -/
theorem abs_tail_ge (T : Perturbative Φ) (ε : ℝ) (p : Φ) (N : ℕ)
    (h : T.ratio * |ε| ≤ 1 / 2) :
    |T.coeff N p| * |ε| ^ (N + 1) - 2 * T.bound * T.ratio ^ (N + 1) * |ε| ^ (N + 2)
      ≤ |tail T ε p N| := by
  have hterm : |wrongTerm T ε p N| = |T.coeff N p| * |ε| ^ (N + 1) := by
    simp [wrongTerm, abs_mul, abs_pow]
  have hrec := tail_succ T ε p N
  have htri : |wrongTerm T ε p N| ≤ |tail T ε p N| + |tail T ε p (N + 1)| := by
    have : wrongTerm T ε p N = tail T ε p N - tail T ε p (N + 1) := by linarith [hrec]
    calc |wrongTerm T ε p N| = |tail T ε p N - tail T ε p (N + 1)| := by rw [this]
      _ ≤ |tail T ε p N| + |tail T ε p (N + 1)| := abs_sub _ _
  have hupper := abs_tail_le_two T ε p (N + 1) h
  linarith [hterm ▸ htri]

/-- **The wrongness hierarchy theorem.**

Fix a phenomenon `p` at which the `M`-th perturbative correction does not
vanish.  Then for every higher order `N > M` there is a punctured window of
couplings on which the `N`-th order truncation — still a wrong theory, since it
too discards infinitely many corrections — strictly outpredicts the `M`-th order
truncation.

This is the precise sense in which "the wrongness of `T` forms a convergent
series toward truth": not only does the total wrongness tend to zero, but the
approximants are strictly ordered by empirical adequacy. -/
theorem higher_order_eventually_better (T : Perturbative Φ) (p : Φ) {M N : ℕ}
    (hMN : M < N) (hc : T.coeff M p ≠ 0) :
    ∃ δ > 0, ∀ ε : ℝ, 0 < |ε| → |ε| < δ →
      predErr (truncate T N ε) (predict T ε) p
        < predErr (truncate T M ε) (predict T ε) p := by
  set b := T.bound with hb
  set r := T.ratio with hr
  set c := |T.coeff M p| with hcdef
  have hcpos : 0 < c := abs_pos.mpr hc
  have hrpos : 0 < r + 1 := by linarith [T.ratio_nonneg]
  have hDpos : 0 < 2 * b * (r ^ N + r ^ (M + 1)) + 1 := by
    have h1 : 0 ≤ b := T.bound_nonneg
    have h2 : 0 ≤ r ^ N := pow_nonneg T.ratio_nonneg N
    have h3 : 0 ≤ r ^ (M + 1) := pow_nonneg T.ratio_nonneg (M + 1)
    nlinarith
  refine ⟨min (min 1 (1 / (2 * (r + 1)))) (c / (2 * b * (r ^ N + r ^ (M + 1)) + 1)),
    lt_min (lt_min one_pos (by positivity)) (by positivity), ?_⟩
  intro ε hε0 hεδ
  have hx1 : |ε| < 1 := lt_of_lt_of_le hεδ ((min_le_left _ _).trans (min_le_left _ _))
  have hx2 : |ε| < 1 / (2 * (r + 1)) :=
    lt_of_lt_of_le hεδ ((min_le_left _ _).trans (min_le_right _ _))
  have hx3 : |ε| < c / (2 * b * (r ^ N + r ^ (M + 1)) + 1) :=
    lt_of_lt_of_le hεδ (min_le_right _ _)
  -- the coupling lies in the half-disc of convergence
  have hq : r * |ε| ≤ 1 / 2 := by
    have hA : r * |ε| ≤ (r + 1) * |ε| := by nlinarith [T.ratio_nonneg, abs_nonneg ε]
    have hB : (r + 1) * |ε| < (r + 1) * (1 / (2 * (r + 1))) := mul_lt_mul_of_pos_left hx2 hrpos
    have hC : (r + 1) * (1 / (2 * (r + 1))) = 1 / 2 := by field_simp
    linarith
  -- the decisive linear inequality
  have hkey : |ε| * (2 * b * (r ^ N + r ^ (M + 1))) < c := by
    have h1 : |ε| * (2 * b * (r ^ N + r ^ (M + 1)) + 1)
        < (c / (2 * b * (r ^ N + r ^ (M + 1)) + 1)) * (2 * b * (r ^ N + r ^ (M + 1)) + 1) :=
      mul_lt_mul_of_pos_right hx3 hDpos
    have h2 : (c / (2 * b * (r ^ N + r ^ (M + 1)) + 1)) * (2 * b * (r ^ N + r ^ (M + 1)) + 1)
        = c := by field_simp
    nlinarith [abs_nonneg ε]
  rw [truncation_err_eq, truncation_err_eq]
  -- upper bound on the fine truncation, lower bound on the coarse one
  have hupper : |tail T ε p N| ≤ 2 * b * r ^ N * |ε| ^ (N + 1) := abs_tail_le_two T ε p N hq
  have hlower : c * |ε| ^ (M + 1) - 2 * b * r ^ (M + 1) * |ε| ^ (M + 2) ≤ |tail T ε p M| :=
    abs_tail_ge T ε p M hq
  -- compare the two bounds
  have hpow : |ε| ^ (N + 1) ≤ |ε| ^ (M + 2) :=
    pow_le_pow_of_le_one (abs_nonneg ε) (le_of_lt hx1) (by omega)
  have hcoefN : 0 ≤ 2 * b * r ^ N :=
    mul_nonneg (by linarith [T.bound_nonneg]) (pow_nonneg T.ratio_nonneg N)
  have hupper' : |tail T ε p N| ≤ 2 * b * r ^ N * |ε| ^ (M + 2) := by
    refine hupper.trans ?_
    exact mul_le_mul_of_nonneg_left hpow hcoefN
  have hxpow : 0 < |ε| ^ (M + 1) := pow_pos hε0 (M + 1)
  have hsplit : |ε| ^ (M + 2) = |ε| ^ (M + 1) * |ε| := by ring
  have hfinal : 2 * b * r ^ N * |ε| ^ (M + 2)
      < c * |ε| ^ (M + 1) - 2 * b * r ^ (M + 1) * |ε| ^ (M + 2) := by
    rw [hsplit]
    have hmul := mul_lt_mul_of_pos_left hkey hxpow
    nlinarith [hmul]
  linarith

/-- The strict chain along the tower: consecutive truncations improve, on a
common window, as long as the corresponding corrections are nonzero. -/
theorem truncation_tower_strictly_better (T : Perturbative Φ) (p : Φ) (M : ℕ)
    (hc : T.coeff M p ≠ 0) :
    ∃ δ > 0, ∀ ε : ℝ, 0 < |ε| → |ε| < δ →
      predErr (truncate T (M + 1) ε) (predict T ε) p
        < predErr (truncate T M ε) (predict T ε) p :=
  higher_order_eventually_better T p (Nat.lt_succ_self M) hc

/-- A single coupling window that works for all consecutive steps of the tower
up to order `K`. -/
theorem consecutive_window (T : Perturbative Φ) (p : Φ) (K : ℕ)
    (hc : ∀ M < K, T.coeff M p ≠ 0) :
    ∃ δ > 0, ∀ ε : ℝ, 0 < |ε| → |ε| < δ → ∀ M < K,
      predErr (truncate T (M + 1) ε) (predict T ε) p
        < predErr (truncate T M ε) (predict T ε) p := by
  induction K with
  | zero => exact ⟨1, one_pos, fun ε _ _ M hM => absurd hM (Nat.not_lt_zero M)⟩
  | succ K ih =>
      obtain ⟨δ₁, hδ₁, h₁⟩ := ih (fun M hM => hc M (Nat.lt_succ_of_lt hM))
      obtain ⟨δ₂, hδ₂, h₂⟩ :=
        truncation_tower_strictly_better T p K (hc K (Nat.lt_succ_self K))
      refine ⟨min δ₁ δ₂, lt_min hδ₁ hδ₂, fun ε hε0 hεδ M hM => ?_⟩
      rcases Nat.lt_succ_iff_lt_or_eq.1 hM with hM' | rfl
      · exact h₁ ε hε0 (lt_of_lt_of_le hεδ (min_le_left _ _)) M hM'
      · exact h₂ ε hε0 (lt_of_lt_of_le hεδ (min_le_right _ _))

/-- **The tower is a strict chain.**  On one common punctured window of
couplings, the truncations of orders `0, 1, …, K` are *totally* ordered by
empirical adequacy: every higher-order truncation beats every lower-order one.
The wrongness of an approximately correct theory therefore organises itself into
a strictly decreasing hierarchy converging to the exact prediction. -/
theorem truncation_chain (T : Perturbative Φ) (p : Φ) (K : ℕ)
    (hc : ∀ M < K, T.coeff M p ≠ 0) :
    ∃ δ > 0, ∀ ε : ℝ, 0 < |ε| → |ε| < δ → ∀ M N : ℕ, M < N → N ≤ K →
      predErr (truncate T N ε) (predict T ε) p
        < predErr (truncate T M ε) (predict T ε) p := by
  obtain ⟨δ, hδ, hstep⟩ := consecutive_window T p K hc
  refine ⟨δ, hδ, fun ε hε0 hεδ => ?_⟩
  intro M N
  induction N with
  | zero => exact fun hM => absurd hM (Nat.not_lt_zero M)
  | succ N ih =>
      intro hMN hNK
      have hNlt : N < K := lt_of_lt_of_le (Nat.lt_succ_self N) hNK
      have hlast := hstep ε hε0 hεδ N hNlt
      rcases Nat.lt_succ_iff_lt_or_eq.1 hMN with hM' | rfl
      · exact lt_trans hlast (ih hM' (le_of_lt hNlt))
      · exact hlast

end WrongTheory