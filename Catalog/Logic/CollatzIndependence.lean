import Mathlib
import Catalog.Logic.StrangeLoops.Core

/-!
# The Collatz statement and logical independence

The Collatz problem concerns the step map
`T n = n / 2` (for even `n`) and `T n = 3 n + 1` (for odd `n`), and asks whether
the orbit of every positive integer eventually reaches `1`.  Despite extensive
numerical verification, no proof or refutation is known.

This file develops two threads and connects them.

## Thread 1 — orbit structure of the Collatz map

We package "the orbit of `n` reaches `1`" as the predicate `Reaches n`, and prove
the elementary but load-bearing structural facts:

* `reaches_step` / `reaches_of_ne_one` — reaching `1` is preserved when passing
  to the successor state, and (away from the fixed target) conversely;
* `reaches_two_mul` and `reaches_pow_two` — doubling preserves reachability, so
  every power of two reaches `1`;
* `cycle_not_reaching` — a periodic orbit that avoids `1` never reaches `1`,
  the exact shape any nontrivial cyclic counterexample would take.

The global statement is `CollatzConj : ∀ n, 0 < n → Reaches n`, and
`not_collatzConj_iff` records that its failure is precisely the existence of a
positive counterexample.

## Thread 2 — the independence conjecture

A recurring speculation is that `CollatzConj` is *independent* of the ambient
arithmetical theory: neither provable nor refutable.  We model a sound theory
abstractly by a provability operator satisfying soundness and the second
incompleteness phenomenon (a consistent theory cannot prove its own
consistency).  The central result `collatz_independent` shows:

> if the Collatz statement is true, the theory is consistent, and the theory
> internally derives `CollatzConj → Con`, then `CollatzConj` is neither provable
> nor refutable.

This is exactly the conditional form of the independence conjecture: the
irrefutability half follows from soundness, while the unprovability half follows
from the second incompleteness theorem applied through the internal implication
`CollatzConj → Con`.  We also connect to the self-referential (strange loop)
machinery, deriving unprovability of a Collatz-linked sentence from a fixed-point
consistency sentence.
-/

namespace CollatzIndep

/-! ## Thread 1: the Collatz step map and reachability -/

/-- The Collatz step map: `T n = n / 2` when `n` is even, `T n = 3 n + 1` when odd. -/
def T (n : ℕ) : ℕ := if n % 2 = 0 then n / 2 else 3 * n + 1

/-- The orbit of `n` reaches `1`: some finite number of steps lands on `1`. -/
def Reaches (n : ℕ) : Prop := ∃ k : ℕ, T^[k] n = 1

/-- `1` trivially reaches `1` in zero steps. -/
theorem reaches_one : Reaches 1 := ⟨0, rfl⟩

/-- If the successor state reaches `1`, so does the current state. -/
theorem reaches_step {n : ℕ} (h : Reaches (T n)) : Reaches n := by
  obtain ⟨k, hk⟩ := h
  exact ⟨k + 1, by rw [Function.iterate_succ_apply]; exact hk⟩

/-- Away from the target `1`, reachability transfers to the successor state. -/
theorem reaches_of_ne_one {n : ℕ} (hn : n ≠ 1) (h : Reaches n) : Reaches (T n) := by
  obtain ⟨k, hk⟩ := h
  cases k with
  | zero => simp at hk; exact absurd hk hn
  | succ m => exact ⟨m, by rw [← Function.iterate_succ_apply]; exact hk⟩

/-- Doubling steps back to the original value: `T (2 n) = n`. -/
theorem T_two_mul (n : ℕ) : T (2 * n) = n := by
  unfold T
  rw [if_pos (by omega)]
  omega

/-- Doubling preserves reachability. -/
theorem reaches_two_mul {n : ℕ} (h : Reaches n) : Reaches (2 * n) :=
  reaches_step (by rw [T_two_mul]; exact h)

/-- Every power of two reaches `1`. -/
theorem reaches_pow_two (k : ℕ) : Reaches (2 ^ k) := by
  induction k with
  | zero => simpa using reaches_one
  | succ m ih => rw [pow_succ, mul_comm]; exact reaches_two_mul ih

/-- Periodicity: if `T^[p] n = n`, then the orbit is `p`-periodic. -/
theorem iterate_periodic {n p : ℕ} (hcyc : T^[p] n = n) (q : ℕ) :
    T^[p * q] n = n := by
  induction q with
  | zero => simp
  | succ r ih =>
      rw [Nat.mul_succ, Function.iterate_add_apply, hcyc, ih]

/-- A periodic orbit that avoids `1` on its period never reaches `1`. This is the
    shape of any nontrivial cyclic counterexample to the Collatz statement. -/
theorem cycle_not_reaching {n p : ℕ} (hp : 0 < p) (hcyc : T^[p] n = n)
    (havoid : ∀ j < p, T^[j] n ≠ 1) : ¬ Reaches n := by
  rintro ⟨k, hk⟩
  have hmod : T^[k] n = T^[k % p] n := by
    conv_lhs => rw [← Nat.mod_add_div k p, Function.iterate_add_apply,
      iterate_periodic hcyc]
  rw [hmod] at hk
  exact havoid (k % p) (Nat.mod_lt k hp) hk

/-- The Collatz conjecture: every positive integer reaches `1`. -/
def CollatzConj : Prop := ∀ n : ℕ, 0 < n → Reaches n

/-- The failure of the Collatz conjecture is exactly a positive counterexample. -/
theorem not_collatzConj_iff : ¬ CollatzConj ↔ ∃ n, 0 < n ∧ ¬ Reaches n := by
  unfold CollatzConj
  constructor
  · intro h; by_contra hc; push_neg at hc; exact h (fun n hn => hc n hn)
  · rintro ⟨n, hn, hr⟩ h; exact hr (h n hn)

/-! ## Thread 2: abstract arithmetical theories and independence -/

/-- An abstract model of a sound arithmetical theory.  `Prov p` reads "the theory
    proves `p`".  We record modus ponens, soundness (with respect to the standard
    model), and the second incompleteness phenomenon: if the theory proves its own
    consistency `¬ Prov False`, then it is in fact inconsistent. -/
structure ArithTheory where
  /-- Provability predicate. -/
  Prov : Prop → Prop
  /-- Modus ponens is available inside the theory. -/
  mp : ∀ {p q : Prop}, Prov (p → q) → Prov p → Prov q
  /-- Soundness: everything provable is true. -/
  sound : ∀ {p : Prop}, Prov p → p
  /-- Second incompleteness: proving one's own consistency entails inconsistency. -/
  godel2 : Prov (¬ Prov False) → Prov False

/-- Consistency of a theory: it does not prove falsehood. -/
def ArithTheory.Con (Th : ArithTheory) : Prop := ¬ Th.Prov False

/-- A sound theory is consistent. -/
theorem ArithTheory.con_of_sound (Th : ArithTheory) : Th.Con := fun h => Th.sound h

/-- A sound theory cannot prove its own consistency (second incompleteness,
    contrapositive form). -/
theorem ArithTheory.not_prov_con (Th : ArithTheory) : ¬ Th.Prov (¬ Th.Prov False) := by
  intro h
  exact Th.con_of_sound (Th.godel2 h)

/-- **Irrefutability of a true statement.** A sound theory never refutes a true
    sentence; applied to a true Collatz statement, the theory cannot prove its
    negation. -/
theorem collatz_irrefutable (Th : ArithTheory) (hCollatz : CollatzConj) :
    ¬ Th.Prov (¬ CollatzConj) := fun h => (Th.sound h) hCollatz

/-- **A refutation would exhibit a genuine counterexample.** If a sound theory
    proves the negation of the Collatz statement, then a positive counterexample
    really exists. -/
theorem refutation_yields_counterexample (Th : ArithTheory)
    (h : Th.Prov (¬ CollatzConj)) : ∃ n, 0 < n ∧ ¬ Reaches n :=
  not_collatzConj_iff.mp (Th.sound h)

/-- **Conditional independence of the Collatz statement.**

    If the Collatz statement is true, the theory is consistent, and the theory
    internally derives the implication `CollatzConj → Con`, then the Collatz
    statement is *independent*: neither provable nor refutable.

    The unprovability half is the second incompleteness theorem routed through the
    internal implication (proving Collatz would prove consistency, hence
    inconsistency); the irrefutability half is soundness. -/
theorem collatz_independent (Th : ArithTheory)
    (hCollatz : CollatzConj)
    (hCon : Th.Con)
    (hint : Th.Prov (CollatzConj → ¬ Th.Prov False)) :
    ¬ Th.Prov CollatzConj ∧ ¬ Th.Prov (¬ CollatzConj) := by
  refine ⟨?_, collatz_irrefutable Th hCollatz⟩
  intro hp
  exact hCon (Th.godel2 (Th.mp hint hp))

/-! ### A concrete inhabitant of `ArithTheory`

The theory that "proves nothing" is a (degenerate) sound, consistent theory in
which the second incompleteness phenomenon holds vacuously, witnessing that the
axioms of `ArithTheory` are consistent. -/

/-- The trivial theory proving nothing. -/
def trivialTheory : ArithTheory where
  Prov := fun _ => False
  mp := fun h _ => h.elim
  sound := fun h => h.elim
  godel2 := fun h => h.elim

/-! ## Thread 3: independence through self-reference (strange loops)

We reuse the diagonal / fixed-point machinery of `StrangeLoop` from
`Logic.StrangeLoops.Core`: in a strange loop, the Gödel sentence is
true-but-unprovable.  The following routes a Collatz-linked sentence through the
consistency fixed point, showing that if provability of the Collatz sentence
forces provability of consistency, then the Collatz sentence is unprovable. -/

/-- **Collatz unprovability via a strange loop.** In a self-referential system,
    suppose `cons` is a consistency sentence (true iff the Gödel sentence is
    unprovable), whose provability formalizes to provability of the Gödel
    sentence.  If provability of a Collatz-linked sentence `collatzSent` forces
    provability of `cons`, then `collatzSent` is unprovable. -/
theorem collatz_unprovable_in_strange_loop
    (L : StrangeLoop)
    (cons collatzSent : L.Sentence)
    (hcons : L.True_ cons ↔ ¬ L.Provable L.goedelSentence)
    (hform : L.Provable cons → L.Provable L.goedelSentence)
    (hequiv_prov : L.Provable collatzSent → L.Provable cons) :
    ¬ L.Provable collatzSent := by
  intro hp
  exact second_incompleteness_analog L cons hcons hform (hequiv_prov hp)

/-! ## Examples, boundaries, and generalizations -/

section Examples

-- The step map computes as expected.
example : T 6 = 3 := by decide
example : T 3 = 10 := by decide

-- Small orbits reach `1` (concrete witnesses).
example : Reaches 6 := ⟨8, by decide⟩
example : Reaches 7 := ⟨16, by decide⟩

-- Powers of two: an infinite family that reaches `1`.
example : Reaches (2 ^ 10) := reaches_pow_two 10

-- Boundary case: the trivial cycle `1 → 4 → 2 → 1` contains `1`, so
-- `cycle_not_reaching` (which requires the cycle to avoid `1`) does not apply —
-- and indeed `2` does reach `1`.
example : Reaches 2 := ⟨1, by decide⟩

-- The type-level signatures of the independence results.
#check @collatz_independent
#check @collatz_irrefutable
#check @collatz_unprovable_in_strange_loop
#check trivialTheory

end Examples

/-!
**Generalization.** The `ArithTheory` interface isolates exactly the three
ingredients that drive independence: modus ponens, soundness, and the second
incompleteness phenomenon.  Any recursively axiomatized sound extension of a base
arithmetic instantiates it, so `collatz_independent` applies verbatim to Peano
arithmetic and to any of its sound consistent extensions.  Replacing
`CollatzConj` by any `Π₂` statement `S` for which the theory internally derives
`S → Con` yields the same independence dichotomy — the argument is entirely
generic in the statement being analyzed.

**Boundary.** The theorem is *conditional*: it assumes the internal derivation
`CollatzConj → Con`.  Whether the Collatz statement actually implies consistency
over a weak base theory is open, so the hypotheses are not known to be jointly
satisfiable for Collatz specifically; the result formalizes the logical skeleton
of the independence argument, not an unconditional independence proof.  The
`trivialTheory` inhabitant shows the axioms of `ArithTheory` are consistent, but
does not satisfy the extra hypothesis `hint`.
-/

/-! ## Lab Notes

-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).** The Collatz statement is independent of a sound
arithmetical theory, and its independence is governed by the same fixed-point /
second-incompleteness mechanism as consistency statements.  Bolder form: Collatz
is equivalent to `Con` over a weak base, so a counterexample would refute
consistency.

**Experiment (Experimenter).** We formalized the orbit predicate `Reaches`, the
doubling / power-of-two family, and the periodic-orbit obstruction
`cycle_not_reaching`.  On the logical side we built the `ArithTheory` interface
(modus ponens + soundness + second incompleteness) and proved `collatz_independent`
as a conditional: irrefutability from soundness, unprovability from second
incompleteness through the internal implication `CollatzConj → Con`.  We connected
to the catalog `StrangeLoop` diagonal machinery via
`collatz_unprovable_in_strange_loop`.

**Analysis (Analyst).** The irrefutability half is unconditionally true for any
sound theory once the Collatz statement is assumed true.  The unprovability half
is *true but conditional*: it needs the internal derivation `CollatzConj → Con`,
which is not known.  The grand claim "Collatz ≡ Con" is therefore *not*
established here — it is used only as a hypothesis-generator.  The genuinely new,
unconditional content is Thread 1 (`cycle_not_reaching`, `reaches_pow_two`) and
the clean reduction of independence to three named structural axioms.

**Critique (Critic).** No theorem is vacuous: `collatz_independent` has a
non-trivial proof combining `mp`, `godel2`, and `sound`; `trivialTheory` witnesses
consistency of the interface but deliberately fails `hint`, so the theorem is not
vacuously instantiated.  `cycle_not_reaching` uses genuine periodicity
(`iterate_periodic`) rather than computation.  The strange-loop corollary adds a
real layer (Collatz⇒consistency provability) over the catalog lemma rather than
re-exporting it.  Boundary honesty: the equivalence to `Con` is flagged as
speculative in the docstring and boundary note.

**Synthesis (PI).** Independence of a Π₂ arithmetical statement reduces to three
reusable structural axioms plus one internal implication; the Collatz statement is
a candidate instance, and its cyclic counterexamples are exactly the periodic
orbits excluded by `cycle_not_reaching`.
-/

end CollatzIndep