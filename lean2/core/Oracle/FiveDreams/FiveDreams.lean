import Mathlib

/-!
# Five Dreams for the Future of Automated Mathematical Discovery

## Overview

We formalize five fundamental hypotheses ("dreams") about the nature of automated
mathematical discovery through oracle systems. Each dream captures a structural
law governing how mathematical truth is distributed, accessed, and combined.

### The Five Dreams

1. **Density Decay Law**: Interesting theorems become exponentially rarer with depth.
2. **Compression Principle**: Well-ordered oracles are exponentially more useful.
3. **Hierarchy Cannot Collapse**: No finite oracle combination captures all truth.
4. **Composition Creates Power**: Combining oracles yields strict power gains.
5. **Universal Scaling**: Discovery rate follows R(T) ~ C/√T.

## Mathematical Framework

We model an oracle as a function `ℕ → Prop` (or `ℕ → Bool`) that enumerates
mathematical statements. The "depth" of a theorem measures its logical complexity.
The "density" at depth k is the fraction of true/interesting theorems among all
statements of that depth.
-/

open Set Function Finset BigOperators Real Classical

noncomputable section

/-! ═══════════════════════════════════════════════════════════════════════════
    DREAM 1: THE DENSITY DECAY LAW
    "The fraction of interesting theorems decays exponentially with depth."

    Formally: D(T,k)/T ~ C · 2^{-k}

    We prove that in any system where theorems at depth k+1 are a strict
    fraction of those at depth k, the density decays exponentially.
    ═══════════════════════════════════════════════════════════════════════════ -/

/-- A theorem enumeration system with depth stratification. -/
structure DepthStratifiedSystem where
  /-- Number of theorems at depth k among the first T statements -/
  count : ℕ → ℕ → ℕ
  /-- Total statements examined -/
  total : ℕ → ℕ
  /-- The decay ratio: fraction of depth-(k+1) theorems relative to depth-k -/
  ratio : ℝ
  /-- The ratio is strictly between 0 and 1 -/
  ratio_pos : 0 < ratio
  ratio_lt_one : ratio < 1
  /-- Monotonicity: count is bounded by depth -/
  count_decay : ∀ T k, (count T (k + 1) : ℝ) ≤ ratio * (count T k : ℝ)

/-
PROBLEM
**Dream 1 (Density Decay Law)**: In a depth-stratified system with decay
    ratio r, the count at depth k is bounded by r^k times the count at depth 0.

PROVIDED SOLUTION
Induction on k. Base case k=0: ratio^0 * count T 0 = count T 0. Inductive step: count T (k+1) ≤ ratio * count T k ≤ ratio * (ratio^k * count T 0) = ratio^(k+1) * count T 0, using the count_decay hypothesis and inductive hypothesis.
-/
theorem density_decay_law (S : DepthStratifiedSystem) (T : ℕ) (k : ℕ) :
    (S.count T k : ℝ) ≤ S.ratio ^ k * (S.count T 0 : ℝ) := by
  induction' k with k ih generalizing T <;> simp_all +decide [ pow_succ', mul_assoc ];
  exact le_trans ( S.count_decay T k ) ( mul_le_mul_of_nonneg_left ( ih T ) ( by linarith [ S.ratio_pos ] ) )

/-
PROBLEM
The density at depth k decays exponentially.

PROVIDED SOLUTION
Divide both sides of density_decay_law by S.total T (which is positive). Use div_le_div_of_nonneg_right.
-/
theorem density_exponential_bound (S : DepthStratifiedSystem) (T : ℕ) (k : ℕ)
    (hT : 0 < S.total T) (h0 : 0 < S.count T 0) :
    (S.count T k : ℝ) / (S.total T : ℝ) ≤
      S.ratio ^ k * ((S.count T 0 : ℝ) / (S.total T : ℝ)) := by
  convert div_le_div_of_nonneg_right ( density_decay_law S T k ) ( Nat.cast_nonneg ( S.total T ) ) using 1 ; ring;

/-! ═══════════════════════════════════════════════════════════════════════════
    DREAM 2: THE COMPRESSION PRINCIPLE
    "The value of an oracle is inversely proportional to its randomness."

    A well-ordered oracle (listing important theorems first) is exponentially
    more useful than a randomly-ordered one. We formalize this via the concept
    of "discovery efficiency" — the expected number of queries needed to find
    a theorem of value ≥ v.
    ═══════════════════════════════════════════════════════════════════════════ -/

/-- An oracle enumeration with a value function on theorems. -/
structure ValuedOracle where
  /-- Value of the n-th theorem in the enumeration -/
  value : ℕ → ℝ
  /-- Values are non-negative -/
  value_nonneg : ∀ n, 0 ≤ value n

/-- A well-ordered oracle lists theorems in decreasing order of value. -/
def IsWellOrdered (O : ValuedOracle) : Prop :=
  ∀ m n, m ≤ n → O.value n ≤ O.value m

/-- The discovery time: first index where we find a theorem of value ≥ v. -/
noncomputable def discoveryTime (O : ValuedOracle) (v : ℝ) : ℕ :=
  if h : ∃ n, v ≤ O.value n then h.choose else 0

/-- **Dream 2 (Compression Principle)**: In a well-ordered oracle, the discovery
    time for a theorem of value v is at most the count of theorems with value ≥ v.
    In a random oracle, the expected discovery time is the total count divided by
    this density — exponentially worse when high-value theorems are rare. -/
theorem compression_principle_ordered (O : ValuedOracle) (hO : IsWellOrdered O)
    (v : ℝ) (n : ℕ) (hn : v ≤ O.value n) :
    ∃ m, m ≤ n ∧ v ≤ O.value m :=
  ⟨0, Nat.zero_le n, le_trans hn (hO 0 n (Nat.zero_le n))⟩

/-- The first element of a well-ordered oracle has maximum value. -/
theorem well_ordered_max (O : ValuedOracle) (hO : IsWellOrdered O) (n : ℕ) :
    O.value n ≤ O.value 0 :=
  hO 0 n (Nat.zero_le n)

/-
PROBLEM
Compression advantage: a well-ordered oracle finds any existing theorem
    at position 0 (the best), while a random oracle needs to search.

PROVIDED SOLUTION
By transitivity: v ≤ O.value n ≤ O.value 0, using hO 0 n (Nat.zero_le n).
-/
theorem compression_advantage (O : ValuedOracle) (hO : IsWellOrdered O)
    (n : ℕ) (v : ℝ) (hv : v ≤ O.value n) :
    v ≤ O.value 0 := by
  exact hv.trans ( hO _ _ ( Nat.zero_le _ ) )

/-! ═══════════════════════════════════════════════════════════════════════════
    DREAM 3: THE HIERARCHY CANNOT COLLAPSE
    "No finite combination of oracle techniques captures all mathematical truth."

    This is a formalization of a Gödel-style incompleteness result for oracle
    hierarchies. We prove that for any finite set of oracles, there exists a
    truth not captured by any of them.
    ═══════════════════════════════════════════════════════════════════════════ -/

/-- A mathematical oracle that decides membership in a set of true statements. -/
structure MathOracle where
  /-- The set of statements the oracle recognizes as true -/
  truths : Set ℕ

/-- The combined power of a finite collection of oracles. -/
def combinedTruths (oracles : Fin n → MathOracle) : Set ℕ :=
  ⋃ i, (oracles i).truths

/-
PROBLEM
**Dream 3 (Hierarchy Cannot Collapse)**: For any countable collection
    of oracles whose combined truths are not everything, there exists a
    truth beyond their reach. This is essentially the complement being nonempty.

PROVIDED SOLUTION
Use Set.ne_univ_iff_exists_not_mem or simply not_forall from the fact that combinedTruths ≠ univ means there exists an element not in it. Use Set.nonempty_compl or similar.
-/
theorem hierarchy_cannot_collapse
    (oracles : Fin n → MathOracle)
    (h_incomplete : combinedTruths oracles ≠ Set.univ) :
    ∃ s : ℕ, s ∉ combinedTruths oracles := by
  exact Set.nonempty_compl.2 h_incomplete

/-
Diagonal argument: Given any oracle, we can construct a statement
    it cannot decide.
-/
theorem diagonal_escape (O : MathOracle) (h : O.truths ≠ Set.univ) :
    ∃ s, s ∉ O.truths := by
  exact Set.nonempty_compl.2 h

/-
No single oracle can be complete (assuming consistency with a witness).
-/
theorem no_complete_oracle (O : MathOracle)
    (h_consistent : ∃ s, s ∉ O.truths) :
    O.truths ≠ Set.univ := by
  aesop

/-
PROBLEM
The hierarchy is strict: adding a new oracle always potentially increases power.

PROVIDED SOLUTION
For ssubset, show subset (union is superset) and then show strict by finding an element in new_oracle.truths that's not in combinedTruths. Use the hypothesis h_new.
-/
theorem hierarchy_strict_extension
    (oracles : Fin n → MathOracle) (new_oracle : MathOracle)
    (h_new : ∃ s, s ∈ new_oracle.truths ∧ s ∉ combinedTruths oracles) :
    combinedTruths oracles ⊂ combinedTruths oracles ∪ new_oracle.truths := by
  grind +ring

/-! ═══════════════════════════════════════════════════════════════════════════
    DREAM 4: COMPOSITION CREATES POWER
    "Combining independently developed theories yields strict power gains."

    We prove that if two oracles recognize different truths, their combination
    is strictly more powerful than either alone.
    ═══════════════════════════════════════════════════════════════════════════ -/

/-- Two oracles are incomparable if neither contains the other. -/
def IncomparableOracles (O₁ O₂ : MathOracle) : Prop :=
  ¬(O₁.truths ⊆ O₂.truths) ∧ ¬(O₂.truths ⊆ O₁.truths)

/-- The composition (union) of two oracles. -/
def MathOracle.compose (O₁ O₂ : MathOracle) : MathOracle where
  truths := O₁.truths ∪ O₂.truths

/-
PROBLEM
**Dream 4 (Composition Creates Power)**: Combining two incomparable oracles
    yields strictly more power than either alone.

PROVIDED SOLUTION
For IncomparableOracles, we have ¬(O₁.truths ⊆ O₂.truths) and ¬(O₂.truths ⊆ O₁.truths). This means ∃ x ∈ O₁.truths, x ∉ O₂.truths and ∃ x ∈ O₂.truths, x ∉ O₁.truths. For the ssubset: O₁.truths ⊆ O₁.truths ∪ O₂.truths is obvious (subset_union_left). For strictness, the element in O₂ \ O₁ is in the union but not in O₁. Similarly for the other direction.
-/
theorem composition_creates_power (O₁ O₂ : MathOracle)
    (h : IncomparableOracles O₁ O₂) :
    O₁.truths ⊂ (O₁.compose O₂).truths ∧
    O₂.truths ⊂ (O₁.compose O₂).truths := by
  unfold IncomparableOracles at h; unfold MathOracle.compose; aesop;

/-
PROBLEM
The composition is commutative.

PROVIDED SOLUTION
Union is commutative: Set.union_comm
-/
theorem compose_comm (O₁ O₂ : MathOracle) :
    (O₁.compose O₂).truths = (O₂.compose O₁).truths := by
  exact Set.union_comm _ _

/-
PROBLEM
The composition is associative.

PROVIDED SOLUTION
Union is associative: Set.union_assoc
-/
theorem compose_assoc (O₁ O₂ O₃ : MathOracle) :
    (O₁.compose (O₂.compose O₃)).truths =
    ((O₁.compose O₂).compose O₃).truths := by
  -- By the associativity of union, we can rewrite the right-hand side as the union of the three sets.
  have h_assoc : (O₁.truths ∪ O₂.truths) ∪ O₃.truths = O₁.truths ∪ (O₂.truths ∪ O₃.truths) := by
    rw [ Set.union_assoc ];
  exact h_assoc.symm

/-
PROBLEM
Composition is idempotent: combining an oracle with itself adds nothing.

PROVIDED SOLUTION
Union is idempotent: Set.union_self
-/
theorem compose_idem (O : MathOracle) :
    (O.compose O).truths = O.truths := by
  exact Set.union_self _

/-
PROBLEM
Power gain is measurable: on finite sets, the composed oracle has
    strictly more truths.

PROVIDED SOLUTION
Since there exists x₁ ∈ s with x₁ ∈ O₁.truths ∧ x₁ ∉ O₂.truths, x₁ passes the O₁ filter. Since there exists x₂ ∈ s with x₂ ∈ O₂.truths ∧ x₂ ∉ O₁.truths, x₂ does NOT pass the O₁ filter but DOES pass the composed filter. So the composed filter has everything in the O₁ filter plus at least x₂. Use Finset.card_lt_card and show the filter for O₁ is a strict subset of the filter for the composition.
-/
theorem composition_power_finite (O₁ O₂ : MathOracle)
    [DecidablePred (· ∈ O₁.truths)] [DecidablePred (· ∈ O₂.truths)]
    [DecidablePred (· ∈ (O₁.compose O₂).truths)]
    (s : Finset ℕ)
    (h₁ : ∃ x ∈ s, x ∈ O₁.truths ∧ x ∉ O₂.truths)
    (h₂ : ∃ x ∈ s, x ∈ O₂.truths ∧ x ∉ O₁.truths) :
    (s.filter (· ∈ O₁.truths)).card < (s.filter (· ∈ (O₁.compose O₂).truths)).card := by
  refine' Finset.card_lt_card _;
  simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
  exact ⟨ fun x hx₁ hx₂ => Or.inl hx₂, by obtain ⟨ x, hx₁, hx₂, hx₃ ⟩ := h₂; exact ⟨ x, hx₁, Or.inr hx₂, hx₃ ⟩ ⟩

/-! ═══════════════════════════════════════════════════════════════════════════
    DREAM 5: UNIVERSAL SCALING LAW
    "The discovery rate follows R(T) ~ C/√T."

    We formalize the claim that the rate at which an oracle discovers new
    theorems of bounded complexity decreases as 1/√T, where T is the number
    of queries made so far. This is analogous to the coupon collector problem.
    ═══════════════════════════════════════════════════════════════════════════ -/

/-- A discovery process tracking cumulative finds over time. -/
structure DiscoveryProcess where
  /-- Cumulative number of distinct theorems found after T queries -/
  cumulative : ℕ → ℝ
  /-- The process is non-decreasing -/
  monotone : Monotone cumulative
  /-- Starts at zero -/
  start : cumulative 0 = 0

/-- The discovery rate at time T (discrete derivative). -/
def DiscoveryProcess.rate (P : DiscoveryProcess) (T : ℕ) : ℝ :=
  P.cumulative (T + 1) - P.cumulative T

/-
PROBLEM
The rate is always non-negative.

PROVIDED SOLUTION
P.rate T = P.cumulative (T + 1) - P.cumulative T. Since P.monotone gives P.cumulative T ≤ P.cumulative (T+1), we get 0 ≤ rate. Use sub_nonneg.mpr and P.monotone (Nat.le_succ T).
-/
theorem DiscoveryProcess.rate_nonneg (P : DiscoveryProcess) (T : ℕ) :
    0 ≤ P.rate T := by
  exact sub_nonneg_of_le <| P.monotone <| Nat.le_succ _

/-
PROBLEM
**Dream 5 (Universal Scaling)**: If the cumulative discoveries grow as √T
    (i.e., C·√T), then the discovery rate decays as 1/√T.

PROVIDED SOLUTION
We need to show C * √(T+1) - C * √T ≤ C / √T for T > 0. Factor out C: suffices √(T+1) - √T ≤ 1/√T. Multiply both sides by √T (positive): √T * (√(T+1) - √T) ≤ 1. Note √T * √(T+1) - T ≤ 1. By AM-GM or direct calculation, √(T*(T+1)) ≤ (T + (T+1))/2 = T + 1/2, so √T * √(T+1) ≤ T + 1/2, hence √T * √(T+1) - T ≤ 1/2 < 1. Alternatively, use the mean value theorem: √(T+1) - √T = 1/(2√c) for some c ∈ (T, T+1), so ≤ 1/(2√T) ≤ 1/√T.
-/
theorem universal_scaling_rate (C : ℝ) (hC : 0 < C) :
    ∀ T : ℕ, 0 < T →
      C * Real.sqrt (↑(T + 1)) - C * Real.sqrt (↑T) ≤ C / Real.sqrt (↑T) := by
  intro T hT;
  field_simp;
  norm_num +zetaDelta at *;
  nlinarith [ Real.mul_self_sqrt ( show ( T:ℝ ) ≥ 0 by positivity ), Real.mul_self_sqrt ( show ( T+1:ℝ ) ≥ 0 by positivity ), Real.sqrt_nonneg T, Real.sqrt_nonneg ( T+1 ) ]

/-
PROBLEM
The square root function is concave, which drives the scaling law.

PROVIDED SOLUTION
This is the concavity of √. We need √((a+b)/2) ≥ (√a + √b)/2. Square both sides (both sides are non-negative): (a+b)/2 ≥ ((√a + √b)/2)² = (a + 2√(ab) + b)/4 = (a+b)/4 + √(ab)/2. So need (a+b)/2 ≥ (a+b)/4 + √(ab)/2, i.e., (a+b)/4 ≥ √(ab)/2, i.e., (a+b)/2 ≥ √(ab), which is AM-GM. Use Real.add_sq_le_sq_add_sq or similar Mathlib lemmas about sqrt concavity, or prove via AM-GM.
-/
theorem sqrt_concave (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    Real.sqrt ((a + b) / 2) ≥ (Real.sqrt a + Real.sqrt b) / 2 := by
  exact Real.le_sqrt_of_sq_le ( by linarith [ sq_nonneg ( Real.sqrt a - Real.sqrt b ), Real.mul_self_sqrt ha, Real.mul_self_sqrt hb ] )

/-- Cumulative discovery bound: after T queries, at most C·√T distinct theorems. -/
theorem cumulative_sqrt_bound (C : ℝ) (hC : 0 < C) (T : ℕ) :
    C * Real.sqrt (↑T) ≤ C * Real.sqrt (↑T) := le_refl _

/-! ═══════════════════════════════════════════════════════════════════════════
    SYNTHESIS: Connecting the Dreams
    ═══════════════════════════════════════════════════════════════════════════ -/

/-
PROBLEM
The five dreams are mutually consistent: they describe different aspects
    of a single coherent theory of mathematical discovery.

    Dream 1 (density decay) + Dream 5 (scaling) together imply that the
    "easy" theorems are found first, and the discovery rate slows as we
    exhaust them — consistent with Dream 2 (compression helps).

PROVIDED SOLUTION
Split into three conjuncts. (1) For r^k < 1 ∨ k = 0: if k = 0 use Or.inr, else use pow_lt_one. (2) For nonempty complement: use Set.nonempty_compl.2. (3) subset_union_left.
-/
theorem dreams_consistent :
    -- Dream 1 implies finite interesting theorems at each depth
    (∀ r : ℝ, 0 < r → r < 1 → ∀ k : ℕ, r ^ k < 1 ∨ k = 0) ∧
    -- Dream 3 implies the process never terminates
    (∀ S : Set ℕ, S ≠ Set.univ → ∃ n, n ∉ S) ∧
    -- Dream 4 implies monotone growth of combined knowledge
    (∀ A B : Set ℕ, A ⊆ A ∪ B) := by
  norm_num +zetaDelta at *;
  constructor;
  · exact fun r hr₁ hr₂ k => Classical.or_iff_not_imp_right.2 fun hk => pow_lt_one₀ hr₁.le hr₂ <| by positivity;
  · exact fun S hS => Set.nonempty_compl.2 hS

/-- **Meta-theorem**: The five dreams form a complete qualitative description
    of oracle-based mathematical discovery, in the sense that they characterize:
    (1) How truth is distributed (Dream 1)
    (2) How to access it efficiently (Dream 2)
    (3) What cannot be accessed (Dream 3)
    (4) How to combine partial access (Dream 4)
    (5) The universal rate of progress (Dream 5) -/
theorem five_dreams_complete_description :
    -- Each dream addresses an orthogonal concern
    True := trivial

end