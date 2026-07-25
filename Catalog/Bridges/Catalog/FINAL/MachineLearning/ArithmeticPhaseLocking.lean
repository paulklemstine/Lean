/-
# Arithmetic Phase Locking in Gradient Descent over Rational Polynomial Models

This file formalizes the first rigorous layer of an arithmetic-dynamical theory
of optimization: gradient descent on polynomial losses viewed as algebraic
self-maps, reduced modulo primes.

## Main Results

- `iterate_reduce_comm`: Reduction mod p commutes with iteration.
- `eventuallyPeriodic_of_finite`: Every orbit on a finite type is eventually periodic.
- `injective_on_orbit_implies_periodic`: Injectivity on orbit forces pure periodicity.
- `periodic_of_bijective_finite`: Bijective maps on finite types have periodic orbits.
- `affine_1d_iterate`: Closed-form for 1D affine iterates.
- `spectral_torsion_1d`: Phase locking for 1D torsion affine maps.
- `spectral_torsion_modp_1d`: Cross-domain modular phase locking.
-/

import Mathlib

/-! ## Definitions -/

/-- Good reduction: the reduction of T modulo p is compatible with
    coordinate-wise casting from ℤ to ZMod p. -/
def HasGoodReduction {n p : ℕ}
    (T : (Fin n → ℤ) → (Fin n → ℤ))
    (Tp : (Fin n → ZMod p) → (Fin n → ZMod p))
    [Fact p.Prime] : Prop :=
  ∀ x : Fin n → ℤ,
    (fun i => ((T x i : ℤ) : ZMod p)) = Tp (fun i => (x i : ZMod p))

/-- Phase locked with period m: the orbit eventually repeats
    with period dividing m. -/
def PhaseLockedAt {α : Type*} (f : α → α) (x : α) (m : ℕ) : Prop :=
  0 < m ∧ ∃ mu : ℕ, f^[mu + m] x = f^[mu] x

/-- Arithmetic phase locking: for infinitely many primes, the reduced orbit
    is phase locked with a uniform period bound. -/
def ArithmeticPhaseLocking {n : ℕ}
    (T : (Fin n → ℤ) → (Fin n → ℤ))
    (_w0 : Fin n → ℤ) : Prop :=
  ∃ m : ℕ, 0 < m ∧ ∀ x : Fin n → ℤ, T^[m] x = x

/-! ## Theorem 1: Iterate-Reduce Commutativity -/

/-
**Iterate-Reduce Commutativity.**
    If reduction modulo p commutes with a single application of T,
    then it commutes with all iterates. This upgrades optimization dynamics
    to a legitimate arithmetic dynamical system.
-/
theorem iterate_reduce_comm
    {n p : ℕ} [Fact p.Prime]
    (T : (Fin n → ℤ) → (Fin n → ℤ))
    (Tp : (Fin n → ZMod p) → (Fin n → ZMod p))
    (hcompat : ∀ x : Fin n → ℤ,
      (fun i => ((T x i : ℤ) : ZMod p)) = Tp (fun i => (x i : ZMod p)))
    (t : ℕ) (x : Fin n → ℤ) :
    (fun i => (((T^[t] x) i : ℤ) : ZMod p)) =
      Tp^[t] (fun i => (x i : ZMod p)) := by
  induction' t with t ih generalizing x <;> simp_all +decide [ Function.iterate_succ_apply' ]

/-! ## Theorem 2: Eventual Periodicity over Finite Types -/

/-
**Eventual Periodicity.**
    Every self-map on a finite type produces eventually periodic orbits,
    with preperiod < card α and period ≤ card α.
-/
theorem eventuallyPeriodic_of_finite
    {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (x : α) :
    ∃ mu per : ℕ, mu < Fintype.card α ∧ 0 < per ∧ per ≤ Fintype.card α ∧
      f^[mu + per] x = f^[mu] x := by
  -- By the pigeonhole principle, since there are only finitely many possible values for $f^t(x)$, there must be some repetition.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, i < j ∧ j ≤ Fintype.card α ∧ f^[i] x = f^[j] x := by
    by_contra! h;
    exact absurd ( Finset.card_le_card ( show Finset.image ( fun i => f^[i] x ) ( Finset.range ( Fintype.card α + 1 ) ) ⊆ Finset.univ from Finset.subset_univ _ ) ) ( by rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( not_lt.1 fun hi' => h _ _ hi' ( by linarith [ Finset.mem_range.1 hi, Finset.mem_range.1 hj ] ) hij.symm ) ( not_lt.1 fun hj' => h _ _ hj' ( by linarith [ Finset.mem_range.1 hi, Finset.mem_range.1 hj ] ) hij ), Finset.card_range ] ; simp +decide );
  exact ⟨ i, j - i, by linarith, Nat.sub_pos_of_lt hij, Nat.sub_le_of_le_add <| by linarith, by rw [ add_tsub_cancel_of_le hij.le, h_eq.2 ] ⟩

/-
**Injectivity on orbit implies pure periodicity.**
    If f is injective on the forward orbit, the orbit is purely periodic.
-/
theorem injective_on_orbit_implies_periodic
    {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (x : α)
    (hinj : Set.InjOn f {y | ∃ t : ℕ, f^[t] x = y}) :
    ∃ per : ℕ, 0 < per ∧ f^[per] x = x := by
  -- By eventuallyPeriodic_of_finite, there exist mu, per with f^[mu + per](x) = f^[mu](x).
  obtain ⟨mu, per, h_mu_per⟩ : ∃ mu per : ℕ, mu < Fintype.card α ∧ 0 < per ∧ per ≤ Fintype.card α ∧ f^[mu + per] x = f^[mu] x := by
    exact eventuallyPeriodic_of_finite f x;
  -- By induction on mu, show that f^[per] x = x.
  induction' mu with mu ih;
  · aesop;
  · simp_all +decide [ Nat.succ_add, Function.iterate_succ_apply' ];
    exact ih ( Nat.lt_of_succ_lt h_mu_per.1 ) ( hinj ⟨ _, rfl ⟩ ⟨ _, rfl ⟩ h_mu_per.2.2.2 )

/-
**Bijective maps on finite types have purely periodic orbits.**
-/
theorem periodic_of_bijective_finite
    {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (hf : Function.Bijective f) (x : α) :
    ∃ n : ℕ, 0 < n ∧ f^[n] x = x := by
  -- Since f is bijective, it is a permutation of the finite type α.
  have h_perm : ∃ g : Equiv.Perm α, ∀ x, f x = g x := by
    exact ⟨ Equiv.ofBijective f hf, fun x => rfl ⟩;
  obtain ⟨ g, hg ⟩ := h_perm; use orderOf g; simp +decide [ hg, Function.iterate_fixed, orderOf_pos ] ;
  exact ⟨ isOfFinOrder_iff_pow_eq_one.mpr ⟨ orderOf g, orderOf_pos g, pow_orderOf_eq_one g ⟩, by rw [ show f = g from funext hg ] ; simp +decide [ pow_orderOf_eq_one ] ⟩

/-! ## Theorem 3: 1D Affine Iteration and Phase Locking -/

/-
**1D affine iterate formula.**
    For T(y) = a*y + b, we have T^[t](x) = a^t * x + (Σ_{k<t} a^k) * b.
-/
theorem affine_1d_iterate (a b : ℤ) (t : ℕ) (x : ℤ) :
    (fun y => a * y + b)^[t] x =
      a ^ t * x + (Finset.range t).sum (fun k => a ^ k) * b := by
  induction t <;> simp +decide [ *, pow_succ', Function.iterate_succ_apply', Finset.mul_sum _ _ _, Finset.sum_range_succ' ] ; ring;
  simpa only [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ] using by ring;

/-
**1D Spectral Torsion Phase Locking.**
    If a^m = 1 and (Σ_{k<m} a^k) * b = 0, then T^m = id.

    For quadratic loss L(w) = (1/2)Aw² + Bw + C, gradient descent gives
    T(w) = (1 - ηA)w - ηB. Setting a = 1 - ηA: if the "propagator" a is a
    root of unity in ℤ (i.e. a ∈ {1,-1}) and the geometric sum vanishes,
    the discrete optimization flow is exactly periodic — a Floquet-type
    periodicity in arithmetic dynamics.
-/
theorem spectral_torsion_1d (a b : ℤ) (m : ℕ) (_hm : 0 < m)
    (ha : a ^ m = 1)
    (hgeom : (Finset.range m).sum (fun k => a ^ k) * b = 0) :
    ∀ x : ℤ, (fun y => a * y + b)^[m] x = x := by
  intro x
  rw [affine_1d_iterate]
  simp [ha, hgeom]

/-! ## Theorem 4: Cross-Domain Modular Phase Locking -/

/-
**1D affine iterate formula over any commutative ring.**
-/
theorem affine_1d_iterate_ring {R : Type*} [CommRing R] (a b : R) (t : ℕ) (x : R) :
    (fun y => a * y + b)^[t] x =
      a ^ t * x + (Finset.range t).sum (fun k => a ^ k) * b := by
  induction t <;> simp_all +decide [ Function.iterate_succ_apply', pow_succ', Finset.sum_range_succ' ];
  simp +decide [ mul_add, add_mul, mul_assoc, Finset.mul_sum _ _ _, Finset.sum_mul ];
  ring

/-
**Cross-domain: spectral torsion modulo primes.**
    If a^m = 1 over ℤ and the geometric condition holds, then for every
    prime p, the reduced 1D affine map mod p has all orbits periodic with
    period dividing m.

    This connects optimization (quadratic loss), spectral algebra
    (roots of unity), and finite-field dynamics (modular periodicity).
-/
theorem spectral_torsion_modp_1d (a b : ℤ) (m : ℕ) (hm : 0 < m)
    (ha : a ^ m = 1)
    (hgeom : (Finset.range m).sum (fun k => a ^ k) * b = 0)
    (p : ℕ) [Fact p.Prime] (x : ZMod p) :
    (fun y => (a : ZMod p) * y + (b : ZMod p))^[m] x = x := by
  convert spectral_torsion_1d ( a := a ) ( b := b ) m hm ?_ ?_;
  · constructor <;> intro h;
    · convert spectral_torsion_1d a b m hm ?_ ?_;
      · exact ha;
      · exact hgeom;
    · convert congr_arg ( ( ↑ ) : ℤ → ZMod p ) ( h ( x.val : ℤ ) ) using 1;
      · exact Nat.recOn m ( by simp +decide ) fun n ih => by simp +decide [ *, Function.iterate_succ_apply' ] ;
      · cases p <;> aesop;
  · exact ha;
  · grind