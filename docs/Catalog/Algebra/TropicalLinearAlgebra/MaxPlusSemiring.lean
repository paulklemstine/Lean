/-
# The max-plus (tropical) semiring

We construct the tropical semiring `(R ∪ {-∞}, max, +)` as a type synonym
`MaxPlus R := WithBot R` for a linearly ordered additive commutative monoid `R`
(the motivating case being `R = ℝ`), equip it with a `CommSemiring` structure,
and record its characteristic tropical features:

* it is **idempotent**: `a + a = a`;
* it is **zero-sum-free**: `a + b = 0 → a = 0 ∧ b = 0`, so (for nontrivial `R`)
  it admits no additive inverses and is genuinely not a ring;
* finite tropical sums are suprema (`toBot_sum`);
* consequently tropical matrix multiplication is the `max`-of-sums formula and
  is associative.
-/
import Mathlib

namespace TropicalLA

/-- Carrier of the max-plus (tropical) semiring: `R ∪ {-∞}`. -/
def MaxPlus (R : Type*) : Type _ := WithBot R

namespace MaxPlus

/-- The identification `R ∪ {-∞} → MaxPlus R`. -/
def ofBot {R : Type*} (x : WithBot R) : MaxPlus R := x

/-- The identification `MaxPlus R → R ∪ {-∞}`. -/
def toBot {R : Type*} (x : MaxPlus R) : WithBot R := x

@[simp] theorem toBot_ofBot {R : Type*} (x : WithBot R) : toBot (ofBot x) = x := rfl
@[simp] theorem ofBot_toBot {R : Type*} (x : MaxPlus R) : ofBot (toBot x) = x := rfl

theorem ofBot_injective {R : Type*} : Function.Injective (ofBot (R := R)) := fun _ _ h => h

instance {R : Type*} : Zero (MaxPlus R) := ⟨ofBot ⊥⟩
instance {R : Type*} [Zero R] : One (MaxPlus R) := ⟨ofBot ((0 : R) : WithBot R)⟩
/-- Tropical addition is `max`. -/
instance {R : Type*} [LinearOrder R] : Add (MaxPlus R) :=
  ⟨fun a b => ofBot (max (toBot a) (toBot b))⟩
/-- Tropical multiplication is ordinary addition. -/
instance {R : Type*} [Add R] : Mul (MaxPlus R) := ⟨fun a b => ofBot (toBot a + toBot b)⟩

@[simp] theorem toBot_add {R : Type*} [LinearOrder R] (a b : MaxPlus R) :
    toBot (a + b) = max (toBot a) (toBot b) := rfl
@[simp] theorem toBot_mul {R : Type*} [Add R] (a b : MaxPlus R) :
    toBot (a * b) = toBot a + toBot b := rfl
@[simp] theorem toBot_zero {R : Type*} : toBot (0 : MaxPlus R) = ⊥ := rfl
@[simp] theorem toBot_one {R : Type*} [Zero R] :
    toBot (1 : MaxPlus R) = ((0 : R) : WithBot R) := rfl

variable {R : Type*} [AddCommMonoid R] [LinearOrder R] [IsOrderedAddMonoid R]

instance : CommSemiring (MaxPlus R) where
  add_assoc a b c := congrArg ofBot (max_assoc _ _ _)
  zero_add a := congrArg ofBot (max_eq_right bot_le)
  add_zero a := congrArg ofBot (max_eq_left bot_le)
  add_comm a b := congrArg ofBot (max_comm _ _)
  mul_assoc a b c := congrArg ofBot (add_assoc _ _ _)
  one_mul a := congrArg ofBot (zero_add (toBot a))
  mul_one a := congrArg ofBot (add_zero (toBot a))
  mul_comm a b := congrArg ofBot (add_comm _ _)
  left_distrib a b c := congrArg ofBot (add_max (toBot a) (toBot b) (toBot c))
  right_distrib a b c := congrArg ofBot (max_add (toBot a) (toBot b) (toBot c))
  zero_mul a := congrArg ofBot (WithBot.bot_add (toBot a))
  mul_zero a := congrArg ofBot (WithBot.add_bot (toBot a))
  nsmul := nsmulRec

/-- Tropical addition is idempotent: the max-plus semiring is an *idempotent* semiring. -/
@[simp] theorem add_self {R : Type*} [LinearOrder R] (a : MaxPlus R) : a + a = a :=
  congrArg ofBot (max_self _)

/-- The tropical order: `a ≤ b` iff `a + b = b`. -/
theorem add_eq_right_iff_le {R : Type*} [LinearOrder R] (a b : MaxPlus R) :
    a + b = b ↔ toBot a ≤ toBot b := by
  constructor
  · intro h
    have h' : max (toBot a) (toBot b) = toBot b := congrArg toBot h
    exact h' ▸ le_max_left (toBot a) (toBot b)
  · intro h
    exact congrArg ofBot (max_eq_right h)

/-- The max-plus semiring is **zero-sum-free**: a tropical sum vanishes only if both
summands do.  In particular no nonzero element has an additive inverse. -/
theorem eq_zero_of_add_eq_zero {R : Type*} [LinearOrder R] {a b : MaxPlus R} (h : a + b = 0) :
    a = 0 ∧ b = 0 := by
  have h' : max (toBot a) (toBot b) = ⊥ := congrArg toBot h
  refine ⟨ofBot_injective ?_, ofBot_injective ?_⟩
  · exact le_bot_iff.mp (h' ▸ le_max_left (toBot a) (toBot b))
  · exact le_bot_iff.mp (h' ▸ le_max_right (toBot a) (toBot b))

/-- Since the semiring is zero-sum-free and nontrivial, it is not a ring:
`1` has no additive inverse. -/
theorem no_neg_one {R : Type*} [Zero R] [LinearOrder R] : ¬ ∃ b : MaxPlus R, (1 : MaxPlus R) + b = 0 := by
  rintro ⟨b, hb⟩
  have h1 : (1 : MaxPlus R) = 0 := (eq_zero_of_add_eq_zero hb).1
  have h2 : ((0 : R) : WithBot R) = (⊥ : WithBot R) := congrArg toBot h1
  exact WithBot.coe_ne_bot h2

/-- A finite tropical sum is the supremum of its terms. -/
theorem toBot_sum {ι : Type*} (s : Finset ι) (f : ι → MaxPlus R) :
    toBot (∑ i ∈ s, f i) = s.sup (fun i => toBot (f i)) := by
  classical
  induction s using Finset.induction with
  | empty => rfl
  | insert a s ha ih => rw [Finset.sum_insert ha, Finset.sup_insert, toBot_add, ih]

/-- A finite tropical product is the sum of its terms. -/
theorem toBot_prod {ι : Type*} (s : Finset ι) (f : ι → MaxPlus R) :
    toBot (∏ i ∈ s, f i) = ∑ i ∈ s, toBot (f i) := by
  classical
  induction s using Finset.induction with
  | empty => rfl
  | insert a s ha ih => rw [Finset.prod_insert ha, Finset.sum_insert ha, toBot_mul, ih]

section Matrices

variable {ι : Type*} [Fintype ι]

/-- The entries of a tropical matrix product: `(A ⊗ B) i j = max_k (A i k + B k j)`,
where `max` and `+` are taken in `R ∪ {-∞}`. -/
theorem toBot_matrix_mul (A B : Matrix ι ι (MaxPlus R)) (i j : ι) :
    toBot ((A * B) i j) = Finset.univ.sup (fun k => toBot (A i k) + toBot (B k j)) := by
  rw [Matrix.mul_apply, toBot_sum]
  simp

/-- **Tropical matrix multiplication is associative.** -/
theorem matrix_mul_assoc (A B C : Matrix ι ι (MaxPlus R)) : A * B * C = A * (B * C) :=
  Matrix.mul_assoc A B C

end Matrices

end MaxPlus

end TropicalLA