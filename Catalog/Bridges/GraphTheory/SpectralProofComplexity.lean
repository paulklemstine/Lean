import Mathlib

/-!
# Spectral Proof Complexity

A framework connecting directed graph expansion to proof complexity through
derivation graphs. We formalize derivation systems, proof balls (the set of
statements derivable within a given number of steps), and establish quantitative
relationships between graph expansion and derivation depth.

## Main Results

* `proofBall_mono` — proof balls grow monotonically
* `proofBall_succ_eq_union_frontier` — Ball(k+1) = Ball(k) ∪ Frontier(k)
* `card_proofBall_succ` — |Ball(k+1)| = |Ball(k)| + |Frontier(k)|
* `proofBall_stabilizes` — once stable, permanently stable
* `stable_iff_derivation_closed` — stabilization ↔ closure under derivation
* `exists_stabilization_depth` — finite types have a stabilization depth
* `reachability_dichotomy` — every statement: derivable or permanently unreachable
* `ball_growth_additive_lower` — additive growth bound from minimum frontier size
* `depth_lower_bound_from_card` — depth ≥ (target_card - axiom_card) / max_frontier
-/

open Finset

/-- A derivation system on a finite type: a set of axioms and a one-step
    derivation function mapping each statement to the set of statements
    it directly implies. -/
structure DerivationSystem (α : Type*) [Fintype α] [DecidableEq α] where
  /-- The set of axiom statements (depth 0). -/
  ax : Finset α
  /-- One-step derivation: `derives a` is the set of statements directly
      derivable from `a` in one step. -/
  derives : α → Finset α

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- The proof ball of depth `k`: all statements derivable in at most `k` steps. -/
def DerivationSystem.proofBall (D : DerivationSystem α) : ℕ → Finset α
  | 0 => D.ax
  | n + 1 => D.proofBall n ∪ (D.proofBall n).biUnion D.derives

namespace DerivationSystem

variable (D : DerivationSystem α)

/-- The frontier at depth `k`: statements newly derivable at step `k+1`
    that were not in Ball(k). -/
def frontier (k : ℕ) : Finset α :=
  (D.proofBall k).biUnion D.derives \ D.proofBall k

/-- A statement is derivable if it appears in some proof ball. -/
def Derivable (a : α) : Prop := ∃ k, a ∈ D.proofBall k

/-- The derivation depth: minimum number of steps to derive a statement. -/
noncomputable def derivationDepth (a : α) (h : D.Derivable a) : ℕ :=
  Nat.find h

/-! ### Monotonicity -/

/-
Proof balls grow monotonically: Ball(k) ⊆ Ball(k+1).
-/
theorem proofBall_mono (k : ℕ) : D.proofBall k ⊆ D.proofBall (k + 1) := by
  exact Finset.subset_union_left

/-
Chained monotonicity for proof balls.
-/
theorem proofBall_mono_of_le {k m : ℕ} (h : k ≤ m) :
    D.proofBall k ⊆ D.proofBall m := by
  induction h <;> simp_all +decide [ Finset.union_subset_union ];
  exact Finset.Subset.trans ‹_› ( Finset.subset_union_left )

/-! ### Structural Decomposition -/

/-
Ball(k+1) decomposes as Ball(k) ∪ Frontier(k).
-/
theorem proofBall_succ_eq_union_frontier (k : ℕ) :
    D.proofBall (k + 1) = D.proofBall k ∪ D.frontier k := by
  unfold DerivationSystem.frontier; aesop;

/-
The frontier is disjoint from the current ball.
-/
theorem frontier_disjoint (k : ℕ) : Disjoint (D.proofBall k) (D.frontier k) := by
  exact disjoint_sdiff_self_right

/-
Cardinality growth: |Ball(k+1)| = |Ball(k)| + |Frontier(k)|.
-/
theorem card_proofBall_succ (k : ℕ) :
    (D.proofBall (k + 1)).card = (D.proofBall k).card + (D.frontier k).card := by
  rw [← Finset.card_union_of_disjoint (D.frontier_disjoint k),
      D.proofBall_succ_eq_union_frontier]

/-! ### Stabilization -/

/-
Once a proof ball stabilizes, it remains stable forever.
-/
theorem proofBall_stabilizes {k : ℕ}
    (h : D.proofBall k = D.proofBall (k + 1)) (n : ℕ) :
    D.proofBall k = D.proofBall (k + n) := by
  induction' n with n ih;
  · rfl;
  · rw [ ← add_assoc, DerivationSystem.proofBall ];
    rw [ ← ih, ← DerivationSystem.proofBall ] at * ; aesop

/-
Stabilization is equivalent to the frontier being empty.
-/
theorem stable_iff_frontier_empty (k : ℕ) :
    D.proofBall k = D.proofBall (k + 1) ↔ D.frontier k = ∅ := by
  rw [ DerivationSystem.proofBall_succ_eq_union_frontier ];
  simp +decide [ Finset.ext_iff ];
  exact ⟨ fun h a ha => by have := D.frontier_disjoint k; exact Finset.disjoint_left.mp this ( h a ha ) ha, fun h a ha => False.elim ( h a ha ) ⟩

/-
**Fixed-point characterization**: Ball(k) stabilizes if and only if
    it is closed under derivation.
-/
theorem stable_iff_derivation_closed (k : ℕ) :
    D.proofBall k = D.proofBall (k + 1) ↔
    ∀ a ∈ D.proofBall k, D.derives a ⊆ D.proofBall k := by
  simp +decide [ Finset.subset_iff, DerivationSystem.proofBall ];
  grind

/-
In a finite type, proof balls must eventually stabilize.
-/
theorem exists_stabilization_depth :
    ∃ k, D.proofBall k = D.proofBall (k + 1) := by
  by_contra h;
  -- Since the sequence of proof balls is strictly increasing and finite, it must eventually stabilize.
  have h_finite : Set.Finite (Set.range (fun k => D.proofBall k)) := by
    exact Set.toFinite _;
  exact h_finite.not_infinite <| Set.infinite_range_of_injective ( StrictMono.injective <| strictMono_nat_of_lt_succ fun k => lt_of_le_of_ne ( D.proofBall_mono k ) fun h' => h ⟨ k, h' ⟩ )

/-! ### Reachability -/

/-
**Reachability dichotomy**: every statement is either eventually
    derivable or permanently unreachable from the axioms.
-/
theorem reachability_dichotomy (a : α) :
    D.Derivable a ∨ ∀ k, a ∉ D.proofBall k := by
  exact Classical.or_iff_not_imp_left.2 fun h => by simpa [ DerivationSystem.Derivable ] using h;

/-
Derivable statements appear at their derivation depth.
-/
theorem mem_proofBall_derivationDepth {a : α} (h : D.Derivable a) :
    a ∈ D.proofBall (D.derivationDepth a h) := by
  exact Nat.find_spec h

/-
Derivable statements do not appear before their derivation depth.
-/
theorem not_mem_proofBall_lt_derivationDepth {a : α} (h : D.Derivable a)
    {k : ℕ} (hk : k < D.derivationDepth a h) :
    a ∉ D.proofBall k := by
  exact fun h' => hk.not_ge ( Nat.find_min' h h' )

/-! ### Growth Bounds -/

/-
**Additive growth bound**: if the frontier has at least `c` elements at
    each of the first `k` steps, then Ball(k) has at least `|axioms| + k * c`
    elements.
-/
theorem ball_growth_additive_lower {k c : ℕ}
    (hfr : ∀ i, i < k → c ≤ (D.frontier i).card) :
    D.ax.card + k * c ≤ (D.proofBall k).card := by
  induction' k with k ih;
  · aesop;
  · linarith [ ih fun i hi => hfr i ( Nat.lt_succ_of_lt hi ), card_proofBall_succ D k, hfr k ( Nat.lt_succ_self k ) ]

/-- **Depth lower bound from cardinality**: deriving `n` statements from
    `|axioms|` axioms with frontier bounded by `f` requires depth ≥ `(n - |axioms|) / f`. -/
private theorem ball_card_upper {k f : ℕ}
    (hf : ∀ i, i < k → (D.frontier i).card ≤ f) :
    (D.proofBall k).card ≤ D.ax.card + k * f := by
  induction k with
  | zero => simp [DerivationSystem.proofBall]
  | succ k ih =>
    have h1 := card_proofBall_succ D k
    have h2 := hf k (Nat.lt_succ_self k)
    have h3 := ih (fun i hi => hf i (Nat.lt_succ_of_lt hi))
    linarith

/-- **Depth lower bound from cardinality**: deriving `n` statements from
    `|axioms|` axioms with frontier bounded by `f` requires depth ≥ `(n - |axioms|) / f`. -/
theorem depth_lower_bound_from_card {k n f : ℕ}
    (_hf_pos : 0 < f)
    (hf : ∀ i, i < k → (D.frontier i).card ≤ f)
    (hn : n ≤ (D.proofBall k).card) :
    (n - D.ax.card) / f ≤ k := by
  have hup := ball_card_upper D hf
  have h1 : n - D.ax.card ≤ k * f := by omega
  rw [mul_comm] at h1
  exact Nat.div_le_of_le_mul h1

/-! ## Layered Systems -/

/-- A derivation system is layered if derivations from Ball(k) only produce
    statements in Ball(k+1). -/
def IsLayered : Prop :=
  ∀ k, ∀ a ∈ D.proofBall k, D.derives a ⊆ D.proofBall (k + 1)

/-- In a layered system, if the ball grows, there exist new statements. -/
theorem layered_strict_depth
    (_hL : D.IsLayered) {k : ℕ} (hk : D.proofBall k ≠ D.proofBall (k + 1)) :
    ∃ a, a ∈ D.proofBall (k + 1) ∧ a ∉ D.proofBall k := by
  exact Finset.exists_of_ssubset (lt_of_le_of_ne (D.proofBall_mono k) hk)

end DerivationSystem

/-! ## Expansion Witness -/

/-- An expansion witness certifies that a derivation system has additive
    expansion of at least `minFrontier` new derivations per step for
    `steps` many steps. -/
structure ExpansionWitness (D : DerivationSystem α) where
  /-- Number of certified expansion steps. -/
  steps : ℕ
  /-- Minimum new derivations per step. -/
  minFrontier : ℕ
  /-- The frontier is at least `minFrontier` at each step. -/
  expansion_holds : ∀ i, i < steps → minFrontier ≤ (D.frontier i).card

namespace ExpansionWitness

variable {D : DerivationSystem α} (w : ExpansionWitness D)

/-- An expansion witness gives a ball growth lower bound. -/
theorem ball_growth (k : ℕ) (hk : k ≤ w.steps) :
    D.ax.card + k * w.minFrontier ≤ (D.proofBall k).card := by
  exact D.ball_growth_additive_lower (fun i hi => w.expansion_holds i (lt_of_lt_of_le hi hk))

/-- The total number of derivable statements is lower bounded. -/
theorem total_derivable_lower :
    D.ax.card + w.steps * w.minFrontier ≤ (D.proofBall w.steps).card := by
  exact w.ball_growth w.steps le_rfl

end ExpansionWitness

/-! ## Proof Domination -/

/-- System D₁ proof-dominates D₂ if every statement derivable in D₂
    is also derivable in D₁ with at most the same depth. -/
def DerivationSystem.ProofDominates (D₁ D₂ : DerivationSystem α) : Prop :=
  ∀ k, D₂.proofBall k ⊆ D₁.proofBall k

namespace DerivationSystem

/-
Proof domination implies derivability inclusion.
-/
theorem proofDominates_derivable {D₁ D₂ : DerivationSystem α}
    (h : ProofDominates D₁ D₂) {a : α} (ha : D₂.Derivable a) :
    D₁.Derivable a := by
  exact ⟨ _, h _ ha.choose_spec ⟩

/-- A system with more axioms and stronger derivation rules dominates. -/
theorem proofDominates_of_superset {D₁ D₂ : DerivationSystem α}
    (hax : D₂.ax ⊆ D₁.ax)
    (hder : ∀ a, D₂.derives a ⊆ D₁.derives a) :
    ProofDominates D₁ D₂ := by
  intro k
  induction k with
  | zero => exact hax
  | succ k ih =>
    intro x hx
    simp only [DerivationSystem.proofBall, Finset.mem_union, Finset.mem_biUnion] at hx ⊢
    rcases hx with hx | ⟨a, ha, hxa⟩
    · exact Or.inl (ih hx)
    · exact Or.inr ⟨a, ih ha, hder a hxa⟩

end DerivationSystem