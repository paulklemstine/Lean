/-! # CatalogBuild.Logic.CantorDiagonal_2

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 14
-/

import Mathlib

/-- [Section: ## Section 1: The Core Diagonal Argument
Cantor's theorem: there is no surjection from any set `α` to its power set `Set α`.
This is the foundational result from which everything else flows.] -/
theorem cantor_antidiagonal_not_in_range (f : α → Set α) :
    {x | x ∉ f x} ∉ Set.range f := by
  simp +zetaDelta at *;
  intro x hx; replace hx := Set.ext_iff.mp hx x; tauto;


theorem cantor_no_injection_powerset_to_base [Nonempty α] :
    ¬∃ g : Set α → α, Function.Injective g := by
  by_contra! h_inj;
  have := Cardinal.cantor ( Cardinal.mk α );
  obtain ⟨ g, hg ⟩ := h_inj;
  have := Cardinal.mk_le_of_injective hg;
  simp +zetaDelta at *;
  exact not_le_of_gt ‹_› this


/-- [Section: ## Section 2: The Uncountability of the Reals
The most famous application: ℝ is uncountable. This follows from the diagonal
argument applied to binary sequences, or more directly from Cantor's theorem
since |ℝ| = |𝒫(ℕ)| = 2^ℵ₀.] -/
theorem binary_sequences_uncountable :
    ¬∃ f : ℕ → (ℕ → Bool), Function.Surjective f := by
  simp +zetaDelta at *;
  intro f hf; have := hf; rw [ Function.Surjective ] at this; simp_all +decide [ funext_iff, Set.ext_iff ] ; (
  exact absurd ( this ( fun n => if f n n = Bool.true then Bool.false else Bool.true ) ) ( by rintro ⟨ a, ha ⟩ ; specialize ha a ; aesop ));


theorem unit_interval_uncountable : ¬Countable (Set.Icc (0 : ℝ) 1) := by
  aesop


/-- [Section: ## Section 3: The Cardinal Hierarchy
Cantor's theorem creates an infinite tower of strictly increasing cardinals.
For any cardinal κ, we have κ < 2^κ. There is no "largest" infinity.] -/
theorem cantor_cardinal_strict_lt (κ : Cardinal) : κ < 2 ^ κ := by
  exact?


theorem no_largest_cardinal (κ : Cardinal) : ∃ μ, κ < μ := by
  exact ⟨ _, Cardinal.cantor κ ⟩


theorem nat_lt_real_cardinal : Cardinal.mk ℕ < Cardinal.mk ℝ := by
  -- The cardinality of the natural numbers is ℵ₀, and the cardinality of the real numbers is 2^ℵ₀.
  have h_card_nat : Cardinal.mk ℕ = Cardinal.aleph0 := by
    exact Cardinal.mk_nat
  have h_card_real : Cardinal.mk ℝ = 2 ^ Cardinal.aleph0 := by
    simp +decide [ Cardinal.mk_real ];
  exact h_card_nat.symm ▸ h_card_real.symm ▸ Cardinal.cantor _


/-- [Section: ## Section 4: Connections to Computability — The Halting Problem
Turing's proof that the halting problem is undecidable uses exactly the same
diagonal structure as Cantor's argument. If a machine H could decide halting
for all machines, we construct a machine D that does the opposite of what H
predicts for D — a contradiction by diagonalization.
We formalize the abstract structure: no computable enumeration can capture all
decidable predicates on ℕ.] -/
theorem no_surjection_nat_to_nat_nat :
    ¬∃ f : ℕ → (ℕ → ℕ), Function.Surjective f := by
  simp +zetaDelta at *;
  exact fun f hf => by have := hf ( fun n => f n n + 1 ) ; obtain ⟨ n, hn ⟩ := this; have := congr_fun hn n; norm_num at this;


/-- [Section: ## Section 6: Russell's Paradox as Diagonalization
Russell's paradox — "the set of all sets that don't contain themselves" —
is precisely the diagonal set `{x | x ∉ f x}` applied to the identity
function on a hypothetical "set of all sets." Cantor's argument thus
explains WHY naive set theory is inconsistent.] -/
theorem russell_as_diagonalization :
    ∀ f : α → Set α, {x | x ∉ f x} ≠ f a := by
  exact fun f h => by simpa using congr_arg ( fun s => a ∈ s ) h;


/-- [Section: ## Section 7: König's Theorem and Cofinality
König's theorem, another diagonal-style argument, states that the sum
of a family of cardinals is strictly less than the product of a family
of strictly larger cardinals. It constrains cardinal arithmetic and
shows, for example, that cf(2^ℵ₀) > ℵ₀.] -/
theorem aleph0_lt_continuum : Cardinal.aleph0 < Cardinal.continuum := by
  exact Cardinal.aleph0_lt_continuum


/-- [Section: ## Section 8: The Schröder-Bernstein Theorem
While Cantor's theorem shows certain injections/surjections cannot exist,
the Schröder-Bernstein theorem provides a positive tool: if there exist
injections in both directions between two sets, then they are in bijection.] -/
theorem schroder_bernstein_cardinal (κ μ : Cardinal) (h1 : κ ≤ μ) (h2 : μ ≤ κ) :
    κ = μ := by
  exact le_antisymm h1 h2


/-- [Section: ## Section 9: Cantor's Theorem in Topology — The Cantor Set
The Cantor ternary set (middle-thirds) is homeomorphic to `ℕ → Bool`
(the Cantor space {0,1}^ℕ). Despite having Lebesgue measure zero,
it is uncountable (by the diagonal argument!), perfect, and nowhere dense.
It is the universal compact metrizable zero-dimensional space.] -/
theorem cantor_space_uncountable : ¬Countable (ℕ → Bool) := by
  -- The space of functions from ℕ to Bool is uncountable because it has cardinality 2^ℵ₀.
  have h_card : Cardinal.mk (ℕ → Bool) = 2 ^ Cardinal.aleph0 := by
    simp +decide [ Cardinal.mk_real ];
  intro h_countable;
  exact absurd ( Cardinal.mk_le_aleph0_iff.mpr h_countable ) ( by rw [ h_card ] ; exact not_le_of_gt ( Cardinal.cantor _ ) )


/-- **The Continuum Hypothesis as a formal statement.**
CH asserts that the cardinality of the continuum equals ℵ₁. -/
def ContinuumHypothesis : Prop :=
  Cardinal.continuum.{0} = Cardinal.aleph.{0} 1


/-- [Section: ## Section 11: Diagonal Arguments in Analysis — Arzelà-Ascoli Style
The diagonal argument appears throughout analysis in "diagonal extraction"
proofs: given a sequence of sequences, extract a subsequence that converges
on a countable dense subset, then extend by density. This technique proves:
- Arzelà-Ascoli theorem
- Bolzano-Weierstrass in infinite dimensions
- Compactness in function spaces
We formalize a key consequence: every bounded sequence in ℝ has a
convergent subsequence (Bolzano-Weierstrass).] -/
theorem bolzano_weierstrass_real (a : ℕ → ℝ) (M : ℝ) (hM : ∀ n, |a n| ≤ M) :
    ∃ (b : ℕ → ℕ), StrictMono b ∧ ∃ L, Filter.Tendsto (a ∘ b) Filter.atTop (nhds L) := by
  have h_compact : IsCompact (Metric.closedBall (0 : ℝ) M) := by
    exact ProperSpace.isCompact_closedBall _ _;
  have := h_compact.isSeqCompact fun n => mem_closedBall_zero_iff.mpr ( hM n ) ; aesop;
