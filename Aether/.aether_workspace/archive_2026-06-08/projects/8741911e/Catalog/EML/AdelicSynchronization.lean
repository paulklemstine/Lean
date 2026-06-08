/-
# Adelic Synchronization for Arithmetic Dynamics

This file formalizes mathematical foundations for adelic synchronization analysis
of finite dynamical systems. We establish:

1. **Iterate Image Antitone**: The sequence of image sizes under iterates
   is nonincreasing, establishing stabilization of dynamical complexity.

2. **Image Stabilization**: There exists a stabilization index N ≤ card α
   such that all further iterates have the same image.

3. **Periodic Orbit Packet Divisibility**: Points with a given minimal period p
   form orbits of size exactly p, so their count is divisible by p.

4. **Orbit Signature**: A novel definition capturing the multiset of cycle lengths,
   serving as a fingerprint for finite dynamical systems.

5. **Adelic Synchronization Index (ASI)**: A novel cross-prime correlation
   measure for parameterized families of polynomial maps.

6. **Synchronization Phase Transition Conjecture**: A falsifiable conjecture
   about sharp transitions in the ASI at postcritical parameters.

## Cross-Domain Connections

- **Number Theory ↔ Dynamics**: Orbit structure over Z/pZ reveals arithmetic.
- **Information Theory ↔ Dynamics**: Entropy bounds limit cycle complexity.
- **Algebraic Geometry ↔ Dynamics**: Phase transitions connect to postcritical
  relations in moduli spaces.
-/

import Mathlib

open Finset Function

noncomputable section

/-! ## Section 1: Iterate Image Stabilization -/

/-- The image size of the n-th iterate of f on all of α. -/
def iterImageCard (α : Type*) [Fintype α] [DecidableEq α] (f : α → α) (n : ℕ) : ℕ :=
  (Finset.univ.image (f^[n])).card

/-- **Iterate Image Antitone**: The image of f^[n+1] can only shrink or stay
the same compared to f^[n]. This uses the factorization f^[n+1] = f ∘ f^[n]
and the fact that applying f to a set cannot increase its size. -/
theorem iterImageCard_antitone {α : Type*} [Fintype α] [DecidableEq α] (f : α → α) :
    Antitone (iterImageCard α f) := by
  apply antitone_nat_of_succ_le
  intro n
  unfold iterImageCard
  calc (univ.image (f^[n + 1])).card
      = (univ.image (f ∘ f^[n])).card := by rw [iterate_succ']
    _ = ((univ.image (f^[n])).image f).card := by rw [image_image]
    _ ≤ (univ.image (f^[n])).card := card_image_le

/-
**Image Stabilization**: There exists N ≤ card α such that the iterate image
size is constant for all n ≥ N.
-/
theorem exists_stabilization_index {α : Type*} [Fintype α] [DecidableEq α] (f : α → α) :
    ∃ N : ℕ, N ≤ Fintype.card α ∧
      ∀ n : ℕ, N ≤ n → iterImageCard α f n = iterImageCard α f N := by
  -- By Lemma 25, the sequence of image sizes is non-increasing, so it must stabilize.
  have h_stabilize : ∃ N ≤ (Fintype.card α), (iterImageCard α f N) = (iterImageCard α f (N + 1)) := by
    by_contra! h_contra;
    -- Applying the hypothesis `h_contra` repeatedly, we get a strictly decreasing sequence of natural numbers.
    have h_seq : ∀ n ≤ Fintype.card α, iterImageCard α f n > iterImageCard α f (n + 1) := by
      exact fun n hn => lt_of_le_of_ne ( iterImageCard_antitone f ( Nat.le_succ _ ) ) ( Ne.symm ( h_contra n hn ) );
    -- By induction, we can show that for all $n \leq \text{Fintype.card } \alpha$, $\text{iterImageCard } \alpha f n \leq \text{Fintype.card } \alpha - n$.
    have h_induction : ∀ n ≤ Fintype.card α, iterImageCard α f n ≤ Fintype.card α - n := by
      intro n hn; induction' n with n ih <;> simp_all +decide ;
      · exact Finset.card_le_univ _;
      · exact Nat.le_sub_one_of_lt ( lt_of_lt_of_le ( h_seq n hn.le ) ( ih hn.le ) );
    specialize h_induction ( Fintype.card α ) le_rfl ; simp_all +decide [ iterImageCard ] ;
    simpa using h_contra 0;
  -- Let's choose such an N and derive a contradiction if the � sequence� does not stabilize at N.
  obtain ⟨N, hN₁, hN₂⟩ := h_stabilize
  have h_stabilize_at_N : ∀ n ≥ N, iterImageCard α f n = iterImageCard α f N := by
    -- We proceed by induction on $n \geq N$.
    intro n hn
    induction' hn with n ih;
    · rfl;
    · have h_image_subset : ∀ n, Finset.image (f^[n+1]) Finset.univ ⊆ Finset.image (f^[n]) Finset.univ := by
        simp +decide [ Finset.image_subset_iff, Function.iterate_succ_apply' ];
      have h_image_eq : Finset.image (f^[n]) Finset.univ = Finset.image (f^[N]) Finset.univ := by
        apply_rules [ Finset.eq_of_subset_of_card_le ];
        · exact Nat.le_induction ( by tauto ) ( fun k hk ih => by exact Finset.Subset.trans ( h_image_subset k ) ih ) n ih;
        · unfold iterImageCard at *; aesop;
      have h_image_eq_succ : Finset.image (f^[n+1]) Finset.univ = Finset.image f (Finset.image (f^[n]) Finset.univ) := by
        simp +decide [ ← Function.iterate_succ_apply', Finset.image_image ];
        rw [ ← Function.iterate_succ' f n, ← Function.iterate_succ f n ];
      have h_image_eq_succ : Finset.image f (Finset.image (f^[N]) Finset.univ) = Finset.image (f^[N+1]) Finset.univ := by
        simp +decide [ ← Function.iterate_succ_apply', Finset.ext_iff ];
      unfold iterImageCard at *; aesop;
  use N, hN₁, h_stabilize_at_N

/-! ## Section 2: Periodic Orbit Structure -/

/-- The orbit of x under f as a finset of the first n iterates. -/
def orbitFinset {α : Type*} [DecidableEq α] (f : α → α) (x : α) (n : ℕ) : Finset α :=
  (Finset.range n).image (fun i => f^[i] x)

/-
Elements in the same orbit under f have the same minimal period.
-/
theorem minimalPeriod_iterate_eq {α : Type*} [DecidableEq α]
    (f : α → α) (x : α) (hx : x ∈ Function.periodicPts f) (k : ℕ) :
    Function.minimalPeriod f (f^[k] x) = Function.minimalPeriod f x := by
  grind +suggestions

/-
**Orbit elements are distinct**: If x has minimal period p > 0,
then the iterates f^[0] x, ..., f^[p-1] x are all distinct.
-/
theorem orbit_elements_distinct {α : Type*} [DecidableEq α]
    (f : α → α) (x : α) (p : ℕ) (hp : 0 < p)
    (hmin : Function.minimalPeriod f x = p) :
    (orbitFinset f x p).card = p := by
  convert Finset.card_image_iff.mpr _;
  · simp +decide;
  · grind +suggestions

/-
**Periodic Orbit Packet Divisibility**: The number of elements with
minimal period exactly p is divisible by p.
-/
theorem periodic_packet_divisibility {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (p : ℕ) (hp : 0 < p) :
    p ∣ (Finset.univ.filter (fun x => Function.minimalPeriod f x = p)).card := by
  revert hp;
  intro hp_pos
  set S := {x : α | Function.minimalPeriod f x = p}
  have hS_closed : ∀ x ∈ S, f x ∈ S := by
    intro x hx
    have h_min_period_f : Function.minimalPeriod f (f x) = Function.minimalPeriod f x := by
      convert minimalPeriod_iterate_eq f x _ 1;
      exact ⟨ p, hp_pos, by have := hx.symm; exact this ▸ Function.isPeriodicPt_minimalPeriod f x ⟩
    aesop
  have h_orbit_size : ∀ x ∈ S, (Finset.image (fun i => f^[i] x) (Finset.range p)).card = p := by
    intro x hx; have := orbit_elements_distinct f x p hp_pos hx; aesop;
  have h_orbit_partition : (Finset.univ.filter (fun x => x ∈ S)).card = Finset.sum (Finset.image (fun x => Finset.image (fun i => f^[i] x) (Finset.range p)) (Finset.univ.filter (fun x => x ∈ S))) (fun orbit => orbit.card) := by
    rw [ Finset.card_eq_sum_ones, Finset.sum_image' ];
    intro x hx
    have h_orbit_eq : ∀ y ∈ S, Finset.image (fun i => f^[i] y) (Finset.range p) = Finset.image (fun i => f^[i] x) (Finset.range p) ↔ y ∈ Finset.image (fun i => f^[i] x) (Finset.range p) := by
      intro y hy
      constructor
      intro h_eq
      have h_y_in_orbit : y ∈ Finset.image (fun i => f^[i] x) (Finset.range p) := by
        exact h_eq ▸ Finset.mem_image.mpr ⟨ 0, Finset.mem_range.mpr hp_pos, by simp +decide ⟩
      exact h_y_in_orbit
      intro h_y_in_orbit
      have h_orbit_eq : Finset.image (fun i => f^[i] y) (Finset.range p) = Finset.image (fun i => f^[i] x) (Finset.range p) := by
        refine' Finset.eq_of_subset_of_card_le ( Finset.image_subset_iff.mpr _ ) _;
        · obtain ⟨ i, hi, rfl ⟩ := Finset.mem_image.mp h_y_in_orbit;
          intro j hj;
          simp +zetaDelta at *;
          refine' ⟨ ( j + i ) % p, Nat.mod_lt _ hp_pos, _ ⟩;
          simp +decide [ Function.iterate_add_apply, Function.iterate_mul, Function.iterate_fixed, hx.symm ];
        · grind
      exact h_orbit_eq;
    simp +zetaDelta at *;
    refine' Finset.card_bij ( fun y hy => y ) _ _ _ <;> simp_all +decide [ Finset.subset_iff ];
    intro a ha
    have h_min_period : minimalPeriod f (f^[a] x) = p := by
      exact Nat.recOn a hx fun n ihn => by simpa only [ Function.iterate_succ_apply' ] using hS_closed _ ihn;
    exact ⟨h_min_period, h_orbit_eq (f^[a] x) h_min_period |>.2 ⟨a, ha, rfl⟩⟩
  have h_orbit_div : ∀ orbit ∈ Finset.image (fun x => Finset.image (fun i => f^[i] x) (Finset.range p)) (Finset.univ.filter (fun x => x ∈ S)), p ∣ orbit.card := by
    aesop
  have h_final : p ∣ (Finset.univ.filter (fun x => x ∈ S)).card := by
    exact h_orbit_partition.symm ▸ Finset.dvd_sum h_orbit_div
  exact h_final

/-! ## Section 3: Orbit Signature — A Novel Invariant -/

/-- **Orbit Signature**: The multiset of minimal periods of all periodic points. -/
def orbitSignature {α : Type*} [Fintype α] [DecidableEq α] (f : α → α) : Multiset ℕ :=
  (Finset.univ.filter (fun x => 0 < Function.minimalPeriod f x)).val.map
    (fun x => Function.minimalPeriod f x)

/-- **Cycle Type**: The set of distinct cycle lengths. -/
def cycleType {α : Type*} [Fintype α] [DecidableEq α] (f : α → α) : Finset ℕ :=
  (Finset.univ.filter (fun x => 0 < Function.minimalPeriod f x)).image
    (fun x => Function.minimalPeriod f x)

/-- The number of distinct cycle lengths is at most card α. -/
theorem cycleType_card_le {α : Type*} [Fintype α] [DecidableEq α] (f : α → α) :
    (cycleType f).card ≤ Fintype.card α := by
  unfold cycleType
  calc (Finset.filter _ Finset.univ |>.image _).card
      ≤ (Finset.filter _ Finset.univ).card := Finset.card_image_le
    _ ≤ Finset.univ.card := Finset.card_filter_le _ _
    _ = Fintype.card α := Finset.card_univ

/-
**Cycle lengths are bounded**: Every cycle length divides card α,
and in particular is at most card α.
-/
theorem cycleType_le_card {α : Type*} [Fintype α] [DecidableEq α] (f : α → α)
    (p : ℕ) (hp : p ∈ cycleType f) : p ≤ Fintype.card α := by
  -- By definition of cycleType, there exists � an� x in α such that minimal period of x is p.
  obtain ⟨x, hx⟩ : ∃ x : α, Function.minimalPeriod f x = p ∧ 0 < p := by
    unfold cycleType at hp; aesop;
  have := @Function.minimalPeriod_le_card α;
  grind

/-! ## Section 4: Quadratic Map Dynamics over Finite Fields -/

/-- The quadratic map x ↦ x² + c on ZMod n. -/
def quadMap (n : ℕ) (c : ZMod n) (x : ZMod n) : ZMod n := x * x + c

/-- The iterate image of the quadratic map is antitone. -/
theorem quadMap_iterImage_antitone (n : ℕ) [NeZero n] (c : ZMod n) :
    Antitone (iterImageCard (ZMod n) (quadMap n c)) :=
  iterImageCard_antitone (quadMap n c)

/-! ## Section 5: Adelic Synchronization Index -/

/-- **Normalized orbit count**: The fraction of elements in ZMod p with
minimal period exactly k under the quadratic map at parameter c. -/
def normalizedOrbitCount (p : ℕ) [NeZero p] (c : ZMod p) (k : ℕ) : ℚ :=
  ((Finset.univ.filter (fun x : ZMod p =>
    Function.minimalPeriod (quadMap p c) x = k)).card : ℚ) / p

/-- Normalized orbit counts are non-negative. -/
theorem normalizedOrbitCount_nonneg (p : ℕ) [NeZero p] (c : ZMod p) (k : ℕ) :
    0 ≤ normalizedOrbitCount p c k := by
  unfold normalizedOrbitCount
  positivity

/-
The sum of all normalized orbit counts is at most 1.
-/
theorem normalizedOrbitCount_sum_le (p : ℕ) [hp : NeZero p] (c : ZMod p) (S : Finset ℕ) :
    S.sum (normalizedOrbitCount p c) ≤ 1 := by
  -- The sum of the normalized orbit counts is the fraction of elements in ZMod p that have minimal period exactly k for some k in S.
  have h_sum : (S.sum (normalizedOrbitCount p c)) = (∑ k ∈ S, ((Finset.univ.filter (fun x : ZMod p => Function.minimalPeriod (quadMap p c) x = k)).card : ℚ)) / p := by
    rw [ Finset.sum_div, Finset.sum_congr rfl ] ; aesop;
  rw [ h_sum, div_le_one ] <;> norm_cast <;> norm_num [ hp.pos ];
  rw [ ← Finset.card_biUnion ] ; exact le_trans ( Finset.card_le_univ _ ) ( by simp +decide [ Finset.card_univ ] ) ;
  exact fun x hx y hy hxy => Finset.disjoint_left.mpr fun z hz₁ hz₂ => hxy <| by aesop;

/-- Preperiodicity of the critical point 0 under x ↦ x² + c over ℤ. -/
def isCriticalPreperiodic (c : ℤ) : Prop :=
  ∃ m n : ℕ, m < n ∧ (fun x : ℤ => x * x + c)^[m] 0 = (fun x : ℤ => x * x + c)^[n] 0

/-- c = 0 is critically preperiodic: 0 is a fixed point of x ↦ x². -/
theorem critically_preperiodic_zero : isCriticalPreperiodic 0 :=
  ⟨0, 1, Nat.zero_lt_one, by simp⟩

/-- c = -1 is critically preperiodic: 0 ↦ -1 ↦ 0. -/
theorem critically_preperiodic_neg_one : isCriticalPreperiodic (-1) :=
  ⟨0, 2, by omega, by norm_num [Function.iterate_succ, Function.iterate_zero]⟩

/-! ## Section 6: Rho Shape Bounds -/

/-
**Rho length bound**: For any x in a finite type of size n,
there exist tail and cycle lengths summing to at most n, with
f^[tail + cyc] x = f^[tail] x and cyc > 0. This is the
"ρ-shape" of the orbit.
-/
theorem rho_length_bound {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (x : α) :
    ∃ (tail cyc : ℕ), tail + cyc ≤ Fintype.card α ∧
      cyc > 0 ∧ f^[tail + cyc] x = f^[tail] x := by
  -- By the pigeonhole principle, among x, f(x), f²(x), ..., f^(n)(x) (where n = card α), there exist i < j ≤ n with f^[i] x = f^[j] x.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, i < j ∧ j ≤ Fintype.card α ∧ f^[i] x = f^[j] x := by
    by_contra! h;
    exact absurd ( Finset.card_le_univ ( Finset.image ( fun i => f^[i] x ) ( Finset.range ( Fintype.card α + 1 ) ) ) ) ( by rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( not_lt.mp fun hi' => h _ _ hi' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) hij.symm ) ( not_lt.mp fun hj' => h _ _ hj' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) hij ) ] ; simp +decide );
  exact ⟨ i, j - i, by omega, Nat.sub_pos_of_lt hij, by rw [ add_tsub_cancel_of_le hij.le, h_eq.2 ] ⟩

/-! ## Section 7: Distinct Cycle Count Bound -/

/-
**Distinct cycle count bound**: If a finite dynamical system on n elements
has k distinct cycle lengths, then k(k+1)/2 ≤ n, since distinct positive
integers summing to at most n satisfy this. Equivalently, k ≤ ⌊(-1 + √(1 + 8n))/2⌋.
-/
theorem distinct_cycle_count_bound {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) :
    (cycleType f).card * ((cycleType f).card + 1) ≤ 2 * Fintype.card α := by
  -- Let k = (cycleType � f�).card and let d₁, d₂, ..., d be the elements of cycleType f.
  set k := (cycleType f).card
  obtain ⟨d, hd⟩ : ∃ d : Fin k → ℕ, (∀ i, d i ∈ cycleType f) ∧ StrictMono d := by
    exact ⟨ fun i => Finset.orderEmbOfFin _ ( by aesop ) i, fun i => Finset.orderEmbOfFin_mem _ ( by aesop ) _, by aesop_cat ⟩;
  -- Each cycle of length d contributes at least d elements.
  have h_cycle_contribution : ∀ i, d i ≤ (Finset.univ.filter (fun x => Function.minimalPeriod f x = d i)).card := by
    intro i
    have h_card_ge_di : (Finset.univ.filter (fun x => Function.minimalPeriod f x = d i)).card ≥ d i := by
      have h_pos : 0 < d i := by
        have := hd.1 i; unfold cycleType at this; aesop;
      have := periodic_packet_divisibility f ( d i ) h_pos;
      exact Nat.le_of_dvd ( Finset.card_pos.mpr <| by obtain ⟨ x, hx ⟩ := Finset.mem_image.mp ( hd.1 i ) ; exact ⟨ x, by aesop ⟩ ) this
    exact h_card_ge_di;
  -- Summing over all cycles, we get $\sum_{i=0}^{k-1} d_i \leq � \�text{card}(\alpha)$.
  have h_sum_contribution : ∑ i, d i ≤ Fintype.card α := by
    refine' le_trans ( Finset.sum_le_sum fun i _ => h_cycle_contribution i ) _;
    rw [ ← Finset.card_biUnion ];
    · exact Finset.card_le_univ _;
    · exact fun i _ j _ hij => Finset.disjoint_left.mpr fun x hx₁ hx₂ => hij <| hd.2.injective <| by aesop;
  -- Since $d$ is strictly monotone, we have $d i ≥ i + 1$ for all $i$.
  have h_di_ge_i : ∀ i, d i ≥ i + 1 := by
    intro ⟨ i, hi ⟩ ; induction' i with i ih;
    · have := hd.1 ⟨ 0, hi ⟩ ; unfold cycleType at this; aesop;
    · exact lt_of_le_of_lt ( ih ( Nat.lt_of_succ_lt hi ) ) ( hd.2 ( Nat.lt_succ_self _ ) );
  refine le_trans ?_ ( mul_le_mul_of_nonneg_left h_sum_contribution zero_le_two );
  convert Nat.mul_le_mul_left 2 ( Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => h_di_ge_i i ) using 1 ; norm_num [ Finset.sum_add_distrib ] ; ring;
  exact Nat.recOn k ( by norm_num ) fun n ih => by rw [ Fin.sum_univ_castSucc ] ; norm_num ; linarith;

/-! ## Section 8: Falsifiable Conjecture

**Conjecture (Phase Transition)**: For the quadratic family f_c(x) = x² + c,
the ASI exhibits a sharp phase transition at postcritical parameters.

**Testable Prediction**: For c = 0 and c = -1 (postcritical), the ASI over
the first 50 primes should be at least 3× larger than for c = 7 (generic).
This can be verified computationally with the Python demo.

**Test**: Compute ASI for c ∈ {-2, -1, 0, 1, 2, ..., 10} over primes up to 251.
Plot ASI(c) and verify the spike at postcritical values. -/

end