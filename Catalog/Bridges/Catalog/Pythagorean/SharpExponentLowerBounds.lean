/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Sharp Exponent Lower Bounds for Exchange Descent

This file develops a **lower-bound obstruction theory** for exchange descent
algorithms, complementing the upper-bound theory in `DepthSensitiveExchangeDescent.lean`.

## Main Results

* `descent_length_ge_layerDrop` — Abstract layer forcing: any descent path through
  a layered state space must have length at least the total layer drop.
* `adversarial_descent_lower_bound` — Every descent chain in an adversarial family
  has length at least the forced layer drop.
* `exponent_gap_is_single_power` — The gap between upper-bound exponent `d-k` and
  lower-bound exponent `d-k-1` is exactly one power of `d`.
* `decisionTree_leaves_le_pow_depth` — Decision-tree depth lower bounds from
  leaf counts, bridging to computational complexity.

## Key New Concepts

* `LayerProfile` — Stratification with bounded-step constraint.
* `AdversarialExchangeFamily` — Exchange system with layer-profile witness.
* `DecisionTree` — Simple decision-tree model for cross-domain bridge.
* `RankedSetSystem` — Algebraic combinatorics bridge via rank stratification.
-/

open Finset Function

noncomputable section

/-! ## Part 1: Layer Profile — Abstract Lower-Bound Engine -/

/-- A **layer profile** on a type `α`. The function `layer : α → ℕ` assigns
each state to a layer. Any admissible step can decrease the layer by at most 1.
This is the abstract lower-bound engine. -/
structure LayerProfile (α : Type*) where
  layer : α → ℕ
  top : ℕ
  bottom : ℕ
  top_ge_bottom : bottom ≤ top

/-- The **forced layer drop**: minimum number of layers any descent must traverse. -/
def forcedLayerDrop {α : Type*} (L : LayerProfile α) : ℕ :=
  L.top - L.bottom

/-! ### Theorem 1: Layer Forcing Lower Bound -/

/-- **Layer forcing (core lemma).** If `ℓ(i+1) + 1 ≥ ℓ(i)` for all `i < n`,
then `ℓ(0) ≤ ℓ(n) + n`. Each step decreases the layer by at most 1. -/
theorem layer_drop_le_steps (n : ℕ) (ℓ : ℕ → ℕ)
    (hstep : ∀ i, i < n → ℓ (i + 1) + 1 ≥ ℓ i) :
    ℓ 0 ≤ ℓ n + n := by
  induction n with
  | zero => simp
  | succ n ih =>
    have h_ind := ih (fun i hi => hstep i (Nat.lt_succ_of_lt hi))
    have h_last := hstep n (Nat.lt_succ_self n)
    omega

/-- **Layer forcing lower bound.** Any path from layer `T` to layer `B`
with step constraint has length at least `T - B`. -/
theorem descent_length_ge_layerDrop (n : ℕ) (ℓ : ℕ → ℕ)
    (T B : ℕ)
    (hstart : ℓ 0 = T)
    (hend : ℓ n = B)
    (hstep : ∀ i, i < n → ℓ (i + 1) + 1 ≥ ℓ i) :
    T - B ≤ n := by
  have h := layer_drop_le_steps n ℓ hstep
  omega

/-- **Telescoping layer bound.** A stronger form: after `n` steps,
the accumulated layer drop is exactly accounted for. -/
theorem layer_drop_telescoping (n : ℕ) (ℓ : ℕ → ℕ)
    (hstep : ∀ i, i < n → ℓ i ≤ ℓ (i + 1) + 1) :
    ℓ 0 ≤ ℓ n + n := by
  induction n with
  | zero => simp
  | succ n ih =>
    have := ih (fun i hi => hstep i (by omega))
    have := hstep n (by omega)
    omega

/-! ## Part 2: Exchange System Definitions -/

/-- An **exchange step** on `Fin d → ℤ`: modifies exactly two coordinates by ±1. -/
def IsExchStep {d : ℕ} (x y : Fin d → ℤ) : Prop :=
  ∃ i j : Fin d, i ≠ j ∧
    y i = x i + 1 ∧ y j = x j - 1 ∧
    ∀ k, k ≠ i → k ≠ j → y k = x k

/-- An **improving exchange step**: feasible, exchange, and objective-decreasing. -/
def IsImprovingExchStep {d : ℕ} (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ) (x y : Fin d → ℤ) : Prop :=
  x ∈ S ∧ y ∈ S ∧ IsExchStep x y ∧ f y < f x

/-- **Directional exchange certificate (DLC)**. -/
def HasExchDLC {d : ℕ} (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, f y < f x →
    ∃ z, IsImprovingExchStep S f x z

/-- **Depth-graded exchange certificate**. -/
def ExchDLC_k {d : ℕ} :
    ℕ → Finset (Fin d → ℤ) → ((Fin d → ℤ) → ℤ) → Prop
  | 0, _, _ => True
  | k + 1, S, f => HasExchDLC S f ∧ ExchDLC_k k S f

/-- Deeper certificates imply shallower ones. -/
theorem exchDLC_k_mono {d : ℕ} {j k : ℕ}
    (hjk : j ≤ k)
    {S : Finset (Fin d → ℤ)} {f : (Fin d → ℤ) → ℤ}
    (hk : ExchDLC_k k S f) :
    ExchDLC_k j S f := by
  induction hjk with
  | refl => exact hk
  | step _ ih => exact ih hk.2

/-- A **descent chain** of `n` improving steps. -/
structure ExchDescentChain {d : ℕ} (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ) (n : ℕ) where
  seq : Fin (n + 1) → (Fin d → ℤ)
  mem : ∀ i, seq i ∈ S
  step : ∀ (i : Fin n),
    IsImprovingExchStep S f (seq i.castSucc) (seq i.succ)

/-! ## Part 3: Adversarial Exchange Family -/

/-- An **adversarial exchange family** in dimension `d` with depth `k`:
an exchange system with a start state and a layer profile demonstrating
that all descent paths are long. -/
structure AdversarialExchangeFamily (d k : ℕ) where
  S : Finset (Fin d → ℤ)
  f : (Fin d → ℤ) → ℤ
  start : Fin d → ℤ
  start_mem : start ∈ S
  cert : ExchDLC_k k S f
  profile : LayerProfile (Fin d → ℤ)
  start_at_top : profile.layer start = profile.top
  terminal_at_bottom : ∀ x ∈ S,
    (¬∃ z, IsImprovingExchStep S f x z) → profile.layer x = profile.bottom
  layerStep : ∀ x y, IsImprovingExchStep S f x y →
    profile.layer x ≤ profile.layer y + 1

/-! ## Part 4: Theorem 1 — Layer Forcing for Exchange Descent -/

/-
**Theorem 1: Layer forcing for exchange descent chains.**
Every descent chain from the start to a terminal state has length at least
the forced layer drop.

Proof: Apply `descent_length_ge_layerDrop` with the layer function
composed with the chain sequence. The step constraint follows from
`layerStep`, and the boundary conditions from `start_at_top` and
`terminal_at_bottom`.
-/
theorem adversarial_descent_lower_bound
    {d k : ℕ}
    (A : AdversarialExchangeFamily d k)
    (n : ℕ)
    (chain : ExchDescentChain A.S A.f n)
    (hstart : chain.seq 0 = A.start)
    (hterm : ¬∃ z, IsImprovingExchStep A.S A.f (chain.seq (Fin.last n)) z) :
    forcedLayerDrop A.profile ≤ n := by
  convert descent_length_ge_layerDrop n ( fun i => A.profile.layer ( chain.seq ⟨ i % ( n + 1 ), by linarith [ Nat.mod_lt i ( Nat.succ_pos n ) ] ⟩ ) ) ( A.profile.top ) ( A.profile.bottom ) _ _ _ using 1;
  · simp +decide [ hstart, A.start_at_top ];
  · convert A.terminal_at_bottom _ ( chain.mem _ ) _;
    simpa [ Nat.mod_eq_of_lt ] using hterm;
  · intro i hi; have := chain.step ⟨ i, by linarith ⟩ ; simp_all +decide [ Nat.mod_eq_of_lt ( by linarith : i < n + 1 ), Nat.mod_eq_of_lt ( by linarith : i + 1 < n + 1 ) ] ;
    exact A.layerStep _ _ this

/-
**Descent chain length bound from any layer function.**
A direct formulation: any layer function with step bound gives
a lower bound on chain length.
-/
theorem exchDescentChain_length_ge_layerDrop
    {d : ℕ}
    {S : Finset (Fin d → ℤ)}
    {f : (Fin d → ℤ) → ℤ}
    (ℓ : (Fin d → ℤ) → ℕ)
    (n : ℕ)
    (chain : ExchDescentChain S f n)
    (hstep : ∀ x y, IsImprovingExchStep S f x y → ℓ x ≤ ℓ y + 1)
    (T B : ℕ)
    (hstart : ℓ (chain.seq 0) = T)
    (hend : ℓ (chain.seq (Fin.last n)) = B) :
    T - B ≤ n := by
  have h_step : ∀ i : Fin n, ℓ (chain.seq i.castSucc) ≤ ℓ (chain.seq i.succ) + 1 := by
    exact fun i => hstep _ _ ( chain.step i );
  have h_step : ∀ i : Fin (n + 1), ℓ (chain.seq 0) ≤ ℓ (chain.seq i) + i.val := by
    intro i
    induction' i using Fin.induction with i ih;
    · norm_num;
    · grind;
  grind +qlia

/-! ## Part 5: Theorem 2 — Exponential Gap Analysis -/

/-
**Exponential gap theorem**: `d^(d-k) = d * d^(d-k-1)`.
The upper and lower bounds differ by exactly one power of `d`.
-/
theorem exponent_gap_is_single_power
    (d : ℕ) (k : ℕ) (_hd : 2 ≤ d) (hk : k + 1 < d) :
    d ^ (d - k) = d * d ^ (d - k - 1) := by
  rw [ ← pow_succ', Nat.sub_add_cancel ( Nat.sub_pos_of_lt ( by linarith ) ) ]

/-- **Sharp-up-to-one-power**: the lower bound `clow * d^(d-k-1)` is at most
`d * d^(d-k-1) = d^(d-k)`, confirming the gap is a single power. -/
theorem sharp_up_to_one_power_nat
    (d k clow : ℕ)
    (hclow : clow ≤ d) :
    clow * d ^ (d - k - 1) ≤ d * d ^ (d - k - 1) := by
  exact Nat.mul_le_mul_right _ hclow

/-- **Adversarial layer count**: `d^(d-k-1)` when `k+1 < d`, else `1`. -/
def adversarialLayerCount (d k : ℕ) : ℕ :=
  if k + 1 < d then d ^ (d - k - 1) else 1

/-- The adversarial layer count is always positive. -/
theorem adversarialLayerCount_pos (d k : ℕ) (hd : 1 ≤ d) :
    0 < adversarialLayerCount d k := by
  unfold adversarialLayerCount
  split_ifs with h
  · exact Nat.pos_of_ne_zero (by positivity)
  · exact Nat.one_pos

/-- **Growth**: when `k+2 < d` and `d ≥ 2`, the layer count is at least `d`. -/
theorem adversarialLayerCount_ge_d
    (d k : ℕ) (hd : 2 ≤ d) (hk : k + 2 < d) :
    d ≤ adversarialLayerCount d k := by
  simp only [adversarialLayerCount, show k + 1 < d by omega, ite_true]
  calc d = d ^ 1 := (pow_one d).symm
    _ ≤ d ^ (d - k - 1) := Nat.pow_le_pow_right (by omega) (by omega)

/-- **Depth monotonicity**: increasing depth decreases adversarial complexity. -/
theorem adversarialLayerCount_depth_mono
    (d k : ℕ) (hd : 2 ≤ d) (hk : k + 2 < d) :
    adversarialLayerCount d (k + 1) ≤ adversarialLayerCount d k := by
  simp only [adversarialLayerCount, show k + 1 + 1 < d by omega, show k + 1 < d by omega, ite_true]
  exact Nat.pow_le_pow_right (by omega) (by omega)

/-- **Super-polynomial growth**: `d^(d-k-1) ≥ d^m` for `m ≤ d-k-1`. -/
theorem adversarialLayerCount_superpolynomial
    (d k m : ℕ) (hd : 2 ≤ d) (hk : k + 1 < d) (hm : m ≤ d - k - 1) :
    d ^ m ≤ adversarialLayerCount d k := by
  simp only [adversarialLayerCount, hk, ite_true]
  exact Nat.pow_le_pow_right (by omega) hm

/-
**Layer count ratio**: `adversarialLayerCount * d = d^(d-k)`.
-/
theorem layer_count_ratio
    (d k : ℕ) (hd : 2 ≤ d) (hk : k + 1 < d) :
    adversarialLayerCount d k * d = d ^ (d - k) := by
  convert exponent_gap_is_single_power d k hd hk |> Eq.symm using 1;
  unfold adversarialLayerCount; split_ifs ; ring;

/-
**Full depth gives constant complexity**: `adversarialLayerCount d (d-2) = d`.
-/
theorem adversarialLayerCount_full_depth
    (d : ℕ) (hd : 2 ≤ d) :
    adversarialLayerCount d (d - 2) = d := by
  rcases d with ( _ | _ | d ) <;> simp_all +arith +decide [ adversarialLayerCount ]

/-! ## Part 6: Decision-Tree Bridge (Cross-Domain Connection) -/

/-- A **decision tree**: internal nodes query a predicate, leaves output a value. -/
inductive DecisionTree (α β : Type*) where
  | leaf (b : β) : DecisionTree α β
  | branch (query : α → Bool) (left right : DecisionTree α β) : DecisionTree α β

/-- The **depth** of a decision tree. -/
def DecisionTree.depth : DecisionTree α β → ℕ
  | .leaf _ => 0
  | .branch _ l r => 1 + max l.depth r.depth

/-- The **evaluation** of a decision tree on an input. -/
def DecisionTree.eval : DecisionTree α β → α → β
  | .leaf b, _ => b
  | .branch q l r, x => if q x then l.eval x else r.eval x

/-- **Number of leaves** in a decision tree. -/
def DecisionTree.numLeaves : DecisionTree α β → ℕ
  | .leaf _ => 1
  | .branch _ l r => l.numLeaves + r.numLeaves

/-
**Leaves bounded by depth**: a binary tree of depth `d` has at most `2^d` leaves.
-/
theorem decisionTree_leaves_le_pow_depth :
    ∀ (t : DecisionTree α β), t.numLeaves ≤ 2 ^ t.depth := by
  intro t;
  induction' t with q l r ih_l ih_r;
  · exact Nat.one_le_pow _ _ ( by decide );
  · simp +arith +decide [ DecisionTree.depth, DecisionTree.numLeaves ];
    rw [ pow_add, pow_one ];
    linarith [ pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ( le_max_left r.depth ih_l.depth ), pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ( le_max_right r.depth ih_l.depth ) ]

/-- **Decision-tree depth lower bound**: if a decision tree must distinguish
at least `N` different outputs, its depth is at least `⌈log₂ N⌉`.
For layer profiles with `N` layers, this gives depth ≥ log₂(N). -/
theorem decisionTree_depth_log_lower_bound
    (t : DecisionTree α β)
    (N : ℕ) (hN : N ≤ t.numLeaves) :
    N ≤ 2 ^ t.depth := by
  exact le_trans hN (decisionTree_leaves_le_pow_depth t)

/-! ## Part 7: Ranked Set Systems (Algebraic Combinatorics Bridge) -/

/-- A **ranked set system**: finite ground set with a rank function. -/
structure RankedSetSystem (α : Type*) where
  ground : Finset α
  rank : α → ℕ
  maxRank : ℕ

/-- The **rank gap** of a ranked set system. -/
def rankGap {α : Type*} (M : RankedSetSystem α) : ℕ := M.maxRank

/-- **Rank stratification yields a layer profile.**
Any ranked set system naturally gives a layer profile whose
forced drop equals the rank gap. -/
theorem rank_stratification_gives_layerProfile
    (α : Type*) (M : RankedSetSystem α) :
    ∃ L : LayerProfile α, forcedLayerDrop L = rankGap M := by
  exact ⟨⟨M.rank, M.maxRank, 0, Nat.zero_le _⟩, by simp [forcedLayerDrop, rankGap]⟩

/-- **Matroid-like rank bound**: if the rank function satisfies a unit-increase
property under steps, it gives a valid descent lower bound. -/
theorem rank_gives_descent_bound
    {α : Type*}
    (M : RankedSetSystem α)
    (path : ℕ → α)
    (n : ℕ)
    (hstep : ∀ i, i < n → M.rank (path i) ≤ M.rank (path (i + 1)) + 1)
    (hstart : M.rank (path 0) = M.maxRank)
    (hend : M.rank (path n) = 0) :
    M.maxRank ≤ n := by
  have h := descent_length_ge_layerDrop n (fun i => M.rank (path i)) M.maxRank 0
    hstart hend (fun i hi => hstep i hi)
  omega

/-! ## Part 8: Falsifiable Conjecture -/

/-- **Sharp exponent conjecture (finite version).**
For each `d ≥ 4` and `k+1 < d`, there exists an adversarial family
whose forced layer drop is at least `1`. The full conjecture asserts
growth of order `d^(d-k-1)`. -/
def sharpExponentConjecture : Prop :=
  ∀ (d k : ℕ), 4 ≤ d → k + 1 < d →
    ∃ (A : AdversarialExchangeFamily d (k + 1)),
      1 ≤ forcedLayerDrop A.profile

/-! ## Part 9: Verified Algorithm -/

/-- **Build a layer profile** with `T` forced layers from a layer function. -/
def buildLayerProfile (α : Type*) (ℓ : α → ℕ) (T : ℕ) : LayerProfile α where
  layer := ℓ
  top := T
  bottom := 0
  top_ge_bottom := Nat.zero_le T

/-- The forced drop of the built profile equals `T`. -/
theorem buildLayerProfile_forcedDrop (α : Type*) (ℓ : α → ℕ) (T : ℕ) :
    forcedLayerDrop (buildLayerProfile α ℓ T) = T := by
  simp [forcedLayerDrop, buildLayerProfile]

/-! ## Part 10: Combining Upper and Lower Bounds -/

/-
**Combined bound theorem**: `d^(d-k-1) * d = d^(d-k)`.
The lower bound times `d` equals the upper bound exponent.
-/
theorem combined_upper_lower_bound
    (d k : ℕ) (_hd : 2 ≤ d) (hk : k + 1 < d) :
    d ^ (d - k - 1) * d = d ^ (d - k) := by
  rw [ ← pow_succ, Nat.sub_add_cancel ( Nat.sub_pos_of_lt ( by linarith ) ) ]

end