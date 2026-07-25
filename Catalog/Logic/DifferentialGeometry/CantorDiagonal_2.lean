import Mathlib

/-! # CatalogBuild.Logic.CantorDiagonal_2

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 14
-/

/-- [Section: # CatalogBuild.Logic.CantorDiagonal_2
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 14] -/
theorem cantor_antidiagonal_not_in_range (f : α → Set α) :
    {x | x ∉ f x} ∉ Set.range f := by
  simp +zetaDelta at *;
  intro x hx; replace hx := Set.ext_iff.mp hx x; tauto;

/-- [Section: # CatalogBuild.Logic.CantorDiagonal_2
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 14] -/
theorem cantor_no_injection_powerset_to_base [Nonempty α] :
    ¬∃ g : Set α → α, Function.Injective g := by
  by_contra! h_inj;
  have := Cardinal.cantor ( Cardinal.mk α );
  obtain ⟨ g, hg ⟩ := h_inj;
  have := Cardinal.mk_le_of_injective hg;
  simp +zetaDelta at *;
  exact not_le_of_gt ‹_› this

theorem binary_sequences_uncountable :
    ¬∃ f : ℕ → (ℕ → Bool), Function.Surjective f := by
  simp +zetaDelta at *;
  intro f hf; have := hf; rw [ Function.Surjective ] at this; simp_all +decide [ funext_iff, Set.ext_iff ] ; (
  exact absurd ( this ( fun n => if f n n = Bool.true then Bool.false else Bool.true ) ) ( by rintro ⟨ a, ha ⟩ ; specialize ha a ; aesop ));

theorem unit_interval_uncountable : ¬Countable (Set.Icc (0 : ℝ) 1) := by
  aesop

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

theorem no_surjection_nat_to_nat_nat :
    ¬∃ f : ℕ → (ℕ → ℕ), Function.Surjective f := by
  simp +zetaDelta at *;
  exact fun f hf => by have := hf ( fun n => f n n + 1 ) ; obtain ⟨ n, hn ⟩ := this; have := congr_fun hn n; norm_num at this;

theorem russell_as_diagonalization :
    ∀ f : α → Set α, {x | x ∉ f x} ≠ f a := by
  exact fun f h => by simpa using congr_arg ( fun s => a ∈ s ) h;

theorem aleph0_lt_continuum : Cardinal.aleph0 < Cardinal.continuum := by
  exact Cardinal.aleph0_lt_continuum

theorem schroder_bernstein_cardinal (κ μ : Cardinal) (h1 : κ ≤ μ) (h2 : μ ≤ κ) :
    κ = μ := by
  exact le_antisymm h1 h2

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

theorem bolzano_weierstrass_real (a : ℕ → ℝ) (M : ℝ) (hM : ∀ n, |a n| ≤ M) :
    ∃ (b : ℕ → ℕ), StrictMono b ∧ ∃ L, Filter.Tendsto (a ∘ b) Filter.atTop (nhds L) := by
  have h_compact : IsCompact (Metric.closedBall (0 : ℝ) M) := by
    exact ProperSpace.isCompact_closedBall _ _;
  have := h_compact.isSeqCompact fun n => mem_closedBall_zero_iff.mpr ( hM n ) ; aesop;