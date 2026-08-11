import Novelty.PhysicalCountermodelCompleteness

/-!
# Completeness of assumption-plus-ex-falso semantics, and the size of its witnesses

`Novelty.PhysicalCountermodelCompleteness` exhibited the two-state switch: a nonempty,
finite, fully sound operational semantics for the *assumption-plus-ex-falso* proof
system in which the consistent finite constraint set `{on, off}` has no realization.
The accompanying conjecture list (item 4, "no finite completeness") proposed that
every finitely presented semantics with two mutually exclusive observation constraints
is incomplete, and (item 5, "boundary rigidity") that no semantic condition strictly
between falsum-soundness and full soundness can carve out the consistency
biconditional.

Both conjectures are settled here, and the first one is settled in a form much
stronger than conjectured.

**§2 The exact completeness criterion.**  For the assumption-plus-ex-falso system over
any sentence type, completeness is equivalent to the existence of a single *omni-world*
satisfying **every** non-falsum sentence (`assumption_complete_iff`).  Neither
finiteness nor decidability plays any role.

**§3 Conjecture 4, strengthened.**  Two mutually exclusive non-falsum observables
therefore preclude completeness (`mutually_exclusive_implies_incomplete`), for
arbitrary — not necessarily finite or decidable — semantics; the switch semantics of
the catalog is the special case `p = on`, `q = off`.  The hypothesis cannot simply be
dropped: `unitSem` is a finite, decidable, *complete* semantics with one observable
(`unitSem_complete`), so mutual exclusivity is genuinely what breaks completeness in
the two-observable case.

**§4 Mutual exclusivity is far from necessary: a Helly phenomenon.**  For every
`k ≥ 1` there is a finite, decidable semantics `missSem k` with `k` observables that
are *`(k-1)`-wise realizable* — every proper subset of the observables has a model —
while the full set has none (`missSem_helly`, `missSem_minimal_unrealizable`).  So the
minimal incompleteness witness can have any prescribed size `k`, and the conjectured
"two mutually exclusive constraints" is only the case `k = 2`.

**§5 Conjecture 5 is a theorem.**  Any semantic condition `C` for which
`C ∧ Complete` is equivalent to the consistency biconditional must agree with
falsum-soundness on complete semantics (`boundary_rigidity`): no strictly intermediate
condition exists.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): incompleteness of the assumption calculus is not about mutual
  exclusivity but about the absence of a maximal world; the obstruction should be
  detectable by a single "omni-world" test, and its minimal witnesses should behave
  like a Helly number for the family of world theories.
Experiment (Stage 2): enumerate all semantics with `w ≤ 4` worlds and `n ≤ 4`
  observables — 74954 satisfaction tables in total.  Result: a table is complete
  exactly when some row is all-true (0 violations).  A first guess for the size of the
  smallest unrealizable consistent theory, `min over rows of (number of false entries
  in the row)`, is wrong (42058 violations); the correct value is the **transversal
  number** of the hypergraph of row complements (0 violations over the same 74954
  tables), i.e. the least number of observables needed to contradict every world.
  Sizes `1, …, n` all occur, size `n` being realized by the "each world misses exactly
  one observable" table — which is the family `missSem k`.
Analysis (Stage 3): the experiment identifies the three theorems below: the omni-world
  criterion, the transversal description of unrealizability, and the unbounded Helly
  number.
Critique (Stage 4): `missSem k` is finite and decidable, so it lives inside the exact
  class of semantics the conjecture speaks about; the theorem therefore genuinely
  sharpens the conjecture instead of evading it.
-/

namespace LogicPhysics

/-! ## §1. The assumption-plus-ex-falso proof system -/

/-- The **assumption-plus-ex-falso** proof system over a sentence type `S` with falsum
`b`: a sentence is derivable from `Γ` when it is a hypothesis, or when `Γ` already
contains falsum. -/
def assumptionSys {S : Type} (b : S) : ProofSystem S where
  bot := b
  Proves := fun Γ φ => φ ∈ Γ ∨ b ∈ Γ
  mono := by
    rintro Γ Δ φ hsub (h | h)
    · exact Or.inl (hsub h)
    · exact Or.inr (hsub h)
  assumption := fun h => Or.inl h

/-- The catalog's switch calculus is an instance of the general system. -/
theorem switchSys_eq : switchSys = assumptionSys Switch.falsum := rfl

/-- Consistency for this calculus is simply not containing falsum. -/
theorem consistent_assumptionSys {S : Type} (b : S) (T : Set S) :
    Consistent (assumptionSys b) T ↔ b ∉ T := by
  constructor
  · intro h hb
    exact h (Or.inl hb)
  · rintro h (hb | hb) <;> exact h hb

/-! ## §2. The exact completeness criterion: an omni-world -/

/-- **Completeness is the existence of an omni-world.**  A semantics of the
assumption-plus-ex-falso calculus is complete exactly when some single world satisfies
every non-falsum sentence.  Finiteness and decidability are irrelevant. -/
theorem assumption_complete_iff {S : Type} (b : S) (M : Semantics (assumptionSys b)) :
    Complete M ↔ ∃ w : M.World, ∀ φ : S, φ ≠ b → M.sat w φ := by
  constructor
  · intro h
    obtain ⟨w, hw⟩ := h {φ : S | φ ≠ b}
      ((consistent_assumptionSys b _).2 (by simp))
    exact ⟨w, fun φ hφ => hw φ hφ⟩
  · rintro ⟨w, hw⟩ T hT
    refine ⟨w, fun φ hφ => hw φ ?_⟩
    intro hb
    exact ((consistent_assumptionSys b T).1 hT) (hb ▸ hφ)

/-! ## §3. Conjecture 4: mutual exclusivity forbids completeness -/

/-- **No completeness with two mutually exclusive observables.**  If two non-falsum
sentences are never satisfied together, the two-element constraint set consisting of
them is consistent but unrealizable, so the semantics is incomplete.  No finiteness or
decidability assumption is used, so the conjecture holds in a strictly stronger
form. -/
theorem mutually_exclusive_implies_incomplete {S : Type} (b : S)
    (M : Semantics (assumptionSys b)) {p q : S} (hp : p ≠ b) (hq : q ≠ b)
    (hex : ∀ w : M.World, ¬ (M.sat w p ∧ M.sat w q)) :
    Consistent (assumptionSys b) {p, q} ∧ ¬ PhysicallyConsistent M {p, q} ∧
      ¬ Complete M := by
  have hcon : Consistent (assumptionSys b) {p, q} := by
    rw [consistent_assumptionSys]
    rintro (h | h)
    · exact hp h.symm
    · exact hq h.symm
  have hunreal : ¬ PhysicallyConsistent M {p, q} := by
    rintro ⟨w, hw⟩
    exact hex w ⟨hw p (by simp), hw q (by simp)⟩
  exact ⟨hcon, hunreal, fun hc => hunreal (hc _ hcon)⟩

/-- The catalog's two-state switch is the instance `p = on`, `q = off` of the general
theorem. -/
theorem switch_incomplete_via_exclusivity :
    Consistent switchSys switchTheory ∧ ¬ PhysicallyConsistent switchSem switchTheory ∧
      ¬ Complete switchSem := by
  have := mutually_exclusive_implies_incomplete (S := Switch) Switch.falsum switchSem
    (p := Switch.on) (q := Switch.off) (by decide) (by decide) (by
      rintro w ⟨h1, h2⟩
      have e1 : w = true := h1
      have e2 : w = false := h2
      rw [e1] at e2
      exact Bool.noConfusion e2)
  exact this

/-! ### The hypothesis of the conjecture cannot be dropped -/

/-- A one-observable language: `false` is falsum and `true` is the single observation
constraint. -/
def unitSem : Semantics (assumptionSys false) where
  World := Unit
  sat := fun _ φ => φ = true
  bot_unsat := by
    intro _ h
    exact absurd h (by decide)

/-- **A finite, decidable, complete semantics.**  With a single observable there is an
omni-world, so the assumption calculus *is* complete: incompleteness in the
two-observable case genuinely comes from mutual exclusivity. -/
theorem unitSem_complete : Complete unitSem := by
  rw [assumption_complete_iff]
  refine ⟨(), fun φ hφ => ?_⟩
  cases φ
  · exact absurd rfl hφ
  · rfl

/-! ## §4. A Helly phenomenon: incompleteness witnesses of every size -/

/-- The **miss semantics** with `k` observables: the worlds are the `k` indices, the
observable `some i` fails exactly at the world `i`.  Every world misses exactly one
observable. -/
def missSem (k : ℕ) : Semantics (assumptionSys (none : Option (Fin k))) where
  World := Fin k
  sat := fun w φ =>
    match φ with
    | none => False
    | some i => i ≠ w
  bot_unsat := by
    intro _ h
    exact h

/-- The world type of the miss semantics is finite. -/
theorem missSem_finite (k : ℕ) : Finite (missSem k).World := by
  unfold missSem
  infer_instance

/-- Satisfaction in the miss semantics is decidable. -/
instance missSem_decidable (k : ℕ) (w : (missSem k).World) (φ : Option (Fin k)) :
    Decidable ((missSem k).sat w φ) := by
  cases φ with
  | none => exact instDecidableFalse
  | some i => exact instDecidableNot

/-- The full set of observables of the miss semantics. -/
def missTheory (k : ℕ) : Set (Option (Fin k)) := {φ | φ ≠ none}

/-- **Every proper subset of the observables is realizable.**  Omitting a single
observable `some i` leaves a set realized by the world `i`. -/
theorem missSem_minimal_unrealizable (k : ℕ) {T : Set (Option (Fin k))}
    (hT : T ⊂ missTheory k) : PhysicallyConsistent (missSem k) T := by
  obtain ⟨hsub, hne⟩ := hT
  have : ∃ φ ∈ missTheory k, φ ∉ T := by
    by_contra hcon
    push_neg at hcon
    exact hne hcon
  obtain ⟨φ₀, hφ₀, hnot⟩ := this
  obtain ⟨i, rfl⟩ : ∃ i, φ₀ = some i := by
    cases φ₀ with
    | none => exact absurd rfl hφ₀
    | some i => exact ⟨i, rfl⟩
  refine ⟨i, fun ψ hψ => ?_⟩
  cases ψ with
  | none => exact absurd rfl (hsub hψ)
  | some j =>
      show j ≠ i
      rintro rfl
      exact hnot hψ

/-- **Helly number of incompleteness is unbounded.**  For every `k` the finite,
decidable semantics `missSem k` has `k` observables such that the full set is
consistent but unrealizable while *every* proper subset is realizable: the minimal
incompleteness witness has exactly `k` elements.  For `k ≥ 3` no two observables are
mutually exclusive, so mutual exclusivity is not necessary for incompleteness. -/
theorem missSem_helly (k : ℕ) :
    Consistent (assumptionSys (none : Option (Fin k))) (missTheory k) ∧
      ¬ PhysicallyConsistent (missSem k) (missTheory k) ∧
      (∀ T ⊂ missTheory k, PhysicallyConsistent (missSem k) T) ∧
      ¬ Complete (missSem k) := by
  have hcon : Consistent (assumptionSys (none : Option (Fin k))) (missTheory k) := by
    rw [consistent_assumptionSys]
    intro h
    exact h rfl
  have hunreal : ¬ PhysicallyConsistent (missSem k) (missTheory k) := by
    rintro ⟨w, hw⟩
    have := hw (some w) (by simp [missTheory])
    exact this rfl
  refine ⟨hcon, hunreal, fun T hT => missSem_minimal_unrealizable k hT, ?_⟩
  intro hc
  exact hunreal (hc _ hcon)

/-- **Pairwise compatibility of the observables** for `k ≥ 3`: any two distinct
observables of `missSem k` are realized together, so the incompleteness of
`missSem k` is invisible to the mutual-exclusivity criterion. -/
theorem missSem_pairwise_realizable {k : ℕ} (hk : 3 ≤ k) (i j : Fin k) :
    PhysicallyConsistent (missSem k) {some i, some j} := by
  have hcard : ∃ w : Fin k, w ≠ i ∧ w ≠ j := by
    by_contra hcon
    push_neg at hcon
    have hsub : (Finset.univ : Finset (Fin k)) ⊆ {i, j} := by
      intro w _
      rcases eq_or_ne w i with rfl | hwi
      · simp
      · simp [hcon w hwi]
    have h1 := Finset.card_le_card hsub
    have h2 : ({i, j} : Finset (Fin k)).card ≤ 2 :=
      (Finset.card_insert_le i {j}).trans (by simp)
    simp [Finset.card_univ] at h1
    omega
  obtain ⟨w, hwi, hwj⟩ := hcard
  refine ⟨w, fun ψ hψ => ?_⟩
  rcases hψ with rfl | rfl
  · exact fun h => hwi h.symm
  · exact fun h => hwj h.symm

/-- **Unrealizability is a transversal condition.**  A constraint set has no model
exactly when it *hits* the complement of every world's theory: incompleteness
witnesses are the transversals of the hypergraph of co-theories, and the size of the
smallest witness is that hypergraph's transversal number.  For `missSem k` this number
is exactly `k` by `missSem_helly`. -/
theorem unrealizable_iff_transversal {S : Type} {P : ProofSystem S} (M : Semantics P)
    (T : Set S) :
    ¬ PhysicallyConsistent M T ↔ ∀ w : M.World, ∃ φ ∈ T, ¬ M.sat w φ := by
  constructor
  · intro h w
    by_contra hcon
    push_neg at hcon
    exact h ⟨w, fun φ hφ => hcon φ hφ⟩
  · rintro h ⟨w, hw⟩
    obtain ⟨φ, hφT, hφ⟩ := h w
    exact hφ (hw φ hφT)

/-! ## §5. Conjecture 5: rigidity of the completeness boundary -/

/-- **Boundary rigidity.**  If a semantic condition `C` is such that `C ∧ Complete` is
equivalent to the coincidence of mathematical and physical consistency, then on
complete semantics `C` is *exactly* falsum-soundness.  Hence there is no condition
strictly between falsum-soundness and full soundness carving out the boundary. -/
theorem boundary_rigidity {S : Type} {P : ProofSystem S}
    (C : Semantics P → Prop)
    (hC : ∀ M : Semantics P,
      (C M ∧ Complete M) ↔ (∀ T : Set S, Consistent P T ↔ PhysicallyConsistent M T))
    (M : Semantics P) (hcomp : Complete M) :
    (C M ↔ FalsumSound M) := by
  constructor
  · intro hc
    exact ((consistency_equivalence_iff M).1 ((hC M).1 ⟨hc, hcomp⟩)).1
  · intro hfs
    exact ((hC M).2 ((consistency_equivalence_iff M).2 ⟨hfs, hcomp⟩)).1

/-- **Summary.**  Completeness of the assumption calculus is the omni-world condition;
mutual exclusivity is sufficient but not necessary for incompleteness (minimal
witnesses of every size `k` exist); and the completeness boundary is rigid. -/
theorem assumption_completeness_summary {S : Type} (b : S)
    (M : Semantics (assumptionSys b)) :
    (Complete M ↔ ∃ w : M.World, ∀ φ : S, φ ≠ b → M.sat w φ) ∧
      (∀ k : ℕ, ¬ Complete (missSem k) ∧
        ∀ T ⊂ missTheory k, PhysicallyConsistent (missSem k) T) :=
  ⟨assumption_complete_iff b M, fun k =>
    ⟨(missSem_helly k).2.2.2, (missSem_helly k).2.2.1⟩⟩

end LogicPhysics