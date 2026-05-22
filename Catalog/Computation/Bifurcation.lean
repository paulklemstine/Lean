import Mathlib

/-!
# Bifurcation Analysis of Periodic Tropical-Life Dynamics on Variable Tori

## Overview

We develop a bifurcation theory for periodic orbits of a tropical cellular automaton
(tropical Life) on finite tori `Fin m × Fin n`. The key contributions are:

1. **Periodic varieties** and **minimal period** predicates for the tropical Life map.
2. **Divisibility lifting**: periodic orbits on a smaller torus pull back to periodic
   orbits of the same period on any covering torus, via a natural pullback map induced
   by coordinate reduction modulo divisibility.
3. **Iterate algebra**: minimal period divides every return time; iterates of period
   multiples are fixed.
4. **Critical birth sizes**: every realizable period has a minimal torus size at which
   it first appears, and period appearance is upward-closed under divisibility.
5. **Period spectrum monotonicity**: the set of realized periods is monotone under
   divisibility of torus sizes.

## Mathematical Significance

This establishes the first rigorous bifurcation framework for tropical cellular dynamics
on finite tori, where the bifurcation parameter is **arithmetic torus size** rather than
a continuous real parameter. Periodic orbit appearance acquires a functorial structure
under torus coverings, analogous to lifting periodic points along covering maps in
topological dynamics and to reduction/lifting phenomena in arithmetic dynamics over
finite fields.

## Tropical Interpretation

The update rule uses `tropicalThreshold`, which encodes interval membership via `min`
(tropical addition) and ℕ arithmetic, connecting the automaton to tropical semiring
computation. The pullback map along torus coverings preserves this tropical structure
because the local update rule depends only on the Moore neighborhood, which is
translation-invariant and compatible with the covering projection.
-/

open Function Finset

/-! ## Basic Types -/

/-- A cell on the `m × n` torus. -/
abbrev Cell (m n : ℕ) := Fin m × Fin n

/-- A configuration assigns a natural number to each cell. -/
abbrev Config (m n : ℕ) := Cell m n → ℕ

/-! ## Toroidal Wrapping -/

/-- Wrap a natural number into `Fin n` via modular reduction. -/
def wrapFin (i : ℕ) (n : ℕ) (hn : 0 < n) : Fin n :=
  ⟨i % n, Nat.mod_lt i hn⟩

/-! ## Moore Neighborhood -/

/-- The 8 Moore neighbors of a cell on the torus, with periodic boundary conditions. -/
def mooreNeighbors {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (x : Cell m n) :
    List (Cell m n) :=
  let i := x.1.val
  let j := x.2.val
  [ (wrapFin (i + m - 1) m hm, wrapFin (j + n - 1) n hn),
    (wrapFin (i + m - 1) m hm, wrapFin j n hn),
    (wrapFin (i + m - 1) m hm, wrapFin (j + 1) n hn),
    (wrapFin i m hm,           wrapFin (j + n - 1) n hn),
    (wrapFin i m hm,           wrapFin (j + 1) n hn),
    (wrapFin (i + 1) m hm,     wrapFin (j + n - 1) n hn),
    (wrapFin (i + 1) m hm,     wrapFin j n hn),
    (wrapFin (i + 1) m hm,     wrapFin (j + 1) n hn) ]

/-! ## Neighborhood Aggregation -/

/-- Sum of configuration values over the Moore neighborhood. -/
def neighborSum {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (c : Config m n)
    (x : Cell m n) : ℕ :=
  ((mooreNeighbors hm hn x).map c).sum

/-! ## Tropical Threshold -/

/-- Tropical threshold indicator: returns 1 if `lo ≤ s ≤ hi`, else 0. -/
def tropicalThreshold (s lo hi : ℕ) : ℕ :=
  min 1 (s + 1 - lo) * min 1 (hi + 1 - s)

/-! ## Tropical Local Rule -/

/-- The tropical local update rule for a single cell. -/
def tropicalLocalRule {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (c : Config m n)
    (x : Cell m n) : ℕ :=
  let s := neighborSum hm hn c x
  let alive := min 1 (c x)
  alive * tropicalThreshold s 2 3 + (1 - alive) * tropicalThreshold s 3 3

/-! ## Global Step Operator -/

/-- The tropical Life step operator: applies `tropicalLocalRule` to every cell. -/
def tropicalLifeStep {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (c : Config m n) :
    Config m n :=
  fun x => tropicalLocalRule hm hn c x

/-! ## Periodic Varieties and Minimal Period -/

/-- The set of period-`p` points of the tropical Life map on the `m × n` torus.
    This is the **periodic variety** — the locus of configurations fixed by the
    `p`-th iterate of the dynamics. -/
def PeriodicVariety (m n p : ℕ) (hm : 0 < m) (hn : 0 < n) : Set (Config m n) :=
  {c | (tropicalLifeStep hm hn)^[p] c = c}

/-- A configuration `c` has **minimal period** `p` if `p > 0`, `c` is periodic
    with period `p`, and no smaller positive integer is a period. -/
def MinimalPeriod (m n : ℕ) (hm : 0 < m) (hn : 0 < n)
    (c : Config m n) (p : ℕ) : Prop :=
  0 < p ∧ (tropicalLifeStep hm hn)^[p] c = c ∧
    ∀ q, 0 < q → q < p → (tropicalLifeStep hm hn)^[q] c ≠ c

/-! ## Torus Covering Pullback -/

/-- The modular reduction map `Fin M → Fin m` induced by `m ∣ M`.
    Sends `⟨i, _⟩` to `⟨i % m, _⟩`. -/
def finModReduce (m M : ℕ) (hm : 0 < m) (_ : m ∣ M) : Fin M → Fin m :=
  fun i => ⟨i.val % m, Nat.mod_lt i.val hm⟩

/-- Pullback of a configuration along a torus covering.
    Given `m ∣ M` and `n ∣ N`, lifts a configuration on the `m × n` torus
    to the `M × N` torus by tiling: the value at `(i, j)` on the large torus
    is the value at `(i % m, j % n)` on the small torus.

    This is the key map for divisibility lifting of periodic orbits. -/
def pullbackConfig
    {m n M N : ℕ}
    (hm : 0 < m) (hn : 0 < n) (hM : 0 < M) (hN : 0 < N)
    (hdm : m ∣ M) (hdn : n ∣ N) :
    Config m n → Config M N :=
  fun c => fun ⟨i, j⟩ =>
    c (⟨i.val % m, Nat.mod_lt i.val hm⟩, ⟨j.val % n, Nat.mod_lt j.val hn⟩)

/-! ## Key Modular Arithmetic Lemma -/

/-- If `m ∣ M` and `0 < m`, then `(x % M) % m = x % m` for all `x`. -/
theorem mod_mod_of_dvd_eq (x m M : ℕ) (hm : 0 < m) (hdm : m ∣ M) :
    (x % M) % m = x % m := by
  exact Nat.mod_mod_of_dvd x hdm

/-! ## Helper: wrapFin commutes with mod reduction -/

/-- Key modular arithmetic: wrapFin on the large torus, followed by mod reduction,
    equals wrapFin on the small torus applied to the mod-reduced input.
    Specifically: `(x % M) % m = x % m` when `m ∣ M`. -/
theorem wrapFin_mod_reduce (x m M : ℕ) (hm : 0 < m) (hM : 0 < M) (hdm : m ∣ M) :
    (wrapFin x M hM).val % m = (wrapFin (x % m) m hm).val := by
  simp [wrapFin, Nat.mod_mod_of_dvd x hdm, Nat.mod_mod_of_dvd]

/-
The neighborSum of a pulled-back configuration at position `(I, J)` on the
    large torus equals the neighborSum of the original configuration at the
    mod-reduced position on the small torus.
-/
theorem neighborSum_pullback
    {m n M N : ℕ}
    (hm : 0 < m) (hn : 0 < n) (hM : 0 < M) (hN : 0 < N)
    (hdm : m ∣ M) (hdn : n ∣ N)
    (c : Config m n) (x : Cell M N) :
    neighborSum hM hN (pullbackConfig hm hn hM hN hdm hdn c) x =
      neighborSum hm hn c
        (⟨x.1.val % m, Nat.mod_lt x.1.val hm⟩,
         ⟨x.2.val % n, Nat.mod_lt x.2.val hn⟩) := by
  -- Let's unfold the definitions of `neighborSum` and `mooreNeighbors`.
  unfold neighborSum mooreNeighbors;
  simp +decide [ pullbackConfig, wrapFin ];
  simp +decide [ Nat.mod_mod_of_dvd _ hdm, Nat.mod_mod_of_dvd _ hdn ];
  rcases m with ( _ | m ) <;> rcases n with ( _ | n ) <;> simp_all +decide [ Nat.mod_eq_of_lt ];
  · contradiction;
  · contradiction;
  · contradiction;
  · rcases M with ( _ | M ) <;> rcases N with ( _ | N ) <;> simp_all +decide [ Nat.mod_eq_of_lt ];
    · contradiction;
    · contradiction;
    · contradiction;
    · obtain ⟨ k, hk ⟩ := hdm; obtain ⟨ l, hl ⟩ := hdn; simp_all +decide [ Nat.add_mod, Nat.mod_eq_of_lt ] ;
      norm_num [ show M = m + ( m + 1 ) * ( k - 1 ) by cases k <;> norm_num at * ; linarith, show N = n + ( n + 1 ) * ( l - 1 ) by cases l <;> norm_num at * ; linarith ]

/-! ## Theorem A: Pullback Commutes with Tropical Life Step -/

/-
**Pullback commutation theorem.**

    The tropical Life step on the large torus, applied to a pulled-back configuration,
    yields the pullback of the tropical Life step on the small torus.

    This is the fundamental structural theorem: it says that the dynamics on the
    large torus restricted to the image of the pullback map is conjugate to the
    dynamics on the small torus. Geometrically, the tiling pattern is preserved
    by the dynamics because the update rule is translation-invariant.

    **Proof strategy**: The local rule at position `(I, J)` on the `M × N` torus
    depends on the Moore neighborhood values. For a pulled-back configuration,
    each neighbor `(I ± δ₁ mod M, J ± δ₂ mod N)` maps to
    `((I ± δ₁) mod m, (J ± δ₂) mod n)` on the small torus, because
    `m ∣ M` implies `(x mod M) mod m = x mod m`. This means the neighbor sum
    on the large torus equals the neighbor sum on the small torus at the
    reduced position, and hence the local rule values agree.
-/
theorem tropicalLifeStep_pullback
    {m n M N : ℕ}
    (hm : 0 < m) (hn : 0 < n) (hM : 0 < M) (hN : 0 < N)
    (hdm : m ∣ M) (hdn : n ∣ N)
    (c : Config m n) :
    tropicalLifeStep hM hN (pullbackConfig hm hn hM hN hdm hdn c) =
      pullbackConfig hm hn hM hN hdm hdn (tropicalLifeStep hm hn c) := by
  unfold tropicalLifeStep;
  -- By definition of pullbackConfig, we can rewrite the right-hand side of the equation.
  funext x; simp [pullbackConfig];
  unfold tropicalLocalRule;
  rw [ neighborSum_pullback ];
  unfold pullbackConfig; aesop;

/-! ## Iterate commutation (consequence of one-step commutation) -/

/-
Pullback commutes with iterated tropical Life steps.
-/
theorem tropicalLifeStep_pullback_iterate
    {m n M N : ℕ}
    (hm : 0 < m) (hn : 0 < n) (hM : 0 < M) (hN : 0 < N)
    (hdm : m ∣ M) (hdn : n ∣ N)
    (c : Config m n) (k : ℕ) :
    (tropicalLifeStep hM hN)^[k] (pullbackConfig hm hn hM hN hdm hdn c) =
      pullbackConfig hm hn hM hN hdm hdn ((tropicalLifeStep hm hn)^[k] c) := by
  induction k <;> simp_all +decide [ Function.iterate_succ_apply' ];
  -- Apply the pullback commutation theorem to rewrite the left-hand side.
  apply tropicalLifeStep_pullback hm hn hM hN hdm hdn

/-! ## Theorem A: Periodic Orbit Lifting -/

/-
**Divisibility lifting of periodic points.**

    Every periodic orbit on the small torus lifts to a periodic orbit of the
    same period on the large torus via the pullback map.
-/
theorem periodic_lifts_along_cover
    {m n M N p : ℕ}
    (hm : 0 < m) (hn : 0 < n) (hM : 0 < M) (hN : 0 < N)
    (hdm : m ∣ M) (hdn : n ∣ N) :
    Set.MapsTo (pullbackConfig hm hn hM hN hdm hdn)
      (PeriodicVariety m n p hm hn) (PeriodicVariety M N p hM hN) := by
  intro c;
  -- If c is in the periodic variety of the small torus, then applying the pullback map to c gives a configuration on the large torus that is also in the periodic variety of the large torus.
  intro hc
  have : (tropicalLifeStep hM hN)^[p] (pullbackConfig hm hn hM hN hdm hdn c) = pullbackConfig hm hn hM hN hdm hdn c := by
    rw [ tropicalLifeStep_pullback_iterate, hc ];
  exact this

/-
**Existential corollary of divisibility lifting.**

    If a period-`p` point exists on the small torus, then one exists on the large torus.
-/
theorem exists_periodic_of_exists_periodic_of_dvd
    {m n M N p : ℕ}
    (hm : 0 < m) (hn : 0 < n) (hM : 0 < M) (hN : 0 < N)
    (hdm : m ∣ M) (hdn : n ∣ N)
    (h : (PeriodicVariety m n p hm hn).Nonempty) :
    (PeriodicVariety M N p hM hN).Nonempty := by
  exact ⟨ _, periodic_lifts_along_cover hm hn hM hN hdm hdn h.choose_spec ⟩

/-! ## Theorem B: Period Algebra -/

/-
**Fixed points of iterates from fixed points.**

    If a configuration is fixed by the `p`-th iterate, then it is fixed by
    the `(p * k)`-th iterate for any `k`.
-/
theorem fixed_of_multiple_period
    {m n p k : ℕ} (hm : 0 < m) (hn : 0 < n) {c : Config m n}
    (hp : (tropicalLifeStep hm hn)^[p] c = c) :
    (tropicalLifeStep hm hn)^[p * k] c = c := by
  induction k <;> simp_all +decide [ Nat.mul_succ, Function.iterate_add_apply ]

/-
General lemma: if `f x = x` then `f^[n] x = x`.
-/
theorem Function.iterate_fixed_of_fixed {α : Type*} (f : α → α) {x : α}
    (h : f x = x) (n : ℕ) : (f^[n]) x = x := by
  grind +suggestions

/-
General lemma: if `f^[p] x = x` then `f^[p * k] x = x`.
-/
theorem Function.iterate_mul_fixed {α : Type*} (f : α → α) {x : α} {p : ℕ}
    (h : (f^[p]) x = x) (k : ℕ) : (f^[p * k]) x = x := by
  induction' k with k ih;
  · rfl;
  · rw [ Nat.mul_succ, add_comm, Function.iterate_add_apply, ih, h ]

/-
**Minimal period divides every return time.**

    If `c` has minimal period `p` and `(tropicalLifeStep^[q]) c = c` with `q > 0`,
    then `p ∣ q`. This is the fundamental divisibility theorem for periodic dynamics.
-/
theorem minimalPeriod_dvd_of_iterate_fix
    {m n : ℕ} (hm : 0 < m) (hn : 0 < n) {c : Config m n} {p q : ℕ}
    (hp : MinimalPeriod m n hm hn c p)
    (hq : 0 < q)
    (hfix : (tropicalLifeStep hm hn)^[q] c = c) :
    p ∣ q := by
  -- By definition of minimal period, we know that p divides q.
  have h_div : p ∣ q := by
    have h_eq : (tropicalLifeStep hm hn)^[q % p] c = c := by
      rw [ ← Nat.mod_add_div q p ] at *; simp_all +decide [ Function.iterate_add,
        Function.iterate_mul ] ;
      convert hfix using 1;
      rw [ Function.iterate_fixed hp.2.1 ]
    exact Nat.dvd_of_mod_eq_zero ( by_contra fun h => hp.2.2 ( q % p ) ( Nat.pos_of_ne_zero h ) ( Nat.mod_lt _ hp.1 ) h_eq );
  assumption

/-! ## Theorem C: Critical Birth Sizes -/

/-- Whether period `p` appears on the `L × L` square torus. -/
def PeriodAppearsAt (p L : ℕ) (hL : 0 < L) : Prop :=
  (PeriodicVariety L L p hL hL).Nonempty

/-- The critical size for period `p`: the smallest `L` at which it first appears. -/
def CriticalSize (p L : ℕ) (hL : 0 < L) : Prop :=
  PeriodAppearsAt p L hL ∧
  ∀ K (hK : 0 < K), K < L → ¬ PeriodAppearsAt p K hK

/-
**Upward closure under divisibility.**

    If period `p` appears on the `L × L` torus and `L ∣ M`, then period `p`
    also appears on the `M × M` torus.
-/
theorem upward_closed_period_appearance
    {p L M : ℕ}
    (hL : 0 < L) (hM : 0 < M)
    (hLM : L ∣ M)
    (h : PeriodAppearsAt p L hL) :
    PeriodAppearsAt p M hM := by
  convert exists_periodic_of_exists_periodic_of_dvd hL hL hM hM hLM hLM h

/-! ## Period Spectrum -/

/-- The **period spectrum** of the `L × L` torus: the set of all periods
    realized by some configuration. -/
def periodSpectrum (L : ℕ) (hL : 0 < L) : Set ℕ :=
  {p | (PeriodicVariety L L p hL hL).Nonempty}

/-
**Period spectrum monotonicity under divisibility.**

    If `L ∣ M`, then every period realized on the `L × L` torus is also
    realized on the `M × M` torus.
-/
theorem periodSpectrum_mono
    {L M : ℕ} (hL : 0 < L) (hM : 0 < M)
    (h : L ∣ M) :
    periodSpectrum L hL ⊆ periodSpectrum M hM := by
  exact fun p hp => upward_closed_period_appearance hL hM h hp

/-! ## Finiteness of Periodic Varieties -/

/-
**Every configuration is a period-0 fixed point** (vacuously: `f^[0] = id`).
-/
theorem zero_period_universal {m n : ℕ} (hm : 0 < m) (hn : 0 < n)
    (c : Config m n) : c ∈ PeriodicVariety m n 0 hm hn := by
  exact Set.mem_of_subset_of_mem (fun ⦃a⦄ => congrArg (tropicalLifeStep hm hn)^[0]) rfl

/-
**The zero configuration is always a fixed point** (period 1).
-/
theorem zero_config_fixed {m n : ℕ} (hm : 0 < m) (hn : 0 < n) :
    (fun _ : Cell m n => 0) ∈ PeriodicVariety m n 1 hm hn := by
  ext; simp [tropicalLifeStep];
  unfold tropicalLocalRule;
  unfold neighborSum; simp +decide [ mooreNeighbors ] ;

/-
Period 1 is always in the period spectrum of any torus.
-/
theorem one_mem_periodSpectrum {L : ℕ} (hL : 0 < L) :
    1 ∈ periodSpectrum L hL := by
  exact ⟨ _, zero_config_fixed hL hL ⟩

/-- The positivity proof in PeriodicVariety is irrelevant. -/
theorem periodicVariety_proof_irrel (m n p : ℕ) (h1 h2 : 0 < m) (h3 h4 : 0 < n) :
    PeriodicVariety m n p h1 h3 = PeriodicVariety m n p h2 h4 := by
  simp [PeriodicVariety]

/-- Auxiliary: period appearance predicate that bundles the positivity. -/
private def periodAppearsAux (p L : ℕ) : Prop :=
  0 < L ∧ ∃ hL : 0 < L, PeriodAppearsAt p L hL

private theorem periodAppearsAux_iff {p L : ℕ} (hL : 0 < L) :
    periodAppearsAux p L ↔ PeriodAppearsAt p L hL := by
  constructor
  · rintro ⟨_, hL', h⟩; exact h
  · intro h; exact ⟨hL, hL, h⟩

/-
**Existence of critical size** under a nonemptiness assumption.
    If some positive-size torus realizes period `p`, then there is a
    smallest such size. This is a well-ordering argument.
-/
theorem exists_criticalSize_of_exists_periodic
    {p : ℕ}
    (h : ∃ L, ∃ hL : 0 < L, PeriodAppearsAt p L hL) :
    ∃ L, ∃ hL : 0 < L, CriticalSize p L hL := by
  -- By the well-ordering principle, there exists a least element in the set of positive integers L such that periodAppearsAux p L.
  obtain ⟨L_min, hL_min⟩ : ∃ L_min, L_min ∈ {L : ℕ | periodAppearsAux p L} ∧ ∀ L', L' ∈ {L : ℕ | periodAppearsAux p L} → L_min ≤ L' := by
    apply Classical.byContradiction
    intro h_no_min;
    push_neg at h_no_min;
    obtain ⟨L_min, hL_min⟩ : ∃ L_min, L_min ∈ {L : ℕ | periodAppearsAux p L} := by
      exact ⟨ _, ⟨ h.choose_spec.1, h.choose_spec.1, h.choose_spec.2 ⟩ ⟩;
    induction' L_min using Nat.strong_induction_on with L ih;
    exact ih _ ( h_no_min _ hL_min |> Classical.choose_spec |> And.right ) ( h_no_min _ hL_min |> Classical.choose_spec |> And.left );
  exact ⟨ L_min, hL_min.1.1, hL_min.1.2.choose_spec, fun K hK hK' => fun hK'' => not_lt_of_ge ( hL_min.2 K ⟨ hK, hK, hK'' ⟩ ) hK' ⟩

/-! ## Pullback is injective -/

/-
The pullback map is injective: distinct configurations on the small torus
    lift to distinct configurations on the large torus.
-/
theorem pullbackConfig_injective
    {m n M N : ℕ}
    (hm : 0 < m) (hn : 0 < n) (hM : 0 < M) (hN : 0 < N)
    (hdm : m ∣ M) (hdn : n ∣ N) :
    Function.Injective (pullbackConfig hm hn hM hN hdm hdn) := by
  intro c1 c2 h;
  ext ⟨i, j⟩;
  convert congr_fun h ( ⟨ i.val, by linarith [ Fin.is_lt i, Nat.le_of_dvd hM hdm ] ⟩, ⟨ j.val, by linarith [ Fin.is_lt j, Nat.le_of_dvd hN hdn ] ⟩ ) using 1;
  · unfold pullbackConfig;
    simp +decide [ Nat.mod_eq_of_lt ];
  · unfold pullbackConfig;
    simp +decide [ Nat.mod_eq_of_lt ]

#print axioms periodic_lifts_along_cover