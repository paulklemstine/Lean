/-! # CatalogBuild.Best.10_FermatLastTheorem

Auto-generated from theorem catalog database.
Domain: Best
Declarations: 6
-/

import Mathlib

noncomputable section

/-- Fermat's Last Theorem: no positive integer solutions to aⁿ + bⁿ = cⁿ for n ≥ 3. -/
def FermatLastTheorem' : Prop :=
  ∀ n : ℕ, n ≥ 3 → ∀ a b c : ℕ, a > 0 → b > 0 → c > 0 → a ^ n + b ^ n ≠ c ^ n


theorem flt_multiple_of_exp {n m : ℕ} (_hn : n ≥ 3) (_hm : m > 0) (hdvd : n ∣ m)
    (hflt : ∀ a b c : ℕ, a > 0 → b > 0 → c > 0 → a ^ n + b ^ n ≠ c ^ n) :
    ∀ a b c : ℕ, a > 0 → b > 0 → c > 0 → a ^ m + b ^ m ≠ c ^ m := by
  -- Since $n \mid m$, we can write $m = n * k$ for some integer $k$.
  obtain ⟨k, rfl⟩ : ∃ k, m = n * k := hdvd;
  exact fun a b c ha hb hc h => hflt ( a ^ k ) ( b ^ k ) ( c ^ k ) ( pow_pos ha _ ) ( pow_pos hb _ ) ( pow_pos hc _ ) ( by ring_nf at *; linarith )

-- ═══════════════════════════════════════════════════════════════════════════════
--  §3: THE CASE n = 4 — Fermat's Infinite Descent (fits in a margin!)
-- ═══════════════════════════════════════════════════════════════════════════════


theorem fermat_n4 (a b c : ℕ) (ha : a > 0) (hb : b > 0) (hc : c > 0) :
    a ^ 4 + b ^ 4 ≠ c ^ 4 := by
  by_contra h_contra;
  convert absurd ( fermatLastTheoremFour ) _;
  unfold FermatLastTheoremFor; aesop;


theorem fermat_n4_strong (a b c : ℕ) (ha : a > 0) (hb : b > 0) (hc : c > 0) :
    a ^ 4 + b ^ 4 ≠ c ^ 2 := by
  -- Apply the known result that there are no nontrivial integer solutions to $x^4 + y^4 = z^2$.
  have h_no_solution : ∀ x y z : ℤ, x ≠ 0 → y ≠ 0 → z ≠ 0 → x ^ 4 + y ^ 4 ≠ z ^ 2 := by
    exact fun x y z a a_1 a_2 => not_fermat_42 a a_1;
  exact_mod_cast h_no_solution a b c ( by positivity ) ( by positivity ) ( by positivity )


theorem fermat_n3 (a b c : ℕ) (ha : a > 0) (hb : b > 0) (hc : c > 0) :
    a ^ 3 + b ^ 3 ≠ c ^ 3 := by
  by_contra h_contra; have := fermatLastTheoremThree; aesop;

-- ═══════════════════════════════════════════════════════════════════════════════
--  §5: THE FULL THEOREM
-- ═══════════════════════════════════════════════════════════════════════════════


/-- The full Fermat's Last Theorem, for all n ≥ 3.
This requires the full Wiles-Taylor proof machinery — it does NOT
fit in any margin.
**Status**: Mathlib defines `FermatLastTheorem` but its proof is not
yet in Mathlib (it is an ongoing formalization project). The cases
n = 3 and n = 4 are proved above. The full theorem remains sorry'd
here, awaiting the completion of the Lean formalization of Wiles' proof. -/
theorem fermat_last_theorem_full : FermatLastTheorem' := by
  sorry

-- ═══════════════════════════════════════════════════════════════════════════════
--  §6: WHY NO MARGIN PROOF EXISTS (Informal Argument)
-- ═══════════════════════════════════════════════════════════════════════════════


end
