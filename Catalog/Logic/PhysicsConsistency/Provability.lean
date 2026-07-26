import Mathlib
import Logic.ProofSystemCollapse

/-!
# Logic–Physics Bridge I: Abstract Provability Predicates for Physical Theories

This file sets up the proof-theoretic skeleton used to study the *consistency of a
physical theory as a proof-theoretic question*.  We model a theory as an abstract
**proof system** (reusing `ProofSystemCollapse.ProofSys` / `Provable` / `Simulates`
from `Logic.ProofSystemCollapse`) whose formulas carry just enough logical structure
— implication, falsum, and an internal *provability operator* `box i` (one operator
per theory tag `i`) — to express the Hilbert–Bernays–Löb derivability conditions.

A theory `S` tagged `i` is a **GL theory** (`IsGLTheory i S`) when its set of theorems
`Provable S` is closed under modus ponens and necessitation, contains every classical
(box-opaque) tautology, and satisfies the distribution (`K`), transitivity (`4`) and
Löb axiom schemata for its own provability operator `box i`.  This is exactly the
abstract provability calculus behind Solovay's theorem: `GL` is the provability logic
of any sufficiently strong Σ₁-sound theory, and in particular of the proof-theoretic
core of a recursively axiomatized physical theory such as quantum field theory.

The consistency *sentence* of theory `i` is `Con i := ¬ box i ⊥` ("`⊥` is not provable
in theory `i`"), an object-level formula, as opposed to the meta-level predicate
`Consistent S := ¬ Provable S ⊥`.  Keeping these two notions of consistency apart is
the whole point of Gödel's second incompleteness theorem.

## Main definitions / results

* `Form`, `eval`, `sat`, `Taut` — the formula language, two models (a degenerate
  box-true model and the genuine standard Kripke model on `(ℕ, <)`), and the notion of
  a classical box-opaque tautology.
* `IsGLTheory i S`, `Consistent S`, `Con i` — GL theories and the two consistencies.
* `taut_dne` — double-negation elimination as a tautology.
* `trueSys` — a consistent GL theory (box-true Boolean model); **not** Σ₁-sound.
* `stdSys` — the **standard Kripke model**: a consistent *and* Σ₁-sound GL theory,
  the non-vacuity witness for the independence theorems.
* `trivialSys` — the inconsistent theory that proves everything.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): "consistency of a physical theory" is faithfully captured by an
  abstract provability predicate satisfying the HBL derivability conditions; the
  object/meta distinction `Con i` vs `Consistent S` is the crux.
Experiment (Stage 2): encode formulas with an indexed box `box i` so one theory can
  talk about another theory's provability predicate; model theorems as
  `ProofSystemCollapse.Provable`.  Two concrete `ProofSys` are built: the box-true
  Boolean model `trueSys` and the standard Kripke model `stdSys` on `(ℕ, <)`.
Analysis (Stage 3): the only propositional ingredient needed downstream is
  double-negation elimination (`taut_dne`); the box-true model is consistent but
  proves `box i ⊥` (it is *not* Σ₁-sound), so it cannot witness the negation half of
  independence — the genuine Kripke model `stdSys` is required.
Critique (Stage 4): a single un-indexed `box` would collapse `Con(T)` and `Con(PA)`
  into one syntactic formula, trivializing cross-theory independence; the ℕ-indexed box
  avoids this.  Löb-axiom validity in `stdSys` is exactly converse-well-foundedness of
  `<` (`box_a_valid`, by strong induction) — the proof-theoretic heart of the model.
Synthesis (Stage 5): `IsGLTheory` + `stdSys` give a non-vacuous abstract setting in
  which Löb, Gödel II and the consistency-bridge theorems all become provable.
-/

namespace PhysicsConsistency

open ProofSystemCollapse

/-- Formulas of the abstract provability calculus.  `box i a` is the internal sentence
"theory number `i` proves `a`"; the index lets one theory reason about another's
provability predicate. -/
inductive Form
  | bot : Form
  | atom : ℕ → Form
  | imp : Form → Form → Form
  | box : ℕ → Form → Form
  deriving DecidableEq

namespace Form

/-- Negation as implication to falsum. -/
def neg (p : Form) : Form := imp p bot

end Form

open Form

/-- The consistency sentence of theory `i`: "`⊥` is not provable in theory `i`". -/
def Con (i : ℕ) : Form := neg (box i bot)

/-- `a` is a **(classical, box-opaque) tautology**: it evaluates to `true` under every
valuation `v` interpreting `⊥` as `false` and `imp` classically, with `box`-formulas
and atoms treated as opaque propositional variables. -/
def Taut (a : Form) : Prop :=
  ∀ v : Form → Bool, v bot = false → (∀ x y, v (imp x y) = ((!(v x)) || v y)) → v a = true

/-- A tagged **GL theory**: the theorems of the proof system `S` satisfy, for the
provability operator `box i`, the Hilbert–Bernays–Löb derivability conditions:
closure under modus ponens and necessitation, all classical tautologies, and the
distribution (`K`), transitivity (`4`) and Löb axiom schemata. -/
structure IsGLTheory (i : ℕ) (S : ProofSys Form) : Prop where
  /-- Modus ponens. -/
  mp : ∀ {a b}, Provable S (imp a b) → Provable S a → Provable S b
  /-- Necessitation: a theorem is provably provable. -/
  nec : ∀ {a}, Provable S a → Provable S (box i a)
  /-- Every classical tautology is a theorem. -/
  taut : ∀ {a}, Taut a → Provable S a
  /-- Distribution axiom `K`: `□(a → b) → (□a → □b)`. -/
  dist : ∀ a b, Provable S (imp (box i (imp a b)) (imp (box i a) (box i b)))
  /-- Transitivity axiom `4`: `□a → □□a`. -/
  four : ∀ a, Provable S (imp (box i a) (box i (box i a)))
  /-- Löb axiom: `□(□a → a) → □a`. -/
  loeb : ∀ a, Provable S (imp (box i (imp (box i a) a)) (box i a))

/-- **Meta-level consistency**: the theory does not prove `⊥`. -/
def Consistent (S : ProofSys Form) : Prop := ¬ Provable S bot

/-! ## A propositional lemma: double-negation elimination -/

/-- **Double-negation elimination is a tautology.**  `¬¬q → q`, i.e.
`((q → ⊥) → ⊥) → q`.  The only propositional ingredient (beyond modus ponens) needed
for the independence arguments. -/
theorem taut_dne (q : Form) : Taut (imp (neg (neg q)) q) := by
  intro v hbot himp
  simp only [neg, himp, hbot]
  cases v q <;> simp

/-! ## A degenerate consistent GL theory: the box-true Boolean model -/

/-- A Boolean model of the language: classical on `⊥`/`imp`, and `box _ _ := true`.
This is the "everything is provable" valuation; it makes `⊥` false, so the induced
theory is consistent, but it makes `box i ⊥` true, so it is *not* Σ₁-sound. -/
def eval : Form → Bool
  | .bot => false
  | .atom _ => true
  | .imp a b => (!(eval a)) || eval b
  | .box _ _ => true

/-- The proof system whose proofs are exactly the `eval`-true formulas. -/
def trueSys : ProofSys Form where
  Proof := { a : Form // eval a = true }
  concl := Subtype.val
  size := fun _ => 0

/-- Provability in `trueSys` is `eval`-truth. -/
theorem provable_trueSys (a : Form) : Provable trueSys a ↔ eval a = true := by
  constructor
  · rintro ⟨⟨b, hb⟩, rfl⟩; exact hb
  · intro h; exact ⟨⟨a, h⟩, rfl⟩

/-- **The box-true Boolean model is a GL theory for every tag.** -/
theorem isGL_trueSys (i : ℕ) : IsGLTheory i trueSys := by
  constructor
  · intro a b hab ha
    rw [provable_trueSys] at *
    simp only [eval] at hab
    revert hab ha; cases eval a <;> cases eval b <;> simp
  · intro a _; rw [provable_trueSys]; rfl
  · intro a h; rw [provable_trueSys]; exact h eval rfl (fun x y => rfl)
  · intro a b; rw [provable_trueSys]; simp [eval]
  · intro a; rw [provable_trueSys]; simp [eval]
  · intro a; rw [provable_trueSys]; simp [eval]

/-- **The box-true Boolean model is consistent**: it does not prove `⊥`. -/
theorem consistent_trueSys : Consistent trueSys := by
  intro h; rw [provable_trueSys] at h; simp [eval] at h

/-! ## The standard Kripke model on `(ℕ, <)`: a Σ₁-sound consistent GL theory -/

/-- Kripke satisfaction at world `m` over the converse-well-founded frame `(ℕ, n < m)`.
`box _ a` holds at `m` iff `a` holds at every strictly smaller world. -/
def sat : ℕ → Form → Bool
  | _, bot => false
  | _, atom _ => true
  | m, imp a b => (!(sat m a)) || sat m b
  | m, box _ a => (List.range m).all (fun n => sat n a)

/-- Satisfaction of a box: holds at `m` iff it holds at all smaller worlds. -/
theorem sat_box (m i : ℕ) (a : Form) :
    sat m (box i a) = true ↔ ∀ n, n < m → sat n a = true := by
  simp [sat, List.all_eq_true, List.mem_range]

/-- Satisfaction of an implication is classical and local. -/
theorem sat_imp (m : ℕ) (a b : Form) :
    sat m (imp a b) = true ↔ (sat m a = true → sat m b = true) := by
  simp only [sat]; cases sat m a <;> cases sat m b <;> simp

/-- **The semantic engine behind Löb validity.**  If `□a → a` holds below `m`, then `a`
holds below `m`.  This is precisely converse-well-foundedness of `<`, proved by strong
induction; it is the model-theoretic shadow of the Löb axiom. -/
theorem box_a_valid (i : ℕ) (a : Form) (m : ℕ)
    (h : ∀ n, n < m → sat n (imp (box i a) a) = true) :
    ∀ n, n < m → sat n a = true := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro hn
    have hstep := h n hn
    rw [sat_imp, sat_box] at hstep
    exact hstep (fun k hk => ih k hk (hk.trans hn))

/-- The proof system whose proofs are exactly the formulas valid at every world. -/
def stdSys : ProofSys Form where
  Proof := { a : Form // ∀ m, sat m a = true }
  concl := Subtype.val
  size := fun _ => 0

/-- Provability in `stdSys` is validity at all worlds. -/
theorem provable_stdSys (a : Form) : Provable stdSys a ↔ ∀ m, sat m a = true := by
  constructor
  · rintro ⟨⟨b, hb⟩, rfl⟩; exact hb
  · intro h; exact ⟨⟨a, h⟩, rfl⟩

/-- **The standard Kripke model is a GL theory for every tag.**  Necessitation is the
"validity is hereditary" step; `4` is transitivity of `<`; `loeb` is `box_a_valid`. -/
theorem isGL_stdSys (i : ℕ) : IsGLTheory i stdSys := by
  constructor
  · intro a b hab ha; rw [provable_stdSys] at *
    intro m; have h := hab m; rw [sat_imp] at h; exact h (ha m)
  · intro a ha; rw [provable_stdSys] at *; intro m; rw [sat_box]; intro n _; exact ha n
  · intro a ha; rw [provable_stdSys]; intro m; exact ha (sat m) rfl (fun x y => rfl)
  · intro a b; rw [provable_stdSys]; intro m
    rw [sat_imp]; intro hab; rw [sat_imp]; intro ha
    rw [sat_box] at hab ha ⊢; intro n hn
    have h1 := hab n hn; rw [sat_imp] at h1; exact h1 (ha n hn)
  · intro a; rw [provable_stdSys]; intro m
    rw [sat_imp]; intro h; rw [sat_box] at h ⊢; intro n hn
    rw [sat_box]; intro k hk; exact h k (hk.trans hn)
  · intro a; rw [provable_stdSys]; intro m
    rw [sat_imp]; intro h; rw [sat_box] at h ⊢; exact box_a_valid i a m h

/-- **The standard model is consistent**: it does not prove `⊥` (false at world `0`). -/
theorem consistent_stdSys : Consistent stdSys := by
  intro hp; rw [provable_stdSys] at hp; have := hp 0; simp [sat] at this

/-- **The standard model is Σ₁-sound about consistency**: it does not prove "`⊥` is
provable", i.e. `¬ Provable stdSys (box i ⊥)` (false at world `1`, which sees world
`0`).  This is the property the box-true model `trueSys` lacks. -/
theorem stdSys_sigma_sound (i : ℕ) : ¬ Provable stdSys (box i bot) := by
  intro hp; rw [provable_stdSys] at hp; have h1 := hp 1
  rw [sat_box] at h1; have := h1 0 (by norm_num); simp [sat] at this

/-! ## The trivial inconsistent theory -/

/-- The inconsistent theory that proves *every* formula. -/
def trivialSys : ProofSys Form where
  Proof := Form
  concl := id
  size := fun _ => 0

/-- The trivial theory proves everything. -/
theorem provable_trivialSys (a : Form) : Provable trivialSys a := ⟨a, rfl⟩

/-- The trivial theory is inconsistent. -/
theorem inconsistent_trivialSys : ¬ Consistent trivialSys :=
  fun h => h (provable_trivialSys bot)

end PhysicsConsistency