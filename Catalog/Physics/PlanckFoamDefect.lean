import Physics.PlanckFoamTopology

/-!
# The metric defect of Wheeler foam: counting the non-separated pairs

`t2Space_foam_iff` shows that the Wheeler foam `Foam X S ι` fails to be
Hausdorff exactly when the branch locus `S` is not open.  This file makes the
failure **quantitative**.

Define the *defect set* of the foam to be the set of ordered pairs of distinct
points whose neighbourhood filters are not disjoint — the pairs that a metric
(or any Hausdorff structure) would have to separate but cannot:

`defectSet = {(u, v) | u ≠ v ∧ ¬ Disjoint (𝓝 u) (𝓝 v)}`.

Main results:

* `disjoint_nhds_sheet_iff` — two distinct Planck branches over `x ∈ S` are
  separable **iff** `x ∈ interior S`.  So the whole obstruction lives on the
  topological boundary `S \ interior S` of the branch locus.
* `mem_defectSet_iff` — the defect set consists exactly of the pairs of distinct
  sheet copies of a point of `S \ interior S`.
* `defectEquiv`, `card_defectSet`, `card_defectSet_bool` — the defect set is in
  bijection with `(S \ interior S) × {(i,j) : i ≠ j}`, so with finitely many
  sheets its cardinality is `|S \ interior S| * (|ι|² - |ι|)`, and for
  two-sheeted foam simply `2 * |S \ interior S|`.

Physically: the "distance from metrizability" of a foam is a purely boundary
quantity.  A branch locus with nonempty interior is metrically harmless there;
what breaks the metric is a Planck branch point that is a limit of smooth
points.  Since `measure`-theoretically small sets can have large boundary and
vice versa, the metric defect is *not* a function of the branch density — it is
a function of the boundary alone.
-/

open Set Topology

namespace PlanckFoam

variable {X : Type*} [TopologicalSpace X] {ι : Type*} [TopologicalSpace ι]
  [DiscreteTopology ι] {S : Set X}

/-! ### Separability of two Planck branches -/

/-- **Sharp separation criterion.** Two distinct Planck branches over a branch
point `x` have disjoint neighbourhoods if and only if `x` is an *interior* point
of the branch locus. -/
theorem disjoint_nhds_sheet_iff {x : X} {i j : ι} (hij : i ≠ j) :
    Disjoint (𝓝 (sheet S i x)) (𝓝 (sheet S j x)) ↔ x ∈ interior S := by
  constructor
  · intro hdisj
    by_contra hx
    exact nhds_branch_not_disjoint hx hdisj
  · intro hx
    have hopen : ∀ k : ι, IsOpen (sheet S k '' interior S) := by
      intro k
      refine (isOpen_iff _).2 fun m => ?_
      by_cases hkm : k = m
      · subst hkm
        rw [slice_image_self]
        exact isOpen_interior
      · rw [slice_image_of_ne hkm,
          show interior S \ S = ∅ from diff_eq_empty.2 interior_subset]
        exact isOpen_empty
    refine Filter.disjoint_iff.2 ⟨sheet S i '' interior S,
      (hopen i).mem_nhds ⟨x, hx, rfl⟩, sheet S j '' interior S,
      (hopen j).mem_nhds ⟨x, hx, rfl⟩, ?_⟩
    rw [Set.disjoint_left]
    rintro w ⟨a, ha, rfl⟩ ⟨b, hb, hEq⟩
    obtain ⟨rfl, hc⟩ := sheet_eq_sheet.1 hEq
    exact (hc.resolve_left (Ne.symm hij)) (interior_subset hb)

/-! ### The defect set -/

/-- The **metric defect set** of the foam: ordered pairs of distinct points that
no pair of disjoint neighbourhoods can separate. -/
def defectSet (X : Type*) [TopologicalSpace X] (S : Set X) (ι : Type*) [TopologicalSpace ι] :
    Set (Foam X S ι × Foam X S ι) :=
  {p | p.1 ≠ p.2 ∧ ¬ Disjoint (𝓝 p.1) (𝓝 p.2)}

/-- **Localisation of the defect.** The non-separated pairs are exactly the
pairs of distinct sheet copies of a boundary point of the branch locus. -/
theorem mem_defectSet_iff [T2Space X] {u v : Foam X S ι} :
    (u, v) ∈ defectSet X S ι ↔
      ∃ (x : X) (i j : ι), i ≠ j ∧ x ∈ S \ interior S ∧ u = sheet S i x ∧ v = sheet S j x := by
  constructor
  · rintro ⟨hne, hnd⟩
    obtain ⟨i, x, rfl⟩ := exists_sheet u
    obtain ⟨j, y, rfl⟩ := exists_sheet v
    have hxy : x = y := by
      by_contra hxy
      obtain ⟨A, B, hA, hB, hxA, hyB, hAB⟩ :=
        separated_of_proj_ne (u := sheet S i x) (v := sheet S j y) (by simpa using hxy)
      exact hnd (Filter.disjoint_iff.2 ⟨A, hA.mem_nhds hxA, B, hB.mem_nhds hyB, hAB⟩)
    subst hxy
    have hij : i ≠ j := fun hc => hne (by rw [hc])
    have hxS : x ∈ S := by
      by_contra hxS
      exact hne (sheet_eq_sheet_of_notMem hxS)
    have hxint : x ∉ interior S := fun hc => hnd ((disjoint_nhds_sheet_iff hij).2 hc)
    exact ⟨x, i, j, hij, ⟨hxS, hxint⟩, rfl, rfl⟩
  · rintro ⟨x, i, j, hij, ⟨hxS, hxint⟩, rfl, rfl⟩
    exact ⟨sheet_ne_sheet hij hxS, fun hc => hxint ((disjoint_nhds_sheet_iff hij).1 hc)⟩

/-! ### Counting the defect -/

omit [TopologicalSpace ι] [DiscreteTopology ι] in
/-- The off-diagonal of the sheet index type, i.e. the set of *unordered choices
of two distinct Planck branches*, presented as ordered pairs. -/
theorem card_offDiag_index [Finite ι] :
    Nat.card {q : ι × ι // q.1 ≠ q.2} = Nat.card ι * Nat.card ι - Nat.card ι := by
  classical
  have hdiag : Nat.card {q : ι × ι // q.1 = q.2} = Nat.card ι := by
    refine Nat.card_eq_of_bijective (fun q => (q : ι × ι).1) ⟨?_, ?_⟩
    · rintro ⟨⟨a, b⟩, (rfl : a = b)⟩ ⟨⟨c, d⟩, (rfl : c = d)⟩ h
      exact Subtype.ext (Prod.ext h h)
    · intro i
      exact ⟨⟨(i, i), rfl⟩, rfl⟩
  haveI : Fintype ι := Fintype.ofFinite ι
  have h1 : Nat.card {q : ι × ι // q.1 ≠ q.2}
      = Fintype.card {q : ι × ι // ¬ (q.1 = q.2)} := by
    simp [Nat.card_eq_fintype_card]
  rw [h1, Fintype.card_subtype_compl, ← Nat.card_eq_fintype_card,
    ← Nat.card_eq_fintype_card, hdiag, Nat.card_prod]

/-- **The defect is a bijection onto boundary points times branch pairs.** -/
noncomputable def defectEquiv [T2Space X] :
    (↥(S \ interior S) × {q : ι × ι // q.1 ≠ q.2}) ≃ defectSet X S ι := by
  refine Equiv.ofBijective
    (fun p => ⟨(sheet S (p.2 : ι × ι).1 (p.1 : X), sheet S (p.2 : ι × ι).2 (p.1 : X)),
      mem_defectSet_iff.2 ⟨(p.1 : X), (p.2 : ι × ι).1, (p.2 : ι × ι).2, p.2.2, p.1.2, rfl, rfl⟩⟩)
    ⟨?_, ?_⟩
  · rintro ⟨⟨x, hx⟩, ⟨⟨i, j⟩, hij⟩⟩ ⟨⟨y, hy⟩, ⟨⟨k, l⟩, hkl⟩⟩ h
    have h1 : sheet S i x = sheet S k y := congrArg (fun q => q.1.1) h
    have h2 : sheet S j x = sheet S l y := congrArg (fun q => q.1.2) h
    obtain ⟨rfl, hik⟩ := sheet_eq_sheet.1 h1
    obtain ⟨-, hjl⟩ := sheet_eq_sheet.1 h2
    have hxS : x ∈ S := hx.1
    have hik' : i = k := hik.resolve_right (not_not.2 hxS)
    have hjl' : j = l := hjl.resolve_right (not_not.2 hxS)
    subst hik'; subst hjl'
    rfl
  · rintro ⟨⟨u, v⟩, huv⟩
    obtain ⟨x, i, j, hij, hx, rfl, rfl⟩ := mem_defectSet_iff.1 huv
    exact ⟨(⟨x, hx⟩, ⟨(i, j), hij⟩), rfl⟩

/-- **Metric defect counting.** With finitely many sheets the number of
non-separated ordered pairs is `|S \ interior S| * (|ι|² - |ι|)`: the defect is
carried entirely by the topological boundary of the branch locus. -/
theorem card_defectSet [T2Space X] [Finite ι] :
    Nat.card (defectSet X S ι)
      = Nat.card (S \ interior S : Set X) * (Nat.card ι * Nat.card ι - Nat.card ι) := by
  rw [← Nat.card_congr (defectEquiv (X := X) (S := S) (ι := ι)), Nat.card_prod,
    card_offDiag_index]

/-- For two-sheeted Wheeler foam the metric defect is exactly twice the number
of boundary branch points. -/
theorem card_defectSet_bool [T2Space X] :
    Nat.card (defectSet X S Bool) = 2 * Nat.card (S \ interior S : Set X) := by
  rw [card_defectSet]
  simp [Nat.card_eq_fintype_card, Nat.mul_comm]

/-- **Zero defect characterises Hausdorffness** (for a nontrivial sheet type and
a Hausdorff base): the foam is Hausdorff exactly when its defect set is
empty. -/
theorem defectSet_eq_empty_iff [T2Space X] [Nontrivial ι] :
    defectSet X S ι = ∅ ↔ T2Space (Foam X S ι) := by
  obtain ⟨i, j, hij⟩ := exists_pair_ne ι
  rw [t2Space_foam_iff]
  constructor
  · intro h
    refine ⟨‹T2Space X›, ?_⟩
    rw [← interior_eq_iff_isOpen]
    refine Subset.antisymm interior_subset fun x hx => ?_
    by_contra hxint
    have : (sheet S i x, sheet S j x) ∈ defectSet X S ι :=
      mem_defectSet_iff.2 ⟨x, i, j, hij, ⟨hx, hxint⟩, rfl, rfl⟩
    rw [h] at this
    exact this
  · rintro ⟨-, hS⟩
    refine eq_empty_iff_forall_notMem.2 fun p hp => ?_
    obtain ⟨x, k, l, -, hx, -, -⟩ := mem_defectSet_iff.1 (by simpa using hp)
    exact hx.2 (by rw [hS.interior_eq]; exact hx.1)

/-- **A concrete instance.** The two-sheeted foam over the real line with a
single Planck branch point at the origin has metric defect exactly `2`: the two
branch copies of the origin form the only non-separated ordered pairs. -/
theorem card_defectSet_line_point :
    Nat.card (defectSet ℝ {(0 : ℝ)} Bool) = 2 := by
  rw [card_defectSet_bool, interior_singleton, diff_empty]
  simp

end PlanckFoam