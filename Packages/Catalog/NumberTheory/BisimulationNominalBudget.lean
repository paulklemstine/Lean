import NumberTheory.BisimulationTheoryTransfer

/-!
# Cycle 4: the naming budget that collapses the resolution hierarchy

Cycle 2 showed that *nominal* valuations — one atom per world — collapse the whole
resolution hierarchy: modal equivalence becomes identity of worlds
(`Beyond.eq_of_modEq_nominal`).  That is a wasteful language: it needs one atom per
world.  This file determines the true budget.

* **Upper bound** (`eq_of_atomicEq_binV`).  With the *binary naming* valuation
  `binV m p = m.testBit p`, agreement on the first `k` atoms already forces equality of
  any two worlds below `2 ^ k`.  So `k` atoms name `2 ^ k` worlds, and the collapse
  happens in the atomic (box-depth `0`) fragment: `pointedIso_of_modEq_binV`.
* **Lower bound** (`exists_atomic_collision`).  No valuation whatsoever can do better:
  as soon as the truncation level reaches `2 ^ k`, any language with `k` atoms has two
  distinct worlds of the same atomic type (pigeonhole on `Fin k → Bool`).
* **Threshold** (`nominal_budget_threshold`).  Combining the two: `⌈log₂ N⌉` atoms are
  necessary and sufficient for the atomic fragment to separate the worlds `0, …, N`,
  and at that budget the entire hierarchy
  `DepthInv k ⊊ ModalInv = BisimInv ⊊ IsoInv` collapses to a single point.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1, cycle 4): naming is a coding problem, so the budget should be
  logarithmic rather than linear in the number of worlds.
Experiment (Stage 2): the binary valuation realises the logarithmic upper bound and a
  pigeonhole on atomic types gives the matching lower bound, both for arbitrary frames.
Analysis (Stage 3): the collapse is entirely atomic — no modality is needed — which
  explains why the gap of cycles 1–2 required *atom-poor* witnesses (the constant
  valuation `multV`, `shV`).
Critique (Stage 4): the lower bound is about the atomic fragment only; it does not
  claim that `k` atoms with modalities cannot separate more worlds, and indeed a frame
  can separate worlds structurally.  The statement is therefore guarded: it says that
  *naming* (as opposed to observing behaviour) is impossible below the budget.
-/

namespace PhysicsConsistency

open ProofSystemCollapse
open Form
open Bisim
open MultGap
open Beyond

namespace Budget

/-! ## §1. Binary naming -/

/-- The **binary naming valuation**: the atom `p` is true at the world `m` iff the
`p`-th bit of `m` is set.  `k` atoms describe `2 ^ k` worlds. -/
def binV : ℕ → ℕ → Bool := fun m p => m.testBit p

/-- Agreement of the first `k` atoms determines a world below `2 ^ k`. -/
theorem eq_of_testBit_below {k m n : ℕ} (hm : m < 2 ^ k) (hn : n < 2 ^ k)
    (h : ∀ p < k, m.testBit p = n.testBit p) : m = n := by
  refine Nat.eq_of_testBit_eq fun p => ?_
  by_cases hp : p < k
  · exact h p hp
  · rw [Nat.testBit_lt_two_pow
        (lt_of_lt_of_le hm (Nat.pow_le_pow_right (by norm_num) (by omega))),
      Nat.testBit_lt_two_pow
        (lt_of_lt_of_le hn (Nat.pow_le_pow_right (by norm_num) (by omega)))]

/-- **Atomic agreement with `k` atoms of the binary naming determines the world.**
Only the box-depth-`0` fragment is used. -/
theorem eq_of_atomicEq_binV {R R' : ℕ → ℕ → ℕ → Bool} {k m n : ℕ} (hm : m < 2 ^ k)
    (hn : n < 2 ^ k) (h : ∀ p < k, satF R binV m (atom p) = satF R' binV n (atom p)) :
    m = n :=
  eq_of_testBit_below hm hn (fun p hp => h p hp)

/-- **Logarithmically many atoms close the gap.**  Modally equivalent worlds below
`2 ^ k` of a frame carrying the binary naming are equal, hence isomorphic. -/
theorem pointedIso_of_modEq_binV {R : ℕ → ℕ → ℕ → Bool} {k m n : ℕ} (hm : m < 2 ^ k)
    (hn : n < 2 ^ k) (h : ModEq R binV R binV m n) :
    Nonempty (PointedIso R binV R binV m n) := by
  obtain rfl : m = n := eq_of_atomicEq_binV hm hn (fun p _ => h (atom p))
  exact ⟨pointedIsoRefl R binV m⟩

/-- With the binary naming, even the multiplicity observation becomes modally
invariant on the truncation — the gap of cycle 1 is gone. -/
theorem outDeg_congr_of_modEq_binV {R : ℕ → ℕ → ℕ → Bool} {k m n : ℕ} (hm : m < 2 ^ k)
    (hn : n < 2 ^ k) (h : ModEq R binV R binV m n) (j : ℕ) :
    outDeg R j m = outDeg R j n := by
  obtain rfl : m = n := eq_of_atomicEq_binV hm hn (fun p _ => h (atom p))
  rfl

/-! ## §2. The matching lower bound -/

/-- **No language with `k` atoms can name `2 ^ k + 1` worlds.**  Whatever the
valuation, once the truncation level reaches `2 ^ k` two distinct worlds share their
atomic type. -/
theorem exists_atomic_collision {k N : ℕ} (hN : 2 ^ k ≤ N) (V : ℕ → ℕ → Bool) :
    ∃ m n, m ≤ N ∧ n ≤ N ∧ m ≠ n ∧ ∀ p < k, V m p = V n p := by
  classical
  have hcard : (Finset.univ : Finset (Fin k → Bool)).card < (Finset.range (2 ^ k + 1)).card := by
    simp
  obtain ⟨m, hm, n, hn, hmn, heq⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to hcard
      (f := fun m => fun p : Fin k => V m (p : ℕ)) (fun m _ => Finset.mem_univ _)
  refine ⟨m, n, ?_, ?_, hmn, fun p hp => ?_⟩
  · have := Finset.mem_range.1 hm; omega
  · have := Finset.mem_range.1 hn; omega
  · exact congrFun heq ⟨p, hp⟩

/-- **The naming threshold.**  With `k` atoms:

* (sufficiency) the binary valuation separates all worlds below `2 ^ k` already in the
  atomic fragment, so modal equivalence there is identity and every interpretation —
  including the multiplicity observation — becomes modally invariant;
* (necessity) if the truncation reaches `2 ^ k`, *no* valuation separates all worlds
  atomically.

So `⌈log₂ N⌉` atoms is the exact budget at which the observational hierarchy of
cycles 1–3 collapses. -/
theorem nominal_budget_threshold (k : ℕ) :
    (∀ (R : ℕ → ℕ → ℕ → Bool) (m n : ℕ), m < 2 ^ k → n < 2 ^ k →
        ModEq R binV R binV m n → Nonempty (PointedIso R binV R binV m n)) ∧
      (∀ (N : ℕ), 2 ^ k ≤ N → ∀ V : ℕ → ℕ → Bool,
        ∃ m n, m ≤ N ∧ n ≤ N ∧ m ≠ n ∧ ∀ p < k, V m p = V n p) :=
  ⟨fun _ _ _ hm hn h => pointedIso_of_modEq_binV hm hn h,
    fun _ hN V => exists_atomic_collision hN V⟩

/-- **The gap needs atom-poverty.**  The witnesses of cycles 1 and 2 both carry the
constant valuation, and by the threshold above that is not an accident: a frame whose
valuation separates its worlds atomically has no bisimulation/isomorphism gap at all.
Here the two facts are put side by side. -/
theorem gap_requires_atom_poverty :
    (ModEq multR multV multR multV 3 4 ∧
        IsEmpty (PointedIso multR multV multR multV 3 4)) ∧
      (∀ (R : ℕ → ℕ → ℕ → Bool) (m n : ℕ), m < 2 ^ 3 → n < 2 ^ 3 →
        ModEq R binV R binV m n → Nonempty (PointedIso R binV R binV m n)) :=
  ⟨⟨modEq_three_four, isEmpty_pointedIso_three_four⟩,
    fun _ _ _ hm hn h => pointedIso_of_modEq_binV hm hn h⟩

end Budget

end PhysicsConsistency