import Applications.MindTools.Basic

/-!
# Mind Tools — category theory as a strictly stronger mind tool than set theory

The mission's third claim: *category theory is a more powerful mind tool than set
theory for certain classes of problems, because it proves things about all
objects simultaneously.*

We formalize the operative contrast — **"one universal proof settles an infinite
family at once"** versus **"instances proved one at a time"** — on a fixed class
of problems `probStmt : ℕ → Statement` (an injective family of statements, think:
"the statement of the problem for object `n`").

* `setLevel F` — a *set-theoretic* system that has settled exactly the finite set
  of instances indexed by a `Finset` `F`.  Its theorems are `probStmt '' F`,
  always **finite**.
* `catLevel` — a *category-theoretic* system that, from a single universal
  theorem, settles the **entire** family at once.  Its theorems are the full
  `range probStmt`, which is **infinite**.

Results:

* `catLevel_proves_all` — the categorical system proves every instance;
* `setLevel_proves_iff` — the set-level system proves instance `n` iff `n` was
  explicitly included;
* `setLevel_ssubset_catLevel` / `catLevel_is_mind_tool` — the categorical system
  strictly extends *every* finite set-level system, and is a mind tool over each;
* `no_finite_setLevel_matches_catLevel` — no amount of finite, instance-by-
  instance set-level work ever matches the single categorical theorem.

This is a faithful, if deliberately austere, rendering of "reasoning about all
categories simultaneously beats reasoning one object at a time".
-/

namespace MindTools

open scoped Classical

/-- The class of problems: `probStmt n` is the statement of "the problem" for
object `n`.  We use an injective encoding so distinct objects give distinct
statements. -/
def probStmt (n : ℕ) : Statement := {n}

theorem probStmt_injective : Function.Injective probStmt := by
  intro a b h
  simpa [probStmt] using h

/-- A set-theoretic system that has proved exactly the (finite) family of
instances indexed by `F`. -/
def setLevel (F : Finset ℕ) : FormalSystem := ⟨probStmt '' (F : Set ℕ)⟩

/-- The category-theoretic system: one universal theorem settles the whole
family, so it proves every instance. -/
def catLevel : FormalSystem := ⟨Set.range probStmt⟩

/-- The categorical system proves **every** instance of the problem class
simultaneously. -/
theorem catLevel_proves_all (n : ℕ) : probStmt n ∈ catLevel.Thm :=
  Set.mem_range_self n

/-- The set-level system proves instance `n` *iff* `n` was explicitly included in
its finite stock of solved cases. -/
theorem setLevel_proves_iff (F : Finset ℕ) (n : ℕ) :
    probStmt n ∈ (setLevel F).Thm ↔ n ∈ F := by
  simp only [setLevel, Set.mem_image, Finset.mem_coe]
  constructor
  · rintro ⟨m, hm, hmn⟩
    rwa [probStmt_injective hmn] at hm
  · intro hn
    exact ⟨n, hn, rfl⟩

/-- Every set-level system has only finitely many theorems. -/
theorem setLevel_finite (F : Finset ℕ) : (setLevel F).Thm.Finite :=
  (F.finite_toSet).image probStmt

/-- The categorical system has infinitely many theorems. -/
theorem catLevel_infinite : catLevel.Thm.Infinite :=
  Set.infinite_range_of_injective probStmt_injective

/-- **Category theory strictly dominates finite set-level work.** The categorical
system strictly extends *every* finite set-level system. -/
theorem setLevel_ssubset_catLevel (F : Finset ℕ) :
    (setLevel F).Thm ⊂ catLevel.Thm := by
  apply (Set.ssubset_iff_of_subset ?_).mpr
  · obtain ⟨x, hx⟩ := (catLevel_infinite.diff (setLevel_finite F)).nonempty
    rw [Set.mem_diff] at hx
    exact ⟨x, hx.1, hx.2⟩
  · intro x hx
    obtain ⟨m, _, hmx⟩ := hx
    exact ⟨m, hmx⟩

/-- The categorical system is a mind tool relative to every finite set-level
system. -/
theorem catLevel_is_mind_tool (F : Finset ℕ) :
    IsMindTool (setLevel F) catLevel :=
  setLevel_ssubset_catLevel F

/-- **No finite set-level effort ever matches the categorical theorem.**  No
matter how many individual instances a set-theoretic worker settles, the result
is never the whole family that one categorical theorem delivers. -/
theorem no_finite_setLevel_matches_catLevel :
    ¬ ∃ F : Finset ℕ, setLevel F = catLevel := by
  rintro ⟨F, hF⟩
  have hfin : catLevel.Thm.Finite := by rw [← hF]; exact setLevel_finite F
  exact catLevel_infinite hfin

end MindTools