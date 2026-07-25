import Logic.LobFixedPoint
import Logic.LobNatModel

/-!
# Gödel–Löb Algebras from Transitive Converse-Well-Founded Frames

This file generalises the concrete `ℕ`-model `NatGL`
(`Catalog/Logic/LobNatModel.lean`) from the single frame `(ℕ, >)` to **every transitive
converse-well-founded frame**, and pushes the provability-rank computation *past `ω`*
into the proper class of ordinals (Direction 4 of the previous cycle's
`FUTURE_DIRECTIONS`).

For a relation `r : α → α → Prop` the **frame box** is
`wfBox r S = { x | ∀ y, r y x → y ∈ S }` — "`x` proves `S` iff every `r`-predecessor of
`x` satisfies `S`".  We prove:

* `wfBox_loeb` — **Löb's axiom holds for `wfBox r` whenever `r` is transitive and
  well-founded.**  This is the exact frame condition for `GL`: transitivity gives axiom
  `4`, converse-well-foundedness gives Löb.  It generalises `natBox_loeb` (the `(ℕ, <)`
  instance) to arbitrary GL frames and is the engine of soundness for the whole class.
* `natBox_eq_wfBox` — the existing `ℕ`-model is literally the `r = (· < ·)` instance.
* `OrdGL` — the `GLOperator (Set Ordinal)` instance for the frame `(Ordinal, <)`,
  making every abstract `GLOperator` theorem (Löb's rule, the Sambin fixed point,
  axiom 4, Gödel II) available transfinitely.
* `ordBox_Iio` — **the transfinite provability-rank ladder** `□(Iio a) = Iio (a+1)`:
  applying the box to the "depth-`a` falsity" advances the rank by exactly one
  successor, for *every* ordinal `a` — the limit-and-beyond analogue of
  `natBox_iterate_eq_Iio`.
* `ordGL_consistent` — the ordinal model is consistent (`□⊥ ≠ ⊤`).
* `ordinal_consistency_strictMono` — the consistency strengths `a ↦ Iio a` form a
  **proper-class strictly increasing chain**, never reaching `⊤`.
* `ordinal_godel_hierarchy` — **transfinite graded Gödel II**: for every ordinal `a`
  the consistency statement `Iio (a+1) ⇨ ⊥` is unprovable, an unprovability spectrum
  indexed by the ordinals.

-- !-- Lab Notebook: wfBox / OrdGL -- !--
-- !-- Hypothesis: NatGL's Löb proof never used anything about ℕ except that `<` is
--     transitive and well-founded; so the same box on ANY transitive converse-well-
--     founded frame is a GLOperator, and the rank computation `□^k⊥ = Iio k` lifts to
--     ordinals as `□(Iio a) = Iio (a+1)`. -- !--
-- !-- Result: Confirmed. wfBox_loeb is well-founded induction on the witness with one
--     use of transitivity (`r p m → r m n → r p n`) — exactly the spot where the ℕ
--     proof used `lt_trans`. The ordinal ladder `□(Iio a) = Iio (a+1)` is
--     `Order.lt_succ_iff`: `(∀ y < x, y < a) ↔ x ≤ a ↔ x < a+1`. -- !--
-- !-- Insight: Löb = transitivity (axiom 4) + converse-well-foundedness (the descent
--     that Löb's rule forbids reflexive points of). Provability RANK is the identity
--     `a ↦ Iio a` on ordinals just as it was on ℕ; nothing special happens at limits —
--     the box simply takes successors, so the hierarchy is a proper class. -- !--
-- !-- Failure analysis: Dropping transitivity breaks Löb (a well-founded but
--     non-transitive frame need not validate axiom 4, hence not GL); both hypotheses
--     are load-bearing in wfBox_loeb. -- !--
-- !-- End Lab Notebook -- !--
-/

open GLOperator Set

variable {α : Type*}

/-- The **provability box of a frame `(α, r)`**: `x` proves `S` iff every
`r`-predecessor of `x` lies in `S`.  Generalises `natBox` (the `r = (· < ·)` case). -/
def wfBox (r : α → α → Prop) (S : Set α) : Set α := { x | ∀ y, r y x → y ∈ S }

@[simp] theorem mem_wfBox {r : α → α → Prop} {S : Set α} {x : α} :
    x ∈ wfBox r S ↔ ∀ y, r y x → y ∈ S := Iff.rfl

-- !-- `⊤ = univ`: every predecessor is trivially in `univ`. -- !--
/-- Necessitation of truth for the frame box. -/
theorem wfBox_top (r : α → α → Prop) : wfBox r (⊤ : Set α) = ⊤ :=
  Set.eq_univ_of_forall fun x => by simp [wfBox]

-- !-- "all predecessors in A∩B" = "all in A" and "all in B". -- !--
/-- Normality (axiom K) for the frame box: it preserves binary meets. -/
theorem wfBox_inf (r : α → α → Prop) (A B : Set α) :
    wfBox r (A ∩ B) = wfBox r A ∩ wfBox r B := by
  ext x
  simp only [mem_wfBox, Set.mem_inter_iff]
  exact ⟨fun h => ⟨fun y hy => (h y hy).1, fun y hy => (h y hy).2⟩,
    fun ⟨hA, hB⟩ y hy => ⟨hA y hy, hB y hy⟩⟩

-- !-- Löb's axiom by well-founded induction on the witness `m`; the single use of
--     transitivity is `r p m → r m n → r p n`, exactly where the ℕ proof used
--     `lt_trans`. Mirrors `natBox_loeb`. -- !--
/-- **Löb's axiom for transitive converse-well-founded frames.**
`wfBox r ((wfBox r S) ⇨ S) ≤ wfBox r S` whenever `r` is transitive and well-founded.
This is the frame-theoretic heart of `GL` soundness and generalises `natBox_loeb`. -/
theorem wfBox_loeb (r : α → α → Prop) (htrans : Transitive r) (hwf : WellFounded r)
    (S : Set α) : wfBox r ((wfBox r S) ⇨ S) ≤ wfBox r S := by
  intro n hn m hm
  induction' m using hwf.induction with m ih
  exact hn m hm fun p hp => ih p hp (htrans hp hm)

-- !-- Definitional: both sides are `{x | ∀ y, y < x → y ∈ S}`. -- !--
/-- The existing `ℕ`-model `natBox` is exactly the frame box of `(ℕ, <)`. -/
theorem natBox_eq_wfBox : natBox = wfBox ((· < ·) : ℕ → ℕ → Prop) := rfl

/-! ### The transfinite ordinal model `(Ordinal, <)` -/

/-- The **canonical Gödel–Löb algebra on `Set Ordinal`** for the frame `(Ordinal, <)`.
Every `GLOperator` theorem now holds transfinitely. -/
instance OrdGL : GLOperator (Set Ordinal) where
  box := wfBox (· < ·)
  box_top := wfBox_top _
  box_inf := wfBox_inf _
  loeb := wfBox_loeb _ (fun _ _ _ h1 h2 => lt_trans h1 h2) Ordinal.lt_wf

@[simp] theorem ordGL_box (S : Set Ordinal) : (□S) = wfBox (· < ·) S := rfl

-- !-- `(∀ y < x, y < a) ↔ x ≤ a ↔ x < a+1`, by `Order.lt_succ_iff`. -- !--
/-- **The transfinite provability-rank ladder.**  Boxing the depth-`a` falsity `Iio a`
yields the depth-`(a+1)` falsity: `□(Iio a) = Iio (a+1)`, for every ordinal `a`. -/
theorem ordBox_Iio (a : Ordinal) :
    wfBox (· < ·) (Set.Iio a) = Set.Iio (Order.succ a) := by
  ext x
  simp only [mem_wfBox, Set.mem_Iio, Order.lt_succ_iff]
  exact ⟨fun h => le_of_not_gt fun hx => by simpa using h a hx,
    fun h y hy => lt_of_lt_of_le hy h⟩

-- !-- `□⊥ = wfBox ∅ = {0}` (only `0` has no predecessor); `≠ univ` since `1 ∉`. -- !--
/-- **The ordinal model is consistent**: `□⊥ ≠ ⊤`. -/
theorem ordGL_consistent : (□(⊥ : Set Ordinal)) ≠ ⊤ := by
  simp only [ordGL_box, ne_eq, Set.ext_iff, not_forall]
  exact ⟨1, by simp [wfBox]⟩

-- !-- `Iio` is strictly monotone on a linear order: `a < b → Iio a ⊂ Iio b`. -- !--
/-- **A proper-class strictly increasing chain of consistency strengths.**
`a ↦ Iio a` is strictly monotone, so the ordinal-indexed consistency statements form a
chain that strictly increases through every ordinal and never reaches `⊤`. -/
theorem ordinal_consistency_strictMono :
    StrictMono (fun a : Ordinal => Set.Iio a) :=
  fun _ _ hab => Set.Iio_ssubset_Iio_iff.mpr hab

-- !-- `Iio (a+1)` is nonempty (`a ∈ Iio (a+1)`), so `□(Iio(a+1) ⇨ ⊥)` fails at the
--     successor world `a+1`, witnessing `≠ ⊤`. -- !--
/-- **Transfinite graded Gödel II.**  For every ordinal `a`, the consistency statement
`Iio (a+1) ⇨ ⊥` is unprovable: `□((Iio (a+1)) ⇨ ⊥) ≠ ⊤`.  An unprovability spectrum
indexed by the entire class of ordinals. -/
theorem ordinal_godel_hierarchy (a : Ordinal) :
    (□((Set.Iio (Order.succ a)) ⇨ (⊥ : Set Ordinal))) ≠ ⊤ := by
  intro h
  have ha_lt : a < Order.succ a := Order.lt_succ_iff.mpr le_rfl
  have hw : Order.succ a ∈ (□((Set.Iio (Order.succ a)) ⇨ (⊥ : Set Ordinal))) := by
    rw [h]; exact Set.mem_univ _
  rw [ordGL_box, mem_wfBox] at hw
  have ha : a ∈ ((Set.Iio (Order.succ a)) ⇨ (⊥ : Set Ordinal)) := hw a ha_lt
  exact (ha (Set.mem_Iio.mpr ha_lt)).elim