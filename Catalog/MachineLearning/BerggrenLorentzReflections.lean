import MachineLearning.BerggrenTreeFreeness

/-!
# The Berggren generators are reflection words in the odd Lorentzian lattice `ℤ^{2,1}`

This file is the first of three establishing the precise relationship between the
Berggren / Barning–Hall tree of primitive Pythagorean triples and the *even* Lorentzian
lattices of moonshine (the Leech-based `II(25,1)` and its relatives).

The catalog already knows that the three Barning–Hall matrices `mA`, `mB`, `mC` are
integral isometries of the Lorentzian form `Q(a,b,c) = a² + b² − c²` of signature `(2,1)`
(`MachineLearning.BerggrenHyperbolicStars`).  What was missing is the *reflection*
description, which is exactly the structure the automorphism groups of even Lorentzian
lattices are built out of (Conway/Vinberg theory).  Here we prove:

* `reflU` — the reflection `x ↦ x − 2⟨x,r⟩ r` in a vector `r` of **unit** norm
  `⟨r,r⟩ = 1`; it is an involutive integral isometry (`bil_reflU`, `reflU_involutive`).
* `mA_reflect`, `mB_reflect`, `mC_reflect` — each Berggren generator is an explicit
  product of unit reflections:
  `mA = s_{e₁} s_{(1,−1,−1)}`, `mC = s_{e₂} s_{(−1,1,−1)}`,
  `mB = s_{e₁} s_{e₂} s_{(1,1,−1)}`.
* `applyGens_isReflectionWord` — hence *every* node of the Berggren tree is obtained from
  the root by a word of reflections in unit vectors of `ℤ^{2,1}`; the Berggren monoid sits
  inside the reflection group of the odd Lorentzian lattice.
* `berggren_reflection_roots_odd` — all five reflection vectors used have **odd** norm
  `1`.  This is the exact numerical obstruction to a naive embedding into an even lattice
  such as `II(25,1)`, and it is repaired in
  `MachineLearning.BerggrenEvenLatticeEmbedding` by rescaling the form by `2`, which turns
  the unit vectors into honest *roots* of norm `2`.

## Lab notes

`#eval`-level data behind the statements (all re-proved below):

```
bil (1,0,0) (1,0,0) = 1      bil (0,1,0) (0,1,0) = 1
bil (1,-1,-1) (1,-1,-1) = 1  bil (1,1,-1) (1,1,-1) = 1   bil (-1,1,-1) (-1,1,-1) = 1
det mA = 1   (2 reflections)  det mB = -1  (3 reflections)  det mC = 1  (2 reflections)
```
-/

namespace BerggrenStars

/-! ### Reflections in unit-norm vectors -/

/-- The reflection of `ℤ^{2,1}` in a vector `r` with `⟨r,r⟩ = 1`:
`s_r(x) = x − 2⟨x,r⟩ r`.  (For unit norm no denominator appears, so this is defined over
`ℤ`.) -/
def reflU (r x : Vec) : Vec :=
  (x.1 - 2 * bil x r * r.1, x.2.1 - 2 * bil x r * r.2.1, x.2.2 - 2 * bil x r * r.2.2)

/-- A unit-norm reflection preserves the Lorentzian form. -/
theorem bil_reflU {r : Vec} (hr : bil r r = 1) (x y : Vec) :
    bil (reflU r x) (reflU r y) = bil x y := by
  obtain ⟨r1, r2, r3⟩ := r
  obtain ⟨x1, x2, x3⟩ := x
  obtain ⟨y1, y2, y3⟩ := y
  simp only [bil, reflU] at hr ⊢
  linear_combination (4 * (x1 * r1 + x2 * r2 - x3 * r3) *
    (y1 * r1 + y2 * r2 - y3 * r3)) * hr

/-- A unit-norm reflection preserves the quadratic form, hence the light cone. -/
theorem qform_reflU {r : Vec} (hr : bil r r = 1) (x : Vec) : qform (reflU r x) = qform x :=
  bil_reflU hr x x

theorem onCone_reflU {r : Vec} (hr : bil r r = 1) {x : Vec} (hx : OnCone x) :
    OnCone (reflU r x) := by
  simpa [OnCone, qform_reflU hr] using hx

/-- A unit-norm reflection is an involution. -/
theorem reflU_involutive {r : Vec} (hr : bil r r = 1) (x : Vec) :
    reflU r (reflU r x) = x := by
  obtain ⟨r1, r2, r3⟩ := r
  obtain ⟨x1, x2, x3⟩ := x
  simp only [bil, reflU, Prod.mk.injEq] at hr ⊢
  refine ⟨?_, ?_, ?_⟩
  · linear_combination (4 * r1 * (x1 * r1 + x2 * r2 - x3 * r3)) * hr
  · linear_combination (4 * r2 * (x1 * r1 + x2 * r2 - x3 * r3)) * hr
  · linear_combination (4 * r3 * (x1 * r1 + x2 * r2 - x3 * r3)) * hr

/-! ### The five Berggren reflection vectors -/

/-- The spacelike coordinate vector `e₁`. -/
def uE1 : Vec := (1, 0, 0)
/-- The spacelike coordinate vector `e₂`. -/
def uE2 : Vec := (0, 1, 0)
/-- The unit vector whose reflection builds `mA`. -/
def rootA : Vec := (1, -1, -1)
/-- The unit vector whose reflection builds `mB`. -/
def rootB : Vec := (1, 1, -1)
/-- The unit vector whose reflection builds `mC`. -/
def rootC : Vec := (-1, 1, -1)

theorem bil_uE1 : bil uE1 uE1 = 1 := by decide
theorem bil_uE2 : bil uE2 uE2 = 1 := by decide
theorem bil_rootA : bil rootA rootA = 1 := by decide
theorem bil_rootB : bil rootB rootB = 1 := by decide
theorem bil_rootC : bil rootC rootC = 1 := by decide

/-- **All Berggren reflection vectors have odd norm.**  This single parity fact is the
obstruction to placing the Berggren picture inside an even lattice without rescaling. -/
theorem berggren_reflection_roots_odd :
    ∀ r ∈ [uE1, uE2, rootA, rootB, rootC], ¬ Even (bil r r) := by
  decide

/-! ### The generators as reflection words -/

/-- `mA` is the product of the reflections in `(1,−1,−1)` and in `e₁`. -/
theorem mA_reflect (v : Vec) : mA v = reflU uE1 (reflU rootA v) := by
  obtain ⟨a, b, c⟩ := v
  simp only [mA, reflU, bil, uE1, rootA, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

/-- `mC` is the product of the reflections in `(−1,1,−1)` and in `e₂`. -/
theorem mC_reflect (v : Vec) : mC v = reflU uE2 (reflU rootC v) := by
  obtain ⟨a, b, c⟩ := v
  simp only [mC, reflU, bil, uE2, rootC, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

/-- `mB` is the product of *three* unit reflections: in `(1,1,−1)`, then `e₂`, then `e₁`.
(Its determinant is `−1`, whereas `mA` and `mC` have determinant `+1`, so an odd number of
reflections is forced.) -/
theorem mB_reflect (v : Vec) : mB v = reflU uE1 (reflU uE2 (reflU rootB v)) := by
  obtain ⟨a, b, c⟩ := v
  simp only [mB, reflU, bil, uE1, uE2, rootB, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

/-! ### Reflection words -/

/-- Apply a list of unit reflections, right to left. -/
def reflWord (rs : List Vec) (x : Vec) : Vec := rs.foldr reflU x

@[simp] theorem reflWord_nil (x : Vec) : reflWord [] x = x := rfl

@[simp] theorem reflWord_cons (r : Vec) (rs : List Vec) (x : Vec) :
    reflWord (r :: rs) x = reflU r (reflWord rs x) := rfl

theorem reflWord_append (rs ss : List Vec) (x : Vec) :
    reflWord (rs ++ ss) x = reflWord rs (reflWord ss x) := by
  simp [reflWord, List.foldr_append]

/-- A list of vectors all of unit norm. -/
def UnitList (rs : List Vec) : Prop := ∀ r ∈ rs, bil r r = 1

theorem unitList_append {rs ss : List Vec} (h : UnitList rs) (h' : UnitList ss) :
    UnitList (rs ++ ss) := by
  intro r hr
  rcases List.mem_append.mp hr with h1 | h1
  · exact h r h1
  · exact h' r h1

/-- The list of reflection vectors realising a single Berggren generator. -/
def genRefl : Gen → List Vec
  | Gen.A => [uE1, rootA]
  | Gen.B => [uE1, uE2, rootB]
  | Gen.C => [uE2, rootC]

theorem genRefl_unit (x : Gen) : UnitList (genRefl x) := by
  cases x <;> intro r hr <;>
    simp only [genRefl, List.mem_cons, List.not_mem_nil, or_false] at hr <;>
    rcases hr with rfl | rfl | rfl <;>
    simp [bil, uE1, uE2, rootA, rootB, rootC]

theorem genRefl_spec (x : Gen) (v : Vec) : Gen.act x v = reflWord (genRefl x) v := by
  cases x
  · simpa [genRefl, reflWord] using mA_reflect v
  · simpa [genRefl, reflWord] using mB_reflect v
  · simpa [genRefl, reflWord] using mC_reflect v

/-- The reflection word attached to a Berggren address. -/
def wordRefl (g : List Gen) : List Vec := (g.map genRefl).flatten

theorem wordRefl_unit (g : List Gen) : UnitList (wordRefl g) := by
  induction g with
  | nil => intro r hr; simp [wordRefl] at hr
  | cons x t ih =>
      have : wordRefl (x :: t) = genRefl x ++ wordRefl t := by
        simp [wordRefl]
      rw [this]
      exact unitList_append (genRefl_unit x) ih

/-- **Every Berggren word is a word of unit reflections.**  The Barning–Hall monoid lies
inside the reflection group of the odd Lorentzian lattice `ℤ^{2,1}`, generated by
reflections in vectors of norm `1`. -/
theorem applyGens_isReflectionWord (g : List Gen) (v : Vec) :
    applyGens g v = reflWord (wordRefl g) v := by
  induction g generalizing v with
  | nil => simp [wordRefl]
  | cons x t ih =>
      have hsplit : wordRefl (x :: t) = genRefl x ++ wordRefl t := by simp [wordRefl]
      rw [applyGens_cons, ih, hsplit, reflWord_append, genRefl_spec]

/-- Packaged existence form: the Berggren monoid is contained in the unit-reflection
group of `ℤ^{2,1}`. -/
theorem berggren_in_unit_reflection_group (g : List Gen) :
    ∃ rs : List Vec, UnitList rs ∧ ∀ v : Vec, applyGens g v = reflWord rs v :=
  ⟨wordRefl g, wordRefl_unit g, applyGens_isReflectionWord g⟩

/-- The number of reflections needed is the `A/C`-count plus three times the `B`-count;
in particular the `B`-generator is orientation reversing. -/
theorem wordRefl_length (g : List Gen) :
    (wordRefl g).length = (g.filter (fun x => decide (x = Gen.B))).length * 3 +
      (g.filter (fun x => decide (x ≠ Gen.B))).length * 2 := by
  induction g with
  | nil => simp [wordRefl]
  | cons x t ih =>
      have hsplit : wordRefl (x :: t) = genRefl x ++ wordRefl t := by simp [wordRefl]
      rw [hsplit, List.length_append, ih]
      cases x <;> simp [genRefl] <;> ring

end BerggrenStars