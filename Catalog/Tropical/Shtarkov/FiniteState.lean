/-
# The finite-state model class and its Shtarkov bound

We build the class `fsmClass M n` of all binary sources emitted by a fixed
finite-state machine `M` with `k` states, with an arbitrary Bernoulli parameter
attached to each state, and we bound its Shtarkov sum (NML normalizer) by
`((n+1)^2)^k`.

The proof is the "tropical counting" mechanism: the maximum-likelihood
(= tropical / max-plus) envelope of the class depends on the sample only through
the per-state occurrence counts, so the sufficient-statistic bound
`shtarkovSum_le_card_image` applies with a statistic taking at most `((n+1)^2)^k`
values.

Main results:
* `sum_probFrom_eq_one` — the finite-state source is a probability measure on
  words of length `n` (induction on `n`, generalising the start state);
* `probFrom_eq_prod_visits` — likelihood factorises over per-state counts;
* `prob_le_prob_ml` — the maximum-likelihood plug-in dominates every member;
* `shtarkovSum_fsmClass_le` — `S_n(FSM_k) ≤ ((n+1)^2)^k`;
* `shtarkovSum_fsmClass_le_two_pow` — the universal cap `S_n ≤ 2^n`.
-/

import Catalog.Tropical.Shtarkov.Basic

open Finset

namespace TropicalShtarkov

/-! ## Words -/

/-- Binary words of length `n`. -/
abbrev Word (n : ℕ) := Fin n → Bool

/-- Extend a finite word to an infinite sequence by padding with `false`. -/
def pad {n : ℕ} (x : Word n) : ℕ → Bool := fun i => if h : i < n then x ⟨i, h⟩ else false

theorem pad_zero {n : ℕ} (x : Word (n + 1)) : pad x 0 = x 0 := by
  simp [pad]

theorem pad_tail {n : ℕ} (x : Word (n + 1)) : (fun i => pad x (i + 1)) = pad (Fin.tail x) := by
  funext i
  simp only [pad, Fin.tail]
  by_cases h : i < n
  · rw [dif_pos (Nat.succ_lt_succ h), dif_pos h]
    rfl
  · rw [dif_neg (by omega : ¬ i + 1 < n + 1), dif_neg h]

/-! ## Finite-state machines and their sources -/

/-- A deterministic finite-state machine on the binary alphabet with `k` states. -/
structure FSM (k : ℕ) where
  /-- The initial state. -/
  init : Fin k
  /-- The transition function. -/
  step : Fin k → Bool → Fin k

variable {k : ℕ}

/-- The state reached after reading the first `i` symbols of `u`, starting at `s`. -/
def stAux (M : FSM k) (s : Fin k) (u : ℕ → Bool) : ℕ → Fin k
  | 0 => s
  | i + 1 => M.step (stAux M s u i) (u i)

theorem stAux_shift (M : FSM k) (s : Fin k) (u : ℕ → Bool) (i : ℕ) :
    stAux M s u (i + 1) = stAux M (M.step s (u 0)) (fun j => u (j + 1)) i := by
  induction i with
  | zero => rfl
  | succ i ih =>
      show M.step (stAux M s u (i + 1)) (u (i + 1)) = _
      rw [ih]
      rfl

/-- Emission weight of symbol `b` in state `s` under parameter vector `θ`. -/
def wt (θ : Fin k → ℝ) (s : Fin k) (b : Bool) : ℝ := if b then θ s else 1 - θ s

theorem wt_nonneg {θ : Fin k → ℝ} (h : ∀ s, 0 ≤ θ s ∧ θ s ≤ 1) (s : Fin k) (b : Bool) :
    0 ≤ wt θ s b := by
  cases b
  · show (0:ℝ) ≤ 1 - θ s
    linarith [(h s).2]
  · show (0:ℝ) ≤ θ s
    exact (h s).1

theorem wt_le_one {θ : Fin k → ℝ} (h : ∀ s, 0 ≤ θ s ∧ θ s ≤ 1) (s : Fin k) (b : Bool) :
    wt θ s b ≤ 1 := by
  cases b
  · show (1:ℝ) - θ s ≤ 1
    linarith [(h s).1]
  · show θ s ≤ 1
    exact (h s).2

theorem wt_sum (θ : Fin k → ℝ) (s : Fin k) : ∑ b : Bool, wt θ s b = 1 := by
  simp [wt]

/-- The likelihood of the word `x` under the finite-state source `(M, θ)` started
in state `s`. -/
noncomputable def probFrom (M : FSM k) (θ : Fin k → ℝ) (s : Fin k) (n : ℕ) (x : Word n) : ℝ :=
  ∏ i ∈ Finset.range n, wt θ (stAux M s (pad x) i) (pad x i)

/-- The likelihood of `x` under the source started in the machine's initial state. -/
noncomputable def prob (M : FSM k) (θ : Fin k → ℝ) (n : ℕ) (x : Word n) : ℝ :=
  probFrom M θ M.init n x

theorem probFrom_zero (M : FSM k) (θ : Fin k → ℝ) (s : Fin k) (x : Word 0) :
    probFrom M θ s 0 x = 1 := by
  simp [probFrom]

/-- The one-step recursion for finite-state likelihoods. -/
theorem probFrom_succ (M : FSM k) (θ : Fin k → ℝ) (s : Fin k) (n : ℕ) (x : Word (n + 1)) :
    probFrom M θ s (n + 1) x
      = wt θ s (x 0) * probFrom M θ (M.step s (x 0)) n (Fin.tail x) := by
  have hp0 : pad x 0 = x 0 := pad_zero x
  have hpt : ∀ i, pad x (i + 1) = pad (Fin.tail x) i := fun i => congrFun (pad_tail x) i
  unfold probFrom
  rw [Finset.prod_range_succ']
  have hfac : ∀ i ∈ Finset.range n, wt θ (stAux M s (pad x) (i + 1)) (pad x (i + 1))
      = wt θ (stAux M (M.step s (x 0)) (pad (Fin.tail x)) i) (pad (Fin.tail x) i) := by
    intro i _
    rw [stAux_shift, hpt i, hp0, pad_tail]
  have hzero : wt θ (stAux M s (pad x) 0) (pad x 0) = wt θ s (x 0) := by
    rw [hp0]
    rfl
  rw [Finset.prod_congr rfl hfac, hzero, mul_comm]

theorem probFrom_nonneg (M : FSM k) {θ : Fin k → ℝ} (h : ∀ s, 0 ≤ θ s ∧ θ s ≤ 1)
    (s : Fin k) (n : ℕ) (x : Word n) : 0 ≤ probFrom M θ s n x :=
  Finset.prod_nonneg fun i _ => wt_nonneg h _ _

theorem probFrom_le_one (M : FSM k) {θ : Fin k → ℝ} (h : ∀ s, 0 ≤ θ s ∧ θ s ≤ 1)
    (s : Fin k) (n : ℕ) (x : Word n) : probFrom M θ s n x ≤ 1 :=
  Finset.prod_le_one (fun i _ => wt_nonneg h _ _) (fun i _ => wt_le_one h _ _)

/-- Summation over words of length `n+1` splits off the first symbol. -/
theorem sum_word_succ (n : ℕ) (f : Word (n + 1) → ℝ) :
    ∑ x : Word (n + 1), f x = ∑ b : Bool, ∑ y : Word n, f (Fin.cons b y) := by
  have h1 : (∑ p : Bool × (Word n), f (Fin.cons p.1 p.2))
      = ∑ b : Bool, ∑ y : Word n, f (Fin.cons b y) :=
    Fintype.sum_prod_type (f := fun p : Bool × (Word n) => f (Fin.cons p.1 p.2))
  rw [← h1]
  exact (Equiv.sum_comp (Fin.consEquiv (fun _ => Bool)) f).symm

/-- **Normalisation.**  A finite-state source is a probability measure on words
of any fixed length, from any start state and for any parameter vector. -/
theorem sum_probFrom_eq_one (M : FSM k) (θ : Fin k → ℝ) :
    ∀ (n : ℕ) (s : Fin k), ∑ x : Word n, probFrom M θ s n x = 1 := by
  intro n
  induction n with
  | zero =>
      intro s
      simp [probFrom_zero]
  | succ n ih =>
      intro s
      rw [sum_word_succ]
      have : ∀ b : Bool, (∑ y : Word n, probFrom M θ s (n + 1) (Fin.cons b y))
          = wt θ s b := by
        intro b
        have hcongr : ∀ y : Word n,
            probFrom M θ s (n + 1) (Fin.cons b y)
              = wt θ s b * probFrom M θ (M.step s b) n y := by
          intro y
          rw [probFrom_succ]
          simp [Fin.cons_zero, Fin.tail_cons]
        rw [Finset.sum_congr rfl fun y _ => hcongr y, ← Finset.mul_sum, ih (M.step s b), mul_one]
      rw [Finset.sum_congr rfl fun b _ => this b]
      exact wt_sum θ s

theorem sum_prob_eq_one (M : FSM k) (θ : Fin k → ℝ) (n : ℕ) :
    ∑ x : Word n, prob M θ n x = 1 := sum_probFrom_eq_one M θ n M.init

/-! ## Occurrence counts and the likelihood factorisation -/

/-- The number of times the machine is in state `p.1` and emits `p.2`. -/
def visits (M : FSM k) {n : ℕ} (x : Word n) (p : Fin k × Bool) : ℕ :=
  ((Finset.range n).filter (fun i => (stAux M M.init (pad x) i, pad x i) = p)).card

theorem visits_le (M : FSM k) {n : ℕ} (x : Word n) (p : Fin k × Bool) : visits M x p ≤ n := by
  unfold visits
  calc ((Finset.range n).filter _).card ≤ (Finset.range n).card := Finset.card_filter_le _ _
    _ = n := Finset.card_range n

/-- **Likelihood factorisation.**  The likelihood only depends on the sample
through the per-state emission counts. -/
theorem prob_eq_prod_visits (M : FSM k) (θ : Fin k → ℝ) (n : ℕ) (x : Word n) :
    prob M θ n x = ∏ p : Fin k × Bool, wt θ p.1 p.2 ^ visits M x p := by
  unfold prob probFrom visits
  rw [← Finset.prod_fiberwise_of_maps_to
    (g := fun i => (stAux M M.init (pad x) i, pad x i))
    (t := (univ : Finset (Fin k × Bool))) (fun i _ => mem_univ _)]
  refine Finset.prod_congr rfl fun p _ => ?_
  rw [← Finset.prod_const]
  refine Finset.prod_congr rfl fun i hi => ?_
  have h := (mem_filter.mp hi).2
  rw [show stAux M M.init (pad x) i = p.1 from congrArg Prod.fst h,
    show pad x i = p.2 from congrArg Prod.snd h]

/-- Grouping the count product by state. -/
theorem prob_eq_prod_states (M : FSM k) (θ : Fin k → ℝ) (n : ℕ) (x : Word n) :
    prob M θ n x
      = ∏ s : Fin k, (θ s ^ visits M x (s, true) * (1 - θ s) ^ visits M x (s, false)) := by
  rw [prob_eq_prod_visits, Fintype.prod_prod_type]
  refine Finset.prod_congr rfl fun s _ => ?_
  rw [Fintype.prod_bool]
  rfl

/-! ## The finite-state class and its Shtarkov bound -/

/-- Parameter vectors of a `k`-state binary source: one Bernoulli parameter per state. -/
def Params (k : ℕ) : Type := {θ : Fin k → ℝ // ∀ s, 0 ≤ θ s ∧ θ s ≤ 1}

instance : Nonempty (Params k) := ⟨⟨fun _ => 0, fun _ => ⟨le_refl 0, zero_le_one⟩⟩⟩

/-- **The finite-state model class**: all sources emitted by the machine `M`,
as a family of probability measures on words of length `n`. -/
noncomputable def fsmClass (M : FSM k) (n : ℕ) : Params k → Word n → ℝ :=
  fun θ x => prob M θ.1 n x

theorem fsmClass_nonneg (M : FSM k) (n : ℕ) (θ : Params k) (x : Word n) :
    0 ≤ fsmClass M n θ x := probFrom_nonneg M θ.2 _ _ _

theorem fsmClass_le_one (M : FSM k) (n : ℕ) (θ : Params k) (x : Word n) :
    fsmClass M n θ x ≤ 1 := probFrom_le_one M θ.2 _ _ _

theorem sum_fsmClass (M : FSM k) (n : ℕ) (θ : Params k) :
    ∑ x : Word n, fsmClass M n θ x = 1 := sum_prob_eq_one M θ.1 n

/-- The maximum-likelihood parameter vector attached to a vector of counts. -/
noncomputable def mlOf (c : Fin k → ℕ × ℕ) : Params k :=
  ⟨fun s => mlParam (c s).1 (c s).2, fun s => ⟨mlParam_nonneg _ _, mlParam_le_one _ _⟩⟩

/-- The per-state emission counts of a word. -/
def countVec (M : FSM k) {n : ℕ} (x : Word n) : Fin k → ℕ × ℕ :=
  fun s => (visits M x (s, true), visits M x (s, false))

/-- **Maximum-likelihood domination.**  The plug-in source built from the counts
of `x` assigns `x` at least as much mass as any member of the class: it realises
the tropical (max-plus) envelope of the class at `x`. -/
theorem prob_le_prob_ml (M : FSM k) {θ : Fin k → ℝ} (h : ∀ s, 0 ≤ θ s ∧ θ s ≤ 1)
    (n : ℕ) (x : Word n) :
    prob M θ n x ≤ prob M (mlOf (countVec M x)).1 n x := by
  rw [prob_eq_prod_states, prob_eq_prod_states]
  refine Finset.prod_le_prod (fun s _ => ?_) (fun s _ => ?_)
  · exact mul_nonneg (pow_nonneg (h s).1 _) (pow_nonneg (by linarith [(h s).2]) _)
  · exact bernoulli_ml_le _ _ (h s).1 (h s).2

/-- The count statistic, valued in a finite type of size `((n+1)*(n+1))^k`. -/
def countStat (M : FSM k) (n : ℕ) (x : Word n) : Fin k → Fin (n + 1) × Fin (n + 1) :=
  fun s => (⟨visits M x (s, true), Nat.lt_succ_of_le (visits_le M x _)⟩,
            ⟨visits M x (s, false), Nat.lt_succ_of_le (visits_le M x _)⟩)

/-- The maximum-likelihood plug-in source associated with a value of the statistic. -/
noncomputable def mlPlugin (M : FSM k) (n : ℕ) (y : Fin k → Fin (n + 1) × Fin (n + 1)) :
    Params k := mlOf (fun s => ((y s).1.val, (y s).2.val))

theorem mlPlugin_countStat (M : FSM k) (n : ℕ) (x : Word n) :
    mlPlugin M n (countStat M n x) = mlOf (countVec M x) := rfl

/-- **The finite-state Shtarkov bound.**  The Shtarkov sum of the `k`-state class
on words of length `n` is at most `((n+1)^2)^k`; equivalently the minimax regret
is at most `2 k log (n+1)`. -/
theorem shtarkovSum_fsmClass_le (M : FSM k) (n : ℕ) :
    shtarkovSum (fsmClass M n) ≤ (((n + 1) * (n + 1)) ^ k : ℝ) := by
  have key := shtarkovSum_le_card_type (X := Word n) (ι := Params k)
    (fsmClass M n) (countStat M n)
    (fun y x => fsmClass M n (mlPlugin M n y) x)
    (fun θ x => by
      show fsmClass M n θ x ≤ fsmClass M n (mlPlugin M n (countStat M n x)) x
      rw [mlPlugin_countStat]
      exact prob_le_prob_ml M θ.2 n x)
    (fun y x => fsmClass_nonneg M n _ x)
    (fun y => le_of_eq (sum_fsmClass M n _))
  refine key.trans (le_of_eq ?_)
  simp

/-- A class of probability measures always has Shtarkov sum at least `1`. -/
theorem one_le_shtarkovSum_fsmClass (M : FSM k) (n : ℕ) :
    1 ≤ shtarkovSum (fsmClass M n) := by
  have h := shtarkovSum_ge_packing (fsmClass M n) (fsmClass_nonneg M n) (fsmClass_le_one M n)
    (univ : Finset (Word n)) (fun _ => Classical.arbitrary (Params k))
  rwa [sum_fsmClass M n (Classical.arbitrary (Params k))] at h

/-- The universal cap: the Shtarkov sum never exceeds the number of samples. -/
theorem shtarkovSum_fsmClass_le_two_pow (M : FSM k) (n : ℕ) :
    shtarkovSum (fsmClass M n) ≤ (2 ^ n : ℝ) := by
  refine (shtarkovSum_le_card (fsmClass M n) (fsmClass_le_one M n)).trans (le_of_eq ?_)
  simp

end TropicalShtarkov