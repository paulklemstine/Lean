import Logic.LobWellFoundedFrame

/-!
# Constructive de Jongh–Sambin Fixed Points by Descending Iteration

This file goes **deeper** into the order-theoretic core of Gödel–Löb provability logic
developed in `Catalog/Logic/LobFixedPoint.lean`.  There the *uniqueness* of modalised
fixed points (`modalised_fixedPoint_unique`) is proved for an **arbitrary** Gödel–Löb
algebra, but *existence* is supplied only for the single explicit map `p ↦ □p ⇨ c`
(`loeb_fixed_point`, `glFix`).  General existence on an arbitrary algebra is genuinely
unavailable — without extra structure a box-congruent operator need not have a fixed
point at all.

The new contribution here is a **structural existence theorem**: on any Gödel–Löb algebra
whose order satisfies the **descending chain condition** (`WellFoundedLT`), *every*
box-congruent operator `f` with `Monotone (f ∘ f)` has a (unique) fixed point, and it is
obtained **constructively** as the stable value of the descending iteration
`(f ∘ f)^[n] ⊤`.  The hypothesis `Monotone (f ∘ f)` is satisfied both by monotone `f`
*and* by antitone `f` — in particular by the canonical Gödel/Sambin map `p ↦ □p ⇨ c`,
which is antitone — so the theorem is a genuine common generalisation that recovers the
explicit `glFix`.

## Main results

* `GLOperator.boxCongruent_box` / `boxCongruent_comp` / `boxCongruent_himp_const` — closure
  lemmas for box-congruence.  `boxCongruent_comp` is where **axiom 4 (`box_transitive`)**
  is used: congruence is preserved under composition precisely because `□a ≤ □□a`.
* `exists_fixedPoint_of_monotone_wf` — a self-contained order-theoretic lemma: on any
  `WellFoundedLT` order with a top element, a monotone map has a fixed point, found as the
  minimum of its descending iteration `g^[n] ⊤`.
* `GLOperator.boxCongruent_fixedPoint` / `boxCongruent_existsUnique_fixedPoint` — **the
  fixed-point theorem under DCC**: a box-congruent `f` with `Monotone (f ∘ f)` has a unique
  fixed point.  Uniqueness is `modalised_fixedPoint_unique`; existence is the descending
  iteration applied to `f ∘ f`, transferred to `f` via uniqueness for `f ∘ f`.
* `GLOperator.sambin_existsUnique_fixedPoint` + `sambin_fixedPoint_eq_glFix` — the canonical
  antitone map `p ↦ □p ⇨ c` is an instance, and on a DCC algebra its iterative fixed point
  is exactly the explicit `glFix c = □c ⇨ c`.
* `FinGL`, `finGL_fixedPoint_property`, `finGL_sambin_fixedPoint` — every **finite** GL
  frame `(Fin n, <)` is a DCC Gödel–Löb algebra, so it has the *constructive* fixed-point
  property for all box-congruent / monotone-square operators.

## Catalog synthesis

This extends `Catalog/Logic/LobFixedPoint.lean` (the `GLOperator` core, especially
`modalised_fixedPoint_unique`, `box_transitive`, `glFix`) and reuses the frame box
`wfBox` of `Catalog/Logic/LobWellFoundedFrame.lean` to build the finite model `FinGL`.
Where `LobNatModel`/`LobWellFoundedFrame` study the *non-DCC* models `(ℕ,>)` and
`(Ordinal,<)` (whose order on `Set _` has infinite descending chains, so the iteration
need not converge and existence rests on the explicit `glFix`), this file isolates the
exact order condition — DCC — under which the de Jongh–Sambin fixed point becomes a
*terminating computation*, and exhibits the finite frames as its natural home.

-- !-- Lab Notebook: constructive Sambin fixed points -- !--
-- !-- Hypothesis: On a DCC Heyting algebra the de Jongh–Sambin fixed point of any
--     box-congruent operator is not merely unique (Löb's rule) but COMPUTABLE, as the
--     limit of a descending iteration from ⊤; and the antitone Gödel map p↦□p⇨c fits
--     because its square is monotone. -- !--
-- !-- Result: Confirmed. Take g = f∘f (box-congruent by boxCongruent_comp, which needs
--     axiom 4!). If Monotone g then g^[n]⊤ is antitone, so by WellFoundedLT it has a
--     minimum g^[m]⊤ with g(g^[m]⊤)=g^[m]⊤ — a fixed point of g. Then f(that) is also a
--     g-fixed point, so by uniqueness for g it equals it: f has a fixed point. The
--     Sambin map's square is monotone (antitone∘antitone), and the fixed point is glFix c. -- !--
-- !-- Insight: Existence of GL fixed points is the descending chain condition in disguise;
--     uniqueness is Löb's rule. The two halves of the de Jongh–Sambin theorem decouple
--     into a PURELY ORDER-THEORETIC half (DCC ⇒ existence) and a PURELY MODAL half
--     (Löb ⇒ uniqueness). Composition-closure of box-congruence is the bridge, and it is
--     exactly where transitivity/axiom 4 is consumed. -- !--
-- !-- Failure analysis: DCC is load-bearing — the canonical models Set ℕ / Set Ordinal
--     have infinite descending chains, so the iteration g^[n]⊤ need NOT stabilise and the
--     theorem genuinely does not apply there (existence in those models still holds, but
--     only via the explicit glFix, not the iteration). Dropping Monotone (f∘f) also breaks
--     the descent. Finite frames are the clean home where everything terminates. -- !--
-- !-- End Lab Notebook -- !--
-/

open GLOperator Set

/-! ### A self-contained order-theoretic existence lemma -/

-- !-- The iterates `g^[n] ⊤` descend (monotone `g`, `g⊤ ≤ ⊤`); a `WellFoundedLT` minimum
--     of their range is a fixed point, as the next iterate is `≤` it but not `<` it. -- !--
/-- **Descending-iteration fixed point.**  On a partial order with a top element and no
infinite strictly descending chains (`WellFoundedLT`), a monotone map `g` has a fixed
point, realised *constructively* as the stabilised value of the iteration `g^[n] ⊤`. -/
theorem exists_fixedPoint_of_monotone_wf {H : Type*} [PartialOrder H] [OrderTop H]
    [WellFoundedLT H] {g : H → H} (hg : Monotone g) : ∃ a, g a = a := by
  set x : ℕ → H := fun n => g^[n] ⊤ with hx
  have hstep : ∀ n, x (n + 1) = g (x n) := fun n => by
    simp only [hx, Function.iterate_succ_apply']
  have hsucc : ∀ n, x (n + 1) ≤ x n := by
    intro n
    induction n with
    | zero =>
        have h0 : x 0 = ⊤ := rfl
        rw [hstep, h0]; exact le_top
    | succ k ih =>
        calc x (k + 1 + 1) = g (x (k + 1)) := hstep (k + 1)
          _ ≤ g (x k) := hg ih
          _ = x (k + 1) := (hstep k).symm
  obtain ⟨a, ha_mem, hmin⟩ := wellFounded_lt.has_min (Set.range x) ⟨x 0, 0, rfl⟩
  obtain ⟨m, rfl⟩ := ha_mem
  refine ⟨x m, ?_⟩
  have hle : x (m + 1) ≤ x m := hsucc m
  have hnlt : ¬ x (m + 1) < x m := hmin (x (m + 1)) ⟨m + 1, rfl⟩
  have heq : x (m + 1) = x m := eq_of_le_of_not_lt hle hnlt
  rw [← hstep m]; exact heq

namespace GLOperator

variable {H : Type*} [HeytingAlgebra H] [GLOperator H]

/-! ### Closure properties of box-congruence -/

-- !-- This is exactly `box_biimp_le`: □(a⇔b) ≤ (□a)⇔(□b). -- !--
/-- The box operator itself is box-congruent. -/
theorem boxCongruent_box : BoxCongruent (box : H → H) := box_biimp_le

-- !-- □(a⇔b) ≤ □□(a⇔b) [axiom 4!] ≤ □((fa)⇔(fb)) [box_mono hf] ≤ (g(fa))⇔(g(fb)) [hg]. -- !--
/-- **Box-congruence is closed under composition.**  This is the precise place where the
transitivity axiom `4` (`box_transitive`) is consumed: a second box is needed to push the
inner congruence under another box. -/
theorem boxCongruent_comp {f g : H → H} (hf : BoxCongruent f) (hg : BoxCongruent g) :
    BoxCongruent (g ∘ f) := by
  intro a b
  calc □(biimp a b) ≤ □□(biimp a b) := box_transitive _
    _ ≤ □(biimp (f a) (f b)) := box_mono (hf a b)
    _ ≤ biimp (g (f a)) (g (f b)) := hg (f a) (f b)

-- !-- biimp is preserved by `· ⇨ c` (biimp_himp_const), so compose with box-congruence. -- !--
/-- Box-congruence is preserved by post-composition with `· ⇨ c`. -/
theorem boxCongruent_himp_const {f : H → H} (hf : BoxCongruent f) (c : H) :
    BoxCongruent (fun p => f p ⇨ c) :=
  fun a b => (hf a b).trans (biimp_himp_const _ _ _)

/-! ### The canonical Gödel/Sambin map `p ↦ □p ⇨ c` -/

-- !-- f = (·⇨c) ∘ □, box-congruent by boxCongruent_himp_const boxCongruent_box. -- !--
/-- The Gödel/Sambin map `p ↦ □p ⇨ c` is box-congruent. -/
theorem boxCongruent_sambin (c : H) : BoxCongruent (fun p => □p ⇨ c) :=
  boxCongruent_himp_const boxCongruent_box c

-- !-- a ≤ b ⇒ □a ≤ □b ⇒ (□b⇨c) ≤ (□a⇨c). -- !--
/-- The Gödel/Sambin map `p ↦ □p ⇨ c` is antitone. -/
theorem antitone_sambin (c : H) : Antitone (fun p => □p ⇨ c) :=
  fun _ _ hab => himp_le_himp (box_mono hab) le_rfl

-- !-- Monotone because antitone∘antitone is monotone. -- !--
omit [GLOperator H] in
/-- The square of an antitone map is monotone. -/
theorem monotone_comp_self_of_antitone {f : H → H} (hf : Antitone f) :
    Monotone (f ∘ f) := fun _ _ hab => hf (hf hab)

/-! ### The fixed-point theorem under the descending chain condition -/

-- !-- g := f∘f is box-congruent (axiom 4) and monotone, so g^[n]⊤ stabilises at a g-fixed
--     point a. Then f a is also a g-fixed point, so uniqueness for g gives f a = a. -- !--
/-- **Existence of the de Jongh–Sambin fixed point under DCC.**  On a Gödel–Löb algebra
whose order has no infinite descending chains, every box-congruent operator `f` whose
square is monotone has a fixed point.  Existence comes from the descending iteration of
`f ∘ f`; the value is transferred to `f` itself via Löb-uniqueness for `f ∘ f`. -/
theorem boxCongruent_fixedPoint [WellFoundedLT H] {f : H → H}
    (hf : BoxCongruent f) (hmono : Monotone (f ∘ f)) : ∃ a, f a = a := by
  obtain ⟨a, ha⟩ := exists_fixedPoint_of_monotone_wf hmono
  have hg : BoxCongruent (f ∘ f) := boxCongruent_comp hf hf
  have hfa : (f ∘ f) (f a) = f a := by
    have h : (f ∘ f) (f a) = f ((f ∘ f) a) := rfl
    rw [h, ha]
  have huniq : a = f a := modalised_fixedPoint_unique hg ha.symm hfa.symm
  exact ⟨a, huniq.symm⟩

/-- **The full de Jongh–Sambin fixed-point theorem under DCC**: existence *and*
uniqueness.  Existence is `boxCongruent_fixedPoint` (descending iteration); uniqueness is
`modalised_fixedPoint_unique` (Löb's rule). -/
theorem boxCongruent_existsUnique_fixedPoint [WellFoundedLT H] {f : H → H}
    (hf : BoxCongruent f) (hmono : Monotone (f ∘ f)) : ∃! a, f a = a := by
  obtain ⟨a, ha⟩ := boxCongruent_fixedPoint hf hmono
  exact ⟨a, ha, fun b hb => modalised_fixedPoint_unique hf hb.symm ha.symm⟩

/-- The canonical Gödel/Sambin map has a unique fixed point on any DCC Gödel–Löb algebra. -/
theorem sambin_existsUnique_fixedPoint [WellFoundedLT H] (c : H) :
    ∃! a, (□a ⇨ c) = a :=
  boxCongruent_existsUnique_fixedPoint (boxCongruent_sambin c)
    (monotone_comp_self_of_antitone (antitone_sambin c))

-- !-- Any fixed point of p↦□p⇨c equals glFix c by glFix_unique (independent of DCC). -- !--
/-- The iterative fixed point of the Sambin map is exactly the explicit term
`glFix c = □c ⇨ c`: the constructive descending iteration recovers the closed form. -/
theorem sambin_fixedPoint_eq_glFix {a c : H} (ha : (□a ⇨ c) = a) : a = glFix c :=
  glFix_unique ha.symm

end GLOperator

/-! ### Finite GL frames: the DCC fixed-point property, concretely -/

-- !-- `(Fin n, <)` is transitive and well-founded, so `wfBox (·<·)` is a GLOperator; the
--     same construction as `OrdGL`/`NatGL` but on a finite carrier. -- !--
/-- Every **finite frame `(Fin n, <)`** is a Gödel–Löb algebra via the frame box `wfBox`.
Unlike `NatGL`/`OrdGL`, the carrier `Set (Fin n)` is finite, hence satisfies the
descending chain condition (`WellFoundedLT`). -/
instance FinGL (n : ℕ) : GLOperator (Set (Fin n)) where
  box := wfBox (· < ·)
  box_top := wfBox_top _
  box_inf := wfBox_inf _
  loeb := wfBox_loeb _ (fun _ _ _ h1 h2 => lt_trans h1 h2) wellFounded_lt

@[simp] theorem finGL_box {n : ℕ} (S : Set (Fin n)) :
    (GLOperator.box S) = wfBox (· < ·) S := rfl

-- !-- Set (Fin n) is finite ⇒ WellFoundedLT, so boxCongruent_existsUnique_fixedPoint applies. -- !--
/-- **The finite GL fixed-point property.**  On every finite frame `(Fin n, <)`, every
box-congruent operator with monotone square has a unique fixed point, found by a
terminating descending iteration. -/
theorem finGL_fixedPoint_property (n : ℕ) {f : Set (Fin n) → Set (Fin n)}
    (hf : GLOperator.BoxCongruent f) (hmono : Monotone (f ∘ f)) : ∃! a, f a = a :=
  GLOperator.boxCongruent_existsUnique_fixedPoint hf hmono

-- !-- Specialisation of sambin_existsUnique_fixedPoint to the finite instance FinGL. -- !--
/-- The Gödel/consistency-style sentence `p ↦ □p ⇨ c` has a unique (constructively
computable) fixed point on every finite GL frame. -/
theorem finGL_sambin_fixedPoint (n : ℕ) (c : Set (Fin n)) :
    ∃! a, (GLOperator.box a ⇨ c) = a :=
  GLOperator.sambin_existsUnique_fixedPoint c