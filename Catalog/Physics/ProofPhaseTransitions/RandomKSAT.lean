/-
# Proof Phase Transitions in Random k-SAT (the first-moment / annealed bound)

This file gives a fully formal account of the **first-moment (annealed) counting
identity** for random `k`-SAT in the "literals with replacement" model, and the sharp
*existence* threshold it implies.

The engine is a general **partition-function first-moment law** for an arbitrary finite
constraint-satisfaction problem (CSP): if every assignment satisfies exactly `S` of the
constraints, then summing the number of satisfying assignments over all `m`-constraint
formulas equals `|A| · S^m`, where `A` is the assignment space.  A pigeonhole on this
identity forces an unsatisfiable formula to exist as soon as `|A| · S^m < |C|^m`.

Specializing to Boolean `k`-SAT (assignments `Fin n → Bool`, literals `Fin n × Bool`,
clauses `Fin k → Lit`) gives

* `RandomKSAT.first_moment` :  `∑_F #{a : a ⊨ F} = 2^n · ((2n)^k − n^k)^m`
* `RandomKSAT.exists_unsat`  :  `2^n·((2n)^k − n^k)^m < (2n)^{km} ⟹ ∃ F` unsatisfiable
* `RandomKSAT.exists_unsat_of_real_density` :
      `2^n · (1 − 2^{−k})^m < 1 ⟹ ∃ F` unsatisfiable

the last being the statistical-physics density form of the satisfiability transition.
-/

import Mathlib

open scoped Classical
open Finset

namespace RandomKSAT

/-! ## A general partition-function first-moment law

We work with an abstract finite assignment space `A`, a finite constraint space `C`, and
a satisfaction relation `sat`.  A *formula* on `m` constraints is `Fin m → C`, and an
assignment `a` *models* a formula `F` when it satisfies every constraint of `F`. -/

section General

variable {A C : Type*} [Fintype A] [Fintype C] (sat : A → C → Prop)

/-
!-- The set of formulas satisfied by a fixed assignment factorizes over the `m`
independent constraint slots via `Equiv.subtypePiEquivPi`, so its cardinality is the
`m`-th power of the per-assignment satisfied-constraint count. -- !--
-/
omit [Fintype A] in
theorem card_models_form (a : A) (m : ℕ) :
    Fintype.card {F : Fin m → C // ∀ j, sat a (F j)}
      = (Fintype.card {c // sat a c}) ^ m := by
  -- By definition of $F$, we can rewrite the set of formulas Fix as a product of sets.
  have h_prod : {F : (Fin m) → C | ∀ j, (sat a (F j))} ≃ ((Fin m) → {c : C | (sat a c)}) := by
    exact ⟨ fun F => fun j => ⟨ F.val j, F.prop j ⟩, fun F => ⟨ fun j => F j, fun j => F j |>.2 ⟩, fun F => rfl, fun F => rfl ⟩;
  simpa using Fintype.card_congr h_prod

/-
!-- Fubini for finite sums: summing the number of satisfying assignments over all
formulas equals summing the number of satisfied formulas over all assignments, each of
which is the constant `S^m` by `card_models_form`. -- !--
-/
theorem first_moment_general (m S : ℕ)
    (hS : ∀ a, Fintype.card {c // sat a c} = S) :
    ∑ F : Fin m → C, Fintype.card {a // ∀ j, sat a (F j)}
      = Fintype.card A * S ^ m := by
  -- Rewrite each `Fintype.card {a // P a}` as `∑ a, if P a then 1 else 0` using `Fintype.card_subtype` together with `Finset.card_filter` (or `Fintype.card_eq_sum_ones`/`Finset.sum_boole`).
  have h_rewrite : ∑ F : (Fin m) → C, Fintype.card {a : A // ∀ j, sat a (F j)} = ∑ F : (Fin m) → C, ∑ a : A, if ∀ j, sat a (F j) then 1 else 0 := by
    simp +decide [ Fintype.card_subtype ];
  rw [ h_rewrite, Finset.sum_comm ];
  convert Finset.sum_congr rfl fun a _ => card_models_form sat a m;
  · simp +decide [ Fintype.card_subtype ];
  · simp +decide [ hS ]

/-
!-- Pigeonhole: if the total satisfying-assignment count summed over all `|C|^m`
formulas is strictly below the number of formulas, some formula must have zero
satisfying assignments, i.e. is unsatisfiable. -- !--
-/
theorem exists_unsat_general (m S : ℕ)
    (hS : ∀ a, Fintype.card {c // sat a c} = S)
    (hlt : Fintype.card A * S ^ m < (Fintype.card C) ^ m) :
    ∃ F : Fin m → C, ∀ a, ¬ (∀ j, sat a (F j)) := by
  contrapose! hlt;
  convert first_moment_general sat m S hS |> le_of_eq |> le_trans _ using 1;
  exact le_trans ( by simp +decide [ Fintype.card_pi ] ) ( Finset.sum_le_sum fun F _ => Fintype.card_pos_iff.mpr ⟨ Classical.choose ( hlt F ), Classical.choose_spec ( hlt F ) ⟩ )

end General

/-! ## Boolean `k`-SAT specialization -/

section Boolean

/-- An assignment of Boolean values to `n` variables. -/
abbrev Assign (n : ℕ) := Fin n → Bool

/-- A literal: a variable together with the sign that makes it true. -/
abbrev Lit (n : ℕ) := Fin n × Bool

/-- A `k`-clause: a `k`-tuple of literals (the "with replacement" model). -/
abbrev Clause (n k : ℕ) := Fin k → Lit n

/-- A literal `(v, s)` is satisfied by `a` iff `a v = s`. -/
def satLit {n : ℕ} (a : Assign n) (l : Lit n) : Prop := a l.1 = l.2

/-- A clause is satisfied iff at least one of its literals is. -/
def satClause {n k : ℕ} (a : Assign n) (c : Clause n k) : Prop := ∃ i, satLit a (c i)

/-- An assignment models a formula iff it satisfies every clause. -/
def models {n k m : ℕ} (a : Assign n) (F : Fin m → Clause n k) : Prop :=
  ∀ j, satClause a (F j)

/-
!-- The literals falsified by `a` are exactly those of the form `(v, !(a v))`, one per
variable, giving a bijection with `Fin n`. -- !--
-/
theorem card_falseLit {n : ℕ} (a : Assign n) :
    Fintype.card {l : Lit n // a l.1 ≠ l.2} = n := by
  rw [ Fintype.card_subtype ];
  convert Finset.card_image_of_injective ( Finset.univ : Finset ( Fin n ) ) ( show Function.Injective ( fun k : Fin n ↦ ( k, !a k ) ) from fun i j h ↦ by aesop ) using 2;
  · ext ⟨ i, j ⟩ ; by_cases hi : a i <;> aesop;
  · simp +decide [ Finset.card_univ ]

/-
!-- A clause is falsified iff every coordinate is a falsified literal; by
`Equiv.subtypePiEquivPi` this set is the `k`-fold product of falsified literals, of
size `n^k`. -- !--
-/
theorem card_unsat_clause {n k : ℕ} (a : Assign n) :
    Fintype.card {c : Clause n k // ∀ i, a (c i).1 ≠ (c i).2} = n ^ k := by
  rw [ Fintype.card_subtype ];
  -- By definition of $satClause$, we know that $satClause a c$ holds if and only if there exists an $i$ such that $a (c i).1 = (c i).2$.
  set S := Finset.filter (fun c : Fin k → Lit n => ∀ i, a (c i).1 ≠ (c i).2) Finset.univ;
  rw [ show S = Finset.image ( fun x : Fin k → Fin n => fun i => ( x i, !a ( x i ) ) ) ( Finset.univ : Finset ( Fin k → Fin n ) ) from ?_ ];
  · rw [ Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
    simp +contextual [ funext_iff ];
  · ext c; simp [S];
    constructor <;> intro h;
    · exact ⟨ fun i => ( c i |>.1 ), funext fun i => by cases h' : c i |>.2 <;> specialize h i <;> aesop ⟩;
    · grind

/-
!-- Satisfied clauses are the complement of falsified clauses, so their count is the
total clause count `(2n)^k` minus the falsified count `n^k`. -- !--
-/
theorem card_sat_clause {n k : ℕ} (a : Assign n) :
    Fintype.card {c : Clause n k // satClause a c} = (n * 2) ^ k - n ^ k := by
  by_contra h;
  -- The set of clauses that are not satisfied by `a` is the complement of the set of clauses that are satisfied by `a`.
  have h_compl : Fintype.card {c : Clause n k // ¬satClause a c} = n ^ k := by
    convert card_unsat_clause a using 4 ; unfold satClause ; aesop;
  have h_total : Fintype.card {c : Clause n k // satClause a c} + Fintype.card {c : Clause n k // ¬satClause a c} = (n * 2) ^ k := by
    rw [ Fintype.card_subtype, Fintype.card_subtype ];
    rw [ Finset.card_filter_add_card_filter_not ] ; aesop;
  exact h ( eq_tsub_of_add_eq <| by linarith )

/-
!-- Instance of `first_moment_general` with `S = (2n)^k − n^k` (constant by
`card_sat_clause`) and `|A| = 2^n`. -- !--
-/
theorem first_moment (n k m : ℕ) :
    ∑ F : Fin m → Clause n k, Fintype.card {a : Assign n // models a F}
      = 2 ^ n * ((n * 2) ^ k - n ^ k) ^ m := by
  by_contra h_contra;
  -- Let's rewrite the sum using the fact that multiplication by a constant out of the sum can be taken outside.
  have h_sum : ∑ F : Fin m → Clause n k, (Fintype.card {a : Assign n // ∀ j, satClause a (F j)}) = Fintype.card (Assign n) * ((n * 2) ^ k - n ^ k) ^ m := by
    convert first_moment_general _ m _ _;
    convert card_sat_clause;
  convert h_contra ?_;
  convert h_sum using 1;
  · congr! 3;
  · norm_num [ Assign ]

/-
!-- Instance of `exists_unsat_general`: `|C|^m = ((2n)^k)^m = (2n)^{km}`, so the
first-moment value dropping below the number of formulas forces an unsatisfiable
formula. -- !--
-/
theorem exists_unsat (n k m : ℕ)
    (hlt : 2 ^ n * ((n * 2) ^ k - n ^ k) ^ m < (n * 2) ^ (k * m)) :
    ∃ F : Fin m → Clause n k, ∀ a, ¬ models a F := by
  contrapose! hlt; simp_all +decide [ models ] ;
  rw [ ← first_moment ];
  refine' le_trans _ ( Finset.sum_le_sum fun F _ => Fintype.card_pos_iff.mpr _ );
  · simp +decide [ pow_mul ];
  · exact ⟨ ⟨ Classical.choose ( hlt F ), Classical.choose_spec ( hlt F ) ⟩ ⟩

/-
!-- Statistical-physics density form.  Casting to ℝ and using
`n^k = (2n)^k · 2^{−k}` rewrites the integer threshold as the sign of
`2^n · (1 − 2^{−k})^m − 1`; the real hypothesis discharges it. -- !--
-/
theorem exists_unsat_of_real_density (n k m : ℕ) (hn : 1 ≤ n)
    (hreal : (2 : ℝ) ^ n * (1 - (1 / 2 : ℝ) ^ k) ^ m < 1) :
    ∃ F : Fin m → Clause n k, ∀ a, ¬ models a F := by
  -- Prove the integer inequality:
  have hlt : (2 : ℝ) ^ n * ((n * 2) ^ k - n ^ k) ^ m < (n * 2) ^ (k * m) := by
    -- Using the factorization, rewrite the left-hand side:
    have h_lhs : ((2 : ℝ) ^ n) * ((n * 2) ^ k - n ^ k) ^ m = ((n * 2 : ℝ) ^ k) ^ m * ((2 : ℝ) ^ n * (1 - (1 / 2 : ℝ) ^ k) ^ m) := by
      rw [ show ( n * 2 : ℝ ) ^ k - n ^ k = ( n * 2 : ℝ ) ^ k * ( 1 - ( 1 / 2 : ℝ ) ^ k ) by rw [ mul_sub, mul_one, ← mul_pow ] ; ring ] ; rw [ mul_pow ] ; ring;
    rw [ h_lhs, pow_mul ] ; exact mul_lt_of_lt_one_right ( by positivity ) hreal;
  convert exists_unsat n k m _;
  norm_cast at hlt;
  rw [ Int.subNatNat_of_le ( Nat.pow_le_pow_left ( by linarith ) _ ) ] at hlt ; norm_cast at hlt

end Boolean

/-! ## Direction 2 — the unsatisfiable phase is upward closed in `m`

Because `0 ≤ 1 − 2^{−k} ≤ 1`, the sequence `(1 − 2^{−k})^m` is antitone in `m`, so the
real density `2^n·(1 − 2^{−k})^m` stays below `1` for every `m' ≥ m`.  Once the
first-moment density forces unsatisfiability at `m` clauses, it forces it at every larger
clause count. -/

/-
!-- Monotonicity of the unsat phase: apply `exists_unsat_of_real_density` at `m'`, using
`(1 − 2^{−k})^m' ≤ (1 − 2^{−k})^m` from `pow_le_pow_of_le_one` since the base lies in
`[0,1]`. -- !--
-/
theorem exists_unsat_of_density_mono (n k m m' : ℕ) (hn : 1 ≤ n) (hmm : m ≤ m')
    (hreal : (2 : ℝ) ^ n * (1 - (1 / 2 : ℝ) ^ k) ^ m < 1) :
    ∃ F : Fin m' → Clause n k, ∀ a, ¬ models a F := by
  convert exists_unsat_of_real_density n k m' hn _;
  exact lt_of_le_of_lt ( mul_le_mul_of_nonneg_left ( pow_le_pow_of_le_one ( sub_nonneg.2 <| pow_le_one₀ ( by norm_num ) <| by norm_num ) ( sub_le_self _ <| by positivity ) hmm ) <| by positivity ) hreal

/-! ## Direction 4 — the finite-domain (`q`-ary) constraint-satisfaction model

We replace Boolean variables by variables over `Fin q`.  A literal `(v, val)` is satisfied
by `a : Fin n → Fin q` iff `a v = val`; a `k`-clause is satisfied iff some literal is.
Reusing the abstract law `first_moment_general`, the first moment is
`q^n · ((nq)^k − (n(q−1))^k)^m`, with density factor `1 − ((q−1)/q)^k` that reduces to the
Boolean `1 − 2^{−k}` at `q = 2`: the threshold is model independent in density form. -/

namespace Qary

/-- A `q`-ary assignment of `n` variables. -/
abbrev QAssign (n q : ℕ) := Fin n → Fin q

/-- A `q`-ary literal: a variable together with the value that makes it true. -/
abbrev QLit (n q : ℕ) := Fin n × Fin q

/-- A `q`-ary `k`-clause: a `k`-tuple of literals. -/
abbrev QClause (n q k : ℕ) := Fin k → QLit n q

/-- A literal `(v, val)` is satisfied by `a` iff `a v = val`. -/
def qsatLit {n q : ℕ} (a : QAssign n q) (l : QLit n q) : Prop := a l.1 = l.2

/-- A clause is satisfied iff at least one literal is. -/
def qsatClause {n q k : ℕ} (a : QAssign n q) (c : QClause n q k) : Prop :=
  ∃ i, qsatLit a (c i)

/-- An assignment models a formula iff it satisfies every clause. -/
def qmodels {n q k m : ℕ} (a : QAssign n q) (F : Fin m → QClause n q k) : Prop :=
  ∀ j, qsatClause a (F j)

/-
!-- The literals satisfied by `a` form the graph `{(v, a v)}`, equivalent to `Fin n`, so
the falsified ones are the complement among the `n·q` literals: `nq − n = n(q−1)`. -- !--
-/
theorem card_qfalseLit {n q : ℕ} (a : QAssign n q) :
    Fintype.card {l : QLit n q // a l.1 ≠ l.2} = n * (q - 1) := by
  -- The literals satisfied by `a` arecollected as the graph: `{l : Fin n × Fin q | a l.1 = l.2}`.
  have h_graph : Fintype.card {l : Fin n × Fin q | a l.1 = l.2} = n := by
    rw [ Fintype.card_subtype ];
    convert Finset.card_image_of_injective ( Finset.univ : Finset ( Fin n ) ) ( show Function.Injective ( fun x : Fin n => ( x, a x ) ) from fun x y hxy => by aesop ) using 1;
    · congr with x ; aesop;
    · simp +decide [ Finset.card_univ ];
  cases q <;> simp_all +decide [ Nat.mul_succ ];
  aesop

/-
!-- A clause is falsified iff every coordinate is a falsified literal; by
`Equiv.subtypePiEquivPi` this is the `k`-fold product, of size `(n(q−1))^k`. -- !--
-/
theorem card_qunsat_clause {n q k : ℕ} (a : QAssign n q) :
    Fintype.card {c : QClause n q k // ∀ i, a (c i).1 ≠ (c i).2} = (n * (q - 1)) ^ k := by
  -- Apply the equivalence between the set of falsified clauses and the product of k falsified literals.
  have h_equiv : {c : Fin k → QLit n q // ∀ i, a (c i).1 ≠ (c i).2} ≃ (Fin k → {l : QLit n q // a l.1 ≠ l.2}) := by
    exact ⟨ fun x => fun i => ⟨ x.val i, x.property i ⟩, fun x => ⟨ fun i => x i |>.1, fun i => x i |>.2 ⟩, fun x => rfl, fun x => rfl ⟩;
  rw [ Fintype.card_congr h_equiv, Fintype.card_pi ];
  simp +decide [ card_qfalseLit a ]

/-
!-- Satisfied clauses are the complement of the falsified ones: `(nq)^k − (n(q−1))^k`. -- !--
-/
theorem card_qsat_clause {n q k : ℕ} (a : QAssign n q) :
    Fintype.card {c : QClause n q k // qsatClause a c} = (n * q) ^ k - (n * (q - 1)) ^ k := by
  rw [ Fintype.card_subtype ];
  convert congr_arg _ ( card_qunsat_clause a ) using 2;
  convert eq_tsub_of_add_eq ( Finset.card_add_card_compl ( Finset.filter ( fun c => qsatClause a c ) Finset.univ ) ) using 1;
  convert rfl;
  all_goals try infer_instance;
  · simp +decide [ QClause ];
  · rw [ Fintype.card_subtype ];
    congr with x ; simp +decide [ qsatClause ];
    rfl

/-
!-- Instance of `first_moment_general` with constant satisfied count
`S = (nq)^k − (n(q−1))^k` and `|A| = q^n`. -- !--
-/
theorem first_moment (n q k m : ℕ) :
    ∑ F : Fin m → QClause n q k, Fintype.card {a : QAssign n q // qmodels a F}
      = q ^ n * ((n * q) ^ k - (n * (q - 1)) ^ k) ^ m := by
  -- Apply the first-moment law with the constant satisfied count `S` and `|A| = q^n`.
  have h_first_moment : ∑ F : Fin m → QClause n q k, Fintype.card {a : QAssign n q // ∀ j, qsatClause a (F j)} = Fintype.card (QAssign n q) * ((n * q) ^ k - (n * (q - 1)) ^ k) ^ m := by
    convert first_moment_general ( fun a c => qsatClause a c ) m ( ( n * q ) ^ k - ( n * ( q - 1 ) ) ^ k ) _ using 1;
    exact fun a => card_qsat_clause a;
  convert h_first_moment using 3 ; simp +decide [ Fintype.card_pi, QAssign ]

/-
!-- Instance of `exists_unsat_general`: `|C|^m = ((nq)^k)^m = (nq)^{km}`. -- !--
-/
theorem exists_unsat (n q k m : ℕ)
    (hlt : q ^ n * ((n * q) ^ k - (n * (q - 1)) ^ k) ^ m < (n * q) ^ (k * m)) :
    ∃ F : Fin m → QClause n q k, ∀ a, ¬ qmodels a F := by
  apply RandomKSAT.exists_unsat_general;
  convert card_qsat_clause using 1;
  convert hlt using 1;
  · simp +decide [ QAssign ];
  · simp +decide [ pow_mul, QClause ]

/-
!-- Density form for the `q`-ary model.  Casting to ℝ and using
`(n(q−1))^k = (nq)^k · ((q−1)/q)^k` turns the integer threshold into the sign of
`q^n · (1 − ((q−1)/q)^k)^m − 1`. -- !--
-/
theorem exists_unsat_of_real_density (n q k m : ℕ) (hn : 1 ≤ n) (hq : 1 ≤ q)
    (hreal : (q : ℝ) ^ n * (1 - (((q : ℝ) - 1) / q) ^ k) ^ m < 1) :
    ∃ F : Fin m → QClause n q k, ∀ a, ¬ qmodels a F := by
  refine' exists_unsat n q k m _;
  rw [ ← @Nat.cast_lt ℝ ];
  rcases q with ( _ | _ | q ) <;> simp_all +decide [ pow_mul ];
  · cases k <;> cases m <;> aesop;
  · rw [ Nat.cast_sub ] <;> norm_num [ mul_pow ];
    · convert mul_lt_mul_of_pos_right hreal ( show 0 < ( n ^ k : ℝ ) ^ m * ( ( q + 1 + 1 ) ^ k ) ^ m by positivity ) using 1 ; ring;
      · field_simp;
        rw [ show ( - ( 1 + q : ℝ ) ^ k + ( 2 + q : ℝ ) ^ k ) = ( 2 + q : ℝ ) ^ k * ( 1 - ( ( 1 + q : ℝ ) / ( 2 + q ) ) ^ k ) by rw [ div_pow, mul_sub, mul_one, mul_div_cancel₀ _ ( by positivity ) ] ; ring ] ; rw [ mul_pow ] ; ring;
        rw [ show ( 2 + q : ℝ ) ^ k - ( 2 + q : ℝ ) ^ k * ( q * ( 2 + q : ℝ ) ⁻¹ + ( 2 + q : ℝ ) ⁻¹ ) ^ k = ( 2 + q : ℝ ) ^ k * ( 1 - ( q * ( 2 + q : ℝ ) ⁻¹ + ( 2 + q : ℝ ) ⁻¹ ) ^ k ) by ring ] ; rw [ mul_pow ] ; ring;
      · ring;
    · gcongr ; norm_num

end Qary

end RandomKSAT