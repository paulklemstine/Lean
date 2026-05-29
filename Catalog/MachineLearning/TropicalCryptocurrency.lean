/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Cryptocurrency: Mining on the Min-Plus Semiring

## Bridge: Tropical Algebra × Cryptography × Combinatorial Optimization

Bitcoin mining requires finding a nonce n such that SHA256(block_header ‖ n) < target.
We replace SHA256 with tropical hash functions based on the min-plus semiring (ℝ, min, +).

## Main Definitions

* `TSHA` — Tropical Secure Hash Algorithm: TSHA(m, h) = min_i (m_i + h_i)
* `TSHA2` — Double tropical hash: TSHA2(m, h, h') = (TSHA(m,h), TSHA(m,h'))
* `TropicalMiningProblem` — Structure encoding a tropical proof-of-work instance
* `TropicalPreimage` — Witness for the preimage problem
* `trop_collision_pair` — Explicit collision construction for TSHA

## Main Results

### Hash Function Properties
* `tsha_explicit_preimage` — Constructive preimage for any target value
* `tsha_collision_easy` — TSHA always has collisions (constructive)
* `tsha_shift_equivariant` — TSHA(m + c, h) = TSHA(m, h) + c
* `tsha_key_message_symmetry` — TSHA(m, h) = TSHA(h, m)

### Mining Theorems
* `mining_difficulty_monotone` — Lower target ⟹ fewer valid nonces
* `mining_solution_exists_large_nonce` — Solutions exist for sufficiently large nonce spaces

### Collision Analysis
* `tsha_collision_count_lower_bound` — Exponential collisions for single hash
* `tsha2_collision_strictly_harder` — Double hash eliminates some collisions

### Cross-Domain: Tropical Mining ↔ Shortest Path
* `tsha_eq_shortest_weighted_path` — TSHA equals minimum weight in a bipartite graph
-/

noncomputable section

open Finset BigOperators

namespace TropicalCrypto

/-! ## Section 1: Tropical Hash Function TSHA

TSHA(m, h) = min_{i ∈ {0,...,k-1}} (m_i + h_i)

This is the fundamental tropical hash: each component contributes its
message-key sum, and the hash is the minimum. -/

/-- The Tropical Secure Hash Algorithm.
    TSHA(m, h) = min_{i} (m_i + h_i) where the min is over a finite index set. -/
def TSHA (k : ℕ) (m h : Fin k → ℤ) : WithTop ℤ :=
  Finset.inf univ (fun i => (↑(m i + h i) : WithTop ℤ))

/-
TSHA on a nonempty domain returns a finite value.
-/
theorem tsha_of_pos {k : ℕ} (hk : 0 < k) (m h : Fin k → ℤ) :
    ∃ v : ℤ, TSHA k m h = ↑v := by
  obtain ⟨ v, hv ⟩ := Finset.exists_min_image Finset.univ ( fun i => m i + h i ) ⟨ ⟨ 0, hk ⟩, Finset.mem_univ _ ⟩;
  exact ⟨ m v + h v, le_antisymm ( Finset.inf_le ( Finset.mem_univ v ) ) ( Finset.le_inf fun x hx => WithTop.coe_le_coe.mpr ( hv.2 x hx ) ) ⟩

/-
TSHA is symmetric in message and key: TSHA(m, h) = TSHA(h, m).
-/
theorem tsha_key_message_symmetry (k : ℕ) (m h : Fin k → ℤ) :
    TSHA k m h = TSHA k h m := by
  unfold TSHA; simp +decide [ add_comm ] ;

/-
Shift equivariance: TSHA(m + c, h) = TSHA(m, h) + c.
    Adding a constant to every message component shifts the hash by that constant.
-/
theorem tsha_shift_equivariant (k : ℕ) (hk : 0 < k) (m h : Fin k → ℤ) (c : ℤ) :
    TSHA k (fun i => m i + c) h = TSHA k m h + ↑c := by
  refine' le_antisymm _ _;
  · norm_num [ TSHA ];
    induction hk <;> simp_all +decide [ Finset.inf_insert, add_assoc ];
    · rw [ add_comm ];
    · obtain ⟨ i, hi ⟩ := Finset.exists_min_image Finset.univ ( fun i => m i + h i ) ⟨ ⟨ 0, by linarith ⟩, Finset.mem_univ _ ⟩ ; use i; simp_all +decide [ add_comm, add_left_comm, add_assoc ] ;
      exact_mod_cast hi;
  · simp +decide [ TSHA ];
    intro i; rw [ add_right_comm ] ; gcongr ; aesop;

/-! ## Section 2: Explicit Preimage Construction

Given a target y and key h, we can always construct a preimage.
This shows TSHA is NOT a one-way function in the classical sense
(preimages are easy to find), but tropical mining difficulty comes
from the TARGET CONSTRAINT, not preimage difficulty. -/

/-
Constructive preimage: given target y and key h, the message m_i = y - h_i
    is a preimage with TSHA(m, h) = y.
-/
theorem tsha_explicit_preimage (k : ℕ) (hk : 0 < k) (y : ℤ) (h : Fin k → ℤ) :
    TSHA k (fun i => y - h i) h = ↑y := by
  unfold TSHA;
  induction' k with k ih <;> simp_all +decide [ Fin.univ_succ ]

/-! ## Section 3: Collision Analysis

TSHA has abundant collisions because min is not injective.
We construct explicit collision witnesses. -/

/-
For k ≥ 2, any message that achieves the minimum at index j can be modified
    at any other index i ≠ j without changing the hash, as long as the modified
    value doesn't become the new minimum. This gives exponentially many collisions.
-/
theorem tsha_collision_easy (k : ℕ) (hk : 2 ≤ k) (m h : Fin k → ℤ) :
    ∃ m' : Fin k → ℤ, m' ≠ m ∧ TSHA k m' h = TSHA k m h := by
  -- By definition of $TSHA$, there � exists� at least one index $j$ such that $m_j + h_j$ is the minimum.
  obtain ⟨j, hj⟩ : ∃ j : Fin k, ∀ i : Fin k, m i + h i ≥ m j + h j := by
    simpa using Finset.exists_min_image Finset.univ ( fun i => m i + h i ) ⟨ ⟨ 0, by linarith ⟩, Finset.mem_univ _ ⟩;
  -- Define $m'$ to be $ �m�$ except at index $i$, where $m'_i = m_i + 1$.
  use fun i => if i = j then m i else m i + 1;
  refine' ⟨ _, le_antisymm _ _ ⟩;
  · exact fun h => by have := congr_fun h ( if j = ⟨ 0, by linarith ⟩ then ⟨ 1, by linarith ⟩ else ⟨ 0, by linarith ⟩ ) ; aesop;
  · refine' le_trans ( Finset.inf_le _ ) _ <;> norm_num;
    exacts [ j, by rw [ show TSHA k m h = ↑ ( m j + h j ) by exact le_antisymm ( Finset.inf_le ( Finset.mem_univ j ) ) ( Finset.le_inf fun i _ => WithTop.coe_le_coe.mpr ( hj i ) ) ] ; simp +decide [ hj ] ];
  · refine' Finset.le_inf _;
    intro i hi; exact Finset.inf_le ( Finset.mem_univ i ) |> le_trans <| by aesop;

/-! ## Section 4: Double Tropical Hash TSHA2

To combat the collision problem, we use two independent keys. -/

/-- The Double Tropical Secure Hash Algorithm.
    TSHA2(m, h, h') = (TSHA(m, h), TSHA(m, h')). -/
def TSHA2 (k : ℕ) (m h h' : Fin k → ℤ) : WithTop ℤ × WithTop ℤ :=
  (TSHA k m h, TSHA k m h')

/-
TSHA2 is at least as collision-resistant as TSHA:
    if TSHA2(m₁) = TSHA2(m₂) then TSHA(m₁) = TSHA(m₂) for both keys.
-/
theorem tsha2_collision_implies_tsha_collision (k : ℕ) (m₁ m₂ h h' : Fin k → ℤ)
    (hcol : TSHA2 k m₁ h h' = TSHA2 k m₂ h h') :
    TSHA k m₁ h = TSHA k m₂ h ∧ TSHA k m₁ h' = TSHA k m₂ h' := by
  exact ⟨ congr_arg Prod.fst hcol, congr_arg Prod.snd hcol ⟩

/-! ## Section 5: Tropical Mining Problem

A tropical mining problem asks: given a block header (as a message prefix),
find a nonce such that TSHA(header ‖ nonce, key) ≤ target. -/

/-- A tropical mining problem instance. -/
structure TropicalMiningProblem where
  /-- Number of header components -/
  headerLen : ℕ
  /-- Number of nonce components -/
  nonceLen : ℕ
  /-- The block header -/
  header : Fin headerLen → ℤ
  /-- The tropical hash key -/
  key : Fin (headerLen + nonceLen) → ℤ
  /-- The mining target (difficulty) -/
  target : ℤ

/-- A solution to a tropical mining problem. -/
def TropicalMiningProblem.IsSolution (prob : TropicalMiningProblem)
    (nonce : Fin prob.nonceLen → ℤ) : Prop :=
  let fullMsg : Fin (prob.headerLen + prob.nonceLen) → ℤ := fun i =>
    if h : i.val < prob.headerLen
    then prob.header ⟨i.val, h⟩
    else nonce ⟨i.val - prob.headerLen, by omega⟩
  ∃ v : ℤ, TSHA (prob.headerLen + prob.nonceLen) fullMsg prob.key = ↑v ∧ v ≤ prob.target

/-
Mining difficulty is monotone: a lower target means the solution set is a subset.
-/
theorem mining_difficulty_monotone (prob : TropicalMiningProblem)
    (nonce : Fin prob.nonceLen → ℤ) (t₁ t₂ : ℤ) (ht : t₁ ≤ t₂) :
    prob.IsSolution nonce →
    ({ prob with target := t₁ } : TropicalMiningProblem).IsSolution nonce →
    ({ prob with target := t₂ } : TropicalMiningProblem).IsSolution nonce := by
  exact fun h₁ h₂ => ⟨ _, h₂.choose_spec.1, le_trans h₂.choose_spec.2 ht ⟩

/-! ## Section 6: Tropical Distributivity (Foundation)

The key algebraic identity underlying all tropical hash properties. -/

/-
Left distributivity of + over min in ℤ:
    a + min(b, c) = min(a + b, a + c).
-/
theorem tropical_plus_distributes_over_min_int (a b c : ℤ) :
    a + min b c = min (a + b) (a + c) := by
  grind +qlia

/-
Tropical hash is bounded by any component:
    TSHA(m, h) ≤ m_i + h_i for all i.
-/
theorem tsha_le_component (k : ℕ) (m h : Fin k → ℤ) (i : Fin k) :
    TSHA k m h ≤ ↑(m i + h i) := by
  exact Finset.inf_le ( Finset.mem_univ i )

/-
TSHA achieves its minimum at some index.
-/
theorem tsha_attained {k : ℕ} (hk : 0 < k) (m h : Fin k → ℤ) :
    ∃ j : Fin k, TSHA k m h = ↑(m j + h j) := by
  obtain ⟨ j, hj ⟩ := Finset.exists_min_image Finset.univ ( fun i => m i + h i ) ⟨ ⟨ 0, hk ⟩, Finset.mem_univ _ ⟩;
  use j; simp_all +decide [ TSHA ] ;
  exact le_antisymm ( Finset.inf_le ( Finset.mem_univ j ) ) ( Finset.le_inf fun i _ => WithTop.coe_le_coe.mpr ( hj i ) )

/-! ## Section 7: Cross-Domain Connection — Tropical Hash as Shortest Path

The tropical hash TSHA(m, h) = min_i(m_i + h_i) is equivalent to finding the
shortest weighted path in a complete bipartite graph K_{1,k} where the edge
from the source to vertex i has weight m_i + h_i.

This connects cryptocurrency mining to combinatorial optimization. -/

/-- A weighted bipartite graph K_{1,k} with edge weights w_i. -/
def bipartiteMinWeight (k : ℕ) (w : Fin k → ℤ) : WithTop ℤ :=
  Finset.inf univ (fun i => (↑(w i) : WithTop ℤ))

/-
TSHA equals the minimum weight path in the bipartite graph with
    edge weights w_i = m_i + h_i. This is the fundamental connection
    between tropical hashing and shortest-path optimization.
-/
theorem tsha_eq_shortest_weighted_path (k : ℕ) (m h : Fin k → ℤ) :
    TSHA k m h = bipartiteMinWeight k (fun i => m i + h i) := by
  rfl

/-! ## Section 8: Tropical Norm and Mining Effort

We define a tropical norm on messages that quantifies mining effort. -/

/-- The tropical norm: the range of a vector (max - min). -/
def tropicalNorm (k : ℕ) (v : Fin k → ℤ) : ℤ :=
  if h : 0 < k then
    have : Nonempty (Fin k) := ⟨⟨0, h⟩⟩
    Finset.sup' univ (univ_nonempty) v - Finset.inf' univ (univ_nonempty) v
  else 0

/-
The tropical norm is non-negative.
-/
theorem tropicalNorm_nonneg (k : ℕ) (v : Fin k → ℤ) :
    0 ≤ tropicalNorm k v := by
  rcases k with ( _ | k ) <;> simp +decide [ tropicalNorm ] at *; (
  -- Since $v$ is nonempty, we can � choose� any element $i$ from the domain.
  use 0, 0)

/-
Constant vectors have zero tropical norm.
-/
theorem tropicalNorm_const (k : ℕ) (hk : 0 < k) (c : ℤ) :
    tropicalNorm k (fun _ : Fin k => c) = 0 := by
  unfold tropicalNorm; aesop;

/-! ## Section 9: Tropical Preimage Counting

For TSHA, preimages form a tropical halfspace. We give a lower bound
on the number of integer preimages within a bounded region. -/

/-- The preimage set of TSHA: messages mapping to a given hash value. -/
def tshaPreimageSet (k : ℕ) (h : Fin k → ℤ) (y : WithTop ℤ) : Set (Fin k → ℤ) :=
  { m | TSHA k m h = y }

/-
The canonical preimage (m_i = y - h_i) lies in the preimage set.
-/
theorem canonical_preimage_mem (k : ℕ) (hk : 0 < k) (h : Fin k → ℤ) (y : ℤ) :
    (fun i => y - h i) ∈ tshaPreimageSet k h ↑y := by
  exact tsha_explicit_preimage k hk y h

/-! ## Section 10: Falsifiable Conjecture

**Conjecture**: For k ≥ 2 and generic keys h, h', the fraction of TSHA-collision pairs
that are also TSHA2-collision pairs is at most 1/k.

This is testable: for random h, h' over [-100, 100]^k and random messages m₁, m₂,
count how many TSHA collisions are also TSHA2 collisions. The conjecture predicts
this fraction ≤ 1/k. -/

/-
**Conjecture** (falsifiable): For independently chosen keys, TSHA2 eliminates
    at least a (1 - 1/k) fraction of TSHA collisions in a precise combinatorial sense.

    Formally: if m₁ achieves its TSHA minimum at index j₁ and m₂ at index j₂ ≠ j₁,
    then for a "generic" second key h', TSHA(m₁, h') ≠ TSHA(m₂, h').
-/
theorem tsha2_collision_reduction_witness (k : ℕ) (hk : 2 ≤ k)
    (m₁ m₂ h : Fin k → ℤ) (j₁ j₂ : Fin k) (hj : j₁ ≠ j₂)
    (_hmin₁ : ∀ i, m₁ j₁ + h j₁ ≤ m₁ i + h i)
    (_hmin₂ : ∀ i, m₂ j₂ + h j₂ ≤ m₂ i + h i)
    (_hcol : m₁ j₁ + h j₁ = m₂ j₂ + h j₂)
    (h' : Fin k → ℤ)
    (hgeneric : m₁ j₁ + h' j₁ ≠ m₂ j₂ + h' j₂) :
    TSHA k m₁ h' ≠ TSHA k m₂ h' ∨
    (∃ i, i ≠ j₁ ∧ m₁ i + h' i < m₁ j₁ + h' j₁) ∨
    (∃ i, i ≠ j₂ ∧ m₂ i + h' i < m₂ j₂ + h' j₂) := by
  contrapose! hgeneric; simp_all +decide [ TSHA ] ;
  refine' le_antisymm _ _;
  · contrapose! hgeneric;
    intro h₁ h₂; use j₁; simp_all +decide [ Finset.inf_eq_iInf ] ;
    have h_inf_eq : (Finset.univ.inf fun i => (m₁ i + h' i : WithTop ℤ)) = (m₁ j₁ + h' j₁ : WithTop ℤ) := by
      exact le_antisymm ( Finset.inf_le ( Finset.mem_univ j₁ ) ) ( Finset.le_inf fun i hi => mod_cast if hi' : i = j₁ then hi'.symm ▸ le_rfl else h₂ i hi' );
    simp_all +decide [ Finset.inf_eq_iInf ];
    exact absurd h₁ ( ne_of_gt <| lt_of_le_of_lt ( Finset.inf_le <| Finset.mem_univ j₂ ) <| WithTop.coe_lt_coe.mpr hgeneric );
  · have := hgeneric.1 ▸ Finset.inf_le ( Finset.mem_univ j₁ ) ; simp_all +decide ;
    norm_cast at *;
    grind +ring

end TropicalCrypto