import Mathlib
import Logic.ProofComplexity.Resolution
import Logic.ProofComplexity.Pigeonhole

/-!
# Proof Complexity IV: Weakening, Restrictions, and Hardness Preservation

This file develops the two structural engines that drive *resolution lower bounds*:

* **Monotonicity / weakening.** A derivation in `F` is still a derivation after
  adding more clauses (`derivable_mono`, `refutation_mono`); and the empty CNF
  proves nothing (`not_derivable_nil`).  These are the closure properties that
  make resolution a well-behaved proof system.

* **Restrictions.** A *restriction* `ρ : V → Option Bool` fixes some variables and
  leaves the rest free.  Restrictions are the central tool of proof complexity:
  Haken-style lower bounds proceed by hitting a refutation with a random
  restriction and arguing the restricted refutation is still large.  We formalize
  the syntactic restriction of clauses and CNFs and prove the key semantic
  invariant `restrict_sat_iff`: a restricted formula `F⌈ρ` is satisfied by `a`
  **iff** `F` is satisfied by the extended assignment `subst ρ a`.  The immediate
  corollary `restrict_preserves_unsat` is *hardness preservation*: restricting an
  unsatisfiable formula keeps it unsatisfiable, applied to the pigeonhole
  principle in `PHP_restrict_unsat`.

## Main results

* `derivable_mono`, `refutation_mono` : weakening of resolution derivations.
* `not_derivable_nil`                 : the empty CNF derives no clause.
* `restrict_sat_iff`                  : the semantic invariant of restrictions.
* `restrict_preserves_unsat`          : restrictions preserve unsatisfiability.
* `PHP_restrict_unsat`                : every restriction of `PHP n` is unsatisfiable.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Resolution should be monotone in its clause set, and a
*restriction* of an unsatisfiable formula should remain unsatisfiable — this is
the abstract reason random restrictions are a sound lower-bound technique.

Experiment (Experimenter): Modelled a restriction as `ρ : V → Option Bool`
(`none` = free, `some b` = fixed to `b`).  A clause is *killed* when one of its
literals is fixed to `true`; otherwise it survives, keeping exactly its free
literals.  `CNF.restrict` filters the killed clauses and trims the rest.  The
extension operator `subst ρ a v = (ρ v).getD (a v)` glues a restriction to a free
assignment.  The crux lemma `restrict_sat_iff` is proved by a two-way literal-level
case split on whether `ρ` fixes the variable.

Analysis (Analyst): The delicate point is that a literal fixed to `false` is *not*
killed but *deleted*; the proof has to show such a literal can never be the witness
that satisfies the original clause under `subst`, because `subst` agrees with the
fixed value there.  Once this is isolated, both directions of the iff close
cleanly. `restrict_preserves_unsat` then follows with no extra hypotheses, and the
pigeonhole instance is a one-liner over `PHP_unsat`.

Critique (Critic): The results are not vacuous — `restrict_sat_iff` is a genuine
biconditional with content in both directions, `not_derivable_nil` rules out a
spurious derivation, and `PHP_restrict_unsat` is a `¬ Satisfiable` statement about
a non-trivial restricted formula.  What is *not* claimed is the quantitative
shrinkage of refutation size under random restrictions (the analytic heart of
Haken's theorem); that is deferred to `FUTURE_DIRECTIONS.md`.

Synthesis (PI): Together with the soundness pipeline of Resolution.lean, these
give the algebra of resolution lower bounds: weaken, restrict, preserve hardness.
The pigeonhole principle is hard *robustly* — it stays unsatisfiable under every
partial assignment.
-/

namespace ProofComplexity

variable {V : Type*}

/-! ## Weakening / monotonicity -/

section Weakening
variable [DecidableEq V]

/-- **Weakening.** A derivation in `F` is a derivation in any superset `G ⊇ F`. -/
theorem derivable_mono {F G : CNF V} (hFG : ∀ C ∈ F, C ∈ G) :
    ∀ {C : Clause V}, Derivable F C → Derivable G C := by
  intro C h
  induction h with
  | base hC => exact Derivable.base (hFG _ hC)
  | res p _ _ ih1 ih2 => exact Derivable.res p ih1 ih2

/-- **Weakening of refutations.** A refutation of `F` is a refutation of any
superset of `F`. -/
theorem refutation_mono {F G : CNF V} (hFG : ∀ C ∈ F, C ∈ G)
    (h : Refutation F) : Refutation G :=
  derivable_mono hFG h

/-- The empty CNF derives no clause whatsoever: there is nothing to start from. -/
theorem not_derivable_nil {C : Clause V} : ¬ Derivable ([] : CNF V) C := by
  intro h
  induction h with
  | base hC => exact List.not_mem_nil hC
  | res p _ _ ih1 _ => exact ih1

end Weakening

/-! ## Restrictions -/

/-- Extend a partial restriction `ρ` by a total assignment `a` on the free
variables: fixed variables take their fixed value, free variables take `a`. -/
def subst (ρ : V → Option Bool) (a : V → Bool) : V → Bool :=
  fun v => (ρ v).getD (a v)

/-- A clause is *killed* by `ρ` when one of its literals is fixed to `true`,
i.e. the restriction already satisfies it. -/
def Clause.killed (ρ : V → Option Bool) (C : Clause V) : Bool :=
  C.any (fun l => ρ l.v == some l.pos)

/-- The restriction of a clause keeps exactly the literals on *free* variables.
(Literals fixed to `false` are deleted; only meaningful when `C` is not killed.) -/
def Clause.restrict (ρ : V → Option Bool) (C : Clause V) : Clause V :=
  C.filter (fun l => (ρ l.v).isNone)

/-- The restriction of a CNF: drop killed clauses, trim the survivors. -/
def CNF.restrict (ρ : V → Option Bool) (F : CNF V) : CNF V :=
  (F.filter (fun C => ! Clause.killed ρ C)).map (Clause.restrict ρ)

/-- **The semantic invariant of restrictions.** An assignment `a` satisfies the
restricted formula `F.restrict ρ` exactly when the glued assignment `subst ρ a`
satisfies the original `F`. -/
theorem restrict_sat_iff (ρ : V → Option Bool) (F : CNF V) (a : V → Bool) :
    (F.restrict ρ).sat a ↔ F.sat (subst ρ a) := by
  constructor <;> intro hC;
  · intro C hC';
    by_cases h : Clause.killed ρ C <;> simp_all +decide [ CNF.restrict, Clause.killed ];
    · obtain ⟨ l, hl₁, hl₂ ⟩ := h; use l; simp_all +decide ;
      unfold Lit.eval subst; aesop;
    · obtain ⟨ l, hl, hl' ⟩ := hC ( Clause.restrict ρ C ) ( List.mem_map.mpr ⟨ C, List.mem_filter.mpr ⟨ hC', by simpa [ List.any_eq_false ] using h ⟩, rfl ⟩ );
      refine' ⟨ l, _, _ ⟩ <;> simp_all +decide [ Clause.restrict, Lit.eval, subst ];
  · intro C' hC';
    obtain ⟨C, hC, hC'⟩ : ∃ C ∈ F, Clause.restrict ρ C = C' ∧ ! Clause.killed ρ C := by
      unfold CNF.restrict at hC'; aesop;
    obtain ⟨ l, hl, hl' ⟩ := ‹CNF.sat ( subst ρ a ) F› C hC;
    cases h : ρ l.v <;> simp_all +decide [ Clause.killed, Clause.restrict, subst, Lit.eval ];
    exact ⟨ l, by rw [ ← hC'.1 ] ; exact List.mem_filter.mpr ⟨ hl, by simp +decide [ h ] ⟩, by simp +decide [ hl', Lit.eval ] ⟩

/-- **Hardness preservation.** If `F` is unsatisfiable, so is every restriction of
`F`.  This is the soundness of the random-restriction method. -/
theorem restrict_preserves_unsat (ρ : V → Option Bool) {F : CNF V}
    (h : ¬ F.Satisfiable) : ¬ (F.restrict ρ).Satisfiable := by
  rintro ⟨a, ha⟩
  exact h ⟨subst ρ a, (restrict_sat_iff ρ F a).mp ha⟩

/-- **Every restriction of the pigeonhole principle is unsatisfiable.** No partial
assignment of pigeon–hole variables can rescue the formula. -/
theorem PHP_restrict_unsat (n : ℕ) (ρ : PVar n → Option Bool) :
    ¬ ((PHP n).restrict ρ).Satisfiable :=
  restrict_preserves_unsat ρ (PHP_unsat n)

end ProofComplexity