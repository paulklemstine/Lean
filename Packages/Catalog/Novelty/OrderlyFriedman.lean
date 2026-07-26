import Mathlib

/-!
# Orderly Friedman numbers

A small, explicit formal model of orderly Friedman certificates.  Decimal digits
must occur from left to right in the expression.  Besides arithmetic operations,
`concat` is available, as in the usual Friedman-number convention; its width is
recorded explicitly.  A certificate must contain a genuine arithmetic operation,
so merely concatenating the original numeral is not accepted.
-/

namespace OrderlyFriedman

inductive Expr where
  | digit : Fin 10 → Expr
  | neg : Expr → Expr
  | add : Expr → Expr → Expr
  | mul : Expr → Expr → Expr
  | pow : Expr → Nat → Expr
  | concat : Expr → Expr → Nat → Expr
  deriving DecidableEq, Repr

open Expr

def leaves : Expr → List Nat
  | digit d => [d.1]
  | neg e => leaves e
  | add e f | mul e f | concat e f _ => leaves e ++ leaves f
  | pow e k => leaves e ++ (Nat.digits 10 k).reverse

/-- Interpret a list as a string of decimal digits. -/
def decimalValue : List Nat → Nat
  | [] => 0
  | d :: ds => d * 10 ^ ds.length + decimalValue ds

/-- Integer evaluation. `concat e f k` reserves `k` decimal places for `f`. -/
def eval : Expr → Int
  | digit d => d.1
  | neg e => -eval e
  | add e f => eval e + eval f
  | mul e f => eval e * eval f
  | pow e k => eval e ^ k
  | concat e f k => eval e * (10 : Int) ^ k + eval f

/-- Concatenation widths agree with the number of digits on their right. -/
def WellFormed : Expr → Prop
  | digit _ => True
  | neg e => WellFormed e
  | add e f | mul e f => WellFormed e ∧ WellFormed f
  | pow e _ => WellFormed e
  | concat e f k => WellFormed e ∧ WellFormed f ∧ (leaves f).length = k

/-- There is at least one arithmetic operation other than decimal concatenation. -/
def arithmetic : Expr → Bool
  | digit _ => false
  | neg _ | add _ _ | mul _ _ | pow _ _ => true
  | concat e f _ => arithmetic e || arithmetic f

/-- An orderly Friedman certificate uses exactly the displayed decimal digits,
in order, and evaluates to the displayed positive integer. -/
def IsOrderly (n : Nat) : Prop :=
  ∃ e : Expr, WellFormed e ∧ decimalValue (leaves e) = n ∧
    eval e = (n : Int) ∧ arithmetic e = true

lemma decimalValue_append (xs ys : List Nat) :
    decimalValue (xs ++ ys) = decimalValue xs * 10 ^ ys.length + decimalValue ys := by
  induction xs <;> simp_all +decide [mul_comm];
  rename_i k l ih; simp_all +decide [ decimalValue ] ; ring;

private def d (n : Nat) (h : n < 10) : Expr := digit ⟨n, h⟩

/-- `-1 + 2^7`, whose leaves are `1,2,7`. -/
def cert127 : Expr := add (neg (d 1 (by omega))) (pow (d 2 (by omega)) 7)

/-- `7 + 3^6`, whose leaves are `7,3,6`. -/
def cert736 : Expr := add (d 7 (by omega)) (pow (d 3 (by omega)) 6)

theorem orderly_127 : IsOrderly 127 := by
  exists add ( neg ( d 1 ( by decide ) ) ) ( pow ( d 2 ( by decide ) ) 7 )

theorem orderly_736 : IsOrderly 736 := by
  -- Use the witness cert736 and unfold all definitions; norm_num computes the certificate.
  use cert736
  norm_num [IsOrderly];
  simp +decide [cert736, WellFormed, d]

/-- Repeat the certified block `127`, joining copies by decimal concatenation. -/
def repeatCert : Nat → Expr
  | 0 => cert127
  | n + 1 => concat (repeatCert n) cert127 3

/-- The corresponding closed recurrent family: 127, 127127, 127127127, ... -/
def family : Nat → Nat
  | 0 => 127
  | n + 1 => 1000 * family n + 127

/-
The useful, non-artificial description of the leaves of the repeated certificate.
-/
lemma repeatCert_leaves_blocks (n : Nat) :
    leaves (repeatCert n) = List.flatten (List.replicate (n + 1) [1, 2, 7]) := by
  induction n <;> simp_all +decide [List.replicate_add];
  rename_i n ih; erw [ show repeatCert ( n + 1 ) = concat ( repeatCert n ) cert127 3 from rfl ] ; simp +decide [ *, leaves ] ;

lemma repeatCert_eval (n : Nat) : eval (repeatCert n) = (family n : Int) := by
  induction' n with n ih;
  · rfl;
  · convert congr_arg₂ ( fun x y : ℤ => x * 10 ^ 3 + y ) ih rfl using 1;
    erw [ show eval cert127 = 127 by rfl ] ; norm_num [ family ] ; ring;

lemma repeatCert_decimal (n : Nat) : decimalValue (leaves (repeatCert n)) = family n := by
  induction' n with n ih;
  · rfl;
  · erw [ show leaves ( concat ( repeatCert n ) cert127 3 ) = leaves ( repeatCert n ) ++ leaves cert127 from ?_ ];
    · rw [ decimalValue_append, ih ] ; ring!;
      rw [ add_comm 1 n ] ; norm_num [ family ] ;
      exact congr_arg₂ _ ( by rw [ mul_comm ] ; rfl ) rfl;
    · rfl

lemma repeatCert_wellFormed (n : Nat) : WellFormed (repeatCert n) := by
  induction n with
  | zero => simp [repeatCert, cert127, WellFormed, d]
  | succ n ih => simp [repeatCert, WellFormed, ih, cert127, leaves, d]

/-
An infinite recurrence producing orderly Friedman numbers.
-/
theorem family_orderly (n : Nat) : IsOrderly (family n) := by
  refine ⟨repeatCert n, repeatCert_wellFormed n, repeatCert_decimal n,
    repeatCert_eval n, ?_⟩
  induction n with
  | zero => rfl
  | succ n ih => simp [repeatCert, arithmetic, ih]

/-
Division-free closed form for the recurrent family.
-/
theorem family_closed_form (n : Nat) :
    999 * family n = 127 * (1000 ^ (n + 1) - 1) := by
  induction n <;> simp_all +decide [ pow_succ', family ] ; ring;
  grind

/-
The certified family is strictly increasing, hence supplies infinitely many
pairwise distinct orderly Friedman numbers.
-/
theorem family_strictMono : StrictMono family := by
  exact strictMono_nat_of_lt_succ fun n => by induction n <;> norm_num [ family ] at * ; linarith;

/-
A bold but false conjecture: orderly Friedman numbers need not be odd.
-/
theorem not_all_orderly_odd : ¬ ∀ n, IsOrderly n → Odd n := by
  push_neg;
  exact ⟨ _, orderly_736, by decide ⟩

/-- The terms exactly as supplied in the mission statement.  Its final `155`
is out of numerical order, unlike the preceding catalog prefix. -/
def reportedTerms : List Nat :=
  [127,343,736,1285,2187,2502,2592,2737,3125,3685,3864,3972,4096,6455,
   11264,11664,12850,13825,14641,155]

/-
Thus the displayed list itself disproves the conjecture that it is strictly
increasing; this detects a transcription/truncation issue in the input.
-/
theorem reportedTerms_not_strictlyIncreasing :
    ¬ reportedTerms.Pairwise (· < ·) := by
  norm_num [reportedTerms, List.pairwise_cons]

end OrderlyFriedman