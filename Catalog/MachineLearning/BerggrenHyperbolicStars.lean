import Mathlib

/-!
# The Lorentzian skeleton of the Berggren / Barning–Hall tree

## Motivation

Plotting the Berggren tree of primitive Pythagorean triples inside a hyperbolic disc
produces striking visual artefacts: besides the lines that radiate from the centre of
the disc, one sees *stars* — bundles of curves radiating from isolated points **on the
boundary circle**.

This file supplies the algebraic explanation.  A Pythagorean triple `(a,b,c)` is exactly
an integer vector on the light cone of the Lorentzian form

  `Q(a,b,c) = a² + b² − c²`   (signature `(2,1)`).

The three Berggren matrices are integral isometries of `Q`, i.e. elements of the Lorentz
group `O(2,1;ℤ)`, which is the isometry group of the hyperbolic plane in the hyperboloid
(Klein) model.  Plotting a triple in the disc is plotting a null ray, i.e. an *ideal
point* of `H²`.

The visual structure is then governed by the **conjugacy type** of the three generators:

* `mA` and `mC` are **parabolic** (unipotent): each one conserves a nonzero linear
  functional (`c − b` resp. `c − a`) whose vanishing locus is a rational null direction.
  Consequently their orbits crawl along **horocycles** and accumulate at *one rational
  boundary point*, at a quadratic (polynomial) rate.  This is the star.
* `mB` is **hyperbolic**: it only conserves `|a − b|`, whose vanishing locus is the
  *irrational* null direction `(1,1,√2)`.  Its orbits run along a geodesic and reach the
  boundary at an exponential rate.

This file establishes the algebra: Lorentz invariance, the conserved charges, exact
closed forms for the two unipotent flows (the `k`-th iterate is a *quadratic polynomial
in `k`*, the signature of a Jordan block of size 3), positivity/primitivity preservation,
and the exponential growth of the hyperbolic flow.  The analytic consequences (the actual
limits on the boundary circle, the horocyclic star, the tangency law) are in
`MachineLearning.BerggrenHorocycleStars`.

The three matrices agree with the catalog's `B₃` and with the inverse matrices used in
`Shared/BerggrenTrees/Parent_hyp_lt.lean`.
-/

namespace BerggrenStars

/-- Integer vectors of the ambient Lorentzian lattice `ℤ^{2,1}`. -/
abbrev Vec : Type := ℤ × ℤ × ℤ

/-- The Lorentzian bilinear form of signature `(2,1)`:
`⟨v, w⟩ = v₁w₁ + v₂w₂ − v₃w₃`. -/
def bil (v w : Vec) : ℤ := v.1 * w.1 + v.2.1 * w.2.1 - v.2.2 * w.2.2

/-- The associated quadratic form `Q(a,b,c) = a² + b² − c²`. -/
def qform (v : Vec) : ℤ := bil v v

/-- Being on the light cone is exactly being a Pythagorean triple. -/
def OnCone (v : Vec) : Prop := qform v = 0

theorem onCone_iff (a b c : ℤ) : OnCone (a, b, c) ↔ a ^ 2 + b ^ 2 = c ^ 2 := by
  constructor <;> intro h <;> simp only [OnCone, qform, bil] at * <;> nlinarith [h]

theorem bil_comm (v w : Vec) : bil v w = bil w v := by
  simp only [bil]; ring

/-! ### The three Berggren generators -/

/-- First Berggren generator (Barning–Hall matrix `A`). -/
def mA (v : Vec) : Vec :=
  (v.1 - 2 * v.2.1 + 2 * v.2.2, 2 * v.1 - v.2.1 + 2 * v.2.2, 2 * v.1 - 2 * v.2.1 + 3 * v.2.2)

/-- Second Berggren generator (Barning–Hall matrix `B`). -/
def mB (v : Vec) : Vec :=
  (v.1 + 2 * v.2.1 + 2 * v.2.2, 2 * v.1 + v.2.1 + 2 * v.2.2, 2 * v.1 + 2 * v.2.1 + 3 * v.2.2)

/-- Third Berggren generator (Barning–Hall matrix `C`; the catalog's `B₃`). -/
def mC (v : Vec) : Vec :=
  (-v.1 + 2 * v.2.1 + 2 * v.2.2, -2 * v.1 + v.2.1 + 2 * v.2.2, -2 * v.1 + 2 * v.2.1 + 3 * v.2.2)

/-- The root of the tree. -/
def root : Vec := (3, 4, 5)

/-! ### Lorentz invariance: the generators lie in `O(2,1;ℤ)` -/

theorem bil_mA (v w : Vec) : bil (mA v) (mA w) = bil v w := by
  obtain ⟨a, b, c⟩ := v; obtain ⟨x, y, z⟩ := w; simp only [bil, mA]; ring

theorem bil_mB (v w : Vec) : bil (mB v) (mB w) = bil v w := by
  obtain ⟨a, b, c⟩ := v; obtain ⟨x, y, z⟩ := w; simp only [bil, mB]; ring

theorem bil_mC (v w : Vec) : bil (mC v) (mC w) = bil v w := by
  obtain ⟨a, b, c⟩ := v; obtain ⟨x, y, z⟩ := w; simp only [bil, mC]; ring

theorem qform_mA (v : Vec) : qform (mA v) = qform v := bil_mA v v
theorem qform_mB (v : Vec) : qform (mB v) = qform v := bil_mB v v
theorem qform_mC (v : Vec) : qform (mC v) = qform v := bil_mC v v

theorem onCone_mA {v : Vec} (h : OnCone v) : OnCone (mA v) := by
  simpa [OnCone, qform_mA] using h
theorem onCone_mB {v : Vec} (h : OnCone v) : OnCone (mB v) := by
  simpa [OnCone, qform_mB] using h
theorem onCone_mC {v : Vec} (h : OnCone v) : OnCone (mC v) := by
  simpa [OnCone, qform_mC] using h

theorem onCone_root : OnCone root := by
  simp [OnCone, qform, bil, root]

/-- Every node of the Berggren tree, reached by an arbitrary word in the generators,
stays on the light cone: the tree consists of Pythagorean triples. -/
theorem onCone_of_word (w : List (Vec → Vec))
    (hw : ∀ f ∈ w, f = mA ∨ f = mB ∨ f = mC) {v : Vec} (hv : OnCone v) :
    OnCone (w.foldr (fun f x => f x) v) := by
  induction w with
  | nil => simpa using hv
  | cons f t ih =>
      have ht : ∀ g ∈ t, g = mA ∨ g = mB ∨ g = mC := fun g hg => hw g (List.mem_cons_of_mem _ hg)
      have hrec := ih ht
      rcases hw f (List.mem_cons_self ..) with rfl | rfl | rfl
      · simpa using onCone_mA hrec
      · simpa using onCone_mB hrec
      · simpa using onCone_mC hrec

/-! ### Conserved charges: the linear functionals fixed by each generator

Each generator preserves a linear functional; the boundary point at which its orbits
accumulate is precisely the null direction on which that functional vanishes.  This is
the structural heart of the whole picture. -/

/-- `mC` conserves `c − a`.  The null direction with `c = a` is `(1,0,1)`. -/
theorem charge_mC (v : Vec) : (mC v).2.2 - (mC v).1 = v.2.2 - v.1 := by
  obtain ⟨a, b, c⟩ := v; simp only [mC]; ring

/-- `mA` conserves `c − b`.  The null direction with `c = b` is `(0,1,1)`. -/
theorem charge_mA (v : Vec) : (mA v).2.2 - (mA v).2.1 = v.2.2 - v.2.1 := by
  obtain ⟨a, b, c⟩ := v; simp only [mA]; ring

/-- `mB` *negates* `a − b`: it is the `(−1)`-eigenvector.  Hence `|a − b|` is conserved,
and the invariant null direction `a = b` is the **irrational** point `(1,1,√2)`. -/
theorem charge_mB (v : Vec) : (mB v).1 - (mB v).2.1 = -(v.1 - v.2.1) := by
  obtain ⟨a, b, c⟩ := v; simp only [mB]; ring

/-- The conserved charges are exactly the Lorentz products with the invariant null
vectors: `⟨v, (1,0,1)⟩ = a − c`. -/
theorem bil_with_e1 (v : Vec) : bil v (1, 0, 1) = v.1 - v.2.2 := by
  simp only [bil]; ring

theorem bil_with_e2 (v : Vec) : bil v (0, 1, 1) = v.2.1 - v.2.2 := by
  simp only [bil]; ring

/-- `(1,0,1)` is a null vector fixed by `mC`: it is the parabolic fixed point. -/
theorem mC_fixes_e1 : mC (1, 0, 1) = (1, 0, 1) := by decide

/-- `(0,1,1)` is a null vector fixed by `mA`. -/
theorem mA_fixes_e2 : mA (0, 1, 1) = (0, 1, 1) := by decide

theorem onCone_e1 : OnCone (1, 0, 1) := by simp [OnCone, qform, bil]
theorem onCone_e2 : OnCone (0, 1, 1) := by simp [OnCone, qform, bil]

/-! ### Unipotency: `mA` and `mC` are parabolic

The exact closed form of the `k`-th iterate is a *quadratic* polynomial in `k`; this is
the fingerprint of a rank-3 unipotent Jordan block, i.e. of a parabolic isometry of `H²`. -/

/-- Closed form for the `mC`-flow.  Writing `d = c − a` for the conserved charge,
`mC^[k](a,b,c) = (c_k − d, b + 2kd, c_k)` with `c_k = c + 2kb + 2k²d`. -/
theorem mC_iterate (v : Vec) (k : ℕ) :
    mC^[k] v =
      (v.2.2 + 2 * (k : ℤ) * v.2.1 + 2 * (k : ℤ) ^ 2 * (v.2.2 - v.1) - (v.2.2 - v.1),
        v.2.1 + 2 * (k : ℤ) * (v.2.2 - v.1),
        v.2.2 + 2 * (k : ℤ) * v.2.1 + 2 * (k : ℤ) ^ 2 * (v.2.2 - v.1)) := by
  induction k with
  | zero => obtain ⟨a, b, c⟩ := v; simp
  | succ n ih =>
      rw [Function.iterate_succ_apply', ih]
      simp only [mC, Prod.mk.injEq]
      push_cast
      refine ⟨by ring, by ring, by ring⟩

/-- Closed form for the `mA`-flow.  Writing `e = c − b`,
`mA^[k](a,b,c) = (a + 2ke, c_k − e, c_k)` with `c_k = c + 2ka + 2k²e`. -/
theorem mA_iterate (v : Vec) (k : ℕ) :
    mA^[k] v =
      (v.1 + 2 * (k : ℤ) * (v.2.2 - v.2.1),
        v.2.2 + 2 * (k : ℤ) * v.1 + 2 * (k : ℤ) ^ 2 * (v.2.2 - v.2.1) - (v.2.2 - v.2.1),
        v.2.2 + 2 * (k : ℤ) * v.1 + 2 * (k : ℤ) ^ 2 * (v.2.2 - v.2.1)) := by
  induction k with
  | zero => obtain ⟨a, b, c⟩ := v; simp
  | succ n ih =>
      rw [Function.iterate_succ_apply', ih]
      simp only [mA, Prod.mk.injEq]
      push_cast
      refine ⟨by ring, by ring, by ring⟩

/-- The hypotenuse along the `mC`-flow is a genuine quadratic polynomial in the step
number, with leading coefficient the conserved charge. -/
theorem mC_iterate_hyp (v : Vec) (k : ℕ) :
    ((mC^[k] v).2.2 : ℤ) = v.2.2 + 2 * k * v.2.1 + 2 * k ^ 2 * (v.2.2 - v.1) := by
  rw [mC_iterate]

/-- Along the `mC`-flow the charge `c − a` really is constant, in closed form. -/
theorem mC_iterate_charge (v : Vec) (k : ℕ) :
    (mC^[k] v).2.2 - (mC^[k] v).1 = v.2.2 - v.1 := by
  rw [mC_iterate]; ring

theorem mA_iterate_charge (v : Vec) (k : ℕ) :
    (mA^[k] v).2.2 - (mA^[k] v).2.1 = v.2.2 - v.2.1 := by
  rw [mA_iterate]; ring

/-! ### Positivity, and the boundary charge is positive -/

/-- For a Pythagorean triple with a positive even leg, the charge `c − a` is positive:
the plotted point is *not* the fixed point itself. -/
theorem charge_pos {a b c : ℤ} (h : OnCone (a, b, c)) (hb : 0 < b) (hc : 0 < c) :
    0 < c - a := by
  rw [onCone_iff] at h
  nlinarith [sq_nonneg (a - c), sq_nonneg (a + c)]

/-- `mC` preserves positivity of all three entries of a Pythagorean triple. -/
theorem mC_pos {a b c : ℤ} (h : OnCone (a, b, c)) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < (mC (a, b, c)).1 ∧ 0 < (mC (a, b, c)).2.1 ∧ 0 < (mC (a, b, c)).2.2 := by
  have hd : 0 < c - a := charge_pos h hb hc
  refine ⟨?_, ?_, ?_⟩ <;> simp only [mC] <;> omega

/-- `mA` preserves positivity of all three entries of a Pythagorean triple. -/
theorem mA_pos {a b c : ℤ} (h : OnCone (a, b, c)) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < (mA (a, b, c)).1 ∧ 0 < (mA (a, b, c)).2.1 ∧ 0 < (mA (a, b, c)).2.2 := by
  have he : 0 < c - b := by
    rw [onCone_iff] at h; nlinarith [sq_nonneg (b - c), sq_nonneg (b + c)]
  refine ⟨?_, ?_, ?_⟩ <;> simp only [mA] <;> omega

/-- `mB` preserves positivity trivially, and increases the hypotenuse by a factor `≥ 3`. -/
theorem mB_pos {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < (mB (a, b, c)).1 ∧ 0 < (mB (a, b, c)).2.1 ∧ 0 < (mB (a, b, c)).2.2 := by
  refine ⟨?_, ?_, ?_⟩ <;> simp only [mB] <;> omega

/-! ### The hyperbolic generator grows exponentially -/

/-- One step of the hyperbolic flow multiplies the hypotenuse by at least 3. -/
theorem mB_hyp_growth {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) :
    3 * c < (mB (a, b, c)).2.2 := by
  simp only [mB]; omega

/-- The `mB`-flow is exponential: `c_k ≥ 3^k c₀`.  (Contrast `mC_iterate_hyp`, where the
hypotenuse only grows quadratically.) -/
theorem mB_iterate_growth {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (k : ℕ) :
    3 ^ k * c ≤ (mB^[k] (a, b, c)).2.2 ∧
      0 < (mB^[k] (a, b, c)).1 ∧ 0 < (mB^[k] (a, b, c)).2.1 := by
  induction k with
  | zero => simpa using ⟨ha, hb⟩
  | succ n ih =>
      obtain ⟨hgrow, hpos1, hpos2⟩ := ih
      have hcn : 0 < (mB^[n] (a, b, c)).2.2 := by
        have : (0:ℤ) < 3 ^ n * c := by positivity
        omega
      obtain ⟨p, q, r⟩ := (mB^[n] (a, b, c))
      simp only at hpos1 hpos2 hcn hgrow
      rw [Function.iterate_succ_apply']
      refine ⟨?_, ?_, ?_⟩ <;> simp only [mB]
      · have : (3:ℤ) ^ (n + 1) * c = 3 * (3 ^ n * c) := by ring
        omega
      · omega
      · omega

/-- Along the `mB`-flow the charge `a − b` only alternates in sign, so `|a − b|` is
constant: the hyperbolic flow slides along the geodesic asymptotic to the null direction
`a = b`. -/
theorem mB_iterate_charge (v : Vec) (k : ℕ) :
    (mB^[k] v).1 - (mB^[k] v).2.1 = (-1) ^ k * (v.1 - v.2.1) := by
  induction k with
  | zero => simp
  | succ n ih =>
      rw [Function.iterate_succ_apply', charge_mB, ih]
      ring

/-! ### Sanity checks against the concrete tree -/

theorem mA_root : mA root = (5, 12, 13) := by decide
theorem mB_root : mB root = (21, 20, 29) := by decide
theorem mC_root : mC root = (15, 8, 17) := by decide

/-- The classical `A`-branch `(2k+3, 2(k+1)(k+2), 2(k+1)(k+2)+1)`: the "one apart"
family, sitting on a single horocycle at the boundary point `(0,1)`. -/
theorem mA_branch (k : ℕ) :
    mA^[k] root = (2 * (k : ℤ) + 3, 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2),
      2 * ((k : ℤ) + 1) * ((k : ℤ) + 2) + 1) := by
  rw [mA_iterate]
  simp only [root, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

/-- The classical `C`-branch `((2k+1)(2k+3), 4k+4, (2k+2)²+1)`: the "two apart" family,
on a single horocycle at the boundary point `(1,0)`. -/
theorem mC_branch (k : ℕ) :
    mC^[k] root = ((2 * (k : ℤ) + 1) * (2 * (k : ℤ) + 3), 4 * (k : ℤ) + 4,
      (2 * (k : ℤ) + 2) ^ 2 + 1) := by
  rw [mC_iterate]
  simp only [root, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

end BerggrenStars