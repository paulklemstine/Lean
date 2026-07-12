/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Tropical.Multiverse.Concrete

/-!
# Forcing closure and the failure of a "true" CH

A central axiom of Hamkins' multiverse is that it is **closed under forcing**: every universe
has forcing extensions, and generic forcing can flip the truth value of independent statements
like CH.

We abstract "the truth value of `s` can always be forced the other way" as `ForcingClosedFor M s`:
for every universe `u` there is another universe `v` (its forcing extension) in which `s`'s truth
value is exactly the *negation* of its value in `u`.

The key structural theorem, `undetermined_of_forcingClosedFor`, shows that this single closure
hypothesis already forces `s` to be **undetermined** — it can have no multiverse truth value.
This is the precise formal content of the slogan "there is no true CH": *closure under forcing
alone* rules out any multiverse-wide answer.

We then verify on the concrete multiverse of `Concrete.lean` that CH is forcing-closed while ZFC
is not, and conclude that CH is undetermined.
-/

namespace MultiverseSet

variable {M : Multiverse}

/-- `s` is **forcing-closed** when every universe has a forcing extension flipping the truth
value of `s`. This is the multiverse's closure-under-forcing axiom, localized to `s`. -/
def ForcingClosedFor (M : Multiverse) (s : M.Statement) : Prop :=
  ∀ u, ∃ v, (M.holds v s ↔ ¬ M.holds u s)

/-- **Forcing closure entails independence.** If the truth value of `s` can always be forced the
other way, then `s` is true in some universe and false in another. -/
theorem independent_of_forcingClosedFor {s : M.Statement} (h : ForcingClosedFor M s) :
    Independent M s := by
  obtain ⟨u₀⟩ := M.nonempty
  obtain ⟨v, hv⟩ := h u₀
  by_cases hu : M.holds u₀ s
  · exact ⟨⟨u₀, hu⟩, ⟨v, fun hvs => (hv.mp hvs) hu⟩⟩
  · exact ⟨⟨v, hv.mpr hu⟩, ⟨u₀, hu⟩⟩

/-- **Closure under forcing kills multiverse truth.** A forcing-closed statement is undetermined:
it is neither multiverse-true nor multiverse-false. Applied to CH, this is the formal statement
that closure under forcing precludes any "true" value of CH. -/
theorem undetermined_of_forcingClosedFor {s : M.Statement} (h : ForcingClosedFor M s) :
    Undetermined M s :=
  independent_iff_undetermined.mp (independent_of_forcingClosedFor h)

/-- In particular a forcing-closed statement is not multiverse-true. -/
theorem not_multiverseTrue_of_forcingClosedFor {s : M.Statement} (h : ForcingClosedFor M s) :
    ¬ MultiverseTrue M s :=
  (undetermined_of_forcingClosedFor h).1

namespace Concrete

/-- **CH is forcing-closed in the concrete multiverse.** From `L` or the measurable universe
(where CH holds) forcing produces the Cohen extension (where CH fails), and from the Cohen
extension forcing produces `L` (where CH holds). -/
theorem ch_forcingClosed : ForcingClosedFor concreteMultiverse .CH := by
  intro u
  cases u
  · exact ⟨Model.cohen, by simp [concrete_holds, choldsB]⟩
  · exact ⟨Model.L, by simp [concrete_holds, choldsB]⟩
  · exact ⟨Model.cohen, by simp [concrete_holds, choldsB]⟩

/-- Recovering `ch_undetermined` from forcing closure alone. -/
theorem ch_undetermined_via_forcing : Undetermined concreteMultiverse .CH :=
  undetermined_of_forcingClosedFor ch_forcingClosed

/-- **ZFC is not forcing-closed.** Being multiverse-true, its truth value cannot be forced away:
no forcing extension makes ZFC fail. -/
theorem zfc_not_forcingClosed : ¬ ForcingClosedFor concreteMultiverse .ZFC := by
  intro h
  obtain ⟨v, hv⟩ := h Model.L
  revert hv
  cases v <;> simp [concrete_holds, choldsB]

end Concrete

end MultiverseSet