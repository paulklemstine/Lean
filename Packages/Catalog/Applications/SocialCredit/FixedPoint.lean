import Mathlib

/-!
# Social Credit Scores as Fixed-Point Attractors

We model a **social credit system** as a map assigning to each member of a
population a *score* living in a totally ordered set (here the real line `ℝ`,
the prototypical complete, totally ordered value space).  Two structural
phenomena are made precise.

* **Extremal members.** On a compact population a continuous scoring map always
  realises a highest- and a lowest-scoring member (`credit_attains_max`,
  `credit_attains_min`).  This is the topological reason a social credit system
  always has identifiable "best" and "worst" ranked individuals.

* **Attractors of the update dynamics.** Credit is not static: each round a
  member's score is revised by a *reward* `c` plus a *damped memory* `k · (old
  score)` of the previous value.  When the damping factor satisfies
  `0 ≤ k < 1` the update map is a contraction, and every starting score
  converges to a single equilibrium `c / (1 - k)`, independent of the initial
  condition (`creditIterate_tendsto`).  The equilibrium is the unique fixed
  point (`creditEquilibrium_unique`).

* **Order-theoretic attractors.** Even without any contraction or continuity
  assumption, a *monotone* credit map on the score interval `[0,1]` must have an
  equilibrium score (`monotone_credit_has_fixedPoint`): a Knaster–Tarski fixed
  point obtained as the supremum of the sub-fixed points.
-/

open Filter Topology

namespace SocialCredit

/-! ## Extremal members of a compact population -/

/-
A continuous credit map on a nonempty compact population attains a maximum:
there is a highest-scoring member.
-/
theorem credit_attains_max {X : Type*} [TopologicalSpace X] [CompactSpace X]
    [Nonempty X] (f : X → ℝ) (hf : Continuous f) :
    ∃ a, ∀ x, f x ≤ f a := by
  have h_compact : IsCompact (Set.range f) := by
    exact isCompact_range hf;
  exact h_compact.exists_isGreatest ( Set.range_nonempty f ) |> fun ⟨ a, ha₁, ha₂ ⟩ => by rcases ha₁ with ⟨ x, rfl ⟩ ; exact ⟨ x, fun y => ha₂ ( Set.mem_range_self y ) ⟩ ;

/-
A continuous credit map on a nonempty compact population attains a minimum:
there is a lowest-scoring member.
-/
theorem credit_attains_min {X : Type*} [TopologicalSpace X] [CompactSpace X]
    [Nonempty X] (f : X → ℝ) (hf : Continuous f) :
    ∃ b, ∀ x, f b ≤ f x := by
  -- Let `Y` be the range of `f`. Since `X` is compact, `Y` is also compact.
  set Y : Set ℝ := Set.range f
  have hY : IsCompact Y := by
    exact isCompact_range hf;
  exact hY.exists_isLeast ( Set.range_nonempty _ ) |> fun ⟨ y, hy ⟩ => by rcases hy.1 with ⟨ x, rfl ⟩ ; exact ⟨ x, fun y => hy.2 ( Set.mem_range_self _ ) ⟩ ;

/-! ## The affine credit-update dynamics -/

/-- One round of credit revision: a fixed reward `c` plus a damped memory
`k · x` of the previous score `x`. -/
def creditStep (c k x : ℝ) : ℝ := c + k * x

/-- The score after `n` rounds of revision, starting from an initial score `x₀`. -/
def creditIterate (c k x₀ : ℝ) (n : ℕ) : ℝ := (creditStep c k)^[n] x₀

/-- The equilibrium (long-run) credit score `c / (1 - k)`. -/
noncomputable def creditEquilibrium (c k : ℝ) : ℝ := c / (1 - k)

/-
The equilibrium score is a fixed point of the update map.
-/
theorem creditStep_equilibrium (c k : ℝ) (hk : k ≠ 1) :
    creditStep c k (creditEquilibrium c k) = creditEquilibrium c k := by
  unfold creditStep creditEquilibrium;
  grind

/-
Closed form for the score after `n` rounds.
-/
theorem creditIterate_closed_form (c k x₀ : ℝ) (hk : k ≠ 1) (n : ℕ) :
    creditIterate c k x₀ n = k ^ n * x₀ + c * (1 - k ^ n) / (1 - k) := by
  have hk' : (1 - k) ≠ 0 := sub_ne_zero.mpr (Ne.symm hk)
  induction n with
  | zero => simp [creditIterate]
  | succ n ih =>
    rw [creditIterate, Function.iterate_succ_apply', ← creditIterate, ih, creditStep, pow_succ]
    field_simp
    ring

/-
**Fixed-point attractor.**  With damping `0 ≤ k < 1`, every starting score
converges to the equilibrium, independently of the initial condition.
-/
theorem creditIterate_tendsto (c k x₀ : ℝ) (hk0 : 0 ≤ k) (hk1 : k < 1) :
    Tendsto (creditIterate c k x₀) atTop (𝓝 (creditEquilibrium c k)) := by
  rw [ show creditIterate c k x₀ = _ from funext fun n => creditIterate_closed_form c k x₀ ( ne_of_lt hk1 ) n ];
  convert Filter.Tendsto.add ( Filter.Tendsto.mul ( tendsto_pow_atTop_nhds_zero_of_lt_one hk0 hk1 ) tendsto_const_nhds ) ( Filter.Tendsto.div_const ( tendsto_const_nhds.mul ( tendsto_const_nhds.sub ( tendsto_pow_atTop_nhds_zero_of_lt_one hk0 hk1 ) ) ) _ ) using 2 ; norm_num [ creditEquilibrium ]

/-
The equilibrium is the *unique* fixed point of the update map (for `k ≠ 1`).
-/
theorem creditEquilibrium_unique (c k y : ℝ) (hk : k ≠ 1)
    (hy : creditStep c k y = y) : y = creditEquilibrium c k := by
  exact eq_div_of_mul_eq ( sub_ne_zero_of_ne <| Ne.symm hk ) <| by rw [ show creditStep c k y = c + k * y by rfl ] at hy; linarith;

/-! ## Order-theoretic attractor: Knaster–Tarski on the score interval -/

/-
**Knaster–Tarski for credit scores.**  A monotone credit map that keeps
scores inside `[0,1]` always has an equilibrium score in `[0,1]`, with no
continuity or contraction hypothesis.
-/
theorem monotone_credit_has_fixedPoint (f : ℝ → ℝ) (hmono : Monotone f)
    (hmaps : ∀ x ∈ Set.Icc (0:ℝ) 1, f x ∈ Set.Icc (0:ℝ) 1) :
    ∃ x ∈ Set.Icc (0:ℝ) 1, f x = x := by
  by_contra! h_contra;
  -- Let $S := {x : ℝ | x ∈ Set.Icc (0:ℝ) 1 ∧ x ≤ f x}$.
  set S := {x : ℝ | x ∈ Set.Icc (0:ℝ) 1 ∧ x ≤ f x} with hS_def

  -- Note $0 ∈ S$: $0 ∈ Icc 0 1$, and $f 0 ∈ Icc 0 1$ (from `hmaps`) gives $0 ≤ f 0$.
  have h0_in_S : (0 : ℝ) ∈ S := by
    exact ⟨ by norm_num, hmaps 0 ( by norm_num ) |>.1 ⟩

  -- So `S` is nonempty.
  have hS_nonempty : S.Nonempty := by
    exact ⟨ _, h0_in_S ⟩

  -- `S` is bounded above by `1` (every element is in `Icc 0 1`).
  have hS_bdd_above : BddAbove S := by
    exact ⟨ 1, fun x hx => hx.1.2 ⟩

  -- Let `s := sSup S`. Then `0 ≤ s` (since `0 ∈ S` and `le_csSup`) and `s ≤ 1` (since `1` is an upper bound and `csSup_le`).
  set s := sSup S with hs_def
  have hs_bounds : s ∈ Set.Icc (0:ℝ) 1 := by
    exact ⟨ le_trans h0_in_S.1.1 <| le_csSup hS_bdd_above h0_in_S, csSup_le hS_nonempty fun x hx => hx.1.2 ⟩;
  -- Show `s ≤ f s`: For any `x ∈ S`, `x ≤ s` (`le_csSup`), so `f x ≤ f s` by `hmono`; combined with `x ≤ f x` gives `x ≤ f s`. Thus `f s` is an upper bound of `S`, so `s = sSup S ≤ f s` by `csSup_le` (S nonempty).
  have hs_le_fs : s ≤ f s := by
    exact csSup_le hS_nonempty fun x hx => le_trans hx.2 <| hmono <| le_csSup hS_bdd_above hx;
  exact h_contra s hs_bounds <| le_antisymm ( by exact le_csSup hS_bdd_above ⟨ hmaps s hs_bounds, by linarith [ hmono hs_le_fs ] ⟩ ) hs_le_fs

end SocialCredit