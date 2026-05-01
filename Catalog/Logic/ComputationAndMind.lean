import Mathlib

/-! # CatalogBuild.Logic.ComputationAndMind

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 8
-/

/-- [Section: # CatalogBuild.Logic.ComputationAndMind
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 8] -/
theorem most_sets_uncomputable :
    ¬ ∃ f : ℕ → Set ℕ, Surjective f := by
      -- Assume for contradiction that there exists a surjective function $f$ from $\mathbb{N}$ to the power set of $\mathbb{N}$.
      by_contra h_contra
      obtain ⟨f, hf_surj⟩ := h_contra;
      -- Consider the set $S = \{n \in \mathbb{N} \mid n \notin f(n)\}$.
      set S : Set ℕ := {n | n∉f n} with hS_def;
      obtain ⟨ n, hn ⟩ := hf_surj S; have := Set.ext_iff.mp hn n; tauto;

/-- [Section: # CatalogBuild.Logic.ComputationAndMind
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 8] -/
theorem lfp_is_fixed {α : Type*} [CompleteLattice α]
    (f : α → α) (hf : Monotone f) :
    f (sInf {x | f x ≤ x}) = sInf {x | f x ≤ x} := by
      -- Let's take the exact set of elements where f x ≤ x and show that its infimum is a fixed point of f.
      have h_ex : sInf {x | f x ≤ x} ∈ {x | f x ≤ x} := by
        exact le_sInf fun x hx => hf ( sInf_le hx ) |> le_trans <| hx;
      refine' le_antisymm h_ex _;
      exact sInf_le ( hf h_ex )

theorem finite_pigeonhole (n : ℕ) :
    ¬ ∃ f : Fin (n + 1) → Fin n, Injective f := by
      simp +zetaDelta at *;
      exact fun f hf => absurd ( Fintype.card_le_of_injective f hf ) ( by simp +arith +decide )

theorem nat_prod_countable : Cardinal.mk (ℕ × ℕ) = Cardinal.mk ℕ := by
  simp +decide [ Cardinal.mk_prod ]

theorem rationals_dense : Dense (Set.range (fun q : ℚ => (q : ℝ))) := by
  exact Rat.isDenseEmbedding_coe_real.dense

theorem hilbert_hotel : ∃ f : ℕ → {n : ℕ | n ≠ 0}, Bijective f := by
  fconstructor;
  exact fun n => ⟨ n + 1, Nat.succ_ne_zero n ⟩;
  exact ⟨ fun a b h => by simpa using congr_arg Subtype.val h, fun a => ⟨ a - 1, by rcases a with ⟨ _ | a, ha ⟩ <;> trivial ⟩ ⟩

theorem evens_equinumerous :
    ∃ f : ℕ → {n : ℕ | Even n}, Bijective f := by
      fconstructor;
      exact fun n => ⟨ 2 * n, even_two_mul n ⟩;
      exact ⟨ fun a b h => by simpa using congr_arg Subtype.val h, fun a => ⟨ a.1 / 2, by simpa [ Nat.mul_div_cancel' ( even_iff_two_dvd.mp a.2 ) ] ⟩ ⟩

theorem int_equinumerous_nat :
    Cardinal.mk ℤ = Cardinal.mk ℕ := by
      simp +zetaDelta at *