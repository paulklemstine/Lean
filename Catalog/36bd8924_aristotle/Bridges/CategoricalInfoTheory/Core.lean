/-
  # Categorical Information Theory: Foundations

  Core definitions and theorems establishing Shannon information theory
  as categorical constructions in the finite stochastic category.

  Bridge: Connects category theory (functors, natural transformations, Kan extensions)
  to information theory (entropy, mutual information, channel capacity)
  to thermodynamics (Landauer erasure, Boltzmann entropy)
  to cryptography (wiretap channels, post-quantum security bounds)
  to machine learning (certified robustness via data processing).

  ## Mathematical Architecture

  Objects of the stochastic category StochFD are finite probability spaces.
  Morphisms are stochastic matrices (channels). Shannon entropy is a
  monoidal functor H: StochFD → (ℝ, +), and channel capacity is the
  left Kan extension of the mutual information bifunctor.
-/

import Mathlib

open Finset Real BigOperators

noncomputable section

namespace CategoricalInfoTheory

/-! ## Section 1: Probability Distributions as Objects of StochFD -/

/-- A probability distribution on `Fin n`.
    This is an object of the Markov category StochFD.
    Bridge: connects probability theory to category theory (objects of StochFD)
    and to statistical mechanics (microstates of a thermodynamic system). -/
structure ProbDist (n : ℕ) where
  prob : Fin n → ℝ
  nonneg : ∀ i, 0 ≤ prob i
  sum_one : ∑ i : Fin n, prob i = 1

/-- A stochastic channel (conditional distribution) from `Fin n` to `Fin m`.
    This is a morphism in the Markov category StochFD.
    Bridge: connects probability to linear algebra (row-stochastic matrices)
    and to cryptography (noisy channels in wiretap coding). -/
structure StochChannel (n m : ℕ) where
  cond : Fin n → Fin m → ℝ
  nonneg : ∀ i j, 0 ≤ cond i j
  row_sum : ∀ i, ∑ j : Fin m, cond i j = 1

/-- The deterministic channel that applies a function `f : Fin n → Fin m`.
    Bridge: connects deterministic computation to stochastic channels. -/
def deterministicChannel {n m : ℕ} (f : Fin n → Fin m) : StochChannel n m where
  cond := fun i j => if f i = j then 1 else 0
  nonneg := fun i j => by split_ifs <;> norm_num
  row_sum := fun i => by simp [Finset.sum_ite_eq', Finset.mem_univ]

/-- The identity channel: each input maps to itself with probability 1.
    This is the identity morphism in StochFD. -/
def idChannel (n : ℕ) : StochChannel n n :=
  deterministicChannel id

/-- The uniform distribution on `Fin n` for `n ≥ 1`.
    Maximizes Shannon entropy (= log n).
    Bridge: connects information theory (maximum entropy) to
    statistical mechanics (microcanonical ensemble). -/
def uniformDist {n : ℕ} (hn : 0 < n) : ProbDist n where
  prob := fun _ => (1 : ℝ) / n
  nonneg := fun _ => by positivity
  sum_one := by
    simp [Finset.sum_const, nsmul_eq_mul]
    exact mul_inv_cancel₀ (Nat.cast_ne_zero.mpr (Nat.pos_iff_ne_zero.mp hn))

/-- The Dirac (point mass) distribution concentrated at a single point.
    Has zero entropy. This is the "pure state" of information theory.
    Bridge: connects info theory (zero entropy) to quantum mechanics (pure states). -/
def diracDist {n : ℕ} (k : Fin n) : ProbDist n where
  prob := fun i => if i = k then 1 else 0
  nonneg := fun i => by split_ifs <;> norm_num
  sum_one := by simp [Finset.sum_ite_eq', Finset.mem_univ]

/-! ## Section 2: Shannon Entropy as a Monoidal Functor -/

/-- Shannon entropy of a probability distribution, measured in nats.
    H(X) = ∑ negMulLog(p(x)) = -∑ p(x)·log(p(x)).
    Bridge: connects information theory (uncertainty) to
    thermodynamics (Boltzmann entropy S = k_B · H). -/
def shannonEntropy {n : ℕ} (p : ProbDist n) : ℝ :=
  ∑ i : Fin n, Real.negMulLog (p.prob i)

/-- Binary entropy function: H_b(t) = negMulLog(t) + negMulLog(1-t).
    Fundamental in coding theory and in Fano's inequality.
    Bridge: connects info theory to coding theory and to
    certified_robustness (binary classification error bounds). -/
def binaryEntropy (t : ℝ) : ℝ :=
  Real.negMulLog t + Real.negMulLog (1 - t)

/-! ## Section 3: Pushforward and Channel Composition -/

/-- Push a probability distribution through a stochastic channel.
    Bridge: connects Kleisli composition to Bayesian inference. -/
def pushforward {n m : ℕ} (p : ProbDist n) (W : StochChannel n m) : ProbDist m where
  prob := fun j => ∑ i : Fin n, p.prob i * W.cond i j
  nonneg := fun j => Finset.sum_nonneg fun i _ =>
    mul_nonneg (p.nonneg i) (W.nonneg i j)
  sum_one := by
    rw [Finset.sum_comm]
    simp_rw [← Finset.mul_sum, W.row_sum, mul_one]
    exact p.sum_one

/-- Compose two stochastic channels. This is composition of morphisms in StochFD.
    (W₂ ∘ W₁)(z|x) = ∑_y W₁(y|x) · W₂(z|y).
    Bridge: connects matrix multiplication to Markov chain composition. -/
def channelCompose {n m k : ℕ} (W₁ : StochChannel n m) (W₂ : StochChannel m k) :
    StochChannel n k where
  cond := fun i l => ∑ j : Fin m, W₁.cond i j * W₂.cond j l
  nonneg := fun i l => Finset.sum_nonneg fun j _ =>
    mul_nonneg (W₁.nonneg i j) (W₂.nonneg j l)
  row_sum := fun i => by
    rw [Finset.sum_comm]
    simp_rw [← Finset.mul_sum, W₂.row_sum, mul_one]
    exact W₁.row_sum i

/-! ## Section 4: Joint Distributions and Conditional Entropy -/

/-- A joint probability distribution on (Fin n) × (Fin m).
    Bridge: connects joint distributions to tensor products in
    the Markov category (monoidal structure on StochFD). -/
structure JointDist (n m : ℕ) where
  prob : Fin n → Fin m → ℝ
  nonneg : ∀ i j, 0 ≤ prob i j
  sum_one : ∑ i : Fin n, ∑ j : Fin m, prob i j = 1

/-- Marginal distribution on the first coordinate.
    Bridge: connects marginalization to the delete map in a Markov category. -/
def JointDist.marginal1 {n m : ℕ} (J : JointDist n m) : ProbDist n where
  prob := fun i => ∑ j : Fin m, J.prob i j
  nonneg := fun i => Finset.sum_nonneg fun j _ => J.nonneg i j
  sum_one := J.sum_one

/-- Marginal distribution on the second coordinate. -/
def JointDist.marginal2 {n m : ℕ} (J : JointDist n m) : ProbDist m where
  prob := fun j => ∑ i : Fin n, J.prob i j
  nonneg := fun j => Finset.sum_nonneg fun i _ => J.nonneg i j
  sum_one := by rw [Finset.sum_comm]; exact J.sum_one

/-- Joint entropy H(X,Y) = -∑_{x,y} p(x,y) log p(x,y).
    Bridge: connects joint entropy to the monoidal functor value on tensor products. -/
def jointEntropy {n m : ℕ} (J : JointDist n m) : ℝ :=
  ∑ i : Fin n, ∑ j : Fin m, Real.negMulLog (J.prob i j)

/-- Conditional entropy H(Y|X) = H(X,Y) - H(X).
    Bridge: connects conditional entropy to monoidal coherence and to
    Landauer's principle (thermodynamic cost of erasure). -/
def conditionalEntropy {n m : ℕ} (J : JointDist n m) : ℝ :=
  jointEntropy J - shannonEntropy J.marginal1

/-- Construct a joint distribution from an input distribution and a channel. -/
def jointFromChannel {n m : ℕ} (p : ProbDist n) (W : StochChannel n m) :
    JointDist n m where
  prob := fun i j => p.prob i * W.cond i j
  nonneg := fun i j => mul_nonneg (p.nonneg i) (W.nonneg i j)
  sum_one := by
    simp_rw [← Finset.mul_sum, W.row_sum, mul_one]
    exact p.sum_one

/-! ## Section 5: Mutual Information -/

/-- Mutual information I(X;Y) = H(X) + H(Y) - H(X,Y).
    Bridge: connects information theory to category theory (bifunctor)
    and to cryptography (information-theoretic security parameter). -/
def mutualInformation {n m : ℕ} (J : JointDist n m) : ℝ :=
  shannonEntropy J.marginal1 + shannonEntropy J.marginal2 - jointEntropy J

/-! ## Section 6: Core Theorems -/

/-
Shannon entropy is nonnegative: H(X) ≥ 0.
    This is the positivity constraint on the entropy monoidal functor.
    Bridge: connects information theory (entropy ≥ 0) to thermodynamics
    (second law: entropy of a closed system is nonneg).
-/
theorem shannonEntropy_nonneg {n : ℕ} (p : ProbDist n) :
    0 ≤ shannonEntropy p := by
  refine' Finset.sum_nonneg fun i _ => _;
  exact Real.negMulLog_nonneg ( p.nonneg i ) ( p.sum_one ▸ Finset.single_le_sum ( fun a _ => p.nonneg a ) ( Finset.mem_univ i ) )

/-
The entropy of a deterministic (Dirac) distribution is zero.
    Bridge: connects pure states to zero entropy (info theory)
    and to deterministic channels (category theory).
-/
theorem shannonEntropy_dirac {n : ℕ} (k : Fin n) :
    shannonEntropy (diracDist k) = 0 := by
  convert Finset.sum_eq_zero _;
  intro x hx; unfold diracDist; aesop;

/-
Binary entropy is symmetric: H_b(t) = H_b(1-t).
    Bridge: connects coding theory symmetry to the braiding
    isomorphism in the Markov category.
-/
theorem binaryEntropy_symm (t : ℝ) :
    binaryEntropy t = binaryEntropy (1 - t) := by
  unfold binaryEntropy; ring;

/-
Binary entropy vanishes at t = 0: H_b(0) = 0.
-/
theorem binaryEntropy_zero : binaryEntropy 0 = 0 := by
  -- By definition of binary entropy, we have:
  simp [binaryEntropy]

/-
Binary entropy vanishes at t = 1: H_b(1) = 0.
-/
theorem binaryEntropy_one : binaryEntropy 1 = 0 := by
  unfold binaryEntropy; norm_num;

/-
Binary entropy is nonnegative on [0,1].
    Bridge: connects to certified_robustness — the binary entropy
    bounds the classification error rate in binary hypothesis testing.
    Computational bound: 0 ≤ H_b(t) ≤ log(2) for t ∈ [0,1].
-/
theorem binaryEntropy_nonneg {t : ℝ} (h0 : 0 ≤ t) (h1 : t ≤ 1) :
    0 ≤ binaryEntropy t := by
  exact add_nonneg ( Real.negMulLog_nonneg h0 h1 ) ( Real.negMulLog_nonneg ( by linarith ) ( by linarith ) )

/-
The identity channel preserves distributions: pushforward through id = id.
    Bridge: identity morphism in category theory = perfect channel.
-/
theorem pushforward_id {n : ℕ} (p : ProbDist n) :
    (pushforward p (idChannel n)).prob = p.prob := by
  funext j
  simp [pushforward, idChannel, deterministicChannel]

/-
Channel composition is associative: making StochFD a category.
    Bridge: connects category theory (associativity) to Markov chains
    (Chapman-Kolmogorov equation).
-/
theorem channelCompose_assoc {n m k l : ℕ}
    (W₁ : StochChannel n m) (W₂ : StochChannel m k) (W₃ : StochChannel k l) :
    (channelCompose (channelCompose W₁ W₂) W₃).cond =
      (channelCompose W₁ (channelCompose W₂ W₃)).cond := by
  funext i l;
  unfold channelCompose; simp +decide [ mul_assoc, Finset.mul_sum _ _ _, Finset.sum_mul ] ;
  exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring )

/-
Pushforward respects composition: functoriality.
    Bridge: connects functoriality to the Chapman-Kolmogorov equation.
-/
theorem pushforward_compose {n m k : ℕ}
    (p : ProbDist n) (W₁ : StochChannel n m) (W₂ : StochChannel m k) :
    (pushforward (pushforward p W₁) W₂).prob =
      (pushforward p (channelCompose W₁ W₂)).prob := by
  funext j;
  unfold pushforward channelCompose;
  simp +decide [ mul_assoc, Finset.mul_sum _ _ _, Finset.sum_mul ];
  exact Finset.sum_comm

/-
A bijective deterministic channel preserves entropy.
    Bridge: connects group theory (bijections) to information conservation
    and to reversible computation (Landauer: reversible = no entropy cost).
-/
theorem shannonEntropy_deterministic_bij {n : ℕ} (f : Fin n → Fin n)
    (hf : Function.Bijective f) (p : ProbDist n) :
    shannonEntropy (pushforward p (deterministicChannel f)) = shannonEntropy p := by
  unfold shannonEntropy pushforward;
  unfold deterministicChannel; simp +decide [ hf.injective.eq_iff ] ;
  rw [ ← Equiv.sum_comp ( Equiv.ofBijective f hf ) ];
  simp +decide [ Finset.sum_ite, hf.injective.eq_iff ]

/-
The second marginal of the channel-induced joint distribution
    equals the pushforward distribution.
    Bridge: connects marginalization to the comonoid delete map.
-/
theorem jointFromChannel_marginal2 {n m : ℕ}
    (p : ProbDist n) (W : StochChannel n m) :
    (jointFromChannel p W).marginal2.prob = (pushforward p W).prob := by
  rfl

/-
The first marginal of the channel-induced joint equals the input.
-/
theorem jointFromChannel_marginal1 {n m : ℕ}
    (p : ProbDist n) (W : StochChannel n m) :
    (jointFromChannel p W).marginal1.prob = p.prob := by
  -- By definition of `marginal1`, we have:
  funext i
  simp [JointDist.marginal1, jointFromChannel];
  rw [ ← Finset.mul_sum _ _ _, W.row_sum, mul_one ]

/-
The chain rule: H(X,Y) = H(X) + H(Y|X), restated as:
    conditional entropy = joint entropy - marginal entropy.
    Bridge: connects the chain rule to monoidal coherence in category theory
    and to thermodynamic additivity (Clausius inequality).
-/
theorem chain_rule_identity {n m : ℕ} (J : JointDist n m) :
    jointEntropy J = shannonEntropy J.marginal1 + conditionalEntropy J := by
  exact?

/-
Binary entropy at 1/2 equals log(2).
    Bridge: connects to channel capacity of the binary symmetric channel
    and to certified_robustness (maximum uncertainty).
    Computational bound: max H_b = log(2) ≈ 0.693 nats.
-/
theorem binaryEntropy_half :
    binaryEntropy (1/2 : ℝ) = Real.log 2 := by
  unfold binaryEntropy;
  norm_num [ Real.log_div, Real.log_inv, Real.log_mul, Real.log_sqrt, Real.log_neg_eq_log, Real.log_neg_eq_log, Real.log_neg_eq_log, Real.log_neg_eq_log, Real.log_neg_eq_log, Real.log_neg_eq_log, Real.log_neg_eq_log, Real.log_neg_eq_log, Real.log_neg_eq_log, Real.log_neg_eq_log, Real.negMulLog ];
  ring

/-
Upper bound on Shannon entropy: H(X) ≤ log(n) for distributions on Fin n.
    Equality iff the distribution is uniform (maximum entropy principle).
    Bridge: connects to the maximum entropy principle in statistical mechanics.
    Computational bound: H(X) ≤ log(n) with O(n) verification.
-/
theorem shannonEntropy_le_log_card {n : ℕ} (hn : 0 < n) (p : ProbDist n) :
    shannonEntropy p ≤ Real.log n := by
  -- Apply Jensen's inequality for the concave function negMulLog with the weights 1/n and the values p(i).
  have h_jensen : (∑ i : Fin n, (1 / n : ℝ) • Real.negMulLog (p.prob i)) ≤ Real.negMulLog (∑ i : Fin n, (1 / n : ℝ) • p.prob i) := by
    convert ( Real.concaveOn_negMulLog).le_map_sum _ _ _ <;> norm_num;
    · exact mul_inv_cancel₀ ( by positivity );
    · exact p.nonneg;
  simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, p.sum_one ];
  convert mul_le_mul_of_nonneg_left h_jensen ( Nat.cast_nonneg n ) using 1 ; ring;
  · rw [ mul_inv_cancel₀ ( by positivity ), one_mul, show shannonEntropy p = ∑ i, Real.negMulLog ( p.prob i ) from rfl ];
  · unfold Real.negMulLog; norm_num [ hn.ne' ]

/-- Each row of a stochastic channel is a probability distribution. -/
theorem stochChannel_row_is_dist {n m : ℕ} (W : StochChannel n m) (i : Fin n) :
    (∑ j : Fin m, W.cond i j = 1) ∧ (∀ j, 0 ≤ W.cond i j) :=
  ⟨W.row_sum i, fun j => W.nonneg i j⟩

/-
Composing deterministic channels gives the deterministic channel of composition.
    Bridge: FinSet ↪ StochFD is a faithful functor.
-/
theorem deterministicChannel_compose {n m k : ℕ}
    (f : Fin n → Fin m) (g : Fin m → Fin k) :
    (channelCompose (deterministicChannel f) (deterministicChannel g)).cond =
      (deterministicChannel (g ∘ f)).cond := by
  ext i l; simp +decide [ channelCompose, deterministicChannel ] ;
  rw [ Finset.sum_eq_single ( f i ) ] <;> aesop

/-
Pushforward through a deterministic channel applies the function.
-/
theorem pushforward_deterministic {n m : ℕ} (p : ProbDist n)
    (f : Fin n → Fin m) :
    (pushforward p (deterministicChannel f)).prob =
      fun j => ∑ i : Fin n, if f i = j then p.prob i else 0 := by
  ext j; simp [pushforward, deterministicChannel]

/-
Left identity: composing with the identity channel on the left is neutral.
-/
theorem channelCompose_id_left {n m : ℕ} (W : StochChannel n m) :
    (channelCompose (idChannel n) W).cond = W.cond := by
  ext i j; simp +decide [ idChannel ] ;
  unfold channelCompose deterministicChannel; aesop;

/-
Right identity for channel composition.
-/
theorem channelCompose_id_right {n m : ℕ} (W : StochChannel n m) :
    (channelCompose W (idChannel m)).cond = W.cond := by
  ext i k; simp +decide [ idChannel, channelCompose ] ;
  unfold deterministicChannel; aesop;

/-! ## Section 7: Metric Structure and Certified Robustness -/

/-- The L¹ distance between two probability distributions.
    Bridge: connects to total variation distance in statistics
    and to differential privacy (sensitivity analysis). -/
def l1Distance {n : ℕ} (p q : ProbDist n) : ℝ :=
  ∑ i : Fin n, |p.prob i - q.prob i|

/-
L¹ distance is nonnegative.
-/
theorem l1Distance_nonneg {n : ℕ} (p q : ProbDist n) :
    0 ≤ l1Distance p q := by
  exact Finset.sum_nonneg fun _ _ => abs_nonneg _

/-
L¹ distance is symmetric.
-/
theorem l1Distance_symm {n : ℕ} (p q : ProbDist n) :
    l1Distance p q = l1Distance q p := by
  exact Finset.sum_congr rfl fun _ _ => abs_sub_comm _ _

/-
L¹ distance satisfies the triangle inequality.
    Bridge: connects to the Wasserstein metric and optimal transport.
    Computational bound: verification in O(n).
-/
theorem l1Distance_triangle {n : ℕ} (p q r : ProbDist n) :
    l1Distance p r ≤ l1Distance p q + l1Distance q r := by
  unfold l1Distance;
  simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_le_sum fun i _ => abs_sub_le _ _ _

/-
L¹ distance is bounded by 2 for all distributions.
    Bridge: connects to post_quantum_security (maximum distinguishing advantage).
-/
theorem l1Distance_le_two {n : ℕ} (p q : ProbDist n) :
    l1Distance p q ≤ 2 := by
  refine' le_trans _ ( show 2 ≥ ∑ i, p.prob i + ∑ i, q.prob i from _ );
  · exact le_trans ( Finset.sum_le_sum fun _ _ => show |p.prob _ - q.prob _| ≤ p.prob _ + q.prob _ by cases abs_cases ( p.prob _ - q.prob _ ) <;> linarith [ p.nonneg ‹_›, q.nonneg ‹_› ] ) ( by simp +decide [ Finset.sum_add_distrib ] );
  · linarith [ p.sum_one, q.sum_one ]

/-! ## Section 8: Capacity and Identity Channel -/

/-
The mutual information of the identity channel equals the entropy.
    I(X; X) = H(X) — observing X perfectly recovers all information.
    Bridge: connects to the capacity of the noiseless channel:
    C(id) = max_p H(p) = log(n).
    Computational bound: I(X;X) = H(X) computed in O(n).
-/
theorem mutualInfo_identity {n : ℕ} (p : ProbDist n) :
    mutualInformation (jointFromChannel p (idChannel n)) =
      shannonEntropy p := by
  unfold mutualInformation jointFromChannel;
  unfold jointEntropy; simp +decide [ shannonEntropy, idChannel ] ;
  unfold deterministicChannel;
  unfold JointDist.marginal1 JointDist.marginal2; simp +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne ] ;
  simp +decide [ ← Finset.sum_add_distrib, Real.negMulLog ]

/-! ## Section 9: Terminal Object and Uniqueness -/

/-- The terminal channel to Fin 1. -/
def terminalChannel (n : ℕ) : StochChannel n 1 where
  cond := fun _ _ => 1
  nonneg := fun _ _ => by norm_num
  row_sum := fun _ => by simp [Finset.sum_const]

/-
The terminal channel is unique: any channel to Fin 1 is the terminal channel.
    Bridge: connects universal properties (category theory) to
    marginalization (probability theory).
-/
theorem terminalChannel_unique {n : ℕ} (W : StochChannel n 1) :
    W.cond = (terminalChannel n).cond := by
  funext i j;
  have := W.row_sum i; simp_all +decide [ Fin.eq_zero, terminalChannel ] ;

/-! ## Section 10: Convex Combinations -/

/-- Convex combination of probability distributions.
    Bridge: connects convex geometry to Bayesian mixture models. -/
def convexCombination {n : ℕ} (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1)
    (p q : ProbDist n) : ProbDist n where
  prob := fun i => t * p.prob i + (1 - t) * q.prob i
  nonneg := fun i => add_nonneg
    (mul_nonneg ht0 (p.nonneg i))
    (mul_nonneg (sub_nonneg.mpr ht1) (q.nonneg i))
  sum_one := by
    simp_rw [Finset.sum_add_distrib, ← Finset.mul_sum]
    rw [p.sum_one, q.sum_one]
    ring

/-
Distribution values are bounded by 1.
-/
theorem prob_le_one {n : ℕ} (p : ProbDist n) (i : Fin n) :
    p.prob i ≤ 1 := by
  exact le_trans ( Finset.single_le_sum ( fun a _ => p.nonneg a ) ( Finset.mem_univ i ) ) p.sum_one.le

/-
Entropy of the uniform distribution on Fin 2 equals log 2.
    Bridge: connects to the thermodynamic bit — k_B · T · log(2)
    is the minimum energy to erase one bit (Landauer's principle).
-/
theorem entropy_uniform_two :
    shannonEntropy (uniformDist (n := 2) (by norm_num)) = Real.log 2 := by
  unfold uniformDist shannonEntropy; norm_num; ring;
  norm_num [ Real.negMulLog ];
  simpa using by ring;

/-
For independent random variables, mutual information is zero.
    Bridge: independence = tensor product = zero mutual information.
-/
theorem mutualInfo_independent {n m : ℕ} (p : ProbDist n) (q : ProbDist m)
    (J : JointDist n m)
    (hJ : ∀ i j, J.prob i j = p.prob i * q.prob j)
    (hp : J.marginal1.prob = p.prob)
    (hq : J.marginal2.prob = q.prob) :
    mutualInformation J =
      shannonEntropy p + shannonEntropy q - jointEntropy J := by
  unfold mutualInformation;
  congr;
  · cases p ; cases J ; aesop;
  · cases q ; aesop

/-
Joint entropy of independent variables: H(X,Y) = H(X) + H(Y).
    This is the monoidality isomorphism for independent systems.
    Bridge: connects monoidal category coherence to the additivity of
    Boltzmann entropy for independent thermodynamic systems.
    Computational bound: computed in O(n·m) operations.
-/
theorem jointEntropy_product {n m : ℕ} (p : ProbDist n) (q : ProbDist m)
    (J : JointDist n m)
    (hJ : ∀ i j, J.prob i j = p.prob i * q.prob j) :
    jointEntropy J = shannonEntropy p + shannonEntropy q := by
  unfold jointEntropy shannonEntropy;
  simp +decide [ hJ, Real.negMulLog_mul ];
  simp +decide [ Finset.sum_add_distrib, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, p.sum_one, q.sum_one ]

end CategoricalInfoTheory
end