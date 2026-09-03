import NumberTheory.BisimulationNominalBudget

/-!
# Cycle 5: the depth hierarchy collapses exactly at the height of the model

`NumberTheory.BisimulationDepthHierarchy` proved that the depth-graded observational
hierarchy is strict at every finite level and that its limit is bisimulation.  That
leaves open where the hierarchy *stops* being strict on a fixed truncation.  This file
settles it: on the worlds `0, …, N` of any tag-indexed frame the hierarchy collapses at
depth exactly `N`.

* `trim` — the depth-`k` trimming of a formula: boxes nested deeper than `k` are
  replaced by verum.  `boxDepth_trim` bounds its depth by `k`, and `satF_trim` shows
  that trimming is invisible at any world `m ≤ k`, because the semantics can only take
  `m` steps downwards before running out of worlds.
* `modEq_of_depthEq_of_le` — **collapse.**  For worlds `m, n ≤ k`, depth-`k` agreement
  already implies full modal equivalence, hence bisimilarity
  (`bisimilar_iff_depthEq_of_le`).
* `collapse_threshold_sharp` — **sharpness.**  Depth `N - 1` does not suffice: the chain
  worlds `N - 1` and `N` agree up to depth `N - 1` and are separated at depth `N`.

So on a model of height `N` the Hennessy–Milner theorem needs exactly `N` rounds: the
infinite ladder of `Hierarchy.full_resolution_hierarchy` is genuinely infinite only
because the truncation level is unbounded.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1, cycle 5): converse well-foundedness should bound the number of
  useful Ehrenfeucht–Fraïssé rounds by the height of the world.
Experiment (Stage 2): formalised as a syntactic trimming operator, which is stronger
  than a game argument: every formula is *equal in truth value* at a world `m ≤ k` to
  one of box depth `≤ k`.
Analysis (Stage 3): the bound is tight — the chain frame realises the worst case — and
  the collapse is uniform in the frame and the valuation.
Critique (Stage 4): `satF_trim` is proved for all worlds `m ≤ k`, not just for the
  truncation root, so the statement does not secretly depend on the choice of the
  distinguished world.
-/

namespace PhysicsConsistency

open ProofSystemCollapse
open Form
open Bisim
open Hierarchy

namespace Collapse

variable {R R' : ℕ → ℕ → ℕ → Bool} {V V' : ℕ → ℕ → Bool}

/-! ## §1. Depth trimming -/

/-- `trim k a` replaces every box nested more than `k` deep in `a` by verum. -/
def trim : ℕ → Form → Form
  | _, bot => bot
  | _, atom p => atom p
  | k, imp a b => imp (trim k a) (trim k b)
  | 0, box _ _ => fTop
  | k + 1, box i a => box i (trim k a)

theorem boxDepth_trim : ∀ (a : Form) (k : ℕ), boxDepth (trim k a) ≤ k := by
  intro a
  induction a with
  | bot => intro k; simp [trim]
  | atom p => intro k; simp [trim, boxDepth]
  | imp a b iha ihb =>
      intro k
      simp only [trim, boxDepth, max_le_iff]
      exact ⟨iha k, ihb k⟩
  | box i a ih =>
      intro k
      match k with
      | 0 => simp [trim, fTop, boxDepth]
      | k + 1 =>
          simp only [trim, boxDepth_box]
          exact Nat.succ_le_succ (ih k)

/-- **Trimming is invisible below the trimming level.**  At a world `m ≤ k` no formula
can look more than `m` steps down, so its depth-`k` trimming has the same truth
value. -/
theorem satF_trim : ∀ (a : Form) (k m : ℕ), m ≤ k → satF R V m (trim k a) = satF R V m a := by
  intro a
  induction a with
  | bot => intro k m _; rfl
  | atom p => intro k m _; rfl
  | imp a b iha ihb =>
      intro k m hm
      simp only [trim, satF, iha k m hm, ihb k m hm]
  | box i a ih =>
      intro k m hm
      match k with
      | 0 =>
          have hm0 : m = 0 := Nat.le_zero.1 hm
          subst hm0
          rw [Bool.eq_iff_iff]
          simp only [trim, satF_fTop, satF_box, true_iff]
          intro n hn
          omega
      | k + 1 =>
          rw [Bool.eq_iff_iff]
          simp only [trim, satF_box]
          constructor
          · intro h n hn hR
            rw [← ih k n (by omega)]
            exact h n hn hR
          · intro h n hn hR
            rw [ih k n (by omega)]
            exact h n hn hR

/-! ## §2. Collapse of the hierarchy at the height of the model -/

/-- **The depth hierarchy collapses at the height of the models.**  Two worlds of
height at most `k` that agree on all formulas of box depth `≤ k` agree on *all*
formulas. -/
theorem modEq_of_depthEq_of_le {k m n : ℕ} (hm : m ≤ k) (hn : n ≤ k)
    (h : DepthEq k R V R' V' m n) : ModEq R V R' V' m n := by
  intro a
  rw [← satF_trim (R := R) (V := V) a k m hm, ← satF_trim (R := R') (V := V') a k n hn]
  exact h (trim k a) (boxDepth_trim a k)

/-- Equivalently: on worlds of height at most `k`, depth-`k` observation already
resolves the models up to bisimulation. -/
theorem bisimilar_iff_depthEq_of_le {k m n : ℕ} (hm : m ≤ k) (hn : n ≤ k) :
    Bisimilar R V R' V' m n ↔ DepthEq k R V R' V' m n := by
  constructor
  · intro hb a _
    exact modEq_of_bisimilar hb a
  · intro hd
    exact bisimilar_iff_modEq.2 (modEq_of_depthEq_of_le hm hn hd)

/-- Consequently every interpretation invariant under depth-`k` observation agrees on
all bisimilar pairs of worlds of height at most `k`, and conversely. -/
theorem depthEq_iff_modEq_of_le {k m n : ℕ} (hm : m ≤ k) (hn : n ≤ k) :
    DepthEq k R V R' V' m n ↔ ModEq R V R' V' m n :=
  ⟨modEq_of_depthEq_of_le hm hn, fun h a _ => h a⟩

/-! ## §3. Sharpness -/

/-- **The threshold is sharp.**  On the chain frame the worlds `N` and `N + 1` — of
height `N` and `N + 1` — agree up to depth `N` but are separated at depth `N + 1`; so
depth `N` does *not* suffice for worlds of height `N + 1`, while by
`modEq_of_depthEq_of_le` depth `N + 1` does. -/
theorem collapse_threshold_sharp (N : ℕ) :
    DepthEq N chainR chainV chainR chainV N (N + 1) ∧
      ¬ DepthEq (N + 1) chainR chainV chainR chainV N (N + 1) ∧
      (∀ (R R' : ℕ → ℕ → ℕ → Bool) (V V' : ℕ → ℕ → Bool) (m n : ℕ), m ≤ N + 1 → n ≤ N + 1 →
        DepthEq (N + 1) R V R' V' m n → ModEq R V R' V' m n) :=
  ⟨depthEq_chain_succ N, not_depthEq_succ_chain N,
    fun _ _ _ _ _ _ hm hn h => modEq_of_depthEq_of_le hm hn h⟩

end Collapse

end PhysicsConsistency