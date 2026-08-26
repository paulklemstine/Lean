import Cryptography.BerggrenModular.LocalSeparation

/-!
# The reachable set lives on the punctured null cone, and the sharpened bound

Every Berggren move lies in `GL₃(ℤ)` and preserves the Lorentz form.  Hence the
whole Berggren tree consists of **primitive** null vectors, and its reduction
modulo a prime `p` lands in

```
Cone p = { w ∈ (ℤ/p)³ : w₁² + w₂² = w₃² } \ {0}.
```

Because a quadratic equation has at most two roots in a field, `|Cone p| ≤ 2p²`.
So the adversary's observation lives in a set of size `O(p²)`, not `p³`, and the
information-theoretic bounds of `Cryptography.BerggrenModular.Hardness` improve
by a whole factor of `p`.

## Main results

* `Prim_applyWord` — every state of the Berggren tree is a primitive triple.
* `stateMod_ne_zero` — modulo a prime the observed state is never `0`.
* `lorentzM_stateMod` — the observation always satisfies `a² + b² = c²` mod `m`.
* `card_nullCone_le` — the null cone modulo a prime has at most `2p²` points.
* `mod_ambiguity_lower_bound_of_subset` — the pigeonhole bound relative to any
  finite superset of the reachable states.
* `prime_ambiguity_lower_bound`, `not_modSeedRecoverable_of_card_prime` —
  the sharpened `Ω(3^k / 2p²)` ambiguity and the improved impossibility
  threshold `2p² < 3^k`.
-/

namespace Cryptography
namespace BerggrenModular

/-! ## Primitivity -/

/-- A triple is primitive when its three entries have no common non-unit divisor. -/
def Prim (v : Tri) : Prop := ∀ d : ℤ, d ∣ v.1 → d ∣ v.2.1 → d ∣ v.2.2 → IsUnit d

theorem Prim_root : Prim root := by
  intro d h1 h2 _
  have : d ∣ (1 : ℤ) := by
    have := dvd_sub h2 h1
    simpa [root] using this
  exact isUnit_of_dvd_one this

/-- Since each move is invertible over `ℤ`, primitivity is preserved. -/
theorem Prim_applyMove {i : Move} {v : Tri} (h : Prim v) : Prim (applyMove i v) := by
  intro d h1 h2 h3
  cases i
  · simp only [applyMove] at h1 h2 h3
    obtain ⟨x, hx⟩ := h1; obtain ⟨y, hy⟩ := h2; obtain ⟨z, hz⟩ := h3
    exact h d ⟨x + 2 * y - 2 * z, by linear_combination hx + 2 * hy - 2 * hz⟩
      ⟨-2 * x - y + 2 * z, by linear_combination -2 * hx - hy + 2 * hz⟩
      ⟨-2 * x - 2 * y + 3 * z, by linear_combination -2 * hx - 2 * hy + 3 * hz⟩
  · simp only [applyMove] at h1 h2 h3
    obtain ⟨x, hx⟩ := h1; obtain ⟨y, hy⟩ := h2; obtain ⟨z, hz⟩ := h3
    exact h d ⟨x + 2 * y - 2 * z, by linear_combination hx + 2 * hy - 2 * hz⟩
      ⟨2 * x + y - 2 * z, by linear_combination 2 * hx + hy - 2 * hz⟩
      ⟨-2 * x - 2 * y + 3 * z, by linear_combination -2 * hx - 2 * hy + 3 * hz⟩
  · simp only [applyMove] at h1 h2 h3
    obtain ⟨x, hx⟩ := h1; obtain ⟨y, hy⟩ := h2; obtain ⟨z, hz⟩ := h3
    exact h d ⟨-x - 2 * y + 2 * z, by linear_combination -hx - 2 * hy + 2 * hz⟩
      ⟨2 * x + y - 2 * z, by linear_combination 2 * hx + hy - 2 * hz⟩
      ⟨-2 * x - 2 * y + 3 * z, by linear_combination -2 * hx - 2 * hy + 3 * hz⟩

theorem Prim_applyWord (u : List Move) : Prim (applyWord u root) := by
  induction u with
  | nil => exact Prim_root
  | cons i rest ih => exact Prim_applyMove ih

/-! ## The observation lies on the punctured null cone -/

theorem lorentz_applyWord (u : List Move) : lorentz (applyWord u root) = 0 := by
  induction u with
  | nil => norm_num [lorentz, root]
  | cons i rest ih => rw [applyWord_cons, lorentz_applyMove]; exact ih

/-- The observed modular state always satisfies `a² + b² = c²`. -/
theorem lorentzM_stateMod (m : ℕ) (u : List Move) : lorentzM m (stateMod m u) = 0 := by
  have h := lorentz_applyWord u
  simp only [lorentzM, stateMod, redTri]
  have : ((lorentz (applyWord u root) : ℤ) : ZMod m) = 0 := by rw [h]; simp
  simpa [lorentz] using this

/-- Modulo a prime the observed state is never the zero vector. -/
theorem stateMod_ne_zero (p : ℕ) [hp : Fact (Nat.Prime p)] (u : List Move) :
    stateMod p u ≠ (0, 0, 0) := by
  intro hEq
  rw [stateMod, redTri, Prod.mk.injEq, Prod.mk.injEq] at hEq
  obtain ⟨h1, h2, h3⟩ := hEq
  have d1 : (p : ℤ) ∣ (applyWord u root).1 := by
    rwa [← ZMod.intCast_zmod_eq_zero_iff_dvd]
  have d2 : (p : ℤ) ∣ (applyWord u root).2.1 := by
    rwa [← ZMod.intCast_zmod_eq_zero_iff_dvd]
  have d3 : (p : ℤ) ∣ (applyWord u root).2.2 := by
    rwa [← ZMod.intCast_zmod_eq_zero_iff_dvd]
  have := Prim_applyWord u (p : ℤ) d1 d2 d3
  rw [Int.isUnit_iff] at this
  have h2' : 2 ≤ p := hp.out.two_le
  omega

/-! ## Counting the null cone modulo a prime -/

/-- The null cone modulo `m`, as a finite set of states. -/
def nullCone (m : ℕ) [NeZero m] : Finset (TriM m) :=
  Finset.univ.filter (fun w => lorentzM m w = 0)

theorem stateMod_mem_nullCone (m : ℕ) [NeZero m] (u : List Move) :
    stateMod m u ∈ nullCone m := by
  simp only [nullCone, Finset.mem_filter, Finset.mem_univ, true_and]
  exact lorentzM_stateMod m u

/-- **The null cone modulo a prime has at most `2p²` points.**  A quadratic equation
has at most two roots in a field, so the projection `(a,b,c) ↦ (a,b)` is at most
two-to-one on the cone. -/
theorem card_nullCone_le (p : ℕ) [Fact (Nat.Prime p)] :
    (nullCone p).card ≤ 2 * p ^ 2 := by
  classical
  have hmaps : ∀ w ∈ nullCone p, (w.1, w.2.1) ∈ (Finset.univ : Finset (ZMod p × ZMod p)) :=
    fun w _ => Finset.mem_univ _
  have hfib : ∀ q ∈ (Finset.univ : Finset (ZMod p × ZMod p)),
      ((nullCone p).filter (fun w => (w.1, w.2.1) = q)).card ≤ 2 := by
    intro q _
    rcases Finset.eq_empty_or_nonempty ((nullCone p).filter (fun w => (w.1, w.2.1) = q)) with
      he | ⟨w₀, hw₀⟩
    · simp [he]
    · have hsub : (nullCone p).filter (fun w => (w.1, w.2.1) = q) ⊆
          ({(q.1, q.2, w₀.2.2), (q.1, q.2, -w₀.2.2)} : Finset (TriM p)) := by
        intro w hw
        simp only [Finset.mem_filter, nullCone, Finset.mem_univ, true_and] at hw hw₀
        obtain ⟨hwc, hwq⟩ := hw
        obtain ⟨hw0c, hw0q⟩ := hw₀
        have hq1 : w.1 = q.1 := congrArg Prod.fst hwq
        have hq2 : w.2.1 = q.2 := congrArg Prod.snd hwq
        have hq1' : w₀.1 = q.1 := congrArg Prod.fst hw0q
        have hq2' : w₀.2.1 = q.2 := congrArg Prod.snd hw0q
        have hsq : w.2.2 ^ 2 = w₀.2.2 ^ 2 := by
          have e1 : w.1 ^ 2 + w.2.1 ^ 2 = w.2.2 ^ 2 := by
            have := hwc; simp only [lorentzM] at this; linear_combination this
          have e2 : w₀.1 ^ 2 + w₀.2.1 ^ 2 = w₀.2.2 ^ 2 := by
            have := hw0c; simp only [lorentzM] at this; linear_combination this
          rw [← e1, ← e2, hq1, hq2, hq1', hq2']
        have hroot : (w.2.2 - w₀.2.2) * (w.2.2 + w₀.2.2) = 0 := by linear_combination hsq
        rcases mul_eq_zero.1 hroot with h | h
        · have : w.2.2 = w₀.2.2 := by linear_combination h
          simp only [Finset.mem_insert, Finset.mem_singleton]
          left
          exact Prod.ext hq1 (Prod.ext hq2 this)
        · have : w.2.2 = -w₀.2.2 := by linear_combination h
          simp only [Finset.mem_insert, Finset.mem_singleton]
          right
          exact Prod.ext hq1 (Prod.ext hq2 this)
      exact le_trans (Finset.card_le_card hsub) (Finset.card_insert_le _ _ |>.trans (by simp))
  have := Finset.card_le_mul_card_image_of_maps_to hmaps 2 hfib
  calc (nullCone p).card ≤ 2 * (Finset.univ : Finset (ZMod p × ZMod p)).card := this
    _ = 2 * p ^ 2 := by
        rw [Finset.card_univ, Fintype.card_prod, ZMod.card]
        ring

/-! ## Sharpened ambiguity -/

/-- Pigeonhole relative to any finite superset of the reachable states. -/
theorem mod_ambiguity_lower_bound_of_subset {m k n : ℕ} [NeZero m] (S : Finset (TriM m))
    (hS : ∀ u : Fin k → Move, stateModF m k u ∈ S) (h : S.card * n < 3 ^ k) :
    ∃ s ∈ S, n < (Finset.univ.filter (fun u : Fin k → Move => stateModF m k u = s)).card := by
  have hmaps : ∀ u ∈ (Finset.univ : Finset (Fin k → Move)), stateModF m k u ∈ S :=
    fun u _ => hS u
  have hcard : S.card * n < (Finset.univ : Finset (Fin k → Move)).card := by
    rw [Finset.card_univ, card_words]; exact h
  exact Finset.exists_lt_card_fiber_of_mul_lt_card_of_maps_to hmaps hcard

/-- **Sharpened ambiguity for prime moduli**: the observation lies on a cone with
at most `2p²` points, so the ambiguity is `Ω(3^k / 2p²)`. -/
theorem prime_ambiguity_lower_bound (p k n : ℕ) [Fact (Nat.Prime p)] (h : 2 * p ^ 2 * n < 3 ^ k) :
    ∃ s ∈ nullCone p,
      n < (Finset.univ.filter (fun u : Fin k → Move => stateModF p k u = s)).card := by
  have hpos : 0 < p := Fact.out (p := Nat.Prime p) |>.pos
  haveI : NeZero p := ⟨hpos.ne'⟩
  refine mod_ambiguity_lower_bound_of_subset (nullCone p) (fun u => stateMod_mem_nullCone p _) ?_
  calc (nullCone p).card * n ≤ 2 * p ^ 2 * n :=
        Nat.mul_le_mul_right n (card_nullCone_le p)
    _ < 3 ^ k := h

/-- **Improved impossibility threshold**: modulo a prime, seed recovery already
fails once `2p² < 3^k` — one factor of `p` better than the generic `p³ < 3^k`. -/
theorem not_modSeedRecoverable_of_card_prime (p k : ℕ) [Fact (Nat.Prime p)]
    (h : 2 * p ^ 2 < 3 ^ k) : ¬ ModSeedRecoverable p k := by
  have hpos : 0 < p := Fact.out (p := Nat.Prime p) |>.pos
  haveI : NeZero p := ⟨hpos.ne'⟩
  obtain ⟨s, -, hs⟩ := prime_ambiguity_lower_bound p k 1 (by simpa using h)
  obtain ⟨u, hu, v, hv, huv⟩ := Finset.one_lt_card.1 hs
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hu hv
  refine not_modSeedRecoverable_of_collision (u := List.ofFn u) (w := List.ofFn v) ?_ ?_ ?_ ?_
  · simp
  · simp
  · exact fun hEq => huv (List.ofFn_injective hEq)
  · exact hu.trans hv.symm

end BerggrenModular
end Cryptography