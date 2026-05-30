/-
  # Hyperbolic Number Theory: Advanced Theorems

  Deeper results about hyperbolic arithmetic:
  - Trace theory for SL₂(ℝ) and Chebyshev polynomials
  - Hyperbolic distance symmetry and positivity
  - Totient sum growth (Farey sequence connection)
  - Cross-domain bridge: geometry ↔ number theory
-/

import Mathlib

open Real

/-! ## Core Definitions (self-contained for this module) -/

/-- A point in the Poincaré disk -/
structure DiskPt where
  x : ℝ
  y : ℝ
  mem_disk : x ^ 2 + y ^ 2 < 1

namespace DiskPt

noncomputable def normSq (p : DiskPt) : ℝ := p.x ^ 2 + p.y ^ 2

theorem normSq_nonneg (p : DiskPt) : 0 ≤ p.normSq := by unfold normSq; positivity

theorem one_sub_normSq_pos (p : DiskPt) : 0 < 1 - p.normSq := by
  have := p.mem_disk; unfold normSq; linarith

end DiskPt

/-- Modified hyperbolic distance -/
noncomputable def mhypDist (p q : DiskPt) : ℝ :=
  Real.log (1 + 2 * ((p.x - q.x) ^ 2 + (p.y - q.y) ^ 2) /
    ((1 - p.normSq) * (1 - q.normSq)))

/-- SL₂(ℝ) element for hyperbolic geometry -/
@[ext]
structure HypSL2 where
  a : ℝ
  b : ℝ
  c : ℝ
  d : ℝ
  det_eq : a * d - b * c = 1

namespace HypSL2

def one : HypSL2 where
  a := 1; b := 0; c := 0; d := 1; det_eq := by ring

noncomputable def mul (g h : HypSL2) : HypSL2 where
  a := g.a * h.a + g.b * h.c
  b := g.a * h.b + g.b * h.d
  c := g.c * h.a + g.d * h.c
  d := g.c * h.b + g.d * h.d
  det_eq := by nlinarith [g.det_eq, h.det_eq]

def inv (g : HypSL2) : HypSL2 where
  a := g.d; b := -g.b; c := -g.c; d := g.a
  det_eq := by nlinarith [g.det_eq]

noncomputable def trace (g : HypSL2) : ℝ := g.a + g.d

theorem mul_assoc (f g h : HypSL2) : mul (mul f g) h = mul f (mul g h) := by
  ext <;> simp [mul] <;> ring

theorem one_mul (g : HypSL2) : mul one g = g := by ext <;> simp [mul, one]
theorem mul_one (g : HypSL2) : mul g one = g := by ext <;> simp [mul, one]

theorem inv_mul (g : HypSL2) : mul (inv g) g = one := by
  ext <;> simp [mul, inv, one] <;> nlinarith [g.det_eq]

theorem mul_inv (g : HypSL2) : mul g (inv g) = one := by
  ext <;> simp [mul, inv, one] <;> nlinarith [g.det_eq]

noncomputable def pow (g : HypSL2) : ℕ → HypSL2
  | 0 => one
  | n + 1 => mul g (pow g n)

end HypSL2

/-! ## Deep Theorem 1: Trace discriminant (nlinarith with determinant) -/

/-- The trace discriminant classifies transformation type -/
theorem hypsl2_trace_discriminant (g : HypSL2) :
    g.trace ^ 2 - 4 = (g.a - g.d) ^ 2 + 4 * g.b * g.c := by
  unfold HypSL2.trace
  nlinarith [g.det_eq]

/-- Hyperbolic elements have positive discriminant -/
theorem hyperbolic_positive_discriminant (g : HypSL2) (htr : g.trace ^ 2 > 4) :
    (g.a - g.d) ^ 2 + 4 * g.b * g.c > 0 := by
  linarith [hypsl2_trace_discriminant g]

/-! ## Deep Theorem 2: Trace of square = trace² - 2 (Chebyshev identity) -/

/-- tr(g²) = tr(g)² - 2: the Chebyshev identity for SL₂ -/
theorem hypsl2_trace_sq (g : HypSL2) :
    (HypSL2.mul g g).trace = g.trace ^ 2 - 2 := by
  unfold HypSL2.trace HypSL2.mul
  nlinarith [g.det_eq]

/-- For hyperbolic g, |tr(g²)| ≥ |tr(g)| -/
theorem hypsl2_trace_sq_growth (g : HypSL2) (htr : g.trace ^ 2 ≥ 4) :
    (HypSL2.mul g g).trace ^ 2 ≥ g.trace ^ 2 := by
  rw [hypsl2_trace_sq]
  nlinarith [sq_nonneg (g.trace ^ 2 - 2), sq_nonneg g.trace]

/-! ## Deep Theorem 3: Distance positivity (rcases + calc) -/

theorem denom_pos' (p q : DiskPt) : 0 < (1 - p.normSq) * (1 - q.normSq) :=
  mul_pos p.one_sub_normSq_pos q.one_sub_normSq_pos

/-- Distinct points have positive hyperbolic distance -/
theorem mhypDist_pos_of_ne (p q : DiskPt) (hpq : p.x ≠ q.x ∨ p.y ≠ q.y) :
    0 < mhypDist p q := by
  unfold mhypDist
  apply Real.log_pos
  have hdp := denom_pos' p q
  have hnum : 0 < (p.x - q.x) ^ 2 + (p.y - q.y) ^ 2 := by
    rcases hpq with hx | hy
    · have : p.x - q.x ≠ 0 := sub_ne_zero.mpr hx
      have : 0 < (p.x - q.x) ^ 2 := by positivity
      linarith [sq_nonneg (p.y - q.y)]
    · have : p.y - q.y ≠ 0 := sub_ne_zero.mpr hy
      have : 0 < (p.y - q.y) ^ 2 := by positivity
      linarith [sq_nonneg (p.x - q.x)]
  calc 1 < 1 + 2 * ((p.x - q.x) ^ 2 + (p.y - q.y) ^ 2) /
           ((1 - p.normSq) * (1 - q.normSq)) := by
        apply lt_add_of_pos_right
        apply div_pos <;> linarith

/-- Hyperbolic distance is symmetric -/
theorem mhypDist_comm (p q : DiskPt) : mhypDist p q = mhypDist q p := by
  unfold mhypDist DiskPt.normSq
  ring_nf

/-- Hyperbolic distance to self is zero -/
theorem mhypDist_self (p : DiskPt) : mhypDist p p = 0 := by
  unfold mhypDist; simp [sub_self]

/-! ## Deep Theorem 4: Totient sum growth (induction + by_cases) -/

/-- Sum of Euler totients -/
def totientSumH : ℕ → ℕ
  | 0 => 0
  | n + 1 => totientSumH n + Nat.totient (n + 1)

/-- **Theorem (induction + by_cases)**: Σ_{k=1}^n φ(k) ≥ n -/
theorem totientSumH_ge (n : ℕ) (hn : 1 ≤ n) : n ≤ totientSumH n := by
  induction n with
  | zero => omega
  | succ n ih =>
    simp [totientSumH]
    by_cases h : n = 0
    · subst h; simp [totientSumH, Nat.totient]
    · have hn1 : 1 ≤ n := by omega
      specialize ih hn1
      have : 0 < Nat.totient (n + 1) := Nat.totient_pos.mpr (by omega)
      omega

/-! ## Deep Theorem 5: Power addition (induction) -/

/-- g^(m+n) = g^m · g^n -/
theorem hypsl2_pow_add (g : HypSL2) (m n : ℕ) :
    HypSL2.pow g (m + n) = HypSL2.mul (HypSL2.pow g m) (HypSL2.pow g n) := by
  induction m with
  | zero => simp [HypSL2.pow, HypSL2.one_mul]
  | succ m ih =>
    simp only [Nat.succ_add, HypSL2.pow]
    rw [ih, HypSL2.mul_assoc]

/-! ## Deep Theorem 6: Trace identities -/

/-- tr(g) = tr(g⁻¹) -/
theorem hypsl2_trace_inv (g : HypSL2) : (HypSL2.inv g).trace = g.trace := by
  unfold HypSL2.trace HypSL2.inv; ring

/-- tr(I) = 2 -/
theorem hypsl2_trace_one : HypSL2.one.trace = 2 := by
  unfold HypSL2.trace HypSL2.one; norm_num

/-! ## Cross-Domain Bridge: Number Theory ↔ Hyperbolic Geometry

For PSL(2,ℤ), congruence subgroups Γ(p) have index p³ - p
in SL₂(ℤ). The quantity p³ - p = p(p-1)(p+1) is always
divisible by 6, connecting modular curve geometry to
divisibility in number theory. -/

/-- For prime p, φ(p) · (p+1) = p² - 1.
    This connects totient (orbit count) to geometry (cusp count). -/
theorem totient_times_succ_prime (p : ℕ) (hp : Nat.Prime p) :
    Nat.totient p * (p + 1) + 1 = p * p := by
  rw [Nat.totient_prime hp]
  have h2 := hp.two_le
  zify [show 1 ≤ p by omega] at *
  ring

/-- p(p²-1) is divisible by 6 for p ≥ 2.
    This gives the index of congruence subgroups. -/
theorem index_divisible_by_six (p : ℕ) (hp : 2 ≤ p) : 6 ∣ p * (p ^ 2 - 1) := by
  have hp1 : 1 ≤ p := by omega
  have hpp : p ^ 2 - 1 = (p - 1) * (p + 1) := by
    zify [hp1, show 1 ≤ p ^ 2 from by nlinarith]; ring
  rw [hpp]
  have : p * ((p - 1) * (p + 1)) = (p - 1) * p * (p + 1) := by ring
  rw [this]
  have hdf : (p + 1).descFactorial 3 = (p + 1) * p * (p - 1) := by
    simp [Nat.descFactorial]; ring
  have heq : (p - 1) * p * (p + 1) = (p + 1).descFactorial 3 := by
    rw [hdf]; ring
  rw [heq, Nat.descFactorial_eq_factorial_mul_choose]
  exact dvd_mul_right _ _

/-! ## Falsifiable Conjecture

**Conjecture**: For PSL(2,ℤ) acting on the disk, the number N(R) of orbit
points within hyperbolic radius R satisfies N(R)/e^R → 3/π as R → ∞.

**Test**: Compute orbit of (0,0) under generators S=[[0,-1],[1,0]] and
T=[[1,1],[0,1]], count points within radius R for R=1,...,10, plot N(R)/e^R.
If it doesn't converge to ≈0.955, the conjecture is false. -/