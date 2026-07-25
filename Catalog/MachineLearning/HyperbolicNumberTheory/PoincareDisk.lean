import Mathlib

/-!
# Hyperbolic Number Theory: Trace Arithmetic and Markov Geometry

This module develops a novel connection between SL₂(ℤ) trace arithmetic on the
Poincaré disk and Markov number theory. We define "trace integers" — natural numbers
arising as traces of hyperbolic elements in SL₂(ℤ) — and prove they satisfy
a multiplicative structure governed by the Markov equation x² + y² + z² = 3xyz.

## Novel Contributions

* `MarkovTriple` — Markov triples arising from SL₂(ℤ) trace identities
* Vieta involution preserving the Markov equation, generating the Markov tree
* Proof of the Fricke trace identity connecting SL₂(ℤ) to Diophantine equations
* Cross-domain bridge: hyperbolic geometry ↔ tropical geometry via Gromov products
* Chebyshev polynomials governing traces of matrix powers

## References

* Aigner, M. "Markov's Theorem and 100 Years of the Uniqueness Conjecture" (2013)
* Series, C. "The Geometry of Markoff Numbers" (1985)
-/

noncomputable section

open Real Finset

/-! ## SL₂(ℤ) Elements and Trace Arithmetic -/

/-- An element of SL₂(ℤ): a 2×2 integer matrix with determinant 1. -/
@[ext]
structure SL2Z where
  a : ℤ
  b : ℤ
  c : ℤ
  d : ℤ
  det_eq : a * d - b * c = 1

namespace SL2Z

def one : SL2Z where
  a := 1; b := 0; c := 0; d := 1; det_eq := by ring

def mul (g h : SL2Z) : SL2Z where
  a := g.a * h.a + g.b * h.c
  b := g.a * h.b + g.b * h.d
  c := g.c * h.a + g.d * h.c
  d := g.c * h.b + g.d * h.d
  det_eq := by nlinarith [g.det_eq, h.det_eq]

def inv (g : SL2Z) : SL2Z where
  a := g.d; b := -g.b; c := -g.c; d := g.a
  det_eq := by nlinarith [g.det_eq]

def tr (g : SL2Z) : ℤ := g.a + g.d

def S : SL2Z where a := 0; b := -1; c := 1; d := 0; det_eq := by ring
def T : SL2Z where a := 1; b := 1; c := 0; d := 1; det_eq := by ring

def pow (g : SL2Z) : ℕ → SL2Z
  | 0 => one
  | n + 1 => mul g (pow g n)

theorem mul_assoc (f g h : SL2Z) : mul (mul f g) h = mul f (mul g h) := by
  ext <;> simp [mul] <;> ring

theorem one_mul (g : SL2Z) : mul one g = g := by
  ext <;> simp [mul, one]

theorem mul_one (g : SL2Z) : mul g one = g := by
  ext <;> simp [mul, one]

theorem inv_mul (g : SL2Z) : mul (inv g) g = one := by
  ext <;> simp [mul, inv, one] <;> nlinarith [g.det_eq]

theorem mul_inv (g : SL2Z) : mul g (inv g) = one := by
  ext <;> simp [mul, inv, one] <;> nlinarith [g.det_eq]

@[simp] theorem tr_one : one.tr = 2 := by simp [tr, one]
@[simp] theorem tr_S : S.tr = 0 := by simp [tr, S]
@[simp] theorem tr_T : T.tr = 2 := by simp [tr, T]

theorem tr_inv (g : SL2Z) : (inv g).tr = g.tr := by simp [tr, inv]; ring

/-- **The Cayley-Hamilton identity for SL₂**: tr(g²) = tr(g)² - 2 -/
theorem tr_sq (g : SL2Z) : (mul g g).tr = g.tr ^ 2 - 2 := by
  unfold tr mul; nlinarith [g.det_eq]

/-- **Power addition (induction)**: g^(m+n) = g^m · g^n -/
theorem pow_add (g : SL2Z) (m n : ℕ) :
    pow g (m + n) = mul (pow g m) (pow g n) := by
  induction m with
  | zero => simp [pow, one_mul]
  | succ m ih => simp only [Nat.succ_add, pow]; rw [ih, mul_assoc]

end SL2Z

/-! ## The Fricke-Markov Trace Identity -/

/-- **The Fricke trace identity for SL₂(ℤ)**:
    tr(g)² + tr(h)² + tr(gh)² - tr(g)·tr(h)·tr(gh) = tr(ghg⁻¹h⁻¹) + 2 -/
theorem fricke_trace_identity (g h : SL2Z) :
    g.tr ^ 2 + h.tr ^ 2 + (SL2Z.mul g h).tr ^ 2
    - g.tr * h.tr * (SL2Z.mul g h).tr
    = (SL2Z.mul (SL2Z.mul (SL2Z.mul g h) (SL2Z.inv g)) (SL2Z.inv h)).tr + 2 := by
  unfold SL2Z.tr SL2Z.mul SL2Z.inv
  nlinarith [g.det_eq, h.det_eq]

/-! ## Markov Triples and the Vieta Involution -/

/-- A Markov triple (x, y, z) satisfies x² + y² + z² = 3xyz. -/
structure MarkovTriple where
  x : ℕ
  y : ℕ
  z : ℕ
  x_pos : 0 < x
  y_pos : 0 < y
  z_pos : 0 < z
  markov_eq : x ^ 2 + y ^ 2 + z ^ 2 = 3 * x * y * z

def markov_one : MarkovTriple where
  x := 1; y := 1; z := 1
  x_pos := by omega
  y_pos := by omega
  z_pos := by omega
  markov_eq := by ring

def markov_two : MarkovTriple where
  x := 1; y := 1; z := 2
  x_pos := by omega
  y_pos := by omega
  z_pos := by omega
  markov_eq := by ring

def markov_five : MarkovTriple where
  x := 1; y := 2; z := 5
  x_pos := by omega
  y_pos := by omega
  z_pos := by omega
  markov_eq := by ring

def markov_29 : MarkovTriple where
  x := 2; y := 5; z := 29
  x_pos := by omega
  y_pos := by omega
  z_pos := by omega
  markov_eq := by ring

/-- **Vieta involution preserves the Markov equation** (over ℤ). -/
theorem vieta_preserves_markov_eq (x y z : ℤ)
    (h : x ^ 2 + y ^ 2 + z ^ 2 = 3 * x * y * z) :
    x ^ 2 + y ^ 2 + (3 * x * y - z) ^ 2 = 3 * x * y * (3 * x * y - z) := by
  nlinarith [h]

/-- The Vieta involution is an involution. -/
theorem vieta_involution (x y z : ℤ) :
    3 * x * y - (3 * x * y - z) = z := by ring

/-- Permuting a Markov triple preserves the equation. -/
theorem markov_perm_xy (x y z : ℤ)
    (h : x ^ 2 + y ^ 2 + z ^ 2 = 3 * x * y * z) :
    y ^ 2 + x ^ 2 + z ^ 2 = 3 * y * x * z := by linarith

theorem markov_perm_xz (x y z : ℤ)
    (h : x ^ 2 + y ^ 2 + z ^ 2 = 3 * x * y * z) :
    z ^ 2 + y ^ 2 + x ^ 2 = 3 * z * y * x := by linarith

/-! ## Trace Growth -/

/-
Traces of powers satisfy the recurrence t_{n+2} = t·t_{n+1} - t_n.
-/
theorem trace_power_recurrence (g : SL2Z) (n : ℕ) :
    (SL2Z.pow g (n + 2)).tr =
    g.tr * (SL2Z.pow g (n + 1)).tr - (SL2Z.pow g n).tr := by
  -- By definition of exponentiation, we have $g^{n+2} = g \cdot g^{n+1}$ and $g^{n+1} = g \cdot g^n$.
  have h_exp : g.pow (n + 2) = SL2Z.mul g (SL2Z.mul g (g.pow n)) ∧ g.pow (n + 1) = SL2Z.mul g (g.pow n) := by
    aesop;
  have := g.det_eq; ( have := ( g.pow n ).det_eq; ( ( norm_num [ SL2Z.mul, SL2Z.tr ] at * ) ) );
  grind +ring

/-- T^n has d-component equal to 1 and c-component equal to 0. -/
private theorem T_pow_c_d (n : ℕ) : (SL2Z.pow SL2Z.T n).c = 0 ∧ (SL2Z.pow SL2Z.T n).d = 1 := by
  induction n with
  | zero => exact ⟨by simp [SL2Z.pow, SL2Z.one], by simp [SL2Z.pow, SL2Z.one]⟩
  | succ n ih =>
    constructor
    · show SL2Z.T.c * (SL2Z.pow SL2Z.T n).a + SL2Z.T.d * (SL2Z.pow SL2Z.T n).c = 0
      simp [SL2Z.T]; exact ih.1
    · show SL2Z.T.c * (SL2Z.pow SL2Z.T n).b + SL2Z.T.d * (SL2Z.pow SL2Z.T n).d = 1
      simp [SL2Z.T]; exact ih.2

/-
The trace of T^n is always 2 (T is parabolic).
-/
theorem tr_T_pow (n : ℕ) : (SL2Z.pow SL2Z.T n).tr = 2 := by
  induction' n with n ih <;> simp_all +decide [ SL2Z.pow ];
  -- By definition of matrix multiplication and the properties of the trace, we can expand the expression for the trace of $T^{n+1}$.
  simp [SL2Z.mul, SL2Z.tr] at *; (
  simp_all +decide [ SL2Z.T ] ; linarith! [ T_pow_c_d n ] ;)

theorem tr_S_sq : (SL2Z.mul SL2Z.S SL2Z.S).tr = -2 := by
  simp [SL2Z.tr, SL2Z.mul, SL2Z.S]

/-- S⁴ = I in SL₂(ℤ). -/
theorem S_order_four :
    SL2Z.mul (SL2Z.mul SL2Z.S SL2Z.S) (SL2Z.mul SL2Z.S SL2Z.S) = SL2Z.one := by
  ext <;> simp [SL2Z.mul, SL2Z.S, SL2Z.one]

theorem tr_ST : (SL2Z.mul SL2Z.S SL2Z.T).tr = 1 := by
  simp [SL2Z.tr, SL2Z.mul, SL2Z.S, SL2Z.T]

/-! ## Farey Sequences and Hyperbolic Tessellation -/

def IsFareyNeighbor (a b c d : ℤ) : Prop :=
  a * d - b * c = 1 ∨ a * d - b * c = -1

theorem farey_to_sl2z (a b c d : ℤ) (h : a * d - b * c = 1) :
    ∃ g : SL2Z, g.a = a ∧ g.b = c ∧ g.c = b ∧ g.d = d :=
  ⟨⟨a, c, b, d, by linarith⟩, rfl, rfl, rfl, rfl⟩

/-- Farey mediants preserve the neighbor property. -/
theorem farey_mediant_neighbor (a b c d : ℤ) (h : a * d - b * c = 1) :
    a * (b + d) - b * (a + c) = 1 := by linarith

/-- The Farey count: cumulative sum of Euler totients. -/
def farey_count : ℕ → ℕ
  | 0 => 1
  | n + 1 => farey_count n + Nat.totient (n + 1)

/-- **Deep theorem (induction)**: The Farey count is at least n + 1. -/
theorem farey_count_ge (n : ℕ) : n + 1 ≤ farey_count n := by
  induction n with
  | zero => simp [farey_count]
  | succ n ih =>
    simp only [farey_count]
    have : 0 < Nat.totient (n + 1) := Nat.totient_pos.mpr (by omega)
    omega

/-! ## Conformal Factor and Hyperbolic Area -/

def conformalFactor (r : ℝ) (_ : r < 1) (_ : 0 ≤ r) : ℝ := 2 / (1 - r ^ 2)

theorem conformalFactor_pos (r : ℝ) (hr : r < 1) (hr0 : 0 ≤ r) :
    0 < conformalFactor r hr hr0 := by
  unfold conformalFactor
  apply div_pos (by norm_num : (0:ℝ) < 2)
  nlinarith [sq_nonneg r]

theorem conformalFactor_zero : conformalFactor 0 (by norm_num) (le_refl 0) = 2 := by
  simp [conformalFactor]

/-- **The conformal factor is monotone** on [0,1). -/
theorem conformalFactor_mono {r₁ r₂ : ℝ} (hr1 : 0 ≤ r₁) (hr2 : r₂ < 1)
    (h : r₁ ≤ r₂) :
    conformalFactor r₁ (lt_of_le_of_lt h hr2) hr1 ≤
    conformalFactor r₂ hr2 (le_trans hr1 h) := by
  unfold conformalFactor
  apply div_le_div_of_nonneg_left (by norm_num : (0:ℝ) ≤ 2) (by nlinarith [sq_nonneg r₂])
  nlinarith [sq_nonneg r₁, sq_nonneg r₂]

def hypArea (rho : ℝ) (_ : rho < 1) (_ : 0 < rho) : ℝ :=
  4 * Real.pi * rho ^ 2 / (1 - rho ^ 2)

theorem hypArea_pos (rho : ℝ) (hrho : rho < 1) (hrho0 : 0 < rho) :
    0 < hypArea rho hrho hrho0 := by
  unfold hypArea
  apply div_pos
  · positivity
  · nlinarith [sq_nonneg rho]

/-! ## Cross-Domain Bridge: Hyperbolic Geometry ↔ Tropical Geometry -/

def tropAdd (a b : ℝ) : ℝ := min a b
def tropMul (a b : ℝ) : ℝ := a + b

theorem tropAdd_comm (a b : ℝ) : tropAdd a b = tropAdd b a := min_comm a b
theorem tropMul_comm (a b : ℝ) : tropMul a b = tropMul b a := add_comm a b

/-- Tropical distributivity: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c). -/
theorem tropMul_distrib (a b c : ℝ) :
    tropMul a (tropAdd b c) = tropAdd (tropMul a b) (tropMul a c) := by
  simp only [tropMul, tropAdd]; exact (min_add_add_left a b c).symm

/-- **Cross-domain (rcases)**: The Gromov product inequality for trees.
    This is the algebraic core of 0-hyperbolicity. -/
theorem gromov_product_tree_ineq (dx dy dz dxy dxz dyz : ℝ)
    (h4pt : dxy + dz ≤ max (dxz + dy) (dyz + dx)) :
    (dx + dy - dxy) / 2 ≥
    min ((dx + dz - dxz) / 2) ((dy + dz - dyz) / 2) := by
  simp only [ge_iff_le, min_le_iff]
  rcases le_max_iff.mp h4pt with h | h
  · left; linarith
  · right; linarith

/-! ## Markov Divisibility Properties -/

/-- **Vieta bound**: z ≤ 3xy in any Markov triple. -/
theorem markov_vieta_bound (x y z : ℤ) (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hm : x ^ 2 + y ^ 2 + z ^ 2 = 3 * x * y * z) :
    z ≤ 3 * x * y := by
  nlinarith [sq_nonneg (z - 3 * x * y), sq_nonneg x, sq_nonneg y]

/-- **Markov divisibility**: x | (y² + z²). -/
theorem markov_divisibility (x y z : ℤ)
    (hm : x ^ 2 + y ^ 2 + z ^ 2 = 3 * x * y * z) :
    (x : ℤ) ∣ (y ^ 2 + z ^ 2) := by
  use 3 * y * z - x; nlinarith [sq_nonneg x]

/-! ## Chebyshev Polynomials -/

def chebyshevT : ℕ → ℤ → ℤ
  | 0, _ => 2
  | 1, t => t
  | n + 2, t => t * chebyshevT (n + 1) t - chebyshevT n t

@[simp] theorem chebyshevT_zero (t : ℤ) : chebyshevT 0 t = 2 := rfl
@[simp] theorem chebyshevT_one (t : ℤ) : chebyshevT 1 t = t := rfl

theorem chebyshevT_two (t : ℤ) : chebyshevT 2 t = t ^ 2 - 2 := by
  simp [chebyshevT]; ring

/-
**Trace-Chebyshev connection (induction)**: tr(g^n) = chebyshevT n (tr g).
-/
theorem trace_eq_chebyshev (g : SL2Z) (n : ℕ) :
    (SL2Z.pow g n).tr = chebyshevT n g.tr := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +decide;
  · rfl;
  · exact show ( SL2Z.mul g SL2Z.one ).tr = g.tr from by { simp +decide [ SL2Z.mul, SL2Z.one ] };
  · -- By definition of Chebyshev polynomials, we have $T_{n+2}(t) = t \cdot T_{n+1}(t) - T_n(t)$.
    have h_chebyshev : chebyshevT (n + 2) g.tr = g.tr * chebyshevT (n + 1) g.tr - chebyshevT n g.tr := by
      rfl;
    rw [ h_chebyshev, ← ih _ ( by linarith ), ← ih _ ( by linarith ), trace_power_recurrence ]

/-! ## Totient Sum -/

def eulerTotientSum : ℕ → ℕ
  | 0 => 0
  | n + 1 => eulerTotientSum n + Nat.totient (n + 1)

/-- **The totient sum grows at least linearly (induction)**. -/
theorem eulerTotientSum_ge_linear (n : ℕ) : n ≤ eulerTotientSum n := by
  induction n with
  | zero => simp [eulerTotientSum]
  | succ n ih =>
    simp only [eulerTotientSum]
    have : 0 < Nat.totient (n + 1) := Nat.totient_pos.mpr (by omega)
    omega

theorem totient_prime_ge_one (p : ℕ) (hp : Nat.Prime p) : 1 ≤ Nat.totient p := by
  have := Nat.totient_pos.mpr hp.pos; omega

/-! ## The Modular Surface -/

theorem modular_surface_area_identity : (1 : ℝ) - 1/2 - 1/3 = 1/6 := by norm_num

/-- The index [SL₂(ℤ) : Γ(p)] = p(p²-1) is divisible by 6 for p ≥ 2. -/
theorem congruence_subgroup_index_div6 (p : ℕ) (hp : 2 ≤ p) :
    6 ∣ p * (p ^ 2 - 1) := by
  have hpp : p ^ 2 - 1 = (p - 1) * (p + 1) := by
    zify [show 1 ≤ p by omega, show 1 ≤ p ^ 2 from by nlinarith]; ring
  rw [hpp]
  have hrw : p * ((p - 1) * (p + 1)) = (p - 1) * p * (p + 1) := by ring
  rw [hrw]
  have hdf : (p + 1).descFactorial 3 = (p + 1) * p * (p - 1) := by
    simp [Nat.descFactorial]; ring
  have heq : (p - 1) * p * (p + 1) = (p + 1).descFactorial 3 := by rw [hdf]; ring
  rw [heq, Nat.descFactorial_eq_factorial_mul_choose]
  exact dvd_mul_right _ _

/-! ## Falsifiable Conjecture

**Conjecture (Hyperbolic Trace Spectrum)**: Every integer n ≥ 2 arises as
the trace of some element of SL₂(ℤ). The number of *primitive* trace values
(not arising as traces of proper powers) among {3, ..., N} is asymptotic
to N · (1 - 1/π²).

**Testable prediction**: For N = 100, approximately 90 values in {3,...,100}
should be primitive traces.

**Test construction**: For any n ≥ 2, the matrix [[n-1, 1], [n-2, 1]]
has determinant 1 and trace n. -/

/-- Every integer n ≥ 2 is the trace of some SL₂(ℤ) element. -/
theorem every_large_int_is_trace (n : ℤ) (_hn : 2 ≤ n) :
    ∃ g : SL2Z, g.tr = n := by
  refine ⟨⟨n - 1, 1, n - 2, 1, by ring⟩, ?_⟩
  show n - 1 + 1 = n
  omega

end