import Tropical.CompressionDelta.Coherence
import Tropical.CompressionDelta.Structure

/-!
# Amortized model-delta compression, IX: the coherence-length law

`CompressionDelta.Amortization` treats a perfectly coherent stream (one domain, delta
amortized to nothing) and `CompressionDelta.Coherence` the maximally incoherent one
(domain flips every message, half a bit lost forever).  This file interpolates between
them and settles the general two-domain case: the stream consists of `B` **blocks** of `L`
consecutive messages, the domain alternating from block to block.

The answer is a clean min-plus formula.  Writing `M₂ = min (2 * D) L` and
`M₁ = min D L`, the optimal protocol transmits

`B * (L * r) + ⌊B/2⌋ * M₂ + (B % 2) * M₁`

bits.  Hence the amortized excess over the rate floor is `min(2D, L) / (2L)` bits per
message: **the delta amortizes against the coherence length `L`, not against the stream
length**.  Setting `L = 1` recovers the half-bit loss of `Coherence`, and letting
`L → ∞` recovers the vanishing overhead of `Amortization`.

## Main results

* `CompressionDelta.blockAbsorb` — exact reduction of one block of `L` messages, from
  either decoder state, in terms of the continuation values (a two-state min-plus
  transfer step).
* `CompressionDelta.optCost_blockCosts` — the exact optimum for `B` alternating blocks.
* `CompressionDelta.blockExcess_closed_form` — the closed form `⌊B/2⌋ M₂ + (B%2) M₁`.
* `CompressionDelta.blockExcess_bounds` — two-sided linear bounds on the excess.
* `CompressionDelta.tendsto_block_rate` — the coherence-length law:
  the amortized rate is `r + min (2 D) L / (2 L)` bits per message.
-/

namespace CompressionDelta

open Filter Topology

/-- The model-delta cost of the two-state model satisfies the triangle inequality. -/
theorem swapDelta_triangle (D : ℕ) (i k j : Bool) :
    swapDelta D i j ≤ swapDelta D i k + swapDelta D k j := by
  cases i <;> cases k <;> cases j <;> simp [swapDelta]

/-- The infimum over `Bool` written relative to a chosen state. -/
theorem natInf_bool' (f : Bool → ℕ) (d : Bool) : (⨅ b : Bool, f b) = min (f d) (f (!d)) := by
  cases d <;> simp [natInf_bool, min_comm]

@[simp] theorem domCost_self (r : ℕ) (d : Bool) : domCost r d d = r := by simp [domCost]

@[simp] theorem domCost_not (r : ℕ) (d : Bool) : domCost r d (!d) = r + 1 := by
  cases d <;> simp [domCost]

@[simp] theorem swapDelta_self (D : ℕ) (d : Bool) : swapDelta D d d = 0 := by simp [swapDelta]

@[simp] theorem swapDelta_not (D : ℕ) (d : Bool) : swapDelta D d (!d) = D := by
  cases d <;> simp [swapDelta]

/-! ## One block at a time -/

/-- **Block absorption.**  Coding `k` consecutive messages of a single domain `d`, from the
matching decoder state or from the wrong one, reduces exactly to the two continuation
values.  The three competing terms in the second formula are: never switch (`k` extra
bits), switch in and stay (`D`), switch in and back out again (`2 * D`). -/
theorem blockAbsorb (r D : ℕ) :
    ∀ (k : ℕ) (d : Bool) (rest : List (Bool → ℕ)),
      optCost (swapDelta D) d (List.replicate k (domCost r d) ++ rest) =
          k * r + min (optCost (swapDelta D) d rest) (D + optCost (swapDelta D) (!d) rest) ∧
        optCost (swapDelta D) (!d) (List.replicate k (domCost r d) ++ rest) =
          k * r + min (k + optCost (swapDelta D) (!d) rest)
            (min (D + optCost (swapDelta D) d rest)
              (2 * D + optCost (swapDelta D) (!d) rest)) := by
  intro k
  induction k with
  | zero =>
      intro d rest
      have h1 : optCost (swapDelta D) d rest ≤ D + optCost (swapDelta D) (!d) rest := by
        have := optCost_le_switch (swapDelta D) (swapDelta_triangle D) d (!d) rest
        simpa using this
      have h2 : optCost (swapDelta D) (!d) rest ≤ D + optCost (swapDelta D) d rest := by
        have := optCost_le_switch (swapDelta D) (swapDelta_triangle D) (!d) d rest
        have hd : swapDelta D (!d) d = D := by cases d <;> simp [swapDelta]
        rw [hd] at this
        exact this
      constructor <;> simp <;> omega
  | succ k ih =>
      intro d rest
      obtain ⟨ih1, ih2⟩ := ih d rest
      have hmul : (k + 1) * r = k * r + r := by ring
      constructor
      · rw [List.replicate_succ, List.cons_append, optCost_cons, natInf_bool' _ d, ih1, ih2]
        simp only [domCost_self, domCost_not, swapDelta_self, swapDelta_not]
        omega
      · rw [List.replicate_succ, List.cons_append, optCost_cons, natInf_bool' _ (!d)]
        simp only [Bool.not_not]
        rw [ih1, ih2]
        have hdd : swapDelta D (!d) d = D := by cases d <;> simp [swapDelta]
        simp only [domCost_self, domCost_not, swapDelta_self, hdd]
        omega

/-! ## The block-alternating stream -/

/-- The stream made of `B` blocks of `L` messages, the domain alternating between blocks. -/
def blockCosts (r L : ℕ) : Bool → ℕ → List (Bool → ℕ)
  | _, 0 => []
  | d, B + 1 => List.replicate L (domCost r d) ++ blockCosts r L (!d) B

/-- Excess over the rate floor for `B` alternating blocks, starting in the wrong decoder
state.  `min (2 * D) L` is the cost of a pair of blocks (either switch twice or eat `L`
extra bits once), `min D L` the cost of the leftover block. -/
def blockExcess (D L : ℕ) : ℕ → ℕ
  | 0 => 0
  | 1 => min D L
  | B + 2 => blockExcess D L B + min (2 * D) L

/-- Excess over the rate floor for `B` alternating blocks, starting in the *right* decoder
state: one block of head start. -/
def blockGood (D L : ℕ) : ℕ → ℕ
  | 0 => 0
  | B + 1 => blockExcess D L B

/-- One extra block never costs more than one model delta. -/
theorem blockExcess_succ_le (D L : ℕ) :
    ∀ B : ℕ, blockExcess D L (B + 1) ≤ D + blockExcess D L B := by
  intro B
  induction B using Nat.strong_induction_on with
  | _ B ih =>
      match B with
      | 0 => simp only [blockExcess]; omega
      | 1 => simp only [blockExcess]; omega
      | (b + 2) =>
          have h := ih b (by omega)
          simp only [blockExcess]
          omega

/-- Two extra blocks cost at least `min (2 * D) L` more than one. -/
theorem blockExcess_pair_le (D L : ℕ) :
    ∀ B : ℕ, blockExcess D L B + min (2 * D) L ≤ D + blockExcess D L (B + 1) := by
  intro B
  induction B using Nat.strong_induction_on with
  | _ B ih =>
      match B with
      | 0 => simp only [blockExcess]; omega
      | 1 => simp only [blockExcess]; omega
      | (b + 2) =>
          have h := ih b (by omega)
          simp only [blockExcess]
          omega

/-- The min-plus recursion satisfied by the block excess. -/
theorem blockExcess_succ_eq (D L : ℕ) (B : ℕ) :
    blockExcess D L (B + 1) =
      min (L + blockGood D L B)
        (min (D + blockExcess D L B) (2 * D + blockGood D L B)) := by
  match B with
  | 0 => simp only [blockExcess, blockGood]; omega
  | (b + 1) =>
      have h := blockExcess_pair_le D L b
      simp only [blockExcess, blockGood]
      omega

/-- **Exact optimum for a block-alternating stream.**  Both starting states are computed
simultaneously. -/
theorem optCost_blockCosts (r D L : ℕ) :
    ∀ (B : ℕ) (d : Bool),
      optCost (swapDelta D) (!d) (blockCosts r L d B) = B * (L * r) + blockExcess D L B ∧
        optCost (swapDelta D) d (blockCosts r L d B) = B * (L * r) + blockGood D L B := by
  intro B
  induction B with
  | zero => intro d; simp [blockCosts, blockExcess, blockGood]
  | succ B ih =>
      intro d
      obtain ⟨ih1, ih2⟩ := ih (!d)
      simp only [Bool.not_not] at ih1
      -- `ih1` : from state `d` (wrong for the next block) ; `ih2` : from state `!d`
      obtain ⟨habs1, habs2⟩ := blockAbsorb r D L d (blockCosts r L (!d) B)
      have hmul : (B + 1) * (L * r) = L * r + B * (L * r) := by ring
      have hgood : blockGood D L (B + 1) = blockExcess D L B := rfl
      have hstep := blockExcess_succ_eq D L B
      have hle : blockExcess D L B ≤ D + blockGood D L B := by
        match B with
        | 0 => simp [blockExcess, blockGood]
        | (b + 1) =>
            have := blockExcess_succ_le D L b
            simpa [blockGood] using this
      constructor
      · rw [blockCosts, habs2, ih1, ih2]
        omega
      · rw [blockCosts, habs1, ih1, ih2, hgood]
        omega

/-! ## Closed form and the coherence-length law -/

/-- Closed form for the block excess: `⌊B/2⌋ * min (2 D) L + (B % 2) * min D L`. -/
theorem blockExcess_closed_form (D L : ℕ) :
    ∀ B : ℕ, blockExcess D L B = (B / 2) * min (2 * D) L + (B % 2) * min D L := by
  intro B
  induction B using Nat.strong_induction_on with
  | _ B ih =>
      match B with
      | 0 => simp [blockExcess]
      | 1 => simp [blockExcess]
      | (b + 2) =>
          have h := ih b (by omega)
          have hdiv : (b + 2) / 2 = b / 2 + 1 := by omega
          have hmod : (b + 2) % 2 = b % 2 := by omega
          rw [blockExcess, h, hdiv, hmod]
          ring

/-- Two-sided linear bounds on the block excess. -/
theorem blockExcess_bounds (D L : ℕ) :
    ∀ B : ℕ, B * min (2 * D) L ≤ 2 * blockExcess D L B ∧
      2 * blockExcess D L B ≤ B * min (2 * D) L + 2 * min D L := by
  intro B
  induction B using Nat.strong_induction_on with
  | _ B ih =>
      match B with
      | 0 => simp [blockExcess]
      | 1 => simp only [blockExcess]; omega
      | (b + 2) =>
          obtain ⟨h1, h2⟩ := ih b (by omega)
          have hmul : (b + 2) * min (2 * D) L = b * min (2 * D) L + 2 * min (2 * D) L := by
            ring
          simp only [blockExcess]
          omega

/-- **The coherence-length law.**  On a stream of `B` blocks of `L` messages with the
domain alternating between blocks, the amortized number of transmitted bits per message
converges to `r + min (2 * D) L / (2 * L)`.  The model delta amortizes against the
coherence length `L`: it is free only in the limit `L → ∞`, and costs half a bit per
message at `L = 1`. -/
theorem tendsto_block_rate (r D L : ℕ) (hL : 1 ≤ L) (d : Bool) :
    Tendsto (fun B : ℕ =>
        (optCost (swapDelta D) (!d) (blockCosts r L d B) : ℝ) / (B * L)) atTop
      (𝓝 ((r : ℝ) + (min (2 * D) L : ℕ) / (2 * L))) := by
  set c : ℝ := (r : ℝ) + ((min (2 * D) L : ℕ) : ℝ) / (2 * L) with hc
  have hL0 : (0 : ℝ) < L := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hL
  have hzero : Tendsto (fun B : ℕ => (((min D L : ℕ) : ℝ) / L) / B) atTop (𝓝 0) :=
    tendsto_const_div_atTop_nhds_zero_nat _
  have hupper : Tendsto (fun B : ℕ => c + (((min D L : ℕ) : ℝ) / L) / B) atTop (𝓝 c) := by
    simpa using (tendsto_const_nhds (x := c) (f := (atTop : Filter ℕ))).add hzero
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hupper ?_ ?_
  · filter_upwards [eventually_ge_atTop 1] with B hB
    have hB0 : (0 : ℝ) < B := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hB
    have hval := (optCost_blockCosts r D L B d).1
    obtain ⟨hlow, -⟩ := blockExcess_bounds D L B
    have hlowR : (B : ℝ) * ((min (2 * D) L : ℕ) : ℝ) ≤ 2 * ((blockExcess D L B : ℕ) : ℝ) := by
      exact_mod_cast hlow
    have hvalR : ((optCost (swapDelta D) (!d) (blockCosts r L d B) : ℕ) : ℝ) =
        (B : ℝ) * (L * r) + ((blockExcess D L B : ℕ) : ℝ) := by
      rw [hval]; push_cast; ring
    rw [le_div_iff₀ (by positivity), hvalR, hc]
    have hexp : ((r : ℝ) + ((min (2 * D) L : ℕ) : ℝ) / (2 * L)) * ((B : ℝ) * L) =
        (B : ℝ) * (L * r) + (B : ℝ) * ((min (2 * D) L : ℕ) : ℝ) / 2 := by
      field_simp
    rw [hexp]
    linarith
  · filter_upwards [eventually_ge_atTop 1] with B hB
    have hB0 : (0 : ℝ) < B := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hB
    have hval := (optCost_blockCosts r D L B d).1
    obtain ⟨-, hhigh⟩ := blockExcess_bounds D L B
    have hhighR : 2 * ((blockExcess D L B : ℕ) : ℝ) ≤
        (B : ℝ) * ((min (2 * D) L : ℕ) : ℝ) + 2 * ((min D L : ℕ) : ℝ) := by
      exact_mod_cast hhigh
    have hvalR : ((optCost (swapDelta D) (!d) (blockCosts r L d B) : ℕ) : ℝ) =
        (B : ℝ) * (L * r) + ((blockExcess D L B : ℕ) : ℝ) := by
      rw [hval]; push_cast; ring
    rw [div_le_iff₀ (by positivity), hvalR, hc]
    have hexp : ((r : ℝ) + ((min (2 * D) L : ℕ) : ℝ) / (2 * L) +
        (((min D L : ℕ) : ℝ) / L) / B) * ((B : ℝ) * L) =
        (B : ℝ) * (L * r) + (B : ℝ) * ((min (2 * D) L : ℕ) : ℝ) / 2 +
          ((min D L : ℕ) : ℝ) := by
      field_simp
    rw [hexp]
    linarith

end CompressionDelta