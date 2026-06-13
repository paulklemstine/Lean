import Logic.LobFixedPoint

/-!
# The Provability Diamond as a Well-Founded Co-Closure

This file develops the **de Morgan dual** `◇` of the provability box of a Boolean
`GLOperator` (`Catalog/Logic/LobFixedPoint.lean`), realising Direction 5 of the previous
cycle's `FUTURE_DIRECTIONS`: `◇` is a *well-founded co-closure* — join-preserving,
strict on `⊥`, sub-idempotent, and satisfying a **dual Löb law** with no analogue among
ordinary topological closure/interior operators.

Working over a Boolean algebra `H` carrying a `GLOperator`, define the **consistency /
diamond operator** `dia a := (□ aᶜ)ᶜ`.  We prove:

* `dia_compl` — `(dia a)ᶜ = □ aᶜ` (the defining duality).
* `dia_bot` — `dia ⊥ = ⊥` (dual of necessitation `□⊤ = ⊤`).
* `dia_sup` — `dia (a ⊔ b) = dia a ⊔ dia b` (**join preservation**, dual of normality
  `□(a ⊓ b) = □a ⊓ □b`).
* `dia_mono` — monotonicity.
* `dia_dia_le` — `dia (dia a) ≤ dia a` (**sub-idempotence**, the de Morgan dual of the
  derived transitivity `□a ≤ □□a`).
* `dia_loeb` — `dia a ≤ dia (a ⊓ (dia a)ᶜ)` (**the dual Löb law**): consistency of `a`
  forces consistency of "`a` together with the unprovability of `a`" — the well-founded
  signature that strictly contracts off fixed points.
* `dia_fixedPoint_eq_bot` — the only fixed point of `◇` is `⊥` (dual of "the only
  self-provable element is `⊤`").

## Catalog synthesis

`dia` is the algebraic shadow of the Kripke diamond dual to `GLFrame.boxSet`
(`Catalog/Logic/GLKripke.lean`); `dia_loeb` is the order-dual of `GLOperator.loeb`, and
`dia_dia_le` dualises `GLOperator.box_transitive`.  Every law is derived purely from the
three `GLOperator` axioms plus Boolean complementation — no new axioms.

-- !-- Lab Notebook: provability diamond -- !--
-- !-- Hypothesis: The de Morgan dual ◇a = ¬□¬a of a Boolean GLOperator is a "well-
--     founded co-closure": join-preserving, ◇⊥ = ⊥, sub-idempotent (◇◇a ≤ ◇a), and
--     satisfying a dual Löb law ◇a ≤ ◇(a ∧ ¬◇a) with no topological analogue. -- !--
-- !-- Result: Confirmed. Every law is the complement of a box law: dia_sup = box_inf
--     under de Morgan; dia_dia_le = box_transitive; and dia_loeb is literally `loeb aᶜ`
--     rewritten through `p ⇨ q = pᶜ ⊔ q` and `compl_compl`. -- !--
-- !-- Insight: GL's box is simultaneously inflationary on theorems (axiom 4) and rigid
--     off them (Löb's rule). Dually ◇ is deflationary AND strictly contracting off
--     fixed points — exactly a WELL-FOUNDED nucleus. The single new ingredient beyond a
--     locale nucleus is dia_loeb, the converse-well-foundedness made algebraic. -- !--
-- !-- Failure analysis: Phrasing this over a general Heyting algebra fails — ◇ needs
--     complementation to be involutive (`compl_compl`) for the duality `(dia a)ᶜ = □aᶜ`
--     to round-trip, so a Boolean algebra is the right setting. -- !--
-- !-- End Lab Notebook -- !--
-/

namespace GLOperator

variable {H : Type*} [BooleanAlgebra H] [GLOperator H]

/-- The **provability diamond / consistency operator** `◇a := ¬□¬a = (□ aᶜ)ᶜ`. -/
def dia (a : H) : H := (□ aᶜ)ᶜ

-- !-- `compl_compl`: `((□aᶜ)ᶜ)ᶜ = □aᶜ`. -- !--
/-- The defining duality: `(◇a)ᶜ = □ aᶜ`. -/
theorem dia_compl (a : H) : (dia a)ᶜ = □ aᶜ := by
  simp [dia]

-- !-- `dia ⊥ = (□⊥ᶜ)ᶜ = (□⊤)ᶜ = ⊤ᶜ = ⊥`, using `box_top`. -- !--
/-- **`◇⊥ = ⊥`** — the dual of necessitation `□⊤ = ⊤`. -/
theorem dia_bot : dia (⊥ : H) = ⊥ := by
  simp [dia, GLOperator.box_top]

-- !-- de Morgan: `(a⊔b)ᶜ = aᶜ⊓bᶜ`, then `box_inf`, then `(□aᶜ ⊓ □bᶜ)ᶜ = ◇a ⊔ ◇b`. -- !--
/-- **`◇` preserves joins**: `◇(a ⊔ b) = ◇a ⊔ ◇b` — the dual of normality. -/
theorem dia_sup (a b : H) : dia (a ⊔ b) = dia a ⊔ dia b := by
  simp only [dia, compl_sup, GLOperator.box_inf, compl_inf]

-- !-- Antitone-of-antitone: `a ≤ b ⇒ bᶜ ≤ aᶜ ⇒ □bᶜ ≤ □aᶜ ⇒ ◇a ≤ ◇b`, via `box_mono`. -- !--
/-- **`◇` is monotone.** -/
theorem dia_mono {a b : H} (h : a ≤ b) : dia a ≤ dia b :=
  compl_le_compl (GLOperator.box_mono (compl_le_compl h))

-- !-- `(dia a)ᶜ = □aᶜ`, so `dia (dia a) = (□(□aᶜ))ᶜ`; `box_transitive` gives
--     `□aᶜ ≤ □□aᶜ`, complement-reverse to `dia (dia a) ≤ (□aᶜ)ᶜ = dia a`. -- !--
/-- **Sub-idempotence**: `◇(◇a) ≤ ◇a` — the de Morgan dual of the derived transitivity
`□a ≤ □□a`. -/
theorem dia_dia_le (a : H) : dia (dia a) ≤ dia a := by
  convert compl_le_compl (GLOperator.box_transitive (aᶜ)) using 1
  simp [dia]

-- !-- Taking complements turns the goal into `□(□aᶜ ⇨ aᶜ) ≤ □aᶜ`, which is exactly
--     `loeb aᶜ` after rewriting `(a ⊓ (dia a)ᶜ)ᶜ = aᶜ ⊔ □aᶜ = □aᶜ ⇨ aᶜ`. -- !--
/-- **The dual Löb law**: `◇a ≤ ◇(a ⊓ (◇a)ᶜ)`.  Consistency of `a` entails consistency
of "`a` and the unprovability of `a`" — the well-founded co-closure signature, dual to
`GLOperator.loeb`. -/
theorem dia_loeb (a : H) : dia a ≤ dia (a ⊓ (dia a)ᶜ) := by
  have h : □(a ⊓ (dia a)ᶜ)ᶜ ≤ □ aᶜ := by
    convert GLOperator.loeb aᶜ using 1
    simp [dia, himp_eq]
  exact compl_le_compl h

-- !-- `dia a = a ⇒ □aᶜ = aᶜ ⇒ aᶜ = ⊤` (box_fixedPoint_eq_top) ⇒ `a = ⊥`. -- !--
/-- **The only fixed point of `◇` is `⊥`** — dual to `box_fixedPoint_eq_top`. -/
theorem dia_fixedPoint_eq_bot {a : H} (h : dia a = a) : a = ⊥ := by
  have hc : □ aᶜ = aᶜ := by rw [← dia_compl, h]
  have := GLOperator.box_fixedPoint_eq_top hc
  simpa using congrArg compl this

end GLOperator