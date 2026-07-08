import Mathlib

/-!
# The Shadowing Lemma for Expanding and Hyperbolic Maps

This file complements `Contraction.lean` by treating the two remaining local
models of hyperbolic dynamics: **expanding** directions and their combination
with contracting ones into a genuinely **hyperbolic** map.

Unlike a contraction, an *expanding* map amplifies errors in forward time, so a
pseudo-orbit can only be shadowed on a *finite* time window `{0, 1, …, N}`; the
shadowing orbit is built by anchoring at the *last* point `x N` and iterating the
inverse (a contraction) **backwards**.  A hyperbolic map splits its space into a
stable (contracting) factor and an unstable (expanding, invertible) factor; the
shadow is then assembled coordinate-wise — forward in the stable factor, backward
in the unstable factor.  This is exactly the mechanism behind the Anosov /
Bowen shadowing theorem.

Everything is stated over general metric spaces and is fully explicit and
quantitative.  The file is self-contained (it only imports Mathlib).

## Main results

* `Computation.Shadowing.Hyperbolic.contraction_window_bound`: forward error bound
  for a contraction on a finite window.
* `Computation.Shadowing.Hyperbolic.expanding_window_bound`: backward error bound
  for an expanding (invertible) map on a finite window.
* `Computation.Shadowing.Hyperbolic.expanding_finite_shadowing`: finite-time
  shadowing for expanding invertible maps, anchored at the endpoint.
* `Computation.Shadowing.Hyperbolic.hyperbolic_finite_shadowing`: finite-time
  shadowing for a hyperbolic map `fs × fu` on a product space.
* `Computation.Shadowing.Hyperbolic.hyperbolicLinear_shadowing`: a concrete
  instance for the linear hyperbolic map `(s, u) ↦ (s/2, 2u)` on `ℝ × ℝ`.
-/

namespace Computation.Shadowing.Hyperbolic

open Function

/-- `y` is a genuine orbit of `f`: each term is the image of the previous one. -/
def IsOrbit {X : Type*} (f : X → X) (y : ℕ → X) : Prop := ∀ n, y (n + 1) = f (y n)

/-! ### Forward bound for a contraction on a finite window -/

/--
**Windowed contraction bound.**  If `x` follows the contraction `f`
(`LipschitzWith L`, `L < 1`) up to error `δ` on the window `n < N`, then each term
`x n` (`n ≤ N`) is within `δ / (1 - L)` of the true orbit through `x 0`.
-/
theorem contraction_window_bound {S : Type*} [MetricSpace S] (f : S → S) (L : NNReal)
    (hL : LipschitzWith L f) (hL1 : (L : ℝ) < 1) {δ : ℝ} (hδ : 0 ≤ δ) {N : ℕ} {x : ℕ → S}
    (hx : ∀ n, n < N → dist (x (n + 1)) (f (x n)) ≤ δ) :
    ∀ n, n ≤ N → dist (x n) (f^[n] (x 0)) ≤ δ / (1 - L) := by
  intro n hn;
  induction' n with n ih;
  · simp +decide [ hδ, div_nonneg, sub_nonneg.2 hL1.le ];
  · -- Using the triangle inequality and the induction hypothesis, we get:
    have h_triangle : dist (x (n + 1)) (f^[n + 1] (x 0)) ≤ dist (x (n + 1)) (f (x n)) + dist (f (x n)) (f (f^[n] (x 0))) := by
      simpa only [ Function.iterate_succ_apply' ] using dist_triangle _ _ _;
    refine' le_trans h_triangle ( le_trans ( add_le_add ( hx n ( Nat.lt_of_succ_le hn ) ) ( hL.dist_le_mul _ _ ) ) _ );
    rw [ le_div_iff₀ ] at * <;> nlinarith [ ih ( Nat.le_of_succ_le hn ), NNReal.coe_nonneg L ]

/-! ### Backward bound for an expanding (invertible) map on a finite window -/

/--
**Windowed expanding bound.**  Let `f` be invertible with inverse `g`
(`g (f z) = z`), where `g` is a contraction (`LipschitzWith μ`, `μ < 1`).  If `x`
follows `f` up to error `δ` on the window `n < N`, then the *backward* iterate
`g^[m] (x N)` stays within `δ μ / (1 - μ)` of `x (N - m)` for every `m ≤ N`.
-/
theorem expanding_window_bound {U : Type*} [MetricSpace U] (f g : U → U) (μ : NNReal)
    (hg : LipschitzWith μ g) (hμ1 : (μ : ℝ) < 1) (hgf : ∀ z, g (f z) = z)
    {δ : ℝ} (hδ : 0 ≤ δ) {N : ℕ} {x : ℕ → U}
    (hx : ∀ n, n < N → dist (x (n + 1)) (f (x n)) ≤ δ) :
    ∀ m, m ≤ N → dist (x (N - m)) (g^[m] (x N)) ≤ δ * μ / (1 - μ) := by
  intro m hm
  induction' m with m ih;
  · simp only [Nat.sub_zero, Function.iterate_zero, id_eq, dist_self];
    exact div_nonneg ( mul_nonneg hδ ( NNReal.coe_nonneg _ ) ) ( sub_nonneg.2 hμ1.le );
  · have h_ind : dist (x (N - (m + 1))) (g (x (N - m))) ≤ μ * δ := by
      have h_ind : dist (g (x (N - m))) (g (f (x (N - (m + 1))))) ≤ μ * δ := by
        refine' le_trans ( hg.dist_le_mul _ _ ) _;
        exact mul_le_mul_of_nonneg_left ( by simpa [ show N - m = N - ( m + 1 ) + 1 by omega ] using hx ( N - ( m + 1 ) ) ( by omega ) ) ( NNReal.coe_nonneg _ );
      rwa [ hgf, dist_comm ] at h_ind;
    have h_ind_step : dist (g (x (N - m))) (g^[m + 1] (x N)) ≤ μ * dist (x (N - m)) (g^[m] (x N)) := by
      simpa only [ Function.iterate_succ_apply' ] using hg.dist_le_mul _ _;
    have := ih ( Nat.le_of_succ_le hm );
    rw [ le_div_iff₀ ] at * <;> nlinarith [ NNReal.coe_nonneg μ, NNReal.coe_lt_one.2 hμ1, dist_triangle ( x ( N - ( m + 1 ) ) ) ( g ( x ( N - m ) ) ) ( g^[m + 1] ( x N ) ) ]

/--
**Finite-time shadowing for expanding invertible maps.**  A `δ`-pseudo-orbit
`x₀, …, x_N` of `f` is shadowed within `δ μ / (1 - μ)` by the genuine orbit
obtained by iterating the inverse `g` backwards from the endpoint `x N`.
-/
theorem expanding_finite_shadowing {U : Type*} [MetricSpace U] (f g : U → U) (μ : NNReal)
    (hg : LipschitzWith μ g) (hμ1 : (μ : ℝ) < 1) (hfg : ∀ z, f (g z) = z) (hgf : ∀ z, g (f z) = z)
    {δ : ℝ} (hδ : 0 ≤ δ) {N : ℕ} {x : ℕ → U}
    (hx : ∀ n, n < N → dist (x (n + 1)) (f (x n)) ≤ δ) :
    ∃ y : ℕ → U, (∀ n, n < N → y (n + 1) = f (y n)) ∧ y N = x N ∧
      ∀ n, n ≤ N → dist (x n) (y n) ≤ δ * μ / (1 - μ) := by
  refine' ⟨ fun n => if n ≤ N then g^[N - n] ( x N ) else f^[n - N] ( x N ), _, _, _ ⟩ <;> simp_all +decide;
  · intro n hn; rw [ if_pos hn.le ] ; rw [ show N - n = N - ( n + 1 ) + 1 by omega ] ; simp +decide [ *, Function.iterate_succ_apply' ] ;
  · intro n hn; have := expanding_window_bound f g μ hg hμ1 hgf hδ hx ( N - n ) ( by omega ) ; simp_all +decide [ Nat.sub_sub_self hn ] ;

/-! ### Shadowing for a hyperbolic map on a product space -/

/--
**Finite-time shadowing for hyperbolic maps.**  Let `fs` be a contraction on
`S` and `fu` an expanding invertible map on `U` with contracting inverse `gu`.
Their product `fs × fu` on `S × U` is hyperbolic, and every `δ`-pseudo-orbit is
shadowed on the window `{0, …, N}` by a genuine orbit, within
`max (δ / (1 - L)) (δ μ / (1 - μ))`.  The stable coordinate is shadowed forward,
the unstable coordinate backward.
-/
theorem hyperbolic_finite_shadowing {S U : Type*} [MetricSpace S] [MetricSpace U]
    (fs : S → S) (fu gu : U → U) (L μ : NNReal)
    (hLs : LipschitzWith L fs) (hL1 : (L : ℝ) < 1)
    (hgu : LipschitzWith μ gu) (hμ1 : (μ : ℝ) < 1)
    (hfg : ∀ z, fu (gu z) = z) (hgf : ∀ z, gu (fu z) = z)
    {δ : ℝ} (hδ : 0 ≤ δ) {N : ℕ} {x : ℕ → S × U}
    (hx : ∀ n, n < N → dist (x (n + 1)) (Prod.map fs fu (x n)) ≤ δ) :
    ∃ y : ℕ → S × U, (∀ n, n < N → y (n + 1) = Prod.map fs fu (y n)) ∧
      ∀ n, n ≤ N → dist (x n) (y n) ≤ max (δ / (1 - L)) (δ * μ / (1 - μ)) := by
  -- Define the stable and unstable parts of the shadow orbit.
  obtain ⟨ys, hys⟩ : ∃ ys : ℕ → S, (∀ n, n < N → ys (n + 1) = fs (ys n)) ∧ (∀ n, n ≤ N → dist (x n).1 (ys n) ≤ δ / (1 - L)) := by
    refine' ⟨ fun n => fs^[n] ( x 0 |>.1 ), _, _ ⟩ <;> simp_all +decide [ Function.iterate_succ_apply' ];
    convert contraction_window_bound fs L hLs ( mod_cast hL1 ) hδ _ using 1;
    exact fun n hn => le_trans ( le_max_left _ _ ) ( hx n hn );
  obtain ⟨yu, hyu⟩ : ∃ yu : ℕ → U, (∀ n, n < N → yu (n + 1) = fu (yu n)) ∧ yu N = (x N).2 ∧ (∀ n, n ≤ N → dist (x n).2 (yu n) ≤ δ * μ / (1 - μ)) := by
    apply expanding_finite_shadowing fu gu μ hgu hμ1 hfg hgf hδ;
    exact fun n hn => le_trans ( le_max_right _ _ ) ( hx n hn );
  refine' ⟨ fun n => ( ys n, yu n ), _, _ ⟩ <;> simp_all +decide [ Prod.dist_eq ];
  grind +splitIndPred

/-! ### A concrete instance: the linear hyperbolic map `(s, u) ↦ (s/2, 2u)` on `ℝ²` -/

/--
**Concrete hyperbolic shadowing.**  For the linear hyperbolic map
`(s, u) ↦ (s/2, 2u)` on `ℝ × ℝ` (contracting by `1/2` in the stable direction,
expanding by `2` in the unstable direction), every `δ`-pseudo-orbit on a window
`{0, …, N}` is shadowed by a true orbit within `2 δ`.
-/
theorem hyperbolicLinear_shadowing {δ : ℝ} (hδ : 0 ≤ δ) {N : ℕ} {x : ℕ → ℝ × ℝ}
    (hx : ∀ n, n < N →
      dist (x (n + 1)) (Prod.map (fun s => s / 2) (fun u => 2 * u) (x n)) ≤ δ) :
    ∃ y : ℕ → ℝ × ℝ,
      (∀ n, n < N → y (n + 1) = Prod.map (fun s => s / 2) (fun u => 2 * u) (y n)) ∧
        ∀ n, n ≤ N → dist (x n) (y n) ≤ 2 * δ := by
  have := @hyperbolic_finite_shadowing;
  convert this ( fun s => s / 2 ) ( fun u => 2 * u ) ( fun u => u / 2 ) ( 1 / 2 ) ( 1 / 2 ) _ _ _ _ _ _ hδ hx using 1 <;> norm_num [ div_eq_mul_inv ];
  · grind;
  · norm_num [ lipschitzWith_iff_norm_sub_le ];
    exact fun x y => abs_le.mpr ⟨ by cases abs_cases ( x - y ) <;> linarith, by cases abs_cases ( x - y ) <;> linarith ⟩;
  · norm_num [ lipschitzWith_iff_norm_sub_le ];
    grind +qlia;
  · exact fun z => by ring;
  · exact fun z => by ring;

end Computation.Shadowing.Hyperbolic