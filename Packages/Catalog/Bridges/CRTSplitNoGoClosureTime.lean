import Bridges.CRTSplitNoGoMinimality

/-!
# The CRT-Split No-Go, Part IV: the reveal time *is* the first one-sided closure time

Parts I–III established that a reveal is an exclusive cycle closure of the reduced dynamics.
Here we turn that into an exact identity for the *time* at which an `N`-explicit iteration can
first exhibit a factor.

For an integer polynomial `f`, a seed `x₀` and a modulus `m`, let `firstClosureTime f m x₀` be
the least `t` for which the reduced orbit revisits an earlier value.  Then:

* `firstClosureTime_le`: it is at most `m` (pigeonhole) — the only unconditional bound;
* `no_reveal_before_min_closure`: nothing is revealed before
  `min (firstClosureTime f p x₀) (firstClosureTime f q x₀)`;
* `reveal_at_min_closure`: as soon as the two closure times differ, a factor *is* revealed at
  that minimum.

Hence for `N`-explicit iterations the reveal time equals `min(T_p, T_q)` (whenever the two
differ), a quantity determined entirely by the reduced dynamics mod `p` and mod `q`.  Both
ends of the range are realised:

* generic nonlinear maps sit at the birthday scale `T_p ≈ √p` (verified CTST demo, Part III);
* the structurally simple successor map sits at the extreme `T_p = p` exactly
  (`successor_firstClosureTime`).

In neither case — nor anywhere in between — is `min(T_p, T_q)` polynomial in `log N`, since it
is bounded below by the corresponding orbit statistics of a modulus of size `≈ √N`.
-/

namespace CRTSplitNoGo

open Polynomial
open scoped Classical

/-- The reduced orbit revisits, at time `t`, a value it had at some earlier time. -/
def ClosureAt (f : ℤ[X]) (m : ℕ) (x0 : ℤ) (t : ℕ) : Prop :=
  ∃ s, s < t ∧ modOrbit f m x0 t = modOrbit f m x0 s

lemma exists_closureAt (f : ℤ[X]) (m : ℕ) [NeZero m] (x0 : ℤ) : ∃ t, ClosureAt f m x0 t := by
  obtain ⟨s, t, hst, -, h⟩ := exists_closure_le f m x0
  exact ⟨t, s, hst, h⟩

/-- The first time the reduced orbit closes up. -/
noncomputable def firstClosureTime (f : ℤ[X]) (m : ℕ) [NeZero m] (x0 : ℤ) : ℕ :=
  Nat.find (exists_closureAt f m x0)

lemma closureAt_firstClosureTime (f : ℤ[X]) (m : ℕ) [NeZero m] (x0 : ℤ) :
    ClosureAt f m x0 (firstClosureTime f m x0) :=
  Nat.find_spec (exists_closureAt f m x0)

lemma not_closureAt_of_lt {f : ℤ[X]} {m : ℕ} [NeZero m] {x0 : ℤ} {t : ℕ}
    (h : t < firstClosureTime f m x0) : ¬ ClosureAt f m x0 t :=
  Nat.find_min (exists_closureAt f m x0) h

/-- Pigeonhole bound: the reduced orbit closes within `m` steps. -/
theorem firstClosureTime_le (f : ℤ[X]) (m : ℕ) [NeZero m] (x0 : ℤ) :
    firstClosureTime f m x0 ≤ m := by
  obtain ⟨s, t, hst, htm, h⟩ := exists_closure_le f m x0
  exact le_trans (Nat.find_le ⟨s, hst, h⟩) htm

/-- **No reveal before the first one-sided closure.** -/
theorem no_reveal_before_min_closure {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (f : ℤ[X]) (x0 : ℤ) :
    haveI : NeZero p := ⟨hp.pos.ne'⟩
    haveI : NeZero q := ⟨hq.pos.ne'⟩
    ∀ s t : ℕ, s < t → t < min (firstClosureTime f p x0) (firstClosureTime f q x0) →
      ¬ RevealsFactor (p * q) (polyOrbit f x0 t - polyOrbit f x0 s) := by
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero q := ⟨hq.pos.ne'⟩
  intro s t hst hlt hrev
  rcases (reveal_iff_xor_closure hp hq hne f x0 s t).mp hrev with ⟨h, -⟩ | ⟨h, -⟩
  · exact not_closureAt_of_lt (lt_of_lt_of_le hlt (min_le_left _ _)) ⟨s, hst, h⟩
  · exact not_closureAt_of_lt (lt_of_lt_of_le hlt (min_le_right _ _)) ⟨s, hst, h⟩

/-- Auxiliary, one-sided version: if the mod-`p` orbit closes strictly before the mod-`q`
orbit does, a factor is revealed exactly at the mod-`p` closure. -/
lemma reveal_at_closure_of_lt {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (f : ℤ[X]) (x0 : ℤ) :
    haveI : NeZero p := ⟨hp.pos.ne'⟩
    haveI : NeZero q := ⟨hq.pos.ne'⟩
    firstClosureTime f p x0 < firstClosureTime f q x0 →
      ∃ s, s < firstClosureTime f p x0 ∧
        RevealsFactor (p * q)
          (polyOrbit f x0 (firstClosureTime f p x0) - polyOrbit f x0 s) := by
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero q := ⟨hq.pos.ne'⟩
  intro hlt
  obtain ⟨s, hs, hclos⟩ := closureAt_firstClosureTime f p x0
  refine ⟨s, hs, ?_⟩
  refine (reveal_iff_xor_closure hp hq hne f x0 s _).mpr (Or.inl ⟨hclos, ?_⟩)
  intro hq'
  exact not_closureAt_of_lt hlt ⟨s, hs, hq'⟩

/-- **The reveal time is the first one-sided closure time.**  Whenever the two reduced orbits
close at different times, a nontrivial factor of `N = p q` is revealed exactly at the earlier
of the two closure times, and never before it. -/
theorem reveal_at_min_closure {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (f : ℤ[X]) (x0 : ℤ) :
    haveI : NeZero p := ⟨hp.pos.ne'⟩
    haveI : NeZero q := ⟨hq.pos.ne'⟩
    firstClosureTime f p x0 ≠ firstClosureTime f q x0 →
      ∃ s, s < min (firstClosureTime f p x0) (firstClosureTime f q x0) ∧
        RevealsFactor (p * q)
          (polyOrbit f x0 (min (firstClosureTime f p x0) (firstClosureTime f q x0))
            - polyOrbit f x0 s) := by
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero q := ⟨hq.pos.ne'⟩
  intro hne'
  rcases lt_or_gt_of_ne hne' with h | h
  · rw [min_eq_left (le_of_lt h)]
    exact reveal_at_closure_of_lt hp hq hne f x0 h
  · rw [min_eq_right (le_of_lt h)]
    obtain ⟨s, hs, hrev⟩ := reveal_at_closure_of_lt hq hp (Ne.symm hne) f x0 h
    exact ⟨s, hs, by rwa [Nat.mul_comm] at hrev⟩

/-! ## The two extremes of the closure time -/

lemma modOrbit_successor (m : ℕ) (x0 : ℤ) (n : ℕ) :
    modOrbit (X + 1) m x0 n = ((x0 + n : ℤ) : ZMod m) := by
  rw [← polyOrbit_cast, polyOrbit_successor]

lemma closureAt_successor_iff {m : ℕ} (x0 : ℤ) (t : ℕ) :
    ClosureAt (X + 1) m x0 t ↔ ∃ s, s < t ∧ (m : ℤ) ∣ ((t : ℤ) - s) := by
  constructor
  · rintro ⟨s, hs, h⟩
    refine ⟨s, hs, ?_⟩
    rw [modOrbit_successor, modOrbit_successor] at h
    have := (intCast_sub_eq_zero_iff m (x0 + t) (x0 + s)).mp h
    simpa using (by simpa using this : (m : ℤ) ∣ (x0 + t) - (x0 + s))
  · rintro ⟨s, hs, h⟩
    refine ⟨s, hs, ?_⟩
    rw [modOrbit_successor, modOrbit_successor]
    refine (intCast_sub_eq_zero_iff m (x0 + t) (x0 + s)).mpr ?_
    simpa using h

/-- **Extreme case (regime (c)).**  For the successor map the first closure time is exactly the
modulus: `m` steps, the worst possible value allowed by the pigeonhole bound.  For a semiprime
`N = p q` this is `min p q ≈ √N`: maximally far from `poly(log N)`. -/
theorem successor_firstClosureTime (m : ℕ) [NeZero m] (x0 : ℤ) :
    firstClosureTime (X + 1) m x0 = m := by
  have hm : 0 < m := Nat.pos_of_ne_zero (NeZero.ne m)
  refine le_antisymm (firstClosureTime_le _ _ _) ?_
  by_contra hcon
  push_neg at hcon
  have hclos := closureAt_firstClosureTime (X + 1) m x0
  rw [closureAt_successor_iff] at hclos
  obtain ⟨s, hs, hdvd⟩ := hclos
  set t := firstClosureTime (X + 1) m x0 with ht
  have h1 : (0 : ℤ) < (t : ℤ) - s := by
    have : (s : ℤ) < t := by exact_mod_cast hs
    linarith
  have h2 : (m : ℤ) ≤ (t : ℤ) - s := Int.le_of_dvd h1 hdvd
  have h3 : (t : ℤ) < m := by exact_mod_cast hcon
  have h4 : (0 : ℤ) ≤ (s : ℤ) := Int.natCast_nonneg s
  linarith

end CRTSplitNoGo