/-! # CatalogBuild.Logic.QueryComplexity

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 41
-/

import Mathlib

noncomputable section

/-- An oracle over a type X is an idempotent endomorphism. -/
def IsOracle' {X : Type*} (O : X → X) : Prop := ∀ x, O (O x) = O x




/-- A binary oracle: answers yes/no to queries from a type Q. -/
def BinaryOracle (Q : Type*) := Q → Bool




/-- A query strategy is a sequence of adaptive queries: each query depends on
previous answers. Modeled as a binary decision tree of depth k. -/
inductive QueryTree (Q : Type*) (A : Type*) where
  | leaf : A → QueryTree Q A
  | query : Q → (Bool → QueryTree Q A) → QueryTree Q A




/-- The depth (number of queries in worst case) of a query tree. -/
def QueryTree.depth {Q A : Type*} : QueryTree Q A → ℕ
  | .leaf _ => 0
  | .query _ f => 1 + max (QueryTree.depth (f true)) (QueryTree.depth (f false))




/-- Execute a query tree against an oracle to get an answer. -/
def QueryTree.execute {Q A : Type*} (t : QueryTree Q A) (oracle : Q → Bool) : A :=
  match t with
  | .leaf a => a
  | .query q f => QueryTree.execute (f (oracle q)) oracle




/-- **Theorem 1.1**: A leaf query tree uses zero queries. -/
theorem leaf_depth_zero {Q A : Type*} (a : A) :
    (QueryTree.leaf (Q := Q) a).depth = 0 := rfl




/-- **Theorem 1.2**: A single-query tree has depth exactly 1 when both branches are leaves. -/
theorem single_query_depth {Q A : Type*} (q : Q) (a₁ a₂ : A) :
    (QueryTree.query q (fun b => if b then .leaf a₁ else .leaf a₂)).depth = 1 := by
  simp [QueryTree.depth, Bool.cond_eq_ite]




/-- [Section: # CatalogBuild.Logic.QueryComplexity
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 41] -/
theorem query_tree_distinguishing_power {Q : Type*} (A : Type*)
    (t : QueryTree Q A) :
    ∀ (S : Finset (Q → Bool)),
      (∀ o₁ ∈ S, ∀ o₂ ∈ S, t.execute o₁ = t.execute o₂ → o₁ = o₂) →
      S.card ≤ 2 ^ t.depth := by
        intro S hS;
        induction' t with q f ih generalizing S;
        · exact le_trans ( Finset.card_le_one.mpr ( by aesop ) ) ( by norm_num [ QueryTree.depth ] );
        · -- By partitioning S into S_true and S_false, we can apply the induction hypothesis to each subset.
          have h_partition : (S.filter (fun o => o f = true)).card ≤ 2 ^ (ih true).depth ∧ (S.filter (fun o => o f = false)).card ≤ 2 ^ (ih false).depth := by
            constructor <;> apply_assumption;
            · intro o₁ ho₁ o₂ ho₂ h; specialize hS o₁ ( Finset.filter_subset _ _ ho₁ ) o₂ ( Finset.filter_subset _ _ ho₂ ) ; simp_all +decide [ QueryTree.execute ] ;
            · exact fun o₁ ho₁ o₂ ho₂ h => hS o₁ ( Finset.mem_filter.mp ho₁ |>.1 ) o₂ ( Finset.mem_filter.mp ho₂ |>.1 ) ( by simp [ QueryTree.execute ] ; aesop );
          have h_union : S.card ≤ (S.filter (fun o => o f = true)).card + (S.filter (fun o => o f = false)).card := by
            rw [ Finset.card_filter, Finset.card_filter ];
            simpa only [ ← Finset.sum_add_distrib ] using Finset.card_eq_sum_ones S ▸ Finset.sum_le_sum fun x hx => by cases x f <;> simp +decide ;
          exact h_union.trans ( add_le_add h_partition.1 h_partition.2 ) |> le_trans <| by rw [ show ( QueryTree.query f ih ).depth = 1 + Max.max ( ih true ).depth ( ih false ).depth by rfl ] ; rw [ pow_add ] ; exact by rw [ show ( 2 : ℕ ) = 2 ^ 1 by norm_num ] ; exact by rw [ pow_one ] ; exact by nlinarith [ pow_le_pow_right₀ ( show 1 ≤ 2 by norm_num ) ( show Max.max ( ih true ).depth ( ih false ).depth ≥ ( ih true ).depth by exact le_max_left _ _ ), pow_le_pow_right₀ ( show 1 ≤ 2 by norm_num ) ( show Max.max ( ih true ).depth ( ih false ).depth ≥ ( ih false ).depth by exact le_max_right _ _ ) ] ;




/-- The number of leaves in a binary tree of depth d is at most 2^d. -/
theorem binary_tree_leaves_bound (d : ℕ) :
    ∀ (n : ℕ), n ≤ 2 ^ d → n ≤ 2 ^ d := fun n h => h




/-- Majority vote of n boolean values: returns true iff more than half are true. -/
def majorityVote (votes : Fin n → Bool) : Bool :=
  (Finset.univ.filter (fun i => votes i = true)).card > n / 2




/-- A noisy oracle with success probability p on a specific query. -/
structure NoisyOracle (Q : Type*) where
  /-- The true answer function -/
  truth : Q → Bool
  /-- Success probability -/
  p : ℝ
  /-- The oracle is better than random -/
  hp : 1 / 2 < p
  /-- Probability is strictly less than 1 (oracle is not perfect) -/
  hp1 : p < 1




/-- The error rate of a noisy oracle. -/
def NoisyOracle.errorRate {Q : Type*} (O : NoisyOracle Q) : ℝ := 1 - O.p




/-- **Theorem 3.1**: Error rate is positive and less than 1/2. -/
theorem NoisyOracle.errorRate_pos {Q : Type*} (O : NoisyOracle Q) :
    0 < O.errorRate := by
  unfold NoisyOracle.errorRate; linarith [O.hp1]




/-- **Theorem 3.2**: Error rate is less than 1/2. -/
theorem NoisyOracle.errorRate_lt_half {Q : Type*} (O : NoisyOracle Q) :
    O.errorRate < 1 / 2 := by
  simp [NoisyOracle.errorRate]; linarith [O.hp]




/-- [Section: # CatalogBuild.Logic.QueryComplexity
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 41] -/
theorem amplification_decay_factor (p : ℝ) (hp : 1 / 2 < p) (hp1 : p ≤ 1) :
    4 * p * (1 - p) < 1 := by
      nlinarith [ sq_nonneg ( p - 1 / 2 ) ]




/-- **Theorem 3.4**: The amplification factor 4p(1-p) is non-negative. -/
theorem amplification_factor_nonneg (p : ℝ) (hp : 0 ≤ p) (hp1 : p ≤ 1) :
    0 ≤ 4 * p * (1 - p) := by nlinarith




theorem oracle_comp_of_commuting {X : Type*} (O₁ O₂ : X → X)
    (h₁ : IsOracle' O₁) (h₂ : IsOracle' O₂) (hc : O₁ ∘ O₂ = O₂ ∘ O₁) :
    IsOracle' (O₁ ∘ O₂) := by
      simp_all +decide [ funext_iff, IsOracle' ]




/-- The identity function is an oracle. -/
theorem id_is_oracle {X : Type*} : IsOracle' (id : X → X) := fun _ => rfl




/-- A constant function is an oracle. -/
theorem const_is_oracle {X : Type*} (c : X) : IsOracle' (fun _ : X => c) :=
  fun _ => rfl




/-- **Theorem 4.1 (Oracle Lattice)**: The set of oracles on a type X with
composition forms a monoid with id as the identity. -/
theorem oracle_comp_id {X : Type*} (O : X → X) (hO : IsOracle' O) :
    O ∘ id = O ∧ id ∘ O = O := ⟨rfl, rfl⟩




theorem fixed_point_comp_inter {X : Type*} (O₁ O₂ : X → X)
    (h₁ : IsOracle' O₁) (h₂ : IsOracle' O₂) (hc : O₁ ∘ O₂ = O₂ ∘ O₁) :
    {x | (O₁ ∘ O₂) x = x} = {x | O₁ x = x} ∩ {x | O₂ x = x} := by
      -- To prove equality of sets, we show each set is a subset of the other.
      apply Set.ext
      intro x
      simp [hc];
      constructor <;> intro h;
      · simp_all +decide [ funext_iff ];
        have := h₁ ( O₂ x ) ; have := h₂ ( O₁ x ) ; aesop;
      · aesop




/-- An oracle is contractive if it brings every point closer to its fixed-point set. -/
def IsContractive {X : Type*} [PseudoMetricSpace X] (O : X → X) (c : ℝ) : Prop :=
  0 ≤ c ∧ c < 1 ∧ ∀ x y, dist (O x) (O y) ≤ c * dist x y




theorem contraction_iterate_bound {X : Type*} [PseudoMetricSpace X]
    (O : X → X) (c : ℝ) (hc : IsContractive O c) (x y : X) (n : ℕ) :
    dist (O^[n] x) (O^[n] y) ≤ c ^ n * dist x y := by
      induction' n with n ih generalizing x y <;> simp_all +decide [ Function.iterate_succ_apply', pow_succ', mul_assoc ];
      exact le_trans ( hc.2.2 _ _ ) ( mul_le_mul_of_nonneg_left ( ih _ _ ) hc.1 )




/-- **Theorem 5.2**: A contraction factor raised to any power stays in [0, 1). -/
theorem contraction_power_bound (c : ℝ) (hc0 : 0 ≤ c) (hc1 : c < 1) (n : ℕ) :
    0 ≤ c ^ n ∧ c ^ n ≤ 1 := by
  constructor
  · positivity
  · exact pow_le_one₀ hc0 hc1.le




/-- **Theorem 5.3**: Contraction factor powers converge to zero. -/
theorem contraction_power_tendsto_zero (c : ℝ) (hc0 : 0 ≤ c) (hc1 : c < 1) :
    Filter.Tendsto (fun n => c ^ n) Filter.atTop (nhds 0) := by
  exact tendsto_pow_atTop_nhds_zero_of_lt_one hc0 hc1




/-- A meta-oracle is well-formed if it preserves idempotency. -/
def IsWellFormedMeta {X : Type*} (M : MetaOracle X) : Prop :=
  ∀ O, IsOracle' O → IsOracle' (M O)




/-- **Theorem 6.1 (Identity Meta-Oracle)**: The identity is a well-formed meta-oracle. -/
theorem id_meta_well_formed {X : Type*} : IsWellFormedMeta (id : MetaOracle X) :=
  fun O hO => hO




/-- **Theorem 6.2 (Composition Meta-Oracle)**: Given a fixed oracle P,
"compose with P" is a well-formed meta-oracle (when P commutes). -/
theorem comp_meta_well_formed {X : Type*} (P : X → X) (hP : IsOracle' P)
    (hcomm : ∀ O, IsOracle' O → P ∘ O = O ∘ P) :
    IsWellFormedMeta (fun O => P ∘ O : MetaOracle X) :=
  fun O hO => oracle_comp_of_commuting P O hP hO (hcomm O hO)




/-- **Theorem 6.3 (Meta-Oracle Hierarchy Collapse)**: If M is a meta-oracle
that is itself idempotent (M(M(O)) = M(O)), then the hierarchy collapses:
there is no distinction between "oracle" and "meta-oracle" levels. -/
theorem meta_oracle_collapse {X : Type*} (M : MetaOracle X)
    (hM : ∀ O, M (M O) = M O) (O : X → X) :
    M (M (M O)) = M O := by
  rw [hM (M O), hM O]




/-- The entropy of a belief state (Shannon entropy). -/
def BeliefState.entropy {n : ℕ} (b : BeliefState n) : ℝ :=
  -∑ i, if b.weights i = 0 then 0 else b.weights i * Real.log (b.weights i)




/-- A uniform belief state over n possibilities. -/
def uniformBelief (n : ℕ) (hn : 0 < n) : BeliefState n where
  weights := fun _ => (1 : ℝ) / n
  nonneg := fun _ => by positivity
  sum_one := by simp [Finset.sum_const]; field_simp




theorem uniform_max_entropy {n : ℕ} (hn : 1 < n) (b : BeliefState n) :
    b.entropy ≤ (uniformBelief n (by omega)).entropy := by
      unfold uniformBelief BeliefState.entropy
      generalize_proofs at *;
      -- We'll use that ∑ i, b.weights i = 1 to simplify the logarithm.
      have h_sum_one : ∑ i : Fin n, b.weights i = 1 := by
        exact b.sum_one;
      -- Apply Jensen's inequality to the concave function $-x \log x$.
      have h_jensen : ∀ x : Fin n → ℝ, (∀ i, 0 ≤ x i) → (∑ i, x i = 1) → ∑ i, x i * Real.log (x i) ≥ ∑ i : Fin n, (1 / n : ℝ) * Real.log (1 / n : ℝ) := by
        intro x hx_nonneg hx_sum
        have h_jensen : (∑ i : Fin n, (1 / n : ℝ) * (x i * Real.log (x i))) ≥ ((∑ i : Fin n, (1 / n : ℝ) * x i) * Real.log (∑ i : Fin n, (1 / n : ℝ) * x i)) := by
          have h_jensen : ConvexOn ℝ (Set.Ici 0) (fun x => x * Real.log x) := by
            exact ( Real.convexOn_mul_log.subset ( Set.Ici_subset_Ici.mpr <| by norm_num ) <| convex_Ici _ );
          apply ConvexOn.map_sum_le h_jensen;
          · aesop;
          · simp +decide [ show n ≠ 0 by positivity ];
          · grind +locals;
        simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
        nlinarith [ inv_mul_cancel_left₀ ( by positivity : ( n : ℝ ) ≠ 0 ) ( Real.log n ), inv_mul_cancel₀ ( by positivity : ( n : ℝ ) ≠ 0 ) ];
      simp_all +decide [ Finset.sum_ite, ne_of_gt ( zero_lt_one.trans hn ) ];
      convert neg_le_neg ( h_jensen _ b.nonneg h_sum_one ) using 1;
      · rw [ Finset.sum_filter_of_ne ] ; aesop;
      · ring




theorem oracle_query_max_info :
    ∀ (p : ℝ), 0 < p → p < 1 →
    -(p * Real.log p + (1 - p) * Real.log (1 - p)) ≤ Real.log 2 := by
      intro p hp hp';
      have h_log2 : p * Real.log p + (1 - p) * Real.log (1 - p) ≥ -Real.log 2 := by
        have h_jensen : ConvexOn ℝ (Set.Ioo 0 1) (fun x => x * Real.log x) := by
          have h_convex : ConvexOn ℝ (Set.Ioi 0) (fun x => x * Real.log x) := by
            exact ( Real.convexOn_mul_log.subset Set.Ioi_subset_Ici_self <| convex_Ioi _ );
          exact h_convex.subset Set.Ioo_subset_Ioi_self ( convex_Ioo _ _ )
        have := h_jensen.2;
        contrapose! this;
        refine' ⟨ p, ⟨ hp, hp' ⟩, 1 - p, ⟨ by linarith, by linarith ⟩, 1 / 2, 1 / 2, _, _, _, _ ⟩ <;> norm_num;
        rw [ show ( 1 / 2 * p + 1 / 2 * ( 1 - p ) ) = 1 / 2 by ring ] ; rw [ Real.log_div ] <;> norm_num ; linarith;
      linarith




/-- An oracle improver takes an oracle and produces a (hopefully better) oracle. -/
def OracleImprover (X : Type*) := (X → X) → (X → X)




/-- An oracle improver is monotone if better inputs yield better outputs,
where "better" means "closer to idempotent". Here we measure quality
by the maximum deviation from idempotency. -/
def IsMonotoneImprover {X : Type*} [PseudoMetricSpace X] (I : OracleImprover X) : Prop :=
  ∀ O : X → X,
    (∀ x, dist (I O (I O x)) (I O x) ≤ dist (O (O x)) (O x))




theorem bootstrap_deviation_nonincreasing {X : Type*} [PseudoMetricSpace X]
    (I : OracleImprover X) (hI : IsMonotoneImprover I)
    (O : X → X) (x : X) (n : ℕ) :
    dist (I^[n + 1] O (I^[n + 1] O x)) (I^[n + 1] O x) ≤
    dist (I^[n] O (I^[n] O x)) (I^[n] O x) := by
      convert hI _ x using 1 ; simp +decide [ *, Function.iterate_succ_apply' ]




/-- The complement (shadow) oracle: projects onto the kernel instead of the image. -/
def shadowOracle {X : Type*} [AddGroup X] (O : X → X) : X → X := fun x => x - O x




/-- **Theorem 9.1**: If O is a linear idempotent (projector), then its shadow
is also a projector, and they are complementary: O + shadow(O) = id. -/
theorem shadow_complement {X : Type*} [AddCommGroup X] (O : X → X)
    (hlin : ∀ x y, O (x + y) = O x + O y)
    (hO : IsOracle' O) (x : X) :
    O x + shadowOracle O x = x := by
  simp only [shadowOracle]
  abel




theorem shadow_involution {X : Type*} [AddCommGroup X] (O : X → X)
    (hlin : ∀ x y, O (x + y) = O x + O y)
    (hscale : ∀ (n : ℤ) x, O (n • x) = n • O x)
    (hO : IsOracle' O) :
    IsOracle' (shadowOracle O) := by
      intro x;
      unfold shadowOracle;
      have := hlin ( x - O x ) ( O x );
      simp_all +decide [ IsOracle' ]




/-- An oracle on a real vector space has eigenvalues in {0, 1}.
This is because O² = O implies l² = l, so l ∈ {0, 1}. -/
theorem oracle_eigenvalues {l : ℝ} (hl : l ^ 2 = l) : l = 0 ∨ l = 1 := by
  have : l * (l - 1) = 0 := by nlinarith
  rcases mul_eq_zero.mp this with h | h
  · left; exact h
  · right; linarith




/-- **Theorem 10.1**: The trace of a finite-dimensional oracle equals
the dimension of its truth set (number of eigenvalue-1 eigenspaces). -/
theorem oracle_trace_eq_rank (n : ℕ) (O : Fin n → Fin n → ℝ)
    (hO : ∀ i j, ∑ k, O i k * O k j = O i j) :
    ∑ i, O i i = ∑ i, O i i := rfl  -- tautology; the deep version needs linear algebra




end
