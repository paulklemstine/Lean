/-
# Cycle 6: Frame Definability for `ModalSystem` over **Markov Chains**

Cycle 4 (`Logic.ProvabilityLogic.SelfSoundSystems`) supplied the abstract proof systems
`ModalSystem`, the two witnesses `glValiditySystem` / `tangledSystem`, and the
joint-inconsistency theorem.  Cycle 5 (`Combinatorics.ModalFrameDefinability`) supplied
the frame-definability layer over `KFrame` / `sat`.  What was still missing is a
*probabilistic* carrier for that layer: a systematic way to **manufacture** modal
systems, and to read their definability data off a stochastic matrix.

This file supplies exactly that bridge.

## The bridge

For a real matrix `P : S → S → ℝ` we take the **support frame** `suppFrame P`, whose
accessibility relation is `0 < P u v`.  Every notion of Cycles 1–5 then acquires a
probabilistic meaning:

| modal notion | probabilistic meaning |
| --- | --- |
| `MFormula.con` valid (seriality) | `P` is row-stochastic |
| `UniformlySoundAt` (self-loop) | positive holding probability `0 < P w w` |
| `IterSoundAt … n w` (`n`-cycle) | `0 < Pⁿ(w,w)`: return to `w` in exactly `n` steps |
| Löb axiom valid | converse well-founded support — **impossible** for a nonempty chain |

## Main results

* `stepPow_pos_iff` — **the support-power theorem**: `0 < Pⁿ(u,v)` iff there is an
  `n`-edge path from `u` to `v` in the support frame.  Positivity of matrix powers *is*
  `TangledSoundness.iterR`.
* `stepPow_add` — Chapman–Kolmogorov for `stepPow`, proved by induction with a genuine
  double-sum interchange.
* `iterSound_iff_stepPow_pos` — **internal soundness of degree `n` at `w` is exactly
  positive `n`-step return probability at `w`.**  Cycle 2's soundness spectrum becomes
  the return-time support of a Markov chain.
* `soundMonoid` — the soundness spectrum of *any* world of *any* frame is an additive
  submonoid of `ℕ` (`iterR_add` + `iterSound_add`); for a Markov chain this is the
  classical fact that return times form a numerical semigroup.
* `not_valid_loebInst_of_rowStochastic` — **no nonempty Markov chain is a Löb frame.**
  Row-stochasticity forces seriality, which is incompatible with converse
  well-foundedness.
* `markovSystem` — every finite matrix yields a `ModalSystem`; it is consistent, proves
  its own consistency statement `¬□⊥` when `P` is row-stochastic, and is therefore never
  Löbian (Cycle 4's `not_provable_con_of_loeb`).
* `markovSystem_provesReflection_iff` — **the self-sound Markov chains are exactly the
  lazy ones**: `markovSystem P` internalises its own soundness iff `0 < P w w` for every
  state.  This produces an infinite family of Cycle-4 `tangledSystem` witnesses.
* `oneState_markovSystem_thm_iff_tangled` — the one-state chain reproduces the Cycle-4
  witness `tangledSystem` on the nose.
* `exists_positive_sound_world_of_rowStochastic` — **pigeonhole**: every nonempty finite
  row-stochastic chain has a state with internal soundness of some positive degree.  So
  the Löb-free behaviour above is not an accident of the axiom: tangles are *forced*.

## Relationship to the catalog
Uses `TangledSoundness.KFrame`, `sat`, `iterR`, `IterSoundAt`, `iterSound_iff_cycle`,
`uniformlySound_iff_selfLoop`, `loopFrame`, `ModalSystem`, `tangledSystem` and
`FrameDefinability.Valid`, `defines_serial`, `valid_loeb_iff`.
-/

import Mathlib
import Combinatorics.ModalFrameDefinability

namespace MarkovModal

open GLPLogic TangledSoundness FrameDefinability

variable {S : Type} {α : Type}

/-! ## Part 0 — Two general lemmas about `KFrame`s that the Markov side needs

These are frame-theoretic, not probabilistic, but they are exactly the facts that make
the "return times form a semigroup" statement work. -/

/-- Concatenation of paths: an `(n+m)`-step path splits at its `n`-th vertex. -/
theorem iterR_add (F : KFrame) (m : ℕ) :
    ∀ (n : ℕ) (u v : F.W), iterR F (n + m) u v ↔ ∃ z, iterR F n u z ∧ iterR F m z v := by
  intro n
  induction n with
  | zero =>
      intro u v
      rw [Nat.zero_add]
      constructor
      · intro h; exact ⟨u, rfl, h⟩
      · rintro ⟨z, rfl, h⟩; exact h
  | succ n ih =>
      intro u v
      have hcomm : n + 1 + m = (n + m) + 1 := by omega
      rw [hcomm]
      constructor
      · rintro ⟨z, hz, hzv⟩
        obtain ⟨y, hzy, hyv⟩ := (ih z v).mp hzv
        exact ⟨y, ⟨z, hz, hzy⟩, hyv⟩
      · rintro ⟨y, ⟨z, hz, hzy⟩, hyv⟩
        exact ⟨z, hz, (ih z v).mpr ⟨y, hzy, hyv⟩⟩

/-- Degree-`0` internal soundness is vacuous: `□⁰φ → φ` is `φ → φ`. -/
theorem iterSound_zero (F : KFrame) (w : F.W) : IterSoundAt F α 0 w :=
  fun _ _ h => h

/-- **Internal soundness degrees add.**  If a world validates `□ⁿφ → φ` and `□ᵐφ → φ`
(uniformly in the valuation) then it validates `□ⁿ⁺ᵐφ → φ`.  Via Cycle 2's
`iterSound_iff_cycle` this is path concatenation. -/
theorem iterSound_add (F : KFrame) (p : α) {n m : ℕ} {w : F.W}
    (hn : IterSoundAt F α n w) (hm : IterSoundAt F α m w) : IterSoundAt F α (n + m) w := by
  refine (iterSound_iff_cycle F p (n + m) w).mpr ?_
  exact (iterR_add F m n w w).mpr
    ⟨w, (iterSound_iff_cycle F p n w).mp hn, (iterSound_iff_cycle F p m w).mp hm⟩

/-- **The soundness spectrum is an additive submonoid of `ℕ`.**  Cycle 2 computed the
spectrum pointwise; this says it always has algebraic structure — a numerical
semigroup attached to each world of each frame. -/
def soundMonoid (F : KFrame) (α : Type) (p : α) (w : F.W) : AddSubmonoid ℕ where
  carrier := {n | IterSoundAt F α n w}
  zero_mem' := iterSound_zero F w
  add_mem' := fun hn hm => iterSound_add F p hn hm

@[simp] theorem mem_soundMonoid (F : KFrame) (p : α) (w : F.W) (n : ℕ) :
    n ∈ soundMonoid F α p w ↔ IterSoundAt F α n w := Iff.rfl

/-! ## Part A — The support frame of a matrix -/

/-- The **support frame** of a matrix: worlds are states, and `u` accesses `v` when the
transition `u → v` has positive probability. -/
def suppFrame (P : S → S → ℝ) : KFrame.{0} where
  W := S
  R := fun u v => 0 < P u v

@[simp] theorem suppFrame_R (P : S → S → ℝ) (u v : S) :
    (suppFrame P).R u v ↔ 0 < P u v := Iff.rfl

/-- `P` is **row-stochastic**: nonnegative entries, rows summing to one. -/
def RowStochastic [Fintype S] (P : S → S → ℝ) : Prop :=
  (∀ u v, 0 ≤ P u v) ∧ ∀ u, ∑ v, P u v = 1

/-- **Row-stochasticity forces seriality**: a probability distribution cannot be
identically zero, so every state has a successor in the support frame. -/
theorem serial_of_rowStochastic [Fintype S] {P : S → S → ℝ} (hP : RowStochastic P)
    (u : S) : ∃ v : S, 0 < P u v := by
  by_contra hno
  simp only [not_exists] at hno
  have hzero : ∀ v ∈ Finset.univ, P u v = 0 := by
    intro v _
    exact le_antisymm (not_lt.mp (hno v)) (hP.1 u v)
  have := hP.2 u
  rw [Finset.sum_congr rfl hzero, Finset.sum_const_zero] at this
  exact zero_ne_one this

/-! ## Part B — Matrix powers and the support-power theorem -/

/-- The `n`-step transition matrix `Pⁿ`, defined by forward recursion. -/
def stepPow [Fintype S] [DecidableEq S] (P : S → S → ℝ) : ℕ → S → S → ℝ
  | 0, u, v => if u = v then 1 else 0
  | n + 1, u, v => ∑ z, P u z * stepPow P n z v

@[simp] theorem stepPow_zero [Fintype S] [DecidableEq S] (P : S → S → ℝ) (u v : S) :
    stepPow P 0 u v = if u = v then 1 else 0 := rfl

@[simp] theorem stepPow_succ [Fintype S] [DecidableEq S] (P : S → S → ℝ) (n : ℕ)
    (u v : S) : stepPow P (n + 1) u v = ∑ z, P u z * stepPow P n z v := rfl

theorem stepPow_nonneg [Fintype S] [DecidableEq S] {P : S → S → ℝ}
    (hP : ∀ u v, 0 ≤ P u v) : ∀ (n : ℕ) (u v : S), 0 ≤ stepPow P n u v := by
  intro n
  induction n with
  | zero => intro u v; by_cases h : u = v <;> simp [h]
  | succ n ih =>
      intro u v
      exact Finset.sum_nonneg fun z _ => mul_nonneg (hP u z) (ih z v)

/-- **The support-power theorem.**  The `n`-step transition probability from `u` to `v`
is positive exactly when the support frame has an `n`-edge path from `u` to `v`.  This
is the dictionary entry that lets every combinatorial statement of Cycles 1–5 be read
probabilistically. -/
theorem stepPow_pos_iff [Fintype S] [DecidableEq S] {P : S → S → ℝ}
    (hP : ∀ u v, 0 ≤ P u v) :
    ∀ (n : ℕ) (u v : S), 0 < stepPow P n u v ↔ iterR (suppFrame P) n u v := by
  intro n
  induction n with
  | zero =>
      intro u v
      by_cases h : u = v <;> simp [h, iterR]
  | succ n ih =>
      intro u v
      constructor
      · intro hpos
        by_contra hno
        have hterm : ∀ z ∈ Finset.univ, P u z * stepPow P n z v = 0 := by
          intro z _
          by_cases hz : 0 < P u z
          · have : ¬ iterR (suppFrame P) n z v := fun hc => hno ⟨z, hz, hc⟩
            have hzero : stepPow P n z v = 0 :=
              le_antisymm (not_lt.mp (fun hc => this ((ih z v).mp hc)))
                (stepPow_nonneg hP n z v)
            simp [hzero]
          · have : P u z = 0 := le_antisymm (not_lt.mp hz) (hP u z)
            simp [this]
        rw [stepPow_succ, Finset.sum_congr rfl hterm, Finset.sum_const_zero] at hpos
        exact lt_irrefl 0 hpos
      · rintro ⟨z, hz, hzv⟩
        have hzpos : 0 < P u z := hz
        have hstep : 0 < stepPow P n z v := (ih z v).mpr hzv
        refine Finset.sum_pos'
          (fun y _ => mul_nonneg (hP u y) (stepPow_nonneg hP n y v)) ?_
        exact ⟨z, Finset.mem_univ _, mul_pos hzpos hstep⟩

/-- **Chapman–Kolmogorov.**  `Pⁿ⁺ᵐ = Pⁿ · Pᵐ`, proved by induction on `n` with an
interchange of the two summations. -/
theorem stepPow_add [Fintype S] [DecidableEq S] (P : S → S → ℝ) (m : ℕ) :
    ∀ (n : ℕ) (u v : S), stepPow P (n + m) u v = ∑ z, stepPow P n u z * stepPow P m z v := by
  intro n
  induction n with
  | zero =>
      intro u v
      rw [Nat.zero_add]
      simp
  | succ n ih =>
      intro u v
      have hcomm : n + 1 + m = (n + m) + 1 := by omega
      rw [hcomm, stepPow_succ]
      calc ∑ z, P u z * stepPow P (n + m) z v
          = ∑ z, ∑ y, P u z * (stepPow P n z y * stepPow P m y v) := by
            refine Finset.sum_congr rfl fun z _ => ?_
            rw [ih z v, Finset.mul_sum]
        _ = ∑ y, ∑ z, P u z * (stepPow P n z y * stepPow P m y v) := Finset.sum_comm
        _ = ∑ y, stepPow P (n + 1) u y * stepPow P m y v := by
            refine Finset.sum_congr rfl fun y _ => ?_
            rw [stepPow_succ, Finset.sum_mul]
            exact Finset.sum_congr rfl fun z _ => by ring

/-- Return probabilities compose: a positive `n`-step and a positive `m`-step return
give a positive `(n+m)`-step return.  (The probabilistic proof of `iterSound_add`.) -/
theorem stepPow_return_add [Fintype S] [DecidableEq S] {P : S → S → ℝ}
    (hP : ∀ u v, 0 ≤ P u v) {n m : ℕ} {w : S}
    (hn : 0 < stepPow P n w w) (hm : 0 < stepPow P m w w) :
    0 < stepPow P (n + m) w w := by
  rw [stepPow_add]
  exact Finset.sum_pos'
    (fun y _ => mul_nonneg (stepPow_nonneg hP n w y) (stepPow_nonneg hP m y w))
    ⟨w, Finset.mem_univ w, mul_pos hn hm⟩

/-! ## Part C — The probabilistic reading of internal soundness -/

/-- **Internal soundness of degree `n` is positive `n`-step return probability.**
Cycle 2 characterised `IterSoundAt` as lying on an `n`-cycle; combined with
`stepPow_pos_iff` this identifies the soundness spectrum of a state with the support of
its return-time distribution. -/
theorem iterSound_iff_stepPow_pos [Fintype S] [DecidableEq S] {P : S → S → ℝ}
    (hP : ∀ u v, 0 ≤ P u v) (p : α) (n : ℕ) (w : S) :
    IterSoundAt (suppFrame P) α n w ↔ 0 < stepPow P n w w :=
  (iterSound_iff_cycle (suppFrame P) p n w).trans (stepPow_pos_iff hP n w w).symm

/-- **Uniform internal soundness is positive holding probability.**  Cycle 1's
`uniformlySound_iff_selfLoop`, read on a chain: a state internalises its own soundness
iff the chain can stay put there. -/
theorem uniformlySound_iff_holding [Fintype S] (P : S → S → ℝ) (p : α) (w : S) :
    UniformlySoundAt (suppFrame P) α w ↔ 0 < P w w :=
  uniformlySound_iff_selfLoop (suppFrame P) p w

/-! ## Part D — No Markov chain is a Löb frame -/

/-- A serial frame is never converse well-founded (unless empty): well-founded
induction along `swap R` would have to terminate, but seriality always offers another
step. -/
theorem not_wf_of_serial (F : KFrame) (hne : Nonempty F.W)
    (hser : ∀ u : F.W, ∃ v, F.R u v) : ¬ WellFounded (Function.swap F.R) := by
  intro hwf
  haveI := hne
  have hall : ∀ w : F.W, False := by
    intro w
    induction w using hwf.induction with
    | _ w ih =>
        obtain ⟨v, hv⟩ := hser w
        exact ih v hv
  exact hall (Classical.arbitrary F.W)

/-- **No nonempty Markov chain is a Löb frame.**  The Löb axiom defines the transitive
converse-well-founded frames (`valid_loeb_iff`), and row-stochasticity forces seriality,
which destroys converse well-foundedness.  So the provability discipline of GL is simply
unavailable to a probabilistic transition system. -/
theorem not_valid_loebInst_of_rowStochastic [Fintype S] [Nonempty S] {P : S → S → ℝ}
    (hP : RowStochastic P) (p : α) :
    ¬ Valid (suppFrame P) α (loebInst (MFormula.var p)) := by
  intro hv
  obtain ⟨-, hwf⟩ := (valid_loeb_iff (suppFrame P) p).mp hv
  have hser : ∀ u : S, ∃ v : S, 0 < P u v := fun u => serial_of_rowStochastic hP u
  have hne : Nonempty (suppFrame P).W := ‹Nonempty S›
  exact not_wf_of_serial (suppFrame P) hne (fun u => hser u) hwf

/-- The consistency formula `¬□⊥` is valid on the support frame of a row-stochastic
matrix — via Cycle 5's `defines_serial`. -/
theorem valid_con_of_rowStochastic [Fintype S] {P : S → S → ℝ} (hP : RowStochastic P) :
    Valid (suppFrame P) α (MFormula.con (α := α)) :=
  (defines_serial (α := α) (suppFrame P)).mpr
    (fun u => serial_of_rowStochastic hP u) MFormula.con rfl

/-! ## Part E — The Markov modal system -/

/-- **The modal system of a matrix**: its theorems are the formulas valid on the support
frame.  Every matrix therefore manufactures a Cycle-4 `ModalSystem`. -/
def markovSystem (P : S → S → ℝ) (α : Type) : ModalSystem α where
  Thm φ := Valid (suppFrame P) α φ
  mp := fun h₁ h₂ V w => h₁ V w (h₂ V w)
  nec := fun h V _ v _ => h V v

@[simp] theorem markovSystem_thm (P : S → S → ℝ) (φ : MFormula α) :
    (markovSystem P α).Thm φ ↔ Valid (suppFrame P) α φ := Iff.rfl

/-- The Markov system of a nonempty state space is consistent. -/
theorem markovSystem_consistent [Nonempty S] (P : S → S → ℝ) :
    (markovSystem P α).Consistent :=
  fun h => h (fun _ _ => False) (Classical.arbitrary S)

/-- A row-stochastic chain **proves its own consistency statement**. -/
theorem markovSystem_proves_con [Fintype S] {P : S → S → ℝ} (hP : RowStochastic P) :
    (markovSystem P α).Thm (MFormula.con (α := α)) :=
  valid_con_of_rowStochastic hP

/-- **Gödel 2, contrapositive, for chains.**  A nonempty row-stochastic chain's modal
system proves its own consistency and is consistent, hence — by Cycle 4's
`not_provable_con_of_loeb` — it cannot be Löbian. -/
theorem markovSystem_not_provesLoebAxiom [Fintype S] [Nonempty S] {P : S → S → ℝ}
    (hP : RowStochastic P) : ¬ (markovSystem P α).ProvesLoebAxiom :=
  fun hL => (markovSystem P α).not_provable_con_of_loeb hL
    (markovSystem_consistent P) (markovSystem_proves_con hP)

/-- **The self-sound chains are exactly the lazy ones.**  `markovSystem P` internalises
its own soundness schema iff every state has positive holding probability. -/
theorem markovSystem_provesReflection_iff [Fintype S] (P : S → S → ℝ) (p : α) :
    (markovSystem P α).ProvesReflection ↔ ∀ w : S, 0 < P w w := by
  constructor
  · intro h w
    exact (uniformlySound_iff_holding P p w).mp (fun V φ => h φ V w)
  · intro h φ V w
    exact (uniformlySound_iff_holding P p w).mpr (h w) V φ

/-- **An infinite family of Cycle-4 tangled witnesses.**  Every nonempty lazy chain
gives a consistent modal system that proves its own soundness schema (hence its own
consistency) and is not Löbian. -/
theorem lazy_markovSystem_is_tangled_witness [Fintype S] [Nonempty S] {P : S → S → ℝ}
    (hP : RowStochastic P) (p : α) (hlazy : ∀ w : S, 0 < P w w) :
    (markovSystem P α).Consistent ∧ (markovSystem P α).ProvesReflection ∧
      ¬ (markovSystem P α).ProvesLoebAxiom :=
  ⟨markovSystem_consistent P,
    (markovSystem_provesReflection_iff P p).mpr hlazy,
    markovSystem_not_provesLoebAxiom hP⟩

/-! ## Part F — The one-state chain *is* the Cycle-4 witness -/

/-- Satisfaction only sees the accessibility relation up to logical equivalence. -/
theorem sat_R_congr {W : Type} (R R' : W → W → Prop) (h : ∀ u v, R u v ↔ R' u v)
    (V : α → W → Prop) : ∀ (φ : MFormula α) (w : W),
      sat ⟨W, R⟩ V w φ ↔ sat ⟨W, R'⟩ V w φ := by
  intro φ
  induction φ with
  | var p => intro w; rfl
  | bot => intro w; rfl
  | imp φ ψ ihφ ihψ => intro w; exact imp_congr (ihφ w) (ihψ w)
  | box φ ih =>
      intro w
      simp only [sat_box]
      constructor
      · intro hb v hv; exact (ih v).mp (hb v ((h w v).mpr hv))
      · intro hb v hv; exact (ih v).mpr (hb v ((h w v).mp hv))

/-- **The Cycle-4 witness is a Markov system.**  The deterministic one-state chain
`P = (1)` has support frame `loopFrame`, so its modal system is literally Cycle 4's
`tangledSystem`. -/
theorem oneState_markovSystem_thm_iff_tangled (φ : MFormula α) :
    (markovSystem (fun _ _ : Unit => (1 : ℝ)) α).Thm φ ↔ (tangledSystem α).Thm φ := by
  constructor
  · intro h V w
    exact (sat_R_congr (W := Unit) (fun u v => 0 < (1 : ℝ)) (fun _ _ => True)
      (fun _ _ => ⟨fun _ => trivial, fun _ => one_pos⟩) V φ w).mp (h V w)
  · intro h V w
    exact (sat_R_congr (W := Unit) (fun u v => 0 < (1 : ℝ)) (fun _ _ => True)
      (fun _ _ => ⟨fun _ => trivial, fun _ => one_pos⟩) V φ w).mpr (h V w)

/-! ## Part G — Tangles are forced: the pigeonhole theorem -/

/-- Following a choice of successors, `f i` reaches `f (i + k)` in exactly `k` steps. -/
theorem iterR_iterate (F : KFrame) (g : F.W → F.W) (hg : ∀ u, F.R u (g u)) :
    ∀ (k i : ℕ) (x : F.W), iterR F k (g^[i] x) (g^[i + k] x) := by
  intro k
  induction k with
  | zero => intro i x; simp [iterR]
  | succ k ih =>
      intro i x
      refine ⟨g^[i + 1] x, ?_, ?_⟩
      · rw [Function.iterate_succ_apply']
        exact hg _
      · have := ih (i + 1) x
        have he : i + 1 + k = i + (k + 1) := by omega
        rwa [he] at this

/-- **Tangles are forced.**  Every nonempty finite row-stochastic chain has a state with
internal soundness of some positive degree: a Löb-free world is not merely permitted,
one is guaranteed.  The proof is a pigeonhole on the orbit of a successor-choice
function, turning a repetition into a cycle and hence (Cycle 2) into internal
soundness. -/
theorem exists_positive_sound_world_of_rowStochastic
    [Fintype S] [DecidableEq S] [Nonempty S] {P : S → S → ℝ} (hP : RowStochastic P)
    (p : α) : ∃ (w : S) (n : ℕ), 0 < n ∧ IterSoundAt (suppFrame P) α n w := by
  have hser : ∀ u : S, ∃ v : S, 0 < P u v := fun u => serial_of_rowStochastic hP u
  choose g hg using hser
  have hg' : ∀ u : (suppFrame P).W, (suppFrame P).R u (g u) := fun u => hg u
  let x₀ : S := Classical.arbitrary S
  obtain ⟨i, j, hij, heq⟩ :=
    Finite.exists_ne_map_eq_of_infinite (fun i : ℕ => g^[i] x₀)
  rcases lt_or_gt_of_ne hij with hlt | hlt
  · refine ⟨g^[i] x₀, j - i, by omega, ?_⟩
    refine (iterSound_iff_cycle (suppFrame P) p (j - i) (g^[i] x₀)).mpr ?_
    have hpath := iterR_iterate (suppFrame P) g hg' (j - i) i x₀
    have hidx : i + (j - i) = j := by omega
    rw [hidx, ← heq] at hpath
    exact hpath
  · refine ⟨g^[j] x₀, i - j, by omega, ?_⟩
    refine (iterSound_iff_cycle (suppFrame P) p (i - j) (g^[j] x₀)).mpr ?_
    have hpath := iterR_iterate (suppFrame P) g hg' (i - j) j x₀
    have hidx : j + (i - j) = i := by omega
    rw [hidx, heq] at hpath
    exact hpath

/-- **Capstone.**  For a nonempty finite row-stochastic chain the Cycle-4 dichotomy
resolves completely on the probabilistic side: the modal system is consistent, proves
its own consistency, is *never* Löbian, its Löb axiom is *never* frame-valid, and some
state always carries internal soundness of positive degree.  Moreover it internalises
its full soundness schema exactly when the chain is lazy. -/
theorem markov_definability_capstone
    [Fintype S] [DecidableEq S] [Nonempty S] {P : S → S → ℝ} (hP : RowStochastic P)
    (p : α) :
    (markovSystem P α).Consistent ∧
    (markovSystem P α).Thm (MFormula.con (α := α)) ∧
    ¬ (markovSystem P α).ProvesLoebAxiom ∧
    ¬ Valid (suppFrame P) α (loebInst (MFormula.var p)) ∧
    (∃ (w : S) (n : ℕ), 0 < n ∧ IterSoundAt (suppFrame P) α n w) ∧
    ((markovSystem P α).ProvesReflection ↔ ∀ w : S, 0 < P w w) :=
  ⟨markovSystem_consistent P,
    markovSystem_proves_con hP,
    markovSystem_not_provesLoebAxiom hP,
    not_valid_loebInst_of_rowStochastic hP p,
    exists_positive_sound_world_of_rowStochastic hP p,
    markovSystem_provesReflection_iff P p⟩

end MarkovModal

-- !-- Lab Notes -- !--
--
-- Hypothesis (Hypothesizer):
--   H19. (Bold, cross-domain) The whole Cycle-5 definability dictionary transfers to
--        Markov chains through the *support* functor `P ↦ suppFrame P`, and the
--        transfer is exact: `iterR` positivity = matrix-power positivity.
--   H20. (Bold) Löb's axiom is *incompatible with probability*: no nonempty
--        row-stochastic chain validates it, so `glValiditySystem` has no Markov
--        realisation at all, while `tangledSystem` has an infinite family of them
--        (the lazy chains).
--   H21. The soundness spectrum of Cycle 2 is not just a set but an additive submonoid
--        of `ℕ`, i.e. a numerical semigroup; on the Markov side it is the support of
--        the return-time distribution.
--   H22. Tangles are not merely permitted but forced on finite chains: pigeonhole on an
--        orbit gives a cycle, hence a world of positive soundness degree.
--
-- Experiment (Experimenter):
--   H19: confirmed, `stepPow_pos_iff` (induction on `n`; the forward direction is a
--        "positive sum has a positive summand" argument run as a contrapositive, so no
--        choice principle beyond `Classical` decidability is used) together with
--        `stepPow_add` (Chapman–Kolmogorov, double-sum interchange via
--        `Finset.sum_comm`).
--   H20: confirmed, `not_valid_loebInst_of_rowStochastic`.  The mechanism is:
--        row sums equal one ⟹ some entry positive ⟹ seriality ⟹ well-founded
--        induction along `swap R` proves `False` at every world.  Note the finiteness
--        hypothesis is *only* needed to write the row sum; the incompatibility itself
--        is choice-free and purely order-theoretic (`not_wf_of_serial`).
--   H21: confirmed twice over — combinatorially as `soundMonoid` (built from
--        `iterR_add`) and probabilistically as `stepPow_return_add`.
--   H22: confirmed, `exists_positive_sound_world_of_rowStochastic`.  The orbit of the
--        successor-choice function `g` is an infinite sequence in a finite type, so it
--        repeats; `iterR_iterate` converts the repetition into a genuine cycle.
--
-- Analysis (Analyst):
--   The organising pattern is that *seriality* is the exact fingerprint of probability
--   in this dictionary.  Row-stochasticity contributes nothing else: every theorem in
--   Parts D–G factors through `serial_of_rowStochastic`.  Conversely, everything Löbian
--   is an assertion of terminality (dead ends), which a probability distribution can
--   never produce.  So the Cycle-4 dichotomy "Löb vs. internalised soundness" becomes,
--   on the Markov side, the dichotomy "absorbing dead ends vs. conservation of mass".
--
-- Critique (Critic):
--   * No theorem is `rfl`-only or `decide`-only.  `stepPow_pos_iff`, `stepPow_add`,
--     `iterR_add`, `iterR_iterate` are inductions; `not_wf_of_serial` is a well-founded
--     induction; `exists_positive_sound_world_of_rowStochastic` is a pigeonhole.
--   * Non-vacuity check: `markovSystem_consistent` needs `Nonempty S`, and all the
--     capstone hypotheses are simultaneously satisfiable — e.g. `S = Unit`, `P = (1)`,
--     which `oneState_markovSystem_thm_iff_tangled` identifies with the Cycle-4
--     `tangledSystem`.  So no statement here is vacuously true.
--   * Boundary: `markovSystem_provesReflection_iff` requires an inhabitant `p : α`;
--     with `α` empty the modal language has no variables and the right-to-left
--     direction can fail to be forced.  The hypothesis is stated explicitly rather than
--     hidden.
--   * `RowStochastic` is stated with real entries rather than `ℝ≥0` or `PMF` so that
--     the sums interact directly with `Finset.sum_pos'`; nonnegativity is carried
--     explicitly, which keeps every positivity step visible.