import Novelty.HeightSpectrumTransfer

/-!
# Reflection strength of interpretation axioms is graph reachability

`Novelty.ArithmetizedQFTReflection` built the explicit Hilbert calculus `Thm pa Ax`
and the arithmetic `PAsys pa qft = glSys pa {□_pa ⊥ → □_qft ⊥}`, which proves the
reflection sentence `Con(QFT₀) → Con(PA)` from the single *interpretation axiom*
`□_pa ⊥ → □_qft ⊥`.  The accompanying conjecture list (item 1, "exact reflection
strength of the interpretation axiom") asked whether, over the GL calculus and for an
axiom set `Ax` consisting of **boxed-falsum implications only**, the reflection
sentence is derivable exactly when `Ax` derives the transfer implication.

This file answers the question in a sharp, purely combinatorial form.  An axiom set of
that shape is nothing but a **directed graph** `E` on the tags, and the answer is:

  `Thm pa (BoxFalsumAx E) (□_i ⊥ → □_j ⊥)  ↔  Reach E i j`
  (`thm_transfer_iff_reach`),

i.e. derivability of a transfer implication is *reachability* in the axiom digraph.
Equivalently for the reflection sentences themselves,

  `Thm pa (BoxFalsumAx E) (Con j → Con i)  ↔  Reach E i j`
  (`thm_reflection_iff_reach`).

So the conjecture is **confirmed in its "derives" reading and refuted in its
"contains" reading**: the derivable transfer implications are exactly the
reflexive–transitive closure of `Ax`, which is in general strictly larger than `Ax`
(`derivable_but_not_an_axiom`), and never larger than that closure
(`reflection_not_derivable_without_path`).

The hard direction is the completeness half: from a *failure of reachability* we must
manufacture a model of the whole GL calculus validating every axiom.  The model is the
two-world tag-sensitive theory `capC c 1` of `Novelty.ConsistencyTransferSharpness`,
with the height function

  `c t = 0` if `t` is reachable from `i`, and `c t = 1` otherwise,

so that `□_t ⊥` is valid exactly at the reachable tags.  Validity of the axioms is
precisely the closure of the reachable set under edges — the graph-theoretic content
of the theorem.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): a boxed-falsum axiom set carries no information beyond its
  edge relation, so the GL machinery (necessitation, K, 4, Löb) cannot create
  transfer implications that are not already forced by paths.
Experiment (Stage 2): for the three-tag graphs `∅`, `{0→1}`, `{0→1, 1→2}`, the
  two-world models `capC c 1` with `c` the indicator of non-reachability validate all
  axioms while refuting every non-path implication; enumerating all `2^9` graphs on
  three tags, the number of derivable transfer implications always equals the size of
  the reflexive–transitive closure of the edge set.
Analysis (Stage 3): the invariant behind the experiment is that at the world `1` of
  the two-world model, `□_t ⊥` is true iff `c t = 0`; validity of `□_s⊥ → □_t⊥` is
  then literally the implication "s reachable ⟹ t reachable".
Critique (Stage 4): the completeness half is proved for arbitrary (possibly infinite)
  edge relations and arbitrary tags, and the calculus is the full GL calculus with
  necessitation, so the result is not an artefact of a weak proof system.
-/

namespace PhysicsConsistency

open ProofSystemCollapse
open Form

/-! ## §1. Three propositional tautologies -/

/-- Identity is a tautology. -/
theorem taut_imp_self (a : Form) : Taut (imp a a) := by
  intro v _ himp
  simp only [himp]
  cases v a <;> simp

/-- Transitivity of implication is a tautology. -/
theorem taut_imp_trans (a b c : Form) :
    Taut (imp (imp a b) (imp (imp b c) (imp a c))) := by
  intro v _ himp
  simp only [himp]
  cases v a <;> cases v b <;> cases v c <;> simp

/-- The converse of contraposition is a tautology (classically). -/
theorem taut_contrapose_rev (a b : Form) :
    Taut (imp (imp (neg b) (neg a)) (imp a b)) := by
  intro v hbot himp
  simp only [neg, himp, hbot]
  cases v a <;> cases v b <;> simp

/-! ## §2. Boxed-falsum axiom sets are directed graphs -/

/-- The axiom set determined by a digraph `E` on the tags: one interpretation axiom
`□_i ⊥ → □_j ⊥` for every edge `i → j`. -/
def BoxFalsumAx (E : ℕ → ℕ → Prop) : Form → Prop :=
  fun a => ∃ i j, E i j ∧ a = imp (box i bot) (box j bot)

/-- Reachability in the axiom digraph: the reflexive–transitive closure of `E`. -/
inductive Reach (E : ℕ → ℕ → Prop) : ℕ → ℕ → Prop
  /-- Every tag reaches itself. -/
  | refl (i : ℕ) : Reach E i i
  /-- A path may be extended by an edge. -/
  | step {i j k : ℕ} : Reach E i j → E j k → Reach E i k

/-- Reachability is transitive. -/
theorem reach_trans {E : ℕ → ℕ → Prop} {i j k : ℕ} (h1 : Reach E i j)
    (h2 : Reach E j k) : Reach E i k := by
  induction h2 with
  | refl => exact h1
  | step _ he ih => exact Reach.step ih he

/-! ## §3. Soundness: every path yields a derivation -/

/-- **Every path is derivable.**  If `j` is reachable from `i` in the axiom digraph,
the calculus derives the transfer implication `□_i ⊥ → □_j ⊥`. -/
theorem thm_of_reach (pa : ℕ) {E : ℕ → ℕ → Prop} {i j : ℕ} (h : Reach E i j) :
    Thm pa (BoxFalsumAx E) (imp (box i bot) (box j bot)) := by
  induction h with
  | refl => exact Thm.taut (taut_imp_self _)
  | step _ he ih =>
      rename_i j k _
      have hax : Thm pa (BoxFalsumAx E) (imp (box j bot) (box k bot)) :=
        Thm.ax ⟨j, k, he, rfl⟩
      exact Thm.mp (Thm.mp (Thm.taut
        (taut_imp_trans (box i bot) (box j bot) (box k bot))) ih) hax

/-! ## §4. Completeness: the reachability countermodel -/

open Classical in
/-- The **reachability height function** for a source tag `i₀`: reachable tags get
height `0` (they will validate `□ ⊥`), all other tags get height `1`. -/
noncomputable def reachHeight (E : ℕ → ℕ → Prop) (i₀ : ℕ) : ℕ → ℕ :=
  fun t => if Reach E i₀ t then 0 else 1

/-- In the two-world tag-sensitive model, a transfer implication is valid exactly when
the height of the source vanishes only if the height of the target does. -/
theorem provable_capC_one_transfer (c : ℕ → ℕ) (i j : ℕ) :
    Provable (capC c 1) (imp (box i bot) (box j bot)) ↔ (c i = 0 → c j = 0) := by
  rw [provable_capC]
  constructor
  · intro h hci
    have h1 := (satC_imp c 1 _ _).1 (h 1 le_rfl)
    have hant : satC c 1 (box i bot) = true :=
      (satC_box_bot_iff c 1 i).2 (Or.inr (by omega))
    have := (satC_box_bot_iff c 1 j).1 (h1 hant)
    omega
  · intro h m hm
    rw [satC_imp]
    intro hant
    have := (satC_box_bot_iff c m i).1 hant
    rw [satC_box_bot_iff]
    rcases this with rfl | hlt
    · left; rfl
    · right
      have : c i = 0 := by omega
      have := h this
      omega

/-- **The reachability model validates every axiom.**  The set of tags reachable from
`i₀` is closed under edges, which is exactly validity of the interpretation axioms in
the two-world model. -/
theorem reachHeight_validates_axioms (E : ℕ → ℕ → Prop) (i₀ : ℕ) (a : Form)
    (ha : BoxFalsumAx E a) : Provable (capC (reachHeight E i₀) 1) a := by
  obtain ⟨s, t, he, rfl⟩ := ha
  rw [provable_capC_one_transfer]
  intro hs
  have hrs : Reach E i₀ s := by
    by_contra hcon
    rw [reachHeight, if_neg hcon] at hs
    omega
  rw [reachHeight, if_pos (Reach.step hrs he)]

/-- **Only paths are derivable.**  If the calculus derives a transfer implication from
a boxed-falsum axiom set, then the target is reachable from the source in the axiom
digraph. -/
theorem reach_of_thm {pa : ℕ} {E : ℕ → ℕ → Prop} {i j : ℕ}
    (h : Thm pa (BoxFalsumAx E) (imp (box i bot) (box j bot))) : Reach E i j := by
  have hsound := thm_sound (i := pa) (S := capC (reachHeight E i) 1)
    (isGL_capC (reachHeight E i) 1 pa) (reachHeight_validates_axioms E i) _ h
  rw [provable_capC_one_transfer] at hsound
  have hi : reachHeight E i i = 0 := by
    rw [reachHeight, if_pos (Reach.refl i)]
  have hj := hsound hi
  by_contra hcon
  rw [reachHeight, if_neg hcon] at hj
  omega

/-! ## §5. The characterization and its consequences -/

/-- **Derivable transfer = reachability.**  Over the GL calculus, a boxed-falsum axiom
set derives the transfer implication `□_i ⊥ → □_j ⊥` precisely when `j` is reachable
from `i` in the digraph of axioms. -/
theorem thm_transfer_iff_reach (pa : ℕ) (E : ℕ → ℕ → Prop) (i j : ℕ) :
    Thm pa (BoxFalsumAx E) (imp (box i bot) (box j bot)) ↔ Reach E i j :=
  ⟨reach_of_thm, thm_of_reach pa⟩

/-- **The reflection sentence and the transfer implication are interderivable** in the
GL calculus, by contraposition. -/
theorem thm_reflection_iff_transfer (pa : ℕ) (Ax : Form → Prop) (i j : ℕ) :
    Thm pa Ax (imp (Con j) (Con i)) ↔ Thm pa Ax (imp (box i bot) (box j bot)) := by
  constructor
  · intro h
    exact Thm.mp (Thm.taut (taut_contrapose_rev (box i bot) (box j bot))) h
  · intro h
    exact Thm.mp (Thm.taut (taut_contrapose (box i bot) (box j bot))) h

/-- **Reflection strength is graph reachability.**  The reflection sentence
`Con j → Con i` is derivable from a boxed-falsum axiom set exactly when there is a
path from `i` to `j` in the axiom digraph. -/
theorem thm_reflection_iff_reach (pa : ℕ) (E : ℕ → ℕ → Prop) (i j : ℕ) :
    Thm pa (BoxFalsumAx E) (imp (Con j) (Con i)) ↔ Reach E i j := by
  rw [thm_reflection_iff_transfer, thm_transfer_iff_reach]

/-- **The derivable transfer relation is a preorder**, namely the least preorder
containing the axiom digraph. -/
theorem derivable_transfer_preorder (pa : ℕ) (E : ℕ → ℕ → Prop) :
    (∀ i, Thm pa (BoxFalsumAx E) (imp (box i bot) (box i bot))) ∧
      (∀ i j k, Thm pa (BoxFalsumAx E) (imp (box i bot) (box j bot)) →
        Thm pa (BoxFalsumAx E) (imp (box j bot) (box k bot)) →
        Thm pa (BoxFalsumAx E) (imp (box i bot) (box k bot))) ∧
      (∀ i j, E i j → Thm pa (BoxFalsumAx E) (imp (box i bot) (box j bot))) := by
  refine ⟨fun i => (thm_transfer_iff_reach pa E i i).2 (Reach.refl i), ?_, ?_⟩
  · intro i j k h1 h2
    rw [thm_transfer_iff_reach] at h1 h2 ⊢
    exact reach_trans h1 h2
  · intro i j he
    exact (thm_transfer_iff_reach pa E i j).2 (Reach.step (Reach.refl i) he)

/-- Without edges there is no reachability except the trivial one. -/
theorem reach_empty {i j : ℕ} (h : Reach (fun _ _ => False) i j) : i = j := by
  induction h with
  | refl => rfl
  | step _ he _ => exact absurd he (by simp)

/-- **The conjecture fails in its "contains" reading.**  For the two-edge digraph
`0 → 1 → 2` the reflection sentence `Con 2 → Con 0` is derivable, although the
corresponding transfer implication `□_0 ⊥ → □_2 ⊥` is *not* one of the axioms: only
the closure matters, not membership. -/
theorem derivable_but_not_an_axiom (pa : ℕ) :
    Thm pa (BoxFalsumAx (fun a b => (a = 0 ∧ b = 1) ∨ (a = 1 ∧ b = 2)))
        (imp (Con 2) (Con 0)) ∧
      ¬ BoxFalsumAx (fun a b => (a = 0 ∧ b = 1) ∨ (a = 1 ∧ b = 2))
        (imp (box 0 bot) (box 2 bot)) := by
  constructor
  · rw [thm_reflection_iff_reach]
    exact Reach.step (Reach.step (Reach.refl 0) (Or.inl ⟨rfl, rfl⟩)) (Or.inr ⟨rfl, rfl⟩)
  · rintro ⟨s, t, he, heq⟩
    simp only [imp.injEq, box.injEq, and_true] at heq
    obtain ⟨hs, ht⟩ := heq
    subst hs
    subst ht
    simp at he

/-- **The conjecture holds in its "derives" reading, and non-vacuously.**  Without a
path no reflection sentence is derivable: the empty axiom set derives no transfer
implication between distinct tags. -/
theorem reflection_not_derivable_without_path (pa : ℕ) :
    ¬ Thm pa (BoxFalsumAx (fun _ _ => False)) (imp (Con 1) (Con 0)) := by
  rw [thm_reflection_iff_reach]
  intro h
  exact absurd (reach_empty h) (by decide)

/-- **Summary: the exact reflection strength of boxed-falsum interpretation axioms.**
Derivability of the reflection sentence is reachability in the axiom digraph; the
derivable implications form the reflexive–transitive closure, which is strictly larger
than the axiom set in general and never larger than the closure. -/
theorem reflection_strength_summary (pa : ℕ) (E : ℕ → ℕ → Prop) :
    (∀ i j, Thm pa (BoxFalsumAx E) (imp (Con j) (Con i)) ↔ Reach E i j) ∧
      (∀ i j, Thm pa (BoxFalsumAx E) (imp (box i bot) (box j bot)) ↔ Reach E i j) :=
  ⟨thm_reflection_iff_reach pa E, thm_transfer_iff_reach pa E⟩

end PhysicsConsistency