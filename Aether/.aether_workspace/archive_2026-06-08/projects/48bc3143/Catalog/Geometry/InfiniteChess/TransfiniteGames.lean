/-
# Transfinite Game Values: The ω^ω Hierarchy in Infinite Chess

We develop the theory of well-founded games with ordinal game values,
focusing on constructions that mirror the transfinite hierarchy arising
in infinite chess.

## Main Results

1. Well-founded game framework with ordinal-valued game positions
2. The ordinal game construction: for every ordinal α, a game with value α
3. The ω^n hierarchy: strict separation of complexity levels
4. ω^ω as the supremum of the hierarchy
5. Cofinality and limit ordinal characterization results
6. Cross-domain bridge: well-order rank = game value

## Mathematical Context

Evans and Hamkins (2014) showed that game values in infinite chess can be
any countable ordinal. Our formalization captures the key algebraic structure:
ordinal arithmetic governs game composition.
-/
import Mathlib

open Ordinal

/-! ## Part 1: Well-Founded Games -/

/-- A well-founded two-player game with positions and a move relation. -/
structure WFGame where
  Pos : Type
  moves : Pos → Set Pos
  wf : WellFounded (fun q p => q ∈ moves p)

/-- The game value (ordinal rank) of a position in a well-founded game. -/
noncomputable def WFGame.gameValue (G : WFGame) : G.Pos → Ordinal.{0} :=
  G.wf.fix fun p ih =>
    ⨆ q : { q // q ∈ G.moves p }, Order.succ (ih q.1 q.2)

/-- The game value satisfies its defining recursion. -/
theorem WFGame.gameValue_eq (G : WFGame) (p : G.Pos) :
    G.gameValue p = ⨆ q : { q // q ∈ G.moves p }, Order.succ (G.gameValue q.1) := by
  unfold gameValue; convert G.wf.fix_eq _ p using 1

/-- A position with no moves has game value 0. -/
theorem WFGame.gameValue_terminal (G : WFGame) (p : G.Pos)
    (h : ∀ q, q ∉ G.moves p) : G.gameValue p = 0 := by
  rw [gameValue_eq]
  have hempty : IsEmpty { q // q ∈ G.moves p } := ⟨fun ⟨q, hq⟩ => absurd hq (h q)⟩
  simp

/-- Game value is strictly greater than the value of any successor. -/
theorem WFGame.gameValue_lt_of_move (G : WFGame) {p q : G.Pos}
    (h : q ∈ G.moves p) : G.gameValue q < G.gameValue p := by
  conv_rhs => rw [gameValue_eq]
  exact lt_of_lt_of_le (Order.lt_succ (G.gameValue q))
    (le_ciSup (Ordinal.bddAbove_of_small _) (⟨q, h⟩ : { q // q ∈ G.moves p }))

/-! ## Part 2: The Ordinal Game — Universal Construction -/

/-- The ordinal game on α: positions are elements of α.out, moves go downward. -/
noncomputable def ordinalGame (α : Ordinal.{0}) : WFGame where
  Pos := α.out.α
  moves := fun p => { q | α.out.r q p }
  wf := α.out.wo.wf

/-
The ordinal game has the correct game value at each position.
-/
theorem ordinalGame_gameValue (α : Ordinal.{0}) (p : α.out.α) :
    (ordinalGame α).gameValue p = Ordinal.typein α.out.r p := by
  by_contra h_contra;
  -- Let $p$ be the minimal counterexample with respect to the well-founded relation $\alpha.out.r$.
  obtain ⟨p, hp⟩ : ∃ p : α.out.α, ¬(ordinalGame α).gameValue p = typein α.out.r p ∧ ∀ q : α.out.α, α.out.r q p → (ordinalGame α).gameValue q = typein α.out.r q := by
    have := α.out.wo.wf.has_min { p : α.out.α | ¬ ( ordinalGame α ).gameValue p = typein α.out.r p } ⟨ p, h_contra ⟩;
    exact ⟨ this.choose, this.choose_spec.1, fun q hq => Classical.not_not.1 fun hq' => this.choose_spec.2 q hq' hq ⟩;
  refine' hp.1 ( le_antisymm _ _ );
  · rw [ WFGame.gameValue_eq ];
    refine' ciSup_le' _;
    simp +zetaDelta at *;
    exact fun q hq => hp.2 q hq ▸ ( typein_lt_typein _ ).mpr hq;
  · refine' le_of_forall_lt fun x hx => _;
    -- Since $x < \text{typein}(\alpha.out.r, p)$, there exists some $q$ such that $\text{typein}(\alpha.out.r, q) = x$ and $\alpha.out.r q p$.
    obtain ⟨q, hq⟩ : ∃ q : α.out.α, typein α.out.r q = x ∧ α.out.r q p := by
      exact?;
    have := WFGame.gameValue_lt_of_move ( ordinalGame α ) hq.2; aesop;

/-
For any ordinal α, there exists a game with game value α.
-/
theorem exists_game_value (α : Ordinal.{0}) :
    ∃ G : WFGame, ∃ p : G.Pos, G.gameValue p = α := by
  by_contra h_contra;
  -- By definition of ordinalGame, there exists a position p in the ordinal game on Order.succ α with typein = α.
  obtain ⟨p, hp⟩ : ∃ p : (α + 1).out.α, Ordinal.typein (α + 1).out.r p = α := by
    have h_typein : Ordinal.type (α + 1).out.r = α + 1 := by
      exact Quotient.out_eq' _;
    have h_typein : ∀ β < α + 1, ∃ p : (α + 1).out.α, Ordinal.typein (α + 1).out.r p = β := by
      intro β hβ;
      convert Ordinal.typein_surj _ _;
      grind;
    exact h_typein α ( Order.lt_succ α );
  exact h_contra ⟨ ordinalGame ( α + 1 ), p, by rw [ ordinalGame_gameValue, hp ] ⟩

/-! ## Part 3: Chain Games and Finite Values -/

/-- A finite chain game: positions are natural numbers ≤ n, move from k+1 to k. -/
def chainGame (n : ℕ) : WFGame where
  Pos := { k : ℕ // k ≤ n }
  moves := fun ⟨k, hk⟩ =>
    if h : 0 < k then {⟨k - 1, by omega⟩} else ∅
  wf := by
    apply WellFounded.intro
    intro ⟨k, hk⟩
    induction k with
    | zero =>
      constructor; intro ⟨j, hj⟩ hmem
      simp only [dite_false] at hmem
      exact absurd hmem (Set.notMem_empty _)
    | succ m ih =>
      constructor; intro ⟨j, hj⟩ hmem
      simp only [Nat.succ_pos, ↓reduceDIte, Set.mem_singleton_iff,
        Subtype.mk.injEq] at hmem
      have : j = m := by omega
      subst this
      exact ih (by omega)

/-
In chainGame n, position k has value k.
-/
theorem chainGame_value (n : ℕ) (k : { k : ℕ // k ≤ n }) :
    (chainGame n).gameValue k = (k.val : Ordinal) := by
  induction k ; simp_all +decide [ chainGame ];
  induction' ‹ℕ› with k ih;
  · convert WFGame.gameValue_terminal _ _ _ ; aesop;
  · rw [ WFGame.gameValue_eq ] ; aesop;

/-- For any natural number n, there exists a game with value n. -/
theorem exists_game_value_nat (n : ℕ) :
    ∃ G : WFGame, ∃ p : G.Pos, G.gameValue p = (n : Ordinal) :=
  ⟨chainGame n, ⟨n, le_refl n⟩, chainGame_value n ⟨n, le_refl n⟩⟩

/-! ## Part 4: The ω^n Hierarchy -/

/-- The game values ω^n form a strictly increasing sequence. -/
theorem omega_pow_strictMono :
    StrictMono (fun n : ℕ => (omega0 : Ordinal.{0}) ^ (n : Ordinal.{0})) :=
  fun _ _ h => (Ordinal.opow_lt_opow_iff_right Ordinal.one_lt_omega0).2 (Nat.cast_lt.2 h)

/-
ω^ω is the supremum of ω^n over all natural numbers.
-/
theorem omega_pow_omega_eq_iSup :
    (omega0 : Ordinal.{0}) ^ (omega0 : Ordinal.{0}) =
    ⨆ n : ℕ, (omega0 : Ordinal.{0}) ^ (n : Ordinal.{0}) := by
  rw [ @ciSup_eq_of_forall_le_of_forall_lt_exists_gt ];
  · exact fun i => by exact_mod_cast Ordinal.opow_le_opow_right ( by norm_num ) ( Ordinal.nat_lt_omega0 i |> le_of_lt ) ;
  · intro w hw;
    rw [ Ordinal.lt_opow_of_isSuccLimit ] at hw;
    · obtain ⟨ c', hc', hw ⟩ := hw;
      rw [ Ordinal.lt_omega0 ] at hc' ; aesop;
    · exact Ordinal.omega0_ne_zero;
    · exact isSuccLimit_omega0

/-- Each ω^n is strictly below ω^ω. -/
theorem omega_pow_nat_lt_omega_pow_omega (n : ℕ) :
    (omega0 : Ordinal.{0}) ^ (n : Ordinal.{0}) <
    (omega0 : Ordinal.{0}) ^ (omega0 : Ordinal.{0}) :=
  (Ordinal.opow_lt_opow_iff_right Ordinal.one_lt_omega0).2 (Ordinal.nat_lt_omega0 n)

/-- For every n, there exists a game with value exactly ω^n. -/
theorem exists_game_omega_pow (n : ℕ) :
    ∃ G : WFGame, ∃ p : G.Pos,
      G.gameValue p = (omega0 : Ordinal.{0}) ^ (n : Ordinal.{0}) :=
  exists_game_value _

/-- There exists a game with value exactly ω^ω. -/
theorem exists_game_omega_pow_omega :
    ∃ G : WFGame, ∃ p : G.Pos,
      G.gameValue p = (omega0 : Ordinal.{0}) ^ (omega0 : Ordinal.{0}) :=
  exists_game_value _

/-! ## Part 5: Separation Results

Each level of the ordinal hierarchy is strictly separated from the next. -/

/-- ω · n < ω² for any finite n. -/
theorem omega_mul_nat_lt_omega_sq (n : ℕ) :
    (omega0 : Ordinal.{0}) * (n : Ordinal.{0}) < (omega0 : Ordinal.{0}) ^ 2 := by
  rw [sq]
  exact mul_lt_mul_of_pos_left (Ordinal.nat_lt_omega0 n) Ordinal.omega0_pos

/-
ω^n · m < ω^(n+1) for any finite m.
-/
theorem omega_pow_mul_nat_lt_next (n m : ℕ) :
    (omega0 : Ordinal.{0}) ^ (n : Ordinal.{0}) * (m : Ordinal.{0}) <
    (omega0 : Ordinal.{0}) ^ ((n : Ordinal.{0}) + 1) := by
  simp +zetaDelta at *

/-! ## Part 6: The Omega Tower and ε₀ -/

/-- The omega tower: 1, ω, ω^ω, ω^(ω^ω), ... -/
noncomputable def omegaTower : ℕ → Ordinal.{0}
  | 0 => 1
  | n + 1 => omega0 ^ omegaTower n

/-
The omega tower is strictly increasing.
-/
theorem omegaTower_strictMono : StrictMono omegaTower := by
  refine' strictMono_nat_of_lt_succ fun n => _;
  induction n <;> simp_all +decide [ omegaTower ]

/-- ε₀ as the supremum of the omega tower. -/
noncomputable def epsilon0 : Ordinal.{0} := ⨆ n : ℕ, omegaTower n

/-
Each level of the omega tower is below ε₀.
-/
theorem omegaTower_lt_epsilon0 (n : ℕ) : omegaTower n < epsilon0 := by
  refine' lt_of_lt_of_le _ ( le_ciSup _ ( n + 1 ) );
  · exact omegaTower_strictMono n.lt_succ_self;
  · exact bddAbove_range fun n => omegaTower n

/-
ε₀ is a fixed point of ω^·: ω^(ε₀) = ε₀.
-/
theorem omega_pow_epsilon0 : omega0 ^ epsilon0 = epsilon0 := by
  refine' le_antisymm _ _;
  · rw [ epsilon0, Ordinal.opow_le_iff_le_log ];
    · refine' ciSup_le fun n => _;
      refine' Ordinal.le_log_of_opow_le ( by norm_num ) _;
      refine' le_ciSup ( Ordinal.bddAbove_of_small _ ) ( n + 1 ) |> le_trans _;
      rfl;
    · exact Ordinal.one_lt_omega0;
    · exact ne_of_gt <| lt_of_lt_of_le ( by simp +decide [ omegaTower ] ) <| le_ciSup ( Ordinal.bddAbove_of_small _ ) 0;
  · refine' ciSup_le fun n => _;
    induction' n with n ih;
    · refine' le_trans _ ( Ordinal.opow_le_opow_right _ <| Ordinal.one_le_iff_ne_zero.mpr _ ) <;> norm_num;
      · exact Ordinal.one_le_iff_ne_zero.mpr Ordinal.omega0_ne_zero;
      · exact ne_of_gt ( lt_of_le_of_lt ( by norm_num ) ( omegaTower_lt_epsilon0 0 ) );
    · refine' le_trans _ ( Ordinal.opow_le_opow_right omega0_pos ( show omegaTower n ≤ epsilon0 from _ ) );
      · exact le_rfl;
      · exact le_of_lt ( omegaTower_lt_epsilon0 n )

/-! ## Part 7: Cofinality and Game Structure -/

/-
**Cofinality**: If every β < α can be reached by a move,
    then the game value is at least α.
-/
theorem gameValue_cofinal (G : WFGame) (p : G.Pos) (α : Ordinal.{0})
    (h : ∀ β < α, ∃ q ∈ G.moves p, β ≤ G.gameValue q) :
    α ≤ G.gameValue p := by
  contrapose! h;
  exact ⟨ _, h, fun q hq => G.gameValue_lt_of_move hq ⟩

/-
A non-terminal position has positive game value.
-/
theorem gameValue_pos_of_nonterminal (G : WFGame) (p : G.Pos)
    (h : ∃ q, q ∈ G.moves p) : 0 < G.gameValue p := by
  obtain ⟨ q, hq ⟩ := h;
  exact lt_of_le_of_lt ( by norm_num ) ( G.gameValue_lt_of_move hq )

/-! ## Part 8: Cross-Domain Bridge — Well-Orders ↔ Game Trees -/

/-- Convert a well-founded relation to a game. -/
def wfRelToGame {α : Type} {r : α → α → Prop} (wf : WellFounded r) : WFGame where
  Pos := α
  moves := fun a => { b | r b a }
  wf := wf

/-- The ordinal rank via well-founded recursion. -/
noncomputable def wfRank {α : Type} {r : α → α → Prop}
    (wf : WellFounded r) : α → Ordinal.{0} :=
  wf.fix fun a ih => ⨆ b : { b // r b a }, Order.succ (ih b.1 b.2)

/-- **Bridge Theorem**: Well-order rank equals game value.
    This structural identity connects order theory and game theory. -/
theorem wfRank_eq_gameValue {α : Type} {r : α → α → Prop}
    (wf : WellFounded r) (a : α) :
    wfRank wf a = (wfRelToGame wf).gameValue a := by
  rfl

/-! ## Part 9: Limit Ordinal Characterization -/

/-
ω is a limit ordinal (not a successor).
-/
theorem omega0_isSuccPrelimit : Order.IsSuccPrelimit (omega0 : Ordinal.{0}) := by
  intro x hx; exact (by
  cases' hx with hx₁ hx₂;
  contrapose! hx₂;
  refine' ⟨ x + 1, _, _ ⟩;
  · exact lt_add_one x;
  · rw [ Ordinal.lt_omega0 ] at *;
    rcases hx₁ with ⟨ n, rfl ⟩ ; exact ⟨ n + 1, by simp +decide ⟩);

/-
ω^ω is a limit ordinal.
-/
theorem omega_pow_omega_isSuccPrelimit :
    Order.IsSuccPrelimit ((omega0 : Ordinal.{0}) ^ (omega0 : Ordinal.{0})) := by
  intro h;
  rintro ⟨ h_le, h_gt ⟩;
  -- Since $h < \omega^\omega$, there exists some $n$ such that $h < \omega^n$.
  obtain ⟨n, hn⟩ : ∃ n : ℕ, h < omega0 ^ (n : Ordinal.{0}) := by
    contrapose! h_le;
    convert ciSup_le fun n => h_le n;
    exact omega_pow_omega_eq_iSup;
  contrapose! h_gt;
  refine' ⟨ _, hn, _ ⟩;
  rw [ Ordinal.opow_lt_opow_iff_right ] <;> norm_num

/-
**Limit Value Characterization**: A limit game value means moves reach
    arbitrarily close to the value.
-/
theorem gameValue_limit_characterization (G : WFGame) (p : G.Pos)
    (_hlim : Order.IsSuccPrelimit (G.gameValue p))
    (_hpos : 0 < G.gameValue p) :
    ∀ β < G.gameValue p, ∃ q ∈ G.moves p, β ≤ G.gameValue q := by
  intro β hβ;
  contrapose! hβ;
  rw [ WFGame.gameValue_eq ];
  refine' ciSup_le' _;
  exact fun q => Order.succ_le_of_lt ( hβ _ q.2 )

/-! ## Part 10: The Set of All Game Values -/

/-- The set of realizable game values (over all WFGames) is all ordinals. -/
theorem all_ordinals_realizable :
    ∀ α : Ordinal.{0}, ∃ G : WFGame, ∃ p : G.Pos, G.gameValue p = α :=
  exists_game_value

/-! ## Part 11: Falsifiable Conjecture

**Conjecture (Principal Hierarchy)**: For every countable ordinal α < ε₀,
there exists an *infinite chess* position P with game value v(P) = α.

This extends Evans-Hamkins. We cannot formalize infinite chess rules here,
but we prove the abstract game-theoretic version: every ordinal is realizable
as a game value of some well-founded game (Theorem `all_ordinals_realizable`).

**Testable prediction**: For α = ω^ω, the position requires at least ω^n
moves for every n, but White can force checkmate in ω^ω moves. A disproof
would exhibit an ordinal α < ε₀ not achievable as an infinite chess game value.
-/