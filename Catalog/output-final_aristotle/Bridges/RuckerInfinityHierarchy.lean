import Mathlib

/-!
# Rucker: Infinity and the Mind — Cantor's Hierarchy of Infinities

This file formalizes, in Lean 4 / Mathlib, several load-bearing facts about the
Cantorian hierarchy of infinite cardinals, in the spirit of Rudy Rucker's
*Infinity and the Mind* and its slogan that "infinity is a place you can visit".

We work entirely inside ZFC as available in Mathlib (which uses classical logic
and choice). The results are grouped into themes:

* **The Cantor tower** — an explicit, strictly increasing infinite tower of
  cardinals `ℵ₀ < 2^ℵ₀ < 2^(2^ℵ₀) < ⋯` (a truncated *beth* sequence). This is
  the concrete sense in which one can "keep visiting larger infinities".
* **No largest infinity** — the cardinals form a proper class: there is no
  cardinal above all cardinals, and every power set is strictly larger than its
  base (Cantor's theorem).
* **Hartogs' theorem** — for *every* type there is a (well-orderable) ordinal
  whose cardinality strictly exceeds it. This holds with no appeal to the power
  set of `α`.
* **`ℵ₁` and the Continuum Hypothesis** — `ℵ₀ < ℵ₁ ≤ 𝔠`, and CH is *exactly*
  the remaining inequality `𝔠 ≤ ℵ₁`.
* **König's theorem in action** — the continuum has uncountable cofinality, and
  as a *disproof* of a naive guess, `𝔠 ≠ ℵ_ω`.
* **Large-cardinal flavour** — `ℵ₀` is regular and a strong limit; it fails to
  be inaccessible *only* because inaccessibility demands uncountability. In this
  precise sense `ℵ₀` is "the first unreachable place".

All theorems are proved in ZFC; the independence of CH itself is discussed in
`FUTURE_DIRECTIONS.md`.
-/

open Cardinal Ordinal

universe u

namespace RuckerInfinity

/-! ## 1. The Cantor tower: an explicit strictly increasing tower of infinities -/

/-- A truncated *beth* sequence: `cantorTower 0 = ℵ₀` and
`cantorTower (n+1) = 2 ^ cantorTower n`.  This realizes Rucker's picture of
successively "visiting" larger infinities `ℵ₀ < 2^ℵ₀ < 2^(2^ℵ₀) < ⋯`. -/
noncomputable def cantorTower : ℕ → Cardinal.{u}
  | 0 => Cardinal.aleph0
  | (n + 1) => 2 ^ (cantorTower n)

@[simp] theorem cantorTower_zero : cantorTower 0 = Cardinal.aleph0.{u} := rfl

@[simp] theorem cantorTower_succ (n : ℕ) :
    cantorTower (n + 1) = 2 ^ (cantorTower.{u} n) := rfl

/-- Every stage of the tower is at least `ℵ₀`, hence infinite. -/
theorem aleph0_le_cantorTower (n : ℕ) : Cardinal.aleph0.{u} ≤ cantorTower n := by
  induction n with
  | zero => simp
  | succ k ih =>
    calc Cardinal.aleph0.{u} ≤ cantorTower k := ih
      _ ≤ 2 ^ (cantorTower k) := le_of_lt (Cardinal.cantor _)

/-- Each stage of the tower is *strictly* smaller than the next: this is Cantor's
theorem `c < 2^c` applied along the tower. -/
theorem cantorTower_lt_succ (n : ℕ) : cantorTower.{u} n < cantorTower (n + 1) :=
  Cardinal.cantor _

/-- The Cantor tower is strictly increasing: infinitely many strictly larger
infinities, explicitly exhibited. -/
theorem cantorTower_strictMono : StrictMono cantorTower.{u} :=
  strictMono_nat_of_lt_succ cantorTower_lt_succ

/-! ## 2. No largest infinity: the cardinals form a proper class -/

/-- Cantor's theorem in power-set form: any set has strictly smaller cardinality
than its power set. -/
theorem lt_powerset {α : Type u} (s : Set α) : (#s) < #(𝒫 s : Set (Set α)) := by
  rw [Cardinal.mk_powerset]
  exact Cardinal.cantor _

/-- There is no largest cardinal: above every cardinal sits a strictly larger
one (namely `2^c`). -/
theorem exists_gt_cardinal (c : Cardinal.{u}) : ∃ d : Cardinal.{u}, c < d :=
  ⟨2 ^ c, Cardinal.cantor _⟩

/-- The cardinals are unbounded: no single cardinal dominates them all. This is
the formal content of "the cardinals form a proper class". -/
theorem cardinals_unbounded : ¬ ∃ M : Cardinal.{u}, ∀ c : Cardinal.{u}, c ≤ M := by
  rintro ⟨M, hM⟩
  exact absurd (hM (2 ^ M)) (not_le.2 (Cardinal.cantor _))

/-! ## 3. Hartogs' theorem: a well-orderable bound above any type -/

/-- **Hartogs' theorem.** For every type `α` there is an ordinal `o` whose
cardinality does not inject into `α`; equivalently `#α < o.card`. The witnessing
`o` is *well-orderable* by construction, and the statement makes no use of the
power set of `α`. -/
theorem hartogs (α : Type u) : ∃ o : Ordinal.{u}, (#α) < o.card := by
  refine ⟨(Order.succ (#α)).ord, ?_⟩
  rw [Cardinal.card_ord]
  exact Order.lt_succ _

/-! ## 4. `ℵ₁`, the first uncountable cardinal, and the Continuum Hypothesis -/

/-- `ℵ₁` is uncountable: `ℵ₀ < ℵ₁`. -/
theorem aleph0_lt_aleph1 : Cardinal.aleph0 < Cardinal.aleph 1 :=
  Cardinal.aleph0_lt_aleph_one

/-- `ℵ₁ ≤ 𝔠`: the first uncountable cardinal is at most the continuum. This is a
ZFC theorem — the "easy half" of CH. -/
theorem aleph1_le_continuum : Cardinal.aleph 1 ≤ Cardinal.continuum :=
  Cardinal.aleph_one_le_continuum

/-- The **Continuum Hypothesis**: `ℵ₁ = 𝔠` (stated for the base universe, where
the continuum `𝔠 = #ℝ` lives). -/
def ContinuumHypothesis : Prop := Cardinal.aleph.{0} 1 = Cardinal.continuum.{0}

/-- Since `ℵ₁ ≤ 𝔠` is a theorem, CH is *exactly* the reverse inequality
`𝔠 ≤ ℵ₁`. This isolates the genuinely undecidable content of CH into a single
`≤`. -/
theorem continuumHypothesis_iff :
    ContinuumHypothesis ↔ Cardinal.continuum.{0} ≤ Cardinal.aleph.{0} 1 := by
  unfold ContinuumHypothesis
  constructor
  · intro h; exact le_of_eq h.symm
  · intro h; exact le_antisymm Cardinal.aleph_one_le_continuum h

/-- CH, equivalently, is the statement `ℵ₁ = 2^ℵ₀`. -/
theorem continuumHypothesis_iff_pow :
    ContinuumHypothesis ↔ Cardinal.aleph.{0} 1 = 2 ^ Cardinal.aleph0.{0} := by
  unfold ContinuumHypothesis
  rw [Cardinal.two_power_aleph0]

/-! ## 5. König's theorem: cofinality of the continuum, and `𝔠 ≠ ℵ_ω` -/

/-- **König's theorem in action.** The continuum has uncountable cofinality:
`ℵ₀ < cof(𝔠)`. Equivalently, `𝔠` is not the supremum of countably many smaller
cardinals. -/
theorem aleph0_lt_cof_continuum : Cardinal.aleph0 < Cardinal.continuum.ord.cof := by
  have h := Cardinal.lt_cof_power (a := ℵ₀) (b := 2) le_rfl one_lt_two
  rwa [Cardinal.two_power_aleph0] at h

/-- The cofinality of `ℵ_ω` is countable: `cof(ℵ_ω) = ℵ₀`. -/
theorem cof_aleph_omega : (Cardinal.aleph Ordinal.omega0).ord.cof = Cardinal.aleph0 := by
  rw [Cardinal.ord_aleph, Ordinal.cof_omega Ordinal.isSuccLimit_omega0, Ordinal.cof_omega0]

/-- **A disproof of a naive conjecture.** One might guess the continuum could be
`ℵ_ω`; König's theorem *refutes* this outright in ZFC: `𝔠 ≠ ℵ_ω`. -/
theorem continuum_ne_aleph_omega : Cardinal.continuum ≠ Cardinal.aleph Ordinal.omega0 := by
  intro h
  have h1 : Cardinal.aleph0 < Cardinal.continuum.ord.cof := aleph0_lt_cof_continuum
  rw [h, cof_aleph_omega] at h1
  exact lt_irrefl _ h1

/-! ## 6. Large-cardinal flavour: `ℵ₀` as "the first unreachable place" -/

/-- `ℵ₀` is regular: `ℵ₀ ≤ cof(ℵ₀)`. -/
theorem aleph0_regular : Cardinal.aleph0 ≤ Cardinal.aleph0.ord.cof :=
  Cardinal.isRegular_aleph0.2

/-- `ℵ₀` is a strong limit: `2^x < ℵ₀` for every `x < ℵ₀` (finite exponents give
finite powers). -/
theorem aleph0_strong_limit :
    ∀ x : Cardinal.{u}, x < Cardinal.aleph0 → 2 ^ x < Cardinal.aleph0 :=
  fun _ hx => Cardinal.isStrongLimit_aleph0.two_power_lt hx

/-- `ℵ₀` is **not** inaccessible — but *only* because inaccessibility, by
definition, demands uncountability (`ℵ₀ < c`). It satisfies the other two
clauses (regularity and strong-limit-ness). This is the precise sense in which
`ℵ₀` is the prototype of an "unreachable" cardinal: the first infinity is itself
a place one cannot climb to from below. -/
theorem aleph0_inaccessible_except_uncountable :
    (Cardinal.aleph0 ≤ Cardinal.aleph0.ord.cof) ∧
      (∀ x : Cardinal.{u}, x < Cardinal.aleph0 → 2 ^ x < Cardinal.aleph0) ∧
      ¬ Cardinal.aleph0.IsInaccessible := by
  refine ⟨aleph0_regular, aleph0_strong_limit, ?_⟩
  rintro ⟨h, _, _⟩
  exact lt_irrefl _ h

end RuckerInfinity