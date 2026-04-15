/-
# Computation and Mind — Uncomputability and the Limits of Formalism

Rudy Rucker's *The Lifebox, the Seashell, and the Soul* and *Mind Tools*
explore the connections between computation, consciousness, and mathematics.
Key themes include:

1. The Halting Problem as a computational analog of Gödel's theorem
2. The Church-Turing thesis and universal computation
3. Cellular automata as models of physical reality
4. The relationship between complexity and randomness

This module formalizes results about computability, decidability,
and the fundamental limits of formal systems that Rucker discusses.
-/
import Mathlib

open Function Set

namespace Rucker.ComputationAndMind

/-! ## Decidability and Its Limits

Rucker discusses how some mathematical questions are fundamentally
undecidable — not because we're not clever enough, but because
no algorithm can answer them.
-/

/-
The set of all subsets of ℕ is uncountable, so most subsets
  are not computable (only countably many programs exist).
  This is Rucker's "almost all reals are random" observation.
-/
theorem most_sets_uncomputable :
    ¬ ∃ f : ℕ → Set ℕ, Surjective f := by
      -- Assume for contradiction that there exists a surjective function $f$ from $\mathbb{N}$ to the power set of $\mathbb{N}$.
      by_contra h_contra
      obtain ⟨f, hf_surj⟩ := h_contra;
      -- Consider the set $S = \{n \in \mathbb{N} \mid n \notin f(n)\}$.
      set S : Set ℕ := {n | n∉f n} with hS_def;
      obtain ⟨ n, hn ⟩ := hf_surj S; have := Set.ext_iff.mp hn n; tauto;

/-! ## Fixed-Point Combinators — The Y Combinator of Logic

Rucker discusses fixed-point constructions as the mathematical
analog of self-awareness. The existence of fixed points in
various settings mirrors consciousness reflecting on itself.
-/

/-
In any complete lattice, the infimum of all pre-fixed points
  is itself a fixed point. This is the constructive core of
  Tarski's theorem, which Rucker connects to self-reference.
-/
theorem lfp_is_fixed {α : Type*} [CompleteLattice α]
    (f : α → α) (hf : Monotone f) :
    f (sInf {x | f x ≤ x}) = sInf {x | f x ≤ x} := by
      -- Let's take the exact set of elements where f x ≤ x and show that its infimum is a fixed point of f.
      have h_ex : sInf {x | f x ≤ x} ∈ {x | f x ≤ x} := by
        exact le_sInf fun x hx => hf ( sInf_le hx ) |> le_trans <| hx;
      refine' le_antisymm h_ex _;
      exact sInf_le ( hf h_ex )

/-! ## The Pigeonhole Principle — Finite Incompressibility

Rucker discusses the pigeonhole principle as the finite analog
of Cantor's theorem: you can't compress without losing information.
-/

/-
Finite pigeonhole: no injection from Fin (n+1) to Fin n.
  Rucker uses this as the starting point for understanding why
  Cantor's theorem must be true: the finite case already forces it.
-/
theorem finite_pigeonhole (n : ℕ) :
    ¬ ∃ f : Fin (n + 1) → Fin n, Injective f := by
      simp +zetaDelta at *;
      exact fun f hf => absurd ( Fintype.card_le_of_injective f hf ) ( by simp +arith +decide )

/-! ## The Countable Chain Condition

Rucker discusses how the structure of the real line reflects
deep set-theoretic properties. The reals satisfy the countable
chain condition (ccc), meaning any family of disjoint open sets
is countable.
-/

/-
ℕ × ℕ has the same cardinality as ℕ.
  Rucker: "You can list all pairs of natural numbers in a single sequence."
-/
theorem nat_prod_countable : Cardinal.mk (ℕ × ℕ) = Cardinal.mk ℕ := by
  simp +decide [ Cardinal.mk_prod ]

/-
The rationals are dense in the reals. Connected to Rucker's
  discussion of how countable and uncountable coexist.
-/
theorem rationals_dense : Dense (Set.range (fun q : ℚ => (q : ℝ))) := by
  exact Rat.isDenseEmbedding_coe_real.dense

/-! ## Infinity Arithmetic Paradoxes

Rucker loves presenting the "paradoxes" of infinite arithmetic
that challenge our finite intuitions.
-/

/-
Hilbert's Hotel: ℕ is equinumerous with ℕ \ {0}.
  "A hotel with infinitely many rooms can accommodate one more guest."
-/
theorem hilbert_hotel : ∃ f : ℕ → {n : ℕ | n ≠ 0}, Bijective f := by
  fconstructor;
  exact fun n => ⟨ n + 1, Nat.succ_ne_zero n ⟩;
  exact ⟨ fun a b h => by simpa using congr_arg Subtype.val h, fun a => ⟨ a - 1, by rcases a with ⟨ _ | a, ha ⟩ <;> trivial ⟩ ⟩

/-
The even natural numbers are equinumerous with all natural numbers.
  "Half of infinity is still infinity."
-/
theorem evens_equinumerous :
    ∃ f : ℕ → {n : ℕ | Even n}, Bijective f := by
      fconstructor;
      exact fun n => ⟨ 2 * n, even_two_mul n ⟩;
      exact ⟨ fun a b h => by simpa using congr_arg Subtype.val h, fun a => ⟨ a.1 / 2, by simpa [ Nat.mul_div_cancel' ( even_iff_two_dvd.mp a.2 ) ] ⟩ ⟩

/-
ℤ is equinumerous with ℕ. "The integers are countable."
-/
theorem int_equinumerous_nat :
    Cardinal.mk ℤ = Cardinal.mk ℕ := by
      simp +zetaDelta at *

end Rucker.ComputationAndMind