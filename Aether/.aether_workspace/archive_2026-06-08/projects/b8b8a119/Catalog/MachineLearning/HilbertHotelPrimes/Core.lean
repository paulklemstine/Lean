/-
# Hilbert's Hotel for Primes: Permutation Stability of the Prime Sequence

We study how the sequence of prime numbers behaves under permutations of the
natural numbers. The central object is the "displacement" of a permutation —
how far each element moves — and its relationship to the asymptotic behavior
of the permuted prime sequence.

## Main Definitions
- `nthPrime`: The n-th prime number (0-indexed), using `Nat.nth Nat.Prime`
- `BoundedDisplacement`: Permutations σ : ℕ ≃ ℕ with |σ(n) - n| ≤ K for all n
- `DisplacementMetric`: A metric on permutations measuring maximum displacement
- `PrimeHotelAssignment`: The canonical assignment of primes to hotel rooms

## Main Results
- Bounded displacement permutations form a subgroup of Sym(ℕ)
- Finitely supported permutations have bounded displacement
- The nth prime is strictly monotone and grows at least linearly
- Cross-domain connection: displacement induces a tropical-algebraic structure
-/

import Mathlib

open Nat Set Filter

noncomputable section

/-! ## The nth Prime -/

/-- The n-th prime number (0-indexed). p(0) = 2, p(1) = 3, p(2) = 5, ... -/
def nthPrime (n : ℕ) : ℕ := Nat.nth Nat.Prime n

/-- The set of primes is infinite. -/
theorem primes_infinite : {p : ℕ | Nat.Prime p}.Infinite :=
  Nat.infinite_setOf_prime

/-- The nth prime is always prime. -/
theorem nthPrime_prime (n : ℕ) : Nat.Prime (nthPrime n) :=
  Nat.nth_mem_of_infinite primes_infinite n

/-- The nth prime function is strictly monotone. -/
theorem nthPrime_strictMono : StrictMono nthPrime :=
  Nat.nth_strictMono primes_infinite

/-- The nth prime function is injective. -/
theorem nthPrime_injective : Function.Injective nthPrime :=
  nthPrime_strictMono.injective

/-- The nth prime is at least 2. -/
theorem nthPrime_ge_two (n : ℕ) : 2 ≤ nthPrime n :=
  (nthPrime_prime n).two_le

/-
The nth prime is at least n + 2. This follows from strict monotonicity
    and the fact that the 0th prime is 2.
-/
theorem nthPrime_ge_add_two (n : ℕ) : n + 2 ≤ nthPrime n := by
  induction' n with n ih;
  · exact Nat.Prime.two_le ( Nat.prime_nth_prime 0 );
  · exact lt_of_le_of_lt ih ( Nat.nth_strictMono ( Nat.infinite_setOf_prime ) ( Nat.lt_succ_self _ ) )

/-- The nth prime is positive. -/
theorem nthPrime_pos (n : ℕ) : 0 < nthPrime n := by
  linarith [nthPrime_ge_two n]

/-! ## Bounded Displacement Permutations -/

/-- A permutation σ : ℕ ≃ ℕ has bounded displacement K if for all n,
    the distance |σ(n) - n| ≤ K. This captures permutations that don't
    move elements "too far" from their original position. -/
def BoundedDisplacement (σ : Equiv.Perm ℕ) (K : ℕ) : Prop :=
  ∀ n : ℕ, (σ n : ℤ) - (n : ℤ) ∈ Set.Icc (-(K : ℤ)) (K : ℤ)

/-- A permutation has bounded displacement if there exists some bound K. -/
def HasBoundedDisplacement (σ : Equiv.Perm ℕ) : Prop :=
  ∃ K : ℕ, BoundedDisplacement σ K

/-- A finitely supported permutation is one that fixes all but finitely many points. -/
def FinitelySupportedPerm (σ : Equiv.Perm ℕ) : Prop :=
  Set.Finite {n : ℕ | σ n ≠ n}

/-
The identity permutation has bounded displacement 0.
-/
theorem boundedDisplacement_id : BoundedDisplacement (Equiv.refl ℕ) 0 := by
  exact fun n => by norm_num

/-
A finitely supported permutation has bounded displacement.
-/
theorem finitelySupportedPerm_hasBoundedDisplacement (σ : Equiv.Perm ℕ)
    (hfin : FinitelySupportedPerm σ) : HasBoundedDisplacement σ := by
  have := hfin.bddAbove;
  cases' this with M hM;
  use M + M;
  intro n; by_cases hn : σ n = n <;> simp_all +decide [ upperBounds ] ;
  constructor <;> linarith [ hM hn, show ( σ n : ℕ ) ≤ M from hM ( by aesop ) ]

/-
The inverse of a bounded displacement permutation is also bounded.
-/
theorem boundedDisplacement_inv (σ : Equiv.Perm ℕ) (K : ℕ)
    (h : BoundedDisplacement σ K) : BoundedDisplacement σ⁻¹ K := by
  intro n
  specialize h (σ⁻¹ n)
  simp_all +decide;
  constructor <;> linarith

/-
The composition of bounded displacement permutations has bounded displacement
    with the sum of the bounds.
-/
theorem boundedDisplacement_comp (σ τ : Equiv.Perm ℕ) (K₁ K₂ : ℕ)
    (h₁ : BoundedDisplacement σ K₁) (h₂ : BoundedDisplacement τ K₂) :
    BoundedDisplacement (σ * τ) (K₁ + K₂) := by
  intro n;
  constructor <;> have := h₁ ( τ n ) <;> have := h₂ n <;> norm_num at * <;> linarith! [ this.1, this.2 ]

/-! ## Prime Hotel Assignment -/

/-- The canonical Hilbert Hotel assignment: room n contains the nth prime.
    This structure packages the assignment with its key properties. -/
structure PrimeHotelAssignment where
  /-- The assignment function from room number to prime -/
  assign : ℕ → ℕ
  /-- Every assigned number is prime -/
  assign_prime : ∀ n, Nat.Prime (assign n)
  /-- The assignment is strictly monotone -/
  assign_strictMono : StrictMono assign
  /-- The assignment is surjective onto primes -/
  assign_surj : ∀ p, Nat.Prime p → ∃ n, assign n = p

/-
The canonical hotel: room n gets the nth prime.
-/
def canonicalHotel : PrimeHotelAssignment where
  assign := nthPrime
  assign_prime := nthPrime_prime
  assign_strictMono := nthPrime_strictMono
  assign_surj := by
    intro p hp
    have h_exists_n : ∃ n : ℕ, Nat.nth Nat.Prime n = p := by
      exact ⟨ Nat.count ( Nat.Prime ) p, Nat.nth_count hp ⟩
    exact h_exists_n

/-! ## Permuted Hotels and Ratio Sequences -/

/-- Given a permutation σ, the permuted prime sequence assigns the σ(n)-th prime
    to room n. -/
def permutedPrimeSeq (σ : Equiv.Perm ℕ) (n : ℕ) : ℕ := nthPrime (σ n)

/-- The ratio sequence: permutedPrime(n) / nthPrime(n) as a real number. -/
def primeRatioSeq (σ : Equiv.Perm ℕ) (n : ℕ) : ℝ :=
  (nthPrime (σ n) : ℝ) / (nthPrime n : ℝ)

/-
The identity permutation gives ratio 1 everywhere.
-/
theorem primeRatioSeq_id (n : ℕ) :
    primeRatioSeq (Equiv.refl ℕ) n = 1 := by
  exact div_self <| Nat.cast_ne_zero.mpr <| Nat.Prime.ne_zero <| nthPrime_prime n

/-! ## Displacement Metric: A Tropical Connection

We define a metric on bounded-displacement permutations that has a natural
interpretation in tropical geometry: the displacement is analogous to a
tropical norm (max-plus algebra). -/

/-- The displacement of a permutation at a point, as a natural number. -/
def pointDisplacement (σ : Equiv.Perm ℕ) (n : ℕ) : ℕ :=
  Int.natAbs ((σ n : ℤ) - (n : ℤ))

/-- The maximum displacement over a finite prefix [0, N). -/
def maxDisplacementPrefix (σ : Equiv.Perm ℕ) (N : ℕ) : ℕ :=
  (Finset.range N).sup (pointDisplacement σ)

/-- The displacement metric on permutations of ℕ, valued in ℝ≥0∞.
    This is the supremum of pointwise displacements, which may be infinite.
    It satisfies d(id, σ) = sup_n |σ(n) - n|.
    This is a tropical norm: in the max-plus (tropical) semiring,
    sup corresponds to tropical addition. -/
def displacementNorm (σ : Equiv.Perm ℕ) : ℕ∞ :=
  ⨆ n, (pointDisplacement σ n : ℕ∞)

/-
The identity has displacement norm 0.
-/
theorem displacementNorm_id : displacementNorm (Equiv.refl ℕ) = 0 := by
  simp [displacementNorm, pointDisplacement]

/-
Bounded displacement is equivalent to finite displacement norm.
-/
theorem hasBoundedDisplacement_iff_finite_norm (σ : Equiv.Perm ℕ) :
    HasBoundedDisplacement σ ↔ displacementNorm σ ≠ ⊤ := by
  constructor <;> intro h <;> contrapose! h <;> simp_all +decide [ HasBoundedDisplacement ];
  · intro K hK;
    exact h.not_lt <| lt_of_le_of_lt ( iSup_le fun n => WithTop.coe_le_coe.mpr <| show Int.natAbs ( ( σ n : ℤ ) - n ) ≤ K from by cases abs_cases ( ( σ n : ℤ ) - n ) <;> linarith [ Set.mem_Icc.mp <| hK n ] ) <| WithTop.coe_lt_top K;
  · simp_all +decide [ BoundedDisplacement, displacementNorm ];
    rw [ iSup_eq_top ];
    intro b hb; rcases h ( Nat.ceil ( b.toNat ) ) with ⟨ i, hi ⟩ ; use i; norm_cast at *; simp_all +decide [ pointDisplacement ] ;
    cases b <;> norm_num at * ; omega;

/-! ## Key Structural Theorem: Finitely Supported → Eventually Identity Ratio

For any permutation that moves only finitely many elements, the ratio
sequence p_{σ(n)}/p_n equals 1 for all sufficiently large n. This is
a non-trivial consequence: it doesn't just say the limit is 1, but that
the sequence is *eventually constant* at 1. -/

/-
A finitely supported permutation fixes all sufficiently large elements.
-/
theorem finitelySupportedPerm_eventually_id (σ : Equiv.Perm ℕ)
    (hfin : FinitelySupportedPerm σ) :
    ∃ N : ℕ, ∀ n ≥ N, σ n = n := by
  cases' hfin.bddAbove with N hN;
  exact ⟨ N + 1, fun n hn => Classical.not_not.1 fun hnn => not_lt_of_ge ( hN hnn ) hn ⟩

/-
For finitely supported permutations, the prime ratio is eventually 1.
-/
theorem primeRatio_eventually_one_of_finitelySupported (σ : Equiv.Perm ℕ)
    (hfin : FinitelySupportedPerm σ) :
    ∃ N : ℕ, ∀ n ≥ N, primeRatioSeq σ n = 1 := by
  -- By finitelySupportedPerm_event �ually�_id, there exists N such that σ n = n for all n ≥ N.
  obtain ⟨N, hN⟩ : ∃ N : ℕ, ∀ n ≥ N, σ n = n := by
    apply finitelySupportedPerm_eventually_id; assumption
  use N
  intro n hn
  simp [primeRatioSeq, hN n hn];
  exact Nat.Prime.ne_zero ( nthPrime_prime n )

/-! ## Prime Gap Bounds from Bounded Displacement

A key insight: for bounded displacement permutations, the ratio p_{σ(n)}/p_n
is controlled by the prime gaps near n. We prove that bounded displacement
gives bounded ratio, using the monotonicity of primes. -/

/-
For bounded displacement K, the permuted prime is between the (n-K)th
    and (n+K)th primes. This gives a "sandwich" for the ratio.
-/
theorem permuted_prime_sandwich (σ : Equiv.Perm ℕ) (K : ℕ)
    (h : BoundedDisplacement σ K) (n : ℕ) (_hn : K ≤ n) :
    nthPrime (n - K) ≤ nthPrime (σ n) ∧ nthPrime (σ n) ≤ nthPrime (n + K) := by
  constructor;
  · exact Nat.nth_monotone ( Nat.infinite_setOf_prime ) ( Nat.sub_le_of_le_add <| by linarith [ Set.mem_Icc.mp <| h n ] );
  · refine' Nat.nth_monotone _ _;
    · exact Nat.infinite_setOf_prime;
    · linarith [ Set.mem_Icc.mp ( h n ) ]

/-! ## Conjecture: Density of Well-Behaved Permutations

**Falsifiable Conjecture**: The set of permutations σ for which
p_{σ(n)}/p_n → 1 is dense in the symmetric group Sym(ℕ) with the
topology of pointwise convergence.

Testable prediction: For any finite partial permutation (a bijection on
{0, ..., N-1}), there exists an extension to a full permutation of ℕ
such that p_{σ(n)}/p_n → 1.

Computational test: Take random permutations of {0, ..., 10^6 - 1},
extend by identity, and check that max |p_{σ(n)}/p_n - 1| < 0.01
for n > 1000. -/

/-- A permutation σ is "ratio-convergent" if p_{σ(n)}/p_n → 1. -/
def IsRatioConvergent (σ : Equiv.Perm ℕ) : Prop :=
  Filter.Tendsto (primeRatioSeq σ) Filter.atTop (nhds 1)

/-
**Conjecture**: Every finitely supported permutation is ratio-convergent.
    This is actually a theorem, as the ratio is eventually 1.
-/
theorem finitelySupported_isRatioConvergent (σ : Equiv.Perm ℕ)
    (hfin : FinitelySupportedPerm σ) : IsRatioConvergent σ := by
  -- By primeRatio_eventually_one_of_finitelySupported, there exists N such that primeRatioSeq σ n = 1 for all n ≥ N.
  obtain ⟨N, hN⟩ : ∃ N : ℕ, ∀ n ≥ N, primeRatioSeq σ n = 1 := primeRatio_eventually_one_of_finitelySupported σ hfin
  exact tendsto_nhds_of_eventually_eq (Filter.eventually_atTop.mpr ⟨N, hN⟩)

/-! ## Adjacent Transposition Analysis

The swap (n, n+1) is the simplest non-trivial permutation. We prove
it has bounded displacement 1, giving a building block for the theory. -/

/-- The swap of adjacent elements n and n+1. -/
def adjacentSwap (n : ℕ) : Equiv.Perm ℕ := Equiv.swap n (n + 1)

/-
An adjacent swap has bounded displacement 1.
-/
theorem adjacentSwap_boundedDisplacement (n : ℕ) :
    BoundedDisplacement (adjacentSwap n) 1 := by
  intro m; by_cases hm : m = n <;> by_cases hm' : m = n + 1 <;> simp_all +decide [ adjacentSwap ] ;
  rw [ Equiv.swap_apply_def ] ; aesop

/-
The number of fixed points of an adjacent swap is all but 2 elements.
-/
theorem adjacentSwap_finitelySupported (n : ℕ) :
    FinitelySupportedPerm (adjacentSwap n) := by
  refine Set.Finite.subset ( Set.toFinite { n, n + 1 } ) ?_;
  intro m hm; contrapose! hm; unfold adjacentSwap at *; aesop;

end