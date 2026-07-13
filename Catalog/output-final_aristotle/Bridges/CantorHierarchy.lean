import Mathlib

/-!
# Cantor's Hierarchy of Infinities

A self-contained formal development of the different *sizes of infinity*, in the
spirit of Rucker's *Infinity and the Mind*.  We assemble the classical picture of
Cantor's transfinite hierarchy from Mathlib's cardinal arithmetic and prove the
landmark facts that separate one infinity from the next.

## Contents

* **Cantor's theorem.** Every set is strictly smaller than its power set
  (`card_lt_powerset`), there is no surjection onto the power set
  (`no_surjection_onto_powerset`) nor an injection out of it
  (`no_injection_from_powerset`), and hence there is no largest cardinal
  (`exists_strictly_larger_cardinal`).
* **The Hartogs number.** For every type there is an ordinal whose cardinality
  exceeds it (`hartogs`): a strictly larger *well-orderable* cardinal always
  exists.
* **The bottom of the ladder.** `ℵ₀` is the least infinite cardinal
  (`aleph0_least_infinite`); `ℵ₁ = succ ℵ₀` (`aleph1_eq_succ_aleph0`) is the
  least uncountable one (`aleph1_le_of_uncountable`).
* **The Cantor / beth tower.** The tower `ℵ₀, 2^ℵ₀, 2^(2^ℵ₀), …`
  (`cantorTower`) is strictly increasing (`cantorTower_strictMono`) and stays
  above `ℵ₀`, exhibiting infinitely many distinct infinities; its first rung is
  the continuum (`cantorTower_one`).  The aleph and beth hierarchies satisfy
  `ℵ_o ≤ ℶ_o` (`aleph_le_beth`).
* **The continuum.** `ℝ` is uncountable (`uncountable_reals`), equinumerous with
  `𝒫 ℕ` (`powerset_nat_equiv_reals`) and with the plane
  (`plane_equiv_line`, `continuum_mul_self`).  By König's theorem the continuum
  has uncountable cofinality (`continuum_cofinality_uncountable`), so it can
  never be a countable supremum of smaller cardinals.
* **The Continuum Hypothesis.** `CH` states `𝔠 = ℵ₁`; we prove it is equivalent
  to the non-existence of a cardinal strictly between `ℵ₀` and `𝔠`
  (`CH_iff_no_intermediate_cardinal`), and that the Generalized Continuum
  Hypothesis implies it (`GCH_imp_CH`).

All results are proved without `sorry`.  Mathlib's cardinal theory is built on
the axiom of choice throughout, so the "well-orderable" reading of the Hartogs
number here is relative to that ambient choice.
-/

open Cardinal Ordinal

namespace CantorHierarchy

/-! ## Cantor's theorem: no set exhausts its power set -/

/-- **Cantor's theorem.** Every set is strictly smaller than its power set. -/
theorem card_lt_powerset (α : Type u) : #α < #(Set α) := by
  rw [Cardinal.mk_set]; exact Cardinal.cantor _

/-- There is no surjection from a set onto its power set. -/
theorem no_surjection_onto_powerset (α : Type u) (f : α → Set α) :
    ¬ Function.Surjective f := Function.cantor_surjective f

/-- There is no injection from the power set of a set back into the set. -/
theorem no_injection_from_powerset (α : Type u) (f : Set α → α) :
    ¬ Function.Injective f := Function.cantor_injective f

/-- There is no largest cardinal: the power-set cardinal `2 ^ c` always exceeds
`c`.  Iterating gives an endless ascending hierarchy of infinities. -/
theorem exists_strictly_larger_cardinal (c : Cardinal.{u}) : ∃ d, c < d :=
  ⟨2 ^ c, Cardinal.cantor c⟩

/-! ## The Hartogs number -/

/-- **Hartogs' theorem (choice-relative form).** For every type `α` there is an
ordinal whose cardinality strictly exceeds `#α`; equivalently, a strictly larger
well-orderable cardinal always exists.  We take the ordinal underlying the
successor cardinal of `#α`. -/
theorem hartogs (α : Type u) : ∃ o : Ordinal.{u}, #α < o.card := by
  refine ⟨(Order.succ (#α)).ord, ?_⟩
  rw [Cardinal.card_ord]; exact Order.lt_succ _

/-! ## The bottom of the ladder: `ℵ₀` and `ℵ₁` -/

/-- `ℵ₀` is the least infinite cardinal: any infinite type has at least `ℵ₀`
elements. -/
theorem aleph0_least_infinite (α : Type u) [Infinite α] : ℵ₀ ≤ #α :=
  Cardinal.aleph0_le_mk α

/-- `ℵ₁` is the successor of `ℵ₀`. -/
theorem aleph1_eq_succ_aleph0 : aleph.{0} 1 = Order.succ ℵ₀ := by
  rw [show (1 : Ordinal) = Order.succ 0 from by simp, Cardinal.aleph_succ,
    Cardinal.aleph_zero]

/-- `ℵ₁` is strictly larger than `ℵ₀`, i.e. it is uncountable. -/
theorem aleph0_lt_aleph1 : ℵ₀ < aleph.{0} 1 := by
  rw [aleph1_eq_succ_aleph0]; exact Order.lt_succ _

/-- `ℵ₁` is the *least* uncountable cardinal: any cardinal above `ℵ₀` is at least
`ℵ₁`. -/
theorem aleph1_le_of_uncountable {c : Cardinal.{0}} (h : ℵ₀ < c) : aleph 1 ≤ c := by
  rw [aleph1_eq_succ_aleph0]; exact Order.succ_le_of_lt h

/-- The aleph hierarchy is strictly monotone in the ordinal index. -/
theorem aleph_strictMono {o₁ o₂ : Ordinal.{u}} (h : o₁ < o₂) : aleph o₁ < aleph o₂ :=
  Cardinal.aleph_lt_aleph.mpr h

/-- Every aleph is dominated by the corresponding beth: `ℵ_o ≤ ℶ_o`. -/
theorem aleph_le_beth (o : Ordinal.{u}) : aleph o ≤ beth o := Cardinal.aleph_le_beth o

/-! ## The Cantor (beth) tower -/

/-- The **Cantor tower** `ℵ₀, 2^ℵ₀, 2^(2^ℵ₀), …`: repeatedly taking power sets
starting from the countable infinity.  These are the finite beth numbers. -/
noncomputable def cantorTower : ℕ → Cardinal.{0}
  | 0 => ℵ₀
  | (n + 1) => 2 ^ cantorTower n

/-- Each rung of the tower is strictly below the next (Cantor's theorem). -/
theorem cantorTower_lt_succ (n : ℕ) : cantorTower n < cantorTower (n + 1) :=
  Cardinal.cantor _

/-- The tower is strictly increasing, so it produces infinitely many *distinct*
infinities. -/
theorem cantorTower_strictMono : StrictMono cantorTower :=
  strictMono_nat_of_lt_succ cantorTower_lt_succ

/-- Every rung of the tower is at least `ℵ₀`. -/
theorem aleph0_le_cantorTower (n : ℕ) : ℵ₀ ≤ cantorTower n := by
  induction n with
  | zero => exact le_rfl
  | succ k ih => exact le_of_lt (lt_of_le_of_lt ih (cantorTower_lt_succ k))

/-- The first rung above `ℵ₀` is exactly the continuum `𝔠 = 2^ℵ₀`. -/
theorem cantorTower_one : cantorTower 1 = 𝔠 := Cardinal.two_power_aleph0

/-! ## The size of the continuum -/

/-- The real line is uncountable. -/
theorem uncountable_reals : ℵ₀ < #ℝ := by
  rw [Cardinal.mk_real]; exact Cardinal.aleph0_lt_continuum

/-- The power set of `ℕ` is equinumerous with `ℝ`: both have cardinality `𝔠`. -/
theorem powerset_nat_equiv_reals : #(Set ℕ) = #ℝ := by
  rw [Cardinal.mk_set, Cardinal.mk_real, Cardinal.mk_nat, Cardinal.two_power_aleph0]

/-- The continuum absorbs multiplication with itself: `𝔠 · 𝔠 = 𝔠`. -/
theorem continuum_mul_self : 𝔠 * 𝔠 = 𝔠 :=
  Cardinal.mul_eq_self Cardinal.aleph0_le_continuum

/-- The plane has the same cardinality as the line: `#(ℝ × ℝ) = #ℝ`. -/
theorem plane_equiv_line : #(ℝ × ℝ) = #ℝ := by
  rw [Cardinal.mk_prod, Cardinal.mk_real]
  simp [Cardinal.mul_eq_self Cardinal.aleph0_le_continuum]

/-- **König's theorem, applied to the continuum.** The continuum has uncountable
cofinality, so `𝔠` is never the supremum of a countable family of strictly
smaller cardinals. -/
theorem continuum_cofinality_uncountable : ℵ₀ < (𝔠).ord.cof := by
  have := Cardinal.lt_cof_power (a := ℵ₀) (b := 2) le_rfl (by norm_num)
  rwa [Cardinal.two_power_aleph0] at this

/-! ## The Continuum Hypothesis -/

/-- The **Continuum Hypothesis**: the continuum is the first uncountable
cardinal, `𝔠 = ℵ₁`. -/
def CH : Prop := 𝔠 = aleph.{0} 1

/-- **CH restated.** The Continuum Hypothesis is equivalent to the statement that
there is no cardinal strictly between `ℵ₀` and the continuum. -/
theorem CH_iff_no_intermediate_cardinal :
    CH ↔ ¬ ∃ c : Cardinal.{0}, ℵ₀ < c ∧ c < 𝔠 := by
  constructor
  · rintro h ⟨c, h1, h2⟩
    rw [h, aleph1_eq_succ_aleph0, Order.lt_succ_iff] at h2
    exact absurd h2 (not_le.mpr h1)
  · intro h
    apply le_antisymm
    · by_contra hc
      push_neg at hc
      exact h ⟨aleph 1, aleph0_lt_aleph1, hc⟩
    · exact aleph1_le_of_uncountable Cardinal.aleph0_lt_continuum

/-- The **Generalized Continuum Hypothesis**: for every ordinal `o`,
`2 ^ ℵ_o = ℵ_(o+1)`. -/
def GCH : Prop := ∀ o : Ordinal.{0}, 2 ^ (aleph o) = aleph (Order.succ o)

/-- GCH implies CH: specializing the generalized hypothesis at `o = 0` gives
`2 ^ ℵ₀ = ℵ₁`, i.e. `𝔠 = ℵ₁`. -/
theorem GCH_imp_CH (h : GCH) : CH := by
  unfold CH
  have := h 0
  rw [Cardinal.aleph_zero, Cardinal.two_power_aleph0] at this
  rw [this]; norm_num

/-! ## Cardinal-arithmetic absorption

The collapse of the continuum results (`continuum_mul_self`, `plane_equiv_line`)
is a special case of the fact that infinite cardinals absorb the basic
arithmetic operations. -/

/-- Any infinite cardinal absorbs addition with itself: `κ + κ = κ`. -/
theorem cardinal_add_self {κ : Cardinal.{u}} (h : ℵ₀ ≤ κ) : κ + κ = κ :=
  Cardinal.add_eq_self h

/-- Any infinite cardinal absorbs multiplication with itself: `κ · κ = κ`.
(`continuum_mul_self` is the case `κ = 𝔠`.) -/
theorem cardinal_mul_self {κ : Cardinal.{u}} (h : ℵ₀ ≤ κ) : κ * κ = κ :=
  Cardinal.mul_eq_self h

/-- For an infinite cardinal, self-exponentiation equals the power-set cardinal:
`κ ^ κ = 2 ^ κ`.  In particular the two natural notions of "function space" and
"power set" of an infinite set have the same size. -/
theorem cardinal_power_self {κ : Cardinal.{u}} (h : ℵ₀ ≤ κ) : κ ^ κ = 2 ^ κ :=
  Cardinal.power_self_eq h

/-! ## König's theorem in general form -/

/-- **König's theorem (cofinality form).** For every infinite cardinal `κ` the
power cardinal `2 ^ κ` has cofinality strictly greater than `κ`; equivalently,
`2 ^ κ` is never the supremum of a `κ`-indexed family of smaller cardinals.
`continuum_cofinality_uncountable` is the special case `κ = ℵ₀`. -/
theorem power_cofinality_gt {κ : Cardinal.{u}} (h : ℵ₀ ≤ κ) :
    κ < ((2 : Cardinal) ^ κ).ord.cof :=
  Cardinal.lt_cof_power h (by norm_num)

/-! ## GCH collapses the beth tower onto the aleph tower -/

/-- **Under GCH the beth and aleph hierarchies coincide:** `∀ o, ℶ_o = ℵ_o`.
The proof is by transfinite induction: the base case is `ℶ_0 = ℵ₀ = ℵ_0`, the
successor step `ℶ_(o+1) = 2 ^ ℶ_o = 2 ^ ℵ_o = ℵ_(o+1)` uses GCH, and the limit
step matches the two suprema termwise. -/
theorem beth_eq_aleph_of_GCH (h : GCH) : ∀ o : Ordinal.{0}, beth o = aleph o := by
  intro o
  induction o using Ordinal.limitRecOn with
  | zero => rw [Cardinal.beth_zero, Cardinal.aleph_zero]
  | succ o ih => rw [Cardinal.beth_succ, ih, h o, Cardinal.aleph_succ]
  | limit o ho ih =>
      rw [Cardinal.beth_limit ho, Cardinal.aleph_limit ho]
      exact iSup_congr fun i => ih i.1 i.2

end CantorHierarchy