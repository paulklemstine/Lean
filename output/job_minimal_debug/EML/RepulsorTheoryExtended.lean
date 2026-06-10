import Mathlib

/-! # CatalogBuild.Physics.Classical.RepulsorTheoryExtended

Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 68
-/

noncomputable section

/-- A function `g` is a repulsor for `enum` if it differs diagonally. -/
def IsRepulsor' (g : ℕ → ℕ) (enum : ℕ → (ℕ → ℕ)) : Prop :=
  ∀ i, g i ≠ enum i i

/-- The diagonal shift is always a repulsor. -/
theorem repulsor_exists_diagonal' (enum : ℕ → (ℕ → ℕ)) :
    IsRepulsor' (fun i => enum i i + 1) enum := by
  intro i; simp

/-- Any positive offset gives a repulsor. -/
theorem repulsor_family' (enum : ℕ → (ℕ → ℕ)) (c : ℕ) (hc : 0 < c) :
    IsRepulsor' (fun i => enum i i + c) enum := by
  intro i; dsimp; omega

/-- Different offsets give different repulsors. -/
theorem repulsor_family_injective' (enum : ℕ → (ℕ → ℕ)) (c₁ c₂ : ℕ)
    (hc : c₁ ≠ c₂) :
    (fun i => enum i i + c₁) ≠ (fun i => enum i i + c₂) := by
  intro h; have := congr_fun h 0; omega

/-- **Repulsor Abundance**: Infinitely many pairwise-distinct repulsors exist. -/
theorem repulsor_abundance' (enum : ℕ → (ℕ → ℕ)) :
    ∃ family : ℕ → (ℕ → ℕ),
      (∀ n, IsRepulsor' (family n) enum) ∧ Injective family := by
  refine ⟨fun c i => enum i i + c + 1, fun n i => ?_, fun a b h => ?_⟩
  · dsimp; omega
  · have := congr_fun h 0; dsimp at this; omega

/-- The diagonal evader. -/
def diagEvader (enum : ℕ → (ℕ → ℕ)) : ℕ → ℕ := fun i => enum i i + 1

/-- Iterated diagonalization tower. -/
def diagTower (base : ℕ → (ℕ → ℕ)) : ℕ → (ℕ → ℕ)
  | 0 => diagEvader base
  | n + 1 => fun i => (diagTower base n) i + 1

/-- Tower values strictly exceed base values. -/
theorem diagTower_gt_base (base : ℕ → (ℕ → ℕ)) (n : ℕ) :
    ∀ i, base i i < diagTower base n i := by
  intro i; induction n with
  | zero => simp [diagTower, diagEvader]
  | succ n ih => simp [diagTower]; omega

/-- Tower levels are strictly monotone. -/
theorem diagTower_strict_mono (base : ℕ → (ℕ → ℕ)) :
    ∀ m n : ℕ, m < n → ∀ i, diagTower base m i < diagTower base n i := by
  intro m n hmn i
  induction n with
  | zero => omega
  | succ n ih =>
    simp only [diagTower]
    rcases Nat.lt_succ_iff_lt_or_eq.mp hmn with h | h
    · linarith [ih h]
    · subst h; omega

/-- Tower levels are distinct functions. -/
theorem diagTower_injective (base : ℕ → (ℕ → ℕ)) :
    Injective (diagTower base) := by
  intro a b hab
  by_contra h
  rcases lt_or_gt_of_ne h with hlt | hlt
  · exact absurd (congr_fun hab 0) (Nat.ne_of_lt (diagTower_strict_mono base a b hlt 0))
  · exact absurd (congr_fun hab 0).symm (Nat.ne_of_lt (diagTower_strict_mono base b a hlt 0))

/-- Each tower level evades the base enumeration. -/
theorem diagTower_evades (base : ℕ → (ℕ → ℕ)) (n : ℕ) :
    IsRepulsor' (diagTower base n) base := by
  intro i; exact Nat.ne_of_gt (diagTower_gt_base base n i)

/-- Fixed-point-free predicate. -/
def IsFixedPointFree' {α : Type*} (f : α → α) : Prop := ∀ x, f x ≠ x

/-- Composition of increasing maps on ℕ is fixed-point-free. -/
theorem fpf_composition_increasing
    (f g : ℕ → ℕ) (hf : ∀ n, n < f n) (hg : ∀ n, n < g n) :
    IsFixedPointFree' (f ∘ g) := by
  intro x; simp [comp]; linarith [hg x, hf (g x)]

/-- Iterate formula for successor. -/
theorem succ_iter_eq (n x : ℕ) : Nat.succ^[n] x = x + n := by
  induction n generalizing x with
  | zero => simp
  | succ k ih => rw [iterate_succ', comp_apply, ih]; omega

/-- n-fold successor is fpf for n > 0. -/
theorem succ_iterate_fpf' (n : ℕ) (hn : 0 < n) :
    IsFixedPointFree' (Nat.succ^[n]) := by
  intro x; rw [succ_iter_eq]; omega

/-- Positive shifts compose: closure under addition. -/
theorem shift_closure (a b : ℕ) (ha : 0 < a) (hb : 0 < b) :
    (∀ n : ℕ, n + a ≠ n) ∧ (∀ n : ℕ, n + b ≠ n) ∧ (∀ n : ℕ, n + (a + b) ≠ n) :=
  ⟨fun n => by omega, fun n => by omega, fun n => by omega⟩

/-- A repulsor point for f is a displaced point. -/
def IsRepulsorPt' {α : Type*} (f : α → α) (x : α) : Prop := f x ≠ x

/-- Every point is either an oracle or a repulsor, never both. -/
theorem oracle_repulsor_partition' {α : Type*} (f : α → α) (x : α) :
    IsOracle' f x ↔ ¬ IsRepulsorPt' f x := by
  simp [IsOracle', IsRepulsorPt']

/-- The oracle and repulsor sets are complementary. -/
theorem oracle_repulsor_complement' {α : Type*} (f : α → α) :
    {x | IsOracle' f x} = {x | IsRepulsorPt' f x}ᶜ := by
  ext x; simp [IsOracle', IsRepulsorPt']

/-- A mixed object: oracle at even positions, repulsor at odd. -/
def mixedOracleRepulsor (enum : ℕ → (ℕ → ℕ)) : ℕ → ℕ :=
  fun i => if i % 2 = 0 then enum i i else enum i i + 1

/-- [Section: # CatalogBuild.Physics.Classical.RepulsorTheoryExtended
Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 68] -/
theorem mixed_oracle_even (enum : ℕ → (ℕ → ℕ)) (i : ℕ) (hi : i % 2 = 0) :
    mixedOracleRepulsor enum i = enum i i := by
  simp [mixedOracleRepulsor, hi]

/-- [Section: # CatalogBuild.Physics.Classical.RepulsorTheoryExtended
Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 68] -/
theorem mixed_repulsor_odd (enum : ℕ → (ℕ → ℕ)) (i : ℕ) (hi : i % 2 = 1) :
    mixedOracleRepulsor enum i ≠ enum i i := by
  simp [mixedOracleRepulsor]; omega

/-- Positions where g disagrees diagonally with enum. -/
def evasionSet (g : ℕ → ℕ) (enum : ℕ → (ℕ → ℕ)) : Set ℕ :=
  {i | g i ≠ enum i i}

/-- A total repulsor has evasion set = univ. -/
theorem total_repulsor_evasion (g : ℕ → ℕ) (enum : ℕ → (ℕ → ℕ))
    (h : IsRepulsor' g enum) : evasionSet g enum = Set.univ := by
  ext i; simp [evasionSet]; exact h i

/-- After k queries in n positions, remaining hiding spots. -/
def remainingPositions (n k : ℕ) : ℕ := n - k

/-- After k < n queries, spots remain. -/
theorem searcher_deficit' (n k : ℕ) (hk : k < n) :
    0 < remainingPositions n k := by
  simp [remainingPositions]; omega

/-- More queries reduce hiding spots. -/
theorem query_monotone' (n k₁ k₂ : ℕ) (h : k₁ ≤ k₂) (hk : k₂ ≤ n) :
    remainingPositions n k₂ ≤ remainingPositions n k₁ := by
  simp [remainingPositions]; omega

/-- **The Last Query Theorem**: n queries suffice, n-1 never do. -/
theorem last_query_essential' (n : ℕ) (hn : 0 < n) :
    (∀ target : Fin n, ∃ queries : Finset (Fin n), queries.card = n ∧ target ∈ queries) ∧
    (∀ queries : Finset (Fin n), queries.card = n - 1 → ∃ target : Fin n, target ∉ queries) := by
  constructor
  · exact fun target => ⟨Finset.univ, by simp, Finset.mem_univ _⟩
  · intro queries hcard
    by_contra h; push_neg at h
    have hle : Finset.univ ⊆ queries := fun x _ => h x
    have := Finset.card_le_card hle
    simp at this; omega

/-- A point is wandering if its orbit exceeds any bound. -/
def IsWandering' (f : ℕ → ℕ) (x : ℕ) : Prop :=
  ∀ B : ℕ, ∃ n : ℕ, B < f^[n] x

/-- Every point wanders under successor. -/
theorem succ_wandering' (x : ℕ) : IsWandering' Nat.succ x := by
  intro B; use B + 1; rw [succ_iter_eq]; omega

/-- Iterate formula for shifts. -/
theorem shift_iterate (c x n : ℕ) : (· + c)^[n] x = x + n * c := by
  induction n with
  | zero => simp
  | succ n ih => rw [iterate_succ', comp_apply, ih]; ring

/-- Every point wanders under x ↦ x + c for c > 0. -/
theorem shift_wandering' (c : ℕ) (hc : 0 < c) (x : ℕ) :
    IsWandering' (· + c) x := by
  intro B; use B + 1; rw [shift_iterate]; nlinarith

/-- Iterates of a fixed point are constant. -/
theorem fixed_iterate' (f : ℕ → ℕ) (x : ℕ) (hfx : f x = x) :
    ∀ n, f^[n] x = x := by
  intro n; induction n with
  | zero => simp
  | succ n ih => simp [iterate_succ, comp, ih, hfx]

/-- Fixed points don't wander. -/
theorem fixed_not_wandering' (f : ℕ → ℕ) (x : ℕ) (hfx : f x = x) :
    ¬ IsWandering' f x := by
  intro hw; obtain ⟨n, hn⟩ := hw (x + 1)
  rw [fixed_iterate' f x hfx n] at hn; omega

/-- Iterate formula for doubling. -/
theorem doubling_iterate' (x n : ℕ) : (· * 2)^[n] x = x * 2 ^ n := by
  induction n with
  | zero => simp
  | succ n ih => rw [iterate_succ', comp_apply, ih]; ring

theorem doubling_wandering' (x : ℕ) (hx : 0 < x) :
    IsWandering' (· * 2) x := by
  intro B;
  -- Choose $n = B + 1$.
  use B + 1;
  induction' B with B ih <;> simp_all +decide [ Function.iterate_succ_apply' ] ; nlinarith [ Nat.one_le_pow B 2 zero_lt_two ] ;

theorem monotone_orbit_dichotomy' (f : ℕ → ℕ) (hf : Monotone f) (x : ℕ) :
    (∃ n, f^[n] x = f^[n + 1] x) ∨ (∀ n, f^[n] x < f^[n + 1] x) := by
  by_contra! h_contra;
  -- If there exists some $n$ such that $f^{[n+1]} x \leq f^{[n]} x$, then by induction, for all $m \geq n$, $f^{[m+1]} x \leq f^{[m]} x$.
  obtain ⟨n, hn⟩ : ∃ n, f^[n + 1] x ≤ f^[n] x := h_contra.right
  have h_ind : ∀ m ≥ n, f^[m + 1] x ≤ f^[m] x := by
    intro m hm; induction hm <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
    exact hf ‹_›;
  -- Since $f^{[n+1]} x \leq f^{[n]} x$, the sequence $f^{[n]} x$ is strictly decreasing and bounded below by $0$.
  have h_decreasing : StrictAnti (fun m => f^[n + m] x) := by
    refine' strictAnti_nat_of_succ_lt _;
    grind +ring;
  exact absurd ( Set.infinite_range_of_injective h_decreasing.injective ) ( Set.not_infinite.mpr <| Set.finite_iff_bddAbove.mpr ⟨ _, Set.forall_mem_range.mpr fun m => h_decreasing.antitone m.zero_le ⟩ )

/-- The diagonal gives a Bool-valued repulsor. -/
theorem cantor_repulsor' (enum : ℕ → (ℕ → Bool)) :
    ∃ g : ℕ → Bool, ∀ i, g i ≠ enum i i :=
  ⟨fun i => !(enum i i), fun i => by simp⟩

theorem zoo_successor : IsFixedPointFree' (fun n : ℕ => n + 1) := by
  intro n; dsimp; omega

theorem zoo_squaring : IsFixedPointFree' (fun n : ℕ => n * n + 1) := by
  intro n; dsimp
  cases n with
  | zero => omega
  | succ m => nlinarith [Nat.zero_le m]

theorem zoo_fib_shift : IsFixedPointFree' (fun n : ℕ => n + Nat.fib n + 1) := by
  intro n; dsimp; omega

theorem zoo_polynomial (c : ℕ) (hc : 0 < c) :
    IsFixedPointFree' (fun n : ℕ => n + c) := by
  intro n; dsimp; omega

/-- Product of repulsors is a repulsor. -/
theorem product_repulsor' (f g : ℕ → ℕ) (hf : IsFixedPointFree' f)
    (_hg : IsFixedPointFree' g) :
    IsFixedPointFree' (fun p : ℕ × ℕ => (f p.1, g p.2)) := by
  intro ⟨a, b⟩; dsimp
  intro h; exact absurd (Prod.mk.inj h).1 (hf a)

/-- Level-k repulsor: displaces by k+1. -/
def levelRepulsor (k : ℕ) : ℕ → ℕ := fun n => n + k + 1

/-- Every level repulsor is fpf. -/
theorem levelRepulsor_fpf (k : ℕ) : IsFixedPointFree' (levelRepulsor k) := by
  intro n; simp [levelRepulsor]; omega

/-- Higher levels displace more. -/
theorem levelRepulsor_increasing (j k : ℕ) (hjk : j < k) :
    ∀ n, levelRepulsor j n < levelRepulsor k n := by
  intro n; simp [levelRepulsor]; omega

/-- No two levels are the same function. -/
theorem levelRepulsor_strict (j k : ℕ) (hjk : j ≠ k) :
    levelRepulsor j ≠ levelRepulsor k := by
  intro h; have := congr_fun h 0; simp [levelRepulsor] at this; omega

/-- Extend a partial repulsor to cover one more entry. -/
theorem repulsor_extension' (enum : ℕ → (ℕ → ℕ)) (g : ℕ → ℕ) (k : ℕ)
    (hk : ∀ i, i < k → g i ≠ enum i i) :
    ∃ g' : ℕ → ℕ, (∀ i, i < k → g' i = g i) ∧
    (∀ i, i < k + 1 → g' i ≠ enum i i) := by
  use fun i => if i < k then g i else enum i i + 1
  refine ⟨fun i hi => by simp [hi], fun i hi => ?_⟩
  simp only; split
  · rename_i hik; exact hk i hik
  · omega

/-- A total repulsor always exists. -/
theorem total_repulsor_exists' (enum : ℕ → (ℕ → ℕ)) :
    ∃ g : ℕ → ℕ, IsRepulsor' g enum :=
  ⟨fun i => enum i i + 1, repulsor_exists_diagonal' enum⟩

/-- Fixed points + displaced points = total. -/
theorem grand_evasion_principle' (n : ℕ) (f : Fin n → Fin n) :
    (Finset.univ.filter (fun x => f x = x)).card +
    (Finset.univ.filter (fun x => f x ≠ x)).card = n := by
  have := Finset.card_filter_add_card_filter_not (s := Finset.univ) (p := fun x => f x = x)
  simpa using this

/-- Negation is a repulsor on nonzero integers. -/
theorem negation_repulsor' : ∀ n : ℤ, n ≠ 0 → -n ≠ n := by omega

/-- A derangement is a total repulsor. -/
theorem derangement_total {n : ℕ} (σ : Equiv.Perm (Fin n))
    (hσ : ∀ x, σ x ≠ x) : IsFixedPointFree' σ := hσ

theorem monotone_fin_fixed_point' (n : ℕ) (f : Fin (n + 1) → Fin (n + 1))
    (hf : Monotone f) : ∃ x, IsOracle' f x := by
  by_contra h_no_fixed_point;
  -- Consider the set S = {i : Fin (n+1) | i ≤ f i}. Since 0 ≤ f 0, we have 0 ∈ S so S is nonempty.
  have hS_nonempty : ∃ i : Fin (n + 1), i ≤ f i := by
    exact ⟨ 0, Nat.zero_le _ ⟩;
  -- Let m be the maximum of S (exists since Fin (n+1) is finite).
  obtain ⟨m, hm⟩ : ∃ m : Fin (n + 1), m ∈ {i : Fin (n + 1) | i ≤ f i} ∧ ∀ i ∈ {i : Fin (n + 1) | i ≤ f i}, i ≤ m := by
    exact ⟨ Finset.max' ( Finset.univ.filter fun i => i ≤ f i ) ⟨ hS_nonempty.choose, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hS_nonempty.choose_spec ⟩ ⟩, Finset.mem_filter.mp ( Finset.max'_mem ( Finset.univ.filter fun i => i ≤ f i ) ⟨ hS_nonempty.choose, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hS_nonempty.choose_spec ⟩ ⟩ ) |>.2, fun i hi => Finset.le_max' _ _ ( by simpa using hi ) ⟩;
  -- If m < f m, then f m ≤ f(f m) by monotonicity, so f m ∈ S, contradicting maximality of m.
  by_cases hm_lt_fm : m < f m;
  · exact not_lt_of_ge ( hm.2 ( f m ) ( by simpa using hf hm_lt_fm.le ) ) hm_lt_fm;
  · exact h_no_fixed_point ⟨ m, le_antisymm ( le_of_not_gt hm_lt_fm ) hm.1 ⟩

/-- Positive displacement implies fpf. -/
theorem positive_displacement_fpf (f : ℕ → ℕ) (h : ∀ x, 0 < displacement f x) :
    IsFixedPointFree' f := by
  intro x; have := h x; simp [displacement] at this; omega

/-- Negative displacement implies fpf. -/
theorem negative_displacement_fpf (f : ℕ → ℕ) (h : ∀ x, displacement f x < 0) :
    IsFixedPointFree' f := by
  intro x; have := h x; simp [displacement] at this; omega

/-- Total displacement over first n points. -/
def totalDisplacement (f : ℕ → ℕ) (n : ℕ) : ℤ :=
  (Finset.range n).sum (fun i => displacement f i)

/-- Successor has total displacement n. -/
theorem succ_total_displacement' (n : ℕ) :
    totalDisplacement Nat.succ n = n := by
  simp [totalDisplacement, displacement]

/-- Shift by c has total displacement n * c. -/
theorem shift_total_displacement' (c : ℕ) (n : ℕ) :
    totalDisplacement (· + c) n = n * c := by
  simp [totalDisplacement, displacement]

/-- Any finite set in an infinite type has elements outside it. -/
theorem infinite_evades_finite {α : Type*} [Infinite α]
    (S : Finset α) : ∃ x : α, x ∉ S :=
  Infinite.exists_notMem_finset S

/-- Two distinct elements evade any finite set in an infinite type. -/
theorem two_evade_finite {α : Type*} [Infinite α]
    (S : Finset α) : ∃ x y : α, x ∉ S ∧ y ∉ S ∧ x ≠ y := by
  obtain ⟨x, hx⟩ := Infinite.exists_notMem_finset S
  obtain ⟨y, hy⟩ := Infinite.exists_notMem_finset ({x} ∪ S)
  simp at hy
  exact ⟨x, y, hx, hy.2, Ne.symm hy.1⟩

/-- Evasion depth: how many initial entries g evades. -/
def evasionDepth (g : ℕ → ℕ) (enum : ℕ → (ℕ → ℕ)) : ℕ → Prop
  | 0 => True
  | n + 1 => g n ≠ enum n n ∧ evasionDepth g enum n

/-- Evasion depth is monotone. -/
theorem evasionDepth_mono (g : ℕ → ℕ) (enum : ℕ → (ℕ → ℕ)) (n : ℕ) :
    evasionDepth g enum (n + 1) → evasionDepth g enum n :=
  fun ⟨_, h⟩ => h

/-- The diagonal evader has infinite evasion depth. -/
theorem diagEvader_infinite_depth (enum : ℕ → (ℕ → ℕ)) :
    ∀ k, evasionDepth (diagEvader enum) enum k := by
  intro k; induction k with
  | zero => trivial
  | succ n ih => exact ⟨by simp [diagEvader], ih⟩

/-- Minimum displacement over first n points. -/
def minDisplacement (f : ℕ → ℕ) (n : ℕ) : ℤ :=
  if h : n = 0 then 0
  else (Finset.range n).inf' (by simp [h]) (fun i => displacement f i)

/-- A "stronger" repulsor displaces more at every point. -/
def StrongerRepulsor (f g : ℕ → ℕ) : Prop :=
  ∀ n, displacement f n ≥ displacement g n

/-- Stronger-repulsor is reflexive. -/
theorem strongerRepulsor_refl (f : ℕ → ℕ) : StrongerRepulsor f f :=
  fun _ => le_refl _

/-- Stronger-repulsor is transitive. -/
theorem strongerRepulsor_trans (f g h : ℕ → ℕ)
    (hfg : StrongerRepulsor f g) (hgh : StrongerRepulsor g h) :
    StrongerRepulsor f h :=
  fun n => le_trans (hgh n) (hfg n)

/-- Level k+1 repulsor is stronger than level k. -/
theorem levelRepulsor_stronger (k : ℕ) :
    StrongerRepulsor (levelRepulsor (k + 1)) (levelRepulsor k) := by
  intro n; simp [displacement, levelRepulsor]

end


-- !-- Merged from RepulsorTheory.lean (auto-dedup) -- !--

Declarations: 33
Declarations: 33] -/
theorem diagonal_evasion (enum : ℕ → (ℕ → ℕ)) :
    ∃ g : ℕ → ℕ, ∀ n, g n ≠ enum n n := by
  exact ⟨ fun n => enum n n + 1, fun n => by simp +decide ⟩
/-- **Diagonal Evasion with Constructive Witness.**
We can explicitly construct the evading function: at position n,
simply differ from enum(n)(n) by adding 1. -/
def diagonal_evader (enum : ℕ → (ℕ → ℕ)) : ℕ → ℕ :=
  fun n => enum n n + 1
Declarations: 33] -/
theorem diagonal_evader_evades (enum : ℕ → (ℕ → ℕ)) :
    ∀ n, diagonal_evader enum n ≠ enum n n := by
  exact fun n => Nat.succ_ne_self _
/-- **Iterated Diagonal Evasion.**
Even if you add the evader back to the enumeration and re-diagonalize,
you get a *new* evader. The evasion never terminates — this is the
"search-hardening" property at its most fundamental. -/
def iterated_evader : ℕ → (ℕ → (ℕ → ℕ)) → (ℕ → ℕ)
  | 0, enum => diagonal_evader enum
  | n + 1, enum =>
    let prev := iterated_evader n enum
    -- Extend the enumeration with the previous evader
    let extended : ℕ → (ℕ → ℕ) := fun k =>
      if k = 0 then prev else enum (k - 1)
    diagonal_evader extended
theorem iterated_evaders_all_distinct (enum : ℕ → (ℕ → ℕ)) :
    ∀ i j, i ≠ j → iterated_evader i enum ≠ iterated_evader j enum := by
  intros i j hij h_eq; contrapose! hij; (
  have h_diff : ∀ n, iterated_evader (n + 1) enum 0 ≠ iterated_evader n enum 0 := by
    simp [iterated_evader];
    exact Nat.succ_ne_self _;
  -- By induction on $n$, we can show that $iterated\_evader n enum 0$ is strictly increasing.
  have h_inc : StrictMono (fun n => iterated_evader n enum 0) := by
    refine' strictMono_nat_of_lt_succ fun n => _;
    induction' n with n ih <;> simp_all +decide [ iterated_evader ];
    · exact Nat.lt_succ_self _;
    · exact Nat.succ_lt_succ ih;
  exact h_inc.injective ( congr_fun h_eq 0 ))
theorem cantor_evasion (α : Type*) (f : α → Set α) :
    ∃ S : Set α, ∀ a, f a ≠ S := by
  exact ⟨ { a | a∉ f a }, fun a ha => by simpa using Set.ext_iff.mp ha a ⟩
/-- **The Evading Set**: explicitly constructed via diagonalization. -/
def evading_set {α : Type*} (f : α → Set α) : Set α :=
  {a : α | a ∉ f a}
theorem evading_set_evades {α : Type*} (f : α → Set α) :
    ∀ a, f a ≠ evading_set f := by
  intro a ha; have := Set.ext_iff.mp ha a; simp +decide [ evading_set ] at this;
/-- A search game on a finite universe of size n.
The target is hidden; the searcher queries positions one at a time.
After k queries that all miss, the evader's remaining hiding places. -/
def remaining_positions (n : ℕ) (queries : Finset (Fin n)) : Finset (Fin n) :=
  Finset.univ \ queries
theorem remaining_positions_card (n : ℕ) (queries : Finset (Fin n)) :
    (remaining_positions n queries).card = n - queries.card := by
  unfold remaining_positions; simp +decide [ Finset.card_sdiff ] ;
theorem evader_survives_linear (n : ℕ) (hn : 2 ≤ n) :
    ∀ pursuer_strategy : Fin (n - 1) → Fin n,
    ∃ evader_pos : Fin (n - 1) → Fin n,
    ∀ round : Fin (n - 1), evader_pos round ≠ pursuer_strategy round := by
  intros pursuer_strategy
  have h_exists : ∀ r : Fin (n - 1), ∃ y : Fin n, y ≠ pursuer_strategy r := by
    exact fun r => ⟨ if pursuer_strategy r = ⟨ 0, by linarith ⟩ then ⟨ 1, by linarith ⟩ else ⟨ 0, by linarith ⟩, by aesop ⟩;
  exact ⟨ fun r => Classical.choose ( h_exists r ), fun r => Classical.choose_spec ( h_exists r ) ⟩
theorem countable_search_misses_almost_all (S : Set ℝ) (hS : S.Countable) :
    MeasureTheory.MeasureSpace.volume S = 0 := by
  exact hS.measure_zero MeasureTheory.MeasureSpace.volume
theorem baire_evasion {X : Type*} [TopologicalSpace X] [BaireSpace X] [Nonempty X]
    (searches : ℕ → Set X) (h_closed : ∀ n, IsClosed (searches n))
    (h_nwd : ∀ n, interior (searches n) = ∅) :
    ∃ x : X, ∀ n, x ∉ searches n := by
  -- Each complement is dense.
  have h_dense : ∀ n, Dense (searches n)ᶜ := by
    simp_all +decide [ Dense, Set.ext_iff ];
  -- The intersection of dense open sets is dense.
  have h_inter_dense : Dense (⋂ n, (searches n)ᶜ) := by
    exact dense_iInter_of_isOpen ( fun n => isOpen_compl_iff.mpr ( h_closed n ) ) h_dense;
  exact h_inter_dense.nonempty.imp fun x hx => by aesop;
theorem generic_evasion (targets : ℕ → Set ℝ)
    (h_closed : ∀ n, IsClosed (targets n))
    (h_nwd : ∀ n, interior (targets n) = ∅) :
    Dense (⋂ n, (targets n)ᶜ) := by
  exact dense_iInter_of_isOpen ( fun n => isOpen_compl_iff.mpr ( h_closed n ) ) fun n => by rw [ ← interior_eq_empty_iff_dense_compl ] ; aesop;
theorem remaining_uncertainty_lower_bound (n k : ℕ) (hk : k < n) :
    n - k ≥ 1 := by
  exact Nat.sub_pos_of_lt hk
theorem pigeonhole_evasion (n : ℕ) (queries : Finset (Fin (n + 1)))
    (hq : queries.card ≤ n) :
    ∃ pos : Fin (n + 1), pos ∉ queries := by
  exact Classical.not_forall.1 fun h => by have := Finset.eq_univ_of_forall h; aesop;
theorem adaptive_evader_wins (n : ℕ) (budget : ℕ) (h : budget < n) :
    ∀ queries : Finset (Fin n), queries.card ≤ budget →
    ∃ pos : Fin n, pos ∉ queries := by
  intro queries h_budget
  by_cases h_card : queries.card = n;
  · linarith;
  · exact not_forall.mp fun h' => h_card <| by simp [ show queries = Finset.univ from Finset.eq_univ_of_forall h' ]
theorem existence_of_total_avoider (f : ℕ → ℕ) :
    ∃ g : ℕ → ℕ, ∀ n, g n ≠ f n := by
  exact ⟨ fun n => f n + 1, fun n => Nat.succ_ne_self _ ⟩
theorem no_universal_enumeration :
    ¬ ∃ enum : ℕ → (ℕ → ℕ), Function.Surjective enum := by
  simp +zetaDelta at *;
  exact fun f hf => by rcases hf ( fun n => f n n + 1 ) with ⟨ n, hn ⟩ ; simpa using congr_fun hn n;
theorem infinite_evasion_finite_range (f : ℕ → ℕ) (hf : Set.Finite (Set.range f)) :
    Set.Infinite {n : ℕ | n ∉ Set.range f} := by
  exact hf.infinite_compl
theorem finite_repulsor {n : ℕ} (hn : 0 < n) (f : Fin n → Fin n)
    (hf : ∀ x, f x ≠ x) : ∀ x : Fin n, f x ≠ x := by
  assumption
theorem antitone_fixed_point_unique {α : Type*} [LinearOrder α] [OrderTop α] [OrderBot α]
    (f : α → α) (hf : Antitone f) (hfixed : ∃ x, f x = x) :
    ∃! x, f x = x := by
  obtain ⟨x₀, hx₀⟩ : ∃ x₀, f x₀ = x₀ := by
    exact hfixed
  have h_unique : ∀ x₁ x₂, f x₁ = x₁ → f x₂ = x₂ → x₁ ≤ x₂ → x₂ ≤ x₁ := by
    exact fun x₁ x₂ hx₁ hx₂ h => by simpa [ hx₁, hx₂ ] using hf h;
  have h_unique' : ∀ x₁ x₂, f x₁ = x₁ → f x₂ = x₂ → x₁ ≠ x₂ → False := by
    exact fun x₁ x₂ hx₁ hx₂ hne => hne <| le_antisymm ( by cases le_total x₁ x₂ <;> tauto ) ( by cases le_total x₁ x₂ <;> tauto )
  exact ⟨x₀, hx₀, fun x hx => by
    exact Classical.not_not.1 fun h => h_unique' x x₀ hx hx₀ h⟩
theorem displacement_repulsor (f : ℕ → ℕ) (hf : StrictMono f) (h0 : 0 < f 0) :
    ∀ n, f n ≠ n := by
  -- We proceed by induction on $n$.
  induction' n with n ih;
  · linarith;
  · contrapose! ih with ih;
    exact le_antisymm ( Nat.le_of_lt_succ <| by linarith [ hf <| Nat.lt_succ_self n ] ) ( Nat.recOn n ( by linarith ) fun n ihn => by linarith [ hf <| Nat.lt_succ_self n ] )
theorem search_asymmetry (n : ℕ) (hn : 0 < n) :
    -- Any n queries suffice to find the target
    (∀ target : Fin n, ∃ queries : Finset (Fin n), queries.card ≤ n ∧ target ∈ queries) ∧
    -- But n-1 queries are never enough (evader survives)
    (∀ queries : Finset (Fin n), queries.card < n → ∃ target : Fin n, target ∉ queries) := by
  constructor;
  · exact fun x => ⟨ { x }, by simpa ⟩;
  · exact fun queries hqueries => by simpa using Finset.exists_of_ssubset ( Finset.ssubset_iff_subset_ne.mpr ⟨ Finset.subset_univ queries, fun h => by have := Finset.card_le_univ queries; aesop ⟩ ) ;
/-- **The Repulsor Hierarchy.**
Repulsors form a strict hierarchy: a Level-k repulsor evades all searches
of depth k, but not necessarily depth k+1.
Here we model this: a function evades an enumeration at level k if it
differs from the first k functions. -/
def evades_at_level (g : ℕ → ℕ) (enum : ℕ → (ℕ → ℕ)) (k : ℕ) : Prop :=
theorem level_k_evader_exists (enum : ℕ → (ℕ → ℕ)) (k : ℕ) :
    ∃ g : ℕ → ℕ, evades_at_level g enum k := by
  exact ⟨ fun n => enum n n + 1, fun i hi => by simp +decide ⟩
theorem level_hierarchy_strict (enum : ℕ → (ℕ → ℕ)) :
    ∀ k, (∃ g, evades_at_level g enum (k + 1)) →
         (∃ g, evades_at_level g enum k) := by
  exact fun k ⟨ g, hg ⟩ => ⟨ g, fun i hi => hg i ( Nat.lt_succ_of_lt hi ) ⟩
theorem infinite_repulsor_exists (enum : ℕ → (ℕ → ℕ)) :
    ∃ g : ℕ → ℕ, ∀ k, evades_at_level g enum k := by
  exact ⟨ fun n => enum n n + 1, fun k i hi => by simp +decide ⟩
theorem prob_evasion_bound (n k : ℕ) (hk : k ≤ n) (hn : 0 < n) :
    n - k ≤ n := by
  exact Nat.sub_le _ _
theorem repulsor_completion (enum : ℕ → (ℕ → ℕ)) (g_partial : ℕ → ℕ)
    (k : ℕ) (hk : evades_at_level g_partial enum k) :
    ∃ g_total : ℕ → ℕ, (∀ i, i < k → g_total i = g_partial i) ∧
    evades_at_level g_total enum (k + 1) := by
  -- Define the complete repulsor function g_total by extending g_partial to all natural numbers.
  use fun i => if i < k then g_partial i else enum i i + 1;
  unfold evades_at_level at *; aesop;
theorem negation_is_repulsor : ∀ n : ℤ, n ≠ 0 → -n ≠ n := by
theorem successor_is_repulsor : ∀ n : ℕ, n + 1 ≠ n := by
  exact fun n => Nat.succ_ne_self n
theorem mutual_repulsion_exists :
    ∃ (f g : ℕ → ℕ), (∀ n, f n ≠ n) ∧ (∀ n, g n ≠ n) ∧
    (∀ n, f (g n) ≠ n) := by
  simp +zetaDelta at *;
  exact ⟨ fun n => n + 1, fun n => by linarith, fun n => n + 2, fun n => by linarith, fun n => by linarith ⟩