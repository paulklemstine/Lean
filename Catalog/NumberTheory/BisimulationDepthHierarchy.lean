import NumberTheory.BisimulationMultiplicityGap

/-!
# The observational hierarchy: from depth-bounded observation up to bisimulation, and
past it to isomorphism

`NumberTheory.BisimulationResolution` identified modal invariance with bisimulation
invariance, and `NumberTheory.BisimulationMultiplicityGap` showed that isomorphism
invariance is *strictly weaker* (i.e. isomorphism classes are strictly finer than
bisimulation classes).  This file fills in the whole ladder **below** bisimulation:

```
  DepthInv 0 ⊊ DepthInv 1 ⊊ DepthInv 2 ⊊ ⋯ ⊊ ModalInv = BisimInv ⊊ IsoInv
```

* `DepthEq k` — agreement on all formulas of box depth `≤ k` (the depth-`k`
  observational equivalence of `Combinatorics.BoxDepthReflection`);
* `modEq_iff_forall_depthEq` — modal equivalence is exactly the intersection of the
  whole family, so, with `bisimilar_iff_modEq`, bisimilarity is the **limit** of the
  depth hierarchy;
* `depthEq_chain` / `not_depthEq_succ_chain` — in the linear frame `chainR` the worlds
  `k` and `k + 1` are depth-`k` equivalent but separated at depth `k + 1`, so every
  layer of the ladder is strict (`depthInvariant_strict_succ`);
* `depthInvariant_lt_modalInvariant` — and no finite depth suffices: there is a modally
  invariant interpretation that is not depth-`k` invariant, for every `k`;
* `full_resolution_hierarchy` — the assembled statement, together with the strict
  bisimulation/isomorphism gap of the previous file.

The witness at each finite layer is the *height* observation `□^{k+1}⊥`, while the
witness of the top gap is the *multiplicity* observation `outDeg`: the hierarchy is
strict for two structurally different reasons — depth of nesting below, counting
above.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the depth ladder is strict at every level and its limit is
  exactly bisimulation; the top gap is orthogonal to depth.
Experiment (Stage 2): `chainR` (each world `m + 1` sees only `m`) realises the
  strictness; `satF_chain_boxPow_bot` computes the entire modal theory of a world of
  the chain: `□^j⊥` holds at `m` iff `m < j`.
Analysis (Stage 3): the depth ladder never reaches the multiplicity gap — the two
  worlds of `multR` agree at *every* depth, so the top gap is not a limit of finite
  gaps but a genuinely different phenomenon.
Critique (Stage 4): the strictness witnesses are explicit formulas, not existence
  claims, and `depthEq_chain` is proved from the catalog's bounded-bisimulation
  transfer lemma `satF_congr_of_approx` rather than by a bespoke induction.
-/

namespace PhysicsConsistency

open ProofSystemCollapse
open Form
open Bisim
open MultGap

namespace Hierarchy

/-! ## §1. Depth-bounded observational equivalence -/

/-- **Depth-`k` observational equivalence**: the two pointed models agree on every
formula of box depth at most `k`. -/
def DepthEq (k : ℕ) (R : ℕ → ℕ → ℕ → Bool) (V : ℕ → ℕ → Bool) (R' : ℕ → ℕ → ℕ → Bool)
    (V' : ℕ → ℕ → Bool) (m n : ℕ) : Prop :=
  ∀ a : Form, boxDepth a ≤ k → satF R V m a = satF R' V' n a

variable {R R' : ℕ → ℕ → ℕ → Bool} {V V' : ℕ → ℕ → Bool}

theorem depthEq_mono {k l : ℕ} (hkl : k ≤ l) {m n : ℕ}
    (h : DepthEq l R V R' V' m n) : DepthEq k R V R' V' m n :=
  fun a ha => h a (ha.trans hkl)

/-- **Modal equivalence is the limit of the depth hierarchy.** -/
theorem modEq_iff_forall_depthEq {m n : ℕ} :
    ModEq R V R' V' m n ↔ ∀ k, DepthEq k R V R' V' m n := by
  constructor
  · intro h k a _; exact h a
  · intro h a; exact h (boxDepth a) a le_rfl

/-- Invariance of an interpretation under depth-`k` observation. -/
def DepthInvariant (k : ℕ) {α : Type*} (I : Interp α) : Prop :=
  ∀ R V R' V' m n, DepthEq k R V R' V' m n → I R V m = I R' V' n

/-- Deeper observation is a weaker requirement on interpretations. -/
theorem depthInvariant_mono {k l : ℕ} (hkl : k ≤ l) {α : Type*} {I : Interp α}
    (h : DepthInvariant k I) : DepthInvariant l I :=
  fun R V R' V' m n hd => h R V R' V' m n (depthEq_mono hkl hd)

/-- Every depth-bounded invariant is a modal invariant. -/
theorem modalInvariant_of_depthInvariant {k : ℕ} {α : Type*} {I : Interp α}
    (h : DepthInvariant k I) : ModalInvariant I :=
  fun R V R' V' m n hm => h R V R' V' m n ((modEq_iff_forall_depthEq.1 hm) k)

/-! ## §2. The linear chain frame -/

/-- The step relation of the linear chain: the world `m + 1` sees exactly `m`. -/
def chainStep (m n : ℕ) : Bool := n + 1 == m

/-- The chain frame, the same at every tag. -/
def chainR : ℕ → ℕ → ℕ → Bool := fun _ m n => chainStep m n

/-- All atoms hold everywhere in the chain: only the transition structure is visible. -/
def chainV : ℕ → ℕ → Bool := fun _ _ => true

theorem chainStep_iff (m n : ℕ) : chainStep m n = true ↔ n + 1 = m := by
  simp [chainStep]

theorem fStep_chain_iff (i m n : ℕ) : FStep chainR i m n ↔ n + 1 = m := by
  constructor
  · intro h; exact (chainStep_iff m n).1 h.2
  · intro h; exact ⟨by omega, (chainStep_iff m n).2 h⟩

/-- **The modal theory of a world of the chain.**  The `j`-fold boxed falsum holds at
`m` exactly when the world `m` has height `< j`. -/
theorem satF_chain_boxPow_bot (i : ℕ) :
    ∀ (j m : ℕ), satF chainR chainV m (boxPow i j bot) = true ↔ m < j := by
  intro j
  induction j with
  | zero => intro m; simp [boxPow]
  | succ j ih =>
      intro m
      rw [boxPow, satF_box]
      constructor
      · intro h
        match m with
        | 0 => omega
        | p + 1 =>
            have hs : FStep chainR i (p + 1) p := (fStep_chain_iff i (p + 1) p).2 rfl
            have := (ih p).1 (h p hs.1 hs.2)
            omega
      · intro hm n hn hR
        have : n + 1 = m := (chainStep_iff m n).1 hR
        exact (ih n).2 (by omega)

/-! ## §3. Strictness of every layer -/

/-- Two worlds of the chain that both have height at least `k` are depth-`k`
equivalent.  Proved from the catalog's bounded-bisimulation transfer lemma. -/
theorem depthEq_chain {k m n : ℕ} (hm : k ≤ m) (hn : k ≤ n) :
    DepthEq k chainR chainV chainR chainV m n := by
  intro a ha
  refine satF_congr_of_approx (R := chainR) (V := chainV)
    (fun k m n => k ≤ m ∧ k ≤ n) (fun _ _ _ _ _ => rfl) (fun _ _ _ h => ⟨h.2, h.1⟩)
    ?_ a k m n ha ⟨hm, hn⟩
  rintro l p q ⟨hp, hq⟩ j p' hp' hR
  have hpp : p' + 1 = p := (chainStep_iff p p').1 hR
  refine ⟨q - 1, by omega, ?_, by omega, by omega⟩
  exact (chainStep_iff q (q - 1)).2 (by omega)

/-- …but the worlds `k` and `k + 1` of the chain are separated at depth `k + 1`, by the
height formula `□^{k+1}⊥`. -/
theorem not_depthEq_succ_chain (k : ℕ) :
    ¬ DepthEq (k + 1) chainR chainV chainR chainV k (k + 1) := by
  intro h
  have hd : boxDepth (boxPow 0 (k + 1) bot) ≤ k + 1 := by simp
  have := h (boxPow 0 (k + 1) bot) hd
  have h1 : satF chainR chainV k (boxPow 0 (k + 1) bot) = true :=
    (satF_chain_boxPow_bot 0 (k + 1) k).2 (by omega)
  have h2 : satF chainR chainV (k + 1) (boxPow 0 (k + 1) bot) = true := by
    rw [← this]; exact h1
  have := (satF_chain_boxPow_bot 0 (k + 1) (k + 1)).1 h2
  omega
/-- The chain worlds `k` and `k + 1` are depth-`k` equivalent. -/
theorem depthEq_chain_succ (k : ℕ) : DepthEq k chainR chainV chainR chainV k (k + 1) :=
  depthEq_chain le_rfl (by omega)

/-- The **height interpretation** at level `j`: does `□^j⊥` hold at the root? -/
def heightInterp (j : ℕ) : Interp Bool := fun R V m => satF R V m (boxPow 0 j bot)

theorem depthInvariant_heightInterp (j : ℕ) : DepthInvariant j (heightInterp j) := by
  intro R V R' V' m n h
  exact h (boxPow 0 j bot) (by simp)

/-- **Every layer of the depth ladder is strict.**  Depth-`k` invariance implies
depth-`(k+1)` invariance, and the height observation `□^{k+1}⊥` witnesses that the
converse fails. -/
theorem depthInvariant_strict_succ (k : ℕ) :
    (∀ (α : Type) (I : Interp α), DepthInvariant k I → DepthInvariant (k + 1) I) ∧
      ∃ I : Interp Bool, DepthInvariant (k + 1) I ∧ ¬ DepthInvariant k I := by
  refine ⟨fun _ I h => depthInvariant_mono (by omega) h, heightInterp (k + 1),
    depthInvariant_heightInterp (k + 1), fun h => ?_⟩
  have hEq := h chainR chainV chainR chainV k (k + 1) (depthEq_chain_succ k)
  simp only [heightInterp] at hEq
  have h1 : satF chainR chainV k (boxPow 0 (k + 1) bot) = true :=
    (satF_chain_boxPow_bot 0 (k + 1) k).2 (by omega)
  have h2 := (satF_chain_boxPow_bot 0 (k + 1) (k + 1)).1 (hEq ▸ h1)
  omega

/-- **No finite depth reaches bisimulation.**  For every `k` there is a modally
invariant interpretation — indeed the full modal theory — that is not depth-`k`
invariant. -/
theorem depthInvariant_lt_modalInvariant (k : ℕ) :
    (∀ (α : Type) (I : Interp α), DepthInvariant k I → ModalInvariant I) ∧
      ∃ I : Interp (Form → Bool), ModalInvariant I ∧ ¬ DepthInvariant k I := by
  refine ⟨fun _ I h => modalInvariant_of_depthInvariant h, modalTheory,
    modalInvariant_modalTheory, fun h => ?_⟩
  have hEq := h chainR chainV chainR chainV k (k + 1) (depthEq_chain_succ k)
  have hEq' := congrFun hEq (boxPow 0 (k + 1) bot)
  simp only [modalTheory] at hEq'
  have h1 : satF chainR chainV k (boxPow 0 (k + 1) bot) = true :=
    (satF_chain_boxPow_bot 0 (k + 1) k).2 (by omega)
  have h2 := (satF_chain_boxPow_bot 0 (k + 1) (k + 1)).1 (hEq' ▸ h1)
  omega

/-! ## §4. The assembled hierarchy -/

/-- **The full resolution hierarchy.**  Reading from the finest observational power to
the coarsest notion of sameness:

1. depth-`k` invariance implies depth-`(k+1)` invariance, strictly (height witness);
2. every depth-bounded invariant is a modal invariant, strictly (no finite depth
   captures the whole modal theory);
3. modal invariance *is* bisimulation invariance — the conjecture's positive half;
4. bisimulation invariance implies isomorphism invariance, strictly (multiplicity
   witness) — the conjecture's negative half.

So modal observation resolves pointed models exactly at bisimulation: strictly coarser
than isomorphism, strictly finer than every depth-bounded approximation. -/
theorem full_resolution_hierarchy (k : ℕ) :
    (∃ I : Interp Bool, DepthInvariant (k + 1) I ∧ ¬ DepthInvariant k I) ∧
      (∃ I : Interp (Form → Bool), ModalInvariant I ∧ ¬ DepthInvariant k I) ∧
      (∀ (α : Type) (I : Interp α), ModalInvariant I ↔ BisimInvariant I) ∧
      (∃ I : Interp ℕ, IsoInvariant I ∧ ¬ BisimInvariant I) :=
  ⟨(depthInvariant_strict_succ k).2, (depthInvariant_lt_modalInvariant k).2,
    fun _ I => modalInvariant_iff_bisimInvariant I, bisimInvariant_lt_isoInvariant.2⟩

/-- **The two gaps are independent.**  The multiplicity witness is *not* a depth
phenomenon: the two worlds `3` and `4` of `multR` are depth-`k` equivalent for every
`k`, yet separated by the multiplicity observation. -/
theorem multiplicity_gap_beyond_every_depth (k : ℕ) :
    DepthEq k multR multV multR multV 3 4 ∧
      outDegInterp 0 multR multV 3 ≠ outDegInterp 0 multR multV 4 :=
  ⟨fun a _ => modEq_three_four a, multiplicity_gap.2.2⟩

end Hierarchy

end PhysicsConsistency