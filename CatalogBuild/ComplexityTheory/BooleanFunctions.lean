/-! # CatalogBuild.ComplexityTheory.BooleanFunctions

Auto-generated from theorem catalog database.
Domain: ComplexityTheory
Declarations: 32
-/

import Mathlib

noncomputable section

/-- A Boolean function on n variables. -/
abbrev BoolFn (n : ℕ) := (Fin n → Bool) → Bool


/-- The Hamming weight of a Boolean string: the number of positions set to `true`. -/
def hammingWeight {n : ℕ} (x : Fin n → Bool) : ℕ :=
  (Finset.univ.filter fun i => x i = true).card


/-- Hamming distance between two Boolean strings. -/
def hammingDist {n : ℕ} (x y : Fin n → Bool) : ℕ :=
  (Finset.univ.filter fun i => x i ≠ y i).card


/-- Flipping a single bit of a Boolean string. -/
def flipBit {n : ℕ} (x : Fin n → Bool) (i : Fin n) : Fin n → Bool :=
  fun j => if j = i then !x i else x j


/-- Hamming distance is symmetric. -/
theorem hammingDist_comm {n : ℕ} (x y : Fin n → Bool) :
    hammingDist x y = hammingDist y x := by
  unfold hammingDist; congr 1; ext i; simp [ne_comm]


/-- Hamming distance zero iff equal. -/
theorem hammingDist_eq_zero {n : ℕ} {x y : Fin n → Bool} :
    hammingDist x y = 0 ↔ x = y := by
  unfold hammingDist
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  constructor
  · intro h; ext i; exact not_not.mp (h (Finset.mem_univ i))
  · intro h; subst h; simp


/-- Flipping a bit and flipping it back gives the original string. -/
theorem flipBit_flipBit {n : ℕ} (x : Fin n → Bool) (i : Fin n) :
    flipBit (flipBit x i) i = x := by
  ext j; simp [flipBit]; split <;> simp_all


/-- Flipping bit i changes exactly coordinate i. -/
theorem flipBit_support {n : ℕ} (x : Fin n → Bool) (i : Fin n) :
    (Finset.univ.filter fun j => (flipBit x i) j ≠ x j) = {i} := by
  ext j; simp [flipBit]
  by_cases hji : j = i
  · subst hji; simp
  · simp [hji]


/-- The **sensitivity** of `f` at input `x`: the number of coordinates `i`
such that flipping bit `i` changes `f(x)`. -/
def sensitivityAt {n : ℕ} (f : BoolFn n) (x : Fin n → Bool) : ℕ :=
  (Finset.univ.filter fun i => f (flipBit x i) ≠ f x).card


/-- The **sensitivity** of `f`: the maximum of sensitivityAt over all inputs. -/
noncomputable def sensitivity {n : ℕ} (f : BoolFn n) : ℕ :=
  Finset.univ.sup fun x => sensitivityAt f x


/-- Sensitivity at any input is at most n. -/
theorem sensitivityAt_le {n : ℕ} (f : BoolFn n) (x : Fin n → Bool) :
    sensitivityAt f x ≤ n := by
  unfold sensitivityAt
  calc (Finset.univ.filter fun i => f (flipBit x i) ≠ f x).card
      ≤ Finset.univ.card := Finset.card_filter_le _ _
    _ = n := Finset.card_fin n


/-- Sensitivity is at most n. -/
theorem sensitivity_le {n : ℕ} (f : BoolFn n) : sensitivity f ≤ n := by
  unfold sensitivity
  simp [Finset.sup_le_iff]
  exact fun x => sensitivityAt_le f x


/-- The constant function has sensitivity 0. -/
theorem sensitivity_const {n : ℕ} (b : Bool) :
    sensitivity (fun _ : Fin n → Bool => b) = 0 := by
  unfold sensitivity sensitivityAt; simp


/-- A **certificate** for `f` at `x` is a set `S` of coordinates such that
any input `y` agreeing with `x` on `S` satisfies `f(y) = f(x)`. -/
def IsCertificate {n : ℕ} (f : BoolFn n) (x : Fin n → Bool) (S : Finset (Fin n)) : Prop :=
  ∀ y : Fin n → Bool, (∀ i ∈ S, y i = x i) → f y = f x


/-- The full set of coordinates is always a certificate. -/
theorem isCertificate_univ {n : ℕ} (f : BoolFn n) (x : Fin n → Bool) :
    IsCertificate f x Finset.univ := by
  intro y hy
  have : y = x := funext fun i => hy i (Finset.mem_univ i)
  rw [this]


/-- Any superset of a certificate is a certificate. -/
theorem IsCertificate.superset {n : ℕ} {f : BoolFn n} {x : Fin n → Bool}
    {S T : Finset (Fin n)} (hS : IsCertificate f x S) (hST : S ⊆ T) :
    IsCertificate f x T :=
  fun y hy => hS y (fun i hi => hy i (hST hi))


/-- Certificate size is a lower bound on sensitivity at a point:
sensitive bits must be in any certificate. -/
theorem sensitivityAt_le_certificate {n : ℕ} (f : BoolFn n) (x : Fin n → Bool)
    (S : Finset (Fin n)) (hS : IsCertificate f x S) :
    sensitivityAt f x ≤ S.card := by
  unfold sensitivityAt
  apply Finset.card_le_card
  intro i hi
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
  by_contra h_not_mem
  apply hi
  exact hS (flipBit x i) (fun j hj => by
    simp [flipBit]
    intro heq
    exact absurd (heq ▸ hj) h_not_mem)


/-- A Boolean function is **monotone** if x ≤ y pointwise implies f(x) ≤ f(y). -/
def IsMonotone {n : ℕ} (f : BoolFn n) : Prop :=
  ∀ x y : Fin n → Bool, (∀ i, x i = true → y i = true) → f x = true → f y = true


/-- The constant true function is monotone. -/
theorem isMonotone_const_true (n : ℕ) :
    IsMonotone (fun _ : Fin n → Bool => true) :=
  fun _ _ _ h => h


/-- The constant false function is monotone. -/
theorem isMonotone_const_false (n : ℕ) :
    IsMonotone (fun _ : Fin n → Bool => false) :=
  fun _ _ _ h => h


/-- A collection of sets forms a **sunflower** with core `Y` if
every set contains `Y` and every pair of distinct sets intersects exactly at `Y`. -/
def IsSunflower {α : Type*} [DecidableEq α] (fam : Finset (Finset α)) (Y : Finset α) : Prop :=
  ∀ A ∈ fam, Y ⊆ A ∧ ∀ B ∈ fam, A ≠ B → A ∩ B = Y


/-- Disjoint sets form a sunflower with empty core. -/
theorem isSunflower_disjoint {α : Type*} [DecidableEq α]
    (fam : Finset (Finset α))
    (hpw : ∀ A ∈ fam, ∀ B ∈ fam, A ≠ B → Disjoint A B) :
    IsSunflower fam ∅ := by
  intro A hA
  constructor
  · exact Finset.empty_subset A
  · intro B hB hne
    exact Finset.disjoint_iff_inter_eq_empty.mp (hpw A hA B hB hne)


/-- The number of Boolean functions on n variables is 2^(2^n). -/
theorem card_bool_fn (n : ℕ) :
    Fintype.card (BoolFn n) = 2 ^ 2 ^ n := by
  simp [BoolFn, Fintype.card_bool, Fintype.card_fin]


/-- There are exactly 2 Boolean functions on 0 variables. -/
theorem card_bool_fn_zero : Fintype.card (BoolFn 0) = 2 := by
  rw [card_bool_fn]; norm_num


/-- The **influence** of coordinate `i` on function `f`:
the fraction of inputs where flipping bit `i` changes `f`. -/
noncomputable def influence {n : ℕ} (f : BoolFn n) (i : Fin n) : ℚ :=
  (Finset.univ.filter fun x => f (flipBit x i) ≠ f x).card / 2 ^ n


/-- Total influence is the sum of individual influences. -/
noncomputable def totalInfluence {n : ℕ} (f : BoolFn n) : ℚ :=
  ∑ i : Fin n, influence f i


/-- Influence of any coordinate is nonneg. -/
theorem influence_nonneg {n : ℕ} (f : BoolFn n) (i : Fin n) :
    0 ≤ influence f i := by
  unfold influence; positivity


/-- Influence of any coordinate is at most 1. -/
theorem influence_le_one {n : ℕ} (f : BoolFn n) (i : Fin n) :
    influence f i ≤ 1 := by
  unfold influence
  rw [div_le_one (by positivity : (0:ℚ) < 2 ^ n)]
  have h := Finset.card_filter_le (Finset.univ (α := Fin n → Bool)) (fun x => f (flipBit x i) ≠ f x)
  have h2 : (Finset.univ (α := Fin n → Bool)).card = 2 ^ n := by
    simp [Fintype.card_bool, Fintype.card_fin]
  exact_mod_cast (h2 ▸ h)


/-- Total influence of a constant function is 0. -/
theorem totalInfluence_const {n : ℕ} (b : Bool) :
    totalInfluence (fun _ : Fin n → Bool => b) = 0 := by
  unfold totalInfluence influence; simp


/-- The parity function: XOR of all input bits. -/
def parity {n : ℕ} (x : Fin n → Bool) : Bool :=
  (hammingWeight x) % 2 == 1


/-- [Section: ## Parity Function] -/
theorem parity_flipBit {n : ℕ} (x : Fin n → Bool) (i : Fin n) :
    parity (flipBit x i) ≠ parity x := by
  revert i;
  unfold parity;
  unfold hammingWeight;
  intro i; rw [ show ( Finset.univ.filter fun j => flipBit x i j = true ) = Finset.univ.filter ( fun j => x j = true ) \ { i } ∪ if x i = true then ∅ else { i } from ?_ ] ; split_ifs <;> simp_all +decide [ Finset.card_sdiff, Finset.subset_iff ] ;
  · rcases k : Finset.card ( Finset.filter ( fun j => x j = true ) Finset.univ ) with ( _ | _ | k ) <;> simp_all +arith +decide [ Nat.add_mod, Nat.mod_two_of_bodd ];
  · cases Nat.mod_two_eq_zero_or_one ( Finset.card ( Finset.filter ( fun j => x j = true ) Finset.univ ) ) <;> simp +decide [ *, Nat.add_mod ];
  · ext j; by_cases hj : j = i <;> simp +decide [ hj, flipBit ] ;
    · cases x i <;> simp +decide [ * ];
    · aesop


theorem sensitivity_parity_allfalse {n : ℕ} (hn : 0 < n) :
    sensitivityAt parity (fun _ : Fin n => false) = n := by
  rw [ show parity = fun x => ( Finset.univ.filter fun i => x i = true ).card % 2 == 1 from funext fun x => rfl ];
  unfold sensitivityAt;
  unfold flipBit; simp +decide [ Finset.filter_eq', Finset.filter_ne' ] ;


end
