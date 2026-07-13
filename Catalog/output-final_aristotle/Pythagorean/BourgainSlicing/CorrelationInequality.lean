import Mathlib
import Pythagorean.BourgainSlicing.DiscreteCube

/-!
# The sharp diagonal correlation inequality on the discrete cube

We work on the discrete cube `{0,1}ⁿ`, modelled as `Fin n → Bool` with the
coordinatewise (product) order, equipped with the uniform probability measure.
The uniform expectation `E`, the sign coordinates `coord`, and the coordinate
covariance kernel `T` are inherited from `DiscreteCube`.

For real observables `f, g` on the cube we study the **covariance**

  `Cov f g = E (f · g) − (E f)(E g).`

The classical **Harris / Fortuin–Kasteleyn–Ginibre (FKG) correlation
inequality** states that increasing observables are positively correlated:
`0 ≤ Cov f g` whenever `f` and `g` are monotone. Building on the finite FKG
inequality for distributive lattices, we prove:

* `cov_nonneg` — the Harris inequality for **arbitrary real** monotone
  observables (removing the nonnegativity hypothesis of the lattice FKG
  inequality by a translation argument);
* `cov_antitone` — the reverse correlation inequality for oppositely monotone
  observables;
* `var_nonneg`, `var_le_quarter` — the variance is nonnegative for every
  observable and bounded by `1/4` for `[0,1]`-valued observables;
* `cov_sq_le` — the Cauchy–Schwarz bound `(Cov f g)² ≤ Var f · Var g`;
* `cov_le_quarter` — the **sharp diagonal bound** `Cov f g ≤ 1/4` for
  `[0,1]`-valued observables, which is *attained* on the diagonal by a common
  dictatorship (`cov_dict_same`), establishing sharpness;
* `E_dict`, `var_dict`, `cov_dict_same`, `cov_dict_diff` — the exact spectrum of
  dictatorship correlations: a dictatorship has mean `1/2` and variance `1/4`,
  two dictatorships on the **same** coordinate realise the extremal covariance
  `1/4`, and two dictatorships on **distinct** coordinates are uncorrelated;
* `cov_zero_of_indep` — the disjoint-support rigidity: observables depending on
  complementary blocks of coordinates are uncorrelated (the equality boundary of
  FKG).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The FKG correlation inequality on the cube has a
*sharp diagonal* refinement `Cov f g ≤ 1/4` for `[0,1]`-valued observables, with
the two extreme regimes — same-coordinate dictatorships (correlation `1/4`) and
disjoint-support pairs (correlation `0`) — sitting at the two ends of the
spectrum. This is the skeleton of the stability trichotomy.

Experiment (Experimenter): We reduced the lower bound `0 ≤ Cov` to Mathlib's
lattice FKG inequality by a translation to the nonnegative orthant, and the
upper bound to Cauchy–Schwarz plus the `[0,1]` variance bound. Dictatorship
values were computed exactly through the coordinate covariance kernel `T`.

Analysis (Analyst): The lower bound needs monotonicity; the upper bound does
not (it holds for all bounded observables). Sharpness on both ends is witnessed
by explicit dictatorships. Disjoint support forces exact independence via a
product decomposition of the cube.

Critique (Critic): Every headline theorem uses genuine structure (order,
Cauchy–Schwarz, or a product Fubini argument), none is definitional. The `1/4`
bound is proved sharp, not merely asserted.

Synthesis (PI): Harris (both signs), the sharp diagonal bound, its dictatorship
extremisers, and disjoint-support rigidity together form the base camp for the
stability programme.
-/

open Finset

namespace BourgainSlicing

variable {n : ℕ}

/-- Uniform covariance of two observables on the discrete cube. -/
noncomputable def Cov (f g : (Fin n → Bool) → ℝ) : ℝ :=
  E (fun x => f x * g x) - E f * E g

/-- Uniform variance of an observable. -/
noncomputable def Var (f : (Fin n → Bool) → ℝ) : ℝ := Cov f f

lemma two_pow_ne_zero : (2 : ℝ) ^ n ≠ 0 := by positivity

/-! ### Linearity of expectation -/

@[simp] lemma E_const (c : ℝ) : E (fun _ : Fin n → Bool => c) = c := by
  unfold E
  rw [Finset.sum_const, card_cube, nsmul_eq_mul]
  push_cast
  field_simp

lemma E_add (f g : (Fin n → Bool) → ℝ) :
    E (fun x => f x + g x) = E f + E g := by
  unfold E; rw [← add_div, Finset.sum_add_distrib]

lemma E_neg (f : (Fin n → Bool) → ℝ) : E (fun x => - f x) = - E f := by
  unfold E; rw [← neg_div, Finset.sum_neg_distrib]

lemma E_sub (f g : (Fin n → Bool) → ℝ) :
    E (fun x => f x - g x) = E f - E g := by
  unfold E; rw [← sub_div, ← Finset.sum_sub_distrib]

lemma E_smul (c : ℝ) (f : (Fin n → Bool) → ℝ) :
    E (fun x => c * f x) = c * E f := by
  unfold E; rw [← Finset.mul_sum, mul_div_assoc]

lemma E_mono {f g : (Fin n → Bool) → ℝ} (h : ∀ x, f x ≤ g x) : E f ≤ E g := by
  unfold E
  gcongr with x
  exact h x

/-! ### Covariance algebra -/

lemma Cov_comm (f g : (Fin n → Bool) → ℝ) : Cov f g = Cov g f := by
  unfold Cov
  have hfg : (fun x => f x * g x) = (fun x => g x * f x) := by funext x; ring
  rw [hfg, mul_comm (E f) (E g)]

lemma Cov_add_const_left (f g : (Fin n → Bool) → ℝ) (c : ℝ) :
    Cov (fun x => f x + c) g = Cov f g := by
  unfold Cov
  have h1 : (fun x => (f x + c) * g x) = (fun x => f x * g x + c * g x) := by
    funext x; ring
  rw [h1, E_add, E_add, E_const, E_smul]
  ring

lemma Cov_neg_right (f g : (Fin n → Bool) → ℝ) :
    Cov f (fun x => - g x) = - Cov f g := by
  unfold Cov
  have h1 : (fun x => f x * (- g x)) = (fun x => - (f x * g x)) := by
    funext x; ring
  rw [h1, E_neg, E_neg]; ring

/-! ### The Harris / FKG correlation inequality -/

/--
The FKG inequality for nonnegative monotone observables, obtained from the
finite lattice four-functions theorem with the uniform (constant) weight.
-/
lemma cov_nonneg_of_nonneg {f g : (Fin n → Bool) → ℝ}
    (hf : Monotone f) (hg : Monotone g) (hf0 : 0 ≤ f) (hg0 : 0 ≤ g) :
    0 ≤ Cov f g := by
  have h := fkg (μ := (1 : (Fin n → Bool) → ℝ)) (f := f) (g := g) (by intro x; simp) hf0 hg0 hf hg (by intro a b; simp);
  unfold Cov E; simp_all +decide [ Finset.sum_add_distrib, mul_add, add_mul, mul_assoc, mul_comm, mul_left_comm, div_eq_mul_inv ] ;
  rwa [ inv_mul_le_iff₀ ( by positivity ) ]

/--
**Harris / FKG correlation inequality.** Increasing observables on the cube
are positively correlated — with no nonnegativity hypothesis.
-/
theorem cov_nonneg {f g : (Fin n → Bool) → ℝ}
    (hf : Monotone f) (hg : Monotone g) : 0 ≤ Cov f g := by
  convert cov_nonneg_of_nonneg ( show Monotone fun x => f x - f ⊥ from fun a b hab => ?_ ) ( show Monotone fun x => g x - g ⊥ from fun a b hab => ?_ ) ?_ ?_ using 1 <;> norm_num [ hf, hg ];
  · unfold Cov; norm_num [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, sub_mul, mul_sub ] ; ring;
    unfold E; norm_num [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, sub_mul, mul_sub ] ; ring;
    norm_num [ pow_mul', ← mul_assoc, ← Finset.sum_mul _ _ _ ] ; ring;
    norm_num [ mul_assoc, ← mul_pow ];
    ring;
  · exact hf hab;
  · exact hg hab;
  · exact fun x => sub_nonneg_of_le <| hf <| bot_le;
  · exact fun x => sub_nonneg_of_le <| hg <| bot_le

/--
**Reverse correlation inequality.** An increasing and a decreasing
observable are negatively correlated.
-/
theorem cov_antitone {f g : (Fin n → Bool) → ℝ}
    (hf : Monotone f) (hg : Antitone g) : Cov f g ≤ 0 := by
  convert neg_nonpos_of_nonneg ( cov_nonneg hf ( show Monotone fun x => - ( g x ) from fun a b hab => neg_le_neg <| hg hab ) ) using 1;
  unfold Cov; ring;
  unfold E; norm_num [ Finset.sum_neg_distrib ] ; ring;

/-! ### Variance bounds and Cauchy–Schwarz -/

/--
The variance is nonnegative for every observable.
-/
theorem var_nonneg (f : (Fin n → Bool) → ℝ) : 0 ≤ Var f := by
  unfold Var;
  unfold Cov E;
  field_simp;
  have := Finset.univ.sum_le_sum fun x _ => pow_two_nonneg ( f x - ( ∑ y : Fin n → Bool, f y ) / 2 ^ n );
  norm_num [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ] at this;
  norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ] at *;
  nlinarith [ show ( 0 : ℝ ) < 2 ^ n by positivity, mul_div_cancel₀ ( ∑ y : Fin n → Bool, f y ) ( show ( 2 : ℝ ) ^ n ≠ 0 by positivity ) ]

/--
**Cauchy–Schwarz for covariance.**
-/
theorem cov_sq_le (f g : (Fin n → Bool) → ℝ) :
    (Cov f g) ^ 2 ≤ Var f * Var g := by
  -- By centering $f$ and $g$, we can reduce the problem to the case where $E(f) = 0$ and $E(g) = 0$.
  suffices h_centered : ∀ (f g : (Fin n → Bool) → ℝ), (∑ x, f x = 0) → (∑ x, g x = 0) → (∑ x, f x * g x) ^ 2 ≤ (∑ x, f x ^ 2) * (∑ x, g x ^ 2) by
    convert div_le_div_of_nonneg_right ( h_centered ( fun x => f x - E f ) ( fun x => g x - E g ) ?_ ?_ ) ( show ( 0 : ℝ ) ≤ ( 2^n ) ^2 by positivity ) using 1 <;> simp +decide [ Cov, Var, E ];
    · simp +decide [ sub_mul, mul_sub, Finset.sum_mul _ _ _, Finset.mul_sum, Finset.sum_add_distrib, div_eq_mul_inv ] ; ring;
      norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ] ; ring;
      norm_num [ pow_mul', ← mul_pow ] ; ring;
      norm_num only [ mul_assoc, ← mul_pow ] ; ring;
    · simp +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, div_eq_mul_inv ] ; ring;
      norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, pow_mul ] ; ring;
      norm_num [ pow_mul', ← mul_pow ] ; ring;
      norm_num only [ mul_assoc, ← mul_pow ] ; ring;
    · rw [ mul_div_cancel₀ _ ( by positivity ), sub_self ];
    · rw [ mul_div_cancel₀ _ ( by positivity ), sub_self ];
  exact fun f g _ _ => Finset.sum_mul_sq_le_sq_mul_sq univ f g

/--
For a `[0,1]`-valued observable the variance is at most `1/4`.
-/
theorem var_le_quarter {f : (Fin n → Bool) → ℝ}
    (h0 : ∀ x, 0 ≤ f x) (h1 : ∀ x, f x ≤ 1) : Var f ≤ 1 / 4 := by
  -- By definition of variance, we have Var f = E (fun x => f x ^ 2) - (E f) ^ 2.
  have h_var_def : Var f = E (fun x => f x ^ 2) - (E f) ^ 2 := by
    unfold Var Cov; ring;
  -- Since $0 \leq f x \leq 1$, we have $f x^2 \leq f x$ pointwise.
  have h_pointwise : ∀ x, f x ^ 2 ≤ f x := by
    exact fun x => by nlinarith only [ h0 x, h1 x ] ;
  nlinarith [ sq_nonneg ( E f - 1 / 2 ), E_mono h_pointwise, show E ( fun x => f x ^ 2 ) ≤ E f from E_mono h_pointwise ]

/--
**Sharp diagonal correlation bound.** For `[0,1]`-valued observables the
covariance never exceeds `1/4`.
-/
theorem cov_le_quarter {f g : (Fin n → Bool) → ℝ}
    (hf0 : ∀ x, 0 ≤ f x) (hf1 : ∀ x, f x ≤ 1)
    (hg0 : ∀ x, 0 ≤ g x) (hg1 : ∀ x, g x ≤ 1) : Cov f g ≤ 1 / 4 := by
  convert le_trans ( Real.le_sqrt_of_sq_le ( cov_sq_le f g ) ) _ using 1;
  rw [ Real.sqrt_le_left ] <;> norm_num ; nlinarith [ var_le_quarter hf0 hf1, var_le_quarter hg0 hg1, var_nonneg f, var_nonneg g ]

/-! ### Dictatorships: the exact correlation spectrum -/

/-- The `i`-th dictatorship: the `{0,1}`-indicator of the `i`-th coordinate. -/
def dict (i : Fin n) : (Fin n → Bool) → ℝ := fun x => if x i then 1 else 0

lemma dict_monotone (i : Fin n) : Monotone (dict i) := by
  intro x y hxy
  have h : x i ≤ y i := hxy i
  simp only [dict]
  cases hx : x i <;> cases hy : y i <;> simp_all <;> exact absurd h (by decide)

lemma dict_eq_coord (i : Fin n) (x : Fin n → Bool) :
    dict i x = (coord x i + 1) / 2 := by
  unfold dict coord sgn
  cases x i <;> norm_num

lemma dict_mul_self (i : Fin n) (x : Fin n → Bool) :
    dict i x * dict i x = dict i x := by
  unfold dict; cases x i <;> simp

/--
A dictatorship has mean `1/2`.
-/
theorem E_dict (i : Fin n) : E (dict i) = 1 / 2 := by
  have hc : E (fun x : Fin n → Bool => coord x i) = 0 := by
    unfold E;
    norm_num [ div_eq_iff, BourgainSlicing.sum_coord_eq_zero ];
  -- Rewrite `dict i` using `dict_eq_coord i : dict i x = (coord x i + 1)/2`.
  have hDict : (dict i) = (fun x : Fin n → Bool => (1 / 2 : ℝ) * coord x i + 1 / 2) := by
    ext x; rw [ dict_eq_coord i x ] ; ring;
  rw [ hDict, E_add, E_smul, hc ] ; norm_num

/--
A dictatorship has variance `1/4`.
-/
theorem var_dict (i : Fin n) : Var (dict i) = 1 / 4 := by
  unfold Var Cov;
  rw [ show ( fun x => dict i x * dict i x ) = dict i from funext fun x => dict_mul_self i x ] ; rw [ E_dict ] ; norm_num;

/-- Two dictatorships on the **same** coordinate realise the extremal covariance
`1/4`: the diagonal of the sharp correlation bound is attained. -/
theorem cov_dict_same (i : Fin n) : Cov (dict i) (dict i) = 1 / 4 := var_dict i

/--
Two dictatorships on **distinct** coordinates are uncorrelated.
-/
theorem cov_dict_diff {i j : Fin n} (h : i ≠ j) : Cov (dict i) (dict j) = 0 := by
  -- Using `dict_eq_coord`, `dict i x * dict j x = (coord x i + 1)/2 * (coord x j + 1)/2`.
  have h_prod : ∀ x : Fin n → Bool, dict i x * dict j x = (coord x i * coord x j + coord x i + coord x j + 1) / 4 := by
    exact fun x => by rw [ dict_eq_coord i x, dict_eq_coord j x ] ; ring;
  convert congr_arg₂ ( fun a b : ℝ => a - b ) ( E_smul ( 1 / 4 : ℝ ) ( fun x : Fin n → Bool => coord x i * coord x j + coord x i + coord x j + 1 ) ) ( congr_arg₂ ( fun a b : ℝ => a * b ) ( E_dict i ) ( E_dict j ) ) using 1 <;> norm_num [ h_prod, E ] ; ring!;
  · unfold Cov; norm_num [ h_prod, E ] ; ring;
    norm_num ; ring;
  · norm_num [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul, div_eq_mul_inv ];
    rw [ show ( ∑ x : Fin n → Bool, coord x i * coord x j ) = 0 from by rw [ show ( ∑ x : Fin n → Bool, coord x i * coord x j ) = T i j from rfl, T_off_diag h ] ] ; norm_num [ sum_coord_eq_zero ]

/-! ### Disjoint-support rigidity (the FKG equality boundary) -/

/-- Coordinatewise merge: take the `S`-coordinates from `u` and the rest from `v`. -/
def mask (S : Finset (Fin n)) (u v : Fin n → Bool) : Fin n → Bool :=
  fun i => if i ∈ S then u i else v i

lemma mask_mem {S : Finset (Fin n)} {u v : Fin n → Bool} {i : Fin n} (h : i ∈ S) :
    mask S u v i = u i := by simp [mask, h]

lemma mask_not_mem {S : Finset (Fin n)} {u v : Fin n → Bool} {i : Fin n} (h : i ∉ S) :
    mask S u v i = v i := by simp [mask, h]

/-- The pair swap `(x,y) ↦ (mask x y, mask y x)` is an involution of the product
cube; it exchanges the two complementary coordinate blocks. -/
lemma maskPair_involutive (S : Finset (Fin n)) :
    Function.Involutive
      (fun p : (Fin n → Bool) × (Fin n → Bool) => (mask S p.1 p.2, mask S p.2 p.1)) := by
  intro p
  ext i
  · by_cases h : i ∈ S <;> simp [mask, h]
  · by_cases h : i ∈ S <;> simp [mask, h]

/-- The involution of the product cube swapping complementary coordinate blocks. -/
def maskEquiv (S : Finset (Fin n)) : ((Fin n → Bool) × (Fin n → Bool)) ≃ ((Fin n → Bool) × (Fin n → Bool)) :=
  (maskPair_involutive S).toPerm

/--
**Independence from disjoint supports.** If `f` depends only on the
coordinates in a set `S` and `g` depends only on the coordinates outside `S`,
then `f` and `g` are uncorrelated. This is the extremal (equality) regime of the
correlation inequality.
-/
theorem cov_zero_of_indep (S : Finset (Fin n)) (f g : (Fin n → Bool) → ℝ)
    (hf : ∀ x y, (∀ i ∈ S, x i = y i) → f x = f y)
    (hg : ∀ x y, (∀ i ∉ S, x i = y i) → g x = g y) :
    Cov f g = 0 := by
  -- By the properties of the mask, we can rewrite the sum as:
  have h_sum : (∑ x : Fin n → Bool, f x) * (∑ x : Fin n → Bool, g x) = 2 ^ n * (∑ x : Fin n → Bool, f x * g x) := by
    -- Apply the maskEquiv to rewrite the sum.
    have h_sum : (∑ x : Fin n → Bool, f x) * (∑ y : Fin n → Bool, g y) = ∑ p : (Fin n → Bool) × (Fin n → Bool), f (mask S p.1 p.2) * g (mask S p.1 p.2) := by
      rw [ Finset.sum_mul_sum ];
      rw [ ← Finset.sum_product' ];
      refine' Finset.sum_congr rfl fun p hp => _;
      exact congr_arg₂ _ ( hf _ _ fun i hi => by unfold mask; aesop ) ( hg _ _ fun i hi => by unfold mask; aesop );
    convert h_sum using 1;
    convert ( Equiv.sum_comp ( maskEquiv S ) fun p => f p.1 * g p.1 ) |> Eq.symm using 1;
    erw [ Finset.sum_product ] ; norm_num [ card_cube ];
    rw [ Finset.mul_sum _ _ _ ];
  unfold Cov E;
  grind

end BourgainSlicing