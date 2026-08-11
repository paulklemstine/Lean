/-
# A finite-scale fractal uncertainty principle on prime-power trees

This development isolates an elementary finite-scale core of the fractal
uncertainty principle over a non-Archimedean local field.  Balls at depth `n`
in the unit ball of `ℚ_p` are represented by words of length `n` in a
`p`-letter alphabet.  Porosity is encoded by a uniform loss in the number of
admissible descendants.  The analytic argument is the Hilbert--Schmidt bound
for a normalized oscillatory kernel.

The resulting theorem applies whenever the loss of descendants is strong
enough that the product of the two branching numbers is smaller than the
ambient branching number.  This is an elementary, quantitatively explicit
regime of the porous-set uncertainty phenomenon; the subtler additive-energy
argument needed for arbitrary fixed porosity is deliberately not assumed.
-/
import Mathlib
import Novelty.AdditiveCAPadicRenorm

open scoped BigOperators

namespace PadicFractalUncertainty

noncomputable section

/-- The squared `ℓ²` mass of a function on a finite set. -/
def energy {α : Type*} (X : Finset α) (f : α → ℂ) : ℝ :=
  ∑ x ∈ X, ‖f x‖ ^ 2

/-- A kernel transform restricted to input set `X`. -/
def restrictedTransform {α β : Type*} (K : β → α → ℂ)
    (X : Finset α) (f : α → ℂ) (y : β) : ℂ :=
  ∑ x ∈ X, K y x * f x

-- !-- Lab Notes -- !--
/-
Hypothesis: normalization of every Fourier-matrix entry by `N⁻¹ᐟ²` already
forces a restricted transform bound controlled by the product of support sizes.
Experiment: expand the finite sums, use the triangle inequality pointwise, and
apply finite Cauchy--Schwarz before summing over the output set.
Analysis: no orthogonality is needed; this is precisely the Hilbert--Schmidt
mechanism and therefore applies to every oscillatory phase.
Critique: the estimate ignores cancellation, so it gives decay only in the
strong-porosity regime.  It must not be advertised as the full sharp theorem.
Synthesis: `restricted_energy_bound` is the analytic module used below.

Hilbert--Schmidt uncertainty bound for a uniformly normalized finite kernel.
-/
theorem restricted_energy_bound {α β : Type*} (K : β → α → ℂ)
    (X : Finset α) (Y : Finset β) (f : α → ℂ) (N : ℝ)
    (hN : 0 < N) (hK : ∀ y x, ‖K y x‖ ≤ 1 / Real.sqrt N) :
    energy Y (restrictedTransform K X f) ≤
      ((X.card : ℝ) * (Y.card : ℝ) / N) * energy X f := by
  -- By the properties of the norm and the triangle inequality, we can bound the energy of the restricted transform.
  have h_bound : ∀ y ∈ Y, ‖∑ x ∈ X, K y x * f x‖ ^ 2 ≤ (1 / N) * (∑ x ∈ X, ‖f x‖) ^ 2 := by
    intro y hy
    have h_sum_bound : ‖∑ x ∈ X, K y x * f x‖ ≤ (1 / Real.sqrt N) * ∑ x ∈ X, ‖f x‖ := by
      exact le_trans ( norm_sum_le _ _ ) ( by rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_le_sum fun x hx => by simpa [ mul_comm ] using mul_le_mul_of_nonneg_right ( hK y x ) ( norm_nonneg ( f x ) ) );
    convert pow_le_pow_left₀ ( norm_nonneg _ ) h_sum_bound 2 using 1 ; ring ; norm_num [ hN.le ];
    ring;
  refine' le_trans ( Finset.sum_le_sum h_bound ) _;
  -- Apply the Cauchy-Schwarz inequality to the sum of norms.
  have h_cauchy_schwarz : (∑ x ∈ X, ‖f x‖) ^ 2 ≤ X.card * ∑ x ∈ X, ‖f x‖ ^ 2 := by
    have := ( Finset.sum_le_sum fun x ( hx : x ∈ X ) => mul_self_nonneg ( ‖f x‖ - ( ∑ y ∈ X, ‖f y‖ ) / X.card ) );
    by_cases hX : X = ∅ <;> simp_all +decide [ sub_mul, mul_sub ];
    case _ => simp_all +decide only [← Finset.sum_mul, ← sq, ← Finset.mul_sum _ _ _] ; nlinarith [ mul_div_cancel₀ ( ∑ y ∈ X, ‖f y‖ ) ( Nat.cast_ne_zero.mpr <| Finset.card_ne_zero_of_mem <| Classical.choose_spec <| Finset.nonempty_of_ne_empty hX ) ] ;
  simp_all +decide [ div_eq_inv_mul, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ];
  convert mul_le_mul_of_nonneg_left h_cauchy_schwarz ( Nat.cast_nonneg Y.card ) using 1 ; simp +decide [ mul_left_comm, Finset.mul_sum _ _ _, energy ]

/-
The standard normalized exponential kernel has constant modulus `N⁻¹ᐟ²`.
-/
theorem normalized_phase_kernel_bound {α β : Type*} (phase : β → α → ℝ)
    (N : ℝ) (y : β) (x : α) :
    ‖Complex.exp (phase y x * Complex.I) / (Real.sqrt N : ℂ)‖ ≤
      1 / Real.sqrt N := by
  simp +decide [ Complex.norm_exp, abs_of_nonneg ( Real.sqrt_nonneg _ ) ]

/-
Uncertainty bound for every normalized finite oscillatory transform.
-/
theorem oscillatory_restricted_energy_bound {α β : Type*}
    (phase : β → α → ℝ) (X : Finset α) (Y : Finset β)
    (f : α → ℂ) (N : ℝ) (hN : 0 < N) :
    energy Y (restrictedTransform
      (fun y x => Complex.exp (phase y x * Complex.I) / (Real.sqrt N : ℂ)) X f) ≤
      ((X.card : ℝ) * (Y.card : ℝ) / N) * energy X f := by
  convert restricted_energy_bound _ _ _ _ _ _ _ using 1 <;> norm_num [ abs_of_pos, hN ]

-- !-- Lab Notes -- !--
/-
Hypothesis: losing at least one child at every scale forces exponential
cardinality loss down the residue-class tree.
Experiment: replace geometric porosity by its exact combinatorial consequence,
the recurrence `c(n+1) ≤ a*c(n)`, and induct on depth.
Analysis: the geometry of ultrametric balls enters only through this recurrence.
Critique: cardinal decay alone is insufficient for weak porosity; the threshold
`a*b < q` below records exactly where the Hilbert--Schmidt argument stops.
Synthesis: the recurrence and analytic estimate combine without hidden regularity.

Iterating a uniform branching bound gives exponential cardinality growth.
-/
theorem porous_cardinality {c : ℕ → ℕ} {a : ℕ}
    (h0 : c 0 ≤ 1) (hstep : ∀ n, c (n + 1) ≤ a * c n) :
    ∀ n, c n ≤ a ^ n := by
  intro n; induction' n with n ih <;> simp_all +decide [ pow_succ' ] ; nlinarith [ hstep n ] ;

/-
Product form of the porous cardinality estimate for two independent trees.
-/
theorem two_porous_cardinality {cX cY : ℕ → ℕ} {a b : ℕ}
    (hX0 : cX 0 ≤ 1) (hY0 : cY 0 ≤ 1)
    (hX : ∀ n, cX (n + 1) ≤ a * cX n)
    (hY : ∀ n, cY (n + 1) ≤ b * cY n) (n : ℕ) :
    cX n * cY n ≤ (a * b) ^ n := by
  rw [ mul_pow ];
  exact Nat.mul_le_mul ( porous_cardinality hX0 hX n ) ( porous_cardinality hY0 hY n )

/-
The finite-scale porous uncertainty principle.

If two depth-`n` residue trees have branching at most `a` and `b` inside an
ambient `q`-ary tree, then every normalized oscillatory transform restricted to
their leaves loses energy by the explicit factor `((a*b)/q)^n`.
-/
theorem porous_fractal_uncertainty {α β : Type*}
    (phase : β → α → ℝ) (X : Finset α) (Y : Finset β)
    (f : α → ℂ) (a b q n : ℕ) (hq : 0 < q)
    (hX : X.card ≤ a ^ n) (hY : Y.card ≤ b ^ n) :
    energy Y (restrictedTransform
      (fun y x => Complex.exp (phase y x * Complex.I) /
        (Real.sqrt ((q : ℝ) ^ n) : ℂ)) X f) ≤
      (((a * b : ℕ) : ℝ) / q) ^ n * energy X f := by
  refine' le_trans _ ( mul_le_mul_of_nonneg_right _ _ );
  convert oscillatory_restricted_energy_bound phase X Y f ( q ^ n ) ( by positivity ) using 1;
  · convert div_le_div_of_nonneg_right ( mul_le_mul ( Nat.cast_le.mpr hX ) ( Nat.cast_le.mpr hY ) ?_ ?_ ) ( by positivity : ( 0 : ℝ ) ≤ q ^ n ) using 1 <;> norm_num ; ring;
  · exact Finset.sum_nonneg fun _ _ => sq_nonneg _

/-
In the strong-porosity range `a*b < q`, the uncertainty factor is strictly
less than one at every positive depth.
-/
theorem porous_decay_factor_lt_one {a b q n : ℕ}
    (hn : 0 < n) (hab : a * b < q) :
    (((a * b : ℕ) : ℝ) / q) ^ n < 1 := by
  exact pow_lt_one₀ ( by positivity ) ( by rw [ div_lt_one ( Nat.cast_pos.mpr <| pos_of_gt hab ) ] ; exact_mod_cast hab ) ( by positivity )

/-- At depth three in a five-ary residue tree, two supports with at most two
children per node have restricted energy factor `64/125`. -/
theorem quintic_depth_three_uncertainty {α β : Type*}
    (phase : β → α → ℝ) (X : Finset α) (Y : Finset β) (f : α → ℂ)
    (hX : X.card ≤ 2 ^ 3) (hY : Y.card ≤ 2 ^ 3) :
    energy Y (restrictedTransform
      (fun y x => Complex.exp (phase y x * Complex.I) /
        (Real.sqrt ((5 : ℝ) ^ 3) : ℂ)) X f) ≤
      (64 / 125 : ℝ) * energy X f := by
  convert porous_fractal_uncertainty phase X Y f 2 2 5 3 (by norm_num) hX hY using 1 <;>
    norm_num

-- !-- Lab Notes -- !--
/-
Hypothesis: prime-power self-similarity in non-Archimedean harmonic analysis
should align with Frobenius self-similarity in additive dynamics.
Experiment: compare the depth parameter `p^k` with the exact two-ray
renormalization identity for the additive cellular automaton.
Analysis: both phenomena are controlled by the same prime-power filtration;
one bounds concentration while the other identifies exact propagation scales.
Critique: this bridge identifies a shared scale hierarchy, not an equivalence
between the two theories.
Synthesis: the conjunction below records both independently proved effects at
one common prime-power scale.

Prime-power scale synthesis: Frobenius gives two exact light rays, while
strongly porous supports obey the finite-scale uncertainty estimate.
-/
theorem prime_power_scale_synthesis (p k : ℕ) [Fact p.Prime]
    {α β : Type*} (phase : β → α → ℝ) (X : Finset α) (Y : Finset β)
    (f : α → ℂ) (a b : ℕ) (hX : X.card ≤ a ^ (p ^ k))
    (hY : Y.card ≤ b ^ (p ^ k)) :
    AdditiveCA.caOp p ^ (p ^ k) =
        LaurentPolynomial.T ((p : ℤ) ^ k) + LaurentPolynomial.T (-((p : ℤ) ^ k)) ∧
    energy Y (restrictedTransform
      (fun y x => Complex.exp (phase y x * Complex.I) /
        (Real.sqrt ((p : ℝ) ^ (p ^ k)) : ℂ)) X f) ≤
      (((a * b : ℕ) : ℝ) / p) ^ (p ^ k) * energy X f := by
  refine' ⟨ _, porous_fractal_uncertainty phase X Y f a b p ( p ^ k ) ( Nat.Prime.pos Fact.out ) _ _ ⟩ <;> norm_cast;
  convert AdditiveCA.caOp_renorm p k using 1

end

-- !-- Lab Notes -- !--
/-
Hypothesis (ranked by expected impact):
1. [Famous-open subtask] A local-field fractal uncertainty exponent implies a
   quantitative discretized Kakeya estimate for product-type tubes.
2. [Famous-open subtask] Prime-power sum-product expansion yields new finite-field
   incidence bounds relevant to the Kakeya conjecture.
3. [Famous-open subtask] An adelic uncertainty inequality can transfer spectral
   gaps between real and non-Archimedean arithmetic quotients, a restricted
   route toward Selberg-type eigenvalue conjectures.
4. [Cross-domain bridge] Porous Fourier decay and Frobenius cellular-automaton
   renormalization possess a common transfer-operator formulation.
5. [Cross-domain bridge] Additive energy on residue trees controls both Fourier
   concentration and ultrametric coding robustness.
6. [Cross-domain bridge] Entropic porosity gives uncertainty exponents stable
   under stochastic deletion of residue classes.
Experiment: the present cycle tested the cardinality-only mechanism first.  It
proved the Hilbert--Schmidt kernel estimate, iterated tree cardinality bounds,
the strong-porosity fractal estimate, a concrete quintic instance, and a
prime-power bridge to exact Frobenius renormalization.
Analysis: conjectures 1--3 remain true-or-hard targets requiring incidence or
spectral infrastructure.  Conjectures 4--6 need definitions beyond cardinality
porosity.  The surviving structural pattern is multiplicative scale loss:
branching losses multiply across the two supports while normalization contributes
one inverse ambient branching factor at each depth.
Critique: the full porous-set theorem for arbitrary fixed porosity is not proved
here.  When `a*b ≥ q`, cardinality and Hilbert--Schmidt estimates do not contract;
cancellation or additive-energy decay is indispensable.  All stated results
respect this boundary, and the concrete factor `64/125` is obtained from the
general theorem rather than by isolated computation.
Synthesis: the selected completed target serves the cross-domain-bridge category.
It combines finite harmonic analysis, ultrametric tree combinatorics, and
prime-characteristic dynamics, while recording the exact threshold at which the
elementary method ceases to prove decay.
-/

end PadicFractalUncertainty