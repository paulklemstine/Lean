import Mathlib

/-!
# Ramanujan Oracles cannot be computable: a counting argument

Many of Ramanujan's identities were stated without proof and only later verified.
This suggests the fantasy of a *Ramanujan oracle*: a device that, presented with a
mathematical statement, returns a verdict — `true`, `false`, or `unknown` — and is
"almost always right".

We make this precise and prove that no such oracle can be *computable*, via a pure
counting (cardinality) argument.  The essential content of the counting argument is:

* there are only **countably many** programs, hence any computable family of oracles
  is indexed by a countable set;
* there are **uncountably many** possible ground truths (arbitrary assignments of
  truth values to the countably many statements).

A single oracle can be perfectly correct for *at most one* ground truth
(`perfect_unique`), so a countable family of oracles can be perfect for only
countably many ground truths.  Since there are uncountably many ground truths, some
ground truth defeats every oracle in the family — and in fact *uncountably many* do
(`missed_uncountable`).

We package the model as follows.

* Statements are Gödel-numbered by `ℕ`.
* A `Truth` is an arbitrary assignment `ℕ → Bool` (the actual truth value of each
  statement).
* An `Oracle` is an arbitrary function `ℕ → Option Bool`: it answers `some true`,
  `some false`, or `none` (= "unknown") on each statement.

Beyond the cardinality results we give two *constructive* strengthenings that make no
appeal to choice on the truth side:

* `family_errs_infinitely_often`: for **any** countable family of oracles there is a
  *single* ground truth on which **every** oracle in the family is wrong at
  infinitely many statements (block diagonalization via `Nat.pair`/`Nat.unpair`).
* `no_oracle_high_accuracy_all_worlds`: for any oracle there is a world in which it is
  correct on *none* of the first `N` statements, for every `N`; hence no oracle can
  guarantee, say, `95 %` accuracy across all possible worlds.

None of these theorems use any nonstandard axioms.

## Main results

* `not_countable_truth` — the space of ground truths is uncountable.
* `perfect_unique` — an oracle is perfect for at most one ground truth.
* `countable_family_incomplete` — a countable family of oracles misses some truth.
* `missed_uncountable` — it in fact misses uncountably many truths.
* `no_computable_oracle_scheme` — the `ℕ`-indexed (program-enumerable) special case.
* `countable_computable_oracles` — there are only countably many `Computable` oracles.
* `exists_truth_no_computable_perfect` — the honest recursion-theoretic corollary: a
  ground truth defeating every `Computable` oracle (using `Nat.Partrec.Code`).
* `family_errs_infinitely_often` — the constructive block-diagonal strengthening.
* `exists_truth_zero_hits` / `no_oracle_high_accuracy_all_worlds` — accuracy version.
-/

namespace RamanujanOracle

open Cardinal

/-- Statements are Gödel-numbered by the naturals. -/
abbrev Stmt : Type := ℕ

/-- A *ground truth* assigns a definite truth value to every statement. -/
abbrev Truth : Type := ℕ → Bool

/-- An *oracle* answers each statement with a definite verdict (`some true`/`some
false`) or with `none`, read as "unknown". -/
abbrev Oracle : Type := ℕ → Option Bool

/-- The oracle `O` is *correct* on statement `n` with respect to the ground truth `T`
if it returns exactly the true verdict.  An `unknown` answer (`none`) is not correct. -/
def Correct (O : Oracle) (T : Truth) (n : ℕ) : Prop := O n = some (T n)

/-- The oracle `O` is *perfect* for the ground truth `T` if it is correct on every
statement. -/
def PerfectOn (O : Oracle) (T : Truth) : Prop := ∀ n, Correct O T n

/-! ### Non-vacuity: perfect oracles do exist (for a fixed world) -/

/-- For every ground truth there is an oracle that is perfect for it, namely the one
that simply echoes the truth.  This shows the definitions are non-vacuous: perfection
for a *fixed* world is easy — the difficulty is uniformity across all worlds. -/
theorem exists_perfect_oracle (T : Truth) : ∃ O : Oracle, PerfectOn O T :=
  ⟨fun n => some (T n), fun _ => rfl⟩

/-! ### The counting argument -/

/-- The space of ground truths is uncountable: it has the cardinality of the
continuum `2 ^ ℵ₀`. -/
theorem not_countable_truth : ¬ Countable Truth := by
  rw [← Cardinal.mk_le_aleph0_iff]
  intro h
  have h2 : (2 : Cardinal) ^ ℵ₀ ≤ ℵ₀ := by
    calc (2 : Cardinal) ^ ℵ₀ = #(ℕ → Bool) := by rw [Cardinal.mk_arrow]; simp
      _ ≤ ℵ₀ := h
  exact absurd (lt_of_lt_of_le (by simpa using Cardinal.cantor ℵ₀) h2) (lt_irrefl _)

/-- An oracle can be perfect for **at most one** ground truth: a perfect oracle
determines the world it lives in. -/
theorem perfect_unique {O : Oracle} {T T' : Truth}
    (h : PerfectOn O T) (h' : PerfectOn O T') : T = T' := by
  funext n
  have := (h n).symm.trans (h' n)
  simpa using this

/-- The set of ground truths for which *some* member of a countable family of oracles
is perfect is itself countable.  This is the heart of the counting argument: perfect
oracles determine their world, so a countable supply of oracles pins down only
countably many worlds. -/
theorem covered_countable {ι : Type*} [Countable ι] (F : ι → Oracle) :
    {T : Truth | ∃ i, PerfectOn (F i) T}.Countable := by
  rw [← Set.countable_coe_iff]
  choose g hg using (fun T : {T : Truth | ∃ i, PerfectOn (F i) T} => T.2)
  have hinj : Function.Injective g := by
    intro a b hab
    exact Subtype.ext (perfect_unique (hg a) (by rw [hab]; exact hg b))
  exact hinj.countable

/-- **Counting argument, uncountable form.**  For any countable family of oracles,
*uncountably many* ground truths defeat the entire family simultaneously (no oracle in
the family is perfect for them). -/
theorem missed_uncountable {ι : Type*} [Countable ι] (F : ι → Oracle) :
    ¬ {T : Truth | ∀ i, ¬ PerfectOn (F i) T}.Countable := by
  intro hmiss
  have hcov := covered_countable F
  have heq :
      {T : Truth | ∀ i, ¬ PerfectOn (F i) T}
        = {T : Truth | ∃ i, PerfectOn (F i) T}ᶜ := by
    ext T; simp
  rw [heq] at hmiss
  have huniv := hcov.union hmiss
  rw [Set.union_compl_self] at huniv
  exact not_countable_truth (Set.countable_univ_iff.mp huniv)

/-- **Counting argument, existence form.**  No countable family of oracles is complete:
there is a ground truth for which no oracle in the family is perfect. -/
theorem countable_family_incomplete {ι : Type*} [Countable ι] (F : ι → Oracle) :
    ∃ T : Truth, ∀ i, ¬ PerfectOn (F i) T := by
  have h := missed_uncountable F
  rcases (Set.eq_empty_or_nonempty {T : Truth | ∀ i, ¬ PerfectOn (F i) T}) with he | hne
  · exact absurd (he ▸ Set.countable_empty) h
  · obtain ⟨T, hT⟩ := hne
    exact ⟨T, hT⟩

/-- **Ramanujan oracles cannot be computable.**  A *computable* oracle scheme is one
whose oracles can be enumerated by programs, i.e. indexed by `ℕ`.  Every such scheme is
incomplete: some ground truth defeats every oracle it produces.  Thus a device that is
*perfectly* correct across all worlds cannot be computable. -/
theorem no_computable_oracle_scheme (F : ℕ → Oracle) :
    ∃ T : Truth, ∀ i, ¬ PerfectOn (F i) T :=
  countable_family_incomplete F

/-- A single oracle cannot be perfect for every ground truth. -/
theorem no_universal_oracle : ¬ ∃ O : Oracle, ∀ T : Truth, PerfectOn O T := by
  rintro ⟨O, hO⟩
  obtain ⟨T, hT⟩ := countable_family_incomplete (fun _ : Unit => O)
  exact hT () (hO T)

/-! ### Constructive strengthening: infinitely many errors -/

/-- The *adversarial* ground truth against an oracle `O`: at each statement it reports
the opposite of `O`'s verdict (and an arbitrary value where `O` is unknown), so that
`O` is never correct. -/
def adv (O : Oracle) (n : ℕ) : Bool :=
  match O n with
  | some b => !b
  | none => true

/-- The adversarial truth makes the oracle wrong at every statement. -/
theorem adv_wrong (O : Oracle) (n : ℕ) : ¬ Correct O (adv O) n := by
  unfold Correct adv
  cases h : O n with
  | none => simp
  | some b => cases b <;> simp

/-- Block-diagonal ground truth against a family: on the block of statements indexed
(via `Nat.unpair`) by `i`, it plays the adversary against the `i`-th oracle. -/
def blockTruth (F : ℕ → Oracle) (n : ℕ) : Bool := adv (F (Nat.unpair n).1) n

/-- **Constructive strengthening.**  For any countable family of oracles there is a
*single* ground truth on which **every** oracle of the family errs at infinitely many
statements.  In particular no oracle in the family is eventually correct on this
world. -/
theorem family_errs_infinitely_often (F : ℕ → Oracle) :
    ∃ T : Truth, ∀ i, {n | ¬ Correct (F i) T n}.Infinite := by
  refine ⟨blockTruth F, fun i => ?_⟩
  have hsub :
      {n : ℕ | (Nat.unpair n).1 = i} ⊆ {n | ¬ Correct (F i) (blockTruth F) n} := by
    intro n hn
    simp only [Set.mem_setOf_eq] at hn ⊢
    have hbt : blockTruth F n = adv (F i) n := by unfold blockTruth; rw [hn]
    rw [Correct, hbt]
    exact adv_wrong (F i) n
  have hinf : Set.Infinite {n : ℕ | (Nat.unpair n).1 = i} := by
    apply Set.infinite_of_injective_forall_mem (f := fun j => Nat.pair i j)
      (fun a b hab => by simpa using hab)
    intro j; simp
  exact hinf.mono hsub

/-! ### Accuracy version: no guaranteed accuracy across all worlds -/

/-- The number of statements among the first `N` on which the oracle `O` is correct in
the world `T`. -/
def hits (O : Oracle) (T : Truth) (N : ℕ) : ℕ :=
  ((Finset.range N).filter (fun n => O n = some (T n))).card

/-- For any oracle there is a world in which it is correct on *none* of the first `N`
statements, for every `N` — its running accuracy is identically `0`. -/
theorem exists_truth_zero_hits (O : Oracle) : ∃ T : Truth, ∀ N, hits O T N = 0 := by
  refine ⟨adv O, fun N => ?_⟩
  unfold hits
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro n _
  have := adv_wrong O n
  unfold Correct at this
  simpa using this

/-- **Accuracy version.**  No oracle can guarantee `95 %` accuracy across all worlds:
there is no oracle that is correct on at least `95 %` (i.e. `19 / 20`) of the first `N`
statements for every world `T` and every `N ≥ 1`.  Indeed the adversarial world drives
its accuracy to `0`.

Here `20 * hits O T N ≥ 19 * N` expresses `hits / N ≥ 19 / 20 = 0.95` without
dividing. -/
theorem no_oracle_high_accuracy_all_worlds :
    ¬ ∃ O : Oracle, ∀ (T : Truth) (N : ℕ), 1 ≤ N → 20 * hits O T N ≥ 19 * N := by
  rintro ⟨O, hO⟩
  obtain ⟨T, hT⟩ := exists_truth_zero_hits O
  have := hO T 1 (le_refl 1)
  rw [hT 1] at this
  omega

/-! ### Genuine recursion-theoretic computability

The results above phrase "computable" as "belonging to a countable family".  We now
connect this to *actual* computability in the sense of Mathlib's `Computable`
(equivalently, `Nat.Partrec.Code`): the type of computable oracles is genuinely
countable, so the counting argument applies verbatim to the honest notion of a
computable device. -/

open Nat.Partrec in
/-- **There are only countably many computable oracles.**  Each computable oracle is
computed by some code in `Nat.Partrec.Code`, and distinct oracles require distinct
codes (a code determines the function it computes, hence the oracle); since the type of
codes is countable, so is the type of computable oracles. -/
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

/-- **Ramanujan oracles cannot be computable — honest form.**  There is a ground truth
that defeats *every* computable oracle: no `Computable` oracle is perfect for it.  This
is the counting argument applied to the genuine notion of computability, upgrading
`no_computable_oracle_scheme` from an abstract `ℕ`-indexed family to Mathlib's
`Computable`. -/
theorem exists_truth_no_computable_perfect :
    ∃ T : Truth, ∀ O : Oracle, Computable O → ¬ PerfectOn O T := by
  haveI := countable_computable_oracles
  obtain ⟨T, hT⟩ :=
    countable_family_incomplete (fun O : {O : Oracle // Computable O} => O.1)
  exact ⟨T, fun O hO => hT ⟨O, hO⟩⟩

end RamanujanOracle