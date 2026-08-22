/-
# Cycle 6, Part IV: The Frobenius Threshold — Aperiodicity Without a Self-Loop

Part III obtained primitivity of an irreducible chain from a *single self-loop*, by path
padding.  That hypothesis is a genuine restriction: the deterministic `n`-cycle is
irreducible and loopless, and its soundness spectrum `nℕ` is not cofinite.  The correct
general hypothesis is arithmetic rather than combinatorial, and this file supplies it.

## The mechanism

The set of return lengths at a world is closed under addition and contains `0`, so it is
an **additive submonoid of `ℕ`** (`cycleMonoid`) — this is Part I's `iterR_add` in
disguise.  Consequently the Chicken McNugget theorem applies verbatim: if a world has
two coprime return lengths `a, b > 1`, every integer exceeding the Frobenius number
`ab - a - b` is a return length.

## Main results

* `cycleMonoid` — the return lengths of a world form an `AddSubmonoid ℕ`; its carrier is
  the Cycle-2 soundness spectrum (`cycleMonoid_eq_soundMonoid`).
* `iterR_of_gt_frobenius` — **coprime cycles give all long cycles**: from `iterR F a w w`
  and `iterR F b w w` with `Nat.Coprime a b`, `1 < a`, `1 < b`, one gets `iterR F k w w`
  for every `k > a * b - a - b`.
* `iterSound_of_gt_frobenius` — hence internal soundness of *every* degree above the
  Frobenius number, with **no self-loop anywhere in the frame**.
* `exists_uniform_primitive_of_coprime_cycles` and
  `stepPow_pos_of_coprime_cycles` — an irreducible finite chain possessing one state with
  two coprime return lengths is primitive, with an explicit uniform exponent.  This
  strictly generalises Part III, whose hypothesis `0 < P w w` is the degenerate case
  `a = 1`.
* `apChain_spectrum` — a fully explicit witness: the loopless `3`-state chain
  `0 → 1 → {0, 2} → 0` has soundness spectrum exactly `{0} ∪ {k | 2 ≤ k}`, a cofinite set
  with a single gap at `k = 1`.  This is the numerical semigroup `⟨2,3⟩`, Frobenius
  number `1`.

## Relationship to the catalog
Builds on `Probability.MarkovPrimitivity` (`FrameIrreducible`, `iterR_of_add_le`),
Part I (`iterR_add`, `soundMonoid`, `stepPow_pos_iff`, `RowStochastic`), Cycle 2's
`IterSoundAt` / `iterSound_iff_cycle`, and Mathlib's `frobeniusNumber_pair`.
-/

import Mathlib
import Probability.MarkovPrimitivity

namespace MarkovModal

open GLPLogic TangledSoundness FrameDefinability

variable {S : Type} {α : Type}

/-! ## Part A — The return lengths of a world form a submonoid -/

/-- **The cycle monoid of a world**: the set of lengths of closed paths at `w`.  It is an
additive submonoid of `ℕ` purely by path concatenation (`iterR_add`), with no
hypotheses on the frame whatsoever. -/
def cycleMonoid (F : KFrame) (w : F.W) : AddSubmonoid ℕ where
  carrier := {k | iterR F k w w}
  zero_mem' := rfl
  add_mem' := fun {n m} hn hm => (iterR_add F m n w w).mpr ⟨w, hn, hm⟩

@[simp] theorem mem_cycleMonoid (F : KFrame) (w : F.W) (k : ℕ) :
    k ∈ cycleMonoid F w ↔ iterR F k w w := Iff.rfl

/-- The cycle monoid *is* the Cycle-2 soundness spectrum. -/
theorem cycleMonoid_eq_soundMonoid (F : KFrame) (p : α) (w : F.W) :
    (cycleMonoid F w : Set ℕ) = (soundMonoid F α p w : Set ℕ) := by
  ext k
  exact (iterSound_iff_cycle F p k w).symm

/-! ## Part B — The Frobenius threshold -/

/-- **Coprime cycles generate all long cycles.**  Mathlib's Chicken McNugget theorem,
transported along `cycleMonoid`: two coprime closed paths of lengths `a, b > 1` at `w`
force closed paths of *every* length beyond `a * b - a - b`. -/
theorem iterR_of_gt_frobenius (F : KFrame) {w : F.W} {a b : ℕ} (hab : Nat.Coprime a b)
    (ha : 1 < a) (hb : 1 < b) (hca : iterR F a w w) (hcb : iterR F b w w)
    {k : ℕ} (hk : a * b - a - b < k) : iterR F k w w := by
  have hclosure : AddSubmonoid.closure ({a, b} : Set ℕ) ≤ cycleMonoid F w := by
    refine AddSubmonoid.closure_le.mpr ?_
    rintro x (rfl | rfl)
    · exact hca
    · exact hcb
  have hmem : k ∈ AddSubmonoid.closure ({a, b} : Set ℕ) :=
    (frobeniusNumber_iff.mp (frobeniusNumber_pair hab ha hb)).2 k hk
  exact hclosure hmem

/-- **Internal soundness of every high degree, with no self-loop.**  A world with two
coprime return lengths validates `□ᵏφ → φ` for every `k` above the Frobenius number of
those lengths. -/
theorem iterSound_of_gt_frobenius (F : KFrame) (p : α) {w : F.W} {a b : ℕ}
    (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b)
    (hca : iterR F a w w) (hcb : iterR F b w w) {k : ℕ} (hk : a * b - a - b < k) :
    IterSoundAt F α k w :=
  (iterSound_iff_cycle F p k w).mpr (iterR_of_gt_frobenius F hab ha hb hca hcb hk)

/-- **Padding through a Frobenius-saturated world.**  Any approach of length `c` and exit
of length `d` through `w` can be inflated to a path of every length beyond
`c + d + (a * b - a - b)`. -/
theorem iterR_of_gt_frobenius_pad (F : KFrame) {u v w : F.W} {a b : ℕ}
    (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b)
    (hca : iterR F a w w) (hcb : iterR F b w w) {c d : ℕ}
    (hc : iterR F c u w) (hd : iterR F d w v) :
    ∀ n : ℕ, c + d + (a * b - a - b) < n → iterR F n u v := by
  intro n hn
  have hk : a * b - a - b < n - c - d := by omega
  have hloop : iterR F (n - c - d) w w := iterR_of_gt_frobenius F hab ha hb hca hcb hk
  have hsplit : n = c + ((n - c - d) + d) := by omega
  rw [hsplit]
  refine (iterR_add F ((n - c - d) + d) c u v).mpr ⟨w, hc, ?_⟩
  exact (iterR_add F d (n - c - d) w v).mpr ⟨w, hloop, hd⟩

/-- **Primitivity without a self-loop.**  An irreducible finite frame with one world
carrying two coprime cycle lengths has all sufficiently long paths between all pairs of
worlds. -/
theorem exists_uniform_primitive_of_coprime_cycles (F : KFrame) [Fintype F.W]
    [DecidableEq F.W] (hirr : FrameIrreducible F) {w : F.W} {a b : ℕ}
    (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b)
    (hca : iterR F a w w) (hcb : iterR F b w w) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → ∀ u v : F.W, iterR F n u v := by
  have hpair : ∀ q : F.W × F.W, ∃ N : ℕ, ∀ n : ℕ, N ≤ n → iterR F n q.1 q.2 := by
    rintro ⟨u, v⟩
    obtain ⟨c, hc⟩ := hirr u w
    obtain ⟨d, hd⟩ := hirr w v
    exact ⟨c + d + (a * b - a - b) + 1,
      fun n hn => iterR_of_gt_frobenius_pad F hab ha hb hca hcb hc hd n (by omega)⟩
  choose Npair hNpair using hpair
  refine ⟨Finset.univ.sup Npair, fun n hn u v => ?_⟩
  exact hNpair (u, v) n (le_trans (Finset.le_sup (Finset.mem_univ (u, v))) hn)

/-- The probabilistic form: **an irreducible chain with coprime return times at one state
is primitive**, with a uniform exponent, even if no state has positive holding
probability. -/
theorem stepPow_pos_of_coprime_cycles [Fintype S] [DecidableEq S] {P : S → S → ℝ}
    (hP : ∀ u v, 0 ≤ P u v) (hirr : ChainIrreducible P) {w : S} {a b : ℕ}
    (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b)
    (hca : 0 < stepPow P a w w) (hcb : 0 < stepPow P b w w) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → ∀ u v : S, 0 < stepPow P n u v := by
  obtain ⟨N, hN⟩ :=
    @exists_uniform_primitive_of_coprime_cycles (suppFrame P) ‹Fintype S› ‹DecidableEq S›
      ((chainIrreducible_iff_frameIrreducible hP).mp hirr) w a b hab ha hb
      ((stepPow_pos_iff hP a w w).mp hca) ((stepPow_pos_iff hP b w w).mp hcb)
  exact ⟨N, fun n hn u v => (stepPow_pos_iff hP n u v).mpr (hN n hn u v)⟩

/-! ## Part C — An explicit loopless aperiodic witness

`apChain` is the `3`-state chain `0 → 1` surely, `1 → 0` or `1 → 2` with probability
`1/2` each, `2 → 0` surely.  It has no self-loop at all, yet cycles of lengths `2` and
`3`, hence a cofinite soundness spectrum with a single gap. -/

/-- The loopless aperiodic `3`-state chain, as a transition matrix. -/
noncomputable def apChain : Fin 3 → Fin 3 → ℝ :=
  ![![0, 1, 0], ![1 / 2, 0, 1 / 2], ![1, 0, 0]]

attribute [local simp] Matrix.cons_val_two Matrix.tail_cons Matrix.head_cons

theorem apChain_nonneg : ∀ u v, 0 ≤ apChain u v := by
  intro u v
  fin_cases u <;> fin_cases v <;> norm_num [apChain]

theorem apChain_rowStochastic : RowStochastic apChain := by
  refine ⟨apChain_nonneg, fun u => ?_⟩
  rw [Fin.sum_univ_three]
  fin_cases u <;> norm_num [apChain]

theorem apChain_R01 : (suppFrame apChain).R (0 : Fin 3) (1 : Fin 3) := by
  show (0 : ℝ) < apChain 0 1
  norm_num [apChain]

theorem apChain_R10 : (suppFrame apChain).R (1 : Fin 3) (0 : Fin 3) := by
  show (0 : ℝ) < apChain 1 0
  norm_num [apChain]

theorem apChain_R12 : (suppFrame apChain).R (1 : Fin 3) (2 : Fin 3) := by
  show (0 : ℝ) < apChain 1 2
  norm_num [apChain]

theorem apChain_R20 : (suppFrame apChain).R (2 : Fin 3) (0 : Fin 3) := by
  show (0 : ℝ) < apChain 2 0
  norm_num [apChain]

theorem apChain_no_selfLoop : ∀ w : Fin 3, ¬ (suppFrame apChain).R w w := by
  intro w hw
  have h : (0 : ℝ) < apChain w w := hw
  revert h
  fin_cases w <;> norm_num [apChain]

/-- A closed path of length `2` at state `0`. -/
theorem apChain_cycle2 : iterR (suppFrame apChain) 2 (0 : Fin 3) (0 : Fin 3) :=
  ⟨(1 : Fin 3), apChain_R01, ⟨(0 : Fin 3), apChain_R10, rfl⟩⟩

/-- A closed path of length `3` at state `0`. -/
theorem apChain_cycle3 : iterR (suppFrame apChain) 3 (0 : Fin 3) (0 : Fin 3) :=
  ⟨(1 : Fin 3), apChain_R01, ⟨(2 : Fin 3), apChain_R12, ⟨(0 : Fin 3), apChain_R20, rfl⟩⟩⟩

/-- **The spectrum of a loopless aperiodic chain.**  State `0` of `apChain` has internal
soundness of degree `k` exactly for `k = 0` and `k ≥ 2`: the numerical semigroup `⟨2,3⟩`,
cofinite with the single gap `k = 1` predicted by the Frobenius number
`2 * 3 - 2 - 3 = 1`.  Note the chain has **no** self-loop, so Part III's hypothesis fails
while the conclusion still holds — the Frobenius route is strictly stronger. -/
theorem apChain_spectrum (p : α) (k : ℕ) :
    IterSoundAt (suppFrame apChain) α k (0 : Fin 3) ↔ (k = 0 ∨ 2 ≤ k) := by
  constructor
  · intro h
    rcases Nat.lt_or_ge k 2 with hk | hk
    · interval_cases k
      · exact Or.inl rfl
      · exfalso
        have hcyc : iterR (suppFrame apChain) 1 (0 : Fin 3) (0 : Fin 3) :=
          (iterSound_iff_cycle (suppFrame apChain) p 1 (0 : Fin 3)).mp h
        obtain ⟨z, hz, hzv⟩ := hcyc
        have hz0 : z = (0 : Fin 3) := hzv
        exact apChain_no_selfLoop (0 : Fin 3) (hz0 ▸ hz)
    · exact Or.inr hk
  · rintro (rfl | hk)
    · exact iterSound_zero _ _
    · exact iterSound_of_gt_frobenius (suppFrame apChain) p (by decide) (by norm_num)
        (by norm_num) apChain_cycle2 apChain_cycle3 (by omega)

/-- **Capstone for Part IV.**  `apChain` is a nonempty finite row-stochastic chain with
no self-loop, hence Part III's primitivity hypothesis fails for it; nevertheless its
soundness spectrum is cofinite, its modal system is consistent, proves its own
consistency, and is not Löbian, and it does *not* internalise its full soundness
schema. -/
theorem apChain_capstone (p : α) :
    (∀ w : Fin 3, ¬ (suppFrame apChain).R w w) ∧
    (∀ k : ℕ, 2 ≤ k → IterSoundAt (suppFrame apChain) α k (0 : Fin 3)) ∧
    ¬ IterSoundAt (suppFrame apChain) α 1 (0 : Fin 3) ∧
    (markovSystem apChain α).Consistent ∧
    (markovSystem apChain α).Thm (MFormula.con (α := α)) ∧
    ¬ (markovSystem apChain α).ProvesLoebAxiom ∧
    ¬ (markovSystem apChain α).ProvesReflection := by
  refine ⟨apChain_no_selfLoop, fun k hk => (apChain_spectrum p k).mpr (Or.inr hk),
    fun h => ?_, markovSystem_consistent _,
    markovSystem_proves_con apChain_rowStochastic,
    markovSystem_not_provesLoebAxiom apChain_rowStochastic, fun h => ?_⟩
  · rcases (apChain_spectrum p 1).mp h with h1 | h1 <;> omega
  · exact apChain_no_selfLoop (0 : Fin 3)
      ((markovSystem_provesReflection_iff apChain p).mp h (0 : Fin 3))

end MarkovModal

-- !-- Lab Notes -- !--
--
-- Hypothesis (Hypothesizer):
--   H29. (Bold) Part III's self-loop hypothesis is an artefact.  The real hypothesis is
--        arithmetic: the *cycle monoid* of a world should be an honest additive
--        submonoid of `ℕ`, and cofiniteness of the soundness spectrum should be exactly
--        the numerical-semigroup condition, with the Frobenius number as the threshold.
--   H30. There should be a small, fully explicit, *loopless* chain realising this:
--        cofinite spectrum with a genuine gap, which no self-loop argument can produce.
--
-- Experiment (Experimenter):
--   H29: confirmed.  `cycleMonoid` needs nothing but `iterR_add`, and
--        `AddSubmonoid.closure_le` plus Mathlib's `frobeniusNumber_pair` immediately
--        yields `iterR_of_gt_frobenius`.  Padding
--        (`iterR_of_gt_frobenius_pad`) then upgrades this to full primitivity
--        (`exists_uniform_primitive_of_coprime_cycles`,
--        `stepPow_pos_of_coprime_cycles`) with the explicit uniform exponent
--        `sup_{u,v} (c(u,w) + d(w,v) + ab - a - b + 1)`.
--        Part III's `exists_uniform_primitive` is the degenerate case `a = 1`, which the
--        Frobenius statement cannot literally absorb (Chicken McNugget requires
--        `1 < a`), so both routes are kept.
--   H30: confirmed, `apChain` and `apChain_spectrum`.  The predicted gap is at
--        `k = 1` (`2 * 3 - 2 - 3 = 1`), and the computed spectrum
--        `{0} ∪ {k ≥ 2}` matches the exact rational computation recorded in
--        `ComputationalEvidence.md` §5 term for term.
--
-- Analysis (Analyst):
--   The three regimes of Part III's trichotomy are now explained by a single invariant:
--   the cycle monoid.  Löb frames have cycle monoid `{0}`; the `n`-cycle has `nℕ`
--   (gcd `n`); a chain with coprime cycles has a cofinite monoid.  Cofiniteness is
--   exactly "gcd of the generators is 1", and the threshold is a Frobenius number.
--   The self-loop hypothesis of Part III is simply the case where `1` is a generator.
--
-- Critique (Critic):
--   * `apChain_spectrum` is a genuine `iff`, both directions proved: the forward
--     direction rules out `k = 1` from `apChain_no_selfLoop`, so the statement is not
--     one-sided and the gap is real, not merely unproved.
--   * The two-generator restriction is inherited from `frobeniusNumber_pair`; the fully
--     general statement (any generating set with gcd 1) remains open and is retained as
--     Future Direction 1.
--   * `1 < a` and `1 < b` are required by Chicken McNugget.  Dropping them is not a
--     weakening but a different theorem (`a = 1` is Part III).
--   * No theorem here is closed by `native_decide`; the single `decide` discharges the
--     numeric side condition `Nat.Coprime 2 3` only.