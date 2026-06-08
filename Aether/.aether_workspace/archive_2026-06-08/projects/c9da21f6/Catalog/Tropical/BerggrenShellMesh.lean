import Mathlib

/-!
# Berggren-Generated Exact Arithmetic Shell Meshes

This file establishes a bridge between the Berggren tree of primitive Pythagorean
triples, rational parametrizations of the unit circle, and exact tropical metric
computation. The key insight is that every Berggren descendant maps to an exact
rational point on the unit circle, and pairwise tropical distances between such
points reduce to exact integer arithmetic with controlled denominators.

## Main Results

* `berggren_point_on_unit_circle` — Every Pythagorean triple `(a,b,c)` with `c ≠ 0`
  yields a rational point `(a/c, b/c)` on the unit circle.
* `rat_sub_eq_int_cross` — Subtraction of rational points from integer triples
  reduces to integer cross-products over a common denominator.
* `tropDistQ_berggren_exact'` — The tropical distance between two Berggren circle
  points is an exact rational expression with denominator `c₁ * c₂`.
* `berggren_mesh_on_shell` — Every Pythagorean triple maps to a point on the unit circle.
* `berggren_mesh_pairwise_tropical_exact` — All pairwise tropical distances in a
  finite mesh of Pythagorean triples are exact rationals.
* `primitive_triple_to_ratPoint_injective` — Primitive normalized triples with
  positive hypotenuse inject into rational circle points.

## Definitions

* `BerggrenTriple` — A triple `(a, b, c)` of integers.
* `isPythagorean` — Predicate: `a² + b² = c²`.
* `toRatPoint` — Maps `(a, b, c)` to `(a/c, b/c) : ℚ × ℚ`.
* `onUnitCircle` — Predicate: `x² + y² = 1`.
* `tropDistQ` — Tropical (Chebyshev/L∞) distance on `ℚ × ℚ`.
-/

namespace BerggrenShellMesh

/-! ## Core Definitions -/

/-- A Berggren triple is a triple of integers `(a, b, c)`. -/
abbrev BerggrenTriple := ℤ × ℤ × ℤ

/-- A triple is Pythagorean if `a² + b² = c²`. -/
def isPythagorean (t : BerggrenTriple) : Prop :=
  t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2

/-- Map a triple to its rational circle point `(a/c, b/c)`. -/
def toRatPoint (t : BerggrenTriple) : ℚ × ℚ :=
  (((t.1 : ℚ) / t.2.2), ((t.2.1 : ℚ) / t.2.2))

/-- A rational point lies on the unit circle if `x² + y² = 1`. -/
def onUnitCircle (p : ℚ × ℚ) : Prop :=
  p.1 ^ 2 + p.2 ^ 2 = 1

/-- Tropical (Chebyshev/L∞) distance on `ℚ × ℚ`. -/
def tropDistQ (p q : ℚ × ℚ) : ℚ :=
  max (|p.1 - q.1|) (|p.2 - q.2|)

/-! ## Berggren Matrices -/

/-- Berggren child A: maps (a,b,c) to (a - 2b + 2c, 2a - b + 2c, 2a - 2b + 3c). -/
def bergA (a b c : ℤ) : BerggrenTriple := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Berggren child B: maps (a,b,c) to (a + 2b + 2c, 2a + b + 2c, 2a + 2b + 3c). -/
def bergB (a b c : ℤ) : BerggrenTriple := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Berggren child C: maps (a,b,c) to (-a + 2b + 2c, -2a + b + 2c, -2a + 2b + 3c). -/
def bergC (a b c : ℤ) : BerggrenTriple := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-! ## Theorem A: Berggren descendants on the rational unit circle -/

/-
**Theorem A**: Every Pythagorean triple `(a,b,c)` with `c ≠ 0` maps to a
rational point on the unit circle: `(a/c)² + (b/c)² = 1`.

This is the geometric shadow of the Pythagorean equation after normalizing
by the hypotenuse. It applies to all Berggren descendants.
-/
theorem berggren_point_on_unit_circle
    (a b c : ℤ)
    (hpy : a ^ 2 + b ^ 2 = c ^ 2)
    (hc : c ≠ 0) :
    ((a : ℚ) / c) ^ 2 + ((b : ℚ) / c) ^ 2 = 1 := by
  rw [ div_pow, div_pow, ← add_div, div_eq_iff ] <;> norm_cast <;> first | positivity | linarith;

/-- The root triple (3, 4, 5) is Pythagorean. -/
theorem root_triple_pythagorean : (3 : ℤ) ^ 2 + (4 : ℤ) ^ 2 = (5 : ℤ) ^ 2 := by norm_num

/-- Berggren A preserves the Pythagorean property. -/
theorem bergA_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (bergA a b c).1 ^ 2 + (bergA a b c).2.1 ^ 2 = (bergA a b c).2.2 ^ 2 := by
  unfold bergA; nlinarith [h]

/-- Berggren B preserves the Pythagorean property. -/
theorem bergB_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (bergB a b c).1 ^ 2 + (bergB a b c).2.1 ^ 2 = (bergB a b c).2.2 ^ 2 := by
  unfold bergB; nlinarith [h]

/-- Berggren C preserves the Pythagorean property. -/
theorem bergC_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (bergC a b c).1 ^ 2 + (bergC a b c).2.1 ^ 2 = (bergC a b c).2.2 ^ 2 := by
  unfold bergC; nlinarith [h]

/-- The root triple (3,4,5) maps to (3/5, 4/5) on the unit circle. -/
theorem root_on_unit_circle :
    ((3 : ℚ) / 5) ^ 2 + ((4 : ℚ) / 5) ^ 2 = 1 := by norm_num

/-- Berggren A child of (3,4,5) is (5,12,13), which maps to the unit circle. -/
theorem bergA_root_on_circle :
    let t := bergA 3 4 5
    ((t.1 : ℚ) / t.2.2) ^ 2 + ((t.2.1 : ℚ) / t.2.2) ^ 2 = 1 := by
  simp [bergA]; norm_num

/-- Berggren B child of (3,4,5) is (21,20,29), which maps to the unit circle. -/
theorem bergB_root_on_circle :
    let t := bergB 3 4 5
    ((t.1 : ℚ) / t.2.2) ^ 2 + ((t.2.1 : ℚ) / t.2.2) ^ 2 = 1 := by
  simp [bergB]; norm_num

/-- Berggren C child of (3,4,5) is (15,8,17), which maps to the unit circle. -/
theorem bergC_root_on_circle :
    let t := bergC 3 4 5
    ((t.1 : ℚ) / t.2.2) ^ 2 + ((t.2.1 : ℚ) / t.2.2) ^ 2 = 1 := by
  simp [bergC]; norm_num

/-
The unit circle property is equivalent to `isPythagorean` for the lifted triple.
-/
theorem unit_circle_iff_pythagorean (t : BerggrenTriple) (hc : t.2.2 ≠ 0) :
    onUnitCircle (toRatPoint t) ↔ isPythagorean t := by
  -- Unfold the definitions of `onUnitCircle`, `toRatPoint`, and `isPythagorean`.
  unfold onUnitCircle toRatPoint isPythagorean;
  field_simp;
  norm_cast

/-! ## Theorem B: Exact tropical distance formula -/

/-
Key lemma: subtraction of rational points from integer triples reduces to
integer cross-products over a common denominator.
-/
lemma rat_sub_eq_int_cross
    (a₁ a₂ c₁ c₂ : ℤ)
    (hc₁ : c₁ ≠ 0)
    (hc₂ : c₂ ≠ 0) :
    ((a₁ : ℚ) / c₁) - ((a₂ : ℚ) / c₂)
      = ((a₁ * c₂ - a₂ * c₁ : ℤ) : ℚ) / (c₁ * c₂) := by
  -- Use field_simp and then push_cast; ring. This will prove the equality.
  field_simp; push_cast; ring

/-
**Theorem B** (clean absolute-value version): The tropical distance between two
Berggren circle points `(a₁/c₁, b₁/c₁)` and `(a₂/c₂, b₂/c₂)` equals
`max(|a₁c₂ - a₂c₁|, |b₁c₂ - b₂c₁|) / |c₁c₂|` computed exactly in `ℚ`.
-/
theorem tropDistQ_berggren_exact'
    (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (hc₁ : c₁ ≠ 0)
    (hc₂ : c₂ ≠ 0) :
    tropDistQ
      (((a₁ : ℚ) / c₁), ((b₁ : ℚ) / c₁))
      (((a₂ : ℚ) / c₂), ((b₂ : ℚ) / c₂))
    =
    max
      (|((a₁ * c₂ - a₂ * c₁ : ℤ) : ℚ) / (c₁ * c₂)|)
      (|((b₁ * c₂ - b₂ * c₁ : ℤ) : ℚ) / (c₁ * c₂)|) := by
  convert congr_arg₂ max ?_ ?_ using 1;
  · push_cast; rw [ div_sub_div ] <;> ring <;> positivity;
  · field_simp;
    lia

/-- Tropical distance is nonneg. -/
theorem tropDistQ_nonneg (p q : ℚ × ℚ) : 0 ≤ tropDistQ p q := by
  unfold tropDistQ
  exact le_max_of_le_left (abs_nonneg _)

/-- Tropical distance is symmetric. -/
theorem tropDistQ_symm (p q : ℚ × ℚ) : tropDistQ p q = tropDistQ q p := by
  unfold tropDistQ
  simp [abs_sub_comm]

/-- Tropical distance to self is zero. -/
theorem tropDistQ_self (p : ℚ × ℚ) : tropDistQ p p = 0 := by
  unfold tropDistQ
  simp

/-! ## Theorem C: Finite mesh certification -/

/-
**Theorem C (shell membership)**: Every Pythagorean triple maps to a point on the
unit circle shell.
-/
theorem berggren_mesh_on_shell
    (t : BerggrenTriple)
    (hpy : t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2)
    (hc : t.2.2 ≠ 0) :
    onUnitCircle (toRatPoint t) := by
  exact (unit_circle_iff_pythagorean t hc).mpr hpy

/-- **Theorem C (pairwise tropical exactness)**: For any finite set of Pythagorean
triples with nonzero hypotenuses, every pairwise tropical distance is an exact
rational number. -/
theorem berggren_mesh_pairwise_tropical_exact
    (s : Finset BerggrenTriple)
    (_hshell : ∀ t ∈ s, t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2)
    (_hnz : ∀ t ∈ s, t.2.2 ≠ 0) :
    ∀ p ∈ s, ∀ q ∈ s,
      ∃ r : ℚ, tropDistQ (toRatPoint p) (toRatPoint q) = r := by
  intro p _ q _
  exact ⟨tropDistQ (toRatPoint p) (toRatPoint q), rfl⟩

/-! ## Theorem D: Primitive triple injectivity -/

/-
**Theorem D**: For primitive Pythagorean triples with positive hypotenuse,
equality of rational circle points implies equality of triples.

If `(a₁/c₁, b₁/c₁) = (a₂/c₂, b₂/c₂)` and both triples are primitive with
`0 < c`, then `a₁ = a₂`, `b₁ = b₂`, `c₁ = c₂`.
-/
theorem primitive_triple_to_ratPoint_injective
    (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (hpy₁ : a₁ ^ 2 + b₁ ^ 2 = c₁ ^ 2)
    (hpy₂ : a₂ ^ 2 + b₂ ^ 2 = c₂ ^ 2)
    (hprim₁ : Int.gcd a₁ (Int.gcd b₁ c₁) = 1)
    (hprim₂ : Int.gcd a₂ (Int.gcd b₂ c₂) = 1)
    (hc₁ : 0 < c₁)
    (hc₂ : 0 < c₂)
    (hEq :
      (((a₁ : ℚ) / c₁), ((b₁ : ℚ) / c₁)) =
      (((a₂ : ℚ) / c₂), ((b₂ : ℚ) / c₂))) :
    a₁ = a₂ ∧ b₁ = b₂ ∧ c₁ = c₂ := by
  -- From hEq, extract a₁/c₁ = a₂/c₂ and b₁/c₁ = b₂/c₂ via Prod.mk.inj.
  obtain ⟨h₁, h₂⟩ : (a₁ : ℚ) / c₁ = (a₂ : ℚ) / c₂ ∧ (b₁ : ℚ) / c₁ = (b₂ : ℚ) / c₂ := by
    lia
  have h_eq2 : b₁ * c₂ = b₂ * c₁ := by
    rw [ div_eq_div_iff ] at h₂ <;> norm_cast at * <;> linarith;
  -- From h_eq1 and h_eq2, we get c₁ = c₂.
  have h_eq3 : c₁ = c₂ := by
    rw [ div_eq_div_iff ] at h₁ h₂ <;> norm_cast at * <;> try linarith;
    -- From the equality of the rational points, we get that $c₁ \mid c₂$ and $c₂ \mid c₁$, hence $c₁ = c₂$.
    have h_div : c₁ ∣ c₂ ∧ c₂ ∣ c₁ := by
      have h_div : c₁ ∣ (a₁ * c₂) ∧ c₁ ∣ (b₁ * c₂) ∧ c₂ ∣ (a₂ * c₁) ∧ c₂ ∣ (b₂ * c₁) := by
        exact ⟨ h₁.symm ▸ dvd_mul_left _ _, h₂.symm ▸ dvd_mul_left _ _, h₁ ▸ dvd_mul_left _ _, h₂ ▸ dvd_mul_left _ _ ⟩;
      refine' ⟨ _, _ ⟩;
      · refine' Int.dvd_of_dvd_mul_right_of_gcd_one h_div.1 _;
        by_contra h_contra;
        obtain ⟨ p, hp₁, hp₂ ⟩ := Nat.Prime.not_coprime_iff_dvd.mp h_contra;
        exact Nat.Prime.not_dvd_one hp₁ ( hprim₁ ▸ Nat.dvd_gcd hp₂.2 ( Nat.dvd_gcd ( show p ∣ Int.natAbs b₁ from Int.natAbs_dvd_natAbs.mpr <| Int.Prime.dvd_pow' hp₁ <| by rw [ show b₁ ^ 2 = c₁ ^ 2 - a₁ ^ 2 by linarith ] ; exact dvd_sub ( dvd_pow ( Int.natCast_dvd.mpr hp₂.1 ) two_ne_zero ) ( dvd_pow ( Int.natCast_dvd.mpr hp₂.2 ) two_ne_zero ) ) hp₂.1 ) );
      · refine' Int.dvd_of_dvd_mul_right_of_gcd_one h_div.2.2.1 _;
        by_contra h_contra;
        obtain ⟨ p, hp₁, hp₂ ⟩ := Nat.Prime.not_coprime_iff_dvd.mp h_contra;
        -- Since $p$ divides $c₂$ and $a₂$, it must also divide $b₂$ because $a₂^2 + b₂^2 = c₂^2$.
        have hp_div_b2 : (p : ℤ) ∣ b₂ := by
          have hp_div_b2 : (p : ℤ) ∣ (a₂ ^ 2 + b₂ ^ 2) := by
            exact hpy₂.symm ▸ dvd_pow ( Int.natCast_dvd.mpr hp₂.1 ) two_ne_zero;
          exact Int.Prime.dvd_pow' hp₁ ( by simpa using dvd_sub hp_div_b2 ( dvd_pow ( Int.natCast_dvd.mpr hp₂.2 ) two_ne_zero ) );
        exact Nat.Prime.not_dvd_one hp₁ ( hprim₂ ▸ Nat.dvd_gcd hp₂.2 ( Nat.dvd_gcd ( Int.natAbs_dvd_natAbs.mpr hp_div_b2 ) hp₂.1 ) );
    exact Int.le_antisymm ( Int.le_of_dvd hc₂ h_div.1 ) ( Int.le_of_dvd hc₁ h_div.2 );
  simp_all +decide [ ne_of_gt, div_eq_iff ]

end BerggrenShellMesh