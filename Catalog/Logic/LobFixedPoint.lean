import Mathlib

/-!
# The Order-Theoretic Core of Gödel–Löb Provability Logic

This file isolates the **purely algebraic / order-theoretic core** of the
Gödel–Löb provability logic `GL`.  A *Gödel–Löb algebra* (Magari algebra) is a
Heyting algebra `H` equipped with a unary *provability operator* `□` ("box")
satisfying exactly three axioms:

* **Necessitation of truth** `□⊤ = ⊤`;
* **Distribution over meets** `□(a ⊓ b) = □a ⊓ □b`;
* **Löb's axiom** `□(□a ⇨ a) ≤ □a`.

We package this as a typeclass `GLOperator` over an arbitrary `HeytingAlgebra`.
From these three axioms *alone* — with no assumption of transitivity (axiom 4),
no assumption of well-foundedness, and no semantic machinery — we derive the
entire skeleton of provability logic:

* `GLOperator.box_mono`     — `□` is monotone (a derived "regularity");
* `GLOperator.loeb_rule`    — **Löb's theorem**: `□` has no nontrivial reflexive
  points, `□a ≤ a → a = ⊤`;
* `GLOperator.loeb_fixed_point` — the **de Jongh–Sambin fixed point**
  `□(□a ⇨ a) = □a`;
* `GLOperator.box_transitive`   — **modal axiom 4** `□a ≤ □□a` is *derived*, not
  assumed (the classic Sambin derivation via the diagonal `a ⊓ □a`);
* `GLOperator.godel_second`     — **Gödel's Second Incompleteness Theorem** as the
  instance of the fixed point at `a = ⊥`: provable consistency collapses to
  provable falsity.

## Catalog synthesis

This is the abstract algebraic counterpart of the semantic Kripke development in
`Catalog/Logic/GLKripke.lean` (`GLFrame`, `gl_frame_validates_loeb`,
`gl_box_inter`, `gl_box_univ`) and of the shallow-semantics layer in
`Catalog/Logic/TemporalGL.lean` (`loeb_box_sound`, `four_box_sound`,
`godel_second_at_time`).  Where those files *validate* the GL axioms on concrete
frames, here we take the three equations as the *definition* of the structure and
show the whole theory is forced.  The concrete frame model `(ℕ, >)` that realises
this typeclass — connecting back to the Kripke side — lives in
`Catalog/Logic/LobNatModel.lean`.

-- !-- Lab Notebook -- !--
**Hypothesis.** The three Magari equations (`□⊤=⊤`, `□` meet-preserving, Löb)
suffice to derive monotonicity, Löb's rule, the Sambin fixed point, axiom 4, and
Gödel II, with no order-theoretic side conditions.

**Result.** All five derived. The keystone is `loeb_fixed_point`, an `le_antisymm`
whose `≤` is Löb verbatim and whose `≥` is `box_mono` applied to the trivial
`a ≤ □a ⇨ a`. Axiom 4 then needs only `box_inf` + Löb on the diagonal `a ⊓ □a`.

**Insight.** Monotonicity is *not* an axiom: it is squeezed out of `box_inf`
alone via `a ≤ b ↔ a ⊓ b = a`. So the entire logic rests on meet-preservation
plus the single inequality of Löb. Axiom 4 — usually postulated in K4 — is a
*theorem* of GL: well-foundedness is hiding inside Löb's axiom.

**Failure analysis.** A first attempt derived axiom 4 by applying Löb to `□a`
directly; the himp bookkeeping pushed `□` onto the wrong side of the inequality.
The diagonal element `a ⊓ □a` (Sambin's trick) is essential: `box_inf` splits its
box, and `a ⊓ □(a ⊓ □a) ≤ a ⊓ □a` is the inequality that makes the chain close.
-- !-- end Lab Notebook -- !--
-/

universe u

/-- A **Gödel–Löb (Magari) provability operator** on a Heyting algebra `H`:
a unary `box` preserving `⊤` and binary meets, and satisfying **Löb's axiom**
`box (box a ⇨ a) ≤ box a`.  These three equations axiomatise the entire
propositional provability logic `GL`. -/
class GLOperator (H : Type u) [HeytingAlgebra H] where
  /-- The provability ("box") operator `□`. -/
  box : H → H
  /-- `□⊤ = ⊤`: the true sentence is provable. -/
  box_top : box ⊤ = ⊤
  /-- `□(a ⊓ b) = □a ⊓ □b`: provability distributes over conjunction (axiom `K`
  together with necessitation, in algebraic form). -/
  box_inf : ∀ a b : H, box (a ⊓ b) = box a ⊓ box b
  /-- **Löb's axiom** `□(□a ⇨ a) ≤ □a`. -/
  loeb : ∀ a : H, box (box a ⇨ a) ≤ box a

namespace GLOperator

variable {H : Type u} [HeytingAlgebra H] [GLOperator H]

@[inherit_doc] notation:max "□" a => GLOperator.box a

-- !-- Monotonicity is derived, not assumed: from `a ≤ b` we have `a ⊓ b = a`, so
--     `□a = □(a ⊓ b) = □a ⊓ □b ≤ □b`. Pure consequence of `box_inf`. -- !--
/-- **`□` is monotone.**  This is *not* an axiom: it is forced by meet-preservation
alone, since `a ≤ b ↔ a ⊓ b = a`. -/
theorem box_mono {a b : H} (h : a ≤ b) : (□a) ≤ □b := by
  have hab : a ⊓ b = a := inf_eq_left.mpr h
  have : (□a) = (□a) ⊓ (□b) := by
    rw [← box_inf, hab]
  rw [this]; exact inf_le_right

-- !-- de Jongh–Sambin fixed point. `≤` is Löb verbatim; `≥` is `box_mono` applied to
--     `a ≤ (□a ⇨ a)` (which is `a ⊓ □a ≤ a`, i.e. `inf_le_left`). -- !--
/-- **The de Jongh–Sambin fixed point.**  `□(□a ⇨ a) = □a`: the Löb inequality is in
fact an equality, exhibiting `□a` as the explicit (and, classically, unique) fixed
point of the box-guarded operator `x ↦ □(x ⇨ a)`. -/
theorem loeb_fixed_point (a : H) : (□((□a) ⇨ a)) = □a := by
  refine le_antisymm (loeb a) ?_
  have hle : a ≤ ((□a) ⇨ a) := le_himp_iff.mpr inf_le_left
  exact box_mono hle

-- !-- Löb's theorem as "no nontrivial reflexive points". From `□a ≤ a` we get
--     `□a ⇨ a = ⊤`, so `□⊤ = ⊤ ≤ □a` by Löb; thus `□a = ⊤ ≤ a`. -- !--
/-- **Löb's theorem.**  The box has *no nontrivial reflexive points*: if `□a ≤ a`
then `a = ⊤`.  Equivalently, the only "self-justifying" sentence is the trivially
true one — there is no consistent sentence asserting its own provability implies its
own truth, except `⊤` itself. -/
theorem loeb_rule {a : H} (h : (□a) ≤ a) : a = ⊤ := by
  have htop : ((□a) ⇨ a) = ⊤ := himp_eq_top_iff.mpr h
  have h1 : (⊤ : H) ≤ □a := by
    have := loeb a
    rwa [htop, box_top] at this
  have hbox : (□a) = ⊤ := top_le_iff.mp h1
  exact top_le_iff.mp (hbox ▸ h)

-- !-- Sambin's derivation of axiom 4 from Löb via the diagonal `b := a ⊓ □a`.
--     `box_inf` gives `□b = □a ⊓ □□a`; then `a ⊓ □b ≤ b` makes `a ≤ □b ⇨ b`, so
--     `□a ≤ □(□b ⇨ b) ≤ □b ≤ □□a`. -- !--
/-- **Modal axiom 4 is derived.**  `□a ≤ □□a` (positive introspection / transitivity)
follows from the three GL axioms; it need not be postulated.  This is the algebraic
form of the fact that GL ⊇ K4 — well-foundedness is already encoded in Löb's axiom. -/
theorem box_transitive (a : H) : (□a) ≤ □□a := by
  set b : H := a ⊓ (□a) with hb
  have hbox_b : (□b) = (□a) ⊓ (□□a) := by rw [hb, box_inf]
  -- `a ⊓ □b ≤ b`
  have hstep : a ⊓ (□b) ≤ b := by
    have h1 : a ⊓ (□b) ≤ a := inf_le_left
    have h2 : (□b) ≤ □a := by rw [hbox_b]; exact inf_le_left
    have h3 : a ⊓ (□b) ≤ (□a) := le_trans inf_le_right h2
    rw [hb]; exact le_inf h1 h3
  have ha : a ≤ ((□b) ⇨ b) := le_himp_iff.mpr hstep
  have hchain1 : (□a) ≤ □((□b) ⇨ b) := box_mono ha
  have hchain2 : (□((□b) ⇨ b)) ≤ □b := loeb b
  have hchain3 : (□b) ≤ □□a := by rw [hbox_b]; exact inf_le_right
  exact le_trans hchain1 (le_trans hchain2 hchain3)

-- !-- Gödel II as the fixed point at `a = ⊥`: `□(¬□⊥) = □⊥`, i.e. provable
--     consistency = provable falsity, so consistency is unprovable unless inconsistent. -- !--
/-- **Gödel's Second Incompleteness Theorem (algebraic form).**  Writing the
consistency statement as `□⊥ ⇨ ⊥` ("if falsity is provable then falsity holds",
i.e. `¬ Prov(⊥)`), provability of consistency collapses onto provability of falsity:
`□(□⊥ ⇨ ⊥) = □⊥`.  Hence a *consistent* algebra (`□⊥ ≠ ⊤`) cannot prove its own
consistency (`□(□⊥ ⇨ ⊥) ≠ ⊤`). -/
theorem godel_second : (□((□(⊥ : H)) ⇨ ⊥)) = □(⊥ : H) :=
  loeb_fixed_point ⊥

/-- **Gödel II, contrapositive packaging.**  In a consistent Gödel–Löb algebra the
consistency statement is *unprovable*. -/
theorem consistency_unprovable (hcon : (□(⊥ : H)) ≠ ⊤) :
    (□((□(⊥ : H)) ⇨ ⊥)) ≠ ⊤ := by
  rw [godel_second]; exact hcon

end GLOperator