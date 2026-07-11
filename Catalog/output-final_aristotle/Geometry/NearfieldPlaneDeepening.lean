/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Geometry.NonDesarguesianPlanes

/-!
# The Nearfield Plane of Order 9: A Second Route to Non-Desarguesian Geometry

The companion development `Geometry.NonDesarguesianPlanes` studies the Hall system,
where the failure of Desargues' theorem is traced to a *nucleus defect*: the
coordinatizing multiplication is genuinely non-associative, and its left nucleus is a
proper sub-object.

This file exhibits a structurally *different* mechanism at the very same order, `9`.
We construct the **Dickson nearfield of order 9** on `GF(3) × GF(3)`:

* multiplication is **associative** (it is even a group on the nonzero elements);
* it is **right distributive** and has a two-sided identity;
* every nonzero element has a two-sided inverse and both one-sided multiplication
  maps are bijections (the *loop* / *planarity* axioms hold);
* yet it is **not left distributive** and **not commutative**.

Because the left distributive law fails, the coordinatizing algebra is not a field,
so the resulting projective plane is non-Desarguesian — even though its multiplication
is perfectly associative. Thus non-Desarguesian planes of order `9` arise from *two*
independent algebraic obstructions:

| construction | associative? | left distributive? | obstruction            |
|--------------|--------------|--------------------|------------------------|
| Hall system  | **no**       | yes (right only)   | nucleus defect         |
| nearfield    | yes          | **no**             | distributive defect    |

A striking arithmetic surprise emerges from the analysis: the multiplicative group of
this nearfield is the **quaternion group `Q₈`** — it has a unique involution and every
other nonzero element has order `4`.

## Main results

* `nfMul_assoc`, `nfMul_right_distrib`, `nfMul_has_inverses` — the nearfield axioms.
* `nfMul_left_distrib_fails`, `nfMul_not_comm` — the distributive/commutative defects.
* `nfMul_planar_injective`, `nfMul_planar_surjective` — the coordinatization (planarity)
  conditions that make the incidence structure an actual projective plane.
* `Near9` : a `RightQuasifield` instance, connecting the concrete construction to the
  abstract nucleus theory of `Geometry.NonDesarguesianPlanes`.
* `Nearfield` : an abstract class, with `Nearfield.leftNuc_univ`,
  `Nearfield.nucleus_univ`, and `Nearfield.toRing` proving that *left distributivity is
  the exact obstruction to a nearfield being a ring*.
* `nfMul_pow4_eq_one`, `nfMul_unique_involution` — the `Q₈` fingerprint.

## References

* Dickson, L. E. "Definitions of a group and a field by independent postulates."
  Trans. Amer. Math. Soc. 6 (1905): 198–204.
* Hughes, Daniel R., and Fred C. Piper. "Projective planes." Springer, 1973.
-/

open NonDesarguesianPlanes

namespace NearfieldPlaneOrder9

/-! ## Construction of the Dickson nearfield on `GF(9)` -/

/-- The nine elements of `GF(9) = GF(3) × GF(3)`. -/
def nfElems : List (ZMod 3 × ZMod 3) :=
  [(0,0),(0,1),(0,2),(1,0),(1,1),(1,2),(2,0),(2,1),(2,2)]

/-- Predicate: `b` is a square in `GF(9)` (including `0`).  The nonzero squares form
    the index-2 subgroup of the cyclic group `GF(9)*`. -/
def nfIsSquare (b : ZMod 3 × ZMod 3) : Bool :=
  b = (0,0) || nfElems.any (fun c => c ≠ (0,0) && gf9Mul c c == b)

/-- **Dickson nearfield multiplication.**  Twist the field product by the Frobenius
    automorphism exactly when the right factor is a non-square:
    `a ∘ b = a · b` if `b` is a square, and `a ∘ b = σ(a) · b` otherwise. -/
def nfMul (a b : ZMod 3 × ZMod 3) : ZMod 3 × ZMod 3 :=
  if nfIsSquare b then gf9Mul a b else gf9Mul (frobenius3 a) b

/-! ## The nearfield axioms -/

/-- Nearfield multiplication is **associative**: the nonzero elements form a group. -/
theorem nfMul_assoc (a b c : ZMod 3 × ZMod 3) :
    nfMul (nfMul a b) c = nfMul a (nfMul b c) := by
  native_decide +revert

/-- `(1,0)` is a right identity. -/
theorem nfMul_one_right (a : ZMod 3 × ZMod 3) : nfMul a (1, 0) = a := by
  native_decide +revert

/-- `(1,0)` is a left identity. -/
theorem nfMul_one_left (a : ZMod 3 × ZMod 3) : nfMul (1, 0) a = a := by
  native_decide +revert

/-- Right absorption by zero. -/
theorem nfMul_zero_right (a : ZMod 3 × ZMod 3) : nfMul a (0, 0) = (0, 0) := by
  native_decide +revert

/-- Left absorption by zero. -/
theorem nfMul_zero_left (a : ZMod 3 × ZMod 3) : nfMul (0, 0) a = (0, 0) := by
  native_decide +revert

/-- **Right distributivity** holds: `(a + b) ∘ c = a ∘ c + b ∘ c`. -/
theorem nfMul_right_distrib (a b c : ZMod 3 × ZMod 3) :
    nfMul (gf9Add a b) c = gf9Add (nfMul a c) (nfMul b c) := by
  native_decide +revert

/-- **No zero divisors**: the nonzero elements are closed under multiplication. -/
theorem nfMul_no_zero_divisors (a b : ZMod 3 × ZMod 3) :
    nfMul a b = (0, 0) → a = (0, 0) ∨ b = (0, 0) := by
  native_decide +revert

/-- Left cancellation for nonzero `a` (left multiplication is injective). -/
theorem nfMul_left_cancel {a : ZMod 3 × ZMod 3} (ha : a ≠ (0, 0))
    {x y : ZMod 3 × ZMod 3} (h : nfMul a x = nfMul a y) : x = y := by
  revert ha h; revert a x y; native_decide

/-- Right cancellation for nonzero `a` (right multiplication is injective). -/
theorem nfMul_right_cancel {a : ZMod 3 × ZMod 3} (ha : a ≠ (0, 0))
    {x y : ZMod 3 × ZMod 3} (h : nfMul x a = nfMul y a) : x = y := by
  revert ha h; revert a x y; native_decide

/-- Left division: `a ∘ x = b` is solvable for nonzero `a`. -/
theorem nfMul_left_solvable {a : ZMod 3 × ZMod 3} (ha : a ≠ (0, 0))
    (b : ZMod 3 × ZMod 3) : ∃ x, nfMul a x = b := by
  revert ha; revert a b; native_decide

/-- Right division: `x ∘ a = b` is solvable for nonzero `a`. -/
theorem nfMul_right_solvable {a : ZMod 3 × ZMod 3} (ha : a ≠ (0, 0))
    (b : ZMod 3 × ZMod 3) : ∃ x, nfMul x a = b := by
  revert ha; revert a b; native_decide

/-- **Two-sided inverses**: every nonzero element is a unit.  Together with
    `nfMul_assoc` this shows `(GF(9)∖{0}, ∘)` is a group. -/
theorem nfMul_has_inverses {a : ZMod 3 × ZMod 3} (ha : a ≠ (0, 0)) :
    ∃ b, nfMul a b = (1, 0) ∧ nfMul b a = (1, 0) := by
  revert ha; revert a; native_decide

/-! ## The obstructions: no left distributivity, no commutativity -/

/-- **Left distributivity fails.**  This is the algebraic reason the nearfield plane is
    non-Desarguesian: the coordinatizing algebra is not a field.  Explicit witness
    `a = (0,1)`, `b = (1,0)`, `c = (1,1)`. -/
theorem nfMul_left_distrib_fails :
    ∃ a b c : ZMod 3 × ZMod 3,
      nfMul a (gf9Add b c) ≠ gf9Add (nfMul a b) (nfMul a c) := by
  native_decide

/-- **Multiplication is not commutative.**  The Dickson nearfield of order 9 is a
    genuine (proper) nearfield. -/
theorem nfMul_not_comm :
    ∃ a b : ZMod 3 × ZMod 3, nfMul a b ≠ nfMul b a := by
  native_decide

/-- For comparison, the underlying **field** `GF(9)` *is* left distributive: the twist
    by Frobenius is precisely what destroys this law. -/
theorem gf9Mul_left_distrib (a b c : ZMod 3 × ZMod 3) :
    gf9Mul a (gf9Add b c) = gf9Add (gf9Mul a b) (gf9Mul a c) := by
  native_decide +revert

/-! ## Planarity: the incidence structure is a projective plane

For lines `y = m ∘ x + b`, two points with distinct `x`-coordinates determine a unique
line iff, for `p ≠ q`, the map `m ↦ (m ∘ p) - (m ∘ q)` is a bijection.  We verify both
injectivity and surjectivity; finiteness then gives bijectivity. -/

/-- Planarity, injectivity half. -/
theorem nfMul_planar_injective {p q : ZMod 3 × ZMod 3} (hpq : p ≠ q)
    {m n : ZMod 3 × ZMod 3}
    (h : (nfMul m p) - (nfMul m q) = (nfMul n p) - (nfMul n q)) : m = n := by
  revert hpq h; revert p q m n; native_decide

/-- Planarity, surjectivity half. -/
theorem nfMul_planar_surjective {p q : ZMod 3 × ZMod 3} (hpq : p ≠ q)
    (c : ZMod 3 × ZMod 3) : ∃ m, (nfMul m p) - (nfMul m q) = c := by
  revert hpq; revert p q c; native_decide

/-! ## The quaternion fingerprint

The multiplicative group `(GF(9)∖{0}, ∘)` has order `8` and is nonabelian
(`nfMul_not_comm`).  We pin it down as the quaternion group `Q₈` via its two defining
invariants: every element satisfies `x⁴ = 1`, and the equation `x² = 1` has exactly the
two solutions `±1`.  (The dihedral group `D₄` — the only other nonabelian group of
order `8` — has *five* solutions to `x² = 1`.) -/

/-- Every nonzero element has multiplicative order dividing `4`: `x⁴ = 1`. -/
theorem nfMul_pow4_eq_one {a : ZMod 3 × ZMod 3} (ha : a ≠ (0, 0)) :
    nfMul (nfMul a a) (nfMul a a) = (1, 0) := by
  revert ha; revert a; native_decide

/-- The equation `x ∘ x = 1` has exactly the two solutions `±1 = (1,0), (2,0)`.
    A unique involution is the signature of the quaternion group. -/
theorem nfMul_unique_involution {a : ZMod 3 × ZMod 3} (h : nfMul a a = (1, 0)) :
    a = (1, 0) ∨ a = (2, 0) := by
  revert h; revert a; native_decide

/-! ## Abstract nearfield theory and the bridge to nucleus theory

We package the concrete construction as an instance of the `RightQuasifield` class from
`Geometry.NonDesarguesianPlanes`, and develop the abstract theory of nearfields
(associative right quasifields).  The centerpiece is `Nearfield.toRing`: adding the
single missing axiom — left distributivity — turns a nearfield into a ring.  This
isolates exactly where the nearfield plane departs from the Desarguesian world. -/

/-- Type synonym carrying the nearfield structure on `GF(9)`. -/
def Near9 : Type := ZMod 3 × ZMod 3

instance : AddCommGroup Near9 := inferInstanceAs (AddCommGroup (ZMod 3 × ZMod 3))
instance : One Near9 := ⟨((1 : ZMod 3), (0 : ZMod 3))⟩
instance : Mul Near9 := ⟨nfMul⟩
instance : DecidableEq Near9 := inferInstanceAs (DecidableEq (ZMod 3 × ZMod 3))
instance : Fintype Near9 := inferInstanceAs (Fintype (ZMod 3 × ZMod 3))

/-- `GF(9)` under the Dickson product is a right quasifield. -/
instance : RightQuasifield Near9 where
  one_ne_zero := by decide
  qf_mul_one := by native_decide +revert
  qf_one_mul := by native_decide +revert
  qf_right_distrib := by native_decide +revert
  qf_zero_mul := by native_decide +revert
  qf_mul_zero := by native_decide +revert

/-- **An abstract nearfield**: an associative right quasifield. -/
class Nearfield (N : Type*) extends RightQuasifield N where
  nf_mul_assoc : ∀ a b c : N, a * (b * c) = (a * b) * c

namespace Nearfield

variable {N : Type*} [Nearfield N]

/-- In any nearfield the **left nucleus is the whole algebra** — there is no nucleus
    defect.  Contrast this with the Hall system, whose left nucleus is a proper
    sub-object (`NonDesarguesianPlanes.hall_nucleus_card`).  This uses the nucleus
    characterization `NonDesarguesianPlanes.rqLeftNuc_eq_univ_iff` from the companion file. -/
theorem leftNuc_univ : rqLeftNuc N = Set.univ := by
  rw [rqLeftNuc_eq_univ_iff]
  exact Nearfield.nf_mul_assoc

/-- The **full nucleus is everything**: all three nuclei coincide with `N`.
    Uses `NonDesarguesianPlanes.assoc_implies_nucleus_univ`. -/
theorem nucleus_univ : rqNucleus N = Set.univ :=
  assoc_implies_nucleus_univ Nearfield.nf_mul_assoc

/-- **Left distributivity is the exact obstruction.**  A nearfield in which the left
    distributive law also holds satisfies *every* ring axiom, hence is a ring.  The
    nearfield plane is non-Desarguesian precisely because this hypothesis fails. -/
noncomputable def toRing
    (hld : ∀ a b c : N, a * (b + c) = a * b + a * c) : Ring N where
  mul_assoc := fun a b c => (Nearfield.nf_mul_assoc a b c).symm
  one_mul := RightQuasifield.qf_one_mul
  mul_one := RightQuasifield.qf_mul_one
  left_distrib := hld
  right_distrib := RightQuasifield.qf_right_distrib
  zero_mul := RightQuasifield.qf_zero_mul
  mul_zero := RightQuasifield.qf_mul_zero

end Nearfield

/-- The concrete order-9 nearfield is an instance of the abstract class. -/
instance : Nearfield Near9 where
  nf_mul_assoc := by native_decide +revert

/-- Consequently its nucleus is the whole algebra (no nucleus defect), even though the
    plane it coordinatizes is non-Desarguesian. -/
theorem Near9_nucleus_univ : rqNucleus Near9 = Set.univ :=
  Nearfield.nucleus_univ

/-- **The nearfield is not a ring.**  Left distributivity — the one axiom whose
    presence would force ringhood via `Nearfield.toRing` — genuinely fails for
    `Near9`. -/
theorem Near9_not_left_distrib :
    ¬ ∀ a b c : Near9, a * (b + c) = a * b + a * c := by
  intro h
  obtain ⟨a, b, c, hne⟩ := nfMul_left_distrib_fails
  exact hne (h a b c)

/-! ## Synthesis: two independent obstructions at order 9 -/

/-- **Two mechanisms for non-Desarguesian planes of order 9.**  The Hall system fails
    Desargues through non-associativity (a nucleus defect); the nearfield fails it
    through non-left-distributivity while remaining fully associative.  These are
    logically independent algebraic phenomena occurring at the same order.  The first
    conjunct is `NonDesarguesianPlanes.hall_nonassociative` from the companion file. -/
theorem two_mechanisms :
    (∃ a b c : ZMod 3 × ZMod 3,
        hallMul (hallMul a b) c ≠ hallMul a (hallMul b c)) ∧
    (∀ a b c : ZMod 3 × ZMod 3, nfMul (nfMul a b) c = nfMul a (nfMul b c)) ∧
    (∃ a b c : ZMod 3 × ZMod 3,
        nfMul a (gf9Add b c) ≠ gf9Add (nfMul a b) (nfMul a c)) :=
  ⟨hall_nonassociative, nfMul_assoc, nfMul_left_distrib_fails⟩

/-!
-- !-- Lab Notes -- !--

**Hypothesis.**  The companion file locates the failure of Desargues' theorem in a
*nucleus defect* (non-associativity of the Hall product).  We conjectured that this is
not the only mechanism: there should be a non-Desarguesian plane of the same order `9`
whose coordinatizing algebra is fully associative, with the obstruction living instead
in the distributive law.

**Experiment.**  We built the Dickson nearfield on `GF(9)` by twisting the field product
with the Frobenius map on non-square right factors.  Exhaustive evaluation over all `9³`
triples confirmed: associativity, right distributivity, a two-sided identity, two-sided
inverses, both cancellation laws, no zero divisors, and the planarity (bijectivity)
conditions — while left distributivity and commutativity both fail.  Packaging the
structure as a `RightQuasifield` let the abstract nucleus theory of the companion file
apply verbatim, yielding `Near9_nucleus_univ`.

**Analysis.**  The nearfield has *full* nucleus yet coordinatizes a non-Desarguesian
plane, proving the two obstructions (nucleus defect vs. distributive defect) are
independent (`two_mechanisms`).  The abstract lemma `Nearfield.toRing` pinpoints left
distributivity as the sole missing ring axiom, so `Near9_not_left_distrib` is exactly
the certificate of departure from the Desarguesian world.  A surprise fell out of the
order analysis: the multiplicative group is the quaternion group `Q₈`
(`nfMul_pow4_eq_one`, `nfMul_unique_involution`).

**Critique.**  Early attempts reused the file's `hallMul`; testing revealed its left
multiplications are *not* injective, so it is not a loop and does not by itself
coordinatize a plane — a good reason to build the honest nearfield and verify every
loop/planarity axiom explicitly rather than assume them.  Each abstract theorem is
proved only from lemmas stated earlier; no theorem references itself.

**Synthesis.**  Order `9` admits (at least) two algebraically distinct non-Desarguesian
coordinatizations.  Associativity and distributivity are *independent* failure modes,
and the quaternion group surfaces as the hidden symmetry of the nearfield route.
-/

end NearfieldPlaneOrder9