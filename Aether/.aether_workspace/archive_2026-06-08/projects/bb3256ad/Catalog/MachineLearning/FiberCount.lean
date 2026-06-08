import Mathlib
import Speculative.MetaComplexity.Defs

/-!
# Weight Fiber Counting for KW Witnesses

This file establishes the counting identity for KW witness fibers:
for fixed weights (k,l), the number of triples (x,y,i) with
|x|=k, |y|=l, x_i≠y_i equals `fiberTotal n k l`.

## Strategy

We decompose by coordinate i. For each fixed i:
- #{x : |x|=k, x_i=true} = C(n-1, k-1)  (when k ≥ 1)
- #{y : |y|=l, y_i=false} = C(n-1, l)
- #{x : |x|=k, x_i=false} = C(n-1, k)  (when k ≤ n-1)
- #{y : |y|=l, y_i=true} = C(n-1, l-1)  (when l ≥ 1)

Then sum over all n coordinates.
-/

noncomputable section
open Classical Finset Fintype

namespace MetaComplexity

/-! ## Counting vectors of fixed weight with a pinned coordinate -/

/-- The set of Boolean vectors of weight k with coordinate i set to true. -/
def weightLayerTrue (n k : ℕ) (i : Fin n) : Finset (BoolVec n) :=
  Finset.univ.filter (fun x => hammingWeight x = k ∧ x i = true)

/-- The set of Boolean vectors of weight k with coordinate i set to false. -/
def weightLayerFalse (n k : ℕ) (i : Fin n) : Finset (BoolVec n) :=
  Finset.univ.filter (fun x => hammingWeight x = k ∧ x i = false)

/-
There are C(n-1, k-1) vectors of weight k with coordinate i true (when k ≥ 1).
-/
theorem card_weightLayerTrue {n : ℕ} (k : ℕ) (i : Fin n) (hk : 0 < k) (hkn : k ≤ n) :
    (weightLayerTrue n k i).card = Nat.choose (n - 1) (k - 1) := by
  have h_bij : {x : Fin n → Bool | hammingWeight x = k ∧ x i = true} ≃ Finset.powersetCard (k - 1) (Finset.univ.erase i) := by
    refine' Equiv.ofBijective ( fun x => ⟨ Finset.filter ( fun j => x.val j = true ) ( Finset.univ.erase i ), _ ⟩ ) ⟨ _, _ ⟩;
    all_goals norm_num [ Function.Injective, Function.Surjective ];
    · have h_card : Finset.card (Finset.filter (fun j => x.val j = true) (Finset.univ.erase i)) = Finset.card (Finset.filter (fun j => x.val j = true) Finset.univ) - 1 := by
        rw [ ← Finset.card_erase_of_mem ( Finset.mem_filter.mpr ⟨ Finset.mem_univ i, x.2.2 ⟩ ), Finset.filter_erase ];
      exact h_card.trans ( congr_arg₂ _ ( x.2.1 ) rfl );
    · simp_all +decide [ Finset.ext_iff, funext_iff ];
      grind;
    · intro a ha hk; use fun j => if j = i then true else j ∈ a; simp_all +decide [ hammingWeight ] ;
      simp_all +decide [ Finset.filter_or, Finset.filter_eq', Finset.subset_iff ];
      exact ⟨ Nat.succ_pred_eq_of_pos ‹_›, by ext x; by_cases hx : x = i <;> aesop ⟩;
  convert Fintype.card_coe ( powersetCard ( k - 1 ) ( Finset.univ.erase i ) ) using 1;
  · convert Fintype.card_congr h_bij;
    exact?;
  · simp +decide [ Finset.card_univ ]

/-
There are C(n-1, k) vectors of weight k with coordinate i false (when k ≤ n-1).
-/
theorem card_weightLayerFalse {n : ℕ} (k : ℕ) (i : Fin n) (hkn : k ≤ n) :
    (weightLayerFalse n k i).card = Nat.choose (n - 1) k := by
  have h_eq : (weightLayerFalse n k i).card = (Finset.univ.filter (fun x : Fin n → Bool => hammingWeight x = k ∧ x i = false)).card := by
    rfl;
  have h_eq : (Finset.univ.filter (fun x : Fin n → Bool => hammingWeight x = k ∧ x i = false)).card = (Finset.univ.filter (fun x : Fin n → Bool => (Finset.univ.filter (fun j => x j = true)).card = k ∧ x i = false)).card := by
    grind;
  have h_eq : (Finset.univ.filter (fun x : Fin n → Bool => (Finset.univ.filter (fun j => x j = true)).card = k ∧ x i = false)).card = (Finset.univ.filter (fun s : Finset (Fin n) => s.card = k ∧ i ∉ s)).card := by
    refine' Finset.card_bij ( fun x hx => Finset.filter ( fun j => x j = true ) Finset.univ ) _ _ _ <;> simp_all +decide;
    · intro a₁ ha₁ ha₂ a₂ ha₃ ha₄ h; ext j; replace h := Finset.ext_iff.mp h j; aesop;
    · intro b hb hi; use fun j => j ∈ b; aesop;
  have h_eq : (Finset.univ.filter (fun s : Finset (Fin n) => s.card = k ∧ i ∉ s)).card = (Finset.powersetCard k (Finset.univ.erase i)).card := by
    congr with s ; simp +contextual [ Finset.subset_iff ];
    tauto;
  simp_all +decide [ Finset.card_univ ]

/-
When k = 0, no vector of weight 0 has coordinate i true.
-/
theorem weightLayerTrue_zero {n : ℕ} (i : Fin n) :
    weightLayerTrue n 0 i = ∅ := by
  -- By definition of weightLayerTrue, if there were any vector x in this set, then hammingWeight x would have to be 0 and x i would be true. But if hammingWeight x is 0, then all coordinates of x are false, including x i. This leads to a contradiction, so the set must be empty.
  ext x
  simp [weightLayerTrue];
  unfold hammingWeight; aesop;

/-
The weight layer partitions into true and false at coordinate i.
-/
theorem weightLayer_partition {n : ℕ} (k : ℕ) (i : Fin n) :
    (layer n k) = weightLayerTrue n k i ∪ weightLayerFalse n k i := by
  unfold layer weightLayerTrue weightLayerFalse; ext; by_cases hi : ‹BoolVec n› i <;> aesop;

theorem weightLayer_disjoint {n : ℕ} (k : ℕ) (i : Fin n) :
    Disjoint (weightLayerTrue n k i) (weightLayerFalse n k i) := by
  exact Finset.disjoint_filter.mpr fun _ _ _ _ => by aesop;

/-! ## The fiber type and its cardinality -/

/-- A witness fiber triple at weights (k,l): a triple (x,y,i) with
    |x|=k, |y|=l, and x_i ≠ y_i. -/
def WitnessFiber (n k l : ℕ) :=
  { w : BoolVec n × BoolVec n × Fin n //
    hammingWeight w.1 = k ∧ hammingWeight w.2.1 = l ∧ w.1 w.2.2 ≠ w.2.1 w.2.2 }

instance (n k l : ℕ) : Fintype (WitnessFiber n k l) := Subtype.fintype _

/-- The "true→false" subfiber: x_i=true, y_i=false. -/
def WitnessFiberTF (n k l : ℕ) :=
  { w : BoolVec n × BoolVec n × Fin n //
    hammingWeight w.1 = k ∧ hammingWeight w.2.1 = l ∧
    w.1 w.2.2 = true ∧ w.2.1 w.2.2 = false }

instance (n k l : ℕ) : Fintype (WitnessFiberTF n k l) := Subtype.fintype _

/-- The "false→true" subfiber: x_i=false, y_i=true. -/
def WitnessFiberFT (n k l : ℕ) :=
  { w : BoolVec n × BoolVec n × Fin n //
    hammingWeight w.1 = k ∧ hammingWeight w.2.1 = l ∧
    w.1 w.2.2 = false ∧ w.2.1 w.2.2 = true }

instance (n k l : ℕ) : Fintype (WitnessFiberFT n k l) := Subtype.fintype _

/-
The witness fiber decomposes into TF and FT subfibers.
-/
theorem card_witnessFiber_eq_TF_plus_FT (n k l : ℕ) :
    Fintype.card (WitnessFiber n k l) =
      Fintype.card (WitnessFiberTF n k l) + Fintype.card (WitnessFiberFT n k l) := by
  rw [ ← Fintype.card_sum ];
  refine' Fintype.card_congr _;
  refine' Equiv.ofBijective _ ⟨ fun x y h => _, fun x => _ ⟩;
  refine' fun x => if hx : x.val.1 x.val.2.2 = true then Sum.inl ⟨ x.val, x.property.1, x.property.2.1, hx, _ ⟩ else Sum.inr ⟨ x.val, x.property.1, x.property.2.1, _, _ ⟩ <;> simp_all +decide [ not_or ];
  grind +locals;
  grind +locals;
  · split_ifs at h <;> simp_all +decide [ Subtype.ext_iff ];
    · exact Subtype.ext <| by injection h;
    · exact Subtype.ext <| by injection h;
  · rcases x with ( ⟨ a, ha ⟩ | ⟨ a, ha ⟩ ) <;> [ refine' ⟨ ⟨ a, ha.1, ha.2.1, _ ⟩, _ ⟩ ; refine' ⟨ ⟨ a, ha.1, ha.2.1, _ ⟩, _ ⟩ ] <;> simp_all +decide [ not_or ]

/-
Counting the TF subfiber: it has n * C(n-1,k-1) * C(n-1,l) elements (when k ≥ 1).
-/
theorem card_witnessFiberTF (n k l : ℕ) (hk : 0 < k) (hkn : k ≤ n) (hln : l ≤ n) :
    Fintype.card (WitnessFiberTF n k l) =
      n * Nat.choose (n - 1) (k - 1) * Nat.choose (n - 1) l := by
  -- By definition of `WitnessFiberTF`, we can build a bijection to the Cartesian product of `Fin n` and the product of `weightLayerTrue` and `weightLayerFalse`.
  have h_bij : WitnessFiberTF n k l ≃ Σ (i : Fin n), weightLayerTrue n k i × weightLayerFalse n l i := by
    refine' Equiv.ofBijective _ ⟨ fun x y h => _, fun x => _ ⟩;
    use fun x => ⟨ x.val.2.2, ⟨ x.val.1, by
      exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, x.2.1, x.2.2.2.1 ⟩ ⟩, ⟨ x.val.2.1, by
      exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, x.2.2.1, x.2.2.2.2 ⟩ ⟩ ⟩
    all_goals generalize_proofs at *;
    · cases x ; cases y ; aesop;
    · rcases x with ⟨ i, ⟨ x, hx ⟩, ⟨ y, hy ⟩ ⟩;
      simp_all +decide [ weightLayerTrue, weightLayerFalse ];
      exact ⟨ ⟨ ⟨ x, y, i ⟩, by
        unfold weightLayerTrue weightLayerFalse at *; aesop; ⟩, rfl, by
        grind ⟩;
  convert Fintype.card_congr h_bij using 1;
  simp +decide [ card_weightLayerTrue, card_weightLayerFalse, hk, hkn, hln ];
  ring

/-
When k = 0, the TF subfiber is empty.
-/
theorem card_witnessFiberTF_zero_k (n l : ℕ) :
    Fintype.card (WitnessFiberTF n 0 l) = 0 := by
  rw [ Fintype.card_eq_zero_iff ];
  constructor;
  rintro ⟨ ⟨ x, y, i ⟩, hx, hy, hxy ⟩;
  simp_all +decide [ hammingWeight ]

/-
Counting the FT subfiber: it has n * C(n-1,k) * C(n-1,l-1) elements (when l ≥ 1).
-/
theorem card_witnessFiberFT (n k l : ℕ) (hl : 0 < l) (hkn : k ≤ n) (hln : l ≤ n) :
    Fintype.card (WitnessFiberFT n k l) =
      n * Nat.choose (n - 1) k * Nat.choose (n - 1) (l - 1) := by
  convert card_witnessFiberTF n l k hl hln hkn using 1;
  · refine' Fintype.card_congr _;
    refine' ⟨ fun x => ⟨ ( x.val.2.1, x.val.1, x.val.2.2 ), _, _, _ ⟩, fun x => ⟨ ( x.val.2.1, x.val.1, x.val.2.2 ), _, _, _ ⟩, fun x => _, fun x => _ ⟩ <;> simp_all +decide [ WitnessFiberFT, WitnessFiberTF ];
    all_goals rcases x with ⟨ ⟨ x, y, i ⟩, hx, hy, hi ⟩ ; aesop;
  · ring

/-
When l = 0, the FT subfiber is empty.
-/
theorem card_witnessFiberFT_zero_l (n k : ℕ) :
    Fintype.card (WitnessFiberFT n k 0) = 0 := by
  -- Apply the fact that k=0 implies the subfiber is empty.
  have h_empty : ∀ w : BoolVec n × BoolVec n × Fin n, ¬(hammingWeight w.1 = k ∧ hammingWeight w.2.1 = 0 ∧ w.1 w.2.2 = false ∧ w.2.1 w.2.2 = true) := by
    simp +contextual [ hammingWeight ];
  convert Fintype.card_eq_zero_iff.mpr ?_;
  exact ⟨ fun w => h_empty w.1 w.2 ⟩

/-
**Main fiber counting theorem**: The total witness fiber count.
-/
theorem card_witnessFiber_eq_fiberTotal (n k l : ℕ) (hkn : k ≤ n) (hln : l ≤ n) :
    Fintype.card (WitnessFiber n k l) = fiberTotal n k l := by
  by_cases hk : 0 < k <;> by_cases hl : 0 < l <;> simp_all +decide [ fiberTotal, fiberTF, fiberFT ];
  · rw [ card_witnessFiber_eq_TF_plus_FT, card_witnessFiberTF n k l hk hkn hln, card_witnessFiberFT n k l hl hkn hln ];
    grind;
  · convert card_witnessFiberTF n k 0 hk hkn ( by linarith ) using 1;
    · convert card_witnessFiber_eq_TF_plus_FT n k 0 using 1;
      simp +decide [ card_witnessFiberFT_zero_l ];
    · aesop;
  · rw [ card_witnessFiber_eq_TF_plus_FT, card_witnessFiberTF_zero_k, card_witnessFiberFT ] <;> aesop;
  · exact Fintype.card_eq_zero_iff.mpr ⟨ by
      rintro ⟨ ⟨ x, y, i ⟩, hx, hy, hxy ⟩ ; simp_all +decide [ hammingWeight ] ; ⟩

end MetaComplexity

end