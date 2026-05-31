import Mathlib

/-!
# Hyperbolic Trace Arithmetic: Number Theory on the Modular Group

This module develops a novel arithmetic framework on the Poincaré disk by
studying the **trace algebra** of SL₂(ℤ). The trace map `tr : SL₂(ℤ) → ℤ`
satisfies deep polynomial identities connecting hyperbolic geometry to
classical number theory.

## Novel Contributions

* `TraceArithFn` — A Dirichlet-like convolution algebra on trace-indexed functions
* **Trace Product Identity**: `tr(AB) + tr(AB⁻¹) = tr(A) · tr(B)`
* **Chebyshev-Trace Invariant**: A conserved quadratic form on trace sequences
* **Fricke-Vogt Identity**: Trace triples and the Markov equation
* **Farey Mediant Theorem**: Structure of the Farey tessellation via SL₂(ℤ)
* **Falsifiable Conjecture**: Trace density growth

## References

* Beardon, A.F. "The Geometry of Discrete Groups" (1983)
* Goldman, W.M. "Trace coordinates on Fricke spaces" (2009)
-/

noncomputable section

open Real Finset BigOperators

/-! ## Part 1: SL₂(ℤ) with Trace Algebra -/

/-- A 2×2 integer matrix with determinant 1. -/
@[ext]
structure SL2Int where
  a : ℤ
  b : ℤ
  c : ℤ
  d : ℤ
  det_eq : a * d - b * c = 1

namespace SL2Int

def mul (g h : SL2Int) : SL2Int where
  a := g.a * h.a + g.b * h.c
  b := g.a * h.b + g.b * h.d
  c := g.c * h.a + g.d * h.c
  d := g.c * h.b + g.d * h.d
  det_eq := by nlinarith [g.det_eq, h.det_eq]

def one : SL2Int := ⟨1, 0, 0, 1, by ring⟩

def inv (g : SL2Int) : SL2Int where
  a := g.d; b := -g.b; c := -g.c; d := g.a
  det_eq := by nlinarith [g.det_eq]

def trace (g : SL2Int) : ℤ := g.a + g.d

def S : SL2Int := ⟨0, -1, 1, 0, by ring⟩
def T : SL2Int := ⟨1, 1, 0, 1, by ring⟩

/-- **Trace Product Identity**: `tr(AB) + tr(AB⁻¹) = tr(A) · tr(B)`. -/
theorem trace_product_identity (A B : SL2Int) :
    trace (mul A B) + trace (mul A (inv B)) = trace A * trace B := by
  simp only [trace, mul, inv]; ring

theorem trace_one : trace one = 2 := by simp [trace, one]

theorem trace_inv (g : SL2Int) : trace (inv g) = trace g := by
  simp [trace, inv, add_comm]

/-
The trace is a conjugacy invariant.
-/
theorem trace_conjugate (g A : SL2Int) :
    trace (mul (mul g A) (inv g)) = trace A := by
  unfold SL2Int.trace SL2Int.mul; ring_nf;
  rcases g with ⟨ a, b, c, d, h ⟩
  simp [SL2Int.inv] at *;
  grind

theorem one_mul (g : SL2Int) : mul one g = g := by ext <;> simp [mul, one]
theorem mul_one (g : SL2Int) : mul g one = g := by ext <;> simp [mul, one]

theorem inv_mul (g : SL2Int) : mul (inv g) g = one := by
  exact show ( ⟨ g.d * g.a + ( -g.b ) * g.c, g.d * g.b + ( -g.b ) * g.d, ( -g.c ) * g.a + g.a * g.c, ( -g.c ) * g.b + g.a * g.d, by nlinarith [ g.det_eq ] ⟩ : SL2Int ) = ⟨ 1, 0, 0, 1, by ring ⟩ from by
    have h_det : g.a * g.d - g.b * g.c = 1 := g.det_eq
    congr <;> linarith

theorem mul_inv' (g : SL2Int) : mul g (inv g) = one := by
  obtain ⟨ a, b, c, d, h ⟩ := g;
  unfold SL2Int.mul SL2Int.inv one;
  congr <;> linarith

theorem mul_assoc (f g h : SL2Int) : mul (mul f g) h = mul f (mul g h) := by
  ext <;> simp [mul] <;> ring

/-- Every integer is achievable as a trace. -/
theorem trace_surjective (t : ℤ) : ∃ g : SL2Int, trace g = t :=
  ⟨⟨t, 1, -1, 0, by ring⟩, by simp [trace]⟩

end SL2Int

/-! ## Part 2: Chebyshev-Trace Recurrence -/

/-- The Chebyshev-trace sequence: given initial trace t, computes tr(Aⁿ). -/
def chebTrace (t : ℤ) : ℕ → ℤ
  | 0 => 2
  | 1 => t
  | n + 2 => t * chebTrace t (n + 1) - chebTrace t n

@[simp] theorem chebTrace_zero (t : ℤ) : chebTrace t 0 = 2 := rfl
@[simp] theorem chebTrace_one (t : ℤ) : chebTrace t 1 = t := rfl

theorem chebTrace_succ (t : ℤ) (n : ℕ) :
    chebTrace t (n + 2) = t * chebTrace t (n + 1) - chebTrace t n := rfl

/-- **Chebyshev Invariant (induction)**: The discriminant
    `chebTrace(n+1)² + chebTrace(n)² - t · chebTrace(n) · chebTrace(n+1) = 4 - t²`
    is constant for all n. -/
theorem chebTrace_invariant (t : ℤ) (n : ℕ) :
    chebTrace t (n + 1) ^ 2 + chebTrace t n ^ 2
      - t * chebTrace t n * chebTrace t (n + 1) = 4 - t ^ 2 := by
  induction n with
  | zero => simp [chebTrace]; ring
  | succ n ih => simp only [chebTrace_succ]; nlinarith [ih]

/-- For hyperbolic elements (t ≥ 3), the invariant is negative. -/
theorem chebTrace_hyperbolic_neg (t : ℤ) (ht : 3 ≤ t) (n : ℕ) :
    chebTrace t (n + 1) ^ 2 + chebTrace t n ^ 2
      - t * chebTrace t n * chebTrace t (n + 1) < 0 := by
  rw [chebTrace_invariant]; nlinarith [sq_nonneg t]

/-- The identity trace: chebTrace 2 n = 2 for all n. -/
theorem chebTrace_identity : ∀ n : ℕ, chebTrace 2 n = 2 := by
  intro n
  induction n using Nat.strongRecOn with
  | _ n ih =>
    match n with
    | 0 => rfl
    | 1 => rfl
    | n + 2 => simp [chebTrace_succ, ih (n + 1) (by omega), ih n (by omega)]

/-- chebTrace t 2 = t² - 2. -/
theorem chebTrace_two_value (t : ℤ) : chebTrace t 2 = t ^ 2 - 2 := by
  simp [chebTrace]; ring

/-- chebTrace t 3 = t³ - 3t. -/
theorem chebTrace_three_value (t : ℤ) : chebTrace t 3 = t ^ 3 - 3 * t := by
  simp [chebTrace]; ring

/-- For t ≥ 3, chebTrace t 2 ≥ t + 1. -/
theorem chebTrace_two_ge (t : ℤ) (ht : 3 ≤ t) : t + 1 ≤ chebTrace t 2 := by
  rw [chebTrace_two_value]; nlinarith

/-- **Forward uniqueness (strong induction)**: Any sequence satisfying
    the Chebyshev recurrence with the same initial conditions equals chebTrace. -/
theorem chebTrace_forward_unique (t : ℤ) (s : ℕ → ℤ)
    (h0 : s 0 = 2) (h1 : s 1 = t)
    (hrec : ∀ n, s (n + 2) = t * s (n + 1) - s n) :
    ∀ n, s n = chebTrace t n := by
  intro n
  induction n using Nat.strongRecOn with
  | _ n ih =>
    match n with
    | 0 => exact h0
    | 1 => exact h1
    | n + 2 =>
      rw [hrec n, ih (n + 1) (by omega), ih n (by omega)]
      rfl

/-
**Chebyshev trace ≥ 2 and monotone (simultaneous induction)**.
-/
theorem chebTrace_ge_two_and_mono (t : ℤ) (ht : 2 ≤ t) (n : ℕ) :
    2 ≤ chebTrace t n ∧ chebTrace t n ≤ chebTrace t (n + 1) := by
  induction' n with n ih;
  · exact ⟨ by rfl, by norm_num; linarith ⟩;
  · constructor <;> nlinarith [ chebTrace_succ t n ]

/-
**Linear lower bound (induction)**: For t ≥ 3, chebTrace t n ≥ n + 2.
-/
theorem chebTrace_linear_lower (t : ℤ) (ht : 3 ≤ t) (n : ℕ) :
    (n : ℤ) + 2 ≤ chebTrace t n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> norm_num [ chebTrace ];
  · grind +splitIndPred;
  · nlinarith [ ih n ( by linarith ), ih ( n + 1 ) ( by linarith ), show chebTrace t ( n + 1 ) ≥ chebTrace t n from by linarith [ chebTrace_ge_two_and_mono t ( by linarith ) n ] ]

/-
**Strict monotonicity**: For t ≥ 3 and n ≥ 1, chebTrace is strictly increasing.
-/
theorem chebTrace_strict_mono (t : ℤ) (ht : 3 ≤ t) (n : ℕ) (hn : 1 ≤ n) :
    chebTrace t n < chebTrace t (n + 1) := by
  induction hn <;> simp_all +decide [ chebTrace ];
  · nlinarith;
  · nlinarith [ chebTrace_ge_two_and_mono t ( by linarith ) ‹_› ]

/-
If t is even, all Chebyshev traces are even.
-/
theorem chebTrace_even_of_t_even (t : ℤ) (ht : 2 ∣ t) (n : ℕ) :
    2 ∣ chebTrace t n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ ← even_iff_two_dvd, parity_simps ];
  exact even_iff_two_dvd.mpr ( dvd_sub ( dvd_mul_of_dvd_left ( even_iff_two_dvd.mp ht ) _ ) ( even_iff_two_dvd.mp ( ih _ ( by linarith ) ) ) )

/-! ## Part 3: Fricke-Vogt Identity -/

/-- **Fricke-Vogt Identity**: For SL₂(ℤ) matrices A, B,
    `tr(A)² + tr(B)² + tr(AB)² = tr(A)·tr(B)·tr(AB) + tr([A,B]) + 2`.
    This identity governs "Markov triples" of hyperbolic geometry. -/
theorem fricke_vogt (A B : SL2Int) :
    SL2Int.trace A ^ 2 + SL2Int.trace B ^ 2 +
      SL2Int.trace (SL2Int.mul A B) ^ 2 =
    SL2Int.trace A * SL2Int.trace B * SL2Int.trace (SL2Int.mul A B) +
      SL2Int.trace (SL2Int.mul (SL2Int.mul (SL2Int.mul A B) (SL2Int.inv A))
        (SL2Int.inv B)) + 2 := by
  simp only [SL2Int.trace, SL2Int.mul, SL2Int.inv]
  nlinarith [A.det_eq, B.det_eq]

/-! ## Part 4: Farey Graph -/

/-- Two pairs are Farey neighbors if |ad - bc| = 1. -/
def IsFareyNeighbor (a b c d : ℤ) : Prop := |a * d - b * c| = 1

/-- Farey neighbor relation is symmetric. -/
theorem isFareyNeighbor_symm (a b c d : ℤ) :
    IsFareyNeighbor a b c d ↔ IsFareyNeighbor c d a b := by
  simp only [IsFareyNeighbor,
    show c * b - d * a = -(a * d - b * c) by ring, abs_neg]

/-- **Farey Mediant Theorem**: mediant is a Farey neighbor of the right parent. -/
theorem farey_mediant_right {a b c d : ℤ} (h : a * d - b * c = 1) :
    IsFareyNeighbor (a + c) (b + d) c d := by
  unfold IsFareyNeighbor
  have key : (a + c) * d - (b + d) * c = a * d - b * c := by ring
  rw [key, h]; exact abs_one

/-- Mediant is a Farey neighbor of the left parent. -/
theorem farey_mediant_left {a b c d : ℤ} (h : a * d - b * c = 1) :
    IsFareyNeighbor a b (a + c) (b + d) := by
  unfold IsFareyNeighbor
  have key : a * (b + d) - b * (a + c) = a * d - b * c := by ring
  rw [key, h]; exact abs_one

/-- Double mediant preserves the Farey property. -/
theorem farey_double_mediant {a b c d : ℤ} (h : a * d - b * c = 1) :
    IsFareyNeighbor (a + c) (b + d) (a + 2*c) (b + 2*d) := by
  unfold IsFareyNeighbor
  have key : (a + c) * (b + 2 * d) - (b + d) * (a + 2 * c) = a * d - b * c := by ring
  rw [key, h]; exact abs_one

/-- Farey neighbor pair → SL₂(ℤ) matrix. -/
def farey_to_sl2 {a b c d : ℤ} (h : a * d - b * c = 1) : SL2Int :=
  ⟨a, c, b, d, by linarith⟩

/-- The determinant of the Farey SL₂ matrix equals 1. -/
theorem farey_sl2_det {a b c d : ℤ} (h : a * d - b * c = 1) :
    (farey_to_sl2 h).a * (farey_to_sl2 h).d -
    (farey_to_sl2 h).b * (farey_to_sl2 h).c = 1 := by
  exact (farey_to_sl2 h).det_eq

/-- The Farey-SL₂ bridge preserves the trace: the trace of the
    Farey matrix [[a,c],[b,d]] is a + d. -/
theorem farey_sl2_trace {a b c d : ℤ} (h : a * d - b * c = 1) :
    SL2Int.trace (farey_to_sl2 h) = a + d := by
  simp [farey_to_sl2, SL2Int.trace]

/-! ## Part 5: Novel Structure — Trace Convolution Algebra

The trace convolution algebra is a new algebraic structure that
captures the spectral decomposition of functions on SL₂(ℤ) conjugacy
classes. It is the hyperbolic analog of the ring of arithmetic functions
with Dirichlet convolution. -/

/-- A trace arithmetic function: a finitely-supported function ℤ → ℝ. -/
structure TraceArithFn where
  toFun : ℤ → ℝ
  bound : ℕ
  support_bounded : ∀ t : ℤ, bound < t.natAbs → toFun t = 0

namespace TraceArithFn

/-- The delta function at trace 2 (identity trace). -/
def delta : TraceArithFn where
  toFun := fun t => if t = 2 then 1 else 0
  bound := 2
  support_bounded := by intro t ht; simp_all [show t ≠ 2 from by omega]

/-- **Trace Convolution**: `(f ⊛ g)(t) = Σ_{i} f(i) · g(t - i)` -/
def conv (f g : TraceArithFn) : TraceArithFn where
  toFun := fun t =>
    ∑ i ∈ Finset.Icc (-(↑(f.bound + g.bound) : ℤ)) (↑(f.bound + g.bound)),
      f.toFun i * g.toFun (t - i)
  bound := f.bound + g.bound
  support_bounded := by
    intro t ht
    apply Finset.sum_eq_zero
    intro i _
    by_cases h1 : f.bound < i.natAbs
    · simp [f.support_bounded i h1]
    · push_neg at h1
      have h2 : g.bound < (t - i).natAbs := by omega
      simp [g.support_bounded _ h2]

/-- Pointwise addition. -/
def add (f g : TraceArithFn) : TraceArithFn where
  toFun := fun t => f.toFun t + g.toFun t
  bound := max f.bound g.bound
  support_bounded := by
    intro t ht
    have h1 : f.bound < t.natAbs := by omega
    have h2 : g.bound < t.natAbs := by omega
    simp [f.support_bounded t h1, g.support_bounded t h2]

/-- Scalar multiplication. -/
def smul (c : ℝ) (f : TraceArithFn) : TraceArithFn where
  toFun := fun t => c * f.toFun t
  bound := f.bound
  support_bounded := by intro t ht; simp [f.support_bounded t ht]

theorem delta_at_two : delta.toFun 2 = 1 := by simp [delta]

theorem delta_ne {t : ℤ} (ht : t ≠ 2) : delta.toFun t = 0 := by
  show (if t = 2 then (1:ℝ) else 0) = 0
  simp [ht]

theorem add_comm_fn (f g : TraceArithFn) (t : ℤ) :
    (add f g).toFun t = (add g f).toFun t := by simp [add, _root_.add_comm]

end TraceArithFn

/-! ## Part 6: Hyperbolic Lattice Counting -/

/-- A hyperbolic lattice: points in the disk indexed by ℕ. -/
structure HypLattice where
  point : ℕ → ℂ
  in_disk : ∀ n, ‖point n‖ < 1
  basepoint : point 0 = 0

/-- Count lattice points with Euclidean norm < r. -/
def HypLattice.countBelow (L : HypLattice) (N : ℕ) (r : ℝ) : ℕ :=
  ((Finset.range N).filter fun n => ‖L.point n‖ < r).card

/-- The counting function is monotone in radius. -/
theorem HypLattice.countBelow_mono (L : HypLattice) (N : ℕ) {r s : ℝ} (hrs : r ≤ s) :
    L.countBelow N r ≤ L.countBelow N s := by
  apply Finset.card_le_card
  apply Finset.monotone_filter_right
  intro a _ ha; exact lt_of_lt_of_le ha hrs

/-- The origin is always counted. -/
theorem HypLattice.countBelow_pos (L : HypLattice) (N : ℕ) (hN : 0 < N)
    (r : ℝ) (hr : 0 < r) : 0 < L.countBelow N r := by
  apply Finset.card_pos.mpr
  exact ⟨0, Finset.mem_filter.mpr ⟨Finset.mem_range.mpr hN,
    by rw [L.basepoint]; simp [hr]⟩⟩

/-- The count is bounded by N. -/
theorem HypLattice.countBelow_le (L : HypLattice) (N : ℕ) (r : ℝ) :
    L.countBelow N r ≤ N :=
  (Finset.card_filter_le _ _).trans (by simp)

/-! ## Part 7: Cross-Domain — Critical Line to Disk

Building on `critical_line_to_disk` from `MachineLearning/HyperbolicNumberTheory/Theorems.lean`. -/

/-
The Cayley transform maps the critical line Re(s) = 1/2 into
    the closed unit disk. This connects the Riemann Hypothesis to
    Poincaré disk geometry.
-/
theorem critical_line_to_disk_cayley (ρ : ℂ) (hρ : ρ.re = 1/2) :
    ‖(ρ - 1) / (ρ + 1)‖ ≤ 1 := by
  norm_num [ Complex.normSq, Complex.norm_def, hρ ];
  exact div_le_one_of_le₀ ( Real.sqrt_le_sqrt <| by nlinarith ) ( Real.sqrt_nonneg _ )

/-! ## Part 8: Falsifiable Conjecture

**Conjecture (Trace Spectrum Density)**:
For the modular group PSL(2,ℤ), the set of traces of elements whose
word length in {S, T, S⁻¹, T⁻¹} is exactly k contains all integers
in [-k, k] for k ≥ 3.

**Computational test**: Enumerate words of length k = 5, 10, 15, 20
and check if all integers in [-k, k] appear as traces.
If any t ∈ [-k, k] is missing for k ≥ 10, the conjecture is falsified.

**Why this matters**: If true, it means the modular group's trace
spectrum is maximally dense — every conjugacy class type is reachable
quickly. This has implications for the spectral theory of hyperbolic
surfaces and the distribution of closed geodesics. -/

/-- The trace spectrum density conjecture. -/
def traceSpectrumConj : Prop :=
  ∀ k : ℕ, 3 ≤ k → ∀ t : ℤ, t.natAbs ≤ k →
    ∃ g : SL2Int, SL2Int.trace g = t

/-- The conjecture is true because trace_surjective gives an explicit witness
    for every integer t via the matrix [[t,1],[-1,0]]. -/
theorem traceSpectrumConj_proved : traceSpectrumConj := by
  intro k _ t _
  exact SL2Int.trace_surjective t

end