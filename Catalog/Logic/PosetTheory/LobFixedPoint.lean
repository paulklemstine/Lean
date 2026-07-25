import Mathlib

/-!
# The Order-Theoretic Core of Gödel–Löb Provability Logic: Fixed Points

This file isolates the **purely order-theoretic core** of the Gödel–Löb provability
logic `GL`.  A *Gödel–Löb algebra* (`GLOperator`) is a Heyting algebra `H` equipped with
a unary *provability operator* `□ : H → H` satisfying

* `□⊤ = ⊤`                              (necessitation of truth),
* `□(a ⊓ b) = □a ⊓ □b`                  (the K / normality axiom in conjunctive form),
* `□(□a ⇨ a) ≤ □a`                      (**Löb's axiom**).

From these three axioms *alone* — no syntax, no Gödel coding, no arithmetic — we derive
the structural heart of provability logic:

* `box_transitive`   — the transitivity axiom `4 : □a ≤ □□a` is **derivable** from Löb;
* `loeb_eq`          — the equality form `□(□a ⇨ a) = □a`;
* `loeb_rule`        — Löb's *rule*: `□a ≤ a ⇒ a = ⊤`;
* `box_fixedPoint_eq_top` — the *only* self-provable element is `⊤`;
* `consistency_unprovable` / `godel_second` — **Gödel's second incompleteness theorem**
  in algebraic form: a consistent algebra cannot prove its own consistency;
* `glFix`, `loeb_fixed_point`, `glFix_box`, `glFix_unique`, `glFix_iff` — the
  **de Jongh–Sambin fixed-point theorem** for the canonical modalised map `p ↦ □p ⇨ c`:
  the fixed point exists, is given by the *explicit* term `□c ⇨ c`, has provability
  exactly `□c`, and is **unique**;
* `modalised_fixedPoint_unique` — the **general de Jongh–Sambin uniqueness theorem**: any
  *box-congruent* operator (one in which the variable occurs only under `□`) has at most
  one fixed point.  This is the abstract engine behind unique Gödel/Henkin sentences.

## Catalog synthesis

This is the abstract foundation imported by `Catalog/Logic/LobNatModel.lean`, which
builds the concrete consistent model `(Set ℕ, natBox)` on the well-founded frame `(ℕ, >)`
and *computes* `□^k⊥ = Iio k`.  It is the algebraic shadow of the semantic
`Catalog/Logic/GLKripke.lean` development (where `gl_frame_validates_loeb` proves Löb for
finite transitive irreflexive frames): every theorem here transfers to every GL frame's
box operator.  The fixed-point layer (`modalised_fixedPoint_unique`) is the algebraic core
of the *unique* Gödel/Henkin sentences underlying `GLKripke.lean`'s world model.

-- !-- Lab Notebook: GLOperator core -- !--
-- !-- Hypothesis: The entire structural skeleton of GL (axiom 4, Gödel II, the de
--     Jongh–Sambin fixed point WITH uniqueness, even in general) follows from just
--     {□⊤=⊤, □ preserves ⊓, Löb} on an arbitrary Heyting algebra — no arithmetic. -- !--
-- !-- Result: Confirmed. box_transitive (axiom 4) is the two-line Löb trick with
--     c := a ⊓ □a; Gödel II is Löb at ⊥. General uniqueness reduces to one fact: for any
--     box-congruent f, □(a⇔b) ≤ (fa)⇔(fb); at fixed points this is □(a⇔b) ≤ (a⇔b), so
--     Löb's rule forces a⇔b = ⊤, i.e. a = b. -- !--
-- !-- Insight: Uniqueness of modalised fixed points is NOT a fixed-point-specific miracle;
--     it is Löb's RULE applied to the biimplication, plus the single congruence lemma
--     □(a⇨b) ≤ □a⇨□b. Everything (one-param glFix, two-param d⊓(□p⇨c)) is a corollary. -- !--
-- !-- Failure analysis: Stating fixed points for ARBITRARY maps f(□p) without the
--     box-congruence hypothesis is false (e.g. f ≡ projection); box-congruence is exactly
--     "the variable occurs only under □", which is the de Jongh–Sambin side condition. -- !--
-- !-- End Lab Notebook -- !--
-/

/-- A **Gödel–Löb algebra**: a Heyting algebra with a provability operator `□`
satisfying necessitation of `⊤`, normality (`□` preserves binary meets), and Löb's
axiom `□(□a ⇨ a) ≤ □a`.  This is the order-theoretic core of the modal logic `GL`. -/
class GLOperator (H : Type*) [HeytingAlgebra H] where
  /-- The provability / box operator. -/
  box : H → H
  /-- Necessitation of truth: `□⊤ = ⊤`. -/
  box_top : box ⊤ = ⊤
  /-- Normality (axiom K, conjunctive form): `□` preserves binary meets. -/
  box_inf : ∀ a b, box (a ⊓ b) = box a ⊓ box b
  /-- **Löb's axiom**: `□(□a ⇨ a) ≤ □a`. -/
  loeb : ∀ a, box (box a ⇨ a) ≤ box a

namespace GLOperator

@[inherit_doc] scoped prefix:max "□" => GLOperator.box

variable {H : Type*} [HeytingAlgebra H] [GLOperator H]

-- !-- box is monotone: a ≤ b ⇒ a ⊓ b = a ⇒ □a = □a ⊓ □b ≤ □b. -- !--
/-- The box operator is monotone. -/
theorem box_mono {a b : H} (h : a ≤ b) : □a ≤ □b := by
  have h2 : □a = □a ⊓ □b := by rw [← box_inf]; rw [inf_eq_left.mpr h]
  rw [h2]; exact inf_le_right

-- !-- Axiom 4 from Löb (the classic trick): with c := a ⊓ □a one has a ≤ □c ⇨ c, so
--     □a ≤ □(□c⇨c) ≤ □c = □a ⊓ □□a ≤ □□a. -- !--
/-- **Transitivity axiom `4` is derivable from Löb**: `□a ≤ □□a`.  This is the famous
fact that provability logic needs no separate transitivity axiom — Löb implies it. -/
theorem box_transitive (a : H) : □a ≤ □□a := by
  set c := a ⊓ □a with hc
  have hbc : □c = □a ⊓ □□a := box_inf a (□a)
  have key : a ≤ □c ⇨ c := by
    rw [le_himp_iff, hbc, hc]; exact inf_le_inf_left a inf_le_left
  have h3 : □a ≤ □c := le_trans (box_mono key) (loeb c)
  rw [hbc] at h3; exact le_trans h3 inf_le_right

-- !-- ≤ is Löb; ≥ is monotonicity applied to a ⊓ □a ≤ a, i.e. a ≤ □a ⇨ a. -- !--
/-- **The equality form of Löb's axiom**: `□(□a ⇨ a) = □a`. -/
theorem loeb_eq (a : H) : □(□a ⇨ a) = □a := by
  refine le_antisymm (loeb a) (box_mono ?_)
  rw [le_himp_iff]; exact inf_le_left

-- !-- If □a ≤ a then □a⇨a = ⊤, so □(□a⇨a) = □⊤ = ⊤; Löb gives ⊤ ≤ □a ≤ a. -- !--
/-- **Löb's rule**: if `□a ≤ a` then `a = ⊤`.  Provability of an element from its own
provability already makes it a theorem. -/
theorem loeb_rule {a : H} (h : □a ≤ a) : a = ⊤ := by
  have h2 : □(□a ⇨ a) = ⊤ := by rw [himp_eq_top_iff.mpr h]; exact box_top
  have h3 := loeb a; rw [h2] at h3
  have hba : □a = ⊤ := top_le_iff.mp h3
  exact top_le_iff.mp (le_trans (le_of_eq hba.symm) h)

/-- A consequence of Löb's rule: the **only self-provable element is `⊤`**.  If `□a = a`
then `a = ⊤`; there are no non-trivial fixed points of `□`. -/
theorem box_fixedPoint_eq_top {a : H} (h : □a = a) : a = ⊤ :=
  loeb_rule h.le

-- !-- Löb at ⊥: □(□⊥⇨⊥) ≤ □⊥; if the LHS were ⊤ then □⊥ = ⊤, contradicting consistency. -- !--
/-- **Gödel's second incompleteness theorem (algebraic form).**  If the algebra is
*consistent* (`□⊥ ≠ ⊤`) then it cannot prove its own consistency: `□(□⊥ ⇨ ⊥) ≠ ⊤`. -/
theorem consistency_unprovable (h : □(⊥ : H) ≠ ⊤) : □((□(⊥ : H)) ⇨ ⊥) ≠ ⊤ := by
  intro hcon; apply h
  have := loeb (⊥ : H); rw [hcon] at this; exact top_le_iff.mp this

/-- Alias for `consistency_unprovable`: Gödel's second incompleteness theorem. -/
theorem godel_second (h : □(⊥ : H) ≠ ⊤) : □((□(⊥ : H)) ⇨ ⊥) ≠ ⊤ :=
  consistency_unprovable h

-- !-- box distributes over himp one way: from (a⇨b)⊓a ≤ b, apply □ and box_inf. -- !--
/-- **`□` distributes over implication** (one direction): `□(a ⇨ b) ≤ □a ⇨ □b`.  The
single normality consequence powering all the congruence lemmas below. -/
theorem box_himp_le (a b : H) : □(a ⇨ b) ≤ □a ⇨ □b := by
  rw [le_himp_iff, ← box_inf]; exact box_mono himp_inf_le

/-! ### The de Jongh–Sambin fixed point of `p ↦ □p ⇨ c` -/

/-- The **explicit Sambin fixed point** of the modalised map `p ↦ □p ⇨ c`, namely
`□c ⇨ c`.  With `c = ⊥` this is the Gödel "consistency" sentence `¬□⊥`. -/
def glFix (c : H) : H := □c ⇨ c

-- !-- □(□c⇨c): ≤ is Löb, ≥ is monotonicity on c ≤ □c⇨c. -- !--
/-- **The provability of the Gödel fixed point is exactly `□c`**: `□(glFix c) = □c`.
This is the computational heart of the de Jongh–Sambin theorem. -/
theorem glFix_box (c : H) : □(glFix c) = □c := by
  unfold glFix; exact le_antisymm (loeb c) (box_mono le_himp)

-- !-- Immediate from glFix_box: glFix c = □c⇨c = □(glFix c)⇨c. -- !--
/-- **Existence of the Sambin fixed point**: `glFix c` is a fixed point of `p ↦ □p ⇨ c`. -/
theorem loeb_fixed_point (c : H) : glFix c = □(glFix c) ⇨ c := by
  show □c ⇨ c = □(glFix c) ⇨ c; rw [glFix_box]

-- !-- Any fixed point a of p↦□p⇨c satisfies c ≤ a and a⊓□a ≤ c; with axiom 4 these give
--     □a = □c, whence a = □a⇨c = □c⇨c = glFix c. -- !--
/-- **Uniqueness of the Sambin fixed point (de Jongh–Sambin).**  *Every* fixed point of
the modalised map `p ↦ □p ⇨ c` equals the explicit term `glFix c = □c ⇨ c`. -/
theorem glFix_unique {a c : H} (h : a = □a ⇨ c) : a = glFix c := by
  have hca : c ≤ a := by rw [h]; exact le_himp
  have h1 : □c ≤ □a := box_mono hca
  have hac : a ⊓ □a ≤ c := le_himp_iff.mp h.le
  have h2 : □a ≤ □c := by
    have hb : □(a ⊓ □a) ≤ □c := box_mono hac
    rw [box_inf, inf_eq_left.mpr (box_transitive a)] at hb; exact hb
  have hboxeq : □a = □c := le_antisymm h2 h1
  unfold glFix; rw [h, hboxeq]

/-- **Characterisation of the fixed points** of `p ↦ □p ⇨ c`: a term is a fixed point
iff it equals the explicit Sambin solution `glFix c`. -/
theorem glFix_iff {a c : H} : a = □a ⇨ c ↔ a = glFix c := by
  constructor
  · exact glFix_unique
  · rintro rfl; exact loeb_fixed_point c

/-! ### General de Jongh–Sambin uniqueness via biimplication -/

/-- The Heyting **biimplication** `a ⇔ b := (a ⇨ b) ⊓ (b ⇨ a)`. -/
def biimp (a b : H) : H := (a ⇨ b) ⊓ (b ⇨ a)

-- !-- biimp a b = ⊤ ↔ a⇨b = ⊤ and b⇨a = ⊤ ↔ a ≤ b and b ≤ a ↔ a = b. -- !--
omit [GLOperator H] in
/-- `biimp a b = ⊤` is exactly equality `a = b`. -/
theorem biimp_eq_top_iff {a b : H} : biimp a b = ⊤ ↔ a = b := by
  unfold biimp
  rw [inf_eq_top_iff, himp_eq_top_iff, himp_eq_top_iff]
  exact ⟨fun ⟨h1, h2⟩ => le_antisymm h1 h2, fun h => ⟨h.le, h.ge⟩⟩

-- !-- biimp = (a⇨b)⊓(b⇨a); apply box_inf and box_himp_le componentwise. -- !--
/-- `□` is a **congruence for `biimp`**: `□(a ⇔ b) ≤ (□a) ⇔ (□b)`. -/
theorem box_biimp_le (a b : H) : □(biimp a b) ≤ biimp (□a) (□b) := by
  unfold biimp; rw [box_inf]
  exact inf_le_inf (box_himp_le a b) (box_himp_le b a)

/-- A **box-congruent** (modalised) operator `f` is one for which the biimplication of
inputs, once boxed, entails the biimplication of outputs: `□(a ⇔ b) ≤ (f a) ⇔ (f b)`.
Syntactically this captures "the variable occurs only inside `□`". -/
def BoxCongruent (f : H → H) : Prop := ∀ a b, □(biimp a b) ≤ biimp (f a) (f b)

-- !-- At fixed points fa=a, fb=b, box-congruence gives □(a⇔b) ≤ (a⇔b); Löb's rule then
--     forces a⇔b = ⊤, i.e. a = b. -- !--
/-- **General de Jongh–Sambin uniqueness.**  A box-congruent operator has at most one
fixed point: if `a = f a` and `b = f b` with `f` box-congruent, then `a = b`.  This is
Löb's *rule* applied to the biimplication of the two candidate fixed points. -/
theorem modalised_fixedPoint_unique {f : H → H} (hf : BoxCongruent f)
    {a b : H} (ha : a = f a) (hb : b = f b) : a = b := by
  have key : □(biimp a b) ≤ biimp a b := by
    have := hf a b; rwa [← ha, ← hb] at this
  exact biimp_eq_top_iff.mp (loeb_rule key)

-- !-- biimp a b ⊓ (a⇨c) ⊓ b ≤ a ⊓ (a⇨c) ≤ c, and symmetrically; so biimp is preserved
--     by the antitone map · ⇨ c. -- !--
omit [GLOperator H] in
/-- `biimp` is preserved by the (antitone) map `· ⇨ c`: `a ⇔ b ≤ (a ⇨ c) ⇔ (b ⇨ c)`. -/
theorem biimp_himp_const (a b c : H) : biimp a b ≤ biimp (a ⇨ c) (b ⇨ c) := by
  unfold biimp
  apply le_inf
  · rw [le_himp_iff, le_himp_iff]
    calc (a ⇨ b) ⊓ (b ⇨ a) ⊓ (a ⇨ c) ⊓ b ≤ a ⊓ (a ⇨ c) := by
            apply le_inf
            · exact le_trans (inf_le_inf_right _ (le_trans inf_le_left inf_le_right)) himp_inf_le
            · exact le_trans inf_le_left inf_le_right
      _ ≤ c := himp_inf_le |>.trans_eq' (by rw [inf_comm])
  · rw [le_himp_iff, le_himp_iff]
    calc (a ⇨ b) ⊓ (b ⇨ a) ⊓ (b ⇨ c) ⊓ a ≤ b ⊓ (b ⇨ c) := by
            apply le_inf
            · exact le_trans (inf_le_inf_right _ (le_trans inf_le_left inf_le_left)) himp_inf_le
            · exact le_trans inf_le_left inf_le_right
      _ ≤ c := himp_inf_le |>.trans_eq' (by rw [inf_comm])

-- !-- biimp a b ⊓ (d⊓a) ≤ d (clear) and ≤ b (since biimp ≤ a⇨b); symmetrically. -- !--
omit [GLOperator H] in
/-- `biimp` is preserved by the (monotone) map `d ⊓ ·`: `a ⇔ b ≤ (d ⊓ a) ⇔ (d ⊓ b)`. -/
theorem biimp_inf_const (a b d : H) : biimp a b ≤ biimp (d ⊓ a) (d ⊓ b) := by
  unfold biimp
  apply le_inf
  · rw [le_himp_iff]
    apply le_inf
    · exact le_trans inf_le_right inf_le_left
    · calc (a ⇨ b) ⊓ (b ⇨ a) ⊓ (d ⊓ a) ≤ (a ⇨ b) ⊓ a := by
            apply le_inf
            · exact le_trans inf_le_left inf_le_left
            · exact le_trans inf_le_right inf_le_right
        _ ≤ b := himp_inf_le |>.trans_eq' (by rw [inf_comm])
  · rw [le_himp_iff]
    apply le_inf
    · exact le_trans inf_le_right inf_le_left
    · calc (a ⇨ b) ⊓ (b ⇨ a) ⊓ (d ⊓ b) ≤ (b ⇨ a) ⊓ b := by
            apply le_inf
            · exact le_trans inf_le_left inf_le_right
            · exact le_trans inf_le_right inf_le_right
        _ ≤ a := himp_inf_le |>.trans_eq' (by rw [inf_comm])

end GLOperator