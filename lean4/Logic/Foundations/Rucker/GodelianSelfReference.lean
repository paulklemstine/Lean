/-
# Gödelian Self-Reference — Incompleteness and Fixed Points

Rudy Rucker's *Infinity and the Mind* and *Mind Tools* explore Gödel's
incompleteness theorems as fundamental limits on formal systems.
Rucker sees Gödel's work as showing that mathematical truth transcends
any single formal system — "the Mindscape is larger than any map of it."

This module formalizes results related to Gödelian themes:
- Lawvere's fixed point theorem (categorical generalization of diagonalization)
- The Knaster-Tarski fixed point theorem
- Self-referential constructions and their consequences
- Cantor's theorem as a corollary of the fixed point perspective
-/
import Mathlib

open Function Set

namespace Rucker.GodelianSelfReference

/-! ## Lawvere's Fixed Point Theorem

Lawvere showed that Cantor's theorem, Gödel's incompleteness, and the
halting problem are all instances of a single categorical phenomenon:
if there is a surjection A → (A → B), then every endomorphism B → B
has a fixed point.

Rucker would appreciate this unification — it shows that the
"diagonal argument" is a universal principle.
-/

/-
PROBLEM
Lawvere's fixed point theorem: If there is a surjection from A to (A → B),
  then every function B → B has a fixed point.
  This unifies Cantor's theorem, Gödel's theorem, and the halting problem.

PROVIDED SOLUTION
Since e is surjective, there exists a₀ with e a₀ = fun a => f (e a a). Then e a₀ a₀ = f (e a₀ a₀), so b = e a₀ a₀ is a fixed point of f.
-/
theorem lawvere_fixed_point {A B : Type*} (e : A → A → B) (he : Surjective e)
    (f : B → B) : ∃ b : B, f b = b := by
      -- Since e is surjective, there exists an a₀ such that e a₀ = fun a => f (e a a).
      obtain ⟨a₀, ha₀⟩ : ∃ a₀ : A, e a₀ = fun a => f (e a a) := by
        exact he _;
      exact ⟨ _, congr_fun ha₀ a₀ |> Eq.symm ⟩

/-
PROBLEM
Corollary: If B has a fixed-point-free endomorphism, there is no
  surjection from A to (A → B). This immediately gives Cantor's theorem
  by taking B = Prop and f = Not.

PROVIDED SOLUTION
Suppose e is such a surjection. By lawvere_fixed_point, f has a fixed point. But hf says f has no fixed point. Contradiction.
-/
theorem cantor_via_lawvere {A B : Type*} (f : B → B) (hf : ∀ b, f b ≠ b) :
    ¬ ∃ e : A → A → B, Surjective e := by
      intro ⟨ e, he ⟩;
      exact absurd ( lawvere_fixed_point e he f ) ( by tauto )

/-
PROBLEM
Cantor's theorem as an instance: Bool has the negation function
  which has no fixed point, so there is no surjection α → (α → Bool).

PROVIDED SOLUTION
Apply cantor_via_lawvere with f = Bool.not. Bool.not has no fixed point because not true ≠ true and not false ≠ false.
-/
theorem cantor_via_bool (α : Type*) : ¬ ∃ f : α → α → Bool, Surjective f := by
  convert cantor_via_lawvere ( Bool.not ) _;
  grobner

/-! ## Knaster-Tarski Fixed Point Theorem

The Knaster-Tarski theorem states that every monotone function on a
complete lattice has a fixed point. Rucker discusses fixed points
as fundamental to self-referential constructions.
-/

/-
PROBLEM
The Knaster-Tarski fixed point theorem: every monotone function on a
  complete lattice has a least fixed point.

PROVIDED SOLUTION
Let x = sInf {y | f y ≤ y}. Show f x = x using monotonicity and completeness. Then show x is least among fixed points.
-/
theorem knaster_tarski_lfp {α : Type*} [CompleteLattice α] (f : α → α) (hf : Monotone f) :
    ∃ x, f x = x ∧ ∀ y, f y = y → x ≤ y := by
      -- Let x = sInf {y | f y ≤ y}.
      set x := sInf { y | f y ≤ y } with hx_def;
      -- We need to show that x is indeed a fixed point.
      have hx_fixed : f x ≤ x := by
        exact le_sInf fun y hy => hf ( sInf_le hy ) |> le_trans <| hy;
      refine' ⟨ x, le_antisymm hx_fixed _, fun y hy => sInf_le hy.le ⟩;
      exact sInf_le ( hf hx_fixed )

/-
The Knaster-Tarski greatest fixed point.
-/
theorem knaster_tarski_gfp {α : Type*} [CompleteLattice α] (f : α → α) (hf : Monotone f) :
    ∃ x, f x = x ∧ ∀ y, f y = y → y ≤ x := by
      -- By the Knaster-Tarski theorem, the set {y | y ≤ f(y)} has a greatest element x.
      obtain ⟨x, hx⟩ : ∃ x, x ∈ {y | y ≤ f y} ∧ ∀ y ∈ {y | y ≤ f y}, y ≤ x := by
        refine' ⟨ sSup { y | y ≤ f y }, _, _ ⟩;
        · simp +zetaDelta at *;
          exact fun b hb => le_trans hb ( hf ( le_sSup hb ) );
        · exact fun y hy => le_sSup hy;
      refine' ⟨ x, le_antisymm _ _, fun y hy ↦ hx.2 y _ ⟩ <;> aesop;

/-! ## The Paradox of Self-Reference

Rucker discusses how self-reference leads to paradox (Russell, Berry, Richard)
but also to profound theorems (Gödel). We formalize the constructive
resolution: the diagonal lemma shows self-reference is *unavoidable*.
-/

/-
PROBLEM
No predicate can decide its own anti-diagonal.
  This is the abstract core of Russell's paradox, the liar paradox,
  and Gödel's first incompleteness theorem.

PROVIDED SOLUTION
Suppose eval is surjective and neg witnesses the anti-diagonal. Then eval neg neg ↔ ¬ eval neg neg, contradiction.
-/
theorem no_self_deciding_predicate (α : Type*) :
    ¬ ∃ (eval : α → α → Prop) (_ : Surjective eval),
      ∃ neg : α, ∀ a, eval neg a ↔ ¬ eval a a := by
        norm_num +zetaDelta at *;
        intro x hx y; use y; by_cases h : x y y <;> simp +decide [ h ] ;

/-! ## Infinity of Primes — A Concrete Diagonal Construction

Rucker discusses Euclid's proof as an early "diagonal argument":
you take everything you have and construct something new.
We formalize this as a connection to Rucker's themes.
-/

/-
Euclid's theorem: there are infinitely many primes.
  Rucker sees this as a proto-diagonal argument: given any finite
  list of primes, you construct a new one.
-/
theorem infinitely_many_primes : ∀ n : ℕ, ∃ p, p > n ∧ Nat.Prime p := by
  exact fun n => Nat.exists_infinite_primes ( n + 1 ) |> Exists.imp fun p => by aesop;

/-! ## The Berry Paradox — Definability Limits

Rucker discusses the Berry paradox: "the smallest number not definable
in fewer than twenty words." We formalize a related result about
definability in formal systems.
-/

/-
There is no function that enumerates all subsets of ℕ.
  A consequence of Cantor's theorem applied to definability.
-/
theorem no_enumeration_of_subsets :
    ¬ ∃ f : ℕ → Set ℕ, Surjective f := by
      -- Apply the fact that there is no surjection from a set to its power set.
      apply cantor_via_lawvere;
      swap;
      exact fun b => ¬b;
      grind

end Rucker.GodelianSelfReference