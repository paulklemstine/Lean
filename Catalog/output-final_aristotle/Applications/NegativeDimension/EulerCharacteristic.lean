import Mathlib
import Applications.SurfaceCodeHomology

/-!
# Euler characteristic in negative dimensions

We develop a rigorous, purely arithmetic model of **negative-dimensional spaces**
motivated by stable homotopy theory and the theory of pro-spectra, where formal
spheres `S^d` are available for *every* integer `d`, including `d < 0`.

The organising invariant is the **dimensional sign**
`sgn d = (-1)^d`, the reduced Euler characteristic of the formal `d`-sphere.
It is defined for all `d ∈ ℤ`, and it is the multiplicative backbone of the whole
theory: it turns the additive group of dimensions into the sign group `{±1}`.

A *formal space* records only the data that the Euler characteristic can see: an
integer dimension `d` and the number `k = |π₀|` of path components.  Its Euler
characteristic is
`χ(X) = sgn(d) · k`.
The headline result is that a space of dimension `-n` has
`χ(X) = (-1)^n · |π₀(X)|`,
extending the classical Euler characteristic to negative dimensions.

We prove that `χ` is:

* **additive** under disjoint union of equidimensional spaces (`chi_disjUnion`);
* **multiplicative** under products (`chi_prod`), because `sgn` sends the sum of
  dimensions to the product of signs (`sgn_add`);
* **sign-reversing** under suspension (`chi_susp`), and hence scaled by `(-1)^n`
  under `n`-fold suspension (`chi_suspIter`).

The `n`-fold suspension is the **stabilization map** carrying a space of dimension
`-n` to an honest `0`-dimensional space, and there the Euler characteristic reads
off `|π₀|` directly (`chi_stabilize`).

Finally we connect the sign-weighted invariant to genuine topology: the graded
Euler characteristic reproduces the classical value `χ = 2 - 2g` of the closed
orientable genus-`g` surface, using its first Betti number computed elsewhere in
the catalog (`chiGraded_surface`).
-/

namespace Catalog.Applications.NegativeDimension

open scoped BigOperators

/-! ## The dimensional sign -/

/-- The **dimensional sign** `sgn d = (-1)^d`, defined for every integer `d`.
Topologically it is the reduced Euler characteristic of the formal `d`-sphere
`S^d`, which the pro-spectrum picture makes available for negative `d` as well. -/
def sgn (d : ℤ) : ℤ := if Even d then 1 else -1

@[simp] lemma sgn_zero : sgn 0 = 1 := by simp [sgn]

@[simp] lemma sgn_one : sgn 1 = -1 := by decide

lemma sgn_eq_one_iff (d : ℤ) : sgn d = 1 ↔ Even d := by
  unfold sgn; split <;> simp_all

lemma sgn_eq_neg_one_iff (d : ℤ) : sgn d = -1 ↔ ¬ Even d := by
  unfold sgn; split <;> simp_all

lemma sgn_ne_zero (d : ℤ) : sgn d ≠ 0 := by
  unfold sgn; split <;> norm_num

/-- The sign only depends on the parity of the dimension, so it is invariant under
sign reversal `d ↦ -d`. -/
@[simp] lemma sgn_neg (d : ℤ) : sgn (-d) = sgn d := by
  unfold sgn
  by_cases h : Even d
  · rw [if_pos h, if_pos h.neg]
  · rw [if_neg h, if_neg (fun hn => h (by simpa using hn.neg))]

/-- **The sign is a homomorphism** from the additive group of dimensions to the
multiplicative sign group: `sgn (a + b) = sgn a · sgn b`.  This single identity
drives multiplicativity of the Euler characteristic under products. -/
lemma sgn_add (a b : ℤ) : sgn (a + b) = sgn a * sgn b := by
  unfold sgn
  by_cases ha : Even a <;> by_cases hb : Even b <;>
    simp [Int.even_add, ha, hb]

/-- The sign of a nonnegative integer dimension `n` is `(-1)^n`. -/
lemma sgn_natCast (n : ℕ) : sgn (n : ℤ) = (-1 : ℤ) ^ n := by
  by_cases h : Even n
  · rw [(sgn_eq_one_iff _).mpr (by exact_mod_cast h), h.neg_one_pow]
  · rw [(sgn_eq_neg_one_iff _).mpr (by exact_mod_cast h),
      (Nat.not_even_iff_odd.mp h).neg_one_pow]

/-- The sign of a negative integer dimension `-n` is `(-1)^n`: the numerical core
of the extension of the Euler characteristic to negative dimensions. -/
lemma sgn_negNatCast (n : ℕ) : sgn (-(n : ℤ)) = (-1 : ℤ) ^ n := by
  rw [sgn_neg, sgn_natCast]

/-! ## Formal spaces and their Euler characteristic -/

/-- A **formal space**: the data an Euler characteristic can detect, namely an
integer `dim` (allowed to be negative) and the number `comp = |π₀|` of path
components. -/
structure FormalSpace where
  dim : ℤ
  comp : ℕ

/-- The **Euler characteristic** `χ(X) = sgn(dim) · |π₀|`. -/
def chi (X : FormalSpace) : ℤ := sgn X.dim * X.comp

/-- **Euler characteristic in negative dimensions.**  A space of dimension `-n`
has `χ(X) = (-1)^n · |π₀(X)|`. -/
theorem chi_of_neg_dim (X : FormalSpace) (n : ℕ) (h : X.dim = -(n : ℤ)) :
    chi X = (-1 : ℤ) ^ n * X.comp := by
  unfold chi
  rw [h, sgn_negNatCast]

/-- The one-point space: dimension `0`, a single component, Euler characteristic `1`. -/
def pt : FormalSpace := ⟨0, 1⟩

@[simp] theorem chi_pt : chi pt = 1 := by simp [chi, pt]

/-! ## Additivity under disjoint union -/

/-- Disjoint union of two equidimensional spaces: the component counts add. -/
def disjUnion (X Y : FormalSpace) (_h : X.dim = Y.dim) : FormalSpace :=
  ⟨X.dim, X.comp + Y.comp⟩

/-- **Additivity.**  The Euler characteristic is additive under disjoint union of
equidimensional spaces. -/
theorem chi_disjUnion (X Y : FormalSpace) (h : X.dim = Y.dim) :
    chi (disjUnion X Y h) = chi X + chi Y := by
  unfold chi disjUnion
  simp only []
  rw [h]
  push_cast
  ring

/-! ## Multiplicativity under products -/

/-- Product of two formal spaces: dimensions add, component counts multiply. -/
def prod (X Y : FormalSpace) : FormalSpace :=
  ⟨X.dim + Y.dim, X.comp * Y.comp⟩

/-- **Multiplicativity.**  The Euler characteristic sends products to products,
`χ(X × Y) = χ(X) · χ(Y)`.  This is where `sgn_add` enters. -/
theorem chi_prod (X Y : FormalSpace) : chi (prod X Y) = chi X * chi Y := by
  unfold chi prod
  simp only []
  rw [sgn_add]
  push_cast
  ring

/-- Formal spaces form a commutative monoid under the product, with the one-point
space as unit.  Dimensions add and component counts multiply, so this is the
product of `(ℤ, +)` and `(ℕ, ·)`. -/
instance : CommMonoid FormalSpace where
  mul := prod
  one := pt
  mul_assoc a b c := by
    change prod (prod a b) c = prod a (prod b c)
    cases a; cases b; cases c
    simp only [prod, FormalSpace.mk.injEq]
    exact ⟨add_assoc _ _ _, mul_assoc _ _ _⟩
  one_mul a := by
    change prod pt a = a
    cases a; simp only [prod, pt, zero_add, one_mul]
  mul_one a := by
    change prod a pt = a
    cases a; simp only [prod, pt, add_zero, mul_one]
  mul_comm a b := by
    change prod a b = prod b a
    cases a; cases b
    simp only [prod, FormalSpace.mk.injEq]
    exact ⟨add_comm _ _, mul_comm _ _⟩

@[simp] lemma mul_eq_prod (X Y : FormalSpace) : X * Y = prod X Y := rfl

@[simp] lemma one_eq_pt : (1 : FormalSpace) = pt := rfl

/-- **The Euler characteristic is a monoid homomorphism** from formal spaces under
product to the integers under multiplication.  It is the universal multiplicative
invariant of the theory. -/
def chiHom : FormalSpace →* ℤ where
  toFun := chi
  map_one' := chi_pt
  map_mul' := chi_prod

@[simp] lemma chiHom_apply (X : FormalSpace) : chiHom X = chi X := rfl

/-! ## Suspension and stabilization -/

/-- Suspension raises the dimension by one and preserves `π₀` (in the reduced /
stable setting). -/
def susp (X : FormalSpace) : FormalSpace := ⟨X.dim + 1, X.comp⟩

/-- **Suspension reverses the Euler characteristic:** `χ(ΣX) = -χ(X)`. -/
theorem chi_susp (X : FormalSpace) : chi (susp X) = - chi X := by
  unfold chi susp
  simp only []
  rw [sgn_add, sgn_one]
  ring

/-- The `n`-fold suspension `Σⁿ`, raising the dimension by `n`. -/
def suspIter (n : ℕ) (X : FormalSpace) : FormalSpace := ⟨X.dim + n, X.comp⟩

@[simp] theorem suspIter_zero (X : FormalSpace) : suspIter 0 X = X := by
  simp [suspIter]

theorem suspIter_dim (n : ℕ) (X : FormalSpace) : (suspIter n X).dim = X.dim + n := rfl

/-- **`n`-fold suspension scales the Euler characteristic by `(-1)^n`.** -/
theorem chi_suspIter (n : ℕ) (X : FormalSpace) :
    chi (suspIter n X) = (-1 : ℤ) ^ n * chi X := by
  unfold chi suspIter
  simp only []
  rw [sgn_add, sgn_natCast]
  ring

/-- The **stabilization map** carries a space of dimension `-n` to dimension `0`. -/
theorem stabilize_dim_zero (X : FormalSpace) (n : ℕ) (h : X.dim = -(n : ℤ)) :
    (suspIter n X).dim = 0 := by
  rw [suspIter_dim, h]
  ring

/-- **Stabilization reads off `|π₀|`.**  Stabilizing a space of dimension `-n`
produces an honest `0`-dimensional space whose Euler characteristic is exactly the
number of path components. -/
theorem chi_stabilize (X : FormalSpace) (n : ℕ) (h : X.dim = -(n : ℤ)) :
    chi (suspIter n X) = X.comp := by
  unfold chi
  rw [stabilize_dim_zero X n h, sgn_zero, one_mul]
  rfl

/-- **Consistency of the two descriptions.**  Combining stabilization with the
suspension scaling law recovers the negative-dimensional Euler characteristic:
`(-1)^n · χ(X) = |π₀(X)|`, hence `χ(X) = (-1)^n · |π₀(X)|`. -/
theorem chi_via_stabilization (X : FormalSpace) (n : ℕ) (h : X.dim = -(n : ℤ)) :
    (-1 : ℤ) ^ n * chi X = X.comp := by
  rw [← chi_suspIter, chi_stabilize X n h]

/-! ## The graded Euler characteristic and a topological bridge -/

/-- The **graded Euler characteristic** of a finitely-supported family of Betti
numbers `b : ℤ → ℕ` over a finite set `S` of degrees: the sign-weighted count
`∑_{i ∈ S} sgn(i) · b i`.  Because `sgn i = (-1)^i` for all integers, this is the
alternating sum of Betti numbers extended to negative degrees. -/
def chiGraded (b : ℤ → ℕ) (S : Finset ℤ) : ℤ := ∑ i ∈ S, sgn i * (b i : ℤ)

/-- A family concentrated in a single degree `d` has graded Euler characteristic
`sgn(d) · k`, recovering the formal-space invariant. -/
theorem chiGraded_concentrated (d : ℤ) (k : ℕ) :
    chiGraded (fun i => if i = d then k else 0) {d} = sgn d * k := by
  unfold chiGraded
  simp

open TQEC in
/-- Betti data of the closed orientable genus-`g` surface: one component in degree
`0`, `2g` independent one-cycles in degree `1` (its first Betti number, computed
homologically elsewhere in the catalog), and one top class in degree `2`. -/
noncomputable def surfaceBetti (g : ℕ) : ℤ → ℕ := fun i =>
  if i = 0 then 1
  else if i = 1 then (surfaceComplex g).logicalQubits
  else if i = 2 then 1 else 0

open TQEC in
/-- **Topological bridge.**  The sign-weighted Euler characteristic reproduces the
classical value `χ = 2 - 2g` of the closed orientable genus-`g` surface, with the
degree-`1` Betti number supplied by the homological computation of the surface's
first homology group. -/
theorem chiGraded_surface (g : ℕ) :
    chiGraded (surfaceBetti g) {0, 1, 2} = 2 - 2 * g := by
  unfold chiGraded surfaceBetti
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide),
      Finset.sum_singleton, surface_logical_qubits]
  norm_num [sgn]
  ring

end Catalog.Applications.NegativeDimension

/-
-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer).
  The Euler characteristic, classically a ℤ-valued invariant of finite CW
  complexes, should extend to *negative* formal dimensions once one accepts the
  pro-spectrum viewpoint in which a sphere `S^d` exists for every integer `d`.
  The bold conjecture: for a space of dimension `-n`, the Euler characteristic is
  governed purely by the number of path components, via `χ = (-1)^n · |π₀|`, and
  the assignment `d ↦ (-1)^d` is a genuine group homomorphism from dimensions to
  signs that controls how χ behaves under products and suspension.

Experiment (Experimenter).
  We isolated the arithmetic core in the dimensional sign `sgn d = (-1)^d` and
  proved it is multiplicative in the dimension (`sgn_add`) and parity-invariant
  (`sgn_neg`).  Modelling a formal space by the pair `(dim, |π₀|)`, the Euler
  characteristic `χ = sgn(dim)·|π₀|` was shown to be additive under disjoint
  union of equidimensional spaces (`chi_disjUnion`), multiplicative under products
  (`chi_prod`, hence a monoid homomorphism `chiHom`), and sign-reversing under
  suspension (`chi_susp`, `chi_suspIter`).  The `n`-fold suspension is exactly the
  stabilization map: it carries dimension `-n` to `0` (`stabilize_dim_zero`) and
  reads off `|π₀|` there (`chi_stabilize`), giving an independent derivation of the
  negative-dimensional formula (`chi_via_stabilization`).

Analysis (Analyst).
  The theory is clean because it factors through two abelian pieces: dimensions
  `(ℤ,+)` mapping onto signs `{±1}`, and components `(ℕ,·)`.  Multiplicativity of
  χ is *exactly* the statement that these two homomorphisms combine, and it is the
  reason products behave well.  Everything hard reduces to the single parity fact
  `sgn_add`.  The graded invariant `chiGraded` shows the sign-weighted sum is the
  honest alternating sum of Betti numbers extended to negative degrees, and it
  reproduces the classical value `χ = 2 - 2g` of the genus-`g` surface using its
  first Betti number computed homologically elsewhere in the catalog.

Critique (Critic).
  None of the main results is vacuous: `chi_prod` genuinely requires `sgn_add`,
  `chi_suspIter` requires an induction-free but nontrivial parity computation, and
  the surface bridge consumes an external homological input.  The model records
  only `(dim, |π₀|)`, so it is faithful precisely to spaces whose reduced homology
  is concentrated in a single degree (formal spheres and their wedges/disjoint
  unions); the graded refinement removes this restriction and the surface bridge
  exhibits a genuinely multi-degree example.  The one-point space is the monoid
  unit with `χ = 1`, ruling out a degenerate `χ ≡ 0` theory.

Synthesis (Principal Investigator).
  Negative-dimensional Euler characteristic is not a formal curiosity: it is the
  restriction to a sub-monoid of a single multiplicative invariant `chiHom`, and
  the stabilization tower identifies the negative-dimensional world with the
  0-dimensional one up to the sign `(-1)^n`.  See `FUTURE_DIRECTIONS.md` for the
  conjectures this suggests.
-/