import Mathlib

/-!
# Tropical Curry–Howard: Proofs as Min-Plus Programs

This module formalizes a **syntactic tropical proof calculus** in which:
- propositions/types are interpreted as tropical costs,
- proofs/programs are syntax trees built from `cut`, `plus`, and `min`,
- cut elimination is a rewrite system whose normalization computes **least-cost proofs**,
- idempotence of `min` forces **proof sharing / duplicate branch collapse**,
- canonical normal forms emerge from tropical algebra.

## Key Results

* **Soundness** (`step_preserves_eval`): Every normalization step preserves tropical semantics.
* **Strong Normalization** (`strongly_normalizing`): The rewrite system terminates, via a
  polynomial interpretation that maps `cut` to multiplication and `min` to addition.
* **Normal Form Existence** (`normal_form_exists`): Every term reduces to a normal form.
* **Semantic Optimality** (`normalization_is_semantics`, `normal_forms_eval_eq`):
  All normal forms of a term have the same tropical cost — normalization computes a
  unique optimal cost.

## Tropical Proof Theory

The revolutionary interpretation: proof normalization **is** optimization. The `min` operation
represents nondeterministic choice among proof strategies, `cut` represents sequential
composition, and normalization computes the cheapest proof path — connecting
Curry–Howard to shortest-path / dynamic programming semantics.

## Cross-Domain Connections

- **Dynamic Programming**: `min + plus` is the algebra of shortest paths; normal forms are
  compiled shortest-proof certificates (Bellman–Ford / Viterbi semantics).
- **Tropical Geometry**: Normal forms correspond to tropical polynomials in canonical
  presentation; proof equivalence relates to tropical hypersurfaces.
- **Semiring Programming Languages**: The syntax is a tiny language with sequencing (`cut`),
  parallelism (`plus`), and nondeterministic choice (`min`); normalization = optimization.
-/

namespace TropicalCurryHoward

/-! ## Syntax -/

/-- Tropical proof terms over `Nat` costs.
- `atom n`: a basic proof/axiom of cost `n`
- `cut t s`: sequential composition (cut rule; cost = sum)
- `plus t s`: parallel/tensor composition (cost = sum)
- `min t s`: nondeterministic choice (cost = minimum) -/
inductive TropTerm where
  | atom : Nat → TropTerm
  | cut  : TropTerm → TropTerm → TropTerm
  | plus : TropTerm → TropTerm → TropTerm
  | min  : TropTerm → TropTerm → TropTerm
deriving DecidableEq, Repr

namespace TropTerm

/-! ## Semantics -/

/-- Tropical evaluation: the cost of a proof term in the min-plus semiring.
- Sequential/parallel composition adds costs.
- Nondeterministic choice takes the minimum cost. -/
def eval : TropTerm → Nat
  | .atom n   => n
  | .cut t s  => eval t + eval s
  | .plus t s => eval t + eval s
  | .min t s  => Nat.min (eval t) (eval s)

/-! ## Structural Measures -/

/-- Syntactic size of a term (number of nodes). -/
def termSize : TropTerm → Nat
  | .atom _   => 1
  | .cut t s  => 1 + termSize t + termSize s
  | .plus t s => 1 + termSize t + termSize s
  | .min t s  => 1 + termSize t + termSize s

/-- Polynomial interpretation for proving termination of tropical cut elimination.

The key idea: map `cut` to multiplication, `plus` to addition, and `min` to
addition + 1. Then each reduction rule strictly decreases this interpretation:
- **Idempotence** (`min t t → t`): `2a + 1 > a` (for `a ≥ 2`).
- **Distribution** (`cut (min t u) s → min (cut t s) (cut u s)`):
  `(a + b + 1) · c > a·c + b·c + 1` (since `c ≥ 2`).

This is a standard technique from term rewriting theory (polynomial interpretations). -/
def interp : TropTerm → Nat
  | .atom _ => 2
  | .cut t s => interp t * interp s
  | .plus t s => interp t + interp s
  | .min t s => interp t + interp s + 1

/-! ## Reduction Relation -/

/-- One-step reduction in the tropical proof calculus.

**Base rules** capture the algebraic identities of idempotent semirings:
- `min_idem`: duplicate branch collapse (`min` is idempotent)
- `cut_min_left`/`cut_min_right`: `cut` distributes over `min`

**Congruence rules** allow reduction inside any subterm, making the
relation a compatible closure of the base rules. -/
inductive Step : TropTerm → TropTerm → Prop where
  | min_idem (t : TropTerm) :
      Step (.min t t) t
  | cut_min_left (t u s : TropTerm) :
      Step (.cut (.min t u) s) (.min (.cut t s) (.cut u s))
  | cut_min_right (s t u : TropTerm) :
      Step (.cut s (.min t u)) (.min (.cut s t) (.cut s u))
  | cut_left {t t' : TropTerm} (s : TropTerm) :
      Step t t' → Step (.cut t s) (.cut t' s)
  | cut_right (t : TropTerm) {s s' : TropTerm} :
      Step s s' → Step (.cut t s) (.cut t s')
  | plus_left {t t' : TropTerm} (s : TropTerm) :
      Step t t' → Step (.plus t s) (.plus t' s)
  | plus_right (t : TropTerm) {s s' : TropTerm} :
      Step s s' → Step (.plus t s) (.plus t s')
  | min_left {t t' : TropTerm} (s : TropTerm) :
      Step t t' → Step (.min t s) (.min t' s)
  | min_right (t : TropTerm) {s s' : TropTerm} :
      Step s s' → Step (.min t s) (.min t s')

/-- A term is in **normal form** if no reduction step applies.
Normal forms represent fully optimized proof strategies. -/
def Normal (t : TropTerm) : Prop := ¬ ∃ u, Step t u

/-- The "reduces to" relation for well-foundedness: `Reduces a b` iff `Step b a`,
i.e., `b` reduces to `a` in one step. Strong normalization is
`WellFounded Reduces`, which means no infinite forward reduction sequence. -/
def Reduces (a b : TropTerm) : Prop := Step b a

/-! ## Section 1: Soundness of Tropical Cut Elimination -/

/-
Every single normalization step preserves tropical cost.
This is the soundness theorem: reduction is semantically transparent.

The proof uses the min-plus semiring identities:
- `min(a, a) = a` (idempotence of min)
- `a + min(b, c) = min(a + b, a + c)` (distributivity of addition over min)
-/
theorem step_preserves_eval {t u : TropTerm} :
    Step t u → eval t = eval u := by
  intro h;
  induction h;
  all_goals simp_all +decide [ TropTerm.eval ]

/-
Transitive closure of soundness: any reduction sequence preserves cost.
-/
theorem rtc_step_preserves_eval {t u : TropTerm} :
    Relation.ReflTransGen Step t u → eval t = eval u := by
  intro h;
  induction h;
  · rfl;
  · rw [ ‹t.eval = _›, step_preserves_eval ‹_› ]

/-! ## Section 2: Termination via Polynomial Interpretation -/

/-
The polynomial interpretation is always at least 2.
This is crucial for the termination argument: it ensures multiplication
by `interp s` in the `cut` case is strictly expansive.
-/
theorem interp_ge_two (t : TropTerm) : 2 ≤ interp t := by
  have h_ind : ∀ t : TropTerm, 2 ≤ t.interp := by
    intro t
    induction' t with t ih;
    · exact Nat.le_add_left _ _;
    · exact le_trans ( by nlinarith ) ( Nat.mul_le_mul ‹2 ≤ ih.interp› ‹2 ≤ _› );
    · exact le_add_of_le_of_nonneg ‹_› ( Nat.zero_le _ );
    · exact le_add_of_le_of_nonneg ( le_add_of_le_of_nonneg ‹_› ( by norm_num ) ) ( by norm_num );
  exact h_ind t

/-
Each reduction step **strictly decreases** the polynomial interpretation.
This is the engine of strong normalization.
-/
theorem step_decreases_interp {t u : TropTerm} :
    Step t u → interp u < interp t := by
  intro h_step
  induction' t with t ih generalizing u;
  · cases h_step;
  · nontriviality;
    rcases h_step with ( _ | _ | _ | _ | _ | _ | _ | _ | _ | h_step ) <;> simp_all +decide [ TropTerm.interp ];
    · nontriviality;
      rename_i k hk;
      rename_i t u;
      rename_i v hv;
      rename_i w;
      nlinarith [ interp_ge_two t, interp_ge_two u, interp_ge_two w ];
    · linarith [ interp_ge_two ih ];
    · exact Nat.mul_lt_mul_of_pos_right ( by solve_by_elim ) ( by exact Nat.one_le_of_lt ( TropTerm.interp_ge_two _ ) );
    · exact Nat.mul_lt_mul_of_pos_left ( by solve_by_elim ) ( by linarith [ interp_ge_two ih ] );
  · cases h_step;
    · exact add_lt_add_of_lt_of_le ( by solve_by_elim ) ( by linarith [ interp_ge_two ‹_› ] );
    · exact Nat.add_lt_add_left ( by solve_by_elim ) _;
  · rcases h_step with ( _ | _ | _ | h_step );
    · grind +locals;
    · simp_all +decide [ TropTerm.interp ];
    · simp_all +decide [ TropTerm.interp ]

/-! ## Section 3: Strong Normalization -/

/-
Every term is accessible under the reduction ordering.
This is the strong normalization theorem: every forward reduction
sequence from `t` is finite.

`Reduces a b` means `Step b a` (b reduces to a), so `Acc Reduces t`
says: for all u with `Step t u`, u is accessible.
-/
theorem acc_step (t : TropTerm) : Acc Reduces t := by
  -- We will prove this by induction on $n = \mathbb{N}$.
  have h_ind : ∀ n : ℕ, ∀ t : TropTerm, interp t ≤ n → Acc Reduces t := by
    intro n;
    induction' n with n ih;
    · exact fun t ht => absurd ht ( not_le_of_gt ( lt_of_lt_of_le ( by decide ) ( interp_ge_two t ) ) );
    · intro t ht;
      refine' ⟨ _, fun u hu => _ ⟩;
      exact ih u ( Nat.le_of_lt_succ ( lt_of_lt_of_le ( step_decreases_interp hu ) ht ) );
  exact h_ind _ _ le_rfl

/-- The tropical proof calculus is **strongly normalizing**: there is no
infinite reduction sequence. -/
theorem strongly_normalizing : WellFounded Reduces :=
  ⟨acc_step⟩

/-! ## Section 4: Normal Form Existence and Semantic Optimality -/

/-
Every term reduces to a normal form.
-/
theorem normal_form_exists (t : TropTerm) :
    ∃ u, Relation.ReflTransGen Step t u ∧ Normal u := by
  -- We prove this using induction on the representation.
  induction' h : acc_step t with t h IH;
  by_cases h₂ : ∃ u, Step t u;
  · exact Exists.elim h₂ fun u hu => Exists.elim ( IH u hu rfl ) fun v hv => ⟨ v, Relation.ReflTransGen.single hu |> Relation.ReflTransGen.trans <| hv.1, hv.2 ⟩;
  · exact ⟨ t, by rfl, by tauto ⟩

/-
Normalization is semantically transparent: normal forms have the same
cost as their source terms.
-/
theorem normalization_is_semantics {t u : TropTerm} :
    Relation.ReflTransGen Step t u → Normal u → eval u = eval t := by
  exact fun h1 h2 => by rw [ rtc_step_preserves_eval h1, eq_comm ] ;

/-
**Semantic uniqueness of normal forms**: any two normal forms reachable
from the same term have the same tropical cost.

Note: Full syntactic uniqueness (`normal_form_unique`) would require confluence,
which needs AC rules for `min`. The semantic result is the core content:
**normalization computes a unique optimal cost**.
-/
theorem normal_forms_eval_eq {t u v : TropTerm} :
    Relation.ReflTransGen Step t u → Normal u →
    Relation.ReflTransGen Step t v → Normal v →
    eval u = eval v := by
  intros h1 h2 h3 h4
  have h_eval_u : eval u = eval t := normalization_is_semantics h1 h2
  have h_eval_v : eval v = eval t := normalization_is_semantics h3 h4
  rw [h_eval_u, h_eval_v]

end TropTerm
end TropicalCurryHoward