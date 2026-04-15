/-! # CatalogBuild.Logic.CantorDiagonal_2

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 14
-/

import Mathlib

theorem cantor_antidiagonal_not_in_range (f : α → Set α) :
    {x | x ∉ f x} ∉ Set.range f := by
  simp +zetaDelta at *;
  intro x hx; replace hx := Set.ext_iff.mp hx x; tauto;

/-
PROBLEM
**Cantor's Theorem (no surjection form).**
There is no surjective function from a type to its power set.

PROVIDED SOLUTION
Use cantor_antidiagonal_not_in_range or Mathlib's Function.cantor_surjective.
-/

theorem cantor_no_injection_powerset_to_base [Nonempty α] :
    ¬∃ g : Set α → α, Function.Injective g := by
  by_contra! h_inj;
  have := Cardinal.cantor ( Cardinal.mk α );
  obtain ⟨ g, hg ⟩ := h_inj;
  have := Cardinal.mk_le_of_injective hg;
  simp +zetaDelta at *;
  exact not_le_of_gt ‹_› this

/-!
## Section 2: The Uncountability of the Reals

The most famous application: ℝ is uncountable. This follows from the diagonal
argument applied to binary sequences, or more directly from Cantor's theorem
since |ℝ| = |𝒫(ℕ)| = 2^ℵ₀.
-/

/-
PROBLEM
**ℕ → Bool is uncountable** (the space of binary sequences).
This is the "raw" diagonal argument on sequences.

PROVIDED SOLUTION
Given f : ℕ → (ℕ → Bool), the anti-diagonal g(n) = !f(n)(n) differs from every f(n). So f is not surjective.
-/

theorem binary_sequences_uncountable :
    ¬∃ f : ℕ → (ℕ → Bool), Function.Surjective f := by
  simp +zetaDelta at *;
  intro f hf; have := hf; rw [ Function.Surjective ] at this; simp_all +decide [ funext_iff, Set.ext_iff ] ; (
  exact absurd ( this ( fun n => if f n n = Bool.true then Bool.false else Bool.true ) ) ( by rintro ⟨ a, ha ⟩ ; specialize ha a ; aesop ));

/-
PROBLEM
**The real numbers are uncountable.**
This is the most celebrated consequence of the diagonal argument.

PROVIDED SOLUTION
Use Cardinal.not_countable_real or the fact that Cardinal.mk ℝ = continuum > aleph0.
-/

theorem unit_interval_uncountable : ¬Countable (Set.Icc (0 : ℝ) 1) := by
  aesop

/-!
## Section 3: The Cardinal Hierarchy

Cantor's theorem creates an infinite tower of strictly increasing cardinals.
For any cardinal κ, we have κ < 2^κ. There is no "largest" infinity.
-/

/-
PROBLEM
**Cantor's theorem on cardinals:** every cardinal is strictly less
than its power (2^κ). This generates the infinite hierarchy of infinities.

PROVIDED SOLUTION
Use Cardinal.cantor from Mathlib.
-/

theorem cantor_cardinal_strict_lt (κ : Cardinal) : κ < 2 ^ κ := by
  exact?

/-
PROBLEM
**No largest cardinal.** For every cardinal, there exists a strictly larger one.

PROVIDED SOLUTION
Use cantor_cardinal_strict_lt: take μ = 2^κ.
-/

theorem no_largest_cardinal (κ : Cardinal) : ∃ μ, κ < μ := by
  exact ⟨ _, Cardinal.cantor κ ⟩

/-
PROBLEM
**The natural numbers are strictly smaller than the reals (as cardinals).**

PROVIDED SOLUTION
Cardinal.mk ℕ = aleph0, Cardinal.mk ℝ = continuum, and aleph0 < continuum by Cardinal.aleph0_lt_continuum.
-/

theorem nat_lt_real_cardinal : Cardinal.mk ℕ < Cardinal.mk ℝ := by
  -- The cardinality of the natural numbers is ℵ₀, and the cardinality of the real numbers is 2^ℵ₀.
  have h_card_nat : Cardinal.mk ℕ = Cardinal.aleph0 := by
    exact Cardinal.mk_nat
  have h_card_real : Cardinal.mk ℝ = 2 ^ Cardinal.aleph0 := by
    simp +decide [ Cardinal.mk_real ];
  exact h_card_nat.symm ▸ h_card_real.symm ▸ Cardinal.cantor _

/-!
## Section 4: Connections to Computability — The Halting Problem

Turing's proof that the halting problem is undecidable uses exactly the same
diagonal structure as Cantor's argument. If a machine H could decide halting
for all machines, we construct a machine D that does the opposite of what H
predicts for D — a contradiction by diagonalization.

We formalize the abstract structure: no computable enumeration can capture all
decidable predicates on ℕ.
-/

/-
PROBLEM
**Diagonal lemma for functions ℕ → ℕ.**
No enumeration of functions ℕ → ℕ can be surjective —
there are uncountably many such functions.

PROVIDED SOLUTION
Given f : ℕ → (ℕ → ℕ), define g(n) = f(n)(n) + 1. Then g differs from every f(n).
-/

theorem no_surjection_nat_to_nat_nat :
    ¬∃ f : ℕ → (ℕ → ℕ), Function.Surjective f := by
  simp +zetaDelta at *;
  exact fun f hf => by have := hf ( fun n => f n n + 1 ) ; obtain ⟨ n, hn ⟩ := this; have := congr_fun hn n; norm_num at this;

/-!
## Section 5: Fixed-Point Theorems (Lawvere's Perspective)

Lawvere showed that Cantor's theorem is a special case of a general
fixed-point theorem in category theory: if there is a surjection
`α → (α → β)`, then every endofunction on `β` has a fixed point.

Contrapositively: if `β` has a fixed-point-free endofunction (like
`Bool` with `not`), then no surjection `α → (α → β)` exists.
-/

/-
PROBLEM
**Lawvere's fixed-point theorem.**
If `f : α → (α → β)` is surjective, then every function `g : β → β`
has a fixed point. This is the categorical generalization of Cantor's theorem.

PROVIDED SOLUTION
Since f is surjective as a function α → (α → β), there exists a such that f a = g ∘ (f a) ... Actually: define h : α → β by h(x) = g(f x x). Since f is surjective (as α → α → β), there exists a with f a = h. Then f a a = h a = g(f a a), so g has fixed point f a a.
-/

theorem russell_as_diagonalization :
    ∀ f : α → Set α, {x | x ∉ f x} ≠ f a := by
  exact fun f h => by simpa using congr_arg ( fun s => a ∈ s ) h;

/-!
## Section 7: König's Theorem and Cofinality

König's theorem, another diagonal-style argument, states that the sum
of a family of cardinals is strictly less than the product of a family
of strictly larger cardinals. It constrains cardinal arithmetic and
shows, for example, that cf(2^ℵ₀) > ℵ₀.
-/

/-
PROBLEM
**ℵ₀ has uncountable cofinality when exponentiated.**
A consequence of König's theorem: `2^ℵ₀` cannot have cofinality `ω`.

PROVIDED SOLUTION
Use Cardinal.aleph0_lt_continuum from Mathlib.
-/

theorem aleph0_lt_continuum : Cardinal.aleph0 < Cardinal.continuum := by
  exact Cardinal.aleph0_lt_continuum

/-!
## Section 8: The Schröder-Bernstein Theorem

While Cantor's theorem shows certain injections/surjections cannot exist,
the Schröder-Bernstein theorem provides a positive tool: if there exist
injections in both directions between two sets, then they are in bijection.
-/

/-
PROBLEM
**Schröder-Bernstein for cardinals.**
If `κ ≤ μ` and `μ ≤ κ`, then `κ = μ`.

PROVIDED SOLUTION
This is le_antisymm h1 h2.
-/

theorem schroder_bernstein_cardinal (κ μ : Cardinal) (h1 : κ ≤ μ) (h2 : μ ≤ κ) :
    κ = μ := by
  exact le_antisymm h1 h2

/-!
## Section 9: Cantor's Theorem in Topology — The Cantor Set

The Cantor ternary set (middle-thirds) is homeomorphic to `ℕ → Bool`
(the Cantor space {0,1}^ℕ). Despite having Lebesgue measure zero,
it is uncountable (by the diagonal argument!), perfect, and nowhere dense.
It is the universal compact metrizable zero-dimensional space.
-/

/-
PROBLEM
**The Cantor space {0,1}^ℕ is not countable.**

PROVIDED SOLUTION
Use the diagonal argument or show Cardinal.mk (ℕ → Bool) = 2^ℵ₀ > ℵ₀. Or use that Countable (ℕ → Bool) would give a surjection ℕ → (ℕ → Bool), contradicting binary_sequences_uncountable.
-/

theorem cantor_space_uncountable : ¬Countable (ℕ → Bool) := by
  -- The space of functions from ℕ to Bool is uncountable because it has cardinality 2^ℵ₀.
  have h_card : Cardinal.mk (ℕ → Bool) = 2 ^ Cardinal.aleph0 := by
    simp +decide [ Cardinal.mk_real ];
  intro h_countable;
  exact absurd ( Cardinal.mk_le_aleph0_iff.mpr h_countable ) ( by rw [ h_card ] ; exact not_le_of_gt ( Cardinal.cantor _ ) )

/-!
## Section 10: The Continuum Hypothesis

Cantor conjectured that there is no cardinal strictly between ℵ₀ and 2^ℵ₀.
Gödel (1940) showed CH is consistent with ZFC; Cohen (1963) showed ¬CH is
also consistent. CH is thus independent of ZFC — the diagonal argument
creates the gap but cannot determine its exact size.

We can state and verify the formal independence by showing both
CH and ¬CH are consistent with the axioms available in Lean's foundation.
Here we just state the hypothesis as a proposition.
-/

/-- **The Continuum Hypothesis as a formal statement.**
CH asserts that the cardinality of the continuum equals ℵ₁. -/

def ContinuumHypothesis : Prop :=
  Cardinal.continuum.{0} = Cardinal.aleph.{0} 1

/-!
## Section 11: Diagonal Arguments in Analysis — Arzelà-Ascoli Style

The diagonal argument appears throughout analysis in "diagonal extraction"
proofs: given a sequence of sequences, extract a subsequence that converges
on a countable dense subset, then extend by density. This technique proves:
- Arzelà-Ascoli theorem
- Bolzano-Weierstrass in infinite dimensions
- Compactness in function spaces

We formalize a key consequence: every bounded sequence in ℝ has a
convergent subsequence (Bolzano-Weierstrass).
-/

/-
PROBLEM
**Bolzano-Weierstrass (sequential compactness of bounded sets in ℝ).**
This is typically proved by iterated bisection + diagonal extraction.

PROVIDED SOLUTION
Use IsCompact.tendsto_subseq. The closed ball of radius M in ℝ is compact (isCompact_Icc or Metric.isCompact_closedBall). All a n lie in this ball by hM. Extract a convergent subsequence.
-/

theorem bolzano_weierstrass_real (a : ℕ → ℝ) (M : ℝ) (hM : ∀ n, |a n| ≤ M) :
    ∃ (b : ℕ → ℕ), StrictMono b ∧ ∃ L, Filter.Tendsto (a ∘ b) Filter.atTop (nhds L) := by
  have h_compact : IsCompact (Metric.closedBall (0 : ℝ) M) := by
    exact ProperSpace.isCompact_closedBall _ _;
  have := h_compact.isSeqCompact fun n => mem_closedBall_zero_iff.mpr ( hM n ) ; aesop;
