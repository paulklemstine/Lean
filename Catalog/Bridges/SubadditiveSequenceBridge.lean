import Mathlib

/-! # Subadditive Sequence Bridge

Fekete's Subadditive Lemma: subadditive sequences u(n+m) ≤ u(n)+u(m)
have convergent u(n)/n. The limit equals inf{u(n)/n}.

Key applications: entropy rates, spectral radii, growth rates, tropical math.
-/

namespace SubadditiveSequenceBridge

/-! ## Section 1: Fekete's Subadditive Lemma -/

/-- A sequence is subadditive iff u(n+m) ≤ u(n) + u(m). -/
theorem subadditive_def (u : ℕ → ℝ) :
    Subadditive u ↔ ∀ n m, u (n + m) ≤ u n + u m :=
  Iff.rfl

/-- **Fekete's Lemma** (convergence): For subadditive u with u(n)/n
    bounded below, u(n)/n converges to h.lim. -/
theorem fekete_convergence {u : ℕ → ℝ} (h : Subadditive u)
    (hbdd : BddBelow (Set.range fun n => u n / (n : ℝ))) :
    Filter.Tendsto (fun n => u n / (n : ℝ)) Filter.atTop (nhds h.lim) :=
  Subadditive.tendsto_lim h hbdd

/-- **Fekete's Lemma** (inequality): h.lim ≤ u(n)/n for all n ≥ 1. -/
theorem fekete_bound {u : ℕ → ℝ} (h : Subadditive u)
    (hbdd : BddBelow (Set.range fun n => u n / (n : ℝ)))
    {n : ℕ} (hn : n ≠ 0) :
    h.lim ≤ u n / (n : ℝ) :=
  Subadditive.lim_le_div h hbdd hn

/-! ## Section 2: Examples -/

/-- Constant sequences are subadditive for non-negative constants. -/
theorem constant_subadditive (c : ℝ) (hc : 0 ≤ c) :
    Subadditive (fun _ => c) :=
  fun _ _ => by dsimp; linarith

/-- Negated subadditive satisfies superadditive inequality. -/
theorem neg_superadditive (u : ℕ → ℝ) (h : Subadditive u) (n m : ℕ) :
    -u n + -u m ≤ -u (n + m) := by
  linarith [h n m]

/-- Subadditive doubling: u(n+n) ≤ u(n) + u(n). -/
theorem subadditive_double (u : ℕ → ℝ) (h : Subadditive u) (n : ℕ) :
    u (n + n) ≤ u n + u n :=
  h n n

end SubadditiveSequenceBridge