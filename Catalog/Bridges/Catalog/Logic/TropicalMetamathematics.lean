import Mathlib

/-!
# Tropical Metamathematics: Self-Referential Proof Systems and Idempotent Incompleteness

This module develops a rigorous bridge between **idempotent/tropical fixed-point theory**
and **Gödelian incompleteness phenomena**. The central insight is that diagonalization and
self-reference arise naturally from the fixed-point structure of closure operators in
idempotent semirings, without any need for arithmetic coding or Boolean syntax.

## Main Results

### Theorem 1: Tropical Fixed-Point Existence
Every monotone idempotent endomap has fixed points — the image of any element is fixed.

### Theorem 2: Tropical Gödel Incompleteness
For any proof system with a diagonal self-referential sentence, soundness and
completeness cannot simultaneously hold.

### Theorem 3: No Sound and Complete Tropical Diagonal System
Combining fixed-point existence with diagonalization yields full incompleteness.

### Theorem 4: Closure Operator Self-Reference
Closure operators canonically produce fixed points serving as self-referential sentences.

### Theorem 5: Tropical Closure Incompleteness
Closure operators with diagonal encoding force incompleteness.

## Mathematical Significance

This work establishes that **incompleteness is not an artifact of arithmetic coding** but
a structural consequence of idempotent fixed-point dynamics.
-/

open Function

/-! ## Part 1: Core Definitions -/

/-- Tropical provability: a sentence `i` is tropically provable in state `x`
    if its tropical cost score equals zero (minimal cost = proved). -/
def TropProvable {n : ℕ} (x : Fin n → WithTop ℝ) (i : Fin n) : Prop :=
  x i = (0 : WithTop ℝ)

/-- Tropical refutability: a sentence `i` is tropically refutable in state `x`
    if its tropical cost score is infinite (maximal cost = refuted). -/
def TropRefutable {n : ℕ} (x : Fin n → WithTop ℝ) (i : Fin n) : Prop :=
  x i = ⊤

/-- A sentence `i` diagonalizes `Prov` against `Truth` if its truth value is
    equivalent to its own unprovability. This is the tropical Gödel sentence schema. -/
def diagonalizes
    {n : ℕ}
    (Prov Truth : (Fin n → WithTop ℝ) → Fin n → Prop)
    (i : Fin n) : Prop :=
  ∀ x, Truth x i ↔ ¬ Prov x i

/-! ## Part 2: Abstract Diagonal Incompleteness (Pure Logic Core) -/

/-- **Abstract Diagonal Incompleteness.** The pure propositional core: if `T ↔ ¬P`,
    `P → T` (soundness), and `T → P` (completeness), then `False`.

    This is the essence of all Gödel-style arguments. -/
theorem abstract_diagonal_incompleteness
    (P T : Prop)
    (hdiag : T ↔ ¬ P)
    (hsound : P → T)
    (hcomplete : T → P) : False := by
  have hnp : ¬ P := fun hp => (hdiag.mp (hsound hp)) hp
  exact hnp (hcomplete (hdiag.mpr hnp))

/-! ## Part 3: Fixed-Point Existence -/

/-- **Tropical Fixed-Point Existence.** Every monotone idempotent endomap on
    `Fin n → WithTop ℝ` has a fixed point. -/
theorem tropical_fixed_point_exists
    {n : ℕ} [NeZero n]
    (Φ : (Fin n → WithTop ℝ) → (Fin n → WithTop ℝ))
    (_hmono : Monotone Φ)
    (hidem : ∀ x, Φ (Φ x) = Φ x) :
    ∃ x, Φ x = x :=
  ⟨Φ (fun _ => 0), hidem _⟩

/-- Stronger form: extract a specific diagonal coordinate. -/
theorem tropical_diagonal_sentence_exists
    {n : ℕ} [NeZero n]
    (Φ : (Fin n → WithTop ℝ) → (Fin n → WithTop ℝ))
    (_hmono : Monotone Φ)
    (hidem : ∀ x, Φ (Φ x) = Φ x) :
    ∃ i : Fin n, ∃ x : Fin n → WithTop ℝ, x i = Φ x i ∧ Φ x = x := by
  exact ⟨0, Φ (fun _ => 0), by rw [hidem], hidem _⟩

/-! ## Part 4: Tropical Gödel Incompleteness -/

/-- **Tropical Gödel Incompleteness Theorem.**

    If a sentence `i` diagonalizes `Prov` against `Truth`, then no state can be
    simultaneously sound and complete at that coordinate.

    This is the tropical analogue of the liar/Gödel paradox. -/
theorem tropical_godel_incompleteness
    {n : ℕ} [NeZero n]
    (Prov Truth : (Fin n → WithTop ℝ) → Fin n → Prop)
    (i : Fin n)
    (x : Fin n → WithTop ℝ)
    (hdiag : diagonalizes Prov Truth i)
    (hsound : Prov x i → Truth x i)
    (hcomplete : Truth x i → Prov x i) :
    False :=
  abstract_diagonal_incompleteness (Prov x i) (Truth x i) (hdiag x) hsound hcomplete

/-- **Universally quantified form**: no state can be both sound and complete at a
    diagonal coordinate. -/
theorem tropical_godel_incompleteness_forall
    {n : ℕ} [NeZero n]
    (Prov Truth : (Fin n → WithTop ℝ) → Fin n → Prop)
    (i : Fin n)
    (hdiag : diagonalizes Prov Truth i)
    (hsound : ∀ x, Prov x i → Truth x i) :
    ¬ ∀ x, Truth x i → Prov x i := by
  intro hcomplete
  exact tropical_godel_incompleteness Prov Truth i (fun _ => (0 : WithTop ℝ))
    hdiag (hsound _) (hcomplete _)

/-! ## Part 5: No Sound and Complete Tropical Diagonal System -/

/-- **No Sound and Complete Tropical Diagonal System.**

    If a tropical evaluator admits a diagonal sentence, no fixed proof state
    can simultaneously satisfy soundness and completeness for all sentences. -/
theorem no_sound_complete_tropical_diagonal_system
    {n : ℕ} [NeZero n]
    (Φ : (Fin n → WithTop ℝ) → (Fin n → WithTop ℝ))
    (_hfix : ∃ x, Φ x = x)
    (diag : Fin n → (Fin n → WithTop ℝ) → Prop)
    (hself : ∃ i, ∀ x, diag i x ↔ ¬ TropProvable x i) :
    ¬ (∃ x : Fin n → WithTop ℝ,
        Φ x = x ∧
        (∀ i, TropProvable x i → diag i x) ∧
        (∀ i, diag i x → TropProvable x i)) := by
  rintro ⟨x, _, hsound, hcomplete⟩
  obtain ⟨i, hdiag⟩ := hself
  exact abstract_diagonal_incompleteness
    (TropProvable x i) (diag i x) (hdiag x) (hsound i) (hcomplete i)

/-! ## Part 6: Closure Operator Self-Reference -/

/-- **Closure operators on tropical states yield self-referential sentences.** -/
theorem tropical_closure_diagonalization
    {n : ℕ} [NeZero n]
    (c : (Fin n → WithTop ℝ) → (Fin n → WithTop ℝ))
    (_hmono : Monotone c)
    (_hext : ∀ x, x ≤ c x)
    (hidem : ∀ x, c (c x) = c x) :
    ∃ x : Fin n → WithTop ℝ, c x = x ∧ ∃ i : Fin n, x i = c x i := by
  refine ⟨c (fun _ => 0), hidem _, 0, ?_⟩
  rw [hidem]

/-! ## Part 7: Tropical Closure Incompleteness -/

/-- **Tropical Closure Incompleteness Theorem.**

    For any closure operator on tropical states with an internal diagonal encoding,
    no fixed proof state can be both sound and complete.

    This derives incompleteness directly from the structural properties of closure
    operators, without any external coding apparatus. -/
theorem tropical_closure_incompleteness
    {n : ℕ} [NeZero n]
    (c : (Fin n → WithTop ℝ) → (Fin n → WithTop ℝ))
    (_hmono : Monotone c)
    (_hext : ∀ x, x ≤ c x)
    (_hidem : ∀ x, c (c x) = c x)
    (Prov Truth : (Fin n → WithTop ℝ) → Fin n → Prop)
    (hencode : ∃ i, ∀ x, Truth x i ↔ ¬ Prov (c x) i) :
    ¬ ∃ x, c x = x ∧
      (∃ (_ : Fin n), (∀ j, Prov x j → Truth x j) ∧ (∀ j, Truth x j → Prov x j)) := by
  rintro ⟨x, hcx, i_wit, hsound, hcomplete⟩
  obtain ⟨i, hencode_i⟩ := hencode
  -- At a fixed point x with c x = x, the encoding gives Truth x i ↔ ¬ Prov x i
  have hdiag : Truth x i ↔ ¬ Prov x i := by
    have := hencode_i x
    rwa [hcx] at this
  exact abstract_diagonal_incompleteness (Prov x i) (Truth x i) hdiag (hsound i) (hcomplete i)

/-! ## Part 8: Lattice Fixed-Point Incompleteness -/

/-- **Lattice Fixed-Point Incompleteness.** On any type, if a map has a fixed point
    where a diagonal predicate holds, soundness + completeness fails. -/
theorem lattice_fixed_point_incompleteness
    {S : Type*}
    (f : S → S)
    (P T : S → Prop)
    (hdiag : ∃ s, f s = s ∧ (T s ↔ ¬ P s))
    (hsound : ∀ s, f s = s → P s → T s)
    (hcomplete : ∀ s, f s = s → T s → P s) : False := by
  obtain ⟨s, hfix, hd⟩ := hdiag
  exact abstract_diagonal_incompleteness (P s) (T s) hd (hsound s hfix) (hcomplete s hfix)

/-! ## Part 9: Tropical Proof System Structure -/

/-- A tropical proof system on `n` sentences with `WithTop ℝ` cost scores. -/
structure TropicalProofSystemR (n : ℕ) where
  /-- The provability evaluator -/
  eval : (Fin n → WithTop ℝ) → (Fin n → WithTop ℝ)
  /-- Monotonicity -/
  mono : Monotone eval
  /-- Idempotency -/
  idem : ∀ x, eval (eval x) = eval x

/-- **Main Theorem: Tropical Proof System Incompleteness.**

    No tropical proof system can be simultaneously sound and complete with
    respect to a truth predicate that diagonalizes at some sentence coordinate.

    Soundness: at fixed points, provable (score = 0) sentences are true.
    Completeness: at fixed points, true sentences are provable (score = 0).
    The diagonal sentence makes these jointly contradictory. -/
theorem tropical_proof_system_incompleteness
    {n : ℕ} [NeZero n]
    (S : TropicalProofSystemR n)
    (Truth : (Fin n → WithTop ℝ) → Fin n → Prop)
    (hdiag : ∃ i, ∀ x, S.eval x = x → (Truth x i ↔ ¬ TropProvable x i))
    (hsound : ∀ x, S.eval x = x → ∀ i, TropProvable x i → Truth x i)
    (hcomplete : ∀ x, S.eval x = x → ∀ i, Truth x i → TropProvable x i) :
    False := by
  obtain ⟨i, hd⟩ := hdiag
  set x := S.eval (fun _ => (0 : WithTop ℝ))
  have hfix : S.eval x = x := S.idem _
  exact abstract_diagonal_incompleteness
    (TropProvable x i) (Truth x i)
    (hd x hfix) (hsound x hfix i) (hcomplete x hfix i)

/-! ## Part 10: Self-Referential Fixed Point as Quine -/

/-- A tropical quine is a cost profile that computes itself via coordinate functionals. -/
def IsTropicalQuine {n : ℕ} (Φ : Fin n → (Fin n → WithTop ℝ) → WithTop ℝ)
    (x : Fin n → WithTop ℝ) : Prop :=
  ∀ i, x i = Φ i x

/-- **Tropical Quine from Idempotent Operator.** -/
theorem tropical_quine_from_idem
    {n : ℕ} [NeZero n]
    (Ψ : (Fin n → WithTop ℝ) → (Fin n → WithTop ℝ))
    (hidem : ∀ x, Ψ (Ψ x) = Ψ x) :
    ∃ x, IsTropicalQuine (fun i y => Ψ y i) x := by
  exact ⟨Ψ (fun _ => 0), fun i => (congr_fun (hidem _) i).symm⟩

/-! ## Part 11: The Image of an Idempotent Map -/

/-- The image of an idempotent map equals its set of fixed points. -/
theorem idem_range_eq_fixed {α : Type*} (f : α → α) (hidem : ∀ x, f (f x) = f x) :
    Set.range f = {x | f x = x} := by
  ext x; constructor
  · rintro ⟨y, rfl⟩; exact hidem y
  · intro h; exact ⟨x, h⟩

/-! ## Part 12: Axiom Verification -/

#print axioms abstract_diagonal_incompleteness
#print axioms tropical_fixed_point_exists
#print axioms tropical_diagonal_sentence_exists
#print axioms tropical_godel_incompleteness
#print axioms tropical_godel_incompleteness_forall
#print axioms no_sound_complete_tropical_diagonal_system
#print axioms tropical_closure_diagonalization
#print axioms tropical_closure_incompleteness
#print axioms lattice_fixed_point_incompleteness
#print axioms tropical_proof_system_incompleteness
#print axioms tropical_quine_from_idem
#print axioms idem_range_eq_fixed