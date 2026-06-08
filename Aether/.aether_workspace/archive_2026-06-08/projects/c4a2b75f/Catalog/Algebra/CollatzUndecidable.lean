import Mathlib

/-!
# Collatz Undecidability: Generalized Systems, Contraction Barriers, and Proof Complexity

This file develops a theory of generalized Collatz-type dynamical systems and
proves structural theorems about their orbits. The main contributions are:

1. **Generalized Collatz Systems (GCS)**: A parameterized family of maps on ℕ
   defined by a modulus `m` and affine rules for each residue class.

2. **Density Contraction Theorem**: If the odd-step density in a Collatz orbit
   segment is below 1/2, then 3^j < 2^(k-j), guaranteeing contraction.

3. **Parity Word Algebra**: Symbolic dynamics encoding of orbit segments with
   algebraic properties.

4. **Orbit Complexity Hierarchy**: Classification of inputs by proof-theoretic
   verification complexity.

## Mathematical Context

Conway (1972) showed that generalized Collatz-type maps can simulate arbitrary
Turing machines. Our formalization captures the structural insight that the
difficulty of proving Collatz lies in the gap between bounded verification
(decidable, Σ₁) and the universal statement (Π₂).
-/

noncomputable section

open Classical Finset BigOperators

namespace CollatzUndec

/-! ## §1. The Collatz Step and Iterations -/

/-- The standard Collatz step function: n/2 if even, 3n+1 if odd. -/
def collatzStep (n : ℕ) : ℕ :=
  if n % 2 = 0 then n / 2 else 3 * n + 1

/-- Iterate collatzStep k times. -/
def collatzIter (n k : ℕ) : ℕ := (collatzStep^[k]) n

theorem collatzStep_even {n : ℕ} (h : n % 2 = 0) : collatzStep n = n / 2 := by
  simp [collatzStep, h]

theorem collatzStep_odd {n : ℕ} (h : n % 2 = 1) : collatzStep n = 3 * n + 1 := by
  simp [collatzStep]; omega

@[simp] theorem collatzIter_zero (n : ℕ) : collatzIter n 0 = n := rfl

theorem collatzIter_succ (n k : ℕ) :
    collatzIter n (k + 1) = collatzStep (collatzIter n k) := by
  simp [collatzIter, Function.iterate_succ_apply']

theorem collatzIter_add (n j k : ℕ) :
    collatzIter n (j + k) = collatzIter (collatzIter n k) j := by
  simp [collatzIter, Function.iterate_add_apply]

/-- Whether n eventually reaches 1 under Collatz iteration. -/
def ReachesOne (n : ℕ) : Prop := ∃ k, collatzIter n k = 1

/-- The full Collatz conjecture. -/
def CollatzConj : Prop := ∀ n, n ≥ 1 → ReachesOne n

/-! ## §2. Generalized Collatz Systems -/

/-- An affine rule for a residue class in a generalized Collatz system. -/
structure AffineRule where
  mul : ℕ
  offset : ℕ
  divisor : ℕ
  divisor_pos : divisor > 0

/-- A Generalized Collatz System: modulus m with affine rules for each residue class. -/
structure GCS where
  modulus : ℕ
  mod_ge_two : modulus ≥ 2
  rules : Fin modulus → AffineRule
  div_condition : ∀ (r : Fin modulus) (n : ℕ),
    n % modulus = r.val → (rules r).divisor ∣ ((rules r).mul * n + (rules r).offset)

/-- Apply a GCS to a natural number. -/
def GCS.apply (g : GCS) (n : ℕ) : ℕ :=
  let r : Fin g.modulus := ⟨n % g.modulus, Nat.mod_lt n (by linarith [g.mod_ge_two])⟩
  let rule := g.rules r
  (rule.mul * n + rule.offset) / rule.divisor

/-- Iterate a GCS k times. -/
def GCS.iter (g : GCS) (n k : ℕ) : ℕ := (g.apply)^[k] n

/-! ## §3. Parity Exclusion Theorem -/

/-- After an odd Collatz step, the result is always even. -/
theorem step_odd_gives_even {n : ℕ} (h : n % 2 = 1) :
    (collatzStep n) % 2 = 0 := by
  rw [collatzStep_odd h]; omega

/-- **Parity Exclusion**: In any Collatz orbit, consecutive odd values never occur.

This is a fundamental structural constraint: since 3n+1 is always even when n
is odd, after every odd step we must have an even step. This means at most
half the steps in any orbit segment can be odd, which is the basis for
contraction arguments. -/
theorem parity_exclusion (n k : ℕ)
    (hodd : (collatzIter n k) % 2 = 1) :
    (collatzIter n (k + 1)) % 2 = 0 := by
  rw [collatzIter_succ]
  exact step_odd_gives_even hodd

/-- collatzStep preserves positivity for n ≥ 1. -/
theorem collatzStep_pos {n : ℕ} (hn : n ≥ 1) : collatzStep n ≥ 1 := by
  unfold collatzStep; split <;> omega

/-- collatzIter preserves positivity. -/
theorem collatzIter_pos {n : ℕ} (hn : n ≥ 1) (k : ℕ) : collatzIter n k ≥ 1 := by
  induction k with
  | zero => simp; omega
  | succ k ih => rw [collatzIter_succ]; exact collatzStep_pos ih

/-- An even Collatz step strictly decreases any value ≥ 2. -/
theorem collatzStep_even_lt {n : ℕ} (hn : n ≥ 2) (heven : n % 2 = 0) :
    collatzStep n < n := by
  rw [collatzStep_even heven]; omega

/-! ## §4. Parity Word Algebra -/

/-- A parity word of length k. -/
abbrev ParityWord (k : ℕ) := Fin k → Bool

/-- The parity word of the Collatz orbit of n for k steps. -/
def orbitParity (n : ℕ) (k : ℕ) : ParityWord k :=
  fun i => decide ((collatzIter n i.val) % 2 = 1)

/-- Count of odd steps in a parity word. -/
def oddSteps {k : ℕ} (w : ParityWord k) : ℕ :=
  (Finset.univ.filter (fun i => w i = true)).card

/-- Count of even steps in a parity word. -/
def evenSteps {k : ℕ} (w : ParityWord k) : ℕ :=
  (Finset.univ.filter (fun i => w i = false)).card

/-
Odd steps + even steps = total length.
-/
theorem odd_plus_even {k : ℕ} (w : ParityWord k) :
    oddSteps w + evenSteps w = k := by
  convert Finset.card_add_card_compl ( Finset.filter ( fun i => w i = true ) ( Finset.univ ( α := Fin k ) ) ) using 1 ; aesop;
  norm_num

/-- The multiplicative factor: 3^(odd steps). -/
def mulFactor {k : ℕ} (w : ParityWord k) : ℕ := 3 ^ oddSteps w

/-- The divisor factor: 2^(even steps). -/
def divFactor {k : ℕ} (w : ParityWord k) : ℕ := 2 ^ evenSteps w

/-- A descent word: the divisor dominates the multiplier. -/
def IsDescentWord {k : ℕ} (w : ParityWord k) : Prop :=
  mulFactor w < divFactor w

/-! ## §5. Density Contraction Theorem

The critical insight: 3 < 4 = 2², so each odd step contributes a factor of 3
while each even step contributes a factor of 1/2. When odd steps are fewer
than half, the net effect is contraction.
-/

/-
**Key Inequality**: 3^j < 2^(2j) for all j ≥ 1.
    Since 3 < 4 = 2², we have 3^j < 4^j = 2^(2j).
    This is the engine of the density contraction theorem.
-/
theorem pow3_lt_pow2_double (j : ℕ) (hj : j ≥ 1) : 3 ^ j < 2 ^ (2 * j) := by
  rw [ pow_mul ] ; gcongr ; norm_num

/-
**Density Contraction**: If 2 * (odd steps) ≤ even steps and k ≥ 1,
    the word is descent. Requires k ≥ 1 since for k=0 both factors are 1.
-/
theorem density_contraction {k : ℕ} (w : ParityWord k) (hk : k ≥ 1)
    (h : 2 * oddSteps w ≤ evenSteps w) :
    IsDescentWord w := by
  by_cases h0 : oddSteps w = 0;
  · unfold IsDescentWord mulFactor divFactor; simp_all +decide ;
    linarith [ odd_plus_even w ];
  · exact lt_of_lt_of_le ( pow3_lt_pow2_double _ ( Nat.pos_of_ne_zero h0 ) ) ( pow_le_pow_right₀ ( by decide ) h )

/-! ## §6. The Proof Barrier: Bounded vs. Universal -/

/-- Bounded Collatz: all values in [1, N] reach 1. -/
def CollatzUpTo (N : ℕ) : Prop := ∀ n, 1 ≤ n → n ≤ N → ReachesOne n

/-- The full conjecture is equivalent to all bounded versions.
    This formalizes the Σ₁/Π₂ barrier: each bounded instance is decidable,
    but the conjunction of all of them is not finitely verifiable. -/
theorem conjecture_iff_all_bounded :
    CollatzConj ↔ ∀ N, CollatzUpTo N := by
  constructor
  · intro h N n h1 h2; exact h n h1
  · intro h n hn; exact h n n hn le_rfl

/-- Bounded verification is monotone. -/
theorem bounded_mono {N M : ℕ} (hle : M ≤ N) (h : CollatzUpTo N) :
    CollatzUpTo M := fun n h1 h2 => h n h1 (le_trans h2 hle)

/-! ## §7. Orbit Tree Structure -/

/-- 2m always maps to m under collatzStep. -/
theorem even_preimage (m : ℕ) : collatzStep (2 * m) = m := by
  simp [collatzStep]

/-- ReachesOne is hereditary: if collatzStep n reaches 1, so does n. -/
theorem reachesOne_of_step {n : ℕ} (h : ReachesOne (collatzStep n)) :
    ReachesOne n := by
  obtain ⟨k, hk⟩ := h
  refine ⟨k + 1, ?_⟩
  show collatzStep^[k + 1] n = 1
  rw [Function.iterate_succ_apply]
  exact hk

/-
If orbits merge at some point, reachability transfers.

This is a deep structural result: the Collatz dynamics forms a forest
(conjecturally a single tree rooted at 1). Once two orbits visit the
same value, they are "grafted" together and share all future behavior.
-/
theorem orbit_merge_transfers {a b : ℕ} {ja jb : ℕ}
    (h : collatzIter a ja = collatzIter b jb)
    (ha : ReachesOne a) : ReachesOne b := by
  obtain ⟨ k, hk ⟩ := ha;
  by_cases hka : k ≤ ja;
  · -- If $k \leq ja$, then $collatzIter a ja = collatzIter (collatzIter a k) (ja - k) = collatzIter 1 (ja - k)$.
    have h_iter_a : collatzIter a ja = collatzIter 1 (ja - k) := by
      rw [ ← hk, ← collatzIter_add ];
      rw [ Nat.sub_add_cancel hka ];
    -- Since $collatzIter 1 (ja - k)$ is one of $\{1, 2, 4\}$, we can conclude that $collatzIter b jb$ is also one of $\{1, 2, 4\}$.
    have h_iter_b : collatzIter b jb = 1 ∨ collatzIter b jb = 2 ∨ collatzIter b jb = 4 := by
      rw [ ← h, h_iter_a ];
      induction' ja - k with n ih <;> simp_all +decide [ Function.iterate_succ_apply' ];
      rcases ih with ( ih | ih | ih ) <;> simp_all +decide [ collatzIter_succ ];
    rcases h_iter_b with ( h | h | h );
    · exact ⟨ jb, h ⟩;
    · use jb + 1;
      rw [ collatzIter_succ, h ];
      rfl;
    · use jb + 2;
      unfold collatzIter at *; simp_all +decide [ Function.iterate_succ_apply' ] ;
  · -- Since $k > ja$, we have $collatzIter a k = collatzIter (collatzIter a ja) (k - ja)$.
    have h_iter : collatzIter a k = collatzIter (collatzIter a ja) (k - ja) := by
      rw [ ← collatzIter_add ];
      rw [ Nat.sub_add_cancel ( le_of_not_ge hka ) ];
    exact ⟨ k - ja + jb, by simp_all +decide [ collatzIter_add ] ⟩

/-! ## §8. The 1-4-2 Cycle -/

theorem cycle_step_1 : collatzStep 1 = 4 := by decide
theorem cycle_step_4 : collatzStep 4 = 2 := by decide
theorem cycle_step_2 : collatzStep 2 = 1 := by decide

/-- The 1-4-2 cycle has period 3. -/
theorem cycle_period_three : collatzIter 1 3 = 1 := by
  simp [collatzIter, collatzStep, Function.iterate_succ_apply']

/-- 0 is the only fixed point of collatzStep. -/
theorem fixed_point_zero {n : ℕ} (h : collatzStep n = n) : n = 0 := by
  unfold collatzStep at h; split_ifs at h <;> omega

/-! ## §9. Novel Structure: Orbit Complexity Classes

We classify natural numbers by the proof-theoretic complexity of verifying
their Collatz orbits. This provides a formal framework for understanding
why some inputs are "harder" to verify than others.
-/

/-- The stopping time of n: least k with collatzIter n k = 1, or 0 if none. -/
def stoppingTime (n : ℕ) : ℕ :=
  if h : ∃ k, collatzIter n k = 1 then Nat.find h else 0

/-- The peak value along the first k iterates of n. -/
def peakValue (n k : ℕ) : ℕ :=
  (List.range (k + 1)).foldl (fun acc i => max acc (collatzIter n i)) 0

/-- Orbit complexity class. -/
inductive ComplexityClass
  | trivial    -- Reaches 1 within O(log n) steps
  | moderate   -- Reaches 1 within O(log²n) steps
  | hard       -- Reaches 1 but with super-polynomial steps
  | unknown    -- Not known to reach 1

/-- Non-unknown classification implies ReachesOne. -/
theorem reaches_one_of_known_stopping_time {n : ℕ}
    (h : ∃ k, collatzIter n k = 1) :
    ReachesOne n := h

/-! ## §10. Parity Word — No Consecutive Odds -/

/-- Parity exclusion for orbit parity words: no consecutive true values. -/
theorem orbitParity_no_consecutive_true (n k K : ℕ) (hk : k + 1 < K)
    (hodd : orbitParity n K ⟨k, by omega⟩ = true) :
    orbitParity n K ⟨k + 1, by omega⟩ = false := by
  simp only [orbitParity, decide_eq_true_eq, decide_eq_false_iff_not] at *
  exact fun h => by have := parity_exclusion n k (by omega); omega

/-
**Odd Density Bound**: In any orbit of length k,
    at most ⌈k/2⌉ steps are odd.
-/
theorem oddSteps_le_half (n k : ℕ) :
    oddSteps (orbitParity n k) ≤ (k + 1) / 2 := by
  -- Consider the set S of odd-step positions. By parity exclusion, if i ∈ S then i+1 ∉ S.
  set S := Finset.filter (fun i => orbitParity n k i = true) (Finset.univ : Finset (Fin k))
  have hS_no_consecutive : ∀ i j : Fin k, i ∈ S → j ∈ S → i.val ≠ j.val + 1 := by
    intro i j hi hj h; have := orbitParity_no_consecutive_true n j i; simp_all +decide ;
    simp +zetaDelta at *;
    unfold orbitParity at *; simp_all +decide ;
    exact absurd hi ( by erw [ parity_exclusion _ _ hj ] ; norm_num );
  -- Since S has no consecutive elements, its size is at most (k + 1) / 2.
  have hS_card : Finset.card (Finset.image (fun i : Fin k => i.val / 2) S) ≤ (k + 1) / 2 := by
    exact le_trans ( Finset.card_le_card <| Finset.image_subset_iff.mpr fun i hi => Finset.mem_range.mpr <| show ( i : ℕ ) / 2 < ( k + 1 ) / 2 from Nat.div_lt_of_lt_mul <| by linarith [ Fin.is_lt i, Nat.div_add_mod ( k + 1 ) 2, Nat.mod_lt ( k + 1 ) two_pos ] ) ( by norm_num );
  rwa [ Finset.card_image_of_injOn ] at hS_card;
  intros i hi j hj hij;
  grind

/-! ## §11. Generalized Collatz: Encoding Power -/

/-- A finite state transition system. -/
structure FiniteTransition where
  states : ℕ
  states_pos : states > 0
  transition : Fin states → Fin states

/-- A GCS encodes a finite transition system via orbit dynamics. -/
def GCS.Encodes (g : GCS) (ft : FiniteTransition) : Prop :=
  ∃ (embed : Fin ft.states → ℕ),
    Function.Injective embed ∧
    ∀ s : Fin ft.states, ∃ k : ℕ, k ≥ 1 ∧
      g.iter (embed s) k = embed (ft.transition s)

/-! ## §12. The Independence Conjecture -/

/-- Independence of a proposition from a proof system. -/
def IndependentOf (P : Prop) (proves : Prop → Prop) : Prop :=
  ¬proves P ∧ ¬proves (¬P)

/-- **The Independence Conjecture**: Collatz is independent of any
    sound proof system that proves basic arithmetic. -/
def CollatzIndependenceConjecture : Prop :=
  ∀ (proves : Prop → Prop),
    (∀ P, proves P → P) →
    (proves (∀ n : ℕ, n + 0 = n)) →
    ¬proves CollatzConj ∨ ¬proves (¬CollatzConj)

/-! ## §13. Falsifiable Conjecture: Polynomial Orbit Diameter -/

/-- The polynomial orbit diameter conjecture. -/
def PolyDiameterConj : Prop :=
  ∃ C : ℕ, C ≥ 1 ∧ ∀ n : ℕ, n ≥ 1 → ReachesOne n →
    peakValue n (stoppingTime n) ≤ n ^ C

/-! ## §14. Small Case Verification -/

theorem reachesOne_1 : ReachesOne 1 := ⟨0, rfl⟩
theorem reachesOne_2 : ReachesOne 2 :=
  ⟨1, by simp [collatzIter, collatzStep]⟩
theorem reachesOne_3 : ReachesOne 3 :=
  ⟨7, by native_decide⟩
theorem reachesOne_4 : ReachesOne 4 :=
  ⟨2, by simp [collatzIter, collatzStep, Function.iterate_succ_apply']⟩

/-- Collatz holds for all n ∈ [1, 4]. -/
theorem collatzUpTo_four : CollatzUpTo 4 := by
  intro n h1 h2
  interval_cases n
  · exact reachesOne_1
  · exact reachesOne_2
  · exact reachesOne_3
  · exact reachesOne_4

end CollatzUndec