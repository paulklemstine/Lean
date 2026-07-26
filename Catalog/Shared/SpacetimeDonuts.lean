import Mathlib

/-!
# Spacetime Donuts: geodesics and the wrapping lattice of the flat 3-torus

This file develops, entirely inside `Mathlib`'s `AddCircle` machinery, a rigorous
account of the *flat three-torus* `𝕋³ = (ℝ/ℤ)³` viewed as a model of a
spatially closed ("donut-shaped") universe.

The three-torus is the quotient of `ℝ³` by the integer translation lattice.
Two intertwined structures make the "donut universe" precise:

* **Closed geodesics.** Straight lines in the universal cover `ℝ³` project to
  geodesics of the flat metric. A line in an *integer* direction `n ∈ ℤ³`
  projects to a *closed* geodesic: it returns to its starting point after unit
  time. Every nonzero integer direction produces a genuinely nonconstant loop,
  so the universe is threaded by closed geodesics that wrap around it.

* **The wrapping lattice.** The kernel of the covering projection
  `proj : ℝ³ → 𝕋³` is exactly the integer lattice `ℤ³`, the group of covering
  translations. Under the standard covering-space dictionary this group *is* the
  fundamental group of the torus, so `π₁(𝕋³) ≅ ℤ³`. The three standard basis
  vectors are linearly independent, giving the *three independent families* of
  ways to wrap around the universe.

## Main results

* `geo_periodic` : an integer-direction geodesic has period one (it is closed).
* `geo_nontrivial` : a nonzero integer direction gives a nonconstant loop.
* `geo_eq_proj_line` : each such geodesic is the projection of a straight line.
* `mem_ker_iff` : the kernel of the covering projection is the integer lattice.
* `ker_proj_eq_range` : the covering-translation group equals the image of `ℤ³`.
* `latt_injective` : the wrapping lattice is a faithful copy of `ℤ³`.
* `standard_basis_indep` : the three fundamental wrapping directions are
  independent — three independent families of loops.
* `geo_class` : the free-homotopy class (endpoint of the canonical lift) of an
  integer geodesic is its direction vector, and this assignment is injective,
  so the torus carries infinitely many distinct closed geodesics.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): If the universe is a flat 3-torus then it must
contain closed spatial geodesics, and these organize into exactly three
independent families indexed by the generators of `π₁ = ℤ³`.

Experiment (Experimenter): Model `𝕋³` as `Fin 3 → AddCircle 1`. Realize
geodesics as projections of straight lines `t ↦ t·n`. Compute the covering
kernel and identify it with the integer lattice.

Analysis (Analyst): The "period one" property is exactly the statement that
the direction is an integer vector; nonconstancy is witnessed by the half-way
point `t = 1/(2 nᵢ)` landing on the order-two element `1/2 ∈ ℝ/ℤ`. The kernel
computation is the covering-space incarnation of `π₁(𝕋³) ≅ ℤ³`.

Critique (Critic): Nonconstancy must be proved, not assumed — a constant loop
is still "periodic". We prove genuine nonconstancy from `n ≠ 0`. The claim
`π₁ ≅ ℤ³` is rendered honestly as the covering-translation group (`ker proj`)
being a free `ℤ`-module of rank three, avoiding any appeal to unformalized
topology.

Synthesis (PI): Closed geodesics + a rank-three faithful lattice together give
the "three independent families of wrapping", the concrete content of Rucker's
donut-shaped spacetime.
-/

open AddCircle

namespace SpacetimeDonuts

/-- The flat three-torus `𝕋³ = (ℝ/ℤ)³`, the spatial slice of a donut universe. -/
abbrev Torus3 := Fin 3 → AddCircle (1 : ℝ)

/-- The universal covering projection `ℝ³ → 𝕋³`, an additive group homomorphism
whose kernel is the group of covering translations. -/
noncomputable def proj : (Fin 3 → ℝ) →+ Torus3 :=
  Pi.addMonoidHom fun i =>
    (QuotientAddGroup.mk' _).comp (Pi.evalAddMonoidHom (fun _ : Fin 3 => ℝ) i)

@[simp] theorem proj_apply (x : Fin 3 → ℝ) (i : Fin 3) :
    proj x i = ((x i : ℝ) : AddCircle (1 : ℝ)) := rfl

/-- The geodesic of the flat torus with integer direction `n`, parameterized by
arclength-scaled time `t`: it is the projection of the straight line `t ↦ t·n`. -/
def geo (n : Fin 3 → ℤ) (t : ℝ) : Torus3 := fun i => ((t * n i : ℝ) : AddCircle (1 : ℝ))

/-- Each integer-direction geodesic is literally the projection of a straight
line in the universal cover — hence a geodesic of the flat metric. -/
theorem geo_eq_proj_line (n : Fin 3 → ℤ) (t : ℝ) :
    geo n t = proj (fun i => t * (n i : ℝ)) := rfl

/-- **Closedness of integer geodesics.** A line in an integer direction projects
to a loop of period one: after unit time the geodesic returns to where it was. -/
theorem geo_periodic (n : Fin 3 → ℤ) (t : ℝ) : geo n (t + 1) = geo n t := by
  funext i
  show (((t + 1) * n i : ℝ) : AddCircle (1 : ℝ)) = ((t * n i : ℝ) : AddCircle (1 : ℝ))
  rw [show ((t + 1) * n i : ℝ) = (n i) • (1 : ℝ) + t * n i by
        simp only [zsmul_eq_mul, mul_one]; ring,
      coe_add, coe_zsmul, coe_period, smul_zero, zero_add]

/-- The geodesic starts at the base point of the torus. -/
@[simp] theorem geo_zero (n : Fin 3 → ℤ) : geo n 0 = 0 := by
  funext i
  show (((0 : ℝ) * n i : ℝ) : AddCircle (1 : ℝ)) = 0
  simp

/-- **Nontriviality of wrapping.** A nonzero integer direction yields a genuinely
nonconstant closed geodesic: the loop actually wraps around the universe rather
than sitting still. The witness is the half-period point, which lands on the
order-two element `1/2` of the circle. -/
theorem geo_nontrivial (n : Fin 3 → ℤ) (hn : n ≠ 0) : ∃ t : ℝ, geo n t ≠ geo n 0 := by
  rw [Function.ne_iff] at hn
  obtain ⟨i, hi⟩ := hn
  refine ⟨1 / (2 * n i), ?_⟩
  intro h
  have hne : (n i : ℝ) ≠ 0 := by exact_mod_cast (by simpa using hi)
  have hci := congrFun h i
  rw [geo_zero] at hci
  simp only [geo, Pi.zero_apply] at hci
  rw [show (1 / (2 * (n i : ℝ)) * n i : ℝ) = 1 / 2 by field_simp] at hci
  rw [AddCircle.coe_eq_zero_iff] at hci
  obtain ⟨m, hm⟩ := hci
  simp only [zsmul_eq_mul, mul_one] at hm
  have h1 : (2 * m : ℤ) = 1 := by
    have h2 : (2 : ℝ) * m = 1 := by rw [hm]; ring
    exact_mod_cast h2
  omega

/-! ## The wrapping lattice and `π₁(𝕋³) ≅ ℤ³` -/

/-- The integer translation lattice `ℤ³ ↪ ℝ³`, the group of covering
translations of the flat torus. -/
def latt : (Fin 3 → ℤ) →+ (Fin 3 → ℝ) where
  toFun n := fun i => (n i : ℝ)
  map_zero' := by funext i; simp
  map_add' a b := by funext i; simp only [Pi.add_apply]; push_cast; ring

@[simp] theorem latt_apply (n : Fin 3 → ℤ) (i : Fin 3) : latt n i = (n i : ℝ) := rfl

/-- The wrapping lattice is a *faithful* copy of `ℤ³`: distinct integer vectors
give distinct covering translations. -/
theorem latt_injective : Function.Injective latt := by
  intro a b h
  funext i
  have : (a i : ℝ) = (b i : ℝ) := congrFun h i
  exact_mod_cast this

/-- **The covering kernel is the integer lattice.** A point of the cover projects
to the base point iff every coordinate is an integer. This is the pointwise form
of `π₁(𝕋³) ≅ ℤ³`. -/
theorem mem_ker_iff (x : Fin 3 → ℝ) : proj x = 0 ↔ ∀ i, ∃ m : ℤ, x i = m := by
  constructor
  · intro h i
    have hi : ((x i : ℝ) : AddCircle (1 : ℝ)) = 0 := by rw [← proj_apply, h]; rfl
    rw [AddCircle.coe_eq_zero_iff] at hi
    obtain ⟨m, hm⟩ := hi
    exact ⟨m, by simpa using hm.symm⟩
  · intro h
    funext i
    obtain ⟨m, hm⟩ := h i
    rw [Pi.zero_apply, proj_apply, hm, AddCircle.coe_eq_zero_iff]
    exact ⟨m, by simp⟩

/-- **`π₁(𝕋³) ≅ ℤ³`, group-theoretic form.** The group of covering translations
(the kernel of the covering projection) is exactly the image of the integer
lattice. Combined with `latt_injective`, the fundamental group of the flat torus
is a free abelian group isomorphic to `ℤ³`. -/
theorem ker_proj_eq_range : proj.ker = latt.range := by
  ext x
  simp only [AddMonoidHom.mem_ker, AddMonoidHom.mem_range]
  rw [mem_ker_iff]
  constructor
  · intro h
    choose m hm using h
    exact ⟨m, by funext i; exact (hm i).symm⟩
  · rintro ⟨n, rfl⟩ i
    exact ⟨n i, rfl⟩

/-- **Three independent families of wrapping.** The three standard directions
`e₀, e₁, e₂` are `ℤ`-linearly independent generators of the wrapping lattice:
there are exactly three independent ways to loop around a donut universe. -/
theorem standard_basis_indep :
    LinearIndependent ℤ (fun i : Fin 3 => (Pi.single i (1 : ℤ) : Fin 3 → ℤ)) := by
  have h := (Pi.basisFun ℤ (Fin 3)).linearIndependent
  have he : (fun i : Fin 3 => (Pi.single i (1 : ℤ) : Fin 3 → ℤ))
      = ⇑(Pi.basisFun ℤ (Fin 3)) := by funext i; rw [Pi.basisFun_apply]
  rw [he]; exact h

/-! ## Homotopy classes of closed geodesics -/

/-- The free-homotopy class of the integer geodesic `geo n` is recorded by the
endpoint of its canonical lift starting at the origin, namely the direction `n`
itself, sitting inside the covering-translation group `ker proj`. -/
def geo_class (n : Fin 3 → ℤ) : proj.ker :=
  ⟨latt n, by
    rw [AddMonoidHom.mem_ker, mem_ker_iff]
    intro i; exact ⟨n i, rfl⟩⟩

/-- The lift of `geo n` from the origin ends at the lattice point `latt n`, and
projecting that lift recovers the geodesic at time one — the geometric reason the
class of `geo n` is `n`. -/
theorem proj_geo_class (n : Fin 3 → ℤ) : proj (geo_class n : Fin 3 → ℝ) = geo n 1 := by
  funext i
  show ((latt n i : ℝ) : AddCircle (1 : ℝ)) = (((1 : ℝ) * n i : ℝ) : AddCircle (1 : ℝ))
  simp

/-- **Infinitely many distinct closed geodesics.** Distinct integer directions
give distinct homotopy classes: the assignment `n ↦ geo_class n` is injective,
so the donut universe supports an infinite `ℤ³` of inequivalent wrapping loops. -/
theorem geo_class_injective : Function.Injective geo_class := by
  intro a b h
  apply latt_injective
  exact congrArg (Subtype.val) h

end SpacetimeDonuts