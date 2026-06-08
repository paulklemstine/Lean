import Mathlib
import Speculative.MetaComplexity.Defs
import Speculative.MetaComplexity.FiberCount

/-!
# Symmetric KW Witness Theory

## Main Results

1. **Profile existence**: Symmetric Boolean functions factor through Hamming weight.
2. **Counterexample**: The conjectured formula `C(n,k)·C(n,l)·|k-l|` is FALSE.
   We provide a machine-checked counterexample at n=3, t=2.
3. **Correct fiber formula**: For fixed weights (k,l), the witness count is
   `n · C(n-1,k-1)·C(n-1,l) + n · C(n-1,k)·C(n-1,l-1)` (with guards for k=0, l=0).
4. **Threshold lower bounds** via boundary layer injection.
5. **Monotone profile structure**.

## The Counterexample

The conjectured formula `∑ C(n,k)·C(n,l)·|k-l|` fails at n=3, t=2:
- Conjectured: 24
- Actual: 30

The error is that `|k-l|` counts only the *net* coordinate difference,
while KW witnesses count *all* differing coordinates in both orientations.
The correct per-coordinate decomposition yields an additional cross-term.
-/

noncomputable section
open Classical Finset Fintype

namespace MetaComplexity

/-! ## Profile existence for symmetric functions -/

/-
A symmetric function factors through Hamming weight: there exists a profile
`p : Fin (n+1) → Bool` such that `f x = p ⟨hammingWeight x, ...⟩`.
-/
theorem exists_profile_of_isSymmetric
    {n : ℕ} {f : BoolVec n → Bool}
    (hsym : IsSymmetric f) :
    ∃ p : Fin (n + 1) → Bool,
      ∀ x, f x = p ⟨hammingWeight x, Nat.lt_succ_of_le (hammingWeight_le x)⟩ := by
  -- By definition of symmetry, for any two vectors x and y with the same Hamming weight, we have f x = f y.
  have h_symm : ∀ x y : BoolVec n, hammingWeight x = hammingWeight y → f x = f y := by
    exact hsym;
  have h_profile : ∀ k : Fin (n + 1), ∃ val : Bool, ∀ x : BoolVec n, hammingWeight x = k.val → f x = val := by
    intro k
    by_cases hk : ∃ x : BoolVec n, hammingWeight x = k.val;
    · exact ⟨ f hk.choose, fun x hx => h_symm x hk.choose <| hx.trans hk.choose_spec.symm ⟩;
    · exact ⟨ Bool.true, fun x hx => False.elim <| hk ⟨ x, hx ⟩ ⟩;
  choose p hp using h_profile;
  exact ⟨ p, fun x => hp _ _ rfl ⟩

/-! ## Counterexample to the conjectured formula -/

/-- The threshold function for n=3, t=2 has exactly 30 KW witnesses. -/
theorem card_KWWitness_thresh_3_2 :
    Fintype.card (KWWitness (thresholdFn 3 2)) = 30 := by
  decide

/-- The conjectured formula `∑ C(n,k)·C(n,l)·|k-l|` gives 24, not 30. -/
theorem conjectured_formula_gives_24 :
    ∑ k : Fin 4, ∑ l : Fin 4,
      (if (2 ≤ k.val) ∧ (l.val < 2) then
        Nat.choose 3 k.val * Nat.choose 3 l.val * Nat.dist k.val l.val
       else 0) = 24 := by
  decide

/-- **Counterexample**: The conjectured formula does not equal the actual witness count. -/
theorem conjectured_formula_wrong :
    ∑ k : Fin 4, ∑ l : Fin 4,
      (if (2 ≤ k.val) ∧ (l.val < 2) then
        Nat.choose 3 k.val * Nat.choose 3 l.val * Nat.dist k.val l.val
       else 0) ≠
    Fintype.card (KWWitness (thresholdFn 3 2)) := by
  rw [card_KWWitness_thresh_3_2, conjectured_formula_gives_24]; decide

/-! ## Small case verifications -/

theorem card_KWWitness_thresh_1_1 :
    Fintype.card (KWWitness (thresholdFn 1 1)) = 1 := by decide

theorem card_KWWitness_thresh_2_1 :
    Fintype.card (KWWitness (thresholdFn 2 1)) = 4 := by decide

theorem card_KWWitness_thresh_3_1 :
    Fintype.card (KWWitness (thresholdFn 3 1)) = 12 := by decide

/-! ## Monotone profile structure -/

/-
For a monotone Boolean profile, `p(k)=true ∧ p(l)=false` implies `l < k`.
-/
theorem monotone_profile_true_false_imp_lt
    {n : ℕ} {p : Fin (n + 1) → Bool}
    (hmono : ∀ a b : Fin (n + 1), a ≤ b → p a = true → p b = true)
    {k l : Fin (n + 1)}
    (hk : p k = true) (hl : p l = false) : l < k := by
  exact lt_of_not_ge fun h => by have := hmono _ _ h hk; aesop;

/-! ## Threshold witness lower bound -/

/-- Each true/false pair from adjacent boundary layers produces a KW witness. -/
theorem boundary_pair_gives_witness {n t : ℕ} (ht : 1 ≤ t) (_htn : t ≤ n)
    (x : BoolVec n) (hx : hammingWeight x = t)
    (y : BoolVec n) (hy : hammingWeight y = t - 1) :
    ∃ i : Fin n, x i ≠ y i := by
  exact not_forall.mp fun h => by rw [show x = y from funext h] at hx; omega

/-
The boundary layer pair `(t, t-1)` contributes `C(n,t) * C(n,t-1)` witnesses.
-/
theorem choose_mul_choose_le_card_KWWitness_threshold
    {n t : ℕ} (ht0 : 0 < t) (htn : t ≤ n) :
    Nat.choose n t * Nat.choose n (t - 1) ≤
      Fintype.card (KWWitness (thresholdFn n t)) := by
  -- Since $t > 0$, we can choose $i$ such that $x_i = 1$ and $y_i = 0$ for any $x$ in the layer $t$ and $y$ in the layer $t-1$.
  have h_choose_i : ∀ x : BoolVec n, hammingWeight x = t → ∀ y : BoolVec n, hammingWeight y = t - 1 → ∃ i : Fin n, x i ≠ y i := by
    exact?;
  -- Define a function that maps each pair (x, y) from the layers t and t-1 to a KW witness.
  have h_map : ∀ x : BoolVec n, hammingWeight x = t → ∀ y : BoolVec n, hammingWeight y = t - 1 → ∃ w : KWWitness (thresholdFn n t), w.val.1 = x ∧ w.val.2.1 = y := by
    intro x hx y hy; obtain ⟨ i, hi ⟩ := h_choose_i x hx y hy; use ⟨ ( x, y, i ), ?_, ?_, ?_ ⟩ <;> simp_all +decide [ thresholdFn ] ;
  -- By definition of $layer$, we know that $|layer(n, t)| = \binom{n}{t}$ and $|layer(n, t-1)| = \binom{n}{t-1}$.
  have h_layer_card : Finset.card (Finset.filter (fun x : BoolVec n => hammingWeight x = t) Finset.univ) = Nat.choose n t ∧ Finset.card (Finset.filter (fun x : BoolVec n => hammingWeight x = t - 1) Finset.univ) = Nat.choose n (t - 1) := by
    have h_layer_card : ∀ k : ℕ, k ≤ n → Finset.card (Finset.filter (fun x : BoolVec n => hammingWeight x = k) Finset.univ) = Nat.choose n k := by
      intro k hk
      have h_layer_card : Finset.card (Finset.filter (fun x : BoolVec n => hammingWeight x = k) Finset.univ) = Finset.card (Finset.powersetCard k (Finset.univ : Finset (Fin n))) := by
        refine' Finset.card_bij ( fun x hx => Finset.univ.filter fun i => x i = true ) _ _ _ <;> simp +decide [ hammingWeight ];
        · simp +contextual [ funext_iff, Finset.ext_iff ];
        · exact fun b hb => ⟨ fun i => if i ∈ b then Bool.true else Bool.false, by simpa [ Finset.filter_mem_eq_inter, Finset.filter_not ] using hb, by ext i; aesop ⟩;
      rw [ h_layer_card, Finset.card_powersetCard, Finset.card_fin ];
    exact ⟨ h_layer_card t htn, h_layer_card ( t - 1 ) ( Nat.sub_le_of_le_add <| by linarith ) ⟩;
  have h_inj : Finset.card (Finset.image (fun w : KWWitness (thresholdFn n t) => (w.val.1, w.val.2.1)) (Finset.univ.filter (fun w : KWWitness (thresholdFn n t) => hammingWeight w.val.1 = t ∧ hammingWeight w.val.2.1 = t - 1))) ≥ Nat.choose n t * Nat.choose n (t - 1) := by
    rw [ ← h_layer_card.1, ← h_layer_card.2, ← Finset.card_product ];
    refine' Finset.card_le_card _;
    grind +splitImp;
  exact h_inj.trans ( Finset.card_image_le.trans ( Finset.card_le_univ _ ) )

/-! ## Correct exact formula: statement and verification

The correct witness count for a symmetric function with profile `p` is:

  `∑_{k,l} [p(k)=tt ∧ p(l)=ff] · (A(k,l) + B(k,l))`

where:
  `A(k,l) = if k > 0 then n · C(n-1,k-1) · C(n-1,l) else 0`
  `B(k,l) = if l > 0 then n · C(n-1,k) · C(n-1,l-1) else 0`
-/

/-- Computational verification: the correct formula matches for n=3, t=2. -/
theorem correct_formula_check_3_2 :
    ∑ k : Fin 4, ∑ l : Fin 4,
      (if (2 ≤ k.val) ∧ (l.val < 2) then fiberTotal 3 k.val l.val else 0) = 30 := by
  decide

/-- Computational verification: n=2, t=1. -/
theorem correct_formula_check_2_1 :
    ∑ k : Fin 3, ∑ l : Fin 3,
      (if (1 ≤ k.val) ∧ (l.val < 1) then fiberTotal 2 k.val l.val else 0) = 4 := by
  decide

/-
**Correct exact formula for symmetric functions.**
For a symmetric `f` with profile `p`, the total KW witness count is:

  `∑ k l, [p(k)=tt ∧ p(l)=ff] · fiberTotal(n, k, l)`
-/
theorem card_KWWitness_eq_sum_correct
    {n : ℕ} {f : BoolVec n → Bool}
    (p : Fin (n + 1) → Bool)
    (hp : ∀ x, f x = p ⟨hammingWeight x, Nat.lt_succ_of_le (hammingWeight_le x)⟩) :
    Fintype.card (KWWitness f) =
      ∑ k : Fin (n + 1), ∑ l : Fin (n + 1),
        (if p k = true ∧ p l = false then fiberTotal n k.val l.val else 0) := by
  unfold KWWitness;
  -- Apply the definition of `fiberTotal` to rewrite the sum.
  have h_fibertotal : ∀ k l : Fin (n + 1), (if p k = true ∧ p l = false then fiberTotal n k.val l.val else 0) = Fintype.card {w : BoolVec n × BoolVec n × Fin n | hammingWeight w.1 = k.val ∧ hammingWeight w.2.1 = l.val ∧ w.1 w.2.2 ≠ w.2.1 w.2.2 ∧ p k = true ∧ p l = false} := by
    intro k l;
    by_cases hk : p k <;> by_cases hl : p l <;> simp +decide [ hk, hl ];
    convert card_witnessFiber_eq_fiberTotal n k.val l.val ( Nat.le_of_lt_succ k.2 ) ( Nat.le_of_lt_succ l.2 ) |> Eq.symm using 1;
  simp +decide only [hp, h_fibertotal];
  simp +decide only [Fintype.card_subtype];
  simp +decide only [card_filter];
  rw [ ← Finset.sum_product' ];
  rw [ ← Finset.sum_comm ];
  refine' Finset.sum_congr rfl fun x hx => _;
  rw [ Finset.sum_eq_single ( ⟨ ⟨ hammingWeight x.1, Nat.lt_succ_of_le ( hammingWeight_le x.1 ) ⟩, ⟨ hammingWeight x.2.1, Nat.lt_succ_of_le ( hammingWeight_le x.2.1 ) ⟩ ⟩ ) ] <;> simp +decide;
  · grind;
  · grind

/-! ## Threshold specialization -/

/-- The threshold profile. -/
def threshProfile (n t : ℕ) : Fin (n + 1) → Bool :=
  fun k => decide (t ≤ k.val)

theorem threshProfile_spec (n t : ℕ) (x : BoolVec n) :
    thresholdFn n t x = threshProfile n t ⟨hammingWeight x, Nat.lt_succ_of_le (hammingWeight_le x)⟩ := by
  simp [thresholdFn, threshProfile]

/-
**Correct threshold witness formula.**
-/
theorem card_KWWitness_threshold_correct
    {n t : ℕ} (_ht : t ≤ n) :
    Fintype.card (KWWitness (thresholdFn n t)) =
      ∑ k : Fin (n + 1), ∑ l : Fin (n + 1),
        (if t ≤ k.val ∧ l.val < t then fiberTotal n k.val l.val else 0) := by
  convert card_KWWitness_eq_sum_correct (threshProfile n t) (fun x => ?_) using 1;
  · unfold threshProfile; aesop;
  · exact threshProfile_spec n t x

/-! ## Layer cardinality -/

/-
The size of a Hamming layer equals the binomial coefficient.
-/
theorem layer_card_eq_choose (n k : ℕ) (hk : k ≤ n) :
    (layer n k).card = Nat.choose n k := by
  unfold layer;
  convert Finset.card_powersetCard k ( Finset.univ : Finset ( Fin n ) ) using 1;
  · refine' Finset.card_bij ( fun x hx => Finset.univ.filter fun i => x i = true ) _ _ _ <;> simp +decide [ hammingWeight ];
    · intro a₁ ha₁ a₂ ha₂ h; ext i; replace h := Finset.ext_iff.mp h i; aesop;
    · exact fun b hb => ⟨ fun i => if i ∈ b then Bool.true else Bool.false, by simpa [ Finset.filter_mem_eq_inter, Finset.filter_not ] using hb, by ext; aesop ⟩;
  · norm_num

end MetaComplexity

end