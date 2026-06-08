/-
  # Tropical Additive Combinatorics: Core Definitions and Theorems

  This module develops a formal bridge between classical additive combinatorics on ℕ
  and min-plus (tropical) convolution methods. The key insight is that additive
  representability of a number as a sum of elements from a set A can be exactly
  characterized by the vanishing of a min-plus convolution of the tropical cost
  function associated to A.

  ## Main definitions
  - `tropPredCost A n`: the tropical cost function, 0 if A(n), ⊤ otherwise
  - `minplusConv f g n`: min-plus convolution of f and g at n
  - `addSumset A B n`: predicate for n being in the sumset A + B
  - `softPrimeCost K n`: soft tropical prime cost, 0 if prime, K otherwise

  ## Main results
  - `minplusConv_tropPredCost_eq_zero_iff`: exact characterization of when
    the min-plus self-convolution of a tropical cost vanishes
  - `zero_locus_minplusConv_tropPredCost`: the zero locus of the convolution
    is exactly the sumset
  - `minplusConv_mono`: monotonicity of min-plus convolution
  - `eventual_zero_of_eventual_sumset`: eventual vanishing from eventual sumset coverage
  - `goldbach_tropical_exact_iff`: specialization to primes (Goldbach reformulation)
  - `goldbach_from_finite_check_and_cover`: finite verification reduction theorem
-/
import Mathlib

open scoped BigOperators

noncomputable section

/-! ## Core Definitions -/

/-- The tropical cost function associated to a predicate A on ℕ.
    Returns 0 if A(n) holds, ⊤ otherwise. This encodes set membership
    as a tropical (min-plus) algebraic quantity. -/
def tropPredCost (A : ℕ → Prop) [DecidablePred A] (n : ℕ) : WithTop ℕ :=
  if A n then 0 else ⊤

/-- Min-plus convolution of two functions f, g : ℕ → WithTop ℕ.
    This is the fundamental operation of tropical algebra applied to
    additive combinatorics:
      (f ⋆ g)(n) = inf { f(a) + g(b) | a + b = n }
    When applied to tropical cost functions, it captures additive
    representability. -/
def minplusConv (f g : ℕ → WithTop ℕ) (n : ℕ) : WithTop ℕ :=
  ⨅ (a : ℕ) (b : ℕ) (_ : a + b = n), f a + g b

/-- The additive sumset predicate: addSumset A B n holds iff
    n can be written as a + b with A(a) and B(b). -/
def addSumset (A B : ℕ → Prop) (n : ℕ) : Prop :=
  ∃ a b : ℕ, a + b = n ∧ A a ∧ B b

/-- Soft tropical prime cost: returns 0 for primes, K for composites.
    This allows studying approximate additive primality and gives
    meaningful asymptotic bounds, unlike the hard 0/⊤ cost. -/
def softPrimeCost (K n : ℕ) : ℕ :=
  if Nat.Prime n then 0 else K

end

/-! ## Theorem A: Exact tropical equivalence -/

/-
**Theorem A (general two-predicate version).**
    The min-plus convolution of tropical cost functions vanishes at n
    if and only if n lies in the additive sumset of A and B.
    This is the universal theorem behind tropical reformulations of
    additive representability.
-/
theorem zero_locus_minplusConv_tropPredCost
    (A B : ℕ → Prop) [DecidablePred A] [DecidablePred B] (n : ℕ) :
    minplusConv (tropPredCost A) (tropPredCost B) n = 0 ↔
      addSumset A B n := by
  constructor;
  · contrapose!;
    unfold minplusConv;
    simp +decide [ addSumset, tropPredCost ];
    intro h;
    refine' ne_of_gt ( lt_of_lt_of_le _ ( le_ciInf fun a => le_ciInf fun b => _ ) );
    exact zero_lt_one;
    by_cases ha : A a <;> by_cases hb : B b <;> simp +decide [ ha, hb ];
    exact fun hab => h a b hab ha hb;
  · intro h
    obtain ⟨a, b, hab⟩ := h
    have h_inf : ⨅ (a' : ℕ) (b' : ℕ) (_ : a' + b' = n), tropPredCost A a' + tropPredCost B b' ≤ tropPredCost A a + tropPredCost B b := by
      refine' le_trans ( ciInf_le _ a ) _;
      · bound;
      · refine' le_trans ( ciInf_le _ b ) _ <;> aesop;
    exact le_antisymm ( le_trans h_inf ( by unfold tropPredCost; aesop ) ) ( by exact zero_le _ )

/-
**Theorem A (self-convolution version).**
    Specialization to the case A = B, which is the relevant case
    for Goldbach-type problems.
-/
theorem minplusConv_tropPredCost_eq_zero_iff
    (A : ℕ → Prop) [DecidablePred A] (n : ℕ) :
    minplusConv (tropPredCost A) (tropPredCost A) n = 0 ↔
      ∃ a b : ℕ, a + b = n ∧ A a ∧ A b := by
  convert zero_locus_minplusConv_tropPredCost A A n using 1

/-
**Goldbach tropical equivalence.**
    Direct corollary: the tropical prime self-convolution vanishes at 2m
    iff 2m has a Goldbach decomposition.
-/
theorem goldbach_tropical_exact_iff (n : ℕ) :
    minplusConv (tropPredCost Nat.Prime) (tropPredCost Nat.Prime) (2*n) = 0 ↔
      ∃ p q : ℕ, p + q = 2*n ∧ Nat.Prime p ∧ Nat.Prime q := by
  -- Apply the theorem minplusConv_tropPredCost_eq_zero_iff with A = Nat.Prime.
  apply minplusConv_tropPredCost_eq_zero_iff

/-! ## Theorem C: Monotonicity and certificates -/

/-
**Min-plus convolution is monotone** in both arguments.
    If f₁ ≤ f₂ and g₁ ≤ g₂ pointwise, then f₁ ⋆ g₁ ≤ f₂ ⋆ g₂.
    This is the key structural property enabling majorization arguments.
-/
theorem minplusConv_mono
    {f₁ f₂ g₁ g₂ : ℕ → WithTop ℕ}
    (hf : ∀ n, f₁ n ≤ f₂ n)
    (hg : ∀ n, g₁ n ≤ g₂ n) :
    ∀ n, minplusConv f₁ g₁ n ≤ minplusConv f₂ g₂ n := by
  exact fun n => iInf_mono fun a => iInf_mono fun b => iInf_mono' fun h => ⟨ by aesop, add_le_add ( hf a ) ( hg b ) ⟩ ;

/-
**Eventual vanishing from eventual sumset coverage.**
    If every even number ≥ N lies in the sumset A + A,
    then the tropical self-convolution vanishes on all such numbers.
-/
theorem eventual_zero_of_eventual_sumset
    (A : ℕ → Prop) [DecidablePred A] (N : ℕ)
    (hcov : ∀ n ≥ N, Even n → addSumset A A n) :
    ∀ n ≥ N, Even n →
      minplusConv (tropPredCost A) (tropPredCost A) n = 0 := by
  exact fun n hn hn' => zero_locus_minplusConv_tropPredCost A A n |>.2 ( hcov n hn hn' )

/-! ## Theorem D: Finite verification reduction -/

/-
**Finite verification reduction for tropical Goldbach.**
    This theorem cleanly separates computation from structure:
    given a finite check up to B, plus a structural covering hypothesis
    for numbers beyond B, we obtain tropical Goldbach globally.
    This creates a formal architecture for hybrid theorem proving.
-/
theorem goldbach_from_finite_check_and_cover
    (B : ℕ)
    (hsmall :
      ∀ n, 4 ≤ n → n ≤ B → Even n →
        ∃ p q : ℕ, p + q = n ∧ Nat.Prime p ∧ Nat.Prime q)
    (A : ℕ → Prop) [DecidablePred A]
    (hA_prime : ∀ n, A n → Nat.Prime n)
    (hlarge : ∀ n, B < n → Even n → addSumset A A n) :
    ∀ n, 4 ≤ n → Even n →
      minplusConv (tropPredCost Nat.Prime) (tropPredCost Nat.Prime) n = 0 := by
  intro n hn hn'; cases le_or_gt n B <;> simp_all +decide [ minplusConv_tropPredCost_eq_zero_iff ] ;
  exact hlarge n ‹_› hn' |> fun ⟨ a, b, hab, ha, hb ⟩ => ⟨ a, b, hab, hA_prime a ha, hA_prime b hb ⟩

/-! ## Soft cost comparison theorems -/

/-
The soft prime cost is bounded above by the hard tropical cost.
    This means: any zero of the hard tropical cost is also a zero of
    the soft cost, and the soft cost is a finite relaxation of the
    hard indicator.
-/
theorem softPrimeCost_le_tropPredCost (K : ℕ) (n : ℕ) :
    ↑(softPrimeCost K n) ≤ tropPredCost Nat.Prime n := by
  unfold softPrimeCost tropPredCost;
  split_ifs <;> norm_num

/-! ## Concrete examples: small even numbers have tropical Goldbach cost 0 -/

/-
4 = 2 + 2, both prime.
-/
theorem goldbach_tropical_4 :
    minplusConv (tropPredCost Nat.Prime) (tropPredCost Nat.Prime) 4 = 0 := by
  -- Apply the theorem minplusConv_tropPredCost_eq_zero_iff with n = 4.
  apply (minplusConv_tropPredCost_eq_zero_iff Nat.Prime 4).mpr;
  exists 2, 2

/-
6 = 3 + 3, both prime.
-/
theorem goldbach_tropical_6 :
    minplusConv (tropPredCost Nat.Prime) (tropPredCost Nat.Prime) 6 = 0 := by
  exact minplusConv_tropPredCost_eq_zero_iff _ _ |>.2 ⟨ 3, 3, rfl, by norm_num ⟩

/-
8 = 3 + 5, both prime.
-/
theorem goldbach_tropical_8 :
    minplusConv (tropPredCost Nat.Prime) (tropPredCost Nat.Prime) 8 = 0 := by
  exact minplusConv_tropPredCost_eq_zero_iff Nat.Prime 8 |>.mpr ⟨ 3, 5, rfl, by norm_num ⟩

/-
10 = 3 + 7 or 5 + 5, both prime.
-/
theorem goldbach_tropical_10 :
    minplusConv (tropPredCost Nat.Prime) (tropPredCost Nat.Prime) 10 = 0 := by
  -- Apply the theorem minplusConv_tropPredCost_eq_zero_iff.mpr to conclude the proof.
  apply (minplusConv_tropPredCost_eq_zero_iff Nat.Prime 10).mpr;
  use 5, 5; simp [Nat.Prime];
  native_decide +revert

/-
12 = 5 + 7, both prime.
-/
theorem goldbach_tropical_12 :
    minplusConv (tropPredCost Nat.Prime) (tropPredCost Nat.Prime) 12 = 0 := by
  -- Apply the minplusConv_tropPredCost_eq_zero_iff theorem with a = 5 and b = 7.
  apply (minplusConv_tropPredCost_eq_zero_iff Nat.Prime 12).mpr;
  use 5, 7; norm_num

/-! ## Additional structural lemmas -/

/-
The tropical cost of n being in a set S is 0 iff n ∈ S.
-/
theorem tropPredCost_eq_zero_iff (A : ℕ → Prop) [DecidablePred A] (n : ℕ) :
    tropPredCost A n = 0 ↔ A n := by
  simp [tropPredCost]

/-
The tropical cost of n not being in S is ⊤.
-/
theorem tropPredCost_eq_top_iff (A : ℕ → Prop) [DecidablePred A] (n : ℕ) :
    tropPredCost A n = ⊤ ↔ ¬A n := by
  unfold tropPredCost; aesop;

/-
The min-plus convolution is the identity on top: if either factor
    is ⊤ for all valid decompositions, the convolution is ⊤.
-/
theorem minplusConv_eq_top_iff (f g : ℕ → WithTop ℕ) (n : ℕ) :
    minplusConv f g n = ⊤ ↔
      ∀ a b : ℕ, a + b = n → f a + g b = ⊤ := by
  unfold minplusConv;
  simp +decide [ iInf_eq_top ]

/-
Commutativity of min-plus convolution.
-/
theorem minplusConv_comm (f g : ℕ → WithTop ℕ) (n : ℕ) :
    minplusConv f g n = minplusConv g f n := by
  unfold minplusConv;
  refine' le_antisymm _ _ <;> simp +decide [ add_comm, iInf_le_iff ];
  · grind +revert;
  · grind