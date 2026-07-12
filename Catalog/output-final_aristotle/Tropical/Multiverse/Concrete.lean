/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Tropical.Multiverse.Basic

/-!
# A concrete multiverse: CH, V=L and a large cardinal

We instantiate the abstract `Multiverse` from `Basic.lean` on an explicit finite collection
of three named universes, chosen to mirror the standard independence phenomena:

* `Model.L`          — the constructible universe `L`: satisfies **V=L** and **CH**, has no
                       large cardinals;
* `Model.cohen`      — a Cohen forcing extension: satisfies **¬CH**;
* `Model.measurable` — a universe with a **large cardinal** (measurable), where **CH** holds
                       but **V≠L**.

Every universe satisfies `ZFC`. Truth is encoded by a `Bool`-valued table so that all the
finite statements below are decidable and dischargeable by `decide`.

## Main results

* `zfc_multiverseTrue`         — ZFC is multiverse-true.
* `ch_independent`             — CH holds in some universes and fails in others.
* `ch_undetermined` / `no_true_CH` — CH has **no** multiverse truth value.
* `veqL_independent`, `largeCardinal_independent` — likewise for V=L and large cardinals.
* `zfc_not_undetermined`       — ZFC, by contrast, *is* determined (it is multiverse-true).
* `veqL_large_cardinal_incompatible` — no single universe has both V=L and a large cardinal.
-/

namespace MultiverseSet.Concrete

open MultiverseSet

/-- The three universes of the concrete multiverse. -/
inductive Model
  | L
  | cohen
  | measurable
  deriving DecidableEq, Fintype, Repr

/-- The statements whose truth varies across the multiverse. -/
inductive Stmt
  | ZFC
  | CH
  | VeqL
  | LargeCardinal
  deriving DecidableEq, Repr

/-- The `Bool`-valued truth table of the concrete multiverse. -/
def choldsB : Model → Stmt → Bool
  | _,               .ZFC           => true
  | .L,              .CH            => true
  | .cohen,          .CH            => false
  | .measurable,     .CH            => true
  | .L,              .VeqL          => true
  | .cohen,          .VeqL          => false
  | .measurable,     .VeqL          => false
  | .L,              .LargeCardinal => false
  | .cohen,          .LargeCardinal => false
  | .measurable,     .LargeCardinal => true

/-- The concrete set-theoretic multiverse with three universes. -/
def concreteMultiverse : Multiverse where
  Universe := Model
  Statement := Stmt
  holds := fun u s => choldsB u s = true
  nonempty := ⟨Model.L⟩

@[simp] theorem concrete_holds (u : Model) (s : Stmt) :
    concreteMultiverse.holds u s ↔ choldsB u s = true := Iff.rfl

/-- **ZFC is multiverse-true**: it holds in every universe. -/
theorem zfc_multiverseTrue : MultiverseTrue concreteMultiverse .ZFC := by
  intro u; cases u <;> rfl

/-- **CH is independent**: true in `L` and in the measurable-cardinal universe, false in the
Cohen extension. -/
theorem ch_independent : Independent concreteMultiverse .CH := by
  refine ⟨⟨Model.L, ?_⟩, ⟨Model.cohen, ?_⟩⟩ <;> simp [concrete_holds, choldsB]

/-- **CH is undetermined**: it is neither multiverse-true nor multiverse-false. -/
theorem ch_undetermined : Undetermined concreteMultiverse .CH :=
  independent_iff_undetermined.mp ch_independent

/-- **There is no "true" CH.** Restated bluntly: CH is not multiverse-true and not
multiverse-false — the question of its truth is meaningless without naming a universe. -/
theorem no_true_CH :
    ¬ MultiverseTrue concreteMultiverse .CH ∧ ¬ MultiverseFalse concreteMultiverse .CH :=
  ch_undetermined

/-- CH is not multiverse-true. -/
theorem ch_not_multiverseTrue : ¬ MultiverseTrue concreteMultiverse .CH :=
  ch_undetermined.1

/-- CH is possibly true (it holds in `L`). -/
theorem ch_possiblyTrue : PossiblyTrue concreteMultiverse .CH :=
  ⟨Model.L, by simp [concrete_holds, choldsB]⟩

/-- **V=L is independent** across the multiverse. -/
theorem veqL_independent : Independent concreteMultiverse .VeqL := by
  refine ⟨⟨Model.L, ?_⟩, ⟨Model.cohen, ?_⟩⟩ <;> simp [concrete_holds, choldsB]

/-- **The existence of a large cardinal is independent** across the multiverse. -/
theorem largeCardinal_independent : Independent concreteMultiverse .LargeCardinal := by
  refine ⟨⟨Model.measurable, ?_⟩, ⟨Model.L, ?_⟩⟩ <;> simp [concrete_holds, choldsB]

/-- ZFC, unlike CH, is **determined**: it is not undetermined. -/
theorem zfc_not_undetermined : ¬ Undetermined concreteMultiverse .ZFC := by
  intro h
  exact h.1 zfc_multiverseTrue

/-- **Incompatibility of V=L and large cardinals**: no single universe satisfies both V=L and
the existence of a large cardinal (`L` refutes large cardinals; a measurable cardinal
refutes V=L). -/
theorem veqL_large_cardinal_incompatible :
    ∀ u, ¬ (concreteMultiverse.holds u .VeqL ∧ concreteMultiverse.holds u .LargeCardinal) := by
  intro u; cases u <;> simp [concrete_holds, choldsB]

end MultiverseSet.Concrete