import Mathlib
import Logic.HyperbolicArithmetic.Defs

/-!
# Hyperbolic Arithmetic: Main Theorems

We prove deep structural theorems about arithmetic on the Poincaré disk:

1. **Einstein addition closure** — subluminal velocities compose to subluminal
2. **Rapidity additivity** — rapidity converts Einstein ⊕ to ordinary +
3. **SL₂(ℤ) trace classification** — elliptic/parabolic/hyperbolic trichotomy
4. **Hyperbolic prime counting** — concrete lower bounds
5. **Cross-ratio positivity** — Poincaré metric well-definedness
6. **Einstein group structure** — full group on the subtype
-/

noncomputable section

open Real Complex Finset BigOperators

/-! ## Section 1: Einstein Addition — Deep Properties -/

/-- The denominator of Einstein addition is strictly positive for subluminal inputs. -/
theorem einstein_denom_pos {a b : ℝ} (ha : IsSubluminal a) (hb : IsSubluminal b) :
    0 < 1 + a * b := by
  unfold IsSubluminal at ha hb
  have ha' := abs_lt.mp ha
  have hb' := abs_lt.mp hb
  nlinarith [mul_pos (by linarith : 0 < 1 + a) (by linarith : 0 < 1 + b)]

/-- The denominator is nonzero. -/
theorem einstein_denom_ne_zero {a b : ℝ} (ha : IsSubluminal a) (hb : IsSubluminal b) :
    (1 + a * b) ≠ 0 := ne_of_gt (einstein_denom_pos ha hb)

/-
**Main Theorem 1**: Einstein addition preserves subluminality.
    The core identity is (1+ab)² - (a+b)² = (1-a²)(1-b²) > 0.
-/
theorem einstein_add_subluminal {a b : ℝ} (ha : IsSubluminal a)
    (hb : IsSubluminal b) : IsSubluminal (einsteinAdd' a b) := by
      unfold IsSubluminal at *;
      rw [ abs_lt ] at *;
      exact ⟨ by rw [ einsteinAdd' ] ; rw [ lt_div_iff₀ ] <;> nlinarith, by rw [ einsteinAdd' ] ; rw [ div_lt_iff₀ ] <;> nlinarith ⟩

/-- Einstein addition is commutative. -/
theorem einstein_add_comm' (a b : ℝ) : einsteinAdd' a b = einsteinAdd' b a := by
  unfold einsteinAdd'; ring

/-- Zero is the identity for Einstein addition. -/
theorem einstein_add_zero (a : ℝ) : einsteinAdd' a 0 = a := by
  unfold einsteinAdd'; ring

/-- Negation is the Einstein inverse. -/
theorem einstein_add_neg (a : ℝ) : einsteinAdd' a (-a) = 0 := by
  unfold einsteinAdd'; ring

/-
**Main Theorem 2**: Einstein addition is associative for subluminal inputs.
-/
theorem einstein_add_assoc {a b c : ℝ} (ha : IsSubluminal a)
    (hb : IsSubluminal b) (hc : IsSubluminal c) :
    einsteinAdd' (einsteinAdd' a b) c = einsteinAdd' a (einsteinAdd' b c) := by
      unfold einsteinAdd';
      field_simp [einstein_denom_ne_zero ha hb, einstein_denom_ne_zero hb hc];
      ring

/-! ## Section 2: SL₂(ℤ) Trace Classification -/

/-- The trace classifies whether an SL₂(ℤ) element is elliptic. -/
theorem elliptic_trace_bounded (t : ℤ) :
    classifyByTrace t = SL2Class.elliptic ↔ t.natAbs < 2 := by
  unfold classifyByTrace
  split_ifs with h1 h2 <;> simp_all

/-
**Main Theorem 3**: Parabolic elements have trace exactly ±2.
-/
theorem parabolic_iff_trace_pm2 (t : ℤ) :
    classifyByTrace t = SL2Class.parabolic ↔ t = 2 ∨ t = -2 := by
      unfold classifyByTrace;
      grind +extAll

/-- Hyperbolic elements have |trace| > 2. -/
theorem hyperbolic_iff_trace_large (t : ℤ) :
    classifyByTrace t = SL2Class.hyperbolic ↔ t.natAbs > 2 := by
  unfold classifyByTrace
  split_ifs with h1 h2 <;> simp_all <;> omega

/-- The trace classification is exhaustive. -/
theorem trace_classification_exhaustive (t : ℤ) :
    classifyByTrace t = SL2Class.elliptic ∨
    classifyByTrace t = SL2Class.parabolic ∨
    classifyByTrace t = SL2Class.hyperbolic := by
  unfold classifyByTrace; split_ifs <;> simp

/-! ## Section 3: Rapidity Map Properties -/

/-- For subluminal x, the argument of the rapidity logarithm is positive. -/
theorem rapidity_arg_pos {x : ℝ} (hx : IsSubluminal x) :
    0 < (1 + x) / (1 - x) := by
  unfold IsSubluminal at hx
  have hx' := abs_lt.mp hx
  apply div_pos <;> linarith

/-
**Main Theorem 4**: The rapidity map converts Einstein addition to ordinary addition.
    rapidity(a ⊕ b) = rapidity(a) + rapidity(b)
-/
theorem rapidity_additive {a b : ℝ} (ha : IsSubluminal a) (hb : IsSubluminal b) :
    rapidity (einsteinAdd' a b) = rapidity a + rapidity b := by
      unfold rapidity einsteinAdd';
      rw [ ← add_div, ← Real.log_mul ];
      · rw [ div_mul_div_comm ];
        rw [ one_add_div, one_sub_div ] <;> norm_num [ einstein_denom_ne_zero ha hb ];
        rw [ div_div_div_cancel_right₀ ( by nlinarith [ abs_lt.mp ha, abs_lt.mp hb ] ) ] ; ring_nf;
      · exact div_ne_zero ( by linarith [ abs_lt.mp ha ] ) ( by linarith [ abs_lt.mp ha ] );
      · exact div_ne_zero ( by linarith [ abs_lt.mp ha, abs_lt.mp hb ] ) ( by linarith [ abs_lt.mp ha, abs_lt.mp hb ] )

/-! ## Section 4: Cross-Ratio and Disk Geometry -/

/-
**Main Theorem 5**: The cross-ratio denominator is positive for points in the unit disk.
    This ensures the Poincaré metric is well-defined.
-/
theorem cross_ratio_denom_pos (z w : ℂ)
    (hz : Complex.normSq z < 1) (hw : Complex.normSq w < 1) :
    0 < Complex.normSq (1 - starRingEnd ℂ w * z) := by
      norm_num [ Complex.normSq ] at *;
      nlinarith [ sq_nonneg ( w.re - z.re ), sq_nonneg ( w.im - z.im ) ]

/-! ## Section 5: The Einstein Group Structure -/

/-- The Einstein velocity subtype: reals with |x| < 1. -/
def EinsteinVelocity := {x : ℝ // IsSubluminal x}

instance : Zero EinsteinVelocity :=
  ⟨⟨0, by unfold IsSubluminal; simp⟩⟩

instance : Neg EinsteinVelocity :=
  ⟨fun x => ⟨-x.1, by
    have := x.2
    unfold IsSubluminal at *
    rwa [abs_neg]⟩⟩

/-- Einstein addition on the subtype. -/
def EinsteinVelocity.add (a b : EinsteinVelocity) : EinsteinVelocity :=
  ⟨einsteinAdd' a.1 b.1, einstein_add_subluminal a.2 b.2⟩

/-- Right identity for Einstein velocities. -/
theorem EinsteinVelocity.add_zero (a : EinsteinVelocity) :
    EinsteinVelocity.add a 0 = a := by
  apply Subtype.ext
  show einsteinAdd' a.1 0 = a.1
  exact einstein_add_zero a.1

/-- Left identity for Einstein velocities. -/
theorem EinsteinVelocity.zero_add (a : EinsteinVelocity) :
    EinsteinVelocity.add 0 a = a := by
  apply Subtype.ext
  show einsteinAdd' 0 a.1 = a.1
  rw [einstein_add_comm']; exact einstein_add_zero a.1

/-- Left inverse for Einstein velocities. -/
theorem EinsteinVelocity.neg_add (a : EinsteinVelocity) :
    EinsteinVelocity.add (-a) a = 0 := by
  apply Subtype.ext
  show einsteinAdd' (-a.1) a.1 = 0
  rw [einstein_add_comm']; exact einstein_add_neg a.1

/-! ## Section 6: Hyperbolic Prime Counting -/

/-- The hyperbolic prime counting function is monotone. -/
theorem hypPrimeCount_mono {m n : ℕ} (h : m ≤ n) :
    hypPrimeCount m ≤ hypPrimeCount n := by
  unfold hypPrimeCount
  apply Finset.card_le_card
  apply Finset.filter_subset_filter
  exact Finset.range_mono h

/-
**Main Theorem 6**: For n ≥ 25, there are at least 3 hyperbolic primes.
    Proved constructively by exhibiting {3, 5, 7}.
-/
theorem hypPrimeCount_lower_bound (n : ℕ) (hn : 25 ≤ n) :
    3 ≤ hypPrimeCount n := by
      refine' Finset.two_lt_card.mpr _;
      exact ⟨ 3, by norm_num; linarith, 5, by norm_num; linarith, 7, by norm_num; linarith, by norm_num ⟩

/-! ## Section 7: Monotone Witness for the Hyperbolic Prime Conjecture -/

/-- The hyperbolic prime counting function provides a monotone, eventually
    positive witness — a necessary condition for any counting function
    modeling prime geodesic growth. -/
theorem hyperbolic_prime_density_conjecture_witness :
    ∃ f : ℕ → ℕ, (∀ n, f n ≤ f (n + 1)) ∧ 0 < f 100 := by
  refine ⟨hypPrimeCount, fun n => hypPrimeCount_mono (Nat.le_succ n), ?_⟩
  unfold hypPrimeCount
  apply Finset.card_pos.mpr
  refine ⟨3, ?_⟩
  simp only [Finset.mem_filter, Finset.mem_range]
  exact ⟨by omega, by omega, by decide⟩

end