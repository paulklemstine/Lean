import NumberTheory.BisimulationResolution

/-!
# The multiplicity gap: bisimulation invariance is strictly stronger than isomorphism
invariance

`NumberTheory.BisimulationResolution` proved the positive half of the mission
conjecture: modal invariance = bisimulation invariance.  This file proves the
**negative half**, and identifies the separating observation.

* `PointedIso` — an isomorphism of pointed tag-indexed models: a bijection between the
  generated submodels preserving atoms and steps at every tag.
* `bisimilar_of_pointedIso` — isomorphic pointed models are bisimilar, hence the
  hierarchy `iso ⟹ bisim ⟺ modal equivalence`.
* `outDeg_congr_of_pointedIso` — the **out-degree of the root** (a multiplicity-
  sensitive observation: it counts successors rather than observing behaviour) is an
  isomorphism invariant.
* `multiplicity_gap` — but it is *not* a modal invariant: in the explicit frame
  `multR`, the worlds `3` (two successors, both behaving like `1`) and `4` (one
  successor) are bisimilar, hence modally indistinguishable, while their out-degrees
  are `2` and `1`.

Consequently `BisimInvariant ⊊ IsoInvariant` (`bisimInvariant_lt_isoInvariant`): an
interpretation invariant under all modal observations factors through bisimulation
classes, and this is *strictly* coarser than factoring through isomorphism classes.
The gap is exactly the multiplicity-sensitive observations, of which the out-degree is
the minimal example (`outDeg` already separates at "modal depth 1 with counting").

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the smallest witness of the gap is a duplicated successor.
Experiment (Stage 2): the 5-world frame `multR` (0 dead, 1→0, 2→0, 3→{1,2}, 4→{1})
  realises it; the bisimulation is the kernel of the "class" map `multCls`.
Analysis (Stage 3): the gap is *not* a defect of the modal language's depth — the two
  worlds agree on formulas of every depth — but of its inability to count successors.
Critique (Stage 4): `PointedIso` is deliberately weak (it constrains only the
  generated submodels), so the non-existence statement `IsEmpty` is correspondingly
  strong; and the out-degree invariance is proved for arbitrary frames, not just the
  witness.
-/

namespace PhysicsConsistency

open ProofSystemCollapse
open Form
open Bisim

namespace MultGap

/-! ## §1. Reachability, pointed isomorphism, out-degree -/

/-- Worlds reachable from the root along steps of arbitrary tags. -/
inductive Reach (R : ℕ → ℕ → ℕ → Bool) (r : ℕ) : ℕ → Prop
  | base : Reach R r r
  | step {m n j : ℕ} : Reach R r m → FStep R j m n → Reach R r n

/-- An **isomorphism of pointed models**: a bijection between the submodels generated
by the two roots, preserving the atoms and the steps of every tag in both
directions. -/
structure PointedIso (R : ℕ → ℕ → ℕ → Bool) (V : ℕ → ℕ → Bool)
    (R' : ℕ → ℕ → ℕ → Bool) (V' : ℕ → ℕ → Bool) (r r' : ℕ) where
  toFun : ℕ → ℕ
  invFun : ℕ → ℕ
  root : toFun r = r'
  root' : invFun r' = r
  map_reach : ∀ m, Reach R r m → Reach R' r' (toFun m)
  map_reach' : ∀ n, Reach R' r' n → Reach R r (invFun n)
  left_inv : ∀ m, Reach R r m → invFun (toFun m) = m
  right_inv : ∀ n, Reach R' r' n → toFun (invFun n) = n
  map_step : ∀ j m n, Reach R r m → FStep R j m n → FStep R' j (toFun m) (toFun n)
  map_step' : ∀ j m n, Reach R' r' m → FStep R' j m n → FStep R j (invFun m) (invFun n)
  map_atom : ∀ m, Reach R r m → ∀ p, V m p = V' (toFun m) p

/-- The **out-degree** of a world at a tag: the number of its successors.  This is the
paradigmatic *multiplicity-sensitive* observation. -/
def outDeg (R : ℕ → ℕ → ℕ → Bool) (j m : ℕ) : ℕ :=
  ((Finset.range m).filter (fun n => R j m n = true)).card

theorem mem_outDeg_filter {R : ℕ → ℕ → ℕ → Bool} {j m n : ℕ} :
    n ∈ (Finset.range m).filter (fun n => R j m n = true) ↔ FStep R j m n := by
  simp [FStep, Finset.mem_filter, Finset.mem_range]

/-! ## §2. Isomorphism implies bisimulation -/

/-- **Isomorphic pointed models are bisimilar.**  The first (easy) layer of the
resolution hierarchy `iso ⟹ bisim ⟺ modal equivalence`. -/
theorem bisimilar_of_pointedIso {R R' : ℕ → ℕ → ℕ → Bool} {V V' : ℕ → ℕ → Bool}
    {r r' : ℕ} (F : PointedIso R V R' V' r r') : Bisimilar R V R' V' r r' := by
  refine ⟨fun m n => Reach R r m ∧ n = F.toFun m, ⟨?_, ?_, ?_⟩, ⟨Reach.base, F.root.symm⟩⟩
  · rintro m n ⟨hm, rfl⟩ p
    exact F.map_atom m hm p
  · rintro m n ⟨hm, rfl⟩ i m' hm'
    exact ⟨F.toFun m', F.map_step i m m' hm hm', Reach.step hm hm', rfl⟩
  · rintro m n ⟨hm, rfl⟩ i n' hn'
    have hstep := F.map_step' i (F.toFun m) n' (F.map_reach m hm) hn'
    rw [F.left_inv m hm] at hstep
    refine ⟨F.invFun n', hstep, Reach.step hm hstep, ?_⟩
    exact (F.right_inv n' (Reach.step (F.map_reach m hm) hn')).symm

/-- Isomorphic pointed models are modally equivalent. -/
theorem modEq_of_pointedIso {R R' : ℕ → ℕ → ℕ → Bool} {V V' : ℕ → ℕ → Bool} {r r' : ℕ}
    (F : PointedIso R V R' V' r r') : ModEq R V R' V' r r' :=
  modEq_of_bisimilar (bisimilar_of_pointedIso F)

/-! ## §3. The out-degree is an isomorphism invariant -/

/-- **Out-degree is preserved by pointed isomorphism**, at every tag. -/
theorem outDeg_congr_of_pointedIso {R R' : ℕ → ℕ → ℕ → Bool} {V V' : ℕ → ℕ → Bool}
    {r r' : ℕ} (F : PointedIso R V R' V' r r') (j : ℕ) : outDeg R j r = outDeg R' j r' := by
  classical
  refine Finset.card_bij (fun n _ => F.toFun n) ?_ ?_ ?_
  · intro n hn
    have hs : FStep R j r n := mem_outDeg_filter.1 hn
    have := F.map_step j r n Reach.base hs
    rw [F.root] at this
    exact mem_outDeg_filter.2 this
  · intro a ha b hb hab
    have hra : Reach R r a := Reach.step Reach.base (mem_outDeg_filter.1 ha)
    have hrb : Reach R r b := Reach.step Reach.base (mem_outDeg_filter.1 hb)
    have := congrArg F.invFun hab
    rwa [F.left_inv a hra, F.left_inv b hrb] at this
  · intro n' hn'
    have hs : FStep R' j r' n' := mem_outDeg_filter.1 hn'
    have hstep := F.map_step' j r' n' Reach.base hs
    rw [F.root'] at hstep
    refine ⟨F.invFun n', mem_outDeg_filter.2 hstep, ?_⟩
    simpa using F.right_inv n' (Reach.step Reach.base hs)

/-! ## §4. The witness frame -/

/-- The step relation of the witness frame: `1 → 0`, `2 → 0`, `3 → 1`, `3 → 2`,
`4 → 1`.  The worlds `3` and `4` differ only by the *multiplicity* of their (behaviourally
identical) successors. -/
def multStep (m n : ℕ) : Bool :=
  (m == 1 && n == 0) || (m == 2 && n == 0) || (m == 3 && (n == 1 || n == 2)) ||
    (m == 4 && n == 1)

/-- The witness frame, the same at every tag. -/
def multR : ℕ → ℕ → ℕ → Bool := fun _ m n => multStep m n

/-- The witness valuation: all atoms true everywhere, so that only the transition
structure can be observed. -/
def multV : ℕ → ℕ → Bool := fun _ _ => true

theorem multStep_iff (m n : ℕ) :
    multStep m n = true ↔
      (m = 1 ∧ n = 0) ∨ (m = 2 ∧ n = 0) ∨ (m = 3 ∧ (n = 1 ∨ n = 2)) ∨ (m = 4 ∧ n = 1) := by
  simp only [multStep, Bool.or_eq_true, Bool.and_eq_true, beq_iff_eq]
  tauto

/-- The behavioural class of a world of the witness frame: `0` for the dead ends,
`1` for the worlds with a single dead-end successor, `2` for the two roots. -/
def multCls (m : ℕ) : ℕ := if m = 1 ∨ m = 2 then 1 else if m = 3 ∨ m = 4 then 2 else 0

theorem multCls_eq_one {n : ℕ} (h : multCls n = 1) : n = 1 ∨ n = 2 := by
  unfold multCls at h; split_ifs at h with h1 h2 <;> simp_all

theorem multCls_eq_two {n : ℕ} (h : multCls n = 2) : n = 3 ∨ n = 4 := by
  unfold multCls at h; split_ifs at h with h1 h2 <;> simp_all

@[simp] theorem multCls_zero : multCls 0 = 0 := by decide
@[simp] theorem multCls_one : multCls 1 = 1 := by decide
@[simp] theorem multCls_two : multCls 2 = 1 := by decide
@[simp] theorem multCls_three : multCls 3 = 2 := by decide
@[simp] theorem multCls_four : multCls 4 = 2 := by decide

/-- The kernel of `multCls` is a bisimulation of the witness frame with itself. -/
theorem isBisim_multCls :
    IsBisim multR multV multR multV (fun m n => multCls m = multCls n) := by
  have forth : ∀ m n : ℕ, multCls m = multCls n → ∀ i m', FStep multR i m m' →
      ∃ n', FStep multR i n n' ∧ multCls m' = multCls n' := by
    intro m n hmn i m' hm'
    have hstep : multStep m m' = true := hm'.2
    rw [multStep_iff] at hstep
    have hone : ∀ k, (k = 1 ∨ k = 2) → FStep multR i k 0 := by
      rintro k (rfl | rfl) <;> exact ⟨by norm_num, rfl⟩
    have htwo : ∀ k, (k = 3 ∨ k = 4) → FStep multR i k 1 := by
      rintro k (rfl | rfl) <;> exact ⟨by norm_num, rfl⟩
    rcases hstep with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, hm2⟩ | ⟨rfl, rfl⟩
    · obtain (rfl | rfl) := multCls_eq_one hmn.symm
      · exact ⟨0, hone 1 (Or.inl rfl), rfl⟩
      · exact ⟨0, hone 2 (Or.inr rfl), rfl⟩
    · obtain (rfl | rfl) := multCls_eq_one hmn.symm
      · exact ⟨0, hone 1 (Or.inl rfl), rfl⟩
      · exact ⟨0, hone 2 (Or.inr rfl), rfl⟩
    · obtain (rfl | rfl) := multCls_eq_two hmn.symm
      · exact ⟨1, htwo 3 (Or.inl rfl), by rcases hm2 with rfl | rfl <;> simp⟩
      · exact ⟨1, htwo 4 (Or.inr rfl), by rcases hm2 with rfl | rfl <;> simp⟩
    · obtain (rfl | rfl) := multCls_eq_two hmn.symm
      · exact ⟨1, htwo 3 (Or.inl rfl), rfl⟩
      · exact ⟨1, htwo 4 (Or.inr rfl), rfl⟩
  exact ⟨fun _ _ _ _ => rfl, forth,
    fun m n h i n' hn' => by
      obtain ⟨m', hm', hE⟩ := forth n m h.symm i n' hn'
      exact ⟨m', hm', hE.symm⟩⟩

/-- The two roots of the witness frame are bisimilar. -/
theorem bisimilar_three_four : Bisimilar multR multV multR multV 3 4 :=
  ⟨_, isBisim_multCls, by simp⟩

/-- …hence modally indistinguishable: no formula of the modal language separates the
world with two successors from the world with one. -/
theorem modEq_three_four : ModEq multR multV multR multV 3 4 :=
  modEq_of_bisimilar bisimilar_three_four

@[simp] theorem outDeg_three : outDeg multR 0 3 = 2 := by decide

@[simp] theorem outDeg_four : outDeg multR 0 4 = 1 := by decide

/-- The two roots are **not** isomorphic: out-degree separates them. -/
theorem isEmpty_pointedIso_three_four :
    IsEmpty (PointedIso multR multV multR multV 3 4) := by
  refine ⟨fun F => ?_⟩
  have := outDeg_congr_of_pointedIso F 0
  rw [outDeg_three, outDeg_four] at this
  exact absurd this (by norm_num)

/-! ## §5. The gap -/

/-- Invariance of an interpretation under isomorphism of pointed models. -/
def IsoInvariant {α : Type*} (I : Interp α) : Prop :=
  ∀ R V R' V' m n, Nonempty (PointedIso R V R' V' m n) → I R V m = I R' V' n

/-- The multiplicity-sensitive interpretation: the out-degree of the root at tag `j`. -/
def outDegInterp (j : ℕ) : Interp ℕ := fun R _ m => outDeg R j m

theorem isoInvariant_outDegInterp (j : ℕ) : IsoInvariant (outDegInterp j) := by
  rintro R V R' V' m n ⟨F⟩
  exact outDeg_congr_of_pointedIso F j

/-- Every bisimulation-invariant interpretation is isomorphism invariant. -/
theorem isoInvariant_of_bisimInvariant {α : Type*} {I : Interp α} (h : BisimInvariant I) :
    IsoInvariant I := by
  rintro R V R' V' m n ⟨F⟩
  exact h R V R' V' m n (bisimilar_of_pointedIso F)

/-- **The multiplicity gap.**  There are two pointed models that are bisimilar — hence
satisfy exactly the same modal formulas — but are not isomorphic, and the
multiplicity-sensitive observation "out-degree of the root" separates them. -/
theorem multiplicity_gap :
    ModEq multR multV multR multV 3 4 ∧
      IsEmpty (PointedIso multR multV multR multV 3 4) ∧
      outDegInterp 0 multR multV 3 ≠ outDegInterp 0 multR multV 4 :=
  ⟨modEq_three_four, isEmpty_pointedIso_three_four, by
    simp only [outDegInterp, outDeg_three, outDeg_four]; norm_num⟩

/-- The out-degree is isomorphism invariant but **not** modally invariant: it does not
factor through bisimulation classes. -/
theorem not_modalInvariant_outDegInterp : ¬ ModalInvariant (outDegInterp 0) := by
  intro h
  have := h multR multV multR multV 3 4 modEq_three_four
  simp only [outDegInterp, outDeg_three, outDeg_four] at this
  exact absurd this (by norm_num)

/-- **Strict hierarchy.**  Bisimulation invariance (equivalently, by
`modalInvariant_iff_bisimInvariant`, invariance under all modal observations) implies
isomorphism invariance, and the implication is strict; the gap is realised by a
multiplicity-sensitive observation. -/
theorem bisimInvariant_lt_isoInvariant :
    (∀ {α : Type} (I : Interp α), BisimInvariant I → IsoInvariant I) ∧
      ∃ I : Interp ℕ, IsoInvariant I ∧ ¬ BisimInvariant I := by
  refine ⟨fun I h => isoInvariant_of_bisimInvariant h, outDegInterp 0,
    isoInvariant_outDegInterp 0, fun h => ?_⟩
  exact not_modalInvariant_outDegInterp ((modalInvariant_iff_bisimInvariant _).2 h)

end MultGap

end PhysicsConsistency