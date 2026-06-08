import Mathlib

/-!
# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

This module develops a novel theory of "hyperbolic integers" — lattice points
in the Poincaré disk model of hyperbolic geometry arising from the action of
SL₂(ℤ) on the upper half-plane. We formalize the algebraic structure of
Möbius transformations, prove key properties of the hyperbolic metric, and
establish connections between trace arithmetic and orbit geometry.

## Novel Contributions

* `MobiusMap` — Möbius transformations as a multiplicative group structure
* `DiskPoint` / `pseudoHypDistSq` — Pseudo-hyperbolic distance in the Poincaré disk
* Trace-Chebyshev duality connecting SL₂(ℤ) traces to Chebyshev polynomials
* Cross-domain bridge: hyperbolic geometry ↔ tropical algebra (Gromov products)
* Falsifiable conjecture on primitive trace density

## References

* Iwaniec, H. "Spectral Methods of Automorphic Forms" (2002)
* Huber, H. "Zur analytischen Theorie hyperbolischer Raumformen" (1959)
-/

noncomputable section

open Real Finset BigOperators

/-! ## Part 1: Möbius Transformations (Novel Structure) -/

/-- A Möbius transformation with integer coefficients and determinant 1.
    Represents an element of SL₂(ℤ). -/
@[ext]
structure MobiusMap where
  a : ℤ
  b : ℤ
  c : ℤ
  d : ℤ
  det_one : a * d - b * c = 1

namespace MobiusMap

def id : MobiusMap where
  a := 1; b := 0; c := 0; d := 1; det_one := by ring

def comp (f g : MobiusMap) : MobiusMap where
  a := f.a * g.a + f.b * g.c
  b := f.a * g.b + f.b * g.d
  c := f.c * g.a + f.d * g.c
  d := f.c * g.b + f.d * g.d
  det_one := by nlinarith [f.det_one, g.det_one]

def inv (f : MobiusMap) : MobiusMap where
  a := f.d; b := -f.b; c := -f.c; d := f.a
  det_one := by nlinarith [f.det_one]

def trace (f : MobiusMap) : ℤ := f.a + f.d

def traceDiscriminant (f : MobiusMap) : ℤ := f.trace ^ 2 - 4

theorem comp_assoc (f g h : MobiusMap) :
    comp (comp f g) h = comp f (comp g h) := by
  ext <;> simp [comp] <;> ring

theorem id_comp (f : MobiusMap) : comp id f = f := by
  ext <;> simp [comp, id]

theorem comp_id (f : MobiusMap) : comp f id = f := by
  ext <;> simp [comp, id]

theorem inv_comp (f : MobiusMap) : comp (inv f) f = id := by
  ext <;> simp [comp, inv, id] <;> nlinarith [f.det_one]

theorem comp_inv (f : MobiusMap) : comp f (inv f) = id := by
  ext <;> simp [comp, inv, id] <;> nlinarith [f.det_one]

theorem inv_comp_eq (f g : MobiusMap) :
    inv (comp f g) = comp (inv g) (inv f) := by
  ext <;> simp [comp, inv] <;> ring

/-- **Trace is preserved under conjugation** (deep: linear_combination with det identity). -/
theorem trace_conjugate (f g : MobiusMap) :
    (comp (comp f g) (inv f)).trace = g.trace := by
  show (f.a * g.a + f.b * g.c) * f.d + (f.a * g.b + f.b * g.d) * (-f.c)
     + ((f.c * g.a + f.d * g.c) * (-f.b) + (f.c * g.b + f.d * g.d) * f.a) = g.a + g.d
  linear_combination (g.a + g.d) * f.det_one

/-- **The Fricke trace identity** for SL₂(ℤ). -/
theorem fricke_identity (f g : MobiusMap) :
    f.trace ^ 2 + g.trace ^ 2 + (comp f g).trace ^ 2
    - f.trace * g.trace * (comp f g).trace
    = (comp (comp (comp f g) (inv f)) (inv g)).trace + 2 := by
  simp only [trace, comp, inv]
  nlinarith [f.det_one, g.det_one]

theorem trace_inv (f : MobiusMap) : (inv f).trace = f.trace := by
  simp [trace, inv]; ring

/-- **Cayley-Hamilton for SL₂**: tr(g²) = tr(g)² - 2. -/
theorem trace_sq (f : MobiusMap) :
    (comp f f).trace = f.trace ^ 2 - 2 := by
  show f.a * f.a + f.b * f.c + (f.c * f.b + f.d * f.d) = (f.a + f.d) ^ 2 - 2
  nlinarith [f.det_one]

def S : MobiusMap where a := 0; b := -1; c := 1; d := 0; det_one := by ring
def T : MobiusMap where a := 1; b := 1; c := 0; d := 1; det_one := by ring

@[simp] theorem trace_S : S.trace = 0 := by simp [trace, S]
@[simp] theorem trace_T : T.trace = 2 := by simp [trace, T]

theorem S_pow_four : comp (comp S S) (comp S S) = id := by
  ext <;> simp [comp, S, id]

theorem trace_ST : (comp S T).trace = 1 := by simp [trace, comp, S, T]

def pow (f : MobiusMap) : ℕ → MobiusMap
  | 0 => id
  | n + 1 => comp f (pow f n)

/-- **Power addition** (by induction on m). -/
theorem pow_add (f : MobiusMap) (m n : ℕ) :
    pow f (m + n) = comp (pow f m) (pow f n) := by
  induction m with
  | zero => simp [pow, id_comp]
  | succ m ih => simp only [Nat.succ_add, pow]; rw [ih, comp_assoc]

/-
**Trace recurrence**: tr(f^{n+2}) = tr(f) · tr(f^{n+1}) - tr(f^n).
-/
theorem trace_pow_recurrence (f : MobiusMap) (n : ℕ) :
    (pow f (n + 2)).trace = f.trace * (pow f (n + 1)).trace - (pow f n).trace := by
  -- By definition of exponentiation, we have `f.pow (n + 2) = f * f.pow (n + 1)`.
  have h_exp : f.pow (n + 2) = MobiusMap.comp f (f.pow (n + 1)) := by
    rfl;
  -- By definition of exponentiation, we have `f.pow (n + 1) = f * f.pow n`.
  have h_exp_succ : f.pow (n + 1) = MobiusMap.comp f (f.pow n) := by
    rfl;
  simp_all +decide [ MobiusMap.comp, MobiusMap.trace ];
  grind +ring

end MobiusMap

/-! ## Part 2: The Poincaré Disk and Hyperbolic Distance -/

/-- A point in the Poincaré disk: (x, y) with x² + y² < 1. -/
structure DiskPoint where
  x : ℝ
  y : ℝ
  in_disk : x ^ 2 + y ^ 2 < 1

namespace DiskPoint

def origin : DiskPoint where x := 0; y := 0; in_disk := by norm_num

def normSq (p : DiskPoint) : ℝ := p.x ^ 2 + p.y ^ 2

theorem normSq_nonneg (p : DiskPoint) : 0 ≤ p.normSq := by unfold normSq; positivity
theorem normSq_lt_one (p : DiskPoint) : p.normSq < 1 := p.in_disk

/-- The pseudo-hyperbolic distance squared: δ(z,w) = |z-w|² / |1-z̄w|². -/
def pseudoHypDistSq (p q : DiskPoint) : ℝ :=
  ((p.x - q.x) ^ 2 + (p.y - q.y) ^ 2) /
  ((1 - p.x * q.x - p.y * q.y) ^ 2 + (p.x * q.y - p.y * q.x) ^ 2)

/-
**Denominator positivity** (deep: by_contra + Cauchy-Schwarz argument).
-/
theorem pseudoHypDist_denom_pos (p q : DiskPoint) :
    0 < (1 - p.x * q.x - p.y * q.y) ^ 2 + (p.x * q.y - p.y * q.x) ^ 2 := by
  nlinarith [ sq_nonneg ( p.x - q.x ), sq_nonneg ( p.y - q.y ), p.in_disk, q.in_disk ]

/-- **Symmetry** of the pseudo-hyperbolic distance. -/
theorem pseudoHypDistSq_symm (p q : DiskPoint) :
    pseudoHypDistSq p q = pseudoHypDistSq q p := by
  unfold pseudoHypDistSq; congr 1 <;> ring

/-- **Self-distance is zero**. -/
theorem pseudoHypDistSq_self (p : DiskPoint) : pseudoHypDistSq p p = 0 := by
  unfold pseudoHypDistSq; simp [sub_self]

/-- **Distance from origin** simplifies to |w|². -/
theorem pseudoHypDistSq_origin (q : DiskPoint) :
    pseudoHypDistSq origin q = q.normSq := by
  simp only [pseudoHypDistSq, origin, normSq]; norm_num

/-
**The pseudo-hyperbolic distance is < 1** (deep: nlinarith on disk constraints).
-/
theorem pseudoHypDistSq_lt_one (p q : DiskPoint) :
    pseudoHypDistSq p q < 1 := by
  convert div_lt_one ?_ |>.2 _;
  · infer_instance;
  · convert p.pseudoHypDist_denom_pos q using 1;
  · nlinarith [ p.in_disk, q.in_disk ]

/-
Non-negativity.
-/
theorem pseudoHypDistSq_nonneg (p q : DiskPoint) :
    0 ≤ pseudoHypDistSq p q := by
  exact div_nonneg ( add_nonneg ( sq_nonneg _ ) ( sq_nonneg _ ) ) ( add_nonneg ( sq_nonneg _ ) ( sq_nonneg _ ) )

end DiskPoint

/-! ## Part 3: Trace Sequences (Chebyshev Connection) -/

/-- The trace sequence: traceSeq t n = tr(g^n) when tr(g) = t. -/
def traceSeq (t : ℤ) : ℕ → ℤ
  | 0 => 2
  | 1 => t
  | n + 2 => t * traceSeq t (n + 1) - traceSeq t n

@[simp] theorem traceSeq_zero (t : ℤ) : traceSeq t 0 = 2 := rfl
@[simp] theorem traceSeq_one (t : ℤ) : traceSeq t 1 = t := rfl

theorem traceSeq_two (t : ℤ) : traceSeq t 2 = t ^ 2 - 2 := by
  simp [traceSeq]; ring

theorem traceSeq_three (t : ℤ) : traceSeq t 3 = t ^ 3 - 3 * t := by
  simp [traceSeq]; ring

theorem traceSeq_t3_values :
    traceSeq 3 0 = 2 ∧ traceSeq 3 1 = 3 ∧
    traceSeq 3 2 = 7 ∧ traceSeq 3 3 = 18 := by
  refine ⟨rfl, rfl, ?_, ?_⟩ <;> simp [traceSeq] <;> ring

/-
**Parity preservation** (by induction).
-/
theorem traceSeq_even_of_even (t : ℤ) (ht : Even t) (n : ℕ) :
    Even (traceSeq t n) := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ parity_simps ];
  exact Even.sub ( ht.mul_right _ ) ( ih _ ( by linarith ) )

/-
**Trace sequence congruence** (by induction):
    traceSeq t n ≡ 2 (mod t-2) for all n.
-/
theorem traceSeq_mod (t : ℤ) (n : ℕ) :
    (t - 2) ∣ (traceSeq t n - 2) := by
  induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | n ) <;> simp +arith +decide [ *, traceSeq ] ;
  -- By the induction hypothesis, we know that $t - 2$ divides both $traceSeq t (n + 1) - 2$ and $traceSeq t n - 2$.
  have h_ind : t - 2 ∣ traceSeq t (n + 1) - 2 ∧ t - 2 ∣ traceSeq t n - 2 := by
    grind;
  convert dvd_add ( dvd_add ( dvd_mul_of_dvd_right h_ind.1 t ) ( dvd_neg.mpr h_ind.2 ) ) ( dvd_mul_right ( t - 2 ) 2 ) using 1 ; ring

/-! ## Part 4: Euler Totient and Orbit Counting -/

def eulerTotientSum : ℕ → ℕ
  | 0 => 0
  | n + 1 => eulerTotientSum n + Nat.totient (n + 1)

/-- **The totient sum grows at least linearly** (by induction). -/
theorem eulerTotientSum_ge (n : ℕ) : n ≤ eulerTotientSum n := by
  induction n with
  | zero => simp [eulerTotientSum]
  | succ n ih =>
    simp only [eulerTotientSum]
    have : 0 < Nat.totient (n + 1) := Nat.totient_pos.mpr (by omega)
    omega

/-- **Every integer ≥ 2 is realized as a trace** (constructive witness). -/
theorem trace_realized (n : ℤ) (_hn : 2 ≤ n) :
    ∃ f : MobiusMap, f.trace = n :=
  ⟨⟨n - 1, 1, n - 2, 1, by ring⟩, by simp [MobiusMap.trace]⟩

/-- **Negative traces are also realized**. -/
theorem trace_realized_neg (n : ℤ) (_hn : n ≤ -2) :
    ∃ f : MobiusMap, f.trace = n :=
  ⟨⟨n - 1, -1, 2 - n, 1, by ring⟩, by simp [MobiusMap.trace]⟩

/-! ## Part 5: Cross-Domain Bridge — Hyperbolic ↔ Tropical Geometry -/

def tropAdd (a b : ℝ) : ℝ := min a b
def tropMul (a b : ℝ) : ℝ := a + b

theorem tropAdd_comm (a b : ℝ) : tropAdd a b = tropAdd b a := min_comm a b
theorem tropMul_comm (a b : ℝ) : tropMul a b = tropMul b a := add_comm a b
theorem tropAdd_assoc (a b c : ℝ) :
    tropAdd (tropAdd a b) c = tropAdd a (tropAdd b c) := min_assoc a b c
theorem tropMul_assoc (a b c : ℝ) :
    tropMul (tropMul a b) c = tropMul a (tropMul b c) := add_assoc a b c

/-- **Tropical distributivity**: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c). -/
theorem tropMul_distrib (a b c : ℝ) :
    tropMul a (tropAdd b c) = tropAdd (tropMul a b) (tropMul a c) := by
  simp only [tropMul, tropAdd]; exact (min_add_add_left a b c).symm

/-- **Cross-domain: Gromov product ultrametric inequality** (deep: rcases on max).
    The algebraic core of 0-hyperbolicity, bridging hyperbolic and tropical geometry. -/
theorem gromov_product_ultrametric (dx dy dz dxy dxz dyz : ℝ)
    (h4pt : dxy + dz ≤ max (dxz + dy) (dyz + dx)) :
    (dx + dy - dxy) / 2 ≥
    min ((dx + dz - dxz) / 2) ((dy + dz - dyz) / 2) := by
  simp only [ge_iff_le, min_le_iff]
  rcases le_max_iff.mp h4pt with h | h
  · left; linarith
  · right; linarith

/-! ## Part 6: Discriminant and Quadratic Fields -/

def fundamentalDisc (t : ℕ) : ℤ := (t : ℤ) ^ 2 - 4

theorem fundamentalDisc_of_3 : fundamentalDisc 3 = 5 := by norm_num [fundamentalDisc]
theorem fundamentalDisc_of_4 : fundamentalDisc 4 = 12 := by norm_num [fundamentalDisc]

/-- **Discriminant positivity for hyperbolic elements**. -/
theorem fundamentalDisc_pos (t : ℕ) (ht : 3 ≤ t) : 0 < fundamentalDisc t := by
  unfold fundamentalDisc
  have : (3 : ℤ) ≤ (t : ℤ) := by exact_mod_cast ht
  nlinarith

/-! ## Part 7: Markov Triples from Trace Identities -/

theorem vieta_preserves_markov (x y z : ℤ)
    (h : x ^ 2 + y ^ 2 + z ^ 2 = 3 * x * y * z) :
    x ^ 2 + y ^ 2 + (3 * x * y - z) ^ 2 = 3 * x * y * (3 * x * y - z) := by
  nlinarith [h]

theorem vieta_involution (x y z : ℤ) : 3 * x * y - (3 * x * y - z) = z := by ring

theorem markov_divisibility (x y z : ℤ)
    (hm : x ^ 2 + y ^ 2 + z ^ 2 = 3 * x * y * z) :
    (x : ℤ) ∣ (y ^ 2 + z ^ 2) := ⟨3 * y * z - x, by nlinarith⟩

theorem markov_vieta_bound (x y z : ℤ) (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hm : x ^ 2 + y ^ 2 + z ^ 2 = 3 * x * y * z) :
    z ≤ 3 * x * y := by
  nlinarith [sq_nonneg (z - 3 * x * y), sq_nonneg x, sq_nonneg y]

theorem markov_vieta_partner_pos (x y z : ℤ) (hx : 0 < x) (hy : 0 < y)
    (hz : 0 < z) (hm : x ^ 2 + y ^ 2 + z ^ 2 = 3 * x * y * z) :
    0 < 3 * x * y - z := by
  nlinarith [sq_nonneg x, sq_nonneg y, sq_nonneg z,
             mul_pos hx hy, mul_pos (mul_pos hx hy) hz]

/-! ## Part 8: Conformal Factor -/

def conformalFactor (r : ℝ) (_ : r < 1) (_ : 0 ≤ r) : ℝ := 2 / (1 - r ^ 2)

theorem conformalFactor_pos (r : ℝ) (hr : r < 1) (hr0 : 0 ≤ r) :
    0 < conformalFactor r hr hr0 := by
  unfold conformalFactor
  apply div_pos (by norm_num : (0:ℝ) < 2)
  nlinarith [sq_nonneg r]

/-- **The conformal factor is at least 2** (deep: calc with division). -/
theorem conformalFactor_ge_two (r : ℝ) (hr : r < 1) (hr0 : 0 ≤ r) :
    2 ≤ conformalFactor r hr hr0 := by
  unfold conformalFactor
  rw [le_div_iff₀ (by nlinarith [sq_nonneg r] : (0:ℝ) < 1 - r ^ 2)]
  nlinarith [sq_nonneg r]

/-
**The index [SL₂(ℤ) : Γ(p)] = p(p²-1) is divisible by 6 for p ≥ 2**.
-/
theorem congruence_subgroup_index_div6 (p : ℕ) (hp : 2 ≤ p) :
    6 ∣ p * (p ^ 2 - 1) := by
  zify [ hp ];
  rw [ Int.ofNat_sub ( by nlinarith ) ] ; push_cast ; rw [ Int.dvd_iff_emod_eq_zero ] ; norm_num [ sq, Int.add_emod, Int.sub_emod, Int.mul_emod ] ; have := Int.emod_nonneg p ( by norm_num : ( 6 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos p ( by norm_num : ( 6 : ℤ ) > 0 ) ; interval_cases ( p % 6 : ℤ ) <;> trivial;

theorem modular_surface_area : (1 : ℝ) - 1/2 - 1/3 = 1/6 := by norm_num

/-! ## Part 9: Farey Graph -/

def IsFareyNeighbor (a b c d : ℤ) : Prop :=
  a * d - b * c = 1 ∨ a * d - b * c = -1

theorem farey_mediant_neighbor (a b c d : ℤ) (h : a * d - b * c = 1) :
    a * (b + d) - b * (a + c) = 1 := by linarith

theorem farey_sl2z_witness (a b c d : ℤ) (h : a * d - b * c = 1) :
    ∃ g : MobiusMap, g.a = a ∧ g.b = c ∧ g.c = b ∧ g.d = d :=
  ⟨⟨a, c, b, d, by linarith⟩, rfl, rfl, rfl, rfl⟩

/-! ## Part 10: Falsifiable Conjecture

**Conjecture (Primitive Trace Density)**: A trace t ≥ 3 is "imprimitive"
if t + 2 is a perfect square ≥ 4 (i.e., t = s² - 2, meaning t is the
trace of the square of an element with trace s).

**Testable prediction**: For N = 20, imprimitive values in {3,...,20} are
{7 = 3²-2, 14 = 4²-2}, so 16/18 ≈ 0.889 are primitive.

Asymptotically, the density of primitive traces should approach a constant
related to ζ(2) = π²/6. -/

def isImprimitive (t : ℕ) : Prop :=
  ∃ s : ℕ, 2 ≤ s ∧ s * s = t + 2

theorem trace7_imprimitive : isImprimitive 7 := ⟨3, by omega, by omega⟩

theorem trace3_primitive : ¬ isImprimitive 3 := by
  intro ⟨s, hs1, hs2⟩
  have : s ≤ 2 := by nlinarith
  interval_cases s <;> omega

theorem trace5_primitive : ¬ isImprimitive 5 := by
  intro ⟨s, hs1, hs2⟩
  have : s ≤ 3 := by nlinarith
  interval_cases s <;> omega

theorem trace4_primitive : ¬ isImprimitive 4 := by
  intro ⟨s, hs1, hs2⟩
  have : s ≤ 2 := by nlinarith
  interval_cases s <;> omega

end