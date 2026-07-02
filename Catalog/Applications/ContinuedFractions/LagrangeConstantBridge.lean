import Mathlib
import Applications.LagrangeRatioSpectrum.Core
import Applications.ContinuedFractions.DiophantineApproximation

/-!
# Bridging Diophantine approximation and the Lagrange constant

The catalog file `LagrangeRatioSpectrum/Core.lean` defines, for `x : ℝ`,
the approximation function `approx x q = q · ‖q·x‖` (valued in `ℝ≥0∞`) and the
*Lagrange constant* `Lc x = liminf_{q→∞} approx x q`, together with the set of
badly approximable reals `Bad = {x | 0 < Lc x}`.

Here we connect that machinery to classical Diophantine approximation:

* `Lc_le_one_of_irrational` : every irrational number has Lagrange constant `≤ 1`
  (a quantitative consequence of Dirichlet's theorem, the easy half of Hurwitz).
* `Lc_eq_zero_of_liouville` : Liouville numbers are *extremely* well approximable,
  so their Lagrange constant vanishes; hence
* `liouville_not_bad` : no Liouville number is badly approximable.

-- !-- Lab Notes -- !--
* **Hypothesis.** Dirichlet's theorem forces `Lc x ≤ 1` for irrational `x`, while
  the super-polynomial approximations defining a Liouville number force the
  stronger `Lc x = 0`.
* **Experiment.** From `irrational_den_unbounded` we obtain, for each `N`, a
  denominator `q ≥ N` with `approx x q ≤ 1`; `liminf_le_of_frequently_le'` then
  bounds the `liminf`.  For Liouville numbers we drive `approx` below any `ε > 0`
  along arbitrarily large denominators, using
  `Irrational.eventually_forall_le_dist_cast_div_of_denom_le` to force the
  Liouville denominators to be large.
* **Analysis.** The key inequality `approx x q.den ≤ 1` comes from
  `‖q.den · x‖ ≤ |q.den · x - q.num| < 1 / q.den`.  The `Lc = 0` argument needs a
  positive lower bound on `approx x q` for small `q` (`approx_pos_of_irrational`),
  obtained because `q · x` is never an integer.
* **Critique.** `ℝ≥0∞` arithmetic (`ENNReal.ofReal`, division, `⊤`) is delicate;
  the `liminf` lemmas require a boundedness side-condition discharged
  automatically here.
* **Synthesis.** The three exported theorems give a clean dictionary between
  approximation quality and the Lagrange constant.
-/

namespace ContinuedFractions

open Filter Topology LagrangeSpectrum

/-- Auxiliary: an `ℝ≥0∞` quantity dominated by every positive element is zero. -/
lemma eq_zero_of_forall_pos_le {x : ENNReal} (h : ∀ ε : ENNReal, 0 < ε → x ≤ ε) :
    x = 0 := by
  by_contra hx
  rcases eq_or_ne x ⊤ with rfl | htop
  · have h1 := h 1 (by norm_num); simp at h1
  · have hlt := ENNReal.half_lt_self hx htop
    exact absurd (h (x / 2) (ENNReal.half_pos hx)) (not_le.mpr hlt)

/-
If for every `N` there is some `q ≥ N` with `approx x q ≤ c`, then the
Lagrange constant is `≤ c`.
-/
lemma Lc_le_of_forall_exists_ge {x : ℝ} {c : ENNReal}
    (h : ∀ N : ℕ, ∃ q, N ≤ q ∧ approx x q ≤ c) : Lc x ≤ c := by
  convert Filter.liminf_le_of_frequently_le' _;
  exact Filter.frequently_atTop.2 fun N => by obtain ⟨ q, hq₁, hq₂ ⟩ := h N; exact ⟨ q, hq₁, hq₂ ⟩ ;

/-
A good rational approximation forces `approx x q.den ≤ 1`.
-/
lemma approx_le_one_of_approx (x : ℝ) (q : ℚ)
    (h : |x - (q : ℝ)| < 1 / (q.den : ℝ) ^ 2) : approx x q.den ≤ 1 := by
  refine' le_trans ( mul_le_mul_right _ _ ) _;
  exact ENNReal.ofReal ( |↑q.den * x - q.num| );
  · refine' ENNReal.ofReal_le_ofReal _;
    exact round_le _ _;
  · rw [ show ( q.den : ℝ ) * x - q.num = q.den * ( x - q ) by simp [ Rat.cast_def, mul_sub, mul_div_cancel₀, q.pos.ne' ], abs_mul, abs_of_nonneg ( Nat.cast_nonneg _ : ( 0 : ℝ ) ≤ q.den ) ];
    rw [ ← ENNReal.toReal_le_toReal ] <;> norm_num;
    · rw [ lt_div_iff₀ ] at h <;> nlinarith [ show ( q.den : ℝ ) ≥ 1 by exact_mod_cast q.pos ];
    · exact ENNReal.mul_ne_top ( by norm_num ) ( ENNReal.mul_ne_top ( by norm_num ) ( ENNReal.ofReal_ne_top ) )

/-- **Dirichlet bound on the Lagrange constant.** Every irrational number has
Lagrange constant at most `1`. -/
theorem Lc_le_one_of_irrational {x : ℝ} (hx : Irrational x) : Lc x ≤ 1 := by
  apply Lc_le_of_forall_exists_ge
  intro N
  obtain ⟨q, hq, hden⟩ := irrational_den_unbounded hx N
  exact ⟨q.den, hden, approx_le_one_of_approx x q hq⟩

/-
For an irrational `x` and `q ≥ 1`, the approximation `approx x q` is strictly
positive, since `q · x` is never an integer.
-/
lemma approx_pos_of_irrational {x : ℝ} (hx : Irrational x) {q : ℕ} (hq : 1 ≤ q) :
    0 < approx x q := by
  have h_approx_pos : 0 < ndist ((q : ℝ) * x) := by
    have h_nonint : ¬∃ m : ℤ, (q : ℝ) * x = m := by
      exact fun ⟨ m, hm ⟩ => hx ⟨ m / q, by push_cast; rw [ ← hm, mul_div_cancel_left₀ _ ( by positivity ) ] ⟩;
    exact abs_pos.mpr ( sub_ne_zero.mpr <| by contrapose! h_nonint; tauto );
  exact ENNReal.mul_pos ( by aesop ) ( by aesop )

/-
Estimate from a level-`(m+2)` Liouville approximation: if `b ≥ 2` and
`|x - a/b| < 1 / b ^ (m+2)`, then `approx x b.toNat ≤ ENNReal.ofReal ((1/2) ^ m)`.
-/
lemma approx_liouville_bound (x : ℝ) (a b : ℤ) (hb : 2 ≤ b) (m : ℕ)
    (h : |x - (a : ℝ) / (b : ℝ)| < 1 / (b : ℝ) ^ (m + 2)) :
    approx x b.toNat ≤ ENNReal.ofReal ((1 / 2 : ℝ) ^ m) := by
  refine' le_trans _ ( ENNReal.ofReal_le_ofReal _ );
  rotate_left;
  exact ( b.toNat : ℝ ) * ( 1 / ( b : ℝ ) ^ ( m + 1 ) );
  · rw [ one_div_pow, mul_one_div, div_le_div_iff₀ ] <;> norm_cast <;> norm_num;
    · rw [ max_eq_left ( by positivity ), pow_succ' ];
      gcongr;
    · positivity;
  · have h_approx : ndist ((b.toNat : ℝ) * x) ≤ 1 / (b : ℝ) ^ (m + 1) := by
      have h_dist : |(b.toNat : ℝ) * x - a| < 1 / (b : ℝ) ^ (m + 1) := by
        have h_abs : |(b : ℝ) * x - a| < 1 / (b : ℝ) ^ (m + 1) := by
          convert mul_lt_mul_of_pos_left h ( show ( 0 : ℝ ) < b by positivity ) using 1;
          · rw [ show ( b : ℝ ) * x - a = b * ( x - a / b ) by rw [ mul_sub, mul_div_cancel₀ _ ( by positivity ) ], abs_mul, abs_of_nonneg ( by positivity ) ];
          · rw [ mul_div, div_eq_div_iff ] <;> ring <;> positivity;
        cases b <;> norm_cast at *;
      exact le_trans ( round_le _ _ ) h_dist.le;
    convert ENNReal.ofReal_le_ofReal ( mul_le_mul_of_nonneg_left h_approx <| Nat.cast_nonneg _ ) using 1 ; norm_num [ approx ]

/-
**Liouville numbers have vanishing Lagrange constant.**
-/
theorem Lc_eq_zero_of_liouville {x : ℝ} (hx : Liouville x) : Lc x = 0 := by
  apply eq_zero_of_forall_pos_le;
  intro ε hε_pos
  by_cases hε : ε = ⊤;
  · aesop;
  · apply Lc_le_of_forall_exists_ge;
    intro N
    obtain ⟨r, hr_pos, hr⟩ : ∃ r > 0, ∀ k ≤ N, ∀ mm : ℤ, r ≤ dist x ((mm : ℝ) / (k : ℝ)) := by
      have := hx.irrational.eventually_forall_le_dist_cast_div_of_denom_le N;
      rcases Metric.eventually_nhds_iff.mp this with ⟨ r, hr₀, hr ⟩;
      exact ⟨ r / 2, half_pos hr₀, fun k hk mm => hr ( show Dist.dist ( r / 2 ) 0 < r by rw [ dist_eq_norm ] ; rw [ Real.norm_of_nonneg ] <;> linarith ) k hk mm ⟩;
    obtain ⟨m, hm⟩ : ∃ m : ℕ, (1 / 2 : ℝ) ^ m < min (ε.toReal) r := by
      exact exists_pow_lt_of_lt_one ( lt_min ( ENNReal.toReal_pos hε_pos.ne' hε ) hr_pos ) ( by norm_num );
    obtain ⟨a, b, hb1, hne, hlt⟩ := hx (m + 2);
    refine' ⟨ b.toNat, _, _ ⟩;
    · contrapose! hr;
      refine' ⟨ b.toNat, hr.le, a, _ ⟩;
      rw [ show ( b.toNat : ℝ ) = b by exact_mod_cast Int.toNat_of_nonneg ( by linarith ) ] ; exact lt_of_lt_of_le hlt ( by exact le_trans ( by simpa using inv_anti₀ ( by positivity ) ( pow_le_pow_left₀ ( by positivity ) ( show ( b : ℝ ) ≥ 2 by norm_cast ) _ ) ) ( le_trans ( pow_le_pow_of_le_one ( by positivity ) ( by norm_num ) ( show m + 2 ≥ m by linarith ) ) ( le_of_lt ( lt_of_lt_of_le hm ( min_le_right _ _ ) ) ) ) ) ;
    · refine' le_trans ( approx_liouville_bound x a b ( by linarith ) m hlt ) _;
      exact le_trans (ENNReal.ofReal_le_ofReal (lt_of_lt_of_le hm (min_le_left _ _)).le)
        (ENNReal.ofReal_toReal hε).le

/-- **No Liouville number is badly approximable.** -/
theorem liouville_not_bad {x : ℝ} (hx : Liouville x) : x ∉ Bad := by
  have h := Lc_eq_zero_of_liouville hx
  simp only [Bad, Set.mem_setOf_eq, h, lt_self_iff_false, not_false_eq_true]

end ContinuedFractions