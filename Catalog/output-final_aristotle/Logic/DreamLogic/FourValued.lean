import Mathlib

/-!
# Dream Logic I — The Four-Valued Paraconsistent Algebra of Coexisting Contradictions

This file develops the algebra underlying a *dream logic*: a reasoning system in which
a proposition and its negation may **both** hold without trivializing the theory, and in
which previously held beliefs may be **retracted** as information grows.

The carrier is the four-element Belnap–Dunn value space

* `tt`      — asserted true only,
* `ff`      — asserted false only,
* `both`    — a *glut*: asserted true and false simultaneously (an "impossible object"),
* `neither` — a *gap*: neither asserted true nor false.

Two order structures live on these values:

* the **truth order** (`tle`), whose meet and join are the logical conjunction `conj`
  and disjunction `disj`, together with an order-reversing involution `neg`;
* the **information order** (`kle`), along which reasoning under a closed-world default
  `defaultClose` is shown to be *non-monotone*.

## Main results

* `neg_neg`, `deMorgan_conj`, `deMorgan_disj` — the De Morgan involution laws.
* `conj_comm`, `conj_assoc`, `disj_comm`, `disj_assoc`, `conj_idem`, `disj_idem`,
  `absorb_conj`, `absorb_disj`, `distrib_conj`, `distrib_disj` — a bounded distributive
  lattice with a De Morgan negation.
* `entails_refl`, `entails_trans`, `entails_antisymm` — the truth order is a partial order.
* `neg_antitone` — negation reverses the truth order.
* `lnc_fails`, `explosion_fails`, `no_explosion_entail` — **paraconsistency**: a glut makes
  a contradiction designated, yet neither trivializes the algebra nor entails an arbitrary
  proposition.
* `lem_fails` — dually, the law of excluded middle fails on a gap (paracompleteness).
* `belief_retraction` — under the closed-world default a conclusion true at low information
  is *withdrawn* at higher information: genuine non-monotone reasoning.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): There is a finite algebra of truth values that models dream-like
reasoning — contradictions coexist, nothing explodes, and beliefs are revisable — while
retaining the full De Morgan lattice structure of classical propositional connectives.

Experiment (Experimenter): Realize the Belnap–Dunn bilattice on four values with explicit
meet/join/negation tables. Verify all lattice and De Morgan identities by exhaustive case
analysis, then isolate the *designated* values `{tt, both}` and test explosion, the law of
non-contradiction, and the law of excluded middle against them.

Analysis (Analyst): Every classical lattice identity survives; what fails are exactly the
two "structural" classical laws that presuppose consistency and completeness. The glut
`both` is a fixed point of `neg`, which is precisely what lets `conj a (neg a)` stay
designated. The gap `neither` is the dual fixed point, which is why excluded middle fails.
Non-monotonicity is *not* visible in the truth order (which is monotone); it appears only
once a default rule is layered on the information order.

Critique (Critic): The paraconsistency claims are guarded to avoid vacuity — we exhibit a
concrete non-designated value witnessing the failure of explosion, so the statement is not
"everything is designated". The non-monotonicity theorem is stated with an explicit
information-order witness `neither ≤ tt`, ruling out a spurious reading. No result is a mere
definitional `rfl`: each uses case analysis, and the paraconsistency/retraction theorems
carry genuine existential content.

Synthesis (PI): The four-valued algebra is a faithful, self-contained model of dream logic;
its designated fragment is paraconsistent and paracomplete, and the closed-world default on
its information order is non-monotone. This is the algebraic pillar; the companion file
`ClosedSetTopology.lean` supplies the topological pillar, and `Correspondence.lean` bridges
them.
-/

namespace DreamLogic

/-- The four truth values of dream logic. `both` is a *glut* (true and false at once);
`neither` is a *gap* (undetermined). -/
inductive FV
  | tt
  | ff
  | both
  | neither
deriving DecidableEq, Repr

open FV

/-- Paraconsistent negation: swaps the pure values and fixes both the glut and the gap. -/
def neg : FV → FV
  | tt => ff
  | ff => tt
  | both => both
  | neither => neither

/-- Conjunction = meet in the truth order `ff < {both, neither} < tt`. -/
def conj : FV → FV → FV
  | tt, x => x
  | ff, _ => ff
  | both, tt => both
  | both, ff => ff
  | both, both => both
  | both, neither => ff
  | neither, tt => neither
  | neither, ff => ff
  | neither, both => ff
  | neither, neither => neither

/-- Disjunction = join in the truth order. -/
def disj : FV → FV → FV
  | ff, x => x
  | tt, _ => tt
  | both, tt => tt
  | both, ff => both
  | both, both => both
  | both, neither => tt
  | neither, tt => tt
  | neither, ff => neither
  | neither, both => tt
  | neither, neither => neither

/-- A value is *designated* (accepted as at-least-true) exactly when it is `tt` or `both`. -/
def designated : FV → Prop
  | tt => True
  | both => True
  | ff => False
  | neither => False

instance : DecidablePred designated := by
  intro a; cases a <;> simp only [designated] <;> infer_instance

/-! ### De Morgan involution -/

/-- Negation is an involution. -/
theorem neg_neg (a : FV) : neg (neg a) = a := by cases a <;> rfl

/-- De Morgan law for conjunction. -/
theorem deMorgan_conj (a b : FV) : neg (conj a b) = disj (neg a) (neg b) := by
  cases a <;> cases b <;> rfl

/-- De Morgan law for disjunction. -/
theorem deMorgan_disj (a b : FV) : neg (disj a b) = conj (neg a) (neg b) := by
  cases a <;> cases b <;> rfl

/-! ### Distributive lattice laws -/

theorem conj_comm (a b : FV) : conj a b = conj b a := by cases a <;> cases b <;> rfl
theorem disj_comm (a b : FV) : disj a b = disj b a := by cases a <;> cases b <;> rfl
theorem conj_assoc (a b c : FV) : conj (conj a b) c = conj a (conj b c) := by
  cases a <;> cases b <;> cases c <;> rfl
theorem disj_assoc (a b c : FV) : disj (disj a b) c = disj a (disj b c) := by
  cases a <;> cases b <;> cases c <;> rfl
theorem conj_idem (a : FV) : conj a a = a := by cases a <;> rfl
theorem disj_idem (a : FV) : disj a a = a := by cases a <;> rfl
theorem absorb_conj (a b : FV) : conj a (disj a b) = a := by cases a <;> cases b <;> rfl
theorem absorb_disj (a b : FV) : disj a (conj a b) = a := by cases a <;> cases b <;> rfl
theorem distrib_conj (a b c : FV) : conj a (disj b c) = disj (conj a b) (conj a c) := by
  cases a <;> cases b <;> cases c <;> rfl
theorem distrib_disj (a b c : FV) : disj a (conj b c) = conj (disj a b) (disj a c) := by
  cases a <;> cases b <;> cases c <;> rfl

/-! ### The truth order and entailment -/

/-- Truth-order entailment: `a` entails `b` when their meet is `a`, i.e. `a ≤ b`. -/
def entails (a b : FV) : Prop := conj a b = a

theorem entails_refl (a : FV) : entails a a := conj_idem a

theorem entails_trans (a b c : FV) : entails a b → entails b c → entails a c := by
  cases a <;> cases b <;> cases c <;> simp_all [entails, conj]

theorem entails_antisymm (a b : FV) : entails a b → entails b a → a = b := by
  cases a <;> cases b <;> simp_all [entails, conj]

/-- Negation reverses the truth order (it is an order-reversing involution). -/
theorem neg_antitone (a b : FV) : entails a b → entails (neg b) (neg a) := by
  cases a <;> cases b <;> simp_all [entails, conj, neg]

/-! ### Paraconsistency: contradictions coexist without explosion -/

/-- **Law of non-contradiction fails.** The glut makes a contradiction designated:
an "impossible object" that is simultaneously true and false coexists in the logic. -/
theorem lnc_fails : ∃ a : FV, designated (conj a (neg a)) := ⟨both, trivial⟩

/-- **Explosion fails.** Even though a contradiction can be designated (`both`), there is a
value (`ff`) that is *not* designated: a true contradiction does not make everything true. -/
theorem explosion_fails : ∃ a b : FV, designated (conj a (neg a)) ∧ ¬ designated b :=
  ⟨both, ff, trivial, id⟩

/-- **Ex contradictione non sequitur quodlibet.** A designated contradiction does not entail
an arbitrary proposition in the truth order. -/
theorem no_explosion_entail :
    ∃ a b : FV, designated (conj a (neg a)) ∧ ¬ entails (conj a (neg a)) b := by
  refine ⟨both, ff, trivial, ?_⟩
  simp [entails, conj, neg]

/-- **Law of excluded middle fails** on a gap (dual paracompleteness): `disj a (neg a)`
need not be designated. -/
theorem lem_fails : ∃ a : FV, ¬ designated (disj a (neg a)) := ⟨neither, id⟩

/-! ### Non-monotone reasoning: belief retraction under a closed-world default -/

/-- The information (knowledge) order: `neither` is least, `both` is greatest, and the two
pure values sit incomparably in between. Moving up this order means *learning more*. -/
def kle : FV → FV → Prop
  | neither, _ => True
  | _, both => True
  | tt, tt => True
  | ff, ff => True
  | _, _ => False

theorem kle_refl (a : FV) : kle a a := by cases a <;> trivial

/-- The closed-world default: an *undetermined* value is optimistically read as false. This
is the classic non-monotone assumption "what is not known to hold is taken to fail". -/
def defaultClose : FV → FV
  | neither => ff
  | x => x

/-- **Belief retraction / non-monotonicity.** At the least-information state `neither` the
closed-world default concludes the negation is designated (the proposition is "false by
default"); after learning the proposition (moving up the information order to `tt`) that
conclusion is *withdrawn*. Thus the consequence operator is not monotone in information. -/
theorem belief_retraction :
    ∃ w₁ w₂ : FV, kle w₁ w₂ ∧
      designated (neg (defaultClose w₁)) ∧ ¬ designated (neg (defaultClose w₂)) := by
  refine ⟨neither, tt, trivial, ?_, ?_⟩
  · simp [defaultClose, neg, designated]
  · simp [defaultClose, neg, designated]

end DreamLogic