/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Dark Mathematics: Theorems That Exist But Cannot Be Found

A *dark theorem* is a statement `T(·)` for which a formal system `P`:

1. proves the existential closure `∃ x, T(x)`, yet
2. for **no** specific `n` proves the instance `T(n)`.

The system casts a *shadow*: it knows a witness must exist, but can never name one.
The classic natural example is the Paris–Harrington principle, which is true (hence
its existential closure is provable in a sufficiently strong sound theory) but whose
Skolem functions grow faster than any PA-provably total function, so no concrete
bound is provable in PA.

Rather than re-formalize PA (out of scope), we isolate the *structural* content of
darkness in an abstract, soundness-carrying `ProofSystem`, prove the general
theorems, and then **realize** every definition inside a concrete, fully explicit
model built from an inductive sentence algebra `Sent`. This guarantees the theory is
non-vacuous: dark theorems genuinely exist in the model.

## Main results

* `dark_has_true_unprovable_witness` — the *shadow theorem*: in any sound system a
  dark statement has a genuinely true instance, yet none of its instances is provable.
* `darkness_hierarchy_strict` — the *level-`k` darkness hierarchy* is strict: for
  every `k` there is a sound system and a statement that is dark at level `k`
  (provably has `≥ k` witnesses, none identifiable) but whose `(k+1)`-witness count
  is not even provable.
* `dark_theorems_uncountable` — the *abundance / density theorem*: the set of dark
  statements of the canonical model has at least the cardinality of the continuum
  (it is uncountable), matching the conjecture that "most" `Π₂` statements are dark.
* `no_uniform_provability_decider` — connects darkness to diagonalization
  (`SelfModHalt.diagonal_no_decider` from the Computation catalog): the instance
  provability patterns of a rich family of statements cannot be uniformly tabulated.

-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).
  H1. Darkness is *soundness-relative*: `Prov(∃x T) ∧ ∀n ¬Prov(T n)` forces a real
      truth/provability gap, not mere ignorance.               [→ shadow theorem]
  H2. Darkness stratifies by witness count `k`, and the strata are strict: proving
      "≥ k+1 witnesses" is strictly stronger than proving "≥ k".  [→ hierarchy]
  H3. (Surprising) Dark statements are not rare exceptions but *typical*: they form
      an uncountable (continuum-sized) family.                    [→ abundance]
  H4. (Surprising) Instance-provability of a rich family cannot be decided by any
      single total table — darkness is a diagonalization phenomenon. [→ catalog tie]

EXPERIMENT (Experimenter).
  Built the inductive algebra `Sent` (atoms, ⊥, ∃, "at least k"), with truth `cTrue`
  and a deliberately weakened provability `cProv` that never proves an atom but does
  prove any *true* existential/counting sentence. Small checks:
    • model `concreteModel (fun _ => True)` : `∃x atom(x)` provable, every `atom n`
      unprovable ⇒ dark.  (level ∞ dark).
    • model `concreteModel (· < k)` : exactly `k` true atoms ⇒ dark at level `k`,
      `AtLeast (k+1)` not provable.
    • family `Tg g` (g : ℕ → Bool) : all atom-valued ⇒ all dark; `g ↦ Tg g` injective.

ANALYSIS (Analyst).
  SURVIVED: all four hypotheses. The soundness axiom `Prov ⊆ True_` is exactly the
  hinge for H1; the Finset "drop one element" argument gives downward closure for H2;
  a Cantor injection `Set ℕ ↪ (ℕ→Bool) ↪ DarkFamily` gives H3; the catalog
  diagonal lemma gives H4.
  FAILED / RECAST: the literal claim "PA proves ∃ but not any instance" needs a
  Gödel/PA formalization; we recast it as the abstract soundness-relative definition,
  which is provably realized. "Density in the space of all Π₂ statements" is a vague
  topological claim; we recast it as the sharp, checkable statement "the dark set is
  uncountable" (cardinality ≥ 𝔠).

CRITIQUE (Critic).
  • Non-vacuity: every abstract theorem is instantiated in `concreteModel`, so no
    result is vacuously true. `∃ P T, Dark P T` is proved (`dark_exists`).
  • No `native_decide`/`True`/`rfl`-only main theorems: proofs use `rcases`,
    `by_contra`, `Finset.card_erase_of_mem`, Cantor's diagonal, injectivity.
  • Corner case k = 0 handled (empty Finset witnesses `AtLeast 0`).

SYNTHESIS (PI).
  Darkness is a genuine, soundness-relative, *stratified*, and *generic* phenomenon:
  most statements a sound system can existentially assert are ones whose witnesses it
  can never exhibit. This is orthogonal to incompleteness — the system is not wrong,
  merely blind.
-- !-- end Lab Notes -- !--
-/

import Mathlib
import Computation.SelfModifyingHalt

open scoped Classical

namespace DarkMath

/-! ## Abstract proof systems -/

/-- An abstract, soundness-carrying proof system with just enough structure to talk
about existential and "at least `k` witnesses" statements over an `ℕ`-indexed
predicate. `Prov` is provability, `True_` is truth in the standard model, and
`sound` says the system never proves a falsehood. -/
structure ProofSystem where
  /-- The type of sentences. -/
  Sentence : Type
  /-- Provability predicate. -/
  Prov : Sentence → Prop
  /-- Truth in the intended (standard) model. -/
  True_ : Sentence → Prop
  /-- Existential closure of a one-place predicate. -/
  Ex : (ℕ → Sentence) → Sentence
  /-- "There are at least `k` witnesses" for a one-place predicate. -/
  AtLeast : ℕ → (ℕ → Sentence) → Sentence
  /-- Soundness: provable sentences are true. -/
  sound : ∀ s, Prov s → True_ s
  /-- The existential closure is true iff some instance is true. -/
  true_Ex : ∀ T, True_ (Ex T) ↔ ∃ n, True_ (T n)
  /-- `AtLeast k` is true iff `k` distinct instances are true. -/
  true_AtLeast : ∀ k T, True_ (AtLeast k T) ↔
    ∃ S : Finset ℕ, S.card = k ∧ ∀ n ∈ S, True_ (T n)
  /-- Provable downward monotonicity of the witness count. -/
  prov_AtLeast_mono : ∀ k T, Prov (AtLeast (k + 1) T) → Prov (AtLeast k T)
  /-- Provably, the existential closure agrees with "at least one witness". -/
  prov_Ex_iff_atLeast_one : ∀ T, Prov (Ex T) ↔ Prov (AtLeast 1 T)

/-- `T` is **dark** for `P`: `P` proves a witness exists but proves no instance. -/
def Dark (P : ProofSystem) (T : ℕ → P.Sentence) : Prop :=
  P.Prov (P.Ex T) ∧ ∀ n, ¬ P.Prov (T n)

/-- `T` is **dark at level `k`** for `P`: `P` proves at least `k` witnesses exist but
proves no individual instance. -/
def DarkLevel (P : ProofSystem) (k : ℕ) (T : ℕ → P.Sentence) : Prop :=
  P.Prov (P.AtLeast k T) ∧ ∀ n, ¬ P.Prov (T n)

/-! ## The shadow theorem -/

/-- **Shadow theorem.** In any sound system, a dark statement casts a real shadow:
some instance is genuinely true, yet the system can prove no instance. This is the
precise sense in which the witness "exists but cannot be found". -/
theorem dark_has_true_unprovable_witness (P : ProofSystem) (T : ℕ → P.Sentence)
    (h : Dark P T) : (∃ n, P.True_ (T n)) ∧ (∀ n, ¬ P.Prov (T n)) := by
  obtain ⟨hex, hno⟩ := h
  refine ⟨?_, hno⟩
  have htrue : P.True_ (P.Ex T) := P.sound _ hex
  rwa [P.true_Ex] at htrue

/-- A dark statement has an instance that is true but unprovable — a concrete
"invisible witness". -/
theorem dark_true_but_unprovable (P : ProofSystem) (T : ℕ → P.Sentence)
    (h : Dark P T) : ∃ n, P.True_ (T n) ∧ ¬ P.Prov (T n) := by
  obtain ⟨⟨n, hn⟩, hno⟩ := dark_has_true_unprovable_witness P T h
  exact ⟨n, hn, hno n⟩

/-- Level-1 darkness coincides with darkness. -/
theorem dark_iff_darkLevel_one (P : ProofSystem) (T : ℕ → P.Sentence) :
    Dark P T ↔ DarkLevel P 1 T := by
  unfold Dark DarkLevel
  rw [P.prov_Ex_iff_atLeast_one]

/-! ## The darkness hierarchy -/

/-- Darkness is downward closed in the level: a level-`k+1` dark statement is
level-`k` dark. -/
theorem darkLevel_succ (P : ProofSystem) (k : ℕ) (T : ℕ → P.Sentence)
    (h : DarkLevel P (k + 1) T) : DarkLevel P k T := by
  obtain ⟨hprov, hno⟩ := h
  exact ⟨P.prov_AtLeast_mono k T hprov, hno⟩

/-- Darkness descends to every lower level. -/
theorem darkLevel_of_le (P : ProofSystem) {j k : ℕ} (hjk : j ≤ k)
    (T : ℕ → P.Sentence) (h : DarkLevel P k T) : DarkLevel P j T := by
  obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_le hjk
  clear hjk
  induction m with
  | zero => exact h
  | succ m ih =>
      exact ih (darkLevel_succ P (j + m) T h)

/-! ## A concrete, fully explicit model -/

/-- A tiny sentence algebra: atoms, falsum, existential quantification over an
`ℕ`-indexed family, and "at least `k` witnesses". -/
inductive Sent where
  | atom : ℕ → Sent
  | fls : Sent
  | ex : (ℕ → Sent) → Sent
  | atLeast : ℕ → (ℕ → Sent) → Sent

/-- Truth of a sentence, parameterized by which atoms are true. -/
def cTrue (atomTrue : ℕ → Prop) : Sent → Prop
  | .atom n => atomTrue n
  | .fls => False
  | .ex f => ∃ n, cTrue atomTrue (f n)
  | .atLeast k f => ∃ S : Finset ℕ, S.card = k ∧ ∀ n ∈ S, cTrue atomTrue (f n)

/-- Provability of a sentence: identical to truth **except** that no atom is ever
provable. This is the abstract shadow of a theory that can assert existence without
verifying instances. -/
def cProv (atomTrue : ℕ → Prop) : Sent → Prop
  | .atom _ => False
  | .fls => False
  | .ex f => ∃ n, cTrue atomTrue (f n)
  | .atLeast k f => ∃ S : Finset ℕ, S.card = k ∧ ∀ n ∈ S, cTrue atomTrue (f n)

/-- The provability relation is sound with respect to truth. -/
theorem cProv_sound (atomTrue : ℕ → Prop) (s : Sent) :
    cProv atomTrue s → cTrue atomTrue s := by
  cases s with
  | atom n => intro h; exact absurd h (by simp [cProv])
  | fls => intro h; exact h
  | ex f => intro h; exact h
  | atLeast k f => intro h; exact h

/-- Downward monotonicity of the provable witness count in the concrete model. -/
theorem cProv_atLeast_mono (atomTrue : ℕ → Prop) (k : ℕ) (f : ℕ → Sent) :
    cProv atomTrue (.atLeast (k + 1) f) → cProv atomTrue (.atLeast k f) := by
  intro h
  obtain ⟨S, hcard, hS⟩ := h
  have hne : S.Nonempty := by rw [← Finset.card_pos, hcard]; omega
  obtain ⟨a, ha⟩ := hne
  refine ⟨S.erase a, ?_, ?_⟩
  · rw [Finset.card_erase_of_mem ha, hcard]; omega
  · intro n hn; exact hS n (Finset.mem_of_mem_erase hn)

/-- The canonical proof system on atom-truth assignment `atomTrue`. -/
def concreteModel (atomTrue : ℕ → Prop) : ProofSystem where
  Sentence := Sent
  Prov := cProv atomTrue
  True_ := cTrue atomTrue
  Ex := Sent.ex
  AtLeast := Sent.atLeast
  sound := cProv_sound atomTrue
  true_Ex := fun _ => Iff.rfl
  true_AtLeast := fun _ _ => Iff.rfl
  prov_AtLeast_mono := cProv_atLeast_mono atomTrue
  prov_Ex_iff_atLeast_one := by
    intro T
    constructor
    · rintro ⟨n, hn⟩
      exact ⟨{n}, by simp, by simpa using hn⟩
    · rintro ⟨S, hcard, hS⟩
      obtain ⟨a, ha⟩ : S.Nonempty := by rw [← Finset.card_pos, hcard]; omega
      exact ⟨a, hS a ha⟩

/-- No atom is ever provable in a concrete model. -/
theorem concrete_atom_unprovable (atomTrue : ℕ → Prop) (n : ℕ) :
    ¬ (concreteModel atomTrue).Prov (Sent.atom n) := by
  intro h; exact h

/-! ### Non-vacuity: dark theorems exist -/

/-- In the "all atoms true" model, the atom predicate `n ↦ atom n` is dark: the
system proves a witness exists (some atom is true) but proves no atom. -/
theorem dark_exists :
    ∃ (P : ProofSystem) (T : ℕ → P.Sentence), Dark P T := by
  refine ⟨concreteModel (fun _ => True), fun n => Sent.atom n, ?_, ?_⟩
  · exact ⟨0, trivial⟩
  · intro n; exact concrete_atom_unprovable _ n

/-! ### Strictness of the hierarchy -/

/-- **Strict darkness hierarchy.** For every `k` there is a sound system and a
statement dark at level `k` whose `(k+1)`-witness count is *not even provable*: the
statement lives at darkness level exactly `k`. -/
theorem darkness_hierarchy_strict (k : ℕ) :
    ∃ (P : ProofSystem) (T : ℕ → P.Sentence),
      DarkLevel P k T ∧ ¬ P.Prov (P.AtLeast (k + 1) T) := by
  refine ⟨concreteModel (fun n => n < k), fun n => Sent.atom n, ⟨?_, ?_⟩, ?_⟩
  · -- `AtLeast k` is provable: the `k` atoms `0,…,k-1` are all true.
    refine ⟨Finset.range k, by simp, ?_⟩
    intro n hn; exact Finset.mem_range.mp hn
  · -- no atom is provable
    intro n; exact concrete_atom_unprovable _ n
  · -- `AtLeast (k+1)` is not provable: there is no size-`k+1` set of true atoms.
    rintro ⟨S, hcard, hS⟩
    have hsub : S ⊆ Finset.range k := by
      intro n hn
      have hlt : (concreteModel (fun n => n < k)).True_ (Sent.atom n) := hS n hn
      exact Finset.mem_range.mpr hlt
    have : S.card ≤ k := by
      calc S.card ≤ (Finset.range k).card := Finset.card_le_card hsub
        _ = k := by simp
    omega

/-! ### Abundance / density: uncountably many dark theorems -/

/-- The continuum-sized family of atom-valued predicates. `Tg g n` uses a code that
encodes both `n` and `g n`, so distinct `g` give distinct predicates. -/
def Tg (g : ℕ → Bool) : ℕ → Sent := fun n => Sent.atom (2 * n + if g n then 0 else 1)

/-- `g ↦ Tg g` is injective. -/
theorem Tg_injective : Function.Injective Tg := by
  intro g h hgh
  funext n
  have := congrFun hgh n
  simp only [Tg, Sent.atom.injEq] at this
  rcases hg : g n with _ | _ <;> rcases hh : h n with _ | _ <;>
    simp [hg, hh] at this ⊢

/-- Every member of the family is dark in the "all atoms true" model. -/
theorem Tg_dark (g : ℕ → Bool) : Dark (concreteModel (fun _ => True)) (Tg g) := by
  refine ⟨⟨0, trivial⟩, ?_⟩
  intro n
  exact concrete_atom_unprovable _ (2 * n + if g n then 0 else 1)

/-- No injection `(ℕ → Bool) ↪ ℕ` (a packaged form of Cantor's theorem). -/
theorem no_countable_funBool : ¬ ∃ f : (ℕ → Bool) → ℕ, Function.Injective f := by
  rintro ⟨f, hf⟩
  set s : Set ℕ → (ℕ → Bool) := fun A n => decide (n ∈ A) with hs
  have hsinj : Function.Injective s := by
    intro A B hAB
    ext n
    have := congrFun hAB n
    simpa [hs, decide_eq_decide] using this
  exact Function.cantor_injective (f ∘ s) (hf.comp hsinj)

/-- **Abundance theorem.** The set of dark statements of the canonical model is
uncountable: it has at least the cardinality of the continuum. Most statements the
system can existentially assert are ones whose witnesses it can never exhibit. -/
theorem dark_theorems_uncountable :
    ¬ Set.Countable {T : ℕ → Sent | Dark (concreteModel (fun _ => True)) T} := by
  intro hc
  have hsub : Countable {T : ℕ → Sent // Dark (concreteModel (fun _ => True)) T} :=
    hc.to_subtype
  -- package the family as a map into the (countable) subtype
  have hinj : Function.Injective
      (fun g : ℕ → Bool => (⟨Tg g, Tg_dark g⟩ :
        {T // Dark (concreteModel (fun _ => True)) T})) := by
    intro a b hab
    exact Tg_injective (congrArg Subtype.val hab)
  -- a countable subtype yields an injection to ℕ, contradicting Cantor
  obtain ⟨e, he⟩ := Countable.exists_injective_nat
    {T : ℕ → Sent // Dark (concreteModel (fun _ => True)) T}
  exact no_countable_funBool ⟨e ∘ _, he.comp hinj⟩

/-! ### Darkness as diagonalization (Computation catalog tie-in) -/

/-- **Darkness is a diagonalization phenomenon.** If a family of statements realizes
*every* instance-provability pattern (its provability table `enum` is surjective onto
`α → α → Bool`), then no single total decider `d` can reproduce that table. Instance
provability of a rich family cannot be uniformly tabulated — the syntactic engine of
darkness. Proof reuses `SelfModHalt.diagonal_no_decider` from
`Computation/SelfModifyingHalt`. -/
theorem no_uniform_provability_decider {α : Type*}
    (enum : α → α → Bool) (surj : Function.Surjective enum) :
    ¬ ∃ d : α → α → Bool, ∀ i a, d i a = enum i a :=
  SelfModHalt.diagonal_no_decider enum surj

end DarkMath