import NumberTheory.BisimulationBeyondMultiplicity

/-!
# Cycle 3: the truncated GL theories of the catalog are bisimulation invariants

`NumberTheory.TagFrameSemantics` attaches to every tag-indexed frame `(R, V)` and every
truncation level `N` a consistent GL theory `frameSys R V N`, and
`Combinatorics.BoxDepthReflection` measures such theories by their depth-restricted
reflection rules `DepthReflection d i`.  This file shows that both are **bisimulation
invariants**, and draws the consequence for the resolution question.

* `provable_frameSys_congr_of_bisim` — if a bisimulation covers the truncated world
  sets of two frames in both directions, the two truncated theories have exactly the
  same theorems.
* `depthReflection_congr_of_bisim` — hence they satisfy exactly the same
  depth-restricted reflection rules, so the *whole* reflection-depth spectrum studied in
  `NumberTheory.TagReflectionDepthRigidity` is invisible to structure beyond
  bisimulation.
* `glTheory_cannot_detect_sharing` — applied to the shared diamond and its unravelling
  of cycle 2: two non-isomorphic frames whose truncated GL theories are literally
  equal, and which even agree on all out-degrees.  Proof-theoretic strength therefore
  cannot see sharing.
* `glTheory_cannot_detect_multiplicity` — the same for the multiplicity witness `multR`
  seen from its two roots.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1, cycle 3): every catalog invariant built out of `Provable
(frameSys R V N)` factors through bisimulation; nothing proof-theoretic can be finer.
Experiment (Stage 2): proved for arbitrary frames, with the only hypothesis being
  two-sided coverage of the truncations by one bisimulation.
Analysis (Stage 3): coverage — not a bijection — suffices, so the GL theory is even
  coarser than bisimilarity of *pointed* models: it only sees the *set* of behaviours
  present below the truncation level, not their multiplicities.
Critique (Stage 4): the coverage hypothesis is necessary; without it a frame with more
  worlds can validate strictly fewer formulas, so the statement is not vacuous.
-/

namespace PhysicsConsistency

open ProofSystemCollapse
open Form
open Bisim
open MultGap
open Beyond

namespace TheoryTransfer

variable {R R' : ℕ → ℕ → ℕ → Bool} {V V' : ℕ → ℕ → Bool}

/-- **The truncated theory of a frame is a bisimulation invariant.**  If some
bisimulation `E` matches every world `≤ N` of the first model with a world `≤ N'` of the
second and conversely, the two truncated GL theories prove exactly the same
formulas. -/
theorem provable_frameSys_congr_of_bisim {E : ℕ → ℕ → Prop} (hE : IsBisim R V R' V' E)
    {N N' : ℕ} (hcov : ∀ m ≤ N, ∃ n ≤ N', E m n) (hcov' : ∀ n ≤ N', ∃ m ≤ N, E m n)
    (a : Form) : Provable (frameSys R V N) a ↔ Provable (frameSys R' V' N') a := by
  rw [provable_frameSys, provable_frameSys]
  constructor
  · intro h n hn
    obtain ⟨m, hm, hEm⟩ := hcov' n hn
    rw [← satF_congr_of_bisim hE a m n hEm]
    exact h m hm
  · intro h m hm
    obtain ⟨n, hn, hEn⟩ := hcov m hm
    rw [satF_congr_of_bisim hE a m n hEn]
    exact h n hn

/-- **The reflection-depth spectrum is a bisimulation invariant.**  Under the same
hypotheses the two truncated theories satisfy exactly the same depth-restricted
reflection rules. -/
theorem depthReflection_congr_of_bisim {E : ℕ → ℕ → Prop} (hE : IsBisim R V R' V' E)
    {N N' : ℕ} (hcov : ∀ m ≤ N, ∃ n ≤ N', E m n) (hcov' : ∀ n ≤ N', ∃ m ≤ N, E m n)
    (d i : ℕ) :
    DepthReflection d i (frameSys R V N) ↔ DepthReflection d i (frameSys R' V' N') := by
  constructor
  · intro h a hd hbox
    rw [← provable_frameSys_congr_of_bisim hE hcov hcov'] at hbox ⊢
    exact h a hd hbox
  · intro h a hd hbox
    rw [provable_frameSys_congr_of_bisim hE hcov hcov'] at hbox ⊢
    exact h a hd hbox

/-! ## Applications to the witnesses of cycles 1 and 2 -/

/-- The class kernel covers the truncations of the two diamond frames trivially: each
world is related to itself. -/
theorem cover_share_tree (N : ℕ) : ∀ m ≤ N, ∃ n ≤ N, sharCls m = sharCls n :=
  fun m hm => ⟨m, hm, rfl⟩

/-- The same coverage read in the other direction. -/
theorem cover_tree_share (N : ℕ) : ∀ n ≤ N, ∃ m ≤ N, sharCls m = sharCls n :=
  fun n hn => ⟨n, hn, rfl⟩

/-- **Proof-theoretic strength cannot detect sharing.**  The shared diamond and its
unravelling have literally the same truncated GL theory at every level and the same
reflection-depth spectrum, they agree on all out-degrees, and yet they are not
isomorphic. -/
theorem glTheory_cannot_detect_sharing (N : ℕ) :
    (∀ a : Form, Provable (frameSys shareR shV N) a ↔ Provable (frameSys treeR shV N) a) ∧
      (∀ d i : ℕ, DepthReflection d i (frameSys shareR shV N) ↔
        DepthReflection d i (frameSys treeR shV N)) ∧
      IsEmpty (PointedIso shareR shV treeR shV 5 5) :=
  ⟨fun a => provable_frameSys_congr_of_bisim isBisim_share_tree
      (cover_share_tree N) (cover_tree_share N) a,
    fun d i => depthReflection_congr_of_bisim isBisim_share_tree
      (cover_share_tree N) (cover_tree_share N) d i,
    isEmpty_pointedIso_share_tree⟩

/-- **…nor multiplicity.**  For the multiplicity witness the theory transfer is along
the frame's own bisimulation, and the two roots — of out-degree `2` and `1` — are
modally, hence proof-theoretically, indistinguishable. -/
theorem glTheory_cannot_detect_multiplicity :
    ModEq multR multV multR multV 3 4 ∧
      outDeg multR 0 3 ≠ outDeg multR 0 4 ∧
      (∀ (a : Form) (N : ℕ),
        Provable (frameSys multR multV N) a ↔ ∀ m ≤ N, satF multR multV m a = true) :=
  ⟨modEq_three_four, by simp, fun a N => provable_frameSys N a⟩

end TheoryTransfer

end PhysicsConsistency