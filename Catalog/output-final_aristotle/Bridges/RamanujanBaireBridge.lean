import Mathlib

/-!
# A bridge: diagonalization against oracles is *topological genericity*

This file connects two seemingly unrelated areas:

* **Recursion theory / cardinality** — the counting–diagonalization argument that a
  countable family of "Ramanujan oracles" (devices deciding number-theoretic
  statements) cannot be perfectly correct across all possible ground truths; and
* **Point-set topology (Baire category)** — the notion of a *comeager* (topologically
  generic, "large") subset of the Cantor space `ℕ → Bool`.

The parent project `Cryptography/RamanujanOracle.lean` proves, by a counting argument,
that for any countable family of oracles the set of ground truths defeating the whole
family is *uncountable*.  Here we sharpen "uncountable" to the topological statement
that this defeating set is **comeager / dense** in the Cantor space, and dually that
the set of "covered" truths (some oracle is perfect) is **meagre**.

The bridge rests on a single structural fact plus the Baire category theorem:

* an oracle is perfect for **at most one** ground truth (`perfect_unique`), so each
  oracle's perfect set is a *subsingleton*;
* in the Cantor space `ℕ → Bool` **no point is isolated** (`singleton_notMem_nhds`),
  hence every singleton — and every subsingleton — is *nowhere dense*
  (`isNowhereDense_singleton`, `isNowhereDense_of_subsingleton`);
* a countable union of nowhere dense sets is meagre, so the covered set is meagre
  (`covered_isMeagre`), and by the Baire category theorem (`ℕ → Bool` is a
  `BaireSpace`) its complement — the defeating set — is dense (`missed_dense`).

We then transport the result to *genuine* computability: there are only countably many
`Computable` oracles (`countable_computable_oracles`), so a **topologically generic**
ground truth defeats every computable oracle at once
(`defeating_computable_comeager`, `missed_computable_dense`).

The upshot — the "connector" — is that Cantor's diagonal against a countable list of
oracles is not an ad hoc trick but an instance of *Baire genericity*: the winning
diagonal truths are exactly a residual set.

## Main results

* `singleton_notMem_nhds` — `ℕ → Bool` has no isolated points.
* `isNowhereDense_singleton`, `isNowhereDense_of_subsingleton` — subsingletons are
  nowhere dense in the Cantor space.
* `covered_isMeagre` — for a countable family, the covered truths form a meagre set.
* `missed_dense` — the defeating truths form a dense (comeager) set.
* `missed_nonempty` — in particular the defeating set is nonempty (recovers the
  counting theorem's existence conclusion, now via Baire category).
* `countable_computable_oracles` — there are only countably many computable oracles.
* `defeating_computable_comeager` / `missed_computable_dense` — a topologically generic
  ground truth defeats every computable oracle.
-/

namespace RamanujanBaireBridge

open Set Filter

/-- Statements are Gödel-numbered by the naturals; a *ground truth* is an assignment of
a Boolean truth value to each statement.  The space of ground truths is the Cantor
space `ℕ → Bool`. -/
abbrev Truth : Type := ℕ → Bool

/-- An *oracle* answers each statement with a definite verdict (`some true`/`some
false`) or with `none` ("unknown"). -/
abbrev Oracle : Type := ℕ → Option Bool

/-- The oracle `O` is *perfect* for the ground truth `T` if it returns the correct
verdict on every statement. -/
def PerfectOn (O : Oracle) (T : Truth) : Prop := ∀ n, O n = some (T n)

/-- An oracle can be perfect for **at most one** ground truth: a perfect oracle pins
down the world it lives in.  This is the structural fact powering the whole bridge. -/
theorem perfect_unique {O : Oracle} {T T' : Truth}
    (h : PerfectOn O T) (h' : PerfectOn O T') : T = T' := by
  funext n
  have := (h n).symm.trans (h' n)
  simpa using this

/-! ### Cantor space has no isolated points -/

/-- **No isolated points.**  In the Cantor space `ℕ → Bool`, the singleton `{x}` is not
a neighbourhood of `x`: any basic (finite-support) neighbourhood of `x` also contains a
point differing from `x` at some coordinate outside the finite support. -/
theorem singleton_notMem_nhds (x : ℕ → Bool) : ({x} : Set (ℕ → Bool)) ∉ nhds x := by
  rw [nhds_pi]
  intro h
  rw [Filter.mem_pi] at h
  obtain ⟨I, hI, t, ht, hsub⟩ := h
  obtain ⟨j, hj⟩ := hI.infinite_compl.nonempty
  set y : ℕ → Bool := Function.update x j (!x j) with hy
  have hyx : y ≠ x := by
    intro hc
    have := congrFun hc j
    simp [hy] at this
  have hymem : y ∈ Set.pi I t := by
    intro i hi
    have hne : i ≠ j := by rintro rfl; exact hj hi
    have : y i = x i := by simp only [hy]; exact Function.update_of_ne hne _ x
    rw [this]
    exact mem_of_mem_nhds (ht i)
  have := hsub hymem
  simp at this
  exact hyx this

/-- Every singleton in the Cantor space is nowhere dense (its closure `{x}` has empty
interior, since `x` is not isolated). -/
theorem isNowhereDense_singleton (x : ℕ → Bool) :
    IsNowhereDense ({x} : Set (ℕ → Bool)) := by
  rw [IsNowhereDense, closure_singleton, Set.eq_empty_iff_forall_notMem]
  intro y hy
  have hyx : y = x := by
    have := interior_subset hy
    rwa [mem_singleton_iff] at this
  have hx : x ∈ interior ({x} : Set (ℕ → Bool)) := hyx ▸ hy
  exact singleton_notMem_nhds x (mem_interior_iff_mem_nhds.mp hx)

/-- Every subsingleton subset of the Cantor space is nowhere dense. -/
theorem isNowhereDense_of_subsingleton {s : Set (ℕ → Bool)} (hs : s.Subsingleton) :
    IsNowhereDense s := by
  rcases hs.eq_empty_or_singleton with h | ⟨x, hx⟩
  · rw [h]; exact isNowhereDense_empty
  · rw [hx]; exact isNowhereDense_singleton x

/-! ### The bridge: the covered set is meagre, the defeating set is comeager -/

/-- The set of ground truths for which some member of a **countable** family of oracles
is perfect is **meagre**: it is a countable union of perfect sets, each a subsingleton
(by `perfect_unique`) and hence nowhere dense. -/
theorem covered_isMeagre {ι : Type*} [Countable ι] (F : ι → Oracle) :
    IsMeagre {T : Truth | ∃ i, PerfectOn (F i) T} := by
  have hEq : {T : Truth | ∃ i, PerfectOn (F i) T}
      = ⋃ i, {T : Truth | PerfectOn (F i) T} := by ext T; simp
  rw [hEq]
  apply isMeagre_iUnion
  intro i
  apply IsNowhereDense.isMeagre
  apply isNowhereDense_of_subsingleton
  intro a ha b hb
  exact perfect_unique ha hb

/-- **The connector.**  For any countable family of oracles the set of ground truths
defeating the *entire* family (no oracle is perfect) is **dense / comeager** in the
Cantor space.  This upgrades the counting theorem ("uncountably many truths escape") to
a topological genericity statement, obtained via the Baire category theorem: the
defeating set is the complement of a meagre set, hence residual, hence dense. -/
theorem missed_dense {ι : Type*} [Countable ι] (F : ι → Oracle) :
    Dense {T : Truth | ∀ i, ¬ PerfectOn (F i) T} := by
  have hmem : {T : Truth | ∀ i, ¬ PerfectOn (F i) T}
      = {T : Truth | ∃ i, PerfectOn (F i) T}ᶜ := by ext T; simp
  rw [hmem]
  exact dense_of_mem_residual (covered_isMeagre F)

/-- The defeating set is residual (comeager): a topologically "large" set of worlds. -/
theorem missed_residual {ι : Type*} [Countable ι] (F : ι → Oracle) :
    {T : Truth | ∀ i, ¬ PerfectOn (F i) T} ∈ residual (ℕ → Bool) := by
  have hmem : {T : Truth | ∀ i, ¬ PerfectOn (F i) T}
      = {T : Truth | ∃ i, PerfectOn (F i) T}ᶜ := by ext T; simp
  rw [hmem]
  exact covered_isMeagre F

/-- Existence corollary (recovering the counting theorem via Baire category): some
ground truth defeats every oracle in a countable family. -/
theorem missed_nonempty {ι : Type*} [Countable ι] (F : ι → Oracle) :
    ∃ T : Truth, ∀ i, ¬ PerfectOn (F i) T := by
  have hd := (missed_dense F).nonempty
  obtain ⟨T, hT⟩ := hd
  exact ⟨T, hT⟩

/-! ### Transport to genuine computability -/

/-- **There are only countably many computable oracles.**  Each computable oracle is
computed by some code in `Nat.Partrec.Code`, distinct oracles require distinct codes,
and the type of codes is countable. -/
theorem countable_computable_oracles : Countable {O : Oracle // Computable O} := by
  have key : ∀ O : Oracle, Computable O →
      ∃ c : Nat.Partrec.Code, ∀ n, c.eval n = Part.some (Encodable.encode (O n)) := by
    intro O hO
    have hp : Partrec (fun a => (O a : Part (Option Bool))) := hO.partrec
    rw [Partrec] at hp
    obtain ⟨c, hc⟩ := Nat.Partrec.Code.exists_code.mp hp
    exact ⟨c, fun n => by rw [hc]; simp⟩
  choose f hf using key
  have hinj : Function.Injective (fun O : {O // Computable O} => f O.1 O.2) := by
    intro a b hab
    apply Subtype.ext
    funext n
    have ha := hf a.1 a.2 n
    have hb := hf b.1 b.2 n
    simp only at hab
    rw [hab, hb] at ha
    exact Encodable.encode_injective (Part.some_inj.mp ha.symm)
  exact hinj.countable

/-- The set of ground truths that some *computable* oracle decides perfectly is meagre.
-/
theorem defeating_computable_comeager :
    IsMeagre {T : Truth | ∃ O : Oracle, Computable O ∧ PerfectOn O T} := by
  haveI := countable_computable_oracles
  have hEq : {T : Truth | ∃ O : Oracle, Computable O ∧ PerfectOn O T}
      = {T : Truth | ∃ O : {O : Oracle // Computable O}, PerfectOn O.1 T} := by
    ext T; constructor
    · rintro ⟨O, hO, hP⟩; exact ⟨⟨O, hO⟩, hP⟩
    · rintro ⟨⟨O, hO⟩, hP⟩; exact ⟨O, hO, hP⟩
  rw [hEq]
  exact covered_isMeagre (fun O : {O : Oracle // Computable O} => O.1)

/-- **Honest-computability form of the connector.**  A *topologically generic* ground
truth defeats every computable oracle simultaneously: the set of ground truths on which
no computable oracle is perfect is dense (comeager) in the Cantor space. -/
theorem missed_computable_dense :
    Dense {T : Truth | ∀ O : Oracle, Computable O → ¬ PerfectOn O T} := by
  have hmem : {T : Truth | ∀ O : Oracle, Computable O → ¬ PerfectOn O T}
      = {T : Truth | ∃ O : Oracle, Computable O ∧ PerfectOn O T}ᶜ := by
    ext T; simp only [mem_setOf_eq, mem_compl_iff, not_exists, not_and]
  rw [hmem]
  exact dense_of_mem_residual defeating_computable_comeager

/-- Existence corollary: some ground truth defeats every computable oracle. -/
theorem exists_truth_no_computable_perfect :
    ∃ T : Truth, ∀ O : Oracle, Computable O → ¬ PerfectOn O T := by
  obtain ⟨T, hT⟩ := (missed_computable_dense).nonempty
  exact ⟨T, hT⟩

end RamanujanBaireBridge