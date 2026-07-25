/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# I Am a Strange Loop, Part II: The Minimum Loop Length is 3

Hofstadter insists a *strange* loop is more than trivial self-reference.
"I am I" (a reflexive self-loop) and "A mirrors B, B mirrors A" (a mutual
2-cycle) are not yet genuine strange loops: the first is a tautology, the
second a mere pair of mirrors.  A genuine strange loop threads *through a
hierarchy* and returns — the shortest such thread visits three distinct
levels: `system → model → model-of-model → system`.

We make this precise combinatorially.  Model "refers to / models" as a binary
relation `R` on a set of levels.  The natural non-degeneracy assumption is that
`R` is **asymmetric**: if level `a` refers up to level `b`, then `b` does not
refer back down to `a` (a strict, oriented hierarchy of description).  We show:

* an asymmetric relation admits **no** closed loop of length `1` or `2`
  (`no_loop_len1`, `no_loop_len2`);
* loops of **every** length `n ≥ 3` genuinely occur (`exists_loop_len`,
  witnessed by the "rock-paper-scissors" successor relation on `ZMod n`);
* hence `3` is exactly the **minimum strange-loop length** (`min_loop_length`);
* a *strict hierarchy* — a transitive, irreflexive relation, i.e. an actual
  partial order of levels — has no strange loops at all
  (`strictOrder_no_loop`).  Strangeness therefore requires **abandoning
  transitivity**: the loop must be non-composable, exactly Hofstadter's
  "tangled hierarchy".

Loops are indexed by `ZMod n`, whose additive `+1` gives the cyclic
"next step" for free.  This file is fully self-contained.
-/
import Mathlib

namespace StrangeLoop

open Relation

/-! ## Loops and the non-degeneracy (asymmetry) condition -/

/-- A relation `R` is **asymmetric**: no two levels refer to each other.  This
is the oriented-hierarchy condition; it implies irreflexivity. -/
def Asymm {V : Type*} (R : V → V → Prop) : Prop := ∀ a b, R a b → ¬ R b a

/-- An asymmetric relation is irreflexive: no level refers to itself. -/
theorem Asymm.irrefl {V : Type*} {R : V → V → Prop} (h : Asymm R) (a : V) : ¬ R a a :=
  fun ha => h a a ha ha

/-- A **closed loop of length `n`** in `R`: an assignment `v` of levels to the
`n` cyclic positions `ZMod n` such that consecutive positions are `R`-related,
with the last wrapping back to the first via `+1`. -/
def IsLoop {V : Type*} (R : V → V → Prop) (n : ℕ) (v : ZMod n → V) : Prop :=
  ∀ i : ZMod n, R (v i) (v (i + 1))

/-! ## No strange loops of length 1 or 2 -/

/-- **No length-1 loop.**  A reflexive self-loop `R x x` is forbidden by
asymmetry: "I am I" is not a strange loop. -/
theorem no_loop_len1 {V : Type*} {R : V → V → Prop} (h : Asymm R) :
    ¬ ∃ v : ZMod 1 → V, IsLoop R 1 v := by
  rintro ⟨v, hv⟩
  have h0 := hv 0
  simp at h0
  exact h.irrefl _ h0

/-- **No length-2 loop.**  A mutual 2-cycle `R a b ∧ R b a` is forbidden by
asymmetry: two mirrors are not a strange loop. -/
theorem no_loop_len2 {V : Type*} {R : V → V → Prop} (h : Asymm R) :
    ¬ ∃ v : ZMod 2 → V, IsLoop R 2 v := by
  rintro ⟨v, hv⟩
  have h0 := hv 0
  have h1 := hv 1
  simp at h0 h1
  exact h _ _ h0 h1

/-! ## Strange loops of every length `n ≥ 3` exist

The witness is the cyclic **successor** relation `b = a + 1` on `ZMod n`
(rock-paper-scissors when `n = 3`). -/

/-- The successor relation on `ZMod n` is asymmetric for every `n ≥ 3`:
`a + 1 = b` and `b + 1 = a` would force `2 = 0` in `ZMod n`, i.e. `n ∣ 2`. -/
theorem succ_asymm {n : ℕ} (hn : 3 ≤ n) :
    Asymm (fun a b : ZMod n => b = a + 1) := by
  intro a b hab hba
  subst hab
  have h2 : (2 : ZMod n) = 0 := by linear_combination -hba
  have hcast : ((2 : ℕ) : ZMod n) = 0 := by exact_mod_cast h2
  have hdvd : n ∣ 2 := (CharP.cast_eq_zero_iff (ZMod n) n 2).mp hcast
  have := Nat.le_of_dvd (by norm_num) hdvd
  omega

/-- **Existence of strange loops of every length `n ≥ 3`.**  The identity
assignment on `ZMod n` is a length-`n` loop of an asymmetric relation.  Longer
loops therefore genuinely exist: "strangeness" (loop length) is an unbounded
resource, matching the intuition that deeper self-reference is possible. -/
theorem exists_loop_len {n : ℕ} (hn : 3 ≤ n) :
    ∃ (V : Type) (R : V → V → Prop), Asymm R ∧ ∃ v : ZMod n → V, IsLoop R n v :=
  ⟨ZMod n, (fun a b => b = a + 1), succ_asymm hn, id, fun _ => rfl⟩

/-- **The minimum strange-loop length is exactly 3.**  Combining the previous
results: for an asymmetric ("oriented hierarchy") relation there is never a
loop of length `1` or `2`, yet loops of length `3` do occur.  So `3` is the
least length at which a genuine strange loop can exist — Hofstadter's
`system → model → model-of-model → system`. -/
theorem min_loop_length :
    (∀ {V : Type} {R : V → V → Prop}, Asymm R → ¬ ∃ v : ZMod 1 → V, IsLoop R 1 v) ∧
    (∀ {V : Type} {R : V → V → Prop}, Asymm R → ¬ ∃ v : ZMod 2 → V, IsLoop R 2 v) ∧
    (∃ (V : Type) (R : V → V → Prop), Asymm R ∧ ∃ v : ZMod 3 → V, IsLoop R 3 v) :=
  ⟨fun h => no_loop_len1 h, fun h => no_loop_len2 h, exists_loop_len (le_refl 3)⟩

/-! ## Tangled hierarchies: strangeness needs the failure of transitivity

Model "the loop closes up" abstractly as `∃ x, TransGen R x x` — some level is
reachable from itself by a finite chain of references. -/

/-- A relation **has a strange loop** if some level is reachable from itself by
a nonempty chain of references. -/
def HasStrangeLoop {V : Type*} (R : V → V → Prop) : Prop := ∃ x, TransGen R x x

/-- Any genuine loop (length `n ≥ 1`) closing up gives a `TransGen` self-cycle;
in particular reflexive self-reference already counts. -/
theorem hasStrangeLoop_of_self {V : Type*} {R : V → V → Prop} {x : V} (h : R x x) :
    HasStrangeLoop R :=
  ⟨x, TransGen.single h⟩

/-- **A strict hierarchy has no strange loops.**  If `R` is transitive and
irreflexive — a genuine strict partial order of levels — then no level can
loop back to itself.  Escaping this is only possible by giving up transitivity:
the references must fail to compose, producing Hofstadter's *tangled
hierarchy*. -/
theorem strictOrder_no_loop {V : Type*} {R : V → V → Prop}
    (htrans : Transitive R) (hirr : ∀ x, ¬ R x x) :
    ¬ HasStrangeLoop R := by
  rintro ⟨x, hx⟩
  rw [Relation.transGen_eq_self htrans] at hx
  exact hirr x hx

/-- **A concrete tangled hierarchy.**  The (non-transitive!) asymmetric
rock-paper-scissors relation on `ZMod 3` *does* have a strange loop
`0 → 1 → 2 → 0`.  Together with `strictOrder_no_loop` this shows the failure of
transitivity is exactly what admits strangeness. -/
theorem rps_hasStrangeLoop :
    HasStrangeLoop (fun a b : ZMod 3 => b = a + 1) := by
  refine ⟨0, ?_⟩
  have h01 : (fun a b : ZMod 3 => b = a + 1) 0 1 := by decide
  have h12 : (fun a b : ZMod 3 => b = a + 1) 1 2 := by decide
  have h20 : (fun a b : ZMod 3 => b = a + 1) 2 0 := by decide
  exact TransGen.head h01 (TransGen.head h12 (TransGen.single h20))

end StrangeLoop