import Mathlib

/-!
# Record-composition product formula: a finite-type model

This file formalizes the multiplicative mechanism in the record-composition formula for
alternating permutations.  `AltPerm n` is the finite type of down-up permutations on `n`
letters.  Thus `Fintype.card (AltPerm n)` is the Euler zigzag number `E_n`.

For a composition `α`, `RecordAssemblyFrom s α` records, at every block, both the choice
of the labels entering that block and an odd alternating permutation internal to it.
Its cardinality is exactly the product occurring in the paper.  The parameter `s` is the
sum of preceding parts; the paper's coefficient is obtained at `s = 0`.
-/

namespace RecordCompositionsAlternating

/-- A permutation is down-up when adjacent comparisons start with `>` and alternate. -/
def IsDownUp {n : ℕ} (p : Equiv.Perm (Fin n)) : Prop :=
  ∀ (i : ℕ) (h : i + 1 < n),
    if Even i then p ⟨i, Nat.lt_trans (Nat.lt_succ_self i) h⟩ > p ⟨i + 1, h⟩
    else p ⟨i, Nat.lt_trans (Nat.lt_succ_self i) h⟩ < p ⟨i + 1, h⟩

/-- The finite type counted by the Euler zigzag number `E_n`. -/
def AltPerm (n : ℕ) := {p : Equiv.Perm (Fin n) // IsDownUp p}

noncomputable instance (n : ℕ) : Fintype (AltPerm n) := by
  classical
  unfold AltPerm
  infer_instance

/-- Euler zigzag numbers, defined here by their standard permutation interpretation. -/
noncomputable def eulerZig (n : ℕ) : ℕ := Fintype.card (AltPerm n)

/-- The product in the record-composition formula, with `s` entries already processed. -/
noncomputable def recordWeightFrom : ℕ → List ℕ → ℕ
  | _, [] => 1
  | s, a :: α =>
      Nat.choose (2 * (s + a) - 1) (2 * a - 1) * eulerZig (2 * a - 1) *
        recordWeightFrom (s + a) α

/-- The coefficient attached to a record composition. -/
noncomputable def recordWeight (α : List ℕ) : ℕ := recordWeightFrom 0 α

/-- A finite combinatorial assembly underlying one record-composition coefficient. -/
def RecordAssemblyFrom : ℕ → List ℕ → Type
  | _, [] => PUnit
  | s, a :: α =>
      Fin (Nat.choose (2 * (s + a) - 1) (2 * a - 1)) ×
        AltPerm (2 * a - 1) × RecordAssemblyFrom (s + a) α

private noncomputable def recordAssemblyFintype (s : ℕ) :
    (α : List ℕ) → Fintype (RecordAssemblyFrom s α)
  | [] => by
      change Fintype PUnit
      infer_instance
  | a :: α => by
      letI := recordAssemblyFintype (s + a) α
      change Fintype (Fin (Nat.choose (2 * (s + a) - 1) (2 * a - 1)) ×
        AltPerm (2 * a - 1) × RecordAssemblyFrom (s + a) α)
      infer_instance

attribute [local instance] recordAssemblyFintype

/-
**Record-composition product theorem.**  The assembly cardinality is
`∏_j binom(2s_j-1,2α_j-1) E_(2α_j-1)`, expressed recursively.
-/
theorem card_recordAssemblyFrom (s : ℕ) (α : List ℕ) :
    Fintype.card (RecordAssemblyFrom s α) = recordWeightFrom s α := by
  induction' α with a α ih generalizing s;
  · rfl;
  · simp +decide [ RecordAssemblyFrom, recordWeightFrom, ih ];
    unfold eulerZig; ring;

/-
The paper's product formula is the `s = 0` specialization.
-/
theorem card_recordAssembly (α : List ℕ) :
    Fintype.card (RecordAssemblyFrom 0 α) = recordWeight α := by
  convert card_recordAssemblyFrom 0 α using 1

/-
Splitting a composition splits its product, with the prefix sum shifting the suffix.
-/
theorem recordWeightFrom_append (s : ℕ) (α β : List ℕ) :
    recordWeightFrom s (α ++ β) =
      recordWeightFrom s α * recordWeightFrom (s + α.sum) β := by
  revert s;
  induction' α with a α ih generalizing β;
  · simp +zetaDelta at *;
    exact fun s => by rw [ show recordWeightFrom s [] = 1 from rfl, one_mul ] ;
  · simp_all +decide [ recordWeightFrom ];
    grind

/-
Consequently the coefficient of a concatenation factors at the cut.
-/
theorem recordWeight_append (α β : List ℕ) :
    recordWeight (α ++ β) =
      recordWeight α * recordWeightFrom α.sum β := by
  convert recordWeightFrom_append 0 α β using 1 ; simp +decide [ recordWeight ]

/-
A one-part record composition has coefficient `E_(2n-1)`: the binomial factor is one.
-/
theorem recordWeight_singleton (n : ℕ) :
    recordWeight [n] = eulerZig (2 * n - 1) := by
  convert card_recordAssemblyFrom 0 [ n ] using 1;
  · exact Eq.symm (card_recordAssembly [n]);
  · cases n <;> simp +decide [ recordWeightFrom ]

/-
Appending one final part gives the explicit last-block recurrence.
-/
theorem recordWeight_snoc (α : List ℕ) (a : ℕ) :
    recordWeight (α ++ [a]) = recordWeight α *
      (Nat.choose (2 * (α.sum + a) - 1) (2 * a - 1) * eulerZig (2 * a - 1)) := by
  unfold recordWeight recordWeightFrom;
  cases α <;> simp_all +decide [ recordWeightFrom_append ];
  · exact mul_one _;
  · simp +decide [ mul_assoc, recordWeightFrom ]

/-
There is exactly one down-up permutation on one letter.
-/
theorem eulerZig_one : eulerZig 1 = 1 := by
  unfold eulerZig;
  unfold AltPerm;
  unfold IsDownUp; simp +decide ;

/-
The first genuinely multi-block coefficient is three.
-/
theorem recordWeight_one_one : recordWeight [1, 1] = 3 := by
  unfold recordWeight; simp +decide [ recordWeightFrom ] ;
  norm_num [ eulerZig_one ]

/-
The assembly cardinality itself factors when a composition is cut.
-/
theorem card_recordAssembly_append (α β : List ℕ) :
    Fintype.card (RecordAssemblyFrom 0 (α ++ β)) =
      Fintype.card (RecordAssemblyFrom 0 α) * recordWeightFrom α.sum β := by
  convert card_recordAssemblyFrom 0 ( α ++ β ) using 1;
  convert recordWeight_append α β |> Eq.symm using 1;
  rw [ ← card_recordAssembly ]

end RecordCompositionsAlternating