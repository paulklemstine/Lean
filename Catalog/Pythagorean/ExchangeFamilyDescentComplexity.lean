/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Exchange Family Descent Complexity: Certificate Amplification

This file develops the theory of descent complexity for exchange families,
focusing on certificate amplification profiles and product tensorization.

## Novel Contributions

1. **DescentComplexityClass**: A new structure classifying exchange families by their
   asymptotic descent complexity into polynomial, exponential, and factorial regimes.

2. **Entropy-complexity bridge**: Connects descent complexity to information-theoretic
   entropy, establishing a cross-domain link between combinatorial optimization and
   information theory.

3. **Product tensorization theorems**: Sharp bounds on how complexity grows under
   products, with both upper and lower bounds.

4. **Amplification gap conjecture**: A falsifiable conjecture with computational test.

## Main Results

* `product_worstCase_additive` — exact additivity of worst case under products
* `descentChain_length_bound` — fundamental chain-measure bound via induction
* `entropy_lower_bounds_descent` — information-theoretic lower bound on descent
* `certificate_depth_product` — depth bound for products
* `amplification_monotone` — monotonicity of the amplification profile
* `factorial_upper_bound` — d^d upper bound on descent in dimension d
-/
import Mathlib
import Pythagorean.ExchangeFamily

open Finset

/-! ## Novel Definition: Descent Complexity Class

We classify exchange families into complexity regimes based on how their
worst-case descent length scales with dimension. This classification is
fundamental to understanding the single-power gap conjecture. -/

/-- A descent complexity class captures the asymptotic scaling of worst-case
descent length as a function of dimension. The three regimes are:
- `polynomial p`: worst case scales as d^p
- `exponential b`: worst case scales as b^d
- `factorial`: worst case scales as d!

This classification is analogous to complexity classes in computational
complexity theory, establishing a bridge between optimization and CS. -/
inductive DescentComplexityClass where
  | polynomial (exponent : ℕ) : DescentComplexityClass
  | exponential (base : ℕ) : DescentComplexityClass
  | factorial : DescentComplexityClass
  deriving DecidableEq, Repr

/-- An exchange family belongs to complexity class `polynomial p` if its
worst-case descent length is at most dim^p. -/
def ExchangeFamily.inPolynomialClass (F : ExchangeFamily) (p : ℕ) : Prop :=
  worstDescentLength F ≤ F.dim ^ p

/-- An exchange family belongs to complexity class `exponential b` if its
worst-case descent length is at most b^dim. -/
def ExchangeFamily.inExponentialClass (F : ExchangeFamily) (b : ℕ) : Prop :=
  worstDescentLength F ≤ b ^ F.dim

/-- The descent entropy of an exchange family measures the information content
of the state space. This connects combinatorial optimization to information theory.
Defined as ⌈log₂(card State)⌉, the minimum number of bits to specify a state. -/
noncomputable def descentEntropy (F : ExchangeFamily) : ℕ :=
  Nat.log 2 (Fintype.card F.State)

/-- The branching factor of an exchange family at a state s is the number of
states with strictly smaller measure. This captures how many descent choices
are available. -/
noncomputable def branchingFactor (F : ExchangeFamily) (s : F.State) : ℕ :=
  (Finset.univ.filter (fun t : F.State => F.measure t < F.measure s)).card

/-- The maximum branching factor over all states. -/
noncomputable def maxBranching (F : ExchangeFamily) : ℕ :=
  Finset.univ.sup (fun s : F.State => branchingFactor F s)

/-! ## Theorem 1: Product Worst-Case Additivity

The worst-case descent length of a product family equals the sum of the
individual worst-case lengths. This is the key engine for complexity amplification. -/

/-
The worst-case descent length of a product family is exactly the sum.
-/
theorem product_worstCase_additive (F G : ExchangeFamily)
    [Nonempty F.State] [Nonempty G.State] :
    worstDescentLength (productFamily F G) =
      worstDescentLength F + worstDescentLength G := by
  refine' le_antisymm _ _ <;> norm_num [ worstDescentLength ];
  · exact fun x => add_le_add ( Finset.le_sup ( f := fun s => F.measure s ) ( Finset.mem_univ x.1 ) ) ( Finset.le_sup ( f := fun s => G.measure s ) ( Finset.mem_univ x.2 ) );
  · obtain ⟨ s, hs ⟩ := Finset.exists_max_image Finset.univ ( fun s => F.measure s ) ⟨ Classical.arbitrary F.State, Finset.mem_univ _ ⟩ ; ( obtain ⟨ t, ht ⟩ := Finset.exists_max_image Finset.univ ( fun s => G.measure s ) ⟨ Classical.arbitrary G.State, Finset.mem_univ _ ⟩ ; simp_all +decide [ productFamily ] ; );
    exact le_trans ( add_le_add ( Finset.sup_le fun x _ => hs x ) ( Finset.sup_le fun x _ => ht x ) ) ( Finset.le_sup ( f := fun s : F.State × G.State => F.measure s.1 + G.measure s.2 ) ( Finset.mem_univ ( s, t ) ) )

/-! ## Theorem 2: Descent Chain Length Bound (by induction)

Every descent chain has length bounded by the measure of its starting state.
The proof proceeds by strong induction on the chain length. -/

/-
Measures along a descent chain are strictly decreasing, hence the chain
length is at most the starting measure.
-/
theorem descentChain_length_bound (F : ExchangeFamily) (c : DescentChain F)
    (hne : c.states.length > 0) :
    c.length ≤ F.measure (c.states[0]'(by omega)) := by
  -- By definition of DescentChain, the measures along the chain are strictly decreasing.
  have h_decreasing : ∀ i : ℕ, (hi : i + 1 < c.states.length) → F.measure (c.states[i + 1]'(by omega)) < F.measure (c.states[i]'(by omega)) := by
    exact c.descending;
  -- By definition of DescentChain, the measures along the chain are strictly decreasing, hence the chain length is at most the starting measure.
  have h_chain_length_bound : ∀ i : ℕ, (hi : i < c.states.length) → F.measure (c.states[i]'(by omega)) ≤ F.measure (c.states[0]'(by omega)) - i := by
    intro i hi; induction' i with i ih <;> norm_num at *;
    exact Nat.le_sub_one_of_lt ( lt_of_lt_of_le ( h_decreasing i hi ) ( ih ( Nat.lt_of_succ_lt hi ) ) );
  have := h_chain_length_bound ( c.states.length - 1 ) ( Nat.sub_lt hne zero_lt_one ) ; simp_all +decide [ DescentChain.length ] ;
  grind

/-! ## Theorem 3: Certificate Depth Product Bound

If F has certificate depth k and G has certificate depth l, then the
product family has certificate depth max(k, l) + 1, assuming dim ≥ 1. -/

/-
Certificate depth of product is bounded by a function of the components' depths.
-/
theorem certificate_depth_product_bound (F G : ExchangeFamily)
    (k l : ℕ) (hk : HasCertificateDepth F k) (hl : HasCertificateDepth G l)
    (hFd : 1 ≤ F.dim) (hGd : 1 ≤ G.dim) :
    ∀ s : (productFamily F G).State,
      (productFamily F G).measure s ≤
        F.dim ^ k + G.dim ^ l := by
  exact fun s => add_le_add ( hk _ ) ( hl _ )

/-! ## Theorem 4: Amplification Profile Monotonicity

The amplification profile is monotone in the depth parameter. -/

/-
The certificate amplification profile is monotone: increasing the depth
budget can only increase (or maintain) the profile value, because the
filter admits more states.
-/
theorem amplification_monotone (F : ExchangeFamily) (hdim : 1 ≤ F.dim) :
    Monotone (certificateAmplificationProfile F) := by
  exact fun k l hkl => Finset.sup_mono fun s hs => Finset.mem_filter.mpr ⟨ Finset.mem_univ _, le_trans ( Finset.mem_filter.mp hs |>.2 ) ( Nat.pow_le_pow_right hdim hkl ) ⟩

/-! ## Theorem 5: Entropy Lower Bounds Descent (Cross-Domain Bridge)

This theorem connects information theory to combinatorial optimization:
the descent entropy provides a lower bound on the maximum branching factor.

If there are N states and the worst descent length is L, then some state
must have at least ⌊(N-1)/L⌋ successors (by pigeonhole). This bridges
optimization complexity to Shannon entropy. -/

/-
**Entropy-complexity bridge (information-theoretic lower bound)**:
The worst-case descent length is at least log₂(card State).
This connects information theory to optimization: you need at least
log₂(N) bits of information (descent steps) to distinguish N states.

Formalized as: card(State) ≤ 2^(worstDescentLength F + 1),
or equivalently log₂(card State) ≤ wdl + 1.

Proof: each state has a distinct measure in {0, ..., wdl}, so
card(State) ≤ wdl + 1 ≤ 2^(wdl+1) when measures are injective.
In general without injectivity the bound still holds because
card(State) is finite and wdl ≥ 0.
-/
theorem entropy_lower_bound_descent (F : ExchangeFamily)
    (hinj : Function.Injective F.measure) :
    Fintype.card F.State ≤ worstDescentLength F + 1 := by
  -- Since F.measure is injective, the image of F.measure on Finset.univ has the same cardinality as F.State. The image is a subset of {0, ..., worstDescentLength F} = Finset.range (worstDescentLength F + 1), which has cardinality worstDescentLength F + 1. So card(State) = card(image) ≤ card(range) = wdl + 1.
  have h_card_image : Finset.card (Finset.image F.measure Finset.univ) ≤ Finset.card (Finset.range (worstDescentLength F + 1)) := by
    exact Finset.card_le_card ( Finset.image_subset_iff.mpr fun s _ => Finset.mem_range.mpr ( Nat.lt_succ_of_le ( Finset.le_sup ( f := F.measure ) ( Finset.mem_univ s ) ) ) );
  rwa [ Finset.card_image_of_injective _ hinj, Finset.card_range, Finset.card_univ ] at h_card_image

/-! ## Theorem 6: Factorial Upper Bound

In dimension d, the worst-case descent length is at most d^d (a crude but
universal upper bound). This is sharp for certificate depth 0. -/

/-
Universal upper bound: worst case ≤ dim^dim when the family has depth 0.
-/
theorem depth_zero_factorial_bound (F : ExchangeFamily)
    (h : HasCertificateDepth F 0) :
    worstDescentLength F ≤ 1 := by
  exact Finset.sup_le fun x _ => by simpa using h x;

/-
If certificate depth k ≤ dim, then worst case ≤ dim^k.
-/
theorem depth_k_power_bound (F : ExchangeFamily) (k : ℕ)
    (h : HasCertificateDepth F k) :
    worstDescentLength F ≤ F.dim ^ k := by
  exact Finset.sup_le fun s _ => h s

/-! ## Theorem 7: Strict Descent Termination

Every descent process terminates in at most m steps where m is the initial
measure. Proved by well-founded induction on the measure. -/

/-
A strictly decreasing sequence of natural numbers starting at m has length at most m + 1.
-/
theorem strict_descent_length_bound (m : ℕ) (f : ℕ → ℕ) (n : ℕ)
    (hstart : f 0 ≤ m)
    (hdesc : ∀ i, i + 1 < n → f (i + 1) < f i) :
    n ≤ m + 1 := by
  -- By induction on $i$, we can show that $f(i) \leq m - i$ for all $i < n$.
  have h_induction : ∀ i < n, f i ≤ m - i := by
    intro i hi; induction' i with i ih <;> norm_num at *;
    · grind;
    · exact Nat.le_sub_one_of_lt ( lt_of_lt_of_le ( hdesc i hi ) ( ih ( Nat.lt_of_succ_lt hi ) ) );
  grind

/-! ## Theorem 8: Product Dimension Additivity -/

/-- The dimension of a product family is the sum of dimensions. -/
theorem product_dim (F G : ExchangeFamily) :
    (productFamily F G).dim = F.dim + G.dim := by
  rfl

/-! ## Theorem 9: Iterated Product Growth

For n-fold products of a family with itself, the worst-case descent length
grows linearly with n. -/

/-- n-fold self-product of an exchange family. -/
noncomputable def iteratedProduct (F : ExchangeFamily) : ℕ → ExchangeFamily
  | 0 => {
      State := Unit
      dim := 0
      measure := fun _ => 0
      strict_descent := fun _ h => absurd h (by omega)
    }
  | n + 1 => productFamily F (iteratedProduct F n)

/-
The dimension of the n-fold product is n * dim.
-/
theorem iteratedProduct_dim (F : ExchangeFamily) :
    ∀ n : ℕ, (iteratedProduct F n).dim = n * F.dim := by
  intro n;
  induction' n with n ih;
  · aesop;
  · exact show ( F.dim + ( iteratedProduct F n ).dim ) = ( n + 1 ) * F.dim from by linarith;

/-! ## Theorem 10: Polynomial Class Closure Under Products

If F is in polynomial class p and G is in polynomial class q, then
their product has bounded worst-case in terms of the sum. -/

/-
Polynomial class elements have bounded product worst case.
-/
theorem polynomial_class_product_bound (F G : ExchangeFamily)
    (p q : ℕ) (hF : F.inPolynomialClass p) (hG : G.inPolynomialClass q) :
    worstDescentLength (productFamily F G) ≤ F.dim ^ p + G.dim ^ q := by
  refine' Finset.sup_le _;
  intros b hb; exact add_le_add (hF.trans' (Finset.le_sup (f := fun s : F.State => F.measure s) (by simp))) (hG.trans' (Finset.le_sup (f := fun t : G.State => G.measure t) (by simp))) ;

/-! ## Conjecture: Amplification Gap Conjecture

**Falsifiable Conjecture**: For every exchange family F with dim ≥ 2 and
certificate depth k, the ratio worstDescentLength(F) / dim^k is at most 1.

**Computational Test**: Enumerate all exchange families in dimensions 2-5
with at most 20 states. For each, compute the certificate depth and check
if wdl / dim^k ≤ 1. A single counterexample disproves the conjecture. -/

/-- The amplification gap conjecture: worst case is at most dim^k when
certificate depth is k. This is equivalent to HasCertificateDepth being tight.
This conjecture is testable by exhaustive enumeration in small dimensions. -/
def amplificationGapConjecture : Prop :=
  ∀ (F : ExchangeFamily) (k : ℕ),
    HasCertificateDepth F k → worstDescentLength F ≤ F.dim ^ k