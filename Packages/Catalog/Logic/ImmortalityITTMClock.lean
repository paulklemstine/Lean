import Novelty.ImmortalityGame

/-!
# A monotone transfinite transition system realizing the `ω²` clock

We build an explicit *monotone transfinite transition system* — the abstract skeleton of an
infinite time Turing machine — whose cells are the moments of the bounded-nondeterministic
game `nondetGame` of `Catalog/Novelty/ImmortalityGame.lean`.

A cell switches on once all strictly earlier cells are on (`step`), and the configuration at a
transfinite time `α` is obtained by applying one step to the union of all earlier
configurations (`stage`, defined by well-founded recursion on ordinals, `stage_limit_rule`).

Main results.

* `mem_stage_iff` — closed form of the stages: a cell is on at time `α` exactly when its
  arrival time (its `typein`, i.e. its clock reading) is at most `α`.
* `stage_succ` — the successor rule is literally one application of `step`.
* `not_terminal_of_lt`, `terminal_omega_sq`, `isLeast_terminal` — the closure ordinal of the
  system is *exactly* `ω²`: no earlier stage is terminal and `ω²` is.
* `arrivalIso`, `range_arrival` — faithfulness: the reachable-time well-order is order
  isomorphic to the moments of `nondetGame`, i.e. to the ordinals below `ω²`.
* `isLeast_terminal_eq_value` — the closure ordinal coincides with the survival value of the
  game the machine realizes.
-/

namespace ImmortalityITTM

open Ordinal ImmortalityGame

/-- Cells of the machine: the moments of the bounded-nondeterministic game. -/
abbrev Cell : Type := nondetGame.Moment

/-- One-step transition: a cell switches on once all strictly earlier cells are on. -/
def step (S : Set Cell) : Set Cell := {x | ∀ y, y < x → y ∈ S}

theorem step_mono : Monotone step := by
  intro S T hST x hx y hy
  exact hST (hx y hy)

/-- The configuration of the machine at transfinite time `α`: the successor rule is `step`,
and the limit rule is union of all earlier stages. -/
def stage (α : Ordinal.{0}) : Set Cell :=
  step (⋃ β : Set.Iio α, stage β.1)
termination_by α
decreasing_by exact β.2

theorem stage_eq (α : Ordinal.{0}) :
    stage α = step (⋃ β : Set.Iio α, stage β.1) := by
  rw [stage]

/-- Arrival time of a cell: the ordinal clock value it represents. -/
noncomputable def arrival (x : Cell) : Ordinal.{0} :=
  typein (α := Cell) (· < ·) x

theorem arrival_lt_omega_sq (x : Cell) : arrival x < ω ^ 2 := by
  have h := typein_lt_type ((· < ·) : Cell → Cell → Prop) x
  rwa [← SurvivalGame.value, nondetGame_value] at h

theorem arrival_lt_arrival {x y : Cell} : arrival x < arrival y ↔ x < y :=
  typein_lt_typein _

/-- Every ordinal below `ω²` is the arrival time of a (unique) cell. -/
theorem exists_arrival_eq {γ : Ordinal.{0}} (hγ : γ < ω ^ 2) : ∃ x : Cell, arrival x = γ := by
  have h : γ < type ((· < ·) : Cell → Cell → Prop) := by
    rwa [← SurvivalGame.value, nondetGame_value]
  obtain ⟨x, hx⟩ := typein_surj ((· < ·) : Cell → Cell → Prop) h
  exact ⟨x, hx⟩

theorem arrival_le_iff_forall_lt {x : Cell} {α : Ordinal.{0}} :
    arrival x ≤ α ↔ ∀ y : Cell, y < x → arrival y < α := by
  constructor
  · intro h y hy
    exact lt_of_lt_of_le (arrival_lt_arrival.2 hy) h
  · intro h
    by_contra hlt
    push_neg at hlt
    obtain ⟨y, hy⟩ := exists_arrival_eq (hlt.trans (arrival_lt_omega_sq x))
    have hyx : y < x := arrival_lt_arrival.1 (by rw [hy]; exact hlt)
    exact absurd (h y hyx) (by rw [hy]; exact lt_irrefl α)

/-- **Closed form of the stages.**  A cell is on at time `α` exactly when its arrival time has
been reached. -/
theorem mem_stage_iff (α : Ordinal.{0}) (x : Cell) : x ∈ stage α ↔ arrival x ≤ α := by
  induction α using WellFoundedLT.induction generalizing x with
  | _ α ih =>
    rw [stage_eq]
    constructor
    · intro hx
      refine arrival_le_iff_forall_lt.2 fun y hy => ?_
      obtain ⟨s, ⟨β, rfl⟩, hys⟩ := hx y hy
      have := (ih β.1 β.2 y).1 hys
      exact lt_of_le_of_lt this β.2
    · intro hx y hy
      have hya : arrival y < α := arrival_le_iff_forall_lt.1 hx y hy
      refine Set.mem_iUnion.2 ⟨⟨arrival y, hya⟩, ?_⟩
      exact (ih (arrival y) hya y).2 le_rfl

theorem stage_mono : Monotone stage := by
  intro α β hαβ x hx
  rw [mem_stage_iff] at hx ⊢
  exact hx.trans hαβ

/-- The machine is **terminal** at time `α` when one further step produces nothing new. -/
def Terminal (α : Ordinal.{0}) : Prop := stage (α + 1) = stage α

theorem stage_omega_sq : stage (ω ^ 2) = Set.univ := by
  ext x
  simp only [Set.mem_univ, iff_true, mem_stage_iff]
  exact (arrival_lt_omega_sq x).le

/-- No stage strictly below `ω²` is terminal: the machine is still active. -/
theorem not_terminal_of_lt {α : Ordinal.{0}} (hα : α < ω ^ 2) : ¬ Terminal α := by
  intro hT
  have hsucc : α + 1 < ω ^ 2 := by
    have hprin : Principal (· + ·) (ω ^ 2 : Ordinal.{0}) := by
      have h := principal_add_omega0_opow (2 : Ordinal.{0})
      rwa [show ((2 : Ordinal.{0})) = ((2 : ℕ) : Ordinal.{0}) by simp, opow_natCast] at h
    have hone : (1 : Ordinal.{0}) < ω ^ 2 := by
      rw [pow_two]
      calc (1 : Ordinal.{0}) < ω := one_lt_omega0
        _ = ω * 1 := (mul_one ω).symm
        _ ≤ ω * ω := mul_le_mul_right one_lt_omega0.le _
    exact hprin hα hone
  obtain ⟨x, hx⟩ := exists_arrival_eq hsucc
  have h1 : x ∈ stage (α + 1) := by rw [mem_stage_iff, hx]
  have h2 : x ∈ stage α := hT ▸ h1
  rw [mem_stage_iff, hx] at h2
  exact absurd h2 (by simp)

/-- The machine is terminal at `ω²`. -/
theorem terminal_omega_sq : Terminal (ω ^ 2) := by
  have h1 : stage (ω ^ 2 + 1) = Set.univ := by
    ext x
    simp only [Set.mem_univ, iff_true, mem_stage_iff]
    exact ((arrival_lt_omega_sq x).le).trans (le_of_lt (lt_add_one _))
  rw [Terminal, h1, stage_omega_sq]

/-- **Conjecture 5, closure ordinal.**  `ω²` is the least terminal time. -/
theorem isLeast_terminal : IsLeast {α : Ordinal.{0} | Terminal α} (ω ^ 2) := by
  refine ⟨terminal_omega_sq, ?_⟩
  intro α hα
  by_contra hlt
  exact not_terminal_of_lt (not_le.1 hlt) hα

/-- **Explicit successor rule.**  One step of the machine is applied at successor times. -/
theorem stage_succ (α : Ordinal.{0}) : stage (α + 1) = step (stage α) := by
  ext x
  simp only [step, Set.mem_setOf_eq, mem_stage_iff]
  rw [arrival_le_iff_forall_lt]
  exact forall_congr' fun _ => forall_congr' fun _ => Order.lt_add_one_iff

/-- **Explicit limit rule.**  At every time the machine takes the union of all earlier stages
and applies one step; at limit times this is exactly the ITTM limit rule. -/
theorem stage_limit_rule (α : Ordinal.{0}) :
    stage α = step (⋃ β : Set.Iio α, stage β.1) := stage_eq α

/-! ## The reachable-time well-order -/

theorem arrival_strictMono : StrictMono arrival := fun _ _ h => arrival_lt_arrival.2 h

/-- The reachable arrival times are exactly the ordinals below `ω²`. -/
theorem range_arrival : Set.range arrival = Set.Iio (ω ^ 2 : Ordinal.{0}) := by
  ext γ
  constructor
  · rintro ⟨x, rfl⟩
    exact arrival_lt_omega_sq x
  · intro h
    obtain ⟨x, hx⟩ := exists_arrival_eq h
    exact ⟨x, hx⟩

/-- **Conjecture 5, faithfulness.**  The reachable-time well-order of the machine is
order-isomorphic to the moments of the bounded-nondeterministic game. -/
noncomputable def arrivalIso : Cell ≃o Set.Iio (ω ^ 2 : Ordinal.{0}) :=
  StrictMono.orderIsoOfSurjective (fun x => ⟨arrival x, arrival_lt_omega_sq x⟩)
    (fun _ _ h => arrival_lt_arrival.2 h)
    (by
      rintro ⟨γ, hγ⟩
      obtain ⟨x, hx⟩ := exists_arrival_eq hγ
      exact ⟨x, by simpa using hx⟩)

/-- The closure ordinal of the machine is exactly the survival value of the game it realizes. -/
theorem isLeast_terminal_eq_value : IsLeast {α : Ordinal.{0} | Terminal α} nondetGame.value := by
  rw [nondetGame_value]
  exact isLeast_terminal

end ImmortalityITTM