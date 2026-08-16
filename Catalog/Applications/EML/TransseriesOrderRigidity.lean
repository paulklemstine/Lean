import Applications.EML.TransseriesRoots

/-!
# Order rigidity of the transseries field, and the quadratic fragment of real closedness

`Applications.EML.TransseriesRoots` established the *root half* of real closedness for the
EML transseries field `EMLTS.TS`:

* every positive transseries has an `n`-th root for every `n ≠ 0`;
* the squares are exactly the nonnegative transseries;
* every transseries has an `n`-th root for every odd `n`.

This file draws the structural consequences that follow from "squares = nonnegatives"
alone, without needing the (much harder) odd-degree root theorem.

The key point is *definability of the ordering*: `f ≤ g ↔ IsSquare (g - f)`.  So the
asymptotic ordering of transseries — the whole content of "which transseries grows
faster" — is not extra data, it is already encoded in the ring structure.  Two immediate
consequences are proved:

* the asymptotic ordering is the **unique** ordering making `TS` an ordered ring
  (`EMLTS.unique_order`);
* **every** ring homomorphism out of `TS` into an ordered field is automatically monotone
  (`EMLTS.ringHom_monotone`); in particular every field automorphism of `TS`
  automatically preserves the asymptotic growth ordering, even though it is a purely
  algebraic object.

Finally we record the quadratic fragment of real closedness: every quadratic with
nonnegative discriminant splits (`EMLTS.exists_root_quadratic`), which is the degree-`2`
case of the statement that `TS` is real closed.

## Main results

* `EMLTS.le_iff_isSquare_sub` : the ordering is definable from the ring structure.
* `EMLTS.unique_order` : uniqueness of the ordered-ring structure on `TS`.
* `EMLTS.ringHom_monotone` : automatic monotonicity of ring maps out of `TS`.
* `EMLTS.exists_root_quadratic` : the quadratic formula holds in `TS`.
* `EMLTS.quadratic_solvable_iff` : a monic quadratic has a root iff its discriminant is a
  nonnegative transseries.
-/

noncomputable section

open HahnSeries

namespace EMLTS

/-! ## Definability of the asymptotic ordering -/

/-- **The asymptotic ordering is definable in the ring language.**  One transseries is at
most another exactly when the difference is a square. -/
theorem le_iff_isSquare_sub (f g : TS) : f ≤ g ↔ IsSquare (g - f) := by
  rw [isSquare_iff_nonneg, sub_nonneg]

/-- The positive cone consists exactly of the nonzero squares. -/
theorem pos_iff_ne_zero_and_isSquare (f : TS) : 0 < f ↔ f ≠ 0 ∧ IsSquare f := by
  rw [isSquare_iff_nonneg]
  constructor
  · exact fun h => ⟨h.ne', h.le⟩
  · exact fun ⟨h1, h2⟩ => lt_of_le_of_ne h2 (Ne.symm h1)

/-- Every transseries is a square or the negative of a square: `TS` is a *Euclidean*
ordered field. -/
theorem isSquare_or_isSquare_neg (f : TS) : IsSquare f ∨ IsSquare (-f) := by
  rcases le_total 0 f with h | h
  · exact Or.inl (isSquare_iff_nonneg.mpr h)
  · exact Or.inr (isSquare_iff_nonneg.mpr (neg_nonneg.mpr h))

/-- **Uniqueness of the ordering.**  Any partial order on `TS` compatible with the ring
structure (in the weak sense that squares are nonnegative and the order is translation
invariant) refines to exactly the asymptotic ordering. -/
theorem unique_order (r : TS → TS → Prop)
    (hsq : ∀ s : TS, r 0 (s * s))
    (htrans : ∀ a b c : TS, r a b → r (a + c) (b + c))
    (hanti : ∀ a b : TS, r a b → r b a → a = b) :
    ∀ f g : TS, r f g ↔ f ≤ g := by
  intro f g
  constructor
  · intro h
    by_contra hlt
    have hgf : g < f := lt_of_not_ge hlt
    obtain ⟨s, hs⟩ := isSquare_iff_nonneg.mpr (sub_nonneg.mpr hgf.le)
    have h1 : r 0 (f - g) := by rw [hs]; exact hsq s
    have h2 : r g f := by
      have := htrans 0 (f - g) g h1
      simpa using this
    exact absurd (hanti g f h2 h) hgf.ne
  · intro h
    obtain ⟨s, hs⟩ := isSquare_iff_nonneg.mpr (sub_nonneg.mpr h)
    have h1 : r 0 (g - f) := by rw [hs]; exact hsq s
    have := htrans 0 (g - f) f h1
    simpa using this

/-- **Automatic monotonicity.**  Because the ordering of `TS` is definable from its ring
structure, every ring homomorphism from `TS` into an ordered field preserves the
asymptotic ordering — no continuity or order hypothesis is needed. -/
theorem ringHom_monotone {K : Type*} [Field K] [LinearOrder K] [IsStrictOrderedRing K]
    (varphi : TS →+* K) : Monotone varphi := by
  intro f g h
  obtain ⟨s, hs⟩ := (le_iff_isSquare_sub f g).mp h
  have : varphi g - varphi f = varphi s * varphi s := by
    rw [← map_sub, hs, map_mul]
  have hnn : 0 ≤ varphi g - varphi f := by
    rw [this]
    exact mul_self_nonneg _
  linarith

/-- Every field automorphism of the transseries field preserves the asymptotic growth
ordering. -/
theorem ringEquiv_monotone (varphi : TS ≃+* TS) : Monotone varphi :=
  ringHom_monotone (varphi : TS →+* TS)

/-! ## The quadratic fragment of real closedness -/

/-- **The quadratic formula in the transseries field.**  A quadratic with nonnegative
discriminant has a root. -/
theorem exists_root_quadratic {a b c : TS} (ha : a ≠ 0) (hdisc : 0 ≤ b ^ 2 - 4 * a * c) :
    ∃ z : TS, a * z ^ 2 + b * z + c = 0 := by
  obtain ⟨s, hs⟩ := exists_sq_of_nonneg hdisc
  refine ⟨(-b + s) / (2 * a), ?_⟩
  have h2 : (2 : TS) ≠ 0 := two_ne_zero
  have h2a : (2 : TS) * a ≠ 0 := mul_ne_zero h2 ha
  field_simp
  linear_combination hs

/-- Both roots of a quadratic with nonnegative discriminant. -/
theorem exists_two_roots_quadratic {a b c : TS} (ha : a ≠ 0)
    (hdisc : 0 ≤ b ^ 2 - 4 * a * c) :
    ∃ z w : TS, a * z ^ 2 + b * z + c = 0 ∧ a * w ^ 2 + b * w + c = 0 ∧ z + w = -b / a := by
  obtain ⟨s, hs⟩ := exists_sq_of_nonneg hdisc
  have h2a : (2 : TS) * a ≠ 0 := mul_ne_zero two_ne_zero ha
  refine ⟨(-b + s) / (2 * a), (-b - s) / (2 * a), ?_, ?_, ?_⟩
  · field_simp
    linear_combination hs
  · field_simp
    linear_combination hs
  · field_simp
    ring

/-- **Solvability criterion.**  A monic quadratic `z ^ 2 + b z + c` has a root in the
transseries field precisely when its discriminant is a nonnegative transseries. -/
theorem quadratic_solvable_iff (b c : TS) :
    (∃ z : TS, z ^ 2 + b * z + c = 0) ↔ 0 ≤ b ^ 2 - 4 * c := by
  constructor
  · rintro ⟨z, hz⟩
    have key : (2 * z + b) ^ 2 = b ^ 2 - 4 * c := by linear_combination 4 * hz
    rw [← key]
    exact sq_nonneg _
  · intro h
    have h' : (0 : TS) ≤ b ^ 2 - 4 * 1 * c := by simpa using h
    obtain ⟨z, hz⟩ := exists_root_quadratic (a := 1) one_ne_zero h'
    exact ⟨z, by rw [← hz]; ring⟩

/-- A concrete instance: `z ^ 2 = x` is solvable (the transseries `√x` exists), while
`z ^ 2 + 1 = 0` is not — the transseries field is formally real but not algebraically
closed. -/
theorem sqrt_Lx_exists : ∃ z : TS, z ^ 2 = Lx :=
  exists_sq_of_nonneg Lx_pos.le

theorem no_sqrt_neg_one : ¬ ∃ z : TS, z ^ 2 = -1 := by
  rintro ⟨z, hz⟩
  have h1 : (0 : TS) ≤ z ^ 2 := sq_nonneg z
  rw [hz] at h1
  linarith

end EMLTS