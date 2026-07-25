import Mathlib

/-!
# Strongly critical ordinals and predicative ordinal analysis

This file develops a self-contained fragment of *predicative ordinal analysis* on top of
Mathlib's Veblen hierarchy (`Ordinal.veblen`, `Ordinal.epsilon`, `Ordinal.gamma`).

The organizing concept is the **strongly critical ordinal**: a positive ordinal that is a
fixed point of the *unary* Veblen function `veblen · 0`.  The decisive structural fact is
that this single fixed-point condition automatically upgrades to closure under the *full
binary* Veblen function (`StronglyCritical.veblen_lt`), generalizing the classical
Feferman–Schütte statement (usually phrased only for `Γ₀`) to arbitrary strongly critical
ordinals.

We then separate the *arithmetic* of the Veblen tower from the *order theory* of system
strength: by recognizing the consistency-strength relation as an `InvImage` of `<` on
`Ordinal`, well-foundedness of ordinal analysis and the impossibility of infinite
consistency descent both descend from `Ordinal.lt_wf`.

## Main results

* `StronglyCritical.veblen_eq` — a strongly critical `o` is a common fixed point of every
  lower Veblen function.
* `StronglyCritical.veblen_lt` (flagship) — predicative closure under the full binary
  Veblen function for *any* strongly critical ordinal.
* `gamma_stronglyCritical`, `gamma_zero_stronglyCritical` — every `Γ_ β`, and in particular
  the Feferman–Schütte ordinal `Γ₀`, is strongly critical.
* `gamma_zero_least_stronglyCritical` — `Γ₀` is the least strongly critical ordinal.
* `epsilon_zero_not_stronglyCritical` — `ε₀` is *not* strongly critical, so the closure
  bound `Γ₀` is sharp.
* `predicative_tower` — the landmark chain `ω < ε₀ < Γ₀`.
* `strength_wellFounded`, `no_infinite_consistency_descent` — order-theoretic consequences
  of `Ordinal.lt_wf` for proof-theoretic strength.
-/

namespace Predicative

open Ordinal Set

/-- A **strongly critical** ordinal is a positive fixed point of the unary Veblen function
`veblen · 0`.  Equivalently (see `mem_range_gamma`) it is a value of Mathlib's `gamma`. -/
def StronglyCritical (o : Ordinal) : Prop := 0 < o ∧ veblen o 0 = o

-- !-- `Γ_ β` is positive (`gamma_pos`) and a Veblen fixed point (`veblen_gamma_zero`). -- !--
/-- Every value `Γ_ β` of the gamma scale is strongly critical. -/
theorem gamma_stronglyCritical (β : Ordinal) : StronglyCritical (Γ_ β) :=
  ⟨gamma_pos, veblen_gamma_zero β⟩

-- !-- Specialize `gamma_stronglyCritical` at `β = 0`, where `Γ_ 0 = Γ₀`. -- !--
/-- The Feferman–Schütte ordinal `Γ₀` is strongly critical. -/
theorem gamma_zero_stronglyCritical : StronglyCritical Γ₀ :=
  gamma_stronglyCritical 0

-- !-- From `veblen o 0 = o` and `veblen_veblen_of_lt` (with `b = 0`), every lower Veblen
-- function fixes `o`. -- !--
/-- A strongly critical ordinal is a simultaneous fixed point of every *lower* Veblen
function: if `a < o` then `veblen a o = o`. -/
theorem StronglyCritical.veblen_eq {o : Ordinal} (h : StronglyCritical o) {a : Ordinal}
    (ha : a < o) : veblen a o = o := by
  have := veblen_veblen_of_lt ha 0
  rw [h.2] at this
  exact this

-- !-- With `veblen a o = o` and right strict monotonicity, `b < o` gives
-- `veblen a b < veblen a o = o`. -- !--
/-- **Flagship.**  Predicative closure: a strongly critical ordinal is closed under the
full binary Veblen function.  If `a < o` and `b < o` then `veblen a b < o`. -/
theorem StronglyCritical.veblen_lt {o : Ordinal} (h : StronglyCritical o) {a b : Ordinal}
    (ha : a < o) (hb : b < o) : veblen a b < o := by
  have hfix : veblen a o = o := h.veblen_eq ha
  calc veblen a b < veblen a o := by rw [veblen_lt_veblen_iff_right]; exact hb
    _ = o := hfix

-- !-- Specialization of the flagship to `Γ₀`, which is strongly critical
-- (`gamma_zero_stronglyCritical`). -- !--
/-- Feferman–Schütte closure of `Γ₀`: if `a, b < Γ₀` then `veblen a b < Γ₀`. -/
theorem veblen_lt_gamma_zero {a b : Ordinal} (ha : a < Γ₀) (hb : b < Γ₀) :
    veblen a b < Γ₀ :=
  gamma_zero_stronglyCritical.veblen_lt ha hb

-- !-- `veblen o 0 = o ≤ o` feeds `gamma_zero_le_of_veblen_le`. -- !--
/-- `Γ₀` is the least strongly critical ordinal. -/
theorem gamma_zero_least_stronglyCritical {o : Ordinal} (h : StronglyCritical o) :
    Γ₀ ≤ o :=
  gamma_zero_le_of_veblen_le (le_of_eq h.2)

-- !-- If `ε₀` were strongly critical then `Γ₀ ≤ ε₀`, contradicting `ε₀ < Γ_ 0 = Γ₀`. -- !--
/-- **Boundary / sharpness.**  `ε₀`, the proof-theoretic ordinal of `PA`, is *not* strongly
critical; hence predicative Veblen closure genuinely begins at `Γ₀`. -/
theorem epsilon_zero_not_stronglyCritical : ¬ StronglyCritical ε₀ := by
  intro h
  have h1 : Γ₀ ≤ ε₀ := gamma_zero_least_stronglyCritical h
  have h2 : ε₀ < Γ₀ := epsilon_zero_lt_gamma 0
  exact absurd (lt_of_lt_of_le h2 h1) (lt_irrefl _)

-- !-- Assemble `omega0_lt_epsilon`, `epsilon_zero_lt_gamma`, the boundary probe, and
-- `gamma_zero_stronglyCritical`. -- !--
/-- The landmark predicative tower `ω < ε₀ < Γ₀`, recording that `ε₀` is *not* strongly
critical while `Γ₀` is. -/
theorem predicative_tower :
    ω < ε₀ ∧ ε₀ < Γ₀ ∧ ¬ StronglyCritical ε₀ ∧ StronglyCritical Γ₀ :=
  ⟨omega0_lt_epsilon 0, epsilon_zero_lt_gamma 0,
    epsilon_zero_not_stronglyCritical, gamma_zero_stronglyCritical⟩

/-! ### Order theory of consistency strength

We model a formal system *analyzed by ordinal analysis* by the single datum of its
proof-theoretic ordinal, and show that comparing strength by this ordinal is well-founded.
-/

/-- A formal system equipped with its proof-theoretic ordinal (its *proof-theoretic
ordinal*, `pto`).  Strength is compared via this ordinal. -/
structure OrdAnalyzedSystem where
  /-- The proof-theoretic ordinal assigned to the system by ordinal analysis. -/
  pto : Ordinal

/-- One system is *strictly stronger* than another when its proof-theoretic ordinal is
larger. -/
def StrongerThan (S T : OrdAnalyzedSystem) : Prop := T.pto < S.pto

-- !-- The strength relation is the `InvImage` of `<` on `Ordinal` under `pto`, so
-- `InvImage.wf` applied to `Ordinal.lt_wf` finishes. -- !--
/-- Consistency strength compared by proof-theoretic ordinal is a well-founded relation:
ordinal analysis terminates. -/
theorem strength_wellFounded :
    WellFounded (InvImage (· < ·) OrdAnalyzedSystem.pto) :=
  InvImage.wf OrdAnalyzedSystem.pto Ordinal.lt_wf

-- !-- A strictly descending sequence of `pto`s yields `RelEmbedding.natGT` into `Ordinal`,
-- contradicting `Ordinal.lt_wf` via `RelEmbedding.not_wellFounded`. -- !--
/-- There is no infinite tower of systems of strictly decreasing proof-theoretic strength. -/
theorem no_infinite_consistency_descent :
    ¬ ∃ f : ℕ → OrdAnalyzedSystem, ∀ n, (f (n + 1)).pto < (f n).pto := by
  rintro ⟨f, hf⟩
  exact (RelEmbedding.natGT (fun n => (f n).pto) hf).not_wellFounded Ordinal.lt_wf

end Predicative