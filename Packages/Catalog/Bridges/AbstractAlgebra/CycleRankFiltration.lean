/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The Hodge–Deligne E-polynomial as a Bridge to Arithmetic

This file introduces the two-variable **Hodge–Deligne E-polynomial**
`E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} uᵖ vᵍ`
on an abstract `HodgeDiamond` structure and proves two genuine *functional equations*:

* `epoly_serre_functional_equation` — the Serre/Poincaré duality equation
  `E(X; u, v) = (uv)ⁿ E(X; 1/u, 1/v)` (under Serre duality of `X`);
* `epoly_mirror_functional_equation` — the mirror equation
  `E(mirror X; u, v) = (-1)ⁿ uⁿ E(X; 1/u, v)` (unconditionally).

Specialising at `u = v = 1` recovers `eulerChar_mirror_sign`, the statement that the
topological Euler characteristic of the mirror diamond is `(-1)ⁿ` times the original.
We also record `totalDim_mirror` (the total Hodge dimension is mirror-invariant) and
upgrade the mirror involution to Calabi–Yau data (`CalabiYauData.mirror`).

This is a *duality / representation* bridge: it translates the geometric mirror
involution `(p,q) ↦ (n-p, q)` and Serre duality `(p,q) ↦ (n-p, n-q)` into algebraic
symmetries (functional equations) of a single polynomial invariant.

-- !-- Lab Notebook -- !--
Hypothesis: The numerical mirror sign `χ(mirror X) = (-1)ⁿ χ(X)` is the `u=v=1`
  shadow of a polynomial-level functional equation in the Hodge–Deligne E-polynomial.
Result: Both the Serre/Poincaré and mirror functional equations are formalised over an
  arbitrary field `K`, and the numerical Euler-characteristic sign and total-dimension
  invariance are recovered as corollaries (the former literally by specialising the
  E-polynomial at `u = v = 1`, see `epoly_one_one_eq_eulerChar`).
Insight: Both geometric involutions are *reflections* `j ↦ n - j` on the index range,
  so `Finset.sum_range_reflect` is the single combinatorial engine behind all the
  functional equations; the `(-1)ⁿ` and `(uv)ⁿ` prefactors are exactly the bookkeeping
  of the parity shift `(-1)^{(n-p)+(n-q)} = (-1)^{2n}·(-1)^{p+q}` and the exponent shift
  `uⁿ · u⁻ᵖ = u^{n-p}`.
Failure analysis: Defining `h` on all of `ℕ × ℕ` (rather than `Fin (n+1)²`) means the
  mirror involution `mirror ∘ mirror = id` only holds on the support `p, q ≤ n`; we
  therefore state the involution at the level of the E-polynomial / pointwise on the
  support (`mirror_mirror_h`, `epoly_mirror_mirror`) rather than as a definitional
  equality of structures.
-/

namespace HodgeEPolynomial

open Finset

/-- An abstract **Hodge diamond**: a complex dimension `n` together with the Hodge
numbers `h^{p,q}`. We store `h` as a function on all of `ℕ × ℕ`; only the values with
`p, q ≤ n` are mathematically meaningful (the rest are treated as padding). -/
structure HodgeDiamond where
  /-- The complex dimension. -/
  n : ℕ
  /-- The Hodge numbers `h^{p,q}`. -/
  h : ℕ → ℕ → ℤ

namespace HodgeDiamond

/-- The **mirror** diamond, implementing the involution `(p,q) ↦ (n-p, q)` on Hodge
numbers (the combinatorial avatar of mirror symmetry exchanging complex and Kähler
moduli). -/
def mirror (X : HodgeDiamond) : HodgeDiamond where
  n := X.n
  h := fun p q => X.h (X.n - p) q

@[simp] lemma mirror_n (X : HodgeDiamond) : X.mirror.n = X.n := rfl

@[simp] lemma mirror_h (X : HodgeDiamond) (p q : ℕ) :
    X.mirror.h p q = X.h (X.n - p) q := rfl

/-- **Serre duality** for a Hodge diamond: `h^{p,q} = h^{n-p, n-q}` on the support. -/
def SerreDual (X : HodgeDiamond) : Prop :=
  ∀ p q, p ≤ X.n → q ≤ X.n → X.h p q = X.h (X.n - p) (X.n - q)

variable {K : Type*} [Field K]

/-- The **Hodge–Deligne E-polynomial** `E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} uᵖ vᵍ`,
evaluated in an arbitrary field `K`. -/
def EPoly (X : HodgeDiamond) (u v : K) : K :=
  ∑ p ∈ range (X.n + 1), ∑ q ∈ range (X.n + 1),
    (-1) ^ (p + q) * (X.h p q : K) * u ^ p * v ^ q

/-- The topological **Euler characteristic** `χ(X) = Σ_{p,q} (-1)^{p+q} h^{p,q}`. -/
def eulerChar (X : HodgeDiamond) : ℤ :=
  ∑ p ∈ range (X.n + 1), ∑ q ∈ range (X.n + 1), (-1) ^ (p + q) * X.h p q

/-- The **total Hodge dimension** `Σ_{p,q} h^{p,q}` (the total Betti number). -/
def totalDim (X : HodgeDiamond) : ℤ :=
  ∑ p ∈ range (X.n + 1), ∑ q ∈ range (X.n + 1), X.h p q

/-- Specialising the E-polynomial at `u = v = 1` recovers the Euler characteristic. -/
-- !-- E(X;1,1) collapses each monomial to its sign times `h^{p,q}`; push the ℤ→K cast
-- through the double sum. -- !--
theorem epoly_one_one_eq_eulerChar (X : HodgeDiamond) :
    EPoly X (1 : K) 1 = (X.eulerChar : K) := by
  unfold HodgeDiamond.EPoly HodgeDiamond.eulerChar; simp +decide [ mul_assoc, mul_comm, mul_left_comm, pow_add ] ;

/-- **Mirror functional equation.** `E(mirror X; u, v) = (-1)ⁿ uⁿ E(X; 1/u, v)`. -/
-- !-- Pull the prefactor `(-1)ⁿ uⁿ` into the double sum, then reflect the `p`-index via
-- `sum_range_reflect`; `uⁿ · (u⁻¹)ᵖ = u^{n-p}` and the parity shift `(-1)^{(n-p)+q}` match. -- !--
theorem epoly_mirror_functional_equation (X : HodgeDiamond) (u v : K) (hu : u ≠ 0) :
    EPoly X.mirror u v = (-1) ^ X.n * u ^ X.n * EPoly X u⁻¹ v := by
  simp +decide only [EPoly];
  simp +decide [ hu, Finset.mul_sum _ _ _, mul_assoc, mul_left_comm, mul_pow, Finset.sum_mul ];
  refine' Finset.sum_bij ( fun p hp => X.n - p ) _ _ _ _ <;> simp_all +decide [ Nat.sub_sub_self, Finset.mem_range_succ_iff ];
  · exact fun a₁ ha₁ a₂ ha₂ h => by rw [ tsub_right_inj ] at h <;> linarith;
  · exact fun b hb => ⟨ X.n - b, Nat.sub_le _ _, Nat.sub_sub_self hb ⟩;
  · intro a ha; refine' Finset.sum_congr rfl fun x hx => _; rw [ show u ^ a = u ^ X.n / u ^ ( X.n - a ) by rw [ eq_div_iff ( pow_ne_zero _ hu ), ← pow_add, Nat.add_sub_of_le ha ] ] ; ring;
    rw [ show ( -1 : K ) ^ X.n = ( -1 : K ) ^ ( X.n - a ) * ( -1 : K ) ^ a by rw [ ← pow_add, Nat.sub_add_cancel ha ] ] ; ring;
    norm_num [ pow_mul' ]

/-- **Serre/Poincaré functional equation.** Under Serre duality,
`E(X; u, v) = (uv)ⁿ E(X; 1/u, 1/v)`. -/
-- !-- Derive from the mirror equation applied to `mirror X`: reflect both indices via
-- `sum_range_reflect`, then use Serre duality `h^{p,q} = h^{n-p,n-q}` and `(-1)^{2n} = 1`. -- !--
theorem epoly_serre_functional_equation (X : HodgeDiamond) (hX : X.SerreDual)
    (u v : K) (hu : u ≠ 0) (hv : v ≠ 0) :
    EPoly X u v = (u * v) ^ X.n * EPoly X u⁻¹ v⁻¹ := by
  convert epoly_mirror_functional_equation ( X.mirror ) u v hu using 1;
  · unfold HodgeDiamond.EPoly;
    congr! 3;
    grind +suggestions;
  · simp +decide [ HodgeDiamond.mirror, pow_add, mul_pow, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul, EPoly ];
    refine' Finset.sum_congr rfl fun i hi => _;
    rw [ ← Finset.sum_flip ];
    refine' Finset.sum_congr rfl fun j hj => _;
    have := hX i ( X.n - j ) ( by linarith [ Finset.mem_range.mp hi ] ) ( by linarith [ Finset.mem_range.mp hj, Nat.sub_le X.n j ] ) ; simp_all +decide [ Nat.sub_sub_self ( show j ≤ X.n from by linarith [ Finset.mem_range.mp hj ] ) ] ;
    rw [ show v ^ X.n = v ^ ( X.n - j ) * v ^ j by rw [ ← pow_add, Nat.sub_add_cancel hj ] ] ; ring;
    rw [ show X.n = j + ( X.n - j ) by rw [ Nat.add_sub_of_le hj ] ] ; ring;
    simp +decide [ mul_left_comm ( v ^ ( X.n - j ) ), mul_assoc, hv ]

/-- **Numerical mirror sign.** `χ(mirror X) = (-1)ⁿ χ(X)`. This is the `u = v = 1`
specialisation of `epoly_mirror_functional_equation`. -/
-- !-- Reflect the `p`-index in the definition of `eulerChar`; the parity shift
-- `(-1)^{(n-p)+q} = (-1)ⁿ (-1)^{p+q}` produces the global sign. -- !--
theorem eulerChar_mirror_sign (X : HodgeDiamond) :
    X.mirror.eulerChar = (-1) ^ X.n * X.eulerChar := by
  unfold HodgeDiamond.eulerChar HodgeDiamond.mirror;
  simp +decide only [mul_sum _ _ _];
  refine' Finset.sum_bij ( fun p hp => X.n - p ) _ _ _ _ <;> simp_all +decide;
  · intros; omega;
  · exact fun b hb => ⟨ X.n - b, Nat.sub_le _ _, Nat.sub_sub_self hb ⟩;
  · intro a ha; refine' Finset.sum_congr rfl fun x hx => _; rw [ show ( -1 : ℤ ) ^ X.n = ( -1 : ℤ ) ^ ( X.n - a ) * ( -1 : ℤ ) ^ a by rw [ ← pow_add, Nat.sub_add_cancel ha ] ] ; ring;
    norm_num [ pow_mul' ]

/-- **Mirror-invariance of the total Hodge dimension.** -/
-- !-- The total dimension is a plain (sign-free) sum, so reflecting the `p`-index leaves
-- it unchanged. -- !--
theorem totalDim_mirror (X : HodgeDiamond) :
    X.mirror.totalDim = X.totalDim := by
  convert Finset.sum_range_reflect ( fun p => ∑ q ∈ Finset.range ( X.n + 1 ), X.h p q ) ( X.n + 1 ) using 1

/-- The mirror is an involution **on the support** `p ≤ n`. -/
-- !-- `(mirror (mirror X)).h p q = X.h (n - (n - p)) q`, and `n - (n - p) = p` for `p ≤ n`. -- !--
theorem mirror_mirror_h (X : HodgeDiamond) (p q : ℕ) (hp : p ≤ X.n) :
    X.mirror.mirror.h p q = X.h p q := by
  rw [ HodgeDiamond.mirror, HodgeDiamond.mirror ];
  grind

/-- The mirror is an involution at the level of the E-polynomial. -/
-- !-- Both sides are sums over `p ≤ n`, where `mirror_mirror_h` makes the summands equal. -- !--
theorem epoly_mirror_mirror (X : HodgeDiamond) (u v : K) :
    EPoly X.mirror.mirror u v = EPoly X u v := by
  refine' Finset.sum_congr rfl fun p hp => Finset.sum_congr rfl fun q hq => _;
  rw [ HodgeDiamond.mirror_mirror_h X p q ( Finset.mem_range_succ_iff.mp hp ) ]

end HodgeDiamond

/-- **Calabi–Yau data**: a Hodge diamond satisfying Serre duality. -/
structure CalabiYauData where
  /-- The underlying Hodge diamond. -/
  diamond : HodgeDiamond
  /-- Serre duality of the underlying diamond. -/
  serre : diamond.SerreDual

namespace CalabiYauData

/-- The **mirror of Calabi–Yau data**: mirroring preserves Serre duality, so the mirror
of a Calabi–Yau diamond is again Calabi–Yau. -/
-- !-- For the mirror, Serre duality `h(n-p,q) = h(p,n-q)` is exactly the original Serre
-- relation applied at `(n-p, q)`. -- !--
def mirror (Y : CalabiYauData) : CalabiYauData where
  diamond := Y.diamond.mirror
  serre := by
    intro p q hp hq; have := Y.serre ( Y.diamond.n - p ) q; simp_all +decide [ Nat.sub_sub_self ] ;

@[simp] lemma mirror_diamond (Y : CalabiYauData) :
    Y.mirror.diamond = Y.diamond.mirror := rfl

end CalabiYauData

end HodgeEPolynomial