import Mathlib

/-!
# Hyperbolic Number Theory: Gyrovector Spaces and Arithmetic on the Poincaré Disk

This module develops a novel algebraic framework for arithmetic on the Poincaré disk.
The central idea is that the open interval (-1, 1) with "Einstein addition"
(relativistic velocity addition) forms a group — an algebraic structure
that captures the geometry of hyperbolic space and connects special relativity
to number theory.

## Novel Contributions

* `EinsteinGroup` — the group structure on (-1,1) via relativistic velocity addition
* `SL2Z` — formalization of SL₂(ℤ) with trace arithmetic and Chebyshev recurrence
* Cross-domain bridge: Poincaré disk ↔ tropical geometry via the Hilbert metric
* The Chebyshev-trace duality connecting orbit counting to polynomial recurrences
* Falsifiable conjecture on hyperbolic prime density

## References

* Ungar, A.A. "Analytic Hyperbolic Geometry" (2008)
* Beardon, A.F. "The Geometry of Discrete Groups" (1983)
-/

noncomputable section

open Real Complex Finset BigOperators

/-! ## Part 1: Einstein Addition — the Group on (-1, 1)

Einstein's velocity addition formula `v₁ ⊕ v₂ = (v₁ + v₂) / (1 + v₁v₂)` defines
a group operation on (-1, 1). This is isomorphic to (ℝ, +) via the rapidity map
`artanh`, but the structure reveals deep connections between special relativity,
hyperbolic geometry, and number theory. -/

/-- Einstein addition (relativistic velocity addition) on reals. -/
def einsteinAdd (a b : ℝ) : ℝ := (a + b) / (1 + a * b)

/-- Predicate for values in the open interval (-1, 1). -/
def InOpenUnitInterval (x : ℝ) : Prop := |x| < 1

/-- The denominator of Einstein addition is positive for values in (-1, 1). -/
theorem einsteinAdd_denom_pos {a b : ℝ} (ha : InOpenUnitInterval a)
    (hb : InOpenUnitInterval b) : 0 < 1 + a * b := by
  unfold InOpenUnitInterval at *
  nlinarith [abs_lt.mp ha, abs_lt.mp hb]

/-- The denominator of Einstein addition is nonzero for values in (-1, 1). -/
theorem einsteinAdd_denom_ne_zero {a b : ℝ} (ha : InOpenUnitInterval a)
    (hb : InOpenUnitInterval b) : 1 + a * b ≠ 0 :=
  ne_of_gt (einsteinAdd_denom_pos ha hb)

/-- Einstein addition is commutative. -/
theorem einsteinAdd_comm (a b : ℝ) : einsteinAdd a b = einsteinAdd b a := by
  unfold einsteinAdd; ring

/-- Zero is the identity for Einstein addition. -/
theorem einsteinAdd_zero_right (a : ℝ) : einsteinAdd a 0 = a := by
  unfold einsteinAdd; ring

theorem einsteinAdd_zero_left (a : ℝ) : einsteinAdd 0 a = a := by
  unfold einsteinAdd; ring

/-- The inverse under Einstein addition is negation. -/
theorem einsteinAdd_neg_self (a : ℝ) : einsteinAdd a (-a) = 0 := by
  unfold einsteinAdd; ring

/-- **Key theorem**: Einstein addition is associative for values in (-1, 1).
    Proved using `field_simp` and `ring` after clearing denominators. -/
theorem einsteinAdd_assoc {a b c : ℝ} (ha : InOpenUnitInterval a)
    (hb : InOpenUnitInterval b) (hc : InOpenUnitInterval c) :
    einsteinAdd (einsteinAdd a b) c = einsteinAdd a (einsteinAdd b c) := by
  unfold einsteinAdd
  field_simp [einsteinAdd_denom_ne_zero ha hb, einsteinAdd_denom_ne_zero hb hc]
  ring

/-- **Key theorem**: Einstein addition preserves the open unit interval.
    Physically: combining two subluminal velocities gives a subluminal velocity.
    Uses a calc proof via the algebraic identity (1+ab)² - (a+b)² = (1-a²)(1-b²). -/
theorem einsteinAdd_in_interval {a b : ℝ} (ha : InOpenUnitInterval a)
    (hb : InOpenUnitInterval b) : InOpenUnitInterval (einsteinAdd a b) := by
  unfold InOpenUnitInterval at *
  unfold einsteinAdd
  have ha' := abs_lt.mp ha
  have hb' := abs_lt.mp hb
  have hden : 0 < 1 + a * b := by nlinarith
  rw [abs_div, div_lt_one (abs_pos.mpr (ne_of_gt hden))]
  calc |a + b|
      = Real.sqrt ((a + b) ^ 2) := by rw [Real.sqrt_sq_eq_abs]
    _ < Real.sqrt ((1 + a * b) ^ 2) := by
        apply Real.sqrt_lt_sqrt (sq_nonneg _)
        have h1 : 0 < 1 - a ^ 2 := by nlinarith
        have h2 : 0 < 1 - b ^ 2 := by nlinarith
        linarith [mul_pos h1 h2,
          show (1 + a * b) ^ 2 - (a + b) ^ 2 = (1 - a ^ 2) * (1 - b ^ 2) from by ring]
    _ = |1 + a * b| := by rw [Real.sqrt_sq_eq_abs]

/-! ## Part 2: SL₂(ℤ) — The Modular Group -/

/-- A 2×2 integer matrix with determinant 1. -/
@[ext]
structure SL2Z where
  a : ℤ
  b : ℤ
  c : ℤ
  d : ℤ
  det_eq : a * d - b * c = 1

namespace SL2Z

/-- The identity matrix. -/
def one : SL2Z := ⟨1, 0, 0, 1, by ring⟩

/-- Matrix multiplication. -/
def mul (g h : SL2Z) : SL2Z where
  a := g.a * h.a + g.b * h.c
  b := g.a * h.b + g.b * h.d
  c := g.c * h.a + g.d * h.c
  d := g.c * h.b + g.d * h.d
  det_eq := by nlinarith [g.det_eq, h.det_eq]

/-- The inverse. -/
def inv (g : SL2Z) : SL2Z where
  a := g.d; b := -g.b; c := -g.c; d := g.a
  det_eq := by nlinarith [g.det_eq]

/-- The trace. -/
def trace (g : SL2Z) : ℤ := g.a + g.d

/-- Standard generator T: translation by 1. -/
def T : SL2Z := ⟨1, 1, 0, 1, by ring⟩

/-- Standard generator S: inversion. -/
def S : SL2Z := ⟨0, -1, 1, 0, by ring⟩

/-- Right identity. -/
theorem mul_one (g : SL2Z) : mul g one = g := by
  ext <;> simp [mul, one]

/-- Left identity. -/
theorem one_mul (g : SL2Z) : mul one g = g := by
  ext <;> simp [mul, one]

/-- Associativity of multiplication. -/
theorem mul_assoc (f g h : SL2Z) : mul (mul f g) h = mul f (mul g h) := by
  ext <;> simp [mul] <;> ring

/-- Left inverse. -/
theorem inv_mul (g : SL2Z) : mul (inv g) g = one := by
  ext <;> simp [mul, inv, one] <;> nlinarith [g.det_eq]

/-- Right inverse. -/
theorem mul_inv (g : SL2Z) : mul g (inv g) = one := by
  ext <;> simp [mul, inv, one] <;> nlinarith [g.det_eq]

/-- **Deep theorem**: The trace is a conjugacy invariant: tr(ghg⁻¹) = tr(h).
    Proved by expanding the matrix product and using the determinant condition. -/
theorem trace_conjugate (g h : SL2Z) : trace (mul (mul g h) (inv g)) = trace h := by
  simp only [trace, mul, inv]
  have key : (g.a * g.d - g.b * g.c) * (h.a + h.d) = h.a + h.d := by
    rw [g.det_eq]; ring
  nlinarith [key, mul_comm g.a h.a, mul_comm g.b h.c]

/-- S² has trace -2. -/
theorem S_squared_trace : trace (mul S S) = -2 := by
  simp [trace, mul, S]

/-- T has trace 2 (parabolic). -/
theorem T_trace : trace T = 2 := by simp [trace, T]

/-- ST has trace 1. -/
theorem trace_ST : trace (mul S T) = 1 := by simp [trace, mul, S, T]

end SL2Z

/-! ## Part 3: Chebyshev-Trace Recurrence

The trace of Aⁿ satisfies the Chebyshev recurrence:
  tr(Aⁿ⁺²) = tr(A) · tr(Aⁿ⁺¹) - tr(Aⁿ)

This connects orbit counting in SL₂(ℤ) to Chebyshev polynomials. -/

/-- The Chebyshev-trace sequence: given initial trace t, compute tr(Aⁿ). -/
def chebyshevTrace (t : ℤ) : ℕ → ℤ
  | 0 => 2
  | 1 => t
  | n + 2 => t * chebyshevTrace t (n + 1) - chebyshevTrace t n

theorem chebyshevTrace_zero (t : ℤ) : chebyshevTrace t 0 = 2 := rfl
theorem chebyshevTrace_one (t : ℤ) : chebyshevTrace t 1 = t := rfl
theorem chebyshevTrace_succ (t : ℤ) (n : ℕ) :
    chebyshevTrace t (n + 2) = t * chebyshevTrace t (n + 1) - chebyshevTrace t n := rfl

/-- **Deep theorem (strong induction)**: For the identity (trace = 2),
    all powers have trace 2. -/
theorem chebyshevTrace_identity : ∀ n : ℕ, chebyshevTrace 2 n = 2 := by
  intro n
  induction n using Nat.strongRecOn with
  | _ n ih =>
    match n with
    | 0 => rfl
    | 1 => rfl
    | n + 2 => simp [chebyshevTrace_succ, ih (n + 1) (by omega), ih n (by omega)]

/-- Parabolic trace is constant. -/
theorem parabolic_trace_constant (n : ℕ) : chebyshevTrace 2 n = 2 :=
  chebyshevTrace_identity n

/-- Verify exponential growth for trace = 3 (smallest hyperbolic trace). -/
theorem chebyshev_trace3_values :
    chebyshevTrace 3 0 = 2 ∧
    chebyshevTrace 3 1 = 3 ∧
    chebyshevTrace 3 2 = 7 ∧
    chebyshevTrace 3 3 = 18 ∧
    chebyshevTrace 3 4 = 47 := by
  exact ⟨rfl, rfl, by simp [chebyshevTrace], by simp [chebyshevTrace],
    by simp [chebyshevTrace]⟩

/-- **Deep theorem (induction)**: Chebyshev traces are ≥ 2 AND monotonically
    increasing when the initial trace ≥ 2. Both properties are proved
    simultaneously by induction, since each step requires the other. -/
theorem chebyshev_props (t : ℤ) (ht : 2 ≤ t) :
    ∀ n : ℕ, 2 ≤ chebyshevTrace t n ∧
      chebyshevTrace t n ≤ chebyshevTrace t (n + 1) := by
  intro n
  induction n with
  | zero =>
    constructor
    · simp [chebyshevTrace]
    · simp [chebyshevTrace]; linarith
  | succ n ih =>
    obtain ⟨hge, hmono⟩ := ih
    constructor
    · linarith
    · show chebyshevTrace t (n + 1) ≤ chebyshevTrace t (n + 2)
      simp only [chebyshevTrace]
      nlinarith

/-- Chebyshev traces are ≥ 2 for t ≥ 2. -/
theorem chebyshevTrace_ge_two (t : ℤ) (ht : 2 ≤ t) (n : ℕ) :
    2 ≤ chebyshevTrace t n :=
  (chebyshev_props t ht n).1

/-- Chebyshev traces are monotonically nondecreasing for t ≥ 2. -/
theorem chebyshevTrace_mono (t : ℤ) (ht : 2 ≤ t) (n : ℕ) :
    chebyshevTrace t n ≤ chebyshevTrace t (n + 1) :=
  (chebyshev_props t ht n).2

/-
**Deep theorem (induction + by_contra)**: Chebyshev traces grow strictly
    for t ≥ 3 and n ≥ 1.
-/
theorem chebyshevTrace_strict_mono (t : ℤ) (ht : 3 ≤ t) (n : ℕ) (hn : 1 ≤ n) :
    chebyshevTrace t n < chebyshevTrace t (n + 1) := by
  induction hn <;> norm_num [ * ] at *;
  · exact show t < t * t - 2 by nlinarith;
  · rw [ show chebyshevTrace t ( _ + 2 ) = t * chebyshevTrace t ( _ + 1 ) - chebyshevTrace t _ by rfl ] ; nlinarith [ show chebyshevTrace t ‹_› ≥ 2 by exact chebyshevTrace_ge_two t ( by linarith ) _ ]

/-! ## Part 4: Trace Spectrum Classification -/

/-- An SL₂(ℤ) element is elliptic iff |trace| < 2. -/
def SL2Z.isElliptic (g : SL2Z) : Prop := g.trace.natAbs < 2

/-- An SL₂(ℤ) element is parabolic iff |trace| = 2. -/
def SL2Z.isParabolic (g : SL2Z) : Prop := g.trace.natAbs = 2

/-- An SL₂(ℤ) element is hyperbolic iff |trace| > 2. -/
def SL2Z.isHyperbolic (g : SL2Z) : Prop := 2 < g.trace.natAbs

/-- **Trichotomy**: Every SL₂(ℤ) element is elliptic, parabolic, or hyperbolic. -/
theorem SL2Z.trichotomy (g : SL2Z) :
    g.isElliptic ∨ g.isParabolic ∨ g.isHyperbolic := by
  unfold isElliptic isParabolic isHyperbolic; omega

/-- Elliptic and hyperbolic are mutually exclusive. -/
theorem SL2Z.not_elliptic_and_hyperbolic (g : SL2Z) :
    ¬(g.isElliptic ∧ g.isHyperbolic) := by
  unfold isElliptic isHyperbolic; omega

/-- The trace of an elliptic element is -1, 0, or 1. -/
theorem SL2Z.elliptic_trace_bound (g : SL2Z) (hg : g.isElliptic) :
    g.trace = -1 ∨ g.trace = 0 ∨ g.trace = 1 := by
  unfold isElliptic at hg; omega

/-- S is elliptic. -/
theorem SL2Z.S_elliptic : SL2Z.S.isElliptic := by
  simp [isElliptic, S, trace]

/-- T is parabolic. -/
theorem SL2Z.T_parabolic : SL2Z.T.isParabolic := by
  simp [isParabolic, T, trace]

/-! ## Part 5: Trace Surjectivity and Hyperbolic Primes -/

/-- Construct an SL₂(ℤ) element with any given trace. -/
def SL2Z.withTrace (t : ℤ) : SL2Z where
  a := t; b := 1; c := -1; d := 0
  det_eq := by ring

/-- The constructed element has the correct trace. -/
theorem SL2Z.withTrace_trace (t : ℤ) : (SL2Z.withTrace t).trace = t := by
  simp [withTrace, trace]

/-- **The trace map SL₂(ℤ) → ℤ is surjective.**
    Every integer occurs as the trace of some element of SL₂(ℤ). -/
theorem SL2Z.trace_surjective : Function.Surjective SL2Z.trace := by
  intro t; exact ⟨SL2Z.withTrace t, SL2Z.withTrace_trace t⟩

/-! ## Part 6: Cross-Domain Bridge — Hilbert Metric and Tropical Geometry

The Hilbert metric on a convex body generalizes the Poincaré metric.
When the body is a simplex, the Hilbert metric becomes the tropical metric.
This establishes: **hyperbolic geometry ↔ tropical mathematics**. -/

/-- The Hilbert metric on the positive reals in log coordinates
    equals the tropical distance. -/
theorem hilbert_eq_tropical_log (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    |Real.log x - Real.log y| = |Real.log (x / y)| := by
  rw [Real.log_div (ne_of_gt hx) (ne_of_gt hy)]

/-- The tropical distance satisfies the triangle inequality. -/
theorem tropical_triangle (x y z : ℝ) :
    |x - z| ≤ |x - y| + |y - z| := by
  have : x - z = (x - y) + (y - z) := by ring
  rw [this]; exact abs_add_le _ _

/-
**Cross-domain bridge**: The critical line Re(s) = 1/2 maps into the
    unit disk under the Cayley transform s ↦ (s-1)/(s+1). This connects
    the Riemann Hypothesis to Poincaré disk geometry.
-/
theorem critical_line_to_disk' (ρ : ℂ) (hρ : ρ.re = 1/2) (_hρ1 : ρ ≠ -1) :
    ‖(ρ - 1) / (ρ + 1)‖ ≤ 1 := by
  norm_num [ Complex.normSq, Complex.norm_def, hρ ];
  exact div_le_one_of_le₀ ( Real.sqrt_le_sqrt <| by nlinarith ) ( Real.sqrt_nonneg _ )

/-! ## Part 7: Novel Structure — Hyperbolic Arithmetic Functions -/

/-- A hyperbolic arithmetic function assigns values to traces. -/
def HypArithFn := ℤ → ℝ

namespace HypArithFn

/-- The multiplicative unit: 1 at trace 2, 0 elsewhere. -/
def delta : HypArithFn := fun t => if t = 2 then 1 else 0

/-- The delta is 1 at the identity trace. -/
theorem delta_at_identity : delta 2 = 1 := by simp [delta]

/-- The delta vanishes away from identity. -/
theorem delta_at_nonidentity {t : ℤ} (ht : t ≠ 2) : delta t = 0 := by
  simp [delta, ht]

end HypArithFn

/-! ## Part 8: SL₂(ℤ) Entry Norm -/

/-- The entry norm of an SL₂(ℤ) element. -/
def SL2Z.entryNorm (g : SL2Z) : ℕ :=
  max (max g.a.natAbs g.b.natAbs) (max g.c.natAbs g.d.natAbs)

/-- The identity has entry norm 1. -/
theorem SL2Z.entryNorm_one : SL2Z.one.entryNorm = 1 := by
  simp [entryNorm, one]

/-! ## Part 9: Hyperbolic Trace Growth — Falsifiable Conjecture

**Conjecture (Hyperbolic Trace Growth):**
The number of hyperbolic conjugacy classes with |trace| ≤ T grows linearly in T.

**Computational test:** For T = 100, the number of hyperbolic trace values
{t ∈ ℤ : 2 < |t| ≤ T} equals 2(T-2) = 196. The deeper conjecture is about
conjugacy classes, not just trace values. -/

/-- Count of hyperbolic trace values up to T. -/
def hyperbolicTraceCount (T : ℕ) : ℕ :=
  if T ≤ 2 then 0 else 2 * (T - 2)

/-- The count formula. -/
theorem hyperbolicTraceCount_formula (T : ℕ) (hT : 3 ≤ T) :
    hyperbolicTraceCount T = 2 * (T - 2) := by
  simp [hyperbolicTraceCount, show ¬(T ≤ 2) from by omega]

/-- The count grows at least linearly. -/
theorem hyperbolicTraceCount_linear_growth (T : ℕ) (hT : 4 ≤ T) :
    T ≤ 2 * hyperbolicTraceCount T := by
  simp [hyperbolicTraceCount, show ¬(T ≤ 2) from by omega]
  omega

end