import Mathlib

/-!
# Lawvere Metric Coding Theorem for Proof Semirings

This file establishes a coding-theoretic bridge between closure-generated proof
semirings and information theory, via the Kraft inequality for prefix-free codes
and the Gibbs variational principle.

## Main results

* `kraft_inequality_binary` — the binary Kraft inequality: for any prefix-free
  code over `{0,1}`, the sum of `2^{-|w|}` over codewords is at most 1.
* `kraft_inequality_binary_nat` — the integer form: for codewords of length ≤ N,
  `∑ 2^{N - |w|} ≤ 2^N`.
* `freeEnergy_variational_le_log_partition` — the Gibbs variational upper bound.
* `lawvere_proof_coding_theorem` — the Kraft inequality on a Lawvere coding model.
* `lawvere_capacity_bound` — the variational compression bound for proof families.
-/

open Finset Real

namespace Bridges.ProofSemiringCoding

/-! ## Section 1: Prefix codes -/

/-- A list `u` is a prefix of a list `v` if there exists `t` such that `u ++ t = v`. -/
def IsPrefix (u v : List Bool) : Prop := ∃ t, u ++ t = v

/-- A finite set of binary words is prefix-free if no distinct pair has one
    word a prefix of the other. -/
def PrefixFree (C : Finset (List Bool)) : Prop :=
  ∀ ⦃u⦄, u ∈ C → ∀ ⦃v⦄, v ∈ C → u ≠ v → ¬ IsPrefix u v

/-- The Kraft weight of a binary codeword: `2^{-|w|}`. -/
noncomputable def kraftWeight (w : List Bool) : ℝ := (2 : ℝ) ^ (-(w.length : ℤ))

/-- The Kraft sum of a finite set of binary codewords. -/
noncomputable def kraftSum (C : Finset (List Bool)) : ℝ :=
  ∑ w ∈ C, kraftWeight w

/-! ## Section 2: Extensions and counting -/

/-- All binary words of a given length. -/
def allWords : ℕ → Finset (List Bool)
  | 0 => {[]}
  | n + 1 => (allWords n).biUnion (fun w => {w ++ [true], w ++ [false]})

/-- The set of all binary extensions of `w` to total length `N`. -/
def extensionsToLength (w : List Bool) (N : ℕ) : Finset (List Bool) :=
  (allWords N).filter (fun v => w <+: v)

theorem mem_allWords_iff (v : List Bool) (N : ℕ) :
    v ∈ allWords N ↔ v.length = N := by
      induction' N with N ih generalizing v <;> simp_all +decide [ allWords ];
      induction v using List.reverseRecOn <;> aesop

theorem card_allWords (N : ℕ) : (allWords N).card = 2 ^ N := by
  induction N <;> simp_all +decide [ pow_succ', allWords ];
  rw [ Finset.card_biUnion ];
  · simp_all +decide [ mul_comm ];
  · intro w hw w' hw' hww'; simp_all +decide [ Finset.disjoint_left ] ;

theorem mem_extensionsToLength_iff (w v : List Bool) (N : ℕ) :
    v ∈ extensionsToLength w N ↔ v ∈ allWords N ∧ w <+: v := by
  simp [extensionsToLength, Finset.mem_filter]

theorem card_extensionsToLength
    (w : List Bool) (N : ℕ) (h : w.length ≤ N) :
    (extensionsToLength w N).card = 2 ^ (N - w.length) := by
      apply le_antisymm;
      · -- By definition of $extensionsToLength$, we know that every element in $extensionsToLength w N$ is of the form $w ++ t$ where $t$ is a binary word of length $N - w.length$.
        have h_extensions : ∀ v ∈ extensionsToLength w N, ∃ t : List Bool, v = w ++ t ∧ t.length = N - w.length := by
          intro v hv
          obtain ⟨hv_mem, hv_prefix⟩ := (mem_extensionsToLength_iff w v N).mp hv
          obtain ⟨t, ht⟩ := hv_prefix;
          have := mem_allWords_iff v N |>.1 hv_mem; aesop;
        -- Since there are $2^{N - w.length}$ binary words of length $N - w.length$, the number of elements in $extensionsToLength w N$ is at most $2^{N - w.length}$.
        have h_card : (extensionsToLength w N).card ≤ Finset.card (Finset.image (fun t : List Bool => w ++ t) (allWords (N - w.length))) := by
          refine Finset.card_le_card ?_;
          intro v hv; obtain ⟨ t, rfl, ht ⟩ := h_extensions v hv; exact Finset.mem_image.mpr ⟨ t, by rw [ mem_allWords_iff ] ; aesop ⟩ ;
        exact h_card.trans ( Finset.card_image_le.trans ( by rw [ card_allWords ] ) );
      · rw [ ← card_allWords, ← Finset.card_image_of_injective _ ( show Function.Injective ( fun t => w ++ t ) from fun a b h => by simpa using h ) ];
        refine Finset.card_le_card ?_;
        grind +suggestions

theorem disjoint_extensions_of_not_prefix (u v : List Bool) (N : ℕ)
    (huv : ¬ u <+: v) (hvu : ¬ v <+: u) :
    Disjoint (extensionsToLength u N) (extensionsToLength v N) := by
      unfold extensionsToLength;
      simp_all +decide [ Finset.disjoint_left, List.prefix_iff_eq_take ];
      grind

/-! ## Section 3: Kraft inequality (integer and real forms) -/

/-
**Integer Kraft inequality**: for codewords of length ≤ N in a prefix-free code,
    the sum of `2^{N - |w|}` over codewords is at most `2^N`.
-/
theorem kraft_inequality_binary_nat
    (C : Finset (List Bool)) (hC : PrefixFree C) (N : ℕ)
    (hN : ∀ w ∈ C, w.length ≤ N) :
    ∑ w ∈ C, 2 ^ (N - w.length) ≤ 2 ^ N := by
      -- For each $w \in C$, the set $extensionsToLength w N$ has cardinality $2^{N - w.length}$ by `card_extensionsToLength`.
      have h_card_extensions : ∀ w ∈ C, (extensionsToLength w N).card = 2 ^ (N - w.length) := by
        exact?;
      rw [ ← Finset.sum_congr rfl h_card_extensions ];
      nontriviality;
      rw [ ← card_allWords ];
      refine' le_trans _ ( Finset.card_le_card <| Finset.biUnion_subset.mpr _ );
      rw [ Finset.card_biUnion ];
      · intro u hu v hv huv; exact disjoint_extensions_of_not_prefix u v N ( by
          exact fun h => hC hu hv huv <| by exact ⟨ _, h.choose_spec ⟩ ; ) ( by
          exact fun h => hC hv hu huv.symm <| by obtain ⟨ t, rfl ⟩ := h; exact ⟨ t, rfl ⟩ ; ) ;
      · exact fun w hw => fun x hx => Finset.mem_filter.mp hx |>.1

/-
**Binary Kraft Inequality**: For any prefix-free code `C` over `{0,1}`,
    the sum `∑_{w ∈ C} 2^{-|w|}` is at most 1.
-/
theorem kraft_inequality_binary
    (C : Finset (List Bool)) (hC : PrefixFree C) :
    kraftSum C ≤ 1 := by
      -- Let $N$ be the maximum length of the codewords in $C$.
      set N := Finset.sup C (fun w => w.length) with hN_def;
      -- By definition of $N$, we know that for all $w \in C$, $w.length \leq N$.
      have hN_le : ∀ w ∈ C, w.length ≤ N := by
        exact fun w hw => Finset.le_sup ( f := fun w => w.length ) hw;
      convert div_le_one_of_le₀ ( show ( ∑ w ∈ C, 2 ^ ( N - w.length ) : ℝ ) ≤ 2 ^ N from ?_ ) ( by positivity : ( 0 : ℝ ) ≤ 2 ^ N ) using 1;
      · rw [ Finset.sum_div _ _ _ ] ; refine' Finset.sum_congr rfl fun x hx => _ ; rw [ eq_div_iff ( by positivity ) ] ; norm_cast ; simp +decide [ ← pow_add, hN_le x hx ] ;
        unfold kraftWeight; norm_num [ zpow_sub₀, zpow_add₀ ] ; ring;
        rw [ inv_pow, inv_mul_eq_div, div_eq_iff ( by positivity ), ← pow_add, Nat.sub_add_cancel ( hN_le x hx ) ];
      · exact_mod_cast kraft_inequality_binary_nat C hC N hN_le

/-! ## Section 4: Proof code profiles and free-energy weights -/

/-- An abstract coding profile for proof objects. -/
structure ProofCodeProfile (α : Type*) where
  carrier : Finset α
  word : α → List Bool
  cost : α → ℝ
  prefix_free : PrefixFree (carrier.image word)
  cost_eq_length : ∀ a ∈ carrier, cost a = (word a).length
  word_injective : Set.InjOn word (↑carrier)

/-- Free-energy weight with inverse temperature: `exp(-β · cost(a))`. -/
noncomputable def freeEnergyWeightβ {α : Type*} (β : ℝ) (P : ProofCodeProfile α) (a : α) : ℝ :=
  Real.exp (- β * P.cost a)

/-
The Kraft inequality for proof families with `β = log 2`.
-/
theorem proof_family_kraft_exp
    {α : Type*} [DecidableEq α] (P : ProofCodeProfile α) :
    ∑ a ∈ P.carrier, freeEnergyWeightβ (Real.log 2) P a ≤ 1 := by
      -- Rewrite the free-energy weights in terms of the lengths of the words.
      have h_rewrite : ∑ a ∈ P.carrier, freeEnergyWeightβ (Real.log 2) P a = ∑ w ∈ P.carrier.image P.word, kraftWeight w := by
        rw [ Finset.sum_image ];
        · unfold freeEnergyWeightβ kraftWeight;
          refine' Finset.sum_congr rfl fun x hx => _;
          rw [ P.cost_eq_length x hx, ← Real.rpow_intCast, Real.rpow_def_of_pos ] <;> norm_num;
        · exact P.word_injective;
      exact h_rewrite ▸ kraft_inequality_binary _ P.prefix_free

/-! ## Section 5: Variational free-energy bound -/

/-- Expected cost of a distribution `p` on a finite set. -/
noncomputable def expectedCost {α : Type*} (s : Finset α) (p : α → ℝ) (c : α → ℝ) : ℝ :=
  ∑ a ∈ s, p a * c a

/-- The free-energy objective: `-β · E[c] + H(p)`. -/
noncomputable def freeEnergyObjective {α : Type*} (β : ℝ) (s : Finset α)
    (p : α → ℝ) (c : α → ℝ) : ℝ :=
  (- β * expectedCost s p c) - ∑ a ∈ s, p a * Real.log (p a)

/-- A probability distribution supported on a finite set. -/
def IsFiniteProb {α : Type*} (s : Finset α) (p : α → ℝ) : Prop :=
  (∀ a ∈ s, 0 ≤ p a) ∧ (∑ a ∈ s, p a = 1)

/-
**Gibbs Variational Upper Bound**: The free-energy objective is bounded by
    the log-partition function.
-/
theorem freeEnergy_variational_le_log_partition
    {α : Type*} [DecidableEq α]
    (s : Finset α) (c : α → ℝ) (β : ℝ)
    (p : α → ℝ) (hp : IsFiniteProb s p) :
    freeEnergyObjective β s p c ≤
      Real.log (∑ a ∈ s, Real.exp (- β * c a)) := by
        by_cases h : ∃ x ∈ s, p x ≠ 0 <;> simp_all +decide [ IsFiniteProb, expectedCost, freeEnergyObjective, Finset.sum_eq_zero_iff_of_nonneg, Real.exp_nonneg ];
        -- Apply Jensen's inequality for the convex function $\varphi(x) = e^x$.
        have h_jensen : (∑ a ∈ s, p a * Real.exp (-(β * c a) - Real.log (p a))) ≥ Real.exp (∑ a ∈ s, p a * (-(β * c a) - Real.log (p a))) := by
          have h_jensen : ConvexOn ℝ (Set.univ : Set ℝ) Real.exp := by
            exact convexOn_exp;
          apply ConvexOn.map_sum_le h_jensen;
          · exact hp.1;
          · exact hp.2;
          · exact fun _ _ => Set.mem_univ _;
        simp_all +decide [ mul_sub, ← mul_assoc, ← Finset.sum_mul _ _ _, Real.exp_sub, Real.exp_log_eq_abs ];
        -- Simplify the right-hand side of Jensen's inequality.
        have h_simplify : ∑ x ∈ s, p x * (Real.exp (-(β * c x)) / Real.exp (Real.log (p x))) ≤ ∑ x ∈ s, Real.exp (-(β * c x)) := by
          refine' Finset.sum_le_sum fun x hx => _;
          by_cases hpx : p x = 0 <;> simp_all +decide [ Real.exp_log_eq_abs, mul_div_cancel₀ ];
          · positivity;
          · rw [ abs_of_nonneg ( hp.1 x hx ), mul_div_cancel₀ _ hpx ];
        have := Real.log_le_log ( div_pos ( Real.exp_pos _ ) ( Real.exp_pos _ ) ) ( h_jensen.trans h_simplify ) ; simp_all +decide [ Real.log_div, Real.exp_ne_zero, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] ;

/-- The Gibbs distribution. -/
noncomputable def gibbsProb {α : Type*} [DecidableEq α]
    (s : Finset α) (c : α → ℝ) (β : ℝ) (a : α) : ℝ :=
  Real.exp (- β * c a) / (∑ x ∈ s, Real.exp (- β * c x))

/-! ## Section 6: Lawvere coding model and bridge theorems -/

/-- A Lawvere coding model for proof objects. -/
structure LawvereCodingModel (α : Type*) where
  carrier : Finset α
  cost : α → ℝ
  code : α → List Bool
  prefix_free : PrefixFree (carrier.image code)
  cost_eq_length : ∀ a ∈ carrier, cost a = (code a).length
  code_injective : Set.InjOn code (↑carrier)
  closed_under_closure : Prop

/-- **Lawvere Proof Coding Theorem**: `∑ exp(-cost · log 2) ≤ 1`. -/
theorem lawvere_proof_coding_theorem
    {α : Type*} [DecidableEq α] (M : LawvereCodingModel α) :
    (∑ a ∈ M.carrier, Real.exp (- (M.cost a) * Real.log 2)) ≤ 1 := by
  let P : ProofCodeProfile α := {
    carrier := M.carrier
    word := M.code
    cost := M.cost
    prefix_free := M.prefix_free
    cost_eq_length := M.cost_eq_length
    word_injective := M.code_injective
  }
  have h := proof_family_kraft_exp P
  refine le_trans ?_ h
  apply le_of_eq
  apply Finset.sum_congr rfl
  intro a _
  simp only [freeEnergyWeightβ]
  congr 1; ring

/-- **Lawvere Capacity Bound**: The variational compression bound. -/
theorem lawvere_capacity_bound
    {α : Type*} [DecidableEq α]
    (M : LawvereCodingModel α)
    (p : α → ℝ)
    (hp : IsFiniteProb M.carrier p) :
    (- (Real.log 2) * expectedCost M.carrier p M.cost
      - ∑ a ∈ M.carrier, p a * Real.log (p a))
    ≤ Real.log (∑ a ∈ M.carrier, Real.exp (- (Real.log 2) * M.cost a)) := by
  exact freeEnergy_variational_le_log_partition M.carrier M.cost (Real.log 2) p hp

end Bridges.ProofSemiringCoding