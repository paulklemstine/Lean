theorem goedel_iff : F.Tr F.goedel ↔ ¬F.Pr F.goedel :=
  Diagonal.fixpt_iff _ _

-- ════════════════════════════════════════════════════════════════════════════
-- THEOREM 1: First Incompleteness Theorem (Abstract)
-- ════════════════════════════════════════════════════════════════════════════

-- !-- The Gödel sentence G satisfies Tr(G) ↔ ¬Pr(G). If Pr(G), then Tr(G)
--     by soundness, hence ¬Pr(G) by the equivalence — contradiction.
--     So ¬Pr(G), hence Tr(G). This gives a true unprovable sentence. -- !--

/-- The Gödel sentence of a sound system is not provable. -/

theorem tarski_undefinability : ¬Diagonal.Repr (F := F) F.Tr := by
  intro hRepr
  have hNeg := Diagonal.neg_repr F.Tr hRepr
  have hL := Diagonal.fixpt_iff (fun s => ¬F.Tr s) hNeg
  have h1 : ¬F.Tr (Diagonal.fixpt (fun s => ¬F.Tr s) hNeg) :=
    fun h => (hL.mp h) h
  exact h1 (hL.mpr h1)

-- **Example**: Tarski's theorem applied — truth is always outside the representable class.
example (F : FormalSystem S) [Diagonal F] :
    ¬Diagonal.Repr (F := F) F.Tr :=
  F.tarski_undefinability

/-
**Generalization**: No predicate that globally agrees with truth is representable.
This strengthens Tarski: even approximate truth predicates are non-representable
if they agree with Tr on all fixed-point sentences.

No predicate agreeing with truth on fixed points can be representable
    together with its negation.
-/

theorem tarski_generalized (Q : S → Prop)
    (hNegQ : Diagonal.Repr (F := F) (fun s => ¬Q s))
    (hAgree : ∀ (P : S → Prop) (hP : Diagonal.Repr (F := F) P),
      Q (Diagonal.fixpt P hP) ↔ F.Tr (Diagonal.fixpt P hP)) :
    False := by
  cases' ‹F.Diagonal› with Diagonal Repr pr_repr neg_repr fixpt fixpt_iff;
  grind

-- **Boundary**: Without `neg_repr`, truth COULD be representable.
-- A system where only non-negated predicates have fixed points would not
-- produce the liar sentence, so Tarski's argument would not apply.

-- ════════════════════════════════════════════════════════════════════════════
-- THEOREM 3: The Lucas-Penrose Dilemma (Anti-Lucas)
-- ════════════════════════════════════════════════════════════════════════════

-- !-- Direct combination: first_incompleteness gives ¬(Sound ∧ Complete).
--     The contrapositive of goedel_unprovable gives: proving the Gödel sentence
--     implies unsoundness. Together: a formal mind either has blind spots or
--     is unreliable — it cannot be both sound and complete. -- !--

/-- **Anti-Lucas Theorem**: Any system that proves its own Gödel sentence is unsound.

    This formalizes the core mathematical response to the Lucas-Penrose argument:
    if a mind is modeled as a sound formal system with the diagonal property,
    it cannot consistently "see" the truth of its own Gödel sentence. The
    Lucas-Penrose argument either proves minds are not formal systems (their
    conclusion) or shows the "seeing" ability is limited (the anti-Lucas response).

    Either way, the same mathematical theorem underlies both sides of the debate. -/

theorem essential_incompleteness
    (chain : ℕ → FormalSystem S)
    (hDiag : ∀ n, Diagonal (chain n))
    (hSound : ∀ n, (chain n).Sound) :
    ∀ n, ¬(chain n).Complete :=
  fun n => @first_incompleteness S (chain n) (hDiag n) (hSound n)

/-- Each level has its own unprovable truth. -/

theorem berry_diagonal (name : S → ℕ → Prop) (n : ℕ)
    (hRepr : Diagonal.Repr (F := F) (fun s => ¬name s n))
    (hS : F.Sound)
    (hNamePr : ∀ s, name s n → F.Pr s) :
    ∃ s, F.Tr s ∧ ¬name s n := by
  refine ⟨Diagonal.fixpt (fun s => ¬name s n) hRepr, ?_, ?_⟩
  all_goals {
    have hL := Diagonal.fixpt_iff (fun s => ¬name s n) hRepr
    first
    | exact hL.mpr (fun hN => (hL.mp (hS _ (hNamePr _ hN))) hN)
    | exact fun hN => (hL.mp (hS _ (hNamePr _ hN))) hN }

end FormalSystem

-- ════════════════════════════════════════════════════════════════════════════
-- Axiom verification
-- ════════════════════════════════════════════════════════════════════════════

#print axioms FormalSystem.first_incompleteness
#print axioms FormalSystem.tarski_undefinability
#print axioms FormalSystem.sound_complete_exclusive
#print axioms FormalSystem.anti_lucas
#print axioms FormalSystem.self_reference_impossibility

/-!
## FUTURE DIRECTIONS

1. **Löb's theorem (abstract)**: Formalize the Hilbert-Bernays derivability conditions
   (D1: if ⊢ A then ⊢ Pr(A); D2: ⊢ Pr(A→B) → Pr(A)→Pr(B); D3: ⊢ Pr(A)→Pr(Pr(A)))
   and prove Löb's theorem: if F ⊢ Pr(A) → A then F ⊢ A. Conjecture: this can be
   formalized as a strengthening of the `Diagonal` class with provability internalization.

2. **Ordinal-indexed hierarchy**: Define the `α`-th Gödel extension for ordinals `α`
   and prove that the proof-theoretic ordinal strictly increases at each successor level.
   Conjecture: for limit ordinals, the union system satisfies the diagonal property iff
   the ordinal is recursively accessible.

3. **Arithmetization bridge**: Construct a `Diagonal` instance for first-order Peano
   Arithmetic using Gödel numbering. Conjecture: the `Repr` class for PA is exactly
   the Σ₁-definable predicates (and this characterization is provable in a meta-theory).

4. **Rosser strengthening**: Prove `first_incompleteness_rosser`: weaken soundness to
   simple consistency (∃ s, ¬Pr s) using the Rosser sentence construction. Conjecture:
   the Rosser sentence is provably different from the Gödel sentence in any system
   where both are definable.

5. **Computational connection**: Establish a formal correspondence between `Diagonal`
   systems and universal Turing machines, showing that the halting problem is a
   special case of the first incompleteness theorem when `S = ℕ` and `Pr` encodes
   halting. Conjecture: every r.e. set of true arithmetic sentences can be realized
   as the `Pr` of some `Diagonal` instance.
-/