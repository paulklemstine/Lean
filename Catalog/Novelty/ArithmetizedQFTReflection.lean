import Bridges.LogicPhysicsConsistency

/-!
# Arithmetized reflection for an explicit physical theory, and the exact strength of
# the negative independence half

This file continues the logic–physics consistency thread.  Cycle 0 produced an
*abstract* independence bridge (`PhysicsConsistency.PAIndependenceConditions` and
`PhysicsConsistency.consistency_sentence_independent_of_PA`) whose hypotheses were
never verified for any concrete pair of theories: the bridge could in principle have
been vacuous.  Here we close that gap and answer three of the proposed future
directions.

## What is proved

**(1) Arithmetized QFT reflection.**  We build an *explicit* Hilbert-style calculus
`Thm i Ax` (finitely many rules, generated from an axiom predicate `Ax`; for the
theories used below `Ax` is a decidable singleton, so the theory is recursively
enumerable) and package it as a catalog `ProofSys` via `glSys`.  Taking

* `QFT₀ := glSys qft ∅`  — the pure provability calculus of the physical theory, and
* `PA  := glSys pa {□_pa ⊥ → □_qft ⊥}` — arithmetic *plus the arithmetized
  interpretation axiom* saying that a PA-proof of falsum is transported to a
  QFT₀-proof of falsum,

we prove `PA ⊢ Con(QFT₀) → Con(PA)` (`PAsys_proves_reflection`), and we verify all
remaining hypotheses of the cycle-0 bridge for this pair, obtaining a genuinely
non-vacuous instance: `Con(QFT₀)` is independent of `PA`
(`Con_QFT0_independent_of_PAsys`).  In particular no PA-model can satisfy
`Con(QFT₀) ∧ ¬Con(PA)`, since the implication is a theorem.

**(2) Minimal soundness for the negative independence half.**  We show that the
hypothesis `sigmaSound` of the cycle-0 bridge is not merely sufficient but *exactly
equivalent* to the negative half `PA ⊬ ¬Con(T)` (`negative_half_iff_min_soundness`),
and that it is strictly weaker than the uniform reflection rule (the abstract stand-in
for 1-consistency): the two-world GL theory `capSys` satisfies the minimal condition
but refutes the reflection rule (`minimal_soundness_strictly_weaker`).  So
1-consistency is strictly stronger than necessary.  The separating example is the
first step of an infinite strictly decreasing hierarchy `capSysN n` of finite-height
GL theories, in which reflection fails at iteration depth exactly `n`
(`capSysN_separating`, `capSysN_strict_hierarchy`).

**(5) Independence transfer along interpretations.**  If PA proves both transfer
implications between the consistency sentences of two theories, then `Con(U)` is
PA-independent iff `Con(T)` is (`independence_transfer`).

All of this runs inside the catalog's existing `PhysicsConsistency` interface: the
formula language `Form`, the Kripke satisfaction `sat`, `IsGLTheory`, `Con`,
`Consistent`, `Independent` and `PAIndependenceConditions` are reused verbatim.
-/

namespace PhysicsConsistency

open ProofSystemCollapse
open Form

/-! ## §1. Two propositional tautologies -/

/-- Double negation *introduction* is a tautology: `q → ¬¬q`. -/
theorem taut_dni (q : Form) : Taut (imp q (neg (neg q))) := by
  intro v hbot himp
  simp only [neg, himp, hbot]
  cases v q <;> simp

/-- Contraposition is a tautology: `(a → b) → (¬b → ¬a)`. -/
theorem taut_contrapose (a b : Form) :
    Taut (imp (imp a b) (imp (neg b) (neg a))) := by
  intro v hbot himp
  simp only [neg, himp, hbot]
  cases v a <;> cases v b <;> simp

/-! ## §2. An explicit recursively enumerable GL calculus -/

/-- The explicit Hilbert calculus of a tagged theory: all classical tautologies, all
instances of the three GL schemata for the operator `box i`, every formula in the
axiom predicate `Ax`, closed under modus ponens and necessitation.  With a decidable
`Ax` (as in all instances below) the derivability predicate is recursively
enumerable: derivations are finite trees over finitely many rule shapes. -/
inductive Thm (i : ℕ) (Ax : Form → Prop) : Form → Prop
  /-- A nonlogical axiom. -/
  | ax {a} : Ax a → Thm i Ax a
  /-- Every classical (box-opaque) tautology. -/
  | taut {a} : Taut a → Thm i Ax a
  /-- Modus ponens. -/
  | mp {a b} : Thm i Ax (imp a b) → Thm i Ax a → Thm i Ax b
  /-- Necessitation. -/
  | nec {a} : Thm i Ax a → Thm i Ax (box i a)
  /-- Distribution axiom `K`. -/
  | dist (a b) : Thm i Ax (imp (box i (imp a b)) (imp (box i a) (box i b)))
  /-- Transitivity axiom `4`. -/
  | four (a) : Thm i Ax (imp (box i a) (box i (box i a)))
  /-- Löb axiom. -/
  | loeb (a) : Thm i Ax (imp (box i (imp (box i a) a)) (box i a))

/-- The proof system whose proofs are the derivations of the calculus `Thm i Ax`. -/
def glSys (i : ℕ) (Ax : Form → Prop) : ProofSys Form where
  Proof := { a : Form // Thm i Ax a }
  concl := Subtype.val
  size := fun _ => 0

/-- Provability in `glSys i Ax` is derivability in the calculus. -/
theorem provable_glSys (i : ℕ) (Ax : Form → Prop) (a : Form) :
    Provable (glSys i Ax) a ↔ Thm i Ax a := by
  constructor
  · rintro ⟨⟨b, hb⟩, rfl⟩; exact hb
  · intro h; exact ⟨⟨a, h⟩, rfl⟩

/-- The explicit calculus is a GL theory for its own tag. -/
theorem isGL_glSys (i : ℕ) (Ax : Form → Prop) : IsGLTheory i (glSys i Ax) := by
  constructor
  · intro a b hab ha
    rw [provable_glSys] at *; exact Thm.mp hab ha
  · intro a ha; rw [provable_glSys] at *; exact Thm.nec ha
  · intro a ha; rw [provable_glSys]; exact Thm.taut ha
  · intro a b; rw [provable_glSys]; exact Thm.dist a b
  · intro a; rw [provable_glSys]; exact Thm.four a
  · intro a; rw [provable_glSys]; exact Thm.loeb a

/-- **Soundness of the explicit calculus relative to any GL model.**  If `S` is a GL
theory at tag `i` proving every nonlogical axiom, then `S` proves every theorem of
`Thm i Ax`.  This is the tool used to establish consistency and minimal soundness of
the explicit theories. -/
theorem thm_sound {i : ℕ} {Ax : Form → Prop} {S : ProofSys Form}
    (hGL : IsGLTheory i S) (hax : ∀ a, Ax a → Provable S a) :
    ∀ a, Thm i Ax a → Provable S a := by
  intro a h
  induction h with
  | ax ha => exact hax _ ha
  | taut ht => exact hGL.taut ht
  | mp _ _ ih1 ih2 => exact hGL.mp ih1 ih2
  | nec _ ih => exact hGL.nec ih
  | dist a b => exact hGL.dist a b
  | four a => exact hGL.four a
  | loeb a => exact hGL.loeb a

/-! ## §3. The finite-height GL models `capSysN`

The catalog's standard Kripke model `stdSys` (validity at *all* worlds of `(ℕ, <)`)
obeys the uniform reflection rule: `Provable stdSys (box i a)` forces
`Provable stdSys a`, because every world has a successor.  Truncating validity to the
first `n + 1` worlds `{0, …, n}` produces a *finite-height* GL theory `capSysN n`
which still refuses to prove `box i ⊥` (as soon as `n ≥ 1`) but *fails* the uniform
reflection rule: it proves `□_i (□_i^n ⊥)` while refuting `□_i^n ⊥`.  This yields the
separating family needed for Future Direction 2, and an infinite strictly decreasing
hierarchy of GL theories. -/

/-- Iterated provability operator: `boxPow i k a` is `□_i^k a`. -/
def boxPow (i : ℕ) : ℕ → Form → Form
  | 0, a => a
  | (k + 1), a => box i (boxPow i k a)

/-- In the Kripke model on `(ℕ, <)`, the `k`-fold boxed falsum is true exactly at the
worlds of height `< k`. -/
theorem sat_boxPow_bot (i k : ℕ) : ∀ m : ℕ, sat m (boxPow i k bot) = true ↔ m < k := by
  induction k with
  | zero => intro m; simp [boxPow, sat]
  | succ k ih =>
    intro m
    rw [boxPow, sat_box]
    constructor
    · intro h
      by_contra hlt
      have hk : k < m := by omega
      exact absurd ((ih k).1 (h k hk)) (by omega)
    · intro h j hj
      exact (ih j).2 (by omega)

/-- The GL theory of height `n`: theorems are the formulas true at all worlds
`0, …, n` of the catalog's Kripke satisfaction `sat`. -/
def capSysN (n : ℕ) : ProofSys Form where
  Proof := { a : Form // ∀ m ≤ n, sat m a = true }
  concl := Subtype.val
  size := fun _ => 0

/-- Provability in `capSysN n` is truth at the worlds `0, …, n`. -/
theorem provable_capSysN (n : ℕ) (a : Form) :
    Provable (capSysN n) a ↔ ∀ m ≤ n, sat m a = true := by
  constructor
  · rintro ⟨⟨b, hb⟩, rfl⟩; exact hb
  · intro h; exact ⟨⟨a, h⟩, rfl⟩

/-- **Every finite-height frame is a GL theory for every tag.** -/
theorem isGL_capSysN (n i : ℕ) : IsGLTheory i (capSysN n) := by
  constructor
  · intro a b hab ha
    rw [provable_capSysN] at *
    intro m hm
    have h := hab m hm
    rw [sat_imp] at h
    exact h (ha m hm)
  · intro a ha
    rw [provable_capSysN] at *
    intro m _
    rw [sat_box]
    intro k hk
    exact ha k (by omega)
  · intro a ha
    rw [provable_capSysN]
    intro m _
    exact ha (sat m) rfl (fun _ _ => rfl)
  · intro a b
    rw [provable_capSysN]
    intro m _
    rw [sat_imp]; intro hab
    rw [sat_imp]; intro ha
    rw [sat_box] at hab ha ⊢
    intro k hk
    have h1 := hab k hk
    rw [sat_imp] at h1
    exact h1 (ha k hk)
  · intro a
    rw [provable_capSysN]
    intro m _
    rw [sat_imp]; intro h
    rw [sat_box] at h ⊢
    intro k hk
    rw [sat_box]
    intro j hj
    exact h j (hj.trans hk)
  · intro a
    rw [provable_capSysN]
    intro m _
    rw [sat_imp]; intro h
    rw [sat_box] at h ⊢
    exact box_a_valid i a m h

/-- **Provability of iterated boxed falsum in a finite-height theory** is decided by
comparing the height with the iteration depth. -/
theorem provable_capSysN_boxPow_bot (n i k : ℕ) :
    Provable (capSysN n) (boxPow i k bot) ↔ n < k := by
  rw [provable_capSysN]
  constructor
  · intro h; exact (sat_boxPow_bot i k n).1 (h n le_rfl)
  · intro h m hm; exact (sat_boxPow_bot i k m).2 (by omega)

/-- **Every finite-height GL theory is consistent.** -/
theorem consistent_capSysN (n : ℕ) : Consistent (capSysN n) := by
  intro h
  have : Provable (capSysN n) (boxPow 0 0 bot) := h
  exact absurd ((provable_capSysN_boxPow_bot n 0 0).1 this) (by omega)

/-- The two-world GL theory: the height-`1` member of the family. -/
def capSys : ProofSys Form := capSysN 1

/-- Provability in `capSys` is truth at the two worlds `0` and `1`. -/
theorem provable_capSys (a : Form) :
    Provable capSys a ↔ ∀ m ≤ 1, sat m a = true := provable_capSysN 1 a

/-- **The two-world frame is a GL theory for every tag.** -/
theorem isGL_capSys (i : ℕ) : IsGLTheory i capSys := isGL_capSysN 1 i

/-- **`capSys` is consistent**: `⊥` fails at world `0`. -/
theorem consistent_capSys : Consistent capSys := consistent_capSysN 1

/-- **`capSys` has the minimal soundness property**: it does not prove `box i ⊥`,
because world `1` sees world `0`, where `⊥` fails. -/
theorem capSys_not_provable_box_bot (i : ℕ) : ¬ Provable capSys (box i bot) := by
  intro h
  have : Provable (capSysN 1) (boxPow i 1 bot) := h
  exact absurd ((provable_capSysN_boxPow_bot 1 i 1).1 this) (by omega)

/-- `capSys` *does* prove `box i (box i ⊥)`: world `1` sees only world `0`, which is a
dead end. -/
theorem capSys_provable_box_box_bot (i : ℕ) : Provable capSys (box i (box i bot)) :=
  (provable_capSysN_boxPow_bot 1 i 2).2 (by omega)

/-! ## §4. Future Direction 2: the exact strength of the negative half -/

/-- The **uniform reflection rule** at tag `i` — the abstract stand-in for
1-consistency: whatever the theory proves to be provable, it proves. -/
def UniformReflectionRule (i : ℕ) (S : ProofSys Form) : Prop :=
  ∀ a, Provable S (box i a) → Provable S a

/-- The **minimal soundness condition** used by the cycle-0 bridge: the theory does
not prove that theory `i` proves falsum. -/
def MinSoundness (i : ℕ) (S : ProofSys Form) : Prop := ¬ Provable S (box i bot)

/-- **The negative independence half is exactly the minimal soundness condition.**
For a GL theory `S`, `S ⊬ ¬Con(i)` holds if and only if `S ⊬ □_i ⊥`; the two are
interderivable through double-negation introduction and elimination.  Hence no
hypothesis weaker than `MinSoundness` can prove the negative half, and none stronger
is needed. -/
theorem negative_half_iff_min_soundness {i : ℕ} {S : ProofSys Form}
    (hGL : IsGLTheory i S) :
    (¬ Provable S (neg (Con i))) ↔ MinSoundness i S := by
  constructor
  · intro h hbox
    apply h
    have hdni : Provable S (imp (box i bot) (neg (neg (box i bot)))) :=
      hGL.taut (taut_dni (box i bot))
    exact hGL.mp hdni hbox
  · intro h hneg
    apply h
    have hdne : Provable S (imp (neg (neg (box i bot))) (box i bot)) :=
      hGL.taut (taut_dne (box i bot))
    exact hGL.mp hdne hneg

/-- The uniform reflection rule implies the minimal soundness condition for a
consistent theory: from `□_i ⊥` it would prove `⊥`. -/
theorem uniform_reflection_implies_min_soundness {i : ℕ} {S : ProofSys Form}
    (hcon : Consistent S) (hur : UniformReflectionRule i S) : MinSoundness i S :=
  fun hbox => hcon (hur bot hbox)

/-- **Future Direction 2, answered: 1-consistency is strictly stronger than
necessary.**  The two-world GL theory `capSys` is consistent, satisfies the minimal
soundness condition (hence the negative independence half `capSys ⊬ ¬Con(i)`), yet
refutes the uniform reflection rule: it proves `□_i □_i ⊥` without proving
`□_i ⊥`. -/
theorem minimal_soundness_strictly_weaker (i : ℕ) :
    IsGLTheory i capSys ∧ Consistent capSys ∧ MinSoundness i capSys ∧
      ¬ Provable capSys (neg (Con i)) ∧ ¬ UniformReflectionRule i capSys := by
  refine ⟨isGL_capSys i, consistent_capSys, capSys_not_provable_box_bot i, ?_, ?_⟩
  · exact (negative_half_iff_min_soundness (isGL_capSys i)).2
      (capSys_not_provable_box_bot i)
  · intro hur
    exact capSys_not_provable_box_bot i (hur (box i bot) (capSys_provable_box_box_bot i))

/-- **An infinite family of separating theories.**  For every height `n ≥ 1` the GL
theory `capSysN n` is consistent, satisfies the minimal soundness condition (hence the
negative independence half), and refutes the uniform reflection rule — it proves
`□_i □_i^n ⊥` while refuting `□_i^n ⊥`.  The failure of reflection therefore occurs at
arbitrarily large iteration depth. -/
theorem capSysN_separating (n i : ℕ) (hn : 1 ≤ n) :
    IsGLTheory i (capSysN n) ∧ Consistent (capSysN n) ∧ MinSoundness i (capSysN n) ∧
      Provable (capSysN n) (boxPow i (n + 1) bot) ∧
      ¬ Provable (capSysN n) (boxPow i n bot) ∧ ¬ UniformReflectionRule i (capSysN n) := by
  have hup : Provable (capSysN n) (boxPow i (n + 1) bot) :=
    (provable_capSysN_boxPow_bot n i (n + 1)).2 (by omega)
  have hdown : ¬ Provable (capSysN n) (boxPow i n bot) := fun h =>
    absurd ((provable_capSysN_boxPow_bot n i n).1 h) (by omega)
  refine ⟨isGL_capSysN n i, consistent_capSysN n, ?_, hup, hdown, ?_⟩
  · intro h
    have : Provable (capSysN n) (boxPow i 1 bot) := h
    exact absurd ((provable_capSysN_boxPow_bot n i 1).1 this) (by omega)
  · intro hur
    exact hdown (hur (boxPow i n bot) hup)

/-- **The finite-height theories form a strictly decreasing hierarchy.**  Everything
provable at height `n + 1` is provable at height `n`, and the converse fails: the
sentence `□_i^{n+1} ⊥` separates them.  So the separating example of Future
Direction 2 is not isolated but the first step of an infinite chain. -/
theorem capSysN_strict_hierarchy (n i : ℕ) :
    (∀ a, Provable (capSysN (n + 1)) a → Provable (capSysN n) a) ∧
      ∃ a, Provable (capSysN n) a ∧ ¬ Provable (capSysN (n + 1)) a := by
  constructor
  · intro a h
    rw [provable_capSysN] at *
    intro m hm
    exact h m (by omega)
  · refine ⟨boxPow i (n + 1) bot, (provable_capSysN_boxPow_bot n i (n + 1)).2 (by omega), ?_⟩
    intro h
    exact absurd ((provable_capSysN_boxPow_bot (n + 1) i (n + 1)).1 h) (by omega)

/-! ## §5. Future Direction 1: an explicit theory `QFT₀` and arithmetized reflection -/

/-- The arithmetized **interpretation axiom**: "every proof of falsum in theory `pa`
is transported to a proof of falsum in theory `qft`".  This is the object-level trace
of a formalized interpretation of arithmetic inside the physical theory. -/
def transferAxiom (pa qft : ℕ) : Form := imp (box pa bot) (box qft bot)

/-- The explicit recursively enumerable physical theory `QFT₀`: the pure provability
calculus of tag `qft`, with no nonlogical axioms. -/
def QFT0 (qft : ℕ) : ProofSys Form := glSys qft (fun _ => False)

/-- The explicit arithmetic `PA`: the provability calculus of tag `pa` together with
the single nonlogical axiom `transferAxiom pa qft`.  Its axiom set is decidable (a
singleton), so the theory is recursively enumerable. -/
def PAsys (pa qft : ℕ) : ProofSys Form := glSys pa (fun a => a = transferAxiom pa qft)

/-- `PAsys` is a GL theory at tag `pa`. -/
theorem isGL_PAsys (pa qft : ℕ) : IsGLTheory pa (PAsys pa qft) := isGL_glSys _ _

/-- `QFT0` is a GL theory at tag `qft`. -/
theorem isGL_QFT0 (qft : ℕ) : IsGLTheory qft (QFT0 qft) := isGL_glSys _ _

/-- `capSys` proves every instance of the interpretation axiom: in the Kripke
semantics the box is index-insensitive, so both sides of the transfer implication are
the same condition. -/
theorem capSys_provable_transferAxiom (pa qft : ℕ) :
    Provable capSys (transferAxiom pa qft) := by
  rw [provable_capSys]
  intro m _
  rw [transferAxiom, sat_imp]
  intro h
  rw [sat_box] at h ⊢
  exact h

/-- Every theorem of the explicit arithmetic `PAsys` is true at the two worlds
`0`, `1`, i.e. `PAsys` is interpretable in `capSys`. -/
theorem PAsys_sound_in_capSys (pa qft : ℕ) (a : Form) :
    Provable (PAsys pa qft) a → Provable capSys a := by
  intro h
  rw [PAsys, provable_glSys] at h
  refine thm_sound (isGL_capSys pa) ?_ a h
  rintro b rfl
  exact capSys_provable_transferAxiom pa qft

/-- **The explicit arithmetic is consistent.** -/
theorem consistent_PAsys (pa qft : ℕ) : Consistent (PAsys pa qft) :=
  fun h => consistent_capSys (PAsys_sound_in_capSys pa qft bot h)

/-- **The explicit physical theory `QFT₀` is consistent.** -/
theorem consistent_QFT0 (qft : ℕ) : Consistent (QFT0 qft) := by
  intro h
  rw [QFT0, provable_glSys] at h
  exact consistent_capSys (thm_sound (isGL_capSys qft) (fun _ hf => hf.elim) bot h)

/-- **The explicit arithmetic has the minimal soundness property for the physical
tag**: it does not prove that `QFT₀` proves falsum. -/
theorem PAsys_min_soundness (pa qft : ℕ) : MinSoundness qft (PAsys pa qft) :=
  fun h => capSys_not_provable_box_bot qft (PAsys_sound_in_capSys pa qft _ h)

/-- **Future Direction 1: arithmetized QFT reflection.**  The explicit arithmetic
proves `Con(QFT₀) → Con(PA)`, by contraposing the arithmetized interpretation
axiom. -/
theorem PAsys_proves_reflection (pa qft : ℕ) :
    Provable (PAsys pa qft) (imp (Con qft) (Con pa)) := by
  have hGL := isGL_PAsys pa qft
  have hax : Provable (PAsys pa qft) (transferAxiom pa qft) := by
    rw [PAsys, provable_glSys]; exact Thm.ax rfl
  have hcp : Provable (PAsys pa qft)
      (imp (transferAxiom pa qft) (imp (neg (box qft bot)) (neg (box pa bot)))) :=
    hGL.taut (taut_contrapose (box pa bot) (box qft bot))
  exact hGL.mp hcp hax

/-- **All hypotheses of the cycle-0 independence bridge hold for the explicit pair
`(PAsys, QFT₀)`.**  In particular the bridge is not vacuous. -/
theorem PAsys_independence_conditions (pa qft : ℕ) :
    PAIndependenceConditions pa qft (PAsys pa qft) where
  gl := isGL_PAsys pa qft
  consistent := consistent_PAsys pa qft
  reflection := PAsys_proves_reflection pa qft
  sigmaSound := PAsys_min_soundness pa qft

/-- **The consistency sentence of the explicit physical theory is independent of the
explicit arithmetic.**  A concrete, non-vacuous instance of the cycle-0 bridge. -/
theorem Con_QFT0_independent_of_PAsys (pa qft : ℕ) :
    Independent (PAsys pa qft) (Con qft) :=
  consistency_sentence_independent_of_PA (PAsys_independence_conditions pa qft)

/-- The arithmetic also cannot prove its own consistency sentence (Gödel II for the
explicit theory). -/
theorem PAsys_not_provable_own_Con (pa qft : ℕ) :
    ¬ Provable (PAsys pa qft) (Con pa) :=
  goedel_second_incompleteness (isGL_PAsys pa qft) (consistent_PAsys pa qft)

/-! ## §6. Future Direction 5: independence transfer along interpretations -/

/-- Two tags are **mutually interpretable over `PA`** when `PA` proves both transfer
implications between their consistency sentences. -/
def MutualConTransfer (u t : ℕ) (PA : ProofSys Form) : Prop :=
  Provable PA (imp (Con u) (Con t)) ∧ Provable PA (imp (Con t) (Con u))

/-- Half of the transfer: a PA-provable implication `Con u → Con t` moves the
positive half of independence from `t` to `u` and the negative half from `u` to
`t`. -/
theorem transfer_one_direction {u t : ℕ} {PA : ProofSys Form}
    (hGL : ∀ {a b}, Provable PA (imp a b) → Provable PA a → Provable PA b)
    (htaut : ∀ {a}, Taut a → Provable PA a)
    (himp : Provable PA (imp (Con u) (Con t))) :
    (¬ Provable PA (Con t) → ¬ Provable PA (Con u)) ∧
      (¬ Provable PA (neg (Con u)) → ¬ Provable PA (neg (Con t))) := by
  constructor
  · intro h hu; exact h (hGL himp hu)
  · intro h ht
    apply h
    have hcp : Provable PA (imp (imp (Con u) (Con t)) (imp (neg (Con t)) (neg (Con u)))) :=
      htaut (taut_contrapose (Con u) (Con t))
    exact hGL (hGL hcp himp) ht

/-- **Future Direction 5: independence transfers along mutual interpretations.**  If
`PA` proves both transfer implications between `Con u` and `Con t`, then `Con u` is
independent of `PA` exactly when `Con t` is.  Consequently no verified pair of mutual
interpretations can make only one of the two consistency sentences independent. -/
theorem independence_transfer {u t pa : ℕ} {PA : ProofSys Form}
    (hGL : IsGLTheory pa PA) (h : MutualConTransfer u t PA) :
    Independent PA (Con u) ↔ Independent PA (Con t) := by
  obtain ⟨hut, htu⟩ := h
  have Hut := transfer_one_direction (u := u) (t := t) hGL.mp hGL.taut hut
  have Htu := transfer_one_direction (u := t) (t := u) hGL.mp hGL.taut htu
  constructor
  · rintro ⟨h1, h2⟩
    exact ⟨Htu.1 h1, Hut.2 h2⟩
  · rintro ⟨h1, h2⟩
    exact ⟨Hut.1 h1, Htu.2 h2⟩

/-- The explicit arithmetic *with both* interpretation axioms: PA-proofs of falsum
transfer to `QFT₀` and conversely.  This is the object-level trace of a pair of
mutual interpretations. -/
def PAbi (pa qft : ℕ) : ProofSys Form :=
  glSys pa (fun a => a = transferAxiom pa qft ∨ a = transferAxiom qft pa)

/-- `PAbi` is a GL theory at tag `pa`. -/
theorem isGL_PAbi (pa qft : ℕ) : IsGLTheory pa (PAbi pa qft) := isGL_glSys _ _

/-- `PAbi` is interpretable in the two-world model, hence consistent and minimally
sound for both tags. -/
theorem PAbi_sound_in_capSys (pa qft : ℕ) (a : Form) :
    Provable (PAbi pa qft) a → Provable capSys a := by
  intro h
  rw [PAbi, provable_glSys] at h
  refine thm_sound (isGL_capSys pa) ?_ a h
  rintro b (rfl | rfl)
  · exact capSys_provable_transferAxiom pa qft
  · exact capSys_provable_transferAxiom qft pa

/-- **`PAbi` is consistent.** -/
theorem consistent_PAbi (pa qft : ℕ) : Consistent (PAbi pa qft) :=
  fun h => consistent_capSys (PAbi_sound_in_capSys pa qft bot h)

/-- **`PAbi` is minimally sound at every tag** (it never proves `□_j ⊥`). -/
theorem PAbi_min_soundness (pa qft j : ℕ) : MinSoundness j (PAbi pa qft) :=
  fun h => capSys_not_provable_box_bot j (PAbi_sound_in_capSys pa qft _ h)

/-- `PAbi` proves both consistency transfer implications: the mutual interpretation
hypothesis of Future Direction 5 is satisfiable. -/
theorem PAbi_mutual_transfer (pa qft : ℕ) : MutualConTransfer qft pa (PAbi pa qft) := by
  have hGL := isGL_PAbi pa qft
  have hax1 : Provable (PAbi pa qft) (transferAxiom pa qft) := by
    rw [PAbi, provable_glSys]; exact Thm.ax (Or.inl rfl)
  have hax2 : Provable (PAbi pa qft) (transferAxiom qft pa) := by
    rw [PAbi, provable_glSys]; exact Thm.ax (Or.inr rfl)
  constructor
  · exact hGL.mp (hGL.taut (taut_contrapose (box pa bot) (box qft bot))) hax1
  · exact hGL.mp (hGL.taut (taut_contrapose (box qft bot) (box pa bot))) hax2

/-- The independence conditions hold for `PAbi` at the physical tag. -/
theorem PAbi_independence_conditions (pa qft : ℕ) :
    PAIndependenceConditions pa qft (PAbi pa qft) where
  gl := isGL_PAbi pa qft
  consistent := consistent_PAbi pa qft
  reflection := (PAbi_mutual_transfer pa qft).1
  sigmaSound := PAbi_min_soundness pa qft qft

/-- **A verified pair of mutual interpretations, with independence on both sides.**
For the bi-interpretable explicit theory `PAbi`, `Con(QFT₀)` and `Con(PA)` are
*simultaneously* independent — exactly as Future Direction 5 predicts, so this pair
does not refute the transfer conjecture. -/
theorem PAbi_independence_both (pa qft : ℕ) :
    Independent (PAbi pa qft) (Con qft) ∧ Independent (PAbi pa qft) (Con pa) := by
  have h1 : Independent (PAbi pa qft) (Con qft) :=
    consistency_sentence_independent_of_PA (PAbi_independence_conditions pa qft)
  exact ⟨h1, (independence_transfer (isGL_PAbi pa qft) (PAbi_mutual_transfer pa qft)).1 h1⟩

end PhysicsConsistency