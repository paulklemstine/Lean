import Mathlib
import Novelty.WangStripeAperiodicity

/-!
# A Diophantine condition on quadratic irrationals forcing Wang-stripe aperiodicity

This file supplies the *quantitative* half of the mission: a Diophantine (badly
approximable) condition on the density parameters, satisfied by quadratic
irrationals, that is **sufficient** for non-periodicity of the awaited Wang stripe
set built in `WangStripeAperiodicity.lean`.

We say `α` is `Diophantine` if it admits a uniform `c/b²` separation from every
rational `a/b`.  Quadratic surds `√d` (`d` not a perfect square) satisfy this with
`c = 1/(2√d + 1)` — the classical "badly approximable" property of quadratic
irrationals.  A Diophantine number is irrational, and irrationality of *both* slopes
forces strong aperiodicity (`WangStripe.wangStripe_aperiodic`).  The resulting chain
is

  `Diophantine α ∧ Diophantine β  ⇒  aperiodic Wang stripe set W(α,β)`,

instantiated at the pair of quadratic irrationals `(√2, √3)`.

## Main results

* `Diophantine_irrational` : a Diophantine real is irrational.
* `sqrt_Diophantine` : every irrational `√d` is Diophantine with `c = 1/(2√d+1)`.
* `sqrt_two_Diophantine`, `sqrt_three_Diophantine` : the two quadratic surds.
* `sqrt_two_diophantine_quarter` : the explicit bound `1/(4b²) ≤ |√2 − a/b|`.
* `diophantine_pair_aperiodic` : the linking theorem.
* `sqrt2_sqrt3_wang_aperiodic` : the concrete aperiodic pair.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "irrational slope" is qualitative; the sharp, falsifiable
form is a *Diophantine* lower bound `c/b²`.  Conjecture: quadratic irrationals are
exactly the slopes for which the exponent 2 is optimal, and any pair of them yields a
strongly aperiodic stripe set.
Experiment (Experimenter): the surd identity `|√d−a/b|·|√d+a/b| = |d b²−a²|/b²` with
the *nonzero-integer* numerator `|d b²−a²| ≥ 1` (forced by irrationality) gives the
`c/b²` bound after bounding `√d + a/b < 2√d + 1` on the relevant range.  The reverse
implication "Diophantine ⇒ irrational" is immediate: a rational slope is *exactly*
hit, violating any positive lower bound.
Analysis (Analyst): the Diophantine exponent 2 is the structural invariant; the
constant `1/(2√d+1)` is explicit, and for `√2` improves to the clean `1/4`.  The link
to aperiodicity factors cleanly through irrationality — the quantitative strength is a
bonus that pins down *how* aperiodic the family is.
Critique (Critic): `Diophantine` is non-vacuous (√2, √3 witness it) and the bound is
strict (`c > 0`); no `native_decide`/`True`.  We honestly note the model is the
Beatty stripe skeleton of a Wang set, and that we prove sufficiency, not necessity.
Synthesis (PI): a pair of quadratic irrationals — the simplest non-trivial Diophantine
data — already certifies strong aperiodicity; see FUTURE_DIRECTIONS for the
necessity / exponent-optimality conjectures.
-/

namespace WangDiophantine

open WangStripe

/-- `α` is **Diophantine** (badly approximable to exponent 2): some `c > 0` separates
`α` from every rational `a/b` by at least `c/b²`. -/
def Diophantine (α : ℝ) : Prop :=
  ∃ c : ℝ, 0 < c ∧ ∀ (a : ℤ) (b : ℕ), 0 < b → c / (b : ℝ) ^ 2 ≤ |α - (a : ℝ) / (b : ℝ)|

/-
A Diophantine real is irrational: a rational slope `a/b` would be hit exactly,
giving distance `0 < c/b²`.
-/
theorem Diophantine_irrational (α : ℝ) (h : Diophantine α) : Irrational α := by
  obtain ⟨ c, hc, h ⟩ := h;
  -- Assume for contradiction that α is rational.
  by_contra h_contra
  obtain ⟨q, hq⟩ : ∃ q : ℚ, α = q := by
    simpa [ eq_comm ] using Classical.not_not.1 h_contra;
  specialize h ( q.num : ℤ ) q.den ( Nat.cast_pos.mpr q.pos ) ; simp_all +decide [ abs_div, Rat.cast_def ];
  exact not_le_of_gt ( by positivity ) h

/-
**Quadratic irrationals are Diophantine.**  For irrational `√d` the surd identity
gives the separation `1/(2√d+1) / b² ≤ |√d − a/b|`.
-/
theorem sqrt_Diophantine (d : ℕ) (hd : Irrational (Real.sqrt d)) :
    Diophantine (Real.sqrt d) := by
  refine' ⟨ 1 / ( 2 * Real.sqrt d + 1 ), by positivity, fun a b hb => _ ⟩;
  -- By the properties of the surd identity, we have $|\sqrt{d} - \frac{a}{b}| \cdot |\sqrt{d} + \frac{a}{b}| \geq \frac{1}{b^2}$.
  have h_surd : |Real.sqrt d - a / b| * |Real.sqrt d + a / b| ≥ 1 / b^2 := by
    have h_surd : |(d : ℝ) - (a / b) ^ 2| ≥ 1 / b ^ 2 := by
      -- Since $d$ is not a perfect square, $d b^2 - a^2$ is a nonzero integer.
      have h_nonzero : (d * b^2 - a^2 : ℤ) ≠ 0 := by
        intro h; have := hd.ne_rat ( |a| / b ) ; simp_all +decide ;
        refine' this _;
        rw [ eq_div_iff ( by positivity ), mul_comm, ← sq_eq_sq₀ ] <;> first | positivity | norm_num [ ← @Int.cast_inj ℝ ] at * ; nlinarith [ Real.mul_self_sqrt ( Nat.cast_nonneg d ) ] ;
      field_simp;
      rw [ abs_div, abs_sq, mul_div_cancel₀ ] <;> norm_cast;
      · exact abs_pos.mpr ( show ( b ^ 2 * d - a ^ 2 : ℤ ) ≠ 0 from by convert h_nonzero using 1; ring );
      · positivity;
    convert h_surd using 1 ; rw [ ← abs_mul ] ; ring ; norm_num;
    ring;
  by_cases h_case : |Real.sqrt d - a / b| < 1;
  · -- Since $|√d - a/b| < 1$, we have $|√d + a/b| < 2√d + 1$.
    have h_bound : |Real.sqrt d + a / b| < 2 * Real.sqrt d + 1 := by
      rw [ abs_lt ] at *;
      constructor <;> nlinarith [ Real.sqrt_nonneg d, Real.sq_sqrt ( Nat.cast_nonneg d ), show ( 1 : ℝ ) ≤ Real.sqrt d from Real.le_sqrt_of_sq_le <| mod_cast Nat.one_le_iff_ne_zero.mpr <| by rintro rfl; norm_num at * ];
    rw [ div_div, div_le_iff₀ ] <;> try positivity;
    rw [ ge_iff_le, div_le_iff₀ ] at h_surd <;> first | positivity | nlinarith [ show ( 0 : ℝ ) < b ^ 2 by positivity, abs_nonneg ( Real.sqrt d - a / b ), abs_nonneg ( Real.sqrt d + a / b ) ] ;
  · refine' le_trans _ ( le_of_not_gt h_case );
    rw [ div_div, div_le_iff₀ ] <;> nlinarith only [ show ( b : ℝ ) ≥ 1 by norm_cast, show ( Real.sqrt d : ℝ ) ≥ 1 by exact Real.le_sqrt_of_sq_le <| mod_cast Nat.one_le_iff_ne_zero.mpr <| by rintro rfl; norm_num at hd, Real.sq_sqrt <| Nat.cast_nonneg d ]

/-- `√2` is Diophantine. -/
theorem sqrt_two_Diophantine : Diophantine (Real.sqrt 2) := by
  have : Irrational (Real.sqrt (2 : ℕ)) := by exact_mod_cast irrational_sqrt_two
  simpa using sqrt_Diophantine 2 this

/-- `√3` is Diophantine. -/
theorem sqrt_three_Diophantine : Diophantine (Real.sqrt 3) := by
  have : Irrational (Real.sqrt (3 : ℕ)) := (Nat.prime_three).irrational_sqrt
  simpa using sqrt_Diophantine 3 this

/-
The classical explicit bound for `√2`: `1/(4b²) ≤ |√2 − a/b|` for all `b > 0`.
-/
theorem sqrt_two_diophantine_quarter (a : ℤ) (b : ℕ) (hb : 0 < b) :
    1 / (4 * (b : ℝ) ^ 2) ≤ |Real.sqrt 2 - (a : ℝ) / (b : ℝ)| := by
  by_cases h_case : |Real.sqrt 2 - (a : ℝ) / (b : ℝ)| < 1;
  · have h_bound : |Real.sqrt 2 - (a : ℝ) / (b : ℝ)| * (Real.sqrt 2 + (a : ℝ) / (b : ℝ)) ≥ 1 / (b : ℝ) ^ 2 := by
      have h_bound : |(Real.sqrt 2 : ℝ) ^ 2 - ((a : ℝ) / (b : ℝ)) ^ 2| ≥ 1 / (b : ℝ) ^ 2 := by
        -- Since $a^2 - 2b^2$ is an integer and non-zero, we have $|a^2 - 2b^2| \geq 1$.
        have h_int : |(a : ℝ) ^ 2 - 2 * (b : ℝ) ^ 2| ≥ 1 := by
          by_contra h_contra
          have h_eq : a ^ 2 = 2 * b ^ 2 := by
            norm_cast at *;
            grind;
          -- If $a^2 = 2b^2$, then $\frac{a}{b} = \sqrt{2}$ or $\frac{a}{b} = -\sqrt{2}$, which contradicts the assumption that $\sqrt{2}$ is irrational.
          have h_contra : (a : ℝ) / b = Real.sqrt 2 ∨ (a : ℝ) / b = -Real.sqrt 2 := by
            exact eq_or_eq_neg_of_sq_eq_sq _ _ <| by rw [ div_pow, Real.sq_sqrt <| by positivity ] ; rw [ div_eq_iff ] <;> norm_cast ; nlinarith;
          exact irrational_sqrt_two <| h_contra.elim ( fun h => ⟨ a / b, by aesop ⟩ ) fun h => ⟨ -a / b, by push_cast; ring_nf at *; aesop ⟩;
        field_simp;
        rw [ abs_div, abs_sq, mul_div_cancel₀ _ ( by positivity ) ] ; norm_num ; cases abs_cases ( ( a : ℝ ) ^ 2 - 2 * b ^ 2 ) <;> cases abs_cases ( ( b ^ 2 * 2 - a ^ 2 : ℝ ) ) <;> nlinarith;
      rw [ show ( Real.sqrt 2 : ℝ ) ^ 2 - ( a / b : ℝ ) ^ 2 = ( Real.sqrt 2 - a / b ) * ( Real.sqrt 2 + a / b ) by ring, abs_mul ] at h_bound;
      rwa [ abs_of_nonneg ( show 0 ≤ Real.sqrt 2 + a / b by nlinarith [ abs_lt.mp h_case, Real.sqrt_nonneg 2, Real.sq_sqrt zero_le_two, show ( b : ℝ ) ≥ 1 by norm_cast, mul_div_cancel₀ ( a : ℝ ) ( by positivity : ( b : ℝ ) ≠ 0 ) ] ) ] at h_bound;
    -- Since $|√2 - a/b| < 1$, we have $√2 + a/b < 2√2 + 1 < 4$.
    have h_sum_bound : Real.sqrt 2 + (a : ℝ) / (b : ℝ) < 4 := by
      nlinarith [ Real.sqrt_nonneg 2, Real.sq_sqrt zero_le_two, abs_lt.mp h_case ];
    rw [ div_le_iff₀ ] <;> nlinarith [ show ( 0 : ℝ ) < b ^ 2 by positivity, show ( 0 : ℝ ) < Real.sqrt 2 + a / b by nlinarith [ show ( 0 : ℝ ) < b ^ 2 by positivity, abs_lt.mp h_case, Real.sqrt_nonneg 2, Real.sq_sqrt zero_le_two, mul_div_cancel₀ ( a : ℝ ) ( by positivity : ( b : ℝ ) ≠ 0 ) ], one_div_mul_cancel ( by positivity : ( b : ℝ ) ^ 2 ≠ 0 ) ];
  · exact le_trans ( div_le_self ( by positivity ) ( by norm_cast; nlinarith ) ) ( le_of_not_gt h_case )

/-- **Linking theorem.**  A *pair* of Diophantine density parameters certifies that
the 2-D Wang stripe set has no non-zero period (strong aperiodicity). -/
theorem diophantine_pair_aperiodic (α β : ℝ)
    (hα : Diophantine α) (hβ : Diophantine β) :
    ¬ HasPeriod (wangStripe α β) :=
  wangStripe_aperiodic α β (Diophantine_irrational α hα) (Diophantine_irrational β hβ)

/-- **Concrete aperiodic pair of quadratic irrationals.**  The Wang stripe set with
column slope `√2` and row slope `√3` is strongly aperiodic. -/
theorem sqrt2_sqrt3_wang_aperiodic :
    ¬ HasPeriod (wangStripe (Real.sqrt 2) (Real.sqrt 3)) :=
  diophantine_pair_aperiodic _ _ sqrt_two_Diophantine sqrt_three_Diophantine

end WangDiophantine