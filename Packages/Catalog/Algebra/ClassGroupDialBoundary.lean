/-
# Where the residue dial stops: the boundary of the `factor3` refutation

Cycle 2 of the investigation.  Cycle 1 (`Algebra.ClassGroupResidueDial`,
`Algebra.ClassGroupResidueDialD84`) proved that at `D = -20` and `D = -84` the
representation vector of the reduced binary quadratic forms is a *pure residue
dial*: the class representing `N` is a function of `N mod |D|`, so the vector is
factor-blind.

Both of those discriminants have **one class per genus**.  This file proves that
the phenomenon is *exactly* a one-class-per-genus phenomenon, by exhibiting a
discriminant where it provably fails, and it quantifies the information loss in
the cases where it holds.

## Contents

* `ClassGroupResidueDial.genus23_no_separation` : at `D = -23` (`h = 3`, a single genus) the
  principal form `x² + xy + 6y²` and the form `2x² + xy + 3y²` represent
  **exactly the same** residues mod `23` — the genus characters see nothing.
* `ClassGroupResidueDial.dial_fails_at_23` : more strongly, representability by the principal
  form is *not* a function of `N mod 23`: `59` and `13` are congruent mod `23`,
  `59 = 5² + 5·2 + 6·2²` is principal, and `13 = 2·2² + 2·1 + 3·1²` is
  represented only by the non-principal form.
* `ClassGroupResidueDial.no_residueDial_23` : consequently **no** `ResidueDial 23` can contain
  both forms — the abstract mechanism of cycle 1 breaks down at `D = -23`.
* `ClassGroupResidueDial.product_fiber_card` : in *any* finite class group the "product of the two
  factor classes" observation is exactly `|Cl|`-to-one on pairs of classes; the
  dial destroys precisely `log₂|Cl|` bits.  Instantiated for `Cl(-20) ≅ ℤ/2`
  (`fiber_card_Z2`) and `Cl(-84) ≅ (ℤ/2)²` (`fiber_card_klein`).

The upshot: the extrinsic-discriminant corner is closed *for idoneal-type
discriminants*, and the surviving frontier is discriminants with several classes
per genus, where the vector is no longer a residue dial — but where computing it
is no longer a residue computation either.
-/
import Mathlib
import Algebra.ClassGroupResidueDial

namespace ClassGroupResidueDial

/-! ## 1. Discriminant `-23`: three classes, one genus -/

/-- Principal form of discriminant `-23`. -/
def ReprP23 (N : ℤ) : Prop := ∃ x y : ℤ, x ^ 2 + x * y + 6 * y ^ 2 = N

/-- Non-principal form `2x² + xy + 3y²` of discriminant `-23`. -/
def ReprQ23 (N : ℤ) : Prop := ∃ x y : ℤ, 2 * x ^ 2 + x * y + 3 * y ^ 2 = N

/-- **No genus separation at `D = -23`.**  The two forms represent exactly the
same residues mod `23`, so no choice of residue sets can tell them apart.
(Finite check in `ZMod 23`.) -/
theorem genus23_no_separation (a : ZMod 23) :
    (∃ x y : ZMod 23, x ^ 2 + x * y + 6 * y ^ 2 = a) ↔
      (∃ x y : ZMod 23, 2 * x ^ 2 + x * y + 3 * y ^ 2 = a) := by
  revert a; decide

theorem reprP23_59 : ReprP23 59 := ⟨5, 2, by norm_num⟩

theorem reprQ23_13 : ReprQ23 13 := ⟨2, 1, by norm_num⟩

/-- `13` is *not* represented by the principal form of discriminant `-23`:
`4·13 = (2x+y)² + 23y²` bounds the search to `|y| ≤ 1`, `|x| ≤ 4`. -/
theorem not_reprP23_13 : ¬ ReprP23 13 := by
  rintro ⟨x, y, h⟩
  have hy1 : -1 ≤ y := by nlinarith [sq_nonneg (2 * x + y), sq_nonneg (y + 1)]
  have hy2 : y ≤ 1 := by nlinarith [sq_nonneg (2 * x + y), sq_nonneg (y - 1)]
  have hx1 : -4 ≤ x := by nlinarith [sq_nonneg (2 * x + y), sq_nonneg (x + 4), sq_nonneg y]
  have hx2 : x ≤ 4 := by nlinarith [sq_nonneg (2 * x + y), sq_nonneg (x - 4), sq_nonneg y]
  interval_cases x <;> interval_cases y <;> omega

/-- **The dial fails at `D = -23`.**  Representability by the principal form is
not a function of the residue: `59 ≡ 13 (mod 23)`, both coprime to `23`, yet
`59` is principal and `13` is not (it is represented by the other class). -/
theorem dial_fails_at_23 :
    ∃ N M : ℤ, IsCoprime N 23 ∧ IsCoprime M 23 ∧ (N : ZMod 23) = (M : ZMod 23) ∧
      ReprP23 N ∧ ¬ ReprP23 M ∧ ReprQ23 M := by
  refine ⟨59, 13, ⟨-7, 18, by norm_num⟩, ⟨-7, 4, by norm_num⟩, by decide, reprP23_59,
    not_reprP23_13, reprQ23_13⟩

/-- **No residue dial at `D = -23`.**  There is no modulus-`23` dial (with any
index type) whose classes include both forms: the mechanism that collapses
`D = -20` and `D = -84` genuinely fails here. -/
theorem no_residueDial_23 {ι : Type*} (d : ResidueDial 23 ι) {i j : ι}
    (hi : d.repr i = ReprP23) (hj : d.repr j = ReprQ23) : False := by
  obtain ⟨N, M, hN, hM, hres, hPN, hPM, hQM⟩ := dial_fails_at_23
  have h1 : ((N : ℤ) : ZMod 23) ∈ d.res i :=
    d.sound i N (unit_cast_of_isCoprime (by exact_mod_cast hN)) (by rw [hi]; exact hPN)
  have h2 : ((M : ℤ) : ZMod 23) ∈ d.res j :=
    d.sound j M (unit_cast_of_isCoprime (by exact_mod_cast hM)) (by rw [hj]; exact hQM)
  rw [← hres] at h2
  have hij : i = j := by
    by_contra hne
    exact d.disj i j hne _ h1 h2
  have hPQ : ReprP23 = ReprQ23 := by rw [← hi, hij, hj]
  exact hPM (by rw [hPQ]; exact hQM)

/-! ## 2. How much information a class-group dial can possibly carry

Even when the dial *is* readable (one class per genus), the observation is the
product `[p]·[q]` of the two factor classes.  The following counting theorem
says that this observation is exactly `|Cl|`-to-one on pairs of classes: every
observed value is compatible with `|Cl|` factorisation types, so at most
`log₂|Cl|` bits about the pair `([p],[q])` survive — and those bits are already
determined by `N mod |D|`. -/

/-- In any finite group, the fibre of the multiplication map over `c` has
exactly `|G|` elements. -/
theorem product_fiber_card {G : Type*} [Group G] [Fintype G] [DecidableEq G] (c : G) :
    Fintype.card {p : G × G // p.1 * p.2 = c} = Fintype.card G := by
  apply Fintype.card_congr
  refine ⟨fun p => p.1.1, fun g => ⟨(g, g⁻¹ * c), by simp⟩, ?_, ?_⟩
  · rintro ⟨⟨a, b⟩, hab⟩
    have : b = a⁻¹ * c := by rw [← hab]; simp
    simp [this]
  · intro g; rfl

/-- `Cl(-20) ≅ ℤ/2`: every observation is compatible with exactly `2`
factorisation types (the "PP" and "NN" collision of cycle 1). -/
theorem fiber_card_Z2 (c : Multiplicative (ZMod 2)) :
    Fintype.card {p : Multiplicative (ZMod 2) × Multiplicative (ZMod 2) // p.1 * p.2 = c} = 2 := by
  rw [product_fiber_card]
  rfl

/-- `Cl(-84) ≅ (ℤ/2)²`: every observation is compatible with exactly `4`
factorisation types. -/
theorem fiber_card_klein (c : Multiplicative (ZMod 2 × ZMod 2)) :
    Fintype.card {p : Multiplicative (ZMod 2 × ZMod 2) × Multiplicative (ZMod 2 × ZMod 2) //
      p.1 * p.2 = c} = 4 := by
  rw [product_fiber_card]
  rfl

end ClassGroupResidueDial