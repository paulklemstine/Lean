import NumberTheory.BisimulationDepthHierarchy

/-!
# Cycle 2: what actually closes the bisimulation/isomorphism gap

Cycle 1 (`NumberTheory.BisimulationResolution`,
`NumberTheory.BisimulationMultiplicityGap`,
`NumberTheory.BisimulationDepthHierarchy`) established

```
  DepthInv 0 ⊊ ⋯ ⊊ ModalInv = BisimInv ⊊ IsoInv
```

and separated the top gap with the *multiplicity-sensitive* observation `outDeg`.
The mission conjecture claims that the gap "is characterized by multiplicity-sensitive
observations".  This file tests that claim adversarially and finds it **too
optimistic**, while identifying a language that does close the gap.

* §1 `Bisimilar` is a groupoid-style equivalence: reflexive, symmetric, transitive
  (composition of bisimulations).
* §2 **Nominals close the gap completely.**  If the valuation is the nominal one
  (`nomV m p = (m = p)`, one atom per world), modal equivalence forces *equality* of
  worlds (`eq_of_modEq_nominal`), hence an isomorphism (`pointedIso_of_modEq_nominal`).
  So the gap is an artefact of atom-poor valuations, and world-identifying atoms — the
  extreme multiplicity-sensitive observations — collapse it.
* §3 **Multiplicity alone does not close it.**  `shareR` (a diamond whose two branches
  are *shared*: `5 → 3, 4`, `3 → 1`, `4 → 1`) and `treeR` (its unravelling
  `5 → 3, 4`, `3 → 1`, `4 → 2`) are bisimilar (`bisimilar_share_tree`) *and* have equal
  out-degrees at every pair of related worlds (`outDeg_share_eq_tree`), yet they are
  not isomorphic (`isEmpty_pointedIso_share_tree`): the models have `4` and `5`
  reachable worlds respectively.
* §4 `multiplicity_does_not_close_the_gap` — the refined verdict: counting successors
  is *strictly weaker* than naming worlds; the residual invisible structure is
  **sharing** (identification of behaviourally equal successors), not multiplicity.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1, cycle 2): "the gap is characterized by multiplicity-sensitive
  observations" — i.e. bisimulation + out-degree data should recover isomorphism.
Experiment (Stage 2): the shared diamond versus its unravelling refutes it; both have
  root degree 2, branch degree 1, leaf degree 0 at every related pair.
Analysis (Stage 3): the surviving statement is a *two-step* hierarchy —
  bisimulation ⊊ bisimulation + multiplicity ⊊ isomorphism — with the second gap
  measured by sharing (the number of reachable worlds), and nominal atoms collapsing
  everything.
Critique (Stage 4): the non-isomorphism proof is a pigeonhole on the two leaves of the
  tree, using only injectivity and forward/backward edge preservation of `PointedIso`,
  so it is robust to weakening the isomorphism notion.
-/

namespace PhysicsConsistency

open ProofSystemCollapse
open Form
open Bisim
open MultGap

namespace Beyond

variable {R R' R'' : ℕ → ℕ → ℕ → Bool} {V V' V'' : ℕ → ℕ → Bool}

/-! ## §1. Bisimilarity is an equivalence -/

theorem bisimilar_refl (R : ℕ → ℕ → ℕ → Bool) (V : ℕ → ℕ → Bool) (m : ℕ) :
    Bisimilar R V R V m m := by
  refine ⟨Eq, ⟨?_, ?_, ?_⟩, rfl⟩
  · rintro a b rfl p; rfl
  · rintro a b rfl i a' ha'; exact ⟨a', ha', rfl⟩
  · rintro a b rfl i b' hb'; exact ⟨b', hb', rfl⟩

theorem bisimilar_symm {m n : ℕ} (h : Bisimilar R V R' V' m n) : Bisimilar R' V' R V n m := by
  obtain ⟨E, ⟨hatom, hforth, hback⟩, hmn⟩ := h
  exact ⟨fun a b => E b a, ⟨fun a b hab p => (hatom b a hab p).symm,
    fun a b hab i a' ha' => hback b a hab i a' ha',
    fun a b hab i b' hb' => hforth b a hab i b' hb'⟩, hmn⟩

theorem bisimilar_trans {m n k : ℕ} (h1 : Bisimilar R V R' V' m n)
    (h2 : Bisimilar R' V' R'' V'' n k) : Bisimilar R V R'' V'' m k := by
  obtain ⟨E, ⟨ha1, hf1, hb1⟩, hmn⟩ := h1
  obtain ⟨F, ⟨ha2, hf2, hb2⟩, hnk⟩ := h2
  refine ⟨fun a c => ∃ b, E a b ∧ F b c, ⟨?_, ?_, ?_⟩, ⟨n, hmn, hnk⟩⟩
  · rintro a c ⟨b, hab, hbc⟩ p; exact (ha1 a b hab p).trans (ha2 b c hbc p)
  · rintro a c ⟨b, hab, hbc⟩ i a' ha'
    obtain ⟨b', hb', hEb⟩ := hf1 a b hab i a' ha'
    obtain ⟨c', hc', hFc⟩ := hf2 b c hbc i b' hb'
    exact ⟨c', hc', b', hEb, hFc⟩
  · rintro a c ⟨b, hab, hbc⟩ i c' hc'
    obtain ⟨b', hb', hFb⟩ := hb2 b c hbc i c' hc'
    obtain ⟨a', ha', hEa⟩ := hb1 a b hab i b' hb'
    exact ⟨a', ha', b', hEa, hFb⟩

/-- The identity isomorphism of a pointed model with itself. -/
def pointedIsoRefl (R : ℕ → ℕ → ℕ → Bool) (V : ℕ → ℕ → Bool) (r : ℕ) :
    PointedIso R V R V r r where
  toFun := id
  invFun := id
  root := rfl
  root' := rfl
  map_reach := fun _ h => h
  map_reach' := fun _ h => h
  left_inv := fun _ _ => rfl
  right_inv := fun _ _ => rfl
  map_step := fun _ _ _ _ h => h
  map_step' := fun _ _ _ _ h => h
  map_atom := fun _ _ _ => rfl

/-! ## §2. Nominals collapse the gap -/

/-- The **nominal valuation**: the atom `p` is true exactly at the world `p`.  This is
the maximal multiplicity-sensitive enrichment of the observational language: every
world is named. -/
def nomV : ℕ → ℕ → Bool := fun m p => decide (m = p)

/-- **With nominals, modal equivalence is identity of worlds.**  Already the atomic
(depth-`0`) fragment does it. -/
theorem eq_of_modEq_nominal {m n : ℕ} (h : ModEq R nomV R' nomV m n) : m = n := by
  have := h (atom m)
  simp only [satF_atom, nomV] at this
  have h2 : n = m := by simpa using this
  exact h2.symm

/-- **Nominals close the bisimulation/isomorphism gap.**  Over a nominal valuation,
modally equivalent pointed models of one and the same frame are isomorphic — indeed
identical. -/
theorem pointedIso_of_modEq_nominal {m n : ℕ} (h : ModEq R nomV R nomV m n) :
    Nonempty (PointedIso R nomV R nomV m n) := by
  obtain rfl := eq_of_modEq_nominal h
  exact ⟨pointedIsoRefl R nomV m⟩

/-- Under a nominal valuation, every interpretation whatsoever is modally invariant on
a fixed frame; in particular the multiplicity observation `outDeg` becomes modally
invariant, in sharp contrast with `MultGap.not_modalInvariant_outDegInterp`, whose
witness frame carries the constant valuation. -/
theorem outDeg_congr_of_modEq_nominal {m n : ℕ} (h : ModEq R nomV R nomV m n) (j : ℕ) :
    outDeg R j m = outDeg R j n := by
  obtain rfl := eq_of_modEq_nominal h
  rfl

/-! ## §3. Multiplicity does not close the gap: the shared diamond -/

/-- The **shared diamond**: `5 → 3`, `5 → 4`, `3 → 1`, `4 → 1`.  The two branches meet
again at the world `1`. -/
def shareStep (m n : ℕ) : Bool :=
  (m == 5 && (n == 3 || n == 4)) || (m == 3 && n == 1) || (m == 4 && n == 1)

/-- The **unravelled diamond**: `5 → 3`, `5 → 4`, `3 → 1`, `4 → 2`.  Same behaviour,
same multiplicities, one extra world. -/
def treeStep (m n : ℕ) : Bool :=
  (m == 5 && (n == 3 || n == 4)) || (m == 3 && n == 1) || (m == 4 && n == 2)

def shareR : ℕ → ℕ → ℕ → Bool := fun _ m n => shareStep m n
def treeR : ℕ → ℕ → ℕ → Bool := fun _ m n => treeStep m n

/-- Constant valuation: only the transition structure is observable. -/
def shV : ℕ → ℕ → Bool := fun _ _ => true

theorem shareStep_iff (m n : ℕ) :
    shareStep m n = true ↔
      (m = 5 ∧ (n = 3 ∨ n = 4)) ∨ (m = 3 ∧ n = 1) ∨ (m = 4 ∧ n = 1) := by
  simp only [shareStep, Bool.or_eq_true, Bool.and_eq_true, beq_iff_eq]
  tauto

theorem treeStep_iff (m n : ℕ) :
    treeStep m n = true ↔
      (m = 5 ∧ (n = 3 ∨ n = 4)) ∨ (m = 3 ∧ n = 1) ∨ (m = 4 ∧ n = 2) := by
  simp only [treeStep, Bool.or_eq_true, Bool.and_eq_true, beq_iff_eq]
  tauto

/-- The behavioural class: `2` at the root, `1` at the two branch worlds, `0` at the
leaves. -/
def sharCls (m : ℕ) : ℕ := if m = 5 then 2 else if m = 3 ∨ m = 4 then 1 else 0

@[simp] theorem sharCls_five : sharCls 5 = 2 := by decide
@[simp] theorem sharCls_three : sharCls 3 = 1 := by decide
@[simp] theorem sharCls_four : sharCls 4 = 1 := by decide
@[simp] theorem sharCls_one : sharCls 1 = 0 := by decide
@[simp] theorem sharCls_two : sharCls 2 = 0 := by decide

theorem sharCls_eq_two {n : ℕ} (h : sharCls n = 2) : n = 5 := by
  unfold sharCls at h; split_ifs at h with h1 h2 <;> simp_all

theorem sharCls_eq_one {n : ℕ} (h : sharCls n = 1) : n = 3 ∨ n = 4 := by
  unfold sharCls at h; split_ifs at h with h1 h2 <;> simp_all

theorem sharCls_ne {n : ℕ} (h5 : n ≠ 5) (h3 : n ≠ 3) (h4 : n ≠ 4) : sharCls n = 0 := by
  unfold sharCls; split_ifs with h1 h2 <;> simp_all

/-- The class kernel is a bisimulation between the shared diamond and its
unravelling. -/
theorem isBisim_share_tree :
    IsBisim shareR shV treeR shV (fun m n => sharCls m = sharCls n) := by
  refine ⟨fun _ _ _ _ => rfl, ?_, ?_⟩
  · intro m n hmn i m' hm'
    have hstep := (shareStep_iff m m').1 hm'.2
    rcases hstep with ⟨rfl, hm2⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · have hn : n = 5 := sharCls_eq_two (by simpa using hmn.symm)
      subst hn
      exact ⟨3, ⟨by norm_num, rfl⟩, by rcases hm2 with rfl | rfl <;> simp⟩
    · obtain (rfl | rfl) := sharCls_eq_one (by simpa using hmn.symm)
      · exact ⟨1, ⟨by norm_num, rfl⟩, by simp⟩
      · exact ⟨2, ⟨by norm_num, rfl⟩, by simp⟩
    · obtain (rfl | rfl) := sharCls_eq_one (by simpa using hmn.symm)
      · exact ⟨1, ⟨by norm_num, rfl⟩, by simp⟩
      · exact ⟨2, ⟨by norm_num, rfl⟩, by simp⟩
  · intro m n hmn i n' hn'
    have hstep := (treeStep_iff n n').1 hn'.2
    rcases hstep with ⟨rfl, hn2⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · have hm : m = 5 := sharCls_eq_two (by simpa using hmn)
      subst hm
      exact ⟨3, ⟨by norm_num, rfl⟩, by rcases hn2 with rfl | rfl <;> simp⟩
    · obtain (rfl | rfl) := sharCls_eq_one (by simpa using hmn)
      · exact ⟨1, ⟨by norm_num, rfl⟩, by simp⟩
      · exact ⟨1, ⟨by norm_num, rfl⟩, by simp⟩
    · obtain (rfl | rfl) := sharCls_eq_one (by simpa using hmn)
      · exact ⟨1, ⟨by norm_num, rfl⟩, by simp⟩
      · exact ⟨1, ⟨by norm_num, rfl⟩, by simp⟩

/-- The shared diamond and its unravelling are bisimilar, hence modally
indistinguishable. -/
theorem bisimilar_share_tree : Bisimilar shareR shV treeR shV 5 5 :=
  ⟨_, isBisim_share_tree, rfl⟩

theorem modEq_share_tree : ModEq shareR shV treeR shV 5 5 :=
  modEq_of_bisimilar bisimilar_share_tree

/-! ### Out-degrees agree at every related pair -/

theorem outDeg_share_eq_zero {i m : ℕ} (h5 : m ≠ 5) (h3 : m ≠ 3) (h4 : m ≠ 4) :
    outDeg shareR i m = 0 := by
  simp only [outDeg, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro n _ hn
  have := (shareStep_iff m n).1 hn
  tauto

theorem outDeg_tree_eq_zero {i m : ℕ} (h5 : m ≠ 5) (h3 : m ≠ 3) (h4 : m ≠ 4) :
    outDeg treeR i m = 0 := by
  simp only [outDeg, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro n _ hn
  have := (treeStep_iff m n).1 hn
  tauto

/-- The out-degree in the two witness frames does not depend on the tag. -/
theorem outDeg_share_tag (i j m : ℕ) : outDeg shareR i m = outDeg shareR j m := rfl

theorem outDeg_tree_tag (i j m : ℕ) : outDeg treeR i m = outDeg treeR j m := rfl

@[simp] theorem outDeg_share_five (i : ℕ) : outDeg shareR i 5 = 2 := by
  rw [outDeg_share_tag i 0]; decide

@[simp] theorem outDeg_tree_five (i : ℕ) : outDeg treeR i 5 = 2 := by
  rw [outDeg_tree_tag i 0]; decide

@[simp] theorem outDeg_share_three (i : ℕ) : outDeg shareR i 3 = 1 := by
  rw [outDeg_share_tag i 0]; decide

@[simp] theorem outDeg_share_four (i : ℕ) : outDeg shareR i 4 = 1 := by
  rw [outDeg_share_tag i 0]; decide

@[simp] theorem outDeg_tree_three (i : ℕ) : outDeg treeR i 3 = 1 := by
  rw [outDeg_tree_tag i 0]; decide

@[simp] theorem outDeg_tree_four (i : ℕ) : outDeg treeR i 4 = 1 := by
  rw [outDeg_tree_tag i 0]; decide

/-- **Multiplicities agree everywhere along the bisimulation**: related worlds have
equal out-degrees at every tag.  So no amount of successor *counting* separates the
two models. -/
theorem outDeg_share_eq_tree {m n : ℕ} (h : sharCls m = sharCls n) (i : ℕ) :
    outDeg shareR i m = outDeg treeR i n := by
  by_cases h5 : m = 5
  · subst h5
    have : n = 5 := sharCls_eq_two (by rw [← h]; simp)
    subst this; simp
  · by_cases h3 : m = 3
    · subst h3
      obtain (rfl | rfl) := sharCls_eq_one (by rw [← h]; simp) <;> simp
    · by_cases h4 : m = 4
      · subst h4
        obtain (rfl | rfl) := sharCls_eq_one (by rw [← h]; simp) <;> simp
      · have hm0 : sharCls m = 0 := sharCls_ne h5 h3 h4
        have hn0 : sharCls n = 0 := h.symm.trans hm0
        have hn5 : n ≠ 5 := by rintro rfl; simp at hn0
        have hn3 : n ≠ 3 := by rintro rfl; simp at hn0
        have hn4 : n ≠ 4 := by rintro rfl; simp at hn0
        rw [outDeg_share_eq_zero h5 h3 h4, outDeg_tree_eq_zero hn5 hn3 hn4]

/-! ### …yet the two models are not isomorphic -/

/-- **No isomorphism.**  The tree has two distinct leaves, the shared diamond only one;
any isomorphism would have to send both leaves to the same world. -/
theorem isEmpty_pointedIso_share_tree :
    IsEmpty (PointedIso shareR shV treeR shV 5 5) := by
  refine ⟨fun F => ?_⟩
  -- reachability facts in the tree model
  have hs53 : FStep treeR 0 5 3 := ⟨by norm_num, rfl⟩
  have hs54 : FStep treeR 0 5 4 := ⟨by norm_num, rfl⟩
  have hs31 : FStep treeR 0 3 1 := ⟨by norm_num, rfl⟩
  have hs42 : FStep treeR 0 4 2 := ⟨by norm_num, rfl⟩
  have hr3 : Reach treeR 5 3 := Reach.step Reach.base hs53
  have hr4 : Reach treeR 5 4 := Reach.step Reach.base hs54
  have hr1 : Reach treeR 5 1 := Reach.step hr3 hs31
  have hr2 : Reach treeR 5 2 := Reach.step hr4 hs42
  -- the images of the two branch worlds are branch worlds of the diamond
  have hg3 := F.map_step' 0 5 3 Reach.base hs53
  have hg4 := F.map_step' 0 5 4 Reach.base hs54
  rw [F.root'] at hg3 hg4
  have hb3 : F.invFun 3 = 3 ∨ F.invFun 3 = 4 := by
    have := (shareStep_iff 5 (F.invFun 3)).1 hg3.2
    tauto
  have hb4 : F.invFun 4 = 3 ∨ F.invFun 4 = 4 := by
    have := (shareStep_iff 5 (F.invFun 4)).1 hg4.2
    tauto
  -- both leaves of the tree must go to the unique leaf of the diamond
  have hl1 : F.invFun 1 = 1 := by
    have hstep := F.map_step' 0 3 1 hr3 hs31
    have := (shareStep_iff (F.invFun 3) (F.invFun 1)).1 hstep.2
    rcases hb3 with h | h <;> rw [h] at this <;> omega
  have hl2 : F.invFun 2 = 1 := by
    have hstep := F.map_step' 0 4 2 hr4 hs42
    have := (shareStep_iff (F.invFun 4) (F.invFun 2)).1 hstep.2
    rcases hb4 with h | h <;> rw [h] at this <;> omega
  -- contradiction with injectivity
  have e1 := F.right_inv 1 hr1
  have e2 := F.right_inv 2 hr2
  rw [hl1] at e1
  rw [hl2] at e2
  omega

/-! ## §4. The refined verdict -/

/-- **Multiplicity does not close the bisimulation/isomorphism gap.**  There are two
pointed models that are

* bisimilar, hence modally indistinguishable,
* multiplicity-matched: related worlds have equal out-degrees at every tag,

and yet not isomorphic.  Therefore the conjecture "the gap is characterized by
multiplicity-sensitive observations" is *false as stated*: successor counting is
strictly weaker than the world-naming (nominal) observations of §2, which do close the
gap.  What remains invisible to counting is **sharing**: the identification of
behaviourally equal successors. -/
theorem multiplicity_does_not_close_the_gap :
    Bisimilar shareR shV treeR shV 5 5 ∧
      (∀ m n, sharCls m = sharCls n → ∀ i, outDeg shareR i m = outDeg treeR i n) ∧
      IsEmpty (PointedIso shareR shV treeR shV 5 5) :=
  ⟨bisimilar_share_tree, fun _ _ h i => outDeg_share_eq_tree h i,
    isEmpty_pointedIso_share_tree⟩

/-- **The two-step resolution ladder of cycle 2.**  Modal observation (equivalently
bisimulation) is strictly coarser than "bisimulation + multiplicity", which is in turn
strictly coarser than isomorphism, which the nominal language recovers exactly. -/
theorem two_step_ladder :
    (∃ m n : ℕ, ModEq multR multV multR multV m n ∧
        outDeg multR 0 m ≠ outDeg multR 0 n) ∧
      (Bisimilar shareR shV treeR shV 5 5 ∧
        (∀ m n, sharCls m = sharCls n → ∀ i, outDeg shareR i m = outDeg treeR i n) ∧
        IsEmpty (PointedIso shareR shV treeR shV 5 5)) ∧
      (∀ (R : ℕ → ℕ → ℕ → Bool) (m n : ℕ), ModEq R nomV R nomV m n →
        Nonempty (PointedIso R nomV R nomV m n)) :=
  ⟨⟨3, 4, modEq_three_four, by simp⟩, multiplicity_does_not_close_the_gap,
    fun _ _ _ h => pointedIso_of_modEq_nominal h⟩

end Beyond

end PhysicsConsistency