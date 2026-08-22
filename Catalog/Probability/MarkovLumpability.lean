/-
# Cycle 6, Part II: Lumpability is a Bounded Morphism, and the Period is a Soundness
# Spectrum

Part I (`Probability.MarkovModalDefinability`) attached to every matrix `P` a Kripke
frame `suppFrame P` and a Cycle-4 `ModalSystem` `markovSystem P`, and translated the
Cycle-1/2/5 vocabulary into probabilistic terms.  This file supplies the two things that
turn that dictionary into a *functorial* theory.

## 1. Lumpability = bounded morphism

The classical notion of **(strong) lumpability** of a Markov chain — a state map `f`
under which the aggregated transition probabilities depend only on the block of the
source — is *exactly* the condition making `f` a bounded morphism of support frames
(`lumpMorphism`).  Consequently Cycle 5's transfer principle applies verbatim:

* `Valid_of_lumpable` — frame validity transfers from a chain to any lumping of it;
* `markovSystem_thm_of_lumpable` — **lumping only adds theorems**: the modal system of
  the lumped chain extends that of the original;
* `provesReflection_of_lumpable` — **internalised soundness is a lumping invariant**:
  a lazy chain lumps only to lazy chains.

## 2. The period of a state is its soundness spectrum

For the deterministic `n`-cycle `cycleChain n` on `ZMod n` we compute everything:

* `iterR_cycleChain` — `k`-step accessibility is `v = u + k` in `ZMod n`;
* `iterSound_cycleChain_iff` — **`w` has internal soundness of degree `k` iff `n ∣ k`**;
* `soundMonoid_cycleChain` — hence the Cycle-2 soundness spectrum of the `n`-cycle is
  the numerical semigroup `nℕ`.  Internal soundness degree = return time = period.

## 3. The two combine

`ZMod.castHom` for `m ∣ n` is a lumping of the `n`-cycle onto the `m`-cycle
(`cycleLumpable`), so `Thm (n-cycle) ⊆ Thm (m-cycle)` (`cycleSystem_thm_mono`) — the
modal-theory inclusion mirrors the spectrum inclusion `nℕ ⊆ mℕ`.  Taking `n = 2`,
`m = 1` gives a purely probabilistic proof that **non-laziness is not modally
definable** (`nonlazy_not_definable`): no modal axiom set can prevent a chain from
having a positive holding probability.

## Relationship to the catalog
Uses `FrameDefinability.BoundedMorphism`, `Valid_of_boundedMorphism_surjective`,
`Defines` (Cycle 5, `Combinatorics.ModalFrameDefinabilityLimits`), the Cycle-1/2
vocabulary `iterR`, `IterSoundAt`, `iterSound_iff_cycle`, Cycle 4's `ModalSystem`, and
Part I's `suppFrame`, `markovSystem`, `soundMonoid`, `RowStochastic`.
-/

import Mathlib
import Combinatorics.ModalFrameDefinabilityLimits
import Probability.MarkovModalDefinability

namespace MarkovModal

open GLPLogic TangledSoundness FrameDefinability

variable {S T : Type} {α : Type}

/-! ## Part A — A positivity helper -/

/-- A positive finite sum of nonnegative reals has a positive summand. -/
theorem exists_pos_of_sum_pos {β : Type} {s : Finset β} {f : β → ℝ}
    (hf : ∀ i ∈ s, 0 ≤ f i) (h : 0 < ∑ i ∈ s, f i) : ∃ i ∈ s, 0 < f i := by
  by_contra hno
  push_neg at hno
  have hz : ∑ i ∈ s, f i = 0 :=
    Finset.sum_eq_zero fun i hi => le_antisymm (hno i hi) (hf i hi)
  rw [hz] at h
  exact lt_irrefl 0 h

/-! ## Part B — Lumpability and bounded morphisms -/

/-- **Strong lumpability.**  `f : S → T` lumps the chain `P` onto the chain `Q` when the
total probability of moving from `u` into the block `f⁻¹(y)` depends on `u` only through
its own block, and equals `Q (f u) y`. -/
def Lumpable [Fintype S] [DecidableEq T] (P : S → S → ℝ) (Q : T → T → ℝ) (f : S → T) :
    Prop :=
  ∀ (u : S) (y : T), ∑ v ∈ Finset.univ.filter (fun v => f v = y), P u v = Q (f u) y

/-- **Lumpability is a bounded morphism of support frames.**  `forth` is the observation
that a single positive transition is a lower bound for the block sum; `back` is the
observation that a positive block sum must contain a positive transition. -/
def lumpMorphism [Fintype S] [DecidableEq T] {P : S → S → ℝ} {Q : T → T → ℝ} {f : S → T}
    (hPnn : ∀ u v, 0 ≤ P u v) (hlump : Lumpable P Q f) :
    BoundedMorphism (suppFrame P) (suppFrame Q) where
  toFun := f
  forth := by
    intro w v hwv
    have hmem : v ∈ Finset.univ.filter (fun x => f x = f v) := by
      simp
    have hle : P w v ≤ ∑ x ∈ Finset.univ.filter (fun x => f x = f v), P w x :=
      Finset.single_le_sum (f := fun x => P w x) (fun x _ => hPnn w x) hmem
    have : (0 : ℝ) < ∑ x ∈ Finset.univ.filter (fun x => f x = f v), P w x :=
      lt_of_lt_of_le hwv hle
    rw [hlump w (f v)] at this
    exact this
  back := by
    intro w u hu
    have hpos : (0 : ℝ) < ∑ x ∈ Finset.univ.filter (fun x => f x = u), P w x := by
      rw [hlump w u]; exact hu
    obtain ⟨v, hv, hvpos⟩ :=
      exists_pos_of_sum_pos (fun x _ => hPnn w x) hpos
    refine ⟨v, hvpos, ?_⟩
    simpa using (Finset.mem_filter.mp hv).2

/-- **Validity transfers along a surjective lumping.** -/
theorem Valid_of_lumpable [Fintype S] [DecidableEq T] {P : S → S → ℝ} {Q : T → T → ℝ}
    {f : S → T} (hPnn : ∀ u v, 0 ≤ P u v) (hlump : Lumpable P Q f)
    (hsurj : Function.Surjective f) {φ : MFormula α} (h : Valid (suppFrame P) α φ) :
    Valid (suppFrame Q) α φ :=
  Valid_of_boundedMorphism_surjective (lumpMorphism hPnn hlump) hsurj h

/-- **Lumping only adds theorems.**  The modal system of the aggregated chain contains
every theorem of the original chain. -/
theorem markovSystem_thm_of_lumpable [Fintype S] [DecidableEq T] {P : S → S → ℝ}
    {Q : T → T → ℝ} {f : S → T} (hPnn : ∀ u v, 0 ≤ P u v) (hlump : Lumpable P Q f)
    (hsurj : Function.Surjective f) {φ : MFormula α} (h : (markovSystem P α).Thm φ) :
    (markovSystem Q α).Thm φ :=
  Valid_of_lumpable hPnn hlump hsurj h

/-- **Internalised soundness is a lumping invariant.**  If a chain is lazy (every state
has positive holding probability) then so is every surjective lumping of it, hence the
lumped system also proves its own soundness schema. -/
theorem provesReflection_of_lumpable [Fintype S] [DecidableEq T] [Fintype T]
    {P : S → S → ℝ} {Q : T → T → ℝ} {f : S → T} (hPnn : ∀ u v, 0 ≤ P u v)
    (hlump : Lumpable P Q f) (hsurj : Function.Surjective f) (p : α)
    (hP : (markovSystem P α).ProvesReflection) :
    (markovSystem Q α).ProvesReflection := by
  refine (markovSystem_provesReflection_iff Q p).mpr ?_
  intro y
  obtain ⟨w, rfl⟩ := hsurj y
  have hlazy : 0 < P w w := (markovSystem_provesReflection_iff P p).mp hP w
  exact (lumpMorphism hPnn hlump).forth (F := suppFrame P) (G := suppFrame Q) hlazy

/-! ## Part C — The deterministic `n`-cycle: period = soundness spectrum -/

/-- The deterministic cyclic chain on `ZMod n`: from `u` one moves to `u + 1` with
probability one. -/
def cycleChain (n : ℕ) [NeZero n] : ZMod n → ZMod n → ℝ :=
  fun u v => if v = u + 1 then 1 else 0

theorem cycleChain_nonneg (n : ℕ) [NeZero n] (u v : ZMod n) : 0 ≤ cycleChain n u v := by
  unfold cycleChain; split_ifs <;> norm_num

theorem cycleChain_rowStochastic (n : ℕ) [NeZero n] : RowStochastic (cycleChain n) := by
  refine ⟨cycleChain_nonneg n, fun u => ?_⟩
  unfold cycleChain
  rw [Finset.sum_ite_eq' Finset.univ (u + 1) (fun _ => (1 : ℝ))]
  simp

@[simp] theorem cycleChain_R_iff (n : ℕ) [NeZero n] (u v : ZMod n) :
    (suppFrame (cycleChain n)).R u v ↔ v = u + 1 := by
  show (0 : ℝ) < cycleChain n u v ↔ _
  unfold cycleChain
  split_ifs with h <;> simp [h]

/-- **`k`-step accessibility on the `n`-cycle is addition of `k` in `ZMod n`.** -/
theorem iterR_cycleChain (n : ℕ) [NeZero n] :
    ∀ (k : ℕ) (u v : ZMod n),
      iterR (suppFrame (cycleChain n)) k u v ↔ v = u + (k : ZMod n) := by
  intro k
  induction k with
  | zero => intro u v; simp [iterR, eq_comm]
  | succ k ih =>
      intro u v
      constructor
      · rintro ⟨z, hz, hzv⟩
        have hz' : z = u + 1 := (cycleChain_R_iff n u z).mp hz
        have := (ih z v).mp hzv
        rw [hz'] at this
        rw [this]
        push_cast
        ring
      · intro hv
        refine ⟨u + 1, (cycleChain_R_iff n u (u + 1)).mpr rfl, ?_⟩
        refine (ih (u + 1) v).mpr ?_
        rw [hv]
        push_cast
        ring

/-- **The period is the soundness spectrum.**  A state of the `n`-cycle has internal
soundness of degree `k` exactly when `n ∣ k`. -/
theorem iterSound_cycleChain_iff (n : ℕ) [NeZero n] (p : α) (k : ℕ) (w : ZMod n) :
    IterSoundAt (suppFrame (cycleChain n)) α k w ↔ n ∣ k := by
  rw [iterSound_iff_cycle (suppFrame (cycleChain n)) p k w, iterR_cycleChain n k w w]
  rw [left_eq_add]
  exact ZMod.natCast_eq_zero_iff k n

/-- **The soundness spectrum of the `n`-cycle is the numerical semigroup `nℕ`.** -/
theorem soundMonoid_cycleChain (n : ℕ) [NeZero n] (p : α) (w : ZMod n) :
    (soundMonoid (suppFrame (cycleChain n)) α p w : Set ℕ) = {k : ℕ | n ∣ k} := by
  ext k
  exact iterSound_cycleChain_iff n p k w

/-- The `1`-cycle is lazy; the `n`-cycle for `n ≥ 2` is not. -/
theorem cycleChain_holding_iff (n : ℕ) [NeZero n] (w : ZMod n) :
    0 < cycleChain n w w ↔ n ∣ 1 := by
  show (0 : ℝ) < cycleChain n w w ↔ _
  unfold cycleChain
  constructor
  · intro h
    have hw : w = w + 1 := by
      by_contra hne
      rw [if_neg hne] at h
      exact lt_irrefl 0 h
    have : (1 : ZMod n) = 0 := left_eq_add.mp hw
    have h1 : ((1 : ℕ) : ZMod n) = 0 := by push_cast; exact this
    exact (ZMod.natCast_eq_zero_iff 1 n).mp h1
  · intro h
    have h1 : ((1 : ℕ) : ZMod n) = 0 := (ZMod.natCast_eq_zero_iff 1 n).mpr h
    have : w = w + 1 := by
      have : (1 : ZMod n) = 0 := by push_cast at h1; exact h1
      rw [this, add_zero]
    rw [if_pos this]
    norm_num

/-! ## Part D — Cycles lump onto their divisors -/

/-- For `m ∣ n`, reduction `ZMod n → ZMod m` lumps the `n`-cycle onto the `m`-cycle. -/
theorem cycleLumpable {n m : ℕ} [NeZero n] [NeZero m] (h : m ∣ n) :
    Lumpable (cycleChain n) (cycleChain m) (fun x => ZMod.castHom h (ZMod m) x) := by
  intro u y
  have hsum : ∑ v ∈ Finset.univ.filter
      (fun v => ZMod.castHom h (ZMod m) v = y), cycleChain n u v
      = if (u + 1) ∈ Finset.univ.filter
          (fun v => ZMod.castHom h (ZMod m) v = y) then (1 : ℝ) else 0 := by
    unfold cycleChain
    exact Finset.sum_ite_eq' _ (u + 1) (fun _ => (1 : ℝ))
  rw [hsum]
  have hmem : ((u + 1) ∈ Finset.univ.filter
      (fun v => ZMod.castHom h (ZMod m) v = y)) ↔
      ZMod.castHom h (ZMod m) u + 1 = y := by
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, map_add, map_one]
  show (if _ then (1 : ℝ) else 0) = cycleChain m _ y
  unfold cycleChain
  by_cases hy : ZMod.castHom h (ZMod m) u + 1 = y
  · rw [if_pos (hmem.mpr hy), if_pos hy.symm]
  · rw [if_neg (fun hc => hy (hmem.mp hc)), if_neg (fun hc => hy hc.symm)]

/-- **Modal theories of cycles are monotone in divisibility.**  Every formula valid on
the `n`-cycle is valid on the `m`-cycle whenever `m ∣ n` — the modal shadow of the
spectrum inclusion `nℕ ⊆ mℕ`. -/
theorem cycleSystem_thm_mono {n m : ℕ} [NeZero n] [NeZero m] (h : m ∣ n)
    {φ : MFormula α} (hφ : (markovSystem (cycleChain n) α).Thm φ) :
    (markovSystem (cycleChain m) α).Thm φ :=
  markovSystem_thm_of_lumpable (cycleChain_nonneg n) (cycleLumpable h)
    (ZMod.castHom_surjective h) hφ

/-- **Non-laziness is not modally definable.**  Concrete probabilistic witnesses: the
`2`-cycle has no positive holding probability, it lumps surjectively onto the `1`-cycle,
and the `1`-cycle is lazy.  So no set of modal axioms can force a chain to have zero
holding probabilities. -/
theorem nonlazy_not_definable (Γ : Set (MFormula α)) :
    ¬ Defines α Γ (fun F : KFrame.{0} => ∀ w, ¬ F.R w w) := by
  intro hdef
  have h2 : ∀ w : ZMod 2, ¬ (suppFrame (cycleChain 2)).R w w := by
    intro w hw
    have := (cycleChain_holding_iff 2 w).mp hw
    omega
  have hvalid2 : ∀ φ ∈ Γ, Valid (suppFrame (cycleChain 2)) α φ :=
    (hdef (suppFrame (cycleChain 2))).mpr h2
  have hvalid1 : ∀ φ ∈ Γ, Valid (suppFrame (cycleChain 1)) α φ := fun φ hφ =>
    cycleSystem_thm_mono (α := α) (one_dvd 2) (hvalid2 φ hφ)
  have h1 : ∀ w : ZMod 1, ¬ (suppFrame (cycleChain 1)).R w w :=
    (hdef (suppFrame (cycleChain 1))).mp hvalid1
  exact h1 0 ((cycleChain_holding_iff 1 0).mpr (dvd_refl 1))

/-- **Capstone for Part II.**  For the deterministic `n`-cycle: the soundness spectrum
is exactly `nℕ`, the system is consistent, proves its own consistency, is never Löbian,
and its theory only grows when the cycle is lumped onto a divisor cycle. -/
theorem cycle_capstone (n : ℕ) [NeZero n] (p : α) (w : ZMod n) :
    ((soundMonoid (suppFrame (cycleChain n)) α p w : Set ℕ) = {k : ℕ | n ∣ k}) ∧
    (markovSystem (cycleChain n) α).Consistent ∧
    (markovSystem (cycleChain n) α).Thm (MFormula.con (α := α)) ∧
    ¬ (markovSystem (cycleChain n) α).ProvesLoebAxiom ∧
    (∀ m : ℕ, ∀ _ : NeZero m, ∀ _ : m ∣ n, ∀ φ : MFormula α,
      (markovSystem (cycleChain n) α).Thm φ → (markovSystem (cycleChain m) α).Thm φ) :=
  ⟨soundMonoid_cycleChain n p w,
    markovSystem_consistent _,
    markovSystem_proves_con (cycleChain_rowStochastic n),
    markovSystem_not_provesLoebAxiom (cycleChain_rowStochastic n),
    fun _ _ h _ hφ => cycleSystem_thm_mono h hφ⟩

end MarkovModal

-- !-- Lab Notes -- !--
--
-- Hypothesis (Hypothesizer):
--   H23. (Bold, cross-domain) The classical Markov-chain notion of *strong
--        lumpability* is not merely analogous to a bounded morphism of Kripke frames —
--        it **is** one, on the nose, after passing to supports.  Hence every
--        limitative result of modal definability becomes a limitative result about what
--        aggregation of a chain can preserve.
--   H24. (Bold) Cycle 2's "soundness spectrum" of a world is, for the deterministic
--        `n`-cycle, exactly the set of multiples of `n`; i.e. the modal invariant
--        *degree of internal soundness* coincides with the probabilistic invariant
--        *period*.
--   H25. Divisibility of periods should be witnessed by a lumping, so the map
--        `n ↦ Thm(cycleChain n)` should be monotone with respect to `∣` reversed.
--
-- Experiment (Experimenter):
--   H23: confirmed, `lumpMorphism`.  The `forth` clause is `Finset.single_le_sum`
--        (one positive transition bounds its block sum below) and `back` is
--        `exists_pos_of_sum_pos` (a positive block sum has a positive summand).  No
--        extra hypotheses beyond nonnegativity are needed — notably *row-stochasticity
--        is irrelevant here*, which is a genuine surprise: lumpability alone carries
--        the modal structure.
--   H24: confirmed, `iterSound_cycleChain_iff`, through `iterR_cycleChain`
--        (`k`-step accessibility = `+k` in `ZMod n`) and `ZMod.natCast_eq_zero_iff`.
--        The submonoid statement `soundMonoid_cycleChain` then says the spectrum is the
--        numerical semigroup generated by `n`.
--   H25: confirmed, `cycleLumpable` + `cycleSystem_thm_mono`.  The lumping is
--        `ZMod.castHom`; the block sum collapses by `Finset.sum_ite_eq'` because the
--        chain is deterministic.
--   Bonus: `nonlazy_not_definable` re-derives Cycle 5's irreflexivity limitation from
--        *probabilistic* witnesses (`2`-cycle ↠ `1`-cycle) instead of the infinite
--        successor frame — a finite, computable counterexample where Cycle 5 needed
--        an infinite one.
--
-- Analysis (Analyst):
--   Two invariants of a state are now provably the same object: its modal soundness
--   spectrum (Cycle 2) and the support of its return-time distribution (Part I), and
--   for the deterministic cycles this common object is a numerical semigroup `nℕ`.
--   Aggregation (lumping) acts on this picture by *enlarging* the theory and
--   *coarsening* the semigroup, and the two motions are compatible: `m ∣ n` gives both
--   `nℕ ⊆ mℕ` and `Thm(n) ⊆ Thm(m)`.  The failure of definability results are exactly
--   the places where the coarsening is strict.
--
-- Critique (Critic):
--   * Non-triviality: `lumpMorphism` builds real data; `iterR_cycleChain` is an
--     induction with `push_cast`/`ring`; `nonlazy_not_definable` is a genuine
--     refutation, not a vacuous statement.
--   * Corner case `n = 1`: `ZMod 1` is a one-element ring, `cycleChain 1` is the
--     one-state lazy chain, and Part I's `oneState_markovSystem_thm_iff_tangled`
--     identifies its system with Cycle 4's `tangledSystem`; so the `n = 1` endpoint of
--     `cycle_capstone` is exactly the Cycle-4 witness, not a degenerate artefact.
--   * `NeZero n` is required to have `Fintype (ZMod n)`; for `n = 0` the "cycle" is
--     `ℤ` with the successor relation, which is *not* row-stochastic in the finite
--     sense, so the hypothesis is genuinely needed rather than cosmetic.
--   * `Lumpable` is stated with a `Finset.filter` over blocks, i.e. strong lumpability
--     for the *support* structure; weak lumpability (which depends on the initial
--     distribution) is **not** covered, and would not give a bounded morphism.  This
--     boundary is deliberate.