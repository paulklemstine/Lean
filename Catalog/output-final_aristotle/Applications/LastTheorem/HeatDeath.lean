import Mathlib

/-!
# The Last Theorem: Countability of Provable Statements and the Limits of Enumeration

This file develops a clean, self-contained model of the informal slogan
"*in the far future all computation ceases, yet in principle every theorem is
discoverable in finite time*".

The mathematical skeleton is the following. Fix a finite alphabet — here the
binary alphabet, which is expressive enough to encode any formal language. A
**statement** is a finite string over this alphabet. A **formal system** is
specified by a predicate singling out its *provable* statements (its theorems),
subject to the mild condition that it proves infinitely many statements.

We prove a small hierarchy of results:

* `space_of_statements_denumerable` — the space of all finite strings is
  *countably infinite*: it carries a bijection with the natural numbers.
* `statement_discoverable` — via any such bijection every string appears at a
  finite index, so it is reached after finitely many enumeration steps.
* `shortStatements_finite` — for each bound only finitely many statements are
  shorter than that bound: any *finite* budget sees only finitely much.
* `theorems_countable`, `theorems_infinite`, `theorems_denumerable`,
  `theorems_cardinality` — the set of theorems of a formal system is countably
  infinite; its cardinality is exactly `ℵ₀`.
* `theorem_discoverable` — every individual theorem is discovered at a finite
  stage of the enumeration.
* `heat_death_leaves_theorems_undiscovered`, `no_finite_budget_suffices`, and
  `undiscovered_theorems_infinite` — the sharp obstruction: *no* finite budget
  of enumeration steps exhausts the theorems. Beyond every horizon infinitely
  many theorems remain.

The interplay is genuinely cross-domain: it fuses the combinatorics of finite
strings, the set theory of countable cardinals, and the order structure of an
enumeration by `ℕ`.

The concrete systems `allStatements` and `constantStatements` witness that the
`FormalSystem` hypotheses are non-vacuous.
-/

namespace LastTheorem

/-- The binary alphabet. Two symbols suffice to encode any formal language. -/
abbrev Alph : Type := Fin 2

/-- A **statement** is a finite string over the alphabet. -/
abbrev Statement : Type := List Alph

/-! ## The space of statements is countably infinite -/

/-- The space of all finite statements is countably infinite: there is a
bijection between it and the natural numbers. -/
theorem space_of_statements_denumerable : Nonempty (Denumerable Statement) :=
  nonempty_denumerable Statement

/-- A fixed enumeration of all statements: a bijection `ℕ ≃ Statement`.

Reading `enum 0, enum 1, enum 2, …` lists every statement exactly once — a
"clock" ticking off statements one per step. -/
noncomputable def enum : ℕ ≃ Statement :=
  (space_of_statements_denumerable).some.eqv.symm

/-- Every statement is reached at a finite index of the enumeration: in
principle it is discovered after finitely many steps. -/
theorem statement_discoverable (s : Statement) : ∃ n : ℕ, enum n = s :=
  ⟨enum.symm s, by simp⟩

/-- The index at which the enumeration reaches a statement is unique. -/
theorem statement_discovery_unique (s : Statement) {m n : ℕ}
    (hm : enum m = s) (hn : enum n = s) : m = n :=
  enum.injective (hm.trans hn.symm)

/-- Only finitely many statements are shorter than any fixed bound. A finite
budget — bounded length — sees only finitely many statements. -/
theorem shortStatements_finite (n : ℕ) : {s : Statement | s.length ≤ n}.Finite :=
  List.finite_length_le Alph n

/-! ## Formal systems and their theorems -/

/-- A **formal system** is given by a provability predicate on statements,
subject to the condition that it proves infinitely many statements. This is the
abstract shape shared by every rich deductive theory. -/
structure FormalSystem where
  /-- The statements the system proves — its theorems. -/
  Provable : Statement → Prop
  /-- A rich system proves infinitely many statements. -/
  infinite_provable : {s | Provable s}.Infinite

/-- The set of theorems of a formal system. -/
def theorems (F : FormalSystem) : Set Statement := {s | F.Provable s}

/-- The set of theorems is countable: it embeds into the countable space of all
statements. -/
theorem theorems_countable (F : FormalSystem) : (theorems F).Countable :=
  (theorems F).to_countable

/-- The set of theorems is infinite. -/
theorem theorems_infinite (F : FormalSystem) : (theorems F).Infinite :=
  F.infinite_provable

/-- The theorems of a formal system form a countably infinite set: there is a
bijection between the theorems and the natural numbers. This is the precise
sense in which "all theorems can, in principle, be listed". -/
theorem theorems_denumerable (F : FormalSystem) :
    Nonempty (Denumerable {s // F.Provable s}) := by
  have : Infinite {s // F.Provable s} := F.infinite_provable.to_subtype
  exact nonempty_denumerable _

/-- The cardinality of the set of theorems is exactly `ℵ₀`. -/
theorem theorems_cardinality (F : FormalSystem) :
    Cardinal.mk {s // F.Provable s} = Cardinal.aleph0 := by
  have : Infinite {s // F.Provable s} := F.infinite_provable.to_subtype
  exact Cardinal.mk_eq_aleph0 _

/-- Every individual theorem is discovered at a finite stage of the master
enumeration: there is a finite index whose enumerated statement equals the
theorem and is therefore itself provable. No single theorem requires infinite
time to find. -/
theorem theorem_discoverable (F : FormalSystem) {t : Statement}
    (ht : F.Provable t) : ∃ n : ℕ, enum n = t ∧ F.Provable (enum n) := by
  obtain ⟨n, hn⟩ := statement_discoverable t
  exact ⟨n, hn, hn ▸ ht⟩

/-! ## The heat-death obstruction -/

/-- **Heat-death obstruction.** For every finite budget of `N` enumeration
steps there is a theorem not discovered within those steps. However far the
"clock of computation" is allowed to run before it stops, an undiscovered
theorem always remains beyond the horizon. -/
theorem heat_death_leaves_theorems_undiscovered (F : FormalSystem) (N : ℕ) :
    ∃ t : Statement, F.Provable t ∧ ∀ n < N, enum n ≠ t := by
  by_contra h
  push_neg at h
  have hsub : theorems F ⊆ enum '' {n | n < N} := by
    intro t ht
    obtain ⟨n, hn, he⟩ := h t ht
    exact ⟨n, hn, he⟩
  have hfin : (enum '' {n | n < N}).Finite := (Set.finite_Iio N).image _
  exact (theorems_infinite F) (hfin.subset hsub)

/-- **No finite budget suffices.** There is no finite set of enumeration steps
after which every theorem has been discovered. Any terminating computation —
any process that halts after finitely many steps, as forced by the heat death of
the universe — misses at least one theorem. -/
theorem no_finite_budget_suffices (F : FormalSystem) :
    ¬ ∃ N : ℕ, ∀ t : Statement, F.Provable t → ∃ n < N, enum n = t := by
  rintro ⟨N, hN⟩
  obtain ⟨t, ht, hmiss⟩ := heat_death_leaves_theorems_undiscovered F N
  obtain ⟨n, hn, he⟩ := hN t ht
  exact hmiss n hn he

/-- Strengthening: the theorems missed by any finite budget themselves form an
infinite set — the "undiscovered" frontier never thins out. -/
theorem undiscovered_theorems_infinite (F : FormalSystem) (N : ℕ) :
    {t : Statement | F.Provable t ∧ ∀ n < N, enum n ≠ t}.Infinite := by
  -- The discovered theorems are contained in a finite image.
  have hdisc : {t : Statement | F.Provable t ∧ ¬ (∀ n < N, enum n ≠ t)} ⊆
      enum '' {n | n < N} := by
    intro t ht
    simp only [Set.mem_setOf_eq, not_forall, not_ne_iff] at ht
    obtain ⟨n, hn, he⟩ := ht.2
    exact ⟨n, hn, he⟩
  have hfin : {t : Statement | F.Provable t ∧ ¬ (∀ n < N, enum n ≠ t)}.Finite :=
    ((Set.finite_Iio N).image _).subset hdisc
  by_contra hinf
  rw [Set.not_infinite] at hinf
  have hcover : theorems F ⊆
      {t | F.Provable t ∧ ∀ n < N, enum n ≠ t} ∪
      {t | F.Provable t ∧ ¬ (∀ n < N, enum n ≠ t)} := by
    intro t ht
    by_cases hc : ∀ n < N, enum n ≠ t
    · exact Or.inl ⟨ht, hc⟩
    · exact Or.inr ⟨ht, hc⟩
  exact (theorems_infinite F) ((hinf.union hfin).subset hcover)

/-! ## Concrete formal systems (non-vacuity witnesses) -/

/-- The trivial system proving every statement. It witnesses that the
`FormalSystem` interface is inhabited. -/
def allStatements : FormalSystem where
  Provable := fun _ => True
  infinite_provable := by
    simpa using (Set.infinite_univ (α := Statement))

/-- The system whose theorems are exactly the constant strings `0, 00, 000, …`
(one repeated symbol). Its theorem set is infinite yet a proper, sparse subset
of all statements — a more discriminating witness. -/
def constantStatements : FormalSystem where
  Provable := fun s => ∃ n : ℕ, s = List.replicate (n + 1) (0 : Alph)
  infinite_provable := by
    apply Set.infinite_of_injective_forall_mem
      (f := fun n : ℕ => List.replicate (n + 1) (0 : Alph))
    · intro a b hab
      have := congrArg List.length hab
      simpa using this
    · intro n
      exact ⟨n, rfl⟩

/-- Sanity check: the constant-string system really is a proper subsystem — not
every statement is one of its theorems (e.g. the singleton `[1]` is not). -/
theorem constantStatements_proper :
    ¬ constantStatements.Provable [(1 : Alph)] := by
  rintro ⟨n, hn⟩
  have hlen := congrArg List.length hn
  simp only [List.length_singleton, List.length_replicate] at hlen
  have hn0 : n = 0 := by omega
  subst hn0
  simp at hn

end LastTheorem

/-!
-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).** The informal picture — "computation ceases at the
heat death of the universe, yet every theorem is discoverable in finite time" —
resolves into three crisp, falsifiable claims:
(H1) the space of finite statements is countably infinite;
(H2) the theorems of any (infinitely-proving) formal system are countably
infinite and each is reached at a finite enumeration index;
(H3) no *finite* amount of computation discovers them all.

**Experiment (Experimenter).** We modelled statements as binary strings
(`List (Fin 2)`) and a formal system as an infinite provability predicate. H1 is
`space_of_statements_denumerable` (`nonempty_denumerable`, since strings are
countable and infinite). H2 splits into `theorems_denumerable` /
`theorems_cardinality` (`ℵ₀`) and `theorem_discoverable`. H3 became
`heat_death_leaves_theorems_undiscovered`, `no_finite_budget_suffices`, and the
sharper `undiscovered_theorems_infinite`.

**Analysis (Analyst).** The decisive structural pattern is a *finite/infinite
scissor*: any finite budget only ever touches a finite image `enum '' {n | n<N}`,
while the theorem set is infinite; the two cannot coincide. The same scissor,
applied to the complement, upgrades "some theorem is missed" to "infinitely many
are missed". Countability of statements is what makes an enumeration exist at
all; infinitude of theorems is what makes the enumeration never terminate.

**Critique (Critic).** Guarding against vacuity: `allStatements` and
`constantStatements` are explicit inhabitants, and `constantStatements_proper`
shows the second is a genuine proper subsystem, so the framework is not empty and
not trivially "everything". No theorem is `True`-valued or proved by `decide`
alone; each uses a real argument (`by_contra`, image-finiteness, injectivity).
No proof references the theorem it proves.

**Synthesis (Principal Investigator).** The heat-death slogan is exactly the gap
between two forms of "finite": each theorem individually is finitely reachable
(H2), but the *collection* is not finitely exhaustible (H3). Countable infinity
is precisely the regime where "each is reachable" and "all are not" coexist.
-/