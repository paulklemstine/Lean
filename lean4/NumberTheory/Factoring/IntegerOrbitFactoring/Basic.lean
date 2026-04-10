/-
  # Integer Orbit Factoring — Core Definitions and Theorems

  This module formalizes the mathematical foundations of **integer orbit factoring**:
  the study of orbits of iterated maps on ℤ/nℤ and how structural collisions in
  these orbits reveal the prime factorization of n.

  ## Key Concepts

  - **Orbit**: The sequence x, f(x), f(f(x)), ... in ℤ/nℤ
  - **Rho shape**: Every orbit in a finite set eventually enters a cycle (tail + loop)
  - **Factor-revealing collisions**: If n = p·q and f(xᵢ) ≡ f(xⱼ) mod p but not mod n,
    then gcd(xᵢ - xⱼ, n) is a nontrivial factor.
  - **Orbit period divisibility**: The period mod n divides lcm of periods mod each prime power.
-/

import Mathlib

namespace IntegerOrbitFactoring

/-! ## Part I: Orbit Definitions -/

/-- The orbit sequence of `f` starting at `x₀`: iterates f(f(...f(x₀)...)). -/
noncomputable def orbitSeq {α : Type*} (f : α → α) (x₀ : α) : ℕ → α
  | 0     => x₀
  | n + 1 => f (orbitSeq f x₀ n)

/-- The orbit sequence satisfies the recurrence: orbitSeq f x₀ (n+1) = f (orbitSeq f x₀ n). -/
theorem orbitSeq_succ {α : Type*} (f : α → α) (x₀ : α) (n : ℕ) :
    orbitSeq f x₀ (n + 1) = f (orbitSeq f x₀ n) := by
  rfl

/-
orbitSeq agrees with Function.iterate.
-/
theorem orbitSeq_eq_iterate {α : Type*} (f : α → α) (x₀ : α) (n : ℕ) :
    orbitSeq f x₀ n = f^[n] x₀ := by
  induction' n with n ih;
  · rfl;
  · rw [ Function.iterate_succ_apply', orbitSeq_succ ] ; aesop

/-! ## Part II: Collision Detection and Factor Extraction -/

/-- A collision in the orbit is a pair (i, j) with i < j and f^[i](x₀) = f^[j](x₀). -/
def IsCollision {α : Type*} [DecidableEq α] (f : α → α) (x₀ : α) (i j : ℕ) : Prop :=
  i < j ∧ f^[i] x₀ = f^[j] x₀

/-- The standard quadratic map used in Pollard's rho: f(x) = x² + c in ℤ/nℤ. -/
def pollardMap (n : ℕ) (c : ZMod n) : ZMod n → ZMod n :=
  fun x => x * x + c

/-
If x ≡ y mod p and p ∣ n, then p ∣ (x - y) in ℤ, which means gcd(x-y, n) > 1.
    This is the core principle of orbit-based factoring.
-/
theorem factor_from_mod_collision {n p : ℕ} (hp : Nat.Prime p) (hpn : p ∣ n) (hn : 1 < n)
    (x y : ℤ) (hmod : (x : ZMod p) = (y : ZMod p)) (hne : ¬((x : ZMod n) = (y : ZMod n))) :
    1 < Int.gcd (x - y) n := by
  -- Since $x \equiv y \pmod{p}$, we have $(p : \mathbb{Z}) \mid (x - y)$.
  have h_div : (p : ℤ) ∣ (x - y) := by
    exact (ZMod.intCast_eq_intCast_iff_dvd_sub y x p).mp (id (Eq.symm hmod));
  exact lt_of_lt_of_le hp.one_lt ( Nat.le_of_dvd ( Int.gcd_pos_of_ne_zero_right _ ( by linarith ) ) ( Nat.dvd_gcd ( Int.natAbs_dvd_natAbs.mpr h_div ) hpn ) )

/-! ## Part III: Orbit Periodicity -/

/-
In ℤ/nℤ (finite), every orbit is eventually periodic. There exist tail length τ
    and period per > 0 such that for all i ≥ τ, f^[i] = f^[i + per].
-/
theorem orbit_eventually_periodic (n : ℕ) [NeZero n] (f : ZMod n → ZMod n) (x₀ : ZMod n) :
    ∃ tau per : ℕ, 0 < per ∧ ∀ i, tau ≤ i → f^[i] x₀ = f^[i + per] x₀ := by
  -- By the pigeonhole principle, since there are only finitely many possible values in ZMod n, there must exist indices i < j such that f^[i] x₀ = f^[j] x₀.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, i < j ∧ (f^[i] x₀) = (f^[j] x₀) := by
    by_contra! h;
    exact absurd ( Set.infinite_range_of_injective ( fun i j hij => le_antisymm ( not_lt.1 fun hi => h _ _ hi hij.symm ) ( not_lt.1 fun hj => h _ _ hj hij ) ) ) ( Set.not_infinite.2 <| Set.toFinite _ );
  refine' ⟨ i, j - i, Nat.sub_pos_of_lt hij, fun k hk => _ ⟩;
  induction hk <;> simp_all +decide [ Nat.succ_add, Function.iterate_succ_apply' ];
  rw [ Nat.add_sub_cancel' hij.le ]

/-
A collision must occur within the first n+1 steps (pigeonhole).
-/
theorem collision_within_card (n : ℕ) [NeZero n] (f : ZMod n → ZMod n) (x₀ : ZMod n) :
    ∃ i j : ℕ, i < j ∧ j ≤ n ∧ f^[i] x₀ = f^[j] x₀ := by
  -- Consider the first n+1 values f^[0](x₀), ..., f^[n](x₀). These are n+1 elements of ZMod n, which has cardinality n. By pigeonhole, two must be equal.
  have h_pigeonhole : Finset.card (Finset.image (fun i => f^[i] x₀) (Finset.range (n + 1))) ≤ n := by
    exact le_trans ( Finset.card_le_univ _ ) ( by norm_num );
  contrapose! h_pigeonhole;
  rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( not_lt.mp fun hi' => h_pigeonhole _ _ hi' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) hij.symm ) ( not_lt.mp fun hj' => h_pigeonhole _ _ hj' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) hij ) ] ; simp +arith +decide

/-! ## Part IV: Orbit Period and Factorization Structure -/

/-- The reduction map from ZMod n to ZMod p when p ∣ n. -/
noncomputable def reductionMap {n p : ℕ} (hp : p ∣ n) [NeZero n] [NeZero p] :
    ZMod n →+* ZMod p :=
  ZMod.castHom hp (ZMod p)

/-
The quadratic map commutes with reduction modulo divisors:
    if π : ℤ/nℤ → ℤ/pℤ is the natural map and f(x) = x²+c, then
    π(f(x)) = f(π(x)).
-/
theorem pollardMap_commutes_with_reduction {n p : ℕ} (hp : p ∣ n)
    [NeZero n] [NeZero p] (c : ZMod n) (x : ZMod n) :
    reductionMap hp (pollardMap n c x) =
      pollardMap p (reductionMap hp c) (reductionMap hp x) := by
  unfold pollardMap;
  grind +revert

/-
If per_n is a period of the orbit of f in ℤ/nℤ (beyond some tail), then per_n
    is also a period of the projected orbit in ℤ/pℤ.
-/
theorem orbit_period_projects {n p : ℕ} (hp : p ∣ n) [NeZero n] [NeZero p]
    (f : ZMod n → ZMod n) (g : ZMod p → ZMod p) (x₀ : ZMod n)
    (hcomm : ∀ x, reductionMap hp (f x) = g (reductionMap hp x))
    (tau per_n : ℕ) (hper_n : 0 < per_n)
    (hperiod_n : ∀ i, tau ≤ i → f^[i] x₀ = f^[i + per_n] x₀) :
    ∀ i, tau ≤ i →
      g^[i] (reductionMap hp x₀) = g^[i + per_n] (reductionMap hp x₀) := by
  -- By induction on $k$, we show that reductionMap hp (f^[k] x₀) = g^[k] (reductionMap hp x₀).
  have h_ind : ∀ k : ℕ, reductionMap hp (f^[k] x₀) = g^[k] (reductionMap hp x₀) := by
    intro k; induction k <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
  exact fun i hi => h_ind i ▸ h_ind ( i + per_n ) ▸ hperiod_n i hi ▸ rfl

/-! ## Part V: Floyd's Cycle Detection -/

/-
Floyd's tortoise-and-hare algorithm: if there is a collision at (i, j) with j ≤ bound,
    then there exists k ≤ bound such that f^[k] x₀ = f^[2*k] x₀.
-/
theorem floyd_detection {α : Type*} [DecidableEq α] [Fintype α]
    (f : α → α) (x₀ : α) :
    ∃ k : ℕ, 0 < k ∧ k ≤ Fintype.card α ∧ f^[k] x₀ = f^[2 * k] x₀ := by
  -- Let's choose any $i < j \leq \text{Fintype.card} \alpha$ such that $f^[i] x₀ = f^[j] x₀$.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j, i < j ∧ j ≤ Fintype.card α ∧ f^[i] x₀ = f^[j] x₀ := by
    by_contra h_no_collision;
    exact absurd ( Finset.card_le_univ ( Finset.image ( fun k => f^[k] x₀ ) ( Finset.Icc 0 ( Fintype.card α ) ) ) ) ( by rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( not_lt.mp fun hi' => h_no_collision ⟨ j, i, hi', by aesop, hij.symm ⟩ ) ( not_lt.mp fun hj' => h_no_collision ⟨ i, j, hj', by aesop, hij ⟩ ) ] ; simpa );
  -- Let per = j - i. Then for any m ≥ i, f^[m] x₀ = f^[m+per] x₀.
  set per := j - i with hper_def
  have h_period : ∀ m ≥ i, f^[m] x₀ = f^[m + per] x₀ := by
    intro m hm
    induction' hm with m hm ih;
    · rw [ Nat.add_sub_of_le hij.le, h_eq.2 ];
    · rw [ Nat.succ_add, Function.iterate_succ_apply', Function.iterate_succ_apply', ih ];
  -- Choose k to be the smallest multiple of per that is ≥ i. Then k ≤ i + per ≤ Fintype.card α.
  obtain ⟨k, hk⟩ : ∃ k, i ≤ k ∧ k ≤ Fintype.card α ∧ per ∣ k := by
    exact ⟨ per * ( i / per + 1 ), by linarith [ Nat.div_add_mod i per, Nat.mod_lt i ( Nat.sub_pos_of_lt hij ) ], by nlinarith [ Nat.div_mul_le_self i per, Nat.sub_add_cancel hij.le ], by norm_num ⟩;
  -- Since k is a multiple of per, we have f^[k] x₀ = f^[k + per] x₀ = f^[k + 2*per] x₀ = ... = f^[2*k] x₀.
  have h_k_periodic : ∀ m ≥ i, per ∣ m → f^[m] x₀ = f^[2 * m] x₀ := by
    intro m hm hper
    have h_iter : ∀ t, f^[m + t * per] x₀ = f^[m] x₀ := by
      intro t; induction' t with t ih <;> simp_all +decide [ Nat.succ_mul, ← add_assoc ] ;
      rw [ ← h_period _ ( by nlinarith ), ih ];
    obtain ⟨ t, rfl ⟩ := hper; specialize h_iter t; ring_nf at *; aesop;
  grind

/-! ## Part VI: GCD Accumulation Theorem -/

/-
In Pollard's rho, we can accumulate products before taking GCD.
    If any factor divides one term xᵢ - xⱼ, it divides the product.
-/
theorem gcd_of_product_dvd {n : ℕ} (hn : 1 < n)
    (vals : Fin k → ℤ) (p : ℕ) (hp : Nat.Prime p) (hpn : p ∣ n)
    (j : Fin k) (hdvd : (p : ℤ) ∣ vals j) :
    1 < Int.gcd (∏ i, vals i) n := by
  refine' lt_of_lt_of_le hp.one_lt ( Nat.le_of_dvd ( Int.gcd_pos_of_ne_zero_right _ ( by positivity ) ) ( Nat.dvd_gcd ( Int.natCast_dvd.mp ( dvd_trans hdvd <| Finset.dvd_prod_of_mem _ <| Finset.mem_univ _ ) ) hpn ) )

end IntegerOrbitFactoring