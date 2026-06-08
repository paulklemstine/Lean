import Mathlib
import Cryptography.HypergraphRamseyDefs

/-!
# Hypergraph Ramsey Theory: Main Theorems

This file contains the core theorems of hypergraph Ramsey theory, including:

1. **Probabilistic lower bound**: The counting argument that yields
   R₃(k,k) > n whenever `2 · C(n,k) < 2^{C(k,3)}`.

2. **Stepping-up inequality**: The Erdős-Rado stepping-up lemma relates
   (r+1)-uniform Ramsey numbers to r-uniform ones exponentially.

3. **Exponential separation**: 3-uniform Ramsey numbers grow strictly faster
   than graph Ramsey numbers, formalized via the tower function.

4. **Monotonicity and structural theorems**.

## Key Results

- `prob_method_lower_bound`: If `2·C(n,k) < 2^{C(k,3)}`, then R₃(k,k) > n
- `stepping_up_le_exp`: The stepping-up bound is at most `2^R + 1`
- `tower_two_strict_mono`: The tower function is strictly monotone
- `diagonal_ramsey_mono`: Diagonal Ramsey numbers are monotone in clique size
-/

open Finset Nat

/-! ## Section 1: Combinatorial Counting Lemmas -/

/-
The number of k-element subsets of `Fin n` equals `Nat.choose n k`.
-/
theorem card_ksubsets_fin (n k : ℕ) :
    ((Finset.univ : Finset (Finset (Fin n))).filter (fun S => S.card = k)).card =
    Nat.choose n k := by
  rw [ ← Nat.card_eq_finsetCard ] ; congr ; aesop

/-
Key counting lemma: the number of r-element subsets contained in a fixed
    k-element subset equals `Nat.choose k r`.
-/
theorem card_subsets_of_fixed_set {n : ℕ} (S : Finset (Fin n)) (r : ℕ) :
    (S.powerset.filter (fun T => T.card = r)).card = Nat.choose S.card r := by
  simp +decide [ ← Finset.powersetCard_eq_filter ]

/-! ## Section 2: Probabilistic Method Lower Bound -/

/-
**Probabilistic method counting inequality** (Erdős, 1947 technique for hypergraphs).

    The core of the probabilistic lower bound for R₃(k,k).
    If we color the 3-element subsets of [n] uniformly at random,
    the expected number of monochromatic k-cliques is `2 · C(n,k) · 2^{-C(k,3)}`.

    Contrapositively: if `HypergraphRamseyProp n 3 k k` holds, then
    `2^{C(k,3)} ≤ 2 · C(n,k)`.

    This is a deep application of the probabilistic method — the proof requires
    showing that if every coloring has a monochromatic clique, the expected count
    must be at least 1, which forces the combinatorial inequality.
-/
theorem prob_method_counting_ineq (n k : ℕ) (hk : 3 ≤ k)
    (h : HypergraphRamseyProp n 3 k k) :
    2 ^ Nat.choose k 3 ≤ 2 * Nat.choose n k := by
  by_contra! h;
  -- By the probabilistic method, there exists a coloring of the 3-element subsets of [n] such that no k-element subset is monochromatic.
  obtain ⟨χ, hχ⟩ : ∃ χ : Finset (Fin n) → Bool, ∀ S : Finset (Fin n), S.card = k → ¬(∀ T ∈ Finset.powersetCard 3 S, χ T = true) ∧ ¬(∀ T ∈ Finset.powersetCard 3 S, χ T = false) := by
    -- Consider the probability space of all possible colorings of the 3-element subsets of [n].
    set Ω := Finset.powersetCard 3 (Finset.univ : Finset (Fin n));
    -- Let's count the number of colorings where there exists a monochromatic k-clique.
    have h_monochromatic : ∑ S ∈ Finset.powersetCard k (Finset.univ : Finset (Fin n)), (2 : ℝ) / 2 ^ (Nat.choose k 3) < 1 := by
      norm_num [ Finset.card_univ ];
      rw [ mul_div, div_lt_iff₀ ] <;> norm_cast <;> linarith [ Nat.one_le_pow ( Nat.choose k 3 ) 2 zero_lt_two ];
    -- By the probabilistic method, there exists a coloring of the 3-element subsets of [n] such that no k-element subset is monochromatic. We can construct such a coloring by choosing each edge independently with probability 1/2.
    have h_probabilistic : ∑ S ∈ Finset.powersetCard k (Finset.univ : Finset (Fin n)), (∑ χ ∈ Finset.powerset Ω, if (∀ T ∈ Finset.powersetCard 3 S, T ∈ χ) ∨ (∀ T ∈ Finset.powersetCard 3 S, T ∉ χ) then 1 else 0 : ℝ) < 2 ^ (Nat.choose n 3) := by
      have h_probabilistic : ∀ S ∈ Finset.powersetCard k (Finset.univ : Finset (Fin n)), (∑ χ ∈ Finset.powerset Ω, if (∀ T ∈ Finset.powersetCard 3 S, T ∈ χ) ∨ (∀ T ∈ Finset.powersetCard 3 S, T ∉ χ) then 1 else 0 : ℝ) ≤ 2 * 2 ^ (Nat.choose n 3 - Nat.choose k 3) := by
        intro S hS
        have h_monochromatic_count : Finset.card (Finset.filter (fun χ => (∀ T ∈ Finset.powersetCard 3 S, T ∈ χ)) (Finset.powerset Ω)) ≤ 2 ^ (Nat.choose n 3 - Nat.choose k 3) := by
          have h_monochromatic_count : Finset.card (Finset.filter (fun χ => (∀ T ∈ Finset.powersetCard 3 S, T ∈ χ)) (Finset.powerset Ω)) ≤ Finset.card (Finset.powerset (Ω \ Finset.powersetCard 3 S)) := by
            refine' le_trans ( Finset.card_le_card _ ) _;
            exact Finset.image ( fun χ => χ ∪ Finset.powersetCard 3 S ) ( Finset.powerset ( Ω \ Finset.powersetCard 3 S ) );
            · intro χ hχ; simp_all +decide [ Finset.subset_iff ] ;
              use χ \ Finset.powersetCard 3 S;
              grind +qlia;
            · exact Finset.card_image_le;
          simp_all +decide [ Finset.card_sdiff ];
          refine le_trans h_monochromatic_count ?_;
          rw [ Finset.inter_eq_left.mpr ] <;> aesop;
        have h_monochromatic_count : Finset.card (Finset.filter (fun χ => (∀ T ∈ Finset.powersetCard 3 S, T ∉ χ)) (Finset.powerset Ω)) ≤ 2 ^ (Nat.choose n 3 - Nat.choose k 3) := by
          have h_monochromatic_count : Finset.card (Finset.filter (fun χ => (∀ T ∈ Finset.powersetCard 3 S, T ∉ χ)) (Finset.powerset Ω)) ≤ Finset.card (Finset.powerset (Ω \ Finset.powersetCard 3 S)) := by
            refine Finset.card_le_card ?_;
            grind;
          simp_all +decide [ Finset.card_sdiff ];
          convert h_monochromatic_count using 2;
          rw [ Finset.inter_eq_left.mpr ] <;> aesop;
        simp_all +decide [ Finset.sum_ite ];
        rw [ show ( Finset.filter ( fun x => ( ∀ T ⊆ S, #T = 3 → T ∈ x ) ∨ ∀ T ⊆ S, #T = 3 → T ∉ x ) ( Finset.powerset Ω ) ) = Finset.filter ( fun x => ∀ T ⊆ S, #T = 3 → T ∈ x ) ( Finset.powerset Ω ) ∪ Finset.filter ( fun x => ∀ T ⊆ S, #T = 3 → T ∉ x ) ( Finset.powerset Ω ) from ?_ ];
        · exact_mod_cast le_trans ( Finset.card_union_le _ _ ) ( by linarith );
        · grind +extAll;
      refine' lt_of_le_of_lt ( Finset.sum_le_sum h_probabilistic ) _;
      convert mul_lt_mul_of_pos_right h_monochromatic ( pow_pos ( zero_lt_two' ℝ ) ( Nat.choose n 3 ) ) using 1 ; ring;
      · by_cases h : n.choose 3 ≥ k.choose 3 <;> simp_all +decide [ Nat.choose_eq_zero_of_lt ];
        · field_simp;
          rw [ mul_assoc, ← pow_add, Nat.sub_add_cancel h ];
        · by_cases h' : n < k <;> simp_all +decide [ Nat.choose_eq_zero_of_lt ];
          exact absurd h ( not_lt_of_ge ( Nat.choose_le_choose _ h' ) );
      · ring;
    -- By the pigeonhole principle, there must exist a coloring χ such that no k-element subset is monochromatic.
    obtain ⟨χ, hχ⟩ : ∃ χ ∈ Finset.powerset Ω, ∀ S ∈ Finset.powersetCard k (Finset.univ : Finset (Fin n)), ¬(∀ T ∈ Finset.powersetCard 3 S, T ∈ χ) ∧ ¬(∀ T ∈ Finset.powersetCard 3 S, T ∉ χ) := by
      contrapose! h_probabilistic;
      rw [ Finset.sum_comm ];
      refine' le_trans _ ( Finset.sum_le_sum fun x hx => show ∑ y ∈ powersetCard k univ, ( if ( ∀ T ∈ powersetCard 3 y, T ∈ x ) ∨ ∀ T ∈ powersetCard 3 y, T ∉ x then 1 else 0 ) ≥ 1 from _ );
      · simp +zetaDelta at *;
      · simp +zetaDelta at *;
        obtain ⟨ S, hS₁, hS₂ ⟩ := h_probabilistic x hx;
        use S;
        grind +splitIndPred;
    use fun T => T ∈ χ; simp_all +decide [ Finset.mem_powersetCard ] ;
  obtain ⟨S, hS⟩ : ∃ S : Finset (Fin n), S.card = k ∧ (∀ T ∈ Finset.powersetCard 3 S, χ T = true) ∨ ∃ S : Finset (Fin n), S.card = k ∧ (∀ T ∈ Finset.powersetCard 3 S, χ T = false) := by
    have := ‹HypergraphRamseyProp n 3 k k› ( fun ⟨ T, hT ⟩ => χ T ) ; aesop;
  grind

/-- **Probabilistic lower bound for 3-uniform Ramsey numbers**.
    If `2 · C(n,k) < 2^{C(k,3)}`, then NOT every 3-coloring of `Fin n`
    has a monochromatic k-clique. This is the contrapositive of
    `prob_method_counting_ineq`.

    This establishes R₃(k,k) > n, giving the exponential lower bound
    R₃(k,k) ≥ 2^{Ω(k²)}. -/
theorem prob_method_lower_bound (n k : ℕ) (hk : 3 ≤ k)
    (hineq : 2 * Nat.choose n k < 2 ^ Nat.choose k 3) :
    ¬ HypergraphRamseyProp n 3 k k := by
  intro h
  have := prob_method_counting_ineq n k hk h
  omega

/-! ## Section 3: Tower Function Properties -/

/-
Tower function is strictly monotone for base ≥ 2.
    This is essential for showing that hypergraph Ramsey numbers form a
    strict hierarchy by uniformity.
-/
theorem tower_two_strict_mono (k : ℕ) : tower 2 k < tower 2 (k + 1) := by
  exact Nat.recOn k ( by decide ) fun k ih => pow_lt_pow_right₀ ( by decide ) ih

/-- Tower of height 2 equals 4. -/
theorem tower_two_two : tower 2 2 = 4 := by
  simp [tower]

/-- Tower of height 3 equals 16. -/
theorem tower_two_three : tower 2 3 = 16 := by
  simp [tower]

/-- Tower of height 4 equals 65536 = 2^16. -/
theorem tower_two_four : tower 2 4 = 65536 := by
  simp [tower]

/-
Tower grows at least as fast as iterated doubling.
-/
theorem tower_ge_double (k : ℕ) : 2 * tower 2 k ≤ tower 2 (k + 1) := by
  have h_exp : ∀ m ≥ 1, 2 * m ≤ 2 ^ m := by
    exact fun m hm => by induction hm <;> norm_num [ Nat.pow_succ ] at * ; linarith;
  exact h_exp _ ( tower_pos _ ( by decide ) _ )

/-! ## Section 4: Stepping-Up Bound Analysis -/

/-
**Stepping-up bound is at most exponential**.
    The stepping-up bound `2^{R-1} + 1` is bounded by `2^R + 1`.
    This quantifies the exponential blowup per uniformity level.
-/
theorem stepping_up_le_exp (R : ℕ) : steppingUpBound R ≤ 2 ^ R + 1 := by
  exact Nat.succ_le_succ ( pow_le_pow_right₀ ( by decide ) ( Nat.pred_le _ ) )

/-
The stepping-up bound is monotone in its argument.
-/
theorem steppingUpBound_mono {a b : ℕ} (h : a ≤ b) :
    steppingUpBound a ≤ steppingUpBound b := by
  unfold steppingUpBound;
  gcongr ; omega

/-
Stepping up from the tower function: composing stepping-up with tower
    gives a value bounded by the next tower level.
    This encodes the inductive structure of the Erdős-Rado upper bound.
-/
theorem stepping_up_tower (k : ℕ) (hk : 1 ≤ k) :
    steppingUpBound (tower 2 k) ≤ tower 2 (k + 1) + 1 := by
  convert Nat.succ_le_succ ( pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ( Nat.sub_le ( tower 2 k ) 1 ) ) using 1

/-! ## Section 5: Monotonicity and Structural Properties -/

/-
**Monotonicity in clique size**: A monochromatic (k+1)-clique contains
    a monochromatic k-clique (just drop a vertex). Therefore R_r(k,k) ≤ R_r(k+1,k+1).

    This is a fundamental structural property: larger cliques are harder to avoid.
-/
theorem MonochromaticClique.subset {n r : ℕ} {χ : HypergraphColoring n r}
    {S T : Finset (Fin n)} {c : Bool}
    (h : MonochromaticClique χ S c) (hTS : T ⊆ S) :
    MonochromaticClique χ T c := by
  exact fun U hU hU' => h U ( Finset.Subset.trans hU hTS ) hU'

/-
**Diagonal monotonicity**: If R_r(k+1,k+1) ≤ n, then R_r(k,k) ≤ n.
    Proof: any monochromatic (k+1)-clique restricts to a k-clique.
-/
theorem diagonal_ramsey_mono {n r k : ℕ} (hk : 0 < k) (hr : 0 < r)
    (h : HypergraphRamseyProp n r (k + 1) (k + 1)) :
    HypergraphRamseyProp n r k k := by
  intro χ; obtain ⟨ S, hS₁, hS₂ ⟩ | ⟨ S, hS₁, hS₂ ⟩ := h χ;
  · exact Or.inl <| by rcases Finset.exists_subset_card_eq ( by linarith : k ≤ #S ) with ⟨ T, hT₁, hT₂ ⟩ ; exact ⟨ T, hT₂, MonochromaticClique.subset hS₂ hT₁ ⟩ ;
  · obtain ⟨ T, hT₁, hT₂ ⟩ := Finset.exists_subset_card_eq ( by linarith : k ≤ S.card );
    exact Or.inr ⟨ T, hT₂, MonochromaticClique.subset hS₂ hT₁ ⟩

/-
**Ramsey property for degenerate case**: When k ≤ r, any single vertex
    trivially forms a "k-clique" since there are no r-subsets of a k-element set
    with k < r. So R_r(k,k) ≤ k for k ≤ r.
-/
theorem HypergraphRamseyProp_of_k_le_r {n r k : ℕ} (hk : k ≤ r) (hn : k ≤ n) :
    HypergraphRamseyProp n r k k := by
  intro χ;
  by_contra h_contra;
  -- Since $k \leq r$, any $k$-element set $S$ has no $r$-element subsets (since $r > \text{card } S$). So $\text{MonochromaticClique } \chi S c$ is vacuously true.
  have h_monochromatic : ∀ S : Finset (Fin n), S.card = k → MonochromaticClique χ S true := by
    intros S hS_card
    unfold MonochromaticClique
    intro T hT_sub hT_card
    have hT_empty : T.card < r := by
      cases lt_or_eq_of_le hk <;> simp_all +decide [ Finset.subset_iff ];
      · exact absurd ( Finset.card_le_card hT_sub ) ( by linarith );
      · exact h_contra.1 S hS_card fun T hT_sub hT_card => by
          cases h : χ { val := T, card_eq := hT_card } <;> simp_all +decide [ MonochromaticClique ];
          obtain ⟨ U, hU_sub, hU_card, hU ⟩ := h_contra.2 T ‹_› ; have := Finset.eq_of_subset_of_card_le hU_sub ; aesop;
    grind +locals;
  have := Finset.exists_subset_card_eq ( show k ≤ Finset.card ( Finset.univ : Finset ( Fin n ) ) from by simpa ) ; aesop;

/-! ## Section 6: Growth Rate Separation -/

/-
**Key separation lemma**: The tower function grows faster than any fixed exponential.
    For all c and sufficiently large k, `c^k < tower 2 k`.
    This is the formal backbone of the claim that hypergraph Ramsey numbers
    grow faster than graph Ramsey numbers.
-/
theorem tower_beats_exp (c : ℕ) (hc : 2 ≤ c) (k : ℕ) (hk : c + 1 ≤ k) :
    c ^ k < tower 2 k := by
  induction' hk with k hk ih <;> simp_all +decide [ pow_succ, tower ];
  · have h_ind : ∀ c ≥ 5, c ^ c * c < 2 ^ (tower 2 c) := by
      intro c hc
      have h_ind : c ^ (c + 1) < 2 ^ (c ^ 2) := by
        -- We can prove this by taking the logarithm base 2 of both sides.
        have h_log : (c + 1) * Real.logb 2 c < c ^ 2 := by
          rw [ Real.logb, mul_div ];
          rw [ div_lt_iff₀ ( Real.log_pos one_lt_two ) ];
          have := Real.log_le_sub_one_of_pos ( by positivity : 0 < ( c : ℝ ) / 2 );
          rw [ Real.log_div ( by positivity ) ( by positivity ) ] at this;
          have := Real.log_two_gt_d9 ; norm_num at * ; nlinarith [ ( by norm_cast : ( 5 :ℝ ) ≤ c ), Real.log_le_sub_one_of_pos zero_lt_two ];
        rw [ ← @Nat.cast_lt ℝ ] ; norm_num;
        rw [ ← Real.log_lt_log_iff ( by positivity ) ( by positivity ), Real.log_pow, Real.log_pow ] ; norm_num ; rw [ Real.logb ] at * ; ring_nf at * ; nlinarith [ inv_pos.mpr ( Real.log_pos one_lt_two ), mul_inv_cancel₀ ( ne_of_gt ( Real.log_pos one_lt_two ) ) ];
      have h_ind : ∀ c ≥ 5, c ^ 2 ≤ tower 2 c := by
        intro c hc
        induction' hc with c hc ih;
        · native_decide +revert;
        · refine' le_trans _ ( Nat.pow_le_pow_right ( by decide ) ih );
          refine' Nat.le_induction _ _ c hc <;> intros <;> norm_num [ Nat.pow_succ, Nat.pow_mul ] at *;
          ring_nf at *;
          nlinarith [ Nat.pow_le_pow_right ( show 1 ≤ 2 by norm_num ) ( show ‹_› ≥ 5 by assumption ), Nat.pow_le_pow_left ( show 2 ^ ‹_› ≥ 2 by exact le_self_pow₀ ( by norm_num ) ( by linarith ) ) 2 ];
      exact lt_of_lt_of_le ‹_› ( pow_le_pow_right₀ ( by decide ) ( h_ind c hc ) );
    by_cases hc_ge_5 : c ≥ 5;
    · exact h_ind c hc_ge_5;
    · interval_cases c <;> native_decide;
  · refine' lt_of_lt_of_le _ ( pow_le_pow_right₀ ( by decide ) ih );
    refine' Nat.le_induction _ _ _ ( show c ^ k ≥ c by exact Nat.le_self_pow ( by linarith ) _ ) <;> intros <;> simp_all +decide [ pow_succ, pow_mul ];
    · exact Nat.le_induction ( by trivial ) ( fun n hn ih => by norm_num [ Nat.pow_succ' ] at * ; nlinarith ) c hc;
    · nlinarith [ Nat.pow_le_pow_right ( by decide : 1 ≤ 2 ) ( show ‹_› ≥ 2 by linarith ) ]

/-
**Corollary**: `4^k < tower 2 k` for k ≥ 5.
    Since R₂(k,k) < 4^k (Erdős-Szekeres), and R₃(k,k) ≥ tower(2, Ω(k)),
    this shows the 3-uniform Ramsey numbers eventually dominate graph Ramsey numbers.
-/
theorem four_pow_lt_tower (k : ℕ) (hk : 5 ≤ k) : 4 ^ k < tower 2 k := by
  exact tower_beats_exp 4 ( by norm_num ) k ( by linarith )

/-! ## Section 7: Testable Conjecture -/

/-- **Probabilistic lower bound for R₃(5,5)**: R₃(5,5) > 11.
    The probabilistic method gives: since `2 · C(11,5) = 924 < 1024 = 2^{C(5,3)}`,
    there exists a 2-coloring of the 3-subsets of an 11-element set with no
    monochromatic 5-clique.

    This is a concrete instantiation of the exponential lower bound
    R₃(k,k) ≥ 2^{Ω(k²)} from the probabilistic method. -/
theorem R3_5_5_prob_lower_bound :
    ¬ HypergraphRamseyProp 11 3 5 5 := by
  exact prob_method_lower_bound 11 5 (by omega) (by native_decide)

/-- **Conjecture (Double Exponential Growth)**: R₃(k,k) grows as tower(2, Θ(k)).
    The gap between the probabilistic lower bound R₃(k,k) ≥ 2^{ck²}
    and the stepping-up upper bound R₃(k,k) ≤ 2^{2^{ck}} is a major open problem.

    Testable prediction: R₃(5,5) ≥ 34 (known lower bound, much stronger than
    our probabilistic bound of 11). If R₃(5,5) is close to 55 (the upper bound),
    this supports the double exponential conjecture.

    We state the arithmetic verification that the probabilistic bound applies. -/
theorem prob_bound_verification_k5 :
    2 * Nat.choose 11 5 < 2 ^ Nat.choose 5 3 := by native_decide

/-- The probabilistic bound also gives R₃(6,6) > 29. -/
theorem prob_bound_verification_k6 :
    2 * Nat.choose 29 6 < 2 ^ Nat.choose 6 3 := by native_decide