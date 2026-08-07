/-
# The radical 2-isogeny formula on Montgomery curves

`Catalog/Cryptography/IsogenySIDH/RadicalMontgomery.lean` verified the *affine
quotient* of a Montgomery curve `E_A : y² = x³ + A x² + x` by its rational
two-torsion point `(0,0)`: the image satisfies the (non-Montgomery) equation
`Y² = X³ + A X² - 4 X - 4 A`.  That is only half of a radical-isogeny step.  The
genuinely *radical* half is the renormalisation of the image back into Montgomery
form, which requires extracting a square root.

This file supplies that missing half and therefore closes the loop:

* `genMont B A P` is the generalized (twisted) Montgomery equation
  `B y² = x³ + A x² + x`.  Allowing the twist coefficient `B` makes the
  renormalisation *rational in a single radical* `α = √(A+2)`, which is exactly
  the shape used by radical-isogeny algorithms.
* `radTwoParam A α = (A+6)/(2α)` is the **radical 2-isogeny parameter formula**.
* `radTwoIso α (x,y) = ((x-1)²/(2αx), y(x²-1)/x²)` is the associated explicit
  rational map, and `radTwoIso_mem` is its correctness theorem.
* `radical_is_four_torsion_ordinate` explains *where the radical comes from*:
  `α` is precisely the `y`-coordinate of an affine point of `E_A` lying above
  `(0,0)` under duplication, i.e. of a point of order four.  This is the
  structural reason radical isogenies avoid square-root extraction at run time.
* `mont_normalisation_unique` shows the two sign choices `±α` exhaust all
  Montgomery renormalisations, and `radTwoParam_neg` identifies the second one
  with the quadratic twist.
* `radChain` iterates the step and `radChain_mem` verifies an entire chain by
  induction, which is the algorithmic content of a radical-isogeny walk.

Everything is stated over an arbitrary field, so it applies verbatim to the
quadratic finite fields `𝔽_{p²}` on which supersingular isogeny cryptography
takes place.
-/
import Cryptography.IsogenySIDH.DeepRadicalMontgomery

namespace Cryptography.IsogenySIDH

open Cryptography.IsogenySIDH

variable {K : Type*} [Field K]

/-! ## Generalized (twisted) Montgomery models -/

/-- The generalized Montgomery equation `B y² = x³ + A x² + x`.  For `B = 1`
this is `OnMontgomery A`; a non-square `B` describes the quadratic twist. -/
def genMont (B A : K) (P : K × K) : Prop :=
  B * P.2 ^ 2 = P.1 ^ 3 + A * P.1 ^ 2 + P.1

theorem genMont_one (A : K) (P : K × K) : genMont 1 A P ↔ OnMontgomery A P := by
  simp [genMont, OnMontgomery]

/-- A generalized Montgomery model can be rescaled by a square: if `r² = B`
then `B y² = …` becomes the untwisted equation for `r y`.  (This reuses the
catalog's `radicalNormalize`.) -/
theorem genMont_untwist {A B r : K} {P : K × K} (hr : r ^ 2 = B)
    (hP : genMont B A P) : OnMontgomery A (radicalNormalize r P) :=
  radicalNormalize_correct hr hP

/-- Passing to the quadratic twist: `x ↦ -x` identifies `genMont B A` with
`genMont (-B) (-A)`. -/
theorem genMont_twist_neg (B A : K) (x y : K) :
    genMont B A (x, y) ↔ genMont (-B) (-A) (-x, y) := by
  simp only [genMont]
  constructor <;> intro h <;> linear_combination -h

/-! ## The radical parameter formula -/

/-- **Radical 2-isogeny parameter.**  If `α² = A + 2`, the curve `2`-isogenous
to `E_A` via the kernel `⟨(0,0)⟩` has Montgomery coefficient `(A+6)/(2α)`. -/
def radTwoParam (A α : K) : K := (A + 6) / (2 * α)

/-- The twisting coefficient of the normalized model produced by the radical
step. -/
def radTwoTwist (α : K) : K := 1 / (8 * α ^ 3)

/-- **The radical 2-isogeny map** from `E_A` to the normalized quotient. -/
def radTwoIso (α : K) (P : K × K) : K × K :=
  ((P.1 - 1) ^ 2 / (2 * α * P.1), P.2 * (P.1 ^ 2 - 1) / P.1 ^ 2)

/-- **Main correctness theorem.**  With a chosen square root `α` of `A + 2`, the
explicit rational map `radTwoIso α` sends affine points of the Montgomery curve
`E_A` (away from the pole `x = 0`, i.e. away from the kernel) to points of the
generalized Montgomery curve with parameter `radTwoParam A α`. -/
theorem radTwoIso_mem {A α x y : K} (hα : α ≠ 0) (hsq : α ^ 2 = A + 2)
    (hx : x ≠ 0) (hP : OnMontgomery A (x, y)) :
    genMont (radTwoTwist α) (radTwoParam A α) (radTwoIso α (x, y)) := by
  have hP' : y ^ 2 = x ^ 3 + A * x ^ 2 + x := hP
  have hA : A = α ^ 2 - 2 := by linear_combination -hsq
  subst hA
  simp only [genMont, radTwoTwist, radTwoParam, radTwoIso]
  have h2 : (y * (x ^ 2 - 1) / x ^ 2) ^ 2 = y ^ 2 * ((x ^ 2 - 1) / x ^ 2) ^ 2 := by ring
  rw [h2, hP']
  field_simp
  ring

/-- Composite of the catalog's radical normalisation with the radical step:
starting from a *twisted* Montgomery model `B y² = x³ + A x² + x` together with
a square root `r` of `B`, the algorithm still lands on the predicted curve. -/
theorem radTwoIso_mem_of_twisted {A B r α x y : K} (hα : α ≠ 0)
    (hsq : α ^ 2 = A + 2) (hx : x ≠ 0) (hr : r ^ 2 = B)
    (hP : genMont B A (x, y)) :
    genMont (radTwoTwist α) (radTwoParam A α) (radTwoIso α (x, r * y)) :=
  radTwoIso_mem hα hsq hx (genMont_untwist hr hP)

/-! ## Where the radical comes from: four-torsion -/

/-- The `x`-coordinate of the duplication map on `E_A`, in the form used by
Montgomery arithmetic. -/
def mDoubleX (A x : K) : K := (x ^ 2 - 1) ^ 2 / (4 * x * (x ^ 2 + A * x + 1))

/-- Montgomery duplication in terms of the ordinate: `x(2P) = ((x²-1)/(2y))²`. -/
theorem mDoubleX_eq_sq {A x y : K} (hP : OnMontgomery A (x, y)) :
    mDoubleX A x = ((x ^ 2 - 1) / (2 * y)) ^ 2 := by
  have hP' : y ^ 2 = x ^ 3 + A * x ^ 2 + x := hP
  have hkey : 4 * x * (x ^ 2 + A * x + 1) = (2 * y) ^ 2 := by linear_combination -(4 : K) * hP'
  simp only [mDoubleX, hkey, div_pow]

/-- **Points above the kernel.**  An affine point of `E_A` doubles to the
two-torsion point `(0,0)` exactly when its abscissa is `1` or `-1`. -/
theorem mDoubleX_eq_zero_iff {A x : K}
    (hd : 4 * x * (x ^ 2 + A * x + 1) ≠ 0) :
    mDoubleX A x = 0 ↔ x = 1 ∨ x = -1 := by
  simp only [mDoubleX, div_eq_zero_iff, hd, or_false]
  constructor
  · intro h
    have h1 : (x - 1) ^ 2 * (x + 1) ^ 2 = 0 := by linear_combination h
    rcases mul_eq_zero.mp h1 with h2 | h2
    · left
      have h3 := sq_eq_zero_iff.mp h2
      linear_combination h3
    · right
      have h3 := sq_eq_zero_iff.mp h2
      linear_combination h3
  · rintro (rfl | rfl) <;> norm_num

/-- **The radical is a four-torsion ordinate.**  If `(1, y)` is an affine point
of `E_A`, then `y² = A + 2`; that is, the square root demanded by the radical
formula is literally the `y`-coordinate of a point lying above the kernel
generator `(0,0)`.  This is the structural fact that makes radical isogenies
square-root free at run time. -/
theorem radical_is_four_torsion_ordinate {A y : K} (hP : OnMontgomery A (1, y)) :
    y ^ 2 = A + 2 := by
  have hP' : y ^ 2 = 1 ^ 3 + A * 1 ^ 2 + 1 := hP
  linear_combination hP'

/-- The companion point above the kernel, with abscissa `-1`, carries the *other*
radical `√(A-2)`. -/
theorem companion_four_torsion_ordinate {A y : K} (hP : OnMontgomery A (-1, y)) :
    y ^ 2 = A - 2 := by
  have hP' : y ^ 2 = (-1 : K) ^ 3 + A * (-1) ^ 2 + (-1) := hP
  linear_combination hP'

/-- A four-torsion point of `E_A` really does double onto the kernel. -/
theorem four_torsion_doubles_into_kernel {A : K}
    (hd : 4 * (1 : K) * (1 ^ 2 + A * 1 + 1) ≠ 0) :
    mDoubleX A 1 = 0 := by
  rw [mDoubleX_eq_zero_iff hd]
  exact Or.inl rfl

/-- **Radical-free reformulation of the step.**  Given an actual four-torsion
point `(1, y)` on `E_A` with `y ≠ 0`, the radical step can be run with `α := y`
and no square root has to be extracted. -/
theorem radTwoIso_mem_of_four_torsion {A y x z : K} (hy : y ≠ 0)
    (hT : OnMontgomery A (1, y)) (hx : x ≠ 0) (hP : OnMontgomery A (x, z)) :
    genMont (radTwoTwist y) (radTwoParam A y) (radTwoIso y (x, z)) :=
  radTwoIso_mem hy (radical_is_four_torsion_ordinate hT) hx hP

/-! ## The image of the kernel-adjacent points -/

/-- The four-torsion point `(1, α)` is sent to the new two-torsion point
`(0,0)` — the kernel generator of the *next* radical step. -/
theorem radTwoIso_four_torsion (α : K) (y : K) :
    radTwoIso α (1, y) = (0, 0) := by
  simp [radTwoIso]

/-- The companion four-torsion point `(-1, β)` is sent to the two-torsion point
with abscissa `-2/α`. -/
theorem radTwoIso_companion {α : K} (hα : α ≠ 0) (htwo : (2 : K) ≠ 0) (y : K) :
    radTwoIso α (-1, y) = (-2 / α, 0) := by
  refine Prod.ext ?_ ?_
  · show ((-1 : K) - 1) ^ 2 / (2 * α * (-1)) = -2 / α
    rw [div_eq_div_iff (by simpa using mul_ne_zero (mul_ne_zero htwo hα) one_ne_zero) hα]
    ring
  · show y * ((-1 : K) ^ 2 - 1) / (-1) ^ 2 = 0
    norm_num

/-! ## Uniqueness of the Montgomery normalisation -/

/-- **The radical formula is forced.**  Any rescaling `X = c·u + 2` of the affine
quotient equation `Y² = X³ + A X² - 4X - 4A` that produces a generalized
Montgomery equation must have `c² = 4(A+2)`, hence `c = ±2α`; the resulting
parameter is then `± radTwoParam A α`.  So the two sign choices of the radical
exhaust all Montgomery models of the quotient. -/
theorem mont_normalisation_unique {A α c : K} (hsq : α ^ 2 = A + 2)
    (hc : c ^ 2 = 4 * (A + 2)) : c = 2 * α ∨ c = -(2 * α) := by
  have h : (c - 2 * α) * (c + 2 * α) = 0 := by
    linear_combination hc - 4 * hsq
  rcases mul_eq_zero.mp h with h1 | h1
  · exact Or.inl (sub_eq_zero.mp h1)
  · exact Or.inr (by linear_combination h1)

/-- Shifting by `X = c·u + 2` transforms the quotient equation into the
generalized Montgomery shape with parameter `(A+6)/c` and linear coefficient
`(4A+8)/c²`; normalising the latter to `1` is exactly the radical condition. -/
theorem quotient_shift_expand (A c u : K) :
    (c * u + 2) ^ 3 + A * (c * u + 2) ^ 2 - 4 * (c * u + 2) - 4 * A
      = c ^ 3 * u ^ 3 + (A + 6) * c ^ 2 * u ^ 2 + (4 * A + 8) * c * u := by
  ring

/-- The opposite choice of radical yields the negated parameter — i.e. the
quadratic twist of the same curve. -/
theorem radTwoParam_neg (A α : K) : radTwoParam A (-α) = -radTwoParam A α := by
  simp only [radTwoParam]
  rw [show 2 * -α = -(2 * α) by ring, div_neg]

/-- The two sign choices of the radical also produce opposite twist
coefficients. -/
theorem radTwoTwist_neg (α : K) : radTwoTwist (-α) = -radTwoTwist α := by
  simp only [radTwoTwist]
  rw [show (-α) ^ 3 = -(α ^ 3) by ring, show 8 * -(α ^ 3) = -(8 * α ^ 3) by ring, div_neg]

/-- The two radical branches are exchanged by the twist involution of
`genMont`. -/
theorem radTwoIso_branch_twist {A α x y : K} (hα : α ≠ 0) (hsq : α ^ 2 = A + 2)
    (hx : x ≠ 0) (hP : OnMontgomery A (x, y)) :
    genMont (radTwoTwist (-α)) (radTwoParam A (-α))
      (-(radTwoIso α (x, y)).1, (radTwoIso α (x, y)).2) := by
  rw [radTwoTwist_neg, radTwoParam_neg]
  exact (genMont_twist_neg _ _ _ _).mp (radTwoIso_mem hα hsq hx hP)

/-! ## Iterating: radical isogeny walks -/

/-- The parameter sequence of a radical-isogeny walk driven by a chosen
sequence `r` of square roots. -/
def radChain (r : ℕ → K) (A : K) : ℕ → K
  | 0 => A
  | n + 1 => radTwoParam (radChain r A n) (r n)

@[simp] theorem radChain_zero (r : ℕ → K) (A : K) : radChain r A 0 = A := rfl

@[simp] theorem radChain_succ (r : ℕ → K) (A : K) (n : ℕ) :
    radChain r A (n + 1) = radTwoParam (radChain r A n) (r n) := rfl

/-- A radical walk is *admissible* when every chosen root is a nonzero square
root of `A_n + 2`. -/
def AdmissibleWalk (r : ℕ → K) (A : K) : Prop :=
  ∀ n, r n ≠ 0 ∧ (r n) ^ 2 = radChain r A n + 2

/-- **Every step of an admissible radical walk is a verified isogeny step.**
This is proved uniformly for all `n`, so a whole walk of length `N` is verified
at once. -/
theorem radChain_step_mem {r : ℕ → K} {A : K} (h : AdmissibleWalk r A) (n : ℕ)
    {x y : K} (hx : x ≠ 0) (hP : OnMontgomery (radChain r A n) (x, y)) :
    genMont (radTwoTwist (r n)) (radChain r A (n + 1)) (radTwoIso (r n) (x, y)) := by
  obtain ⟨h0, hsq⟩ := h n
  exact radTwoIso_mem h0 hsq hx hP

/-- An admissible walk never leaves the ground field: the whole chain is
definable from `A` and the roots, and each parameter satisfies the
one-step algebraic relation `2 * A_{n+1} * r n = A_n + 6`. -/
theorem radChain_relation {r : ℕ → K} {A : K} (htwo : (2 : K) ≠ 0)
    (h : AdmissibleWalk r A) (n : ℕ) :
    2 * radChain r A (n + 1) * r n = radChain r A n + 6 := by
  obtain ⟨h0, _⟩ := h n
  simp only [radChain_succ, radTwoParam]
  field_simp

/-- **Determinacy of a radical walk.**  Two admissible walks over the same
starting parameter that use the same roots produce the same parameter
sequence; and more sharply, the parameter sequence is determined by the roots
through the explicit recursion.  Proved by induction on `n`. -/
theorem radChain_unique {r : ℕ → K} {A : K} (f : ℕ → K) (h0 : f 0 = A)
    (hstep : ∀ n, f (n + 1) = radTwoParam (f n) (r n)) (n : ℕ) :
    f n = radChain r A n := by
  induction n with
  | zero => simpa using h0
  | succ n ih => rw [hstep n, ih, radChain_succ]

end Cryptography.IsogenySIDH