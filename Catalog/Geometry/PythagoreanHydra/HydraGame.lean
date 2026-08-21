import Mathlib

/-!
# The abstract hydra game underlying the Pythagorean Hydra

A *hydra* is a finite multiset of heads, each head carrying a natural number *level*.
Hercules chops one head; the hydra regrows an arbitrary finite multiset of new heads,
each of *strictly smaller* level.  In the Pythagorean Hydra of
`Catalog/Geometry/PythagoreanHydra/PythagoreanHydra.lean` the heads are primitive
Pythagorean triples and the regrown heads are Berggren ancestors of the chopped one, so
the level of a head is (a monotone function of) its position in the Berggren tree.

Two regimes are analysed here.

* **Bounded branching** (`HydraStep k`): at most `k` heads regrow.  The potential
  `Phi k H = ∑_{x ∈ H} (1 + k + ⋯ + k^x)` drops by *at least one* at every move
  (`hydraStep_Phi_succ_le`), and there is a strategy realising a drop of *exactly*
  one at every move (`exists_maximal_play`).  Hence the length of the longest play is
  **exactly** `Phi k H` (`longest_play_eq`), an explicit elementary function of the
  initial hydra: `Phi k H ≤ card H * (k+1)^(maxlevel+1)`.  This is the *calibration*
  result: the game is `ω^ω`-style, provably terminating by an explicit primitive
  recursive bound, and therefore has none of the proof-theoretic strength of the
  Kirby–Paris hydra (whose length function majorises every provably total function
  of Peano Arithmetic).

* **Unbounded branching** (`HydraStepU`): arbitrarily many heads may regrow.  Every
  play still terminates (`no_infinite_playU`, via the Dershowitz–Manna order), but the
  length is no longer bounded by any function of the initial hydra alone
  (`unbounded_play_length`), so the game's ordinal is genuinely `> ω`.
-/

namespace PythHydra

open Multiset

/-! ### The potential function -/

/-- `phi k n = 1 + k + k² + ⋯ + kⁿ`, the potential of a single head of level `n`
in a hydra with branching bound `k`. -/
def phi (k n : ℕ) : ℕ := ∑ i ∈ Finset.range (n + 1), k ^ i

@[simp] theorem phi_zero (k : ℕ) : phi k 0 = 1 := by simp [phi]

theorem phi_succ (k n : ℕ) : phi k (n + 1) = 1 + k * phi k n := by
  simp only [phi]
  rw [Finset.sum_range_succ' (fun i => k ^ i) (n + 1), Finset.mul_sum]
  simp [pow_succ, mul_comm, add_comm]

theorem phi_pos (k n : ℕ) : 0 < phi k n := by
  induction n with
  | zero => simp
  | succ m ih => rw [phi_succ]; omega

theorem phi_mono (k : ℕ) {m n : ℕ} (h : m ≤ n) : phi k m ≤ phi k n := by
  have hsub : Finset.range (m + 1) ⊆ Finset.range (n + 1) := by
    intro x hx
    simp only [Finset.mem_range] at hx ⊢
    omega
  exact Finset.sum_le_sum_of_subset hsub

/-- The potential is bounded by an explicit exponential: the hydra game with branching
bound `k` is an *elementary* game. -/
theorem phi_le_pow (k n : ℕ) : phi k n ≤ (k + 1) ^ (n + 1) := by
  induction n with
  | zero => simp
  | succ m ih =>
    rw [phi_succ]
    calc 1 + k * phi k m ≤ 1 + k * (k + 1) ^ (m + 1) := by
          exact Nat.add_le_add_left (Nat.mul_le_mul_left k ih) 1
      _ ≤ (k + 1) ^ (m + 2) := by
          have h1 : (1 : ℕ) ≤ (k + 1) ^ (m + 1) := Nat.one_le_pow _ _ (by omega)
          have : (k + 1) ^ (m + 2) = k * (k + 1) ^ (m + 1) + (k + 1) ^ (m + 1) := by
            ring
          omega

/-- The potential of a whole hydra. -/
def Phi (k : ℕ) (H : Multiset ℕ) : ℕ := (H.map (phi k)).sum

@[simp] theorem Phi_zero (k : ℕ) : Phi k 0 = 0 := rfl

@[simp] theorem Phi_cons (k m : ℕ) (H : Multiset ℕ) :
    Phi k (m ::ₘ H) = phi k m + Phi k H := by simp [Phi]

@[simp] theorem Phi_add (k : ℕ) (H H' : Multiset ℕ) :
    Phi k (H + H') = Phi k H + Phi k H' := by simp [Phi]

theorem Phi_replicate (k n m : ℕ) : Phi k (Multiset.replicate n m) = n * phi k m := by
  induction n with
  | zero => simp
  | succ p ih => rw [Multiset.replicate_succ, Phi_cons, ih]; ring

/-- If every head of `H` has level at most `m` then `Phi k H ≤ card H * phi k m`. -/
theorem Phi_le_of_forall_le {k m : ℕ} {H : Multiset ℕ} (h : ∀ x ∈ H, x ≤ m) :
    Phi k H ≤ Multiset.card H * phi k m := by
  have : ∀ y ∈ H.map (phi k), y ≤ phi k m := by
    intro y hy
    obtain ⟨x, hx, rfl⟩ := Multiset.mem_map.mp hy
    exact phi_mono k (h x hx)
  have hsum := Multiset.sum_le_card_nsmul _ _ this
  simpa [Phi, smul_eq_mul] using hsum

/-! ### The game with bounded branching -/

/-- One move of the hydra game with branching bound `k`: a head of level `m` is chopped
and at most `k` heads of strictly smaller level regrow. -/
inductive HydraStep (k : ℕ) : Multiset ℕ → Multiset ℕ → Prop
  | chop (m : ℕ) (H R : Multiset ℕ) (hlt : ∀ x ∈ R, x < m) (hcard : Multiset.card R ≤ k) :
      HydraStep k (m ::ₘ H) (R + H)

/-- **Each move strictly decreases the potential**, by at least one. -/
theorem hydraStep_Phi_succ_le {k : ℕ} {H H' : Multiset ℕ} (h : HydraStep k H H') :
    Phi k H' + 1 ≤ Phi k H := by
  obtain ⟨m, H₀, R, hlt, hcard⟩ := h
  rw [Phi_cons, Phi_add]
  have key : Phi k R + 1 ≤ phi k m := by
    rcases Nat.eq_zero_or_pos m with hm | hm
    · -- level `0`: nothing can regrow
      have hR : R = 0 := by
        rw [Multiset.eq_zero_iff_forall_notMem]
        intro x hx
        have := hlt x hx
        omega
      simp [hR, hm]
    · obtain ⟨m', rfl⟩ : ∃ m', m = m' + 1 := ⟨m - 1, by omega⟩
      have hle : ∀ x ∈ R, x ≤ m' := fun x hx => by have := hlt x hx; omega
      have h1 : Phi k R ≤ Multiset.card R * phi k m' := Phi_le_of_forall_le hle
      have h2 : Multiset.card R * phi k m' ≤ k * phi k m' :=
        Nat.mul_le_mul_right _ hcard
      rw [phi_succ]
      omega
  omega

/-- `StepsTo k N H H'` : there is a play of exactly `N` moves from `H` to `H'`. -/
def StepsTo (k : ℕ) : ℕ → Multiset ℕ → Multiset ℕ → Prop
  | 0, H, H' => H = H'
  | (n + 1), H, H' => ∃ M, HydraStep k H M ∧ StepsTo k n M H'

/-- The potential bounds the length of every play. -/
theorem stepsTo_Phi_le {k : ℕ} : ∀ (N : ℕ) (H H' : Multiset ℕ),
    StepsTo k N H H' → N + Phi k H' ≤ Phi k H := by
  intro N
  induction N with
  | zero => intro H H' h; subst h; simp
  | succ n ih =>
    rintro H H' ⟨M, hstep, hrest⟩
    have h1 := ih M H' hrest
    have h2 := hydraStep_Phi_succ_le hstep
    omega

/-- **Upper bound**: no play from `H` lasts longer than `Phi k H` moves. -/
theorem play_length_le {k N : ℕ} {H H' : Multiset ℕ} (h : StepsTo k N H H') :
    N ≤ Phi k H := by
  have := stepsTo_Phi_le N H H' h
  omega

/-- Plays can be extended by one move at the end. -/
theorem stepsTo_snoc {k : ℕ} : ∀ (n : ℕ) (H M M' : Multiset ℕ),
    StepsTo k n H M → HydraStep k M M' → StepsTo k (n + 1) H M' := by
  intro n
  induction n with
  | zero => intro H M M' h hs; subst h; exact ⟨M', hs, rfl⟩
  | succ p ih =>
    rintro H M M' ⟨X, hstep, hrest⟩ hs
    exact ⟨X, hstep, ih X M M' hrest hs⟩

/-- **Termination of the bounded Pythagorean Hydra game**: there is no infinite play. -/
theorem no_infinite_play (k : ℕ) (f : ℕ → Multiset ℕ) (hf : ∀ i, HydraStep k (f i) (f (i + 1))) :
    False := by
  have hsteps : ∀ n, StepsTo k n (f 0) (f n) := by
    intro n
    induction n with
    | zero => rfl
    | succ m ih => exact stepsTo_snoc m (f 0) (f m) (f (m + 1)) ih (hf m)
  have := play_length_le (hsteps (Phi k (f 0) + 1))
  omega

/-! ### The bound is sharp -/

/-- From any non-empty hydra there is a move dropping the potential by *exactly* one. -/
theorem exists_step_Phi_pred {k : ℕ} {H : Multiset ℕ} (hH : H ≠ 0) :
    ∃ H', HydraStep k H H' ∧ Phi k H' + 1 = Phi k H := by
  obtain ⟨m, hmem⟩ := Multiset.exists_mem_of_ne_zero hH
  obtain ⟨H₀, rfl⟩ := Multiset.exists_cons_of_mem hmem
  rcases Nat.eq_zero_or_pos m with rfl | hm
  · refine ⟨H₀, ?_, ?_⟩
    · have h0 : HydraStep k (0 ::ₘ H₀) (0 + H₀) := HydraStep.chop 0 H₀ 0 (by simp) (by simp)
      simpa using h0
    · simp only [Phi_cons, phi_zero]
      omega
  · obtain ⟨m', rfl⟩ : ∃ m', m = m' + 1 := ⟨m - 1, by omega⟩
    refine ⟨Multiset.replicate k m' + H₀, HydraStep.chop _ _ _ ?_ ?_, ?_⟩
    · intro x hx
      have := Multiset.eq_of_mem_replicate hx
      omega
    · simp
    · rw [Phi_add, Phi_cons, Phi_replicate, phi_succ]
      ring

/-- **Attainment**: every hydra admits a play of length exactly `Phi k H` that kills it. -/
theorem exists_maximal_play (k : ℕ) : ∀ (H : Multiset ℕ), StepsTo k (Phi k H) H 0 := by
  intro H
  generalize hn : Phi k H = n
  induction n using Nat.strong_induction_on generalizing H with
  | _ n ih =>
    rcases eq_or_ne H 0 with rfl | hH
    · simp only [Phi_zero] at hn
      subst hn
      exact rfl
    · obtain ⟨H', hstep, hPhi⟩ := exists_step_Phi_pred (k := k) hH
      obtain ⟨p, rfl⟩ : ∃ p, n = p + 1 := ⟨Phi k H', by omega⟩
      exact ⟨H', hstep, ih p (by omega) H' (by omega)⟩

/-- **Sharp calibration of the bounded hydra game.**  The longest play from `H` has exactly
`Phi k H` moves: the bound is attained, and no play exceeds it. -/
theorem longest_play_eq (k : ℕ) (H : Multiset ℕ) :
    StepsTo k (Phi k H) H 0 ∧ ∀ (N : ℕ) (H' : Multiset ℕ), StepsTo k N H H' → N ≤ Phi k H :=
  ⟨exists_maximal_play k H, fun _ _ h => play_length_le h⟩

/-- The game length is bounded by an explicit elementary function of the initial hydra:
if all heads have level at most `L` then every play has at most
`card H * (k+1)^(L+1)` moves. -/
theorem play_length_elementary_bound {k N L : ℕ} {H H' : Multiset ℕ}
    (hL : ∀ x ∈ H, x ≤ L) (h : StepsTo k N H H') :
    N ≤ Multiset.card H * (k + 1) ^ (L + 1) := by
  have h1 := play_length_le h
  have h2 : Phi k H ≤ Multiset.card H * phi k L := Phi_le_of_forall_le hL
  have h3 : phi k L ≤ (k + 1) ^ (L + 1) := phi_le_pow k L
  calc N ≤ Phi k H := h1
    _ ≤ Multiset.card H * phi k L := h2
    _ ≤ Multiset.card H * (k + 1) ^ (L + 1) := Nat.mul_le_mul_left _ h3

/-! ### The game with unbounded branching -/

/-- One move of the hydra game with *unbounded* regrowth. -/
inductive HydraStepU : Multiset ℕ → Multiset ℕ → Prop
  | chop (m : ℕ) (H R : Multiset ℕ) (hlt : ∀ x ∈ R, x < m) : HydraStepU (m ::ₘ H) (R + H)

theorem hydraStepU_isDershowitzMannaLT {H H' : Multiset ℕ} (h : HydraStepU H H') :
    Multiset.IsDershowitzMannaLT H' H := by
  obtain ⟨m, H₀, R, hlt⟩ := h
  refine ⟨H₀, R, {m}, by simp, by rw [add_comm], by rw [add_comm, Multiset.singleton_add], ?_⟩
  intro y hy
  exact ⟨m, by simp, hlt y hy⟩

/-- **Termination in full generality**: even with unbounded regrowth, every play of the
Pythagorean Hydra is finite.  (Dershowitz–Manna: the order type is `ω^ω`.) -/
theorem no_infinite_playU (f : ℕ → Multiset ℕ) (hf : ∀ i, HydraStepU (f i) (f (i + 1))) :
    False := by
  have wf : WellFounded (Multiset.IsDershowitzMannaLT : Multiset ℕ → Multiset ℕ → Prop) :=
    Multiset.wellFounded_isDershowitzMannaLT
  obtain ⟨a, ⟨i, rfl⟩, hmin⟩ := wf.has_min (Set.range f) ⟨f 0, ⟨0, rfl⟩⟩
  exact hmin (f (i + 1)) ⟨i + 1, rfl⟩ (hydraStepU_isDershowitzMannaLT (hf i))

/-- Plays in the unbounded game. -/
def StepsToU : ℕ → Multiset ℕ → Multiset ℕ → Prop
  | 0, H, H' => H = H'
  | (n + 1), H, H' => ∃ M, HydraStepU H M ∧ StepsToU n M H'

theorem stepsToU_replicate_zero : ∀ n : ℕ, StepsToU n (Multiset.replicate n 0) 0 := by
  intro n
  induction n with
  | zero => rfl
  | succ m ih =>
    refine ⟨Multiset.replicate m 0, ?_, ih⟩
    rw [Multiset.replicate_succ]
    have : Multiset.replicate m 0 = (0 : Multiset ℕ) + Multiset.replicate m 0 := by simp
    rw [this]
    exact HydraStepU.chop 0 (Multiset.replicate m 0) 0 (by simp)

/-- **No uniform bound**: with unbounded regrowth the single head `{1}` admits plays of
arbitrary length, so the length of the game is not a function of the initial hydra.  The
game's ordinal is therefore strictly larger than `ω`, while `no_infinite_playU` keeps it
at `ω^ω`. -/
theorem unbounded_play_length (N : ℕ) : StepsToU (N + 1) {1} 0 := by
  refine ⟨Multiset.replicate N 0, ?_, stepsToU_replicate_zero N⟩
  have h1 : ({1} : Multiset ℕ) = (1 : ℕ) ::ₘ 0 := rfl
  have h2 : Multiset.replicate N 0 = Multiset.replicate N 0 + (0 : Multiset ℕ) := by simp
  rw [h1, h2]
  exact HydraStepU.chop 1 0 (Multiset.replicate N 0)
    (by intro x hx; have := Multiset.eq_of_mem_replicate hx; omega)

end PythHydra